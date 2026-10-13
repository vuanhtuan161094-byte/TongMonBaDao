# TÔNG MÔN BÁ ĐẠO — Xây dựng, di chuyển công trình và mở đất (DESIGN PROPOSAL V1)

**Ngày:** 2026-10-13. **Trạng thái:** DESIGN ONLY — CHỜ CHỦ DỰ ÁN DUYỆT, KHÔNG CẤP QUYỀN CODE.  
**Nền:** `main` sau SAFE-01/SAFE-02 CLOSED; ENV-02A 192×192, Windows/Android PENDING USER.  
**Sản phẩm:** Android, LANDSCAPE, thiết kế 1280×720; Godot 4.7.2.  
**Không mở:** FE-02, ENV-02B–E, DV2-03 (PAUSED NOT CLOSED), artwork S3, pipeline Spine.

## 1. Căn cứ thực tế và bài học nguồn tham khảo

- **Source Ta Là Tông Sư — VERIFIED client:** `ZQZS-Source-Knowledge/docs/HOME_BUILDING.md` và `analysis/SystemResearch/HOME_BUILDING_DEEP_DIVE.md`. Source có `buid_size`, `doorway`, `x/y/orientation`, kiểm tra vị trí, lệnh xây/di chuyển, bản thiết kế local, vẽ đường, mở area và điều động AI theo công trình. Không có thân thuật toán `_MapManager.IsCanPlace/FindPath`, không có bằng chứng đầy đủ về giao dịch vật tư phía server. Học luồng thao tác và phân quyền dữ liệu; **không bê networking, thuật toán chưa xác minh hoặc balance**.
- **Game hiện tại:** `BuildingState` lưu ID/loại/cấp/nhân sự/sản xuất, **không có tọa độ**. `BuildingSystem` hiện quản lý các instance thật, tăng cấp và sản xuất; một số consumer vẫn chọn `primary_building`. `WarehouseSystem` là kho nguyên liệu duy nhất. Ba sprite Source A của ENV-02A chỉ là preview lab, **không tự động tương đương ba BuildingState production**.
- **Authority ADR-0003:** fixed-layout V1; geometry trong `SectLayoutDefinition`/map model là presentation. Nếu tương lai cho phép người chơi sửa bố cục thì phải **duyệt cơ chế persistent layout/migration và chuyển quyền sở hữu vị trí một cách độc quyền**. Tài liệu này chỉ đề xuất quyết định tiếp theo; không tự ý sửa ADR.
- **Gameplay master:** `docs/P3_7_BUILDING_TREE_SPEC.md`: công trình Lv1–100 theo instance, một số trung tâm độc nhất, nhiều instance được mở theo tiến trình. **Không đồng nhất xây mới với nâng cấp**, không tự bịa nguyên liệu/giá hay mở sẵn 463 công trình từ Source.

## 2. Trải nghiệm người chơi: 3 thao tác, 1 menu

Tại bản đồ tông môn, màn hình bình thường vẫn map-first, HUD sát mép, không mở sidebar khi chưa chọn.

1. Chạm **Xây Dựng** → menu gọn có **Công trình / Đường / Mở đất**.
2. Chọn công trình → preview chân nhà/footprint (xanh = hợp lệ, đỏ = bị chặn) → chạm ô đặt → **Xác nhận** hoặc **Hủy**. Chỉ hiện nút xoay nếu art/footprint hỗ trợ hướng đó.
3. Chạm công trình có thật → **Quản lý** hoặc **Di chuyển**; dời nhà bằng preview ở vị trí mới → xác nhận. Giữ nguyên `building_instance_id`, cấp, nhân lực, việc đang làm và sản phẩm; không tự reset timer.

Android: một ngón vuốt map khi không ở chế độ đặt; khi chọn preview, chạm vùng đích để đặt, không hiểu nhầm pan là xây. Hai ngón pinch vẫn zoom; HUD/panel nằm ngoài camera. Có vùng bấm tối thiểu đủ chạm và hiển thị lý do không đặt được. PC sử dụng chuột chỉ để phát triển/test cùng luật.

## 3. Quy mô bản đồ / đất

- World logic **192×192** (36.864 ô), chỉ là kiến trúc thử nghiệm có khả năng mở rộng; bản đồ render bằng chunk **16×16** (144 chunk). Chunk là **đơn vị culling**, **không phải** đơn vị sở hữu đất hoặc mở khóa kinh tế.
- Khu mở đầu **Rect2i(72,72,48,48)** như ENV-02A; kích thước 2.304 ô, không giả vờ cả map đã được mở. Trong khu này có đất trống, sân/đường và các công trình đã xác minh.
- **Đất mở:** danh sách `region_id` cùng polygon/hình chữ nhật authored, có thể độc lập với ranh giới chunk. Ví dụ vùng thử nghiệm lân cận khu mở đầu: Bắc `(72,40,48,32)`, Đông `(120,72,32,48)`, Nam `(72,120,48,32)`, Tây `(40,72,32,48)`; **chỉ là khu gợi ý để duyệt, không có giá hay quyền mở khóa đã xác lập**. Các góc và vành ngoài dành cho về sau.
- Người chơi có thể ngắm xa vùng khóa qua camera nhưng chưa được xây trên đất chưa mở; địa hình khóa có lớp chỉ báo nhẹ. Khi mở vùng, ghi ID vùng, không phải ghi hàng nghìn boolean ô.
- Kiểm tra mở vùng: region tồn tại, chưa mở, tiếp giáp ít nhất một vùng đã mở, không làm mất đường hợp lệ. **Giá mở đất, mốc tiến trình và thời gian chưa có authority** → trạng thái **TBD**, tuyệt đối không kích hoạt gameplay tính tiền giả.

## 4. Quyền sở hữu dữ liệu: chỉ MỘT sự thật

**Đề xuất nếu ADR-0003 được sửa bằng phê duyệt riêng:** một `SectLayoutState` nhỏ được sở hữu bởi `SimulationState`, chỉ có:
- `layout_schema_version`, `map_content_id`, `layout_revision`;
- `placements`: map `building_instance_id -> {x:int,y:int,orientation:int}` đối với **building gameplay thật**;
- `unlocked_region_ids`: tập ID đã mở (serialize sắp xếp);
- `roads`: tập tọa độ ô đường đã xác nhận (serialize sắp xếp).

**Không lưu trùng:** cấp, tài nguyên, worker, queue vẫn ở `BuildingState`/`WarehouseSystem`; địa hình, loại/tên/footprint/doorway/art và các landmark không quản lý vẫn là content definition. `TransferMapModel` được dựng như **projection/cache kiểm tra geometry** từ content + persistent layout, không được tự ghi save hay giữ authority thứ hai. Nút ở UI chỉ gửi lệnh tới một owner giao dịch, chờ kết quả rồi redraw.

Với **save cũ**, layout mặc định chưa kích hoạt. Sau khi người dùng phê duyệt migration, hệ thống seed **một lần** các công trình có `BuildingState` thật theo layout được thẩm định; kiểm tra đủ ô, không chồng lấn, doorway hợp lệ; lỗi → fail closed và giữ save SAFE-01. Khi đã bật editable layout, không đồng thời đọc vị trí từ fixed-layout làm nguồn song song. Asset `main_hall/warehouse/forge` trong lab phải được phân loại `managed_building` (có đúng ID canonical) hoặc `landmark` (visual-only); **không gán level/production giả cho landmark**.

## 5. Luật đặt nhà, dời nhà, đường và giao dịch

**Placement preview chỉ đọc**. Validator dùng geometry hiện có: tọa độ trong map, region mở, footprint không chồng nhà/ô cấm/cổng quan trọng, cửa ở ngoài footprint và không bị chiếm, đường từ điểm nối chính tới tất cả doorway quan trọng vẫn thông (AStar). Khi dời, tạm loại footprint chính nó bằng `ignore_id`. Recheck toàn bộ trên canonical state ngay trước commit; số `layout_revision` đổi thì preview cũ hết hiệu lực.

**Dời nhà V1:** thay đổi vị trí/hướng, giữ nguyên `building_instance_id`, `BuildingState` và nhiệm vụ đang chạy. Khuyến nghị **miễn phí** trong giai đoạn đầu để giảm scope; đây là đề xuất cần duyệt, chưa phải luật gameplay chốt.

**Đường V1:** vẽ/xóa theo danh sách ô qua preview, không xuyên footprint/cổng/đất khóa; làm đổi chi phí hình ảnh cho AStar, **không tự tạo bonus tài nguyên hoặc thưởng công việc**. Phí làm đường chưa được phê duyệt; đề xuất ban đầu coi là chỉnh bố cục miễn phí, cho chốt riêng.

**Xây mới:** chỉ khi `BuildingSystem` hỗ trợ loại/instance đó và bảng chi phí **đã được phê duyệt**. Giao dịch duy nhất: kiểm tra phép xây và giới hạn instance/đất → kiểm tra Warehouse reserve/lock và Linh Thạch → trừ đúng một lần → tạo `BuildingState` ID duy nhất và thêm vị trí trong layout → lưu trong cùng `SimulationState`. Nếu thất bại, rollback toàn bộ. Preview không tiêu hao. Không dùng `start_upgrade` để giả lập xây công trình mới. Các consumer hiện dùng `primary_building` phải được đánh giá trước khi bật nhiều instance; không tự mở vô hạn instance. Lệnh lặp do chạm kép/tải lại phải không bị trừ tài nguyên lần hai (request receipt có giới hạn hoặc nguyên tắc idempotency đã kiểm thử).

**Mở đất:** chỉ thay đổi danh sách vùng sau khi mọi điều kiện và chi phí authored được kiểm tra tại gameplay authority. Không phát thưởng/EXP/cấp building chỉ vì mở vùng. Không có bảng giá được duyệt → nút chỉ là UI/preview thiết kế, chưa được phép giao dịch thật.

## 6. Thứ tự triển khai sau khi chủ dự án duyệt code (CHƯA MỞ)

| Packet đề xuất | Nội dung tối thiểu | Gate |
|---|---|---|
| **LAY-01** | Duyệt thay đổi ADR và schema `SectLayoutState`; seed/migrate an toàn các BuildingState thật, đối chiếu 3 visual lab; chưa cho xây | Save cũ/nguyên trạng; 1 authority; không chồng footprint; Godot CI |
| **LAY-02** | Tap/chọn/dời công trình hiện có, preview xanh/đỏ, pan/pinch, lưu tọa độ | Dời–lưu–tải; không mất sản xuất/nhân lực; cửa/AStar vẫn thông |
| **LAY-03** | Xây instance mới theo bảng giá/giới hạn đã duyệt, road editing đơn giản | Kho trừ đúng một lần, request replay, undo preview; sản xuất nhiều instance test riêng |
| **LAY-04** | Author vùng mở đất, unlock transaction, chỉ báo vùng khóa; Android acceptance | Không mở trùng, save/load, hiệu năng khu lớn, thao tác cảm ứng |
 
Mỗi packet được **duyệt riêng**, không code khi ENV-02A Windows chưa có kết quả, không coi ảnh đẹp là đủ nghiệm thu gameplay. **FE-02 production asset integration là quyết định riêng**, không bị LAY-01 tự mở. DV2-03 PAUSED NOT CLOSED.

## 7. Những quyết định còn chờ chủ dự án

1. Đồng ý hướng **xây dựng tự do dựa trên một persistent `SectLayoutState`** và chuyển authority layout đúng ADR-0003 ở phase tương lai?
2. Cho **di chuyển nhà + lát đường miễn phí V1** để đơn giản, còn xây mới/mở đất phải có bảng chi phí gameplay duyệt riêng?
3. Giữ **192×192 và vùng đầu 48×48** làm cơ sở thử nghiệm, sau này tăng theo benchmark, không khóa cứng số lượng vùng/nhà?

**Đề xuất:** duyệt ba nguyên tắc thiết kế, **chưa cấp phép code**; đợi ENV-02A Godot Windows/Android runtime QA. Các giới hạn về thời gian/hiệu năng 1.000–3.000 đệ tử vẫn chưa được xác nhận.

## 8. Bằng chứng / đường dẫn

- [Source Home/Building](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/docs/HOME_BUILDING.md)
- [Source deep dive](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/analysis/SystemResearch/HOME_BUILDING_DEEP_DIVE.md)
- [ADR-0003 Godot Native](../decisions/0003-fe00-godot-native-data-driven-frontend.md)
- [Canonical building tree](../P3_7_BUILDING_TREE_SPEC.md)
- [Main map UX](../P3_UX_MAIN_MAP.md)
- [Lab ENV-02A](../../labs/env02a/scripts/env02_world.gd)
- [BuildingState](../../godot/src/simulation/state/building_state.gd)
