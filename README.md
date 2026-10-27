# TÔNG MÔN BÁ ĐẠO — Godot 4.7.2

Tu tiên quản lý tông môn và PvE liên tục. **Một bản game chính thức: `main`.** Bản PvE hiện đại hiện đang ở ứng viên nghiệm thu, không phải nhiều nhánh game độc lập.

## Cách mở game bằng một cú nhấp

Chỉ dùng **MO_GAME.cmd** trong E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao hoặc shortcut Desktop trỏ đến file này. Không chọn đại các Sync/Verify/Preview cũ. Launcher chỉ chạy checkout chứa PvE RC đúng baseline, dùng Godot 4.7.2 trên ổ E, kiểm tra Stage A và gọi Run-PVE-Play.cmd. Nếu checkout ở E chưa chuẩn, hãy để Codex đồng bộ trước. **Chưa xác minh dọn máy local.** Xem [quy tắc workspace và kế hoạch chuyển 44 script](docs/operations/TMB_ONE_WORKSPACE_WINDOWS_20261027.md).

## Bắt đầu ở đâu?

| Loại | Link | Ý nghĩa |
| --- | --- | --- |
| Stable chính thức | [`main`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/tree/main) | Bản đã được nhận; chưa nhập ứng viên PvE mới. |
| **RC duy nhất đang nghiệm thu** | [`integration/pve-unified-rc-20261027`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/tree/integration/pve-unified-rc-20261027) | Kết hợp CodeX 1 core PR #51 (14/14 test PASS tại SHA riêng), CodeX 2 VFX/FPS PR #50 (static PASS, runtime PENDING) và docs PR #49. **Godot 4.7.2 headless full regression 22/22 PASS**; exact SHA, commands và exit codes nằm trong evidence của Issue #37. GUI chuột, Save/Return và FPS OFF/ON vẫn PENDING. |
| Nguồn lịch sử | [Feature PvE](https://github.com/vuanhtuan161094-byte/TongMonBaDao/tree/feature/pve-jx-continuous-world-20261026) / [#51](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/51) / [#50](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/50) | Không tự xem là bản game mới nhất để chơi; giữ lại để audit và rollback. |

**Đọc [CURRENT_CHECKPOINT.md](./CURRENT_CHECKPOINT.md) để biết live trạng thái, SHA và PASS/FAIL/PENDING.** [NEXT_CHAT_HANDOFF.md](./NEXT_CHAT_HANDOFF.md) chỉ có một hàng đợi QA. Quyền hạn kỹ thuật tại `AGENTS.md` và `docs/GAME_SYSTEM_ARCHITECTURE.md` giữ nguyên.

## Chạy ứng viên PvE trên Windows (chưa được gọi là bản phát hành)

- Dùng isolated worktree riêng của RC, xác định exact SHA + Godot **4.7.2**.
- `Run-PVE-Play.cmd`: mở P3.2 landscape 1280×720 với save QA tổng hợp, vào **Săn quái / Thanh Trúc Lâm**, chọn sáu đệ tử thực.
- `Run-PVE-FPS-QA.cmd` và `Run-PVE-FPS-QA.cmd /log` tuần tự, log có timestamp. Giữ mỗi lần chỉ một Godot GUI trên máy Windows 8GB. Không dùng MovieWriter thay đo FPS GUI.
- Cần chuột thật, camera/minimap/PvE/Save/Return; ảnh thật và phase P50/P95/P99/1%low/RAM mới được chấp nhận. Test inject chuột/headless KHÔNG thay nghiệm thu GUI.
- Log và lỗi cập nhật [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37) đúng SHA.

## Trạng thái QA mới nhất

- Bài P3.2 integration headless với roster 130 mất 252,956 giây cho 50 bước shared clock; đây là tải mô phỏng cần điều tra, không phải FPS GUI.
- Launcher đã nạp scene P3.2, 130 đệ tử, 103 công trình và tạo save QA cô lập. Sky không liệt kê cửa sổ Godot nên chưa xác nhận hình ảnh hoặc thao tác chuột.
- Không tuyên bố GUI PASS, FPS PASS hay PLAYABLE PASS khi các bước đó còn pending.

## Không thay đổi các contract đã khóa

Source A production renderer giữ nguyên; Combat V2 là authority duy nhất. Một scheduler runtime, SaveService, Warehouse, One Active Job và Injury 0/1/120 tick. PvE có 20 camp/192×192; loot mỗi quái **`LOOT_PENDING`**, không tự cấp reward. JX #158 VFX là cosmetic; Unity Source A skill prefab/pivot mapping còn chưa xác minh.

**Không mass merge 40+ Draft PR, không chuyển `main` sang RC trước khi QA và owner duyệt, không xóa nhánh/worktree/asset/save để dọn lịch sử.** Sau nghiệm thu, nhập một lần vào `main`, tạo tag checkpoint và thu hồi các nhánh tạm theo sổ [166-branch review](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/audit/tmb-whole-project-readiness-20261027/docs/operations/TMB_GITHUB_BRANCH_CONSOLIDATION_REGISTER_2026-10-27.md).
