# TMB — Disciple Modular Sprite Standard V1 | AS-CHAR-40

**Status: ENGINE-PACKET TECHNICALLY TESTED IN PYTHON / ART_PENDING / GODOT_ENGINE_NOT_RUN.** 2026-11-14.

**Explicit latest owner contract**: no rig, no bones, no skeleton deformation, no whole-image shaking as animation; preserve the liked Shadow Pixel-Chibi 12-sect palettes and original approved character identities; do not replace the owner-accepted earlier Idle/Walk and Attack assets. A smooth anime board is not native pixel art. Do not reuse the Code-authored rejected Kiếm Tu pilot.

## Why this package exists

- Actual **layer-aware asset compiler** (source PNGs → body/weapon atlases, JSON provenance, real GIF preview, Godot SpriteFrames) with deterministic output.
- **Swappable weapons**, with identical body pixels regardless of weapon item; each *authored* frame has grip position and a true weapon front/back 128×128 canvas. When replacing a steel jian with a jade jian, no base-body frames are redrawn. Changing from a jian to a bow, spear or dao requires a compatible **weapon-family action pack**, not magically rotating a sword animation.
- **Swappable outfit, face, hair at authoring time** via per-frame variant-layer PNGs, without rerendering face/costume through AI prompts. Output body atlas is precomposed for efficiency, while weapon stays a separate `AnimatedSprite2D` actor.
- No appearance item is allowed to award equipment or damage stats: real inventory/equipment authority must approve runtime selection in a separate gameplay package.

## Source geometry

- Canvas **128×128 RGBA**, foot `(64,104)`, 60–75 logical px visible; four real directions `front,right,back,left`, and six real states `idle,walk,attack,cast,hit,death`.
- One source directory **per actor/clip**. `actor.json` lists *actual* edited RGBA PNG layers for every frame. No missing layer or frame will be generated from thin air.
- Required **`body_base`** and **`underwear`**: form-fitting underbody, not nude, readable joint and anatomy. It is the permanent body/color-volume/pose reference, **not an automated rig**.
- Optional/selected layers (back-to-front): `hair_back`, `body_base`, `underwear`, `face`, `eyes`, `hair_front`, `outfit_inner`, `outfit_outer`, `sleeve_left`, `sleeve_right`, `boots`, `ornament`. Every per-frame layer must be real pixel artwork where geometry changes.
- `variants.faces`, `variants.hairs`, `variants.outfits`: selected layer replacements *for the exact frame and direction*. An unavailable variant is an explicit ERROR, not a recolored shortcut.
- `weapons[ID]` declares one `family`, grip at or within 2px of `anchors.hand_r_grip`, and `front`/`back` separate RGBA PNGs that already depict the correct pose. NO baked weapon in body; projectiles and skill VFX separate.
- Same family can share animation timings and socket conventions. **Different weapon families may require different actual pose art** and never inherit incompatible hand geometry automatically.

## Authoring workflow, one genuine actor before 12 schools

1. Freeze already-liked 12-school art palette/design, and one original verified identity via actual bytes and source SHA. No reinterpreting the look from generic generated pictures.
2. Draw **one** face-neutral, form-fitting clothed base body *at actual pixel scale*, four genuinely authored directions. These are source pixels to paint in a pixel editor (LibreSprite), not Python geometric primitives as final art. Review at native 1× and nearest-neighbor 6× against an accepted reference. **Owner visual gate is mandatory**.
3. Paint face/hair/outfit as actual layered source(s) for the same pose and directions, reconstruct hidden anatomy. The underbody should not become visible through clothing.
4. Draw true Walk key poses `left contact → passing → right contact → passing` with separate legs, arms, hair and robes. Register actual hand/weapon locations; QA GIF and export native PNGs before the next state.
5. Attack: `windup → hit/release → follow-through → recovery`; Hit: true recoil; Death: collapse and stay down; Cast distinct from Attack. Never use one moving still as multiple clips.
6. Only when 1×/6× visual accepted, expand directions, female base, then other states and school wardrobe packs. Do not scale a bad source into 48 clips.

## Folder layout

```
source/actors/male_base_v1/actor.json
source/actors/male_base_v1/frames/walk/front/f00/body_base.png
source/actors/male_base_v1/frames/walk/front/f00/underwear.png
source/actors/male_base_v1/frames/walk/front/f00/outfit_blue.png
source/actors/male_base_v1/frames/walk/front/f00/outfit_gold.png
source/actors/male_base_v1/frames/walk/front/f00/jian_blue_front.png
source/actors/male_base_v1/frames/walk/front/f00/jian_gold_front.png
out/<actor>__body__walk_front.png
out/<actor>__jian_blue_front__walk_front.png
out/<actor>__jian_blue_back__walk_front.png
out/<actor>__body.tres
out/<actor>__jian_blue_front.tres
out/<actor>__jian_blue_back.tres
out/export_manifest.json
```

## Run build

```
python tools/build_modular.py source/actors/male_base_v1/actor.json --out godot/labs/character_family/as_char40_modular/out --godot-res res://labs/character_family/as_char40_modular/out --face calm --hair silver --outfit cobalt
python -m unittest discover -s tests -v
```

Copy `godot_modular_actor_preview.gd` and `.tscn` into `godot/labs/character_family/as_char40_modular` **only after real valid source exists**. Open the scene in Godot 4.7.2; press 1–6 for states, D direction, E next weapon. The preview uses body SpriteFrames and **two synchronized weapon atlas nodes**; no rig. **This Python environment has not run official Godot 4.7.2**, so no engine PASS is claimed.

## QA gates

- G0 authentic source identity + SHA; G1 beautiful native pixel character at 1×/6× (human approval); G2 four authored directions; G3 outfit/hair/face and weapon-swap tests; G4 real distinct movement GIF; G5 official Godot 4.7.2 source-SHA GUI and clip playback; G6 owner visual approval, then separate production integration.
- Compiler rejects missing PNG, partial-alpha layers, cropped transparent edges, invalid canvas/pivot, duplicate fake walking poses, unknown layer, baked-in weapon key, incompatible weapon family, detached grip, missing variant, absent indices, fake approval without evidence, and approved flag for incomplete clip sets.
- Tests run on **artificial rectangles kept inside the test suite ONLY**. They are not game character assets or art style examples. **14/14 technical tests PASS**, not graphic/engine approval. Current actual character art remains blocked and is deliberately not shipped as production.

## Source constraints

Use only existing project source or personally authorized original artwork. Do not silently copy Source A/JX commercial sprite art or infer licensing from accessibility. Preserve PR #72 Draft on `integration/pve-p0-playable-ui-20261103`; no gameplay, SaveService, combat, economy, player saves, branches or merge.