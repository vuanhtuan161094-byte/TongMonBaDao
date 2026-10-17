# MAP25 / UI-UX finalization acceptance — 2026-10-17

Status: **WINDOWS FOCUSED TEST PASS / PERFORMANCE TARGET PASS / VISUAL ACCEPTANCE OPEN / ANDROID PENDING**. Stacked branch `map25-uiux-finalization-20261017` starts at draft PR #18 HEAD `855fc4e8342607fed36f1128536f7a1c0d3d09fa`. Source A pilot, production and disciple presentation packets were implemented and tested. No gameplay, CI, merge or main edit.

## P0 — terrain batching verification

The tested source contains the cached 16×16 ground `ArrayMesh` change from `41783d312281be7ade5d86ff86e3cbad1b6f97d3`. Test host: Windows, Godot `4.7.2.stable.official.ed1daf0bf`, Compatibility OpenGL 3.3, Intel Iris Plus Graphics (driver `31.0.101.2125`), landscape 1280×720. Isolated checkout and isolated APPDATA/LOCALAPPDATA were used; no owner save was read. The downloadable evidence bundle is `MAP25_P0_855fc4e_20261017.zip` in the task outputs, with five authentic screenshots, 600 frame samples, CSV, metadata and individual gate logs.

| Scenario | Baseline `5e0ec9` avg / p95 ms | Current `855fc4e` avg / p95 ms | Draw calls baseline → current | Current FPS from 1000/avg interval |
|---|---:|---:|---:|---:|
| Idle | 16.569 / 19.257 | 16.561 / 18.916 | 78.0 → 78.0 | 60.38 |
| Active pan | 58.175 / 60.623 | 17.261 / 21.949 | 4892.7 → 415.9 | 57.93 |
| Active zoom | 67.124 / 104.761 | 17.495 / 24.380 | 4339.6 → 375.1 | 57.16 |
| Mine panel | 16.568 / 17.509 | 16.485 / 19.276 | 91.0 → 91.0 | 60.66 |
| Picker | 16.523 / 17.303 | 18.054 / 20.341 | 121.0 → 113.2 | 55.39 |

Both source and comparison are 120 observed frame intervals per scenario on the same named machine. The displayed FPS is an interval conversion, **not** Godot's sampled FPS column. `avg_process_ms` remains inconsistent with observed frame gaps and does not identify a CPU or GPU bottleneck. The pan/zoom p95 target <=33.3 ms and draw-call target <=600 were met in this run; no Android or sustained-load conclusion follows.

Official Godot exits were 0 with no `SCRIPT ERROR`, `Parse Error`, `ERROR:` or `WARNING:` in the elevated gate logs:

- Import/parse on this checkout: exit 0.
- `sect_map25_verified_art_gate_test.gd`: 32 accepted, 0 missing, 0 rejected.
- `sect_iso_projection_contract_test.gd`: 36 cases PASS.
- `sect_iso_main_integration_test.gd`: real scene / camera / Workforce PASS.
- `gui_workforce_v1_e2e_test.gd`: real landscape end-to-end PASS.
- `gui_multiple_resource_instances_test.gd`: real ID routing PASS.
- `sect_map25_visual_perf_capture_test.gd`: five 1280×720 captures and 600 samples PASS.

Direct screenshot review: the ground colors, roads, trees and PV01 building layering rendered, with no ArrayMesh compile/color regression observed. The left map viewport contains a large pale blank margin; green silhouette actors remain; building markers and the 440-pixel Mine panel are still conspicuously provisional. Thus **TEST PASS / PERF TARGET PASS / VISUAL ACCEPTANCE OPEN**. P1 needs no further speculative renderer optimization on this measured host; proceed with the authorized Source A pilot and UI packets, then benchmark again after their integration.

## P1–P4 packet results and rollback points

| Packet | Code commit | Tested result | Acceptance limit |
|---|---|---|---|
| P1 terrain/layout | `41783d3` inherited; P0 docs `a1402bd`; full-width correction `4c35b2c` | Pan/zoom p95 and draw-call targets met on the same Intel Iris Plus machine. The map SubViewport now spans the full 1280-pixel landscape width; projection, real scene, Workforce and final capture gates passed again. | Map framing is visually improved; art completeness and actor/roof order remain open. |
| P2 actor pilot | `873f3cd` | Exact Batch-01 `1113028_1` files copied, asset hash verified, female map actors use genuine stand/walk SpriteFrames, left/right mirror and idle stop while existing actor ID/click/foot API stays intact. Official real-scene focused gate PASS for two female actors; 3 walk frames captured. | Visual approval, some roof overlap, three zoom scales, sustained atlas/Android performance and other rigs OPEN. Male green fallback still visible because no approved source for that actor. |
| P3 production | `a073515`, `05af0b6` | Mine/Forest/Field right panel narrowed to 320 px. Exact building-instance picker, one worker, live plan/yield/warehouse, authentic timer result and cancel through existing BuildingSystem; verified worker avatar links to summary and returns to the exact building ID. Workforce E2E, multiple-instance/save test PASS. | Field progress hierarchy and missing building artwork still need visual approval/refinement; no blanket visual COMPLETE. |
| P4 disciple | `2fd377d`, `05af0b6` | Left roster, center verified pilot artwork, right canonical data, six existing real tabs retained. Improved contrast and 44 px controls; verified art or explicit pending portrait. Operational-flow and authentic V2 profile focused gates PASS. | Only verified female pilot has artwork; separate male/individual portraits, some reference ornamentation and mobile device QA OPEN. |
| Integrated capture | `a7bebcc` | Existing capture probe now saves eight 1280×720 states, three consecutive actor frames and five-case 600-frame CSV; strict native resolution, no image rescaling. | Three-frame GIF is a short visual sample, not frame-perfect motion or z-order approval. |

**Source/provenance.** `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472\1113028_1\asset.json` SHA-256 `daecefdc454883b8613fa2ec8361be1c80b2ddcc162b4aceff84618306e4a637`; copied to `godot/assets/actors/1113028_1/`. Its four resource/atlas hashes were checked: `actor.tscn` `5442a4442a31c9ae27027ef0bf16941e3a1afe0f85b94a17713be300578b2cf5`; `animations.tres` `e2864cfe778fac39b093fa30c76c76bfec40f1b03a8ed1f3af5ea72aa6eb6473`; `atlas_000.webp` `ce2bea0da04a8e461016de756546640afd4eda855f64ed3cd44e15bdc06c4197`; `atlas_001.webp` `8e1bffa36d2c5ff68ca54be3f56633006a94b42bf9b0abecd03ab50023024da6`. The copied `asset.json` names and hashes the original `.skel`, `.atlas` and PNG. Its two atlases total 2,833,528 on-disk bytes; this is **not VRAM**. No converter rerun. No claim of rights beyond owner personal-project use.

## Integrated Windows 4.7.2 release-candidate evidence

All commands used `E:\Godot_v4.7.2-stable_win64_console.exe`, the repository `godot/` project, isolated QA user-data roots, Compatibility OpenGL 3.3 on Intel Iris Plus Graphics, native landscape 1280×720. Test command pattern: `Godot --headless --path godot --script res://tests/presentation/<name>.gd`; visual probe omits `--headless` and uses `--rendering-method gl_compatibility`. Final full-width viewport visual probe exited 0 after 11 `CAPTURE_OK` at exactly 1280×720 and 600 benchmark samples; screenshot SHA-256 values are in `evidence_manifest_release.json` inside the output ZIP. Import exit 0 with no parse or script error. Final focused PASS logs: 32/32 Source A art hash, 36/36 projection, real MAP25 main scene/camera/Workforce, Source A in-scene stand/walk pilot, Workforce one-worker/timer/cancel/warehouse/EXP/offline E2E including worker→exact-building return, multiple building IDs and save roundtrip, P3.3 operational disciple flow, DV2-03 authentic V2 disciple profile. The 600-frame profile is from the final presentation code, before documentation-only evidence refresh.

| Scenario | `5e0ec9` baseline avg / p95 ms; draw calls | Final avg / p95 ms; draw calls | Final converted FPS `1000/avg` |
|---|---:|---:|---:|
| Idle | 16.569 / 19.257; 78.0 | 16.499 / 17.503; 66.0 | 60.61 |
| Pan | 58.175 / 60.623; 4892.7 | 16.926 / 18.770; 413.2 | 59.08 |
| Zoom | 67.124 / 104.761; 4339.6 | 16.802 / 19.968; 403.2 | 59.52 |
| Mine panel | 16.568 / 17.509; 91.0 | 16.535 / 17.182; 81.0 | 60.48 |
| Picker | 16.523 / 17.303; 121.0 | 16.606 / 17.903; 123.0 | 60.22 |

The monitor's `avg_fps` and `avg_process_ms` columns differ from observed interval timing and are **not** used as causal CPU/GPU evidence. Sampled `memory_bytes` in the 600 rows ranges from 57,157,828 to 59,454,870 bytes; this is an engine monitor value, not atlas VRAM or memory peak for Android. There is no sustained-play or Android FPS claim. Pan and zoom p95 remain below 33.3 ms and mean draw calls below 600 on this machine.

**Artifact:** `MAP25_UIUX_WINDOWS_CANDIDATE_20261017.zip` in the task outputs, SHA-256 `36ed9c5f16edbe133cac58a85541cfa29ba9ddddc5ab017b986bdde7d96fe122`; ZIP CRC PASS. It contains 11 original 1280×720 screenshots, `frame_samples.csv`, `performance_summary.csv`, manifest and named Godot logs. `MAP25_SourceA_actor_walk_20261017.gif` is a three-frame excerpt from actual rendered screenshots, SHA-256 `60dfe96013398df268a2ac640968ead60264b8ae988a2a4342337838d7002837`.

| Screenshot in bundle | Reference pattern from `P3_REFERENCE_UI_AUDIT` | Ours / limitation |
|---|---|---|
| `01_idle.png`, `02_pan.png`, `03_zoom.png` | Map-first, thin edge HUD, tappable buildings | Source A terrain/buildings now fill the landscape viewport; green fallback actors and flat markers remain. |
| `04_mine.png`, `06_field.png`, `07_forest.png` | Compact right panel over visible map, responsible disciple then real production | 320 px panel, one-person card, genuine stock/job state and actions; historical building art for all three still pending recovery. |
| `05_picker.png` | Fast worker choice with status | Search, readiness sorting, profession level, worker portrait/initial and blocked reason; visual decoration remains simpler than reference. |
| `08_disciple.png` | Left portrait roster, large center character, right information, lower tabs | Pilot artwork, six live tabs and canonical attributes visible; other individual portraits pending verified assets. |
| `09_actor_walk_01..03.png` | Character animates in the real map | Genuine three-frame capture; foot/click focused tests pass, roof overlap and all-zoom visual signoff remain open. |

**Open visual/asset gate:** actor/roof overlap, green fallback males, provisional map markers, historical S3 building images for Mine/Forest/Field and remaining individual portraits. The left blank strip is resolved in the final full-width screenshot. Exact S3 bytes were not recovered, so no replacement was relabeled as canonical Source A. Visual comparison uses structural observations in the existing reference audit; no reference artwork was copied into the repository or artifact. **Android PENDING**: no device/export runner was available in this packet. The branch is a reviewable candidate, not a declared fully polished/visually accepted production release.
