# Insight Gaps Bureau — Website Runbook

One page. If you are the next operator, read this first.

## What this repository is

The production website for www.insightgaps.com. It is a **generated static site**:
source content lives in `content/`, and `scripts/build.py` produces the deployable
site into `public/`. `public/` is never committed and never edited by hand.

## The one command

```
python scripts/build.py && python scripts/validate.py
```

Build renders every page; validation fails the deploy on any error (broken link,
missing canonical, missing asset, unsitemapped route, leak pattern, bad manifest).
Warnings do not block; they are reviewed in the build log.

## Publishing a change

1. Edit source files (`content/**`, templates, manifests, `site.json`).
2. Commit to a branch; push. Cloudflare Pages builds a **preview URL**.
3. Check the preview. Merge to `main` → production deploys.
4. Emergency rollback: Cloudflare Pages dashboard → previous deployment.
   (Rollback redeploys a previously validated build; it cannot introduce new content.)

## Where things live

| Thing | Location |
|---|---|
| Report/presentation page bodies | `content/pages/*.body.html`, `content/investigations/*/report.html` |
| Investigation manifests | `content/investigations/<slug>/investigation.json` |
| Analysis domain manifests | `content/analysis/<slug>/analysis.json` |
| Corrections log (**append-only**) | `corrections.log.jsonl` |
| Redirects (single source) | `config/redirects.toml` → generated `public/_redirects` |
| Security headers | `config/headers.toml` → generated `public/_headers` |
| Templates / chrome | `templates/` |
| Design tokens | `assets/css/style.css` (token block at top) |
| Property-preservation app source | `analysis/property-preservation/` (copied to output as-is) |
| Generated output | `public/` (never committed) |

## Publishing an investigation (checklist)

- [ ] `investigation.json` present; required fields filled (id, title, slug, url,
      date_published, status, dek, summary, key_findings, og_image_path, source_count)
- [ ] Report page exists at `content/investigations/<slug>/report.html`
      (or `page_kind: template` with a `content/pages/<slug>.body.html`)
- [ ] OG image file exists under `/assets/img/`
- [ ] Status `published` — **or** leave `draft` and the build will exclude it everywhere
- [ ] Push to a branch, verify preview, merge

The build *cannot* publish a half-configured investigation: a published manifest
missing required fields or assets fails validation, and sitemap/listings/cards are
all generated from the same manifest, so a work is either rendered everywhere or nowhere.

## Corrections

Append one line to `corrections.log.jsonl`:

```
{"id":"C-001","date":"2026-09-02","work":"/investigations/slug/","summary":"...","amended":"..."}
```

Never edit or delete an existing line. The build renders the log onto
`/trust/corrections/` automatically; validation enforces append-only id ordering.
Also set `"has_correction": true` and add a note to the investigation manifest.

## Host redirect (one-time, Cloudflare zone setting)

`insightgaps.com/*` → `https://www.insightgaps.com/*` (301). Canonicals, sitemap,
and robots all use the www host. If the zone rule is missing, add it before launch.

## What must never enter this repository

Private repositories (`Anik_OS`, `assets`, `insightgaps-os-main`), source-identifying
material, any secret or API key. The validator scans for leak patterns and private
repo names on every build.

## Known warnings (reviewed, accepted)

- Five evidence download links (`/data/*.xlsx|.csv|.geojson`) target owner-held files
  not in the repository. Restoring those files (or removing the links) clears them.
- Property-preservation app uses relative links internally (self-contained app, WAIT
  disposition — see `WEBSITE_EXECUTION_COMPLETION_REPORT.md`).

## Frozen until the Phase 3 report audit

Report page presentation (storytelling layout, citation UX, evidence visualization,
methodology UX, tracker UX, chart internals). Infrastructure changes must not
restructure these pages' editorial presentation. See `REPORT_AUDIT_HANDOFF.md`.
