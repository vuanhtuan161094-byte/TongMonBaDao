# AUX-01 Issue #41 — QA evidence

Date: 2026-10-27
Status: **focused headless gates PASS with one independently reproduced clock-owner persistence FAIL**

## Authority and tested revision

- Read Issue #37 and `docs/handoffs/TMB_PVE_PLAY01_HANDOFF_2026-10-26.md` before starting Issue #41.
- Isolated branch: `qa/pve-aux01-save-return-20261027`.
- Tested QA code SHA: `c26491c1bfdb40deb67cc3e3c7f5cdb4931509af`.
- The QA code SHA is based on feature SHA `7c79a7740938e4a5852234fa3826850db902b167`. At final upstream inspection, the feature branch had advanced to `6b3fd181392c96c2386e5aa85950d2e993d67dda`; its only changes after `7c79a77` are `CURRENT_CHECKPOINT.md` and `NEXT_CHAT_HANDOFF.md`. No gameplay, Combat V2, or SaveService code changed after the tested code base.
- Runtime: Godot `4.7.2.stable.official.ed1daf0bf`, Windows, all runs `--headless`; `TMB_SOURCE_SHA` was set to the tested QA code SHA.
- No production gameplay, Combat V2, `SaveService`, `SimulationRuntimeOwnerV2`, or `HuntingPveRunV2` files were edited. No main merge or GUI launch was performed.

## Exact-SHA focused runs

Each run used an isolated Godot user-data directory under the task workspace and a captured engine log in `godot/outputs/qa_aux01_issue41_20261027/logs/`.

| Gate | Result | Exit | Evidence |
|---|---:|---:|---|
| `pve_save_return_reload_exactly_once_test.gd` | PASS — 50 checks; active 6/10 save/reload, bad SHA/map rejection, same-wall no-step, HP0 receipt once, zero Warehouse delta, return/reopen, `LOOT_PENDING` | 0 | [save-return-reload.log](../../godot/outputs/qa_aux01_issue41_20261027/logs/save-return-reload.log) |
| `pve_open_world_save_identity_contract_test.gd` | PASS — 9 checks | 0 | [identity-fail-closed.log](../../godot/outputs/qa_aux01_issue41_20261027/logs/identity-fail-closed.log) |
| `pve_multicamp_combat_hp0_bridge_test.gd` | PASS — real Combat V2 HP0, journal receipt and no reward | 0 | [combat-hp0-receipt.log](../../godot/outputs/qa_aux01_issue41_20261027/logs/combat-hp0-receipt.log) |
| `pve_multi_camp_population_v1_test.gd` | PASS — 20 camps, duplicate life/receipt barriers, no loot | 0 | [population-idempotency.log](../../godot/outputs/qa_aux01_issue41_20261027/logs/population-idempotency.log) |
| `gp_02c1_injury_settlement_test.gd` | PASS — T01–T23 terminal, recovery, compatibility and Injury120 cases | 0 | [injury120-settlement.log](../../godot/outputs/qa_aux01_issue41_20261027/logs/injury120-settlement.log) |
| `dv2_03_live_runtime_integration_test.gd` | PASS twice back-to-back in the same isolated user-data directory after fixture cleanup | 0, 0 | [run 1](../../godot/outputs/qa_aux01_issue41_20261027/logs/runtime-live-run-1.log), [run 2](../../godot/outputs/qa_aux01_issue41_20261027/logs/runtime-live-run-2.log) |
| `pve_multicamp_p3_2_live_integration_test.gd` | PASS — active save/load and shared clock; 6 V2 members vs 10 monsters, movement verified, no fabricated rewards | 0 | [p32-live-integration.log](../../godot/outputs/qa_aux01_issue41_20261027/logs/p32-live-integration.log) |
| `dv2_03_runtime_clock_test.gd` | **FAIL** — runtime owner save assertion; time advanced but SaveService rejected the save | 1 | [runtime-clock-owner-fail.log](../../godot/outputs/qa_aux01_issue41_20261027/logs/runtime-clock-owner-fail.log), [diagnostic](../../godot/outputs/qa_aux01_issue41_20261027/logs/runtime-clock-owner-diagnostic.log) |

The runtime-owner diagnostic returned `{ok:false, error:1, steps_run:2, pending_minutes:0}` while state reached `tick=2`, `runtime_last_wall_unix=2120`, and remainder `0.0`. The same result reproduced with a fresh, isolated app-data directory. This is a persistence failure outside the test-only lane; no production workaround was made.

### Separate source follow-up for the clock-owner FAIL

The reproduction narrows the failure to the save path after correct clock advancement. A separate implementation lane should identify whether `SaveService.save_to_path` returns `FAILED` from the staged write or staged round-trip validation, then add this exact owner fixture as a regression and fix only the rejecting persistence condition if the fixture is valid. Do not change clock accounting based on this evidence.

The P3.2 harness ended with the encounter still active (`shared_clock_seconds=71`, `actions=141`, 7 kills). Zone hop and Injury120 are reported `NOT_REACHED` by this short headless integration; the dedicated GP-02C1 suite above covers Injury120 and passed. No physical GUI or mouse acceptance is claimed.

## Test/fixture change

- Added `godot/tests/simulation/pve_save_return_reload_exactly_once_test.gd`, using only an isolated QA save path.
- Updated `dv2_03_live_runtime_integration_test.gd` cleanup to remove its owned primary, `.tmp`, and `.bak` files. Without `.bak` cleanup a repeated test could interpret an old backup as a save that should be missing; the fixed test passes twice consecutively.
- The root certificate store warning appears in Godot logs on this Windows environment. Expected negative-fixture logs also include invalid JSON and the intentional legacy occupation-conflict rejection; the associated test gates exit 0.
