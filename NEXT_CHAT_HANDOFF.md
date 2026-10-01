# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-01

Always inspect live `main` before editing.

## Runtime status

Real Windows + Godot 4.7.2 cumulative gate is green through P2.6:

- P0-P1.6: PASS
- P2.1 Cultivation: PASS
- P2.2 Spiritual Roots: PASS
- P2.3 Technique Economy: PASS
- P2.4 Cultivation Paths: PASS
- P2.5 Realtime Combat + Independent Skills: PASS
- P2.6 Forge + Equipment Tycoon: LOCKED / PASS

P2.7 is now **IMPLEMENTED / AWAITING RUNTIME GATE**.

Do not call P2.7 PASS until the real local cumulative gate succeeds.

## Read first

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. `docs/GAMEPLAY_REFERENCE_SYNTHESIS.md`
4. `docs/DISCIPLE_SYSTEM_DEEP_RESEARCH.md`
5. `docs/P2_7_DISCIPLE_LIFE_WORKFORCE_SPEC.md`
6. this file

## Core game identity

Primary operating rhythm: **Evil Hunter Tycoon**.

The player is the Sect Master. Disciples should autonomously live, cultivate, work, hunt, recover, buy/use equipment and form stories. The player manages infrastructure, policy, production, assignments and preparation and may directly command a specific disciple when needed.

Routine micromanagement must remain optional.

Reference responsibilities:

- `最强祖师` -> multidimensional disciple value, traits/quirks and production specialization;
- `The Lost Village` -> work priorities, groups and work/cultivation/recovery schedule;
- `Amazing Cultivation Simulator` -> work priorities, schedule and later mentor/inner-disciple opportunity cost;
- `鬼谷八荒` -> later sect rank/delegation/hall authority;
- `Sect Master / 宗门经理人` -> expedition -> warehouse -> production -> disciple growth loop;
- `修仙家族模拟器` -> later rule-based bulk assignment, stipend/loyalty and lineage ideas;
- RimWorld/ONI -> scalable priority/template management.

## P2.7 architecture implemented

P2.7 adds a separate workforce authority layer. Do not merge it into P1.5 `role_assignments`.

Distinct concepts:

1. `sect_rank` — sect status schema;
2. `profession_xp` / workforce specialization;
3. `work_group_id` / production group;
4. P1.5 combat/adventure team and role.

A disciple can be `Outer + Forging specialist + Forge Hall worker + Hunt-team member` simultaneously.

## P2.7 runtime state

Per disciple:

- comprehension;
- profession XP;
- profession traits;
- personal work priorities;
- work group;
- work progress;
- direct Sect Master command;
- sect-rank schema.

Sect:

- workforce feature flag;
- work policy;
- work groups;
- forge support points;
- workforce event count.

Persistence is canonicalized in `DiscipleState` and `SectState` and uses SaveService v2 lossless floats.

## P2.7 authority order

Current runtime arbitration:

1. survival emergency;
2. direct Sect Master command;
3. schedule phase;
4. personal/group work priority;
5. existing GoalSystem/DecisionSystem autonomy.

Mandatory event duty is deferred.

## P2.7 schedule

Deterministic 20-tick cycle with work/cultivation/recovery phases.

Policies:

- balanced;
- production_push;
- cultivation_focus.

This deliberately prevents an assigned worker from working forever and never cultivating/recovering.

## P2.7 direct commands

Persistent deterministic commands:

- WORK_PROFESSION;
- CULTIVATE;
- HUNT_REGION;
- RETURN_SECT;
- REST;
- HOLD_AT_SECT.

Commands have issued/expiry ticks and target. Completed/expired commands return the disciple to autonomy.

## P2.7 real profession loops

Only two professions have active gameplay in the vertical slice.

### Mining

- produces real Thanh Thiết into P2.6 `forge_materials`;
- raises mining XP;
- profession level/comprehension/traits change work speed;
- experienced miner can produce more yield than novice.

### Forging

- raises forging XP;
- produces `forge_support_points`;
- when workforce is enabled, `EquipmentSystem.craft()` consumes one point for +5% stat multiplier on the next real P2.6 craft;
- P2.6 behavior is unchanged while workforce is disabled.

## Recruitment update

P2.7 candidates now receive deterministic:

- comprehension;
- 0-2 profession traits.

This is the first step toward weak-combat but high-value production disciples. Do not add an overall score.

## Files

- `godot/src/simulation/workforce/workforce_system.gd`
- `godot/src/simulation/core/p2_7_factory.gd`
- `godot/src/simulation/state/disciple_state.gd`
- `godot/src/simulation/state/candidate_state.gd`
- `godot/src/simulation/state/sect_state.gd`
- `godot/src/simulation/recruitment/recruitment_system.gd`
- `godot/src/simulation/core/simulation_scheduler.gd`
- `godot/src/simulation/equipment/equipment_system.gd`
- `godot/tests/simulation/p2_7_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_7_workforce_test.gd`
- `godot/src/presentation/p2_7_workforce.gd`
- `godot/scenes/p2/p2_7_workforce.tscn`
- `tools/godot/Verify-P2-7.ps1`
- `Verify-P2-7.cmd`
- `Sync-P2-7.cmd`

## P2.7 gate intent

The gate must prove:

- P2.6 stays workforce-disabled;
- same seed gives same workforce profiles;
- mining produces real Thanh Thiết;
- work raises profession XP;
- experienced miner outperforms novice;
- schedule contains work/cultivation/recovery;
- direct Tông Chủ command overrides then releases control;
- forging support changes a real P2.6 craft;
- recruitment has deterministic non-combat aptitude;
- exact save/load and continuation remain deterministic;
- prior gates and invariants remain green;
- P2.7 scene smoke passes.

## Authoritative next command

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-7.cmd
```

If it fails, fix the first failing gate and rerun the same cumulative command. Do not weaken exact tests.

## Root launcher note

The new P2.7 root launchers exist. An attempted GitHub deletion of the old P2.6 root launcher pair was blocked by the tool safety layer, so do not assume the old pair is absent until verified/cleaned safely. The P2.7 pair is the authoritative pair going forward.

## Deferred after P2.7 vertical slice

Do not expand until P2.7 is runtime green:

- elder/hall-master delegation AI;
- salary/stipend + loyalty;
- master-disciple system;
- lifespan/death/succession;
- marriage/dual cultivation;
- active alchemy/herbalism/logistics loops;
- full spatial production/pathfinding;
- advanced equipment enhancement/reroll.
