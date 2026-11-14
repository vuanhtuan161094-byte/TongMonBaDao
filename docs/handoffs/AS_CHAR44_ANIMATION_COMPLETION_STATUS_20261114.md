# AS-CHAR-44 — Kiếm Tu nam: actual animation coverage (2026-11-14)

Owner request: **create ALL disciple animations before further game integration**. Scope of this pilot is the approved male Kiếm Tu identity, **4 directions × Idle/Walk/Attack/Cast/Hit/Death = 24 required clips**. Female and 11 other schools remain subsequent scope. NO rigs, Skeleton2D, Bone2D, primitive code-drawn actors, fake walks, or made-up states.

## Actual deliverables (binary source in personal Library; NOT checked into GitHub)

- `/TMB-Character-Art/AS_CHAR44_KIEM_TU_ANIMATION_PROGRESS_R1_20261114.zip` (personal ChatGPT Library), SHA256 `523bebf159c5ea1d92f342bd33d0d9b0a613d9699465c11f9098ede4d2ae1bcd`; **65 files, ZIP CRC PASS**. Retrieve the real ZIP via Files/Library when changing chat; do not invent sandbox paths.
- Input original user-approved right-walk GIF retained with SHA `15b78700836f3d519fbe916ae819f20c9d07d3821b6c8917bb84df99f950b6ac`, 508×337, 9×120 ms, minor hand issue.
- NEW sword-free 9-pose RIGHT-WALK ImageGen animated GIF source `chibi_swordsman_walk_cycle_animation.png` (GIF file, 430×392, 9×120ms), exported with deliberate transparency matte to 9 unique 448×416 PNG frames and 1344×1248 RGBA atlas; real dark-background GIF and contact sheet. **Owner has NOT approved this new variant.**
- Four high-resolution independent original static stands front/right/back/left; not relabeled Walk.
- Separate 9-frame weapon overlays for red-black owner-selected asymmetric sword, cyan demo test, **body atlas invariant under swap**; z-order/hand grip quality **FAIL / PENDING**. Isolated GDScript `res://labs/character_family/as_char44_kiem_tu_progress/preview.tscn` has 1×/2×/3× zoom and keyboard D/E, no rig. **Godot engine has NOT been run**, no 4.7.2 screenshot or Android proof.
- Manifest `CLIP_COVERAGE_MANIFEST.json` enumerates exactly all **24 clip slots** with 1 new right Walk 9-frame candidate, 4 single-frame static stands, 19 un-authored clips; 65-file ZIP hash/CRC verified. Source alpha proof and 9 distinct frame hashes generated.
- An earlier attempt to generate Attack/Cast via image generation incorrectly returned Walk again and was **rejected**, not counted as an authored action.

## QA truth

- `WALK_RIGHT` = new 9 real distinct keyframe candidate (not owner-approved), transparent RGBA, no weapon baked, source ≈350px actor; 9-frame GIF reviewed on dark.
- `IDLE_FRONT/RIGHT/BACK/LEFT` = 1 static stand image each, NOT idle animations.
- `WALK_FRONT/BACK/LEFT` = NOT AUTHORED.
- `ATTACK/CAST/HIT/DEATH` each four directions = NOT AUTHORED.
- **Official Godot 4.7.2, clean modular weapon grip, full 4-direction motion and owner release visual approval remain NOT PASSED**.

## Required next actions

1. Generate ARTIST-QUALITY, visibly distinct *front/back/left* nine-frame Walk cels from locked source, never rotate one flat perspective and call it another direction. Preserve 320px+ source.
2. Author Attack (windup–strike–recovery), Cast (gather–gesture–recovery), Hit (impact–recovery), Death (fall–settle), and actual idle secondary motion for each direction from an identical reference master, 1 action/1 direction at a time; inspect real motion.
3. Modular red-black sword: per-frame matched hand sockets, independent front/back occlusion masks; redo while inspecting each frame. Keep visual effects external and no rig.
4. Godot 4.7.2 engine/frame QA on an isolated E: worktree; then expand to female and other 11 sects with visual owner gate.
5. No asset is passed or integrated into production by presence of a file name; no branch, merge, or gameplay/SaveService/Combat/economy modifications.

**Do not use the new Clip 1/24 as proof 24/24 done.**