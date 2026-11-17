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

## R2C G3.5/G3.6/G5 exact-SHA native result — 2026-11-17
- Source tested: `840fd37a3e2de2c0e9174204980661d7fff56f7f`; [GitHub Actions #44068338641](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44068338641) **SUCCESS**. Do not conflate later automatic art archive SHA with this tested source SHA.
- Original source script and all six true-alpha atlases + six transparent masters are archived on Draft PR #72. 80 independently changed code-painted source poses. The reference promotional image is NOT a sprite master and its pixels were not extracted/copied.
- True native Godot 4.7.2 Compatibility LAB `godot/labs/combat_lab/poison19_phu_cot_co_tien_b/r2/phu_cot_co_tien_b.tscn`: MP4 1280×720, 60 encoded fps, 510 frames, 8.500s, MP4 SHA256 `0529c76c599920ab153db5056a00374e9695acb3101fe53f4be5c21839c88d20`.
- G3.5 source charge at t.21, peak flight at t.98, single moving-target contact at t1.48 — all genuine native Godot screenshots. Moving selected V5 WALK actor plus separately moving unmarked decoy; caster uses approved art unchanged. Focused contract `POI19_IMMORTAL_MARK_R2_RESULT=PASS failures=0` on exact tested SHA.
- G3.6 native pixel probe (violet OR jade) over scene-specific idle ROI: charge +559, peak +1652, contact +3684. Persistent floating orchid at t2.30=125 pixels, t5.10=118, expiry t7.92=29, after fade t8.22=35 (35 background/actor pixels, not a remaining drawn mark). All QA thresholds PASS; quantitative visibility only, never automatic beauty PASS or proof of live Combat V2 status. The 8.5s LAB map has simulated contact at 1.35 and 6.5s sustained mark, not authoritative combat receipt.
- G5 full native 8.5-second movie and 20+ timed checkpoints + status-active/mid/expiring/cleared exist in source run artifact `poi19-r2-immortal-mark-native-840fd37a3e2de2c0e9174204980661d7fff56f7f`.
- G6 artist self-review: **candidate; still less painterly and cinematic than owner's high-detail violet xianxia reference**. At true native 1×, foreground orchid and underfoot seal are legible and 6-layer color separation improved, but large petal shapes are simplistic code-painted geometry and the tiny floating mark needs polish. Self-score: silhouette3/5, illustrated material3/5, color/brightness4/5, motion4/5, selected target contact4/5, duration/expiry4/5, distinct semantic4/5. Since critical art metrics <4, no `ART_PASS` and no owner approval claimed.
- Independent gates: G7 exact-SHA technical PASS; G6 owner visual review PENDING; G8 PvE integration HOLD, V6.3 OFF, Windows/Android physical QA PENDING. No gameplay, combat, save or merge changes.
