# PAF02 R3 — Opening talisman only (2026-11-16)

Owner feedback: "cái phù có vấn đề r. còn lại khá ok. phù ban đầu đấy" — **ONLY initial casting talisman is rejected**. Preserve existing PAF02 R2 LINE / CONTACT / BADGE, three moving actors and the short-action duration. PAF01 R6 owner-approved art remains unchanged.

## G0 contract
Exact catalogue `tmb.skill.talisman.phong_an_phu.active_02.human`: effect=mark, wind, shape=line, target_limit=3, cast_time=.5s, status_duration=5.5s, cooldown=10.8s, projectile_speed=0, hit_count=1. This LAB never grants a status/damage/projectile. Actual Combat V2 mark receipt: `RUNTIME_MAPPING_PENDING`.

## Source and visual repair
- Historical PAF02 R2 charge `render_hero` drew a large flat blocky 玄 glyph with ring arcs that appeared like a HUD icon at native 1x.
- R3 charge-only uses the project's already approved PAF01 R6 first-party flexible jade-gold talisman master, with **new independent PAF02 curling/shear key poses** and three subdued winding filaments. This is **explicit shared source lineage**; it is not falsely labelled an independent new ImageGen painting. No commercial Source A/JX/VL pixels, rig or generic rectangle.
- New source `tools/vfx/paf02_r3_initial_paper.py`, generator wrapper `tools/vfx/paf02_assets.py`; changes only `paf02_charge.webp` and derived `paf02_thai_huyen_original_master.png`. Existing `wind_line`, `close_seal`, `status_badge` functions unchanged. No scene/GDScript, Combat V2, status, PvE, SaveService or PAF01 source modification.
- The first-party PAF01 R6 art source is durably committed at `godot/labs/combat_lab/talisman11/art_sources/paf01_r6_illustrated_source.webp`. No dependency on expiring GitHub Actions for source.

## Timing and review
- Combat-clock declared cast .5s / debuff 5.5s, actual receipt UNKNOWN. Visual charge .02–.55s, one cosmetic line .48–1.06s, simulated mark contact .78–1.23s, fade1.58s. 2.2s QA clip only. A 30s buff likewise never requires a 30s VFX movie.
- New G3.5 proof: genuine native Godot 4.7.2 / 1280x720 charge .28, peak .67, contact .97 on moving actors; short native movie, ≥12 timestamps, exact-SHA manifest/validator. Review specifically the first .1–.43s, any paper matte, actor visibility and continuity. Technical PASS does NOT imply artist approval.
- Before new run: `R3_G3_5_NOT_EXECUTED / R3_GODOT_NOT_EXECUTED / OWNER_VISUAL_PENDING / PVE_HOLD / PHYSICAL_QA_PENDING`.
