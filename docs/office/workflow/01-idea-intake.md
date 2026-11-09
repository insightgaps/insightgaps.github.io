# Workflow Stage 01: Idea Intake

**Stage:** 01 · Intake & Feasibility Assessment  
**Owner:** Agent 01 (Topic Scout)  
**Input:** Human User Topic Prompt  
**Output:** `docs/office/workspace/intake/<slug>-intake-memo.md`

---

## 1. Objectives

The Idea Intake stage evaluates whether a proposed topic can be investigated into a high-impact, bulletproof report using **exclusively public data**.

The bureau operates on an asynchronous pipeline: the human owner drops a topic idea, and the Topic Scout runs the feasibility algorithm to accept, pivot, or reject the topic within minutes.

---

## 2. The 5-Point Feasibility Rubric

Every topic is scored across five criteria (0–2 points each; minimum score of 8/10 required to proceed):

1. **Public Data Availability (Score 0–2):**
   - 0: Relies entirely on confidential leaks, whistleblowers, or closed databases.
   - 1: Some data exists, but key indicators require estimated proxies.
   - 2: Full public microdata or authoritative institutional series exist (BBS, departmental gazettes, remote sensing, court judgments).

2. **Measurable Outcome Metric (Score 0–2):**
   - 0: Subjective, rhetorical, or philosophical debate without measurable variables.
   - 1: Weakly quantified qualitative trends.
   - 2: Precise numerical variables (fatality rate per km, conviction percentage, ppm chemical concentration, budget disbursement delay).

3. **Statutory & Legal Anchor (Score 0–2):**
   - 0: Ambiguous moral claim without statutory definition.
   - 1: Broad constitutional aspiration (e.g. general right to life).
   - 2: Explicit parliamentary legislation, statutory timeline, or regulatory threshold (e.g. Environment Conservation Act, Road Transport Act).

4. **Public Interest & Systemic Impact (Score 0–2):**
   - 0: Private commercial dispute or partisan political gossip.
   - 1: Narrow regional issue with limited systemic implication.
   - 2: National public health, human rights, infrastructure safety, or fiscal integrity failure affecting millions.

5. **Visual & Story-First Feasibility (Score 0–2):**
   - 0: Abstract financial loop impossible to represent visually.
   - 1: Moderate visual clarity.
   - 2: High visual potential (compelling geographic hotspots, stark macro gaps, or clear multi-stage process failures).

---

## 3. Step-by-Step Procedure

1. **Parse the User Prompt:**
   - Extract the core subject, affected population, responsible government entity, and geographic focus.
   - Assign a clean kebab-case slug (e.g. `oxygen-tariffs`, `embankment-breaches`, `blood-routes`).

2. **Conduct the Public Corpus Scan:**
   - Perform rapid targeted searches across open data repositories:
     - `bbs.gov.bd` (Statistical bulletins, census microdata)
     - `dpp.gov.bd` (Bangladesh Gazette portal)
     - `data.gov.bd` (National open data portal)
     - UN/Multilateral databases (UNICEF MICS, WHO GHO, World Bank)
     - Academic literature indexing (Google Scholar, PubMed, ResearchGate)
     - Remote sensing platforms (Copernicus Browser, USGS EarthExplorer)

3. **Document Anticipated Data Voids:**
   - Formulate what data is intentionally or structurally omitted by state registries (e.g. non-reporting of night-time crashes, absence of soil testing logs).

4. **Complete the Intake Memo:**
   - Author the memo using `docs/office/templates/topic-intake-memo.md`.
   - If score ≥ 8: Mark `PROCEED` and hand off to Agent 02.
   - If score < 8: Mark `REJECT` or propose a revised `PIVOT` that satisfies public data constraints.
