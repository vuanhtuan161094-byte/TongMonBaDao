# P2.3 — Tàng Kinh Các, Công Pháp, Mảnh, Học và Nâng Cấp

Status: IMPLEMENTED / AWAITING RUNTIME GATE

## Mục tiêu

P2.3 biến công pháp thành một vòng kinh tế và phát triển nhân vật có hậu quả thật:

`farm -> mảnh/nguyên liệu/linh thạch -> ghép hoặc gacha -> quyển công pháp -> lưu/bán -> học -> tu thành thạo -> dùng nguyên liệu nâng cấp -> thay đổi tu luyện/đột phá/chiến đấu`.

Không có công pháp chỉ để hiện tên/phẩm.

## 1. Quyền sở hữu công pháp

Có hai trạng thái khác nhau:

- **Quyển công pháp hoàn chỉnh**: vật phẩm hữu hạn trong kho tông môn, có thể bán hoặc dùng để lưu;
- **Bản lưu Tàng Kinh Các**: quyền truyền dạy vĩnh viễn, không bị tiêu hao khi nhiều đệ tử học.

Gacha hoặc ghép mảnh tạo **quyển hoàn chỉnh**, không tự động lưu.

Người chơi phải chọn:

- bán quyển lấy linh thạch tông môn; hoặc
- tiêu một quyển để lưu vào Tàng Kinh Các.

Chỉ công pháp đã lưu mới được dạy cho đệ tử.

## 2. Hai nguồn công pháp

### Gacha do người chơi thực hiện

- giá: 100 linh thạch tông môn/lần;
- dùng RNG riêng theo `seed + gacha_index`;
- không tiêu thụ RNG combat, tuyển người hay linh căn;
- kết quả là một quyển công pháp hoàn chỉnh.

### Farm tự động bởi đệ tử

Sau chiến thắng, P2.3 dùng RNG riêng theo seed/tick/disciple/combat index để có thể sinh:

- linh thạch cá nhân;
- nguyên liệu nâng công pháp;
- mảnh công pháp.

Vật phẩm đặc biệt nằm trong hành lý cho tới khi đệ tử về tông môn. Khi về:

- linh thạch vào túi cá nhân;
- mảnh vào kho mảnh tông môn;
- nguyên liệu vào kho nguyên liệu tông môn;
- đệ tử nhận Cống hiến từ mảnh/nguyên liệu nộp về.

Mảnh đủ số lượng có thể ghép thành một quyển hoàn chỉnh. Quyển ghép được cũng có thể bán.

## 3. Linh thạch và Cống hiến

P2.3 có hai túi linh thạch cùng một loại tài nguyên:

- **linh thạch tông môn**: dùng để gacha;
- **linh thạch cá nhân**: đệ tử farm được và dùng để trả học phí.

Khi học công pháp:

- Cống hiến cá nhân bị tiêu hao;
- linh thạch cá nhân chuyển vào kho linh thạch tông môn.

Do đó học công pháp đồng thời tạo lại một phần nguồn gacha cho tông môn.

Gacha là sink của linh thạch tông môn. Bán quyển công pháp là source từ thị trường bên ngoài. Hai source/sink này được khai báo rõ và không liên quan tới money-conservation của P0.

## 4. Giới hạn học và công pháp đang dùng

Mỗi đệ tử học tối đa 3 công pháp trong P2.3.

Một thời điểm chỉ có **một công pháp đang dùng**. Chỉ công pháp đang dùng tạo hiệu ứng và nhận kinh nghiệm thành thạo khi TU LUYỆN.

Điều này làm các công pháp đã học khác vẫn có giá trị: người chơi có thể đổi công pháp đang dùng theo mục tiêu hiện tại, nhưng không được cộng dồn toàn bộ hiệu ứng.

## 5. Phẩm, hệ, thuộc tính và vai trò

Mỗi công pháp lưu sẵn các tag:

- phẩm: Phàm / Huyền / Địa / Thiên;
- hệ tu: Kiếm / Thể / Pháp;
- thuộc tính: Kim / Mộc / Thủy / Hỏa / Thổ;
- vai trò: Tu luyện / Công kích / Phòng thủ / Ổn định.

P2.3 chưa biến nhân vật thành class Kiếm tu/Thể tu/Pháp tu. Tag hệ được lưu ngay từ bây giờ để phase hệ-tu sau có thể suy ra đường phát triển từ lịch sử học/dùng công pháp mà không sửa schema công pháp.

## 6. Thuộc tính linh căn

P2.2 quality không đổi:

- Tạp: 0.75x tu vi, -8 điểm % đột phá;
- Phàm: 1.00x;
- Địa: 1.20x, +5 điểm %;
- Thiên: 1.45x, +10 điểm %.

P2.3 mới bổ sung thuộc tính Kim/Mộc/Thủy/Hỏa/Thổ vì từ đây chúng có tương tác thật với công pháp.

Số thuộc tính theo quality:

- Tạp: 3;
- Phàm: 2;
- Địa: 1;
- Thiên: 1.

Thuộc tính không cấm học. Khớp thuộc tính tăng tốc thành thạo và hiệu lực công pháp; không khớp chỉ giảm hiệu quả.

P2.2 factory vẫn không sinh thuộc tính, bảo toàn hành vi P2.2.

## 7. Thành thạo và nâng cấp

TU LUYỆN đồng thời:

- tăng tu vi theo P2.1/P2.2/P2.3;
- tăng XP công pháp đang dùng.

XP công pháp dừng ở ngưỡng nâng cấp, không tích vô hạn.

Cấp tối đa P2.3: 5.

Đủ XP chưa tự tăng cấp. Người chơi phải có nguyên liệu tông môn và chủ động nâng.

Nguyên liệu bản đầu:

- Linh Tủy;
- Huyền Thiết;
- Yêu Đan.

Chi phí tăng theo cấp hiện tại và theo công pháp.

## 8. Sáu công pháp mẫu

- Dưỡng Khí Quyết — Phàm / Pháp / Mộc / Tu luyện;
- Huyền Giáp Công — Huyền / Thể / Thổ / Phòng thủ;
- Liệt Chiến Quyết — Huyền / Thể / Hỏa / Công kích;
- Thanh Phong Kiếm Quyết — Địa / Kiếm / Kim / Công kích;
- Xích Viêm Chân Quyết — Địa / Pháp / Hỏa / Công kích;
- Hàn Nguyệt Tâm Pháp — Thiên / Pháp / Thủy / Ổn định.

## 9. Hậu quả mô phỏng bắt buộc

Tùy công pháp/cấp/độ hợp, công pháp đang dùng có thể thay đổi:

- lượng tu vi nhận khi TU LUYỆN;
- sức chiến đấu thực;
- sát thương nhận vào;
- xác suất đột phá;
- mức mất tu vi/HP/thể lực khi đột phá thất bại.

Do sức chiến đấu thực đã được DecisionSystem dùng để chọn vùng, công pháp công kích cũng có thể gián tiếp thay đổi khu vực AI dám đi.

## 10. Scale

- một kho tông môn, không có N x N;
- tối đa 3 công pháp học/đệ tử;
- chỉ công pháp active được tính hiệu ứng;
- lookup công pháp/material là O(1);
- farm drop là O(1) mỗi chiến thắng và dùng RNG tách biệt;
- gacha chỉ quét pool công pháp nhỏ, không quét dân số.

## 11. Gate P2.3

P2.3 chỉ được PASS khi:

1. toàn bộ P0 -> P2.2 gate PASS;
2. P22Factory vẫn technique-off và không sinh elemental root;
3. elemental root P2.3 deterministic;
4. gacha trừ đúng linh thạch, sinh manual và không làm đổi recruitment RNG;
5. manual có thể lưu hoặc bán; lưu không bị mất khi bán manual khác;
6. farm sinh nguồn đặc biệt và return/deposit đưa đúng tài nguyên vào đúng kho;
7. đủ mảnh ghép được manual và tiêu đúng mảnh;
8. học yêu cầu archived manual + contribution + personal spirit stones;
9. học chuyển linh thạch cá nhân vào tông môn;
10. giới hạn 3 công pháp được enforce;
11. matching element tăng mastery so với base;
12. mastery dừng ở ngưỡng và upgrade cần nguyên liệu;
13. upgrade tiêu nguyên liệu, tăng level, reset XP;
14. công pháp thật sự thay đổi cultivation/breakthrough/combat/defense;
15. save/load và deterministic continuation giữ nguyên toàn bộ P2.3 state;
16. invariants + P0 money conservation vẫn xanh;
17. scene P2.3 launch được trên Godot 4.7.2.

Authoritative command: `Sync-P2-3.cmd`.

## Chưa làm trong P2.3

- class/hệ tu cố định cho nhân vật;
- nhiều công pháp active đồng thời;
- kỹ năng chiến đấu riêng từng chiêu;
- ngộ tính/đạo ý;
- sư đồ/truyền công;
- đan dược/pháp bảo;
- real-money/premium gacha;
- pity/banner/event gacha;
- production art.
