# TÔNG MÔN BÁ ĐẠO — BÀN GIAO CHAT MỚI: NGHIÊN CỨU BACKEND SONG SONG SOURCE A

**Ngày:** 2026-10-21 (Asia/Bangkok).  
**Loại:** Kế hoạch nghiên cứu + quy tắc phối hợp + prompt chuyển chat.  
**Trạng thái:** DESIGN / READ-ONLY AUDIT. Chưa sửa code, chưa chạy Godot, chưa nghiệm thu một tính năng nào mới theo file này.  
**Dự án:** `vuanhtuan161094-byte/TongMonBaDao` — Godot **4.7.2**, Android landscape **1280×720**.  
**Quyết định mỹ thuật mới nhất của chủ dự án:** **GIỮ SOURCE A CHIBI**; không chuyển pixel; không thay gameplay bằng JX1. Combat V2 tiếp tục là numeric/authoritative core. Skill/VFX JX1 đã có vẫn giữ, có thể làm thư viện chọn lọc.

## 0. Nhiệm vụ của chat mới và ranh giới với Codex

Chủ dự án đã giao **Codex** xử lý `CODEX_TMB_SOURCE_A_COMBAT_V5_P0_P2_2026-10-21.md`: rà soát ứng dụng, kiểm tra Source A trên E:, clip attack/hit/dead, skin/attachment, asset Godot-ready, visual pilot và focused QA trên Windows khi đủ điều kiện.

**Chat mới nghiên cứu BACKEND**, không làm việc chồng lên Codex. Trọng tâm: Combat V2 simulation, hệ skill/AI, săn quái và loot, sản xuất/kinh tế, quản lý đệ tử, lưu/khôi phục/offline, scale 1.000–3.000 đệ tử, test contracts, source-code gap audit.

**Trong giai đoạn đang chạy Codex:** chỉ READ-ONLY GitHub + phân tích spec/code/test + tài liệu/đề xuất. KHÔNG sửa, commit, rebase, PR, merge, đụng file E: của máy người dùng hoặc Godot runtime trừ khi chủ dự án **ủy quyền một packet CODE riêng** và chứng minh không xung đột một-writer-per-subsystem. Không lấy kế hoạch này làm quyền tự sửa balance/gameplay.

## 1. Hiện trạng repository đã xác minh trong lần rà soát 21/10

- `main`: `461caca1171462e0da092f21108c5c1733157ad9` — nền cũ, **không phải build tích hợp mới nhất**.
- `work/playfirst-demo-max-v3-20261020`: `aad7cec147e5df587ab13614e1c9ef2ac752a8d7` — điểm kiểm toán kỹ thuật đầu tiên; lịch sử GitHub cho thấy **ahead main 478 commits, behind 0; ahead G1 PR20 60 commits, behind 0** tại lúc so sánh. Không suy ra mọi chức năng đã được merge/owner duyệt.
- `g1-disciple-radar-sourcea-pool-20261017`: `2219535fc3519ce811265ceed5cb85001efe5e45`; draft PR #20; stacked trên PR #19.
- `tools/af-jx1-player-forge-20261020`: `4dcb2daf01e6a14971b32131b7b69d7c67ae563f`, công cụ asset độc lập.
- Có 19 PR mở tại thời điểm rà soát, hầu hết là draft và được xếp chồng; **không tự merge**.
- `CURRENT_CHECKPOINT.md` và `NEXT_CHAT_HANDOFF.md` trên nhánh DEMO chứa các đính chính và lịch sử rất dài. Luôn đọc **phần mới nhất ở đầu**, không dùng dòng lịch sử bị superseded để quyết định.
- Trên nhánh DEMO đã có source-backed MAP25/G1 actor Art, backend V2, pilot skill JX1 và nhánh JXQY2. Windows Godot 4.7.2 có focused PASS cho một số lát cắt và ảnh thật, **owner visual acceptance / Android performance còn PENDING**. Đừng biến QA của lát cắt thành chứng nhận toàn bộ game.

### File backend nên mở theo thứ tự

1. `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`.
2. `docs/DISCIPLE_MASTER_SCHEMA.md`, `docs/COMBAT_STATS_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/DV2_02_GROUP_MAP_COMBAT_CONTRACT.md`.
3. `docs/C4_ACCURACY_EVASION_MOVEMENT_SKILL_REACTION_DESIGN_2026-10-19.md`, `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`.
4. `docs/ECONOMY_V2_INTEGRATION_RESEARCH_AND_BALANCE_2026-10-16.md`, `docs/DV2_PRODUCTION_RESULT_CONTRACT_V1.md`, `docs/G2_PLAYABLE_CORE_LOOP_PLAN_2026-10-17.md`.
5. `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`, `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`, `docs/QA_DEBT_MASTER_AND_BACKEND_REDESIGN_HANDOFF_2026-10-13.md`.

### Vị trí code chính cần kiểm toán (ưu tiên không lặp khối lượng tùy tiện)

```text
godot/src/simulation/combat/{combat_stats_v2.gd,combat_skill_system.gd,disciple_combat_loadout_v2.gd,map_battle_v2.gd,map_battle_snapshot_v2.gd,hunting_map_v2.gd,hunting_pve_run_v2.gd,monster_catalogue_v2.gd,combat_world_grid_v2.gd}
godot/src/simulation/building/production_plan_registry.gd
godot/src/simulation/core/simulation_scheduler.gd
godot/src/simulation/resource/warehouse_system.gd
godot/src/simulation/workforce/{workforce_system.gd,profession_modifier_system.gd}
godot/src/simulation/save/save_service.gd
godot/src/simulation/ [discover paths of BuildingSystem, EconomySystem, RecruitmentSystem, InjuryService, EquipmentSystem]
```

Không đoán file chưa kiểm chứng tồn tại; dùng GitHub tree/search để tìm thực tế.

## 2. Quy tắc LOCK không được vô tình thay đổi

| Nền tảng | Bảo toàn |
|---|---|
| Combat | Combat V2 tính toán sát thương, bạo kích, phòng thủ, RNG, hiệu lực skill, reward; cảnh hiển thị/camera không ảnh hưởng outcome |
| Tu luyện | 30 cảnh giới Tu Vi × 10 tầng, 30 cảnh giới Luyện Thể × 10 tầng; không tạo level nhân vật mới |
| Đội hình | Tối đa **6 đệ tử/đội**, tối đa **30 đệ tử/cụm**. Tài liệu P3.7 lịch sử có ghi 5; quy tắc Combat V2 mới hơn có quyền ưu tiên |
| Skill | 1 Thường Kỹ + 4 Active + 6 Combat Passive ở loadout trưởng thành; phải học/được sở hữu/trang bị hợp lệ; 3 thế hệ Nhân–Tiên–Thần; không tặng skill vì chọn phe/phái |
| Đệ tử và việc làm | **One Active Job**; đệ tử không đồng thời làm công trình và săn; Injury 0/1/120 tick đang có hiệu lực. Concept Thương Thế 0–100 trong tài liệu cũ không tự triển khai |
| Time | Scheduler chính thức **1 tick = 1 phút** cho sản xuất; combat step hiện **0,25 giây**; tốc độ chạy, basic attack, cast, cooldown, work speed là các miền khác nhau |
| Kho / kinh tế | Một Warehouse canonical; transaction và receipt; không cấp vật phẩm hai lần, không xáo sổ sau save/offline; không tạo kho UI thứ hai |
| Thời gian ngoại tuyến | Exactly-once reward, idempotency, replay/restore; kiểm offscreen/onscreen cùng authority |
| Gameplay / presentation | Visual không tự quyết định AI, damage, mastery, RNG, inventory, construction, reward |
| PR / QA | Focused gates theo exact SHA; không CI/FULL/merge, không tuyên bố Android PASS bằng test Windows; owner UX chỉ PASS khi duyệt |

**Cần lưu ý:** `COMBAT_STATS_V2_SPEC.md` có owner override 19/10: tương lai bổ sung **Accuracy/Evasion** (18 primary stats). Nhưng **live runtime hiện 16 primary stats**, chưa có roll né thông thường. Hãy đánh dấu MISMATCH / DESIGN REQUESTED; đừng lén sửa công thức, save/RNG hay in chữ MISS khi chưa có event.

## 3. Danh sách công việc có thể làm ngay — ưu tiên giá trị sản phẩm

### B0 — Backend Truth Map: bắt đầu ngay (READ-ONLY)

- Lập bảng `Feature / Spec / Code / Tests / SHA / Real QA / Gaps / Side Effects / Owner decision` cho 7 tuyến: tuyển dụng, tu luyện, sản xuất, kho, kinh tế/tiêu dùng, săn/chiến đấu, lưu/offline.
- Đọc GitHub HEAD mới nhất, truy đến owner thật (caller, consumer, state, serializer), tránh kết luận từ class name hoặc spec.
- Vẽ một sơ đồ `Sect → Recruit → Assign → Mine/Forest/Field → Warehouse → Spend/Upgrade/Alchemy/Equipment → Party Hunt → Loot → Return/Heal → Save/Offline` với **mỗi node thật**.
- Chỉ ra khi nào player có thể chơi vòng lặp hoàn chỉnh, khi nào phải qua sandbox, và điểm gãy thực tế. Không sinh ra 'todo' giả ở phần code đã làm.
- Output: `BACKEND_TRUTH_MATRIX.md`, `CODE_OWNERSHIP_MAP.md`, danh sách 10 lỗi/thiếu có ảnh hưởng người chơi nhất. Không code.

### B1 — Combat V2 / Skill / AI (READ-ONLY DESIGN)

- Đối chiếu event pipeline: chọn mục tiêu deterministic, khoảng cách, movement speed, basic/active slot, cast/commit/projectile/impact, AoE, debuff, downed, retreat, respawn, reward.
- Xác minh 5 skill JX pilot là opt-in test consumer, tách khỏi gameplay skill đã được học/trang bị. Không nhân bản hệ skill và không thay JX ID.
- Đối chiếu spec Kiếm/Thể/Pháp, Ngũ Hành, Linh Căn, Tương Sinh, AoE/caps và threat/survival AI: tính năng nào có code thật và 1 ví dụ end-to-end, tính năng nào chỉ tên trong master spec.
- Nêu riêng accuracy/evasion và learned dodge skill migration (18 stats, new RNG roll, existing seed snapshots): lập risk matrix + migration tests, **không đề nghị tự code ngay**.
- Khả năng multi-party 6×5, 30v40: target tie-break, cache/pathfinding CPU, buff party scope, cooldown queue, event ordering, offscreen equivalence, boss warning/AI.
- Kết quả: `COMBAT_V2_BACKEND_GAP_AUDIT.md`, `SKILL_EVENT_CONTRACT.md`, `AI_AND_DODGE_DESIGN_OPEN_DECISIONS.md`, không thay balance.

### B2 — Sản xuất / Economy V2 / tuyến tiêu dùng (READ-ONLY DESIGN)

- Kiểm tra pipeline Mỏ/Linh Lâm/Linh Điền: worker eligible → reserve → start → duration → completed/awaiting settlement → single Warehouse receipt → profession EXP → UI read; interrupt/reassign/job conflicts.
- Audit tên instance thật, nhiều công trình cùng loại, Field plot, scheduler tick=1 phút và offline chunking; điều kiện exactly-once dưới save/restore + interrupted work.
- Phân biệt **work speed** (thời gian), **yield** (sản lượng/lượt), **rare** (random independent). Không cộng nhầm bonus, không 'nhân đôi' ở UI.
- Pilot Economy V2 từng chốt sản lượng cao và curve lv1..100: không tự đổi công thức. Kiểm **hiện diện code** tại `production_plan_registry.gd`, không lấy bản spec 2026-10-05 làm final khi bị spec 2026-10-16 supersede.
- Audit tuyến **consumption**: warehouse → nâng cấp công trình / luyện đan / luyện khí / thị trường / sửa chữa / săn và hậu cần. Chỉ rõ sink thật và sink design-only. Đối chiếu tài chính lương/chi tiêu nếu đã triển khai.
- Kết quả: `ECONOMY_V2_RESOURCE_FLOW_AUDIT.md`, `PRODUCTION_EDGE_CASE_MATRIX.md`, `G2_LOOP_CONSUMPTION_GAPS.md`, không sửa kho/scheduler/save.

### B3 — Save/Offline/Exactly-once + One Active Job (READ-ONLY CONTRACT)

- Xây ma trận sự kiện có thể xảy ra quanh save: tick đúng lúc batch settle, offline return, crash trước/giữa/sau warehouse commit, snapshot giữa projectile, reward claim duplicate, multiple actors/jobs reassign.
- Kiểm version snapshot/backward compatibility, RNG state và event order; đề xuất *invariant/property tests* ưu tiên, không chạy CI/FULL.
- Kiểm boundary One Active Job giữa WorkforceSystem, PvE, cultivation, Spirit Field, Alchemy và Injury; tái sử dụng lỗi lịch sử làm fixture test chứ không sửa luật tùy tiện.
- Kết quả: `SAVE_OFFLINE_EXACTLY_ONCE_REVIEW.md`, `STATE_INVARIANTS_TEST_PLAN.md`.

### B4 — Scale & performance simulation (READ-ONLY)

- Phân tích mục tiêu 1.000–3.000 đệ tử, 30 đệ tử + 40 quái; xử lý theo event queue thay vì `actor × skill × frame` polling.
- Xem vòng lặp per-tick/time complexity, caching snapshot, scheduler, warehouse receipts, pathfinding, save size; đề xuất cách đo time/memory có baseline.
- Tách **backend CPU/time**, **asset decode**, **render FPS/VRAM**, **launcher import time**; không đồng nhất lag do 8GB RAM và Godot rendering.
- Kết quả: `SIMULATION_SCALE_DESIGN.md`, benchmark plan với exact-SHA / save cách ly. Không mặc định đạt 30/60 FPS.

### B5 — Đánh giá tiến độ tính năng còn thiếu và roadmap độc lập

- Map status `IMPLEMENTED`, `TESTED FOCUSED`, `OWNER VISUAL PENDING`, `DESIGN ONLY`, `BLOCKED`; ưu tiên gameplay loop trước mở rộng tính năng.
- Phân chia packet CODE độc lập **chờ owner cấp phép riêng**: ví dụ bổ sung focused regressions cho vùng không bị Codex chạm; đọc-only economic balancing spreadsheet; thiết kế kế hoạch skill mapping; kiểm khoảng trống logistics/AI; không tự triển khai khi chưa có GO.
- Đối chiếu `docs/G2_PLAYABLE_CORE_LOOP_PLAN_2026-10-17.md`: “xây thêm công trình/mở đất” từng mới là preview, thiếu transaction pháp lý; không tự coi hoàn tất vì có GUI mock.

## 4. Cách làm từng phiên chat — tránh tạo 30 tài liệu không dùng

**Buổi 1 (khuyến nghị):** Audit truth matrix Combat / Production / Save dựa trên code HEAD mới nhất. Trả bảng 8–12 feature có chứng cứ và **3 blockers quan trọng nhất**. Không cần thẩm tra toàn bộ kho trong một lượt.

**Buổi 2:** Combat backend sâu: 1 normal combat trace và 1 Boss AoE trace; skill legality + targeting + combat state → snapshot/replay. Chỉ nghiên cứu; chọn 1 packet CODE sau khi người dùng duyệt.

**Buổi 3:** Sản xuất/kinh tế sâu: Mỏ/Linh Lâm/Linh Điền → kho → sử dụng/upgrade → offline exactly-once. Nếu cần minh họa balance, cung cấp kịch bản 60/90/180 phút, không đổi số liệu.

**Buổi 4:** Save/offline/performance: race conditions, 1k–3k disciples và offscreen equivalence; thiết kế test matrix và budget.

**Buổi 5:** Kết luận roadmap backend và hợp đồng tích hợp với visual pilot Source A khi Codex trả kết quả.

Phân tích từng nhóm theo chuỗi **vấn đề → code hiện có → bằng chứng → rủi ro → đề xuất → packet kiểm thử**; không lặp lại toàn bộ spec hoặc bốc hạng mục đã xong lên làm lại. Ưu tiên đầu ra gọn, có giá trị quyết định, và cập nhật một file tổng sống nếu chủ dự án muốn lưu trong repo.

## 5. Ranh giới phối hợp / tránh conflict với Codex

| Vùng mã / tài sản | Codex Source A V5 | Chat backend mới |
|---|---|---|
| `godot/assets/actors`, Source A, Spine converter, atlas, scenes, combat presentation | **Owner of pending execution** | Chỉ đọc / nêu contract cần adapter |
| `godot/src/presentation/p3/*`, map, VFX, player UX | **Owner of pending execution** | Không sửa |
| `godot/src/simulation/combat/*`, combat authority / RNG / skill consumers | Codex **không được sửa** theo prompt trừ packet riêng | Chỉ nghiên cứu, đề xuất/gate CODE riêng |
| `simulation_scheduler.gd`, `warehouse_system.gd`, `save_service.gd`, `workforce_system.gd` | Ngoài phạm vi visual | Chỉ nghiên cứu, không sửa khi Codex đang làm |
| `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md` | Codex có thể ghi sau packet authorized | Chat mới chỉ ghi tài liệu **ngoài repo** khi nghiên cứu; không cạnh tranh commit |
| G1 production display | Codex có thể kiểm status hiện tại | Chat backend không đổi UX |

Trước **bất kỳ** packet CODE tương lai, fetch new HEAD và worktree, so git diff touched paths, một người ghi trên mỗi file, focused tests chính xác. Một lỗi backend có thể được phân tích song song, nhưng **không sửa chéo simulation khi visual pilot chưa có gói tích hợp được phê duyệt**.

## 6. Những bất nhất lịch sử cần flag, không sửa ngầm

- P3.7 long-term ghi standard hunting team 5, nhưng locked Combat Skills V2/owner chốt đội 6: **đội 6 mới là gameplay target**.
- P3.7 Thương Thế 0–100 chỉ concept cũ; current Injury 0/1/120 tick: không âm thầm tạo Injury 0–100.
- Accuracy/Evasion và skill né được chủ dự án yêu cầu thiết kế sau; current runtime vẫn 16 headline stats, không có miss roll. 18-stat migration phải có packet riêng.
- `COMBAT_SKILLS_V2_SPEC.md` ghi DESIGN LOCKED, một số pilot consumers chạy thật nhưng không đại diện cho toàn bộ cây skill Nhân/Tiên/Thần.
- Một số backend QA thuộc bản SHA cũ; không gọi PASS tại SHA mới nếu chưa chạy.
- Tài liệu cũ từng muốn dùng toàn bộ JX1 combat art, nay owner chốt **Source A là art authority**. Giữ gameplay V2 và skill/VFX chọn lọc, nhưng không dùng JX1/JXQY2 làm chuẩn mỹ thuật game chính.

## 7. Đầu ra chat mới cần giao ngay sau vòng kiểm toán đầu

Một báo cáo có tối thiểu:

1. Current branch/HEAD được kiểm thật, feature/code/test file có đường dẫn.
2. **MATRIX 7 hệ**: gameplay có thật, trạng thái test, lỗ hổng, rủi ro xung đột Codex.
3. **Top 3 blocker backend** đến bản game hấp dẫn/chơi dài hạn, có bằng chứng.
4. **Top 3 phân tích có thể làm không code** khi chờ asset.
5. Một gói CODE proposal đầu tiên nhỏ, *không tự triển khai*; nêu các file có thể sửa, invariants, focused test, tác động đến Codex và rủi ro save.
6. Một câu hỏi duy nhất chỉ nếu thiếu thông tin ngăn cản kết luận; nếu không, đưa đề xuất mặc định và làm tiếp.

## 8. PROMPT CHUYỂN CHAT — SAO CHÉP NGUYÊN VĂN

> TÔNG MÔN BÁ ĐẠO — TIẾP QUẢN NGHIÊN CỨU BACKEND SONG SONG CODEX SOURCE A. Đọc file đính kèm `TMB_BACKEND_RESEARCH_NEXT_CHAT_HANDOFF_2026-10-21.md`. Chủ dự án đã khóa mỹ thuật **Source A chibi**, không pixel, không bê JX1 thành luật combat. Codex đang thực hiện riêng P0–P2 khảo sát Source A/animation và visual pilot theo `CODEX_TMB_SOURCE_A_COMBAT_V5_P0_P2_2026-10-21.md`. Trong chat này **chỉ READ-ONLY, không sửa code/GitHub/save, không CI/FULL/merge**, không đụng thư mục làm việc của Codex. Đọc `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md` và code trên GitHub repo `vuanhtuan161094-byte/TongMonBaDao`; khởi đầu từ nhánh `work/playfirst-demo-max-v3-20261020` (HEAD đã biết `aad7cec1`, **fetch lại HEAD** trước khi phân tích), không coi `main` là bản DEMO mới nhất. Nhiệm vụ vòng đầu: **kiểm toán backend Combat V2, AI/skill/loot/hunting; Economy V2 + Mỏ/Linh Lâm/Linh Điền → Warehouse → tiêu dùng/nâng cấp; đệ tử/One Active Job; save/offline exactly-once và quy mô 1.000–3.000 đệ tử**. Xuất feature truth matrix có path/class/test/SHA/trạng thái, phân biệt thiết kế với tính năng đã code và Windows/Android QA. Chỉ ra **3 blocker quan trọng nhất**, những gì có thể nghiên cứu song song an toàn và đề xuất packet backend nhỏ nhất để tôi duyệt sau, **không triển khai packet**. Giữ 30×10 Tu Vi + Luyện Thể, đội 6/cụm 30, Injury 0/1/120, Combat V2 authority, skill loadout 1+4+6, RNG, balance, save/offline và kho canonical. Đối chiếu yêu cầu Accuracy/Evasion 18-stat chỉ là thiết kế chưa thực thi, không lén bật MISS/DODGE. Ưu tiên kiểm toán có chứng cứ hơn liệt kê tính năng tưởng tượng; bắt đầu ngay bằng B0 Backend Truth Map.

## 9. Cách sử dụng

Mở **chat mới trong cùng dự án** → đính kèm file này → dán nguyên prompt ở §8. Khi Codex Source A bàn giao, đưa báo cáo asset/ảnh/commit từ Codex vào chat mới để thiết kế điểm nối animation/VFX với **cùng event Combat V2**, không yêu cầu đổi gameplay chỉ vì hình ảnh. File này không tự tạo automation, không chiếm máy, không thực thi ngầm.
