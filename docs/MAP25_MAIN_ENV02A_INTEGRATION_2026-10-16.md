# MAP25 — ENV-02A 2.5D main game integration handoff

## 2026-10-16 — Source A art renderer update (code SHA `b8b003280ef235767cc4627bf7df9adea8a618a2`)

**Implemented:** GitHub art whitelist `godot/data/presentation/map25_source_a_verified.json` includes **32 exact image hashes/paths** copied from original ENV-02A baseline manifest; `SectMap25SourceArt` validates PNG bytes before creating ImageTexture, accepts only the fixed `res://art/source_a_env02a` root. Renderer uses textures for houses (510052, 510102, 520081), terrain tiles, road tiles and 19 curated vegetation models if present. World sorts ground-contact Y for decoration and buildings; Godot actor LEFT/RIGHT mirrored walk; real scene viewport corrected to draw underneath character layer; PV01 artwork anchored to footprint centers.

**Missing:** zero original Source A PNG binaries in actual GitHub repo. No art was imported or authenticated at runtime; fallback remains visible. The 32 count excludes preview/evidence PNGs in 35-entry ENV02A manifest. To resume with art use exact owner-authorized ENV02A ZIP, check all relevant SHA, then copy to `godot/art/source_a_env02a` without altering raw bytes; actual Godot import and interactive screenshots are mandatory.

**Evidence:** static parser-like bracket/string scan 6/6 and every 32 SHA/index pairs match original manifest; official Godot 4.7.2 headless and GUI **PENDING**, test scripts are **not executed**. No CI/merge/balance/SaveService changes; main untouched. Regression now guards SubViewport below actors and verifies the three PV01 anchor offsets.

---
**Code/test SHA:** `e64fbfe35ac08f8b5e8be62553a31811c2b40ce7`. Draft [PR #18](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/18); project is Godot 4.7.2, mobile landscape 1280×720. Runtime tests **NOT RUN**, no CI, no merge.

## Main scene, not a separate lab

- Existing scene `res://scenes/p3/p3_2_landscape_sect.tscn` continues to create `LiveGameRuntimeV2`. Script `p3_2_landscape_sect.gd` mounts a `SectMainIsoViewportContainer` positioned in existing `SectMapCamera.VIEW_RECT`; its child SubViewport/Camera2D renders `SectIsoWorld192` (a real Node2D) behind the existing Godot Control HUD.
- The former flat graybox `SectTerrainBase`, 13 `BuildingToken_*` and painter primitives are invisible while their named nodes remain for backwards test compatibility. The original modular actor input/animation and HUD remain outside the isometric camera; their destination anchors and tap focus are projected to the new world.
- World has deterministic 192×192 coordinate system, `project(x,y)=((x-y)*25,(x+y)*13)`, view-only 48×48 starter at (72,72), 16×16 visible chunk culling and identical ENV02A MapModel AStar/doorway road algorithm. Three ENV02A fixed visual examples use their original preview cell seeds: main_hall (84,86), warehouse (96,87), forge (92,92). They are **not** proof of actual paid/saved buildings or verified managed Hall.
- Existing scene tap, pinch, pan, reset, building selection and all player-facing Workforce V1 panels still use the sole canonical SimulationState; world pick resolves real building ID exactly when it is an actual Mine, Linh Lâm or Linh Điền. Additional instances use deterministic visual-only relative anchor offsets, not persistent placement.
- View-only ENV02A model rebuilds static roads via AStar; no saved terrain, no gameplay movement authority, no factory timer, no Warehouse duplication.

## Asset evidence / honest fallback

The GitHub `labs/env02a` checkout contains code/manifest but NOT the source 35 asset PNGs. `docs/handoffs/ENV02A_CODE_AND_BACKEND_AUDIT_2026-10-13.md` records owner-supplied offline ZIP `TongMonBaDao_ENV02A_192World_Lab.zip`. All current building/trees/tiles display **procedural flat-colored isometric stand-ins**, NOT Source A textures. Do not fabricate artwork, invent SHA approval or claim the final production visual matches lab screenshots. To replace: obtain original authorized pack, compare bytes against `labs/env02a/ENV02A_BASELINE_ASSET_SHA256.json`, curate 3 house sprites/terrain/foliage/roads, import actual `res://` art and adjust depth/touch footprints without changing worker IDs or gameplay authority. No asset change included in this checkpoint.

## Next QA

1. Official Godot 4.7.2 importer: compile new global `SectIsoMapModelV1`, `SectIsometricWorldV1`, P3 main scene, detect missing script/API and render/CanvasItem order.
2. Focused tests: `sect_iso_projection_contract_test.gd`, `sect_iso_main_integration_test.gd` (screen picking, AStar hall/warehouse/forge, canonical Mine ID, chunk/camera, immutable save snapshot), `gui_workforce_v1_e2e_test.gd`, `gui_multiple_resource_instances_test.gd`.
3. Cumulative O2/O3/O4/O6==4/O7/O8/O9, One Active Job, GP-02B1/02C1, SAFE and P3.7 FULL; physical SaveService offline test. Source SHA-specific runtime only, no fake PASS from static.
4. Official screenshots Windows 1280×720, Android touch/pinch, FPS/memory and lifecycle. ENV02A external art/render acceptance remains pending separately.

**Static evidence** five touched scripts passed lexical bracket/string/comment and function-duplicate scan. Eight protected gameplay source blobs identical to PR #9. Godot was not installed in the available environment. Technical corrections may be made on the integration branch with unchanged gameplay, no CI/merge; paid construction and LAY persistent-editable schema require their own approved owner rules/visual seed.
