# FIST14 R6 — why the VFX art failed despite V4: root-cause audit

**Date:** 18 Nov 2026 · **Owner request:** “xem lại quy trình vì sao mỹ thuật k đạt” · **Repository:** `vuanhtuan161094-byte/TongMonBaDao` · **Draft PR #72**.

**Scope and evidence:** read original [Art-First SOP V3 + Production System V4](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md), [Sprite Layer Pipeline](TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md), [Art Director skill](../../.agents/skills/tmb-vfx-art-director/SKILL.md), R6 source generator `tools/vfx/generate_fist14_r6_light.py`, R6 source/atlas description, R6 Godot LAB scene, V4 packet/validator/workflow, and **actual native 1280×720 charge/peak/contact** frames from [Actions #44355423136](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44355423136) on source SHA `67a4e90219f7786dd3fed5546eed8385b387bff0`. A second source revision `43183f70ef57c7a8d472fdffcc5a7d3f38167c18` was pushed to improve knuckle edges and energy body; its [native Actions #44356505548](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44356505548) was still in progress when last checked, so do **not** claim second-run native visual PASS based on the first movie.

## Executive finding

**This is a PROCESS EXECUTION FAILURE before an engine/render failure.** We correctly wrote V4 ART-FIRST requirements, then overrode them in practice: created a central bitmap from geometry with Pillow/Bezier, recognized it as neon-line/low-quality `G3 ART_SELF_FAIL`, but still authored Godot LAB scene, packet, CI workflow and invoked native movie capture. This is **precisely the anti-pattern warned against in V4**; automation correctly checks syntax/files/exact SHA, **not beauty**.

### Five root causes with exact evidence

| Stage | V4 required | R6 actually did | Consequence |
|---|---|---|---|
| G1 reference | Observe relevant martial/energy VFX **motion and material**; break down real sequence, without borrowing proprietary pixels | The references summarized sword styles and general wuxia images; the R6 brief itself acknowledged no timed authentic fist/chưởng clip | Direction/timing of compression, release, local contact not grounded in a fist beat. A written style slogan cannot replace motion study |
| G2 semantic | Clear **one-skill visual motif** in charge/strike/impact, size tested relative to real caster and enemy | The abstract curve composition was defined by numeric paths, not independently accepted silhouette contact sheet; no visual art stop before implementation | The intended “luminous fist pressure” looks like **energy threads/ribbons** and then a generic star |
| **G3 illustrated RGBA — principal root** | A true high-quality illustrated original source/master with distinctive authored changing key poses, material light hierarchy; frame changes purposeful | `generate_fist14_r6_light.py` uses `ImageDraw.line`, fixed Bézier path sets, polygons, blur, a few arcs for “knuckles.” Seven RGBA images are generated from line geometry. The report itself called source **procedural raster** and `G3 ART SELF FAIL` | Different path coordinates + different hashes =/= satisfying first-party **painterly or sculpted energy art quality**; at 1× the fine red lines vanish into disconnected glow, a few white crests never form coherent force |
| G4 animation/anchors | Correct actor **causes** hit; source → short movement → contact → rebound, target visible. No rig, no invented projectile | LAB still displays static `nu_doc_tu_v4_candidate` actor, not a fist attack; a separate attack sprite is snapped to moving target anchor immediately after cast. No convincing physical transfer from caster at near range | Reads as a **spell appearing on enemy**, not a powerful martial punch; `projectile_speed=0` must not be misinterpreted as “show impact without the causal action” |
| G3.5/G6 technical vs art | Early native 1× **STOP**, revise G2/G3 if shape fails. Exact-SHA QA proves only technical integrity | Self-identified art failure yet proceeded with one complete scene, Actions run, technical SUCCESS. V4 validator checks source exists/PNG size and distinct atlas pixel hashes, not quality/semantic motion. R5 had misleading uniform 4/5 art self-scoring | Green CI and full artifact perpetuate false perception that a VFX is nearly completed. Technical PASS must not release G3 ART block |

### What the real native first G3.5 proof shows

- **Charge (~0.20 s):** tiny thin pink loops around an actor who does not visibly punch.
- **Peak (~0.62 s):** two to three bright near-parallel curves stretched between actors, no solid luminous pressure volume or identifiable four-knuckle compression; central hero energy is **too weak at game 1×**.
- **Contact (~0.94 s):** radial pink star lines intersect the monster, but local white-hot impact does not read as a powerful single martial strike. Lack of coherent main mass/actor motion is not fixed by adding particles.
- Second art adjustment `43183f70` adds flat semi-transparent polygons and white knuckle arcs, but this is still **an incremental patch to geometric source**, not proof of the illustrated V4 G3 source. Only exact-SHA native footage can justify changes to native assessment; no automatic G3 artistic certification.

### Corrective action — **NO NEW SOP**, enforce existing V4 at the correct point

1. **G1/G2 before artwork:** one suitable filmed reference if accessible, otherwise label timing evidence missing; produce a concise sketch/storyboard of charge, pressure core, short-range extension and impact at the real actor scale. This is not a poster or UI card.
2. **G3 TRUE ART SOURCE FIRST:** create a new *painted-looking high quality, original, transparent 2D energy pressure master* and independently authored morphology key poses. Keep original raw PNG/WebP masters committed in GitHub, with 1× source-contact sheet and preserved alpha. No tiny crops of posters, no copied JX/VLTK pixels, no vector contours/blur as principal VFX visual. A code-baked Bezier study can support strands, particles and post-processing, **not be promoted as the painted core by itself**.
3. **Stop gate:** self-inspect source frames at the scale they will appear in Godot, next to caster/monster, before scripting a full LAB or triggering QA. If unreadable or visually generic, label **`G3_ART_SOURCE_FAIL`** and revise only source. Do **not** run additional 1.45s native movie/green CI to try to redeem a failed source. A later Godot G3.5 is still mandatory after real G3 art passes. **Minimize QA, not visual standards.**
4. **Actor/scene fidelity:** caster must give a legible punch *without rigging* (existing frame-by-frame actor attack or a permitted authored short strike cue), and the effect must be anchored near hand/contact with clear release/recoil. If no suitable original attack actor clip exists, mark **ACTOR_PUNCH_SOURCE_BLOCKED** rather than fake with a static Poison Tu model. No gameplay cast/receipt invented.
5. **Formal separation of approval:** `SOURCE_PROVENANCE_VERIFIED` / `G3_ART_PRECHECK_PASS` / `G3.5_NATIVE_TECH_PASS` / `G3.6/3.7_SELF_REVIEW` / `OWNER_VISUAL_APPROVED` / `PVE_INTEGRATED` are different. No automatic beauty PASS from hashes, red-pixel ROI or GitHub Action SUCCESS.

## Immediate status / prevention of repetition

- **FIST14 R6**: code/scene/procedural source exists, first G3.5 TECH PASS, but **G3_ART_SOURCE_FAIL; G3.7 SEMANTIC_FAIL; OWNER_VISUAL_PENDING; PVE_HOLD**. Prior R2/R3/R4/R5 kept frozen. Continue from **actual illustrated source redesign**, not current Bezier artwork shader/glow tweaks.
- **Workflow remains the existing verified native runner** for *later* valid art; **do not waste Actions on failed G3 sources**. No new CI systems or bureaucratic QA rounds required.
- **No Codex Cloud** per latest owner instruction; ChatGPT is direct producer. No rig, GIF by default, gameplay/SaveService changes or merge.
- **This is a process failure by the implementing assistant, not a reason to lower artistic expectations or to abandon Godot.**
