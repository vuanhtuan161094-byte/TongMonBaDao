# TÔNG MÔN BÁ ĐẠO — KẾ HOẠCH VERTICAL SLICE R10→R11, R20→R21
## Chứng minh nguồn vật liệu thật → nghiên cứu bản vẽ → Luyện Khí → Kho → mặc trang bị

**Ngày:** 2026-10-25 · **DOCS-ONLY / OWNER REVIEW, NOT AN IMPLEMENTATION PACKET.** Không code, Codex packet, PR29/UI/Source A, CI/FULL, Godot, merge. Không khóa ID, thời gian, lượng vật tư, xác suất hoặc giá.
**Quyết định OWNER mới nhất:** R11 basic dùng Luyện Khí Điện Lv30; R21 basic CŨNG được dùng Lv30 khi có đúng vật liệu/bản vẽ Thần và worker/công trình hợp lệ; Lv75 chỉ dành đồ bộ/advanced và các cơ chế đặc biệt. Lựa chọn A này thay lựa chọn B “Lv75 bắt buộc mọi R21” trong tin nhắn ngay trước. Đường Mỏ/khoáng (M), lâm sản/sợi (F) và quái thường (N) của rank R phải có thể tiếp cận bằng đội đang mặc đồ R−1. Các quyết định chưa phải CODE authorization.
**Source authority:** `main@29b5fba448b0178cb520a4ada44b375b4b934e31`; đã đọc `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/REALM_LADDER_V2_SPEC.md`, `docs/WEAPON_EQUIPMENT_V2_SPEC.md`, `docs/EQUIPMENT_SETS_V2_SPEC.md`, `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md`, `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`, mã `resource_registry.gd`, `warehouse_system.gd`, `monster_catalogue_v2.gd`, `hunting_map_v2.gd`, `equipment_system.gd`, `building_system.gd`, `workforce_system.gd`, `sect_state.gd`, `save_service.gd`. Phụ thuộc hồ sơ tại `docs/gear-r10-r11-r20-r21-first-design-acceptance-20261024` và catalog `docs/forge-r11-r30-source-blueprint-economy-anti-softlock-20261024`. [CODE] đã có trong main; [LOCK] thiết kế đã khóa; [PROPOSED] ý tưởng mới chưa duyệt; [BLOCKED] chưa có runtime; [QA-NOT-RUN] test mới chưa chạy.

## 1. Hiện trạng thật, tuyệt đối không gán PASS giả
- [CODE] `ResourceRegistry` có ID `linh_moc,thanh_thiet,huyen_thiet,tinh_lang_bi,yeu_dan,linh_tuy` và vật liệu `body_gate_material`/`body_gate_seal` dùng cho Luyện Thể; **KHÔNG** có `eqv2_r11_ore/fiber/beast`, `eqv2_r21_ore/fiber/beast`. Không suy ra có sẵn Tiên Thiết/Sơ Thần Khoáng.
- [CODE] `MonsterCatalogueV2` gồm bảy species thấp, `nham_giap_thu` và `hac_lang_vuong` có `loot_ready=false`; chưa có `eqv2_mob_r11_normal` Vân Giác Lộc hay `eqv2_mob_r21_normal` Sơ Thần Thạch Nhân. `HuntingMapV2` có ba region thấp, năm difficulty **theo encounter**, không phải World V3 high-rank loot.
- [CODE] `WarehouseSystem` có ID validation, `reserve_min/locked`, tiêu thụ điều kiện; CHƯA có sổ riêng giữ vật liệu cho một lệnh R11/R21 Forge. `EquipmentSystem` là P2 ba slot `weapon/armor/talisman`, ba quality, năm recipe; **không phải** V2 mười slot/mười hai phẩm.
- [CODE] `BuildingSystem` main không có Forge V2 được thực thi như một building kind/crafting owner; mốc Lv30/Lv75 trong `EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md` là **định hướng gameplay**. `SaveService.CURRENT_VERSION=2` nhưng chưa có unique gear/archive/order journal V2.
- [LOCK] Combat V2 làm damage và death authority; một Warehouse và một clock; One Active Job; Injury0/1, hồi 120 tick; 10 ô trang bị, 24 dòng đồ bộ ×4, đúng thế hệ Nhân/Tiên/Thần. Một bản đồ Thanh Trúc Lâm đề xuất20 bãi/quái và30 đệ tử, KHÔNG phải 20 bản đồ/3000 hunter.
- [PROPOSED] `frontier_r11/frontier_r21` chỉ là nhãn nguồn/biome **chưa phải scene**; toàn bộ `eqv2_*` chỉ là candidate IDs trong tài liệu, chưa có Source A rig/loot/runtime. Không dùng vật liệu body-gate làm nguyên liệu Forge nếu chưa duyệt hai hệ thống.

## 2. Bài toán nghiệm thu nhỏ nhất
Một đội và thợ hợp lệ ở R10 (chưa có R11 gear) phải nhận được **một đơn vị M+F+N thật** từ một vùng có thể đi đến và đánh được; chứng cứ source receipt nhập Kho Sect. Một Luyện Khí worker tạo nghiên cứu bản vẽ R11 basic một lần cho Sect từ chính source; sau đó chế tạo chính xác **một món weapon R11** đã chọn qua Forge Lv30, với reserve/debit, thời gian tick thật, kết quả phẩm chốt một lần, item ID duy nhất và gear assignment cho người đủ cảnh giới. Reload phải giữ nguyên mọi receipt và state, không dupe. R20→R21 làm lại chuỗi tương ứng bằng vật liệu THẦN thật nhưng cũng có một đường Forge basic Lv30; set advanced Lv75 đứng NGOÀI lối tiến cơ bản. Không giả lập kill, UI click, FPS, map hoặc source item.
**Đồ thuộc Sect.** Nhân R10 không tính vào bộ Tiên R11; Tiên R20 không tính vào bộ Thần R21. Một item vật lý không thể được cấp phát hai lần. Thăng cảnh giới disciple không tự sinh trang bị mới.

## 3. DAG và chỗ phải chứng minh không softlock
~~~text
R10 mặc đồ R10 + Mine/Forest/Hunt worker thật
    ├─ [truy cập nguồn bằng gear R10] ─ ore R11, harvest receipt ─┐
    ├─ [truy cập nguồn bằng gear R10] ─ fiber R11, work receipt ───┤→ Warehouse
    └─ [normal mob ngoài biên, R10 có thể đánh] beast, kill receipt ┘
              + worker/forge Lv30 reachable with pre-R11 resources
                   → Sect-wide blueprint archive 1 lần (ore+beast [TRIAL])
                   → chosen weapon recipe/input reserve + real work
                   → frozen one grade → one physical item + one receipt
                   → eligible wearer/equip (old set preserved)
R20 mặc đồ R20 → frontier R21 M/F/N có thể kiếm được trước item R21
     → genuine Thần resources + basic archive → Lv30 BASIC R21 output
          (Lv75 reserved for advanced/bộ, not baseline gear gate)
~~~
**Vòng phụ thuộc nào làm cần có gear R để đi lấy R ore, cần Boss R để mở basic R, cần Lv75 chứa item R21 để tạo món R21 đầu tiên, hoặc cần blueprint R để lấy tài nguyên nghiên cứu blueprint R → BLOCKER.** Cần chứng minh đường di chuyển, quái/HP/DEF theo Combat V2, worker, công trình, nguồn sản xuất thực; không chỉ ghi tên một “frontier”.

## 4. Vertical slices tương lai — mỗi bước có input / authority / output / negative gate
| Gate | ONE narrow vertical slice (proposed) | Future observable acceptance | Negative blocker / do not cheat |
|---|---|---|---|
| **S0 Save baseline** | Chụp fixture legacy P2/P3.7 với Warehouse/Job/Save; xác định one-writer integration | Save→Load→Save không mất hay tạo tài nguyên, số ID/slot cũ giữ nguyên; old backup còn an toàn | Không đặt V2=PASS vì tài liệu tồn tại; chưa tạo Codex packet |
| **S1 R11 authoring** | R11 ba candidate resource IDs, một normal mob type+realm/element, một reachable frontier/node profile | Registry ID, nguồn và consumer đều được đối chiếu; không có duplicate ID, map route chứng minh R10 đến được | ID không có source thực = CHƯA PASS; Source A hình chưa có |
| **S2 R11 source-to-warehouse** | Mỏ ore+Lâm fiber+1 quái thường thật, source generation/receipt dedup | Sau work/kill thật, kho Sect có stack đúng theo life/node, one worker job; Save reload không nhân vật tư | Không phát reward do render, preview, Boss, hoặc đổi 5 encounter difficulties |
| **S3 R11 archive** | Basic R11 catalog nghiên cứu Sect-wide một lần bằng vật liệu M/N thật | Research order tính worker/tick, đúng một debit và durable recipe entitlement; các lần đọc lại không trừ nguyên liệu thêm | Cấm bấm UI mở recipe, cấm free pattern khi chưa có nguồn |
| **S4 ONE R11 forge** | Một Lv30 Forge thật, 1 worker, 1 queue, `weapon` R11 chọn đúng dạng theo skill | Reserve stock+Spirit Stones, work thật, freeze quality, receipt 1 lần, item unique vào Kho | Đừng sử dụng P2 3-slot forge như V2, không cho zero-time/clone/mất item giữa debit và credit |
| **S5 R11 first equip** | Item R11 nằm Kho → 1 người có Tu Vi hoặc Luyện Thể hợp lệ, weapon requirement chuẩn | Item assigned đúng 1 người; món R10 trả Kho hoặc vẫn giữ theo policy; set Nhân/Tiên không pha | Không tự đổi talisman P2 thành pendant V2; không gian lận HP/skill |
| **S6 10-slot and 30-person load** | Mở rộng cùng recipe-owner cho 10 ordinary slots của R11 và 30 đội săn | Đủ10 vị trí/nhóm, không cần Boss để đủ đồ thường; nhu cầu vật tư/throughput đo bằng kill/worker thật | Không 30 Boss item cho30 người; source odds pilot không phải actual drops |
| **S7 R21 source & one-item** | Lặp S1→S5 cho material THẦN + mob R21 + R21 archive và ONE item | R20 team farm được trước khi có item R21; rèn R21 basic với Lv30 khi đủ Thần mats và blueprint thật | Không yêu cầu Lv75, không tái dùng Body-Gate, không chuyển Tiên sang Thần khi nhân vật level-up |
| **S8 Generation safeguard** | Hai thế hệ set thay theo nhóm, optional inheritance sau khi có target thật | 2/3/4 threshold đúng generation, stash item cũ và donor unique only if approved | Không tự nhân bản credit, không tính4-set mix Tiên/Thần |
| **S9 Premium isolation** | Lv75 set/advanced grade/Chân Văn là TƯƠNG LAI riêng | Chỉ có thể xét khi Elite/Boss/Bí Cảnh, effect consumer, worker/sources thực | Không kéo Lv75 thành gate implicit cho S7 |

**Release spine:** S0→S1→S2→S3→S4→S5 là chuỗi giao một chức năng đầu cuối đầu tiên. Chỉ sau đó khảo sát S6→S7→S8. S9 độc lập, không cản S7. Không khuyến nghị khởi đầu bằng toàn bộ 20 rank, 100 materials, 60 monster species và 160 blueprints.

## 5. Trách nhiệm code TƯƠNG LAI (KHÔNG phải implementation allowlist)
S1 là nội dung typed của ResourceRegistry/Monster/region; S2 do Combat V2 death + real Mine/Forest job + Warehouse receipt authority; S3 Sect persistent archive; S4 building/workforce/EquipmentV2/unique item/one Warehouse+Stone settlement; S5 equipment assignee+stats; S6/S7 nguồn có nội dung mới nhưng cùng authority; S8 batch equip/lineage and safe ownership. GUI chỉ gửi command/thể hiện state.
**CODE yêu cầu giấy phép riêng theo AGENTS:** một writer cho SectState, SimulationState, WarehouseSystem, SaveService, BuildingSystem và rewards; chốt baseline SHA mới tại thời điểm cấp phép, path allowlist, rollback và official focused/cumulative tests. Không xung đột PR29 hay nhánh Codex hiện tại. Không chạm Source A qua một docs PR.
**Luyện Khí Điện Lv30** là mốc thiết kế, chưa phải completed building in code; cần chứng minh upgrade/worker path bằng tài nguyên ≤R10 trước khi nói R11 forge, và đường đó còn áp dụng đối với R20. Tốc độ nghề `level=floor(sqrt(XP/24))` / `speed=1+0.01×level` chỉ giảm thời gian, không nhân item/XP. Injury pause/resume duy nhất; worker không thể đồng thời săn và rèn. Không hứa số queue nhân với worker slots.

## 6. Owner review
Đã đồng ý hướng S1→S8 R−1 frontier + Lv30 BASIC R11/R21 + Lv75 premium và “learn once” theo nguyên tắc. **Chưa duyệt các ID, phí, quantity, q per kill, thời gian, loại map, hạch toán Forge, 12-grade RNG hay năng lực Lv30 làm từ tier Thần cụ thể.** Tài liệu kế tiếp trong cùng nhánh `docs/research/TMB_ASCENSION_R11_R21_MIN_SLICE_ACCEPTANCE_EVIDENCE_RISK_2026-10-25.md` ghi bằng chứng/chướng ngại, fixture lỗi và bảng gate để chủ dự án duyệt. Không có Godot QA nào đã chạy.
