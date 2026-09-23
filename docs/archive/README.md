# Session Archive — Agent Handoffs & Reports

Historical build/audit handoffs moved from repo root on 2026-09-23 to keep the root clean and
discoverable. No site templates link to these files, so `scripts/build.py` output is unaffected.
Root keeps only `AGENTS.md`, `START_HERE.md`, `PRODUCTION_STATE_AUDIT.md` plus live site files
(`index.html`, `CNAME`, `.nojekyll`, `sitemap.xml`, `robots.txt`, `site.json`).

## Method-note copies
- `methods/analyze.py` in this repo is the PUBLISHED mirror served at `/methods/analyze.py`
  (linked from Lead Belt methodology + evidence panels). Canonical source lives in the OS repo
  at `insightgaps-os/methods/analyze.py`. Edit the OS copy first, then mirror here and rebuild.

## Sessions (newest last)
- `EXECUTION_STATUS_2026-09-03.md` — deploy status snapshot.
- `PREPARED_CHANGES.md` — staged change list.
- `OWNER_DECISIONS_REQUIRED.md` + `OWNER_DECISION_PACKET.md` — owner decision packs.
- `PHASE5_FINAL_EXECUTION_REPORT.md` — Phase-5 execution.
- `PHASE6_FINAL_PUBLICATION_REPORT.md` — Phase-6 publication.
- `REPORT_AUDIT_HANDOFF.md`, `REPORT_AUDIT_HANDOFF_NEXT_PHASE.md`, `REPORT_AUDIT_INPUT_REQUIREMENTS.md` — audit handoffs.
- `REPORT_FORENSIC_AUDIT_PHASE_3.md` — forensic audit (largest).
- `REPORT_IMPLEMENTATION_COMPLETION.md`, `REPORT_IMPLEMENTATION_REPORT.md` — implementation.
- `REPORT_QA_REPORT.md` — QA.
- `REPORT_SEO_AUDIT.md` — SEO.
- `REPORT_SYSTEM_ARCHITECTURE_PHASE_3.md` — architecture.
- `REPORT_VISUALIZATION_STRATEGY.md` — visualization.
- `WEBSITE_EXECUTION_COMPLETION_REPORT.md` — website completion.
- `ANTIGRAVITY.md` — agent notes.

## Deleted as superseded
- `scratch/audit_website.py` (removed 2026-09-23): hardcoded stale `Administrator` path,
  superseded by `scripts/validate.py` + `tests/test_validate.py`. No references remain.
