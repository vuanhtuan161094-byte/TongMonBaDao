# TMB VFX — SPRITE / ATLAS / LAYER PRODUCTION PIPELINE
Date 2026-11-14 | PR #72 Draft | Godot 4.7.2 Compatibility | Owner artwork first

## Lesson from Loi Phu (technical method, NOT source art reuse)
Actual files studied:
- godot/labs/combat_lab/talisman01/ART_PROVENANCE_R4.md
- godot/labs/combat_lab/talisman01/dien_quang_khai_phu.gd
- tools/vfx/generate_talisman01_atlas.py
- .github/workflows/vfx-tal-01-dien-quang-khai-phu.yml

The effective workflow starts with original illustrated hero asset -> cleaned RGBA alpha -> multiple original atlas poses -> independently controlled emission/contact/ground layers -> genuine native Godot 1280x720 video -> timed frame-by-frame review. Copy its METHOD, never its talisman glyphs or violet sparks into Fist or other schools. A source concept illustration or generated poster is NOT a gameplay asset or a Godot capture. The owner, not CI, approves art.

## Required stages
1. G0 read canonical skill ID, exact Combat V2 effect/element/shape/range/target cap/cast time. Never invent AoE, fire DoT, status, HP, hit/summon or other gameplay events.
2. G1 describe reference material/motion and permissions. Unlicensed commercial JX/Source VL asset pixels are reference-only.
3. G2 design an individual hero silhouette plus 8-12 pose storyboard across charge / release / active / contact / fade. Keep readability at real 1x game scale.
4. G3 make first-party transparent art. Painted master can be authored or ImageGen-generated and independently cleaned/animated; deterministic raster painting via Pillow also counts as original source art but does NOT automatically pass aesthetic review. NEVER replace poor art with only SVG recolors/shader rings. Distinct actual pose imagery is necessary.
5. G4 atlas specification: record width, height, frame count, rows/columns, rect per cell, pivot, alignment, RGB/alpha edge cleanup, no edge bleeding. Example: 12 hero poses in 4 columns x 3 rows of 320x320 RGBA pixels (1280x960); 8 impact poses in 4x2. Store provenance and the complete reproducible source.
6. G5 composite BACK TO FRONT: ground/ambient dust (MIX) -> aura and shot (MIX/ADD at restrained alpha) -> actual actors -> small foreground weapon/fist/contact (MIX, minimal hot ADD) -> grit and fade. No giant opaque polygon hiding target. Linear filtering for painted/glow alpha, nearest for truly pixel-art actors.
7. G6 genuine Godot scene at 1280x720, capture MP4, GIF, at least 8 checkpoint PNGs, test with bright/dark terrain and actors at 1x. Animation clock 60fps in movie is NOT measured physical Android/Windows performance.
8. G7 strict exact-SHA import+parse+focused contract; inspect motion/art not just checks. Score silhouette, material/light, choreography, layering/readability, contact, fade, uniqueness >=4/5 each; otherwise rework SAME skill and repeat render.
9. G8 owner explicit approval and separately authorized live PvE receipts. Until then OWNER_VISUAL_PENDING, PVE_INTEGRATION_HOLD, V63_OFF.

## Concurrent school ownership and safe writes
Read AGENTS.md, Art-First SOP V3, this file, and the specific school's playbook. Each chat only changes its own school-owned LAB, test, generator, workflow and art packet: Poison poison*/ , Talisman talisman*/ , Fist fist*/ . Never edit TAL01 or POIxx from the Fist chat. One PR #72 branch; check current HEAD on every write; nonforce fast-forward with expected SHA. No Codex, skeletal rig, branch or merge, Combat V2/SaveService/economy/AI change.

## Actual Fist adoption R9 (not owner art-approved)
tools/vfx/generate_fist01_painted_atlas.py -> three raster alpha sprite sheets: 12 hero + 8 charge + 8 impact = 28 frames, not a sprite made from Tal01. They are first-party procedural Pillow paintings (not ImageGen artwork), with separate glow and local dust/crack layers. Lab scene: godot/labs/combat_lab/fist01/khai_son_trong_quyen.tscn. True native run #43580310765 on commit 7f74ab41..., strict import/test/movie PASS; the hero remains visually too flat like an orange mitt, so ART_REWORK_REQUIRED. CI success is NOT a beauty pass.

## Added 2026-11-14 — preserve painterly render quality in *actual* skills
Read **[Painted Source → Gameplay Sprite Quality Gate](TMB_VFX_PAINTED_SOURCE_TO_GODOT_ASSET_GATE_20261114.md)** before converting generated concept art into runnable VFX. TAL02 R3 and TAL03 R2 replace their **primary** procedural SVG/line layer with first-party painted WebP RGBA masters/animated atlases, independently baked impact art and a caster-ground texture, with runtime shaders/lines only as minor support. Keep exact original art source SHA, alpha mask proof, atlas frame geometry and native Godot footage; a presentation board is not a game screenshot. This is a rendering-method acceptance, not new owner visual approval or blanket skill PASS.

## Shared native-scale anchor lesson — TAL02 R6 / TAL03 R4, proven 2026-11-14
- An original beautiful alpha atlas still fails in-engine if its **VISIBLE painted-pixel envelope** starts far from the caster hand. TAL02 R5 had a ~100px+ gameplay-scale left gap at 1.08s; R6 keeps the source painted pixels and repositions/extends the raster destination rect while anchoring the subordinate (10%) conductor to the same palm pivot. Preserve the right/contact endpoint. Check 0.73, 1.08, 1.51s in the REAL Godot MP4, not a standalone poster.
- A six-second status mark should remain small and readable throughout sustain, not act like damage: TAL03 R4 moved the painted mark 9px below the target face, reduced ambient halo and warmed the original gilded material without replacing the eight baked frames. Check 1.08, 5.03, 6.85, 7.04s for occlusion/readability/fade. The LAB clock does not create real marks.
- Evidence: TAL02 R6 source `b2b21147b834a59b14fc16530d014c5e1e39f16d` [Actions 43604043517](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43604043517) — strict import/parse/focused and 188 frames 1280×720 PASS. TAL03 R4 source `7f141fefd7eee87f61a6a04fb446f1742cb7d798` [Actions 43604383986](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43604383986) — same QA and 468 frames PASS. Self-review found better anchoring/readability, **not OWNER_VISUAL_APPROVED**. Preserve original master+flipbook. Physical device FPS remains unknown.


## Production System V4 synchronization — 2026-11-16

This is a **companion** to the canonical Production System V4 addendum in TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md; no independent competing SOP. All school art chats must follow that newer rule. The earlier 8–12 pose and 8 checkpoint examples above are **defaults**, NOT universal requirements. The exact frame count must be derived from the intended actual duration, independent silhouette changes and display cadence; persistent buff/debuff layers may loop clean poses instead of baking their entire 4–8 second duration.

- Always acquire **live PR #72 HEAD** and original catalogue/ledger, then write a three-clock timeline: canonical cast/status/projectile/receipt timing; local animation charge/release/travel/contact/fade; LAB demo/video loop. In stand-alone LAB report assumed contact times as simulated, never as verified gameplay hits.
- **Master first.** Store sufficiently large original transparent artwork and independently authored living pose changes, measured native visible-alpha envelope, source SHA and durable masters. Byte-unique hashes establish file integrity, not beauty or frame-to-frame motion.
- **G3.5 STOP before full render.** Build cheap provisional Godot capture with three true native 1280×720 frames at charge/peak/hit ON A MOVING MONSTER. Compare at identical 1× gameplay scale to source art; review saturation/core, material, alpha, caster hand and target contact, occlusion and silhouette. Failed comparison returns to original sprite work. This is a human review gate, not an automatic visual PASS.
- **Compositing** follows MIX-painted material → selective concentrated ADD emission → restrained localized soft ambient → event-tethered impact and short residue. Visual circling/radiant bursts can be beautiful when independently painted and skill-specific; never repeat uniform HUD neon rings across schools.
- **G4/G5** must use stationary/moving/multi-target visual cases with genuine motion inspection, >=12 meaningful checkpoints when clip length supports them, dark/light terrain, exact alpha and back/front layers. Hit follows an event/receipt when integrated; presentation cannot create mechanic effects.
- **G6–G8 separation:** self art review, technical exact-SHA QA, owner visual approval, live/PvE authorization and physical Windows/Android FPS are distinct. Preserve previously approved TAL02 R6/TAL03 R4 and accepted Poison sources; revise only authorized portions.
- **Cross-chat handoff** is mandatory: latest branch SHA; school skill exact ID; three-clock matrix; art master/atlas manifest and provenance; G3.5 visual gate result with three frame locations; actual movie and moving-contact findings; art self-score; technical CI/run; owner/PvE/device status. If not run, mark NOT_EXECUTED rather than using historical run as current validation.

