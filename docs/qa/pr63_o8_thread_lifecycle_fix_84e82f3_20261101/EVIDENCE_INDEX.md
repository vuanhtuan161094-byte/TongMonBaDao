# PR #63 O8 lifecycle QA evidence

## Scope and identity

- PR #63 remains an open Draft at baseline SHA `cabdf54656b252541ea42fa029f370cc1f2e8d0e`; no PR #63 ref was changed.
- Test-only fix branch: `qa/o8-thread-lifecycle-fix-20261101`, exact pushed SHA `84e82f301b86616c24e241e02fbe798681803a99`.
- Fix consists only of two commits changing `godot/tests/presentation/p3_o8_alchemy_loop_test.gd`; no production SaveService, gameplay, save data or assertion was modified or weakened.
- Official runtime: Godot `4.7.2.stable.official.ed1daf0bf` on Windows.

## Results

- Import on the fix SHA: exit 0, no parse diagnostics. Stderr contains the environment's Windows root-certificate-store error.
- PR #63 exact baseline O8: 3/3 isolated runs exit 0 with the required PASS marker, but each reproduced one `Thread object is being destroyed without its completion having been realized` warning. Baseline is therefore not accepted as clean.
- Temporary diagnostic trace: four started save threads had matching joins. The fifth thread belonged to the final O8 scene's SaveService owner `-9223371697837569432`, thread instance `-9223371644989338229`; `_notification(PREDELETE)` observed `pending=true`, immediately followed by Godot's Thread destructor warning. The O8 harness was tearing the scene down while the final UI autosave coroutine/worker was still active. Its test helper disabled `runtime_ready` before `queue_free`, bypassing the normal scene `_exit_tree()` save barrier. See `THREAD_TRACE_DIAGNOSTIC.txt`; this run used temporary instrumentation and is diagnostic-only.
- Fix SHA O8: 3/3 separate profiles exit 0, PASS marker present, zero Thread destructor warnings, zero parse diagnostics.
- PR #62 regression set on the fix SHA: 8/8 exit 0 with their PASS markers; zero Thread destructor warnings and parse diagnostics. B3 pill/CARE stderr includes expected negative-fixture rejection diagnostics.
- PR #60 physical 1280x720 GUI acceptance remains **PENDING** because Computer Use approval was unavailable. No GUI PASS is claimed.

## Fix behavior

Before scene teardown the O8 test now waits for an active runtime poll to finish, joins any prior pending save, then starts and awaits a final UI autosave and verifies the durable job/snapshot boundary. Original gameplay/save assertions remain intact. This fixes the test's teardown lifecycle race; it does not change SaveService production behavior.

## Evidence files

- [Regression matrix with source SHA and exit codes](REGRESSION_MATRIX.csv)
- [Redacted raw stdout/stderr and exit records](RAW_LOGS_REDACTED.txt)
- [Temporary Thread/SaveService lifecycle trace](THREAD_TRACE_DIAGNOSTIC.txt)

Raw logs retain test data and diagnostics while replacing local user/worktree paths. No save files were uploaded.

