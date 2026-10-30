## Latest D7 GUI matrix — 2026-10-30 (current)

Feature runtime/test source: 59f3903f37dc0260cf07059bf3bd24e0973168c6. Evidence was captured in a normal Windows Godot 4.7.2 GUI window at 1280×720 against the real P3.2 Combat V2 Boss encounter. The harness drives existing UI signals and captures the root viewport; it is scripted GUI evidence, not physical-mouse or owner acceptance.

**PASS — scripted visual sample:** 9/9 branch skill cues and 9/9 distinct Bosses have paired screenshot/log records. Every log reports cast=true, positive_hit=true, telegraph=true, and V65 BOSS GUI CAPTURE PASS. Each screenshot is 1280×720.

| Branch / skill sample | Boss | Screenshot | Screenshot SHA-256 | GUI log | Log SHA-256 |
|---|---|---|---|---|---|
| bow_liep_anh | boss_thiet_giap | bow_liep_anh__boss_thiet_giap.png | 2F16AD51768F3FFDBC55A660B2AFDA91E61190FD52CA675AB7C52887C3B2031E | same-name .log | 3F48B90EDD5F7B11929D7D48F17F8812296271C58DFC6DF48D18FEF29B1E917F |
| bow_linh_tien | boss_xich_viem | bow_linh_tien__boss_xich_viem.png | B901BAD9AEEA3E83564D759863EDC508A23C6EA50C781657B0B2A575D94AA5FE | same-name .log | CD292083AE5A275083965AF80ECD8828D60B7150B617E4F9177E6E5EA20DDB00 |
| bow_thien_vu | boss_bach_doc | bow_thien_vu__boss_bach_doc.png | C840EB6E89400CD964074DA01A1AF20761E8F25327E7B491D61F634984FD4CC4 | same-name .log | A8C8A1FAB97252F0360E9BCB1B9FB86DEEEC692BC4BEC84F0D36A4DD515062D2 |
| fist_ba_quyen | boss_immortal_loi_nguc | fist_ba_quyen__boss_immortal_loi_nguc.png | 2B9265D622E9D2EE87547FD84DB69B22052C62000923552E18A56A53BA00C2B3 | same-name .log | 0C5F1CD86FC891EFF4A25F94A34CFAE85AD36ABAFD53393CDAF6ED5BF5DF43A9 |
| fist_huyet_quyen | boss_immortal_u_minh | fist_huyet_quyen__boss_immortal_u_minh.png | 15CE5BF2B4D46AF2F84478515D30F6F29F51B51D982A04A7D4B33AD409076602 | same-name .log | 23917513F05139F818465DC163FA7A93F89220540184DDE94DC5FD694082535E |
| fist_kim_cang | boss_immortal_han_nguyet | fist_kim_cang__boss_immortal_han_nguyet.png | 76017B14B73101302A38B5C75F3CAB8707AA72B5940501B679ADBD0FB4B4AD31 | same-name .log | 6A262CE2FB43C62123E3D5B0826DEA60C363D229095A92C9527736D64445D242 |
| poison_co_doc | boss_divine_bat_diet | poison_co_doc__boss_divine_bat_diet.png | C35E311875A4B02A9BBDE959D35ABE254FC5391E6001304DB1050CF8948FF0B8 | same-name .log | C46169ED4F14598B98D70F3F3E193CA2747A6BE55960987AA6B1EB60C1D80C0B |
| poison_doc_cham | boss_divine_cuu_tieu | poison_doc_cham__boss_divine_cuu_tieu.png | 4CBD43A785BEA27D641F52F983F5FCA45703625526923C0E4E3FB79BDD19DA2C | same-name .log | 6B9718F5192FD1F02C9ACCC193BA841DDA791542238C8E821A31FCD48D8E5CFB |
| poison_duoc_doc | boss_divine_thai_so | poison_duoc_doc__boss_divine_thai_so.png | 343066FEF89983B22260EECCBE4FB0826D4E177A941604C39754DFCEE2898DA9 | same-name .log | 1CFEC8E8887C2FA8CB78D019B808A68EF2AE0AEA6A5998D691E3CCC33401EBD3 |

Evidence directory: E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D7_GUI_MATRIX_20261030\published_59f3903_114435. The exact 9 PNG and 9 log copies were SHA-verified against the C: originals under the active Codex workspace. Screenshot review confirms the right-side Boss/party/skill panel is legible and the telegraph is visible; the center still crowds actors and damage numbers.

**Pending:** D6 rare-skill GUI coverage, physical mouse and Save/Return interaction, and owner visual review. The capture is actual rendered gameplay in a native GUI window, but scripted UI events do not prove manual interaction. D7 implementation/capture is not owner-accepted. Overall V6.5 remains INCOMPLETE.

## Previous D7 records
Earlier partial matrices and their source SHAs remain below as historical evidence; this 9/9 table supersedes earlier 1/9 or 8/9 D7 capture counts.

---

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
