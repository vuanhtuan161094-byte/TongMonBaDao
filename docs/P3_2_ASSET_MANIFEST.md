# P3.2 — Asset Manifest

Date: 2026-10-01
Status: PREPRODUCTION

Mục tiêu: chuẩn bị đủ danh sách asset trước khi vẽ/generate để tránh làm từng ảnh rời rạc rồi phải sửa tỉ lệ/style nhiều lần.

---

# 1. Map environment — batch A

## Ground / environment

- `sect_ground_base_01` — nền sân/đất chính, seamless hoặc large plate;
- `sect_path_stone_01` — đường đá;
- `sect_path_dirt_01` — đường đất;
- `sect_river_01` — nước/suối;
- `sect_bridge_01` — cầu gỗ/đá nhỏ;
- `sect_wall_01` — tường thấp;
- `sect_gate_wall_segment_01`;
- `sect_tree_pine_01..03`;
- `sect_tree_bamboo_01..03`;
- `sect_rock_01..04`;
- `sect_lantern_01..02`;
- `sect_flower_patch_01..03`;
- `sect_lotus_pond_01`;
- `sect_cloud_fog_01..03` — overlay nhẹ.

Yêu cầu: palette xanh xám + nâu gỗ + vàng đồng, không quá cute.

---

# 2. Buildings — batch B

Mỗi công trình cần `base`, `selected/highlight`, `shadow`; VFX nhẹ nếu phù hợp.

1. `building_main_hall_01` — Tông Môn Đại Điện;
2. `building_residence_01` — Đệ Tử Xá;
3. `building_cultivation_01` — Tu Luyện Đài;
4. `building_warehouse_01` — Kho;
5. `building_forge_01` — Luyện Khí Đường;
6. `building_medicine_01` — Dược Phòng;
7. `building_mine_01` — Khu Khai Khoáng;
8. `building_gate_01` — Tông Môn Đại Môn.

### VFX/ambient

- `vfx_forge_smoke_01`;
- `vfx_forge_spark_01`;
- `vfx_cultivation_aura_01`;
- `vfx_medicine_steam_01`;
- `vfx_building_upgrade_01`;
- `vfx_resource_ready_01`.

---

# 3. Map disciple actors — batch C

Production rule: map actor nhỏ, đọc được silhouette, không dùng profile portrait thu nhỏ.

## Base variations

Tối thiểu 6 bộ để roster đầu không trùng hệt:

- nam kiếm tu;
- nữ kiếm tu;
- nam pháp tu;
- nữ pháp tu;
- nam thể tu/lao động;
- nữ thể tu/lao động.

## Animation minimum

Cho mỗi bộ:

- idle;
- walk/run;
- cultivate sitting;
- work generic;
- mining;
- forging;
- rest;
- heal;
- leave/ready.

Ưu tiên 4 hướng trước nếu 8 hướng quá nặng; architecture phải cho nâng lên 8 hướng sau.

---

# 4. Profile character art — batch D

Không cần 50 nhân vật ngay.

P3.2 vertical slice cần 8 portrait/full-body gốc:

1. Lâm Thanh Vũ;
2. Trần Mặc;
3. Bạch Nguyệt;
4. Lâm An;
5. Cố Trường Phong;
6. Triệu Linh Nhi;
7. V2 candidate male;
8. V2 candidate female.

Format mong muốn:

- transparent background;
- full/three-quarter body;
- pose đứng tự nhiên;
- đủ khoảng trống trên đầu/tay để crop nhiều UI ratio;
- mặt tương đối người thật hơn chibi map;
- costume gọn, silhouette sạch.

---

# 5. UI shell — batch E

## Panels

- `ui_panel_parchment_large_9slice`;
- `ui_panel_parchment_medium_9slice`;
- `ui_panel_parchment_small_9slice`;
- `ui_panel_dark_jade_9slice`;
- `ui_panel_tooltip_9slice`;
- `ui_panel_roster_9slice`.

## Buttons

- primary normal/pressed/disabled;
- secondary normal/pressed/disabled;
- icon round button normal/pressed;
- close button;
- plus button;
- claim/collect button.

## Tabs

- normal;
- selected;
- locked;
- notification state.

## Frames

Portrait frame by Disciple Quality:

- Phàm Thường;
- Xuất Chúng;
- Thiên Kiêu;
- Tuyệt Luân;
- Nghịch Thiên.

Không dùng cầu vồng neon; khác nhau bằng vật liệu/ornament + accent color.

---

# 6. HUD/resource icons — batch F

Core:

- tiền;
- Linh Thạch;
- Thanh Thiết;
- Linh Mộc;
- Yêu Đan;
- Linh Tủy;
- thuốc;
- supplies;
- contribution;
- recruitment token.

Actions:

- Đệ Tử;
- Kho;
- Công Trình;
- Thế Giới;
- Nhiệm Vụ;
- Chiêu Hiền;
- Kỳ Vật/Truyền Thừa future;
- Settings.

Status:

- làm việc;
- tu luyện;
- nghỉ;
- chữa trị;
- xuất chiến;
- sẵn sàng đột phá;
- cảnh báo;
- hoàn thành;
- thiếu tài nguyên;
- new/reveal.

---

# 7. Disciple screen icons — batch G

Foundation:

- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

Identity/progression:

- Linh căn;
- Huyết Mạch;
- Thể Chất;
- Đặc Chất;
- Công pháp;
- Trang bị;
- Pháp bảo;
- Nghề;
- Quan hệ;
- Ký ức;
- cảnh giới;
- HP;
- stamina.

Element:

- Kim;
- Mộc;
- Thủy;
- Hỏa;
- Thổ.

---

# 8. Building bubble icons — batch H

- collect;
- production complete;
- upgrade available;
- missing worker;
- missing material;
- event;
- breakthrough-ready;
- injury;
- storage full;
- idle worker.

---

# 9. Typography / localization rules

- ưu tiên font Việt rõ dấu;
- không dùng font thư pháp cho body text;
- thư pháp/chữ triện chỉ dùng title/accent nhỏ;
- body minimum trên 1280×720: khoảng 14–16 logical px;
- button target tối thiểu khoảng 44 logical px theo chiều ngắn;
- text phải chịu được tên tiếng Việt dài hơn nhãn Hán ngắn.

---

# 10. Production order

Không generate/vẽ tất cả cùng lúc.

## Sprint art 1 — prove visual language

Chỉ làm:

- 1 background ground plate;
- Đại Điện;
- Luyện Khí Đường;
- Kho;
- 1 nam map actor;
- 1 nữ map actor;
- parchment panel;
- top bar;
- primary button;
- 8 resource/action icons.

Gắn vào game, chụp 1280×720, đánh giá readability.

## Sprint art 2 — complete map

- 5 building còn lại;
- vegetation;
- river/bridge;
- action bubbles;
- actor variations.

## Sprint art 3 — disciple UI

- profile artworks;
- roster frames;
- tabs;
- foundation icons;
- HM/TC/root icons.

## Sprint art 4 — animation/VFX polish

- cultivate;
- forge;
- mine;
- heal;
- ambient map;
- notification VFX.

---

# 11. Acceptance rules

Một asset chỉ được coi là production-usable khi:

- nhìn rõ ở scale thật của game;
- cùng perspective với map;
- không có chữ baked-in nếu chữ cần localization;
- có alpha sạch nếu transparent;
- không chứa watermark;
- không sao chép trực tiếp asset từ game tham chiếu;
- tên file ổn định;
- có source prompt/spec hoặc source drawing note để tái tạo biến thể;
- không phụ thuộc màu nền để nhìn được silhouette.
