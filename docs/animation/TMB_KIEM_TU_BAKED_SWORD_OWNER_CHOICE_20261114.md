# TMB Kiếm Tu nam — BAKED-WEAPON owner choice (2026-11-14)

## TOP PRIORITY: User's latest explicit decision OVERRIDES earlier modular sword requirement FOR THIS CHARACTER

The owner explicitly decided on 2026-11-14 to **stop sword-free body + separately animated weapon** attempts and author a **male Sword Cultivator WITH RED-BLACK SWORD BAKED INTO EACH SOURCE FRAME**. Preserve source art quality. No skeletal rig/Skeleton2D/Bone2D. This supersedes older Kiếm Tu docs/Issue #77 notes *only* where they insist that this Kiếm Tu's sword be dynamically swappable. It does NOT automatically eliminate modular equipment for other schools or projects.

Visual identity LOCK: male adult Shadow Pixel-Chibi Xianxia, silver-white high ponytail, cobalt-blue fluttering ribbons, bright blue eyes, crisp blue-white/silver patterned robe, forehead tiny crimson sword sect mark, asymmetric jagged black-red blade. Four **individually authored** viewpoints: front/right/back/left. No code-primitive redesign, no 128×128 destructive master. Source height 320 px and display at 75/150/225 px for zoom 1×/2×/3× as Source-A-inspired workflow. No ownership is asserted over third-party game character artwork; continue from images generated for owner's game.

### AS-CHAR-46 actual authored visuals and source exact identity
- New four-view owner-chosen rendered source: `chibi_kiếm_tu_disciple_sprite_turnaround.png` 1254×1254 RGBA SHA256 `1aa8b82457e072d28f06371bbbc40631626e593356548161c103e0e9bd455ccc`.
- Genuine nine-frame sword-in-hand RIGHT WALK GIF `chibi_xianxia_swordsman_walk_cycle.png` 418×418 GIF with 9×120ms and transparent background, SHA256 `f73817e0f935d81d4f927cdbebe43544e455a7e62c30c32312c4cd1ca7aa105a`.
- Exact new ZIP `AS_CHAR46_KIEM_TU_BAKED_SWORD_GODOT_WALK_R1_20261114.zip`, SHA256 `12af466d4069a97a4526db728be0fd65595053078623240408be441c881371ac`, 37 entries, CRC PASS.
- The archive was uploaded into user's **personal ChatGPT Library** path `/TMB-Character-Art/AS_CHAR46_KIEM_TU_BAKED_SWORD_GODOT_WALK_R1_20261114.zip`. **Binary ZIP, PNGs, GIF and atlas are NOT in the GitHub repository**. A new chat must locate via Files/Library, retrieve actual bytes and verify exact SHA before relying on it.
- Binary package contains original unchanged source art, 4 independent standalone STAND PNGs + 9 unique WALK_RIGHT PNGs, source-height 320 px on 384×416 canvas, common foot pivot (192,366), stand atlas, nine-frame 3×3 Walk atlas, real Godot `SpriteFrames` `animations.tres`, `actor.tscn` and standalone Godot 4.7.2 preview project with D/Space/1-3/F controls. No rig.
- Python technical source/alpha/geometry/atlas/SpriteFrames **STATIC_QA_PASS**, ZIP CRC PASS. Godot 4.7.2 executable was not available in ChatGPT local runtime, **GODOT_NOT_RUN**. Not production integrated in this turn.
- Preview GIF `qa/WALK_RIGHT_9F_SWORD_BAKED_ACTUAL.gif` uses 9 genuine source frames with no tween/fake motion. Four directional stands remain static and are **NOT** moving Idle.

### Clip coverage — no fabrications
Target: 4 directions × (Idle/Walk/Attack/Cast/Hit/Death) = 24 genuine separate animation clips. **1 / 24 authored moving candidates** = WALK_RIGHT 9 frames (latest-generation art; final owner/engine QA pending). Four static stands are NOT completed Idle. **19 other slots are MISSING**. Two attempted image generations specifically for ATTACK reverted to WALK; those outputs were REJECTED. Previous mixed-action concept sources may provide reference poses but no fake relabeling, no battle effects baked into attacks without design approval.

### Next production gate
First independently author true sword-in-hand ATTACK_RIGHT (windup, slash, recoil) with coherent grip, **actual blade traversing an arc**, using the same character master. Inspect consecutive real GIF frames before accepting. Next CAST/HIT/DEATH_right and true directional Walk. Ensure any generated Attack that merely walks with sword behind is rejected. Preserve source high-res and keep Godot QA isolated from dirty owner Windows E: checkout. No gameplay/SaveService/economy/Combat/V6.3 edits, no new branch or merge.
