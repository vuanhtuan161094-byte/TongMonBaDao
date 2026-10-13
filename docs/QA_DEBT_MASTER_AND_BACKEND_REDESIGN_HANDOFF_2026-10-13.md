# TÔNG MÔN BÁ ĐẠO — SỔ NỢ CHUNG + BÀN GIAO RÀ SOÁT BACKEND
Ngày: 2026-10-13 · Repository: `vuanhtuan161094-byte/TongMonBaDao` (`main`) · Engine: Godot **4.7.2**.
Tài liệu điều phối / kiểm thử, **không đổi luật chơi, không cấp phép sửa gameplay**.

## A. Authority và nguyên tắc mới của chủ dự án
1. Đọc `AGENTS.md` → `docs/GAME_SYSTEM_ARCHITECTURE.md` → `CURRENT_CHECKPOINT.md` → `NEXT_CHAT_HANDOFF.md` → tài liệu này → master spec / code / test live. Kiểm tra `main` HEAD lại; không suy code status từ tên tài liệu.
2. Chủ dự án muốn **tạm ngừng mở rộng backend**, rà sâu từ đầu lần lượt **nhân vật → nghề & công việc → công trình → kho/giao dịch → kinh tế game**, duyệt gameplay và luật thiết kế trước; mỗi phần/code packet riêng phải có phê duyệt cụ thể.
3. Trọng tâm là **game idle quản lý tông môn đơn giản, dễ chơi**, không tự tạo mô phỏng logistics/đường đi/vác hàng thành công thức sản lượng. Đệ tử **chỉ một công việc chủ động tại một thời điểm** (định hướng thiết kế cần audit chỗ chưa bảo đảm), Tu Vi thụ động không tính việc thứ hai.
4. **Mỏ: bốn mức thời lượng** là ý tưởng chủ dự án, ví dụ 1/2/4/8 giờ, **chưa khóa balance**. Đề xuất completion-based: giao người + mức → chạy timer → đến hạn quặng vào Kho một lần; hủy mất tiến độ; hoặc minute-credit nếu chủ dự án chọn. Chưa được tự thay BuildingSystem cũ trước thiết kế/migration/save/test.
5. NPC đi/đào/vác có thể chỉ là **visual AI animation**; gameplay authority vẫn ở timer/transaction, không phải footstep hoặc carried inventory. Nếu giữ logistics, phải cực kỳ đơn giản và được duyệt riêng.
6. Nguồn `vuanhtuan161094-byte/ZQZS-Source-Knowledge` dùng làm **benchmark, không phải backend authority**. `docs/PROFESSION_PRODUCTION.md` có bằng chứng client nghề/công trình/AI event planStart/planComplete; **thời gian và sản lượng thực trên server UNKNOWN**. Không tự suy hay copy balance.
7. Android LANDSCAPE 1280×720 là mục tiêu; Windows là máy phát triển/kiểm thử.

## B. SỔ NỢ CHUNG — một điểm truy cập, không quên / không lẫn PASS
Danh mục chia ba loại: **AUTO-WIN** (launcher PC có thể chạy), **MANUAL-DEVICE** (cần thao tác/người thật/Android), **DESIGN-BACKLOG** (không thể được giải quyết bởi một bài test). Mỗi kết quả cần evidence/log/commit rõ.

| ID | Loại | Vấn đề / điều kiện đóng | Trạng thái tại bàn giao |
|---|---|---|---|
| Q01 | AUTO-WIN | GP-02C1 focused injury, legacy active/terminal PvE save migration, receipt exactly once; chạy official Godot Windows 4.7.2 trên HEAD gameplay hiện tại | **Linux CI PASS** [38369220631](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38369220631) tại gameplay `c8ec094c`; **Windows GP-02C1 PENDING** |
| Q02 | AUTO-WIN | GP-02C1 presentation scene smoke, trạng thái Injury từ canonical snapshot | Linux PASS; Windows GP-02C1 PENDING |
| Q03 | AUTO-WIN | O6 M1 end-to-end: mức `available_quantity(thanh_thiet)==4`, không tự sửa test/balance/warehouse để ép xanh; đối chiếu O5 | **O6 standalone FAIL 2 lần** [38360325913](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38360325913) trên **SHA cũ `a327ab59`**. Chưa xác lập origin vs `0a29f9c6`; chưa rerun standalone tại `c8ec094c` |
| Q04 | AUTO-WIN | P3.7 FULL cumulative regression trên Godot Windows 4.7.2 | Linux FULL PASS trên `c8ec094c`; GP-02B1 Windows 24/24 PASS trên **SHA cũ `0027878e`**, **không thay GP-02C1 Windows** |
| Q05 | MANUAL-DEVICE | Windows GUI/visual/manual launch GP-02C1; đệ tử bị hạ → màn thông tin bị thương → không PvE → vẫn sản xuất → tự hồi; ảnh chụp màn thật | PENDING USER |
| Q06 | MANUAL-DEVICE | Android touch/landscape, PvE, quay về tông môn, save/offline/đặt lại thiết bị; crash/kill thật, power/storage-full có giám sát an toàn | PENDING USER; **PC runner không thể xác nhận Android PASS** |
| Q07 | MANUAL-DEVICE | 100/500/1000/3000 disciples stress + RAM/tick/offline/save trên target hardware, tiêu chí hiệu năng phải khóa trước | UNVERIFIED; không được thay timer/tick âm thầm |
| Q08 | MANUAL-DEVICE | ENV-02A dùng matching owner ZIP có đầy đủ 35 PNGs; Windows Godot import/scene/camera/AStar/culling, 2 ảnh, Android touch/FPS | Windows/Android PENDING; GitHub `labs/env02a/` code-only không đủ tự chạy |
| Q09 | MANUAL-DEVICE | P3.6A Screenshot/Preview upload artifact; workflow cũ fail do GitHub quota, cần hình ảnh thật và kiểm tra thủ công | Workflow FAIL riêng ở upload; gameplay/capture gate cũ PASS. Không đồng nhất với code regression |
| Q10 | MANUAL-DEVICE | SAFE-01/02 real-device Android kill/low storage/backup/recovery | CI CLOSED, physical QA PENDING |
| Q11 | DESIGN-BACKLOG | DV2-03 A/B live partial; C–H/3 Ấn và 29 công thức/route nguồn; chốt riêng nếu resume | **PAUSED NOT CLOSED**; DV2-04 unopened |
| Q12 | DESIGN-BACKLOG | Global action/occupation ownership: one disciple-one active job; cancel/timeout/offline/recovery, current work_cycle/field/alchemy/PvE guards and HP/HEAL/REST | GP-02B1 guards + GP-02C1 PvE reservation PASS riêng; **chưa có occupation authority toàn cục** |
| Q13 | DESIGN-BACKLOG | Luật sản xuất từng công trình, bốn mức Mỏ, start/finish/cancel, sản lượng, warehouse reserve/anti-double-pay, animation-only transport | Cần audit & **design approval**, hiện code legacy travel/extract/haul, không sửa trong Injury |
| Q14 | DESIGN-BACKLOG | Kinh tế: resource faucets/sinks, craft/upgrade cost, time gating, rewards PvE, chống lạm phát, reserve, đầu/giữa/cuối game; không tự bịa giá hoặc balance | **Chưa khóa**; phải lập ledger giao dịch và mô phỏng giả định riêng |
| Q15 | DESIGN-BACKLOG | Đệ tử: lục duy, linh căn, huyết mạch, thể chất, thiên phú, passive vs active Tu Vi, Body, HP/Injury, combat/work consumer, P2/V2 compatibility | Chưa audit tổng thể effect coverage; `docs/DISCIPLE_MASTER_SCHEMA.md` là nguồn thiết kế |
| Q16 | DESIGN-BACKLOG | Map/building/land: future SectLayoutState, 192x192 / 48x48, 8 S3 artworks, Spine, UI production mapping, giá xây/mở đất | DESIGN APPROVED ONLY; ADR-0003 fixed-layout còn hiệu lực, LAY/FE-02 unopened |
| Q17 | DESIGN-BACKLOG | Mobile art & UI final: Source A matching, character 3 directions, Spine imports, on-device visual acceptance | PENDING; không tự ghi đè S3 art/rig |

### Trạng thái phase — KHÔNG ĐƯỢC TỰ ĐỘNG ĐÓNG
- GP-01 / GP-02A / GP-02B1: **CLOSED** theo các checkpoint/CI đã ghi.
- GP-02C1: code/legacy-save migration **DONE**, Linux focused/FULL **PASS**, nhưng tổng phase **OPEN** chờ xử lý Q03 và bằng chứng Q01/Q02/Q04 Windows + ngoại cảnh có phạm vi rõ.
- DV2-03: PAUSED NOT CLOSED; DV2-04, FE-02, LAY-01–04 chưa mở.
- Không có ủy quyền đổi `BuildingSystem`, `WarehouseSystem`, EXP, tu luyện, giá, bản đồ production, art hay save wire.

## C. Một file Windows: chạy QA tự động, không tự nhận hoàn thành nợ thủ công
File trong repository: `tools/qa/RUN-QA-DEBTS-WINDOWS.cmd`.

**Cách chạy:** sau khi đồng bộ `main` qua workflow `Sync-Main.cmd` theo AGENTS, mở **một** file CMD trên Windows. Launcher thực hiện version/preflight/import, GP-02C1 focused + presentation, O6, O5 và FULL. Xuất logs theo từng gate, `SUMMARY.txt`, environment SHA và danh mục nợ thiết bị còn lại vào thư mục `QA_DEBT_RESULTS\<timestamp>`. **Không push GitHub; không đổi gameplay; không xóa local save người chơi**, các test giữ trách nhiệm dọn save fixture `user://` riêng. CMD có thể FAIL vì thiếu asset import/runtime local: coi là INFRA/BLOCKED hoặc FAIL thực cần đọc log, không công bố success chỉ từ script file tồn tại.

**Lưu ý:** launcher được chuẩn bị từ nguồn CI/test thật nhưng chưa có chạy thử Windows thực tế ngay tại thời điểm tài liệu này được viết. Android/GUI/ENV02A ZIP/performance/fault injection sẽ ở `PENDING USER`; không tự giả lập kết quả. Nếu Q03 FAIL, ghi log, xin phép diagnostic A/B isolated cho SHA baseline `05ea66ed`, `0a29f9c6`, `c8ec094c`; **không checkout/reset repo production và không làm loãng O6 assertion**. Đối với nợ cần vật lý/thiết bị, chỉ đánh dấu CLOSED khi có ảnh/log/manual record độc lập.

## D. CHAT MỚI — Deep audit/backend redesign + economy (READ-ONLY first)
**Chủ dự án đã yêu cầu rà soát từ đầu từng phần, không cho phép tự code trong lượt bàn giao.**

Đọc thêm:
- `docs/DISCIPLE_MASTER_SCHEMA.md`, `docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md`, `docs/DISCIPLE_V2_DESIGN_LEDGER.md`.
- `docs/P3_7_BUILDING_TREE_SPEC.md`, `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`, `docs/P3_6_SECT_MASTER_GAMEPLAY_LOOP_SPEC.md`, `docs/design/SECT_BUILDING_LAND_EXPANSION_DESIGN_V1.md`.
- `docs/handoffs/NEXT_CHAT_GAMEPLAY_DISCIPLE_TO_SECT_2026-10-13.md`.
- Kèm source thực: `DiscipleState`, recruitment/generator, profession, `WorkforceSystem`, `SimulationScheduler`, `BuildingSystem`, `WarehouseSystem`, `SimulationState`, `SaveService`, `HuntingPveRunV2`, cultivation, tests, UI command ingress.
- Source Knowledge: `docs/PROFESSION_PRODUCTION.md` và mã Lua chứng minh hành vi client, tách **VERIFIED CLIENT** với **UNKNOWN SERVER**.

### Thứ tự rà và đầu ra
**I. Nhân vật/đệ tử:** định nghĩa nền tảng (lục duy, linh căn, cơ duyên, nghề, thiên phú, HP, Thương Thế, thân phận), progression/tăng sức mạnh, bắt đầu/phân công/nghỉ/hủy, một action chủ động; bảng trạng thái chuyển/ưu tiên và hiệu ứng thật.
**II. Nghề & action:** mọi hành động (WORK/CULTIVATE/BODY/REST/HEAL/PvE); truth owner; guard chéo/cancel, offline/restart/AI, ẩn số; thiết kế tối giản và migration implications.
**III. Công trình:** từng nhà có chức năng, slots, inputs, thời gian, outputs, upgrade/unlock, cancel, UI, dependency; phân loại ACTIVE/IMPLEMENTED/PARTIAL/DESIGN-ONLY; đề xuất mẫu giao dịch/timer thống nhất chứ không implement framework ngay.
**IV. Economy:** thiết lập bảng `source → amount/time → warehouse → sink → output/value`, tiền/tài nguyên chính, biến động theo thời gian, tránh duplicate và runaway inflation; phân biệt **đã khóa** / **đề xuất** / **chưa rõ**. Xây mô hình kiểm tra balance (không áp tự động).
**V. So với 最强祖师:** học UX/workflow/layer separation nếu có chứng cứ; không suy server yield hoặc copy lối gameplay không cần.
**VI. Kế hoạch triển khai:** đưa **một gói nhỏ nhất** để chủ duyệt code sau khi duyệt rule, allowlist đúng, migration/save safety, acceptance test Godot 4.7.2, O6 debt isolation.

Yêu cầu báo cáo: mỗi hàng `Luật người chơi → Code owner → Nguồn chứng cứ → Hiện trạng → Sự phức tạp dư thừa → Luật đề xuất → Hệ quả save/economy → PASS gate`. Không thay runtime, docs design chính thức, workflows hay `main` trước khi chủ dự án phê duyệt packet. **Đừng khởi động O6 điều tra vào luồng thiết kế/kinh tế; để ở sổ nợ Q03.**

## E. Source/evidence tại thời điểm tạo tài liệu
- GP-02C1 code SHA `c8ec094c0bc8653b1438172de1d9338a6c0d28ea`, [Linux official CI SUCCESS](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38369220631).
- O6 historical [FAIL run](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38360325913), no proven attribution.
- Previous GP-02B1 Windows full 24/24 PASS evidence documented at the top of `CURRENT_CHECKPOINT.md`; not new GP-02C1 evidence.
- Source reference: [ZQZS production research](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/docs/PROFESSION_PRODUCTION.md).

**END. Chỉ dùng sổ nợ để tránh quên; một file PC không biến manual/Android checks thành PASS.**
