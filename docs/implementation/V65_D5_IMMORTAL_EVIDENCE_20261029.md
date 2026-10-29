# V6.5 D5 Immortal implementation evidence — 2026-10-29

## Status

D5 is **HEADLESS_PASS** at source/test commit [`2f193644329ecabcd71d20bf3283972235bf47c1`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/2f193644329ecabcd71d20bf3283972235bf47c1), parent `a0c426291b6fd815678568ba7dfe902a4bca4005`. The existing feature branch is `feature/v63-v64-full-combat-20261029`; stable `main` remains `c0c1382f119599497b52d8ee8abd9e830a883f1e`. PR #52 remains Draft/open at `f7c33d9c3baba3267a17021718b44f87acd62ef6`, unchanged.

## Implemented and verified

- Nine Immortal branches each expose distinct A/B successor paths. Both can remain in learned history, while the same-family active successor is exclusive. The focused matrix exercised 18/18 manual-backed A/B casts through Combat V2.
- Three Immortal bosses have Combat V2 counter windows; the matrix verified 3/3 cast interruptions, stage events, actor-snapshot resume, and bounded elemental reaction behavior.
- Deterministic breakthrough study uses archived manuals and the existing D3 One Active Job authority, with compatible Human prerequisite mastery, candidate cost/tick receipts, exactly-once completion, and save/load coverage.
- Archive/learning catalogs recognize the new lineage records. D5 costs, durations, status coefficients, and boss peak values remain candidate-only. Global gates remain OFF by default.
- Existing Human combat, D2 Archive/receipt settlement, D3 study, P2.3/P2.5, CombatStatsV2, Warehouse, SaveService/SAFE-01, PvE Save/Return/exactly-once and HP0 bridge tests all passed on the same final scratch source snapshot.

## Official Windows Godot run

Runtime: `E:\Godot_v4.7.2-stable_win64_console.exe`, `4.7.2.stable.official.ed1daf0bf`.

Workspace: `E:\TongMonBaDaoWorkspace\01_Game\TMB_V65_D4A_20261029`. Evidence logs: `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D5_20261029`. Headless editor import and the following 18 scripts ran sequentially; every process exited 0. `SHA256SUMS.txt` SHA-256: `067207C5B4681AC8D5DFB1F71BC78FC0886FCAEFDFA5469763A5F5726893E0C2`.

| Log | Result | Log SHA-256 |
|---|---|---|
| `00_import.log` | PASS exit 0 | `B728DE0C23F24D9AA31BC7608B177D7CA13857D7C3ACA862A08506D00675123B` |
| `01_v63_d5_immortal_lineage_combat_test.gd.log` | PASS exit 0; 18/18 manual-backed A/B casts; 3/3 boss counter interruptions; reactions; gates OFF | `899C0D8D3F16E31D91C107AE97EB634CC884282844CA272B61A69F2B61F83AA3` |
| `02_v63_d5_predictable_breakthrough_study_test.gd.log` | PASS exit 0; deterministic study/prerequisites/One Active Job/receipts/save-load | `E5A7ECA6173E5F77D0E11CE4FA1F41D36292BD3B5E974C7B95675754A2DCE79D` |
| `03_v63_d4b_human_branches_bosses_test.gd.log` | PASS exit 0 | `1EB521A92D372EF16E59CD20C09B7D6B30A26C4A3B099118359590D884968AE5` |
| `04_v63_d4b_archive_learning_test.gd.log` | PASS exit 0 | `427E787BDA3EB3E84E10DDD3423CF54CD3B1EB234487C50B6EB9309BBA211300` |
| `05_v63_d2_sect_archive_test.gd.log` | PASS exit 0 | `F2D10F1DC897398031E05BC68FFFADDE2ECE0DA0878C0868DAC49DB0BDD1FBFE` |
| `06_v63_d2_codex_drop_receipts_test.gd.log` | PASS exit 0 | `23CB9EEE73390A7751340F25B78DF6190905A2B51B07260E1E9117914E4F38C8` |
| `07_v63_d3_learning_job_test.gd.log` | PASS exit 0 | `04782DA36E2A234FC081D5E3DF9BF4F12991B1044DBAE2E4FEC64E224F0ED4EE` |
| `08_v63_d4a_human_combat_test.gd.log` | PASS exit 0 | `DF2E6B790C0EC2B787D3456489CF32AD5D5F45A43DE90FB943945FC1463369BB` |
| `09_v63_d4a_state_roundtrip_test.gd.log` | PASS exit 0 | `B5A37A56A1FD4BFCAC133DD22D92D531BDF815347D52F43AE1AF15896E9945D0` |
| `10_v63_d1_content_registry_test.gd.log` | PASS exit 0 | `A404B3A6D3BD93E6C88CA9E8534AC54B5DF145BF3603AB570D2015BD5F8BA617` |
| `11_p2_5_combat_skill_test.gd.log` | PASS exit 0 | `F582FF439983D7DC8690365119360A8D2EBDBBBBA210BBC491A338CAFF3EBCD4` |
| `12_dv2_02_combat_stats_test.gd.log` | PASS exit 0 | `D61FA52D2D0D833779F62E62E70F5CF1D58EE273E31171EA992A2E44BB192543` |
| `13_p2_3_technique_test.gd.log` | PASS exit 0 | `39541A8D1377AFD45589D1233E6EA6A508C24B0D3E4FA62961FEC86A8611B046` |
| `14_p3_7b1_warehouse_test.gd.log` | PASS exit 0 | `3BF2591F4B2A49AF303F830598BB09A7A13FF5FB6D67F6F7A1DC9DB625249DA1` |
| `15_save_service_async_roundtrip_test.gd.log` | PASS exit 0 | `69D6CEC243CB90909F9218BE21FE9855A9547D454271653932351BD40874C678` |
| `16_safe_01_save_recovery_test.gd.log` | PASS exit 0; expected malformed JSON recovery diagnostics | `49F9B5C5C9B0AB1A8B06DD958EA25093CFDD6D596535D8EEAE84D0C3C4639CF0` |
| `17_pve_save_return_reload_exactly_once_test.gd.log` | PASS exit 0; loot still LOOT_PENDING baseline | `54B3814E705F9AE19BA33754905539F635112DC324978B19E2862A86BE0D3671` |
| `18_pve_multicamp_combat_hp0_bridge_test.gd.log` | PASS exit 0 | `59FC99447EF7A83D050D78FB177B5F858151DC4912C2CCF74406C93D92FDE788` |

SAFE-01 intentionally emits malformed-JSON diagnostics while exercising recovery; the test ends `SAFE-01 SAVE RECOVERY PASS`. PvE save-return retains the separately tracked `LOOT_PENDING) baseline.

## Tested source parity

The D5 source/test commit is the exact GitHub tree produced from the isolated tested E: scratch file contents (UTF-8, canonical LF). No import sidecars, unrelated D4/D5 scratch edits, or tool scripts were included. The source/test commit changes exactly these 12 allowlisted paths:

| Path | Git blob SHA |
|---|---|
| `godot/data/combat/v63_immortal_combat_catalog.json` | `7fbcc44f00fd44ff66a1639e5e5f3b4878c8c2ee` |
| `godot/data/combat/v63_learning_catalog.json` | `be065e28642e4c7e92a166d96f705f18c7db1221` |
| `godot/data/combat/v63_archive_catalog.json` | `2470c0e9f3e68a8546c9dd6e2bec95ffbd0d81ca` |
| `godot/src/simulation/archive/v63_sect_archive_system.gd` | `1104026fdde3102cd50fca4af7a1918eef7d650f` |
| `godot/src/simulation/technique/v63_learning_system.gd` | `ad2e4aab40025ddd3d5d06f3635c7a0ea67e24de` |
| `godot/src/simulation/combat/v63_immortal_skill_combat_system.gd` | `78318adb2cc27f252431158b75dd9d6f461863a8` |
| `godot/src/simulation/combat/v63_human_skill_combat_system.gd` | `bb86969d9d4b1ef2406143096584c2529aa3f08c` |
| `godot/src/simulation/combat/map_battle_v2.gd` | `3564b80f9f4f1d5c002ce414e63afd1ffa5b2300` |
| `godot/tests/simulation/v63_d5_immortal_lineage_combat_test.gd` | `8291ba4d892c1bd57663e64e2e0da471dcabfdc5` |
| `godot/tests/simulation/v63_d5_predictable_breakthrough_study_test.gd` | `9cad5eeac3ae69dbffbf8d3d7eb5415f425a20e5` |
| `godot/tests/simulation/v63_d2_sect_archive_test.gd` | `c0ee0aea1ae9d5f0a095ad57b29921a5ca7b287a` |
| `godot/tests/simulation/v63_d3_learning_job_test.gd` | `4e882d95eb099a7d05a4df646196b68e70aaf7ed` |

The scratch checkout's local Git metadata remained at preflight ancestor `91cfc7e9c4975d6f03834355f38d5d6db8308b3c`; publication was performed as a fast-forward Git Data API commit on the verified feature branch tip `a0c426291b6fd815678568ba7dfe902a4bca4005`. The original dirty E: checkout was preserved.

## Not accepted

D4-A live GUI capture, owner visual review, Android, D7 visual/VFX integration and D8 endgame/performance remain **PENDING**. No art/UI changed in D5, so no GUI PASS is claimed. The overall V6.5 program remains **INCOMPLETE**; no merge or new PR was created.
