# Workflow Stage 09: Pre-Publication Audit & Publish Gate

**Stage:** 09 · Pre-flight QA & Staging Gatekeeper  
**Owner:** Agent 09 (Publisher)  
**Inputs:** Complete investigation files, assets, indices, sitemaps  
**Outputs:** Staged git working tree (`git add -A`), `docs/office/workspace/release/<slug>-release-packet.md`

---

## 1. Objectives

The Pre-Publication Audit stage is the strict release gate. The Publisher conducts a comprehensive technical, asset, and editorial audit, stages all files using `git add -A`, and presents a structured Release Packet to the human owner.

**Rule:** Autonomous agents never commit and never push. The human owner reviews the staged package and gives the final live command.

---

## 2. Pre-flight Verification Checklist

- [ ] **Asset Resolution:** Run script to verify that every `<img src="...">`, `<link href="...">`, and `<script src="...">` resolves to an existing file on disk. Zero 404s.
- [ ] **Internal Link Resolution:** Confirm all navigation links (`/methodology/`, `/investigations/`, `/corrections/`) resolve correctly.
- [ ] **Desktop & Mobile Parity:** Test rendering at 1440px desktop width (charts expand to 960px) and 360px mobile width (single-column responsive).
- [ ] **Homepage & Archive Integration:** Confirm that the new investigation card is present on `index.html` and `investigations/index.html`.
- [ ] **JSON-LD Syntax:** Validate schema markup using linter/JSON parser.
- [ ] **Git Working Tree Inspection:** Check `git status` to ensure only intended files are modified/created. No scratch scripts, no temporary test files in the repo root.
- [ ] **Execution of `git add -A`:** Stage all files.
- [ ] **Verify Uncommitted State:** Confirm with `git status` that changes are staged and uncommitted.

---

## 3. Step-by-Step Procedure

1. **Run Local Link and Asset Auditor:**
   - Execute PowerShell or Python link verification script across `investigations/<slug>/index.html`.

2. **Update Global Indices:**
   - Add new report card with hero image, title, deck, and date to `index.html` and `investigations/index.html`.

3. **Stage All Changes:**
   - Execute: `& 'C:\Program Files\Git\cmd\git.exe' add -A`
   - Run: `& 'C:\Program Files\Git\cmd\git.exe' status`

4. **Author Release Packet:**
   - Generate `docs/office/workspace/release/<slug>-release-packet.md` detailing:
     - Title, slug, and word count.
     - Summary of key findings and claim grades.
     - Rebuilt/created charts and dimensions.
     - Git diff summary and staged status.
     - Explicit notice to human owner requesting review and push approval.
