# 04-content-schema.md — Insight Gaps Content Schema
**Version:** 1.0
**Status:** Active
**Rule:** No page is designed or built until its schema is fully defined here.

---

## WHAT THIS DOCUMENT IS

This document answers one question per page type:
**What fields must exist before this page can be built?**

Design follows content. No field is added during the design or build phase.
If a new field is needed, update this document first, then update the design and template.

---

## SCHEMA 1 — INVESTIGATION PAGE (INV-00X)

Stored in: `data/investigations.json`
Template: `templates/investigation-blanket.html`

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string | yes | e.g. `INV-003` — matches folder name exactly |
| `title` | string | yes | Full editorial headline |
| `dek` | string | yes | One sentence expanding the headline |
| `slug` | string | yes | URL-safe identifier e.g. `the-lead-belt` |
| `date_published` | date | yes | ISO format: YYYY-MM-DD |
| `date_revised` | date | no | ISO format — populated only if revised |
| `status` | enum | yes | `published` `corrected` `developing` `terminated` `archived` |
| `investigation_type` | enum | yes | `Tier 1 — Document-Heavy` `Tier 2 — Data-Driven` `Tier 3 — Source-Driven` |
| `topic_tags` | array | yes | e.g. `["lead contamination", "public health", "education"]` |
| `summary` | string | yes | One sentence — used in archive cards and homepage feed |
| `key_findings` | array | yes | Exactly three strings — core verified findings from handoff.md |
| `source_count` | integer | yes | Total primary sources in offline vault |
| `methodology_link` | string | yes | Path to investigation-specific methodology.md |
| `has_correction` | boolean | yes | Default false — triggers correction banner if true |
| `correction_notes` | array | no | Populated only if has_correction is true |
| `og_image_path` | string | yes | Path to 1200x630 share image |
| `related_items` | array | no | Array of INV ids — max three |
| `rtl_status` | string | no | RTI filing status if applicable |

---

## SCHEMA 2 — ANALYSIS DOMAIN PAGE

Stored in: `data/analysis.json` under `domains[]`
Template: `templates/analysis-domain.html`

| Field | Type | Required | Notes |
|---|---|---|---|
| `domain_id` | string | yes | e.g. `property-preservation` |
| `domain_title` | string | yes | Display name e.g. `Property Preservation` |
| `domain_slug` | string | yes | URL path e.g. `property-preservation` |
| `description` | string | yes | Two to three sentences — what this domain covers and who it serves |
| `audience` | string | yes | e.g. `Business operators, investors, portfolio reviewers` |
| `report_count` | integer | yes | Auto-derived from reports array length |
| `last_updated` | date | yes | ISO format — date of most recent report |
| `reports` | array | yes | Array of report objects — see Schema 3 |

---

## SCHEMA 3 — ANALYSIS REPORT PAGE

Stored in: `data/analysis.json` under `domains[].reports[]`
Template: `templates/analysis-report.html`

| Field | Type | Required | Notes |
|---|---|---|---|
| `report_id` | string | yes | e.g. `pp-financial-health` |
| `title` | string | yes | Professional report title |
| `tag` | string | yes | Short category label e.g. `Cash Flow Risk` |
| `date` | date | yes | ISO format |
| `executive_summary` | string | yes | Two to four sentences — high scannability for business readers |
| `key_findings` | array | yes | Three to five bullet strings |
| `methodology_note` | string | yes | Brief note on data sources and analytical approach |
| `dataset_reference` | string | no | Source dataset name or reference |
| `confidence_level` | enum | no | `High` `Medium` `Indicative` |
| `visuals` | array | no | Array of image paths for charts or dashboards |
| `preview_image` | string | yes | Path to report card preview image |
| `contact_cta` | boolean | yes | Whether to show commission/contact button — default true |

---

## SCHEMA 4 — HOMEPAGE

Not stored in JSON. Renders dynamically from investigations.json and analysis.json.
Template: `index.html`

| Block | Data source | Required | Notes |
|---|---|---|---|
| Bureau logotype | Static | yes | Text only — no image dependency |
| Bureau mandate statement | Static | yes | One sentence — never changes |
| Featured investigation | `investigations.json` — top published entry | yes | Pulls: title, dek, og_image_path, date |
| Metrics counters | Derived from both JSON files | yes | Investigation count, source count, correction count |
| Investigation feed cards | `investigations.json` | yes | Pulls: id, title, summary, date, status, topic_tags |
| Analysis domain cards | `analysis.json` | yes | Pulls: domain_title, description, report_count, last_updated |
| Trust surface links | Static | yes | Links to methodology, ai-use, corrections pages |

---

## SCHEMA 5 — ARCHIVE PAGE

Renders dynamically from investigations.json and analysis.json.
Template: `archive.html`

| Block | Data source | Required | Notes |
|---|---|---|---|
| Filter controls | Static UI | yes | Filter by: status, topic_tags, date, content type |
| Investigation cards | `investigations.json` | yes | Pulls: id, title, summary, date, status, topic_tags, has_correction |
| Analysis domain cards | `analysis.json` | yes | Pulls: domain_title, description, report_count |
| Status badge | Per card | yes | Must display status on every card — including terminated |
| Correction indicator | Per card | no | Shown only if has_correction is true |

---

## SCHEMA 6 — TRUST PAGES

### methodology.html
| Field | Type | Notes |
|---|---|---|
| Page title | string | Static |
| Intro statement | string | What Insight Gaps considers verified |
| Verification tiers | structured list | Tier 1, Tier 2, Tier 3 — definitions and standards |
| Data handling rules | structured list | Raw file rules, transformation protocol |
| Last updated | date | Updated any time methodology changes |

### ai-use.html
| Field | Type | Notes |
|---|---|---|
| Page title | string | Static |
| Intro statement | string | Role of AI in the bureau workflow |
| AI operations table | table | Columns: Tool Name, Primary Role, What It Must Not Own |
| Last updated | date | Updated any time tools or roles change |

### corrections.html
| Field | Type | Notes |
|---|---|---|
| Page title | string | Static |
| Corrections log | append-only table | Columns: Date, Investigation ID, Error Identified, Correction Executed |
| Rule notice | string | Entries are never deleted — only appended |

---

## SCHEMA 7 — SUPPORTING PAGES

### about.html
| Field | Type | Notes |
|---|---|---|
| Bureau mission statement | string | What Insight Gaps is and why it exists |
| Editor profile | string | Name, background, credentials — no photograph required |
| Funding disclosure | string | How the bureau is funded — required for credibility |
| Methodology philosophy | string | Summary link to full methodology page |

### contact.html
| Field | Type | Notes |
|---|---|---|
| Tip submission form | form | Via Formspree or equivalent — no backend storage |
| Secure contact note | string | What submitters should know about data handling |
| General contact | string | Email address only |

### 404.html
| Field | Type | Notes |
|---|---|---|
| Error message | string | Human — not technical |
| Navigation recovery | links | Back to homepage and archive |

---

## FIELD RULES

- No field is optional if marked required — page cannot be published without it
- Arrays have minimum lengths defined per schema — do not publish with empty arrays
- `key_findings` for investigations pulls directly from the investigation's handoff.md — no paraphrasing at build time
- `status` field drives visual treatment in archive and homepage — keep it accurate
- `has_correction` must be updated in investigations.json the same day a correction is published
- `date_revised` is only populated on genuine content corrections — not design updates

---

*This document is the content foundation. Design tokens, component rules, page specs, and templates all derive from the field structures defined here. If a layout cannot accommodate a required field, the layout is wrong, not the field.*
