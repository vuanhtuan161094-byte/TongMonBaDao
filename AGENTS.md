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

P2.6 is LOCKED. Do not weaken or bypass its contracts.

P2.7 is **IMPLEMENTED / AWAITING RUNTIME GATE**. Do not call it PASS until the cumulative Godot 4.7.2 gate reaches and passes it.

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
- P2.7: `tools/godot/Verify-P2-7.ps1`

Latest authoritative launcher: `Sync-P2-7.cmd`.

## Core character philosophy

The player is the Sect Master, not an invisible city-builder cursor.

The player sets infrastructure, recruitment, assignments, policies, investment and strategic direction, and can intervene directly when appropriate. Disciples remain autonomous people inside the sect rather than puppets.

Do not introduce a fixed character class system. Sword/Body/Spell identity is emergent from cultivation/path history and compatible systems.

A disciple can be valuable through combat, cultivation, crafting, production, logistics, social/administrative duties and later teaching/lineage systems.

## Reference-game hierarchy

Primary operating rhythm: **Evil Hunter Tycoon**.

Use it for autonomous characters, sect economy, hunt -> material -> production -> consumption loops, and temporary direct one-character commands from the Sect Master.

Use other references only for their strongest domain:

- `最强祖师`: multidimensional disciple value, traits/quirks, production specialization;
- `The Lost Village`: work assignment, group priorities and work/cultivation/recovery scheduling;
- `Amazing Cultivation Simulator`: work priorities and later mentor/inner-disciple opportunity-cost ideas;
- `鬼谷八荒`: sect rank, elders/halls and delegated task authority;
- `Sect Master / 宗门经理人`: expedition -> warehouse -> production -> disciple build economy loop;
- `修仙家族模拟器`: later bulk assignment rules, stipend/loyalty and lineage ideas;
- RimWorld/ONI: scalable priorities/templates for large autonomous rosters.

Read:

- `docs/GAMEPLAY_REFERENCE_SYNTHESIS.md`
- `docs/DISCIPLE_SYSTEM_DEEP_RESEARCH.md`
- `docs/P2_7_DISCIPLE_LIFE_WORKFORCE_SPEC.md`

## P2.6 locked contract — Forge + Equipment Tycoon

Required loop:

`hunt -> forge materials -> sect forge -> storage/shop -> autonomous purchase or player allocation -> stronger disciple -> harder hunt`

Locked behavior:

- autonomous equipment is default;
- player may manually equip;
- player may lock/unlock equipment slots;
- internal purchase conserves total money;
- item quality/identity is deterministic;
- nested equipment state survives exact save/load;
- equipment changes real region choice and combat consequences;
- compatibility changes actual effectiveness, not legality.

P2.7 hooks into P2.6 only when `workforce_enabled == true`. P2.6 behavior must remain unchanged when workforce is off.

## Active P2.7 contract — Disciple Life + Workforce + Sect Assignment

P2.7 must keep these concepts separate:

1. `sect_rank` — status/authority schema;
2. `profession_xp` + workforce specialization;
3. `work_group_id` — production group/department;
4. P1.5 combat/adventure team and role.

Do not overload one `role` field.

### Workforce authority order

1. survival emergency;
2. direct Sect Master command;
3. deterministic schedule phase;
4. personal/group work priority;
5. existing GoalSystem/DecisionSystem autonomy.

Direct commands must complete/expire and return the disciple to autonomy.

### P2.7 vertical slice

Only two professions have active gameplay:

- **Mining** -> real Thanh Thiết into P2.6 forge storage, mining XP, higher-level yield;
- **Forging** -> real forge-support points, forging XP, next P2.6 craft gets +5% stat multiplier when support is consumed.

Other profession IDs may exist as schema but do not count as completed systems.

### Schedule

A deterministic 20-tick schedule reserves time for:

- work;
- cultivation;
- recovery.

Policies: balanced / production_push / cultivation_focus.

Assigned work must not permanently suppress cultivation/recovery.

### Recruitment

Workforce-aware candidates gain deterministic comprehension and up to two profession traits. Do not collapse candidate value into one overall score.

### Persistence

P2.7 workforce state must survive exact SaveService v2 round-trip and deterministic continuation. `p2_7_persistence_diagnostic.gd` is the first-difference diagnostic.

### P2.7 anti-patterns

- fixed profession classes;
- one hard-coded DecisionSystem branch per future profession;
- work forever with no cultivation/recovery;
- candidate value only by combat power;
- repetitive one-by-one mandatory micromanagement;
- decorative aptitude/trait labels without consequences;
- AI replacing an active direct Sect Master command;
- expanding into loyalty/lifespan/master-disciple before the workforce gate is green.
