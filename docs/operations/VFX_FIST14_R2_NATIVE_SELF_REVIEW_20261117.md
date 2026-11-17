# FIST14 — Liệp Huyết Truy Đả R2 | native Godot self-review | 17/11/2026

## Owner decisions and boundaries
- FIST12 Đoạn Mạch Liên Quyền R10C remains **OWNER_PROVISIONAL_SELECTED, unchanged**. Source artwork exact SHA `e178095b43a9b1f21b77544a821622f0cc9d706a`; no alteration here.
- FIST13 Huyết Khí Hồi Lưu R7 remains provisional as previously accepted.
- This new separate skill **FIST14** is only an owner-review LAB experiment. No user/owner approval yet, **NO PVE INTEGRATION**. PR #72 Draft, V6.3 OFF, no rig, no GIF, no merge.

## Exact source and Godot provenance
- New first-party original deterministic **raster code-art** (Pillow/numpy): `tools/vfx/generate_fist14_liep_huyet_truy_da.py`. It is **NOT ImageGen or a hand-painted master**. No third-party Võ Lâm/Kiếm Thế sprite pixels or cropped poster frames; no reuse of existing FIST11/12/13/POI/HF artwork.
- Four independently generated 640px true-RGBA representative masters, plus 8 charge / 12 single three-talon lunge / 8 local contact / 8 small three-scratch-mark poses, total 36 original code-derived poses, four 320px atlas sheets `f14_charge/talon/contact/mark.png`. Deterministic output/master hashes in generated provenance JSON and CI artifact.
- LAB GDScript `godot/labs/combat_lab/fist14/liep_huyet_truy_da.gd`, scene `liep_huyet_truy_da.tscn`, focused test `godot/tests/labs/combat_lab/vfx_fist14_contract_test.gd`, packet `docs/operations/vfx_packets/FIST14_R1_LIEP_HUYET_TRUY_DA_V4.json`.
- True Godot **4.7.2 Compatibility 1280×720** G3.5 charge t=.22, peak t=.65 and moving target contact .90, **7.433s native full MP4 (446 frames/60 encoded fps)**, 18 timestamp PNGs including mark hold 3.60s. Exact tested SHA `1fc4ad2811fa0fcaa572b89e0b34c676d46fa416`: [GitHub Actions #44112832093](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44112832093) **SUCCESS**, downloadable native artifact id `14341108126`.

## Catalogue, not made-up mechanics
- ID `tmb.skill.fist.huyet_quyen.active_04.human`; effect **MARK**; element `nether`; single target max=1; range 2.8; radius 0; cast 0.45s, cooldown 8s, projectile speed=0, duration 6s; hit_count NOT DECLARED. No healing, damage/knockback, multi-hit receipt, tracking gameplay or projectile added.
- Isolated LAB visual clock .00–.45 charge; .45–.82 single hunter claw presentation anchored to selected moving enemy (not game projectile); **ONE** LAB-simulated mark .82–6.82; fade 6.82–7.11; reset 7.43. Actual Combat V2 receipt remains `RUNTIME_MAPPING_PENDING`.

## Actual R1→R2 optical fixes
- R1 first native screenshot 0.65 showed opaque maroon rectangular gauntlet/flat claw with blunt prongs; 3.6s persistent mark nearly invisible on target. **R1 ART_SELF_FAIL** despite successful native technical CI [#44111536841](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44111536841).
- R2 new pointed tips, stronger hot ivory core in handrawn-code material, lower central body coverage, three individually separated prongs and persistent scar brighter/larger on shoulder/torso. Original deterministic source remains fully reproducible. 1× screenshots and actual full video manually reviewed.

## G3.5/G3.6 and art truth
- Strict import/parse/focused moving-target contract PASS exact SHA. V4 packet/assets/evidence manifest PASS; G3.6 native red-energy screen-pixel counts: **CHARGE 1083**, **PEAK 5254**, **CONTACT 3272**, all minimum PASS. Additional R2 **status t=3.6s 561 pixels** (minimum 65) PASS. These prove visibility, NOT beauty.
- **Manual R2 native visual rubric**: semantic talon vs arbitrary red stroke **2.5/5** (shape is recognizable 3-pronged slash but still flat), painted material quality **2/5** (procedural matte, not nuanced watercolor), local light hierarchy **3/5**, movement **3/5**, local contact **3/5**, six-second sign legibility **3/5** (visible after R2 but still too small/close to character), originality **3/5**. **G3.7_ART_SELF_REWORK_REQUIRED**; NOT yet owner-ready/approved. Do not infer art PASS from G3.6.
- Remaining: image-generated/illustrated independent original FIST14 **true-alpha master** with fuller organic spectral gauntlet and clearer white-hot contact; avoid reusing FIST12/F13 source or generic orange/red rings. Separate actor's frame-by-frame Quyền Tu animation is not available; no rig/fake attack. Bright-terrain and crowded 6v8 QA and physical Android FPS NOT EXECUTED. Native dark isolated lab alone is insufficient for game integration.

**STATUS: TECHNICAL_PASS / G3.6_MIN_VISIBILITY_PASS / G3.7_ART_SELF_FAIL / OWNER_VISUAL_PENDING / PVE_HOLD / V63_OFF / ANDROID_QA_PENDING.** Keep R2 experiment as reproducible proof, no owner pass.
