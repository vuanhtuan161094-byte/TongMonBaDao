# PVE-OPT01 — Source A Visual Row Copy Optimization — QA evidence

Date: 2026-11-03. Engine **Godot 4.7.2.stable.official.ed1daf0bf**.  
Scope: presentation-only, **no pixel/art/style downgrade and no gameplay authority changes**.  
Basis: PR #67 `f2ae694af791a27deec4e1de7ae7c122914be635` (Draft, unmerged).  
Independent branch: `feature/pve-opt01-preserve-assets-viewrow-20261103`.

## Exact code delta

Production change **ONLY ONE file**: `godot/src/presentation/p3/pve_sect_world_view_v1.gd`, commit `e395efa4f260997e9d0a06ff0e0dc96a789f1f5a`.

Before: `_view_rows = view_rows.duplicate(true)`; immediately after, `SectIsometricWorldV1.set_pve_snapshot(battle,_view_rows,...)` makes a *second* recursive `view_rows.duplicate(true)` copy for renderer.

After: `_view_rows = view_rows` (borrow the per-refresh producer row dictionary without mutating it). The **renderer still retains exactly one defensive deep copy** in `SectIsometricWorldV1.set_pve_snapshot`, thereby isolating live visual HP/selection/labels from any future producer updates. Both Source A world/camera and canonical battle are reused; the immutable snapshot boundary stays within the renderer. No save/schema/clock/actor/AI/map/rig/VFX/loot asset path is altered.

New isolated test: `godot/tests/presentation/pve_opt01_source_a_viewrow_copy_contract_test.gd`, commit `129ef2ebe1a55ffe1b7e6e16c2d0c65af5da7465`.

## Official Godot CI evidence

1. [P3 O2 recruitment map run 41598636209](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41598636209), verified exact experimental SHA `6cfc3c7063283a754ef1b83aa809c6ff29644ee1`, job `125791844439`: GitHub **SUCCESS, 25/25 job steps**.
2. The O2 job calls the standalone new test in a **separate official Godot 4.7.2 process**, not by mocking rows in JavaScript or replacing the engine. Real CI log exact markers:
   - `P3 O2 RECRUITMENT MAP TEST PASS`
   - `PVE_OPT01_SOURCE_A_VIEWROW_PASS {"asset_files_modified":false,"double_deepcopy_removed":true,"renderer_defensive_snapshot":true,"selection_and_hp_updated":true,"simulation_files_modified":false,"source_a_world_reused":true,"visual_rows_after_removal":15,"visual_rows_initial":16}`
   - `PVE_OPT01_STANDALONE_EXIT=0`
   - `PVE_OPT01_TEST_FIRST_GREEN`
3. [P3.6A preview run 41598496684](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41598496684) on clean production OPT01 code SHA `e395efa4f260997e9d0a06ff0e0dc96a789f1f5a`: **SUCCESS, 10/10 job steps**.
4. CI log contains Linux runner **ALSA unavailable -> dummy audio driver** warnings at unrelated windowed smoke steps; job finished SUCCESS. These are host audio-backend warnings, not asset corruptions or visual performance proof.
5. Temporary O2 subprocess adapter was removed in commit `ed3d927c68a8bef1bc8c4e5828d40e78377cb16a` and its final Git blob `04041836e4a7c122caa4d6fd2c9f7a8d61552348` is **byte-identical** to source PR67. Therefore official evidence is from identical native renderer/test code, and the production O2 test is not modified in final tree.

## Precise validation and limits

**PASS:** 6 authentic-shape disciple actor rows + 10 monster render rows stay visible in the Source A Godot render adapter; calling `show_authority_snapshot` on one world object twice updates the drawn HP/selection; after a producer-side nested HP update the prior renderer snapshot remains unchanged; a new snapshot reflects the update; deleted actors disappear from selected IDs/renderer positions. Standalone exit `0`.

**Optimized operation:** exactly one intermediate deep copy removed in a 16-actor snapshot path. **The performance benefit is not measured** (no FPS/P95/RAM benchmark before-versus-after); never claim a numerical speed-up or Android optimization from this single change. Native renderer still draws the **original** PNGs/animated sprites.

**NOT_TESTED:** 12/20/30 actors, 20 independently active camps, multi-map concurrency, hundreds of disciples across maps, real per-kill loot, longer battle completion, physical Windows mouse and Android touch. These remain explicit acceptance gates in [PVE_VISUAL_PRESERVATION_AND_SCALE_ROADMAP_20261103.md](PVE_VISUAL_PRESERVATION_AND_SCALE_ROADMAP_20261103.md).

## Adoption and rollback

- This evidence authorizes **consideration** by TRI-03 and integration owner only. **No code has been pushed to PR #67 or merged into main**; the live P3.2 writer keeps exclusive ownership. Before adopting, recheck live PR HEAD, file blobs and writer consent.
- To adopt only OPT01, copy **one production commit** `e395efa4f260997e9d0a06ff0e0dc96a789f1f5a`; do **NOT** cherry-pick all branch commits (includes tests/docs/temporary adapter history). Keep test as optional independent QA script, not a replacement for asset fidelity checks.
- Revert only the one-line production change if renderer copy isolation, HP update or scene content fails; no player save migration.
- For standalone official rerun: `godot --headless --path godot -s res://tests/presentation/pve_opt01_source_a_viewrow_copy_contract_test.gd`.

**Verdict: PVE-OPT01 functional/visual isolation test GREEN; measured performance gain UNKNOWN.**
