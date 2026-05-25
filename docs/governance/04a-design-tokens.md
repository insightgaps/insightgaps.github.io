# 04a-design-tokens.md — Insight Gaps Design Tokens
**Version:** 1.0
**Status:** Active
**Rule:** All values here map directly to CSS variables in assets/css/style.css. Change here first, then update the file.

---

## DESIGN PHILOSOPHY

Insight Gaps is a forensic data journalism bureau. The design must communicate:
- Precision — every element is intentional
- Credibility — nothing is decorative without purpose
- Readability — long-form data journalism read on screens
- Seriousness — without being cold or institutional

Light site. Typography-forward. Data and text treated as equals.
No gradients. No drop shadows. No stock photography.

---

## TYPOGRAPHY

### Headline Font — Space Grotesk
**Use:** All headlines, section labels, navigation, UI elements, card titles
**Weight used:** 400 regular, 600 semibold, 700 bold
**Why:** Geometric but with character. Precise without being cold. Works at display sizes and small UI labels. Completely distinct from generic system fonts.

### Body Font — Lora
**Use:** All body copy, investigation prose, analysis report text, about page
**Weight used:** 400 regular, 400 italic, 700 bold
**Why:** Serif with editorial credibility. Highly readable at paragraph sizes. Signals long-form reading rather than quick-scan content.

### Data / Mono Font — Space Mono
**Use:** Case IDs, timestamps, data labels, code references, status badges, source counts, metric counters
**Weight used:** 400 regular
**Why:** Already in use across investigations. Signals data precision. Visually distinct from prose — reader knows immediately they are looking at structured data.

### Type Scale
| Token | Size | Font | Weight | Use |
|---|---|---|---|---|
| `--type-display` | 48px | Space Grotesk | 700 | Homepage hero headline |
| `--type-h1` | 36px | Space Grotesk | 700 | Investigation and report titles |
| `--type-h2` | 24px | Space Grotesk | 600 | Section headings |
| `--type-h3` | 18px | Space Grotesk | 600 | Subsection headings, card titles |
| `--type-body` | 17px | Lora | 400 | All prose — body copy |
| `--type-body-sm` | 15px | Lora | 400 | Captions, footnotes, source lines |
| `--type-label` | 12px | Space Mono | 400 | Status badges, case IDs, timestamps |
| `--type-data` | 14px | Space Mono | 400 | Data labels, metric counters |

### Line Height
| Token | Value | Use |
|---|---|---|
| `--leading-tight` | 1.2 | Headlines |
| `--leading-body` | 1.7 | All prose — comfortable long-form reading |
| `--leading-data` | 1.4 | Data labels, tables |

---

## COLOR PALETTE

### Base — Light Site
| Token | Hex | Use |
|---|---|---|
| `--color-bg` | #F9F8F6 | Page background — warm white, not clinical |
| `--color-surface` | #FFFFFF | Cards, panels, elevated surfaces |
| `--color-border` | #E2E0DC | Dividers, card borders, table rules |
| `--color-border-strong` | #C8C4BC | Emphasis borders, active states |

### Text
| Token | Hex | Use |
|---|---|---|
| `--color-text-primary` | #1A1917 | All primary body text |
| `--color-text-secondary` | #5C5954 | Secondary labels, captions, metadata |
| `--color-text-muted` | #9C9891 | Timestamps, placeholder text |
| `--color-text-inverse` | #F9F8F6 | Text on dark backgrounds |

### Bureau Accent — Investigation Track
| Token | Hex | Use |
|---|---|---|
| `--color-accent` | #C17D11 | Primary bureau accent — links, active states, key highlights |
| `--color-accent-hover` | #A06A0E | Hover state for accent elements |
| `--color-accent-subtle` | #FDF3E3 | Light amber backgrounds — finding highlights, callout blocks |
| `--color-accent-border` | #E8C07A | Amber borders for callout blocks |

Note: The amber accent is the bureau identity color. It applies globally across both investigations and analysis. Investigation pages use it more prominently. Analysis pages use it only for interactive elements and links.

### Status Colors
| Token | Hex | Use |
|---|---|---|
| `--color-status-published` | #1A6B3C | Published badge |
| `--color-status-corrected` | #C17D11 | Corrected badge — same as accent |
| `--color-status-developing` | #2563AB | Developing badge |
| `--color-status-terminated` | #6B1A1A | Terminated badge |
| `--color-status-archived` | #5C5954 | Archived badge |

### Trust Surface
| Token | Hex | Use |
|---|---|---|
| `--color-trust-bg` | #F2F0EC | Background for methodology, corrections, AI-use pages |
| `--color-correction-bg` | #FEF2F2 | Correction banner background |
| `--color-correction-border` | #FECACA | Correction banner border |

---

## SPACING SCALE

Base unit: 4px. All spacing is a multiple of this unit.

| Token | Value | Use |
|---|---|---|
| `--space-1` | 4px | Micro — icon padding, tight gaps |
| `--space-2` | 8px | Small — inline element spacing |
| `--space-3` | 12px | Default — label to value gaps |
| `--space-4` | 16px | Base — standard component padding |
| `--space-5` | 24px | Medium — card padding, section gaps |
| `--space-6` | 32px | Large — between major sections |
| `--space-7` | 48px | XL — page section breaks |
| `--space-8` | 64px | XXL — hero sections, major page divisions |
| `--space-9` | 96px | Max — top of page breathing room |

---

## GRID SYSTEM

### Content Width
| Token | Value | Use |
|---|---|---|
| `--grid-max` | 1200px | Maximum page width — nothing wider than this |
| `--grid-content` | 720px | Prose column — investigation and analysis body text |
| `--grid-wide` | 960px | Wide content — charts, maps, data tables that need room |
| `--grid-full` | 100% | Full bleed — hero images, section backgrounds |

### Columns
Standard 12-column grid. Gutters: 24px.

Investigation prose: 8 of 12 columns centered
Data visualizations: 10 of 12 columns centered
Homepage cards: 4 of 12 columns each — three per row
Archive cards: 6 of 12 columns each — two per row on desktop

### Breakpoints
| Token | Value | Use |
|---|---|---|
| `--bp-mobile` | 480px | Single column layout |
| `--bp-tablet` | 768px | Two column where applicable |
| `--bp-desktop` | 1024px | Full grid |
| `--bp-wide` | 1200px | Max width locks |

---

## BORDERS AND RADIUS

| Token | Value | Use |
|---|---|---|
| `--radius-sm` | 2px | Badges, status tags |
| `--radius-md` | 4px | Cards, buttons |
| `--radius-lg` | 8px | Panels, modals |
| `--border-width` | 1px | All borders — no thick borders |
| `--border-width-strong` | 2px | Active states, correction banners |

---

## MOTION

Minimal. Nothing decorative.

| Token | Value | Use |
|---|---|---|
| `--transition-fast` | 150ms ease | Hover states on links and buttons |
| `--transition-base` | 250ms ease | State changes on cards and panels |

No scroll animations. No entrance animations. No parallax.
Motion only serves state change feedback.

---

## TRACK-SPECIFIC RULES

### Investigation Pages
- Amber accent used for: section dividers above key findings, inline citation callouts, methodology badge border
- Space Mono used prominently: case ID in hero, source count, timestamp pair
- Correction banner: red surface — stands out clearly from amber

### Analysis Pages
- Amber accent used for: links and CTA buttons only
- More white space — business readers expect cleaner layouts
- Executive summary block gets slightly larger type treatment
- No case ID treatment — reports use tag labels instead

---

*These tokens are the visual contract. Every component, every page, every template reads from this file. No color, size, or spacing value is hardcoded anywhere else.*
