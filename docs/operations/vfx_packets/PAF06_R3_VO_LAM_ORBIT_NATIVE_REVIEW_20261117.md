# PAF06 R3 — Võ Lâm-inspired rotating body buff, native Godot owner review

Date: 2026-11-17. PR #72 Draft. Existing integration branch only, no merge and no live gameplay edits.

## Owner direction, reference and rights

Owner asked for a clearly visible light ring **rotating around the character**, reminiscent of classic Võ Lâm game buffs. We inspected screenshots and compared publicly available GitHub Godot VFX examples (REEBOO godot-stylized-2d-vfx-lite, MIT; Godot 4.7 Effects Lab). This implementation learned *staging/depth/animation principles* only. **No proprietary Võ Lâm, Kiếm Thế or third-party extracted sprite was imported.** All runtime VFX ring pixels were authored independently in the first-party Pillow generator. Commercial Võ Lâm screenshots are references, not redistributable gameplay art.

## Canonical skill and three clocks

- Skill: `tmb.skill.talisman.phong_an_phu.passive_01.human` — Tĩnh Giới Tĩnh Tâm.
- Wind, passive_always_on, catalogue candidate cooldown_recovery_factor=0.015. It is NOT a guard and is NOT an independently applied timed buff or an activated skill.
- Canonical cast=0, cooldown=0, duration=0, damage=0, projectile=0. No cast/contact/hit receipt. The generic catalogue hit_count=1 field is not used to fabricate a hit.
- Visual clock: seamless approx 3.0 second pair of moving orbit highlights over original 48-source-frame per-layer true alpha animation. Gold/jade energy rings around character, with 2.5D far/near split, one subdued foot ellipse.
- QA clock: 4.2s @ fixed 60FPS native movie (252 frames), with ON/OFF comparison at the same local timestamp. This is an encoded simulated timeline, not measured physical FPS.
- **G3.5 charge/peak/moving-contact N/A to passive_always_on.** G3.5 substitute: early orbit / luminous core / near-side depth and actor head/face visibility, no false enemy contact.

## Source and implementation

- Reproducible first-party code painted generator: `tools/vfx/paint_paf06_r3_orbit.py` (not copied JX pixels). Its generated source master PNG and 48-pose each RGBA WebP atlas are attached in the Actions artifact and can be reproduced from git code.
- Three transparent layers: `rear` (far half orbit), `front` (near half) and `spark` (drifting glints). 48 poses per layer, 144 cells total, 320x320 each, 8x6 atlas. Gold highlights orbit in the opposite direction from jade; the actor's body is composited BETWEEN far and near halves. Additional CPUParticles2D motes continue independently at a small budget.
- Runtime scene: `godot/labs/combat_lab/talisman16/r3/vo_lam_orbit_buff_r3.tscn`, script of same base. This R3 inherits R2's passive fixture without changing R2 animation source, no rig or gameplay writes.
- OFF comparison: `godot/labs/combat_lab/talisman16/r3/vo_lam_orbit_buff_r3_off.tscn`.
- Tests: `godot/tests/labs/combat_lab/vfx_paf06_r3_contract_test.gd` and `tools/qa/check_paf06_r3_orbit.py`.
- Native workflow: `.github/workflows/vfx-paf06-r3-orbit-native.yml`.
- No GIF (per owner instruction).

## Technical verification – exact SHA

Technical source/content SHA: **de9701beb3ba17a31c730a642825e3841435e195**.

- GitHub Actions: https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44103927302 — **COMPLETED SUCCESS**, official Godot 4.7.2 Compatibility, strict import, full focused test, native 1280x720 252 frames / 4.2s video.
- Exact-source 48x3 atlas hash/alpha tests PASS; original-source rights recorded in manifest.
- R3 native ON/OFF 1× visual difference: 3,144 changed pixels (>24 intensity in caster ROI); strong head overlap 0 pixels (>90 threshold), proving a visible ring without face occlusion.
- One previous run failed on sparse sparkle-source alpha threshold (intentionally lower than main ring); fixed by separating spark alpha gate rather than increasing sparkle brightness.
- Another previous run actually rendered genuine Godot 252 frame video, but FFmpeg phase-image extraction failed because `-ss .35` was rejected; corrected to `0.35`. Neither failure was a scene/runtime PASS.

## Art self-review — NOT an owner approval

The buff reads more clearly than R2: two distinct horizontally tilted orbit rings visibly surround the character and can be seen at native 1x. It has 2.5D actor depth, independently traveling bright glints and a restrained gold foot sign. It is closer to the requested traditional Võ Lâm buff language than the former two upright jade strips. However, the current source is first-party code-painted raster and the rings may still look too thin/synthetic compared with professional hand-painted game effects. Larger bloom would worsen character readability; improve irregular light material/short tail shapes instead if rejected.

Self-ratings (artistic /5): buff identification 4, silhouette 3.5, material 3, moving orbital readability 4, actor occlusion 4.5, uniqueness 3.5; **G6 ART SELF REWORK/PENDING owner visual choice**, not art-approved. The user has not reviewed the R3 video as of this record.

States: Godot technical PASS; G3.5 passive-specific native view PASS technical; G6 ART_OWNER_PENDING; actual PvE integration HOLD, V6.3 OFF; physical Android/Windows and crowded-battle perf PENDING. PAF05 R5E remains PROVISIONAL and its ugly charge backlog is unchanged.
