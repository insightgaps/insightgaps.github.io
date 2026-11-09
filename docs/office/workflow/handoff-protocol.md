# Inter-Agent Handoff Protocol

**Insight Gaps Data Journalism Office**  
**Specification:** Version 1.0  
**Status:** Mandatory Standard  

---

## 1. Purpose & Architecture

In an autonomous multi-agent newsroom, errors occur at the handoff boundaries between disciplines. If an analyst passes ambiguous column definitions to a visualizer, or if an editor summarizes a calculation without referencing the exact verified denominator, factual distortions arise.

The **Insight Gaps Handoff Protocol** enforces strict, machine-readable, and auditable data contracts between each of the 10 agent roles. No agent may begin work without a validated handoff artifact from the preceding phase.

---

## 2. Master Handoff Sequence

```
Phase 01: Intake ─────────────────────► Artifact: <slug>-intake-memo.md
                                                │
Phase 02: Research Planning ──────────► Artifact: <slug>-research-plan.md
                                                │
Phase 03: Data Ingestion & Cleaning ──► Artifacts: <slug>-data-spec.md + clean CSVs
                                                │
Phase 04: Independent Fact-Check ─────► Artifact: <slug>-fact-check-matrix.md
                                                ├──────────────────────┐
                                                ▼                      ▼
Phase 05: Visual Production ──────────► Assets: SVGs      Phase 06: UI Scaffolding
                                                │                      │
                                                └──────────┬───────────┘
                                                           ▼
Phase 07: Editorial Drafting & Polish ─► Artifact: investigations/<slug>/index.html
                                                │
Phase 08: SEO & Discovery ────────────► Artifacts: JSON-LD + sitemap.xml
                                                │
Phase 09: QA, Staging & Release Gate ──► Artifact: git add -A + release packet
                                                │
                                    [ Human Review & Live Release ]
                                                │
Phase 10: Corrections & Impact ───────► Artifacts: corrections/ + <slug>-impact-log.md
```

---

## 3. Phase-by-Phase Handoff Specifications

### Handoff 01 -> 02: Intake to Research
- **Sender:** Agent 01 (Topic Scout)
- **Receiver:** Agent 02 (Researcher)
- **Mandatory File:** `docs/office/workspace/intake/<slug>-intake-memo.md`
- **Required Fields:**
  - `Slug`: Lowercase alphanumeric hyphenated identifier.
  - `Core Question`: Focused sentence defining the inquiry.
  - `Feasibility Verdict`: Must be `PROCEED`.
  - `Public Dataset Catalog`: At least 3 verified public data URLs or published series.
  - `Null Hypothesis`: Explicit statement of what would prove the system functions.

### Handoff 02 -> 03: Research to Data Analyst
- **Sender:** Agent 02 (Researcher)
- **Receiver:** Agent 03 (Data Analyst)
- **Mandatory File:** `docs/office/workspace/research/<slug>-research-plan.md`
- **Required Fields:**
  - `Statutory Citations`: Exact Bangladesh Acts, Sections, and statutory regulatory limits.
  - `Literature Standards`: Scientific reference values (e.g. WHO/UNICEF thresholds).
  - `Raw Source Roster`: Complete download instructions and filenames for `data/raw/<slug>/`.
  - `Target Metric Definitions`: Explicit definitions of required numerators and denominators.

### Handoff 03 -> 04: Data Analyst to Fact Checker
- **Sender:** Agent 03 (Data Analyst)
- **Receiver:** Agent 04 (Fact Checker / Bulletproofer)
- **Mandatory Files:**
  - `docs/office/workspace/analysis/<slug>-data-spec.md`
  - `data/processed/<slug>/*.csv`
  - `data/raw/<slug>/*`
- **Required Fields:**
  - `SHA-256 Hashes`: Integrity hashes for all raw files.
  - `Data Diary`: Step-by-step transformation scripts/queries.
  - `Key Findings Table`: Numerator, denominator, resulting rate, and date range for every metric.
  - `Denominator Registry`: Source and count for every base population.

### Handoff 04 -> 05 & 06: Fact Checker to Visual & UI Designers
- **Sender:** Agent 04 (Fact Checker)
- **Receivers:** Agent 05 (Visual Designer) & Agent 06 (UI Designer)
- **Mandatory File:** `docs/office/workspace/verification/<slug>-fact-check-matrix.md`
- **Required Fields:**
  - `Audit Verdict`: Must be `PASSED` or `PASSED WITH REVISIONS`.
  - `Audited Claim Register`: Every verified claim with assigned grade (**Confirmed**, **Supported**, or **Probable**).
  - `Recalculation Proof`: Dual-path proof table confirming mathematical parity.
  - **Notice:** Designers may only visualize claims listed in this register.

### Handoff 05 & 06 -> 07: Visual & UI to Editor
- **Senders:** Agent 05 (Visual Designer) & Agent 06 (UI Designer)
- **Receiver:** Agent 07 (Editor)
- **Mandatory Files:**
  - `assets/img/charts/<slug>-*.svg` (All SVGs built to 960px standard)
  - `investigations/<slug>/index.html` (Complete UI scaffolding with evidence boxes)
- **Required Fields:**
  - `Chart Inventory`: File paths, dimensions, titles, and verified figure cross-references.
  - `Component Validation`: Full-width layout confirmation (`.scroll-step--full`, `.page--report`).

### Handoff 07 -> 08: Editor to SEO / Discovery
- **Sender:** Agent 07 (Editor)
- **Receiver:** Agent 08 (SEO / Discovery)
- **Mandatory File:** `investigations/<slug>/index.html` (Complete written narrative)
- **Required Fields:**
  - `Word Count Audit`: Word count strictly between 2,000 and 2,500 words.
  - `Claim Parity Audit`: Confirmation that 100% of figures match the Fact-Check Matrix.
  - `Headline & Deck`: Finalized headline and 150-character meta description.

### Handoff 08 -> 09: SEO to Publisher (Release Gate)
- **Sender:** Agent 08 (SEO / Discovery)
- **Receiver:** Agent 09 (Publisher)
- **Mandatory Files:**
  - `investigations/<slug>/index.html` (Metadata and JSON-LD injected)
  - `sitemap.xml` (Updated)
  - `assets/img/hero-<slug>-gemini.jpg` (Hero image present)
- **Required Fields:**
  - `JSON-LD Schema Verification`: Valid `NewsArticle` structure with no syntax errors.
  - `Canonical URL Check`: Pointing to `https://insightgaps.com/investigations/<slug>/`.

### Handoff 09 -> Human Owner: Publisher to Human
- **Sender:** Agent 09 (Publisher)
- **Receiver:** Human Bureau Owner
- **Mandatory File:** `docs/office/workspace/release/<slug>-release-packet.md`
- **Required State:**
  - **Git Status:** All modified and new files **staged with `git add`** on `main`.
  - **Uncommitted:** Zero commits, zero pushes.
  - **Verification:** 100% local asset and link resolution.
  - **Sign-off Packet:** Complete word count, chart inventory, and diff summary presented for human review.

### Handoff 10: Post-Release Accountability
- **Sender:** Agent 10 (Corrections & Impact Tracker)
- **Receiver:** Public Record & Bureau Archive
- **Trigger:** Reader inquiry, agency correction, or 30/90/180-day milestone.
- **Mandatory Files:**
  - `corrections/index.html` (If error identified)
  - `docs/office/workspace/impact/<slug>-impact-log.md`
