# TÔNG MÔN BÁ ĐẠO — MAP-D1B Option B portable project

## Mở game

1. Giải nén `TMB_MAP_D1B_WINDOWS_PORTABLE_2026-10-25.zip` sang một thư mục có quyền ghi, ví dụ trên ổ E:.
2. Nhấn đúp `Run_Map_D1B.cmd`. Không cần Administrator.
3. Game mở thẳng màn P3.2 thật theo project, viewport 1280×720. Đây không phải một scene demo riêng.
4. Nhấn dấu cộng/trừ để zoom; kéo bản đồ để pan. Chạm Mỏ, Linh Lâm hoặc Linh Điền để mở panel quản lý producer thật. Nút đóng panel nằm ở góc phải.

Save được cách ly trong thư mục `userdata/` cạnh launcher. Giữ thư mục này nếu muốn tiếp tục lần chơi trước. Không có save nào trong project gốc bị dùng hoặc thay thế.

## Nội dung

- `godot/` — project hiện tại, Source A đã SHA-gate và harness/test.
- `Godot_v4.7.2-stable_win64.exe` — Godot official 4.7.2 portable editor/runtime dùng để mở project.
- `Run_Map_D1B.cmd` — launcher một lần nhấn.
- `userdata/` — tạo khi chạy, dành riêng cho gói này.

Đây là **gói project Godot portable**, không phải standalone exported game EXE. Export template Godot 4.7.2 không có trên máy tại lúc tạo gói.

## Xác minh

- Godot: `4.7.2.stable.official.ed1daf0bf`.
- Project scene: `res://scenes/p3/p3_2_landscape_sect.tscn`.
- Focused regression: 29/29 PASS; không chạy FULL/CI.
- Bản đồ hunting Thanh Trúc Lâm 20 bãi là hệ riêng, không thay thế map tông môn.
- Owner visual approval, Windows manual play của người chơi, Android/touch vẫn PENDING.

Xem báo cáo `TMB_MAP_D1B_OPTION_B_IMPLEMENTATION_REPORT_2026-10-25.md` và matrix trong repository để biết asset còn thiếu, benchmark và giới hạn prototype.