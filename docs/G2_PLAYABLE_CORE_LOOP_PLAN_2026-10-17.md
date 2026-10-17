# G2 — PLAYABLE CORE LOOP | KẾ HOẠCH, CHƯA CẤP PHÉP CODE

**Ngày:** 17/10/2026 · **Repo:** `vuanhtuan161094-byte/TongMonBaDao` · **Baseline:** `main` 461caca1171462e0da092f21108c5c1733157ad9 · **Phần tích hợp để đánh giá:** draft PR #20 HEAD 78254c615e49ed40304a4e60966115dd41a8c657 (stacked trên PR #19, **chưa merge**) · **Target:** Godot 4.7.2, Android ngang 1280×720.

**Mục tiêu G2:** người chơi thực hiện một vòng **Dẫn Tiên → nhận đệ tử → phân công một công trình → sản xuất hoàn thành → nhập Kho → dùng nguyên liệu có thật → phát triển một công trình/đệ tử → thấy tiến triển trong Điều hành → lưu/khôi phục**. G2 **không** đồng nghĩa mở quyền xây thêm công trình, thêm quest/currency hoặc thay luật kinh tế.

## 1. Audit dựa trên code (phân biệt `main` và nhánh)

| Mắt xích | Đã có thật | Khoảng trống G2 |
|---|---|---|
| **Tuyển** | `RecruitmentSystem.accept_candidate/guidance_recruit_with_order`; candidate/đệ tử canonical; Dẫn Tiên UI và test `sect_playable_home_loop_test.gd`. Cơ chế tuyển cơ bản có ở `main`; luồng thuận tiện nằm trong stacked PR. | Thiếu chỉ dẫn liên tục từ đệ tử vừa tuyển tới một nhu cầu sản xuất **cụ thể**, không tạo người giả. |
| **Phân công** | `WorkforceSystem.transfer_production_worker`, one-active-job guard; PR #20 G1.5–G1.8 có chọn/đổi người, nút Start và bảng **Cần xử lý** theo đúng building ID. | Chờ G1 Windows Acceptance; người chơi chưa có một tuyến hành động nhất quán tới điểm tiêu thụ tài nguyên. |
| **Sản xuất + Kho** | `BuildingSystem`: Mỏ/Linh Lâm timer, Linh Điền plot, planned output snapshot; `SimulationScheduler` là đồng hồ duy nhất (1 tick = 1 phút), `WarehouseSystem` là kho duy nhất; save/offline/receipt có code & test focused. | Bảng tiến độ G1 mới chỉ qua static, **Windows mới nhất PENDING**; cần chứng minh produce–stock–spend cùng một phiên/roundtrip. |
| **Tiêu dùng** | `EconomySystem.buy_from_npc_v1/sell_to_npc_v1` với tồn kho thương nhân, hạn mức, budget và receipt; `BuildingSystem.start_upgrade` thật: phí gỗ/quặng/Linh Thạch và thời gian; `perform_alchemy_step` trừ inputs thật; `EquipmentSystem.can_craft` + UI Forge. Phường Thị/nâng cấp Mỏ đã có UI. | Các nơi tiêu dùng còn rời rạc; thiếu chỉ dẫn **tồn/dùng/cần**, liên kết từ sản phẩm vừa thu sang công năng cụ thể; Linh Lâm/Linh Điền chưa có UX nâng cấp đồng đều như Mỏ. |
| **Tăng trưởng** | Nâng cấp BuildingState tiến triển theo scheduler; tốc độ/sản lượng theo `ProductionPlanRegistry`; profession EXP/tu vi V2 có authority. | Thiếu hiển thị rõ **trước/sau** tăng trưởng dựa trên dữ liệu thật, không nên lập quest/progress bar độc lập. |
| **Xây thêm / mở đất** | `ResourceBuildingExpansionPolicyV2.preview` trên stacked PR chỉ tính cap giả định; `create_building` là factory và fixture nội bộ, **không phải giao dịch xây cho người chơi**. File mở rộng này không có trên `main`. | **BLOCKED** cho đến khi SectLayoutState, Đại Điện thực, đất, phí xây và giao dịch bền vững được phê duyệt riêng. Không dựng nút Xây mới hoạt động trong G2. |

**Nguồn kiểm tra:** `docs/GAME_SYSTEM_ARCHITECTURE.md`, `docs/G1_ACCEPTANCE_MINIMAL_PLAN_2026-10-17.md`, `CURRENT_CHECKPOINT.md`; code tại `godot/src/simulation/{recruitment,building,core,economy,resource}/`, `godot/src/presentation/p3_2_landscape_sect.gd`; các bài test `sect_playable_home_loop_test.gd`, `gui_workforce_v1_e2e_test.gd`, `gui_multiple_resource_instances_test.gd`, `economy_a_playable_test.gd`. Có code/test lịch sử **không có nghĩa HEAD G1 mới đã runtime PASS**.

## 2. Packet code nhỏ theo thứ tự (ĐỀ XUẤT, cần chủ dự án cấp phép riêng)

| Thứ tự | Packet | Đầu ra cụ thể | Phạm vi/Gate focused |
|---|---|---|---|
| **G2-00** | **G1 prerequisite, QA-only** | Một lần `Run-G1-Acceptance-Windows.cmd`: 4 test + chơi thử 5–10 phút; nếu lỗi chỉ sửa blocker có bằng chứng. **Không tuyên bố G1 ACCEPTED trước review của chủ dự án.** | Script đã có. Không CI/FULL/Android/merge. |
| **G2-01** | **Chuỗi hướng dẫn từ tài nguyên thật** (ưu tiên số 1 sau G1) | Trên `Điều hành`: thẻ bước kế tiếp hiển thị *Tuyển → Giao người → Chạy mẻ → Có hàng → Dùng hàng*. Nút mở thẳng màn/công trình có thật; nhu cầu lấy từ `can_start_upgrade`, recipe inputs, kho/market và job snapshot. Không tạo nhiệm vụ, phần thưởng hoặc progression mới. | Presentation + 1 test read-only state `to_dict`/đúng ID. |
| **G2-02** | **Produce → Spend UX** | Khi có Thanh Thiết/Linh Mộc/Thảo, cho mở nhanh **Nâng cấp Mỏ**, **Luyện Đan**, **Luyện Khí** hoặc **Phường Thị** ở đúng màn hiện có; cho thấy *cần / tồn / khả dụng*, lý do thiếu và receipt/chi phí **sau khi hệ thống thật chấp nhận**, không cộng/trừ UI. | Presentation only + focused Mine upgrade / alchemy / market receipts; không đổi giá/balance. |
| **G2-03** | **Growth UX cho công trình hiện có** | Dùng lại `BuildingSystem.can_start_upgrade/start_upgrade` cho Mỏ và **chỉ những instance Linh Lâm/Linh Điền có `upgrade_enabled` và giá trị hợp lệ**. Trước/sau hiển thị Lv, chi phí, tiến độ và sản lượng kế hoạch từ registry; button disabled theo preflight. Không mở xây mới, không auto-upgrade. | Presentation + focused exact-ID upgrade, cost once, 1 scheduler, save/load. Nếu backend reject thì hiển thị reason, **không tự mở gate**. |
| **G2-04** | **Một E2E vòng kinh tế thực** | Một test tích hợp cô lập: tuyển hợp lệ → phân công → scheduler chạy mẻ → Kho + lượng đúng một lần → trả chi phí nâng cấp Mỏ hoặc tiêu thụ recipe hợp lệ → tăng cấp/đầu ra được phản ánh → save/reopen không trả lần hai. Không dựng fixture tạo tài nguyên miễn phí; dùng factory/seed thử nghiệm canonical được phép. | Tái sử dụng tests cũ, chỉ thêm test/đường khẳng định thiếu; official Godot focused + một play session. |

**Nguyên tắc tiết kiệm usage:** G2-01 → G2-03 chỉ sửa khi thật sự thiếu UX; không chép lại backend đã tồn tại. Không tự kích hoạt FULL QA; chỉ chạy test liên quan thay đổi. Không mở G2-04 thành một hệ thống achievement/mission mới.

## 3. Definition of Done và ngưỡng dừng

- **Nghiệm thu theo chuỗi có dữ liệu thật:** đệ tử/công trình định danh chính xác; lệnh được hệ thống nhận; sản phẩm chỉ nhập Kho sau scheduler; tiêu dùng thực trừ Kho + Linh Thạch đúng một lần; nâng cấp đúng instance, theo thời gian; reload/offline không nhân đôi.
- **UI dễ dùng:** mỗi bước có một điểm bấm rõ ràng, trả lý do nếu khóa, không có đường cụt; Android landscape 1280×720, nút chạm ≥44px khi khả thi; không giả kết quả chưa quyết toán.
- **Phải giữ nguyên:** 30 Tu Vi ×10 tầng, 30 Luyện Thể ×10 tầng, Lục Duy, Injury 0/1/120, một active job, một Warehouse, một scheduler, thị trường quota & budget hữu hạn, Economy V2, save/receipt exactly-once; không đổi cân bằng hay phí theo suy đoán.
- **Ngoài G2 / cần phê duyệt riêng:** xây mới/mở đất/Đại Điện và layout persistent, gameplay hunting/PvE mới, đổi mô hình kinh tế, thêm currency hay thưởng nhiệm vụ.
- **Gate honesty:** `G1 Windows Acceptance PENDING` cho HEAD 78254c6; G2 packet chưa CODE AUTHORIZED; không CI/merge. Khi G2 code thật chỉ được ghi PASS sau focused Godot chính thức + bằng chứng từ phiên chơi, không lấy static scan làm runtime.

## 4. Hành động kế tiếp

**Đề xuất chủ dự án duyệt packet G2-01 (presentation-only) *sau khi đã xử lý G1 Acceptance blocker*,** hoặc cho phép chuẩn bị UI read-only song song nhưng phải ghi G1 runtime/visual PENDING, không gộp nhầm kết quả. Cấp phép code cần nêu rõ nhánh, file cho phép, điều kiện rollback, test focused và những hệ gameplay không được sửa.
