# Insight Gaps Bureau — Report System Architecture (Phase 3)

**Companion to:** `REPORT_FORENSIC_AUDIT_PHASE_3.md`
**Status:** Design + implemented subset on branch `phase3-report-improvement`
**Constraint:** the website infrastructure (Phase 2: generated static site, manifests, fail-closed build/validation, Cloudflare Pages) is frozen and is the foundation everything below builds on. No runtime hydration for core content; no new frameworks.

---

## 1. The resulting system, end to end

```
CONTENT (content/**, manifests — author-owned, human-editable)
   ↓
CLAIMS (investigation.json key_findings + per-claim source registry [new])
   ↓
EVIDENCE (evidence.json per work; artifacts under public-evidence/ or marked private)
   ↓
DATA (raw → scripts → derived; JSON data files + embedded report data)
   ↓
TRANSFORMATIONS (OS-repo scripts; website build validates linkage, doesn't perform analysis)
   ↓
VISUALIZATIONS (static-first: precomputed SVG/HTML tables; JS only for enhancement)
   ↓
REPORT (template-rendered pages from bodies + chrome; claim badges anchored #claim-N)
   ↓
SEO / DISCOVERY (generated canonical/OG/NewsArticle JSON-LD; sitemap; stable anchors)
   ↓
VALIDATION (scripts/validate.py gates + new report-specific checks)
   ↓
PUBLICATION (Cloudflare Pages; preview URLs = review state; main = production)
```

How the layers connect after this phase:

- **Manifests remain the single source of truth** for titles, dates, findings, tiers, source counts. Phase 3 adds optional per-claim source fields to manifests — data, not prose, so the renderer can surface them.
- **The build never invents content.** New affordances (source-basis labels, evidence-status badges, claim anchors, methodology links) render only from manifest-provided text. Where the bureau hasn't supplied text, the affordance is absent — absence is visible in validation as a warning, not papered over.
- **Validation extends from "site integrity" to "report integrity"**: link checks now include claim-anchor integrity, evidence-reference status honesty (a public link to a known-missing artifact must be labeled, not silently shipped), and per-report structured-data presence.

## 2. What was actually implemented this phase (evidence-supported, presentation-only)

| # | Improvement | Where | Basis |
|---|---|---|---|
| 1 | **Evidence-download status honesty**: the evidence page now renders each referenced artifact with status (available / private-held / not-in-repository) instead of bare links that 404 | `content/pages/evidence.body.html` + build-assisted | REP-005; audit §12 |
| 2 | **Claim anchors**: every key finding in manifest gets a stable `#finding-N` anchor on investigation pages; links from cards/indexes can deep-link findings | build + investigation pages | "stable anchors to major findings" (research notes D-decision) |
| 3 | **NewsArticle JSON-LD** on all four investigation pages + tracker, generated from manifests (headline, dates, org, image) | `scripts/build.py` + standalone emit for frozen pages | Google Article guidance; REP-016 family |
| 4 | **Source-basis labels** on homepage hero stats (dataset-derived vs external-report-cited) — rendered from new manifest fields, no prose edits | home template + `site.json` stats metadata | REP-008/BR audit |
| 5 | **Per-work evidence panel** on investigation index cards (methodology/evidence/tracker links where they exist — generated from manifest subpages) | listing template | §15 friction |
| 6 | **Source-count definition** published on the trust/methodology page (definition text supplied as data; surfaced as a disclosure note under the homepage stat) | trust body + home | REP-011 |
| 7 | **Slum-fires verification-drawer promise repaired**: drawer restored from git history (`9e73d50`) OR promise text adjusted — **implemented as restore**, since the content exists and restoration is presentation-only | slum-fires body | REP-007 |
| 8 | **Draft limitations surfaced**: the bureau's own draft Limitations section (already written in OS repo) is appended as a clearly-marked "Limitations (from the investigation file)" block | slum-fires body | SF audit §5; surfacing existing material |
| 9 | **Validation extension**: new checks — claim-anchor integrity, evidence-status consistency, NewsArticle JSON-LD presence on report routes, chart-text minimum-size lint on report pages | `scripts/validate.py` | §37 final validation |

Items 1–9 are the complete implemented set. Anything requiring editorial judgment (claim wording, hero reframing, corrections entries, tier labels, evidence publication) is **not** implemented — see `OWNER_DECISIONS_REQUIRED.md`.

## 3. Report shell architecture (common vs investigation-specific)

**Common structure (all four investigations):**
- Landing/report page (label · status · date · tier badge · title · dek) → findings (anchored) → body → methodology link → evidence link (where exists) → related work.
- Chrome from base template; disclosure bar; skip link; canonical/OG/NewsArticle.
- Mobile: content-first (existing, preserved).

**Investigation-specific (derived from the audit, not uniformity):**

| Investigation | Structure |
|---|---|
| Blood Routes | Single scrolling report + map; **add**: hero source-basis labels; dataset-profile disclosure (85% truck-motorcycle composition) once owner supplies the text — field exists, currently empty |
| Impunity Machine | Keep the 4-page split (report / detailed / methodology / tracker) — the audit found each page earns its role (report = narrative; detailed = data-driven; methodology = reconstruction; tracker = living). `detailed` stays: it is the only page whose content is fully data-derived |
| Lead Belt | Report + methodology (with published reconciliation) + satellite proof; **add**: hero-adjacent estimate-mechanics disclosure rendered from methodology content (no new claims) |
| Slum Fires | Report + restored claim drawer + surfaced limitations; evidence page intentionally absent until owner supplies artifacts |

**`detailed` page decision (asked explicitly by the brief):** KEEP. Evidence: it renders from `cases.json`/`leads.json`/`monthly.json`, making it the investigation's most verifiable surface. Merging it into the report page would bury the only fully data-driven view. Role clarified by nav labels, not by restructuring.

## 4. Content model additions (backward-compatible, optional fields)

```jsonc
// investigation.json additions (all optional; validation warns, never breaks):
"claims": [                       // optional per-claim registry
  { "id": "C001", "text": "...",                  // text = existing key_findings entry
    "source_basis": "external-report",            // enum: dataset | external-report | document | mixed
    "source_note": "RSF & BJKS Eid 2026 reports",// shown on hover/anchor
    "status": "verified|unverified|caveated" }   // honest, from bureau's own audit docs
],
"evidence_refs": [                 // per-artifact status honesty
  { "path": "/data/BD-INV-002_Master_Evidence_File.xlsx",
    "title": "Master evidence file (BD-INV-002)",
    "status": "private-held",                    // enum: available | private-held | not-in-repository
    "note": "Held in the bureau archive; publication pending editorial decision" }
],
"findings_anchored": true,
"limitations_note": "..."           // surfaced block, verbatim from bureau's own draft
```

Renderer rules: absence of optional fields = absence of affordance. Validation warns on: published work with zero `source_basis` entries; evidence link without a matching `evidence_refs` status; `status: "verified"` claim without `source_note`.

## 5. What this architecture deliberately does NOT do

- No client-side rendering of core content (frozen rule).
- No chart library introduced; no scrollytelling framework; heavy visuals remain per-work custom (visualization strategy doc governs their repair, not a system rewrite).
- No CMS, no database, no server. Still files + build + gate.
- No claim is ever generated, strengthened, weakened, or caveated by the build — only surfaced from authored data.
- No edits to investigation prose, methodology statements, numbers, or tiers anywhere in the implemented set.
