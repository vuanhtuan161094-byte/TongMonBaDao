# POI19 R2 — Phụ Cốt Cổ · Tiên B (Phệ Cổ): Lục Tử Lan Ấn

2026-11-17 · Draft PR #72. Skill authority: `tmb.skill.poison.co_doc.active_01.immortal.b`, catalog `godot/data/combat/v63_immortal_combat_catalog.json`, branch poison/Độc Cổ Tiên B. This revision directly responds to owner criticism that POI19 R1C VFX is too sparse and the decorative reference is much more luxurious. An attractive model-generated poster previously shown is **NOT IMPLEMENTED** or a proof and is **NOT SUITABLE sprite source**.

## G0 — exact canonical contract / hard limits
Effect=mark, element=wood, shape=single_target, target_limit=1, radius=0, range=7.8, cast=.43s, cooldown=9.6s, projectile_speed=8.96 world-units/s, duration=6.5s, no authoritative hit_count. Damage/power ratio metadata not a VFX receipt. No AoE, damage, poison stacks, target duplication, health change, live Combat V2 or SaveService writes. V6.3 OFF.

## G1 — visual source + rights
First-party reproducible **code-painted RGBA** illustration in `tools/vfx/generate_poi19_phu_cot_co_tien_b_r2.py`, six independent original transparent layers. Original source pixels created from coded smooth floral contours, satin folding petals, fine gold veins, diffuse violet lilac spirit curtains, jade-green hot edges, pale-white pearl. The owner's rich purple-JX-style screenshot is **style inspiration only**: do not crop it, copy licensed game material, invent a giant AoE ring or skeletal monster, or claim it was rendered in Godot. Original accepted Nữ Độc Tu actor unchanged.

## G2 — three-clock and semantic storyboard
Canonical combat clock .43s cast, 9.6s cooldown, mark6.5s, 8.96 world-units/s projectile; actual release/hit/mark receipts `RUNTIME_MAPPING_PENDING`. Local cosmetic LAB alone: 0–.43 five differently contoured orchid petals gather a pearl at caster; .43–.55 release; .55–1.35 16-pose pearl flies continuously towards selected moving monster; 1.35 *simulated contact*, never a real gameplay status; 1.35–2.06 16-pose five-petal violet bloom **folds inward** around only selected target; a restrained silk veil is briefly visible; 1.35–7.85 one small underfoot ceremonial sigil and floating orchid mark attach to target; mark fades 7.85–8.10; LAB cycle8.50s. No effect on independently moving second WALK monster. The small *underfoot* ring is decorative status mark, not AoE geometry.

Visual semantic: the player sees pearl → flight to one enemy → orchid folds & binds that enemy → small floating sustained orchid, clearly distinct from POI18's two-leaf heart-linked mark. Color violet/lilac dominant, jade/gold accent. No horror insect, moving bones or roaring dragon copied from the inaccurate reference.

## G3 — source layers
Six new isolated transparent atlases, 80 distinct source poses:
- gather12, 320×320; five changing petal poses, hot pearl core
- seed16, 384×256; flying orchid-pearl, restrained wake
- fold16, 384×384; inward closing petal contact, not burst damage
- mark12, 320×320; sustained one-target orchid above head
- ground12, 384×256; small low-perspective decorative foot binding
- veil12, 384×320; local violet-jade translucent ribbons behind target

Source files under `godot/labs/combat_lab/poison19_phu_cot_co_tien_b/r2/assets/` are generated and committed separately on exact-SHA GitHub Actions; no skeletal rig, no GIF, no threshold poster cropping. Native Godot 4.7.2 Compatibility 1280×720 controls color/alpha composites and continuously follows independent WALK enemy.

## G3.5–G8 independent gates
G3.5 short 108-frame/1.8s **genuine Godot** native first: t=.21 charge, t=.98 peak flight, t=1.48 selected moving enemy contact. Inspect native 1× against owner style in dark/bright areas. G3.6 visibility / G3.7 semantic acceptance are separate, not inferred from original-alpha checks. **STOP before long 8.5s movie** if rich materials, petals, contact, silhouette or readability look bad. G4 moving-target/no damage focused Godot script, stage packet validated with V4. Only after manual G3.5 visual pass capture G5 8.5s, >=12 checkpoints. G6 owner art approval still pending. G7 exact-SHA CI ≠ ART PASS. G8 PvE/physical Android QA HOLD. No Codex, new branch, merge, V6.3 enable, gameplay modification.
