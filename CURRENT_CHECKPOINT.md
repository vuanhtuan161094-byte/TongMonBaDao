# CURRENT CHECKPOINT

Date: 2026-10-03

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 cumulative evidence confirms:

- P0-P2.12: PASS;
- P3.1 mobile landscape + living sect shell: PASS;
- P3.2 camera + map target selection + real disciple tabs interaction slice: PASS;
- P3.2 Character Creator V1 shared-rig scaffold: PASS.

Latest authoritative Character Creator run ended with:

```text
P3.1 LANDSCAPE SECT SHELL GATE: PASS
P3.2 MAP CAMERA TEST PASS
P3.2 DISCIPLE UI INTEGRATION TEST PASS
P3.2 CAMERA + DISCIPLE UI GATE: PASS
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 CHARACTER CREATOR SCAFFOLD GATE: PASS
CHARACTER CREATOR V1 SCAFFOLD GATE: PASS
```

Do not reopen these locked runtime contracts without new regression evidence.

Important distinction: the Character Creator scaffold is runtime-green; the production character-art vertical slice is not yet PASS.

---

# Character authority

Read `docs/DISCIPLE_MASTER_SCHEMA.md` before changing character gameplay systems.

Locked principles:

- one disciple is one canonical `DiscipleState` identity;
- six foundation dimensions remain Tư Chất / Căn Cốt / Cơ Duyên / Thông Tuệ / Mị Lực / Tiềm Lực;
- disciple quality is derived rather than separately rolled;
- Linh căn / Huyết Mạch / Thể Chất / traits / Destiny remain separate axes;
- hidden identity is generated once and persisted;
- reveal/awakening/transformation never rerolls hidden identity;
- presentation must never create parallel gameplay authority;
- appearance must never mutate combat/cultivation/economy state;
- `sex_id` remains canonical identity for an existing disciple;
- appearance work must not consume or reorder the P2.8 RNG stream.

The player is the **Tông Chủ**. Disciples remain autonomous people; player influence is primarily infrastructure, recruitment, policy, investment, assignment and strategic intervention.

---

# Presentation canon

- mobile landscape;
- base logical resolution `1280×720`;
- map-first sect management;
- thin edge HUD;
- direct building/disciple tap;
- parchment overlays preserve map context;
- UX structure may learn from `Ta Làm Tông Sư Trong Tiên Môn`, but production art/text/icons/map must be original.

`Sync-P3-2-Camera.cmd` remains the cumulative regression launcher for the locked P3.1/P3.2 interaction baseline.

---

# CHARACTER CREATOR V1 — RUNTIME-GREEN SCAFFOLD

Status: **DESIGN LOCKED + SHARED-RIG SCAFFOLD RUNTIME PASS ON REAL GODOT 4.7.2**.

Canonical spec:

`docs/P3_2_MODULAR_ACTOR_SPEC.md`

Asset plan:

`docs/P3_2_ASSET_MANIFEST.md`

Female production contract:

`docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`

Canonical direction:

**modular appearance + shared 2D rig/animation**.

Map actor and profile portrait remain separate pipelines.

Initial rig IDs:

- `female_normal_v1`;
- `male_normal_v1`.

Canonical source registration:

- source canvas `128×128`;
- foot anchor `(64,104)`;
- source-to-map scale `0.68` at map zoom 1.0;
- actor scaffold box `88×92`;
- visual body target about `64–70` logical px.

Canonical internal bones:

`root, pelvis, torso, head, arm_l, arm_r, hand_weapon, leg_l, leg_r`.

Canonical render layers back-to-front:

`shadow -> aura -> hair_back -> weapon_back -> body -> outfit -> face -> hair_front -> head_accessory -> weapon_front -> accessory`.

Architecture proven by the real gate:

- one `Skeleton2D`;
- canonical nine-`Bone2D` hierarchy;
- one `AnimationPlayer`;
- no timeline-per-layer `AnimatedSprite2D` architecture;
- deterministic default appearance from persisted identity;
- invalid appearance values fall back safely;
- public directions remain `down/right/up/left`;
- mirror-safe left may reuse right playback while public facing remains left;
- presentation actor does not mutate `DiscipleState`.

The modular rig is still deliberately **not wired into the live sect map**. Appearance persistence is also still not wired into locked `DiscipleState`/generator.

---

# female_normal_v1 production contract — LOCKED

Detailed naming/export authority:

`docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`

Locked rules include:

- `down` = authored front;
- `right` = authored right-facing side;
- `up` = authored back;
- `left` = mirror from `right` while mirror-safe;
- every runtime cutout is full-canvas `128×128` RGBA PNG;
- foot registration remains `(64,104)`;
- no auto-crop/recenter per piece;
- runtime naming pattern `<variant>_<direction>_<piece>.png`;
- anatomical `l/r` means character-left/character-right;
- exact practical pivots may be tuned only from real art while keeping bone IDs/hierarchy and `(64,104)` stable.

---

# Stage A — DOWN/FRONT PIVOT-LOCK PACK

Status: **ART PACK + ISOLATED LOADER/TEST/SANDBOX IMPLEMENTED / AWAITING REAL GODOT 4.7.2 GATE**.

The approved turnaround was normalized to a real `128×128` down/front master with baseline `(64,104)`. A pivot-lock extraction pack was created from that master.

Current Stage A down/front pack contains 14 runtime PNG components:

- body: `head`, `torso`, `arm_l`, `arm_r`, `leg_l`, `leg_r`;
- face: `face_01_down`;
- hair: `hair_01_down_back`, `hair_01_down_front`;
- outfit: `torso`, `arm_l`, `arm_r`, `skirt`;
- head accessory: `horn_01_down`.

All PNGs are `128×128` and share the same registration transform. The extraction composite covers about 98.8% of the approved master silhouette; this is a **pivot-lock proof diagnostic**, not a final-art quality claim.

Tracked binary pack:

`tools/assets/female_normal_v1_stageA_repo_pack.zip`

The pack extracts into:

`godot/assets/p3/character_creator/parts/female_normal_v1/...`

New isolated Stage A files:

- `godot/src/presentation/p3/female_stage_a_asset_loader.gd`;
- `godot/tests/presentation/p3_2_female_stage_a_down_contract_test.gd`;
- `godot/src/presentation/p3/female_stage_a_down_sandbox.gd`;
- `godot/scenes/p3/p3_2_female_stage_a_down_sandbox.tscn`;
- `tools/godot/Verify-P3-2-Female-StageA.ps1`;
- `Verify-P3-2-Female-StageA.cmd`;
- `Install-P3-2-Female-StageA.cmd`.

The Stage A verifier is intentionally isolated and first reruns the already-green Character Creator cumulative chain. It then verifies all required PNGs exist, are exactly `128×128`, attach all 14 components to `ModularDiscipleActor`, replace placeholder mode, preserve down facing, and smoke-load the visual sandbox.

No Stage A PASS may be claimed until the user's real Windows/Godot output says so.

---

# Next authoritative Windows action

From:

```bat
cd /d "E:\0.2. TongMonBaDao"
```

first update local `main`, then run:

```bat
Install-P3-2-Female-StageA.cmd
```

The installer uses the tracked ZIP under `tools\assets`, extracts the 14 PNGs into the correct `godot/assets/...` tree, then automatically runs:

```bat
Verify-P3-2-Female-StageA.cmd
```

If the gate fails, fix the **first real parser/import/runtime/assertion failure only**. Do not weaken tests.

---

# Development order after Stage A down gate is green

1. inspect the real down/front sandbox at zoom `0.75 / 1.0 / 1.35`;
2. tune practical bone rest positions only where the real art proves misalignment;
3. lock the down/front pivots;
4. repeat the same registered asset process for authored `right` and `up` views;
5. author the shared idle + walk `AnimationLibrary`;
6. add `face_02`, `hair_02/03`, `outfit_02`, `weapon_01/02` and tint masks;
7. create a sandbox proving at least 6 combinations on the same shared rig;
8. run a real Godot visual-slice gate;
9. only then integrate `ModularDiscipleActor` into the live sect map;
10. add backward-compatible `appearance_profile` persistence with no P2.8 RNG-stream change;
11. only then expand to `male_normal_v1`, more actions and larger asset volume.

Do not call the production Character Creator vertical slice PASS until real art + shared animation are visible and its real Godot gate is green.
