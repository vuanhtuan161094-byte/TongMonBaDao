# AUX-02: PvE world input and movement QA report

- Issue: [#42](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/42), parent [#37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37)
- Date: 2026-10-27
- QA branch: `qa/pve-aux02-world-input-contract-20261027`
- Base: `9ad423ec9fa08b388c9aef96b8316f7b6c0bd2c5`
- Tested code commit: `382878af63a9b589931cc87b53425f07599f8c95`
- Scope: Godot QA tests and fixture controls only. No production UI, renderer, gameplay, save service, or art source was edited.

## Environment and evidence level

Ran `E:\Godot_v4.7.2-stable_win64_console.exe` (`4.7.2.stable.official.ed1daf0bf`) on Windows in headless mode. The tests inject pointer events into the actual world view. No GUI session or physical mouse was tested; automated input is not mouse acceptance.

The Source A navigation identity was `sect_isometric_source_a_pve_v1`, 192x192, source SHA `c0e6b9952ce6303718938f5705a0327d0a14b136`. The import command exited 0 ([import log](pve_aux02_world_input_contract_20261027/logs/godot_import.log)). Godot emitted a Windows root-certificate-store error during headless runs; the local tests still completed and produced the results below.

## Focused results

| Gate | Result | Evidence |
| --- | --- | --- |
| AUX-02 world input contract | **FAIL: 2 findings**, 1,744 checks reached | [console](pve_aux02_world_input_contract_20261027/logs/world_input_contract_console.log), [engine](pve_aux02_world_input_contract_20261027/logs/world_input_contract_engine.log) |
| Production P3.2 click handler and SaveService movement restore | **PASS**, 6 active orders and destinations round-tripped | [console](pve_aux02_world_input_contract_20261027/logs/pve_multicamp_p3_2_movement_console.log), [engine](pve_aux02_world_input_contract_20261027/logs/pve_multicamp_p3_2_movement_engine.log) |
| Open-world save identity contract | **PASS**, 9 checks | [console](pve_aux02_world_input_contract_20261027/logs/save_identity_console.log), [engine](pve_aux02_world_input_contract_20261027/logs/save_identity_engine.log) |

The world input contract covers world/screen inverse mapping at five camp positions and three zoom levels, all 20 minimap/world positions and route checks, injected zoom anchoring and camera pan, valid and out-of-map clicks, blocked-cell snapping, six-member movement, Save/Restore of active orders, 20-zone travel, and monster pathing around the stream. `physical_mouse=NOT_TESTED` is printed by the test.

## Findings

1. **Low-level group ordering can assign colliding destinations.** A walkable click at Source A cell `(92, 68)` yielded only three distinct destinations for six disciples. This reproduces when the signal is forwarded directly to `MapBattleV2.order_group_move(ids, destination)`, whose per-actor nearest-walkable offsets can converge on occupied cells. The production P3.2 handler has its own free-slot assignment; the integration run verified six distinct slots with 2.83 minimum spacing. Do not treat this low-level finding as evidence that the production handler duplicates slots.
2. **Movement can stall after entering the destination cell.** During sequential zone travel, the order for C17 remained active with actor position `(96.35806, 168.0268)` and target `(96.5, 168.5)`. Both floor to cell `(96, 168)`; distance is `0.494`, just outside the `0.45` completion threshold. The path finder returns no route for start and goal in the same cell, so the actor never closes the remaining distance and the command does not finish.

These are QA findings only; they were not changed in production code in this branch.

## Additional full integration run

The unfiltered P3.2 live integration reached and passed the six-order Save/Restore assertion, then failed its later endgame Injury120/loot expectation (`outcome=defeat`, `kills=0`, `camp=C01`, `injury_valid=true`). That later assertion is outside Issue #42 movement acceptance. The focused run exits after the relevant movement Save/Restore gate. See [full integration console](pve_aux02_world_input_contract_20261027/logs/pve_multicamp_p3_2_live_console.log) and [engine log](pve_aux02_world_input_contract_20261027/logs/pve_multicamp_p3_2_live_engine.log).

## Reproduction commands

```powershell
E:\Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/presentation/pve_aux02_world_input_contract_test.gd
$env:TMB_PVE_AUX02_FOCUSED_MOVEMENT_ONLY = '1'
E:\Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/presentation/pve_multicamp_p3_2_live_integration_test.gd
E:\Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/simulation/pve_open_world_save_identity_contract_test.gd
```
