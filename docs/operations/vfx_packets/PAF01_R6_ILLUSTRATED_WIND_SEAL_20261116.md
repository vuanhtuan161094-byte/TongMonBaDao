# PAF01 R6 — illustrated silk wind seal (paper-only candidate)

Live user decision 16 Nov: reject R5 talisman despite R5 technical PASS, preserve accepted wind transport, moving 風 mark and fade. The owner wants a real engine VFX rather than another PDF/art-direction explanation.

## R6 art and permanent provenance
- New first-party generated xianxia **illustration**, not the rejected code-painted R4/R5 paper. Material: curved thin jade silk-paper, woven/speckled pigment, gilded hand-painted head, jade hanging bead, live tassel and uneven pointed tip. Traditional 風 is pictorial, not UI font stamped on a rectangle.
- `godot/labs/combat_lab/talisman11/art_sources/paf01_r6_illustrated_source.webp`: RGBA 180x216 cutout with a matte derived from original generated poster. Asset is binary committed to PR #72 and must remain in repo; it is a crop of a larger first-party concept, not a commissioned full-resolution isolated character illustration. Upscaling may create a fidelity limitation.
- `tools/vfx/paf01_r6_illustrated_paper.py`: source-to-16 elastic silhouette poses, not skeletal rigging. Caster charge uses 12, moving optical trace uses 16; R3 wind fan function, track anchor, target contact/mark glyph/fade functions unchanged.

## Contract / three clocks
|Clock|Authority|Timing|
|---|---|---|
|Combat|catalogue only; no actual mark receipt|wind mark single target; cast .50s; status 6.0s; cooldown 9.4s; speed 0|
|VFX LAB|simulated view-only|charge .02-.60; wind .51-1.12; demonstration mark receipt 1.15; one moving target marker sustain until 7.15; fade 7.51|
|Movie|QA only|8-second fixed 60fps native capture, not gameplay cast/cooldown/device FPS|

## G3.5 and final gates
- G3.5 requires exact new SHA technical validator + true native Godot 1280x720 screenshots t=.30/.84/1.28s, moving monster, actual alpha and viewport scale. **Do not declare success from source picture**.
- Inspect paper on bright/dark background at 1x. Check alpha halo, left edge, excessive scale, motion pops; if ugly, self FAIL and do not call owner approved.
- After preflight passes visually, inspect native 8s 480-frame movie and >=12 checkpoints, 風 mark tracking and fade. Old R5 tech success is historical only.
- Owner art PENDING; PvE and V6.3 OFF; Windows/Android physical QA PENDING; no Codex, rig, new branch, merge, Combat V2 or SaveService edits.

## R6 actual exact-SHA Godot 4.7.2 QA outcome

- Tested SOURCE SHA: `8bd765ba17f30a23ecc1ee1fa586266ed6977379`, original first-party 180×216 RGBA master Git blob `9d5502fb68db2492650ef46f0713017f361324ea` (local Git blob SHA independently matched). SHA256 master `5e0f1409bb2975ca03052932013121f052346314c59765ada51657147333f018`.
- [Native V4 G3.5 Action #43838930601](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43838930601) SUCCESS; artifact `14211274774`; native charge0.30s/peak0.84s/contact1.28s 1280×720 screenshots on moving actor, source/atlas packet validator, strict Godot import/parse/focused, exact-SHA manifest and negative missing-contact fail-closed all PASS.
- [Full native 8-second Action #43838930612](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43838930612) SUCCESS; artifact `14211303774`; Godot 4.7.2 Compatibility 1280×720 480 frames fixed 60 fps, MP4, GIF, 15 actual timed frame screenshots; movie SHA256 `bfd637f67232ae6dfdf4a674827d1762403d548ff1d622899344eef556207091`.
- Focused contract `VFX_TAL11_FOCUSED_RESULT=PASS failures=0`, one locked moving WALK monster, one simulated mark lasting 6s, no projectile/HP/status action.
- Verified same-camera same-time rendered R5/R6: 0.30s significantly changed paper material/silhouette; 0.84s R3 wind shape preserved with new R6 painted paper overlay; sustain 4.22s and fade 7.30s **pixel-identical** to R5 screenshot (mean absolute pixel diff = 0). 1.28s varies only slightly due to encoding noise, no mark design rewrite.

## G3.5 manual 1× art self-review and remaining defects
- R5 was a straight flat rectangular calligraphy icon. Actual R6 charge 0.30s reads as diagonally curled ornamental silk-paper with gold-crafted head, jade bead and hanging tassel, materially different in true Godot movie. Silhouette 4.1/5, school identity 4.2/5, color identity 4/5.
- Original first-party pictorial master source only 180×216 pixels; at 1280×720 film close crop fine filigree gets visibly soft. Material fidelity 3.6/5; some dark translucent edge halo; pose-to-pose elastic curl remains subtle (motion distinctiveness 3.7/5). This is **NOT art self-QA full PASS**: owner previously explicitly rejected the flat shape and must review R6 material/motion at real scale.
- Existing R3 wind/moving mark 4.5/5 inherited acceptance; target contact and fade 4.3/5; physical Windows/Android FPS unmeasured; no light-terrain visual QA in this native dark LAB.
- **Final independent gate status:** `R6_G3_5_TECH_PASS / R6_NATIVE_FULL_480_FRAME_TECH_PASS / R6_ART_SELF_REVIEW_OPEN_MATERIAL_MOTION / OWNER_R6_VISUAL_PENDING / R3_WIND_MARK_PROVISIONALLY_LOCKED / COMBAT_RECEIPT_MAPPING_PENDING / PVE_HOLD / V63_OFF / DEVICE_PENDING`.

All displayed images from GitHub are engine-rendered; generated concept reference is not gameplay. No change to V6.3, Combat V2, SaveService, economy, PvE, no rig/Codex/new branch/merge.
