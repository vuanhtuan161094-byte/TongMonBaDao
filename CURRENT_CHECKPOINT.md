# CURRENT CHECKPOINT — ONE GAME INTEGRATION

Updated 2026-10-31 (Asia/Saigon). This file supersedes the archived RC status below.

## Current candidate

- Integration branch: `integration/one-game-v65-20261030`
- Latest tested runtime commit: `1ffa078099d86e893eec7434ecaa2934791e6e41` (R6 / D6); earlier R4/R5 coverage and runtime commits are listed below.
- Runtime base remains PvE RC #52; PR #52, V6.5 source, and `main` are unchanged.
- Coordination: [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56); conflict authority: [Issue #54 matrix](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/54#issuecomment-6520099847).

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

Isolated checkout: `E:\TongMonBaDaoWorkspace\01_Game\TMB_ONE_GAME_V65_20261030`  
Evidence directory: `E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030`

- R3 headless editor import — exit 0, stderr empty. On the R3 picker-fix tree, stdout SHA-256 `CE9CCEA1BE4DA31DE12806EDC40917C7AB4589E52CEFF90F044BD3FE2BAC2EBF`.
- `res://tests/simulation/v63_d1_content_registry_test.gd` — PASS, 105 families / 531 nodes / 18 rare variants / 9 Boss records (R1 log `R1_d1_content_registry_test.stdout.log`).
- `res://tests/simulation/v63_d2_sect_archive_test.gd` — PASS, 159 codices / 150 archivable manuals / Warehouse and save round-trip (R3 log SHA `E7A2BD07F2137F3C6F7EE84B8EBFAE32918F641582F55948AE5ADA621F7A801B`).
- `res://tests/simulation/one_game_r2_open_world_codex_receipt_test.gd` — PASS, retry-safe HP0 to one Warehouse receipt and exact-once save/load (SHA `8D63F9D825F8B95ECDA530ED1C9EF3DBA7B61665DDB5F0F8F887640DE74F92F2`).
- `res://tests/simulation/v63_d3_learning_job_test.gd` — PASS, 62 checks (job reservation, cancellation/completion/mastery receipts, migration, gate-off pause, save/load and 1+2 loadout; SHA `49E7945760A32E288194ACB3746F61420289DECF49DDEC253E753CE250B9A9A5`).
- `res://tests/presentation/v63_d3_learning_ui_test.gd` — PASS, archives a real manual, starts/cancels/completes study, displays ETA and equips the main slot (SHA `A767F81110AB3698C16EE3FC3BE4D93304B078E20D2822C588027EFC852170C6`).
- P2.3 technique regression, P3.7B1 Warehouse, SaveService async round-trip (10 checks), SAFE-01 recovery, and PvE save/return/reload (50 checks) all exit 0. SAFE-01 intentionally emits malformed-JSON recovery diagnostics and prints its PASS marker.

Focused stdout/stderr logs are in the evidence directory above. All tests ran sequentially on Windows Godot 4.7.2.

## Pending — not user-playable accepted

- Feature gates remain OFF by default; D3 and D4 focused tests used explicit preview overrides for candidate behavior.
- D2 single-encounter `HuntingMapV2.claim_reward` codex bridge is not integrated yet.
- D4-A and D4-B are integrated/headless tested for all nine Human branches and all three Human Bosses. D7–D8 remain pending. This is not the complete skill roster or a user-playable accepted build.
- Physical GUI gameplay/capture, Source A UI reskin/owner visual review, Android device QA and whole-game performance remain PENDING.
- No claim of FULL COMPLETE or release readiness.

The isolated checkout contains Godot-generated import metadata, test user data, and QA files. They were not staged. Existing E: workspaces and real saves were left untouched.

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

1. Full 22-test headless matrix PASS trên RC; dùng exact SHA, logs và exit codes trong evidence của Issue #37, không ghép kết quả từ SHA cũ.
2. Nghiệm thu GUI chuột thật 1280×720: 15s sản xuất, chọn sáu đệ tử, PvE 30–60s, pan/zoom/minimap, Save/Return; chạy `tools/windows/run/Run-PVE-FPS-QA.cmd` OFF và `/log` ON tuần tự, ghi P50/P95/P99, 1%-low, RAM, worst spikes và ảnh/video thật.
3. Chỉ owner review/duyệt mới merge `main`; không xóa PR/nhánh hoặc hồ sơ, save, E: assets.

Nguồn: [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37) · [PR #51](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/51) · [PR #50](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/50) · [166-branch inventory](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/audit/tmb-whole-project-readiness-20261027/docs/operations/TMB_GITHUB_BRANCH_CONSOLIDATION_REGISTER_2026-10-27.md).

Old full history preserved at [legacy checkpoint](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/6b3fd181392c96c2386e5aa85950d2e993d67dda/CURRENT_CHECKPOINT.md).
