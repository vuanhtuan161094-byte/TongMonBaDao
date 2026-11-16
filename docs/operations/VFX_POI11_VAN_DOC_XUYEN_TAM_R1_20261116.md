# POI11 — Vạn Độc Xuyên Tâm Human ultimate, original sprite-first V4

2026-11-16, PR #72 Draft, current integration branch, one skill only, no rig/Codex/merge/PvE.

## G0 — canonical catalogue
` tmb.skill.poison.doc_cham.ultimate.human ` (trim spaces) | `poison/nether/circle` | radius **3** world units | target cap **3** | range **8** | cast **1.15s** | cooldown **36s** | projectile_speed **8** | poison duration **8s** | poison stacks **2** | damage ratio **1.8**. Canonical Human entry does **not** declare `hit_count`; metadata keeps explicit null, does not infer extra hit receipts. `V63_OFF`, `PVE_INTEGRATION_HOLD`, `RUNTIME_MAPPING_PENDING`.

## Previous owner gate and sequencing
Owner replied "ok./ skill tiếp" after native POI10 R2. POI10 R2 permitted to proceed, but formal blanket visual/device/PvE approvals are not inferred. POI07 and POI09 owner-approved sprite assets are locked, POI08 provisional/backlog, POI10 own art not modified here. There is no `doc_cham.active_05` in canonical catalogue. Next CAST_MASTER in the same branch is the Human **ultimate**.

## G1 reference rights, G2 storyboard
Previously supplied Võ Lâm/JX reference sheet observations and owner preference for *organic luminous outburst, saturated color, sharp cores, fine residue*. Third-party art is reference ONLY. POI10 had a large poison lotus; this ultimate must be different: **painted multi-needle crossthrough plume** whose needle points converge from different angles, then intersect the center and flare on the moving victims. Original first-party image-generation concept sheet created in current project conversation, SHA256 `a1e7eb3f6d83af8ded23d829ecd3df3327ec3119df0185edb035c3bb29384106`, filename `a_pair_of_digital_illustrations_displays_skill_vfx.png`. This illustrated concept is **NOT a native screenshot**; visible names, damage numbers, times and QA in its poster are fictitious, not skill authority or performance evidence. The original generated light pixels were cropped and alpha-matted from effects-only regions (no people/stats/UI): charge `(61,754,362,939)`, hero flight `(379,755,716,954)`, hit `(756,755,1107,954)`; independent tracked transparent WebP masters. Original crop resolution is limited (~300–350px wide), so despite larger stored masters this is a native-scale art **quality risk**, not an auto-approved result.

## G3 original sprite assets
Tracked original alpha masters: `needle_crown_source.webp` at **820×640**, `heart_piercer_source.webp` at **1024×676**, `heart_rupture_source.webp` at **800×600** under `godot/labs/combat_lab/poison11/r1_original/assets/master/`. Baker `tools/vfx/generate_poi11_original.py` creates independent nonrigid sprite poses from source pixels, not a new procedural primary neon ring:
- `poison11_charge_10.png`, 10 poses, 192×192, 768×576 atlas;
- `poison11_crown_12.png`, 12 poses, 320×224, 1280×672 atlas;
- `poison11_contact_08.png`, 8 poses, 192×160, 768×320 atlas.
Total **30 original key pose frames** and **6,193,152 bytes ≈ 5.906 MiB raw RGBA8** (excluding shared badge and actors). Distinct file hashes and alpha are technical checks only. POI10 attack atlases are not reused; only existing shared 64px poison-state badge is used. No 8s continuous body poison plume.

## Three clocks (G4)
- Catalogue: cast1.15, cooldown36, projectile8, poison 2 stacks/8s, unknown event receipt timestamp.
- Isolated LAB visual: 0–1.15 needle charge → 1.15–1.90 **one cosmetic approach** to area center → 1.90–3.08 asymmetric luminous converging needle crown → synthetic local contacts 2.20, 2.28, 2.36 on three WALK-animated moving monsters; attack VFX gone after 3.08. The exact duration/refresh state may only be driven by real Combat V2 status data once separately authorized.
- Movie/demo: G3.5 160 frames / ~2.67 s fixed 60fps with charge0.55, peak2.10, moving-contact2.43 native Godot PNG; full 660 frames/11.00 s only after manual art STOP review. Fixed capture framerate is NOT Android device FPS.

## G5–G8 technical, art and live gates
Godot 4.7.2 Compatibility strict import/parse/focused contract, general V4 packet/atlas/evidence validator, 3 native proof images and media SHA. Art self review at actual native 1× on dark/bright backdrop must reject weak/out-of-scale/matted box/face occlusion. Continuous movie and 14 timed frames after G3.5. Actual `OWNER_VISUAL_APPROVED` never inferred from CI. No branch, merge, rig, Codex, Combat V2, SaveService, economy, targeting, AI, PvE or V6.3 modifications. Final handoff must disclose exact SHA, result, failure if any and status.

**At file creation:** `G3.5_NOT_RUN`; `FULL_VIDEO_NOT_RUN`; `OWNER_VISUAL_PENDING`; `PVE_INTEGRATION_HOLD`; `PHYSICAL_QA_PENDING`.
## First G3.5 STOP — visually rejected
- Initial source SHA `973f8ee15964b8008791f3e3e4e2255f2c0fa6eb`, native Godot [run #43817362116](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43817362116). Godot 4.7.2 and V4 technical PASS, genuine 160-frame 1280×720 charge/peak/contact images.
- **SELF-ART G3.5 FAIL:** 0.55-second charge had rectangular semi-opaque source matte; peak lacked concentrated hot core; local hit was weak. Correct technical PASS did not authorize movie/approval, so full video was gated off.
- R2 generator improves low-chroma transparency, organically feathers charge envelope, brightens actual painted purple/jade brushwork and local contact. Repeat native G3.5 before self art approval.

## Second G3.5 visual inspection, R3 source cleanup requested
- Native V4 proof [run #43818428180](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43818428180) at SHA `4f205e05d6a53fcda617c22e3d18cd2ca734816c` again **technical PASS** but still visually *too low-contrast and dark-matted* on the charge; hero remained too diffuse and localized contact too faint at 1280×720. **ART SELF-GATE NOT PASS**, full movie appropriately skipped.
- This R3 technical candidate tightens original charge's organic alpha envelope and pigment threshold, slightly reduces charge display footprint, adds one short-lived **painted-source** white-hot energy node under moving targets at the impact area, and enlarges localized *source-painted* contact without touching gameplay. Do not claim art PASS without inspecting newly rendered actual 1× G3.5 charge/peak/contact. Shared PoisonBadge unchanged.
