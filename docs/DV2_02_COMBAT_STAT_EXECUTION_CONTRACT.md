# DV2-02 — HỢP ĐỒNG TRIỂN KHAI 16 CHỈ SỐ CHIẾN ĐẤU V2

Ngày: 2026-10-09.
**Trạng thái: ĐÃ VIẾT VÀ KIỂM THỬ ĐỘC LẬP BỘ TÍNH; DV2-02 CHƯA ĐÓNG; CHƯA CHUYỂN PvE SANG V2.**
Đọc cùng `docs/COMBAT_STATS_V2_SPEC.md` và `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md` (**các con số trong file lịch sử này đã được user khóa**).

## 1. Một cây tính chỉ số thực — không có Combat Power nguồn

```text
Tu Vi: đại cảnh 1..30 / tầng 1..10
        \                   /
         (Realm HP/ATK/DEF)
                              +  Luyện Thể 1..30 / 1..10 → (Body HP/ATK/DEF)
                                        |
                           Tổng Realm + Body Core
                                        |
                    × [1 + 0,0005 × Tiềm Lực hiện tại]
                                        |
                           + các flat hợp lệ từ trang bị
                                        |
                     × [1 + tổng bonus % CÙNG KÊNH]
                                        |
         16 chỉ số chính / 10 kháng hệ / breakdown nguồn
                                        |
                 Hành động kỹ năng/đòn đánh (combat owner)
                                        |
         bạo kích → phòng ngự/xuyên phòng → khắc hệ
                → kháng hệ → giảm sát thương → HP
```

- Hạt gốc `G(r,t)=1.65^(r-1)*1.03^(t-1)`.
- Tu Vi căn bản ở 1.1: `HP=100 / Công=20 / Thủ=12`.
- Luyện Thể căn bản ở 1.1: `HP=90 / Công=3 / Thủ=7`.
- `Tiềm Lực` +0,05% mỗi điểm vào **Core Realm+Body**, không nhân cố định của kiếm/giáp.
- Trang bị +100 Công cộng đúng 100 rồi mới tính % Công hợp lệ.
- Sát thương giao chiến **không đọc `combat_power`**; mã chiến đấu cũ vẫn sống riêng cho đến lúc có quái/skill V2 chuẩn.

## 2. Danh mục 16 chỉ số chính — giá trị gốc, cộng/trừ, đầu ra

| Chỉ số | Mã canonical | Mức bắt đầu (không nguồn) | Hiệu ứng được phép | Người dùng kết quả |
|---|---|---|---|---|
| Sinh Mệnh tối đa | `max_hp` | `RealmHP+BodyHP` | flat, cùng kênh %; Tiềm Lực chỉ ở Core | trần HP, tính giữ tỷ lệ HP |
| Công Kích | `attack` | `RealmATK+BodyATK` | flat, cùng kênh % | đòn thường và đòn kỹ năng có tỷ lệ Công |
| Phòng Ngự | `defense` | `RealmDEF+BodyDEF` | flat, cùng kênh % và debuff trạng thái đã giải | giảm sát thương của mục tiêu |
| Di Chuyển | `move_speed` | hệ số 1,0 (100% vận tốc gốc do hành động sở hữu) | bonus % tốc độ di chuyển, không trộn tốc đánh | vận tốc di chuyển; hành động chủ quản quyết định m/s thật |
| Đánh Thường | `attack_speed` | bonus 0% | bonus % dạng rate | `base_attack_interval / (1 + bonus)` |
| Thi Pháp | `cast_speed` | bonus 0% | bonus % dạng rate | `base_cast_time / (1 + bonus)` |
| Hồi Chiêu | `cooldown_recovery` | bonus 0% | bonus % dạng rate | `base_cd / (1 + bonus)`, rồi xét Phong Thế |
| Bạo Kích | `crit_chance` | 5% | cộng/trừ **điểm phần trăm**, 0–100% | xác suất bạo kích đòn đủ điều kiện |
| Sát Thương Bạo Kích | `crit_damage` | hệ số 1,50× | +50% sát thương bạo kích = +0,50 vào hệ số | độ lớn khi đòn đã được phép bạo kích |
| Kháng Bạo | `crit_resistance` | 0 điểm phần trăm | cộng/trừ điểm phần trăm, 0–100% | trừ bạo kích người đánh |
| Xuyên Phòng | `defense_penetration` | 0% | điểm phần trăm, 0–100% | giảm DEF còn lại sau buff/debuff |
| Chính Xác Hiệu Ứng | `effect_hit` | 0 điểm phần trăm | cộng/trừ điểm phần trăm | kiểm tra đóng băng/khống chế/debuff cần kiểm tra |
| Kháng Hiệu Ứng | `effect_resistance` | 0 điểm phần trăm | cộng/trừ điểm phần trăm | trừ xác suất áp hiệu ứng |
| Giảm Sát Thương | `damage_reduction` | 0% | các nguồn độc lập nhân lên **phần sát thương còn lại**, không cộng thẳng | hậu phòng ngự và kháng hệ |
| **Hút Máu** | `lifesteal` | 0% | cộng/trừ **điểm phần trăm**; không tự đặt giới hạn tối đa 100% | hồi HP theo % **sát thương HP thực tế** đã gây, sau giảm sát thương và giới hạn HP của đối thủ |
| **Giảm Hút Máu** | `lifesteal_reduction` | 0% | cộng/trừ **điểm phần trăm**, không nhân giảm sát thương | trừ trực tiếp Hút Máu của người đánh, rồi chặn tỷ lệ âm |

**10 kháng hệ (không tính là 10 thuộc tính sinh độc lập):**
`metal, wood, water, fire, earth, lightning, wind, ice, yang, nether` = Kim, Mộc, Thủy, Hỏa, Thổ, Lôi, Phong, Băng, Dương, U Minh.
Giá trị bắt đầu 0%; hai nguồn kháng Hỏa 30% và 20% cho **kháng hiệu lực 44%**, không phải 50%. Khắc hệ Kim–Mộc–Thủy–Hỏa–Thổ là **một phép nhân khác do Linh Căn sở hữu**, không tự tính từ kháng hệ.

**Các giới hạn kỹ thuật (không phải giới hạn nuôi nhân vật):**
- HP tối đa không thấp hơn 1; Công và Thủ không âm; số không hữu hạn bị từ chối.
- Crit Chance, Crit Resistance, Xuyên Phòng kẹp 0–100%; Crit Damage ít nhất 1,0× đối với cơ chế bạo kích thường.
- Effect Hit/Effect Resistance có thể nhận buff/debuff có dấu; **xác suất áp hiệu ứng cuối** mới kẹp 0–100%.
- Một nguồn Giảm Sát Thương/kháng hệ thường phải `0<=value<1`; miễn nhiễm 100% là **luật riêng**, không phải cộng quá nhiều nguồn.
- Tốc độ dạng rate không tự tạo kỹ năng có hồi chiêu 0: đầu vào `bonus <= -100%` bị báo không hợp lệ khi tính khoảng thời gian.
- **Hút Máu hiệu lực = max(0, %HútMáu − %GiảmHútMáu mục tiêu)**. Hai tỷ lệ gốc không âm, **không có cap 100% tự suy diễn**; Hút Máu >100% hợp lệ nếu nội dung thực sự cấp, nhưng HP hồi không vượt phần còn thiếu.
- Chỉ dùng **sát thương trực tiếp thực sự trừ HP** sau toàn bộ phòng thủ; đòn kết liễu không được hút thêm từ sát thương dư. Kỹ năng gây sát thương DoT/phản đòn/triệu hồi/proc hoặc fixed damage phải khai báo quyền Hút Máu riêng.
- **Hút Máu không tự nhân Healing Done/Healing Received** và không tự chạy khi xem trước sát thương; commit HP đúng một lần theo hệ combat action.
- Không có né tránh/chính xác đòn thường, Mana chung, chỉ số tốc độ lượt, chia Công/Thủ vật lý–pháp thuật hay Combat Power làm quyền lực V2.

## 3. Nhận và xử lý nguồn bonus theo đúng địa chỉ

`CombatStatsV2.derive(realm, floor, body_realm, body_floor, potential, sources)` chỉ nhận các nguồn toàn cục **đã được consumer hợp lệ xác định**.

Mỗi đóng góp:
```gdscript
{"source_id":"kiem_thuong_cap","channel":"attack","mode":"flat","value":100.0}
{"source_id":"kiem_menh","channel":"crit_chance","mode":"percentage_points","value":0.05}
{"source_id":"linh_can_hoa","channel":"elemental_resistance/fire","mode":"remaining_reduction","value":0.30}
```
`enabled=false` = ghi nhận nhưng **không cộng hiệu ứng**. Trùng `source_id + channel` là lỗi; tên kênh không tồn tại là lỗi. Một nguồn có `condition/scope/filter` sẽ bị từ chối ở tầng **toàn cục** này: phải được hệ chiến đấu/skill/work tương ứng kiểm tra điều kiện trước, không tự áp dụng mọi trận.

Các nguồn thực sự hiện hữu (Linh Căn, Đặc Chất, Thể Chất, Huyết Mạch, trang bị) sẽ được ánh xạ vào đây ở phase chuyên ngành và chỉ sau khi consumer thật hoạt động. Sinh ra danh tính không đồng nghĩa đã nhận buff.

**Không lưu bộ chỉ số dẫn xuất thành sự thật thứ hai.** Hồ sơ tiến triển + các nguồn gốc là thẩm quyền; `derive` tạo snapshot và bảng `core_breakdown/applied_sources` phục vụ UI, tính chiến đấu và kiểm toán.

## 4. Các phép giải trong một đòn đánh (đã có mã kiểm thử độc lập)

**Khả năng chí mạng**
```text
P(crit) = clamp(Crit Chance_attacker - Crit Resistance_target, 0, 1)
```
Chỉ thử RNG khi cú đánh được gắn `can_crit`. DoT, phản sát thương, proc biến dị, sát thương cố định, hồi máu/hộ thuẫn mặc định **không bạo kích**.

**Áp hiệu ứng**
```text
P(status) = clamp(base_status_chance + EffectHit - EffectResistance, 0, 1)
```
`guaranteed` vượt roll thường; `immune` vượt `guaranteed`, theo thẩm quyền kỹ năng/trạng thái.

**Phòng Ngự và Xuyên Phòng**
```text
DEF_sau_buff_debuff = max(0, mục_tiêu.DEF)
DEF_hiệu_lực = DEF_sau_buff_debuff × (1 − XuyênPhòng)
K = 2 × CôngKích_người_đánh
HệSốQuaThủ = K / (K + DEF_hiệu_lực), khi Công > 0
Damage_after_DEF = RawATK × skill_ratio × eligible_crit × HệSốQuaThủ
Damage_final = Damage_after_DEF × KhắcHệ × (1 − KhángHệ) × (1 − GiảmST)
```

**Trật tự cuối** do từng loại damage packet xác định: `direct` đủ điều kiện mới qua Phòng Ngự; sát thương cố định/DoT/hồi máu không mặc định dùng công thức đòn trực tiếp. Không dùng công thức này như universal resolver cho mọi hiệu ứng.

## 4A. Hút Máu và Giảm Hút Máu — luật đã khóa ngày 2026-10-09

```text
HútMáuHiệuLực = max(0, HútMáuAttacker - GiảmHútMáuDefender)
DamageThực = min(DamageSauPhòngNgựKhángHệGiảmST, HPHiệnTạiDefender)
MáuHồiThô = DamageThực × HútMáuHiệuLực
MáuHồiThật = min(MáuHồiThô, MaxHPAttacker - HPHiệnTạiAttacker)
```

Ví dụ: A có 20% Hút Máu, B có 5% Giảm Hút Máu, gây 1.000 damage sau xử lý phòng thủ. Nếu B có đủ HP thì A được hồi 150 HP (nhưng không vượt HP tối đa). B chỉ còn 100 HP thì lượng hồi thô còn 15 HP. Hút Máu không dùng Công/Chiến Lực thô hoặc **sát thương trước phòng ngự**.

**Code authority:** `CombatStatsV2.effective_lifesteal_rate` và `settle_damage_and_lifesteal` tính toán kết quả HP trong một đòn hợp lệ. Đây chưa phải quyền tự ý chạy xuyên mọi tick chiến đấu cũ. Hệ combat owner phải gọi đúng lúc commit action, và xử lý chống thưởng trùng/restore sau save trong giai đoạn tích hợp encounter.

**Source contract:** hai nguồn đều dùng `percentage_points`. `{"source_id":"huyet_ma","channel":"lifesteal","mode":"percentage_points","value":0.20}` và `{"source_id":"khac_che","channel":"lifesteal_reduction","mode":"percentage_points","value":0.05}`. Các effect chưa có consumer thật vẫn phải `enabled=false`.

## 5. Kiểm thử và giới hạn phase

**Code hiện có:**
- `godot/src/simulation/combat/combat_stats_v2.gd` — kernel tính 16 chỉ số + kháng 10 hệ, typed modifier, direct damage packet.
- `godot/tests/simulation/dv2_02_combat_stats_test.gd` — kiểm tra 14/10, Tiềm Lực+equipment, diễn giải %, stacking, trạng thái, nhịp độ, 300 tầng, nguồn sai/trùng.
- `.github/workflows/dv2-02-combat-stats.yml` — focused Godot 4.7.2.

**Đã có bộ tính; chưa triển khai:**
1. Adapter canonical từ đệ tử V2 sống sang hai tiến độ Tu Vi/Luyện Thể (DV2-03 hiện chưa có track 300 tầng thật).
2. Monster HP/ATK/DEF và các skill damage-tag V2 để **CombatSystem** dùng số thật thay `effective_combat_power`.
3. UI/chính sách cache/invalidation thực, source-filter/theo kỹ năng/điều kiện, các effect kích hoạt riêng.
4. Heal/Shield/DoT/element matchup advanced — nằm trong specialized channels/event owner có spec, không được bật giả.
5. Cumulative Godot 4.7.2 phải có thật trước khi gọi toàn bộ DV2-02 BACKEND LOCKED.

**Không đổi** tỷ lệ sinh đệ tử, nghề nghiệp, Thể Lực Viễn Chinh hoặc Dẫn Tiên trong phase này. Sau DV2-02 mới tiếp tục DV2-03 30×10 và các consumer cần chúng.

## 6. Thuộc tính có điều kiện và quái V2 — DV2-02C

User yêu cầu mở đường xây dựng đa dạng nhưng không phá cân bằng: sát thương lên thủ lĩnh, sát thương theo chủng tộc, liên kích đánh thường và chừa các cơ chế có consumer tương lai.

**Không đổi con số 16 chỉ số chính:** các kênh mới là **nguồn hiệu ứng bối cảnh / hành động**.

| Channel đã có thử nghiệm Godot | Mode | Điều kiện và đầu ra |
|---|---|---|
| `damage_vs_boss` | `percent_add` | mục tiêu đúng tier `boss` |
| `damage_vs_elite` | `percent_add` | mục tiêu đúng tier `elite` |
| `damage_vs_race/<race>` | `percent_add` | mục tiêu đúng một `race_id`; không cộng mọi giống |
| `basic_followup_chance` | `percentage_points` | cơ hội duy nhất sau mỗi đòn đánh thường gốc |
| `basic_followup_damage` | `percent_add` | tăng/giảm hệ số riêng của một đòn liên kích thêm |

**Ví dụ:** Sát thương Boss +15% và sát thương Yêu Thú +10% đánh Hắc Lang Vương (boss, yêu thú) tạo ×1,25 vào một damage packet; không được nhân hai nguồn thành ×1,265 và không nhận buff Elite. Đánh U Hồn (quỷ tộc) không được buff Yêu Thú.

**Liên kích cơ bản:** khi đòn thường chính thành công và quái còn HP, một lần roll theo tỷ lệ thực của đệ tử; nếu thành công tối đa một extra basic hit. Hệ số ban đầu extra hit 60% **PILOT chưa khóa cân bằng**, tự cộng theo `basic_followup_damage`, không được kích hoạt lại liên kích/DoT/skill/proc/hút máu/crit nếu chưa có luật riêng. Không có roll mỗi frame.

**Quái:** `godot/src/simulation/combat/monster_catalogue_v2.gd` định nghĩa 7 loài mẫu, bao gồm 3 ID quái P0 hiện có và Hắc Lang Vương, Nham Giáp Thú, Huyết Lang Đầu Đàn, U Hồn. Quái sử dụng bộ HP/Công/Thủ riêng và `MonsterEncounterV2` cho phép đánh nhau với `DiscipleState.hp` thực, không lấy `combat_power` hoặc `P0Content.MONSTERS.power`.

**Hành vi/phần thưởng/phases chưa triển khai:** field `behavior_id` chỉ là nhãn để nối AI sau này; các species mới `loot_ready=false`, không cấp vật phẩm giả. Boss phase và quái dùng kỹ năng phải dùng nguyên thủy chiến đấu chung, không xây engine thứ hai. **P0/P3.7 đang chạy cũ không đổi.**

Chi tiết nguồn, hướng FUTURE và cân bằng số quái ở `docs/DV2_02_CONTEXT_STATS_MONSTER_FOUNDATION.md` (pilot). DV2-02 chưa kết thúc chỉ vì các bài focused pass.
