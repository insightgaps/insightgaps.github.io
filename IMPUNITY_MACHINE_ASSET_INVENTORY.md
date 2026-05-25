# Impunity Machine (BD-INV-002) — Legacy Asset Inventory

**Date of Inventory:** May 25, 2026  
**Investigation ID:** BD-INV-002  
**Source Repository:** `C:\Users\Administrator\Desktop\old_insightgaps.github.io-main\insightgaps.github.io-main`  
**Target Repository:** `c:\Users\Administrator\Desktop\insightgaps.github.io-main\insightgaps.github.io-main`

---

## 1. Inventory of Report Pages

| File Name | Path in Source Archive | Size (Bytes) | Purpose / Description |
| :--- | :--- | :--- | :--- |
| `index.html` | `investigations/national/impunity-machine/index.html` | 186,401 | Main data investigation report page. Contains 10 chapters on the conviction gap, backlog crisis, legal architecture, geography, access, global context, deterrence theory, witness protection, evidence reforms, and the 2025 post-revolution surge. |
| `visual.html` | `investigations/national/impunity-machine/visual.html` | 108,084 | Scrollytelling visual story using HTML5 Canvas (`dotCanvas` for funnel), interactive clock animations, Section 17 inversion bars, global comparison race bars, and a Leaflet-based IPV division map. |
| `tracker.html` | `investigations/national/impunity-machine/tracker.html` | 63,423 | Live monitoring station that tracks recent findings, the post-revolution surge monitor, a monthly data record ledger, a witness protection watch list, and a DNA backlog monitor. |
| `methodology.html` | `series/impunity-machine/methodology.html` | 23,199 | Detailed methodology document (v2.1) explaining evidence tiers, conviction rate ranges, the Probability of Punishment model formula, source conflicts, and the 12 gaps. |
| `data.html` | `series/impunity-machine/data.html` | 10,767 | Data repository page providing public downloads for Excel evidence files, JSON cases, monthly records, and automated press leads. |

---

## 2. Inventory of Datasets

| File Name | Path in Source Archive | Size (Bytes) | Purpose / Description |
| :--- | :--- | :--- | :--- |
| `BD-INV-002_Master_Evidence_File.xlsx` | `data/BD-INV-002_Master_Evidence_File.xlsx` | 92,924 | Master Excel evidence sheet containing 10 worksheets (README, statistics, conviction rates, tribunal cases, acquittals, Section 17, timeline, forensics, source registry, and confirmed absent gaps). |
| `cases.json` | `data/cases.json` | 10,166 | JSON case registry tracking timeline, status, and sources of prominent WCRPA and Section 17 cases. |
| `leads.json` | `data/leads.json` | 4,993 | JSON file tracking automated news leads harvested from press feeds. |
| `monthly.json` | `data/monthly.json` | 15,768 | JSON file storing monthly aggregate case filings, OCC visitors, verdicts, and convictions since 2019. |

---

## 3. Reusable Layout & System Assets

| File Name | Path in Source Archive | Size (Bytes) | Purpose / Description |
| :--- | :--- | :--- | :--- |
| `style.css` | `style.css` | 11,578 | Global styles for layout, theme-toggle colors, typography, nav, and card grids. |
| `theme-toggle.js` | `theme-toggle.js` | 1,554 | Javascript helper managing the client-side dark/light mode toggle. |
| `components.js` | `js/components.js` | 17,092 | Component loader responsible for injecting shared header and footer HTML blocks. |
| `ui.js` | `js/ui.js` | — | Global UI utility helper. |
| `CNAME` | `CNAME` | 15 | Custom domain mapping (`www.insightgaps.com`). |
| `favicon.png` | `favicon.png` | 36,889 | Browser tab icon. |
| `logo.png` | `logo.png` | 106,713 | Insight Gaps wordmark logo asset. |
| `scene-01-silence.png` | `scene-01-silence.png` | 8,334,386 | Uncompressed 8MB visual asset sitting in the legacy root directory. |

---

## 4. Critical Gaps & Missing Assets

### A. Missing Graphic Assets
The legacy HTML and CSS codes contain references to images that are completely missing from the old repository folder:
1.  **`investigations/national/images/impunity-machine/hero-cover.jpg`**: Main illustration used for the data investigation hero cover. Not found in `investigations/national/images/` or any subfolders.
2.  **`investigations/national/images/impunity-machine/scene-07-reckoning.png`**: Background illustration used in `visual.html` for the closing reckoning scene. Not found in the source directory.

### B. Structural Gaps
1.  **Chittagong Hill Tracts Coordinates**: While Chapter 5 discusses the intersectional vulnerability of indigenous women in the Chittagong Hill Tracts (CHT) citing 17 rape cases from SHARE-Net, no specific geo-coordinates or CHT map overlay data are provided in the source datasets.
2.  **DNA Laboratory Data Breakdown**: Forensics capacity is discussed in I-05, citing NFDPL's 19-year backlog. However, no independent CSV tracking district-by-district processing delay was archived.
