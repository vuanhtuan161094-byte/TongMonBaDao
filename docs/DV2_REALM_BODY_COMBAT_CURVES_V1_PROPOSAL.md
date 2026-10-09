# DV2 — CÔNG THỨC CÔNG, THỦ, HP VÀ GIẢM SÁT THƯƠNG (BẢN CÂN BẰNG 1)

Ngày 2026-10-09.

**Status: NUMERIC BALANCE PROPOSAL / FIRST-STEP DESIGN IMPLEMENTATION — NOT YET USER-LOCKED; NO GAMEPLAY CODE; NO GODOT PASS.**

Tài liệu này đi **từ cấp độ Tu Vi/Luyện Thể đến chỉ số**, không thiết kế từ Đặc Chất. Những hệ số đề xuất ở đây là để có đường tăng chính xác, kiểm tra được và đưa người dùng duyệt; không sửa ngầm các luật V2 đã khóa trong:
- `docs/REALM_LADDER_V2_SPEC.md` (30×10 độc lập);
- `docs/BODY_CULTIVATION_V2_SPEC.md` (Body Core HP > DEF > ATK; không tiêu hao Thể Lực trong tông);
- `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md` (Tiềm Lực +0,05%/điểm);
- `docs/COMBAT_STATS_V2_SPEC.md` (14 stats, kháng hệ, thứ tự DEF/penetration/reduction, giữ tỷ lệ HP);
- `docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md`.

## A. Tọa độ gốc (đã khóa)

Mỗi đường tăng có riêng `realm_index = 1..30` và `floor = 1..10`; có thể quy đổi `global_floor = (realm_index-1)*10 + floor`. Không ép `TuViFloor == LuyenTheFloor`. Không lấy Tu Vi đang tích lũy (chưa lên tầng) làm sức mạnh tức thời, trừ buff/special rule đã thiết kế.

**Một đệ tử bẩm sinh bình thường bắt đầu ở Tu Vi Phàm Nhân tầng 1, Luyện Thể Phàm Thân tầng 1** *trong ví dụ đường tăng này*; phân bố cảnh giới khởi đầu Dẫn Tiên thực tế vẫn giữ compatibility P3.7C1 cho đến DV2-03.

## B. Cấu trúc công thức NUMERIC V1 — ĐỀ XUẤT

Đặt:

```text
G(r,f) = 1.65 ^ (r-1) × 1.03 ^ (f-1)
  với r thuộc [1,30], f thuộc [1,10].
```

Bảng nguồn gốc tại **cấp 1.1** của từng đường:

| Kênh | Realm Core ở Phàm Nhân 1 | Body Core ở Phàm Thân 1 | Lý do |
|---|---:|---:|---|
| Max HP | 100 | 90 | Thể tu tăng sức chịu đựng gần ngang hệ cảnh giới |
| Attack | 20 | 3 | Tu Vi là trục chính cho lượng Công, nhưng Thể tu vẫn có Công thật |
| Defense | 12 | 7 | Luyện Thể có giá trị Phòng Ngự rõ ràng |

Công thức tương ứng:

```text
RealmHP  = 100 × G(cultivation_realm, cultivation_floor)
RealmATK =  20 × G(cultivation_realm, cultivation_floor)
RealmDEF =  12 × G(cultivation_realm, cultivation_floor)

BodyHP   = 90 × G(body_realm, body_floor)
BodyATK  =  3 × G(body_realm, body_floor)
BodyDEF  =  7 × G(body_realm, body_floor)

TiềmLựcFactor = 1 + 0.0005 × CurrentTiềmLực

MaxHPCore = (RealmHP + BodyHP) × TiềmLựcFactor
AttackCore = (RealmATK + BodyATK) × TiềmLựcFactor
DefenseCore = (RealmDEF + BodyDEF) × TiềmLựcFactor

PrePercentOutput = Core + sum(valid unrelated flat sources)
Final = apply channel-specific additive-% + context + temporary + special rules
```

**Chú ý:** Tiềm Lực sửa kết quả tính lại từ hồ sơ hiện tại, KHÔNG phải cộng nguồn vĩnh viễn sau mỗi lần đột phá. Thanh kiếm `+100 Attack` cộng đúng +100 rồi mới xét các % ATK khác; nó không được tự phóng đại thành +100×TiềmLựcFactor.

**Bậc tăng:** mỗi tầng +3% phần Core của đường đang tăng; từ cùng một đường `r.10` sang `(r+1).1` Core tăng khoảng **26,46%**, khiến đột phá đại cảnh thật sự có ý nghĩa. Tỷ lệ này chỉ mô tả phần Core của **đường tiến triển tương ứng**, không có chuyện cả nhân vật tự tăng 26,46% khi chỉ một trong hai đường đột phá.

**Vai trò Luyện Thể tại hai đường bằng cấp:** Body cung cấp ~47,37% Max HP Core, ~36,84% DEF Core, ~13,04% ATK Core. Đúng hướng **sức chịu đựng > phòng ngự > tấn công**, trong khi người chuyên tu một đường vẫn được phép có ưu thế lớn trên chỉ số tương ứng.

**Cân bằng không khóa tùy tiện:** không tự thêm mốc x10 đặc biệt ở Nhân→Tiên→Thần. Bước sang đại cảnh 11 hoặc 21 vốn đã dùng cùng quy tắc +26,46% và cần vượt qua nội dung Độ Kiếp/Thần Kiếp riêng. Sau này nếu cần nhảy sức mạnh tại các cửa ải đó, chỉ sửa khi có số liệu PvE/monster benchmark và phê duyệt.

### B.1 Bảng kiểm tra các trường hợp (trước trang bị/trait/buff; Tiềm Lực=0 trừ dòng cuối)

| Tu Vi | Luyện Thể | Tiềm Lực | Max HP | Attack | Defense |
|---|---|---:|---:|---:|---:|
| 1.1 | 1.1 | 0 | 190 | 23 | 19 |
| 1.10 | 1.10 | 0 | 247.91 | 30.01 | 24.79 |
| 2.1 | 1.1 | 0 | 255 | 36 | 26.80 |
| 5.1 | 5.1 | 0 | 1,408.28 | 170.48 | 140.83 |
| 5.10 | 5.10 | 0 | 1,837.49 | 222.43 | 183.75 |
| 10.10 | 10.10 | 0 | 22,472.12 | 2,720.31 | 2,247.21 |
| 11.1 | 11.1 | 0 | 28,417.97 | 3,440.07 | 2,841.80 |
| 20.10 | 20.10 | 0 | 3,361,116.48 | 406,872.00 | 336,111.65 |
| 21.1 | 21.1 | 0 | 4,250,426.25 | 514,525.28 | 425,042.63 |
| 30.10 | 30.10 | 0 | 502,716,344.62 | 60,855,136.45 | 50,271,634.46 |
| 5.1 | 1.1 | 0 | 831.20 | 151.24 | 95.94 |
| 1.1 | 5.1 | 0 | 767.08 | 42.24 | 63.88 |
| 5.1 | 5.1 | 1,000 | 2,112.42 | 255.71 | 211.24 |

Các số được hiển thị làm tròn **chỉ ở bảng UI**, không làm tròn ở các tầng trung gian hay lưu derived base thành nguồn thật.

### B.2 Tiềm Lực và đặc điểm khác

- Người có Tiềm Lực 1,000 có Core HP/ATK/DEF ×1.50, nhưng phần +100 Công vũ khí độc lập.
- `Đại Khí Vãn Thành` có các ấn Hậu-Phát +8% **Realm + Body Core**/ấn, nếu active phải tham gia vào đúng Core và theo thứ tự/kiểu cộng % chuyên ngành đã khóa; không tạo chỉ số hậu thiên khác.
- Thiên phú nghề, Cơ Duyên, Mị Lực không tự cộng Công/Thủ/HP.
- Phẩm chất đệ tử từ Lục Duy không tự nhân các chỉ số.

## C. Phòng Ngự V1 — công thức ĐỀ XUẤT có thứ tự pháp lý đã khóa

**Cấp độ dữ liệu:** chỉ áp dụng cho damage packet có nguồn quy mô Công Kích và được skill định nghĩa là `affected_by_defense`. Fixed/true damage nếu hợp lệ phải được author trực tiếp, không lén cho hưởng.

```text
DEF_after_buffs_debuffs = max(0, target_derived_DEF_with_status)
DEF_effective = max(0, DEF_after_buffs_debuffs × (1 - valid_attacker_penetration))

K = 2 × max(0, attacker_current_attack)
if attacker_current_attack <= 0 then ordinary Attack-scaled direct damage = 0
ordinary_defense_factor = K / (K + DEF_effective)   [K>0]

post_defense_damage = eligible_predefense_damage × ordinary_defense_factor
post_defense_damage -> elemental matchup -> element resistance ->
                       independent damage reduction -> special incoming rules
```

`valid_attacker_penetration` được giới hạn hợp lệ để DEF không âm; ordinary 0..100%. % Xuyên Phòng chỉ giảm phần DEF đã xử lý, không phải độc lập nhân sát thương.

**Tác dụng mong muốn:** Khi DEF=0, không giảm sát thương. Khi DEF tăng không âm, kết quả giảm liên tục, không âm/không bao giờ chuyển thành hồi máu. Khi ATK mạnh hơn DEF, sát thương giảm ít hơn. Không có hard damage-cap/Defense stat split.

**Các ví dụ chưa crit/status/element:**

| Attack người đánh | Defense người chịu | Xuyên Phòng | Sát thương gốc (bằng Attack) | Sau Phòng Ngự |
|---:|---:|---:|---:|---:|
| 23 | 19 | 0% | 23 | 16.28 |
| 23 | 19 | 20% | 23 | 17.29 |
| 23 | 38 | 0% | 23 | 12.60 |
| 23 | 190 | 0% | 23 | 4.48 |
| 38 | 19 | 0% | 38 | 30.40 |
| 23 | 0 | 0% | 23 | 23.00 |

**Cân bằng gameplay có thật:** ATK vũ khí (sau khi vào current Attack) làm tăng cả lượng damage gốc và khả năng vượt Phòng Ngự theo tỷ lệ ATK/DEF. Đây KHÔNG phải chỉ số Xuyên Phòng riêng; cần kiểm tra khi cân bằng vũ khí. Nếu muốn vũ khí chỉ nhân damage mà không tương tác mitigation, đó sẽ là thay đổi design formula và cần báo riêng.

## D. Các trường hợp cần xử lý rõ trước khi code

1. **Tấn công tầm cực thấp so với DEF:** tỷ lệ sát thương nhỏ nhưng dương nếu ATK>0; không làm tròn sớm thành 0 theo từng sub-hit.
2. **ATK không dương:** ordinary ATK-sourced hit không tạo damage; không cho chia cho 0.
3. **Sát thương đặc biệt/fixed:** có tag rõ `ignore_defense`/non-scaling khi nội dung được cấp quyền; không mặc định miễn giảm DEF.
4. **Địch/boss:** cũng phải sử dụng ATK/DEF/Max HP thật, không còn monster `power` đánh qua `combat_power`; monster curve và boss scaling là **phần cần thiết kế riêng** trước khi chuyển hệ PvE.
5. **Khi Max HP vĩnh viễn đổi:** giữ `current_hp/new_max_hp` theo **tỷ lệ current HP/max HP cũ**, không hồi đầy miễn phí (đã được khóa ở Combat Stats V2).
6. **Số rất lớn:** dùng tính float64 trong khi tính, không làm tròn intermediate; giới hạn input `r∈[1,30], f∈[1,10]` là giới hạn của thang nội dung hiện tại, không phải cap lên Lục Duy.
7. **Hoàn trả FX:** tổng sát thương qua mỗi nguồn %/rule phải có provenance, không double-apply hoặc người hưởng buff bị cộng hai lần.
8. **Không tháo nguyên gốc hậu thiên:** phát triển từng tầng reconstructible, save only progress and sources; hiện trường V2 tính snapshot/caches on invalidation.

## E. Kết quả kiểm tra toán học (không phải Godot gate)

Kiểm tra toán học bằng JavaScript trên:
- 300 cặp mốc cùng bậc `RealmFloor=BodyFloor`: HP/ATK/DEF hữu hạn, tăng đơn điệu trong từng tầng và khi vượt major gate;
- nhiều cặp Attack–Defense từ cực nhỏ tới rất lớn: Defense không tăng damage, không gây damage âm;
- tăng Tiềm Lực có tác động đúng vào Core, **không vào cố định +100 Công**.

Các kiểm tra trên **PASS mức kiểm toán công thức**. Chưa chạy trong Godot, chưa test PvE, không phải BACKEND LOCKED.

## F. Chưa được phê duyệt

**Các hệ số mới** (1.65, 1.03; bảng 100/20/12 và 90/3/7; hằng số K=2×ATK) là **đề xuất cân bằng V1**, chưa được khóa chỉ vì tạo file.

Hướng xét duyệt tiếp theo:
- mức tăng giữa tầng/đột phá có đủ cảm giác mạnh không;
- lệch đường chuyên Tu Vi so với chuyên Luyện Thể có hợp lý không;
- một trận giữa hai nhân vật cùng cấp kéo dài theo nhịp kỹ năng dự định hay không;
- monster/boss stat curve, nhiều cấp độ map, tỉ lệ gặp boss và skill coefficient;
- con số lớn ở Tiên/Thần ảnh hưởng đọc UI và hiệu năng thế nào.

Nếu người dùng phê duyệt numeric V1, cập nhật authority trong `docs/COMBAT_STATS_V2_SPEC.md`, `docs/REALM_LADDER_V2_SPEC.md` và đăng ký một phase lập trình có Godot focused+cumulative gates; không coi đây là thiết kế Độ Kiếp/EXP/monster đã hoàn thiện.
