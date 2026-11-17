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


## Real Godot R1 exact-SHA technical result — 17 November 2026

- **PASS technical (NOT art approval):** commit `65716b74fd8cfeb9f66ed717d0e18265ca59e634`, [GitHub Actions #43999000999](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43999000999), exact artifact **#14292070078** `poi15-r1-poison-native-65716b74fd8cfeb9f66ed717d0e18265ca59e634`. Strict Godot 4.7.2 import/parse/focused `POI15_HOA_DOC_TAN_R1_RESULT=PASS failures=0`, packet/assets/evidence V4 stage PASS, all workflow steps success.
- **Native media proof:** **1280×720, 450 recorded 60fps frames, 7.5s native MP4** (not 450 authored sprite poses or measured Android runtime FPS); real screen snapshots charge0.28, expanding-field peak0.84, contact1.20; independent on-screen mark status snapshots t1.50,3.95,6.90 and expired7.20, plus 15 timeline captures and SHA256 file manifest.
- **Original durable source:** first-party code `tools/vfx/generate_poi15_hoa_doc_tan_r1.py`, **28 original RGBA source poses** (8 charge/12 field/8 status) + 3 real original alpha atlas PNG and middle-pose master sources persisted in PR #72 at CI follow-up commit. The source dimensions are 192², 320², 128² and original palette jade/aqua/purple. No GIF, rigs, branch creation or reused commercial pixels.
- **Visual target contract:** 4 genuinely WALK-animated enemies, 3 within the **LAB-only visual circular area** and fourth outside; `poison_stacks=1` and `duration=6s` from t1.05 to t7.05, mark disappears by t7.20. Visual checks plus focused test demonstrate timing and target fixtures only. **No real damage, poisoned-state application, real Combat V2 hit receipt or actual live area-to-pixel mapping**, no PVE. No unverified Android fps claims.
- **Self-art review:** soft green poison field with violet accents is translucent and does not form a black rectangle. However at 1280×720 full-screen display the three individual status wisps are rather subtle and may need bolder selective luminance/contrast on owner request. **Art not finally approved**; this R1 is an OWNER_VISUAL_PENDING candidate, not owner-approved and not live-ready.
- **Gates:** `TECH_GODOT_V4_G35_EXACT_SHA_PASS`, `ART_SELF_REVIEW_LIMITATIONS_RECORDED`, `OWNER_VISUAL_PENDING`, `RUNTIME_MAPPING_PENDING`, `PVE_HOLD`, `V63_OFF`, `PHYSICAL_QA_PENDING`. Prior POI14 R1B and POI13 R2 remain temporarily approved and not modified.


## R1B focused 1× mark-legibility polish — 17/11/2026

Manual review of real R1 native 1280×720 at t1.2 vs t3.95 showed area toxic wave clearly but independent target status wisps were nearly invisible on 1×. R1B increases **only the mark** brightness and slight displayed footprint, preserving its genuine true-alpha translucency, three targets, no fourth mark, exact 6-second fade, base field and charge, original generator-based sprite master workflow. Requires fresh exact-SHA Godot Actions test and native media review. **Not owner approved**.


## R1B native exact-SHA technical QA — 17 November 2026

After 1× manual comparison of R1 native screenshots, the status marks on three moving monsters were too faint. R1B improved **only the 8-pose per-monster status atlas translucency/luminance and its on-screen scale/alpha**, preserving all 3 targets, the separate unmarked fourth, the 6.00s status duration, 2.3 world-unit area catalogue and original green-violet expanding field without extra overdraw. R1 media remains as historical QA only, NOT evidence for R1B.

- **Immutable R1B tested source:** `1b40811248fcaca9b33a5e4cbc35e8b03e2ca9b5`, [GitHub Actions #43999563772](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43999563772) **SUCCESS**, artifact **#14292200693**, `poi15-r1-poison-native-1b40811248fcaca9b33a5e4cbc35e8b03e2ca9b5`.
- Original R1B true RGBA 3 atlas/source master PNG files were saved on existing PR branch automatically via same CI; no new branch/merge. Source generator retained; this was **not GIF-based** and not actual PvE integration.
- Godot 4.7.2 Compatibility: V4 packet/assets/evidence technical PASS, strict import/parse/focused `POI15_HOA_DOC_TAN_R1_RESULT=PASS failures=0`, real **1280x720 native MP4 7.5sec 450 encoded 60fps frames**, and actual Godot screenshots at t0.28 charge, t0.84 area peak, t1.20 three enemy marks, t3.95 status mid, t6.90 pre-expiry, t7.20 clean expiry. Test verifies moving enemies and fourth unaffected and 6-second LAB-only status duration. FPS recording does not imply Android performance.
- **1× manual source-vs-native visual check:** R1B now has brighter individual poison wisps legible on all three enemies; diffuse field has soft jade-green and purple energy with genuine alpha, no hard UI disc. Fourth outside target area receives no visible mark. The skill is clearly an area POISON event distinct from earlier POI13 HEAL and POI14 CLEANSE. This still does NOT prove AAA/JX-grade visual acceptance, and users may request refined artistic texture/motion.
- **Current gates:** `TECH_G3.5_R1B_PASS`, `ART_CANDIDATE_OWNER_VISUAL_PENDING`, `RUNTIME_MAPPING_PENDING`, `PVE_HOLD`, `V6.3_OFF`, `PHYSICAL_QA_PENDING`. There is **no Combat V2 damage/status receipt**, no invented extra target or DoT tick in Godot Lab.
