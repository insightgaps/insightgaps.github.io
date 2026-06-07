(function () {
  'use strict';

  var state = {
    investigations: [],
    domains: []
  };

  function esc(value) {
    return String(value == null ? '' : value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function formatDate(value) {
    if (!value) return '';
    var date = new Date(value);
    if (Number.isNaN(date.getTime())) return value;
    return date.toLocaleDateString('en-GB', {
      day: 'numeric',
      month: 'long',
      year: 'numeric'
    });
  }

  function statusBadge(status) {
    var clean = esc(status || 'archived');
    return '<span class="status-badge status-badge--' + clean + '">' +
      clean.replace(/-/g, ' ').toUpperCase() +
      '</span>';
  }

  function firstSentence(text) {
    var value = String(text || '');
    var match = value.match(/^.*?[.!?](?:\s|$)/);
    return match ? match[0].trim() : value;
  }

  function isDraftSlot(text) {
    return String(text || '').indexOf('SLOT:') !== -1;
  }

  async function loadJSON(path) {
    var response = await fetch(path);
    if (!response.ok) throw new Error(path + ' returned ' + response.status);
    return response.json();
  }

  function investigationUrl(inv) {
    if (inv.url) return inv.url;
    return '/content/investigations/' + encodeURIComponent(inv.slug || '') + '/';
  }

  function domainUrl(domain) {
    return '/analysis/' + encodeURIComponent(domain.domain_slug || domain.slug || '') + '/';
  }

  function reportUrl(domain, report) {
    return domainUrl(domain) + encodeURIComponent(report.report_id || report.slug || '') + '.html';
  }

  function buildInvestigationCard(inv) {
    var tags = Array.isArray(inv.topic_tags) ? inv.topic_tags : [];
    var tag = tags.length ? tags[0] : 'Investigation';
    var date = inv.date_published || inv.date || '';
    var correction = inv.has_correction
      ? '<span class="inv-card__correction-dot" aria-label="Correction issued"></span>'
      : '';
    var img = inv.og_image_path
      ? '  <div class="inv-card__image-wrap"><img class="inv-card__image" src="' + esc(inv.og_image_path) + '" alt="' + esc(inv.title) + '"></div>'
      : '';

    return [
      '<article class="inv-card" data-type="investigation" data-status="' + esc(inv.status) + '">',
      img,
      '  <div class="inv-card__header">',
      '    <span class="inv-card__tag">' + esc(tag) + '</span>',
      '    ' + statusBadge(inv.status),
      '  </div>',
      '  <h3 class="inv-card__title">' + esc(inv.title) + '</h3>',
      '  <p class="inv-card__summary">' + esc(inv.summary || inv.dek) + '</p>',
      '  <footer class="inv-card__footer">',
      '    <span class="inv-card__id">' + correction + esc(inv.id) + '</span>',
      '    <time class="inv-card__date" datetime="' + esc(date) + '">' + esc(formatDate(date)) + '</time>',
      '  </footer>',
      '  <a class="inv-card__link" href="' + investigationUrl(inv) + '" aria-label="Open ' + esc(inv.title) + '"></a>',
      '</article>'
    ].join('\n');
  }

  function buildAnalysisCard(domain) {
    var count = Number(domain.report_count || (domain.reports || []).length || 0);
    var label = count === 1 ? '1 report' : count + ' reports';

    return [
      '<article class="analysis-card" data-type="analysis" data-status="published">',
      '  <h3 class="analysis-card__title">' + esc(domain.domain_title || domain.name) + '</h3>',
      '  <p class="analysis-card__description">' + esc(domain.description || domain.summary) + '</p>',
      '  <footer class="analysis-card__footer">',
      '    <span class="analysis-card__count">' + esc(label) + '</span>',
      '    <time class="analysis-card__date" datetime="' + esc(domain.last_updated) + '">' + esc(formatDate(domain.last_updated)) + '</time>',
      '  </footer>',
      '  <a class="analysis-card__link" href="' + domainUrl(domain) + '" aria-label="Open ' + esc(domain.domain_title || domain.name) + '"></a>',
      '</article>'
    ].join('\n');
  }

  function renderFeatured() {
    var target = document.getElementById('js-featured-investigation');
    var imageTarget = document.getElementById('js-featured-image');
    if (!target) return;

    var inv = state.investigations.find(function (item) {
      return item.slug === 'the-impunity-machine';
    });

    if (!inv) {
      var published = state.investigations
        .filter(function (inv) { return inv.status === 'published'; })
        .sort(function (a, b) {
          return new Date(b.date_published || 0) - new Date(a.date_published || 0);
        });
      inv = published[0] || state.investigations[0];
    }

    if (!inv) {
      target.innerHTML = '<p class="home__empty-state">No investigations published yet.</p>';
      return;
    }

    target.innerHTML = [
      '<div class="home__featured-meta">' + statusBadge(inv.status) +
      '<time class="home__featured-date" datetime="' + esc(inv.date_published) + '">' + esc(formatDate(inv.date_published)) + '</time></div>',
      '<h2 class="home__featured-title">' + esc(inv.title) + '</h2>',
      '<p class="home__featured-dek">' + esc(inv.dek || inv.summary) + '</p>',
      '<a class="home__featured-link" href="' + investigationUrl(inv) + '">Read investigation &rarr;</a>'
    ].join('\n');

    if (imageTarget) {
      if (inv.og_image_path) {
        imageTarget.innerHTML = '<img src="' + esc(inv.og_image_path) + '" alt="Visual summary of ' + esc(inv.title) + '" style="width:100%; height:100%; object-fit:cover; display:block;">';
      } else {
        imageTarget.innerHTML = '<div class="home__hero-image-placeholder" aria-hidden="true">' +
          '<span>' + esc(inv.id) + '</span>' +
          '</div>';
      }
    }
  }

  function renderHomeCards() {
    var invTarget = document.getElementById('js-investigation-cards');
    if (invTarget) {
      var isHomePage = window.location.pathname === '/' || window.location.pathname === '/index.html';
      var items = state.investigations
        .filter(function (inv) {
          if (isHomePage && inv.slug === 'dhaka-slum-fires') {
            return false;
          }
          return inv.status === 'published' || inv.status === 'developing';
        })
        .slice(0, 3);
      invTarget.innerHTML = items.length
        ? items.map(buildInvestigationCard).join('\n')
        : '<p class="home__empty-state">No investigations published yet.</p>';
    }

    var analysisTarget = document.getElementById('js-analysis-cards');
    if (analysisTarget) {
      analysisTarget.innerHTML = state.domains.length
        ? state.domains.map(buildAnalysisCard).join('\n')
        : '<p class="home__empty-state">No analysis domains yet.</p>';
    }
  }

  function renderMetrics() {
    var invCount = document.getElementById('js-count-investigations');
    var sourceCount = document.getElementById('js-count-sources');
    var correctionCount = document.getElementById('js-count-corrections');

    if (invCount) invCount.textContent = state.investigations.length;
    if (sourceCount) {
      sourceCount.textContent = state.investigations.reduce(function (sum, inv) {
        return sum + Number(inv.source_count || 0);
      }, 0);
    }
    if (correctionCount) {
      correctionCount.textContent = state.investigations.filter(function (inv) {
        return Boolean(inv.has_correction);
      }).length;
    }
  }

  function archiveItems() {
    var investigations = state.investigations.map(function (inv) {
      return {
        type: 'investigation',
        status: inv.status || 'archived',
        tags: Array.isArray(inv.topic_tags) ? inv.topic_tags : [],
        date: inv.date_published || '',
        html: buildInvestigationCard(inv)
      };
    });

    var domains = state.domains.map(function (domain) {
      return {
        type: 'analysis',
        status: 'published',
        tags: [domain.domain_title || domain.domain || 'analysis'],
        date: domain.last_updated || '',
        html: buildAnalysisCard(domain)
      };
    });

    return investigations.concat(domains);
  }

  function populateArchiveTags() {
    var select = document.getElementById('filter-tag');
    if (!select || select.options.length > 1) return;

    var tags = [];
    state.investigations.forEach(function (inv) {
      (inv.topic_tags || []).forEach(function (tag) { tags.push(tag); });
    });
    state.domains.forEach(function (domain) {
      tags.push(domain.domain_title || domain.domain || 'analysis');
    });

    Array.from(new Set(tags)).sort().forEach(function (tag) {
      var option = document.createElement('option');
      option.value = tag;
      option.textContent = tag;
      select.appendChild(option);
    });
  }

  function renderArchive() {
    var grid = document.getElementById('js-archive-results');
    if (!grid) return;

    var type = (document.getElementById('filter-type') || {}).value || 'all';
    var status = (document.getElementById('filter-status') || {}).value || 'all';
    var tag = (document.getElementById('filter-tag') || {}).value || 'all';
    var sort = (document.getElementById('filter-sort') || {}).value || 'newest';

    var items = archiveItems().filter(function (item) {
      var typeMatch = type === 'all' || item.type === type;
      var statusMatch = status === 'all' || item.status === status;
      var tagMatch = tag === 'all' || item.tags.indexOf(tag) !== -1;
      return typeMatch && statusMatch && tagMatch;
    });

    items.sort(function (a, b) {
      var diff = new Date(b.date || 0) - new Date(a.date || 0);
      return sort === 'oldest' ? diff * -1 : diff;
    });

    grid.innerHTML = items.map(function (item) { return item.html; }).join('\n');

    var count = document.getElementById('js-results-count');
    if (count) count.textContent = items.length + ' result' + (items.length === 1 ? '' : 's') + ' shown';

    var empty = document.getElementById('js-archive-empty');
    if (empty) empty.hidden = items.length !== 0;
  }

  function renderArchiveHeader() {
    var subtitle = document.getElementById('js-archive-subtitle');
    if (!subtitle) return;

    subtitle.textContent = state.investigations.length + ' investigations · ' +
      state.domains.length + ' analysis ' + (state.domains.length === 1 ? 'domain' : 'domains');
  }

  function renderAnalysisDomainPage() {
    if (!document.querySelector('.analysis-domain')) return;

    var path = window.location.pathname;
    var domain = state.domains.find(function (item) {
      return path.indexOf('/analysis/' + item.domain_slug + '/') !== -1;
    }) || state.domains[0];
    if (!domain) return;

    document.title = domain.domain_title + ' Analysis - Insight Gaps Bureau';
    document.querySelectorAll('.analysis-domain__title').forEach(function (el) {
      el.textContent = domain.domain_title;
    });
    document.querySelectorAll('.breadcrumb span:last-child').forEach(function (el) {
      el.textContent = domain.domain_title;
    });

    var audience = document.querySelector('.analysis-domain__audience');
    if (audience) audience.textContent = domain.audience || 'Analysis domain';

    var description = document.querySelector('.analysis-domain__description');
    if (description) description.textContent = domain.description || '';

    var meta = document.querySelector('.analysis-domain__meta');
    if (meta) {
      meta.innerHTML = '<span>' + Number(domain.report_count || (domain.reports || []).length || 0) +
        ' reports</span><span class="analysis-domain__meta-sep" aria-hidden="true">&middot;</span>' +
        '<span>Last updated ' + esc(formatDate(domain.last_updated)) + '</span>';
    }

    var grid = document.querySelector('.analysis-domain .card-grid--two');
    if (grid) {
      var reports = domain.reports || [];
      grid.innerHTML = reports.length ? reports.map(function (report) {
        return [
          '<article class="report-card">',
          '  <span class="report-card__tag">' + esc(report.tag) + '</span>',
          '  <h2 class="report-card__title">' + esc(report.title) + '</h2>',
          '  <p class="report-card__summary">' + esc(firstSentence(report.executive_summary)) + '</p>',
          '  <div class="report-card__footer">',
          '    <time class="report-card__date" datetime="' + esc(report.date) + '">' + esc(formatDate(report.date)) + '</time>',
          '    <span class="report-card__read" aria-hidden="true">Read report &rarr;</span>',
          '  </div>',
          '  <a class="report-card__link" href="' + reportUrl(domain, report) + '"><span class="sr-only">Read ' + esc(report.title) + '</span></a>',
          '</article>'
        ].join('\n');
      }).join('\n') : '<div class="domain-empty"><p class="domain-empty__text">Reports for this domain are in preparation.</p></div>';
    }
  }

  function renderInvestigationPage() {
    var page = document.querySelector('[data-investigation-slug]');
    if (!page) return;

    var slug = page.getAttribute('data-investigation-slug');
    var inv = state.investigations.find(function (item) { return item.slug === slug; });
    if (!inv) return;

    document.title = inv.title + ' - Insight Gaps Bureau';

    var title = document.getElementById('js-investigation-title');
    var dek = document.getElementById('js-investigation-dek');
    var meta = document.getElementById('js-investigation-meta');
    var badges = document.getElementById('js-investigation-badges');
    var findings = document.getElementById('js-investigation-findings');
    var sources = document.getElementById('js-investigation-sources');
    var method = document.getElementById('js-investigation-methodology');

    if (title) title.textContent = inv.title;
    if (dek) dek.textContent = inv.dek || inv.summary || '';
    if (badges) {
      badges.innerHTML = statusBadge(inv.status) +
        '<span class="tier-badge">' + esc(inv.investigation_type || 'Verification tier pending') + '</span>';
    }
    if (meta) {
      meta.innerHTML = '<span>Insight Gaps Bureau</span><span aria-hidden="true">·</span>' +
        '<time datetime="' + esc(inv.date_published) + '">' + esc(formatDate(inv.date_published)) + '</time>' +
        '<span class="investigation__id">' + esc(inv.id) + '</span>';
    }
    if (findings) {
      var cleanFindings = (inv.key_findings || []).filter(function (finding) {
        return !isDraftSlot(finding);
      });
      findings.innerHTML = cleanFindings.length ? cleanFindings.slice(0, 3).map(function (finding, index) {
        return '<li class="investigation__finding"><span class="investigation__finding-number" aria-hidden="true">' +
          String(index + 1).padStart(2, '0') + '</span><p class="investigation__finding-text">' +
          esc(finding) + '</p></li>';
      }).join('\n') : '<li class="investigation__finding"><span class="investigation__finding-number" aria-hidden="true">01</span><p class="investigation__finding-text">Key findings slot reserved for final reporting handoff.</p></li>';
    }
    if (sources) sources.textContent = Number(inv.source_count || 0) + ' sources on record';
    if (method) {
      method.textContent = inv.rtl_status ||
        'Methodology page and source documentation are part of the required publication structure for this investigation.';
    }
  }

  function renderAnalysisReportPage() {
    var page = document.querySelector('[data-analysis-report]');
    if (!page) return;

    var domainSlug = page.getAttribute('data-domain-slug');
    var reportId = page.getAttribute('data-analysis-report');
    var domain = state.domains.find(function (item) { return item.domain_slug === domainSlug; });
    var report = domain && (domain.reports || []).find(function (item) { return item.report_id === reportId; });
    if (!domain || !report) return;

    document.title = report.title + ' - Insight Gaps Bureau';
    var domainEl = document.getElementById('js-report-domain');
    var title = document.getElementById('js-report-title');
    var tag = document.getElementById('js-report-tag');
    var date = document.getElementById('js-report-date');
    var summary = document.getElementById('js-report-summary');
    var findings = document.getElementById('js-report-findings');
    var method = document.getElementById('js-report-methodology');

    if (domainEl) domainEl.textContent = domain.domain_title;
    if (title) title.textContent = report.title;
    if (tag) tag.textContent = report.tag || 'Analysis report';
    if (date) date.textContent = formatDate(report.date);
    if (summary) summary.textContent = report.executive_summary || '';
    if (findings) {
      var cleanReportFindings = (report.key_findings || []).filter(function (finding) {
        return !isDraftSlot(finding);
      });
      findings.innerHTML = (cleanReportFindings.length ? cleanReportFindings : [
        'Key findings slot reserved for final report data.'
      ]).map(function (finding) {
        return '<li>' + esc(finding) + '</li>';
      }).join('\n');
    }
    if (method) method.textContent = report.methodology_note || '';
  }

  function bindArchiveFilters() {
    window._archiveFilter = renderArchive;
    ['filter-type', 'filter-status', 'filter-tag', 'filter-sort'].forEach(function (id) {
      var el = document.getElementById(id);
      if (el) el.addEventListener('change', renderArchive);
    });
  }

  async function init() {
    try {
      var results = await Promise.all([
        loadJSON('/data/investigations.json'),
        loadJSON('/data/analysis.json')
      ]);

      state.investigations = Array.isArray(results[0]) ? results[0] : [];
      state.domains = Array.isArray(results[1]) ? results[1] : (results[1].domains || []);

      renderFeatured();
      renderHomeCards();
      renderMetrics();
      renderArchiveHeader();
      populateArchiveTags();
      bindArchiveFilters();
      renderArchive();
      renderAnalysisDomainPage();
      renderInvestigationPage();
      renderAnalysisReportPage();
    } catch (err) {
      console.error('[data-loader] Site data failed to load', err);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
}());
