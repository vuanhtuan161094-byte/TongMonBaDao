# HF03 Hỏa Tâm Ngưng Phù R2 — actual Godot 4.7.2 native visual review

**Date:** 2026-11-16. Existing PR #72 Draft, branch `integration/pve-p0-playable-ui-20261103`. **Skill:** `tmb.skill.talisman.hoa_phu.active_03.human`. Canonical FIRE `single_target`, cap1, one hit, cast0.50s, cooldown12.2s, range8.5, projectile_speed9, duration0; catalogue only, V6.3 stays OFF.

## Verified exact-SHA evidence
- **G3.5 V4 three real Godot 1280×720 native charge/flight/contact screenshots:** run [#43800461891](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43800461891), exact R2 packet/content SHA `825c0f37894de88163f8475b03984262150860b5`, **SUCCESS**. Three frame indices from 96-frame preflight: .30 charge, 1.05 travel, 1.42 target-local contact, moving WALK monster, source/manifest and negative missing-contact fail-closed proof. Artifact ID `14196077876`. R1 predecessor was technically PASS but visually had a weak hand channel; R2 made painted charge more visible.
- **FULL exact-SHA native movie + 15 stills:** [Actions #43800803981](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43800803981) **SUCCESS**, source SHA `ac3b02b1aa6c0d7e0c5dd7e418c59c4dc52a0bb4`, artifact ID `14195924457`, `vfx-tal08-ac3b02b1aa6c0d7e0c5dd7e418c59c4dc52a0bb4`. Godot **4.7.2.stable.official**, GL Compatibility, strict import/parse and focused result `VFX_TAL08_FOCUSED_RESULT=PASS failures=0`. Native movie **1280×720**, **171 encoded frames**, fixed movie 60/1 FPS, **2.85 seconds**, MP4 + GIF + 15 timestamped PNG + original 3 alpha atlases and SHA256 manifests.
- **CI technical PASS != owner visual approval**. No physical FPS test on Windows/Android; no integration.
- The exact SHA is the evidence source, later documentation commits do not change this tested art snapshot. Parent approval HF02 R6 stays at `b5a29f1504078a0e66acc9c79306dc86f5f28463`.

## Three clocks and authority
1. **Catalogue:** cast .50s; projectile speed 9 world units per second; one eligible enemy, one damage receipt maximum; cooldown12.2; no duration/DoT.
2. **LAB-only visual:** charge .02–.62, one painted paper fire-heart projectile travels .52–1.30 toward the **current position** of a preselected real animated WALK monster, one local fire hit starts1.30, fades1.81, ash ends2.36. No target switching, AI, real HP/damage, status or extra hits. Visual schedule cannot be equated with real projectile arrival or actual Combat V2 receipt. **RUNTIME_MAPPING_PENDING**.
3. **QA-only movie:** exactly 2.85s loop, not cooldown/cast time or device performance.

## Source art and G3.5 1× appearance
- `tools/vfx/hf03_r1_fire_heart.py` composes a **distinct single compact Hỏa Tâm projectile** using only first-party repo art masters `talisman06/art_sources/hf01_r5_talisman_master_png.b64` (gold-red paper), `hf01_r5_dragon_master_png.b64` (Hỏa Long) and `talisman07/art_sources/hf02_r5_owner_fire_blast.webp.b64` (original TMB luminous fire). None of the HF02 R6 master, scene, generator, or issued art SHA were modified to make HF03. These are derived image recompositions, **not 38 independent hand-painted originals**, and still require owner judgment at 1×.
- Three **R2 original-composed alpha flipbook atlases** generated before import, uploaded by GitHub Actions rather than falsely represented as binary files tracked by source control: 12 charge poses 320×320; 16 single flying-fire-heart poses 320×192; 10 target-local contact poses 320×256.
- Inspected actual Godot stills at .12, .25, **.30**, .43, .54, .70, .86, **1.05**, 1.17, 1.26, 1.34, **1.42**, 1.63, 1.80, 2.14. At gameplay 1×, the R2 charge was substantially brighter than R1, the paper head is legible during the flight, and the impact follows the moving target while preserving the monster face. No rectangular dark matte visible on reviewed frames; the effect ends cleanly.
- Internal visual estimate only (NOT owner's decision): shape4/5, pure material/color4/5, motion4/5, impact4/5, fade4/5, identity4/5, 1× readability4/5; efficiency/device NOT_MEASURED. Saturation and painted complexity remain below the highly cinematic owner concept reference, so avoid overclaiming parity.
- Rejected visual directions: generic rotating HUD lines, seven yellow candles, a fake AoE under one target, extra projectile hits, duplicated actor/rig. None added.

## Terminal scoped status
`HF03_DEDICATED_LAB_COMPLETE / V4_G3_5_TECH_PASS / FULL_GODOT472_MOVIE_TECH_PASS / OWNER_VISUAL_PENDING / RUNTIME_MAPPING_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_WINDOWS_ANDROID_QA_PENDING`.

No Codex, skeletal rig, new branch, merge, Combat V2, SaveService, economic/AI, PvE or V6.3 changes. Further revisions are art-only and require the owner's actual R2 video feedback.
