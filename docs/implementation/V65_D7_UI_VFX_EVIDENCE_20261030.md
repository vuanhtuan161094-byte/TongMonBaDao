# Current D7 regression and Boss GUI evidence — 2026-10-30

Feature source commit: [`5e1fc3043abe4fcd402ce226be7bb944d053cd0d`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/5e1fc3043abe4fcd402ce226be7bb944d053cd0d), parent `c035bd8a8b4856b47213988ed4c3c56ded830820`. Stable main remains `c0c1382f119599497b52d8ee8abd9e830a883f1e`. PR #52 remains Draft/open/unmerged at `2a99ed505c85a17f6d25f91891560ca51fa02d88`.

## Published corrections

- `godot/src/presentation/p3/b3_care_combat_v5_presenter.gd`: replaced the untyped ternary assignment to `Array[String]` in `attach_session()` with explicit typed branches. This fixes the runtime error raised when attaching the real Boss battle.
- `godot/src/presentation/p3_2_landscape_sect.gd`: the production Boss picker now passes the existing selected map level through canonical `HuntingMapV2.choose_level()` before `HuntingPveRunV2.begin()`, and reports authority rejection in its picker feedback. This enables the PvE authority using the user-selected level.
- No simulation combat math, SaveService/schema, scheduler, Warehouse, Injury120, raw art, or feature-gate default changed. The gates remain OFF by default.

## Official Windows Godot 4.7.2 regressions

- Import: **PASS**, exit 0; log `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D7D8_20261030_boss_fixes\00_import.log`, SHA-256 `B3A23744AE960A77A913A9C6E9CDE0BC3C4FA59C42FE75D566BA1ACF958B60F2`.
- Sequential affected matrix: **34/34 PASS**, all exit 0; 35 successful commands including import. D6's complete 20-script regression set, D8 checks, save/warehouse/PvE safety, and six D7 presentation/runtime checks are included. Matrix JSON SHA-256 `3C7E4982B423CF3033C3E51AB08430B3F32F09B789F9C1687E6F330DA68D1032` at `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D7D8_20261030_boss_fixes\regression_results.json`.
- Six D7 reruns (per-test log hashes are also in the matrix):

| Test | Result | Log SHA-256 |
|---|---|---|
| `p3_2_live_modular_map_test.gd` | PASS | `18538F108E511067309DEB046190C1E086BE65304834C8B537BC13DEE5797A85` |
| `p3_2_map_camera_test.gd` | PASS | `08CB56D8EAE5950E5E8990C9A5DC961ED993093BADA8E71CB2392605C323B24C` |
| `v63_d7_combat_hud_test.gd` | PASS | `9E89C155127328164D7683FF89F109A02E0D34227ED5A520AFE5386A5FE03433` |
| `v63_d7_archive_entry_test.gd` | PASS | `59FF5308649D05C5C0BF139BD94D12C63073251F098174755F705A9EE91BD28D` |
| `v63_d7_runtime_boss_encounter_test.gd` | PASS | `9AC01F6C4D771D2DE8FE890A96F9357D10AF5491958C94739D748AFA027820EF` |
| `pve_multicamp_p3_2_live_integration_test.gd` | PASS | `94E7DE373DD67EE8EE0698C9E9CB631EB4DFB538D2EF81DE25ADA472A15BE616` |

The local E: QA snapshot is not a Git worktree. The two changed source files were compared to the published branch content after normalizing Windows line endings; the D6/D8 runtime source was unchanged from the tested branch baseline. Earlier failed GUI attempt logs remain in the same evidence directory and are not counted as PASS.

## Actual P3.2 Boss GUI capture

Official Godot `4.7.2.stable.official.ed1daf0bf`, normal Windows GUI window, OpenGL 3.3 Compatibility / Intel Iris Plus Graphics, 1280×720. The harness opened the real P3.2 scene and production Boss picker; the isolated fixture left `v2_pve_enabled=false` until the production picker selected the current map through `HuntingMapV2.choose_level()`. Six party members entered the Combat V2 Boss encounter. The live screenshot shows the Boss HUD, Phase 1 telegraph, party cards, Liệp Ảnh personal skill and cooldown; log receipts confirm Liệp Ảnh cast and positive hit.

- Screenshot: `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D7_VISUAL_MATRIX_20261030\GUI\boss_human_thiet_giap_live12.png`, 1280×720, SHA-256 `59508487945305293EFD9360C1272EE194ABDCD11F2FB46700BAA281246BF07E`.
- GUI log: `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D7_VISUAL_MATRIX_20261030\boss_human_thiet_giap_live12.log`, process exit 0, SHA-256 `D3FFB81E971B156EF2E6DE0E97808503895FDB37CFEEA81716FF7AA63933A0C4`. The record is scripted UI interaction and viewport capture, not a physical mouse run or owner review.
- Coverage is partial: **1/9 Bosses** and **1/9 branch skill samples** (Liệp Ảnh); the other eight Boss and branch captures remain pending. The screenshot still has combat number/nameplate overlap around the Boss; presentation refinement and owner visual acceptance remain pending.

D7 implementation and selected regressions pass. **D7 acceptance remains PENDING** until all required visual captures, physical input/Save-Return review and owner approval are completed. Overall V6.5 remains INCOMPLETE.

---

# V6.5 D7 UI/VFX Evidence — 2026-10-30

## Source and branch

- Repository: `vuanhtuan161094-byte/TongMonBaDao`
- Branch: `feature/v63-v64-full-combat-20261029`
- D7 code/test commit: `878b279b4ac536c1c28a36e4ed0e87251f43c2c9` (parent `990432cee290be738a03e499b9d99ecffa89b5db`)
- Stable main: `c0c1382f119599497b52d8ee8abd9e830a883f1e` (unchanged)
- PR #52: live head `2a99ed505c85a17f6d25f91891560ca51fa02d88`, Draft/open/unmerged.

## D7 change allowlist

1. `godot/data/presentation/v63_combat_vfx_manifest.json` (new)
2. `godot/src/presentation/p2_3_techniques.gd`
3. `godot/src/presentation/p3/v63_combat_hud_v1.gd` (new)
4. `godot/src/presentation/p3/v63_original_combat_vfx_v1.gd` (new)
5. `godot/src/presentation/p3_2_landscape_sect.gd`
6. `godot/src/simulation/combat/hunting_pve_run_v2.gd`
7. `godot/src/simulation/core/simulation_runtime_clock_v2.gd`
8. `godot/tests/presentation/pve_multicamp_p3_2_live_integration_test.gd`
9. `godot/tests/presentation/v63_d7_archive_entry_test.gd` (new)
10. `godot/tests/presentation/v63_d7_combat_hud_test.gd` (new)
11. `godot/tests/simulation/v63_d7_runtime_boss_encounter_test.gd` (new)

No raw art, SaveService/schema, Warehouse authority, Injury120, main or PR #52 changes.

## Results

**Official engine:** Windows Godot `4.7.2.stable.official.ed1daf0bf` import PASS, exit 0. Log `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D7_20261030_final\00_import_zoom_fix.log`, SHA-256 `66FA2901248A6A92F33FDDB24865FA3A408500ECA4035C1EC9E421DFBED54BC4`. The run emitted a nonfatal system certificate-store warning and restricted editor-settings messages; process exit was 0.

**D6 regression:** the 20 D6 focused/affected legacy scripts all PASS, sequential, in `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D7_20261030_regression2\results.json`. Each per-test log hash is recorded there and in the D6 evidence. The D6 matrix proves only its selected representative checks; it does not prove exhaustive effects for every catalog node.

**D7 targeted checks after corrections:** all six passed, exit 0:
- `p3_2_live_modular_map_test.gd` — SHA-256 `3EF0B0C291FEA0474C1F0DCE61F1B9042140B6A47F420E6CA21F7E01E9721B75`
- `p3_2_map_camera_test.gd` — `AD03E323A7B440EE71000CEE587DF98B25373E9B14673C847DD3318A08AED656`
- `v63_d7_combat_hud_test.gd` — `AFB8E851EE34C425FD97F86169240F4CF5F3F2EAFF3CB49BDE32CA1AF21B8FC9`
- `v63_d7_archive_entry_test.gd` — `8F8848DC3FFA665D96B1BF51E79FC26735F71197E7A4E4B58E467A167EEA9F53`
- `v63_d7_runtime_boss_encounter_test.gd` — `1CA3120AE16C428DD25B48B2152D09BAEABAB573E983B520F3EB5B869ADA0629`
- `pve_multicamp_p3_2_live_integration_test.gd` — SHA-256 `72042C41A684BDCEC6F65A26DD38BE47E409F36759EF2D6CC6E3F56A0672E339`, including six-person movement slots, camera zoom controls, active save/load and shared-clock progression. Log: `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D7_20261030_final\01_p3_2_live_integration.log`.

The earlier D7 combined run was **24/26**, not clean: integration asserted the obsolete status widget, and modular-map was missing Stage A source assets. The UI assertion/layout was corrected and an exact Stage A package (42 PNG; SHA-256 `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`) was installed in scratch; the affected tests were rerun. The corrected zoom controls are on the upper-left during live-map hunting to avoid the right-side combat HUD; existing layout offsets are restored outside that mode. A single final cumulative 26-script rerun was not completed, so report the 20 D6 checks and six D7 targeted checks separately.

## GUI status and limitations

**PENDING.** Godot ran in a native Windows window, but Computer Use approval timed out and the Godot window was not returned for input/capture. No actual gameplay screenshot or video is attached; no visual claim for all nine branches/Bosses, no owner visual acceptance and no FULL PLAYABLE/FULL COMPLETE claim.

D7 establishes tested UI/runtime building blocks only. The contract's real 1280×720 screenshots, manual interaction, Save/Return GUI path and owner review remain open. The P3.2 headless integration used synthetic fixture setup and is not a GUI substitute.

## PR #52 overlap matrix

- `p3_2_landscape_sect.gd`: PR-only profiler/freeze/culling versus D7 HUD/Boss/Archive/zoom changes; layout needs visual revalidation.
- `hunting_pve_run_v2.gd`: PR-only respawn/corpse cleanup/checkpoint/performance versus D7 preview forwarding.
- `simulation_runtime_clock_v2.gd`: PR-only frame-budget/active-session changes versus D7 Boss shared-clock and preview-gate forwarding.
- Integration test: PR performance-probe/ring-capture edits are separate from D7 HUD/zoom assertions; rerun after any integration.
- SaveService was untouched by D7. No blind merge or PR mutation.

## D8 next packet

D8 initial exact allowlist is in the new top section of `CURRENT_CHECKPOINT.md`: three QA tests (progression, multiseed camps, performance contract), evidence, coverage ledger and handoff/checkpoint. Start by inspecting current progression gates and existing QA helpers. Do not add balance values or bypass unavailable body content. D7 GUI remains PENDING while D8 proceeds.
