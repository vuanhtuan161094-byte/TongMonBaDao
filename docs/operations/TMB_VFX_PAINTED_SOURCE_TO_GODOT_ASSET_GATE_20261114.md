# TÔNG MÔN BÁ ĐẠO — PAINTED CONCEPT → GAMEPLAY-SPRITE QUALITY GATE (2026-11-14)

**Applies to every VFX school** via `AGENTS.md` → sprite-first quality rules → shared pipeline → this gate. Mandatory whenever an original generative/painted concept is converted into sprite, flipbook, alpha art or textured impact. **No rig, no Codex, no branch/merge, no live gameplay modifications**. Owner visual approval is distinct from CI.

## Why this exists
TAL02 R1/R2 thin GDScript curves and SVG gradients were technically valid but read as neon tubes. TAL03 procedural marks were legible yet lacked the painted material depth the owner approved as a direction in TAL01. A beautiful static concept is NOT a Godot effect: **retain the source's actual lit pixels as texture**, don't re-trace the image with uniform runtime lines. Use shaders/particles for subtle motion or spark accent only.

## Source provenance — must be honest
The TAL02/TAL03 painted samples below were extracted from **original image-generation artwork created within the TMB conversation**, not captured from a playable game or imported from JX, Kiếm Thế, Source VL or Source A. Raw concept images were **not** directly imported as a game screenshot. The actual standalone transparent master WebPs are committed, alongside separately authored alpha/warped flipbooks. If a new skill uses outside art, rights/license proof must be obtained first.
- Source concept `a_dramatic_high_detail_vfx_concept_screenshot_com.png`, SHA256 `17753a05e26aa826aed3eb1b8d01a9577ca301a3dcf3fa6c33e171bc6bac1f30`: lightning crop (337,725,512,827), impact crop (515,723,640,825).
- Source concept `a_dark_black_fantasy_game_vfx_showcase_layout_hig.png`, SHA256 `4103fc3e65e778c826b0e2036fe144ca9bea7a12b6c9feaddbc3b014f8e0d7b9`: caster circle (26,540,250,628), TAL03 glowing talisman (111,100,505,428).
- Original poster masters are **not distributed as separate game textures**: only their manually isolated effect layers and resulting master/flipbook images are retained. Archive the poster's name, prompt/version, crop and SHA to enable traceability. If full byte-reproduction is required, preserve the source concept in authorized art storage; a crop alone does not recreate its input generator.

## Production: painted source is art; runtime is choreography
1. **Identify an approved-looking master**: self-authored/first-party art, distinct clean silhouette, high-key focal whites, violet/yellow-gold falloff, atmospheric fragments, no background, UI panel, character, typography or watermark embedded in the VFX sprite.
2. **Crop with margins and clean alpha**: remove source presentation background using chroma/luminance matte; preserve faint luminous wisps with graded alpha. Manually inspect on light gray, dark charcoal and actual bright game terrain. Avoid black rectangle, box edge, brown paper bleed, 1-pixel white cutoff, clipped strokes.
3. **Repair actual prop body**: when a dark inlay is intended (e.g. TAL03 gilded talisman), protect it by an inner material matte. Never solve it by leaving the entire poster crop opaque.
4. **Bake multiple real poses**: each pose must differ in the pixels: controlled non-rigid mesh/phase displacement, stroke growth/wipe, lighting sequence, ink reveal and fragment release. Repositioning or rotating one sprite at runtime alone is NOT a flipbook. Clean alpha and anchor in every cell; verify no skipped frames, clipped ends or bleeding UVs.
5. **Export measured atlas**: TAL02 ten 1024×256 painted strokes, 4 cols × 3 rows, `4096×768`; TAL03 eight 320×320 painted stamps, 4 cols × 2 rows, `1280×640`. Keep maximum texture side ≤4096 for expected Android compatibility; WEBP RGBA or PNG with exact alpha accepted. Record source masters, atlas rect, filter, pivot and image hashes.
6. **Compose by actual scene layers**: painted ground array behind actor's feet → caster/target stand-ins → talisman/ink hero under appropriate actor occlusion → local confirmed contact image (only damage skill) → small optional shader/particle. No duplicate UI-looking ring, no fake extra hits, no fictional target number. For TAL03 mark, **no impact damage burst or DoT**; the glyph only appears on confirmed mark receipt in future real integration.
7. **Inspect real Godot at native 1×**, both 1280×720 MP4 and 8–14 timed PNGs. Compare same-frame R2 vs baked version for silhouette richness, glow response, contact, fade, face coverage, clipped bounding box, shader blending. Export a GIF for owner review. A fixed 60fps encoding is not physical device performance.
8. **Exact SHA QA & approval**: Godot 4.7.2 GL Compatibility import/parse/focused tests verify the real image exists, dimensions, alpha and declared target/effect semantics; video is inspected separately. `GODOT_TECH_PASS` != `ART_SELF_REVIEW_PASS` != `OWNER_VISUAL_APPROVED`. No approved visual = `OWNER_VISUAL_PENDING`. Live PvE/V6.3 remains OFF.

## Per-skill concrete application
| Skill | Hero layer | Supporting layers | Disallowed visual |
| --- | --- | --- | --- |
| TAL02 Thiên Lôi Dẫn Nét | Real 10-pose painted white-violet hand-written lightning, main texture `tal02_thunder_flipbook.webp` | Painted caster array `talisman_foot_array.webp`, small painted local crack `tal02_fracture_impact.webp`, low-intensity procedural flicker only | Flat SVG line as hero, symmetric ring AoE, >3 targets |
| TAL03 Lôi Văn Truy Ấn | Real 8-pose gilded ink talisman stamped over exactly one target, `tal03_mark_flipbook.webp` | Brief shared caster array and low opacity halo | Damage blast, persistent false lightning ticks, >1 target, giant target-face obscuration |

## Acceptance checklist
- [ ] Concept source attribution/hash/rights verified and matte origin recorded
- [ ] Actual ALPHA (not fake checkerboard), no edge/seam/cropped-background rectangle on mid-gray
- [ ] Hero image is independently rendered original art, not UI infographic/copy of licensed commercial pixels
- [ ] Each flipbook cell has proper action progression and correct subrect/anchor; no rig
- [ ] Lighting hierarchy: one hot center, quiet secondary aura, little flash pollution
- [ ] Native Godot footage with full 8+ checkpoints inspected; exact SHA, run ID and artifact present
- [ ] No gameplay contract fabrication; all cosmetic events correctly gated
- [ ] Owner explicitly approved THIS skill, not just the METHOD; PvE remains separate

## Evidence-driven correction case — TAL02 R3→R4 / TAL03 R2→R3
Review the **actual Godot 1280×720 screenshot**, not just the standalone asset on charcoal. The first baked TAL02 alpha atlas was rich, but 1.08s revealed its nontransparent pixels only spanned x≈350..702 of a 1024px cell; it produced a disconnected floating energy fragment. TAL02 R4 normalizes the true alpha bounding box, stretches the original painted pixels into the usable 952px width, then regenerates all 10 warped/wiped poses; tiny procedural support remains subordinate. The TAL03 R2 proof at 1.08 and 5.03s showed high-quality painting but a too-large target mark, so R3 reduces the mark's displayed size from 68→52 initial radius and 55→40 steady. Both fixes follow the art-first rule: keep painterly material while correcting native-scale position, lighting and silhouette. Record the corrective run's SHA and 8+ frames separately; do not call art approved merely because alpha tests and CI are green.

## Prevent an attractive but disconnected asset — native-scale anchor validation
At actual combat scale compare first-frame hot current with the caster **HAND** anchor, the midpoint with the declared LINE trajectory and the final frame with the target chest/contact point. A perfectly painted original lightning stroke may have a diagonal inclination relative to the path in the game; correct its **baked original pixels by a smooth spatial warp/shear**, don't compensate with uniform neon polylines. TAL02 R4 movie run 43584912261 exposed the defect (light left too low / head ended too high). TAL02 R5 generator rebakes painterly alpha using `vertical_shift=np.interp(...)`; verify genuine same-clock screenshots after any such source-art change.
