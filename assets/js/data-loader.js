/**
 * data-loader.js — Insight Gaps Bureau
 * Reads data/investigations.json and data/analysis.json
 * Renders investigation cards and analysis domain cards on homepage and archive.
 * Wires archive filter dropdowns and animates metrics counter blocks.
 */

(function () {
  'use strict';

  /* ─────────────────────────────────────────────
     UTILITY: fetch JSON from an absolute path
     ───────────────────────────────────────────── */
  async function fetchJSON(path) {
    try {
      const response = await fetch(path);
      if (!response.ok) {
        console.warn('[data-loader] Failed to load ' + path + ' — HTTP ' + response.status);
        return null;
      }
      return await response.json();
    } catch (err) {
      console.warn('[data-loader] Could not parse ' + path, err);
      return null;
    }
  }

  /* ─────────────────────────────────────────────
     UTILITY: resolve root-relative data paths
     ───────────────────────────────────────────── */
  function resolveDataPath(file) {
    return '/data/' + file;
  }

  /* ─────────────────────────────────────────────
     UTILITY: resolve root-relative hrefs for links
     Counts non-empty path segments to determine depth.
     Adjusts for filename segments.
     ───────────────────────────────────────────── */
  function rootRelative(path) {
    const segments = window.location.pathname
      .split('/')
      .filter(function (s) { return s.length > 0; });
    let depth = segments.length;
    if (depth > 0 && (segments[depth - 1].includes('.') || segments[depth - 1] === 'index.html')) {
      depth--;
    }
    if (depth === 0) return path.replace(/^\//, '');
    const prefix = Array(depth).fill('..').join('/') + '/';
    return prefix + path.replace(/^\//, '');
  }

  /* ─────────────────────────────────────────────
     UTILITY: status badge HTML
     ───────────────────────────────────────────── */
  function statusBadge(status) {
    var labels = {
      'published':   'Published',
      'corrected':   'Corrected',
      'developing':  'Developing',
      'terminated':  'Terminated',
      'archived':    'Archived'
    };
    var label = labels[status] || status;
    return '<span class="status-badge status-badge--' + status + '">' + label + '</span>';
  }

  /* ─────────────────────────────────────────────
     UTILITY: format ISO date string as readable date
     ───────────────────────────────────────────── */
  function formatDate(dateStr) {
    if (!dateStr) return '';
    try {
      var d = new Date(dateStr);
      return d.toLocaleDateString('en-GB', {
        day: 'numeric',
        month: 'long',
        year: 'numeric'
      });
    } catch (e) {
      return dateStr;
    }
  }

  /* ─────────────────────────────────────────────
     UTILITY: escape HTML to prevent injection
     ───────────────────────────────────────────── */
  function esc(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  /* ─────────────────────────────────────────────
     COMPONENT: Investigation Card
     Matches templates/archive-card.html option A.
     ───────────────────────────────────────────── */
  function buildInvestigationCard(inv) {
    var isLinkable = inv.status === 'published' || inv.status === 'corrected' || inv.status === 'archived';
    var invPath = isLinkable ? rootRelative('/content/investigations/' + esc(inv.slug) + '/') : '#';

    // Tag (first tag only)
    var tagHtml = '';
    if (Array.isArray(inv.topic_tags) && inv.topic_tags.length > 0) {
      tagHtml = '<span class="inv-card__tag">' + esc(inv.topic_tags[0]) + '</span>';
    }

    // Title — linked only if linkable
    var titleHtml = isLinkable
      ? '<a href="' + invPath + '">' + esc(inv.title) + '</a>'
      : esc(inv.title);

    // Correction dot — if applicable
    var correctionDot = inv.has_correction
      ? '<span class="inv-card__correction-dot" aria-hidden="true"></span>'
      : '';

    return [
      '<article class="inv-card" data-status="' + esc(inv.status) + '">',
      '  <div class="inv-card__header">',
      '    ' + statusBadge(inv.status),
      '    ' + tagHtml,
      '  </div>',
      '  <h3 class="inv-card__title">' + titleHtml + '</h3>',
      '  <p class="inv-card__summary">' + esc(inv.summary) + '</p>',
      '  <div class="inv-card__footer">',
      '    <span class="inv-card__id">',
      '      ' + esc(inv.id),
      '      ' + correctionDot,
      '    </span>',
      '    <time class="inv-card__date" datetime="' + esc(inv.date_published) + '">' + formatDate(inv.date_published) + '</time>',
      '  </div>',
      isLinkable ? '  <a class="inv-card__link" href="' + invPath + '"><span class="sr-only">Read ' + esc(inv.title) + '</span></a>' : '',
      '</article>'
    ].filter(function (line) { return line.trim().length > 0; }).join('\n');
  }

  /* ─────────────────────────────────────────────
     COMPONENT: Analysis Domain Card
     Matches templates/archive-card.html option B.
     ───────────────────────────────────────────── */
  function buildAnalysisCard(domain) {
    var domainPath = rootRelative('/analysis/' + esc(domain.domain_slug) + '/');
    var reportCount = Number(domain.report_count) || 0;
    var countLabel = reportCount === 1 ? '1 report' : reportCount + ' reports';

    return [
      '<article class="analysis-card">',
      '  <h3 class="analysis-card__title"><a href="' + domainPath + '">' + esc(domain.domain_title) + '</a></h3>',
      '  <p class="analysis-card__description">' + esc(domain.description) + '</p>',
      '  <div class="analysis-card__footer">',
      '    <span class="analysis-card__count">' + countLabel + '</span>',
      '    <time class="analysis-card__date">Last updated ' + formatDate(domain.last_updated) + '</time>',
      '  </div>',
      '  <a class="analysis-card__link" href="' + domainPath + '"><span class="sr-only">Read ' + esc(domain.domain_title) + '</span></a>',
      '</article>'
    ].join('\n');
  }

  /* ─────────────────────────────────────────────
     METRICS COUNTER: animate count-up on scroll
     ───────────────────────────────────────────── */
  function initCounters() {
    var counters = document.querySelectorAll('[data-count-target]');
    if (!counters.length) return;

    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        observer.unobserve(entry.target);

        var el = entry.target;
        var target = parseInt(el.getAttribute('data-count-target'), 10);
        if (isNaN(target)) return;

        var duration = 1200; // ms
        var start = performance.now();
        var initial = 0;

        function tick(now) {
          var elapsed = now - start;
          var progress = Math.min(elapsed / duration, 1);
          // Ease out cubic
          var eased = 1 - Math.pow(1 - progress, 3);
          var current = Math.round(initial + (target - initial) * eased);

          el.textContent = target >= 1000
            ? current.toLocaleString('en-GB')
            : current;

          if (progress < 1) {
            requestAnimationFrame(tick);
          } else {
            el.textContent = target >= 1000
              ? target.toLocaleString('en-GB')
              : target;
          }
        }

        requestAnimationFrame(tick);
      });
    }, { threshold: 0.3 });

    counters.forEach(function (el) { observer.observe(el); });
  }

  /* ─────────────────────────────────────────────
     MAIN: load data and orchestrate renders
     ───────────────────────────────────────────── */
  async function init() {
    var results = await Promise.all([
      fetchJSON(resolveDataPath('investigations.json')),
      fetchJSON(resolveDataPath('analysis.json'))
    ]);

    var investigations = results[0];
    var analysisData = results[1];
    var analysisDomains = analysisData ? (analysisData.domains || []) : [];

    /* ── HOMEPAGE LATEST INVESTIGATIONS ── */
    var homepageInvGrid = document.getElementById('js-investigation-cards');
    if (homepageInvGrid && Array.isArray(investigations)) {
      var latestInvs = investigations
        .filter(function (inv) { return inv.status === 'published' || inv.status === 'corrected' || inv.status === 'archived'; })
        .sort(function (a, b) { return new Date(b.date_published) - new Date(a.date_published); })
        .slice(0, 3);

      if (latestInvs.length === 0) {
        homepageInvGrid.innerHTML = '<p class="empty-state">No investigations published yet.</p>';
      } else {
        homepageInvGrid.innerHTML = latestInvs.map(buildInvestigationCard).join('\n');
      }
    }

    /* ── HOMEPAGE ANALYSIS DOMAINS ── */
    var homepageAnaGrid = document.getElementById('js-analysis-cards');
    if (homepageAnaGrid && Array.isArray(analysisDomains)) {
      if (analysisDomains.length === 0) {
        homepageAnaGrid.innerHTML = '<p class="empty-state">No analysis domains yet.</p>';
      } else {
        homepageAnaGrid.innerHTML = analysisDomains.slice(0, 3).map(buildAnalysisCard).join('\n');
      }
    }

    /* ── ARCHIVE PAGE HYDRATION & FILTERING ── */
    var archiveResultsEl = document.getElementById('js-archive-results');
    if (archiveResultsEl) {
      var allItems = [];

      if (Array.isArray(investigations)) {
        investigations.forEach(function (inv) {
          allItems.push({
            type: 'investigation',
            status: inv.status,
            tags: inv.topic_tags || [],
            date: inv.date_published,
            html: buildInvestigationCard(inv),
            raw: inv
          });
        });
      }

      if (Array.isArray(analysisDomains)) {
        analysisDomains.forEach(function (domain) {
          var tags = [];
          if (Array.isArray(domain.reports)) {
            domain.reports.forEach(function (rep) {
              if (rep.tag && !tags.includes(rep.tag)) {
                tags.push(rep.tag);
              }
            });
          }
          allItems.push({
            type: 'analysis',
            status: 'published', // Domain index pages are always active/published
            tags: tags,
            date: domain.last_updated,
            html: buildAnalysisCard(domain),
            raw: domain
          });
        });
      }

      // Populate unique tags in dropdown
      var uniqueTags = [];
      allItems.forEach(function (item) {
        item.tags.forEach(function (t) {
          if (!uniqueTags.includes(t)) {
            uniqueTags.push(t);
          }
        });
      });
      uniqueTags.sort();

      var filterTagEl = document.getElementById('filter-tag');
      if (filterTagEl) {
        filterTagEl.innerHTML = '<option value="all">All topics</option>';
        uniqueTags.forEach(function (tag) {
          var opt = document.createElement('option');
          opt.value = tag;
          opt.textContent = tag;
          filterTagEl.appendChild(opt);
        });
      }

      // Update subtitle total counts
      var subtitleEl = document.getElementById('js-archive-subtitle');
      if (subtitleEl) {
        var invTotal = allItems.filter(function (i) { return i.type === 'investigation'; }).length;
        var anaTotal = allItems.filter(function (i) { return i.type === 'analysis'; }).length;
        subtitleEl.textContent = invTotal + ' investigations · ' + anaTotal + ' analysis domains';
      }

      // Define global archive filter logic
      window._archiveFilter = function () {
        var typeVal = document.getElementById('filter-type').value;
        var statusVal = document.getElementById('filter-status').value;
        var tagVal = document.getElementById('filter-tag').value;
        var sortVal = document.getElementById('filter-sort').value;

        var filtered = allItems.filter(function (item) {
          if (typeVal !== 'all' && item.type !== typeVal) return false;
          if (statusVal !== 'all' && item.status !== statusVal) return false;
          if (tagVal !== 'all' && !item.tags.includes(tagVal)) return false;
          return true;
        });

        // Sort
        filtered.sort(function (a, b) {
          var dA = new Date(a.date);
          var dB = new Date(b.date);
          return sortVal === 'newest' ? dB - dA : dA - dB;
        });

        // Render
        var loadingEl = document.getElementById('js-archive-loading');
        if (loadingEl) loadingEl.style.display = 'none';

        var emptyStateEl = document.getElementById('js-archive-empty');
        if (filtered.length === 0) {
          archiveResultsEl.innerHTML = '';
          if (emptyStateEl) emptyStateEl.removeAttribute('hidden');
        } else {
          archiveResultsEl.innerHTML = filtered.map(function (item) { return item.html; }).join('\n');
          if (emptyStateEl) emptyStateEl.setAttribute('hidden', 'true');
        }

        // Update results count
        var resultsCountEl = document.getElementById('js-results-count');
        if (resultsCountEl) {
          var invCount = filtered.filter(function (i) { return i.type === 'investigation'; }).length;
          var anaCount = filtered.filter(function (i) { return i.type === 'analysis'; }).length;
          var parts = [];
          if (invCount > 0 || anaCount === 0) {
            parts.push(invCount + (invCount === 1 ? ' investigation' : ' investigations'));
          }
          if (anaCount > 0) {
            parts.push(anaCount + (anaCount === 1 ? ' analysis domain' : ' analysis domains'));
          }
          resultsCountEl.textContent = parts.join(' · ') + ' shown';
        }
      };

      // Run initial filter to render cards on load
      window._archiveFilter();
    }

    /* ── METRICS COUNTERS (on homepage or any page) ── */
    initCounters();
  }

  /* ── RUN ON READY ── */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
