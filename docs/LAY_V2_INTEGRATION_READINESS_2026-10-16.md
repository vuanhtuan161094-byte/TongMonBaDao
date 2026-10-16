# TÔNG MÔN BÁ ĐẠO — LAY-V2 Integration Readiness (2026-10-16)

## Status

Branch PR #18 code/test SHA `2e6cdc2e67a456e4836dcf4d2f252773f486a9d9`: **multi-instance operator/policy GUI implemented; expansion caps and land regions design-preview only; actual construction, persistent move and paid land unlock BLOCKED**. Godot 4.7.2 runtime and ENV-02A Windows visual gate **PENDING**. No CI, no merge main.

## Canonical state and authority

- Current `SimulationState.buildings[id]` owns real building status, work, level, production; `DiscipleState.worksite_building_id` selects exact production instance; `BuildingSystem` owns one operator per Mine, Forest, Field.
- ResourceBuildingExpansionPolicyV2 from draft PR #12 is a pure fail-closed cap preview. Cap tiers are Hall Lv1–9:1/1/1; 10–19:2/2/3; 20–39:5/5/7; 40–59:10/10/14; 60–79:18/18/24; 80–100:30/30/40. Existing-level averages at thresholds:5,10,20,35,50. It does NOT prove a real Hall building exists.
- `SectLandRegionPreviewV2` gives proposed 13 disjoint rectangles covering 192×192, starter (72,72,48,48), chunk 16×16. It does NOT persist road/placement, open regions or claim space is fully buildable.
- Player sees an exact-instance selector for existing resource producers (with each instance's assigned worker, Mine plan and Field policy). Selecting a different saved ID never creates/levels up/debits a new building. `SectHubLayoutPreview` shows planning numbers and explicitly locks Build/Unlock.
- Demo/test-only extra building created via `BuildingSystem.create_building` is a fixture that proves UI routing, not an authorized player transaction.

## Owner decisions needed before real LAY code

1. Explicitly amend ADR-0003 from fixed presentation-owned placements to exclusive `SimulationState.sect_layout` for player-edited positions, roads and unlocked land. Hall `main_hall_001` must be a singleton canonical BuildingState with its level as the only authority; an art landmark is not the Hall.
2. Approve or amend **the candidate numeric tariff bundle** in draft PR #13 `docs/design/SECT_BUILDING_LAND_EXPANSION_DESIGN_V1.md`, sections **9.5, 9.6, 9.7**, **not previously approved**:
   - new Mine baseline 80,000 Wood + 40,000 Ore + 200 Sect Stones / 240 ticks;
   - Forest baseline 40,000 Wood + 30,000 Ore + 150 Stones / 180 ticks;
   - Field baseline 50,000 Wood + 20,000 Ore + 180 Stones / 180 ticks;
   - nth-instance scaling ×[1+0.10×(n−2)] inputs/currency, construction time ×[1+0.02×(n−2)];
   - Hall Lv2–100 cost and time formula from §9.6 (with milestone multipliers);
   - 12 land-region unlock tariffs and Hall gates from §9.7 (starter seeded at no cost).
3. Technical gate remains ENV-02A 4.7.2 real render + exact seed manifest for **all existing BuildingState IDs**. Existing art previews do not justify auto-creating Hall, warehouse or forge. Existing old saves cannot be migrated until manifest/doorway/collision QA exists; protect Safe backup.
4. After acceptance, implement LAY-01 schema/seed, LAY-02 movement/roads, LAY-03 paid construction/receipts, LAY-04 timed region unlock with one scheduler/warehouse/SaveService, focused/Windows Android gates. No redefinition of 30x10, injury, Economy V2 production or PvE.

## Static QA / real runtime debt

- 7 changed/adjacent GDScript files scanned for balanced strings/comments/delimiters and no duplicate function names. This does **not** prove Godot parsing or valid UI behavior.
- New tests (not run): `godot/tests/simulation/economy_v2_expansion_cap_preview_test.gd`, `godot/tests/simulation/sect_land_region_preview_v2_test.gd`, `godot/tests/presentation/gui_multiple_resource_instances_test.gd`. Test-only secondary Mine with canonical ID+employee, scheduler start and save roundtrip. Existing GUI Workforce/O2/O3/O4/O6/O7/O8/O9/GP-02B1/02C1/SAFE/P3.7 FULL remain to run on official Godot 4.7.2.
- ProductionPlanRegistry, EconomySystem, WarehouseSystem, SimulationScheduler, CombatStatsV2, DiscipleRealmProgressV2, SaveService, HuntingPveRunV2 were exact Git blob SHA identical to PR #9. Historical Windows QA at SHA 453df9a cannot certify this branch.
