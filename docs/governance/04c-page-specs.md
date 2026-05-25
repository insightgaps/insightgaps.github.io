# 04c-page-specs.md — Insight Gaps Page Specifications
**Version:** 1.0
**Status:** Active
**Rule:** Page specs describe what each page contains and how components are assembled. They do not redefine design. All visual rules live in 04a and 04b.

---

## PAGE 1 — HOMEPAGE (index.html)

**Purpose:** Bureau command center. First impression. Establishes identity and routes readers to investigations and analysis.
**Data source:** investigations.json + analysis.json
**Template:** index.html directly — no blanket template

### Component Assembly — top to bottom

1. AI Disclosure Bar
2. Global Header
3. Hero Block
   - Bureau mandate statement — one line
   - Featured investigation: title, dek, status badge, date, link
   - Featured investigation og_image fills right half of hero on desktop
4. Metrics Counter Block
   - Total Investigations | Total Primary Sources | Corrections on Record
5. Section Label: `LATEST INVESTIGATIONS` — Space Mono uppercase
6. Investigation Card Grid — three cards, three columns
   - Pulls three most recent published investigations from investigations.json
7. Link: `View all investigations →` — right aligned
8. Section Label: `ANALYSIS DOMAINS` — Space Mono uppercase
9. Analysis Domain Card Grid — two or three cards
   - Pulls all active domains from analysis.json
10. Link: `View all analysis →` — right aligned
11. Trust Surface Strip
    - Three trust links with one-line descriptions: Methodology, AI Use, Corrections
    - Background: `--color-trust-bg`
    - This is not the footer — it is a dedicated trust signal block above the footer
12. Global Footer

### Page Rules
- Featured investigation is always the most recently published item with status published
- If no investigations exist yet — show a placeholder state, not an empty grid
- Homepage never shows developing or terminated investigations in the feed

---

## PAGE 2 — ARCHIVE (archive.html)

**Purpose:** Complete index of all bureau output — investigations and analysis — searchable and filterable.
**Data source:** investigations.json + analysis.json
**Template:** archive.html directly

### Component Assembly — top to bottom

1. AI Disclosure Bar
2. Global Header
3. Page Header Block
   - Title: `Archive` — `--type-h1`
   - Subtitle: Total count — `INV count investigations · domain count analysis domains`
4. Filter Controls
   - Filter by: Content type (Investigations / Analysis / All)
   - Filter by: Status (All / Published / Corrected / Developing / Terminated / Archived)
   - Filter by: Topic tag — dropdown populated from all unique tags in JSON
   - Sort by: Date newest / Date oldest
5. Results Grid
   - Investigation cards and analysis domain cards render together
   - Status badge always visible
   - Terminated investigations always included — never hidden
6. Global Footer

### Page Rules
- All status types visible including terminated — with terminated badge clearly styled
- If a filter returns zero results — show a clear empty state message
- Archive does not paginate at current scale — all items render

---

## PAGE 3 — INVESTIGATION PAGE (INV-00X/index.html)

**Purpose:** Primary reporting product. The investigation itself.
**Data source:** investigations.json entry + local handoff.md content
**Template:** templates/investigation-blanket.html

### Component Assembly — top to bottom

1. AI Disclosure Bar
2. Global Header
3. Investigation Hero
   - Status badge
   - Investigation type badge (Tier label)
   - Title — `--type-h1`
   - Dek — `--type-body` Lora italic
   - Byline: `Insight Gaps Bureau` + date_published
   - If date_revised exists: `Updated: date_revised`
   - Case ID in Space Mono — right aligned
4. Correction Banner — only if has_correction is true
5. Methodology Badge
6. Key Findings Panel — exactly three findings
7. Body Content Sections
   - Prose in Lora `--type-body` at `--grid-content` width
   - Visual blocks (charts, maps) break out to `--grid-wide` width
   - Data tables break out to `--grid-wide` width
   - Section dividers between major sections
8. Source Citation Section
   - Label: `PRIMARY SOURCES` in Space Mono uppercase
   - Source count displayed
   - Source list — numbered, Lora `--type-body-sm`
9. Methodology Section
   - Label: `METHODOLOGY` in Space Mono uppercase
   - Content from methodology/methodology.md
   - Link to global methodology page
10. Related Investigations — max three cards
    - Only if related_items array is populated
11. Global Footer

### Page Rules
- Key findings are never written at build time — always pulled from handoff.md
- Correction banner position is fixed — always between hero and methodology badge
- Source count in hero must match actual source list count — verified before publication
- No investigation page is published without a populated methodology section

---

## PAGE 4 — ANALYSIS DOMAIN PAGE (analysis/[domain]/index.html)

**Purpose:** Domain landing page. Shows what reports exist in this domain. Routes business readers to specific reports.
**Data source:** analysis.json — domain entry
**Template:** templates/analysis-domain.html

### Component Assembly — top to bottom

1. Global Header
2. Breadcrumb: `Analysis → Domain Title`
3. Domain Header Block
   - Domain title — `--type-h1`
   - Audience label — Space Mono `--type-label`
   - Description — Lora `--type-body`
   - Last updated + report count in Space Mono
4. Report Card Grid
   - One card per report in domain
   - Each card: tag, title, date, executive_summary excerpt, link
   - Two columns on desktop, one on mobile
5. Call to Action Component
6. Global Footer

### Page Rules
- No amber left border on report cards — softer visual treatment than investigations
- Executive summary excerpt is first sentence only — not truncated mid-sentence
- Report count in header updates automatically from analysis.json

---

## PAGE 5 — ANALYSIS REPORT PAGE (analysis/[domain]/[report].html)

**Purpose:** Individual forensic business report. Portfolio and income product.
**Data source:** analysis.json — report entry
**Template:** templates/analysis-report.html

### Component Assembly — top to bottom

1. AI Disclosure Bar
2. Global Header
3. Breadcrumb: `Analysis → Domain Title → Report Title`
4. Report Header
   - Tag label — Space Mono `--type-label`
   - Title — `--type-h1`
   - Date — Space Mono
   - If confidence_level exists: displayed as a small badge
5. Executive Summary Block
   - Slightly larger type — `--type-body` at 18px for this block only
   - Lora italic
6. Key Findings List
   - Label: `KEY FINDINGS` — Space Mono uppercase
   - Three to five bullet points
7. Body Content — data sections, charts, analysis
   - Visual blocks at `--grid-wide`
8. Methodology Note
   - Brief — two to four sentences
   - Dataset reference if populated
9. Call to Action Component
10. Global Footer

### Page Rules
- No correction banner mechanism — analysis reports are versioned by date, not corrected in place
- CTA component always present — contact_cta field defaults to true
- No case ID treatment — reports identified by tag + title

---

## PAGE 6 — ABOUT (about.html)

**Purpose:** Bureau identity and trust. Who runs this, why, how it is funded.

### Component Assembly — top to bottom

1. Global Header
2. Page Header: `About Insight Gaps`
3. Mission Statement Block — bureau mandate in full
4. Editor Profile Block — name, background, credentials
5. Funding Disclosure Block — clearly labeled, no evasion
6. Methodology Philosophy — summary paragraph + link to full methodology page
7. Global Footer

### Page Rules
- No photographs required
- Funding disclosure must be honest even if the answer is self-funded
- Links directly to methodology.html — not a summary of it

---

## PAGE 7 — METHODOLOGY (content/trust/methodology.html)

**Purpose:** Full public record of how Insight Gaps verifies and publishes.

### Component Assembly — top to bottom

1. Global Header
2. Page Header: `Methodology`
3. Intro statement — what counts as verified at Insight Gaps
4. Verification Tiers Section — Tier 1, 2, 3 with full definitions
5. Data Handling Rules Section
6. AI Use Summary — link to full ai-use.html
7. Last Updated — Space Mono, bottom of page
8. Global Footer

---

## PAGE 8 — AI USE (content/trust/ai-use.html)

**Purpose:** Full transparency ledger of AI tool use in bureau operations.

### Component Assembly — top to bottom

1. Global Header
2. Page Header: `AI Use Disclosure`
3. Intro statement — role of AI in Insight Gaps workflow
4. AI Operations Table
   - Columns: Tool Name | Primary Role | What It Must Not Own
   - One row per tool
5. What AI Does Not Control — explicit statement
6. Last Updated — Space Mono
7. Global Footer

---

## PAGE 9 — CORRECTIONS (content/trust/corrections.html)

**Purpose:** Permanent timestamped record of every correction ever issued.

### Component Assembly — top to bottom

1. Global Header
2. Page Header: `Corrections Log`
3. Policy Statement — entries are never deleted, only appended
4. Corrections Table
   - Columns: Date | Investigation ID | Error Identified | Correction Executed
   - Most recent at top
   - If no corrections exist: explicit statement — `No corrections have been issued.`
5. Global Footer

### Page Rules
- Table rows are never deleted
- Most recent correction always at top
- Empty state must be explicit — not a missing table

---

## PAGE 10 — CONTACT (contact.html)

**Purpose:** Secure tip submission and general contact.

### Component Assembly — top to bottom

1. Global Header
2. Page Header: `Contact`
3. Tip Submission Section
   - What to submit and what happens to it
   - Formspree form — name optional, message required
   - OPSEC note — what is and is not stored
4. General Contact — email address only
5. Global Footer

---

## PAGE 11 — 404 (404.html)

**Purpose:** Graceful error handling.

### Component Assembly — top to bottom

1. Global Header
2. Error Block — centered
   - `404` in Space Mono large
   - Human message: one sentence
   - Two links: Homepage and Archive
3. Global Footer

---

*Page specs are the assembly instructions. They reference components and tokens. They never define visual rules.*
