# Evidence index — PR #52 patch

- Exact tested RC SHA: 9ad0c29cb04776f692a48e89558277e855e63aef
- Godot: 4.7.2.stable.official.ed1daf0bf
- Final matrix: 7 focused tests, all exit 0; import exit 0. This is a targeted matrix because the patch changes only a presentation test, installer portability, and checkpoint docs; simulation/combat/save/economy production code is untouched.
- Source files, logs and command paths were filtered in publication copies. The CSV keeps timestamps, elapsed time, exact SHA and exit code.
- GitHub archive contains text evidence only; no generated PNGs or ZIP art package.

## Exact-SHA commands

| # | Case | Command | Exit | Status | Exact SHA | Godot | Logs |
|---:|---|---|---:|---|---|---|---|
| 1 | p3_2_live_modular_map | <code>Godot_v4.7.2-stable_win64_console.exe --headless --path godot --log-file logs/p3_2_live_modular_map.godot.log --script res://tests/presentation/p3_2_live_modular_map_test.gd</code> | 0 | PASS | 9ad0c29cb04776f692a48e89558277e855e63aef | 4.7.2.stable.official.ed1daf0bf | [stdout](logs/p3_2_live_modular_map.stdout.txt) · [Godot](logs/p3_2_live_modular_map.godot.log) · [exit](logs/p3_2_live_modular_map.exit.txt) |
| 2 | p3_2_map_camera | <code>Godot_v4.7.2-stable_win64_console.exe --headless --path godot --log-file logs/p3_2_map_camera.godot.log --script res://tests/presentation/p3_2_map_camera_test.gd</code> | 0 | PASS | 9ad0c29cb04776f692a48e89558277e855e63aef | 4.7.2.stable.official.ed1daf0bf | [stdout](logs/p3_2_map_camera.stdout.txt) · [Godot](logs/p3_2_map_camera.godot.log) · [exit](logs/p3_2_map_camera.exit.txt) |
| 3 | p3_2_disciple_ui | <code>Godot_v4.7.2-stable_win64_console.exe --headless --path godot --log-file logs/p3_2_disciple_ui.godot.log --script res://tests/presentation/p3_2_disciple_ui_test.gd</code> | 0 | PASS | 9ad0c29cb04776f692a48e89558277e855e63aef | 4.7.2.stable.official.ed1daf0bf | [stdout](logs/p3_2_disciple_ui.stdout.txt) · [Godot](logs/p3_2_disciple_ui.godot.log) · [exit](logs/p3_2_disciple_ui.exit.txt) |
| 4 | p3_2_live_integration | <code>Godot_v4.7.2-stable_win64_console.exe --headless --path godot --log-file logs/p3_2_live_integration.godot.log --script res://tests/presentation/pve_multicamp_p3_2_live_integration_test.gd</code> | 0 | PASS | 9ad0c29cb04776f692a48e89558277e855e63aef | 4.7.2.stable.official.ed1daf0bf | [stdout](logs/p3_2_live_integration.stdout.txt) · [Godot](logs/p3_2_live_integration.godot.log) · [exit](logs/p3_2_live_integration.exit.txt) |
| 5 | jx_vfx_saveresume | <code>Godot_v4.7.2-stable_win64_console.exe --headless --path godot --log-file logs/jx_vfx_saveresume.godot.log --script res://tests/presentation/pve_jx_sword_vfx_adapter_test.gd</code> | 0 | PASS | 9ad0c29cb04776f692a48e89558277e855e63aef | 4.7.2.stable.official.ed1daf0bf | [stdout](logs/jx_vfx_saveresume.stdout.txt) · [Godot](logs/jx_vfx_saveresume.godot.log) · [exit](logs/jx_vfx_saveresume.exit.txt) |
| 6 | sourcea_death_snapshot | <code>Godot_v4.7.2-stable_win64_console.exe --headless --path godot --log-file logs/sourcea_death_snapshot.godot.log --script res://tests/presentation/pve_sourcea_death_snapshot_contract_test.gd</code> | 0 | PASS | 9ad0c29cb04776f692a48e89558277e855e63aef | 4.7.2.stable.official.ed1daf0bf | [stdout](logs/sourcea_death_snapshot.stdout.txt) · [Godot](logs/sourcea_death_snapshot.godot.log) · [exit](logs/sourcea_death_snapshot.exit.txt) |
| 7 | safe_save_recovery | <code>Godot_v4.7.2-stable_win64_console.exe --headless --path godot --log-file logs/safe_save_recovery.godot.log --script res://tests/simulation/safe_01_save_recovery_test.gd</code> | 0 | PASS | 9ad0c29cb04776f692a48e89558277e855e63aef | 4.7.2.stable.official.ed1daf0bf | [stdout](logs/safe_save_recovery.stdout.txt) · [Godot](logs/safe_save_recovery.godot.log) · [exit](logs/safe_save_recovery.exit.txt) |

## Asset bootstrap gates

- [Official import stdout](logs/godot_import.stdout.txt) · [Godot log](logs/godot_import.godot.log) · [exit](logs/godot_import.exit.txt)
- [Tracked transport install-only stdout](logs/stage_a_tracked_install.stdout.txt) · [exit](logs/stage_a_tracked_install.exit.txt)
- [External ZIP fallback stdout](logs/stage_a_external_fallback_install.stdout.txt) · [exit](logs/stage_a_external_fallback_install.exit.txt)
- [Detailed patch report](PATCH_REPORT.md) · [hash manifest](SHA256SUMS.txt)
