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


## Verified Godot V3 — actual native review / art decision

- **QA source SHA:** `d631b1f2fcc3d92f08029bb9333e5e03bcad1987`; [official GitHub Actions run #43617223374](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43617223374): conclusion **SUCCESS**. Artifact **vfx-fist03-native** ID **14122568500**, MP4 1280×720 (60fps fixed clock), GIF, 12 native phase PNGs, 4 RGBA 40-frame atlases, source logs, SHA checksums; exact `Godot 4.7.2.stable.official.ed1daf0bf`. Strict import/parse and focused `VFX_FIST03_FOCUSED_RESULT=PASS failures=0`.
- Earlier #43616259087 failed strict parse due missing local float/Vector2 inference; fixed at SHA `db4c866863c9ada412d95a77ea3595e89dc2fb5c`, successful run #43616448751. R2 run #43616805884 technically passed but review showed a sharp rectangular lower/left impact cut in the **source image content** (not just atlas cell edges). V3 changed true image-content alpha feather bounds and rerendered native footage. Do not call R1/R2 finished.
- **Observed native V3 frames:** 0.76 s first-party gold-painted fist appears behind the unchanged actor, 1.40 s large image-origin knuckle-lit spirit fist on directional travel, 1.70–1.83 s illustrated fire-rock blast visibly behind three target stand-ins, **three distinct short chest highlights/whole-sprite small recoil cues**; V2 rectangular lower crop has been softened with an actual content-edge alpha window. 2.42 s residual smoke/grit reduced; 3.03 s clear. V3 is noticeably better than V1's flat-source impact edge, but the blast still has some broad illustrative-material appearance at 1×.
- Manual self-score /5: core fist silhouette 3.8, painted light/material 3.8, movement/weight 3.5, composition/occlusion 3.9, target reaction 3.8, fade 4.0, uniqueness 3.8, physical performance **NOT MEASURED**. These are ART-SELF-REVIEW only and remain below the SOP's all-items ≥4/5 owner-submission gate. Real actor uses approved existing **Poison Tu idle placeholder** only, not original Quyền Tu character punch/hit animation. No skeletal rig.
- **Semantics:** “Thần Quyền” is a first-party *visual concept name*, not an ID in authoritative catalogue. No registry change. Reference contract `tmb.skill.fist.ba_quyen.ultimate.human` = Human Bá Quyền ultimate Sơn Hà Chấn Thiên (damage / fire / circle radius 3 / cap 3 / cast 1.15 / range 5). LAB contains scripted *illustrative* three-target contact timings; they have **NO gameplay authority**, no HP writes. Live contact must later be coupled to confirmed per-target Combat V2 hit receipts and only upon separate owner permission. Divine-tier branches have different IDs and elemental/combat contracts; do not infer binding.
- **Gates:** CODE_LAB_READY, GODOT_FOCUSED_PASS, GODOT_NATIVE_CAPTURED, FRAMES_REVIEWED. **OWNER_VISUAL_PENDING / ART_POLISH_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_WINDOWS_ANDROID_QA_PENDING**. Tech PASS != art approval or Android 60fps.

## Owner visual decision from chat — 2026-11-14 after V3
Owner message **"ok chốt. skill tiếp theo"** immediately after reviewing Thần Quyền V3 video. Record **OWNER_VISUAL_ACCEPTED_FOR_LAB_V3** (not a newly authored canonical skill ID, and not blanket approval of all successor tiers). The original art study still maps as design reference to Human Bá Quyền ultimate Sơn Hà Chấn Thiên. Preserve underlying official Godot Actions #43617223374 and recorded art SHA d631b1f2; **PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_QA_PENDING** remain. This supersedes older owner_visual_pending only for the reviewed Thần Quyền V3 artwork.
