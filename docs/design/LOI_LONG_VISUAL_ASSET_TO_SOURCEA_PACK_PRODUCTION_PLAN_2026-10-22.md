# TÔNG MÔN BÁ ĐẠO — LÔI LONG ORIGINAL CHARACTER ART → GODOT / SOURCE-A-LIKE PACK

**Date:** 2026-10-22 · **Artifact status:** **VISUAL POSE PREVIEW / STATIC QA PASS; GODOT RUNTIME NOT RUN; NOT A SPINE RIG**.  
**Scope:** only design and independent downloadable proof-of-concept asset archive, no game runtime or Source A worker changes. **Do not merge**.  
**Original art:** original "Lôi Long" character illustration made during conversation; a second transparent generated sheet enabled pose extraction. The transparent sheet is a **newly generated derivative** rather than a pixel-preserving alpha cut from the first sheet.

## 1. Created working prototype pack (outside GitHub)

Generated archive in conversation: `TMB_LOI_LONG_ASSET_PREVIEW_V1.zip`, SHA-256 `67dd5dbf3a5f6118881a8502d20cceac9e4b34afb9aecc29d6b61bcf9db84662`; **not uploaded to repository** and must not be assumed available in E: unless owner copies it. Contained standalone Godot project: `project.godot`, `preview.tscn`, `preview.gd`; visual actor `actor.tscn`, `animations.tres`, atlas `atlas_000.webp`/`atlas_001.webp`, 8 RGBA PNG pose frames, `asset.json`, reproducible build/verify scripts, 128×128 single stand preview, design sheets and SHA256SUMS. Static QA 8/8 atlas regions **pixel-identical to PNG**, stable registered canvas 768×768 with foot anchor (384,540), 2 atlas pages, CRC PASS; **no Godot 4.7.2 executable was available to runtime-test**.

Preview clips: stand (1 still pose), walk (2 key poses), attack1 (2 key poses), cast_dragon (1), hit (1), dead (1). These are **NOT source-authored temporal Spine clips / not combat-ready animation**. Do not fake 30 FPS by duplicating images; actual Spine samples show stand/walk ~48 distinct frames and explicit loop/timing.

## 2. Source verified and adopted patterns

- Read `main/docs/P3_2_MODULAR_ACTOR_SPEC.md`, `P3_2_ASSET_MANIFEST.md`, `P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`, `AGENTS.md`. **Canonical modular character:** shared Skeleton2D + 9 Bone2D hierarchy, one shared AnimationPlayer, separate body/face/hair/outfit/horn/weapon/aura/shadow; real P3 map actor canvas 128×128/foot (64,104) and directions down/right/up/left (left mirrored only mirror-safe).
- Inspected existing Source A converter output from previously user-uploaded QA archive. It uses `asset.json`, source file SHA, converter fingerprint, canvas+foot, cropped sprite frames, atlas WebP, `animations.tres` and `actor.tscn`. **Do not re-use its converter v7 SHA/fingerprint** for a generated pose-only pack: it has no source Spine `.skel/.atlas` or skin timeline.
- Godot 4 `AnimatedSprite2D` consumes `SpriteFrames`; multiple `AtlasTexture` regions can refer to lossless WebP pages; references: [Godot source documentation](https://github.com/godotengine/godot/blob/master/doc/classes/SpriteFrames.xml) and [2D sprite animation source](https://github.com/godotengine/godot-docs/blob/master/tutorials/2d/2d_sprite_animation.rst).
- Optional external [Sprite Atlas Importer](https://godotengine.org/asset-library/asset/5487) supports data-driven atlas formats, **not installed/verified in this repo and unnecessary for native SpriteFrames .tres prototype**.

## 3. Production choice: HYBRID 2D RIG + REAL VFX, not one concept sheet per character

**Recommended for sect management / large roster**: shared Godot 2D rig for base disciple variants, separate Source A-derived or newly authored animation/VFX for unique combat actions. All equipment remains sect-owned gameplay; weapon appearance only displays assigned equipment and does not create stats.

| Layer | Production file(s) | Required QA |
|---|---|---|
| Base | body, face, hair back/front (coarse pieces) | matched anatomy/scale across down/right/up, 9 bone pivots |
| Outfit | torso/arm_l/arm_r/leg_l/leg_r + drape front/back | aligned sockets, left mirror-safe only if verified, no fake modular composite |
| Weapon | separate spear socket + front/back pass | hand attachment doesn't slide over actual animation |
| Aura | separate blue lightning halo animation | VFX layer never commits Combat V2 damage |
| Skill VFX | dragon-shaped light bolts as independent effect sprite sequences | cast/impact from **real Combat V2 domain events**, not animation timers |
| Motion | shared idle/walk 4 directional; attack/hit/dead/cast authored | 30 FPS concept target **only if actual in-betweens/source frames exist**, actual loop/cast/end markers |
| Map | fixed 128×128 alpha foot (64,104), read 60–75 logical px | 1280×720 zoom/readability, multiple actors/HP labels |
| Hi-res combat | consistent 768 canvas foot (384,540) if full-body composed art | no frame cropping, no foot/pivot jitter at runtime |
| Portrait | separate genuinely authored high-res image | do not upscale small map actor |

**One image cannot reliably regenerate Spine SkeletonData, bones, weights, skins, animation keys or 4 angles.** To achieve Source A class, must author layered source (PSD/ORA/art project) and a genuine rig/animator pipeline (e.g. Godot Skeleton2D/AnimationPlayer or licensed Spine editor) with repeatable exports, review and QA.

### Production acceptance sequence

1. **LOCK ART**: front/right/back master, orthographic/isometric feet consistent, distinctive Lôi Long spear/armor/hair, clean silhouette, no watermarks/text, palette stable across views.
2. **LAYER AUTHORING**: deliver high-res cutouts with shared registration, explicit 9 bone pivots, clean alpha including behind weapon; no AI guessing invisible limbs as verified source.
3. **RIG**: 4 directional identity; actual 30-fps-or-other-authored-timeline animation for idle/walk/attack/cast/hit/dead; record real foot motion, original frames, not repeated static poses; test left mirror if legal.
4. **VFX**: separate Lôi Long dragon/sparks/projectile/impact sequences, with event schema and presentation-only animation. Gameplay `lightning` element, skill ID, faction and Combat V2 modifiers remain **UNASSIGNED** until authored; visuals cannot grant buffs by association.
5. **PACK**: `rig.tscn`+shared `AnimationLibrary` for modular or verified baked `animations.tres`+atlas for authored motion, `asset.json`, source+converter fingerprint+SHA, persistent `asset_pack_id`, pivot/direction metadata; **do not counterfeit Source A provenance**.
6. **QA**: static image/alpha SHA, import Godot official 4.7.2, actual timeline/playback, visual in 1280×720, real Android performance, user visual acceptance; no implicit PASS on first prototype.
7. **CONSUME**: Character Studio and V5 can import a reviewed pack via **manifest bridge** only with separate integration owner/approved allowlist. Source A converter remains single writer, separate from this original art pipeline.

## 4. Next scoped Codex packet for standalone ART V2 (not automatically authorized)

> TÔNG MÔN BÁ ĐẠO — LOI LONG ORIGINAL ART V2 / SHARED RIG & TRUE MOTION, STANDALONE.
> 
> First read repo `AGENTS.md`, `docs/P3_2_MODULAR_ACTOR_SPEC.md`, `docs/P3_2_ASSET_MANIFEST.md`, and this document. Owner provides downloaded `TMB_LOI_LONG_ASSET_PREVIEW_V1.zip`. Work **only in an isolated E: proof directory**, never edit `main` game/Combat V2/Character Studio/Source A converter/Map/V5. Verify ZIP SHA-256 and static manifest. Do not call 8 still poses “48-frame Spine animation”.
> 
> Author a genuinely editable layered Lôi Long male visual using 9-bone 2D skeleton, shared idle/walk (down/right/up; left only mirror-safe), separate weapon, aura and dragon VFX; each component has consistent pivots and foot. If original layered art does not exist, create an **art authoring requirements and missing-source list** and implement only what can be verified, not fake bones/weights/animations. Keep gameplay skill/element IDs unassigned. For a first proof choose `stand_down` + `walk_down` with actual repeated poses or authored in-betweens and verify 128×128 map render before building all skill effects. Then expand only after owner visual acceptance.
> 
> Pack as Godot4.7.2 isolated project with manifest, source hashes, atlas, animation library, before/after capture at 1280×720, focused QA and one ZIP. Provide report with source-vs-authored proofs and missing directions/frames/cutouts. Never merge/push, never run heavy Godot while Source A converter runs on 8GB Windows.

**No owner-CODE auth, no Godot runtime tests or Source A changes occurred from this design note.**
