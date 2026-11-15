# VFX POI07 R7 — Xuyên Cốt Độc Châm — first-party painted sprite remake

Date: 2026-11-15 · PR #72 Draft · isolated Combat Lab only · no Codex, rig, branch or merge.

## Owner direction and canonical gameplay authority
Owner rejected POI07 R5 / POI08 R2 visual quality on 2026-11-15: one truly different original set of sprites per skill, not recolored procedural lines; remake POI07 first and do not switch skills before art approval. This R7 candidate preserves separate R5 and R6 for regression comparison, never claims prior art approval.

Exact Human catalogue: `tmb.skill.poison.doc_cham.active_01.human` / Độc Tu – Độc Châm – active_01; `damage`, `nether`, `single_target`, cap 1, radius 0, range 7.5, cast 0.45 seconds, projectile_speed 8, cooldown 9, poison_stacks **0**. These are **READ-ONLY** Lab metadata: no fake DoT, damage number, new status, target, HP or save.

## Source provenance (not an in-game screenshot)
Original source is a Tông Môn Bá Đạo first-party *image-generated concept POSTER*, created in the user project conversation, `a_highly_detailed_game_vfx_showcase_poster_composi.png`, SHA256 `4d762c065c3fdf51542d35e37405088d0b369ac13710c0528a601a013edc9198`. This poster is **not** a Godot render or a distribution-ready asset, and its embedded text/damage numbers/characters must **not** be baked as game VFX. It contains no third-party imported game pixels.

Isolated *original painted light pixels*, independently color-keyed/matted into RGBA and stored as source masters:
- Hero crop `(566,167,1054,275)` → `godot/labs/combat_lab/poison07/r7_painted/assets/master/needle_painted_source.webp` SHA256 `2b7a41c2719eb7441b3ca552ecf46bd4c0788fb5a9351f9f5ebb7da87611cf1f`. Contains only original violet-jade spear light, no target or UI.
- Palm crop `(410,108,552,338)` → `godot/labs/combat_lab/poison07/r7_painted/assets/master/palm_painted_source.webp` SHA256 `357fcbe0ff458b1396da37a3668011728e0b51843c13becb9bcfc60138bfe19c`. Color-keyed / outer alpha masked to remove the caster body and background; check over light-gray as well as dark terrain.

All mastered pixels are first-party painted-source raster, not code-redrawn geometry, no Source A/JX/Võ Lâm asset copy. The files are **original RGBA WebP source masters, not spritesheets masquerading as a screenshot**.

## Original frame-by-frame export and budget
`tools/vfx/generate_poi07_r7_painted.py` animates exact painted source pixels with individually changing nonrigid row-displacement, alpha/scale, crystal flight and layered source-tip contact. No character rig or static SVG hero.
- `painted_needle_r7_12.png`: 12 poses, 4x3 cells of 384x128, atlas 1536x384.
- `painted_charge_r7_10.png`: 10 poses, 4x3 cells of 224x224, atlas 896x672 (last two cells empty).
- `painted_puncture_r7_12.png`: 12 poses, 4x3 cells of 224x224, atlas 896x672.
- **34/34 distinct RGBA frames**, fully transparent per-cell edge gutters; three texture atlases **7,176,192 raw RGBA8 bytes = 6.844 MiB**, under local 8 MiB per-skill test budget. Source masters reside in art packet but are not runtime preloaded by the isolated scene. Actual Android VRAM/residency/draw calls remain unmeasured.
- No texture reuse from POI08, R5 or R6; previous sprite packs remain intact for independent regression.

## Isolated Godot timeline (1280×720, GL Compatibility)
Dedicated Lab `res://labs/combat_lab/poison07/r7_painted/xuyen_cot_doc_cham_r7.tscn`:
0.00–0.45 original painted palm charge; 0.45–1.39 distinct crystal spear alpha flipbook traveling **strictly straight** from palm (342,427) to ONE chest (960,471); 1.39–1.87 local bright puncture; 1.87–2.34 dissolve; 2.34–2.95 idle. 1x actual approved Stage A actor texture, original R5 scene never mutated. Painted impact under/over actor locally and *does not imply an extra hit*. 60fps fixed recording clock is not device performance.

## QA acceptance gate
`.github/workflows/vfx-poi-07-r7-painted-native.yml` pins official Godot 4.7.2 SHA256. Stages: bake from tracked masters, assert alpha + frame distinction + texture budget; restore Stage A actor; strict import, script parse, focused contract; genuine Godot H264 1280×720 177-frame movie, GIF and 14 stills; guarded fast-forward of binaries to the **same** PR branch and exact-SHA redispatch. All binaries and logs published as artifact.

Statuses must be separately asserted: `ART_CANDIDATE_R7`; `OWNER_VISUAL_PENDING` until owner sees actual video; `PVE_INTEGRATION_HOLD`, `V63_OFF`, `PHYSICAL_WINDOWS_ANDROID_QA_PENDING`. Do not proceed to POI08 while R7 art gate is rejected or pending. R7 does not change Combat V2, SaveService, economy, AI or live PvE.
