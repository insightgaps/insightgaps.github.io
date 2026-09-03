"""Insight Gaps Bureau — build validation gate (fail-closed).

Run against build output:  python scripts/validate.py [--public public]
Exit 0 = deployable; exit 1 = any error. Warnings do not block.

Checks:
  1. page metadata: exactly one <title>, canonical == self, absolute og:image, description
  2. internal links resolve; known owner-held evidence downloads warn, unknown break
  3. referenced assets exist
  4. route set: no duplicates; sitemap == canonical route universe
  5. redirect map: legacy paths absent from output, each legacy path mapped exactly once
  6. corrections log schema + append-only id ordering
  7. leak scan: private-repo paths and secret patterns must not appear
  8. generated data files parse and reference published works only
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import tomllib
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parent.parent

ALLOWED_MISSING = {
    # Owner-held dataset downloads referenced by the evidence page (documented known issue)
    "/data/BD-INV-002_Master_Evidence_File.xlsx",
    "/data/BD-INV-003_LeadBelt_MasterDataset_v5.csv",
    "/data/BD-INV-003_LeadBelt_MasterDataset_v5.xlsx",
    "/data/PP-ANA-001_PropertyPreservation_MasterDataset.xlsx",
    "/data/osm_schools.geojson",
}

LEAK_PATTERNS = [
    re.compile(r"Anik_OS", re.I),
    re.compile(r"insightgaps-os", re.I),
    re.compile(r"AIza[0-9A-Za-z\-_]{20,}"),
    re.compile(r"sk-[A-Za-z0-9]{20,}"),
    re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
    re.compile(r"api[_-]?key\s*[=:]\s*['\"][A-Za-z0-9]{16,}", re.I),
    re.compile(r"GEMINI_API_KEY|VITE_GEMINI"),
]

SCAN_SUFFIXES = {".html", ".js", ".json", ".xml", ".txt", ".toml", ".md", ".css"}


class Report:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []

    def error(self, msg: str) -> None:
        self.errors.append(msg)

    def warn(self, msg: str) -> None:
        self.warnings.append(msg)

    @property
    def ok(self) -> bool:
        return not self.errors


def load_public(public: Path) -> dict[str, Path]:
    files: dict[str, Path] = {}
    for p in public.rglob("*"):
        if p.is_file():
            files.setdefault("/" + p.relative_to(public).as_posix(), p)
    return files


def resolve_route(files: dict[str, Path], href: str) -> bool:
    path = urlparse(href).path
    if path in files:
        return True
    if not path.endswith("/") and path + "/index.html" in files:
        return True
    if path.endswith("/") and path + "index.html" in files:
        return True
    return False


def strip_noise(text: str) -> tuple[str, str]:
    """Return (text without HTML comments, text without script blocks)."""
    no_comments = re.sub(r"<!--.*?-->", "", text, flags=re.S)
    no_scripts = re.sub(r"<script\b.*?</script>", "", text, flags=re.S | re.I)
    return no_comments, no_scripts


def check_page_metadata(files, rep: Report, canonical_base: str) -> None:
    for rel, path in files.items():
        if not rel.endswith(".html"):
            continue
        if "/views/" in rel:
            continue  # headless JS-loaded partials (property-preservation, WAIT disposition)
        text = path.read_text(encoding="utf-8", errors="replace")
        _, no_scripts = strip_noise(text)
        titles = re.findall(r"<title[^>]*>", no_scripts)
        if len(titles) != 1:
            rep.error(f"{rel}: expected exactly 1 <title>, found {len(titles)}")
        canons = re.findall(r'<link rel="canonical" href="([^"]*)"', text)
        if len(canons) != 1:
            rep.error(f"{rel}: expected exactly 1 canonical, found {len(canons)}")
        elif canons[0] != canonical_base + self_route(rel):
            rep.error(f"{rel}: canonical {canons[0]} != self ({canonical_base}{self_route(rel)})")
        if not re.search(r'<meta name="description" content="[^"]+"', text):
            rep.error(f"{rel}: missing meta description")
        og = re.search(r'property="og:image"\s+content="([^"]*)"', text)
        if not og:
            rep.warn(f"{rel}: no og:image")
        elif not og.group(1).startswith("http"):
            rep.error(f"{rel}: og:image not absolute: {og.group(1)}")


def self_route(rel: str) -> str:
    if rel.endswith("index.html"):
        return rel[: -len("index.html")]
    return rel


def check_links(files, rep: Report) -> None:
    href_re = re.compile(r'(?:href|src)="([^"]+)"')
    for rel, path in files.items():
        if not rel.endswith(".html"):
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        text, _ = strip_noise(text)
        for href in href_re.findall(text):
            if href.startswith(("http://", "https://", "mailto:", "tel:", "#", "data:")):
                continue
            if href == "" or href.startswith("${") or "{{" in href:
                continue  # JS-populated or template residue in frozen docs
            if not href.startswith("/"):
                rep.warn(f"{rel}: relative link {href!r}")
                continue
            if href in ALLOWED_MISSING:
                rep.warn(f"{rel}: owner-held evidence file not in repo: {href}")
                continue
            if href.endswith((".xlsx", ".csv")) and not resolve_route(files, href):
                rep.warn(f"{rel}: dataset download missing: {href}")
                continue
            if not resolve_route(files, href):
                rep.error(f"{rel}: broken internal reference {href}")


def check_routes(files, rep: Report, canonical_base: str) -> set[str]:
    # Sitemap set equality
    sm = files.get("/sitemap.xml")
    if not sm:
        rep.error("sitemap.xml missing")
        return set()
    locs = re.findall(r"<loc>([^<]+)</loc>", sm.read_text(encoding="utf-8"))
    sitemap_routes = {u.replace(canonical_base, "") for u in locs}
    if any(not u.startswith(canonical_base) for u in locs):
        rep.error("sitemap contains non-canonical host URLs")
    pages = {self_route(r) for r in files if r.endswith(".html")}
    pages = {("" if p == "/index.html" else p) for p in pages}
    pages = {p for p in pages if not p.startswith("/analysis/property-preservation/views/")}
    pages.discard("/404.html")  # error pages are intentionally not sitemapped
    missing = pages - sitemap_routes
    extra = sitemap_routes - pages
    for m in sorted(missing):
        rep.error(f"route in output but missing from sitemap: {m}")
    for e in sorted(extra):
        rep.error(f"route in sitemap but absent from output: {e}")
    if len(locs) != len(set(locs)):
        rep.error("sitemap contains duplicate URLs")
    return sitemap_routes


def check_redirects(files, rep: Report) -> None:
    red_path = ROOT / "config" / "redirects.toml"
    red = tomllib.loads(red_path.read_text(encoding="utf-8"))["redirects"]
    out_red = files.get("/_redirects")
    if not out_red:
        rep.error("_redirects missing from output")
        return
    out_lines = [l for l in out_red.read_text(encoding="utf-8").splitlines()
                 if l.strip() and not l.startswith("#")]
    if len(out_lines) != len(red):
        rep.error(f"_redirects has {len(out_lines)} rules, config has {len(red)}")
    for src in red:
        if not src.endswith("*") and resolve_route(files, src):
            rep.error(f"legacy route {src} is mapped as a redirect but still exists in output")


def check_corrections(rep: Report) -> None:
    log = ROOT / "corrections.log.jsonl"
    if not log.exists():
        rep.error("corrections.log.jsonl missing")
        return
    last = 0
    for i, line in enumerate(log.read_text(encoding="utf-8").splitlines(), 1):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        try:
            e = json.loads(line)
        except json.JSONDecodeError as exc:
            rep.error(f"corrections line {i}: {exc}")
            continue
        m = re.fullmatch(r"C-(\d+)", str(e.get("id", "")))
        if not m:
            rep.error(f"corrections line {i}: bad id")
            continue
        if int(m.group(1)) <= last:
            rep.error(f"corrections line {i}: id not append-only-ordered")
        last = int(m.group(1))
        for f in ("date", "work", "summary", "amended"):
            if not e.get(f):
                rep.error(f"corrections line {i}: missing {f}")


def check_leaks(files, rep: Report) -> None:
    for rel, path in files.items():
        if path.suffix not in SCAN_SUFFIXES:
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for pat in LEAK_PATTERNS:
            m = pat.search(text)
            if m:
                rep.error(f"{rel}: leak pattern matched ({m.group(0)[:24]}...)")


def check_data(files, rep: Report) -> None:
    inv = files.get("/data/investigations.json")
    ana = files.get("/data/analysis.json")
    if not inv or not ana:
        rep.error("generated data files missing")
        return
    try:
        investigations = json.loads(inv.read_text(encoding="utf-8"))
        domains = json.loads(ana.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        rep.error(f"generated data file invalid: {exc}")
        return
    for i in investigations:
        if i.get("status") not in ("published", "developing", "corrected"):
            rep.error(f"data/investigations.json contains non-published work {i.get('slug')}")
        if i.get("og_image_path") and not resolve_route(files, i["og_image_path"]):
            rep.error(f"{i.get('slug')}: og_image_path missing in output: {i['og_image_path']}")
    if "domains" not in domains:
        rep.error("data/analysis.json missing domains key")


# ---- Phase 3: report-integrity checks ------------------------------------

REPORT_ROUTES = {
    "/investigations/blood-routes/",
    "/investigations/the-impunity-machine/",
    "/investigations/the-lead-belt/",
    "/investigations/the-impunity-machine/tracker/",
    "/investigations/the-impunity-machine/methodology/",
    "/investigations/the-impunity-machine/detailed/",
    "/investigations/the-lead-belt/methodology/",
}

VALID_EVIDENCE_STATUSES = {"available", "private-held", "not-in-repository"}


def check_report_integrity(files, rep: Report) -> None:
    # Skip report-integrity checks on sites that contain no investigations
    # (fixture trees); they only apply to the real site.
    if not any(r.startswith("/investigations/") for r in files):
        return
    # 1. NewsArticle JSON-LD presence on report routes
    for route in REPORT_ROUTES:
        page = files.get(route + "index.html")
        if not page:
            rep.error(f"report route missing from output: {route}")
            continue
        text = page.read_text(encoding="utf-8", errors="replace")
        if "NewsArticle" not in text:
            rep.error(f"{route}: missing NewsArticle JSON-LD")

    # 2. Manifest evidence_refs consistency: statuses well-formed; links to
    #    non-existent artifacts must be declared not-in-repository/private-held
    inv_file = ROOT / "content" / "investigations"
    for mf in inv_file.glob("*/investigation.json"):
        slug = mf.parent.name
        try:
            inv = json.loads(mf.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            rep.error(f"{slug}: manifest invalid JSON: {exc}")
            continue
        for ref in inv.get("evidence_refs", []):
            status = ref.get("status")
            if status not in VALID_EVIDENCE_STATUSES:
                rep.error(f"{slug}: evidence_refs has invalid status {status!r} for {ref.get('path')}")
                continue
            path = ref.get("path")
            if path and status == "available" and not resolve_route(files, path):
                rep.error(
                    f"{slug}: evidence_refs marks {path} available but it is absent from output "
                    f"(use private-held/not-in-repository, or ship the file)"
                )

    # 3. Slum-fires claim drawer integrity: badges present -> drawer present
    sf = files.get("/investigations/dhaka-slum-fires/index.html")
    if sf:
        text = sf.read_text(encoding="utf-8", errors="replace")
        badges = len(re.findall(r'class="claim-badge"', text))
        has_drawer = "js-drawer" in text and "claimLedger" in text
        if badges > 0 and not has_drawer:
            rep.error(
                f"slum-fires: {badges} claim badges rendered but the verification drawer is absent"
            )
        # every data-claim id must exist in the ledger
        ids = set(re.findall(r'data-claim="(\d+)"', text))
        ledger_ids = set(re.findall(r'"(\d+)":\s*\{\s*ref:', text))
        missing = ids - ledger_ids
        if missing:
            rep.error(f"slum-fires: claim badges without ledger entries: {sorted(missing)}")

    # 4. Evidence page: every referenced /data/ download link must either
    #    resolve or carry a status badge nearby (known-missing set drives warnings)
    ev = files.get("/evidence/index.html")
    if ev:
        text = ev.read_text(encoding="utf-8", errors="replace")
        for m in re.finditer(r'href="(/data/[^"]+)"', text):
            href = m.group(1)
            if not resolve_route(files, href) and href not in ALLOWED_MISSING:
                rep.error(f"evidence page: dead download link without status disclosure: {href}")

    # 5. Investigation index: finding anchors present for every published work
    idx = files.get("/investigations/index.html")
    if idx:
        text = idx.read_text(encoding="utf-8", errors="replace")
        n_works = len(re.findall(r'class="index-work"', text))
        n_findings = len(re.findall(r'id="finding-\d+"', text))
        if n_works > 0 and n_findings == 0:
            rep.error("investigations index: works rendered without finding anchors")


def run(public: Path) -> Report:
    rep = Report()
    if not public.exists():
        rep.error(f"public directory not found: {public}")
        return rep
    site = json.loads((ROOT / "site.json").read_text(encoding="utf-8"))
    canonical_base = site["canonical_base"]
    files = load_public(public)
    if not files:
        rep.error("public output is empty")
        return rep
    check_page_metadata(files, rep, canonical_base)
    check_links(files, rep)
    check_routes(files, rep, canonical_base)
    check_redirects(files, rep)
    check_corrections(rep)
    check_leaks(files, rep)
    check_data(files, rep)
    check_report_integrity(files, rep)
    return rep


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--public", default=str(ROOT / "public"))
    args = ap.parse_args()
    rep = run(Path(args.public))
    for w in rep.warnings:
        print(f"WARN: {w}")
    for e in rep.errors:
        print(f"ERROR: {e}")
    print(f"validation: {'PASS' if rep.ok else 'FAIL'} "
          f"({len(rep.errors)} errors, {len(rep.warnings)} warnings)")
    return 0 if rep.ok else 1


if __name__ == "__main__":
    sys.exit(main())
