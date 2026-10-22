# TÔNG MÔN BÁ ĐẠO — LÔI LONG / AI VIDEO → 2D SPRITE ASSET STUDIO

**2026-10-22 — DESIGN PROPOSAL / NO CODE / NO MERGE / NO SOURCE A WORKSPACE CHANGES.**

## 0. Decision and source authority

**Owner direction:** It is acceptable and likely preferable to produce original Lôi Long game visuals from reference character images → Grok image/video generation → high-quality selected frames → sprite atlases. **Godot runtime need not use bones or Spine**. This is **not** permission to overwrite prior P3.2 shared Skeleton2D contract for established rigs; the no-bones **new original-art source pipeline** is a proposal/visual pilot until separately accepted.

**Known sources:**
- Existing original art prototype `TMB_LOI_LONG_ASSET_PREVIEW_V1.zip`: 8 pose cutouts, 2 lossless WebP atlases, `actor.tscn`/`animations.tres` static PASS, **Godot official runtime not run**, no genuine authored action timeline.
- Main repo `docs/P3_2_MODULAR_ACTOR_SPEC.md` proposes 128×128 full frame, foot=(64,104), 4 directional interface down/right/up/left and approximately 60–75 px map-actor silhouette; V5 uses Source A baked frames via `asset.json`, `actor.tscn`, `animations.tres`, WebP atlas. Retain registration principles, not the requirement to create Skeleton2D for new assets.
- [Official xAI Grok Imagine video documentation](https://docs.x.ai/developers/model-capabilities/video/overview) and [Image-to-Video](https://docs.x.ai/developers/model-capabilities/video/image-to-video): generated video, pinned first/last/keyframes available on API-supported models (availability in user's Grok consumer UI must be verified).
- [Godot 4.7 SpriteFrames](https://docs.godotengine.org/en/4.7/classes/class_spriteframes.html), [Godot 4.7 image import](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_images.html); [Aseprite CLI](https://aseprite.com/docs/cli/) supports batch frame/sheet exports. No live tool/plugin is required by the design.

**DO NOT confuse** AI-generated video frames with a recovered Spine rig, Source A skel source, or combat skill definition. New original assets need their own provenance `source_kind=ai_video_original` and media hashes; no borrowing the Source A converter fingerprint.

## 1. Recommended: baked 2D frame animation, without runtime skeleton

```
LOCKED ORIGINAL CHARACTER DESIGN
  ├─ character style bible / front, right, back reference (same outfit/weapon/height)
  ├─ one motion × one direction × one clean video generation
  │   ├─ idle_down, idle_right, idle_up (mirrored left only after visual check)
  │   ├─ walk_down, walk_right, walk_up
  │   ├─ attack1_*, cast_*, hit_*, dead_* (expand only after proof)
  │   └─ separate lightning dragon skill VFX video(s), without actor in frame
  ├─ MP4 frame decode (FFmpeg streaming) → candidate frames
  ├─ alpha matte, manual cleanup, consistency check
  ├─ foot registration + fixed alpha canvas per direction/action
  ├─ curated authored-time frames + duration, loop flags & event markers
  ├─ atlas PNG/WebP lossless + manifest checksums
  ├─ Godot AnimatedSprite2D/SpriteFrames/AtlasTexture scene
  └─ focused Godot4.7.2 / Android1280×720 visual & performance acceptance
```

**Video is a motion proposal, not guaranteed final frames.** AI can change face/horns, weapon length/hand, clothes and position; stage gates reject bad temporal geometry. If no clean alpha source, isolate against one fixed simple background and inspect transparency edges. Avoid automatically claiming native alpha support for MP4.

**Four-directional issue:** one front still cannot reliably define unseen back/side details. Lock original **three master directions** as independent consistent art; then video for each. Left = mirror of right only if asymmetric armor/spear/chest ornament passes mirror-safe. Gameplay direction remains down/right/up/left even if some motions intentionally use fallback visual pending proof.

## 2. Art direction for Lôi Long (one character, one first proof)

Visual identity: silver hair in long tied high ponytail, small stylized golden dragon crown, white/navy coat with restrained gold trim, long lightning spear, cool electric-blue aura. Distinct facial proportions and ornament positions **must persist across every frame**. Background clean and immobile; camera completely locked, 2D full-body isometric-ish game sprite framing; avoid cinematic camera shake/zoom; shadows/VFX separate. Even if key art is detailed, gameplay must remain legible at 60–75 logical px.

**FIRST proof:** `idle_down` loop + `walk_down` loop, consistent 128×128 rendered output and foot=(64,104). Target **6–12 truly distinct curated frames** per walk clip as a starting study, fps 8–12 after visual tuning; do not manufacture frame count by duplicating stills. Preview on 1280×720 6-actor cluster before many variants. Real asset frame count is an acceptance result, NOT an AI generation promise. Keep hi-res image/video masters outside exported Godot pack for future regeneration.

**SECOND proof:** `attack1_down`, `hit_down`, `dead_down` and distinct VFX `vfx_loi_long_summon`, using authored frame events for presentation while combat damage/cast/cooldown remain Combat V2 authority.

## 3. Professional Asset Studio architecture without mandatory bones

Prefer a lightweight **external Windows desktop Asset Studio** (Python/PySide6 optional) orchestrating the existing open-source tools, plus a small optional **Godot preview project**. The UI manages:
- **Projects & Character Bible:** stable ID, reference images, image/video prompt history, palette, angle masters and masks.
- **Video Jobs:** one job/clip at a time, approved Grok outputs imported as MP4; model request IDs optional when using API, downloaded clip immutable SHA.
- **Frame Inspector:** time scrub, reject/accept/delete/reorder, side-by-side silhouette, anchor preview, actual per-frame durations, looping preview, visual flaw flags. Operator—not algorithm—signs consistency.
- **Matte & Registration:** remove fixed backdrop, decontaminate edge, maintain uniform canvas, anchor foot; do not crop each frame to own bbox then center independently.
- **Timeline & VFX:** separate actor and aura/dragon/projectile/impact frame sequences; casts driven by real Combat V2 events; optional per-frame weapon socket metadata.
- **Atlas & Export:** pack immutable approved RGBA frames to lossless WebP/PNG atlas, deterministic frame rect IDs, `SpriteFrames.tres`, `actor.tscn`, `asset.json`, `SHA256SUMS`, original source hash/version.
- **QA & Library:** inspect source hash, decode completeness, alpha, canvas, foot drift, weapon changing shape, malformed/blank/duplicate frames, loop start/end pop, actual Godot import/playback and phone preview. State `DRAFT` → `FRAMES_CURATED` → `STATIC_QA_PASS` → `GODOT_QA_PASS` → `OWNER_VISUAL_PASS`; never silently skip gate.

**Shared Source A catalog boundary:** Asset Studio registers **new original-art packs** via an append/ingestion queue to the one library/catalog owner; do not have two simultaneous writers opening the Source A SQLite DB. Original media should live in its own logical input area on E:; exact directory chosen by current workspace owner. Do not reuse Source A `.skel`, `.atlas`, parser fingerprint fields for AI art.

**Memory efficiency:** 128×128 RGBA uncompressed ≈64 KiB per frame; 144 distinct frames ≈9 MiB before imported texture compression, mipmap or overhead. Thousands of fully unique actors can overrun Android budgets quickly. Reuse normal-body animation looks or limited baked outfit variants, prioritize on-demand pack loading, share atlas pages per visual family and inspect actual RAM/VRAM. Optional weapon overlay aligned by per-frame sockets avoids redrawing every costume; without runtime skeleton it still needs verified weapon positions for each frame/direction. Gear stats from canonical Sect equipment are independent of visual appearance.

## 4. Grok motion prompts — reusable templates

**Character reference contract (prepend to each isolated generation):**

> Use the supplied Lôi Long original character design as a strict visual reference. Preserve the identical face, silver ponytail, golden dragon coronet, white/navy/gold robe, armor pattern and gold-blue lightning spear in every frame. 2D hand-painted Chinese xianxia action-RPG sprite art matching the original reference, slightly stylized readable silhouette. Character fully visible head to feet with ample margins, constant figure scale and fixed ground position. LOCKED ORTHOGRAPHIC/ISOMETRIC GAME CAMERA; no panning, zooming, rotations, scene cuts, lighting changes, motion blur, text, symbols or second characters. Plain solid uniform background for post-processing. Move ONLY the character to perform this one action. No morphing anatomy, accessories or spear, no extra limbs or changing crown.

**Pilot A — walk loop, front/down:**

> The Lôi Long warrior performs a gentle in-place walk cycle facing down/front. Legs alternate with clear weight transfer, arms and spear sway naturally while the foot pivot stays on a fixed ground baseline. Ponytail and fabric have restrained secondary motion. Keep start/end poses compatible for a seamless loop. No teleporting, flying, combat or lightning VFX. One clean approximately 2–3 second motion study. Preserve exact design and camera. The feet should not drift laterally.

**Pilot B — attack 1, front/down:**

> The exact same Lôi Long warrior performs one short, readable spear slash and recovers to the same starting stance. Distinct anticipation → contact → follow-through → settle phases. Fixed weapon length and grip, no dragon appearing yet. Controlled secondary cloth/hair motion; no camera moves. Leave a few stable frames at beginning/end for cleanup, make strike silhouette clear even at small size.

**Pilot C — dragon VFX only (separate pass):**

> On fixed solid background, an isolated blue-white Chinese electric-dragon energy effect appears, curls once, dashes forward and dissipates into short lightning sparks. NO character, NO spear, NO scenery, NO text, NO camera movement. Preserve one direction and stable effect center; key visual phases summon → travel → impact → dissipate. This is a visual-only effect to composite on top of actor at Combat V2-authorized cast/release moments.

When API mode supports pinned first and last frames, use same idle keyframe to guide loop; **pinned endpoints do not guarantee perfectly seamless intermediate motion**. Not all UI surfaces expose every API feature.

## 5. Accepted export conventions & validation

```text
asset_id: loi_long_male_original_v2
source_kind: ai_video_original
provenance:
  concept_sha256: exact
  video_sha256_by_clip: exact
  model_family/request_id: known_if_available
  prompt_version: preserved
  human_cleanup_revision: named
presentation:
  approach: baked_spriteframes_no_runtime_bones
  canvas_map: [128,128]
  foot_anchor_map: [64,104]
  animation_direction_ids: [down,right,up,left]
  clips:
    idle_down:
      frames: [...]           # actual distinct approved PNG source frame IDs
      duration_seconds: [...]
      loop: true
      verified: status
    walk_down: ...
    attack1_down: ...
  atlas_pages: [{file,sha256,width,height,rect_manifest_sha}]
  vfx_refs: [vfx_loi_long_summon]  # separate and optional
  optional_weapon_sockets_by_frame: [...]
qa:
  static_validation: pass|fail|not_run
  godot_4_7_2_runtime: pass|fail|not_run
  owner_visual: pending|pass|fail
```

No invented stats, skill ID, school, elemental damage, Tu Vi and loot from the name “Lôi Long.” Artistic theme alone is not a Combat V2 gameplay rule. 128×128 is existing P3 map-actor contract; if high-res V5 combat uses larger canvas/pivot, it must have a **separate** export profile with actual alignment QA, not blindly scale/crop map-actor export.

## 6. Gate plan & stop conditions

| Gate | Must be demonstrated | Stop condition |
|---|---|---|
| G0 art consistency | down/right/up master visual accepted; proper hands/weapon/hair | any changed face/outfit detail |
| G1 real walk/idle | actual differentiated movement frames, foot anchor fixed, controlled loop | still/duplicate frames or teleport feet |
| G2 Godot import | all SpriteFrames/AtlasTexture indices valid, render 1280×720 and map zooms | crash, out of bounds, wrong direction |
| G3 Combat action | attack1 motion and independent VFX sync to event, no gameplay timing edits | VFX animation grants damage or shifts cast |
| G4 scale/performance | 6-actor battle and loaded atlas footprint measured; on-demand packs | excessive memory, labels unreadable |
| G5 reuse | second outfit/weapon visual can be adapted with documented effort | requires redrawing all motions for every gear item against goals |

**Don't start bulk 30×10 roster variants before G1/G2.** Baked animations may be entirely sensible for monsters/Boss with fixed appearance, but a highly customizable disciple needs careful compromise: limited pre-baked costume families, palette shader and selected socket overlays. This is the primary trade-off against Spine.

## 7. Next safe Codex direction — stand-alone tool design, not code authorization

TÔNG MÔN BÁ ĐẠO — ORIGINAL AI VIDEO ASSET STUDIO / NO RUNTIME BONES / DESIGN-ONLY.

Read AGENTS.md, P3_2_MODULAR_ACTOR_SPEC.md, Source A QA output contracts and this design doc. Review original Lôi Long V1 ZIP proof. Propose a standalone E: workflow using Grok image-to-video inputs and FFmpeg to produce real frames, alpha-cleaning and foot registration, atlas WebP, Godot SpriteFrames/AnimatedSprite2D, manifest and QA. First proof is only idle_down + walk_down. Explicitly **do not use Spine or Skeleton2D in Godot runtime**, and don't fake animation by looping still images. Keep original Source A untouched and do not update its SQLite while its converter writer is running. Report required source inputs, exact tool dependencies, UI plan, test gates and estimated asset/storage budget. No game code, no merge, no Godot heavy test concurrently with Source A converter.

**Owner can later authorize scoped CODE packet for an isolated Asset Studio importer or Godot sample, separately from Source A and Combat V2.**
