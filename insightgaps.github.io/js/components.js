/**
 * Component Loader
 * Loads reusable header and footer components
 * Fallback: Works without JavaScript (components must be inline)
 */

(function() {
  'use strict';

  function loadComponent(element, path) {
    if (!element) return;
    
    fetch(path)
      .then(function(response) {
        if (!response.ok) {
          throw new Error('Failed to load component');
        }
        return response.text();
      })
      .then(function(html) {
        element.innerHTML = html;
        
        // Re-initialize navigation after loading header
        if (path.includes('header')) {
          // Trigger navigation script if it exists
          if (typeof setActiveNav === 'function') {
            setActiveNav();
          }
        }
      })
      .catch(function(error) {
        console.warn('Component loader: Could not load', path, error);
        // Graceful degradation - component should be inline as fallback
      });
  }

  // Load components if data attributes are present
  document.addEventListener('DOMContentLoaded', function() {
    const headerPlaceholder = document.querySelector('[data-include="header"]');
    const footerPlaceholder = document.querySelector('[data-include="footer"]');
    
    if (headerPlaceholder) {
      const headerPath = headerPlaceholder.getAttribute('data-path') || '/includes/header.html';
      loadComponent(headerPlaceholder, headerPath);
    }
    
    if (footerPlaceholder) {
      const footerPath = footerPlaceholder.getAttribute('data-path') || '/includes/footer.html';
      loadComponent(footerPlaceholder, footerPath);
    }
  });
})();
