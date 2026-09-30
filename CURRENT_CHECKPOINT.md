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
3. Single-seed 20,000-tick invariant scenario.
4. Save/load + resumed simulation.
5. Same-seed deterministic reproducibility.
6. Multi-seed benchmark: 8 seeds × 12,000 ticks.
7. 180-frame headless runtime smoke.

Benchmark telemetry includes total money, treasury range, combat outcomes, sale/recovery activity, per-disciple safe/danger exposure, and ending wallet/HP/stamina.

## Static review patches already applied

- 200 Linh Thạch sect operating reserve for market purchases.
- SELL falls back to HUNT when market spendable treasury is exhausted, preventing an EVALUATE↔SELL spin loop.
- Inventory/economy item keys use JSON-stable strings.
- RNG state serializes as string to preserve exact integer state across JSON.

## Completion status

NOT P0 PASS yet.

Reason: this ChatGPT execution environment does not expose a Godot 4.7.2 executable, so the runtime gate has not been executed here. Source/structure review is not a substitute for the Godot gate.

Next closure condition:
run `tools/godot/Verify-P0.ps1` on an environment with Godot 4.7.2 and fix every import/parse/test/runtime failure before marking P0 foundation green.
