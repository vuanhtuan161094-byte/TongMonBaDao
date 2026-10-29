# V6.5 D4-A Human Combat Evidence — 2026-10-29

## Status

- Implementation and headless runtime: **PASS** at source SHA 0af2af261e62960ffb4669c8d9d81feb153dd387.
- Official Godot 4.7.2 headless editor import: **PASS**, exit 0.
- Focused and affected cumulative regressions: **14/14 PASS**, sequential, exit 0 each.
- Actual Windows gameplay GUI, Android, performance profile, owner visual acceptance: **PENDING**. No screenshot or playable acceptance is claimed; D4-A changed no art, VFX assets, scene, or UI.
- Overall V6.5 D4–D8: **INCOMPLETE**.

## Branch and source

Repository vuanhtuan161094-byte/TongMonBaDao, branch feature/v63-v64-full-combat-20261029. Stable main remains c0c1382f119599497b52d8ee8abd9e830a883f1e. PR #52 remains Draft/open at audited head f7c33d9c3baba3267a17021718b44f87acd62ef6; it was not merged or modified.

The D4-A source was first published in d744537069f5c6ae2108a7334321eff6339ec6aa, then five CRLF blobs were corrected to canonical LF in 0af2af261e62960ffb4669c8d9d81feb153dd387. The final 10 source/catalog/test blobs match the normalized local bytes used for the final tests. No force push.

D4-A commits: six guarded adapters/state files plus:
- godot/data/combat/v63_human_combat_catalog.json
- godot/src/simulation/combat/v63_human_skill_combat_system.gd
- godot/tests/simulation/v63_d4a_human_combat_test.gd
- godot/tests/simulation/v63_d4a_state_roundtrip_test.gd

## Implemented

A default-OFF human_skill_combat gate and per-save opt-in add personal Liệp Ảnh skill Xuyên Tâm Tiễn. Six actors can learn/equip/auto-cast from archived D2 codex state; damage resolves through MapBattleV2 and CombatStatsV2. Thiết Giáp Sơn Viên is one Human-stage boss with actual cast/telegraph/release actions and one-time 70%/35% phase transitions. Actor-local pending cast state survives MapBattle snapshot and HuntingPveRunV2 save/restore.

D4-A balance coefficients are candidate only. SaveService/schema, legacy P2 skill records, Injury120, One Active Job, canonical Warehouse, scheduler, production/economy, and assets were not changed.

## Godot 4.7.2 Windows logs

Engine: E:\Godot_v4.7.2-stable_win64_console.exe  
Version: 4.7.2.stable.official.ed1daf0bf  
Logs: E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D4A_20261029_final

Import command: Godot --headless --editor --import --path godot; exit 0.  
Import stdout SHA-256: 926AC09AEA38B4621E2F34EB127B578ECD25AB8949E09E05B92D77885643628C.  
Import stderr SHA-256: E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855 (empty).

Each script used Godot --headless --path godot --script res://tests/simulation/<script>, run sequentially:

| Script | Exit | stdout SHA-256 |
|---|---:|---|
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
| safe_01_save_recovery_test.gd | 0 | 46ECBA9A5C7FFBE6B3463D536004F6109174F69A56274515CE78381EE6B71480 |
| pve_save_return_reload_exactly_once_test.gd | 0 | 54B3814E705F9AE19BA33754905539F635112DC324978B19E2862A86BE0D3671 |
| pve_multicamp_combat_hp0_bridge_test.gd | 0 | 59FC99447EF7A83D050D78FB177B5F858151DC4912C2CCF74406C93D92FDE788 |

All stderr logs are empty except SAFE-01's expected malformed-save negative-fixture diagnostics: SHA-256 B639778FA07B00E9FC1034D5C72D629868C18F5A2020DB8BCC87B98C10004DCA. SAFE-01 printed PASS and exited 0.

D4-A human test output confirms six casts, real CombatStatsV2 damage, Boss phase/telegraph, snapshot resume, and HuntingPveRunV2 adapter. The state test confirms legacy empty defaults and additive personal knowledge/loadout. PvE save-return reports the separate GP-02C1 Injury120 authority; this packet did not modify it.

## GUI and next packet

Issue #54 requests a live P3.2 capture. I attempted the Windows Computer Use flow; launching the existing Godot executable returned “Computer Use app approval timed out”, and the helper remained busy after reset. No screenshot was produced, and no test/mock image is presented as gameplay. GUI remains PENDING; the D4-A Issue checkbox is not complete until the required capture is obtained.

Proceed automatically on the same feature branch with D4-B. Implement all nine Human branch families and three Human bosses, including archived-manual learning, owner-attributed bounded effects, phase/telegraph behavior, and complete slot coverage. Exact proposed D4-B allowlist and test gates are recorded at the top of CURRENT_CHECKPOINT.md and NEXT_CHAT_HANDOFF.md. Keep default gates OFF and all production authorities protected.