# Tông Môn Bá Đạo — bản chơi thử portable Packet B

Bản này mở scene game chính P3.2 trên Godot official 4.7.2. Đây là project Godot portable kèm launcher, chưa phải executable export độc lập vì thư mục export templates trên máy nghiệm thu đang rỗng.

## Mở game

1. Giải nén toàn bộ thư mục ZIP vào một vị trí có thể ghi được.
2. Nhấn đúp `run_tmb_windows.cmd`.
3. Launcher dùng `engine\Godot_v4.7.2-stable_win64.exe` nếu bạn tự đặt engine cạnh game; nếu không, dùng đường dẫn máy nghiệm thu `E:\Godot_v4.7.2-stable_win64.exe`. Có thể đặt biến môi trường `TMB_GODOT_EXE` để chọn một file Godot 4.7.2 khác.
4. Không cần quyền Administrator. Cửa sổ mở ở 1280×720.

Save/user data được cách ly trong thư mục `userdata\`; log được ghi vào `logs\playable.log`. Không dùng save cá nhân của project khác.

## Bản dựng

- Nhánh nguồn: `integration/pr28-combat-v3-s1-playable-qa-20261024`
- Code/test commit: `35db75aed9e39924194a9996ab8e584f2f7b9e1e`
- Git tree đã được kiểm thử: `3c59574d914f57276ca5a1dba5a0802838d02a5d`
- Project entry scene: `res://scenes/p3/p3_2_landscape_sect.tscn`
- Godot: `4.7.2.stable.official.ed1daf0bf`
- ZIP gồm project và Godot `.godot/imported` cache đã sinh trên máy nghiệm thu, nhưng không chứa engine binary; cung cấp engine riêng để tránh tái phân phối file engine 181 MB.
- Windows manual mouse acceptance, Android device/touch và owner visual acceptance vẫn PENDING.

Nếu lần mở đầu cần tái-import asset, đợi Godot hoàn tất rồi mở game lại. Không xóa `userdata` nếu cần giữ save của bản chơi thử.
