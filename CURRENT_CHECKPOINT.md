# CURRENT CHECKPOINT

Date: 2026-10-03

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 cumulative evidence now confirms **P0 through P2.12 PASS, P3.1 PASS, and the P3.2 camera/map-selection/disciple-tabs interaction slice PASS**.

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
- P3.1 Mobile landscape + living sect shell: PASS.
- P3.2 camera + map target selection + real disciple tabs interaction slice: PASS.

Latest authoritative real Windows/Godot evidence on 2026-10-03 ended with:

```text
P3.1 LANDSCAPE SECT SHELL TEST PASS
P3.1 LANDSCAPE SECT SHELL GATE: PASS
P3.2 MAP CAMERA TEST PASS
P3.2 DISCIPLE UI INTEGRATION TEST PASS
P3.2 CAMERA + DISCIPLE UI GATE: PASS
P3.2 INTERACTION GATE: PASS
```

The parser fix immediately before this green run was commit `d5ee8e8148642738cfc9c03a7797ba67e829e80b` (`Fix P3.2 tab active type inference on Godot 4.7.2`).

Do not reopen P0-P3.2 interaction contracts without new regression evidence.

Important distinction: this confirms the **P3.2 interaction slice**, not the full production-art definition of done. Production buildings, environment art, UI skin and final map actors are still future work.

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

Status: **RUNTIME PASS on real Windows Godot 4.7.2**.

Confirmed presentation base includes:

- landscape shell;
- real action -> visible map destination mapping;
- visible disciple movement between work/rest/cultivation/gate destinations;
- building/disciple popup reads real state;
- quick Sect Master orders call real workforce systems;
- no parallel gameplay engine.

---

# P3.2 interaction slice — Camera + map selection + real disciple tabs

Status: **RUNTIME PASS on real Windows Godot 4.7.2**.

Current main scene:

`res://scenes/p3/p3_2_landscape_sect.tscn`

Runtime-green interaction includes:

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

`Sync-P3-2-Camera.cmd` remains the cumulative regression launcher for this locked interaction baseline.

---

# CHARACTER CREATOR V1 + FEMALE NORMAL RIG V1

Status: **DESIGN LOCKED + SAFE ISOLATED SCAFFOLD IMPLEMENTED / REAL CHARACTER CREATOR GATE STILL PENDING**.

Canonical spec:

`docs/P3_2_MODULAR_ACTOR_SPEC.md`

Asset plan:

`docs/P3_2_ASSET_MANIFEST.md`

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

Initial rig IDs:

- `female_normal_v1`;
- `male_normal_v1`.

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

One rig uses one `AnimationPlayer`/shared `AnimationLibrary` driving `Bone2D` transforms. Public directions remain `down / right / up / left`; mirror-right-for-left is allowed when mirror-safe.

Current scaffold files:

- `godot/src/presentation/p3/disciple_actor_visual_catalog.gd`;
- `godot/src/presentation/p3/modular_disciple_actor.gd`;
- `godot/tests/presentation/p3_2_modular_actor_contract_test.gd`;
- `tools/godot/Verify-P3-2-Character-Creator.ps1`;
- `Verify-P3-2-Character-Creator.cmd`.

The new rig is still deliberately **not wired into the live P3.2 map scene**. Its isolated runtime gate must go green first.

Appearance persistence is also still deliberately **not wired into locked DiscipleState/generator**. When added, it must be backward-compatible and must not consume or reorder the P2.8 RNG stream.

---

# Character Creator vertical slice target

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

Acceptance proof checks common foot registration, hair/face alignment, outfit limb alignment, weapon front/back, tint masks, mirror behavior, shared motion and readability at map zoom 0.75 / 1.0 / 1.35.

Do not mass-produce character art before this proof.

---

# Next authoritative Windows action

Now that `Sync-P3-2-Camera.cmd` is green, run:

```bat
cd /d "E:\0.2. TongMonBaDao"
Verify-P3-2-Character-Creator.cmd
```

This verifier intentionally reruns the existing P3.2 cumulative regression chain first, then executes:

`res://tests/presentation/p3_2_modular_actor_contract_test.gd`

Do not call Character Creator V1 PASS until the real Windows output says so.

If it fails: fix the **first real parser/diagnostic/assertion failure only**. Do not weaken tests.

---

# Next development order after Character Creator runtime green

1. resolve any real parser/runtime issue from the isolated Character Creator gate;
2. use one real `female_normal_v1` art sample to lock exact pivot positions;
3. author shared idle + walk `AnimationLibrary`;
4. build first coarse cutout body/outfit bundle + face/hair/weapon/horn;
5. build tint-mask shader/presets;
6. create a sandbox showing at least 6 combinations on one shared rig;
7. only then integrate `ModularDiscipleActor` into the live sect map;
8. add backward-compatible `appearance_profile` persistence contract;
9. only then expand to `male_normal_v1` and larger asset volume.
