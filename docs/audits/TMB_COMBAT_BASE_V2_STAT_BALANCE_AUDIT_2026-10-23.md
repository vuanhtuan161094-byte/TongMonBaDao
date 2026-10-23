# TÔNG MÔN BÁ ĐẠO — COMBAT BASE V2: STATIC STAT BALANCE AUDIT

**Date:** 2026-10-23  
**Nature:** READ-ONLY SOURCE AUDIT + INDEPENDENT ARITHMETIC; DOCS ONLY. **No Godot run, no gameplay tuning authorization, no balance coefficient changed, no FULL/CI, no merge.**  
**Base:** `main@29b5fba448b0178cb520a4ada44b375b4b934e31`. Combat source `godot/src/simulation/combat/combat_stats_v2.gd`; `monster_catalogue_v2.gd`; `monster_encounter_v2.gd`; `map_battle_v2.gd`; `disciple_combat_loadout_v2.gd`; `combat_skill_system.gd`. B3 CARE checked on **draft** PR #24, `integration/b3-care-main-20261022`, NOT merged.

## Executive verdict

**NUMERIC DESIGN LOCKED ≠ GAMEPLAY BALANCED.** Main already implements base Core/defense calculation; not enough evidence to call PvE, 16 dependent stats, skills/roles or 30-realm content balanced. Keep Combat V2 authority and user-approved `1.65 / 1.03 / 100,20,12 / 90,3,7 / K=2×ATK` untouched until measured scenario and owner authorization. This audit identifies balance/integration debt without altering game.

## A. Canonical source calculation

```text
G(r,f) = 1.65^(r-1) × 1.03^(f-1), r=1..30, f=1..10
RealmCore: HP100, ATK20, DEF12 × G(cultivation_r, cultivation_f)
BodyCore:  HP 90, ATK 3, DEF 7 × G(body_r, body_f)
PotentialFactor = 1 + 0.0005 × current_potential
Core = (RealmCore + BodyCore) × PotentialFactor
Final HP/ATK/DEF = max(channel_floor, (Core + approved_flat) × (1 + approved_percent_add))
DEF_effective = max(0, target_DEF_after_status × (1 - valid_attacker_penetration))
direct_damage = attacker_ATK × authored_skill_ratio × eligible_crit ×
                [2×attacker_ATK/(2×attacker_ATK + DEF_effective)] ×
                elemental_matchup × (1 - elemental_resistance) × (1 - damage_reduction)
```
`CombatStatsV2.derive` is implemented. The above damage formula applies ONLY eligible direct ATK-scaled packets, not all healing/true damage/DoT.

**Same-cultivation-and-body examples, Potential0, no flat/percent buffs** (rounded for display):

| Both realm.floor | G | HP | ATK | DEF |
|---|---:|---:|---:|---:|
| 1.1 | 1.0000 | 190 | 23 | 19 |
| 1.10 | 1.3048 | 247.91 | 30.01 | 24.79 |
| 2.1 | 1.6500 | 313.50 | 37.95 | 31.35 |
| 5.1 | 7.4120 | 1,408.28 | 170.48 | 140.83 |
| 10.1 | 90.6474 | 17,223.01 | 2,084.89 | 1,722.30 |
| 11.1 | 149.5683 | 28,417.97 | 3,440.07 | 2,841.80 |
| 20.1 | 13,557.9785 | 2,576,015.91 | 311,833.50 | 257,601.59 |
| 21.1 | 22,370.6645 | 4,250,426.25 | 514,525.28 | 425,042.63 |
| 30.10 | 2,645,875.4980 | 502,716,344.62 | 60,855,136.45 | 50,271,634.46 |

A floor raises its own Core growth 3%; equal-track 1.10→2.1 gives 1.65/1.03^9≈1.2645. A person advancing only ONE track does NOT receive that same total-character jump. Body at equal progress contributes ~47.37% Core HP, 36.84% DEF, 13.04% ATK. Potential 1,000 means Core ×1.5, not independently sourced item flats.

## B. All 16 headline stats and 10 resistance keys

| Group | Canonical channels | No-source baseline | Rule |
|---|---|---|---|
| Core | max_hp / attack / defense | 190/23/19 at both 1.1 | two independently scaled tracks + Potential + allowed sources |
| Timing | move_speed | 1.0× base action speed | multiplier (real units are in style/action) |
| Timing | attack_speed / cast_speed / cooldown_recovery | +0% each | interval / (1+rate); action consumer must actually use it |
| Crit | crit_chance / crit_damage / crit_resistance | 5% / 1.50× / 0pp | crit vs resistance, eligible actions only |
| Defense | defense_penetration | 0% | lowers positive remaining DEF |
| Status | effect_hit / effect_resistance | 0pp / 0pp | base status chance + hit - resistance, apply action rules |
| Defense | damage_reduction | 0% | independent sources multiply remaining damage |
| Siphon | lifesteal / lifesteal_reduction | 0% / 0% | subtract pp, heal from actual eligible target HP loss |
| Element | elemental_resistance map | zero in all 10 elements | independent remaining-damage reductions |

10 keys: metal, wood, water, fire, earth, lightning, wind, ice, yang, nether. These are not ten independent birth attribute rolls. Other authored conditional/specialized channels include damage-vs-boss/elite/race, followup, healing done/received, shield, all/direct/basic damage, DoT, skill, control; they are NOT extra universally applied character base stats.

Six Foundations are sources into *specific systems*, not six universal combat multipliers: Tư Chất→natural cultivation; Căn Cốt→body training; Thông Tuệ→learning/profession XP; Tiềm Lực→Core; Cơ Duyên→meaningful event check; Mị Lực→social/recruitment. Root/trait/bloodline/physique and learned equipment effects need real source→consumer gates before claiming buffs in PvE. No universal direct-attack Dodge/Accuracy and no combat_power as V2 damage authority.

## C. Static attack/defense sensitivity — THIS IS NOT GODOT PLAYTEST

At player 1.1 vs Thanh Lang 1.1, with current `MonsterCatalogueV2` species/tier stat factors: wolf HP171, ATK20.24, DEF13.68, while player HP190 ATK23 DEF19. Without crit/status/skill/movement:

- Player direct basic damage ≈17.73; needs **10 hits** against wolf 171HP; wolf direct hit ≈13.77 and needs **14 hits** to deplete player 190HP. This is HIT COUNT only, NOT elapsed fighting time or a proven win.
- Trúc Thử 1.1: player 8 hits; wolf analogue Hắc Lang 1.1: 12 hits vs 12 hits. Nham Giáp Thú elite1.1: player 25 hits, elite 12 hits. Hắc Lang Vương boss1.1: player 36 hits, Boss 8 hits, showing boss is group-oriented. These are bare 1v1 static exchanges, ignoring casts, positioning, healer and guard.
- Against the same wolf, **+10% player ATK** raises one-hit damage 17.73→19.92 (**+12.34%**, because ATK also changes the DEF attenuation factor); +20pp penetration vs this wolf raises 17.73→18.58 (**+4.8%**).
- For player defense versus this wolf, **+10% player DEF** lowers incoming hit 13.77→13.35 (**~3.1% reduction**). Equal percentage magnitudes across ATK/DEF/HP/DR thus do NOT have equal economic or combat values.
- Basic crit at 5% and crit ×1.50 gives expected direct-hit multiplier **1.025×**, absent target crit resistance, per eligible hit.
- Equal rank player and monster both share G. With no different buffs and unchanged action timing, all scaled HP, ATK and DEF grow proportionally, so normalized hit counts and same-tier duel TTK do NOT change from R01 to R30. This is mathematically consistent but insufficient to create tier-specific gameplay progression by itself.
- A R01.1 player vs R02.1 Thanh Lang instead requires ~19 hits to kill but survives ~8 monster hits (same fixed assumptions); this highlights a steep **one-major-realm mismatch**.

**Style profile basic-only static damage-per-second against mirror 1.1 DEF19**, before movement, skills, crit and frame quantization:

| Path | Base interval seconds | Basic damage ratio | Movement units/s | Paper basic DPS |
|---|---:|---:|---:|---:|
| sword | 1.10 | 1.00 | 3.10 | 14.80 |
| body | 1.45 | 1.15 | 2.50 | 12.91 |
| spell | 1.65 | 0.85 | 2.70 | 8.39 |
| balanced | 1.35 | 1.00 | 2.70 | 12.06 |

These are **not** total class DPS: learned skills, travel, AoE, tanking, heals, targets and casting compete with basic attacks.

## D. Concrete source drift and runtime coverage risks

1. **Boss coefficient drift:** `docs/DV2_02_CONTEXT_STATS_MONSTER_FOUNDATION.md` still describes pilot Boss ×4.00 HP / ×1.60 ATK / ×1.35 DEF, but actual **main** `MonsterCatalogueV2.TIERS.boss` is ×2.50 / ×1.30 / ×1.18. Runtime wins; old doc is historical until reconciled. Do not benchmark with both numbers mixed.
2. **Cast/recovery coverage in MapBattleV2:** `_try_learned_damage_skill` calculates `ready_at=now+cast_time+travel` and skill-ready at `now+base_cooldown`, **without consuming** `stats.cast_speed` or `stats.cooldown_recovery`. The stats exist but the learned-skill consumer in THIS map battle path does not apply the bonuses. Must be reviewed as integration coverage debt; no immediate code change authorized.
3. **Step discretization:** `MapBattleV2.STEP_SECONDS=0.25`; basic interval is `max(0.25, effective_interval)`, then scheduled on frame boundaries. Nominal +100% attack speed need not double delivered hits for every profile (e.g. sword interval 1.10→0.55 results in actual intervals roughly 1.25→0.75 seconds during uninterrupted attacks). Existing FPS/skill action conflicts make real throughput even more contextual.
4. **Gear/source bridge incomplete:** `DiscipleCombatLoadoutV2` maps some legacy item stats (speed, damage reduction, basic ratio/range), but deliberately does not treat P2 `combat_power` as `attack`. A full V2 gear and Root/Trait/Physique/Potential build cannot be declared balanced from the current pilot loadout.
5. **Tests are mechanics/sanity, not tuned targets:** `dv2_02_five_level_balance_test.gd` explicitly calls itself diagnostic and asserts that Level1 success is not worse than Level5 for identical groups, rather than a target PvE TTK, win rate, survival, or role fairness. `dv2_02_group_map_battle_test.gd` samples 16 seeds/scenario and compares weak vs strong groups; it does NOT lock desired win-rate thresholds. Existing successful CARE 13/13 or focused 28/28 proves correctness of their declared contracts, not overall player-stat balance.
6. **Encounter differences:** `MonsterEncounterV2.monster_basic_hit` disables basic crit for monsters, whereas `MapBattleV2._deal_direct` can roll the baseline 5% critical for ordinary monster basics. This is a path-specific mechanic discrepancy requiring an explicit unified decision or authored monster action metadata before final balancing.

## E. Required next BAL-BASE gates — documentation and benchmark first

- **B0 source reconciliation:** mark each of 16 stat channels as `derived/consumed in CARE/consumed in group map/only registered/deferred`, including Crit, Element, EffectHit and combat-special channels. Preserve current owner-locked laws.
- **B1 mathematical regression:** all 300 floors, both tracks matched + intentionally mismatched (e.g. R05 Tu Vi / R01 Body), Potential0/100/1000, expected damage scaling, HP ratio and edge cases; check attack/defense relative valuation, floats and UI formatting.
- **B2 controlled deterministic duels:** R01/02/03/05/10/20/30; monsters normal/elite/boss; +0/+1/-1 realm matchups; no gear, no skills, one variable at a time; log attacks, TTK, incoming damage, HP%, exact RNG seed, player stat snapshots. Do not invent a desired win rate.
- **B3 dependent stat A/B:** compare +0/10/25/50/100% attack/cast/cooldown, crit+resistance, penetration, HP/DEF/DR, elemental resistance, effect hit/res, lifesteal counter, healing, AoE and followup. Separate intended formula, actual resolved action events and source attribution.
- **B4 party benchmarks:** 1/3/6 and 2-team Boss; DPS, threat/mitigation, actual healing, support, idle/cast time, out-of-range and death. Repeat enough deterministic seeds to report outcome confidence, not just PASS marker; use live CARE path when it supports those compositions.
- **B5 target envelopes for owner approval:** normal/elite/Boss time-to-kill ranges, relative risk, role contribution targets, desired gap between same-rank and +1/-1 rank, maximum non-boss compulsory progression pain, percent source budget; **all OPEN** until measured and user approves.
- **B6 only then:** design equipment/technique/pill percentage budgets and loot economy; otherwise every new bonus changes an uncalibrated base.

**Decision requested later:** approve the fixture-based balance targets, NOT a silent edit to `G`, base stat 100/20/12–90/3/7, defense mitigation or skill coefficients. The Codex master recovery and PR #24/#25 remain separate untouched processes.
