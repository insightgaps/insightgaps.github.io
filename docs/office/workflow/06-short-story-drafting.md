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
