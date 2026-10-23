# TÔNG MÔN BÁ ĐẠO — COMBAT V3: ACTION-SKILL / TIMING / HP / MONSTER BALANCE PROPOSAL

**Date:** 2026-10-24 | **Type:** design proposal, **NOT CODE** nor official Godot 4.7.2 evidence.  
**Source authority:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`; same combat sources inspected in PR #26 draft `53ff0b223f4e77ccfbe5c77d2203496ac0cc37a9` (`integration/master-recovery-playable-v1-20261023`). Preserve Combat V2 runtime and CARE receipts; no PR24/25/26 edit, no merge, no Source A modifications. 19/19 earlier focused PASS applies only to PR26 code/test SHA `f5715ad0`, **not** this proposal.

## 0. Verdict — what is selected and what remains open

- **OWNER DIRECTION**: Combat visual scale HP/ATK/DEF ×100; Tu Vi Realm base **10,000/2,000/1,200**; Potential affects **RealmCore only**; two independent Tam Căn / Tứ Tính point pools; Combat V2 is simulation authority.
- **DERIVED interim V3 baseline** with old Body ratio: Body **9,000/300/700**, total naked Tu Vi1.1/Body1.1 **19,000 HP / 2,300 ATK / 1,900 DEF**, no stat or gear. **19,000 HP has NOT been demonstrated balanced; do not lock it as owner acceptance.** Later owner may choose a different base/ratio after real battle fixture.
- **RECOMMENDED DESIGN NUMERIC CANDIDATE** for first real fixtures: normal monsters ×100 unchanged rank+species factors; **ELITE HP tier 1.35 → 5.0**, **BOSS HP tier 2.50 → 18.0**; keep ATK/DEF tier coefficients at their current values **for the first experiment only**, so HP difficulty and threat can be separately measured. **NOT authorized runtime values.**
- **P0 timing debt** before validating speed builds: action step 0.25s makes certain attack-speed upgrades ineffective. Learned damage skills consume a casting action and replace/delay basics; currently cast_speed/cooldown_recovery stats are not consumed in the damage-skill path. Compare V2 historical scheduler with an independently versioned V3 cadence proposal, do not silently rewrite damage receipts/save.
- **P0 ability roster**: CombatSkillSystem contains **9 authored P2 skill definitions**, but MapBattleV2 only activates learned `effect=="damage"` entries (**Thanh Phong Trảm**, **Ngự Kiếm Thuật**); other effects (dash/guard/burn/weaken/fire_combo) are deferred by Loadout. `Ngự Kiếm Thuật` has `min_stage=9`, so a starting legal R1.1 character does **not** have both direct skills. Generic role guard/heal, monster AoE, and pilot CARE poison/HoT belong to separate authentic event owners and are not proof all 9 skills are live.

## 1. Actual current combat action authority inspected

Source: `godot/src/simulation/combat/{combat_stats_v2.gd,map_battle_v2.gd,combat_skill_system.gd,disciple_combat_loadout_v2.gd,monster_catalogue_v2.gd,combat_context_effects_v2.gd,hunting_pve_run_v2.gd}`, PR26 read-only presenter `godot/src/presentation/p3/b3_care_combat_v5_presenter.gd`.

- Engine advances exactly `STEP_SECONDS=0.25`; ordinary isolated battles `MAX_SECONDS=90`, max 6 members per party, up to 30 disciples and 40 monsters.
- Actor order ID sorted every step. Pending casts release BEFORE actions, and pending caster skips new actions. `_try_learned_damage_skill` precedes ordinary attack and movement. Skill requires range, uses authored `cast_time`, projectile travel, cooldown and own ready table; no derived cast_speed/cooldown_recovery currently used. Generic healer action and frontline guard have priority over learned skill.
- Basic attack interval `now+max(.25, base_interval/(1+attack_speed))` means ACTUAL grid-round-up; at sword base 1.10s, +50% and +100% can both attack each 0.75s. Need scheduled-deadline accumulation or deterministic substep/action-progress model, avoiding unbounded catch-up, duplicate hits, performance explosion, save replay RNG perturbation and phantom DPS.
- Sword profile move 3.10 range1.90 interval1.10 ratio1.00; Body move2.50 range1.35 interval1.45 ratio1.15; Spell move2.70 range5.50 interval1.65 ratio0.85; Balanced move2.70 range1.75 interval1.35 ratio1.0.
- Generic healer: if own party ally below **65%** within range6 and ability ready, heals `min(missing HP,1.80×healer ATK)`, cooldown **5 sec**, consuming an action. Naked rank1.1 ATK2300 ⇒ max 4140 per heal ⇒ ideal upper continuous rate 828 HP/s before gating, overheal and movement. Scaling ATK×100 ALREADY scales this healer effect: **DO NOT scale again ×100**.
- Frontline generic guard triggers HP below75%, lasts4s, ability cooldown9s; active guard in `_deal_direct` combines existing remaining damage by ×0.65 ⇒ 35% incoming reduction; NOT necessarily the separate authored Kim Cương Hộ Thể/Bất Động Thân effects, which are deferred.
- Mage AoE generic 0.90× direct ratio on ≤3 enemies every7s in appropriate cluster, boss/elite telegraphed AoE delayed1.0/0.75s and recurring7.5/8.0s, 1.10/0.85× direct ratio to ≤3 within radius 2.8/2.2. Actual path/position decides damage.
- Crit default5%, crit multiplier×1.50 ⇒ expected +2.5% direct damage where crit eligible. Real lifesteal heals only on settled HP loss. Defense factor `2×attacker_ATK/(2×attacker_ATK+effectiveDEF)`. Guard, defense penetration, DR, effect resists, element and context effects resolve as authored.

## 2. Transparent action-cadence numeric illustration (NOT Godot runtime)

**Clean-room Python deterministic reproduction of actor attack scheduling with `STEP=.25`, a single actor stationary within range 1, starting action time t=.25, no monsters attacking, no movement/target kills, no DoT, no resistances, no equipment/roots/cultivation-path multipliers.** Expected crit factor 1.025 is applied mathematically per eligible hit, NOT stochastic crit rolls. Total damage measured across 30-second dummy, `ATK=2300, dummy DEF=1368`. This is only a timeline comparison, not a full PvE result.

- Active sword `Thanh Phong Trảm`: 1.35× damage, cast0.30s, cooldown2.8s, min_stage0.
- Mid progression `Ngự Kiếm Thuật`: 1.70×, cast0.65s, cooldown6.5s, projectile speed10, min_stage9; both-learned rows use a **hypothetical unlocked later-stage configuration normalized to same 2300 ATK** solely to isolate cadence, NOT a legal R1.1 loadout.

| Learned skills | +attack speed | Basics/30s | Skills settled/30s | Expected damage per second | Relative |
|---|---:|---:|---:|---:|---:|
| none | 0% | 24 | 0 | **1454** | 1.00× |
| Thanh | 0% | 20 | 10 | **2029** | 1.40× vs no skill |
| Thanh + Ngự (unlocked later) | 0% | 18 | 14 | **2341** | 1.61× vs no skill |
| none | +50% | 40 | 0 | **2423** | 1.67× vs +0 |
| none | +100% | 40 | 0 | **2423** | **NO improvement from +50%**, scheduler plateau |
| Thanh | +50% | 40 | 10 | **3241** | ×1.60 vs Thanh +0 |
| Thanh + Ngự | +50% | 32 | 14 | **3189** | second skill can *lower* damage vs only Thanh due to casts |

**Design implication:** Attack speed points are not smoothly valued under V2 tick schedule, and adding a learned skill can REDUCE damage due to cast blocking; optimize auto policy vs naive always-cast before setting equipment skill/attack-speed budgets. Cast priority alphabetical under current sorted loadout, cannot assume intended per-class rotation; no auto rotation simulator bypassing current authority.

**Candidate V3 scheduler contract:** Preserve canonical 0.25s simulation clock; store per-actor fractional attack-progress/deadline debt in the **single MapBattleV2 snapshot**; allow scheduled expiry carries so +50% results about ×1.5 attack frequency and +100% about ×2 subject to cast occupancy; one settled action per step unless explicit high-speed multi-action contract reviewed; no negative cooldown/cast or unbounded banked attacks. Ensure deterministic pause/resume, sorted action IDs, exact hit receipts and old snapshot compatibility. No blind conversion while Codex recovery is editing.

## 3. Player and monster base — checked enemy numbers

All figures below are **candidate ×100 multiplication of SOURCE main definitions**, not code-applied. Rank1.floor1 player and monster:

| Actor | HP | ATK | DEF | Basic hit by player | Basic hit to naked player |
|---|---:|---:|---:|---:|---:|
| disciple both1.1 | **19000** | 2300 | 1900 | — | — |
| Trúc Thử normal | 13300 | 1564 | 1045 | ≈1874 | ≈973 |
| Thanh Lang normal | 17100 | 2024 | 1368 | ≈1773 | ≈1377 |
| Hắc Lang normal | 19000 | 2300 | 1615 | ≈1702 | ≈1628 |
| Nham Giáp Thú elite OLD tierHP1.35 | 33345 | 2277 | **3135** | ≈1368 | ≈1607 |
| Hắc Lang Vương BOSS OLD tierHP2.50 | 54625 | 3438.5 | **2242** | ≈1546 | ≈2694 |

**Do not erroneously state elite DEF=31350.** It is **3135** (1900×1.5×1.1). Higher than this Boss but not 14×. Actual species/TIERS math verified.

## 4. Proposed trial HP budget BY archetype (not false final lock)

**Proposed V3 first sandbox starting fixtures** with SAME base actor ATK/DEF coefficients as source:
- **Normal**: keep current species scale, e.g. Thanh Lang **17,100 HP**. Naked sword with authentic Thanh learned skill in stationary dummy ≈2029 DPS vs Thanh Lang, ~8.4s static HP/DPS; ordinary only ~11.8s. Movement/attrition raises actual TTK. **Target median 8–18 seconds normal 1v1**, P90 ≤25s; absence of unlocked skills must still be viable.
- **Elite**: change tier HP **1.35 → 5.0**, Nham Giáp Thú **123,500 HP**, ATK2277 DEF3135 initially unchanged. Sword with Thanh stationary expected damage vs this DEF ≈1566 DPS, **3 such disciples ~4698 DPS → 26.3s static**. Mixed roles/position can shift, so **target median 20–40s 3v1**, P90 ≤60; single disciple will face stronger attrition.
- **Boss**: change tier HP **2.50 → 18.0**, Hắc Lang Vương **393,300 HP**, ATK3438.5 DEF2242 initially unchanged. Six stationary sword users with Thanh each roughly1770 DPS vs Boss ⇒ aggregate10620 DPS ⇒ **37s static**; 6 unlocked Thanh+Ngự each roughly2042 DPS ⇒ **32s static** (later stage normalized ATK; actual later boss rank scales too). True movement, tank/healer/guard/AoE affect result. **Target median 35–65s 6v1**, P90 <90s given MAX_SECONDS90.
- This is a **candidate first experimental configuration**: HP multiplier increased intentionally without simultaneously increasing monster ATK/DEF/AI; do not report “balanced”. Alternate stress trials eliteHP3.5/5/6.5, bossHP14/18/22; if too many team wipes, change attack pattern/healing/survival first rather than reflexively cutting bossHP. Separate 1-team vs 2-team HP/loot pool policy in existing B3 coop contract; NEVER award last-hit loot or generate duplicate boss pools.
- **Survival anchor:** Boss naked basic ≈2694 vs player19000 HP (~8 unmitigated hits to down), telegraphed AoE ≈2964 to up to3, not equivalent to ordinary basic. Healer upper 4140/5s + frontline guard 35% at under75% alter survival. Genuine threat metric is **focused target 5s/10s damage + team down events**, not hit equivalence only.
- **Base character HP 19000 is a trial only**. Bench alternate player naked HP20k/25k/30k at same ATK/DEF and matched monster threat; choose minimal HP keeping body/role differentiation and ≥1 cast/telegraph response window, with 1v1 and 6vBoss seeded verification. Avoid doubling player HP and boss HP arbitrarily in the same knob adjustment.

## 5. Additional stat interactions before approving HP or equipment

- **Crit stacking**: 5% ×1.5 gives 1.025 average eligible damage multiplier; hypothetical 35% ×2.2 gives 1.42 (=38.5% larger than1.025) before other gear, indicating multiplicative pressure on HP. Do not budget crit chance and crit damage independently as both linear DPS flat.
- **Penetration**: for ATK2300 vs Thanh Lang DEF1368, +25% defense penetration changes DEF factor from0.7708 to0.8176 (~6.1% direct damage gain); vs Nham Giáp DEF3135, ratio 0.5947→0.6619 (~11.3% gain). Specific monster armor affects value, not one universal +25% DPS.
- **Damage reduction**: incoming25% actual DR implies 1/(.75)=**1.333× effective HP** before heals; healer effective healing often compounds survival. Compare DR +0/10/25/40 and healer overcap.
- **Attack speed**: profile move speed and attack rate are separate; standstill model does not include path/chase, line-of-sight, targeting, stun, carry/exit, boss dodge of zone. Persist input and action receipts for correct count.
- **9 skill definitions** are not 9 active combat consumers. Skill ratios and cooldown are design inputs only when they have an actual source consumer. Different realms/professions may have fewer active damage skills; do not buff nonexistent skills in calculations.
- **Potential and Constitution**: at R1.1 +1Potential => +5HP/+1ATK/+0.6DEF in proposed split. +1Constitution => +2.25HP/+0.075ATK/+0.175DEF **ONLY if independent +0.025% BodyCore coefficient is later approved**; base C effect on BodyXP +0.20%/point remains source. Two independent birth budgets may create high Tư Chất + high Potential builds; gear and technique add multiplicative layers and must be tested by cohort.
- **Realm scaling** G=1.65^(r-1)*1.03^(f-1); test R1/2/5/10/20/30, R1.10→R2.1, matched vs unmatched Body tracks, elite armor, boss stat growth, extra-thick HP at 30.10 (≈50.27B naked).
- **Fixed-value medical/gear migration**: pill +55HP, legacy paid +55, rest +5, service +10 require authored tier re-price, not blanket final gameplay×100. ATK-based healer already scales. Do not ×100 Injury HP1, Tu Vi XP, Body XP, currency, pill satiety, timers, RNG or loot. Injury0/1 auto-return/recovery120 ticks, exactly once, cannot change.
- **Scoped UI**: Combat V5 presenter only reads settled source events. Need real DPS/skill metrics from authoritative receipt aggregations, not client-generated damage. Don't fake Boss in CARE just to screenshot.

## 6. Expected mandatory real benchmark packet — no false PASS

**Godot4.7.2 official test matrix** (isolate from unfinished PR26 and using correct test --path):
- Scenario groups: solo normal; 3-member elite; 6-member Boss; 6-member Boss with healer/frontline; up to2 squads co-op source-owned Boss.
- Unlock states: starting only Thanh, no learned skills, stage9 allows Ngự, ranged/body deferred, macro 1/2/5/10/20/30.
- Gear/advanced stats stress: attack speed0/+20/+50/+100, cast_speed0/+25/+50, cooldown recovery0/+25/+50, crit5/35, crit damage1.5/2.2, penetration0/25, DR0/25/40, healing bonus and lifesteal; Potential/Constitution0/100/500/2500; Body rank mismatch.
- Combat stats: target HP/initial DPS, **every authenticated action**, skill chosen/started/released, canceled, basic displaced, projectiles, expected vs actual DPS, burst2s, per-target damage, heal/overheal, guard uptime, AoE actual targets, HP remaining, down/retreat/wipe, TTK P10/P50/P90, reward receipts and timeouts. ≥30 deterministic seeds per representative case (more for crit/rare events), save/load midcast and after downed exactly once. Speed scale/test runner diff benchmark must be version-labeled.
- **Quality criteria proposal**: normal median8–18s; elite median20–40s; boss median35–65s and P90 under90s; ordinary same-rank normal P50 survival with useful reserve (e.g. HP remaining ≥20%); Boss team wipe ≤10% in prepared median cohort, downed count P50≤1; battle skill share **30–60% sustained output** for skill-active Sword; increasing beneficial speed stat never decreases throughput absent new displacement/movement tradeoff; no duplicate skill hit receipts, no exploit infinite healing; avoid artificially assigning a guaranteed 100% survival.
- Any failed criterion triggers targeted parameter review, not a silent new universal cap. Boss HP percentile/pacing should be considered alongside server simulation performance and expected loot per canonical hour.

## 7. Decision/implementation status

- **Source verified:** mechanics, current coefficients, 9 definitions/2 live skills, current elite/boss formula, role heal/guard, 0.25s quantization.
- **Arithmetic + clean-room measured:** stationary 30s action counts and expected DPS; static HP/DPS; monster numbers and penetration math.
- **Proposed numeric for owner to review:** trial eliteHP ×5, bossHP ×18; player baseline19000 candidate; time/role/skills targets and staggered V3 timing.
- **Not done:** Godot execution of changed coefficients, official seeded PvE fixtures, owner combat acceptance, downstream item/medicine/economy balancing, runtime or save migration. 
