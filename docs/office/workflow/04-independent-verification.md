# Workflow Stage 04: Independent Verification & Bulletproofing

**Stage:** 04 · Adversarial Auditing & Claim Grading  
**Owner:** Agent 04 (Fact Checker / Bulletproofer)  
**Input:** `docs/office/workspace/analysis/<slug>-data-spec.md` + `data/processed/<slug>/`  
**Output:** `docs/office/workspace/verification/<slug>-fact-check-matrix.md`

---

## 1. Objectives

The Independent Verification stage tests the findings through an adversarial, ProPublica-grade audit before any narrative writing begins.

The Fact Checker acts as a defense attorney seeking to dismiss the investigation's claims. If a calculation cannot be independently reproduced, or if a finding relies on unsupported assumptions, it is rejected or downgraded.

---

## 2. Verification Protocol

1. **Dual Computational Paths:**
   - The Fact Checker must write independent code (using a different environment, syntax, or tool) to reproduce every metric calculated by Agent 03.
   - Parity must be 100% exact.

2. **25-Row Random Sample Audit:**
   - A random sample of at least 25 processed rows is drawn.
   - Each row is traced back to its raw source document (the specific PDF page, gazette column, or satellite granule).
   - If even one data point is mistranscribed, the entire dataset is returned to Agent 03 for re-cleaning.

3. **Jennifer LaFleur Bulletproofing Checklist Execution:**
   - **Row Count:** Are there artifact boundaries (65,536, 1,000)?
   - **Column Sums:** Do the individual rows add up to the published total?
   - **Spelling / Categories:** Did `GROUP BY` reveal misclassified entities?
   - **Missing Data:** Are blank fields true zeros or unrecorded observations?
   - **False Precision:** Are decimal values rounded to scientifically defensible levels?
   - **Confounding Variables:** Did the analyst control for population scale or vehicle registration volume before claiming a rate anomaly?
   - **Cut-off Freeze:** Is there a fixed historical end-date?

---

## 3. Claim Grading Standard

Every factual claim intended for the final report is graded:

| Grade | Criteria | Action |
| :--- | :--- | :--- |
| **Confirmed** | Primary verified finding; dual-calculated; 100% source-traced. | Lead headline & stat callouts. |
| **Supported** | Grounded in official monitoring or reputable multilateral series. | Secondary narrative body. |
| **Probable** | High-confidence structural finding with physical corroboration. | Labeled with explicit limitations. |
| **Rejected** | Fails recalculation, lacks primary proof, or relies on speculation. | **Permanently eliminated.** |

---

## 4. Deliverable Production

- Output `docs/office/workspace/verification/<slug>-fact-check-matrix.md` using `docs/office/templates/fact-check-bulletproof-matrix.md`.
- Issue formal sign-off: `PASSED`, `PASSED WITH REVISIONS`, or `FAILED`.
