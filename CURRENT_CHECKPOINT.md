# CURRENT CHECKPOINT

Date: 2026-10-03

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 cumulative evidence confirms:

- P0-P2.12: PASS;
- P3.1 mobile landscape + living sect shell: PASS;
- P3.2 camera + map target selection + real disciple tabs interaction slice: PASS;
- P3.2 Character Creator V1 shared-rig scaffold: PASS.

Latest locked Character Creator tail:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 CHARACTER CREATOR SCAFFOLD GATE: PASS
CHARACTER CREATOR V1 SCAFFOLD GATE: PASS
```

Do not reopen those locked contracts without new regression evidence.

**The production female visual slice is NOT PASS yet.**

---

# Character authority

Read `docs/DISCIPLE_MASTER_SCHEMA.md` before changing character gameplay systems.

Locked rules remain:

- one disciple = one canonical `DiscipleState` identity;
- hidden identity is generated once and persisted;
- reveal/awakening/transformation never rerolls hidden identity;
- presentation must not create parallel gameplay authority;
- appearance never changes stats/economy/action;
- existing disciple `sex_id` is canonical;
- appearance work must not consume/reorder the P2.8 RNG stream.

---

# Character Creator V1 — runtime-green scaffold

Canonical architecture: **modular appearance + shared 2D rig/animation**.

Canonical specs:

- `docs/P3_2_MODULAR_ACTOR_SPEC.md`;
- `docs/P3_2_ASSET_MANIFEST.md`;
- `docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`.

Locked registration:

- source canvas `128×128`;
- foot anchor `(64,104)`;
- map scale `0.68` at zoom 1.0;
- actor box `88×92`.

Locked bones:

`root, pelvis, torso, head, arm_l, arm_r, hand_weapon, leg_l, leg_r`.

Locked render order:

`shadow -> aura -> hair_back -> weapon_back -> body -> outfit -> face -> hair_front -> head_accessory -> weapon_front -> accessory`.

The real scaffold gate already proved `Skeleton2D + 9 Bone2D + one AnimationPlayer`, deterministic appearance normalization, safe fallback, direction/mirror mapping and presentation read-only behavior.

The modular actor is still intentionally isolated from the live sect map. Appearance persistence is also not wired into `DiscipleState` yet.

---

# female_normal_v1 production contract — locked

- `down` = authored front;
- `right` = authored right-facing side;
- `up` = authored back;
- `left` = mirror from `right` while mirror-safe;
- every runtime cutout is full-canvas `128×128` RGBA;
- foot registration stays `(64,104)`;
- no crop/recenter per piece;
- runtime naming `<variant>_<direction>_<piece>.png`;
- anatomical `l/r` means character-left/character-right;
- practical bone rest positions may only be tuned after real art proves a pivot mismatch; bone IDs/hierarchy and foot anchor remain stable.

---

# Stage A — DOWN/FRONT pivot-lock proof

Status: **IMPLEMENTED / REAL WINDOWS FAST CHECK PENDING**.

Current proof pack contains 14 registered runtime components:

- body: `head`, `torso`, `arm_l`, `arm_r`, `leg_l`, `leg_r`;
- face: `face_01_down`;
- hair: `hair_01_down_back`, `hair_01_down_front`;
- outfit: `torso`, `arm_l`, `arm_r`, `skirt`;
- head accessory: `horn_01_down`.

This is a pivot-lock diagnostic, not final polished character art.

## Real failure observed on 2026-10-03

The first Windows Stage A run failed before asset verification because the old directly tracked binary ZIP was corrupted during text-only connector transport:

```text
End of Central Directory record could not be found.
```

Because extraction failed, the following Stage A test correctly reported all 14 PNGs missing. That missing-asset error was downstream of packaging; it was not evidence of a Godot rig failure.

Stage A therefore remains **NOT PASS**.

## Packaging fix

Direct binary ZIP tracking through the text connector is retired.

The runtime pack is now stored as verified Base64 text chunks under `tools/assets/`. The canonical ZIP represented by those chunks has SHA-256:

`0c23ed5ee12cf5ec838e0a87b00f33122f6a196bd3812ecf96de2d99086fcc7c`

`Install-P3-2-Female-StageA.cmd` now:

1. concatenates the tracked text chunks in fixed order;
2. decodes them to a temporary ZIP;
3. verifies the SHA-256 above;
4. only then extracts the 14 PNGs;
5. stops immediately if rebuild/checksum/extraction fails;
6. runs the FAST Stage A verifier after successful installation.

The corrupted direct binary pack and obsolete intermediate pack files are no longer authoritative.

---

# Stage A verification policy

Normal art/pivot iteration must **not** rerun P0-P2.12 every time.

## FAST — normal Stage A iteration

Use:

`Verify-P3-2-Female-StageA.cmd`

It runs only:

1. Godot import for changed assets;
2. P3.2 Character Creator shared-rig contract;
3. P3.2 Stage A down/front asset contract;
4. Stage A sandbox smoke.

Expected final line:

`FEMALE STAGE A DOWN FAST CHECK: PASS`

## FULL — final acceptance only

Use only after the real art/pivots look correct:

`Verify-P3-2-Female-StageA-Full.cmd`

That launcher reruns the full cumulative chain before the Stage A checks. Only this later final gate is allowed to lock Stage A as a regression-safe milestone.

---

# Next authoritative Windows action

From repo root run the same launcher again:

```bat
Sync-P3-2-Female-StageA.cmd
```

It now performs:

`fetch/pull -> rebuild verified Stage A pack -> SHA-256 check -> extract 14 PNGs -> FAST P3.2 Stage A check`.

There should be no P0-P2.12 cumulative spam in this normal FAST iteration.

If it fails, fix the first real error only. Do not weaken tests.

---

# Development order after FAST Stage A is green

1. visually inspect down/front sandbox at zoom `0.75 / 1.0 / 1.35`;
2. tune practical bone rest positions only where the real art proves misalignment;
3. lock down/front pivots;
4. repeat registered asset process for authored `right` and `up` views;
5. author shared idle + walk `AnimationLibrary`;
6. add `face_02`, `hair_02/03`, `outfit_02`, `weapon_01/02` and tint masks;
7. prove at least 6 combinations on the same shared rig;
8. run the FULL cumulative visual-slice gate;
9. only then integrate `ModularDiscipleActor` into the live sect map;
10. add backward-compatible `appearance_profile` persistence without changing P2.8 RNG;
11. then expand to `male_normal_v1`, more actions and larger asset volume.
