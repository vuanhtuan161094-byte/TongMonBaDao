# Tông Môn Bá Đạo — Combat V3-S1 QA Handoff for ChatGPT

**Date:** 2026-10-24 (Asia/Saigon)  
**Repository:** `vuanhtuan161094-byte/TongMonBaDao`  
**Packet:** A — official Godot 4.7.2 focused QA and in-scope bug repair for PR #29.

## Result

The initial 14-test focused suite passed on PR #29 HEAD `9522812e91b7ca5bc0cc108eb92e000e930fe850`. A separate baseline edge probe exposed five assertion failures. After the allowlisted S1 fixes, the final 14-test matrix passed 14/14 and the expanded S1 edge contract passed 56/56 on source commit `4fe466d8efc192aa93738811041de795baadb22a` (tree `6859fde16ed71a2596d3a5a52539622136d866e0`). Official engine: Godot `4.7.2.stable.official.ed1daf0bf`; import and all tests exited 0 with required markers.

The engine stderr includes `ERROR: Failed to read the root certificate store.` under isolated Windows profiles. The matrix records this as one runtime diagnostic line per process. It did not change exit codes, required markers, or parse/assertion results. Do not omit this note when summarizing PASS.

CARE/B3 burn-kill settlement was exercised through the real world/receipt path: warehouse quantity increased once, the canonical receipt committed, and reload/replay did not award again.

## Changes and limits

The fixes are limited to `map_battle_v2.gd` and `map_battle_snapshot_v2.gd`; test coverage is in `combat_v3_s1_effects_test.gd` and `combat_v3_s1_edge_contract_test.gd`. Frontline learned guard now takes precedence over generic guard, invalid attack intervals do not create rapid basic attacks, and snapshot status/cast/timer provenance and finite bounds are checked.

No UI/UX, Source A, D7, economy/medicine, HP×100, Combat×100, S2, unrelated PR, or PR #29 files were changed. No full CI, Android or physical visual QA was run. PR #29 remains unchanged and unmerged.

Two owner decisions remain explicit: current pilot behavior clears burn when its caster dies; and the repository has no historical binary v2 golden save, so the v2 compatibility fixture is schema-derived rather than a byte-for-byte archive. Neither blocks the tested S1 scope.

## GitHub delivery

Fix branch: `fix/combat-v3-s1-official-qa-20261024`, created from PR #29 head. The code/test commit on GitHub is `e51dabc57ce20c294d03a0e9d64ed3ccd1397b3c`, with the same tree as the locally tested source. The QA report, summary packet, next-task prompt, checksums, runner scripts, CSV results, and baseline/final logs are included in evidence commit `cb68ec7e167320a73894392d0860f053f3f48489`. Draft review PR: [#30](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/30), stacked on PR #29; GitHub reports it clean and mergeable.

See `TMB_COMBAT_V3_S1_OFFICIAL_QA_REPORT_2026-10-24.md` for detailed commands, baseline failures, engine hash, regression list, caveats, and artifact paths. Machine-readable results: `focused_results.csv`, `baseline_results.csv`, `baseline_edge_results.csv`, and `edge_results.csv` in `outputs/COMBAT_V3_S1_OFFICIAL_QA_20261024/`.


