# P3 — MAP / TERRAIN / ENVIRONMENT VISUAL AUTHORITY

Date: 2026-10-03
Status: CANONICAL MAP-ENVIRONMENT CONTRACT

## 0. Phạm vi

Authority cho terrain, đường, nước, cây, đá, bridge, deco, khoảng sân và cách ghép map quanh building.

Đọc sau `P3_PRESENTATION_MASTER.md` trước mọi map mockup/generation.

---

# 1. Mục tiêu cảm giác

Map phải cho cảm giác **một tông môn nhỏ đang sống**, không phải một đại tiên cung để ngắm cảnh.

Bắt buộc:

- compact;
- có đường đi thật giữa building;
- đủ khoảng sân để NPC di chuyển;
- cây/đá/nước tạo cảnh nhưng không chặn gameplay readability;
- nhìn thấy khu vực làm việc, nghỉ, luyện, ra/vào;
- có độ cũ, tự nhiên, hơi hỗn độn có kiểm soát.

---

# 2. Style lock

- 2D hand-painted;
- isometric/top-down nhẹ cùng camera building family;
- pastel/thủy mặc;
- muted jade / blue-gray / stone gray;
- wood + bronze accent;
- không glossy 3D;
- không quá fantasy/cinematic;
- không biến map thành vườn cảnh trống người;
- không dùng foliage cực chi tiết gây noise mobile.

User đã chấp nhận hướng có đệ tử nhỏ đi lại giữa Dược Phòng, Kho, Chợ/khu giao dịch và Cổng Tông; cảm giác thế giới vận hành quan trọng hơn độ nguy nga.

---

# 3. Layer production canonical

Thứ tự ghép map lâu dài:

1. base terrain;
2. dirt/stone path overlay;
3. water/stream;
4. bridge/walls/gates;
5. building assets;
6. trees/rocks/vegetation;
7. props/deco;
8. actor + action bubble;
9. VFX/fog/ambient overlay rất nhẹ.

Không bake toàn bộ thành một background duy nhất nếu điều đó cản camera focus, building selection hoặc future map expansion.

---

# 4. Existing production notes

Pipeline trước đã chốt:

- base terrain;
- path overlay trong suốt;
- water/stream;
- 8 building;
- deco;
- character/FX.

Một dirt-path pack từng được chuẩn bị theo grid 128 với nhiều PNG/atlas. Khi source binary được tập trung lại, phải đăng ký vào manifest thay vì regenerate từ đầu.

---

# 5. Path/readability rules

- đường chính phải nối được Đại Môn -> sân trung tâm -> Đại Điện;
- đường phụ phải dẫn rõ tới khu nghỉ, Dược Phòng, Kho, Luyện Khí, Tu Luyện, Khai Khoáng;
- NPC không nên xuyên cây/nhà trong mockup presentation;
- path width phải đủ cho 1–2 actor nhỏ đọc được;
- tránh mọi building nằm sát nhau đến mức silhouette dính khối;
- vẫn giữ compactness, không tạo quảng trường quá rộng.

---

# 6. Water / cliff / mountain framing

Mountains/water dùng để tạo identity tiên hiệp nhưng không chiếm gameplay core:

- cliff/mountain ở rìa map;
- stream/water làm divider tự nhiên;
- bridge dùng nơi có giá trị điều hướng;
- waterfall/fog là accent, không phải focal point chính;
- main interactive area phải phẳng/đọc được.

---

# 7. NPC/world-life requirement

Mockup map production phải thể hiện tông môn đang vận hành:

- NPC đi giữa building;
- một số người mang kiếm/túi/thảo dược/vật tư;
- có người làm việc, nghỉ, luyện;
- bubble chỉ xuất hiện ở target/action đáng chú ý;
- không cần mọi NPC đều có label.

---

# 8. Không được tự thay đổi

- camera family;
- palette tổng;
- building footprint đã duyệt;
- đường chính chỉ để làm ảnh đẹp;
- map thành đại cung điện trên mây;
- foliage/đá che mất building click targets.

---

# 9. Status / next

Current: environment style/pipeline đã có hướng duyệt nhưng asset binary chưa được tập trung thành một canonical pack trong GitHub.

Next:

1. inventory lại terrain/path/deco source đã duyệt;
2. lập manifest file cụ thể;
3. dùng chính source đó khi làm mockup/runtime map production;
4. chỉ generate phần thiếu, không remake phần đã có.
