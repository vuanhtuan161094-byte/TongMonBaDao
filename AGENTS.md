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
- P1.4, P1.5, P1.6, P2.1, P2.2 and P2.3 may be implemented while the user is away from the Windows machine, but none may be marked PASS without real Godot 4.7.2 runtime evidence.
- New mechanics must have measurable gameplay/simulation impact; do not add story-only, title-only, rarity-label-only, elemental-label-only or decorative progress state.

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

## Active P2.3 gate

`tools/godot/Verify-P2-3.ps1`

P2.3 adds Tàng Kinh Các ownership, in-game spirit-stone gacha, farmed technique fragments/materials, manual crafting/sale/archive choices, personal contribution + spirit-stone learning costs, up to three learned techniques with one active technique, mastery growth during cultivation, material-gated upgrades, technique path/element/role tags, and direct cultivation/breakthrough/combat/defense consequences.

P2.3 elemental roots exist only because they now affect technique compatibility. P2.2 must remain element-free and behavior-stable.

P2.3 must not expand into fixed character classes, simultaneous multi-technique stacking, technique combat skills, master/disciple hierarchy, pills/equipment, premium/real-money gacha, pity/banner systems, secret realms, bosses/factions or combat-team V2.
