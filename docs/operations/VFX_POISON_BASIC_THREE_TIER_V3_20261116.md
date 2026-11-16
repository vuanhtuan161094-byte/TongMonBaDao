# Độc Châm Thường Thức V3 — direct VFX Godot, NO GIF

Owner 16 November 2026 explicitly cancelled GIF-first production. **Do not make more GIFs** by default. Delivery is actual Godot MP4 1280×720, charge/peak/contact screenshots and exact-SHA V4 proof. Existing accepted POI11 R9 remains untouched. PR #72 Draft, no merge.

## Canonical three normal attacks
| Tier | ID | Ratio | Range | Speed | Cooldown | Cast / status |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Nhân | tmb.skill.poison.basic.human | 1.00 | 6 | 12 | 1.60s | 0 / 0 |
| Tiên BASE | tmb.skill.poison.basic.immortal.base | 1.18 | 6.24 | 13.44 | 1.54s | 0 / 0 |
| Thần BASE | tmb.skill.poison.basic.divine.base | 1.34 | 6.42 | 13.44 | 1.47s | 0 / 0 |

All three: element metal, damage, single target cap 1, no poisoned status; hit_count undeclared and never invented. V6.3 OFF.

## Painted visual progression (not palette-only)
**Nhân:** straight slender jade poison needle, pale core, short violet halo, compact five-ray local hit.
**Tiên:** needle becomes dual-echo cyan-jade lance with two symmetric translucent afterimage trails and seven-spoke broken ripple at hit, still one gameplay target/hit.
**Thần:** stronger jade needle with finely articulated warm-gold tip, two golden side glints and nine-spoke bright local contact plus five subtle gold motes, still one target/hit.

Never make the tail squirm like a snake. Each tier uses new original RGB-alpha source art, with light-pure saturated pigments independent of transparency. 6 charge + 8 flight + 8 contact alpha sprite poses per tier = 66 authored poses total. Three atlases and three preserved master key poses per tier. No actual GIF generated or used. Original Python source: `tools/vfx/generate_poison_basic_tiers_v3.py`.

## Live Godot LAB only
Scene `godot/labs/combat_lab/poison_basic_tiers_v3/poison_basic_tiers.tscn` and focused Godot contract test under `godot/tests/labs/combat_lab/vfx_poison_basic_tiers_v3_contract_test.gd`. Three tiers display sequentially in a 3.78 sec native clip (Human [0,1.26), Immortal [1.26,2.52), Divine [2.52,3.78)); user sees true VFX in Godot on existing frozen caster and actual WALK monster. Screen-space projectile aims toward locked moving target by rotating a single atlas. Each tier's G3.5 images at local t=.08/.42/.80. Native video 234 encoded 60fps frames is NOT 234 source sprite poses and is NOT physical device FPS.

**Pending:** G3.5 native exact-SHA technical QA, human 1× art review, owner visual approval, physical QA, runtime event integration. Keep PvE OFF, V6.3 OFF. No rig, Codex, new branch, merge or Combat V2/SaveService changes.
