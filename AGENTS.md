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
- P1.4, P1.5, P1.6 and P2.1 may be implemented while the user is away from the Windows machine, but none may be marked PASS without real Godot 4.7.2 runtime evidence.
- New mechanics must have measurable gameplay/simulation impact; do not add story-only, title-only, realm-name-only or decorative progress state.

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

## Active P2.1 gate

`tools/godot/Verify-P2-1.ps1`

P2.1 adds cultivation progress, Luyện Khí/Trúc Cơ/Kim Đan stages, autonomous CULTIVATE/BREAKTHROUGH actions, player cultivation priorities, stage-dependent breakthrough risk, realm combat-power/HP bonuses and direct behavior/combat consequences. The old `combat_power` field remains base power so earlier factories stay behavior-stable.

P2.1 must not expand into spiritual roots, aptitude ratings, techniques, pills, tribulations, master/disciple hierarchy, realm skills, secret realms, bosses/factions or combat-team V2.
