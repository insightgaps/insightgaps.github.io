# Insight Gaps Bureau
# Phase 3 — Investigation / Report Forensic Audit

**Date:** 2 September 2026
**Mode:** Read-only forensic audit of the journalism (no report, dataset, methodology, manifest, or correction content was modified; audit documents only)
**Sources audited together:** website repository (`insightgaps.github.io-main`), assets repository (`assets`), OS repository (`insightgaps-os-main`)
**Branch for outputs:** `phase3-report-improvement`

---

## 1. Executive Summary

The four published investigations are **journalistically coherent, internally disciplined products with materially different levels of evidentiary support — and one of them (Dhaka Slum Fires) cannot currently withstand the scrutiny its own methodology page promises.**

The single most consequential systemic finding: **the bureau's verification apparatus verifies internal consistency, not evidence.** The pre-publish "gatekeeper" (`pre_publish.py` → `adversarial_review.py`) PASSes a report when (a) the draft contains `[[Claim N]]` markers and (b) a claim ledger contains the literal string `[x] Verified by human` — a checkbox the ledger author (an AI session) ticks itself. The slum-fires investigation passed this gate "🟢 13/13 verified" while its registered raw dataset never existed (its logged SHA-256 is the hash of an **empty file**), its "cleaning script" hardcodes the final dataset as a Python literal, and its central legal claim carries no case citation in the published page.

Per-investigation standing (audit judgment, not a statement about whether underlying allegations are true):

| Investigation | Standing |
|---|---|
| The Impunity Machine | Strongest: real cleaned datasets, documented scripts, an honest self-audit tradition; headline ratio is arithmetically verifiable from published data |
| The Lead Belt | Strong spatial work with an unusually candid internal audit trail; headline school/exposure numbers are **definitional**, and the published methodology honestly reconciles them — but the headline framing ("39,875 children at extreme risk") still outruns the estimate's own bounds |
| Blood Routes | Split: macro claims (WHO 31,578 vs BRTA 5,480 = 5.8×) are documented against named external sources; but the **published dataset supports only the map** — it contains 2022–2024 records, zero 2026 records, and cannot derive the headline Eid-2026 figure (351 deaths) or the 47%-pedestrian claim (dataset shows 5.8% pedestrian-involved Dhaka deaths) |
| Dhaka Slum Fires | **Not currently defensible as a Tier 2 data investigation**: no raw data, hardcoded "cleaning", uncited legal core, n=4 correlation sold as "clear correlation", empty governance templates, AI-signed human sign-off, dead verification-drawer promise, and unlogged number changes between published versions |

A fifth published work — the **Property Preservation analysis** — is audited here for data integrity only and produced an independent P1: its published methodology text describes "268 work order records spanning May to December 2025, operator-provided ledgers," while the actual dataset driving the public pages is 480 records spanning Nov 2025–Jun 2026 and is headed "Auto-generated EPCS dataset." Whatever this work is (journalism vs tool vs product — unresolved owner decision), its methodology note is presently false on its face.

**Corrections doctrine breach (cross-cutting, P1):** git history shows substantive post-publication amendments that qualify under the bureau's own doctrine but appear in no corrections log: the Impunity Machine's cross-jurisdictional denominator disclosure and 2024-surge aggregation note (commit `36177f6`, 2026-05-26), and the slum-fires number changes (+420%→+250%, +310%→+150%) between its 2026-05-28 deployment and 2026-06-03 republication (`ffdf1b1`/`be5785f`/`9e73d50`), under `has_correction: false`.

**INVESTIGATION QUALITY STATUS (system-level): SIGNIFICANT VERIFICATION GAPS** — one investigation strong, two sound-with-gaps, one not yet defensible, plus a systemic corrections and gating failure. This is an audit of verifiability, not of the truth of the allegations.

---

## 2. Audit Scope and Evidence Base

- All four investigations' published pages were read in full (report, methodology, tracker, detailed pages) — not from manifests alone.
- OS-repo pipeline material per investigation (topic-pipeline stages 00–06, claim ledgers, pre-publish verdicts, cleaned data, scripts, research audits) was read and cross-checked.
- Assets repository inventoried (BD-INV-001 data files; BD-INV-003 storyboard/visual-production material; BD-INV-007 CSV evidence tables; **no BD-INV-004 folder exists**).
- Local datasets re-parsed and key figures recomputed directly: `blood_routes_accidents.json` (2,331 records), `slum_fires_data.json` (4 sites, 9 fire events), Lead Belt report's embedded site data (294 site objects), `epcs_data.js` (480 work orders), `osm_schools.geojson`, Impunity Machine cleaned JSONs (`cr_clean`, `acquittals`, `agg_stats`, `s17`, `fc`, `sources`, `tribunal_cases`) and site data files (`cases.json`, `leads.json`, `monthly.json`).
- Git history of all report pages reviewed for post-publication changes qualifying as corrections.
- Self-audit documents (`docs/publication/*` in website repo; `research/lead-belt-audit/*` in OS repo) read first, then independently verified finding-by-finding.
- Not performed: external re-verification of third-party statistics (WHO, RSF, UNICEF figures) against their original publications — flagged where the audit relies on the pipeline's citation of those sources.

## 3. Repository and Data Map

| Repository | Role | Key evidence |
|---|---|---|
| Website | Published claims & presentation | Report HTML, manifests, corrections log (empty), data files |
| OS (`insightgaps-os-main`) | Production pipeline | Per-topic 7-stage pipelines, claim ledgers, pre-publish verdicts, cleaned JSONs, scripts, `research/lead-belt-audit/` (genuine hostile audits), governance docs |
| Assets | Raw artifacts | BD-INV-001 xlsx/pdf; BD-INV-003 storyboards/visual Bibles/persons (production material, not field evidence); BD-INV-007 source logs/evidence tables. **Nothing for BD-INV-002 (master evidence file exists only in OS repo raw folder), nothing for BD-INV-004.** |
| Reference: PP data | Website repo `analysis/property-preservation/data/epcs_data.js` | 480 work orders, 480 financial records, 2,322 communications; Nov 2025–Jun 2026; "Auto-generated" |

Pipeline architecture (verified in code): `run_pipeline.py` → ingestion (gdrive) → schema validation → CSV integrity → adversarial review → pre-publish verdict → (manual deploy). Gemini keys are pipeline inputs for generation steps; the scheduled workflow runs it daily.

## 4. Investigation Inventory

| Field | Blood Routes | The Impunity Machine | The Lead Belt | Dhaka Slum Fires |
|---|---|---|---|---|
| ID / type | BD-INV-001, Tier 1 "Visual Data" | BD-INV-002, Tier 1 "Visual Data" | BD-INV-003, Tier 2 "Visual Spatial" | BD-INV-004, Tier 2 "Spatial Overlay" |
| Published | 2026-05-26 | 2026-03-01 | 2025-01-01 (manifest; pipeline activity 2026-05/06 — date conflict) | 2026-05-28 (manifest date belongs to a *reverted* version; current narrative published 2026-06-03) |
| Status | published | published | published | published (but **excluded from homepage** by hard-coded slug filter since 2026-06-07, no documented rationale) |
| Source count (manifest) | 22 | 91 | 7 | 7 |
| Headline claims | 351 Eid-2026 deaths/15 days; 23.4/day; WHO ~31,578 vs BRTA 5,480 (5.8×); joma incentive system; 47% Dhaka victims pedestrians; Phoenix rebrand; 4 data voids | 310 convictions / 66,711 OCC women / 23 yrs → 0.46%; 14 OCCs; 2 national DNA machines; §17 counter-prosecutions; backlog; no national registry | 294 sites; 145 schools ≤500 m; closest 59 m; max 680,872 ppm (1,702× 400 ppm); 39,875 children | corridor correlation; +250% Kalshi after Tk 1,012cr flyover; 1,200 structures May 2026; 3,500 displaced; 16.2% wetland decline |
| Public data | `blood_routes_accidents.json` (2,331 rec, 2022–24) + geojson | `cases.json`, `leads.json`, `monthly.json` + OS cleaned JSONs | embedded in report (294 sites) + `osm_schools.geojson` (9,846 nodes) | `slum_fires_data.json` (4 sites, hardcoded origin) |
| Methodology | inside report | dedicated methodology page + OS reconstruction | dedicated methodology page (reconciliation published) | section in-page (draft's version had caveats; published page dropped them) |
| Tracker | none | Impunity Tracker (BD-INV-002) | none | none |
| Downloads | none public | BD-INV-002 master evidence file xlsx (in OS repo only — public link 404) | MasterDataset v5 csv/xlsx (**exists nowhere in any repo**), osm_schools.geojson (OS repo only) | none |
| Corrections | none logged | none logged (but `36177f6` added substantive disclosures post-publication) | none logged | none logged (but +420%→+250% etc. between published versions) |

## 5. Cross-Investigation Findings

1. **The verification gate is self-referential (P0, systemic).** `pre_publish.py` runs `research.py`'s checklist audit, which **exits 0 (PASS) even while printing "[!] WARNING: Some checklist items remain incomplete"** (verified in `scripts/research.py:296-300`: it sets `all_clean=False` but never exits non-zero). The Impunity Machine passed with Stage 06 (publication checklist) **0/12**; slum-fires passed with Stage 00 at 6/8. The "adversarial factual claim traceability" check (`adversarial_review.py`) verifies `[[Claim N]]` marker presence and ledger checkbox text — not evidence. Both investigations then state in output "cleared for publication."
2. **Human sign-off is performed by the AI session (P0, systemic).** Slum-fires publication checklist: "Signature: **Approved by System Administrator (Pair-Programming Turn)**". Release notes credit "Antigravity (Gemini 3.5 Flash)". This contradicts the published AI-use policy ("No correction decision is automated… the editor handles every decision requiring accountability" and "AI tools do not decide what is published") — the observable record shows AI pairs writing, gating, and approving publication in one turn.
3. **Corrections doctrine is breached in practice (P1).** Zero entries in `corrections.log.jsonl`; git history contains qualifying amendments (§1). Under the bureau's own "errors are corrected promptly and logged permanently" standard, at minimum the Impunity Machine denominator disclosures qualify as post-publication clarifications that belong on the record.
4. **Source counts are nominal, definition-free numbers (P2, systemic).** No definition of "source" exists anywhere in either repo (grep confirmed). Counts are arithmetically traceable to internal source *lists* (7 for slum-fires, etc.) but: slum-fires' list was never published and 3 of 7 entries are root-domain URLs; the real dependency surface in its own evidence matrix is ~15 entities. The homepage "127 Total Primary Sources" sums these nominal numbers — a public trust stat with no defined basis.
5. **Public data ≠ headline data (P1, systemic).** Blood Routes publishes a dataset that cannot derive its headline; Impunity Machine's headline *is* derivable from public data; Lead Belt embeds its data (derivable); slum-fires' data is a re-serialization of the narrative. The pattern: published datasets exist to power maps/visuals, not to let readers verify claims.
6. **Download/evidence links promise artifacts that do not exist publicly (P1).** Of the 5 referenced evidence downloads, 3 exist nowhere in any repository (LeadBelt MasterDataset v5 csv/xlsx; PP master dataset xlsx), 2 exist only in the private OS repo (BD-INV-002 master evidence file; osm_schools.geojson) while the public links 404. All five were 404ing on the live site before this phase.
7. **Tier labels don't match the published taxonomy (P3).** The methodology page defines Tier 1 "Document-Heavy", Tier 2 "Data-Driven", Tier 3 "Source-Driven". Manifests use "Tier 1 - Visual Data Investigation", "Tier 2 - Visual Spatial Investigation", "Tier 2 - Spatial Overlay Investigation" — labels from a different (unpublished) taxonomy, so no reader can check a tier's obligations against the work.
8. **Publication-dates in manifests are unreliable (P3).** Lead Belt's manifest says 2025-01-01 while its pipeline/audit activity is 2026-05/06; slum-fires' manifest date attaches to a reverted version.

## 6. Claim-to-Evidence Traceability

Classification: **A** directly supported & reproducible · **B** supported, partially reproducible · **C** supported with methodological ambiguity · **D** weak traceability · **E** unsupported/cannot verify.

| ID | Investigation | Published claim | Supporting artifact | Dataset | Traceability | Reproducible? | Finding |
|---|---|---|---|---|---|---|---|
| BR-1 | Blood Routes | "351 deaths, 15-day Eid-ul-Fitr 2026 (Mar 14–28), 23/day" | **None.** Public dataset has zero 2025/2026 records; no 15-day window sums to 351; no RSF/BJKS 2026 Eid report exists in either repo; no URL. Git: headline swapped from "312 deaths/12 days/Eid-ul-Adha June 2025, 29% YoY surge" **on publication day** (`4499e8a` website, `6032db0` OS, 2026-05-26) | None | **E** | No | Unverifiable headline swapped in on publication day; no archived source for either number; the old 29% YoY figure survives in the 2025 Adha chart description where (312−262)/262 = 19.08% — arithmetically wrong and still published |
| BR-1b | Blood Routes | Night-crash share: published "97.13%" → now "41.56%" | 97.13% derived from the 95%-padded dataset; OS retracted claim 2026-06-03 (`c57c283`, citing "synthetic padding artifacts"); website silently corrected 2026-06-08 (`527d0a4`) | Derivable (and wrong — that's the point) | **E → silently corrected** | Yes | **A published headline statistic that was independently checkable and wrong, corrected after ~11–13 days live with the corrections log empty, `has_correction: false`, `date_revised: null`** — direct violation of the bureau's published corrections policy |
| BR-2 | Blood Routes | WHO ~31,578 vs BRTA 5,480 (5.8×) | "WHO Global Status Report 2023 · BRTA Annual Report 2023" name-dropped (internal matrix adds "page 14"); not archived | None public | D | No (arithmetic ✓, sources unarchived) | Honestly tiered "PROBABLE (derived, model-dependent)" in-page |
| BR-3 | Blood Routes | "47% of Dhaka's road victims are pedestrians" + "41.56% of fatal Dhaka crashes 10pm–6am" | "RSF Dhaka Annual Report 2025" — not archived | Public dataset: 5.8% pedestrian-involved Dhaka deaths (87/1,512); no time-of-day field | **E** | Contradicted/underivable | 41.56% is itself the post-publication replacement for the false 97.13% (BR-1b); dataset is 85% truck–motorcycle records — composition invisible to readers |
| BR-4 | Blood Routes | Database-audit counts: "bus (909) / truck (45,891) / only a single record mentions a brand name (Saint Martin Paribahan)" | Pipeline Claim 9 | Recomputed from raw xlsx: 'bus' any-cell 2,758; 'truck' 46,020; Vehicle-Info col 931/45,985; paribahan = 5 distinct strings, 27 cell refs | **E** | Attempted; fails | Published counts fail replication; "single record" is false (direction holds, numbers don't) |
| BR-5 | Blood Routes | Figshare dedup forensics: 47,680 → 2,331 (95.11% padding); 143 "IMG 2467" rows; 353 narratives; template 45,505 (95.4%); driver age 25.82; deaths 4,252 | Raw xlsx (all 3 repo copies, identical MD5) + `clean_blood_routes.py` | Recomputed: **every figure reproduces exactly** | **A** | Yes | The bureau's strongest data forensics — genuinely adversarial work on a flawed academic source |
| BR-6 | Blood Routes | Motorcycle crosstabs (unlicensed 47.26% vs licensed 16.85% = 2.8×; helmet 31.16/30.47) | Mendeley CSV (archived, 15,102 rows) | Recomputed to two decimals | **A numerically / D provenance** | Yes | Source is a rider **survey** with no "fatal" category, framed as "highway records"/"Severe/Fatal" — mislabeled provenance |
| BR-7 | Blood Routes | Division map/rates (Dhaka 18.62/M etc.), "Extreme/High/Moderate" risk labels, 25 hotspots | Map JS + published JSON | 25 hotspots ✓; live counts verified (airport 60/107, feni 142/251); **but 802 of 1,508 "modelled" records had Dhaka source-locations reassigned to non-Dhaka divisions** ("Mohakhali Flyover"→Chattogram; "Mirpur 1 Road"→Feni); several advertised Dhaka hotspots match 0 records | **C** | Yes (of the reassigned data) | Division statistics and risk labels are computed on quietly relocated Dhaka records; "modelled corridor placement" under-discloses relocation; 6 Dhaka hotspots display "0 Crashes, 0 Deaths" |
| BR-8 | Blood Routes | ARI-BUET 2000–2006 historical series, charted "ARI-BUET (Official)" | `download_raw_datasets.py` — the figures are **hard-coded literals** in the script, not downloaded | Values match the hard-codes | **E** | No | "Official" label on script-generated constants |
| IM-1 | Impunity Machine | 310 convictions / 66,711 OCC women / 23 years = 0.46% | OS cleaned data (`cr_clean.json`, `agg_stats_clean.json`) + master evidence xlsx (private) + published methodology | Public: ratio arithmetic present; counts sourced | B | Yes (ratio); counts trace to private xlsx | Strongest chain in the bureau: scripts (`verify_claims.py`) exist and methodology page reconstructs the model |
| IM-2 | Impunity Machine | 14 OCCs; 2 national DNA machines; backlog | Master evidence xlsx / entities JSONs | `fc_clean.json`, entities | B | Partially | Counts traceable to archived (private) evidence; public page states sources per figure |
| IM-3 | Impunity Machine | Cross-country comparison (0.46% vs UK 53.4% etc.) | Post-publication disclosure `36177f6` | Published note in-page | B | Yes | Denominator-metric caveat properly disclosed — but added post-publication without corrections entry |
| IM-4 | Impunity Machine | Tracker values | `cases.json`, `leads.json`, `monthly.json` | Public | A/B | Yes (values re-derived from JSONs during audit) | Tracker is data-driven; last-verified dates present |
| LB-1 | Lead Belt | 294 contaminated sites | Embedded dataset (294 site objects parsed & counted) | Embedded + Pure Earth/UD assessment data (external) | A | Yes | Verified: 294 objects with ppm values; 35 sites >400 ppm in embedded set |
| LB-2 | Lead Belt | 145 schools within 500 m | Embedded per-site school counts (sum = 145, verified) | Embedded + osm_schools.geojson | **A against embedded / E against snapshot** | Sum yes; snapshot no | 145 = **site-school intersections, not unique schools**. My independent full replication (294 sites × 9,846-school snapshot, Haversine ≤500 m) yields **166 intersections / 51 sites / 125 unique schools** — not 145/44/121. The published numbers are only recoverable from an unpublished Excel workbook; the "archived frozen snapshot" itself contradicts them (7 sites with `sc:0` in published data have schools within 500 m in the same snapshot) |
| LB-2b | Lead Belt | "44 formally assessed sites have at least one school within 500 m" | Embedded `sc>0` count = 44 | Same | **E against snapshot** | No | Snapshot re-run gives 51 hit-sites; the bureau's own discrepancy report attributes this to OSM drift — but the snapshot was archived precisely to prevent that, so the headline traces to nothing published |
| LB-2c | Lead Belt | On-page number set | Embedded data | Same | **Internally contradictory** | Yes (all of them) | The single page carries **five mutually inconsistent numbers**: filter chip "Satellite Active 26" vs `sat:true`=19; "Critical >100k: 68" vs `p>100k`=65 (3 of 68 are ≤100k, incl. one at exactly 100,000); "507 upazila boundaries" vs 93-polygon GeoJSON; choropleth `students_at_risk` summing to 58,000 (×400/school) vs hero 39,875 (×275); the embedded `st` field uses a 400/school multiplier appearing in no methodology document |
| LB-3 | Lead Belt | "closest school 59 metres" (Kamrangir Char, BD-4591) | Embedded `cm` field = 59 for BD-4591 | Embedded | B | Yes (58.8 m recomputed) | Verified for BD-4591 — the distances are genuine Haversine outputs (43/44 `cm` values reproduce within 3 m); **but three sites have closer schools (BD-7303: 14 m; BD-5035/BD-7382: 53 m)** — the "closest" framing survives only because the narrative ignores closer sites; also the internal video-brief says the 59 m school is in "Kathgora" (it's Kamrangir Char) — factual drift between promotional and published layers |
| LB-4 | Lead Belt | max 680,872 ppm ≈ 1,702× the 400 ppm threshold | Embedded `p`=680872, `xs`=1702.2 for BD-4921 | Embedded | A | Yes | Arithmetic verified exactly |
| LB-5 | Lead Belt | "39,875 children at extreme risk" (hero/meta) | 145 × 275 (APSS 2024 urban avg) | None (multiplier external) | C | No | Methodology publishes the estimate's nature and reconciliation; but the **hero/meta framing outruns it**: "children at extreme risk" vs an intersection-count projection whose own audit bounds it 24,650–50,750 and calls the unique-count figure 33,275 |
| LB-6 | Lead Belt | 26 of 44 sites "active" March 2026 | Gemini 2.0 Flash Lite satellite classification; satellite_proof JPGs (only 2 of 26 sites' proof published; 88-image archive private in OS repo) | `sta`/`sat` flags in embedded data | C | No | Report qualifies as "visual indicators" and names the tool — good practice; the bureau's own decision memo rated the claim **Unverified**; **BD-4802's prose claims March-2026 satellite confirmation but its record is `sat:false, sta:'assessed'`** — data contradicts prose |
| LB-7 | Lead Belt | "Full code and static snapshots are open for verification in the downloads package below" | **All four data downloads dead** (MasterDataset v5 xlsx+csv, osm_schools.geojson, osm_intersections.csv — none exist in any repository) | — | **E** | No | The reproducibility promise is factually false in the shipped state; the release checklist's claim that these were "registered on the Data Repository index page" is contradicted by the current tree (dropped in the June "Restore legacy" commits); `analyze.py` IS published but exists in **two divergent versions** (website vs OS repo, different content, no statement of which produced the findings) |
| SF-1 | Slum Fires | "High Court ruled no eviction without notice + rehabilitation" (Articles 15(a)/32; ASK/BLAST/CUP; writ by 126 residents incl. 36 freedom fighters) | **None published**: no case name/number/date/link in page; writ no. 9763/2008 appears only as a search query in `01-source-search.md`; no judgment archived anywhere | None | **E** | No | The investigation's load-bearing legal fact is uncited in public |
| SF-2 | Slum Fires | +250% land value at Kalshi after Tk 1,012cr flyover; 1,200 structures; 3,500 displaced; 16.2% wetland decline | `slum_fires_data.json` typed fields for +250% only; 1,200/3,500 in free-text `details`; 16.2% nowhere | Hardcoded-origin data file | D | No | Prior published version said **+420%** (reverted same day); no sales records exist despite "compiled from land registration and sales records (2006–2026)" |
| SF-3 | Slum Fires | "correlates directly" / "clear correlation" transport expansion ↔ fires | 4 hand-picked sites (audit recomputation: r = −0.845, n=4) | `slum_fires_data.json` | D | Yes (and meaningless) | n=4 correlation oversold as a finding; 2 of 9 "fire" records are evictions per their own text |
| PP-1 | Property Preservation | "268 work order records spanning May to December 2025, operator-provided ledgers" | `epcs_data.js`: **480 records, Nov 2025–Jun 2026, "Auto-generated"** | Website repo | **E** (methodology note vs reality) | Yes (contradicted) | Whatever the work's editorial status, the published methodology note is false on its face; the "less than half reaches the bank" claim also reads oddly against the data's 53.9% collected ratio |

## 7. Data Lineage and Reproducibility

- **Blood Routes:** RAW (ARI BUET 2000–06 CSV, data_gov xlsx/csv, Mendeley motorbike set — all in OS `datasets/blood-routes/raw_collection/`) → `clean_blood_routes.py`/`analyze_clean_data.py` → `blood_routes_accidents.json` (2,331 recs). Lineage for the *map* is real and scripted. Lineage for headline claims (Eid 351, 47%, WHO/BRTA) is **external-report citation only** — standard journalism practice, but the page does not distinguish "derivable from our published dataset" from "cited from external reports," and the hero presents both identically.
- **Impunity Machine:** RAW `BD-INV-002_Master_Evidence_File.xlsx` (OS repo, with manifest) → `clean_data.py` → 8 cleaned JSONs → `verify_claims.py` → published figures. **The bureau's only complete raw→published chain.** The 0.46% headline recomputes from published `cases.json`/methodology arithmetic.
- **Lead Belt:** RAW (Pure Earth/UD assessments + OSM snapshot) → workbook analysis (Excel, historically) → `analyze.py` (replication script, published on site at `/methods/analyze.py` — verified present) + `osm_schools.geojson` (9,846 nodes, OS repo) → embedded site data. Reproducible in principle (script + geojson exist publicly/pinately), with the counting-definition caveat published in the methodology. The v5 master dataset referenced publicly exists **nowhere**.
- **Slum Fires:** **No raw.** Registered raw CSV's logged SHA-256 = empty-file hash; "cleaning script" emits a hardcoded `SLUM_DATA` literal; no analysis scripts (`.gitkeep` stubs); haversine described in methodology but never implemented. Lineage is fabricated in form, narrative in substance.
- **Property Preservation:** `epcs_data.js` "Auto-generated … Nov 2025 to Jun 7, 2026" — generator not in any audited repo; published methodology note describes a different (smaller, earlier) dataset.

## 8. Methodology / Verification Tier Audit

| Investigation | Assigned tier (manifest) | Standard's requirements for that tier (methodology page) | Evidence actually present | Pass/Fail | Reason |
|---|---|---|---|---|---|
| Blood Routes | "Tier 1 - Visual Data Investigation" | Tier 1 (Document-Heavy): traceable primary document for central claim; stats require original source; coordinate verification for geo claims | Central claims cited to external reports (not archived documents); geo claims verified for the map dataset (`geo_verification_report.md`) | **Partial** | Label taxonomy mismatch; external-report sourcing is real but the published dataset can't carry the headline numbers |
| Impunity Machine | "Tier 1 - Visual Data Investigation" | Same as above | Master evidence file (private), cleaned data + scripts (reproducible), per-figure sources stated, methodology reconstruction doc | **Pass (with access caveat)** | Meets document-heavy standard; public reproducibility limited by the private xlsx |
| Lead Belt | "Tier 2 - Visual Spatial Investigation" | Tier 2 (Data-Driven): reproducible from raw data via documented scripts; no manual edits; outliers explained; methodology note mandatory | Replication script + OSM snapshot published; methodology note with reconciliation; satellite claims qualified | **Pass** | Strongest methodology page of the four |
| Slum Fires | "Tier 2 - Spatial Overlay Investigation" | Same as above | No raw data; hardcoded "cleaning"; no scripts; ~⅓ of numbers in data file, rest prose-only; legal core uncited | **Fail** | Fails every Tier 2 clause that can be checked |

Note: tiers are audited, not reassigned (editorial act reserved to owner).

## 9. Source Count Audit

| Investigation | Manifest | Report-countable | Reality |
|---|---|---|---|
| Blood Routes | 22 | ~8–10 distinct named external sources + 4 archived datasets in OS repo | Pipeline source-search lists align with ~22 *documents/entities*; not published as a list; definition absent |
| Impunity Machine | 91 | `sources_clean.json` exists (OS) — count pending agent consolidation | The only investigation with an archived source dataset backing its count |
| Lead Belt | 7 | ~7 named external sources in report/methodology | Count matches named sources; several are aggregate citations (Pure Earth program, not per-site) |
| Slum Fires | 7 | Draft listed exactly 7; 3 root-domain URLs, 1 no URL; published page lists **zero** | Count is arithmetically honest, substantively empty; evidence matrix implies ~15 dependencies |
| **Homepage "127 Total Primary Sources"** | sum of manifests | — | A public trust stat with no defined basis and no published source lists — P2 |

## 10. Visualization Audit

- **Impunity Machine** (canvas/inline-SVG, scroll-driven): visually strong; source lines present on several panels (e.g., "PHQ via Kaler Kantho 2019–2020 · PHQ via TBS 2023…"); **P2: inline font sizes 0.42–0.55rem** — unreadable on mobile and below any accessibility floor; canvas charts have no text alternatives. The cross-country comparison chart now carries the denominator caveat (post-publication fix).
- **Lead Belt** (Leaflet + markercluster + satellite viewer): data-driven from embedded dataset (numbers verified); map legend/labels not audited at pixel level (agent consolidation pending); satellite viewer is JS-populated (empty `src` until selection — Phase 1's "empty src" finding was this, not a defect).
- **Blood Routes** (Leaflet map over `blood_routes_accidents.json`): map is genuine data visualization; hero number panel mixes dataset-derived and external-report numbers without distinction (P2).
- **Slum Fires**: promised "Interactive Forensic Slider Map" never existed (spec references a never-written script and a `file:///` local path); published page has **no visuals beyond text** and advertises a verification drawer/land deeds/court writs that do not exist (P1) — the drawer was implemented 2026-06-03 and **silently dropped in the Phase-2 rebuild** (`803c990`) while the promise text survived.
- **Infographics** (assets/img): three exist; slum-fires' infographic never existed yet was shipped as og:image URL to production in the June version.

## 11. Tracker Audit (Impunity Tracker)

- Tracks: conviction-rate state, §17 counter-prosecutions, reform status, DNA backlog (per tracker page + `cases/leads/monthly.json`).
- Data-driven: values re-derivable from the published JSONs (verified during Phase-1 testing and re-checked); last-updated metadata present on the page.
- Gaps: update cadence is not stated as a commitment (a "monitoring station" with no published cadence or historical-change log); historical values preserved only via git, not surfaced to readers (P2); no per-row source citation on tracker statuses (P3).

## 12. Evidence Download Audit

| Reference | Expected artifact | Exists? | Where | Status |
|---|---|---|---|---|
| `/data/BD-INV-002_Master_Evidence_File.xlsx` | Impunity master evidence | **Yes (private)** | OS repo `topic-pipeline/the-impunity-machine/data/raw/` (+ manifest) | Public link 404 — classification: **intentionally private artifact, publicly referenced** (owner decision: publish or de-link) |
| `/data/BD-INV-003_LeadBelt_MasterDataset_v5.csv` / `.xlsx` | Lead Belt master dataset | **No — nowhere in any repo** | — | Stale/broken reference; the 12-sheet v5 workbook described in decision memo is not in any audited repository |
| `/data/osm_schools.geojson` | OSM schools snapshot | **Yes (private)** | OS repo `datasets/lead-belt/` (9,846 nodes) | Public link 404 — publishable snapshot (owner decision) |
| `/data/PP-ANA-001_PropertyPreservation_MasterDataset.xlsx` | PP master dataset | **No** | — | Stale reference (and see PP-1: published description doesn't match the live dataset anyway) |

Classification: 2 intentionally-private artifacts publicly referenced; 2 stale/missing; 0 correctly published. **The evidence system currently advertises verification it cannot deliver** — the opposite of its purpose.

## 13. Corrections Audit

- Public log: **empty**; `has_correction: false` on all four manifests.
- Git history contradicts "no corrections" in substance:
  - **Impunity Machine** `36177f6` (2026-05-26): adds cross-jurisdictional denominator disclosure + 2024-surge aggregation note → qualifies as post-publication clarification/correction-adjacent change under doctrine (classification: **editorial update / correction candidate** — owner decision).
  - **Lead Belt** `36177f6` also adds geo-verification report entries; language-hardening commit qualifies claims ("visual indicators") → **editorial update** (pre-publication hardening was ordered by decision memo; publication date makes it post-publication in effect — owner decision).
  - **Slum Fires** `ffdf1b1`→`be5785f`→`9e73d50`: +420%→+250%, +310%→+150%, wholesale fire-history replacement between two publicly deployed versions; manifest keeps `date_published: 2026-05-28` and `has_correction: false` → **correction-class change, unlogged** (the same-day revert of v1 gives partial cover; the manifest date binding is the error).
  - Phase-2 note (self-report): the 2026-09-02 rebuild dropped slum-fires' verification drawer (functional regression, not editorial).
- No evidence any change was made to *hide an error*; all observed changes go in the direction of **more** caution. The failure is the missing record, not the missing integrity.

## 14. AI-Use Audit

- Published policy (trust page): tool table with roles/prohibitions; "AI does not decide what is published"; "human editor makes every deployment decision."
- Observable reality: pipeline uses Gemini keys for generation/analysis steps; slum-fires release notes credit **"Antigravity (Gemini 3.5 Flash)"** as author; publication checklist signed "**Approved by System Administrator (Pair-Programming Turn)**"; pre-publish gate ran on AI-authored ledgers ticking their own "Verified by human" boxes.
- Lead Belt is the model of good practice: report names "Gemini 2.0 Flash Lite" for satellite classification and qualifies its outputs as visual indicators; decision memo rates that very claim Unverified and delayed publication pending fixes.
- Verdict: **policy-vs-practice gap (P1)**. Not hidden AI use — the opposite: the repo is candid — but the *human-owned final gate* the policy promises is not observable in the record for at least one publication. No speculation about other runs.

## 15. Report Presentation / UX Audit

Helps verification: per-investigation landing pages with status/tier/date/dek; dedicated methodology pages (Impunity, Lead Belt) with real reconstruction content; tracker with data behind it; claim-badge discipline (slum-fires' 13 numbered claims; Impunity's claim data-ids in methodology).
Obstructs verification: evidence links 404 (§12); no per-claim source lists published for any investigation; slum-fires' dead drawer promise; hero/meta framing outrunning caveats (LB-5, BR hero); 0.4–0.5rem inline chart text (Impunity) unreadable on mobile; no breadcrumbs between report/methodology/tracker (Phase-2 preserved legacy nav, which is report-page-internal); no "how this number was calculated" affordance next to headline numbers; homepage "127 sources" stat (§9).
Unnecessary friction: none egregious beyond the above; the property-preservation app's headless views remain title-less (frozen WAIT item).

## 16. Technical Report Quality

Frozen-platform boundary respected; only report-page findings: Impunity inline styles (mobile readability P2, accessibility P2); slum-fires page body preserved word-for-word (correct — no silent changes); Lead Belt's report self-contains data (good for archival, bad for reuse — dataset-as-JS); JSON-LD on report pages is bespoke (Article markup of unknown strictness — carried from legacy; standardization is Phase-3 implementation work); og:image on slum-fires correctly falls back to bureau default in current build.

## 17. Blood Routes Audit

**Strong:** the dedup/padding/temporal forensics on the Figshare dataset **fully reproduces from raw data** (47,680→2,331; 95.11% padding; 143 IMG rows; 353 narratives; template 45,505; age 25.82; deaths 4,252; hotspot counts) — genuinely adversarial data work; motorcycle crosstabs reproduce to two decimals from archived raw CSV; evidence-tier labels (CONFIRMED/PROBABLE/ALLEGED/UNVERIFIED) consistently applied with Phoenix ownership correctly held at ALLEGED and right-of-reply documented; fabricated operator attributions correctly stripped from the final artifact; provenance fields shipped in the public JSON; geo-verification report published despite its adverse findings; denominator note on the scale chart; honest tiering of the WHO/BRTA comparison ("modelled, PROBABLE").
**Weak:** F-1/F-2 (silent correction of the false 97.13% headline stat; publication-day swap of the unverifiable 351 headline with the old 29%-YoY figure still wrong and published at 19.08% actual); F-3 (802 Dhaka records quietly reassigned to non-Dhaka divisions, division rates/risk labels computed on reassigned data, "modelled corridor placement" under-disclosing); F-4 (909/45,891/"single record" counts fail replication); F-5 (documented methodology describes a different artifact than shipped: JKS 2016–2026 spread and operator-attribution rules vs actual 2022–2024, operators NULL — an earlier stage fabricated attributions, final artifact removed them, docs never reconciled); F-6 (no limitations section despite the pre-publish advisory explicitly requesting one; "any claim derived from raw row counts would be fraudulent" caveat not carried into the report); F-7 (traceability PASS draft-scoped; 20+ published numbers outside the 13-claim ledger); F-8 (ARI-BUET "Official" figures are hard-coded script literals); F-9 (corrupted data_gov downloads retained as "evidence"); F-11 (broken methodology_link; zero downloadable evidence for BD-INV-001 while 002/003 get links; evidence page cites "Nirapad Sarak Chai" — a source never used in the report); F-14 (source-count 22 vs "20+" vs ~24–25 countable; zero external hyperlinks in 3,514 lines).
**Critical findings:** REP-018 (P0: silent correction 97.13%→41.56%, `527d0a4`, live ~11–13 days, log empty); REP-019 (P0: publication-day headline swap, unverifiable 351); REP-020 (P1: geographic reassignment under-disclosure); REP-021 (P1: non-replicating published counts); REP-022 (P1: methodology↔artifact divergence); REP-023 (P2: no limitations section); REP-024 (P2: wrong 29% YoY still published); REP-025 (P2: "Official" hard-coded series).
**Required owner decisions:** log the correction for `527d0a4` and set `has_correction`/`date_revised`; cite/archive the RSF/BJKS 2026 Eid report or re-basis the headline; publish a limitations section; reconcile METHOD_SUMMARY with the shipped dataset; disclose the Dhaka→non-Dhaka reassignment in the map's data note; fix the 29% YoY description, the 909/45,891 counts, and the broken methodology_link.
**Recommended improvements (presentation-only):** source-basis labels on hero numbers (implemented); dataset-profile disclosure; evidence-page honesty (implemented).

## 18. The Impunity Machine Audit

**Strong:** the bureau's only complete raw→script→published chain (private xlsx + clean_data.py + verify_claims.py + cleaned JSONs); methodology page that reconstructs the conviction-rate model and discloses denominators; honest self-audit tradition (context packs, claim inventory, data audit in website repo `docs/publication/`); tracker with public data.
**Weak:** master evidence file private while publicly linked (404); the 0.46% headline's *inputs* (310, 66,711, 23 yrs) trace to the private xlsx — public readers can verify arithmetic but not the counts; cross-country chart caveat added post-publication unlogged; mobile chart text unreadable; source count 91 unverifiable publicly.
**Critical findings:** REP-010 (P1: evidence-download promise broken); REP-011 (P2: post-publication disclosures unlogged); REP-012 (P2: mobile/accessibility of chart text).
**Required owner decisions:** publish or de-link the master evidence file; whether the 91-source count gets a published basis; corrections-log entry for `36177f6` disclosures.
**Recommended improvements:** per-figure source tags; data-table fallbacks for canvas charts; public "evidence digest" derived from the master file (provenance-preserving).

## 19. The Lead Belt Audit

**Strong:** the embedded dataset is genuine and granular — every headline number reproduces **exactly** against the shipped 294-record dataset (294; 145-sum; 680,872/1,702×; 59 m recomputed 58.8 m; 44; upazila `sites_count` sums to 294; all 294 `xs` values = round(p/400,1); min ppm 9 with 20 "low" sites correctly retained); the self-audit suite is exceptional by industry standards (the 145-vs-121 overlap flaw and the 19.8% overstatement are documented by the bureau itself, and the methodology page publishes the reconciliation rather than hiding it); honest labeling in places ("projection based on national primary school averages", "visual indicators of activity", data-age warnings); real Esri satellite basemap with genuine 768×768 proof JPGs for the two case-study sites; SVG map fallback with per-dot titles; no post-publication tampering of the data payload; `dateModified` honestly bumped.
**Weak:** LB-7 (all four data downloads dead — the reproducibility promise is false in the shipped state; the sites CSV exists only as the embedded JS array, which `analyze.py` cannot consume); LB-2/2b (published spatial results not reproducible from the archived snapshot — my independent replication gives 166/51/125 vs published 145/44/121; the discrepancy report's "OSM drift" explanation fails because the snapshot was archived to prevent exactly this); LB-2c (five mutually inconsistent numbers on one page: 26/19 satellite, 68/65 critical, 507/93 upazilas, 58,000/39,875 students, ×400/×275 multipliers); Tier 2 not earned under the bureau's own definition (reproducibility and no-manual-edits criteria unmet); citation drift (Sultana DOI vs vol/article; Forsyth vs "icddr,b + Stanford"; 7,257 vs 9,846 OSM node counts in OS docs); source count 7 is the footer-list length while the OS evidence inventory catalogs 14; only 2 of 26 "active" sites have published proof; manifest `date_published: 2025-01-01` contradicts git (first content 2026-05-23, publication 2026-05-25).
**Critical findings:** REP-026 (P0: dead downloads vs "open for verification" promise); REP-027 (P0: snapshot contradiction — headline numbers trace only to an unpublished workbook); REP-028 (P1: five on-page number contradictions incl. the BD-4802 prose-vs-data conflict); REP-029 (P2: citation/DOI drift; divergent analyze.py versions; date metadata).
**Assets-repo structural finding:** `assets/BD-INV-003/` is **video-production material, not investigation evidence** — storyboard/style bibles, viral-video frameworks, and 17 AI-generated production plates including named-person photorealistic portraits (children) tied to the real contamination story. None of it is cited by the report. **Risk flag:** if those AI renderings are ever published as depicting real affected persons, or the promotional video ships with the internal brief's drifted numbers ("121 schools", "Kathgora 59m", "Gazipur"), it becomes a P0 integrity issue. Archived-but-unpublished, it is a governance concern (evidence repo hygiene), not a publication defect.
**Required owner decisions:** D-3/D-8 in `OWNER_DECISIONS_REQUIRED.md` — publish the v5 dataset (decision memo calls it publication-ready) or re-freeze the correct snapshot and regenerate; align the five on-page numbers (several fixes are mechanical re-derivations from the embedded data — but each changes displayed values, so they are editorial); the video-production material's governance.
**Recommended improvements (presentation-only):** none safe to auto-fix — the contradictions are in published content; all paths run through owner decisions.

## 20. Dhaka Slum Fires Audit

**Strong:** disciplined claim numbering (13 claims, consistently cross-referenced in pipeline and page); prose traceable verbatim between OS draft and published page; data file schema-valid; missing infographic documented rather than faked; the draft's internal limitations section is candid.
**Weak / critical (full agent audit incorporated):** P0 fabricated reproducibility chain (empty-file hash; hardcoded SLUM_DATA; stub scripts); P0 self-verifying gate + AI-signed human sign-off; P1 uncited legal core (no case name/number/date; zero external links in the page); P1 dead verification-drawer promise (dropped in Phase-2 rebuild while promise text survived — my own phase's regression, now documented); P2 hero metric (16.2%) with no data; P2 n=4 correlation oversold; P2 nominal source count (7, half-broken, unpublished list); P2 unlogged number changes between published versions; P3 empty governance templates presented as reference package; P4 label/date/housekeeping.
**Required owner decisions:** whether BD-INV-004 remains published as-is, is annotated (limitations + sourcing disclosures), or is unpublished pending the raw evidence its methodology promises; whether the drawer/verification-desk affordance is restored; whether homepage suppression is a policy (and documented) or reverted.
**Recommended improvements (within presentation-only):** restore the claim-ledger drawer from the June version (it exists in git history); publish the limitations section from the draft (content already written by the bureau — surfacing existing material, not authoring); add the writ petition citation from the draft's source list. All editorial decisions remain the owner's.

## 21. Critical Findings

P0 — REP-001 slum-fires fabricated data lineage (empty-hash raw, hardcoded "cleaning", stub scripts)
P0 — REP-002 verification gate verifies markers/checkboxes, not evidence; exits PASS on warnings
P0 — REP-003 human sign-off performed by AI session (slum-fires); contradicts published AI policy
P0 — REP-018 blood-routes silent correction of the false 97.13% headline statistic (`527d0a4`), live ~11–13 days, corrections log empty
P0 — REP-019 blood-routes publication-day headline swap (312/2025 → 351/2026) with no archived source; old 29% YoY figure still wrong-and-published
P0 — REP-026 lead-belt all four data downloads dead while the report asserts "open for verification in the downloads package"
P0 — REP-027 lead-belt published spatial results not reproducible from the archived snapshot (independent replication: 166/51/125 vs published 145/44/121); headline traces only to an unpublished Excel workbook
P1 — REP-004 legal core of slum-fires uncited in public (case name/number/date absent)
P1 — REP-005 evidence-download system advertises verification it cannot deliver (2 private-referenced, 2 nonexistent; impunity evidence registry paths point to a nonexistent assets/BD-INV-002 folder)
P1 — REP-006 corrections doctrine breached: qualifying post-publication amendments unlogged (impunity disclosures; blood-routes 97.13%; slum-fires number changes; lead-belt post-publication edits with has_correction:false)
P1 — REP-007 slum-fires dead verification-drawer promise (incl. Phase-2 regression)
P1 — REP-008 Blood Routes 47% pedestrian claim contradicted by published dataset (5.8%), uncaveated; 802 Dhaka records quietly reassigned to non-Dhaka divisions powering the map's risk labels
P1 — REP-009 PP methodology note false on its face (268/May–Dec-2025 vs 480/Nov25–Jun26 auto-generated)
P1 — REP-010 AI-use policy vs observable publication practice
P1 — REP-020 blood-routes published audit counts fail replication (909/45,891/"single record")
P1 — REP-021 blood-routes documented methodology describes a different artifact than shipped (2016–2026 JKS spread + operator rules vs 2022–2024, NULL operators)
P1 — REP-028 lead-belt five mutually inconsistent on-page numbers (26/19 satellite; 68/65 critical; 507/93 upazilas; 58,000/39,875 students; ×400/×275) + BD-4802 prose contradicting its own `sat:false` record
P2 — REP-011 nominal source counts; homepage "127 sources" without definition; impunity manifest 91 vs archived registry 65 (lead auditor re-verified); lead-belt 7 vs OS inventory 14
P2 — REP-012 Lead Belt hero framing vs own audit bounds; 14/53 m closer schools vs "closest 59 m"
P2 — REP-013 Impunity mobile/accessibility (0.42–0.55rem chart text; no chart alternatives)
P2 — REP-014 slum-fires hero 16.2% metric without data; n=4 correlation language
P2 — REP-015 homepage suppression of slum-fires institutionalized in build code without documented rationale
P2 — REP-022 blood-routes: no limitations section despite explicit advisory; traceability PASS draft-scoped (20+ numbers outside ledger); ARI-BUET "Official" hard-codes; corrupted data_gov "evidence" files retained
P2 — REP-029 lead-belt citation/DOI drift; divergent analyze.py versions; date metadata contradictions
P2 — REP-030 lead-belt only 2 of 26 "active" sites have published proof; 88-JPG archive private; assets-repo is promotional video-production material (incl. AI named-person portraits — governance risk if ever published as real persons)
P3 — REP-016 tier-label taxonomy mismatch; manifest date conflicts; slum-fires governance templates empty; blood-routes doc arithmetic errors
P4 — housekeeping (PP relative links; local file:// references in specs; size-label errors; etc.)

## 22. Root Causes

RC-1 **Verification defined as internal consistency.** Symptoms: REP-002, REP-004, slum-fires P0s. Impact: the entire quality apparatus can pass evidence-free work. Control: gate on artifact existence + hash + external-source resolution, not markers/checkboxes; exit non-zero on warnings.
RC-2 **No published source/evidence binding per claim.** Symptoms: REP-005/008/011. Impact: readers cannot trace; counts are theater. Control: per-claim source registry rendered on-page (data, not prose).
RC-3 **Corrections log disconnected from git reality.** Symptoms: REP-006. Impact: doctrine says "never edited or deleted"; history shows unlogged substantive changes. Control: publication-change review step comparing report diffs to the corrections log before deploy.
RC-4 **Publication state managed by code patches, not policy.** Symptoms: homepage slug filter (REP-015), reverted deploys carrying manifest dates. Impact: "published" means different things on different surfaces. Control: status field in manifest drives all surfaces; no per-slug code exclusions.
RC-5 **Public data chosen for visuals, not verification.** Symptoms: REP-008, §5.5. Impact: datasets exist but don't support claims. Control: publish claim-relevant aggregates, or label hero numbers by source-basis.

## 23. Priority Issue Register

| ID | Priority | Type | Investigation | Location | Observed fact | Evidence | Interpretation | Impact | Recommendation |
|---|---|---|---|---|---|---|---|---|---|
| REP-001 | P0 | Evidence/Data | Slum Fires | OS `topic-pipeline/dhaka-slum-fires/`, `scripts/clean_dhaka_slum_fires.py` | Raw CSV absent; its SHA-256 = empty-file hash; script hardcodes SLUM_DATA | `01-source-search.md` hash `e3b0c442…`; script source read | Fabricated lineage | Tier 2 mandate unmet | Owner: annotate or unpublish; never present scripts as lineage without inputs |
| REP-002 | P0 | Methodology | All | `scripts/research.py:296-300`, `pre_publish.py`, `adversarial_review.py` | Gate exits 0 while printing warnings; PASSes on marker presence | Code read; verdict files | Self-referential QA | Evidence-free work can pass | Fail-closed gate; artifact checks |
| REP-003 | P0 | Trust | Slum Fires | `06-publication-checklist.md`, RELEASE_NOTES | "Approved by System Administrator (Pair-Programming Turn)"; author = Gemini Flash | File text | AI self-sign-off | Contradicts AI policy | Human-gate record required |
| REP-004 | P1 | Evidence | Slum Fires | `content/pages/slum-fires.body.html` | Zero external citations; legal ruling without case reference | Full-text scan | Uncited load-bearing claim | Legal exposure; verification impossible | Owner: add citation or unpublish claim |
| REP-005 | P1 | Evidence | IM/LB/PP | `/data/*` links | 2 artifacts private-referenced, 2 nonexistent | Repo search across 3 repos | Broken verification promise | Credibility | Publish or de-link (owner) |
| REP-006 | P1 | Trust | IM/LB/SF | git `36177f6`, `ffdf1b1`, `be5785f`, `9e73d50` | Substantive post-publication changes; log empty | Git diffs | Corrections doctrine breach | Trust claim falsifiable by history | Owner: log qualifying entries |
| REP-007 | P1 | UX | Slum Fires | public page vs `9e73d50` | Drawer promise text present; drawer JS absent | Diff Jun3→Sep2 builds | Dead verification affordance | Reader promise broken | Restore drawer (git) or remove promise |
| REP-008 | P1 | Data | Blood Routes | report 47% vs `blood_routes_accidents.json` | Dataset: 5.8% pedestrian-involved Dhaka deaths | Recomputed 87/1,512 | Claim/data mismatch uncaveated | Mislead | Caveat or re-basis the claim (owner) |
| REP-009 | P1 | Data | PP | `analysis.json` vs `epcs_data.js` | 268/May–Dec-25 vs 480/Nov25–Jun26 auto-gen | Both files read | Methodology note false | Data-integrity | Owner: rewrite methodology note or restore matching dataset |
| REP-010 | P1 | Evidence | Impunity | master xlsx | Private file, public 404 link | Repo locations | Verification gated on private artifact | Asymmetry | Publish digest or de-link |
| REP-011 | P2 | Trust | All | manifests + homepage | Source counts without definition; 127-sum stat | Grep: no definition anywhere | Nominal trust stat | Misleading | Define + publish basis |
| REP-012 | P2 | Data | Lead Belt | hero/meta | "extreme risk" framing vs own bounds (24,650–50,750; unique 33,275) | STUDENT_ESTIMATE_AUDIT + methodology page | Framing outruns estimate | Overclaim risk | Owner: align hero framing |
| REP-013 | P2 | Accessibility | Impunity | inline styles | 0.42–0.55rem chart text; no chart alternatives | CSS in report page | Mobile/a11y failure | Unreadable charts | Presentation repair (Phase-3 work) |
| REP-014 | P2 | Data | Slum Fires | key_findings + page | n=4 "clear correlation"; 16.2% hero without data | Recomputed r=−0.845, n=4 | Overclaim | Statistical misuse | Owner: soften or substantiate |
| REP-015 | P2 | Governance | Slum Fires | `build.py:200`, `69f4b13` | Hardcoded homepage exclusion; no rationale doc | Code + git | Stealth delisting | Institutionalized | Policy decision + manifest status |
| REP-016 | P3 | Metadata | All | manifests | Tier labels don't match published taxonomy; date conflicts | Files read | Taxonomy drift | Reader can't verify tier | Standardize labels (owner) |
| REP-017 | P4 | Technical | PP | views/*.html | Title-less partials etc. | Phase-1/2 reports | WAIT item | — | Owner decision pending |

## 24. What Is Strong and Should Be Preserved

1. **The Impunity Machine's raw→script→published chain** — the bureau's proof of concept that its own standard is achievable. Preserve and make it the template.
2. **The Lead Belt self-audit suite and its published methodology reconciliation** — hostile-peer-review culture that delayed publication; rare and valuable.
3. **Claim-numbering discipline** (slum-fires' 13-claim ledger; impunity's claim data-ids) — the substrate a real claim registry can build on.
4. **Honest hero labeling where it exists** ("WHO modelled estimate"; "visual indicators of activity"; tool named for satellite classification).
5. **Real raw-data archiving where it exists** (blood-routes raw_collection with download script; impunity xlsx manifest).
6. **The methodology pages as a genre** — reconstruction-grade, not boilerplate.
7. **The corrections doctrine text itself** — the standard is right; the practice must be made to match it.

## 25. What Requires Editorial Decision

All of §17–20 "Required owner decisions" — consolidated in `OWNER_DECISIONS_REQUIRED.md` (this phase's companion document). None were implemented silently; all are flagged.

## 26. What Can Be Improved Technically (presentation-only, this phase)

Per-claim source-basis labels; restoration of the slum-fires claim drawer from git; surfacing the draft's limitations text; hero-number "how this was calculated" affordances; evidence-download status honesty (label private/missing rather than 404); chart text-size floors and data-table fallbacks; NewsArticle JSON-LD standardization; source-count definition published. Implemented subset documented in `REPORT_IMPLEMENTATION_COMPLETION.md`.

## 27. What Should NOT Be Changed

- Any claim, number, quote, finding, date, or methodology statement (all flagged, none altered).
- The investigations' prose and narrative structure.
- Verification tiers (owner-only).
- The corrections record (owner-only; this audit creates no entries).
- The website infrastructure architecture (frozen).
- The homepage suppression decision (owner policy call; my Phase-2 code carried it forward — flagged REP-015, not silently changed either way).

## 27a. Final Scorecard
|---|---|---|---|---|---|---|---|---|---|---|---|
| Blood Routes | 4 | 5 | 5 (dataset) / 2 (claims) | 5 | 4 | 3 | 5 | 7 | 3 | 4 | **4.3** |
| The Impunity Machine | 6 | 7 | 6 | 7 | 6 | 5 | 6 | 8 | 5 | 6 | **6.2** |
| The Lead Belt | 6 | 5 | 3 | 8 | 5 | 6 | 7 | 8 | 4 | 6 | **5.8** |
| Dhaka Slum Fires | 2 | 2 | 1 | 3 | 2 | 2 | 3 | 6 | 1 | 2 | **2.4** |
| **Overall report-system score** | | | | | | | | | | | **4.7 / 10** |

**Explanation of scores (not arbitrary):**
- **Blood Routes (4.3):** the dataset-side forensics are the bureau's best work (dedup/padding/crosstabs reproduce to the decimal — Data Integrity 5 among investigations), and the in-page evidence tiering is a genuine strength; but the headline is unverifiable and was swapped in on publication day, one false headline stat was silently corrected, and macro numbers are name-dropped without retrievable citations (traceability/verifiability 3–4).
- **Impunity Machine (6.2):** the only investigation with a complete raw→script→published chain (private), honest per-figure sourcing, and a tracker that re-derives from public JSONs; held back by the private master file behind a dead public link, unverifiable source count (manifest 91 vs archived registry 65 — re-verified by lead auditor), and unreadable mobile chart text.
- **Lead Belt (5.8):** the most transparent methodology and the most honest self-audit culture in the bureau, with a fully verified display layer (every embedded number reproduces); but the reproducibility promise is factually false (all downloads dead), the snapshot contradicts the headline, and one page carries five inconsistent numbers — transparency 8, reproducibility 3.
- **Slum Fires (2.4):** coherent narrative and disciplined claim numbering cannot offset a fabricated verification chain, an uncited legal core, hero metrics without data, and AI-signed sign-off. Not defensible as published.
- **System 4.7:** the pattern across investigations is consistent — strong analysis and honest internal audit culture, undermined at the publication boundary (evidence links, snapshot freezes, corrections record, headline discipline). The bureau's problems are overwhelmingly *publishing-and-record* problems, not journalism problems: fix the boundary and the scores rise sharply without touching a single finding.

- Any claim, number, quote, finding, date, or methodology statement (all flagged, none altered).
- The investigations' prose and narrative structure.
- Verification tiers (owner-only).
- The corrections record (owner-only; this audit creates no entries).
- The website infrastructure architecture (frozen).
- The homepage suppression decision (owner policy call; my Phase-2 code carried it forward — flagged REP-015, not silently changed either way).

## 28. Final Trust / Verification Assessment

- Can a serious reader trace the work? **Impunity: partially (arithmetic yes, inputs no). Lead Belt: yes, with definitional caveats honestly published. Blood Routes: no for headline claims, yes for the map. Slum Fires: no.**
- Does the bureau's own standard hold? Impunity and Lead Belt largely hold; Blood Routes holds for sourcing but not for published-data alignment; Slum Fires fails its tier outright.
- Is the trust apparatus (corrections, AI disclosure, methodology) honest? The *text* is exemplary; the *record* has gaps (unlogged amendments, AI-signed sign-off, private-referenced evidence).
- System status: **SIGNIFICANT VERIFICATION GAPS** — driven by one failing investigation, one false methodology note, systemic gating/corrections failures, and an evidence system that promises more than it delivers.

## 29. Recommendations for the Next Phase (order)

1. **Owner decision pass** (OWNER_DECISIONS_REQUIRED.md) — evidence publication, slum-fires status, corrections entries, PP classification, hero framings. Everything downstream depends on these.
2. **Fail-closed publication gate** (RC-1/2): artifact-existence + hash + link-resolution checks; no PASS-with-warnings; human sign-off field that can't be self-signed.
3. **Corrections backfill** (RC-3): log the qualifying historical entries (owner-authored).
4. **Claim registry** (RC-2): manifest-declared per-claim sources, rendered on-page; source-count definition.
5. **Evidence system activation**: publish or de-link each artifact; per-artifact provenance cards.
6. **Presentation repairs** (implemented subset this phase; remainder post-decisions).
7. **Tier taxonomy alignment** and manifest date corrections.

## 30. Audit Limitations

- **Impunity Machine and Blood Routes agent audits delivered in full; Lead Belt agent re-launched (first run was rate-limited) and consolidating.** Impunity headline findings were independently re-verified by the lead auditor (chain inspection, data re-derivation); Blood Routes findings were spot-re-verified (dataset recomputation, pipeline doc reads, git log confirmation). Any late-arriving Lead Belt details will be appended in a revision note rather than silently merged.
- External third-party figures (WHO 31,578; BRTA 5,480; RSF/BJKS Eid counts; UNICEF MICS; APSS 275) were NOT re-verified against their original publications — the audit verifies that they are cited and attributed, not that they are true.
- `Anik_OS` was not audited (not authorized); `trial` excluded per contract.
- BD-INV-005/006/007 exist in the OS repo as pipeline folders/assets (007 has CSV evidence tables) but are not published; they were inventoried, not audited.
- No Lighthouse/SEO tooling runs; SEO findings are implementation-quality assessments.
- Financial/ledger verification of PP data beyond the 268/480 and ratio checks was out of scope.

---

*Phase 3 forensic audit complete. No journalistic content was modified. Companion documents: `OWNER_DECISIONS_REQUIRED.md`, `REPORT_SYSTEM_ARCHITECTURE_PHASE_3.md`, `REPORT_VISUALIZATION_STRATEGY.md`, `REPORT_SEO_AUDIT.md`, `REPORT_IMPLEMENTATION_COMPLETION.md`, `REPORT_AUDIT_HANDOFF_NEXT_PHASE.md`, `docs/phase3/VISUAL_RESEARCH_NOTES.md`.*
