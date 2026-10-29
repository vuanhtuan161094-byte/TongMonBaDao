# V6.5 D4-B Human Branches and Bosses — Evidence (2026-10-29)

## Status

- D4-B implementation: **HEADLESS_PASS** on feature source SHA bbd6f83984c45e5212847bdaf326f14ef5ab469f.
- Official Windows Godot 4.7.2 headless editor import: **PASS**, exit 0.
- Focused and affected cumulative regression: **16/16 PASS**, sequential, exit 0 for every script.
- Actual GUI, owner visual acceptance, Android, performance, and overall D4–D8: **PENDING / INCOMPLETE**. D4-B changed no UI, scene, image, asset, or VFX file; visual integration belongs to D7. D4-A's live GUI capture remains pending.

## Branch and parity

Repository vuanhtuan161094-byte/TongMonBaDao; branch feature/v63-v64-full-combat-20261029. Stable main remains c0c1382f119599497b52d8ee8abd9e830a883f1e. D4-B source/test files were published sequentially to the existing branch; no branch rewrite, PR creation, merge, or PR #52 mutation occurred. Final D4-B source/test commit: bbd6f83984c45e5212847bdaf326f14ef5ab469f. All seven code/catalog/test blobs match the canonical local Git blob hashes used by the final tested snapshot. The D4-B coverage ledger records this source SHA. PR #52 remains Draft/open at f7c33d9c3baba3267a17021718b44f87acd62ef6.

## Implemented and exercised

- 105 Human nodes across all nine branches, with one derived innate and the designed slots present for each branch.
- Six shared-school basic/mobility behaviors and manual-backed active_01 learning/equip/use for all nine branches, through MapBattleV2 and CombatStatsV2.
- Three Human bosses execute telegraphed attacks and release into real combat; phase 70%/35% events are one-time and survive snapshot/resume.
- All 96 Human skill codex source-node mappings validate. Tests cover owner-attributed bounded poison, dead-owner tick suppression, guard, heal, cleanse, marks, bounded AoE, mobility/evasion, passives, and boss poison cap.
- Candidate balance only. sect_codex and human_skill_combat remain OFF by default; tests explicitly opt in. SaveService/schema, P2/P2.3 legacy, One Active Job, Injury120, Warehouse authority, scheduler, production economy, and asset files were not changed by D4-B.

## Godot 4.7.2 Windows evidence

Engine: E:\Godot_v4.7.2-stable_win64_console.exe  
Version: 4.7.2.stable.official.ed1daf0bf  
Logs: E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D4B_20261029_final

Import command: `--headless --editor --import --path godot`; exit 0; stdout SHA-256 B7E73A8D12AAAA8C0356CE80000CCEDD937B0A1D3E603B7205F8CDF597A3E5B4.

Each test ran sequentially as `--headless --path godot --script res://tests/simulation/<script>`:

| Script | Exit | stdout SHA-256 |
|---|---:|---|
| v63_d4b_human_branches_bosses_test.gd | 0 | 1EB521A92D372EF16E59CD20C09B7D6B30A26C4A3B099118359590D884968AE5 |
| v63_d4b_archive_learning_test.gd | 0 | 427E787BDA3EB3E84E10DDD3423CF54CD3B1EB234487C50B6EB9309BBA211300 |
| v63_d4a_human_combat_test.gd | 0 | DF2E6B790C0EC2B787D3456489CF32AD5D5F45A43DE90FB943945FC1463369BB |
| v63_d4a_state_roundtrip_test.gd | 0 | B5A37A56A1FD4BFCAC133DD22D92D531BDF815347D52F43AE1AF15896E9945D0 |
| p2_5_combat_skill_test.gd | 0 | F582FF439983D7DC8690365119360A8D2EBDBBBBA210BBC491A338CAFF3EBCD4 |
| dv2_02_combat_stats_test.gd | 0 | D61FA52D2D0D833779F62E62E70F5CF1D58EE273E31171EA992A2E44BB192543 |
| p2_3_technique_test.gd | 0 | 39541A8D1377AFD45589D1233E6EA6A508C24B0D3E4FA62961FEC86A8611B046 |
| v63_d1_content_registry_test.gd | 0 | A404B3A6D3BD93E6C88CA9E8534AC54B5DF145BF3603AB570D2015BD5F8BA617 |
| v63_d2_sect_archive_test.gd | 0 | B4B7795FE275050FD6CD8BD208D2FD30996112B25A076E00DCBAA0B298B37863 |
| v63_d2_codex_drop_receipts_test.gd | 0 | 23CB9EEE73390A7751340F25B78DF6190905A2B51B07260E1E9117914E4F38C8 |
| v63_d3_learning_job_test.gd | 0 | 63B0BCDEB4CDEEB4CFBA9B3100C3D7989718F2B26532B7CA75B7122730329FB5 |
| p3_7b1_warehouse_test.gd | 0 | 3BF2591F4B2A49AF303F830598BB09A7A13FF5FB6D67F6F7A1DC9DB625249DA1 |
| save_service_async_roundtrip_test.gd | 0 | 69D6CEC243CB90909F9218BE21FE9855A9547D454271653932351BD40874C678 |
| safe_01_save_recovery_test.gd | 0 | 49F9B5C5C9B0AB1A8B06DD958EA25093CFDD6D596535D8EEAE84D0C3C4639CF0 |
| pve_save_return_reload_exactly_once_test.gd | 0 | 54B3814E705F9AE19BA33754905539F635112DC324978B19E2862A86BE0D3671 |
| pve_multicamp_combat_hp0_bridge_test.gd | 0 | 59FC99447EF7A83D050D78FB177B5F858151DC4912C2CCF74406C93D92FDE788 |

No exit-code failures occurred. These are headless runtime results; they are not GUI or owner visual acceptance.

## Next packet — D5 Immortal (authorized; proceed automatically)

Required: nine distinct branches, A/B successor paths, three Immortal bosses with stage/counter mechanics, and deterministic breakthrough study through the existing One Active Job/D3 study authority. Keep costs, durations, coefficients, and boss peak curves candidate-only unless approved. Reuse Combat V2, D2 archive and Warehouse, existing V63 records/save migration, and the current scheduler. Do not recolor Human abilities or create a second job/inventory authority.

Concrete D5 write allowlist:
- godot/data/combat/v63_immortal_combat_catalog.json (new)
- godot/data/combat/v63_learning_catalog.json
- godot/data/combat/v63_archive_catalog.json
- godot/src/simulation/archive/v63_sect_archive_system.gd
- godot/src/simulation/technique/v63_learning_system.gd
- godot/src/simulation/combat/v63_immortal_skill_combat_system.gd (new)
- godot/src/simulation/combat/v63_human_skill_combat_system.gd
- godot/src/simulation/combat/map_battle_v2.gd
- godot/tests/simulation/v63_d5_immortal_lineage_combat_test.gd (new)
- godot/tests/simulation/v63_d5_predictable_breakthrough_study_test.gd (new)
- godot/tests/simulation/v63_d4b_human_branches_bosses_test.gd
- godot/tests/simulation/v63_d4b_archive_learning_test.gd
- godot/tests/simulation/v63_d2_sect_archive_test.gd
- godot/tests/simulation/v63_d2_codex_drop_receipts_test.gd
- godot/tests/simulation/v63_d3_learning_job_test.gd
- godot/tests/simulation/v63_d4a_human_combat_test.gd
- godot/tests/simulation/v63_d4a_state_roundtrip_test.gd
- godot/tests/simulation/p2_5_combat_skill_test.gd
- godot/tests/simulation/dv2_02_combat_stats_test.gd
- godot/tests/simulation/p2_3_technique_test.gd
- godot/tests/simulation/p3_7b1_warehouse_test.gd
- godot/tests/simulation/save_service_async_roundtrip_test.gd
- godot/tests/simulation/safe_01_save_recovery_test.gd
- godot/tests/simulation/pve_save_return_reload_exactly_once_test.gd
- godot/tests/simulation/pve_multicamp_combat_hp0_bridge_test.gd
- docs/implementation/V65_COMBAT_COVERAGE_LEDGER_20261029.json
- docs/implementation/V65_D5_IMMORTAL_EVIDENCE_20261029.md (new)
- CURRENT_CHECKPOINT.md
- NEXT_CHAT_HANDOFF.md

Protected/excluded: D6 Divine/rare, D7 UI/VFX assets and presentation, D8 balance/performance release tuning, SaveService/schema, Injury120, Warehouse or scheduler authority changes, production economy, Source A originals/raw JX assets, main, PR #52, and merge. Rollback is default gate OFF: suppress new Immortal combat/learning effects while retaining saved knowledge and equipment records; no destructive downgrade or replacement of Human knowledge.

D5 gates: new A/B learning/combat and boss tests; D4-B branch/boss and archive tests; D2 archive/drop receipts; D3 study job; D4-A; P2.3/P2.5/CombatStats; Warehouse; save/recovery; PvE Save/Return/exactly-once and HP0 bridge, sequential on official Windows Godot 4.7.2. Record source-byte parity, exit codes, log hashes and real GUI if visible files change.
