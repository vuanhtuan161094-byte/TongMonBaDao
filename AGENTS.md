# AGENTS.md — Tông Môn Tycoon AI Development Contract

## Authority order

1. current user instruction;
2. `CURRENT_CHECKPOINT.md`;
3. live code + tests;
4. `docs/P0_SPEC.md`;
5. older discussion only for historical context.

## Non-negotiable rules

- Godot/GDScript is the simulation authority.
- Do not introduce a parallel JavaScript gameplay engine.
- Static content definitions and runtime state stay separated.
- Simulation code must not depend on presentation/UI nodes.
- Randomness must flow through a seeded RNG owned by the simulation.
- Economy transactions must conserve money unless a source/sink is explicitly declared.
- Every runtime state mutation must preserve invariants.
- Prefer small composition-oriented systems over giant manager scripts.
- Do not call a change PASS without the active verification gate.
- P0 is simulation-first: do not add cultivation realms, relationships, boss systems, premium currency, elaborate art, or production animation.

## Required loop

read checkpoint -> narrow scope -> patch -> static review -> headless import/parse -> simulation tests -> runtime smoke -> checkpoint

## P0 active gate

`tools/godot/Verify-P0.ps1`

Required proof:
1. import;
2. changed-script parse;
3. deterministic invariant scenario;
4. save/load round trip;
5. bounded runtime smoke.

Visual approval is not required for P0 placeholder art, but runtime debug information must remain legible at 390x844.
