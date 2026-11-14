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
