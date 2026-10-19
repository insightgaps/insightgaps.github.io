/**
 * ============================================================================
 * INSIGHT GAPS BUREAU — UNIVERSAL SCROLLYTELLING ENGINE v1.0
 * Zero external dependencies. Native IntersectionObserver + requestAnimationFrame.
 * Adapters for Leaflet Maps, SVG/Canvas Charts, and Metric Tickers.
 * ============================================================================
 */
(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    define([], factory);
  } else if (typeof module === 'object' && module.exports) {
    module.exports = factory();
  } else {
    root.ScrollyEngine = factory();
  }
}(typeof self !== 'undefined' ? self : this, function () {
  'use strict';

  var reduceMotion = typeof window !== 'undefined' &&
    window.matchMedia &&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /**
   * Core ScrollyEngine constructor
   */
  function ScrollyEngine(options) {
    this.options = Object.assign({
      containerSelector: '[data-scrolly], .scrolly, #scrolly-container',
      stepSelector: '.scrolly__card, .step',
      activeClass: 'scrolly__card--active',
      offset: 0.38,
      progressSelector: '.scrolly-progress, #ig-progress'
    }, options);

    this.containers = Array.from(document.querySelectorAll(this.options.containerSelector));
    this.handlers = { enter: [], exit: [], step: [] };
    this.lastScrollY = typeof window !== 'undefined' ? window.scrollY : 0;
    this.direction = 'down';

    if (this.containers.length) {
      this._initProgress();
      if (!reduceMotion && typeof window !== 'undefined' && ('IntersectionObserver' in window)) {
        this._initStepObserver();
      } else {
        this._initFallback();
      }
    }
  }

  ScrollyEngine.prototype.on = function (event, callback) {
    if (this.handlers[event]) {
      this.handlers[event].push(callback);
    }
    return this;
  };

  ScrollyEngine.prototype._emit = function (event, data) {
    if (this.handlers[event]) {
      for (var i = 0; i < this.handlers[event].length; i++) {
        try {
          this.handlers[event][i](data);
        } catch (err) {
          console.error('[ScrollyEngine Error in ' + event + ']', err);
        }
      }
    }
  };

  ScrollyEngine.prototype._initProgress = function () {
    var progressBar = document.querySelector(this.options.progressSelector);
    if (!progressBar || reduceMotion) return;

    var ticking = false;
    var update = function () {
      var docEl = document.documentElement;
      var total = docEl.scrollHeight - window.innerHeight;
      var ratio = total > 0 ? Math.min(Math.max(window.scrollY / total, 0), 1) : 0;
      progressBar.style.transform = 'scaleX(' + ratio.toFixed(4) + ')';
      ticking = false;
    };

    window.addEventListener('scroll', function () {
      if (!ticking) {
        ticking = true;
        window.requestAnimationFrame(update);
      }
    }, { passive: true });
    update();
  };

  ScrollyEngine.prototype._initStepObserver = function () {
    var self = this;
    var marginPercent = Math.round(this.options.offset * 100);
    var rootMargin = '-' + marginPercent + '% 0px -' + marginPercent + '% 0px';

    window.addEventListener('scroll', function () {
      var currentY = window.scrollY;
      self.direction = currentY >= self.lastScrollY ? 'down' : 'up';
      self.lastScrollY = currentY;
    }, { passive: true });

    this.observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        var el = entry.target;
        var stepIndex = parseInt(el.getAttribute('data-step') || '0', 10);
        var container = el.closest(self.options.containerSelector);
        var scene = el.getAttribute('data-scene') || el.id || '';

        var payload = {
          element: el,
          index: stepIndex,
          scene: scene,
          container: container,
          direction: self.direction,
          data: el.dataset || {}
        };

        if (entry.isIntersecting) {
          var siblings = container ? container.querySelectorAll(self.options.stepSelector) : [];
          siblings.forEach(function (card) {
            card.classList.remove(self.options.activeClass);
            card.classList.remove('active');
            card.removeAttribute('aria-current');
          });

          el.classList.add(self.options.activeClass);
          el.classList.add('active');
          el.setAttribute('aria-current', 'step');
          self._emit('enter', payload);
          self._emit('step', payload);
        } else {
          if (el.classList.contains(self.options.activeClass)) {
            el.classList.remove(self.options.activeClass);
            el.removeAttribute('aria-current');
            self._emit('exit', payload);
          }
        }
      });
    }, { rootMargin: rootMargin, threshold: 0 });

    this.containers.forEach(function (container) {
      var steps = container.querySelectorAll(self.options.stepSelector);
      steps.forEach(function (step) { self.observer.observe(step); });
      if (steps.length > 0) {
        steps[0].classList.add(self.options.activeClass);
        steps[0].setAttribute('aria-current', 'step');
      }
    });
  };

  ScrollyEngine.prototype._initFallback = function () {
    this.containers.forEach(function (container) {
      var steps = container.querySelectorAll('.scrolly__card, .step');
      steps.forEach(function (s) {
        s.style.opacity = '1';
        s.style.transform = 'none';
      });
    });
  };

  /**
   * Leaflet Map Adapter
   */
  function LeafletScrollyAdapter(mapInstance, options) {
    this.map = mapInstance;
    this.options = Object.assign({
      defaultDuration: 1.5,
      clusterGroup: null,
      markerMap: new Map(),
      onSceneChange: null
    }, options);

    this._bindMobileProtection();
  }

  LeafletScrollyAdapter.prototype._bindMobileProtection = function () {
    var self = this;
    if (typeof window === 'undefined' || !this.map) return;

    var checkMobile = function () {
      if (window.innerWidth <= 768) {
        if (self.map.dragging) self.map.dragging.disable();
        if (self.map.touchZoom) self.map.touchZoom.disable();
        if (self.map.scrollWheelZoom) self.map.scrollWheelZoom.disable();
      } else {
        if (self.map.dragging) self.map.dragging.enable();
        if (self.map.touchZoom) self.map.touchZoom.enable();
        if (self.map.scrollWheelZoom) self.map.scrollWheelZoom.enable();
      }
      self.map.invalidateSize();
    };

    window.addEventListener('resize', checkMobile, { passive: true });
    window.addEventListener('orientationchange', checkMobile, { passive: true });
    checkMobile();
  };

  LeafletScrollyAdapter.prototype.onStepEnter = function (step) {
    if (!this.map) return;
    var d = step.data || {};
    this.map.invalidateSize();

    if (d.bounds) {
      try {
        var b = JSON.parse(d.bounds);
        this.map.flyToBounds(b, { padding: [30, 30], maxZoom: 16, duration: this.options.defaultDuration });
      } catch (e) {}
    } else if (d.flyto) {
      try {
        var coords = JSON.parse(d.flyto);
        this.map.flyTo([coords[0], coords[1]], coords[2] || 15, { duration: this.options.defaultDuration });
      } catch (e) {}
    }

    if (d.highlight && this.options.clusterGroup) {
      var marker = this.options.markerMap.get(d.highlight);
      if (marker) {
        this.options.clusterGroup.zoomToShowLayer(marker, function () {
          marker.openPopup();
        });
      }
    }

    if (typeof this.options.onSceneChange === 'function') {
      this.options.onSceneChange(step.scene, step);
    }
  };

  /**
   * Counter Scrolly Adapter
   */
  function CounterScrollyAdapter(options) {
    this.options = Object.assign({
      formatter: new Intl.NumberFormat('en-US'),
      duration: 1100
    }, options);
    this.activeTweens = typeof WeakMap !== 'undefined' ? new WeakMap() : null;
  }

  CounterScrollyAdapter.prototype.animate = function (element, targetValue, suffix) {
    suffix = suffix || '';
    var self = this;
    var currentText = (element.textContent || '').replace(/[^0-9.-]/g, '');
    var startValue = parseFloat(currentText) || 0;
    var startTime = null;

    var frame = function (now) {
      if (!startTime) startTime = now;
      var progress = Math.min((now - startTime) / self.options.duration, 1);
      var ease = progress === 1 ? 1 : 1 - Math.pow(2, -10 * progress);
      var current = startValue + (targetValue - startValue) * ease;

      element.textContent = self.options.formatter.format(Math.round(current)) + suffix;

      if (progress < 1) {
        var id = window.requestAnimationFrame(frame);
        if (self.activeTweens) self.activeTweens.set(element, id);
      } else {
        element.textContent = self.options.formatter.format(targetValue) + suffix;
      }
    };

    if (this.activeTweens && this.activeTweens.has(element)) {
      window.cancelAnimationFrame(this.activeTweens.get(element));
    }
    window.requestAnimationFrame(frame);
  };

  CounterScrollyAdapter.prototype.onStepEnter = function (step) {
    if (!step || !step.element) return;
    var counterEl = step.element.querySelector('[data-counter]');
    if (!counterEl) return;

    var target = parseFloat(counterEl.getAttribute('data-counter'));
    var suffix = step.data ? (step.data.metricSuffix || '') : '';
    if (!isNaN(target)) {
      this.animate(counterEl, target, suffix);
    }
  };

  ScrollyEngine.LeafletAdapter = LeafletScrollyAdapter;
  ScrollyEngine.CounterAdapter = CounterScrollyAdapter;

  return ScrollyEngine;
}));
