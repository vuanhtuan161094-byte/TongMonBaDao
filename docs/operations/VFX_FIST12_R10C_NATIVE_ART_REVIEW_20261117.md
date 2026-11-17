# FIST12 R10C — Đoạn Mạch Liên Quyền | 17 November 2026

**Decision state:** `ENGINE_TECH_PASS`, `G3_5_NATIVE_PASS`, `G3_6_MINIMUM_VISIBILITY_PASS`, `G3_7_SEMANTIC_REVIEW_PENDING`, `ART_OWNER_PENDING`, `PVE_HOLD`.

## Exact-SHA evidence — real Godot, not an infographic
- Repo `vuanhtuan161094-byte/TongMonBaDao`, PR #72 Draft, branch `integration/pve-p0-playable-ui-20261103`.
- Exact implementation SHA `e178095b43a9b1f21b77544a821622f0cc9d706a`, [Actions #44107346724](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44107346724) **SUCCESS**. The branch HEAD may move due to other school writers; source SHA is fixed for this proof.
- Godot 4.7.2 Compatibility on Linux Xvfb: strict import, scene parse, standalone moving-target and event-view-only focused test `VFX_FIST12_R10_FOCUSED_RESULT=PASS failures=0`, V4 packet, original RGBA atlas source checks and G3.5 native preflight.
- Native full 1280×720 `fist12-r10-full-native.mp4`, 456 H264 frames / 7.6s, no GIF, no movie stitched from offline illustrations; artifact `vfx-fist12-r10-godot-native-art-review` id `14339446759`.
- 3 G3.5 native screenshots: charge t=0.22, strong finisher peak 0.83 (not beat transition 0.74), selected-target single contact 0.99. Full native movie has 19+ timed screenshots, including independent first/second/third beat at 0.53/0.68/0.83 and continuing mark at 3.60 seconds.

## G3.6 quantitative source-video checks at true 1×
```
FIST12_R10_G36 charge red_energy_pixels=1563 min=110 status=PASS
FIST12_R10_G36 peak red_energy_pixels=17703 min=350 status=PASS
FIST12_R10_G36 contact red_energy_pixels=4096 min=450 status=PASS
FIST12_R10_G36_MINIMUM_VISIBILITY=PASS
```
The fixed source-/scene-specific ROI thresholds are **minimum visibility** checks only; they do NOT prove scene art beauty, semantic correctness, stable frame pacing or physical phone FPS.

## Source provenance, 48 authored alpha frames
- Independent source VFX pages `godot/labs/combat_lab/fist12/assets/r9_sources/f12_r9_{charge,punch1,punch2,punch3,contact,mark}_master.webp.b64` retained unchanged after rejection of R9's COMPOSITION. They are first-party original actor-free separate alpha pages. **R10 material is a DERIVATIVE of R9 originals, not new independently painted R10 source artwork.**
- Adds original first-party 384×384 alpha art `godot/labs/combat_lab/fist03/assets/godfist_master.webp` (illustrated clenched fist previously used in other skill families) as distinctive visual fist at the head of each of the 3 different pose chains; project-owned, no copied Võ Lâm/Kiếm Thế commercial pixels.
- New off-line generator `tools/vfx/generate_fist12_r10.py`, four reproducible true-alpha atlases `r10_charge.png` 8 poses, `r10_punches.png` 24 poses (3 distinct directional 8-pose sequences), `r10_contact.png` 8 poses, `r10_mark.png` 8 loop poses. Atlas 4x columns / 320px frames, generated in CI; not 2D actor rigging or native character body animation.
- Own scene `godot/labs/combat_lab/fist12/r10/doan_mach_lien_quyen_r10.tscn`, original R9 scene/assets/source preserved. FIST13 R7 unchanged.

## Canonical three clocks and risk
- Human ID `tmb.skill.fist.huyet_quyen.active_02.human`; `effect=mark`, `element=nether`, `shape=single_target`, `target_limit=1`, `range=2.8`, `projectile_speed=0`, `cast_time=.45s`, `cooldown=8s`, `duration=6s`, `hit_count` NOT DECLARED.
- LAB-only stage `.00-.45s` charge; `.45-.92s` three cosmetically differentiated qi-fist motions (short horizontal jab, tilted rising hook, heavier third straight); `.92s` one visual mark (NOT 3 hit receipts), `.92-6.92s` six seconds target-following single mark, `6.92-7.22s` fade; movie reset 7.6s.
- Receipt mapping stays `RUNTIME_MAPPING_PENDING`; no actual status, HP, heal, knockback, attack speed, PvE, economy or SaveService writes. Actor remains the pre-existing temporary character sprite; no independently authored frame-by-frame **caster punch animation** or skeletal rig.

## Native 1x art self-review — candid
- **Tụ lực (0.22):** readable compact crimson source at caster hand; does not overwhelm face. 3/5.
- **Quyền 1/2/3 (0.53/0.68/0.83):** visibly different horizontal, rising diagonal, broad finisher with genuine source painted fist heads; 3rd beat much brighter and larger. 3/5 silhouette difference, 3/5 light hierarchy. The overlay can still read as fire-like crimson qi rather than clearly articulated hands at native size: **G3.7 semantic identity is not yet owner-approved**, newly created source master would help.
- **Contact (0.99):** one short lateral local white-red impact near incoming left side of target, shifted below/left of face. 3/5. Actor and enemy remain legible on dark sample map.
- **Persistent mark (3.6):** compact garnet broken meridian around right shoulder/chest, moves with selected foe and does not cover face; no permanent red cloud. 3/5.
- **Limitations:** dark stage only; no bright-map QA, 6v8 battlefield occlusion, real Android physical FPS or GPU memory performance measured. Reusing FIST03 illuminated hand as source may visually overlap FIST11 and FIST13; owner may prefer an independently painted R10-exclusive master and stronger frame-by-frame caster attack.

## Release freeze
Technical and minimum visibility tests PASS only. **Owner visual decision is pending**; this is an **R10C owner-review candidate, NOT an approved game asset**. R9 remains rejected art, FIST13 R7 remains provisional. PR #72 remains Draft; no merge, no rig, no GIF, no changes to Combat V2, SaveService, AI, PvE or V6.3.
