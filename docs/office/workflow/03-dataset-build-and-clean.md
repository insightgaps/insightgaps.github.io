# Workflow Stage 03: Dataset Build & Clean

**Stage:** 03 · Data Ingestion, Cleaning & Transformation  
**Owner:** Agent 03 (Data Analyst)  
**Input:** `docs/office/workspace/research/<slug>-research-plan.md`  
**Outputs:** `data/processed/<slug>/*.csv`, `docs/office/workspace/analysis/<slug>-data-spec.md`

---

## 1. Objectives

The Dataset Build & Clean stage transforms disparate public records into clean, audited, tidy relational tables. It establishes:
1. Immutability of raw source files.
2. An unbroken, scripted audit trail (the Data Diary).
3. Primary metric calculations, rate calculations, and data reconciliation models.
4. Quantification of institutional data voids.

---

## 2. Core Methodological Rules

- **Immutability Principle:** Files saved in `data/raw/<slug>/` are read-only. Never modify, overwrite, or re-save raw files.
- **Scripted Transformations Only:** Every cleaning operation must be performed via code (Python script, PowerShell pipeline, or SQL query). Never perform manual cell edits in Excel or Google Sheets.
- **Denominator Precision:** Every rate (e.g. deaths per 100,000, conviction rate, exceedance multiplier) must have an explicitly documented base population or case universe.
- **Encoding Standardization:** All output files must be encoded in UTF-8 without BOM.
- **Date Standardization:** All timestamps and dates must follow ISO-8601 (`YYYY-MM-DD` or `YYYY-MM-DDTHH:MM:SS+06:00`).

---

## 3. Step-by-Step Procedure

1. **Raw Acquisition & Cryptographic Hashing:**
   - Download public records into `data/raw/<slug>/`.
   - Calculate SHA-256 hash for each raw file and record in the Data Diary.

2. **Parsing & Cleaning:**
   - Extract tabular data from PDFs using `pdfplumber`, `tabula`, or `pdftotext` where applicable.
   - Clean column headers (lowercase, snake_case, no spaces or special characters).
   - Strip leading/trailing whitespace.
   - Reconcile transliteration drift across administrative units (e.g., standardizing Upazila and District names against the BBS Geocode catalog).

3. **Data Deduplication & Validation:**
   - Check for cross-join artifacts and duplicate rows.
   - Test column totals against published official summary tables. If totals do not match, document the discrepancy.
   - Isolate outlier values (e.g. impossible speeds, negative casualty counts, dates in the future).

4. **Primary Calculations:**
   - Calculate primary metrics:
     - Ratios (e.g., actual vs reported: $47,680 / 2,331 = 20.45\times$).
     - Exceedance multiples ($681,000 / 400 = 1,702.5\times$).
     - Backlog growth ($\Delta = \text{Filings} - \text{Disposals}$).
     - True conviction rates (convictions / total filed cases).
   - Test calculations against the Null Hypothesis.

5. **Deliverable Production:**
   - Save processed tidy tables in `data/processed/<slug>/`.
   - Compile the Data Diary and data specification using `docs/office/templates/data-dictionary-and-cleaning-spec.md`.
