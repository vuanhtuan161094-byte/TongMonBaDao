# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-03

Always fetch/inspect live `main` before editing.

## Working style / user preference

- Code directly through the GitHub connector.
- Do not use Codex or Work.
- Do not ask the user to repeat anything already in repo/spec/handoff.
- User is non-technical; after a meaningful phase explain clearly: (1) người chơi sẽ thấy gì, (2) hệ thống phía sau làm gì.
- Never claim a runtime phase PASS without real Godot 4.7.2 output from the user's Windows machine.
- Never use destructive local git instructions (`reset --hard`, `git clean`, deleting user files, etc.).

Repo: `vuanhtuan161094-byte/TongMonBaDao`
Branch: `main`
Local: `E:\0.2. TongMonBaDao`
Godot: 4.7.2 stable console.

Last implementation commit before this handoff rewrite was `af249fd44245dc7934a3c77f2a3274f40278eb32` (`Add Character Creator V1 verify launcher`). Re-fetch live HEAD before doing anything.

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 cumulative evidence confirms **P0 through P2.12 PASS**.

Do not reopen P0-P2.12 without new regression evidence.

P3 status remains:

- P3.1: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**;
- P3.2 camera + map selection + real disciple tabs: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**;
- Character Creator V1 scaffold: **IMPLEMENTED STATIC SCAFFOLD / NOT YET RUN ON REAL GODOT**.

No P3 slice may be called PASS from static GitHub review alone.

## Character authority

Before character work read in order:

1. `AGENTS.md`;
2. `CURRENT_CHECKPOINT.md`;
3. `NEXT_CHAT_HANDOFF.md`;
4. `docs/DISCIPLE_MASTER_SCHEMA.md`;
5. `docs/P3_2_MODULAR_ACTOR_SPEC.md`;
6. related P3 specs.

Locked character principles still apply:

- one disciple is one canonical `DiscipleState` identity;
- hidden identity is generated once and persisted;
- reveal/awakening/transformation never rerolls hidden identity;
- UI/presentation may read gameplay state but may not invent a parallel gameplay state;
- `sex_id` is canonical identity for an existing disciple and must not be silently changed by cosmetic UI.

## Product presentation canon

- Mobile landscape, base logical resolution **1280×720**.
- Map-first sect-management UI.
- Structural UX reference may be learned from `Ta Làm Tông Sư Trong Tiên Môn`, but do not copy proprietary art/text/icons/map/pixels.
- Original visual direction: xianxia management world, green-gray/wood/bronze, not glossy AI hero-art.

## P3.1 / P3.2 interaction state

Main P3.2 scene:

`res://scenes/p3/p3_2_landscape_sect.tscn`

Current implemented interaction includes:

- only map layer zooms/pans;
- pinch/wheel zoom and drag pan;
- target focus and gold marker;
- direct building/disciple selection;
- tabs: Thuộc tính / Công pháp / Trang bị / Huyết Mạch / Thể Chất / Quan hệ;
- real Bloodline/Physique actions consume real resources;
- no parallel UI gameplay state.

Existing cumulative launcher is still authoritative for the pending P3.2 runtime gate:

`Sync-P3-2-Camera.cmd`

## CHARACTER CREATOR V1 — newest canonical direction

Old approach is retired:

- do NOT produce one complete spritesheet/video animation set per disciple;
- do NOT continue the old six complete visual families (`male/female sword/spell/body`) as production architecture;
- do NOT split Grok output into arbitrary face/hair/body pieces before the rig contract is proven.

New long-term architecture:

**modular character + shared 2D rig/animation**.

Map actor and portrait are separate pipelines:

- map actor: mature chibi, big head/compact body, clear silhouette, around 60–75 px at map zoom 1.0;
- portrait/profile: separate higher-detail artwork, can be more attractive/tastefully sexy where appropriate.

Initial rig IDs:

- `female_normal_v1`;
- `male_normal_v1`.

Future only after proof:

- `female_heavy_v1`;
- `male_heavy_v1`;
- special body types.

## Character Creator V1 locked rig contract

Canonical source registration:

- canvas `128×128`;
- foot anchor `(64,104)`;
- display scale `0.68` at map zoom 1.0;
- actor scaffold box `88×92`;
- body silhouette target roughly `64–70` logical px.

Canonical bones:

`root, pelvis, torso, head, arm_l, arm_r, hand_weapon, leg_l, leg_r`.

Bones are internal rig mechanics, not player-visible customization slots.

Canonical render layers back-to-front:

`shadow -> aura -> hair_back -> weapon_back -> body -> outfit -> face -> hair_front -> head_accessory -> weapon_front -> accessory`.

Player-facing choices:

- body type / gender at the appropriate identity-creation flow;
- face;
- hair;
- hair tint;
- outfit;
- outfit tint;
- horn/head accessory;
- weapon visual;
- accessory;
- aura.

Body/Outfit remain one creator choice each, but production may internally export a coarse bundle for head/torso/arms/legs. Do not fragment into eyes/fingers/shoes as separate creator options.

## Godot architecture now scaffolded

Current files:

- `docs/P3_2_MODULAR_ACTOR_SPEC.md` — canonical new Character Creator/shared-rig contract;
- `docs/P3_2_ASSET_MANIFEST.md` — old six-complete-actor production plan removed;
- `godot/src/presentation/p3/disciple_actor_visual_catalog.gd` — rig IDs, canvas/anchor, bones, layers, direction/mirror rules, deterministic default appearance normalizer;
- `godot/src/presentation/p3/modular_disciple_actor.gd` — `Skeleton2D + Bone2D + one AnimationPlayer` scaffold;
- `godot/tests/presentation/p3_2_modular_actor_contract_test.gd` — new shared-rig contract test;
- `tools/godot/Verify-P3-2-Character-Creator.ps1`;
- `Verify-P3-2-Character-Creator.cmd`.

Important: the existing map scene still uses its prior placeholder actor path. The new modular rig is **not yet integrated into the main P3.2 scene**. This is deliberate so the pending P3.2 camera/UI gate is not destabilized before real Windows evidence.

The old modular scaffold used multiple `AnimatedSprite2D` layers with synchronized `SpriteFrames`. That architecture has been replaced in the isolated scaffold. New shared motion must animate Bone2D transforms through one `AnimationPlayer`/`AnimationLibrary`.

## Direction/mirror rule

Public directions always remain:

`down / right / up / left`.

V1 is allowed to reuse right motion for left via horizontal mirror when a variant is mirror-safe. Public facing remains `left`; only presentation playback resolves to right + mirror. Asymmetric art may opt into authored-left later.

## Appearance state contract

The target persistence payload is documented in `P3_2_MODULAR_ACTOR_SPEC.md` as `appearance_profile` with fields such as:

- rig/body/face/hair/outfit/head accessory/weapon/accessory/aura IDs;
- hair tint and outfit tint as RGB hex;
- schema version.

Rules:

- appearance is presentation identity, never gameplay stat authority;
- defaults can be derived deterministically from `profile_seed + sex_id`;
- invalid/missing optional assets fall back safely;
- existing disciple `sex_id` cannot be overridden by cosmetic appearance normalization;
- real equipment visual must eventually win over a fake cosmetic weapon when gameplay equipment mapping is available.

**Persistence has deliberately NOT been wired into locked `DiscipleState`/generator yet.** First run the existing P3.2 gate and the isolated Character Creator contract in real Godot. Then add a backward-compatible persistence contract without consuming/changing the P2.8 RNG stream.

## Tint rule

Hair/outfit production art should use base texture + tint mask/shader. Do not globally `modulate` a multicolor sprite and accidentally tint skin/metal/face.

## Weapon render rule

One weapon ID may render as:

- back;
- front;
- split back/front.

It attaches to `hand_weapon`. Direction changes render pass/socket presentation only; it does not mutate gameplay equipment.

## Character Creator vertical slice target

Do not mass-produce art yet.

First proof is **female_normal_v1 only**:

- 1 body;
- 2 face;
- 3 hair;
- 2 outfit;
- 2 weapon;
- 1 horn/head accessory;
- several hair/outfit tints;
- shared idle + walk with public 4 directions;
- at least 6 visual combinations on one shared rig.

Acceptance proof checks foot registration, hair/face alignment, outfit limb alignment, weapon back/front, tint masks, mirror behavior, shared AnimationLibrary usage and readability at map zoom 0.75/1.0/1.35.

Only after this proof should `male_normal_v1` and additional actions be produced.

## Next authoritative Windows order

When the Windows machine is available, **do this first**:

```bat
cd /d "E:\0.2. TongMonBaDao"
Sync-P3-2-Camera.cmd
```

Do not skip directly to Character Creator verification.

If the existing P3.2 cumulative camera/UI gate becomes green, then run:

```bat
Verify-P3-2-Character-Creator.cmd
```

The Character Creator verifier intentionally reruns the existing P3.2 cumulative verifier first, then runs:

`res://tests/presentation/p3_2_modular_actor_contract_test.gd`

Do not call either gate PASS until the real Windows output says so.

If there is a failure, fix the first real parser/diagnostic/assertion failure only. Do not weaken locked tests.

## Next GitHub-side development after runtime green

1. fix any real parser/runtime issue from the two gates;
2. lock `female_normal_v1` actual bone pivots from a real art sample;
3. create the shared `AnimationLibrary` with idle + walk;
4. create the first production cutout bundle and tint mask shader;
5. create a Character Creator sandbox/proof with 6 combinations;
6. only then integrate `ModularDiscipleActor` into the live sect map;
7. add backward-compatible `appearance_profile` persistence contract without changing existing gameplay RNG/state authority;
8. only then expand art volume.
