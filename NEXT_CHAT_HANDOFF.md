# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-03

Always fetch/inspect live `main` before editing.

## Working style / user preference

- Code directly through the GitHub connector.
- Do not use Codex or Work.
- Do not ask the user to repeat anything already in repo/spec/handoff.
- Explain meaningful progress clearly in Vietnamese; user is non-technical.
- Never claim a runtime phase PASS without real Godot 4.7.2 output from the user's Windows machine.
- Never use destructive local git instructions (`reset --hard`, `git clean`, deleting user files, etc.).

Repo: `vuanhtuan161094-byte/TongMonBaDao`
Branch: `main`
Local: `E:\0.2. TongMonBaDao`
Godot: 4.7.2 stable console.

## Required read order before character/P3 work

1. `AGENTS.md`;
2. `CURRENT_CHECKPOINT.md`;
3. `NEXT_CHAT_HANDOFF.md`;
4. `docs/DISCIPLE_MASTER_SCHEMA.md`;
5. `docs/P3_2_MODULAR_ACTOR_SPEC.md`;
6. `docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md` for current female art work;
7. related P3 specs;
8. then inspect live code/tests before editing.

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 now confirms:

- P0-P2.12: PASS;
- P3.1 landscape shell: PASS;
- P3.2 camera + map target selection + real disciple tabs interaction slice: PASS;
- P3.2 Character Creator V1 shared-rig scaffold: PASS.

Authoritative Character Creator output on 2026-10-03 ended with:

```text
P3.2 MAP CAMERA TEST PASS
P3.2 DISCIPLE UI INTEGRATION TEST PASS
P3.2 CAMERA + DISCIPLE UI GATE: PASS
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 CHARACTER CREATOR SCAFFOLD GATE: PASS
CHARACTER CREATOR V1 SCAFFOLD GATE: PASS
```

Do not reopen P0-P3.2 interaction/shared-rig scaffold contracts without new regression evidence.

Important distinction: **the scaffold is green; the production Character Creator visual slice is not yet built.** Full P3.2 production art is also not complete.

## Character authority

Locked principles:

- one disciple is one canonical `DiscipleState` identity;
- hidden identity is generated once and persisted;
- reveal/awakening/transformation never rerolls hidden identity;
- UI/presentation may read gameplay state but may not invent parallel gameplay state;
- `sex_id` is canonical identity for an existing disciple and must not be silently changed by cosmetic UI;
- appearance is presentation identity only and must not affect stats/economy/action;
- appearance work must not consume/reorder existing P2.8 RNG.

## Product presentation canon

- mobile landscape, base logical resolution `1280×720`;
- map-first sect management;
- structural UX reference may be learned from `Ta Làm Tông Sư Trong Tiên Môn`, but do not copy proprietary art/text/icons/map;
- original xianxia visual direction: green-gray/wood/bronze, parchment, not glossy AI hero-art.

## CHARACTER CREATOR V1 — LOCKED RUNTIME-GREEN SCAFFOLD

Long-term architecture:

**modular appearance + shared 2D rig/animation**.

Map actor and portrait remain separate pipelines.

Map actor target:

- mature chibi;
- big head + compact body;
- cute but not childlike;
- clear silhouette;
- around 60–75 px perceived size at map zoom 1.0;
- profile portrait is separate higher-detail art.

Initial rig IDs:

- `female_normal_v1`;
- `male_normal_v1`.

Future only after proof:

- heavy rigs;
- special body types.

Canonical source registration:

- canvas `128×128`;
- foot anchor `(64,104)`;
- display scale `0.68` at map zoom 1.0;
- actor scaffold box `88×92`.

Canonical bones:

`root, pelvis, torso, head, arm_l, arm_r, hand_weapon, leg_l, leg_r`.

Canonical render layers:

`shadow -> aura -> hair_back -> weapon_back -> body -> outfit -> face -> hair_front -> head_accessory -> weapon_front -> accessory`.

One rig uses one `AnimationPlayer`/shared `AnimationLibrary` driving `Bone2D` transforms. Public directions remain `down/right/up/left`. V1 may mirror right motion for left when mirror-safe.

Real Godot gate proved:

- exactly the shared coarse rig contract;
- deterministic appearance normalization;
- safe invalid-profile fallback;
- action-to-clip mapping;
- direction + mirror mapping;
- presentation actor remains read-only against `DiscipleState`;
- `Skeleton2D + Bone2D + one AnimationPlayer` exists;
- no timeline-per-layer `AnimatedSprite2D` regression.

Current scaffold files:

- `docs/P3_2_MODULAR_ACTOR_SPEC.md`;
- `docs/P3_2_ASSET_MANIFEST.md`;
- `docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`;
- `godot/src/presentation/p3/disciple_actor_visual_catalog.gd`;
- `godot/src/presentation/p3/modular_disciple_actor.gd`;
- `godot/tests/presentation/p3_2_modular_actor_contract_test.gd`;
- `tools/godot/Verify-P3-2-Character-Creator.ps1`;
- `Verify-P3-2-Character-Creator.cmd`.

`Verify-P3-2-Character-Creator.cmd` is the authoritative Character Creator regression launcher. It reruns the existing cumulative P3.2 gate first, then the shared-rig contract test.

Important: `ModularDiscipleActor` is still intentionally isolated and not yet integrated into the live sect map.

Appearance persistence is still intentionally not wired into `DiscipleState`/generator. Add only after the production visual proof, with a backward-compatible contract and no RNG-stream change.

## female_normal_v1 reference + production contract — NEW LOCK

User supplied two female reference images on 2026-10-03:

- a multi-view turnaround-style image used for front/side/back continuity, hair length, horns, dress silhouette and back view;
- a front-view mature-chibi image used for preferred face/head/body proportion and tasteful feminine styling.

Do not generate a random new style instead of these references.

Detailed production authority:

`docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`

Locked asset rules:

- `down` = authored front;
- `right` = authored right-facing side;
- `up` = authored back;
- `left` = mirror from `right` while mirror-safe;
- runtime cutouts are full-canvas `128×128` RGBA PNG;
- foot anchor remains `(64,104)`;
- no auto-crop/recenter per piece;
- no chroma green in runtime PNG;
- file pattern `<variant>_<direction>_<piece>.png`;
- tint mask pattern `<variant>_<direction>_<piece>_tint_mask.png`;
- anatomical `l/r` always means the character's own left/right;
- 3/4 views are design references only, not runtime directions;
- artist should build layered master views and batch-export pieces rather than redraw every runtime PNG separately.

Piece contracts are now locked for:

- `body_01`: `head/torso/arm_l/arm_r/leg_l/leg_r`;
- `face_01..02`: `main`, front + side; hidden on back;
- `hair_01..03`: `back/front`;
- `outfit_01..02`: `torso/arm_l/arm_r/leg_l/leg_r/drape_back/drape_front`;
- `horn_01`: `main` head accessory;
- `weapon_01..02`: `main` or explicit split back/front only when required.

The existing scaffold rest positions are only starting pivots. Do not overwrite bone IDs/hierarchy or `(64,104)` registration. Exact practical pivots are tuned only after the real Stage A baseline art is attached.

## NEXT ACTIVE WORK — Stage A pivot-lock sample

Do not mass-produce variants yet.

Build one baseline appearance only:

- `body_01`;
- `face_01`;
- `hair_01`;
- `outfit_01`;
- `horn_01`;
- authored views `down/right/up`.

Then export with the locked naming/registration contract, attach to `ModularDiscipleActor`, inspect alignment, and lock practical pivots from the real art.

After Stage A:

1. shared idle/walk motion proof;
2. then add face/hair/outfit/weapon variants + tint masks;
3. then six-combination sandbox;
4. then real visual-slice Godot gate;
5. only then live-map integration and appearance persistence.

Do not call the production visual slice PASS until real art/animation is visible and its real Godot gate is green.
