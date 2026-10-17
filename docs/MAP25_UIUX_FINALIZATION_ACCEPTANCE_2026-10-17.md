# MAP25 / UI-UX finalization acceptance — 2026-10-17

Status: IN PROGRESS. P0 Windows focused gates and performance target PASS on PR #18 ancestor `855fc4e8342607fed36f1128536f7a1c0d3d09fa`; visual acceptance, Source A actor integration, production UI, disciple UI and Android remain OPEN.

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

## Remaining gates

| Packet | State | Required proof |
|---|---|---|
| P2 Source A actor `1113028_1` | PENDING | Exact asset hashes, in-scene idle/walk/stop, feet/click/z-order, 0.75/1/1.35 zoom, screenshots/clip |
| P3 Mine/Forest/Field UI | PENDING | Live one-worker/building actions and backend timer/stock/EXP, seven-state screenshots, focused regression |
| P4 disciple V3.3 UI | PENDING | Roster/showcase/six real tabs, hidden data, touch/navigation regression |
| Integrated Windows | PENDING | Repeat 5-case benchmark and 7 screenshots on final SHA, save/offline/One Active Job affected gates |
| Android | PENDING | Real runner/device evidence |

Source A binary redistribution rights remain restricted to the owner's personal project permission. Technical Batch-01 PASS is not visual acceptance. No CI, merge, main change or gameplay-authority edit was performed in P0.
