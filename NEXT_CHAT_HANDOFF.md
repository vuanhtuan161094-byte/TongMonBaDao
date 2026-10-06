# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-06

## Read first

1. `AGENTS.md`
2. `docs/GAME_SYSTEM_ARCHITECTURE.md`
3. `CURRENT_CHECKPOINT.md`
4. this file
5. only the spec relevant to the active phase

Fetch live `main` before editing.

---

## Current active phase

**AUTHORITY / DOCUMENT STRUCTURE CLEANUP**

Do not implement P3.7B2 yet.

Purpose:
- remove stale/contradictory documentation;
- make design specs design-only;
- keep progress evidence only in `CURRENT_CHECKPOINT.md`;
- keep this handoff focused only on the current phase;
- enforce one-phase-at-a-time development.

---

## Cleanup tasks remaining

1. Sanitize `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`
   - remove obsolete pre-implementation “next step/order” sections;
   - remove A1/A2/B1 implementation diaries;
   - retain only high-level design + child-authority links + locked corrections.

2. Sanitize `docs/P3_7_BUILDING_TREE_SPEC.md`
   - remove stale implementation-order/gate/history sections;
   - remove obsolete Team Loot Bag / Loot Warehouse wording;
   - retain the building tree and immutable building rules.

3. Sanitize `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`
   - update stale status header;
   - remove implementation-status appendix;
   - keep resource/storage/base-growth design only.

4. Sanitize `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`
   - update stale Windows-pending header;
   - remove implementation-status appendix;
   - keep timing semantics only.

5. Sanitize `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`
   - integrate the no-Loot-Warehouse rule into the main text;
   - remove “override because older text may conflict” wording once no conflict remains;
   - keep this system DESIGN LOCKED / not implemented.

6. Search all P3.7 canonical docs for stale phrases:
   - Team Loot Bag;
   - Loot Warehouse;
   - bridge;
   - Windows pending;
   - implementation not started when partially implemented;
   - obsolete NEXT / IMPLEMENT ORDER text.

7. After cleanup:
   - verify cross-links;
   - record cleanup complete in `CURRENT_CHECKPOINT.md`;
   - then and only then activate B2.

---

## Locked backend state while cleaning

Do not change gameplay code unless documentation cleanup exposes a real contradiction requiring a minimal correction.

Backend locked through:
- A1 Building + Mine;
- A2 Spirit Field;
- B1 Resource Registry + canonical Sect Warehouse.

Official Godot 4.7.2 focused + cumulative CI is green through B1.

---

## Queued phase after cleanup

**P3.7B2 — Construction Resolver by material family + required Phẩm Lực**

B2 is not active yet.
Do not start it until cleanup is closed in the checkpoint.
