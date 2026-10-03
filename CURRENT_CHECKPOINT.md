# CURRENT CHECKPOINT

Date: 2026-10-03

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 cumulative evidence now confirms:

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

Important distinction: the **Character Creator scaffold is runtime-green**, but the production character-art vertical slice is not done. No real female cutout set, shared idle/walk AnimationLibrary, tint-mask art proof or live-map integration has been accepted yet.

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

Current scaffold files:

- `godot/src/presentation/p3/disciple_actor_visual_catalog.gd`;
- `godot/src/presentation/p3/modular_disciple_actor.gd`;
- `godot/tests/presentation/p3_2_modular_actor_contract_test.gd`;
- `tools/godot/Verify-P3-2-Character-Creator.ps1`;
- `Verify-P3-2-Character-Creator.cmd`.

`Verify-P3-2-Character-Creator.cmd` is now the authoritative Character Creator regression launcher: it reruns the cumulative P3.2 chain and then the shared-rig contract test.

The modular rig is still deliberately **not wired into the live sect map**. Appearance persistence is also still not wired into locked `DiscipleState`/generator.

---

# Character Creator production vertical slice — ACTIVE

First production proof is **female_normal_v1 only**.

Target minimum:

- 1 body;
- 2 faces;
- 3 hairs;
- 2 outfits;
- 2 weapons;
- 1 horn/head accessory;
- several hair/outfit tint presets;
- shared idle + walk, public 4 directions;
- at least 6 visual combinations sharing the same rig and AnimationLibrary.

Acceptance proof must show:

- common foot registration;
- no face/hair drift;
- outfit limbs stay aligned to the rig;
- weapon front/back works by direction;
- tint masks do not color skin/face/metal accidentally;
- mirror does not break z-order or handedness assumptions;
- all six combinations share motion rather than duplicate animations;
- actor remains readable at map zoom 0.75 / 1.0 / 1.35.

Do not mass-produce art before this female proof is accepted.

## female_normal_v1 asset production contract — LOCKED

Detailed checklist + naming authority:

`docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`

The contract is based on the two user-supplied female reference images from 2026-10-03 and locks:

- mature-chibi style target and silhouette priorities;
- authored runtime directions: `down`=front, `right`=side, `up`=back;
- public `left` remains mirror-from-right for mirror-safe V1 variants;
- every runtime cutout is full-canvas `128×128` PNG with foot registration `(64,104)` and no auto-crop;
- runtime naming pattern `<variant>_<direction>_<piece>.png`;
- tint-mask naming `<variant>_<direction>_<piece>_tint_mask.png`;
- anatomical `l/r` means character-left/character-right, never screen-left/screen-right;
- exact piece sets for `body_01`, `face_01..02`, `hair_01..03`, `outfit_01..02`, `horn_01`, `weapon_01..02`;
- Stage A pivot-lock -> Stage B shared motion -> Stage C modular variants -> Stage D map-scale proof.

The existing scaffold bone rest positions are still a starting point, not final art pivots. Exact practical pivots may be tuned only after Stage A real art is attached, while keeping bone IDs/hierarchy and the `(64,104)` registration contract stable.

---

# Next development order

1. execute **Stage A — Pivot-lock sample** from `docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md` using the approved two-image reference direction;
2. create the baseline `body_01 + face_01 + hair_01 + outfit_01 + horn_01` master art for `down/right/up`;
3. export full-canvas named cutouts and attach them to the existing shared rig;
4. lock exact practical head/shoulder/hip/hand/foot pivots from the real art;
5. author the shared idle + walk `AnimationLibrary`;
6. add `face_02`, `hair_02/03`, `outfit_02`, `weapon_01/02` and tint masks;
7. create a sandbox proving at least 6 combinations on the same shared rig;
8. run a real Godot gate for that visual slice;
9. only then integrate `ModularDiscipleActor` into the live sect map;
10. add backward-compatible `appearance_profile` persistence with no P2.8 RNG-stream change;
11. only then expand to `male_normal_v1`, more actions and larger asset volume.

Do not call the production Character Creator vertical slice PASS until real art + shared animation are visible and its real Godot gate is green.
