# PAF01 R4 — talisman paper only, R3 wind and moving mark preserved

16 Nov 2026 / Tông Môn Bá Đạo / PR #72 Draft / isolated talisman11 LAB.

Owner: PAF01 R3 provisionally accepted EXCEPT ugly Phong An paper. R4 reauthors only paper. Does not build PAF02.

## What changed
- New source tools/vfx/paf01_r4_paper.py paints 4 distinct first-party 480x560 RGBA parchment frames at 3x antialiasing with material grain, variable gilded edges, traditional brush 風, delicate filigree, cyan-gold illumination.
- R4 supersedes the 96x132 fire-derived paper; no longer samples the miniature original HF01 paper. The source generator and variant masters are reproducible. Historical HF01 master stays in existing packet for provenance compatibility but is NOT USED in R4.
- Existing streamer() broad R3 wind fan and its target anchor, original_mark(), contact(), mark() and Godot LAB scene, actor WALK motion, state-clock and alpha fades are unchanged. Only the cosmetic 4-pose paper input in charge/stream atlases is replaced.
- Assets keep existing atlas dimensions and paths. No original commercial JX/Source A/VL pixels, no rig.

## Three-clock contract (read-only)
- Catalogue: tmb.skill.talisman.phong_an_phu.active_01.human; wind, mark, one target, 0.5s cast, 6.0s duration, speed0/no gameplay projectile, cooldown9.4s.
- Runtime mark receipt: RUNTIME_MAPPING_PENDING; view-only.
- LAB wind .51 to 1.12s; simulated mark receipt1.15, expiry7.15, fade7.51; movie loop8.00 is not gameplay or physical FPS.

## Required independent gates
- Before new exact-SHA run: G3.5 and QA R4 NOT_EXECUTED. R3 technical SUCCESS does not prove R4.
- R4 preflight must bake paper, validate packet/assets, run Godot 4.7.2 strict import/parse/focused and export genuine 1280x720 charge .30s / peak .84s / moving-target contact 1.28s screenshots plus exact-SHA manifest.
- Manually judge 1x material, glyph legibility, paper silhouette, bright/dark terrain, 4-pose motion. If visually icon-like, keep ART_REWORK and revise, do not claim beautiful.
- Full native 8-second movie and final visual score are a separate gate. OWNER_R4_VISUAL_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_QA_PENDING.

## After PAF01 art review
PAF02 Thái Huyền Khép Ấn must remain a NEW independent skill, not three copies of PAF01: mark/line/target cap3/cast .5s/sustain5.5s/speed0.
