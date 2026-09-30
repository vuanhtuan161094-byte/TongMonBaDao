# CURRENT CHECKPOINT

Date: 2026-09-30

## Project state

Step 13 Technical Architecture & Development Roadmap: LOCKED.
Step 14 P0 Prototype Specification: LOCKED.
Step 15 Repository Bootstrap + P0 Foundation: LOCKED / PASS.
Step 16 P1.1 Goal + Personality: IMPLEMENTED / AWAITING RUNTIME GATE.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns simulation/gameplay authority.
- No dual JS/Godot gameplay authority.
- Simulation is presentation-independent.
- Seeded RNG is mandatory.
- Save schema is versioned from P0.
- Invariants are mandatory.
- UI is a debug consumer of simulation state only.
- P0 remains the mandatory regression baseline for P1 work.

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

## Current P0 verification suite

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

## P1.1 Goal + Personality scope

P1.1 is a minimal vertical slice only. It does not open recruitment, relationships, memory, cultivation realms, bosses, premium currency, or production art.

Implemented design:

- Existing `risk_bias`, `spend_bias`, and `survival_bias` remain the personality behavior vector.
- Each disciple now has stable `personality_id` metadata.
- Each disciple has deterministic `active_goal` and `goal_changed_tick` runtime state.
- New `GoalSystem` forms goals from current HP/stamina/inventory/economy state plus the existing personality vector.
- Goal values are `RECOVER`, `WEALTH`, `GLORY`, `SECURITY`, `PREPARE`, and `GROWTH`.
- Goal modifiers feed the existing `DecisionSystem`; no second AI authority was introduced.
- Hard safety floors remain authoritative before discretionary P1.1 utility choices.
- Goal modifiers also shape region utility, so different goals can produce measurably different region choices.
- P1.1 behavior is opt-in through `SimulationState.p1_goal_personality_enabled` and `P1Factory`.
- `P0Factory` leaves P1.1 disabled so the locked P0 behavior path remains behavior-identical.
- Personality, active goal, goal-change tick, and the P1.1 feature flag serialize through the existing versioned save path.
- Old P0/current-version saves that do not contain the new optional fields remain loadable with safe defaults.

P1.1 verification contract:

- full P0 9-stage gate must PASS first;
- same seed must produce the same personality/goal state and deterministic simulation state;
- initial P1.1 population must show personality and goal diversity;
- `GLORY` and `SECURITY` must produce different measurable region utility choices in a neutral probe;
- save/load must preserve personality + active goal + goal-change tick + P1.1 enable flag;
- save/load continuation must remain deterministic;
- simulation invariants must remain green.

Authoritative P1.1 command:

`Sync-P1-1.cmd`

This syncs `main`, runs the complete P0 regression gate, then runs the dedicated P1.1 Goal + Personality contract test.

P1.1 may be marked `LOCKED / PASS` only after a real Godot `4.7.2.stable.official.ed1daf0bf` run ends with both:

`P0 FOUNDATION GATE: PASS`

`P1.1 GOAL + PERSONALITY GATE: PASS`

## Runtime verification evidence — P0 — 2026-09-30

Environment:

- Windows 10.
- Godot `4.7.2.stable.official.ed1daf0bf`.
- Local authoritative gate: `Sync-P0.cmd` → `Verify-P0.cmd` → `tools/godot/Verify-P0.ps1`.

Result: all nine stages completed successfully and ended with:

`P0 FOUNDATION GATE: PASS`

`P0 GATE: PASS`

Recorded gate evidence:

- Decision contracts: PASS.
- Economy contracts: PASS.
- 20,000-tick invariant scenario: PASS.
  - total money: 1,630;
  - ending treasury: 203;
  - combats: 11,081;
  - sales: 3,761;
  - recovery actions: 23,487;
  - aggressive-profile danger visits: 1,033;
  - cautious-profile danger visits: 0.
- Save/load round trip: PASS.
  - resumed tick: 3,000;
  - total money: 1,630;
  - disciples: 6;
  - malformed and negative-version fixtures were rejected as intended;
  - deterministic continuation matched the same-state control after another 2,000 ticks.
- Same-seed reproducibility: PASS.
  - seed: 515151;
  - ticks: 5,000.
- Multi-seed benchmark: PASS.
  - 8 runs × 12,000 ticks = 96,000 ticks;
  - total money remained 1,630;
  - treasury range: 201..215;
  - combats: 57,347;
  - wins: 38,661;
  - retreats: 18,032;
  - defeats: 654;
  - sales: 20,163;
  - heals: 23,682;
  - rests: 84,325;
  - buys: 6,795.
- 180-frame headless runtime smoke: PASS.

## Static / mirror review patches already applied in P0

- 200 Linh Thạch sect operating reserve for market purchases.
- SELL falls back to HUNT when market spendable treasury is exhausted, preventing an EVALUATE↔SELL spin loop.
- Inventory/economy item keys use JSON-stable strings.
- RNG state serializes as string to preserve exact integer state across JSON.
- Region definitions include `recommended_power`.
- Region selection combines profit + risk tolerance - underpower penalty; profit alone cannot force every profile into the hardest zone.
- Broke injured disciples use free Rest recovery instead of returning to combat because they cannot afford paid healing.
- Debug inspector exposes region scores and chosen-region rationale.
- Save loading fails closed for malformed current-version payloads and invalid negative versions instead of silently constructing a default state.
- Save verification compares the full round-tripped state and requires deterministic continuation to match a same-state control after another 2,000 ticks.
- Save round-trip float comparison tolerates only representation-level floating-point noise; discrete state remains exact, and continuation must still converge exactly under the deterministic control.
- `last_decision.action` is stored as a JSON-stable string; runtime converts it back to `StringName` only when executing the action.
- Weighted RNG iterates canonically sorted keys, so JSON dictionary key-order changes cannot remap the same RNG roll to a different monster.
- Inventory sales iterate canonically sorted item keys, so a save/load key-order change cannot alter limited-treasury sale behavior.
- Disciple inventory/pending-loot/metrics and sect market/base-price values are normalized back to integer types after JSON load.
- Save JSON uses full float precision to preserve HP/stamina/score values closely enough for deterministic continuation.
- A non-authoritative mirror simulation was used only as a design sanity check; it did NOT substitute for the final Godot runtime gate.

## GitHub Actions runner blocker

Two CI attempts were accepted by GitHub but failed before a runner executed any step:

- run `36663544443`;
- run `36663692983`.

Both reported no executed steps and no usable job log. Changing from a third-party Godot setup action to a direct download of the official Godot 4.7.2 binary did not change this behavior. Therefore this remains classified as a runner/prepare-job blocker, not as evidence that the Godot project or P0 tests failed.

The workflow is temporarily `workflow_dispatch` only so normal development pushes do not create misleading red runs. The local authoritative Godot 4.7.2 gate completed successfully, so the CI runner issue is not a P0 closure blocker.

## Completion status

P0: PASS / LOCKED.

P1.1: implementation and dedicated gate are present, but runtime proof is still required before lock.

Next closure condition: run `Sync-P1-1.cmd` on the local Windows/Godot 4.7.2 environment, fix every regression/P1.1 failure if any, then mark Step 16 `LOCKED / PASS` only with the exact runtime evidence.
