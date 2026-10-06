# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-06

## Read first

1. `AGENTS.md`
2. `docs/GAME_SYSTEM_ARCHITECTURE.md`
3. `CURRENT_CHECKPOINT.md`
4. this file
5. only the spec relevant to the next requested phase

Fetch live `main` before editing.

---

## Current state

The authority/document cleanup phase is **COMPLETE / LOCKED**.

There is currently **no active implementation phase**.

Do not continue coding automatically.

---

## Backend locked through

### P3.7A1
Building Authority + Mine.

### P3.7A2
Spirit Field / Linh Điền on the same BuildingSystem.

### P3.7B1
Resource Registry + one canonical Sect Warehouse.

Official Godot 4.7.2 focused and cumulative GitHub CI is green through B1.

Earlier locked Windows baseline remains P0–P3.6A runtime as recorded in `CURRENT_CHECKPOINT.md`.

---

## Documentation structure now

### Stable architecture / workflow
`docs/GAME_SYSTEM_ARCHITECTURE.md`

### Current runtime truth
`CURRENT_CHECKPOINT.md`

### Character master
`docs/DISCIPLE_MASTER_SCHEMA.md`

### P3.7 parent
`docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`

### Building design
`docs/P3_7_BUILDING_TREE_SPEC.md`

### Resource / warehouse / base growth
`docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`

### Time / movement / work
`docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`

### Hunting / loadout / progression
`docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`

Design specs must not accumulate progress logs again.

---

## Next queued phase — do not start without user instruction

**P3.7B2 — Construction Resolver by material family + required Phẩm Lực**

When the user explicitly starts B2:

1. fetch live `main`;
2. read authorities above;
3. inspect current `ResourceRegistry`, `WarehouseSystem`, `BuildingSystem`;
4. lock B2 contract before broad edits;
5. implement B2 only;
6. focused Godot 4.7.2 gate;
7. cumulative gate to close B2;
8. update checkpoint;
9. stop before B3 unless the user explicitly continues.

No presentation work during B2.
