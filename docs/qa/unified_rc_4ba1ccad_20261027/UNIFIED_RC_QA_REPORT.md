# Unified RC #52 — exact-SHA QA

- **Branch:** integration/pve-unified-rc-20261027
- **Exact SHA:** 4ba1ccad25c1d03053cefbc724c1a19287d4c0f3
- **Worktree:** <LOCAL_QA_WORKTREE>
- **Engine:** 4.7.2.stable.official.ed1daf0bf
- **Run window:** 2026-10-27 09:56–10:09 +07
- **Code changes:** none; tracked HEAD remains exact RC SHA.

## Focused exact-SHA tests

| Group | Test | Exit | Result |
|---|---|---:|---|
| PR51 core | core_runtime_clock | 0 | PASS |
| PR51 core | core_d7_save_ab | 0 | PASS |
| PR51 core | core_safe_recovery | 0 | PASS |
| PR51 core | core_live_runtime_1 | 0 | PASS |
| PR51 core | core_live_runtime_2 | 0 | PASS |
| PR51 core | core_save_return_reload | 0 | PASS |
| PR51 core | core_c17 | 0 | PASS |
| PR51 core | core_unique_formation | 0 | PASS |
| PR51 core | core_population_20 | 0 | PASS |
| PR51 core | core_hp0_bridge | 0 | PASS |
| PR51 core | core_injury120 | 0 | PASS |
| PR51 core | core_sourcea_pointer_2172 | 0 | PASS |
| PR51 core | core_autonomous_zone_progression | 0 | PASS |
| PR51 core | core_p3_2_live_integration | 0 | PASS |
| PR50 presentation | visual_jx_vfx_saveresume | 0 | PASS |
| PR50 presentation | visual_sourcea_death_snapshot | 0 | PASS |
| PR50 presentation | visual_perf_probe | 0 | PASS |
| PR50 presentation | visual_care_combat_presenter | 0 | PASS |
| PR50 presentation | visual_p3_2_camera | 0 | PASS |
| PR50 presentation | visual_p3_2_live_map | 1 | FAIL |
| PR50 presentation | visual_disciple_ui | 0 | PASS |
| PR50 presentation | visual_injury_presentation | 0 | PASS |

**Summary:** PR #51 core 14/14 PASS. PR #50/presentation focused tests 7/8 PASS; visual_p3_2_live_map failed at setup because Stage A female asset pack is absent. This test did not reach live-map assertions.

### P3.2 integration detail

core_p3_2_live_integration.stdout.txt: six distinct formation slots, minimum separation 2.83; active Save/Load verified; shared clock finished at battle time 76 s, 165 actions, 10 kills, active battle, zone-hop PASS, Injury120 NOT_REACHED, live minimap/camera contracts, no fabricated rewards (LOOT_PENDING). This is headless integration evidence, not a physical GUI playtest.

core_autonomous_zone_progression.stdout.txt: Save/Reload true, C01→C02, 11 kills, 5 C01 respawns, 6 party records, 5 living disciples, 9 alive monsters, zero claims and warehouse unchanged.

### Normal GUI launcher

Run-PVE-Play.cmd started the official Godot 4.7.2 GUI from this worktree at requested 1280×720, loaded res://scenes/p3/p3_2_landscape_sect.tscn, and logged TMB_ENDGAME_LIVE_P3_2_READY with 130 QA-roster records. The GUI process responded and was closed gracefully after the Computer Use helper could not enumerate its window. Both cua.listWindows() and sky.list_apps()/list_windows() omitted the native Godot window, so no physical clicks, screenshot, or video were obtained.

- **REAL_MOUSE / SAVE-RETURN GUI:** PENDING_GUI.
- **FPS logger OFF/ON, phase percentiles, 1%-low, spikes:** PENDING_GUI; no phase metrics were collected.
- **RAM:** one non-controlled GUI snapshot at the Sect screen was 816,553,984 bytes (~0.76 GiB); this is not peak/phase RAM.
- **Screenshot/video:** not captured; no authentic local media artifact exists.

Manual completion: launch Run-PVE-FPS-QA.cmd, spend 15 s in the Sect, click “Săn quái / Thanh Trúc Lâm”, select six eligible disciples, enter, move by clicking ground, observe automatic combat/JX #158 plus camera/minimap, Save and Return. Close that run, then repeat the same route with Run-PVE-FPS-QA.cmd /log. Save screenshots/video using Windows capture tools. Keep the two logger runs sequential.

### Environment and diagnostics

Every Godot run logged Failed to read the root certificate store from Windows; all executed test cases still returned their recorded exit codes. The initial import used a relative --log-file path and emitted an editor-settings warning; a second import used an absolute log path and isolated APPDATA, exited 0. The first focused harness attempt omitted res://tests/; those File not found invocations were preserved under logs/invalid_script_path_invocation/ and are not counted as test failures.

### Evidence paths

- Test result CSV: godot/outputs/unified_rc_qa_20261027/exact_sha_test_results_corrected.csv
- Individual Godot official logs and stdout/exit codes: godot/outputs/unified_rc_qa_20261027/logs/
- GUI launcher log: godot/outputs/pve_jx_world_20261026/logs/pve_play_launcher_cache_optimized_20261026.godot.log
- GUI isolated save: godot/outputs/pve_jx_world_20261026/userdata/pve_play_launcher/live_save_130.json
- Initial status/header/footer: godot/outputs/unified_rc_qa_20261027/qa_header.txt, qa_footer.txt
