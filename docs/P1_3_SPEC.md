# P1.3 — Quan hệ + tác động hành vi

## Mục tiêu

P1.3 biến quan hệ giữa đệ tử thành một phần của mô phỏng, không phải dữ liệu trang trí.

## Phạm vi khóa

- Quan hệ có hướng: A -> B độc lập với B -> A.
- Ba chỉ số: thiện cảm, tin tưởng, kính trọng; miền 0..100, trung lập 50.
- Lưu thưa: chỉ tạo bản ghi cho các cặp có liên hệ thực sự.
- Mạng ban đầu chỉ tạo một số liên hệ gần cho mỗi đệ tử; không tạo toàn bộ N x N.
- Tính cách làm cùng một sự kiện tạo mức thay đổi quan hệ khác nhau.
- Kết quả chiến đấu khi những người có liên hệ đang ở cùng khu vực có thể làm quan hệ thay đổi.
- Quan hệ tác động trực tiếp tới điểm chọn khu vực của AI.
- Người chơi có thể ghép một đệ tử với một đồng hành. Lệnh này tăng tác động của mối quan hệ lên lựa chọn khu vực.
- Quan hệ xấu có thể làm đệ tử tránh khu vực của người kia; quan hệ tốt có thể kéo họ về cùng khu vực.
- Người mới tuyển ở P1.2 được nối vào mạng quan hệ khi P1.3 đang bật.
- Quan hệ, ghép đồng hành và số sự kiện quan hệ phải lưu/tải được.

## Trọng số hành vi

Điểm quan hệ so với mức trung lập được tính từ:

- thiện cảm: 30%;
- tin tưởng: 45%;
- kính trọng: 25%.

Điểm này đi thẳng vào điểm lựa chọn khu vực. Ghép đồng hành của người chơi tạo thêm trọng số nhưng không xóa tính cách hay quan hệ cá nhân của nhân vật.

## Khả năng mở rộng

P1.3 không quét toàn bộ mọi cặp đệ tử. Khi một đệ tử cần quyết định, hệ thống chỉ đọc các cạnh quan hệ của chính đệ tử đó. Với tông môn 120 người, số bản ghi có thể vẫn chỉ là vài trăm hoặc vài nghìn thay vì bắt buộc 14.280 quan hệ có hướng.

## Không mở trong P1.3

- ký ức dài hạn;
- yêu đương/kết hôn;
- sư đồ;
- kết nghĩa;
- phe phái;
- phản bội/rời tông môn;
- đánh nhau nội bộ;
- cảnh giới/công pháp.

## Điều kiện đạt

1. P0, P1.1 và P1.2 đều vẫn đạt.
2. Cùng hạt khởi tạo sinh cùng mạng quan hệ.
3. Mạng quan hệ là mạng thưa, không phải toàn bộ N x N.
4. Thiện cảm, tin tưởng và kính trọng đều có tác động đo được lên quyết định.
5. Tính cách làm phản ứng quan hệ khác nhau với cùng sự kiện.
6. A -> B không tự động làm thay đổi B -> A.
7. Quan hệ đủ mạnh làm thay đổi được lựa chọn khu vực.
8. Ghép đồng hành của người chơi làm thay đổi được lựa chọn khu vực trong bài thử kiểm soát.
9. Người mới tuyển được đưa vào mạng quan hệ.
10. Lưu/tải giữ nguyên quan hệ và ghép đồng hành.
11. Chạy tiếp sau tải vẫn xác định và không lệch.
12. Màn thử P1.3 khởi chạy được trên Godot 4.7.2.
