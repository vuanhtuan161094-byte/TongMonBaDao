# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-03

Always fetch/inspect live `main` before editing.

## Working style / user preference

- Code directly through the GitHub connector.
- Do not use Codex or Work.
- Do not ask the user to repeat anything already in repo/spec/handoff.
- Explain meaningful progress clearly in Vietnamese; user is non-technical.
- Never claim a runtime phase PASS without real Godot 4.7.2 output from the user's Windows machine.
- Never use destructive local git instructions (`reset --hard`, `git clean`, deleting user files, etc.).

Repo: `vuanhtuan161094-byte/TongMonBaDao`
Branch: `main`
Local: `E:\0.2. TongMonBaDao`
Godot: 4.7.2 stable console.

## Required read order before character/P3 work

1. `AGENTS.md`;
2. `CURRENT_CHECKPOINT.md`;
3. `NEXT_CHAT_HANDOFF.md`;
4. `docs/DISCIPLE_MASTER_SCHEMA.md`;
5. `docs/P3_2_MODULAR_ACTOR_SPEC.md`;
6. `docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`;
7. related P3 specs;
8. then inspect live code/tests before editing.

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 confirms:

- P0-P2.12: PASS;
- P3.1 landscape shell: PASS;
- P3.2 camera + map target selection + real disciple tabs interaction slice: PASS;
- P3.2 Character Creator V1 shared-rig scaffold: PASS.

Authoritative Character Creator output ended with:

```text
P3.2 MAP CAMERA TEST PASS
P3.2 DISCIPLE UI INTEGRATION TEST PASS
P3.2 CAMERA + DISCIPLE UI GATE: PASS
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 CHARACTER CREATOR SCAFFOLD GATE: PASS
CHARACTER CREATOR V1 SCAFFOLD GATE: PASS
```

Do not reopen those contracts without new regression evidence.

The production visual slice is **not** PASS yet.

## Character Creator V1 locked architecture

- modular appearance + shared 2D rig/animation;
- map actor and profile portrait are separate pipelines;
- source canvas `128×128`;
- foot anchor `(64,104)`;
- display scale `0.68` at map zoom 1.0;
- bones: `root, pelvis, torso, head, arm_l, arm_r, hand_weapon, leg_l, leg_r`;
- render order: `shadow -> aura -> hair_back -> weapon_back -> body -> outfit -> face -> hair_front -> head_accessory -> weapon_front -> accessory`;
- one `Skeleton2D` + one shared `AnimationPlayer`/`AnimationLibrary`;
- public directions `down/right/up/left`;
- mirror-safe left may reuse right playback;
- presentation must not mutate `DiscipleState` or P2.8 RNG.

## Female production contract

Authority:

`docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`

Locked rules:

- `down` = front;
- `right` = authored right-facing side;
- `up` = back;
- `left` = mirror-right while mirror-safe;
- every runtime cutout is full-canvas `128×128` RGBA PNG;
- foot registration `(64,104)`;
- no auto-crop/recenter;
- anatomical `l/r` means the character's own left/right;
- 3/4 views are design reference only, not runtime directions.

## CURRENT ACTIVE STATE — Stage A down/front pivot-lock

A real down/front pivot-lock pack has now been produced from the approved turnaround, not from the discarded sheet-mockup workflow.

Tracked asset source pack:

`tools/assets/female_normal_v1_stageA_repo_pack.zip`

It contains 14 real `128×128` down/front runtime PNG components plus proof/manifest files. Runtime components are:

- body: `head`, `torso`, `arm_l`, `arm_r`, `leg_l`, `leg_r`;
- `face_01_down`;
- `hair_01_down_back`, `hair_01_down_front`;
- outfit: `torso`, `arm_l`, `arm_r`, `skirt`;
- `horn_01_down`.

The extraction composite covers about 98.8% of the approved master silhouette. This is a pivot-lock diagnostic, not a final polished-art claim. Hidden anatomy under costume is intentionally conservative until pivot proof is accepted.

Isolated Stage A implementation on `main`:

- `godot/src/presentation/p3/female_stage_a_asset_loader.gd`;
- `godot/tests/presentation/p3_2_female_stage_a_down_contract_test.gd`;
- `godot/src/presentation/p3/female_stage_a_down_sandbox.gd`;
- `godot/scenes/p3/p3_2_female_stage_a_down_sandbox.tscn`;
- `tools/godot/Verify-P3-2-Female-StageA.ps1`;
- `Verify-P3-2-Female-StageA.cmd`;
- `Install-P3-2-Female-StageA.cmd`.

The Stage A verifier is NOT part of the cumulative gate yet. It first reruns the already-green Character Creator cumulative verifier, then checks Stage A PNG existence/size/component attachment and sandbox smoke.

The live sect map is still untouched.

## NEXT WINDOWS ACTION

At local repo root:

```bat
cd /d "E:\0.2. TongMonBaDao"
```

Update local `main`, then run:

```bat
Install-P3-2-Female-StageA.cmd
```

The installer reads the tracked pack from:

`tools\assets\female_normal_v1_stageA_repo_pack.zip`

It extracts into the correct `godot/assets/...` tree and automatically calls:

`Verify-P3-2-Female-StageA.cmd`

Expected final green lines, if no parser/import/pivot-contract issue appears:

```text
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN PIVOT-LOCK GATE: PASS
FEMALE STAGE A DOWN PIVOT-LOCK GATE: PASS
```

Do not claim Stage A PASS until the user's real Windows output shows it.

If it fails: fix the **first real parser/import/runtime/assertion failure only**. Never weaken tests.

## After Stage A down gate is green

1. inspect real sandbox at zoom `0.75 / 1.0 / 1.35`;
2. tune practical bone rest positions only where real art proves misalignment;
3. lock down/front pivots;
4. repeat registered asset production for authored `right` and `up`;
5. author shared idle + walk `AnimationLibrary`;
6. add face/hair/outfit/weapon variants + tint masks;
7. build six-combination sandbox;
8. run real visual-slice gate;
9. only then integrate `ModularDiscipleActor` into live map;
10. add backward-compatible `appearance_profile` persistence;
11. then expand male rig and art volume.
