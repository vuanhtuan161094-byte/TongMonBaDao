# TÔNG MÔN BÁ ĐẠO — COMBAT V3 / PR27 MEASURED TRACE AUDIT AND CORRECTED BALANCE EXPERIMENT

**2026-10-24 • DESIGN + MEASURED EVIDENCE REVIEW; NO CODE AUTHORIZATION.**

## Authority, isolation, evidence
- Gameplay authoritativeness: `CombatStatsV2`, `MapBattleV2`, `CombatSkillSystem`, `DiscipleCombatLoadoutV2`, `MonsterCatalogueV2` from PR #27 current remote HEAD `deeae081bcfbe1413d4cf60a29db7e58150888b5`; base PR #26 HEAD `53ff0b223f4e77ccfbe5c77d2203496ac0cc37a9`. PR #27 CODE/test SHA `80ed0270d2b7370f8feff1ce829f167146f3f341`. `main` checked `29b5fba448b0178cb520a4ada44b375b4b934e31`.
- Local owner-provided ZIP: `TMB_MASTER_V3_CODEX_HANDOFF_20261024.zip`. Its enclosed `evidence/combat_fixture/combat_fixture_summary.csv` SHA256 `18f37708bf334a43f9cb34f381147a5014d417fa3948c368e309a3af66e5bb70`, `combat_fixture_groups.csv` SHA256 `8ffeac1d66994b1c66035ed4c20f9fac8179ecb2ca50881415b5fb54d390881b`, `combat_action_ledger.csv` SHA256 `bd4cdf99534dc8b7bfa5ae35045d9f2b7c5f303a44279df3e80ab5fa05a840f1`.
- These CSVs contain **62 fixture groups × 20 seeds = 1,240 authentic PR #27 Godot fixture battles** and **176,682 ledger rows**. Code and checks were run by Codex at 80ed027; **no new Godot run was performed during THIS audit**. Here the CSVs were parsed and analyzed independently. All proposed new multipliers are **hypotheses**, NOT observed PASS, owner-accepted tuning or live CARE-Boss availability.
- Strictly separated workstream from UI: no editing PR #27, PR #24/25/26, CombatStatsV2, MapBattleV2, D7, SaveService, renderer or test source. Source A unchanged. No merge/CI/FULL.

## 1. Critical corrections to previous V3 proposal

The earlier proposal `docs/combat-v3-full-action-balance-proposal-20261024/docs/design/TMB_COMBAT_V3_ACTION_SKILL_TTK_BOSS_BALANCE_PROPOSAL_2026-10-24.md` estimated **3v1 Elite** and **6v1 Boss** from theoretical isolated target DPS and proposed **Elite HP tier1.35→5, Boss HP tier2.5→18** as trial multipliers. These numbers must **NOT be shipped to existing multi-monster CARE encounters** without a distinct runtime test. The actual 1,240-trial PR #27 fixture is not those encounters.

**Real fixture compositions** (`tmb_master_v3_combat_trace_fixture.gd` source):
- `normal`: Hắc Lang + Thanh Lang + Trúc Thử, i.e. THREE normals;
- `elite`: Nham Giáp Thú + Huyết Lang Đầu Đàn + Nham Giáp Thú, i.e. THREE elites;
- `boss`: Hắc Lang Vương + Thanh Lang + Trúc Thử, i.e. Boss **PLUS TWO adds**;
- `party_size 1` is a frontline only, `3` is frontline/mage/healer, `6` is frontline/ranged/mage/healer/frontline/ranged. **First frontline of party3/6 starts with 45% HP**, healer/guard action already relevant.
- Fixture heroes are manually constructed through `CombatStatsV2.derive(realm,1,body,1,0)` with **Potential=0, no gear, no actual D7 birth points, no spiritual-root/technique skill factor**. The actor rows omit `basic_interval/basic_ratio/move_speed` STYLE overrides; MapBattle defaults `basic_interval=1.6s`, `basic_ratio=1.0`, not real Sword style `1.10s` or Body `1.45s` from `DiscipleCombatLoadoutV2`. Fixture also supplies learned direct skill IDs directly, not full content-owned selection/recruitment and future ability utilization.
- Thus fixture **tests selected MapBattleV2 rules at its own injected role/gear/skill configuration**. It is not evidence of balanced real production loadouts, intended Sword DPS, D7 Potential, six fully sourced disciples, or live CARE Boss path. Do not cite its 1v3 defeat as genuine 1v1 failure.

## 2. MEASURED actual 1,240-fixture outcomes — old Combat V2 numeric scale

**All below R1.1 Tu Vi / R1.1 Body; 20 seeded battles each. Median times only among wins; other rows show observed active duration.**

| Actual encounter fixture | Wins/n | Median win time | Avg disciple downs | Avg dealt | Avg incoming | Avg effective heals |
|---|---:|---:|---:|---:|---:|---:|
| 1 frontline vs 3 normals | 0/20 | n/a | 1.00 | 122.72 | 190.00 | 0 |
| 3 (front/mage/heal) vs 3 normals | 20/20 | **16.50s** | 0.00 | 494.00 | 175.16 | 163.53 |
| 6 vs 3 normals | 20/20 | **9.25s** | 0.00 | 494.00 | 76.78 | 82.80 |
| 3 vs 3 elites | 0/20 | n/a | 3.00 | 319.39 | 589.70 | 124.20 |
| 6 vs 3 elites | 20/20 | **20.00s** | **1.80** | 949.05 | 562.08 | 180.09 |
| 3 vs Boss+2 adds | 0/20 | n/a | 3.00 | 628.19 | 649.73 | 184.23 |
| 6 vs Boss+2 adds | 20/20 | **16.50s** | **0.65** | 850.25 | 404.26 | 165.60 |

Notes: dealt numbers equal aggregate mob HP on full victory and are REAL code units **before ×100**; incoming is settled actual damage across allies (and may include damage to allies that fall); healing comes from true in-fixture Healer actions. Initial 45% HP deliberately reduces margin. 20/20 does not establish true win probability100%; a 95% two-sided binomial interval for20/20 still has lower bound about83%.

**Level and Body sensitivity**: 6v(Boss+2 adds) median TTK **16.5s** at realm1/body1, **14.25s** at realm5/body5, **14.25s** at 10/10, 20/20 and 30/30. **R5/body3 ≈16.25s** and **R20/body18 ≈16.25s**, with ~0.7–0.8 average downs compared with 0 at equal high realm; Body lag materially hurts team survival. These are real fixture observations, not proof every higher-rank region should run at a fixed14s.

**Event ledger**: 97,876 moves, 57,833 settled hits, 5,532 learned skill casts, 5,311 learned skill hit notifications, 2,860 healer acts, 2,112 generic guard acts, 2,581 telegraphs and 2,577 area releases. `hit` subtypes: 43,246 basics; 5,311 learned skill; 5,583 area slams; 3,693 mage area bursts. Learned casts split 4,039 `ngu_kiem_thuat`, 1,493 `thanh_phong_tram`. This verifies real cast/action mechanics and AoE in the sandbox, not other seven dormant learned ability consumers.

## 3. ×100 unit scaling INVARIANCE: don't confuse big HP numbers with balance

For any positive `s`, if attacker ATK, target DEF, all direct-multiplicative base stats and target HP are scaled by `s` while crit chance, skill ratios, percent effects, time and RNG are unchanged, V2 direct damage is homogeneous:
```text
D(A, DEF) = A * ratio * [2A/(2A+DEF_eff)] * other_dimensionless_modifiers
D(sA, sDEF) = s * D(A, DEF)
HP' = s*HP; effective_heal_from_attack' = s * effective_heal
```
**Consequence: ×100 simultaneous scaling alone does NOT change normalized HP loss, equivalent action counts or theoretical TTK**, aside from float numerical edge effects and **non-scaled fixed values/flat bonuses/absolute thresholds**. The 20/20 pass records are current **unscaled V2** and must not be relabeled ×100 tests, but they provide a valid dimensionless starting anchor.

Examples at R1 with no other sources:
- naked player old **190HP/23ATK/19DEF** → candidate **19,000HP/2,300ATK/1,900DEF**;
- Hắc Lang Vương old **546.25HP/34.385ATK/22.42DEF** → candidate **54,625HP/3438.5ATK/2242DEF**;
- generic healer old `1.8*23 =41.4HP` → new `1.8*2300=4140HP` **automatically**, NOT another forced ×100;
- Hồi Xuân absolute **+55**, rest **+5**, services, flat gear, DoTs or cast fixed heals **DO require source-specific reauthoring**, and CARE Injury downed sentinel `HP=1` NEVER auto-scales.

## 4. Boss and Elite candidate multipliers — recalibrated to measured GROUP baselines

At R1 fixture Boss group old HP:
```text
Boss: 190 * 1.15(species) * 2.5(tier) = 546.25
Adds: Thanh Lang 171 + Trúc Thử 133 = 304
GROUP TOTAL = 850.25     [at ×100 visual HP group 85,025]
```
Increasing Boss tier to `t` only changes Boss HP; group total `304+218.5*t`. The last column below is a **LINEAR HP/DPS PROXY ONLY**, using real 6v(Boss+adds) median16.5s as origin, **not a Godot simulated outcome under new tiers**.

| Boss tier HP factor | Boss HP in ×100 units | Group HP / baseline groupHP | 16.5s proxy |
|---|---:|---:|---:|
| 2.5 SOURCE | 54,625 | 1.000× | 16.5s |
| **5.0** | 109,250 | 1.642× | 27.1s |
| **8.0** | 174,800 | 2.413× | 39.8s |
| **10.0** | 218,500 | 2.927× | 48.3s |
| **12.0** | 262,200 | 3.441× | 56.8s |
| **14.0** | 305,900 | 3.955× | 65.3s |
| **18.0** | 393,300 | 4.983× | 82.2s |

**Corrected first test proposal: Boss tier HP 8 / 10 / 12** for a real 6v(Boss+2 adds) matched-rank scenario; `18` only as **stress test** under current MAX_SECONDS=90 and current generic Boss telegraph. For **6v1 isolated Boss**, do not derive acceptance from this group table; real geometry/healer/targeting changes. Boss+adds versus pure Boss must be separate fixtures and separate HP targets. This explicitly supersedes the prior document's blanket initial `BossHP18` recommendation.

At R1 `6v3 elites` baseline median20s, source EliteHP tier1.35. Scaling the three elite HP values uniformly (constant DPS proxy) gives:
| Elite tier HP | Group HP / source | 20s proxy |
|---|---:|---:|
| 1.35 | 1.00× | 20.0s |
| **1.8** | 1.33× | 26.7s |
| **2.0** | 1.48× | 29.6s |
| **2.5** | 1.85× | 37.0s |
| **3.0** | 2.22× | 44.4s |
| **5.0** | 3.70× | 74.1s |

**Corrected first test proposal: Elite tier HP 1.8 / 2.0 / 2.5 for 6v3**; `5.0` only stress, not default. Real initial 6v3 already has **1.8 downed disciples on average**; applying even modest elite HP increases can cause a large nonlinear shift in wipe-rate. Need independent **3v1 Elite** target and separate HP range because role/target count change.

These are trial NUMERICS, **NOT CODE authorization nor accepted balance**. HP multipliers alone cannot guarantee real fun; analyze enemy focus fire, AoE, summons, cast interruptions, guard/heal and 90s timeout together.

## 5. Timing, attack speed and skill-decision debt

From source:
- `STEP_SECONDS=.25`. `MapBattleV2.step` processes pending casts FIRST; a learned skill may **release damage and also be followed by an ordinary basic hit on the same 0.25s tick** if `next_basic` is ready. Casts are action-blocking while pending, but no universal GCD currently forbids release+basic in a single simulation tick. Future scheduler changes must preserve or intentionally version this interaction; never double-settle a skill in UI.
- Basic cooldown uses `next_basic=now+max(0.25,base_interval/(1+attack_speed))` and only checks on 0.25s grid. Effective interval rounds UP to the next grid point.
- Actual **Sword style** base1.10s: +0%=effective1.25s→24 basics/30s; +20%=1.00s→30; **+50%=0.75s→40; +100%=also0.75s→40**. This discontinuity is serious for future equipment affixes; spell/fixture base1.6sec have different thresholds.
- Fixture does **NOT** use Sword interval: its injected party defaults `base_interval=1.60`, effective1.75s at speed0. Don't calibrate Sword/Body/Spell burst based on fixture average basic interval.
- Only direct learned `effect=="damage"` P2 skills active in `MapBattleV2`: Thanh Phong Trảm and Ngự Kiếm Thuật. The other seven authored P2 effects are deferred here. `cast_speed` and `cooldown_recovery` exist as derived channels but are **not applied in `_try_learned_damage_skill`**. Generic frontline guard, healer heals, mage AoE, elite/boss AoE are separate role/monster actions.
- Recommended **DESIGN OPTION**, not code patch: fixed 0.25s canonical clock plus deterministic per-actor fractional attack-action progress/deadline carry, safe one-action-per-tick policy until higher rates need explicit specification; cast and basic contention resolved with a documented policy + save snapshot version; attack-speed never decrements time to negative; no duplicate skill or damage receipts. Before adopting, compare same seeded battle snapshots V2→V3 and prior pending-cast exactly-once semantics.
- Real combat auto skill choice needs source-driven action priority, target range, action opportunity cost and potential fight duration. Source priority can favor low-value available skill over a superior basic or vice versa; more skills != automatically more DPS.

## 6. Mandatory NEXT balance fixture design and gate

Run official Godot 4.7.2 on a **dedicated future approved test-only branch** based on the inspected PR #27 HEAD, **not** PR27 writer branch and not UI writer paths. This document does NOT grant code permission.

Minimum new scenario families (each with ≥30 deterministic seeds plus edge seeding):
1. **True 1v1 NORMAL**: 1 legal starting disciple vs 1 normal, fullHP and 45%HP variants, none/Thanh skill.
2. **True 3v1 ELITE**: 3 role-appropriate authentic loadouts vs 1 elite; no extra elite; with/without healer/guard.
3. **True 6v1 BOSS**: 6 authentic legal loadouts vs Boss alone; Boss tier 2.5/8/10/12/18 comparison and timeout/wipe.
4. **Actual 6v(BOSS+2ADDS)**: replicate source party and map positions, tier2.5/8/10/12/18, no synthetic 'real CARE Boss' claim.
5. **6v3 ELITE**: source tier1.35/1.8/2/2.5/3/5, record fallback and wipe.
6. **Skill and speed**: real sword/body/spell/balanced loadouts, +0/+20/+50/+100 speed, actual attack intervals, cast and release behavior, Ngự unlock, heal/guard/AoE, status/DoT only where consumers live.
7. **Growth**: R1/2/5/10/20/30 and body equal/-2, D7 Potential0/100/500/2500, naked/equipped, seed robustness, gear percent and fixed flat; +100 unit-scaling invariance against explicit before/after gear/medicine.
8. **Save, injury and rewards**: midcast persistence, character drop to HP1 / Injury120, 90s timeout, idempotent settlement/loot, multiple waves, anti-duplication, no free recovery through scaling.

Report: `outcome`, P10/P50/P90 TTK **per exact fixture type**, actual throughput, ratio of skill to total settled damage, action displacement, 2s burst, target-specific incoming, guard uptime, effective/overhealed HP, down count, timeouts, loot/hour with canonical time, 95% confidence intervals for win/wipe and exact state SHA. Never tune HP from only raw 30s dummy DPS or a mixed group mislabeled solo.

## 7. Decisions for owner

**KEEP as structure:** Combat V2 single simulation owner; 16 CombatStatsV2 stat channels; D7 two independent TamCăn/TứTính; Potential Realm-only for D7; owner-directed ×100 numeric display target; 30×10 realm and Body, injury0/1/120.

**SUPERCEDES trial-only recommendations** in previous V3 docs:
- Replace default "EliteHP5" with **test tier1.8/2.0/2.5** under actual 6v3.
- Replace default "BossHP18" with **test tier8/10/12** under actual 6vBoss+2adds; 18 stress only.
- No change to runtime PLAYER base19,000HP, still **trial input only**, because matching enemy skill/targeting and ×100 equivalence weren't fully tested.

**PENDING**: critical cast/action scheduling design decision, true legal loadout fixtures, Boss multi-phase authored behavior, full stat-affix budget, healer/tank participation balance, economic medicine and drops, 90s threshold and recovery, owner numeric lock. PR27 remains draft. UI team owns UI; this Combat Balance Lab only owns docs and analysis.
