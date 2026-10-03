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
- P3.2 `female_normal_v1` Stage A FAST check: PASS.

Real FAST tail:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A FAST CHECK: PASS
FEMALE STAGE A DOWN FAST CHECK: PASS
```

Do **not** call the Stage A final milestone PASS yet. Visible pivot quality has not been accepted and FULL cumulative verification has not been run for the visual proof.

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

## Current active task — Stage A down/front visual pivot review

The FAST-green proof contains 14 registered runtime components:

- body: head/torso/arm_l/arm_r/leg_l/leg_r;
- face_01_down;
- hair back/front;
- outfit torso/arm_l/arm_r/skirt;
- horn_01_down.

Relevant implementation:

- `godot/src/presentation/p3/female_stage_a_asset_loader.gd`;
- `godot/tests/presentation/p3_2_female_stage_a_down_contract_test.gd`;
- `godot/src/presentation/p3/female_stage_a_down_sandbox.gd`;
- `godot/scenes/p3/p3_2_female_stage_a_down_sandbox.tscn`;
- `Install-P3-2-Female-StageA.cmd`;
- `Sync-P3-2-Female-StageA.cmd`;
- `Verify-P3-2-Female-StageA.cmd`;
- `Verify-P3-2-Female-StageA-Full.cmd`;
- `Preview-P3-2-Female-StageA.cmd`.

The live sect map remains untouched.

## NEXT WINDOWS ACTION

Pull the latest main through the normal sync launcher if needed, then close any other Godot window and run:

```bat
cd /d "E:\0.2. TongMonBaDao"
Preview-P3-2-Female-StageA.cmd
```

The preview opens the same Stage A sandbox that already passed headless smoke and shows the down/front actor at `0.75x`, `1.00x`, `1.35x` simultaneously.

Ask the user to send a screenshot of that preview or describe visible defects. Review specifically:

- head/face/hair/horn registration;
- shoulder/arm attachment;
- torso/outfit/skirt seams;
- leg/foot coherence and common ground level;
- silhouette/readability at 0.75x.

Do not adjust pivots from old estimates. Tune only where the real preview proves mismatch.

## After visual review

1. fix only evidenced pivot/art registration issues;
2. rerun FAST after any GDScript/pivot change;
3. lock down/front pivots once visually accepted;
4. produce authored `right` and `up` views;
5. shared idle + walk;
6. add face/hair/outfit/weapon variants + tint masks;
7. six-combination same-rig proof;
8. run FULL cumulative visual-slice gate;
9. only then live-map integration;
10. appearance persistence;
11. male rig/art expansion.
