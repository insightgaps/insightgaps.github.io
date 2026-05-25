# Impunity Machine (BD-INV-002) — Website Upgrade Plan

This document outlines the website transformation and experience design upgrades planned for the public release of the *Impunity Machine* investigation.

---

## 1. Critical Improvements

### A. Rebuild index.html as the Flagship Visual Experience
*   **File Affected:** `content/investigations/the-impunity-machine/index.html`
*   **Exact Modification:**
    *   Merge narrative content from legacy `index.html` with scrollytelling visual panels from legacy `visual.html`.
    *   Implement grid layout (`.sscene`) pinning map or canvas on the left/sticky sidebar, with narrative steps scrolling on the right.
    *   Include Canvas dot-funnel animation, SVG clocks, and interactive Section 17 comparison graphs inline.
*   **Reason:** Eliminates fragmented user flows. Ensures visual evidence synchronizes directly with prose.
*   **Expected Impact:** High-end scrollytelling experience matching premium journalism benchmarks.
*   **Dependency:** Approval of the publication architecture.

### B. Standardize styling and fonts (Design Tokens)
*   **File Affected:** `content/investigations/the-impunity-machine/index.html`, `tracker.html`, `methodology.html`
*   **Exact Modification:**
    *   Use CSS custom properties for warm white background and high-contrast dark mode colors.
    *   Enforce Lora for body copy, DM Mono or Space Mono for metadata, and Libre Baskerville or Playfair Display for headings.
    *   Maintain 3px solid blood-red accent borders (`#c41e3a`) for brand consistency.
*   **Reason:** Fits within the global design language of the new website.
*   **Expected Impact:** Sophisticated, premium aesthetic.
*   **Dependency:** None.

---

## 2. High Impact Improvements

### A. Map-Story Scroll Synchronization
*   **File Affected:** `content/investigations/the-impunity-machine/index.html`
*   **Exact Modification:**
    *   Initialize Leaflet map inside a sticky container.
    *   Use `IntersectionObserver` on the narrative scrolling column to fly-to and pan the map across division boundaries dynamically (e.g. focusing on Barishal, Sylhet, and Dhaka).
*   **Reason:** Replaces static maps with dynamic geographic scrollytelling.
*   **Expected Impact:** Interactive, evidence-driven regional reporting.
*   **Dependency:** Leaflet script and CSS initialization.

### B. Mobile Viewport Layout Hardening
*   **File Affected:** `content/investigations/the-impunity-machine/index.html`, `tracker.html`
*   **Exact Modification:**
    *   Add media queries (`@media (max-width: 768px)`) converting split-grid scrollytelling scenes into a stacked layout.
    *   Pin active charts/maps as a sticky top header (height ~40vw) while narrative text panels scroll below.
*   **Reason:** Ensures the scrollytelling visual remains visible during mobile reading.
*   **Expected Impact:** Exceptional readability and chart legibility on mobile screens.
*   **Dependency:** None.

### C. Reconstruct the Monthly Ledger and Heatmap
*   **File Affected:** `content/investigations/the-impunity-machine/tracker.html`
*   **Exact Modification:**
    *   Rebuild the monthly ledger heatmap to display a grid of years (columns) and months (cells).
    *   Color cells by data presence: Green (Confirmed), Amber (Probable), Red (Confirmed Absent).
    *   Add a click handler displaying details (sources, notes, totals) for the selected month.
*   **Reason:** Transparently displays the "paper trail" of official data gaps.
*   **Expected Impact:** Powerful visual representation of the unmeasured backlog crisis.
*   **Dependency:** `data/monthly.json`.

---

## 3. Optional / Long-term Improvements

### A. Case Registry Filters
*   **File Affected:** `content/investigations/the-impunity-machine/tracker.html`
*   **Exact Modification:**
    *   Add interactive status chips (`ALL`, `CONVICTED`, `PENDING`, `SECTION 17`) to filter the case card grid dynamically without reloading.
*   **Reason:** Improves case monitor usability.
*   **Expected Impact:** Clean, fast, and responsive database filtering.
*   **Dependency:** `data/cases.json`.

### B. Automated Press Feed integration
*   **File Affected:** `content/investigations/the-impunity-machine/tracker.html`
*   **Exact Modification:**
    *   Inject list of recent press headlines from `data/leads.json`.
    *   Label all raw crawled leads clearly as `UNVERIFIED` and place them in an expandable drawer to separate them from audited findings.
*   **Reason:** Signals active investigation monitoring.
*   **Expected Impact:** High-trust evidence compilation.
*   **Dependency:** GitHub Actions collector scheduler.
