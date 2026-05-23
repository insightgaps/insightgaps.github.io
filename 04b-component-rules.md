# 04b-component-rules.md — Insight Gaps Component Rules
**Version:** 1.0
**Status:** Active
**Rule:** Every component is defined here before it is built. No component is designed at the page level.

---

## WHAT THIS DOCUMENT IS

This document defines how every reusable element on the site behaves, looks, and is used.
Components are built once. Pages assemble them.
If a component needs to change, update the definition here first.

---

## COMPONENT 1 — GLOBAL HEADER / NAVIGATION

**File:** `components/header.html`
**Appears on:** Every page without exception

### Structure
- Left: Bureau logotype — `INSIGHT GAPS` in Space Grotesk 700
- Center: Primary navigation links
- Right: Nothing — no search, no account, no hamburger icon on desktop

### Navigation Links
`Investigations` | `Analysis` | `Archive` | `About` | `Trust`

Trust is a nav item, not a footer-only link. This is a deliberate credibility signal.

### Behavior
- Sticky on scroll — header stays visible always
- Mobile: links collapse into a minimal toggle — no overlay, just a vertical stack below the logo
- Active page: current link underlined with `--color-accent` 2px bottom border
- No dropdown menus

### Visual Rules
- Background: `--color-surface` with 1px bottom border `--color-border`
- Logotype: `--color-text-primary` — no accent color on the wordmark
- Nav links: `--color-text-secondary` default, `--color-text-primary` on hover and active
- Height: 64px fixed

---

## COMPONENT 2 — GLOBAL FOOTER

**File:** `components/footer.html`
**Appears on:** Every page without exception

### Structure
Three columns:

Left column: Bureau logotype, mandate statement in one line, copyright
Center column: Navigation links repeated — Investigations, Analysis, Archive, About
Right column: Trust links — Methodology, AI Use, Corrections, Contact

Below columns: Single line — license statement and deployment note

### Visual Rules
- Background: `--color-text-primary` — dark footer on light site
- All text: `--color-text-inverse`
- Links: `--color-text-inverse` with underline on hover
- Top border: 3px solid `--color-accent` — bureau identity signal
- Padding: `--space-8` top and bottom

---

## COMPONENT 3 — INVESTIGATION CARD

**File:** Referenced in `templates/archive-card.html`
**Appears on:** Homepage feed, archive page

### Required Fields
`status badge` | `topic_tags` | `title` | `summary` | `date` | `id` | `has_correction indicator`

### Structure — top to bottom
1. Status badge — top left
2. Topic tag — top right, first tag only
3. Title — Space Grotesk 600 `--type-h3`
4. Summary — Lora `--type-body-sm`
5. Bottom row: Case ID in Space Mono `--type-label` left, date right

### Visual Rules
- Background: `--color-surface`
- Border: 1px `--color-border`
- Left border accent: 3px solid `--color-accent` — investigation identity marker
- Padding: `--space-5`
- Hover: border color shifts to `--color-accent`, subtle lift via border-color only — no shadow
- Correction indicator: small amber dot next to case ID if has_correction is true

---

## COMPONENT 4 — ANALYSIS DOMAIN CARD

**Appears on:** Homepage, archive, analysis index page

### Required Fields
`domain_title` | `description` | `report_count` | `last_updated`

### Structure — top to bottom
1. Domain title — Space Grotesk 600 `--type-h3`
2. Description — Lora `--type-body-sm`
3. Bottom row: Report count in Space Mono left, last updated right

### Visual Rules
- Same card shell as investigation card
- No left border accent — analysis track is visually softer
- Top border: 2px solid `--color-border-strong` instead of accent color
- Hover: border-top shifts to `--color-accent`

---

## COMPONENT 5 — STATUS BADGE

**Appears on:** Every investigation card and investigation page hero

### Rules
- Rendered as a small inline tag — Space Mono `--type-label`
- Uppercase text
- Background uses the status color at 15% opacity
- Text uses the full status color
- Border radius: `--radius-sm`
- Padding: `--space-1` vertical, `--space-2` horizontal

| Status | Text | Color token |
|---|---|---|
| published | PUBLISHED | `--color-status-published` |
| corrected | CORRECTED | `--color-status-corrected` |
| developing | DEVELOPING | `--color-status-developing` |
| terminated | TERMINATED | `--color-status-terminated` |
| archived | ARCHIVED | `--color-status-archived` |

---

## COMPONENT 6 — METHODOLOGY BADGE

**File:** `components/methodology-badge.html`
**Appears on:** Every investigation page — mandatory

### Structure
Single line: verification tier label + link to methodology page

Example: `Tier 2 — Data-Driven Investigation  →  Full Methodology`

### Visual Rules
- Background: `--color-accent-subtle`
- Border: 1px `--color-accent-border`
- Text: Space Mono `--type-label`
- Border radius: `--radius-md`
- Padding: `--space-3` vertical, `--space-4` horizontal
- Link: `--color-accent` with underline

---

## COMPONENT 7 — CORRECTION BANNER

**File:** `components/correction-banner.html`
**Appears on:** Investigation pages where has_correction is true

### Structure
- Label: `CORRECTION ISSUED` in Space Mono uppercase
- Date of correction
- One-line description of what changed
- Link: `View full corrections log →`

### Visual Rules
- Background: `--color-correction-bg`
- Border-left: 4px solid `#DC2626` — red, clearly distinct from amber
- Must appear directly below the investigation hero — before body content begins
- Never hidden, never collapsible

---

## COMPONENT 8 — AI DISCLOSURE BAR

**File:** `components/ai-disclosure-bar.html`
**Appears on:** Every investigation page and analysis report page

### Structure
Single line: `AI tools were used in producing this report. View AI use disclosure →`

### Visual Rules
- Background: `--color-trust-bg`
- Border-bottom: 1px `--color-border`
- Text: `--color-text-secondary` `--type-label`
- Appears at very top of page — above the header
- Not sticky — scrolls away

---

## COMPONENT 9 — KEY FINDINGS PANEL

**Appears on:** Investigation pages only

### Structure
- Label: `KEY FINDINGS` in Space Mono uppercase
- Exactly three findings — pulled from handoff.md
- Numbered 01, 02, 03 in Space Mono

### Visual Rules
- Background: `--color-accent-subtle`
- Border-left: 3px solid `--color-accent`
- Each finding: Lora `--type-body` with number label in Space Mono `--type-label`
- Padding: `--space-6`
- Margin: `--space-7` top and bottom — given significant breathing room

---

## COMPONENT 10 — METRICS COUNTER BLOCK

**Appears on:** Homepage only

### Structure
Three counters side by side:
- Total Investigations
- Total Primary Sources
- Corrections on Record

### Visual Rules
- Number: Space Mono `--type-display` `--color-text-primary`
- Label: Space Grotesk `--type-label` `--color-text-secondary` uppercase
- Dividers: 1px `--color-border` between counters
- No background — sits on page background directly

---

## COMPONENT 11 — SECTION DIVIDER

**Appears on:** Investigation and analysis pages — between major content sections

### Two types:

**Light divider:** 1px `--color-border` — standard between body sections

**Accent divider:** 2px `--color-accent` width 48px — used above key findings panel and before methodology section. Signals a shift to structured data.

---

## COMPONENT 12 — CALL TO ACTION — ANALYSIS ONLY

**Appears on:** Analysis domain pages and individual report pages

### Structure
- Headline: `Commission a Custom Analysis`
- One line description
- Button: `Get in Touch →` links to contact.html

### Visual Rules
- Background: `--color-surface`
- Border: 1px `--color-border`
- Button: Background `--color-accent`, text `--color-text-inverse`, radius `--radius-md`
- Button hover: `--color-accent-hover`

---

## COMPONENT RULES — GLOBAL

- No component defines its own colors — all values reference design tokens
- No component uses inline styles
- Components are pasted into pages during build — not dynamically included
- When a component changes, it must be re-pasted into all pages that use it
- Components are documented here before they are built

---

*Components are the vocabulary of the design system. Pages are sentences made from that vocabulary. Never write new vocabulary at the page level.*
