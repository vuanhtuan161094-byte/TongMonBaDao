# TMB — ONE WINDOWS SESSION / CONTROLLED QA & INTEGRATION HANDOFF (2026-10-27)

**OWNER INTENT:** Continue GitHub research while Windows is off; when the PC is available, do all verification in one organized local session **without indiscriminate merging**. This checklist is executable by Codex on Windows 8GB with Godot 4.7.2. It is not an authorization to change locked Combat V2 or player saves.

## 1. Baselines to check (never hardcode a stale SHA as latest)

| Role | Branch / PR at audit | Reviewed SHA |
| --- | --- | --- |
| Stable GitHub | `main` | `29b5fba448b0178cb520a4ada44b375b4b934e31` |
| Current playable candidate | `feature/pve-jx-continuous-world-20261026` | `6b3fd181392c96c2386e5aa85950d2e993d67dda` |
| C17 same-cell movement + owner-save diagnostic | Draft [#46](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/46) | `49db887a7785a3111278d1bb992037e8884b5861` |
| Atomic six-person formation | Draft [#47](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/47) | `528f6914261cd4b7725fd972dc39226e33954d50` |
| SaveService source A/B differential | Draft [#48](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/48) | `5915fca17b8e23b3afb597f1f379c4d2d60cecbb` |
| AUX-01 Save/Return tests | Draft [#45](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/45) | `0a69ac951c0ea80c13b50e16855a61d3f4a9ba4f` |
| AUX-03 VFX Source A / JX | Draft [#44](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/44) | `89d1061770c87858b76b7f940d2c35fae75edf56` |
| Independent whole-project audit | `audit/tmb-whole-project-readiness-20261027` | Read live GitHub branch HEAD before test |

NOTE: each candidate base may have advanced since this audit. The above is an evidence snapshot, not a merge manifest.

## 2. Stage 0 — READ-ONLY safety preflight (first)

- Make sure no 4 concurrent Godot windows: on 8 GB RAM, one GUI or one headless test batch at a time. Don't indiscriminately kill user processes.
- Do not use Administrator/profile switch, don't clear `%APPDATA%`, `E:\...`, source asset packages, existing `.bak`, player save or Codex worktree.
- Identify real project checkout path and Godot 4.7.2 binary from `TMB_GODOT` (or E: official executable). Run the audit-only `Run-TMB-Audit-Preflight.cmd` **when this audit branch is present in its own clean worktree**.
- Read exact values from `git status --porcelain=v1`, `git worktree list --porcelain`, `git rev-parse HEAD`, `git ls-remote origin refs/heads/main` and official `godot --version`. No `git clean`, hard reset or `git pull` in dirty worktree.
- Protect player save via a separate owner-approved backup outside test worktrees; never copy a real private save into GitHub issue/log. QA launchers use their own isolated `user://` and synthetic `godot/outputs` paths.

## 3. Stage 1 — Test the independent FIXES *sequentially*, no merge

**A. SAVE FIRST (highest blast radius):** isolate Draft #48 in a scratch worktree. Run:
```powershell
.\Run-PVE-Save-Forensics.cmd
```
Then the original baseline `dv2_03_runtime_clock_test.gd`, `safe_01_save_recovery_test.gd`, `gp_02c1_injury_settlement_test.gd`. Compare mutated-D7 aptitude to unmodified control; capture exact staged `wire_probe`, `foundation_errors`, exact load and OS rename probe. Don't assume error1 proves a specific failure path. If fixture invalid, **correct test fixture through proper Foundation authority** in a *separate authorized patch*, not SaveService. Preserve all red tests, save versions and `.bak`.

**B. MOVEMENT:** verify Draft #46 separately on its SHA:
```powershell
E:\Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/simulation/pve_same_cell_move_c17_regression_test.gd
```
Must show no C17 stall after Save/Restore.

**C. FORMATION:** verify Draft #47 separately on its SHA:
```powershell
E:\Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/simulation/pve_group_move_unique_formation_test.gd
```
Must give six distinct valid goals, deterministic replay and whole-command rejection on insufficient grid tiles.

**D. COMBINED REPLAY:** only after B+C individually pass, create a THIRD **temporary** integration QA worktree starting at latest Codex PvE feature HEAD; selectively apply reviewed disjoint `MapBattleV2` hunks + just the corresponding test files, with explicit diff review. Do NOT merge either complete PR and do NOT change `main`. Add AUX-02 20-zone world input contract test fixture as appropriate. Re-run 6v10 Save/Restore, 20-camp movement, boss/no-reward, Injury120, save identity. Treat its existing low-level formation collision and controlled-zone-hop tests separately: don't confuse a different combat scenario with a failing canonical rule.

**E. VFX (if machine has headroom):** run AUX-03 `pve_jx_sword_vfx_adapter_test.gd` separately, preserving source hashes and JX #158 graphics. No unverified Source A skill/prefab link should be promoted.

Keep all engines/headless suites **serial**, not four Codex testing simultaneously. It is fine to leave work blocked with logs instead of forcing a PASS.

## 4. Stage 2 — Real GUI performance & interaction (physical mouse / normal Godot window)

The current `Run-PVE-FPS-QA.cmd` compares logger OFF and ON using a fresh isolated 130-disciple seed for each invocation; audit branch contains a proposed bug fix so each Godot `--log-file` is timestamped, avoiding overwriting earlier evidence. Apply this QA-only hunk in a **reviewed scratch worktree** before measuring, not by merging the audit branch wholesale.

Run on the same exact gameplay SHA:
```bat
Run-PVE-FPS-QA.cmd
Run-PVE-FPS-QA.cmd /log
```

For EACH run (don't keep both open), with physical mouse: 15s Sect production, open Săn quái, select six real V2 members, PvE move/camera/attack for 30–60s, Save, Return, 10s Sect after return. If Save/Return cannot occur, mark BLOCKED and do not silently substitute scripted signals.

Capture:
- runtime exact SHA and Godot 4.7.2 string; GPU/renderer; peak static/video memory and node/draw count;
- GUI screenshot + normal captured screen recording only if tool works (not FPS from MovieWriter);
- `godot/outputs/pve_perf_qa_20261026/metrics/normal_gui_<run_id>.jsonl` for both modes with `start`, `sample`, `phase_summary`, `stop`;
- real phase `frame_gaps_ms` from `phase_summary` to calculate exact P50/P95/P99, max, and FPS slowest1% per phase. **Do not aggregate percentile summaries arithmetically**; 3s windows are only hints;
- top actual frame spikes and `godot_process_ms` / physics, timestamp-aligned with player action and SaveService refresh. Classify slowdown only when measured.

If the game visually plays but has repeated 100ms+ spikes, status = **VISUAL_PARTIAL / PERF_FAIL**, not PLAYABLE PASS. If desktop capture API times out, an owner-supplied screen recording or visible manual screenshots may help; still do not claim automated capture.

## 5. Stage 3 — Report one matrix and decide, do NOT auto-merge

| Category | PASS evidence required | If RED |
| --- | --- | --- |
| Save correctness | Original owner + PR #48 A/B, SAFE-01, GP-02C1 on correct exact SHA | No production SaveService changes without diagnosed cause |
| 20-zone movement | No C17 stall, distinct formation cells, Source A nav identity, full 20-zone progression | Preserve red fixture + reproduction |
| PvE loop | 6 real disciples vs 10+ real monsters, clock, HP0 kill receipts, Injury120, Save/Return; no fabricated reward | No PLAYABLE label |
| 1280×720 GUI | Real click/pan/zoom/PvE/return, readable controls, screenshots | Visual approval PENDING |
| FPS | Exact per-phase metrics, OFF/ON comparison, large spikes explained | Profile first, optimize second |
| Assets | Source A hash/identity, JX #158 cues and no replay VFX | No speculative conversion |
| Future economics | Documented canonical inventory, no phantom loot, no auto Economy-V2 x100 | Design gate only |

Produce one short GitHub issue comment #37 containing: tested SHA, Godot version, command, pass/fail and exit code per test, log paths or URLs, screenshots and reasons blocked. Then prepare a **single candidate integration review** listing selected paths/hunks and exact conflicting PR ancestry; ask owner to approve before any merge. Never mass-merge 39 stacked Draft PRs.

## Ready-to-send Codex mission (owner may paste ONE message into Windows Codex)

> TÔNG MÔN BÁ ĐẠO — ONE-SESSION QA / NO MERGE. Read latest Issue #37 and the 2026-10-27 whole-project audit + one-session execution document on branch `audit/tmb-whole-project-readiness-20261027`. I am now at my Windows 8 GB machine. Take read-only repo/worktree/Godot 4.7.2 inventory first; preserve E:, active worktrees and all saves. Run PR #48 SaveService forensic A/B, original clock test and SAFE-01 first in separate scratch worktrees. Then run PR #46 C17 and PR #47 six-person formation focused tests, followed by combined scratch 20-zone/6v10 regression only after each passes. Run normal GUI FPS launcher OFF/ON sequentially with exact-SHA timestamped logs and real manual mouse only where available; do not invent screenshots. Update Issue #37 with exact results, test links and blockers. No Combat V2 formula changes, Source A renderer remake, unauthorized loot, file deletion, hard reset, `main` merge, or auto PR merges. Stop and report if SaveService/QA safety gate fails.

## 6. Deferred roadmap after these gates

If and only if above Save/Movement/GUI gates are credible: (1) improve pathfinding/render hotspots under profiler; (2) approve per-monster loot receipt/drop economics; (3) connect canonical Forge R1; (4) mobile touch and asset polish; (5) read-only P3.2 UI modularization and repository artifact retention. Don't launch parallel architecture rewrites while 8 GB Windows runtime is still unverified.
