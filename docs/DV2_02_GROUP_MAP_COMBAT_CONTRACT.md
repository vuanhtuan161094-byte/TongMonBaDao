# DV2-02D — Quần công trên map: hợp đồng chiến đấu và cân bằng quái/đệ tử

Ngày: 2026-10-09. **USER DIRECTION: đa đệ tử đấu đa quái trên MAP THẬT**, không phải PvE 1v1 giả, không tự chỉnh số quái theo sức mạnh người chơi sau khi spawn.

## 1. Luật đã khóa và ràng buộc có sẵn

- `docs/COMBAT_SKILLS_V2_SPEC.md` §11–15, §27–31: 6 đệ tử/đội, tối đa **30 đệ tử/cụm đi săn**, chọn mục tiêu deterministic, cận/trung/viễn/hậu tuyến, AoE rõ vùng & max targets, không friendly fire, support có contribution, 0 HP = **Bị Hạ** (không chết vĩnh viễn), quái dùng shared combat primitives.
- `docs/P3_2_MODULAR_ACTOR_SPEC.md` & `docs/P3_UX_MAIN_MAP.md`: map visual 1280×720; 2D rig/sprite chỉ trình diễn theo vị trí/diễn biến trong **simulation**; camera không được thay outcome. NPC ngoài map không cần frame-polling. Chỉ trận **đang có thật** mới tạo combat actors.
- `CombatStatsV2` nắm 16 chỉ số + 10 kháng hệ và damage packet; `MonsterCatalogueV2` giữ quái với `race_id`, `tier`, `stats`. `CombatContextEffectsV2` thưởng đánh Boss/Race, liên kích 1 lần.
- Lớp map-battle không được thay luật canh tác/Thể Lực Viễn Chinh (chỉ tốn khi đi map ngoài, không tốn công tác nội tông), không bỏ `combat_power` cũ một cách làm P0 gãy.

## 2. Mô hình thực hiện — nhóm đấu nhóm

**Điểm quan trọng:** một `encounter_id` có **nhiều actor** cả hai phía; không lặp một hàm 1v1 độc lập.

```text
Outside Region Map (tọa độ thế giới 2D)
       |
       +-- Tổ đội người 1: ≤ 6 (Cận chiến / Thể Tu / Pháp Tu / Hỗ Trợ)
       +-- [Tổ đội người khác nếu chung encounter]: tổng ≤ 30
       |
       +-- Cụm quái: quái thường, tinh anh, thủ lĩnh
       |
       +-- Map Battle Session (server/simulation authority)
              - live actor positions, facing/role, range/movement, real HP, targeting
              - 0.25s step only when encounter active
              - skill/basic interval/cast/area targets/telegraph/status/guard/heal
              - event journal: move, target, cast, damage, lifesteal, heal, downed, retreat, victory
              - map scene listens to events and renders animations; camera/view off does NOT reroll
```

- Giai đoạn này thử nghiệm một arena **tọa độ local map** `(0..36, 0..20)` là tọa độ logic, không phải pixel UI. Tọa độ ấy được adapter sang map Godot ở bước scene presentation; không dựng trận chiến ở popup giả.
- Mục tiêu tự chọn **kẻ địch gần nhất**, hòa theo ID. Có threat/taunt nếu sau này có `ThreatSystem` thật; pilot vai tanker giữ tuyến bằng vị trí, không tạo +1000 aggro giả.
- Quái cũng chọn mục tiêu từ **mọi đệ tử đang còn đánh**, không ép mỗi quái ghép một người. Có thể hội đồng 1 người, nhưng tránh dồn sát thương vô lý bằng giới hạn body blocking/phân vai ở thiết kế hoàn chỉnh.
- Role cận chiến/viễn trình/hỗ trợ: dùng range và movement; hỗ trợ sẽ tìm người mất HP thật để chữa; AoE đánh **nhiều mục tiêu** theo tâm/nhỏ nhất ID nếu cùng khoảng cách, có giới hạn 3.
- Một hành động được xử lý **một lần** trên tick hợp lệ; cool-down và interval độc lập; không tự kích hoạt hàng chục đòn từ cùng một frame.
- Kỹ năng elite và boss sử dụng chung `CombatStatsV2.resolve_direct_hit` / event queue, **không làm MonsterAbilityEngine thứ hai**. Boss có cast cảnh báo vị trí/tâm/độ trễ trước AoE; **quái đứng trong phạm vi lúc cast hoàn tất mới trúng**, không có damage instant xuyên map.
- Bị Hạ ngừng mọi hành động, không được heal thường hồi sinh; phần thưởng/contribution support về sau dùng journal. Khi thua/rút lui, không tạo chết vĩnh viễn.

## 3. Cân bằng quái và đệ tử: KHÔNG chia 1v1 để cân

**Cân bằng là một bài toán đội hình:** 1 tanker + 2 đánh + 1 hỗ trợ khác 4 dps; 4 dps không nhất thiết thắng mọi trận.

Dùng cả thời gian/hạ gục/HP sống sót cho các kiểm thử 100 seed, không chỉ nhìn HP/ATK:

- **Thời gian trận quái thường pilot:** khoảng 12–40 giây khi nhóm chuẩn cùng cấp và số quái phù hợp; không ép cố định theo thời gian, đây chỉ là khoảng benchmark thử.
- **Số thành viên bị hạ:** đội cân đối cùng cấp nên thường đủ sức vượt quái thường; nhóm quá yếu vẫn thất bại; Boss phải cần vị trí/chọn mục tiêu và AoE, không chỉ lấy HP nhân 10.
- **Tổ đội hỗn hợp thắng bền hơn** so với dồn 100% DPS khi kéo dài chiến đấu; vai healer không phải decoration.
- **DPS hiệu dụng** `Σ(công × skill ratio × DEF factor × targeting uptime / action interval)`; **EHP nhóm** `Σ HP theo DEF/DR + lượng heal hiệu dụng/tồn tại`. Boss và quái có EHP/DPS theo đội/điều kiện map.
- **Ngưỡng quái** lấy từ khu vực/độ khó nội dung và stage, không đọc power của người chơi rồi "cân tay" bí mật. Cảnh báo độ khó hiển thị theo đánh giá dự tính `đội mạnh/đội yếu`, không tự bẻ thông số quái sau spawn.
- **Điều kiện test cân:** (a) đội 2–3 vs quái thường 2–4; (b) đội 4–6 vs 4–7 quái; (c) 1 elite + quái thường; (d) boss + hộ vệ; (e) nhóm thiếu tank/heal; (f) nhóm chênh cấp; (g) 2 tổ đội hợp tác; (h) tối đa 30 đệ tử.
- **Tuyệt đối không tự đặt các tỷ lệ thắng làm luật game** chỉ từ bộ thử; phải có báo cáo benchmark đủ ngữ cảnh và điều chỉnh numbers khi thấy combat chạy.

## 4. DV2-02D ranh giới implement

**Thực hiện trong slice:** pure deterministic map-battle multi-actor simulation; tọa độ thật trong state, target selection, movement, basic, AoE có cap, heal, boss telegraph, downed, battle trace/event, no duplicate strike, grouped DPS/HP. Dùng sản phẩm của `CombatStatsV2` và `MonsterCatalogueV2`.

**Chưa gọi hoàn thành:** Godot visual sprites chuyển động thật trên camera map, map placement tương ứng prefab, quái đi lại ngoài combat/sinh tự nhiên, rewards, save/reload mid-battle, PvE scheduler migration, skill loadout thật 4 slot, full Boss phase. Chúng thuộc chính DV2-02 để làm sau hoặc phải thiết kế giao tiếp rõ; không gọi implemented vì chỉ đặt tên/metadata.

## 5. Test gates

1. 3v4 và 6v7 là **một encounter**; đệ tử và quái có tọa độ/move event.
2. Mỗi đòn có target đang sống/trong tầm; AoE tối đa 3, đúng radius, không friendly fire.
3. Hồi máu chỉ phục hồi ally sống + có mất máu thật; Bị Hạ không hồi bằng heal.
4. Boss telegraph tạo event rồi mới gây damage theo điều kiện phạm vi tại thời điểm xảy ra; target ra khỏi phạm vi an toàn.
5. Cùng seed/đội hình/quái/map điều kiện → cùng kết quả/event snapshot dù `viewed_map=true/false`; không phụ thuộc FPS.
6. Cùng danh sách đệ tử đảo thứ tự đầu vào → cùng thứ tự/hành vi theo stable ID và tọa độ; no double action.
7. Benchmark nhiều tổ đội cấp tương đương và bất cân bằng, báo winrate/TTK/downed/HP survive; số pilot chưa cố định khi chưa benchmark.
8. P3.7 cũ vẫn PASS, không bị thay simulator từ trạng thái `COMBAT` cũ trước khi adapter được gated.
