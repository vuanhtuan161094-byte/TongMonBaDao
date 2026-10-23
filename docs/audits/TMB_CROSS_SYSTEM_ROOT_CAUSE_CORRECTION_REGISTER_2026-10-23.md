# TÔNG MÔN BÁ ĐẠO — FORENSIC SYSTEM-OF-SYSTEMS DESIGN AUDIT & REPAIR REGISTER

**Date:** 2026-10-23. **Status:** source-backed audit, **DOCS REPAIRED / GAMEPLAY NOT REPAIRED**. No Godot execution in this documentation pass; no CODE/CI/FULL/merge.  
**Repo/source:** `main` at `29b5fba448b0178cb520a4ada44b375b4b934e31` for locked docs and P2 implementation; PR #24 `4d08984f044bfa29a98070c8d68ee5a155256d3a` for CARE single-hunt content; PR #25 `710137c0e3976e685613a86692e5eb128b8d3c62` for P3.2 integration. Later heads must be freshly verified.  
**Correction contract:** [TMB_CROSS_SYSTEM_REALM_CONTENT_INTEGRITY_CONTRACT_2026-10-23.md](../design/TMB_CROSS_SYSTEM_REALM_CONTENT_INTEGRITY_CONTRACT_2026-10-23.md).

## 1. Findings by evidence, severity and scope

| ID | Severity | Source evidence | Exact mismatch / risk | Safe correction | Gate |
|---|---|---|---|---|---|
| **X-01** | **P0 DESIGN** | `DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md` locked formula, `CombatStatsV2.derive`, assistant BD01A | `G(r,f)` correctly scales Realm/Body Core; assistant used `3*G(r,1)` as though one named Thanh Thiết Kiếm is automatically 30 rank-specific items | retire cross-rank named item cloning; authored distinct equipment template/tier/sources | BD01/BD01A corrected in docs; CODE NOT CHANGED |
| **X-02** | **P0 CONTENT** | `WEAPON_EQUIPMENT_V2_REALM_MAP_SET_MATRIX.md`, `ResourceRegistry` | Old doc outlines *proposed* 30 maps/300 clusters; early actual content is only a few low-level IDs; high-realm materials and gear cannot be assumed live | 30-row content coverage table, rank-item family identity and explicit ID/producer/consumer requirements; no generated fake IDs | data authoring needed |
| **X-03** | **P0 ECONOMY** | `MonsterCatalogueV2`, `HuntingMapV2`, `B3PilotContent` | 3 region pilot, many monsters `loot_ready=false`, CARE one wolf hide; no full grade/rank source table for unique gear, herbs, books, boss materials | explicit legal source table per region/monster/grade (drop→Warehouse→consumer) plus anti-softlock/no-free-loot contracts | future content registry/code |
| **X-04** | **P0 EQUIPMENT** | `equipment_system.gd` 3 P2 slots/3 quality grades + shop/purchase; `WEAPON_EQUIPMENT_V2_SPEC.md` 10/12/sets | P2 gear shop, old `owner_id` and `combat_power` incompatible with V2 Sect-owned unique items / CombatStatsV2 true channels | version-aware old UID migration, V2 item schema/unique registry and no private transfer fee; no forced talisman→pendant conversion | deferred CODE packet |
| **X-05** | **P0 ALCH** | `AlchemyRecipeRegistry` main, CARE pill packet, `P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md` | Pilot Hồi Xuân main 3 herbs; separate CARE Tu Khi 2 herb+1 grain; no complete realm-tier medicine chain, exact effect costs/drop ingredients | source-aware medicine recipe IDs, fixed effects + cap and tier authoring; preserve old pill usability by explicit data | docs only now |
| **X-06** | **P0 TECH** | `TechniqueSystem.MAX_LEARNED_TECHNIQUES=3`, `MAX_TECHNIQUE_LEVEL=5` vs `TECHNIQUE_V2_SPEC` | P2 coding reflects old learned cap and level mechanics; V2 learned library, 1 main+2 aux, transmission/mastery & successor not implemented there | preserve legacy behavior, stage V2 schema with old-save migration, no forced one-to-one rarity/rank | requires CODE authorization |
| **X-07** | **P1 SKILLS** | `COMBAT_SKILLS_V2_SPEC.md`, Combat V2 pilot | 3-wave skill lineage is designed, but no authored per-rank manual/skill source/visual/action coverage; affixes referring to nonlive skills are fake | curated skill/action/teaching drops + proper runtime consumer gate + skill family generations | content authoring/QA |
| **X-08** | **P1 BODY** | `BODY_CULTIVATION_V2_SPEC.md`, `ResourceRegistry` body materials | Body training track independent; no complete 30-realm gate/material/economy source loop evidenced | authored Body gate material sources and alternate repeatable pathways, no generic monster kill gives unapproved Body XP | author each chapter |
| **X-09** | **P0 XP OWNERSHIP** | older `P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md` %next-stage proposal; newer owner direct-kill fixed Tu Vi design 2026-10-23 | stale docs suggest alternative XP law; direct kill not code; risk double XP via Tinh Nguyên or legacy WIN payouts | obey newer explicit direct fixed XP per eligible participant once/kill; Tinh Nguyên material only unless distinct authorized consumption | B3-XP01 future CODE |
| **X-10** | **P1 BOSS** | cooperative Boss design, existing single world and pilot MonsterCatalogue | one Boss shared HP/loot and causal multi-role support has design, threshold not fixture locked; Stone sect-personal split 60/40 unapproved | role credit & retreat/late join empirical fixture, no last hit, one Sect loot; avoid invented Boss loot table | separate design/QA |
| **X-11** | **P1 WORKFLOW** | `P3_7_BUILDING_TREE_SPEC`: Luyện Khí Điện Lv1 basic, Lv30 monster material; `EquipmentSystem` older `tinh_lang_giap` hide recipe | moving P2 hide armor into V2 Lv1 forge may silently bypass designed Lv30 gating | preserve P2 compatibility; decide V2 starter armor material or explicit exception; no stealth rule change | owner policy needed |
| **X-12** | **P1 MAP** | `WEAPON_EQUIPMENT_V2_REALM_MAP_SET_MATRIX.md` explicitly projection; `HuntingMapV2.LEVELS` five grades; `REALM_LADDER_V2_SPEC` 10 floors; map 10 clusters previous approval | easily confuse 5 encounter difficulty levels vs 10 area clusters vs 10 floors vs 30 realms | assign different typed fields and labels; 30 primary maps remain proposed, not canonical implementation | source schema validation |
| **X-13** | **P0 UX** | PR25 P3.2 inherits P3.1's `_build_shell` legacy, adds new CARE; `p3_2_landscape_sect.tscn` root bare `Control` | game UI looks mixed even with 13/13 gameplay tests | unified native presentation composition from source snapshots; owner visual acceptance separate | Codex UI owner future CODE |
| **X-14** | **P1 NUMBERS** | V2 foundations raw, legacy `_score()*100`, render screen | numeric labels can misrepresent thousands; all stat/loot/recipe values must link to source data | V2-only formatter + chart separately normalized, test original vs rendered vs save | separate narrow UI CODE |
| **X-15** | **P0 GOVERNANCE** | many long design docs, old status banners, docs branches plus layered CODE PRs; AGENTS authority precedence | previously approved BASE curves still described OPEN in older Oct08 file; unsupported probabilities from assistant appeared "ready"; ambiguous source/model | explicit precedence ledger, owner-lock/PROPOSAL/source/code/QA states, and data integrity gate before declaring playable content complete | X0 docs, future validator |

## 2. Fixed cross-system law: equipment family per realm, NOT all consumables/techniques numerically chained

- **Source-derived (owner):** 30 named Tu Vi realms with 10 floors; separate 30×10 Body; equipment `equipment_realm_index 1..30`, 10 ordinary slots + 3 Fu +2 treasures, 12 grade capacity, 24 set lineages.
- **Explicit latest owner correction:** each realm should have *its corresponding type/family* of equipment and loot; low-tier named gear is not scaled as if it were high-tier item. This does **not** imply only one item total, one per-monster guaranteed drop, exactly 30 maps, or a required one-to-one technique/pill identity.
- **Medicine:** old pills remain usable unless explicit authored restriction; source effect is fixed if authored fixed; satiety shared 1M/day.
- **Technique:** can persist across realms; rarity `pham/huyen/dia/thien/tien/than` separate from equipped item 12 grades and realm30; V2 transmission and mastery independent.
- **Skills:** authored family generational waves Nhân/Tiên/Thần, do not auto-refresh full moves per 30 realms.
- **Work/economy:** no `resource power` currency and no fabricated "higher" item from name equality; ingredient IDs/milesstone cost/quantity real.
- **Save:** unique item UID and stackables separated; one receipt exactly once; old P2 saves remain loadable without converting `combat_power` into Attack.

## 3. How to prevent recurrence (mandatory review before any BD-01/other content CODE)

For every *new* item, herb, book, monster, skill, affix or recipe row, create a compact **producer/consumer evidence sheet**:
1. `entity_id`, kind, authority and version, status: LOCKED STRUCTURE / AUTHORED DATA / LIVE CODE / TESTED / VISUAL ACCEPTED / PROPOSED.
2. `realm_or_body_band`, grade, eligibility and unit. For techniques, document explicitly **no hard realm mapping** unless prerequisites say otherwise.
3. Source `region/cluster/monster/normal|elite|boss/forge/field/market/manual` and exact probability/quantity where approved.
4. Destination (Sect Warehouse stack; unique item registry; learned technique or personal progression receipt).
5. First live consumer (craft/equip/medicine use/learning/Body breakthrough), actual resource debit + clock/job/satiety.
6. Numeric benchmark vs canonical Combat V2 and correct current HP fraction; early+mid+late comparisons including baseline no-gear.
7. At least one repeatable source for every mandatory progress; no impossible recipe/source circular dependency or unapproved hard map locks.
8. Exact save/reload, offline, double callback, conflicting job, migration/legacy and screen-display tests.
9. Art provenance, if any, not fictitious Source A school actor/Spine clip.

**If any mandatory foreign key or producer→consumer link is missing, status remains CONTENT BLOCKED. Do not silently fill with dummy rewards or assign a default r=1 for all.**

## 4. Priority and owner approvals

**Already owner-locked:** S2 + F1 + Q1, 30×10 realm/body, item tier1..30, 10 slots/12 grades/24 sets, single Warehouse/owner, CARE satiety 1M and Injury120, distinct techniques/skills. **Never ask to redo.**

**OPEN, not yet approved:** exact number of equipment families/templates per realm and their names, mapping between P2 item recipes and r01/02/03, material/source tables, Grade12 R12=0.2% (assistant suggestion only), forge time 10 ticks (assistant suggestion only), specific item base stats, which loot comes direct vs is forged, exact pill tier/effects, technique/skill drop/teacher availability, full Body gate sources, Boss credit thresholds and Stone split.

**Recommendation**: first design and test one R01→R02→R03 **complete content chain** with true ID provenance; only then extend to 30 realms using an authoring matrix and scripted validator. Do NOT mass-generate gameplay content or 300 zones from the theme projection. Deliver fixed/code milestones separately. No change to PR #24/#25 while UI migration runs.

## 5. Current completed scope vs remaining

- **DONE THIS DOCUMENT PASS:** evidence-backed forensic cross-system inventory, normalizing relationship definitions, 30 named row coverage ledger, correction banners for BD01/BD01A.
- **NOT DONE:** actual fully authored 30×10 item/pill/technique/skill/monster content; implementing new registry/recipes, real V2 equipment/technique migrations, simulating balance, Godot tests, Android/Windows physical UAT. No claim "whole game fixed" from docs.
- **NEXT DESIGN:** X1 author first 3 stage content fixture with known existing pilot resource IDs and proposed missing IDs clearly marked, validate producer/consumer cost loop and present genuine player choices.
- **NEXT CODE WHEN AUTHORIZED:** narrow data validation, then a single rank-specific drop→forge/pill→equip/use→Combat stat/XP UI/save path without touching CARE authority or Codex UI owner.
