# CURRENT CHECKPOINT

Date: 2026-10-03

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 cumulative evidence confirms **P0 through P2.12 PASS**.

Locked chain:

- P0 Foundation: LOCKED / PASS.
- P1.1 Goal + Personality: LOCKED / PASS.
- P1.2 Recruitment + Player Choice: LOCKED / PASS.
- P1.3 Relationships + Behavioral Impact: LOCKED / PASS.
- P1.4 Consequential Memory: PASS.
- P1.5 Organization + Teams + Leadership + Combat Roles: PASS.
- P1.6 Sect Life + Needs + Resource Pressure: PASS.
- P2.1 Cultivation + Realms + Breakthrough: PASS.
- P2.2 Spiritual Roots: PASS.
- P2.3 Technique Economy + Library + Mastery: PASS.
- P2.4 Cultivation Paths: PASS.
- P2.5 Realtime Combat + Independent Skills: PASS.
- P2.6 Forge + Equipment Tycoon: LOCKED / PASS.
- P2.7 Disciple Life + Workforce + Sect Assignment: LOCKED / PASS.
- P2.8 Disciple Generation V2 + Phẩm chất + Recruitment Sources: LOCKED / PASS.
- P2.9 Traits + Quirks + Hidden Reveal: LOCKED / PASS.
- P2.10 Spiritual Root Refinement + Mutation: LOCKED / PASS.
- P2.11 Bloodline + Awakening + Purity: LOCKED / PASS.
- P2.12 Physique + Grades + Tempering + Transformation: LOCKED / PASS.

Latest authoritative runtime evidence ended with the final `P2.12 GATE: PASS` chain. Do not reopen P0-P2.12 without new regression evidence.

---

# Character authority

Read `docs/DISCIPLE_MASTER_SCHEMA.md` before changing character gameplay systems.

Locked principles:

- six foundation dimensions: Tư Chất / Căn Cốt / Cơ Duyên / Thông Tuệ / Mị Lực / Tiềm Lực;
- disciple quality is derived rather than separately rolled;
- Linh căn / Huyết Mạch / Thể Chất / traits / Destiny are separate axes;
- hidden identity is generated once and persisted;
- reveal/awakening/transformation never rerolls hidden identity;
- systems may overlap on real effects when logical;
- named mechanics require real consequences, not UI-only flavor;
- presentation must never create parallel gameplay authority.

The player is the **Tông Chủ**. Disciples are autonomous people. Player influence is through infrastructure, recruitment, policy, investment, assignment and strategic intervention rather than routine puppet-style micromanagement.

---

# Presentation canon

- mobile landscape;
- base logical resolution `1280×720`;
- map-first sect management;
- thin edge HUD rather than desktop dashboard;
- direct building/disciple tap;
- parchment overlays preserve map context;
- disciple screen uses left roster + central character + right detail + lower tabs;
- UX structure may learn from `Ta Làm Tông Sư Trong Tiên Môn`, but production art/text/icons/map must be original.

---

# P3.1 — Mobile ngang + Tông Môn Sống V1

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

Implemented presentation base includes:

- landscape shell;
- real action -> visible map destination mapping;
- visible disciple movement between work/rest/cultivation/gate destinations;
- building/disciple popup reads real state;
- quick Sect Master orders call real workforce systems;
- no parallel gameplay engine.

P3.1 is not yet runtime-confirmed on the user's current Windows gate run.

---

# P3.2 — Camera + map selection + real disciple tabs

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

Current main scene:

`res://scenes/p3/p3_2_landscape_sect.tscn`

Implemented:

- map-only zoom/pan while HUD/popups remain fixed;
- pinch zoom + one-finger pan;
- desktop wheel zoom + drag pan;
- double-tap/double-click quick zoom;
- camera clamp and anchored zoom;
- building/disciple focus + gold selection marker;
- focus target button;
- tabs reading the same real `SimulationState`: Thuộc tính / Công pháp / Trang bị / Huyết Mạch / Thể Chất / Quan hệ;
- Bloodline/Physique action buttons use real systems/resources;
- hidden identity remains hidden where required.

Authoritative pending launcher:

`Sync-P3-2-Camera.cmd`

Do **not** call P3.1/P3.2 PASS until real Windows/Godot output reaches the cumulative gate.

---

# CHARACTER CREATOR V1 + FEMALE NORMAL RIG V1

Status: **DESIGN LOCKED + SAFE ISOLATED SCAFFOLD IMPLEMENTED / NOT YET RUN ON REAL GODOT**.

Canonical spec:

`docs/P3_2_MODULAR_ACTOR_SPEC.md`

Asset plan:

`docs/P3_2_ASSET_MANIFEST.md`

## New production direction

Retired:

- one complete spritesheet/video animation set per disciple;
- six complete map-actor families with duplicated animations;
- arbitrary Grok part-splitting before a rig contract exists.

Canonical direction:

**Character Creator = modular appearance + shared 2D rig/animation.**

Map actor and profile portrait are separate pipelines.

Map actor style:

- mature chibi;
- large head + compact body;
- cute but not childlike;
- female may be lightly/tastefully sexy where appropriate;
- xianxia/mobile 2D;
- clear silhouette;
- low micro-detail;
- avoid glossy AI hero-art.

## Rig V1

Initial rig IDs:

- `female_normal_v1`;
- `male_normal_v1`.

Future only after proof:

- `female_heavy_v1`;
- `male_heavy_v1`;
- special body types.

Canonical source registration:

- `128×128` canvas;
- foot anchor `(64,104)`;
- source-to-map scale `0.68` at map zoom 1.0;
- actor scaffold box `88×92`;
- visual body target about `64–70` logical px.

Canonical internal bones:

`root, pelvis, torso, head, arm_l, arm_r, hand_weapon, leg_l, leg_r`.

Canonical render layers back-to-front:

`shadow -> aura -> hair_back -> weapon_back -> body -> outfit -> face -> hair_front -> head_accessory -> weapon_front -> accessory`.

Body/Outfit are single creator choices but may internally use coarse cutouts for head/torso/arms/legs. Do not fragment creator choices into eyes/fingers/shoes.

## Shared animation

One rig uses one `AnimationPlayer`/shared `AnimationLibrary` driving `Bone2D` transforms.

Public directions remain:

`down / right / up / left`.

V1 may mirror right motion for left when mirror-safe. Public facing still stays `left`; asymmetric assets may later provide authored-left.

Required first motion proof:

- idle 4 public directions;
- walk 4 public directions.

Cultivate/work/combat/mining/forging/heal/rest follow only after the first rig proof.

## Current scaffold files

- `godot/src/presentation/p3/disciple_actor_visual_catalog.gd`;
- `godot/src/presentation/p3/modular_disciple_actor.gd`;
- `godot/tests/presentation/p3_2_modular_actor_contract_test.gd`;
- `tools/godot/Verify-P3-2-Character-Creator.ps1`;
- `Verify-P3-2-Character-Creator.cmd`.

`ModularDiscipleActor` now scaffolds:

- `Skeleton2D`;
- canonical `Bone2D` hierarchy;
- one `AnimationPlayer`;
- deterministic default appearance profile from persisted identity;
- left-mirror playback rule;
- registered full-canvas texture attachment helpers;
- safe placeholder behavior when production art is missing.

The old synchronized `AnimatedSprite2D/SpriteFrames` layer architecture is retired for this scaffold.

## Important isolation rule

The new rig is deliberately **not yet wired into the live P3.2 map scene** and its test is not added to `Sync-P3-2-Camera.cmd`.

Reason: P3.1/P3.2 camera/UI still await real runtime evidence. Do not destabilize that pending gate before seeing the actual Windows result.

## Appearance persistence target

Target schema is documented as `appearance_profile` containing:

- schema version;
- rig/body/face/hair/outfit/head accessory/weapon/accessory/aura IDs;
- hair/outfit tint RGB hex.

Rules:

- appearance is presentation identity only;
- default appearance may be derived deterministically from `profile_seed + sex_id`;
- existing disciple `sex_id` cannot be silently overridden by cosmetic UI;
- equipment visuals must eventually respect real equipped items/skin rules;
- appearance must not affect combat/cultivation/economy state.

Persistence is **not yet wired into locked DiscipleState/generator**. Add it only after real P3.2 + Character Creator parser/runtime checks, using a backward-compatible contract that does not consume or reorder the P2.8 RNG stream.

## Tint rule

Hair/outfit production uses base texture + tint mask/shader. Do not globally modulate multicolor art and accidentally tint skin/face/metal.

## Weapon rule

One weapon variant can use `back`, `front`, or split render passes attached to `hand_weapon`. Direction changes presentation only; it must never equip a fake gameplay item.

---

# Character Creator vertical slice

First proof is **female_normal_v1 only**:

- 1 body;
- at least 2 faces;
- 3 hairs;
- 2 outfits;
- 2 weapons;
- 1 horn/head accessory;
- several hair/outfit tint presets;
- shared idle + walk;
- at least 6 combinations simultaneously using the same rig/AnimationLibrary.

Acceptance proof:

- common foot anchor;
- no face/hair drift;
- outfit limbs stay aligned;
- weapon back/front works by direction;
- tint does not color skin/face;
- mirror does not break z-order;
- all combinations share motion;
- actor remains readable at map zoom 0.75 / 1.0 / 1.35.

Do not mass-produce character art before this proof.

---

# Next authoritative Windows order

First:

```bat
cd /d "E:\0.2. TongMonBaDao"
Sync-P3-2-Camera.cmd
```

If that cumulative P3.2 gate is green, then:

```bat
Verify-P3-2-Character-Creator.cmd
```

The Character Creator verifier reruns the existing P3.2 cumulative chain first, then executes the isolated shared-rig contract test.

Do not claim PASS before real output.

If a gate fails: fix the **first real parser/diagnostic/assertion failure only**. Do not weaken tests.

---

# Next development order after runtime green

1. resolve any real parser/runtime failure from the pending gates;
2. use one real `female_normal_v1` art sample to lock exact pivot positions;
3. author shared idle + walk `AnimationLibrary`;
4. build first coarse cutout body/outfit bundle + face/hair/weapon/horn;
5. build tint-mask shader/presets;
6. create a sandbox showing at least 6 combinations on one shared rig;
7. only then integrate `ModularDiscipleActor` into the live sect map;
8. add backward-compatible `appearance_profile` persistence contract;
9. only then expand to `male_normal_v1` and larger asset volume.
