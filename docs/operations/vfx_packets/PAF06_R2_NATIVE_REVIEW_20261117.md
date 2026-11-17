# PAF06 – Tĩnh Giới Tĩnh Tâm R2: Native Godot technical PASS, art owner pending

Date 2026-11-17. Draft PR #72 branch `integration/pve-p0-playable-ui-20261103`. PAF05 R5E remains provisionally accepted with **charge/tụ lực art debt** in `PAF05_R5E_OWNER_PROVISIONAL_CHARGE_DEBT_20261117.md`; no approved PAF05 asset was modified.

## G0 – canonical passive contract

Exact ID: `tmb.skill.talisman.phong_an_phu.passive_01.human`, wind, passive_always_on, shape single_target, target_limit1 (metadata), cast_time=0, cooldown=0, duration=0, damage_ratio=0, radius=0, range=0, projectile_speed=0, passive.cooldown_recovery_factor=0.015 candidate. The catalogue's generic hit_count=1 is **not a passive damage/hit receipt**. R2 does NOT simulate a cast, contact, projectile, enemy target status, cooldown receipt or actual passive stat modification.

Three clocks: canonical passive continuously enabled when equipped; art has continuous 3.0s loop of quiet light (24 transparent key poses blended at 60fps); demo samples 4.2s (252 fixed-fps encoded frames) to inspect at least one loop seam. Normal cast/impact G3.5 labels are **NOT_APPLICABLE_BY_CONTRACT**. Three source-native visual stages are calm .42s, flow 1.32s, exhale 2.64s.

## Original generated source and Godot runtime

- `tools/vfx/paint_paf06_tinh_gioi.py`: original first-party Pillow-based painting, no copyrighted commercial sprites, no font files. This generator produces `godot/labs/combat_lab/talisman16/art_sources/` PNG masters + `assets/` WebP RGBA animation atlases. 24 authored morphing source poses each for BACK/FRONT/HEART, 72 total frame cells, 320x320 pixels, atlas 6x4.
- `godot/labs/combat_lab/talisman16/tinh_gioi_tinh_tam_r1.gd` + `.tscn`: view-only genuine Godot native render. Interpolates adjacent independent RGBA poses; no global warped image, no rigging. Includes real CPUParticles2D for quiet motes. Actor unchanged.
- `godot/labs/combat_lab/talisman16/tinh_gioi_tinh_tam_r1_off.tscn`: identical camera/scenery but passive disabled for honest pixel delta.
- `tools/qa/check_paf06_passive.py` and `godot/tests/labs/combat_lab/vfx_paf06_r1_contract_test.gd`: passive-only contract, no fabricated hit, assets, loop and native on/off QA.
- `docs/operations/vfx_packets/PAF06_R1_PASSIVE_CUE_PACKET.json`: explicit passive visual packet. Shared V4 CAST validator requires charge/peak/moving-contact, which are inapplicable to a continuous passive; use the skill-specific **fail-closed passive QA**, not a fake cast/mark.

## Exact-SHA technical result

R1 `9634dd4662f3ce4e83a04fc42f74100ccc8d0747`: [native workflow #44075038350](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44075038350) SUCCESS. R1 native 1x appeared too similar to two upright shield strips; therefore self-rejected as ideal art.

**R2 source SHA `478a650109eeaf7087a3b654482320e29adeced0`**: [native workflow #44075693506](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44075693506) COMPLETED SUCCESS. Asset alpha/source hashes, official Godot 4.7.2 strict import, focused script with PASS marker, true 1280x720 native 252 frames / 4.2s MP4, 5 phase PNGs and 96-frame passive-OFF control all succeed. Exact same-clock R2 ON vs OFF native screenshot changed **1,512 pixels** above the `24/255` visual-delta threshold in 1x caster ROI (x485:773, y313:575) — evidence of rendered presence, **not evidence of beauty**. Original masters and atlases archived in 30-day Actions artifact `vfx-paf06-passive-native-478a6501...`, reproducible from git generator.

## Manual 1x art self-review

R2 no longer has two upright shielding wings: four nonuniform jade streams converge toward the center and a short strand exhales upward; the gold talisman at chest is intentionally small. It reads as a passive aura and doesn't fake combat targeting, but its 1x rendered silk still looks somewhat like narrow turquoise wedges, with insufficient original painterly depth and a weak luminous central symbol.

Self-assessment: mechanic truth 5/5, readable presence 4/5, layer separation 4/5, distinctive silhouette **3/5**, material 3/5, natural motion 3/5, non-occlusion 4/5. Therefore **technical PASS, ART_SELF_REWORK_REQUIRED, OWNER_VISUAL_PENDING**. Owner decides whether provisional use is acceptable; do not auto-promote to ART_APPROVED or silently move on. R2 is a legitimate Godot-native test, not final release-ready VFX.

No Combat V2, HP, target selection, SaveService, AI, economy, PvE, V6.3 enable, branches or merges were changed. Physical Android/Windows FPS and crowded battle performance PENDING.
