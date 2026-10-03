# P3 — ASSET CÔNG TRÌNH / BUILDING VISUAL AUTHORITY

Date: 2026-10-03
Status: CANONICAL BUILDING ART CONTRACT
Source availability: VISUAL APPROVED / EXACT SOURCE BYTES NOT YET RECOVERED

## 0. Phạm vi

File này là authority presentation cho **toàn bộ công trình nhìn thấy trên map Tông Môn**.

Trước mọi mockup/map art/building generation phải đọc:

1. `P3_PRESENTATION_MASTER.md`;
2. `P3_ART_BIBLE.md`;
3. `P3_ASSET_REGISTRY.json`;
4. `P3_SOURCE_RECOVERY_MANIFEST.md`;
5. file này.

Nếu mockup cần công trình đã có asset duyệt, **không được tự thiết kế lại công trình đó**.

---

# 1. Bộ công trình canonical hiện tại

Map vertical slice có 8 destination/building chính:

1. `Tông Môn Đại Điện`;
2. `Đệ Tử Xá / Phòng Ốc`;
3. `Tu Luyện Đài`;
4. `Kho`;
5. `Luyện Khí Đường`;
6. `Dược Phòng`;
7. `Khu Khai Khoáng`;
8. `Tông Môn Đại Môn`.

Sân trung tâm là destination/map-space, không phải một building asset độc lập.

---

# 2. Approved visual source — bắt buộc kế thừa

Trong production trước 2026-10-03, user đã duyệt một family công trình làm chuẩn visual, ban đầu gồm các ảnh:

- Tông Môn Đại Điện;
- Phòng Ốc / Đệ Tử Xá;
- Luyện Khí Đường;
- Kho;
- UI quản lý Phòng Ốc.

Sau đó production tiếp tục chốt thêm:

- Tu Luyện Đài;
- Dược Phòng;
- Khu Khai Khoáng;
- Tông Môn Đại Môn.

Các ảnh duyệt này là **visual authority thực tế**.

Tuy nhiên, audit ngày 2026-10-03 xác nhận:

- `source_art/` trong live repo chưa có building binary nào;
- repo không có canonical building pack;
- Library/conversation search hiện chưa phục hồi được exact bytes của 8 ảnh duyệt;
- vì vậy 8 building được registry đánh dấu `source_status=missing`, `source_evidence_class=S3`.

Điều này **không hủy visual approval**. Nó chỉ có nghĩa source bytes cần phục hồi.

Không được generate một ảnh giống phong cách rồi đổi nhãn thành “source đã duyệt trước đây”.

---

# 3. Rule khi exact source chưa phục hồi

Cho tới khi exact source được tìm lại:

- mockup composition được phép dùng placeholder/silhouette/khối kiến trúc theo đúng identity và footprint contract;
- nếu source ảnh đã duyệt xuất hiện lại trong conversation/library, phải dùng chính ảnh đó làm reference;
- không redesign Đại Điện/Kho/Dược Phòng/... chỉ vì model có thể tạo bản đẹp khác;
- không gọi generated lookalike là canonical historical source;
- khi source thật được phục hồi, ghi filename/path + SHA-256 vào registry/recovery manifest trước khi ingest.

Recovery priority của 8 building là **P0 trước Mockup V3 production**.

---

# 4. Style lock của building family

Bắt buộc giữ:

- 2D mobile hand-painted;
- isometric/top-down nhẹ, cùng góc camera giữa các building;
- pastel/thủy mặc nhẹ nhưng nét silhouette rõ;
- hình khối đơn giản vừa đủ để đọc ở map scale;
- hơi cute ở simplification, nhưng không đồ chơi/trẻ con;
- kiến trúc tu tiên Á Đông cũ, có khí chất;
- mái xanh xám/ngói tối;
- gỗ nâu đỏ;
- accent vàng đồng vừa phải;
- đá/xám ngọc, greenery xanh trầm;
- không glossy fantasy palace;
- không photorealistic;
- không quá nhiều chi tiết nhỏ biến thành noise ở zoom xa.

Tất cả building phải nhìn như **cùng một game, cùng một artist family, cùng camera**.

---

# 5. Registration / footprint consistency

Khi làm hoặc sửa asset:

- giữ cùng camera pitch/yaw;
- cùng logic chiều cao tầng;
- cùng scale cửa, mái, bậc thang;
- footprint phải tương thích map layout;
- shadow direction thống nhất;
- không đổi perspective từng building;
- building quan trọng có thể lớn hơn nhưng không được phá tỷ lệ thế giới.

Nếu mockup chỉ cần composition, phải reuse footprint/silhouette authority thay vì generate palace mới.

---

# 6. Identity từng công trình

## Tông Môn Đại Điện

- building authority/administration chính;
- nổi bật nhất nhưng vẫn là tông môn đầu-mid game, không cung điện đế vương;
- trục chính rõ, bậc thang/sân trước hợp lý;
- accent vàng đồng nhiều hơn building phụ.

## Đệ Tử Xá / Phòng Ốc

- khu nghỉ/sinh hoạt;
- cảm giác cư trú thật, có sân/phơi/đồ dùng nhẹ;
- không giống chính điện thu nhỏ.

## Tu Luyện Đài

- không nhất thiết là nhà kín;
- đọc được ngay là nơi tu luyện/tụ linh;
- có platform/trận pháp/linh khí nhẹ;
- VFX phải tiết chế để không phá map.

## Kho

- hình khối chắc, thực dụng;
- có dấu hiệu chứa vật tư/thùng/kệ nhưng không clutter quá mức;
- không biến thành shop fantasy.

## Luyện Khí Đường

- lò/rèn/khói/lửa là signature;
- công nghiệp thủ công tiên hiệp, không steampunk;
- có ambient fire/smoke nhẹ.

## Dược Phòng

- herbs, cauldron/medicine identity;
- xanh ngọc/thảo mộc là cue phụ;
- không biến thành bệnh viện hiện đại.

## Khu Khai Khoáng

- quặng/đá/giàn khai thác thô;
- là một khu chức năng ngoài trời hoặc bán ngoài trời;
- không cần kiến trúc quá lớn.

## Tông Môn Đại Môn

- landmark ra/vào tông môn;
- đủ đọc ở zoom xa;
- có khí chất cổ, không phải cổng hoàng cung quá phô trương.

---

# 7. Building states cần production

Mỗi building về lâu dài cần:

- base;
- selected/highlight;
- shadow;
- construction/upgrade indicator;
- 1 ambient VFX/animation nhẹ nếu hợp lý;
- hitbox logic riêng khỏi alpha.

Selected state không được thay toàn bộ hình building; ưu tiên glow/outline/plate/ring nhẹ.

---

# 8. Mockup rule

Khi dựng mockup UI/UX:

- giữ đúng building family đã duyệt;
- không hiện nameplate cho mọi building mọi lúc;
- default chỉ landmark quan trọng hoặc selected target mới hiện tên;
- notification/action bubble tách khỏi art building;
- UI không được che silhouette công trình chính;
- map phải vẫn đọc được đường đi giữa các building.

Mockup mới **không có quyền redesign** Đại Điện, Kho, Dược Phòng... chỉ vì image model thấy đẹp hơn.

---

# 9. Status / next

Current:

- building visual family: **approved**;
- exact canonical binary source: **not recovered**;
- registry: 8 building = `S3 / missing source / visual approved`;
- runtime integration: chưa làm.

Next:

1. phục hồi exact source của 8 building nếu còn trong lịch sử/local machine;
2. user xác nhận candidate source nếu cần;
3. ghi checksum/locator;
4. sau khi Windows xác minh LFS workflow, ingest source master vào `source_art/p3/buildings/...`;
5. chuẩn hóa runtime export và states mà không redraw base tùy tiện.
