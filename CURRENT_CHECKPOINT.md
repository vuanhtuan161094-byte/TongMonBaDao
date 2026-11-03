# TRI-03 G0 → G1 → G2 update — 2026-11-03

**Latest source commit:** `36532c39f294e1eb56d73d8ce0c0eb7cb68c5567` on `integration/tri-facility-a-b-playable-20261102`, parent `c136600f5579871d476e0feca2d78ea3c74e6b1f`. PR #67 remains Draft, open and unmerged. The completed evidence set is in [G0_G1_G2_EVIDENCE](docs/qa/TRI03_OWNER_FINAL_20261103/G0_G1_G2_EVIDENCE/EVIDENCE_INDEX.md).

- G0 current-source focused Save/Reload regressions: PASS. Full 14-case G0 rerun from a clean checkout of this source commit: PENDING; prior 14/14 is historical evidence only.
- G1 New Game paid Residence construction, actor-occupied placement rejection, real candidate recruitment/profile/assignment, Save, and second-process Reload: PASS in a windowed OpenGL harness at 1280×720. Input was harness-injected.
- G2 B1 UI contract/live callback tests and 1280×720 Godot captures: PASS. Source A 510052/510076/510111 hashes unchanged. Generated 16-icon UI atlas is explicitly original generated art, not Source A, and awaits owner approval.
- The Windows checkout remains local HEAD `27ed01cd8f377994e5e50bac9ede84e78e8895bd` with existing dirty/generated QA files preserved. Its 49 pinned source blobs match the source commit’s Git tree exactly; this is not a clean Git checkout at the source commit.
- The one-click launcher verified and opened the normal Godot window (PID 13624), left open for the owner. UI Computer Use did not enumerate that Godot window, so physical Windows mouse acceptance is PENDING. Android/touch and owner visual sign-off are also PENDING.
- Godot stderr contains a non-fatal Windows root-certificate-store warning. No parse errors were found; certificate checks were not disabled. No owner default save was touched.

Evidence: [matrix](docs/qa/TRI03_OWNER_FINAL_20261103/G0_G1_G2_EVIDENCE/TEST_MATRIX.csv), [filtered logs](docs/qa/TRI03_OWNER_FINAL_20261103/G0_G1_G2_EVIDENCE/RAW_LOGS_FILTERED.txt), [source and asset hashes](docs/qa/TRI03_OWNER_FINAL_20261103/G0_G1_G2_EVIDENCE/SOURCE_MANIFEST.json). This status supersedes the older checkpoint text below.

---

## FINAL DELIVERY — Windows playable RC status (2026-11-02)

**Status: BLOCKED for physical Windows delivery; automated focused QA PASS.** Live PR #67 HEAD was checked as `df6f55ee63d36c77e52b5d9eaf3c5743349b935a`; code/capture SHA tested by official Godot 4.7.2 is `8979dca68495a74ad272ca4c861034040bf385f7`. PR stays Draft and unmerged.

### Exact-SHA evidence

[Godot 4.7.2 O2 workflow 41402324227](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41402324227) completed SUCCESS: import/parse, O2, P3.7C1/Dẫn Tiên, B1 contract/live callbacks, independent two-process SaveService reload, DD092, Source A checks, four 1280×720 map/B1 captures and P3.6A. [Capture artifact](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41402324227/artifacts/13122450868). This was Ubuntu/Xvfb/llvmpipe, not Windows mouse acceptance.

### E: source and launcher

- Canonical `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao` is unchanged on `main` @ `5e6fdd966bdf710b71e2a1539bb712e44069a4bb`, with the existing seven untracked QA entries preserved. No user save was accessed.
- Exact-source folder `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao_PR67_QA` and launcher `E:\TongMonBaDaoWorkspace\01_Game\CHOI-GAME-THU.cmd` are **not present**. The official binary exists at `E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe` and reports `4.7.2.stable.official.ed1daf0bf`.
- Local Git does not contain commit `df6f55ee63d36c77e52b5d9eaf3c5743349b935a` (`git cat-file -e` failed). E: main is 259 commits behind PR base `970af33b` by ancestry; it cannot serve as a PR67 checkout.
- Fetch attempts: Git HTTPS/GCM returned `SEC_E_NO_CREDENTIALS`; disabling the helper for a read-only OpenSSL attempt could not prompt without a TTY; codeload and the signed Actions artifact URL both returned Windows `Authentication failed`; Node fetch also failed. The authorized GitHub connector provides metadata/text but not a local binary source archive.
- No launcher was created against a missing checkout, so it cannot be mistaken for a playable PR67 build.

### O6 / GP-01 / GP-02A locator assessment

Static review at PR #67 shows those older tests search for `GuidanceRecruitOrder` and `AcceptCandidate_<id>`. Current B1 controls are named `UseRecruitmentOrder` and `AcceptCandidate`; the live adapter connects those controls to canonical RecruitmentSystem callbacks. The exact-SHA O2 live integration gate passes real recruitment and independent reload. This supports a **legacy test-locator mismatch**, not evidence that recruitment gameplay is broken. No fake controls were added and no assertion was weakened. The complete O6/GP runs remain **PENDING** on Windows.

### Final gates

| Gate | Status |
|---|---|
| Exact-SHA Godot 4.7.2 automated focused suite and 4 captures | PASS |
| Windows PR67 QA checkout and one-click playable launcher | BLOCKED — source transfer/auth unavailable |
| Windows 1280×720 mouse playthrough of three facilities | PENDING USER |
| GUI Save → exit → launcher → Reload receipt verification | PENDING USER |
| Android/touch and owner visual acceptance | PENDING USER |

Safe workaround: restore official Git Credential Manager sign-in in the Windows session (no token/password in chat), then fetch this existing branch into the isolated QA folder. The canonical game directory and untracked files must remain untouched. Do not claim PLAYABLE RC until the launcher runs this exact PR source.

---

# TRI-03 CHECKPOINT — PR #67 (2026-11-02)

- Live code SHA tested: [`8979dca68495a74ad272ca4c861034040bf385f7`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/8979dca68495a74ad272ca4c861034040bf385f7); branch: `integration/tri-facility-a-b-playable-20261102`.
- Official Godot 4.7.2 O2 workflow: [41402324227 SUCCESS](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41402324227); actual four-screen map/B1 1280×720 capture artifact: [13122450868](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41402324227/artifacts/13122450868).
- PASS on exact SHA: project import/parse, O2, P3.7C1/Dẫn Tiên, B1 contract/live callbacks, independent two-process SaveService reload, DD092, Source A alpha/render capture, and P3.6A. See `docs/uiux/B1_TRIFACILITY_UI_QA_20261102.md` for markers and matrix.
- TRI-03 code delta: two B1/map management button minimum heights raised to 48 px. Source A 510052/510076/510111 hashes unchanged; Guidance facility art is separate from the neutral candidate portrait fallback.
- **PENDING USER:** physical Windows mouse playthrough and 1280×720 review, gameplay Save → Return → Reload through GUI, Android device/touch, owner visual sign-off. CI screenshots are automated Ubuntu/Xvfb Godot renders, not physical Windows acceptance.
- Windows exact-branch checkout was not produced: canonical E game folder remains untouched at main `5e6fdd966bdf710b71e2a1539bb712e44069a4bb` with existing untracked QA files; Git/GCM HTTPS authentication failed. No user save was accessed or modified. PR remains Draft; no merge.

---

# CURRENT CHECKPOINT — ONE GAME INTEGRATION

Updated 2026-10-31 (Asia/Saigon). This file supersedes the archived RC status below.

## Current candidate

- Integration branch: `integration/one-game-v65-20261030`
- Latest tested source commit: `79dab92ccc95a93b39dcb563fe06c93a9aa422da` (HS-09 plus selected Stage A, P3.2/DV2, D2/D3/D6, save and PvE regressions; evidence below). The Godot import snapshot and focused tests both use this source SHA.
- Runtime base remains PvE RC #52; PR #52, V6.5 source, and `main` are unchanged.
- Coordination: [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56); conflict authority: [Issue #54 matrix](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/54#issuecomment-6520099847).

- Latest HS-09 code/test commit: `79dab92ccc95a93b39dcb563fe06c93a9aa422da` (test-only signal-emission fix on top of HS-09 code `be37bca1725e9cc19e710dba3f3f796041ac78e7`). This runtime evidence is committed separately from this checkpoint; fetch the live branch SHA before further work.

## Latest checkpoint — HS-09 focused QA and New Game launch (2026-10-31)

**Tested source SHA:** `79dab92ccc95a93b39dcb563fe06c93a9aa422da`. **main:** `c0c1382f119599497b52d8ee8abd9e830a883f1e` unchanged. PR #52 and the V6.5 source branch were not edited.

The HS-09 implementation remains presentation-only. Commit `79dab92` fixes its focused regression test by emitting the LineEdit's `text_changed` signal after programmatically setting its value, then verifying both matching and nonmatching roster rows. It does not change simulation, save, combat, economy, feature-gate defaults or assets.

### Godot 4.7.2 import and focused tests

- Official Godot: `4.7.2.stable.official.ed1daf0bf`.
- Editor import: PASS, exit 0, 103 import steps, from a Git archive of exact source SHA `79dab92` at `E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030\qa_hs09_400baa\qa_import_79dab92\godot`. A root-certificate-store diagnostic was printed; import completed successfully. Log: `E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030\qa_hs09_400baa\godot_import_79dab92.log`.
- PASS, 14 focused tests: HS-09 profile/radar/read-only gate model; Female Stage A down and 3-direction contracts; DV2 profile and live P3.2 binding; D2 archive and exactly-once codex receipt; D3 study job and UI; SaveService async round-trip; SAFE-01 recovery; PvE save/return/reload; D6 divine-lineage combat and rare successors.
- The PvE test reports 50 checks, six party members, ten monsters, active-run reload and exactly-once HP0 receipt; it explicitly reports `loot=LOOT_PENDING`. The SAFE-01 test prints malformed-JSON diagnostics from its negative fixtures and ends with PASS.
- Stage A installer: PASS; 42 canonical PNGs restored, pack SHA-256 `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`. Both focused Stage A contract tests passed.
- Individual test logs (each records source SHA, full Godot command and exit code) are in `E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030\qa_hs09_400baa`.

The first HS-09 test run at parent `400baa11403720fb816075d65f3cb74e8f4ad505` failed because the test changed the LineEdit value without emitting its signal. The test-only repair was committed as `79dab92`; rerunning HS-09 and the listed regression set at that SHA passed.

### Real New Game launch and remaining GUI gate

The committed `tools/windows/run/Run-OneGame-NewGame.cmd` was run with official Godot GUI in a new isolated session profile, at 1280×720. It launched the real P3.2 project main scene and produced a canonical version-4 SaveService save. A read-only inspection observed six starting disciples, six standard buildings, two teams, 500 spirit stones and simulation tick 8. The save and profile are confined to `E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030\checkout_400baa\godot\outputs\one_game_newgame\sessions\12863_18370_19894_3279`; no user save was accessed. The GUI process (PID 8136) remains open.

**PENDING:** no gameplay input or 1280×720 screenshot was captured. Computer Use window capture timed out twice, including one reselect/retry. No PvE was entered through this GUI, and no manual in-game Save/Return/Reload journey has been performed. The headless save/PvE tests are regression evidence, not physical gameplay acceptance. Do not mark ONE GAME playable-accepted or V6.5 complete from this checkpoint.

## Integrated code

- R1 `70271184a7c3d1d1dfb374c0050424e263bf7a16`: 18 gated V6.5 catalogs/systems and D1 registry test.
- R2 `f4316ab0881c3a34c24c754aec922030be911971`: additive Sect Archive state, ResourceRegistry definitions, Combat V2 open-world HP0 codex receipts through PveMultiCamp and the canonical Warehouse.
- R3 `d0223f93cba330dcc562edb4ec48e953217f3334` plus picker correction `f18e4d6419f9ac43cf4a9fac119a415cb4f0c40d`: personal technique study, one active job, exactly-once study/mastery receipts, scheduler progression, additive save migration, BuildingSystem exclusion, and the existing P2.3 screen. The picker exposes the 12 Human/base D3 techniques; the 84-record catalog retains later-generation candidates for later phases.

R3 touched: `disciple_state.gd`, `sect_state.gd`, `simulation_state.gd`, `simulation_scheduler.gd`, `save_service.gd`, `building_system.gd`, `p2_3_techniques.gd`, `v63_learning_system.gd`, plus the D3 learning-job/UI tests. SaveService retains RC async atomic writes/backups and accepts prior CARE envelopes.

### R4 / D4-A — integrated and headless PASS

- Code commit: [`020531cb555cce949442ec4a257ca557255c9e4a`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/020531cb555cce949442ec4a257ca557255c9e4a), parent `411951483fceeebd585754fda2def0bc48514542`.
- Eight changed paths: MapBattleV2, HuntingPveRunV2, DiscipleState, SectState, SimulationState, the existing Human skill-combat kernel, and two D4-A tests. No catalog copy was needed; R1 already carries the approved Human catalog and kernel.
- One Human branch skill (Liệp Ảnh) is personally learned from an archived manual and equipped on six disciples. All six cast through Combat V2, deal real CombatStatsV2 damage, and preserve pending casts/loadouts in a snapshot. The Thiet Giap Son Vien Human Boss telegraphs and changes phase through its authored HP thresholds. The existing HuntingPveRunV2 path starts and restores the Boss fight.
- Legacy defaults remain gate-OFF and D4 state fields are omitted unless populated. Boss actions and phase transitions now require `v63_combat_enabled`, including after a gate-OFF restore.
- Rollback: disable the preview/gate or revert this package’s eight paths; do not delete new records from saves.

### R4 final focused evidence

- Windows Godot `4.7.2.stable.official.ed1daf0bf`; 16 sequential commands (editor import + 15 focused tests), all exit 0.
- D4-A combat and state round-trip, D3 learning job/UI, D2 archive, P3.7 Warehouse, SaveService async, SAFE-01 recovery, PvE Save/Return/Reload, HP0 receipt bridge, formation, C17 movement, Injury120, RuntimeClock and live-runtime integration all PASS.
- Commands and exit codes: `E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030\R4_D4A_FINAL_FOCUSED_20261031.tsv`, SHA-256 `E8AF94315976CF11C875CF7A3BD85883F10917EEF5190A56D0226B1F342F3704`.
- Log checksums: `R4_D4A_SHA256SUMS_20261031.txt`, SHA-256 `D747334C4DC363FBC87D0CD7D9818B3625ADDA4178EE7508F0C501290EB1AD5C`. Human combat log SHA-256 `90D70E1A4F69DDA08548178DD0D042DEBC8CE25D96B6586F58D0E7908AE57073`.
- Test `APPDATA` was redirected inside the isolated integration checkout; no real saves were read or written. Godot logged a Windows root-certificate-store error in each run; it did not affect imports/tests. SAFE-01 and live-runtime recovery logs contain expected malformed-JSON diagnostics.
- No presentation file changed in D4-A, so no GUI was opened; real combat HUD/Source A visual QA remains D7.

### R4 / D4-B — Human branch and Boss coverage integrated; headless PASS

- Coverage commit: [`efb26c1288575ab6a0477278f6d71d6e14830bd5`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/efb26c1288575ab6a0477278f6d71d6e14830bd5); this adds the two source-parity D4-B regression tests only. Runtime behavior is supplied by the approved R1 Human catalog/kernel and D4-A Combat V2/HuntingPveRun integration; no extra shared-runtime change was needed.
- `v63_d4b_human_branches_bosses_test.gd`: 9/9 manual-backed Human branch casts, 105 nodes, and 3/3 real Human Boss telegraph/release/phase behavior; includes basic/mobility and the twelve-slot branch loadout.
- `v63_d4b_archive_learning_test.gd`: 96 archived Human manuals and poison ownership/cap, dead-owner stop, guard/heal/cleanse/mark/AoE/mobility/passive effects.
- Godot 4.7.2 import and four focused D4-A/D4-B simulation tests all exited 0. PASS markers: `V63 D4-B HUMAN BRANCHES/BOSSES PASS`, `V63 D4-B ARCHIVE/EFFECTS PASS`, `V63 D4-A HUMAN COMBAT PASS`, and `V63 D4-A STATE ROUNDTRIP PASS`. Each run emitted the Windows root-certificate-store diagnostic; it did not affect import or tests. APPDATA was isolated under the integration checkout.
- Rollback: revert only the two added D4-B test paths. No SaveService, Warehouse, Injury120, scheduler, or six-person PvE authority changed.

### R5 / D5 — Immortal lineage and breakthrough coverage integrated; headless PASS

- Coverage commit: [`6f42f2a2fea2799427838c7c3d83bfb3bc6dc5bb`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/6f42f2a2fea2799427838c7c3d83bfb3bc6dc5bb); two source-parity D5 tests only. Runtime uses the R1 Immortal catalog/combat kernel, R3 one-active-job learning/save path and D4 Combat V2 adapter; no further shared-runtime patch was necessary.
- `v63_d5_immortal_lineage_combat_test.gd`: 18/18 manual-backed Immortal lineage casts, A/B family replacement, 3/3 Boss counter interruptions across snapshots, elemental reaction, and legacy combat gate OFF.
- `v63_d5_predictable_breakthrough_study_test.gd`: deterministic realm/body and mastery gates, Human active L7/ultimate L4 prerequisites, archived source, costs reserved once, One Active Job, exact-once completion receipt and save/load.
- Final Windows Godot 4.7.2 run: editor import + nine sequential focused tests (D5 ×2, D4-A ×2, D4-B ×2, D3 learning job, SaveService async roundtrip, PvE Save/Return/Reload) — 10/10 exit 0. APPDATA was isolated; no real save was read or written.
- Command/exit manifest: `E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030\R5_D5_FINAL_FOCUSED_20261031.tsv`, SHA-256 `D86FF0E687FB40C910236336E6BBD8C98407B9D444DD049F7C58680A46B1E920`. Log checksum manifest: `R5_D5_SHA256SUMS_20261031.txt`, SHA-256 `C165E7FB644FF4B05E7D8E3D6D5AB670D6D8CCC0DE97B946EF63F2D414953B41`. Each stdout contains the same Windows root-certificate-store diagnostic; stderr logs are empty and all tests pass.
- Rollback: revert only the two new D5 test paths. SaveService, Warehouse, scheduler authority, Injury120 and six-person PvE were not changed.

### R6 / D6 — Divine lineage, rare successors and Boss summons integrated; headless PASS

- Runtime/test commit: [`1ffa078099d86e893eec7434ecaa2934791e6e41`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/1ffa078099d86e893eec7434ecaa2934791e6e41), parent `7fa6cdc2bb2f8a75cebea238fa8ba95fd3e6019b`; five paths changed.
- MapBattleV2 now routes gated Divine fatal-save and committed-damage reflection through the existing Combat V2 hit settlement. Divine Boss phase changes add bounded summons (maximum four alive per Boss); summons inherit no V63 Boss AI and carry a no-reward marker excluded from the durable kill journal. They do not create Warehouse/loot receipts.
- MapBattleSnapshotV2 now accepts and validates owned V63 poison stacks, skill/effect/owner provenance, attack snapshot and bounded timers (30 target cap), allowing poison to resume without weakening existing burn/weaken validation.
- Focused evidence confirms 18/18 manual-backed Divine lineage casts and A/B replacement, 3/3 Boss counter interruptions, 18/18 rare ultimate/elective replacements, real releases, 30-stack poison snapshot/resume and diminishing factor, fatal-save cooldown, committed reflection, Blood Ma/Life healing boundaries, bounded no-reward summons, and deterministic Divine study.
- Windows Godot 4.7.2: import + 15 sequential focused regressions **16/16 exit 0**. Included D6 ×3, D5 ×2, D4-A/B ×4, D3 learning, SaveService async, PvE Save/Return/Reload, HP0 bridge, Injury120 and D2 codex receipt. APPDATA was isolated; no real saves were accessed.
- Exact manifest: `E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030\R6_D6_FINAL_FOCUSED_20261031.tsv`, SHA-256 `113DED5B83F4C768AC199E7BE00EFA0D7D0F9194C6332FF18726213CA17875E6`. Log checksum list `R6_D6_SHA256SUMS_20261031.txt`, SHA-256 `F52EF3A7446CD842B39FC71D7CEBE181776B3423369FE9D51E953600A73CFD11`. Godot’s root-certificate warning appears; Injury120 also emits its expected fail-closed malformed/legacy fixture diagnostic while T01–T23 all report PASS and exit 0.
- Rollback: revert the D6 runtime hook/snapshot changes and D6 tests as this package. Legacy feature gates remain OFF; no SaveService/Warehouse/scheduler/Injury120 logic changed.

## Godot 4.7.2 evidence

Latest exact-source QA is at `79dab92ccc95a93b39dcb563fe06c93a9aa422da`, using official Windows Godot 4.7.2 (`ed1daf0bf`). Import and test logs are under `E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030\qa_hs09_400baa`; each focused test log records source SHA, command and exit code.

Selected focused PASS set (14):
- HS-09 disciple profile / dual radar / feature-gate read model.
- Female Stage A down and 3-direction asset contracts.
- DV2 P3 disciple profile and live runtime binding.
- D2 Sect Archive, R2 exactly-once open-world codex receipt.
- D3 learning job (62 checks) and learning UI.
- SaveService async round-trip (10 checks), SAFE-01 recovery, and PvE Save/Return/Reload regression (50 checks).
- D6 divine-lineage combat and rare-successor combat.

The PvE automated regression explicitly leaves loot pending. These runs do not verify a player-controlled GUI journey. Earlier R3-R6 evidence and exact test details remain in the integrated-history sections below.

## Pending — not user-playable accepted

- Actual in-game input, readable GUI screenshot at 1280×720, New Game progression, PvE, and Save/Return/Reload in one active profile remain PENDING because the Computer Use capture timed out twice. No GUI action or screenshot was obtained.
- Existing focused tests pass at `79dab92`, but they do not replace manual gameplay acceptance. The automated PvE regression still reports `loot=LOOT_PENDING`; no loot/EXP reward was invented.
- Source A owner visual review, Android device QA, and whole-game FPS/performance acceptance remain PENDING.
- Do not claim FULL COMPLETE, release readiness or playable acceptance.

The isolated QA checkout contains generated Godot import metadata, test profiles and New Game save data. They were not staged. The canonical E: checkout, other workspaces, real saves, PR #52, V6.5 source branch and main were left unchanged.

## Archived RC checkpoint context

The section below records the previous RC-only handoff for history; its branch/status is not the current integration target.


**Cập nhật 27/10/2026 — Một dự án, một bản game chính thức.** Đọc file này trước; các checkpoint dài cũ là lịch sử, không phải nhiều phiên bản game song song.

## Phiên bản và quyền hạn

| Loại | Nhánh | Trạng thái |
| --- | --- | --- |
| **Stable chính thức** | `main` tại `29b5fba448b0178cb520a4ada44b375b4b934e31` | Bản đã được chấp nhận; **chưa chứa** PvE mới. Chưa được phép thay đổi. |
| **Bản phát triển tham chiếu** | `feature/pve-jx-continuous-world-20261026` tại `6b3fd181392c96c2386e5aa85950d2e993d67dda` | Nền tảng shared cho hai Codex; giữ nguyên trong kỳ nghiệm thu. |
| **Ứng viên tích hợp DUY NHẤT** | `integration/pve-unified-rc-20261027` | Tổng hợp **PR #51 core + PR #50 visual + tài liệu PR #49**, bảo toàn đúng file/byte và nhánh gốc. PR #52 vẫn Draft, không phải Stable. Focused QA mới nhất và exact HEAD được liên kết từ [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37) và PR #52. |
| Core hồi quy đã chạy | [PR #51](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/51) SHA `c217471bd3fbe88b95e6e7537b39dc07ae683e41` | Codex 1 **báo cáo 14/14 lệnh Godot 4.7.2 exit 0**; log chi tiết lưu tại E: Windows, chưa tái kiểm tra bằng engine trên RC. |
| Visual & VFX | [PR #50](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/50) SHA `59c6dea9041653026e02a55b0bc1f4e298976835` | SHA sheet/manifest Source A/JX static PASS; VFX Save/Resume focused test chạy trên RC; chuột thật/FPS vẫn PENDING. |
| Handoff/Docs | [PR #49](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/49) | Trạng thái được nén, AGENTS và kiến trúc không bị thay; file này cập nhật kết quả Codex 1/2 trên RC. |

**Không merge các PR nguồn #44–#51 riêng lẻ vào main.** Khi nghiệm thu đủ RC và được owner duyệt, một lần review/merge bản chốt vào `main`, tag SHA, đóng các PR được thay thế có dẫn nguồn và thu hồi nhánh sau khi Windows worktree đã nhả.

## Kết quả và gate nghiệm thu

| Gate | Tình trạng có bằng chứng |
| --- | --- |
| Canonical SaveService | **PASS trên PR #51**: lỗi `FAILED=1` trong DV2-03 do fixture thay `aptitude` đệ tử D7 mà không cập nhật quality. SaveService production không sửa, save hợp lệ và backup còn nguyên. Safe recovery và VFX Save/Resume focused checks chạy lại trên RC; không sửa SaveService. |
| PvE move C17 + 6 thành viên | **PASS trên PR #51**: hoàn tất subcell same-cell; sáu đích hợp lệ riêng, cùng connected region, thao tác nguyên tử; Godot focused QA PASS. |
| World 20 camps / autonomous | **PASS trên PR #51**: C01 → C02 sau 10 HP0 tự nhiên, có năm quái C01 respawn, Save/Reload. Kết quả 11 HP0 tổng, 5/6 đội sống tại lúc chụp, `LOOT_PENDING`, Warehouse không phát sinh receipt. |
| Injury120 | **PASS test độc lập** GP-02C1 tại mốc 119/120 tick online/offline trên PR #51. Bài P3.2 70s ở SHA đó có tám kills, **zone-hop và Injury120 chưa tới** trong fixture ngắn này. |
| VFX JX #158 | **PASS focused**: VFX Save/Resume regression chạy trên RC; static 10+17+8=35 frames, frame bounds, sheet hash/anchor và Source A tám clip/texture khớp E:. Binding Unity prefab/pivot và skill mapping vẫn **UNVERIFIED**. |
| Female Stage A / selected-only actor | Installer giữ exact package hash và dùng .NET SHA-256 fallback khi `Get-FileHash` không có; tracked transport và external ZIP fallback đều kiểm tra đủ 42 PNG. Live-map test chọn qua `_open_disciple`, đợi focus camera, xác nhận một actor được dựng trong viewport và roster khác vẫn virtual. Focused PASS trên current PR #52 head; exact log/SHA ở Issue #37. |
| Full regression trên RC | 22/22 PASS, exit 0 từng lượt; Godot 4.7.2.stable.official.ed1daf0bf. Gồm 14 core + 8 presentation, bao phủ clock/D7 Save A-B/C17/formation/20 camp/HP0/Injury120/Save-Return/Source A/VFX/camera/selected-only/UI. Matrix và exact SHA từng lượt nằm trên evidence branch và Issue #37. Đây là headless QA. |
| Hiệu năng headless P3.2 | Test 6v10 dùng roster 130, 50 shared-clock polls và mất 252,956 giây; kết thúc 73 giây mô phỏng/164 actions/10 kills/zone-hop PASS. Đây là dấu hiệu tải mô phỏng cần profiler; không suy ra FPS game thật. |
| GUI bình thường / điều khiển chuột / FPS | PENDING_GUI. Launcher mở P3.2 ở 1280x720; Win32 xác nhận cửa sổ và log runtime-ready, nhưng Sky không liệt kê được cửa sổ nên chưa có thao tác chuột, ảnh/video, Save/Return hoặc FPS logger OFF/ON. Không gọi GUI hoặc PLAYABLE PASS. |
| Android | Chưa có APK/thiết bị thật nghiệm thu. |
| Branch cleanup | Kiểm kê 166 nhánh trước đây, chưa xóa nhánh hay đóng PR nào; không xóa nhánh khi có worktree Codex hoặc dữ liệu độc nhất. |

## Quy tắc kỹ thuật vẫn khóa

- Godot **4.7.2**; landscape **1280×720**.
- Source A đã chốt phong cách và map sản xuất; không làm lại renderer.
- **Combat V2** duy nhất; One Active Job; Injury 0/1 và **120 scheduler ticks**; SaveService/SimulationRuntimeOwner/Warehouse canonical; không cấp phần thưởng đồ rơi giả.
- Các thiết kế công pháp/Boss/Forge/Economy V2 chưa nằm trong code hiện hành không tự trở thành runtime authority khi hợp nhánh.
- Hiện `main` và PvE feature không thay đổi. Draft RC không chứng minh visual acceptance hay performance.

## Bàn giao tiếp

1. Continue real GUI acceptance on the isolated New Game session only when a working capture/input channel is available; capture 1280×720, then exercise PvE and Save/Return/Reload using the same isolated profile.
2. Preserve the observed distinction: Godot import and focused headless regressions PASS at `79dab92`; GUI gameplay and screenshot are PENDING.
3. Keep main, PR #52, V6.5 source, canonical checkout and user saves unchanged.

Coordination: [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56).
