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

## 9. The 90% Full-Bleed Visual Essay Standard (Reverse-Engineered Playbook)

All investigations published by the bureau must follow the true **90% Full-Bleed Visual Essay** standard, reverse-engineered from benchmark visual journalism (*NYT Snow Fall*, *Guardian Firestorm*, *NYT A Game of Shark and Minnow*, *SBS The Boat*, *Bloomberg "What's Really Warming the World?"*, *The Pudding*, and *NYT You Draw It*):

1. **Pinned Full-Bleed Visuals:**
   - Visuals are full-bleed edge-to-edge (`100vw`, `min-height: 100vh; min-height: 100svh; height: 100svh`).
   - One visual fills the entire viewport on desktop and mobile. No 960px or 68ch text column constraints on visual screens.
   - The visual is an **Inline SVG** (never an `<img>` or iframe), taking up 65%–75% of viewport height, with massive legible labels ($\ge 28\text{px}$ on desktop, $\ge 18\text{px}$ on mobile).
2. **Scroll Changes the Chart:**
   - As the reader scrolls, the visual builds step-by-step (bars grow, funnels narrow, scale walkers advance, timelines illuminate).
   - Powered by CSS scroll-driven animations (`animation-timeline: view()`) with a JavaScript `IntersectionObserver` fallback.
3. **10–15 Words at a Time:**
   - Main-scroll text is strictly restricted to:
     - Chapter kicker (max 6 words)
     - Screen headline (max 5 words)
     - One massive stat hero
     - One pointed annotation of 10–15 words placed directly ON/beside the visual
   - Zero dense paragraphs in the main scroll. Total main-scroll words must remain **strictly under 180 words per report**.
4. **You Draw It (NYT Interaction):**
   - Each report features an interactive guess-then-reveal slider widget on Screen 1, allowing the reader to guess the metric before revealing the verified truth.
5. **Top Progress Spine:**
   - A 4px fixed reading progress bar (`.visual-progress-bar`) tracks scroll position from 0% to 100%, alongside numbered chapter pills (e.g. `1/5 · THE GAP`).
6. **Evidence Behind a Tap, Only:**
   - All claim registers, data tables, regulatory citations, five-line summaries, reader verdict questions, and permanent correction logs are placed exclusively inside a single collapsed `<details class="evidence-appendix">` at the foot of the document.

---

## 10. Permanent Series Architecture: "The Missing Variable"

**Standing Editorial Mandate for All Past, Present, and Future Reports:**

Every investigation produced by the Insight Gaps Bureau is connected as part of a single unified overarching story: **"The Missing Variable: A Three-Month Systemic Warning"** (expanding across sequential causes).

### 1. The Unified Predictive Story Arc
- **Predictive Architecture (Warning, Not After-the-Fact):** Nusrat has NOT died. Tanvir, guided by analytical personas **ORACLE** and **MUKTI**, discovers patterns across state and commercial datasets that predict Nusrat faces acute mortal peril over the next three months.
- **The Critical Window:** The upcoming Eid-ul-Fitr travel rush represents the primary convergence window where regulatory failure turns lethal.
- **Sequential System Roles (Road → Justice → Poison):**
  - **Cause 1 of 3: Blood Routes (*The Immediate Hazard*):** The road transit system that could kill her in the Eid rush (351 deaths in 15 days, 41.56% night window, predatory joma lease incentives, phantom Phoenix buses).
  - **Cause 2 of 3: The Impunity Machine (*The Aftermath if Struck*):** The criminal justice system that guarantees zero deterrence or accountability (0.46% conviction rate, 2,349-day verdict delay, 92% DNA backlog).
  - **Cause 3 of 3: The Lead Belt (*The Everyday Chronic Risk*):** The toxic industrial environment already poisoning her community (illegal battery furnaces 59m from primary school gates, 680,872 ppm peak soil lead, 22 years of zero cleanups).
  - *Future Investigations (Cause 4, Cause 5, ...):* Each subsequent investigation explores another systemic vector in Tanvir's ongoing predictive investigation.
- **Navigation & Links:** Each report identifies its cause number and role in the opening header, maintains the 10–15 word thematic framing, and closes with a forward transition card pointing to the next cause or hub.

### 2. Strict Fiction Guardrails (Permanent)
- **Fictional Prediction Only:** Nusrat, Tanvir, ORACLE, and MUKTI are entirely fictional conceptual motifs used strictly for narrative coherence and human-centred engagement.
- **The Prediction is NOT Evidence:**
  - The warning is not a real individual actuarial forecast, never describes a living person, and never cites confidential files.
  - The prediction must **NEVER** be converted into a data claim or empirical probability attributed to a real person.
  - All data points, institutional audits, and statutory analyses are 100% verified public facts.
- **Mandatory Disclaimers:**
  - Every report and hub must display a visible `<span class="fiction-pill">Fictional prediction</span>` badge on its opening screen.
  - Every report's evidence appendix must lead with the permanent disclaimer:  
    *"Fictional prediction — the data is real; the sister, the warning and the prediction are not. This narrative motif is an anonymised conceptual framing device connecting separate public-data investigations into systemic accountability. Nusrat and Tanvir are invented characters."*



