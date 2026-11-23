# Kiếm Vũ Hồi Phong — Nhân R1E / PR #72 isolated Combat Lab

**Owner source-art accepted 2026-11-23** (user: “Ok đạt r. Bc tiewps”). This is the first-party AI-drawn 12-frame **VFX-only** source, **not extracted from a promotional poster** and **not AI character replacement**. The source frame labels were removed and alpha recovered from a dark matte; see original README and source QA for provenance.

- Source archive SHA-256: `bede0519b1026f3245f636f56991dcf09c5737913bc66b2c741838dc5534bd87`; exact original archive imported via GitHub Actions, 12× 512×512 RGBA poses and 2048×1536 atlas.
- Canonical skill: `tmb.skill.sword.ngu_kiem.active_02.human`; metal damage, circle radius 1.4, max 3 targets, cast 0.36 s, cooldown 10 s, damage ratio 0.82, projectile speed 8. The LAB **does not implement, infer or award** those gameplay receipts.
- Lab scene `r1e_lab.tscn`: **existing AS48 front attack** 4 frame sprites, real independent AS48 weapon/socket metadata, 3 existing monster sprites moving, overlaid **R1E-only** image atlas. No rig, no procedural substitute VFX, no gameplay state writes, no PvE integration.
- Web: add to existing **one** canonical `/vfx/` GitHub Pages selector. `review_seek_phase` controls charge/projectile/contact; toggles bright/dark, pause, moving monsters, zoom and VFX. Visual 12-frame review clock 1.54s is not canonical gameplay timing. No validated 4-direction AS48 runtime: **FRONT ONLY**.
- G3 source art: **OWNER ACCEPTED**. G3.5+ Godot / browser gates require exact-SHA CI evidence; source QA alone is not proof of runtime visibility. PR remains Draft. No merge, Codex Cloud, rig or PvE.
## 2026-11-24 — runtime art correction, owner dissatisfaction
Owner judged the Web VFX visually wrong/weak despite green QA. Direct code inspection found that the old `_update_positions` **teleported the single FX sprite** between three anchor coordinates: actor+offset for charge, fixed `(585,474)` for gyre, and monster #2 at contact. The phase-seek button also did not reproduce the tint of contact, and 2x UI zoom magnified only FX while labeled Actor.

New isolated G3.5 candidate:
- Read `asset_tip_px` and actual AS48 grip, angle and frame from the existing socket JSON. Carry R1E from the independent sword tip (no rig) along a smooth time-based curved path to the **moving** 3-monster centroid, with no phase-9 teleport.
- Keep charge close to actor's feet, blend toward the blade as it releases, show the contact flash even when paused, make the 2x inspection magnify actors/mobs and VFX consistently.
- Add non-aesthetic Godot contract tests for continuous travel, no contact teleport, seek-frame hit tint and zoom correctness.
- The underlying 12 R1E source PNGs/atlas remain byte-identical. **Previous Chromium PASS was technical only; owner explicitly rejects the runtime look.** Do not promote G3.5 to visual PASS until real exact-SHA screenshots/GIF are reviewed.
- No Codex Cloud, rig, gameplay receipts, SaveService, PvE or merge.

## Sprite-first runtime luminosity pass (2026-11-24)
VFX was visually too faint on the arena because the approved R1E artwork had only a single normal-alpha display pass. Add one **additive Sprite2D using the same AtlasTexture and frame as the source**, behind the normal sprite at 1.06× with moderate alpha (dark map 0.28, pale map 0.18; temporarily 0.48/0.30 on contact). It follows the exact same per-frame position and VFX toggle; it is not a new or generated art layer. Tested through Godot scene QA for atlas linkage, additive mode and synchronized position. This is a visual **candidate pending owner/browser 1× review**, NOT ART PASS or gameplay integration; R1E PNGs unchanged.
