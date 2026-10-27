# TMB — TWO CODEX CONTROL SHEET / FOUR HISTORICAL LANES (2026-10-27)

**Owner request:** finish unfinished tasks with **two** Windows Codex sessions, without racing worktrees, changing canonical Combat V2 or merging into `main`. The two task files in this branch are executable assignments, NOT historical STATUS/PASS certificates.

## Task dispatch — one writer per subsystem

| Original lane | Implemented evidence | Pending blocker(s) | Executor |
| --- | --- | --- | --- |
| Windows main PvE #37 | PvE feature `6b3fd18`; 6v10 battle, 79 sim seconds, 9 authentic kills/active Save-Load on `7c79a77`; map cache/selected actor; 1s UI refresh | Physical mouse/camera/Save-Return, FPS percentile and true screenshot/video, 20-zone progression, Injury120 | CODEX 1 owns simulation/zone/Injury; CODEX 2 owns P3.2 visuals/GUI/FPS |
| AUX-01 #41 / PR #45 | Official 4.7.2: 50 Save/Return checks, HP0, identity, population receipt, GP-02C1, live runtime tests PASS | Owner `dv2_03_runtime_clock_test` FAIL error1 after correct 2 ticks. Stage unknown, PR #48 forensic unexecuted | CODEX 1 |
| AUX-02 #42 / QA branch / PR #46, #47 | Source identity 9/9; injected camera/world contract; P3.2 handler had 6 unique goal points | C17 same-cell stall `0.494>0.45`, low-level 6-person command -> 3 unique slots; long injected route battle `kills=0`; both proposed fixes not Godot-verified | CODEX 1 |
| AUX-03 #43 / PR #44 | JX #158 35 rect/anchor/hash verified, E: real Unity clips and textures recorded, manifest and replay VFX test committed | Godot runtime test not run due to nine Godot processes; Unity role/prefab/skill mapping UNVERIFIED | CODEX 2 |

GitHub audit snapshot:
- `main` `29b5fba448b0178cb520a4ada44b375b4b934e31`;
- active PvE `feature/pve-jx-continuous-world-20261026` `6b3fd181392c96c2386e5aa85950d2e993d67dda`;
- `audit/tmb-whole-project-readiness-20261027` `d2adf282cbfb4ec362f565c2c7d42de4009bb6df`;
- PRs #44/#45/#46/#47/#48 all open Draft, mergeable **at snapshot time only**, **not merged**. Fetch live heads on launch, do not force old SHAs.

## The two executable work orders

**Codex 1 — CORE:** [TMB_CODEX1_CORE_RECOVERY_EXECUTION_2026-10-27.md](./TMB_CODEX1_CORE_RECOVERY_EXECUTION_2026-10-27.md). Create `recovery/pve-core-a1-20261027` worktree on remote feature HEAD. Own SaveService if proven, combat movement/formation and simulation QA only. Adopt reviewed PR #45/#46/#47/#48 tests and AUX-02 source test with exact SHA. Godot test slot FIRST.

**Codex 2 — VISUAL:** [TMB_CODEX2_PLAYABLE_VISUAL_FPS_EXECUTION_2026-10-27.md](./TMB_CODEX2_PLAYABLE_VISUAL_FPS_EXECUTION_2026-10-27.md). Create `recovery/pve-playable-visual-a1-20261027` worktree on feature HEAD. Own P3.2 UI/camera/Source A/JX VFX adapters, AUX-03 manifest replay test and FPS QA launcher/tools. Do static/provenance and isolated UI code while CODEX 1 runs Godot. Official Godot or GUI only after CODEX1 slot release.

## Windows 8 GB resource protocol

1. Both Codex threads may **analyze and write disjoint worktrees in parallel**.
2. Check `Get-Process | Where-Object { $_.ProcessName -match 'godot' }` before running official engine. Never kill processes not confidently owned by the current Codex. If nine existing windows remain, engine test is BLOCKED until the user closes/identifies them. No forced taskkill or automatic restart.
3. CODEX 1 comments `CODEX1_GODOT_QA_START SHA=<exact>` to #37, runs **one** serial Godot headless task at a time, closes its processes, comments `CODEX1_GODOT_QA_RELEASE status=<...> SHA=<...>`.
4. CODEX 2 must check the latest Issue #37 comments before engine use. Unless RELEASE explicitly exists **for this run** and OS is free of conflicting foreign Godot GUI, mark `PENDING_ENGINE_SLOT` and finish static/source/PR handoff. Do not wait for hours or claim runtime PASS.
5. Disable parallel Godot GUIs, no `git clean`, destructive checkout, force push, save deletion, Windows admin profile changes, or unsolicited external asset copying.
6. The only shared writing venue is **Issue #37 comments**; each session links its own independent Draft PR and exact-SHA evidence. Code ownership is disjoint.

## In-scope code changes

| Scope | CODEX 1 | CODEX 2 |
| --- | --- | --- |
| `save_service.gd`, D7 fixture, safe recovery | WRITE narrowly after proof | READ |
| `map_battle_v2.gd`, `hunting_pve_run_v2.gd` movement/zone only | WRITE narrowly after proof | READ |
| Godot simulation tests, imported AUX-02 presentation test | WRITE | READ |
| `p3_2_landscape_sect.gd`, Source A world visual renderer/view | READ | WRITE only UI/presentation |
| JX #158 adapter/manifest and AUX-03 test | READ | WRITE |
| FPS launcher/probe, normal playable launcher | READ | WRITE |
| `main`, live feature branch, physical player saves, E: unrelated files | NEITHER | NEITHER |

## Owner-friendly done definition

**CODE DONE** means source patch/test committed and a Draft PR exists. **QA PASS** requires successful official Godot 4.7.2 on the *exact resulting SHA* and log with test name/exit code. **PLAYABLE PASS** additionally requires actual normal Windows 1280×720 GUI/mouse/PvE/Save-Return interaction and frame/screenshot evidence (cannot infer it from headless tests). **ASSET VERIFIED** distinguishes correct sprite SHA/rect from unproven Unity prefab/pivot/skill mapping. **INTEGRATED** means a separate selected-composition candidate survived cross-system tests; it is **not** synonymous with merged into `main`.

## Final composition, only when both tasks actually finish

- No automatic merging of 39 historical Draft PRs. Existing #44/#45/#46/#47/#48 remain source/history of evidence, not an ordered merge queue.
- If CODEX 1 candidate is green and published **before CODEX 2 closes**, CODEX 2 may make a **THIRD disposable integration-review worktree** from refreshed active PvE feature, import the already-tested *exact* core candidate and its own visual candidate, run focused end-to-end QA. **Do not manually edit CODEX 1's core code while composing**; if a shared-file conflict or any QA failure appears, label `INTEGRATION_BLOCKED` and publish conflict table. Do not change both PR branch histories to force assembly. Such a composed worktree can create **one additional Draft integration PR** to feature ONLY if complete. No `main` merge or feature-branch merge without owner sign-off.
- If CODEX 1 not ready, CODEX 2 closes own Draft visual PR and lists dependency `WAIT_CORE_SHA`; final composition is the user's later decision.
- Both final reports must expose PASS/FAIL/PENDING per gate, no fabricated runtime and no re-running ancient statuses as current. Link #37 plus original issues #41–#43, exact commit and evidence paths.

## Links / reference packets

- [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37).
- [Whole-project audit](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/audit/tmb-whole-project-readiness-20261027/docs/operations/TMB_WHOLE_PROJECT_AUDIT_2026-10-27.md).
- [One-Windows-session QA plan](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/audit/tmb-whole-project-readiness-20261027/docs/operations/TMB_2026-10-27_ONE_SESSION_WINDOWS_EXECUTION.md).
- [AUX-01 SaveService forensic proposal](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/48).
