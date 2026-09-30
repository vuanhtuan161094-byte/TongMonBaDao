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
- P2.3 spirit-stone sources/sinks must be explicit and must not contaminate P0 money conservation.
- Every runtime state mutation must preserve invariants.
- Prefer small composition-oriented systems over giant manager scripts.
- Do not call a change PASS without the active verification gate.
- Locked P0, P1.1, P1.2 and P1.3 remain mandatory regression baselines.
- Real runtime evidence currently confirms P0 through P1.6; P2.1 is the first active persistence blocker.
- P2.2 through P2.6 may be implemented while the user is away from the Windows machine, but none may be marked PASS until the cumulative Godot 4.7.2 gate actually reaches and passes them.
- New mechanics must have measurable gameplay/simulation impact; do not add story-only, title-only, rarity-label-only, elemental-label-only, class-label-only or decorative progress state.

## Required loop

read checkpoint -> narrow scope -> patch -> static review -> headless import/parse -> simulation tests -> runtime smoke -> checkpoint

If the Windows/Godot runtime machine is unavailable, complete the read/narrow/patch/static-review/checkpoint portion honestly and leave runtime status as awaiting gate.

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

Authoritative local launcher: `Sync-P2-6.cmd`.

## P2.5 combat contract carried forward

P2.5 adds deterministic real-time autonomous combat when `combat_skills_enabled` is enabled. It models combat time, distance, approach/keep-distance behavior, melee/ranged basics, cast time, cooldown, projectile travel and a deliberately small set of meaningful short-lived effects.

Combat skills remain independent from P2.3 cultivation techniques. Technique is the cultivation foundation; realm gates capability; combat skills are separately learned actions. Do not turn one technique into a fixed five-skill class kit.

Sword/Body/Spell differ through actual spacing and combat behavior, not only coefficients. Spiritual-root affinity, P2.4 path expertise and compatible active technique may modify combat-skill effectiveness without hard-locking cross-path learning.

P2.5 must preserve the exact P2.4 legacy resolver while `combat_skills_enabled == false`.

## Active P2.6 contract — Forge + Equipment Tycoon

P2.6 is enabled only by `P26Factory` / `equipment_enabled` and must leave P2.5 behavior unchanged when the flag is false.

The required economic/gameplay loop is:

`hunt -> forge materials -> sect forge -> equipment storage/shop -> autonomous purchase or player allocation -> stronger disciple -> harder hunt`.

### Equipment authority

- Autonomous equipment is the default.
- A disciple evaluates gear from real build state, including path history, active technique, learned skill paths, root element, personality and price sensitivity.
- The player may manually equip an item at any time.
- A player-locked slot cannot be replaced by AI.
- Unlocking a slot returns it to autonomous management.
- No fixed Sword/Body/Spell class lock is allowed; compatibility changes value/effectiveness, not legality.

### Economy

Internal purchase must conserve P0 money:

`disciple wallet - price -> sect treasury + price`.

Manual equipment allocation is not a purchase.

Do not introduce an undeclared external money source/sink. The first forge slice consumes explicit materials only.

### Determinism and persistence

- Forge quality must come from deterministic seeded state, never wall-clock time.
- Equipment item IDs and forge sequence must be stable.
- Equipment instances, locations, owners, policies, equipped slots and lock states must survive SaveService v2 exact round-trip.
- Same-seed forging and post-load continuation must remain deterministic.

### Required real consequences

At minimum P2.6 must prove that equipment can:

- change autonomous purchase choice;
- change autonomous region choice through effective power;
- change a controlled real combat outcome;
- preserve internal money during purchases.

Do not count a rarity label or visual equipment panel as completion by itself.

## P2.6 bounded scope

Do not expand the current vertical slice into the following until the base loop passes runtime:

- +N enhancement;
- large random-affix/reroll economy;
- set bonuses;
- forge failure;
- blacksmith skill progression;
- durability/repair;
- auction house;
- pet equipment;
- autonomous artifact AI;
- multi-workstation crafting queues;
- undefined external money sources/sinks;
- master/disciple unless explicitly selected later by the user.
