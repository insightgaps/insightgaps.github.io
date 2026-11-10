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

  // 4. Instant Deep-Linking / Screen Parameter Support
  function initScreenJump() {
    const params = new URLSearchParams(window.location.search);
    const jumpScreen = params.get('screen');
    const hash = window.location.hash ? window.location.hash.replace('#', '') : null;
    const targetId = jumpScreen ? ('screen-' + jumpScreen) : hash;

    if (targetId) {
      const el = document.getElementById(targetId);
      if (el) {
        // Instant jump without smooth scroll animation delay
        el.scrollIntoView({ behavior: 'instant', block: 'start' });
        el.classList.add('is-active');
      }
    }
  }

  // Initialize on DOM load
  function initAll() {
    initProgressBar();
    initScreenObserver();
    initYouDrawIt();
    initScreenJump();
    initBoatScrolly();
    initAtmosphereAudio();
    initAutoScroll();
  }

  // 5. SBS The Boat Scrubbed Stage & Timeline Engine
  function initBoatScrolly() {
    const track = document.querySelector('.boat-scroll-track');
    const stage = document.querySelector('.boat-stage');
    if (!track || !stage) return;

    const storyKey = track.getAttribute('data-story') || 'blood-routes';
    const scenes = track.querySelectorAll('.boat-scene');
    const chapterNumEl = document.getElementById('boat-chapter-num');
    const titleEl = document.getElementById('boat-title');
    const heroStatEl = document.getElementById('boat-hero-stat');
    const narrationEl = document.getElementById('boat-narration-text');
    const nextLinkEl = document.getElementById('boat-next-link');
    const dots = track.querySelectorAll('.boat-rail-dot');

    const bloodRoutesScenes = [
      {
        num: '01 / 05',
        title: 'The Five-Fold Gap',
        stat: '5.8×',
        narration: 'WHO models 31,578 road deaths every year; the state counts 5,480. Most vanish.',
        nextText: 'Scroll to advance ↓',
        nextHref: '#scene-2'
      },
      {
        num: '02 / 05',
        title: '351 Deaths in 15 Days',
        stat: '351 Deaths',
        narration: '351 die in fifteen Eid travel days; forty-two percent strike in the night truck window.',
        nextText: 'Scroll to advance ↓',
        nextHref: '#scene-3'
      },
      {
        num: '03 / 05',
        title: 'Built to Force Racing',
        stat: 'Tk 4,000–6,000',
        narration: 'Drivers start every morning in debt; the daily lease contract forces the race.',
        nextText: 'Scroll to advance ↓',
        nextHref: '#scene-4'
      },
      {
        num: '04 / 05',
        title: 'Banned Fleets Reincarnate',
        stat: '100% Re-Entered',
        narration: 'Banned after killing a student in 2019, the same buses return under fresh paint.',
        nextText: 'Scroll to advance ↓',
        nextHref: '#scene-5'
      },
      {
        num: '05 / 05',
        title: 'Four Unpublished Registries',
        stat: '4 Sealed Voids',
        narration: 'Four public registries stay locked; fleet owners stay legally invisible.',
        nextText: 'Next: Cause 2 · Impunity Machine →',
        nextHref: '/investigations/the-impunity-machine/'
      }
    ];

    const impunityMachineScenes = [
      {
        num: '01 / 05',
        title: 'The Impunity Funnel',
        stat: '310 Convictions',
        narration: '66,711 women entered state crisis centres; only 310 cases ended in conviction.',
        nextText: 'Scroll to advance ↓',
        nextHref: '#scene-2'
      },
      {
        num: '02 / 05',
        title: 'The 72-Hour Window',
        stat: '78.0% Late',
        narration: 'Physical evidence expires in seventy-two hours; seventy-eight percent arrive after it closes.',
        nextText: 'Scroll to advance ↓',
        nextHref: '#scene-3'
      },
      {
        num: '03 / 05',
        title: 'The DNA Backlog',
        stat: '92.3% Backlog',
        narration: 'Two forensic DNA machines serve 170 million people; ninety-two percent wait untested.',
        nextText: 'Scroll to advance ↓',
        nextHref: '#scene-4'
      },
      {
        num: '04 / 05',
        title: 'Six Years to Verdict',
        stat: '2,349 Days',
        narration: 'The law promises a verdict in ninety days; trials take twenty-six times longer.',
        nextText: 'Scroll to advance ↓',
        nextHref: '#scene-5'
      },
      {
        num: '05 / 05',
        title: 'Punishment by Chance',
        stat: '1 in 4,650',
        narration: 'The state promises the death penalty, but delivers a one in 4,650 chance of punishment.',
        nextText: 'Next: Cause 3 · Lead Belt →',
        nextHref: '/investigations/the-lead-belt/'
      }
    ];

    const leadBeltScenes = [
      {
        num: '01 / 05',
        title: '59 Metres to Furnace',
        stat: '59 Metres',
        narration: 'Fifty-nine metres separate a school gate from an unlicensed battery furnace.',
        nextText: 'Scroll to advance ↓',
        nextHref: '#scene-2'
      },
      {
        num: '02 / 05',
        title: '1,702× Safety Limit',
        stat: '680,872 ppm',
        narration: 'Safe soil is 400 parts per million; Savar tests at 680,872 — 1,702 times the limit.',
        nextText: 'Scroll to advance ↓',
        nextHref: '#scene-3'
      },
      {
        num: '03 / 05',
        title: 'Two in Three Poisoned',
        stat: '65.2% in Dhaka',
        narration: 'Two in three children in Dhaka Division carry elevated lead in their blood.',
        nextText: 'Scroll to advance ↓',
        nextHref: '#scene-4'
      },
      {
        num: '04 / 05',
        title: 'The Informal Monopoly',
        stat: '294 Sites',
        narration: 'Six thousand informal kilns melt seventy percent of scrap batteries with zero filters.',
        nextText: 'Scroll to advance ↓',
        nextHref: '#scene-5'
      },
      {
        num: '05 / 05',
        title: '22 Years, 0 Cleanups',
        stat: '0 Cleanups',
        narration: 'Twenty-two years of documented surveys; zero contaminated sites have ever been cleaned.',
        nextText: 'The Missing Variable: Enter Hub →',
        nextHref: '/investigations/the-missing-variable/'
      }
    ];

    let sceneData = bloodRoutesScenes;
    if (storyKey === 'lead-belt' || storyKey === 'the-lead-belt') {
      sceneData = leadBeltScenes;
    } else if (storyKey === 'impunity-machine' || storyKey === 'the-impunity-machine') {
      sceneData = impunityMachineScenes;
    }

    let currentSceneIdx = -1;
    let ticking = false;

    function updateScrub() {
      const rect = track.getBoundingClientRect();
      const scrollableDist = rect.height - window.innerHeight;
      if (scrollableDist <= 0) {
        ticking = false;
        return;
      }

      const progress = Math.min(1, Math.max(0, -rect.top / scrollableDist));
      const numScenes = sceneData.length;
      const targetSceneIdx = Math.min(numScenes - 1, Math.floor(progress * numScenes));
      const localProgress = (progress * numScenes) - targetSceneIdx;

      // Update scene active classes
      if (targetSceneIdx !== currentSceneIdx) {
        currentSceneIdx = targetSceneIdx;
        const data = sceneData[currentSceneIdx];

        scenes.forEach(function (sc, i) {
          if (i === currentSceneIdx) {
            sc.classList.remove('is-inactive');
            sc.classList.add('is-active');
          } else {
            sc.classList.remove('is-active');
            sc.classList.add('is-inactive');
          }
        });

        if (chapterNumEl) chapterNumEl.textContent = data.num;
        if (titleEl) titleEl.textContent = data.title;
        if (heroStatEl) heroStatEl.textContent = data.stat;
        if (narrationEl) {
          narrationEl.style.opacity = '0';
          setTimeout(function () {
            narrationEl.textContent = data.narration;
            narrationEl.style.opacity = '1';
          }, 120);
        }
        if (nextLinkEl) {
          nextLinkEl.textContent = data.nextText;
          nextLinkEl.setAttribute('href', data.nextHref);
        }

        dots.forEach(function (dot, idx) {
          if (idx === currentSceneIdx) {
            dot.classList.add('is-active');
          } else {
            dot.classList.remove('is-active');
          }
        });
      }

      // Continuous SVG attribute scrubbing for active scene
      if (storyKey === 'lead-belt' || storyKey === 'the-lead-belt') {
        if (currentSceneIdx === 0) {
          const proxBar = document.getElementById('scrub-proximity-bar');
          if (proxBar) proxBar.setAttribute('width', '212');
        } else if (currentSceneIdx === 1) {
          const p1 = document.getElementById('scrub-lead-peak');
          const p2 = document.getElementById('scrub-lead-kam');
          const p3 = document.getElementById('scrub-lead-jat');
          if (p1) p1.setAttribute('width', '1450');
          if (p2) p2.setAttribute('width', '703');
          if (p3) p3.setAttribute('width', '634');
        } else if (currentSceneIdx === 2) {
          const b1 = document.getElementById('scrub-bll-dhaka');
          const b2 = document.getElementById('scrub-bll-khulna');
          const b3 = document.getElementById('scrub-bll-nat');
          const b4 = document.getElementById('scrub-bll-raj');
          if (b1) b1.setAttribute('width', '978');
          if (b2) b2.setAttribute('width', '720');
          if (b3) b3.setAttribute('width', '575');
          if (b4) b4.setAttribute('width', '239');
        } else if (currentSceneIdx === 3) {
          const c1 = document.getElementById('scrub-belt-c1');
          const c2 = document.getElementById('scrub-belt-c2');
          const c3 = document.getElementById('scrub-belt-c3');
          if (c1) c1.style.opacity = '1';
          if (c2) c2.style.opacity = '1';
          if (c3) c3.style.opacity = '1';
        } else if (currentSceneIdx === 4) {
          const cc = document.getElementById('scrub-cleanups-card');
          if (cc) cc.style.opacity = '1';
        }
      } else if (storyKey === 'impunity-machine' || storyKey === 'the-impunity-machine') {
        if (currentSceneIdx === 0) {
          const s1 = document.getElementById('scrub-imp-s1');
          const s2 = document.getElementById('scrub-imp-s2');
          const s3 = document.getElementById('scrub-imp-s3');
          const s4 = document.getElementById('scrub-imp-s4');
          const s5 = document.getElementById('scrub-imp-s5');
          if (s1) s1.style.opacity = '1';
          if (s2) s2.style.opacity = '1';
          if (s3) s3.style.opacity = '1';
          if (s4) s4.style.opacity = '1';
          if (s5) s5.style.opacity = '1';
        } else if (currentSceneIdx === 1) {
          const lateBar = document.getElementById('scrub-late-bar');
          const earlyBar = document.getElementById('scrub-early-bar');
          if (lateBar) lateBar.setAttribute('width', '858');
          if (earlyBar) earlyBar.setAttribute('width', '242');
        } else if (currentSceneIdx === 2) {
          const dnaBar = document.getElementById('scrub-dna-bar');
          const c1 = document.getElementById('scrub-dna-c1');
          const c2 = document.getElementById('scrub-dna-c2');
          if (dnaBar) dnaBar.setAttribute('width', '1200');
          if (c1) c1.style.opacity = '1';
          if (c2) c2.style.opacity = '1';
        } else if (currentSceneIdx === 3) {
          const statBar = document.getElementById('scrub-statutory-bar');
          const delayBar = document.getElementById('scrub-verdict-bar');
          const pileupCard = document.getElementById('scrub-pileup-card');
          if (statBar) statBar.setAttribute('width', '45');
          if (delayBar) delayBar.setAttribute('width', '1050');
          if (pileupCard) pileupCard.style.opacity = '1';
        } else if (currentSceneIdx === 4) {
          const probCard = document.getElementById('scrub-prob-card');
          const deterCard = document.getElementById('scrub-deter-card');
          if (probCard) probCard.style.opacity = '1';
          if (deterCard) deterCard.style.opacity = '1';
        }
      } else {
        // Blood Routes scrubbing
        if (currentSceneIdx === 0) {
          const whoBar = document.getElementById('scrub-who-bar');
          const brtaBar = document.getElementById('scrub-brta-bar');
          const voidBox = document.getElementById('scrub-void-box');
          if (whoBar) whoBar.setAttribute('width', '1100');
          if (brtaBar) brtaBar.setAttribute('width', '191');
          if (voidBox) voidBox.style.opacity = '1';
        } else if (currentSceneIdx === 1) {
          const eidBar = document.getElementById('scrub-eid-bar');
          const nightBar = document.getElementById('scrub-night-bar');
          if (eidBar) eidBar.setAttribute('width', '760');
          if (nightBar) nightBar.setAttribute('width', '500');
        } else if (currentSceneIdx === 2) {
          const flowCard1 = document.getElementById('scrub-joma-c1');
          const flowCard2 = document.getElementById('scrub-joma-c2');
          const flowCard3 = document.getElementById('scrub-joma-c3');
          if (flowCard1) flowCard1.style.opacity = '1';
          if (flowCard2) flowCard2.style.opacity = '1';
          if (flowCard3) flowCard3.style.opacity = '1';
        } else if (currentSceneIdx === 3) {
          const phoenixCard1 = document.getElementById('scrub-phx-c1');
          const phoenixCard2 = document.getElementById('scrub-phx-c2');
          const phoenixCard3 = document.getElementById('scrub-phx-c3');
          if (phoenixCard1) phoenixCard1.style.opacity = '1';
          if (phoenixCard2) phoenixCard2.style.opacity = '1';
          if (phoenixCard3) phoenixCard3.style.opacity = '1';
        } else if (currentSceneIdx === 4) {
          const v1 = document.getElementById('scrub-void-1');
          const v2 = document.getElementById('scrub-void-2');
          const v3 = document.getElementById('scrub-void-3');
          const v4 = document.getElementById('scrub-void-4');
          if (v1) v1.style.opacity = '1';
          if (v2) v2.style.opacity = '1';
          if (v3) v3.style.opacity = '1';
          if (v4) v4.style.opacity = '1';
        }
      }

      ticking = false;
    }

    window.addEventListener('scroll', function () {
      if (!ticking) {
        window.requestAnimationFrame(updateScrub);
        ticking = true;
      }
    }, { passive: true });

    // Chapter Rail dot clicks: Jump directly to the chapter offset
    dots.forEach(function (dot) {
      dot.addEventListener('click', function () {
        const targetIdx = parseInt(dot.getAttribute('data-chapter-idx'), 10);
        if (!isNaN(targetIdx)) {
          const trackRect = track.getBoundingClientRect();
          const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
          const trackTop = trackRect.top + scrollTop;
          const scrollableDist = trackRect.height - window.innerHeight;
          const targetOffset = trackTop + (scrollableDist * (targetIdx / sceneData.length)) + 5;
          window.scrollTo({ top: targetOffset, behavior: 'smooth' });
        }
      });
    });

    // Deep link support (?chapter=N or ?screen=N)
    const urlParams = new URLSearchParams(window.location.search);
    const chapterParam = urlParams.get('chapter') || urlParams.get('screen');
    if (chapterParam) {
      const idx = parseInt(chapterParam, 10) - 1;
      if (idx >= 0 && idx < sceneData.length) {
        setTimeout(function () {
          const trackRect = track.getBoundingClientRect();
          const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
          const trackTop = trackRect.top + scrollTop;
          const scrollableDist = trackRect.height - window.innerHeight;
          const targetOffset = trackTop + (scrollableDist * (idx / sceneData.length)) + 10;
          window.scrollTo({ top: targetOffset, behavior: 'instant' });
        }, 100);
      }
    }

    // Run first calculation
    updateScrub();
  }

  // 6. Web Audio API Ambient Sound Generator (Muted by default)
  function initAtmosphereAudio() {
    const btn = document.getElementById('boat-sound-btn');
    if (!btn) return;

    let audioCtx = null;
    let masterGain = null;
    let isPlaying = false;

    function setupAudio() {
      if (audioCtx) return;
      try {
        const AudioContext = window.AudioContext || window.webkitAudioContext;
        audioCtx = new AudioContext();

        masterGain = audioCtx.createGain();
        masterGain.gain.setValueAtTime(0.0001, audioCtx.currentTime);
        masterGain.connect(audioCtx.destination);

        // Sub-bass drone (55Hz highway rumble)
        const osc = audioCtx.createOscillator();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(55, audioCtx.currentTime);

        const oscGain = audioCtx.createGain();
        oscGain.gain.setValueAtTime(0.35, audioCtx.currentTime);
        osc.connect(oscGain);
        oscGain.connect(masterGain);
        osc.start();

        // 110Hz harmonic drone
        const osc2 = audioCtx.createOscillator();
        osc2.type = 'triangle';
        osc2.frequency.setValueAtTime(110, audioCtx.currentTime);

        const filter = audioCtx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.setValueAtTime(140, audioCtx.currentTime);

        const osc2Gain = audioCtx.createGain();
        osc2Gain.gain.setValueAtTime(0.18, audioCtx.currentTime);
        osc2.connect(filter);
        filter.connect(osc2Gain);
        osc2Gain.connect(masterGain);
        osc2.start();

        // Asphalt hiss / rain noise buffer
        const bufferSize = audioCtx.sampleRate * 2;
        const noiseBuffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate);
        const output = noiseBuffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
          output[i] = (Math.random() * 2 - 1) * 0.12;
        }

        const whiteNoise = audioCtx.createBufferSource();
        whiteNoise.buffer = noiseBuffer;
        whiteNoise.loop = true;

        const noiseFilter = audioCtx.createBiquadFilter();
        noiseFilter.type = 'bandpass';
        noiseFilter.frequency.setValueAtTime(850, audioCtx.currentTime);
        noiseFilter.Q.setValueAtTime(1.2, audioCtx.currentTime);

        whiteNoise.connect(noiseFilter);
        noiseFilter.connect(masterGain);
        whiteNoise.start();
      } catch (err) {
        console.warn('Web Audio API not supported', err);
      }
    }

    btn.addEventListener('click', function () {
      setupAudio();
      if (!audioCtx) return;

      if (audioCtx.state === 'suspended') {
        audioCtx.resume();
      }

      if (!isPlaying) {
        masterGain.gain.linearRampToValueAtTime(0.12, audioCtx.currentTime + 1.2);
        btn.innerHTML = '🔊 Atmosphere: On';
        btn.classList.add('is-active');
        isPlaying = true;
      } else {
        masterGain.gain.linearRampToValueAtTime(0.0001, audioCtx.currentTime + 0.6);
        btn.innerHTML = '🔇 Atmosphere: Off';
        btn.classList.remove('is-active');
        isPlaying = false;
      }
    });
  }

  // 7. Auto-Scroll Cinematic Reader Engine
  function initAutoScroll() {
    const btn = document.getElementById('boat-autoscroll-btn');
    if (!btn) return;

    let isScrolling = false;
    let animId = null;

    function step() {
      if (!isScrolling) return;
      window.scrollBy(0, 1.5);
      if ((window.innerHeight + window.pageYOffset) >= document.body.offsetHeight - 50) {
        stopAutoScroll();
        return;
      }
      animId = requestAnimationFrame(step);
    }

    function startAutoScroll() {
      isScrolling = true;
      btn.innerHTML = '⏸ Auto-Scroll: On';
      btn.classList.add('is-active');
      animId = requestAnimationFrame(step);
    }

    function stopAutoScroll() {
      isScrolling = false;
      btn.innerHTML = '▶ Auto-Scroll';
      btn.classList.remove('is-active');
      if (animId) cancelAnimationFrame(animId);
    }

    btn.addEventListener('click', function () {
      if (isScrolling) {
        stopAutoScroll();
      } else {
        startAutoScroll();
      }
    });

    // Pause on user wheel or touch
    window.addEventListener('wheel', function () {
      if (isScrolling) stopAutoScroll();
    }, { passive: true });
    window.addEventListener('touchmove', function () {
      if (isScrolling) stopAutoScroll();
    }, { passive: true });
  }

  // Initialize on DOM load
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAll);
  } else {
    initAll();
  }
})();
