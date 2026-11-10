# Workflow Stage 06: Short Story Drafting

**Stage:** 06 · Story-First Narrative Architecture  
**Owner:** Agent 07 (Editor) & Agent 06 (UI Designer)  
**Inputs:** Fact-Check Matrix, Research Plan, Chart SVGs  
**Output:** Initial `investigations/<slug>/index.html` Draft

---

## 1. Objectives

The Short Story Drafting stage establishes the narrative scaffolding for the investigation. It departs from traditional academic whitepapers and legacy newsroom bloat, crafting a **story-first, scannable, high-impact investigation** of approximately 2,000 to 2,500 words.

---

## 2. The 5-Act Forensic Narrative Architecture

Every investigation follows a disciplined 5-act structure:

```
┌─────────────────────────────────────────────────────────────┐
│ ACT 1 · The Breaking System (The Core Empirical Finding)    │
│ - Immediate real-world reality; bold confirmed figures       │
│ - Key stat callout grid (2 to 4 primary metrics)            │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ ACT 2 · The Mechanism of Breakdown                          │
│ - How the systemic or economic engine produces the failure  │
│ - Process schematic (e.g. daily quota, circuit loop)        │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ ACT 3 · The Institutional Void                              │
│ - The data state agencies do not collect or hide            │
│ - Comparison of official claims vs empirical realities      │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ ACT 4 · The Published Official Record                       │
│ - What the state admits in gazettes, audit reports & laws   │
│ - Regulatory history and statutory deadlines violated       │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ ACT 5 · Audited Evidence & Claim Register                   │
│ - Full audited claim table with grades (Confirmed/Supported)│
│ - Expandable <details> tables with raw data & methodology   │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Structural Rules for Ruthless Brevity

1. **Lead with the Numbers:** Never open with general philosophical musings about governance. Open with the specific finding, the exact metric, and the human stakes.
2. **Subheadings Every 250–350 Words:** Break prose into digestible visual modules. Subheadings must be factual statements, not clever puns.
3. **Evidence Box Delegation:** Any table exceeding 5 rows, any complex statistical derivation formula, or any lengthy list of upazilas must be enclosed in `<details class="evidence-box">`. The main scroll must remain clean and readable.
4. **No Meta-Journalism:** Remove all phrases like *"In this report, Insight Gaps examines..."*, *"As we will discover below..."*, or *"Let us first decide..."*. State the evidence directly.

---

## 4. The 90% Full-Bleed Visual Essay Standard (Snow Fall & Pudding Playbook)

All future and current investigations must be drafted following the true full-bleed visual essay playbook:

1. **Full-Bleed Pinned Screens (100svh x 100vw):**
   - Each major empirical finding is presented as a standalone full-screen section (`.scrolly-screen`).
   - The visual is an **Inline SVG** occupying 65%–75% of viewport height with large high-contrast labels ($\ge 28\text{px}$ desktop, $\ge 18\text{px}$ mobile).
2. **Scroll Changes the Chart:**
   - Visual elements animate (bars grow, funnels contract, timeline fills, walkers advance) driven by scroll and `IntersectionObserver`.
3. **10–15 Words per Screen:**
   - Main scroll consists strictly of:
     - Chapter kicker (max 6 words)
     - Screen headline (max 5 words)
     - Big stat hero
     - Pointed on-visual annotation (10–15 words)
   - Zero dense prose paragraphs in the main scroll. Total main-scroll words must remain **under 180 words**.
4. **"You Draw It" Interaction:**
   - Screen 1 must include an interactive guess-then-reveal slider allowing the reader to predict the metric before seeing the audited reality.
5. **Evidence Behind a Tap, Only:**
   - All tables, complete claim registers, five-line summaries, verdict questions, and corrections live exclusively within `<details class="evidence-appendix">` at the foot of the document.

---

## 5. Permanent Standing Rule: "The Missing Variable" Series Architecture

Every investigation produced in the bureau connects to the master story: **"The Missing Variable: A Three-Month Systemic Warning"**.

1. **Predictive Story Arc (Warning, Not After-the-Fact):**
   - Nusrat has NOT died. Tanvir, guided by analytical personas **ORACLE** and **MUKTI**, projects that his sister Nusrat is at severe mortal risk over the next 3 months as the Eid-ul-Fitr travel rush approaches.
   - The story begins at the topic-idea stage: every proposed report must identify which systemic risk factor it investigates in Tanvir's predictive inquiry.
   - Sequence and roles:
     - **Cause 1 of 3:** Blood Routes (*The Danger* — the road transit system that could kill her in the Eid rush)
     - **Cause 2 of 3:** The Impunity Machine (*The Aftermath* — the justice system that offers zero punishment if struck)
     - **Cause 3 of 3:** The Lead Belt (*The Everyday Chronic Risk* — the poisoned environment already surrounding schools and homes)
     - **Cause 4+:** Assigned sequentially to subsequent systemic investigations.
   - Each report's closing screen must link to the next cause or to the central hub (`/investigations/the-missing-variable/`).
2. **Permanent Fiction Guardrails:**
   - Nusrat, Tanvir, ORACLE, and MUKTI are strictly fictional, conceptual motifs for reader engagement and inquiry structuring.
   - The warning is NOT an actuarial prediction about a real person, NOT evidence, and must never be cited as an empirical forecast.
   - Never cite them as evidence or connect them to real individual victims, lawsuits, or workplaces.
   - Every report and hub must include the visible `<span class="fiction-pill">Fictional prediction</span>` tag on Screen 1 and the formal disclaimer at the top of the evidence appendix:  
     *"Fictional prediction — the data is real; the sister, the warning and the prediction are not."*


