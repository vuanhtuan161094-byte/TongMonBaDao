# CURRENT CHECKPOINT

Date: 2026-10-03

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 evidence confirms:

- P0-P2.12: PASS;
- P3.1 mobile landscape + living sect shell: PASS;
- P3.2 camera + map target selection + real disciple tabs interaction slice: PASS;
- P3.2 Character Creator V1 shared-rig scaffold: PASS;
- P3.2 `female_normal_v1` Stage A **FAST** check: PASS.

Latest real Stage A FAST tail supplied by the user:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A FAST CHECK: PASS
FEMALE STAGE A DOWN FAST CHECK: PASS
```

Important distinction: the production female visual slice / Stage A final milestone is **NOT final PASS yet**. FAST proves packaging/import/shared-rig/asset-contract/sandbox-smoke only. Visible pivot quality must still be inspected, then the separate FULL cumulative gate must pass before locking the milestone.

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

The shared-rig scaffold is still intentionally isolated from the live sect map. Appearance persistence is not wired into `DiscipleState` yet.

---

# female_normal_v1 Stage A — DOWN/FRONT pivot-lock proof

Status: **FAST GREEN / VISUAL PIVOT REVIEW PENDING**.

Current proof pack contains 14 registered runtime components:

- body: `head`, `torso`, `arm_l`, `arm_r`, `leg_l`, `leg_r`;
- face: `face_01_down`;
- hair: `hair_01_down_back`, `hair_01_down_front`;
- outfit: `torso`, `arm_l`, `arm_r`, `skirt`;
- head accessory: `horn_01_down`.

These are pivot-lock diagnostic assets, not final polished production art.

FAST verifier now runs only:

1. import changed Stage A assets;
2. P3.2 Character Creator shared-rig contract;
3. P3.2 Stage A down/front asset contract;
4. Stage A sandbox smoke.

It does **not** rerun P0-P2.12 on each art/pivot iteration.

The verified Base64 runtime pack decodes to ZIP SHA-256:

`0c23ed5ee12cf5ec838e0a87b00f33122f6a196bd3812ecf96de2d99086fcc7c`

Packaging/tooling issues encountered earlier (corrupt direct ZIP, launcher self-update, generated asset git noise, Godot discovery/import wrapper) have been fixed and are no longer the active blocker.

---

# Next authoritative action — visual pivot review

A visual launcher now exists:

`Preview-P3-2-Female-StageA.cmd`

It opens the same FAST-green sandbox visually with the down/front actor shown at:

- `0.75x`;
- `1.00x`;
- `1.35x`.

Inspect:

- face/hair/horns remain one coherent head;
- shoulders/arms do not split from torso;
- outfit/skirt has no broken seams;
- legs/feet remain coherent and share ground registration;
- silhouette is still readable at `0.75x`.

Do **not** tune bone rest positions from estimates. Change practical pivots only if this real preview visibly proves misalignment.

After visual review:

1. if misaligned: tune only the affected practical bone rest positions, rerun FAST, review again;
2. if visually acceptable: lock down/front pivots;
3. produce authored `right` and `up` views on the same registration;
4. then shared idle + walk AnimationLibrary;
5. then add face/hair/outfit/weapon variants + tint masks and six-combination proof;
6. only after visible proof is accepted run `Verify-P3-2-Female-StageA-Full.cmd`;
7. only FULL cumulative green may lock Stage A as a regression-safe milestone;
8. live-map integration and appearance persistence remain later work.
