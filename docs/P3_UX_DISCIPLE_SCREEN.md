# P3 — DISCIPLE SCREEN UI/UX AUTHORITY

Date: 2026-10-03
Status: CANONICAL DISCIPLE-SCREEN UX CONTRACT

## 0. Mục tiêu

Authority cho màn hồ sơ đệ tử đầy đủ. Đây là **deep overlay/page**, không phải sidebar thường trực trên main map.

---

# 1. Structure canonical

Landscape overlay gần full-screen:

- trái: vertical roster;
- giữa: character showcase lớn;
- phải: compact summary/detail;
- dưới hoặc cạnh phải: tabs/function navigation;
- map phía sau có thể dim nhưng không cần mất hoàn toàn context khi đóng/mở nhanh.

---

# 2. Left roster

Mỗi row/portrait gồm tối thiểu:

- portrait;
- tên ngắn;
- quality/frame cue;
- cảnh báo nhỏ nếu có;
- selected state rõ.

Roster phải scroll nhanh, không mở card lớn cho từng người.

---

# 3. Center showcase

- artwork/profile riêng, không upscale map actor;
- tên;
- rank/chức phận;
- cảnh giới;
- action/status hiện tại;
- VFX khí chất nhẹ nếu hợp lý.

Không phủ dày số liệu lên artwork.

---

# 4. Right summary

Default summary chỉ giữ các thông tin người chơi cần đọc ngay:

- phẩm chất;
- cảnh giới;
- HP/stamina;
- spiritual root summary;
- Bloodline state;
- Physique state;
- nghề/nhóm;
- current action;
- direct Sect Master order.

Foundation/stat sâu chuyển vào tab, tránh giant character sheet.

---

# 5. Tabs runtime hiện tại

Locked real interaction slice hiện có 6 tab:

1. Thuộc tính;
2. Công pháp;
3. Trang bị;
4. Huyết Mạch;
5. Thể Chất;
6. Quan hệ.

Các tab tương lai như Tu luyện, Pháp bảo, Nghề, Ký ức chỉ thêm khi backend/runtime tương ứng sẵn sàng. Không mock thành state giả.

---

# 6. Hidden information

- latent Bloodline/Physique/traits không được leak;
- chưa reveal -> `Chưa xác định`;
- không dùng color/icon/text vô tình tiết lộ hidden type;
- presentation không tạo giá trị thay authority simulation.

---

# 7. Quick action

Quick orders phải gọi authority thật.

Các action như:

- Tu luyện;
- Nghỉ;
- Về tông;
- work/hunt khi hệ cho phép;

không được chỉ đổi text/icon presentation.

---

# 8. Style

- parchment/ink/jade/bronze;
- character art là focal point;
- panel sáng vừa phải, không dark-heavy;
- tab selected rõ nhưng không neon;
- iconography đơn giản, đọc ở mobile;
- quality dùng frame/accent tiết chế, không rainbow toàn màn.

---

# 9. Relationship với main map

Main map tap actor chỉ mở **quick card**.

Nút `Chi tiết` hoặc bottom `Đệ Tử` mới vào màn này.

Không quay lại layout mockup kiểu panel bên phải chiếm 35–45% màn map và chứa toàn bộ 6 tab.

---

# 10. Visual asset authority

Map actor appearance theo:

- `P3_2_MODULAR_ACTOR_SPEC.md`;
- `P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`.

Profile/showcase art là pipeline riêng và phải có hạng mục asset riêng khi production bắt đầu.

---

# 11. Next UX mockup

Khi tạo mockup màn Đệ Tử tiếp theo phải plan trước với user và mô tả rõ:

- roster width;
- showcase footprint;
- summary density;
- vị trí 6 tab;
- quick order location;
- typography/icon hierarchy;
- reference visual assets được kế thừa.
