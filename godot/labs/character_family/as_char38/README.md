# AS-CHAR-38 · sprite family lab

This isolated lab prepares the 2 neutral novice bases and the 36 design-branch registry without changing the gameplay renderer, SaveService, V6.3, or project.godot.

## Open the preview

1. Open the godot/ project in official Godot 4.7.2.
2. Open res://labs/character_family/as_char38/as_char38_preview.tscn.
3. Run the scene with F6.

The preview lets you browse all 36 branch definitions, choose male/female, front/right/back/left, and inspect Idle/Walk/Cast/Attack/Hit/Death status. The stage uses a checkerboard so transparent edges can be seen against light and dark squares; a floor line and pivot mark show the foot registration. The body stays at its 70px game size, with only 1× and 6× inspection views to keep review simple.

Branches currently resolve to a clearly labelled novice fallback because branch art is still ART_PENDING. Only the authored one-pose-per-direction novice idle is rendered. The one-frame idle is held as a static pose; selecting another state does not start playback, substitute a clip, or invent motion. The asset label shows the atlas file, cell region, pivot and mirror status.

## Current output

- Two neutral novice turnaround masters, each four authored views: assets/novice_male/master_turnaround.png and assets/novice_female/master_turnaround.png.
- Two 512×128 RGBA idle sheets, four 128×128 cells in front/right/back/left order. Each cell uses a 70px visible body and pivot (64,104).
- Two SpriteFrames resources. They contain one real static frame for each directional Idle animation; no Walk/Cast/Attack/Hit/Death clip is declared.
- as_char38_registry.json contains exactly 38 design groups: 2 novice bases and the 36 branch motifs. It records the 18 actual path candidate IDs present in the current V63 registry and leaves 18 other design rows as design-only. V63 is disabled in the source registry; this catalog does not create skill or gameplay authority.
- g1_style_comparison.png and g1_directional_coverage.png are static export contact sheets, not Godot screenshots or motion evidence.

## Rebuild the novice atlases

The exporter needs Python and Pillow 11.3.0. Pillow is an authoring-time dependency only; Godot runtime has no new dependency.

    python -m pip install Pillow==11.3.0
    python godot/labs/character_family/as_char38/tools/build_novice_atlases.py

The tool reads the committed source masters and the immutable Nữ Độc Tu V4 style-reference atlas. It creates the directional idle atlases, SpriteFrames, checksummed manifest, and contact sheets. It does not create motion or recolor any full sprite. The optional red edge cleanup only replaces a small number of red-dominant pixels in the outer alpha ring.

## Validate and test

    python -m unittest discover -s godot/labs/character_family/as_char38/tests -v
    python godot/labs/character_family/as_char38/tools/as_char38_registry.py

compose_appearance.py is a future-facing source-backed compositor. It accepts only verified same-canvas RGBA layer packs matching the exact school, branch and sex. It preserves geometry and the four registered directions, chooses cosmetic layers deterministically from disciple_id, profile_seed, cosmetic_seed, and refuses missing, mismatched, unverified or hash-invalid layers with ART_PENDING. No branch layer packs are present yet.

## Honest acceptance status

- Design mapping: 38/38 rows.
- Static novice directional idle candidates: 2/2 groups, not owner visual-approved and not yet Godot GUI-approved.
- Branch art: 0/36 authored; male/female variants for all rows remain ART_PENDING.
- Complete accepted six-clip animation: 0/38.
- Unique cosmetic combinations and unique 30-character lineup: not produced because source layers are not available. A repeated two-source scene is not a substitute for this art acceptance.
- Production roster coverage: not measured; no production integration is present.
- Motion video/pose-layer source: unavailable in the checked input inventory. No GIF is included.
