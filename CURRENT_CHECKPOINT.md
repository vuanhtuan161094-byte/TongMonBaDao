# CURRENT CHECKPOINT — TÔNG MÔN BÁ ĐẠO

**Cập nhật 27/10/2026 — Một dự án, một bản game chính thức.** Đọc file này trước; các checkpoint dài cũ là lịch sử, không phải nhiều phiên bản game song song.

## Phiên bản và quyền hạn

| Loại | Nhánh | Trạng thái |
| --- | --- | --- |
| **Stable chính thức** | `main` tại `29b5fba448b0178cb520a4ada44b375b4b934e31` | Bản đã được chấp nhận; **chưa chứa** PvE mới. Chưa được phép thay đổi. |
| **Bản phát triển tham chiếu** | `feature/pve-jx-continuous-world-20261026` tại `6b3fd181392c96c2386e5aa85950d2e993d67dda` | Nền tảng shared cho hai Codex; giữ nguyên trong kỳ nghiệm thu. |
| **Ứng viên tích hợp DUY NHẤT** | `integration/pve-unified-rc-20261027` | Tổng hợp **PR #51 core + PR #50 visual + tài liệu PR #49**, bảo toàn đúng file/byte và nhánh gốc. **RC QA CHƯA CHẠY**, không phải Stable. Xem GitHub branch HEAD hiện hành thay vì tin SHA hard-code trong docs. |
| Core hồi quy đã chạy | [PR #51](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/51) SHA `c217471bd3fbe88b95e6e7537b39dc07ae683e41` | Codex 1 **báo cáo 14/14 lệnh Godot 4.7.2 exit 0**; log chi tiết lưu tại E: Windows, chưa tái kiểm tra bằng engine trên RC. |
| Visual & VFX chưa nghiệm thu | [PR #50](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/50) SHA `59c6dea9041653026e02a55b0bc1f4e298976835` | SHA sheet/manifest Source A/JX static PASS; code test SaveService → resume được thêm; **Godot runtime, chuột thật và FPS PENDING**. |
| Handoff/Docs | [PR #49](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/49) | Trạng thái được nén, AGENTS và kiến trúc không bị thay; file này cập nhật kết quả Codex 1/2 trên RC. |

**Không merge các PR nguồn #44–#51 riêng lẻ vào main.** Khi nghiệm thu đủ RC và được owner duyệt, một lần review/merge bản chốt vào `main`, tag SHA, đóng các PR được thay thế có dẫn nguồn và thu hồi nhánh sau khi Windows worktree đã nhả.

## Kết quả và gate nghiệm thu

| Gate | Tình trạng có bằng chứng |
| --- | --- |
| Canonical SaveService | **PASS trên PR #51**: lỗi `FAILED=1` trong DV2-03 do fixture thay `aptitude` đệ tử D7 mà không cập nhật quality. SaveService production không sửa, save hợp lệ và backup còn nguyên. Chưa chạy lại RC. |
| PvE move C17 + 6 thành viên | **PASS trên PR #51**: hoàn tất subcell same-cell; sáu đích hợp lệ riêng, cùng connected region, thao tác nguyên tử; Godot focused QA PASS. |
| World 20 camps / autonomous | **PASS trên PR #51**: C01 → C02 sau 10 HP0 tự nhiên, có năm quái C01 respawn, Save/Reload. Kết quả 11 HP0 tổng, 5/6 đội sống tại lúc chụp, `LOOT_PENDING`, Warehouse không phát sinh receipt. |
| Injury120 | **PASS test độc lập** GP-02C1 tại mốc 119/120 tick online/offline trên PR #51. Bài P3.2 70s ở SHA đó có tám kills, **zone-hop và Injury120 chưa tới** trong fixture ngắn này. |
| VFX JX #158 | **PASS static** 10+17+8=35 frames, frame bounds, sheet hash/anchor, Source A tám clip/texture khớp E:. Binding Unity prefab/pivot và skill mapping vẫn **UNVERIFIED**; test VFX/runtime Save/Reload trên PR #50 và RC **PENDING**. |
| GUI bình thường / điều khiển chuột / FPS | **BLOCKED / PENDING**. Godot QA slot đã được Codex 1 nhả trên [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37#issuecomment-6431975722); Codex 2 có thể chạy QA **trên RC exact SHA** tuần tự khi máy không có Godot xung đột. Không có screenshot/video/phase FPS/RAM mới. |
| Android | Chưa có APK/thiết bị thật nghiệm thu. |
| Branch cleanup | Kiểm kê 166 nhánh trước đây, chưa xóa nhánh hay đóng PR nào; không xóa nhánh khi có worktree Codex hoặc dữ liệu độc nhất. |

## Quy tắc kỹ thuật vẫn khóa

- Godot **4.7.2**; landscape **1280×720**.
- Source A đã chốt phong cách và map sản xuất; không làm lại renderer.
- **Combat V2** duy nhất; One Active Job; Injury 0/1 và **120 scheduler ticks**; SaveService/SimulationRuntimeOwner/Warehouse canonical; không cấp phần thưởng đồ rơi giả.
- Các thiết kế công pháp/Boss/Forge/Economy V2 chưa nằm trong code hiện hành không tự trở thành runtime authority khi hợp nhánh.
- Hiện `main` và PvE feature không thay đổi. Draft RC không chứng minh visual acceptance hay performance.

## Bàn giao tiếp

1. Trên Windows dùng worktree **riêng** của `integration/pve-unified-rc-20261027`, xác minh exact HEAD/Godot 4.7.2/clean status.
2. Rerun PR #51 focused checks và VFX/death/P3.2/SaveService focused tests cho *combined exact SHA*; không dùng PASS cũ như PASS cho RC.
3. 1280×720 GUI thật: 15s sản xuất, chọn sáu đệ tử, PvE 30–60s, pan/zoom/minimap, Save/Return; chạy `Run-PVE-FPS-QA.cmd` OFF và `/log` ON tuần tự, ghi P50/P95/P99, 1%-low, RAM, worst spikes và ảnh/video thật nếu có.
4. Khi đủ evidence: owner xem kết quả, chấp thuận mới merge `main`; lúc đó đóng các PR trùng lặp và thu hồi nhánh có ghi SHA; không xóa hồ sơ, save, E: asset.

Nguồn: [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37) · [PR #51](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/51) · [PR #50](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/50) · [166-branch inventory](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/audit/tmb-whole-project-readiness-20261027/docs/operations/TMB_GITHUB_BRANCH_CONSOLIDATION_REGISTER_2026-10-27.md).

Old full history preserved at [legacy checkpoint](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/6b3fd181392c96c2386e5aa85950d2e993d67dda/CURRENT_CHECKPOINT.md).
