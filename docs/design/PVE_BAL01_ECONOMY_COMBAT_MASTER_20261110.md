# PVE-BAL01 — ĐỐI SOÁT TU VI THỤ ĐỘNG, THƯỞNG SĂN, HP/ĐAN, LT2, 119 CÔNG THỨC

**Ngày:** 10/11/2026 · PR #72 một nhánh Draft, chưa merge. **Trạng thái:** CODE CANDIDATE + SOURCE AUDIT, CHƯA PLAYER RELEASE. Dữ liệu JSON kèm theo: `docs/design/PVE_BAL01_119_RECIPES_CANDIDATE_20261110.json`.

## 0. Quyết định điều chỉnh do chủ dự án bổ sung

**1000 Tu Vi XP/phút LUÔN LÀ NGUỒN THỤ ĐỘNG** cho V2 disciple đang ở hoạt động hợp lệ, bao gồm cả khi đi PvE. `SimulationScheduler._step_disciple` gọi `DiscipleTuViFlowV2.resolve_minute` TRƯỚC khi kiểm tra `active_pve_encounter_id` và return. `CULTIVATE` đổi hệ số phút lên x2. EXP do giết quái là cộng thêm từ `PvePerKillRewardV1`, không thay thế EXP nền.

Không so sánh '2000 XP/phút tu luyện' với 'EXP từ quái/phút' như thể PvE mất nguồn 1000 nền. Không tự tăng nền để cân bằng.

**Giá 3 LT/10 HP** là dữ liệu `Economy-A` cũ, chỉ có hiệu lực ở nhánh service v1 và không đại diện cân bằng 2026. Cờ `pve_r12_reward_pilot=false` bảo vệ toàn bộ Save hiện có. Khi cờ riêng thử nghiệm bật, trị giá dịch vụ là r1 300 LT/+10 HP và r2 600 LT/+10 HP tại Tông Môn; chi phí được chuyển từ ví cá nhân vào quỹ môn phái (không đốt khỏi nền kinh tế).

**Không trừ hai lần HP đã hồi bằng Đan.** Phần HP do Hồi Nguyên Đan hồi phải được trừ khỏi lượng HP còn cần mua dịch vụ; viên Đan đã lấy khỏi Kho thì không trừ thêm tiền mặt như vừa mua shop. `pill_shadow_stones` dưới đây chỉ dùng cho kịch bản **phải mua Đan thay thế từ shop giả định**, không phải giao dịch đã code.

## 1. Mô hình 1 đệ tử/giờ, cố định r1 hoặc r2 (candidate)

Lưu ý: **12 kills/giờ, 18/24 HP mất/mạng, 2 Q1 Hồi Nguyên Đan/giờ là kịch bản**, KHÔNG đo trong GUI. Tỷ trọng quái hiện hành Thanh Trúc Lâm: Trúc Thử 65%, Thanh Lang 30%, Hắc Lang 5%. Mỗi kill có thể không rơi nguyên liệu; LT trực tiếp được chốt theo loại quái bằng biên bản hạ quái thật. Không tính bán nguyên liệu, ngọc, trang bị, công pháp hay thưởng Boss trong tiền ròng dưới đây.

| Chỉ tiêu | r1 Phàm Nhân | r2 Luyện Khí | Cách tính |
|---|---:|---:|---|
| Tu Vi thụ động/h | 60.000 | 60.000 | 1000 × 60 (chưa bonus) |
| Tu Vi bonus/kill | 5.000 | 6.350 | 0,05% × EXP toàn cảnh |
| EXP Tu Vi bonus/h | 60.000 | 76.200 | 12 kills/h |
| Tu Vi tổng/h | 120.000 | 136.200 | passive + kill bonus |
| Chuyên Tu tham chiếu/h | 120.000 | 120.000 | 1000 × 2 × 60 |
| Luyện Thể bonus/kill | 1.200 | 1.524 | 0,012% × EXP toàn cảnh |
| Luyện Thể bonus/h | 14.400 | 18.288 | 12 kills/h |
| Thưởng LT/Trúc Thử | 2.100 | 4.200 | cá nhân, HP0 only |
| Thưởng LT/Thanh Lang | 3.000 | 6.000 | cá nhân, HP0 only |
| Thưởng LT/Hắc Lang | 4.200 | 8.400 | cá nhân, HP0 only |
| **Gross LT PvE/h** | **29.700** | **59.400** | 12 × (65% Trúc +30% Thanh +5% Hắc) |
| HP mất/h | 216 | 288 | 12 × 18/24 HP |
| Q1 Hồi Nguyên Đan | +55 HP/viên | +91 HP/viên | MedicineCatalogueV2 v4 |
| HP phục hồi từ 2 Đan | 110 | 182 | tối đa HP thiếu |
| Số dịch vụ +10 HP | 11 | 11 | CEIL((HP mất − HP do Đan)/10) |
| Phí dịch vụ/h | 3.300 | 6.600 | 11 × 300/600 |
| Giá tham chiếu mua 2 Đan/h | 3.000 | 6.000 | giả định 1.500/3.000 LT/viên |
| **Net LT cá nhân/h** | **23.400** | **46.800** | gross − HP fee − giả định phải mua 2 Đan |
| Sản xuất gross LT/h | 60.000 | 120.000 | LT2 1000/2000 phút × 60 |
| Sản xuất cá nhân Mine/h | 18.000 | 36.000 | thuế Mine 70% |
| Sản xuất cá nhân Forest/h | 42.000 | 84.000 | thuế Forest 30% |
| Sản xuất cá nhân Field/h | 36.000 | 72.000 | thuế Field 40% |
| Net PvE / gross công việc | 39% | 39% | chưa tính vết thương/thời gian đi lại |

**Phân biệt tổng của môn phái:** lương LT2 tạo tiền mới từ công việc hợp lệ, T2 chia ví/Quỹ. Thưởng PvE trực tiếp tạo tiền mới khi HP0 thật. Phí chữa trị từ đệ tử sang môn phái là **chuyển khoản, không xóa tiền**. Mua NPC từ nguồn ngoài tiêu tiền; NPC thu mua vật tư tạo tiền mới khi trừ Kho. Chi phí bóng của Đan không tự động trừ khỏi tài khoản nào. Không được tính thêm chi phí như thể thuốc vừa được sản xuất trong Kho vừa mua bằng LT ngoài.

### Sensitivity và điều kiện nghiệm thu

- 12 kills/h là mốc kiểm thử **không phải thông số cố định của AI**. Quan sát 6/12/18 kills/h theo từng đội 1/3/6 và đồ mặc r1–r2; lấy median + p10/p90.
- Theo dõi sát thương thực nhận; 18/24 HP/k là giả định. Tính chi phí với HP mất thực, loại Đan, phẩm Q1–Q4, quyết định hồi tại tông môn và thời gian quay về.
- Không tự hồi và tính phí dịch vụ khi đang ở PvE: `buy_personal_hp_service` yêu cầu đứng trong Tông Môn và không giữ job khác. B3 tự dùng Đan trong chăm sóc/hồi phục phải trừ Kho đúng một lần.
- Auto-heal Economy-A hiện kích hoạt dưới 50% HP, công cụ B3 CARE có ngưỡng riêng 75%; lịch sử thiết kế từng yêu cầu 80%. Cần một chính sách chung mới (phải có đủ tiêu hao Đan/tiền và chống trùng), **không ngầm bật cả hai**.
- Phần thưởng thắng trận `HuntingMapV2` và HP0 `PvePerKillRewardV1` là hai giao thức khác nhau, tuyệt đối không cộng đôi khi cùng một encounter/world.
- Không có giá/độ khó Boss, Elite và Công Pháp V6.3 hoàn chỉnh => chưa phát tiền/đồ giả. Chỉ ba quái thường r1/r2 được báo giá candidate, r3+ chặn.

## 2. Kiểm soát 1/7/30 ngày theo mô hình 6 giờ/ngày

Các giá trị là **kịch bản r1/r2 cố định**, chưa phản ánh tăng cảnh giới, offline, bất hoạt, nghỉ/trả đơn, chết hoặc downtime. Một đệ tử PvE 6 giờ/ngày:

| Kỳ | r1 thưởng LT gross | r1 ròng sau care+Đan mua giả định | r1 tổng Tu Vi (thụ động + bonus) |
|---|---:|---:|---:|
| 1 ngày | 178.200 | 140.400 | 720.000 |
| 7 ngày | 1.247.400 | 982.800 | 5.040.000 |
| 30 ngày | 5.346.000 | 4.212.000 | 21.600.000 |

6 thợ × 360 phút/ngày của r1 sẽ tạo LT2 gross **2.160.000/ngày**; nếu thay cả sáu bằng hunter 6 giờ/ngày, PvE gross **1.069.200/ngày**, tiền cá nhân ròng sau giả định care/Đan **842.400/ngày**. Hai số KHÔNG tương đương với thu nhập ngân quỹ do thuế và doanh thu NPC; phải tách quỹ/người và đủ vật tư chữa trị.

**Cổng từ HOLD → ENABLE:** chạy 1/7/30 ngày thật với One Active Job, 6 người sản xuất + 6 người săn xoay vòng, 30 người tối đa đang săn, tiến độ trồng/khai thác, dùng Đan, vụ thiếu vốn, thương tích 120 ticks, rớt tài nguyên và Save/Load/rollback; sai lệch tài khoản/quyền sở hữu cuối kỳ bằng 0. Mục tiêu không để PvE lợi nhuận cao hơn SX ở mọi mặt, cũng không để PvE lỗ dài hạn vì phải hồi máu liên tục.

## 3. Nguồn – người tiêu thụ – 119 công thức

- `MedicineCatalogueV2.all_recipe_ids()` = 119 mã định danh, 476 vật phẩm phẩm chất Q1–Q4. 8 công thức r1–r2 có BOM nguyên liệu thực; 111 công thức từ r3+ thiếu ít nhất một tuyến nguồn.
- `PVE_BAL01_119_RECIPES_CANDIDATE_20261110.json`: liệt kê **đích danh 119 recipe**, 8 BOM thật, 111 candidate BOM có số lượng chính xác `source_role` theo từng cảnh, cấp Linh Điền, cấp Luyện Đan Điện, cấp nghề, Q1–Q4, sản lượng và thời gian mẻ dự kiến.
- **`primary_field_herb`, `secondary_field_herb`, `rare_mob_core` trong JSON chỉ là vai trò nguyên liệu chưa đăng ký, KHÔNG phải ID item.** Không cho phép `AlchemyRecipeRegistry` nhận chúng, không mượn Thanh Linh Thảo làm giả thuốc r30. Từng role phải gắn 1:1 vào ID đã được `ResourceRegistry` định nghĩa, nguồn sản xuất/săn thật, mức mở khóa và kiểm thử phục vụ người dùng.
- Nguồn r1/r2 trước mắt: Mine Thanh Thiết 10.000/60m, Forest Linh Mộc 8.000/60m, Field Linh Cốc 2.500/60m, Thanh Linh Thảo 2.000/90m, Tử Vân Thảo 1.000/180m tại Lv10, Instanced 3 khu và P0 ba quái thưởng vật tư xác thực.
- Q2 tăng xúc tác Tử Vân ×1, Q3 Huyền Thiết ×1 + Linh Tủy ×1, Q4 Tử Vân ×2 + Huyền Thiết ×2 + Tinh Lang Bì ×1 ở công thức đã authored; r3+ trong JSON chỉ là candidate yêu cầu nguồn riêng tương ứng.
- Vấn đề vẫn HOLD: BOM r1 hiện tiêu quá ít thảo so với sản lượng số lượng lớn 2.000/mẻ và tốc độ luyện 36 viên/3m. Cần đo nhu cầu đan của 6/30 hunter theo HP thật, rồi kiểm định cân bằng đầu ra và chi phí; không tăng thuốc/giống đơn phương.
- Trang Bị V2 10 ô, 12 phẩm và 24 bộ chưa nối loot; Công Pháp V6.3 159 bản / 150 bản lưu trữ chưa có `drop_profiles` authorized. Tạo Loot Table cho từng quái/Elite/Boss từ nguồn game thật khi đã có content ID hợp lệ, **không cấp công pháp/trang bị bằng chuỗi ID giả**.

## 4. Shop và các chi phí cần lập riêng

### Phường Thị — giá MUA VẬT TƯ đề xuất trong pilot, không thay người chơi đang hoạt động

`market_purchase_price` đã được nối với bảng giá **cơ sở** chỉ khi `pve_r12_reward_pilot=true` nội bộ; giá thực bằng giá cơ sở × `market_buy_markup` hiện hữu (mặc định ×2). Quyền bán của NPC, tồn kho/ngày, hàng tồn và sổ giao dịch vẫn thuộc `EconomySystem`. Các giá này **không tác động** tới chế độ hiện hành.

| Item ID | Giá cơ sở pilot | Giá mua với markup ×2 | Người chơi bán cho NPC |
|---|---:|---:|---|
| `linh_moc` | 50 | 100 LT | vẫn 2 LT |
| `thanh_thiet` | 80 | 160 LT | vẫn 8 LT |
| `linh_coc` | 40 | 80 LT | vẫn 4 LT |
| `thanh_linh_thao` | 80 | 160 LT | vẫn 6 LT |
| `tu_van_thao` | 200 | 400 LT | không có trong danh sách bán |
| `huyen_thiet` | 550 | 1.100 LT | vẫn 34 LT |
| `tinh_lang_bi` | 375 | 750 LT | không có trong danh sách bán |
| `linh_tuy` | 1.250 | 2.500 LT | không có trong danh sách bán |
| `tam_mach_ban` | 20.000 | 40.000 LT | không bán lại |
| `linh_tuyen_chi_tam_manh` | 600 | 1.200 LT | không bán lại |

Cần đo thật nguồn thu/chi và thay lại giá **bán cho NPC** nếu cần, nhưng không mở vòng mua rẻ bán đắt. Mảnh Linh Tuyền Chi Tâm mua 100 mảnh tốn tối thiểu 120.000 LT ở markup mặc định, nhưng stock nhập NPC 20 mảnh/ngày nên tối thiểu 5 ngày khi không tự trồng/thu hoạch. Đây là **rào nguồn** thay vì giả vờ Linh Điền tự sinh Linh Tuyền Chi Tâm.

**Giá tham chiếu mua Đan r1 Q1 1.500 LT, r2 Q1 3.000 LT/viên chỉ thuộc mô hình dự báo; thuốc chưa được thêm vào danh mục NPC.** Không cho NPC tạo Đan mà thiếu tồn nguồn và công thức.

| Nhóm giao dịch | Cơ chế hiện hành | Rủi ro | Đích triển khai |
|---|---|---|---|
| HP cá nhân | 3 LT/+10 HP, tự mua dưới 50% khi cấu hình cho phép | Rẻ hơn nhiều so với LT2 | Candidate 300/600 LT theo cảnh, giới hạn ngân sách ngày; player OFF |
| Hồi Nguyên Đan | Kho → B3 Pill Consumer khi điều kiện hợp lệ | Có thể sản xuất 36 viên/3m, BOM rất rẻ | Theo dõi số Đan tiêu thực/giờ và chi phí nguyên liệu, không giả lập trừ LT |
| Shop NPC vật tư | giá cơ sở thấp, mức tồn/ngày hữu hạn | giá không cùng thang LT2 x1000 | Cân bằng r1–r2 sau kiểm thử market 1/7/30d; chặn mua/bán arbitrage |
| Trang Bị | 5 công thức cũ | 10 ô / 24 bộ chưa có nguồn rơi | Drop quái→mảnh/bản vẽ→rèn→đeo→nâng cấp, mỗi công thức có nguồn |
| Công Pháp | Cơ chế cũ + Tàng Kinh Các candidate | 159 mã không có bảng rơi approved | Định cấp bản/bộ/mảnh; Boss và Bí Cảnh làm nguồn hiếm hữu hạn |

## 5. Contract kỹ thuật và ngăn phát hành

- Bất kỳ sửa thưởng PvE nào đều qua đúng `PvePerKillRewardV1.preview/commit`, HP0 journal và `camp_population.p0_kill_rewards`; retry, cold reload hoặc thiếu tiền/Kho không phát thêm.
- Không tạo tiền riêng cho 'kill event' từ UI, `LootBag`, reward màn hình hay shop giả; không thay `SaveService`, scheduler clock hoặc thương lượng T2/W2 lịch sử.
- Kiểm tra Overflow ví cá nhân, Vault, Kho; revert toàn bộ nếu giao dịch không hợp lệ. Nền thưởng hiện hành chỉ thay khi cờ nội bộ bằng true.
- Bảo vệ `r3+`, (111) công thức chưa sourced, bảng thảo r3–r30, Boss drop và chế tạo V2 dưới DESIGN_ONLY.
- Windows 10 thật 1280×720/Intel GUI, Android thực và thời gian thực offline PENDING USER, không đồng nhất với Linux Godot official.

## 6. Thứ tự công việc kế tiếp trên duy nhất PR #72

1. PVE-BAL01: chính xác quyền thưởng và ngăn double HP/pill; Godot focused + replay + cold Save.
2. PVE-BAL02: đo sát thương/kill/h, tiêu Đan/giờ, số lần rút khỏi bãi săn; chỉ chấp nhận chỉ số có log thực.
3. SX-BAL03: đối chiếu đúng giá giống V5.4, giá market, tiền từ LT2 và thuế T2; không thay chi phí các đơn hàng đã chạy.
4. DROP-BAL04: tạo bảng quái thường/Elite/Boss và công thức trang bị/công pháp r1–r2 bằng nguyên liệu thật, test rơi, không hạch toán giả.
5. RECIPE-BAL05: nối từng role vào nguồn thật theo cảnh r3–r30, điều kiện mở Linh Điền/Mỏ/Lâm/shop; chỉ enable recipe khi đủ resource/source/cost/consumer.
6. QA: diễn tập 1/7/30 ngày, FULL CI exact SHA, Windows/Android rồi mới quyết định bật bản public.

**Không nghiệm thu r3+ chỉ vì JSON có 119 dòng. Không kết luận cân bằng dài hạn chỉ vì một kịch bản 12 kill/h đạt ROI.**
