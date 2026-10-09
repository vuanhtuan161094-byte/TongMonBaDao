# DV2 — PHƯƠNG ÁN TRỌNG SỐ SINH ĐẶC CHẤT / MỆNH CÁCH V1

2026-10-09

**NUMERIC DESIGN PROPOSAL — CHƯA CHỐT TRỌNG SỐ TỪNG ID, CHƯA KÍCH HOẠT V2 SINH NỘI DUNG.** Người dùng đã duyệt **chọn theo trọng số riêng** (Trait, Fate) nhưng chưa duyệt các trọng số chính xác; bảng này được lập đầy đủ để rà nguồn → hiệu ứng → eligibility trước khi mở toàn bộ DV2-01.

Không thay đổi:
- visible Trait count 1/2/3 = 60/32/8%;
- mỗi visible Trait chọn nhóm Hữu Ích/Song Diện/Bất Lợi = 50/30/20% trước khi chọn ID;
- latent Trait = 8%, tối đa một; không reroll sau sinh, conflict check;
- Mệnh congenital = 0.50% (0.45% latent, 0.05% revealed), tối đa một lúc sinh, không chịu Dẫn Tiên phẩm chất;
- Kiếm Cốt không ở birth pool cho đến khi weapon+effect xác định.

## 1. Luật trọng số áp dụng

**Trọng số xuất hiện, KHÔNG phải phẩm cấp và KHÔNG đồng nghĩa sức mạnh.** Mức đề xuất `10` (thường), `4` (ít gặp), `1` (hiếm/độc đáo). Mỗi ID được chọn theo `weight / sum(eligible_weights_of_same_nature)`, **sau** khi nature đã được chọn theo 50/30/20. Nếu một ID không hợp lệ do conflict hay nguồn event chưa sẵn sàng, phải tái tính tổng trên pool hợp lệ và lưu kết quả; không rút lại nature một cách ngầm định. Trường hợp pool nature rỗng là **lỗi dữ liệu/gate** phải kiểm tra, không thay bằng Trait giả.

**Nature**: H=Hữu Ích, S=Song Diện, B=Bất Lợi.

**Readiness**: Các tên có `consumer_gated` hoặc hệ số mới từ Chapter 26 chỉ là birth-ID direction khi được user chốt; **hiệu ứng** chưa có consumer không được bật. Tên cần kinh nghiệm đời người như `Thương Binh Kinh Nghiệm` nên thiết kế **hậu thiên** (không tự xem sinh 14 tuổi đã từng trải qua chấn thương). `Cuồng Công` và các trait hai mặt thiếu hậu quả thực tế **không được kích hoạt** dù danh tính có thể được lưu sau khi birth eligibility được duyệt.

## 2. Đề xuất 101 Trait theo từng nature

| ID hiển thị | Nguồn | Nature | Trọng số V1 | Lưu ý |
|---|---|---|---:|---|
| Ham Học | Gốc | H | 10 | Giữ hướng có trong spec gốc |
| Nhất Tâm | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Trí Nhớ Sâu | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Suy Diễn | Gốc | S | 4 | Giữ hướng có trong spec gốc |
| Học Nhanh Làm Ẩu | Gốc | S | 4 | Giữ hướng có trong spec gốc |
| Chậm Mà Chắc | Gốc | S | 4 | Consumer / nhược điểm chưa đủ |
| Tạp Niệm | Gốc | B | 10 | Giữ hướng có trong spec gốc |
| Khó Tiếp Thu | Gốc | B | 10 | Giữ hướng có trong spec gốc |
| Kinh Mạch Ổn Định | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Kinh Mạch Mong Manh | Gốc | B | 10 | Giữ hướng có trong spec gốc |
| Ngộ Tĩnh | Gốc | H | 1 | Giữ hướng có trong spec gốc |
| Tâm Tĩnh Như Thủy | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Nóng Vội Cầu Thành | Gốc | S | 4 | Consumer / nhược điểm chưa đủ |
| Cần Mẫn | Gốc | H | 10 | Giữ hướng có trong spec gốc |
| Cuồng Công | Gốc | S | 4 | Consumer / nhược điểm chưa đủ |
| Lười Nhác | Gốc | B | 10 | Giữ hướng có trong spec gốc |
| Cẩu Thả | Gốc | S | 10 | Giữ hướng có trong spec gốc |
| Tỉ Mỉ | Gốc | S | 10 | Giữ hướng có trong spec gốc |
| Tiết Liệu | Gốc | H | 4 | Consumer / nhược điểm chưa đủ |
| Phung Phí | Gốc | S | 4 | Consumer / nhược điểm chưa đủ |
| Đa Nhiệm | Gốc | H | 4 | Consumer / nhược điểm chưa đủ |
| Quen Tay | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Đổi Nghề Khó | Gốc | B | 10 | Giữ hướng có trong spec gốc |
| Bản Năng Chiến Đấu | Gốc | H | 1 | Giữ hướng có trong spec gốc |
| Linh Giác Sắc Bén | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Tâm Thần Kiên Cố | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Phá Giáp Cảm | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Hấp Tấp | Gốc | S | 10 | Giữ hướng có trong spec gốc |
| Huyết Chiến | Gốc | S | 4 | Giữ hướng có trong spec gốc |
| Bất Khuất | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Tâm Thần Bất Ổn | Gốc | B | 10 | Giữ hướng có trong spec gốc |
| Trì Trọng | Gốc | S | 10 | Giữ hướng có trong spec gốc |
| Thân Pháp Nhẹ Nhàng | Gốc | H | 10 | Giữ hướng có trong spec gốc |
| Phản Ứng Nhanh | Gốc | H | 10 | Giữ hướng có trong spec gốc |
| Lão Luyện | Gốc | H | 10 | Giữ hướng có trong spec gốc |
| Liều Mạng | Gốc | S | 10 | Giữ hướng có trong spec gốc |
| Thừa Thắng Truy Kích | Gốc | H | 1 | Giữ hướng có trong spec gốc |
| Ổn Trận | Gốc | H | 10 | Giữ hướng có trong spec gốc |
| Dược Tâm | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Hộ Tâm | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Hồi Nguyên | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Khí Huyết Khó Hợp | Gốc | B | 10 | Giữ hướng có trong spec gốc |
| Dược Lý Thông Thạo | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Thương Binh Kinh Nghiệm | Gốc | H | 4 | Đề xuất chỉ HẬU THIÊN |
| Cứng Đầu | Gốc | S | 10 | Giữ hướng có trong spec gốc |
| Hộ Trì Bản Năng | Gốc | H | 1 | Giữ hướng có trong spec gốc |
| Kiếm Cảm | Gốc | H | 1 | Giữ hướng có trong spec gốc |
| Thể Ngộ | Gốc | H | 1 | Giữ hướng có trong spec gốc |
| Pháp Cảm | Gốc | H | 1 | Giữ hướng có trong spec gốc |
| Kiếm Tâm Ổn Định | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Cận Chiến Lão Thành | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Pháp Ý Liên Miên | Gốc | H | 4 | Giữ hướng có trong spec gốc |
| Tạp Tu | Gốc | S | 10 | Giữ hướng có trong spec gốc |
| Tham Ăn | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Kén Ăn | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Cú Đêm | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Ngủ Nướng | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Mê Sạch Sẽ | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Bày Bừa | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Trộm Ăn Vặt | Mới | B | 10 | Consumer / nhược điểm chưa đủ |
| Mê Ngủ Trưa | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Mắt Nhìn Quặng | Mới | H | 1 | Đề xuất tính năng mới, consumer-gated |
| Khứu Giác Linh Thảo | Mới | H | 1 | Đề xuất tính năng mới, consumer-gated |
| Thích Thử Nghiệm | Mới | S | 4 | Consumer / nhược điểm chưa đủ |
| Đếm Từng Đồng | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Vừa Làm Vừa Hát | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Đổi Việc Như Thay Áo | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Hay Quên Dụng Cụ | Mới | B | 10 | Đề xuất tính năng mới, consumer-gated |
| Học Qua Thực Hành | Mới | H | 4 | Consumer / nhược điểm chưa đủ |
| Ngộ Đạo Lúc Quét Sân | Mới | H | 1 | Consumer / nhược điểm chưa đủ |
| Bế Quan Quên Ngày | Mới | S | 4 | Đề xuất tính năng mới, consumer-gated |
| Học Vẹt | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Trí Nhớ Cá Vàng | Mới | B | 10 | Đề xuất tính năng mới, consumer-gated |
| Mê Sưu Tầm Công Pháp | Mới | S | 4 | Đề xuất tính năng mới, consumer-gated |
| Nửa Đêm Tỉnh Ngộ | Mới | H | 1 | Đề xuất tính năng mới, consumer-gated |
| Sợ Đột Phá | Mới | B | 10 | Đề xuất tính năng mới, consumer-gated |
| Nghe Giảng Là Buồn Ngủ | Mới | S | 4 | Đề xuất tính năng mới, consumer-gated |
| Nhát Nhưng Chạy Nhanh | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Thù Dai | Mới | H | 4 | Đề xuất tính năng mới, consumer-gated |
| Đánh Hội Đồng | Mới | S | 4 | Đề xuất tính năng mới, consumer-gated |
| Chuyên Đánh Lén | Mới | S | 4 | Đề xuất tính năng mới, consumer-gated |
| Hò Hét Xung Phong | Mới | S | 4 | Đề xuất tính năng mới, consumer-gated |
| Giả Chết Tài Tình | Mới | H | 1 | Consumer / nhược điểm chưa đủ |
| Tay Nhanh Hơn Não | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Vấp Nhưng Không Ngã | Mới | H | 4 | Đề xuất tính năng mới, consumer-gated |
| Lắm Chuyện | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Hay Mách Lẻo | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Biết Tuốt | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Hay Gây Sự | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Thích Khoe | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Tốt Bụng Quá Đà | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Mê Làm Sư Huynh | Mới | S | 10 | Đề xuất tính năng mới, consumer-gated |
| Cãi Chày Cãi Cối | Mới | B | 10 | Đề xuất tính năng mới, consumer-gated |
| Lạc Đường Có Duyên | Mới | S | 1 | Đề xuất tính năng mới, consumer-gated |
| Nhặt Gì Cũng Mang | Mới | S | 4 | Đề xuất tính năng mới, consumer-gated |
| Đụng Gì Cũng Mở | Mới | S | 4 | Đề xuất tính năng mới, consumer-gated |
| Thính Tai | Mới | H | 4 | Đề xuất tính năng mới, consumer-gated |
| Xem Bản Đồ Ngược | Mới | B | 10 | Đề xuất tính năng mới, consumer-gated |
| Đi Đâu Cũng Đánh Dấu | Mới | H | 1 | Đề xuất tính năng mới, consumer-gated |
| Sợ Ma | Mới | B | 10 | Đề xuất tính năng mới, consumer-gated |
| Lì Đòn Khi Lạc Rừng | Mới | H | 4 | Đề xuất tính năng mới, consumer-gated |

**Tổng trọng số V1 theo nature (trước khi lọc điều kiện/loại hậu thiên):** H=169, S=335, B=140. Các tổng này **chưa** dùng trực tiếp để lấy xác suất nature; chọn nature theo đúng tỷ lệ 50/30/20, rồi mới chọn ID.

Mốc tỷ lệ ví dụ (chỉ để người dùng dễ hình dung): một Trait nature H, weight 10, nếu pool H chưa lọc có tổng 169, thì xác suất trên **một slot visible** là `50% × 10/169`; không phải `10%` hay `10/101`.

## 3. Phương án 24 Mệnh Cách congenital

Mệnh Cách chọn trong xác suất tổng 0.50%; weight chỉ là **trọng số có điều kiện bên trong 0.50%**, không làm các Mệnh phổ biến như Trait thường.

| Mệnh Cách | birth_weight V1 | Điều kiện nguồn/effect |
|---|---:|---|
| Đại Khí Vãn Thành | 3 | CORE/BREAKTHROUGH GATED |
| Hồng Trần Luyện Tâm | 3 | BREAKTHROUGH GATED |
| Phá Quân | 3 | COMBAT TIER GATED |
| Thất Sát | 3 | KILL EVENT GATED |
| Tham Lang | 2 | UNIQUE ELITE GATED |
| Thiên Sát Cô Tinh | 2 | PARTY COMBAT GATED |
| Gặp Dữ Hóa Lành | 3 | LETHAL/EVENT GATED |
| Thiên Quyến Hồng Phúc | 3 | LUCK EVENT GATED |
| Thôn Thiên | 1 | UNIQUE BOSS GATED |
| Vạn Pháp Quy Nhất | 2 | SKILL/PATH GATED |
| Kiếm Tiên Chuyển Thế | 1 | BIRTH OVERRIDE BLOCKED |
| Dược Vương Tại Thế | 2 | HEAL/ALLY-SAVE GATED |
| Tài Tinh Nhập Mệnh | 2 | WORK QUALITY GATED |
| Bách Kiếp Bất Diệt | 2 | CALAMITY EVENT GATED |
| Thiên Đố Anh Tài | 1 | LIFESPAN DOWNSIDE GATED |
| Túc Tuệ Chuyển Thế | 1 | FUTURE ONLY: REBIRTH |
| Đoạt Mệnh | 1 | FUTURE ONLY: HOSTILE FATE |
| Hậu Tích Bạc Phát | 2 | BREAKTHROUGH GATED |
| Nhất Niệm Sinh Vạn Pháp | 1 | COMBAT ECHO GATED |
| Tụ Bảo Mệnh | 2 | EXPEDITION REWARD GATED |
| Bách Nghệ Quy Tông | 2 | WORK XP/MILESTONE GATED |
| Tử Vi Đế Mệnh | 2 | CANONICAL TEAM LEADER GATED |
| Thiên Cơ Khả Khuy | 1 | EXPLORATION EVENT GATED |
| Thiên Công Khai Vật | 1 | CRAFT TRANSACTION GATED |

Tổng birth_weight V1 (nếu cả 24 eligible) = **46**. Một Mệnh weight 1 tương đương `0.50% × 1/46` cơ hội có đúng identity đó lúc sinh **khi pool đầy đủ**, gồm latent và revealed. Khi một số Mệnh bị chặn vì chưa có authority, pool giảm; phải phân phối lại **bên trong phần congenital 0.50%**, không tăng odds có Mệnh của cả nhân vật.

**Birth-package riêng:** `Kiếm Tiên Chuyển Thế` congenital revealed cần một `Sword-path` lịch sử khởi đầu deterministic theo `DESTINY_V2_SPEC`. Hiện số mốc/path history **chưa được duyệt**, vì vậy đề xuất `birth_weight=1` không có nghĩa được sinh vào runtime trước khi gói này hoàn tất. `Túc Tuệ Chuyển Thế` và `Đoạt Mệnh` cần hệ Ma/Hồn hoặc quái mang Mệnh có thật; không kích hoạt effect giả.

## 4. Xung đột bắt buộc giữ khi chọn nhiều Trait

- `Kinh Mạch Ổn Định` ↔ `Kinh Mạch Mong Manh`;
- `Cần Mẫn` ↔ `Lười Nhác`;
- `Cẩu Thả` ↔ `Tỉ Mỉ`;
- `Tiết Liệu` ↔ `Phung Phí`;
- `Hồi Nguyên` ↔ `Khí Huyết Khó Hợp`.

Những Trait thú vị **được phép cùng tồn tại** nếu không có xung đột thật, ví dụ `Cú Đêm` + `Ngủ Nướng`, hoặc `Mê Sạch Sẽ` + `Bày Bừa` để tạo tính cách trái khoáy.

**Ẩn vs hậu thiên:** latent xung đột với Trait được học sau đó không được lộ qua giao diện; khi lộ có trạng thái bị áp chế theo `TRAITS_V2_SPEC`. Không giải quyết bằng reroll.

## 5. Các cổng duyệt trước khi kích hoạt code DV2-01 full birth

1. User phê duyệt mức 10/4/1 và danh sách weight từng ID; **các số trên CHƯA khóa**.
2. Từng Trait/Fate phải có unique internal ID, nature, birth/hậu thiên eligibility, conflict set, status `ready / consumer_gated / future_only`, cách lộ và effect package tương ứng.
3. Bảng độ khó/vật phẩm mà Trait/Fate sửa phải dùng owner có thật; không dùng lore as effect.
4. V2 generator chỉ đọc các config đã phê duyệt và độc lập seed-domain; giữ nguyên các tỷ lệ Dẫn Tiên/Lục Duy.
5. Test 100K seed distributions, conflict/latent no-leak, eligible pool empty fail, replay save/load.
6. Chưa có toàn bộ nội dung hợp lệ thì **giữ V2 birth layer chưa khởi tạo hoặc bật một pool tối thiểu đã được phê duyệt riêng**, không tự roll mặc định đều.

**Status triển khai:** DV2-01A chỉ mới tạo envelope versioned/seed domains (opt-in, thử nghiệm Godot đã có focused PASS); chưa sinh/lưu 101 Trait hoặc 24 Mệnh trong hệ V2. 
