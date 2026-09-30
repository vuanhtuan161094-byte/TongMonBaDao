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
- Locked P0, P1.1, P1.2, and P1.3 behavior paths remain mandatory regression baselines.
- New mechanics must have measurable gameplay/simulation impact; do not add story-only state with no behavioral consequence.

## Required loop

read checkpoint -> narrow scope -> patch -> static review -> headless import/parse -> simulation tests -> runtime smoke -> checkpoint

## Locked regression gates

- P0: `tools/godot/Verify-P0.ps1`
- P1.1: `tools/godot/Verify-P1-1.ps1`
- P1.2: `tools/godot/Verify-P1-2.ps1`
- P1.3: `tools/godot/Verify-P1-3.ps1`

All locked gates remain mandatory for later P1 work.

## Active P1.4 gate

`tools/godot/Verify-P1-4.ps1`

P1.4 adds bounded consequential memory only. Memory must affect later behavior, remain sparse/bounded, preserve player-created consequences after direct orders are removed, serialize safely, and remain deterministic. Do not expand into romance, marriage, mentor/disciple hierarchy, sworn siblings, factions, betrayal/leaving, internal combat, cultivation realms, bosses, premium currency, or production art during P1.4.
