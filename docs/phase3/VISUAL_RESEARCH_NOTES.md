# Visual Journalism Research Notes (Phase 3 benchmarking)

Private research notes. EXAMPLE → TECHNIQUE → WHY IT WORKS → APPLIES TO INSIGHT GAPS? → TARGET INVESTIGATION.
Principles only; no visual style copied from anyone.

## 1. Chartability (fizz.studio) — accessible chart framework
→ TECHNIQUE: POUR+CAF checklist (Perceivable/Operable/Understandable/Robust + Compromising/Assistive/Flexible); treat charts as data *experiences* with non-visual semantics; mechanical contrast checks; 14-test shortlist audit before shipping.
→ WHY: chart accessibility failures are invisible to sighted authors; a checklist makes them findable in 20–40 min.
→ APPLIES: YES — the Impunity Machine and Lead Belt charts are canvas/inline-SVG with no text alternatives; tracker is visual-only.
→ TARGET: all report visuals; evidence tables.

## 2. Google Search Central — Article structured data (2025 guidance)
→ TECHNIQUE: NewsArticle markup with `headline` (concise), `datePublished`/`dateModified` ISO 8601 with timezone, `author` as Person/Organization with `url`, `image` matching article content (not logos; ≥50k px, multiple ratios). Nothing is strictly *required*; recommended properties only. Rich results not guaranteed.
→ WHY: entity/topic understanding + eligibility for rich presentation.
→ APPLIES: YES — investigation pages currently carry bespoke JSON-LD of unknown validity; we can standardize NewsArticle on report pages with real dates from manifests (already the single source of truth).
→ TARGET: all four investigations + tracker/methodology pages.

## 3. Google Search Central — Dataset structured data (updated 2025-12-10)
→ TECHNIQUE: Dataset JSON-LD with `name` + `description` (50–5000 chars), `creator`, `license` (specific version URL), `distribution` (DataDownload + contentUrl + encodingFormat), `variableMeasured`, `spatialCoverage`, `temporalCoverage`, `version`, `sameAs`.
→ WHY: Dataset Search discovery; signals provenance discipline.
→ APPLIES: YES, BUT GATED — the site advertises dataset downloads that do not exist publicly yet. Dataset markup must only point at artifacts that actually resolve. Implementation is prepared and wired to manifests, activated per-artifact when the owner publishes the files (owner decision).
→ TARGET: evidence page + per-investigation evidence panels.

## 4. ICIJ — evidence-first attribution practice
→ TECHNIQUE: attribute findings to *specific evidence classes* inline ("Leaked Pandora Papers records", "internal report obtained"); dedicated methodology/FAQ pages per investigation; public searchable databases as first-class navigation destinations; standing "found an inaccuracy?" contact in footer; impact tracking.
→ WHY: verification credibility comes from claim→artifact visibility, not from claims about rigor.
→ APPLIES: YES — investigations currently assert sourcing vaguely ("records show") in several places; inline evidence attribution + per-work methodology pages already half-exist here; we strengthen the *presentation* of attribution, inventing nothing.
→ TARGET: Impunity Machine (strongest case: it has real cleaned datasets behind it), Blood Routes.

## 5. Datawrapper/newsroom convention — title as takeaway; design against misreading
→ TECHNIQUE: chart titles assert the finding ("Electric cars are heavy. SUVs are heavier."), not the mechanics ("Bar chart of weight"); every chart asks "how could this be misread?" before shipping; source+date line under every chart is non-negotiable.
→ WHY: reader gets the finding even if they never read the prose; source lines convert a graphic from decoration into evidence.
→ APPLIES: YES — several report visuals lack visible source/date lines; captions where present are stylistic rather than "what this shows".
→ TARGET: all investigations; tracker header.

## 6. ProPublica/"show your work" convention (via markup_show_your_work_checklist.md already in OS repo)
→ TECHNIQUE: "How we calculated this" blocks adjacent to headline numbers; data downloads linked from the exact visualization; methodology progressive-disclosure (short summary first, full method one click away).
→ WHY: progressive disclosure serves both the general reader and the researcher without burying methodology at the page bottom.
→ APPLIES: YES — the bureau's own OS repo contains a show-your-work checklist; the published reports don't yet follow it. This is alignment with the owner's documented standard, not an imported taste.
→ TARGET: all investigations, especially headline-number sections (351 deaths; 0.46% conviction rate; 294 sites/145 schools; +250% land value).

## 7. Mobile data-vis patterns (newsroom standard practice)
→ TECHNIQUE: don't shrink desktop charts; transform: horizontal-scroll tables, stacked comparisons, chart-to-table fallback, simplified label sets on small screens; precomputed SVG over runtime chart libs where possible.
→ WHY: the audience is substantially mobile (Bangladesh-focused readership); the current reports render canvas/complex visuals at fixed scales with `.46rem`/`.42rem` font sizes — unreadable on phones.
→ APPLIES: YES, urgently — Impunity Machine's inline styles set font sizes at 0.4–0.5rem, below any readable threshold on mobile.
→ TARGET: Impunity Machine first (worst offender), then Lead Belt map legend/labels.

## Decisions derived from research (not copied from anyone)
- D1: Every chart gets: finding-title + unit/denominator + source + date. (5, 6)
- D2: Headline numbers get adjacent "how this was calculated" disclosure blocks fed by manifest text (no invented content; where method text doesn't exist, the block is omitted and flagged for owner). (6)
- D3: Charts must ship with an accessible text/table alternative; canvas-only visuals get a data table fallback. (1)
- D4: Dataset JSON-LD wired to manifests but only emitted for publicly resolvable artifacts. (3)
- D5: NewsArticle JSON-LD standardized on all report pages from manifest data. (2)
- D6: Mobile: minimum readable type in report visuals; table fallbacks for dense grids. (7)
- D7: Inline evidence-attribution presented where evidence exists; vague attributions flagged, never "improved" by inventing sources. (4)
