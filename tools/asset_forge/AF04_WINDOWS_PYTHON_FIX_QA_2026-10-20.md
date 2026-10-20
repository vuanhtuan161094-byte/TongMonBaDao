# AF-04 Windows Python launcher fix — 2026-10-20

## Root cause

Original AF-04 `MO_ASSET_FORGE_STUDIO.cmd` selected `python` after `where python` returned success, without running/validating that executable. Windows `App execution aliases` exposes `Microsoft\WindowsApps\python.exe`, which passes `where` but can display the Microsoft Store message. A separate failure occurs when `py` exists but does not point to a working Python 3.10+ installation.

## Fix

Shared `FIND_PYTHON.cmd` verifies Python >=3.10 using `-c`, explicitly skips WindowsApps aliases, checks `py -3`, virtualenv/Conda, PATH, and common per-user/system Python directories, and supports `TMB_PYTHON_OVERRIDE` for other installations. All five launchers use it, plus a one-click `KIEM_TRA_PYTHON.cmd` diagnostic. No gameplay/asset code changed.

## Evidence / limits

- Three static launcher tests: PASS. All six Python CMD entrypoints call the centralized dispatcher.
- Asset Forge Python focused tests: **32/32 PASS** in Linux (29 preexisting + 3 bootstrap static tests; game/asset workflows unchanged).
- ZIP CRC and path inventory: PASS.
- Actual Windows cmd.exe / installed user Python / Windows UI: **PENDING USER**, not represented as PASS.
