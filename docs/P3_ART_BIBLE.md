# P3 — ART BIBLE / VISUAL STYLE GUIDE

Date: 2026-10-03
Status: CANONICAL CROSS-CUTTING VISUAL GUIDE
Locked since: 2026-10-03

## 0. Vai trò

Đây là **quick-reference visual guide** cho toàn bộ presentation P3. Nó không thay MD riêng của từng hạng mục; nó chỉ khóa những quy tắc phải giống nhau giữa công trình, map, nhân vật, UI và VFX.

Thứ tự đọc:

`P3_PRESENTATION_MASTER.md -> P3_ART_BIBLE.md -> MD hạng mục -> asset/reference đã duyệt`.

---

# 1. Visual pillars

| Pillar | Nghĩa | Loại trừ |
|---|---|---|
| **Tông môn đang sống** | Người chơi nhìn thấy nơi chốn đang vận hành, NPC di chuyển/làm việc, building có chức năng rõ | map chỉ để ngắm; đại cung điện trống người |
| **Tiên hiệp vẽ tay, cổ nhưng dễ đọc** | 2D hand-painted, thủy mặc/pastel, vật liệu gỗ-đá-ngói-giấy | glossy fantasy, photoreal, UI sci-fi/SaaS |
| **Mobile readability trước micro-detail** | silhouette, hierarchy, icon, text và hit target đọc nhanh ở 1280×720 | hoa văn nhỏ dày đặc, clutter, label mọi nơi |
| **Một thế giới, một camera, một family** | building/map/actor/UI phải có cùng scale logic, palette, perspective và độ chi tiết | mỗi asset đẹp riêng nhưng ghép vào nhìn như game khác |

---

# 2. Palette theo chức năng

Chưa khóa mã màu hex cho tới khi approved source art được ingest và sample trực tiếp. Hiện khóa theo **vai trò màu**:

| Context | Palette | Rule |
|---|---|---|
| Nền/map | xanh xám, jade muted, đá xám, đất ngà | nhạt hơn interactive object |
| Kiến trúc | mái xanh xám/ngói tối, gỗ nâu đỏ | cùng material family giữa mọi building |
| Selected/high value | vàng đồng | accent, không phủ toàn object |
| Panel | giấy ngà + mực nâu/xám xanh | deep overlay vẫn sáng, dễ đọc |
| Primary action | son/cam ấm | chỉ action chính |
| Success/heal | xanh lục trầm | không neon |
| Mystic/rare | tím/xanh lam sâu | dùng ít, không rainbow rarity |
| Danger | đỏ | chỉ danger/urgent thật |

**Palette không chỉ là swatch:** mỗi màu phải có vai trò và không được dùng tùy hứng.

---

# 3. Camera / perspective / scale

Main map:

- mobile landscape `1280×720`;
- isometric/top-down nhẹ;
- một family camera cho mọi building;
- cùng hướng shadow;
- cùng logic tỷ lệ cửa, mái, bậc thang, actor;
- map zoom canonical `0.75–1.80`, default `1.00`.

Map actor:

- perceived body target khoảng `60–75 px` ở zoom `1.00`;
- mature chibi, đầu lớn vừa phải, không loli;
- silhouette phải còn đọc ở `0.75x`.

---

# 4. Shape / silhouette rules

## Building

- identity đọc được từ silhouette trước khi đọc label;
- Đại Điện, Kho, Dược Phòng, Luyện Khí, Đệ Tử Xá không được là cùng một nhà đổi biển;
- roof mass, entrance, platform, props chức năng là cue chính;
- building quan trọng lớn hơn nhưng không phá scale thế giới.

## Character

- đầu lớn vừa phải;
- thân compact nhưng trưởng thành;
- tay/chân phải đọc được khi chuyển động;
- hair/outfit không được nhập thành một khối tối hoàn toàn ở zoom xa;
- accessory lớn phải giữ silhouette, accessory nhỏ không được làm noise.

## UI

- panel silhouette đơn giản;
- selected state rõ bằng border/accent/plate, không bằng full-screen glow;
- icon đọc ở kích thước nhỏ trước khi nhìn chi tiết nội bộ.

---

# 5. Detail budget

Thứ tự ưu tiên khi giảm chi tiết:

1. giữ silhouette;
2. giữ material/color block;
3. giữ motif chức năng;
4. giữ một vài accent lớn;
5. bỏ micro-pattern, charm, line cực nhỏ.

Nếu chi tiết không đọc được ở kích thước gameplay, mặc định **không sản xuất** cho runtime asset.

---

# 6. Visual hierarchy main screen

Mắt người chơi nên đọc theo thứ tự:

1. map / current target;
2. actionable world cue;
3. top resource/status;
4. task rail;
5. navigation;
6. secondary decoration.

Không để:

- sidebar lớn thường trực;
- 10 resource chips;
- nameplate trên mọi building;
- red dot khắp màn;
- VFX phủ mất NPC/building.

---

# 7. Environment density

Map đầu game phải:

- compact;
- có đường đi rõ;
- có cây/đá/nước tạo không khí;
- có khoảng âm để actor đọc được;
- không quá sạch/đối xứng như palace showcase;
- không quá dày foliage/props tới mức target khó bấm.

World life quan trọng hơn cảnh nền phô trương.

---

# 8. UI material language

UI family:

- parchment;
- ink line;
- wood/jade frame;
- bronze/gold selection;
- cinnabar primary action.

Không dùng:

- glassmorphism;
- neon;
- gradient digital nặng;
- panel đen glossy fantasy;
- white-card enterprise dashboard.

---

# 9. VFX language

VFX là **feedback**, không phải wallpaper.

- cultivation: khí/linh quang nhẹ;
- forge: fire/spark cục bộ;
- medicine: herb/green-blue cue tiết chế;
- selected: ring/outline/pulse ngắn;
- success: flash ngắn;
- warning: icon/badge trước, screen effect sau.

Không giữ VFX mạnh liên tục trên nhiều object cùng lúc.

---

# 10. Reference priority

Khi có xung đột:

1. approved source asset cùng hạng mục;
2. MD hạng mục;
3. Art Bible này;
4. mockup mood reference;
5. external game reference chỉ cho structure/hierarchy.

Mockup đẹp hơn **không tự động thắng** asset đã duyệt.

---

# 11. Review checklist cho mỗi asset/mockup

Trước khi trình user:

- đúng approved family chưa?
- đúng camera/scale chưa?
- silhouette đọc ở gameplay size chưa?
- palette có đúng vai trò không?
- chi tiết có quá dày không?
- asset có làm map/UI lệch sang game khác không?
- có dùng lại source đã duyệt thay vì reinvent không?
- nếu là mockup: map có còn là focal point không?

Nếu một câu trả lời là `không`, chưa nên generate/finalize tiếp.
