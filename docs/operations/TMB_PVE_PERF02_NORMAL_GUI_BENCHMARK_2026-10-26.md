# TÔNG MÔN BÁ ĐẠO — PVE PERF-02 — Normal GUI Playable Benchmark

**Date:** 2026-10-26. **Source base:** remote PvE `038873592b908c05a28ac7f827a8b831fce000c8`. **Scope:** isolated QA only; Codex Windows PVE-PLAY-01 owns active uncommitted gameplay work. **Status:** CODE PREPARED / GODOT 4.7.2 QA NOT RUN. Never treat this packet as an FPS improvement by itself.

## Why

Codex last reported **2.17 FPS** from a GUI/MovieWriter harness, not from an ordinary player-controlled Windows session. The remote JX snow-map `Run-PVE-JX-World.cmd` is obsolete for the **Source A** continuous world. Do not use it for PvE 0.1 acceptance. This packet opens the **actual P3.2 main scene** and passively records ordinary GUI FPS without MovieWriter.

## Files created

- `Run-PVE-FPS-QA.cmd`: one-click Windows entry. Official **Godot 4.7.2 console**, default `E:\Godot_v4.7.2-stable_win64_console.exe`; set `TMB_GODOT` environment override if installed elsewhere. Run only when Windows 8 GB has no duplicate running Godot.
- `godot/tools/qa/pve_playable_perf_launcher.gd`: imports existing *canonical* `res://qa/endgame_qa_save.json` (130 disciple fixture) into an **isolated new QA save**; starts production `res://scenes/p3/p3_2_landscape_sect.tscn`. An existing QA save is **never overwritten**; corruption fails closed. No JXQY2 asset-root requirement.
- `godot/tools/qa/pve_playable_perf_probe.gd`: passive Node; once every three wall-clock seconds, writes one JSON line. Uses `Time.get_ticks_usec()` monotonic measurements (not Game/Combat clock). Reads FPS, frame time p50/p95/peak, process ms, physics ms, 2D/3D render counter, node count, debug static RAM/renderer memory, current phase `sect` / `pve_active`. No image/video capture, no UI overlay, no gameplay state mutation.
- `godot/tests/presentation/pve_perf_probe_contract_test.gd`: deterministic test for frame duration percentile, very slow 2 FPS spikes and no input mutation.
- `.gitignore` and `godot/.gitignore`: exclude QA output and mutable saves.

### Exact outputs after Windows run

- **Sample records:** `godot/outputs/pve_perf_qa_20261026/metrics/normal_gui_*.jsonl` (run-unique).
- **QA gameplay Save:** `godot/outputs/pve_perf_qa_20261026/userdata/pve_perf_playable_130.json`.
- **Runtime log:** `outputs/pve_perf_qa_20261026/logs/normal_gui.log` (root-relative). 
- **Isolated Godot user config:** `outputs/pve_perf_qa_20261026/userdata/Roaming` and `Local` (root-relative).

These are local-only diagnostic data; do not upload raw user directories, real gameplay Save, personal data or unrelated assets to GitHub.

## Manual reproducible trial

1. Open `Run-PVE-FPS-QA.cmd` from a **temporary clean QA worktree or later reconciled Codex build**; do **not** checkout/reset over PVE-PLAY-01 dirty worktree. **Do not run concurrently** with other Godot clients on an 8 GB system.
2. In P3.2, remain in the ordinary **sect** for **15–20 seconds** (initial warm-up plus stable samples). Let scene/atlas imports settle.
3. Select valid healthy, idle V2 disciple → **Vào Thanh Trúc Lâm** → **6 true disciples vs 10 true monsters**. Stay at PvE for **30 seconds**, pan/zoom, order group movement, observe real JX VFX #158. Do not use MovieWriter.
4. Click **Save**, return to the sect, wait 10 seconds, exit Godot normally. Check that phase changes to `pve_active` and back to `sect` in JSONL. Retest once only if QA seed has appropriate playable V2 disciples (otherwise report blocking roster preparation — do not manufacture/upgrade them).
5. Compare identical actions with **unmodified normal launcher** `Run-Endgame-QA.cmd` to determine profiler overhead; optionally MovieWriter separately in a later test. FPS gain from PERF-01.1 may only be claimed **after** patch is integrated and baseline measured on same machine/settings.

**Stage gates:**
- **QA_TOOL_PASS**: launcher starts real P3.2, ordinary GUI samples contain both `sect` and `pve_active`, profiler does not crash, isolated Save remains reloadable, no production save path touched, and official Godot 4.7.2 exact SHA logs archived.
- **PLAYABLE_PASS (separate gate)**: user can click and play, normal GUI target >=30 FPS stably with frame-ms p95 near/below 33.3 ms, 6v10 real fight/impact, same-clock, Save/Return all pass at exact integrated SHA. If not achieved, log **PLAYABLE_BLOCKED** with profiler bottleneck.
- **NOT PROVED**: Godot `Performance.TIME_PROCESS` is a frame process monitor, not a direct per-method script profiler. `RENDER_TOTAL_DRAW_CALLS_IN_FRAME` may not reflect all 2D Compatibility canvas work. `MEMORY_STATIC` can be 0 outside debug. Samples are low overhead, not zero overhead. For a true hot-function breakdown use the official Godot debugger/profiler with real Windows runtime.

## Regression command for Codex later

```powershell
& 'E:\Godot_v4.7.2-stable_win64_console.exe' --headless --path godot --script res://tests/presentation/pve_perf_probe_contract_test.gd
```

Also run previous PvE focus suites and `pve_multicamp_p3_2_live_integration_test.gd` after merging local. **This branch alone has not been run.** No PASS by static inspection.

## Coordination

Keep three independent prepared patches `2b455682` (PVE PERF-01.1), `7038e878` (GUI same-clock), `c90ab907` (PVE Save identity) separate from this **PERF-02** tool. It is **not** a fourth gameplay branch and must not pre-empt active Codex. Once it checkpoints, back up dirty work, compare files/diffs, port only compatible QA tooling, verify GUI/QA before merge. Issue #37 remains the only coordination channel.
