# PAF05 R5E — Real Godot Native VFX Review / Owner Art Pending (17 Nov 2026)

**Current focus:** PAF05 Thái Huyền Phong Giới Phù, skill ID `tmb.skill.talisman.phong_an_phu.ultimate.human`. PR #72 Draft, existing integration branch. R2 and R4 source scenes are NOT overwritten. R3 offline sprite-pasting source is not production artwork; R5A jade curl mark and R5B huge central glyph have been superseded. No rig/Codex, new branch, merge, Combat V2, PvE, SaveService, economy or AI modifications.

## Exact canonical mechanics / independent clocks

Wind, effect=mark, shape=circle, radius2.1, target_limit3, cast_time0.9s, cooldown23s, duration7.0s, projectile_speed0, hit_count1. These are catalogue fields, NOT values set by VFX.
- Simulated LAB mark receipt = 1.33 s. **Real Combat V2 receipt mapping UNKNOWN/PENDING**.
- Hero effect starts with hand charge, formation .60–2.52 s; contact pulse 1.33–1.92s; persistent cosmetic mark 1.33–8.33s. The 9-second status QA recording is not a nine-second spell cast.
- Mark latches by legal simulated receipt and follows original moving target by index until expiry; does not reacquire additional targets or apply a real status.

## What was actually implemented

- Main R4 real-time curving 4-blade wind stream geometry + CPU particles + Compatibility-safe internal light-flow shader reused and adapted at R5D to four deliberately nonidentical trajectories and brighter converging caster charge. No whole-sprite sine-wave deformation.
- Dedicated original source generator `tools/vfx/paint_paf05_r5_mark.py` builds a true-RGBA independent WIND/風 seal and contact key-pose atlas, with staged calligraphic reveal and separate hold/caustic. The source uses rasterized Noto Serif CJK (open OFL font from Ubuntu packages) as one mark shape mask, plus first-party jade light/gold brush materials; **no font files are shipped** and no proprietary Võ Lâm/Kiếm Thế pixels are used.
- R5C stopped displaying a giant hovering 風 glyph; central source art became a subdued ground inscription, target mark moved to enemy shoulder. R5D changed the core to antique gold and varied wind streams. R5E improves the contact->hold optical handoff: mark contracts from 73px art-cell destination to 56px, preserving readability but reducing occlusion.
- Field particles are actual Godot CPUParticles2D; moving target uses actual SpriteFrames WALK. This is a dedicated LAB, **view-only**, not Combat V2.

## Reproducible code

- `godot/labs/combat_lab/talisman15/r5/thai_huyen_phong_gioi_r5.tscn`
- `godot/labs/combat_lab/talisman15/r5/thai_huyen_phong_gioi_r5.gd`
- Inherited isolated R4 wind base `godot/labs/combat_lab/talisman15/r4/` (not edited by this R5 iteration)
- `godot/tests/labs/combat_lab/vfx_paf05_r5_contract_test.gd`
- `.github/workflows/vfx-v4-paf05-r5-native.yml`
- Original source at `tools/vfx/paint_paf05_r5_mark.py`; binary PNG master and WebP atlases regenerated identically in the workflow and archived with MP4 (not currently git-committed as binary masters).

## Exact-SHA verified technical evidence

- Tested content SHA **87afe14aa7888cf086409a34b4f65dccd9345d10**.
- GitHub Actions run https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44069358237: **COMPLETED SUCCESS**.
- Strict Godot official 4.7.2 Compatibility import/parse, R2/R4 regression source and focused R5 moving-target contract: PASS, `VFX_PAF05_R5_FOCUSED_RESULT=PASS failures=0`.
- Native R5 movie: **1280×720, 192 frames / 3.2s**. Full independent status test movie: **1280×720, 540 frames / 9.0s**, including timestamps 1.52, 3.18, 5.11, 7.96, 8.28, 8.52, 8.80. Assets/PNG/video SHA manifest and raw logs in native Actions artifact `vfx-paf05-r5-native-87afe14...`.
- The status remains visible at t=8.28 and absent at t=8.52 in native Godot screenshots; exact expiry by contract is t=8.33. All three targets tracked while walking.
- Movie-maker 60 FPS is **encoded simulation timeline**, not a measured physical GPU/Android/Windows frame rate. Native runner is Linux Mesa llvmpipe.

## Manual visual self-review — DO NOT OVERRIDE ART GATE

Improved relative to R4: the mark has a meaningful legible 風 identity, no generic arc/ring HUD badge; native 1x anchor and three-target visibility improved; the drawn contract, moving energy and 7-second status are demonstrable without any offline still-camera animation. However, the main four wind blades still read somewhat as artificial curved leaf sectors rather than premium hand-painted living qi, and the mark remains a glyph-like bright seal rather than richly illustrated ink-light. **R5E is a revision candidate, not OWNER ART APPROVED**.

G0 verified; G3 source reproducible/art manual pending; G3.5 / G3.6 native technical PASS; G3.7 semantic mark clarity improved but manual owner judgment required; G5 genuine native MP4 PASS; G7 technical exact-SHA PASS; **OWNER_VISUAL_PENDING / ART_REWORK_REQUIRED until explicitly approved**, G8 live PvE HOLD, Windows/Android physical QA PENDING.

Do not move to a new skill or enable live PvE on the basis of green CI. If owner rejects R5E, next work is to improve the main painted wind source at its current 1x target scale, not build another poster or increase glow blindly.
