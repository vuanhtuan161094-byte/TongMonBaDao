# P3 — DISCIPLE SCREEN UI/UX AUTHORITY

Date: 2026-10-04
Status: CANONICAL DISCIPLE-SCREEN UX CONTRACT — V3.3 LOCKED

## 0. Mục tiêu

Authority cho màn hồ sơ đệ tử đầy đủ V3.3.

Entry chính:

`Main Map V3.1 -> tap disciple -> Right Summary Panel V3.2 -> Xem chi tiết -> V3.3`

Bottom nav `Đệ Tử` cũng có thể mở màn này trực tiếp.

Đây là deep overlay/page. Không phải panel thường trực trên main map.

---

# 1. Structure canonical — V3.3

Landscape overlay gần full-screen:

- **trái:** vertical disciple roster;
- **giữa:** character showcase lớn;
- **phải:** nội dung chi tiết/tab content;
- tab/function navigation bố trí sao cho 6 tab luôn truy cập được bằng mobile;
- map phía sau có thể dim nhẹ để giữ cảm giác continuity.

Không copy pixel/layout/icon/text của game tham khảo. Chỉ kế thừa hierarchy đã được user duyệt.

---

# 2. Left roster

Mỗi row/portrait gồm tối thiểu:

- portrait;
- tên ngắn hoặc tooltip khi cần;
- quality/frame cue;
- cảnh báo nhỏ nếu có;
- selected state rõ.

Roster phải:

- scroll nhanh;
- cho đổi đệ tử mà không đóng màn;
- không mở card lớn cho từng người;
- giữ selected disciple khi đổi tab.

---

# 3. Center showcase

- artwork/profile riêng, không upscale map actor;
- tên;
- rank/chức phận;
- cảnh giới;
- action/status hiện tại;
- VFX khí chất nhẹ nếu hợp lý.

Character art là focal point, không phủ dày số liệu lên artwork.

---

# 4. Persistent status continuity

Thông tin quan trọng từ V3.2 vẫn phải đọc được trong V3.3:

- HP;
- Thể lực;
- Tu vi / tiến độ cảnh giới;
- cảnh giới;
- công việc hiện tại;
- trạng thái;
- vị trí.

Không cần đặt đúng cùng vị trí pixel với V3.2, nhưng semantic continuity phải rõ để người chơi không cảm giác sang một character model khác.

---

# 5. Tabs runtime hiện tại — LOCKED

Đúng 6 tab real interaction slice:

1. **Thuộc tính**;
2. **Công pháp**;
3. **Trang bị**;
4. **Huyết Mạch**;
5. **Thể Chất**;
6. **Quan hệ**.

Không thêm tab giả chỉ để mockup đẹp.

Các tab tương lai như Pháp bảo/Nghề/Ký ức chỉ thêm khi runtime authority tương ứng sẵn sàng.

Default khi mở từ `Xem chi tiết`: **Thuộc tính**, trừ khi entry context sau này chỉ rõ tab khác.

---

# 6. Tab Thuộc tính

Mục tiêu: full character read, nhưng có hierarchy.

Nhóm hiển thị:

- sáu foundation: Tư Chất / Căn Cốt / Cơ Duyên / Thông Tuệ / Mị Lực / Tiềm Lực;
- combat/runtime derived stats phù hợp: Công / Thủ / HP / Tốc độ / chỉ số liên quan;
- cảnh giới + tu vi;
- profession/organization summary nếu cần;
- trạng thái sống hiện tại.

Không trình bày combat power như innate identity độc lập; tuân `DISCIPLE_MASTER_SCHEMA.md`.

---

# 7. Tab Công pháp

Hiển thị real learned/active techniques:

- công pháp đang học/đang dùng;
- mastery/progress nếu runtime có;
- combat skills;
- slot khóa/mở nếu có authority thật.

Không tạo skill giả presentation-only.

---

# 8. Tab Trang bị

Đọc real item ownership/equipment state:

- slot;
- item đang equip;
- slot lock;
- stat/effect summary;
- action equip/unequip chỉ khi gọi runtime authority thật.

Không invent inventory state.

---

# 9. Tab Huyết Mạch

- chưa phát hiện -> `Chưa xác định`;
- không leak latent type/purity bằng icon/màu;
- đã phát hiện mới hiện type/purity/state;
- action reveal/awaken/refine gọi real `BloodlineSystem` và cost thật.

---

# 10. Tab Thể Chất

Giữ hai trục riêng:

- grade: Phàm/Linh/Huyền/Thánh/Thần;
- special physique type riêng.

Hiển thị tempering/progression khi runtime có.

Không gộp grade + special type thành một rarity duy nhất.

---

# 11. Tab Quan hệ

Đọc actual P1.3 relationship state:

- người liên quan;
- loại/độ mạnh quan hệ nếu runtime có;
- recent/relevant social cue nếu authority cho phép.

Không fabricate relationship chỉ để làm UI đầy.

---

# 12. Quick/direct orders

Có thể có khu lệnh nhỏ, nhưng màn này không biến thành command dashboard.

Các lệnh như:

- Tu luyện;
- Nghỉ;
- Về tông;
- work/hunt/assignment khi hệ cho phép;

phải gọi authority thật.

Routine command nhanh vẫn ưu tiên V3.2 để giảm số bước.

---

# 13. Hidden information

- hidden Bloodline/Physique/traits không leak;
- `none` và `unknown` là hai trạng thái khác nhau khi runtime phân biệt;
- reveal không reroll;
- presentation không sinh identity mới.

---

# 14. Style — V3.3 locked direction

- parchment/ink/jade/bronze;
- character art là focal point;
- panel sáng vừa phải;
- selected tab rõ nhưng không neon;
- icon đơn giản, readable trên mobile;
- quality dùng frame/accent tiết chế;
- cùng material language với V3.1/V3.2.

---

# 15. Back/navigation contract

- từ V3.2 bấm `Xem chi tiết` -> V3.3 đúng disciple;
- đổi disciple trong roster -> V3.3 đổi context nhưng không thoát;
- Back/X -> trở lại main map;
- nếu vào từ V3.2 và selection còn hợp lệ, restore selected disciple + right panel;
- nếu actor/context không còn hợp lệ, quay về map sạch thay vì giữ state giả.

---

# 16. Visual asset authority

Map actor appearance theo:

- `P3_2_MODULAR_ACTOR_SPEC.md`;
- `P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`.

Profile/showcase art là pipeline riêng; không upscale map actor để giả profile production.

---

# 17. UX acceptance khi implement

V3.3 chỉ coi là UX-implemented khi test thật chứng minh:

1. mở đúng disciple từ V3.2;
2. đổi roster không mất selected state;
3. 6 tab đều đọc authority thật;
4. hidden data không leak;
5. HP/stamina/tu vi/status continuity đúng;
6. Back restore map context đúng;
7. hit target/readability ổn ở 1280×720.

Mockup approval không phải Godot runtime PASS.
