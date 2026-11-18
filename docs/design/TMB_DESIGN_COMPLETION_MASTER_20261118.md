# TÔNG MÔN BÁ ĐẠO — CHỐT THIẾT KẾ TRƯỚC KHI VIẾT THÊM GAMEPLAY (D0)

Ngày lập: 18/11/2026. Repo: \`vuanhtuan161094-byte/TongMonBaDao\`, Draft PR #72, nhánh \`integration/pve-p0-playable-ui-20261103\`.

**Chỉ thị mới:** tạm dừng đưa “đóng vòng chơi P0” thành ưu tiên số một. Ưu tiên hiện tại là **hoàn tất bản thiết kế còn khuyết**, bảo toàn các phần đã được duyệt và tạo hợp đồng dữ liệu đủ rõ cho lần lập trình sau. Tài liệu này **không** yêu cầu chạy lại vòng chơi, không tạo gameplay code, không merge và không điều khiển các chat VFX đang làm việc.

**Phạm vi và mức chắc chắn:** D0 là bản chỉ huy thiết kế. “Đã duyệt” phải có nguồn quyết định gốc; “Đề xuất D1/D4” chưa phải người dùng khóa, kể cả khi đã có công thức mẫu. Không dùng chữ PASS/SHIPPED cho tài liệu. Bách khoa là một nơi tra cứu, không mở trang Wiki hay danh mục QA khác.

## A. Thứ tự hoàn thiện thiết kế — không phải thứ tự lặp QA

| Gói | Hệ | Thiết kế cần đóng | Đầu ra kiểm được | Nguồn | Thứ tự |
|---|---|---|---|---|---|
| D1 | Nhân vật & hiệu ứng | Tâm Tính, 101 đặc tính, 24 Thiên Mệnh, 14 Thể Chất, 5 Huyết Mạch | Gốc chỉ số → điều kiện → kênh tác động → event thật → xung đột → kết quả, không sửa Tam Căn/Tứ Tính | D1_CHARACTER_EFFECT_DESIGN_CANDIDATE_20261118.md | Đầu tiên |
| D2 | Công trình & nâng cấp | 8 loại runtime, 26 loại trong cây (20 chưa đăng ký) | Từng nhà: mục đích, Lv1, slot, 10/20/30/50/75/100, đầu vào, đầu ra, chi phí/mốc, liên kết nghề và nguồn vật liệu | P3_7_BUILDING_TREE_SPEC.md | Thứ hai |
| D3 | Nguyên liệu → vật phẩm → đan | 630 vật liệu thiết kế; 270 tuyến nguồn; 476 mã đan; 119 recipe IDs | Mỗi item có ID, nguồn nhận hợp lệ, yêu cầu nghề/nhà/cấp, công thức, thời gian, số lượng, sử dụng, tiêu hao | P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md | Thứ ba |
| D4 | Trang bị & đồ bộ | 10 ô +3 Phù +2 Pháp Bảo; 12 phẩm; 24 bộ; 9 chu trình rèn/nâng | Đóng transaction 1 đơn rèn, tiếp đến nâng/tẩy/thăng/kế thừa/chân văn; không sửa luật chiến đấu V2 | D4_FORGE_TRANSACTION_DESIGN_CANDIDATE_20261118.md | Thứ tư |
| D5 | Tu luyện & kinh nghiệm | 30×10 Tu Vi +30×10 Luyện Thể, đột phá, nguồn EXP | Xác nhận công thức EXP & tỷ lệ; giao nhiệm vụ mỗi nguồn; không thêm Tâm Cảnh trước khi chốt D1 | REALM_LADDER_V2_SPEC.md | Thứ năm |
| D6 | Chiến đấu, kỹ năng, môn phái | 36 nhánh, 2.196 node V6.3; P1/P2 pending owner | Khóa mô tả hành động/hiệu ứng, nguồn debuff/buff, AI, cooldown, tầm, mục tiêu; phân biệt catalog và live | COMBAT_SKILLS_V2_SPEC.md | Thứ sáu |

**Nguyên tắc:** Hoàn thành về **nội dung thiết kế** nghĩa là từng chức năng có quy tắc đầu vào, điều kiện, output, xung đột, hành vi khi thiếu tài nguyên, cấp, giá trị và trạng thái chưa có consumer. Hoàn thành **mã game** là giai đoạn khác, không gắn PASS lẫn nhau.

## B. Quy ước chuẩn cho mọi chức năng trong Tàng Kinh Các

Mỗi tính năng/bản ghi có ít nhất:

- \`identity\`: ID bất biến và tên tiếng Việt.
- \`design_state\`: \`APPROVED\` (đã duyệt), \`DESIGN_CANDIDATE\` (đề xuất có công thức cụ thể), \`DESIGN_OPEN\` (còn quyết định), \`DESIGN_DEFERRED\` (chủ động hoãn).
- \`implementation_state\`: \`NOT_CODED\`, \`DATA_ONLY\`, \`CODED_GATED\`, \`CODED_QA_PENDING\`, \`VERIFIED_RUNTIME\`. **Không đồng nhất với trạng thái thiết kế.**
- \`consumer\`: hành động nào sử dụng thật, có/không có callback.
- \`trigger/output\`: bắt đầu, hoàn thành, trả kho, nhận EXP, gây sát thương hoặc thay đổi lịch.
- \`dependencies\`, \`source_path\` và \`missing_decisions\`.
- \`evidence\`: spec gốc, mã hiện có và bằng chứng test đúng SHA **nếu thật sự có**.

Không cộng số lượng “ID vật phẩm đã khai báo” thành “vật phẩm đã chơi được”; không phát hành thiết kế chưa duyệt như nguồn sự thật gameplay.

## C. Những vấn đề phải chốt trong D1 — Nhân vật

**Khuyến cáo D1 mới nhất:** bản kháng +8 điểm % từng bị gọi nhầm là đã duyệt. Người dùng đã đề nghị trần 50 điểm % và tăng hiệu quả hoạt động Tu Luyện sẵn có; numeric slope chưa chốt. Tham chiếu `docs/design/D1_MIND_NATURE_V2_EFFECT_CONTRACT_20261118.md`.

**Đã duyệt:** 7 chỉ số nền; Tư Chất +0,25% Tu Vi tự nhiên mỗi điểm; Căn Cốt +0,20% EXP Luyện Thể mỗi điểm; Thông Tuệ +0,15% XP học; Tiềm Lực +0,05% hệ số tiềm năng; các đặc tính V2 **không có cấp chung**; không tự sửa chỉ số nền bẩm sinh qua buff; 101 định danh đã có trọng số sinh, 9 đặc tính hệ cũ là bộ khác.

**Cần đóng:** Tâm Tính hiện chưa có consumer gameplay; không vội tạo thêm hệ 300 tầng. **Đề xuất D1:** Tâm Tính chỉ quản lý ổn định tinh thần/gián đoạn/kháng hiệu ứng tinh thần **khi có sự kiện hợp lệ**. Tâm Cảnh 6 cấp chỉ là **đề xuất riêng**, không tự mặc định là hệ thứ ba hay được cộng EXP/s.

41 đặc tính có kênh thiết kế, 12 còn phụ thuộc, 48 mới chỉ là ý tưởng/hệ số tham khảo; không tự bật lợi ích của đặc tính hai mặt khi cái giá chưa có nguồn sự kiện. Từng đặc tính phải được gắn consumer và điều kiện thật. Trạng thái đang kiểm kê tại \`wiki/data/trait_effect_audit.json\`.

Các quyết định mở gồm cách áp dụng Tâm Tính, biến cố tinh thần (nếu có), mốc tu tâm, điều kiện bộc lộ/khắc phục đặc tính, 48 cơ chế đề xuất và chống chồng kênh buff quá mạnh.

## D. Những vấn đề phải chốt trong D2 — Công trình

**Đã duyệt:** cây **26 loại** dài hạn; mỗi instance tối đa Lv100; milestone thiết kế 10/20/30/50/75/100; Linh Mộc + khoáng liệu + linh thạch là nhóm tài nguyên thường; vật liệu đặc biệt ở mốc; công trình hỗ trợ săn quái/phát triển đệ tử, không phải một cửa sổ bảng tính độc lập.

**Hiện có mã:** 8 loại, trong đó 6 trùng cây 26 và 2 loại riêng (Rèn Thân Đường, Dẫn Tiên Đài). Chưa có loại \`Kho Tông Môn\` trong \`BuildingSystem.DEFINITIONS\` dù WarehouseSystem có mã độc lập; **không được tạo kho dữ liệu thứ hai**.

**Thiếu thiết kế cần đóng theo từng công trình:** (1) cấp/giới hạn sở hữu, (2) chức năng Lv1, (3) tăng tiến mỗi cấp, (4) từng mốc 10/20/30/50/75/100, (5) vật liệu đặc thù có nguồn thật, (6) nhân công, (7) giao diện chọn/chính sách, (8) nơi kết quả về kho/hồ sơ/chiến đấu. Các quy tắc đã có trong spec gốc được kế thừa, **không viết lại khác số**.

| Công trình | Kiểm kê code | Tình trạng nâng cấp | Nguồn thiết kế |
|---|---|---|---|
| ĐẠI ĐIỆN | Đã có mã loại công trình | Có luật nâng cấp có điều kiện | docs/P3_7_BUILDING_TREE_SPEC.md#L282 |
| KHO TÔNG MÔN | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L361 |
| ĐỆ TỬ XÁ | Đã có mã loại công trình | Có luật nâng cấp có điều kiện | docs/P3_7_BUILDING_TREE_SPEC.md#L430 |
| LINH ĐIỀN | Đã có mã loại công trình | Có luật nâng cấp có điều kiện | docs/P3_7_BUILDING_TREE_SPEC.md#L479 |
| MỎ LINH KHOÁNG | Đã có mã loại công trình | Có luật nâng cấp có điều kiện | docs/P3_7_BUILDING_TREE_SPEC.md#L559 |
| LINH LÂM | Đã có mã loại công trình | Có luật nâng cấp có điều kiện | docs/P3_7_BUILDING_TREE_SPEC.md#L621 |
| TU LUYỆN ĐÀI | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L674 |
| MẬT THẤT | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L730 |
| Y QUÁN | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L793 |
| LUYỆN ĐAN ĐIỆN | Đã có mã loại công trình | Có luật nâng cấp có điều kiện | docs/P3_7_BUILDING_TREE_SPEC.md#L853 |
| LUYỆN KHÍ ĐIỆN | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L915 |
| SĂN YÊU ĐIỆN | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L973 |
| HẬU CẦN ĐIỆN | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1036 |
| CỔNG TÔNG MÔN | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1096 |
| PHƯỜNG THỊ | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1147 |
| PHÙ LỤC ĐIỆN | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1208 |
| TRẬN PHÁP ĐIỆN | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1253 |
| NGỰ THÚ VIỆN | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1295 |
| DIỄN VÕ TRƯỜNG | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1346 |
| TÀNG KINH CÁC | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1394 |
| TỬU PHƯỜNG | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1449 |
| LINH TRÙ PHÒNG | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1474 |
| HOA PHƯỜNG | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1496 |
| HỒNG TRẦN PHƯỜNG | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1518 |
| ĐẤU GIÁ CÁC | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1546 |
| CHÍ BẢO TÔNG MÔN | Chỉ có bản thiết kế | Chưa có luật nâng cấp trong runtime | docs/P3_7_BUILDING_TREE_SPEC.md#L1578 |
| Rèn Thân Đường | Đã có mã loại công trình | Nâng cấp bị chặn | godot/src/simulation/building/building_system.gd |
| Dẫn Tiên Đài | Đã có mã loại công trình | Không nâng quá Lv20 | godot/src/simulation/building/building_system.gd |

**Quyết định ưu tiên đặc biệt:** Rèn Thân Đường đã khóa Lv1 = 2 slot, 1 Linh Thạch + 1 phút mô phỏng → 1.500 EXP Luyện Thể nền; nhưng **chưa khóa chi phí và lợi ích nâng cấp**. Dẫn Tiên Đài bị chặn quá Lv20; muốn mở cần hợp đồng tiến trình tông môn. Không tự bịa công thức để bypass gate.

## E. D3 — Chuỗi nguyên liệu và chế tạo

**Giữ nguyên:** 630 ô vật liệu là thiết kế; hiện chỉ **11/630 đăng ký**, **619 chưa** (112 preserved chưa đăng ký, 507 mới đề xuất/chưa có provenance). 270 tuyến nguồn mới là profile **thiết kế**, không phải 270 site có thể farm. Đã có 34 tài nguyên nền tổng hợp các loại khác; 34 ≠ 630. Không tạo nguồn rơi ảo.

**Đan:** 476 ID theo phẩm/cảnh giới; 119 ID công thức; chỉ **8 họ-cảnh giới** có recipe body tương ứng 32 biến thể phẩm, **444 mã chưa có công thức**. Phân biệt \`item_identity\`, \`recipe_definition\`, \`producer_route\`, \`consumable_effect\` và \`UI_access\`.

Quy tắc thiết kế cho mỗi nguyên liệu mới: nguồn gốc ID / bậc / khu vực/loại quái/cây/mỏ / nghề và công trình / chu kỳ / số lượng / tỷ lệ/giá / nguồn thay thế có thật / người tiêu thụ. Nếu chưa có tài liệu provenance hoặc consumer, gắn \`DESIGN_OPEN\` thay vì tự dựng 270 site.

Luồng chuẩn: producer có thật → Warehouse hiện có → công thức xác định → job One Active Job → trừ nguyên liệu đúng lần → sản phẩm/EXP nghề → vật phẩm dùng được. Đây là **hợp đồng dữ liệu để thiết kế**; không phải yêu cầu quay lại P0 hay cấp phép chỉnh gameplay trong đợt này.

## F. D4 — Trang bị và đồ bộ

**Đã duyệt:** 10 ô thường + 3 Phù + 2 Pháp Bảo; 4 ô vật phẩm tiêu hao; 12 phẩm; tối đa 6 dòng thường + 2 dòng hiếm + 1 ô Chân Văn ở Chí Tôn; 24 bộ (18 chiến đấu, 6 nghề) có 4 mảnh, mốc 2/3/4; không có set Chân Văn Cộng Hưởng, không tự tạo skill khi mặc set. Đạo tu/thân thể quyết định tính hợp lệ trang bị như spec.

**Chưa khóa:** kết quả 1 đơn rèn, tỉ lệ ra phẩm/dòng, cấp cường hóa tối đa, tiêu hao các công đoạn, tẩy/tinh luyện/thăng phẩm/kế thừa, vật phẩm nguồn, tỉ lệ rơi và 80+ dòng phụ. Thực hiện bản D4 ứng viên để người dùng chốt; không âm thầm xem bản ví dụ như người dùng đã duyệt. Phù/Pháp Bảo chuyên biệt **không gộp vào 10 ô thường**.

## G. D5/D6 — Tu luyện, chiến đấu, kỹ năng và VFX

- Tu Vi và Luyện Thể 30×10 đã là trục chính; không dựng hệ tu luyện thứ ba khi chưa duyệt. Tâm Tính/Tâm Cảnh không được tăng trực tiếp tỷ lệ đột phá hoặc nhân hệ số EXP ngoài quyền điều kiện hợp lệ.
- Combat V2 và 36 nhánh / 2.196 node V6.3 phải giữ P1/P2 design/effect identity; V6.3 mặc định OFF. Số kỹ năng trong catalog không đồng nghĩa kỹ năng đánh được.
- VFX là nghệ thuật cần phê duyệt riêng; không sửa VFX hiện tại trong giai đoạn chốt thiết kế hệ thống. Các chat VFX tiếp tục theo quyền sở hữu file riêng.

## H. Quyết định để khép thiết kế, không phải checklist QA

| Gói | Cần sản phẩm thiết kế cuối | Khi nào được đánh dấu DESIGN COMPLETE |
|---|---|---|
| D1 | Ma trận từng chỉ số/đặc tính với trigger, consumer, tác dụng, xung đột | 101/101 có quy tắc cụ thể và các điều kiện phụ thuộc hoặc quyết định hoãn rõ ràng |
| D2 | 26 công trình + 2 ngoại lệ: cấp/mốc/nhân công/đầu vào/đầu ra/giá | Không còn mốc nâng cấp hứa hẹn nhưng thiếu điều kiện hoặc nguồn vật liệu |
| D3 | Provenance của vật liệu, nguồn farm, BOM 30 cảnh giới, 476 đan | Không tạo ID giả; ID thiếu nguồn ghi chặn/hoãn minh bạch, không phát hành thiếu vòng đời |
| D4 | 9 hợp đồng rèn/nâng/sở hữu/phân giải và 24 bộ/12 phẩm | Đủ hành động, ràng buộc, tỉ lệ mẫu và chống duplication, nội dung numeric duyệt riêng |
| D5 | Cảnh giới/đột phá/XP/cơ chế trụ cột | Có bảng định lượng duy nhất, không trùng authority |
| D6 | 36 nhánh kỹ năng, buff/debuff, VFX semantics | Skill effect thật được mô tả, loại khóa được gắn trạng thái, không bịa số hoặc art PASS |

**Điểm chốt:** thiết kế hoàn chỉnh trước khi giao coding. Không thêm một chiến dịch “đóng P0” mới. Tàng Kinh Các chỉ trình bày hai trục tách biệt **Thiết kế** và **Triển khai**.
