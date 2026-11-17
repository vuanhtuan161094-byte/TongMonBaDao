TMB VFX PLAYTEST QA49 — MỞ BẰNG MỘT CÚ NHẤP

1. Tải artifact TMB_VFX_PLAYTEST_WINDOWS từ run GitHub Actions được liên kết ở PR #72, rồi giải nén ZIP một lần. Thư mục vừa giải nén có sẵn START_TEST.cmd, không có ZIP lồng bên trong.
2. Nhấp đúp START_TEST.cmd. Godot 4.7.2 portable đã nằm trong gói; không cần cài hoặc tự tìm Godot.
3. Lần đầu, nếu gói chưa tự tìm thấy nguồn, chọn thư mục R1 V10 đã giải nén khi hộp thoại xuất hiện. Chọn thư mục có ASSET_MANIFEST_SHA256.json và SHA-256 A766948A82171909DE4DF3B2DA5F30EB587DB71CB3444141D2DF53B0FB401B49. Không chọn thư mục Tông Môn hoặc Godot. Chỉ chọn một lần; launcher xác minh SHA rồi chép ảnh vào profile QA riêng.
4. Đợi cửa sổ thử nghiệm 1280 x 720 mở. Gói chỉ là lab hình ảnh, không gây sát thương, trạng thái, không sửa Combat V2, SaveService, PvE hay save người chơi.
5. Điều khiển: WASD/phím mũi tên di chuyển; phím 1–7 xem bảy hiệu ứng Độc/Phù; SPACE đánh; nhấp chuột trái/TAB đổi quái; M bật/tắt quái di chuyển; V bật/tắt VFX; P tạm dừng; R đặt lại; H ẩn HUD.
6. Sau khi đóng game, log và profile QA nằm trong %LOCALAPPDATA%\TMB\QA49. Launcher không ghi ngược vào thư mục R1 đã chọn.

Nguồn và giới hạn:
- Godot: bản Windows x64 portable chính thức 4.7.2 stable. Workflow ghim và kiểm SHA-256 gói phát hành chính thức.
- Source game: đúng SHA PR #72 ghi trong package_manifest.json.
- Nhân vật V10: manifest R1 SHA-256 A766948A82171909DE4DF3B2DA5F30EB587DB71CB3444141D2DF53B0FB401B49; ZIP nguồn nhân vật SHA-256 c8290077e0fc8ee9fd99f21b4e69038f2c3fecb9471bde253799bb4ef1fcd4fa; có 240 frame và 23/24 clip. Death_Left còn thiếu, không lật ảnh để giả lập.
- Bảy nguồn VFX: POI02, POI03, POI04, TAL02, TAL03, HF02 R6, HF03 R2. Cầu nối mục tiêu di chuyển trong lab chưa được duyệt thành VFX sản xuất.
- Không rig nhân vật. Không có damage/status gameplay. Owner visual approval và thử trên Windows vật lý vẫn là cổng riêng.

