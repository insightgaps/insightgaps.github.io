# Lead Belt (BD-INV-003) Release Checklist

## 1. Live URLs
*   **Visual Investigation Index Page:** `https://insightgaps.com/content/investigations/the-lead-belt/`
    *   *Alternative path:* `https://www.insightgaps.com/content/investigations/the-lead-belt/index.html`
*   **Website Main Homepage:** `https://insightgaps.com/`

## 2. Methodology URL
*   **Spatial & Proximity Methodology Note:** `https://insightgaps.com/content/investigations/the-lead-belt/methodology.html`
    *   *Features:* Styled using design tokens, contains collapsible LaTeX math expressions, the raw Overpass Query CLI block for replication, and the study's metadata registration card.

## 3. Dataset URLs
All evidence files are registered on the [Data Repository](https://insightgaps.com/data/) index page:
*   **Master Excel Dataset (v5):** `https://insightgaps.com/data/BD-INV-003_LeadBelt_MasterDataset_v5.xlsx`
*   **Master CSV Dataset (v5):** `https://insightgaps.com/data/BD-INV-003_LeadBelt_MasterDataset_v5.csv`
*   **OSM Bangladesh School Nodes (GeoJSON):** `https://insightgaps.com/data/osm_schools.geojson`
*   **OSM School-Site Proximity Intersections (CSV):** `https://insightgaps.com/data/osm_intersections.csv`
*   **Methodology Spatial Calculation Script (Python):** `https://insightgaps.com/methods/analyze.py`

## 4. Sitemap Status
*   **Status:** Verified & Updated
*   **File:** [sitemap.xml](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/sitemap.xml)
*   **Registered Entries:**
    ```xml
    <url>
      <loc>https://insightgaps.com/content/investigations/the-lead-belt/</loc>
      <lastmod>2026-05-25</lastmod>
      <priority>0.9</priority>
    </url>
    <url>
      <loc>https://insightgaps.com/content/investigations/the-lead-belt/methodology.html</loc>
      <lastmod>2026-05-25</lastmod>
      <priority>0.8</priority>
    </url>
    ```

## 5. Final Publication Status
*   **Internal Investigation Archive (insightgaps-os):** Sealed and frozen at commit `1f95873 Archive BD-INV-003 final publication package`. Tagged with release candidate tag `BD-INV-003_RELEASE_CANDIDATE_v1` and pushed to remote origin.
*   **Public Presentation (insightgaps.github.io-main):** Fully implemented with visual journalism features (map scrollytelling, satellite basemap toggle, zoom-16/18 tabbed verification panel for featured sites `BD-4591` and `BD-4802`, metric cards, "How Built" pipeline, and downloads grid). Pushed successfully to the remote repository.
*   **Build Verification:** Verified locally on port 8000 using headless Chrome with zero console errors or ReferenceErrors. Checked layouts for responsive rendering on desktop, tablet, and mobile viewport simulations.
*   **Final Release Commit Hash:** `b56631b89c061b7f2f712ac4370a637edac3feb2`
*   **Remote Deployment Status:** Synchronized with the production origin and live on GitHub Pages.
