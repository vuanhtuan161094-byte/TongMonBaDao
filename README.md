# Tông Môn Tycoon — P0 Simulation Sandbox

Step 15 P0 foundation for **Tông Môn Bá Đạo**.

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

### Windows — easiest

Double-click:

```text
Verify-P0.cmd
```

The verifier auto-discovers Godot 4.7.2 from PATH, a running Godot process, Downloads/Desktop, or the repository. If needed, set `GODOT_BIN` to the exact executable path.

### PowerShell

```powershell
pwsh -File tools/godot/Verify-P0.ps1
```

The gate runs:

1. Godot import.
2. GDScript parse checks.
3. decision contracts.
4. economy contracts.
5. 20,000-tick invariant scenario.
6. save/load resumed simulation.
7. same-seed reproducibility.
8. 8-seed × 12,000-tick benchmark.
9. bounded headless runtime smoke.

A successful benchmark writes `godot/reports/p0_benchmark.json`.

The GitHub Actions workflow is currently manual-only because the first two jobs were never assigned a runner. Once GitHub can start the runner, the same P0 gate can be dispatched from Actions.

## Run the debug sandbox

```powershell
godot --path godot
```

## Skill snapshot

`tools/godot/Vendor-GodotSkills.ps1` downloads the explicitly pinned `vl4dt/godot-skills` snapshot and copies only the selected skills into `/skills`.

See `skills/SOURCE_LOCK.md`.

## Status

Do not call P0 PASS from source inspection or mirror simulation. P0 becomes green only when the Godot runtime gate is green.
