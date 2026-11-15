# POI08 R4 · Phệ Mạch Độc Thích — independent painted sprite Combat Lab

Updated: 2026-11-15. PR #72 Draft, branch `integration/pve-p0-playable-ui-20261103`.

## Art approval context
Owner approved **POI07 R7 Human** after reviewing its real Godot movie, then ordered continuation. Prior POI08 R1/R2 art was rejected as insufficiently distinct. R3 was technically Godot-pass but visually resembled the already approved Độc Tu snake skill. **R4 remakes the hero's head into a faceted poison-stinger/venom thorn**, preserving the lively twisted source-body while eliminating the reptile jaw. Re-render this one skill and seek owner art approval before POI09. Do NOT claim blanket school approval.

## Canonical Human contract (view-only)
`tmb.skill.poison.doc_cham.active_02.human`, `nether`, effect `poison`, `single_target`, radius 0, cap 1, range 7.5, cast 0.45 s, cooldown 9 s, projectile speed 8, duration 8 s, poison stack **1**, damage ratio 1.1 (catalogue read-only). No VFX writes HP, applies a poison receipt or fakes damage/status updates; visual preview sustains from 1.39 s to 9.39 s without eight artificial hits.

## First-party painted source provenance
All art pixels are first-party, from a project-conversation image-generation **concept poster** (NOT a Godot screenshot) named `a_highly_detailed_cinematic_game_skill_presentati.png`, SHA256 `f013277dc37e517b34a16f375393c6e7d3747581e1ebfc97e97a8e4b874fa3de`.
- Crop `(610,565,1043,686)` → `godot/labs/combat_lab/poison08/r3_painted/assets/master/living_barb_painted.webp`, SHA256 `d6c2d8297d0c1988a80e0dab8f5234a0d49c8c60e95107d15d5548630adf09a6`.
- Crop `(331,781,545,863)` → `.../r3_painted/assets/master/thorn_seed_painted.webp`, SHA256 `f85afe7833453aa0b920a05570d842393cf5a581de29e2dd0cbb2e6c034a92ea`.
- Crop `(1104,606,1290,718)` → `.../r3_painted/assets/master/vein_grip_painted.webp`, SHA256 `7dd323aa15c92860b54d0675a153b66d55db5cd62546da24bceedafbaf3b91d6`.
- Each crop was luminance/hue-matted to actual transparent RGBA, manually inspected over light/dark backgrounds to exclude underlying UI, actor, health bars, damage text, ground and sky.
- R4 derived hero master `godot/labs/combat_lab/poison08/r4_painted/assets/master/toxin_barb_painted.webp`, SHA256 `2fd6203d900b6e0f3cf3d15929cdf2790d01544244a12fefe2d181f88f2d60dd`, is an explicit **hand-composited first-party painted-source object**: original body masked to remove the dragon mouth and an existing original source poison crystal petal rotated/shaped as a barbed tip. No POI07, Xà Ảnh, Source VL/JX/A pixels copied. Neither Code-only SVG nor imported commercial textures.

## Reproducible original sprite-first production
`tools/vfx/generate_poi08_r4_painted.py` reads the tracked R3 source **for the same skill** and tracked R4 barbed master, non-rigidly repositions actual painted pixels with per-frame alpha and pose changes (no character rig). It writes independent RGBA atlases:
- `living_barb_r4_12.png`: 12 poses, 4×3 cells 384×128, 1536×384.
- `thorn_seed_r4_10.png`: 10 poses, 4×3 cells 192×192, 768×576.
- `bite_contact_r4_08.png`: 8 poses, 4×2 cells 192×192, 768×384.
- `vein_mark_r4_12.png`: 12 poses, 4×3 cells 192×192, 768×576.
Total 42 nonduplicated source-pixel RGBA poses; transparent borders with no atlas bleed. Raw RGBA8 budget four atlases **7,077,888 bytes = 6.75 MiB**. This is an asset-memory budget only, **not** proven physical Android FPS, VRAM or crowded 6v8+ combat.

## Timeline and occlusion
Dedicated Godot 4.7.2 Compatibility LAB `godot/labs/combat_lab/poison08/r4_painted/phe_mach_doc_thich_r4.tscn`. 1280×720. t=0.00–0.45 palm seed charge, t=0.45–1.39 **straight** one-target barbed projectile, t=1.39–1.87 local bite into one chest, t=1.39–9.39 cosmetic poisoned-meridian mark under/over actor at chest +17px to preserve face, t=9.39–9.72 fade, t=9.72–10.15 idle. Static Stage A approved actor texture unchanged, no character animation or fake target damage.

## QA gates and status
`.github/workflows/vfx-poi-08-r4-painted-native.yml`: official SHA256-pinned Godot 4.7.2 GL Compatibility, alpha/unique frame/≤8MiB gate, strict import/parse/focused contract, full 609-frame 1280×720 native movie (H264 MP4/GIF/14 timed 1× screenshots), SHA256 media evidence, guarded same-branch fast-forward for PNG atlases and exact-final-SHA dispatch. An automated PASS is **not** owner visual acceptance.

R4 native run, exact SHA and visual review: **PENDING at document creation**. Owner gate `OWNER_VISUAL_PENDING`; PvE integration `HOLD_V63_OFF`; Windows/Android physical QA `PENDING`. Do not merge or modify POI07 R7, POI06 R11, Combat V2, SaveService, AI or economy. No Codex, rig or new branch.

## QA closeout — R4 initial + binary-tracked exact SHA
- Original R4 first script and workflow commit `7518bf17913b1f0848a3d34463aff590ab27b30d`; [GitHub Actions run #43698467670](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43698467670) **SUCCESS** (first attempt at previous script name failed and was corrected; no false PASS).
- PNG atlas fast-forward add on same PR branch `dab9e89c03742f40a2a4face48c1d612a7da44d5`, verified via exact source [run #43698586531](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43698586531) **SUCCESS**, [artifact #14154618848](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43698586531/artifacts/14154618848).
- Official SHA256-pinned Godot `4.7.2.stable.official.ed1daf0bf` GL Compatibility. Strict import + parse + isolated Human poison contract `VFX_POI08_R4_RESULT=PASS failures=0`; real 1280×720 H.264 MP4 with 609 frames / 60/1 fixed movie clock (10.15s). GIF and 14 native 1× frame captures. After download from exact-binary-SHA Actions artifact, **16/16 SHA256 media checksums verified**, MP4 SHA256 `c4405205d05017b834e9b1ec83c880bc792e97a47ddd95b1e661a401b6130756`. Fixed recording framerate is not Android FPS.
- Actual native t=0.29 charge, t=0.88 flight, t=1.42 contact, t=2.46/5.00/8.40 sustained marked state, t=9.47 dissolve and t=9.77 clear were inspected on 1280×720 screenshots. The projectile reads as crystal barbed thorn rather than a dragon jaw; the chest-localized mark does not obscure the face, is visible through the sustained phase, and leaves one single visual status only. **No runtime poison ticks or damage implementation**.
- First R3 original painted trial [run #43697418718](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43697418718) also passed technically but used snake-head art and has NOT been approved; preserved untouched for comparison.
- `POI07_R7_HUMAN_OWNER_VISUAL_APPROVED`; `POI08_R4_TECH_PASS`; `POI08_R4_OWNER_VISUAL_PENDING`; `V63_OFF`; `PVE_INTEGRATION_HOLD`; `WINDOWS_ANDROID_PHYSICAL_QA_PENDING`. No merge. Raw 7,077,888 byte RGBA8 budget only; current real multi-caster stress performance remains UNKNOWN.
