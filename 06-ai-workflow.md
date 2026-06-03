# 06-ai-workflow.md — Insight Gaps AI Operating Engine
**Version:** 1.0 — Pre-INV-001 Calibration Draft
**Status:** Active
**Last revised:** Pre-first investigation
**Next revision trigger:** After INV-001 retrospective

---

## CORE OPERATING PRINCIPLE

The system is governed by file states, not memory or checklists.
No phase executes without its entry artifact present in the repository.
The investigation and the system revision are both legitimate outputs of every run.

---

## THE TWO-OUTPUT RULE

Every investigation produces two deliverables:

1. **The story** — the published investigation
2. **The system revision** — a better operating document, based on the friction log

Neither output is optional.
If only the story is delivered, the calibration run failed.

---

## WORKFLOW RETURN TRIGGERS

The investigation workflow is not linear.
Any of the following conditions requires returning to an earlier stage:

- New evidence contradicts the central claim
- A source dispute emerges after evidence has been sorted
- Key variables are missing or unreliable
- A visual or geographic claim cannot be independently verified
- The draft exceeds the boundary of the available evidence
- A key source withdraws or requests removal
- **The original question turned out to be the wrong question**

The last trigger is the most common and the most likely to be ignored.
When the framing changes, the investigation does not fail — it recalibrates.
Motivated reasoning enters when teams suppress this trigger to protect sunk work.

---

## THE FIVE ARTIFACT GATES

### GATE 1 — INGESTION
**Entry condition:** Raw unstructured assets present in `/data/raw/`
**Active stack:** Gemini Pro / NotebookLM
**Action:** Deep extraction — textual, statistical, geospatial, documentary
**Verification check:** Every extracted claim must trace to a source file. Unsupported extractions are flagged, not deleted.
**Output (the gate):** `.handoff.md` saved to the active investigation directory

---

### GATE 2 — STRATEGIC WIREFRAME
**Entry condition:** Verified `.handoff.md` present
**Active stack:** ChatGPT (Mode: Sandbox Partner)
**Action:** Narrative angle ideation, UX layout planning, data visualization strategy
**Constraint:** ChatGPT has no persistent context. Re-brief fully at every session. Treat output as structured input, not decision.
**Output (the gate):** `architecture.md` — maximum 5 bullets, committed to active branch, frozen before Gate 3

**Prompt template:**
> "Read `.handoff.md`. Act as my Sandbox Partner. Propose three narrative angles based strictly on the verified data boundaries in this file. Do not introduce claims that are not grounded in the handoff."

---

### GATE 3 — BUILD
**Entry condition:** Frozen `architecture.md` and `/docs/02-design-system.md` both present
**Active stack:** Codex / Claude Code / Antigravity
**Action:** Component generation, data processing scripts, layout compilation
**Constraint:** No architectural decisions at this stage. Implementation only. Deviations require returning to Gate 2.
**Output (the gate):** Successful compile and deployment to Firebase Staging URL

---

### GATE 4 — ADVERSARIAL REVIEW
**Entry condition:** Active Firebase Staging URL
**Active stack:** ChatGPT (Mode: Adversarial Editor) + Claude (Mode: Coherence Review)
**Action:**
- ChatGPT: Pressure-test data correlations, factual claims, mobile UI rendering
- Claude: Review narrative coherence, logic hierarchy, readability, ambiguity

**Output (the gate):** Single-sentence sign-off OR targeted patch list returned to Gate 3

**Prompt template (ChatGPT):**
> "Review this staging output and handoff file. Act as my Adversarial Editor. Identify the single most vulnerable analytical claim or UI problem before public release."

**Prompt template (Claude):**
> "Review this draft. Does the logic follow from the evidence? Where is the hierarchy unclear? What should be cut? Where does the text exceed what the data supports?"

---

### GATE 5 — LEGAL AND COMPLIANCE SIGN-OFF
**Entry condition:** Zero high-risk flags remaining from Gate 4
**Active stack:** ChatGPT (Mode: Risk Officer)
**Action:** Data anonymity verification, source metadata sanitation, coordinate validation, libel exposure check
**Output (the gate):** Human owner manual push to `main`

**The human decision is the gate. No tool substitutes for this.**

---

## VERIFICATION TIERS BY INVESTIGATION TYPE

Verification standards are not universal. Apply the correct tier.

### Tier 1 — Document-Heavy Investigations
*(regulatory failures, environmental records, public health data)*
- Central claim requires a traceable primary document
- All statistics require original source, not secondary reporting
- Government records preferred over NGO summaries unless NGO has primary data
- Geographic claims require coordinate verification

### Tier 2 — Data-Driven Investigations
*(quantitative analysis, pattern detection, comparative datasets)*
- Analysis must be reproducible from raw data using documented scripts
- No manual edits to raw data files — transformations via script only
- Outliers must be explained, not removed without documentation
- Methodology note is mandatory before publication

### Tier 3 — Source-Driven Investigations
*(testimony, interviews, field observation)*
- Minimum two independent sources for any central claim
- Source identity protected in all internal notes (use codenames or role descriptors only)
- On-record vs. off-record status documented for every source before drafting
- No claim from a single anonymous source without corroborating documentary evidence

---

## SOURCE PROTECTION AND OPSEC

*Written for source trust, not internal convenience.*

**What is protected:**
- Source identity in all working files — use role descriptors (e.g. "Government Inspector, Gazipur") not names
- Location specifics that could identify a source
- Communication metadata

**Where sensitive material lives:**
- NOT in Google Drive — Drive is not a secure environment for sensitive source information
- Field notes with source identity: encrypted local storage only
- Source contact details: outside the investigation repository entirely

**What goes in Drive:**
- Published reports, public documents, exported data, design assets
- Nothing that would compromise a source if the account were accessed

**Source removal protocol:**
- If a source requests removal after contribution: document the request, assess what can be redacted, escalate to human owner for final decision
- No AI tool processes this decision

**When explaining this to a source:**
> "Your identity is never stored in the same system as the investigation files. We use role descriptors internally. If you ask to be removed, that decision is made by the editor, not automated."

---

## AI ROLE QUICK REFERENCE

| Tool | Primary role | What it must not own |
|---|---|---|
| ChatGPT | Strategy, architecture, adversarial critique | Final editorial decisions, persistent context assumed |
| Gemini Pro | Long document synthesis, source pattern detection | Unverified factual claims, final framing |
| Claude | Editorial coherence, prose clarity, narrative logic | Repository management, research sourcing |
| Codex / Claude Code | Implementation, component builds, scripts | Architecture not yet approved |
| Antigravity | Agentic multi-step execution, automation | Editorial judgment, autonomous publication |
| NotebookLM | Source vault, citation-grounded research memory | Final editorial synthesis |
| Human owner | Every final decision | Nothing is delegated at the final gate |

---

## INV-001 FOLDER INITIALIZATION

When starting the first investigation, create:

```
/experiments/
  INV-001/
    /01-raw/
    /02-research/
    /03-handoff/
    /04-planning/
    /05-build/
    /06-review/
    /07-publish/
    /08-retrospective/
      friction-log.md
```

Each folder is a gate checkpoint.
The folder structure is the checklist. No separate checklist needed.

---

## FRICTION LOG — TEMPLATE

**File:** `/experiments/INV-001/08-retrospective/friction-log.md`
**Rule:** One line per entry, captured in the moment. Do not stop to analyze mid-investigation. Analyze after publication.

```
## Friction Log — INV-001

| # | Stage | Friction type | Notes |
|---|---|---|---|
| 1 | Gate 2 | Decision not covered | Architecture.md format was unclear — how many bullets is "frozen"? |
| 2 | Gate 3 | Tool confusion | Unclear whether Codex or Antigravity owns this step |
| 3 | Gate 1 | Slow step | Handoff.md took 3x longer than expected — Gemini session needed full re-brief |
| ... | | | |
```

**Friction types to watch for:**
- Decision not covered by the document
- Unclear workflow ownership
- Tool confusion
- Step slower than expected
- Unexpected failure or error
- Repeated manual work that should be automated
- Workflow return triggered — which trigger, which stage
- Original question changed — note what changed and why

**After publication:** Use this log as the sole basis for revising this document. Do not revise from memory.

---

## CORRECTIONS FRAMEWORK

**Detection:** Any team member or reader may flag a potential error.
**Verification:** Human owner confirms the error against primary source.
**Decision:** Human owner decides correction type:
- Minor factual correction: update in place, add correction note with timestamp at bottom of page
- Structural error affecting central claim: publish separate correction page, note on original
- Source-level error: assess whether source protection is implicated before correcting publicly

**Rule:** Corrections go up faster than the original publication went out. Speed of correction is a credibility signal.

---

## ESCALATION RULES

| Problem type | First tool | Note |
|---|---|---|
| Strategic / architectural | ChatGPT | Re-brief fully. No assumed context. |
| Research-heavy | Gemini / NotebookLM | Source-grounded only |
| Writing clarity / coherence | Claude | |
| Implementation / code | Codex / Claude Code | |
| Multi-step automation | Antigravity | Human approval required |
| Deployment | GitHub / Firebase | |
| Final publication decision | Human owner only | Non-negotiable |

---

## OPERATING PRINCIPLES

1. Do not confuse research with publication.
2. Do not confuse strategy with implementation.
3. Do not confuse automation with editorial judgment.
4. Do not let tools make final decisions.
5. Prefer reusable systems over one-off output.
6. Prefer clarity over complexity.
7. Prefer review over trust.
8. Prefer source-backed work over unsupported generation.
9. The methodology must remain defensible even if every tool in the stack changes.
10. The first investigation is a calibration run. Discovering where reality disagrees with the design is a valid output.

---

*This document is revised after every investigation, using the friction log as the sole source of revision input.*
