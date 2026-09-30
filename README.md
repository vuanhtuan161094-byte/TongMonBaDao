# Tông Môn Tycoon — P0 Simulation Sandbox

Bootstrap candidate for Step 15.

## Target

- Godot 4.7.2
- GDScript
- Portrait debug runtime: 390x844
- Godot/GDScript is the simulation authority from day one.
- No JS gameplay bridge.
- Deterministic seeded simulation.
- Static definitions are separated from runtime state.
- P0 scope: 6 disciples, 3 regions, 3 monster species, autonomous hunt/combat/loot/economy/recovery loop.

## P0 executable loop

EVALUATE -> HUNT -> TRAVEL -> COMBAT -> LOOT -> EVALUATE

Recovery/economy branches:

RETURN_SECT -> SELL / BUY / HEAL / REST -> EVALUATE

## P0 verification

Local Windows/Linux with PowerShell and Godot 4.7.2 on PATH:

```powershell
pwsh -File tools/godot/Verify-P0.ps1
```

The gate runs:

1. Godot import.
2. GDScript parse checks.
3. 20,000-tick invariant scenario.
4. Save/load resumed simulation.
5. Same-seed reproducibility.
6. 8-seed × 12,000-tick benchmark.
7. Bounded headless runtime smoke.

A successful benchmark writes `godot/reports/p0_benchmark.json`.

GitHub Actions runs the same gate on pushes and pull requests to `main` using Godot 4.7.2 and uploads the benchmark report as an artifact.

## Run the debug sandbox

```powershell
godot --path godot
```

## Skill snapshot

`tools/godot/Vendor-GodotSkills.ps1` downloads the explicitly pinned `vl4dt/godot-skills` snapshot and copies only the selected skills into `/skills`.

See `skills/SOURCE_LOCK.md`.

## Status

Do not call P0 PASS from source inspection or mirror simulation. P0 becomes green only when the Godot runtime gate is green.
