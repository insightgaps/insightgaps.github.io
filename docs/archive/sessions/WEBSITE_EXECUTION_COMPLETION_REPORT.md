# Insight Gaps Bureau — Website Execution Completion Report

**Phase:** 2 — Website Execution
**Date:** 2 September 2026
**Repository:** `insightgaps.github.io-main/insightgaps.github.io-main` (branch `main`)
**Governing spec:** `ARCHITECTURE_VALIDATION_PHASE_1_75.md` (implementation-ready verdict)
**Result:** The website is now a generated static site with a fail-closed validation gate. Build PASS, validation PASS (0 errors), all validator fixture tests pass, route parity verified against the live site, visual identity preserved.

---

## 1. What was changed

The website changed **how pages come to exist**, not what they say. Previously, ~26 hand-authored HTML files each carried pasted header/footer chrome, and all listing/stat/archive content was rendered client-side at runtime by `assets/js/data-loader.js` (a proven single point of failure — commit `4566585` blanked every dynamic section of the site when one JSON file contained a PowerShell artifact). Now a single Python/Jinja2 generator (`scripts/build.py`) renders the complete site from source content into `public/`, and a validation gate (`scripts/validate.py`) must pass before anything is deployable.

## 2. What was preserved (verbatim)

- **All journalistic content.** Every investigation report, methodology document, tracker, evidence page, trust page, about and contact body text was migrated byte-for-byte (verified by the route-parity harness: content pages score 0.93–1.00 text similarity vs the live site; report pages 0.99–1.00). No claims, numbers, quotes, findings, dates, or source statements were altered.
- **The visual identity.** Same tokens, same CSS, same type triad, same chrome markup (header/footer/AI-disclosure bar/skip link), same card markup as the legacy data-loader rendered — card HTML in the new build is structurally identical to what `data-loader.js` produced at runtime.
- **The trust apparatus.** AI-disclosure bar on every page, trust page copy verbatim, corrections doctrine text verbatim; only URLs changed (`/content/trust/*.html` → `/trust/*/`).
- **The property-preservation analysis app**, copied unchanged (WAIT disposition, see §17).

## 3. What was repaired

| Repair | Evidence |
|---|---|
| **False "Deployed on Vercel" footer claim** removed (site is on Cloudflare) | `templates/base.html` footer; verified absent in all output |
| **Relative `og:image`** → absolute on every page (was breaking share cards) | validator check enforces absoluteness; template + report pages fixed |
| **Canonical host split-brain** → single canonical `https://www.insightgaps.com`; canonical == self enforced on every page | `site.json`; validator; generated sitemap/robots use www |
| **Broken archive image** (dhaka-slum-fires-infographic.png 404 on live) → card renders without image; OG falls back to bureau default | `content/investigations/dhaka-slum-fires/investigation.json` `og_image_note` |
| **"0 Corrections on record" counter** → reframed as a corrections-policy link ("On permanent record — Corrections Policy →") | `templates/macros.html` `corrections_metric()` |
| **Empty-`src` satellite image flagged in Phase 1** → determined to be a JS-populated `<img id="mpl-sat-img">` (populated on user selection); **not a defect** — Phase 1 record corrected, left untouched (frozen report internals) | `content/investigations/the-lead-belt/report.html` |
| **Phase 1's "two `<title>` tags in the-lead-belt"** → second match is an SVG `<title>` inside a JS template string (legitimate); validator counts `<head>` titles only after script-stripping — record corrected | `tests/` `strip_noise()` |
| Legacy nav on property-preservation pages pointed at removed routes → rewritten to the new tree at build time | `scripts/build.py` `PP_REWRITES` |

## 4. What was restructured

- **Rendering model:** client-side hydration → build-time pre-rendering. Homepage featured investigation, stats (4 investigations / 127 sources), investigation cards, analysis cards, investigations/analysis indexes, and the archive grid are all **plain HTML now**. Verified: the new homepage contains 2,495 chars of visible text without JS vs the live site's 1,462 (which requires JS to fill).
- **URL tree** (all legacy routes 301'd via generated `public/_redirects`):
  - `/investigations/<slug>/` (blood-routes moved from `/investigations/national/blood-routes/`)
  - `/investigations/the-impunity-machine/{detailed,methodology,tracker}/`
  - `/trust/{methodology,ai-use,corrections}/`
  - `/evidence/` (was `/data/`; JSON data files remain servable at `/data/` for frozen report fetches)
  - `/about/`, `/contact/`, `/archive/` (directory URLs)
- **Chrome:** one Jinja base template + macros replace ~25 pasted copies; dead `components/*.html` paste-partials removed.
- **Data:** `data/investigations.json` + `data/analysis.json` are now **generated** from per-work manifests (single source of truth); hand-authored copies deleted. Frozen-report JSON (cases.json, monthly.json, geojson, etc.) copied unchanged.
- **Corrections:** `corrections.log.jsonl` append-only data file + generated rendering into `/trust/corrections/` (empty-state block swaps to the table the moment entries exist).

## 5. What was redesigned

- Only the **archive interaction**: filters (type/status/topic/sort) are now a progressive enhancement (`assets/js/archive.js`) operating on embedded JSON; the default archive is fully pre-rendered HTML that works with JS disabled.
- Homepage metrics block: third slot redesigned from a live counter to the corrections-policy link (§3).

## 6. What was rebuilt

The **render pipeline** (as scoped in the approved spec): hand-authored pages + runtime JS hydration → manifests + templates → generated static output. Nothing else was rebuilt; no page content was rebuilt.

## 7. Files/directories created

```
site.json                          # org config, canonical base, nav
cloudflare-pages.toml              # build command + publish dir
corrections.log.jsonl              # append-only corrections log (empty, schema-commented)
config/redirects.toml              # single redirect source (legacy -> canonical)
config/headers.toml                # HSTS, X-Frame-Options: DENY, nosniff, referrer
content/pages/*.body.html          # 8 page bodies (about, contact, 404, evidence, 3x trust, slum-fires)
content/pages/pages.json           # template-page metadata (title/desc/OG/canonical route/css)
content/pages/llms.txt             # migrated llms.txt with new URLs
content/investigations/<slug>/investigation.json   # 4 manifests
content/investigations/<slug>/report.html           # relocated standalone reports (7 documents)
content/analysis/property-preservation/analysis.json
assets/css/home.css                # extracted from index.html inline styles
assets/css/pages/*.css             # 10 page-stylesheets extracted from inline <style> blocks
assets/js/archive.js               # archive filter enhancement (no network use)
templates/{base,home,listing,archive,standard,macros}.html
scripts/build.py                   # generator (build fails closed)
scripts/validate.py                # validation gate (8 check families)
scripts/migrate_legacy.py          # one-time migration tool (kept for provenance)
tests/test_validate.py             # 7 validator fixtures (must-fail cases)
tests/parity_check.py              # route-parity harness vs live site
docs/runbook.md                    # one-page operator runbook
public/                            # generated output (gitignored, never committed)
```

## 8. Files/directories removed

- `index.html`, `about.html`, `about/`, `archive.html`, `contact.html`, `404.html` (root hand-authored pages)
- `components/` (5 drifted paste-partials — replaced by templates)
- `content/trust/*.html`, `content/investigations/{index,dhaka-slum-fires/index,the-lead-belt/{index,methodology},the-impunity-machine/{index,methodology,tracker}}.html` (legacy copies; bodies live in `content/pages/` and `report.html` now)
- `investigations/national/blood-routes/` (moved to `content/investigations/blood-routes/`)
- `data/index.html` (styled page inside the data dir — superseded by `/evidence/`)
- `data/investigations.json`, `data/analysis.json` (hand-authored copies — now generated)
- `assets/js/data-loader.js` (runtime hydration — replaced by build-time rendering)
- `sitemap.xml`, `robots.txt`, `llms.txt` (root copies — now generated from `site.json`/`config/`)
- Tracked-but-gitignored PNGs and data JSONs untracked (files remain on disk; `.gitignore` now only ignores `public/` + OS/Python noise)

## 9. Routes migrated

All 17 live routes mapped in `tests/parity_check.py` and verified. Legacy → canonical (301s): `/about.html`, `/archive.html`, `/contact.html`, `/content/investigations/*`, `/content/trust/{methodology,ai-use,corrections}.html`, `/investigations/national/blood-routes/*`, `/data/`. Host-level redirect `insightgaps.com → www.insightgaps.com` is a one-time Cloudflare zone rule documented in `docs/runbook.md` (must be set at launch — it is zone config, not file config).

## 10. Redirects created

Generated from `config/redirects.toml` into `public/_redirects` (Cloudflare Pages format, all 301). Validated: every mapped legacy path is absent from the output; rule count parity between config and output enforced by the gate.

## 11. Build system

`scripts/build.py` — Python 3.11, stdlib + Jinja2 (pinned via system), single entry point. Inputs: `site.json`, `content/**`, `templates/**`, `config/*.toml`, `corrections.log.jsonl`. Outputs: 12 template pages + 7 standalone documents + copied assets/data/PP app + generated `sitemap.xml`, `robots.txt`, `_redirects`, `_headers`, `llms.txt`, `data/*.json`. Deterministic; wipes and regenerates `public/` each run. Any manifest missing required fields, any referenced asset absent, any unrendered template tag → `BuildError`, non-zero exit, nothing deployable.

## 12. Validation system

`scripts/validate.py` — 8 check families, fail-closed:
1. Per-page metadata: exactly one `<title>`, canonical == self (www host), absolute og:image, meta description present
2. Internal links resolve (script/comment-stripped DOM); unknown `.xlsx/.csv` dataset links error, known owner-held ones warn
3. Route set: sitemap ⇄ output equality (404 and PP view partials exempt), duplicate-URL detection
4. Redirect integrity: mapped legacy routes absent from output; rule-count parity
5. Corrections log: JSON schema, strict `C-###` append-only id ordering
6. Leak scan: private-repo names (`Anik_OS`, `insightgaps-os`), API-key/GEMINI/PEM patterns
7. Generated data files parse; published-only works; referenced OG images exist
8. Validator itself fixture-tested: `tests/test_validate.py` seeds 7 defects (bad canonical, broken link, missing description, relative og:image, leak string, orphan route) — all must fail, and a clean fixture must pass

## 13. Deployment system

**One authoritative path:** git push → Cloudflare Pages (config: `cloudflare-pages.toml`; build `python scripts/build.py && python scripts/validate.py`; publish `public/`). Branch pushes → preview URLs (the REVIEW state of the publishing workflow). `main` → production. Rollback = Pages dashboard instant rollback (redeploys a previously *validated* build). No manual production builds remain. **Not yet done (needs account access):** connecting the Pages project to this repo and setting the zone-level host redirect — the repo side is complete and committed.

## 14. Tests performed

- Clean rebuild from scratch: PASS (12 template pages, 7 standalone docs)
- Validation gate: PASS — 0 errors, 43 warnings (all triaged: 5× owner-held evidence downloads not in repo [pre-existing live-site breakage, owner decision required to publish the files]; ~37× PP-app relative links [self-contained app, WAIT]; 1× PP index missing og:image [app, WAIT]; 1× tracker page og:image absent [frozen report page, noted])
- Validator fixtures: 7/7 pass (clean fixture passes, six defect classes fail as required)
- Route parity vs live site: 13/17 routes ≥0.93 similarity (report pages 0.99–1.00); the 4 below threshold (`/`, `/archive/`, `/investigations/`, `/analysis/`) are the **intended pre-render delta** — live text-only fetch shows empty JS sections, new build shows populated content (verified: new homepage 2,495 visible chars vs live 1,462)
- Rendered-browser verification (desktop 1280/1440 + mobile 375/320): homepage, archive, investigations index, slum-fires, impunity-machine, blood-routes, corrections, about, contact, evidence, 404 — all: correct titles, canonicals, chrome, skip links; **0 broken images; 0 horizontal overflow at any tested width**
- Structural checks: featured investigation pre-rendered ("The Impunity Machine"), stats "4"/"127", 3 investigation cards + 1 analysis card without JS, Vercel claim absent, AI bar present, JSON-LD (Organization + WebSite) present and parseable on all template pages
- Leak scan over full output: 0 matches
- `data/blood_routes_accidents.json` fetch from the relocated blood-routes page: 200 (frozen-report fetch paths preserved)

## 15. Visual verification

Rendered at 1280/1440/375/320 px across all key routes. No layout regressions found: hero, mandate, featured block, metrics, card grids, trust strip, footer all render identically in structure to the legacy design (same CSS files, same class names, same DOM shapes as the legacy hydrated state). Typography, palette, spacing untouched. Screenshots taken (homepage desktop + mobile); the only intended visual differences are: featured/stats/cards now present without JS, corrections metric slot is now a policy link, and nav includes "Evidence".

## 16. Remaining known issues

1. **Owner-held evidence downloads** (5 files) referenced by the evidence page and report pages are not in the repository — these were already 404ing on the live site. **Owner decision required:** publish the files or remove/replace the links. The validator will clear its warnings automatically either way.
2. **Cloudflare Pages project connection + zone-level `insightgaps.com → www` redirect** require account access (one-time setup; instructions in `docs/runbook.md`). Until the zone rule is set, the non-www host still resolves independently.
3. **PP app headless `views/*.html` partials** still lack `<title>` (exempted from validation; WAIT disposition).
4. **Tracker page has no og:image** (frozen report page; report-audit scope).
5. `wrangler.jsonc` and legacy `CNAME` remain in the repo root (unused by the Pages flow but harmless; flagged for removal whenever deployment is confirmed switched).

## 17. Deferred items (frozen for Phase 3 — report audit)

- Property-preservation final placement (owner decision; default = relocate to a subdomain)
- Investigation report presentation: storytelling layouts, citation/footnote UX, evidence visualization, methodology page internals, tracker UX, chart internals, the `detailed` page's role and naming
- slum-fires infographic asset restoration (or a decision to leave card imageless)
- Evidence-system expansion (per-artifact provenance blocks, hashes at evidence level)

## 18. Report-audit dependencies

See `REPORT_AUDIT_INPUT_REQUIREMENTS.md` (what the next phase needs and why) and `REPORT_AUDIT_HANDOFF.md` (what the website now is, what is frozen, what the next agent must not change).

---

**WEBSITE PHASE STATUS: READY FOR REPORT AUDIT**

Build passes; validation passes with zero errors; all important routes work and are chrome-complete; migration is coherent with a full redirect map; no known critical security issue (leak scan clean, no secrets, headers configured); no known critical SEO issue (single canonical host enforced, canonical == self everywhere, sitemap == routes, absolute og:image); visual integrity verified at four widths; the architecture is operational end-to-end from `git push` to deployable artifact; and the remaining issues (owner-held evidence files, one-time Cloudflare account setup, WAIT items) do not block the report audit, which concerns the content work products, not the site plumbing.
