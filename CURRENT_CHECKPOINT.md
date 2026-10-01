# CURRENT CHECKPOINT

Date: 2026-10-01

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 cumulative evidence confirms:

- P0 Foundation: LOCKED / PASS.
- P1.1 Goal + Personality: LOCKED / PASS.
- P1.2 Recruitment + Player Choice: LOCKED / PASS.
- P1.3 Relationships + Behavioral Impact: LOCKED / PASS.
- P1.4 Consequential Memory: PASS.
- P1.5 Organization + Teams + Leadership + Roles: PASS.
- P1.6 Sect Life + Needs + Resource Pressure: PASS.
- P2.1 Cultivation + Realms + Breakthrough: PASS.
- P2.2 Spiritual Root Quality + Long-Term Growth: PASS.
- P2.3 Technique Economy + Library + Mastery: PASS.
- P2.4 Cultivation Paths / Character Dao Direction: PASS.
- P2.5 Combat Skills / Real-time Auto Combat: PASS.
- P2.6 Forge + Equipment Tycoon: LOCKED / PASS.

P2.6 final runtime evidence included persistence diagnostic, forge/equipment contracts, combat-stat consequence contracts and interaction scene smoke.

## Active phase

**P2.7 — Disciple Life + Workforce + Sect Assignment**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 RUNTIME GATE**.

Do not call P2.7 PASS until `Sync-P2-7.cmd` reaches the final P2.7 gate successfully on the Windows machine.

## Core product direction

Primary operating rhythm: **Evil Hunter Tycoon**.

- disciples move/live/work/fight autonomously;
- player is the Sect Master and manages infrastructure, production, policy, assignments and preparation;
- player can directly command a specific disciple when needed;
- routine micromanagement must remain optional;
- hunt/expedition/work rewards feed sect production, disciple growth and harder content.

Reference specializations:

- `最强祖师` -> multidimensional disciple value, traits, production specialization;
- `The Lost Village` -> work assignment, group priority and work/cultivation/recovery schedule;
- `鬼谷八荒` -> sect rank and later delegation/hall authority;
- `Sect Master / 宗门经理人` -> expedition -> warehouse -> production -> disciple build loop.

Research docs:

- `docs/GAMEPLAY_REFERENCE_SYNTHESIS.md`
- `docs/DISCIPLE_SYSTEM_DEEP_RESEARCH.md`
- `docs/P2_7_DISCIPLE_LIFE_WORKFORCE_SPEC.md`

## P2.7 implemented architecture

Three concepts remain separate:

1. `sect_rank` — sect status/authority schema;
2. `profession_xp` + workforce state — production specialization;
3. P1.5 combat/adventure roles — team behavior.

Do not merge these into one `role` field.

### Disciple workforce state

P2.7 adds opt-in state for:

- comprehension / learning aptitude;
- profession XP;
- profession traits;
- personal work priorities;
- work group;
- work progress;
- direct Sect Master command;
- sect-rank schema.

P2.6 disciples remain behavior-compatible because these mechanics activate only when `workforce_enabled == true`.

### Workforce groups

Initial groups:

- `mining_crew` — Đội Khai Khoáng;
- `forge_hall` — Luyện Khí Đường.

Group priorities provide scalable defaults. Personal priorities override group defaults.

### Schedule

P2.7 uses a deterministic 20-tick schedule with:

- work;
- cultivation;
- recovery.

Policies:

- balanced;
- production_push;
- cultivation_focus.

Assigned work cannot occupy 100% of time by default.

### Direct Sect Master command

Persistent deterministic commands:

- WORK_PROFESSION;
- CULTIVATE;
- HUNT_REGION;
- RETURN_SECT;
- REST;
- HOLD_AT_SECT.

Emergency survival remains above routine commands. A completed/expired command returns the disciple to normal autonomy.

### Real work consequences

**Mining**

- work completion increases mining XP;
- produces real `Thanh Thiết` in the P2.6 forge-material store;
- profession level/comprehension/traits affect productivity;
- experienced miner can yield more than a novice.

**Forging**

- work completion increases forging XP;
- creates forge support points;
- when P2.7 is enabled, a P2.6 craft can consume one support point for a real +5% stat multiplier on that item;
- P2.6 crafting remains unchanged while workforce is disabled.

### Recruitment

P2.7 candidates gain deterministic:

- comprehension;
- 0-2 profession traits.

This creates non-combat recruitment value without an overall-score shortcut.

## Persistence and determinism

P2.7 state is serialized through SaveService v2.

Canonical persistence covers:

- workforce flag/policy/groups;
- forge support points/counters;
- comprehension;
- profession XP/traits;
- work priorities/group/progress;
- direct commands with integer ticks;
- sect-rank schema.

A dedicated first-difference diagnostic exists:

- `godot/tests/simulation/p2_7_persistence_diagnostic.gd`

## P2.7 verification assets

- `godot/src/simulation/workforce/workforce_system.gd`
- `godot/src/simulation/core/p2_7_factory.gd`
- `godot/tests/simulation/p2_7_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_7_workforce_test.gd`
- `godot/src/presentation/p2_7_workforce.gd`
- `godot/scenes/p2/p2_7_workforce.tscn`
- `tools/godot/Verify-P2-7.ps1`
- `Verify-P2-7.cmd`
- `Sync-P2-7.cmd`

## P2.7 gate must prove

1. P2.6 remains workforce-disabled.
2. Same seed produces the same workforce profiles.
3. Mining produces real Thanh Thiết.
4. Work raises profession XP.
5. Experienced miner outperforms novice miner.
6. Schedule reserves work/cultivation/recovery.
7. Direct Sect Master command overrides routine assignment.
8. Completed command returns to autonomy.
9. Forging support changes a real P2.6 craft.
10. Recruitment has deterministic non-combat aptitude.
11. Save/load exact equality passes.
12. Post-load continuation remains deterministic.
13. All prior invariants and P0-P2.6 gates remain green.
14. P2.7 interaction scene launches headless.

## Deferred after P2.7 vertical slice

- elder/hall-master delegation AI;
- salaries/stipends and loyalty;
- master-disciple relationships;
- lifespan/death/succession;
- marriage/dual cultivation;
- active alchemy/herbalism/logistics loops;
- full spatial building/pathfinding workforce simulation;
- advanced equipment enhancement/reroll systems.

## Next authoritative local command

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-7.cmd
```

If the chain fails, fix the first failing gate only, rerun the same command, and do not weaken exact persistence/determinism contracts.
