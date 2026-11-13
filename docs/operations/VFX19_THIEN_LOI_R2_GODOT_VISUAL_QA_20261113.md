# VFX19 Thiên Lôi — trực tiếp code / nghiên cứu nghệ thuật / Godot 4.7.2 R2 QA
Date: 2026-11-13. PR #72 Draft, branch `integration/pve-p0-playable-ui-20261103`. Base code SHA after art pass `45fda38f67d478bb5a6e6c49a11908c2d667f251`.

## Why VFX19 exists
Owner explicitly rejected VFX18.2 sword-qi artwork ("xấu vãi nhái") and requested THIÊN LÔI instead, then asked whether handing the job to Codex would automatically achieve game-level VFX. Response: NO GUARANTEE. All VFX19 changes were implemented directly through GitHub (no Codex/delegation). A successful CI and hundreds of script lines do not prove artistic quality. Owner's visual art approval remains explicit, not assumed.

## Source & restrictions
Read owner style / persistent skill `.agents/skills/tmb-vfx-art-director/SKILL.md`, existing V9 serpent energy anatomy `godot/labs/combat_lab/combat_lab_v9_energy_fx.gd` and V9 original light-compositing shader, and research about JX/Source A in `VFX18_JX_SOURCEA_LIGHT_LANGUAGE_RESEARCH_20261113.md`. No JX/Source A commercial art copied. Documented eight-stage storyboard **BEFORE** code at `VFX19_THIEN_LOI_ART_BRIEF_20261113.md` commit `c920fef4995a277c86503539969a3920340179c3`.

## Actual code
- `godot/labs/combat_lab/research04/thien_loi_vfx.gd` — original procedural hierarchical midpoint-displacement electric bolt; multiple time-varying levels, forks, white-hot core / cyan-blue and violet low-opacity halos, short-lived contact crackles, exact positions supplied by mock Lab. Bounded MAX_BRANCHES=6/MAX_SPLINTERS=7, no arbitrary gameplay targets.
- `thien_loi_overlay.gd`: separate additive light-only canvas using V9 native GL Compatibility shader; actor rigs are normal blend and NOT washed out.
- `thien_loi_arena.gd` / `.tscn`: independently selectable variants 1 `Thiên Lôi Giáng Thế` (sky-to-approved-target) and 2 `Lôi Liên` (caster-to-target plus jumps). Four existing rig monsters visible, exactly three permitted visual contacts, fourth excluded. 1280×720. Key Space replay, P pause.
- `godot/tests/labs/combat_lab/research04_thien_loi_contract_test.gd`: test normal source/endpoint and time-varying path, 17 nodes, mock target guard, separate V9 shader layer, deterministic thresholds and no phantom contacts.
- `.github/workflows/vfx19-thien-loi-godot.yml`: isolated Godot 4.7.2 strict import/parse, focused test, actual GUI Xvfb native MP4 for rejected sword vs variants A/B, 12 screenshots per scene, encoded FPS and hash evidence.

## Exact trace and actual ART failures corrected
1. **Initial implementation** `069d2fb0c4d09b48c6efd61a11cc36a96da7f1d2`. Initial new workflow `8ca54c8f` FAILED because it accidentally still referenced `research03_contract_test.gd`, so this was an invalid QA test call, NOT a valid VFX19 PASS. Corrected exact test route at `854c89c5ee335721beab4857fee67d1a76df2409`. [Run #43407684961](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43407684961) scoped PASS on the corrected initial implementation, with genuine first video.
2. **R0 full-frame visual review** at t=1.46s showed main bolt too weak and narrow in both sky and chain; lines looked like an electric wire and contacts lacked weight, despite technical PASS. Reworked the actual anatomy, not just test status.
3. **R1** `78ce395ee508a75678fd61571c9b65a18d84f99c`: brightened white-cyan core and violet atmosphere, added small cloud crown, 2 independently varying lower-power sister channels and more legible branches. [Godot run #43408375617](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43408375617) SUCCESS; observed many **hard rectangular bright patches** at kink joints due to per-segment multiple additive draw_line passes. Marked ART_REWORK_REQUIRED.
4. **R2** `45fda38f67d478bb5a6e6c49a11908c2d667f251`: replaced segmented per-branch drawing with whole-curve `draw_polyline` layered halo, reducing hard segmented squares while preserving the irregular fractal path and dynamic forks. [Exact SHA run #43408915125](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43408915125) **SUCCESS**. Scoped test output `VFX19_THIEN_LOI_FOCUSED_RESULT=PASS failures=0`. Actual native 1280×720 MP4 and PNG frame at 1.46s show smooth continuous connected white-cyan bolt rather than illuminated rectangular chunks.

### Owner-facing video evidence
[GitHub Actions run #43408915125](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43408915125), artifact ID **14028377506**, name `vfx19-thien-loi-45fda38f67d478bb5a6e6c49a11908c2d667f251`. Contains `sky.mp4`, `chain.mp4`, `old_sword.mp4` genuine 1280×720 @ 60fps **encoded/fixed**, each 204 rendered frames. 12 key samples each: 0.24, 0.62, 0.92, 1.10, 1.28, 1.46, 1.60, 1.77, 1.95, 2.15, 2.42, 2.82s, plus full timeline, logs and SHA256 manifest. Local reviewer also assembled A/B side-by-side movie and 4-frame montage from these files; **these are real Godot outputs, NOT ImageGen/mockups**.

## Professional art appraisal (not owner approval)
At native full-size frames, main strike now reads as branching lightning with unmistakable bright core and diffused cyan/violet energy; R2 fixes the unacceptable join squares seen in R1. The chain-jump around 1.77s visibly connects only two nearby allowed mock victims, then decays. However:
- Cast animation is still understated at 0.24–0.92s and contact effect is a brief glow rather than fully polished AAA hit-stop/animation.
- Existing Combat Lab actor rig / simple gravel map are obvious placeholder art; source does not yet demonstrate professional final gameplay unity.
- The animation currently contains considerable low-activity time before and after the highlight, and the sét fragments can look like individual drawn polylines in zoom. It is **better than VFX18 sword family**, not a verified commercial-quality effect.
- Self rubric (tentative): silhouette 4/5, luminous physics 3.8/5, choreography 3.6/5, composition 4/5, contact 3.2/5, fade 4/5, uniqueness 4/5, real crowd performance NOT TESTED. Rework is merited; never call `OWNER_VISUAL_APPROVED` without explicit owner approval.

## QA limitations / safety
Focused Godot **PASS only** with historical uncommitted, disposable CI-checkout summon parser shim. Separate `v63-quyen-doc-matrix` still FAIL on unrelated full-game scope. This is NOT full clean-repo Godot PASS. Windows/Android physical real device and 6v8 / 30v40 stress performance **PENDING USER**; 60FPS MP4 movie encoding does NOT equal actual device FPS.

**This task modified only** `research04/**`, `research04_thien_loi_contract_test.gd`, isolated workflow, docs and PR discussion. Did not write game damage/HP/target/AI/SaveService/cooldown/summon/PvE; no branch/merge. `OWNER_VISUAL_PENDING` • `PVE_INTEGRATION_HOLD` • `ART_REWORK_REQUIRED` for real production finish.
