# Insight Gaps Bureau — Report Audit Handoff

**From:** Phase 2 (website execution), 2 September 2026
**To:** Phase 3 — Investigation / Report Forensic Audit
**Status:** WEBSITE PHASE: READY FOR REPORT AUDIT

---

## 1. What the website architecture now is

A **generated static site**. Source content lives in the repository (`content/`, manifests, templates, `site.json`); `python scripts/build.py` renders the complete site into `public/`; `python scripts/validate.py` gates it (fail-closed); Cloudflare Pages builds on every push (`cloudflare-pages.toml`; `main` = production, branches = previews). Generated output is never committed or hand-edited. Full detail: `WEBSITE_EXECUTION_COMPLETION_REPORT.md`; operator basics: `docs/runbook.md`.

## 2. What the website exposes

- **Canonical URL tree** (single host `https://www.insightgaps.com`): `/`, `/investigations/[slug]/{,detailed,methodology,tracker}/`, `/analysis/[slug]/`, `/archive/`, `/evidence/`, `/trust/{methodology,ai-use,corrections}/`, `/about/`, `/contact/`
- **All legacy routes 301** to canonical equivalents (generated `_redirects`); `/data/*.json` files still served (frozen report pages fetch them)
- **Pre-rendered content everywhere** — listings, stats, archive work without JS; only the archive filter is a JS enhancement
- **Per-work manifests** (`content/investigations/<slug>/investigation.json`) drive the sitemap, indexes, cards, stats, and metadata — a published work cannot be half-rendered
- **Append-only corrections log** (`corrections.log.jsonl`) renders into `/trust/corrections/`
- **Structured data:** Organization JSON-LD on every page, WebSite on home (report-page JSON-LD untouched — frozen)

## 3. What repositories the website depends on

None at build time — the build clones nothing and reads only this repo. The **content**, however, cross-references two private repositories the report audit must examine: the `assets` repo (raw BD-INV evidence files) and the OS repo (production pipeline and datasets). See `REPORT_AUDIT_INPUT_REQUIREMENTS.md`.

## 4. What remains unknown (deliberately undecided)

| Item | Default in force | Decision owner |
|---|---|---|
| Property-preservation final placement | Stays at `/analysis/property-preservation/` (WAIT) | Owner |
| Five owner-held evidence downloads (currently 404, warned) | Links retained pending file publication | Owner |
| AI-training policy (CC BY 4.0 vs `ai-train=no`) | robots.txt generated plain `Allow: /` until decided | Owner |
| slum-fires infographic | Card renders imageless; OG falls back | Owner (asset restore) |
| Cloudflare Pages project wiring + zone-level host redirect | Config committed; account setup pending | Owner/deployer |

## 5. What must be audited next (Phase 3 scope)

**The journalism itself, as published** — across the four investigations (blood-routes, the-impunity-machine, the-lead-belt, dhaka-slum-fires), the tracker, the methodology documents, and the analysis domain:

- **Editorial structure:** report hierarchy, narrative organization, heading/finding/conclusion architecture; whether the landing→report→methodology→evidence structure serves verification
- **Evidence:** claim-to-artifact traceability (the five download references are the immediate test case), citation practice, provenance visibility, dataset versioning
- **Methodology:** tier assignments vs the bureau's own tier standard in `/trust/methodology/`; reproducibility of headline numbers; limitations disclosure; the tracker's update cadence and last-verified dates
- **Data:** table/chart/map numbers vs underlying datasets; raw vs derived distinction as presented
- **Trust:** consistency of per-work AI statements, source counts vs countable sources, corrections readiness (log empty — is that accurate?)
- **UX (presentation of reports):** long-form readability, navigation within reports, mobile reading of data-heavy pages, evidence-access friction
- **Technical report quality:** metadata accuracy per page, cross-link integrity, asset quality

The audit inputs and repository map are specified in `REPORT_AUDIT_INPUT_REQUIREMENTS.md`.

## 6. What decisions must wait (frozen until the report audit concludes)

1. Report page **layouts, typography internals, storytelling structure** (including the `detailed` page's existence/role)
2. **Citation/footnote/source-note presentation**; evidence-block visual design
3. **Methodology page internals** (slots exist; their presentation is not final)
4. **Chart/map/tracker internals** (including the lead-belt JS-populated satellite viewer)
5. **Sub-page naming/merging** (`detailed`, `tracker` routes are 1:1 provisional)
6. Any restructure that would change report URLs a second time

## 7. What the report audit must NOT change

- **The website infrastructure** just executed: build/validate system, templates, manifests schema, redirects, canonical scheme, corrections log format. Presentation conclusions from the audit should be implemented *through* this system (template/manifest changes), never by hand-editing `public/` or reverting to pasted chrome.
- **Published URLs** (they now carry the redirect investment; further URL changes need explicit justification).
- **Journalistic content itself** — Phase 3 audits and recommends; editorial changes remain the owner's decision under the correction/append-only doctrine.
- **Anything in the private repos' confidentiality boundary** — audit findings about private material must describe, not publish.
- **Trust-page doctrine text** (AI bar, corrections policy, methodology standard) without owner sign-off.

## 8. Information still missing before Phase 3 begins

1. Owner answers to the three open inputs in `REPORT_AUDIT_INPUT_REQUIREMENTS.md` (evidence-download intent; property-preservation scope; AI-training stance)
2. Confirmation that the three local repositories (website, assets, OS) are current mirrors of their GitHub remotes (`git fetch` status at Phase 2 close: website repo was `ahead 2` of origin — the Phase 2 commits have **not been pushed**; pushing is the owner's call)
3. If the owner wants `Anik_OS` included as private context: explicit consent

## 9. First suggested Phase 3 step

Read the existing self-audit documents already in the website repo (`docs/publication/IMPUNITY_MACHINE_*` — claim inventory, data audit, method reconstruction; `LEAD_BELT_*`) — then independently verify rather than repeat them, starting with the claim inventories against the published pages and the assets/OS repositories.

---

*Handoff complete. The website system is stable, validated, and intentionally constrained so that Phase 3 can change report presentation without disturbing site infrastructure.*
