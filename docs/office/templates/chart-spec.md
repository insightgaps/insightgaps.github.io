# Chart Design Specification & Visual Inventory

**Investigation Slug:** `{{SLUG}}`  
**Visual Designer:** Agent 05 (Information Architecture Desk)  
**Date Created:** {{YYYY-MM-DD}}  
**Design Standards:** 960px Baseline, SVG-Only, WCAG AA Contrast  

---

## 1. Visual Asset Inventory

| Chart ID | Relative File Path | Chart Type | Dimensions (viewBox) | Target Section in Report |
| :--- | :--- | :--- | :--- | :--- |
| **CH-01** | `assets/img/charts/{{SLUG}}-gap.svg` | Comparison Bar / Gap | `viewBox="0 0 960 260"` | Act 1: The Core Finding |
| **CH-02** | `assets/img/charts/{{SLUG}}-cycle.svg` | Multi-stage Process | `viewBox="0 0 960 280"` | Act 2: Mechanism of Failure |
| **CH-03** | `assets/img/charts/{{SLUG}}-spatial.svg` | Geographic Breakdown | `viewBox="0 0 960 320"` | Act 3: Spatial Disparities |
| **CH-04** | `assets/img/charts/{{SLUG}}-timeline.svg`| Longitudinal Trend | `viewBox="0 0 960 260"` | Act 4: Statutory Record |

---

## 2. Standard SVG Architecture Boilerplate

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 260" width="100%" height="auto" role="img" aria-labelledby="chart-title-{{ID}} chart-desc-{{ID}}">
  <title id="chart-title-{{ID}}">{{INFORMATIVE_CHART_TITLE}}</title>
  <desc id="chart-desc-{{ID}}">{{ACCESSIBILITY_DESCRIPTION_OF_DATA_POINTS}}</desc>
  <style>
    .bg { fill: #0f172a; }
    .card { fill: #1e293b; stroke: #334155; stroke-width: 1; }
    .title { font-family: system-ui, -apple-system, sans-serif; font-size: 20px; font-weight: 700; fill: #ffffff; }
    .subtitle { font-family: system-ui, -apple-system, sans-serif; font-size: 14px; fill: #94a3b8; }
    .val-primary { font-family: system-ui, -apple-system, sans-serif; font-size: 26px; font-weight: 800; fill: #ef4444; }
    .val-secondary { font-family: system-ui, -apple-system, sans-serif; font-size: 26px; font-weight: 800; fill: #38bdf8; }
    .label { font-family: system-ui, -apple-system, sans-serif; font-size: 14px; fill: #e2e8f0; }
    .footnote { font-family: system-ui, -apple-system, sans-serif; font-size: 12px; fill: #64748b; }
  </style>
  <!-- Background -->
  <rect width="960" height="260" rx="8" class="bg"/>
  
  <!-- Header Block -->
  <text x="32" y="42" class="title">{{TITLE_TEXT}}</text>
  <text x="32" y="66" class="subtitle">{{SUBTITLE_AND_MEASUREMENT_UNIT}}</text>
  
  <!-- Data Graphics / Cards / Bars -->
  <!-- Direct data visual elements placed here with minimum 14px text -->

  <!-- Attribution Footer Line -->
  <text x="32" y="240" class="footnote">Source: {{DATA_SOURCE_CITATION_AND_YEAR}} · Insight Gaps Bureau Audit</text>
</svg>
```

---

## 3. Contrast & Accessibility Checklist

- [x] All text elements maintain contrast ratio ≥ 4.5:1 against their backgrounds.
- [x] No data series differentiated solely by red/green color.
- [x] Bar charts start at zero baseline.
- [x] Embedded source line directly inside the vector asset.
- [x] No raster text embedded inside vector graphics.
