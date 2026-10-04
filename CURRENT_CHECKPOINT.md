# CURRENT CHECKPOINT

Date: 2026-10-04

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 evidence confirms:

- P0-P2.12: PASS;
- P3.1 mobile landscape + living sect shell: PASS;
- P3.2 camera + map target selection + real disciple tabs interaction slice: PASS;
- P3.2 Character Creator V1 shared-rig scaffold: PASS;
- P3.2 `female_normal_v1` Stage A **3-DIRECTION FAST** check: PASS (down/right/up) with user visual review accepted.
- P3.2 `female_normal_v1` shared **IDLE + WALK FAST** check: PASS on real Windows Godot 4.7.2; user video visual review accepted.
- P3.3 disciple operational flow (right summary -> real quick orders -> 6-tab deep screen -> context restore): **IMPLEMENTED ON MAIN, RUNTIME PENDING**. Do not call PASS until the dedicated Windows gate is green.

Latest real 3-direction FAST tail supplied by the user:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
```

User also supplied the real direction-preview screenshot. Visual review accepted front/side/back identity, common ground registration, readable 0.75x silhouette, and no front-face leakage in the back view.

The production female visual slice / Stage A final milestone is **NOT final PASS yet**. Three-direction FAST + visual review are locked. Shared idle/walk runtime contract, sandbox smoke and user video visual review are now accepted. Variants/tints/six-combo proof and the FULL cumulative acceptance remain later.

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

The user opened the real preview after the down/front FAST gate passed and supplied a screenshot at `0.75x`, `1.00x`, `1.35x`.

Accepted visual observations:

- face/hair/horns remain coherent;
- shoulders/arms do not visibly split from torso;
- no major outfit/skirt seam;
- legs/feet share the same ground registration;
- silhouette remains readable at `0.75x`.

Dark hair + skirt merge somewhat at `0.75x`, but this is future art contrast/simplification work, not evidence of a pivot mismatch.

Therefore **down/front practical pivots are visually locked** and current bone rest positions remain unchanged.

---

# Stage A authored directions — Windows FAST + visual review PASS

Diagnostic proof now supports authored:

- `down` = front;
- `right` = side;
- `up` = back;
- `left` remains mirror-right while mirror-safe.

Each authored direction has 14 registered `128×128` components, total **42 PNGs**. `up` face is intentionally transparent to prevent front-face leakage.

Relevant implementation:

- `godot/src/presentation/p3/female_stage_a_asset_loader.gd`;
- `godot/tests/presentation/p3_2_female_stage_a_down_contract_test.gd`;
- `godot/tests/presentation/p3_2_female_stage_a_directions_contract_test.gd`;
- `godot/src/presentation/p3/female_stage_a_directions_sandbox.gd`;
- `godot/scenes/p3/p3_2_female_stage_a_directions_sandbox.tscn`;
- `Preview-P3-2-Female-Directions.cmd`;
- `Verify-P3-2-Female-StageA.cmd` — 5-step P3.2-only FAST gate;
- `Verify-P3-2-Female-StageA-Full.cmd` — final acceptance only; **do not run yet**.

Live sect-map integration remains untouched.

Real Windows Godot 4.7.2 FAST gate passed on 2026-10-04. The user then opened `Preview-P3-2-Female-Directions.cmd`; front/side/back were visually accepted. No pivot/rest-position retune is needed from this proof.

---

# FAST verification policy

Normal art/pivot iteration remains **P3.2 FAST only** and does not rerun P0-P2.12.

FAST runs:

1. import changed Stage A assets;
2. Character Creator shared-rig contract;
3. locked down/front regression contract;
4. authored `down/right/up` asset contract;
5. authored-direction sandbox smoke.

Expected green tail:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
```

---

# Binary asset transport — current authoritative method

The previous tracked 4-part Base64 v2 transport is **retired**.

Real Windows failure:

```text
Exception calling "FromBase64String" ... "Invalid length for a Base-64 char array or string."
```

Static comparison against the canonical local ZIP proved the tracked 4 chunks were incomplete by 1,793 Base64 characters. This was a transport/tooling defect, not a Godot, rig, registration, or art failure.

The malformed `female_normal_v1_stageA_v2q_*.b64` files and experimental replacement chunks were removed from live `main` so they cannot be reused accidentally.

Authoritative diagnostic binary pack now is:

`female_normal_v1_stageA_runtime_pack_v2_quant.zip`

Properties:

- 42 Stage A PNGs (`down/right/up`);
- ZIP size: 44,838 bytes;
- SHA-256: `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`.

`Install-P3-2-Female-StageA.cmd` now searches for this ZIP in:

- `STAGE_A_PACK` env path if explicitly supplied;
- repo root;
- user `Downloads`;
- user `Desktop`;
- duplicate browser-download names matching `female_normal_v1_stageA_runtime_pack_v2_quant*.zip`.

It computes SHA-256 first and extracts only a matching pack. A wrong/corrupt ZIP is rejected.

`.gitignore` continues to ignore only the exact generated Stage A PNGs, their `.png.import` sidecars, and an optional repo-root copy of this diagnostic ZIP. It does not hide unrelated asset work.

---

# Shared idle + walk — Windows FAST + visual motion review PASS

Real Windows Godot 4.7.2 evidence supplied by the user:

```text
P3.2 FEMALE SHARED IDLE WALK MOTION CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
P3.2 FEMALE SHARED IDLE WALK FAST CHECK: PASS
FEMALE STAGE A + SHARED MOTION FAST CHECK: PASS
```

The user supplied an 11.6-second real Windows motion video. Review accepted the current V1 motion: idle breathing is restrained, walk cadence is stable, there is no obvious anchor jump or severe shoulder/hip tearing, hair/horns remain attached, and LEFT mirrors RIGHT cleanly. Motion is intentionally simple/stiff at this stage; long-hair secondary motion is future polish, not a blocker for map integration.

# Next authoritative Windows action

**Do not run FULL yet.**

Run in this order:

1. `Verify-P3-2-Female-StageA.cmd`
   - required missing evidence: `P3.2 LIVE MODULAR FEMALE MAP INTEGRATION TEST PASS`;
   - this locks the already-implemented modular female actor on the real map.
2. If step 1 is green, run `Verify-P3-3-Disciple-Flow.cmd`
   - verifies map tap -> right operational summary;
   - real `WorkforceSystem` quick orders;
   - `Xem chi tiết` -> six real tabs;
   - roster switch + Back context restoration;
   - bottom-nav direct deep entry -> clean map.
3. Then visually playtest the real map: select moving disciples, issue orders, watch them move to simulation-derived destinations, switch disciples, pan/zoom, open buildings, enter/leave deep profile.

P3.3 is already implemented in code but remains **runtime pending** until this Windows evidence exists. Character cosmetic variants are not a blocker for this gate.

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
