# C5 JX1 Combat Source Intake — focused QA / 2026-10-21

- Scope: `tools/asset_forge/jx_combat_intake.py`, one-click Windows `QUET_SOURCE_COMBAT_JX1.cmd`, focused tests, README/handoff. No files under `godot/`, no gameplay changes, no CI/FULL/merge.
- User source roots: `E:\Source`, `E:\Tool JX`. These local roots cannot be inspected in the assistant's runtime. No original binary decoding claim.
- Read-only scanner: os.walk bounded; avoids symlinks/junctions, git/venv caches; metadata-only for large files; `PACK` header validation (without full index parsing), key-table SHA-256 only if <=6 MiB; no RAR/ZIP unpack, no execution, no raw file write.
- Candidate pilot: only `人物类型.txt` under `settings/npcres`, source-proven `男主角`; requests AF-04 table/catalog via exact Kind/Part/Sect chain, reports missing evidence as PENDING, does not fake visuals.
- Tests: `python -m unittest discover -p test_*.py -v` **43/43 PASS**, Python isolated Linux local fixture. Includes 7 C5 tests and 36 preexisting Asset Forge focused tests.
- System performance design target: cached JX1 atlases, visible map chunks, interpolate view snapshots, FX budget, avoid reading PACK whole per frame, free camera follow-on-selection only, Android 1280x720. No real frame-rate measurements; Android/Windows Godot 4.7.2 QA **PENDING USER**.
- Windows operator action: run `QUET_SOURCE_COMBAT_JX1.cmd`; then deliver `JX1_COMBAT_SUMMARY.md` and optionally `JX1_COMBAT_SOURCE_MANIFEST.json`. Source binaries may remain on user's PC.
