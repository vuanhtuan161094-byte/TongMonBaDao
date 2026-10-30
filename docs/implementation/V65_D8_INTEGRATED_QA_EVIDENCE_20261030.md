# V6.5 D8 Integrated QA Evidence — 2026-10-30

Repository: `vuanhtuan161094-byte/TongMonBaDao`  
Branch: `feature/v63-v64-full-combat-20261029`  
D8 code/test commit: `9f7cebd3aaa11ef53660497dfe5fc6bab30cb378` (parent `02018db95dc022aba16ba4eee4376bf64b73b0e4`)  
Stable main: `c0c1382f119599497b52d8ee8abd9e830a883f1e` (unchanged)  
PR #52: Draft/open/unmerged; last audited head `2a99ed505c85a17f6d25f91891560ca51fa02d88`.  
Overall release: **INCOMPLETE**.

## D8 code/test scope

The D8 code commit contains only the approved QA/test paths:
- `godot/tests/presentation/v63_d8_performance_qa_contract_test.gd`
- `godot/tests/simulation/dv2_03_realm_body_progress_test.gd` (one model-version-aware expected-stat call correction)
- `godot/tests/simulation/v63_d8_endgame_progression_test.gd`
- `godot/tests/simulation/v63_d8_multiseed_camp_battle_test.gd`

Remote tree/blob parity was checked against all four published files. No production runtime, save schema, economy, scheduler, Warehouse, or art path changed in D8.

## Official Godot 4.7.2 import

**PASS**, exit 0. Windows console executable:  
`E:/TongMonBaDaoWorkspace/01_Game/TMB_V65_D4A_20261029/Godot_v4.7.2-stable_win64_console.exe`  
Log: `E:/TongMonBaDaoWorkspace/QA_Evidence/V65_D8_20261030/00_import_final.log`  
SHA-256: `4607CF35E6D6B82797968FE151305A9C35D23E7884FAE37D36A6CB249F87DB2`.

The log includes a nonfatal certificate-store warning and editor-settings save denial under the Windows AppData location; process exit was 0.

## D8 affected regression matrix — 16/16 PASS

Tests ran sequentially using the official Godot 4.7.2 headless runner. Logs are in `E:/TongMonBaDaoWorkspace/QA_Evidence/V65_D8_20261030/`; SHA-256 values below are for each final per-test log.

| Test | Log SHA-256 |
|---|---|
| `p2_1_cultivation_test` | `8814089ED865857EDDF18002E28CCEEE8281495D752558B8A8657F3A046A6A19` |
| `dv2_03_realm_body_progress_test` | `17474DD24A8C9DAD4B9713A0094EB611EE07D9BC49D054905423251DF94A40AF` |
| `dv2_03_body_xp_source_test` | `9EE3FD3648790115E197E92D400A1582208554689C5816D5BFF1F78937C8EDA0` |
| `dv2_03_f1_body_gate_manifest_test` | `5FDA589AD650264254143E6220C1843B6141E8578F6FA5B249F5E4E4660229CF` |
| `dv2_03_f2_body_gate_transaction_test` | `40012BD09ED3A4B4983AC74213BE92F6985064F9B5D1D70F6365C551595955C0` |
| `dv2_03_f3_body_material_earned_claim_test` | `B01E14ABB369CEAAD148B181BDF58F4103064D85B99A398F50216045106C2159` |
| `dv2_03_f6_real_earned_body_gate_integration_test` | `12C629530523972A9DC5E801A25DAFB2066570D8FDA454B6BE4E322AE1B49249` |
| `pve_multi_camp_population_v1_test` | `490FA190BD50AF7C5A0D06E729C094ED6E5BF8E239B873B3D12184389468853B` |
| `pve_multicamp_combat_hp0_bridge_test` | `DA866B04B9351B4D51E550ABBB65503295B2A16F9285A63ED8C2FED3015AA5FC` |
| `save_service_async_roundtrip_test` | `053737622A52D3E705E7776519F18A557F8588CD0F92AC8AC8400D75B1CB09B2` |
| `safe_01_save_recovery_test` | `2E5462661AF1331167FEB5E4CCD76D614DC7F829B2161467B9AC10CC706E3F79` |
| `pve_save_return_reload_exactly_once_test` | `6A46BDB34EAD522E68B0E9D9B05CF420C596E28BDF9614CAEE82FF1B39FACD06` |
| `endgame_fixture_contract_test` | `B3E4C996DC772774A517582E62A7F1105365058F54E56F8A86D17A4B89F62899` |
| `v63_d8_endgame_progression_test` | `C3C1FA42C86672681775B69B44541844E54074688DE7F5BFC2E94AA12AF4BB2A` |
| `v63_d8_multiseed_camp_battle_test` | `EA2EFBC72223B30FB0B1FEA6A41C848DCFACE30735CABE271E5AEDD7747D7E50` |
| `v63_d8_performance_qa_contract_test` | `A62E86E4A89B9A60E9E685C65DAA349463DB22D41ABEB3D554135A686A96FB92` |

Final matrix JSON: `E:/TongMonBaDaoWorkspace/QA_Evidence/V65_D8_20261030/regression_results_final.json`; SHA-256 `3C435EC5E1A2BF50159E5BB870DF2BE336394D3966492850FEFD0DE14C917C75`.

The multiseed test exercises direct Combat V2 HP0/receipt/no-reward/respawn traces for three seeds × three team fixtures × twenty camps (six disciples per fixture). It does not establish autonomous pathing, live frame-rate, or a full twenty-camp GUI playthrough.

## Cross-phase safety checks — 4/4 PASS

| Test | Log SHA-256 |
|---|---|
| `v63_d3_learning_job_test` (One Active Job) | `80F9E663EA5A89FCBD247BDDD4711EC02D31330CA39A83B22E1B5291CE67BF22` |
| `v63_d2_codex_drop_receipts_test` (exact once) | `E35DFCC8BC740131E5EA27E242E7DB73CE82EDD4788A3A42DE573308C6C24183` |
| `v63_d6_divine_lineage_combat_test` | `1E47271A9E44CFFC7A00669579376AD87A1E939E2376F1D118A832E4FF61FCB0` |
| `v63_d7_runtime_boss_encounter_test` | `9AC01F6C4D771D2DE8FE890A96F9357D10AF5491958C94739D748AFA027820EF` |

Supplement matrix: `E:/TongMonBaDaoWorkspace/QA_Evidence/V65_D8_20261030/extra_results.json`; SHA-256 `2E439B30D5465EB94E9A6221F6118FEDD858E8B465259EDFE7E3E77241702491`. Combined D8 affected and cross-phase set: **20/20 PASS**.

During validation, save/recovery checks first used the default Windows AppData sandbox and failed to write user data. Final runs used isolated `APPDATA=E:/TongMonBaDaoWorkspace/QA_Evidence/V65_D8_20261030/userdata` and passed. A progression expectation was updated to pass the existing D7 foundation-model flag; no production behavior changed. Test-fixture and runner filename-format issues were also corrected, and final sequential logs/matrix were regenerated. The initial failed runs remain part of the audit trail and are not counted as passes.

## Gates still pending or blocked

- **Gameplay GUI / owner visual acceptance — PENDING.** A later Computer Use retest launched the official Godot 4.7.2 Project Manager and selected its returned window, but screenshot-backed state capture timed out twice (FrameArrived/channel timeout). No gameplay input, screenshot, branch/Boss visual matrix, or owner approval is claimed.
- **Live performance/FPS/RAM and Android device evidence — PENDING.** The contract test checks the existing probe/launcher fields only; it is not a runtime measurement.
- **Endgame playable progression — BLOCKED by authored content availability.** The cultivation cost table contains 300 coordinates, but Body gate content is explicitly unavailable beyond realms 1–6; realms 7–30 return `content_unavailable`. No production recipes, material sources, or numeric progression values were invented or bypassed.
- **Overall V6.5 — INCOMPLETE.** Headless test coverage does not satisfy the requested game-playable GUI/owner QA.

## D8 test findings and handling

The single test-file correction fixes an old expected-stat assertion so it supplies the same `foundation_model_version >= FoundationSystem.MODEL_D7` argument as the established derivation API. Other initial failures were environment/fixture/test-runner issues described above and passed after isolated reruns. No runtime path needed a code fix.

## Protected state and next work

Stable `main` was not changed. PR #52 remains Draft/open/unmerged; do not merge it. The original owner E: checkout and unrelated pre-existing scratch/import files were preserved. No files were staged wholesale, cleaned, or deleted. Continue only after GUI access is restored and content/owner gates are resolved; maintain Source A provenance and the existing single Warehouse/scheduler, Injury120, SaveService/schema and One Active Job invariants.


## GUI retry after D8 documentation

On 2026-10-30, Computer Use launched the official Windows Godot 4.7.2 executable and returned a single Project Manager window. Both screenshot-backed `get_window_state` attempts timed out at the frame channel (first `FrameArrived`, retry generic window-capture timeout). Per the Computer Use recovery limit, no further capture retry or alternative Windows automation was used. No project was opened and no gameplay input/screenshot was obtained. GUI and owner visual acceptance remain **PENDING**.


---

## 30/10/2026 — Scripted live P3.2 GUI capture (baseline, not current-head acceptance)

The official Windows Godot 4.7.2 console executable ran the existing pve_multicamp_p3_2_live_integration_test.gd in a normal GUI window (headless=false) at 1280×720. It rendered the real P3.2 Source A continuous world and captured the actual root viewport. This is a scripted GUI run: the test uses UI signals and viewport-routed mouse events; it is not a physical mouse playthrough or owner review.

- Test process exit: 0. Godot: 4.7.2.stable.official.ed1daf0bf; OpenGL 3.3 Compatibility; Intel Iris Plus Graphics.
- Log: E:/TongMonBaDaoWorkspace/QA_Evidence/V65_D8_20261030/GUI/pve_multicamp_live_gui.log; SHA-256 B3C312AE3D669C01B8C05135762C73777676771A0019AE82B55C4C060D60DA53.
- Real viewport screenshot: E:/TongMonBaDaoWorkspace/QA_Evidence/V65_D8_20261030/GUI/pve_multicamp_live_1280x720.png; 1280×720, SHA-256 D61FAC6E805E3D648D4255B5C98AB4D12D759F50A83A43005D03910EC28F5710.
- The rendered run had 130 loaded disciples, a selected team of six versus ten live monsters, 18 Combat V2 actions at capture, Source A map assets, pan/zoom input, six-member movement formation, and active SaveService save/load. The shared clock then advanced four frames without a fabricated reward.
- Log ends with PVE SOURCE A CONTINUOUS WORLD P3.2 INTEGRATION PASS; zone_hop=NOT_REACHED, injury120=NOT_REACHED, loot=LOOT_PENDING. The visible HUD showed V6.5 OFF; this run did not prove a Liệp Ảnh/V6.5 cast.

Provenance limit: test execution came from the existing dirty E: scratch at local Git HEAD 91cfc7e9c4975d6f03834355f38d5d6db8308b3c. At the time of capture the published code/test baseline was 9f7cebd3aaa11ef53660497dfe5fc6bab30cb378. The D7 11-file allowlist and relevant D7 dependencies were checked for content parity after normalizing Windows CRLF and trailing blank lines; this was not a clean full-tree checkout. Therefore this is baseline GUI capture evidence only, not proof for the new D8 preview-resume patch now at branch code/test SHA 63b5eaef9eae17ccc0fb71a1fa8b7524f50fc64f or current docs HEAD dd15641068d4a251296956d30de681472bd572e7.

D7 full visual matrix (nine branches and nine Bosses), actual physical input, Save/Return GUI review, measured performance, Android and owner visual acceptance remain PENDING. Overall V6.5 stays INCOMPLETE.