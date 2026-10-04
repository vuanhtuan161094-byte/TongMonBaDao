# P3 — MAIN MAP UI/UX AUTHORITY

Date: 2026-10-04
Status: CANONICAL MAIN-MAP UX CONTRACT — V3.1/V3.2 LOCKED; V3.2 IMPLEMENTED / RUNTIME PENDING

## 0. Mục tiêu

Authority cho màn Tông Môn/home screen 1280×720.

Reference ngoài chỉ dùng để học hierarchy/nhịp thao tác. Asset/text/map phải là của Tông Môn Bá Đạo.

User đã chốt flow V3 ngày 2026-10-04:

`Main Map V3.1 -> tap disciple -> right summary panel V3.2 -> Xem chi tiết -> Disciple Deep Screen V3.3`.

Map-first vẫn là nguyên tắc gốc. Panel phải **không mở mặc định**; nó chỉ xuất hiện khi người chơi chọn một đệ tử.

---

# 1. Visual hierarchy — V3.1 idle

Ở trạng thái bình thường:

- map chiếm khoảng 85–90% cảm nhận thị giác;
- HUD bám viền;
- task rail trái mỏng và thu gọn được;
- bottom/edge navigation gọn;
- bubble/status nằm trực tiếp trên world target;
- không có detail sidebar lớn mở mặc định;
- terrain sáng, thoáng, có negative space;
- công trình tương đối nhỏ hơn màn hình, không dồn thành city-builder đặc;
- NPC/bubble tạo cảm giác tông môn đang sống.

Map phải là thứ mắt nhìn vào đầu tiên.

---

# 2. Top bar

Giữ:

- tên/cấp hoặc uy danh Tông Môn ở góc/trái;
- 4–5 tài nguyên quan trọng nhất;
- game time/calendar compact;
- mail/settings/event nếu thực sự cần.

Không:

- hiển thị 10+ resource chip;
- top bar cao kiểu desktop toolbar;
- quá nhiều label chữ dài.

---

# 3. Left task rail

- width nhỏ;
- 2–4 task visible;
- có collapse;
- task active nổi hơn bằng giấy/vàng/son nhẹ;
- bấm task có thể focus target phù hợp;
- không chiếm nửa màn hình dọc.

**Vai trò canonical:** bên trái = nhiệm vụ / việc cần làm. Không dùng bên trái làm disciple detail panel.

---

# 4. Building labels

Default:

- không hiện nameplate cố định cho mọi building;
- selected/hover/focus building hiện tên + cấp;
- landmark quan trọng có thể có label ngắn nếu cần onboarding;
- actionable bubble được ưu tiên hơn nameplate.

Mục tiêu là giảm clutter và giữ map tự nhiên.

---

# 5. Tap building flow — chưa visual-lock

Target hiện tại:

`tap building -> camera focus nhẹ + selected marker -> contextual summary -> Quản lý/Chi tiết nếu hệ sâu`

Chi tiết panel/popup công trình sẽ được khóa ở bước UX kế tiếp. Không lấy disciple panel rồi áp máy móc cho building trước khi user duyệt.

---

# 6. Tap disciple flow — V3.2 LOCKED

Canonical:

`tap disciple -> focus nhẹ + selection ring -> right vertical summary panel`

Không dùng floating tooltip/card nhỏ giữa map nữa.

### Vị trí

- panel neo **bên phải**;
- từ dưới top HUD xuống gần bottom navigation;
- target width khoảng **280–320 px** ở logical 1280×720;
- map vẫn hoạt động/nhìn thấy ở phần còn lại;
- panel không scale cùng camera map.

### Nội dung theo thứ tự

1. tên + portrait/profile;
2. phẩm chất/tag/chức phận cần thiết;
3. cảnh giới;
4. **HP**;
5. **Thể lực**;
6. **Tu vi / tiến độ cảnh giới**;
7. **Công việc hiện tại**;
8. **Trạng thái** — ví dụ Làm việc / Nghỉ / Tu luyện / Bị thương;
9. **Vị trí hiện tại** — ví dụ Dược Phòng;
10. thuộc tính chiến đấu/chính cần đọc nhanh;
11. 3–4 icon kỹ năng/công pháp đang dùng hoặc slot khóa;
12. cue nhỏ cho Huyết Mạch/Thể Chất chỉ khi thông tin đã được phát hiện;
13. action theo ngữ cảnh;
14. nút **Xem chi tiết**.

Panel là **operational summary**, không phải full character sheet.

### Interaction

- tap đệ tử khác -> panel đổi sang người mới ngay;
- selected actor vẫn có selection ring trên map;
- tap vùng trống hoặc X -> đóng panel, trả full map;
- camera không auto-follow actor liên tục;
- `Xem chi tiết` -> mở V3.3;
- đóng V3.3 -> quay về map và giữ selected disciple/panel nếu context còn hợp lệ.

### Hidden data

- latent Bloodline/Physique/trait không được leak;
- chưa phát hiện -> `Chưa xác định` hoặc không hiện cue;
- không dùng màu/icon vô tình tiết lộ hidden type.

---

# 7. Deep overlays / screens

Các hệ sâu như:

- hồ sơ đệ tử;
- công pháp;
- trang bị;
- Huyết Mạch;
- Thể Chất;
- Quan hệ;
- inventory chi tiết;
- nhiệm vụ/sổ tay lớn;
- upgrade tree;

dùng parchment overlay/page riêng.

V3.2 không chứa 6 tab. Sáu tab thuộc V3.3.

---

# 8. Bottom/edge navigation

Target 5 entry thường trực:

- Tông Môn;
- Đệ Tử;
- Xây Dựng/Công Trình;
- Nhiệm Vụ;
- Thế Giới/Bản Đồ.

Kho/Chiêu Hiền/Kỳ Vật có thể là contextual/secondary entry tùy phase.

---

# 9. World-life cues

Map phải có cảm giác tự vận hành:

- actor đi giữa destination thật;
- icon action nhỏ;
- speech/event bubble tiết chế;
- production-ready/upgrade alert;
- heal/rest/breakthrough warning;
- ambient activity tại building.

Baseline V3.1: khoảng 8–12 actor visible và chỉ 1–3 bubble/action cue nổi bật cùng lúc.

---

# 10. Camera

Giữ locked runtime contract:

- zoom 0.75–1.80;
- default 1.00;
- focus khoảng 1.35;
- pinch/wheel anchored zoom;
- one-finger/mouse drag pan;
- camera chỉ transform map;
- HUD/panel không scale theo map;
- focus target không auto-follow liên tục.

---

# 11. Main-map style — V3.1 locked direction

- hand-painted xianxia mobile;
- sáng, thoáng, hơi thủy mặc;
- terrain nhạt hơn và có negative space;
- công trình không phóng quá lớn;
- giấy ngà, ink line, jade muted, bronze/gold accent;
- NPC nhỏ nhưng readable;
- không dark-heavy;
- không palace fantasy glossy;
- không SaaS/dashboard.

Công trình canonical theo `P3_ASSET_BUILDINGS.md`; mockup không có quyền thay thiết kế building đã duyệt.

---

# 12. UX playtest checklist khi có máy

Test tối thiểu:

1. pan/zoom map bằng touch/mouse;
2. tap actor đang di chuyển -> panel phải mở;
3. HP/stamina/tu vi đọc được ở 1280×720;
4. công việc/trạng thái/vị trí phản ánh runtime thật;
5. tap actor khác -> panel đổi đúng người;
6. focus target rồi pan đi, dùng focus quay lại;
7. X/blank tap đóng panel;
8. `Xem chi tiết` mở V3.3;
9. đóng V3.3 quay lại đúng map context;
10. task rail collapse/expand;
11. kiểm hit target mobile;
12. kiểm map còn đủ diện tích chơi khi panel phải mở.

Đánh giá theo số thao tác + độ che map + khả năng đọc trạng thái, không chỉ theo ảnh đẹp.
