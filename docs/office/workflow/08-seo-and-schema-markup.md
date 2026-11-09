# Workflow Stage 08: SEO & Schema Markup

**Stage:** 08 · Search Discovery, Structured Data & Metadata  
**Owner:** Agent 08 (SEO / Discovery)  
**Input:** Polished `investigations/<slug>/index.html`  
**Outputs:** Updated `investigations/<slug>/index.html`, updated `sitemap.xml`, `docs/office/workspace/seo/<slug>-seo-report.md`

---

## 1. Objectives

The SEO & Schema Markup stage equips the investigation with publication-grade semantic metadata, structured JSON-LD schemas, social preview tags, and search engine discovery pathways, while enforcing zero-tracking privacy standards.

---

## 2. Core SEO & Metadata Standards

1. **Structured Data:** Implement schema.org `NewsArticle` JSON-LD in the document `<head>`:
   - Valid fields: `headline`, `description`, `image`, `datePublished`, `dateModified`, `author`, `publisher`.
2. **Canonical URL:** Always set canonical tag to the live production URL:
   `<link rel="canonical" href="https://insightgaps.com/investigations/<slug>/">`
3. **Open Graph & Twitter Cards:**
   - `og:title`, `og:description` (150–160 chars), `og:image` (1200×630px), `og:type="article"`.
   - `twitter:card="summary_large_image"`.
4. **Clean XML Sitemap:** Update `/sitemap.xml` with standard `<url>` entry, `<loc>`, `<lastmod>`, and `<changefreq>weekly</changefreq>`.
5. **Pagefind Client-Side Search:**
   - Tag the main narrative container with `data-pagefind-body`.
   - Tag primary headline with `data-pagefind-weight="10"`.
   - Mark secondary `<details>` tables and navigation noise with `data-pagefind-ignore`.
6. **Zero Commercial Trackers:** Never add GA4, Google Tag Manager, Facebook Pixel, or third-party cookies.

---

## 3. Step-by-Step Procedure

1. **Draft Headline & Meta Description:**
   - Write a crisp headline (≤70 characters) containing the core topic and primary metric.
   - Write a meta description (140–160 characters) summarizing the empirical finding.

2. **Inject Meta Tags and JSON-LD:**
   - Insert canonical, Open Graph, and Twitter tags into `<head>`.
   - Insert validated `NewsArticle` JSON-LD block.

3. **Verify Open Graph Asset:**
   - Confirm that the referenced `og:image` exists at `assets/img/hero-<slug>-gemini.jpg` (or `assets/img/og-image.png`).

4. **Update `sitemap.xml`:**
   - Append the new URL entry to `sitemap.xml`.

5. **Deliverable Production:**
   - Save modified `investigations/<slug>/index.html` and `sitemap.xml`.
   - Output `docs/office/workspace/seo/<slug>-seo-report.md`.


---

## 4. Pagefind Search Index Build (Owner Command)

Insight Gaps uses Pagefind for completely static, zero-tracking, client-side search. Node is deliberately not installed in restricted automated worker environments. The search index is generated directly by the human site owner using `npx`:

```bash
npx -y pagefind --site . --output-path _pagefind --exclude 'preservation/**'
```

### Execution Rules:
- **Canonical Output Path:** `_pagefind` (matched by `/search/index.html` loading `/_pagefind/pagefind-ui.js` and `/_pagefind/pagefind-ui.css`).
- **Preservation Exclusion:** The gated preservation section (`preservation/**`) MUST be excluded from the public search index via `--exclude 'preservation/**'`.
- **Pre-deployment Trigger:** The owner runs this command prior to site deployment whenever new investigations, evidence dossiers, or methodologies are published.
