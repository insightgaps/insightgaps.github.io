# LEAD_BELT_WEBSITE_UPGRADE_PLAN.md — Lead Belt Website Experience Upgrade Plan

* **Date:** 2026-05-25  
* **Investigation ID:** BD-INV-003 (The Lead Belt)  
* **Objective:** Transform *The Lead Belt* public website pages from a raw data release into a premium, world-class visual data journalism presentation.  
* **Benchmarks:** Reuters Graphics, Financial Times Visual Journalism, New York Times Visual Investigations, ProPublica, The Pudding.  

---

## Executive Summary

To achieve world-class status, the Lead Belt visual investigation must bridge the gap between static content and interactive visual storytelling. The current pages possess a strong technical backbone (a large geocoded site database and a functional map), but they suffer from disconnected scrollytelling flow, raw CSS variable overrides, and a critical usability barrier where the methodology paper is served as raw markdown. 

This plan details the specific engineering and design modifications required to elevate the experience, organized into three priority tiers.

---

## 1. Critical Improvements (Priority 1)

These modifications resolve functional bugs, mobile layout breaks, and raw file rendering issues that block publication quality.

### 1.1 render Methodology Paper as a Styled HTML Page
* **File Affected:** `content/investigations/the-lead-belt/lead-belt-method-paper.md` [DELETE] and create [content/investigations/the-lead-belt/methodology/index.html](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/content/investigations/the-lead-belt/methodology/index.html) [NEW]
* **Exact Modification:** Converted the raw markdown text of the methodology paper into a beautifully styled HTML page. Wrap the content with:
  1. Global header (`components/header.html`) and footer (`components/footer.html`) templates.
  2. Typographic layout styling following the design tokens (Lora for body text, Space Grotesk for headings, Space Mono for formulas and tables).
  3. Interactive elements (collapsible formulas and clickable links to datasets).
* **Reason:** Displaying raw markdown (.md) in a production web browser shows unformatted text or triggers a raw text download. This is a severe UX bug.
* **Expected Impact:** Guarantees a polished, responsive reading experience that matches academic journal publication quality.

### 1.2 Mobile Bottom-Drawer Layout for Map Site Details
* **File Affected:** [content/investigations/the-lead-belt/index.html](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/content/investigations/the-lead-belt/index.html)
* **Exact Modification:** Under mobile media queries (`@media (max-width: 768px)`), modify `#mpl` (the site detail panel) from a floating card covering the map to a slide-up bottom drawer. Specifically:
  - Set `#mpl` to `position: absolute; bottom: 0; left: 0; right: 0; width: 100%`.
  - Limit its height to `40vh` with an `overflow-y: auto` scroll area.
  - Add a pull-bar drag indicator at the top of the panel and support swipe-to-dismiss behavior.
* **Reason:** In the current layout, the site detail panel floats on mobile, completely covering the markers and preventing the reader from clicking other locations without closing the panel first.
* **Expected Impact:** Restores map usability on smartphones, ensuring a seamless user flow.

### 1.3 Mobile-First Sticky Panel for Scrollytelling
* **File Affected:** [content/investigations/the-lead-belt/index.html](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/content/investigations/the-lead-belt/index.html)
* **Exact Modification:** Modify the responsive styling for `.vsticky` and `.stcol`. Instead of setting `.vsticky { display: none }` on mobile, change it to:
  - `.vsticky { position: sticky; top: 76px; height: 35vh; width: 100%; z-index: 10; }`
  - `.stcol { position: relative; width: 100%; padding-top: 2vh; }`
  - Render scrolling text cards (`.step`) with a semi-transparent, high-contrast dark background overlay (`background: rgba(3,3,5,0.85); backdrop-filter: blur(8px)`) that scrolls over the sticky background graphic.
* **Reason:** Currently, all sticky visual context (charts, satellite indicators) is completely hidden on mobile screens, stripping the story of its core visual evidence.
* **Expected Impact:** Ensures mobile readers (who represent >50% of traffic) receive the same rich visual storytelling as desktop users.

### 1.4 Resolve Inconsistent Links on Verdict & Data Hub
* **Files Affected:** [content/investigations/the-lead-belt/index.html](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/content/investigations/the-lead-belt/index.html) and [data/index.html](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/data/index.html)
* **Exact Modification:**
  - Update download links in the verdict panel of `index.html` to point to `/data/BD-INV-003_LeadBelt_MasterDataset_v5.xlsx` (Master workbook) and add a secondary link for the raw flat CSV `/data/BD-INV-003_LeadBelt_MasterDataset_v5.csv`.
  - Re-route the methodology badge link from `lead-belt-method-paper.md` to `content/investigations/the-lead-belt/methodology/index.html`.
* **Reason:** The download buttons point to raw CSVs with abbreviated column names, which confuses general users, and the methodology badge points to the raw markdown file.
* **Expected Impact:** Unifies the data download and reading experience, directing users to the correct resources.

---

## 2. High-Impact Improvements (Priority 2)

These upgrades add visual depth, interactive polish, and orbital satellite evidence directly to the reader's screen.

### 2.1 Interactive Map-Prose Scroll Binding (Map Scrollytelling)
* **File Affected:** [content/investigations/the-lead-belt/index.html](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/content/investigations/the-lead-belt/index.html)
* **Exact Modification:** Write an IntersectionObserver script that triggers Leaflet map panning, zooming, and marker-opening as the reader scrolls past specific narrative steps:
  - **Scene 02 (Kamrangir Char):** Trigger `map.flyTo([23.7227, 90.3698], 15)` to highlight the Rosulpur smelter (BD-4591) and open its school-proximity details.
  - **Scene 03 (Jatrabari):** Trigger `map.flyTo([23.7096, 90.4257], 15)` to focus on the Doyaganj market (BD-4802).
  - **Scene 06 (Kathgora):** Trigger `map.flyTo([23.9194, 90.2923], 15)` to focus on Savar (BD-4921).
* **Reason:** In NYT and Reuters benchmark pieces, scrolling down the page drives the visual content. Currently, the map remains static at the top of the page, completely disconnected from the stories scrolling below.
* **Expected Impact:** Creates a unified visual narrative that connects spatial data directly to reading progress.

### 2.2 Integration of Real Satellite Basemap Toggles
* **File Affected:** [content/investigations/the-lead-belt/index.html](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/content/investigations/the-lead-belt/index.html)
* **Exact Modification:** Initialize a second tile layer inside Leaflet pointing to Esri World Imagery (`https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}`). Add a listener to the `Satellite View` layer button that smoothly toggles between the dark vector tiles and the high-resolution satellite imagery tiles.
* **Reason:** The current "Satellite View" button merely shows coordinate outline rings on a dark blank background, denying the reader actual orbital view context.
* **Expected Impact:** Provides real geographic visualization of factory rooftops and nearby school structures, enhancing transparency.

### 2.3 Render Satellite Verification Proof Images in the Detail Panel
* **File Affected:** [content/investigations/the-lead-belt/index.html](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/content/investigations/the-lead-belt/index.html)
* **Exact Modification:** Update the JavaScript click handler for map markers. If a clicked site is active (has `sat: true` in its database object, e.g. BD-4591, BD-4802), render a tabbed media module inside the detail panel `#mpl` that lets readers click between Wide (Zoom-16) and Close-Up (Zoom-18) views of the smelting furnace and slag piles.
* **Reason:** Although 44 folders of satellite screenshot proof have been archived in the OS repository, they are invisible to the public. Integrating them provides immediate evidence.
* **Expected Impact:** Provides visual evidence directly in the interface, supporting the "reproducibility" standard.

### 2.4 Animate Horizontal Soil Bar Charts on Scroll
* **File Affected:** [content/investigations/the-lead-belt/index.html](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/content/investigations/the-lead-belt/index.html)
* **Exact Modification:** Change the inline styles of `.sbi-fill` from absolute widths to transition properties. When the bar chart container enters the viewport, trigger a script that sets the CSS variable widths (e.g. from `0%` to `100%` for BD-4921) over a `1s ease-out` transition.
* **Reason:** The chart loads in a static state, missing the opportunity for a polished micro-animation that visually emphasizes scale.
* **Expected Impact:** Boosts reader engagement and highlights the massive safety exceedances (e.g., 1,702× safe).

---

## 3. Nice-to-Have Improvements (Priority 3)

These upgrades add optional polish, sharing capabilities, and metadata rigor.

### 3.1 Skeleton Loader for Homepage Hydration
* **Files Affected:** [index.html](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/index.html) (root) and [assets/js/data-loader.js](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/assets/js/data-loader.js)
* **Exact Modification:** Add a CSS skeleton card layout to `index.html` inside `#js-featured-investigation` that mimics the title, summary, and date fields. The hydration script in `data-loader.js` will replace this skeleton card once the JSON payload is parsed.
* **Reason:** Currently, there is a minor layout shift on load when the client-side JS hydrates the featured investigation block.
* **Expected Impact:** Eliminates content layout shifts, matching professional performance standards.

### 3.2 Interactive Command Line Replication Copy Block
* **File Affected:** [content/investigations/the-lead-belt/methodology/index.html](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/content/investigations/the-lead-belt/methodology/index.html) (new HTML file)
* **Exact Modification:** Embed a styled command line block showing the exact CLI command to run `analyze.py` against `osm_schools.geojson`, equipped with a single-click "Copy to Clipboard" button.
* **Reason:** Promotes replication by making the replication CLI command copy-pasteable.
* **Expected Impact:** Signals transparency and makes replication easy for data analysts.

---

## 4. Verification Plan

Upon approval of the plan and completion of Phase 2 implementation, the following verifications will be conducted:
1. **Broken Link Scan:** Run local checks to verify all anchor routes and downloads resolve.
2. **Device Responsiveness Testing:** Verify mobile bottom-drawer panels and scrolling cards render on mobile viewports.
3. **Local Dev Validation:** Serve the website repository locally (`npm run dev` or local server) to test transitions and map layer toggles.
