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

## R1C Native Godot G3.5/G3.6/G5 exact-SHA result — 2026-11-17

- Initial source commit `1e426fab0edd90ad41738de158a6a49c9a6611c6`: generator produced 60 original RGBAs; V4 first gate failed until `receipt_claim=SIMULATED_VISUAL_ONLY` explicit; no gameplay or art was affected. Subsequent first native [Actions #44133329003](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44133329003) tech PASS, but G3.5 actual 1× contact visually resembled concentric UI circles, **ART SELF FAIL**.
- G3.7 silhouette correction: `f56e57d20c58f9f3fe1d2b9ebe08cb8be8396597`, [Actions #44134321790](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44134321790) native G3.5 tech PASS. Reworked independent snake atlases + Godot additive light: two **asymmetric vertical S-shaped serpent bodies**, top-down wrapping around ONE independently WALKING target, old circle motif abandoned. Actual contact image clearer and on-theme; head shape and details still owner art pending.
- **Final R1C exact tested source SHA `26f759a629adac63bffe07fa33f24ea967bab537`**. [Actions #44135139429](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44135139429): **SUCCESS**. Godot 4.7.2 Compatibility 1280×720, real `v4-poi20-r1-native.mp4`: **639 encoded frames at 60 FPS; 10.650 seconds**. Frames are GENUINE GODOT running VFX, not an offline poster/montage. Five source-transparent master PNGs and five atlases archived at subsequent art-only commit `bb2042bdfad43f34ac4815a57e241c0fdb9c8677`. Preserve first-party original reproducible Python/Pillow generator.
- G3.5 genuine native charges t0.21, projectile t0.98, contact on independently moving selected monster t1.48, all captured and visually inspected at native game 1×. Human approved Xà Ảnh and JX commercial source pixels not altered or copied.
- G4 strict Godot focused test `POI20_XA_ANH_R1_RESULT=PASS failures=0`; target_limit1, declared poison_stacks2 as metadata only, VFX no Combat V2 hit/status/damage, 8.5s LAB-clock duration, no effect on independent decoy.
- G3.6 measured genuine 1× bright-jade/ivory pixel ROIs vs idle frame: **charge +304**, **peak +1578**, **contact +2993**; all exceed thresholds 180/600/700. Selected target marking counts: t2.30 **1017**, t5.10 **1094**, t9.75 **794**, t10.04 **229**, t10.27 **176** residual moving-actor/background pixels (not a remaining visual mark). The visible light fully clears by 10.27s. **Pixel QA proves legibility/expiry only, never beauty or real gameplay status.**
- G5 native whole cycle from t0–10.65 and >=22 distinct checkpoint PNGs, status active/mid/expiring/fade/clear. Built-in Godot rendering uses separate ADD gradient `draw_polyline_colors` source synchronized with original MIX RGBA back/front snake layers (no skeletal rig), and moving V5 WALK monsters.
- Manual self art score at 1× (out of5): readable serpent silhouette **3**, JX-style core purity **4**, flowing action **4**, contact meaning **4**, sustained mark readability **4**, artistic richness **3**, fade **4**. R1C is a real playable-lab candidate with restrained glowing two-channel wrap, **still lacks some high-detail illustrated serpent head/material compared with owner's admired Võ Đang effect**. Therefore status **TECH_PASS, ART_OWNER_PENDING**, not approved for PvE.
- Independent gates: G6 owner art approval PENDING; G7 technical exact-SHA PASS; G8 PvE/V6.3 HOLD, Windows/Android device FPS untested; PR #72 still Draft, unmerged.
