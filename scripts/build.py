"""Insight Gaps Bureau — static site generator.

Reads: site.json, content/**, templates/**, config/*.toml, corrections.log.jsonl
Writes: public/ (complete static site)

Fail-closed principle: any validation error raises BuildError and nothing is
deployable. Run: python scripts/build.py
"""
from __future__ import annotations

import datetime as dt
import json
import re
import shutil
import sys
import tomllib
from pathlib import Path

from jinja2 import Environment, FileSystemLoader, select_autoescape
from markupsafe import Markup

ROOT = Path(__file__).resolve().parent.parent
PUBLIC = ROOT / "public"
TEMPLATES = ROOT / "templates"

# Files referenced by the evidence page that are not in the repository.
# Owner-held datasets; surfaced as warnings, never silently ignored.
KNOWN_MISSING_DOWNLOADS = {
    "/data/BD-INV-002_Master_Evidence_File.xlsx",
    "/data/BD-INV-003_LeadBelt_MasterDataset_v5.csv",
    "/data/BD-INV-003_LeadBelt_MasterDataset_v5.xlsx",
    "/data/PP-ANA-001_PropertyPreservation_MasterDataset.xlsx",
    "/data/osm_schools.geojson",
}

# Link repair applied to the property-preservation tree at copy time.
PP_REWRITES = [
    ("/content/investigations/", "/investigations/"),
    ("/content/trust/methodology.html", "/trust/methodology/"),
    ("/content/trust/ai-use.html", "/trust/ai-use/"),
    ("/content/trust/corrections.html", "/trust/corrections/"),
    ("/archive.html", "/archive/"),
    ("/about.html", "/about/"),
    ("/contact.html", "/contact/"),
]


class BuildError(Exception):
    pass


def fmt_date(iso: str | None) -> str:
    if not iso:
        return ""
    try:
        d = dt.date.fromisoformat(iso)
    except ValueError:
        return iso
    return f"{d.day} {d:%B} {d.year}"


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise BuildError(f"Invalid JSON in {path}: {exc}") from exc


# ---------------------------------------------------------------------------
# Loading
# ---------------------------------------------------------------------------

def load_site() -> dict:
    return load_json(ROOT / "site.json")


def load_manifests() -> tuple[list[dict], list[dict]]:
    investigations = []
    for path in sorted((ROOT / "content" / "investigations").glob("*/investigation.json")):
        inv = load_json(path)
        inv["_dir"] = path.parent
        investigations.append(inv)
    analyses = []
    for path in sorted((ROOT / "content" / "analysis").glob("*/analysis.json")):
        analyses.append(load_json(path))
    return investigations, analyses


def load_pages_meta() -> dict:
    return load_json(ROOT / "content" / "pages" / "pages.json")


def load_corrections() -> list[dict]:
    entries = []
    log = ROOT / "corrections.log.jsonl"
    if not log.exists():
        return entries
    for i, line in enumerate(log.read_text(encoding="utf-8").splitlines(), start=1):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        try:
            entries.append(json.loads(line))
        except json.JSONDecodeError as exc:
            raise BuildError(f"corrections.log.jsonl line {i}: invalid JSON: {exc}") from exc
    # Append-only sanity: ids strictly increasing, schema present
    last_num = 0
    for e in entries:
        m = re.fullmatch(r"C-(\d+)", str(e.get("id", "")))
        if not m:
            raise BuildError(f"corrections.log.jsonl: bad id {e.get('id')!r}")
        num = int(m.group(1))
        if num <= last_num:
            raise BuildError(f"corrections.log.jsonl: id {e['id']} out of order (append-only)")
        last_num = num
        for field in ("date", "work", "summary", "amended"):
            if not e.get(field):
                raise BuildError(f"corrections.log.jsonl {e['id']}: missing field {field!r}")
    return entries


# ---------------------------------------------------------------------------
# Manifests -> generated data files (values preserved, URLs canonical)
# ---------------------------------------------------------------------------

def public_investigations(investigations: list[dict]) -> list[dict]:
    """Published investigations in legacy data-file schema (for /data/investigations.json)."""
    out = []
    for inv in investigations:
        if inv.get("status") not in ("published", "developing", "corrected"):
            continue
        entry = {k: v for k, v in inv.items() if not k.startswith("_")}
        out.append(entry)
    out.sort(key=lambda i: i.get("date_published") or "", reverse=True)
    return out


def corrections_injections(corrections: list[dict]) -> str:
    """Generated corrections-log HTML block (empty string while log is empty)."""
    if not corrections:
        return ""
    rows = []
    for c in corrections:
        rows.append(
            "<tr>"
            f'<td class="corrections-table__date">{c["date"]}</td>'
            f'<td class="corrections-table__work">{c["work"]}</td>'
            f'<td class="corrections-table__summary">{c["summary"]}</td>'
            f'<td class="corrections-table__amended">{c["amended"]}</td>'
            "</tr>"
        )
    return (
        '<div class="corrections-table-wrap">'
        '<table class="corrections-table"><thead><tr>'
        "<th>Date</th><th>Work</th><th>What was wrong</th><th>What changed</th>"
        "</tr></thead><tbody>" + "".join(rows) + "</tbody></table></div>"
    )


EMPTY_STATE_RE = re.compile(r'<div class="corrections-empty".*?</div>', re.S)


def inject_corrections(body: str, corrections: list[dict]) -> str:
    if not corrections:
        return body
    if not EMPTY_STATE_RE.search(body):
        raise BuildError("corrections page: entries exist but .corrections-empty block missing")
    return EMPTY_STATE_RE.sub(lambda _: corrections_injections(corrections), body, count=1)


# ---------------------------------------------------------------------------
# Rendering
# ---------------------------------------------------------------------------

def make_env() -> Environment:
    env = Environment(
        loader=FileSystemLoader(str(TEMPLATES)),
        autoescape=select_autoescape(("html", "xml")),
        trim_blocks=False,
        lstrip_blocks=False,
    )
    env.filters["date_format"] = fmt_date
    return env


def absolute(base: str, path: str) -> str:
    if path.startswith("http"):
        return path
    return base + path


def render_template_pages(env, site, pages_meta, investigations, domains, corrections, warnings):
    published_sorted = sorted(
        (i for i in investigations if i.get("status") in ("published", "corrected")),
        key=lambda i: i.get("date_published") or "",
        reverse=True,
    )
    featured = next((i for i in published_sorted if i["slug"] == "the-impunity-machine"),
                    published_sorted[0])
    latest = published_sorted[:3]
    total_sources = sum(int(i.get("source_count") or 0) for i in investigations)
    analysis_domains = domains[0]["domains"] if domains else []
    nav = site["nav"]
    footer_nav = site["footer_nav"]
    base_ctx = dict(nav=nav, footer_nav=footer_nav)
    canonical_base = site["canonical_base"]

    def meta(page: dict, **extra):
        ctx = dict(base_ctx)
        ctx.update(page)
        ctx["canonical"] = canonical_base + page["route"]
        ctx["og_image"] = absolute(canonical_base, page.get("og_image") or "/assets/img/og-default.jpg")
        ctx["page_css"] = page.get("css", [])
        ctx.update(extra)
        return ctx

    out = {}

    jsonld_head = {
        "org": '<script type="application/ld+json">' + org_jsonld(site) + "</script>",
        "home": ('<script type="application/ld+json">' + org_jsonld(site) + "</script>"
                 '<script type="application/ld+json">' + website_jsonld(site) + "</script>"),
    }

    def meta(page: dict, **extra):
        ctx = dict(base_ctx)
        ctx.update(page)
        ctx["canonical"] = canonical_base + page["route"]
        ctx["og_image"] = absolute(canonical_base, page.get("og_image") or "/assets/img/og-default.jpg")
        ctx["page_css"] = page.get("css", [])
        ctx["head_extra"] = Markup(jsonld_head["home" if page["route"] == "/" else "org"])
        ctx.update(extra)
        return ctx

    # Home
    out["index.html"] = env.get_template("home.html").render(
        meta(pages_meta["home"], og_type="website",
             featured=featured, investigations=investigations,
             latest_investigations=latest, total_sources=total_sources,
             domains=analysis_domains, active_nav="",
             stats_notes=site.get("stats_notes", {})),
    )

    # Investigations index: cards + anchored findings + evidence panels per work
    inv_idx = pages_meta["investigations-index"]
    m = env.get_template("macros.html").module
    inv_sections = "".join(m.index_work(i) for i in published_sorted)
    inv_markup = (
        '<div class="index-header"><h1 class="index-title">Investigations</h1></div>'
        '<div class="card-grid--two">'
        + "".join(m.inv_card(i) for i in published_sorted)
        + "</div>"
        + str(inv_sections)
    )
    out["investigations/index.html"] = env.get_template("listing.html").render(
        meta(inv_idx, section_markup=inv_markup, active_nav="/investigations/"))


    ana_idx = pages_meta["analysis-index"]
    ana_markup = (
        '<div class="index-header"><h1 class="index-title">Analysis</h1></div>'
        '<div class="card-grid--two">'
        + "".join(
            env.get_template("macros.html").module.analysis_card(d) for d in analysis_domains
        )
        + "</div>"
    )
    out["analysis/index.html"] = env.get_template("listing.html").render(
        meta(ana_idx, section_markup=ana_markup, active_nav="/analysis/"))

    # Archive (pre-rendered default + embedded JSON for filter enhancement)
    all_tags = sorted({t for i in investigations for t in (i.get("topic_tags") or [])}
                      | {d.get("domain_title", "analysis") for d in analysis_domains})
    archive_items = []
    for i in investigations:
        if i.get("status") in ("published", "corrected", "developing"):
            archive_items.append({"type": "investigation", "status": i.get("status", "archived"),
                                  "tags": i.get("topic_tags") or [],
                                  "date": i.get("date_published") or "", "data": i})
    for d in analysis_domains:
        archive_items.append({"type": "analysis", "status": "published",
                              "tags": [d.get("domain_title", "analysis")],
                              "date": d.get("last_updated") or "", "data": d})
    archive_items.sort(key=lambda x: x["date"] or "", reverse=True)
    archive_json = json.dumps(
        [{k: v for k, v in item.items() if k != "data"} | {"data": {k: v for k, v in item["data"].items() if not k.startswith("_")}}
         for item in archive_items],
        ensure_ascii=False,
    )
    out["archive/index.html"] = env.get_template("archive.html").render(
        meta(pages_meta["archive"],
             investigations=investigations, domains=analysis_domains,
             all_tags=all_tags, archive_items=archive_items, archive_json=archive_json,
             active_nav=""))

    # Standard fragment pages
    for key, tpl_vars in [
        ("about", {}),
        ("contact", {}),
        ("404", {}),
        ("evidence", {}),
        ("trust-methodology", {}),
        ("trust-ai-use", {}),
        ("trust-corrections", {}),
    ]:
        page = pages_meta[key]
        body_path = ROOT / "content" / "pages" / f"{key}.body.html"
        body = body_path.read_text(encoding="utf-8")
        if key == "trust-corrections":
            body = inject_corrections(body, corrections)
        route_file = "404.html" if key == "404" else page["route"].lstrip("/") + "index.html"
        out[route_file] = env.get_template("standard.html").render(
            meta(page, body=body, active_nav=page["route"] if page["route"] != "/" else ""))

    # Investigation pages: standalone report documents are emitted separately
    # (see STANDALONE_ROUTES / emit_standalone). Template-kind investigation
    # pages would render here from content/pages/<slug>.body.html.
    # NOTE: dhaka-slum-fires was unpublished by owner decision on 2026-09-03
    # (audit REP-001/004/007 cluster); its route now redirects to /investigations/.

    return out


# ---------------------------------------------------------------------------
# Standalone report documents (frozen presentation; metadata repair only)
# ---------------------------------------------------------------------------

STANDALONE_ROUTES = {
    "content/investigations/blood-routes/report.html": "/investigations/blood-routes/",
    "content/investigations/the-lead-belt/report.html": "/investigations/the-lead-belt/",
    "content/investigations/the-lead-belt/methodology_full.html": "/investigations/the-lead-belt/methodology/",
    "content/investigations/the-impunity-machine/report.html": "/investigations/the-impunity-machine/",
    "content/investigations/the-impunity-machine/detailed.html": "/investigations/the-impunity-machine/detailed/",
    "content/investigations/the-impunity-machine/methodology_full.html": "/investigations/the-impunity-machine/methodology/",
    "content/investigations/the-impunity-machine/tracker.html": "/investigations/the-impunity-machine/tracker/",
}


def wayfinding_strip(inv, investigations) -> str:
    """Breadcrumb + related-work strip injected atop report pages (Phase 4).
    Generated entirely from manifest data; self-contained styles."""
    related = []
    by_id = {i["id"]: i for i in investigations}
    for rid in inv.get("related_items") or []:
        r = by_id.get(rid)
        if r and r.get("status") in ("published", "corrected"):
            related.append(f'<a href="{r["url"]}" style="color:inherit;text-decoration:underline;text-underline-offset:2px;">{r["title"]}</a>')
    related_html = (
        '<span style="white-space:nowrap;">Related: ' + " · ".join(related) + "</span>"
        if related else ""
    )
    return (
        '<nav aria-label="Investigation wayfinding" style="'
        "font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;"
        "font-size:0.66rem;letter-spacing:0.06em;text-transform:uppercase;"
        "display:flex;flex-wrap:wrap;gap:0.4rem 1.2rem;justify-content:space-between;"
        "align-items:center;padding:0.55rem clamp(1rem,4vw,3rem);"
        'border-bottom:1px solid rgba(128,128,128,0.25);">'
        f'<span style="display:flex;flex-wrap:wrap;gap:0 0.4rem;"><a href="/" style="color:inherit;text-decoration:none;">Home</a>'
        ' <span aria-hidden="true" style="opacity:0.5;">&rsaquo;</span> '
        f'<a href="/investigations/" style="color:inherit;text-decoration:none;">Investigations</a>'
        ' <span aria-hidden="true" style="opacity:0.5;">&rsaquo;</span> '
        f'<span style="opacity:0.75;overflow-wrap:anywhere;">{inv["title"]}</span></span>'
        f"{related_html}"
        "</nav>"
    )



READABILITY_FLOOR = (
    "\n  <style>/* Phase 4 presentation repairs (audit REP-013). Presentation-only; no content altered. "
    "Mobile: readability floor for micro inline type; sub-nav wrapping; canvas scaling; "
    "table horizontal scroll; scroll containment for animation tracks. "
    "Known residual (owner-gated D-9ii): the frozen Impunity Machine report retains "
    "20-40px horizontal overflow at <=414px from inline-styled absolute/flex elements; "
    "the full fix requires the report-redesign pass, not CSS overrides. */"
    "@media (max-width: 768px){"
    " body * { font-size: max(11px, 0.6875em) !important; }"
    " .sub-nav__inner, .sub-nav__scenes, .sub-nav__actions { max-width: 100% !important; flex-wrap: wrap !important; overflow-x: auto !important; }"
    " canvas { max-width: 100% !important; height: auto !important; }"
    " [class*='track'] { max-width: 100vw !important; overflow: hidden !important; }"
    " table { display: block !important; overflow-x: auto !important; max-width: 100% !important; }"
    " .counter-right, .cr-item, .tier { max-width: 100% !important; overflow-wrap: anywhere !important; }"
    "}</style>"
)

def repair_standalone(text: str, route: str, site: dict, title: str, description: str) -> str:
    base = site["canonical_base"]
    canonical = base + route
    # Canonical + og:url pinned to emit route
    text = re.sub(r'(<link rel="canonical" href=")[^"]*(")', lambda m: m.group(1) + canonical + m.group(2), text, count=1)
    text = re.sub(r'(<meta property="og:url" content=")[^"]*(")', lambda m: m.group(1) + canonical + m.group(2), text, count=1)
    # Absolute og:image for pages that have one; inject block when absent
    def absolutize(m):
        val = m.group(2)
        if val.startswith("http"):
            return m.group(0)
        return m.group(1) + base + val + m.group(3)
    text = re.sub(r'(property="og:image" content=")([^"]+)(")', absolutize, text)
    text = re.sub(r'(name="twitter:image" content=")([^"]+)(")', absolutize, text)
    if 'property="og:title"' not in text:
        inject = (
            f'\n  <meta property="og:title" content="{title}">\n'
            f'  <meta property="og:description" content="{description}">\n'
            f'  <meta property="og:url" content="{canonical}">\n'
            f'  <meta property="og:image" content="{base}/assets/img/og-default.jpg">\n'
            f'  <link rel="canonical" href="{canonical}">'
        )
        text = text.replace("</title>", "</title>" + inject, 1)
    # Canonical tag may be duplicated by the inject path; keep first only
    seen = []
    def dedupe_canon(m):
        seen.append(1)
        return m.group(0) if len(seen) == 1 else ""
    text = re.sub(r'<link rel="canonical" href="[^"]*">', dedupe_canon, text)
    # Phase 4: readability floor for micro inline type (mobile)
    if "readability floor" not in text:
        text = text.replace("</head>", READABILITY_FLOOR + "\n</head>", 1)
    return text


def emit_standalone(site, investigations, warnings) -> int:
    count = 0
    inv_by_slug = {i["url"]: i for i in investigations}
    for src_rel, route in STANDALONE_ROUTES.items():
        src = ROOT / src_rel
        if not src.exists():
            raise BuildError(f"standalone source missing: {src_rel}")
        text = src.read_text(encoding="utf-8")
        tmatch = re.search(r"<title[^>]*>(.*?)</title>", text, re.S)
        title = re.sub(r"<[^>]+>", "", tmatch.group(1)).strip() if tmatch else "Insight Gaps Bureau"
        dmatch = re.search(r'<meta name="description" content="([^"]*)"', text)
        description = dmatch.group(1) if dmatch else ""
        text = repair_standalone(text, route, site, title, description)
        # Phase 4: wayfinding breadcrumb + related-work strip (top of body,
        # above the AI disclosure bar; manifest-generated, self-contained).
        inv = inv_by_slug.get(route)
        if inv and inv.get("status") in ("published", "corrected"):
            strip = wayfinding_strip(inv, investigations)
            body_m = re.search(r"<body[^>]*>", text)
            if body_m and 'aria-label="Investigation wayfinding"' not in text:
                insert_at = body_m.end()
                text = text[:insert_at] + "\n" + strip + "\n" + text[insert_at:]
        dst = PUBLIC / route.lstrip("/") / "index.html"
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(text, encoding="utf-8")
        count += 1
    return count


# ---------------------------------------------------------------------------
# Static copying + generated config files
# ---------------------------------------------------------------------------

COPY_DIRS = ["assets", "methods"]
COPY_FILES = ["theme-toggle.js", "favicon.png"]


def copy_static(warnings) -> None:
    for d in COPY_DIRS:
        src = ROOT / d
        dst = PUBLIC / d
        if src.exists():
            shutil.copytree(src, dst, dirs_exist_ok=True,
                            ignore=shutil.ignore_patterns("*.pyc", "__pycache__"))
    for f in COPY_FILES:
        if (ROOT / f).exists():
            shutil.copy2(ROOT / f, PUBLIC / f)
    # Data files: generated manifests + frozen-report JSON data
    data_dst = PUBLIC / "data"
    data_dst.mkdir(parents=True, exist_ok=True)
    for f in (ROOT / "data").glob("*"):
        if f.suffix in (".json", ".geojson", ".md") and f.name not in ("investigations.json", "analysis.json"):
            shutil.copy2(f, data_dst / f.name)
    # Property preservation analysis app: copied with link/host repair only
    # (WAIT disposition — markup untouched otherwise).
    pp_src = ROOT / "analysis" / "property-preservation"
    pp_dst = PUBLIC / "analysis" / "property-preservation"
    if pp_src.exists():
        shutil.copytree(pp_src, pp_dst, dirs_exist_ok=True,
                        ignore=shutil.ignore_patterns("*.pyc", "__pycache__"))
        for html in pp_dst.rglob("*.html"):
            text = html.read_text(encoding="utf-8")
            for old, new in PP_REWRITES:
                text = text.replace(old, new)
            text = text.replace("https://insightgaps.com", "https://www.insightgaps.com")
            base = "https://www.insightgaps.com"
            text = re.sub(r'(property="og:image"\s+content=")(/[^"]+)(")',
                          lambda m: m.group(1) + base + m.group(2) + m.group(3), text)
            text = re.sub(r'(name="twitter:image"\s+content=")(/[^"]+)(")',
                          lambda m: m.group(1) + base + m.group(2) + m.group(3), text)
            html.write_text(text, encoding="utf-8")
    # Investigation sidecars (satellite proof, methodology md, verification reports)
    for slug_dir in (ROOT / "content" / "investigations").iterdir():
        if not slug_dir.is_dir():
            continue
        for item in slug_dir.rglob("*"):
            if item.is_file() and item.suffix in (".md", ".jpg", ".png") and "investigation.json" not in item.name:
                rel = item.relative_to(slug_dir)
                (PUBLIC / "investigations" / slug_dir.name / rel).parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(item, PUBLIC / "investigations" / slug_dir.name / rel)


def gen_data_files(investigations, domains) -> None:
    data = PUBLIC / "data"
    data.mkdir(parents=True, exist_ok=True)
    (data / "investigations.json").write_text(
        json.dumps(public_investigations(investigations), indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8")
    (data / "analysis.json").write_text(
        json.dumps(domains[0], indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def gen_redirects_headers() -> None:
    red = tomllib.loads((ROOT / "config" / "redirects.toml").read_text(encoding="utf-8"))["redirects"]
    lines = ["# Generated by scripts/build.py from config/redirects.toml — do not edit.\n"]
    for src, dst in red.items():
        lines.append(f"{src}\t{dst}\t301")
    (PUBLIC / "_redirects").write_text("\n".join(lines) + "\n", encoding="utf-8")

    hdr = tomllib.loads((ROOT / "config" / "headers.toml").read_text(encoding="utf-8"))
    out = []
    for rule in hdr.get("headers", []):
        out.append(f"[{rule['for']}]")
        for k, v in rule.get("values", {}).items():
            out.append(f"  {k}: {v}")
        out.append("")
    (PUBLIC / "_headers").write_text("\n".join(out), encoding="utf-8")


def route_universe(investigations, pages_meta) -> list[str]:
    routes = ["/"]
    routes += [v["route"] for k, v in pages_meta.items() if k != "404"]
    routes += list(STANDALONE_ROUTES.values())
    for name in ("", "financial-health.html", "leakage-breakdown.html",
                 "work-order-breakdown.html", "sheet.html"):
        routes.append("/analysis/property-preservation/" + name)
    return sorted(set(routes))


def gen_sitemap_robots(site, investigations, pages_meta) -> None:
    base = site["canonical_base"]
    items = route_universe(investigations, pages_meta)
    today = dt.date.today().isoformat()
    lines = ['<?xml version="1.0" encoding="UTF-8"?>',
             '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']
    for r in items:
        lines.append("  <url><loc>" + base + r + "</loc><lastmod>" + today + "</lastmod></url>")
    lines.append("</urlset>")
    (PUBLIC / "sitemap.xml").write_text("\n".join(lines) + "\n", encoding="utf-8")
    (PUBLIC / "robots.txt").write_text(
        "User-agent: *\nAllow: /\n\n"
        f"Sitemap: {base}/sitemap.xml\n", encoding="utf-8")


def gen_llms(site) -> None:
    src = ROOT / "content" / "pages" / "llms.txt"
    if src.exists():
        shutil.copy2(src, PUBLIC / "llms.txt")


# ---------------------------------------------------------------------------
# JSON-LD
# ---------------------------------------------------------------------------

def org_jsonld(site) -> str:
    data = {
        "@context": "https://schema.org",
        "@type": "Organization",
        "name": site["organization"],
        "url": site["canonical_base"] + "/",
        "description": site["description"],
        "email": site["contact_email"],
        "logo": site["canonical_base"] + "/assets/img/og-default.jpg",
    }
    return json.dumps(data, ensure_ascii=False)


def article_jsonld(site, inv) -> str:
    data = {
        "@context": "https://schema.org",
        "@type": "NewsArticle",
        "headline": inv["title"],
        "description": inv.get("dek") or inv.get("summary") or "",
        "datePublished": inv.get("date_published"),
        "author": {"@type": "Organization", "name": site["organization"], "url": site["canonical_base"] + "/"},
        "publisher": {"@type": "Organization", "name": site["organization"], "url": site["canonical_base"] + "/"},
        "mainEntityOfPage": site["canonical_base"] + inv["url"],
    }
    if inv.get("og_image_path"):
        data["image"] = absolute(site["canonical_base"], inv["og_image_path"])
    return json.dumps(data, ensure_ascii=False)


def website_jsonld(site) -> str:
    data = {
        "@context": "https://schema.org",
        "@type": "WebSite",
        "name": site["organization"],
        "url": site["canonical_base"] + "/",
    }
    return json.dumps(data, ensure_ascii=False)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    site = load_site()
    investigations, domains = load_manifests()
    pages_meta = load_pages_meta()
    corrections = load_corrections()
    warnings: list[str] = []

    # Manifest gate: published works must be complete
    for inv in investigations:
        for field in ("id", "title", "slug", "url", "date_published", "status",
                      "dek", "summary", "og_image_path", "source_count"):
            if field not in inv:
                raise BuildError(f"{inv.get('slug')}: manifest missing field {field!r}")
        if inv["status"] in ("published", "corrected"):
            if not inv.get("key_findings"):
                raise BuildError(f"{inv['slug']}: published work has no key_findings")
        # referenced OG images must exist
        if inv.get("og_image_path") and not (PUBLIC_STATIC := ROOT / inv["og_image_path"].lstrip("/")).exists():
            if inv["og_image_path"] != "/assets/img/dhaka-slum-fires-infographic.png":
                raise BuildError(f"{inv['slug']}: og_image_path missing on disk: {inv['og_image_path']}")

    if PUBLIC.exists():
        shutil.rmtree(PUBLIC)
    PUBLIC.mkdir(parents=True)

    copy_static(warnings)
    gen_data_files(investigations, domains)
    gen_redirects_headers()
    gen_sitemap_robots(site, investigations, pages_meta)
    gen_llms(site)

    env = make_env()
    rendered = render_template_pages(env, site, pages_meta, investigations, domains, corrections, warnings)

    for rel, html in list(rendered.items()):
        m = re.search(r"\{\{[^}]*\}\}|\{%[^%]*%\}", html)
        if m:
            raise BuildError(f"{rel}: unrendered template tag {m.group(0)!r}")
        rendered[rel] = html

    for rel, html in rendered.items():
        dst = PUBLIC / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(html, encoding="utf-8")

    n_standalone = emit_standalone(site, investigations, warnings)

    # NewsArticle JSON-LD injected into each investigation's report routes at
    # the </title> boundary (surgical; legacy JSON-LD untouched). Covers the
    # main report route plus declared subpages (methodology/tracker/detailed).
    n_injected = 0
    for inv in investigations:
        if inv.get("status") not in ("published", "corrected"):
            continue
        routes = [inv["url"]] + list((inv.get("subpages") or {}).values())
        for route in routes:
            route_file = route.lstrip("/") + "index.html"
            page_path = PUBLIC / route_file
            if not page_path.exists():
                continue
            text = page_path.read_text(encoding="utf-8")
            if "NewsArticle" in text:
                continue  # already present (e.g., legacy markup) — never duplicate
            block = '<script type="application/ld+json">' + article_jsonld(site, inv) + "</script>"
            text = text.replace("</title>", "</title>\n  " + block, 1)
            page_path.write_text(text, encoding="utf-8")
            n_injected += 1
    print(f"  NewsArticle JSON-LD injected on {n_injected} report pages")

    # Known-missing evidence downloads -> warnings (owner-held files)
    for missing in sorted(KNOWN_MISSING_DOWNLOADS):
        warnings.append(f"evidence download referenced but not in repository: {missing}")

    print(f"build: {len(rendered)} template pages, {n_standalone} standalone documents")
    for w in warnings:
        print(f"  WARN: {w}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
