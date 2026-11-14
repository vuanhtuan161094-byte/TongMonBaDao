# VIS-08 — Original Building Art Replacement, 14 November 2026
State: **CODE AND BINARY CANDIDATE, OWNER VISUAL REVIEW PENDING**, PR #72 Draft

Owner explicitly rejected the R4 Main Hall as underwhelming and instructed replacement of every visible Source A **building** with original self-generated art.

## New original five-building pack
All five images are extracted from ONE independently generated 1672×941 TMB building-sheet image, **not sampled from original Source A pixels**. Production method: isolate each independently generated building illustration from the sheet, remove the navy card background with foreground masks, inspect RGBA transparency, fit proportionally into the pre-existing Godot target dimensions, quantize PNG palette to 256 colors for Android memory/download size, verify byte-identical Git blobs. Source intent: more refined, ornamented yet readable buildings and one coherent visual family. **This is a proposed art revision, not an owner-approved visual change.**

| Building | Display target | Git blob SHA |
| --- | --- | --- |
| Main Hall / Đại Điện | 300×201 | `f44df31610501ff7f6ed15f7a242e123e6371d89` |
| Residence / Đệ Tử Xá | 174×135 | `305313469274a0338e9c1d0af64098cb2a102345` |
| Warehouse / Kho | 162×138 | `874d117a520b73d0d1807f8284e166f111d37681` |
| Forge / Luyện Khí Đường | 205×164 | `51ee0baa6595c6233551f3b448d645c59466e445` |
| Guidance / Dẫn Tiên Đài | 182×203 | `868adc18dd760f53f0018c973e1413cf04e279a1` |

- Main-map five old house keys `510052/510076/510102/520081/510111` remain **placement/rollback identifiers**, NOT displayed Source A texture. Runtime `render_art` now binds them to the five new PNGs. All existing footprint/pivot/size/collision/selection/door anchors stay intact.
- Real panels use new images for Hall/Residence/Guidance/Warehouse/Forge. Mine remains owner-approved VIS-07 R4 original PNG; Forest/Field/Alchemy unchanged V3 **12/12 real PNG** A/B×idle/active. No animation rig or gameplay edits.
- Historical SHA-pinned Source A binary files stay present solely for verification/history; the default presentation has **no old Source A buildings**.
- **Remaining Source A environment:** roads, terrain, foliage PNGs have not yet been replaced by accepted original art, so DO NOT describe the entire game as free of Source A. This production phase retires only buildings; environment replacement is another visual packet.
- Original screenshot source: generated VIS08 original game-art building-sheet from 2026-11-14, source SHA to be recorded in external owner ZIP; no commercial Source A files are redistributed by new sprites.
- QA: focused official Godot 4.7.2 import of 5 PNG, alpha, direct facility panel, V3 preservation; real 1280×720 screenshot `.github/workflows/art05-screenshot-compare.yml`. Technical PASS does not constitute owner approval.
