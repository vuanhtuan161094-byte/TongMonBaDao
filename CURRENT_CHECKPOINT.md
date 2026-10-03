# CURRENT CHECKPOINT

Date: 2026-10-03

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 evidence confirms:

- P0-P2.12: PASS;
- P3.1 mobile landscape + living sect shell: PASS;
- P3.2 camera + map target selection + real disciple tabs interaction slice: PASS;
- P3.2 Character Creator V1 shared-rig scaffold: PASS;
- P3.2 `female_normal_v1` Stage A **DOWN/FRONT FAST** check: PASS.

Latest real down/front FAST tail supplied by the user:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A FAST CHECK: PASS
FEMALE STAGE A DOWN FAST CHECK: PASS
```

The production female visual slice / Stage A final milestone is **NOT final PASS yet**. Do not run or claim the FULL cumulative milestone until the authored direction proof and later visual slice work are accepted.

---

# Character Creator locked contract

Canonical architecture remains **modular appearance + shared 2D rig/animation**.

Locked registration:

- source canvas `128×128`;
- foot anchor `(64,104)`;
- map scale `0.68` at zoom 1.0;
- actor box `88×92`;
- bones: `root, pelvis, torso, head, arm_l, arm_r, hand_weapon, leg_l, leg_r`;
- render order: `shadow -> aura -> hair_back -> weapon_back -> body -> outfit -> face -> hair_front -> head_accessory -> weapon_front -> accessory`.

Appearance remains presentation-only and must not mutate `DiscipleState`, stats, economy, actions, `sex_id`, or P2.8 RNG consumption/order.

---

# Stage A down/front — visual pivot accepted

The user opened the real visual preview after the down/front FAST gate passed and supplied a screenshot showing the same actor at `0.75x`, `1.00x`, `1.35x`.

Visual review result on 2026-10-03:

- face/hair/horns remain a coherent head;
- shoulders/arms do not visibly split from torso;
- outfit/skirt has no major broken seam;
- legs/feet remain coherent on the same ground registration;
- silhouette remains readable at `0.75x`;
- dark hair + dark skirt merge somewhat at `0.75x`, but this is an art contrast/simplification issue for later polish, **not** evidence of a pivot mismatch.

Therefore the practical **down/front pivot-lock is visually accepted** and the current bone rest positions remain unchanged. Do not retune bones from old estimates.

This does **not** mean polished production art is finished.

---

# Stage A authored directions — implementation ready, Windows gate pending

The diagnostic proof has now been expanded from down/front only to the three authored V1 directions:

- `down` = front;
- `right` = authored right-facing side;
- `up` = authored back;
- `left` remains intentionally unauthored and will mirror `right` while mirror-safe.

Each authored direction contains 14 registered `128×128` runtime components:

- body: `head`, `torso`, `arm_l`, `arm_r`, `leg_l`, `leg_r`;
- face;
- hair back/front;
- outfit torso/arm_l/arm_r/skirt;
- horn.

Total generated Stage A runtime proof files: **42 PNGs**.

For `up`, the face layer is intentionally transparent so no front-face detail can leak through the back view.

The new verified runtime pack is stored as four Base64 text chunks:

- `tools/assets/female_normal_v1_stageA_v2q_01.b64`;
- `tools/assets/female_normal_v1_stageA_v2q_02.b64`;
- `tools/assets/female_normal_v1_stageA_v2q_03.b64`;
- `tools/assets/female_normal_v1_stageA_v2q_04.b64`.

Decoded ZIP SHA-256:

`6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`

Local static pack inspection confirms exactly **42/42 expected paths** are present. The Windows installer must still reconstruct this pack and verify the same SHA before extraction.

Relevant new/updated implementation:

- `Install-P3-2-Female-StageA.cmd` — installs verified 42-file pack;
- `godot/src/presentation/p3/female_stage_a_asset_loader.gd` — `down/right/up` authored loading;
- `godot/tests/presentation/p3_2_female_stage_a_directions_contract_test.gd` — three-direction registration/attachment contract;
- `godot/src/presentation/p3/female_stage_a_directions_sandbox.gd`;
- `godot/scenes/p3/p3_2_female_stage_a_directions_sandbox.tscn`;
- `Preview-P3-2-Female-Directions.cmd`.

No live sect-map integration has been made.

---

# FAST verification policy

Normal art/pivot iteration remains **P3.2 FAST only** and does not rerun P0-P2.12.

`Verify-P3-2-Female-StageA.cmd` now runs:

1. import changed Stage A assets;
2. Character Creator shared-rig contract;
3. locked down/front regression contract;
4. authored `down/right/up` asset contract;
5. authored-direction sandbox smoke.

Expected new green tail includes:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
```

`Verify-P3-2-Female-StageA-Full.cmd` remains final-acceptance-only and has been extended to cover the three authored directions. **Do not run FULL yet.**

---

# Sync guard note — generated Stage A PNGs

A real Windows attempt to run the new three-direction sync stopped before fetch with:

```text
[STOP] Local changes detected.
?? godot/assets/
```

Cause: the local checkout still had an older `.gitignore`, while the installer-generated `right/up` PNGs already existed. This created a bootstrap deadlock: generated assets blocked the pull that would bring the new ignore rules.

Live `main` now has two protections:

1. `.gitignore` ignores only the exact generated Stage A `down/right/up` proof PNG patterns;
2. `Sync-P3-2-Female-StageA.cmd` independently allows only those exact untracked generated Stage A PNG paths through its dirty-worktree guard, while still blocking all other changes.

The sync-guard fix is commit `7a8839bb3c6a9557e3e652c80619d2421f21c107`.

One manual `git pull --ff-only origin main` is required on a checkout still using the older launcher to break this bootstrap loop. No reset/clean/delete is required.

---

# Next authoritative Windows action

With all Godot windows closed, from repo root run once:

```bat
git pull --ff-only origin main
```

Then run normally:

```bat
Sync-P3-2-Female-StageA.cmd
```

The sync launcher should:

`fetch/pull -> rebuild 4 Base64 chunks -> verify SHA-256 -> install 42 PNGs -> run 5-step P3.2 FAST gate`.

If FAST is green, visually open:

```bat
Preview-P3-2-Female-Directions.cmd
```

The preview shows `down/right/up` at `0.75x` and `1.35x`. Review identity/proportions, horn/hair roots, shoulder/hip continuity, common foot registration, right-side readability, back-view face leakage and 0.75x silhouette.

Only tune practical pivots if that real preview proves a mismatch.

---

# Development order after three-direction visual acceptance

1. lock authored `down/right/up` registration;
2. author shared `idle + walk` AnimationLibrary for public `down/right/up/left` (`left` mirror-right while safe);
3. add `face_02`, `hair_02/03`, `outfit_02`, `weapon_01/02`;
4. add tint masks/presets;
5. prove at least 6 combinations on the same shared rig/motion;
6. run the FULL cumulative visual-slice gate only when the visible proof is ready to lock;
7. only then integrate `ModularDiscipleActor` into the live sect map;
8. add backward-compatible `appearance_profile` persistence without changing P2.8 RNG;
9. then expand to `male_normal_v1`, more actions and larger asset volume.
