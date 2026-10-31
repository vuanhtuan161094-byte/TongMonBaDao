# TÔNG MÔN BÁ ĐẠO — HỒ SƠ ĐỆ TỬ HS-09
**Owner approval:** 31/10/2026 — phương án A, duyệt phong cách mỹ thuật HTML/CSS và bố cục hiện tại.
**Trạng thái:** DESIGN APPROVED / HTML OFFLINE DEMO. **KHÔNG PHẢI GODOT RUNTIME PASS**.
**Nhánh lưu:** `design/disciple-profile-hs09-20261031`. Không merge, không thay đổi Godot/Codex.

## 1. Phạm vi và bố cục

- Android landscape 1280×720 là mục tiêu chính; kiểm tra layout 960×540, 915×412 và 812×375 trên Chromium.
- Bản HTML/CSS chạy offline, không phụ thuộc thư viện mạng. Các dữ liệu, tên, chỉ số trong demo là **MẪU**, không phải trạng thái save của game.
- 3 vùng cơ bản theo giao diện P3.2 hiện có: roster đệ tử (có thể thu gọn), showcase nhân vật, nội dung phải theo tab.
- **Tổng Quan** ưu tiên Tu Vi, Luyện Thể, Linh Căn, trạng thái hiện hành và radar nhỏ; thêm lối tắt để xem chuyên sâu.
- Tab **Thuộc Tính** có radar lớn + giá trị, điểm sinh, thay đổi, ý nghĩa và trạng thái hiện thực hóa hiệu ứng. 6 tab gốc cần giữ: Thuộc Tính, Công Pháp, Trang Bị, Huyết Mạch, Thể Chất, Quan Hệ. Tổng Quan là tab thứ bảy ở giao diện đề xuất.
- Các nhóm chi tiết từ backend như nghề nghiệp, chiến đấu, bẩm sinh/mệnh cách, Đan Bão Hòa, kỹ năng V6.3 có thể nằm trong subview / panel của tab liên quan, **không tạo ra hệ gameplay mới**.
- Avatar/chibi Source A là placeholder bằng chữ khi không có asset xác minh. Không dùng tranh AI làm sprite hoặc nguồn lực sản xuất.

## 2. Radar D7 — quyết định bắt buộc HS-04B

**Chung một tâm, hai đa giác độc lập**:
- **Tam Căn:** tam giác 3 trục gồm Tư Chất (`aptitude`), Căn Cốt (`constitution`), Tâm Tính (`mind_nature`). Màu cam.
- **Tứ Tính:** tứ giác 4 trục gồm Tiềm Lực (`potential`), Thông Tuệ (`comprehension`), Cơ Duyên (`fortune`), Mị Lực (`charisma`). Màu xanh ngọc.
- Hai tập dữ liệu/bể độc lập, hai thang vẽ riêng để dễ nhìn. Hiển thị trục, giá trị gốc, thang hiển thị; KHÔNG giới hạn hoặc thay đổi điểm thật.
- Biểu đồ nhỏ ở Tổng Quan; bấm mở tab Thuộc Tính để xem biểu đồ lớn, 7 chỉ số và mô tả.
- `DiscipleSixDimensionRadar.gd` hiện còn vẽ polygon 7 trục cho D7, nên **phải đổi renderer trình bày sau này**, không sửa FoundationSystem hay công thức D7.

## 3. Nội dung nhân vật cần có

| Khối | Nguồn dữ liệu/giải thích |
| --- | --- |
| Identity | tên, phẩm chất, nguồn tuyển, chủng tộc, giới, xuất thân, tuổi/tuổi thọ, tính cách, địa vị tông môn |
| Tu Vi & Luyện Thể | hai tiến trình độc lập; 30 bậc ×10 tầng; EXP, cổng đột phá, auto gate theo đúng snapshot |
| Bẩm sinh | Linh Căn 5 hành, dị căn; đặc chất thấy được; huyết mạch, thể chất, mệnh cách, thiên phú nghề |
| Life & action | HP, thể lực viễn chinh, Injury, PvE, lệnh hành động, vị trí, Linh Thạch cá nhân, cống hiến |
| Work | 6 nghề (Khai Khoáng/Lâm Nghiệp/Linh Thực/Luyện Đan/Luyện Khí/Hậu Cần), level, EXP, ưu tiên, công trình, Active Job |
| Công Pháp V6.3 | Chủ Tu + Phụ Tu 1/2, learned codex, mastery, nghiên tu; **feature-gated**, không khẳng định hiệu ứng đang chạy |
| Kỹ năng V6.3 | Nhánh, basic, active, ultimate, mobility, passive, innate; skill learned/equipped; đối chiếu catalogue trước khi hiển thị tên |
| Trang Bị | 3 ô **Vũ Khí/Giáp/Phụ Kiện**, equipped/locked; authentic V2 chưa có equipment consumer hoàn chỉnh trong snapshot |
| Quan hệ | thân thiết, tin tưởng, kính trọng, số tương tác và đồng hành |
| Đan Bão Hòa | trạng thái riêng 1,000,000 điểm/ngày khi feature có hiệu lực, số đã sử dụng, kiểm tra tick, không giả tự tiêu |
| Combat | chỉ số core, kháng và provenance; không cộng bừa innate/equipment P2 vào V2 |

## 4. UI/UX Android & mỹ thuật HS-09

- Phối màu giấy ấm, xanh ngọc đậm và vàng tiết chế; đồng bộ Tông Vụ; có phân cấp typography / tương phản rõ.
- Hàng tab và các nút đủ vùng chạm; màn hình thấp có thể thu roster để dành diện tích.
- Công cụ `Nạp JSON`, audit/QA nằm trong menu phụ; không hiển thị như hành động gameplay.
- Không che/mất radar nhỏ trong lần nhìn đầu tiên; vẫn có xem chi tiết.
- Không dùng nút có vẻ hoạt động nhưng chỉ giả sửa authoritative state. Ở HTML chỉ minh họa/trình bày/điều hướng.

## 5. Kết quả kiểm tra & giới hạn

- Chromium kiểm tra bố cục 1280×720, 960×540, 915×412, 812×375; tab, điều hướng, radar, nạp JSON đã được thử trong quá trình tạo HS-09.
- **Chưa chạy Godot GUI/mobile thật và chưa nối SimulationState.** Không tuyên bố Android hardware PASS.
- Ảnh Chromium là bằng chứng HTML render, không phải screenshot game đang chạy.
- Ảnh và bundle có manifest SHA-256 trong `SCREENSHOT_MANIFEST.md`; nếu ảnh chưa có trong chính repository, không tuyên bố GitHub lưu được binary.

## 6. Handoff giới hạn

Khi dự án ONE GAME integration ổn định và owner cho phép: build read-model thống nhất cho gameplay V2/D7 + V6.3 feature gate; giữ one-active-job; không phá save; thực hiện focused regressions + GUI capture trên SHA thực tế. Không tự ý sửa nhánh `integration/one-game-v65-20261030` hoặc `main`.
