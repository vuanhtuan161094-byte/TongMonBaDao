# SX-GATE-01 — Production source and upgrade fail-closed diagnostic

**Implemented as executable Python code (stdlib only), not merely a design.** Runs locally without launching Godot, Chrome, or creating a save. This makes it suitable for the user's 8 GiB RAM machine.

## Files
- [`tools/qa/sx_source_gate.py`](../../tools/qa/sx_source_gate.py): reads canonical `BuildingSystem`, `ResourceRegistry`, crops, alchemy recipes, PvE reward preview, Economy-A market and Equipment loot; identifies static blockers and exports JSON.
- [`tools/qa/tests/test_sx_source_gate.py`](../../tools/qa/tests/test_sx_source_gate.py): fixtures for missing Lv20 milestone, unsourced Tầm Mạch Bàn, disabled Forest/Alchemy upgrades, source added to registry, false producers in comments, tier metadata and fail-closed missing source files.

## Run on an isolated checkout

```powershell
cd E:\TongMonBaDaoWorkspace\01_Game\YOUR_QA_CHECKOUT
py -3.12 -m unittest discover -s tools/qa/tests -p test_sx_source_gate.py -v
py -3.12 tools/qa/sx_source_gate.py --root . --json-out SX_GATE_RESULT.json
# An intentionally strict blocking gate, expected non-zero on current baseline:
py -3.12 tools/qa/sx_source_gate.py --root . --strict
```

Exits **0** for successful diagnostic (even if findings exist); **2** in `--strict` when P0 is present; **3** when required source data missing/unreadable/unparseable. The output is deterministic and does not touch Godot. No network, no pip install.

**QA execution status:** The assistant authored the tool and tests on GitHub, but **has NOT run the Python unit tests or Godot** in its current environment. Codex must execute and publish stdout/stderr/exit and compare with the current HEAD, rather than promote unexecuted files to PASS.

## Expected static baseline findings (from reviewed source; NOT an executed tool result)

- Mine Lv10 `tam_mach_ban` has no supplier detected among current source registries.
- Mine Lv20/30/50/75/100: missing milestone component definitions while required.
- Linh Lâm and Luyện Đan Điện: explicit `upgrade_enabled=false` on baseline.
- Rèn Thân upgrade content pending, independent of the 100 levels advertised.
- Linh Điền heart 29 total / 2,900 fragments / 58,000 expected harvests at base 5% chance (not time).
- Mine theoretical Lv100 output under current formula ×66 at full staff vs target ×10,000 (speed1/10 tick premise; **not measured runtime**).
- When run against PR #58 branch, 240 unique medicine IDs but only ranks 1–2 authored as recipe metadata; no claim of actual 240 craftable items.

## Limitations and nonnegotiable release rules

Static source markers may exist in disabled/locked PvE, so `potential_sources` are **candidate** suppliers only. A source must still prove: unlock→job/kill→actual receipt→Warehouse→consumer→Save/Reload. Player money affordability, RNG tails, offline and GUI are **not** established by the scanner. It intentionally cannot override or rebalance level caps, ingredient acquisition, medicine grades or B3/Save.

Do not integrate this gate into existing green CI as `--strict` until its true P0 findings are fixed or individually reviewed; baseline is expected to return 2. It is safe to run diagnostic without `--strict` while investigating.

**Coordination:** This exists on a docs/QA branch only. The running Codex agent owns current G1 work; use it as a separate later check. Never cherry-pick the branch wholesale into the active game worktree. 
