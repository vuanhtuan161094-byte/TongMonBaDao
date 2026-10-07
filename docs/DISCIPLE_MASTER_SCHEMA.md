# Tông Môn Bá Đạo — MASTER SCHEMA NHÂN VẬT

Date: 2026-10-07
Status: CANONICAL MASTER CONTRACT

Tài liệu này là nguồn duy nhất để trả lời: một đệ tử có những lớp nào, lớp nào được random, random khi nào, giá trị nào là cố định, giá trị nào phát triển được, và hệ nào được phép biến đổi bằng vật phẩm/cơ duyên.

Mọi phase nhân vật sau P2.8 phải đọc tài liệu này trước. Spec phase chỉ được chi tiết hóa một dòng trong master schema, không được tự tạo một mô hình nhân vật khác.

Companion authorities:
- `docs/DISCIPLE_V2_DESIGN_LEDGER.md` — locked decisions, provisional constants, future-but-not-implemented rules, reference lessons;
- `docs/DISCIPLE_V2_ROADMAP.md` — complete disciple-system map and preferred design order;
- `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md` — implemented lục-duy + Dẫn Tiên authority.

## Long-term nurture law

The player must be able to keep and develop one disciple for the entire game.

Canonical consequences:
- weak birth increases required time/resources but does not impose a universal final ceiling;
- every major growth/power layer should eventually have an explicit improvement/transformation route;
- immutable birth history is preserved separately from current permanent growth;
- no system may silently erase months of investment by rerolling hidden identity;
- rare birth remains valuable because it saves enormous time/resources and can create special combinations.

---

# 1. Luật sinh một con người

Chiêu Hiền/Tuyển thường/Nhân Duyên đều tạo **một con người hoàn chỉnh**. Không quay riêng một rarity rồi mới ráp nhân vật về sau.

Cùng `world seed + recruitment source + generation index` phải tạo lại đúng cùng hồ sơ.

Thứ tự canonical:

1. identity seed + recruitment source;
2. tên/chủng tộc/giới tính/xuất thân;
3. sáu thuộc tính nền;
4. Phẩm chất Đệ tử được SUY RA từ sáu thuộc tính nền;
5. personality core + behavioral biases;
6. Linh Căn: nguyên tố + số hệ + độ tinh thuần;
7. thiên phú nghề/bẩm sinh liên quan nghề;
8. Đặc Chất: visible + latent;
9. Huyết Mạch: có/không -> loại -> độ thuần -> trạng thái phát hiện;
10. Thể Chất: cấp cơ thể -> loại dị thể đặc biệt có/không -> latent transformation nếu có;
11. Thiên Mệnh latent nếu có;
12. tuổi + thọ mệnh nền;
13. cảnh giới/tiến độ khởi đầu;
14. derive HP/combat power/current capability từ các lớp trên.

**Combat power không được roll như identity độc lập.** Nó là kết quả của con người hiện tại.

Reveal/awakening không được reroll identity ẩn.

---

# 2. Bảng tổng — random, cố định, cập nhật

| Lớp | Sinh ban đầu | Cố định? | Có thể phát triển/đổi? | Cách thay đổi canonical |
|---|---|---|---|---|
| ID/profile seed | deterministic | Gần tuyệt đối | Không | Không reroll |
| Nguồn tuyển | do cách gặp nhân vật | Có | Không | lịch sử gốc |
| Tên hiển thị | random | Không hoàn toàn | Có | player đổi tên; identity không đổi |
| Chủng tộc | random/theo nguồn về sau; hiện Human | Gốc cố định | Chỉ đại biến đổi nếu game có | không đổi bằng training thường |
| Giới tính | random | Gốc cố định | Không bằng progression thường | identity |
| Xuất thân | random | Có | Không | lịch sử gốc |
| Tư Chất | random theo source | Birth snapshot cố định | Có, không hard cap | đan/vật phẩm cải căn, thiên tài địa bảo, cơ duyên, permanent growth hợp lệ |
| Căn Cốt | random theo source | Birth snapshot cố định | Có, không hard cap | đan/vật phẩm luyện thể, cải tạo cơ thể, bảo vật, permanent growth hợp lệ |
| Cơ Duyên | random theo source | Birth snapshot cố định | Có, không hard cap | khí vận, bảo vật, đại sự kiện, permanent growth hợp lệ |
| Thông Tuệ | random theo source | Birth snapshot cố định | Có, không hard cap | ngộ đạo, vật phẩm, cải tạo thần thức, permanent growth hợp lệ |
| Mị Lực | random theo source | Birth snapshot cố định | Có, không hard cap | vật phẩm, danh vọng/cơ duyên cải tạo permanent; trạng thái/title có thể buff hiệu dụng riêng |
| Tiềm Lực | random theo source | Birth snapshot cố định | Có, không hard cap | cải căn, đề thăng, đại cơ duyên, permanent growth hợp lệ |
| Phẩm chất Đệ tử | derived, không roll riêng | Không | Có thể tăng | tự recompute khi permanent foundation vượt ngưỡng |
| Personality core | random | Khá ổn định | Có thể biến chuyển lớn | biến cố đời người; không tăng XP thường |
| Risk/Spend/Survival bias | random quanh personality | mềm | Có thể dịch chuyển có giới hạn | kinh nghiệm sống/sự kiện/chính sách sau này |
| Active Goal | không phải innate rarity | Không | Thay đổi thường xuyên | hoàn cảnh, ký ức, mục tiêu cá nhân |
| Linh căn — số hệ/nguyên tố | random | innate ổn định | có thể biến dị/đổi cực hiếm | đại cơ duyên/cải tạo chuyên biệt; refine thường KHÔNG đổi hệ |
| Linh căn — độ tinh thuần | random | Không | Có | Linh Tủy/refinement; diminishing returns |
| Phẩm Linh căn | derived từ purity | Không | Có | purity vượt threshold |
| Biến dị Linh căn | latent random | identity ẩn cố định | reveal/awaken | điều kiện/refinement; không reroll |
| Profession talent bẩm sinh | random | khá ổn định | có thể thêm trait hiếm sau này | cơ duyên/đào tạo đặc biệt, không thay profession XP |
| Profession XP | 0/thấp khi sinh | Không | Có | thật sự làm nghề |
| Work preference | personality/life derived | Không | Có | trải nghiệm/chính sách/assignment |
| Đặc Chất visible | random | thường ổn định | có thể thêm/mất nếu event hợp lý | event lớn, tu luyện, thương tích, thành tựu |
| Đặc Chất latent | random từ seed | cố định trước reveal | reveal | lived-history threshold; không reroll |
| Huyết Mạch — có/không | random riêng | innate identity | Có thể được ban bằng vật phẩm/cơ duyên | Huyết Tinh/Truyền Thừa/Hoán Huyết sau này |
| Huyết Mạch — loại | random nếu có | gốc ổn định | Có thể tiến hóa/đổi cực hiếm | tiến hóa huyết mạch, dung/hoán huyết chuyên biệt |
| Huyết Mạch — độ thuần | random nếu có | Không | Có | Yêu Đan/bloodline essence/refinement |
| Huyết Mạch — phát hiện | random/điều kiện | Không | Có | lived history -> reveal |
| Huyết Mạch — thức tỉnh | false/true tùy nguồn đặc biệt sau này | Không | Có | tài nguyên + điều kiện; mới kích hoạt full effect |
| Thể Chất — cấp | random riêng | innate starting tier | Có thể thăng rất hiếm | thiên tài địa bảo/cơ duyên/cải thể; không tăng tự động chỉ vì Tôi thể |
| Thể Chất — loại đặc biệt | roll riêng, có thể none | innate identity | Có thể được ban/cải tạo | Đạo Thai/Bản Nguyên/vật phẩm/cơ duyên |
| Thể Chất — Tôi thể | 0 ban đầu | Không | Có | Yêu Đan/tài nguyên, training cơ thể |
| Thể Chất — latent transformation | random từ seed nếu applicable | cố định trước transform | transform | đủ điều kiện + tài nguyên; không reroll |
| Thiên Mệnh | latent random cực hiếm | identity ẩn | thức tỉnh/phân nhánh | đại sự kiện/cơ duyên; không XP thường |
| Tuổi | random theo source | Không | Tăng theo thời gian | simulation time |
| Thọ mệnh cơ sở | derived từ race/foundation | base ổn định | Không trực tiếp | gốc sinh học |
| Thọ mệnh tối đa hiện tại | derived | Không | Có | đại cảnh giới, thọ đan, bảo vật, huyết mạch/thể chất/thiên mệnh phù hợp |
| Cảnh giới | generated starting level | Không | Có | tu luyện + đột phá |
| Tu vi progress | generated nhỏ | Không | Có | tu luyện, chiến đấu, công pháp, buff hợp lệ |
| Luyện thể | generated/default | Không | Có | body training/công pháp/thể chất |
| Kiếm/Thể/Pháp path XP | 0/thấp | Không | Có | hành vi thực tế; không có fixed class |
| Công pháp đã học | acquired | Không | Có | học bí tịch, mastery, đổi active |
| Combat skills | acquired | Không | Có | học/mở khóa |
| Trang bị | acquired | Không | Có | loot/rèn/mua/equip/lock |
| Pháp bảo | acquired | Không | Có | tìm/nhận/truyền thừa; mastery riêng sau này |
| Inventory | runtime | Không | Có | loot/consume/trade |
| HP | runtime | Không | Có | combat/heal/rest |
| Stamina | runtime | Không | Có | action/rest |
| Injury | runtime future | Không | Có | combat/medical; khác HP |
| Mood | runtime future | Không | Có | sự kiện/quan hệ/life |
| Loyalty | runtime future | Không | Có | bổng lộc, trọng thương, thưởng phạt, quan hệ |
| Relationships | runtime | Không | Có | interaction/events/memory |
| Memories | runtime | Không | Có, lịch sử chỉ append/decay theo luật | sự kiện sống |
| Sect rank | organization | Không | Có | bổ nhiệm/thăng giáng |
| Work group | organization | Không | Có | player/AI assignment |
| Combat team/role | organization | Không | Có | player/AI assignment |
| Direct Sect Master order | runtime | Không | Có | player intervention |
| Wallet/contribution | runtime | Không | Có | economy/work/reward/spending |
| Current action/location | runtime | Không | Có liên tục | AI/command/schedule |

---

# 3. Sáu thuộc tính nền và Phẩm chất Đệ tử

Sáu trục canonical:

- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

## 3.1. Luật chung P3.7C1

P3.7 dùng **điểm lục duy mở, không hard cap**.

Khi sinh:
- roll Tổng Lục Duy Bẩm Sinh;
- chia tổng đó vào sáu trục;
- một stat ordinary nằm khoảng `floor(total/12)` đến `floor(total/2)`, tức khoảng 0,5x–3x trung bình sáu stat;
- Mệnh Cách/content hiếm về sau được phép phá envelope này.

Sau khi sinh:
- sáu stat tăng độc lập;
- không còn giới hạn phân bố;
- current value có thể lên hàng nghìn/hàng chục nghìn;
- birth snapshot được lưu vĩnh viễn để giữ lịch sử nhân vật;
- tăng hậu thiên không được rewrite birth snapshot.

Legacy P0–P2 factories vẫn có thể dùng normalized values để bảo toàn regression; không tạo một block lục duy song song.

## 3.2. Vai trò

- **Tư Chất** -> tốc độ Tu Vi nền; balance khởi đầu +0,25%/điểm.
- **Căn Cốt** -> tốc độ Luyện Thể; balance khởi đầu +0,20%/điểm.
- **Cơ Duyên** -> `RNG 0..9999 + Cơ Duyên - difficulty`; tier 6000/8500/9500/9900.
- **Thông Tuệ** -> EXP học/nghề/mastery; balance khởi đầu +0,15%/điểm.
- **Mị Lực** -> social power; Dẫn Tiên có recruitment curve/cap riêng.
- **Tiềm Lực** -> chất lượng stat growth từ Realm + Luyện Thể; balance khởi đầu +0,05%/điểm khi authority đó được triển khai.

Fixed-value consumable rewards remain fixed:
- đan +10.000 Tu Vi -> đúng +10.000;
- sách +X mastery/XP -> đúng +X;
- lục duy không tự nhân con số cố định đó trừ khi item/content nói rõ.

Các bonus phần trăm cùng tác động lên một progression channel dùng **cộng bonus trên base**, không nhân dây chuyền:
`final = base × (1 + bonus_A + bonus_B + ...)`.
Ví dụ Tư Chất, Linh Căn, trait, Công pháp cùng tăng tốc Tu Vi thì các phần bonus được cộng vào một channel trước khi áp lên base. Quy tắc này tránh nổ số khi đệ tử được nuôi rất lâu.

Các hệ số trên là balance constants có thể benchmark; vai trò và open-point architecture là canonical.

## 3.3. Phẩm chất Đệ tử

Phẩm chất hiện tại:

`Phàm Thường -> Xuất Chúng -> Thiên Kiêu -> Tuyệt Luân -> Nghịch Thiên`

Working total thresholds:
- <360;
- 360–599;
- 600–999;
- 1.000–1.799;
- >=1.800.

Phẩm chất:
- được SUY RA từ tổng current permanent six foundations;
- có thể đề thăng khi lục duy tăng;
- không cộng trực tiếp trang bị/cảnh giới/nghề/chức vụ;
- không thay thế Linh Căn/Huyết Mạch/Thể Chất/Thiên Mệnh.

Nghịch Thiên vẫn có long tail về Tổng Lục Duy; hai người cùng Nghịch Thiên có thể chênh tổng cực lớn.

Chi tiết Dẫn Tiên/quality distribution:
`docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`

---

# 4. Linh căn — ba roll độc lập chính

Khi sinh:

1. roll **số hệ/nguyên tố**;
2. roll **độ tinh thuần**;
3. roll **latent mutation** nếu hệ P2.10 bật.

Không dùng luật `đơn linh căn = luôn phẩm cao`.

Độ tinh thuần tăng được bằng refinement. Refinement thường không đổi số hệ.

Phẩm Linh căn được derived từ purity và thay đổi khi purity vượt ngưỡng.

---

# 5. Huyết Mạch — nhiều roll, nhưng vẫn thuộc một con người

Huyết Mạch không phải một character banner riêng.

Khi sinh character:

1. roll **có Huyết Mạch đặc biệt hay không**;
2. nếu có, roll **loại**;
3. roll **độ thuần ban đầu**;
4. roll/derive **đã được phát hiện hay còn ẩn**;
5. trạng thái **thức tỉnh** thường bắt đầu false.

Recruitment source thay phân bố nhưng không thay schema.

Sau sinh:

- reveal không reroll;
- awaken kích hoạt full mechanic;
- refinement tăng độ thuần;
- vật phẩm Huyết Tinh/Truyền Thừa có thể BAN Huyết Mạch cho người chưa có;
- cùng huyết mạch có thể tăng purity/awakening progress;
- huyết mạch khác không được silent overwrite; cần Hoán Huyết/Dung Huyết mechanic lớn.

---

# 6. Thể Chất — hai roll identity + progression

**Mọi người đều có CẤP THỂ CHẤT.**

Cấp canonical:

`Phàm Thể -> Linh Thể -> Huyền Thể -> Thánh Thể -> Thần Thể`

Đây là cấp nền cơ thể, random riêng.

Ngoài ra có roll riêng cho **loại dị thể đặc biệt**:

- none;
- Kiếm Cốt;
- Kim Cương Bá Thể;
- Hàn Âm Thể;
- Hỏa Linh Thể;
- Vô Cấu Đạo Thể;
- và content mở rộng sau này.

Ví dụ hợp lệ:

- `Thánh Thể + không dị thể`;
- `Phàm Thể + Kiếm Cốt`;
- `Thần Thể + Hàn Âm Thể`;
- `Huyền Thể + Vô Cấu Đạo Thể`.

Tên hiển thị nếu có dị thể: `Kiếm Cốt · Huyền Thể`. Nếu không có dị thể: chỉ `Huyền Thể`.

Sau sinh:

- `Tôi thể` là progression riêng, tăng stat thật;
- Tôi thể **không tự động** biến Phàm -> Linh -> Huyền -> Thánh -> Thần;
- thăng cấp thể chất cần major resource/cơ duyên riêng;
- vật phẩm `Đạo Thai/Bản Nguyên` có thể ban loại dị thể cho người chưa có;
- cùng loại có thể dùng cho nâng cấp/tăng cấp;
- khác loại không silent overwrite, cần Cải Thể mechanic.

---

# 7. Đặc Chất

Đặc Chất tách khỏi personality, nghề, huyết mạch và thể chất.

Có:

- visible positive;
- visible negative;
- latent;
- acquired/event traits về sau.

Latent trait được roll từ lúc sinh và chỉ reveal theo lịch sử sống; trước reveal không được tác động gameplay.

Acquired trait là ngoại lệ hợp lệ: ví dụ thương tích lớn, đột phá đặc biệt, thành tựu nghề có thể thêm trait mới nếu mechanic rõ ràng. Đây là **thêm do sự kiện**, không phải reroll trait latent cũ.

---

# 8. Thiên Mệnh

Thiên Mệnh là lớp hiếm nhất, chưa active full.

Canonical target:

- roll latent lúc sinh hoặc được ban bởi đại cơ duyên đặc biệt;
- có thể `none`;
- có tier/branch riêng;
- reveal/awakening không reroll;
- có thể thay đổi luật chơi chứ không chỉ +stat;
- không cộng thẳng vào Phẩm chất Đệ tử.

Chi tiết balance để phase Destiny triển khai sau map/life systems.

---

# 9. Cái gì RANDOM, và random như thế nào

## Random một lần khi sinh

Random bằng deterministic seeded stream:

- tên;
- giới tính;
- xuất thân;
- six foundation;
- personality/biases;
- root elements/count/purity;
- profession talents;
- traits visible/latent;
- bloodline presence/type/purity/detected state;
- physique grade + special type + latent transformation;
- latent Destiny;
- age;
- starting realm/progress.

Những giá trị ẩn vẫn được sinh **ngay lúc tạo character**.

## Không random lại sau load

Không dùng `field rỗng => reroll`.

Mọi subsystem phải có initialized marker hoặc canonical default để phân biệt:

- chưa tạo;
- đã tạo và kết quả hợp lệ là `none/empty`.

## Recruitment source chỉ bias distribution

- **Tuyển thường**: broad/common distribution;
- **Chiêu Hiền**: tốt hơn về một số guarantee/distribution nhưng vẫn tạo whole person;
- **Nhân Duyên**: bias unusual/rare combinations, fortune và identity kỳ lạ.

Nguồn tuyển không tạo schema khác nhau.

Exact % là balance data và có thể chỉnh bằng test distribution; nguyên tắc không đổi.

---

# 10. Hai gacha tách biệt

## A. Gacha Đệ tử / Chiêu Hiền

Roll **whole person** theo schema ở trên.

Không roll riêng `Thánh Thể character` hay `Chân Long character`.

Ví dụ kết quả là:

`Trần Mặc | Thiên Kiêu | Hỏa-Kim root 78% | Bạch Hổ Huyết 31% | Kiếm Cốt · Huyền Thể | trait ...`

## B. Gacha Kỳ Vật / Truyền Thừa

Roll **vật phẩm cải tạo**, không roll người.

Nhóm item:

- Huyết Tinh / Chân Huyết / Bản Nguyên -> ban/nâng Huyết Mạch;
- Đạo Thai / Linh Thai / Cốt Nguyên -> ban/nâng/cải Thể Chất;
- Linh Căn vật phẩm -> refinement/mutation/cải căn nếu item cho phép;
- Thiên tài địa bảo -> permanent foundation hoặc thọ mệnh nếu mechanic rõ;
- truyền thừa/công pháp/pháp bảo hiếm.

Item gacha không được silently reroll innate identity. Nó tạo một **biến đổi có chủ đích** và phải được ghi lịch sử.

---

# 11. Cái gì FIXED, cái gì UPDATE — quy tắc ngắn

### Fixed identity

ID, source, origin history, seed, race/sex gốc, latent rolls đã sinh, event history.

### Mostly innate but improvable rarely

Six foundation, root composition, bloodline identity, physique grade/type, Destiny.

### Normal progression

Realm, cultivation, body training, path XP, techniques/mastery, combat skills, profession XP, equipment mastery, contribution, money, relationships.

### Living state

HP, stamina, injury, mood, loyalty, location, action, schedule, command, inventory.

### Derived, không roll trực tiếp

Disciple quality, root quality tier, combat power, many UI ratings/suitability scores.

---

# 12. Quy tắc không được phá

1. Một nhân vật = nhiều trục độc lập, không một rarity quyết định hết.
2. Same seed/source/index = same person.
3. Hidden identity sinh trước reveal.
4. Reveal không reroll.
5. `none`/empty có thể là kết quả hợp lệ, không phải lỗi.
6. Combat power là derived, không phải identity roll đầu tiên.
7. Phẩm chất Đệ tử khác Phẩm Linh căn, cấp Thể Chất, Huyết Mạch, quality trang bị.
8. Huyết Mạch và Thể Chất được phép cùng cộng Công/Thủ/Tu/etc.
9. Ordinary training không được tự biến innate rare identity thành thứ khác; mutation cần mechanic/resource/event rõ.
10. Item gacha thay đổi character bằng action explicit, không ghi đè lặng lẽ.
11. Profession, sect rank, work group và combat role là bốn khái niệm khác nhau.
12. Không fixed class; Kiếm/Thể/Pháp identity sinh từ path history.
13. Mỗi layer phải có gameplay consequence thật khi active.
14. Exact probabilities là balance data có test phân bố; không dùng lore thay cho xác suất.
15. Trước khi triển khai thêm subsystem nhân vật, cập nhật master schema nếu design thay đổi.

---
