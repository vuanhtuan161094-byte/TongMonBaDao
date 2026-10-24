# TÔNG MÔN BÁ ĐẠO — R11 S1/S2: KIỂM ĐỊNH TUYẾN ĐỒ R10, SOFTLOCK VÀ NGUỒN CUNG
## Reachability, Combat V2 calibration, kinh tế vật tư phổ thông và quyết định owner

**2026-10-25 · DESIGN ANALYSIS ONLY; NOT A GODOT PLAYTEST; NO SOURCE A ASSET/MAP CODE.** Companion source contract `docs/design/TMB_R11_S1_S2_TIEN_THIET_VAN_MOC_VAN_GIAC_LOC_SOURCE_CONTRACT_2026-10-25.md`. Main `29b5fba448b0178cb520a4ada44b375b4b934e31`; canonical `docs/REALM_LADDER_V2_SPEC.md` & `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`; current `MonsterCatalogueV2.create_actor` and `HuntingMapV2`. Những chỉ số mới là đề xuất; nhánh doc trước `docs/ascension-r11-r21-vertical-slice-source-proof-20261025` làm đầu vào.

## 1. Định nghĩa “đội R10 đạt nguồn R11” — đồng thời qua 5 cổng
1. **Travel/path reachable:** from one actually saved entry/sect departure to R11 margin through legal nav graph with existing geometry collision, no item R11 or blueprint R11 gate; player camera movement does not change the path result. Old projected `hunt_r11` or `frontier_r11` is NOT evidence of a scene.
2. **Sustainable encounter:** real party wearing only legal R10 equipment and an actual R10 Tu Vi/Body profile can defeat ≥1 *normal margin* Vân Giác Lộc under Combat V2, or has at least one repeatable viable tactic without dying/infinite unrecoverable injury. Need objective fixture with DPS, healing, defense, combat ticks/TTK, not “power 10000”. No automatic gear scaling to match opponents.
3. **Worker-source access:** valid mining/forestry worker and worksite/labor route obtain at least one physical R11 ore/fiber with ONE job each; does not require ore before visiting the ore node. A gather action is not just a region name; real harvest+haul and Warehouse receipt required.
4. **Survivable exit/recovery:** after injury, return-to-Sect and 120-tick canonical recovery remains possible; respawn, node reset and safe return routes are not locked behind R11 items. Legitimate replacement worker/recruit policy may cover all injured but cannot mint free materials.
5. **Persistence:** source and death identities survive exit/reload; if a source was already harvested/killed and credited, returning or loading cannot re-award it. Offline time may advance pending work **only** through canonical simulation source with exactly-once job receipt, never by wall-clock fake payout.

**FORMAL graph acceptance [P]:** let nodes be sect_start, margin_entry, ore_node, fiber_node, deer_camp, safe_exit. On real persisted nav graph G, require:
`reachable(sect_start, margin_entry, old_gear)`,
`reachable(margin_entry, ore_node, old_gear)`,
`reachable(margin_entry, fiber_node, old_gear)`,
`reachable(margin_entry, deer_camp, old_gear)`,
`reachable(deer_camp, safe_exit, injury_policy)`.
Source edges must not require `item_rank>=11`, `blueprint_r11`, Elite/Boss deaths, exclusive Thần material, Forge Lv75, or R11 rare gear. The graph is a **test specification**, not a nav-graph already produced. Scarcity affects speed/chase, not permission to obtain the *first* basic source.

## 2. Controlled RealmBody/monster stat arithmetic — NO QA PASS
**[LOCKED SPEC]** player realm/body growth `G(r,f)=1.65^(r−1)×1.03^(f−1)`. Monster stat profile in CURRENT `MonsterCatalogueV2.create_actor`:
`HP = 190G × species_hp_factor × tier_hp_factor`,
`ATK = 23G × species_attack_factor × tier_attack_factor`,
`DEF = 19G × species_defense_factor × tier_defense_factor`.
Species Vân Giác Lộc factors **not authored**; do not pretend generic1.0 is a final deer profile. Current normal monster tier factors=1/1/1.
| Authored ACTOR scale candidate, not named character item realm | G (relative basis) | Relative to R10 tầng10 | Design implication |
|---|---:|---:|---|
| R10 tầng8 (outer margin candidate) |111.4849|0.9426|a legitimate lighter tier-world source test, not guaranteed easy due to skills/build|
| R10 tầng10 (upper margin candidate) |118.2743|1.0000|same progression scale as R10f10 before species differences|
| R11 tầng1 (interior candidate) |149.5683|**1.2646**|about **+26.46%** growth over R10f10, BEFORE species/element/AI|
| R11 tầng3 (deep candidate) |158.6770|1.3416|about **+34.16%** growth over R10f10|
**[SIM arithmetic]** numbers are straightforward application of the locked scale, not a Godot battle and not a proposed boost to player stats. The monster is of R11 family even if OUTER specimens use explicit R10f8..10 actor scale; content authoring has to explain this instead of secretly downscaling by squad strength.
**Combat acceptance fixtures [P]:** make actual R10f8/R10f10 Tu Vi and independently varied Body (R9f10, R10f10), Sword/Body/Spell legal builds, appropriate learned skill/equipment; compare against Vân Giác Lộc normal at proposed scales R10f8/f10 and R11f1/f3, with wood elemental interaction and AI leash/chase. Collect HP time series, attack/DEF, damage packets, healer contributions, TTK, retreat success, Injury, number of legitimate victories/lives and resource receipt. None of these live fixtures or elements currently exists; no benchmark claim.

## 3. First source demand is small; every material must be earned, not free
From earlier DESIGN trial: study R11 catalog once costs [P] **1 `eqv2_r11_ore` +1 `eqv2_r11_beast`**; forge one R11 weapon later costs [P] **3ore+2fiber+1beast+22 Sect Stones and base12 Forge ticks**. For first researched + forged physical R11 weapon **minimum total future demands =4 ore +2 fiber +2 beast +22 Stones, plus unpriced research work/time**. This is a prospective **S3/S4 consumer**, not S1/S2 runtime. Therefore S2 should demonstrate gathering **at least 4 units ore,2 fiber and2 beast** as robust source batch, even though the strict source-registration criterion is one of each. No extra item or blueprint is earned merely for collecting the materials.
Existing Sect Mine production `thanh_thiet` and Forest `linh_moc` do NOT satisfy ore_R11/fiber_R11 quota. Also R10→R11 content might have market/exchange later, but current NPC market has no sale of R11 materials; do not use infinite fictional merchant stock to close a softlock.
**Tổng vật tư thử [not actual production]:** 30 ten-slot fresh kits incl first research =451ore,630fiber,121beast; 1000 kits=15001/21000/4001;3000 kits=45001/63000/12001. These are gross potential sink demand, not 3,000 simultaneously deployed or a mandatory gear policy. Three independent faucets must be measured in ore/hour, fiber/hour, beast kills/hour before a 7d/30d distribution estimate is credible. Do not derive unlimited resource intake from 200–400 visible monsters.

## 4. Common hide distribution versus HIẾM gear: mathematically distinct denominators
For one eligible ACTUAL normal Vân Giác Lộc life, suppose a common material drop is Bernoulli(q), once per committed death event, **not per participant**:
| COMMON q (TRIAL) | Expected genuine kills to earn first beast | P(no beast after 5 eligible deaths) | P(no beast after 10 deaths) | Expected kills to earn two beasts for research+first weapon | Expected kills for121 beast units |
|---:|---:|---:|---:|---:|---:|
| 1.00 |1|0|0|2|121|
|0.50|2|0.03125|0.0009766|4|242|
|0.25|4|0.23730|0.05631|8|484|
**Math not gameplay.** This illustrates why a resource required to escape R10 shouldn't inherit rare gear odds from HIẾM. A repeatable normal source with q∈(0,1) is mathematically eventually possible if truly infinite lives/retries and a repeatable safe route exist, BUT “chance to get material” is NOT by itself a bounded-time progression guarantee. If there is a finite life/supply quota, travel danger, no retirement, no respawn or no viable kill, the resource can be permanent BLOCKER.
- **Option A [recommend trial, not approved]:** exactly one common hide per eligible genuine normal life, independently from item/books/Elite/Boss. Free body of a resurrected mob is NOT another life unless a legal spawn-generation/respawn tick occurs.
- **Option B:** q<1 + bounded guarantee counter per Sect or source/life category, incremented against exactly-once eligible kill receipts, with explicit fixed threshold chosen by owner. Hidden reroll on reload and multiple-claim from squad assist forbidden. Guaranteed **material** is not guaranteed **rare gear**.
- **Option C:** deterministic real production conversion of ordinary valid sources with labor/material expense, available from R10; requires authoring a new consumer and non-arbitrage model and is *not* presently available.
If all A/B/C absent or source location R10 unreachable: **S1/S2 BLOCKED**. Normal monster item source q does not equal current `HuntingMapV2.LEVELS[].rare` per-encounter rare roll.

## 5. Resource supply and World performance questions (design test proposals)
- `ore_rate = legal_harvest_jobs_completed_per_tick × approved_qty_per_ore_node_receipt`, `fiber_rate` similarly; `beast_rate = true_normal_life_deaths_per_tick × approved_q_or_guarantee`. Do NOT use historical Sect mine units/hour as R11 world-node output. All numerators need real job/life receipts and persistent work continuity. For 30 hunters sharing one camp, monster damage is shared, but their reward is **one Sect kill**; no 30× loot.
- Concurrent workers reserve distinct node generations; one node can be active by one worker unless owner explicitly defines a legal co-op harvest job with contribution and ONE aggregate payout. A harvesting worker cannot also hunt or run Forge; travel and hauling are actual time, not cosmetic.
- World node/monster identity is maintained off camera. A chunk unload is presentational; it must not regenerate source slot, reset HP or re-enable payout. S2 should test100 camera leaves/returns,100 Save reloads with unchanged source receipts, 30-worker contention against fewer nodes,1–4 actual job lanes and eventual access for 1000/3000 roster without instantiating all actor sprites.
- Nonexistent high-rank map art, missing navmesh or no R10 survivor source is not “PASS with placeholder.” A docs-only sketch is merely a proposal, **no QA evidence**.

## 6. Softlock risk matrix with severity
| Risk | Threat path | Severity | Pass condition needed before CODE acceptance |
|---|---|---|---|
| S-01 | Entry requires R11 equipment to collect ore_R11 | BLOCKER | old-geared R10 nav graph reaches ore and returns |
| S-02 | Entry requires R11 blueprint/catalog | BLOCKER | all three S1/S2 source paths independent of archive |
| S-03 | Common beast exists only on Elite/Boss | BLOCKER | accessible real normal Vân Giác Lộc drop owner |
| S-04 | Mine/Forest after some harvests never respawn and no alternate | BLOCKER for prolonged play | repeatable authenticated node-generation policy |
| S-05 | Wounded team permanently trapped in source zone | BLOCKER | real retreat/return, Injury recovery120 ticks and legal workforce allocation |
| S-06 | R10 monster mismatch 1.2646 G × high species multipliers kills all parties | BALANCE BLOCKER until tested | R10-finish team viable against at least one outer normal life |
| S-07 | Full Warehouse stack or unregistered source ID discards the result but still depletes node | DATA-LOSS BLOCKER | preflight then atomic settle/rollback, do not expire uncommitted source |
| S-08 | Source can credit on dig animation AND hauling AND battle win | DUPLICATE-LOOT BLOCKER | exactly one physical source owner/payout per generation |
| S-09 | Life respawns on camera and gives repeated rewards | DUPLICATE-LOOT BLOCKER | persistent life generation+receipt tombstone/watermark |
| S-10 | R11 beast source only on old encounter payout, reused per-kill despite no live world | SOURCE-CONTRACT BLOCKER | explicit mode/loot-class reconciliation and one reward writer |

**Recommend next owner review:** accept R10f8–10 margin as only a CALIBRATION REGION, choose material policy A/B, keep current encounter reward unchanged until one standalone World S2 source owner is developed by an authorized CODE packet. All content ID and physical map decisions are open. No Godot, Android, UI or source art test has been executed.
