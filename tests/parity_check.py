"""Route-parity harness: compares migrated pages against the live site.

Usage: python tests/parity_check.py [--local http://127.0.0.1:8000]
Compares visible text of each migrated route with its legacy live URL.
Differences in dynamic sections (pre-rendered vs JS-hydrated) are expected to be
identical in content; only whitespace-normalized text is compared.
"""
from __future__ import annotations

import argparse
import re
import sys
import urllib.request
from html.parser import HTMLParser

# (legacy live URL, new local route)
PAIRS = [
    ("https://www.insightgaps.com/", "/"),
    ("https://www.insightgaps.com/about.html", "/about/"),
    ("https://www.insightgaps.com/archive.html", "/archive/"),
    ("https://www.insightgaps.com/contact.html", "/contact/"),
    ("https://www.insightgaps.com/content/investigations/", "/investigations/"),
    ("https://www.insightgaps.com/analysis/", "/analysis/"),
    ("https://www.insightgaps.com/content/trust/methodology.html", "/trust/methodology/"),
    ("https://www.insightgaps.com/content/trust/ai-use.html", "/trust/ai-use/"),
    ("https://www.insightgaps.com/content/trust/corrections.html", "/trust/corrections/"),
    ("https://www.insightgaps.com/data/", "/evidence/"),
    ("https://www.insightgaps.com/content/investigations/dhaka-slum-fires/", "/investigations/dhaka-slum-fires/"),
    ("https://www.insightgaps.com/investigations/national/blood-routes/", "/investigations/blood-routes/"),
    ("https://www.insightgaps.com/content/investigations/the-lead-belt/", "/investigations/the-lead-belt/"),
    ("https://www.insightgaps.com/content/investigations/the-impunity-machine/", "/investigations/the-impunity-machine/"),
    ("https://www.insightgaps.com/content/investigations/the-impunity-machine/tracker.html", "/investigations/the-impunity-machine/tracker/"),
    ("https://www.insightgaps.com/content/investigations/the-impunity-machine/methodology.html", "/investigations/the-impunity-machine/methodology/"),
    ("https://www.insightgaps.com/content/investigations/the-impunity-machine/detailed.html", "/investigations/the-impunity-machine/detailed/"),
]

THRESHOLD = 0.85


class TextExtract(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.parts: list[str] = []
        self._skip = 0

    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style"):
            self._skip += 1

    def handle_endtag(self, tag):
        if tag in ("script", "style") and self._skip:
            self._skip -= 1

    def handle_data(self, data):
        if not self._skip:
            self.parts.append(data)


def text_of(html: str) -> str:
    p = TextExtract()
    p.feed(html)
    text = " ".join(p.parts)
    return re.sub(r"\s+", " ", text).strip()


def fetch(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": "ig-parity-check"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.read().decode("utf-8", errors="replace")


def sim(a: str, b: str) -> float:
    """Char-bigram similarity (crude but adequate for content preservation)."""
    def grams(s):
        return set(s[i:i + 2] for i in range(len(s) - 1))
    ga, gb = grams(a), grams(b)
    if not ga or not gb:
        return 0.0
    return len(ga & gb) / len(ga | gb)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--local", default="http://127.0.0.1:8000")
    args = ap.parse_args()
    failures = 0
    for legacy, local in PAIRS:
        try:
            live_text = text_of(fetch(legacy))
        except Exception as exc:
            print(f"SKIP {local}: live fetch failed ({exc})")
            continue
        try:
            new_text = text_of(fetch(args.local + local))
        except Exception as exc:
            print(f"FAIL {local}: local fetch failed ({exc})")
            failures += 1
            continue
        score = sim(live_text, new_text)
        status = "ok  " if score >= THRESHOLD else "FAIL"
        if score < THRESHOLD:
            failures += 1
        print(f"{status} {local}: similarity {score:.3f} (live {len(live_text)} ch, local {len(new_text)} ch)")
    print("parity: " + ("PASS" if failures == 0 else f"{failures} FAILURES"))
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
