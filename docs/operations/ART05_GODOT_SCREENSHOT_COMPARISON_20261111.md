# ART-05/06 — Screenshot-first Godot OneGame visual audit (11 November 2026)

## Scope and provenance
Real engine: official **Godot 4.7.2**, canonical `res://scenes/p3/p3_2_landscape_sect.tscn` on PR #72. Runtime output is **actual 1280x720 Linux X11 / Mesa Xvfb**, not browser HTML and NOT Windows/Android owner physical acceptance. Mockups made earlier in chat are an aesthetic target, never a canonical game-simulation source (their quantities, product list, actions, capacities and characters can be fictional).

**Baseline screenshot workflow:** [ECO07 #43056838146](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43056838146), code SHA `d48d8d2192b6e68b6a27a42e5a4b243ab666d661`, 7 PNGs. All seven have a nearly full-width 1184x552 cream modal, cramped two-column management, small images, tiny text and disconnected low-intensity colors.

## Visual comparison by live screen

| Canonical scene | Baseline observed | Implemented (screenshots, code) | Still open versus premium mockup |
| --- | --- | --- | --- |
| Map `00` | Isometric small world, disconnected palette, sparse ground | Dark jade bottom navigation with actual input actions, original procedural environmental motes | World geometry/terrain richness, map landmarks and actual actor actions—not replaceable by a flat fake screenshot |
| Hall `01` | Ivory wall of text hides map | 832px world-preserving jade/gold management panel, retained real economy ledger and scroll | More illustration, transaction summary hierarchy |
| Mine `02` | Tiny block art, hard-to-read ore selection, text truncation | Canonical four ore selections with icons, distinct amber styling, responsive two-column forms, slim progress and real-job-only worksite VFX | Real pickaxe/carts/worksite animation clips, richer mine background |
| Forest `03` | Tiny generic trees and crowded UI | Green facility accent, real four-material cards, controlled list/worker scroll | Verified actual woodcutting actor clip, higher-quality trees |
| Field `04` | Tiny crop diagram, worker info barely visible | Teal crop art cards and grounded plot data, distinct fields/progress, visible actual map | Animated crop life-cycle artwork and actual harvest cues |
| Warehouse `05` | List of counts and a few small pictures | Two-column rendered real-stock cards, no fake inventory, modern dark information design | Richer category/filter inventory UX, scalable icon portraits |
| Alchemy `06` | Small static furnace, recipe information in paragraphs | Violet frame, ingredient grid wrapped inside right-hand column, authoritative batch ETA/ingredients | High-quality cauldron visual, authored VFX keyed to actual batch stage, master pill art |

## Measured iterations — **do not claim FPS gains without proof**
- Before d48d: GUI mean engine FPS 31.24, approx static memory 227.65 MB (software Mesa/Xvfb).
- ART05 iteration1, [GUI #43065355611](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43065355611) 33.00 FPS, 228.29 MB; world exposed but tiny text, layout width clipping.
- ART05 iteration2, [GUI #43066391432](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43066391432) 29.13 FPS, 228.50 MB; compact navigation, dark management and better wrapping.
- ART06 iteration3, [GUI #43067189022](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43067189022) 22.63 FPS, 228.43 MB; new world motes but software-rendering cost.
- ART06 iteration4, [GUI #43067699494](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43067699494) 22.34 FPS, 228.43 MB. Throttled but did not recover performance, so rejected as sufficient.
- ART06 iteration5 source `bb9791c02e646282dbf29e44dbfe4a3c6ba509df`: world aura now static while canonical jobs inactive. **Exact-sha fresh measured run pending** when this record was prepared.

FPS above is specific to runner software rendering and must not be used to assert physical Android/Windows FPS. Small run-to-run variance and job contention may exist. Genuine user acceptance requires seeing the output on target machine.

## Source changes
`godot/src/presentation/art05_onegame_cinematic_ui.gd` subclasses old ART02 and preserves its controls/state/transactions; `godot/src/presentation/uiux/sect_premium_panel_v1.gd` draws panel skin; `godot/src/presentation/uiux/sect_world_atmosphere_v1.gd` is decorative only; `godot/scenes/p3/p3_2_landscape_sect.tscn` selects the derived view; `godot/tests/presentation/art05_real_gui_layout_test.gd` tests six real panels and navigation geometry; `.github/workflows/art05-screenshot-compare.yml` captures 7 real rasterized screenshots on every UI source push.

**Hard gate:** Never add fake resources, fake worker output, bypassed timers or buttons that don't work. Do not call this visual mockup parity / owner-approved. PR #72 remains Draft, no merge; Windows/Android physical QA and high-quality 2D asset pass remain open.
