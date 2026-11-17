# POI18 — Phụ Cốt Cổ · Tiên A (Liên Tâm) — R1 LAB VFX
Date: 2026-11-17. Draft PR #72 only. No Codex, rig, GIF, gameplay edits, new branch or merge.

## G0 canonical contract
Skill tmb.skill.poison.co_doc.active_01.immortal.a from godot/data/combat/v63_immortal_combat_catalog.json.
Immortal lineage A, effect mark, element wood, shape single_target, target cap 1, range7.8, radius0, cast .43s, cooldown9.6s, projectile_speed8.96 WORLD units/s, duration6.5s. hit_count absent: must not infer a damage receipt. V6.3 tier OFF. Actual runtime mark receipt unknown: RUNTIME_MAPPING_PENDING.

## G1–G3 authored VFX source
First-party transparent RGBA living insect, two unequal luminous gu wings, claw and antenna changes, plus linked jade/gold thorn-heart seal. No copied Source VL/JX pixels or promotional poster crops.
48 poses in 4 independently drawn atlases: gather 8 × 256×256, gu 16 × 320×256, burst 12 × 320×320, linked-heart seal 12 × 256×256; separate true-alpha masters saved and SHA indexed; original generator tools/vfx/generate_poi18_phu_cot_co_tien_a_r1.py.

## THREE CLOCKS, exactly separated
Combat: .43s cast, 9.6s cooldown, 6.5s status, 8.96 world units/s projectile; actual release, hit and mark timestamp UNKNOWN.
LAB VFX: gather 0–.43, reveal .43–.55, moving-target guided gu .55–1.35, simulated LOCAL contact at1.35 (not gameplay hit), heart-thorn burst1.35–2.06, sustained mark1.35–7.85 (exact 6.5s), fade7.85–8.10, loop8.50. The LAB flight is NOT speed8.96 translated into pixels.
QA video: initially 108 encoded frames / 1.8s 1280×720 fixed60 native movie for G3.5; full 8.5s sustained mark clip is not authorized by automatic code checks and awaits visual STOP review.

## G3.5/G4/G5/G6/G7/G8
First source test uses actual Godot 4.7.2 GL Compatibility charge t.21 / peak t.98 / contact t1.48 frames, 14 timed checkpoints on independently walking monster, separate moving decoy unmarked. Shared V4 packet validates source, moving-target test marker, real native movie and exact SHA; machine checks establish only technical structural evidence.
Manual 1× checks needed: distinct flutter/antenna silhouette at peak, clean alpha/no black square, visible gold/jade contact without covering monster, heart mark at chest on moving creature, repeat and expiry after 6.5s. Failure stops before full G5. No auto art PASS.
Initial gate: G3.5 NOT_EXECUTED before CI; G5 FULL NOT_EXECUTED; owner VISUAL_PENDING; PvE HOLD; physical Windows/Android PENDING. Preserve POI17 accepted-tentative and all previously owner-approved assets.
