# Insight Gaps Bureau — Report Audit Input Requirements

**Prepared:** 2 September 2026, at the close of Phase 2 (website execution)
**Purpose:** Define exactly what the Phase 3 investigation/report forensic audit needs — no more, no less — so the next session can begin without repository guessing.

Do **not** provide anything listed under "DO NOT NEED / DO NOT PROVIDE" below.

---

## 1. Repositories required

| Repository | Location (current machine) | Why required | Priority |
|---|---|---|---|
| **Website repo** (`insightgaps.github.io`) | `C:\Users\User\Desktop\Insightgaps\insightgaps.github.io-main\insightgaps.github.io-main` | Contains the published investigation/report pages (the presentation layer under audit), manifests, corrections log, and the frozen-report source documents | **Required** — already present |
| **`assets` repo** (raw evidence datasets) | `C:\Users\User\Desktop\Insightgaps\assets` | Contains the raw BD-INV-001/003/007 evidence files (xlsx/pdf) that published report claims reference. The audit must check whether public claims trace to these artifacts | **Required** — already present locally |
| **OS repo** (`insightgaps-os-main`) | `C:\Users\User\Desktop\Insightgaps\insightgaps-os-main` | The investigation production pipeline (datasets, `scheduled_pipeline.yml`, intelligence/analysis working files). Needed to test claim-vs-pipeline consistency and to locate analysis notebooks/derived data | **Required** — already present locally |
| `Anik_OS` vault | `C:\Users\User\Desktop\Insightgaps\Anik_OS` | **Only if the owner chooses to include it.** Contains career/personal operations material (01_Investigations, 04_Career, 05_Consulting). Relevant *only* to verifying investigation working files and their provenance; must never be published or quoted publicly. Provide only if the owner consents to its use as private audit context | Optional (owner consent) |

## 2. Why each matters (audit logic)

- The website repo shows **what is claimed and how it is presented**.
- The assets repo shows **whether the underlying evidence exists and matches** (file names, versions, structure).
- The OS repo shows **how the numbers were produced** (pipeline, methodology, intermediate datasets).
- The report audit's core test — "can a serious reader verify the work?" — requires all three to cross-reference claims → data → method.

## 3. What directories matter (website repo)

- `content/investigations/<slug>/report.html` + `methodology*.html` + `detailed.html` + `tracker.html` — the report presentation pages (primary audit surface)
- `content/investigations/<slug>/investigation.json` — claims/manifests (key_findings, source_count, dates, tiers)
- `corrections.log.jsonl` — corrections state (currently empty; must be cross-checked with any correction text found in reports)
- `content/pages/trust-*.body.html` — trust apparatus text (methodology, AI-use, corrections policy) against which per-work pages must be consistent
- `public/` is generated output — audit source, not the generated tree

## 4. What files matter (assets/OS repos)

- `assets/BD-INV-001/**`, `BD-INV-003/**`, `BD-INV-007/**` — raw evidence files, especially any matching the five published download references:
  - `BD-INV-002_Master_Evidence_File.xlsx`
  - `BD-INV-003_LeadBelt_MasterDataset_v5.csv` / `.xlsx`
  - `PP-ANA-001_PropertyPreservation_MasterDataset.xlsx`
  - `osm_schools.geojson`
- OS repo: investigation datasets, analysis scripts/notebooks, `scheduled_pipeline.yml`, any claim inventories or method papers referenced by report pages (e.g., `lead-belt-method-paper.md` referenced in the manifest)

## 5. What data matters

- Point-level datasets behind each investigation's headline numbers (blood-routes accident records; lead-belt site/school coordinates; impunity-machine case/conviction data; slum-fires fire/land-value series)
- Any derived aggregates the report pages display (the audit checks derivation trail: raw → derived → published number)

## 6. What assets matter

- Infographics (`assets/img/*-infographic.png`) — do the images' numbers match the text's numbers?
- Satellite proof imagery (`content/investigations/the-lead-belt/satellite_proof/**`) — are visual claims annotated and sourced?
- Maps' underlying geojson (`bangladesh.geojson`, `osm_schools.geojson`) vs map claims

## 7. What metadata matters

- Publication dates (manifest `date_published` vs dates stated in report text vs OS-repo file timestamps)
- Verification tiers (`investigation_type`) vs what the tier standard in `/trust/methodology/` says a tier requires
- Source counts (`source_count`) vs countable citations/sources in the reports

## 8. What historical material matters

- Git history of report pages (what was corrected/changed post-publication — relevant to the corrections-policy claim "logged permanently")
- `docs/publication/*` files already in the website repo (claim inventories, data audits, method reconstructions for the Impunity Machine and Lead Belt) — these are pre-existing self-audits the Phase 3 audit should verify rather than duplicate

## 9. What should remain private (never published, never quoted verbatim)

- Everything in `Anik_OS` (personal/career/consulting material)
- Source-identifying details of any kind (the website content model intentionally cannot express sources; keep it that way)
- Raw evidence whose publication could endanger sources or ongoing work — the Phase 3 audit should classify each artifact: publishable / withhold / partial

## 10. What should NOT be provided

- The `trial` repo (empty; rolled-back React experiment — irrelevant to the journalism)
- Any cloud credentials, API keys, or account access
- Duplicates of anything already in the three local repositories above
- Web-hosting configuration beyond what is already in the website repo

## Open owner inputs that materially improve the audit (also listed in the completion report)

1. Intended publication status of the five owner-held evidence downloads (publish files / remove links)
2. Editorial intent for `property-preservation` (journalism product vs consulting tool) — determines whether its reports are in scope for a *journalism* audit
3. The AI-training stance decision (CC BY 4.0 vs `ai-train=no` robots policy) — currently robots.txt is generated plain (`Allow: /`); restoring the documented Cloudflare content-signals policy is a one-line config change once decided
