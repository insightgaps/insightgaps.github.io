# Correction Entry Specification

**Schema Version:** 1.0  
**Authority:** Agent 10 (Post-Publication Accountability)  

---

## 1. Markdown Log Format for `corrections/index.html`

```html
<article class="correction-card" id="cor-{{YYYYMMDD}}-{{SLUG}}">
  <div class="correction-card__header">
    <span class="badge badge--correction">Correction</span>
    <time datetime="{{YYYY-MM-DD}}">{{HUMAN_DATE}}</time>
    <span class="correction-card__target">Investigation: <a href="/investigations/{{SLUG}}/">{{INVESTIGATION_TITLE}}</a></span>
  </div>
  <div class="correction-card__body">
    <h4>Correction: {{BRIEF_DESCRIPTION_OF_REVISION}}</h4>
    <div class="correction-diff">
      <div class="diff-block diff-block--original">
        <strong>Original Text:</strong>
        <p>"{{ORIGINAL_QUOTED_TEXT_WITH_ERROR}}"</p>
      </div>
      <div class="diff-block diff-block--corrected">
        <strong>Corrected Text:</strong>
        <p>"{{CORRECTED_TEXT}}"</p>
      </div>
    </div>
    <p class="correction-card__reason"><strong>Reason & Audit Note:</strong> {{EXPLANATION_OF_WHY_DISCREPANCY_OCCURRED_AND_HOW_IT_WAS_RESOLVED}}</p>
  </div>
</article>
```

---

## 2. In-Story Alert Callout Boilerplate

To be placed immediately below `<header class="report-header">` in `investigations/<slug>/index.html`:

```html
<aside class="alert-box alert-box--correction" role="note">
  <div class="alert-box__badge">CORRECTION · {{HUMAN_DATE}}</div>
  <p>An earlier version of this report stated that [ORIGINAL_FINDING]. This has been corrected to [CORRECTED_FINDING] following verification against [OFFICIAL_PRIMARY_SOURCE]. See our <a href="/corrections/#cor-{{YYYYMMDD}}-{{SLUG}}">Permanent Corrections Log</a> for full details.</p>
</aside>
```
