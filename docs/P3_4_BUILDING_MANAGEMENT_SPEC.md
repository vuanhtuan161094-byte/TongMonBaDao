# P3.4 — BUILDING MANAGEMENT / QUẢN LÝ CÔNG TRÌNH

Date: 2026-10-04  
Status: DESIGN LOCKED / IMPLEMENT ONLY AFTER P3.2 LIVE-MAP [8/8] + P3.3 WINDOWS GATE GREEN

## 0. Mục tiêu

P3.4 biến công trình trên map từ “bấm để đọc mô tả” thành **điểm điều hành tông môn thật**.

Trải nghiệm đích:

`chạm công trình -> xem trạng thái thật -> thấy ai đang làm -> phân/gọi người -> hệ simulation nhận lệnh -> nhìn đệ tử tự di chuyển và kết quả thay đổi trên map`.

P3.4 ưu tiên **gameplay quản lý**, không ưu tiên art/polish.

Không tạo BuildingState riêng chỉ để UI đẹp. Không fake queue, cấp công trình, capacity, production-per-minute hoặc buff nếu simulation hiện chưa có authority tương ứng.

---

# 1. Gate trước khi implement

Không code P3.4 runtime trước khi Windows chứng minh:

1. `Verify-P3-2-Female-StageA.cmd` có:
   `P3.2 LIVE MODULAR FEMALE MAP INTEGRATION TEST PASS`;
2. `Verify-P3-3-Disciple-Flow.cmd` xanh.

Nếu một gate fail, sửa gate đó trước. Không chồng thêm P3.4 lên lỗi chưa xác định.

---

# 2. UX chung

## 2.1. Tap building

Thay modal/dim P3.1 bằng **Building Operation Panel** cố định ở cạnh phải.

Khác panel đệ tử:

- rộng hơn vì có danh sách người + tài nguyên + action;
- target width khoảng **400–440 px**;
- map vẫn nhìn thấy và vẫn pan/zoom ở vùng còn lại;
- camera rail bên phải tạm ẩn khi panel mở;
- selected building có marker/highlight;
- tap building khác -> đổi panel ngay;
- tap disciple -> chuyển sang disciple summary P3.3;
- X hoặc tap vùng map trống -> đóng panel;
- không reset camera vô cớ.

Không dùng full-screen overlay cho thao tác thường ngày.

## 2.2. Skeleton panel

Mọi công trình dùng cùng khung:

1. tên công trình;
2. 2–4 chỉ số chính;
3. cảnh báo nếu có;
4. người liên quan;
5. hành động thật;
6. link tới màn sâu chỉ khi hệ đó thực sự cần.

Không bắt mọi building có cùng số nút.

---

# 3. Authority mapping

P3.4 chỉ đọc/gọi hệ thật:

- workforce / phân nhóm / lệnh trực tiếp:
  `WorkforceSystem`;
- nghỉ, thuốc, vật tư, sức chứa:
  `NeedsSystem`;
- tu luyện / tiến độ / sẵn sàng đột phá:
  `CultivationSystem`;
- luyện khí / recipe / vật liệu / item:
  `EquipmentSystem`;
- kho tài nguyên:
  `SectState` + equipment/technique/needs state;
- vị trí/hành động:
  `DiscipleState.current_action`, `region_id`;
- tiền:
  `SectState.treasury`;
- Linh Thạch:
  `SectState.spirit_stones`.

Presentation không sửa `current_action`, `region_id`, inventory hay production result trực tiếp.

---

# 4. Khu Khai Khoáng

## Người chơi thấy

- Thanh Thiết hiện có;
- số người đang `WORK_MINING`;
- thành viên `mining_crew`;
- với mỗi người:
  - tên;
  - thể lực;
  - cấp Khai Khoáng;
  - tiến độ chu kỳ hiện tại;
  - có thiên phú thợ mỏ hay không nếu trait đó là visible authority;
  - trạng thái hiện tại.

## Hành động

### `Phân vào Đội Khai Khoáng`

Gọi:

`WorkforceSystem.assign_group(state, disciple_id, "mining_crew")`.

Đây là phân công dài hạn.

### `Gọi khai khoáng ngay`

Gọi:

`WorkforceSystem.issue_command(... COMMAND_WORK, PROF_MINING ...)`.

Đây là lệnh trực tiếp có TTL hiện hữu.

### `Rút khỏi đội`

Gọi:

`assign_group(..., "")`.

Không tự ép người đó IDLE.

## Production thật

`WorkforceSystem.perform_work(PROF_MINING)` hiện:

- chu kỳ cơ bản 4 progress;
- hoàn thành cho XP nghề;
- sản xuất 1 Thanh Thiết;
- cấp nghề >= 3 sản xuất 2;
- tiêu hao thể lực theo hệ hiện hành.

UI chỉ hiển thị dữ liệu; không tự cộng Thanh Thiết.

---

# 5. Luyện Khí Đường

## Người chơi thấy

- người đang `WORK_FORGING`;
- thành viên `forge_hall`;
- cấp Luyện Khí từng người;
- tiến độ chu kỳ;
- `forge_support_points`;
- vật liệu:
  - Thanh Thiết;
  - Linh Mộc;
  - Tinh Lang Bì;
  - Yêu Đan;
- danh sách 5 recipe hiện có;
- recipe nào đủ/thiếu nguyên liệu.

## Hành động nhân sự

- `Phân vào Luyện Khí Đường` -> `assign_group(..., "forge_hall")`;
- `Gọi luyện khí ngay` -> `issue_command(COMMAND_WORK, PROF_FORGING)`;
- `Rút khỏi đội` -> `assign_group(..., "")`.

## Hành động chế tạo

P3.4 được phép expose craft thủ công vì authority đã tồn tại:

`EquipmentSystem.craft(state, recipe_id, list_for_sale)`.

Không thêm queue giả.

Khi craft:

- vật liệu bị trừ bởi `EquipmentSystem`;
- quality do RNG deterministic hiện có;
- `forge_support_points` được tiêu thụ theo authority hiện có;
- item sinh vào shop/storage theo chính lời gọi hệ thống.

UI phải báo rõ thiếu nguyên liệu thay vì disable im lặng.

---

# 6. Tu Luyện Đài

## Người chơi thấy

- ai đang `CULTIVATE` / `BREAKTHROUGH`;
- cảnh giới;
- tu vi hiện tại / mốc cần;
- thể lực;
- ai đã đầy tu vi;
- ai đủ điều kiện đột phá theo `CultivationSystem.can_breakthrough()`.

## Hành động

### `Gọi tu luyện`

Gọi:

`WorkforceSystem.issue_command(... COMMAND_CULTIVATE ...)`.

Không trực tiếp gọi `cultivate()`.

## Không làm

Không thêm nút `Đột phá ngay` trong P3.4.

Lý do: hệ lệnh hiện tại chưa có command breakthrough riêng; gọi `attempt_breakthrough()` trực tiếp từ UI sẽ bỏ qua nhịp action/AI hiện hành.

Có thể thiết kế command breakthrough ở phase gameplay riêng sau này nếu cần.

---

# 7. Đệ Tử Xá

## Người chơi thấy

- người đang `REST`;
- thể lực/HP;
- `lodging_capacity`;
- số đệ tử hiện tại;
- tình trạng quá tải;
- hệ số hồi phục hiện tại từ `NeedsSystem.rest_recovery_multiplier()`;
- vật tư `supply_stock`.

## Hành động

### `Gọi nghỉ`

`WorkforceSystem.issue_command(... COMMAND_REST ...)`.

### `Mở rộng +1 chỗ`

`NeedsSystem.expand_lodging(state, 1)`.

Authority hiện tại:

- tốn 8 supply/slot;
- tăng lodging capacity thật;
- cập nhật needs stats/event count.

Không tạo tiền/cost xây dựng mới ở presentation.

---

# 8. Dược Phòng

## Người chơi thấy

- người đang `HEAL`;
- danh sách người bị thương theo HP ratio;
- medicine stock / cap 60;
- supply stock;
- tổng medicine used / produced từ `needs_stats`;
- chính sách logistics hiện tại.

## Hành động P3.4

Có thể đổi priority logistics bằng:

`NeedsSystem.set_priority()`

với:

- Cân bằng;
- Ưu tiên thuốc;
- Ưu tiên vật tư.

## Không có nút `Đi chữa trị` trực tiếp

Hiện `WorkforceSystem` không có `COMMAND_HEAL`.

P3.4 không được tạo nút giả rồi tự đặt `current_action = HEAL`.

Nếu muốn Tông Chủ chủ động chỉ định trị thương, phải bổ sung command gameplay thật ở phase riêng và có test simulation trước khi nối UI.

---

# 9. Kho Tông Môn

## Người chơi thấy

Nhóm theo category thay vì dump một danh sách dài:

### Vật liệu luyện khí
Từ `forge_materials`.

### Tài nguyên công pháp
Từ `technique_materials`.

### Sinh hoạt
- medicine;
- supplies.

### Tiền tệ
- ngân khố;
- Linh Thạch.

### Trang bị
Đếm theo location:

- storage;
- shop;
- equipped.

Không invent warehouse capacity vì current state không có capacity authority.

## Action

P3.4 baseline ưu tiên read/manage, chưa cần inventory drag-drop.

Nếu expose item action thì chỉ dùng API thật:

- `EquipmentSystem.move_to_storage()`;
- `EquipmentSystem.move_to_shop()`.

---

# 10. Tông Môn Đại Môn

## Người chơi thấy

Danh sách đệ tử:

- ngoài tông;
- đang HUNT;
- TRAVEL;
- COMBAT;
- LOOT;
- RETURN_SECT;
- region hiện tại;
- HP/thể lực;
- supply stock của tông.

## Hành động

### `Triệu hồi`

`WorkforceSystem.issue_command(... COMMAND_RETURN_SECT ...)`.

Nếu người đang ngoài tông, simulation tự đi qua RETURN_SECT hiện hữu.

## Không làm

Không mở region/hunt assignment mới ngay trong P3.4.

`COMMAND_HUNT_REGION` đã tồn tại nhưng chọn vùng thuộc flow Thế Giới; tránh nhét world-map management vào building panel.

---

# 11. Tông Môn Đại Điện

Đây là nơi quản lý **chính sách tông môn**, không phải màn admin tổng hợp mọi thứ.

## Người chơi thấy

- đệ tử hiện tại / capacity;
- ngân khố;
- Linh Thạch;
- workforce policy;
- needs priority;
- equipment policy.

## Hành động thật

### Chính sách lao động

`WorkforceSystem.set_work_policy()`

- Cân bằng;
- Ưu tiên sản xuất;
- Ưu tiên tu luyện.

### Ưu tiên hậu cần

`NeedsSystem.set_priority()`

- Cân bằng;
- Ưu tiên thuốc;
- Ưu tiên vật tư.

### Chính sách trang bị

`EquipmentSystem.set_policy()`

- Cân bằng;
- Chiến đấu;
- Tiết kiệm.

Mọi nút phải gọi authority tương ứng. Không chỉ đổi text.

---

# 12. Dược Phòng / Kho / Đại Điện và logistics cũ

P1.6 logistics production hiện vẫn dựa vào combat/adventure role `ROLE_LOGISTICS`, trong khi P2.7 workforce profession là hệ riêng.

P3.4 **không được giả vờ hai hệ này đã hợp nhất**.

UI chỉ:

- đọc `needs_priority` và stock thật;
- cho đổi `NeedsSystem.set_priority()`;
- không gắn profession logistics mới vào Dược Phòng khi simulation chưa làm vậy.

Nếu sau này hợp nhất logistics profession, đó là gameplay phase riêng.

---

# 13. Status/cảnh báo cho building panel

Chỉ derive từ state thật.

Ví dụ:

- Khai Khoáng: `Không có người làm`;
- Luyện Khí: `Thiếu Thanh Thiết`;
- Đệ Tử Xá: `Quá tải chỗ nghỉ`;
- Dược Phòng: `Hết thuốc`;
- Đại Môn: `Có đệ tử HP thấp ngoài tông`;
- Tu Luyện Đài: `Có người đủ điều kiện đột phá`.

Không thêm notification event state riêng trong P3.4.

P3.5 mới làm world bubble/cue trên map dựa trên các điều kiện này.

---

# 14. Implementation order sau khi gate xanh

## P3.4A — Read-only building operation panel

- thay modal building hiện tại;
- 8 công trình đọc state thật;
- selected marker + switching + close;
- map/camera không regression.

Mục tiêu: **bấm đâu hiểu ngay công trình đang thế nào**.

## P3.4B — People management

- Mine/Forge: assign group + direct work;
- Cultivation: direct cultivate;
- Residence: direct rest;
- Gate: return sect.

Mục tiêu: **bấm công trình -> điều người -> actor tự đi theo action thật**.

## P3.4C — Real building/system actions

- Đại Điện policy controls;
- Đệ Tử Xá expand lodging;
- Dược Phòng needs priority;
- Luyện Khí craft recipe;
- Kho item storage/shop action nếu UI còn đủ gọn.

Mục tiêu: **công trình làm thay đổi game thật, không chỉ là màn thông tin**.

---

# 15. Contract tests

Dedicated P3.4 test phải chứng minh tối thiểu:

1. tap building mở fixed Building Operation Panel, không dim map;
2. panel switching giữ đúng selected building;
3. values đến từ real `SimulationState`;
4. Mine assign uses `WorkforceSystem.assign_group()`;
5. Mine/Forge immediate order uses `issue_command()`;
6. presentation không sửa `current_action` trực tiếp;
7. Cultivation order uses real command;
8. Residence expand consumes supply and raises real lodging capacity;
9. Main Hall policy buttons mutate real authority;
10. Forge craft consumes real material and creates real equipment item;
11. hidden/nonexistent capabilities are not fabricated;
12. Dược Phòng không có fake HEAL command;
13. building -> disciple switch works;
14. panel close/blank tap works without breaking pan/zoom;
15. P3.3 disciple flow remains green.

---

# 16. Không làm trong P3.4

- không building level system mới;
- không construction timer mới;
- không upgrade tree giả;
- không production queue giả;
- không warehouse capacity giả;
- không fake heal command;
- không world-region management trong Đại Môn;
- không rewrite workforce;
- không polish building art trước gameplay;
- không Character Creator expansion làm blocker.

---

# 17. Sau P3.4

P3.5 — Living Sect Cues:

- mệt;
- cần chữa;
- sẵn sàng đột phá;
- thiếu nguyên liệu;
- hoàn thành công việc;
- cảnh báo người ngoài tông nguy hiểm;

được derive từ state thật và hiện trực tiếp trên world/map để người chơi không phải mở từng panel mới biết chuyện gì đang xảy ra.
