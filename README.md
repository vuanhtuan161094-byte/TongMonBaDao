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

## Current candidate

This package is a **static bootstrap candidate**. The current ChatGPT execution environment does not contain the Godot 4.7.2 executable, so import/parse/runtime gates have not been claimed.

On a machine with Godot 4.7.2:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot/Verify-P0.ps1
```

To run the debug sandbox:

```powershell
godot --path godot
```

## Skill snapshot

`tools/godot/Vendor-GodotSkills.ps1` downloads the explicitly pinned `vl4dt/godot-skills` snapshot and copies only the selected skills into `/skills`.

See `skills/SOURCE_LOCK.md`.
