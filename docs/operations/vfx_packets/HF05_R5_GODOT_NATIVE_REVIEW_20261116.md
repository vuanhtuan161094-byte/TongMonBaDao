# HF05 Vạn Phù Phần Thiên R5 — Godot 4.7.2 actual native movie and production status

**Date:** 2026-11-16. **PR:** #72 Draft, branch `integration/pve-p0-playable-ui-20261103`. **Skill:** `tmb.skill.talisman.hoa_phu.ultimate.human`.

## Exact canonical VFX / no gameplay modification
Catalogue: **FIRE damage**, **CIRCLE radius 2.8**, range **9.5**, target cap **3**, **one hit**, cast time **1.05 seconds**, cooldown **23 seconds**, projectile speed **0**, persistent duration **0**, canonical damage ratio **1.58** (read-only). The golden paper constellation and staggered rain are **cosmetic** and never spawn runtime projectiles, damage ticks, statuses, or extra hit receipts. Three independent Godot WALK monsters are preselected visual stand-ins, not live targeting. `RUNTIME_MAPPING_PENDING / V63_OFF / PVE_INTEGRATION_HOLD`.

## Real technical proof
- **V4 three-frame actual Godot G3.5:** [Actions #43810368432](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43810368432), **SUCCESS**, exact source SHA **`b14391041439d87e31eb4901b0ad9725480d86b5`**; actual 1280×720 PNG at .52 charge, 1.44 peak (moving paper cloud / fire rain), 1.96 local moving-group contact; fixed 125-frame preview; source/atlas checks, V4 manifest SHA and negative missing-contact fail-closed test. Godot version 4.7.2 Compatibility.
- **Full actual native Godot movie:** [Actions #43810368486](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43810368486), **SUCCESS**, same exact SHA `b14391041439d87e31eb4901b0ad9725480d86b5`. Artifact **`14200291637`**, name `vfx-tal10-b14391041439d87e31eb4901b0ad9725480d86b5`. Real Godot 4.7.2 native **1280×720 MP4, 201 encoded frames at fixed 60fps (3.35 seconds)**, GIF, 15 PNGs, original RGBA atlases, source checksums and focused logs.
- MP4 SHA256 (actual exported media): **`23cd87f9326276318f4056a17c2b7a7fbf6f57d316acf012ca6a619d2559e0b9`**. Strict import, GDScript parse and focused test `VFX_TAL10_FOCUSED_RESULT=PASS failures=0` with cap3 WALK current-position anchors; FFprobe verified 1280×720 / 201 frames.
- **15 human self-review checkpoints**: 0.12, .33, .52, .70, .92, 1.11, 1.26, 1.44, 1.68, 1.82, 1.88, 1.96, 2.07, 2.38, 2.87s; true Godot captures, NOT AI generated showcase photos. The generated promotional concept may serve art direction, never a technical QA screenshot.

## Source / art honesty
- New first-party TMB original illustration: a golden-red `炎` large paper talisman isolated from a new conceptual illustration into transparent **96×132 WebP** source, permanently committed at `godot/labs/combat_lab/talisman10/art_sources/hf05_original_van_phu_hero_master_rgba.webp.b64`. No whole promotional poster, captions or mock UI imported. Rights: created for this user/project; no Source VL/JX/Source A commercial image crops.
- Supporting project-owned first-party masters: `talisman06/art_sources/hf01_r5_talisman_master_png.b64` for small gold-red paper scroll and `talisman07/art_sources/hf02_r5_owner_fire_blast.webp.b64` for alpha-unmatted warm fire. Generator `tools/vfx/hf05_r1_van_phu.py` uses these to produce **16 charge / 24 continuously moving paper storm / 20 descending fire rain / 12 original fire impact** alpha poses, 72 cells total. Source stays committed, binary WEBP atlases are baked on CI and archived with 30-day artifact retention. The atlas frames are **composites of painted original image materials**, not 72 independently hand-painted full images.
- Quality limitation: the independent `炎` source is only 96×132, so painterly detail at large native game zoom remains lower than the full concept. The visual has an atmospheric dark lab backdrop, **not the actual PvE scene nor a bright-terrain test**.

## Three clocks (must stay independent)
1. **Canonical runtime:** cast 1.05s, cooldown23s, projectile_speed0, radius2.8, cap3, hit_count1; actual Combat V2 damage event timestamp UNKNOWN.
2. **LAB visual:** charge .02–1.00, painted sky constellation .59–1.90, descending paper/fire 1.19–2.03, a **single** illustrated fire-circle contact 1.85–2.17 follows all three CURRENT moving WALK monster body positions, giant painted chief seal persists briefly across impact (1.63–2.20), luminous residue fades by 2.74. All timing simulated in isolated LAB only.
3. **Movie loop:** 3.35s fixed Godot proof recording, not cast or cooldown nor real Android FPS.

## Actual art rework decisions
- **R1** passed source/technical V4 but FAILED internal visual review at native 1×: dull muddy fire, small local contact, papery cloud more legible than forceful explosion.
- **R2** raised original RGBA flame purity and localized white-gold fire; still undersized impact.
- **R3** expanded source-painted asymmetric fire across cap3 group, without over-covering 3 actors.
- **R4** maintained a large painted `炎` mega-seal across the single zone contact for identity and force, preserving source.
- **R5** replaces 60fps sampled flipbook jumps with **smooth adjacent-cell blend** for four separate real painted sprite layers (no rig, no extra art source, no combat semantics change). In a reproducible 201-frame MP4 ROI at x=630–1260, y=145–640, pixel mean absolute frame-difference 95th percentile decreased from **13.48 (R4) to 8.25 (R5)**; the max dropped from 18.25 to 15.09 (8-bit RGB scale). This is a perceptual movement-change *proxy*, not proof of universal artistic quality or measured engine performance.
- 15 R5 native frames show the `炎` card visibly at charge and contact, 3 moving actors still legible, fire pulses within the intended circle, atlas/card alpha background transparent. Shortcomings vs full promotional concept remain, especially limited resolution and less dense rain.

## Gate distinctions
`HF05_R5_ORIGINAL_SOURCE_DURABLE / V4_G3_5_TECH_PASS / FULL_GODOT472_NATIVE_201FRAMES_TECH_PASS / INTERNAL_ART_REVIEW_PARTIAL / OWNER_VISUAL_PENDING / RUNTIME_MAPPING_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_WINDOWS_ANDROID_QA_PENDING`.

The owner must evaluate the **real native R5** clip before any formal beauty approval. No Codex, skeletal rig, new branch, merge, Combat V2, SaveService, economy, monster AI, PvE or V6.3 changes. Prior **HF04 R3 is owner-approved for provisional use only**, with phoenix shape/smoothness rework deferred, not falsely an art-final PASS.
