# P3.2 — Asset Manifest

Date: 2026-10-03
Status: PREPRODUCTION — CHARACTER CREATOR V1 UPDATED

Mục tiêu: chuẩn bị đủ danh sách asset trước khi vẽ/generate để tránh làm từng ảnh rời rạc rồi phải sửa tỉ lệ/style nhiều lần.

**Character actor rule mới nhất:** bỏ hướng sản xuất 6 bộ nhân vật hoàn chỉnh có animation riêng. Map actor dùng `Character Creator = modular appearance + shared 2D rig/animation` theo `P3_2_MODULAR_ACTOR_SPEC.md`.

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

# 3. Map disciple actors — Character Creator V1

Production rule: map actor nhỏ, chibi trưởng thành, silhouette rõ, đọc được ở khoảng 60–75 logical px tại zoom map 1.0x. Không dùng profile portrait thu nhỏ.

## 3.1. Rig production order

Không làm 6 bộ `male/female sword/spell/body` riêng nữa.

Rig order:

1. `female_normal_v1` — vertical slice bắt buộc;
2. `male_normal_v1` — chỉ sản xuất sau khi female rig proof đạt;
3. `female_heavy_v1`, `male_heavy_v1` — future;
4. body type đặc biệt — future theo nhu cầu gameplay/art.

## 3.2. Canvas registration

Mọi map actor cutout:

- PNG alpha;
- canvas `128×128`;
- foot anchor `(64,104)`;
- không auto-crop;
- cùng perspective và cùng registration giữa mọi variant.

## 3.3. Female normal vertical slice

Tối thiểu:

- `body_01`;
- `face_01..02`;
- `hair_01..03`;
- `outfit_01..02`;
- `weapon_01..02`;
- `horn_01`;
- 3 hair tint preset;
- 3 outfit tint preset;
- shadow dùng chung;
- accessory/aura được phép empty ở proof đầu.

Body/Outfit là một lựa chọn trong Character Creator nhưng production bundle có thể gồm coarse cutout `head/torso/arm_l/arm_r/leg_l/leg_r`. Không tách mắt trái/phải, bàn tay, ngón tay hay giày thành lựa chọn riêng.

## 3.4. Shared animation minimum

Cho `female_normal_v1`:

- `idle_down/right/up/left`;
- `walk_down/right/up/left`.

`left` được phép mirror từ right nếu variant mirror-safe.

Sau khi proof đạt mới bổ sung:

- cultivate;
- work generic;
- mining;
- forging;
- rest;
- heal;
- combat-ready/leave.

Một rig dùng một AnimationLibrary chung. Không xuất spritesheet/video animation hoàn chỉnh riêng cho từng character combination.

---

# 4. Profile character art — batch D

Profile/portrait là pipeline riêng với map actor.

Không cần 50 nhân vật ngay.

P3.2 vertical slice cần 8 portrait/full-body gốc khi tới art pass profile:

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
- chi tiết cao hơn map actor;
- có thể đẹp/quyến rũ nhẹ khi phù hợp nhưng tasteful;
- không dùng glossy AI hero-art;
- costume gọn, silhouette sạch.

Không phóng map actor lên làm portrait.

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

## Sprint actor 0 — lock rig before art volume

Chỉ làm:

- `female_normal_v1` rig scene;
- shared idle/walk motion;
- 2 face;
- 3 hair;
- 2 outfit;
- 2 weapon;
- 1 horn;
- tint mask/preset;
- 6 combination proof trên cùng rig.

Gắn vào Godot, chụp/quan sát ở map zoom 0.75x/1.0x/1.35x. Chỉ khi registration + readability ổn mới mở rộng actor art.

## Sprint art 1 — prove visual language

Sau actor proof:

- 1 background ground plate;
- Đại Điện;
- Luyện Khí Đường;
- Kho;
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
- `male_normal_v1` nếu female vertical slice đã đạt.

## Sprint art 3 — disciple UI

- profile artworks;
- roster frames;
- tabs;
- foundation icons;
- HM/TC/root icons.

## Sprint art 4 — animation/VFX polish

Chỉ sau khi shared-rig proof đã đạt:

- cultivate;
- forge;
- mine;
- heal;
- rest;
- combat-ready;
- ambient map;
- notification VFX.

---

# 11. Acceptance rules

Một asset chỉ được coi là production-usable khi:

- nhìn rõ ở scale thật của game;
- cùng perspective với map;
- map actor đúng canvas/foot registration;
- không có chữ baked-in nếu chữ cần localization;
- có alpha sạch nếu transparent;
- không chứa watermark;
- không sao chép trực tiếp asset từ game tham chiếu;
- tên file ổn định;
- có source prompt/spec hoặc source drawing note để tái tạo biến thể;
- không phụ thuộc màu nền để nhìn được silhouette;
- hair/outfit tint không nhuộm nhầm da/mặt;
- variant dùng chung rig không cần animation riêng;
- weapon back/front không phá hướng nhìn;
- thiếu optional cosmetic không làm actor crash.
