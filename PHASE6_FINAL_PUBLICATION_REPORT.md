# INSIGHT GAPS — PHASE 6 FINAL PUBLICATION REPORT

**Date:** 4 September 2026 · **Mode:** autonomous 12-hour publication-grade finalization
**Inputs:** `PHASE5_FINAL_EXECUTION_REPORT.md` + the Phase-6 master prompt

---

## 1. Production

**BLOCKED — CLOUDFLARE ACCOUNT CONFIGURATION** (unchanged; re-verified at run start per §3)

Live probe of all 10 required routes: every content route 404; `/robots.txt` returns 200 but serves the **legacy Cloudflare-managed version** (interestingly already blocking AI trainers — consistent with our D-10 policy, but not our file); `site.json` remains the 2-Sep frozen snapshot; all post-2-Sep files 404. The deployment has never built and does not sync pushes. **Owner action unchanged (one dashboard step):** Workers & Pages → `insightgaps` → Settings → Build configuration → command `pip install jinja2 && python scripts/build.py && python scripts/validate.py`, output `public`, branch `main` → Retry deployment. Full evidence in `PRODUCTION_STATE_AUDIT.md`. No success claimed; all repo-side work completed and pushed.

## 2. Git

- **main:** `de45a27` · **origin/main:** synced (verified at every push) · **working tree:** clean
- **Commits this run (all pushed):** `7169742` contrast tokens, `1755eeb` corrections-page restoration + skip-link, `e2c982f` micro-type floor, `c06ef0c` impunity mobile overflow elimination, `dd31d4e` dead CSS + determinism, `a28b2a0` §32 fixtures + validator gap fix, `de45a27` evidence labels.

## 3. Public Route Inventory

Published: **Blood Routes, The Impunity Machine, The Lead Belt** — verified consistent across sitemap (3 works, no slum), homepage (stats now **3 / 94**, the honest post-correction sum), investigations index (3 work sections, 12 finding anchors, 4 evidence panels, 3 source profiles), JSON-LD graph (18 pages, zero slum references), redirects (4 slum routes → `/investigations/`), generated data. **Zero slum-fires references anywhere in output.** Unpublished: Dhaka Slum Fires (D-4) — absent from every surface, redirects retained.

## 4. Report Quality

**Blood Routes** — 19.08% fix live; 351 headline properly qualified (Option B basis note on the index); C-001/C-002 rendered with correction dot; methodology link (geo-verification report) resolving. **Impunity Machine** — 65 sources on every surface with 54/11 tier split; S-26 remapped to S-37; historical changelog preserved; **mobile overflow eliminated at 375/414/768 (was all ≤414)**; C-003/C-004 live. **Lead Belt** — all reconciled semantics verified (26/19 satellite, 68/65 critical, 93 upazila, ×275 models both summing 39,875, projection language with unique-count and range, scoped 59 m, provenance note, 2026-05-25 dates in JSON-LD); C-005 live. **Property Preservation** — ANALYTICAL TOOL badge, 480-record methodology, dates aligned to the dataset generation.

## 5. Visualization

No visualizations replaced (none met the replacement bar). Mobile behavior of the Impunity canvases, tracker stat rail, surge grid, and source-list repaired via scoped clamps; desktop geometry verified unchanged at 1440 (3 canvases at original 500/580/620px widths, 8 tables intact).

## 6. Evidence

Public + verified 200 with valid content: `osm_schools.geojson` (9,846 features, ODbL attribution), `BD-INV-002` digest (65-entry registry, no case rows), cases/leads/monthly/blood-routes/geojson data files. Private-held (labeled): master evidence workbook. Not-in-repository (labeled): Lead Belt v5, PP dataset. **Every referenced-but-unavailable download on the evidence page now carries an honest status badge** — zero unlabeled dead links. Unarchived: Impunity EV-001…005 (marked in the OS registry).

## 7. Corrections

C-001…C-005 all render in the corrections table (5 rows); the corrections page structure was **restored** after discovery that yesterday's template cleanup had removed its H1, intro, and doctrine text; append-only + ID-monotonicity now enforced by the validator with a fixture.

## 8. Accessibility (measured, not assumed)

- **Contrast (§17):** 27/27 checks pass across 10 standard surfaces after darkening 3 tokens (accent 3.11→4.67:1; muted 2.64→4.94:1; hover→5.26:1) — identity preserved (same hue family).
- **Keyboard/landmarks (§16):** skip link moved to first-focusable position on every page; one H1 per page (corrections H1 restored); header/main/footer landmarks verified; focus styles present.
- **Micro-type (§18):** reader-facing disclosures raised to ≥11px; intentional compact badges classified and preserved; 11px floor active on frozen report pages ≤768px.
- **Not measured:** full screen-reader pass, WCAG formal conformance claim.

## 9. SEO

Titles/descriptions/canonical/OG verified on all report routes; NewsArticle JSON-LD **19/19 blocks parse with zero errors and complete required fields**; lead-belt JSON-LD datePublished now 2026-05-25; robots.txt regenerated with content-signals + 7 training-bot blocks; sitemap = publication state exactly.

## 10. Performance

Dead 16K `investigation.css` removed (unreferenced by any template/content/page); **build determinism verified — two consecutive builds byte-identical (84 files, all MD5s match)**; payload audit recorded (HTML 20K home / 160K reports by design; infographic PNGs 2.5-2.7MB are og/card images, preserved per §22).

## 11. Validator + Tests

- **New §32 fixtures (all fail correctly):** unpublished-investigation-in-sitemap; unlabeled-dead-evidence-link; duplicate correction IDs — **fixture 6 exposed a real validator gap** (evidence-page dead downloads were downgraded to warnings before the evidence check could fire, and that check was fixture-scoped). Fixed: evidence check now always-on and fail-closed on unlabeled dead downloads; honest labels pass.
- **Fixture count: 9/9 PASS.** Build PASS · Validation PASS **0 errors / 43 warnings** (PP-app internals + PP og:image, all WAIT-gated and triaged).

## 12. QA Summary

- Full-site crawl: **659 internal refs across 33 pages — 0 true broken links** (17 flagged paths are all known owner-held datasets, each now labeled)
- Evidence downloads: all 7 public files 200 + content-validated
- JSON-LD: 19/19 valid, dates accurate, no unpublished material anywhere
- Mobile: 11 routes × 7 widths — all clean except Impunity residual at **320px only** (~40px, sub-nav/canvas edges), deliberately left per §15
- Security sweep (§38): **0 hits** — no keys, tokens, passwords, private paths, or private identifiers in output

## 13. Remaining Limitations (genuine only)

1. **Production deployment** — the single Cloudflare dashboard step (blocks only the public URL).
2. **Impunity 320px residual** (~40px) — full fix is the owner-gated responsive redesign; a broken chart would be worse.
3. **Blood Routes 351** — qualified (Option B); needs the RSF/BJKS reports archived to upgrade.
4. **Lead Belt v5 dataset** — unlocated in all authorized repos (labeled honestly).
6. **Impunity master workbook** — full publication pending source-protection review (public digest available).
7. Screen-reader/WCAG-formal conformance: not measured.

## 14. Final Classification

**READY WITH DOCUMENTED LIMITATIONS** — publication-grade on the repository side: measured accessibility, honest evidence labeling end-to-end, clean mobile at every practical width, deterministic build, 9/9 regression fixtures, zero security findings, and every remaining limitation explicitly documented with its owner action.
