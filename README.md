# TÔNG MÔN BÁ ĐẠO — Godot 4.7.2

Game quản lý tông môn, sản xuất, tuyển đệ tử và chiến đấu PvE liên tục. **Đích cuối: một game hoàn chỉnh trên `main`, một launcher Windows, một SaveService canonical.**

> **TRẠNG THÁI PHÁT HÀNH (04/11/2026):** Chưa có bản PLAYABLE Windows được nghiệm thu. Ứng viên đang tích hợp là **[PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72)**, **không phải PR #52, PR #67 hoặc `main`**. Thông tin mới nhất/chuỗi việc R0–R5: **[Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56)** và [bản điều phối canonical](docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md).

## Đâu là phiên bản chính?

| Vai trò | Nguồn | Trạng thái |
|---|---|---|
| Release branch cuối cùng | [`main`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/tree/main) | Chưa có PvE P0 candidate. Không coi là bản gameplay mới nhất. |
| **Tuyến tích hợp duy nhất** | [PR #72 / `integration/pve-p0-playable-ui-20261103`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) | **Draft**, chưa merge. Có PvE 20 camp, 1–30 đệ tử, rewards và Save/Reload; nghiệm thu GUI còn thiếu. |
| Nhánh base của #72 | [PR #67](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/67) | Là tổ tiên; không merge riêng khi #72 đang kế thừa. |
| Animation/rig | PR #68/#69/#71/#74 | Lab/đề xuất; không phải asset production đã nghiệm thu. |

## Cách mở game trên Windows

Workspace Owner: `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao`.

Godot bắt buộc: **4.7.2.stable.official**; thiết kế hiển thị **landscape 1280×720**.

**R2 ACTIVE / launcher vẫn chưa được xác nhận chạy ổn định trên PR #72.** Lượt mở Windows thứ hai gặp crash `ig11icd64.dll` khi khởi tạo OpenGL và còn PID không truy vấn/đóng được. `godot/project.godot` đã là `gl_compatibility`, không thể coi chuyển sang Compatibility là giải pháp. Tên launcher cũ xuất hiện là `MO_GAME.cmd` và `CHOI-GAME.cmd`; hãy để quy trình R2 của Codex xác minh một launcher chính thức thực tế. **Không chạy scripts Sync-Main/Preview cũ tùy tiện, không overwrite checkout/save cá nhân.**

## Mức độ đã kiểm thử

- **R0 PASS:** 196 working items + 94 save được sao lưu và kiểm tra hash (xem Issue #56). **R1 PASS (canonical):** Godot 4.7.2 import + 19 focused tests **20/20 exit 0** ở code SHA `b56b6fe8fa29ae663994a65098a56b60c3b42513`; UI D7 Tam Căn(3)/Tứ Tính(4) đã sửa. Các luật bulk/cap/FoundationGrowth chưa được duyệt vẫn DESIGN_HOLD, không tự nhập.
- World PvE: **20 vùng, 30 hunter tối đa, 40 monster hoạt động / 200 spawn slots**. Test tự động PASS. Natural solo: 10 kills/10 receipts, Tu Vi/Luyện Thể/loot thật, respawn generation 2, cold Save/Reload PASS.
- **Chưa PASS:** GUI chuột Windows thật, 3 clean starts, và trọn vòng New Game → xây → tuyển → sản xuất → PvE → loot → Save/Exit/Reload trên cùng save. Android/touch cũng chưa nghiệm thu.

## Quy tắc tiếp tục phát triển

1. Đọc [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56) → [tài liệu canonical](docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md) → [CURRENT_CHECKPOINT.md](CURRENT_CHECKPOINT.md) → [NEXT_CHAT_HANDOFF.md](NEXT_CHAT_HANDOFF.md) → [AGENTS.md](AGENTS.md).
2. Chỉ sửa trên tuyến PR #72 khi có quyền; bảo toàn khoảng 196 thay đổi local E và save, không reset/clean/ép checkout. PR cũ đã đóng **không** có nghĩa đã merge vào main.
3. Giữ một authority SaveService, Warehouse, Runtime/Scheduler, One Active Job, Injury 0/1/120 ticks; không tự cấp phần thưởng giả.
4. Giữ quyết định nhãn nhân vật **Tam Căn / Tứ Tính** trong giao diện Dẫn Tiên theo chỉ đạo Owner; kiểm tra game authority trước khi sửa cơ chế.
5. Lịch sử tiến độ và hướng dẫn launch cũ được lưu tại `docs/archive/checkpoints/`, **không còn là hướng dẫn hiện hành**.

**Một mục tiêu duy nhất:** R0–R1 đã PASS; **tiếp tục R2→R3→R4→R5 không dừng giữa các gate**, nghiệm thu exact SHA, merge bản đạt chuẩn vào `main` và bàn giao launcher chơi được. [Chỉ thị Codex mới nhất](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72#issuecomment-6627064335).
