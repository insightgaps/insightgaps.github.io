# Workflow Stage 05: Visual & Chart Production

**Stage:** 05 · High-Contrast Vector Graphics & Schematic Diagrams  
**Owner:** Agent 05 (Visual Designer)  
**Input:** `docs/office/workspace/verification/<slug>-fact-check-matrix.md`  
**Outputs:** `assets/img/charts/<slug>-*.svg`, `docs/office/workspace/visuals/<slug>-visual-inventory.md`

---

## 1. Objectives

The Visual Production stage converts audited quantitative findings into self-contained, publication-ready SVG vector graphics that are instantly legible on desktop PCs and mobile devices.

---

## 2. Desktop Readability Standards (PC & Mobile Parity)

- **960px Baseline Width:** All SVGs must be constructed with a standard viewBox: `viewBox="0 0 960 [Height]"`.
- **Typography Minimums:**
  - Chart Headings: 18–22px, bold, high-contrast.
  - Subtitles & Units: 14–15px, medium weight.
  - Data Values & Bar Labels: 14–16px, bold.
  - Axis Labels & Category Names: 13–14px.
  - Source Attributions & Footnotes: 12–13px (never below 12px).
- **High Contrast Palette:**
  - Primary Background: `#0f172a` (navy) or `#ffffff` (white card).
  - Primary Content Fill: `#ffffff` or `#0f172a`.
  - Secondary Content: `#94a3b8` (slate-400) or `#475569` (slate-600).
  - Primary Alert / Exceedance Accent: `#b91c1c` (crimson-700) or `#ef4444` (red-500).
  - Secondary Metric Accent: `#0284c7` (blue-600) or `#38bdf8` (sky-400).
  - Warning Accent: `#d97706` (amber-600) or `#f59e0b` (amber-500).
- **No Third-Party Iframes:** Zero Flourish, Datawrapper, Tableau, or Google Charts embeds. Everything must be local SVG/HTML.

---

## 3. Step-by-Step Procedure

1. **Select Chart Types for Core Findings:**
   - Finding 1: Macro gap or undercount -> Two-tier horizontal bar comparison or ratio callout.
   - Finding 2: Structural failure or cycle -> 3-stage or 4-stage process schematic with bold directional arrows.
   - Finding 3: Spatial disparity -> Geographic or division breakdown bar chart.
   - Finding 4: Longitudinal bottleneck -> Time-series slope chart or multi-year backlog progression.

2. **SVG Code Construction:**
   - Define clean SVG root with accessibility labels (`role="img"`, `aria-labelledby`).
   - Group visual elements logically inside `<g>` containers.
   - Include direct labeling rather than disconnected legends wherever possible.
   - Embed source citation directly inside the SVG footer so the graphic remains fully attributed if downloaded or screenshotted.

3. **Visual Contrast & Zoom Testing:**
   - Test rendering in browser at 100% desktop scale (960px container). Verify that all numbers can be read without squinting.
   - Test rendering on mobile screen simulation (360px viewport). Ensure vector paths scale cleanly.

4. **Deliverable Production:**
   - Save SVGs in `assets/img/charts/<slug>-<name>.svg`.
   - Author `docs/office/workspace/visuals/<slug>-visual-inventory.md` using `docs/office/templates/chart-spec.md`.
