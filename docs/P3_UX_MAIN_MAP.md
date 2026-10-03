# P3 — MAIN MAP UI/UX AUTHORITY

Date: 2026-10-03
Status: CANONICAL MAIN-MAP UX CONTRACT

## 0. Mục tiêu

Authority cho màn Tông Môn/home screen 1280×720.

Reference ngoài chỉ dùng để học hierarchy/nhịp thao tác. Asset/text/map phải là của Tông Môn Bá Đạo.

Các video user gửi ngày 2026-10-03 củng cố quyết định: **map-first, HUD mỏng, deep screens tách lớp, không sidebar nặng thường trực**.

---

# 1. Visual hierarchy

Ở trạng thái bình thường:

- map chiếm khoảng 85–90% cảm nhận thị giác;
- HUD bám viền;
- task rail trái mỏng và thu gọn được;
- bottom/edge navigation gọn;
- bubble/status nằm trực tiếp trên world target;
- không có detail sidebar lớn mở mặc định.

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

---

# 4. Building labels

Default:

- không hiện nameplate cố định cho mọi building;
- selected/hover/focus building hiện tên + cấp;
- landmark quan trọng có thể có label ngắn nếu cần onboarding;
- actionable bubble được ưu tiên hơn nameplate.

Mục tiêu là giảm clutter và giữ map tự nhiên.

---

# 5. Tap building flow

Canonical:

`tap building -> camera focus nhẹ + selected marker -> compact quick popup -> action/deep detail nếu cần`

Quick popup chỉ nên có:

- tên/cấp;
- trạng thái chính;
- worker/output/input quan trọng;
- 1–2 action chính;
- nút mở chi tiết nếu hệ sâu.

Không mở giant panel ngay cho mọi tap thường.

---

# 6. Tap disciple flow

Canonical:

`tap disciple -> focus + selection ring -> compact identity/action card`

Quick card chỉ hiện:

- tên;
- cảnh giới;
- action/location;
- HP/stamina hoặc alert nếu cần;
- 1–2 quick command;
- nút `Chi tiết` mở màn Đệ Tử đầy đủ.

Không nhét 6 tab + full stats vào sidebar map.

---

# 7. Deep overlays / screens

Các hệ sâu như:

- hồ sơ đệ tử;
- công pháp;
- trang bị;
- inventory chi tiết;
- nhiệm vụ/sổ tay lớn;
- upgrade tree;

được phép dùng parchment overlay gần full-screen và dim map phía sau.

Routine management vẫn ưu tiên popup nhỏ để giữ world context.

---

# 8. Bottom/edge navigation

Target 4–5 entry thường trực, không nhồi mọi hệ thống:

- Tông Môn/Home;
- Đệ Tử;
- Công Trình hoặc Xây Dựng;
- Nhiệm Vụ / Sổ;
- Thế Giới / Bản Đồ.

Kho/Chiêu Hiền/Kỳ Vật có thể là contextual/secondary entry tùy phase, không bắt buộc tất cả nằm trên dock.

---

# 9. World-life cues

Map phải có cảm giác tự vận hành:

- actor đi giữa destination thật;
- icon action nhỏ;
- speech/event bubble tiết chế;
- production-ready/upgrade alert;
- heal/rest/breakthrough warning;
- một số ambient activity tại building.

Không spam red dot hoặc bubble trên mọi object.

---

# 10. Camera

Giữ locked runtime contract:

- zoom 0.75–1.80;
- default 1.00;
- focus khoảng 1.35;
- pinch/wheel anchored zoom;
- one-finger/mouse drag pan;
- camera chỉ transform map;
- HUD/popup không scale theo map;
- focus target không auto-follow liên tục.

---

# 11. Main-map style

UI/map mood user hiện thích:

- hand-painted xianxia mobile;
- giấy ngà, ink line, jade muted, bronze/gold accent;
- sáng, dễ đọc, có hơi thở đời sống;
- không dark-heavy toàn màn;
- không SaaS;
- không glossy fantasy UI.

Công trình phải theo `P3_ASSET_BUILDINGS.md`, không theo kiến trúc ngẫu nhiên của mockup.

---

# 12. UX playtest checklist khi có máy

Test tối thiểu:

1. pan/zoom map bằng touch/mouse;
2. tap 3 building khác nhau;
3. tap actor đang di chuyển;
4. focus target rồi pan đi, dùng nút focus quay lại;
5. open/close compact popup;
6. open deep disciple screen rồi quay lại map;
7. task rail collapse/expand;
8. đọc resource/top bar ở 1280×720;
9. kiểm hit target mobile;
10. kiểm map còn nhìn thấy đủ khi popup mở.

Đánh giá theo số thao tác + độ che map, không chỉ theo ảnh đẹp.
