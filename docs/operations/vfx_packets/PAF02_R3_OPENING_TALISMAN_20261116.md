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


## Exact-SHA Godot R3 result (native technical gate)
- Source SHA: `6be2341f9d397e8b3de8f1903aeee2ac02970539`; [official Actions run #43850865173](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43850865173) **SUCCESS**, artifact `14217302952`.
- Godot 4.7.2 Compatibility: strict import / parse, focused `VFX_PAF02_FOCUSED_RESULT=PASS failures=0`, first-party source/atlas V4 packet and native manifest PASS; 1280×720 native video `132` frames / `2.20` seconds, GIF and charge / peak / moving-contact screenshots. MP4 SHA256 `dfdacb146199186eb3404b3b1e81e3b454c0ca58da2403d95f0ea3efc64bbbca`.
- Byte-for-byte against prior owner-"khá OK" R2 artifact: `paf02_line.webp` SHA256 `a50d6bf73d1b2a7f4806bc46ebe4c353f6c2f75f19a696edd82cf635c5137d98`, `paf02_contact.webp` `6355361de599181bea63cb3655c4f8fe8ab576737defecb5091a60389e636dcd`, `paf02_badge.webp` `f1e7be8d4b19dea0dc59ef35b6d5e48d55114d90922b74bd17a10085d2b5044f` are **UNCHANGED**. Only initial `paf02_charge.webp` now has SHA256 `95e909acfe75... ` (see evidence manifest for complete hash).
- Honest native 1x self-review: formerly flat HUD/玄 card replaced by a recognizable flowing jade-gold talisman during .10–.43s. Three selected moving actors remain visible; new paper visual no hard black rectangular crop in sampled 0.10/0.22/0.28/0.43 frames, and line/contact unchanged at 0.67/0.97. Reused source material from owner-approved PAF01 R6, not presented as original new painting. Small source resolution and edge softness remain an art limitation requiring owner feedback.
- Separate statuses: `PAF02_R3_TECH_PASS / ART_SELF_CANDIDATE / OWNER_VISUAL_PENDING / PVE_HOLD / V63_OFF / PHYSICAL_DEVICE_QA_PENDING`; older PAF01 R6 owner visual approval remains untouched.
