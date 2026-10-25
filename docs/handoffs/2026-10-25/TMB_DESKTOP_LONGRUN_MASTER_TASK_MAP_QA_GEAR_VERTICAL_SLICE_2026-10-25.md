# TÔNG MÔN BÁ ĐẠO — DESKTOP LONG-RUN MASTER WORK TASK
## Một tác vụ dài: kiểm thử/tích hợp hai map, rồi chứng minh vòng trang bị Forge→Kho→mặc→Save

**Ngày:** 25/10/2026 · **Đề xuất giao Công việc, không phải chứng nhận PASS/ủy quyền merge.**  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao`; Godot **4.7.2 official**; Windows/Android landscape 1280×720.  
**Tài liệu liên quan:** `docs/handoffs/2026-10-25/TMB_WORK_MODE_MASTER_CHECKPOINT_MAP_PR33_PR34_2026-10-25.md` cùng nhánh này.

## 0. Trạng thái GitHub sống (PHẢI fetch lại trước khi làm)

Tại 25/10: **145 branches**, **31 PR OPEN (đều Draft)**, **2 merged** (#1, #23), **2 closed không merge** (#15, #22). Không dùng số nhánh làm chỉ báo performance. Nhiều nhánh là docs nghiên cứu.

| Đích | Ref tại kiểm tra | Bằng chứng |
|---|---|---|
| Official `main` | `29b5fba448b0178cb520a4ada44b375b4b934e31` | Chưa có dãy code gameplay mới; không bắt đầu code map từ main |
| [PR31](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/31) | `integration/pr28-combat-v3-s1-playable-qa-20261024@9eb4fd55733bb49bbb069240b8e332d37d22aced` | CARE/D7/Combat S1/P3.2; **28/28 focused và 56/56 S1** PASS trên code SHA `4b02a0c61a2771d9d4638129d96b68ad292270dc` |
| [PR32](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/32) | `feature/map-d1b-functional-hub-playable-20261025@c6bde70f6e98f482c91cd6d2c386e58437877209` | Sect Option B, **29/29** focused PASS theo evidence SHA |
| [PR33](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/33) | `feature/map-d2-direct-chatgpt-visual-upgrade-20261025@7a551ca4f8f9b15f3069652c5f557e0fbc29833e` | Site SVG thử nghiệm, cache địa hình/đường, AStar reused; **Godot chưa chạy trên SHA này** |
| [PR34](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/34) | `feature/pve-map-presentation-upgrade-20261025@dae86efd37a61e2e82c64ea00608fc062c4b423c` | CARE forest visual + scene xem thử 20 bãi; 300 quái **CHƯA code** |
| [PR35](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/35) | `docs/project-status-cleanup-20261025@f1d0cca3a9ef8c921ad07fafba536fcde4edf313` | Rút gọn entrypoint docs, CHƯA merge; tham khảo, không ghi đè PR31 |
| Concurrent CODE-CLEAN/R0 | `code/code-clean-finite-reward-20261025@5fbdbc6309c3f1386f0d8b619831e007c5a52824`, `qa/code-r0-finite-world-20261025@cb0974bca4445b3ef591fbb149740f328a40c0c8` | Công việc finite-world/migration riêng; kiểm tra HEAD mới nhất trước sửa Gear/Save |

Dùng exact branch + path. PR29/30 Combat S1 là sibling đã selectively incorporated trong PR31; KHÔNG merge lại toàn bộ. PR33 và PR34 chưa có combined QA tree.

## 1. Thiết kế trang bị ngày 24–25/10: QUYẾT ĐỊNH vs THỬ NGHIỆM

Đọc đúng các **docs-only branches** (không tự nhầm là code):
- `docs/gear-v2-basic-rare-24sets-camp-sources-20261024/docs/design/TMB_EQUIPMENT_V2_BASIC_10_SLOT_FORGE_RARE_CHASE_30_TO_3000_2026-10-24.md`: **10 ô thường** `weapon,head,armor,cloak,bracers,gloves,belt,boots,pendant,ring`. 3 Phù và 2 Pháp Bảo nằm ngoài bộ 10 ô. Item là tài sản Tông Môn ở **một Kho canonical**, disciple chỉ được phân phối dùng, không clone.
- Cùng branch, `docs/design/TMB_EQUIPMENT_V2_24_SETS_96_PIECES_TTL_SOURCE_MATRIX_2026-10-24.md`: **24 dòng đồ bộ ×4 món=96**, thưởng tích lũy 2/3/4, source-directed từng món, không roll 96 món từ một pool chung; Hỗn Độn ở Thần.
- `docs/equipment-v2-forge-transaction-rng-inheritance-20261024/docs/design/TMB_FORGING_V2_END_TO_END_TRANSACTION_BLUEPRINT_FACILITY_2026-10-24.md`: owner đã đồng ý **nguyên tắc** chọn đúng slot/blueprint, reserve toàn bộ vật tư, work time/One Active Job, receipt exactly-once, một item unique hợp lệ, phẩm thấp khi RNG không đạt, học blueprint một lần; costs/seed schema/RNG rates chưa khóa.
- `docs/forge-v2-enhance-refine-grade-realm-inherit-economy-review-20261024/docs/design/TMB_FORGE_V2_FIVE_UPGRADE_OPERATIONS_INVESTMENT_CONTRACT_2026-10-24.md`: năm thao tác nâng cấp/tinh luyện/thăng phẩm/thăng bậc/kế thừa, giữ đầu tư không phá item theo nguyên tắc; **+3, 80%, 55%, 70% credit chỉ là PILOT**, không được ghi thành runtime canon.
- `docs/equipment-r1-r30-ascension-chanvan-combatv2-review-20261024/docs/design/TMB_EQUIPMENT_V2_R1_R30_THREE_GENERATIONS_SOURCE_BLUEPRINT_PROGRESSION_2026-10-24.md`: item R1–30, Nhân1–10/Tiên11–20/Thần21–30, phẩm chất **1–12 là một trục độc lập**, đừng dùng body-gate materials làm vật tư Forge.
- **LATEST OWNER OVERRIDE** `docs/ascension-r11-r21-vertical-slice-source-proof-20261025/docs/design/TMB_ASCENSION_R11_R21_SOURCE_TO_EQUIP_VERTICAL_SLICE_ROADMAP_2026-10-25.md`: **R11 BASIC tại Luyện Khí Điện Lv30 và R21 BASIC CŨNG tại Lv30** khi vật liệu/bản vẽ đúng thế hệ đã có nguồn thật; **Lv75 CHỈ đồ bộ/advanced/special**. Ghi đè tài liệu cũ cho rằng mọi món R21 bắt buộc Lv75. R11/R21 frontier, vật tư/IDs mới chưa phải nguồn live. Đọc trước mọi Forge logic.
- `docs/forge-lv30-75-three-budget-profiles-r20-20261025/docs/design/TMB_FORGE_LV30_LV75_THREE_ECONOMY_PROFILES_R20_OWNER_REVIEW_2026-10-25.md`: 3 phương án ngân sách chỉ là mô phỏng, không khóa kinh tế.
- **HIẾM** = profile nghiên cứu tỉ lệ rơi, KHÔNG khóa. 7 loài/9 vật liệu/6 nguồn Công Pháp là hướng đã đồng ý, không phải đồng loạt ID/source đã code.

**Thực tế code cũ**: EquipmentSystem P2 chỉ có 3 slot và 5 recipes, chưa có V2 10-slot/24-set Forge trọn vẹn. Bản thiết kế R11/R21 không tự tạo ra nguồn quái, mine, blueprint hoặc vật phẩm Thần.

## 2. Môi trường Windows/Work và giới hạn an toàn

Người dùng có PC Windows RAM khoảng **8GB**, từng BSOD khi chạy nhiều tác vụ. **Một Godot process mỗi lần**, giới hạn số capture/log, không chạy full-suite/CI đồng thời, không login Windows Administrator hay sử dụng profile admin, không xóa/sửa worktree và source ở ổ E. Kiểm tra installed Godot official 4.7.2 engine hash, quyền filesystem, GUI, GPU và paths ở đầu phiên. Work Cloud trước đã **không có Godot** và không cài được: chỉ thực hiện runtime QA nếu Work/Desktop có QUYỀN TRUY CẬP THỰC TẾ vào máy/Godot. Không nhầm Work cloud browser với môi trường Windows của chủ dự án.

Không retry GitHub Actions job zero-step/BlobNotFound vô hạn, không coi CI failure chưa có log là lỗi gameplay đã chứng minh. Mọi PASS phải có **exact SHA/tree, command, exit, marker, log, screenshot runtime thật**. Không xóa lịch sử, PR, Source A hoặc thay gameplay khi chưa có fixture/migration rõ ràng.

## 3. MỘT TÁC VỤ DÀI — nội bộ W0–W6, chỉ báo cáo cuối

### W0. Freeze source & machine

Đọc `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, Work master checkpoint và file này; fetch HEAD PR31–35, CODE-R0, status worktree/saves. Không đọc lại 145 branches nếu không liên quan. Liệt kê số liệu SHA mà chính máy sẽ dùng và lập baseline commit/tree. Dùng docs cleanup PR35 để tránh prompt cũ, không tự merge PR35.

### W1. Sửa lỗi tĩnh PR33/PR34 trong phạm vi map

Rà parse types, `SVG` import, class dependencies, SHA 32 Source A PNG, cache static overlay theo chunk, 9 AStar preview routes phải đúng AStar independent, lookup BuildingState (ID/picking) và Sect/CARE camera. PR34 có helper forest và scene `PveWorldTopologyPreviewV1` (20 camps/30 edges/3 bridges/256×192 design) **chỉ preview**, không có 300 monster logic. Không sửa `godot/src/simulation/**` để map chạy được. Không bỏ asserts khi fail.

### W2. Kết hợp hai map lên nhánh QA RIÊNG + Godot official

Tạo worktree branch mới, đề xuất `integration/work-desktop-map-qa-20261025`, base HEAD thực tế PR33 (tức đã có PR31+PR32) và apply **NET** 7 tệp PR34 (không merge các nhánh khác). Giữ nguyên PR31–35. Rerun Godot 4.7.2 clean import/parse, PR32 **29 scoped focused tests**, PR31 **56 S1 checks** và các test PR33/34 + CARE/Save/Warehouse/camera, cùng final SHA. Nếu FAIL, sửa giới hạn view/script/tests rồi test lại; nếu vượt quyền/thiếu Godot ghi **BLOCKED**, không nhận là PASS. Chụp 1280×720 P3.2 sect mới, Mỏ/Lâm/Điền, Kho/click, CARE hunt, cùng một scene preview 20 camps **labeled DESIGN ONLY**, so sánh PR32 baseline ảnh thật. Benchmark frame-time p95/p99, Working Set nếu có Windows GUI/hardware hợp lệ.

### W3. Audit sâu Gear/Forge từ SOURCE, không tự tin vì docs

Đọc live `EquipmentSystem`, `WarehouseSystem`, `SaveService`, `WorkforceSystem`, `BuildingSystem`, `ResourceRegistry`, `GameRng`, Combat V2 equip consumers và CODE-R0's source delta. Làm matrix: real source→registered ID→Kho→blueprint learned once→Forge facility level+worker→material hold→single tick owner→frozen quality+item ID→unique item in Sect warehouse→single-disciple equip→save/load exactly once. Mọi unregistered item/material map/provenance phải báo thiếu. Kiểm toán save version, old P2 3-slot migration, user old saves và One Active Job. Xác định mẫu R1 BASIC hiện có `thanh_thiet/linh_moc`; công thức chi phí ví dụ 15/21 full kit không phải cost đã khóa.

### W4. Nếu W2 PASS và W3 khả thi, code ONE R1 BASIC gear vertical slice thật trên branch riêng

Tạo một worktree/branch kế thừa **combined map QA**; đặt `feature/gear-v2-r1-forge-vertical-slice-20261025` nếu chưa có. **Phạm vi cho phép**: tất cả code canonical tối thiểu thực sự cần cho R1 `source→Warehouse→validated order→reserve→worker/facility/tick→frozen valid item→unique Sect-owned warehouse item→equip real weapon slot→same-build save/reload` + tests/data adapters. Không khóa số giờ/tỉ lệ phẩm mới nếu chưa duyệt; có thể giới hạn output thử nghiệm grade thấp nhất hợp lệ trong pilot riêng, ghi rõ DESIGN CHOICE/CANDIDATE chứ không bật cân bằng game chính. Một order không tạo item nếu chưa thực sự trừ hợp lệ đầu vào. Không tạo Forge ảo với đồng hồ ảo hay tặng đồ miễn phí.

Giữ nguyên combat damage rules/CARE/loot, nguồn đã đăng ký, currency Kho, Injury0/1/120, One Active Job, SaveService. Nếu buộc sửa Save schema, phải có migration versioned + fixtures reset/resume exactly-once trước khi coi CODE hoàn tất; nếu không chứng minh được, STOP phần này và tiếp tục report/test design. Không xóa/retype 3 slot P2 làm hỏng save. Không code 96 set, 12-grade RNG phân phối, R11/R21 source giả, upgrade rate, Boss 20-camp game nếu chưa có nguồn hợp lệ.

**R11/R21 công việc song song dạng TEST-FIRST / DOCS**: tạo nguồn-gate/softlock fixture từ R10→R11 và R20→R21, chốt guard BASIC Lv30 vs ADVANCED Lv75, blueprint one-time, đúng owner. KHÔNG tự thêm ID vật tư tiên/thần chưa có verified producer/mob/loot receipt để fake source. Nếu map QA bị chặn, vẫn làm W3 và R11/R21 fixture chuẩn bị nhưng không ghép code chưa chứng minh.

### W5. QA hậu tích hợp và chống exploit

Trên cùng final code SHA chạy map baseline, existing Equipment/Combat/CARE/production/O9/Warehouse/Save tests và R1 pilot tests. Ít nhất: double-click/order idem, two workers same materials, hold/release, injury pause, quit/save/reload at every receipt boundary, 100 replay/restart deterministic or bounded equivalent, item immutable instance id, equip assigned one disciple only, no duplicate debtor/credit, no downgrade R10/R20 crossing, invalid blueprint/slot/material/facility fail-closed. Phải ghi expected/actual inventory và hash. Build Windows portable project và smoke test nếu engine + templates hỗ trợ; không mang claim `EXE` nếu chỉ project.

### W6. Một lần giao kết quả & tránh nhánh bùng nổ

Deliver 1 bảng trạng thái toàn dự án và 1 master Markdown concise `TMB_WORK_DESKTOP_END_TO_END_RESULTS_2026-10-25.md` trên branch QA, với exact refs, screenshot/log SHA, PASS/FAIL/BLOCKED/NOT RUN, QA command, performance, các source IDs mới/thiếu, migration, rollback, next owner choices. Tối đa **2 Draft PRs**: (1) map integration stacked on PR33; (2) R1 gear pilot stacked on map integration **nếu W4 thật sự code**. Không merge main, không close/delete các Draft PR cũ, không tự xoá 145 branches. Đưa danh mục nhánh cũ để archive *sau cutover được owner duyệt*, đừng cherry-pick Economy/JX/Combat forks hàng loạt.

**Quy tắc độc lập:** nếu Godot không mở được, hoặc một stage bị BLOCKED, tiếp tục các audit/fixture/docs an toàn để một job dài vẫn tạo giá trị; KHÔNG invent PASS hoặc yêu cầu owner trả lời từng 5 phút. Owner chỉ review kết quả cuối.

## 4. Acceptance statuses

- `MAP_CODE_INTEGRATED_UNVERIFIED`: có code, chưa phải Godot QA.
- `MAP_GODOT_FOCUSED_PASS`: 29 baseline + 56 S1 + new tests và game screenshot cùng SHA có bằng chứng.
- `GEAR_SOURCE_AUDITED`: code/source/equipment gap matrix chứng minh.
- `GEAR_R1_PILOT_PASS`: item thật trong Kho, equip đúng slot, SAVE exactly-once qua test.
- `R11_R21_SOURCE_BLOCKED`: thiếu materials/blueprint/facility thật; test-first docs chứ không giả đã rèn.
- `ANDROID_PENDING / OWNER_VISUAL_PENDING / NOT_RELEASE`: mặc định cho đến khi có nghiệm thu thật.

## 5. READY TO PASTE INTO CHATGPT WORK DESKTOP (hoặc Codex trên máy Windows)

**TÔNG MÔN BÁ ĐẠO — TÔI GIAO MỘT CÔNG VIỆC DÀI TRÊN MÁY TÍNH, CÓ QUYỀN CODE TRÊN NHÁNH RIÊNG.**

Repo GitHub `vuanhtuan161094-byte/TongMonBaDao`. Đọc toàn bộ file:
`docs/work-mode-handoff-map-qa-integration-20261025/docs/handoffs/2026-10-25/TMB_DESKTOP_LONGRUN_MASTER_TASK_MAP_QA_GEAR_VERTICAL_SLICE_2026-10-25.md` và `TMB_WORK_MODE_MASTER_CHECKPOINT_MAP_PR33_PR34_2026-10-25.md` trên cùng nhánh.

Làm một lần, liên tục W0–W6. Đầu tiên kiểm tra quyền truy cập PC local, official Godot 4.7.2, repo/saves, rồi code sửa và kết hợp PR33+34 trên nhánh QA riêng. Chạy 29 focused PR32, 56 S1 checks và các test map mới trên final tree, screenshot runtime 1280×720, đo FPS/RAM nếu thật sự có Windows GUI. Không động vào PR31–35 gốc, `main`, Source A verified hay Combat/CARE authority.

Sau khi map đã đủ QA, kiểm toán sâu Gear V2/Forge theo docs 24–25/10 và, nếu nguồn/cơ sở thật cho phép, triển khai **ONE R1 basic forge→Kho→equip→Save exactly-once vertical slice**, với tests, không tự khóa HIẾM/80%/55%/+3/70%. Nhớ **R11/R21 BASIC Lv30, Lv75 SET/ADVANCED**, nguồn R11/R21 chỉ fixture nếu chưa code.

Không chạy hai Godot cùng lúc trên máy 8GB; không Administrator; không xoá dữ liệu ổ E; không retry Github Actions vô ích. Tự xử lý trong scope, tự sửa và chạy lại; nếu blocked thì làm các việc an toàn khác và ghi đúng thiếu gì. Cuối cùng một báo cáo tiếng Việt, tối đa hai Draft PR mới, exact SHA/log/screenshot/chiến lược rollback. Không merge, không xóa nhánh hay gọi release PASS trước khi tôi nghiệm thu.
