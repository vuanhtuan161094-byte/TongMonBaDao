# POI14 — Nghịch Độc Phản Chế R1: luminous clean extraction (not heal)

17 Nov 2026. Original art on existing Tông Môn Bá Đạo PR #72 Draft, same integration branch. POI13 R2 was **owner provisionally accepted**, frozen pending optional polish. This is the *next separate poison skill*, no redo.

## Catalogue and prohibited invented mechanics

- ID `tmb.skill.poison.duoc_doc.active_03.human`, Dược Độc, Nhân giới.
- **effect=cleanse**, element wood, shape single_target, target_limit 1, `range=6.5`, `cast_time=0.55`, `cooldown=18`, `projectile_speed=0`, `duration=0`, `damage_ratio=0.05` purely as catalogued metadata; `hit_count` undeclared.
- This is **not POI13's heal**, and does not spawn an attacking projectile, enemy poison application, lasting status icon/shield, fake healing number or HP receipt. No actual real cleanse of simulated poison states: existing Combat V2/SaveService/PvE/V6.3 remain untouched.

## Original artwork — true alpha, energy-first

`tools/vfx/generate_poi14_cleanse_r1.py` paints original floating-point full-RGB transparent source, retaining RGB vividness even where alpha low. No GIF, no rigs and no game pixel extraction. Three atlas textures plus three kept PNG source keyposes under `godot/labs/combat_lab/poison14_cleanse/r1/assets/`:

1. Charge: 8 × 192² RGB+alpha frames. Icy-silver and green concentrated quang khí above caster's hand.
2. Sever: 12 × 256² RGB+alpha frames. A short horizontal cyan-white cleansing slash slices upward through a soft jade field; **9 separate translucent violet contaminant wisps visibly leave the moving ally**, fading rather than accumulating. Rear and front compositing separated around the approved actor sprite; no hard leaf/heart/ring icon.
3. Purge: 10 × 256² RGBA frames. Purple residual vapor dissolves upwards, leaving tiny aqua/gold/white motes and no sustained status.

30 independently authored pose frames vs movie 120 encoded frames; this is nonrigged 2D source-painted original raster. Impact/cleanse anchored on single **moving allied disciple**, while a separate enemy walks in the scene but receives no VFX.

## Godot V4 and three-clock QA

Scene `godot/labs/combat_lab/poison14_cleanse/r1/nghich_doc_phan_che.tscn` and focused test `godot/tests/labs/combat_lab/vfx_poi14_cleanse_r1_contract_test.gd` run Godot 4.7.2 Compatibility. Real native 1280×720 MP4 attack visual 120 frames at fixed encoded FPS60, G3.5 true screenshots charge t0.28, cleanse peak t0.82, purge/contact t1.20 on moving ally with independent walking enemy. 14 timeline probes, V4 packet/assets/evidence exact SHA, retained RGBA source/manifest required.

The visual demo timing is charge0–.55, extraction .55–.98, purge .98–1.56, idle1.56–1.9, **not 18-second lifecycle nor real cleanse receipt**. Native video FPS does not prove Android runtime FPS.

**Before evidence:** `G3.5_NOT_EXECUTED`, `TECH_QA_PENDING`, `ART_MANUAL_REVIEW_REQUIRED`, `OWNER_VISUAL_PENDING`, `RUNTIME_MAPPING_PENDING`, `PVE_HOLD`, `V63_OFF`, `PHYSICAL_QA_PENDING`. Never auto-approve art from CI or alter previously accepted source.
