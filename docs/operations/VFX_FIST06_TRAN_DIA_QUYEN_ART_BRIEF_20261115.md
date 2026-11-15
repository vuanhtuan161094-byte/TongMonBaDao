# FIST06 — Trấn Địa Quyền / Kim Cang / Human (2026-11-15)

## G0 catalogue truth and scope
- Exact ID: `tmb.skill.fist.kim_cang.active_01.human`, active_01 in branch `kim_cang`, school Fist, Human.
- Effect `damage`, element `earth`, shape `single_target`, target_limit 1, range 2.8, cast 0.45s, cooldown 8s, projectile_speed 8, damage_ratio 1.35 (metadata READ-ONLY); radius 0, no guard/AoE/mark.
- Only visual LAB; cannot change confirmed Combat V2 cast/hit/HP or projectile authority. V6.3/PvE OFF; only event-bound preview. No rig, Codex, branch/merge, SaveService/AI/economy changes.

## Art direction — not another Ba Quyen fire AOE
**One stone-crusted knuckle fist**, from angular earthen pressure to a short strike, then a localized rock fracture on ONE moving target. Ink-dark granite, muted ochre seams and mineral-gold pin highlights, not orange explosion star, stone pillar spam, talisman runes or a full glowing screen circle. Top-heavy velocity, very short contact flare and restrained gray-umber dust; the rest of the frame remains readable at 1× game scale.

## Production master / provenance
- An original source-code-drawn raster stone-fist hero, **not** ImageGen art, not a JX commercial source and not footage from a prior VFX.
- `tools/vfx/generate_fist06_tran_dia_quyen.py` generates two original PNG RGBA 256px-cell atlases: 16 pose MAIN (4 charge + 12 travel) in 4x4 1024x1024, 8 pose localized HIT in 4x2 1024x512. Full first-party deterministic source preserved. No rig, target remains a statically sized original UI scale stand-in.
- Main: knuckle geometry, mineral seam highlights, fractured palm facets and independent motes. Contact: different stone chips and airborne dust; localized to target torso.
- Both sheets share 2D textures; **6,291,456 bytes = 6.00 MiB raw RGBA**; uncompressed raw accounting is NOT physical mobile VRAM or a tested FPS. CI creates and hashes PNGs before Godot import.

## 60fps lab storyboard, not a Combat V2 timing receipt
- 0.00–0.45: stone knuckles compact at caster hand (charge)
- 0.45–0.72: one short earthy fist travels along a dynamic aim line to the moving target
- 0.72–0.96: one grounded contact flash, target full-sprite recoil PREVIEW ONLY
- 0.96–1.28: stone chips and earthen dust fall and clear
- 1.28–1.68: no VFX (full clear, loop)
- Native frame checkpoints at 0.12/0.34/0.44/0.51/0.62/0.70/0.74/0.80/0.93/1.04/1.18/1.38.

## QA / acceptance
Godot 4.7.2 GL Compatibility strict import, parse, focused contract, native film MP4 1280x720, GIF, 12 timecoded frames, original atlases and checksums on exact GitHub SHA. Visually reject if hero looks like a flat beige vector, if the actual attack loses its leading knuckles, if enemy is covered by an opaque cloud, if body reaction looks like fake hits, or if release lacks speed/weight. Keep tech PASS and visual quality separate; **OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / ANDROID_PHYSICAL_PENDING**. User-approved Ba Quyền labs remain untouched.
