# PVE-PLAY-01.1 — Triaging AUX-01 SaveService, AUX-02 C17 movement, zone-hop/Injury120

**Date:** 2026-10-27 | **Authoritative baseline:** `feature/pve-jx-continuous-world-20261026` at `6b3fd181392c96c2386e5aa85950d2e993d67dda`.  
**This fix branch:** `fix/pve-play011-movement-save-diagnostics-20261027` (independent; NO main or Windows worktree modifications).

## Evidence matrix

| Gate | Actual evidence | Assessment | Changed |
| --- | --- | --- | --- |
| C17 arrival stall | AUX-02 real Windows Godot 4.7.2 log `pve_aux02_world_input_contract_console.log`, 1,744 checks / 2 findings, Source A SHA `c0e6b9952ce6303718938f5705a0327d0a14b136`. Position (96.35806,168.0268), target (96.5,168.5), active order. | **Reproduced on AUX-02 SHA**. `MapBattleV2._world_path` returns empty on start == goal *cell*. `_move_world_actor` returned false, while `step` only cleared the order at <=0.45 unit separation. Remaining gap ~0.494. | `godot/src/simulation/combat/map_battle_v2.gd`: local sub-cell movement when the positions share a passable cell; preserve world bounds, speed cap, event and deterministic step. New `pve_same_cell_move_c17_regression_test.gd`: exact coordinates, terminal order and Save/Restore. **Godot QA PENDING on this fix SHA.** |
| Low-level group formation collisions | AUX-02 log reports 3 unique destinations from 6 `MapBattleV2.order_group_move` offsets at (92,68), while production P3.2 handler's independent slots delivered 6/6 distinct with minimum 2.83 separation. | **Known low-level API discrepancy, NOT proven production click collision.** | Not changed in this narrowly scoped patch. Separate API-level improvement requires caller-consumer audit. |
| AUX-01 owner clock Save FAILED | AUX-01 `dv2_03_runtime_clock_test.gd` log and diagnostic, isolated Windows Godot 4.7.2 test SHA `c26491c1bfdb40deb67cc3e3c7f5cdb4931509af`: `owner.save_to_path(...,2120)` returns `{ok:false,error:1,steps_run:2,pending_minutes:0}`, state at tick2, wall2120, remainder0.0. | **Real test FAIL.** Clock progressed two minutes as requested. Error 1 corresponds to `FAILED`, which `SaveService.save_to_path` returns when staging write fails OR staged `_load_exact` validation rejects the serialized state; do not assume which without instrumentation. | New isolated `pve_aux01_clock_owner_save_diagnostic_test.gd` compares 2060 vs 2120 owner fixtures, intermediate JSON, `SimulationState.from_dict`, `SaveService._load_exact`, pre/post invariants and write result. Doesn't alter production SaveService/RuntimeOwner. **Diagnostic runtime PENDING.** |
| 6v10 PvE Save/Return/Reload | AUX-01 `pve_save_return_reload_exactly_once_test.gd` **PASS 50 checks**; GP-02C1 Injury120 targeted suite PASS; seven other focused gates PASS except clock-owner test, official Windows Godot 4.7.2. | Narrow 6v10 snapshot/return and Injury120 contracts pass; doesn't erase the independent runtime-owner failure. | No gameplay code changes. |
| AUX-02 full endgame/zone-hop | AUX-02 `pve_multicamp_p3_2_live_console.log`: six move orders+Save/Restore PASS; further full fixture `outcome=defeat,kills=0,camp=C01,injury_valid=true`. Main Codex `7c79a77` had distinct short headless trial 79 shared seconds, 9 kills, active Save/Load (no zone-hop or Injury120). | **Not equivalent combat fixtures.** AUX-02 extends the integration harness to issue six formation move orders and to assert their Save/Restore before progressing fighting, changing actor position/action schedule. The 50-second continuation died early at C01 with valid Injury. Nothing here proves a broken zone transition; it does prove that the modified *full* endgame expectation (`kills>=10 && zone_hop`) was not met. | Preserve production and the failing assertion. Use `TMB_PVE_AUX02_FOCUSED_MOVEMENT_ONLY=1` for its isolated 6/6 movement acceptance (already PASS), and a separately controlled combat fixture with identical positions/orders and enough fight time to test zone-hop/Injury. Do not weaken existing full gates or award fictional kills. |
| GUI smoothness/manual mouse | Issue #37 most recent Codex checkpoint `7c79a77` — optimized 1s PVE HUD, raw phase FPS profiler; GUI capture timeouts. | **PLAYABLE_BLOCKED** pending physical mouse + 15s sect / 30-60s PvE / Save-Return and P50/P95/P99/1%low. | Not part of patch. |

## Commands to run on an isolated Godot 4.7.2 checkout of THIS branch

```powershell
$godot = 'E:\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path godot --script res://tests/simulation/pve_same_cell_move_c17_regression_test.gd
& $godot --headless --path godot --script res://tests/simulation/pve_aux01_clock_owner_save_diagnostic_test.gd
& $godot --headless --path godot --script res://tests/presentation/pve_multicamp_p3_2_live_integration_test.gd
& $godot --headless --path godot --script res://tests/simulation/pve_open_world_save_identity_contract_test.gd
```

- C17 regression MUST return 0 with `PVE SAME-CELL MOVE C17: PASS`; rerun the full AUX-02 20-zone input contract **after manually porting this one gameplay fix to an isolated test branch**. That contract still tests a second, independent low-level destination-uniqueness issue: do not mislabel full contract PASS while collision finding remains.
- Owner clock diagnostic is intentionally a **failing test (exit 2)** if `SaveService` still rejects second-minute checkpoint. Capture stdout and compare `direct_from_dict` / `load_exact` / `save_error`; implement production save changes only after identifying an actual incompatibility.
- The main P3.2 integration is a smoke/regression, not a physical mouse acceptance. Pin exact test SHA and preserve isolated user data. Never launch alongside another heavy Godot GUI on the owner's 8 GB Windows PC.
- A static GitHub patch and GDScript test source are **not** a Godot 4.7.2 runtime PASS. No manual GUI or FPS evidence is asserted.

## Safety guardrails
- Keep Combat V2 formulas, Injury 0/1/120, SaveService, SimulationRuntimeOwnerV2, Source A asset bytes, existing registry SHA checks, one-active-job and LOOT_PENDING unchanged.
- No cherry-pick / merge to active Codex worktree or `main` without explicit review. The fix branch is an independent proposal.
