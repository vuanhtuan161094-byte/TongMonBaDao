# CMB-V4-VP01 — REDUCED VISUAL LAB

**Scope:** isolated Godot 4.7.2 visual proof. Does not touch production P3.2 main scene, FE-02, CMB-01, SimulationScheduler, state/save, combat damage, warehouse, rewards or Injury. Main branch remains gameplay authority.

## Run

Launch independent scene in the Godot project:

    godot --path godot res://scenes/labs/combat_v4_visual_pilot.tscn

Focused contract:

    godot --headless --path godot --editor --quit
    godot --headless --path godot -s res://tests/presentation/combat_v4_visual_pilot_test.gd

Do not claim a screenshot from a headless parse. Before any phase closure run DV2-02 group/battle snapshot and monster tests, P3.2 female motion/Stage A/camera, affected P3.7 FULL regressions, manual Windows 1280x720 screenshot and physical Android touch/FPS tests.

The fixture uses one true CombatStatsV2 actor and two MonsterCatalogueV2 actors (thanh_lang, hac_lang_vuong). Positions, HP, warnings and hits are read from actual MapBattleV2. Only the isolated HARNESS steps battle at 0.25s. View never steps, changes RNG, saves or awards anything. This is NOT a live scheduler/PvE replacement. The seed is 240416. Monster visuals are visibly labeled placeholders and MUST NOT be presented as Source A assets.

## Stage A exact 42-PNG pack — recoverable

Exact ZIP name: female_normal_v1_stageA_runtime_pack_v2_quant.zip

SHA-256:
6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca

Tracked Git transport in .github/assets/p3/female_stage_a/ has 20 Base64 chunks (part15a and part15b replace part15). The existing Install-P3-2-Female-StageA.cmd script rebuilds, verifies this hash and installs 42 cutout PNGs into godot/assets/p3/character_creator/parts/female_normal_v1. By default it also runs FAST. Do not run on owner's machine without explicit permission. Git checkout does not contain actual PNGs. Pack is runtime proof, not editable master artwork.

Shared rig: ModularDiscipleActor; loader: FemaleStageAAssetLoader; animation: FemaleNormalV1MotionLibrary. Currently idle/walk three authored directions plus mirrored left. Reduced lab does NOT claim production attack/hit clips (VFX only). Require a real image and 14/14 direction parts to accept the character art.

## Optional exact-hash ENV-01 Source A PNGs

Original 35 ENV-01/02A PNG binaries are NOT part of text-only GitHub lab mirror. Historical owner external archive: TongMonBaDao_ENV02A_192World_Lab.zip. Do not fabricate or bulk-export replacements.

Only THREE optional assets may be staged into TEMPORARY untracked Godot lab paths. The world adapter calls FileAccess.get_sha256 on the staged PNG and rejects hash mismatch before using the texture.

| Temporary path under godot/ | Exact SHA-256 |
|---|---|
| assets/labs/combat_v4/terrain/stone_courtyard.png | c157965bd15f2747a55b602d4320dc34ad70c9129f79cc17eb8b4b139897468a |
| assets/labs/combat_v4/roads/stone_branch.png | 1894d9047c73a6d9c80c8455b1a09209e49acb6eafed2922eb23446f190ab819 |
| assets/labs/combat_v4/vegetation/570185.png | 89fba324db3e3c6d850ed36ee2a3d0712c569cae220fbe9655 |

Full original source identifiers and hashes are recorded in labs/env02a/ENV02A_BASELINE_ASSET_SHA256.json. The original relative paths are env01_assets/terrain/stone_courtyard.png, env01_assets/roads/stone_branch.png, env01_assets/vegetation/570185.png.

The 570185 ID has NO verified biological/visual classification: do not call it bamboo without preview. Stone courtyard is NOT proof of forest ground set. Procedural backup is visible and labeled when external art is not present. This lab is NOT full production Combat V4 art. It does NOT copy 192x192 ENV-02A grid/chunk/placement authority.

## Monster Source A art proof — SEPARATE / UNRESOLVED

| TMBĐ species | Gameplay proof | Verified Source A rig/atlas/PNG? |
|---|---|---|
| thanh_lang | Normal wood wolf in MonsterCatalogueV2 | NO — MISSING |
| hac_lang_vuong | Nether boss in MonsterCatalogueV2 | NO — MISSING |

Reviewed TMBĐ monster_catalogue_v2.gd/hunting_map_v2.gd and ZQZS Source Knowledge transferkit/Catalog/{ANIMATION_INDEX,DISCIPLE_RIG_INDEX,GODOT_COMPATIBILITY_INDEX}.csv, analysis/DarkEdition/ANIMATION_LIBRARY_INDEX.csv and monster Lua excerpts. No valid evidence maps either custom TMBĐ species to a specific Source A model and complete visual dependencies. Rig 1113002_1 is a HUMAN candidate, not wolf art. Names of animations embedded in binary are NOT actual playable clips.

One separate, read-only art proof for EACH beast must establish source monster config/model, bundle locator, .skel/.atlas/PNG hashes, actual image preview, Godot playback/bake proof and redistribution rights; otherwise commission original art with separate approval. Do not download/export entire Source A library.

## Boundaries

World coordinates are MapBattleV2 local 36x20. Ground, path and foliage are visual-only; there is no terrain collision or authored movement around rocks. The view culls only limited lab elements; 30v40 Android performance is NOT established. No automated hunting/scheduler integration, save/loot/HP/Injury settlement, or 1280x720 Android QA is claimed.

Rollback: remove only newly created CMB-V4-VP01 lab script, scene, focused test and this README from the feature branch. Existing canonical files, all Source A packs, docs, save data, FE-02, CMB-01, S3-approved artwork and GP-02C1 remain untouched. No merge into main before reviewed exact-SHA QA and user acceptance.
