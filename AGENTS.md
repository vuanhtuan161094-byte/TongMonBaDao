# AGENTS.md — TÔNG MÔN BÁ ĐẠO

This file is the repository operating contract.

## 1. Authority order

Before changing code or gameplay design, read in this order:

1. current user instruction;
2. `docs/GAME_SYSTEM_ARCHITECTURE.md`;
3. `CURRENT_CHECKPOINT.md`;
4. `NEXT_CHAT_HANDOFF.md`;
5. the active phase spec;
6. subsystem master specs, especially `docs/DISCIPLE_MASTER_SCHEMA.md` for character changes;
7. current live code.

Do not ask the user to repeat information already available in these authorities.

If two documents conflict:
- newer explicit user decision wins;
- then `docs/GAME_SYSTEM_ARCHITECTURE.md`;
- then the more specific subsystem spec;
- implementation status comes only from `CURRENT_CHECKPOINT.md`.

Design specs must not be treated as progress logs.

---

## 2. Engine / branch / workflow

Repository:
`vuanhtuan161094-byte/TongMonBaDao`

Primary branch:
`main`

Engine:
Godot 4.7.2

Before edits:
- fetch live `main`;
- inspect current code;
- do not assume a previous chat's HEAD is still current.

Use GitHub connector for repository edits.
Do not use Codex or Work for repository coding unless the user explicitly changes that instruction.

---

## 3. One-phase-at-a-time rule

There is at most one active implementation phase.

Do not start a neighboring gameplay phase until the current phase is closed.

A phase closes only when:
1. contract/scope is explicit;
2. implementation is complete for that scope;
3. focused Godot 4.7.2 gate is green;
4. cumulative regression is green when closing the phase;
5. `CURRENT_CHECKPOINT.md` records the result and names the next phase.

If a dependency is required to make the active phase correct, fix it inside the active phase.
Otherwise record it for later and do not implement it early.

Never implement speculative UI/data for a future phase.

---

## 4. Gate policy

Never call a phase PASS from static inspection alone.

During iteration:
- use FAST targeted gates;
- parse changed/adjacent scripts;
- run the active contract;
- use the smallest relevant smoke.

Run a FULL cumulative gate:
- when closing a phase;
- when a change crosses a locked subsystem;
- when regression evidence points into an older baseline.

Never weaken persistence, determinism, invariants or contract tests merely to make a gate pass.

GitHub Actions on official Godot 4.7.2 is valid runtime evidence.
Do not relabel CI evidence as Windows evidence.

For Windows:
- `Sync-Main.cmd` is the stable sync entrypoint;
- for a gate use `Sync-Main.cmd Verify-<gate>.cmd`;
- do not create phase-specific Sync launchers as the primary workflow.

---

## 5. Core architecture rule

Gameplay truth lives in simulation/runtime authority, not presentation.

Presentation may display state and issue real commands.
Presentation may not invent:
- resources;
- building levels;
- queues;
- production;
- upgrades;
- injury;
- ownership;
- cultivation;
- profession level;
- hunting rewards.

If backend authority does not exist yet, UI must not fake it.

Read:
`docs/GAME_SYSTEM_ARCHITECTURE.md`

---

## 6. Character authority

Read:
`docs/DISCIPLE_MASTER_SCHEMA.md`

Keep distinct:
- innate foundation;
- learned progression;
- Spiritual Root;
- Bloodline;
- Physique;
- traits/personality;
- equipment/loadout;
- living state;
- organization/social state.

Canonical six foundation dimensions:
- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

Do not replace them with a new parallel stat block.

---

## 7. Locked earlier baseline

Locked earlier runtime:
- P0–P2.12;
- P3.1;
- P3.2 map/camera/selection/real disciple tabs;
- P3.3 disciple operational flow;
- P3.4 building management;
- P3.5 living-sect cues;
- P3.6A runtime slice.

P3.6A final visual acceptance remains user-owned.
Do not reopen locked phases without real regression evidence.

---

## 8. P3.7 canonical direction

Parent:
`docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`

Children:
- `docs/P3_7_BUILDING_TREE_SPEC.md`
- `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`
- `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`
- `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`

Locked high-level rules:
- target scale 1,000–3,000 disciples;
- player manages policy/groups/teams/infrastructure rather than thousands of individuals;
- hunting is primary outward progression;
- rear-base professions support hunting and economy;
- no permanent disciple deletion from lifespan expiry;
- lifespan expiry -> Ma/Hồn state; only expulsion removes from roster;
- no reward Loot Warehouse;
- no persistent Team Loot Bag for rewards;
- ordinary item/material hunting rewards -> main Sect Warehouse immediately;
- one canonical P3.7 stackable-resource warehouse;
- no warehouse capacity gameplay ceiling;
- resource IDs stay distinct;
- realm grade + stable per-unit Phẩm Lực are metadata;
- building instances cap at Lv.100;
- normal levels scale numbers; milestones open mechanics;
- construction/upgrades take real simulation time;
- movement speed, attack speed, work speed, cast time and cooldown are separate concepts.

---

## 9. P3.7 backend currently locked through B1

Backend foundation:
- P3.7A1 Building Authority + Mine;
- P3.7A2 Spirit Field;
- P3.7B1 Resource Registry + canonical Sect Warehouse.

Exact evidence belongs in `CURRENT_CHECKPOINT.md`, not here.

Do not reintroduce:
- permanent P3.7 `forge_materials` authority;
- permanent P3.7 `technique_materials` authority;
- secondary reward warehouse;
- warehouse-capacity gating.

---

## 10. Current phase source

Do not duplicate current-phase status in AGENTS.

Read:
- `CURRENT_CHECKPOINT.md`;
- `NEXT_CHAT_HANDOFF.md`.

If the checkpoint says no implementation phase is active, do not start the queued next phase without a new user instruction.
