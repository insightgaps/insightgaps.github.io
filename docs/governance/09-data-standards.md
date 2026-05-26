# 09-data-standards.md — Master Data Standards Guide
**Version:** 1.0  
**Status:** Active  

This document defines the core technical, mathematical, and ethical standards for data engineering, cleaning, modeling, analysis, and visualization within the **Insight Gaps** bureau. All analytical workflows, scripts, datasets, and public visualizations must adhere strictly to these principles.

---

## 1. DATA Wrangling & CLEANING STANDARDS

Data cleaning is an investigative process. We treat "dirty" data not just as a technical hurdle, but as a potential story or systemic failure.

### A. Raw Data Preservation
1. **Immutable Raw Directory:** All raw data files downloaded or scraped must be stored under `/data/raw/` (or `topic-pipeline/[slug]/data/raw/`) and frozen immediately.
2. **Never Edit Raw Files:** Never modify, save, or edit raw files directly. Any changes—including correcting typo-filled columns—must occur programmatically.
3. **File Hash Logging:** Raw datasets must be logged with their SHA-256 hash inside `02-data-cleaning.md` to guarantee source integrity.

### B. Standard Cleaning Pipeline
All data transformations must be executed via reproducible Python scripts (using libraries like `pandas`, `numpy`, or `openpyxl`). The cleaning script must handle:
1. **Trim Whitespace:** Strip leading/trailing whitespaces and double spaces from all string columns.
2. **Standardize Case:** Case-sensitive values must be normalized (e.g. convert "dhaka", "Dhaka ", and "DHAKA" to "Dhaka").
3. **Standardize Date Formats:** Dates must be parsed and stored in strict ISO 8601 format (`YYYY-MM-DD` or `YYYY-MM-DDTHH:MM:SS`).
4. **Invalid Value Audits:** Numeric columns must be checked for impossible values (e.g. age = `-1`, speed = `999`). Replace with standard null markers (`NaN` or `None`), never arbitrary defaults like `0`.
5. **Duplicate Checks:** Deduplicate rows using primary compound keys. In road accident datasets, for example, verify if duplicate timestamps, latitudes, and vehicle profiles indicate double-reported incidents.

### C. The Missing Data Protocol
* **Do Not Guess:** Never fill missing numerical values (imputation) without a statistically validated model. If a field is blank, mark it as `Unknown`.
* **Disclose Omissions:** Document the percentage of null values for each column in the cleaning log. If a column has >20% missing values, it cannot be used to support primary quantitative claims.

### D. Version Control on Cleaned Outputs
Data cleaning is iterative. To ensure reliability and trace transformations:
1. **Never Overwrite Cleaned State:** Each cleaning run that introduces structural changes or major filtering must save its output with a versioned suffix (e.g., `accidents_v1_raw.csv` -> `accidents_v2_trimmed.csv` -> `accidents_v3_deduped.csv`).
2. **Maintain a Cleaning Changelog:** Every topic or investigation dataset directory under `data/cleaned/` must contain a `CHANGELOG.md` detailing what each cleaning version modified, which script generated it, and what anomalies were filtered.
3. **Rollback Capability:** If an error is discovered in cleaning logic, the pipeline should easily point back to the previous version `v(N-1)` without requiring re-scraping or raw recovery.

---

## 2. DATA MODELING & SCHEMAS

Proper data structures prevent errors and ensure that public frontend applications remain fast and reliable.

### A. Typed Declarations
All datasets compiled for analysis or website loading must have a documented schema:
* **Unique IDs:** Every record must have a unique identifier (e.g., `acc_2026_0001`).
* **Strict Type Safety:** Define fields as integer counts, float coordinates (e.g. `latitude: Float`), booleans (`is_highway: Boolean`), or categoricals.
* **Geospatial Coordinates:** Coordinate fields must follow standard WGS84 decimal degrees (latitudes: `-90.0` to `90.0`, longitudes: `-180.0` to `180.0`) and have at least 5 decimal places of precision.

### B. Relational Integrity & Normalization
* **Avoid Duplication:** Do not nest complex, repeating arrays inside simple CSV rows. Use normalized structures (e.g., a master `accidents.json` linked via `accident_id` to a detail `vehicles.json`).
* **Compact JSON Outputs:** For files loaded by frontend charts, minify JSON files and filter out unused columns to minimize loading overhead.

---

## 3. DATA ANALYSIS & ETHICAL STATISTICAL RULES

### A. Correlation vs. Causation
* **The Golden Rule:** Never state or imply that one variable caused another simply because they correlate.
* **Independent Controls:** If asserting an association (e.g. "highway fatalities increased after speed limits were raised"), verify if other factors (holiday travel volumes, weather conditions, or vehicle density) were controlled.

### B. Small Numbers & Rate Volatility
* **Beware the Small Denominator:** Districts or sub-districts with very small populations will naturally show massive, volatile swings in rate metrics (e.g. "fatalities per 100,000").
* **Threshold Rule:** Do not calculate rates for categories or regions with fewer than 10 total cases. Instead, present raw counts or combine categories to avoid misleading rate spikes.

### C. Generalization Boundaries
* **Sample Constraints:** Localized data (e.g., road safety audits in Dhaka) cannot be used to make claims about national trends unless the sample is statistically representative and weighted.
* **Acknowledge Bias:** If a dataset is built on media scanning (e.g., tracking accidents via newspaper reports), explicitly state that it represents "media-reported incidents" rather than absolute administrative totals, acknowledging bias towards major highways and urban centers.

---

## 4. DATA VISUALIZATION GUIDELINES

Visualizations must serve the data. We prioritize clarity, legibility, and technical correctness over decorative embellishment.

### A. Core Typographic Hierarchy
Our frontend layout relies on a fixed design token typography system:
* **Headers/Labels:** Space Grotesk (sans-serif) for high scannability.
* **Body/Explanations:** Lora (serif) for readability.
* **Values/Metadata/Legends:** Space Mono (monospaced) for aligned data columns.

### B. Visual Elements and Gridlines
* **Axes:** Always label axes clearly with units (e.g. "Fatality Rate (per 10,000 vehicles)"). Start numerical Y-axes at `0` for bar charts to prevent visual scaling distortions.
* **Colors with Intent:** Use a restricted color palette:
  - Background: Sleek, high-contrast dark backgrounds (`#0a0f1d`) or clean light surfaces (`#fcfdff`).
  - Accent: High-contrast amber (`#ffb703`) or red (`#d90429`) to highlight focus data points.
  - De-emphasized Data: Muted grey/slate for background trends or context.
* **No Rainbow Palettes:** Do not use decorative color scales that carry no quantitative meaning.

### C. Technical Requirements
* **Mobile Responsiveness:** All charts must scale dynamically. Avoid fixed pixel widths on canvas or SVGs. Ensure interactive touch areas (like map hotspots) are at least 44x44px.
* **Source Attribution:** Every chart, diagram, and map must have a visible caption identifying the source (e.g. `Source: BRTA Road Safety Division Audit (2025)`).
