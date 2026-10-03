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
6. related P3 specs;
7. then inspect live code/tests before editing.

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
- `godot/src/presentation/p3/disciple_actor_visual_catalog.gd`;
- `godot/src/presentation/p3/modular_disciple_actor.gd`;
- `godot/tests/presentation/p3_2_modular_actor_contract_test.gd`;
- `tools/godot/Verify-P3-2-Character-Creator.ps1`;
- `Verify-P3-2-Character-Creator.cmd`.

`Verify-P3-2-Character-Creator.cmd` is now the authoritative Character Creator regression launcher. It reruns the existing cumulative P3.2 gate first, then the shared-rig contract test.

Important: `ModularDiscipleActor` is still intentionally isolated and not yet integrated into the live sect map.

Appearance persistence is still intentionally not wired into `DiscipleState`/generator. Add only after the production visual proof, with a backward-compatible contract and no RNG-stream change.

## NEXT ACTIVE WORK — female_normal_v1 production proof

Do not mass-produce art yet.

First proof must use `female_normal_v1` only:

- 1 body;
- 2 faces;
- 3 hairs;
- 2 outfits;
- 2 weapons;
- 1 horn/head accessory;
- several hair/outfit tint presets;
- shared idle + walk, public 4 directions;
- at least 6 visual combinations sharing one rig/AnimationLibrary.

Acceptance checks:

- common foot registration;
- no face/hair drift;
- outfit limbs align to bones;
- weapon front/back works by direction;
- tint masks do not affect skin/face/metal unintentionally;
- mirror behavior does not break z-order/handedness;
- all combinations share the same motion library;
- readable at zoom 0.75 / 1.0 / 1.35.

## Next development order

1. create or approve **one real `female_normal_v1` art sample** on the locked `128×128` canvas;
2. lock exact practical rig pivots from that real art sample;
3. author the shared idle + walk `AnimationLibrary`;
4. build first coarse cutout body/outfit bundle + face/hair/weapon/horn;
5. create tint-mask shader/presets;
6. create sandbox proving 6 combinations on the same rig;
7. run a real Godot visual-slice gate;
8. only then integrate `ModularDiscipleActor` into the live map;
9. add backward-compatible `appearance_profile` persistence;
10. then expand to `male_normal_v1`, more actions and larger art volume.

Do not call the production visual slice PASS until the real art/animation proof is visible and its real Godot gate is green.
