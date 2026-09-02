"""Fixture test: the validator must FAIL on seeded defects.

Builds a tiny fake public tree with one defect per fixture and asserts
validate.run() flags each. Run: python tests/test_validate.py
"""
from __future__ import annotations

import json
import shutil
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import validate  # noqa: E402

PAGE = """<!DOCTYPE html>
<html><head><title>T</title>
<meta name="description" content="d">
<link rel="canonical" href="https://www.insightgaps.com{route}">
<meta property="og:image" content="https://www.insightgaps.com/assets/img/og-default.jpg">
</head><body><main>{body}</main></body></html>
"""


def make_site(tmp: Path, page_html: str, route: str = "/") -> Path:
    public = tmp / "public"
    (public / "assets").mkdir(parents=True)
    (public / "data").mkdir(parents=True)
    (public / "sitemap.xml").write_text(
        '<?xml version="1.0"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
        f'<url><loc>https://www.insightgaps.com{route}</loc></url></urlset>', encoding="utf-8")
    # Mirror the real generated redirect file so rule-count parity holds
    real_redirects = Path(__file__).resolve().parent.parent / "public" / "_redirects"
    (public / "_redirects").write_text(
        real_redirects.read_text(encoding="utf-8") if real_redirects.exists() else "",
        encoding="utf-8")
    (public / "data" / "investigations.json").write_text("[]", encoding="utf-8")
    (public / "data" / "analysis.json").write_text('{"domains":[]}', encoding="utf-8")
    f = public / route.lstrip("/") / ("index.html" if route.endswith("/") else "")
    f.parent.mkdir(parents=True, exist_ok=True)
    if f.is_dir() or not f.name:
        f = f / "index.html"
    f.write_text(page_html, encoding="utf-8")
    return public


def expect_fail(name: str, public: Path, needle: str) -> None:
    rep = validate.run(public)
    if rep.ok:
        print(f"FAIL(test) {name}: validator passed a defective fixture")
        sys.exit(1)
    if not any(needle in e for e in rep.errors):
        print(f"FAIL(test) {name}: flagged {rep.errors} but expected '{needle}'")
        sys.exit(1)
    print(f"ok  {name}")


def expect_pass(name: str, public: Path) -> None:
    rep = validate.run(public)
    if not rep.ok:
        print(f"FAIL(test) {name}: validator rejected a clean fixture: {rep.errors}")
        sys.exit(1)
    print(f"ok  {name}")


def main() -> None:
    tmp = Path(tempfile.mkdtemp(prefix="ig-validate-tests-"))
    good = PAGE.format(route="/", body='<a href="/">Home</a>')
    expect_pass("clean page", make_site(tmp / "c", good))

    expect_fail("broken canonical",
                make_site(tmp / "b1", PAGE.format(route="/other/", body="")),
                "canonical")
    expect_fail("broken link",
                make_site(tmp / "b2", PAGE.format(route="/", body='<a href="/nope/">x</a>')),
                "broken internal")
    expect_fail("missing description",
                make_site(tmp / "b3", PAGE.format(route="/", body="").replace(
                    '<meta name="description" content="d">', "")),
                "description")
    expect_fail("relative og:image",
                make_site(tmp / "b4", PAGE.format(route="/", body="").replace(
                    'content="https://www.insightgaps.com/assets/img/og-default.jpg"',
                    'content="/assets/img/og-default.jpg"')),
                "og:image")
    expect_fail("leak pattern",
                make_site(tmp / "b5", PAGE.format(route="/", body="Anik_OS reference")),
                "leak pattern")
    # orphan route: a page present in output but absent from the sitemap
    b7 = make_site(tmp / "b7", PAGE.format(route="/", body=""))
    (b7 / "secret").mkdir(parents=True, exist_ok=True)
    (b7 / "secret" / "index.html").write_text(
        PAGE.format(route="/secret/", body=""), encoding="utf-8")
    expect_fail("orphan route (unsitemapped page)",
                b7, "missing from sitemap: /secret/")

    shutil.rmtree(tmp, ignore_errors=True)
    print("all validator fixture tests passed")


if __name__ == "__main__":
    main()
