/* Insight Gaps — Theme Toggle
   White = default. Dark = opt-in. Persisted via localStorage. */
(function () {
  var DARK = 'dark';
  var KEY  = 'ig-theme';

  function apply(theme) {
    if (theme === DARK) {
      document.documentElement.setAttribute('data-theme', DARK);
    } else {
      document.documentElement.removeAttribute('data-theme');
    }
  }

  /* Apply immediately to avoid flash */
  var stored = '';
  try { stored = localStorage.getItem(KEY) || ''; } catch(e) {}
  apply(stored);

  function toggle() {
    var current = document.documentElement.getAttribute('data-theme');
    var next = (current === DARK) ? '' : DARK;
    try { localStorage.setItem(KEY, next); } catch(e) {}
    apply(next);
    /* Update all toggle buttons on page */
    document.querySelectorAll('.theme-toggle-btn').forEach(function(btn) {
      btn.setAttribute('aria-label', next === DARK ? 'Switch to white theme' : 'Switch to dark theme');
      btn.querySelector('.theme-icon').textContent = next === DARK ? '◑' : '●';
    });
  }

  /* Expose globally so inline onclick can call it */
  window.igToggleTheme = toggle;

  /* Init button state on DOMContentLoaded */
  document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.theme-toggle-btn').forEach(function(btn) {
      var isDark = document.documentElement.getAttribute('data-theme') === DARK;
      btn.setAttribute('aria-label', isDark ? 'Switch to white theme' : 'Switch to dark theme');
      btn.querySelector('.theme-icon').textContent = isDark ? '◑' : '●';
      btn.addEventListener('click', toggle);
    });
  });
})();
