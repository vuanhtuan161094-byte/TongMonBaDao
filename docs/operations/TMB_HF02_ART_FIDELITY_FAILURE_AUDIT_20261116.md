# TMB HF02 — Concept-to-Godot visual fidelity failure audit (16 Nov 2026)

## Scope / evidence
- PR #72 Draft, same existing branch `integration/pve-p0-playable-ui-20261103`, no merge.
- Owner-supplied reference in chat: originally assistant-generated illustrated "Phù Tu – Hỏa Phù" cinematic *concept poster* `a_highly_detailed_game_vfx_showcase_poster_board_f.png`. It has luminous golden/white flame streams, multiple hot runes, articulated energy trails, a giant flame creature, coherent explosion at target and a saturated palette. **This poster is not an actual Godot screenshot or engine movie despite promotional text printed inside it.** Its in-poster HF02 name "Liệt Diệm Phá Ấn" and visually depicted flying projectiles are NOT the canonical mechanic.
- Actual HF02 original ID `tmb.skill.talisman.hoa_phu.active_02.human` / **Liên Diệm Phần Giới**, FIRE/damage, **circle**, radius 2.1, **max 3 targets**, projectile speed **0**. Catalogue immutable.
- Real native R4 Godot evidence: [Actions #43712804172](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43712804172), exact art/CI SHA `2db6dcdee8c6f3f67c4ba1f35c8ee556f9eec922`; full-size 1280×720 MP4, screenshots 0.30, 0.43, 0.70, 0.86, 1.10, 1.28, 1.38, 1.49, 1.62, 1.84, 2.22, 2.75. Tech PASS but the picture shows orange candle-like upright wisps and a modest dim impact; far below the illustrated reference's visual hierarchy.
- Current owner feedback: "càng làm càng xấu" and specifically points to the luminous reference as desired quality. Treat R1-R4 as **ART_REWORK_REQUIRED**; do not label R4 owner-approved or use it as quality template.

## Failure localization (NOT a Godot-version explanation)
| Pipeline step | What was actually done | Why visual quality was lost |
|---|---|---|
| G1 art reference | Generated an elaborate cinematic poster claiming Godot/video-style details | Concept and actual in-engine skill were never matched in a same-scale visual review; depicted invented mechanics too |
| G3 primary art source | `tools/vfx/paint_tal07_lien_diem.py`, `plume_layer`, constructs seven quasi-symmetric plumes from parametric lines and masks | Curves resemble upright candles/wires, not painterly fluid shapes with branching hot cores |
| G3 painted sublayer | Original RGBA fragment only **80×65 px**, enlarged to **~141×153 px**, rotated four times on every lotus cell | Original composition and brush structure disappear; repeated fragment cannot reconstruct full-scale image art |
| G3 frame distinction test | 12 different pixels/frames via random seeds/noise/phase | Unique frame hashes prove bytes differ, **not** new painted poses, continuity or beauty |
| G4 lighting | Native scene uses standard `draw_texture_rect_region` on mostly flat painted raster plus low-alpha radial `_halo` | No independently controlled intensely hot small core, saturated emission and soft roll-off or convincing local scene illumination. More halo alone cannot fix painted material |
| G4 composition | Reference uses subject-scale luminous flames and strong silhouette; native R4 uses relatively small/distant monsters with vertical flames | Skill occupancy, movement rhythm, contact force and actor/background contrast not preserved |
| G5 QC | All 40 frames, RGBA and exact-SHA video PASS; 12 stills reviewed | QA measured build validity/pose variety, not visual match to the reference. Self-rejected art nevertheless advanced to R4 and was handed over |

## Revised preflight — STOP before Godot implementation

**F0: Grounded skill contract.** Read actual catalogue. Poster is a style benchmark, not a license to invent extra flying talismans, AoE radius, dragon attacks, targets, hit counts, status or timestamps.

**F1: High-fidelity original HERO source BEFORE any procedural animation.** Generate or paint the large individual transparent energy pieces at the **actual target game scale or larger**, e.g. central fire-lotus/head, curling tongues, hot-core eruption, local contact and embers. Separate **true painted body** from **independent light**. Do not use a tiny crop of a promotional poster as the dominant material. Never reconstruct painted material as seven script-drawn cylinders.

**F2: Material/palette match (owner observation).** At 1x compare reference's *high-saturation emissive energy*:
- small high-key warm-white/ivory `#FFFBEA` impact core;
- bright yellow `#FFE65C`, saturated fiery orange `#FF961A`, hot coral-red `#FF3F22` and restrained red edge;
- body/shadow uses normal alpha mix; separate narrow *luminous* (additive) accents and a controlled low-opacity bloom/soft-scatter texture. Preserve mixed dark gaps, not blanket brightness or white clipping.
- Keep recognizable contours after reducing image to actual in-game display size. Test on dark and bright maps.

**F3: Genuine keyframe animation, not duplicate-variation.** Draw/author *independent state changes* for charge → lotus shape opens → energy curls → localized hit on moving actor → break into sparks/fade. Mathematical deformation/noise is permitted for secondary jitter, never a substitute for authored primary key poses. Inspect side-by-side contact sheets at full scale and animation continuity.

**F4: 3 still frames as STOP gate BEFORE expensive movie/CI.** Use a provisional Godot LAB 1280×720 capture (0.43 charge, 1.38 maximum fire, 1.49 hit), compare concept's main energy and actor occlusion. If visibly candle-like/dull/tiny/covered/circular HUD, STOP and repair primary art. Do not respond by only increasing scale, halos or adding uniform rays. No owner presentation until this step is passed.

**F5: Native motion and strict QA.** Render full 60fps encoded MP4, capture >=12 phases incl 0.30/0.43/0.70/0.86/1.10/1.28/1.38/1.49/1.62/1.84/2.22/2.75. Inspect temporal continuity, exact moving targets, local contact and 1× readability. Exact-SHA alpha/pose/parse/contract/MP4 PASS is **technical** only. Independent visual check on material, light, shape, contact and source fidelity must each >=4/5 before owner review.

**F6: Owner gate.** Owner review of actual Godot movie, not concept. Until explicit approval: `ART_REWORK_REQUIRED`, `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, `V63_OFF`. This does not retroactively revoke other owner's previously approved Lôi Phù TAL02/TAL03 assets.

## Decision for HF02
- **Keep source/QA in git for evidence; DO NOT promote HF02 R4 as a final VFX.**
- Next HF02 revision should restart at hero-art/source-stage, not patch R4 only via size/glow tweaks.
- The desired reference energy can be recreated visually with independently created assets without copying unlicensed commercial game art. Interpret the poster stylistically only, and preserve the canonical circle/3-target/no-projectile semantics.
- No rig, Codex, new branch, merge, Combat V2, SaveService, economy, AI, PvE or V6.3 changes.
