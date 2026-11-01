# QA evidence index — PR #62 and PR #60 (2026-11-01)

## Exact refs and toolchain

- PR #62 head: 7cc555bbdda8389a678caeb54a7197d345b025b2 (tested from a separate detached QA checkout).
- PR #62 base: e7643ba142f5ffbf22b2c56d5086bdbb6cec32cd.
- PR #60 head: 074ca829d2d35a559c445edba17c5e1f9d1dc937.
- Godot: 4.7.2.stable.official.ed1daf0bf.
- Test profiles were isolated under QA-only AppData paths. No user save files are part of this upload.

## PR #62 results on the exact SHA

Import completed with exit 0, empty stderr, and no parse diagnostic. Of the nine requested scripts, eight passed and O8 failed (exit 1). Including import, the matrix is 9/10 rows PASS, 1/10 FAIL.

| Test | Checks/marker | Exit | Status | stderr bytes |
|---|---:|---:|---|---:|
| SX01 JSON policy roundtrip | 13 | 0 | PASS | 0 |
| SX01 pill policy / quota | 32 | 0 | PASS | 0 |
| SX02 medicine runtime | 47 | 0 | PASS | 0 |
| B3 pill satiety | 45 | 0 | PASS | 797 |
| B3 CARE / auto hunt | 39 | 0 | PASS | 413 |
| Async SaveService | 10 | 0 | PASS | 0 |
| P0 Save/Reload | PASS marker | 0 | PASS | 962 |
| O4 Spirit Field | PASS marker | 0 | PASS | 0 |
| O8 Alchemy loop | no PASS marker | 1 | FAIL | 592 |

The prior SX02 QA policy/quota JSON roundtrip failure is resolved on the combined PR #62 SHA: the 32-check SX01 policy test and 47-check SX02 runtime test both passed. B3/P0 stderr contains fail-closed negative-fixture assertions (invalid CARE capability/satiety/counters and malformed/negative-version save payloads); their expected rejection tests completed with exit 0 and PASS markers.

### O8 finding

The official O8 script failed at “reload lost/restarted the exact timed recipe.” The test calls _autosave_runtime() through ui.call() and disposes/reloads the scene without awaiting the coroutine. A temporary, untracked diagnostic copy that awaited those two explicit autosave calls and joined pending saves in its action helper exited 0 with the O8 PASS marker. Both diagnostic runs still emitted a “Thread object is being destroyed without its completion having been realized” warning; therefore this does not upgrade the official O8 result to PASS and leaves async thread cleanup to investigate. The tested PR #62 source and official test were not edited.

## PR #60 GUI status

The exact PR #60 project launched under official Godot at its configured 1280×720 size. Computer Use could enumerate the game window, but image capture timed out at app approval and exposed no game controls. No actual mouse operation or visual assertion was completed. Source A appearance, recruitment filtering/acceptance, guidance actions, capacity-shortage behavior, GUI Save/Reload, and FPS remain PENDING. See PR60_GUI_STATUS.md. The older nine-row PR #60 focused matrix is headless evidence only.

## Files

- PR62_TEST_MATRIX.csv: per-run SHA, exit code, status, marker, parse flag, stderr byte count and redacted log filenames.
- PR62_RAW_LOGS.md: captured PR #62 stdout/stderr plus explicitly labeled diagnostic-only O8 runs.
- PR60_PREVIOUS_FOCUSED_MATRIX.csv: prior exact-SHA PR #60 focused results.
- PR60_PREVIOUS_FOCUSED_RAW_LOGS.md: raw stdout/stderr from the earlier PR #60 headless run; not GUI evidence.
- PR60_GUI_STATUS.md: exact scope and Computer Use blocker for the current GUI attempt.
