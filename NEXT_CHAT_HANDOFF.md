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
Godot: 4.7.2 stable console.

## Required read order before P3/character work

1. `AGENTS.md`;
2. `CURRENT_CHECKPOINT.md`;
3. `NEXT_CHAT_HANDOFF.md`;
4. `docs/DISCIPLE_MASTER_SCHEMA.md`;
5. `docs/P3_2_MODULAR_ACTOR_SPEC.md`;
6. `docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`;
7. related P3 specs;
8. live code/tests.

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 confirms:

- P0-P2.12: PASS;
- P3.1: PASS;
- P3.2 camera/map-selection/real disciple tabs interaction slice: PASS;
- P3.2 Character Creator shared-rig scaffold: PASS.

Production `female_normal_v1` visual slice is **NOT PASS yet**.

## Character Creator locked architecture

- modular appearance + shared 2D rig/animation;
- source canvas `128×128`;
- foot anchor `(64,104)`;
- map scale `0.68` at zoom 1.0;
- bones: `root, pelvis, torso, head, arm_l, arm_r, hand_weapon, leg_l, leg_r`;
- render order: `shadow -> aura -> hair_back -> weapon_back -> body -> outfit -> face -> hair_front -> head_accessory -> weapon_front -> accessory`;
- one `Skeleton2D` + one shared `AnimationPlayer`/`AnimationLibrary`;
- directions `down/right/up/left`;
- mirror-safe left may reuse right;
- presentation may not mutate `DiscipleState` or P2.8 RNG.

Female runtime views:

- `down` = front;
- `right` = right-facing side;
- `up` = back;
- `left` = mirror-right while mirror-safe.

## Current active task — Stage A down/front pivot-lock

14 registered runtime components exist conceptually for the proof:

- body: head/torso/arm_l/arm_r/leg_l/leg_r;
- face_01_down;
- hair back/front;
- outfit torso/arm_l/arm_r/skirt;
- horn_01_down.

The proof is diagnostic art for pivot-lock, not final polished production art.

Relevant implementation:

- `godot/src/presentation/p3/female_stage_a_asset_loader.gd`;
- `godot/tests/presentation/p3_2_female_stage_a_down_contract_test.gd`;
- `godot/src/presentation/p3/female_stage_a_down_sandbox.gd`;
- `godot/scenes/p3/p3_2_female_stage_a_down_sandbox.tscn`;
- `Install-P3-2-Female-StageA.cmd`;
- `Sync-P3-2-Female-StageA.cmd`;
- `Verify-P3-2-Female-StageA.cmd`;
- `Verify-P3-2-Female-StageA-Full.cmd`.

The live sect map remains untouched.

## Important real failure + fix

First real Windows Stage A run failed during the old asset installer:

`End of Central Directory record could not be found.`

Cause: a binary ZIP committed through the text-only GitHub connector was corrupted. The subsequent 14-missing-PNG error was only a consequence of extraction never occurring. It did not prove a rig/Godot failure.

Stage A remains NOT PASS.

Direct binary pack transport is retired.

The runtime ZIP is now represented by verified Base64 text chunks under `tools/assets/`. The chunks currently used by the installer were checked against the locally generated canonical Base64 using Git blob SHA values and match bit-for-bit. The decoded ZIP must additionally match SHA-256:

`0c23ed5ee12cf5ec838e0a87b00f33122f6a196bd3812ecf96de2d99086fcc7c`

Installer behavior:

1. concatenate fixed text chunks;
2. Base64-decode temporary ZIP;
3. SHA-256 verify;
4. extract 14 PNGs only if hash is exact;
5. stop on any packaging error;
6. run FAST Stage A verification.

## Test scope policy — important

User correctly questioned why an art iteration reran the whole project.

Normal Stage A work is now **FAST P3.2 only**:

`Verify-P3-2-Female-StageA.cmd`

It runs:

1. changed-asset import;
2. P3.2 shared-rig contract;
3. Stage A down/front asset contract;
4. Stage A sandbox smoke.

It does **not** rerun P0-P2.12 each time.

Final regression acceptance is separate:

`Verify-P3-2-Female-StageA-Full.cmd`

Only use FULL after the visible art/pivots have been accepted. FULL reruns the cumulative chain first.

## NEXT WINDOWS ACTION

The user already has `Sync-P3-2-Female-StageA.cmd` locally. Run the same command again:

```bat
cd /d "E:\0.2. TongMonBaDao"
Sync-P3-2-Female-StageA.cmd
```

The launcher will pull the fixed `main`, rebuild/check/install the asset pack, then run only the FAST P3.2 check.

Expected fast green tail:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A FAST CHECK: PASS
FEMALE STAGE A DOWN FAST CHECK: PASS
```

Do not call Stage A final PASS from this fast check alone. After FAST green, visually inspect the sandbox/pivots first, then use the FULL cumulative gate when ready to lock the milestone.

If any command fails, fix the first real error only; do not weaken tests.

## After FAST green

1. inspect down/front at zoom `0.75 / 1.0 / 1.35`;
2. tune bone rest positions only if real art proves mismatch;
3. lock down/front pivots;
4. produce authored right/up views;
5. shared idle + walk;
6. add face/hair/outfit/weapon variants + tint masks;
7. six-combination same-rig proof;
8. FULL cumulative visual-slice gate;
9. only then live-map integration;
10. appearance persistence;
11. male rig/art expansion.
