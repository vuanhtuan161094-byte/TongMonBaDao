# VIS-09 — Two dimensional handpainted Hall and Mine

Date 2026-11-14 · PR #72, current working integration branch · Source A art not used for Hall/Mine.

**Goal:** Preserve a flat painted 2D game world with independent alpha sprites; avoid fake 3D rigging, screenshots pasted into a scene, or a baked screenshot pretending to be gameplay.

## New user-selected concept lineage
- Hall master: original 2D generated image `a_detailed_high_quality_2d_game_art_illustration.png` (1536×1024 RGBA), **not** a Source A sprite; map export `art/tmb_handpaint_v6/hall_handpaint_v6_300x201.png` SHA256 `e7812ccd3083c1289ce1ad1d7d18421dfa047b17b6f59bb25e5678d6320101dd`.
- Mine master: generated `a_highly_detailed_polished_2d_game_art_isometric.png` (1536×1024 RGBA); map export `art/tmb_handpaint_v6/mine_handpaint_v6_166x121.png` SHA256 `a4703e7df0592fa2d102ad9818dea744e7eb30209ad67ae141258364aa7b37c9`.
- The new PNGs preserve the source alpha, attenuate low-opacity ambient glows, trim transparent borders and scale to target with Lanczos resampling. No painterly repaint or replacement with another concept.
- Original version V4/R4 and V5 sprite masters are deliberately preserved for rollback. **VIS-09 is a presentation/art candidate** until the owner reviews actual Godot screenshot; the user did not authorize changing 3D/gameplay nor deleting history.

## Actual integration
- Map: `SectIsometricWorldV1` uses VIS-09 for main_hall and the primary mine if the two exact assets import; never renders historical Source A `510052`. Existing 300×201 Hall anchor and 166×121 Mine site footprint and gameplay click anchors untouched.
- UI: Actual management Hall/Mine illustrations use same VIS-09 PNGs via ART-05 and TRI facility. No image is a clickable cover or new gameplay receipt.
- All **12** V3 Forest/Field/Alchemy images, their active/idle flags and two drawn orientations are untouched. Residence/Warehouse/Forge/Guidance still use previously integrated independent V5 art; gameplay, combat, economy, SaveService and Android settings untouched.
- **Known visual tradeoff:** User-liked VIS-09 Hall concept is more front-facing than canonical 3/4-isometric building family. No claim that screenshot QA passes perspective matching without seeing native gameplay screenshot.
- QA lean: official Godot 4.7.2 VIS-09 import/alpha/native size contract + one ART-05 real 1280×720 seven-screen screenshot run at exact SHA. Physical Windows/Android and visual owner approval remain PENDING.
