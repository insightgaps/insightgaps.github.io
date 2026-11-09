# Workflow Stage 07: Editing & Refinement

**Stage:** 07 · Ruthless Editorial Editing & Fact Parity Audit  
**Owner:** Agent 07 (Editor)  
**Input:** Initial HTML draft from Stage 06  
**Outputs:** Final `investigations/<slug>/index.html`, `docs/office/workspace/editorial/<slug>-editorial-memo.md`

---

## 1. Objectives

The Editing & Refinement stage polishes the drafted report into a diamond-hard investigative piece. The Editor:
1. Cuts visible narrative word count to **2,000–2,500 words**.
2. Audits 100% parity between the Fact-Check Matrix and the published text.
3. Enforces an objective, forensic tone and eliminates moralizing or rhetorical bias.
4. Ensures all evidence tables are accessible within `<details class="evidence-box">`.

---

## 2. The Editorial Cut Checklist

- [ ] **Word Count Check:** Run word counter on visible prose (excluding script, style, and collapsed details tags). Is it between 2,000 and 2,500 words? If >2,500 words, cut further.
- [ ] **Fact Parity Check:** Cross-reference every single number in the text against the Fact-Check Matrix. Are all figures preserved exactly? Are denominators clearly stated?
- [ ] **Passive Voice Elimination:** Convert passive institutional descriptions into active institutional duties (e.g., *"The 90-day statutory window was missed by prosecutors"* -> *"Prosecutors exceeded the 90-day statutory trial deadline by 2,259 days"*).
- [ ] **Jargon Translation:** Translate dense bureaucratic terminology (e.g. SRO numbers, sub-clauses) into plain, precise language while keeping exact statutory citations in parentheses or footnotes.
- [ ] **Public Record Audit:** Verify that no statements imply private interviews or unreturned comment requests. Ensure official stances cite published reports, gazettes, or court submissions.
- [ ] **Evidence Box Accessibility:** Ensure all `<details>` tags have clear, descriptive `<summary>` headings (e.g. `<summary>View Full 64-District Backlog Table & Methodology (64 Rows)</summary>`).

---

## 3. Deliverable Production

- Update `investigations/<slug>/index.html` with polished text.
- Author `docs/office/workspace/editorial/<slug>-editorial-memo.md` certifying:
  - Exact visible word count.
  - Complete list of confirmed facts present in the text.
  - Editor's formal certification of tone and brevity.
