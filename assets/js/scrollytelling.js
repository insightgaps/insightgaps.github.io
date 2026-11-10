/* ==========================================================================
   Insight Gaps — Scrollytelling & Visual Essay Engine
   Reverse-engineered from NYT Snow Fall, Bloomberg Warming, & The Pudding
   ========================================================================== */

(function () {
  'use strict';

  // 1. Reading Progress Bar
  function initProgressBar() {
    const bar = document.querySelector('.visual-progress-bar');
    if (!bar) return;

    window.addEventListener('scroll', function () {
      const winScroll = document.documentElement.scrollTop || document.body.scrollTop;
      const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
      const scrolled = height > 0 ? (winScroll / height) * 100 : 0;
      bar.style.width = Math.min(100, Math.max(0, scrolled)) + '%';
    }, { passive: true });
  }

  // 2. Scroll-Driven IntersectionObserver for Screen Animations
  function initScreenObserver() {
    const screens = document.querySelectorAll('.scrolly-screen');
    if (!screens.length) return;

    if ('IntersectionObserver' in window) {
      const observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add('is-active');
            // Animate SVG elements inside
            const animElements = entry.target.querySelectorAll('.anim-bar, .anim-walker, .anim-node, .anim-fill');
            animElements.forEach(function (el) {
              el.classList.add('animate-play');
            });
          }
        });
      }, {
        root: null,
        threshold: 0.35,
        rootMargin: '0px'
      });

      screens.forEach(function (screen) {
        observer.observe(screen);
      });
    } else {
      // Fallback: activate all screens immediately
      screens.forEach(function (screen) {
        screen.classList.add('is-active');
      });
    }
  }

  // 3. "You Draw It" (NYT) Guess-Then-Reveal Interactions
  function initYouDrawIt() {
    const widgets = document.querySelectorAll('.you-draw-it-box');
    widgets.forEach(function (box) {
      const slider = box.querySelector('.you-draw-it-slider');
      const valDisplay = box.querySelector('.you-draw-it-val');
      const btn = box.querySelector('.you-draw-it-btn');
      const result = box.querySelector('.you-draw-it-result');
      const targetId = box.getAttribute('data-target-screen');
      const screen = targetId ? document.getElementById(targetId) : null;

      if (!slider || !btn || !result) return;

      slider.addEventListener('input', function () {
        const unit = box.getAttribute('data-unit') || '';
        valDisplay.textContent = slider.value + unit;
      });

      btn.addEventListener('click', function () {
        result.style.display = 'inline-block';
        btn.style.display = 'none';
        slider.disabled = true;

        if (screen) {
          const revealTarget = screen.querySelector('.reveal-on-guess');
          if (revealTarget) {
            revealTarget.style.opacity = '1';
            revealTarget.style.transform = 'scale(1)';
            revealTarget.classList.add('is-revealed');
          }
        }
      });
    });
  }

  // Initialize on DOM load
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      initProgressBar();
      initScreenObserver();
      initYouDrawIt();
    });
  } else {
    initProgressBar();
    initScreenObserver();
    initYouDrawIt();
  }
})();
