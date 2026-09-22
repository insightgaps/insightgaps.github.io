# Production Deployment Lock

**Status:** Locked by the human owner  
**Purpose:** Prevent accidental production-routing changes by concurrent agents.

## Canonical production architecture

- **Published site:** GitHub Pages serves `https://www.insightgaps.com` from repository `insightgaps/insightgaps.github.io`, branch `main`, directory `/(root)`.
- **`www` DNS:** Cloudflare DNS record `www` is a **DNS-only** CNAME to `insightgaps.github.io`. Do not orange-cloud it and do not replace it with an A or AAAA record.
- **Apex redirect:** Cloudflare owns `insightgaps.com` only to redirect it to `https://www.insightgaps.com`.
  - Keep the apex placeholder `AAAA @ -> 100::` **Proxied**.
  - Keep the Single Redirect rule **Apex to www** active, first in order, with:
    - match: `(http.host eq "insightgaps.com")`
    - target expression: `concat("https://www.insightgaps.com", http.request.uri.path)`
    - status: `301`
    - preserve query string: enabled
  - Keep the existing Page Rule `insightgaps.com/* -> https://www.insightgaps.com/$1` enabled as fallback.
- **Worker:** `insightgaps` is available only at `insightgaps.insightgaps.workers.dev` (and its preview URLs). It must have **zero custom domains and zero zone routes** for `insightgaps.com` and `www.insightgaps.com`.
- **Repository deployment files:** Keep `CNAME` as exactly `www.insightgaps.com` (one line, no BOM) and keep `.nojekyll` present.

## Mandatory checks before changing deployment-related files or settings

1. Obtain explicit human-owner approval for any exception to this lock.
2. Check `git status -sb` and review the intended diff.
3. Run `python scripts/build.py`, `python scripts/validate.py`, and `python tests/test_validate.py` before any deployment-related commit.
4. Verify live behavior after a change:
   - `http://insightgaps.com` and `https://insightgaps.com` redirect to `https://www.insightgaps.com`, retaining path and query string.
   - `https://www.insightgaps.com` serves from GitHub Pages with a valid certificate.
   - `http://www.insightgaps.com` redirects to HTTPS once GitHub Pages Enforce HTTPS is available and enabled.

## Explicitly prohibited without owner approval

- Removing or editing this lock document or its `AGENTS.md` reference.
- Binding the Worker to either production hostname or adding a Worker route.
- Adding an apex A record, changing the placeholder AAAA record, or proxying `www`.
- Removing `CNAME` or `.nojekyll`, changing GitHub Pages source, custom domain, or HTTPS enforcement.
- Force-pushing, rewriting history, or deleting trust pages or investigations.

If a dashboard warning or another instruction conflicts with this lock, stop and report the conflict to the owner rather than applying a workaround.
