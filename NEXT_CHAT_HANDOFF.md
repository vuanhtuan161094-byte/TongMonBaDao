# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-03

Always fetch/inspect live `main` before editing.

## Working style / user preference

- Code directly through the GitHub connector.
- Do not use Codex or Work.
- Do not ask the user to repeat anything already in repo/spec/handoff.
- User is non-technical; explain meaningful progress clearly in Vietnamese.
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
6. related P3 specs;
7. then inspect live code/tests before editing.

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 now confirms:

- P0-P2.12: PASS;
- P3.1 landscape shell: PASS;
- P3.2 camera + map target selection + real disciple tabs interaction slice: PASS.

Authoritative user output on 2026-10-03 ended with:

```text
P3.1 LANDSCAPE SECT SHELL TEST PASS
P3.1 LANDSCAPE SECT SHELL GATE: PASS
P3.2 MAP CAMERA TEST PASS
P3.2 DISCIPLE UI INTEGRATION TEST PASS
P3.2 CAMERA + DISCIPLE UI GATE: PASS
P3.2 INTERACTION GATE: PASS
```

The parser fix immediately before this green run was commit:

`d5ee8e8148642738cfc9c03a7797ba67e829e80b` — `Fix P3.2 tab active type inference on Godot 4.7.2`.

Do not reopen P0-P3.2 interaction contracts without new regression evidence.

Important distinction: **P3.2 interaction is green, but full P3.2 production art is not complete.** Do not call the whole art/production phase done.

`Sync-P3-2-Camera.cmd` remains the cumulative regression launcher for the locked interaction baseline.

## Character authority

Locked principles still apply:

- one disciple is one canonical `DiscipleState` identity;
- hidden identity is generated once and persisted;
- reveal/awakening/transformation never rerolls hidden identity;
- UI/presentation may read gameplay state but may not invent parallel gameplay state;
- `sex_id` is canonical identity for an existing disciple and must not be silently changed by cosmetic UI;
- appearance must not consume/reorder existing P2.8 RNG.

## Product presentation canon

- mobile landscape, base logical resolution `1280×720`;
- map-first sect management;
- structural UX reference may be learned from `Ta Làm Tông Sư Trong Tiên Môn`, but do not copy proprietary art/text/icons/map;
- original xianxia visual direction: green-gray/wood/bronze, parchment, not glossy AI hero-art.

## CHARACTER CREATOR V1 — current active task

Long-term architecture:

**modular appearance + shared 2D rig/animation**.

Map actor and portrait are separate pipelines.

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

Current scaffold files:

- `docs/P3_2_MODULAR_ACTOR_SPEC.md`;
- `docs/P3_2_ASSET_MANIFEST.md`;
- `godot/src/presentation/p3/disciple_actor_visual_catalog.gd`;
- `godot/src/presentation/p3/modular_disciple_actor.gd`;
- `godot/tests/presentation/p3_2_modular_actor_contract_test.gd`;
- `tools/godot/Verify-P3-2-Character-Creator.ps1`;
- `Verify-P3-2-Character-Creator.cmd`.

Important: `ModularDiscipleActor` is still intentionally isolated and not yet integrated into the live sect map.

Appearance persistence is still intentionally not wired into `DiscipleState`/generator. Add only after Character Creator runtime green, with a backward-compatible contract and no RNG stream change.

## Character Creator vertical slice target

First proof is `female_normal_v1` only:

- 1 body;
- 2 faces;
- 3 hairs;
- 2 outfits;
- 2 weapons;
- 1 horn/head accessory;
- several hair/outfit tint presets;
- shared idle + walk, public 4 directions;
- at least 6 visual combinations sharing one rig/AnimationLibrary.

Acceptance checks: common foot registration, hair/face alignment, outfit limb alignment, weapon front/back, tint masks, mirror behavior, shared animation usage and readability at zoom 0.75/1.0/1.35.

Do not mass-produce art before this proof.

## NEXT ACTION — do this now on Windows

Because `Sync-P3-2-Camera.cmd` is now green, the next authoritative command is:

```bat
cd /d "E:\0.2. TongMonBaDao"
Verify-P3-2-Character-Creator.cmd
```

This verifier reruns the cumulative P3.2 regression chain first, then runs:

`res://tests/presentation/p3_2_modular_actor_contract_test.gd`

Do not call Character Creator PASS until the real output says so.

If it fails, fix the **first parser/diagnostic/assertion failure only**. Never weaken the test to obtain green.

## After Character Creator runtime green

1. lock exact `female_normal_v1` bone pivots using one real art sample;
2. author shared idle + walk `AnimationLibrary`;
3. create first coarse cutout body/outfit bundle + face/hair/weapon/horn;
4. create tint-mask shader/presets;
5. create sandbox proving 6 combinations on the same rig;
6. only then integrate `ModularDiscipleActor` into the live map;
7. add backward-compatible `appearance_profile` persistence;
8. then expand to `male_normal_v1` and larger art volume.
