# Insight Gaps Data Journalism Office

**Autonomous Operating System for Public-Data Investigations**  
**Repository:** `insightgaps/insightgaps.github.io`  
**Branch:** `main`  
**License:** CC BY 4.0 (Public Data Only)

---

## 1. Bureau Mission & Operating Philosophy

The **Insight Gaps Data Journalism Office** is an autonomous newsroom operating system designed for rigorous, evidence-first forensic investigations based exclusively on public data.

### The Single-Input Model
The human publisher provides only **one input**:
> **A Topic Idea** (e.g., *"Medical oxygen tariff exemptions vs hospital supply shortages in divisional towns"* or *"River sand-mining lease boundaries vs flood embankment breaches"*).

From that single topic idea, the office coordinates ten specialized autonomous roles across a disciplined nine-stage pipeline, delivering a verified, shortened, mobile/PC-responsive, interactive investigation report staged for human owner review and release.

### Fundamental Operating Boundaries (Immutable Rules)
1. **Public Data Only:** All findings derive from published statistical datasets, gazettes, corporate filings, remote sensing, and institutional audit reports.
2. **Zero Invasiveness:** No Right to Information (RTI) or FOI filings; no field interviews; no undercover inquiries; no direct source outreach.
3. **Published Official Record:** Institutional response is assessed exclusively through published parliamentary proceedings, official audit reports, ministry statements, and gazette notifications.
4. **Zero Invented Figures:** Every number published must have an unbroken audit trail to a public primary or secondary source.
5. **Short & Story-First:** Investigations are written for maximum human impact—scannable, concise (~2,000 to 2,500 words), with heavy data tables organized inside expandable `<details class="evidence-box">` elements.
6. **Desktop & Mobile Legibility:** All graphics are pure SVG/HTML, rendered full-width (960px baseline on PC) with minimum 14px typography and WCAG AA contrast.
7. **Strict Staging Gate:** Autonomous agents prepare, build, test, and stage (`git add`) changes. Human approval is strictly required before commit and production push.

---

## 2. Directory Architecture

```
docs/office/
├── README.md                          # Office master architecture and operating manual
├── agents/                            # Standalone Antigravity agent role briefs
│   ├── 01-topic-scout.md             # Topic intake, viability filtering, public data mapping
│   ├── 02-researcher.md              # Public record search, academic literature, legal baseline
│   ├── 03-data-analyst.md            # Dataset ingestion, normalization, calculations, data diary
│   ├── 04-fact-checker-bulletproofer.md # Dual-path calculation check, claim grading (A-F), audit
│   ├── 05-visual-designer.md         # 960px responsive SVG production, high-contrast palettes
│   ├── 06-ui-designer.md             # Page structure, typography, component integration, scrollytelling
│   ├── 07-editor.md                  # Narrative pacing, story-first editing, ~2,200w condensation
│   ├── 08-seo-discovery.md           # NewsArticle JSON-LD, sitemap updates, Pagefind search indexing
│   ├── 09-publisher.md               # HTML/asset QA, broken link check, git staging gatekeeper
│   └── 10-corrections-impact-tracker.md # Post-publication monitoring, correction log, impact audits
├── workflow/                          # Phase-by-phase operational workflow manuals
│   ├── 01-idea-intake.md             # Topic assessment rubric & public feasibility screen
│   ├── 02-research-planning.md       # Hypothesis framing & null hypothesis declaration
│   ├── 03-dataset-build-and-clean.md # Raw data immutability & transformation rules
│   ├── 04-independent-verification.md # Dual calculation paths & bulletproofing checklist
│   ├── 05-visual-and-chart-production.md # Vector standards, contrast, PC readability rules
│   ├── 06-short-story-drafting.md    # Story-first structure & scannable editorial rules
│   ├── 07-editing-and-refinement.md  # Tone enforcement, jargon cuts, evidence box migration
│   ├── 08-seo-and-schema-markup.md   # Metadata, OpenGraph cards, search engine discovery
│   ├── 09-pre-publication-audit-and-publish.md # Pre-flight validation, asset verification, git add
│   ├── 10-corrections-and-impact-tracking.md # 30/90/180-day impact tracking & transparent corrections
│   └── handoff-protocol.md           # Standardized inter-agent handoff data contracts
├── templates/                         # Standardized documentation and code templates
│   ├── topic-intake-memo.md          # Topic intake assessment template
│   ├── research-plan.md              # Investigation research plan template
│   ├── data-dictionary-and-cleaning-spec.md # Data catalog and transformation log template
│   ├── fact-check-bulletproof-matrix.md # Line-by-line claim audit matrix
│   ├── chart-spec.md                 # SVG visualization design specification
│   ├── short-investigation-template.html # Clean investigation HTML boilerplate
│   ├── evidence-appendix-template.html # Evidence & data appendix HTML boilerplate
│   ├── correction-entry-template.md  # Corrections log record format
│   └── impact-log-template.md        # Institutional impact tracking ledger
└── design-system/                     # UI components, design tokens, and page templates
    ├── README.md                     # Design tokens, color system, typography rules
    ├── components.md                 # Complete reusable HTML/CSS component library
    └── templates/                    # Core responsive HTML page blueprints
        ├── page-home.html            # Bureau frontpage blueprint
        ├── page-investigation.html   # Investigation feature story blueprint
        ├── page-evidence.html        # Raw data and methodology appendix blueprint
        ├── page-methodology.html     # Standards and trust documentation blueprint
        ├── page-corrections.html     # Public corrections log blueprint
        ├── page-search.html          # Client-side Pagefind search blueprint
        ├── page-archive.html         # Longitudinal investigation index blueprint
        └── page-topic-intake.html    # User topic submission & triage interface
```

---

## 3. End-to-End Pipeline Summary

```
[ User Topic Idea ]
         │
         ▼
[ 1. Topic Scout ] ──> Evaluates against Public Data Rubric (Pass/Fail)
         │
         ▼
[ 2. Researcher ] ──> Maps published datasets, legal statutes, and null hypothesis
         │
         ▼
[ 3. Data Analyst ] ──> Cleans data, normalizes denominators, produces Data Diary
         │
         ▼
[ 4. Fact Checker / Bulletproofer ] ──> Dual-calculates, grades claims (Confirmed/Supported/Probable)
         │
         ▼
[ 5. Visual Designer ] ──> Builds 960px high-contrast responsive SVG diagrams
         │
         ▼
[ 6. UI Designer ] ──> Assembles responsive HTML with story-first layout & evidence boxes
         │
         ▼
[ 7. Editor ] ──> Cuts repetition to ~2,200 words, tunes narrative arc, enforces tone
         │
         ▼
[ 8. SEO / Discovery ] ──> Injects NewsArticle JSON-LD, OpenGraph, sitemap, Pagefind tags
         │
         ▼
[ 9. Publisher ] ──> Performs pre-flight link/asset verification, executes git add
         │
         ▼
[ Human Owner Review ] ──> Inspects staged changes, tests in browser, approves commit/push
         │
         ▼
[ 10. Corrections & Impact Tracker ] ──> Monitors published impact at 30/90/180 days; logs corrections
```

---

## 4. How to Run an Investigation

To launch an investigation, start a new Antigravity session on this repository and invoke the pipeline:
1. Provide the topic idea using the format in [templates/topic-intake-memo.md](file:///c:/Users/ah_an/OneDrive/Desktop/insightgaps/insightgaps.github.io/docs/office/templates/topic-intake-memo.md).
2. The agent adopts the [01-topic-scout.md](file:///c:/Users/ah_an/OneDrive/Desktop/insightgaps/insightgaps.github.io/docs/office/agents/01-topic-scout.md) prompt to perform the initial intake assessment.
3. Upon milestone sign-off, subsequent agent prompts are applied sequentially or in coordinated stages.
4. All work is saved locally in `investigations/<slug>/` and `assets/img/charts/`.
5. When complete, the publisher agent stages the files (`git add -A`) and produces the final handoff report for your review.
