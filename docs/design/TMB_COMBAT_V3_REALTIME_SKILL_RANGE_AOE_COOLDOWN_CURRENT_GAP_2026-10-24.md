# TÔNG MÔN BÁ ĐẠO — COMBAT V3: WHAT ALREADY EXISTS / SKILL RANGE, TARGETS, AUTO & STATUS
**2026-10-24; SOURCE AUDIT + PROPOSED DESIGN, docs-only.** Code source inspected on PR #27 `deeae081bcfbe1413d4cf60a29db7e58150888b5` (Godot code/test `80ed0270d2b7370f8feff1ce829f167146f3f341`). `main` at docs origin `29b5fba448b0178cb520a4ada44b375b4b934e31`. Existing PR24–27 remain draft. No code/test/runtime edits, no merge.

## 1. In plain language: the game is real-time
Character searches target → approaches attack/cast range → basic attack at own interval or casts a learned ready skill → damage after defense/element/crit → applies valid heal/guard/AoE → next action; on genuine kill CARE saves exactly-once loot. `MapBattleV2.STEP_SECONDS=.25` is the internal deterministic **combat** update resolution (4 checks per simulated second), NOT round-based combat, NOT the sect's 120 canonical ticks of Injury recovery. Rendering fps is separate from battle simulation; do not equate .25s with 4fps.

## 2. What source truly implements
| Mechanic | Real source | Status / boundary |
|---|---|---|
| Single automatic target | MapBattleV2._nearest_enemy | nearest alive enemy by arena coordinates, actor ID stable tiebreak; NO tank aggro/target scoring/taunt AI yet |
| Movement to attack | MapBattleV2.step | straight-line step until basic range; no obstacle-aware combat pathfinder in this isolated arena |
| Distinct basic profiles | CombatSkillSystem.style_profile | Sword range1.90 interval1.10 move3.10; Body1.35/1.45/2.50; Spell5.50/1.65/2.70; Balanced1.75/1.35/2.70. Distances are local **arena units**, NOT claimed meters or displayed pixels. |
| Learned skill range / cast / cooldown | CombatSkillSystem.SKILLS + _try_learned_damage_skill | range check at cast START and per-skill skill_ready; effects execute upon cast+travel delay if target is still alive, without final range/line-of-sight verification; learned direct-damage actions only |
| 9 skill descriptions | CombatSkillSystem.SKILLS | 2 learned direct damage effects live, 7 other P2 effect types deferred |
| Learned skill loadout | DiscipleCombatLoadoutV2 | learned, legal damage-only skill IDs collected and sorted, no user-configurable 4-slot active rotation in this bridge |
| Attack stat formula | CombatStatsV2.resolve_direct_hit | atk×ratio×(2atk/(2atk+def×(1-penetration)))×crit×elements×damage-reduction and context |
| Attack rate | MapBattleV2.step + CombatStatsV2.effective_interval | own basic_interval / (1+attack_speed), quantized to next .25s check; current speed plateaus |
| Cast & cooldown rate | CombatStatsV2 stats fields exist | **NOT consumed by MapBattle learned-skill pathway** yet |
| Generic self guard | MapBattleV2._guard_frontline | role frontline at HP<75%, 4s guard,9s generic cooldown; guard reduces actual incoming by35%; NOT Kim Cương/Bất Động learned skill |
| Generic healer | MapBattleV2._heal_ally | role healer, alive same-party ally within6 units and HP<65%, lowest ratio first; up to1.8×healerATK,5s generic cooldown |
| Generic mage AoE | MapBattleV2._cast_mage_aoe | if ≥2 enemies within3 units of nearest target, hit up to3 nearest-to-center, ratio .90 each, cooldown7s |
| Elite telegraph AoE | _begin_telegraphed_aoe | radius2.2, cast .75s, ratio.85, cooldown8s, at most3 targets |
| Boss telegraph AoE | _begin_telegraphed_aoe | radius2.8, cast1.00s, ratio1.10, cooldown7.5s, at most3 targets |
| AoE target selection | _area_targets | within selected radius sorted by center distance, tiebreak ID, caps at global MAX_TARGETS_AOE=3. Distances checked at release for telegraph. All current AoE is not proof arbitrary learned AoE skills work |
| Source/passive multipliers | CombatSkillSystem.effect_multiplier, DiscipleCombatLoadoutV2 | spiritual root, cultivation path, active technique and equipment can multiply legal learned skill power; not a typed timed-buff stack for all the other seven skills |
| CARE on real P3.2 | B3HuntWorld & B3PilotContent | **currently ONE disciple, ONE recurring Thanh Lang**; monster respawns8s, kill grants1 real `tinh_lang_bi` via canonical receipt, no live Boss multi-team or true 6-disciple CARE battle. Separate MapBattle/HuntingPveRunV2 can simulate many; up to6 per party,30 disciples/40 monsters cap in engine. |

## 3. Authored 9 skills are NOT synonymous with 9 live skills

| Skill | effect | Damage ratio | Cast | CD | Cast range | Runtime learnt skill effect |
|---|---|---:|---:|---:|---:|---|
| Thanh Phong Trảm | damage |1.35|.30s|2.8s|2.0| working single-target |
| Truy Phong Bộ | dash|.75|.25s|5.0s|7.0| deferred |
| Ngự Kiếm Thuật | damage|1.70|.65s+travel|6.5s|7.0| working single-target, min_stage9 |
| Chấn Sơn Quyền | weaken|1.45|.45s|3.4s|1.45| deferred |
| Kim Cương Hộ Thể | guard|0|.25s|8.0s|self| deferred |
| Bất Động Thân | guard|0|.45s|14.0s|self| deferred |
| Hỏa Cầu | burn|1.15|.65s+travel|3.8s|7.5| deferred |
| Hàn Sương Ấn | weaken|.90|.80s+travel|5.5s|6.5| deferred |
| Liệt Diễm | fire_combo|1.45|1.0s+travel|7.0s|6.0| deferred |

Example: Sword basic range1.90. A target six ARENA units away allows legal Ngự Kiếm cast (range7.0) IF learned/unlocked, but is outside sword basic range; the actor may begin projectile casting before walking to melee. This is real start-range logic. `projectile_speed=10` is a delay term, not a physical sprite collision/line-of-sight system.

## 4. Proposed per-skill contract; numbers are examples only

Every learned effect must define **start range**, **hit shape/radius**, **max targets / falloff rule**, **damage packet ratio and damage type**, **cast time**, **cooldown**, **projectile/travel**, **target lock/retarget rule**, **interruptibility**, **status type, value, duration, stacking**, **role/path/eligibility**, **AI policy**, **authored combat receipt/event**, **snapshot save version**, visual event name. Target count cap must be **per skill** or per explicitly chosen skill family, not one global 3.

Design examples, no CODE authorization and no claim already in source:
- light sword cleave: `start_range=2, cone radius~2, max_targets=3, ratio1.2 per target, cooldown4s`;
- ordinary fire circle: `start_range=7, radius3, max_targets=5, ratio1.0 + burn valid target, cooldown7s`;
- high-tier ultimate: `radius4, max_targets=8, ratio1.4, cooldown15s`;
- boss telegraph: start with current 3-target AoE until escape/AI counterplay exists; later can author `max_targets=6` per party, radius clearly communicated and adequate dodge window. These **3/5/8/6** are design trial values, NOT locked balance caps.

Target geometry definitions: single, cleave/cone, circle, chain, directed projectile, ground AoE, self, ally single, ally AoE. Source/target and falloff must be deterministic; live HP and spawn generation checked at settlement. Avoid unlimited splash in 40-monster combat unless a benchmark supports it. Do not automatically make Liệt Diễm or Hỏa Cầu AoE: their current source describes fire_combo and burn, respectively, not circle.

## 5. Who owns each property of a disciple and why a complete feature matters
- Foundation D7 grants innate stats, Tu Vi/Body realm are progression, roots and paths determine compatibility, `CombatSkillSystem.learn_skill` marks which individual learned a skill (eligibility via `cultivation_stage_index`, enabled gate). No complete teach/skill-level/4-active-slot economy is established by this minimal bool API; future fragments/manuals belong to their own content and receipts.
- Loadout must choose unlocked learned skills, active technique, equipment, combat role, target range and action priority. Currently direct-damage skills are gathered and sorted; there is no complete owner-configurable priority/conditional active skill build in that bridge.
- A skill is **COMPLETE** only when a real character can learn/unlock it legitimately, select it in a legal loadout, move/cast with correct range/timers, settle real damage/status on eligible targets, show truthful event/animation, recover from save/reload without double impact, and reward the kill once. A SKILLS dictionary entry alone is NOT completion.
- A buff/status has provider_id, source_id, target_scope, magnitude semantics (%ATK vs %final damage vs %DR), active time, update/expiration, stacking rules, status-resistance, and snapshot serialization. Generic frontline guard is a tiny pilot subset, not full skill buff ecosystem.
- Future healing skill vs role generic healer must not double-consume or double-cast in one instant without intentional action economy.

## 6. Efficient next vertical slices
1. **V3-S1 REAL CORE**: keep simulation real-time and the .25s canonical battle clock while making attack speed monotone and cast/cooldown stats meaningful; implement 1 learned guard + 1 learned burn/DoT + 1 learned weaken using typed effect/status layer; one existing damage skill; source-specific target count config; minimal automated decisions. Small focused tests + one actual short gameplay video.
2. **V3-S2 SKILL BUILDS**: finish all 9 P2 active consumers, clear individualized role/path, active skills/priority, legal unlock/teaching loop, debuff duration and stack; AI heal/guard/skill target choices; real performance/accuracy checks. Minimal gate per effect type.
3. **V3-S3 FARM & BOSS**: authored B3 CARE live small-team/elite/Boss, with multiple spawn slots, target/aggro/counters as needed, canonical loot/warehouse/save. Items or manuals from ordinary & elite must make higher content feasible without requiring Boss-only loot to kill that Boss. No artificial HP rubberbanding tied to player combat power.
4. **V3-S4 EXPAND CONTENT THEN BALANCE**: full item, buff/technique, potion x100 and survival economies; representative encounter test matrix/seed percentiles and per-map loot time, staged checks rather than exhaustive testing after every number.

**Two mandatory gates:** local integrity (no wrong targets, duplicate damage/casts/receipts, save idempotency) after each slice, and broader balance after each completed content cycle; final economy and full match simulations later.

## 7. Compatibility and work ownership
PR27 D7 & UI separate writer; other chat owns UI. This document ONLY. Do not modify PR27 code/Source A/map renderer or request CI/FULL/merge. New code authorizations must be explicit with path allowlist, head SHA, rollback and real Godot official focused tests.

Useful external corroboration, not authority for source: official Evil Hunter Tycoon support describes separately learned automatically used skills at https://evilhunter.zendesk.com/hc/en-us/articles/360039886791-Hunter-Skills; Godot fixed tick vs frames at https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/physics_interpolation_introduction.html.
