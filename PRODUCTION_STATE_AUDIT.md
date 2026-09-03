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
