# SX-MASTER-01 — G0 async Save/Reload runtime QA

**Date:** 2026-10-31 (Asia/Saigon)
**Repository:** `vuanhtuan161094-byte/TongMonBaDao`
**Source branch / SHA:** `integration/one-game-v65-20261030` / `199f888c7fd690830728dfbf29b6b79276e3b283`
**Source tree:** `55cda18698e92cf614f001dd1bd3288491dff3b4`
**G0 fix branch:** `codex/sx-master-01-g0-async-save-20261031`
**Code/test SHA:** `fa010df49b455dc896a9b5c509c85fccfce09448`
**Engine:** official Windows `4.7.2.stable.official.ed1daf0bf`; import exit 0.

## Result

| Run | Result | Evidence |
|---|---:|---|
| Baseline, 199f | 10/14 strict PASS; 4/14 invalid/FAIL | O3/O8 printed PASS but each destroyed two unfinished threads; O7/O9 failed Save/Reload assertions and all four emitted the thread warning. |
| Focused after harness fix | 4/4 PASS | O3/O7/O8/O9 exit 0, PASS markers, no unfinished-thread warning. |
| Full final run, fa010df | **14/14 PASS** | Every test exit 0, PASS marker present, no SaveService/thread-join warning. SAFE-01 intentionally logs malformed-fixture JSON parse errors and still reports its recovery PASS marker/exit 0. |

The exact per-test exit codes, durations, PASS markers, thread-warning flags and system free-memory samples are in `G0_TEST_MATRIX.csv`. Raw stdout/stderr are retained by phase under `logs/`. The matrix records the **code SHA** each test ran against, not the later evidence-only branch head.

## Root cause and minimal change

`p3_2_landscape_sect.gd` delegates autosave to `p3_1_landscape_sect.gd`; that async function starts `runtime_session.save_async()` and awaits `runtime_session.wait_for_pending_save(get_tree())`. The runtime owner delegates to `SaveService.wait_for_async_save()`, which waits for the worker to stop and calls `Thread.wait_to_finish()` before returning. The four production-loop tests called this coroutine with `ui.call("_autosave_runtime")` but did not `await` it, then disposed the scene and reloaded immediately. This caused a nondeterministic save/reload race and thread destruction warnings; O3/O8 could appear to pass while still leaking the unfinished thread.

The commit adds `await` at all 7 test save call sites in O3/O7/O8/O9. Assertions and production logic remain unchanged. No SaveService code, payload, validation, backup transaction, warehouse, or save contract was altered. Existing `save_service_async_roundtrip_test.gd` passed its 10 checks, including snapshot isolation, join-before-sync, and prior-backup validity.

## Resource and data safety

- Each test ran sequentially with an isolated APPDATA/LOCALAPPDATA/TEMP profile; no player save profile was used.
- No Godot process remains from this run.
- System available RAM during the final run ranged from 2257 to 2358 MiB.
- Per-process WorkingSet sampler returned 4.8–5.0 MiB for the Godot process and is clearly invalid; it is excluded as a memory result. Do not interpret it as actual RSS.
- Godot import changed generated `.import` metadata in the QA worktree. Those changes and other imported artifacts were left unstaged and uncommitted; the original SX00 source checkout and user saves were not modified.

## Not covered by G0

G0 does not establish PR #57/#58 acceptance, GUI, offline economy, or full New Game → production → medicine → cultivation → PvE playability. G1 must review and test PR #57/#58 separately before any selective integration. No merge performed.