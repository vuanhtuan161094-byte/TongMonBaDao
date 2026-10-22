# TÔNG MÔN BÁ ĐẠO — 300-TẦNG GROWTH / MAP / LINH ĐIỀN / ĐAN DƯỢC — BALANCE LAB

**Ngày:** 2026-10-22 · **Loại:** READ-ONLY DESIGN + ANALYTICAL / MONTE-CARLO SIMULATION · **Trạng thái:** PROPOSED, **KHÔNG** CODE/QA/PASS · **Nhánh:** `docs/tmb-agent-skills-20261022` · **main đọc được:** `461caca1171462e0da092f21108c5c1733157ad9`.

> TÀI LIỆU NÀY KHÔNG KHÓA CÁC GIÁ TRỊ CHƯA PHÊ DUYỆT. **CARE-FASTTRACK vẫn là phiên Codex đang làm, chưa lấy được code hiện hành từ local worktree.** B3 FAST-TRACK PASS ở checkpoint local `1d686dc8` không hiện diện trên main. Nội dung dưới đây căn cứ code chính thức hiện có trên main cộng các quyết định owner ngày 22/10; số liệu future là `SIMULATION_ONLY`. Không sửa `AGENTS.md`, gameplay, main, CARE, Source A, renderer hay build. Không thay thế các đặc tả canonical.

## 0. Công cụ và quy tắc phân tầng bằng chứng

- Đọc `.agents/skills/tmb-project-director/SKILL.md`, `.agents/skills/tmb-balance-lab/SKILL.md`; áp dụng thứ tự `AGENTS.md`, [architecture](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/docs/GAME_SYSTEM_ARCHITECTURE.md), checkpoint, code và quyết định mới nhất của owner.
- `LOCKED`: Tu Vi & Luyện Thể là **hai track** độc lập, mỗi track 30 cảnh giới × 10 tầng; **cùng cost curve**; đột phá Tu Vi tuân theo canonical major gate/chance, đột phá Luyện Thể là deterministic nhưng cần verified materials.
- `CODE(main)`: [balance](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/godot/src/simulation/cultivation/disciple_progression_balance_v2.gd) có tổng 30 realm = **48,130,600,000 XP** / track, weights per floor (7%,7.5%,8%,8.5%,9%,10%,11%,12%,13%,14%). [TuViFlow](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/godot/src/simulation/cultivation/disciple_tuvi_flow_v2.gd) 1000 Tu Vi/phút trước cộng Tư Chất (+0.25%/điểm) và nguồn hợp lệ, `CULTIVATE x2` theo luật đang chạy; được cấp **một** grant tự nhiên/tick ngay cả lúc hunt, không phải mỗi nguồn một grant.
- `CODE(main)`: [Body source](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/godot/src/simulation/cultivation/disciple_body_xp_source_v2.gd) có `production`, `body_training`, `expedition`, chỉ một nguồn natural body XP/tick; mốc tham chiếu 250/1500/750 phút, Rèn Thân Đường thực trừ **1 Linh Thạch/phút** để cấp 1500 XP/phút.
- `CODE(main)`: [map registry](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/godot/src/simulation/combat/hunting_map_v2.gd) có **3 vùng**: Thanh Trúc Lâm (r1f1), Bạch Thạch Khê (r1f3), Hắc Phong Cốc (r1f6). Mỗi vùng 5 mức PvE riêng, với yield 1, 1.35, 1.8, 2.5, 3.5; boss/elite rates là PILOT. Không suy diễn rằng đã có map r2–r30.
- `CODE(main)`: [3 cây](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/godot/src/simulation/building/spirit_crop_registry.gd) Thanh Linh Thảo Lv1 (12 tick, 3/cycle, 4 stone), Linh Cốc Lv1 (10 tick, 5/cycle, 3 stone), Tử Vân Thảo Lv30 (24 tick, 3/cycle, 14 stone). [Alchemy](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/godot/src/simulation/building/alchemy_recipe_registry.gd) trên main chỉ có Hồi Xuân Đan 3 Thanh Linh Thảo /6 ticks. Tụ Khí Đan thuộc phạm vi CARE local đang chạy, KHÔNG nhầm với main.
- `OWNER-LOCK` mới: Bão Hòa `100000` điểm/người/ngày **simulation** (= `floor(tick/1440)`), chia chung các thuốc; Hồi Xuân +55 HP, 10 điểm; Tụ Khí +10000 **fixed** Tu Vi, 25 điểm, 2 Thanh Linh Thảo + 1 Linh Cốc /6 ticks. Đan cơ bản thuộc giai đoạn đầu; future grade phải có vật phẩm, nguyên liệu và pha map tương ứng. Bão hòa không phải tự động hạn chế sản lượng.
- `CODE(main)`: [realm progress](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/godot/src/simulation/cultivation/disciple_realm_progress_v2.gd) cố định +XP dùng `gain_type=fixed`, **không** nhân Tư Chất/Căn Cốt; at-major-gate không tự vượt, surplus trả `unapplied_overflow`, không có kho XP thừa được phép tạo bừa. [C1](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md) percentage bonus cùng channel là additive trên base.

## 1. Định nghĩa vòng chơi 300 tầng (future DESIGN)

Một người chơi quản lý **chính sách**, không nhấp tay từng đệ tử. Vòng kinh tế & năng lực:

```text
Chọn vùng farm theo cảnh giới + độ nguy hiểm
 -> thắng combat hợp lệ -> Warehouse nhận tài nguyên/map drops đúng receipt
 -> Linh Điền (Lv1..100, nghề Linh Thực) cấp linh dược theo loại/realm
 -> Luyện Đan / Rèn Thân / Mật Thất dùng nguyên liệu, Linh Thạch và thời gian thật
 -> một đệ tử nhận fixed Tu Vi, Body XP hoặc HP sau transaction hợp lệ
 -> xử lý đại cảnh giới/gate riêng; mở map và nguyên liệu cấp tiếp theo
```

**Không** tăng thẳng EXP chỉ vì boss/monster HP0 trong B3 hiện hữu. Khi owner phê duyệt reward Tu Vi theo map trong CODE packet khác, đề xuất **hai dòng** rõ ràng:
- A) `map_ambient_natural` — hệ số hiệu suất Tu Vi **trên nguồn tự nhiên duy nhất của tick**, được chính `SimulationScheduler` xác thực từ map/actor/time; KHÔNG là grant bổ sung. Có thể áp dụng buff êm trong lúc di chuyển/chiến đấu, nhưng các bonus trong channel cộng theo nguồn, không xếp nhân đôi.
- B) `encounter_completion_fixed` — *tùy chọn về sau* bonus Tu Vi cá nhân một lần cho **encounter hoàn thành thật** (không last-hit, không XP mỗi quái). Phải có contract đối tượng tham gia, kết quả, bảo vệ replay, `DiscipleRealmProgressV2.grant_xp(...,"fixed")` và receipt riêng được owner duyệt. **B3/CARE chưa có quyền triển khai B**. Không gán bonus boss nhiều đội khi chưa khóa participation fixture.

Đối với Luyện Thể, giữ một trong `production|body_training|expedition` mỗi tick; sức mạnh map có thể điều chỉnh `expedition` trong nguồn hợp lệ; Rèn Thân trả phí thật; fixed Body consumable là tương lai độc lập. **Linh Điền cấp nguyên liệu và EXP nghề, không tự cộng Tu Vi khi plot chỉ đang đếm giờ** — đúng [Spirit Field canonical](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/docs/P3_7_SPIRIT_FIELD_SPEC.md).

## 2. 30 cấp nguyên liệu/thuốc, không tạo 30 hệ thống riêng

**Chọn cấu trúc 10 dải nội dung × 3 cảnh giới/dải**, trong mỗi dải có 3 cấp phẩm tương ứng 3 cảnh giới, tạo đủ 30 nấc cho từng track. Các ID bên dưới chỉ là mẫu danh pháp:
- `tu_khi_dan_b01_g1` ... `tu_khi_dan_b10_g3` — Tu Vi fixed, mức mạnh tăng theo rarity/realm; r1 dùng ID đã duyệt `tu_khi_dan`, **không tự đổi ID**.
- `hoi_xuan_dan_b01_g1` ... `hoi_xuan_dan_b10_g3` — trị thương fixed HP theo thang maxHP Combat V2. r1 giữ `hoi_xuan_dan`, +55.
- `luyen_the_dan_b01_g1` ... — Body XP fixed mới, **DESIGN ONLY**; không thêm vào CARE. Cùng Đan Bão Hòa chỉ khi owner quyết định áp dụng cho họ thuốc này.
- `herb_bXX_gY`, `grain_bXX_gY`, `boss_material_bXX_gY` chỉ là nhãn placeholder, không phải asset, tên item, tên nguyên liệu hay ResourceRegistry đã tồn tại. Content phải định danh cây theo vai trò, realm-grade và giá trị cụ thể trước khi CODE.
- Giữ `thanh_linh_thao`/`linh_coc`/`tu_van_thao` hiện có. Tử Vân Thảo hiện yêu cầu Linh Điền Lv30 và thuộc realm-rank 2; **KHÔNG** ép nó vào công thức chung field-level giả định và vô tình hạ Lv30 xuống cấp thấp.
- Đan cấp thấp vẫn được dùng khi lên cao nếu không bị content quy định khóa, nhưng giảm hiệu quả thực tế trên HP/EXP cấp cao; **không** dùng %HP hiện tại đơn thuần cho thuốc thấp vì sẽ khiến thuốc Lv1 tự scale mãi mãi.

### Khuyến nghị hiệu lực thuốc (chưa khóa)

- Tu Khí rank r, grade g: **fixed XP**; giá trị hiệu chuẩn sơ bộ `0.10% × realm_total_xp(r)` (round tới 1000), grade 1; vì floor1 chiếm 7% nên tương đương **1.4286% EXP tầng 1**. Mốc r1 chính xác 10,000 theo owner. g2, g3 nên dựa vào chi phí nguyên liệu và fixture kinh tế, không chốt ngay multiplier. Tính đủ r1–r30 trong CSV đi kèm. Đây là test-value, **không** mặc định nhiều đan cao cấp có thể luyện 6 tick với 2 cỏ Lv1.
- Hồi Xuân cấp r: dùng **fixed HP** được chốt bằng snapshot Combat V2 cho cặp (tuvi realm, luyện thể realm), Tiềm Lực đại diện và trang bị mẫu. Ngưỡng đánh giá đề xuất: một viên đúng cấp phục hồi 15–30% HP khi thiếu máu; không được biến cấp thấp thành %HP hiện tại nếu cấp cách xa. Bộ nào là phù hợp cho đệ tử lệch hai track phải so bằng `effective_HP_tier` rõ ràng (candidate = max hai realm; **không đổi CombatStats**). Hồi +55 là pilot cố định, không nhân phẩm chất.
- Đan Luyện Thể tương lai: fixed Body XP, bỏ qua multiplier Căn Cốt giống các consumable cố định canonical; nguyên liệu thường cần map và tài nguyên dành cho luyện thể, không lấy toàn bộ chung với Tu Khí, tránh tranh cướp/độc quyền vật liệu.
- Không đặt lại CAP 100000, không thêm trần viên/ngày hoặc diminishing returns ẩn. Cân bằng **bằng chi phí vật liệu, thời gian thật, mức rủi ro, cơ hội nghề/người và hiệu quả theo realm**, không dùng nerf trá hình.
- Điều kiện mạnh mẽ: nhiều loại thuốc cùng chiếm Đan Bão Hòa theo `spent` saved/day; debit Warehouse + spent + HP/XP nhận + receipt là *một* giao dịch.

### Ma trận bản đồ — Linh Điền — thuốc

| Dải | Realm index | Linh Điền liên quan | Map / PvE | Đan dược |
|---:|---|---|---|---|
| 1 | 1–3 | Cây cơ bản Lv1; Tử Vân Thảo chỉ từ Lv30 | Ba map hiện có r1; vùng r2–3 PENDING | Hồi Xuân/Tụ Khí cơ bản; cấp r2–3 PENDING |
| 2 | 4–6 | Cây grade mới, slot/time/yield đã có Lv1–100 | map region IDs mới, 5 danger levels/map | cấp r4–6 |
| 3 | 7–9 | Nguyên liệu vùng + crop higher grade | map r7–9 | cấp r7–9 |
| 4 | 10–12 | linh dược mới có yêu cầu rõ; không tự sinh cây | map r10–12 | cấp r10–12 |
| 5 | 13–15 | logistics/catalyst farm khác nhau | map r13–15 | cấp r13–15 |
| 6 | 16–18 | chỉ có field Lv1–100; grade do explicit crop/content unlock | map r16–18 | cấp r16–18 |
| 7 | 19–21 | ngành nghề, nguyên liệu và tốc độ | map r19–21 | cấp r19–21 |
| 8 | 22–24 | sản lượng và rare materials | map r22–24 | cấp r22–24 |
| 9 | 25–27 | catalyst boss/rare; không ép Boss farm cho toàn bộ người chơi | map r25–27 | cấp r25–27 |
| 10 | 28–30 | Lv100 nhưng không Level101; mở nội dung qua resource/recipe | map r28–30 | cấp r28–30 |

**Cần phân biệt:** dải 10×3 là tổ chức data/content để giảm chi phí sản xuất; không thay đổi 30 tên cảnh giới/10 tầng của canonical. 5 mức khó per region vẫn giữ; cấp realm/monster làm trục nội dung khác với difficulty level. Đừng tạo 150 scene khác nhau nếu chỉ khác data hợp lệ; map vùng cao cấp có thể tái dùng nền phù hợp, spawn data/content thật và scaled Combat V2. Không sao chép từ Source A trong nhánh docs.

## 3. Linh Điền và kinh tế thực — tính toán công suất Lv1 (không bonus)

Lấy [SpiritCropRegistry](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/godot/src/simulation/building/spirit_crop_registry.gd) + [AlchemyRecipeRegistry](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/godot/src/simulation/building/alchemy_recipe_registry.gd) trên main, bỏ qua buff tốc độ/yield/rare, không gián đoạn và đủ worker/slot:
- 4 plot Lv1 chia **2 Thanh Linh Thảo + 2 Linh Cốc**: herb = `2×3/12=0.5/phút` = **720 herb / ngày 1440 phút**; grain = `2×5/10=1/phút` = **1440 grain/ngày**.
- Plant cost thuần = `2×4/12 + 2×3/10 = 1.2667 Linh Thạch/phút` ≈ **1824/ngày** khi duy trì bốn plot (chưa cộng milestone/speed/profession).
- Tụ Khí owner pilot cần 2 herb + 1 grain, 6 tick/viên. Theo flow trên nguyên liệu đủ `min(720/2,1440)=360 viên/ngày`, nhưng **một slot dây chuyền luyện đan không song song** cho tối đa `1440/6=240 viên/ngày` => **bottleneck là Alchemy job** trong fixture một slot. Số 240 là trần tính cho một *slot liên tục*, chưa xác nhận BuildingSystem phân bổ bao nhiêu slot hiện hành và mọi công trình/worker eligibility; không mô tả như công suất runtime đã nghiệm thu.
- Nếu cả 240 viên chỉ là Tụ Khí cơ bản: tối đa **2.4 triệu fixed Tu Vi/ngày** (chỉ với nguyên liệu + slot + thuốc thật) và dùng **6000/100000 bão hòa = 6% CAP** trên một nhân vật. Với Hồi Xuân, 240 viên cần **720 herbs/ngày**, tức toàn bộ herb được trồng ở fixture; khi cùng luyện cả hai, phải phân bổ tài nguyên và thời gian, tuyệt đối không cộng hai maximum như hoạt động đồng thời.
- Nếu không có thu Linh Thạch tương ứng, sản xuất dừng chứ không tự bù stock. Nếu nguyên liệu map cũng cấp herb, thử cả trường hợp dư/khan hiếm thay vì giả định bất biến.
- Lúc nâng Linh Điền: theo spec Lv1–100 **+0.5% speed và +0.5% yield/level**, có milestones cấp 10,20,30,50,75,100; một plot một timer và một người giữ slot đến harvest. Cải thiện throughput/cây có thật, **không** được nhân Tu Vi bằng một hệ số Linh Điền chỉ vì field level tăng.

### Design kinh tế unlock
- Không buộc 1 Linh Điền cụ thể làm ra đủ 30 cấp; late content cho phép nhiều field instances với crop/resource ID riêng, nghề cao, field milestones và map catalyst, nhưng vẫn không cấp lại một CropRegistry giả.
- Đặt mỗi recipe bên cạnh `ingredient_source_ids`, `field_level_required`, `profession_level_required`, `realm_grade`, `time_ticks`, `material_units`, `Warehouse_reserved_quantity`, `XP_or_HP_value`, `receipt_id`. Chỉ khóa khi có bằng chứng năng suất nguồn cấp.
- Đảm bảo ít nhất 2 đường lấy nguyên liệu hợp lệ cho thuốc cốt lõi: farm map và trồng cây/crafting, tùy cấp. Không để Boss độc chiếm tài nguyên hồi máu thiết yếu.
- Đánh giá 100, 1000, 3000 disciple demand: **supply_per_day** vs **demand_per_day** theo tỷ lệ người chọn thuốc, job occupancy, số field/alchemy slots và budget Linh Thạch; không nhân bản tài nguyên khi tăng số đệ tử.
- Hạng mục kinh tế không áp dụng lời khuyên generic bán premium currency/monetization; TMB là game cá nhân, không thương mại.

## 4. Đề xuất mục tiêu thời lượng 300 tầng (KHÔNG OWNER-LOCKED)

### Chọn một frontier nhanh để kiểm tra tính khả thi, không ép người chơi theo lịch này

Dùng 30 giá trị canonical `REALM_TOTAL_XP[r]`. Giả định **chỉ** để stress-test hệ thống tương lai:
- `T_tuvi(r) = 180 × 1.14^(r−1)` simulation minutes để hoàn thành 10 tầng của 1 realm **nếu farm hiệu quả gần liên tục**, chưa tính chi phí đột phá, injury, xây dựng, backlog, vật phẩm, thời gian offline không chơi.
- `T_body(r) = 1.35×T_tuvi(r)` minutes cho cùng cost đường Luyện Thể. **Hai track có thể tiến triển song song** từ các nguồn thật; không cộng máy móc hai T để tính tổng đời nhân vật.
- `Required Tu Vi/min(r) = REALM_TOTAL_XP[r]/T_tuvi(r)`, `Required Body XP/min(r) = REALM_TOTAL_XP[r]/T_body(r)`. Đây là **yêu cầu nội dung** cho map/thuốc/công trình sau này, **không** phải nguồn đang có, không phải hứa hẹn chơi hết game trong 45 ngày.
- Tổng lý thuyết `sum_r T_tuvi(r) ≈ 44.60 ngày 1440 phút` nếu farm liên tục 100% và vượt mọi major gate ngay. Trong thực tế sẽ lâu hơn; không thể coi là ngày chơi thực tế của người chơi. Có thể đổi 180 hoặc 1.14 sau khi owner duyệt kỳ vọng pacing/fixture.

| Realm | Tu Vi realm | XP canonical/realm | T_target (sim min) | Required Tu Vi/min | T_body (sim min) |
|---:|---|---:|---:|---:|---:|
| 1 | Phàm Nhân | 10,000,000 | 180 | 55,556 | 243 |
| 5 | Kim Đan | 26,000,000 | 304 | 85,523 | 410 |
| 10 | Đại Thừa | 86,000,000 | 585 | 146,920 | 790 |
| 15 | Huyền Tiên | 284,000,000 | 1,127 | 251,987 | 1,522 |
| 20 | Tiên Đế | 938,200,000 | 2,170 | 432,345 | 2,930 |
| 25 | Thần Vương | 3,099,500,000 | 4,178 | 741,827 | 5,641 |
| 30 | Sáng Thế Chủ | 10,240,200,000 | 8,045 | 1,272,903 | 10,860 |

Đính kèm CSV 30 hàng: `docs/design/TMB_300_REALM_PACE_SCENARIOS_2026-10-22.csv`, với cột đầy đủ tên Tu Vi/Luyện Thể, XP, tốc độ mục tiêu, dự kiến pill fixed, dải content và field-level example; mọi cột ngoài XP/names đều `SIMULATION_ONLY`.

### Kiểm toán giá trị thực của 2 starter pills

- Hồi Xuân +55 với `HP = (100×1.65^(tuvi_r-1)×1.03^(tuvi_floor-1) + 90×1.65^(body_r-1)×1.03^(body_floor-1)) × (1 + Tiềm_Lực×0.0005)` trước equipment: ở r1f1/body1f1, Tiềm Lực185 => HP207.575, thuốc hồi **26.50% max HP**; lên r5/body1 chỉ ~6.06%, r10/body1 ~0.55%, r20/body1 ~0.00371%, r30/body1 ~0.0000248%. Hồi Xuân là starter, không thể đặt nó làm thuốc duy nhất tới tận r30.
- Tụ Khí +10000 / XP floor1 của r1 = 10000/700000 = **1.4286%**; r5 ~0.5495%; r10 ~0.1661%; r20 ~0.01523%; r30 ~0.001395%. Fixed Tu Vi không nhận Tư Chất xN.
- Trial-grade fixed XP `0.1%×realm_total` đủ bám mức 1.4286% floor1 cho mọi realm, nhưng để tránh sập kinh tế phải kiểm tra vật liệu hiếm/thời gian/slot/loot, không đưa ngay vào registry; giá trị từ r30 ≈ 10.24 triệu/viên trước cân bằng nguyên liệu.
- Khi nội dung thực chưa có, hiển thị "PENDING CONTENT" thay vì chế 30 map/đan/thuốc.

## 5. Monte Carlo — stress-test pacing, không phải chứng nhận cân bằng

**Thuật toán thiết kế**, seed cố định, 1000 lần chạy độc lập / điểm / scenario, mỗi iteration xét block 10 simulation minutes; không chạy Godot/CARE. Tổng XP được xét liên tục trong 1 realm, **không** mô phỏng 10 floor/gate/overflow hay crafting; các con số dưới đây chỉ chứng minh rủi ro theo uptime/map success. Đây **không phải** chứng cứ playable.

- Frontier expected `R_r` trong mục 4 là tốc độ mục tiêu của một phiên farm thành công điển hình.
- Khi **active**: +XP ambient mỗi phút tương đương `0.75×R_r` (tính **bao gồm** nguồn natural, không double grant); thắng một encounter mỗi 10 phút cho +`0.25×R_r×10/0.85` fixed XP nếu triển khai settlement riêng về sau. `p_win=0.85` là anchor, **không** phải tỷ lệ combat đã đo.
- Khi **inactive**: +1150 natural XP/phút (giả định Tư Chất60 và không chuyên tâm, 1000×(1+60×0.0025)), không có farm bonus. Chọn active/inactive từng block theo `map_uptime_probability`, thắng/rớt theo `p_win`.
- Scenarios: ideal `u=1,p=.85`; practical `u=.75,p=.85`; highrisk `u=.60,p=.70`. Không mô phỏng Injury120, chi phí y tế, thời gian công trình, job conflicts, map travel, floor10 gate, auto-breakthrough, resource shortfall, rng combat thật. **Chúng sẽ làm thời lượng thực tăng thêm.**
- PRNG deterministic Mulberry32, mỗi cặp realm/scenario seed `0xB3202610 + realm×97 + length(scenario_name)×13`; kết thúc khi XP ≥ realm_total, đếm tròn block 10 min; P50 = phần tử thứ 500/1000, P90 = thứ 900/1000 sau sort. Đây là code mô phỏng ngoài Godot, không sửa game.

| Realm | Scenario (u / p_win) | P50 sim min | P90 sim min | Frontier sim min |
|---:|---|---:|---:|---:|
| 1 | ideal (1.00 / .85) | 190 | 190 | 180 |
| 1 | practical (.75 / .85) | 240 | 280 | 180 |
| 1 | highrisk (.60 / .70) | 310 | 370 | 180 |
| 10 | ideal | 590 | 600 | 585 |
| 10 | practical | 790 | 850 | 585 |
| 10 | highrisk | 1020 | 1140 | 585 |
| 20 | ideal | 2170 | 2200 | 2170 |
| 20 | practical | 2900 | 3030 | 2170 |
| 20 | highrisk | 3780 | 4000 | 2170 |
| 30 | ideal | 8050 | 8090 | 8045 |
| 30 | practical | 10710 | 10980 | 8045 |
| 30 | highrisk | 14040 | 14450 | 8045 |

**Giải thích:** số rất nhạy với uptime và độ khó, nên dùng chính sách rút lui, lựa chọn map, thuốc hồi phục và phân công hậu cần để giảm downtime có giá trị lớn hơn việc chỉnh Tu Vi bằng tay. Nhưng bảng này **không cho phép** kết luận map mới đã có, khả năng win thật đạt 85%, hoặc completion ~45 ngày thực.

### Cần thêm fixtures mới có thể khóa balance

1. 5–10 cấp đầu, mid r10/r20, end r30; trường hợp Tu Vi mạnh hơn Luyện Thể 5 realm và ngược lại.
2. Tư Chất/Căn Cốt ở 60/500/2500/10000; kiểm tra same-channel additive, fixed XP unaffected.
3. Uptime farm 30/60/90%, win p 50/75/90%, defeat→HP1/Injury120, retreat policy và death-no-loot.
4. 1, 100, 1000, 3000 disciple economy; plots/alchemy/ren-than slots; stone budget; impact field Lv1/30/75/100; real material source rates.
5. 10-floor weighted costs; boundary floor9→10, full floor10 gate, failed major cultivation breakthrough, large fixed pill overflows; no fabricated bank/tích tụ.
6. B3 settle-once; farm/map XP must not be granted on mob HP0; loot direct canonical warehouse; per-person Tu Vi participation and boss coop remains separately gated.

## 6. Kiến trúc data cho CODE packet **SAU NÀY**, không CODE hôm nay

- `RegionContent`: `region_id`, `map_asset_manifest_id`, `realm_band`, `monster_realm/floor`, `difficulty_level(1..5)`, `loot_resource_ids`, `encounter_reward_policy_id`, `travel_time/risk`, `unlocked_by`. IDs unique. Đồ họa map chỉ đọc data đã phê duyệt.
- `CultivationGainSource`: một owning `SimulationScheduler` tick, `disciple_id`, `world_id`, `tick`, `source_kind`, `applied_bonus` và read-only preview. Không ghi 2 grants natural/tick khi map buff có hiệu lực.
- `EncounterRewardReceipt`: `encounter_id`, `world_id`, `terminal_outcome`, `participant_ids`, `grant_by_disciple`, `settled_at_tick`, `save_version`. Không last hit, không pre-settle XP. Cần thiết kế/B3 test riêng để được phép thêm.
- `CropDefinition` giữ nguyên 3 ID hiện có; map tier/field milestone giải khóa **cây mới riêng**. Field Lv100 cap giữ nguyên, don't imply Lv101. Map drop catalyst không tạo crop bằng tên code chưa registered.
- `PillDefinition`: `pill_id`, `family`, `effective_realm_band`, `fixed_xp/fixed_hp`, `satiety_cost`, `recipe_id`, `materials`, `required_hall_level/worker`, `one_transaction_receipt`. Không thêm daily-count caps/hidden yield penalty.
- `BodyXpSource`: chỉ one natural source per tick, fixed reward distinct, no fake ability to train while field plot worker is reserved.
- `SAVE`: clear contracts for claim atomicity, backward-compatible migration; never replace current 100000 daily cap with old 100; no silent retroactive resets.

## 7. Quyết định dành cho owner và thứ tự hành động

**Không cần chủ game phải tự chọn 90 chỉ số thuốc ngay bây giờ.** Đề xuất:
1. Ưu tiên **CARE Codex QA**: đủ thuốc/hồi phục/return same world, CAP100000, save exactly-once; **KHÔNG can thiệp session đó**.
2. Khi CARE PASS, chốt mục tiêu time-to-realm, farm-vs-work-vs-focused split, và 3 map tier mẫu (r1/r5/r10) bằng fixture nguồn thực. Tuning các vùng cao 11–30 dựa trên kết quả chứ không nhập hằng số võ đoán.
3. Thiết kế **1 vertical slice r2–r3** (một higher-grade ingredient, một thuốc Tu Vi cao hơn, một map reward authority, một Body material path) riêng, READ-ONLY packet trước khi xin CODE.
4. Sau owner approval mới mở CODE packet độc lập, cho phép sửa canonical files với allowlist/test/save migration. Ưu tiên 30-level data-driven template + 10 content bands, không 30 bộ engine/copy-paste.
5. Future Boss nhiều đội/loot chia sect-personal phải theo hợp đồng riêng chưa khóa DPS/tank/heal/support threshold 60/40; skill document **không** mở quyền.

### Câu lệnh gợi ý lần tiếp theo
```text
TÔNG MÔN BÁ ĐẠO — Dùng docs/design/TMB_300_REALM_MAP_FIELD_PILL_BALANCE_LAB_2026-10-22.md trên docs/tmb-agent-skills-20261022 làm giả thiết nghiên cứu. Trên dữ liệu main/B3 thực, lập 3 fixture r1/r5/r10 có Tu Vi, Luyện Thể, map farm, sản lượng Linh Điền, nguyên liệu đan; kiểm tra hiệu suất, overflow, tích hợp nghỉ hồi phục và Boss reward. Chỉ DESIGN + số liệu, không CODE, không merge, không can thiệp CARE-FASTTRACK.
```
