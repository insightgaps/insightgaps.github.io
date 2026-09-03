# Insight Gaps Bureau — Production State Audit

**Date:** 3 September 2026
**Method:** live HTTP probing of every layer between git and the rendered site (no deployment assumed successful).

---

## Layer table

| Layer | Expected | Actual | Status | Evidence |
|---|---|---|---|---|
| Local git (branch `main`) | Phase-2 HEAD `5fd2219` | `5fd2219` + Phase-3 branch work (unmerged at audit start) | OK | `git rev-parse HEAD` |
| `origin/main` | == local main | `5fd2219` (pushed 2 Sep, verified then) | OK | `git ls-remote` |
| Cloudflare connection | Pages project building from git | **Connected** — remote branch `origin/cloudflare/workers-autoconfig` exists; responses now served with `Server: cloudflare` and no cache markers | OK (connection), see deployment row | `git branch -a`; response headers |
| Deployment output | `public/` build artifacts served at site root | **Repo root served / no build ran**: every route 404s, including previously-live legacy routes (`/content/investigations/`) | **BROKEN** | `curl https://www.insightgaps.com/` → 404; `…/content/investigations/` → 404; `…/data/investigations.json` → empty |
| DNS / host | `insightgaps.com` + `www` resolve to Cloudflare | Both resolve; http→https 301 works; GitHub Pages still 301s to www | OK | `curl -w` probes |
| HTTPS | Valid TLS | Valid (no cert errors in probes) | OK | probes |
| Live HTML | Phase-2 generated homepage (pre-rendered stats/cards, no hydration markers) | **404** | **BROKEN** | probe |
| Live assets/JS | Phase-2 asset tree | **404** | **BROKEN** | probe |
| Live canonical | `https://www.insightgaps.com/...` per page | n/a (no page) | **BROKEN** | probe |
| Live sitemap/robots/JSON-LD | Generated set | **404** | **BROKEN** | probe |

## Root cause (diagnosed, not guessed)

Timeline evidence: on 2 Sep the legacy site was live and byte-identical to the pre-Phase-2 repo. On 3 Sep **every** path 404s. The only infrastructure change in between is the appearance of the `cloudflare/workers-autoconfig` remote branch — i.e., a Cloudflare Pages project was connected to this GitHub repository after the Phase-2 push. Pages then attempted to deploy **the repo root as a static site**. The repo root contains **no `index.html`**: the Phase-2 restructure moved all pages into build-time generation, and the generated site (`public/`) is intentionally git-ignored. Deploying a directory with no index → Cloudflare serves 404 for every route. The in-repo file that described the intended build (`cloudflare-pages.toml`) is **not a file Cloudflare Pages reads** — Pages reads its dashboard settings or `wrangler.toml`.

## Fix applied (in-repo, safe)

- Replaced `cloudflare-pages.toml` + legacy `wrangler.jsonc` with a single **`wrangler.toml`** Pages configuration:
  - `name = "insightgaps"`, `pages_build_output_dir = "public"`
  - `[build] command = "pip install jinja2 && python scripts/build.py && python scripts/validate.py"` (pip install was a latent gap — Pages build images do not include Jinja2)
  - `PYTHON_VERSION = "3.11"`
- Removed the legacy `CNAME` file (GitHub-Pages leftover; host mapping is Cloudflare-side).

## Residual blocker (account-level; cannot be fixed from the repository)

If the Pages project's dashboard settings override `wrangler.toml` (project created before the file existed, with framework preset "None", no build command, output `/`), the first build after this push may still deploy the repo root. In that case, exactly one dashboard change is required:

- **Cloudflare dashboard → Workers & Pages → insightgaps → Settings → Build configuration:**
  - Build command: `pip install jinja2 && python scripts/build.py && python scripts/validate.py`
  - Build output directory: `public`
  - (Production branch: `main`)

After either path takes effect, the deployment will serve the Phase-2/3 generated site (now also with slum-fires unpublished per owner decision). Also still pending at the zone level (documented since Phase 2): the `insightgaps.com → www.insightgaps.com` 301 redirect rule.

## State of the site content that will deploy

Phase 2 generated site + Phase 3 improvements + slum-fires unpublished (owner decision 2026-09-03): 11 template pages + 7 standalone documents, 3 investigations / 120 primary sources, 22 sitemap URLs, all slum-fires routes 301'd to `/investigations/`. Build PASS, validation PASS (0 errors), fixtures 8/8.

## Verification commands for the owner (post-deploy)

```
curl -s -o /dev/null -w "%{http_code}" https://www.insightgaps.com/                 # expect 200
curl -s https://www.insightgaps.com/ | grep -c "metrics-block__number"              # expect 2 (pre-rendered stats)
curl -s -o /dev/null -w "%{http_code}" https://www.insightgaps.com/investigations/  # expect 200
curl -s -o /dev/null -w "%{http_code} %{redirect_url}" https://www.insightgaps.com/investigations/dhaka-slum-fires/  # expect 301 -> /investigations/
```


## Update (2026-09-03, post-owner-dashboard-config check) — CONFIRMED root cause with hard evidence

Probes after the wrangler.toml fix was pushed:

| Probe | Result | Meaning |
|---|---|---|
| `/scripts/build.py` | **200** | The deployment is serving **repo-root files** |
| `/site.json` | 200, content = Phase-2 version (no `stats_notes`, 1,413 bytes vs 1,910 local) | The served snapshot is the **2026-09-02 Phase-2 push** — no build has run since |
| `/` , `/content/` , `/wrangler.toml` , `/public/index.html` | 404 | No index document and no generated output in the deployment |
| `Cache-Control: public, max-age=0, must-revalidate` + fresh ETag | — | Direct asset serving, not an error page |

**Conclusion (evidence-closed):** the Pages project deploys the repository root as a static asset directory, with **no build command configured**, and its dashboard settings override the in-repo `wrangler.toml`. None of the 2026-09-02/03 pushes triggered a rebuild. This cannot be fixed from the repository.

**The exact one-step fix (owner, Cloudflare dashboard):**
Workers & Pages → project `insightgaps` → Settings → Build configuration:
- Build command: `pip install jinja2 && python scripts/build.py && python scripts/validate.py`
- Build output directory: `public`
- Production branch: `main`
Then "Retry deployment". (Equivalent: delete + re-create the Pages project — a fresh connection reads `wrangler.toml`.)
Secondary zone-level item: add the `insightgaps.com → www.insightgaps.com` 301 rule.

---

## FROZEN DEPLOYMENT PROOF (2026-09-03, final)

After the root-mirror recovery push (`a7103e1`), live probes confirm the deployment is **frozen at exactly commit `5fd2219`** (the 2026-09-02 Phase-2 push):

- Live `site.json` MD5 `4a48fff6…` == `git show 5fd2219:site.json` MD5 — byte-identical.
- Files added by later pushes (`wrangler.toml`, `PREPARED_CHANGES.md`, `EXECUTION_STATUS_2026-09-03.md`, `REPORT_FORENSIC_AUDIT_PHASE_3.md`) → all 404 on the live host.
- `/index.html` at root (shipped by the mirror) → 404 on the live host, while `/scripts/build.py` (existed at `5fd2219`) → 200.

**Conclusion: pushes do not trigger anything in the Cloudflare Pages project.** No build has run since the project was connected, and later commits are not even synced as static assets. This means the project's git integration/deployments are disabled or broken at the account level — not merely a missing build command. The repo-side recovery (root mirror) is in place and correct: the moment any root-serving deploy of current `main` occurs, the site works.

**Owner actions (in order):**
1. Cloudflare dashboard → Workers & Pages → `insightgaps` → **Deployments**: check whether any deployment is listed at all. If none: the git connection failed — reconnect the repo.
2. Settings → **Build configuration**: command `pip install jinja2 && python scripts/build.py && python scripts/validate.py`, output `public`, branch `main`. (With the root mirror in place, even a "no build, root output" configuration now serves the site.)
3. Trigger **"Retry deployment" / "Create deployment"**.
4. If the project shows a "workers-autoconfig" setup instead of Pages static hosting, delete the project and re-create it as a **Pages** project connected to `insightgaps/insightgaps.github.io`, branch `main`.

Fallback that requires no Cloudflare at all: the repo also works on GitHub Pages — enable it for the `main` branch (the root now contains the full generated site + `404.html` + `_redirects`-equivalent routing via directories), and point the DNS `www` CNAME at `insightgaps.github.io`.
