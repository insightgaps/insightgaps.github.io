"""Deployment sync: mirror the built site (public/) to the repository root.

Why this exists: the Cloudflare Pages project was connected with no build
command (dashboard settings override wrangler.toml), so it serves the REPO
ROOT as static files. Until the dashboard build configuration is fixed
(see PRODUCTION_STATE_AUDIT.md), this script makes the repo root BE the
site so the broken deployment still serves correctly.

Run AFTER scripts/build.py. Idempotent. Once the dashboard is fixed, stop
running this and delete the mirrored output (script has --clean).
"""
from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PUBLIC = ROOT / "public"

# Root files that belong to the REPOSITORY, not the site. Never overwritten.
REPO_ONLY = {
    "site.json", "corrections.log.jsonl", "wrangler.toml", "wrangler.jsonc",
    "cloudflare-pages.toml", "CNAME", ".gitignore", ".git", ".gitattributes",
    "README.md", "LICENSE",
    # source directories — never mirrored INTO, but also never deleted
    "content", "templates", "scripts", "tests", "config", "docs",
    "scripts_old", "node_modules", "venv", ".venv", "__pycache__",
}

# Tracked source files that live at root and would be clobbered by the mirror.
# The mirror copies the build's versions over the root copies (identical content
# for assets/; favicon/theme-toggle are copied into public/ by the build anyway).
ALLOW_CLOBBER = {"favicon.png", "theme-toggle.js"}


def clean_dir(dst: Path) -> None:
    """Remove mirrored output at root (restore convention)."""
    for item in PUBLIC.iterdir():
        target = ROOT / item.name
        if item.name in REPO_ONLY:
            continue
        if target.exists():
            if target.is_dir():
                shutil.rmtree(target)
            else:
                target.unlink()
    print("cleaned root mirror (repo-only files untouched)")


def sync() -> int:
    if not (PUBLIC / "index.html").exists():
        print("public/ has no index.html — run scripts/build.py first")
        return 1
    copied = skipped = 0
    for item in PUBLIC.rglob("*"):
        rel = item.relative_to(PUBLIC)
        # never touch repo-only paths
        if rel.parts[0] in REPO_ONLY:
            skipped += 1
            continue
        target = ROOT / rel
        if item.is_dir():
            target.mkdir(parents=True, exist_ok=True)
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        # root source files we deliberately overwrite with build output
        if rel.parts[0] in ALLOW_CLOBBER and target.exists():
            pass  # allowed
        shutil.copy2(item, target)
        copied += 1
    print(f"synced {copied} files to root ({skipped} repo-only paths skipped)")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--clean", action="store_true", help="remove the root mirror")
    args = ap.parse_args()
    return clean_dir(None) if args.clean else sync()


if __name__ == "__main__":
    sys.exit(main())
