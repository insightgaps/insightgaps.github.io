# Insight Gaps Bureau — Phase 3 Report Implementation Completion

**Branch:** `phase3-report-improvement` (5 commits ahead of pushed `main` at time of writing; **not pushed** — production deployment is owner-authorized only)
**Build:** PASS · **Validation:** PASS, 0 errors, 47 warnings (all triaged below) · **Validator fixtures:** 8/8 pass
**Content rule honored:** no claim, number, quote, date, methodology statement, or tier was altered anywhere. Everything implemented is presentation of bureau-authored data or restoration of the bureau's own previously-shipped artifacts.

---

## 1. What was implemented (with evidence of each)

| # | Improvement | Files | Verified by |
|---|---|---|---|
| 1 | **Slum-fires claim verification drawer restored** (was silently dropped in the Phase-2 rebuild — audit REP-007): markup, CSS, and the 13-claim ledger JS from the 2026-06-03 build (`9e73d50`), plus one honesty repair — the hardcoded "Confirmed" badge is now a **per-claim status** from data (e.g., "SOURCED — ARTIFACT NOT ARCHIVED", "IN PUBLISHED DATASET") | `content/pages/slum-fires.body.html` (restoration script `scripts/restore_slumfires_drawer.py`) | Browser test: badge click → drawer opens → CLM-SFI-001 + status renders; 37 badges, all 13 IDs in ledger |
| 2 | **Limitations section surfaced** on slum-fires — verbatim the bureau's own draft text (OS repo `04-report-draft.md`), clearly labeled "from the investigation file" | `content/pages/slum-fires.body.html` | `#limitations-surfaced` present in render |
| 3 | **Evidence-page status honesty**: all 5 unavailable downloads labeled (`HELD BY BUREAU — NOT YET PUBLIC` / `FILE NOT IN REPOSITORY`) with explanatory notes; the three "Active — Fully Verified" package headers corrected to "public availability varies (see file statuses)" | `content/pages/evidence.body.html` | Render check: 5 badges, zero "Fully Verified" |
| 4 | **Per-work evidence_refs** in all four manifests with statuses (`available` / `private-held` / `not-in-repository`) + notes; lead-belt manifest gains its `subpages` map | `content/investigations/*/investigation.json` | Render check: 13 status badges across 4 panels |
| 5 | **Investigations index rebuilt**: per-work sections with title/dek, subpage navigation (methodology/tracker/detailed links), key findings with stable **`#finding-N` deep-link anchors**, evidence-status panels | `templates/macros.html` (`index_work`), `scripts/build.py`, `assets/css/pages/listing.css` | 4 works, 12 anchors, 2 subpage navs, 4 evidence panels; no overflow 375px |
| 6 | **NewsArticle JSON-LD** generated from manifests on all 4 investigation report routes + 3 subpages (tracker, 2× methodology) — headline, dates, Organization author/publisher, image; legacy JSON-LD left untouched; never duplicated | `scripts/build.py` (`article_jsonld` + post-emit injection) | Build log: 3 injected + slum-fires via template; validator enforces presence on 8 report routes |
| 7 | **Homepage stats basis notes** rendered from `site.json` — including the first published **source-count definition** (a "source" = distinct external document/institution/dataset named in an investigation's source log) | `site.json`, `templates/home.html`, `assets/css/home.css` | Render check: both notes present under 4 / 127 |
| 8 | **Validator report-integrity checks** (fail-closed, added to the Phase-2 gate): NewsArticle presence on report routes; evidence_refs status validity + availability-consistency (an `available` ref pointing at a missing file is an ERROR); slum-fires badge↔ledger integrity (badges without ledger entries fail); evidence-page dead links must be status-disclosed; investigations index must carry finding anchors | `scripts/validate.py` | Fixture tests extended; gate PASS on real site; fixture-scope skip for minimal trees |
| 9 | **Escaping bug found and fixed during visual verification**: the index work-sections initially shipped HTML-escaped (Jinja `Markup` + f-string concatenation) — caught by the render-inspect-fix loop, fixed via a proper macro (`index_work`), re-verified | `templates/macros.html`, `scripts/build.py` | Post-fix render: 4 sections unescaped, anchors/nav/panels functional |

## 2. What was deliberately NOT implemented (owner-gated — see `OWNER_DECISIONS_REQUIRED.md`)

Every change that would alter displayed content or claims: corrections-log entries (incl. the blood-routes 97.13% silent correction and impunity disclosures — D-1/D-6); headline/hero reframings (Lead Belt bounds, blood-routes external-basis labels text — needs bureau data); source-count corrections (91→65 for impunity — D-9); tier-label alignment (D-11); evidence file publication (D-3); PP methodology-note fix (D-7); slum-fires annotation decisions (D-4); homepage suppression policy (D-5); the five on-page number contradictions in Lead Belt (displayed values — D-8); mobile chart-text repair of the Impunity canvas panels (visual identity of published pages — D-9ii).

## 3. Validation warnings (47) — triage

- ~30 × PP-app relative links (self-contained app; WAIT disposition — unchanged)
- 5 × owner-held evidence downloads not in repo (now labeled honestly on the evidence page; resolution is D-3)
- 1 × PP index og:image absent (app page; WAIT)
- 1 × tracker og:image absent (frozen report page; owner-gated)
- Remainder: dataset-download links whose status labels the validator recognizes (by design — they warn until files ship or are de-linked)

## 4. Test evidence

- `python scripts/build.py` → 12 template pages, 7 standalone documents, 3+1 NewsArticle injections
- `python scripts/validate.py` → PASS, 0 errors (full route/metadata/link/leak/report-integrity gate)
- `python tests/test_validate.py` → 8/8 (clean fixture passes; bad-canonical, broken-link, missing-description, relative-og, leak, orphan-route fixtures fail as required)
- Browser verification (rendered, not source-only): drawer interaction end-to-end; evidence badges; anchors; subpage navs; stats notes; no horizontal overflow at 1280px or 375px on new/changed pages; JSON-LD parses (validator) and is present on all 8 report routes

## 5. Commits on this branch (chronological)

1. `1fbbc2f` — forensic audit document + visual research notes
2. `8c993e7` — blood-routes findings incorporated; architecture/visualization/SEO docs
3. `9048168` — lead-belt findings + scorecard + owner-decisions doc
4. `b7f5a9b` — implementation of presentation-only improvements
5. `b3a7e53` — escaping fix + impunity findings incorporated

## 6. Resulting system state

The report system now has, end-to-end: manifests as the single source (with evidence-status data); build-time rendering of every verification affordance; a validation gate that enforces report integrity (not just site integrity); honest evidence labeling where artifacts are unavailable; stable finding anchors for deep-linking and AI answers; NewsArticle structured data on every report surface; the slum-fires verification desk functional again with truthful per-claim statuses; and the bureau's own limitations text surfaced. **Nothing published was weakened, strengthened, or reworded.**

Remaining known issues are exclusively the owner-decision list — the system can enforce honesty going forward, but only the editor can supply the missing artifacts, corrections entries, and claim-level decisions.
