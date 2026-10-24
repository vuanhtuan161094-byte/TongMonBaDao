# TÔNG MÔN BÁ ĐẠO — LUYỆN KHÍ V2: LỆNH RÈN, BẢN VẼ, RNG PHẨM VÀ GIAO DỊCH EXACTLY-ONCE

**24/10/2026 · DOCS-ONLY · CHỜ OWNER DUYỆT.** Không code, không Codex packet, không PR29/UI/Source A, không merge. HIẾM là baseline nghiên cứu, chưa khóa gameplay.

## 0. Nguồn và phân loại
Đọc trực tiếp main `29b5fba448b0178cb520a4ada44b375b4b934e31`: `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/WEAPON_EQUIPMENT_V2_SPEC.md`, `docs/EQUIPMENT_SETS_V2_SPEC.md`, `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md`, `docs/P3_7_BUILDING_TREE_SPEC.md`, `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`, `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`, `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`, `godot/src/simulation/equipment/equipment_system.gd`, `godot/src/simulation/resource/warehouse_system.gd`. Kế thừa hai tài liệu từ `docs/gear-v2-basic-rare-24sets-camp-sources-20261024` và HIẾM từ `docs/ttl-v3-rare-loot-three-profiles-gear-scaling-20261024`. PR29 OPEN/DRAFT SHA `9522812e91b7ca5bc0cc108eb92e000e930fe850` khi kiểm tra.
**[LOCK]** luật V2 đã duyệt; **[SOURCE]** mã hiện có; **[PROPOSAL]** luật/nội dung thiết kế mới chưa duyệt; **[DEFERRED]** chưa thể tạo vật phẩm do thiếu nguồn/công năng; **[TEST]** chỉ fixture định nghĩa, chưa chạy. Các số và IDs mới đều là PROPOSAL.

### Ranh giới không được đổi
- [LOCK] 10 ordinary slots: `weapon,head,armor,cloak,bracers,gloves,belt,boots,pendant,ring`; item realm1–30 độc lập phẩm1–12. Phù3/Pháp Bảo2 độc lập. `weapon_requirement` thực mới giới hạn vũ khí, không khóa mọi nghề/pháp tu vào một class; Quyền Sáo = weapon không phải gloves.
- [LOCK] 12 phẩm Phàm/Tinh/Thượng/Cực/Linh/Huyền/Địa/Thiên/Vương/Thánh/Đế/Chí Tôn; max 6 normal lines, 2 rare **stat** lines, 1 Chân Văn **capacity trống** ở phẩm12. 24 dòng đồ bộ =96 tên/đúng bốn vị trí mỗi dòng; chỉ `head,armor,cloak,bracers,belt,boots` tham gia. Ngưỡng2/3/4 tích lũy; phối4+2,3+3,2+2+2 hợp lệ; trong một bộ phải cùng generation Nhân/Tiên/Thần; Hỗn Độn chỉ Thần.
- [LOCK] One Active Job; Injury0/1 và hồi120 tick; simulation tick canonical, Warehouse Sect duy nhất với material lock/reserve_min và integer bound; đồ độc nhất thuộc Sect, cá nhân chỉ được phân công sử dụng; no reroll Save/offline. Cơ Duyên không phải tỷ lệ cộng thẳng vô hạn, nghề Luyện Khí tốc độ cơ bản theo `1+0.01×profession_level` với `profession_level=floor(sqrt(XP/24))`.
- [SOURCE] `EquipmentSystem` main còn ba slot P2 cũ `weapon/armor/talisman` và năm recipe, không có full 10-slot 12-grade Forge V2. `WarehouseSystem` thật có `available_quantity`, `consume_requirements`, `warehouse_rules:{reserve_min,locked}` và giới hạn an toàn `9000000000000000`; **CHƯA có reservation ledger cho mỗi lệnh rèn**. Đừng giả đã có code rèn phẩm12 hay sổ giữ nguyên liệu.
- [OWNER] Giữ 10 công thức quái vật chuyên biệt và 10 basic recipe đã đề xuất trước; HIẾM chỉ cho gear-drop theo từng con quái (.0375–.10% normal tùy loài, Elite1%, Boss8.75%), không phải tỷ lệ thất bại rèn. Giữ 7 quái mới và 9 vật tư mới (hai nguyên liệu Elite/Boss thiếu consumer nên DEFERRED).

## 1. Hệ thống nội dung — ba định nghĩa riêng biệt
**EquipmentTemplateV2 [PROPOSAL]**: `template_id,slot,weapon_family_or_none,realm_index1..30,generation,base_stat_curve_id,equip_requirements,affix_pool_A_B_C,set_lineage_id_optional,set_piece_slot_optional,asset_ref_optional`. Không sinh chỉ số base khi RealmBodyCore curve chưa có; không dùng hình ảnh làm nguồn thông số. Cùng một mẫu có nhiều item instance khác `instance_id`/phẩm/chỉ số nhưng cùng template identity.
**ForgeRecipeV2 [PROPOSAL]**: `recipe_id,recipe_version,output_template_id,chosen_slot,chosen_weapon_form,required_building_level,required_profession,worker_condition,inputs_registered_id_quantity,blueprint_unlock_id_optional,item_realm_allowlist,quality_pool_id,base_work_ticks`. Người chơi chọn **món/ô muốn rèn**, không quay xổ số cả 10 ô hoặc 24 set. Phẩm/thuộc tính chỉ được roll từ pool hợp lệ của công thức. Có bản vẽ mà thiếu vật tư thật/worker/facility → từ chối không trừ nguyên liệu.
**BlueprintV2 [PROPOSAL]**: `blueprint_v2:set:<lineage_id>:<canonical_slot>` phải gắn đúng một trong 96 canonical vị trí, thêm `acquisition_source` và `realm/generation`. Hai mô hình cần owner duyệt: (A) bản vẽ hoàn chỉnh đầu tiên được lưu vào Sách Luyện Khí để **mở công thức lâu dài**, mỗi lần rèn trả vật liệu/tick; (B) bản vẽ tiêu hao mỗi lần. Khuyến nghị A để tránh buộc 3.000 người săn 30.000 quyển bản vẽ; nhưng A chưa có lưu trữ hay runtime. Mảnh blueprint khác Công Pháp, khác mảnh Công Pháp; không dùng ID chưa đăng ký để nhập Warehouse. Tuyệt đối không có token đổi ra mọi bộ miễn phí.
**UniqueEquipmentInstanceV2 [PROPOSAL]**: `item_instance_id,template_id,realm_index,quality_grade,legal_normal_lines,legal_rare_stat_lines,chan_van_slot_state,one_set_lineage_optional,source_order_id,source_receipt_id,sect_owner,assigned_disciple_optional,lock_flags,item_version`. Một item chỉ có một location/assignee hợp lệ; không clone khi equip, inheritance hoặc salvage.

## 2. Lv1 / Lv30 / Lv75 + phân bố thiết kế
| Mốc | [LOCK] định hướng | [PROPOSAL] đường chế tạo | Tuyệt đối không suy ra |
|---|---|---|---|
| Lv1 | Luyện Khí cơ bản/sửa chữa | Rèn món thường không set, đủ 10 ô với registered `thanh_thiet/linh_moc`; chọn rõ ô/vũ khí. Input nguyên từ `TMB_EQUIPMENT_V2_BASIC_10_SLOT_FORGE_RARE_CHASE_30_TO_3000_2026-10-24.md`; 1 kit 15 ore+21 wood; cấp vật phẩm sau job thật | Không miễn phí 10 ô, không tạo gear phẩm12 |
| Lv10 | Auto-repair hướng thiết kế | Mẫu queue repair nếu có durability consumer thật | Không tự giới thiệu thanh độ bền/bắt sửa khi durability chưa có |
| Lv20 | tinh chế vật liệu | Registered refinement recipe có output vật liệu **thật**, tránh input→output quay vòng có lãi | Không tạo “tinh luyện” ảo vào vật phẩm |
| Lv30 | forge vật liệu quái | 10 specialist recipes đã đề xuất + vài set thấp [S0] theo đúng **individual piece blueprint** trong ma trận 96 món; worker và nguồn thật | Không suy rằng toàn 24 bộ mở ở Lv30, hoặc bản vẽ tên là vật phẩm thật |
| Lv50 | trait/reforge sâu hơn | Chỉ mở tiêu chí hợp lệ đã được tác giả hóa | Không auto viết lại affix, nâng phẩm |
| Lv75 | set/special nâng cao | [S1] cụ thể từng piece blueprint, nguồn Tinh Anh/Boss, mốc vật liệu và phẩm tốt hơn khi đủ nguồn; kết quả vẫn đúng set identity | Không auto grade8/Chí Tôn nếu recipe nguồn không đủ, không chặn tuyệt đối mọi set thấp dưới Lv75 |
| Lv100 | rare-line/mastery | Hướng chuyên sâu có consumer hiện hữu; sự kiện ra đồ hiếm phải kiểm được | Không tự tăng cơ hội phẩm12 hoặc work output ×thêm một lần |
**[DEFERRED]** Sáu dòng `Cửu Lôi,Thực Cốt,Huyền Ấn,Hỗn Độn,Phù Văn,Thiên Cơ` ở sơ đồ 96-piece còn thiếu nguồn/lore/consumer hoặc thuộc Thần; không đưa chúng vào Thanh Trúc Lâm đầu game giả bằng hệ số cực thấp. Tên canonical giữ nguyên. Nguồn Elite/Boss có một life/loot pool, không multiply set drop bởi 30 người.

## 3. Persistent ForgeOrderJournalV2 — sự thật transaction (chưa có code)
~~~yaml
order_id: forge:v2:sect:monotonic_order_sequence
idempotency_key: ui_or_auto_user_command_id
recipe_id: forge_v2:basic_armor
recipe_version: pinned_content_hash
output_template_id: gear_v2:basic_armor
item_realm_index: 1
facility_instance_id: persistent_building_id
worker_disciple_id: persistent_disciple_id
created_tick: 3000
start_tick: 3001
base_duration_ticks: 12
duration_snapshot_ticks: 12
remaining_ticks: 12
input_snapshot: {thanh_thiet: 3, linh_moc: 2}
reservation_id: resv:forge:v2:sect:monotonic_order_sequence
rng_identity: [sect_seed,order_id,recipe_version,quality_stage]
state: RUNNING
frozen_result: null
settlement_receipt: null
~~~
Định nghĩa đây là ĐỀ XUẤT schema persistent; không đánh dấu các field có sẵn ở `SectState`. `order_id` phải duy nhất, không theo giờ thực; command trùng nhận lại đúng order; RNG dùng identity ổn định, không phụ thuộc vị trí camera hoặc frame count.

### 3.1 One Forge order complete state machine
| Bước | Trạng thái | Hành động authoritative | Chống lỗi |
|---:|---|---|---|
|1|REQUESTED|Chọn template/slot/item realm/worker/Forge| UI/auto chỉ gửi yêu cầu, không cộng đồ |
|2|VALIDATED|Kiểm tra công thức + vật tư IDs thật + unlock blueprint + facility/worker + giới hạn One Active Job + reserve/lock + queue capacity + item generation|Lỗi → REJECTED, không debit |
|3|RESERVED|Sect journal khóa định lượng theo `order_id`, phát job thật cho đúng worker/building, ghi Save| Hai lệnh không thể cùng giữ một Thanh Thiết |
|4|RUNNING|Lao động theo canonical tick, speed snapshot; job tiến độ thật. Injury→PAUSED theo policy, giữ order ID| Thoát game/đổi speed/offline không nhân sản phẩm; không làm hai job |
|5|RESULT_FROZEN|Khi đủ actual ticks, xác định phẩm thuộc nguồn hợp lệ + valid affixes + một stable `item_instance_id`; kết quả cố định trong journal|Tải lại save không reroll |
|6|COMMIT_PENDING|Atomically áp dụng debit vật liệu đã reserved + insert unique gear + receipt + profession XP; nếu cần journal replay phải idempotent| Không thể mất vật tư mà không có món, hoặc có hai món |
|7|COMMITTED|ACK, giải phóng reservation/job, item tồn tại một lần trong Sect Warehouse|Cùng order chạy lại chỉ trả receipt |
|8|ASSIGNED optional|Auto-equip riêng kiểm tra item lock, đúng slot, weapon/realm/branch, không phá set 2/3/4|Không có bản sao trong túi cá nhân |

**Reserved stock formula (NEW, chưa phải WarehouseSystem API):** `new_allocatable_r = max(0,physical_stock_r − user_min_reserved_r − sum(active_order_reservations_r))`, bằng 0 khi resource locked cho **lệnh mới**. Order đã accepted giữ reservation ngay cả khi user đổi warehouse lock về sau; chủ kho có quyền hủy theo policy minh bạch. Nếu vật tư Thanh Thiết thực5, user reserve_min1, order A giữ3 → chỉ còn1 cho order B; lệnh B xin2 phải thất bại **trước** worker bắt đầu. Sổ reservation là thuộc *cùng Sect Warehouse*; không thêm túi Forge hay kho riêng.
**Atomicity requirement:** Mã hiện có `WarehouseSystem.consume_requirements` bảo vệ debit nhiều nguyên liệu khi được gọi, nhưng KHÔNG hiện thực reservation riêng/job journal/unique gear receipt. Gọi consume, tạo item, rồi Save như ba bước rời không chống crash giữa các bước. Khi sau này code, hoặc giao dịch trạng thái atomic trong một persistent save snapshot, hoặc durable prepare/commit replay rõ ràng; luôn giữ `RESULT_FROZEN` không reroll.

### 3.2 Hủy / rớt mạng / Injury / worker swap — phương án để owner duyệt
- Trước khi RESERVED: Cancel không tạo hiệu ứng gì. Trong RESERVED/RUNNING: đề xuất cancel tự nguyện **trả toàn bộ nguyên liệu đã giữ, mất tiến độ làm**, không sinh vật phẩm và không có EXP nghề; vì phẩm ẩn đến RESULT_FROZEN, không có peek trước để spam quay phẩm. Mọi order id/counter vẫn tăng và được ghi lại dù cancel; không tái sử dụng seed. Owner có thể chọn policy phí hủy, nhưng hiện không tự áp.
- Sau RESULT_FROZEN: KHÔNG cancel hoặc hoàn nguyên liệu để quay lại RNG; phải settle đúng output đã chốt. Nếu Warehouse/save lỗi thì PENDING + retry cùng result.
- Nếu Injury đúng 0/1 hoặc không thể tiếp tục: tạm dừng durable `remaining_ticks`, worker được giải phóng/auto-return theo luật hiện hữu, không double work. Khi phục hồi: resume same worker **hoặc** chuyển cho worker đủ điều kiện khác nhưng order ID/seed/progress giữ nguyên và từng người chỉ có một Active Job; chính sách transfer chưa khóa.
- Nếu lò rèn biến mất/nâng cấp/lỗi: tạm dừng, không tự tăng tốc hoặc hoàn tất bằng thời gian thực. Sau pause trước frozen, chỉ mới có quyền cancel rõ ràng.
- Tốc độ nghề theo [LOCK] `1+0.01×level`, cùng `work_speed` và facility modifier, chỉ **giảm thời gian**, không nhân đôi item hoặc lượng vật tư. Đề xuất freeze duration khi RUNNING bắt đầu, tiến độ là canonical ticks, quy tắc đổi worker speed mid-job [U]. Ví dụ level10 nghề, base12 ticks, không bonus khác ⇒ `ceil(12/1.10)=11` ticks [P time calculation]; Lv1 jobs 12 ticks trước bonus **chưa phê duyệt số thời gian**.

## 4. RNG phẩm 1–12, line caps và thất bại
**CANONICAL phẩm/stat capacity [LOCK]:**
| Grade | Phẩm | Lines thường tối đa | Lines đặc biệt dạng STAT tối đa | Chân Văn slots |
|---:|---|---:|---:|---:|
|1|Phàm|0|0|0|
|2|Tinh|1|0|0|
|3|Thượng|2|0|0|
|4|Cực|3|0|0|
|5|Linh|3|0|0|
|6|Huyền|4|0|0|
|7|Địa|4|1|0|
|8|Thiên|5|1|0|
|9|Vương|5|1|0|
|10|Thánh|5|2|0|
|11|Đế|6|2|0|
|12|Chí Tôn|6|2|1 trống|
**[PROPOSAL] Chỉ số RNG chất lượng các nhóm công thức để thử; không phải phẩm đã có trong code:**
| Profile nguồn rèn | Điều kiện hợp lệ | Tỷ lệ theo chỉ số grade | Các phẩm khác |
|---|---|---|---|
| F1_BASIC | Lv1, item realm1, registered Thanh Thiết/Linh Mộc | `1:85%,2:13%,3:2%` |4–12 =0|
| F30_MONSTER | Lv30 + từng vật liệu quái và blueprint/recipe có thật | `1:55%,2:25%,3:12%,4:6%,5:2%` |6–12 =0|
| F75_ADVANCED | Lv75 + blueprint, vật liệu/recipe cao hơn, item realm hợp lệ + actual grade8 source | `2:40%,3:28%,4:17%,5:9%,6:4%,7:1.5%,8:.5%` |1 và9–12=0|
| EXCEPTIONAL9–12 | chưa tác giả hóa nguồn high-rank/canonical | UNKNOWN, NO ACTIVE ROLL |Tất cả OFF cho tới khi có source hợp lệ |
Tổng xác suất mỗi hàng có số =100%. F75 **không tự mở phẩm Thiên** chỉ vì building lên75; mỗi recipe/item phải có allowed quality profile đủ nguồn, đúng realm, generation. Nếu recipe thiếu điều kiện thì không được roll, không ép về phẩm1 hay secretly renormalize. Baseline HIẾM là monster loot, không trừ thêm vào tỷ lệ Forge trên.
**[LOCK]** Grade và realm độc lập; roll line hợp lệ từ A/B/C stat pool theo slot, tối đa2 dòng A trên item, không trùng affix ID, hiếm chỉ sửa kênh có consumer; Chân Văn riêng không tự xuất hiện lúc Forge. Luck/Cơ Duyên theo score khi rare content check có phép, không cộng thẳng % tất cả recipes.
**[PROPOSAL] Thất bại và giữ phẩm:**
- Lệnh rèn hợp lệ **luôn tạo ra một item**, phẩm được roll trong tập allowed; “muốn phẩm cao nhưng ra Phàm” là kết quả kém **không phải trắng tay**. Không tạo tình huống Lv1 mất hết nguyên liệu mà không có item.
- Invalid recipe, thiếu worker, nguyên liệu lock/missing, output registry lỗi: reject/pause **không tiêu vật tư**. Lệnh đã `RESULT_FROZEN` chờ commit đúng kết quả, không được cancel/reroll.
- Các thao tác sau này `thăng phẩm/cường hóa/tẩy luyện` tách biệt khỏi tạo item. Nếu owner muốn upgrade có thất bại, đề xuất chỉ tiêu hao vật tư upgrade đã cam kết, **giữ item gốc và phẩm cũ** (non-destructive), không nhân bản. Tỷ lệ thành công/pity/trần cường hóa là [U] chưa chốt; không tự coi +15/+20 hợp lệ.
- Mọi outcome gồm fail của nâng cấp phải có `operation_id`/receipt bất biến để Save/retry không quay lại phần trăm.

## 5. Ba ví dụ quyết toán (minh họa, KHÔNG game chạy thật)
**E1 — Giáp cơ bản Lv1:** `forge_v2:basic_armor` từ 3 `thanh_thiet` +2 `linh_moc` [IDs thật] → một `gear_v2:basic_armor` item realm1, Phàm/Tinh/Thượng 85/13/2 [P], không set. Lệnh A giữ3 ore2wood, B không dùng lại chúng; sau12 ticks trừ một lần, tạo unique item, cộng EXP nghề hợp lệ đúng một lần. UI hiển thị receipt. Từ đây người chủ có thể giao cho một Kiếm/Thể/Pháp nếu yêu cầu vũ khí/hệ không cấm và item đủ tier.
**E2 — Bộ Hộ Sơn Lv30:** tên/positions canonical `Hộ Sơn Quan` head, `Trấn Sơn Giáp` armor, `Thạch Linh Uyển` bracers, `Bất Động Đái` belt. Tài liệu 96 món trước đề xuất C12/C19 Thạch Bì Thú cho 3 món và Nham Giáp Thú Elite cho một món. CHƯA có blueprint/gear ID/real registered Thạch Bì. Người chơi không thể rèn “một món Hộ Sơn ngẫu nhiên” khi chưa chọn đúng piece và thật sự có Blueprint. Rèn trúng phẩm khác nhau vẫn tính bộ nếu generation/slot đúng; ngưỡng2/3/4 dùng kỹ năng và chỉ số có thật, không tự bật skill.
**E3 — Bộ nghề Thiên Công và Lv75:** canonical bốn món `Khí Sư Quan`, `Khí Lô Phòng Y`, `Luyện Khí Hộ Uyển`, `Thiên Công Đái`. Nếu future authorized F30 piece và worker có `work_speed/profession_xp` consumer thật, các ngưỡng set chỉ giúp tốc độ/EXP nghề hợp lệ, không nhân item mỗi đơn. Lv75 có thể mở advanced quality cho một recipe nếu riêng recipe có nguồn và vật liệu chất lượng đủ, không tự tạo Chí Tôn hoặc Thần bộ.

## 6. Phân giải và kế thừa — không phá thứ tự lộ trình canonical
**Phân giải [PROPOSAL, DEFERRED cho tới khi có pricing]:** chọn một `unique item` không equip/lock/reserve, kiểm tra snapshot chính xác item source/grade/realm/affix/Chân Văn, bảo vệ đồ bộ 2/3/4. Một `salvage_order_id`, khóa item duy nhất, tính output vật tư từ **author-approved recipe**, xóa/consume item đúng một lần và cộng một vector tài nguyên registered hợp lệ, cùng transaction/receipt. Mọi thuật toán phải đảm bảo **giá trị đầu ra phân giải thấp hơn đầu vào + công** trên vòng craft→salvage→market, kiểm tra làm tròn. Không dùng công thức `floor(25% × ít vật liệu)` mà cho ra0 mà vẫn gọi là phần thưởng; định lượng thu hồi vẫn [U], nên **không auto-salvage** hiện tại. Boss relic/chân văn/set quý được lock mặc định nếu policy duyệt.
**Kế thừa [PROPOSAL, DEFERRED]:** chọn donor item A và target B là hai `instance_id` Sect duy nhất, đều tự do khỏi equip/lock; yêu cầu cùng slot, matching weapon family/realm/generation hoặc recipe exception có nguồn hợp lệ; nhập nguyên liệu phí thật một lần; commit tiêu hủy donor A và nâng B theo **quy tắc kế thừa hữu hạn** (chỉ một phần nâng cấp/phần trăm đầu tư thật, không nhân đôi affix/base phẩm/Chân Văn). Receipt công khai A bị consume, B giữ ID và version tăng; crash không thể vừa giữ A vừa B được thưởng. Nâng phẩm/cường hóa/tẩy luyện/thăng bậc/Chân Văn đang riêng roadmap orders2–7, không được tự tuyên bố đã hoàn tất.
**Kho Sect** ordinary stack logic unbounded (safe integer), equipment unique item identity. Auto-assign không thay món +1% mà phá full four-piece threshold; bảo vệ `locked`. Không có private bag, không tạo thưởng chỉ từ VFX.

## 7. QA invariant contracts (DESIGN ONLY)
- One request ID→one order, one order→one input reservation, at most one frozen grade/affix output, one debit, one unique item and one EXP nghề receipt. Invalid ID/negative/overflow and user reserve minima fail closed.
- Same-build Save/reload tại các điểm: sau RESERVED, giữa RUNNING, sau RESULT_FROZEN, sau material debit/unique output trước ACK, sau COMMITTED, trong PAUSED Injury và OFFLINE. Tất cả repeat đúng item instance/grade/stats; không mất vật tư hoặc nhân đôi.
- 2 workers cùng 1 mineral source, 1/2/4 queue lanes giả lập; không race dùng cùng stock và worker không nhận 2 active job. Speed profession chỉ giảm duration, không nhân số item hoặc EXP.
- Cancel trước frozen trả đúng held input không EXP, không UI grade peek; cancel sau frozen bị từ chối. Restart lúc accepted same command không tạo order mới.
- Phẩm12 không tự có Chân Văn và không vượt 6+2+1; các phẩm9–12 không bật trong Thanh Trúc Lâm khi chưa có nguồn. Set 24×4 khớp canonical 96 món, slot và generation; item inheritance không tạo duplicate.
- Salvage item đã được equip/lock/set-protected phải refuse; double salvage fails; craft→salvage→craft không tạo lãi vật tư hoặc Stones.
- Godot4.7.2 official focused, Windows gameplay và Android landscape1280×720/roster1000–3000 gates PENDING. Chưa chạy một test nào trong đợt docs này. Không sửa checkpoint runtime hoặc PR29.
**Open owner approval:** nguyên tắc guaranteed valid item thay vì phạt trắng, full reserved-cancel return, blueprint vĩnh viễn vs tiêu hao, distribution 3 profile, Lv1 time12, policy worker injury, Lv75 recipe gating, post-craft salvage/inheritance inputs. No code permission.
