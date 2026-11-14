# VFX-POI-04 — Cổ Vụ Mê Tung / painted poisonous mist field
Date 2026-11-14 | Godot 4.7.2 Compatibility | PR #72 Draft | isolated LAB only

## Canonical gameplay authority — verified JSON
- Exact ID: `tmb.skill.poison.co_doc.active_03.human`; school poison, branch Cổ Độc, Human active.
- Declared effect=`poison`, shape=`circle`, target_limit=`3`, radius=`3`, range=`7`, cast_time=`0.65`, cooldown=`12`, projectile_speed=`8`, duration=`7`, poison_stacks=`1`.
- No runtime damage/poison, no new target selection or status changes. LAB may display **three dummy actors only**, not guaranteed three hits. Combat V2 owns all hit/poison events. V6.3 and PvE stay OFF.

## Style: Source VL quality without snake/gu recolor
- Different from Xà Ảnh: no snake body/coil and no oversized glowing loops.
- Different from Phụ Cốt Cổ: not a single beetle attaching a seal.
- Main visual: **hand-authored independently layered smoke sculptures**, asymmetric jade-green inner billows with deep plum shadows, pale-lime broken thin highlights, discreet lilac ambient wisps; semi-transparent enough to see the targets.
- Use separate transparent SVG sprites: sculpted horizontal cloud layer, vertical drifting smoke strands, tiny moth/gu shadows. Blend MIX for forms, restrained additive for brief spark accent only.
- Floor boundary is a faint broken elliptical stain corresponding to preview radius; it does not create hitboxes or a permanently luminous neon circle.
- Three actual target sprites are visually distinct positions. Background fog behind them, thin transparent low front fog at their feet, not a screen-filling solid green plate. No rig.
- Source VL sword JX references only as rendering polish/timing language; no proprietary sprite copied. New art is authored TMB SVG. Source rights for commercial references remain unverified.

## Storyboard and exact native-film checkpoints (proposed VFX-only clock)
1. 0.00–0.65: caster gathers a compact toxic-fog pearl at hand; visible anticipation, without large generic magic circle.
2. 0.65–1.35: pearl travels from caster to zone center leaving short ink-smoke trailing sprite puffs.
3. 1.35–1.65: smoke breaks into a low, uneven ground pool; short localized contact brightness (no fake damage).
4. 1.65–2.20: multiple painted cloud billows expand around three preview actors, back layers deeper and front veil light.
5. 2.20–3.20: sustained small turbulence, lateral drift, moth shadows appear/disappear; zone geometry stays bounded and actors' heads visible.
6. 3.20–4.05: clouds thin into isolated wisps and motes; 4.05–4.50 returns to blank LAB.
- Native capture at 0.20, 0.48, 0.73, 0.98, 1.18, 1.37, 1.57, 1.82, 2.12, 2.45, 2.78, 3.15, 3.54, 3.91 seconds; evaluate video, not only frames.
- Red flags: fog looks like opaque blobs or clouds rather than poisonous magic; caster face blocked; goal area unreadable; bad looping; fake gameplay hits; generic rotated neon ovals; distracting saturated glow.

## QA and release gates
- Godot official 4.7.2, `gl_compatibility`, actual 1280×720 --write-movie, strict import/parse/focused test on code-exact SHA. 270 deterministic frames at fixed encoded 60 fps NOT physical hardware performance.
- Clip exported MP4, phase PNGs, GIF/ZIP access alternative; owner art gate separately `OWNER_VISUAL_PENDING`.
- Scene `res://labs/combat_lab/poison04/co_vu_me_tung.tscn`, code/assets only under `godot/labs/combat_lab/poison04`, independent test/workflow. No Combat V2 / AI / HP / SaveService / economy / real PvE modifications.
- Preserve approved Xà Ảnh Quấn Mạch and Phụ Cốt Cổ. No skeletal rigs, Codex or new branch.