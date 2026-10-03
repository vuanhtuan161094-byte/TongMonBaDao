# P3 — MAIN MAP V3 COMPOSITION / WIREFRAME SPEC

Date: 2026-10-03
Status: CANONICAL PRE-MOCKUP COMPOSITION SPEC
Canvas: `1280 × 720` landscape

## 0. Mục đích

Khóa **bố cục trước khi tạo mockup art tiếp theo**.

File này cố ý dùng `asset_id` + placeholder footprint. Nó **không được phép tự redesign** 8 building đã được user duyệt.

Khi exact building source được phục hồi, thay trực tiếp vào đúng slot/footprint. Nếu source chưa có, mockup/wireframe chỉ dùng silhouette/placeholder trung tính.

Authority đọc trước:

1. `P3_PRESENTATION_MASTER.md`;
2. `P3_ART_BIBLE.md`;
3. `P3_ASSET_REGISTRY.json`;
4. `P3_SOURCE_RECOVERY_MANIFEST.md`;
5. `P3_ASSET_BUILDINGS.md`;
6. `P3_ASSET_MAP_ENVIRONMENT.md`;
7. `P3_UX_MAIN_MAP.md`;
8. `P3_UI_SKIN_AND_ICONOGRAPHY.md`.

---

# 1. Mục tiêu V3

Màn phải đọc ngay là:

> **một tông môn nhỏ đang sống và vận hành**, không phải dashboard và không phải palace showcase.

Thứ tự mắt nhìn:

1. world/map + current activity;
2. selected/actionable target nếu có;
3. top resources/status;
4. task rail;
5. nav;
6. decoration.

Map phải giữ khoảng **85–90% cảm nhận thị giác** ở trạng thái bình thường.

---

# 2. Safe-area / HUD zones

Không bake HUD vào map art.

### Top HUD

- vùng tổng: `x=16..1264`, `y=12..64`;
- chiều cao mục tiêu: `44–52 px`;
- profile/sect block: khoảng `220–250 px` bên trái;
- 4–5 resource chips compact ở giữa;
- calendar/time + mail/settings ở phải;
- không tạo một thanh đặc kín toàn chiều ngang nếu không cần.

### Left task rail

- expanded target: `x=16..224`, `y=92..310`;
- width khoảng `190–208 px`;
- 2–4 task visible;
- collapsed target width khoảng `40–48 px`;
- không che đường đi chính hoặc building landmark.

### Bottom navigation

- 5 entry tối đa;
- vùng mục tiêu: khoảng `x=400..880`, `y=654..710`;
- height `48–56 px`;
- entry: Tông Môn / Đệ Tử / Xây Dựng / Nhiệm Vụ / Thế Giới;
- không dùng dock cao toàn chiều ngang.

### Right contextual edge

- chỉ 0–3 icon nhỏ theo trạng thái;
- không tạo fixed sidebar.

Mobile hit target quan trọng không nhỏ hơn khoảng `44×44 px` dù icon visual nhỏ hơn.

---

# 3. World composition — canonical slots

Tọa độ dưới đây là **center normalized / composition target**, được phép tune nhẹ khi exact source footprint được phục hồi. Không đổi vai trò vùng chỉ để ảnh đẹp hơn.

| Asset ID | Building | Center target | Vai trò bố cục |
|---|---|---:|---|
| `building.sect_main_hall` | Tông Môn Đại Điện | `(0.52, 0.25)` | landmark chính, cuối trục từ Đại Môn |
| `building.cultivation_platform` | Tu Luyện Đài | `(0.31, 0.31)` | upper-left, gần thiên nhiên/linh khí |
| `building.mining_area` | Khu Khai Khoáng | `(0.80, 0.31)` | rìa map, gần đá/cliff |
| `building.disciple_quarters` | Đệ Tử Xá | `(0.25, 0.53)` | khu sinh hoạt, lệch trái |
| `building.storage` | Kho | `(0.59, 0.53)` | gần sân trung tâm / logistics |
| `building.forge` | Luyện Khí Đường | `(0.76, 0.53)` | xa khu nghỉ, cue lửa/khói nhẹ |
| `building.medicine_hall` | Dược Phòng | `(0.37, 0.64)` | gần khu ở và đường trung tâm |
| `building.sect_gate` | Tông Môn Đại Môn | `(0.53, 0.80)` | landmark lối ra/vào, đầu trục chính |

### Sân trung tâm

- center khoảng `(0.51, 0.49)`;
- là destination `HOLD` / hub circulation;
- đủ chỗ 4–8 actor nhỏ đi/cắt nhau mà không che building;
- không biến thành quảng trường khổng lồ.

---

# 4. Path graph

Trục chính bắt buộc:

`Đại Môn -> Sân trung tâm -> Đại Điện`

Nhánh:

- Sân -> Đệ Tử Xá;
- Sân -> Tu Luyện Đài;
- Sân -> Dược Phòng;
- Sân -> Kho;
- Kho/Sân -> Luyện Khí;
- Luyện Khí/Kho -> Khai Khoáng.

Path phải:

- đọc được ở zoom 0.75;
- đủ rộng cho 1–2 actor;
- không chạy xuyên footprint building;
- tạo loop nhỏ ở khu sinh hoạt nếu hợp lý;
- tránh mạng đường hình học quá sạch/đối xứng.

---

# 5. Environment framing

### Rìa trên / hai bên

- mountain/cliff/tree mass để frame;
- muted, không cạnh tranh Đại Điện;
- khai khoáng có rock mass rõ ở rìa phải/trên.

### Water

- stream có thể chạy ở một rìa hoặc cắt một nhánh phụ;
- bridge chỉ dùng khi có giá trị điều hướng;
- không chia map gameplay thành hai nửa khó đọc.

### Vegetation

- cluster cây/đá thay vì rải đều;
- giữ negative space quanh building hitbox và actor route;
- không che cửa/entrance.

---

# 6. NPC / world-life composition

Baseline V3 target: khoảng `8–12` actor visible, không cần tất cả có bubble.

Ví dụ distribution:

- 2 actor giữa Đại Môn <-> sân;
- 1–2 ở Tu Luyện Đài;
- 1 ở Dược Phòng;
- 1 ở Kho;
- 1–2 giữa Kho/Luyện Khí/Khai Khoáng;
- 1 ở Đệ Tử Xá;
- 1 ambient tại sân.

Props hành vi có thể gồm kiếm/túi/thảo dược/vật tư/băng bó, nhưng actor vẫn phải nhỏ và không quá chibi.

Chỉ 1–3 actionable/world bubbles cùng lúc.

---

# 7. Building labels / alerts

Default state:

- không hiện tên trên cả 8 building;
- selected building mới hiện `Tên + Cấp`;
- onboarding landmark có thể tạm hiện label;
- production-ready / upgrade / heal / breakthrough dùng bubble nhỏ riêng.

Không bake label vào art building.

---

# 8. State A — Main map idle

Đây là ảnh/màn đầu tiên cần khóa.

Visible:

- map full;
- top HUD;
- task rail;
- bottom nav;
- 8 building footprints;
- 8–12 actor;
- 1–3 world cues tối đa.

Không visible:

- giant right panel;
- full disciple tabs;
- full building management screen;
- label mọi building.

Mục tiêu: người xem phải nhận ra map trước UI.

---

# 9. State B — Selected disciple quick card

Giữ nguyên map/HUD của State A.

Thêm:

- selection ring ở actor;
- camera focus presentation;
- compact quick card khoảng `250–300 × 130–165 px`;
- đặt ở vùng không che actor/target, ưu tiên góc phải dưới hoặc adaptive side;
- card chỉ có:
  - tên;
  - cảnh giới;
  - current action/location;
  - HP/stamina hoặc alert cần thiết;
  - 1–2 quick command;
  - `Chi tiết`.

Không nhét 6 tab vào quick card.

---

# 10. State C — Selected building quick popup

Giữ map context.

Popup target khoảng `260–320 × 140–190 px`.

Chỉ gồm:

- building name/level;
- trạng thái chính;
- worker/output/input quan trọng;
- 1–2 action;
- detail/upgrade entry nếu cần.

Selected visual trên building dùng ring/outline/glow nhẹ, không repaint toàn building.

---

# 11. Deep screen boundary

Các nội dung sau **không thuộc main-map composition**:

- 6 tab hồ sơ đệ tử;
- equipment detail;
- bloodline/physique deep controls;
- inventory lớn;
- upgrade tree lớn.

Chúng mở parchment overlay/deep page riêng và được spec trong `P3_UX_DISCIPLE_SCREEN.md` hoặc screen-specific authority sau này.

---

# 12. Visual treatment khóa cho mockup tiếp theo

- 2D hand-painted xianxia mobile;
- pastel / ink-wash nhẹ;
- muted jade / blue-gray / ivory;
- wood red-brown + bronze/gold accent;
- sáng và dễ đọc hơn mockup dark-heavy cũ;
- có độ cũ và đời sống;
- không palace fantasy glossy;
- không SaaS;
- không dùng third-party asset/text/icon/map.

**Building placeholder không được tự biến thành generated replacement.** Nếu exact approved building source chưa có, placeholder phải đủ trung tính để người xem hiểu layout mà không hiểu nhầm là building art mới đã chốt.

---

# 13. Pre-image plan requirement

Trước khi tạo **bất kỳ ảnh mockup nào từ spec này**, phải trình user plan riêng của lượt đó, tối thiểu nêu:

1. state nào (`A/B/C`);
2. asset thật nào đã có / asset nào đang dùng placeholder;
3. bố cục giữ nguyên gì;
4. thứ được phép thay đổi;
5. phong cách/palette;
6. mục tiêu review sau ảnh.

Chỉ generate sau khi user duyệt plan.

---

# 14. Acceptance checklist

State A chỉ được visual-accept khi:

- map là focal point;
- 8 building slot đọc tách nhau;
- trục Gate -> Courtyard -> Main Hall rõ;
- actor route hợp lý;
- HUD không ép map xuống thành dashboard;
- task rail không quá rộng;
- bottom nav không quá cao;
- không label spam;
- không art tự phát minh thay approved building family;
- ở 1280×720 vẫn đọc được hierarchy.

Sau State A mới review State B/C, không gộp cả ba thành một screenshot rối.
