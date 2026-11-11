# Disciple animation coverage — PR #72 snapshot

Exact source inventory at the start of this packet: PR #72 HEAD 7587e2be5bb0800d6c84d4fb28e35c8951bebcc0. Detailed source file hashes and frame counts are in godot/labs/character_family/source_a_asset_matrix.json.

**Manifest frame counts prove stored sequences exist; they do not prove visual acceptance, school identity, or shared pivot compatibility. No clip is merged across packages here.**

| Package | Source label | Present clips from manifest | Missing from six-clip target | Boundary |
|---|---|---|---|---|
| 1113028_1 | Source rig; identity unknown | stand 48, walk 24 | cast, attack1, hit, dead | Do not assign disciple/school from ID alone |
| body_1110201 | Body rig; role unknown | stand 48, walk 24 | cast, attack1, hit, dead | No identity/sex/school claim |
| body_1120402 | Body rig; role unknown | stand 48, walk 24 | cast, attack1, hit, dead | No identity/sex/school claim |
| v5_sa_female_1113028_1 | Female visual candidate | attack1 29, hit 15, dead 15 | stand, walk, cast | Related source hashes do not prove combined clip/pivot compatibility with 1113028_1 |
| v5_sa_male_body_1110201 | Male visual candidate | stand 48, walk 24, attack1 29, hit 15, dead 15 | cast | Source A visual style is not automatically the Issue #77 family style |
| v5_sa_monster_1113031_1 | Monster | stand 60, walk 24, attack1 29, hit 10, dead 22 | cast | Monster remains monster, not disciple |
| v5_sa_boss_410041_1 | Boss-slot candidate | stand 60, run 28, attack1 30, hit 15, dead declares 30 but stores 21 | cast; dead mismatch | Candidate, not a verified Boss identity |

## Nữ Độc Tu V4 supplied package

Six atlas states and four actual 8-frame motion-review GIFs are committed under godot/labs/character_family/assets/nu_doc_tu_v4_candidate/ with per-file SHA-256 records.

- Idle: one still frame per direction; valid static idle form, not moving idle.
- Walk: eight frames per direction; its motion direction was accepted by the owner earlier; Godot and target-size review pending.
- Cast/Attack/Hit/Death: eight frames per direction in candidate atlases. Cast/Attack contain green light/projectile pixels already baked in.
- No official Godot 4.7.2 preview ran on the Windows owner machine; Windows process enumeration was Access denied. The focused GitHub workflow is the isolated check.
- No candidate atlas is wired into Combat Lab, P3.2, or production.

## What complete disciple animation still needs

1. Family-compatible male and additional female authored masters; existing turnarounds are static candidates.
2. Real storyboard/key poses and six clips for each shared compatible rig and weapon family, not fake substitutions.
3. Verified source/rig/pivot retarget before any Source A clip reuse into the Shadow Pixel-Chibi family.
4. Four-view, game-size visual review, editable source, and exact-SHA Godot evidence.
5. A verified mapping from real disciple appearance to school; unknown asset IDs cannot supply that mapping.
