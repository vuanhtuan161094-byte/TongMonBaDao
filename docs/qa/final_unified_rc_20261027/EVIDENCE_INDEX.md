# Evidence index — Unified RC final QA

- Exact source: [`0d3952dd11f85bebbde60176deafc4f19afc8a6f`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/0d3952dd11f85bebbde60176deafc4f19afc8a6f)
- RC branch: `integration/pve-unified-rc-20261027`; PR [#52](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/52) Draft/Open, unmerged.
- Full regression: [matrix 22 rows](FULL_22_TEST_MATRIX.csv), [summary](FULL_22_SUMMARY.json), [rerun script](RUN_22_TESTS.ps1).
- Female Stage A: [supplemental matrix](STAGE_A_FOCUSED_MATRIX.csv), [installer log](logs/stage_a_install_only.stdout.txt), [clean isolated import](logs/import_clean.stdout.txt), [down/front after import](logs/stage_a_down_contract_after_import.stdout.txt), [directions after import](logs/stage_a_directions_contract_after_import.stdout.txt).
- Critical logs: [D7 Save A/B](logs/core_d7_save_ab.stdout.txt), [C17](logs/core_c17.stdout.txt), [unique formation](logs/core_unique_formation.stdout.txt), [20 camps](logs/core_population_20.stdout.txt), [Injury120](logs/core_injury120.stdout.txt), [autonomous zone transfer](logs/core_autonomous_zone_progression.stdout.txt), [P3.2 integration](logs/core_p3_2_live_integration.stdout.txt), [JX #158 VFX](logs/visual_jx_vfx_saveresume.stdout.txt), [profiler probe contract](logs/visual_perf_probe.stdout.txt), [selected-only actor/camera](logs/visual_p3_2_live_map.stdout.txt).
- [All stdout, Godot logs and exit files, sanitized, in one ZIP](logs/FULL_22_LOGS_AND_IMPORT.zip). Matrix log paths map to paths inside that ZIP.
- [GUI acceptance and manual checklist](GUI_ACCEPTANCE.md), [FPS OFF/ON results](FPS_OFF_ON_COMPARISON.csv), [regression findings](REGRESSION_DIAGNOSIS.md), [mainline feature audit](MAIN_MERGE_READINESS.md), [SHA-256 manifest](SHA256SUMS.txt), [overall report](FINAL_QA_REPORT.md).

## All 22 exact-SHA cases (exit 0 each)

| # | Test |
|---:|---|
| 1 | `core_runtime_clock` |
| 2 | `core_d7_save_ab` |
| 3 | `core_safe_recovery` |
| 4 | `core_live_runtime_1` |
| 5 | `core_live_runtime_2` |
| 6 | `core_save_return_reload` |
| 7 | `core_c17` |
| 8 | `core_unique_formation` |
| 9 | `core_population_20` |
| 10 | `core_hp0_bridge` |
| 11 | `core_injury120` |
| 12 | `core_sourcea_pointer_2172` |
| 13 | `core_autonomous_zone_progression` |
| 14 | `core_p3_2_live_integration` |
| 15 | `visual_jx_vfx_saveresume` |
| 16 | `visual_sourcea_death_snapshot` |
| 17 | `visual_perf_probe` |
| 18 | `visual_care_combat_presenter` |
| 19 | `visual_p3_2_camera` |
| 20 | `visual_p3_2_live_map` |
| 21 | `visual_disciple_ui` |
| 22 | `visual_injury_presentation` |

## Data handling

No save files, source-art masters, Stage A PNG/ZIP, credentials, process environment, or HWND are included. Logs replace local account/worktree paths with placeholders. Negative-save errors and root-certificate warnings are retained as test/environment output.
