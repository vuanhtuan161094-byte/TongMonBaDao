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
- Randomness must flow through seeded simulation RNG.
- Economy transactions must conserve money unless a source/sink is explicitly declared.
- Every runtime state mutation must preserve invariants.
- Prefer small composition-oriented systems over giant manager scripts.
- Do not call a change PASS without the active verification gate.
- Locked P0, P1.1, P1.2 and P1.3 remain mandatory regression baselines.
- P1.4, P1.5 and P1.6 may be implemented while the user is away from the Windows machine, but none may be marked PASS without real Godot 4.7.2 runtime evidence.
- New mechanics must have measurable gameplay/simulation impact; do not add story-only, title-only or decorative resource state.

## Required loop

read checkpoint -> narrow scope -> patch -> static review -> headless import/parse -> simulation tests -> runtime smoke -> checkpoint

## Locked regression gates

- P0: `tools/godot/Verify-P0.ps1`
- P1.1: `tools/godot/Verify-P1-1.ps1`
- P1.2: `tools/godot/Verify-P1-2.ps1`
- P1.3: `tools/godot/Verify-P1-3.ps1`

## Pending gates chained into the active verifier

- P1.4: `tools/godot/Verify-P1-4.ps1`
- P1.5: `tools/godot/Verify-P1-5.ps1`

## Active P1.6 gate

`tools/godot/Verify-P1-6.ps1`

P1.6 adds bounded sect-level medicine, expedition supplies, lodging capacity, logistics production priority and resource-pressure consequences. Medicine must affect healing availability, supplies must affect expedition behavior/travel cost, lodging pressure must affect recovery, and player allocation must create a measurable tradeoff. Do not expand P1.6 into morale, salaries, building trees, crafting chains, combat-team V2, cultivation realms, romance/factions, premium currency or production art.
