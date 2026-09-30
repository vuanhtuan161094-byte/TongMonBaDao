# CURRENT CHECKPOINT

Date: 2026-09-30

## Project state

Step 13 Technical Architecture & Development Roadmap: LOCKED.
Step 14 P0 Prototype Specification: LOCKED.
Step 15 Repository Bootstrap + P0 Foundation: IN PROGRESS.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns simulation/gameplay authority.
- No dual JS/Godot gameplay authority.
- Simulation is presentation-independent.
- Seeded RNG is mandatory.
- Save schema is versioned from P0.
- Invariants are mandatory.
- UI is a debug consumer of simulation state only.

## P0 scope

- 6 fixed disciple behavior profiles.
- 3 regions.
- 3 monster species.
- 4 loot resources.
- 11 action names: IDLE, EVALUATE, TRAVEL, HUNT, COMBAT, LOOT, RETURN_SECT, SELL, BUY, HEAL, REST.
- Tông Môn treasury + disciple wallets.
- Dynamic buy price bounded to 0.8x–1.2x.
- Recovery loop.
- Save/load.
- Debug inspector.

## Current verification suite

1. Godot import.
2. Parse all project/test GDScript.
3. Decision contracts: fixed profile region choices, retreat-risk ordering, broke-injured REST, funded-injured HEAL.
4. Economy contracts: sell/heal/supply transfer conservation and market operating reserve.
5. Single-seed 20,000-tick invariant scenario.
6. Save/load contract: full-state round trip, malformed/invalid-version rejection, resumed simulation invariants, and deterministic continuation against a same-state control.
7. Same-seed deterministic reproducibility.
8. Multi-seed benchmark: 8 seeds × 12,000 ticks.
9. 180-frame headless runtime smoke.

Benchmark telemetry includes total money, treasury range, combat outcomes, sale/recovery activity, per-disciple safe/medium/danger exposure, and ending wallet/HP/stamina. It writes `godot/reports/p0_benchmark.json`.

## Static / mirror review patches already applied

- 200 Linh Thạch sect operating reserve for market purchases.
- SELL falls back to HUNT when market spendable treasury is exhausted, preventing an EVALUATE↔SELL spin loop.
- Inventory/economy item keys use JSON-stable strings.
- RNG state serializes as string to preserve exact integer state across JSON.
- Region definitions include `recommended_power`.
- Region selection combines profit + risk tolerance - underpower penalty; profit alone cannot force every profile into the hardest zone.
- Broke injured disciples use free Rest recovery instead of returning to combat because they cannot afford paid healing.
- Debug inspector exposes region scores and chosen-region rationale.
- Save loading now fails closed for malformed current-version payloads and invalid negative versions instead of silently constructing a default state.
- Save verification now compares the full round-tripped state and requires deterministic continuation to match a same-state control after another 2,000 ticks.
- `last_decision.action` is stored as a JSON-stable string; runtime converts it back to `StringName` only when executing the action.
- A non-authoritative mirror simulation was used only as a design sanity check; it does NOT satisfy the Godot runtime gate.

## GitHub Actions runner blocker

Two CI attempts were accepted by GitHub but failed before a runner executed any step:

- run `36663544443`;
- run `36663692983`.

Both reported no executed steps and no usable job log. Changing from a third-party Godot setup action to a direct download of the official Godot 4.7.2 binary did not change this behavior. Therefore this is treated as a runner/prepare-job blocker, not as evidence that the Godot project or P0 tests failed.

The workflow is temporarily `workflow_dispatch` only so normal development pushes do not create misleading red runs. It remains ready for manual execution once a GitHub-hosted runner can actually start the job.

## Completion status

NOT P0 PASS yet.

Reason: no real Godot 4.7.2 runtime has completed the nine-stage verification gate. Source review, mirror simulation, and pre-run CI failures are not substitutes for runtime proof.

Next closure condition:
run `tools/godot/Verify-P0.ps1` on any environment where Godot 4.7.2 can execute, fix every import/parse/test/runtime failure, then mark P0 green only with the exact gate evidence.
