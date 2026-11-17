# POI17 — Yểm Ảnh Bộ R1 — Thân pháp Độc Tu
2026-11-17 · GitHub PR #72 Draft only, no gameplay implementation, no Codex, rig, GIF, new branch or merge.

**Owner accepted POI16 R2D provisionally and requested next skill.** The next UNPRODUCED Human Poison CAST_MASTER from canonical ledger is SHARED `tmb.skill.poison.mobility.human`. Distinct from other Poison active skills. Keep POI16 R2D source/version frozen in same PR.

## Canonical non-fabricated contract
Effect **mobility**, element **metal**, shape **single_target**, target_limit1, range11 WORLD units, cast_time0.1s, cooldown10s, duration1s, projectile_speed0, power0, poison_stacks0. Catalogue `damage_ratio=0.05` is metadata only. The canonical field does NOT authorize teleport, stealth invisibility, poison/damage, repeated hits or PvE motion authority.

## G2 semantic storyboard at real size
**Yểm Ảnh Bộ** should read as **fast shadow FOOTWORK**, not a generalized green buff, attack or portal. 0–0.1s: a pair of spectral boots appears at caster feet. 0.1–1.1s: approved caster sprite translates continuously across LAB (not game authoritative), leaves at most 3 naturally spaced semi-transparent copies of its OWN earlier 2D poses; true original RGBA speed wake follows the moving caster and two distinct staggered left/right boot soles mark prior positions. 1.1–1.52s: a finite light footprint lands, both wakes and ghosts dissolve; after1.52s no persistent state. An independent enemy WALK animation at ~x1060 receives no VFX contact.

## Source and proof
New reproducible painterly generator: `tools/vfx/generate_poi17_yem_anh_bo_r1.py`, produces 4 original true-alpha sprite sheets (8 gather 256x224; 12 jade movement wakes 320x160;12 spectrally paired left/right bootprints 256x192;8 landing 256x224) totaling 40 frame-by-frame poses and 4 master PNGs preserved under `godot/labs/combat_lab/poison17_yem_anh_bo/r1/assets/`. Approved original disciple and monster art are pre-existing fixtures, not redrawn/rigged; actor copies at past spatial positions illustrate real motion. Godot scene `godot/labs/combat_lab/poison17_yem_anh_bo/r1/yem_anh_bo.tscn`, 1280x720, recording108 movie frames at 60 fixed output, phase images t0.075 charge,t0.63 peak,t1.15 landing, t1.30 fade and t1.63/1.72 idle/expired.

Movement trajectory start (286,545)→end(805,539) over exactly1s is a LAB-only staged visual **NOT** range11 units→px mapping or game controller movement speed. No claim of real dodge or hit receipts. G3.5 exact Godot native on moving actor + WALK monster negative case; G3.6 native-scale green jade visibility and absence of ghost persistence; G3.7 manual player-recognition: **'paired shadow footprints + trailing phantom selves + clear change of position' should read as a mobility skill without an explanatory HUD**. Godot strict parse/contract and V4 packet/source/video exact-SHA; technical PASS never auto approves art or PvE. Owner review, actual gameplay and Android physics QA PENDING. V6.3 OFF.
