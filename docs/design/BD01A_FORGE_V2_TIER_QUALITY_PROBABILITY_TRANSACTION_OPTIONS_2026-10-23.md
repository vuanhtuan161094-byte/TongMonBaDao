# TÔNG MÔN BÁ ĐẠO — BD-01A / V2: CÔNG THỨC, 30 BẬC, 12 PHẨM, XÁC SUẤT, GIAO DỊCH RÈN

> **CORRECTION / OWNER OVERRIDE 2026-10-23:** Earlier sample numbers `+3×G(r,1)` Thanh Thiết Kiếm and `+20×G(r,1)` Tinh Lang Giáp across all 30 ranks are **WITHDRAWN AS EQUIPMENT GENERATION**, including the numerical comparison table below. **Do not code, balance or author item IDs from that table.** Different cultivation realms need their own authored equipment families/templates, real loot/recipe/source and use constraints. `G(r,f)` remains valid ONLY as locked Realm/Body Core and external *comparison reference*. See [cross-system content contract](TMB_CROSS_SYSTEM_REALM_CONTENT_INTEGRITY_CONTRACT_2026-10-23.md). The E0/E1/E2 grade distributions, Chí Tôn probability, 10-tick work time and all material-input V2 proposals are still **UNAPPROVED** until source/sink audit. S2+F1+Q1 are owner-locked.

**Date:** 2026-10-23; **OWNER LOCKED THIS TURN:** **S2 + F1 + Q1** (authority for design direction, NOT permission to code).  
**State:** all new numeric coefficients below are **PROPOSED / TO SELECT**, with source-derived examples explicitly labeled. Only documentation may be committed to branch `docs/bd01-equipment-deep-design-20261023`. Do not change main, PR #24, PR #25, Source A, gameplay/tests, CI or FULL.
**Authoritative design references:** `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md` (Oct09 locked), `docs/COMBAT_STATS_V2_SPEC.md`, `docs/WEAPON_EQUIPMENT_V2_SPEC.md`, `docs/EQUIPMENT_SETS_V2_SPEC.md`, `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md`, `docs/P3_7_BUILDING_TREE_SPEC.md`; source `CombatStatsV2`, `DiscipleCombatLoadoutV2`, `EquipmentSystem`, `WarehouseSystem`, `WorkforceSystem`. This doc supersedes only earlier **assistant proposals**, not older owner-locked data.

## 1. No new character base-stat lock required

The Oct09 **LOCKED and already coded** Combat V2 baseline is:
`G(r,f)=1.65^(r-1)*1.03^(f-1)`,
`RealmHP/ATK/DEF = (100,20,12)*G(Cultivation)`,
`BodyHP/ATK/DEF = (90,3,7)*G(Body)`,
`PotentialFactor=1+.0005*CurrentPotential`,
`Core=(Realm+Body)*PotentialFactor`;
`FinalPrimary=(Core+unrelated_flat_sources)*(1+same_channel_percent_add)`.
Direct eligible basic hit with no other modifiers has defense factor `2*ATK/(2*ATK+effective_DEF)`. `CombatStatsV2.derive()` is the current code authority; it uses proper channel names/modes, source IDs and duplicate detection. No gear input may secretly modify `combat_power` into V2 Attack. No flat gear is pre-multiplied by Potential.

**Core values below are SOURCE-derived. IMPORTANT: the proposed +Sword/+Armor rank-scaled columns are RETIRED EXPERIMENTAL ARITHMETIC, not valid item designs, not owner-selected. They demonstrate only how a mathematically scaled statistic would behave; they MUST NOT be used to implement items.**

**SOURCE numeric checks (cultivation and body same, Potential=0):**

| Realm/floor | Baseline ATK | Baseline HP | Baseline DEF | G(r,1) | +Sword ATK proposed (+3G) | +Armor HP proposed (+20G) | +Armor DEF proposed (+2G) |
|---|---:|---:|---:|---:|---:|---:|---:|
| 1.1 | 23.00 | 190.00 | 19.00 | 1.00 | 3.00 | 20.00 | 2.00 |
| 2.1 | 37.95 | 313.50 | 31.35 | 1.65 | 4.95 | 33.00 | 3.30 |
| 5.1 | 170.48 | 1,408.28 | 140.83 | 7.41 | 22.24 | 148.24 | 14.82 |
| 10.1 | 2,084.89 | 17,223.01 | 1,722.30 | 90.65 | 271.94 | 1,812.95 | 181.29 |
| 11.1 | 3,440.07 | 28,417.97 | 2,841.80 | 149.57 | 448.70 | 2,991.37 | 299.14 |
| 20.1 | 311,833.50 | 2,576,015.91 | 257,601.59 | 13,557.98 | 40,673.94 | 271,159.57 | 27,115.96 |
| 21.1 | 514,525.28 | 4,250,426.25 | 425,042.63 | 22,370.66 | 67,111.99 | 447,413.29 | 44,741.33 |
| 30.1 | 46,640,394.83 | 385,290,218.14 | 38,529,021.81 | 2,027,843.25 | 6,083,529.76 | 40,556,865.07 | 4,055,686.51 |

NOTE: the numbers in the `G` and item columns are **PROPOSED arithmetic reference**, not current engine item data. Realm 30 floor10 is much larger due to ×1.03^9. Item tier r **must not** be derived from wearer floor, and cannot exploit dual-track eligibility to gain a fictitious 31st rank. Numeric display must preserve real values/precision even when a compact `M` suffix is used.

**Exact pilot comparison:** at 1.1 (no buffs/crit/element) and target DEF=19: basic damage `23*(46/65)=16.276923`. A Phàm tier1 sword +3 Attack yields `26*(52/71)=19.042254`, **+16.99% actual hit damage**, despite Attack +13.04%. The armor example +20 HP and +2 DEF provides +10.53% HP and ~+3.0% ordinary incoming-mitigation benefit against ATK23 in isolation. Pilot constants are **not owner-locked**.

## 2. Translate S2 into a testable *combat power budget*, not a hidden hard cap

**OWNER-LOCKED S2 direction:** moderate but meaningful gear; realm remains primary. Earlier rough `30–50%` phrase is **a proposed same-tier full-loadout *effective role-performance target***, NOT an official flat +50% ATK, and not a cap enforced by code.

**Proposal S2-A (RECOMMENDED)** at matching rank and comparable Potential/skills:
- DPS: full ordinary 10-slot **with representative accessible grade/affix rolls** targets `+30–50%` *measured sustained single-target DPS*, not +50% Attack alone.
- Tank: full build targets `+30–50%` *time surviving a same-rank melee damage fixture*, using HP, DEF, mitigation; healer/support get a comparable measurable contribution metric tied to **implemented** healing/skill channels, not generic Combat Power.
- Define **basic no-affix loadout as weaker than top affix build**, otherwise Q1's grade progression becomes irrelevant. Start solo pilot weapon and armor, then calibrate 10-slot budget after real role fixtures.
- Never multiply a gear stat by Potential or multiply the final role budget again because quality is higher. Avoid unbounded additive `percent_add` from ten unrelated items.
- Recompute from actual equip source IDs, and rescale current HP fraction when MaxHP changes; no free heal.

**Other *still open* S2 calibration variants (not reopening S2):**
- **S2-A [recommended]:** target full mid-grade gear +30–50% role performance, allow fully rare gear to exceed temporarily only after endgame/Elite/Boss stress tests.
- **S2-B:** interpret +30–50% as *only base-grade ten-piece* performance, with rare affixes added on top -> bigger power spikes, risk crossing multiple realms.
- **S2-C:** +30–50% effective power specifically for ordinary farming; Boss/elite conditional bonuses excluded from this benchmark. Useful but needs additional explicit Boss tests.

**Corrected pilot proposal:** low-tier named starter sword **could** grant flat +3 Attack and starter armor +20 HP/+2 DEF, but only once an authored item tier/ID/source/eligibility is assigned and separately approved. These exact numbers remain PROPOSED. **NO global `flat(r)=flat(1)×1.65^(r-1)` equipment progression rule**. Each higher realm item template and source is authored separately, with Combat Core used only to benchmark item budget. Low-tier sword remains at its actual fixed stat even when a rank30 disciple wears it.

## 3. Q1: all twelve approved grade capacities, baseline bonus and affix catalog

**Canonical exact grade capacities** (already owner locked; `normal/special` = maximum slots, not guarantee of perfect rolls):

| Grade | Name | Normal slots | Rare conditional-stat slots | Chân Văn |
|---:|---|---:|---:|---:|
|1|Phàm|0|0|0|
|2|Tinh|1|0|0|
|3|Thượng|2|0|0|
|4|Cực|3|0|0|
|5|Linh|3|0|0|
|6|Huyền|4|0|0|
|7|Địa|4|1|0|
|8|Thiên|5|1|0|
|9|Vương|5|1|0|
|10|Thánh|5|2|0|
|11|Đế|6|2|0|
|12|Chí Tôn|6|2|1 **EMPTY available slot**|

**Q1-first policy PROPOSED**: base flat stat is **tier/template dependent**, grade enhances legal extra line count & rarity first; do not use P2's automatic 1.16/1.34 multipliers. For the first pilot (grades 1–3), **base exactly identical**: sword +3, armor +20 HP/+2 DEF; grade2 has up to one legal affix, grade3 up to two. When both render/readable and Combat consumer tested, consider at most modest `0–8%` *additional template-base* allowance across the full 12-grade ladder, which is **separately OPEN** and NEVER globally applied yet. (If owner selects grade **Q1-BASE0**, keep flat identical at all 12 tiers, let legal affixes define quality.)

**Legal early affix draft** (each is `PROPOSED`; only consumer-backed `CombatStatsV2` channels may ship; no universal ability with no runtime consumer):

| Item / grade | Candidate legal normal line | Channel and mode | Example rank1 amount — PROPOSED | Implementation dependency |
|---|---|---|---:|---|
| Sword grade2+ | Critical chance | `crit_chance/percentage_points` | +1pp (=.01) | `CombatStatsV2.derive` |
| Sword grade3+ | Attack | `attack/flat` | +1 | `CombatStatsV2.derive` |
| Sword grade3+ | Attack speed | `attack_speed/percent_add` | +2% (=.02) | `CombatStatsV2.effective_interval` |
| Armor grade2+ | Defense | `defense/flat` | +1 | `CombatStatsV2.derive` |
| Armor grade3+ | Max HP | `max_hp/flat` | +6 | source breakdown + HP ratio |
| Armor grade3+ | Elemental resistance (specific) | `elemental_resistance/<element>/remaining_reduction` | +2% (=.02) | authorized actual element in combat |

A/B/C positional pools in spec remain controlling: not every Sword may roll all six generic stats; normally at most **2 A general lines per item**, no duplicate affix ID on same item, not every slot gets generic Attack, no fake forge rare-yield without consumer. Limit specific per-line roll range and weighting after Combat fixtures; **+1, +2% are just illustrative candidates**. Graded line *capacity* does not automatically spawn a second independent attack or Chân Văn proc.

## 4. F1: deterministic targeted forge from live ingredients, no free items

### Pilot recipe candidates using **existing P2 authored input IDs**, with V2 behavior not yet coded:

| Pilot craft | Current P2 recipe reference (SOURCE) | Proposed V2 item output | Owner choice needed |
|---|---|---|---|
| `thanh_thiet_kiem` | 3 `thanh_thiet` + 1 `linh_moc` | tier1 sword with guaranteed template, minimum Phàm, true +3 ATK | keep same inputs for migration-safe first pilot? |
| `tinh_lang_giap` | 3 `tinh_lang_bi` + 1 `thanh_thiet` | tier1 armor guaranteed template, minimum Phàm, +20 HP/+2 DEF | allow same source, or require Lv30 monster-material workshop? |

**Conflict requiring explicit solution:** building spec says monster-material forging is a Lv30 unlock, but old P2 already has `Tinh Lang Giáp` crafted from `tinh_lang_bi`. **Recommended compatibility rule:** permit existing legacy P2 recipe in grandfathered compatibility/migration mode, but *new* V2 crafted monster-material armor only after workshop unlock; alternatively define starter hide as basic material with narrowly allowed Lv1 crafting. This is an owner choice, not automatically locked.

**Proposed starter work time [not locked]**:
- **T1** 5 simulation ticks (fast, current legacy forging duration 5 work units, but those work units are NOT the new timed job).
- **T2 RECOMMENDED** 10 simulation ticks at neutral Lv1 worker/building speed; emphasizes a real timed order.
- **T3** 20 simulation ticks; more production-oriented, potentially slow to equip opening disciple. 
`tick` means canonical simulation minute; speed bonus changes work duration only, never material yield and never extra item count.

### Open and honest forge failure rule (choose with owner before CODE):
- **F1-A RECOMMENDED:** usable baseline item **guaranteed** if order legitimately completes; no complete-material-loss failure. Quality above minimum random per eligible table.
- **F1-B:** at some high-grade/advanced recipes failure may output lower grade but still one item; resource-consuming sink, must bound guaranteed quality.
- **F1-C:** catastrophic failure possible only on explicitly marked *late optional* risky recipes with preview of costs/risks; NEVER secretly active for Lv1 pilot.

F1 already means the **selected slot/template/tier stays targeted** (unless owner separately chooses a visible optional gamble system). All RNG inputs frozen at order acceptance, preventing save-scum re-roll. An item may have hidden affix rolls generated from saved seed at completion; no pre-roll exploit through GUI.

## 5. Numeric proposals: legal grade distributions, per 10,000 *eligible* forges

These are **PROPOSED probability tables (not SOURCE, not yet owner locked)**. It is *not* true that Lv100 alone entitles a cheap recipe to Chí Tôn; eligibility simultaneously requires building milestone, recipe/blueprint, profession and suitable material.

| Grade | Early `E0` basic starter | Intermediate `E1` authored advanced | Exceptional `E2` top recipe and costly rare materials |
|---:|---:|---:|---:|
|1 Phàm|7,500 (75%)|2,000 (20%)|0|
|2 Tinh|2,000 (20%)|2,500 (25%)|0|
|3 Thượng|500 (5%)|2,500 (25%)|0|
|4 Cực|0|1,800 (18%)|600 (6%)|
|5 Linh|0|900 (9%)|1,000 (10%)|
|6 Huyền|0|300 (3%)|1,700 (17%)|
|7 Địa|0|0|2,300 (23%)|
|8 Thiên|0|0|2,200 (22%)|
|9 Vương|0|0|1,300 (13%)|
|10 Thánh|0|0|650 (6.5%)|
|11 Đế|0|0|230 (2.3%)|
|12 Chí Tôn|0|0|20 (**0.2%**)|
|**Total**|**10,000**|**10,000**|**10,000**|

**Eligibility proposal, not final building lock:** E0 allowed once basic forge functional. E1 requires an authored higher recipe and facility/profession/material eligibility (e.g., Lv30). E2 *example* requires Lv100+top schematic+rare source rather than automatically receiving all-grade odds for cheap ore. Do not assume a fake Lv100 facility exists now; real workshop must be implemented and tested later. Level threshold may be recalibrated after examining 30-tier availability and profession growth.

- The E2 table is **conditional** on paying for an expensive eligible craft, *not* the unconditional chance from an ordinary kill or from any item with a high-level blacksmith.
- E0 **75/20/5** means expected per 100 legitimate basic forges 75 Phàm / 20 Tinh / 5 Thượng, not a guaranteed outcome in 100 trials.
- Grade12 rarity comparison for E2 if eligible:
  * **R1 rare**: **0.05%** per craft -> mean 2,000 eligible attempts for one; P(at least one in 500)=22.12%.
  * **R2 RECOMMENDED CANDIDATE**: **0.2%** -> mean 500 attempts; P(at least one in 500)=63.25%.
  * **R3 generous**: **1.0%** -> mean 100 attempts; P(at least one in 500)=99.34%.
- Extremely rare craft material cost/rate & population of 1,000–3,000 disciplines must be measured **before approving 0.2%**. One lucky result or 500 attempts does not guarantee grade12. Grade10+11 rows need renormalization if R option changes, keep column sum 10000 in integer basis points.
- No published live rates. Future deterministic seeded 10k/100k craft simulations require approved eligibility, cost, source seed, distribution & target percentiles, not raw random draws blindly labeled test PASS.
- Starter forging **no Grade 12 roll** in any E0 input: 0 odds by contract; cannot be hacked by UI.

## 6. Transaction and unique-item architecture: canonical, no duplication

### One owner, source of truth
`SimulationRuntimeOwnerV2` + Sect State and scheduler own the forge order, material debit and item creation. Stackable ingredients are `WarehouseSystem` and `ResourceRegistry`; unique equipment stays indexed by a single Sect `equipment_items` identity registry (schema-versioned). UI only sends a command and reads a copied snapshot. No second timer, no UI-produced items, no second save file.

```text
ACCEPT:
  validate facility & recipe tier, legal blueprint, worker and One Active Job,
  material stock (respect reserve_min/locked rules), queue space and uniqueness;
  allocate durable global forge_order_id and freeze recipe_revision,
  input amounts, item template/tier, worker snapshot & per-order RNG seed;
  commit canonical debit and durable ACTIVE order atomically in authoritative state;
  make one durable save through existing owner boundary.

RUN:
  scheduler alone advances job progress; job belongs to worker.
  If paused/injured/busy, consult explicit pause/cancel policy.
  One explicit completed status per order; no "one button press = one extra item".

SETTLE:
  order already COMPLETE? return same existing product ID without reward.
  order ACTIVE & progress sufficient? recompute valid deterministic grade and
  eligible line IDs from frozen seed/recipe_version/pool_version; assign one
  monotonic/unique item ID; update item registry and order COMPLETED with same receipt.
  persist one canonical state transition before telling UI "success".

ASSIGN:
  validate equipment slot and Tu Vi OR Luyện Thể eligibility, item assignment,
  locked equipment policies, compatible set/generation, previous assignee.
  Equip moves UID, does not create new UID; rebuild combat source snapshot,
  preserve current HP fraction; rollback invalid action with no mutation.

RECOVER:
  load canonical snapshot; roll must be repeatable, never reroll on reload.
  Retry callback must detect receipt and return existing result. Same worker/job
  cannot secretly mine or hunt concurrently. A failed save means success cannot
  be *durably* reported, and state retry policy must be explicit.
```

**Important persistence nuance:** `WarehouseSystem.consume_requirements` is atomic inside the in-memory state, but **it is not itself a durable journal or filesystem transaction**. Do not assert file-level atomicity just because this helper returned true. The future code must rely on existing SaveService atomic-write/recovery semantics and document the recovery boundary, with real crash/replay fixtures. If material consumed and order NOT present after power loss, revert to previous saved snapshot or restore a verified idempotent transaction; never mint a free result on an orphan debit.

**Plan for V2 migration without losing P2 gear:** keep P2 `equipment_items`, receipt/UID and assignment until validated; add versioned schema for new V2 instances, do not overwrite `owner_id` old saves. P2 `weapon` and `armor` can map *only after validating their old stats*, never convert `combat_power=6` into V2 Attack+6. Old `talisman` cannot silently become `pendant` or a new `Phù` merely because names sound similar; preserve a **legacy-compatibility slot** until an explicit Phù migration mapping/consumer is approved. No duplicated buff from reading both P2 and V2 gear bridges. Never auto-trade Sect equipment from disciple wallet in V2; P2 shop flows only continue behind legacy compatibility until migrated.

## 7. End-to-end design test matrices

| Fixture | Expected |
|---|---|
| F0: legal E0 sword, 3 ore+1 wood, worker+facility, clock | exactly 1 debit+1 tracked order+1 item on completion; item base +3ATK on a tier1 wearer; deterministic grade eligible 1..3 |
| F1: preview rerender/reopen before finishing | no second charge, no grade reroll, no new UID |
| F2: duplicate finish callback and save reload after COMMITTED | same item ID; exactly one item total, one XP work credit and no extra Warehouse debit |
| F3: crash after in-memory material debit before durable save | previous valid snapshot or recovery proof; never orphaned cost or free item |
| F4: same worker mining/other profession/hunting | forge reject or exclusive reservation; One Active Job preserved |
| F5: item moved to second disciple | first no longer has same UID, no duplicate active buffs or phantom private gear payment |
| F6: P2 old 3-slot save + P2 forge legacy | loads exactly, no forced talisman->pendant/Phù, no loss of UID |
| F7: Potential1,000 on base23ATK and +3 sword | core34.5 +flat3 =37.5 before other %, NOT39 |
| F8: rank30 gear on rank1 character, and rank1 Sword on rank30 | eligibility rejects invalid equip; lower tier does not scale from wearer |
| F9: grade1 E0 and grade12 E2 candidate | impossible to create grade12 from E0; Chí Tôn grants EMPTY inscription slot only |
| F10: HP changes from armor, 60/100 HP originally | ratio remains 60% after Max HP recalculation, no free full HP |
| F11: E0 workshop 10000 seeded eligible rolls after authorized code | approximately table probabilities (statistically bounded), no 7..12 outcomes |
| F12: 2/3/4 same generation set / 3+3 eligible | additive rule/lowest tier correct, no set proc or free Chân Văn |

Do not label design fixtures as Godot tests executed. Official running Godot 4.7.2 and Windows/Android visual/manual remain separate.

## 8. Only new owner choices still needed (all compact and independent)

**Owner has ALREADY chosen S2+F1+Q1. Do not re-ask.** Remaining meaningful choices:

| ID | Option A | Option B | Option C | Recommended |
|---|---|---|---|---|
| **BUDGET** full gear measurement | A: role performance +30..50% (DPS/TTK, tank survival, healer actions) | B: same range on raw core Attack/DEF/HP, affixes on top | C: only normal mob, Boss uncapped | **A** |
| **GRADE-BASE** baseline Q1 variance | A: exactly same template-base at all 12 grades, only lines differ | B: baseline may rise at most about 8% by grade 12 | C: up to 15% | **A for pilot**, B only after testing |
| **R12** Chí Tôn chance on eligible E2 forge | A: 0.05% | B: 0.2% | C: 1.0% | **B candidate**, only after expensive material economy known |
| **WORK** starting craft time | A: 5 sim ticks | B: 10 sim ticks | C: 20 sim ticks | **B** |
| **HIDE** old hide armor versus Lv30 design | A: treat pilot hide as authorized basic material at Lv1 (exception stated) | B: defer V2 hide armor to Lv30; old P2 item migration only | C: choose unrelated starter non-monster armor for V2 pilot | **C** (clean rule) |
| **BAD-CRAFT** usable result on complete | A: always one usable baseline, quality varies | B: optional high-tier failure to lower grade | C: possible total loss | **A** |

**Recommendation for next assistant-only research:** lock none of R12/material-rate/craft time as canonical until owner picks; then produce exact **BD-01B one normal weapon + basic armor recipe**, 4-6 combat tiers, source-backed one-day/one-week material flow and full trace of receipt/migration. This is feasible as docs-only alongside PR #25 Windows QA. Gameplay CODE remains awaiting an explicit scoped owner ticket.
