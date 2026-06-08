(function () {
  'use strict';

  const VIEWS = {
    pulse:          { title: 'Morning Pulse',    file: 'views/pulse.html' },
    financial:      { title: 'Financials',        file: 'views/financial.html' },
    leakage:        { title: 'Leakage Breakdown', file: 'views/leakage.html' },
    workorders:     { title: 'Work Orders',       file: 'views/workorders.html' },
    contractors:    { title: 'Contractors',       file: 'views/contractors.html' },
    communications: { title: 'Communications',    file: 'views/communications.html' },
    zip:            { title: 'ZIP Intelligence',  file: 'views/zip.html' },
    photoqc:        { title: 'Photo QC',          file: 'views/photoqc.html' },
    bidgenerator:   { title: 'Bid Generator',     file: 'views/bidgenerator.html' },
  };

  // Global filter state
  window.EPCS_FILTERS = { month: 'all', client: 'all', contractor: 'all' };

  // View loader
  function loadView(viewKey) {
    var container = document.getElementById('view-container');
    container.innerHTML = '<div style="padding:40px;text-align:center;color:#8C8985;font-family:Space Mono,monospace;font-size:12px;">Loading...</div>';
    
    fetch(VIEWS[viewKey].file + '?t=' + Date.now())
      .then(function (r) {
        if (!r.ok) throw new Error('Network error');
        return r.text();
      })
      .then(function (html) {
        var parser = new DOMParser();
        var doc = parser.parseFromString(html, 'text/html');
        var body = doc.querySelector('.os-view-body');
        if (body) {
          container.innerHTML = body.innerHTML;
        } else {
          container.innerHTML = html; // fallback
        }
        
        // Re-execute scripts in the loaded content
        container.querySelectorAll('script').forEach(function (oldScript) {
          var newScript = document.createElement('script');
          newScript.textContent = oldScript.textContent;
          oldScript.parentNode.replaceChild(newScript, oldScript);
        });
        
        // Trigger initial render with current filters
        window.dispatchEvent(new CustomEvent('epcs:view-loaded', { detail: { view: viewKey } }));
      })
      .catch(function (err) {
        container.innerHTML = '<div style="padding:40px;text-align:center;color:#DC2626;font-family:Space Mono,monospace;font-size:12px;">Failed to load view.</div>';
      });
  }

  // Navigation handlers
  document.querySelectorAll('.os-nav__item').forEach(function (item) {
    item.addEventListener('click', function (e) {
      e.preventDefault();
      var viewKey = this.dataset.view;
      loadView(viewKey);
      document.querySelectorAll('.os-nav__item').forEach(function (i) { i.classList.remove('active'); });
      this.classList.add('active');
      document.getElementById('current-view-title').textContent = VIEWS[viewKey].title;
    });
  });

  // Filter controls
  ['filter-month', 'filter-client', 'filter-contractor'].forEach(function (id) {
    var el = document.getElementById(id);
    if (!el) return;
    el.addEventListener('change', function () {
      window.EPCS_FILTERS[id.replace('filter-', '')] = this.value;
      window.dispatchEvent(new CustomEvent('epcs:filter-change', { detail: window.EPCS_FILTERS }));
    });
  });

  document.getElementById('filter-reset').addEventListener('click', function () {
    window.EPCS_FILTERS = { month: 'all', client: 'all', contractor: 'all' };
    
    var m = document.getElementById('filter-month');
    var c = document.getElementById('filter-client');
    var ct = document.getElementById('filter-contractor');
    
    if (m) m.value = 'all';
    if (c) c.value = 'all';
    if (ct) ct.value = 'all';
    
    window.dispatchEvent(new CustomEvent('epcs:filter-change', { detail: window.EPCS_FILTERS }));
  });

  // Initialize function (called once index.html and data are loaded)
  window.initEPCSOS = function () {
    if (typeof window.EPCS_DATA === 'undefined') {
      console.error('EPCS_DATA not loaded');
      return;
    }
    
    var data = window.EPCS_DATA;
    
    // 1. Populate contractor filter select box
    var contractorSelect = document.getElementById('filter-contractor');
    if (contractorSelect) {
      contractorSelect.innerHTML = '<option value="all">All Contractors</option>';
      data.contractors.forEach(function (c) {
        var opt = document.createElement('option');
        opt.value = c.name;
        opt.textContent = c.name;
        contractorSelect.appendChild(opt);
      });
    }
    
    // 2. Set badge counts
    var badgeWOs = document.getElementById('badge-workorders');
    if (badgeWOs) {
      badgeWOs.textContent = data.meta.total_wos;
    }
    var badgeComms = document.getElementById('badge-comms');
    if (badgeComms) {
      badgeComms.textContent = data.meta.total_comms;
    }
    var badgeQC = document.getElementById('badge-qc');
    if (badgeQC) {
      badgeQC.textContent = '3';
    }
    
    // 3. Load default view (pulse)
    loadView('pulse');
  };

  // Wait for DOM to execute initialization if needed, or index.html can call it
  document.addEventListener('DOMContentLoaded', function () {
    if (window.EPCS_DATA) {
      window.initEPCSOS();
    }
  });

})();
