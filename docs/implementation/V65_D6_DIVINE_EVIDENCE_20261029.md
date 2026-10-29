# V6.5 D6 Divine combat evidence — 2026-10-30

## Status

D6 source/test checkpoint: [`eff8446b571f945c14799c48ecb8a1519e076e30`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/eff8446b571f945c14799c48ecb8a1519e076e30) on `feature/v63-v64-full-combat-20261029`. Status: **HEADLESS_PASS, 21/21** official Windows Godot 4.7.2 commands. Stable main remains `c0c1382f119599497b52d8ee8abd9e830a883f1e`. PR #52 was rechecked at `8a2860903a6b9e241d88ca13cbf9b64f37cdcfd0` (Draft/open/unmerged); no PR files were imported or modified.

### Runtime implemented

- Nine Divine branches with mutually exclusive A/B descendants, three Divine study stages, stage III rare eligibility, 18 rare ultimate replacements and 18 elective rare passive replacement definitions. Catalog contains 240 skills: 204 standard, 18 rare ultimates, 18 rare passives. New combat gate remains OFF by default; coefficients and costs remain candidate-only.
- Shared Human dispatcher routes Divine learning/equip/release through Combat V2. A real cast now awards bounded per-node mastery from a unique encounter/actor/sequence receipt; receipt replay is rejected and mastery records live on the disciple. The existing D3 One Active Job authority continues to settle timed stage study and exact-once costs.
- Divine boss definitions cover Cửu Tiêu Kiếp Long, Bất Diệt Huyết Ma Tôn and Thái Sơ Pháp Tắc Đế; staged rules, counter windows, interrupt handling, 70%/35% phase transitions and capped Combat V2 summons are implemented.
- D6 status handling includes owner-keyed poison stacks (max 5 per source, 30 per target), monotonic owner ordinals, symmetric diminishing stack ticks and snapshot provenance validation; Blood Ma sealing/anti-heal, Blood Life bounded healing/lifesteal, lethal-save cooldown and non-recursive reflection are implemented.
- SaveService and snapshot version/schema are unchanged. Injury120, six-member PvE, Warehouse, scheduler, legacy P2/P2.3 and exactly-once receipt authorities remain as before.

### Focused evidence coverage limits

- D6 lineage test performed 18/18 manual-backed Divine active_01 A/B releases, A/B replacement, attached innate and actual Combat V2 damage, plus all 3 boss spawn/telegraph/counter interruption/snapshot/phase/summon-cap sentinels and elemental reaction.
- Rare test performed 18/18 actual rare ultimate releases and tested all 18 rare passive replacements for learn/equip-slot replacement. Passive effect safety was exercised through targeted sentinel cases; this does not mean each of the 18 passive effects was independently characterized.
- The catalog definition/validator count of 240 must not be presented as 240 individually battle-tested effects. Full branch/boss live visual coverage remains D7. D6 boss full release-to-kill/reward settlement was not claimed by this matrix.
- D6 changed no presentation, scene or asset files. Actual GUI screenshots/owner visual acceptance remain **PENDING**; Android, performance, endgame balance and full integrated gameplay remain **PENDING**. Overall V6.5 is **INCOMPLETE**.
- SAFE-01 intentionally logs malformed-candidate parse diagnostics while proving fallback recovery. Its row is PASS only with exit 0, the expected SAFE-01 pass marker and the known exact parse-diagnostic prefix; no other `ERROR:` or `SCRIPT ERROR` was ignored.

## Windows commands and matrix

Godot: `4.7.2.stable.official.ed1daf0bf`; root: `E:\TongMonBaDaoWorkspace\01_Game\TMB_V65_D4A_20261029\godot`. Import command: `E:\Godot_v4.7.2-stable_win64_console.exe --headless --path <root> --editor --import --quit`. Each script command: `E:\Godot_v4.7.2-stable_win64_console.exe --headless --path <root> --script res://tests/simulation/<name>.gd`. Runner was sequential; no source edits occurred during the final matrix. Each local log is under `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D6_20261030_final\`.

| Script | Exit | Seconds | Log SHA-256 |
|---|---:|---:|---|
| `import` | 0 | 12.047 | `4160ec0be32c94dbfffaa21b1b63fb14560acfd2c45bfb0f360760b7b4560595` |
| `v63_d6_divine_lineage_combat_test` | 0 | 24.282 | `6256418506f74f0d1530ec9ce2e26a746a5f2702bc8e7876a9ff5d001368ecbb` |
| `v63_d6_rare_successors_test` | 0 | 26.172 | `7029c89063be01506b5e6b7be82e512cf58a063fd6a6e62f88ddac6702f74b3f` |
| `v63_d5_immortal_lineage_combat_test` | 0 | 22.859 | `899c0d8d3f16e31d91c107ae97eb634cc884282844ca272b61a69f2b61f83aa3` |
| `v63_d5_predictable_breakthrough_study_test` | 0 | 4.625 | `e5a7eca6173e5f77d0e11ce4fa1f41d36292bd3b5e974c7b95675754a2dce79d` |
| `v63_d4b_human_branches_bosses_test` | 0 | 13.703 | `1eb521a92d372ef16e59cd20c09b7d6b30a26c4a3b099118359590d884968ae5` |
| `v63_d4b_archive_learning_test` | 0 | 9.828 | `427e787bda3eb3e84e10ddd3423cf54cd3b1eb234487c50b6eb9309bba211300` |
| `v63_d2_sect_archive_test` | 0 | 4.391 | `e7a2bd07f2137f3c6f7ee84b8ebfae32918f641582f55948ae5ada621f7a801b` |
| `v63_d2_codex_drop_receipts_test` | 0 | 5.578 | `23cb9eee73390a7751340f25b78df6190905a2b51b07260e1e9117914e4f38c8` |
| `v63_d3_learning_job_test` | 0 | 6.907 | `49e7945760a32e288194acb3746f61420289decf49ddec253e753ce250b9a9a5` |
| `v63_d4a_human_combat_test` | 0 | 30.14 | `df2e6b790c0ec2b787d3456489cf32ad5d5f45a43de90fb943945fc1463369bb` |
| `v63_d4a_state_roundtrip_test` | 0 | 2.375 | `b5a37a56a1fd4bfcac133dd22d92d531bdf815347d52f43ae1af15896e9945d0` |
| `v63_d1_content_registry_test` | 0 | 0.422 | `a404b3a6d3bd93e6c88ca9e8534ac54b5df145bf3603ab570d2015bd5f8ba617` |
| `p2_5_combat_skill_test` | 0 | 6.078 | `f582ff439983d7dc8690365119360a8d2ebdbbbba210bbc491a338caff3ebcd4` |
| `dv2_02_combat_stats_test` | 0 | 2.5 | `d61fa52d2d0d833779f62e62e70f5cf1d58ee273e31171ea992a2e44bb192543` |
| `p2_3_technique_test` | 0 | 6.625 | `39541a8d1377afd45589d1233e6ea6a508c24b0d3e4fa62961fec86a8611b046` |
| `p3_7b1_warehouse_test` | 0 | 8.766 | `3bf2591f4b2a49af303f830598bb09a7a13ff5fb6d67f6f7a1dc9db625249da1` |
| `save_service_async_roundtrip_test` | 0 | 2.469 | `69d6cec243cb90909f9218be21fe9855a9547d454271653932351bd40874c678` |
| `safe_01_save_recovery_test` | 0 | 2.375 | `63615ac5dbe87e28ff23013a711a1da95b3bbf99cbffd1813b8d70406800eb8e` |
| `pve_save_return_reload_exactly_once_test` | 0 | 13.203 | `54b3814e705f9ae19ba33754905539f635112dc324978b19e2862a86be0d3671` |
| `pve_multicamp_combat_hp0_bridge_test` | 0 | 3.437 | `59fc99447ef7a83d050d78fb177b5f858151dc4912c2ccf74406c93d92fde788` |

## Exact source parity

These 15 tested paths were published using their canonical Git blob IDs. Each blob ID below matched the local source bytes before the source commit was created; the final commit tree contains these exact blobs. Generated import sidecars and unrelated dirty files were not included.

| Path | Git blob |
|---|---|
| `godot/data/combat/v63_divine_combat_catalog.json` | `78ebe72157fb725744649aa899761b51dcffa7cc` |
| `godot/data/combat/v63_archive_catalog.json` | `eb22de8f4f9097e262b019930acd38e2e740949e` |
| `godot/data/combat/v63_learning_catalog.json` | `05857ea0207df3323e2c922b98bc0b574b212ac2` |
| `godot/src/simulation/archive/v63_sect_archive_system.gd` | `6aef8627ac38478e033402eb61311ccc318879b1` |
| `godot/src/simulation/technique/v63_learning_system.gd` | `035a23fa9628b677a84597a95923a000763575e9` |
| `godot/src/simulation/combat/v63_feature_gates.gd` | `bb35382b1df3f61d63df60fc868e6248efc2552c` |
| `godot/src/simulation/combat/v63_human_skill_combat_system.gd` | `46024a557651804b6c58eda9ec313b41e23e2f12` |
| `godot/src/simulation/combat/v63_divine_skill_combat_system.gd` | `ff9840e84870099c097264fc073d0be8179ee65c` |
| `godot/src/simulation/combat/map_battle_v2.gd` | `3b07fc6c5e1ec395594ab20d008344a4b213bb6d` |
| `godot/src/simulation/combat/map_battle_snapshot_v2.gd` | `bbc7d670a8c99e4680e1d40e167662ee6829bedb` |
| `godot/tests/simulation/v63_d6_divine_lineage_combat_test.gd` | `234082ecd46b03e705239c97f253eae0ab9ec914` |
| `godot/tests/simulation/v63_d6_rare_successors_test.gd` | `3cc36ea6fc4210e415e39f66e81e7ca14397f354` |
| `godot/tests/simulation/v63_d2_sect_archive_test.gd` | `979c5a58b7838befb9b8da2eaa85a5a7b621aced` |
| `godot/tests/simulation/v63_d3_learning_job_test.gd` | `00d9c478d1ec2672cccc4ca1b6765534377d51ce` |
| `godot/tests/simulation/v63_d4b_archive_learning_test.gd` | `2ed5515feff7e1d8aa565cb61cbe2804c25cfdd7` |

## Next work

Proceed to D7 in the same feature branch and existing `godot/scenes/p3/p3_2_landscape_sect.tscn` main surface. Build actual 6-party/selected-disciple skill UI, boss HP/phase/telegraph/counter cues, Tàng Kinh Các access from map, and original independently authored skill VFX tied to real combat event stages. Use the existing Source A presentation manifests without editing raw/source originals; JX/JXQY remain reference-only. Run focused presentation tests and regressions, launch the official Godot 4.7.2 GUI at 1280×720 and record real screenshots/input results. Do not mark visual acceptance before owner review.
