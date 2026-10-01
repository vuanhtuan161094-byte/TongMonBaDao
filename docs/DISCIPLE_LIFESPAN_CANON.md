# Tông Môn Bá Đạo — Canon Thọ Mệnh Đệ Tử

Date: 2026-10-01
Status: CANONICAL DESIGN LOCK / IMPLEMENT AFTER P2.7 RUNTIME GREEN

## 1. Mục tiêu

Thọ mệnh là một lớp đời sống thật của đệ tử, không phải số trang trí.

Mỗi đệ tử có tối thiểu:

- `age` — tuổi hiện tại;
- `lifespan_max` — thọ mệnh tối đa hiện tại;
- `lifespan_base` — nền bẩm sinh từ chủng tộc/căn cơ;
- lịch sử các nguồn đã tăng/giảm thọ mệnh để deterministic và tránh cộng trùng.

Đệ tử chết vì đại hạn khi tuổi vượt thọ mệnh tối đa, trừ khi có mechanic đặc biệt hợp lệ cứu họ trước bước kiểm tra đại hạn.

## 2. Nguồn thọ mệnh

### Bẩm sinh

Thọ mệnh cơ sở chịu ảnh hưởng bởi:

- chủng tộc;
- một phần Căn Cốt/Thể Chất;
- Huyết Mạch đặc biệt nếu có;
- Thiên Mệnh đặc biệt nếu có;
- tuổi khởi đầu khi nhân vật được tuyển/gặp.

Phẩm chất không trực tiếp cộng thọ mệnh chỉ vì màu/tier cao.

### Tu luyện — nguồn tăng chính

Đột phá **đại cảnh giới** tăng thọ mệnh tối đa.

Nguyên tắc:

- tiểu cảnh giới chủ yếu tăng sức mạnh/tu vi, không nhất thiết tăng thọ;
- đại cảnh giới mới tạo bước nhảy thọ mệnh đáng kể;
- cảnh giới càng cao, bước nhảy thọ mệnh càng lớn;
- con số cụ thể sẽ cân bằng sau khi tốc độ thời gian game được khóa.

Vòng chơi mong muốn:

`tu luyện -> gần đại hạn -> cố đột phá -> thành công -> kéo dài thọ mệnh -> có thêm thời gian phát triển`.

### Đan dược

Có các nhóm đan/vật phẩm tăng thọ:

- thọ đan thường — cộng ít;
- thọ đan cao cấp — cộng nhiều hơn;
- thiên tài địa bảo kéo dài tuổi thọ;
- đan/vật phẩm đặc biệt có thể chữa tổn thọ hoặc khôi phục một phần thọ mệnh bị mất.

Chống spam:

- cùng một loại/nhóm thọ đan có diminishing return hoặc giới hạn hấp thu;
- không cho một loại đan rẻ biến thành bất tử;
- đan cấp cao phải phụ thuộc Luyện Đan, nguyên liệu hiếm, bí cảnh, giao dịch hoặc cơ duyên.

### Nguồn hiếm khác

Có thể tăng thọ mệnh bằng:

- Huyết Mạch thức tỉnh;
- Thể Chất tiến hóa;
- Thiên Mệnh;
- truyền thừa;
- thiên tài địa bảo;
- đại cơ duyên;
- bí cảnh/sự kiện đặc biệt;
- pháp bảo/đạo cụ đặc thù nếu có luật rõ.

Các nguồn này không được chỉ là modifier trang trí; phải ghi nhận vào state và persistence.

## 3. Tổn thọ

Một số mechanic tương lai có thể làm giảm thọ mệnh hoặc thọ mệnh tối đa:

- cấm thuật;
- cưỡng ép đột phá;
- thương thế/căn cơ bị tổn hại đặc biệt;
- nguyền rủa/độc đặc thù;
- hiến tế hoặc kỹ năng đổi mạng lấy sức mạnh;
- sự kiện thất bại lớn.

Tổn thọ khác HP và khác thương tích thường.

HP hồi đầy không tự hoàn lại phần thọ mệnh đã mất.

## 4. Đại hạn

Khi còn ít thời gian sống, đệ tử bước vào trạng thái `gần đại hạn`.

Hệ này phải tạo gameplay chứ không chỉ cảnh báo đỏ.

AI/Tông Chủ có thể ưu tiên:

- tăng thời gian tu luyện;
- tìm thọ đan;
- tìm thiên tài địa bảo;
- chuẩn bị đột phá;
- truyền nghề/công pháp cho đệ tử khác;
- bàn giao chức vụ;
- để lại pháp bảo/trang bị/truyền thừa;
- thực hiện nguyện vọng cuối hoặc cơ duyên đặc biệt về sau.

Tông Chủ vẫn có quyền phớt lờ và bắt người đó tiếp tục làm nhiệm vụ nếu muốn.

## 5. Thứ tự xử lý quan trọng

Nếu một đệ tử vừa đủ điều kiện đột phá đúng thời điểm gần chết vì đại hạn:

1. hoàn tất action/đột phá hợp lệ;
2. nếu đột phá thành công, cập nhật cảnh giới và tăng `lifespan_max`;
3. sau đó mới thực hiện kiểm tra đại hạn.

Điều này cho phép tình huống "đột phá phút cuối cứu mạng" một cách deterministic.

Không dùng random lại kết quả sau load.

## 6. Quan hệ với các hệ khác

### P2.1 Cảnh giới

Cảnh giới là nguồn tăng thọ mệnh chính.

Sau khi lifespan được triển khai, bảng realm phải có dữ liệu `lifespan_bonus` ở các đại cảnh giới phù hợp.

### Luyện Đan

Thọ đan tạo mục tiêu kinh tế và nghề nghiệp thật cho Đan Đạo.

Một Đan Sư giỏi có thể trở thành người cực kỳ quan trọng vì họ kéo dài thời gian sống cho trưởng lão/thiên tài trong tông môn.

### Huyết Mạch / Thể Chất / Thiên Mệnh

Các hệ này có thể thay đổi base lifespan, tốc độ lão hóa hoặc tạo rule đặc biệt, nhưng không mặc định tất cả loại hiếm đều tăng tuổi.

### Trung thành / Quan hệ / Sư đồ

Gần đại hạn có thể tạo event xã hội: truyền nghề, chọn người kế nhiệm, trao đồ, truyền công, chia tài sản, lời trăn trối.

### Phẩm chất

Phẩm chất không bằng tuổi thọ còn lại.

Một đệ tử Nghịch Thiên sắp hết tuổi vẫn là Nghịch Thiên; một đệ tử Phàm Thường uống thọ đan sống lâu không tự tăng phẩm chất.

## 7. Không làm ngay

P2.7 đang chờ runtime gate và không bị mở rộng scope.

Lifespan/death chỉ triển khai sau khi:

- workforce/life foundation đã ổn;
- thời gian simulation/game-year pacing được xác định;
- recruitment/generation V2 đã có tuổi/thọ nền;
- save/load cho disciple identity mới ổn định.

## 8. Design target

Mục tiêu cuối là tạo câu chuyện kiểu:

> Một trưởng lão luyện khí đã 176/180 tuổi, đột phá thất bại hai lần. Tông môn phải quyết định dùng viên Thọ Nguyên Đan duy nhất cho ông ta, hay giữ lại cho một thiên tài trẻ đang bị tổn thọ.

Hoặc:

> Một đệ tử bình thường được nuôi từ Ngoại môn, tới sát đại hạn mới phá cảnh thành công và sống thêm hàng chục/nhiều năm, sau đó trở thành trưởng lão của tông môn.

Thọ mệnh phải biến thời gian thành tài nguyên chiến lược và tạo lịch sử cá nhân, không chỉ là đồng hồ đếm ngược.