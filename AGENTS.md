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
- P1.4, P1.5, P1.6, P2.1, P2.2, P2.3 and P2.4 may be implemented while the user is away from the Windows machine, but none may be marked PASS without real Godot 4.7.2 runtime evidence.
- New mechanics must have measurable gameplay/simulation impact; do not add story-only, title-only, rarity-label-only, elemental-label-only, class-label-only or decorative progress state.

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
- P1.6: `tools/godot/Verify-P1-6.ps1`
- P2.1: `tools/godot/Verify-P2-1.ps1`
- P2.2: `tools/godot/Verify-P2-2.ps1`
- P2.3: `tools/godot/Verify-P2-3.ps1`

## Active P2.4 gate

`tools/godot/Verify-P2-4.ps1`

P2.4 derives Kiếm/Thể/Pháp identity from accumulated use history instead of assigning a fixed class. Cultivation and combat with the active P2.3 technique grow that technique path; switching techniques changes future growth without erasing prior history.

Path depth must have real consequences: Kiếm affects effective combat power and hunting utility, Thể affects incoming damage and recovery/hunting utility, Pháp affects cultivation gain and cultivation utility, and same-path experience improves the active technique's real effects.

P2.4 must preserve P2.3 behavior when disabled and must not expand into master/disciple hierarchy, combat skills/moves, equipment, new profession paths, Dao event trees, pills, secret realms or factions.
