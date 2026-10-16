# LAY-01 — All-instance placement and save-migration manifest

**Status:** DESIGN ONLY / INCOMPLETE / FAIL-CLOSED; 2026-10-16. **No code, no runtime or schema authority.**
**Source:** stacked draft PR #13 at \`23818d778cf7d4cb4d711f01182ed19d36f00408\`. The owner approved the LAY V2 architecture, single Hall and 30/30/40 caps *in principle*, and allowed proposed prices for further balance audit. This is **not** approval to migrate saves or enable player building placement.

## 1. Verified gameplay instance census — do not confuse with art

In \`godot/src/simulation/building/building_system.gd\`, \`initialize(state)\` creates exactly these missing primary instances in a new P3.7 state, conditional on \`workforce_enabled\`. \`ensure_body_training_facility(state)\` may add the sixth in a V2 live runtime. \`create_building(type,index)\` is only a factory, not a construction/unlock action. A saved player state may contain **additional or different** instances: actual loaded \`state.buildings.keys()\`, not the static census, is the migration input.

| Actual canonical BuildingState ID in fresh P3.7 | Type | Destination / visual alias | Actual status | TransferMapModel footprint / door (0°) | Confirmed persistent grid placement |
|---|---|---|---|---|---|
| \`mine_001\` | \`mine\` | \`mine\` / \`mine\` | real initially created | 3×3 / (1,-1), **lab-only geometry** | **NONE: BLOCK** |
| \`linh_forest_001\` | \`linh_forest\` | \`linh_forest\` / lab \`forest\` | real initially created | 2×2 / (0,-1), **lab-only geometry**; alias \`forest→linh_forest\` not proven in production | **NONE: BLOCK** |
| \`alchemy_hall_001\` | \`alchemy_hall\` | \`alchemy_hall\` | real initially created | **UNDEFINED in TransferMapModel** | **NONE: BLOCK** |
| \`spirit_field_001\` | \`spirit_field\` | \`spirit_field\` | real initially created | 2×2 / (0,-1), **lab-only geometry** | **NONE: BLOCK** |
| \`dan_tien_dai_001\` | \`dan_tien_dai\` | \`guidance\` | real initially created | **UNDEFINED in TransferMapModel** | **NONE: BLOCK** |
| \`ren_than_duong_001\` | \`ren_than_duong\` | \`ren_than_duong\` | **conditional V2 live** \`ensure_body_training_facility\`; not guaranteed in every P3.7 save | **UNDEFINED in TransferMapModel** | **NONE: BLOCK** |
| \`main_hall_001\` | \`main_hall\` | \`main_hall\` | **PROPOSED; currently no BuildingSystem definition or live instance** | 7×5 / (3,-1), lab visual candidate | **NOT a real saved placement; BLOCK** |

All IDs are from \`create_building\`'s \`"%s_%03d"\` convention. Do **not** assume every loaded save has exactly this set, or that a missing real instance can be created from a screen destination. \`main_hall_001\` must be introduced through an explicitly approved gameplay initialization/migration rule in a future packet, not inferred from an ENV-02A image.

**Migration input rule:** sorted **every** \`state.buildings\` entry; validate actual \`id, building_type, instance_index, status, production_state, worker/worksite reservations\`. Unknown types, extra \`_002\` instances, a non-standard saved ID or missing geometry must be diagnosed explicitly. Never silently discard, remap, invent or overlap it.

## 2. Presentation destinations — all 14 identifiers classified

\`godot/src/presentation/p3/sect_map_presentation.gd\` currently uses **screen-space Vector2 positions**, not world-grid \`Vector2i\`. A destination and an art candidate are not proof of a persistent \`BuildingState\`.

| Destination | Classification as of audited code | Actual BuildingState mapping | Future ownership / test |
|---|---|---|---|
| \`courtyard\` | circulation/map destination | none | authored terrain/landmark, no mutable gameplay level |
| \`main_hall\` | currently visual destination / future Hall authority | **not yet** \`main_hall_001\` | approve singleton Hall initialization + seed separately |
| \`residence\` | visual/destination; housing may be a non-building system | none in BuildingSystem | do not invent housing BuildingState |
| \`cultivation\` | visual/destination | none in BuildingSystem | map landmark unless separately authorized |
| \`ren_than_duong\` | managed when actual facility exists | conditional \`ren_than_duong_001\` | resolve footprint, door, real-world seed |
| \`warehouse\` | visual + canonical warehouse service | **not a BuildingState**; existing WarehouseSystem owns inventory | keep visual-only building, never a second warehouse |
| \`forge\` | visual + EquipmentSystem service | **not a BuildingState** | do not create a forged second equipment authority |
| \`medicine\` | visual/service destination | none in BuildingSystem | no phantom medicine building |
| \`mine\` | managed resource producer | \`mine_001\` initially | needs exact production-grid placement |
| \`linh_forest\` | managed resource producer | \`linh_forest_001\` initially | map lab \`forest\` alias is not live ID |
| \`alchemy_hall\` | managed timed producer | \`alchemy_hall_001\` initially | no lab geometry, unresolved |
| \`spirit_field\` | managed four-plot producer | \`spirit_field_001\` initially | no verified production-grid placement |
| \`guidance\` | managed recruitment facility | \`dan_tien_dai_001\` initially | visual ID differs from real building ID |
| \`gate\` | visual map destination | none | map landmark/entry, not a gameplay building |

This resolves the **destination ↔ managed instance ↔ visual-only** distinction in ADR-0003. It does not approve any art replacement: historical S3 approved images remain unrecovered and Source A assets remain candidate provenance, not gameplay truth.

## 3. Precisely three ENV-02A code-lab visual placements (NOT gameplay)

\`labs/env02a/scripts/env02_world.gd\` uses \`TransferMapModel(192×192, spawn=(82,84))\`; starter \`Rect2i(72,72,48,48)\`, chunk 16×16. It seeds these three **art preview IDs** only:

| LAB id | Source A candidate | Lab grid origin | Lab geometry footprint | Derived lab doorway at 0° | Inside 48×48 starter? | Owned by a real saved BuildingState now? |
|---|---|---|---|---|---|---|
| \`main_hall\` | model \`510052\` | (84,86) | 7×5 | (87,85) | YES | **NO** |
| \`warehouse\` | model \`510102\` | (96,87) | 3×2 | (97,86) | YES | **NO** |
| \`forge\` | model \`520081\` | (92,92) | 3×3 | (93,91) | YES | **NO** |

Static interval comparison: the three lab footprints do not overlap and their doors are within the starter rectangle. **This does not prove that a real Godot scene was rendered, routes/connectivity passed, or that any player save can adopt these three placements.** Actual ENV-02A Windows import, screenshots, AStar/culling and asset hashes remain PENDING USER, as documented in \`docs/handoffs/ENV02A_CODE_AND_BACKEND_AUDIT_2026-10-13.md\`. \`SectMapPresentation.DESTINATION_POSITIONS\` entries (e.g. Main Hall \`Vector2(620,192)\`) are **screen-space pixels**, not alternative grid coordinates.

\`TransferMapModel.DEFINITIONS\` currently covers six lab kind keys: \`main_hall\`, \`mine\`, \`spirit_field\`, \`warehouse\`, \`forge\`, \`forest\`. It has **no geometry** for \`alchemy_hall\`, \`dan_tien_dai\` or \`ren_than_duong\`. New geometries/aliases require approved content evidence, not guessing by copying the nearest visual.

## 4. Mandatory all-instance seed rows before migration authorization

The future reviewed manifest must supply the following for **each real BuildingState in the specific saved snapshot**:

| Required field | Validation |
|---|---|
| \`building_id\`, \`building_type\`, \`instance_index\` | exact live ID/type/index; no fabricated mapping; matching gameplay BuildingState |
| \`visual_id\`, \`presentation_kind\` | provenance-backed \`managed_building\` vs \`landmark\`; visual aliases documented |
| \`map_content_id\`, \`geometry_version\` | exact version, not local ZIP filename |
| \`grid_origin_x/y\`, \`orientation\` | **approved** values, not inferred screen pixels |
| \`footprint_w/h\`, \`doorway_offset\`, rotations | approved authored visual/geometry; no copying unrelated sizes |
| \`source_proof\`, \`asset_status\`, \`visual_provenance\` | reference to source/visual lab/hash, and QA state |
| \`unlocked_region_id\`, \`starter_or_migrated\` | inside unlocked land or explicitly approved other-area mapping |
| \`placement_validation\`, \`route_validation\` | collision, bounds, doorway, reachability, reserved terrain, roads |
| \`save_migration_version\`, \`migration_receipt\` | one-time seeding, old-save recovery and idempotency |

**At present no complete approved all-instance manifest exists.** Rows for the five seeded producers/facilities plus optional Body facility lack an approved grid origin; three facility kinds additionally lack verified geometry. The design gate should **remain closed**, not assign arbitrary cells simply because 192×192 is spacious.

### Legacy instances and future scale

For an old save containing \`mine_002\`, \`spirit_field_017\`, or other variants, the manifest must key **exactly** by \`building_id\` and place each instance separately, with one legal worker per Mine/Forest/Field. The destination \`mine\` may become an **instance selector/aggregate entry**, not a shared position for 30 Mine instances. No unapproved extra building should be created. Distinct \`BuildingState\` IDs keep their production timers, worker assignment, status and data; layout stores only position/orientation.

## 5. Explicit legacy Hall fork — owner decision still required

A proposed real singleton \`main_hall_001\` exists in **zero** current gameplay seeds. The owner approved the **architecture principle**, but not how old saves gain an authentic Hall without retroactive Stone/material debit.

Proposed options for later approval:
- **A (recommended, explicit baseline grant):** add a real Lv1 Hall once to *genuinely old P3.7 saves* using one documented migration receipt, with no replay and no visual-based hallucination. This is a deliberate gameplay migration decision, not a deduction from \`main_hall\` sprite.
- **B:** do not seed Hall for legacy saves; require a separate owner-approved acquisition/build process before constructing any new instance. Existing saves remain playable but expansion stays locked.

Both must preserve existing Warehouse, jobs, saved resource balances and real building IDs. Future fresh starts may seed one Hall Lv1 as starting infrastructure **only after explicit CODE approval**.

## 6. Exact migration gate matrix (proposed tests, NOT RUN)

1. **Legacy P0–P2 save:** no P3.7 buildings and no forced phantom Hall/layout. Save remains valid.
2. **Standard P3.7 save:** actual 5 initial instances mapped exactly once with reviewed geometry; 6th Body only if present. No clone, no lost XP/Stone/profession/job.
3. **Saved \`_002+\` instances:** all enumerated; each separately placed or migration rejects. Never default every instance to first destination.
4. **Known visual-only entities:** warehouse/forge/residence/medicine/gate/courtyard never mint \`BuildingState\`, resources, EXP or labor capacity.
5. **Main Hall policy A/B:** tests demonstrate exactly which old saves gain a real Hall and why; repeated load does not change level/currency.
6. **Placement validation:** rotated footprints, blocked terrain, door outside footprint, route to courtyard/gate, unlocked-region membership, no two building IDs on same occupied cell.
7. **Migration failure:** unknown geometry, map/asset mismatch, duplicate ID, collision, no legal route → fail before offline ticks and preserve primary and valid \`.bak\`.
8. **Serialization:** layout fields belong in the same \`SimulationState.to_dict/from_dict\` and SaveService staged/bak migration, not another save; preserve existing float64 encoding for SaveService v2 snapshots if a future version bump is approved.
9. **Exactly once:** load twice, save/load, offline catch-up, request replay and construction receipt do not duplicate building or debit resources.
10. **All-instance UX:** choose specific building ID, one worker/instance and four subordinate Field plots; never collapse \`_002+\` instances onto primary BuildingState.
11. **Physical ENV-02A:** official Godot 4.7.2 with exact 35 PNGs, pan/zoom/AStar/selection/culling and two real screenshots plus Android separately; code-only GitHub lab is not a PASS.

**No migration test passes are claimed by this document.** No runtime or save file has been modified.

## 7. Next deliberate tasks (design or QA only)

1. Verify ENV-02A on Windows from the owner-approved matching ZIP with matching hashes/screenshots; reconcile asset proof and terrain geometry.
2. Produce an authored real-instance mapping for at least five primary gameplay buildings, the conditional Body building, and any live-save extra instances. Do not copy the three visual preview positions as a substitute.
3. Make explicit Hall legacy-save A/B decision and typed visual-only treatment of Warehouse/Forge.
4. Only then seek exact LAY-01 CODE authority (schema + seed + migration tests only) and a separately approved ADR-0003 amendment; no LAY-02/03/04 or FE-02 code before their own gates.
