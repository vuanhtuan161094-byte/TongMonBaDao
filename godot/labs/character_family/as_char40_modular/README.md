# AS-CHAR-40 — Real no-rig modular character LAB (presentation only)

Technical source packet for **authored RGBA frame layers**. Current status **ART_PENDING**, because no new beautiful and approved Shadow Pixel-Chibi disciple body/Walk source is ready. This lab explicitly refuses to invent animation when `export_manifest.json` is missing.

**Not a rig.** AnimatedSprite2D body and two frame-synchronized weapon sprites in front/behind; weapon textures are genuinely authored frame by frame. Foot canvas 128×128, pivot (64,104); nearest filtering. No VFX inside body, no attack events or gameplay state updates.

**Pack source:** `TMB_DISCIPLE_MODULAR_V1.zip` created in the linked ChatGPT session. Contains full Python Pillow pixel composer, native 128×128 alpha/anchor/source verification, 14/14 focused Python tests, two weapon variants, face/hair/outfit selection, export SHA manifest and GIF previews. **The ZIP's source bytes are not auto-included in GitHub by this README.** Install the authoring tool from the ZIP before running the lab; do NOT use old code-drawn/painterly candidates in place of real pixel layers.

After an actual original pixel master has been painted and approved, export:
`python tools/build_modular.py source/actors/male_base_v1/actor.json --out godot/labs/character_family/as_char40_modular/out --godot-res res://labs/character_family/as_char40_modular/out --face calm --hair silver --outfit cobalt`

Open `res://labs/character_family/as_char40_modular/godot_modular_actor_preview.tscn` in official Godot 4.7.2. Press **1–6** for a state, **D** to change direction, **E** to change weapon. Missing clips remain missing, not synthesized. The engine has **not** been run for this packet in the ChatGPT execution environment.

Preserve 12-school owner-liked style design, prior locked source identity and baselines. No rig/Skeleton2D/Bone2D, code-generated primitive character, pixelation filter, production integration, SaveService/gameplay changes, branch or merge. PR #72 Draft, Issue #77.
