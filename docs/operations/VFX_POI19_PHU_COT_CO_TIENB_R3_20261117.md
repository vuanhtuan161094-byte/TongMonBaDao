# POI19 R3 — Phệ Cổ, luồng linh quang sống TRỰC TIẾP trong Godot 4.7.2

Date 2026-11-17. Draft PR #72, current branch integration/pve-p0-playable-ui-20261103. Owner request: VFX must RUN INSIDE Godot, do not deliver only illustrated sheets/posters, and the existing R2C looked like a sprite sticker. R2 6 atlas, 80 original RGBA poses ARE PRESERVED UNTOUCHED.

## G0 skill authority / three clocks
- Canonical ID `tmb.skill.poison.co_doc.active_01.immortal.b`, `effect=mark`, `element=wood`, `single_target`, one target, radius0, range7.8, cast0.43, cooldown9.6, projectile_speed8.96 world-units/s, mark6.5s, no authoritative hit_count. Catalogue V6.3 OFF. No new poison, damage, AoE, actual Combat V2 hit/mark application or persistent buffs invented.
- Combat receipt mapping UNKNOWN `RUNTIME_MAPPING_PENDING`. LAB-only simulation: .00–.43 caster charge; .43–.55 release; .55–1.35 flowing pearl follows selected WALK monster; t1.35 simulated contact; 1.35–2.10 swirling strands wrap only chosen target; 1.35–7.85 native softly moving orchid wisps and R2 flower remain with selected, 7.85–8.10 fade. Demo loop8.5; 60fps video metadata not device FPS.

## G1/G2 original material and semantic
- **Physical perception goal:** real-time Godot emitted light, soft continuous temporal trail behind a small original RGBA pearl, 3 side filaments, local short wrap, restrained status wisps, not big UI sticker or stationary PNG transitions.
- Separate blended layers: unchanged original 80-pose source-saved R2 atlas material in regular alpha/MIX; NEW entirely-native `flow_light.gd` child Control with actual `CanvasItemMaterial.BLEND_MODE_ADD`, per-frame Godot `draw_line` and `draw_circle` at live moving screen coordinates (analytic splines, time sample, subtle pulse). Only additive glow is in this child, not on background, characters or ground. Dynamic charged core, travel history with width falloff, local contact center and small mark wisps. Native Godot 60fps continuous motion, not GIF, offline Python MP4, static copy-paste, or rig. Original reference screenshots are inspiration only, no pixels copied.
- No new hero artist sprite invented. R2 illustrated source remains under `godot/labs/combat_lab/poison19_phu_cot_co_tien_b/r2/assets/`, original generator `tools/vfx/generate_poi19_phu_cot_co_tien_b_r2.py`, original latest masters + all six atlases. New R3 path is **code scene + energy layer**.

## G3 provenance / paths
- R3 scene: `godot/labs/combat_lab/poison19_phu_cot_co_tien_b/r3/phu_cot_co_tien_b.tscn`, `phu_cot_co_tien_b.gd` controls approved stationary caster/real WALK monster sprite and R2 original RGBA.
- R3 real-time additive: `godot/labs/combat_lab/poison19_phu_cot_co_tien_b/r3/flow_light.gd`, 3 historical flight filaments evaluated at past projectile timestamps, no rig, dynamic additive emission. Source is GDScript first-party code.
- Focused source test: `godot/tests/labs/combat_lab/vfx_poi19_native_flow_r3_contract_test.gd`. Verifies source, Godot additive material, per-frame clock, moving-selected-target trajectory equality, 6.5s mark and no selected-secondary effect.

## G3.5–G8 independent QA
- Run initial Godot 4.7.2 strict import/parse + focused native test and G3.5 108-frame 1280×720 true **native** MP4 with charge t.21/peak t.98/contact t1.48 on moving target. Inspect at 1× and compare to owner natural-light goal. Do not claim art PASS simply from exact-SHA CI.
- Only AFTER G3.5 manual 1× review, render full 510-frame/8.5s native film with >=12 distinct screenshots and mark sustain / extinction checks. R3 native screenshot not a live PvE feature and no real Combat V2 receipt.
- At source commit: G3.5=NOT_EXECUTED; technical=NOT_EXECUTED; G5=NOT_EXECUTED; G6 owner visual=PENDING; PvE=HOLD; V6.3=OFF; Android/Windows physical QA=PENDING; no merge.
