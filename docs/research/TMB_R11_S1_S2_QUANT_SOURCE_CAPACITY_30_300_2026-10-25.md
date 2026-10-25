# TÔNG MÔN BÁ ĐẠO — R11 S1/S2: CÔNG SUẤT NGUỒN VẬT LIỆU & QUY MÔ 30–300 ĐỆ TỬ
## Mô hình tính có thể kiểm tra; SOURCE ≠ ASSUMPTION ≠ GAMEPLAY PASS

> **World combat R11 chính là CONTINUOUS, KHÔNG giới hạn 90 giây.** `MAX_SECONDS=90` trong `main` chỉ là finite legacy mode; code PR #31 đã bypass giới hạn đó khi `continuous_mode=true`, có test same-world 120s và real per-life loot/save. R11 vật liệu vẫn chưa code. Model hunter ở đây dùng genuine kills/world respawn, tuyệt đối không dùng encounter-wave reward. Xem `TMB_COMBAT_CONTINUOUS_VS_LEGACY_90S_DEPRECATION_AUDIT_2026-10-25.md`.


**2026-10-25 — RESEARCH / DOCS ONLY. KHÔNG CODE, GODOT QA, MERGE, SỬA UI, MAP, COMBAT V2, SOURCE A, PR ĐANG MỞ.**
**Branch base**: R11 previous docs HEAD 4c3e7ba5df058eb4250e14e02db6b13f6e2a8618; upstream main inspected at 29b5fba448b0178cb520a4ada44b375b4b934e31.
**Tham chiếu trực tiếp**: AGENTS.md; docs/GAME_SYSTEM_ARCHITECTURE.md; docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md; docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md; docs/REALM_LADDER_V2_SPEC.md; main godot/src/simulation/{building/building_system.gd,workforce/workforce_system.gd,resource/warehouse_system.gd,core/simulation_runtime_clock_v2.gd,combat/{hunting_map_v2.gd,monster_catalogue_v2.gd,map_battle_v2.gd}}. Kế thừa 3 hồ sơ R11 S1/S2 trong nhánh parent. Đây không phải nội dung đang chạy trong game.

## 1. Phân biệt số liệu thực và giả định
| Phân loại | Bằng chứng / ý nghĩa |
|---|---|
| [SOURCE/CODE] | SimulationRuntimeClockV2: 60 giây thực = 1 phút mô phỏng = 1 scheduler step khi 1×. Chỉ quy đổi giờ mô phỏng: 60 tick/giờ, 1.440 tick/ngày, 10.080 tick/7 ngày, 43.200 tick/30 ngày. Tốc độ khác hoặc offline phải đi qua canonical clock. |
| [SOURCE/CODE] | BuildingSystem mine tạo thanh_thiet, linh_forest tạo linh_moc; không có R11 node thế giới. Workforce One Active Job; tài nguyên không được tạo từ renderer. |
| [SOURCE/CODE] | WarehouseSystem.MAX_SAFE_STACK = 9.000.000.000.000.000 (giới hạn số nguyên), không phải giới hạn sức chứa gameplay; không được thêm cơ chế Kho đầy bình thường. Nếu gần tràn số nguyên thì fail-closed giữ pending receipt. |
| [SOURCE/CODE] | MonsterCatalogueV2 không có Vân Giác Lộc; HuntingMapV2 trả theo encounter; không có per-life R11 reward. |
| [DESIGN TRIAL] | Nghiên cứu một catalog R11: 1 Tiên Thiết + 1 Lộc Bì; một vũ khí: 3 Tiên Thiết + 2 Vân Mộc + 1 Lộc Bì + 22 Linh Thạch + 12 Forge tick chưa khóa. S1/S2 không thực thi consumer. |
| [DESIGN TRIAL] | Bộ 10 slot R11: 15 quặng + 21 mộc + 4 bì / đệ tử, thêm 1 quặng + 1 bì cho lần nghiên cứu đầu tiên (rút ra đúng từ tổng prior 30/100/300 kits). Đây là gross model, KHÔNG phải recipe được đăng ký. |
| [ASSUMPTION] | Tất cả số node, worker, respawn, drop, xác suất thắng, thông lượng, uptime và giờ cấp R11 ở dưới là INPUT MÔ HÌNH, chưa owner-locked. Không lấy sản lượng Thanh Thiết/Linh Mộc cấp thấp làm Tiên Thiết/Vân Mộc. |

## 2. Phương trình lưu lượng / thời gian
Đơn vị: tick = phút mô phỏng ở 1×; chỉ chi khi đã hoàn tất haul/death receipt. Tải có nhiều người dùng chung nguồn, không nhân thưởng theo số người.

**Node vật lý loại x**:
- N = số node persistent; y = vật liệu/receipt; w = số worker được phép; a = thời gian công việc + đi/haul/deposit (tick/receipt); r = cooldown từ lần settle trước đến thế hệ tiếp (tick); u = tỷ lệ công suất thực hữu hiệu, 0..1.
- Khả năng dài hạn x/giờ ≈ u × min[N × y × 60/(a+r), w × y × 60/a]. Số thứ hai chặn khả năng worker, số thứ nhất chặn nguồn; giới hạn một đời node, một receipt. Đây là **rate envelope**, không phải bộ lập lịch/work simulation có path.
- Uptime đã gộp nghỉ, di chuyển phát sinh, gián đoạn, thiếu nhân lực; KHÔNG được nhân thêm phần đó lần hai. Nếu r=0 vẫn phải có một job/receipt thật.

**Vân Giác Lộc**:
- n = slot life; c = thời gian tối thiểu tìm/đánh một encounter theo tick mô phỏng (khác với giây arena MapBattleV2), r = cooldown sau một đời chết đã kết toán; s = số tổ đội 6 người; p = hệ số giả định chiến thắng hợp lệ trên cơ hội; u = hiệu dụng trực thực tế; q = tỷ lệ nhận vật liệu cơ bản trên một death đủ điều kiện.
- Tốc độ lên kế hoạch bì/giờ ≈ min[n×60/(c+r), s×60/c] × p × u × q.
- Đây là **planning envelope**, chưa phải stochastic world simulator: thất bại có thể làm quái giữ HP/trạng thái và kéo dài life, nên tỷ lệ thực phải thấp hơn nếu không thỏa điều kiện; p không được lén biến thành luật Combat V2. Quái offscreen không tự chết. Không có kill → không có receipt → zero output.

## 3. Ba cấu hình giả định độ nhạy (không phê duyệt cân bằng)
| Parameter | KHAN HIẾM (stress) | CÂN BẰNG (reference trial) | DỒI DÀO (upper stress) |
|---|---:|---:|---:|
| Quặng N, y, a, r, workers, u | 2; 1; 24; 96; 1; 0,75 | 4; 2; 20; 40; 2; 0,85 | 8; 3; 15; 30; 4; 0,90 |
| Mộc N, y, a, r, workers, u | 2; 2; 30; 90; 1; 0,75 | 4; 3; 24; 66; 2; 0,85 | 8; 4; 20; 40; 4; 0,90 |
| Lộc: slots, c, r, squads, p, u, q | 1; 12; 60; 1; 0,65; 0,65; 0,50 | 3; 10; 30; 1; 0,80; 0,80; 1,00 | 8; 7; 15; 2; 0,90; 0,90; 1,00 |
| Tiên Thiết/giờ | **0,75** | **6,80** | **28,80** |
| Vân Mộc/giờ | **1,50** | **6,80** | **28,80** |
| Lộc Bì/giờ | **0,176** | **2,88** | **13,886** |

Chú ý: Cấu hình scarce là kiểm tra thất bại, không khuyến nghị. Các slot hunter là tối đa hoàn thành một đời quái; thêm tổ đội không biến một xác quái thành nhiều rơi đồ. Nhiều đệ tử/worker hơn KHÔNG tăng công suất khi bottleneck là số node/camp. Uptime ở đây là assumption nhạy cảm nhất, không phải đo runtime.

## 4. Nguồn cung nếu chạy đủ tick theo envelope, CHƯA TRỪ NGUYÊN LIỆU TIÊU
| Cấu hình | 7 ngày — Ore / Fiber / Beast | 30 ngày — Ore / Fiber / Beast |
|---|---|---|
| Khan hiếm | 126 / 252 / 29,6 | 540 / 1.080 / 126,8 |
| Cân bằng | 1.142,4 / 1.142,4 / 483,8 | 4.896 / 4.896 / 2.073,6 |
| Dồi dào | 4.838,4 / 4.838,4 / 2.332,8 | 20.736 / 20.736 / 9.997,7 |

Số thập phân là giá trị **kỳ vọng lưu lượng**, không phải cộng mảnh vật phẩm vào Kho. Receipt phải ghi số nguyên; model hiện bỏ qua lượng dư chu kỳ tại ranh giới, thời gian cấp phép nhà xưởng và tác động lịch online/offline thực.

## 5. Nhu cầu phát triển 30 / 100 / 300 đệ tử (STRESS: mọi người đều nhận đủ 10 món)
**Tổng khối lượng thử**: Ore = 15×N+1; Fiber = 21×N; Beast = 4×N+1. Không áp dụng cho việc chỉ trang bị 1 vũ khí; không buộc mọi đệ tử trang bị R11 khi còn R10. Cần thêm tiến độ rèn, Linh Thạch và nghiên cứu chưa được tính.

| Số bộ 10 món | Ore | Fiber | Beast | Thời gian tối thiểu envelope khan hiếm | Cân bằng | Dồi dào |
|---:|---:|---:|---:|---:|---:|---:|
| 30 | 451 | 630 | 121 | 687,3 giờ / 28,6 ngày (Bì) | **92,6 giờ / 3,9 ngày (Mộc)** | 21,9 giờ (Mộc) |
| 100 | 1.501 | 2.100 | 401 | 2.277,9 giờ / 94,9 ngày (Bì) | **308,8 giờ / 12,9 ngày (Mộc)** | 72,9 giờ (Mộc) |
| 300 | 4.501 | 6.300 | 1.201 | 6.822,2 giờ / 284,3 ngày (Bì) | **926,5 giờ / 38,6 ngày (Mộc)** | 218,8 giờ / 9,1 ngày (Mộc) |

Cách tính: T(N) = max(ore_demand/ore_rate, fiber_demand/fiber_rate, beast_demand/beast_rate). Đây là **cận dưới lưu lượng dài hạn** khi ba nguồn vận hành song song liên tục và đã có sẵn đủ công nhân/đường đi. Không phải ETA gameplay: với lô nhỏ, tối thiểu vẫn phải đợi các job đầu (cân bằng: quặng ≥20 tick, mộc ≥24 tick, kill cần combat thật); rate/giờ không tự cho vật phẩm trước khi có receipt.

**Nhu cầu cấp toàn bộ bộ kit trong 7 ngày**:
- 30 người: Ore ≥2,68/h, Fiber ≥3,75/h, Beast ≥0,72/h → reference trial đủ lưu lượng trước khi tính forging.
- 100 người: Ore ≥8,93/h, Fiber ≥12,50/h, Beast ≥2,39/h → reference trial thiếu quặng/mộc.
- 300 người: Ore ≥26,79/h, Fiber ≥37,50/h, Beast ≥7,15/h → reference trial thiếu ba dòng, không giải bằng thêm worker một cách mù quáng.

**Trong 30 ngày**: với 300 kit cần Ore ≥6,25/h, Fiber ≥8,75/h, Beast ≥1,67/h. Cấu hình 4 node mộc chỉ cho 6,80/h → **thiếu 1,95/h**. Nếu giữ y=3, a=24, r=66, u=.85 và 2 worker forestry, tăng từ 4 lên **6 node mộc** đưa envelope từ 6,8 lên 10,2/h (worker cap sau uptime 12,75/h), đủ riêng hạn mức vật liệu 300 kit/30 ngày, CHƯA khẳng định forging và người R10 sống sót có thể hoàn thành.

## 6. Ràng buộc nhân sự: 30–300 đệ tử không đồng nghĩa 30–300 producer
| Roster | Phân bổ thử miners / forestry / hunters | Tổ đội hunter 6 người | Remainder chưa gán job loại này |
|---:|---|---:|---:|
| 30 | 2 / 2 / 6 | 1 | 20 |
| 100 | 5 / 5 / 24 | 4 | 66 |
| 300 | 12 / 12 / 60 | 10 | 216 |

- Đây là **phân bổ stress**, không phải workforce hiện đã có. Số người ở khu nguồn chỉ là subset, phần còn lại dành cho tu luyện, hậu cần, luyện đan, sản xuất, trị thương; One Active Job bảo toàn.
- Trong reference 4/4/3-node/camp, ngay ở roster30 worker node-cap đã bão hòa; 100/300 không được cộng thêm thẳng theo tỉ lệ số người. Nhiều squad đánh một con vật vẫn một death owner, không tăng hide theo số đội.
- Sau khi nhận 300 kit, tiêu hao định kỳ có thể khác hoàn toàn gross first-fill: nếu chỉ 10% roster300 cần thay bộ trong 7 ngày → 30 kit/tuần, cần 3,75 mộc/giờ, reference đủ về mộc; nếu 20% → 60 kit/tuần, cần 7,50 mộc/giờ, reference thiếu.
- Giới hạn thực còn là Forge queue, blueprint, Linh Thạch và nghề, hiện S3/S4 chưa tồn tại. Không dùng MAX_SAFE_STACK để thiết kế Kho có sức chứa ảo.

## 7. Không tạo lạm phát/softlock bằng cân bằng giả
1. **Bootstrap**: trước Tiên Thiết đầu tiên, người chơi R10 phải path đến node, thu và nhận thật. Không yêu cầu weapon R11/blueprint R11/Elite/Boss.
2. **Scarcity có thể làm chậm, không cắt đường**: 1 đời node/camp phải respawn/settle đúng sau cooldown và có đường rút lui. Nếu tất cả chết/injured, recovery120 tick và tuyển/thay người là cổng fallback, không phát thưởng miễn phí.
3. **NO DROP**: nếu q<1 thì death không rơi cũng bắt buộc ghi receipt tránh reload-reroll; q=1 cho common R11 là **đề xuất prototype**, không nhân 100% rare equipment.
4. **Chống arbitrage**: market price, trade, disassemble, resale chưa được xác định; tuyệt đối chưa kết luận lời/lỗ, không cho low-tier vô hạn đổi thành R11 bằng nhãn mới.
5. **Node OFFSCREEN**: renderer không quyết định harvest/die/respawn; 7/30d offline phải chạy cùng event canonical, không nhảy 10 respawn rồi cấp 10 nguồn khi chưa có worker/kill.
6. **Bảo vệ phần thưởng**: từng NodeHarvestKey / ActorLifeKey frozen payload; Warehouse credit+source receipt+node/life status được kết toán logic một lần. Legacy encounter reward không trùng entitlement World per-life.
7. **Stress scaling**: 30/100/300 simulated agents không đòi spawn 300 sprite Android; batch nền giữ cùng chính sách công việc & tick. Android FPS/memory vẫn PENDING USER.

## 8. Decision gates / hạn chế
- [D] Quy mô node vật lý, cự ly path, tốc độ đi/haul, worker slots, lượng yield, cooldown, respawn clock, return/recovery và số camp chưa khóa.
- [D] Combat win factor p và effective uptime u chưa đo, không được in như kết quả Godot. Test q=1 vẫn không chứng minh có thể thắng một con vật.
- [D] S3/S4 consumer/Forge throughput/costs 10-slot kit chưa được triển khai, do vậy bảng chỉ là **sizing pressure**, không phải dự báo số lượng R11 có thể mặc.
- [D] Chỉ qua Gate khi có actual simulation-state receipt & batch-mode equality tests, fixture 7/30d, 30–300 work assignments, source ID registry, navmesh, Combat V2 và save/reload.
- **OWNER RECOMMENDATION, NOT APPROVED**: dùng reference 4 ore + 4 fiber nodes + 3 normal deer slots để triển khai fixture S1/S2 sau khi được phép code; không khóa rate. Để hỗ trợ 300 kit/30d có thể thử 6 fiber nodes nhưng chưa cấp giấy phép world authoring.

**Verdict**: quantitative **DESIGN MODEL PRODUCED**; S1/S2 GAMEPLAY **BLOCKED / NOT RUN**. Đọc companion Combat và Softlock long-horizon docs trước khi duyệt.
