# FIST04 — Lôi Đình Chấn Quyền, Bá Quyền Human | Original art-first V1
Date: 2026-11-14 | active PR #72 Draft | Godot 4.7.2 Compatibility | no rig

## G0 Exact skill contract from catalogue, READ ONLY
`tmb.skill.fist.ba_quyen.active_03.human`: active / fist / ba_quyen / Human, effect `damage`, element `fire` (**not electric elemental damage despite name**), shape `circle`, radius 3, target cap 3, cast_time 0.45 s, range 4, projectile_speed 8, cooldown 8. No V6.3 activation or live gameplay edits.

## G1–G3 Original painted source and story
Original first-party ImageGen artwork from 14 Nov 2026 used ONLY as reference material to extract TWO cropped painted RGBA production masters: `thunder_ghost_master.webp` (amber tiger-shaped spirit pressure; no human sprite) and `threefold_impact_master.webp` (ground rupture material). Neither the promotional illustration nor its R7 labels is evidence of Godot QA, approval, FPS or gameplay implementation. Crops cleaned with chroma alpha + feather and stored as tracked original source. No borrowed assets from Source VL/JX, no reused TAL01 sprite pixels.

Storyboard: 0–0.45 gold qi gathers at caster; 0.45–1.04 directional spirit shock release; 1.04–1.18 three staggered *visual-only* recipient contact glints (no gameplay hits invented); 1.04–2.34 ground painting+grit fades; 2.34–2.73 full clear. Human actors in LAB are static scale placeholders, target recoil only moves whole proxy slightly to depict impact for art checking (not character rig or HP writes). No fake additional targets, bonus status or modified Combat V2.

Atlases generated deterministically by `tools/vfx/generate_fist04_lei_dinh_v1.py` from 384×384 RGBA masters: charge 8 (4x2), thunder hero 12 (4x3), impact 12 (4x3), grit 8 (4x2) = 40 poses. Generated output PNGs are in GitHub Actions artifacts and must be rebuilt from tracked sources on a fresh checkout before opening LAB. Godot scene: `res://labs/combat_lab/fist04/lei_dinh_chan_quyen.tscn`; test `res://tests/labs/combat_lab/vfx_fist04_contract_test.gd`. Alpha quality shall be checked on black/bright terrain at 1×. Painterly original sprite is the hero; particles and glints are supplementary only.

## G4–G7 Acceptance/evidence
Official Godot 4.7.2 strict import, parse, focused contract on exact SHA; true 1280×720 movie 180 fixed-frame capture plus GIF and 12 native timecodes. CI PASS is not owner art PASS or measured device FPS. DO NOT merge, branch, rig, use Codex, edit live PvE/Combat V2/SaveService/economy, or other schools' paths. State gates separately: CODE_READY, GODOT_FOCUSED_PENDING, OWNER_VISUAL_PENDING, PVE_INTEGRATION_HOLD, V63_OFF. Explicit owner decision is required for art approval. This new skill doesn't replace accepted FIST03 Thần Quyền V3.
## Exact-SHA Godot review and source repair log - 2026-11-14
- V1 SHA 9df60b19c728e417b75d144244bc26ed016a8efc, Godot Actions #43620925492 SUCCESS. Strict import/parse/focused and authentic 1280x720 movie PASS; but charge was faint and impact was too small at 1x. Not art approved.
- V2 SHA 08a064311a0fb2630bd90b7315a48277977a26d1, Godot Actions #43621374619 SUCCESS. Better art scale and brightness, three contact glints. Actual frames 0.68s/1.15s had straight poster-crop border; ART REWORK REQUIRED.
- V3 repairs that boundary with content-aware left/right/top/bottom feather at the true original artwork, not only atlas cell edges. Rerun Godot exact SHA before claim. Game contract remains damage/fire/circle/radius3/cap3/cast0.45; hits view-only demo and no HP. GATES OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / NO_RIG. Physical FPS unknown.
