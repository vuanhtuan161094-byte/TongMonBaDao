# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-01

Always inspect live `main` before editing.

## Read first

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. this file
4. `docs/P1_5_PERSISTENCE_RUNTIME_REPORT.md`
5. `docs/P2_6_SPEC.md`
6. live P2.1 diagnostic + P2.6 code/tests

## Runtime status

Real Godot 4.7.2 PASS evidence exists for:

- P0 Foundation
- P1.1 Goal + Personality
- P1.2 Recruitment
- P1.3 Relationships
- P1.4 Consequential Memory
- P1.5 Organization
- P1.6 Sect Needs

Current first failing gate:

- P2.1 FAIL — `cultivation state was not preserved by save/load`.

P2.2-P2.5 were not reached in the latest cumulative run because P2.1 stopped the chain.

P2.6 is implemented and statically hardened but has not been runtime-reached yet.

Do not call P2.1-P2.6 PASS without real local gate evidence.

## P1.5 persistence fix already closed

Do not reopen this unless a regression proves otherwise.

Root cause was one-ULP float64 loss through JSON decimal round-trip inside a nested `last_decision.region_scores` value.

Fix:

- SaveService v2 recursively wraps float64 as exact eight-byte hex;
- legacy v0/v1 still load;
- strict immediate save/load equality PASS;
- 800 continuation ticks PASS;
- P1.5 organization test PASS.

Fix commit: `c895bdf114c8b11c2f84095c6da517b66f82f5fe`.

## P2.1 blocker workflow

A dedicated diagnostic exists:

`godot/tests/simulation/p2_1_persistence_diagnostic.gd`

`tools/godot/Verify-P2-1.ps1` runs it before the ordinary P2.1 test.

The next cumulative local run should print the exact first persisted-state difference if P2.1 still fails.

Fix the real field/serialization problem; do not weaken equality tests or add tolerance just to make the gate green.

## Core game philosophy

The player runs the sect rather than puppeting every disciple.

The player controls infrastructure, production, recruitment, priorities and resources and may intervene directly when desired. Disciples otherwise act autonomously from personality, history, relationships, realm, roots, techniques, path history, learned combat skills and equipment.

The game may borrow useful operating loops from Evil Hunter Tycoon, but remains a cultivation sect-management game rather than a manual action RPG.

Every mechanic must have measurable simulation/player-decision consequences.

## Progression stack

- P2.1: cultivation -> breakthrough -> realm.
- P2.2: spiritual-root quality/elements.
- P2.3: cultivation-technique economy + Tàng Kinh Các + mastery.
- P2.4: classless Kiếm/Thể/Pháp identity from accumulated path XP.
- P2.5: independent combat skills + deterministic real-time auto combat.
- P2.6: forge/equipment tycoon loop.

## P2.6 user-approved design

Primary loop:

`hunt -> forge materials -> Luyện Khí Đường -> forged item -> sect storage/shop -> autonomous purchase OR player allocation -> equipment changes power -> harder hunt`.

### Autonomous equipment

Disciples score equipment from:

- real compatible stats;
- path depth;
- active technique path;
- learned combat skill paths;
- spiritual-root element;
- personality/risk/survival;
- price;
- spend bias and wallet reserve;
- sect equipment policy.

A higher raw-stat item is not automatically better for every disciple. The same item can have different effective combat power on different builds.

### Player equipment authority

The player can always:

- manually equip an item;
- lock the slot so AI cannot replace it;
- unlock / return to auto;
- unequip to sect storage.

Manual locked slot overrides AI. Micromanagement remains optional.

Unlocked slots are represented canonically by removing the lock key, not persisting `false`; this avoids exact save/load drift.

### Closed internal money

An autonomous shop purchase transfers money only:

`disciple wallet - price -> sect treasury + price`.

Total simulation money is unchanged.

Manual equipment allocation is not a purchase.

Initial forging consumes materials only; no undefined outside money sink has been introduced.

### P2.6 initial content

Forge materials:

- Linh Mộc
- Thanh Thiết
- Tinh Lang Bì
- Yêu Đan

Initial recipes:

- Thanh Thiết Kiếm — Sword / Metal
- Huyền Thiết Quyền Sáo — Body / Earth
- Linh Mộc Pháp Trượng — Spell / Wood
- Tinh Lang Giáp — armor / Body / Earth
- Hỏa Vân Ngọc — talisman / Spell / Fire

Quality:

- Phàm phẩm
- Tinh phẩm
- Thượng phẩm

Quality roll is deterministic from simulation seed + forge index + recipe identity.

## P2.6 files

- `docs/P2_6_SPEC.md`
- `godot/src/simulation/equipment/equipment_system.gd`
- `godot/src/simulation/core/p2_6_factory.gd`
- `godot/src/simulation/state/sect_state.gd`
- `godot/src/simulation/state/disciple_state.gd`
- `godot/src/simulation/core/simulation_scheduler.gd`
- `godot/src/simulation/ai/decision_system.gd`
- `godot/src/simulation/combat/combat_system.gd`
- `godot/tests/simulation/p2_6_equipment_test.gd`
- `godot/tests/simulation/p2_6_equipment_combat_effects_test.gd`
- `godot/src/presentation/p2_6_equipment.gd`
- `godot/scenes/p2/p2_6_equipment.tscn`
- `tools/godot/Verify-P2-6.ps1`
- `Verify-P2-6.cmd`
- `Sync-P2-6.cmd`

Only the latest root `.cmd` launchers should remain: `Sync-P2-6.cmd` and `Verify-P2-6.cmd`. Older cumulative PowerShell verifiers remain under `tools/godot`.

Root `.gitignore` ignores root `VERIFY*.txt` and diagnostic `.txt` output so local verification logs do not block `Sync-P2-6.cmd`.

## Current P2.6 runtime wiring

Implemented in source:

- combat wins create forge-material loot when P2.6 enabled;
- returned materials are separated into the sect forge store before ordinary sale;
- forging consumes materials and creates deterministic item instances;
- autonomous equipment buying is build-aware and price-aware;
- player manual equip / lock / unlock / unequip;
- purchases conserve total money;
- equipment combat power is compatibility-adjusted by path/root/technique/learned skills;
- equipment combat power affects real P2.5 encounter power;
- equipment combat power affects autonomous region choice;
- armor `defense_reduction` multiplies real incoming damage;
- `move_speed`, `basic_speed`, `basic_range`, `basic_ratio` modify real P2.5 combat style;
- `skill_effect` modifies real skill utility, hit damage and burn damage based on path/element match;
- P2.6 state is serialized through existing SaveService v2.

All equipment hooks are gated behind `equipment_enabled`, so P2.5 remains behavior-compatible when the feature is off.

## P2.6 test contract

`godot/tests/simulation/p2_6_equipment_test.gd` covers the main tycoon/economy/persistence loop:

- P2.5 factory remains equipment-disabled;
- hunt -> material deposit;
- deterministic forging;
- different builds value and use equipment differently;
- autonomous purchase works;
- internal purchase money is conserved;
- manual lock defeats AI replacement;
- unlock returns control to AI canonically;
- equipment changes region selection;
- equipment combat power changes controlled combat outcome;
- save/load exact equality;
- deterministic post-load continuation;
- all prior invariants + equipment invariants.

`godot/tests/simulation/p2_6_equipment_combat_effects_test.gd` separately proves real resolver wiring for:

- armor damage reduction;
- equipment skill-effect damage;
- weapon basic speed/range behavior.

`tools/godot/Verify-P2-6.ps1` runs both tests before the interaction scene smoke.

## Deferred

Do not expand P2.6 yet into:

- +N enhancement;
- reroll/large random affix system;
- set bonuses;
- forge failure;
- blacksmith skill progression;
- durability/repair;
- auctions;
- pet equipment;
- artifact AI;
- multi-workstation production queues;
- undefined external money sources/sinks.

Master/disciple also remains deferred unless the user explicitly selects it later.

## Next action

When the Windows machine is back on:

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-6.cmd
```

The cumulative chain will first reproduce/diagnose P2.1. Fix the first failing gate, rerun the same command, and continue sequentially until P2.6 is actually reached and verified.
