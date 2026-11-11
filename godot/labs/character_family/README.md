# AS-CHAR isolated family preview

This is a review-only scene inside the existing Godot project. It does not change the main scene, project.godot, P3.2 actor scripts, or gameplay.

## Open the preview

From the repository root, open godot/ in Godot 4.7.2 and run:

res://labs/character_family/character_family_preview.tscn

The left card plays the six real stored Nữ Độc Tu atlas sequences. Use the clip buttons, pause/play, restart, speed, and zoom controls. The two other cards show static four-view candidate sheets. They intentionally do not move because they have no authored animation.

The locked female master remains blocked while the original owner file is missing. The existing six atlas sheets are not a substitute for the 4-direction master. Candidate cards are not production assets.

## Focused checks

From the repository root:

python -m unittest discover -s godot/labs/character_family/tests -v

python godot/labs/character_family/tools/validate_catalog.py

The validator checks catalog identity/status, candidate PNG path/hash/dimensions/RGBA, and all six current Nữ atlas sheet paths/hashes. It does not certify anatomy, animation quality, owner approval, or device performance.

## Asset outputs

- assets/candidate_male_swordsman_4view.png
- assets/candidate_female_healer_4view.png
- assets/GENERATION_PROVENANCE.md
- catalog.json, catalog.schema.json, and source_a_asset_matrix.json

Both new sheets are independent static ImageGen candidates. No GIF/video is included because no real motion has been authored for them.

