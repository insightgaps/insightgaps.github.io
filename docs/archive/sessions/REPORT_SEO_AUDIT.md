# Insight Gaps Bureau — Report SEO Audit (Phase 3)

**Scope:** report/investigation routes only (platform SEO was fixed in Phase 2: single www canonical host, canonical==self, absolute og:image, generated sitemap). This audit covers report-specific discoverability and the structured-data upgrades implemented this phase.

---

## 1. State at phase start (per report route)

| Route | Title quality | Description | JSON-LD | Gaps |
|---|---|---|---|---|
| `/investigations/blood-routes/` | Strong ("Blood Routes · Road Crash Fatalities in Bangladesh · Insight Gaps") | Present, accurate | Legacy Article JSON-LD (unvalidated) | No dateModified signal; og:image = infographic (2.5MB PNG — heavy for social) |
| `/investigations/the-impunity-machine/` (+3 subpages) | Strong | Present, accurate | Legacy JSON-LD on report + detailed | Subpages (methodology/tracker) lack structured data; tracker title is descriptive-good ("Impunity Tracker — Bangladesh Rape Justice Monitor") |
| `/investigations/the-lead-belt/` | Strong | **Contains "39,875 children at extreme risk"** — framing flagged REP-012 (owner editorial) | Legacy JSON-LD | Methodology subpage lacks structured data |
| `/investigations/dhaka-slum-fires/` | Strong | Present | None in current build (dropped with the drawer in Phase 2's body extraction) | No og:image asset; excluded from homepage (indexation unaffected — in sitemap) |

Cross-cutting: all report routes have canonical==self + absolute OG (Phase-2 build, validated); sitemap includes all report routes (verified: set-equality gate).

## 2. Findings

1. **Structured data is patchy and non-standard** (P2): legacy JSON-LD exists on some pages, absent on methodology/tracker/detailed subpages, and was never validated against Google's guidance. Per current Google Article guidance: nothing is strictly required, but recommended properties (headline, datePublished/dateModified ISO 8601, author/publisher, image) drive eligibility and correctness. The `detailed.html` and tracker pages are data-rich surfaces invisible as articles.
2. **No author/organization signal on report pages beyond legacy markup** (P2): the bureau is anonymous by design (Organization, no Person) — correct approach is Organization authorship consistently.
3. **Date signals stale** (P3): manifests carry `date_published` (and several are wrong — REP-016 family: Lead Belt 2025-01-01 vs 2026 activity; slum-fires date belongs to a reverted version). Search-visible freshness (dateModified) is absent.
4. **Image weights** (P3): 2.5MB PNG infographics as og:image slow social unfurls; not blocking.
5. **Anchor-level discoverability** (P3): no stable anchors to findings before this phase — deep-linking and AI-assist surfacing of specific findings impossible.
6. **AI discoverability**: `llms.txt` migrated (Phase 2) with correct URLs; robots generated `Allow: /` (AI-training stance is an owner decision, documented separately); content is static-rendered so crawlers see full reports (Phase-2 win: reports no longer require JS).

## 3. Implemented this phase (presentation-only; no headline rewrites)

1. **NewsArticle JSON-LD on all four investigation report routes + Impunity tracker + methodology subpages**, generated from manifests at build: `headline` (concise title), `datePublished` (manifest), `dateModified` (build-detected content change date from git metadata of the body file — honest freshness, not fabricated), `author`/`publisher` = Organization with URL, `image` = investigation OG image. For the frozen standalone pages, emitted as a surgical `<head>` injection alongside existing legacy JSON-LD (legacy blocks left untouched — no claim content altered; they validate as JSON).
2. **Stable finding anchors** (`#finding-1..N`) rendered on investigation index cards' findings lists — deep-link targets for search/AI answers.
3. **Evidence-page status labels** make the evidence inventory crawlable text (available/private-held/not-in-repository) — previously invisible 404 links.
4. **Sitemap unchanged** (correct); robots unchanged (owner-gated AI decision).
5. **Validation additions:** NewsArticle presence required on `/investigations/*` report routes; JSON-LD must parse; anchors must resolve.

Not done (owner-gated): description/meta rewrites (Lead Belt framing), publication-date corrections in manifests (editorial metadata), og:image asset creation (slum-fires), image optimization (asset pipeline is a platform feature, not report SEO).

## 4. Per-investigation search-intent notes (for the owner; no changes made)

- **Blood Routes**: intent = Bangladesh road deaths / Eid travel safety; strong title already; internal-link from tracker absent (none exists).
- **Impunity Machine**: the tracker page is the highest-value search surface (unique monitoring station) — tracker↔report cross-links exist (nav), now structured-data-complete.
- **Lead Belt**: title targets "lead contamination Bangladesh" well; the methodology page is citation-bait for researchers — now structured-data-complete.
- **Slum Fires**: strong topical title; homepage suppression does not affect indexation; its discoverability is intact — visibility is a presentation policy issue (REP-015).

## 5. Verification

- Build + validation pass with the new checks (see `REPORT_IMPLEMENTATION_COMPLETION.md` for exact outputs).
- All NewsArticle blocks parse as JSON (validation gate).
- No title/description text on any existing page was altered.
