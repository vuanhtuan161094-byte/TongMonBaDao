# Combat Lab — báo cáo kiểm định (tiếng Việt)

**Nguồn hợp đồng:** PR #72, `f8e0fb6df38172da5c79615ed3e7c2b9c0e472bf`. Head nhánh lúc bắt đầu QA là `a800c2596d416fa51f6508b4bce22a174b9f581a`; trong lúc hoàn tất, nhánh tiến lên `dbce73df82abe3744948bcf1911d83bb871c6357`. So sánh cả hai đoạn commit mới cho thấy chỉ thay presentation P3_2, test presentation, workflow/QA và runtime manifest; không sửa các authority combat mà Lab gọi. Commit Lab được đặt nối tiếp head hiện hành bằng expected-SHA lease để giữ nguyên các cập nhật mới.

**Scene:** `res://labs/combat_lab/combat_lab.tscn` — mở bằng Godot 4.7.2 rồi nhấn F6. Hướng dẫn thao tác nằm trong `README_vi.md`. Không sửa `project.godot`, main scene hay AutoLoad.

## Phạm vi chạy được

- UI 1280×720: Cung/Quyền/Độc; Nhân/Tiên/Thần; nhánh/truyền thừa; đội 1–6 đệ tử; bốn kỹ năng chủ động và một tuyệt kỹ hợp lệ; Thường/Tinh Anh/Boss; zoom 1×/2×/4×/6×; TÁI TẠO, STEP 0,25s, AUTO, HOLD.
- Trận gọi trực tiếp `MapBattleV2.step`, `CombatStatsV2` và consumer V6.3. Fixture/`DiscipleState`/`SimulationState` mới chỉ nằm trong bộ nhớ Lab. Finite encounter được cấu hình không ghi kill receipt, loot hay thưởng. Không đụng `SaveService`, save, kho hay trạng thái PvE thật.
- Stat breakdown dùng `CombatLabRosterAdapter.stat_breakdown` và effective stats hiện hữu. UI đọc pending cast/cooldown từ actor V6.3; không có consumer năng lượng hiện hữu để hiển thị.
- VFX chỉ đọc event: cast/release, impact/crit, heal/lifesteal, poison/DoT, miss/evade, AoE, Boss telegraph và death. `hit` là packet có thẩm quyền; event `v63_skill_hit` đi sau được khử trùng. Poison dùng `status_tick`; event DoT trùng dùng `damage_tick`. VFX không gọi damage/heal hoặc sửa state.
- Hình nhân vật và vũ khí là primitive placeholder tĩnh, ghi rõ LAB_ONLY; đường vẽ vũ khí tách riêng, không phải asset/rig. Không nạp C2/Source A chưa duyệt, không tuyên bố animation nhân vật đạt. Tọa độ đi bộ và thời điểm hiệu ứng lấy từ battle/event thật; engine chưa phát event attack-start cho đòn đánh thường nên không dựng pre-hit animation giả.

## Kết quả focused test

Godot official `4.7.2.stable.official.ed1daf0bf`; focused test exit 0, `failures=0`.

| Nhóm | Tổng | PASS | FAIL | NOT_TESTED |
|---|---:|---:|---:|---:|
| Toàn bộ skill ID catalog | 549 | 540 | 0 | 9 |
| Active/ultimate | 243 | 243 | 0 | 0 |
| Passive | 243 | 238 | 0 | 5 |
| Innate | 45 | 42 | 0 | 3 |
| Basic | 9 | 9 | 0 | 0 |
| Mobility | 9 | 9 | 0 | 0 |

Các probe active/ultimate gọi `try_cast` consumer thật và kiểm tra cast/release/effect/cooldown; poison action có probe tick DoT. Passive/innate dùng effective-stat/status consumer hiện hữu. Ma trận từng `skill_id` nằm ở `evidence/combat_lab_skill_matrix.csv`.

Chín ID NOT_TESTED được giữ nguyên, không giả PASS:

- `tmb.skill.fist.huyet_quyen.passive_01.divine.a` … `passive_05.divine.a`: `divine_rule_status`/modifier không có consumer runtime tương ứng.
- `tmb.skill.poison.duoc_doc.innate.human`, `.innate.immortal.a`, `.innate.divine.a`: runtime không đọc `heal_factor` từ innate ID.
- `tmb.skill.poison.duoc_doc.passive_02.human`: không có poison action cùng nhánh/generation để chứng minh consumer `poison_factor`.

Ngoài ma trận ID, test đã chạy default loadout của 9 cặp trường phái/cảnh giới; từ chối ID lạ/trùng; đội 6 đệ tử qua một tick `MapBattleV2`; phát signal HOLD/STEP/AUTO/reset/zoom thật của UI; so sánh trace hai trận cùng seed; khử VFX duplicate; kiểm tra giới hạn `MAX_EVENTS`; damage, crit, lifesteal, kháng lửa; Boss V6.3 phát telegraph; finite encounter không tạo kill/reward receipt.

## QA GUI / bằng chứng

| Kiểm tra | Kết quả |
|---|---|
| Godot official Editor import | PASS · 4.7.2 official · exit 0 |
| Script --check-only và mở scene trực tiếp headless | PASS · exit 0 |
| Focused suite 549 ID + Lab cases | PASS · exit 0 · 0 FAIL |
| Godot GUI viewport 1280×720, zoom 1×/2×/4×/6× | PASS · ảnh thật bên dưới |
| Tín hiệu HOLD/STEP/AUTO/reset/zoom | PASS · phát signal trong focused test |
| Chuột vật lý / full Windows regression / CI | PENDING · chưa chạy |

Godot Editor official import hoàn tất exit 0. Scene chạy trong Godot GUI thật ở OpenGL 3.3 Intel Iris Plus; ảnh được lấy từ viewport đang mô phỏng, không phải headless mock. Mỗi ảnh 1280×720. 2× là mức mặc định dễ đọc; ở 1× đội hình nhìn sít hơn, 6× là crop zoom có chủ ý. Tín hiệu UI được kiểm thử trong focused test; **thao tác chuột vật lý chưa được xác nhận**.

- `evidence/combat_lab_preview_1x.png`
- `evidence/combat_lab_preview_2x.png`
- `evidence/combat_lab_preview_4x.png`
- `evidence/combat_lab_preview_6x.png`

## Giới hạn / trạng thái tích hợp

- **PENDING — PvE liên tục:** `MapBattleV2` không cấp stable event ID. Lab dùng local array cursor và finite encounter; test xác nhận bridge hiện không phát hiện replacement khi `world_mode` cuộn mảng đầy. Không nối adapter này vào PvE liên tục cho tới khi có event ID/cursor authority.
- **PENDING — art/animation:** placeholder tĩnh để thử combat/UI; chưa có Source A/asset nhân vật được duyệt và không có animation Idle/Walk/Attack/Hit/Death đạt nghiệm thu.
- **DESIGN-ONLY/MISSING — khắc chế hệ số:** `CombatStatsV2` có elemental resistance; `MapBattleV2` hiện gọi matchup factor `1.0`. Không thêm bảng ngũ hành khắc chế hoặc công thức mới.
- **DESIGN-ONLY/MISSING — energy:** consumer V6.3 hiện tại không cung cấp authority năng lượng cho Lab.
- **PENDING — kiểm thử chuột/Windows thủ công và test toàn regression:** không chạy trong nhiệm vụ này; không chạy CI/FULL.

Feature gates mặc định vẫn OFF; production combat/economy/save/PvE code không được sửa. Lần chạy Godot báo warning môi trường `Failed to read the root certificate store`, nhưng import và focused test đều exit 0.
