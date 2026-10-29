# CURRENT CHECKPOINT — TÔNG MÔN BÁ ĐẠO

## Cập nhật 29/10/2026 — V6.5 full combat task

> Ghi chú hiện tại này thay thế các branch head và gate đã cũ trong snapshot lịch sử bên dưới.
>
> - Stable `main`: `c0c1382f119599497b52d8ee8abd9e830a883f1e`; PvE reference `integration/pve-unified-rc-20261027`: `5005d7508dff4b6a3da3f319de09dac33669882a`.
> - D1 baseline: `6e4012d7a9e3a7efa56df349a176f9491d550742`; active no-merge work branch: `feature/v63-v64-full-combat-20261029`.
> - Godot 4.7.2 Windows import and focused D1 registry test both PASS (exit 0). Evidence and log hashes: [D1 validation report](docs/implementation/V63_D1_VALIDATION_EVIDENCE_20261029.md).
> - D1 remains data-only: gates OFF, no skill runtime, boss spawn, or loot wiring.
> - D2 Sect Archive and exactly-once codex rewards are complete on tested source `d45ab195c53c00f0f29732124dd7678fd42cb351`; official Godot 4.7.2 import and all 10 focused/regression scripts PASS. See [D2 evidence](docs/implementation/V63_D2_ARCHIVE_EVIDENCE_20261029.md). The release gate remains OFF; no production drop profiles or rates were authored.
> - D2 used the owner-approved exact path allowlist. PR #52 remains Draft/open and no merge to `main` was performed. The original E: checkout and its existing QA/import artifacts were preserved.
> - Next is D3 planning and its own owner-approved exact code path allowlist. Do not begin D3 SaveService migration, timed research/One Active Job, live skill runtime, or D4+ in this packet.
> - PR #52 remains Draft/open. No merge to `main`; the original E: checkout and its QA artifacts were preserved.


**Cập nhật 27/10/2026 — Một dự án, một bản game chính thức.** Đọc file này trước; các checkpoint dài cũ là lịch sử, không phải nhiều phiên bản game song song.

## Phiên bản và quyền hạn

| Loại | Nhánh | Trạng thái |
| --- | --- | --- |
| **Stable chính thức** | `main` tại `c0c1382f119599497b52d8ee8abd9e830a883f1e` | Bản đã được chấp nhận; **chưa chứa** PvE mới. Chưa được phép thay đổi. |
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
