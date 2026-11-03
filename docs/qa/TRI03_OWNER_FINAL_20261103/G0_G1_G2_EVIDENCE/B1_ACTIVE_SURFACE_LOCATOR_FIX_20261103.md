# B1 active-surface locator fix — 2026-11-03

PR #67 remains Draft and unmerged. Current code head before this evidence file: `ae16a8ba4963a19531c0d7d34cafbdae588f6968`.

## Root cause

On the live P3.2 scene, the legacy `DanTienScreenV2` host keeps its old dialog subtree in the tree but hides it while B1 is active. The old subtree and the active B1 surface both contain a `CandidateSearch` control. Test helpers called `ui.find_child("CandidateSearch", true, false)`, which returns the hidden legacy field first. They then tried to find candidate buttons on the active B1 surface, so the filter was never applied and the authentic candidate row was absent. This was a test locator defect; the product B1 surface is not being weakened or replaced.

## Fix

Three regression helpers now require the visible node `DanTienScreenV2/TriFacilityB1LiveAdapterV1` and scope CandidateSearch, CandidatePick and Accept lookups to that B1 surface. Gameplay assertions, candidate identity, canonical accept callback, visible second confirmation, SaveService and exact-once checks are unchanged.

| File | Blob SHA at `ae16a8b` |
|---|---|
| `godot/tests/presentation/gp_01_v2_mine_vertical_slice_test.gd` | `70b3749ce3fedbca5ebab798814e3f575805d4ff` |
| `godot/tests/presentation/gp_02a_v2_cultivation_panel_test.gd` | `9c38a69c7e5f64a0a144235027f9ad75d6ba4e2a` |
| `godot/tests/presentation/p3_o6_m1_release_rehearsal_test.gd` | `edd52f73d7806108938fe9bf658467b1c24b4897` |

## Godot 4.7.2 Windows test results

Tests used an isolated absolute save path under `E:\\TongMonBaDaoWorkspace\\03_QA_Logs\\TRI03_OWNER_FINAL_20261103`; owner/default save profile was fingerprinted before and after GP-01 and remained unchanged. The temporary test script copy changed only SAVE_PATH, then was removed with its temporary save artifacts.

| Test | Exit | Result |
|---|---:|---|
| GP-01 V2 guidance → mine → warehouse → offline exactly-once | 0 | PASS |
| GP-02A V2 cultivation → safe busy command → Save/Reload | 0 | PASS |
| P3 O6 M1 end-to-end release rehearsal | 0 | PASS |

Raw local logs: `gp01_b1_locator_fixed_20261103.log`, `gp02a_b1_locator_fixed_20261103.log`, `o6_b1_locator_fixed_20261103.log`. Each contains the test PASS marker and Godot’s non-fatal Windows root-certificate-store warning. Certificate checks were not disabled. Two unrelated/headless Godot processes were left running.

The existing G0 focused evidence (async SaveService, P0 Save/Reload, recovery and independent-process reload) remains at [the prior matrix](TEST_MATRIX.csv). The full clean-checkout 14-case G0 suite is still **PENDING**; no historical result is reused as a pass for a clean checkout at this head.

## Game evidence

The launcher had already opened a responsive official Godot 4.7.2 window (PID 13624, title `Tong Mon Ba Dao (DEBUG)`). The 1280×720 before/after facility captures and New Game flow captures are in [EVIDENCE_INDEX.md](EVIDENCE_INDEX.md). Windowed inputs were harness-injected; physical owner mouse play, Android/touch, and owner approval of generated icons remain **PENDING**.

The project overlay is local Git HEAD `27ed01cd8f377994e5e50bac9ede84e78e8895bd`, not a clean checkout. The 49 pinned source blobs match the earlier code commit `36532c39f294e1eb56d73d8ce0c0eb7cb68c5567`; the three test blobs above match PR head `ae16a8ba4963a19531c0d7d34cafbdae588f6968`. Do not call overall G0→G2 acceptance complete from these focused results.

GitHub Actions has not reported a workflow run or combined status for `ae16a8ba4963a19531c0d7d34cafbdae588f6968` yet; CI remains **PENDING** at this exact PR head.
