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


## Exact-SHA R4 native QA (after implementation)
- Source tested SHA: `da3c7aea3dfed0f245b2395248a397fa48d4930f`.
- [Godot 4.7.2 V4 PAF02 technical workflow #43854056521](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43854056521) **SUCCESS**, artifact `14220310777` (`vfx-paf02-native-da3c7aea...`). Strict import/parse, asset/packet/evidence validation and focused moving-3-target no-gameplay-writes tests successful. Three true 1280×720 G3.5 frames at charge0.28, peak0.67, contact0.97 included.
- True native MP4 1280×720 / 60 fixed encoding FPS / 132 frames / 2.20 seconds; GIF at 640×360 / 22 frames. MP4 SHA256 `83bfba1c3a3bf0cc950cccaed26cca53f63274b4d0f1c65693b87d7b23bfb546` (NOT physical device FPS).
- R3 vs R4 actual decoded WEBP SHA256 comparison: only `paf02_charge.webp` changed (`95e909acfe7553381090ea646b63ef687c7d54baa44abcc47f35480a870b3616` → `89aaa6a666b9f9c4f9528ea7fce6ddf32b1e999673a1a17efa955ef81a3590fc`). **UNCHANGED** R2/R3: line `a50d6bf73d1b2a7f4806bc46ebe4c353f6c2f75f19a696edd82cf635c5137d98`, contact `6355361de599181bea63cb3655c4f8fe8ab576737defecb5091a60389e636dcd`, badge `f1e7be8d4b19dea0dc59ef35b6d5e48d55114d90922b74bd17a10085d2b5044f`.
- Manual same-camera 1× review: `PHONG` + `ẤN` legible at native charge 0.28 on the moving scene; the source paper image still has soft original painted edges and small text when zoomed out. No CJK `風` on *opening talisman*; unchanged `風` target badge because owner had approved its appearance and did not request changes to debuff marks.
- `R4_TECH_PASS / R4_ART_CANDIDATE / OWNER_VISUAL_PENDING / PVE_HOLD / V63_OFF / PHYSICAL_QA_PENDING`. User may prefer alternative label/font in later art-only revision; no claim of release readiness.
