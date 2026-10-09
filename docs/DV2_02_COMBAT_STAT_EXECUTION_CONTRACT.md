# DV2-02 — HỢP ĐỒNG TRIỂN KHAI 14 CHỈ SỐ CHIẾN ĐẤU V2

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
         14 chỉ số chính / 10 kháng hệ / breakdown nguồn
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

## 2. Danh mục 14 chỉ số chính — giá trị gốc, cộng/trừ, đầu ra

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

**10 kháng hệ (không tính là 10 thuộc tính sinh độc lập):**
`metal, wood, water, fire, earth, lightning, wind, ice, yang, nether` = Kim, Mộc, Thủy, Hỏa, Thổ, Lôi, Phong, Băng, Dương, U Minh.
Giá trị bắt đầu 0%; hai nguồn kháng Hỏa 30% và 20% cho **kháng hiệu lực 44%**, không phải 50%. Khắc hệ Kim–Mộc–Thủy–Hỏa–Thổ là **một phép nhân khác do Linh Căn sở hữu**, không tự tính từ kháng hệ.

**Các giới hạn kỹ thuật (không phải giới hạn nuôi nhân vật):**
- HP tối đa không thấp hơn 1; Công và Thủ không âm; số không hữu hạn bị từ chối.
- Crit Chance, Crit Resistance, Xuyên Phòng kẹp 0–100%; Crit Damage ít nhất 1,0× đối với cơ chế bạo kích thường.
- Effect Hit/Effect Resistance có thể nhận buff/debuff có dấu; **xác suất áp hiệu ứng cuối** mới kẹp 0–100%.
- Một nguồn Giảm Sát Thương/kháng hệ thường phải `0<=value<1`; miễn nhiễm 100% là **luật riêng**, không phải cộng quá nhiều nguồn.
- Tốc độ dạng rate không tự tạo kỹ năng có hồi chiêu 0: đầu vào `bonus <= -100%` bị báo không hợp lệ khi tính khoảng thời gian.
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

## 5. Kiểm thử và giới hạn phase

**Code hiện có:**
- `godot/src/simulation/combat/combat_stats_v2.gd` — kernel tính 14 chỉ số + kháng 10 hệ, typed modifier, direct damage packet.
- `godot/tests/simulation/dv2_02_combat_stats_test.gd` — kiểm tra 14/10, Tiềm Lực+equipment, diễn giải %, stacking, trạng thái, nhịp độ, 300 tầng, nguồn sai/trùng.
- `.github/workflows/dv2-02-combat-stats.yml` — focused Godot 4.7.2.

**Đã có bộ tính; chưa triển khai:**
1. Adapter canonical từ đệ tử V2 sống sang hai tiến độ Tu Vi/Luyện Thể (DV2-03 hiện chưa có track 300 tầng thật).
2. Monster HP/ATK/DEF và các skill damage-tag V2 để **CombatSystem** dùng số thật thay `effective_combat_power`.
3. UI/chính sách cache/invalidation thực, source-filter/theo kỹ năng/điều kiện, các effect kích hoạt riêng.
4. Heal/Shield/DoT/element matchup advanced — nằm trong specialized channels/event owner có spec, không được bật giả.
5. Cumulative Godot 4.7.2 phải có thật trước khi gọi toàn bộ DV2-02 BACKEND LOCKED.

**Không đổi** tỷ lệ sinh đệ tử, nghề nghiệp, Thể Lực Viễn Chinh hoặc Dẫn Tiên trong phase này. Sau DV2-02 mới tiếp tục DV2-03 30×10 và các consumer cần chúng.
