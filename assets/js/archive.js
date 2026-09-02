/* Archive filtering — progressive enhancement only.
   The default archive view is pre-rendered at build time; this script
   re-renders the grid client-side from embedded JSON when filters change.
   No network requests: a failure here cannot blank the archive. */
(function () {
  'use strict';

  var dataEl = document.getElementById('archive-data');
  var grid = document.getElementById('js-archive-results');
  if (!dataEl || !grid) return;

  var items;
  try {
    items = JSON.parse(dataEl.textContent);
  } catch (err) {
    return; // keep the pre-rendered grid untouched
  }

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
    return date.toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
  }

  function statusBadge(status) {
    var clean = esc(status || 'archived');
    return '<span class="status-badge status-badge--' + clean + '">' +
      clean.replace(/-/g, ' ').toUpperCase() + '</span>';
  }

  function invCard(inv) {
    var tags = inv.topic_tags || [];
    var img = inv.og_image_path
      ? '<div class="inv-card__image-wrap"><img class="inv-card__image" src="' + esc(inv.og_image_path) + '" alt="' + esc(inv.title) + '"></div>'
      : '';
    var correction = inv.has_correction
      ? '<span class="inv-card__correction-dot" aria-label="Correction issued"></span>'
      : '';
    return '<article class="inv-card" data-type="investigation" data-status="' + esc(inv.status) + '">' +
      img +
      '<div class="inv-card__header"><span class="inv-card__tag">' + esc(tags[0] || 'Investigation') + '</span>' + statusBadge(inv.status) + '</div>' +
      '<h3 class="inv-card__title">' + esc(inv.title) + '</h3>' +
      '<p class="inv-card__summary">' + esc(inv.summary || inv.dek) + '</p>' +
      '<footer class="inv-card__footer"><span class="inv-card__id">' + correction + esc(inv.id) + '</span>' +
      '<time class="inv-card__date" datetime="' + esc(inv.date_published) + '">' + esc(formatDate(inv.date_published)) + '</time></footer>' +
      '<a class="inv-card__link" href="' + esc(inv.url) + '" aria-label="Open ' + esc(inv.title) + '"></a>' +
      '</article>';
  }

  function analysisCard(domain) {
    var count = Number(domain.report_count || 0);
    var img = domain.og_image_path
      ? '<div class="analysis-card__image-wrap"><img class="analysis-card__image" src="' + esc(domain.og_image_path) + '" alt="' + esc(domain.domain_title) + '"></div>'
      : '';
    return '<article class="analysis-card" data-type="analysis" data-status="published">' +
      img +
      '<div class="analysis-card__content"><h3 class="analysis-card__title">' + esc(domain.domain_title) + '</h3>' +
      '<p class="analysis-card__description">' + esc(domain.description) + '</p></div>' +
      '<footer class="analysis-card__footer"><span class="analysis-card__count">' + count + ' report' + (count === 1 ? '' : 's') + '</span>' +
      '<time class="analysis-card__date" datetime="' + esc(domain.last_updated) + '">' + esc(formatDate(domain.last_updated)) + '</time></footer>' +
      '<a class="analysis-card__link" href="/analysis/' + esc(domain.domain_slug) + '/" aria-label="Open ' + esc(domain.domain_title) + '"></a>' +
      '</article>';
  }

  function render() {
    var type = (document.getElementById('filter-type') || {}).value || 'all';
    var status = (document.getElementById('filter-status') || {}).value || 'all';
    var tag = (document.getElementById('filter-tag') || {}).value || 'all';
    var sort = (document.getElementById('filter-sort') || {}).value || 'newest';

    var shown = items.filter(function (item) {
      var typeMatch = type === 'all' || item.type === type;
      var statusMatch = status === 'all' || item.status === status;
      var tagMatch = tag === 'all' || item.tags.indexOf(tag) !== -1;
      return typeMatch && statusMatch && tagMatch;
    });

    shown.sort(function (a, b) {
      var diff = new Date(b.date || 0) - new Date(a.date || 0);
      return sort === 'oldest' ? diff * -1 : diff;
    });

    grid.innerHTML = shown.map(function (item) {
      return item.type === 'investigation' ? invCard(item.data) : analysisCard(item.data);
    }).join('\n');

    var count = document.getElementById('js-results-count');
    if (count) count.textContent = shown.length + ' result' + (shown.length === 1 ? '' : 's') + ' shown';

    var empty = document.getElementById('js-archive-empty');
    if (empty) empty.hidden = shown.length !== 0;
  }

  ['filter-type', 'filter-status', 'filter-tag', 'filter-sort'].forEach(function (id) {
    var el = document.getElementById(id);
    if (el) el.addEventListener('change', render);
  });

  var reset = document.getElementById('js-archive-reset');
  if (reset) {
    reset.addEventListener('click', function () {
      ['filter-type', 'filter-status', 'filter-tag', 'filter-sort'].forEach(function (id) {
        var el = document.getElementById(id);
        if (el) el.value = 'all';
      });
      render();
    });
  }
}());
