# TÔNG MÔN BÁ ĐẠO — COMBAT V3 / PLAYABLE FIRST ROADMAP
**2026-10-24 | DOCUMENTED DESIGN, NOT CODE AUTHORIZATION OR OWNER NUMERIC SIGNOFF**

## 0. Why this roadmap supersedes over-analysis of monster HP

Owner feedback: real-time automatic combat with attack speed, learned skills, buffs/debuffs, loot → gear/technique → stronger characters → harder farming; no expectation of a final balanced number at incomplete content stage. Do not stall progress until all skills are finished and fully balanced; perform minimal gameplay integrity tests during feature development, broad systemic balance only at content milestones.

**Source checked:** PR27 draft `deeae081bcfbe1413d4cf60a29db7e58150888b5`, code SHA `80ed0270d2b7370f8feff1ce829f167146f3f341`, stacked PR26. Canonical `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`; `CombatSkillSystem`, `MapBattleV2`, `CombatStatsV2`, `DiscipleCombatLoadoutV2`. Combat V2 owns gameplay; CARE owns loot/Injury/save; PR27 already implements D7 but not x100 rebalance. PR24–27 draft, no merge by this packet. UI work belongs to another chat/workstream: this Combat Lab only edits docs.

**Terminology:** real-time ≠ turn-based. `MapBattleV2.STEP_SECONDS = 0.25` is an invisible deterministic combat simulation interval. Actor basic attack interval, movement, cast and cooldown are measured in simulated seconds. This 0.25-second battle simulation step is not the same thing as the canonical sect clock tick (e.g. Injury recovery 120 ticks). Gameplay stays real-time with renderer interpolation/visual events; no renderer rewrite authorized.

## 1. Actual skills in source (AUTHORING vs ACTIVE)

| ID | Effect | ratio x ATK before defense | cast | CD | Current learned skill execution |
|---|---|---:|---:|---:|---|
| thanh_phong_tram | damage | 1.35 | .30s | 2.8s | YES direct damage |
| truy_phong_bo | dash | .75 | .25s | 5.0s | DEFERRED |
| ngu_kiem_thuat | damage | 1.70 | .65s + projectile | 6.5s | YES direct damage at legal stage9 |
| chan_son_quyen | weaken | 1.45 | .45s | 3.4s | DEFERRED |
| kim_cuong_ho_the | guard | 0 | .25s | 8.0s | DEFERRED as learned skill; generic role guard already exists separately |
| bat_dong_than | guard | 0 | .45s | 14.0s | DEFERRED learned effect |
| hoa_cau | burn | 1.15 | .65s + projectile | 3.8s | DEFERRED |
| han_suong_an | weaken | .90 | .80s + projectile | 5.5s | DEFERRED |
| liet_diem | fire_combo | 1.45 | 1.0s + projectile | 7.0s | DEFERRED |

Current `MapBattleV2._try_learned_damage_skill` accepts only `effect=="damage"`; `DiscipleCombatLoadoutV2` keeps others in `deferred_skill_ids`. Generic healer/guard/mage AoE/boss telegraph are independent actions; must not count as execution of above learned abilities. Current learned skills do not yet consume `cast_speed`/`cooldown_recovery`, while basic attacks have .25s quantization plateaus.

### Skill contract for every ability, no extra universal resource bar

`id, path, element, unlock, target type, range, damage_ratio (if any), cast_seconds, cooldown_seconds, projectile_speed (if any), effect list, buff/debuff target, duration, source_id, stack rule, visual event, authoritative settle event`. Typed effects e.g. damage, dash, guard, burn/DoT, weaken, combo, heal/shield only when a real source owner exists. Every feature must be deterministic, save-safe, no repeat hit or loot. No new universal mana/Qi system unless a concrete skill requires it and owner approves.

**Rules proposal:** `raw predefense = effective ATK × damage_ratio`; defenses, crit, elemental, contextual effects applied via existing canonical Combat V2 single-hit rules. Distinguish **+15% ATK** vs **+15% final damage** vs **−15% damage taken**; never reinterpret them all as the same multiplier. Buff sources have typed scope, provider, duration, applicable stage, precedence, and explicit additive-vs-multiplicative policy to be reviewed alongside content. Do not invent buffs in UI without runtime settlement.

## 2. Play loop target

**Deploy ordinary field** → earn actual loot in canonical Warehouse → unlock/craft a real item or obtain technique materials → teach/upgrade skill / equip disciple → make previously dangerous elite manageable → obtain elite-specific crafting ingredients, manuals or fragments → form a multi-role squad → challenge authored Boss with AoE/telegraph → obtain distinct rare rewards → advance to next tier. Do not fake a kill→TuVi EXP reward; real TuVi is its own source and earned from authorized sources. All rewards settled exactly once; Injury1 recovers after120 canonical ticks.

**Do NOT use hidden rubber-banding:** monsters do NOT instantly copy the current party's dynamic power or adapt HP automatically to whatever gear the player has. Difficulty is static by monster tier/realm/map and authored behavior. Party-strength comparisons are a *designer benchmark*, not a runtime enemy rescaler.

## 3. Relative threat bands as provisional PVE design, without premature final HP

- **Ordinary:** legal same-rank solo or small team can farm safely with starter skills and sensible auto policy; still risky when several mobs gang up. Should allow early resources without forcing a rare drop.
- **Elite:** significantly harder than same-map ordinary; tests crowd control/guard/heal, target choice and skill timing. Reward noticeably better crafting/cultivation materials and possibly fragments. Can be defeated by a prepared party with normal loot, avoiding a bootstrap deadlock.
- **Boss:** requires prepared squad(s), telegraphed attack and genuine multi-role decisions; rare skill manual, special equipment component, technique or advancement loot. Do not assume Boss damage/HP is just a fixed ×18 from source; real group + adds and phase behavior determine difficulty. No last-hit exploit; B3 multi-team HP/loot owner contract remains separate.
- **Next-tier:** new materials enable stronger skill/gear so the next zone becomes approachable; after progress, earlier zone gets faster, preserving a power fantasy.

Quantifiable acceptance anchors deferred until each feature is present: win/wipe range by legal cohort, time-to-kill distribution, actual skill usage, focus-fire lethality, medicine cost per run, loot per canonical hour, time to first meaningful upgrade. Initially measure a few seeded runs and one visible scene, not exhaustive 1,240+ for every isolated coefficient change.

## 4. Vertical slices (sequential code ownership, progressively playable)

### V3-S1 — Real-time cadence + skill effect framework (technical floor)
- Preserve single `MapBattleV2` authoritative clock; implement fractional-rate attack scheduling if needed, make cast speed and cooldown recovery actually affect learned skills after explicit type/priority rules; resolve cast-versus-basic priority and snapshot compatible state. No duplicate actions; no hidden turn-taking.
- Implement typed statuses and an effect-application/expiry owner (source/time/stack) with safe save/replay; no independent second combat engine.
- Make **one simple damaging, one guard, one burn/DoT, one weaken** effect work in an honest single local PvE scenario. Use existing definitions; do not require full nine to pass S1.
- Minimal FAST QA: one fight, one damage skill, one buff/debuff expiry, speed monotonicity test, save midcast/resume and one CARE loot exactly once. Visual only via authentic battle events.

### V3-S2 — Complete 9 P2 authored skills + usable AI/loadout
- Finish dash, body weaken/guard, burn, water weaken, fire combo and any missing prescribed consumers until 9 definitions are actually active where unlocked. Distinct roles sword/body/spell; unlocked prerequisites; no accidental skill saturation or cast starvation; basic attacks still meaningful.
- Valid deterministic skill selection based on context and opportunity cost, not automatic spam / alphabetical choice. Replay seed; prevent per-target effect duplicate/stack overflow.
- FAST QA: one representative scenario per effect type; action telemetry, scope/target/expiry, save/load; not yet final DPS balancing.

### V3-S3 — Ordinary → Elite → Boss playable loot progression
- Build genuine authored Normal, Elite, Boss sandbox content in CARE with real spawn generation, telegraph, one HP and loot pool per true encounter, receipt/Warehouse exactly once; Boss live only after backend maps legitimate event. Upgrade content unlocks legal skills/gear/mats.
- Keep boss adds, healer and tank roles; solo ordinary starter can receive initial materials. No fabricated UI Boss. Avoid unnecessary map-topology complexification if arena already supported.
- FAST QA: complete repeated hunt→loot→craft/equip/teach→next field, no dead end; Injury120, offline/load replay.

### V3-S4 — Content variety / gear / cultivation scaling
- Expand actual item affixes and technique modifiers using registered 16 stat channels and explicit conditional effect consumers. Pilot 3–5 representative build archetypes rather than claim every future skill complete. Sample 1/5/10/20/30 matched-and-mismatched Realm/Body plus D7 potential and safe large numbers. Design tiered medication to support new scale; do not multiply economy blindly.
- Only after this, run **wide balance sweep** across role, tier, gear, affix and effects, tune static monster HP/ATK/DEF, rewards, healing, and class identities; report TTK/win/loss percentiles and economy ROI.
- UI chat owns presentation, and derives skill/HP events from runtime only.

### Balance policy: two gates, not infinite pre-tuning
- **GATE A per slice (mandatory safety):** scripts load, core combat works, no illegal skill execution, no negative/nonfinite stats, no duplicated damage/loot, save/reload deterministic, authored content visibly works. Small focused tests.
- **GATE B at content milestones:** group tests and tuning to make ordinary farm meaningful, elite hard but achievable, boss rewarding, and new equipment/skill actually increases power. No excessive micro-balance between incomplete features.
- **FINAL wide regression** only after enough content exists to represent player progression, supplemented by ordinary QA/bug fixes. An early proposal is a tunable pilot, never a permanent law.

## 5. Commit/code discipline & current handoff

- PR27 draft already owns D7 State/Foundation/Save + test; UI chat separately owns presentation. This chat makes **DOCS ONLY** changes, no gameplay code changes nor new overlapped Codex writer. Codex code instructions for V3-S1/S2 require a NEW user-authorized scoped packet and a stable PR27 base SHA (currently `deeae081bcfbe1413d4cf60a29db7e58150888b5`), actual test allowlist and migration policy. Existing PR24/25/26/27 remain unmerged.
- Existing prior V3 documents offering fixed Boss HP tier 8/10/12 and Elite 1.8/2.0/2.5 remain **exploratory benchmark candidates**, NOT prerequisites or numeric design locks. `19,000` HP is a proportional x100 baseline, NOT approved balance.
- **Recommended immediate action:** owner acknowledges PLAYABLE-FIRST principle and authorizes *separately* S1 read-only/code packet after UI writer confirms non-overlapping paths. In the meantime design the typed skill-effect schema and first four representative action fixtures; do not block whole project on 1,240 seeded rounds.
