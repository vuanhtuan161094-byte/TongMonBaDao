# Current D8 refresh-reuse implementation and integrated QA — 2026-10-30

**Code/test SHA:** 23e5d0ba812f4b39dc6c8c5afc47864929c645aa, parent 5d9337d06aa9c931b844133f8add890c756a9b8c. Official Godot 4.7.2: 4.7.2.stable.official.ed1daf0bf.
The owner-approved patch is limited to:
- godot/src/presentation/p3_2_landscape_sect.gd
- godot/src/presentation/p3/v63_combat_hud_v1.gd
- godot/tests/presentation/v63_d8_p3_refresh_reuse_test.gd
- godot/tests/presentation/v63_d8_p3_refresh_reuse_test.gd.uid

## Runtime and regression status

- Windows Godot 4.7.2 import: PASS, exit 0; final import log SHA-256 B500736E0177F44888D24EF078EA3450E557923411BA5DFA0C0EE1D1292B9DDA.
- Focused refresh/HUD/P3.2 suite: 3/3 exit 0; manifest SHA-256 1928E0773542A32A6A2BC635442703DB9E81FDBC2E44E3991B1897A6B9471D1E. New refresh reuse test log SHA-256 948DF38343FCE20F53D1F9BD45BF96ECD03D7F30DC184A832087F1913F626641.
- D8 affected D7/D8/Save/PvE suite: 25/25 PASS, all exit 0; manifest SHA-256 7D3E2AA3C4B2F7DF00621173C8D4537C61A6476B2425CB7D7D86518D245DE590.
- D6 complete regression: 20/20 PASS, sequential; manifest SHA-256 84CFEDE5292EC65C56F6E7052FBA72B27AA96811F0FE2B7487431B7441521FF7.
- The manifest source field describes tested content as 59f3903 baseline plus approved D8 presentation patch; it does not embed a commit SHA. Exact P3.2/HUD blob parity between the tested isolated snapshot and published code commit was checked. Two earlier process attempts exited -1; fresh isolated APPDATA runs passed and only final runs are counted.
- The existing D7 combat HUD test exits 0 but retains fixture teardown resource-leak diagnostics. The fixture was not changed in this packet.

## D8 GUI / paired profiler

Normal Windows Godot GUI, 1280×720, OpenGL 3.3 Compatibility on Intel Iris Plus; loaded QA save has 130 disciples, and the Combat V2 party has six actors. Logger OFF and ON were run separately for 20 seconds; each log confirms game actions advancing 0→149 and process exit 0.

| Measurement | Before OFF | Before ON | After OFF | After ON |
|---|---:|---:|---:|---:|
| Frames | 1135 | 1133 | 1172 | 1172 |
| P50 / P95 (ms) | 16.66 / 17.50 | 16.65 / 17.49 | 16.66 / 17.32 | 16.66 / 17.30 |
| P99 / max (ms) | 68.94 / 94.88 | 68.48 / 120.10 | 30.98 / 95.35 | 27.99 / 100.83 |
| 1%-low FPS | 12.44 | 12.02 | 13.70 | 14.00 |
| Process P95 (ms) | 136.99 | 112.21 | 109.83 | 104.32 |
| Physics P95 (ms) | 0.19 | 0.09 | 0.16 | 0.13 |
| Static / video memory peak (MB) | 189.7 / 267.6 | 189.5 / 269.6 | 189.4 / 267.6 | 189.8 / 267.6 |

### Post-D8 scripted Boss recapture — FAILED, not counted (2026-10-30)

A follow-up attempt used the disposable copy `E:/TongMonBaDaoWorkspace\\01_Game\\TMB_V65_D8_SYNC_20261030` and `godot/tests/presentation/v65_d7_visual_matrix_capture_test.gd`. It exited 1 at production Boss-pick selection: `production Boss picker could not select boss_thiet_giap`. No screenshot was produced. Log: `E:/TongMonBaDaoWorkspace\\QA_Evidence\\V65_D8_REFRESH_FIX_20261030\\d7_boss_gui_after_d8\\bow_liep_anh_boss_thiet_giap.log`; SHA-256 `ECD69B6C9FA27048799BB4D2EEEAEB8E9841ACB937F94DA40BDBC2C2DC81CDAB`. The tested copy has no Git metadata, so its exact source parity is unverified; this result is **not** attributed to the published branch and is not counted as a product regression or GUI PASS. The earlier D7 9/9 branch + 9/9 Boss captures remain baseline scripted evidence; a post-D8 Boss capture remains PENDING.

## Additional D8 trace/environment audit — 2026-10-30

The OFF and ON raw metrics logs show recurring PVE-phase frame-gap spikes at roughly two-second intervals after the first sample: approximately 69–101 ms, with 373 nodes and 374 draw calls. Most repeated spike rows report Godot process time around 17–20 ms and physics below 0.15 ms. The first sample has an unaligned/aggregate process-time value, so this trace does not establish a reliable CPU/GPU/source attribution. Keep performance acceptance REVIEW PENDING; no new source change is justified by this evidence alone.

Android availability check: PowerShell could not find adb on PATH. No Android device QA was run; device performance remains PENDING.

The hot HUD update maximum fell from roughly 33–51 ms to 5.57 ms, while visual-row update fell from roughly 31–45 ms to 0.098 ms. P99 improved and both 1%-low values rose, but maximum whole-frame spikes remain near 100 ms. Therefore the optimization is measured as improved and **D8 performance acceptance remains REVIEW PENDING**; no target or owner signoff was inferred.

After OFF log/metrics SHA-256: AC39830029C5678A75F150314FAA7E118DDDE034E84D4849045D2103B4C5271B / 127BAA90D7A7C869A7E622E6CA46BA926AE83CD8E4FBB269838B9E2F276DF6E3.
After ON log/metrics SHA-256: 71D96B868A24A6D9F6CB1A2355C5212C87FE458652DBF94CE1E7642B7D8DE1B4 / DB6F088267E3CAB7D1E09B03C99AC1881E733CC411F41CDEFDA170B929C6855E.

Screenshot: E:/TongMonBaDaoWorkspace/QA_Evidence/V65_D8_REFRESH_FIX_20261030/gui_after_refresh_fix_on/p3_2_pve_1280x720.png; SHA-256 2AEFED2A9D6AF88E8F006C190B105D5E42875F362056E13AB9B2B9A9CE3E5AC8. It shows the actual game viewport with the Source A world and all six HUD rows. At capture, V6.5 is OFF and the event count is zero; this image proves layout/readability only, not a skill cast. Scripted UI testing is not physical mouse play. Manual Save/Return and owner review remain PENDING. Central actor/damage-number crowding in the D7 combat matrix remains a separate visible issue.

The D7 branch/Boss matrix remains 9/9 branch samples and 9/9 Boss captures as documented in V65_D7_UI_VFX_EVIDENCE_20261030.md. D6 rare-skill GUI remains PENDING; Android device remains PENDING; Body realms 7–30 remain BLOCKED by missing authored progression sources. V6.5 overall remains INCOMPLETE.

QA output root: E:/TongMonBaDaoWorkspace/QA_Evidence/V65_D8_REFRESH_FIX_20261030. The original dirty E: checkout was preserved; no test logs, screenshots, or save files were committed.

---

## Historical D8 profile-guided presentation optimization preflight — approval recorded 2026-10-30

Base feature HEAD: 02a964e088414798d3dc18cac3d0e20c91af3457. Runtime evidence source: 59f3903f37dc0260cf07059bf3bd24e0973168c6. Main remains c0c1382f119599497b52d8ee8abd9e830a883f1e; PR #52 remains Draft/open/unmerged at 2a99ed505c85a17f6d25f91891560ca51fa02d88.

Profiler OFF/ON runs reproduce long-tail frames (P99 68.48–68.94 ms, maximum 94.88–120.10 ms; 1%-low 12.02–12.44 FPS). The P3.2 instrumentation attributes recurring cost to visual-row and HUD refresh. Source inspection found two repeatable allocation/IO patterns on that path: _b3_hunt_visual_rows constructs ResourceRegistry.new() for each Thanh Lang actor, while ResourceRegistry._init reads and parses the codex catalog; V63CombatHudV1._render queue-frees and rebuilds the six party buttons on each authority refresh. These observations motivate a narrow optimization; they do not yet prove how much each contributes to the measured spikes.

Owner approved this exact CODE allowlist in the current session on 2026-10-30. Runtime edits remain unstarted until this exact-path preflight commit is published:
- godot/src/presentation/p3_2_landscape_sect.gd — retain/reuse one scene-owned ResourceRegistry for live visual-row name lookup; preserve the same labels and Source A keys.
- godot/src/presentation/p3/v63_combat_hud_v1.gd — reuse the existing six party-row controls and update their text/selection/visibility in place; preserve HP, injury, Boss, skill, telegraph and event content.
- godot/tests/presentation/v63_d8_p3_refresh_reuse_test.gd (new) and its generated .gd.uid — focused assertions for stable row nodes, updated HP/injury/selection, and identical visual-row mapping across repeated refreshes.

Additional exact paths for evidence only: docs/implementation/V65_D8_INTEGRATED_QA_EVIDENCE_20261030.md; docs/implementation/V65_COMBAT_COVERAGE_LEDGER_20261029.json; CURRENT_CHECKPOINT.md; NEXT_CHAT_HANDOFF.md.

Verification after approval: official Godot 4.7.2 import; the new focused test; existing D7 HUD and P3.2 integration tests; current 24-test affected matrix; complete 20-test D6 matrix; repeat both 20-second normal-GUI logger OFF/ON captures on the same seed and compare P50/P95/P99/1%-low, process/physics and memory. Keep the existing 9/9 D7 screenshots/logs as unchanged visual baseline.

Rollback: revert only the two presentation source paths and the new focused test/UID. No simulation, resource authority, economy, SaveService/schema, Injury120, One Active Job, Warehouse, scheduler, assets, maps, main, PR #52, or saved data changes. Do not claim performance PASS without post-change measurements and review.

---

# Current D6–D8 verification — 2026-10-30

**Exact branch context:** feature/v63-v64-full-combat-20261029 was at 53d6134ec7ecad5f10f29c2617869c6717958d4a before this evidence commit. Runtime and regression source SHA is 59f3903f37dc0260cf07059bf3bd24e0973168c6; commits after that runtime SHA through 53d add D8 QA/preflight documentation and the GUI capture test only. Stable main remains c0c1382f119599497b52d8ee8abd9e830a883f1e. PR #52 remains Draft/open/unmerged at 2a99ed505c85a17f6d25f91891560ca51fa02d88, based on feature/pve-jx-continuous-world-20261026.

## Godot and regression status

- Official Windows Godot 4.7.2.stable.official.ed1daf0bf import: PASS, exit 0. Import-log SHA-256: B728DE0C23F24D9AA31BC7608B177D7CA13857D7C3ACA862A08506D00675123B.
- Full D6-specific matrix: 20/20 sequential scripts PASS on runtime source 59f3903. Result manifest: E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D8_PERF_20261030\d6_regression_59f3903\d6_results_59f3903.json; SHA-256 6AE3CC0C708D76BD1E0D59875C03BD036E5F6B1059884905AA2D7FED66DDB93D.
- Current affected/cross-phase D7/D8/Save/PvE matrix: 24/24 sequential scripts PASS on the same runtime source. Manifest: E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D8_PERF_20261030\regression_59f3903\regression_results_59f3903.json; SHA-256 EA6DF0603FD27F4759FF1C8AD5538399664EDFFA48F9943766F830535374D739.
- D6 20/20 and D8/D7 24/24 are overlapping suites and must not be added into a single 44-test claim. Both exact result manifests contain individual exits/log hashes. The D6 matrix includes Divine/rare lineage, Immortal/Human combat, D2/D3, P2.3/P2.5, Warehouse, SaveService/SAFE-01, save-return exact-once and HP0 bridge checks.
- Current D8 GUI test is godot/tests/presentation/v63_d8_performance_runtime_capture_test.gd (SHA-256 54CD3B166B36B0F34A5CC62A89F6E6770009250F9184B1E2DD34B99A3AB305E) with generated UID sidecar SHA-256 8595C3D6888CFCF6025C642E80A91E1808196AF7179CD71419FB03C60F1E9CED. Its code is QA-only; no production runtime changed.

## D7 real GUI visual matrix

See the current D7 evidence at V65_D7_UI_VFX_EVIDENCE_20261030.md for all 9 branch/Boss screenshot and log hashes. A native Windows GUI rendered the actual P3.2 Source A scene and Combat V2; automated UI signals made captures repeatable. The UI panel is readable but central actors/damage numbers remain crowded. Physical mouse and owner visual acceptance are PENDING.

## D8 Windows GUI performance capture

Official Windows Godot 4.7.2, OpenGL 3.3 Compatibility, Intel Iris Plus. The test loaded the existing 130-disciple QA save through SaveService, entered a real six-member C01 Combat V2 encounter in the Source A P3.2 scene, warmed the map for five seconds, and measured 20 seconds of live combat with the existing passive profiler. Logger OFF and ON were run separately. Both final runs exited 0 and recorded 149 combat actions. These are real native-GUI runtime captures driven by automated UI signals, not physical-mouse testing.

| Mode | Frames | FPS measured | P50 / P95 / P99 | Max frame | 1%-low | Process P95 | Physics P95 | Static / video memory peak |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Logger OFF | 1135 | 56.58 | 16.66 / 17.50 / 68.94 ms | 94.88 ms | 12.44 FPS | 136.99 ms | 0.19 ms | 189.7 / 267.6 MB |
| Logger ON | 1133 | 56.51 | 16.65 / 17.49 / 68.48 ms | 120.10 ms | 12.02 FPS | 112.21 ms | 0.09 ms | 189.5 / 269.6 MB |

Logger OFF: E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D8_PERF_20261030\GUI\logger_off_clean\ — log SHA-256 FBEDE14FB3F363D95BECEC8478F058127E90C4A96F12A9F530281036B9FA588F; metrics SHA-256 80C8D863FE3FCA0ABE90EB2D41B77192AE74C4E816598C0054A1E2ECD0E4E0B4.

Logger ON: E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D8_PERF_20261030\GUI\logger_on_clean\ — log SHA-256 C1D9685347EA5B0D13EC13D9A2C6B48EAFB9CAF4E57F2887BF0EA4CD6DCDCD38; metrics SHA-256 49A884AACACA6562D5D88E6D5321889D8075B88AAD766755CA02578F0DA38D74.

Both root viewport screenshots are p3_2_pve_1280x720.png, SHA-256 A020EFD9CD7443948A717D4E54AC08D4E522A8555B91A26AAC61445612C79B40. The captures show a live fight. Tail frame spikes remain in both runs; the 1%-low near 12 FPS is not presented as an acceptance PASS because the contract provides no numeric threshold and no owner signoff. The paired run demonstrates that toggling the existing logger does not remove the observed tail. Treat D8 performance as MEASURED / REVIEW PENDING.

Initial harness-only attempts that had an output collision or teardown access violation are excluded; the refined unique-directory runs above are the two successful final runs. They did not change production behavior.

## Current gates

- D6 runtime regression PASS; D6 rare-ultimate GUI visual coverage PENDING.
- D7 scripted actual-GUI branch/Boss matrix PASS 9/9; D7 physical interaction and owner acceptance PENDING.
- D8 runtime/cross-phase regressions PASS 24/24; native-GUI OFF/ON data captured; performance acceptance PENDING measured tail spikes.
- Android physical-device test PENDING because no device environment is available.
- Body realms 7–30 BLOCKED: authored gate content is unavailable beyond 1–6; do not invent recipes, materials, or costs.
- Overall V6.5 INCOMPLETE. Main unchanged; PR #52 remains Draft/unmerged. Preserve Injury120, One Active Job, SaveService/schema, canonical Warehouse/scheduler, feature-gate defaults, and the dirty canonical E: worktree.

## Historical D8 records
Earlier D8 results remain below with their exact older source SHAs. Do not combine their counts or hashes with the current 59f3903 matrices.

---

# Current D8 integrated regression update — 2026-10-30

Tested source content: feature SHA `5e1fc3043abe4fcd402ce226be7bb944d053cd0d` plus the two published D7 presentation corrections described in [D7 evidence](V65_D7_UI_VFX_EVIDENCE_20261030.md). Official Windows Godot 4.7.2 import passed, and the complete affected/cross-phase matrix passed **34/34 sequential scripts**, exit 0. The D8-specific 20 checks (endgame fixtures, multiseed camp and battle, performance QA contract, preview-gate resume, One Active Job, D2 receipts, D6/D7 regressions) are included.

- Import log SHA-256: `B3A23744AE960A77A913A9C6E9CDE0BC3C4FA59C42FE75D566BA1ACF958B60F2`.
- Full results: `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D7D8_20261030_boss_fixes\regression_results.json`; SHA-256 `3C7E4982B423CF3033C3E51AB08430B3F32F09B789F9C1687E6F330DA68D1032`. It records 34/34 tests plus the successful import command, with per-test logs/hashes.
- A real 1280×720 P3.2 Boss GUI frame now demonstrates the current Boss picker, live Combat V2 Boss, six members, telegraph, and Liệp Ảnh cast/hit: screenshot SHA-256 `59508487945305293EFD9360C1272EE194ABDCD11F2FB46700BAA281246BF07E`; log SHA-256 `D3FFB81E971B156EF2E6DE0E97808503895FDB37CFEEA81716FF7AA63933A0C4`. This is one scripted gameplay capture, not a full 20-camp/endgame session or owner review.

**Still pending:** measured FPS/RAM, Android device QA, all nine branch/all nine Boss visual matrix, physical input and owner review. **Still blocked:** authored Body gates beyond realms 1–6 return `content_unavailable`; do not invent progression/cost content. Overall release remains **INCOMPLETE**; no main/PR #52 merge.

---

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