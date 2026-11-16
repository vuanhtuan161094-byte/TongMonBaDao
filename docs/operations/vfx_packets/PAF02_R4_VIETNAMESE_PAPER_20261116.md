# PAF02 R4 — Initial talisman readability and Vietnamese lettering (16 November 2026)

## Owner instruction and acceptance state
PAF02 R3 accepted provisionally ("ok tạm đc"), with a new request: **opening talisman a little blurry, can it display Vietnamese instead?** Revise only opening talisman. R3 remains recoverable; preserve existing LINE/CONTACT/BADGE, actor movement, short 2.2s movie, PAF01 R6 owner-approved art and all Combat V2/SaveService/PvE flags.

## Source and implementation
- New original reversible source generator: `tools/vfx/paf02_r4_vietnamese_paper.py`, with owner-approved first-party PAF01 R6 pictorial silk source as permitted lineage.
- Before R3 fold/warp, erase only legacy "風" printed pigment using a jade-colored feathered mask while preserving the original source alpha and golden embroidery; overlay native Vietnamese Unicode **PHONG** / **ẤN** in two lines at high resolution using a system-installed Latin font. 690x825 RGBA intermediate is generated into `godot/labs/combat_lab/talisman12/art_sources/paf02_r4_vietnamese_paper_master.png`.
- Keep existing 14 frame shape-changing origami/cloth poses and independent existing R2 line, target contact and icon badge atlases. The status badge on monsters still reads `風` because owner approved it and requested changing the **opening talisman**, not existing debuff cues. No font files distributed, no rig.
- Sharpness is improved through new high-resolution glyph rasterization, restrained alpha and unsharp detail. Technical success is not sufficient to claim the glyph is artistically beautiful at Godot 1x.

## Timing contract
- Catalogue `tmb.skill.talisman.phong_an_phu.active_02.human`: wind / mark / line / max 3 / cast0.5s / status5.5s / cooldown10.8s / projectile_speed0.
- Runtime actual mark receipt UNKNOWN (`RUNTIME_MAPPING_PENDING`).
- LAB: charge .02-.55s; cosmetic line .48-1.06s; simulated contact .78-1.23s; residual to 1.58s. 2.20s video is only for QA, not 5.5s mark.
- Test Godot G3.5 0.28/0.67/0.97s on independently moving monsters, strict focused contract and exact-SHA; manual inspect paper and typographic legibility at real 1280×720 native scale.

**Before a new exact SHA run:** R4 TECH NOT_EXECUTED / G3.5 NOT_EXECUTED / OWNER_VISUAL_PENDING / PVE_HOLD / PHYSICAL_QA_PENDING.
