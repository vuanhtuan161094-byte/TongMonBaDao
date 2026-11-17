# POI20 R1 — Xà Ảnh Quấn Mạch · Tiên A (Liên Tâm)

Date 2026-11-17 · Draft PR #72 · `integration/pve-p0-playable-ui-20261103`. First unproduced immortal-A branch of next Cổ Độc active_02 after POI18/19; POI20 is a VFX production index only, canonical ID is `tmb.skill.poison.co_doc.active_02.immortal.a`.

## G0 — Canonical / source-only (no fabricated game effects)

Catalog `godot/data/combat/v63_immortal_combat_catalog.json`: `effect=poison`, `element=wood`, `shape=single_target`, `target_limit=1`, `poison_stacks=2`, `range=7.8`, `radius=0`, `cast_time=0.43s`, `cooldown=8.64s`, `projectile_speed=8.96 WORLD units/s`, `duration=8.5s`; hit_count not declared. This VFX does NOT apply a real stack, damage or debuff: actual Combat V2 release/receipt `RUNTIME_MAPPING_PENDING`, V6.3 OFF.

## G1/G2 — Color, recognizable silhouette, three clocks

User likes the existing JX1 Võ Đang #158 *quality*: small sharp white/silver energy shafts, pale lilac secondary body, low-alpha colored aura on dark terrain. **Only hierarchy/timing learned**; NO JX1 or unlicensed Source VL pixel copied. Keep Độc Tu distinct: **silver-hot white seam + rich transparent jade-green serpent trunk + faint orchid/lilac haze + tiny gold contact hints**. No giant snake anatomy, creepy head/eye, no repeated blank circles or UI labels to carry semantics.

The owner-approved Human Xà Ảnh baseline source assets under `poison02` remain **untouched and separate**. Human sprite is a design reference only; POI20 makes brand-new first-party painted light art. Two slender spirit-snakes refer to two visual poison channels of Tiên A Liên Tâm; target remains **ONE enemy**, not two independently hit enemies or guaranteed gameplay stacks. Back coils go *behind* the real WALK monster; front silk overlays only the torso, not an opaque sticker on the face. Light is streamed through native Godot `draw_polyline_colors` on a dedicated ADD child.

Three clocks:
1. **Declared combat:** cast0.43, cooldown8.64, duration8.5, projectile_speed8.96 world units/s. Real game hit/mark receipt UNKNOWN.
2. **Art LAB local:** charge t0–.43 hand current; release .43–.55; original luminous serpent travels .55–1.35 toward moving enemy; `simulated visual contact=1.35s`; t1.35–2.33 wrap grows on selected torso; one status remains until t9.85 (8.5s) then clean fade t10.17.
3. **Demo clock:** loop10.65s; first G3.5 108 frames=1.8s at encoded60 (not real physical FPS), charge .21, peak .98, moving-contact 1.48. Full 639 frames (10.65s) only after native 1× art checks.

## G3 — Five truly isolated first-party RGBA masters and atlas poses

Generation: `tools/vfx/generate_poi20_xa_anh_quan_mach_tien_a_r1.py`, Pillow original code-art: hand-authored curving path/interpolated segments, asymmetrical tapered white-hot filament, faint jade diffuse layered RGB, gold hints. No poster crop, chromakey or rig. Five independent transparent master PNGs plus changing 60 source poses:

- `gather`: 8×256×256, original two independent current streams gather at palm.
- `flight`: 16×384×256, one recognizable compact serpent-energy body with living tail and white head.
- `coil_back`: 12×320×320, two serpent coils **behind** chosen WALK actor.
- `coil_front`: 12×320×320, two independently changing front strands.
- `mark`: 12×256×256, two tiny venom strands as readable floating mark during 8.5s.

Original master+atlas under `godot/labs/combat_lab/poison20_xa_anh_quan_mach_tien_a/r1/assets/`, separate GDScript Godot light layer `flow_light.gd` emits smooth live ADD charge, continuous time-sampled head/flight trail, two moving target-wrapping ribbons and small status glow, distinct from sprite MIX. Character art unchanged. No fake HP, actual poison stack or second victim.

## G3.5–G8 acceptance

- V4 packet `docs/operations/vfx_packets/POI20_R1_V4_PREFLIGHT.json`, focused test `godot/tests/labs/combat_lab/vfx_poi20_xa_anh_r1_contract_test.gd`.
- Real Godot 4.7.2 Compatibility scene `godot/labs/combat_lab/poison20_xa_anh_quan_mach_tien_a/r1/xa_anh_quan_mach.tscn`: approved Nữ Độc Tu fixture, one moving V5 WALK selected enemy, one independent decoy. Native 1280×720 charge/peak/contact screenshots, real 1× view.
- G3.7 check: visually obvious **snake-shaped flowing light quenching and coiling ONE target**; before/after ordering, no creepy creature or meaningless orb. Don't mark art PASS just because parser/atlas hash pass.
- G3.5 mandatory stop: source integrity and Godot test alone are insufficient; after reviewing three native 1× screenshots decide art quality before whole movie. Follow with G3.6 native brightness/target exclusion and G5 full10.65s if G3.5 visual good enough.
- At source staging: G3.5 `NOT_EXECUTED`, G5 `NOT_EXECUTED`, G6 owner art `PENDING`, G8 PvE `HOLD`, physical Windows/Android `PENDING`. No Codex, GIF or merge.
