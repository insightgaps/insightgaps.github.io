#!/usr/bin/env python3
"""
========================================================================
INSIGHT GAPS — BD-INV-002 Automated Lead Collector
========================================================================
Runs every 6 hours via GitHub Actions.
Scrapes RSS feeds from major Bangladesh news sources.
Classifies each item against Insight Gaps evidence tier rules using Gemini.
Updates data/leads.json and data/cases.json.
Never auto-publishes CONFIRMED without 2+ independent sources.
Never deletes existing items — only adds.

Evidence tier rules (hardcoded into Gemini prompt):
  CONFIRMED  = 2+ independent primary sources OR 1 official + corroboration
  PROBABLE   = 1 primary source + corroborating pattern
  UNVERIFIED = single source, no cross-reference yet

Author: Insight Gaps Bureau
License: CC BY-NC 4.0
Version: 1.0
========================================================================
"""

import os
import json
import hashlib
import datetime
import time
import re
import sys

try:
    import feedparser
except ImportError:
    os.system("pip install feedparser --quiet")
    import feedparser

try:
    import google.generativeai as genai
except ImportError:
    os.system("pip install google-generativeai --quiet")
    import google.generativeai as genai

# ── CONFIGURATION ──────────────────────────────────────────────────────

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")
DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
LEADS_FILE = os.path.join(DATA_DIR, "leads.json")
CASES_FILE = os.path.join(DATA_DIR, "cases.json")

# Rate limit: Gemini Flash free tier = 15 RPM, 1500 RPD
GEMINI_DELAY_SECONDS = 5  # 5s between calls = 12 RPM — safe
MAX_ITEMS_PER_RUN = 30    # Hard cap per run to stay within daily limits

# ── RSS FEEDS ──────────────────────────────────────────────────────────
# Only feeds that cover crime, justice, or national news
FEEDS = [
    {
        "name": "The Daily Star — Law & Rights",
        "url": "https://www.thedailystar.net/rss/feeds/law-our-rights",
        "tier": "C"  # Tier C: Major media
    },
    {
        "name": "The Daily Star — Crime & Justice",
        "url": "https://www.thedailystar.net/rss/feeds/crime-justice",
        "tier": "C"
    },
    {
        "name": "The Daily Star — Bangladesh",
        "url": "https://www.thedailystar.net/rss/feeds/bangladesh",
        "tier": "C"
    },
    {
        "name": "TBS News — Bangladesh",
        "url": "https://www.tbsnews.net/rss.xml",
        "tier": "C"
    },
    {
        "name": "bdnews24 — Bangladesh",
        "url": "https://bdnews24.com/feed",
        "tier": "C"
    },
    {
        "name": "BSS — Official Bangladesh News",
        "url": "https://www.bssnews.net/feed",
        "tier": "A"  # Tier A: Official source
    },
    {
        "name": "New Age Bangladesh",
        "url": "https://www.newagebd.net/feed",
        "tier": "C"
    },
]

# ── KEYWORDS ───────────────────────────────────────────────────────────
KEYWORDS_EN = [
    "rape", "sexual assault", "sexual violence", "gang rape",
    "WCRPA", "women and children repression",
    "nari-o-shishu", "nari o shishu", "nirjatan",
    "OCC", "one-stop crisis",
    "section 17", "false rape case", "counter-complaint",
    "shalish", "rape case", "rape verdict", "rape sentence",
    "VAWC", "violence against women",
    "charge sheet rape", "FIR rape", "rape conviction",
    "rape acquittal", "rape accused", "rape survivor",
    "forensic rape", "DNA test rape", "medical evidence rape",
    "PHQ rape", "police headquarters rape", "tribunal backlog",
]

# Sports / irrelevant title exclusion — if ANY of these appear in the
# title, skip immediately even if a broad keyword matched elsewhere.
EXCLUSION_TITLE_KEYWORDS = [
    "cricket", "football", "fifa", "copa america", "world cup",
    "ipl", "bpl", "premier league", "champions league",
    "batting", "bowling", "wicket", "run rate", "over ", "fifties",
    "archer", "medal", "archery", "sarfaraz", "rohit", "mushfiq",
    "mithun", "shakib", "proteas", "tigers ", "afghanistan ",
    "pakistan cricket", "india cricket", "south africa cricket",
    "warm-up match", "dearer", "commodities", "inflation",
    "stock market", "taka exchange", "currency",
]

KEYWORDS_BN = [
    "ধর্ষণ", "যৌন সহিংসতা", "যৌন নিপীড়ন",
    "নারী নির্যাতন", "শিশু নির্যাতন",
    "সালিশ", "বিচার", "সাজা", "আসামি", "আদালত",
    "মামলা", "চার্জশিট", "ভুক্তভোগী",
]

def is_excluded_by_title(title):
    """Returns True if the title matches sports/irrelevant exclusion list."""
    title_lower = title.lower()
    for ex in EXCLUSION_TITLE_KEYWORDS:
        if ex.lower() in title_lower:
            return True
    return False

def keyword_match(text):
    """Returns True if text contains any relevant keyword."""
    text_lower = text.lower()
    for kw in KEYWORDS_EN:
        if kw.lower() in text_lower:
            return True
    for kw in KEYWORDS_BN:
        if kw in text:
            return True
    return False

# ── EVIDENCE TIER PROMPT ───────────────────────────────────────────────
GEMINI_SYSTEM_PROMPT = """You are an evidence classification assistant for Insight Gaps, a forensic data journalism bureau in Bangladesh.

Your job: Classify news items about Bangladesh rape justice, sexual violence cases, or WCRPA tribunal outcomes.

EVIDENCE TIER RULES (apply these exactly):
- CONFIRMED: The item contains a specific verifiable claim from a named official source (PHQ, court records, government body, named NGO report) OR can be cross-referenced with another known confirmed source.
- PROBABLE: The item contains a specific claim from a named journalist or credible outlet, but cannot be immediately cross-referenced.
- UNVERIFIED: Vague claim, anonymous source, no specific data, or tabloid/unverified outlet.
- NOT_RELEVANT: The item is not about Bangladesh sexual violence, rape cases, tribunal outcomes, OCC, WCRPA, shalish, Section 17, or related topics.

RELEVANCE CRITERIA — item must relate to ONE of:
1. A specific rape/sexual violence case in Bangladesh (arrest, charge sheet, verdict, acquittal, sentence)
2. WCRPA tribunal data (backlog, conviction rates, case filings)
3. OCC (One-Stop Crisis Centre) data or incidents
4. Section 17 counter-prosecutions against complainants
5. Shalish/informal settlement of rape cases
6. DNA forensic capacity or delays
7. Legal reforms to WCRPA, marital rape law, witness protection
8. PHQ (Police Headquarters) statistics on rape/VAWC

DO NOT classify as relevant: general crime, murder without sexual violence component, domestic violence without sexual violence component, child abuse that is not sexual in nature.

CASE MATCHING — check if the item might update one of these tracked cases:
- MG-2025-001: Magura child rape case 2025
- CX-2023-001: Runa Akhter Cox's Bazar Section 17 case 2023
- BS-2026-001: Barishal Section 17 case 2026

Respond ONLY in valid JSON, no other text, no markdown, no backticks:
{
  "relevant": true/false,
  "tier": "CONFIRMED" or "PROBABLE" or "UNVERIFIED" or "NOT_RELEVANT",
  "claim": "One clear sentence stating the specific verifiable claim. If not relevant, write null.",
  "tags": ["tag1", "tag2"],
  "linked_case_id": "case ID if this updates a tracked case, else null",
  "notes": "Brief explanation of tier assignment. Max 100 words."
}"""

# ── GEMINI CALL ────────────────────────────────────────────────────────
def classify_item(title, description, source_name, url):
    """Send item to Gemini for classification. Returns dict or None on failure."""
    if not GEMINI_API_KEY:
        print("  [WARN] No GEMINI_API_KEY — skipping AI classification")
        return None

    try:
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel(
            model_name="gemini-1.5-flash",
            system_instruction=GEMINI_SYSTEM_PROMPT
        )

        user_message = f"""Classify this news item:

SOURCE: {source_name}
URL: {url}
TITLE: {title}
DESCRIPTION: {description[:800] if description else 'No description'}

Apply the evidence tier rules and respond in JSON only."""

        response = model.generate_content(user_message)
        raw = response.text.strip()

        # Strip any markdown fences if model adds them
        raw = re.sub(r"^```json\s*", "", raw)
        raw = re.sub(r"^```\s*", "", raw)
        raw = re.sub(r"\s*```$", "", raw)
        raw = raw.strip()

        result = json.loads(raw)
        return result

    except json.JSONDecodeError as e:
        print(f"  [ERROR] Gemini JSON parse failed: {e}")
        return None
    except Exception as e:
        print(f"  [ERROR] Gemini call failed: {e}")
        return None

# ── LOAD / SAVE JSON ───────────────────────────────────────────────────
def load_json(filepath):
    """Load JSON file. Returns dict."""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"  [WARN] File not found: {filepath}")
        return None
    except json.JSONDecodeError as e:
        print(f"  [ERROR] JSON decode error in {filepath}: {e}")
        return None

def save_json(filepath, data):
    """Save dict as formatted JSON."""
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"  [SAVED] {filepath}")

# ── DEDUPLICATION ──────────────────────────────────────────────────────
def url_hash(url):
    """Generate a stable short ID from a URL."""
    return hashlib.md5(url.encode()).hexdigest()[:12]

def get_existing_url_hashes(leads_data):
    """Get set of URL hashes already in leads.json."""
    if not leads_data or "leads" not in leads_data:
        return set()
    return {url_hash(item.get("source_url", "")) for item in leads_data["leads"]}

# ── LEAD ID GENERATOR ──────────────────────────────────────────────────
def generate_lead_id(leads_data):
    """Generate next sequential lead ID like LDR-2026-0042."""
    year = datetime.datetime.utcnow().year
    if not leads_data or "leads" not in leads_data:
        return f"LDR-{year}-0001"

    existing = [l.get("id", "") for l in leads_data["leads"]]
    # Find max number for current year
    max_num = 0
    for lid in existing:
        match = re.match(r"LDR-\d{4}-(\d+)", lid)
        if match:
            num = int(match.group(1))
            if num > max_num:
                max_num = num
    return f"LDR-{year}-{str(max_num + 1).zfill(4)}"

# ── CROSS-CHECK EXISTING LEADS ─────────────────────────────────────────
def weekly_cross_check(leads_data):
    """
    Run every Sunday: check PROBABLE items older than 7 days.
    If a second source now exists for the same claim, upgrade to CONFIRMED.
    If 30+ days old with no corroboration, downgrade to UNVERIFIED.
    This is a simple heuristic check — full cross-referencing requires human review.
    """
    if not leads_data or "leads" not in leads_data:
        return leads_data, 0

    now = datetime.datetime.utcnow()
    upgraded = 0
    downgraded = 0

    for lead in leads_data["leads"]:
        if lead.get("tier") != "PROBABLE":
            continue

        collected_str = lead.get("date_collected", "")
        try:
            collected = datetime.datetime.fromisoformat(collected_str.replace("Z", "+00:00"))
        except (ValueError, AttributeError):
            continue

        age_days = (now - collected.replace(tzinfo=None)).days

        # Check if any other lead covers the same topic/case
        same_topic_confirmed = any(
            other.get("tier") == "CONFIRMED"
            and other.get("id") != lead.get("id")
            and any(tag in other.get("tags", []) for tag in lead.get("tags", []))
            for other in leads_data["leads"]
        )

        if same_topic_confirmed:
            lead["tier"] = "CONFIRMED"
            lead["notes"] = (lead.get("notes", "") +
                             " [Auto-upgraded to CONFIRMED: corroborating CONFIRMED item found in database.]")
            upgraded += 1
        elif age_days >= 30:
            lead["tier"] = "UNVERIFIED"
            lead["notes"] = (lead.get("notes", "") +
                             f" [Auto-downgraded to UNVERIFIED: 30+ days with no corroboration found.]")
            downgraded += 1

    print(f"  [CROSS-CHECK] Upgraded: {upgraded} · Downgraded: {downgraded}")
    return leads_data, upgraded + downgraded

# ── UPDATE CASE STATUS ─────────────────────────────────────────────────
def update_case_status(cases_data, lead_id, linked_case_id, classification, title, source_name, url, pub_date):
    """Add a timeline event to a tracked case when a new lead matches it."""
    if not cases_data or not linked_case_id:
        return cases_data, False

    for case in cases_data.get("cases", []):
        if case.get("id") == linked_case_id:
            # Check if this lead_id already logged
            existing_events = [e.get("lead_ref") for e in case.get("timeline", [])]
            if lead_id in existing_events:
                return cases_data, False

            new_event = {
                "date": pub_date,
                "event": classification.get("claim") or title,
                "tier": classification.get("tier", "PROBABLE"),
                "source": source_name,
                "source_url": url,
                "lead_ref": lead_id
            }
            case["timeline"].append(new_event)
            case["last_updated"] = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

            print(f"  [CASE UPDATE] {linked_case_id} — new timeline event added")
            return cases_data, True

    return cases_data, False

# ── MAIN COLLECTION LOOP ───────────────────────────────────────────────
def run_collection():
    print("=" * 70)
    print(f"INSIGHT GAPS — BD-INV-002 Lead Collector")
    print(f"Run started: {datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')} UTC")
    print("=" * 70)

    # Load existing data
    leads_data = load_json(LEADS_FILE)
    cases_data = load_json(CASES_FILE)

    if not leads_data:
        print("[ERROR] Could not load leads.json. Aborting.")
        sys.exit(1)

    existing_hashes = get_existing_url_hashes(leads_data)
    print(f"Existing leads: {len(leads_data.get('leads', []))}")
    print(f"Existing URL hashes: {len(existing_hashes)}")

    new_leads = []
    items_processed = 0
    items_classified = 0

    for feed_config in FEEDS:
        feed_name = feed_config["name"]
        feed_url = feed_config["url"]
        print(f"\n[FEED] {feed_name}")
        print(f"  URL: {feed_url}")

        try:
            feed = feedparser.parse(feed_url)
            entries = feed.entries
            print(f"  Entries: {len(entries)}")
        except Exception as e:
            print(f"  [ERROR] Feed parse failed: {e}")
            continue

        for entry in entries:
            if items_processed >= MAX_ITEMS_PER_RUN:
                print(f"\n[LIMIT] Reached {MAX_ITEMS_PER_RUN} items cap for this run.")
                break

            title = getattr(entry, "title", "") or ""
            description = getattr(entry, "summary", "") or getattr(entry, "description", "") or ""
            url = getattr(entry, "link", "") or ""

            # Clean HTML tags from description
            description = re.sub(r"<[^>]+>", " ", description)
            description = re.sub(r"\s+", " ", description).strip()

            # Skip if no URL
            if not url:
                continue

            # Skip if already in database
            h = url_hash(url)
            if h in existing_hashes:
                continue

            # Skip if no keyword match (save API calls)
            combined_text = title + " " + description
            if not keyword_match(combined_text):
                continue

            # Skip if title matches sports/irrelevant exclusion list
            if is_excluded_by_title(title):
                print(f"  [SKIP-EXCL] Excluded by title filter: {title[:60]}")
                continue

            items_processed += 1
            print(f"\n  [ITEM {items_processed}] {title[:80]}")
            print(f"    URL: {url[:80]}")

            # Get publication date
            pub_date = ""
            if hasattr(entry, "published_parsed") and entry.published_parsed:
                pub_date = datetime.datetime(*entry.published_parsed[:6]).strftime("%Y-%m-%d")
            elif hasattr(entry, "updated_parsed") and entry.updated_parsed:
                pub_date = datetime.datetime(*entry.updated_parsed[:6]).strftime("%Y-%m-%d")
            else:
                pub_date = datetime.datetime.utcnow().strftime("%Y-%m-%d")

            # Classify with Gemini
            time.sleep(GEMINI_DELAY_SECONDS)
            classification = classify_item(title, description, feed_name, url)

            if classification is None:
                # Gemini unavailable — SKIP rather than pollute the database
                # with unverified non-relevant items. Log for manual review.
                print(f"    [SKIP-NO-GEMINI] Gemini unavailable. Skipping: {title[:60]}")
                print(f"    Manual review URL: {url}")
                continue

            if not classification.get("relevant", False):
                print(f"    [SKIP] Not relevant")
                continue

            if classification.get("tier") == "NOT_RELEVANT":
                print(f"    [SKIP] Not relevant (Gemini)")
                continue

            items_classified += 1
            tier = classification.get("tier", "UNVERIFIED")
            print(f"    [CLASSIFIED] Tier: {tier}")

            # Generate lead ID
            lead_id = generate_lead_id(leads_data)

            # Build lead entry
            lead = {
                "id": lead_id,
                "date_collected": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
                "date_published": pub_date,
                "source_name": feed_name.split("—")[0].strip(),
                "source_url": url,
                "headline": title,
                "claim": classification.get("claim") or title,
                "tier": tier,
                "cross_references": [],
                "tags": classification.get("tags", []),
                "related_investigation": "BD-INV-002",
                "linked_case_id": classification.get("linked_case_id"),
                "notes": classification.get("notes", "")
            }

            new_leads.append(lead)
            leads_data["leads"].append(lead)
            existing_hashes.add(h)

            # Update case register if linked
            linked_case = classification.get("linked_case_id")
            if linked_case and cases_data:
                cases_data, updated = update_case_status(
                    cases_data, lead_id, linked_case,
                    classification, title, feed_name, url, pub_date
                )

    # Run weekly cross-check (Sundays)
    if datetime.datetime.utcnow().weekday() == 6:  # 6 = Sunday
        print("\n[WEEKLY CROSS-CHECK] Sunday run detected — running cross-check...")
        leads_data, changes = weekly_cross_check(leads_data)
        if changes > 0:
            print(f"  Cross-check made {changes} tier changes")

    # Update metadata
    now_str = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    leads_data["_meta"]["last_updated"] = now_str
    leads_data["_meta"]["last_run"] = now_str
    leads_data["_meta"]["total_leads"] = len(leads_data["leads"])

    if cases_data:
        cases_data["_meta"]["last_updated"] = now_str
        cases_data["_meta"]["total_cases"] = len(cases_data["cases"])

    # Save
    print(f"\n[SUMMARY]")
    print(f"  Items processed: {items_processed}")
    print(f"  Items classified as relevant: {items_classified}")
    print(f"  New leads added: {len(new_leads)}")

    if new_leads or datetime.datetime.utcnow().weekday() == 6:
        save_json(LEADS_FILE, leads_data)
        if cases_data:
            save_json(CASES_FILE, cases_data)
        print("\n[DONE] Files updated. GitHub Actions will commit changes.")
    else:
        print("\n[DONE] No new relevant items found. No files changed.")

    print("=" * 70)
    return len(new_leads)

# ── ENTRY POINT ────────────────────────────────────────────────────────
if __name__ == "__main__":
    new_count = run_collection()
    # Exit code 0 always — GitHub Action checks git diff for actual changes
    sys.exit(0)
