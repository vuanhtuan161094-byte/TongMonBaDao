# DV2-02 — CHỈ SỐ THEO NGỮ CẢNH & NỀN TẢNG QUÁI V2

Ngày: 2026-10-09 — **USER APPROVED DIRECTION**, numeric content tuning that is not pre-locked remains **PILOT, NOT FULL BALANCE LOCK**.

## 1. 16 chỉ số nền vẫn là 16

Không đổi 16 chỉ số **toàn cục** (gồm Hút Máu và Giảm Hút Máu) + 10 kháng nguyên tố. Những năng lực sau là **kênh phụ có điều kiện hoặc sự kiện**, không phải thêm hàng chục chỉ số bẩm sinh, không tự cuộn lúc sinh.

| Kênh V2 | Nguồn | Hệ áp dụng | Mức sẵn sàng |
|---|---|---|---|
| `damage_vs_boss` | % cộng cùng kênh | Chỉ đòn sát thương hợp lệ lên quái có **tier boss** | Có resolver thử nghiệm DV2-02 |
| `damage_vs_elite` | % cộng cùng kênh | Chỉ đòn lên tier elite, không đồng thời tier boss | Có resolver thử nghiệm DV2-02 |
| `damage_vs_race/<race_id>` | % cộng cùng kênh | Chỉ đúng chủng tộc của mục tiêu, không cộng tất cả chủng tộc | Có resolver thử nghiệm DV2-02 |
| `basic_followup_chance` | cộng điểm % | Đòn đánh thường hợp lệ có cơ hội thêm **một** đòn | Có resolver thử nghiệm DV2-02 |
| `basic_followup_damage` | cộng % hệ số riêng | Đòn liên kích thêm, tính trên cơ sở **60% lực đòn đánh thường** (tạm thử cân bằng) | Có resolver thử nghiệm DV2-02 |
| `damage_vs_shield` | % | Sát thương đối với lớp Hộ Thuẫn, không nhân HP damage | **FUTURE: shield owner** |
| `execute_low_hp` | trigger/skill tag | Kỹ năng kích hoạt khi mục tiêu thấp HP, không nhân hết damage toàn game | **FUTURE: skill owner** |
| `control_vs_boss` | rule/soften | Boss có cơ chế kháng/giảm thời gian hard-CC; Băng dùng Hàn Trệ theo spec | **FUTURE: status/tier owner** |
| `monster_break` / `poise` | thuộc tính quái/hiệu ứng tích lũy | Phá thế/gián đoạn kỹ năng đặc biệt | **FUTURE: skill cast owner** |
| `damage_vs_summon` | % | Chỉ đánh đơn vị triệu hồi có actor thật | **FUTURE: summon owner** |
| `injury_pressure`, `retreat_opportunity` | luật event | Thương Thế/thoát hiểm, không phải damage trực tiếp | **FUTURE: injury/AI owner** |
| `race_ward/<race_id>` | giảm damage nhận từ chủng tộc | Phòng vệ ngữ cảnh không đồng nghĩa Giảm Sát Thương toàn cục | **FUTURE: source/filter owner** |

**Không thêm cùng lúc:** mana, hit/dodge, knockback vĩnh viễn, 7 loại penetration giống nhau, boss-damage nhân liên tiếp vô hạn, thủ lĩnh bị khống chế cứng liên tục.

## 2. Điều kiện cân bằng bắt buộc

1. Tier là **một nhãn** `normal | elite | boss`. Một con boss KHÔNG đồng thời là elite để hưởng hai bonus.
2. Mục tiêu chỉ có **một primary race_id** cho bộ bonus chủng tộc phổ thông, không được đánh dấu mọi họ hàng để ăn buff nhiều lần. Có thể có `tags` phụ cho kỹ năng đặc biệt về sau.
3. Bonus cùng nhánh bối cảnh được **cộng trong một nhóm**: ví dụ +15% boss và +10% đúng race = `1 + 0.15 + 0.10 = 1.25`, **không** `1.15×1.10`. Dùng một nhóm trong một damage packet, không tự lặp trên từng mảnh đòn.
4. Có thể author một thanh kiếm sát thương thủ lĩnh, nhưng phải qua `source_id`, `channel`, `condition` hợp lệ; nguồn chưa mở `enabled=false`; target tags cần có thật.
5. Liên kích **chỉ từ đòn đánh thường chính** sau khi đòn chính trúng và đối thủ còn HP; tối đa **một đòn thêm**, không tự sinh liên kích khác. Đây KHÔNG phải skill echo và không kích hoạt lại các trigger kích hoạt theo đòn/kill/proc chỉ vì thêm hit. Đòn liên kích không mặc định bạo kích, hút máu, phản đòn hoặc kích hoạt quái kỹ năng đặc biệt (các tương tác này phải có luật rõ riêng sau).
6. Liên kích: xác suất độc lập theo **mỗi lượt đánh thường gốc**, không roll mỗi khung hình; bonus chance cùng kênh cộng điểm phần trăm, clamp **xác suất** về [0, 1], không hard-cap số điểm nguồn Lục Duy.
7. Hệ số 60% cho đòn thêm **pilot V1 để có test**, chưa được user duyệt khóa cân bằng; không tự tăng khi lên Nhân/Tiên/Thần trừ khi skill/equipment thực sự cấp.
8. Hiệu ứng có điều kiện không được đưa thẳng vào `CombatStatsV2.derive` như cộng Công toàn cục. Áp vào đúng một damage packet qua bối cảnh `target.tier`, `target.race_id`, `attack_kind`.
9. Không hiện các kênh FUTURE như đã kích hoạt; không biến danh mục thành 100 chỉ số nhìn vào không hiểu.

## 3. Quái V2 — schema gốc

```text
species_id (stable) + name + race_id + primary_element + tags
tier: normal / elite / boss
base profile: HP/ATK/DEF factor + optional elemental-resistance sources
spawn context: realm 1..30, floor 1..10, region/pool/time/rarity
combat runtime: current HP, derived Max HP/ATK/DEF, skill ids, AI behavior ID
loot authority: real recipe/material/reward table; idempotent defeat event
history: unique-boss kill / encounter id / personal kill provenance
```

- **Một actor monster thực** sở hữu HP hiện tại và sheet stat, không có một `power` quyết định sát thương.
- Quái KHÔNG có 6 thuộc tính đệ tử, Đan Điền, thanh Tu Vi, Luyện Thể hoặc nghề. Dùng cùng hệ tính **damage packet và hiệu ứng** với đệ tử, nhưng nguồn sinh stat là **monster-specific authored species+map scaling**, không giả mạo đệ tử tu hai đường.
- **Monster tiers:** normal hoạt động theo bầy và nhịp chiến đấu nhỏ, elite có 1–2 biến thể kỹ năng, boss có kỹ năng cảnh báo/phases/tier hard-control. Tất cả dùng **chung CombatStatsV2/skill primitives**, không xây `MonsterAbilityEngine` thứ hai.
- **Sản xuất/kinh tế:** chỉ đưa vật phẩm có sẵn vào kho sau kill event thật; hàng chưa khai báo không tự drop hoặc tạo vật phẩm ảo.
- Quái nguyên bản cũ `truc_thu`, `thanh_lang`, `hac_lang` có V2 species_id đối ứng; P0/P3.7 `P0Content.MONSTERS` và region monster weights KHÔNG bị thay khi phase V2 monster chưa gated.

## 4. Mô hình tăng chỉ số QUÁI — pilot chưa khóa cân bằng

Để **test stat thật** với một con quái V2, dùng cùng thang major/floor `G(r,f)=1.65^(r−1)×1.03^(f−1)` (đã khóa cho người chơi), nhân species-specific baseline và tier multiplier dành riêng cho quái:

```text
Monster HP = 190 × G(r,f) × species.hp_factor × tier.hp_factor
Monster ATK = 23 × G(r,f) × species.attack_factor × tier.attack_factor
Monster DEF = 19 × G(r,f) × species.defense_factor × tier.defense_factor
```

Pilot tier multipliers (để test, KHÔNG user-locked):
- **normal:** HP ×1,00; Công ×1,00; Thủ ×1,00;
- **elite:** HP ×1,80; Công ×1,25; Thủ ×1,20;
- **boss:** HP ×4,00; Công ×1,60; Thủ ×1,35.

Species factors theo từng quái được author, *không gacha mỗi lần đánh*. Map tier phải rõ, không nhân vô hạn damage boss ở nhiều tầng. Ngoại lệ boss theo chapter sau này dùng encounter author riêng; không làm loãng cả thang 30 đại cảnh.

## 5. Khung nội dung ban đầu

| species_id | Tên | race_id | tier | Element | Chức năng |
|---|---|---|---|---|---|
| `truc_thu` | Trúc Thử | `yeu_thu` | normal | Mộc | dễ đánh, có thể chạy trốn |
| `thanh_lang` | Thanh Lang | `yeu_thu` | normal | Mộc | thú săn theo bầy |
| `hac_lang` | Hắc Lang | `yeu_thu` | normal | U Minh | thú hung dữ hơn |
| `nham_giap_thu` | Nham Giáp Thú | `yeu_thu` | elite | Thổ | trâu, ưu tiên đánh gần |
| `u_hon` | U Hồn | `quy_toc` | normal | U Minh | ưu tiên debuff/status sau này |
| `huyet_lang_dau_dan` | Huyết Lang Đầu Đàn | `yeu_thu` | elite | Hỏa | đợt chiến đấu tinh anh |
| `hac_lang_vuong` | Hắc Lang Vương | `yeu_thu` | boss | U Minh | boss khu vực, phase và skill cảnh báo về sau |

Các tên mới chưa được gán loot khi item registry chưa có. Đây là **pilot catalogue cho DV2-02**; không tự thay lịch sử 3 monster P0.

## 6. Cổng kiểm thử

1. Một con boss có `race_id=yeu_thu` nhận bonus boss + bonus đúng race **một lần**, không nhận elite; quái `quy_toc` không ăn bonus `yeu_thu`.
2. Liên kích khi attack_kind=basic và roll thành công; attack_kind=skill không liên kích; extra hit không gọi lại proc; boss HP damage thực và overkill được xử lý đúng.
3. Actor quái sinh `HP/ATK/DEF` thật trên thang 1..30/1..10, hữu hạn, không đọc `P0Content.MONSTERS.power`.
4. Một đòn V2 giữa đệ tử và quái thật dùng cùng `CombatStatsV2.resolve_direct_hit`, không có universal `combat_power` damage.
5. Spawn/PvE legacy data và loot registry cũ vẫn chạy đúng khi V2 không được bật; không fake full migration.
6. Focused Godot 4.7.2 CI rồi full cumulative nếu chuyển quyền PvE. `CURRENT_CHECKPOINT.md` là authority duy nhất cho trạng thái.
