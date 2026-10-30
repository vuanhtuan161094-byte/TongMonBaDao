# TÔNG MÔN BÁ ĐẠO — TÔNG VỤ UI/UX V1.0 (Owner design checkpoint)
Date: 2026-10-30
Status: DESIGN APPROVED IN PRINCIPLE / CODE NOT IMPLEMENTED / NOT GUI-ACCEPTED
Scope: UI/UX and intended behavior only. NO runtime authority; NO change to main, RC #52, V6.5 feature, or the one-game integration branch.
Design branch: design/tong-vu-uiux-v1-20261030

## 0. Quyết định của Owner và mức nghiệm thu

Owner đã chấp thuận phong cách Tổng Quan, hướng bố cục Sản Xuất và bản mẫu tương tác Nhân Sự trong cuộc thảo luận ngày 30/10/2026.
- **Tổng Quan:** bố cục và visual concept APPROVED; chưa kiểm tra Godot GUI / Android.
- **Sản Xuất:** direction / screen APPROVED WITH UX FIXES; phải bỏ dữ liệu lặp, nút không hợp lệ, density quá cao trước khi implementation.
- **Nhân Sự:** functional UX WIRE­FRAME APPROVED; ảnh minh họa chính thức chưa hoàn thiện và chưa được Owner duyệt hình.
- **Backend wiring, exact-screen asset export, device QA:** PENDING. Không coi bản thiết kế là đã có gameplay.
- Owner dừng mở rộng TV-10 (mục tiêu/nhiệm vụ/phần thưởng), ưu tiên hoàn thiện UI hiện có.

## 1. Thanh menu gốc

Android landscape 1280×720; menu dưới 6 mục: Tông Môn / Đệ Tử / Kho / Công Pháp / **Tông Vụ** / PvE.
Tông Môn giữ MAP25 Source A làm mặt chính. Tông Vụ là màn hình quản lý tập trung, không thay thế thế giới.
Tông Vụ có đúng ba tab: **Tổng Quan / Sản Xuất / Nhân Sự**.

## 2. Quyết định đã khóa TV-01..TV-09

| ID | Quyết định |
| --- | --- |
| TV-01 | Ba tab Tổng Quan, Sản Xuất, Nhân Sự |
| TV-02 | Source A-inspired visual, phối với bố cục tối giản, chữ dễ đọc, không quá nhiều hoa văn |
| TV-03 | Màn quản lý toàn màn hình; nút **Tới** đưa camera đến đúng instance công trình, chọn đối tượng và mở panel; có đường trở về Tông Vụ, khôi phục tab/bộ lọc/vị trí danh sách |
| TV-04 | Thao tác một công trình, nhiều công trình và mẫu cấu hình, luôn preview trước batch |
| TV-05 | Gợi ý phân công ưu tiên đệ tử rảnh, đủ điều kiện, tinh thông đúng nghề, rồi hiệu suất sản xuất thực tính; tối ưu trên cả nhóm, tránh trùng người |
| TV-06 | Kế hoạch sản xuất theo sản phẩm/chu kỳ/ngưỡng tồn kho, chuyển sản phẩm hợp lệ khi đạt mục tiêu từ **chu kỳ kế tiếp**; không tự cắt chu kỳ |
| TV-07 | Nâng cấp riêng lẻ / hàng loạt / kế hoạch theo ngân sách, mốc cấp, điều kiện dừng; không vượt ngân sách |
| TV-08 | Cảnh báo và đề xuất điều hành với **tự động hóa vừa phải**; hoạt động lặp đã được duyệt mới được tự thực hiện; quyết định lớn thuộc người chơi |
| TV-09 | Dashboard kết hợp số liệu then chốt + tối đa 3 việc đáng quyết định + trạng thái tự động hóa + lối tắt |

**Không mở TV-10** cho đến sau khi hoàn thiện 3 màn và kiểm nghiệm gameplay.

## 3. Screen S1 — Tổng Quan

- Hàng thống kê ngắn: số công trình, đệ tử rảnh/đang làm, cảnh báo thật và tình trạng sản xuất. Chỉ hiển thị chỉ số lấy được từ authoritative SimulationState.
- Vùng "Việc cần quyết định": tối đa ba cảnh báo/đề xuất thực sự có hành động; có nút điều hướng thẳng đến xử lý.
- Vùng "Tự động hóa": chỉ tóm tắt trạng thái các kế hoạch thực đang vận hành, không spam.
- Phím nhanh đến phân công / công trình / nâng cấp / kế hoạch sản phẩm; không thêm tab mới.
- Số 100 công trình, 60 đệ tử, kho 75%, v.v. trong mockup là giả định; không dùng làm game defaults.

## 4. Screen S2 — Sản Xuất

- Dùng một danh sách duy nhất của instance công trình, **không lặp** thông tin tại hai bảng "Kế hoạch" / "Nổi bật".
- Sidebar theo nhóm: Tất cả, Mỏ, Linh Lâm, Linh Điền, Luyện Đan, Luyện Khí (nếu thực sự có backend).
- Tìm kiếm, lọc trạng thái/nhân sự, sắp xếp; danh sách cuộn độc lập. Mỗi hàng hiển thị: instance, cấp, nhân sự, công việc/sản phẩm hợp lệ, tiến độ/sản lượng đúng snapshot.
- Mỗi hàng chỉ cần **Tới** và **Quản lý**; hành động Nâng cấp / Phân công / Chọn cây / Chọn công thức trong panel chi tiết. Gạt/khóa nút khi backend chưa cho phép.
- Mỏ/Linh Lâm không hiện "Đổi sản phẩm" khi loại hàng không selectable. Mở chọn cây cho Linh Điền và chọn công thức cho Luyện Đan theo real registry.
- Panel chi tiết có lựa chọn công trình, quy tắc tự động đã duyệt, chi phí/điều kiện, thông báo lỗi real authority. "Quản lý" không trực tiếp sửa state UI.

## 5. Screen S3 — Nhân Sự

- 3 metric nhỏ: Tổng số / Đang làm / Rảnh; không lạm dụng thống kê.
- Chọn nhóm nghề/công trình; checkbox lọc người rảnh; tìm kiếm, sort theo proficiency của nghề được chọn.
- Danh sách đệ tử thể hiện chân dung Source A đã kiểm chứng khi có, tên, cấp tinh thông nghề, trạng thái, vị trí công việc; người đang làm **không là ứng viên mặc định**.
- Ưu tiên: (1) eligible + idle (2) proficiency phù hợp (3) bonus tốc độ/sản lượng thật trong backend (4) tối ưu tổng thể, không local greedy khi batch.
- Người chơi được xem trước danh sách instance → disciple, tác động, trạng thái và confirm; có thể sửa gợi ý hoặc chọn thủ công.
- Không tự chuyển đệ tử có One Active Job. Nếu yêu cầu chuyển thủ công phải hiển thị mất tiến độ và xác nhận.
- Tên, level và số lượng trong interactive wireframe là dữ liệu mẫu, không phải thực trạng.

## 6. Backend mapping (snapshot kiểm tra 30/10/2026)

Reference: integration/one-game-v65-20261030 (starting RC #52 source). Need re-check exact SHA at implementation.

| Intent UI | Authority/hiện trạng | Rule |
| --- | --- | --- |
| Building list, instance, workers | BuildingSystem + SimulationState, assigned_worker_ids, active_worker_ids, can_disciple_work | Đọc từ state thật, không tự tạo building |
| Đổi cây Linh Điền | BuildingSystem.set_spirit_field_policy; auto_demand, priority, fixed | Fixed/priority chỉ đủ điều kiện khi field Lv>=10; Lv thấp không mở sai nút |
| Nhu cầu kho cây | BuildingSystem._select_crop theo stock_target và warehouse quantity | Mức mục tiêu != sức chứa kho; chưa có engine điều phối toàn tông môn |
| Luyện Đan | BuildingSystem.set_alchemy_recipe, set_alchemy_recipe_enabled | Công thức mới cho future jobs, không thay running job |
| Nâng cấp | can_start_upgrade, start_upgrade, upgrade_cost | Linh Lâm và Luyện Đan hiện có upgrade_enabled=false; không show action như có sẵn |
| Luyện Khí | EquipmentSystem craft + 5 recipe được ghi trong P3.4C | Không giả thêm job queue/recipe |
| Điều hướng camera | P3.2 map focus / building operation | Cần connector từ Tông Vụ; giữ ability trở lại tab đang thao tác |
| Cảnh báo Kho | Kho và Living Cues P3.5 **không có generic warehouse capacity** | **Không** hiển thị "Kho đầy", "75% dung lượng" nếu chưa có capacity authority |
| Batch/auto policy | Các thao tác per-building hiện có; coordinator tổng hợp chưa chứng minh | Thiết kế tương lai; phải implement/test mới bật |
| Save/offline/receipt | SaveService/Warehouse canonical; exactly-once QA existing | Không giả nhận hàng, trừ tiền hay thay state ở presentation |

**Backend blockers P0:** không có batch optimizer/profession matching fully wired; policy orchestration across plants/buildings chưa verified; disabled upgrades; warehouse max-capacity UI giả.
**P1:** lọc/tìm kiếm/danh sách, touch targets/scroll, context restoration, camera connector, preview/cancel batch, logs.

## 7. Visual requirements and mockup provenance

- 16:9 landscape 1280×720, parchment cream, jade green, restrained gold, Source A chibi/pagoda style; map-first khi trở về thế giới.
- Bố cục ngắn, nút đủ lớn cho cảm ứng; không bắt người chơi gõ hay scroll lồng nhau nhiều.
- Các preview image trong phiên chat 30/10/2026 là **AI-generated concept**, không phải Source A binary, không phải Godot screenshot và không phải asset đã sẵn sàng nhập.
- Screen Tổng Quan mockup đã được owner chấp nhận; Screen Sản Xuất cần sửa UX/button policy; Screen Nhân Sự đã duyệt interactive wireframe, **chưa có ảnh final**. Bản PNG trong chat chưa được commit cùng tài liệu này.
- Không bỏ qua audit provenance, image import, DPI, fonts và manual input QA.

## 8. Định nghĩa nghiệm thu sau này

1. Exact source SHA, authoritative callbacks, không fake simulation; non-working button disabled/hidden.
2. Demo luồng: Tông Vụ → Sản Xuất → instance → Tới → map focus + panel → Quay lại Tông Vụ.
3. Demo luồng: Tông Vụ → Nhân Sự → lọc idle → đề xuất theo nghề → preview → phân công real, không ảnh hưởng Active Job khác.
4. Linh Điền chọn mode hợp lệ, persist Save/Reload, chu kỳ dở không bị hủy.
5. Upgrade check/cost/payment and blocked upgrade cases; no duplicate receipt.
6. 1280×720 Godot GUI screenshot + Windows mouse + Android touch, performance/RAM; owner visual approval.
7. Test focused + integration trên chính exact SHA sau khi Codex hoàn tất ONE GAME integration.

## 9. Workflow & ownership

This is **documentation-only design checkpoint** in an isolated GitHub branch. No Godot edits, no PR/merge, no CLI worktree on user PC. No instruction for active Codex to pause or switch context. Handoff implementation chỉ sau khi owner duyệt thiết kế hoàn chỉnh và integration ổn định.

Related references:
- Integration Hub: https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56
- PvE RC: https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/52
- Prior UI/Source A: https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/28
- Specs: docs/P3_4_BUILDING_MANAGEMENT_SPEC.md, docs/P3_5_LIVING_SECT_CUES_SPEC.md.
