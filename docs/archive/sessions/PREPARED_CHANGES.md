# Insight Gaps Bureau — Prepared Changes (Phase 5B)

**Purpose:** every owner-gated change, prepared to the exact string/field level, ready to execute on approval. Nothing here is implemented. Approve per line-item (or per section) and the change ships through build → validate → QA → commit → push.
**Mechanical work executed this phase** (safe, non-editorial): dead slum-fires code removed from `build.py` (one-off og_image carve-out deleted — manifests now validated uniformly); slum-fires-specific validator check generalized to a route-agnostic claim-badge/ledger integrity check; D-5 re-verified (no slug filters anywhere, no output residue, redirects retained). Gate re-run green after each.

---

## D-1 — Blood Routes correction record (ready to append on approval)

```json
{"id":"C-001","date":"2026-06-08","work":"/investigations/blood-routes/","summary":"The report's night-time crash statistic was published as 97.13% (derived from a dataset later found to contain ~95% synthetic padding); it was corrected to 41.56% (RSF Dhaka Annual Report 2025 basis) on 2026-06-08, after the pipeline retracted the original figure on 2026-06-03. The change was made in commit 527d0a4 without a log entry at the time.","amended":"Night-time share of fatal Dhaka crashes corrected 97.13% → 41.56% (10pm–6am window). has_correction set to true; date_revised set to 2026-06-08."}
```
Also on approval: `investigation.json` → `"has_correction": true`, `"date_revised": "2026-06-08"`.
Affects: corrections page (auto-renders), homepage corrections notice slot (auto), manifest.

## D-2 — Blood Routes: 29% YoY fix (1 location) + 351 qualification

**Verified against the report's own embedded timeline:** 2024-Adha = **262 deaths** (BJKS), 2025-Adha = **312 deaths** → **19.08%**, not 29%.

| Location | Current text | Proposed replacement |
|---|---|---|
| `report.html` line ~2279, timeline data `{ year: 2025, ... }` desc | `"Devastating 29% YoY surge in road fatalities over a 12-day window."` | `"Sharp 19% year-on-year rise in road fatalities over a 12-day window (312 vs 262 in 2024)."` |

351 qualification (Option B, if reports not held): add to the hero's source basis — proposed note text: `"Eid 2026 figures as reported by Road Safety Foundation and Bangladesh Jatri Kalyan Samity; the underlying reports are not yet archived in the bureau's evidence repository."` Manifest dek/key_findings touchpoints listed; exact replacement strings prepared on request of option choice (A/B/C per packet).
Correction-log entry required for the 29%→19.08% change: prepared as C-002 pending D-1 numbering.

## D-3 — Evidence artifacts (status table; publication actions ready)

| Artifact | Exists | Location | Checksum | Recommendation | Ready action |
|---|---|---|---|---|---|
| BD-INV-002 master xlsx | yes (private) | OS `topic-pipeline/the-impunity-machine/data/raw/` | SHA-256 `811c104d…` (manifest-matched) | Publish **digest only** after source-protection review | Digest generator prepared as a proposal (summary sheets: SOURCE_REGISTRY 65 rows, AGGREGATE_STATISTICS counts — no case rows) |
| osm_schools.geojson | yes (private) | OS `datasets/lead-belt/` (9,846 nodes; ODbL-attributable OSM extract) | n/a | **Publish** (public snapshot; zero source risk) | Copy → website `data/`; evidence label auto-flips to available; validator warning clears |
| Lead Belt v5 csv/xlsx | **not found in any authorized repo** (searched all three incl. archives) | — | — | Keep honest "not-in-repository" label; owner to locate | None (cannot fabricate) |
| PP master dataset | not found | — | — | Keep "not-in-repository" | None |
| Impunity EV-001…005 | **registry paths broken** (point to nonexistent `assets/BD-INV-002/`); no source documents in any authorized repo | — | checksums recorded in registry, unverifiable | Owner: re-archive the named documents (MoWCA OCC reports, PHQ stats, NFDPL review, BLAST study, BRAC study) or mark registry entries unarchived | Registry annotation text prepared |

## D-6 — Corrections backfill queue (exact wording per entry prepared; appended on approval)

1. C-001 (D-1, above).
2. C-002 (D-2's 29% fix).
3. Impunity cross-country denominator disclosure — proposed: `"date":"2026-05-26","work":"/investigations/the-impunity-machine/","summary":"A note disclosing that the Bangladesh 0.46% conviction rate and the UK/India/South Africa comparator rates use different denominators (all-complaints vs prosecuted-trials) was added to the comparison section after initial publication (commit 36177f6).","amended":"Comparison chart now carries the cross-jurisdictional denominator note."`
4. Impunity hero rewording (c8532e7→ee84986) — owner judgment; proposed clarification text prepared, not drafted into the log.
5. Lead Belt language hardening — **no entry** (pre-publication in practice).
6. Slum Fires — **no entry** (unpublished).

## D-7 — Property Preservation methodology note (proposed replacement text)

Current (false): "Analysis is based on 268 work order records spanning May to December 2025…" (×4 occurrences: 3 in `analysis.json` methodology_note fields, 1 in sheet.html "268 work order records").
Proposed: `"Analysis is based on a 480-record work order dataset covering November 2025 – June 2026. Records were compiled into the bureau's EPCS working dataset for analysis; figures reflect that dataset as generated on 2026-06-07."`
Classification (journalism / tool / product): owner-gated; note fix is valid under all three.
Correction-log: required **only if** classified as journalism (then C-003).

## D-8 — Lead Belt figure matrix (all values extracted from the embedded 294-site dataset)

| Claim | Published | Data value | Source | Recommended | Correction? |
|---|---|---|---|---|---|
| "Satellite Active 26" filter chip | 26 | `sat:true` = **19**; `sta:"confirmed"` = 26 | embedded dataset | Chip counts High-Confidence only → relabel to "Satellite confirmed: 26 (high-confidence: 19)" or set chip = 19 | yes (published count change) |
| "Critical areas >100k: 68" chip | 68 | `p>100000` = **65**; `v:critical` = 68 (3 sites at exactly 100,000: BD-8094, BD-7354, BD-7355) | embedded dataset | Relabel "Critical: 68 (65 exceed 100k ppm)" or change threshold wording | yes |
| "507 upazila boundaries" | 507 | embedded GeoJSON has **93** upazila polygons | page payload | Correct to 93 (or the sentence describes the national boundary file — owner to confirm intent) | yes |
| Choropleth students_at_risk | sums 58,000 (×400/school) | hero = 39,875 (×275/school) | same page, two models | Either regenerate choropleth with ×275 (sums 39,875) or label the layer's multiplier explicitly | yes |
| Hero "39,875 children at extreme risk" | 39,875 | = 145 intersections × 275; unique-count 33,275; own audit bounds 24,650–50,750 | bureau's STUDENT_ESTIMATE_AUDIT | Pair with: `~39,875 exposure instances (projection: school-site intersections × 275 avg enrollment); unique-school estimate ~33,275; range 24,650–50,750` | framing choice → owner |
| "Closest school 59 m" | 59 m (BD-4591) | BD-7303 = 14 m (recomputed 13.9 m) | embedded `cm` fields | Scope: "the featured report's closest school" or amend | framing choice → owner |
| Snapshot contradiction | 145/44/121 | replication from published snapshot: 166/51/125 | lead-belt audit (independently replicated) | Re-freeze correct snapshot + regenerate, or publish the bureau's own reconciliation note | yes |
| Manifest `date_published` | 2025-01-01 | git: first content 2026-05-23, publication 2026-05-25 | repo history | **Mechanical fix ready:** `2025-05-25` — awaiting owner confirmation of intended value (2026-05-25 assumed typo for 2025? or genuinely 2026?) | no (metadata) |

## D-9 — Impunity source count: complete occurrence map (18 instances)

| Surface | "91" occurrences | S-26/27/28 citations |
|---|---|---|
| report.html | 4 ("91 Named Sources" ×2, footer ×2) | 3 (Scenes 01/04: "UK: CPS VAWG 2024 (S-28) · India: NCRB 2022 (S-27)" + one S-26) |
| detailed.html | 10 | 0 |
| methodology_full.html | 1 | 0 |
| investigation.json | 3 (`source_count`, profile) | 0 |
| tracker.html | 0 | 0 |

On approval (recommended: correct to 65): replace 18 text/field instances; re-map S-26/27/28 → the registry's actual entries for CPS 2024 / NCRB 2022 (both exist in the 65-source registry under different IDs — re-mapping table prepared); correct the evidence-page "~91 KB · 91 sources" line; add correction C-004: `"Published source count corrected 91 → 65; three on-page citations (S-26/27/28) re-mapped to registry entries."`
Note: the Phase-4 disclosure profile already shows both counts, so post-correction the registry line simply becomes the single truth.

## D-10 — AI-training policy (two exact implementations prepared)

- **A (recommended):** `robots.txt` generation gains the content-signals block (exact lines prepared: `Content-Signal: search=yes,ai-train=no,use=reference` + the specific bot blocks the bureau previously used, GPTBot/ClaudeBot/CCBot/Bytespider/Google-Extended/Amazonbot/Applebot-Extended) + trust-site note: `"Bureau policy: our reporting is licensed CC BY 4.0 for human reuse; machine-training use is not granted by default and is reserved via robots content-signals."`
- **B:** keep plain `Allow: /` + trust-site note that machine training is permitted under the license.
Both are one-commit changes; neither alters licensing itself.

## D-11 — Tier taxonomy (mapping table complete)

| Manifest label | Works | Methodology-page tier it most matches | Obligation shift if aligned? |
|---|---|---|---|
| Tier 1 – Visual Data Investigation | Blood Routes, Impunity Machine | closest to "Document-Heavy" (Tier 1) | none if publishing the operative taxonomy instead |
| Tier 2 – Visual Spatial Investigation | Lead Belt | closest to "Data-Driven" (Tier 2) | none |
Proposed implementation (Option A from packet): publish the operative taxonomy on `/trust/methodology/` — exact replacement tier-block text drafted (three tiers renamed to the manifest vocabulary with their existing obligation lists carried over verbatim); zero works change obligations. Awaiting approval.

---

## Execution note

All the above ship through the standard gate (build → validate 0-errors → fixtures 8/8 → browser QA on affected routes → logical commits per the section-30 plan → push). Production remains blocked on the single Cloudflare dashboard step (unchanged; see `PRODUCTION_STATE_AUDIT.md`).
