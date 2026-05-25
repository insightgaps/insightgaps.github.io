# BD-INV-002 — The Impunity Machine
## Implementation Report — May 2026

---

### Summary

**Commit hash:** `8e84b29`  
**Branch:** `main`  
**Status:** Implementation complete. Awaiting human review before push.  
**Files changed:** 25 files (3,132 insertions, 24 deletions)

---

### Files Changed

#### MODIFIED

| File | Change |
|------|--------|
| `content/investigations/the-impunity-machine/index.html` | Full flagship implementation (see detail below) |
| `data/index.html` | BD-INV-002 package upgraded from Partial to Active; all 5 files registered |

#### CREATED — Investigation Pages

| File | Source | Purpose |
|------|--------|---------|
| `content/investigations/the-impunity-machine/tracker.html` | Legacy archive | Live monitoring dashboard — 1,267 lines |
| `content/investigations/the-impunity-machine/methodology.html` | Legacy archive | Methodology documentation — 229 lines |

#### CREATED — Datasets

| File | Size | Contents |
|------|------|---------|
| `data/BD-INV-002_Master_Evidence_File.xlsx` | ~91 KB | Master evidence file · 10 worksheets · 91 sources |
| `data/cases.json` | ~10 KB | Tribunal case register with timelines |
| `data/monthly.json` | ~16 KB | PHQ monthly ledger + confirmed gaps heatmap data |
| `data/leads.json` | ~5 KB | Active monitoring leads (auto-collected) |

#### CREATED — Planning Documents (archived to repo)

- `IMPUNITY_MACHINE_ARCHITECTURE_RECOMMENDATION.md`
- `IMPUNITY_MACHINE_ASSET_INVENTORY.md`
- `IMPUNITY_MACHINE_CLAIM_INVENTORY.md`
- `IMPUNITY_MACHINE_DATA_AUDIT.md`
- `IMPUNITY_MACHINE_METHOD_RECONSTRUCTION.md`
- `IMPUNITY_MACHINE_WEBSITE_UPGRADE_PLAN.md`
- `LEAD_BELT_RELEASE_CHECKLIST.md`
- `LEAD_BELT_WEBSITE_UPGRADE_PLAN.md`

---

### index.html — Detailed Changes

**Architecture:** Hybrid scrollytelling flagship report. Single-page narrative with 9 visual scenes driven by IntersectionObserver scroll triggers, followed by key content modules.

#### Implemented features

| Feature | Status | Location |
|---------|--------|---------|
| Hero section (full-screen, animated) | ✅ | `#hero` |
| Context block (investigation overview) | ✅ | `#context` |
| Mobile hamburger navigation | ✅ | `.nav-ham` / `.nav-drawer` |
| Key Numbers module (6 statistics) | ✅ | `#key-numbers` |
| Her Story narrative (composite figure, 7 panels) | ✅ | `.her-story` |
| Scene 01: Dot Matrix (attrition model) | ✅ | `.scene` |
| Scene 02: Clock (56 days vs 2,349 days) | ✅ | `.scene` |
| Scene 03: The Inversion (§17 prosecution) | ✅ | `.scene` |
| Scene 04: Race bars (global conviction rates) | ✅ | `.scene` |
| Scene 05: Evidence window (forensic gap) | ✅ | `.scene` |
| Scene 06: OCC map (geographic gaps) | ✅ | `.scene` |
| Scene 07: Scatter plot (severity vs. conviction) | ✅ | `.scene` |
| Scene 08: Backlog bars (pending cases) | ✅ | `.scene` |
| Scene 09: Section 32 refusal visualization | ✅ | `.scene` |
| Legislative Timeline (2000–2026) | ✅ | `#s-timeline` |
| How We Did This (transparency section) | ✅ | `#how-we-did-this` |
| 6 Reform Interventions | ✅ | `.ivs` |
| Closing statement | ✅ | `#closing` |
| Download Evidence section (with real file links) | ✅ | `#evidence-export` |
| Dark/light theme toggle | ✅ | Inline JS |

#### Fixed bugs
- Broken methodology links: `methodology/methodology.md` → `methodology.html` (3 locations)
- Duplicate "Download Evidence Data" buttons removed
- Download buttons now link to actual files in `/data/`

---

### tracker.html — Changes

- All navigation links updated from old paths (`/investigations/national/impunity-machine/`) to current paths (`/content/investigations/the-impunity-machine/`)
- `visual.html` references removed (file was merged into flagship index.html)
- Broken external script `../../../../theme-toggle.js` replaced with self-contained inline theme toggle
- Footer links updated to match current file structure
- Evidence file link added to footer navigation

---

### methodology.html — Changes

- All navigation links updated from old paths to current paths
- Broken `data-include="header"` and `data-include="footer"` directives removed (component system not implemented in this deployment)
- Broken external scripts (`/js/components.js`, `/js/ui.js`) removed
- `theme-toggle.js` external script replaced with self-contained inline handler
- Hero breadcrumb links updated
- Reference to deleted `visual.html` replaced with description of flagship page scrollytelling
- Evidence file link added to hero nav buttons

---

### data/index.html — Changes

BD-INV-002 package entry:
- Status: `Partial - Documentation Available` → `Active - Fully Verified`
- Files registered: Master Evidence File (xlsx), cases.json, monthly.json, leads.json, methodology.html
- Button: `btn--ghost` → `btn--primary` (report is fully published)

---

### Verification

#### Evidence preservation
- ✅ All findings preserved from legacy investigation
- ✅ All calculations preserved (conviction rate range 0.12%–3.66%)
- ✅ All denominators preserved with labels
- ✅ All citation references preserved (91 named sources)
- ✅ No claims strengthened beyond evidence
- ✅ All tier labels (CONFIRMED / PROBABLE / CONFIRMED ABSENT) retained

#### Link integrity
- ✅ All internal links from index.html to tracker.html: correct
- ✅ All internal links from index.html to methodology.html: correct
- ✅ All internal links from tracker.html to index.html: correct
- ✅ All internal links from methodology.html to index.html: correct
- ✅ All dataset download links point to actual files in `/data/`
- ✅ No remaining references to deleted visual.html

#### Constitution compliance
- ✅ No new findings invented
- ✅ No evidence rules created
- ✅ No governance documents modified
- ✅ Her Story panels: composite figure, all details from confirmed primary sources
- ✅ All sections identify their source tier

---

### Outstanding items (not in scope, not started)

| Item | Status |
|------|--------|
| Sitemap update (add impunity machine URLs) | Not started |
| `sitemap.xml` entry for tracker.html and methodology.html | Not started |
| `robots.txt` verification | Not started |
| Animated soil bars | Deferred per earlier user decision |
| Skeleton loaders | Deferred per earlier user decision |

---

### Ready for human review

**Commit:** `8e84b29`  
**Files:** `content/investigations/the-impunity-machine/` (3 files), `data/` (4 new files + index.html), planning docs  
**Push target:** `origin/main`  

> **STOP:** Do not push until human review is complete.
