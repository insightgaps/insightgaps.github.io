# Fact-Check & Bulletproof Audit Matrix

**Investigation Slug:** `{{SLUG}}`  
**Fact Checker:** Agent 04 (Adversarial Auditor)  
**Date Audited:** {{YYYY-MM-DD}}  
**Audit Verdict:** `{{PASSED / PASSED WITH REVISIONS / FAILED}}`  

---

## 1. Primary Metrics Independent Recalculation

Every quantitative finding must be independently re-computed via an alternative script/environment:

| Finding ID | Primary Metric Description | Analyst Result (Agent 03) | Auditor Result (Agent 04) | Discrepancy | Audit Verdict |
| :--- | :--- | :--- | :--- | :---: | :---: |
| **M-01** | {{METRIC_DESCRIPTION_1}} | {{VALUE_1}} | {{RECALCULATED_1}} | `0.00%` | **MATCH** |
| **M-02** | {{METRIC_DESCRIPTION_2}} | {{VALUE_2}} | {{RECALCULATED_2}} | `0.00%` | **MATCH** |
| **M-03** | {{METRIC_DESCRIPTION_3}} | {{VALUE_3}} | {{RECALCULATED_3}} | `0.00%` | **MATCH** |

---

## 2. 25-Row Random Sample Audit (Source-Tracing)

Random sample drawn from `data/processed/{{SLUG}}/`:

| Sample # | Record ID | Processed Value | Primary Source Document Reference | Raw Document Value | Parity |
| :---: | :--- | :--- | :--- | :--- | :---: |
| 01 | `{{REC_ID_01}}` | `{{PROC_VAL_01}}` | Gazette No. {{NO}}, Page {{PG}} | `{{RAW_VAL_01}}` | **VERIFIED** |
| 02 | `{{REC_ID_02}}` | `{{PROC_VAL_02}}` | BBS Report Table {{TBL}}, Page {{PG}} | `{{RAW_VAL_02}}` | **VERIFIED** |
| ... | ... | ... | ... | ... | ... |
| 25 | `{{REC_ID_25}}` | `{{PROC_VAL_25}}` | DoE Spatial Survey Point {{PT}} | `{{RAW_VAL_25}}` | **VERIFIED** |

---

## 3. LaFleur Bulletproofing Verification Sign-off

- [x] **Row Count Bounds:** Verified that record counts do not reflect database truncations.
- [x] **Summary Re-check:** Verified that column totals match official published summary tables.
- [x] **Identifier & Categorical Clusters:** Audited `GROUP BY` outputs for misclassified administrative units.
- [x] **Missing Field Audit:** Verified that missing entries reflect true zeros or non-reporting.
- [x] **False Precision Audit:** Verified that values avoid misleading decimals (e.g. integer casualties, rounded multiples).
- [x] **Lurking Variable Check:** Tested whether population density, daytime traffic volume, or reporting frequency drives the rate.
- [x] **Snapshot Date Freeze:** Verified that dataset has a fixed historical cut-off date: `{{CUTOFF_DATE}}`.

---

## 4. Audited Claim Register & Assigned Grades

| Claim ID | Verified Narrative Claim Text | Exact Citation / Primary Source | Assigned Grade |
| :--- | :--- | :--- | :---: |
| **C-01** | "{{EXACT_TEXT_OF_CONFIRMED_CLAIM_1}}" | {{FULL_PUBLIC_CITATION_1}} | **Confirmed** |
| **C-02** | "{{EXACT_TEXT_OF_CONFIRMED_CLAIM_2}}" | {{FULL_PUBLIC_CITATION_2}} | **Confirmed** |
| **C-03** | "{{EXACT_TEXT_OF_SUPPORTED_CLAIM_3}}" | {{FULL_PUBLIC_CITATION_3}} | **Supported** |
| **C-04** | "{{EXACT_TEXT_OF_PROBABLE_CLAIM_4}}" | {{FULL_PUBLIC_CITATION_4}} | **Probable** |

*Only claims graded Confirmed, Supported, or Probable may appear in the final report.*
