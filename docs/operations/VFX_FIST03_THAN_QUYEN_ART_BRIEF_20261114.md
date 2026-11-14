# FIST03 — THẦN QUYỀN | original painted sprite VFX art study
**Date:** 2026-11-14 · **Scope:** isolated Godot Combat LAB, PR #72 Draft, Godot 4.7.2 GL Compatibility

## Truth before appearance
The exact name “Thần Quyền” is **not** a canonical separate fist skill in current registry. This is the requested visual title only. To avoid fabricating a new combat node, the demonstrator borrows *only* the existing **Bá Quyền Human ultimate / Sơn Hà Chấn Thiên** visual contract: `tmb.skill.fist.ba_quyen.ultimate.human`, damage, fire, circle radius 3, maximum three targets, cast 1.15s, range 5, projectile_speed 8. It does NOT add the skill “Thần Quyền” to game registry, and does NOT alter any damage. Immortal/Divine branches are different catalogue entries and do not inherit approval automatically. User can later explicitly choose canonical binding.

## Original asset provenance and composition
- The first-party gold-amber spirit fist and fire-rock impact were separately isolated from a **generated presentation illustration** (not copied from any JX/Source VL/Source A proprietary asset). The source presentation illustration is not called gameplay footage or QA proof.
- Fist master `assets/godfist_master.webp`: first-party ImageGen-origin cropped material, RGBA 384×384, front knuckles and lit seams genuinely present in source. Prepared alpha clean mask + left-edge fade, then WebP quality 75.
- Impact master `assets/impact_master.webp`: first-party ImageGen-origin cropped explosion/rock material from same presentation image, alpha mask, WebP quality 78.
- Deterministic Python Pillow/NumPy factory `tools/vfx/generate_fist03_than_quyen_v1.py` bakes 40 actual image-origin alpha pose frames: charge 8 (4×2), fist flight 12 (4×3), fire-rock impact 12 (4×3), dust/ash 8 (4×2), cell 384×384; atlases are generated BEFORE Godot strict import, and uploaded to CI artifact with SHA256.
- Shader-derived soft light and tiny victim glints are secondary to original art. **NO RIG** and no copied game commercial textures.
- Existing valley backdrop and static character pixels are **LAB SCALE PLACEHOLDERS** from project; they are not a new approved Quyền Tu cast animation.

## Storyboard (3.28 s demonstration loop, art preview only)
| Time | Image and action |
|---|---|
| 0–0.39s | small condensed painted glowing fist, controlled gathering highlights |
| 0.39–1.15s | larger first-party spirit fist appears, rises and brightens; actor idle unchanged |
| 1.15–1.69s | massive detailed golden fist crosses toward target group, 2 soft delayed source-image echoes |
| 1.69–1.91s | one *demonstrative* contact wave, large original fire-earth stone burst; three **visual-only** injured-opponent flash/recoil cues staggered by 0 / .055 / .105 s |
| 1.91–2.89s | stone debris and amber afterimage fade, no extra hits/HP writes |
| 2.89–3.28s | clear/reset |

**Important:** LAB contact is storyboard timing only, not actual Combat V2 hit receipt. Runtime cannot play target flash until its own confirmed hit event. No fake 4th victim. No rig, no body-kicking action or damage/status writes.

## QA/acceptance
CI workflow `.github/workflows/vfx-fist-03-than-quyen.yml` pinned official Godot 4.7.2, strict import, script parse and focused contract; native Godot 1280×720 MP4/GIF and 12 timed PNGs, 40-frame atlas exports and checksums. Run ID/exact SHA, image inspection and art rubric must be appended AFTER real run. Never label preview-composites or the ImageGen presentation board as Godot screenshots. Encoded fixed 60fps ≠ physical Android FPS.

Current gates: `CODE_LAB_READY / GODOT_QA_PENDING / OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / V63_OFF`. Do not merge PR, edit other schools, save, economy, Combat V2, HP or feature gates.
