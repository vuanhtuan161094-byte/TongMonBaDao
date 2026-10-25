# TÔNG MÔN BÁ ĐẠO — R10 ĐÁNH VÂN GIÁC LỘC: KIỂM ĐỊNH SÁT THƯƠNG COMBAT V2
## Tách phép tính theo code thật khỏi tỷ lệ thắng / game QA chưa có

**2026-10-25 — DOCS RESEARCH ONLY.** Không sửa code; không bổ sung species vào registry, không dựng map, không chạy Godot/CI, không merge, không sửa PR UI/Source A/Combat V2. Căn cứ main 29b5fba448b0178cb520a4ada44b375b4b934e31 và hồ sơ R11 S1/S2 nhánh 4c3e7ba5.

## 1. Những gì code chính xác đang làm [SOURCE/CODE]
- CombatStatsV2.derive: Realm G(r,f)=1,65^(r−1) × 1,03^(f−1); Body dùng G riêng; Tiềm Lực factor=(1+0,0005×potential). Base player:
  - MaxHP = (100 × RealmG + 90 × BodyG) × potential_factor, sau đó flat/percent sources hợp pháp;
  - ATK = (20 × RealmG + 3 × BodyG) × potential_factor;
  - DEF = (12 × RealmG + 7 × BodyG) × potential_factor.
- CombatStatsV2.resolve_direct_hit với neutral/basic, không chí mạng/kháng/phá thủ: damage = ATK × [2 ATK / (2 ATK + DEF_target)]. Nếu penetration/crit/resistance/context được bật, phải áp đúng nguồn và thứ tự của code; không biến historical equipment combat_power thành ATK.
- MonsterCatalogueV2.create_actor: normal HP=190G × species_hp, ATK=23G × species_atk, DEF=19G × species_def; normal tier factors đều 1. Vân Giác Lộc species chưa tồn tại, nên **species factor trong báo cáo này là tham số mô phỏng**.
- MapBattleV2: STEP_SECONDS=0,25, MAX_SECONDS=90, MAX_DISCIPLES=30, MAX_MONSTERS=40, sáu disciple tối đa/party; normal monster basic base interval=1,65 giây, disciple mặc định base_interval=1,6 giây trước learned style/gear. Các đòn có vị trí/movement/target, role healer/guard/learned skills, randomness, dead/downed, cooldown. Map battle giây **không trực tiếp tương đương tick/minute của scheduler**.
- DiscipleCombatLoadoutV2.build nhận Tu Vi/Body explicit và gear/sources có thật; safe linked HP không mặc định ghi ngược V2 maxHP vào persistent disciple. Hệ thống HuntingPveRunV2 nói rõ V2 run chưa được cài vào legacy scheduler.
- Body là track độc lập; R10 Đại Thừa T10 + Body R9 Linh Thân? **Sai tên**: Body R9 Khai Khiếu, R10 Linh Thân. Tu Vi R11=Nhân Tiên, Body R11=Kim Thân. Không được coi cả hai tự đồng cấp.
- R11 family ngoài biên có actor scale thử theo R10f8–10, sâu bên trong dùng R11f1+; đó là **content proposal**, không có luật tự giảm sức quái theo team.

## 2. Reproduction contract của phép tính offline [SIM, not game runtime]
Đầu vào chuẩn để so sánh:
- Một đệ tử giả định cultivation R10f10, body R9f10; Tiềm Lực=0, không nguồn gia tăng, HP đầy, neutral, no crit/no skill/no resistance/no penetration; đây là stat baseline **có thể tính theo code**, KHÔNG phải bằng chứng build R10 gear thực tế.
- Sáu actor giả định có stat giống nhau, tất cả đã đứng trong tầm đánh, target cùng một normal deer; đòn đồng loạt 1× basic ratio, không có lỡ nhịp/AI target switches. Đây là tình huống lý tưởng hóa gây **cận dưới lạc quan** cho thời gian hạ một đối thủ.
- Monster giả định normal, species HP/ATK/DEF factors 1,0. Không ngầm giả thiết special AI, element advantage, buff hoặc gear.
- Pseudomath: P_hit = P_ATK × 2P_ATK/(2P_ATK+M_DEF); M_hit = M_ATK × 2M_ATK/(2M_ATK+P_DEF); ideal TTK_6 = M_HP × 1,6/(6×P_hit); solo under-fire TTD = P_HP × 1,65/M_hit. Có rounding; TTK_6 không tính animation/position/current HP, nên **không dùng để kết luận đội đã thắng**.

Stat của player R10f10/Body R9f10: HP≈18.278,76; ATK≈2.580,53; DEF≈1.921,06.

| Monster actor scale, species=1/1/1 | Monster HP / ATK / DEF (xấp xỉ) | Người gây damage/basic | Quái gây damage/basic | Ideal TTK một quái, 6 người | Một quái đánh một người: thời gian giảm HP lý tưởng |
|---|---|---:|---:|---:|---:|
| R10 tầng 8 (vùng ngoài) | 21.182 / 2.564 / 2.118 | 1.830 | 1.865 | 3,09 giây | 16,17 giây |
| R10 tầng 10 (rìa sâu hơn) | 22.472 / 2.720 / 2.247 | 1.798 | 2.010 | 3,33 giây | 15,00 giây |
| R11 tầng 1 (nội vùng) | 28.418 / 3.440 / 2.842 | 1.664 | 2.689 | 4,55 giây | 11,22 giây |
| R11 tầng 3 (nội vùng mạnh) | 30.149 / 3.650 / 3.015 | 1.629 | 2.889 | 4,94 giây | 10,44 giây |

**Không đánh đồng** TTD trung bình với thời điểm down trong MapBattleV2: game dùng tick 0,25s, first attack near t0, crit 5% mặc định, priority targets, role skills, movement. Tình huống 3–6 quái cùng đánh một frontline đặc biệt nguy hiểm. Những con số trên là so sánh analytic, không phải trace.

## 3. Nhạy theo species chưa được author: ví dụ R11f1
**Ba bộ factor HP/ATK/DEF đều [ASSUMPTION], không phải ID đã đăng ký:**

| Deer profile | Factor HP / ATK / DEF | Deer HP | Damage người gây/basic | Damage deer gây/basic | Ideal 6-v-1 TTK | Deer đơn lẻ TTD player |
|---|---|---:|---:|---:|---:|---:|
| Ngoại biên nhẹ | 0,80 / 0,85 / 0,80 | 22.734 | 1.791 | 2.201 | 3,38s | 13,70s |
| Trung tính | 1,00 / 1,00 / 1,00 | 28.418 | 1.664 | 2.689 | 4,55s | 11,22s |
| Nặng | 1,30 / 1,20 / 1,15 | 36.943 | 1.580 | 3.349 | 6,24s | 9,01s |

Nếu **3 quái nặng cùng tập trung đúng một người** và cả 3 đòn đều trúng, một volley có thể gây khoảng 10.047 HP = 55% HP player R10f10/BodyR9f10 trước guard/heal; hai volley có thể knockdown. Do đó cảnh giác với suy luận 6-v-1 nhanh → 6-v-3 chắc thắng; không tính DPS tổng của 30 người như đánh một quái vô hạn.

Baseline thay Body:
| Tu Vi / Body (Tiềm Lực 0, no sources) | HP xấp xỉ | ATK | DEF |
|---|---:|---:|---:|
| R10f8 / R9f10 | 17.600 | 2.445 | 1.840 |
| R10f8 / R10f10 | 21.793 | 2.585 | 2.166 |
| R10f10 / R9f10 | 18.279 | 2.581 | 1.921 |
| R10f10 / R10f10 | 22.472 | 2.720 | 2.247 |

Cảnh giới/quái scaling **đúng với curve đã khóa**, nhưng trang bị và kỹ năng learned thực tế sẽ làm khác kết quả. Đây là lý do bắt buộc phải dùng legal R10 account fixtures thay cho Tiềm Lực=0/không đồ.

## 4. Vấn đề liên quan đến PvE live mode
- Vân Giác Lộc chưa tồn tại trong SPECIES, không có authored wood skill, behavior_ready mặc định false. Không được nhét species_id vào encounter giả rồi nói đã được combat nghiệm thu.
- Hệ thống hiện dùng arena nhóm chứ chưa là open-world persistent physical life tại world/camp/spawn_slot/gen. Không có per-life loot; kết toán encounter và life cần owner riêng rõ, không thưởng hai lần.
- Healer, defense guard, damage_context, elemental resist, skill eligibility đều có thể làm TTK khác. Nếu muốn xác suất thắng phải dùng deterministic seeds vào **chính MapBattleV2** với 6 disciple thực sự được xây từ DiscipleCombatLoadoutV2 và real R10 owned gear/skills; analytic sheet không thay được fixture này.
- Role bố trí, 3/5/6 quái, lịch AoE Elite/Boss không được đem vào common hide bootstrap nếu Elite/Boss là cổng bắt buộc.
- Damage result không phải survival trace. Team sau khi hạ quái còn phải rút lui và giữ hợp đồng Injury0/1, 120 tick; loser không được nhận hide vì damage contribution.

## 5. Test matrix cần Code/Godot authorization MỚI chạy được
| ID | Thiết lập tài khoản/build | Đối thủ | Tín hiệu cần ghi | Expected DESIGN gate |
|---|---|---|---|---|
| C01 | 6 R10f8 + BodyR9f10, gear R10 legal | 1 outer normal R10f8 | win/defeat, 0–90sec, hp timeline, Injury | Tìm chiến thuật khả thi |
| C02 | 6 R10f10 + BodyR9f10 | 1 outer normal R10f10 | attack/defense/effect, no R11 gear | Không cần R11 để săn |
| C03 | 6 R10f10 + BodyR10f10, roles frontline/heal | 3 outer normal | target switch, healer, downed, retreat | Nhận diện focus-fire spike |
| C04 | như C02 nhưng 3 normal | 3 R10f8–f10 | TTK, downed/injury, repeat | Thử trần số mob đầu vùng |
| C05 | như C03 và 6 monsters | 6 normal | near-loss/failure/injury | KHÔNG được biến C01 thành bảo chứng |
| C06 | C02, state không có blueprint/R11 items | R11f1 + 1 normal | progression/softlock trace | Nội vùng có thể khó, không bắt buộc |
| C07 | C02, điều kiện yếu nhất & worker bị Injury | 1 outer normal | recovery 120 tick, route return | Có đường lui |
| C08 | 5 đội / 30 disciple cùng tấn công 1 life | 1 shared normal | 1 HP owner, 1 death, 1 receipt | Không 30× hide |
| C09 | 100 seeds theo chính GameRng / builds C01–C05 | 1/3/6 normal | win%, p05/p50/p95 TTK; Injuries | Chọn candidate balance, không tự khóa threshold |
| C10 | V2 reward owner vs legacy encounter | same entitlement | delta Kho / receipts | Không double credit |

**Acceptance đề xuất, chưa owner duyệt**:
1. Ít nhất một đội R10 không có R11 gear/blueprint có đường đánh thắng **một** normal outer deer, lấy common resource và rút lui; không nhất thiết mọi team đều thắng.
2. Đánh đủ seed và thực tế injury/recovery; không có insta-wipe bắt buộc vì 3 monster spawn chắn nguồn.
3. Nếu đội thất bại, phải có recovery/retry hữu hạn; ít nhất một tuyến worker đến ore/fiber vẫn chạy mà không cần giết boss.
4. Một con quái có một HP/life terminal thật và đúng một common-material settlement.
5. Không chốt p_win = 0,80 từ bản tính; chỉ đặt vào quantitative envelope như tham số độ nhạy. Không chứng minh FPS, Android, animation, camera hoặc navmesh bằng công thức.

**Verdict:** [SOURCE] công thức và giới hạn trận V2 đã đối chiếu; [SIM] bảng số học đã tính với giả định rõ; [RUN] zero official Godot battles; [STATUS] R10→R11 outer survivability **PENDING FIXTURE**, S1/S2 vẫn BLOCKED cho nghiệm thu gameplay.
