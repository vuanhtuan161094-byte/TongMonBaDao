# TÔNG MÔN BÁ ĐẠO — PR #28 UI + Source A integration report

Date: 2026-10-24  
Repository: `vuanhtuan161094-byte/TongMonBaDao`  
PR: [#28 — Draft UI readability + verified Source A assets](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/28)  
Branch: `ui/pr27-runtime-readability-20261024`  
PR base: PR #27 head `deeae081bcfbe1413d4cf60a29db7e58150888b5`  
Tested presentation blob: `9f7e10425e907b74ce69af1c3d74d60bc1984eaf`  
Code commit: `47b704270ae165504aeef526963e8d03f87bc579`

PR #28 remains **OPEN / DRAFT / UNMERGED**. No FULL/CI, merge, Source A gameplay authority, or changes to Combat V2/V3, CARE, D7 generation, Warehouse, SaveService, economy, scheduler, Injury120, or reward logic were made.

## Work completed

1. Fetched and verified the latest PR #28 head before edits (`f253cca1bb2dfa5576ba3d431d5fa70c4db16f0c`), preserving the PR's stack on PR #27.
2. Completed the local worker asset inventory. Four converted actor packs were found; all four are verified, but they are content-equivalent to packs already in PR #28. Atlas file hashes match exactly; normalized `actor.tscn` and `animations.tres` text matches exactly despite CRLF/LF raw-hash differences. **No duplicate or replacement binaries were committed.** See `WORKER_ASSET_CATALOG.json`, `WORKER_ASSET_DISCOVERY.csv`, and `WORKER_ASSET_DIFF.md`.
3. Made one focused P3.2 presentation correction after a real Mine-loop gate exposed hidden state: when PR28 shortens the personnel section, it now keeps the active Mine/Linh Lâm worker phase in a concise `ĐANG THỰC HIỆN` summary. This reads the existing canonical worker/cycle/timer state. It does not advance simulation or touch production output.
4. Captured the actual P3.2 scene with the official Godot editor build at 1280×720. The 12-screen set covers map and pan/zoom, Mỏ, Linh Lâm, Linh Điền, canonical Warehouse, a real V2 profile, CARE/Combat V2 shown by the V5 adapter, hit/skill, paid loot, and return to sect. The clean capture manifest records the real receipt `tinh_lang_bi ×1`, `paid_generation=1`, Warehouse stock `1`, and SaveService reload preserving both counts.
5. Retained actual Source A asset contact sheets and evidence logs. No mockup was represented as gameplay.

## Godot results on the changed P3.2 source

Engine: `4.7.2.stable.official.ed1daf0bf`.

| Run | Result | Evidence |
| --- | --- | --- |
| Focused PR #28 regression | **21/21 PASS**, zero parse errors, zero log-open errors, zero malformed `user://E:` paths | `evidence/PR28/logs/acceptance_logs_47b70427.zip` (includes `focused_summary_9f7e1042.csv` and per-test engine/stdout logs) |
| O3 real Mine work loop | **PASS** — actual work phases, haul, canonical Warehouse and persistence assertions | `acceptance_logs_47b70427.zip` (`O3/` retry PASS; initial UI FAIL retained separately) |
| P3.2 modular actor contract | **PASS** | `acceptance_logs_47b70427.zip` (`modular_actor/`) |
| O9 M2 multi-producer rehearsal | **PASS** in the focused suite on the changed source | current O9 stdout/engine logs in `acceptance_logs_47b70427.zip` |
| P3.2 actual GUI capture | **12/12 PASS**, 1280×720, real P3.2 scene, receipt and reload state, process exit 0 | `evidence/PR28/logs/capture_47b70427.stdout.log`, `evidence/PR28/after_47b70427/capture_state_manifest.json`, before/after images, SHA ledger |
| Extended Mine capture harness | **FAIL after its `mine_running` frame** — its separate extra loop did not settle exactly one batch; that harness result is preserved. It is not counted as a PASS. | `acceptance_logs_47b70427.zip` (`extended_capture/`) |

The first O3 run failed because the collapsed roster also hid the live `haul_back` phrase. After the presentation fix, the same official O3 test passed, so Mine production and warehouse settlement were verified by the gameplay test. The failed extra capture harness does mean a screenshot of the settled Mine state is still missing; see the issue matrix. Its active-worker frame at `evidence/PR28/after_47b70427/mine_running_1280x720.png` is retained only as a real active-state UI frame, not as proof of settlement.

A separate commit-labelled GUI capture attempt produced all 12 pass markers but exited with Windows access-violation code `-1073741819` during shutdown. Both logs are retained as `capture_47b70427_shutdown_crash.*`. A clean isolated rerun on the same code commit produced all 12 frames and exited 0; that clean run is the GUI PASS cited above.

### O9 history — kept separate

- Historical initial **19/20 FAIL** and clean **20/20 PASS** remain separate entries under `O9/` inside `acceptance_logs_47b70427.zip`; the original FAIL root cause remains unknown.
- Current changed-source O9 M2 test is **PASS** in the 21/21 run. The three records were not overwritten or merged into a single claim.

## Visual and asset gates

- **Current P3.2 map:** MAP25 Source A visuals remain the current renderer and pass the 32-file SHA-gated art test. Real map/building views and free pan/zoom were captured.
- **Production:** Mỏ, Linh Lâm and Linh Điền actual operation panels were captured. O3 proves the real Mine loop; Mỏ/Linh Lâm live status is now visible even when the detailed roster is collapsed. A screenshot showing the paid, settled Mine batch is still pending.
- **Disciples/profile:** current P3.2 real V2 profile and the Source A actor contract passed. A separate male profile screenshot is not in this evidence set.
- **Combat:** existing CARE → Combat V5 view-only adapter passes; capture records real hit, skill hit and a paid canonical loot receipt. Boss remains display-only, with no live CARE Boss event mapping.
- **Worker asset addition:** no new output pack qualified as a *new* asset because all four verified local outputs are duplicates of existing PR #28 packs. They were not recopied or overwritten.
- **Building packs:** full Source A binary packs for Mỏ/Linh Lâm/Linh Điền were not found. Incomplete candidates stay out of the scene.

## Scope diff

Code commit `47b704270ae165504aeef526963e8d03f87bc579` changes one file: `godot/src/presentation/p3_2_landscape_sect.gd`. Earlier PR28 readability commits remain `8568392c0c099871cd6befeb2fdce420021db371` and `f253cca1bb2dfa5576ba3d431d5fa70c4db16f0c`. The final report/evidence commit follows separately. No worker binaries were added; changed documentation files enumerate the inventory. `evidence_manifest_47b70427.json` gives SHA-256 and byte size for the directly linked screenshots, catalog, reports, and QA/log archives. The focused and asset QA archives retain their full individual logs/records.

## Outstanding acceptance

- Windows manual mouse/play/save-load: **PENDING**.
- Android landscape/touch device: **PENDING**.
- Owner visual approval: **PENDING**; screenshots contain remaining dense panel text and some combat receipt overlap.
- Screenshot of a Mine batch after its exact canonical warehouse settlement: **PENDING**; O3 test passed, but the extra GUI harness did not finish its own settlement assertion.
- Full building art packs and male profile screenshot: **PENDING**.
- FULL/CI: not run by instruction.

