# AS-CHAR-49 — Audit sai quy cách Nữ Kiếm Tu (2026-11-14)

**Status: ART_FAIL / SOURCE_INCONSISTENT / ANIMATION_INCOMPLETE / GODOT_NOT_RUN / NOT_FOR_PRODUCTION.**

## Contract to restore (actual authority)
Read `AGENTS.md`, `docs/animation/TMB_KIEM_TU_FEMALE_ART_DIRECTION_AND_PIPELINE_20261114.md`, and `docs/handoffs/AS_CHAR48_KIEM_TU_MALE_24_CLIP_TECHNICAL_DRAFT_20261114.md`.
- Female original identity = **deep indigo/dark violet hair**, high tied hair + white-blue floral ornament and flowing blue ribbons, blue-violet eyes, elegant blue-white/silver layered robes, **blue-silver sword baked into each frame**. Female is independent from the male silver-white ponytail / red-black sword. Original reference: Library `KIEM_TU_FEMALE_4DIR_ATTACK_LOSSLESS.apng`, `KIEM_TU_INTERACTIVE_QUALITY_REVIEW.html`.
- Same high-resolution production contract as male AS-CHAR48: four independently authored views (front/right/back/left) × six real states (Idle/Walk/Attack/Cast/Hit/Death) = **24 distinct motion clips**; **512×512 RGBA**, shared foot pivot **(256,442)**, visible actor target ~320 px; sprites intended for game map at 75/150/225 px for zoom 1×/2×/3×. Standalone per-clip source frames + GIF preview + transparent atlas + Godot `SpriteFrames`, source hashes, per-clip real unique-pose counts and 1280×720 **actual Godot 4.7.2** QA. Only Death holds final frame; no rig/Skeleton2D/Bone2D; no synthetic static bobbing. No gameplay, SaveService, combat, economy, production replacement, new branch or merge.
- **Current male AS-CHAR48 itself is a 24-slot technical draft, not approved production**, so do not mistake exported-file counts or promotional layouts for acceptance.

## What went wrong (observed bytes in /mnt/data, same conversation)
1. Assistant abandoned the locked **female blue-white / deep purple / silver-sword** identity and generated multiple **silver-white-haired / red-black-sword male-lookalike** sources. It therefore *cannot* combine those frames with the original female identity.
2. Assistant repeatedly asked the image generator for a **pretty completed animation poster**, not isolated production frames, then mistakenly continued to treat infographic claims (`24 clips`, `Godot-ready`) as if they were evidence. Such posters are NOT sprites, atlas, GIF, Godot screenshots or QA.
3. Assistant generated **Walk over and over**, failed to produce distinct Attack/Hit/Death or a coherent 4-direction × 6-state source set. One Cast source is a separate *silver-haired* character with blue sword and painted-in blue light, not the dark-haired reference.
4. Source format and clipping were not gated. Files named `.png` may actually be GIF and vary from 8 to 9 frames and 414×414 to 508×337. Some sources have **fully opaque gray/black backing**, other GIFs have **detached extra remnants at the bottom**, and some silhouettes/VFX approach the bottom canvas boundary. These cannot be accepted as clean transparent, shared-pivot 512×512 frame cells without explicit source QA.
5. No exported **female** 24 `SpriteFrames`, 24 individual atlases, 24 action GIFs, true pivots, frame uniqueness manifests, Godot 4.7.2 GUI footage or checked owner approval. No right to claim master locked or animation completed.

### Sample verification by Pillow (2026-11-14)
| Source | Actual magic | Size | Frames | Issue |
|---|---|---|---:|---|
| `chibi_swordswoman_walking_animation.png` | GIF | 414×414 | 8 | Female purple hair, **opaque grey background**, Walk only |
| `chibi_sword_cultivator_walk_cycle_animation.png` | GIF | 418×418 | 9 | **Male-like silver hair with red-black sword**, mismatched female reference |
| `chibi_xianxia_back_walking_animation.png` | GIF | 482×362 | 8 | Back-facing purple-haired Walk, **detached leftover content at bottom** in inspected frame |
| `animated_chibi_sword_cultivator_walk_cycle.png` | GIF | 482×362 | 8 | Purple-haired **front-facing Walk**, not additional action |
| `indigo_sword_cultivator_walk_cycle.png` | GIF | 482×362 | 8 | Purple-haired side Walk, bottom contamination in inspected frame |
| `chibi_sword_cultivator_casting_animation.png` | GIF | 508×337 | 9 | **Male-look silver hair**, blue sword + baked light, full opaque black backing |
| `chibi_sword_cultivator_turnaround_animation.png` | GIF | 482×362 | 8 | Purple-haired side Walk-like poses, NOT four-view master despite name |
| `silver_lavender_sword_cultivator_turnaround.png` | PNG | 1448×1086 | 1 | 2×2 *static* four-view on opaque black canvas, silver-haired/red-sword identity |
| `chibi_sword_cultivator_walk_cycle.png` | GIF | 482×362 | 8 | Purple-haired left Walk only |
| `chibi_sword_cultivator_walking_animation.png` | GIF | 418×418 | 9 | Silver-haired male-like Walk + red-black sword |

All frame counts/sizes determined by opening the **actual file contents with Pillow**, not the extension. Several GIFs have 8 unique encoded frames, but uniqueness does **not** prove aesthetic continuity or correct action. Inspection image `female_recent_sources_private_qa.jpg` is an offline comparison, NOT Godot footage.

## Source disposition
- **Retain for REFERENTIAL PURPOSE ONLY**: dark-indigo-haired Walk candidates (do not imply they form 4 approved directional sequences), the **original female Library reference** and approved B+C female identity.
- **REJECT AS FEMALE PRODUCTION SOURCE**: silver-white male-look frames, black-red sword turnarounds, gray/black matte files, detached extra components, falsely titled multi-state layouts, and any Walk labeled Cast/Attack/Hit/Death.
- The original female Library APNG must be retrieved and inspected before further generation; if its raw bytes cannot be accessed, keep the correct reference visible via Files read and mark unverified source without inventing a new identity. Do not use old sexy gold-purple lotus mood board in place of current 3.5-head chibi look.

## Corrective workflow, mandatory before proceeding
A. Read current PR #72 HEAD, AGENTS, female authority doc and AS-CHAR48 source manifest; identify one female *authoritative visual master* and sword, make real 4-view transparent PNG and inspect silhouettes 1×/3×. Do not claim master LOCK without owner approval.
B. Export **one** true female direction **Walk** and a visually DIFFERENT **Attack** at ≥320px visible height as a paired motion contract. Reject if color/hair/weapon morph, the sword does not swing, or pose is global bobbing.
C. Then independently author the remaining action/direction source frames and 24 honest clips; process original GIF frames instead of cutting contact boards; 512×512 pivot (256,442), exact source-to-atlas pixels, alpha, no crop, unique poses, end-to-start motion seam, legitimate frame durations.
D. Run exact-SHA official Godot 4.7.2 project rendering and 1280×720 zoom QA, actual GIF/video/manifest, get owner visual signoff. Keep release BLOCKED until passes.

**Current female completion: 0/24 Godot-verified/prod approved; no new valid 24-slot female game asset pack.**

This is a documentation/quality correction only; do not mutate game code, existing male art source or current deployed assets.