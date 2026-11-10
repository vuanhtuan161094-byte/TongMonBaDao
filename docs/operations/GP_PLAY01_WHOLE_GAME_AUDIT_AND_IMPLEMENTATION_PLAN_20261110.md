# GP-PLAY01 — KIỂM TOÁN TOÀN GAME VÀ LỘ TRÌNH KHÉP KÍN GAMEPLAY

**Dự án:** Tông Môn Bá Đạo (Godot 4.7.2) · **một PR:** [#72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) · **nhánh duy nhất:** `integration/pve-p0-playable-ui-20261103`.  
**Mốc đọc mã đầu tiên:** `235f5d23b336ba17879da935f7d2acca6856c65c`, 10/11/2026. Mọi lần CODE tiếp theo **phải fetch HEAD mới nhất**, không mặc định mốc này là HEAD.  
**Người quyết định:** Chủ dự án; **scope chat GP-PLAY01:** quản lý Tông Môn, sản xuất, Kho, Luyện Đan, kinh tế, trang bị theo nguồn, dẫn nhập, giao diện chơi, Save/QA. **Chat khác** sở hữu kỹ năng, công thức combat, AI/quái/Boss, VFX/hitbox/movement chiến đấu.  
**Trạng thái tài liệu:** AUDIT + EXECUTION CONTRACT; không phải tuyên bố đã hoàn thành các giai đoạn. R0/R1 và Issue #56 vẫn là release train chính; GP-PLAY01 là **gói khép kín gameplay**, không tạo game/roadmap/Save độc lập.

## 1. Định nghĩa gameplay thành công

Làm cho Tông Chủ có **quyết định → đánh đổi → hệ quả thấy được → mục tiêu kế tiếp**, không chỉ nút hoạt động hoặc thêm số vào Kho.

### Vòng chơi xuyên suốt 1 Save (người chơi tự bấm, không QA fixtures)

**Tạo Tông Môn → tuyển đệ tử thật → xây/chọn cơ sở → phân 2 Mỏ / 2 Linh Lâm / 2 Linh Điền (hoặc cấu hình tối thiểu khả dụng) → công việc thật → mẻ vật tư ghi đúng vào Kho → tiêu đúng nguyên liệu vào Luyện Đan → mang thuốc thật đi săn PvE → nhận kill/loot/XP từ combat authority → tự uống thuốc trong bãi → trả về/điều trị Injury → chế tạo/đeo ít nhất một trang bị thật → có cải thiện thống kê/hiệu quả so với trước → Save/Exit/cold Reload → tiếp tục.**

`1.000 Tu Vi XP/phút` của V2 vẫn cộng khi PvE, nghề, chờ điều trị; EXP kill là cộng thêm. HP dùng Đan/kỹ năng, tử trận full HP + Injury=1; chữa Injury tại sect 30 ticks phí r1=1.500 LT/r2=3.000 LT, hoặc tự hồi 120 ticks miễn phí. One Active Job; thưởng kill không trùng, không có Kho loot thứ hai, tiền nội bộ chuyển ví≠tạo tiền.

### Chuẩn nghiệm thu

- **G0 technical:** focused và cumulative theo **đúng SHA**; không ngụy tạo PASS nếu còn FAIL liên quan; có log + exit code + file sửa cụ thể.
- **G1 real loop:** hoàn thành xuyên suốt trên một Save, không admin console/fixture/script seed ở game phát hành; cả 12 liên kết trên có biên nhận, UI thể hiện *trước/sau*; tương tác tự nhiên 10–15 phút khi dùng thời gian mô phỏng hợp lệ (không đồng nhất với 10–15 phút thời gian sản xuất bình thường).
- **G2 safety:** tồn Kho, LT, số Đan, XP, Injury, trang bị và tiến độ nghề có biến thiên đúng theo receipt, duplicate count=0, số dư âm=0, lost-job/softlock=0 trong những kịch bản đã kiểm.
- **G3 economy:** mô phỏng 1/7/30 ngày đúng source với các nhóm 6/30/90/480 đệ tử; có lương, thuế, chi phí mua vật tư, Đan tiêu, downtime và tiền mặt; không cần tự bịa nguồn r3+ để đạt dương.
- **G4 playable:** Windows 10 1280×720 chuột thật từ launcher chính thức, 3 cold launches và Save/Load; Android landscape/touch/FPS/RAM trên thiết bị truy cập được, nếu không thì **PENDING USER** chứ không báo PASS.
- **G5 product:** Tông Chủ có ít nhất 3 quyết định chiến lược có tác động (đội săn vs sản xuất; dự trữ thảo vs luyện thuốc; trả phí điều trị vs chờ), trạng thái thiếu nguyên liệu/tiền/nghề có đường khắc phục và phản hồi trên map/UI. Không biến game thành thao tác nhận thưởng mỗi phút.

## 2. Kiểm kê mã nguồn và trạng thái KHÔNG ĐÁNH ĐỒNG

Tree GitHub tại SHA đầu kiểm kê có 2.136 entries, trong đó 121 tệp dưới `godot/src/simulation/`, 81 dưới `godot/src/presentation/`, 145 `godot/tests/simulation/`, 93 entry `godot/tests/presentation/` (gồm metadata). Số tệp KHÔNG phải bằng chứng chất lượng.

| # | Miền kiểm toán | Source authority / nguồn đối chiếu | Thực tế xác minh được | Hở gameplay / kiểm tra tiếp | Trạng thái |
|---|---|---|---|---|---|
| 01 | ONE GAME, Tông Môn, màn hình 1280×720 | `p3_2_landscape_sect.gd`, `docs/P3_6A_PLAYABLE_VERTICAL_SLICE_SPEC.md` | Một scene UI thống nhất, nhiều panel/chức năng | Nút khó thấy/đè, phản hồi chưa phải một user journey thực | CODE, PHYSICAL QA PENDING |
| 02 | New Game, Nhà ở, tuyển đệ tử | `LiveGameRuntimeV2`, Recruitment, G0/G1/G2 tests | Có pipeline khởi tạo, tuyển thật và chỗ ở | Người mới có hiểu trình tự, nguồn tiền, giới hạn slot, cảnh báo softlock? | CODE, ONE-SAVE QA PENDING |
| 03 | Nhân sự, phân công, 1 Active Job | `WorkforceSystem`, `BuildingSystem`, GP02B1 | Có lệnh phân công, thời gian khóa trị thương | Nghề đang bận/đi săn/điều trị có thể bị chiếm slot hoặc kẹt lệnh; test O9/GP02 | CUMULATIVE FAIL trên SHA cũ |
| 04 | Mỏ | `BuildingSystem`, Mine producer, `WarehouseSystem` | Có nguồn Thanh Thiết và các output r1–r2 đã chứng minh theo selector | Sản lượng basic và SX V5.5 bulk chưa thống nhất, upgrade/cost cần cashflow thật | CODE/PILOT, BALANCE HOLD |
| 05 | Linh Lâm | `BuildingSystem`, Forest producer | Có Linh Mộc và chọn nguồn riêng | Nguồn khai thác mới cần GUI selector và đầu ra thật; chưa đủ cơ sở 30 cảnh | CODE/PILOT, BALANCE HOLD |
| 06 | Linh Điền | `SpiritCropRegistry` + `BuildingSystem` | Chỉ 3 cây có thật: Linh Cốc, Thanh Linh Thảo (Lv1), Tử Vân Thảo (Lv10) | Thu hoạch–Kho–Luyện Đan O9 FAIL; hạt giống giá cũ 3/4/14 LT khác đơn vị pilot ×1000; stock target và tiêu hao tranh chấp | CODE, P0 INTEGRATION FAIL |
| 07 | Kho/Vật tư | `WarehouseSystem`, `ResourceRegistry`, `_warehouse_operation_text` | Một Kho P3.7, có lượng/khóa/dự trữ, chống âm | `_warehouse_operation_text` **bỏ dòng có tồn=0, dự trữ=0, không khóa**; O9 yêu cầu luôn thấy “Thanh Linh Thảo” sau auto Alchemy. Phải log tồn thật rồi phân biệt UI đúng-hide-zero hay mất vật tư; **chưa đủ chứng cứ kết luận nguyên nhân** | P0 INVESTIGATE |
| 08 | Luyện Đan và thuốc | `MedicineCatalogueV2`, `AlchemyRecipeRegistry`, `SX01PillPolicy` | 119 recipe IDs/476 pill IDs nhưng **8 công thức r1–r2 authored**, 111 chỉ có thiết kế; 36 viên/3 phút áp dụng cho mẻ tương ứng, không phải tất cả mẻ | Nguồn thảo, người luyện, kho dự trữ, số thuốc/hunter/ngày, Q2–Q4 catalyst; công thức r3+ không có nguồn | P1 R1–R2 LOOP; R3+ HOLD |
| 09 | HP, Đan tự uống, Injury | `PveCombatAutoPillV1`, `PveInjuryTreatmentV1` | 80% HP, cooldown 5 giây, tiêu Kho 1 viên có receipt; Injury1, Sect 30/120 ticks | One Save/loop tự nhiên, 0 thuốc, 0 tiền, cooldown Save cạnh ranh giới ngày và UI phản hồi | CODE+FOCUSED GODOT PASS, user visual PENDING |
| 10 | PvE rewards/economy (không sửa combat) | `PvePerKillRewardV1`, `PveR12BalanceV1` | Base P0 75 Tu Vi +25 Luyện Thể per normal kill, teammate 40% trong 12 units; r1–r2 LT/bonus XP candidate vẫn `pve_r12_reward_pilot=false` | Người chơi hiện chưa có động lực kinh tế cân đối; cần loot → source-backed craft/market & đo kill/h, pill/h, injury/h; không bật fiat pilot mù | P0 LOOP GAP |
| 11 | Monster/map/wave/AI | `PveMultiCampPopulationV1`, `PveDistributedWorldV1` | Thanh Trúc Lâm 20 bãi/200 slot, **tối đa 40 active**/30 hunters; 2 cụm 10+10 chỉ metadata | Địa hình Bạch Thạch/Hắc Phong chưa thành Open World, FPS Android chưa đo; **combat writer phụ trách quái**, GP chỉ theo dõi tài nguyên/điểm vào/UI | HANDOFF OTHER CHAT |
| 12 | Trang bị/chế tạo | `EquipmentSystem.RECIPES` và `VALID_SLOTS` | **5 công thức** legacy, **3 slot** weapon/armor/talisman, 3 phẩm | Thiết kế mới 10+ slot, 12 phẩm, 24 set chưa chứng minh full runtime; thiếu source rơi → rèn → trang bị → sức mạnh với đúng quyền sở hữu | P2 GAMEPLAY GAP; COMBAT STATS OTHER CHAT |
| 13 | Công pháp/bản vẽ & kho sách | `TechniqueSystem`, `V63FeatureGates` | Legacy 6 công pháp, V63 catalogue data rộng, feature gates default OFF | Nguồn rơi học thật, tích hợp unlock/loadout/Save; **logic kỹ năng chat khác**; GP chỉ UI, sách, kho/chi phí theo interface | CROSS-CHAT HOLD |
| 14 | Shop/LT2/W2/T2 | `EconomySystem`, `docs/qa/SX_V55_R12_CASH_MATERIAL_BALANCE_20261110.md` | Shop NPC có quota/ngày, giá; LT2/W2/T2 r1–r2 là pilot source-backed nhưng OFF | 500 LT đầu không thể tự đảm bảo vòng 649.000 LT upgrade, bán NPC quota nhỏ; không tách phân bổ thuế khỏi tiêu hủy tiền; chế độ 0% thuế có thể softlock | P0 ECONOMY DESIGN/TEST |
| 15 | Vật liệu 30 cảnh | `ResourceRegistry`, `SX07B_PRESERVED_MATERIALS_SOURCE_GATE` | Báo cáo nguồn 11/630 ID đã đăng ký, 619 chưa đăng ký, 270 profile thiết kế không đồng nghĩa map thật | R3+ không có chuỗi source; tuyệt đối không chế tiền, item, drop, công thức giả | R3+ HOLD |
| 16 | Save/clock/offline | `SimulationState`, `SaveService`, `SimulationRuntimeClockV2`, One Save tests | P0 và PvE-CARE03 có official Godot headless/cold Save PASS ở SHA đã kiểm | 60/90/180 phút offline và full loop thao tác vật lý + crash recovery chưa có nghiệm thu chủ máy | TECH PASS PARTIAL, PHYSICAL PENDING |
| 17 | Mục tiêu, hướng dẫn, quyết định Tông Chủ | `docs/P3_6_SECT_MASTER_GAMEPLAY_LOOP_SPEC.md`, scene player UI | Spec có loop 5–10 phút quản lý và chú ý 0–3 ngoại lệ lớn/session | Chưa chứng minh có hướng dẫn thấy được, cảnh báo đường xử lý thiếu hàng, quyết định làm đổi gameplay thay vì chỉ nhấn nút | P1 GAMEPLAY GAP |
| 18 | VFX, kỹ năng, Boss và độ khó | `v63-quyen-doc-matrix.yml`, skill/MapBattle | 183 Độc Tu candidate đang được code/test ở cùng PR | Một số V63 CI FAIL, chưa có QA chiến đấu thực và FPS thiết bị | EXCLUDED — OTHER CHAT |
| 19 | Launcher/Windows/Android & release | `docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md`, Issue #56 | Godot CI Linux; Windows launcher từng có Intel crash; main chưa merge | 3 cold starts, mouse, same-Save, FPS/RAM Android, SHA post-merge | R2/R3/R4/R5 OPEN |

**Lưu ý trạng thái:** cột CODE/TESTED/PLAYER-AVAILABLE/VISUAL-ACCEPTED/RELEASED tách riêng; việc có 119 recipe IDs không chứng minh 119 công thức có nguyên liệu và nút dùng.

## 3. Bằng chứng hiện hành và 3 lỗi ưu tiên

### Cổng QA trên mốc đọc `235f5d23b`

- PVE-P0 official 4.7.2 **whole SUCCESS** [run #42853619295](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42853619295) trên **đúng** SHA đó. Không thay thế GP/O9/SX/Windows QA.
- P3 O9 M2 [#42851571699](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42851571699) **FAIL** tại `O9 Warehouse projection is missing Thanh Linh Thảo`. Cùng fail ở Economy-A [#42851571522](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42851571522), GP02C1 [#42851571376](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42851571376) và GP02B1 [#42851571763](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42851571763). Các workflow trùng fail cùng test không phải 4 lỗi độc lập.
- GP02C1 run #42851571376 cũng ghi `legacy_participant_occupation_conflict` trong log. Phải xác minh nguyên nhân, không xóa guard khi chưa chứng minh có lỗi nghiệp vụ.
- V63 matrix latest source SHA đang do **chat combat** thực thi; không sửa source/log của combat trong gói này. Đây là blocker release liên ngành, không phải quyền sửa skill.
- Tính toán LT2/W2/T2, 1/7/30 ngày ở `SX_V55_R12_CASH_MATERIAL_BALANCE` là scenario, **chưa phải** 30 ngày runtime chơi thật. Không bật pilot từ mô phỏng giấy.

### Điều tra O9 cần làm, không đoán trước root cause

1. Dùng một fixed-seed NewGame/Save, log Kho `thanh_linh_thao` `before_crop, after_crop, before_alchemy, after_alchemy, after_autoplay`; log `warehouse_rule reserve_min/locked`, plot/job pending, số mẻ `sx01`.
2. So `WarehouseSystem.quantity/available_quantity` với UI `_warehouse_operation_text`. UI hiện bỏ hiển thị vật liệu 0 tồn/0 dự trữ/không khóa; nếu Kho thật về 0 sau auto luyện Đan thì lỗi có thể nằm ở **kỳ vọng test/UI không mô tả nguồn đã tiêu**, không phải mất hàng.
3. Không sửa test chỉ để xanh. Nếu zero thực là bình thường, thay bằng projection rõ: **Thanh Linh Thảo 0 tồn / đã tiêu vào job nào / cần tiếp theo bao nhiêu / ETA từ Linh Điền** dựa trên dữ liệu thật. Nếu biến mất do settlement/duplicate, sửa canonical source và test biên nhận.
4. Chạy `p3_o9_m2_production_rehearsal_test.gd` strict + O4/O5/O7/O8, GP02C1, GP02B1, Economy-A + 3-process cold Save. PASS chỉ khi UI và số dư Kho đồng nhất trong cả mẻ đã tiêu hết.

## 4. Backlog thực thi theo các cổng, KHÔNG song song shared files

| Gate | Mục tiêu người chơi | Công việc kỹ thuật cụ thể (sẽ phân rã ở packet đầu) | Điều kiện mở cổng sau |
|---|---|---|---|
| **GP0 — TRIAGE** | Game không mất vật tư/đơ hoặc sai trạng thái | Reproduce O9 Thanh Linh Thảo, GP02C1 occupation, affected Economy-A; khóa nhánh V63 về writer combat; đối chiếu versions/UI tests; sửa lỗi non-combat có log | O9 + GP02 + Economy-A focused PASS trên cùng SHA, nếu unrelated đỏ phải ghi rõ |
| **GP1 — FIRST 5 MINUTES** | Người mới biết phải làm gì | Audit NewGame/Residence/Recruit/Workforce, một hướng dẫn theo hành động thật (không quà miễn phí), tooltips điều kiện, 3 trạng thái công việc `ready/busy/blocked` | 6 bước dẫn nhập bấm được trong One Game, không phải mock; UI 1280x720 không chồng |
| **GP2 — TRI-FACILITY** | Có vật tư đầu vào dùng được | 2 Mỏ +2 Lâm +2 Điền hoặc nhóm nhỏ khả dụng; source selector thật r1–r2, ETA, số lượng mỗi mẻ, freeze current jobs, ưu tiên từ Kho; giải quyết lệch basic/bulk, không bật 30-rank | Nguồn→Kho đúng 1 lần/mẻ, auto-repeat không mất tiền và không tạo tài nguyên giả; cold reload giữa job |
| **GP3 — MEDICINE** | Tạo được Đan để đi săn | Authored r1–r2 BOM; giống/giá trồng, Hall/worker/profession, Q1–Q4 đủ catalyst thật; stock target theo số hunter và reserve; Đan ở Kho → tiêu PVE-CARE03 | 1 mẻ có input/worker/timer real → item thật, 1 viên tiêu trận/hồi HP trên snapshot, thiếu thuốc có phản hồi/không softlock |
| **GP4 — PvE ECONOMIC HANDOFF** | Đi săn có lý do và không phá kinh tế | Nhận receipt HP0/loot/XP từ chat combat, **không sửa damage/skill/monster**; hiển thị EXP bonus vs 1.000 Tu Vi/min nền, loot→Kho, phí thuốc và Injury, ledger personal/sect; 6/12/18 kills/h chỉ sensitivity | 0 double credit; gross/net/medicine cost rõ; không unlock r3+ hoặc cộng tiền từ UI |
| **GP5 — EQUIPMENT/REWARD USE** | Phần thưởng tạo sức mạnh thật | Ưu tiên 5 recipe legacy có nguyên liệu thật; đúng owner Sect Warehouse → forge → item instance → equip/trade/lock → Save. Mở rộng 10 slots/V2 sau khi có migration và interface combat owner | Có 1 trang bị rèn từ vật tư kiếm được, được đeo, combat writer xác nhận thống kê thay đổi; Save giữ item ID, ownership, slot |
| **GP6 — TÔNG CHỦ DECISIONS** | Game có chiến lược/tiến triển | Chính sách dự trữ Kho, ưu tiên thuốc, phân 2/2/2, phân đội săn/hậu cần, mục tiêu/ngưỡng mở công trình thật, task-rail tối đa 0–3 cảnh báo cần làm/session; không spam reward | 3 lựa chọn tạo 3 hậu quả thực, hiển thị trước/sau; AI tự chạy khi không can thiệp |
| **GP7 — ECONOMY STRESS** | Không giàu vô hạn/thiếu vốn kẹt game | 1/7/30 ngày cùng Save: 6/30/90/480 roster; tính LT2 source, W2 topup đúng, T2 transfer, mua NPC, giống, thuốc, mẻ rèn, hỏng trận, Injury wait/cost; Monte Carlo loot có seed | Không xuất hiện giao dịch âm, không double claim, không default tiền fake, player không buộc NPC mua tài nguyên chưa có source; báo percentile có n, seed |
| **GP8 — ONE GAME QA** | Mở được game để chơi | Official Godot exact SHA, launcher Windows 3 lần, chuột 1280×720, complete playable path + cold Save, Android ngang, LOD và FPS/RAM; R2/R3/R4 | Evidence screenshot/recording và logs thật; chưa có máy thì PHYSICAL PENDING |
| **GP9 — MAP EXPANSION GATE** | Mở vùng mới khi sẵn sàng | Giữ Thanh Trúc Lâm 20 bãi, 40 quái active; UI 2 nhóm 10; chỉ mở Bạch Thạch Khê/Hắc Phong Cốc khi combat writer bàn giao terrain/nav/real monster source và FPS | Scene/map ID/Save, entrance/exit, loot/accounting hợp lệ; không nhân 40 quái mỗi map |
| **R5 — RELEASE** | Một bản duy nhất hoạt động | Hòa giải `main` riêng, retarget PR #72, official post-merge SHA, release+launcher khi user duyệt | Không merge trước R2–R4 + gameplay GP1–GP8 đủ evidence |

**Thứ tự mặc định GP0→GP1→GP2→GP3→GP4→GP5→GP6→GP7→GP8. GP9 là cổng mở rộng sau, không cản vertical slice r1–r2.** Một cổng có thể có 2–3 subpacket nhưng không được mở rộng chung `MapBattleV2`/V63.

## 5. Ma trận giao diện giữa hai chat — hợp đồng khóa xung đột

**GP-PLAY01 (chat này) READ ONLY đối với:** `godot/src/simulation/combat/map_battle_v2.gd`, `map_battle_snapshot_v2.gd`, `combat_stats_v2.gd`, `monster_catalogue_v2.gd`, `hunting_pve_run_v2.gd`, `pve_per_kill_reward_v1.gd`, `pve_combat_auto_pill_v1.gd`, toàn bộ `v63_*combat*`, `v63_*skill*`, shader/VFX/atlas. Không sửa hành vi chiến đấu, DoT, skill, Boss, auto-target, spawn hoặc đạo cụ VFX. Cần combat fix → ghi issue rõ, giao chat chuyên trách.

**GP writer được phép đề xuất packet cụ thể trên:** `BuildingSystem`, `SpiritCropRegistry`, `AlchemyRecipeRegistry`, `MedicineCatalogueV2`, `WarehouseSystem`, `EconomySystem`, `WorkforceSystem`, `EquipmentSystem` (chỉ kinh tế/ownership/forge không đụng combat stats), một scene `p3_2_landscape_sect.gd` có integration owner, tests O4/O5/O7/O8/O9, docs/agent. Trước CODE từng packet phải đọc diff HEAD mới nhất và kiểm tra writer khác; `State/SaveService/Clock` mặc định read-only.

**Interface bên combat cần bàn giao cho GP:** (1) encounter ID/real HP0 kill ID/loot receipt exact-once; (2) species/grade/realm/difficulty dữ liệu hợp lệ; (3) delta Tu Vi, Luyện Thể, personal LT (nếu enabled) và vật phẩm vào Kho; (4) tiêu Đan và Injury transition; (5) item equipment effective stats before/after (chỉ quan sát); (6) thời gian thực chiến/kills/h/damage taken/deaths/h/FPS on source SHA. GP không tự cấp loot hoặc sửa hệ số chỉ vì UI cần số.

**Bàn giao SHA:** mỗi chat gửi `branch + HEAD + diff files + interface changes + tests + result + compatibility`. Nếu cùng chạm `p3_2_landscape_sect.gd`/RuntimeOwner thì chỉ một writer tích hợp commit tại một thời điểm; yêu cầu patch/handoff thay vì overwrite.

## 6. Kiểm thử nghiệm thu cụ thể, chống "có code nhưng không có game"

| Test/cảnh chơi | Input thật | Output/receipt phải có | Fail cứng |
|---|---|---|---|
| Onboarding | NewGame → dựng Nhà → tuyển thật | Nhà có chi phí, candidate nhận đúng, roster+1, Save | Item/tiền free không nguồn, UI bấm mà không đổi |
| Mine/Forest | chọn worker/mỏ/lâm + chạy đủ timer | đúng ID/qty vào một Kho; nghề EXP một lần | Lặp receipt, công việc x2, mất worker |
| Field | chọn Linh Cốc/Thanh Linh Thảo, trả giống | plot đúng ETA, thu vào Warehouse và can replant | Kho hiển thị sai nguồn, âm tiền |
| Alchemy | chọn recipe authored, worker/hall hợp lệ | nguyên liệu trừ 1 lần, đan đúng số sau timer, cold Save không mint | Job hoàn thành nhưng thuốc mất/nhân đôi |
| Combat interface | đội thật vào bản đồ có source | loot+XP receipt, Đan đã trừ, Injury riêng HP, Save | duplicate, HP=1 sau hồi sinh V2, 1000 passive XP bị thay |
| Gear | forge 1 recipe có nguồn, cấp cho đệ tử | item instance/owner+slot, saved, combat side read-only reports delta | bán và đeo cùng item, cấp vật phẩm giả |
| Economy | no-tax/100%-tax, 0 viên thuốc, 0 tiền, 30 đệ tử | bù trừ lương/thuế minh bạch, đường hồi miễn phí, không softlock | thiếu vốn vĩnh viễn không thể tiến |
| UI/launcher | mouse/touch từ launcher chính | 1280x720 legible, scene không đóng khi đổi tác vụ, đúng Save sau restart | auto-close panel, crash, nút che nút |

### Yêu cầu hồ sơ bằng chứng tối thiểu

Ghi vào CURRENT_CHECKPOINT sau mỗi gate: `gate / source SHA / files / test command / workflow run ID / step exit / focused & cumulative / ledger deltas / screenshot state / known fail / owner-physical PENDING / next gate`. Không gắn 'DONE' từ source-only hoặc simulated 30 ngày. Không ghi lại thiết kế bị hủy (chữa HP bằng 3 LT/10HP).

## 7. Cổng đầu tiên có thể thực hiện ngay — GP0 O9 + GP02/Economy (không combat)

1. Fetch HEAD mới nhất, xem `git diff` đối với `p3_2_landscape_sect.gd` và writer ownership; đọc trực tiếp O9 lỗi `Kho không thấy Thanh Linh Thảo`.
2. Reproduce O9 với đúng seed/timer; **đầu tiên chạy read-only diagnostics**: tồn Kho trước/trong/sau luyện, plot ETA, nhu cầu đứng chờ, UI projection; xác định bug source vs UI vs test contract.
3. Chỉ sửa đường không-combat có bằng chứng. Không tăng số cây/tiền/Đan để ngụy trang test. Không đổi active producer job hoặc Save cũ.
4. Focused official Godot 4.7.2 O9 + O4/O5/O7/O8; GP02C1/GP02B1/Economy-A; cold reload, One Active Job; trước khi nâng GP1 báo SHA+log, no fake PASS.
5. Chuẩn hóa guide first-time theo source thật, nếu O9 đã đủ xanh. Sau đó GP1→GP3 để sớm có gameplay r1–r2 hoàn chỉnh trước khi đẩy mở rộng r3+.

## 8. Tổ chức Agent và quy tắc báo cáo

Agent contract độc lập: `/.agents/skills/tmb-gameplay-closure/SKILL.md`. Mỗi lượt agent: đọc `AGENTS.md` → source live/HEAD → `CURRENT_CHECKPOINT.md` → tài liệu này → đúng skill specialist cần dùng. **Một writer/subsystem**, không tự spawn nhiều agent hay Codex để đụng file khác, không tạo nhánh/merge. Khi bàn giao chat mới vẫn dùng **cùng** master MD, update status ở checkpoint/handoff chứ không tạo 7 roadmap mới.

### 3 lựa chọn tiếp công việc (luôn đưa cho user)

- **A — Đề xuất:** GP0: sửa O9 Thanh Linh Thảo/kho/đan + GP02/Economy theo log, focused/cumulative Godot đúng SHA, giao diện không giả, không combat.
- **B:** GP1–GP3: hoàn thiện nguyên liệu → Kho → Luyện Đan → thuốc ở r1–r2, chỉ sau khi G0 đã đủ green/baseline noted.
- **C:** GP8: chuẩn bị và chạy nghiệm thu launcher/one-save Windows 1280×720, Android nếu có môi trường, giữ physical PENDING khi không truy cập.

**Câu lệnh tiếp tục mặc định cho agent:** “Tiếp tục GP-PLAY01 trên PR #72 từ HEAD mới nhất; đọc AGENTS.md, CURRENT_CHECKPOINT.md, GP_PLAY01_WHOLE_GAME_AUDIT_AND_IMPLEMENTATION_PLAN_20261110.md và skill tmb-gameplay-closure; triển khai GP0 điều tra/sửa O9 production Warehouse Thanh Linh Thảo và related GP02/Economy có bằng chứng, không chỉnh combat/skill/VFX/monster, không tạo nhánh/merge/SaveService; chạy official Godot 4.7.2 focused+cumulative và ghi exact SHA/log cùng 2–3 options tiếp.” 
