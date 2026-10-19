#!/usr/bin/env python3
"""
bureau.py — Insight Gaps Bureau Master Orchestrator (Web Repo Link)
"""
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OS_DIR = ROOT.parent / "insightgaps-os" / "scripts" / "bureau.py"

if OS_DIR.is_file():
    import subprocess
    sys.exit(subprocess.run([sys.executable, str(OS_DIR)] + sys.argv[1:]).returncode)
else:
    # Standalone fallback inside web repo
    import subprocess
    cmd = sys.argv[1].lower() if len(sys.argv) > 1 else "status"
    if cmd in ("build", "sync"):
        sys.exit(subprocess.run([sys.executable, str(ROOT / "scripts" / "build.py"), "-a"]).returncode)
    elif cmd == "status":
        print("Git repo status:")
        subprocess.run(["git", "status", "-sb"])
    else:
        print("Run python scripts/build.py -a to build, sync, and validate.")
