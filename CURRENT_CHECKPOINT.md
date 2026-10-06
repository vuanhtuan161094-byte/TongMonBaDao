# CURRENT CHECKPOINT — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-06

This file contains **current truth only**.
It is not a historical changelog.

Read `docs/GAME_SYSTEM_ARCHITECTURE.md` for system structure and phase discipline.

---

## 1. Locked earlier baseline

Real Windows Godot 4.7.2 locked baseline:
- P0–P2.12;
- P3.1 landscape/living-sect shell;
- P3.2 map camera/selection + real disciple tabs;
- P3.2 live modular female map integration;
- P3.3 disciple operational flow;
- P3.4 building management;
- P3.5 living-sect cues;
- P3.6A runtime slice.

P3.6A final visual acceptance remains user-owned.
It is not a blocker for backend P3.7.

Do not reopen these phases without actual regression evidence.

---

## 2. P3.7 backend foundation completed

### P3.7A1 — Building Authority + Mine

Status: **BACKEND LOCKED — official Godot 4.7.2 CI green**

Implemented:
- generic `BuildingState`;
- generic `BuildingSystem`;
- stable building instance identity;
- Lv.1–100;
- worker slots;
- timed construction/upgrades;
- milestone state;
- Mine using existing `mining_crew`;
- travel -> mine batch -> haul/deposit;
- movement speed affects travel/haul;
- Căn Cốt affects hauling;
- Mining profession XP;
- Lv.10 Tầm Mạch Bàn milestone;
- save/load + deterministic continuation.

### P3.7A2 — Spirit Field / Linh Điền

Status: **BACKEND LOCKED — official Godot 4.7.2 CI green**

Implemented on the same BuildingSystem:
- `spirit_field_001`;
- `herbalism_crew`;
- worker-slot enforcement;
- travel -> tend/plant;
- building-owned crop growth;
- worker is free while crop grows;
- harvest-ready -> harvest -> haul/deposit;
- Herbalism profession XP;
- competing workers release cleanly when shared phase completes;
- Lv.10 Linh Tuyền Chi Tâm milestone;
- save/load + deterministic continuation.

Persistence fix discovered during A2:
- legacy disciples now preserve all six foundation values even when `profile_seed == 0`.

### P3.7B1 — Resource Registry + canonical Sect Warehouse

Status: **BACKEND LOCKED — official Godot 4.7.2 CI green**

Implemented:
- `ResourceRegistry`;
- explicit resource identity;
- family/tags;
- realm grade/rank;
- stable per-unit Phẩm Lực;
- one canonical P3.7 stackable-resource warehouse;
- no gameplay capacity ceiling;
- multi-million stacks;
- reserve minimum;
- resource lock;
- atomic multi-resource consumption;
- persistent quantities/rules;
- one-time migration from old P3.7 `forge_materials` + `technique_materials`;
- overlapping legacy IDs merge once;
- legacy P3.7 material buckets are cleared after migration.

Current P3.7 consumers using the canonical warehouse:
- construction/building upgrade;
- Mine production;
- Spirit Field harvest;
- Luyện Khí deposit/crafting;
- Công pháp material deposit/upgrade;
- Tinh luyện Linh Căn;
- Huyết Mạch;
- Thể Chất.

P2 behavior remains isolated when P3.7 resource authority is disabled.

---

## 3. B1 verification evidence

Official Godot 4.7.2 GitHub CI:
- A1 focused gate: GREEN;
- A2 focused gate: GREEN;
- B1 focused gate: GREEN;
- Resource Registry contracts: GREEN;
- 3,000,000-unit stack test: GREEN;
- reserve/lock tests: GREEN;
- old P3.7 save migration: GREEN;
- P2 legacy isolation: GREEN;
- all current material-consumer contracts: GREEN;
- cumulative P0 -> P2.12 + A1 + A2 + B1: GREEN.

Persistent commands:
- `Verify-P3-7A1-Building-Authority.cmd`;
- `Verify-P3-7A1-Building-Authority-Full.cmd`;
- `Verify-P3-7A2-Spirit-Field.cmd`;
- `Verify-P3-7A2-Spirit-Field-Full.cmd`;
- `Verify-P3-7B1-Warehouse.cmd`;
- `Verify-P3-7B1-Warehouse-Full.cmd`.

Do not describe these P3.7 CI runs as Windows evidence unless the Windows gate is separately run.

---

## 4. Locked P3.7 design corrections

### Warehouse
- no warehouse capacity gameplay limit;
- stacks may become extremely large;
- resources keep distinct IDs;
- Phẩm Lực does not replace item identity;
- one canonical main Sect Warehouse.

### Hunting rewards
- no Loot Warehouse;
- no persistent Team Loot Bag for rewards;
- item/material rewards -> main Sect Warehouse immediately;
- personal Tu Vi / Contribution / mastery / personal Spirit Stone share -> disciple immediately;
- carried inventory outside is supplies-only.

### Lifespan
- lifespan expiry does not delete a disciple;
- disciple becomes Ma/Hồn and stays in roster/history/relationships;
- valid longevity/revival effects may restore life;
- only expulsion removes the disciple from the sect roster.

### Time
- movement speed != attack speed != work speed != cast time != cooldown;
- construction/upgrades take real simulation time;
- no generic fake cooldown after building upgrade.

### Character foundation
Use the existing six dimensions:
- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

Do not create a parallel replacement stat block.

---

## 5. Current active phase

**AUTHORITY / DOCUMENT STRUCTURE CLEANUP**

No new gameplay feature is active right now.

Cleanup scope:
- simplify `AGENTS.md`;
- add one canonical system-architecture document;
- rewrite checkpoint/handoff to current truth only;
- remove stale implementation diaries from P3.7 design specs;
- remove obsolete “next phase” instructions;
- remove contradictory Loot Bag / Loot Warehouse wording.

This cleanup must finish before any B2 code begins.

---

## 6. Queued next gameplay phase — NOT STARTED

**P3.7B2 — Construction Resolver by material family + required Phẩm Lực**

Queued contract:
- normal building upgrade asks for total Construction Wood Phẩm Lực;
- normal building upgrade asks for total Construction Mineral Phẩm Lực;
- Linh Thạch remains currency input;
- specialty milestone component remains an exact named item;
- only eligible resource tags may satisfy a requirement;
- reserve/lock rules must be respected;
- prefer lower-value/lower-grade eligible stock first;
- do not consume rare/high-grade stock unnecessarily;
- no presentation work until backend B2 is locked.

B2 remains queued until the documentation cleanup phase is explicitly closed.
