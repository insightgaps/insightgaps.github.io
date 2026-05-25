# Insight Gaps Website Blueprint

**Status:** Working blueprint  
**Last updated:** 2026-05-25  
**Architecture reference:** `docs/governance/03-content-architecture.md` version 1.2  
**Workflow reference:** `docs/governance/06-ai-workflow.md` version 1.0

## 1. Site Purpose

Insight Gaps is an independent forensic data journalism website from Dhaka. The website should make three things immediately clear:

- What the bureau investigates.
- Why the work is trustworthy.
- Where readers, sources, clients, and reviewers should go next.

The site has two separate public tracks:

- **Investigations:** public-interest forensic reporting, accountability work, and evidence-led stories.
- **Analysis:** portfolio and commercial analysis reports for business, domain, and professional audiences.

These tracks should share the same visual system but remain separated in navigation, data indexes, and page logic.

## 2. Primary Audiences

- **Readers:** need clear stories, evidence, and plain-language findings.
- **Sources and tipsters:** need contact paths, trust signals, and safe handling expectations.
- **Editors, partners, and funders:** need proof of method, corrections discipline, and publication standards.
- **Clients and employers:** need analysis work that demonstrates data skill, business understanding, and reproducible process.

## 3. Current Sitemap

```text
/
|-- index.html
|-- archive.html
|-- about.html
|-- contact.html
|-- 404.html
|-- content/
|   |-- investigations/
|   |   |-- index.html
|   |   |-- the-lead-belt/
|   |   |-- the-impunity-machine/
|   |-- trust/
|       |-- methodology.html
|       |-- ai-use.html
|       |-- corrections.html
|-- analysis/
|   |-- index.html
|   |-- property-preservation/
|-- data/
|   |-- investigations.json
|   |-- analysis.json
|   |-- cases.json
|   |-- leads.json
|   |-- monthly.json
|-- assets/
|   |-- css/
|   |-- js/
|-- components/
|-- docs/
|   |-- WEBSITE_BLUEPRINT.md
|   |-- governance/
|   |-- publication/
|-- methods/
```

## 4. Page Responsibilities

### Homepage

Role: bureau command center.

It should show the latest published investigation, headline metrics, recent investigations, analysis domains, and trust links. It should not become a general landing page or marketing page.

### Investigations Index

Role: reader entry point for public-interest reporting.

It should route users to live investigations and make investigation status visible.

### Investigation Pages

Role: primary editorial product.

Each investigation should carry its own title, dek, findings, methodology, source logic, and correction status. The page must not hide uncertainty or overstate evidence.

### Analysis Index

Role: business and portfolio entry point.

It should show domains clearly and route users to report clusters.

### Analysis Reports

Role: professional analysis product.

Reports should prioritize executive summary, key findings, methodology note, dataset reference, and a clear contact path.

### Trust Pages

Role: credibility infrastructure.

Methodology, AI use, and corrections pages should remain easy to find from the main navigation and footer.

### Contact

Role: source and general communication entry point.

It should separate tip submission expectations from general contact.

## 5. Content and Data Model

The site should keep these as single sources of truth:

- `data/investigations.json` for investigation cards, archive entries, homepage feed, and status.
- `data/analysis.json` for analysis domains and reports.
- Investigation-specific methodology files inside each investigation folder.
- Global trust policy inside `content/trust/`.

Do not mix investigation content into analysis JSON, or analysis reports into investigation JSON.

## 6. Visual Direction

The current design contract is:

- Light editorial site.
- Typography-forward.
- No decorative gradients or stock-like imagery.
- Amber accent used as the bureau identity signal.
- Investigation pages can feel more forensic and evidence-heavy.
- Analysis pages should feel cleaner, professional, and business-readable.

All future visual work should follow `docs/governance/04a-design-tokens.md` and `docs/governance/04b-component-rules.md`.

## 7. Trust and Verification Layer

Every major public page should make the trust system visible through at least one of these:

- Methodology link.
- AI use disclosure.
- Correction policy or correction status.
- Source count, dataset reference, or methodology note.

The trust layer should not be treated as footer-only material. It is part of the product.

## 8. Repository Organization Rules

Keep the root focused on deployed site files and governance entry points.

Recommended root-level files:

- Entry pages: `index.html`, `archive.html`, `about.html`, `contact.html`, `404.html`.
- Governance entry points: `START_HERE.md`, `AGENTS.md`.
- Deployment files: `CNAME`, `robots.txt`, `sitemap.xml`, `wrangler.jsonc`, `.gitignore`.

Recommended folders:

- `assets/` for shared CSS, JavaScript, images, and future fonts.
- `components/` for copied HTML partials.
- `content/` for investigations and trust pages.
- `analysis/` for analysis track pages.
- `data/` for public JSON and dataset files.
- `methods/` for scripts.
- `docs/` for blueprints, audit notes, implementation reports, and operating documentation that should not appear as live pages.
- `docs/governance/` for architecture, schema, design, component, page, template, and AI workflow rules.
- `docs/publication/` for investigation-specific release checklists, upgrade plans, asset inventories, and implementation reports.

Temporary QA screenshots should not live at the repository root. They should either stay outside the repo or be stored under a deliberate review folder only when they are part of a written review package.

## 9. Near-Term Build Priorities

1. Confirm all public pages have consistent navigation and footer links.
2. Confirm `investigations.json` and `analysis.json` match the visible cards and published pages.
3. Add or restore `assets/img/og-default.jpg` if it is referenced by the homepage metadata.
4. Review `sitemap.xml` after any URL changes.
5. Review `docs/publication/` periodically and archive outdated implementation notes when a release is superseded.
6. Add missing template files only if the human owner approves the architecture step.

## 10. Publication Guardrails

- Do not delete investigations.
- Do not remove trust pages.
- Do not change schemas or architecture without explicit approval.
- Do not push directly to production unless the human owner asks for it.
- Before deployment, review changed files, check broken references, and verify the live paths.
