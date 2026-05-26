# 08-negative-rules.md — The "What NOT to Do" Checklist
**Version:** 1.1  
**Status:** Active  

This document lists prohibited behaviors, bad practices, and design/engineering anti-patterns across website development, data analysis, investigative research, visualizations, and session context resumption. Refer to this checklist to verify what you must avoid during every task.

---

## 1. WEBSITE & COMPONENT DEVELOPMENT (What NOT to Do)
* **[ ] NO Inline CSS Styles:** Never use the `style="..."` attribute on elements for layout, spacing, or colors. All styling must read from `assets/css/style.css` or `assets/css/components.css`.
* **[ ] NO Ad-Hoc CSS Variables:** Do not define local variables or values that bypass the approved design tokens in `docs/governance/04a-design-tokens.md`.
* **[ ] NO Raw Primary Colors:** Never use basic HTML/hex colors (e.g. `#FF0000`, `#0000FF`, `#00FF00`). Always use the mapped color tokens (e.g. `var(--color-accent)`, `var(--color-status-published)`, etc.).
* **[ ] NO Page-Level Component Styling:** Do not write custom styles for headers, footers, breadcrumbs, navigation bars, or cards at the page level. If a component exists in `components.css`, use it exactly.
* **[ ] NO External Script Dependencies:** Do not introduce external JS libraries, trackers, or styling frameworks (like Tailwind or Bootstrap) unless explicitly instructed and approved.
* **[ ] NO Static/Broken Asset Paths:** Do not link images, CSS, or JS files with pathing that fails under local filesystem (`file://`) or subdirectory hosting. Maintain clean, root-relative paths for production, but verify fallback functionality.
* **[ ] NO Hardcoded Date Fallbacks:** Do not leave old static copyright years (e.g., copyright 2025) in page footers. Ensure they either dynamically fetch the current year via script or reference the current year (2026).
* **[ ] NO Unlabeled Interactive Elements:** Do not implement map buttons, filters, or links without descriptive `aria-label` or clean accessibility text.

---

## 2. DATA ANALYSIS & RESEARCH (What NOT to Do)
* **[ ] NO Manual Edits on Raw Data:** Never modify values directly inside raw data files (`/data/raw/` or `data/` database directories). All transformations, cleaning, and formatting must be script-based and documented.
* **[ ] NO Single-Source Claims:** Do not make a central investigative claim based on a single anonymous source or a single unverified document.
* **[ ] NO Hearsay Sourcing:** Do not quote or cite secondary summaries (e.g. news reports summarizing a study) without tracking down and auditing the original, primary dataset or study publication.
* **[ ] NO Speculative Generalization:** Do not extrapolate a localized dataset (e.g., Dhaka-specific crash data) to a national scale unless you have a statistically validated national sample weight.
* **[ ] NO Motivated Scaling:** Do not frame correlations (e.g. "crime rates increased after a law passed") as causative without independent, verified controls.
* **[ ] NO Unverified Dataset Aggregations:** Never rely on dataset row counts or sums without checking for duplicate entries, artificial padding, or hidden null-value clusters.
* **[ ] NO Exposure of Sensitive Metadata:** Never push raw data or source communication containing original metadata (e.g., EXIF GPS tags on images, document creator details in PDFs) to the Git repository.

---

## 3. DATA VISUALIZATION (What NOT to Do)
* **[ ] NO Overly Complex Charts:** Do not use 3D effects, pie charts with many categories, or scatter plots without labeled trendlines.
* **[ ] NO Decorative Animations:** Avoid page animations or transitions that serve no informational purpose (no parallax, no entrance fades that slow down reading). Motion must only represent user interaction or data transition.
* **[ ] NO Unlabeled Data Points:** Never display charts, map pins, or coordinates without explicit unit labels, source credits, and metadata context.
* **[ ] NO Rainbow Color Palettes:** Do not use random color scales. Visual coloring must follow a purposeful gradient or highlight token variables.
* **[ ] NO Unscaled Geographic Visuals:** Never overlay geographic points without mapping density levels or clusters (e.g., raw overlapping pins that obscure the actual scale of hotspots).

---

## 4. CONTEXT RESUMPTION & CREDIT PROTECTION (What NOT to Do)
* **[ ] NO Broad File-Read Scans:** When starting a new session or resuming from compaction, **DO NOT** use broad directory scans or read all HTML/data files in full. This burns thousands of context tokens.
* **[ ] NO Repetitive Tool Polling:** Do not run recursive loops, repeated `git status` commands, or poll tasks in a loop. Rely on system event messages to notify you of async process completions.
* **[ ] NO Context Blindness:** Do not start coding from scratch without checking what the previous agent completed.
* **[ ] Context Recovery Rule:** Follow the **Single-File Resumption Protocol**:
  - Always write and update the context transfer state in a single file: `insightgaps-os/ACTIVE_CONTEXT.md` (or `docs/governance/context_transfer.md` in the frontend repo).
  - When starting a session, the very first step must be reading **ONLY** the handoff file to get the current state, progress, and next steps, bypassing file searches and repository audits.
