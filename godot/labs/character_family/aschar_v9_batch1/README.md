# AS-CHAR V9 — Batch 1 review package

This is a Godot 4.7.2 candidate-art review project, not a gameplay integration. Open `project.godot` with the official Godot 4.7.2 editor and run `scenes/review.tscn` for AS-CHAR-48, or `scenes/review_as49_attack.tscn` for AS-CHAR-49 Attack_Front plus map-scale Walk_Front.

For deterministic rebuild, import first, then run the two resource scripts in order and the verifiers: `godot --headless --editor --path <project> --quit`, `godot --headless --path <project> --script res://scripts/build_as49_attack.gd`, import again so Godot registers the new atlas, `godot --headless --path <project> --script res://scripts/build_as49_spriteframes.gd`, then run `verify_as49_attack.gd` and `verify_batch1.gd`.

## What exists in this package

- AS-CHAR-48 Kiếm Tu nam: Walk_Front and body-only Attack_Front, each with four source poses and registered 400×440 RGBA cels.
- AS-CHAR-49 Kiếm Tu nữ: Walk_Front and Attack_Front, each with four source poses and registered 400×440 RGBA cels.
- `SpriteFrames`, atlases, review scenes, source prompts, manifests, a 576-row coverage matrix, native Godot viewport screenshots, native Godot MovieWriter AVI files, and raw logs.
- Body sprites are monolithic per frame. There is no rig, bone system, or split body. Swords are deliberately absent from the body frames and remain a separate-overlay task; no sword choice or grip calibration is approved.

## Status

Four of 576 target clips have technical evidence; none has owner art approval. These are candidate animations for the first two Kiếm Tu identities only. Right/Back/Left, the other four actions, all other schools, weapon overlay/grip metadata, clipping review at runtime scale, and owner approval remain open. Do not wire these assets into the production game yet.

The test source was this isolated local review project. PR #72 was checked live before publication, but this folder is not a native checkout of PR #72; its current head and exact artifact hashes are recorded in `meta/`. Godot system-certificate, user-profile-write, and shader-cache warnings are environment issues documented with the logs. Native OpenGL Compatibility runs completed with exit 0.
