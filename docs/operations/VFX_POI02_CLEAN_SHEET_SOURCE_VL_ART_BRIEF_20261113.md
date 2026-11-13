# POI-02 — Xà Ảnh Quấn Mạch clean-sheet Source VL-quality study

**Owner direction**: R1–R5 are definitively OWNER_VISUAL_REJECTED. This is a NEW isolated scene, not a version bump or reworked Gaussian path.

Canonical skill: tmb.skill.poison.co_doc.active_02.human / Poison / Cổ Độc / SINGLE_TARGET=1. A scene-fixed target dummy is used solely for preview. No damage/target-selection/timing/status/DoT/SaveService/economy/PvE mutation. No rig.

## New image-backed art and verified origin

- Original painted serpent: bespoke AI-generated wuxia concept illustrated in this session; manually extracted using chroma and spine masking into transparent full-body image, head / eyes / teeth / scales / tapered energy tail. Then remastered as six 512×179 sprite poses with small image-space tail undulations, packed as 1536×358 3×2 WebP flipbook (assets/serpent-flight-atlas.webp). Sprite alpha/mix, NOT procedural polyline snake or additive white noodle. No commercial JX serpent pixels in the snake.
- Original bind/coil spiritual light: masked/cut out of the same original concept art at the target, saved separately at 320×350 (assets/serpent-bind-energy.webp). Additive blending so the dark cutout reference actor does not obscure the actual Godot target. Art QA must explicitly check for ghost-actor contamination, rhythm and clipping. If quality remains poor, rework rather than promote.
- Actual JX1 Wudu #63 impact only: 13 frames at 56 ms, played on fixed preview target starting at CONTACT_AT=1.63, rects/pivots directly from fx_manifest.json. Not an actual verified snake. Rights of commercial JX sprite for any external redistribution remain unverified.
- Source VL sword 150: visual quality / sprite layering / staging reference (36×30ms cast, 21×30ms hit), not copied into this serpent.
- No imported skeleton / rig. Characters: original repo's unchanged approved 320×384 idle cell.

## Five stage contract / timing
0.00–0.54 charge; 0.54–1.63 flight 6-frame alpha sprite; 1.63–2.57 contact + animated spiritual bind (JX impact plays only 1.63–2.358); 2.57–3.45 dissolve; 3.45–4.10 rest/loop.

## Implementation / art hold
Scene: res://labs/combat_lab/poison02/xa_anh_source_vl_remake.tscn.
Godot GL Compatibility 4.7.2, native 1280×720 and 1x. All rendered stages must be inspected in movie. This is an experiment; OWNER_VISUAL_PENDING until explicit review. Do not enable V6.3/PvE or call this production-approved. Physical Windows/Android perf, scale/LOD 6v8 and 30x40 remain untested.