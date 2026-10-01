# Tông Môn Bá Đạo — Canon sinh Đệ tử và vòng đời thuộc tính

Date: 2026-10-01
Status: CANONICAL DESIGN LOCK / IMPLEMENT AFTER P2.7 RUNTIME GREEN

## 0. Nguồn và phạm vi

Tài liệu này tổng hợp những điểm quan trọng từ toàn bộ ảnh/video người dùng đã cung cấp về màn Đệ tử của `最强祖师`, cộng với các quyết định thiết kế riêng cho Tông Môn Bá Đạo.

### Quan sát trực tiếp được nguồn ảnh/video hỗ trợ

Ảnh/video cho thấy một đệ tử có các lớp độc lập:

- sáu thuộc tính nền: Tư Chất, Căn Cốt, Cơ Duyên, Thông Tuệ, Mị Lực, Tiềm Lực;
- chủng tộc, giới tính, lập trường, thọ nguyên, thương tích, trung thành;
- Linh Căn;
- Đặc Chất tốt/xấu;
- Thiên Mệnh;
- nhiều chuyên môn sản xuất có cấp/tiến độ riêng;
- cảnh giới/tu vi/luyện thể;
- công pháp/kỹ năng;
- trang bị;
- pháp bảo;
- chỉ số chiến đấu chi tiết;
- phẩm chất đệ tử được tổng hợp từ một nhóm giá trị nền và có thể đề thăng khi đạt ngưỡng;
- thương tích làm giảm thuộc tính theo mức;
- trung thành chịu tác động bởi bổng lộc, trọng thương, ban thưởng và có thể ảnh hưởng việc nhận/phục tùng nhiệm vụ;
- Linh Căn ảnh hưởng tốc độ tu công pháp cùng hệ và uy lực cùng hệ.

### Quyết định thiết kế thêm của game mình

Các hệ sau là chuẩn hóa riêng cho Tông Môn Bá Đạo; ảnh/video không chứng minh game nguồn có đúng y hệt:

- Huyết Mạch là một lớp riêng;
- Thể Chất là một lớp riêng;
- nguồn tuyển gồm tuyển thường, gacha/Chiêu Hiền, nhân duyên/cơ duyên, tiến cử, sự kiện;
- đệ tử tương lai được sinh ngẫu nhiên bằng seed, không viết tay từng nhân vật;
- một số Huyết Mạch/Thể Chất/Thiên Mệnh có thể ẩn và chỉ thức tỉnh về sau.

---

# 1. Nguyên tắc cốt lõi

Mỗi đệ tử là một cá thể được sinh ra từ **nhiều trục độc lập**, không phải một class và không phải một rarity quyết định tất cả.

Một đệ tử có thể đồng thời:

`Phẩm chất cao + chiến đấu trung bình + Luyện Khí cực giỏi + Huyết Mạch thường + trung thành cao`

hoặc:

`Phẩm chất thấp + Huyết Mạch hiếm ẩn + Cơ Duyên cao + nghề yếu + sau này thức tỉnh thành nhân vật mạnh`.

Mục tiêu là tạo ba niềm vui song song:

1. tuyển/gacha ra thiên tài và biết ngay mình vừa gặp hàng hiếm;
2. phát hiện một người tưởng bình thường nhưng có tổ hợp cực tốt ở nghề/build khác;
3. nuôi một người bình thường nhiều năm rồi đề thăng, thức tỉnh và trở thành đại năng.

---

# 2. Sáu nhóm thuộc tính theo nguồn gốc

## A. Bẩm sinh — sinh ra đã có

Được roll khi tạo đệ tử và giữ identity ổn định.

- Chủng tộc;
- giới tính;
- Tư Chất nền;
- Căn Cốt nền;
- Cơ Duyên nền;
- Thông Tuệ nền;
- Mị Lực nền;
- Tiềm Lực nền;
- Linh Căn ban đầu: nguyên tố + phẩm chất/độ tinh thuần;
- Huyết Mạch gốc, kể cả trạng thái ẩn;
- Thể Chất gốc, kể cả trạng thái ẩn;
- khí chất/tính cách lõi;
- một phần Đặc Chất bẩm sinh;
- Thiên Mệnh bẩm sinh hoặc latent nếu seed sinh ra có;
- thọ nguyên cơ sở theo chủng tộc/thể chất/cảnh giới khởi đầu.

**Bẩm sinh không có nghĩa là không bao giờ thay đổi.** Một số thứ chỉ thay đổi bằng cơ duyên/biến đổi hiếm, không tăng bằng luyện tập hằng ngày.

## B. Cố định gần như tuyệt đối — identity

Không dùng progression thông thường để thay đổi:

- ID nhân vật;
- nguồn gốc tuyển/gặp;
- chủng tộc gốc;
- giới tính sinh học của nhân vật trong simulation;
- lịch sử sự kiện đã xảy ra;
- seed/profile gốc dùng để tái hiện deterministic state.

Tên hiển thị có thể cho player đổi nếu muốn, nhưng không làm thay đổi identity gameplay.

## C. Rèn luyện được — tăng bằng quá trình sống bình thường

Đây là phần player nuôi mỗi ngày:

- cảnh giới/tu vi;
- luyện thể;
- Sword/Body/Spell path XP;
- công pháp đã học + mastery;
- combat skills;
- profession XP: Luyện Khí, Luyện Đan, Bồi Thực, Khai Khoáng, Hậu Cần, Phù, Trận...;
- kinh nghiệm chiến đấu;
- kỹ năng nghề;
- độ thành thạo pháp bảo sau này;
- đóng góp tông môn;
- quan hệ xã hội;
- tiền cá nhân.

Các giá trị này tăng chủ yếu vì **đệ tử thật sự làm việc/tu luyện/chiến đấu**.

## D. Ngộ ra / Thức tỉnh — không mua thẳng bằng XP thường

Có điều kiện, milestone hoặc sự kiện mới mở:

- thức tỉnh Huyết Mạch ẩn;
- thức tỉnh Thể Chất ẩn;
- Thiên Mệnh/nhánh Thiên Mệnh;
- biến dị Linh Căn hiếm;
- lĩnh ngộ công pháp/kỹ năng đặc biệt;
- đột phá nhận trait mới;
- lĩnh ngộ Đạo/ý cảnh về sau;
- chuyển biến tính cách lớn do sự kiện đời người.

Các hệ này phải tạo cảm giác "người này vừa thay đổi số phận", không phải một nút +1 quen thuộc.

## E. Nhặt được / Nhận được từ thế giới

Không thuộc cơ thể gốc của đệ tử:

- trang bị;
- pháp bảo;
- công pháp bí tịch trước khi học;
- đan dược;
- thiên tài địa bảo;
- vật phẩm thức tỉnh Huyết Mạch/Thể Chất;
- truyền thừa;
- chức vị/ấn tín;
- phần thưởng cơ duyên;
- tài sản cá nhân.

Nhặt được vật phẩm **không đồng nghĩa đã biến thành năng lực vĩnh viễn**. Ví dụ nhặt bí tịch chỉ cho quyền học; học rồi mới thành mastery cá nhân.

## F. Trạng thái sống — lên xuống liên tục

- HP;
- stamina;
- thương tích;
- đói/nhu cầu nếu active;
- mood/tâm trạng sau này;
- trung thành;
- vị trí;
- công việc hiện tại;
- lệnh Tông Chủ hiện tại;
- schedule phase;
- tiền trong ví;
- trạng thái bệnh/độc/buff/debuff;
- quan hệ hiện tại;
- rank/chức vụ/phân công tổ chức.

Đây không phải "chất lượng bẩm sinh" của người đó.

---

# 3. Sáu thuộc tính nền — canon game mình

## Tư Chất

- bẩm sinh là chính;
- quyết định tốc độ hấp thu tu vi/cảnh giới;
- có thể tăng vĩnh viễn nhưng chỉ qua tài nguyên/cơ duyên cực hiếm;
- không tăng chỉ vì ngồi tu lâu.

## Căn Cốt

- bẩm sinh là chính;
- ảnh hưởng luyện thể, HP/stamina tiềm năng và workload thể lực;
- có thể cải tạo bằng luyện thể cấp cao, thiên tài địa bảo hoặc Thể Chất biến đổi;
- tăng chậm và đắt.

## Cơ Duyên

- thiên hướng bẩm sinh;
- ảnh hưởng roll sự kiện, discovery, rare encounter, hidden opportunity;
- không farm XP trực tiếp;
- có thể thay đổi nhỏ do Thiên Mệnh, khí vận, đại sự kiện hoặc vật phẩm đặc biệt.

## Thông Tuệ

- bẩm sinh là chính;
- ảnh hưởng học nghề, hiểu công pháp, nghiên cứu/teaching về sau;
- P2.7 `comprehension` hiện tại là representation đầu tiên của trục này;
- có thể được cải thiện hiếm qua ngộ đạo/cơ duyên, không tăng chỉ vì làm nghề.

## Mị Lực

- bẩm sinh + biểu hiện xã hội;
- ảnh hưởng tuyển dụng, ngoại giao, quan hệ, teaching/social task về sau;
- có thể thay đổi hiệu quả bởi danh vọng, thương tích, title, item nhưng base không random lại.

## Tiềm Lực

- bẩm sinh là chính;
- quyết định trần tăng trưởng dài hạn của các thuộc tính phát triển;
- không phải combat power hiện tại;
- có thể được nâng bằng đề thăng phẩm chất, đại cơ duyên hoặc biến đổi căn cơ rất hiếm.

---

# 4. Phẩm chất Đệ tử — BẮT BUỘC CÓ và CÓ THỂ ĐỀ THĂNG

## 4.1. Vai trò

Phẩm chất là **nhãn tổng hợp về tầm vóc/tiềm năng nền**, để player đọc roster và gacha nhanh.

Phẩm chất KHÔNG thay thế:

- Linh Căn;
- Huyết Mạch;
- Thể Chất;
- Thiên Mệnh;
- nghề;
- cảnh giới;
- công pháp;
- tính cách;
- trang bị.

Một người phẩm thấp vẫn có thể cực kỳ quý vì một tổ hợp hiếm.

## 4.2. Tier đề xuất

Tên làm việc:

1. Phàm Thường
2. Xuất Chúng
3. Thiên Kiêu
4. Tuyệt Luân
5. Nghịch Thiên

Có thể đổi tên UI sau; semantic giữ nguyên.

## 4.3. Phẩm chất được tính từ đâu

Phẩm chất **chỉ nên dựa chủ yếu vào sáu thuộc tính nền/permanent growth**:

- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

Không tính trực tiếp:

- trang bị;
- cảnh giới hiện tại;
- profession XP;
- chức vụ;
- buff tạm thời;
- tiền;
- team role.

Lý do: như vậy một trưởng lão mặc đồ thần không "ăn gian" thành Nghịch Thiên; phẩm chất phản ánh con người, không phản ánh tài sản hiện tại.

Huyết Mạch/Thể Chất/Thiên Mệnh cũng **không nên cộng thẳng toàn bộ vào điểm phẩm chất**. Chúng là những trục hiếm độc lập, giúp một đệ tử phẩm thấp vẫn có lý do để được giữ và đầu tư.

## 4.4. Đề thăng phẩm chất

Phẩm chất có thể tăng khi tổng permanent foundation vượt ngưỡng mới.

Nguồn tăng permanent foundation:

- đại cảnh giới/milestone đặc biệt;
- cải tạo căn cơ;
- thiên tài địa bảo cực hiếm;
- Huyết Mạch/Thể Chất thức tỉnh nếu hiệu ứng thật sự cải tạo foundation;
- cơ duyên lớn;
- truyền thừa;
- sự kiện "thoát thai hoán cốt";
- một số Thiên Mệnh.

Không dùng "ăn 50 mảnh cùng nhân vật" làm con đường duy nhất.

Đề thăng phải là một câu chuyện/progression thật của nhân vật.

---

# 5. Linh Căn — bẩm sinh nhưng có thể tinh luyện

Khi sinh:

- roll tập nguyên tố;
- roll phẩm chất/độ tinh thuần;
- có thể là đơn linh căn, song linh căn, đa linh căn, tạp linh căn.

Trade-off canon:

- ít hệ = tinh thuần/chuyên sâu hơn;
- nhiều hệ = linh hoạt build/công pháp hơn;
- tương thích cùng hệ tăng tốc tu luyện + hiệu quả công pháp/skill thật;
- không nên cấm tuyệt đối cross-path nếu không cần thiết.

Có thể tăng/biến đổi bằng:

- tẩy luyện;
- thiên tài địa bảo;
- cơ duyên;
- bloodline/physique interaction;
- biến dị hiếm.

Không đổi nguyên tố tùy ý như respec miễn phí.

---

# 6. Huyết Mạch — bẩm sinh/ẩn, tăng bằng thức tỉnh và tinh luyện

## 6.1. Gốc

Huyết Mạch được roll khi nhân vật sinh/generate.

Có thể:

- không có Huyết Mạch đặc biệt;
- có Huyết Mạch đã hiện;
- có Huyết Mạch ẩn chưa phát hiện.

## 6.2. Độ thuần

Huyết Mạch có purity/progression riêng.

Ví dụ conceptual:

`12% -> 30% -> 55% -> 80% -> 100%`

## 6.3. Tăng bằng gì

- thức tỉnh qua sự kiện/cảnh giới;
- huyết tinh/tủy/thiên tài địa bảo phù hợp;
- bí cảnh/truyền thừa;
- dung hợp/biến dị có rủi ro về sau.

Không tăng bằng profession XP hay combat XP thông thường.

## 6.4. Hậu quả

Huyết Mạch phải tạo mechanic riêng, ví dụ:

- thay đổi HP/regen;
- trigger khi trọng thương;
- resistance;
- uy áp;
- affinity với một nhóm skill;
- mở transformation/skill/trait.

Không chỉ `+X% combat_power`.

---

# 7. Thể Chất — bẩm sinh hoặc hậu thiên biến đổi

Thể Chất khác Huyết Mạch.

- Huyết Mạch = nguồn gốc di truyền/dòng máu.
- Thể Chất = cấu tạo/cơ chế thân thể hiện tại.

Một người có thể:

- sinh ra Phàm Thể;
- sinh ra Linh Thể hiếm;
- về sau cải tạo thành thể chất mới;
- thức tỉnh thể chất ẩn.

Thể Chất ảnh hưởng:

- luyện thể;
- element/path affinity;
- HP/stamina;
- tốc độ/cost tu luyện;
- trạng thái đặc biệt;
- downside riêng nếu có.

Ví dụ design target:

`Hàn Âm Thể`: mạnh Băng/Thủy nhưng tích Hàn khí nếu không có công pháp phù hợp.

Tức thể chất tốt có thể có giá phải trả.

---

# 8. Thiên Mệnh — hiếm, quy tắc đặc biệt, có thể thức tỉnh/nâng tầng

Thiên Mệnh không phải personality và không phải trait thường.

- có thể roll từ đầu nhưng ở trạng thái ẩn;
- có thể được thức tỉnh bởi milestone;
- có thể có nhiều tầng;
- mỗi tầng nên thay đổi quy tắc thật.

Ví dụ:

- phản kích gây hồi HP;
- shield/debuff interaction;
- thay đổi combo skill;
- chuyển damage type;
- special work/social rule.

Không dùng Thiên Mệnh chỉ để cộng chỉ số thẳng.

---

# 9. Đặc Chất / Quái Tật / Tính Cách

## Personality

- lõi hành vi;
- ảnh hưởng quyết định AI;
- tương đối ổn định;
- có thể drift nhẹ sau các đại sự kiện, không reroll tùy ý.

## Traits/Quirks

Có hai nguồn:

- bẩm sinh;
- acquired từ đời sống/sự kiện.

Mỗi trait phải có consequence thật:

- thời gian sản xuất;
- yield;
- learning speed;
- stamina cost;
- risk appetite;
- social behavior;
- combat rule.

Trait xấu là hợp lệ và cần tồn tại.

---

# 10. Chuyên môn nghề — học được, KHÔNG phải bẩm sinh

Phân biệt rõ:

- `profession_talent` = thiên phú nghề, có thể bẩm sinh;
- `profession_xp/level` = tay nghề thật, phải làm việc mới tăng.

Một người có Luyện Khí kỳ tài nhưng chưa từng rèn:

`talent cao + forging level 0`.

Một người không có thiên phú nhưng làm mười năm:

`talent thường + forging level cao`.

Cả hai đều có giá trị theo cách khác nhau.

Đây là nguyên tắc bắt buộc để đệ tử có lịch sử sống.

---

# 11. Công pháp / Kỹ năng / Trang bị / Pháp bảo — bốn lớp khác nhau

- Công pháp: học và tu luyện -> mastery cá nhân.
- Combat skill: hành động chiến đấu độc lập.
- Trang bị: vật phẩm đeo, có thể mua/cấp/đổi.
- Pháp bảo: object riêng có charge/trigger/skill nếu triển khai.

Không gộp Pháp Bảo thành accessory thường nếu nó có cơ chế chủ động.

---

# 12. Trung thành / thương tích / thọ nguyên — trạng thái sống, không phải phẩm chất

## Trung thành

- thay đổi theo thời gian;
- bổng lộc, thưởng/phạt, quan hệ, trọng thương, đối xử ảnh hưởng;
- thấp có thể từ chối/không ưu tiên lệnh hoặc rời tông môn về sau;
- nối với wallet + treasury để tạo economy thật.

## Thương tích

- tách khỏi HP;
- nhẹ/trọng/nguy kịch làm giảm hiệu suất thực;
- cần trị liệu/thời gian/thuốc;
- HP đầy không tự xóa injury ngay.

## Thọ nguyên

- có base từ chủng tộc;
- cảnh giới/Thể Chất/Huyết Mạch/đan dược có thể kéo dài;
- tuổi và thọ nguyên không đưa vào loop chết/chuyển thế trước khi pacing được chứng minh.

---

# 13. Nguồn lấy Đệ tử — nhiều đường song song

Game phải có cả tuyển và gacha.

## 13.1. Tuyển mộ thường

- người tới xin nhập môn;
- Tông Chủ xem hồ sơ rồi nhận/loại;
- pool chịu ảnh hưởng danh vọng/cấp Tông Môn/khu vực.

## 13.2. Chiêu Hiền / Gacha

- dùng tài nguyên/tín vật/lệnh bài phù hợp game;
- roll một **cá thể hoàn chỉnh**, không roll chỉ một màu;
- phẩm chất cao hiếm hơn nhưng không đảm bảo nghề/build tốt nhất;
- duplicate character không phải trọng tâm vì nhân vật là procedural individual.

## 13.3. Nhân Duyên / Cơ Duyên

Ví dụ:

- cứu người trong bí cảnh;
- gặp cô nhi có Huyết Mạch ẩn;
- tán tu xin nhập môn;
- hậu nhân một gia tộc;
- người được trưởng lão tiến cử;
- đệ tử tự dẫn bạn/người thân về;
- truyền nhân của NPC;
- người bị truy sát được cứu.

Nguồn này có thể sinh tổ hợp hiếm mà gacha thường ít gặp.

## 13.4. Sự kiện/Truyện/Thế giới

Named/unique NPC có thể tồn tại, nhưng **đa số đệ tử không viết tay**.

---

# 14. Pipeline sinh đệ tử ngẫu nhiên — canonical

Mọi procedural disciple dùng deterministic seed.

Input tối thiểu:

`world_seed + candidate_sequence + recruitment_source + source_context`

Pipeline:

1. sinh identity: tên, chủng tộc, giới tính, tuổi/background;
2. sinh sáu thuộc tính nền;
3. derive phẩm chất ban đầu;
4. sinh Linh Căn;
5. roll Huyết Mạch: none / visible / latent;
6. roll Thể Chất: normal / special / latent;
7. roll core personality;
8. roll innate traits/quirks;
9. roll Thiên Mệnh: mostly none, some latent/visible;
10. roll profession talents;
11. sinh starting profession XP theo background, không nhầm với talent;
12. sinh starting cultivation/realm theo nguồn tuyển;
13. sinh starting techniques/equipment chỉ nếu background/source hợp lý;
14. sinh loyalty/relationship starting state theo nguồn;
15. persist toàn bộ result; **không reroll khi reload**.

Cùng seed + cùng source phải sinh đúng cùng cá thể.

---

# 15. Gacha không được biến thành "màu cao auto thắng"

Gacha cần tạo excitement nhưng roster vẫn phải có quyết định.

Một roll hiếm có thể mạnh vì:

- phẩm chất cao;
- Huyết Mạch hiếm;
- Thể Chất hiếm;
- Thiên Mệnh;
- Linh Căn cực hợp;
- trait nghề cực mạnh;
- background đã có mastery;
- tổ hợp synergy hiếm.

Không cần mọi thứ cùng xuất hiện trên một người.

Ví dụ:

### A — thiên tài chiến đấu

- Tuyệt Luân;
- Hỏa đơn linh căn;
- không Huyết Mạch đặc biệt;
- Kiếm thiên phú;
- nghề bình thường.

### B — nhân sự sản xuất quý

- Xuất Chúng;
- linh căn thường;
- Thông Tuệ rất cao;
- Luyện Khí kỳ tài;
- trait chăm chỉ;
- forging background cấp cao.

### C — sleeper

- Phàm Thường;
- combat hiện tại yếu;
- Huyết Mạch ẩn;
- Cơ Duyên cực cao;
- về sau sự kiện thức tỉnh tạo một câu chuyện riêng.

Cả ba đều có lý do để giữ.

---

# 16. Hidden information — discovery là một phần gameplay

Không phải mọi thông tin phải lộ ngay khi tuyển.

Có thể ẩn:

- Huyết Mạch;
- Thể Chất;
- Thiên Mệnh;
- một số trait;
- tiềm năng sâu;
- background secret.

Cách phát hiện:

- Quan Tinh/Trắc Linh/Khảo Hạch;
- cảnh giới đột phá;
- trọng thương;
- bí cảnh;
- sự kiện quan hệ;
- trưởng lão/nhân vật có năng lực giám định;
- vật phẩm kiểm tra.

Discovery phải deterministic theo state đã sinh; không được "roll lại bí mật" tại lúc reveal.

---

# 17. UI rule

Không nhồi tất cả lên một màn.

Màn tóm tắt cần thấy nhanh:

- Phẩm chất;
- cảnh giới;
- Linh Căn;
- 1-3 điểm nổi bật nhất;
- công việc/trạng thái hiện tại;
- thương tích/trung thành nếu có vấn đề;
- nghề mạnh nhất.

Tab sâu:

- Thuộc tính nền;
- Tu hành;
- Nghề;
- Trang bị/Pháp bảo;
- Huyết Mạch/Thể Chất/Thiên Mệnh;
- Quan hệ/Lịch sử.

Phẩm chất giúp scan roster; các trục chi tiết mới quyết định dùng người vào đâu.

---

# 18. Quy tắc implementation bắt buộc

1. Không viết tay từng đệ tử thường.
2. Procedural generation phải deterministic.
3. Không reroll khi save/load.
4. Tách `innate talent` khỏi `learned proficiency`.
5. Tách `quality` khỏi combat power.
6. Tách Huyết Mạch, Thể Chất, Linh Căn, Thiên Mệnh và trait.
7. Không cho equipment/rank buff làm tăng giả phẩm chất.
8. Phẩm chất có thể đề thăng bằng permanent foundation growth.
9. Hidden trait/bloodline/destiny được generate từ đầu; reveal chỉ mở thông tin.
10. Gacha/tuyển/cơ duyên dùng cùng một generator nhưng khác distribution/source rules.
11. Mọi modifier phải có consequence thật trước khi quảng bá trên UI.
12. P2.7 workforce vẫn phải runtime PASS trước khi bắt đầu implementation lớn của canon này.

---

# 19. Thứ tự triển khai sau P2.7

Không khóa số phase, nhưng dependency nên là:

1. P2.7 workforce/life runtime green.
2. Procedural disciple generator v2 + six base dimensions + Phẩm chất.
3. Recruitment sources: tuyển thường + Chiêu Hiền/gacha + Nhân Duyên source interface.
4. Traits/quirks + hidden reveal framework.
5. Linh Căn purity/refinement upgrade trên nền P2.2.
6. Huyết Mạch + Thể Chất.
7. Injury + medical loop.
8. Loyalty + stipend/reward loop.
9. Sect rank/authority.
10. Master-disciple/teaching.
11. Thiên Mệnh/Đạo/rare awakening.
12. lifespan/death/inheritance khi pacing đủ ổn.

Không xây tất cả một lúc.
