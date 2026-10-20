# AF-04 Windows Python Discovery V3 | 2026-10-20

## User-reported evidence
- The only `where.exe python.exe` result was `C:\Users\Admin\AppData\Local\Microsoft\WindowsApps\python.exe`, the Microsoft Store app execution alias; `py -0p` listed nothing in supplied log.
- **Inference only:** no supported Python 3.10+ is exposed to the prior launcher via PATH/py/common folders. This is **not proof that Python is absent**, since a custom location remains plausible.

## Changes
- `FIND_PYTHON.cmd`: honor persistent `python.local.txt`, then fallback to bundled `FIND_PYTHON.ps1` probing PEP 514 Registry keys, Conda, venv, uv and bounded root/custom-drive directories; still verify Python 3.10+ execution before use.
- `KIEM_TRA_PYTHON.cmd`: adds full candidate list; `TIM_PYTHON_CHI_TIET.cmd`: diagnostic report.
- `CHON_PYTHON.cmd` + `.ps1`: browse for *real* installed `python.exe` or paste full path, verify interpreter and persist to local `python.local.txt` (gitignored). Does not install or modify OS PATH.
- `test_windows_python_discovery_v3.py`: four source-level regression checks.

## Verification / limits
- `python -m unittest discover -p test_*.py -q` -> **36/36 PASS (Linux Python 3.13)**; includes existing asset and localhost smoke tests and four new source-level discovery regressions.
- ZIP verified by `ZipFile.testzip`: OK. `.cmd` launchers retain Windows CRLF and `.ps1` scripts are text.
- **PENDING**: actual `cmd.exe` and Windows PowerShell execution on owner's PC; actual Python runtime path/installed version; authentic JX1 binary visual acceptance; Godot/Android. No false PASS.
- No game code, combat numeric, M1/M2/V-01, original assets or save altered; no CI/FULL/merge.

## Operator instructions
1. Extract latest `TMB_ASSET_FORGE_STUDIO_AF04_PYTHON_DISCOVERY_V3_2026-10-20.zip` to a fresh folder.
2. Run `KIEM_TRA_PYTHON.cmd`: if PASS, run `MO_ASSET_FORGE_STUDIO.cmd`.
3. If no PASS, run `TIM_PYTHON_CHI_TIET.cmd` to see all candidates. If one installed Python is in a custom folder, run `CHON_PYTHON.cmd` and choose its `python.exe` once; then rerun Studio.
4. If no Python installation is found, install/repair official Python 3.10+ only after verifying what was already installed.
