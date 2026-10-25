# TÔNG MÔN BÁ ĐẠO — R11 S1/S2 SOFTLOCK, ĐỘ LỆCH MAY RỦI VÀ KINH TẾ 7–30 NGÀY
## Thiết kế World Continuous; không dùng timeout 90s hay loot theo wave

**Ngày 25/10/2026. RESEARCH-ONLY.** Tiếp nối commit R11 S1/S2 `4c3e7ba5` trên main `29b5fba`. Đối chiếu PR31 continuous trên SHA code `4b02a0c...`, HEAD `9eb4fd5...` (open/draft, không merge). Không code, không sửa PR29/UI, không map hay asset, không claim Godot PASS R11. Companion docs: `TMB_R11_S1_S2_QUANT_SOURCE_CAPACITY_30_300_2026-10-25.md`, `TMB_R11_R10_COMBAT_V2_ANALYTIC_SURVIVAL_CALIBRATION_2026-10-25.md`, `TMB_COMBAT_CONTINUOUS_VS_LEGACY_90S_DEPRECATION_AUDIT_2026-10-25.md`.

## 1. Luật quan trọng — nguồn và thời gian
1. Chỉ tính **genuine death** của một monster life thật trong world continuous; kill/loot một lần theo `(world,camp,slot,generation)`. Quái respawn độc lập theo thời gian, không có trận thắng toàn wave mới được nhận.
2. Ore, Fiber chỉ đến Warehouse sau worker mining/forestry thực, có work+haul, một NodeHarvestKey/một thế hệ, không phải thu từ mine/forest lower-tier.
3. Không có mốc 90s kết thúc săn; `MapBattleV2.MAX_SECONDS` chỉ là rule của finite legacy. World candidate PR31 đã test 120s same active world. Tuy nhiên model quặng/cây và quái R11 vẫn CHƯA CODE.
4. Nguồn cung bằng 0 nếu không có worker/hợp đồng work hoặc không có một lần quái HP0 nào; chỉ trôi qua respawn ticks không cho loot. Offline dùng canonical sim ticks và persisted node/monster generation. Rút lui là action/policy, Injury0/1 hồi120 tick.
5. Một Sect Warehouse không giới hạn gameplay capacity; phải fail-closed nếu cộng tràn MAX_SAFE_STACK, không “Kho đầy thì mất vật liệu”, không hidden extra bag.

## 2. Đường R10 lấy nguồn R11: điều kiện softlock phải đồng thời PASS
| Gate | Câu hỏi có thể kiểm chứng | Hiện trạng |
|---|---|---|
| G1 — Navigation | Team gear R10 đi từ sect_start đến outer_entry và từng ore/fiber/deer camp rồi trở về không cần R11? | Không có nav graph R11 runtime; BLOCKED |
| G2 — Work | Worker thật có One Active Job hoàn tất harvest+haul và receipt không credit sớm? | R11 node chưa có; BLOCKED |
| G3 — Combat | Ít nhất một đội thực R10 cùng learned skills/equipment legal hạ một normal deer vùng rìa, survive/retreat/retry, không cần R11 gear? | Vân Giác Lộc chưa có, chưa chạy Godot R11; BLOCKED |
| G4 — Recovery | Nếu đội thua hoặc worker Injury1, về nhà hồi120 ticks và có tiếp cơ hội lấy nguồn? | Invariant Injury code tồn tại, nhưng R11 route chưa chứng minh |
| G5 — Persistence | 100 lần save/load, death receipt/node receipt và generation không tăng thưởng? | Contract docs-only, QA fixtures chưa chạy |
| G6 — Reward authority | Legacy encounter `claim_reward` không cùng lúc trả R11 World per-life? | Reward cutover chưa triển khai; BLOCKED |

**Hard softlock**: Cần R11 trước khi tới R11, chỉ Boss/Elite có vật tư thường, cắt đường rút lui, không respawn mà nguồn tiêu hết. **Soft economic bottleneck**: full gear 300 người mất >30 ngày vì mộc hạn chế — không phải hard progression lock nếu game chỉ cần đội tiên phong lên R11.

## 3. Common hide — định lượng rủi ro từ các lần hạ Vân Giác Lộc thật
Nếu một genuine eligible death có xác suất common hide `q` và rolls độc lập theo *life*:
- `K`: số lần hạ đủ 2 bì cho trial first research + 1 weapon (S3/S4 consumer chưa code). `E[K]=2/q`.
- `P(K<=n)=1-(1-q)^n-n*q*(1-q)^(n-1)` cho n>=2, q trong (0,1).
- Không đếm 2 lần do 2 đội/2 người cùng đánh; không reroll ở save/load nếu zero-drop, phải persist `NO_DROP` source receipt.

| Xác suất common q **TRIAL** | Kỳ vọng số kill để được 2 bì | P(đủ sau 5 kill) | P(đủ sau 10 kill) | Số kill ở ngưỡng 95% (exact) |
|---:|---:|---:|---:|---:|
| 100% | 2 | 100% | 100% | 2 |
| 50% | 4 | 81,25% | 98,93% | 8 |
| 25% | 8 | 36,72% | 75,60% | 18 |

**Cross-check Monte Carlo (ngoài Godot, không phải RNG game):** Python NumPy default_rng seed `20261025`, N=50.000 độc lập mỗi q, negative_binomial(2,q)+2; sample means q=1/0,5/0,25 lần lượt **2,00000 / 4,00620 / 8,01678**, sample P(K<=10) **1,00000 / 0,98934 / 0,75584**. Chạy trong phiên phân tích để xác nhận công thức; không hề chạy Combat V2 hoặc engine Godot.

**Khuyến nghị O3 vẫn OPEN:** q=1 cho **chất liệu phổ thông giai đoạn bootstrap**; nếu q<1 phải có bounded guarantee counter theo death receipts hợp lệ persisted. Hiếm equipment/manual là RNG khác, không được tăng lên 100% theo vật tư thường. Q=1 không có nghĩa 100% khả năng đánh thắng.

## 4. Nhu cầu với roster 30–300: đừng giả toàn bộ được mặc đủ R11
TRIAL: một kit 10-slot cần 15 ore +21 fiber +4 beast; lần nghiên cứu đầu +1 ore/+1 beast. `kit_count=ceil(roster*fraction)` khi lập kế hoạch, không bắt người chơi mua full 10 món. Cả kit/công thức chưa được Registry/Forge công bố trong runtime.

| Roster | 10% ready → kit count | Ore/Fiber/Beast cho 10% | 25% ready → kit count | Ore/Fiber/Beast cho 25% |
|---:|---:|---:|---:|---:|
| 30 | 3 | 46 / 63 / 13 | 8 | 121 / 168 / 33 |
| 100 | 10 | 151 / 210 / 41 | 25 | 376 / 525 / 101 |
| 300 | 30 | 451 / 630 / 121 | 75 | 1.126 / 1.575 / 301 |

Reference faucet TRIAL 4 ore nodes, 4 fiber nodes, 3 deer slots và worker/squad/uptime đã cho trong công suất companion: **6,80 ore/h, 6,80 fiber/h, 2,88 beast/h**. Tất cả là expected capacity envelope, không phải Warehouse stock measured.

- 300 roster, **25% =75 kit**, hạn mộc 1.575/6,8 = **231,62 giờ mô phỏng (9,65 ngày)**. Đây là cận dưới nguồn cung, chưa tính Forge/research/injury.
- 300 roster, **100%=300 kit**, 6.300/6,8 = **926,47 giờ mô phỏng (38,60 ngày)**; vượt 30 ngày, không nên dùng làm hidden gate bắt buộc.
- Để 300 kit/30 ngày, fiber >=8,75/h; reference 6,80/h thiếu 1,95/h. 6 fiber nodes theo cùng giả định sẽ cho 10,20/h nếu đủ 2 workers, vượt riêng yêu cầu này; có thể khi đó sink Forge là bottleneck khác.
- 300 roster, **10%=30 kit**, tối thiểu 630/6,8=**92,65 giờ mô phỏng**. Phát triển theo đội tiên phong làm tiến trình hợp lý hơn.
- Nếu 300 roster có 10% cần replacement mỗi 7 ngày =30 kit/tuần → fiber cần 3,75/h; 20%=60 kit/tuần → fiber cần 7,50/h. Reference vừa đủ mức 10%, thiếu mức 20%; kiểm chứng replacement/salvage/market sau khi có consumers.
- 7 ngày, 30 kits cần 3,75 fiber/h, phù hợp reference trên giấy. 7 ngày, 300 kits cần 37,5 fiber/h, không phù hợp; không được tăng tài nguyên ×số đệ tử khi node/camp đã full.

## 5. Long-horizon fault matrix: dữ liệu hơn là animation
| Case | Thiết lập cần test trong tương lai | PASS phải chứng minh |
|---|---|---|
| L01 | Có 300 đệ tử, cùng 4 fiber nodes | node-limited; thêm worker dư không sinh gỗ |
| L02 | 7 ngày offline, không có worker/kill | zero earned R11 source material |
| L03 | 7 ngày offline, worker đúng job và nguồn persisted | genuine job completions only; no free cycles |
| L04 | 100 camera unload/reload | không reset monster life/node generation |
| L05 | same kill_id ghi 100 lần | stock +1 entitlement, một receipt |
| L06 | NO_DROP valid death q=.25, reload | zero hide remain zero; no free reroll |
| L07 | nhiều hunter gây chung damage một deer | một life, một HP owner, một credit, không ×hunter |
| L08 | crash trước/giữa/sau stock journal settlement | atomic rollback/commit, không mất/nhân đôi |
| L09 | legacy encounter claim + world per-life kill cùng reward class | fail-closed hoặc đúng một owner |
| L10 | monster respawn cùng slot và gen tăng thật | thế hệ kế tiếp được farm, đời cũ không |
| L11 | worker injured trước haul | no premature Warehouse credit; recovery120 |
| L12 | ore/fiber/deer source đều cần R11 sword | hard softlock FAIL |
| L13 | 30/100/300 roster, 10/25/100% kits | stress supply/sinks/One Active Job; no teleport production |
| L14 | continuous same-world 120s / 3600s | no 90s timeout; real kill/recovery and bounded catch-up |
| L15 | actual R10 stat + gear + learned skills facing 1/3 normal R11 edge | Game RNG seeds, role heal, HP, Injury, retreat without R11 gear |
| L16 | output approaches MAX_SAFE_STACK | safe-int guard only, no invented warehouse capacity |

**Không kịch bản L01–L16 nào đã được chạy trong Godot cho R11**. PR31 có riêng test B3 legacy/continuous >90s, single-life reward + save; không thể mượn kết quả đó làm PASS cho Vân Giác Lộc, vùng biên hay R11 node.

## 6. Việc R11 cần quyết định sau báo cáo
- O1: ID/tags của 3 vật liệu và species có giữ như proposal không.
- O2: single authoritative physical node production+haul, worker constraints; không tái nhãn building Mine/Forest lower-tier.
- O3: common hide q=1 prototype vs q<1 bounded guarantee; nguồn HIẾM/bí tịch vẫn hiếm.
- O4: outer normal deer scale thử R10f8–10; có thể giảm load bằng species factor nhưng phải chạy Combat V2 real fixture.
- O5: world loot ledger và legacy `HuntingMapV2.claim_reward` không trùng entitlement, đối chiếu B3 PH0 owner.
- O6: R10 old-gear accessible two-way nav, injury/recovery, no rare/Elite/Boss gate.

**Final status**: định lượng/softlock [DESIGN ANALYSIS COMPLETE], Godot R11 runtime [NOT IMPLEMENTED], R11 Combat fixture [NOT RUN], World continuous >90s [CODE + FOCUSED EVIDENCE ON PR31, NOT MAIN], Windows/Android sustained performance [PENDING USER]. Không merge/PR mutation.
