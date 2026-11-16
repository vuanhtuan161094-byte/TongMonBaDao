# Phản Chấn Quyền · FIST08 R1 · 16/11/2026

**GitHub PR #72 Draft only, branch integration/pve-p0-playable-ui-20261103.**

## G0 canonical lock
Exactly `tmb.skill.fist.kim_cang.active_03.human` — Earth `guard`, `single_target`, one protected recipient, `cast_time=0.45`, `duration=4`, cooldown 8, range 5.5, projectile speed 0, radius 0. Catalogue does not declare hit_count on this legacy guard, hence V4 packet sets 0 **outgoing visual hits**, not synthetic damage. No real damage deflection or return-attack logic authorized. V6.3/PvE OFF.

## R6 carry-forward, no rewriting approved art
User allows Kim Cang Ho The R6 as **provisionally acceptable** and asks to move on; records two open debts: (a) defended-hit reaction too weak, (b) long-state marker not perceptible. Do not change R6. This FIST08 must have separate punchy guarded-hit flash and a legible but subdued status marker.

## New art, not recycled visual
- Original 512×512 gold asymmetrical compression channels and white-gold counter-impulse painted into transparent masters. Added short-lived original first-party generated dragon pigment (646×185) from an *assistant-generated concept*, NOT any JX commercial pixel or poster as Godot proof.
- Cast 0–0.45, hero retract through 0.79. Distinguish from FIST07: no statue, no permanent grand glass dome. Negative central window to preserve real actor.
- Sustain 0.45–4.45 is small luminous pressure chevrons around shoulder and under feet; no repeated cinema-scale dragon; loop 8 poses. Give UI remaining-duration **LAB ONLY**.
- Incoming guarded-hit contact at demo timestamps 1.29 and 3.09 tracked to the walking protected actor's shoulder, visible ~0.28 seconds. Short white-gold directional counter-impulse visual without damage to opponent. Last 0.4s quietly fades.
- True visual demo start/end local timeline and the engine's gameplay event clock are separately declared in the V4 packet, `RUNTIME_MAPPING_PENDING`.

## G1 source/style reference
Owner wants JX/Kiếm Thế feeling: pure saturated luminous gold + ivory-hot core, strong quick contact, readable actor, restrained ongoing buff. External JX pixels are only for visual study and are **not** included. Source hero from this conversation is independent first-party. Two incorrectly generated poster boards featuring different fictional skill IDs were **rejected** and are not production assets.

## G3–G5 technical contract and evidence
- Original source: 3 encoded RGBA masters (two 512px original raster painted, one 646×185 cropped first-party generated gold dragon detail); generator `tools/vfx/generate_fist08_phan_chan_quyen.py`.
- Atlas: 8×320 cast (1280×640); 8×192 sustain (768×384); 10×256 contact (1024×768): **26 poses, 3 textures, 7,602,176 raw RGBA bytes = 7.25 MiB**. This is raw source pixels, NOT measured Android texture residency.
- Godot isolated LAB: `godot/labs/combat_lab/fist08/phan_chan_quyen.tscn`, view only. MOVING target via approved unchanged frame-by-frame WALK. No rig.
- V4 G3.5 mini proof genuine Godot native 1280×720 `v4-charge.png` .30, `v4-peak.png` .59, `v4-contact.png` 1.34 and exact SHA evidence manifest. After manual STOP art gate, full movie review >12 checkpoints, dark/bright terrain and occlusion checks.

## Current approval boundary
R1 is **not** owner-approved, ART_SELF_QA_PENDING until actual Godot footage reviewed, PVE_INTEGRATION_HOLD, Android device pending. No Combat V2, damage, status mutations, SaveService, AI, merge, new branch, rig or Codex.
