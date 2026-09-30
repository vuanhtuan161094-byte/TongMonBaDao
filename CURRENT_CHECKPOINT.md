# CURRENT CHECKPOINT

Date: 2026-09-30

## Project state

Step 13 Technical Architecture & Development Roadmap: LOCKED.
Step 14 P0 Prototype Specification: LOCKED.
Step 15 Repository Bootstrap + P0 Foundation: STATIC CANDIDATE.

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

## Completion status

Not runtime-verified in this environment because the Godot executable is unavailable.

Next closure condition:
run `tools/godot/Verify-P0.ps1` on the real machine and resolve any import/parse/test/runtime failures before marking P0 foundation green.

## Static review patch

- Added a 200 Linh Thạch sect operating reserve for market purchases.
- SELL falls back to HUNT when market spendable treasury is exhausted, preventing an EVALUATE↔SELL spin loop.
- Inventory/economy item keys use JSON-stable strings.
- RNG state serializes as string to preserve exact integer state across JSON.
