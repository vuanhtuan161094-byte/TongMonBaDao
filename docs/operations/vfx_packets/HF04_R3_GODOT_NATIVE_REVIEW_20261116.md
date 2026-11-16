# HF04 R3 Chu Tước Hồi Hoàn — true Godot native 1× art review

**Date:** 16 November 2026. **Existing PR #72 Draft:** `integration/pve-p0-playable-ui-20261103`. No merge, new branch, rig, Codex or gameplay edits.

**Canonical:** `tmb.skill.talisman.hoa_phu.active_04.human`, Fire damage, CIRCLE radius **2.35**, range **8.5**, maximum **3** targets, one hit per target, cast **0.50s**, cooldown **13.6s**, `projectile_speed` **0**, persistent duration **0**. Source `godot/data/combat/v63_talisman_combat_catalog.json`. A cosmetic Chu Tước flying along an orbit is **NOT** a gameplay projectile, no extra hits or HP/status events.

## Verified actual render / exact SHAs
- **R1** initial painterly material collage technical PASS but owner-style **INTERNAL ART REJECTED** at native Godot 1× because the shape looked like X-shaped crossing flame strips, overly broad orbit arms occluded three moving monsters. Never claim this generated source poster is a Godot movie.
- **R2** source-art pivot: preserved an original first-party AI-illustrated phoenix cropped to RGB **304×112 WebP** (not game screenshot) at `godot/labs/combat_lab/talisman09/art_sources/hf04_chu_tuoc_original_rgb.webp.b64`, feathered alpha recovered by `tools/vfx/hf04_r1_que_tuoc.py`. Distinct bird head, feathers/wings/torso/tail are now recognizable. Orbit thinned and scene actor readability repaired.
- **R3** retains R2 main bird and makes **ONE** soft, source-painted local-area pulse **BEHIND** moving actors while retaining smaller local hot spots near all three real moving actor render locations.
- **V4 G3.5 three native proof gates:** [Actions #43805491478](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43805491478), exact source SHA `42180480756c7651025a5ca24abf0e205761a5f3`, **SUCCESS** Godot 4.7.2 strict. Artifact **14198092312**, native 1280×720 screenshots at charge **0.30**, peak **1.29**, contact **1.71** and 116-frame native mini MP4; source/atlas hashes, focus moving-target check, fail-closed missing-contact test. Visual self-review: charge centered at caster palm, bird visibly recognizable and separate from flame orbit, target contact does not hide faces.
- **Full exact-SHA Godot movie:** [Actions #43805913523](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43805913523), art/CI SHA `bb681dbbf3f8adeb6bf83053a2e2f3c05e62020c`, **SUCCESS**, artifact **14197654489**. Godot **4.7.2.stable.official.ed1daf0bf**, GL Compatibility, strict import, parse, `VFX_TAL09_FOCUSED_RESULT=PASS failures=0`, native **1280×720 187 encoded frames / 60/1 fixed movie clock** (3.1167 sec) verified by FFprobe. Fixed movie FPS is **not physical Android/Windows measured FPS**. MP4 SHA256 `a00ba4f2d1a81ba5c3fe3368392a60e482072f0ae20bdbcb281c6f1e3975fb09`.
- Full export additionally includes GIF, **15 timed PNG frames** at **0.12, 0.30, 0.44, 0.62, 0.82, 1.04, 1.29, 1.43, 1.55, 1.63, 1.71, 1.82, 2.06, 2.36, 2.84**, original 4 RGBA flipbook atlases, generator bake log, source SHA checksums, focused log, scope manifest.
- Full render source SHA differs from G3.5 because independent CI/workflow and documentation commits followed, but the underlying HF04 hero/source/scene atlases were unchanged between these verified native captures.

## First-party source, art movement and timing integrity
- **Original ImageGen bird** is a first-party illustration generated for Tông Môn Bá Đạo. Only the high-chroma bird pixels are alpha-extracted and displayed in the LAB; no UI/status labels or backdrop from the original presentation are imported. This 304×112 crop has a known source fidelity cap compared with the original full-size painting. Its individual atlas poses are image-derived with per-frame silhouette warp/flutter and separate first-party flame-tail compositions, **NOT** falsely claimed as 16 independently painted complete original bird keyframes.
- Other source: committed Hỏa Phù scroll `talisman06/art_sources/hf01_r5_talisman_master_png.b64`, Hỏa Long `hf01_r5_dragon_master_png.b64`, and luminance-unmatted TMB fire source `talisman07/art_sources/hf02_r5_owner_fire_blast.webp.b64`. No commercial third-party JX/Source VL/Source A art copied. Source art and generator permanent in Git; CI's baked binary asset archive has 30-day retention.
- Four independent flipbooks, all genuine source-colored RGBA and non-empty poses: **charge 12×320×320**, **phoenix 16×512×320**, **flame-return orbit 12×640×340**, **contact 10×256×256**. Used additive-like subtle separate soft light texture only at focal points, not uniform code-drawn circles. Glow/alpha verified on dark battle terrain; **physical bright-map comparison remains NOT_EXECUTED**.
- Three distinct clocks maintained:
  1. **Authority:** .50s cast, `projectile_speed=0`, 13.6s cooldown, cap3 circle damage. Actual Combat V2 receipt timestamps **UNKNOWN / RUNTIME_MAPPING_PENDING**.
  2. **LAB visual choreography:** charge .02–.68, bird .58–2.04, flame return .78–2.24, ONE simulated circle pulse 1.60–1.92 anchored separately to each actor's CURRENT position; fade by 2.55.
  3. **Demo/movie:** 3.12s loop, not skill cast/cooldown/true live hit time.
- All 3 independent monsters use genuine WALK `SpriteFrames`, no rig, their trajectories are non-identical, tested motion between 0.30 and 1.65; cosmetic pulse does not create actual targets or damage.

## Visual self-gate / owner status

Reviewed Godot 1× G3.5 frames and continuous GIF + 15-frame full movie sheet. Internal subjective rubric: recognizable bright original bird **4.3/5**; saturated ember/light material **4.1/5**; charge/return motion and placement **4.0/5**; moving-target contact force and face readability **4.0/5**; fade and afterimage **4.3/5**; distinct Hỏa Phù signature **4.2/5**. These are **internal**, not owner's approval; stable bright-terrain/physical-device performance and live Combat V2 remain untested.

**Terminal stage:** `HF04_R3_DEDICATED_LAB_SOURCE_COMMITTED`, `G3_5_NATIVE_TECH_PASS`, `FULL_NATIVE_GODOT472_TECH_PASS`, `INTERNAL_VISUAL_QA_PASS_OWNER_PENDING`, `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, `V63_OFF`, `PHYSICAL_WINDOWS_ANDROID_QA_PENDING`.

Preserve owner-approved HF02 R6 exact art SHA `b5a29f15` and HF03 R2 exact SHA `ac3b02b1` unchanged. Owner may accept R3 or request art-only rework; no automatic HF05 starts until this decision.
