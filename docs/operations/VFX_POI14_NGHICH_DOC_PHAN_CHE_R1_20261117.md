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

## R1B result — exact-SHA Godot technical PASS, human art review pending (2026-11-17)

- **First source QA R1** succeeded at GitHub Actions [#43996802324](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43996802324), but the manual self-review of native screenshots found the violet extracted impurity and final sparkle too faint at 1×. This was an **ART REWORK** issue, NOT a basic technical block. Do not use the older R1 media as art acceptance proof.
- **Corrected exact-source R1B:** source commit `a76891233bc5bbb8554108a53b69704006b48b02`, [GitHub Actions #43997288745](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43997288745) **SUCCESS**, artifact #14289698932. Tightened blue-white cleansing slash and increased the partially transparent **outward-drifting PURPLE** impurity contrast without changing the original gameplay contract or source shape. The original Python paint generator, source atlas and retained middle source poses are durable on the same PR.
- Godot **4.7.2**, `VFX_V4_PACKET_TECHNICAL_PASS`, `VFX_V4_ASSETS_TECHNICAL_PASS`, `VFX_V4_EVIDENCE_TECHNICAL_PASS`, strict parse/import/focused `POI14_CLEANSE_R1_RESULT=PASS failures=0`. Native **1280×720 movie 2.0s / 120 encoded frames @60 video FPS**, three actual in-engine screenshots `charge=.28s`, `peak=.82s`, `contact/purge=1.20s` on one moving ally and a separate walking monster, with 14 more checkpoints and SHA-256 source/evidence manifest.
- Original 3 true RGBA atlas images: 8+12+10 **authored poses (30)** and three original retained RGBA key-master PNGs. Atlas raw RGBA8 7,471,104 bytes, before compression/texture residency/overdraw. Native MP4 is not native performance FPS.
- **Manual art self-review:** R1B has a clearer pale cyan cutting line and more readable violet contamination leaving the ally; no rigid leaf drawing or GIF-cutout. At full 1280×720 overview it is still a relatively compact/light effect, and may need further aesthetic refinement if owner expects high-contrast Võ Lâm/Kiếm Thế-grade visuals. **DO NOT call this owner-approved.**
- Gates: `V4_G35_NATIVE_TECH_PASS_R1B`, `TRUE_RGBA_SOURCE_AND_MASTERS_COMMITTED`, `ART_CANDIDATE_OWNER_REVIEW`, `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, `V6.3_OFF`, `PHYSICAL_QA_PENDING`. No invented real poison cleanse receipt; the live skill catalogue and Combat V2 not modified. No merge/rig/Codex/GIF.


## Owner decision — 17/11/2026: R1B TEMPORARILY ACCEPTED

After viewing the true Godot R1B, owner stated “ok tạm đc. tiếp skill tiép theo”. **Freeze current R1B assets and native proof as a provisionally usable art candidate, not final visual approval.** Continue directly to POI15 Hóa Độc Tán; do not redo POI14 now. Keep `OWNER_PROVISIONAL_ACCEPTED_NOT_FINAL`, `POLISH_BACKLOG_OPEN`, `V6.3_OFF`, `PVE_INTEGRATION_HOLD`, `PHYSICAL_QA_PENDING`. Technical Godot acceptance from its exact SHA is not a PvE or art release.
