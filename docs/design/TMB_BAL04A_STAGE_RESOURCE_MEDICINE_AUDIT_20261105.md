# BAL-04A — KIỂM TOÁN CHỈ SỐ THEO GIAI ĐOẠN, SOURCE → CONSUMER

**Ngày:** 2026-11-05. **Nhánh:** `integration/pve-p0-playable-ui-20261103`. **Tình trạng:** READ-ONLY SOURCE AUDIT + CODED QA CONTRACT, **chưa duyệt thay cân bằng runtime, chưa chạy Godot test**.

**Nhiệm vụ Owner:** code trên PR #72 duy nhất; mỗi vật phẩm cần nguồn và chức năng thật; chỉ số phải phù hợp Nhân/Tiên/Thần và nhịp phát triển dài hạn; công khai toàn bộ các con số quan trọng cho Owner chọn. Không động SaveService/PvE/animation/main.

## 1. Dữ liệu đã kiểm tra trong code (CURRENT_RUNTIME_SOURCE, không phải balance mới)

### 1.1 Sản xuất tài nguyên

| ID | Nguồn có code | Điều kiện | Chi phí/cycle cơ sở | Đầu ra cơ sở | Người tiêu thụ thực |
|---|---|---|---|---|---|
| `thanh_thiet` | Mỏ `carry_cycle` | có Mỏ, worker hợp lệ | công đoạn làm `4.0`; có vận chuyển | `2` units/batch | xây/nâng cấp; không coi giá bán là nguồn |
| `linh_moc` | Linh Lâm `carry_cycle` | có Linh Lâm, worker hợp lệ | công đoạn `4.0`; có vận chuyển | `2` units/batch | xây/nâng cấp |
| `thanh_linh_thao` | Linh Điền | Field Lv1 | `4` Linh Thạch, `12` ticks | `3` cây, job EXP cơ sở `10` | 5 công thức: HXD, TQD, r1 heal, r1 tuvi và r2 heal |
| `linh_coc` | Linh Điền | Field Lv1 | `3` Linh Thạch, `10` ticks | `5` đơn vị, EXP cơ sở `8` | TQD legacy, r1 TuVi, r2 TuVi |
| `tu_van_thao` | Linh Điền | **Field Lv30** | `14` Linh Thạch, `24` ticks | `3` cây, EXP cơ sở `16` | hai công thức thuốc cảnh giới 2 |

> `base_cycle_ticks` của cây là nhịp cơ sở; thời gian giao hàng thực còn phụ thuộc tay nghề/cấp ruộng/policy. `base_work_duration` của Mỏ/Lâm không bao gồm toàn bộ chuyến đi và giao nộp. Không suy diễn đơn vị/giờ từ các số này.

### 1.2 Công thức thuốc đã CHẾ TẠO ĐƯỢC (6 công thức, không phải 240)

| ID công thức | Input đã có nguồn | Output | Ticks gốc | Gate |
|---|---|---|---:|---|
| `hoi_xuan_dan` | `thanh_linh_thao ×3` | `hoi_xuan_dan ×1` | 6 | nghề 0, Đan Điện mặc định Lv1 |
| `tu_khi_dan` | `thanh_linh_thao ×2 + linh_coc ×1` | `tu_khi_dan ×1` | 6 | nghề 0, Lv1 |
| `sx02_recipe_heal_r01` | `thanh_linh_thao ×3` | thuốc Hồi Nguyên r1 ×1 (phẩm quyết định lúc khởi công) | 6 | nghề 0, Lv1 |
| `sx02_recipe_tuvi_r01` | `thanh_linh_thao ×2 + linh_coc ×1` | thuốc Tụ Linh r1 ×1 | 6 | nghề 0, Lv1 |
| `sx02_recipe_heal_r02` | `tu_van_thao ×2 + thanh_linh_thao ×2` | thuốc Hồi Nguyên r2 ×1 | 10 | nghề 3, Đan Điện Lv10 |
| `sx02_recipe_tuvi_r02` | `tu_van_thao ×2 + linh_coc ×2` | thuốc Tụ Linh r2 ×1 | 10 | nghề 3, Lv10 |

**Quan trọng:** 240 SKU metadata = `30 realm × 4 quality × 2 families`. Chỉ **4** recipe SX02 (r1,r2; heal,tuvi) và **2** legacy; chưa có 28 realm cao. Các SKU `craftable=true` theo danh sách realm r1,r2 không có nghĩa đã có nguyên liệu ở Kho. Không được tạo drop, recipe, ingredient r3..30 tự động.

### 1.3 Nâng chất lượng thuốc hiện tại

| Phẩm đầu ra | Hệ số hiệu lực | Cần nghề Luyện Đan | Cần cấp Đan Điện |
|---|---:|---:|---:|
| Hạ (q1) | ×1.00 | 0 | 1 |
| Trung (q2) | ×1.25 | ≥2 | ≥5 |
| Thượng (q3) | ×1.55 | ≥5 | ≥10 |
| Cực (q4) | ×2.00 | ≥10 | ≥20 |

Hệ thống hiện cho phẩm **deterministic** theo nghề & công trình, chưa có xác suất grade roll; đừng giới thiệu là “đan phẩm ngẫu nhiên”.

## 2. Tính phù hợp theo cảnh giới: phát hiện phải xử lý

**A. Thuốc Hồi Xuân cũ:** `NeedsSystem.HEALING_PILL_HP=55` bất kể maxHP. Với Core HP đồng cấp: r1.1 190 (28.95%), r5.1 ~1,408 (3.91%), r10.10 ~22,472 (0.245%), r20.10 ~3,361,116 (0.00164%). Ở late thuốc cũ hầu như vô dụng. `SX01PillPolicy.review` vẫn có cơ chế fallback HXD nếu không chọn được graded heal. Không chuyển thành phần trăm miễn phí; cần duyệt chính sách eligibility/auto-use.

**B. Thuốc Tu Vi mới tại cảnh giới r, phẩm 1:** runtime `10000×1.65^(r-1)` trong khi tổng XP cần qua cảnh r từ `DiscipleProgressionBalanceV2.REALM_TOTAL_XP` tăng khoảng 1.27. Chênh lệch khuếch đại cực lớn:

| Cảnh r | Tổng EXP của cảnh | EXP tầng đầu cảnh (7%) | Thuốc q1 **đang định nghĩa** | % một tầng đầu | `0.1%×tổng XP cảnh` **ĐỀ XUẤT** |
|---:|---:|---:|---:|---:|---:|
| 1 | 10,000,000 | 700,000 | 10,000 | 1.43% | 10,000 |
| 2 | 12,700,000 | 889,000 | 16,500 | 1.86% | 12,700 |
| 5 | 26,000,000 | 1,820,000 | 74,120 | 4.07% | 26,000 |
| 10 | 86,000,000 | 6,020,000 | 906,474 | 15.06% | 86,000 |
| 11 | 109,200,000 | 7,644,000 | 1,495,683 | 19.57% | 109,200 |
| 20 | 938,200,000 | 65,674,000 | 135,579,785 | 206.44% | 938,200 |
| 21 | 1,191,500,000 | 83,405,000 | 223,706,645 | 268.22% | 1,191,500 |
| 30 | 10,240,200,000 | 716,814,000 | 20,278,432,534 | 2828.97% | 10,240,200 |

Đề xuất dùng `potency_tuvi=round(REALM_TOTAL_XP[r-1]×0.001×quality_factor)`: giữ nguyên **10.000** ở r1 q1, luôn khoảng **1,43% EXP tầng đầu** thay vì 2.829% ở r30. **Chưa áp code:** cần owner duyệt, đánh giá chế độ auto dùng, max per day, cost mỗi recipe và sát thương/tốc săn kiếm nguyên liệu trước.

**C. Bộ thuốc Hồi Nguyên phân rank hiện tại:** `55×1.65^(r-1)×quality_factor`. Khi Tu Vi và Luyện Thể cùng r.1, thuốc q1 hồi khoảng **28.95% Core HP** ở mọi cảnh (khác HXD cố định). Với trang bị/buff HP, tỷ lệ thay đổi. Đây là lý do nên giữ thuốc phân rank thay vì cho HXD tăng cấp vô hạn.

**D. Field Lv30 → thuốc r2:** Tử Vân yêu cầu Lv30, và quá trình lên cấp phải qua Heart tại mốc 10/20/30. Cần 1+2+3=6 Heart = **600 mảnh**, 5% chance cơ sở/harvest → kỳ vọng khoảng **12.000 lượt thu hoạch** để gom đủ mảnh *nếu chỉ dùng nguồn này và rare_factor=1*. Thời gian thực phụ thuộc số luống, canh tác, may mắn, tốc độ, nguồn khác và luật upgrade. Đây là **nguy cơ lệch giai đoạn**, không được xử lý bằng phát Tử Vân miễn phí.

**E. Lv100:** `BuildingSystem.spirit_field_yield_factor` hiện `(1+0.005×(L-1))×1.10 [L≥20]×1.10 [L≥75]×1.20 [L≥100]`. Tại L100 ~**2.17× routine yield** so với Lv1, chưa tính plot slots và bonus nghề. Không thể tuyên bố đạt mục tiêu cuối game ×10.000 theo quyết định Owner lịch sử; cần định nghĩa đó là yield đơn vị, throughput tổng, hay hiệu suất kinh tế ròng để tránh inflation.

## 3. Benchmark tiến trình nền (không phải dự báo thời gian chơi)

`DiscipleProgressionBalanceV2` đã có 30 tổng EXP, r1 = 10 triệu, r30 = 10,240.2 triệu; `BASE_TUVI_PER_MINUTE=1000`, `CULTIVATE_MULTIPLIER=2`. **Giả định đối chứng 2.000 Tu Vi/phút 24/7, chưa tính bất kỳ bonus/nhiệm vụ/đan/breakthrough/travel**:

| Đã vượt hết cảnh | EXP cộng dồn | Số ngày tối thiểu theo giả định | Hệ số cần so với tốc độ gốc để đạt mốc mục tiêu |
|---:|---:|---:|---:|
| 10 | 367,400,000 | 127.6 ngày | 1.42× |
| 20 | 4,376,300,000 | 1519.5 ngày | 4.16× |
| 30 | 48,130,600,000 | 16712.0 ngày | 22.89× |

Mục tiêu Owner: khoảng **3 tháng hết Nhân, 12 tháng vào Thần, 24 tháng hết Thần**. Baseline tuyến tính hiện không tự đạt mốc; phải xem bonus tăng theo bậc, nguồn EXP từng giai đoạn, đan tiêu hao, PvE, số đệ tử và gate thật trước khi hạ chi phí hoặc buff toàn hệ. Các hệ số “cần” là **đường kiểm toán**, không phải bonus đã được cấp.

## 4. Các lựa chọn cần Owner duyệt — chưa đưa runtime

### BAL-04A / Chính sách thuốc cấp thấp

- **A (khuyến nghị):** giữ thuốc cấp thấp cho người mới; AI chỉ tự dùng nếu hồi thực tế ≥**2% maxHP**; nếu thấp hơn thì ưu tiên thuốc đúng bậc hoặc nghỉ hồi phục. Không hủy quyền dùng thủ công và không sửa hiệu ứng 55HP cũ. Với cùng Core HP không buff, HXD thường tự dừng từ r7+. Với thuốc cùng realm mới, vẫn tối ưu theo hồi thực tế và tồn kho.
- **B:** thuốc heal chỉ tự dùng cho nhân vật có cảnh giới **cao hơn bậc thuốc tối đa 2 đại cảnh**; mạnh về nhận diện tier, nhưng thuốc thừa có thể tồn.
- **C:** AI tiếp tục dùng mọi thuốc có tăng HP, không chặn; giữ nguyên hành vi cũ nhưng có rủi ro lãng phí (không khuyến nghị).

### BAL-04B / Sức mạnh thuốc Tu Vi cao cấp

- **A (khuyến nghị):** q1 = **0.1% tổng EXP của cảnh thuốc**, nhân hệ số phẩm đang có; so theo XP realm hiện hành, giữ r1 10k.
- **B:** q1 = **0.2%** tổng EXP cảnh, r1 tăng thành 20k (phải duyệt sửa số Tu Vi cơ sở đã khóa, không khuyến nghị).
- **C:** giữ `10000×1.65^(r-1)`, nhưng **khóa không cho sản xuất từ r3+** đến khi được xem lại; hiện recipe đã chưa có, nên chưa gây lạm phát tức thời.

### BAL-04C / Mở nguyên liệu r2

- **A (khuyến nghị):** điều chỉnh đường mở **Tử Vân Thảo tại Field Lv10** *khi* có nguồn Heart Lv10 thực và kiểm thử giai đoạn; không phát miễn phí, còn nghề3/Đan Điện Lv10. Số 10 là **đề xuất**, không phải quyền sửa hiện tại.
- **B:** giữ Field Lv30 nhưng thêm nguồn PvE r2 có giới hạn và receipt thật trước khi mở recipe (cần thiết kế drop ID và chống lạm phát).
- **C:** giữ Lv30, ghi rõ r2 thuốc là hàng hiếm late-R2; r2 player giai đoạn đầu sử dụng cơ chế khác.

## 5. Hàng rào QA trước khi chuyển sang runtime

- Đã **commit test mới** `godot/tests/simulation/sx03_source_consumer_stage_contract_test.gd`, chỉ đọc registry/crop/recipe và check link, không tạo save, vật phẩm hay tiền; **GODOT NOT RUN**.
- Không thay `BuildingSystem`, `SX01PillPolicy`, `MedicineCatalogueV2`, `B3PillSatietyV1`, `SaveService` hoặc combat khi chưa chốt phương án và allowlist cụ thể.
- Với thay đổi runtime: yêu cầu 1 vòng crop thật → craft thật → B3 consume thật, cùng với realm eligibility, EXP amount, exact-once, Save/Reload qua 3 tiến trình và Godot official 4.7.2.
- Không tự lấy số liệu lịch sử làm mới; resource không có nguồn `ID/source` rõ hoặc consumer thật thì vẫn **DESIGN_HOLD**.
- Bất kỳ packet nào thêm recipe r3–30 đều phải có nguyên liệu mới có source/tiến trình phù hợp và nguồn cung không phá softlock.
