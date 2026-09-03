# Insight Gaps Bureau — Report Visualization Strategy (Phase 3)

**Companion to:** `REPORT_FORENSIC_AUDIT_PHASE_3.md`, `docs/phase3/VISUAL_RESEARCH_NOTES.md`
**Mode:** Strategy + KEEP/REPAIR/REPLACE/REMOVE classification per visual. Chart redesign *implementation* for frozen report pages is gated on owner decisions where it touches claims; mobile/a11y *repairs* that change no content are implemented this phase where safe.

---

## 1. Governing rules (derived from research + the site's constraints)

1. **A visual exists only to improve UNDERSTANDING, VERIFICATION, or DISCOVERY.** No decoration.
2. **Every chart ships with: a finding-title, unit/denominator, source line, and date.** A chart without a source line is decoration (Datawrapper/newsroom convention; ICIJ evidence-attribution).
3. **No visualization may contain manually typed data when the underlying data can be generated.** Dataset → transformation → visual data → visualization; a dataset change must update the visual or fail validation (matches the bureau's own Markup-derived checklist).
4. **Every visual has an accessible alternative** (data table or text summary) — Chartability POUR+CAF baseline.
5. **Mobile is a first-class form**: minimum readable type (≥12px), table fallbacks for dense grids, no shrinking-until-unreadable.
6. **Static-first**: precomputed SVG/HTML over runtime chart libraries; JS only enhances.

## 2. Inventory and classification

### The Impunity Machine
| Visual | Question it answers | Classification | Why |
|---|---|---|---|
| Conviction funnel / attrition bars | Where do 66,711 → 310 cases go? | **KEEP (repair)** | Right form; the post-publication denominator disclosure (`36177f6`) is now the model caveat |
| Cross-country comparison bars | How anomalous is 0.46%? | **KEEP (repair)** | Caveat text exists; chart labels need the denominator note visible (it is); mobile text at 0.42–0.55rem must be repaired |
| Backlog/court steps panel | Is the system shrinking backlog? | **KEEP** | Data-driven from cleaned JSONs |
| §17 counter-prosecution timeline | What's the legal exposure? | **KEEP** | Unique tracker-adjacent view |
| Canvas race/bar animations | Narrative pacing | **REPAIR** (a11y): add text/data alternatives; enforce text-size floor | No content change |

### The Lead Belt
| Visual | Classification | Why |
|---|---|---|
| Leaflet map + markercluster (294 sites) | **KEEP** | The investigation's core spatial claim; data embedded and verified (294/145/1,702× reproduce) |
| Satellite viewer (JS-populated) | **KEEP** | Phase-1 "empty src" resolved as JS-populated on selection; works as designed |
| Hero stats (294 / 145 / 59m / 1,702×) | **KEEP (owner-gated repair)** | Numbers verified against embedded data; the 145-is-intersections and estimate-bounds framings are editorial (owner) |
| per-site ppm markers | **KEEP** | Direct encoding, data-true |

### Blood Routes
| Visual | Classification | Why |
|---|---|---|
| Leaflet map over 2,331 accidents | **KEEP** | Genuinely data-driven; the dataset's honest purpose |
| Hero number panel (31,578 / 5,480 / 351) | **REPAIR (implemented)** | Mixed source-basis now labeled (modelled estimate vs NGO count) via manifest fields — presentation-only |
| Eid surge box | **REPAIR (owner-gated)** | 351 rests on external reports; label basis; content unchanged |

### Dhaka Slum Fires
| Visual | Classification | Why |
|---|---|---|
| (none present) | — | Report is text-only |
| Claim badges (26 placements) | **REPAIR (implemented)** | Drawer restored from git `9e73d50`; badges functional again |
| Promised slider map / infographic | **REMOVE the promise or BUILD the artifact — owner decision** | Neither ever existed; spec referenced a `file:///` path and an unwritten script. Never manufacture. |

### Property Preservation (data-tool surfaces — frozen WAIT)
| Visual | Classification | Why |
|---|---|---|
| Dashboard views (10 partials) | **DEFER** | Owner placement decision pending; no redesign now |

### Site-wide
| Visual | Classification |
|---|---|
| Investigation infographics (3 PNGs) | **KEEP** (og/cards) — asset quality fine at current scale |
| Archive cards/filters | **KEEP** (Phase-2 build; progressive enhancement) |
| Homepage metrics block | **REPAIR (implemented)** — corrections-policy link (Phase 2) + source-basis sublabels (Phase 3) |

## 3. "The tricks" — adopted techniques (responsible-journalism set)

- **Headline number + denominator adjacent** (Impunity hero: counts WITH their denominators visible — preserved where present, added as labels where manifest supplies them).
- **"How this was calculated" progressive disclosure** — implemented as `<details>` blocks sourced from methodology/bureau-authored text only; omitted where no authored text exists.
- **Evidence links adjacent to claims** — claim anchors + drawer (slum-fires) + evidence panels (index pages).
- **Direct labeling over legends** where feasible on new/modified visuals (none modified beyond labels this phase).
- **Source+date line under every data-driven visual** — required for any NEW visual; existing visuals carry their source lines (verified on Impunity panels).
- **Observation vs inference separation** — the "visual indicators" language on Lead Belt satellite claims is the bureau's own good practice; the strategy codifies it as the standard for any future AI-assisted visual claim.
- **Chart-to-table fallback** — required for any NEW dense visual; added as validation lint for text-size on report pages (implemented).
- **Deep-linkable findings** — `#finding-N` anchors (implemented).
- **Uncertainty bands / bounds display** — future visuals must show bounds where the bureau authored them (e.g., student-estimate range exists in methodology; displaying it at the hero is owner-gated).

## 4. Mobile strategy per visual class

- Maps (Leaflet): existing responsive behavior verified in Phase 2 (no overflow at 320–1440px); cluster + zoom interactions remain; no change.
- Canvas charts (Impunity): **repair implemented as a CSS text-size floor override** scoped to the report pages (`.impunity-report * { font-size: max(inherit, ...) }` is NOT used — instead a scoped minimum on the specific inline classes identified; content unchanged). Full chart redesign deferred to owner-gated report redesign.
- Hero stats: existing clamp() scaling preserved.
- Tables (PP app, tracker): horizontal scroll already; fallback tables required for any new visual.

## 5. What was NOT done (and why)

- No chart type replacements: the audit found **no misleading encodings** — the failures were sourcing/labeling, not chart form. Replacing chart types would be fashionable, not evidence-driven.
- No scrollytelling additions, no animation additions.
- No infographic regeneration (slum-fires): manufacturing evidence imagery is prohibited; the asset must come from the owner.
- No interactive filters added anywhere: the audit found no filtering need that serves understanding/verification/discovery at current data volumes.
