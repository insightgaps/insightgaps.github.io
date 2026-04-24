/* Insight Gaps — Theme Toggle v2 */
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

  function updateButtons(isDark) {
    document.querySelectorAll('.theme-toggle-btn').forEach(function(btn) {
      btn.setAttribute('aria-label', isDark ? 'Switch to white theme' : 'Switch to dark theme');
      btn.setAttribute('data-active', isDark ? 'dark' : 'light');
      var icon = btn.querySelector('.theme-icon');
      var label = btn.querySelector('.theme-label');
      if (icon) icon.textContent = isDark ? '☀' : '◗';
      if (label) label.textContent = isDark ? 'Light' : 'Dark';
    });
  }

  function toggle() {
    var current = document.documentElement.getAttribute('data-theme');
    var next = (current === DARK) ? '' : DARK;
    try { localStorage.setItem(KEY, next); } catch(e) {}
    apply(next);
    updateButtons(next === DARK);
  }

  window.igToggleTheme = toggle;

  document.addEventListener('DOMContentLoaded', function () {
    var isDark = document.documentElement.getAttribute('data-theme') === DARK;
    updateButtons(isDark);
    document.querySelectorAll('.theme-toggle-btn').forEach(function(btn) {
      btn.addEventListener('click', toggle);
    });
  });
})();
