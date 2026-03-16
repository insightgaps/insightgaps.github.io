/**
 * ============================================================
 * INSIGHT GAPS — INVESTIGATION REGISTRY
 * ============================================================
 *
 * THE ONLY FILE YOU EDIT WHEN PUBLISHING A NEW INVESTIGATION.
 *
 * HOW TO PUBLISH A NEW INVESTIGATION:
 * 1. Upload your investigation HTML to: /investigations/[scope]/[slug]/index.html
 * 2. Add one new entry to the INVESTIGATIONS array below
 * 3. Commit — every page updates automatically
 *
 * HOW TO UPDATE AN EXISTING INVESTIGATION:
 * 1. Edit the investigation HTML file
 * 2. Update the entry below if title/summary/findings/stats changed
 * 3. Commit — done
 *
 * NOTHING ELSE NEEDS TO BE TOUCHED.
 *
 * URL STRUCTURE (standardised — all investigations use folder pattern):
 *   /investigations/national/[slug]/index.html     ← main report
 *   /investigations/national/[slug]/visual.html    ← visual story (if exists)
 *   /investigations/national/[slug]/methodology.html ← methodology (optional)
 *   /investigations/national/[slug]/tracker.html   ← live tracker (if exists)
 *   International: /investigations/international/[slug]/
 *
 * INVESTIGATION IDs:
 *   BD-INV-001 → Blood Routes (published)
 *   BD-INV-002 → The Impunity Machine (published)
 *   BD-INV-003 → The Lead Belt (published)
 *   BD-INV-004 → Next national investigation
 *   INT-INV-001 → The Hidden Tax of War (published)
 *   INT-INV-002 → Next international investigation
 * ============================================================
 */

const INVESTIGATIONS = [

  // ── BD-INV-003 ─────────────────────────────────────────
  {
    id:       "BD-INV-003",
    title:    "The Lead Belt: Bangladesh's Lead Poisoning Crisis",
    short:    "The Lead Belt",
    slug:     "lead-belt",
    topic:    "environment",
    scope:    "national",
    region:   "Bangladesh",
    date:     "March 2026",
    year:     2026,
    sources:  "Pure Earth / UNICEF / Lancet",
    version:  "v1.0",
    status:   "published",
    featured: true,
    evidence: "Confirmed",
    summary:  "44 formally assessed lead-contaminated sites across Bangladesh have at least one school within 500 metres — placing an estimated 39,875 students in proximity to sites where soil lead reaches 1,702 times the international safety standard. Not one facility has a public record of permanent closure. The first school-proximity lead analysis in South Asia.",
    findings: [
      "<strong>44 sites, 145 schools, ~39,875 students:</strong> The first spatial proximity analysis of its kind in South Asia, built from the Pure Earth contaminated sites database and OpenStreetMap.",
      "<strong>22 years of documentation. Zero permanent closures:</strong> The Department of Environment has had legal authority and public data since 2003. Not one ULAB facility has a confirmed permanent closure on record.",
      "<strong>1,702× the safe limit at the highest site:</strong> Soil lead at Kathgora, Savar reaches 680,872 ppm against the 400 ppm international residential standard."
    ],
    stats: [
      { val: "~39,875", lbl: "Students at risk" },
      { val: "1,702×",  lbl: "Max soil lead vs safe limit" },
      { val: "0",       lbl: "Permanent closures on record" }
    ],
    url:    "/investigations/national/lead-belt/",
    visual: "/investigations/national/lead-belt/visual.html",
    series: {
      methodology: "/investigations/national/lead-belt/methodology.html",
      data:         null
    }
  },

  // ── BD-INV-002 ─────────────────────────────────────────
  {
    id:       "BD-INV-002",
    title:    "The Impunity Machine: Bangladesh's Rape Justice Crisis",
    short:    "The Impunity Machine",
    slug:     "impunity-machine",
    topic:    "accountability",
    scope:    "national",
    region:   "Bangladesh",
    date:     "March 2026",
    year:     2026,
    sources:  "91",
    version:  "v5.0",
    status:   "published",
    featured: false,
    evidence: "Confirmed",
    summary:  "A forensic audit of Bangladesh's rape justice system. 310 convictions in 23 years for 66,711 women who reached a One-Stop Crisis Centre. Zero convictions in the first seven months of 2024. Child rape cases surged 75% in H1 2025. The machine runs.",
    findings: [
      "<strong>0.46% conviction rate:</strong> Of 66,711 women who reached a crisis centre (2001–2024), only 310 resulted in conviction across 23 years.",
      "<strong>52.3% surge (2024→2025):</strong> BMP documented 786 rape victims in 2025 vs 516 in 2024. Child rape cases rose 75% in the first half of the year.",
      "<strong>13 women every day:</strong> PHQ data confirms ~13 women and children raped per day in Bangladesh. 24 perpetrators convicted in five years across all of Dhaka."
    ],
    stats: [
      { val: "91",     lbl: "Sources" },
      { val: "0.46%",  lbl: "OCC conviction rate" },
      { val: "66,711", lbl: "Women — 310 convictions" }
    ],
    url:     "/investigations/national/impunity-machine/",
    visual:  "/investigations/national/impunity-machine/visual.html",
    tracker: "/investigations/national/impunity-machine/tracker.html",
    series: {
      methodology: "/series/impunity-machine/methodology.html",
      data:         "/series/impunity-machine/data.html"
    }
  },

  // ── BD-INV-001 ─────────────────────────────────────────
  {
    id:       "BD-INV-001",
    title:    "Blood Routes: The Dhaka Bus Fatalities Investigation",
    short:    "Blood Routes",
    slug:     "blood-routes",
    topic:    "accountability",
    scope:    "national",
    region:   "Bangladesh",
    date:     "February 2026",
    year:     2026,
    sources:  "155+",
    version:  "v1.0",
    status:   "published",
    featured: false,
    evidence: "Confirmed",
    summary:  "Forensic dataset on bus-related fatalities in Dhaka, the structural incentives of the waybill (Joma) system, and accountability failures. Six operators documented. Phoenix hypothesis: banned operators rebranding to evade enforcement.",
    findings: [
      "<strong>5.8× data gap:</strong> Official figures undercount fatalities by approximately 5.8× vs WHO estimates.",
      "<strong>Phoenix phenomenon:</strong> Banned operators (e.g. Suprobhat) rebrand as Victor Classic and Akash to bypass enforcement.",
      "<strong>Joma system:</strong> The waybill system creates rational economic incentives for bus racing, directly causing pedestrian deaths."
    ],
    stats: [
      { val: "155+",    lbl: "Sources" },
      { val: "5.8×",    lbl: "Data undercount factor" },
      { val: "~31,578", lbl: "WHO est. deaths" }
    ],
    url:    "/investigations/national/blood-routes/",
    visual: null,
    series: {
      methodology: "/series/blood-routes/methodology.html",
      data:         null
    }
  },

  // ── INT-INV-001 ────────────────────────────────────────
  {
    id:       "INT-INV-001",
    title:    "The Hidden Tax of War: How Conflicts Raise Global Prices",
    short:    "The Hidden Tax of War",
    slug:     "war-tax",
    topic:    "conflict-economics",
    scope:    "international",
    region:   "Global",
    date:     "2025",
    year:     2025,
    sources:  "Cross-conflict",
    version:  "v1.0",
    status:   "published",
    featured: false,
    evidence: "Confirmed",
    summary:  "How armed conflicts — Iraq 2003, Arab Spring 2011, Ukraine 2022, Red Sea 2023–24 — transmit economic shocks through energy, food, and shipping markets to countries that never participated. The War Externality Index framework.",
    findings: [
      "One repeated transmission mechanism across multiple conflicts drives global price spillovers to uninvolved nations.",
      "Import-dependent countries absorb disproportionate welfare losses — bottom-quintile households lose 3–5% of real income.",
      "The WEI framework enables cross-conflict quantitative comparison of economic externalities for the first time."
    ],
    stats: [
      { val: "4",     lbl: "Conflicts analyzed" },
      { val: "WEI",   lbl: "War Externality Index" },
      { val: "12–15pp", lbl: "Food inflation gap" }
    ],
    url:    "/investigations/international/war-tax/",
    visual: null,
    series: {
      methodology: "/series/war-tax/methodology.html",
      data:         "/series/war-tax/data.html"
    }
  }

  // ── ADD NEW INVESTIGATIONS BELOW THIS LINE ─────────────
  // Copy any block above, update all fields, save, commit.
  // Next national ID: BD-INV-004
  // Next international ID: INT-INV-002

];

/**
 * TOPIC REGISTRY
 */
const TOPICS = {
  "accountability": {
    label:    "Accountability & Justice",
    color:    "red",
    colorVar: "var(--red)",
    url:      "/topics/accountability/",
    mandate:  "Forensic examination of how institutional systems produce systematic impunity — police, courts, prosecutors."
  },
  "conflict-economics": {
    label:    "Conflict Economics",
    color:    "gold",
    colorVar: "var(--gold)",
    url:      "/topics/conflict-economics/",
    mandate:  "Quantitative analysis of how armed conflicts transmit economic harm across borders to uninvolved countries."
  },
  "operational-intelligence": {
    label:    "Operational Intelligence",
    color:    "teal",
    colorVar: "var(--teal)",
    url:      "/topics/operational-intelligence/",
    mandate:  "Forensic diagnostics applied to operational systems — cash flow, vendor risk, work order patterns."
  },
  "environment": {
    label:    "Environment & Public Health",
    color:    "teal",
    colorVar: "var(--teal)",
    url:      "/topics/operational-intelligence/",
    mandate:  "Forensic spatial and environmental analysis of public health crises caused by regulatory failure."
  }
};

/**
 * HELPER FUNCTIONS
 * Used by all pages to render investigations from registry data.
 */

function getPublished() {
  return INVESTIGATIONS.filter(i => i.status === "published");
}

function getByTopic(topic) {
  return getPublished().filter(i => i.topic === topic);
}

function getByScope(scope) {
  return getPublished().filter(i => i.scope === scope);
}

function getByYear(year) {
  return getPublished().filter(i => i.year === year);
}

function getFeatured() {
  return getPublished().find(i => i.featured === true) || getPublished()[0];
}

function scopeColor(inv) {
  if (inv.topic === "conflict-economics") return "var(--gold)";
  if (inv.topic === "environment") return "var(--teal)";
  if (inv.topic === "operational-intelligence") return "var(--teal)";
  return "var(--red)";
}

// Render sidebar card (homepage)
function renderSidebarCard(inv) {
  const color = scopeColor(inv);
  const scopeLabel = inv.scope === "international" ? "INTERNATIONAL" : "NATIONAL";
  return `
    <div class="sub-story">
      <div class="ss-content">
        <div class="ss-num" style="color:${color};">${scopeLabel}</div>
        <div class="ss-title"><a href="${inv.url}">${inv.title}</a></div>
        <div class="ss-cat">${inv.region} · ${inv.date} · ${inv.sources} Sources</div>
      </div>
    </div>`;
}

// Render full investigation card (investigations/index)
function renderInvCard(inv) {
  const color = scopeColor(inv);
  const bandClass = inv.topic === "conflict-economics" ? "gold" : "";
  const scopeClass = inv.scope === "international" ? "international" : "national";
  const topicData = TOPICS[inv.topic] || TOPICS["accountability"];

  const statsHtml = inv.stats.map(s =>
    `<div class="inv-stat"><div class="inv-stat-val">${s.val}</div><div class="inv-stat-lbl">${s.lbl}</div></div>`
  ).join('');

  const findingsHtml = inv.findings.map(f =>
    `<li>${f}</li>`
  ).join('');

  const visualBtn = inv.visual
    ? `<a href="${inv.visual}" class="btn-report visual-btn">▶ Visual Story →</a>`
    : '';

  const btnStyle = inv.topic !== "accountability"
    ? `style="border-color:${color};color:${color};" onmouseover="this.style.background='${color}';this.style.color='#fff';" onmouseout="this.style.background='transparent';this.style.color='${color}';"`
    : '';

  return `
    <article class="inv-card" data-topics="${inv.topic} ${inv.scope} ${inv.year}">
      <div class="inv-card-band ${bandClass}"></div>
      <div class="inv-card-body">
        <div style="display:flex;align-items:center;flex-wrap:wrap;gap:var(--s2);margin-bottom:var(--s5);">
          <span class="inv-scope ${scopeClass}">${inv.scope === 'international' ? 'International' : 'National'} Investigation</span>
          <a href="${topicData.url}" class="inv-topic-link">${topicData.label} ↗</a>
        </div>
        <h3>${inv.title}</h3>
        <div class="inv-card-meta">
          <span>${inv.id}</span><span>·</span><span>Published ${inv.date}</span><span>·</span><span>${inv.version} Public Release</span>
        </div>
        <div class="inv-stats">${statsHtml}</div>
        <p>${inv.summary}</p>
        <div class="inv-findings ${inv.topic === 'conflict-economics' ? 'gold-border' : ''}">
          <div class="inv-findings-label">Primary Findings</div>
          <ul>${findingsHtml}</ul>
        </div>
        <div class="inv-card-footer">
          <span class="inv-status" style="${inv.topic !== 'accountability' ? 'color:'+color : ''}">Evidence Tier: ${inv.evidence}</span>
          <div style="display:flex;gap:.5rem;flex-wrap:wrap;">
            ${visualBtn}
            <a href="${inv.url}" class="btn-report" ${btnStyle}>View Full Investigation →</a>
          </div>
        </div>
      </div>
    </article>`;
}

// Render topic hub row
function renderTopicRow(inv, index) {
  const color = scopeColor(inv);
  const findingsHtml = inv.findings.map(f => `<li>${f}</li>`).join('');

  return `
    <div class="inv-row-card">
      <div class="inv-row-num" style="color:rgba(0,0,0,0.06);">0${index+1}</div>
      <div class="inv-row-content">
        <div class="inv-row-meta" style="color:${color};">${inv.id} · Published ${inv.date} · ${inv.version} Public Release</div>
        <h3>${inv.title}</h3>
        <p>${inv.summary}</p>
        <div class="inv-key-findings">
          <div class="inv-key-findings-label">Primary Findings</div>
          <ul>${findingsHtml}</ul>
        </div>
        <div class="inv-row-footer">
          <span class="inv-evidence-tag">${inv.evidence} · ${inv.sources} Sources</span>
          <a href="${inv.url}" class="btn-report" ${inv.topic !== 'accountability' ? `style="border-color:${color};color:${color};" onmouseover="this.style.background='${color}';this.style.color='#fff';" onmouseout="this.style.background='transparent';this.style.color='${color}';"` : ''}>Read Investigation →</a>
        </div>
      </div>
    </div>`;
}

// Render dossier row for series/index
function renderDossierRow(inv) {
  const color = scopeColor(inv);
  const topicData = TOPICS[inv.topic] || TOPICS["accountability"];
  const idStyle = inv.topic === "conflict-economics"
    ? "background:rgba(184,134,11,0.08);color:var(--gold);border:1px solid rgba(184,134,11,0.2);"
    : "background:rgba(196,30,58,0.08);color:var(--red);border:1px solid rgba(196,30,58,0.2);";

  const methodologyLink = inv.series && inv.series.methodology
    ? `<a href="${inv.series.methodology}" class="dossier-page-link">
        <span class="dossier-page-icon">MTH</span>
        <div><div class="dossier-page-label">Methodology</div><div class="dossier-page-desc">Evidence framework · source tiers</div></div>
      </a>`
    : '';

  const dataLink = inv.series && inv.series.data
    ? `<a href="${inv.series.data}" class="dossier-page-link">
        <span class="dossier-page-icon">DAT</span>
        <div><div class="dossier-page-label">Data &amp; Evidence</div><div class="dossier-page-desc">Datasets · documentation</div></div>
      </a>`
    : '';

  return `
    <div class="dossier-row">
      <div class="dossier-header">
        <div class="dossier-id-block">
          <span class="dossier-id" style="${idStyle}">${inv.id}</span>
          <span style="font-family:var(--mono);font-size:0.6rem;color:var(--text-4);">${topicData.label}</span>
        </div>
        <span class="dossier-pub">Published ${inv.date} · ${inv.version}</span>
      </div>
      <div class="dossier-body">
        <div>
          <h2 class="dossier-title">${inv.title}</h2>
          <p class="dossier-summary">${inv.summary}</p>
        </div>
        <div class="dossier-pages">
          <a href="${inv.url}" class="dossier-page-link">
            <span class="dossier-page-icon">RPT</span>
            <div><div class="dossier-page-label">Full Investigation</div><div class="dossier-page-desc">${inv.sources} sources · ${inv.evidence}</div></div>
          </a>
          ${methodologyLink}
          ${dataLink}
        </div>
      </div>
    </div>`;
}
