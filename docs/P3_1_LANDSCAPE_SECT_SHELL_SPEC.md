# P3.1 — Mobile ngang + Tông Môn Sống V1

Date: 2026-10-01
Status: ACTIVE IMPLEMENTATION SPEC

## 1. Mục tiêu

P3.1 là điểm chuyển từ simulation/backend sang **một game nhìn thấy được**.

Từ phase này, target presentation chính thức là **mobile landscape**. Base logical resolution: **1280×720**. Gameplay không còn thiết kế dọc 390×844.

UI/UX tham chiếu chính: **Ta Làm Tông Sư Trong Tiên Môn** ở cấp độ cấu trúc trải nghiệm:

- bản đồ tông môn chiếm phần lớn màn hình;
- top resource bar mỏng;
- chapter/task rail sát cạnh trái;
- các nút chức năng bám mép màn hình;
- thao tác công trình ngay trên map;
- popup/panel dạng giấy/cuộn thư phủ lên map;
- màn đệ tử có roster portrait dọc + nhân vật trung tâm + detail bên phải + tab chức năng.

Không sao chép asset, logo, icon, tranh, text hay map của game tham chiếu. Tông Môn Bá Đạo dùng asset/ngôn ngữ hình ảnh riêng nhưng giữ UX skeleton gần như vậy.

## 2. Luật authority

Simulation P0-P2.12 vẫn là authority.

Presentation P3.1:

- không tạo gameplay engine song song;
- không fake tài nguyên;
- không fake action đệ tử;
- map đọc `DiscipleState.current_action`, `region_id`, kho và workforce state thật;
- direct order trên UI phải gọi `WorkforceSystem.issue_command()` thật;
- map chỉ diễn giải state thành vị trí/animation.

## 3. Landscape contract

Project settings:

- viewport: `1280 × 720`;
- desktop override: `1280 × 720`;
- stretch: `canvas_items`;
- aspect: `expand`;
- handheld orientation: landscape.

Safe content target:

- top bar: y = 0..70;
- bottom action bar: y = 642..720;
- left task rail: x = 16..258, y = 90..460;
- main map remains visible behind all edge UI;
- central popup must leave map context visible around it.

## 4. Main map shell

Initial visible destinations/buildings:

1. Tông Môn Đại Điện;
2. Đệ Tử Xá;
3. Tu Luyện Đài;
4. Kho;
5. Luyện Khí Đường;
6. Dược Phòng;
7. Khu Khai Khoáng;
8. Tông Môn Đại Môn;
9. Sân trung tâm.

P3.1 uses original placeholder geometry/styles until production art arrives. Layout must already read as a compact cultivation sect rather than a software dashboard.

## 5. Action → destination mapping

Presentation mapping is deterministic:

- `CULTIVATE`, `BREAKTHROUGH` -> Tu Luyện Đài;
- `WORK_MINING` -> Khu Khai Khoáng;
- `WORK_FORGING` -> Luyện Khí Đường;
- `REST` -> Đệ Tử Xá;
- `HEAL` -> Dược Phòng;
- `SELL`, `BUY` -> Kho;
- `HUNT`, `TRAVEL`, `COMBAT`, `LOOT`, `RETURN_SECT` -> Tông Môn Đại Môn;
- `HOLD` -> Sân trung tâm;
- `EVALUATE`, `IDLE` are transient and preserve the previous visible destination instead of forcing every disciple to snap back to courtyard.

Movement is presentation tweening only. It never changes simulation region/action authority.

## 6. Top bar

The top bar must show concise real state:

- Tông môn name;
- tick/year placeholder derived from tick until full calendar exists;
- money/treasury;
- Linh Thạch;
- key materials (Thanh Thiết, Yêu Đan, Linh Tủy) in compact form.

Do not dump every inventory key into the top bar. Full resource detail belongs to Kho popup.

## 7. Task rail

Left task rail provides the immediate progression guide.

P3.1 vertical-slice tasks:

- quan sát 1 đệ tử làm việc;
- có Thanh Thiết trong kho;
- có ít nhất 1 đệ tử tu luyện;
- mở hồ sơ đệ tử.

Task rail is presentation guidance, not a new reward economy yet.

## 8. Building interaction

Click/tap a building opens a parchment-style popup over the map.

The popup reads actual state. Examples:

- Kho -> Thanh Thiết / Linh Mộc / Yêu Đan / Linh Tủy / spirit stones;
- Luyện Khí Đường -> forging workers + forge support points;
- Khu Khai Khoáng -> mining workers + Thanh Thiết stock;
- Tu Luyện Đài -> current cultivators;
- Đệ Tử Xá -> current resting disciples + lodging capacity;
- Dược Phòng -> medicine stock + current healing disciples;
- Đại Môn -> disciples outside sect / hunting / travelling.

No separate fake building state in P3.1.

## 9. Disciple interaction shell

Tap a disciple or bottom `Đệ Tử` opens the roster screen.

Structure:

- left: vertical disciple roster;
- center: large character presentation placeholder;
- right: selected disciple data;
- bottom: tabs / primary direct actions.

For V2 disciples the detail panel should expose, when available:

- name;
- disciple quality;
- realm;
- HP/stamina;
- six foundation values;
- spiritual root elements + purity;
- Bloodline;
- Physique type + grade;
- current action/work group.

Legacy founding disciples must remain valid; unavailable V2 identity fields show as `—`, not invented values.

## 10. Direct Sect Master controls

P3.1 disciple panel includes real quick orders:

- Tu luyện;
- Đi khai khoáng;
- Đi luyện khí;
- Nghỉ;
- Về tông.

These buttons call the existing workforce direct-command API. Survival emergency still outranks direct order exactly as P2.7 locked.

## 11. Visual language

Reference feeling:

- Chinese ink / parchment / painted cultivation town;
- warm ivory paper panels;
- dark ink borders;
- muted jade green map;
- cinnabar/orange primary buttons;
- gold highlight for important progression;
- compact notification badges;
- no modern white SaaS cards.

P3.1 uses code-generated placeholder style only. Production art pass comes later; layout and information hierarchy are locked now.

## 12. P3.1 gate

Cumulative gate must prove:

1. P0-P2.12 regressions remain green;
2. project target is 1280×720 landscape with canvas-items + expand;
3. project main scene is the P3.1 shell while P0 verifier explicitly smokes its own P0 scene;
4. action -> destination mapping is deterministic and covers cultivation/work/rest/heal/hunt/return/commerce;
5. transient `EVALUATE/IDLE` preserves prior visible destination;
6. direct command from real WorkforceSystem produces an action that maps to the intended location;
7. main P3.1 scene loads headless without parser/runtime failure;
8. the shell reads P2.12 state and does not introduce a second simulation state model.

## 13. Sau P3.1

P3.2 will replace placeholder map/building/character visuals with production-ready assets and animations while retaining this layout/interaction contract.
