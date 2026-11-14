# VIS-11 — 12 native 2D A/B sprites from approved building sheet

Input: exact 1448×1086 RGB `bảng_thiết_kế_công_trình_tông_môn.png`, accepted by owner on 2026-11-14. Every A/B drawing was cropped, background keyed, labels/borders removed, alpha masked and padded within its pre-existing in-game target rectangle. **Not a repaint, not a flip_h, not Source A extracted art.**

Original independent A/B pairs: main_hall `hall_A/B.png` 300×201, mine `mine_A/B.png` 166×121, residence `residence_A/B.png` 174×135, warehouse `warehouse_A/B.png` 162×138, forge `forge_A/B.png` 205×164, guidance `guidance_A/B.png` 182×203. PNG assets live at `godot/art/tmb_buildings_ab_v7/`. `tmb_building_art_ab_v7.gd` preloads all twelve for Android export.

The actual map renderer chooses A or B via its existing `view_direction` (producer visual-only parity) and already exposed `set_visual_rotation_preview` API. Fixed landmarks default A. Panels now load matching new originals with no gameplay/SaveService/footprint/picking change. The three completed Linh Lâm/Linh Điền/Luyện Đan product families retain exactly their existing 12 PNGs.

The Source A map environment is **not** fully retired: trees/roads/terrain still load historic images and character sources are a separate project. Old building images remain in git only for provenance/rollback. Two displayed sprite views do not provide a complete 360° rotation controller and do not persist orientation.

Targeted import test: `godot/tests/presentation/vis11_ab_sprite_contract_test.gd`, followed by real `ART-05` 1280×720 screenshot QA. Android visual acceptance remains separate from technical success.
