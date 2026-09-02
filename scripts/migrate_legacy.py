"""One-time Phase 2 migration: extract legacy pages into the new source structure.

Reads legacy HTML at the repo root, writes:
  - content/pages/<name>.body.html + .styles.html fragments (template pages)
  - content/investigations/<slug>/ full standalone documents (link-rewritten)
  - content/pages/pages.json (template-page metadata)
  - assets/css/pages/<name>.css (page-specific styles extracted from <style> blocks)
  - assets/css/home.css

Idempotent: safe to re-run. Does not delete legacy files (cleanup is a separate step).
"""
import json
import re
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
LEG = REPO  # legacy files currently live at repo root

# Ordered longest-first; applied to href/src/canonical/og attributes and plain text.
REWRITES = [
    ("/content/investigations/the-impunity-machine/methodology.html", "/investigations/the-impunity-machine/methodology/"),
    ("/content/investigations/the-impunity-machine/tracker.html", "/investigations/the-impunity-machine/tracker/"),
    ("/content/investigations/the-impunity-machine/detailed.html", "/investigations/the-impunity-machine/detailed/"),
    ("/content/investigations/the-impunity-machine/", "/investigations/the-impunity-machine/"),
    ("/content/investigations/the-lead-belt/methodology.html", "/investigations/the-lead-belt/methodology/"),
    ("/content/investigations/the-lead-belt/", "/investigations/the-lead-belt/"),
    ("/content/investigations/dhaka-slum-fires/", "/investigations/dhaka-slum-fires/"),
    ("/content/investigations/", "/investigations/"),
    ("/content/trust/methodology.html", "/trust/methodology/"),
    ("/content/trust/ai-use.html", "/trust/ai-use/"),
    ("/content/trust/corrections.html", "/trust/corrections/"),
    ("/investigations/national/blood-routes/", "/investigations/blood-routes/"),
    ("/archive.html", "/archive/"),
    ("/about.html", "/about/"),
    ("/contact.html", "/contact/"),
]

TEMPLATE_PAGES = {
    # name -> legacy path
    "about": "about.html",
    "contact": "contact.html",
    "404": "404.html",
    "evidence": "data/index.html",
    "trust-methodology": "content/trust/methodology.html",
    "trust-ai-use": "content/trust/ai-use.html",
    "trust-corrections": "content/trust/corrections.html",
    "slum-fires": "content/investigations/dhaka-slum-fires/index.html",
}

STANDALONE = {
    "investigations/national/blood-routes/index.html":
        "content/investigations/blood-routes/report.html",
    "content/investigations/the-lead-belt/index.html":
        "content/investigations/the-lead-belt/report.html",
    "content/investigations/the-lead-belt/methodology.html":
        "content/investigations/the-lead-belt/methodology_full.html",
    "content/investigations/the-impunity-machine/index.html":
        "content/investigations/the-impunity-machine/report.html",
    "content/investigations/the-impunity-machine/detailed.html":
        "content/investigations/the-impunity-machine/detailed.html",
    "content/investigations/the-impunity-machine/methodology.html":
        "content/investigations/the-impunity-machine/methodology_full.html",
    "content/investigations/the-impunity-machine/tracker.html":
        "content/investigations/the-impunity-machine/tracker.html",
}

# Template-page metadata (values from legacy heads; canonicals rewritten to www/new).
PAGES_JSON = {
    "home": {
        "route": "/",
        "title": "Insight Gaps Bureau — Forensic Data Journalism from Dhaka",
        "description": "Independent forensic data journalism from Dhaka, Bangladesh. Investigations into contamination, institutional failure, and accountability gaps.",
        "og_title": "Insight Gaps Bureau",
        "og_description": "Independent forensic data journalism from Dhaka, Bangladesh.",
        "og_image": "/assets/img/og-default.jpg",
        "css": ["/assets/css/home.css"],
    },
    "about": {
        "route": "/about/",
        "title": "About the Bureau — Insight Gaps Bureau",
        "description": "Insight Gaps Bureau is an independent forensic data journalism organization and operational intelligence practice based in Dhaka, Bangladesh, producing accountability investigations and public-interest data audits.",
        "og_title": "About — Insight Gaps Bureau",
        "og_description": "Independent forensic data journalism and operational intelligence from Dhaka, Bangladesh. Built to verify facts and expose systemic gaps.",
        "og_image": "/assets/img/og-default.jpg",
        "main_class": "about-page",
    },
    "contact": {
        "route": "/contact/",
        "title": "Contact — Insight Gaps Bureau",
        "description": "Submit a tip or get in touch with Insight Gaps Bureau. Secure tip submission and general contact information.",
        "og_title": "Contact — Insight Gaps Bureau",
        "og_description": "Submit a tip or get in touch with Insight Gaps Bureau.",
        "og_image": "/assets/img/og-default.jpg",
        "main_class": "contact-page",
    },
    "404": {
        "route": "/404.html",
        "title": "Page Not Found — Insight Gaps Bureau",
        "description": "The page you are looking for does not exist.",
        "og_title": "Page Not Found — Insight Gaps Bureau",
        "og_description": "The page you are looking for does not exist.",
        "og_image": "/assets/img/og-default.jpg",
        "main_class": "error-page",
        "no_chrome": False,
    },
    "evidence": {
        "route": "/evidence/",
        "title": "Data Repository — Insight Gaps Bureau",
        "description": "Public evidence packages, datasets, and source documentation for Insight Gaps Bureau investigations.",
        "og_title": "Data Repository — Insight Gaps Bureau",
        "og_description": "Public evidence packages, datasets, and source documentation for Insight Gaps Bureau investigations.",
        "og_image": "/assets/img/og-default.jpg",
        "main_class": "data-page",
    },
    "trust-methodology": {
        "route": "/trust/methodology/",
        "title": "Methodology — Insight Gaps Bureau",
        "description": "How Insight Gaps Bureau verifies data, sources, and claims before publication. Verification tiers, data handling rules, and editorial standards.",
        "og_title": "Methodology — Insight Gaps Bureau",
        "og_description": "How Insight Gaps Bureau verifies data, sources, and claims before publication.",
        "og_image": "/assets/img/og-default.jpg",
        "main_class": "trust-page",
    },
    "trust-ai-use": {
        "route": "/trust/ai-use/",
        "title": "AI Use Disclosure — Insight Gaps Bureau",
        "description": "Full transparency ledger of AI tool use in Insight Gaps Bureau operations — which tools, what roles, and what they are prohibited from owning.",
        "og_title": "AI Use Disclosure — Insight Gaps Bureau",
        "og_description": "Full transparency ledger of AI tool use in Insight Gaps Bureau operations.",
        "og_image": "/assets/img/og-default.jpg",
        "main_class": "trust-page",
    },
    "trust-corrections": {
        "route": "/trust/corrections/",
        "title": "Corrections Log — Insight Gaps Bureau",
        "description": "Permanent timestamped record of every correction ever issued by Insight Gaps Bureau. Entries are never deleted — only appended.",
        "og_title": "Corrections Log — Insight Gaps Bureau",
        "og_description": "Permanent timestamped record of every correction ever issued by Insight Gaps Bureau.",
        "og_image": "/assets/img/og-default.jpg",
        "main_class": "trust-page",
    },
    "investigations-index": {
        "route": "/investigations/",
        "title": "Investigations — Insight Gaps Bureau",
        "description": "Published and developing investigations from Insight Gaps Bureau.",
        "og_title": "Investigations — Insight Gaps Bureau",
        "og_description": "Published and developing investigations from Insight Gaps Bureau.",
        "og_image": "/assets/img/og-default.jpg",
        "main_class": "investigations-index",
    },
    "analysis-index": {
        "route": "/analysis/",
        "title": "Analysis — Insight Gaps Bureau",
        "description": "Commercial analysis, operational intelligence, and performance dashboards by Insight Gaps Bureau.",
        "og_title": "Analysis — Insight Gaps Bureau",
        "og_description": "Commercial analysis, operational intelligence, and performance dashboards by Insight Gaps Bureau.",
        "og_image": "/assets/img/og-default.jpg",
        "main_class": "investigations-index",
    },
    "archive": {
        "route": "/archive/",
        "title": "Archive — Insight Gaps Bureau",
        "description": "Complete index of all investigations and analysis reports published by Insight Gaps Bureau.",
        "og_title": "Archive — Insight Gaps Bureau",
        "og_description": "Complete index of all investigations and analysis reports published by Insight Gaps Bureau.",
        "og_image": "/assets/img/og-default.jpg",
        "main_class": "archive",
    },
    "slum-fires": {
        "route": "/investigations/dhaka-slum-fires/",
        "title": "Dhaka Slum Fires · Land Transformation & Eviction Bypass · Insight Gaps",
        "description": "A spatial forensic overlay investigation tracing how catastrophic fires bypass constitutional eviction protections to clear high-value infrastructure corridors in Dhaka.",
        "og_title": "Dhaka Slum Fires · Land Transformation & Eviction Bypass · Insight Gaps",
        "og_description": "A spatial forensic overlay investigation tracing how catastrophic fires bypass constitutional eviction protections to clear high-value infrastructure corridors in Dhaka.",
        "og_image": "/assets/img/og-default.jpg",
        "main_class": "investigation",
    },
}


def rewrite(text: str) -> str:
    for old, new in REWRITES:
        text = text.replace(old, new)
    text = text.replace('href="/data/"', 'href="/evidence/"')
    text = text.replace("https://insightgaps.com", "https://www.insightgaps.com")
    text = text.replace("../../../theme-toggle.js", "/theme-toggle.js")
    return text


def extract_main(text: str):
    m = re.search(r"<main[^>]*>(.*)</main>", text, re.S | re.I)
    return m.group(1) if m else None


def extract_styles(text: str):
    return re.findall(r"<style[^>]*>(.*?)</style>", text, re.S | re.I)


def main() -> None:
    pages_dir = REPO / "content" / "pages"
    css_dir = REPO / "assets" / "css" / "pages"
    pages_dir.mkdir(parents=True, exist_ok=True)
    css_dir.mkdir(parents=True, exist_ok=True)

    pages_meta = dict(PAGES_JSON)

    # --- Home: styles only (body is template-rendered) ---
    home_src = (LEG / "index.html").read_text(encoding="utf-8")
    home_css = "\n\n".join(extract_styles(home_src))
    (REPO / "assets" / "css" / "home.css").write_text(
        "/* Home-specific layout — extracted from legacy index.html inline styles */\n"
        + home_css
        + "\n",
        encoding="utf-8",
    )

    # --- Template pages: extract main body + styles ---
    for name, rel in TEMPLATE_PAGES.items():
        src = LEG / rel
        text = src.read_text(encoding="utf-8")
        body = extract_main(text)
        if body is None:
            raise SystemExit(f"No <main> found in {rel}")
        styles = extract_styles(text)
        css = "\n\n".join(styles).strip()
        if css:
            (css_dir / f"{name}.css").write_text(
                f"/* Page styles — extracted from legacy {rel} */\n" + css + "\n",
                encoding="utf-8",
            )
            pages_meta[name]["css"] = [f"/assets/css/pages/{name}.css"]
        (pages_dir / f"{name}.body.html").write_text(
            rewrite(body).strip() + "\n", encoding="utf-8"
        )

    # --- Archive styles (filter bar lives in template; keep its css) ---
    arch = (LEG / "archive.html").read_text(encoding="utf-8")
    arch_css = "\n\n".join(extract_styles(arch)).strip()
    (css_dir / "archive.css").write_text(
        "/* Archive page styles — extracted from legacy archive.html */\n" + arch_css + "\n",
        encoding="utf-8",
    )
    pages_meta["archive"]["css"] = ["/assets/css/pages/archive.css"]

    # --- Listings index styles (shared investigations-index styles) ---
    idx = (LEG / "content/investigations/index.html").read_text(encoding="utf-8")
    idx_css = "\n\n".join(extract_styles(idx)).strip()
    (css_dir / "listing.css").write_text(
        "/* Listing index styles — extracted from legacy investigations index */\n" + idx_css + "\n",
        encoding="utf-8",
    )
    pages_meta["investigations-index"]["css"] = ["/assets/css/pages/listing.css"]
    pages_meta["analysis-index"]["css"] = ["/assets/css/pages/listing.css"]

    # --- Standalone documents: full copy with link rewrites ---
    for rel_src, rel_dst in STANDALONE.items():
        text = (LEG / rel_src).read_text(encoding="utf-8")
        text = rewrite(text)
        dst = REPO / rel_dst
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(text, encoding="utf-8")

    (pages_dir / "pages.json").write_text(
        json.dumps(pages_meta, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    print("Migration extraction complete:")
    print(f"  template fragments: {len(TEMPLATE_PAGES)} -> {pages_dir}")
    print(f"  standalone docs:    {len(STANDALONE)}")
    print(f"  pages.json entries: {len(pages_meta)}")


if __name__ == "__main__":
    main()
