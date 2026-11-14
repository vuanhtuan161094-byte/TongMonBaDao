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
## Executed R1 → R3 proof and artistic review — 2026-11-14

**R1 at code SHA `1288e0f63acfe0aa2ff0fdfdd2aee1dc20bf4dd4`:** Godot strict parse FAIL on three locally inferred array-index values `offset_x`, `offset_y`, `dx`; artifact `vfx-poi04-1288e0f63acfe0aa2ff0fdfdd2aee1dc20bf4dd4` (run #43553956184) shows exact parser messages. All three floats explicitly typed before the next run. No film from R1; NEVER claim R1 PASS.

**R2 at code SHA `9c877acff6653d5768ccc04ee18f88fb948f9169`:** [Godot Actions #43554117799](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43554117799) SUCCESS, focused contract `VFX_POI04_FOCUSED_RESULT=PASS failures=0`, native 1280×720 movie (270 frames, 4.50 seconds, fixed 60fps), frame checkpoint images. Actual visual inspection at 0.48, 1.18, 1.57, 2.12 seconds found **artistically underpowered smoky puddle**; sprite mist not tall/bright enough behind the targets. R2 ART_REWORK_REQUIRED notwithstanding test PASS.

**R3 at code SHA `d5e2339b804c6685d7866e85045e2e3b24c20fd3`:** [Godot Actions #43554393311](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43554393311) completed SUCCESS. Official Godot 4.7.2.stable.official.ed1daf0bf, Compatibility GL via Xvfb/Mesa, strict import/parse and `VFX_POI04_FOCUSED_RESULT=PASS failures=0`. Actual `--write-movie` **1280×720, 270 frames, 4.50s, encoded 60fps**. This is not measured real GPU FPS on Windows/Android. Full artifact ID **14096834867**, name `vfx-poi04-d5e2339b804c6685d7866e85045e2e3b24c20fd3`, includes MP4, SHA256SUMS, 14 native checkpoint PNGs, timeline, import/parse/movie/test logs.

Actual R3 video+stills inspected at 0.48 (charge with gu moth image, hand clear), 1.18 (single painted flying moth/vapour tail), 1.57 (zone expanding behind three target sprites), 2.12 (high full poison mist with tall purple-green curls), 2.45/2.78 (sustained image layering), 3.54 (fading), 3.91 (clearing). Front green ground veil leaves all three actor heads/readability intact. R3 is meaningfully more pronounced than the rejected R2 without solid neon discs or black opaque patches.

**Art judgement:** R3 is a **Godot LAB owner-review candidate**, not a claimed Source VL commercial-equivalent final. Remaining possible improvements: stronger localized contact color contrast, more character-specific caster/source artwork rather than repeated dummy targets, deeper wing motion and nuanced smoke plume timing. LAB rendering runs only on fixed scene timeline; real Combat V2 status/damage/target receipts are NOT bound. `GODOT_FOCUSED_PASS / OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD`.

**Provenance:** three new original SVG textures for fog, wisps and spirit moth authored specifically for the game; no copied JX or Source VL pixels in the skill. Skill remains `poison / circle / declared radius 3 / target cap 3` without creating a fourth hit or any real proc. No rig, no Codex, no branch/merge or edits to approved Xà Ảnh/Phụ Cốt, AI, Combat V2, SaveService, economy or V6.3.

**User-friendly media:** video MP4 optimized for browser (`-movflags +faststart`), GIF preview, PNG phase strip and ZIP backup generated from **actual R3 Godot movie**, in addition to GitHub Actions full QA archive. Keep file download/access concerns in mind when sharing.
