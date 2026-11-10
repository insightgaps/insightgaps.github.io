# Rules and Methods — Insight Gaps Bureau

**Version:** 1.0  
**Effective Date:** 9 November 2026  
**Repository:** `insightgaps/insightgaps.github.io`  
**License:** CC BY 4.0 (Public Data Only)

---

## 1. Operating Mandate: Public Data Only

Insight Gaps is an independent forensic data journalism bureau operating from Dhaka, Bangladesh. The bureau operates strictly under the principle of **Evidence Before Narrative**.

### Core Constraints
- **Public Data Only:** All findings, models, and investigations are derived exclusively from officially published bulletins, government statistics, court records, gazettes, scientific datasets, corporate filings, and satellite imagery.
- **No RTI / FOI Requests:** The bureau does not submit Right to Information (RTI) or Freedom of Information (FOI) requests.
- **No Fieldwork or Interviews:** The bureau does not conduct field interviews, undercover recordings, or direct source outreach.
- **Published Official Record:** Traditional "right of reply" is fulfilled through systematic review of published government responses, parliamentary proceedings, gazette notifications, and official departmental reports.
- **Strict Anonymisation:** Internal working files and examples never contain identifiable personal information, live work-order numbers, or private communications.

---

## 2. The 7-Step Data Journalism Workflow

Synthesised from the scientific workflows of ProPublica, The Markup, and leading international investigative teams, adapted for a small public-data newsroom.

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   STEP 1    │ ──> │      STEP 2      │ ──> │      STEP 3      │ ──> │      STEP 4      │
│ Hypothesis  │     │ Build Dataset    │     │  Bulletproof It  │     │ Independent Check│
└─────────────┘     └──────────────────┘     └──────────────────┘     └──────────────────┘
                                                                                │
┌─────────────┐     ┌──────────────────┐     ┌──────────────────┐              │
│   STEP 7    │ <── │      STEP 6      │ <── │      STEP 5      │ <─────────────┘
│ Log & Track │     │ Publish & Arch.  │     │ Official Record  │
└─────────────┘     └──────────────────┘     └──────────────────┘
```

### Step 1 · Formulate the Hypothesis
- Define a clear, testable question and identify the specific public interest or institutional failure before touching the data.
- State the null hypothesis: what evidence would prove the institutional system is functioning as intended?

### Step 2 · Build the Dataset
- Gather published records: Bangladesh Bureau of Statistics (Census, SVRS, HIES), open government portals (`data.gov.bd`), UN series (WHO, UNICEF, World Bank), court registries, and remote sensing (Copernicus Sentinel-2, Landsat).
- **Data Immutability Rule:** Never edit a raw data file. Store originals in `data/raw/` with exact source filenames and dates. Every transformation generates a new dated file in `data/processed/` (e.g. `INV-001_clean_v1.csv`).
- **Data Diary:** Maintain an exact log of all transformation formulas, scripts, and joins so that any independent analyst can reproduce the clean dataset from scratch.

### Step 3 · Bulletproof the Data
- Apply the complete bulletproofing checklist (§3) before drafting narrative copy.
- Check row counts, totals against summary tables, and inspect outlier distributions.
- Quantify data padding, missing fields, and metadata artifacts (e.g., cross-join duplication).

### Step 4 · Independent Check & Method Peer Review
- Duplicate key calculations with an alternative query or calculation path that must yield the identical answer.
- Pull a random sample of rows and trace them back to the original source record.
- Review findings against published academic and statistical literature.

### Step 5 · Published Official Record & Position
- Examine official published positions: departmental annual reports, official audit reports, ministry press statements, and gazettes.
- If government agencies hold conflicting datasets or fail to publish mandatory registries, document the gap as an institutional finding.

### Step 6 · Publish the Investigation
- Every story ships as a complete package:
  1. Concise, story-first scannable narrative.
  2. Full-width, high-contrast, build-time SVG/HTML charts.
  3. Interactive `<details>` tables for underlying data.
  4. Complete methodology "nerd box" and dataset download links.
  5. Permanent evidence appendix with audited claim register.
- Every chart and table carries an explicit source and date attribution line.

### Step 7 · Log Corrections & Track Impact
- Append corrections to the permanent public log on the day an error is verified (§5).
- Track real-world impact at 30, 90, and 180 days: policy reforms, regulatory closures, official citations, or dataset releases. Impact is institutional change, not pageviews.

---

## 3. Verification & Bulletproofing Checklist

Drawn from Jennifer LaFleur's canonical ProPublica guide (*A Guide to Bulletproofing Your Data*):

- [ ] **Row Count Verification:** Know the expected universe of records. Be suspicious of artifact limits (e.g. 65,536 rows from legacy spreadsheets).
- [ ] **Summary Re-check:** Verify that column sums match official summary tables or gazette totals.
- [ ] **Spelling & Identifier Clustering:** Run `GROUP BY` on all categorical fields to expose transliteration drift (Bangla/English variations, union parishad names).
- [ ] **Missing Field Audit:** Determine whether blank entries reflect true zeros, non-reporting, or export truncations.
- [ ] **False Precision Avoidance:** Avoid unrealistic decimal precision (e.g., round 5.76× to 5.8×; state integer casualties; do not report survey estimates to two decimal places).
- [ ] **Margin of Error & Denominator Discipline:** Never publish a percentage or rate without stating the exact denominator and measurement period.
- [ ] **Lurking Variables:** Before claiming causality, test whether the relationship is driven by population density, daytime traffic volume, or reporting frequency.
- [ ] **Cut-off Date Freeze:** For rolling datasets, set a hard cut-off date and freeze the data snapshot prior to analysis.

---

## 4. Claim Grades

Every factual claim in bureau reports is audited and assigned an explicit credibility grade:

| Grade | Definition | Standard of Proof |
|---|---|---|
| **Confirmed** | Primary verified finding | Independently calculated and cross-verified against primary records or audited clean datasets. |
| **Supported** | Grounded in official reports | Derived from reputable published institutional monitoring (e.g. RSF, BJKS, UNICEF) where raw microdata is held or pending archive. |
| **Probable** | High-confidence structural finding | Corroborated by physical infrastructure, permit routing, or multiple independent secondary sources, but lacking direct beneficial registry proof. |
| **Alleged / Unverified** | Public or legal allegation | Stated in public allegations or media reports; explicitly noted as unverified by official registries. Never stated as fact. |
| **Disproved / Refuted** | Contradicted by evidence | Disproved by recalculation, forensic audit, or primary records (e.g. discarded data padding). |

---

## 5. Permanent Corrections Log Rules

Credibility requires absolute transparency when errors occur.

1. **Append-Only Ledger:** Corrections are never deleted or rewritten. Entries are permanently appended to `/corrections/`.
2. **On-Story Disclosure:** When a correction affects a published investigation, a visible, dated correction banner is placed on the story page above the methodology section.
3. **Structured Entry Format:**
   ```
   [Date] · [Investigation ID] · [Claim Code]
   - Error Identified: Exact text or figure previously published.
   - Correction Executed: Corrected figure, arithmetic derivation, and source.
   - Editorial Context: Explanation of why the error occurred (e.g. calculation typo, updated baseline).
   ```
4. **Minor Typos:** Pure spelling or punctuation fixes that do not alter meaning or numbers are fixed silently without cluttering the log.

---

## 6. Chart & Data Visualization Readability Rules

All charts and diagrams must adhere to strict desktop readability rules:

- **Desktop Full Width:** Charts must render at full width (up to 960px container width). Never squeeze visuals into narrow 300px sticky sidebars on PC screens.
- **Minimum Legible Text Sizes on Desktop:**
  - Chart Display Titles: `18px – 22px` bold
  - Axis Labels & Categories: `14px – 16px`
  - Data Values & Highlights: `18px – 24px` bold
  - Methodology Captions & Sources: `13px – 14px`
- **High Contrast:**
  - Dark text `#16130f` on light backgrounds (`#ffffff`, `#fcfbf9`).
  - Dark red accent `#8c2b18` for primary findings; amber `#c17d11` for warnings; charcoal `#5c5954` for baselines.
  - Borders must be clean and distinct (minimum 1.5px–2px stroke).
- **SVG / HTML Native Only:**
  - No third-party iframes (Flourish, Datawrapper, Tableau).
  - No embedded low-resolution bitmap text.
  - Zero external tracking or external script dependencies.
- **Reuters Core-Trend Rule:** The primary finding must be readable instantly at normal desktop zoom without clicking, zooming, or hovering.
- **Visual Vocabulary Discipline:**
  - Bar charts for discrete comparisons and rankings.
  - Stacked/segmented bars for part-to-whole proportions.
  - Process diagrams / flowcharts for regulatory chains and funnels.
  - No 3D charts, no pie charts with more than two elements, no decorative fluff.

---

## 7. SEO, Structured Data & Discoverability Rules

- **NewsArticle JSON-LD:** Every investigation page must include valid `NewsArticle` schema containing headline, description, author organization, datePublished, dateModified, and full-resolution image URL.
- **Standard XML Sitemap:** Maintain a standard, valid `sitemap.xml` covering all canonical routes.
- **Client-Side Search:** Use Pagefind for zero-latency, privacy-respecting client-side full-text search indexing story text, methodology, and evidence sections.
- **Semantic Metadata:** Canonical URLs, Open Graph tags (`og:title`, `og:description`, `og:image`), and Twitter summary cards on all primary pages.
- **Zero Third-Party Trackers:** No tracking pixels, Google Analytics, or invasive cookies.

---

## 8. Design System Tokens

The visual language communicates forensic precision, editorial authority, and maximum legibility.

### Typography
- **Headlines & UI:** `Space Grotesk` (700 bold, 600 semibold)
- **Body & Prose:** `Lora` (400 regular, 400 italic, 700 bold)
- **Data & Timestamps:** `Space Mono` (400 regular, 700 bold)

### Type Scale
| Token | Size | Font | Weight | Use |
|---|---|---|---|---|
| `--type-display` | 48px | Space Grotesk | 700 | Homepage headline |
| `--type-h1` | 36px | Space Grotesk | 700 | Investigation titles |
| `--type-h2` | 24px | Space Grotesk | 600 | Section headings |
| `--type-h3` | 18px | Space Grotesk | 600 | Subsections, card titles |
| `--type-body` | 17px | Lora | 400 | Prose body copy (line-height 1.7) |
| `--type-body-sm` | 15px | Lora | 400 | Captions, footnotes, table text |
| `--type-label` | 12.5px | Space Mono | 700 | Status badges, case IDs |
| `--type-data` | 14px–16px| Space Mono | 700 | Data labels, metric counters |

### Color Tokens
| Token | Hex | Role |
|---|---|---|
| `--color-bg` | `#F9F8F6` | Warm paper page background |
| `--color-surface` | `#FFFFFF` | Elevated cards, chart backgrounds |
| `--color-text-primary` | `#1A1917` | Primary prose and high-contrast text |
| `--color-text-secondary` | `#5C5954` | Secondary labels, captions, metadata |
| `--color-text-muted` | `#9C9891` | Timestamps, placeholder annotations |
| `--color-accent` | `#8C2B18` | Investigation primary red accent |
| `--color-accent-amber` | `#C17D11` | Secondary identity amber / caution |
| `--color-border` | `#E2E0DC` | Hairline dividers, card outlines |
| `--color-border-strong` | `#16130F` | Heavy structural borders (2px) |

### Layout Grid
- **Prose Column:** `720px` (comfortable 65–75 character reading measure)
- **Visual & Chart Width:** `960px` (full desktop reading width for SVGs and data tables)
- **Max Page Width:** `1200px`

---

## 9. The 90/10 Visual Essay Standard (The Pudding & NYT Style)

All core investigations must follow the **90/10 Visual Essay** presentation format:

1. **One Visual per Screen:** Full width (up to 960px container), chart fills the viewport cleanly without cramped sidebars.
2. **On-Visual Annotation:** A crisp 10–15 word annotation card pointing directly to the decisive bar, line, or metric that drives the finding.
3. **Scroll-Driven Progression:** The vertical scroll advances the story sequentially (bars compare, funnels narrow, distance scales move).
4. **Ruthless Scroll Economy:** Zero dense prose in the main scroll. Each screen consists strictly of:
   - Screen kicker / eyebrow
   - Punchy headline stating the finding
   - Prominent stat callout badge
   - Full-width SVG chart
   - 10–15 word pointed annotation
   - 1–2 sentence narrative spine
   - Interactive `<details>` decision point ("Decide first... Reveal...")
5. **The Narrative Spine ("The Missing Variable"):** An anonymised human spine (Tanvir searching for his sister Nusrat, guided by data agent VIGIL and inquiry agent MUKTI) threads through each screen, grounding technical datasets in human consequences without ever fabricating evidence, naming living individuals, or referencing interviews.
6. **Narrator Decision Point:** At each screen or step, the narrator halts and prompts the reader to decide before revealing the audited regulatory or empirical finding.
7. **Five-Line Summary & Verdict:** The story concludes with an exact 5-line factual takeaway followed by a verdict callout handing judgment to the reader.
8. **Evidence Appendix Behind a Tap:** All comprehensive data tables, complete claim registers (with grades Confirmed/Supported/Contested), regulatory citations, documented gaps, and permanent corrections logs are enclosed within an expandable `<details class="evidence-appendix">` element. Every verified number remains 100% accessible and verifiable upon tap.

