# Insight Gaps — Website

Public site served at https://www.insightgaps.com via GitHub Pages (`main` / root).

Start: `START_HERE.md` → agent rules `AGENTS.md` → deploy lock
`docs/publication/PRODUCTION_DEPLOYMENT_LOCK.md` → session history `docs/archive/`.

Build: `pip install jinja2 && python scripts/build.py && python scripts/validate.py`
(`public/` output mirrored to root by `python scripts/sync_root.py`).

License: CC BY 4.0 — see `LICENSE`.
