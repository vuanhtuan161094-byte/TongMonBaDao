# TÔNG MÔN BÁ ĐẠO — SO SÁNH 3 HỆ TU VI SĂN QUÁI / 300 TẦNG / OFFLINE BENCHMARK

**Ngày:** 23/10/2026. **Loại:** SOURCE AUDIT + DESKTOP STOCHASTIC/ANALYTIC BENCHMARK + DESIGN ONLY. **NO GAME CODE, NO GODOT EXECUTION, NO MERGE.**
**GitHub baseline lúc khảo sát:** main 29b5fba448b0178cb520a4ada44b375b4b934e31; branch độc lập docs/b3-tuviflow-threepath-benchmark-20261023. CARE Codex local handoff 35ffa85fd45da42e43722e7ac74b7423602d4491 báo 15/15 focused PASS, **không suy diễn đã merge**. PR #23 đã đưa sáu repo skills vào main, không thay đổi gameplay.
**Skills áp dụng:** tmb-project-director + tmb-balance-lab (đã đọc từ plugin cá nhân).
**Mục tiêu:** 3 phương án DIRECT / ESSENCE / 80:20 HYBRID, cohorts 1/3/6, Normal/Elite/Boss, online/offline, 30 realms × 10 floors, một nguồn reward và không trùng Tu Vi.

## 0. Kết luận thực dụng và trạng thái quyền

**Khuyến nghị về game feel:** **Direct fixed Tu Vi trên real kill cho từng đệ tử đủ điều kiện + Tinh Nguyên HIẾM làm nguyên liệu cấp cao (KHÔNG dùng làm nguồn EXP farm bắt buộc)**. Đây là lựa chọn có nhiều lợi ích của hybrid về kinh tế nhưng về TU VI vẫn là DIRECT; không cần đệ tử đem EXP về nhà, không tạo hàng chờ ẩn. Quái thường là nhịp lên cấp, Elite/Boss có điểm nhấn vật phẩm và cơ hội, không nên là nguồn EXP đều đặn duy nhất. Healer/Tank/Support được xét đóng góp thực tế. **Tuy nhiên chỉ là RECOMMENDATION; chưa phải gameplay LOCK/CODE.**

**CONFLICT CẦN OWNER APPROVAL/RECONCILE:** canonical docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md §2.2 (USER LOCK ngày 09/10) cấm EXP trực tiếp tại HP0, cho phép Tinh Nguyên hấp thu sau. B3_DIRECT_KILL_TUVI_RECOMMENDED_GAMEPLAY_2026-10-23.md ở nhánh thiết kế đề xuất thay luật nhưng chưa sửa canonical. Nếu owner chốt direct/extended hybrid, phải cập nhật canonical doc có owner approval **trước khi cấp phép CODE khác**. Tài liệu này không cấp phép tự đổi luồng Combat V2.

## 1. SOURCE FACTS — KHÔNG SUY ĐOÁN

- Source main godot/src/simulation/cultivation/disciple_progression_balance_v2.gd: **30×10 TU VI + 30×10 BODY**, cùng bảng giá, mỗi track tổng **48,130,600,000 XP**. Realm r1=10,000,000; r30=10,240,200,000. W floor thứ tự = 7/7.5/8/8.5/9/10/11/12/13/14%, floors1–9 round nearest10, floor10 lấy số dư. **Natural** 1,000 XP/phút; Chuyên Tu ×2 trên chính natural grant (không thêm tick).
- Source godot/src/simulation/cultivation/disciple_realm_progress_v2.gd: gain_type natural áp Tư Chất; fixed không áp; grant_xp có thể vượt nhiều **tầng nhỏ** trong cùng realm; **tầng 10 chặn major gate**, dư hiện trả unapplied_overflow, không tự lưu. Breakthrough có RNG/gate, thất bại mất XP theo contract khác; không bỏ qua trong triển khai thật.
- Owner định hướng: 1 thế giới săn liên tục, không reset wave/90s; 1 monster instance/HP/kill receipt, loot tài sản Sect, Tu Vi cá nhân có bằng chứng; One Active Job; Injury 0/1/120 simulation ticks; B3 thuốc Hồi Xuân 10/+55HP, Tụ Khí 25/+10,000 fixed Tu Vi, satiety **1,000,000/đệ tử/ngày** theo floor(tick/1440). **CAP thuốc không phải CAP Tu Vi săn**. Luyện Thể giữ nguồn XP riêng.
- P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md: săn phù hợp ~10–20× lao động thường là **design target**; 0.5–1% tầng/giờ khi farm khỏe cũng là **starting design target**. Hai chỉ tiêu hiện KHÔNG cùng áp dụng được trên cả 300 tầng khi natural 1000/min không scale theo realm.
- Main chưa có một dòng B3 production reward direct-kill XP và không xác minh hệ Tinh Nguyên hấp thu đầy đủ. Không biến tài liệu B3 cũ hay bản Monte Carlo này thành CODED status.

## 2. Ba lựa chọn được định nghĩa CÔNG BẰNG

| Phương án | EXP nhận ngay lúc HP0 | EXP nhận sau ở Sect | Vật phẩm, quyền sở hữu | Cần lưu thêm / rủi ro |
| --- | --- | --- | --- | --- |
| D — DIRECT | 100% fixed hunt reward cho nhân vật đủ điều kiện | Không | nguyên liệu/gear đưa về 1 Sect Kho | real death + per-actor XP receipts; ít trạng thái nhất |
| E — ESSENCE ONLY | 0% | Token Tinh Nguyên -> Sect Kho -> người hợp lệ hấp thu mới cộng fixed XP | dùng Kho Sect, không nhân đôi XP khi hút | drop RNG, allocation, queue/claim, vật phẩm tồn kho, day/offline, EXP dồn và gate |
| H — SPLIT HYBRID | 80% nominal reward fixed | 20% **kỳ vọng** thông qua token, không phải thêm 20% bonus | token + loot Sect; phải chuyển đúng policy | cả hai ledger, nhiều trạng thái, offline reconciliation |
| H2 — HYBRID HỆ SINH THÁI **KHUYẾN NGHỊ** | 100% DIRECT fixed EXP | **0% XP bắt buộc** | Tinh Nguyên hiếm chỉ craft/phá cảnh/đan sau này nếu được duyệt | phần EXP đơn giản như D, vật phẩm hiếm tăng chiều sâu |

**Không bao giờ** cấp một lần EXP từ kill rồi lại cấp đủ EXP đó từ token; các phương án D/E/H được chuẩn hóa sao cho expected total hunt EXP bằng nhau khi tất cả token được hấp thu. H2 chỉ là D cộng khả năng drop hiếm thuộc economy, **không cộng XP lần nữa**.

**Role protection đề xuất:** mỗi người có useful causal action từ Combat V2 (actual damage, absorbed/guarded damage thực, effective heal, useful buff/debuff/control) mới eligible; không chia pool bằng 1/N theo DPS/last-hit, không free EXP cho đứng nhìn, và numeric thresholds vẫn OPEN. Boss nhiều đội chỉ 1 HP/1 loot/1 death, personal XP mỗi eligible riêng; Sect/personal Stone share 60/40 chưa khóa.

## 3. Benchmark fixtures — mọi số dưới đây là ASSUMPTION, KHÔNG PHẢI tốc độ game thực

### 3.1 Cohort and kill generation

Mô phỏng **một đệ tử đại diện** trong nhóm 1/3/6, cửa sổ 6 GIỜ simulation, **không cộng nhân nhóm lần hai**. Quái bình thường/Tinh Anh/Boss có rate dạng **TEAM encounters per active sim-hour**, uptime và tỷ lệ eligibility của nhân vật để tránh reward spectator. Uptime gộp giả định supply/retreat/Injury downtime, **không phải đo Injury120 từ Godot**:

| Đội | Normal/active hour | Elite/active hour | Boss/active hour | Uptime | Khả năng thực sự eligible của 1 actor |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 | 9 | 0.25 | 0.020 | 72% | 100% |
| 3 | 16 | 0.65 | 0.055 | 82% | 90% |
| 6 | 21 | 1.05 | 0.090 | 88% | 82% |

Effective eligible events/hour = TEAM events/hour × uptime × eligibility. Per-event reward anchored to **XP của tầng đang xét** C(r,f): NORMAL = 0.008×C, ELITE = 4×NORMAL, BOSS = 15×NORMAL. Đây là chuẩn hóa để so **tương quan phương án** chứ không phải loot/EXP cuối cùng. Khi gói Tinh Nguyên chuyển tiền về Sect mà có thể phân phối khác người săn, giả định bảo lưu credit cho đúng actor là **optimistic E/H bound**, không phải hiện trạng gameplay.

**Pacing 6h theo grade.** Mỗi ô % là **gross hunt XP tương đương % của một tầng tham chiếu**, KHÔNG tự áp vào thanh tầng thật hoặc vượt tầng10. Boss zero probability tính Poisson độc lập, chưa có spawn-cap/season constraints:

| Team | Normal kills eligible /6h | Elite /6h | Boss /6h | Normal XP frac | Elite XP frac | Boss XP frac | P(không gặp Boss /6h) |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 38.88 | 1.08 | 0.086 | 31.10% | 3.46% | 1.04% | 91.7% |
| 3 | 70.85 | 2.88 | 0.244 | 56.68% | 9.21% | 2.92% | 78.4% |
| 6 | 90.92 | 4.55 | 0.390 | 72.74% | 14.55% | 4.68% | 67.7% |

**Quan sát:** nhóm 6 có nhiều kill và coverage support tốt hơn nhưng normal vẫn là phần tăng trưởng cốt lõi. Không được suy ra "Boss chắc chắn có" từ trung bình 0.390 Boss/6h của fixture.

### 3.2 FAIR RNG policy & seeded Monte Carlo

Cùng dòng eligible kills, so ba cơ chế:
- D: tất cả real kill EXP ghi ngay.
- E: mỗi eligible kill có Tinh Nguyên với p=0.75; nếu drop thì trị giá 1/0.75 lần nominal XP. Đến lúc hợp lệ hấp thu mới cộng; **kỳ vọng bằng D**, variance lớn hơn và có thể giữ Kho.
- H: 80% nominal ghi ngay; thêm p=0.25 token có trị giá 0.8×nominal nếu rơi => expected token =0.2×nominal; **tổng kỳ vọng bằng D**. H token chỉ tiêu thụ khi hợp lệ.
- Mọi token được giả định hấp thu đầy đủ **để so long-run fairness**. Trong lúc chưa hấp thu, E chỉ thể hiện pending material, H chỉ có phần 80% trực tiếp. Không có giả định Godot đã implement các token.
- Pure analytical Monte Carlo độc lập: **N=10,000** mẫu/party, seed = **20261023**, NumPy default_rng (PCG64); per-class eligible kill counts Poisson(6×effective_rate). Draw binomial theo grade để mint token. Không dùng Combat V2 RNG/runtime, không có seed game, không có QA Godot.

**Phân phối 6 giờ: gross hunt EXP quy đổi theo % floor tham chiếu, bao gồm cả thưởng token nếu giả sử đã hấp thu**. P10/P50/P90 qua 10,000 mẫu (D/E/H cùng các kill draws trong mỗi cohort):

| Team | Cơ chế | Mean | P10 | P50 | P90 |
| ---: | --- | ---: | ---: | ---: | ---: |
| 1 | D | 35.58% | 27.20% | 35.20% | 44.80% |
| 1 | E | 35.54% | 26.67% | 35.20% | 45.87% |
| 1 | H | 35.57% | 26.88% | 34.56% | 44.80% |
| 3 | D | 68.88% | 56.00% | 68.00% | 82.40% |
| 3 | E | 68.85% | 54.40% | 68.27% | 84.27% |
| 3 | H | 68.87% | 55.68% | 67.84% | 83.20% |
| 6 | D | 92.02% | 76.80% | 91.20% | 108.80% |
| 6 | E | 91.97% | 74.67% | 90.67% | 110.93% |
| 6 | H | 92.04% | 76.16% | 90.88% | 109.44% |

**Đọc đúng:** 108.8% hay 110.93% ở P90 nhóm 6 là **lượng reward GROSS của tầng tham chiếu**, KHÔNG phải trạng thái XP thực có thể vượt gate. Chuyển tầng nhỏ/gate10/EXP dư/downtime/nhóm mới phải được mô phỏng trong Godot đúng source. Không kết luận H/E nhiều XP hơn D vì dao động Monte Carlo vài %.

### 3.3 Nature of variance and engagement

- Quái thường xuất hiện rất nhiều => direct per-kill tạo nhịp reward dễ hiểu, có thể batch UI 1–3s trong khi backend settlements không trì hoãn.
- Elite là boost thường thấy ở nhóm lớn, boss cố ý hiếm: trong fixture P(không có Boss trong 6h) = 91.7% solo, 78.4% trio, 67.7% 6 người. **Boss nên mạnh về gear/rare drop, không là điều kiện bắt buộc để lên Tu Vi bình thường**.
- ESSENCE có thêm RNG ở tầng drop và một bước người dùng/AI phân phối; cùng mean nhưng đuôi thấp/xấu dễ hơn, đồng thời dễ sinh hoarding cho đệ tử khỏe và bỏ quên support. H2 giữ randomness ở phần vật liệu đặc biệt, không ở cốt lõi Tu Vi.
- Phí server/CPU (chưa benchmark): D cần 1 per-kill receipt + eligible actor credits; E cần Kho, token gen/drop, consumer receipt, phân phối, queued pending; H đòi cả hai. Với 1,000–3,000 đệ tử, kiểm thử batch/receipt/SaveService phải đo trên workload thật, không quy là đã performant.

## 4. 30 CẢNH GIỚI × 10 TẦNG: bám đúng SOURCE, tính trên CẢ 300 COST

Canonical floor cost C(r,f): với f=1..9 lấy round-to-nearest-10(REALM_TOTAL_XP[r] × weight[f]); f10 = total − sum(f1..f9). Tổng cả hai track riêng, nhưng benchmark này tính **Tu Vi track**, Body không tự ăn XP quái.

Công thức **IDEAL LOWER-BOUND thời gian toàn tuyến** (không có thất bại đột phá, không delay vật liệu/sản xuất, không EXP dư ở major gate, không kill grade/rank mismatch, không world caps, không giới hạn vật lý). Chọn Tư Chất 60 và không buff => natural=(1000×1.15×60)=**69,000 XP/giờ**. Với cohort g, Wg = uptime×eligible×(normal_rate+4×elite_rate+15×boss_rate). Expected modeled stage progress speed = **69,000 + 0.008×C(r,f)×Wg XP/hour**; ideal time per floor = C(r,f)/that_speed; cộng **300** floor times. Đây là tích phân gần đúng theo expectation, không phải replay monster kill. D, E, H có **CÙNG** lower-bound khi absorbed ngay và không có loss; khác nhau ở latency/variance/persistence.

Effective W: solo **7.4160**, trio **14.3357**, team6 **19.1585**. Toàn tuyến ideal khoảng **185.5 / 100.9 / 76.7 simulation-days** tương ứng 1/3/6. **Không phải thời gian hoàn thành người chơi**. Thời gian thực phụ thuộc tốc độ simulation, gate, repair, offline budget, tài nguyên và chiến đấu thật. Bảng này cố tình hơi chậm; các mục tiêu "frontier 44.6 sim-days" trước là phương án khác, không phải benchmark CODE PASS.

| Realm | Authored realm XP | Floor1 cost | Floor10 cost | 1 member ideal days | 3 members ideal days | 6 members ideal days |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 10,000,000 | 700,000 | 1,400,000 | 3.2 | 2.2 | 1.9 |
| 2 | 12,700,000 | 889,000 | 1,778,000 | 3.6 | 2.4 | 2.0 |
| 3 | 16,200,000 | 1,134,000 | 2,268,000 | 4.0 | 2.6 | 2.1 |
| 4 | 20,500,000 | 1,435,000 | 2,870,000 | 4.4 | 2.8 | 2.2 |
| 5 | 26,000,000 | 1,820,000 | 3,640,000 | 4.8 | 2.9 | 2.3 |
| 6 | 33,000,000 | 2,310,000 | 4,620,000 | 5.1 | 3.1 | 2.4 |
| 7 | 42,000,000 | 2,940,000 | 5,880,000 | 5.5 | 3.2 | 2.4 |
| 8 | 53,300,000 | 3,731,000 | 7,462,000 | 5.7 | 3.2 | 2.5 |
| 9 | 67,700,000 | 4,739,000 | 9,478,000 | 6.0 | 3.3 | 2.5 |
| 10 | 86,000,000 | 6,020,000 | 12,040,000 | 6.2 | 3.4 | 2.6 |
| 11 | 109,200,000 | 7,644,000 | 15,288,000 | 6.3 | 3.4 | 2.6 |
| 12 | 138,700,000 | 9,709,000 | 19,418,000 | 6.5 | 3.5 | 2.6 |
| 13 | 176,000,000 | 12,320,000 | 24,640,000 | 6.6 | 3.5 | 2.6 |
| 14 | 223,700,000 | 15,659,000 | 31,318,000 | 6.7 | 3.5 | 2.7 |
| 15 | 284,000,000 | 19,880,000 | 39,760,000 | 6.7 | 3.6 | 2.7 |
| 16 | 360,700,000 | 25,249,000 | 50,498,000 | 6.8 | 3.6 | 2.7 |
| 17 | 458,000,000 | 32,060,000 | 64,120,000 | 6.8 | 3.6 | 2.7 |
| 18 | 581,700,000 | 40,719,000 | 81,438,000 | 6.9 | 3.6 | 2.7 |
| 19 | 738,700,000 | 51,709,000 | 103,418,000 | 6.9 | 3.6 | 2.7 |
| 20 | 938,200,000 | 65,674,000 | 131,348,000 | 6.9 | 3.6 | 2.7 |
| 21 | 1,191,500,000 | 83,405,000 | 166,810,000 | 7.0 | 3.6 | 2.7 |
| 22 | 1,513,200,000 | 105,924,000 | 211,848,000 | 7.0 | 3.6 | 2.7 |
| 23 | 1,921,700,000 | 134,519,000 | 269,038,000 | 7.0 | 3.6 | 2.7 |
| 24 | 2,440,500,000 | 170,835,000 | 341,670,000 | 7.0 | 3.6 | 2.7 |
| 25 | 3,099,500,000 | 216,965,000 | 433,930,000 | 7.0 | 3.6 | 2.7 |
| 26 | 3,936,300,000 | 275,541,000 | 551,082,000 | 7.0 | 3.6 | 2.7 |
| 27 | 4,999,200,000 | 349,944,000 | 699,888,000 | 7.0 | 3.6 | 2.7 |
| 28 | 6,349,000,000 | 444,430,000 | 888,860,000 | 7.0 | 3.6 | 2.7 |
| 29 | 8,063,200,000 | 564,424,000 | 1,128,848,000 | 7.0 | 3.6 | 2.7 |
| 30 | 10,240,200,000 | 716,814,000 | 1,433,628,000 | 7.0 | 3.6 | 2.7 |

**Cross-check:** total realm XP = 48,130,600,000 per track; các floor trong mỗi realm cộng đúng realm total; đủ 300 costs. Tại r1f1 C=700,000 và natural 69,000/h = **9.857% floor/h**; tại r30f1 C=716,814,000 = **0.009626% floor/h**. Muốn luôn săn **10–20× natural** thì ở r1 mục tiêu sẽ 98.57–197.14% floor/h, r30 chỉ 0.0963–0.1925% floor/h. Muốn giữ **0.5–1% floor/h** trên cả ladder thì multiplier so natural phải đổi từ dưới 1 ở r1 lên 52–104× tại r30. **Hai mục tiêu trong P3.7 không nhất quán nếu áp cứng mọi realm**; phải chọn mục tiêu paced stage-aware riêng sau khi đo kill cadence.

### 4.1 Late stage and first-stage risks

- REALM 1: natural EXP đã mạnh so với floor1; nếu thưởng săn nhân theo floor cost cực lớn, nhân vật lên tầng quá nhanh, Boss có thể tạo overflow lớn khi không có breakthrough đủ điều kiện. Không được coi reward E/H lô lớn là tự nhiên bank.
- REALM 30: natural EXP rất bé so với tầng; content cần tier-aware genuine EXP. Đừng copy +10,000 Tụ Khí đầu game làm mọi r30 pills.
- 300-floor model giả định hệ số 0.8% normal/floor per eligible kill xuyên toàn game; **đó chỉ là stress fixture**, không có authored 30-tier monster/loot tables. Để khóa tốc độ thật, cần CombatV2 real throughput per band, chance bị thương, medicine/Stone costs, relative monster realm, Breakthrough failure odds và anti-farm dưới cấp.
- Nếu 1/3/6 đều hưởng full per-eligible XP, trong giả định này cá nhân nhóm 6 nhanh lên hơn solo; áp luật qualification đúng từng action, kiểm tra solo niche, tổng tốc độ bãi/quái và consumption budgets. Không sử dụng 1/N flat chia đều làm healer kém phát triển.

## 5. OFFLINE: 4 fixture phải tách rạch ròi

| Case | Server/simulation has authoritative combat events? | D credited before return | E credited before absorption | H credited before absorption | Rule |
| --- | --- | --- | --- | --- | --- |
| OFF-0: offline world không simulate/không có kill events | NO | **0 hunt XP** | 0 | 0 | Không ước lượng kills/h tạo free loot; natural XP riêng chỉ khi canonical clock hợp lệ |
| OFF-1: bounded deterministic offline replay of real death/loot receipts | YES | 100% eligible fixed hunt XP | 0% pending token | 80% direct + token pending | Same seed/world/slot/generation/clock, single authoritative ledger |
| OFF-2: legally return Sect, consume all recorded tokens atomically | YES + warehouse/actor/eligibility | already credited | pending token converts to EXP | pending 20% expected converts | Validate before debit; avoid double grants; same 300-floor gate |
| OFF-3: replay duplicate/crash after partial receipt | same event IDs replayed | 0 additional | 0 additional | 0 additional | Exactly once across loot, XP and optional token, no second RNG |

**Quan trọng:** phép "E/H cuối cùng bằng D kỳ vọng" chỉ đúng khi tokens thật đã được phân phối và hấp thu hợp lệ. Nếu đệ tử không về Sect 24 giờ, ESSENCE có thể tạm thời **0 hunting EXP**, HYBRID chỉ 80%, dù Kho đang đầy; chặn unlock map và sức mạnh giữa quá trình săn liên tục. Một lần hấp thu lớn khi tầng10 chặn thì unapplied_overflow bị loại theo code nếu không có bank hợp pháp. D vẫn có thể bị tràn ở gate nếu không đột phá kịp; **không khẳng định D miễn tràn**, chỉ loại bỏ backlog hấp thu bắt buộc. Tồn Kho Tinh Nguyên không tự bằng XP đã được cấp.

Không mô phỏng "offline = x giờ × kills/h" thành game rewards khi chưa có authoritative event replay. Không reset daily cap thuốc theo OS midnight; clock duy nhất tick/1440. CARE Injury120 là 120 simulation ticks, không phải 120 wall-clock minutes trong mọi tốc độ chạy.

## 6. Boss + role credit + save exactly-once cases

**Minimal schema (DESIGN, NOT IMPLEMENTED):** `kill_id=(world_id,slot_id,generation,death_seq)`, one death proof, one Sect loot transaction, one event set for each legal contributor, `(kill_id,disciple_id,channel=fixed_hunt_tuvi)` prevents repeat EXP. If E/H: token/provenance links to same root kill; claim receipt is a distinct consumer, not second kill award. Concurrency: 2 legitimate squads must hit ONE Boss HP in CombatV2; no last-hit ownership; healed amount capped to missing HP; tank prevented damage must be instrumented; useful buff/debuff and downed support evidence must be audited. Thresholds, grace/retreat policy and 60/40 Spirit Stones **NOT LOCKED**.

**Fixtures before CODE:** normal kill per 1/3/6, 6-member group one player AFK, tank zero damage but true absorbed damage, healer real vs overheal 0, late tag, two teams Boss, boss full reset no kill, simultaneous lethal hits, personal receipt collision, floor9->10 and gate10 saturation, multiple failed breakthroughs, daily satiety rollback, offline before/after commit, negative/duplicate Warehouse stock and actor unavailable.

**1k/3k stress thought experiment:** assuming 70% rosters are hunters solely as a policy fixture (not owner-locked), 1,000 => ~117 six-person teams, 3,000 => ~350; source normal active 21/h×uptime88% gives ~2,162 / 6,468 **team mob deaths/hour** across independent worlds (NOT a prediction; ignores shared spawn competition/map caps). With 6 qualified participants each, up to 13k / 39k personal XP rows/hour before receipt compression; this demands event-driven aggregation, bounded ledger retention and replay tests, not per-frame UI floating spam. The effective eligibility 82% scenario reduces rows further, but strict role evidence must drive real values.

## 7. Product score / choice (qualitative, NOT a fabricated quantitative score)

| Goal | D DIRECT | E ESSENCE | H 80/20 | H2 DIRECT + RARE NON-XP MATERIAL |
| --- | --- | --- | --- | --- |
| Instant, understandable growth | Very strong | Weak unless magic auto-absorb | Good | **Very strong** |
| PvE continuity / no unnecessary Sect return | Strong | Weak if absorption Sect-only | Medium | **Strong** |
| 6-member healer/tank fairness | Good with true credit | Requires allocation plus true credit | Most complex | **Good with true credit** |
| Economy meaningful for production | Loot/gear still matters | Lots of resource loops | Both | **Rare crafting/breakthrough + existing pills/fields** |
| Offline/save transaction complexity | Least | Highest absorption/stock | Highest dual-source | Direct EXP ledger + ordinary rare material receipt |
| Anti-hoarding/overflow | Immediate timing; gate still matters | Bulk redeem spikes & delay | Intermediate | Same as direct |
| Current canonical compatibility | Needs explicit §2.2 change | Best match current lock | Needs §2.2 change | Needs §2.2 change for direct XP |

**RECOMMENDED H2:** Direct fixed hunting XP to participating actor from actual death, while rare Tinh Nguyên (if useful) is a **Sect-owned special item for recipes, breakthrough or forge only**. Do NOT make it a new hidden required progression currency. This is a design choice in response to user request, NOT code approval or authorized override of canonical §2.2 yet.

## 8. Handoff — what to do AFTER current Codex B3-CARE integration

1. Owner reviews/directly approves **canonical source policy** D/H2 vs locked Essence; first docs-only reconciliation of §2.2 and all contradictory P3.7/B3 notes with an explicit superseded-not-deleted audit trail. No runtime on this benchmark branch.
2. When CARE integration and focused regression at exact new HEAD finish, run a read-only CodeAudit of real world/kill action traces for **1,3,6 disciples** by grade; identify rates/eligibility/injury at realm1/floor1 first, then calibrated r5/r10/r20/r30. Do not introduce unapproved data.
3. Use those logs to fit one typed fixed-hunt reward curve C(r,f,monster_grade,challenge,participation) after comparing 10–20× vs stage% targets across 300 costs. NORMAL farms drive predictable growth; Elite/Boss bursts/loot, not guaranteed.
4. Separate narrow CODE packet with exact allowlist: canonical death ledger -> personal EXP receipt plus Sect loot receipt -> SaveService -> UI; no second passive source. Negative replay/overflow/role/offline tests. CODE only after explicit owner-approved scope. Source A and other world/AI writers untouched.

## Reproduction outline — analysis only, no engine calls

- For each party seed with NumPy `default_rng(20261023)`, 10,000 rows; class vector `[normal,elite,boss]`; Poisson lambda=(active_rate×uptime×qualification×6h).
- For D: stage_fraction =0.008×(normal+4×elite+15×boss).
- For E: token_counts = Binomial(event_counts,0.75); eventual_fraction=0.008×(normal_token+4×elite_token+15×boss_token)/0.75.
- For H: direct=.8×D; token_counts=Binomial(event_counts,0.25); eventual_fraction=direct+0.008×0.8×(normal_token+4×elite_token+15×boss_token).
- Build all 300 stage C(r,f) from exact frozen REALM_TOTAL_XP and FLOOR_WEIGHT_PER_MILLE, f10 residual; stage duration=C/(69000+0.008*C*Wg) hours, sum. This is a **notional lower-bound** and cannot validate actual 30×10 gameplay without authentic Godot runs.

**No CODE, Godot tests, CI, merge, Source A or existing docs file replaced by this task.**
