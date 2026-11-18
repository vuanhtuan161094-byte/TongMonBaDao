# D2/D3 — THIẾT KẾ CÔNG TRÌNH, NGUYÊN LIỆU VÀ VÒNG ĐỜI VẬT PHẨM

Ngày: 18/11/2026 · **DESIGN CANDIDATE** cho các nội dung còn mở; kế thừa mọi luật đã duyệt trong \`docs/P3_7_BUILDING_TREE_SPEC.md\` và \`docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md\`.

Mục tiêu là hoàn thiện mô tả gameplay để lần lập trình sau chỉ phải thực hiện hợp đồng đã duyệt. **Không code công trình mới, không kích hoạt công thức, không sinh vật liệu hay buộc đóng lại vòng P0.**

## 1. Cây công trình — đủ 28 mục để đối chiếu

Cây dài hạn gốc: 26 loại. Runtime đang đăng ký 8 loại, gồm 6 nằm trong cây + 2 ngoài cây. Bảng bên dưới ghi **mục tiêu chức năng/đầu ra thiết kế**, không mô tả nó đang hoạt động.

| # | Công trình | Trạng thái mã | Vai trò | Hành động → đầu ra dự kiến | Không được làm sai |
|---:|---|---|---|---|---|
| 1 | ĐẠI ĐIỆN | Có loại trong code | Quyền hạn/cấp Tông Môn | Nhận điều kiện tiến trình sau khi hoàn thành nâng cấp, không sinh tài nguyên | Thẩm quyền mở cấp/nhiệm vụ, không tạo tiền miễn phí |
| 2 | KHO TÔNG MÔN | Chỉ có thiết kế | Sức chứa & quy tắc kho | Cùng WarehouseSystem hiện tại, chỉ cải thiện capacity/chính sách giao nhận | Không lập kho thứ hai, không đổi quyền sở hữu vật phẩm |
| 3 | ĐỆ TỬ XÁ | Có loại trong code | Chỗ ở và cư trú | Tăng giới hạn/nhóm nhà ở theo cơ chế residence thực | Không trực tiếp sửa sức mạnh chiến đấu |
| 4 | LINH ĐIỀN | Có loại trong code | Số ô gieo và công suất | Gieo/chăm/thu hoạch một lần theo chu kỳ → đúng item vào Warehouse | Không bonus sản lượng từ work_speed ngoài nguồn hợp lệ |
| 5 | MỎ LINH KHOÁNG | Có loại trong code | Chọn mạch và sản xuất quặng | Job cố định loại quặng lúc bắt đầu → quặng trả Warehouse | Không biến 270 source profile thành site farm |
| 6 | LINH LÂM | Có loại trong code | Chọn cây/nguyên liệu gỗ | Job thu hoạch/carry cố định nguồn → kho | Không tự tăng yields theo cấp nếu chưa chốt |
| 7 | TU LUYỆN ĐÀI | Chỉ có thiết kế | Tu luyện Tu Vi tập trung | Đệ tử được xếp slot, dùng thời gian và tài nguyên đã duyệt → Tu Vi thực | Không cấp Tu Vi Đan tự động, không nhập đè Rèn Thân Đường |
| 8 | MẬT THẤT | Chỉ có thiết kế | Bế quan & tu luyện chuyên sâu | Khoá lịch đệ tử tại slot có thời lượng/điều kiện → exp từ nguồn bế quan | Không nhận EXP cả từ bế quan lẫn ca làm cùng khoảng thời gian |
| 9 | Y QUÁN | Chỉ có thiết kế | Hồi thương và trị liệu | Nhận đệ tử Injury thực, thanh toán một lần → giảm chấn thương | Không coi heal HP bằng xóa Injury |
| 10 | LUYỆN ĐAN ĐIỆN | Có loại trong code | Đơn luyện đan | Nguyên liệu + thời gian + nghề → đan thành phẩm cùng ID → kho | Không mở recipe thiếu nguồn hoặc cấp |
| 11 | LUYỆN KHÍ ĐIỆN | Chỉ có thiết kế | Đơn rèn/trang bị & sửa chữa | Chọn mẫu/cấp, reserver vật liệu, thời gian job → unique gear | Không tạo item trùng hoặc nâng cấp đồ trái grade |
| 12 | SĂN YÊU ĐIỆN | Chỉ có thiết kế | Điều phối săn quái | Thiết lập đội, lịch, mục tiêu, policy và báo cáo nguồn vật phẩm | Không tạo farm thêm ngoài map / quái có thật |
| 13 | HẬU CẦN ĐIỆN | Chỉ có thiết kế | Tiếp tế & vận chuyển | Chuẩn bị supply/expedition; trừ kho một lần trước đội xuất phát | Không tạo Thể Lực Viễn Chinh bằng việc nâng nhà |
| 14 | CỔNG TÔNG MÔN | Chỉ có thiết kế | Bảo vệ và truy cập vùng | Kiểm tra quyền vào, trạng thái phòng thủ, kết nối sự kiện xâm nhập | Không tự tạo hệ PvP/invasion nếu chưa có |
| 15 | PHƯỜNG THỊ | Chỉ có thiết kế | Giao dịch và lưu thông | Lệnh mua/bán có số lượng/giá/thuế và đối tác hợp lệ | Không phát tiền/nhân bản hàng khi đổi giá |
| 16 | PHÙ LỤC ĐIỆN | Chỉ có thiết kế | Chế tác Phù | Công thức Phù hợp lệ + nguyên liệu + nghề → item trong Warehouse | Không nhầm VFX Phù Tu thành vật phẩm Phù |
| 17 | TRẬN PHÁP ĐIỆN | Chỉ có thiết kế | Gia công/phân bổ trận pháp | Tạo đầu ra thuộc trận pháp có consumer thật và trạng thái triển khai | Không tạo buff/formation mới khi combat không có |
| 18 | NGỰ THÚ VIỆN | Chỉ có thiết kế | Thuần hóa và chăn linh thú | Tiếp nhận thú có ID hợp lệ, nuôi/training và assignment | Không tạo bộ thú/AI độc lập khi thiếu mô hình dữ liệu |
| 19 | DIỄN VÕ TRƯỜNG | Chỉ có thiết kế | Luyện kỹ năng & so tài | Skill/mastery XP từ sự kiện training có thời lượng, kết quả và lưu tiến độ | Không cộng Tu Vi thay mastery XP |
| 20 | TÀNG KINH CÁC | Chỉ có thiết kế | Sưu tập và nghiên cứu công pháp | Kho bí kíp của Tông Môn, phân quyền học theo skill thực | Không gộp Bách khoa website vào công trình hoặc bật V6.3 |
| 21 | TỬU PHƯỜNG | Chỉ có thiết kế | Đồ uống và sản xuất | Công thức rượu/nước uống có nguyên liệu/chu kỳ và hiệu lực thực | Không dựng chỉ số say/rượu khi chưa thiết kế nhu cầu |
| 22 | LINH TRÙ PHÒNG | Chỉ có thiết kế | Ăn uống, dự trữ lương thực | Nấu món ăn, tiêu khẩu phần có item và sự kiện meal | Không bật 8 trait ăn ngủ nếu thiếu food/schedule |
| 23 | HOA PHƯỜNG | Chỉ có thiết kế | Sản xuất hương liệu/hoa | Gieo/đổi mới nguồn flower, gia công vào item hợp lệ | Không tự tạo hiệu ứng tình cảm nếu thiếu social event |
| 24 | HỒNG TRẦN PHƯỜNG | Chỉ có thiết kế | Sinh hoạt và tương tác xã hội | Sự kiện quan hệ có actor/target/timeline và consequence hợp lệ | Không tạo buff sinh tâm tính/nhân duyên khi không có hệ xã hội |
| 25 | ĐẤU GIÁ CÁC | Chỉ có thiết kế | Mua bán giới hạn/hàng hiếm | Phiên đấu giá có lô hàng thật và thanh toán kho/tiền một lần | Không tạo hàng hiếm vô hạn hoặc nâng grade item |
| 26 | CHÍ BẢO TÔNG MÔN | Chỉ có thiết kế | Chí bảo và hiệu ứng Tông Môn | Registry chí bảo độc nhất; hiệu ứng qua consumer hợp lệ và giới hạn | Không auto kích hoạt Chí Bảo không có nguồn rơi |
| 27 | Rèn Thân Đường | Có loại trong code | Huấn luyện Luyện Thể | Lv1: 2 slot; 1 phút mô phỏng + 1 linh thạch → 1.500 EXP Luyện Thể nền | Chưa chốt chi phí và hiệu quả nâng cấp trên Lv1 |
| 28 | Dẫn Tiên Đài | Có loại trong code | Chiêu mộ/tiếp dẫn | Gói tuyển hợp lệ; phí và eligibility qua recruitment actor | Nâng vượt Lv20 còn bị chặn thiếu điều kiện tiến trình |

## 2. Hợp đồng cấp Lv1–100 và các mốc

- **Lv1:** chức năng cơ bản của từng công trình, tối thiểu một action hợp lệ có đầu ra; hệ chưa có consumer phải ghi khóa.
- **Lv2–9/11–19/…:** tăng một đại lượng hiện có và tính bằng công thức chung **đã có trong spec**, ví dụ sức chứa, tốc độ, số worker/slot, chứ không thêm tiền/đan tự sinh.
- **Lv10/20/30/50/75/100:** nâng cấp mang một **hợp đồng mở khóa** có tên, dữ liệu, ID vật liệu mốc và nguồn hợp lệ; nếu thiếu source hoặc spec thì trạng thái \`MILESTONE_DESIGN_GATED\` và người chơi không được thấy nút nâng cấp ảo.
- **Quan hệ Đại Điện:** nếu cơ chế giới hạn level tông môn còn chưa khóa, không dùng max=100 để bypass cổng.
- **Điều kiện chi phí:** chỉ lấy Linh Mộc/khoáng liệu/linh thạch thường theo chính authority; chuyên liệu có định danh và nguồn được kiểm tra riêng. Không dùng bảng giá mẫu không có nguồn làm giá chính thức.
- **Số lượng công trình:** giữ luật unique/repeatable và giới hạn theo Tông Môn của spec, không tạo unlimited instance do tăng level.
- **Nhân công:** số người làm được/cấp/loại phải được ghi bằng bảng dữ liệu, không lấy công thức chung cho mọi nhà; người làm công việc có lịch và EXP nghề.
- **Chốt mỗi công trình:** định nghĩa \`input\`, \`worker\`, \`duration\`, \`output\`, \`benefit_per_level\`, \`milestone_unlock\`, \`upgrade_BOM\`, \`runtime_consumer\`, \`save_version\` và nguồn thiết kế cho từng cấp mốc.

### Hai điểm cần quyết định cụ thể

**Rèn Thân Đường:** đã duyệt 2 slot, 1 phút và 1 Linh Thạch = 1.500 EXP Luyện Thể cơ bản. **Ứng viên D2-A:** mỗi +10 cấp công trình mở thêm 1 slot huấn luyện (Lv1 2; Lv10 3; … Lv100 12). Không tự tăng EXP/phút bằng level; thang chi phí/lực luyện mới chỉ mở khi tồn tại nguyên liệu tier thật. Mẫu này chống inflate EXP nhưng cần owner phê duyệt.

**Dẫn Tiên Đài:** giữ giới hạn runtime không vượt Lv20 cho đến khi có authority \`sect_progression_gate\`. **Ứng viên D2-B:** mốc 30/50/75/100 yêu cầu hoàn thành milestone Đại Điện tương ứng, công trình có slot hoạt động và một nhóm vật liệu chỉ xuất phát từ săn quái/chế tạo có nguồn. Không tự gán ID vật liệu mốc chưa có provenance.

**Kho Tông Môn:** kiến trúc thiết kế là **công trình điều khiển sức chứa/chính sách**, nhưng dữ liệu vật phẩm vẫn do **WarehouseSystem duy nhất** sở hữu. Không tạo kho nhân vật/kho riêng thứ hai.

## 3. Vật phẩm — một hợp đồng chung cho mọi loại

Mỗi item/recipe/source có các trường:
\`item_id, Vietnamese_name, type, realm_index(1..30 nếu áp dụng), family, grade, tradable?, stackable?, legal_source, source_level, source_kind, recipe_id, recipe_required_facility, worker_profession, ingredient_ids_and_units, job_duration_ticks, output_count, result_quality_rules, consume_action, persistence_owner, design_state, runtime_state\`.

Hành động có quyền tạo/vay/tiêu vật phẩm:
- Mỏ/Linh Lâm/Linh Điền: nguồn tài nguyên thuộc công trình và job.
- Quái/Thủ lĩnh/Bí Cảnh/Map: drop/loot là kết quả từ một encounter đã định danh.
- Chế tác: tạo từ BOM đã kiểm tra và **trừ một lần**, kết quả về Warehouse.
- Giao dịch: giá rõ ràng, thanh toán kho/currency một lần, phải có NPC/đối tác thật.
- Vật phẩm dùng một lần: đúng actor/target/tác dụng/cooldown, không lặp lại sau save/load.

Nếu một ID thiếu \`legal_source\` hoặc \`consume_action\`, ghi \`DESIGN_GATED\`. Không tự nhét vào shop, thưởng miễn phí hoặc tăng tỉ lệ rơi khi chưa được duyệt.

## 4. Tình trạng thiết kế vật liệu và đan — không thổi phồng

| Danh mục | Số lượng có trong tài liệu/mã | Không được diễn giải thành |
|---|---:|---|
| Vật liệu thiết kế dài hạn | 630 slot | 630 vật phẩm đã có source hoạt động |
| Đã đăng ký trong 630 slot | 11 ID | Đủ nguyên liệu craft xuyên 30 cảnh giới |
| Chưa đăng ký | 619 = 112 preserved + 507 đề xuất | 619 ID được phép tự tạo mà không có hồ sơ gốc |
| Tuyến nguồn thiết kế | 270 profile | 270 mỏ/điền/địa điểm farm live |
| Tài nguyên nền runtime | 34 ID | 34 loại trong 630 được đăng ký |
| Đan dược trong catalog | 476 mã | 476 đan có công thức chế tạo |
| Recipe IDs | 119 mã | 119 công thức có đủ nguyên liệu và thời gian |
| Họ-cảnh giới có recipe body | 8 (32 biến thể phẩm) | Có sẵn toàn bộ chất lượng Q1–Q4 bằng một thao tác |

**Quy tắc chống bịa:** 507 mã mới đề xuất không có provenance từ V5.4/CSV chính thức chỉ được giữ trong **design reserve**. 112 mã preserved cần đối chiếu original name/hash, rồi mới tạo nguồn farm. Không làm hàng trăm file mới để “đủ chỉ tiêu 630”.

## 5. Thứ tự chốt nội dung D3 theo 30 cảnh giới

1. **Item identity và nguồn gốc** từ 34 nguồn đang có, 11/630 mã runtime và các ID preserved; chỉ những ID có provenance đủ mới bước tiếp.
2. **BOM 8 công thức sớm** đang dùng: không phá tương thích và không thay ingredients bằng vật liệu chưa click chọn được trên GUI.
3. **Mở đúng nguyên liệu cấp tiếp theo:** mỏ/rừng/cây theo cấp hiện có, drop quái có encounter nguồn, chợ NPC có hợp đồng trade; **không kích hoạt 270 site map giả**.
4. **Chốt family/realm recipe 3..30** theo mẫu cùng họ có điều kiện; mỗi recipe mới phải tra được BOM + producer + profession + cấp nhà trước khi \`DESIGN_COMPLETE\`.
5. **Điều kiện dùng:** đúng cảnh giới, Q1–Q4, cooldown 5s/giới hạn các nguồn đan; không tự lấy bảng potency làm hiệu quả khi consumer chưa có.
6. **Cân bằng sau cùng:** giá thị trường/sản lượng/thuế/drop được cân bằng trên các nguồn **đã thực**; không tạo 30 bậc kinh tế từ số liệu V5.5-D \`runtime_activation=false\`.

## 6. Đầu ra của gói này

- **Đã biên soạn:** hồ sơ chức năng dự kiến cho đủ **28 trường hợp công trình**, quy tắc cấp/mốc, các hợp đồng nguồn–BOM–sử dụng item, cách xử lý 630/270 và 476/119.
- **Chưa thể gọi DESIGN LOCKED:** hệ số nâng cấp từng nhà, giá/mốc vật liệu, danh mục source 112 preserved chưa đăng ký, 507 mã chưa có nguồn, và 444 đan thiếu recipe body. Phải giữ trạng thái thiếu thiết kế thay vì bịa ID hoặc con số.
- **Không phải yêu cầu P0:** tài liệu là mô tả đầu ra mong đợi cho đợt hoàn thiện thiết kế.

Authority: \`docs/P3_7_BUILDING_TREE_SPEC.md\`, \`docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md\`, \`docs/qa/SX07B_PRESERVED_MATERIALS_SOURCE_GATE_20261109.md\`, \`docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md\` và \`wiki/data/game_system_audit.json\`.
