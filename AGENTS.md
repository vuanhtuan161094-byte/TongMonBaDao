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
- Locked P0, P1.1, and P1.2 behavior paths remain mandatory regression baselines.
- New mechanics must have measurable gameplay/simulation impact; do not add story-only state with no behavioral consequence.

## Required loop

read checkpoint -> narrow scope -> patch -> static review -> headless import/parse -> simulation tests -> runtime smoke -> checkpoint

## Locked P0 regression gate

`tools/godot/Verify-P0.ps1`

P0 remains a mandatory regression baseline for every P1 change.

## Locked P1.1 regression gate

`tools/godot/Verify-P1-1.ps1`

P1.1 Goal + Personality remains a mandatory deterministic/save-load regression baseline for later P1 work.

## Locked P1.2 regression gate

`tools/godot/Verify-P1-2.ps1`

P1.2 Population + Recruitment + Player Choice remains a mandatory deterministic/save-load/player-agency regression baseline for later P1 work.

## Active P1.3 gate

`tools/godot/Verify-P1-3.ps1`

The P1.3 verifier runs the complete locked P0/P1.1/P1.2 gates first, then the P1.3 relationship/behavior-impact contracts and relationship interaction-scene smoke test.

P1.3 scope is limited to sparse directed relationships, affinity/trust/respect, personality-shaped relationship reactions, relationship-driven region utility, explicit player companion assignment, recruitment integration, save/load persistence, deterministic continuation, and a minimal interaction screen. Do not expand into memory, romance, mentor/disciple hierarchy, factions, betrayal, cultivation realms, bosses, premium currency, or production art during P1.3.
