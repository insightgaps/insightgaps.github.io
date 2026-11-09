# Workflow Stage 10: Corrections & Impact Tracking

**Stage:** 10 · Post-Publication Accountability & Institutional Impact  
**Owner:** Agent 10 (Corrections & Impact Tracker)  
**Inputs:** Published investigation, public inquiries, institutional records  
**Outputs:** Updated `corrections/index.html`, `docs/office/workspace/impact/<slug>-impact-log.md`

---

## 1. Objectives

The Corrections & Impact Tracking stage begins immediately upon publication. It ensures:
1. Complete transparency through an unyielding public corrections log.
2. Systematic tracking of real-world institutional impact at 30, 90, and 180 days.

---

## 2. Corrections Protocol (Zero Stealth-Editing)

The bureau never quietly alters a published story. If an error is detected:
1. **Triage & Classification:**
   - **Clarification:** Language refined for technical accuracy without altering numerical conclusions.
   - **Correction:** Factual, statistical, or mathematical figure revised.
   - **Retraction:** Complete withdrawal of a claim or report (with permanent public notice).
2. **Execution Steps:**
   - Update `investigations/<slug>/index.html` with an alert callout box at the top of the article detailing the correction and timestamp.
   - Append a permanent entry to the public corrections log at `corrections/index.html`.
   - Update the Data Diary and Fact-Check Matrix to maintain reproducible records.

---

## 3. Institutional Impact Tracking Protocol

The bureau defines impact as **tangible institutional, regulatory, or policy accountability**:

| Milestone | Target Channels | Impact Indicators |
| :--- | :--- | :--- |
| **Day 30** | Regulatory Agencies & Ministries | Official statements, agency circulars, taskforce formations, or public inspections initiated. |
| **Day 90** | Parliament & Judiciary | Parliamentary questions tabled, High Court suo motu notices or rulings, regulatory draft rules published. |
| **Day 180** | Long-term Systemic Reform | Gazette amendments enacted, illegal industrial sites dismantled, previously withheld data series published. |

*Vanity metrics (social media likes, pageviews, retweets) are strictly excluded from the impact ledger.*

---

## 4. Deliverable Production

- Update `corrections/index.html` when revisions occur.
- Record all institutional responses in `docs/office/workspace/impact/<slug>-impact-log.md` using `docs/office/templates/impact-log-template.md`.
