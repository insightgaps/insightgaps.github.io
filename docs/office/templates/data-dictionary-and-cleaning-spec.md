# Data Dictionary & Cleaning Specification (Data Diary)

**Investigation Slug:** `{{SLUG}}`  
**Data Analyst:** Agent 03 (Forensic Data Desk)  
**Date Generated:** {{YYYY-MM-DD}}  
**Processing Environment:** Python / PowerShell / SQLite  

---

## 1. Raw Data Provenance & Cryptographic Hashes

Raw files stored immutably in `data/raw/{{SLUG}}/`:

| Raw Filename | Source Agency | Date Downloaded | Original URL | SHA-256 Checksum |
| :--- | :--- | :--- | :--- | :--- |
| `{{RAW_FILE_1}}` | {{AGENCY_1}} | {{DATE}} | `{{URL_1}}` | `{{SHA256_HASH_1}}` |
| `{{RAW_FILE_2}}` | {{AGENCY_2}} | {{DATE}} | `{{URL_2}}` | `{{SHA256_HASH_2}}` |

---

## 2. Transformation Pipeline & Data Diary

Document every script and transformation step sequentially:

### Step 1: Ingestion & Encoding Normalization
- **Script:** `scripts/{{SLUG}}_01_ingest.py`
- **Actions:** Converted legacy Windows-1252 / ASCII to UTF-8 without BOM. Cleaned null byte characters.

### Step 2: Categorical Clustering & Normalization
- **Actions:** Standardized district and upazila names against BBS 2022 Census geocodes.
- **Transliteration Mapping Table:**
  - `{{ORIGINAL_NAME}}` -> `{{STANDARDIZED_NAME}}`

### Step 3: Deduplication & Exclusions
- **Rows Ingested:** {{RAW_ROW_COUNT}}
- **Duplicate Rows Removed:** {{DUPLICATE_COUNT}} (Reason: cross-join artifact)
- **Outlier Exclusions:** {{OUTLIER_COUNT}} (Criteria: {{CRITERIA}})
- **Final Clean Rows:** {{CLEAN_ROW_COUNT}}

---

## 3. Data Dictionary for Processed Tables

**Processed File:** `data/processed/{{SLUG}}/{{PROCESSED_FILE}}.csv`

| Column Name | Data Type | Nullable | Definition | Valid Range / Example |
| :--- | :--- | :---: | :--- | :--- |
| `record_id` | String | No | Unique primary key | `"BR-2025-00124"` |
| `district_geo` | String | No | BBS 4-digit district code | `"2648"` |
| `event_date` | Date (ISO) | No | Date of recorded event | `"2025-04-12"` |
| `statutory_limit` | Float | No | Statutory limit value | `400.0` |
| `measured_value` | Float | No | Empirically measured value | `681000.0` |
| `exceedance_ratio`| Float | No | Measured / Statutory ratio | `1702.5` |

---

## 4. Key Calculation Outputs & Denominators

| Metric Name | Numerator | Denominator | Calculated Value | Formula / Method |
| :--- | :--- | :--- | :--- | :--- |
| **{{METRIC_1}}** | {{NUM_VALUE_1}} | {{DENOM_VALUE_1}} | **{{RESULT_1}}** | `{{FORMULA_1}}` |
| **{{METRIC_2}}** | {{NUM_VALUE_2}} | {{DENOM_VALUE_2}} | **{{RESULT_2}}** | `{{FORMULA_2}}` |

---

## 5. Institutional Data Voids & Limitations

- **Omission 1:** {{DESCRIPTION_OF_MISSING_SUBSET}}
- **Denominator Constraints:** {{DOCUMENTED_DENOMINATOR_LIMITATION}}
