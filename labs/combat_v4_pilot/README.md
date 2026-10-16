# CMB-V4-VP01 — REDUCED VISUAL LAB

**Scope:** isolated Godot 4.7.2 visual proof. Does not touch production P3.2 main scene, FE-02, CMB-01, SimulationScheduler, state/save, combat damage, warehouse, rewards or Injury. Main branch remains gameplay authority.

## Run

Launch independent scene in the Godot project:

    godot --path godot res://scenes/labs/combat_v4_visual_pilot.tscn

Focused contract:

    godot --headless --path godot --editor --quit
    godot --headless --path godot -s res://tests/presentation/combat_v4_visual_pilot_test.gd
    godot --headless --path godot -s res://tests/presentation/combat_v4_two_way_test.gd

Do not claim a screenshot from a headless parse. Before any phase closure run DV2-02 group/battle snapshot and monster tests, P3.2 female motion/Stage A/camera, affected P3.7 FULL regressions, manual Windows 1280x720 screenshot and physical Android touch/FPS tests.

The fixture uses one true CombatStatsV2 actor and two MonsterCatalogueV2 actors (thanh_lang, hac_lang_vuong). Positions, HP, warnings and hits are read from actual MapBattleV2. Only the isolated HARNESS steps battle at 0.25s. View never steps, changes RNG, saves or awards anything. This is NOT a live scheduler/PvE replacement. The seed is 240416. Monster visuals use either explicit placeholders or EXACT-HASH generated ORIGINAL ART pose proof images. Neither route may be presented as verified Source A rig/animation.

## Stage A exact 42-PNG pack — recoverable

Exact ZIP name: female_normal_v1_stageA_runtime_pack_v2_quant.zip

SHA-256:
6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca

Tracked Git transport in .github/assets/p3/female_stage_a/ has 20 Base64 chunks (part15a and part15b replace part15). The existing Install-P3-2-Female-StageA.cmd script rebuilds, verifies this hash and installs 42 cutout PNGs into godot/assets/p3/character_creator/parts/female_normal_v1. By default it also runs FAST. Do not run on owner's machine without explicit permission. Git checkout does not contain actual PNGs. Pack is runtime proof, not editable master artwork.

Shared rig: ModularDiscipleActor; loader: FemaleStageAAssetLoader. Existing production library owns idle/walk for three directions, but **this combat pilot uses RIGHT ONLY and mirrors LEFT**, preserving horizontal orientation for all vertical movement. New isolated CombatV4TwoWayMotion adds basic right-only Attack/Hit bone clips; no global Stage A animation code is changed. If the Stage A pack is absent, an optional EXACT-HASH generated female original-art pose image is shown instead of pretending to have the original rig. Such pose illustrations are NOT full animation cycles. Require an actual Godot screenshot and 14/14 direction parts to accept the Stage A rig artwork.

## Two-direction contract and original-art overlay

**User decision (2026-10-16): human, normal wolf and wolf boss are presented using ONE authored horizontal side plus Godot mirror.** Vertical travel changes world position but keeps previous horizontal facing. The classic three-direction art in other production screens remains untouched. Two-way implementation uses CombatV4TwoWayFacing.for_motion() + flip_h() and no independent combat direction authority. Human Stage A is authored RIGHT and mirrored LEFT; custom wolf concept poses are authored LEFT and mirrored RIGHT.

A temporary ORIGINAL-ART concept pack (12 alpha PNGs) has been prepared separately from GitHub in conversation artifact `Combat_V4_TwoWay_OriginalArt_RuntimePack.zip`. All 12 PNGs are checksum-pinned inside the adapter and package manifest. When installed into `godot/assets/labs/combat_v4/original/`, the lab can show an actual heroine, Thanh Lang and Boss illustration rather than abstract circles. These are NEW GENERATIVE POSE ILLUSTRATIONS, NOT Source A, NOT production animation-ready and must be removed/replaced if visual motion QA fails. The pack's installer verifies every input checksum and refuses to overwrite a different local asset.

Useful vetted references:
- Godot official 4.7 skeleton/cutout animation demo: https://github.com/godotengine/godot-demo-projects/tree/master/2d/skeleton (MIT, do not import its unrelated demo art).
- Godot-2D-animation SKILL.md: https://github.com/thedivergentai/Game-Dev-Agentic-Skills/blob/main/skills/godot-2d-animation/SKILL.md (reference patterns only; **no third-party scripts/plugins installed**).
- Pixelorama: https://github.com/Orama-Interactive/Pixelorama (optional MIT sprite editor; not a Godot runtime dependency).

**Art QA truth:** mirrored facing and right-only cutout rig keyframes are authored. The art PNGs contain single different poses, not frame sequences. Smooth anatomically correct wolf gait and Boss multiple-action animation are still outstanding. No Godot/Android runtime PASS is claimed.

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

## CC0 LICENSED WOLF RUN — 2026-10-16

**Selected actual third-party sprite:** `wolf_run.png`, author **alizard**, license **CC0**. Verified public release/source: https://opengameart.org/content/pixel-wolf ; direct source: https://opengameart.org/sites/default/files/wolf_run.png . Source description specifies 5 side-profile frames, each 66x66px, giving a 330x66 horizontal sprite sheet. THIS IS NOT VLTK1 ART AND MUST NOT BE LABELED AS SUCH.

Installer in repository: `tools/asset/Install-CMBV4-CC0-Wolf.ps1` (Windows PowerShell). It downloads source to a temporary directory, validates PNG signature and exact dimensions, obtains SHA-256, refuses to overwrite a different file, then stages under `godot/assets/labs/combat_v4/cc0_wolf/wolf_run.png`. Never manually copy unverified game-client Resources into this path.

The Godot visual lab automatically prefers the CC0 5-frame wolf sheet over the original-art one-pose proof for regular Thanh Lang, using Sprite2D.hframes=5, vframes=1, 8 fps when moving, native flip_h for facing left/right and previous horizontal side while moving vertically. The Boss remains the separately labeled original-art pose proof (or a placeholder), since this CC0 file is only a regular wolf RUN animation. Both editions share the same canonical MapBattleV2 positions/HP; the frame index is visual only.

The network-backed artifact could **not** be downloaded into the assistant runtime: local network resolution and asset transfer were blocked. Therefore there is **no new asset binary committed, no verified local download SHA, no Godot runtime PASS** from this work. The script is awaiting one successful legitimate download on a Windows testing machine. No CI/workflow triggered.

**True runtime screenshots:** The isolated lab now has a `Chụp ảnh` button which waits for a real rendered frame and saves the viewport PNG to `user://cmb_v4_screenshots/CMB-V4-<timestamp>.png`; it logs the resolved absolute filename. Requires running Godot 4.7.2 with a graphical display. Any composited preview prepared outside Godot must prominently say NOT A GODOT SCREENSHOT.

VLTK1/JX1 freely uploaded game clients/resources have **unverified redistribution/reuse rights** despite some third-party GitHub repos being MIT-licensed; not ingested. License-approved replacement art can be evaluated separately, without copying VLTK1 art into production.

## Monster Source A art proof — SEPARATE / UNRESOLVED

| TMBĐ species | Gameplay proof | Verified Source A rig/atlas/PNG? |
|---|---|---|
| thanh_lang | Normal wood wolf in MonsterCatalogueV2 | NO — MISSING |
| hac_lang_vuong | Nether boss in MonsterCatalogueV2 | NO — MISSING |

Reviewed TMBĐ monster_catalogue_v2.gd/hunting_map_v2.gd and ZQZS Source Knowledge transferkit/Catalog/{ANIMATION_INDEX,DISCIPLE_RIG_INDEX,GODOT_COMPATIBILITY_INDEX}.csv, analysis/DarkEdition/ANIMATION_LIBRARY_INDEX.csv and monster Lua excerpts. No valid evidence maps either custom TMBĐ species to a specific Source A model and complete visual dependencies. Rig 1113002_1 is a HUMAN candidate, not wolf art. Names of animations embedded in binary are NOT actual playable clips.

One separate, read-only art proof for EACH beast must establish source monster config/model, bundle locator, .skel/.atlas/PNG hashes, actual image preview, Godot playback/bake proof and redistribution rights; otherwise commission original art with separate approval. Do not download/export entire Source A library.

## Boundaries

World coordinates are MapBattleV2 local 36x20. Ground, path and foliage are visual-only; there is no terrain collision or authored movement around rocks. The view culls only limited lab elements; 30v40 Android performance is NOT established. No automated hunting/scheduler integration, save/loot/HP/Injury settlement, or 1280x720 Android QA is claimed.

Rollback: remove only newly created CMB-V4-VP01 lab scripts, scene, focused tests and this README from the feature branch. Remove staged assets only if their checksums match the original-art package; never delete unknown local files. Existing canonical files, all Source A packs, docs, save data, FE-02, CMB-01, S3-approved artwork and GP-02C1 remain untouched. No merge into main before reviewed exact-SHA QA and user acceptance.
