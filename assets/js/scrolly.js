/* Scrollytelling homepage hero — OFFLINE PROTOTYPE (uncommitted).
   Vanilla IntersectionObserver, no dependencies. Progressive enhancement:
   all numbers/text pre-rendered, so no-JS and reduced-motion show final state. */
(function () {
  'use strict';

  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // Reading progress bar (skip entirely under reduced motion).
  var progress = document.querySelector('.scrolly-progress');
  if (progress && !reduceMotion) {
    var onScroll = function () {
      var max = document.documentElement.scrollHeight - window.innerHeight;
      var ratio = max > 0 ? window.scrollY / max : 0;
      progress.style.transform = 'scaleX(' + ratio.toFixed(4) + ')';
    };
    document.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  } else if (progress) {
    progress.style.display = 'none';
  }

  if (reduceMotion || !('IntersectionObserver' in window)) { return; }

  // Scrolly steps: one step = one claim; figure states swap per step.
  var scrolly = document.querySelector('[data-scrolly]');
  if (scrolly) {
    var steps = Array.prototype.slice.call(scrolly.querySelectorAll('.scrolly__step'));
    var states = Array.prototype.slice.call(scrolly.querySelectorAll('.scrolly__figure-state'));
    var setActive = function (index) {
      steps.forEach(function (el, i) {
        el.classList.toggle('scrolly__step--active', i === index);
      });
      states.forEach(function (el, i) {
        el.classList.toggle('scrolly__figure-state--active', i === index);
      });
    };
    var stepObserver = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          setActive(steps.indexOf(entry.target));
        }
      });
    }, { rootMargin: '-45% 0px -45% 0px' });
    steps.forEach(function (el) { stepObserver.observe(el); });
    setActive(0);
  }

  // Animated counters: parse pre-rendered final value, count up once.
  var counters = document.querySelectorAll('.metrics-block__number--count');
  var countUp = function (el) {
    var target = parseInt(el.textContent.replace(/[^0-9]/g, ''), 10);
    if (isNaN(target)) { return; }
    var start = null;
    var duration = 900;
    var frame = function (now) {
      if (!start) { start = now; }
      var p = Math.min((now - start) / duration, 1);
      el.textContent = String(Math.round(target * (0.2 + 0.8 * p)));
      if (p < 1) { window.requestAnimationFrame(frame); }
      else { el.textContent = String(target); }
    };
    window.requestAnimationFrame(frame);
  };
  if (counters.length) {
    var counterObserver = new IntersectionObserver(function (entries, obs) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          countUp(entry.target);
          obs.unobserve(entry.target);
        }
      });
    }, { threshold: 0.5 });
    counters.forEach(function (el) { counterObserver.observe(el); });
  }

  // Generic reveal for cards/sections below hero.
  var revealEls = document.querySelectorAll('[data-reveal]');
  if (revealEls.length) {
    var revealObserver = new IntersectionObserver(function (entries, obs) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.setAttribute('data-reveal', 'in');
          obs.unobserve(entry.target);
        }
      });
    }, { threshold: 0.15 });
    revealEls.forEach(function (el) { revealObserver.observe(el); });
  }
}());
