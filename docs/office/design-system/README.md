# Insight Gaps UI Design System

**Design Specification & Token Manual**  
**Version:** 2.0 (Forensic & Desktop-First)  
**Maintained in:** `assets/css/style.css` & `docs/office/design-system/`  

---

## 1. Principles of Forensic Information Design

The Insight Gaps visual language is engineered for credibility, legibility, and evidentiary transparency. It rejects decorative clutter, frivolous animations, and commercial ad patterns in favor of calm, high-contrast, editorial typography.

1. **Warm Paper & Charcoal Ink:** Readability emulates physical broadsheet journalism, pairing warm ivory surfaces (`#fdfcf8`) with deep charcoal ink (`#16130f`) and restrained terracotta/crimson accents (`#8c2b18`).
2. **Hairlines, Not Shadows:** Structural hierarchy is communicated through hairline dividers (`1px solid #e3ddd0`) and strong top borders (`2px–4px solid #16130f`), never fuzzy box-shadows or floating cards.
3. **Full-Width Desktop Visuals:** Critical investigative charts require horizontal space. Visual containers scale up to **960px width** on desktop displays, preventing squeezed data visualizations.
4. **Accessible Typography Scale:** No chart label or footnote may be smaller than 12px; visible narrative text scales from 17px (1.0625rem) to 18px (1.1rem); headings are set in authoritative serif type.
5. **Native HTML5 Extensibility:** Secondary data tables, detailed upazila breakdowns, and methodological derivations live inside native `<details class="evidence-box">` elements, keeping stories scannable without JavaScript overhead.

---

## 2. Design Tokens Reference

### Color System
```css
:root {
  /* Surfaces */
  --color-bg: #fdfcf8;           /* Primary broadsheet paper */
  --color-bg-soft: #f5f1e8;      /* Secondary surface / code / evidence background */
  --color-bg-card: #f9f7f2;      /* Elevated stat card background */
  
  /* Ink & Typography */
  --color-ink: #16130f;          /* Deep charcoal primary body & headlines */
  --color-ink-muted: #6d675c;    /* Secondary text / captions / deks */
  --color-ink-faint: #8a8478;    /* Muted metadata / labels / dates */
  
  /* Structural Dividers */
  --color-line: #e3ddd0;         /* Standard hairline divider / table borders */
  --color-line-strong: #16130f;  /* Prominent section / header top border */
  
  /* Editorial Accents */
  --color-accent: #8c2b18;       /* Primary investigative accent (crimson/terracotta) */
  --color-accent-soft: #f7ece8;  /* Soft alert / highlight tint */
  --color-accent-hover: #b03820; /* Interactive hover / focus state */

  /* Claim Grading Tokens */
  --color-grade-confirmed: #2f5d3a;  /* Confirmed claim (forest green) */
  --color-grade-supported: #3d382f;  /* Supported claim (charcoal brown) */
  --color-grade-contested: #8c2b18;  /* Contested claim (deep crimson) */
  --color-grade-untraced: #8a8478;   /* Untraced / void claim (slate gray) */
}
```

### Typography System
```css
:root {
  --font-serif: "KaTeX_Main", Georgia, "Iowan Old Style", Palatino, serif;
  --font-sans: "KaTeX_SansSerif", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
  --font-mono: "JetBrainsMono", ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
}
```

### Layout Scale & Containers
```css
:root {
  --measure: 68ch;          /* Optimal prose reading measure */
  --page: 74rem;            /* Master homepage & archive width (1184px) */
  --container-report: 960px; /* Investigation report & full-width chart width */
}
```

---

## 3. Responsive Breakpoints

| Breakpoint | Target Screen | Layout Behavior |
| :--- | :--- | :--- |
| `< 48rem` (`< 768px`) | Mobile Viewports | Single-column linear flow; tables horizontally scrollable; stacked charts. |
| `≥ 48rem` (`≥ 768px`) | Tablet / Small Laptop | Multi-column homepage grids; stat strips expand to 3-columns. |
| `≥ 56.25rem` (`≥ 900px`)| Desktop Workstations | `.page--report` unlocks full 960px chart containers (`figure.chart-full`). |

---

## 4. Evidentiary UI Rules

- **Zero Fake Photos:** All hero graphics must be either verified data maps or labeled synthetic concept art generated from verified spatial parameters (e.g. Gemini-generated models of road networks, lead recycling boundaries, or court archives).
- **Direct Labeling in Charts:** Avoid detached legends. Values and categories should be positioned adjacent to their visual marks.
- **Permanent Anchor IDs:** Every section, chart figure, evidence box, and correction card must have a permanent HTML `id` attribute for permanent legal and peer-review citations.
