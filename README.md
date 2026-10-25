# Tông Môn Bá Đạo

Game quản lý tông môn tu tiên, Godot 4.7.2 / GDScript. Mục tiêu Android màn hình ngang 1280×720; quy mô dài hạn 1.000–3.000 đệ tử.

Người chơi quản lý hạ tầng, nhân sự, chính sách, tu luyện và săn quái. Simulation sở hữu dữ liệu gameplay; giao diện đọc trạng thái và gửi lệnh thật. Một Warehouse, một nguồn thời gian, One Active Job và save/reward exactly-once.

## Trạng thái dự án

**`main` chưa chứa toàn bộ bản game mới.** Nhánh tích hợp gameplay #31, map Option B #32, ứng viên MAP-D2 #33, PvE presentation #34 và CODE-R0 là các luồng khác nhau; tất cả chưa được gộp thành một bản đã QA.

Xem [CURRENT_CHECKPOINT.md](CURRENT_CHECKPOINT.md) để chọn đúng nhánh, SHA, bằng chứng và việc còn thiếu. [NEXT_CHAT_HANDOFF.md](NEXT_CHAT_HANDOFF.md) là hướng dẫn tiếp tục. Không dùng số phase hoặc ngày commit để suy ra mức hoàn thiện.

| Thành phần | Trạng thái ngày 25/10/2026 |
| --- | --- |
| Gameplay tích hợp #31 | 28/28 focused, 56 S1 checks theo evidence đã lưu |
| Map Option B #32 | 29/29 focused theo evidence đã lưu; owner visual pending |
| MAP-D2 #33 và PvE #34 | Có code; Godot QA pending |
| CODE-R0 | QA blocked: chưa có runner thực thi 21 tests |
| Android / nghiệm thu hình ảnh / bản phát hành | Chưa hoàn tất |

Đây là tổng hợp bằng chứng trước đó, không phải lượt chạy test mới.

## Làm việc với dự án

Đọc [AGENTS.md](AGENTS.md), [kiến trúc](docs/GAME_SYSTEM_ARCHITECTURE.md), checkpoint và handoff trước khi sửa. Specs là thiết kế; checkpoint mới xác định tiến độ.

Windows sử dụng entrypoint `Sync-Main.cmd` cho trunk; chỉ gọi `Sync-Main.cmd Verify-<gate>.cmd` khi đúng gate đã được giao. Lệnh đồng bộ main không tải các PR thử nghiệm chưa merge; xem checkpoint trước khi chọn bản chạy.

Các verifier cũ còn là dependency/bằng chứng hồi quy. Đợt dọn này bỏ hướng dẫn lỗi thời trong tài liệu, giữ các hợp đồng runtime và asset còn giá trị. [Biên bản dọn dự án](docs/PROJECT_CLEANUP_2026-10-25.md).
