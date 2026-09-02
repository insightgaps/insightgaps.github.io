# Insight Gaps Bureau — Owner Decisions Required (Phase 3)

Only decisions that genuinely require editorial/strategic authority appear here. Routine engineering choices were made autonomously (documented in `REPORT_IMPLEMENTATION_COMPLETION.md`). Each entry: QUESTION · why it cannot be inferred · default recommendation · consequences of each option. **Nothing below has been implemented; the site content is untouched pending your calls.**

---

## D-1. Blood Routes: log the silent correction (P0)

- **QUESTION:** Should the corrections log record the 2026-06-08 change of the night-crash statistic from 97.13% to 41.56% (commit `527d0a4`), and should `has_correction`/`date_revised` be set on BD-INV-001?
- **WHY IT CANNOT BE INFERRED:** What counts as a correction vs a technical fix under your doctrine is an editorial judgment. The evidence: a published headline statistic was independently checkable, wrong, derived from data the bureau knew was 95% synthetic padding, stayed live ~11–13 days, and was fixed silently while the public log says "No corrections issued." Your published policy says corrections are "noted directly on the investigation page and added to this log" and the status field is "updated to corrected on the same day."
- **DEFAULT RECOMMENDATION:** Log it. The evidence that a correction-class change occurred is unambiguous (the OS pipeline itself retracted the claim citing "synthetic padding artifacts" on 2026-06-03). Logging it converts your weakest credibility moment into proof the doctrine works.
- **CONSEQUENCES:** *Log it:* doctrine upheld; the record shows self-correction — the strongest possible trust signal. *Don't:* any external reviewer who finds `527d0a4` in git can state accurately that the bureau corrected a false headline number without logging it — precisely what the corrections page promises never happens.

## D-2. Blood Routes: the 351 headline (P0)

- **QUESTION:** The Eid headline (351 deaths, 15 days, March 2026) has no archived source in any repository (the public dataset has zero 2025/2026 records), and it replaced "312 deaths/2025" on publication day. Archive/cite the RSF/BJKS 2026 Eid reports, annotate the hero with its external-source basis, or re-basis the headline?
- **WHY IT CANNOT BE INFERRED:** Whether the RSF/BJKS reports exist in your possession, and how you source headline numbers, is editorial. What is established: the number is currently unverifiable by any reader, and the superseded 29%-YoY figure that survived in the 2025 chart description is arithmetically wrong ((312−262)/262 = 19.08%, not 29%).
- **DEFAULT RECOMMENDATION:** (a) Obtain and archive the two NGO reports into the evidence system; (b) label the hero's source basis (implemented infrastructure supports this — the label text needs your data); (c) fix the 29% figure — that one is arithmetically wrong regardless of sourcing, but the replacement text is editorial.
- **CONSEQUENCES:** *Archive + label:* headline becomes verifiable-in-principle; standard practice. *Leave as-is:* the investigation's most visible number is unverifiable, and its predecessor figure is published-and-wrong — a standing factual error.

## D-3. Evidence artifacts: publish or de-link (P1)

- **QUESTION:** For each of the four referenced-but-unavailable artifacts — BD-INV-002 master evidence file (exists, private, in OS repo), osm_schools.geojson (exists, private, OS repo), LeadBelt MasterDataset v5 csv/xlsx (described as publication-ready in your own decision memo but **in no repository**), PP master dataset xlsx (nowhere) — publish the file, or de-link and mark private-held?
- **WHY IT CANNOT BE INFERRED:** Evidence-publication involves source protection and editorial exposure judgments only you can make. The Lead Belt v5 file's actual whereabouts is unknown to me (your decision memo says it was completed).
- **DEFAULT RECOMMENDATION:** Publish `osm_schools.geojson` (a public OSM snapshot — zero source risk, high verification value). For the BD-INV-002 master file, publish a provenance-preserving digest (summary sheets, not raw case records) pending your source-protection review. For the two missing files: de-link with status "not in repository" (the evidence page now renders status labels either way — implemented).
- **CONSEQUENCES:** *Publish:* the evidence system starts delivering verification, which is its entire purpose. *De-link only:* honest, but the "reader can verify" promise stays unfulfilled for the flagship investigation. *Do nothing:* five public 404s plus a false methodology note (D-7) remain the site's most visible integrity gap.

## D-4. Dhaka Slum Fires: publication status (P0 cluster)

- **QUESTION:** Given the audit findings (fabricated data lineage — the registered raw CSV's logged SHA-256 is the hash of an empty file; the "cleaning script" hardcodes the dataset; the central legal claim carries no case citation in public; hero 16.2% metric has no data; n=4 "clear correlation" language; empty governance templates; AI-signed sign-off): keep published as-is, publish with annotations (limitations section + sourcing disclosures + restored claim drawer), or unpublish pending the raw evidence?
- **WHY IT CANNOT BE INFERRED:** This is the bureau's core editorial call about its own work. The audit establishes the verification gaps; whether the investigation's sourcing exists privately (and merely wasn't archived) or never existed is knowable only by you.
- **DEFAULT RECOMMENDATION:** Publish-with-annotations (middle path): restore the claim drawer (done — it's presentation), surface the draft's already-written Limitations section (done — surfacing your own text), and you supply: the writ petition citation (Writ No. 9763 of 2008 appears in your own source-search notes), and either the underlying land-value/sales records or a caveat on the +250% figure. If the underlying records cannot be produced, the honest options are a prominent sourcing-disclosure notice or unpublishing.
- **CONSEQUENCES:** *Annotate:* investigation becomes defensible-if-imperfect; consistent with how you handled Lead Belt (which you delayed and fixed — the precedent is your own). *Leave as-is:* it remains the one investigation that fails its own tier standard on every checkable axis. *Unpublish:* safest against external challenge, but loses the work; homepage suppression (already in place) suggests half of this decision was already made silently — making it explicit either way is the actual decision.

## D-5. Homepage suppression of slum-fires: policy or revert (P2)

- **QUESTION:** Commit `69f4b13` (2026-06-07) excluded dhaka-slum-fires from the homepage while leaving it in the sitemap/index/archive; the exclusion now lives in build code with no documented rationale. Make it an explicit manifest-level status (e.g., `featured: false` + a documented reason), or revert it?
- **WHY IT CANNOT BE INFERRED:** The original motive is undocumented; institutionalizing vs removing an undocumented decision are both editorial.
- **DEFAULT RECOMMENDATION:** Convert to explicit manifest field with a one-line documented rationale (e.g., "pending evidence completion"), and stop filtering in code. Either direction of the display decision itself is yours.
- **CONSEQUENCES:** *Explicit:* honest and maintainable. *Revert:* the newest investigation gets homepage visibility (with D-4 unresolved, that's risky). *Leave as-is:* a hard-coded slug exclusion in production build code — the pattern the Phase-1 audit called "institutionalized stealth delisting."

## D-6. Corrections backfill for qualifying historical changes (P1)

- **QUESTION:** Beyond D-1, should the log record: (a) the Impunity Machine's post-publication denominator disclosures (`36177f6`), (b) the Lead Belt language-hardening changes, (c) the slum-fires number changes between the reverted 2026-05-28 version and the 2026-06-03 republication (+420%→+250%, +310%→+150%)?
- **WHY IT CANNOT BE INFERRED:** Classification of each change (correction / editorial update / technical fix) is the editor's call under your own doctrine. Evidence for each is documented in `REPORT_FORENSIC_AUDIT_PHASE_3.md` §13.
- **DEFAULT RECOMMENDATION:** Log (a) as a clarification-entry (it changed how a published chart should be read); classify (b) as pre-publication hardening (the investigation's manifest date postdates it in practice); (c) is covered by D-4's annotation path — the same-day revert of v1 gives partial cover, but the manifest binding the old date to new content needs a date fix regardless.
- **CONSEQUENCES:** *Backfill:* the corrections page becomes non-empty — which reads as maturity, not weakness, in this genre. *Don't:* the gap between doctrine text and git record remains findable by anyone.

## D-7. Property Preservation: classification + the false methodology note (P1)

- **QUESTION:** (i) What is this work — journalism, analytical research tooling, or consulting/product software (its final home follows from this: keep in-tree, subdomain, or separate product)? (ii) Independently: the published methodology note ("268 work order records spanning May to December 2025, operator-provided accounting ledgers") contradicts the actual dataset (480 records, Nov 2025–Jun 2026, headed "Auto-generated EPCS dataset"). Rewrite the note, restore a matching dataset, or retire the note?
- **WHY IT CANNOT BE INFERRED:** Intent (i) is strategic; (ii) involves what the underlying operator data actually is (the "auto-generated" header may itself be misleading about a real anonymized dataset — only you know).
- **DEFAULT RECOMMENDATION:** Fix the methodology note to describe the real artifact (or describe it accurately as a demonstration dataset if that's what it is) regardless of the classification decision — a false methods description is a defect under any classification. For (i): default remains relocation to a tools home, but no move was made (WAIT honored).
- **CONSEQUENCES:** *Fix note only:* data-integrity defect resolved; classification can wait. *Leave:* a published methods statement that any reader with the data can falsify in one query — worse for a bureau selling forensic rigor. Note: the "less than half of invoiced value reaches the bank" claim also reads oddly against the data's 53.9% collected ratio — flag, not fixed.

## D-8. Lead Belt: hero framing and metadata (P2)

- **QUESTION:** (i) Should the hero/meta "39,875 children at extreme risk" adopt your own audit's bounds (24,650–50,750) and unique-count figure (33,275)? (ii) Should the manifest date (2025-01-01) be corrected to the actual publication date (pipeline activity 2026-05/06)? (iii) The "closest school 59 metres" narrative vs the embedded data's 14 m record (BD-7303): contextualize the 59 m claim (it's about the featured Kamrangir Char school) or amend?
- **WHY IT CANNOT BE INFERRED:** All three reframe published claims — editorial acts. The evidence for each is in the audit (LB-5, date conflict, LB-3).
- **DEFAULT RECOMMENDATION:** (i) Pair the hero number with the range and "projection" language from your own methodology page (the text already exists — it's a framing choice, not new content). (ii) Yes — date metadata is factual. (iii) Scope the 59 m claim to the featured site in one clause.
- **CONSEQUENCES:** *Adopt:* the investigation's strongest work (the honest reconciliation) finally appears at the point of maximum reader attention. *Don't:* the hero still outruns your own published methodology — the exact pattern your Lead Belt audit was written to prevent.

## D-9. Impunity Machine: source-count basis + mobile chart repair scope (P2)

- **QUESTION:** (i) Publish the basis for the 91-source count (an archived `sources_clean.json` exists in the OS repo)? (ii) The chart text at 0.42–0.55rem is unreadable on mobile — approve a presentation-only repair pass on the report's inline styles (content unchanged), or defer to a full report redesign?
- **WHY IT CANNOT BE INFERRED:** (i) is an evidence-publication call (D-3 family). (ii) touches a published page's visual identity — you may want it bundled with future redesign rather than incrementally patched.
- **DEFAULT RECOMMENDATION:** (i) Publish the source list (redacted as needed for source protection). (ii) Approve the incremental pass — it changes no content, and unreadable charts are an accessibility failure either way.
- **CONSEQUENCES:** *Approve both:* flagship investigation becomes fully checkable and readable. *Defer (ii):* mobile readers cannot read the charts until a redesign lands (a11y failure persists by choice).

## D-10. AI-training stance (carried from Phase 1.75)

- **QUESTION:** Resolve the CC BY 4.0 license vs `ai-train=no` contradiction: keep the robots training-refusal and document it as overriding the license default for machine training, or align the two?
- **DEFAULT RECOMMENDATION:** Keep refusal; document on the trust site. Currently robots.txt is generated plain (`Allow: /`) — restoring the Cloudflare content-signals block is a one-line config change once decided.
- **CONSEQUENCES:** *Decide:* coherent public stance either way. *Don't:* license says one thing, robots says another (or nothing, currently).

## D-11. Tier taxonomy (P3)

- **QUESTION:** Manifests use tier labels ("Visual Data", "Visual Spatial", "Spatial Overlay") from a taxonomy that is not the one published on `/trust/methodology/` ("Document-Heavy", "Data-Driven", "Source-Driven"). Align the labels to the published taxonomy (which changes what each tier obligates — several labels would shift), or publish the taxonomy the manifests actually use?
- **DEFAULT RECOMMENDATION:** Publish the taxonomy actually used, with per-tier obligations — it's your operative standard and the audits read against it more naturally.
- **CONSEQUENCES:** Either alignment works; the current state means no reader can check a tier's obligations against the work. (Labels are editorial; not changed by this phase.)
