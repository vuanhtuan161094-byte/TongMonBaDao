# GUI acceptance — exact RC SHA 0d3952dd

## Trạng thái: PENDING_GUI

Godot 4.7.2 từng khởi chạy scene P3.2 ở cửa sổ Windows 1280×720 và ghi runtime-ready, nhưng Computer Use/Sky không liệt kê cửa sổ Godot trong app inventory. Vì không có target GUI hợp lệ để quan sát, phiên này không gửi input chuột và không chụp screenshot/video. Win32 process/window metadata hoặc startup log không thay cho gameplay acceptance.

## Checklist chủ sở hữu cần chạy

Dùng checkout `integration/pve-unified-rc-20261027` tại exact SHA `0d3952dd11f85bebbde60176deafc4f19afc8a6f`, engine Godot `4.7.2.stable.official.ed1daf0bf`.

1. Mở `Run-PVE-Play.cmd`, xác nhận cửa sổ 1280×720, bản đồ Source A và HUD không lỗi.
2. Từ màn hình tông môn mở **Săn quái / Thanh Trúc Lâm**, chọn sáu đệ tử hợp lệ; xác nhận giải thích rõ nếu roster không đủ.
3. Click đất để di chuyển; theo dõi sáu điểm đến khác nhau. Để Combat V2 tự chiến với quái và quan sát cast, projectile, hit/impact JX #158, HP/death/respawn và chuyển vùng.
4. Pan/zoom camera và so minimap với cùng thế giới.
5. Save → Return → Load/Resume; kiểm tra roster/zone/HP và không replay hit/claim/reward.
6. Chụp ảnh và video thật. Ghi thao tác, exact SHA, cấu hình và log.

Chỉ chuyển sang GUI PASS khi hoàn thành checklist với bằng chứng thật. Hiện chưa có GUI evidence; không gọi game PLAYABLE PASS.
