# P3 — UI/UX Reference Audit: Ta Làm Tông Sư Trong Tiên Môn

Date: 2026-10-01
Status: RESEARCH NOTE / STRUCTURAL REFERENCE ONLY

Mục tiêu: ghi lại **pattern UX quan sát được** để P3 không dựa vào trí nhớ rời rạc.

Không copy asset, logo, text, icon, map art hoặc character art. Chỉ học cách phân tầng thông tin và thao tác.

## Nguồn tham khảo công khai đã xem

- Google Play / App Store listing của `Ta Làm Tông Sư Trong Tiên Môn` (Vision Game, package `com.vnzqzs.and`).
- AFKMobile review với ảnh màn Đệ Tử.
- Quantrimang screenshot màn Tông Môn.
- Phụ Nữ Thủ Đô promotional screenshot màn Ủy Thác/Sổ nhiệm vụ.
- LDPlayer promotional screenshot màn Phá Cảnh.
- BlueStacks beginner guide về loop công trình, nhân sự và nhiệm vụ chính.

Các nguồn này chỉ dùng để audit hierarchy; implementation phải dùng art gốc.

---

# 1. Màn Tông Môn

Quan sát chính:

- Landscape.
- Map chiếm gần như toàn bộ nền.
- HUD nằm sát viền thay vì dựng một dashboard lớn.
- Top bar rất mỏng: thông tin tông môn/cấp ở giữa hoặc gần giữa; tài nguyên ở góc/phía phải.
- Left rail chứa chapter/task theo dạng các nhãn ngắn.
- Nút xây dựng nằm sát góc dưới/phải.
- Công trình nằm trực tiếp trên map và có tên/bubble gắn lên công trình.
- Các resource/action bubble nổi ngay trong không gian map.
- Palette map khá nhạt/giấy, để icon hành động và công trình nổi hơn.

### Áp dụng cho Tông Môn Bá Đạo

Giữ:

- map-first;
- HUD edge-based;
- task rail;
- trực tiếp bấm công trình;
- bubble actionable;
- xây dựng là nút nổi cạnh map.

Thay đổi:

- art bớt chibi;
- công trình cũ/khí chất hơn;
- palette xanh xám + vàng đồng + giấy ngà;
- nhân vật map nhỏ nhưng tỷ lệ người rõ hơn.

---

# 2. Màn Đệ Tử

Quan sát chính từ screenshot công khai:

- roster portrait **dọc bên trái**;
- character art lớn ở trung tâm;
- tên + trạng thái/cảnh giới gần phía trên character;
- detail/progression panel nằm bên phải;
- hàng icon/tab hình tròn nằm dọc khu vực dưới character;
- panel toàn màn dùng nền giấy/parchment, không phải card UI hiện đại;
- rarity/quality được biểu đạt mạnh bằng khung và biểu tượng hơn là bảng số.

### Áp dụng

P3.1/P3.2 disciple screen dùng:

- left roster;
- center character showcase;
- right compact detail;
- lower tabs;
- quick orders gần detail nhưng không phủ character art.

Riêng game mình cần thêm vì simulation sâu hơn:

- Huyết Mạch;
- Thể Chất;
- 6 foundation;
- current action;
- direct command;
- nghề/nhóm;
- relation/memory tab.

Không được đưa tất cả thành text một lần. Default detail chỉ tóm tắt; tab mở sâu.

---

# 3. Popup Ủy Thác / Sổ nhiệm vụ

Quan sát:

- popup dạng cuộn giấy lớn ở trung tâm;
- map/gameplay tối phía sau;
- mỗi row có hình nhỏ bên trái;
- tên/cấp/progress ở giữa;
- action button màu cam/son ở phải;
- notification dot gắn trực tiếp row;
- có action hàng loạt như nhận nhanh/tăng tốc;
- mascot/speech bubble dùng để giải thích ngắn, không biến thành tutorial chữ dài.

### Áp dụng

Popup production/building list của mình nên dùng row pattern:

`icon -> tên/cấp -> progress/input/output -> action`

Mass action khi có nhiều row:

- Thu tất cả;
- Phân công nhanh;
- Nâng cấp nhanh nếu hợp lệ;
- không buộc người chơi bấm từng row khi tông môn lớn.

---

# 4. Màn Phá Cảnh

Quan sát:

- character/VFX chiếm thị giác chính;
- lựa chọn nâng thuộc tính/skill đặt quanh vùng trung tâm;
- một nút hành động chính rất nổi (`Bắt đầu...`);
- stat bonus hiển thị bằng icon + % lớn;
- không trình bày như bảng xác suất khô.

### Áp dụng

Khi làm Breakthrough UI sau này:

- giữ simulation xác suất thật;
- visual hóa nguồn bonus bằng icon/tag;
- nút `Đột phá` là primary action rõ;
- rủi ro, HP/stamina, failure consequence phải nhìn thấy trước khi bấm;
- không che giấu xác suất nếu game mình có thể tính được.

---

# 5. Interaction density

Reference có nhiều chức năng nhưng không mở tất cả trên mặt map.

Pattern:

1. map;
2. compact HUD;
3. notification/bubble;
4. popup;
5. tabs/secondary details.

Đây là hierarchy canonical cho game mình.

Không dùng:

- sidebar desktop cố định rộng;
- nhiều panel ngang nhau cùng mở;
- một màn có 30 số liệu text nhỏ;
- button lồng 3–4 cấp menu cho action thường xuyên.

---

# 6. Management loop quan sát được

Nguồn công khai mô tả loop:

- xây/khai thác;
- phân đệ tử vào hoạt động hậu cần;
- luyện đan/công trình tạo tài nguyên;
- nâng cấp tông môn;
- thu nhận/nuôi đệ tử;
- thám hiểm/chiến đấu.

Điểm đáng học cho UX:

- người chơi điều hành qua **map + người**, không qua spreadsheet;
- production state hiện tại phải nhìn thấy tại nơi nó xảy ra;
- nhiệm vụ đầu game dẫn player tới đúng công trình/chức năng.

Tông Môn Bá Đạo khác ở chỗ AI đệ tử sâu hơn; UI phải thể hiện `đang làm gì và vì sao`, không chỉ `đã được phân vào đâu`.

---

# 7. Canon decision cho P3

- UX structural reference: gần reference.
- Art: original.
- Mobile: landscape.
- Base: 1280×720.
- Map is the home screen.
- Direct manipulation first: tap building/tap disciple.
- Parchment overlay instead of navigation-away for routine management.
- Roster vertical left on disciple screen.
- Detail tabs instead of one giant character sheet.
- Quick actions use real simulation authority.
- Red dots only for actionable/new content; không spam chấm đỏ mọi nơi.
- When scale grows, mass actions/templates are mandatory.
