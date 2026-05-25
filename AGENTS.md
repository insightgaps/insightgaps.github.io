# AGENTS.md — Insight Gaps Agent Governance and Operating Rules

This file is the single source of truth for all coding agents operating in this repository.

## 1) Governance Documents
Insight Gaps is governed by the following documents located in `docs/governance/`.

Read them in this order before making any changes:

- `docs/governance/03-content-architecture.md`
- `docs/governance/04-content-schema.md`
- `docs/governance/04a-design-tokens.md`
- `docs/governance/04b-component-rules.md`
- `docs/governance/04c-page-specs.md`
- `docs/governance/04d-template-specs.md`
- `docs/governance/06-ai-workflow.md`

**Requirement:** Agents MUST read all of these governance files before making any changes.

---

## 2) Permitted and Prohibited Actions

### Permitted Actions (What Agents MAY Do):
- Modify HTML files.
- Modify CSS files.
- Modify JS files.
- Add new investigations.
- Add new analysis reports.
- Fix bugs.

### Prohibited Actions (What Agents MAY NOT Do):
- Change repository/content architecture without explicit human owner approval.
- Change schemas without explicit human owner approval.
- Change design tokens without explicit human owner approval.
- Delete existing investigations.
- Remove trust pages (e.g., `methodology.html`, `ai-use.html`, `corrections.html`).
- Push directly to production without explicit human owner instruction.

---

## 3) Operating Rules & Edit Discipline

- **Conflict Protocol:** If any user request or instruction conflicts with the governance documentation, the agent must **STOP immediately and report the conflict** to the user.
- **Minimal Diffs:** Always make the smallest possible change that satisfies the request. Keep unrelated files untouched.
- **Pre-edit Explanation:** Always explain planned changes in detail before performing edits.
- **Path Validation:** Always validate file paths against the repository architecture specified in `docs/governance/03-content-architecture.md`.
- **Content Separation:** Always preserve the separation between the **investigation** and **analysis** content tracks.
- **Locality:** Work only inside the cloned repository context. Treat the repo as the only valid working context. Do not make outside assumptions.
- **Build Discipline:** Follow the locked architecture and page specs exactly. Use the existing design tokens and component rules only. Do not create ad hoc CSS or JS patterns when a shared asset already exists. Do not add dependencies unless approved.
- **Verification before any push:**
  - Confirm the changed files are the intended files.
  - Review the diff.
  - Check for broken references and missing assets.
  - Check that paths are correct for the deployed site.
  - Check that the page matches the architecture and page specs.
- **Git Safety:** Never force-push, never rewrite commit history, and never delete branches.

---

## 4) Specific Agent Guidelines

### For Codex specifically:
- Read the repository instructions first.
- Keep implementation exact.
- Do not make architectural decisions.
- If the request requires a design or workflow change, stop and ask.
- If a file is missing, report the missing file instead of creating a substitute.

### For Antigravity specifically:
- Use this same rule set.
- Stay inside the approved file list.
- Do not self-expand the task.
- Do not auto-correct unrelated files.
- Do not treat a partial success as complete if validation fails.

---

## 5) Default Behavior Summary
The safe default for all future work is:
`read` → `inspect` → `edit minimally` → `validate locally` → `report` → `wait for approval to push`
