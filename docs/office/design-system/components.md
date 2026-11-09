# Insight Gaps Component Library

**Forensic UI Component Catalog**  
**Design Reference for Agent 06 (UI Designer)**  
**Maintained in:** `assets/css/style.css`

---

## 1. Global Header Navigation

```html
<header class="site-header" role="banner">
  <div class="site-header__inner">
    <a href="/" class="site-header__logo" aria-label="Insight Gaps Homepage">
      <span class="logo__brand">Insight Gaps</span>
      <small>Forensic Public Data Bureau</small>
    </a>
    <nav class="site-nav" aria-label="Main Navigation">
      <a href="/investigations/" class="site-nav__link">Investigations</a>
      <a href="/methodology/" class="site-nav__link">Methodology</a>
      <a href="/corrections/" class="site-nav__link">Corrections</a>
    </nav>
  </div>
</header>
```

---

## 2. Article Header & Hero Section

```html
<header class="report-header">
  <div class="report-header__badge">
    <span class="eyebrow">Public Data Investigation · Series No. 04</span>
  </div>
  <h1 class="report-header__title">Headline Stating Verified Empirical Finding</h1>
  <p class="report-header__deck">A two-sentence deck contextualizing the institutional breakdown and primary verified multiple.</p>
  
  <div class="meta">
    <span>By <strong>Insight Gaps Bureau</strong></span>
    <span>·</span>
    <time datetime="2026-11-09">9 November 2026</time>
    <span>·</span>
    <span>Standard: <strong>Public Data Only</strong></span>
  </div>

  <figure class="hero-figure">
    <img src="/assets/img/hero-[slug]-gemini.jpg" alt="Descriptive visual caption" class="hero-img" width="960" height="480">
    <figcaption class="meta">Visual model constructed from verified public geographic coordinates.</figcaption>
  </figure>
</header>
```

---

## 3. Key Stat Callout Grid (`.stat-strip`)

Used immediately following the hero to anchor the primary findings:

```html
<section class="stat-strip" aria-label="Key Quantitative Findings">
  <div>
    <strong>5.8×</strong>
    <span>Official casualty undercount multiple calculated against hospital registries</span>
  </div>
  <div>
    <strong>41.6%</strong>
    <span>Proportion of highway fatalities concentrated in the 10pm–6am enforcement void</span>
  </div>
  <div>
    <strong>95.1%</strong>
    <span>Police FIR database padding identified across 47,680 unclassified entries</span>
  </div>
</section>
```

---

## 4. Full-Width Vector Chart (`figure.chart-full`)

Ensures desktop visuals expand to full 960px container width:

```html
<figure class="chart-full" id="figure-01">
  <img src="/assets/img/charts/[slug]-gap.svg" alt="Accessible description of chart data" width="960" height="260" loading="lazy">
  <figcaption><strong>Figure 1 · The Undercount Gap.</strong> Official departmental fatality totals versus audited hospital admission registries (2020–2025). Source: BRTA and DGHS published records.</figcaption>
</figure>
```

---

## 5. Expandable Evidence Box (`<details class="evidence-box">`)

Used for dense multi-row tables, complete upazila rosters, and mathematical derivations:

```html
<details class="evidence-box">
  <summary>View Complete 64-District Backlog Table & Methodology (64 Rows)</summary>
  <div class="evidence-box__content">
    <p class="meta">Raw microdata extracted from Ministry of Law Annual Statistical Bulletins. All rates calculated per 100,000 population using BBS 2022 Census denominators.</p>
    <div class="table-responsive">
      <table>
        <caption>Table 1.1 · Longitudinal Case Filings vs Disposals by Division</caption>
        <thead>
          <tr>
            <th>Division / District</th>
            <th>Cases Filed</th>
            <th>Cases Disposed</th>
            <th>Convictions</th>
            <th>Effective Conviction Rate</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Dhaka Special Tribunal</td>
            <td>17,544</td>
            <td>5,648</td>
            <td>182</td>
            <td><strong>1.04%</strong></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</details>
```

---

## 6. Claim Register Matrix (`.grade-legend` & `.grade`)

Mandatory audit register at the conclusion of every investigation:

```html
<section class="evidence-panel" aria-label="Audited Claim Register">
  <h3>Audited Claim Register</h3>
  <ul class="grade-legend">
    <li><span class="grade grade--confirmed">Confirmed</span> Independently Calculated</li>
    <li><span class="grade grade--supported">Supported</span> Official Institutional Monitoring</li>
    <li><span class="grade grade--contested">Probable</span> Corroborated Structural Finding</li>
  </ul>
  
  <table>
    <thead>
      <tr>
        <th>Finding / Claim</th>
        <th>Primary Public Document</th>
        <th>Grade</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>5.8× Fatality Undercount in National Road Registry</td>
        <td>DGHS Annual Health Bulletin 2024, Table 12, p. 84</td>
        <td><span class="grade grade--confirmed">Confirmed</span></td>
      </tr>
    </tbody>
  </table>
</section>
```

---

## 7. Trust & Methodology Anchor Block

```html
<aside class="banner" role="complementary">
  <h3>Public Data Mandate & Verification</h3>
  <p>Insight Gaps investigations are derived strictly from published official records, remote sensing, and government gazettes. We do not conduct interviews or submit RTI requests.</p>
  <p><a href="/methodology/">Read our 7-step verification methodology &rarr;</a> · <a href="/docs/rules-and-methods.md">Review bureau operating rules &rarr;</a></p>
</aside>
```

---

## 8. Global Site Footer

```html
<footer class="site-footer" role="contentinfo">
  <div class="site-footer__inner">
    <p>&copy; 2026 Insight Gaps Bureau. An independent forensic data journalism desk. Published under CC BY 4.0 (Public Data Only).</p>
    <nav aria-label="Footer Navigation">
      <a href="/">Home</a>
      <a href="/investigations/">Investigations</a>
      <a href="/methodology/">Methodology</a>
      <a href="/corrections/">Corrections</a>
    </nav>
  </div>
</footer>
```
