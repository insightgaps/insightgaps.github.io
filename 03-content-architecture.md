# 03-content-architecture.md — Insight Gaps Platform Architecture
**Version:** 1.2 — Analysis Track Added
**Status:** Active
**Frozen before:** INV-001 build begins

---

## DESIGN RULES FOR THIS STRUCTURE

1. **One template rules all investigation pages.** Never design a page from scratch for a new investigation. Copy the template.
2. **Assets are shared globally.** Change `style.css` once and it updates every page.
3. **Each investigation is self-contained.** Delete `INV-001/` and nothing else breaks.
4. **Content is separated from presentation.** HTML is layout. Data is in `/data/`. Copy is in the HTML. Never mix them.
5. **The trust layer is non-negotiable.** `methodology.html`, `ai-use.html`, and `corrections.html` are not optional pages. They are the credibility infrastructure.
6. **`investigations.json` is the single source of truth** for the archive, homepage feed, and any future search function. Update it every time a new investigation is published.
7. **Analysis is a separate content track.** The `/analysis/` section serves commercial and portfolio purposes. It uses the same global design system but has its own folder, its own templates, and its own index (`analysis.json`). Analysis content never appears in `investigations.json` and investigation content never appears in `analysis.json`.

---

## FULL DIRECTORY TREE

```text
/insight-gaps-platform-root/
│
├── index.html                          # Homepage — Global Console
│                                       # Shows: featured investigation, latest headlines,
│                                       # investigation count, trust badges
│                                       # Pulls data from: investigations.json
│
├── archive.html                        # All Investigations Index
│                                       # Sortable by: date, topic, status
│                                       # Pulls data from: investigations.json
│
├── about.html                          # Mission, methodology philosophy, funding disclosure
│
├── contact.html                        # Secure tip submission, general contact
│                                       # Note: No form backend — use Formspree or similar
│                                       # Do not store tip submissions in Drive
│
├── 404.html                            # Custom error page
│
│
├── assets/                             # SHARED ACROSS ALL PAGES — edit here, applies everywhere
│   │
│   ├── css/
│   │   ├── style.css                   # Global design tokens: colors, typography, spacing, grid
│   │   │                               # All CSS variables live here. Touch this first.
│   │   ├── investigation.css           # Styles specific to investigation pages
│   │   └── components.css             # Cards, banners, badges, tables, nav, footer
│   │
│   ├── js/
│   │   ├── charts.js                   # Reusable D3/SVG chart rendering functions
│   │   ├── maps.js                     # Geospatial rendering — Leaflet or D3 geo
│   │   ├── data-loader.js             # Fetches investigations.json for archive/homepage
│   │   └── ui.js                      # Nav toggle, dark mode, scroll behavior, search
│   │
│   ├── fonts/                          # Self-hosted fonts — no Google Fonts dependency
│   │   └── [font-files]               # Load locally for performance and privacy
│   │
│   └── img/
│       ├── logo.svg                    # Primary wordmark
│       ├── logo-dark.svg              # Inverted version for dark backgrounds
│       ├── og-default.jpg             # Default Open Graph share image (1200x630)
│       ├── favicon.ico
│       └── icons/                     # UI icons — prefer SVG inline
│
│
├── templates/                          # BLUEPRINT FILES — never deploy these directly
│   │                                   # These are the source. Copy to content/ to use.
│   │
│   ├── investigation-blanket.html      # Master investigation page
│   │                                   # Sections: hero, claim, methodology badge,
│   │                                   # data section, visual blocks, source list,
│   │                                   # correction notice slot, related investigations
│   │
│   ├── archive-card.html              # Single investigation card for archive/homepage
│   │                                   # Fields: title, tag, date, status, 1-line summary
│   │
│   ├── chart-block.html               # Reusable chart embed with caption and source line
│   │
│   ├── map-block.html                 # Reusable map embed with legend and coordinate note
│   │
│   ├── data-table.html                # Reusable downloadable data table with source row
│   │
│   ├── analysis-domain.html           # Master domain landing page (e.g. property-preservation/)
│   │                                   # Sections: domain title, description, report card grid,
│   │                                   # last updated, contact/commission prompt
│   │
│   └── analysis-report.html           # Individual analysis report page
│                                       # Sections: report title, tag, date, executive summary,
│                                       # data blocks, charts, findings, methodology note
│
│
├── components/                         # HTML PARTIALS — paste into pages during build
│   │                                   # When site grows: convert to includes or web components
│   │
│   ├── header.html                    # Global navigation — logo, nav links, search
│   ├── footer.html                    # Global footer — about, trust links, contact, RSS
│   ├── methodology-badge.html         # Inline trust badge: links to methodology.html
│   ├── ai-disclosure-bar.html         # Per-page AI use disclosure strip
│   └── correction-banner.html        # Activated when correction exists for this page
│
│
├── content/
│   │
│   ├── investigations/
│   │   │
│   │   ├── INV-001/                    # One folder per investigation — self-contained unit
│   │   │   │
│   │   │   ├── index.html             # Published investigation page
│   │   │   │                           # Built from: investigation-blanket.html template
│   │   │   │                           # Populated with: handoff.md data + architecture.md structure
│   │   │   │
│   │   │   ├── data/
│   │   │   │   ├── raw/               # Source data files — exactly as received
│   │   │   │   │   └── [source-files] # Named: YYYY-MM-DD_source-description.csv
│   │   │   │   └── processed/         # Clean, analysis-ready exports
│   │   │   │       └── [clean-files]  # Named: INV-001_clean_v1.csv
│   │   │   │                           # Rule: raw files are never edited manually
│   │   │   │
│   │   │   ├── visuals/
│   │   │   │   ├── chart-01.svg       # Named by order of appearance in the story
│   │   │   │   ├── chart-02.svg
│   │   │   │   └── map-01.svg
│   │   │   │
│   │   │   ├── og-image.jpg           # Investigation-specific share image (1200x630)
│   │   │   │
│   │   │   └── methodology/
│   │   │       └── methodology.md     # Investigation-specific method note
│   │   │                               # Required before publication
│   │   │                               # Fields: data sources, transformation steps,
│   │   │                               #         verification method, known limitations
│   │   │
│   │   └── INV-002/                    # Same structure. Always.
│   │       └── [same tree as INV-001]
│   │
│   └── trust/
│       ├── methodology.html           # Global methodology framework — how Insight Gaps works
│       ├── ai-use.html               # AI operations ledger — which tools, what roles, what limits
│       └── corrections.html          # Timestamped corrections log — one entry per correction
│                                      # Format: [Date] | [Investigation] | [Error] | [Correction]
│                                      # Rule: entries are never deleted — only appended
│
│
├── analysis/                           # ANALYSIS TRACK — separate from investigations
│   │                                   # Purpose: commercial forensic reports, portfolio showcase
│   │                                   # Audience: business clients, employers, domain specialists
│   │                                   # Same global design system. Different content logic.
│   │
│   ├── index.html                     # Analysis landing page — all domains listed
│   │                                   # Pulls data from: data/analysis.json
│   │
│   └── [domain-name]/                 # One folder per analysis domain — self-contained
│       │                               # Examples: property-preservation/, public-health/, finance/
│       │
│       ├── index.html                 # Domain landing page
│       │                               # Built from: templates/analysis-domain.html
│       │                               # Shows: domain description, report list, last updated
│       │
│       ├── [report-name].html         # Individual report page
│       │                               # Built from: templates/analysis-report.html
│       │                               # One file per report. Self-contained.
│       │
│       └── images/                    # Domain-specific visuals
│           └── [report-previews]      # Named: [report-name]-preview.png
│
│
├── data/
│   ├── investigations.json           # MASTER INDEX — single source of truth for all investigations
│                                      # Updated every time an investigation is published or corrected
│                                      # Fields per entry:
│                                      #   id, title, slug, date, status, topic_tags,
│                                      #   summary (1 sentence), has_correction (bool),
│                                      #   og_image_path
│   │
│   └── analysis.json                 # ANALYSIS INDEX — single source of truth for analysis track
│                                      # Updated every time a domain or report is added
│                                      # Fields per entry:
│                                      #   domain_id, domain_title, domain_slug, description,
│                                      #   report_count, last_updated, reports[]
│                                      #   Each report: id, title, slug, tag, date, summary
│
│
├── docs/                              # OPERATING DOCUMENTATION — not deployed, version controlled
│   ├── 01-operating-principles.md
│   ├── 02-ai-roles.md
│   ├── 03-content-architecture.md    # This file
│   ├── 04-design-system.md           # Typography, color palette, spacing scale, grid rules
│   ├── 05-investigation-workflow.md  # Full investigation lifecycle (iterative)
│   ├── 06-ai-workflow.md             # AI operating engine — the five gates
│   ├── 07-source-protection.md       # OPSEC protocol
│   └── 08-corrections-policy.md      # Corrections and retractions framework
│
│
└── _meta/                             # DEPLOYMENT METADATA
    ├── robots.txt                     # Search engine crawl rules
    ├── sitemap.xml                    # Auto-updated on publication
    └── feed.rss                       # RSS feed — title, date, summary, link per investigation
```

---

## HOW TO ADD A NEW INVESTIGATION

```text
1. Create folder:        /content/investigations/INV-00X/
2. Copy template:        templates/investigation-blanket.html → INV-00X/index.html
3. Create subfolders:    /data/raw/   /data/processed/   /visuals/   /methodology/
4. Build the page:       Populate index.html using architecture.md and handoff.md
5. Write method note:    methodology/methodology.md — required before publication
6. Add to master index:  data/investigations.json — one new entry
7. Deploy:               Firebase push — index.html + data/ + visuals/ + og-image.jpg
```

One investigation. Always the same steps. The structure is the checklist.

---

## HOW TO ADD A NEW ANALYSIS DOMAIN

```text
1. Create folder:        /analysis/[domain-name]/
2. Copy template:        templates/analysis-domain.html → [domain-name]/index.html
3. Create subfolder:     /analysis/[domain-name]/images/
4. Build domain page:    Populate index.html — domain title, description, report list
5. Add to index:         data/analysis.json — one new domain entry
6. Deploy:               Push index.html + images/
```

## HOW TO ADD A NEW ANALYSIS REPORT

```text
1. Build report file:    templates/analysis-report.html → [domain-name]/[report-name].html
2. Add preview image:    [domain-name]/images/[report-name]-preview.png
3. Update domain page:   Add report card to [domain-name]/index.html
4. Update index:         data/analysis.json → append report to domain's reports[] array
5. Deploy:               Push [report-name].html + images/ + updated index.html
```

One domain. One report. Always the same steps.

---

## HOW TO UPDATE GLOBAL DESIGN

```text
- Typography or color change:    assets/css/style.css → CSS variables section
- Component change:              assets/css/components.css
- Navigation change:             components/header.html → re-paste into all pages
- New chart type:                assets/js/charts.js → add function → reuse via template
```

---

## HOW TO PUBLISH A CORRECTION

```text
1. Add correction banner:    Activate correction-banner.html in the affected investigation page
2. Log the correction:       content/trust/corrections.html — append new timestamped entry
3. Update master index:      data/investigations.json → set has_correction: true for that entry
4. Never delete the error:   The original claim and the correction must both be visible
```

---

## STATUS FLAGS FOR investigations.json

| Status | Meaning |
|---|---|
| `published` | Live and verified |
| `corrected` | Published with at least one correction |
| `developing` | Ongoing — not yet published |
| `terminated` | Investigation closed without publication — termination report filed |
| `archived` | Published, no longer actively maintained |

The `terminated` status matters.
A killed investigation is still a completed investigation.
It appears in the archive with status `terminated` and links to its termination report.
Hiding killed investigations from the archive undermines the credibility of the ones that survived.

---

*This document is the canonical reference for platform structure.
All build decisions, template design, and investigation folder creation follow this tree.
The analysis track follows the same discipline — one template, one index, always the same steps.
Deviations require a documented reason and a revision to this file.*
