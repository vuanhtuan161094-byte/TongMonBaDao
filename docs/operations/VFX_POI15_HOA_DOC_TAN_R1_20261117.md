# POI15 — Hóa Độc Tán R1: original luminous AOE poison VFX

**Started 17 November 2026.** After owner temporarily accepted POI14 R1B, POI15 is the next skill, **not** a redo of any previously accepted asset. Existing Draft PR #72 same integration branch. No GIF, no rigs, no Codex, no branch/merge, no gameplay modifications.

## G0 immutable catalogue
- `id=tmb.skill.poison.duoc_doc.active_04.human`, Human Dược Độc; `effect=poison`, `element=wood`, `shape=circle`, `radius=2.3 world units`, `target_limit=3`, `range=7`.
- `cast_time=0.6s`, `cooldown=13s`, `projectile_speed=0`, `damage_ratio=0.86`, `power=0.015`, `poison_stacks=1`, `duration=6s`. No declared hit_count; do not invent one. V6.3 OFF, actual Combat V2 receipts not available.
- This is **POISON AREA**, NOT POI14 cleanse nor POI13 heal. Show exactly three independent moving monster recipients within LAB area, fourth walking enemy beyond visual area **must never receive a mark**. Never show a real damage number, actual state application or HP decrement.

## First-party source-preserved RGBA layered animated art
- Generator `tools/vfx/generate_poi15_hoa_doc_tan_r1.py`. Three original true-RGBA flipbook atlases and three kept full-color transparent source PNG masters under `godot/labs/combat_lab/poison15_hoa_doc_tan/r1/assets/`.
- **28 authored alpha poses:** 8 charging jade reagent at caster hand (192x192), 12 widening organic non-solid irregular poison light field (320x320), 8 independent small teal/violet luminous toxin wisps (128x128) on each affected monster. Source RGB stays high saturation under translucent alpha: no black background, square cutout, geometrical HUD circle, hard outline or squirming snake-tail.
- The single circular area has a **soft wavy perimeter** in RGB+alpha source but is not a Godot GUI circle. 2.5D rear field vs marks front/rear on actors, marked monster still visible.

## Timing and target/owner gates
- Native scene `godot/labs/combat_lab/poison15_hoa_doc_tan/r1/hoa_doc_tan.tscn`. The root LAB clock illustrates charge t0-.60, expanding area t.60-1.65 and marking at t1.05; a `1-stack` visual poison mark follows the 3 enemies until **t7.05 (= 1.05+6.00)**, including fade tail, and disappears before t7.20. The fourth monster never receives the visual mark.
- Catalogue radius `2.3` world units is **not automatically converted into pixels**. LAB-only 165px visual radius provides a four-enemy QA fixture. Actual live target resolver and one real status application per hit target are **NOT implemented**.
- G3.5 native 1280×720 Godot 4.7.2 Compatibility at charge `.28`, expansion peak `.84`, contact/three marks `1.20` seconds. Additional duration probes t1.45, 3.95, 6.90, 7.20(s) validate 6-second status and expiry. The 450 encoded frames (7.5 seconds) are a deliberate **full-expiry QA video**, NOT 450 source sprite frames, NOT an Android performance reading.
- V4 packet/assets/evidence exact-SHA; QA import/parse/focused contract stage; 4 mobile WALK fixture, targeted conditions, 3 status screenshots, separate owner visual review.

**Initial gates:** `G3.5_NATIVE_NOT_YET_EXECUTED`, `TECH_QA_PENDING`, `ART_MANUAL_REVIEW_REQUIRED`, `OWNER_VISUAL_PENDING`, `RUNTIME_MAPPING_PENDING`, `PVE_INTEGRATION_HOLD`, `V6.3_OFF`, `PHYSICAL_QA_PENDING`.
