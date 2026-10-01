# AGENTS.md — Tông Môn Tycoon AI Development Contract

## Authority order

1. current user instruction;
2. `CURRENT_CHECKPOINT.md`;
3. live code + tests;
4. active phase spec under `docs/`;
5. older discussion only for historical context.

## Non-negotiable rules

- Godot/GDScript is the simulation authority.
- Do not introduce a parallel JavaScript gameplay engine.
- Static content definitions and runtime state stay separated.
- Simulation code must not depend on presentation/UI nodes.
- Randomness must flow through deterministic seeded streams.
- Economy transactions must conserve P0 money unless a source/sink is explicitly declared.
- P2.3 spirit-stone sources/sinks must remain explicit and separate from P0 money conservation.
- Every runtime state mutation must preserve invariants.
- Prefer small composition-oriented systems over giant manager scripts.
- Do not call a change PASS without the active verification gate.
- New mechanics must have measurable gameplay/simulation impact; decorative labels alone do not count.

## Runtime baseline

Real Godot 4.7.2 cumulative runtime evidence confirms **P0 through P2.6 PASS**.

P2.6 is LOCKED. Do not weaken or bypass its contracts when designing later phases.

## Required loop

read checkpoint -> narrow scope -> patch -> static review -> headless import/parse -> simulation tests -> runtime smoke -> checkpoint

## Cumulative verification chain

- P0: `tools/godot/Verify-P0.ps1`
- P1.1: `tools/godot/Verify-P1-1.ps1`
- P1.2: `tools/godot/Verify-P1-2.ps1`
- P1.3: `tools/godot/Verify-P1-3.ps1`
- P1.4: `tools/godot/Verify-P1-4.ps1`
- P1.5: `tools/godot/Verify-P1-5.ps1`
- P1.6: `tools/godot/Verify-P1-6.ps1`
- P2.1: `tools/godot/Verify-P2-1.ps1`
- P2.2: `tools/godot/Verify-P2-2.ps1`
- P2.3: `tools/godot/Verify-P2-3.ps1`
- P2.4: `tools/godot/Verify-P2-4.ps1`
- P2.5: `tools/godot/Verify-P2-5.ps1`
- P2.6: `tools/godot/Verify-P2-6.ps1`

Latest authoritative launcher: `Sync-P2-6.cmd` until a later phase replaces it.

## Core character philosophy

The player is the sect master, not an invisible city-builder cursor.

The player sets infrastructure, recruitment, assignments, policies, investment and strategic direction, and can intervene directly when appropriate. Disciples should remain autonomous people inside the sect rather than puppets.

Do not introduce a fixed character class system. Sword/Body/Spell identity is emergent from cultivation/path history and compatible systems.

A disciple should be able to be valuable in different ways: combat, production, crafting, alchemy, farming, logistics, commerce, recruitment, teaching or other sect duties as later systems are introduced.

## Reference-game hierarchy

Primary operating rhythm: **Evil Hunter Tycoon**.

Use it for autonomous characters, town/sect economy, hunt -> material -> production -> consumption loops, and direct one-character commands from the Chief/Sect Master.

Use other references only for their strongest domain:

- `最强祖师`: traits/personality, multidimensional disciple value, production specialization;
- `The Lost Village`: work assignment, group/position preferences, work/cultivation/recovery scheduling;
- `鬼谷八荒`: sect rank, elders/halls, delegated task authority;
- `Sect Master / 宗门经理人`: expedition -> warehouse -> production -> disciple build -> harder expedition economy loop.

Read `docs/GAMEPLAY_REFERENCE_SYNTHESIS.md` before designing later disciple-management phases.

## P2.5 combat contract carried forward

- deterministic real-time autonomous combat;
- distance/movement, melee/ranged basics, cast time, cooldown, projectile travel and temporary effects;
- combat skills are independent from cultivation techniques;
- cross-path learning remains legal;
- P2.5 behavior remains unchanged when later feature flags are off.

## P2.6 locked contract — Forge + Equipment Tycoon

Required loop:

`hunt -> forge materials -> sect forge -> storage/shop -> autonomous purchase or player allocation -> stronger disciple -> harder hunt`

Locked behavior:

- autonomous equipment is default;
- player may manually equip;
- player may lock a slot against AI replacement;
- unlock returns to autonomous management;
- internal purchase conserves total money;
- item quality/identity is deterministic;
- nested equipment state survives exact save/load;
- equipment changes real region choice and combat consequences;
- compatibility changes actual effectiveness, not legality.

## P2.7 design candidate — Disciple Life + Workforce + Sect Assignment

Read `docs/P2_7_DISCIPLE_LIFE_WORKFORCE_SPEC.md` before implementation.

P2.7 is not runtime-locked yet, but the following architectural rule is mandatory:

**Sect rank, profession/work specialization, and combat/adventure role are three separate concepts.**

Do not overload P1.5 `role_assignments` with all three.

Target model:

- `sect_rank`: outer / inner / core / deacon / elder / hall master / ...;
- `profession_xp`: forging / alchemy / herbalism / mining / logistics / ...;
- combat/adventure role: existing P1.5 team behavior or future tactical role.

The first P2.7 implementation must remain narrow. Prefer proving Mining + Forging work, profession XP, schedule, group defaults and temporary direct Sect Master commands before adding many professions.

### P2.7 anti-patterns

- fixed profession classes;
- assigned work that permanently suppresses cultivation/recovery;
- one hard-coded DecisionSystem branch per future profession;
- candidate value represented only by combat power;
- requiring repetitive one-by-one micromanagement;
- decorative profession/trait labels without measurable consequences;
- AI replacing an active direct Sect Master command.
