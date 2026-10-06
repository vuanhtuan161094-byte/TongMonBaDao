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
- Mine using `mining_crew`;
- travel -> mine batch -> haul/deposit;
- Mining profession XP;
- Lv.10 Tầm Mạch Bàn milestone;
- save/load + deterministic continuation.

### P3.7A2R — Spirit Field / Linh Điền Completion

Status: **BACKEND LOCKED — official Godot 4.7.2 fast + full cumulative CI green**

Canonical simplified runtime:
- one plot = one authoritative timer: start -> countdown -> harvest resolve;
- no seed item;
- no backend walking/tending/harvest/haul phases for Linh Điền;
- crop start consumes Sect Spirit Stones immediately;
- cancel has no default refund;
- multiple independent plots per field;
- multiple Spirit Field instances;
- concrete `worksite_building_id` assignment;
- worker is released immediately after starting a plot;
- AUTO_DEMAND / PRIORITY / FIXED crop policies;
- crop registry with explicit output ID, realm/tier, field-level requirement, cost, time and yield;
- profession level improves cycle speed at +1% per level;
- generic data-driven `work_speed` and `profession_xp` modifier channels;
- Cần Mẫn/Cẩu Thả are content data, not hard-coded work formula branches;
- shared lục-duy factor = `0.75 + 0.50 × normalized value`;
- Tư Chất -> cultivation gain;
- Căn Cốt -> body-training authority, not generic profession stamina;
- Cơ Duyên -> rare chance;
- Thông Tuệ -> profession/skill learning;
- Mị Lực -> social-effect authority;
- Tiềm Lực -> future long-term permanent growth authority;
- Linh Thực Thiên Phú grade 1–5 -> +5/+10/+15/+20/+25% profession XP;
- lucky harvest ×4 / ×3 / ×2 uses snapshotted rare factor at crop start;
- passive work Tu Vi is granted only for actual work action, never passive crop countdown;
- field-level speed/yield and milestone factors;
- direct deposit into canonical Sect Warehouse;
- legacy A2 single-crop state migration;
- save/load mid-cycle + deterministic continuation;
- legacy disciple/candidate persistence compatibility preserved.

### P3.7B1 — Resource Registry + canonical Sect Warehouse

Status: **BACKEND LOCKED — official Godot 4.7.2 CI green**

Implemented:
- `ResourceRegistry`;
- explicit resource identity;
- family/tags;
- realm grade/rank;
- **no Phẩm Lực runtime authority**;
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

## 3. Verification evidence

Official Godot 4.7.2 GitHub CI:
- A1 focused gate: GREEN;
- A2R focused gate: GREEN;
- B1 focused gate: GREEN;
- full cumulative P0 -> P2.12 + P3.7 A1 + A2R + B1: GREEN;
- latest closing run: P3.7 Backend run #48, commit `509a650b97852a306af4a0581fece2359db4615e`.

A2R closing coverage includes:
- plot timers;
- Spirit Stone cost / insufficient funds / no-refund cancel;
- multiple plots and workers;
- multiple fields and specific worksites;
- crop policies;
- generic modifiers;
- profession learning and long-term profession level;
- lucky harvest;
- field levels/milestones;
- work-only passive Tu Vi;
- canonical warehouse deposit;
- legacy field migration;
- exact save/load;
- deterministic continuation;
- locked earlier regression.

Persistent commands:
- `Verify-P3-7A1-Building-Authority.cmd`;
- `Verify-P3-7A1-Building-Authority-Full.cmd`;
- `Verify-P3-7A2-Spirit-Field.cmd`;
- `Verify-P3-7A2-Spirit-Field-Full.cmd`;
- `Verify-P3-7B1-Warehouse.cmd`;
- `Verify-P3-7B1-Warehouse-Full.cmd`.

Do not describe GitHub CI evidence as Windows evidence unless a Windows gate is separately run.

---

## 4. Locked P3.7 design corrections

### Warehouse
- no warehouse capacity gameplay limit;
- stacks may become extremely large;
- resources keep distinct IDs;
- no continuous Phẩm Lực;
- progression uses explicit ID + realm/tier + quantity;
- one canonical main Sect Warehouse.

### Shared character/work model
Keep the six existing foundation dimensions:
- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

Use one simple common factor:
**`0.75 + 0.50 × normalized foundation value`**

Each foundation has one primary role instead of being forced into every profession.

Routine percentage content should use generic modifier channels rather than name-specific formula branches.

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
- passive production timer is not active disciple work.

---

## 5. Authority / document structure cleanup

Status: **LOCKED 2026-10-06**

Canonical structure:
- `AGENTS.md` = repository operating contract;
- `docs/GAME_SYSTEM_ARCHITECTURE.md` = system/layer authority;
- design specs = mechanics only;
- this file = implementation truth;
- `NEXT_CHAT_HANDOFF.md` = continuation instructions only.

---

## 6. Current implementation phase

**NONE — P3.7A2R IS CLOSED.**

Do not start another gameplay phase without a new explicit user instruction.

---

## 7. Queued work

The previous PL-based B2 Construction Resolver is canceled.

Any future construction/resource phase must use:
- explicit resource IDs/families;
- realm/tier;
- explicit quantities;
- no Phẩm Lực.

No next gameplay phase is authorized yet.
