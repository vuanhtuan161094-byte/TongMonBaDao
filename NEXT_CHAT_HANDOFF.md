# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-03

Always fetch/inspect live `main` before editing.

## Working style / user preference

- Code directly through the GitHub connector.
- Do not use Codex or Work.
- Do not ask the user to repeat repo/spec context.
- Explain progress clearly in Vietnamese; user is non-technical.
- Never claim runtime PASS without real Godot 4.7.2 output from the user's Windows machine.
- Never use destructive local git instructions (`reset --hard`, `git clean`, deleting user files, etc.).

Repo: `vuanhtuan161094-byte/TongMonBaDao`
Branch: `main`
Local: `E:\0.2. TongMonBaDao`
Godot: 4.7.2 stable.

## Required read order before P3/character work

1. `AGENTS.md`;
2. `CURRENT_CHECKPOINT.md`;
3. `NEXT_CHAT_HANDOFF.md`;
4. `docs/DISCIPLE_MASTER_SCHEMA.md`;
5. `docs/P3_PRESENTATION_MASTER.md` for any UI/UX/art/mockup task;
6. relevant presentation item MD (`P3_ASSET_BUILDINGS.md`, `P3_ASSET_MAP_ENVIRONMENT.md`, `P3_UX_MAIN_MAP.md`, `P3_UX_DISCIPLE_SCREEN.md`, `P3_UI_SKIN_AND_ICONOGRAPHY.md`);
7. `docs/P3_2_MODULAR_ACTOR_SPEC.md`;
8. `docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`;
9. related P3 specs;
10. live P3 code/tests.

## Presentation workflow — LOCKED 2026-10-03

User explicitly requires a **plan before every image generation/edit/mockup**. Do not call image generation first.

Workflow:

1. read `docs/P3_PRESENTATION_MASTER.md`;
2. read the relevant item MD;
3. inspect/reuse previously approved source assets;
4. present a concise plan covering goal, composition, inherited approved assets, locked elements, allowed changes, dimensions/style and differences from previous version;
5. generate only after user approves that plan;
6. after user accepts a visual, update the item MD so the decision is recoverable from repo.

Existing approved building art must be treated as visual authority. The approved building family predates this handoff and includes Tông Môn Đại Điện, Phòng Ốc/Đệ Tử Xá, Luyện Khí Đường, Kho and later Tu Luyện Đài, Dược Phòng, Khu Khai Khoáng, Tông Môn Đại Môn. Style: hand-painted 2D mobile, light isometric/top-down, pastel/ink-wash, clear silhouettes, simple slightly cute forms, shared camera/scale/footprint. **Do not redesign these buildings in a new mockup just because the image model can invent alternatives.**

The live GitHub repo does not currently contain a reliable tracked binary pack for those approved building images, so their approved status is recorded in `docs/P3_ASSET_BUILDINGS.md`; when source images are available in chat/library, use them directly as references. Do not silently substitute newly generated architecture.

User also prefers the brighter hand-painted/parchment mood of the 2026-10-03 V3 map mockup over the earlier darker/heavier mockups. This affects UI/map mood, not the identity of already-approved building assets.

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 confirms:

- P0-P2.12: PASS;
- P3.1: PASS;
- P3.2 camera/map-selection/real disciple tabs: PASS;
- P3.2 Character Creator shared-rig scaffold: PASS;
- `female_normal_v1` Stage A DOWN/FRONT FAST: PASS.

Real down/front tail:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A FAST CHECK: PASS
FEMALE STAGE A DOWN FAST CHECK: PASS
```

Stage A final milestone remains **NOT PASS**. Three-direction FAST + visual review are pending, then later motion/variants/tints/six-combo proof and FULL cumulative acceptance.

## Down/front visual review — accepted

User supplied a real screenshot at `0.75x / 1.00x / 1.35x`.

Accepted:

- head/face/hair/horns coherent;
- arms/shoulders attached;
- no major skirt/outfit seam;
- feet share ground registration;
- silhouette readable at `0.75x`.

Dark hair + skirt merging at `0.75x` is future art contrast work, not a pivot defect. **No bone rest positions were changed.**

## Current active task — authored RIGHT + UP proof

Stage A loader/test/sandbox support:

- `down` = front;
- `right` = authored side;
- `up` = authored back;
- `left` = mirror-right while safe.

Each authored direction has 14 full-canvas `128×128` components, total **42 PNGs**. Foot anchor remains `(64,104)`. `up` face is transparent to prevent face leakage.

FAST is still P3.2-only:

1. import;
2. shared-rig contract;
3. down regression;
4. 3-direction contract;
5. 3-direction sandbox smoke.

Relevant files:

- `godot/src/presentation/p3/female_stage_a_asset_loader.gd`;
- `godot/tests/presentation/p3_2_female_stage_a_down_contract_test.gd`;
- `godot/tests/presentation/p3_2_female_stage_a_directions_contract_test.gd`;
- `godot/src/presentation/p3/female_stage_a_directions_sandbox.gd`;
- `godot/scenes/p3/p3_2_female_stage_a_directions_sandbox.tscn`;
- `Verify-P3-2-Female-StageA.cmd`;
- `Verify-P3-2-Female-StageA-Full.cmd` — do not run yet;
- `Preview-P3-2-Female-Directions.cmd`.

Live sect map remains untouched.

## Binary transport issue — resolved design, Windows run pending

The previous four tracked `female_normal_v1_stageA_v2q_*.b64` files were proven incomplete after Windows failed with:

```text
Invalid length for a Base-64 char array or string.
```

Canonical source comparison showed the tracked text was missing 1,793 Base64 chars in total. This is a connector/binary-transport tooling defect, not a Godot/art/rig defect.

The malformed v2 chunks plus experimental replacement chunks were removed from live `main`.

Current authoritative diagnostic pack is an external one-time ZIP:

`female_normal_v1_stageA_runtime_pack_v2_quant.zip`

- size: 44,838 bytes;
- exactly 42 Stage A PNGs;
- SHA-256: `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`.

`Install-P3-2-Female-StageA.cmd` now auto-discovers the ZIP in `Downloads`, `Desktop`, repo root, or `STAGE_A_PACK`, including browser duplicate names. It verifies SHA-256 before extraction; wrong/corrupt packs are rejected.

`.gitignore` covers only exact generated Stage A PNGs, `.png.import` sidecars, and an optional repo-root copy of the diagnostic ZIP.

## NEXT WINDOWS ACTION

1. User already has/was given the ChatGPT download link for `female_normal_v1_stageA_runtime_pack_v2_quant.zip`.
2. Leave it in Windows `Downloads`; no manual extraction needed.
3. Close all Godot windows.
4. Run:

```bat
cd /d "E:\0.2. TongMonBaDao"
Sync-P3-2-Female-StageA.cmd
```

Sync should pull live main, installer should find the downloaded ZIP, print its SHA, install 42 PNGs, then run the five FAST P3.2 steps.

Expected green tail:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
```

If green, run:

```bat
Preview-P3-2-Female-Directions.cmd
```

Ask for screenshot. Inspect front/side/back identity, horn/hair roots, shoulder/hip continuity, common foot registration, side readability, no back-face leakage, and `0.75x` silhouette.

## UX playtest priority when machine is available

Do not wait for every cosmetic variant before testing UX. After three-direction visual acceptance:

1. shared idle + walk public 4 directions;
2. integrate modular actor into the live sect map in a safe/controlled step;
3. run a real main-map UI/UX playtest (pan/zoom, tap actor/building, quick popup, disciple deep screen, HUD/task rail/mobile hit targets);
4. then continue broad cosmetic asset volume.

## After three-direction visual acceptance

1. lock `down/right/up` registration;
2. shared idle + walk public 4 directions;
3. early live-map UX integration/playtest;
4. add face/hair/outfit/weapon variants;
5. tint masks/presets;
6. six-combination same-rig proof;
7. FULL cumulative visual-slice gate;
8. appearance persistence;
9. male rig/art expansion.
