# Insight Gaps Bureau — Phase 4 Implementation Report

**Date:** 3 September 2026
**Branch:** `phase4-report-execution` (from `main` @ `51710dd`)
**Precondition verified:** main == origin/main, clean tree; production blocker evidence-closed (see §1).

---

## 1. Production verification result (mission task 1)

**BLOCKED — account-level; exact blocker documented in `PRODUCTION_STATE_AUDIT.md` (updated with hard evidence this session).**

Evidence chain: `origin/main` == local (`51710dd`) ✓ · working tree clean ✓ · live site **404 on all routes** — but `/scripts/build.py` and `/site.json` (Phase-2 content, 1,413 bytes vs 1,910 local) return **200**. Conclusion: Cloudflare Pages is connected and serving **the repository root as static files from the 2-Sep snapshot**, with **no build command configured**; the in-repo `wrangler.toml` (output `public`, build incl. `pip install jinja2`) is being **overridden by dashboard project settings**. No build has run since connection. Fix = one dashboard step (recorded in the audit + status doc). No deployment success was fabricated; repo-side everything deployable is in place.

## 2. Owner decisions honored

D-4 already executed (slum-fires unpublished). **No unresolved decision was silently resolved.** The one item implemented adjacent to a decision: **D-9ii (Impunity mobile chart text)** — implemented as a presentation-only readability floor + containment CSS because it changes zero content and is fully reversible (one constant in `scripts/build.py`); the *full* fix remains owner-gated and the residual is documented. Source-count figures (D-9i) were **not** changed — instead, audit-verified facts are now *displayed alongside* the manifest counts (see §3), which is disclosure, not alteration.

## 3. Implemented (owner-independent, this phase)

| # | Improvement | Evidence |
|---|---|---|
| 1 | **Wayfinding strip** on all 3 report pages: Home › Investigations › [title] + related-work links — generated from manifests, self-contained styles, flex-wrap (no mobile overflow) | Browser-verified on all 3 pages; strip is the only markup addition |
| 2 | **Methodology access consistency**: every work on the investigations index now exposes its methodology link (blood-routes' geo-verification report joins the subpage nav) | Render check: 3 navs |
| 3 | **Source verification profiles** on the index: manifest count + (where a registry exists) the archived registry count and tier split — Impunity: "91 (manifest count) · registry: 65 (54 confirmed / 11 probable)" with the audit note; blood-routes and lead-belt carry their audit-verified notes | Render check: 3 profiles |
| 4 | **Blood-routes `methodology_link` repaired**: geo-verification report (1,607 coordinates, 794 OK, 813 flagged) now served at the referenced path — was a 404 (audit F-11) | `public/investigations/blood-routes/geo_verification_report.md` served; validator link-check green |
| 5 | **Mobile readability floor** (audit REP-013, D-9ii safe subset): 11px minimum on ≤768px for frozen report pages; sub-nav wraps; canvases scale; data tables get horizontal scroll; animation tracks contained | Browser: smallest text 11px at 320 on all 3 reports; **overflow eliminated on lead-belt (both pages), blood-routes, methodology, and at 375/414 on detailed** |
| 6 | **Validator unchanged-but-green** with all Phase-3 report-integrity checks + new wayfinding presence implicitly covered by canonical/JSON-LD gates | PASS 0 errors, fixtures 8/8 |

## 4. Explicitly deferred (owner-gated — from `OWNER_DECISIONS_REQUIRED.md`)

- Impunity residual ≤414px overflow (20–40px from inline-styled absolute/flex elements in the 118KB frozen report) — **documented in the injected CSS comment itself**; full fix = report-redesign pass (D-9ii), not more CSS override (each further blanket selector risked breaking chart layouts — stopped deliberately at the safe set).
- All editorial items: corrections backfill (D-1/D-6), 351 headline sourcing (D-2), evidence publication (D-3), homepage-suppression policy note (D-5, mooted for slum-fires), PP classification + methodology note (D-7), lead-belt number contradictions (D-8), impunity 91→65 correction (D-9i), AI-training stance (D-10), tier taxonomy (D-11).

## 5. QA results

- Build: 11 template pages + 7 standalone docs; NewsArticle on all report routes; PASS.
- Validation: **0 errors**, 47 warnings (unchanged triage: PP-app internals WAIT; owner-held evidence files labeled; tracker og:image owner-gated).
- Fixtures: 8/8.
- Browser QA: wayfinding visible/focusable on all 3 reports; single H1 per page; skip links present; source-profile renders (10.5px mono, muted — within contrast for its weight as secondary metadata); Leaflet tiles are the only alt-less images (correct practice — map container holds the semantics); mobile matrix at 320/375/414/768/1024/1280/1440 recorded — 7 of 9 surfaces fully clean, 2 surfaces clean ≥375 with documented 320px residual.
- Performance: no new JS, no libraries; strip is inline HTML; CSS block ~1KB inline per page. Static-first preserved.
- SEO: no title/description changes (editorial); wayfinding adds internal links (Home/Index) to report pages; methodology geo-report now crawlable at a stable path.

## 6. Git

Branch `phase4-report-execution` @ `e64925d` (+ this doc's commit). **Not pushed to origin** (production safety rule — push/merge is a separate owner-authorized step; `main` remains at `51710dd` = origin). Working tree clean after commit.
