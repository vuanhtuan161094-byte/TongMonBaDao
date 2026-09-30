# P1.2 — Dân số + Tuyển đệ tử + Quyết định của người chơi

## Mục tiêu

P1.2 làm cho tông môn có khả năng tăng dân số nhưng không tự tuyển người thay người chơi. Hệ thống chỉ tạo ứng viên; người chơi quyết định nhận hoặc từ chối.

## Phạm vi khóa

- Tông môn có giới hạn số đệ tử.
- P1.2 bắt đầu với 6 đệ tử, sức chứa 8 và 3 ứng viên.
- Ứng viên được sinh ổn định từ hạt khởi tạo của mô phỏng.
- Mỗi ứng viên có tên, sức mạnh, tính cách và ba xu hướng hành vi của P1.1.
- Người chơi có hai quyết định trực tiếp: nhận hoặc từ chối.
- Người được nhận trở thành đệ tử với 0 tiền cá nhân để không tạo thêm tiền ngoài quy tắc kinh tế.
- Người được nhận lập tức dùng hệ thống tính cách + mục tiêu P1.1.
- Khi tông môn đủ chỗ, thao tác nhận phải bị chặn.
- Danh sách ứng viên, số lần sinh ứng viên, số lần nhận/từ chối và sức chứa phải lưu/tải được.
- Có một màn thử riêng để bấm Nhận/Từ chối; màn P0 cũ không bị thay thế.

## Không thuộc P1.2

- Quan hệ giữa đệ tử.
- Ký ức.
- Sư đồ.
- Cảnh giới tu tiên/công pháp.
- Tử vong hoặc rời tông môn phức tạp.
- Phí tuyển dụng, danh tiếng, yêu cầu nhập môn nâng cao.
- Đồ họa sản phẩm cuối.

## Điều kiện khóa PASS

1. Toàn bộ cổng P0 vẫn PASS.
2. Toàn bộ cổng P1.1 vẫn PASS.
3. Cùng một hạt khởi tạo tạo đúng cùng danh sách ứng viên.
4. Cùng chuỗi quyết định nhận/từ chối tạo cùng trạng thái.
5. Nhận và từ chối cùng một ứng viên tạo hai kết quả dân số khác nhau.
6. Không thể nhận quá sức chứa.
7. Tuyển người không làm thay đổi tổng tiền hệ thống.
8. Người mới có tính cách + mục tiêu P1.1 và có thể chạy trong mô phỏng.
9. Lưu/tải giữ nguyên toàn bộ trạng thái tuyển dụng.
10. Chạy tiếp sau lưu/tải vẫn ổn định.
11. Màn thử tuyển đệ tử mở được trong Godot 4.7.2.

Lệnh kiểm tra: `Sync-P1-2.cmd`.
