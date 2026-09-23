# Insight Gaps Bureau — Phase 3 Handoff (Next Phase)

**From:** Phase 3 (report forensic audit + presentation-only improvements), 2 September 2026
**Branch:** `phase3-report-improvement` — 6 commits, clean tree, **not pushed** (production push requires owner authorization)
**Read first:** `REPORT_FORENSIC_AUDIT_PHASE_3.md` (the findings), `OWNER_DECISIONS_REQUIRED.md` (the decisions), `REPORT_IMPLEMENTATION_COMPLETION.md` (what changed)

---

## 1. What the report system now is

Static-generated site (frozen Phase-2 infrastructure) + Phase-3 report layer:
- **Manifests** carry evidence-status data (`evidence_refs`: available / private-held / not-in-repository) and subpage maps.
- **Build** renders: investigations index with `#finding-N` anchors, subpage navs, evidence-status panels; NewsArticle JSON-LD on all 8 report routes; homepage stats with basis notes (incl. the source-count definition).
- **Validation** enforces report integrity (NewsArticle presence, evidence-status consistency, badge↔ledger integrity, dead-link disclosure, anchor presence) on top of the Phase-2 site-integrity gate.
- **Slum-fires page** has its verification drawer back (honest per-claim statuses) and the bureau's own limitations text surfaced.
- **Evidence page** labels every unavailable artifact truthfully.

## 2. What must happen next — in order

### Step 1 — Owner decision pass (blocking for everything editorial)
`OWNER_DECISIONS_REQUIRED.md` D-1 … D-11. The highest-consequence ones:
- **D-1/D-6 (corrections):** log the blood-routes 97.13%→41.56% silent correction, the impunity post-publication disclosures, and classify the slum-fires version changes. The corrections page currently says "No corrections issued" while git shows qualifying corrections — this is the bureau's most fixable credibility gap.
- **D-3 (evidence):** publish or de-link the 4 artifacts (impunity master file, osm_schools.geojson, lead-belt v5 dataset, PP dataset). The lead-belt v5 file is described as publication-ready in the bureau's own decision memo but exists in no repository — locate it.
- **D-4/D-5 (slum-fires):** annotation vs unpublishing; homepage-suppression policy or revert.
- **D-8/D-9 (lead-belt/impunity):** number-contradiction resolutions, source-count correction (65 not 91), hero framing.

### Step 2 — Mechanical editorial repairs (after decisions; each is data-driven and small)
- Impunity: fix "91 sources" → 65 everywhere (page footers, manifest, evidence page); remove citations to nonexistent S-26/27/28 or re-map them; reconcile comparator/IPV/tribunal/BMP sets between report and detailed pages; correct "40 acquittals" → 18; align tracker cadence language; handle the 14 Gemini-doc CONFIRMED rows (re-tier or annotate).
- Blood-routes: fix the arithmetically wrong 29% YoY description (actual 19.08%); reconcile the 909/45,891/"single record" audit counts; fix the broken `methodology_link`; disclose the Dhaka→non-Dhaka geographic reassignment in the map's data note; add a limitations section (the pipeline advisory already asked for one).
- Lead-belt: align the five on-page number contradictions (26/19, 68/65, 507/93, 58,000/39,875, ×400/×275); decide snapshot-vs-workbook basis for 145/44/121 and regenerate or caveat; fix manifest date (2025-01-01 → actual).
- Slum-fires: supply the writ citation (9763/2008 is in the bureau's own source log); annotate or unpublish per D-4.
- PP: rewrite the methodology note to describe the real artifact (480 records, Nov 2025–Jun 2026) or restore the matching dataset.

### Step 3 — Infrastructure repairs in the OS repo (publication gate)
- Make `scripts/research.py` exit non-zero on incomplete checklists (currently PASS-with-warnings); make `adversarial_review.py` verify artifact existence, not marker presence; require a human sign-off field that an AI session cannot truthfully fill; add the corrections-log-vs-git-diff check to the pipeline.
- Archive the five impunity EV-### primary documents into a real `assets/BD-INV-002/` folder (the registry's checksummed paths currently point nowhere).

### Step 4 — Deferred presentation work (post-decisions)
- Impunity mobile chart-text repair (0.42–0.55rem) + canvas chart data-table fallbacks.
- Lead-belt accessibility (mobile legend, data-table for map statistics).
- Tracker: either build the described data pipeline (fetch calls, collector, historical-change log) or re-label as a static snapshot.

## 3. What the next engineer/agent must NOT do

- Do not push `phase3-report-improvement` to production without owner sign-off (it contains the restored drawer + surfaced limitations + honest evidence labels — safe, but deployment is the owner's call per the run contract).
- Do not "fix" any claim, number, tier, or methodology statement without an explicit owner decision — every such item is listed, not silently repairable.
- Do not recreate the corrections log entries yourself; the doctrine makes corrections editor-authored.
- Do not treat the pre-publish 🟢 PASS verdicts as evidence of anything (REP-002/035: the gate passed work with 0/12 checklists and empty evidence).
- Do not assume the OS-repo self-audits describe reality (REP-037 family: several affirmatively misdescribe artifacts — verify against files).
- Do not publish anything from `assets/BD-INV-003/` (video-production material incl. AI named-person portraits) or the Anik_OS/trial repos.
- Do not reintroduce client-side hydration, hand-edited `public/`, or per-slug code filters (the homepage exclusion pattern must become manifest-level policy per D-5).

## 4. Open factual questions the owner can answer quickly (high value)

1. Where is `BD-INV-003_LeadBelt_MasterDataset_v5.xlsx/csv`? (The decision memo says completed; no repository holds it.)
2. Does the `assets/BD-INV-002/` evidence folder exist anywhere (the intelligence registry's 5 checksummed paths point to it)?
3. Is there an archived copy of the RSF/BJKS Eid-2026 report behind the 351 headline?
4. Do the slum-fires land-registry/sales records (2006–2026) exist privately?
5. What is the intended publication date of record for the Lead Belt (manifest says 2025-01-01; git says 2026-05-25)?

## 5. Status

- Website infrastructure: stable, validated, frozen.
- Report presentation layer: strengthened within presentation-only bounds; all validation green.
- Journalistic content: untouched, fully audited; per-investigation standing in the audit (Impunity 6.2, Lead Belt 5.8, Blood Routes 4.3, Slum Fires 2.4; system 4.7/10) — driven overwhelmingly by publication-boundary failures, not analysis quality.
- The system can now enforce honesty automatically; the missing pieces (artifacts, corrections entries, claim decisions) are exclusively editorial and await the owner.
