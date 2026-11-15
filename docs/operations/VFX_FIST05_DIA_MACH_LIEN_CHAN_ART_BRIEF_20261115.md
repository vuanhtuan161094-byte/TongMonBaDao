# FIST05 — ĐỊA MẠCH LIÊN CHẤN · Art-first V1
2026-11-15 | owner visual PENDING | isolated LAB only

Canonical: `tmb.skill.fist.ba_quyen.active_04.human`; name Địa Mạch Liên Chấn; school fist, Bá Quyền, active Human; `damage / fire / circle / radius 3 / max 3 targets / cast 0.45s / range 4 / projectile_speed 8`; cooldown 8; damage_ratio 1.35 from source and READ ONLY. Never invent additional hits, HP modifications, lightning elemental damage or persistent status effects.

## ART SOURCE / provenance
Original image generated for this conversation (fresh first-party design, no commercial pixels): master scene SHA256 `14fe768c2c9101717232f77684e31f2992c22c1171af9def62db007d1944dfe4`. The ORIGINAL CONCEPT BOARD itself is **not** the game asset, a screenshot or a QA PASS. Three real transparent cropped and feathered first-party WebP source-paint masters are tracked:
- `seismic_ground_master.webp`, SHA256 `59b00e7f698c4f8582e0c6b2f3ce2706b2ff07cf73d81ecd9acd110a71e0a01b`
- `molten_shard_master.webp`, SHA256 `2a20612399dfe009ed4394f8acc9d4f7194929c7636397eb5992dc6ee6619ccf`
- `spires_master.webp`, SHA256 `d28060c75f8a3acf7319aebdca9cb260afdd796c2c69d8f58ebb2357888dd47d`
Reproducible source `tools/vfx/generate_fist05_dia_mach.py` composes **40 RGBA frames**: 8 charge (4x2), 12 fault spread (4x3), 12 rising stones (4x3), 8 contact (4x2), all 384px/cell. Each frame varies split geometry, stone positions, material, opacity and rubble. It does not fake a moving actor rig. These generated PNGs are build assets, produced by CI before Godot import, not committed as binary duplicates.

## Storyboard / QA
Cast 0-.45 ground qi at caster; .45-1.01 cracked fault propagates ON THE GROUND towards a circle group; 1.01-1.72 independently posed rocky eruption behind targets + bounded flashes on **at most three** preview enemies; 1.72-2.56 rocks/dust fade, 2.56-3.0 clear. Godot fixed-clock 1280x720 185 frames, timecode PNG, GIF, MP4, exact SHA contract. LAB targets wander slightly: **preview staging, not pathfinding/Combat V2 tracking**. Only a separately confirmed receipt can later authorize real hit reactions. Check rocks do not obscure the enemies at 1x and avoid an orange flat UI disk.

Files: `res://labs/combat_lab/fist05/dia_mach_lien_chan.tscn`, its script, `res://tests/labs/combat_lab/vfx_fist05_contract_test.gd`; CI `.github/workflows/vfx-fist-05-dia-mach-lien-chan.yml`. No rig, Codex, branch, merge, other school assets or gameplay edits; V6.3 OFF, PVE HOLD. **Technical QA PENDING UNTIL EXACT-SHA CI completes; OWNER_VISUAL_PENDING.** Final 60fps movie is NOT physical Android FPS.
