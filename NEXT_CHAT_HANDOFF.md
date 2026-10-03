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
5. `docs/P3_2_MODULAR_ACTOR_SPEC.md`;
6. `docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`;
7. related P3 specs;
8. live P3 code/tests.

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 confirms:

- P0-P2.12: PASS;
- P3.1: PASS;
- P3.2 camera/map-selection/real disciple tabs interaction slice: PASS;
- P3.2 Character Creator shared-rig scaffold: PASS;
- `female_normal_v1` Stage A DOWN/FRONT FAST: PASS.

Real down/front FAST tail:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A FAST CHECK: PASS
FEMALE STAGE A DOWN FAST CHECK: PASS
```

Stage A final milestone is still **NOT final PASS** because the new three-direction proof has not yet passed its Windows FAST gate/visual review and FULL cumulative acceptance remains later.

## Down/front visual review — accepted

User supplied a real preview screenshot showing down/front at `0.75x`, `1.00x`, `1.35x`.

Accepted observations:

- head/face/hair/horns coherent;
- arms/shoulders do not split from torso;
- no major outfit/skirt seam;
- legs/feet share ground registration;
- silhouette readable at 0.75x.

Dark hair + skirt merge somewhat at 0.75x, but this is future art contrast/simplification work, not a pivot defect.

**No bone rest positions were changed. Down/front practical pivots are visually locked.**

## Current active task — authored RIGHT + UP proof

Stage A diagnostic assets now include the three authored directions:

- `down` = front;
- `right` = authored side;
- `up` = authored back;
- `left` remains mirror-right while mirror-safe.

Each direction has 14 full-canvas `128×128` pieces, total **42 PNGs**. Foot anchor remains `(64,104)`.

`up` face layer is intentionally transparent to prevent front-face leakage.

New authoritative diagnostic runtime pack is four tracked Base64 chunks:

- `female_normal_v1_stageA_v2q_01.b64`;
- `female_normal_v1_stageA_v2q_02.b64`;
- `female_normal_v1_stageA_v2q_03.b64`;
- `female_normal_v1_stageA_v2q_04.b64`.

Decoded ZIP SHA-256:

`6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`

Local static inspection confirmed the ZIP contains exactly the 42 loader-expected paths. Real Windows installer SHA verification is still pending.

Relevant implementation:

- `Install-P3-2-Female-StageA.cmd` — rebuilds 4 chunks, checks SHA, installs 42 PNGs;
- `godot/src/presentation/p3/female_stage_a_asset_loader.gd` — down/right/up loaders;
- `godot/tests/presentation/p3_2_female_stage_a_down_contract_test.gd` — locked down regression;
- `godot/tests/presentation/p3_2_female_stage_a_directions_contract_test.gd` — 3-direction contract;
- `godot/src/presentation/p3/female_stage_a_directions_sandbox.gd`;
- `godot/scenes/p3/p3_2_female_stage_a_directions_sandbox.tscn`;
- `Preview-P3-2-Female-Directions.cmd`;
- `Verify-P3-2-Female-StageA.cmd` — 5-step P3.2-only FAST gate;
- `Verify-P3-2-Female-StageA-Full.cmd` / PS1 — updated for directions, but do not run yet.

Live sect map remains untouched.

## NEXT WINDOWS ACTION

Close all Godot windows, then run:

```bat
cd /d "E:\0.2. TongMonBaDao"
Sync-P3-2-Female-StageA.cmd
```

Expected new green tail:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
```

If FAST is green, run:

```bat
Preview-P3-2-Female-Directions.cmd
```

Ask for a screenshot. Inspect front/side/back consistency, head/horn/hair root, shoulder/hip position, common feet/ground, right-side identity, no face leak in back view, and readability at 0.75x.

Do not tune pivots unless the real preview proves a mismatch.

## After three-direction visual acceptance

1. lock down/right/up registration;
2. shared idle + walk public 4 directions, left mirror-right while safe;
3. add face/hair/outfit/weapon variants;
4. tint masks/presets;
5. six-combination same-rig proof;
6. FULL cumulative visual-slice gate;
7. only then live-map integration;
8. appearance persistence;
9. male rig/art expansion.
