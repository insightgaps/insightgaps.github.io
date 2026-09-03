# Insight Gaps Bureau — Phase 4 QA Report

**Date:** 3 September 2026 · **Scope:** all changes on `phase4-report-execution`; frozen-Phase-2 infrastructure regression checks included.
**Method:** every claim below was produced by an executed check (build, validator, fixture tests, or rendered-browser probes) — none are assertions from source code alone.

---

## 1. Automated gates

| Gate | Result | Detail |
|---|---|---|
| Build | **PASS** | 11 template pages + 7 standalone docs; NewsArticle JSON-LD on 3 injected routes + slum-free set; wayfinding injected on 3 reports |
| Validation (`scripts/validate.py`) | **PASS — 0 errors** | Full gate: metadata/canonical==self (www), absolute og:image, internal links, sitemap⇄routes set-equality, redirect integrity, corrections schema, leak scan, evidence-status consistency, report-integrity (NewsArticle presence, badge/ledger, dead-link disclosure, finding anchors) |
| Warnings | 47 — all triaged | ~30 PP-app relative links (WAIT disposition); 5 owner-held evidence downloads (labeled on-page); PP og:image (WAIT); tracker og:image (owner-gated); remainder recognized-status dataset links |
| Validator fixtures (`tests/test_validate.py`) | **8/8 PASS** | Clean fixture passes; 6 defect classes + orphan-route fail as required |

## 2. Rendered-browser QA (executed, not assumed)

### Wayfinding strip (new)
- Present + visible on all 3 report pages; links: Home / Investigations / [title] + related-work; focusable (3 anchors on blood-routes).
- **Found-and-fixed during QA:** initial `white-space:nowrap` caused 320px overflow on Impunity → replaced with flex-wrap; re-verified clean.

### Mobile matrix (scrollWidth > clientWidth per width)

| Surface | 320 | 375 | 414 | 768–1440 |
|---|---|---|---|---|
| `/` | clean | clean | clean | clean |
| `/investigations/` | clean | clean | clean | clean |
| Blood Routes report | clean | clean | clean | clean |
| Lead Belt report | clean | clean | clean | clean |
| Lead Belt methodology | clean | clean | clean | clean |
| Impunity methodology | clean | clean | clean | clean |
| Impunity detailed | **residual** | clean | clean | clean |
| Impunity tracker | **residual** | **residual** | **residual** | clean |
| Impunity main report | **residual** | clean | clean | clean |

Residual = 20–40px from inline-styled absolute/flex elements in the 118KB frozen report. The safe CSS set (readability floor, sub-nav wrap, canvas scaling, table scroll-block, track containment) eliminated 11→1 culprit on the main report and fixed 4 surfaces outright; further blanket selectors began trading layout regressions for marginal gain — **stopped deliberately and documented as owner-gated D-9ii** (the injected CSS carries the note verbatim).

### Readability floor (audit REP-013)
- Smallest rendered text at 320px: **11px on all three reports** (was 4.4–10.4px). Content untouched.

### Accessibility spot checks
- One H1 per audited page; heading hierarchies present; skip links present on all pages.
- All content images carry alt (blood-routes' 18 alt-less `img` are Leaflet map tiles — correct practice; map containers carry semantics).
- Wayfinding strip: semantic `<nav>` + aria-label; anchors keyboard-focusable.
- Source-profile text renders at 10.5px mono in muted tone — acceptable for secondary metadata (contrast not numerically computed: **not measured**).

## 3. Regression checks (frozen infrastructure)

- Homepage pre-rendered stats/cards unchanged (3 investigations / 120 sources post-D-4) ✓
- Evidence-page status labels intact ✓ · investigations index anchors (12) + evidence panels (4) + profiles (3) ✓
- Slum-fires: zero residue in output (sitemap, data, redirects to `/investigations/` with specific-before-splat ordering) ✓
- Leak scan green; no private material in output ✓
- JSON-LD parses on all pages (validator-enforced) ✓

## 4. Production

**Not deployable from repo alone — blocker is account-level** (Pages dashboard build config override; `PRODUCTION_STATE_AUDIT.md` has the evidence table and the exact one-step fix + post-deploy verification commands). Until applied, the live site serves the repo-root snapshot of 2-Sep (404 on all routes; `scripts/build.py` 200s).

## 5. Not done / classified

- Impunity 91→65 source-count correction: **OWNER DECISION (D-9i)** — only disclosed, not changed.
- Corrections-log entries: **OWNER (D-1/D-6)** — no entries created by any agent.
- Impunity chart data-table fallbacks + full mobile redesign: **OWNER (D-9ii)** — safe subset done, residual documented.
- Lead-belt on-page number contradictions, blood-routes content fixes, PP methodology note: **OWNER (D-2/D-7/D-8)** — untouched.
- Contrast ratios, full keyboard walk, screen-reader pass: **not measured/performed** — only structural spot checks (documented above).
