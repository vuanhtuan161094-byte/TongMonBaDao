# HF02 R6 — Liên Diệm Phần Giới | V4 genuine Godot visual QA

**Date:** 2026-11-16  
**Repository:** `vuanhtuan161094-byte/TongMonBaDao`  
**PR:** [#72 Draft](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72), existing branch `integration/pve-p0-playable-ui-20261103`  
**EXACT tested R6 art/source SHA:** `b5a29f1504078a0e66acc9c79306dc86f5f28463`  
**Revision:** HF02 R6, charge + cosmetic flying seals; original R5 painted explosion kept unchanged  
**Status:** `G3_5_NATIVE_CAPTURE_TECH_PASS`, `FULL_NATIVE_MOVIE_TECH_PASS`, `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, `PHYSICAL_WINDOWS_ANDROID_PENDING`.

## Real technical evidence

- **Production System V4 G3.5** [run #43796504460](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43796504460), SUCCESS, Godot 4.7.2 Compatibility, 96 frames fixed 60. Artifact `14194657255` (three native 1280×720 PNGs charge 0.30, peak 1.28, contact 1.49, mini MP4, V4_MANIFEST.json, source-SHA integrity, fail-closed missing-contact negative test).
- **Full native QA** [run #43796504489](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43796504489), SUCCESS, artifact `14194687188`. Genuine Godot 4.7.2 Compatibility MP4 **1280×720, 198 frames, fixed output clock 60 FPS, 3.3 s**, GIF, 14 PNGs, source + atlas hashes and focused contract logs. FFprobe verified resolution and frame count. Fixed movie frame clock does NOT establish Android/Windows hardware FPS.
- All 14 GitHub screenshots taken at .12, .30, .43, .58, .70, .86, 1.10, 1.28, 1.38, 1.49, 1.62, 1.84, 2.22, 2.75s. Human comparative inspection of eight charge/launch/travel/contact/after-hit frames confirmed stage ordering in the native video. Three walking monster sprites remain visibly moving.

## Real HF02 gameplay contract vs visual clock

| Authority/clock | Values |
| --- | --- |
| Catalogue/Combat authority | `tmb.skill.talisman.hoa_phu.active_02.human`, FIRE damage, CIRCLE radius 2.1, target cap 3, one hit, cast 0.62s, cooldown 10.8s, projectile speed **0**, status duration **0** |
| Runtime event receipts | **RUNTIME_MAPPING_PENDING**, no claims of actual live event dispatch, damage, HP or target acquisition |
| R6 cosmetic VFX LAB | charge .02–.70, four animated visual-only gold-red 火 talismans fly staggered .52–1.36 towards fixed declared lab circle, original R5 lotus starts .79, simulated local contacts 1.37–1.72 on the *current positions* of the three preselected moving targets, fade by 2.62 |
| Demo-only movie | fixed-length 3.30s playback; **not** the 0.62s cast duration |

A talisman visually crossing the scene is **not a gameplay projectile**. There are exactly four *cosmetic* flying talismans and **zero live projectile instances**; target cap, hit count, range and all Combat V2 rules remain untouched. Ground circle and targets already exist as view-only stand-ins.

## Durable provenance

- First-party TMB gold-red 火 scroll master: `godot/labs/combat_lab/talisman06/art_sources/hf01_r5_talisman_master_png.b64`, preserved unchanged.
- First-party generated Hỏa Phù owner-reference source `godot/labs/combat_lab/talisman07/art_sources/hf02_r5_owner_fire_blast.webp.b64`, preserved unchanged. **Known limitation:** R5 explosion source is still a 320×91 concept crop; not the full illustration nor a fully painted full-res explosion master.
- **New original source baker:** `tools/vfx/hf02_r6_talisman_motion.py` derives 12 charging-pose transparent atlas cells and 12 cosmetic flying-pose transparent atlas cells from those documented first-party masters. This keeps original painted material within the new frames, with independent transforms and light material: it does **not** claim hand-painted 24 unique full-scene master paintings.
- Outputs built before Godot import and archived with checksum in CI (not claimed as Git-tracked WEBP binaries):
  - `godot/labs/combat_lab/talisman07/assets/tal07_r6_charge_atlas.webp` — 12 × 320×320, atlas 1280×960;
  - `godot/labs/combat_lab/talisman07/assets/tal07_r6_flying_atlas.webp` — 12 × 320×192, atlas 1280×576.
- Original R5 `tal07_r5_lotus_atlas.webp`, `tal07_r5_contact_atlas.webp` and ground source are **not repainted**. The R5 visual explosion and moving-target contact stay intact.

## G3.5 native-scale self-review and limitations

- **Charge 0.30s:** four actual gold-red talisman symbols gather around a distinct central painted white-gold energy core rather than a code-only circle; reads at 1×. A slight R6 correction at `b5a29f15` brightened the core after native source comparison. Internal visual impression ~4/5; owner approval pending.
- **Flight .58–1.28s:** four visible talismans trace a curved launch path with orange-gold painted tails, not repeated white vector needles, and the four marks resolve towards the *fixed area* rather than home each enemy. Readability/continuity ~4/5, owner pending.
- **Contact 1.49–1.62s:** R5 blast does not vanish; three walking enemies remain readable with brief local fire hit accents. No dark square matte seen in selected reviewed native frames. Explosion still inherits lower resolution and lacks some of owner's concept illustration's painterly depth: 3.5/5; do NOT self-certify art success.
- **Color/material:** no unlicensed Source VL/JX frames; saturated yellow/gold/red, painted material + subtle bloom; screen scale still a deliberately minimal isolated combat lab. Art contact/source fidelity remains below reference poster.
- **Post-visual gate:** Technical QA SUCCESS only, visual self-review for owner **PENDING**, performance/physical hardware **NOT_EXECUTED**. Do not automatically integrate into live PvE or promote as a global VFX baseline.

**Explicit non-changes:** No Codex, skeletal rig, new branch, merge, Combat V2, SaveService, economy, AI, PvE or V6.3 modifications.
