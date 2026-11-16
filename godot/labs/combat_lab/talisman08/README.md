# HF03 — Hỏa Tâm Ngưng Phù | isolated first-party Combat Lab

Catalogue source: `godot/data/combat/v63_talisman_combat_catalog.json`, exact skill ID `tmb.skill.talisman.hoa_phu.active_03.human`. Hỏa Tu / Human active_03, fire damage **single_target**, cap **1**, hit count **1**, cast **0.5 s**, cooldown **12.2 s**, range **8.5**, projectile speed **9**, duration **0**. This is not HF02's circle/cap3/zero-projectile.

The owner explicitly approved HF02 R6 (10/10) on 2026-11-16; HF02 exact art SHA `b5a29f1504078a0e66acc9c79306dc86f5f28463`, keep unchanged. This HF03 uses a distinct composition: **ONE concentrated gold-and-red talisman channeling a burning fire-heart**, a single directional Hỏa Long fire-head scroll projectile whose tip meets **ONE locked moving WALK monster**, followed by a compact local hot burst and short sparks. No rig; no fake gameplay damage, status, homing acquisition, extra projectiles or AoE. Reuse *TMB-approved visual language*, not its frames, code or mechanics.

## Original source and art-layers
- New generator `tools/vfx/hf03_r1_fire_heart.py` recreates distinct source-painted panels from existing first-party `talisman06/art_sources/hf01_r5_talisman_master_png.b64` (96×132 gold/red paper), `hf01_r5_dragon_master_png.b64` (160×94) and `talisman07/art_sources/hf02_r5_owner_fire_blast.webp.b64` (320×91 first-party painted fire). Those original sources remain committed; **HF03 does not edit HF02 R6 artwork or source**. These are *re-compositions of TMB first-party painted source fragments*, not 38 independently hand-painted full-resolution master images; source-quality limitations and owner visual gate must be disclosed.
- New `tal08_r1_charge.webp` 12 × (320×320), `tal08_r1_projectile.webp` 16 × (320×192), `tal08_r1_contact.webp` 10 × (320×256), all alpha WEBP, staged in GitHub Actions artifacts rather than falsely claimed to be committed binary image files. Generator code is permanent.
- Native stage layers: previous monster real WALK texture remains in foreground; painted fire behind, one *small* white-hot contact core above, and bounded ember fade. No generic vector ring or candelabra.

## Explicit three-clock contract
- **Catalogue/Combat V2:** cast .5 s, projectile speed 9 world-units/s, cooldown 12.2 s, one hit/one target, no persistent duration. Actual runtime event/arrival timestamp unknown: `RUNTIME_MAPPING_PENDING`.
- **LAB-only VFX:** charge .02–.62; one painted talisman fire-head travels over .52–1.30 to **the current position** of the same prelocked monster; local fire contact 1.30–1.81; residue .~1.6–2.36.
- **QA/demo:** isolated deterministic video loop 2.85 seconds; it is NOT the actual cast, cooldown or runtime projectile travel time. Reference clock/mapping must be redone if runtime Combat V2 connection is separately authorized.

## V4 gates
G0 canonical contract, G1 first-party provenance, G2 distinct storyboard, G3 original source composition/poses, G3.5 **genuine native 1280×720 Godot** charge .30 / peak 1.05 / contact 1.42 on actual moving WALK enemy, G4 moving-anchor tests, G5 full genuine video and >=12 screenshots (only **after manually reviewing G3.5**), G6 human aesthetic QA per silhouette / pure color / contact / legibility / alpha/transition, G7 owner explicit approval.

**State until real evidence:** `G3_5_NOT_EXECUTED / TECH_NOT_EXECUTED / OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_WINDOWS_ANDROID_PENDING`. Do not conflate a committed scene with a successful Godot movie. No Codex, skeletal rigs, new branch/merge, Combat V2, SaveService, economy, AI, PvE or V6.3 changes.
