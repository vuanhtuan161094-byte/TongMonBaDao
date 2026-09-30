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
- P1.4 and P1.5 may be implemented ahead of local runtime proof, but must remain explicitly AWAITING RUNTIME GATE until a real Godot 4.7.2 run passes.
- New mechanics must have measurable gameplay/simulation impact; do not add story-only state or title-only organization with no behavioral consequence.

## Required loop

read checkpoint -> narrow scope -> patch -> static review -> headless import/parse -> simulation tests -> runtime smoke -> checkpoint

## Locked regression gates

- P0: `tools/godot/Verify-P0.ps1`
- P1.1: `tools/godot/Verify-P1-1.ps1`
- P1.2: `tools/godot/Verify-P1-2.ps1`
- P1.3: `tools/godot/Verify-P1-3.ps1`

All locked gates remain mandatory for later P1 work.

## Pending P1.4 gate

`tools/godot/Verify-P1-4.ps1`

P1.4 adds bounded consequential memory. It remains implemented but unverified until the user returns to the Windows/Godot machine.

## Active P1.5 gate

`tools/godot/Verify-P1-5.ps1`

The P1.5 verifier chains P0 -> P1.1 -> P1.2 -> P1.3 -> P1.4 before running organization contracts and the P1.5 scene smoke. This allows one future local run to verify both pending P1.4 and P1.5.

P1.5 scope is limited to bounded teams, direct disciple-to-team lookup, team leadership, three consequential roles (hunter/logistics/guard), player team/leader/role assignment, relationship/memory-shaped leadership influence, save/load persistence, deterministic continuation, and a minimal management screen. Do not expand into sect upkeep/needs, buildings, morale, salaries, mentor/disciple hierarchy, romance, factions, betrayal, cultivation realms, bosses, premium currency, or production art during P1.5.
