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

## 5. Authority / document structure cleanup — COMPLETE

Status: **LOCKED 2026-10-06**

Completed:
- added `docs/GAME_SYSTEM_ARCHITECTURE.md` as the canonical system/layer/phase-discipline authority;
- simplified `AGENTS.md` to stable operating rules instead of historical progress;
- rewrote this checkpoint to current truth only;
- rewrote `NEXT_CHAT_HANDOFF.md` to avoid carrying obsolete phase history;
- removed stale A1/A2/B1 implementation diaries from P3.7 design specs;
- removed obsolete pre-implementation “next design / implementation order” sections;
- removed stale Windows-pending / implementation-not-started labels from design authorities;
- removed stale P2.12 implementation-status text from `DISCIPLE_MASTER_SCHEMA.md`;
- replaced obsolete Team Loot Bag building-tree mechanics with supplies/logistics carrying semantics;
- integrated the no-Loot-Warehouse rule into current design wording;
- design specs now define mechanics only;
- runtime/progress status now lives here, not inside every design file.

No gameplay code was added during this cleanup phase.

---

## 6. Current implementation phase

**P3.7A2R — LINH ĐIỀN COMPLETION**

Status: **DESIGN LOCKED / RUNTIME REVISION NOT STARTED**

Reason for reopening:
the old A2 proved that BuildingSystem supports a farming lifecycle, but it did not complete the full Linh Điền gameplay contract.

Canonical authority:
`docs/P3_7_SPIRIT_FIELD_SPEC.md`

### Locked corrections

Linh Điền backend should focus on:
- planting/tending time;
- passive growth time;
- harvest/processing time;
- yield;
- output Phẩm Lực;
- seed consumption/return;
- crop policy;
- multiple plots;
- multiple field instances;
- worker/building assignment.

Detailed tile-by-tile travel/haul is NOT required.
Movement/logistics may be represented as deterministic time overhead.

### Character interaction

No new seventh foundation stat is needed.

Use existing character authority:

- **Tư Chất:** no generic farming bonus;
- **Căn Cốt:** labor endurance/stamina and modest sustained work efficiency;
- **Cơ Duyên:** rare crop/mutation/exceptional seed outcomes;
- **Thông Tuệ:** profession XP / difficult-crop handling;
- **Mị Lực:** no routine field-production bonus;
- **Tiềm Lực:** no immediate crop-output multiplier.

Add one missing profession-specific talent:
- `herbalist_affinity` / Linh Thực Thiên Phú;
- primary effect: +80% Herbalism XP;
- only small secondary farming effects.

Spiritual Root/Bloodline/Physique do not provide universal farming multipliers.
Crop-specific elemental affinity may grant a small positive bonus with no mismatch penalty.

### Boundary

Linh Điền owns:
- plots;
- crops;
- seeds;
- field policy;
- field timing;
- yield/quality;
- field worker assignment;
- field milestones.

It does NOT privately reimplement:
- the global profession 1–1000 progression;
- universal passive cultivation from work;
- wages/personal Spirit Stones;
- generic Contribution rewards.

Those remain shared-system phases.

### Completion requirement

Do not close A2R until the completion gate in `docs/P3_7_SPIRIT_FIELD_SPEC.md` is satisfied.

---

## 7. Queued phases

No other gameplay phase may start while A2R is active.

B2 Construction Resolver is paused behind Linh Điền completion.
