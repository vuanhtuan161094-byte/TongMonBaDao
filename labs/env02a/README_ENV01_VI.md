# Tông Môn Bá Đạo — ENV-01 Source A Environment Map Lab

**Scope:** isolated static visual lab for Godot **4.7.2**, LANDSCAPE **1280×720**. **NOT production integration, NOT S3 art approval, NOT Spine runtime.** DV2-03 **PAUSED, NOT CLOSED**.

## Run on Windows — one step

1. Unzip the package to any writable directory on Windows (e.g. `E:\TongMonIntegrationLab\ENV01_SourceA_Map_Lab`).
2. Double-click **`RUN_ENV01_WINDOWS.cmd`**. It uses `E:\Godot_v4.7.2-stable_win64_console.exe`. If Godot is elsewhere, open Command Prompt and run `RUN_ENV01_WINDOWS.cmd "C:\path\to\godot_console.exe"`.
3. The script imports resources, runs `--env01-verify` headlessly (no screenshot wait), checks for `ENV01_RESULT PASS_STRUCTURE`, then opens the graphical Godot scene. It writes **only within the extracted lab** (`.godot/` and `ENV01_TEST_RESULTS/`).
4. Inspect **three buildings and scenery**, click/tap buildings, right-drag or touch-drag to pan, wheel/pinch to zoom. Check path visibility, doorway selection, silhouettes, foliage depth, texture seams and 1280×720 layout. Close the Godot window after inspecting.
5. Send back `ENV01_TEST_RESULTS/import.log`, `ENV01_TEST_RESULTS/env01_structure.log`, and an **actual Godot screenshot**. The included `ENV01_EVIDENCE/offline_asset_composite_preview.png` is an **offline visual composition, not Godot test proof**.

Alternatively: open `project.godot` in Godot 4.7.2 and run scene `scenes/pv01_three_buildings.tscn`.

## Changes from PV-01

- Preserves `scripts/map_model.gd` **byte-identical**: 20×13 grid; footprints 7×5, 3×2, 3×3; doorway offsets; occupancy and AStar.
- Preserves the original **three Source A building PNGs byte-identical**.
- Adds `scripts/env01_environment.gd`: backdrop, muted procedural grass (fallback because extracted Source A surface tiles are pale stone, not natural grass), Source A terrain paving, stone roads with **provisional** neighbor selection, depth-ordered static Source A trees/bamboo/rocks/lanterns.
- The modified `scripts/pv01_three_buildings.gd` seeds a connected visual road network through the same `TransferMapModel`, creates the environment layer and provides `--env01-verify`. No separate map authority or gameplay state.
- Uses a curated set of **29 original Source A texture PNGs**. Assets were copied unaltered from `SourceA_Map_Prep_20261012.zip`; originals and hash metadata appear in `ENV01_ASSET_MANIFEST.json`. No `.skel` runtime integration.
- Terrain and roads are Source A sprites mapped to PV-01's original projection (50×26 per cell), **not a claim of exact native Source A autotile parity**. Road mask mapping is a preliminary lab rendering rule; inspect corners/joins manually.
- Environment decorations do **not** modify navigation solidity. Anchors outside grid are visual-only; interior anchors are skipped if model occupancy or road overlaps. More general collision behavior is outside ENV-01.

## Acceptance / limitations

- Offline Python static checks, asset hashes and route-feasibility validation are recorded in `ENV01_EVIDENCE/ENV01_STATIC_QA.json`.
- The runtime `ENV01_RESULT PASS_STRUCTURE` is **not yet observed** in this environment because Godot 4.7.2 is not installed in the sandbox. Windows import, actual rendering and manual input/visual acceptance remain **PENDING USER**.
- `home.ab`, original `_MapManager`, full scene placement, mountain materials/meshes and actual Spine character animations are deliberately **excluded**. This is **not** full Home scene reconstruction.
- No production P3.2 changes, FE-02, G1, EXP, Warehouse, Save or existing S3 visual authority changes.
- Running `--pv01-smoke` remains available but may depend on a real graphical viewport to capture an image. The dedicated ENV-01 verify mode deliberately does not wait for `RenderingServer.frame_post_draw`.

## Files

- `project.godot`, `scenes/`, `scripts/`: Godot project
- `pv01_assets/`: original three building images
- `env01_assets/`: selected Source A environmental textures
- `ENV01_ASSET_MANIFEST.json`: per-texture original ZIP locator, size and SHA-256
- `PV01_EVIDENCE/`: original PV-01 evidence copied from the user's ZIP (not new ENV-01 proof)
- `ENV01_EVIDENCE/`: offline preview and static QA evidence
- `RUN_ENV01_WINDOWS.cmd`: one-step import/structural verification/interactive launch