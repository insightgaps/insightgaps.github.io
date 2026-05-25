# 04d-template-specs.md — Insight Gaps Template Specifications
**Version:** 1.0
**Status:** Active
**Rule:** Templates are structural blueprints. They define the HTML skeleton. They contain no content. Content is added when a template is copied for a specific page.

---

## WHAT THIS DOCUMENT IS

This document defines the HTML structure, CSS class conventions, and content slots for every master template. These specs are handed to the build phase. No template is built without this document present.

---

## TEMPLATE CONVENTIONS — GLOBAL

### CSS Class Naming
All classes use BEM-style naming: `block__element--modifier`

Examples:
- `investigation__hero` — hero block inside investigation
- `investigation__hero--corrected` — hero block when correction exists
- `card__status--published` — status badge modifier

### Slot Notation
Content slots in templates are marked with comment blocks:
`<!-- SLOT: field_name — description -->`

These are the only places content is inserted during the build phase.
Never add content outside a designated slot.

### Shared HTML Head Structure
Every template includes:
- `charset` and `viewport` meta
- `canonical` link — populated at build time
- `og:title`, `og:description`, `og:image` — populated at build time
- Link to `assets/css/style.css`
- Link to `assets/css/components.css`
- Link to page-specific CSS if required
- Self-hosted font preloads

---

## TEMPLATE 1 — INVESTIGATION BLANKET
**File:** `templates/investigation-blanket.html`
**Copied to:** `content/investigations/INV-00X/index.html`
**Additional CSS:** `assets/css/investigation.css`

### HTML Skeleton

```
<body>
  <!-- COMPONENT: ai-disclosure-bar.html -->
  <!-- COMPONENT: header.html -->

  <main class="investigation">

    <section class="investigation__hero">
      <!-- SLOT: status — status badge component -->
      <!-- SLOT: investigation_type — tier badge -->
      <h1 class="investigation__title"><!-- SLOT: title --></h1>
      <p class="investigation__dek"><!-- SLOT: dek --></p>
      <div class="investigation__meta">
        <!-- SLOT: date_published -->
        <!-- SLOT: date_revised — render only if populated -->
        <span class="investigation__id"><!-- SLOT: id --></span>
      </div>
    </section>

    <!-- COMPONENT: correction-banner.html — render only if has_correction is true -->

    <!-- COMPONENT: methodology-badge.html -->

    <section class="investigation__findings">
      <!-- COMPONENT: key-findings-panel — populated from handoff.md -->
    </section>

    <article class="investigation__body">
      <!-- SLOT: body_content — all prose, visual blocks, data tables go here -->
      <!-- Visual blocks use class="visual-block visual-block--wide" to break grid -->
    </article>

    <section class="investigation__sources">
      <!-- SLOT: source_count -->
      <!-- SLOT: source_list — numbered list -->
    </section>

    <section class="investigation__methodology">
      <!-- SLOT: methodology_content — from methodology/methodology.md -->
    </section>

    <section class="investigation__related">
      <!-- SLOT: related_items — render only if populated, max three cards -->
    </section>

  </main>

  <!-- COMPONENT: footer.html -->
</body>
```

### Build Checklist for This Template
Before marking a page built from this template as ready:
- [ ] All SLOT comments replaced with real content
- [ ] Status badge reflects investigations.json status field
- [ ] Correction banner activated if has_correction is true
- [ ] Key findings pulled directly from handoff.md — not written fresh
- [ ] Source count matches actual source list
- [ ] Methodology section populated
- [ ] og_image_path updated in HTML head
- [ ] canonical URL set correctly

---

## TEMPLATE 2 — ANALYSIS DOMAIN PAGE
**File:** `templates/analysis-domain.html`
**Copied to:** `analysis/[domain-name]/index.html`

### HTML Skeleton

```
<body>
  <!-- COMPONENT: header.html -->

  <main class="analysis-domain">

    <nav class="breadcrumb">
      <!-- SLOT: breadcrumb — Analysis → Domain Title -->
    </nav>

    <section class="analysis-domain__header">
      <h1 class="analysis-domain__title"><!-- SLOT: domain_title --></h1>
      <span class="analysis-domain__audience"><!-- SLOT: audience --></span>
      <p class="analysis-domain__description"><!-- SLOT: description --></p>
      <div class="analysis-domain__meta">
        <!-- SLOT: report_count --> reports ·
        Last updated <!-- SLOT: last_updated -->
      </div>
    </section>

    <section class="analysis-domain__reports">
      <!-- SLOT: report_cards — one card per report, built from report objects in analysis.json -->
    </section>

    <!-- COMPONENT: cta-analysis.html -->

  </main>

  <!-- COMPONENT: footer.html -->
</body>
```

### Build Checklist for This Template
- [ ] All SLOT comments replaced with real content
- [ ] Report cards match entries in analysis.json for this domain
- [ ] report_count accurate
- [ ] Breadcrumb links working
- [ ] CTA component links to contact.html

---

## TEMPLATE 3 — ANALYSIS REPORT PAGE
**File:** `templates/analysis-report.html`
**Copied to:** `analysis/[domain-name]/[report-name].html`

### HTML Skeleton

```
<body>
  <!-- COMPONENT: ai-disclosure-bar.html -->
  <!-- COMPONENT: header.html -->

  <main class="analysis-report">

    <nav class="breadcrumb">
      <!-- SLOT: breadcrumb — Analysis → Domain → Report Title -->
    </nav>

    <section class="analysis-report__header">
      <span class="analysis-report__tag"><!-- SLOT: tag --></span>
      <h1 class="analysis-report__title"><!-- SLOT: title --></h1>
      <div class="analysis-report__meta">
        <!-- SLOT: date -->
        <!-- SLOT: confidence_level — render only if populated -->
      </div>
    </section>

    <section class="analysis-report__executive-summary">
      <!-- SLOT: executive_summary -->
    </section>

    <section class="analysis-report__findings">
      <!-- SLOT: key_findings — three to five items -->
    </section>

    <article class="analysis-report__body">
      <!-- SLOT: body_content — data sections, visuals, analysis -->
    </article>

    <section class="analysis-report__methodology">
      <!-- SLOT: methodology_note -->
      <!-- SLOT: dataset_reference — render only if populated -->
    </section>

    <!-- COMPONENT: cta-analysis.html -->

  </main>

  <!-- COMPONENT: footer.html -->
</body>
```

### Build Checklist for This Template
- [ ] All SLOT comments replaced
- [ ] Executive summary is high scannability — short sentences, no jargon
- [ ] Key findings are complete sentences, not fragments
- [ ] Methodology note present
- [ ] CTA component present and links to contact.html

---

## TEMPLATE 4 — ARCHIVE CARD
**File:** `templates/archive-card.html`
**Used in:** archive.html, index.html

### HTML Skeleton

```
<article class="card card--investigation">  <!-- or card--analysis -->
  <div class="card__header">
    <!-- SLOT: status_badge — status badge component -->
    <!-- SLOT: topic_tag — first tag only -->
  </div>
  <h3 class="card__title"><!-- SLOT: title --></h3>
  <p class="card__summary"><!-- SLOT: summary --></p>
  <div class="card__footer">
    <span class="card__id"><!-- SLOT: id --></span>
    <!-- SLOT: correction_dot — render only if has_correction true -->
    <time class="card__date"><!-- SLOT: date --></time>
  </div>
  <a class="card__link" href="<!-- SLOT: url -->">
    <span class="sr-only">Read <!-- SLOT: title --></span>
  </a>
</article>
```

Note: The anchor covers the entire card — click anywhere on the card to navigate.

---

## TEMPLATE 5 — TRUST PAGE SHELL
**File:** `templates/trust-shell.html`
**Copied to:** methodology.html, ai-use.html, corrections.html

### HTML Skeleton

```
<body>
  <!-- COMPONENT: header.html -->

  <main class="trust-page">

    <section class="trust-page__header">
      <h1 class="trust-page__title"><!-- SLOT: page_title --></h1>
      <p class="trust-page__intro"><!-- SLOT: intro --></p>
    </section>

    <article class="trust-page__body">
      <!-- SLOT: page_content — structured sections specific to each trust page -->
    </article>

    <footer class="trust-page__updated">
      <!-- SLOT: last_updated -->
    </footer>

  </main>

  <!-- COMPONENT: footer.html -->
</body>
```

---

## TEMPLATE 6 — HOMEPAGE
**File:** `index.html` — not a blanket template, built directly

### HTML Skeleton

```
<body>
  <!-- COMPONENT: ai-disclosure-bar.html -->
  <!-- COMPONENT: header.html -->

  <main class="home">

    <section class="home__hero">
      <div class="home__mandate"><!-- SLOT: bureau_mandate --></div>
      <div class="home__featured">
        <!-- SLOT: featured_investigation — title, dek, status, date, image, link -->
      </div>
    </section>

    <section class="home__metrics">
      <!-- COMPONENT: metrics-counter-block -->
    </section>

    <section class="home__investigations">
      <h2 class="home__section-label">LATEST INVESTIGATIONS</h2>
      <!-- SLOT: investigation_cards — three cards rendered from investigations.json -->
      <a class="home__view-all" href="archive.html">View all investigations →</a>
    </section>

    <section class="home__analysis">
      <h2 class="home__section-label">ANALYSIS DOMAINS</h2>
      <!-- SLOT: analysis_cards — domain cards from analysis.json -->
      <a class="home__view-all" href="analysis/">View all analysis →</a>
    </section>

    <section class="home__trust">
      <!-- SLOT: trust_surface_strip — three trust links with descriptions -->
    </section>

  </main>

  <!-- COMPONENT: footer.html -->
</body>
```

---

## TEMPLATE RULES — GLOBAL

- SLOT comments are the only content entry points — never add content outside them
- Component comments are the only component entry points — paste the component HTML here
- No inline styles in any template
- No hardcoded colors, sizes, or fonts in any template — all values via CSS classes referencing tokens
- Templates are never deployed directly — always copied and populated first
- A template with unfilled SLOT comments is never published

---

*Templates are the build contracts. When a new investigation or analysis report is started, the first action is copying the correct template. The second action is filling every required slot. Only then does the page exist.*
