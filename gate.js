/**
 * gate.js — Insight Gaps Bureau & Property Preservation Class Gatekeeper
 * 
 * Teacher Passcode: 1972
 * Role: Restricts access to student learning content, module pages, rubrics, 
 *       and exercise files. Public showcase cards remain teaser-only.
 * Storage: sessionStorage key 'ig_class_gate_auth'
 */

(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    define([], factory);
  } else if (typeof module === 'object' && module.exports) {
    module.exports = factory();
  } else {
    root.ClassGate = factory();
  }
}(typeof self !== 'undefined' ? self : this, function () {
  'use strict';

  var GATE_CODE = '1972';
  var STORAGE_KEY = 'ig_class_gate_auth';

  var ClassGate = {
    code: GATE_CODE,

    /**
     * Verify provided code against the teacher's secret
     * @param {string} inputCode 
     * @returns {boolean}
     */
    verify: function (inputCode) {
      if (!inputCode) return false;
      var clean = String(inputCode).trim();
      if (clean === GATE_CODE) {
        try {
          sessionStorage.setItem(STORAGE_KEY, GATE_CODE);
        } catch (e) {
          // Fallback if sessionStorage is disabled/restricted
          window._ig_class_gate_auth = true;
        }
        return true;
      }
      return false;
    },

    /**
     * Check if current session is authorized
     * @returns {boolean}
     */
    isAuthorized: function () {
      try {
        return sessionStorage.getItem(STORAGE_KEY) === GATE_CODE || window._ig_class_gate_auth === true;
      } catch (e) {
        return window._ig_class_gate_auth === true;
      }
    },

    /**
     * Clear authorization and lock the gate
     */
    lock: function () {
      try {
        sessionStorage.removeItem(STORAGE_KEY);
      } catch (e) {}
      window._ig_class_gate_auth = false;
      var lockedViews = document.querySelectorAll('[data-gate-locked]');
      var unlockedViews = document.querySelectorAll('[data-gate-unlocked]');
      lockedViews.forEach(function (el) { el.style.display = ''; });
      unlockedViews.forEach(function (el) { el.style.display = 'none'; });
    },

    /**
     * Initialize gate listener on a container
     * @param {Object} options 
     */
    init: function (options) {
      options = options || {};
      var inputEl = document.getElementById(options.inputId || 'gate-passcode-input');
      var submitEl = document.getElementById(options.submitId || 'gate-submit-btn');
      var feedbackEl = document.getElementById(options.feedbackId || 'gate-feedback-msg');
      var targetUrl = options.targetUrl || 'class_hub.html';
      var autoReveal = options.autoReveal !== false;

      function handleAttempt() {
        if (!inputEl) return;
        var val = inputEl.value;
        if (ClassGate.verify(val)) {
          if (feedbackEl) {
            feedbackEl.className = 'gate-feedback gate-feedback--success';
            feedbackEl.textContent = 'Passcode accepted. Loading Class Hub...';
          }
          inputEl.blur();

          if (options.onSuccess) {
            options.onSuccess();
          } else if (autoReveal && document.querySelector('[data-gate-unlocked]')) {
            ClassGate.reveal();
          } else {
            setTimeout(function () {
              window.location.href = targetUrl;
            }, 300);
          }
        } else {
          if (feedbackEl) {
            feedbackEl.className = 'gate-feedback gate-feedback--error';
            feedbackEl.textContent = 'Invalid cohort passcode. Contact the instructor.';
          }
          if (inputEl) {
            inputEl.classList.add('gate-input--shake');
            setTimeout(function () {
              inputEl.classList.remove('gate-input--shake');
            }, 500);
            inputEl.focus();
            inputEl.select();
          }
          if (options.onError) {
            options.onError();
          }
        }
      }

      if (submitEl) {
        submitEl.addEventListener('click', function (e) {
          e.preventDefault();
          handleAttempt();
        });
      }

      if (inputEl) {
        inputEl.addEventListener('keydown', function (e) {
          if (e.key === 'Enter') {
            e.preventDefault();
            handleAttempt();
          }
        });
      }

      // Check current state on load
      if (ClassGate.isAuthorized()) {
        if (autoReveal && document.querySelector('[data-gate-unlocked]')) {
          ClassGate.reveal();
        }
      }
    },

    /**
     * Unlocks the view on the current page if gated sections exist
     */
    reveal: function () {
      var lockedViews = document.querySelectorAll('[data-gate-locked]');
      var unlockedViews = document.querySelectorAll('[data-gate-unlocked]');
      lockedViews.forEach(function (el) { el.style.display = 'none'; });
      unlockedViews.forEach(function (el) { el.style.display = ''; });
    }
  };

  return ClassGate;
}));
