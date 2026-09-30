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
- Randomness must flow through a seeded RNG owned by the simulation.
- Economy transactions must conserve money unless a source/sink is explicitly declared.
- Every runtime state mutation must preserve invariants.
- Prefer small composition-oriented systems over giant manager scripts.
- Do not call a change PASS without the active verification gate.
- The locked P0 behavior path and locked P1.1 behavior path must remain available as regression baselines while later P1 features are added.

## Required loop

read checkpoint -> narrow scope -> patch -> static review -> headless import/parse -> simulation tests -> runtime smoke -> checkpoint

## Locked P0 regression gate

`tools/godot/Verify-P0.ps1`

P0 remains a mandatory regression baseline for every P1 change.

## Locked P1.1 regression gate

`tools/godot/Verify-P1-1.ps1`

P1.1 Goal + Personality remains a mandatory deterministic/save-load regression baseline for later P1 work.

## Active P1.2 gate

`tools/godot/Verify-P1-2.ps1`

The P1.2 verifier runs the complete P0 gate, then the locked P1.1 gate, then the P1.2 recruitment/player-choice contracts and the recruitment interaction-scene smoke test.

P1.2 scope is limited to deterministic recruitment candidates, sect population capacity, explicit player accept/reject decisions, save/load persistence, deterministic continuation, and a minimal interaction screen. Do not expand into relationships, memory, cultivation realms, bosses, premium currency, or production art during P1.2.
