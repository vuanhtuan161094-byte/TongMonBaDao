# D4 — MỘT QUY TRÌNH RÈN TRANG BỊ V2 ĐẦY ĐỦ + 9 HỆ NÂNG CẤP

18/11/2026 · **DESIGN CANDIDATE**. Không sửa gameplay, không ghi “user approved”, không mở Phù/Pháp Bảo. Thừa kế \`WEAPON_EQUIPMENT_V2_SPEC.md\`, \`EQUIPMENT_SETS_V2_SPEC.md\`, \`EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md\`.

## 1. Phần đã duyệt không thay đổi

- 10 ô thường: weapon/head/armor/cloak/bracers/gloves/belt/boots/pendant/ring; **thêm 3 ô Phù, 2 ô Pháp Bảo và 4 ô tiêu hao ở hệ khác**.
- 12 phẩm Phàm, Tinh, Thượng, Cực, Linh, Huyền, Địa, Thiên, Vương, Thánh, Đế, Chí Tôn.
- Phẩm quy định tối đa dòng phụ; thường tối đa 6, đặc biệt tối đa 2, ô Chân Văn riêng ở Chí Tôn, **không tự khắc Chân Văn**.
- Realm tier item là 1..30 độc lập phẩm; ba đời Nhân 1–10, Tiên 11–20, Thần 21–30.
- 24 đồ bộ, mỗi bộ 4 vị trí đặc định, các mốc 2/3/4 cộng dồn; 18 bộ combat + 6 bộ nghề; 3+3 có hiệu lực hai mốc 2/3; không có Chân Văn cộng hưởng set và không tặng skill mới.
- Mọi món đồ thuộc về Tông Môn; có thể giao cho đệ tử, không đổi ownership; tự động cấp phát phải xét tổng loadout và set threshold.

## 2. D4-01 — Đơn rèn từ đầu tới cuối (đề xuất khóa thành transaction)

**Nguồn dữ liệu của một recipe:** \`recipe_id\`, \`template_id\`, \`slot_id\`, \`allowed_style_tags\`, \`required_equipment_realm\`, \`facility_min_level\`, \`forger_profession_min\`, \`material_BOM\`, \`craft_duration_ticks\`, \`quality_table_id\`, \`legal_affix_pool_id\`, \`source_provenance\`.

**Quy trình:**
1. Người chơi chọn **mẫu trang bị và ô đích**, cấp cảnh giới trang bị 1..30, phẩm dự kiến chỉ là phạm vi có thể ra. UI hiển thị BOM, thời gian, cấp Luyện Khí Điện và nghề thợ, không bấm craft nếu thiếu.
2. Kiểm tra recipe đã mở và từng material ID có trong canonical Warehouse. Không nhận vật liệu tương lai thiếu nguồn hoặc đồ không hợp ô.
3. Chọn người rèn có nghề hợp lệ, xác lập job id ổn định \`forge_job_id\`. Khi bắt đầu, dự trữ material và worker slot đúng một lần; chưa tạo item.
4. Job lưu seed/recipe/worker/material snapshot ở mốc \`START\`. Không cho cancel/reload đổi seed để liên tục roll phẩm.
5. Khi đạt tick \`COMPLETE\` qua canonical scheduler, giải kết quả một lần. **Không có thất bại trắng** cho recipe rèn đồ thường: được tối thiểu một món đúng template/cấp, biến động chỉ ở phẩm và legal affix.
6. Rút phẩm theo bảng **được gắn với recipe/bậc**, không dùng một tỷ lệ chung cho 12 phẩm. Nghiệp vụ giới hạn phẩm theo level Luyện Khí Điện, nghề, provenance của nguyên liệu.
7. Sinh các dòng phụ từ pool **đúng vị trí/grade/realm**, không trùng ID, tối đa 2 dòng A chung, giới hạn B theo luật spec; đặc tính chưa có consumer không được roll. Chân Văn slot ở Chí Tôn để trống.
8. Tạo \`instance_id\` duy nhất thuộc Sect Warehouse; commit một lần: vật liệu dự trữ chuyển tiêu hao, công XP nghề được cộng, đồ mới xuất hiện trong kho; trạng thái \`COMPLETED\` có receipt.
9. Có policy tự rèn theo số lượng, slot và role; không yêu cầu người chơi bấm lặp từng đơn. Khi mất save/khôi phục, job dùng cùng receipt/seed; không trừ nguyên liệu hoặc cấp đồ hai lần.

**Luật hiển thị UI trước khi bấm:** món mục tiêu, vật liệu, cấp/đủ thiếu, thời gian, phẩm **có thể ra**, phạm vi chỉ số; không hiện % phẩm giả nếu bảng xác suất chưa khóa.

### Ví dụ đầu game dựa trên ID đang có

\`Thanh Thiết Kiếm\` hệ cũ sử dụng **3 Thanh Thiết + 1 Linh Mộc**. D4-V2 có thể sử dụng cùng 2 nguyên liệu nguồn hợp lệ làm phiên bản cấp 1 để không làm mất nguồn farm; tuy nhiên phải có \`recipe_id_v2\` tách biệt và lưu cơ chế upgrade/migration.

**Đề xuất D4-01A (số liệu *chưa duyệt*, chỉ để người dùng quyết định):**
- Rèn thường cấp thấp: Phàm 70%, Tinh 25%, Thượng 5%, các phẩm khác 0%. Không có hỏng mất trắng.
- Mẫu rèn trung cấp (chỉ khi đã có recipe/material trung cấp hợp lệ): Cực 55%, Linh 30%, Huyền 12%, Địa 3%.
- Mẫu rèn cao cấp/chase (chỉ khi đã có đồ liệu cao cấp hợp lệ): Thiên 60%, Vương 28%, Thánh 10%, Đế 1,8%, Chí Tôn 0,2%.
- Mỗi recipe phải chỉ rõ nguồn vật liệu và facility/forger tier để chọn **một** bảng; không tự đạt Thần phẩm chỉ nhờ bấm recipe rẻ. Đây là 3 ứng viên phân phối phẩm, cần cân bằng theo mức thu nhập/mốc farm thật trước khi gọi thiết kế chính thức.

## 3. D4-02 — Cường hóa (chỉ số nền món đồ)

**Ứng viên:** tối đa **+10** cho một trang bị ở mọi phẩm, không có thất bại hủy đồ hoặc giảm cấp. Mỗi +1 dùng nguyên liệu hợp lệ cùng cảnh giới, linh thạch và thời gian nghề. Chỉ tăng **chỉ số nền item** (Attack/Defense/HP theo template), không nhân buff ngoại, dòng phụ/rare, chỉ số Lục Duy hoặc toàn bộ HP của đệ tử.

- **Ứng viên số học:** \`enhanced_base = base_item_stat × (1+0.02×level)\`, tại +10 tăng 20% base của chính món đó.
- **Chi phí đơn vị vật liệu mẫu:** \`primary_material_units=2+next_level\`; \`special_material_units=ceil(next_level/3)\` tại các mốc có specialty ID hợp lệ; giá linh thạch dùng bảng riêng theo cấp/realm, **chưa khóa**. Không tạo currency mới.
- **Mở khóa theo nhà:** giữ cơ chế Luyện Khí Điện Lv1 cơ bản, Lv10 auto repair, Lv20 tinh luyện nguyên liệu, Lv30 vật liệu quái, Lv50 affix/reforge, Lv75 bộ đặc biệt, Lv100 rare-line mastery theo spec, nhưng không mặc định Lv75 chặn mọi đồ bộ cấp thấp.
- Bật/chốt +10 và +2% chỉ sau khi so với RealmBodyCore numeric và monster scale; **+15 cũ không phải quyết định đã duyệt**.

## 4. D4-03 — Tinh luyện và tẩy luyện tách hai thao tác

- **Tinh luyện**: chọn một dòng phụ hiện có → nâng **giá trị** trong dải hợp lệ bằng tiêu hao; ID loại chỉ số không đổi, không vượt tier/range của phẩm, không đụng Chân Văn.
- **Tẩy luyện**: chọn một dòng phụ hiện có → đổi **ID thuộc tính** từ pool đã đăng ký theo đúng ô/grade; UI cho xem trước **một kết quả** và chọn **Giữ cũ / Nhận mới**; chi phí/seed được chốt khi job bắt đầu, không bốc lại bằng thao tác hủy/load.
- Không trùng cùng ID trên một item, không vượt 2 dòng A chung. Rare conditional lines giữ luật rarity riêng, không roll như dòng thường.

## 5. D4-04 — Thăng phẩm 1→12

- Thăng phẩm là thay **quality_grade** của cùng instance, **không tự tăng equipment_realm_index**.
- Yêu cầu vật liệu/phí/cấp nghề/công trình **tương ứng phẩm đích**; không biến đồ giá rẻ thành Chí Tôn bằng chỉ Linh Mộc Lv1.
- Phẩm lên thì mở thêm số dòng theo bảng 12 phẩm đã duyệt; dòng cũ giữ nguyên ID/mức hợp lệ, ô mới trống để reroll/điền qua consumer hợp lệ. Không tặng rare line hoặc Chân Văn gratis.
- Đề xuất chọn nâng phẩm **deterministic** khi đủ nguồn liệu đích, thay vì thất bại tiêu hao toàn bộ; chi phí và giới hạn nguồn rare quyết định độ khó. Chưa duyệt.

## 6. D4-05 — Thăng bậc cảnh giới

- \`equipment_realm_index = r\` lên \`r+1\` chỉ khi có **recipe nâng tier** và nguyên liệu với nguồn ở cấp \`r+1\`/Boss/Mỏ hợp lệ.
- Không tự cộng khả năng Nhân→Tiên→Thần chỉ từ phẩm, cấp +10 hoặc lưu đồ bộ.
- Giữ ID instance/ownership và khóa cấp phát trong thời gian nâng; tiến trình đầu tư cũ giữ nếu vẫn hợp lệ theo cấp đích; công thức phần vượt phải xác nhận ở D3.
- Cấp mới không làm tăng sức mạnh ngoài bảng RealmBodyCore và base item của cấp đó.

## 7. D4-06 — Kế thừa và phân giải

- **Kế thừa:** chọn A (nguồn) + B (đích) trong Warehouse, hai ID khác nhau, đúng loại/tier tương thích. Người chơi thấy preview thuộc tính được giữ/chuyển, phí, mất gì. Transaction commit: A tiêu thụ hoặc trả về item trắng theo luật chọn **một** trước khi triển khai, B nâng cấp theo luật một lần; không tồn tại cả hai món cùng toàn bộ đầu tư.
- **Phân giải:** đồ không đang khóa/trang bị/đang dùng job mới đủ điều kiện. Trả về tỷ lệ vật liệu theo \`item_instance_provenance\`/phẩm; **không trả lại 100% mọi nguyên liệu cùng dòng/upgrade** để tránh loop tự đẻ vật phẩm.
- **Ứng viên:** hoàn lại tối đa 50% nguyên liệu nền của item và 0% vật liệu Chân Văn hiếm; con số chỉ để cân bằng, chưa khóa.

## 8. D4-07 — Chân Văn cá thể

- Chỉ item Chí Tôn mới có **một ô khả dụng**, ô không tự chứa hiệu ứng.
- Chân Văn có ID riêng: nguồn nhận, một số kênh, trigger actor/action, một đích, ICD, hiệu lực, lượng stack tối đa và điều kiện hủy/khắc. Tất cả phải có consumer V2 hợp lệ.
- Không cho hiệu ứng tự gọi lại chính nó, không cho set bonus tự tạo Chân Văn, không cấp echo/counterstrike/reflect nếu chưa có Combat Event/proc budget.
- Chưa chốt danh mục Chân Văn và nguồn drop, do đó phần này là \`DESIGN_GATED\` không giả định tự động phát hành.

## 9. D4-08 — Nguồn vật phẩm và kinh tế

- Rèn cơ bản: tài nguyên Mỏ/Linh Lâm/điền có ID hiện hành + công thức cấp hợp lệ.
- Trang bị cao cấp: vật liệu Boss/Elite/Bí Cảnh **có provenance**, recipe unlock theo đúng cấp/hệ; không sinh 630 ID giả hay 270 site game.
- Phân giải, nâng phẩm, tinh luyện có phí trả về linh thạch và nguyên liệu có nguồn, không lập currency mới.
- Không đặt 0,2% Chí Tôn vào bất kỳ recipe phổ thông nào; chỉ table chase đúng nguồn đã thiết kế.

## 10. D4-09 — Tự động cấp phát quy mô lớn

- Người chơi chọn policy \`role_template\` (PvE tanker/attacker/support/worker), giữ lock trên đồ/đệ tử hoặc exclude cấp phát.
- Scoring đánh giá **toàn bộ 10 ô và set 2/3/4** chứ không đánh giá mỗi item độc lập; không phá bộ 4 món vì một món lẻ tăng rất ít điểm.
- Một worker có item đang assign không cho 2 job đồng thời cùng nhận bonus snapshot.
- Với hàng nghìn đệ tử, thay đổi chỉ recompute người/role bị ảnh hưởng, không rebuild toàn bộ 30.000 item mỗi tick.

## 11. Bảng trạng thái 9 bước thiết kế

| Mục | Đã có cấu trúc duyệt | Ứng viên mới trong D4 | Cần phê duyệt trước khi khóa |
|---|---|---|---|
| Rèn vật phẩm | 10 ô, 12 phẩm, source pháp luật | Transaction 9 bước, 3 bảng roll ví dụ | Grade probabilities, BOM từng recipe, nghề/nhà |
| Cường hóa | Không nhân buff ngoài | +10, +2% chỉ số nền/cấp | Cap, material cost và RealmBodyCore benchmark |
| Tinh/tẩy | 6+2 affix, pool đúng slot | Hai action khác nhau, preview nhận/giữ | Giá/range/rare pools |
| Thăng phẩm | 12 phẩm, không phải realm | Deterministic nếu đủ vật liệu | Material tier & scarcity |
| Thăng bậc | Gear realm1..30 | Bắt buộc tier+1 provenance | ID nguồn và công thức từng tier |
| Kế thừa/phân giải | Một Warehouse Tông Môn | Transaction bảo toàn, ≤50% refund tham khảo | Tỷ lệ chính thức, chính sách A/B |
| Chân Văn | 1 ô tại Chí Tôn | Thêm registry/ICD riêng | Bộ Chân Văn cá thể, nguồn sở hữu |
| Nguồn rơi/kinh tế | PvE + sản xuất | Không farm giả, không thêm currency | D3 provenance từng cấp |
| Auto cấp phát | 24 bộ/role policy | Scoring set-aware + khóa | Score templates, CPU/performance |

**Cấm kết luận đã làm xong:** Chỉ có hợp đồng quy trình và một số tỷ lệ ứng viên; không có game code, không có thử nghiệm Godot, chưa duyệt các con số mới.

Nguồn đã duyệt: \`docs/WEAPON_EQUIPMENT_V2_SPEC.md\`, \`docs/EQUIPMENT_SETS_V2_SPEC.md\`, \`docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md\`.
