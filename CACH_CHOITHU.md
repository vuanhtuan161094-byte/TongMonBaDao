# Cách chạy DEMO V3

## Yêu cầu

- Windows và Godot **4.7.2**.
- Launcher tự tìm E:\Godot_v4.7.2-stable_win64.exe hoặc godot.exe trong PATH. Nếu Godot ở chỗ khác, đặt biến môi trường GODOT_BIN tới file thực thi Godot 4.7.2.

## Chơi

Chạy tools\qa\Run-TMB-Demo-Windows.cmd. Mặc định mở launcher DEMO trong cửa sổ 1280×720. Lần đầu launcher nhập asset vào cache .godot; các lần sau chỉ nhập lại khi fingerprint của source đổi. Launcher gọi scene DEMO riêng, còn main scene của project vẫn là P3.2.

Trong launcher:

- **CHƠI NGAY — DEMO MAX** tạo save sandbox mới với 6 đệ tử săn, Tu Vi và Luyện Thể 30.10, kỹ năng P2 hợp lệ đã học, trang bị sở hữu, 6 worker riêng (3 được giao việc), rồi mở một lần săn V2 ở Tuyệt Địa cấp 5.
- **CHƠI TỪ ĐẦU** tạo state khởi đầu bình thường trong save DEMO.
- **TIẾP TỤC DEMO** mở save DEMO hiện có.

Muốn chạy focused QA riêng, dùng tools\qa\Run-TMB-Demo-Windows.cmd -Focused. Muốn xóa riêng save sandbox DEMO, dùng tools\qa\Run-TMB-Demo-Windows.cmd -ResetDemo; thao tác này chỉ nhắm user://demo_sandbox của ứng dụng DEMO.

Godot xác nhận thư mục người dùng riêng là %APPDATA%\Godot\app_userdata\Tong Mon Ba Dao Demo V3; trong phiên xác minh, OS.get_user_data_dir() trả về C:/Users/Admin/AppData/Roaming/Godot/app_userdata/Tong Mon Ba Dao Demo V3. Save DEMO nằm trong demo_sandbox/, tách khỏi save mặc định của game.

## Nội dung và giới hạn đã xác minh

- Luật đánh, chỉ số, HP, hit, phần thưởng và settlement dùng Combat V2 hiện có. Đội săn và thưởng được tạo qua HuntingPveRunV2 thật.
- VFX JX1 #158 (impact), #63 (impact), #93 (precast) được kiểm tra SHA-256 và được QA kích hoạt từ event combat có thẩm quyền. Combat sprites dùng atlas source hiện có.
- **Bản đồ nền JX1: ASSET_INCOMPLETE**. res://art/jx1_private/img/z/2.jpg không nằm trong commit nguồn đã xác minh. Nền sàn cầu nối hiện là texture sân đá Source A, được ghi rõ trong manifest; đây không phải bản đồ JX1.
- Kỹ năng P2 hợp lệ được học và trang bị trong DEMO. Cấp mastery kỹ năng không có trong hệ thống hiện hành, nên không được giả lập.
- Launcher và focused test đã chạy trên Godot 4.7.2. Đây là build DEMO có sandbox riêng, không phải gói phát hành Android.
