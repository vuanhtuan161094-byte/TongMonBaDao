# P3.2 — UI/UX + Art Production Spec (Mobile ngang)

Date: 2026-10-01
Status: PREPRODUCTION LOCK — IMPLEMENT ONLY AFTER P3.1 REAL GODOT GATE GREEN

## 0. Mục tiêu

P3.2 biến P3.1 từ một shell hình học thành một màn game tu tiên mobile ngang có thể nhìn, hiểu và thao tác như một sản phẩm thật.

P3.2 **không thay simulation**. Mọi hành vi vẫn đọc từ P0-P2.12/P3.1. P3.2 chỉ thay lớp trình bày, iconography, animation, skin, layout chi tiết và affordance.

UX reference chính: **Ta Làm Tông Sư Trong Tiên Môn** ở cấp cấu trúc tương tác.

Không sao chép asset, logo, chữ, icon, hình nhân vật, map hoặc bố cục pixel-for-pixel của sản phẩm tham chiếu. Dùng asset gốc nhưng giữ interaction hierarchy gần với reference.

---

# 1. Hướng trình bày chuẩn

- Mobile landscape.
- Logical base: **1280×720**.
- Map/tông môn là nội dung chính, chiếm khoảng 75–85% cảm nhận thị giác.
- UI bám mép, không biến màn chính thành dashboard.
- Panel mở đè lên map thay vì chuyển sang trang trắng riêng.
- Chạm trực tiếp công trình/đệ tử là đường vào chức năng chính.
- Số liệu quan trọng đọc trong 1–2 giây; số liệu sâu nằm sau tab/popup.

## 1.1. Ngôn ngữ thị giác

Phong cách gốc của Tông Môn Bá Đạo:

- tiên hiệp 2D vẽ tay;
- thủy mặc nhẹ + màu khoáng/vàng đồng;
- mái ngói xanh xám;
- gỗ nâu đỏ;
- giấy ngà;
- dấu son đỏ;
- khung gỗ/ngọc;
- không dùng UI kiểu SaaS/card hiện đại;
- ít gradient kỹ thuật số;
- nút chính màu son/cam ấm;
- thông tin phụ màu mực/xám xanh.

Nhân vật/map nên **bớt chibi hơn reference**: đầu chỉ lớn vừa phải, cơ thể rõ, trang phục tu tiên đọc được khi zoom map.

---

# 2. Màn Tông Môn — hierarchy bắt buộc

## 2.1. Lớp 1 — Map

Map phải là thứ người chơi nhìn thấy trước.

Có tối thiểu:

- Đại Điện;
- Đệ Tử Xá;
- Tu Luyện Đài;
- Kho;
- Luyện Khí Đường;
- Dược Phòng;
- Khai Khoáng;
- Đại Môn;
- đường đi;
- cây/đá/nước;
- khoảng sân đủ cho đệ tử di chuyển.

Công trình có silhouette khác nhau, nhìn lướt vẫn phân biệt được.

## 2.2. Lớp 2 — HUD mép màn hình

### Top bar

Trái:

- tên Tông Môn;
- cấp/phồn vinh hoặc biểu tượng uy danh;
- thời gian game nếu cần.

Giữa/Phải:

- Tiền;
- Linh Thạch;
- 2–3 tài nguyên đang quan trọng nhất;
- nút `+`/mở Kho để xem phần còn lại.

Không hiển thị 10 loại tài nguyên cùng lúc.

### Left task rail

- chương hiện tại;
- 2–4 mục tiêu;
- dấu hoàn thành;
- có thể thu gọn.

### Edge actions

Các entry chính:

- Đệ Tử;
- Kho;
- Công Trình;
- Thế Giới;
- Nhiệm Vụ;
- sau này Chiêu Hiền/Kỳ Vật.

Không che vùng map trung tâm.

## 2.3. Lớp 3 — Bubble/notification trên map

Công trình/đệ tử có thể hiện:

- hoàn thành sản xuất;
- tài nguyên chờ thu;
- có thể nâng cấp;
- cảnh báo thiếu nguyên liệu;
- đệ tử cần nghỉ/chữa;
- sẵn sàng đột phá;
- có sự kiện/cơ duyên.

Bubble phải bấm được để đi thẳng tới hành động liên quan.

## 2.4. Camera map — zoom, pan, focus

Camera chỉ tác động lên **map world**. HUD, task rail, menu, popup và các lớp UI phải giữ nguyên kích thước/vị trí khi zoom.

Canonical interaction:

- mobile: pinch 2 ngón để zoom;
- mobile: kéo 1 ngón trên vùng map trống để pan;
- desktop/test: wheel chuột để zoom, kéo chuột trái trên map trống để pan;
- double-tap/double-click vào công trình hoặc đệ tử: camera focus mềm vào mục tiêu;
- nút `+`, `−`, `Toàn cảnh` là fallback cho accessibility/test và không thay thế gesture.

Giới hạn zoom vertical slice:

- min `0.75x`;
- default `1.00x`;
- max `1.80x`;
- focus target mặc định khoảng `1.35x`.

Camera phải clamp để không thể kéo toàn bộ tông môn ra khỏi vùng nhìn thấy.

Zoom phải giữ điểm pinch/wheel ổn định trên màn hình thay vì luôn phóng quanh góc trái.

Double-tap focus không mở một simulation state mới và không teleport đệ tử. Đây chỉ là presentation camera.

Khi popup đang mở, map gesture bị khóa để tránh pan/zoom ngoài ý muốn.

---

# 3. Màn Đệ Tử — cấu trúc chuẩn

Landscape full popup/page overlay.

## 3.1. Cột trái — roster

- danh sách portrait dọc;
- tên ngắn;
- phẩm chất/tier bằng viền hoặc ký hiệu;
- icon cảnh báo nhỏ nếu bị thương/đại hạn/đang có sự kiện;
- scroll nhanh;
- người đang chọn được nhấn mạnh bằng viền vàng/son.

## 3.2. Khu giữa — character showcase

- artwork nhân vật lớn;
- tên;
- chức phận/rank;
- cảnh giới;
- hành động hiện tại;
- có thể thêm hiệu ứng khí chất rất nhẹ theo quality/realm.

Không nhét số liệu dày lên artwork.

## 3.3. Cột phải — thông tin nhanh

Phải đọc được ngay:

- Phẩm chất đệ tử;
- Cảnh giới;
- HP/Thể lực;
- Linh căn;
- Huyết Mạch;
- Thể Chất;
- 6 foundation;
- nghề/nhóm;
- hành động hiện tại;
- lệnh Tông Chủ hiện tại.

Thông tin ẩn chưa reveal phải hiện `Chưa xác định`, không leak latent state.

## 3.4. Hàng tab dưới

Canonical tabs:

1. Thuộc tính;
2. Tu luyện;
3. Công pháp;
4. Trang bị;
5. Pháp bảo;
6. Huyết Mạch;
7. Thể Chất;
8. Nghề;
9. Quan hệ;
10. Ký ức.

Không bắt buộc tất cả hiện cùng lúc; dùng paged/scroll tab nếu màn nhỏ.

## 3.5. Quick order

Nút hành động nhanh:

- Tu luyện;
- Nghỉ;
- Về tông;
- Đi săn/đi khu vực;
- Làm nghề;
- giữ tại tông;
- sau này trang bị tay/khóa đồ.

Quick order phải gọi authority simulation thật, không chỉ đổi text UI.

---

# 4. Popup công trình

Bấm công trình trên map mở popup giấy/cuộn thư.

Mỗi popup có cùng skeleton:

1. tên + cấp;
2. ảnh/icon công trình;
3. trạng thái hiện tại;
4. đệ tử đang làm;
5. output/input thật;
6. nút hành động chính;
7. nút nâng cấp/đổi người nếu hệ đó đã được triển khai.

Ví dụ Luyện Khí Đường:

- người đang làm;
- cấp nghề;
- điểm hỗ trợ rèn;
- Thanh Thiết;
- queue nếu có;
- Đổi đệ tử;
- Nâng cấp.

Ví dụ Kho:

- tài nguyên nhóm theo category;
- capacity;
- filter nhanh;
- không hiện toàn bộ inventory thành một trang chữ dài.

---

# 5. Chuyển động đệ tử trên map

P3.1 đã có destination mapping. P3.2 chỉ thay presentation.

## 5.1. State-to-animation

- IDLE/EVALUATE: đứng/nhìn quanh nhẹ;
- WALK/TRAVEL map-local: chạy/đi;
- CULTIVATE: ngồi thiền/khí xoáy;
- WORK_MINING: vung cuốc/đập quặng;
- WORK_FORGING: búa/lò;
- REST: ngồi/ngủ/ngả lưng;
- HEAL: ngồi trị thương/hiệu ứng xanh;
- HUNT/COMBAT outside: avatar đi về Đại Môn rồi ẩn khỏi nội map;
- RETURN_SECT: xuất hiện ở Đại Môn rồi đi vào.

## 5.2. Readability

Khi zoom map bình thường:

- tên chỉ hiện khi chạm/hover hoặc khi cần;
- icon action nhỏ trên đầu;
- không hiện 5 dòng text trên mỗi người;
- cảnh báo quan trọng mới dùng màu đỏ/vàng.

---

# 6. Art asset production rules

## 6.1. Buildings

Mỗi building cần tối thiểu:

- base illustration;
- selected highlight;
- shadow;
- construction/upgrade indicator;
- 1 idle ambient animation hoặc VFX nhẹ;
- hitbox riêng không phụ thuộc alpha texture.

## 6.2. Characters

Map actor:

- idle;
- walk/run 8 hướng hoặc tối thiểu 4 hướng + mirror nếu phù hợp;
- cultivate;
- work generic;
- mining;
- forging;
- rest;
- heal;
- combat-ready/leave-gate.

Profile artwork là asset riêng, không dùng sprite map phóng to.

## 6.3. UI skin

Cần asset gốc cho:

- parchment panel 9-slice;
- dark jade top bar;
- tab normal/selected;
- button primary/secondary/disabled;
- portrait frame theo quality;
- notification dot;
- resource chip;
- title plate;
- close button;
- scroll/rail;
- tooltip.

---

# 7. Màu và hierarchy

Màu chức năng đề xuất:

- mực đen/nâu: text chính;
- giấy ngà: panel;
- ngọc xanh: navigation/neutral system;
- vàng đồng: selected/high value;
- son đỏ/cam: primary action;
- đỏ: lỗi/nguy hiểm;
- xanh lục: hồi phục/thành công;
- tím/xanh lam sâu: hiếm/mystic effect, dùng tiết chế.

Không biến rarity thành cầu vồng phủ toàn UI.

---

# 8. P3.2 definition of done

P3.2 chỉ được gọi PASS khi:

1. P3.1 đã runtime green trước đó;
2. main scene vẫn 1280×720 landscape;
3. không còn placeholder rectangle cho các thành phần production-critical chính;
4. map/công trình/đệ tử đọc được bằng hình;
5. actor animation đổi đúng theo simulation state;
6. popup công trình hiển thị state thật;
7. disciple screen có roster/showcase/details/tabs đúng hierarchy;
8. direct-order vẫn gọi existing authority;
9. safe-area/aspect ratio smoke tối thiểu 16:9 và 19.5:9;
10. map camera hỗ trợ pinch/pan/focus trong khoảng 0.75x–1.80x và không làm HUD phóng theo;
11. P0-P3.1 cumulative regression vẫn green.

---

# 9. Không làm trong P3.2

- không mở Destiny gameplay;
- không mở injury gameplay mới;
- không mở item gacha;
- không viết lại production economy;
- không thêm parallel world simulation;
- không cân bằng toàn game;
- không chép asset/reference pixel-for-pixel.

P3.2 là production presentation pass, không phải phase backend mới.
