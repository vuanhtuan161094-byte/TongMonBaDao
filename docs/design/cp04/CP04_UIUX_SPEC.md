# TÔNG MÔN BÁ ĐẠO — CP-04 Công Pháp & Kỹ Năng
**Ngày khóa thiết kế:** 31/10/2026 · **Owner:** chọn A, duyệt bố cục **Visual-first**
**Trạng thái:** **UI/UX DESIGN APPROVED**, HTML prototype; **NOT GAMEPLAY COMPLETE**, **NOT GODOT/ANDROID QA**.
**Lưu tại:** `design/cp04-visual-first-20261031` — branch chỉ dành cho tài liệu/giao diện, KHÔNG merge hoặc mở PR thực thi ở thời điểm này.

## 1. Tinh thần sản phẩm được duyệt
- Android landscape 1280×720, style giấy ấm, xanh ngọc đậm và điểm nhấn vàng tiết chế **đồng bộ HS-09 / Tông Vụ**.
- **Ưu tiên hình ảnh, ít chữ**; chừa ô rõ ràng để gắn icon PNG, ảnh bí kíp và animation/VFX. Nội dung dài mở bằng “Chi tiết” khi cần.
- Ký hiệu chưa có ảnh sử dụng chữ placeholder; không dùng tranh AI giả làm asset thực.
- Không thể suy ra “đã học”, “đã có bí kíp”, “đang trang bị” chỉ vì item hiện trong catalogue.
- Trong HTML mọi thao tác học/trang bị là demo preview; không ghi Save hoặc can thiệp state.

## 2. Bốn màn thiết kế
**Công Pháp:** danh sách bí kíp có thumbnail, bộ lọc hệ/nhánh/giai, ô xem ảnh lớn, hiện tên và yêu cầu ngắn, ba ô loadout **Chủ Tu + Phụ Tu 1/2**; mở thông tin tiền đề, chi phí và thời gian khi bấm Chi tiết. Màn hình thấp ưu tiên khung hình chính trước danh sách dài.

**Kỹ Năng:** lưới icon skill 4 cột, ô 72×72 tại 1280; một vùng VFX lớn, thông tin cốt lõi (tên, loại, CD/hệ số khi có dữ liệu được duyệt); xem Chi tiết để đọc đầy đủ. Phân biệt basic, active, ultimate, mobility, passive, innate.

**Tiến Hóa:** năm mốc trực quan Nhân → Tiên → Thần I → II → III, mỗi mốc có vị trí media; hai truyền thừa A/B; vùng hoạt ảnh biến đổi độc lập; hiển thị điều kiện/lock đúng catalogue. Đây là trình bày UI, không bật cây tiến hóa trong game.

**Nghiên Tu:** tiến độ công pháp, bí kíp nguồn, tiền đề, chi phí, thời gian, thông báo One Active Job. Tất cả cần đọc authoritative snapshot và feature gate khi tích hợp.

## 3. Media-slot contract

| Thành phần | Vùng hiển thị demo | Ảnh/animation gợi ý |
| --- | --- | --- |
| Ô kỹ năng | ~72×72 ở 1280 | 96×96 hoặc 128×128 RGBA PNG |
| Thumbnail Bí Kíp | ~53×53 | 128×128 PNG |
| Khung Bí Kíp | khu linh hoạt ~240×230 | 512×512+ PNG/WebP |
| Trình xem VFX | khu phản hồi ~540×248 | APNG, WebP động hoặc GIF ở HTML; sprite frame/atlas/VFX node trong Godot |
| 5 mốc tiến hóa | ~90×90/mốc | 5 PNG riêng, khác biệt rõ theo giai |
| Khung VFX tiến hóa | một vùng độc lập | animation cho Nhân/Tiên/Thần I/II/III và nhánh A/B |

Các kích cỡ trên là **mẫu để kiểm tra UI**, không phải thông số nhập asset cuối đã được test với Godot.

## 4. Luật backend KHÔNG được thay

- Nguồn catalogue kiểm tra: `godot/data/combat/v63_learning_catalog.json` (84 công pháp), `v63_human_combat_catalog.json` (9 nhánh, 105 skill), `v63_immortal_combat_catalog.json` (204 skill), `v63_divine_combat_catalog.json` (240 skill). Đây là **candidate/gated**, không phải số skill đã sẵn sàng chơi.
- 9 nhánh: Cung — Liệp Ảnh/Linh Tiễn/Thiên Vũ; Quyền — Bá Quyền/Kim Cang/Huyết Quyền; Độc — Độc Châm/Cổ Độc/Dược Độc.
- Học và nghiên tu theo `V63LearningSystem`, có điều kiện bí kíp, tiền đề, tài nguyên, tiến độ, receipts, và loadout **1 Chủ + 2 Phụ**.
- Kỹ năng V6.3 theo `V63HumanSkillCombatSystem`: một basic, bốn active, một ultimate, một mobility, năm passive, một innate là cấu trúc loại tối đa; giới hạn tổng 12 skill phải được xử lý chặt, không giả rằng mọi loại đều được trang bị đồng thời tự do.
- `V63FeatureGates.DEFAULT_FLAGS` tắt. Chỉ bật thành phần tác dụng khi persisted feature opt-in thực tế cho phép. Không biến giao diện review thành lệnh học kỹ năng.
- Tiên: truyền thừa A/B; Thần: I/II/III. Chi phí, hệ số, đặc tính hiệu ứng ở catalog còn là giá trị thử nghiệm.
- Giữ `One Active Job` và bảo vệ tiến độ khi đổi nghiên tu/công việc.

## 5. Nghiệm thu giao diện / trạng thái thực

**Đã kiểm thử trên Chromium:** viewport 1280×720, 960×540, 915×412, 812×375; không tràn ngang trong các luồng đã thử. Bốn tab, chọn nhánh/đệ tử, lọc active skills, chọn VFX, đổi truyền thừa B, tới Thần III, về bí kíp, preview trang bị và nạp thử PNG đều chạy trong HTML.

**Chưa nghiệm thu:** touch Android thật, import/render trong Godot 4.7.2, tải Source A/VFX thực, animation FPS/cost, save/load, dữ liệu V6.3 thật và mọi đường lệnh gameplay.

**Khi triển khai sau:** nối projection trạng thái nhân vật và catalogue, gate đúng quyền/điều kiện/học/skill slot, thử Save/Reload & negative paths; chỉ tạo PNG chuẩn khi nguồn asset được audit; giữ test/perf cho máy RAM thấp.

## 6. Bàn giao
- [HTML CP-04](./TMB_CP04_CongPhap_KyNang_VisualSlots_Offline.html)
- [Ảnh chụp Chromium](./screenshots/)
- [QA kết quả](./CP04_Design_QA.md)
- [Screenshot + SHA-256](./SCREENSHOT_MANIFEST.md)

Chỉ sửa nhánh thiết kế riêng; không sửa `main`, nhánh ONE GAME, PR #52, Godot source hoặc Codex worker.
