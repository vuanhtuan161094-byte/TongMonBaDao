# DV2-02E — 5 CẤP ĐỘ CHO MỖI BẢN ĐỒ, TRANG BỊ/KỸ NĂNG THẬT VÀ TÀI NGUYÊN

Ngày 09/10/2026. **User directed implementation; balance values are PILOT, not permanent user-locked.** One active phase remains DV2-02.

## Reference
[Evil Hunter Tycoon official difficulty guide](https://evilhunter.zendesk.com/hc/en-us/articles/360039486532-Difficulty): its **8 global difficulty levels** progress with hunter reincarnations. Its item/gear progression encourages choosing a manageable hunting difficulty. **Tông Môn Bá Đạo uses 5 individually selectable levels PER MAP**, not Evil Hunter's global difficulty structure, and none of its proprietary content.

## Per-region difficulty choice, not a map rename

The canonical P0 RegionState IDs remain `thanh_truc_lam`, `bach_thach_khe`, `hac_phong_coc`; each has five levels selected as `region_id + difficulty 1..5`. **No duplicate copies of a map**, no global difficulty state, no automatically unlocking a level from headcount or reincarnations.

| Lựa chọn | Cấp | HP quái (pilot) | ATK | DEF | Số lượng/pool | Sản lượng thường | Hiếm |
|---|---|---:|---:|---:|---|---:|---|
| 1 | Ngoại Vi | ×0.75 | ×0.82 | ×0.88 | thường, nhóm nhỏ | 1.00 | mức nền |
| 2 | Thâm Nhập | ×1.00 | ×1.00 | ×1.00 | thường, nhóm chuẩn | 1.35 | tăng nhẹ |
| 3 | Hung Địa | ×1.40 | ×1.18 | ×1.12 | có Tinh Anh | 1.80 | tăng vừa |
| 4 | Hiểm Địa | ×1.95 | ×1.40 | ×1.27 | Tinh Anh + hộ vệ | 2.50 | tăng mạnh |
| 5 | Tuyệt Địa | ×2.70 | ×1.65 | ×1.45 | Boss + hộ vệ | 3.50 | cao nhất |

Các hệ số này tính **trên monster species/tier stats đã được author**, không lén tăng theo trang bị/tổ đội người chơi sau khi xuất hiện. Cảnh giới quái do khu vực và nội dung xác định, không tự sửa theo người chơi. Ngưỡng cảnh báo đội có thể dự báo, không thay đổi stat kẻ địch.

## Buff thật của đệ tử — một danh sách nguồn, không dùng combat_power

- `DiscipleState` là gốc nhân vật. Numeric V2 Core cần **Tu Vi realm/floor + Luyện Thể realm/floor thật**. Khi code lưu tiến độ V2 chưa có, chỉ nhận **tham số V2 progress truyền rõ** trong adapter thử nghiệm, **không tự suy từ cultivation_stage_index P2 để giả 300 tầng**.
- `CombatStatsV2` = 16 chỉ số + 10 kháng; lấy Core + Tiềm Lực theo công thức user đã khóa. Chỉ áp dụng các nguồn buff đã có consumer.
- **Legacy P2 Equipment bridge, chỉ những thuộc tính có nghĩa thực:** giảm sát thương `defense_reduction` -> independent `damage_reduction`; `basic_speed` -> Attack Speed rate; `move_speed` -> Move Speed rate; `basic_range`, `basic_ratio` -> chính đòn đánh thường; `skill_effect` -> chỉ áp theo skill path và element khi đánh kỹ năng. Các `combat_power` trên item P2 **KHÔNG** chuyển sang ATK V2 theo tỷ lệ tự đoán. Nếu món không có HP/ATK/DEF flat được author thì không được bịa ra. Trang bị V2 thật/đủ slot thuộc phase riêng.
- **Legacy P2 Learned Skills bridge:** kiểm tra skill đã học + `can_learn_skill` + `CombatSkillSystem.SKILLS`. Đưa skill `effect=damage` đã có quyền sử dụng vào một priority loadout, có cast time/cooldown/range/ratio thực; source path/element multiplier chỉ ở damage packet kỹ năng đó. Không cấp Hỏa Cầu burn, Hàn Sương debuff, skill defense/control nếu status consumer chưa hoàn thành. Thường kỹ vẫn mặc định khả dụng và có interval/range từ bộ style P2 khi thật sự bật.
- Combat Buff từ Traits, Bloodline, Physique, Talisman V2, công pháp/ngũ hành luôn là `source_id/channel/mode/enabled`, thuộc phase consumer chuyên biệt. Danh tính sinh ra không cộng buff. Hệ V2 nhận sẵn nguồn ngoài **đã được xác thực và sắp xếp** để thêm sau, không bắt buộc phải code hết content trước khi săn.

## Bản đồ, quái và chiến đấu

- Map chọn `region_id` và `difficulty` (1..5) trước khi chọn đội thật ≤6, cụm ≤30. Cảnh giới, phẩm cấp và nguồn quái là tĩnh theo vùng/cấp; khu 3,4,5 tăng khả năng có Elite/Boss, **không gây trận Boss 1v1**.
- Spawn đệ tử/quái trong CÙNG `MapBattleV2` với tọa độ, di chuyển, target, basic, buffs/equipment/skill actions, heal, AoE, telegraph, downed. Không tạo 5 con quái giả với từng duel riêng.
- Các ô quái mới chưa có drops hữu hiệu trong registry được đánh như quái thật nhưng **không phát thưởng vật phẩm giả**.
- Map không auto-switch độ khó. Khi người chơi chọn cấp thấp vẫn có thể thu gom vật liệu phù hợp để nâng cấp. Level 5 cao hơn về nguyên liệu/hệ số cơ hội hiếm nhưng không tự cho vật phẩm không tồn tại.
- `ResourceRegistry` là chủ danh mục item; mọi drop ID phải được khai báo và ghi 1 lần theo `encounter_id`/kill event. Trước khi warehouse + persistence logic sẵn có, `preview` không được biến thành tài nguyên thực; `finalize` chỉ sau win, chống trùng, rồi bàn giao cho Kho. Thắng không đồng nghĩa cấp drops ngẫu nhiên vô hạn.
- Thời gian, số quái/chương, nhịp respawn và tỷ lệ drop số cụ thể đều **pilot chưa khóa**; benchmark theo nhóm thực của cảnh giới 1..30 có đủ nguồn buffs.

## Gate
1. Mỗi region có đủ 5 levels, level 1..5 monster stats và tài nguyên tăng có kiểm chứng, level vượt 1..5 bị từ chối.
2. Cùng map khác difficulty có danh sách quái có thể khác, số lượng/quái Boss khác. Cấp khó không tự làm người chơi tăng chỉ số.
3. Trang bị P2 đã sở hữu (đúng owner/location) cộng duy nhất những buff hợp lệ; bỏ trang bị làm mất buff; combat_power không làm tăng ATK.
4. Learned damage skill thật được sử dụng, có cooldown/cast/time/ratio; chưa học không auto-cast; khác hướng/element đúng nguồn.
5. Same player formation, same seed, reversed input order, visible/offscreen → same battle. Full P3.7 baseline không đổi khi feature không được bật.
6. No resource overgrant from overkill/multiple click/reload; ONLY item ID existing in ResourceRegistry. No loot on defeat.
7. CI Godot 4.7.2 focused, then full cumulative on closure. **DV2-02 not closed** until map/warehouse session ownership and actor persistence/live map integration actually implemented and tested.
