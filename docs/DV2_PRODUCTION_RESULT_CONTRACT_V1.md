# DV2 — HỢP ĐỒNG SẢN XUẤT TỪ NGUỒN GỐC ĐẾN THÀNH PHẨM

Ngày: 2026-10-09.

**Status: DESIGN INTERFACE V1, with an implemented Economy V2 pilot on the integration branch.** The common-yield curve, timed Mine/Forest/Field jobs, Warehouse settlement and finite merchant budget now have code and focused Windows Godot tests. Universal quantity modifiers, refunds, product quality and advanced tier sources remain OPEN. See [integration research and ledger](ECONOMY_V2_INTEGRATION_RESEARCH_AND_BALANCE_2026-10-16.md) for the exact implemented boundary.

Các nguồn nền: `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`, `docs/P3_7_BUILDING_TREE_SPEC.md`, `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`, `docs/P3_7_SPIRIT_FIELD_SPEC.md`, `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`, `docs/TRAITS_V2_SPEC.md`, `docs/DESTINY_V2_SPEC.md`, `docs/BODY_CULTIVATION_V2_SPEC.md`.

## 1. Phân biệt nguồn, tốc độ, chi phí, chất lượng và kết quả

Hợp đồng một hành động thực tế:

```text
worksite/recipe/task (WHAT CAN BE DONE)
  + disciple/job/level/assignments (WHO DOES IT)
  + task input inventory and building state (WHAT IT CONSUMES)
  + typed sources: profession talent, Trait, Fate, Bloodline, Physique,
                   explicit root-affinity, relevant equipment, facility (WHAT MODIFIES)
      -> eligibility / reserve
      -> active-work progress with actual elapsed simulation time
      -> canonical work result resolution
      -> output quantity / source-tagged quality / rare result / costs
      -> warehouse transaction commit
      -> profession XP / work Tu Vi / history events
```

**Không tồn tại một chỉ số `Sức Lao Động` hoặc `Work Power` chung.** Không gán tất cả nghề vào một nguồn sản lượng. Việc đạt cùng số vật liệu trong ít thời gian ≠ nhiều vật liệu mỗi lượt.

## 2. Các kênh và công thức hiện có phải giữ

| Channel | Formula/owner đã chốt | Consumer |
|---|---|---|
| Profession Level | `floor(sqrt(profession_XP/24))` | `WorkforceSystem`/một nghề cụ thể |
| Profession Speed | `1+0.01×ProfessionLevel` | tiến trình/tốc độ một ca hợp lệ |
| Work Speed | `ProfessionSpeed × ValidWorkSpeedModifiers × OptionalAffinity × FacilityFactor` | thời gian công việc, không tự nhân đầu ra từng ca |
| Profession XP | BaseXP × (1+0.0015×ThôngTuệ+sum(valid profession XP %)) | XP nghề thật sau ca hoàn thành |
| Talent XP | Grade 1/2/3/4/5 -> +5/+10/+15/+20/+25% XP; tách biệt Trait | tiến trình nghề |
| Matching Root | `×1.05` Work Speed chỉ cho recipe/crop/resource có tag tương hợp | recipe/task cụ thể, không phải passive mọi nghề |
| Work Tu Vi | `CurrentStageRequirement × 0.0005 × (1+0.0005×Level)` / giờ làm thật → CultivationGainChannel một lần | Tu Vi có thẩm quyền, không tự cấp trong chờ đếm ngược |
| Rare outcome | `RNG[0..9999]+CơDuyên−Difficulty` và nguồn điều chỉnh được phép | chỉ khi task có meaningful rare/quality event; không mỗi tick |

**M-01: Ordinary same-channel percentages** (ví dụ +10% và +15% Work Speed) cộng thành một factor `1+0.10+0.15=1.25`, không tự tính `1.10×1.15`. Sau đó **các factor thuộc nguồn thành phần khác** (profession level, facility, explicit matching affinity) kết hợp theo P3.7; không nhân lại lượng vật liệu sản xuất bởi Work Speed.

### Ví dụ độc lập

Nếu cùng một nhiệm vụ mất **60 phút gốc**, Level 20 cho `×1.20`, Đặc Chất +10% Work Speed → `×1.10`:
- thời gian hoàn thành giả định `60 / (1.20×1.10) ≈ 45,45` phút khi FacilityFactor 1;
- nếu recipe gốc cho **3 quặng/chu kỳ**, kết quả vẫn **3 quặng/chu kỳ**;
- Thông Tuệ không tự làm mỗi chu kỳ từ 3 quặng thành 4 quặng;
- người hoàn thành nhiều chu kỳ trong một ngày sẽ có **tổng sản lượng/ngày** cao hơn một cách tự nhiên.

Đây là minh họa toán, không có nghĩa đã sửa timer của mỏ P3.7 thành thời gian thật này.

## 3. Hợp đồng đầu ra theo từng nghề

| Đầu ra | Định nghĩa canonical | Thẩm quyền sở hữu |
|---|---|---|
| `duration` / `work_progress` | Base task duration và phần tiến độ đã làm; đi lại chỉ được tính nếu map/time authority có quãng đường thật | Worksite/task Building hoặc recipe owner |
| `input_required` | Danh sách ID nguyên liệu × số lượng, tier/tag, điều kiện inventory/reserve | Recipe/task, warehouse |
| `input_spent` | Nguyên liệu thực sự trừ vào kho **đúng một lần theo giai đoạn commit** | Warehouse transaction owner |
| `quantity` | Số lượng resource/item/service thật hoàn thành sau một ca | Crop/mine/recipe owner |
| `quality` | Phẩm chất kết quả mà một loại thành phẩm **thực sự có phân phẩm** quy định | Content family author; không universal quality roll |
| `rare_result` | Một bảng kết quả cơ duyên, có difficulty/table ID, kết quả được chọn duy nhất | Task/mine/field/event author |
| `profession_xp` | Nghề thực sự nhận XP, có provenance và source | Profession owner |
| `cultivation_gain` | Chỉ gắn giờ làm thực tế, tính qua CultivationGainSource như đã khóa | Cultivation owner |
| `event_history` | ID actor, ID action, outcome và significant flag | Simulation life-history owner |

Nhiều nghề **không cần đủ các channel**. Ví dụ bốc xếp có thể chỉ tác động tốc độ và XP; luyện đan có recipe và phẩm chất; thu hoạch có chu kỳ cây, thu hoạch và một kiểm tra hạt giống hiếm.

## 4. Quy tắc mặc định của một transaction (HƯỚNG THIẾT KẾ, CHƯA CODE)

1. Kiểm tra **đủ công trình, quyền làm việc, nghề, mốc mở, thời gian, slot, vật liệu có thật**.
2. Nếu hành động cần vật liệu, **reserve** theo chính sách kho thực trước khi tiêu hao. Không tạo mất/trùng vật liệu khi đổi lệnh hoặc hủy công việc.
3. Theo dõi tiến trình hoàn thành trong simulation, không phải tự cộng tài nguyên theo số lần hiện popup UI.
4. Khi hoàn thành, một commit duy nhất xử lý chi phí/hoàn trả/đầu ra/XP và chống việc trả hai lần theo `action_instance_id`.
5. Sau outcome mới emit event hợp lệ cho Đặc Chất/Mệnh Cách học nghề/tạo buff/đánh dấu thành tựu. Hook “trước/đang/sau completion” phải khai báo rõ và không trigger lặp.
6. Không tác động `Expedition Stamina` khi làm việc bên trong tông môn. Nếu phải xử lý việc căng thẳng/nghỉ ca theo Trait vui nhộn, cần một subsystem riêng được duyệt.

Không giả định P3.7 đã có **một** transaction owner đa nghề; đó là hướng migration phải làm dần khi tới gameplay phase.

## 5. Quantity và nguyên liệu — hợp đồng nguồn tác động

**Các kênh cần hỗ trợ về mặt cấu trúc:** `output_quantity_flat`, `output_quantity_percent`, `input_material_percent`, `eligible_refund_quantity`, lọc `recipe_id`, `resource_family`, `profession_id`, `rarity_tier`.

- Các effect chỉ tác động đến thành phẩm/recipe mà content author đánh dấu **supports_quantity_modifier**. Không cho `+100% output` sao chép thanh kiếm độc nhất, vật phẩm nhiệm vụ, tông môn thủ lệnh, Mệnh Nguyên.
- Đặc Chất `Tiết Liệu`, `Phung Phí` phải khai báo rõ **từng đầu vào nào** được phép sửa; không tự giảm chi phí tinh hoa/hạch duy nhất hoặc thứ nguyên liệu không được discount.
- `Thiên Công Khai Vật`: vẫn **tiêu hao và hoàn tất recipe theo luật bình thường trước**, rồi hoàn trả số lượng nguyên liệu thường hợp lệ **một lần mỗi ngày**, có journal chống lặp/cancel/save-reload.
- `Tài Tinh Nhập Mệnh`: chỉ nhân output stackable hiếm và sau **một lần rare/quality task đạt tier cao nhất thực**, không nhân mọi sản lượng routine.
- **Quantity và cost dùng số nguyên không âm**. Các quy tắc làm tròn, xử lý phần lẻ và trường hợp recipe chỉ dùng 1 nguyên liệu của `-20% cost` là **BẢN CÂN BẰNG CHƯA KHÓA**, phải chốt trước viết code cost optimizer. Không âm thầm hứa tiết kiệm 20% nhưng trên recipe dùng 1 viên lại không bao giờ có tác dụng.

## 6. Phẩm chất — không phải một hệ chỉ số con người mới

- **Phẩm Chất Đệ Tử** là nhãn từ Lục Duy, **không phải** cấp sản phẩm.
- `product_quality` thuộc **loại thành phẩm** và **công thức công trình**, không lưu thành stat gốc của đệ tử.
- Chỉ khi **recipe định nghĩa quality outcome** mới chạy kiểm tra phẩm chất. Có thể tham chiếu profession level/thuộc tính/nguyên liệu/Facility/Đặc Chất/Mệnh hợp lệ, nhưng không được tự tạo thêm cơ chế `Quality Power` chung.
- Nghề khác có thể sử dụng cùng `LuckScore` nếu đó thực sự là sự kiện hiếm và có bảng difficulty hợp lệ; không tự dùng nó thay toàn bộ quality-quality grade.
- Cần khóa từng họ recipe: `quality_input_tags`, `eligible_quality_tiers`, `difficulty/quality_formula`, `material_rounding`, `quality_modifier_mode`. Thông số không thể được suy ra chỉ từ tên `Luyện Đan` hay `Khai Khoáng`.

## 7. Một ví dụ có Đặc Chất / Mệnh Cách (CHỈ MINH HỌA)

Đệ tử có `Cần Mẫn`, `Mắt Nhìn Quặng` và Mệnh `Tài Tinh Nhập Mệnh`:
- Cần Mẫn tăng **work_speed** khi là nguồn hợp lệ, nên hoàn thành một chu kỳ nhanh hơn.
- Mắt Nhìn Quặng chỉ sửa độ khó **một kiểm tra quặng hiếm thật** có nguồn và rarity table, không cho +quặng thường.
- Nếu kiểm tra đạt tier cao nhất, `Tài Tinh Nhập Mệnh` có thể nhân đôi lượng quặng **stackable hiếm** của lượt hoàn thành đủ điều kiện đầu tiên trong ngày.
- Tất cả phải ghi rõ action ID/actor, source IDs, đầu ra vào **canonical Sect Warehouse** và áp dụng một lần duy nhất.
- Không được tạo ấn/XP/cơ duyên nếu chỉ gán công trình mà chưa làm xong.

## 8. Phân cấp readiness

| Hợp đồng | Tình trạng |
|---|---|
| Profession Level & Speed, learning XP, active-work Tu Vi | P3.7 backend law exists; V2 no-stamina migration **chưa code** |
| Yield và thời gian công trình Mine/Linh Điền hiện tại | Đã có action P3.7, cần chuẩn hóa chung mà không phá behavior |
| Universal stackable output modifiers | Cần owner và tests, chưa được triển khai |
| Cost efficiency / material refund | Cần quyết định cách làm tròn và transaction ID, chưa code |
| Product quality for crafting recipes | Cần bảng quality theo họ recipe, chưa code |
| Lucky outcomes | Score có authority, từng task phải có bảng tier/khả dụng riêng |
| Food/rest/social/work-fatigue Traits | Consumer-gated/future; không gán buff giả |

## 9. Gate kiểm thử bắt buộc

1. Cấp nghề +20% => ca nhanh hơn theo luật, mỗi ca không tự dư vật liệu.
2. Thông Tuệ/talent XP => XP thay đổi, nhưng số quặng và thời gian chu kỳ hiện tại không đổi chỉ vì XP bonus.
3. Toàn bộ tác vụ trong tông môn tiêu hao Thể Lực Viễn Chinh **0**, dù HP thấp hoặc Thể Lực ngoài map bằng 0.
4. Mỗi `action_instance_id` tạo output/XP/consumption exactly once khi hoàn thành; cancel và save/reload không thưởng thêm.
5. Empty recipe/none rarity vẫn có thể hoàn thành bình thường.
6. Cost discount, refund hoặc doubling không làm nhân bản unique/non-stackable/quest items.
7. Không kiểm tra Cơ Duyên theo mỗi tick, chỉ đúng eligible rare outcome.
8. 1.000–3.000 đệ tử: timer/expedition/news không polling tràn theo số lượng công thức không liên quan.
9. Existing Godot 4.7.2 P3.7 Mine/Linh Điền/Warehouse regression phải PASS thật trước khi thay luật sản xuất có thẩm quyền.

## 10. Open items để chốt theo đúng trục nguồn → kết quả

- Numeric material rounding/minimums/fractional saving behavior;
- quality scales and input formulas **for each supported recipe family**;
- phase-specific `reserve/consume/refund` when jobs can cancel/reassign;
- shop/trade price modifiers vs production-output cost;
- optional future work-fatigue/shift/meal effects independent of Expedition Stamina.

**Không dùng quy tắc cấp 1–5 cho Đặc Chất V2; giữ Grade 1–5 thiên phú nghề riêng.** Tài liệu này không thay đổi rate Đặc Chất hoặc Mệnh Cách khi sinh.
