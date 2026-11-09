# Workflow Stage 02: Research Planning

**Stage:** 02 · Statutory Mapping & Hypothesis Formulation  
**Owner:** Agent 02 (Researcher)  
**Input:** `docs/office/workspace/intake/<slug>-intake-memo.md`  
**Output:** `docs/office/workspace/research/<slug>-research-plan.md`

---

## 1. Objectives

The Research Planning stage converts the greenlit intake memo into an actionable empirical research plan. It establishes:
1. The exact statutory limits and legal duties of public agencies.
2. The scientific thresholds recognized by international peer-reviewed literature.
3. The published position of the government from official reports and gazettes.
4. The testable **Hypothesis** versus the **Null Hypothesis**.

---

## 2. Research Protocols (Public Data Only)

- **Zero Field Inquiries:** Do not attempt to interview officials, police officers, factory owners, or victims. The investigation relies exclusively on what the state has committed to writing in public records.
- **Gazette Extraction:** Locate Bangladesh Government gazette notifications (`dpp.gov.bd`), statutory regulatory orders (SROs), and parliamentary question transcripts.
- **International Peer Review:** Identify benchmark standards (e.g. WHO air quality guidelines, CDC lead reference values, ISO standards for road safety design).

---

## 3. Step-by-Step Procedure

1. **Statutory Audit:**
   - Catalog primary legislation (e.g., Road Transport Act 2018, Penal Code 1860, Nari O Shishu Nirjatan Daman Ain 2000, Environment Conservation Act 1995).
   - Identify statutory timelines (e.g. mandatory 90-day trial completion windows, 15-day investigation rules).
   - Document statutory penalties and enforcement agency duties.

2. **Published Government Stance Audit:**
   - Search published annual reports from relevant ministries (e.g., Ministry of Road Transport and Bridges, Ministry of Environment, Forest and Climate Change, Ministry of Law).
   - Search parliamentary questions (`parliament.gov.bd`) and CAG audit reports.
   - Extract official statements made in gazettes or departmental press conferences.

3. **Hypothesis Formulation:**
   - **Investigative Hypothesis:** The systemic failure or regulatory breakdown occurring in practice (e.g. *"Informal lead recyclers operate with impunity within 500m of primary schools despite 2003 gazette bans"*).
   - **Null Hypothesis ($H_0$):** The condition indicating regulatory compliance and normal institutional function (e.g. *"All schools are situated >500m from recycling sites or documented cleanups occurred within 90 days of notification"*).

4. **Data Acquisition Specification:**
   - Detail every dataset to be downloaded by Agent 03, including exact URL, issuing agency, file format, expected row count, and primary key fields.

5. **Deliverable Production:**
   - Output `docs/office/workspace/research/<slug>-research-plan.md` using `docs/office/templates/research-plan.md`.
