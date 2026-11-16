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
