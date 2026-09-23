# Insight Gaps Bureau — Owner Decision Packet (Phase 5)

**Date:** 3 September 2026 · **For:** owner/editor decision pass
**Rule applied:** no decision below has been implemented; every option is safe to choose. Evidence for each fact is in `REPORT_FORENSIC_AUDIT_PHASE_3.md` (§ references). D-4 is already resolved (Slum Fires unpublished) and verified absent from output.
**Hierarchy used for recommendations:** evidence integrity > truthful disclosure > reproducibility > correction transparency > reader understanding > UX polish.

---

## D-1 — Blood Routes silent correction (P0)

| Field | Content |
|---|---|
| **Verified facts** | The night-crash statistic published as **97.13%** (~2026-05-28) was changed to **41.56%** on **2026-06-08** (website commit `527d0a4`, message: "correct night-time accident percentage claim from 97.13% to 41.56%"). The OS pipeline retracted the claim 2026-06-03 (`c57c283`) citing "synthetic padding artifacts" — i.e., the bureau knew the number derived from the 95%-padded dataset. The corrections log is **empty**; `has_correction: false`; `date_revised: null` |
| **Evidence** | Audit §6/§17 (BR-1b); git diffs `527d0a4`, `c57c283`; `corrections.log.jsonl` (header only) |
| **Problem/risk** | A false headline statistic was corrected after ~11–13 days live with no public record — a direct, provable violation of the bureau's published corrections doctrine ("corrections go up faster than the original publication went out") |
| **Option A** | Log it: append one corrections-log entry describing the 97.13%→41.56% change, set `has_correction: true` + `date_revised: 2026-06-08` in the manifest |
| **Option B** | Classify as a technical fix (no entry), on the argument that 97.13% was never a "verified" claim |
| **Recommended** | **Option A.** The evidence that a correction-class change occurred is unambiguous — the commit message itself says "correct". Option B is factually hard to defend given the bureau's own retraction language |
| **Consequences** | A: doctrine upheld; the record shows self-correction (strongest trust signal). B: any external reviewer finding `527d0a4` can accurately state the bureau corrected a false headline number silently |
| **Files affected** | `corrections.log.jsonl` (1 append), `content/investigations/blood-routes/investigation.json` (2 fields), generated corrections page + notices |
| **Correction-log entry required?** | Yes under Option A (that *is* the action) |

## D-2 — Blood Routes 351 headline + wrong 29% YoY (P0)

| Field | Content |
|---|---|
| **Verified facts** | "351 deaths, 15 days, Eid-ul-Fitr March 14–28, 2026" has **no archived source in any repository**; the public dataset has **zero 2025/2026 records** and no 15-day window sums to 351. Git shows it replaced "312 deaths/12 days/Eid-ul-Adha June 2025, 29% YoY surge" **on publication day** (`4499e8a` website, `6032db0` OS, 2026-05-26). The surviving 2025-Adha chart text still says **"29% YoY surge"** where (312−262)/262 = **19.08%** |
| **Evidence** | Audit §17 (BR-1), F-2/F-10; dataset recomputation (2,331 recs, 2022–2024 only); git logs |
| **Problem/risk** | The investigation's most visible number is unverifiable by any reader; a predecessor figure that *is* checkable is published and arithmetically wrong |
| **Option A** | Obtain + archive the RSF/BJKS Eid-2026 reports into the evidence system, label the hero's source basis, fix the 29%→19.08% figure (or re-source it) |
| **Option B** | Qualify the hero ("as reported by RSF/BJKS; underlying report not yet archived") + fix the 29% figure; archive when obtained |
| **Option C** | Remove/re-basis the headline until sourced |
| **Recommended** | **A if you hold the reports; B immediately otherwise.** The 29%→19.08% fix is required under every option — it is arithmetically wrong regardless of sourcing |
| **Consequences** | A/B: headline becomes verifiable-in-principle. C: safest externally but loses the story's peg. Doing nothing: the site's flagship road-safety number is unverifiable and an adjacent wrong figure is live |
| **Files affected** | Report hero text (content change — *not* done by agent), evidence refs (if archived), manifest dek/key_findings text; the 29% is in the 2025 chart description (content change) |
| **Correction-log entry?** | The 29% fix: yes (it changes a published figure). The 351 sourcing/qualification: owner judgment (qualification ≠ correction; re-basing is) |

## D-3 — Evidence artifacts: publish or de-link (P1)

| Artifact | Exists? | Where | Publishable? | Recommended |
|---|---|---|---|---|
| `BD-INV-002_Master_Evidence_File.xlsx` | Yes (private) | OS repo `topic-pipeline/the-impunity-machine/data/raw/` (checksum verified) | Owner call — contains case-level records | **Publish a provenance-preserving digest** (summary sheets, not raw case rows) pending source-protection review; else keep "private-held" label (already honest on-site) |
| `osm_schools.geojson` | Yes (private) | OS repo `datasets/lead-belt/` (9,846 nodes) | **Yes — public OSM snapshot, zero source risk, high verification value** | **Publish** (copy into website `data/`; the evidence-page label flips to available; validator warning clears) |
| Lead Belt `MasterDataset_v5.csv/xlsx` | **No — nowhere** | — (decision memo calls it "publication-ready") | n/a until located | **Locate and publish** — the report's replication command depends on it; until then the honest "not-in-repository" label stands (already on-site) |
| PP master dataset xlsx | **No** | — | n/a | Keep "not-in-repository" label; superseded by D-7's methodology-note fix |
| Impunity EV-001…005 registry paths | **No** (registry points to nonexistent `assets/BD-INV-002/`) | — | — | Owner: re-archive the five named primary documents (MoWCA, PHQ, NFDPL, BLAST, BRAC) to the real assets repo, or mark the registry entries unarchived |

**Correction-log entries?** Not corrections — publication actions. Evidence-page statuses already render honestly for every case, so no reader is misled either way.

## D-5 — Homepage suppression mechanism (P2, mooted for Slum Fires)

| Field | Content |
|---|---|
| **Verified facts** | The old hard-coded slug filter (`dhaka-slum-fires` excluded from homepage) was **removed in the Phase-4 merge**; the investigation is now absent because its manifest no longer exists (true publication status), not because of code suppression. All routes redirect 301 to `/investigations/`. Residual: nothing |
| **Recommended** | **Resolved mechanically.** Remaining policy note (optional): document the D-4 unpublish decision in one line in the investigation's place in the bureau's records. No site change required |

## D-6 — Corrections backfill (P1)

| Candidate change | Verdict (audit) | Entry? |
|---|---|---|
| Blood Routes 97.13%→41.56% | Correction-class (see D-1) | **Yes** (with D-1) |
| Impunity cross-country denominator disclosure (`36177f6`) | Changed how a published chart should be read | **Yes** — as a clarification entry (added post-publication) |
| Impunity hero rewording (`c8532e7`→`ee84986`) | Re-presentation of the flagship claim | Owner judgment; lean **yes** (clarification) |
| Lead Belt language-hardening (visual-indicators phrasing) | Pre-publication hardening in practice | **No** (publication date postdates the change in practice) |
| Slum Fires +420%→+250% between published versions | Superseded by D-4 (work unpublished) | **No entry needed** while unpublished |
**Implementation:** owner writes/approves the entries; agent then appends to `corrections.log.jsonl` (schema enforced: C-### monotonic IDs) → build auto-renders the log page + any per-work notices. Nothing has been backfilled.

## D-7 — Property Preservation classification + methodology note (P1)

| Field | Content |
|---|---|
| **Verified facts** | Published note: "268 work order records spanning May to December 2025, operator-provided accounting ledgers." Actual dataset: **480 records, Nov 2025–Jun 2026**, headed "**Auto-generated** EPCS dataset" (also: the "less than half reaches the bank" claim reads against a 53.9% collected ratio) |
| **Evidence** | Audit PP-1; `analysis.json` vs `epcs_data.js` (both read directly) |
| **Problem** | A published methods statement any reader with the data can falsify in one query |
| **Options** | A: rewrite the note to describe the real artifact. B: restore a matching (truly 268-record) dataset. C: describe it accurately as a demonstration dataset (if that's what it is) |
| **Recommended** | **A now** (fix the methods description regardless of classification — a false methods text is a defect under any label); classification (journalism vs tool vs product) decides its *home* later |
| **Consequences** | A/C: data-integrity defect resolved immediately. B: only if the real operator dataset exists. Classification can wait; the false note cannot |
| **Files** | `content/analysis/property-preservation/analysis.json` methodology_note fields; PP report pages' descriptions |
| **Correction-log?** | If the work is deemed "journalism," yes (a published methods claim changes). If tooling, no public corrections entry needed — just fix |

## D-8 — Lead Belt (P2/P1 cluster)

| Sub-issue | Verified facts | Recommended |
|---|---|---|
| Hero "39,875 children at extreme risk" | = 145 × 275 (intersections × avg enrollment); the bureau's own audit bounds it 24,650–50,750 and computes unique-count 33,275; methodology page publishes the reconciliation but the hero doesn't reference it | Pair the hero with the range/projection language **from your own methodology text** (framing choice, not new content) |
| "Closest school 59 m" | True for BD-4591 (58.8 m recomputed) but **three sites have closer schools** (BD-7303: 14 m) | Scope the claim to the featured site in one clause ("the closest school among the featured sites") or amend |
| Snapshot contradiction | Independent replication: 166 intersections / 51 sites / 125 unique schools vs published 145/44/121; the archived snapshot cannot reproduce the published numbers | Either re-freeze the correct snapshot + regenerate, or add a "figures locked to the March-2026 workbook analysis; the archived snapshot yields slightly different counts after OSM drift" note (the bureau's own reconciliation docs provide this language) |
| On-page contradictions | 26/19 satellite count, 68/65 critical, 507/93 upazilas, 58,000/39,875 students, ×400/×275 multipliers | Align to the embedded data (mechanical re-derivation, but each changes displayed values → editorial approval) |
| Manifest date 2025-01-01 | Git: first content 2026-05-23, publication 2026-05-25 | Correct the metadata date (factual, not editorial) |
**Correction-log?** Date fix: no (metadata). Number alignments: yes if any figure changes (each is a published-value change).

## D-9 — Impunity Machine

| Sub-issue | Verified facts | Recommended |
|---|---|---|
| Source count | Published **91** on every page + manifest; archived registry holds **65** (54 CONFIRMED / 11 PROBABLE); pages cite S-26/27/28 which don't exist in the registry | **Correct to 65** (the registry is the countable truth) + re-map or remove the three dangling citations. The on-site disclosure (Phase 4) already shows both counts, so no reader is misled meanwhile |
| Mobile typography | Micro-type was 4.4–10.4px; Phase-4 floor raised it to **11px ≤768px**; residual 20–40px overflow at ≤414px from inline-styled elements | Floor is in place and safe; the full fix (chart-geometry-preserving responsive rebuild) remains the owner-gated redesign. **Do not** widen the CSS override further — the prompt's section 21 rule applies and is documented in the CSS comment |

**Correction-log?** The 91→65 correction: yes (a published trust figure changes).

## D-10 — AI-training stance (P3)

| Field | Content |
|---|---|
| **Verified facts** | Content is licensed **CC BY 4.0** (which permits reuse incl. machine reuse under attribution) while the legacy robots.txt blocked AI training (`ai-train=no` + bot blocks); the current generated robots.txt is plain `Allow: /`. Two of the bureau's own instruments conflict |
| **Options** | A: keep the training-refusal, document it explicitly as overriding the license default for machine training (restore the Cloudflare content-signals block — one config line). B: align (allow training). C: leave plain robots (status quo — neither stance expressed) |
| **Recommended** | **A** — matches the bureau's evident prior intent; cost is one config line + a short trust-page note |
| **Correction-log?** | No (policy, not correction) |

## D-11 — Tier taxonomy (P3)

| Field | Content |
|---|---|
| **Verified facts** | Manifests use "Tier 1 - Visual Data / Tier 2 - Visual Spatial / Tier 2 - Spatial Overlay"; the published methodology page defines "Tier 1 Document-Heavy / Tier 2 Data-Driven / Tier 3 Source-Driven" — different taxonomies, so no reader can check a tier's obligations against the work |
| **Options** | A: publish the taxonomy the manifests actually use, with per-tier obligations. B: re-map manifest labels to the published three-tier system (changes what several tiers obligate — several works would shift obligations) |
| **Recommended** | **A** — it's the operative standard; the audits read against it naturally; no work's obligations change |
| **Correction-log?** | No (documentation alignment) |

---

## Ready-to-execute queue (mechanical, on your approval — in dependency order)

1. **D-1 + D-6 (approved entries)** → append corrections log + manifest flags → build auto-renders everything.
2. **D-9i** 91→65 + re-map dangling citations.
3. **D-8** number alignments + hero qualification + date fix (approve as a batch; each entry itemized before commit).
4. **D-2** 29%→19.08% + hero qualification (with or without report archiving).
5. **D-7** methodology-note rewrite.
6. **D-3** publish osm_schools.geojson (+ any located v5 dataset); digest of the impunity master file after your source-protection review.
7. **D-10** robots config line + trust note. **D-11** tier documentation page.
8. **Production:** apply the Cloudflare dashboard build config (the standing blocker) — after which every item above deploys on merge.

Each item is small; none has been pre-implemented. Say the word per item (or per batch) and it ships through the normal build → validate → browser-QA → commit gate.
