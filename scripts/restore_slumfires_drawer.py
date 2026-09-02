"""Phase 3: restore slum-fires claim drawer (from 9e73d50) with honest per-claim status."""
from pathlib import Path

p = Path(__file__).resolve().parent.parent / "content/pages/slum-fires.body.html"
t = p.read_text(encoding="utf-8")

if "js-drawer" in t:
    print("drawer already present; nothing to do")
    raise SystemExit(0)

drawer_markup = """
  <!-- CLAIM VERIFICATION DRAWER (restored from the 2026-06-03 publication build, 9e73d50) -->
  <div class="backdrop" id="js-backdrop"></div>
  <div class="drawer" id="js-drawer" role="dialog" aria-modal="true" aria-label="Claim verification drawer">
    <div class="drawer__header">
      <div class="drawer__title">Evidence Verification Desk</div>
      <button class="drawer__close" id="js-drawer-close" aria-label="Close verification drawer">&times;</button>
    </div>
    <div class="drawer__body">
      <div class="drawer-field">
        <div class="drawer-field__label">Claim Reference</div>
        <div class="drawer-field__val" id="js-drawer-ref">--</div>
      </div>
      <div class="drawer-field">
        <div class="drawer-field__label">Claim Text</div>
        <div class="drawer-field__val" id="js-drawer-text" style="font-style: italic;">--</div>
      </div>
      <div class="drawer-field">
        <div class="drawer-field__label">Verification Status</div>
        <div class="drawer-field__val">
          <span class="drawer-badge" id="js-drawer-status">--</span>
        </div>
      </div>
      <div class="drawer-field">
        <div class="drawer-field__label">Named Sources (artifacts not yet publicly archived)</div>
        <div class="drawer-field__val" id="js-drawer-sources">--</div>
      </div>
    </div>
  </div>

  <script>
  (function () {
    'use strict';
    // Claim ledger restored from the 2026-06-03 build with one honesty repair:
    // verification status is per-claim data instead of a hardcoded "Confirmed"
    // badge. Statuses reflect the 2026-09-02 forensic audit: sources are named
    // but source artifacts are not publicly archived; some claims await owner
    // decisions.
    var claimLedger = {
      "1":  { ref: "CLM-SFI-001", status: "SOURCED \\u2014 ARTIFACT NOT ARCHIVED",
              text: "Dhaka occupies 306.4 sq km and supports a population of over 10.2 million. Korail covers 90+ acres acquired by BTCL in 1961 and transferred to PWD in 1990.",
              sources: "Dhaka City Corporation Census Logs, Lands Ministry Cadastral Map Registry, BTCL Corporate Asset Registry." },
      "2":  { ref: "CLM-SFI-002", status: "SOURCED \\u2014 ARTIFACT NOT ARCHIVED",
              text: "Between 1975 and 2026, Dhaka's wetlands and water bodies declined by 16.2%, and cultivated land shrank by 34.1%.",
              sources: "GIS Satellite remote sensing land classification map layers (1975\\u20132026)." },
      "3":  { ref: "CLM-SFI-003", status: "SOURCED \\u2014 ARTIFACT NOT ARCHIVED",
              text: "The average fire mortality rate in Dhaka is 174 deaths per 100 fires, and annual property damage across the city corporations exceeds BDT 4 billion.",
              sources: "Bangladesh Fire Service and Civil Defence (FSCD) Annual Operations & Damage Audit Reports." },
      "4":  { ref: "CLM-SFI-004", status: "IN PUBLISHED DATASET",
              text: "Korail population density is 87,606 people per square kilometer, restricting residents to an average of only 78 square feet of living space per capita.",
              sources: "Community Census Spatial mapping survey and local NGO housing profiling statistics." },
      "5":  { ref: "CLM-SFI-005", status: "SOURCED \\u2014 ARTIFACT NOT ARCHIVED",
              text: "Fire on November 25, 2025 raged for over 16 hours, destroying 1,500 shanties, 400 commercial shops, and 1,200 industrial sewing machines.",
              sources: "Bangladesh Red Crescent Society (BDRCS) Situation Report 1: Korail Slum Fire incident." },
      "6":  { ref: "CLM-SFI-006", status: "SOURCED \\u2014 CITATION PENDING OWNER DECISION",
              text: "126 residents, including 36 freedom fighters, filed High Court writ petition. Eviction bypass fires in August 2019, January 2020, and March 2020 destroyed 1,000 shanties.",
              sources: "Supreme Court of Bangladesh Writ Registry, Ain o Salish Kendra (ASK) and BLAST Litigation Records. Writ Petition No. 9763 of 2008 is referenced in the investigation's source log." },
      "7":  { ref: "CLM-SFI-007", status: "IN PUBLISHED DATASET",
              text: "NHA Flat Project sizes: 800, 1,350, and 1,550 square feet.",
              sources: "National Housing Authority (NHA) Mirpur Flat Project Specification sheets." },
      "8":  { ref: "CLM-SFI-008", status: "SOURCED \\u2014 ARTIFACT NOT ARCHIVED",
              text: "Sattola Slum houses 36,000 people across 8,000 households, with 2,450 households evicted in August 2010.",
              sources: "Ministry of Health and Family Welfare Land allocation sheets, BLAST litigation briefs." },
      "9":  { ref: "CLM-SFI-009", status: "SOURCED \\u2014 ARTIFACT NOT ARCHIVED",
              text: "Fire of March 12, 2025 broke out at 3:40 AM, requiring 8 firefighting units and 2 hours to control.",
              sources: "Fire Service and Civil Defence Incident Response sheet logs." },
      "10": { ref: "CLM-SFI-010", status: "SOURCED \\u2014 ARTIFACT NOT ARCHIVED",
              text: "On February 19, 2023, the Tk 1,012 crore Mirpur-Kalshi Flyover opened, widening the corridor to 6 lanes.",
              sources: "DNCC flyover project layout and DNCC finance division audit." },
      "11": { ref: "CLM-SFI-011", status: "SOURCED \\u2014 ARTIFACT NOT ARCHIVED",
              text: "On December 17, 2025, the 60-feet link road opened, clearing structures on plots 80800 and 40456.",
              sources: "Lands Ministry cadastral and municipal link road alignment maps." },
      "12": { ref: "CLM-SFI-012", status: "IN PUBLISHED DATASET (PARTIAL)",
              text: "Fire on May 25, 2026 at 7:23 PM destroyed 1,200 structures, requiring 15 fire units, 123 firefighters, and 15 water vehicles for 2 hours, clearing plots for a 7.40 km RCC drain and displacing 3,500 residents.",
              sources: "FSCD regional response logs, DNCC Kalshi drainage reconstruction project specifications." },
      "13": { ref: "CLM-SFI-013", status: "IN PUBLISHED DATASET (PARTIAL)",
              text: "Land value appreciation spikes: Kalshi Slum (+250%, 0m, 800m), Korail (+180%, 0m, 500m), Sattola (+150%, 0m, 400m), Chalantika (+120%, 900m).",
              sources: "Calculated via multi-site spatial proximity analysis overlays using district land registration records." }
    };

    var drawer = document.getElementById('js-drawer');
    var backdrop = document.getElementById('js-backdrop');
    var closeBtn = document.getElementById('js-drawer-close');
    if (!drawer || !backdrop || !closeBtn) return;

    function openDrawer(claimId) {
      var claim = claimLedger[claimId];
      if (!claim) return;
      document.getElementById('js-drawer-ref').textContent = claim.ref;
      document.getElementById('js-drawer-text').textContent = '\\u201C' + claim.text + '\\u201D';
      document.getElementById('js-drawer-status').textContent = claim.status;
      document.getElementById('js-drawer-sources').textContent = claim.sources;
      drawer.classList.add('open');
      backdrop.classList.add('show');
      closeBtn.focus();
    }

    function closeDrawer() {
      drawer.classList.remove('open');
      backdrop.classList.remove('show');
    }

    document.querySelectorAll('.claim-badge').forEach(function (badge) {
      badge.addEventListener('click', function (e) {
        e.preventDefault();
        openDrawer(badge.getAttribute('data-claim'));
      });
    });

    closeBtn.addEventListener('click', closeDrawer);
    backdrop.addEventListener('click', closeDrawer);
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') closeDrawer();
    });
  }());
  </script>
"""

t = t.rstrip() + "\n" + drawer_markup
p.write_text(t, encoding="utf-8")
print("drawer restored with per-claim status ledger")
