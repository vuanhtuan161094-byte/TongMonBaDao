# Bản chơi thử P3.2 endgame

## Mở game

1. Dùng Godot official 4.7.2 tại `E:\Godot_v4.7.2-stable_win64_console.exe`.
2. Mở `Run-Endgame-QA.cmd` ở thư mục gốc của worktree bằng double-click. Không cần Administrator.
3. Launcher mở scene gameplay thật `res://scenes/p3/p3_2_landscape_sect.tscn` ở 1280×720 và dùng save cách ly trong `godot/outputs/endgame_qa_20261026/userdata/`.
4. Mặc định tải trạng thái QA 130 đệ tử với 30 Mỏ, 30 Linh Lâm, 40 Linh Điền và các công trình phụ canonical. Save gốc `godot/qa/endgame_qa_save.json` chỉ được đọc làm nguồn.

Hồ sơ 200 được tạo để nghiệm thu trong worktree hiện tại: `godot/qa/endgame_qa_save_200.json`, SHA-256 `E0EE041E433B93AAE9CBF2FE027638D0AAEB00D59826D5ADDB55BBB286E8463B`. Chạy `Run-Endgame-QA.cmd --tmb-roster=200`. Đây là save QA cục bộ bị `.gitignore` loại khỏi commit; hồ sơ 500 chưa tạo do cổng RAM.

## Evidence

- [Báo cáo nghiệm thu](ENDGAME_QA_REPORT.md)
- [Ảnh preview 10/263 asset QA_PASS](assets/sourcea_qa_pass_preview_sheet.png)
- [Catalog SHA/clip/pivot 263 asset](assets/sourcea_qa_pass_asset_catalog.csv)
- [Log focused 29](logs/focused_29_final_20261026_013707_831/focused_results.csv)
- [Log 6 map/PvE foundation](logs/endgame_map_additional/focused_results.csv)
- [Capture Godot 4.7.2, 130 roster](logs/gui_capture/capture_130.log)
- [Capture Godot 4.7.2, 200 roster](logs/gui_capture/capture_200.log)

Các ảnh PNG, JSON evidence và isolated capture save nằm dưới `godot/outputs/endgame_qa_20261026/gameplay/roster_130/` và `roster_200/`.

Video chưa được tạo vì máy không có ffmpeg/OBS; ảnh là capture từ production P3.2, không phải mockup. Kiểm tra click thủ công của người chơi vẫn PENDING.
