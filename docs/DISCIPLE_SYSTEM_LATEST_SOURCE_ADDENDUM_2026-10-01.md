# Tông Môn Bá Đạo — Bổ sung nghiên cứu hệ Đệ tử từ ảnh/video mới

Date: 2026-10-01
Status: RESEARCH ADDENDUM / DOES NOT CHANGE P2.7 RUNTIME SCOPE

## Nguyên tắc

P2.7 đang ở trạng thái IMPLEMENTED / AWAITING RUNTIME. Các quan sát dưới đây được dùng để chuẩn hóa các phase sau, không nhồi ngược toàn bộ vào P2.7.

Khung vận hành vẫn là Evil Hunter Tycoon: đệ tử tự sống/tự làm/tự săn, Tông Chủ quản chính sách và can thiệp trực tiếp khi cần.

## 1. Sáu thuộc tính nền nên là sáu chức năng, không phải sáu biến cộng chiến lực

Ảnh nguồn cho thấy sáu trục có tác dụng khác nhau:

- Tư Chất: hiệu suất nhận tu vi/cảnh giới.
- Căn Cốt: hiệu suất luyện thể.
- Cơ Duyên: khí vận trong sự kiện/cơ duyên.
- Thông Tuệ: tốc độ học kỹ năng/chuyên môn.
- Mị Lực: quan hệ/xã giao với người khác.
- Tiềm Lực: mức tăng trưởng thuộc tính từ cảnh giới/luyện thể/công pháp.

Chuẩn hóa cho game mình:

- P2.7 chỉ kích hoạt `comprehension`/Thông Tuệ vì đang có consequence nghề thật.
- Không thêm các trục khác cho đến khi mỗi trục có consequence gameplay cụ thể.
- Có thể có một lớp **Phẩm chất đệ tử** để người chơi nhìn nhanh giá trị/tiềm năng tổng thể, nhưng gameplay/AI bên dưới vẫn đọc từng thuộc tính, trait, linh căn, nghề, cảnh giới, build và trạng thái thật.

## 2. Thương tích là một layer đời sống riêng, không chỉ HP thấp

Ảnh nguồn mô tả thương tích theo mức và giảm thuộc tính:

- nhẹ: giảm khoảng 10%;
- trọng thương: giảm khoảng 50%;
- nguy kịch: giảm khoảng 75%.

Bài học cho game mình:

- `hp` và `injury` nên tách.
- HP hồi đầy không nhất thiết xóa hậu quả thương tích ngay.
- thương tích có thể làm giảm combat, năng suất và khả năng nhận nhiệm vụ.
- về sau cần nơi trị thương/thời gian hồi phục/thuốc, để P1.6 medicine có thêm giá trị.

Không đưa hệ injury severity hoàn chỉnh vào P2.7.

## 3. Trung thành phải tạo quyền quản lý và hậu quả kinh tế

Ảnh nguồn cho thấy:

- trung thành có thể tăng theo thời gian;
- không chi trả bổng lộc làm giảm trung thành;
- trung thành quá thấp có thể khiến đệ tử không nhận phái đi hoặc không thực hiện nhiệm vụ sản xuất;
- trọng thương có thể làm giảm trung thành;
- ban thưởng vật phẩm có thể tăng trung thành.

Chuẩn hóa cho game mình:

- Loyalty không phải thanh trang trí.
- Khi triển khai, loyalty phải ảnh hưởng ít nhất: khả năng nhận lệnh, nguy cơ rời tông môn, hoặc hiệu suất/thái độ thực hiện nhiệm vụ.
- Rất phù hợp với kinh tế hiện có:

`sect treasury -> stipend/reward -> disciple wallet -> sect shop/service -> sect treasury`

- Đây là internal transfer nên tiếp tục tuân thủ closed-money invariant, trừ khi có source/sink bên ngoài được khai báo rõ.

Đề xuất triển khai sau khi workforce ổn định, không nhồi vào P2.7.

## 4. Linh căn nên có trade-off thật

Ảnh nguồn cho thấy linh căn phù hợp có thể đồng thời:

- tăng tốc tu luyện công pháp cùng hệ;
- tăng uy lực công pháp cùng hệ;
- số lượng linh căn ảnh hưởng hiệu suất/uy lực tu luyện.

Game mình hiện đã có spiritual roots và compatibility. Hướng mở rộng hợp lý:

- nhiều hệ linh căn = linh hoạt công pháp/build hơn;
- ít hệ nhưng tinh thuần = mạnh hơn trong hệ tương ứng;
- không khóa học tuyệt đối nếu không có lý do gameplay mạnh;
- hiệu ứng phải đi vào tốc độ tu luyện + hiệu quả skill thật, không chỉ điểm UI.

## 5. Đặc chất tốt/xấu phải có consequence rõ

Ảnh nguồn có ví dụ đặc chất xấu khiến:

- thời gian sản xuất tăng;
- sản lượng tài nguyên giảm.

Và có đặc chất tốt/thiên mệnh ảnh hưởng combat hoặc nghề.

Chuẩn hóa:

Tách ít nhất ba khái niệm:

1. `personality` — xu hướng hành vi;
2. `traits/quirks` — hiệu ứng đời sống/nghề, có thể tốt hoặc xấu;
3. `destiny` — đặc tính hiếm/quy tắc đặc biệt, thường tác động build sâu hơn.

Không nhét tất cả vào một mảng label chung.

Mỗi trait phải thay đổi một trong các thứ:

- tốc độ học;
- thời gian công việc;
- yield/chất lượng;
- stamina/mood cost;
- quyết định AI;
- combat consequence thật.

## 6. Destiny/Thiên Mệnh có thể là lớp build dài hạn

Video/ảnh cho thấy Thiên Mệnh mở thành nhiều hiệu ứng theo tầng/nâng bậc, ví dụ thay đổi phản kích, nhận hiệu ứng, tăng sát thương vật lý hoặc tạo cơ chế đặc biệt.

Game mình có thể học cả cấu trúc **hiếm + nâng bậc + mở hiệu ứng**, nhưng không để Thiên Mệnh thay thế toàn bộ identity đệ tử:

- một số đệ tử có `destiny_id` hiếm;
- destiny mở các modifier/quy tắc đặc biệt theo mốc trưởng thành hoặc tài nguyên đầu tư;
- không được chỉ cộng `combat_power`;
- phải tương tác với P2.4 path, P2.5 skill hoặc social/workforce về sau.

## 7. Công pháp, pháp bảo và trang bị là ba lớp riêng

Video cho thấy ba lớp rõ ràng:

- Công pháp: học/tu luyện, có nhiều slot;
- Pháp bảo: một object riêng có cơ chế tích lực/kỹ năng;
- Trang bị: weapon/armor/accessory build riêng.

Game mình hiện có:

- techniques;
- combat skills;
- equipment.

Hướng chuẩn hóa sau này:

- không biến artifact/pháp bảo thành `talisman equipment` đơn thuần nếu nó có cơ chế chủ động riêng;
- artifact nên có charge/trigger/skill riêng nếu triển khai;
- technique vẫn là nền tu luyện, equipment là vật phẩm đeo, combat skill là hành động chiến đấu.

## 8. Combat guide trong video: điểm đáng học, không copy nguyên

Video bổ sung cho thấy combat có các concept:

- tốc độ quyết định lượt/ưu tiên hành động;
- chọn mục tiêu công;
- trạng thái khiên hấp thụ sát thương;
- phản xạ trạng thái tiêu cực;
- tích lực pháp bảo;
- hiệu quả kỹ năng/trạng thái có nhiều modifier.

P2.5 đã có realtime deterministic combat nên không chuyển sang turn-based. Chỉ lấy các ý tưởng như mechanic candidates:

- shield state;
- reflect/debuff interaction;
- artifact charge;
- richer targeting policy.

Chỉ thêm từng mechanic khi có bài test consequence rõ.

## 9. Phẩm chất đệ tử là hệ thật và có thể đề thăng

Điều chỉnh quan trọng theo định hướng người dùng:

**Game phải có Phẩm chất đệ tử.** Đây là một lớp progression/rarity dễ hiểu cho người chơi và là động lực sưu tầm, tuyển người, nuôi người và nâng người.

Phẩm chất không phải chỉ là màu sinh ra một lần rồi khóa vĩnh viễn. Nó phải có khả năng **đề thăng** thông qua điều kiện/tài nguyên phù hợp.

Mô hình đề xuất:

- phẩm chất ban đầu được sinh ra từ nguồn tuyển/gacha/cơ duyên và tiềm năng nền;
- phẩm chất quyết định một số trần/tốc độ tăng trưởng/khả năng mở tiềm năng hoặc bonus nền;
- phẩm chất có thể tăng khi đạt đủ điều kiện như cảnh giới, tiềm lực, cơ duyên, tài nguyên hiếm, thành tựu, thiên mệnh hoặc nghi thức tông môn;
- đề thăng phẩm chất không được tự động biến mọi chỉ số thành giống nhau: hai đệ tử cùng phẩm chất vẫn khác nhau vì linh căn, nghề, trait, personality, build và lịch sử trưởng thành;
- đệ tử phẩm thấp vẫn có thể đáng giữ nếu có nghề/trait phù hợp, nhưng người chơi vẫn có lý do rất rõ để săn/tuyển/nuôi đệ tử phẩm cao.

Có thể dùng tier tương tự:

`Bình thường -> Xuất chúng -> Kiêu ngạo -> Tuyệt luân -> Nghịch thiên`

Tên tier cuối cùng sẽ chốt theo phong cách game sau; không bắt buộc sao chép nguyên nguồn.

AI không được đơn giản hóa thành `phẩm chất cao = luôn tốt hơn trong mọi việc`. Phẩm chất là một trục quan trọng, không phải trục duy nhất.

## 10. Tuyển đệ tử phải có nhiều con đường, bao gồm gacha

Điều chỉnh quan trọng: **game mình có gacha đệ tử**. Không loại bỏ gacha.

Các nguồn đệ tử nên cùng tồn tại để tạo nhiều kiểu chơi:

1. **Tuyển mộ thường** — ứng viên đến tông môn / chiêu mộ tại khu vực.
2. **Gacha/Chiêu Hiền** — tiêu tài nguyên/tín vật/linh thạch hoặc vé để gọi một lượt ứng viên, có xác suất phẩm chất/thiên phú hiếm.
3. **Nhân duyên/Cơ duyên** — gặp người đặc biệt qua sự kiện, expedition, cứu người, bí cảnh, quan hệ.
4. **Nhiệm vụ/Thế lực** — thu nhận đệ tử do nhiệm vụ, ngoại giao, quy phục hoặc chiến tích.
5. **Sư đồ/truyền thừa về sau** — hậu bối, người được tiến cử, đệ tử của trưởng lão.

Gacha nên tạo **niềm vui tuyển người**, nhưng không được làm các nguồn khác vô nghĩa.

Một lượt gacha tốt không chỉ là “ra màu cao”, mà có thể thú vị vì tổ hợp:

- phẩm chất;
- linh căn;
- thiên phú nghề;
- personality;
- trait tốt/xấu;
- destiny hiếm;
- cơ duyên đặc biệt;
- build tiềm năng.

Nhờ vậy có trường hợp:

- đệ tử phẩm cao nhưng trait xấu, không hợp nhu cầu hiện tại;
- đệ tử phẩm trung bình nhưng Luyện Khí kỳ tài, cực đáng giữ;
- đệ tử phẩm thấp có cơ duyên/Thiên Mệnh cho phép nuôi lên mạnh về sau.

Đây mới tạo loop săn người + nuôi người có chiều sâu.

## 11. Phẩm chất và các chỉ số chi tiết phải phục vụ hai tầng UI khác nhau

Tầng nhìn nhanh:

- tên;
- phẩm chất/màu;
- cảnh giới;
- linh căn nổi bật;
- nghề nổi bật;
- 1-2 trait chính;
- trạng thái hiện tại.

Tầng chi tiết:

- sáu thuộc tính nền;
- profession XP;
- trait/quirk;
- destiny;
- combat build;
- trang bị/công pháp/pháp bảo;
- loyalty/injury;
- quan hệ;
- lịch sử progression.

Như vậy người mới vẫn hiểu nhanh “ai ngon”, nhưng người chơi sâu vẫn có lý do soi từng đệ tử.

## 12. Hướng phase sau P2.7

Không khóa số phase cứng, nhưng thứ tự kiến trúc nên là:

1. P2.7 workforce/life foundation PASS trước.
2. Personal traits/quirks có consequence thật.
3. Injury/medical state nối P1.6.
4. Loyalty + stipend + reward/discipline nối economy.
5. Sect rank/position/authority.
6. **Disciple quality + quality promotion + expanded recruitment/gacha/cơ duyên**, nếu chưa được tách thành phase riêng sớm hơn.
7. Master-disciple/teaching.
8. Events/fortune/charisma.
9. Lifespan/death/inheritance khi pacing đã đủ ổn.
10. Artifact/destiny sâu hơn nếu combat/build cần.

## 13. Design target cuối

Mục tiêu không phải tạo một roster đầy số liệu. Mục tiêu là khi nhìn một đệ tử, player hiểu:

- người này sinh ra có gì;
- **phẩm chất hiện tại là gì và còn có thể đề thăng không**;
- hiện đã học được gì;
- giỏi việc gì;
- đang làm gì;
- quan hệ/trạng thái ra sao;
- vì sao họ có giá trị với tông môn;
- Tông Chủ có thể can thiệp ở đâu.

Game phải giữ nhịp đơn giản kiểu Evil Hunter Tycoon ở tầng vận hành, nhưng chiều sâu cá nhân phải đủ để tạo ba niềm vui đồng thời:

1. **săn/tuyển/gacha được đệ tử ngon**;
2. **nuôi một đệ tử bình thường thành người rất mạnh hoặc rất hữu dụng**;
3. **quản đúng người vào đúng vai trò trong tông môn**.
