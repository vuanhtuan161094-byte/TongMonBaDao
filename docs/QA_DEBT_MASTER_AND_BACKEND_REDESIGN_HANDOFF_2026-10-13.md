# TÔNG MÔN BÁ ĐẠO — SỔ NỢ CHUNG + BÀN GIAO RÀ SOÁT BACKEND

## GUI-WORKFORCE-V1 — 2026-10-15 · BRANCH CODE / PENDING QA

- **Owner and scope:** GUI presentation owner only: `godot/src/presentation/p3_2_landscape_sect.gd`, `godot/tests/presentation/gui_workforce_v1_picker_test.gd`, this existing canonical ledger and checkpoint/handoff. PR #2 draft, branch `gui-workforce-v1-20261015`; baseline `main=461caca1171462e0da092f21108c5c1733157ad9`. No Backend, Economy, Warehouse, Scheduler, SaveService or balance edits allowed.
- **Backend audit result:** `assign_group` may terminate an older work cycle, `assign_worksite` changes real worker location, `issue_command` may cancel a running timer or other occupation. Existing V2 Field plots, Alchemy jobs, Body training and PvE reservations have guards. Picker therefore filters with read-only actual state and refuses silent transfer; dispatch uses existing Workforce/Training APIs, never writes disciple keys directly.
- **UI-DEFECT-01/02/03:** implementation targets readable name contrast, width-safe 384px row and layout with controls above building descriptions. Code updated on draft branch; **do not mark GUI PASS** until real Windows video after regression. Secondary user-reported defect: unusable worker allocation for Mine/Field; implementation adds shared modal, search, status, profession ranking, real slot and pagination for six facility types.
- **Compatibility/debt:** older `Group_*`, `FieldGroup_*`, `Work_*` retained in hidden advanced section; focused O3/O4/O5/O6/O7/O8/O9/P3.7 FULL still **NOT RUN on branch**. Legacy large-roster advanced control panel shows max first 24 while picker filters full state (8 rows per page); target scale and GUI interactions with 1000–3000 are **PENDING USER**, not benchmarked.
- **Acceptance:** exact-SHA Godot 4.7.2 import, focused `gui_workforce_v1_picker_test.gd` and cumulative regression, GUI videos of Mine/Field selection. Linux Actions quota exhausted, no Linux PASS. Maintain Economy-A previous acceptance and GP-02C1 overall OPEN, DV2-03 PAUSED.

---

## BẰNG CHỨNG WINDOWS GUI THỰC — 2026-10-15 14:43–14:48 UTC+07

- **Evidence mới, không thay đổi gameplay:** owner-uploaded `20261015_144302.zip` SHA-256 `a1aca095366dc701c0e6408491c157d54b66983a420a05eb77bf9f791c42fb3c` và video quay màn hình `Tong Mon Ba Dao (DEBUG) 2026-10-15 14-44-41.mp4` SHA-256 `31a7c44370e290935d379df5d2df7c2f5eee86b5ecf7c377f170813cf579ef18` (~61 giây, 1920×1004 recording). Tệp nguồn do user upload trong chat, **không tự có trên GitHub**.
- **SYNC PASS:** local `main` fast-forward từ `0439b34b...` sang đúng remote `5e6fdd966bdf710b71e2a1539bb712e44069a4bb`. Tracked clean; 17 untracked preserved. Detached QA worktree tại đúng SHA; Stage A pack validated; official Windows Godot `4.7.2.stable.official.ed1daf0bf` project import exit 0. GUI started successfully, map/camera/building panels interacted with in supplied video. Không có observed visual crash trong đoạn ghi hình.
- **GUI QA = PARTIAL / NOT ACCEPTED.** Runner says `GUI run: STILL_RUNNING_USER_MUST_CLOSE`, so no final process exit code. Captured screenshot `economy_a_gui_01.png` accidentally contains console window rather than game; separate owner video provides GUI evidence. Video covers Mine, Forge, Body Training, Medicine and camera/pan/zoom, **not Main Hall Economy-A enable, Market buy/sell, authentic V2 timers/payroll or personal auto spending**. Isolated saved `SectState` has no `economy_a_enabled` serialized field, consistent with Economy-A remaining opt-out in this manual session. 18/18 Windows headless PASS from the previous run is separate evidence and remains valid.
- **GUI-DEFECT-01 (CONFIRMED):** disciple name rows in building management are extremely low contrast (light/default label font against light paper); `p3_2_landscape_sect.gd::_new_management_row()` does not set readable `font_color` on name labels.
- **GUI-DEFECT-02 (CONFIRMED):** Mine worker action row requires at least approx. `190+70+76+82+3*6=436` px but parent content target width is 384 px. The last action is visibly clipped and horizontal scrolling appears in the video.
- **GUI-DEFECT-03 (CONFIRMED):** building_operation_body normally reserves `420` px before action controls inside a 442-px scroll, forcing important worker/management controls far down and obscuring actionable controls on 1280×720 landscape.
- **QA packaging debt:** owner ZIP contains the entire `ISOLATED_GAME_WORKTREE` and private sandbox save/cache; next evidence submission should upload only existing `UPLOAD_EVIDENCE_ONLY.zip` plus video/screenshots. Do not put private save/cache and source worktree in routine evidence archives. No runtime/UI changes authorized by these findings.
- **Next code permission if owner chooses:** a bounded `GUI-FIX-01` presentation-only packet; update contrast, row layout, visible controls/scroll UX without touching EconomySystem, Warehouse, Scheduler, SaveService, Injuries, O6 or balance; add a real 1280×720 UI test and re-run Windows Godot focused + P3.7 FULL/O6. Physical/manual Economy-A acceptance still OPEN until toggle/market/timer interaction evidence.

---


## CẬP NHẬT KIỂM KÊ — 2026-10-15, SAU MERGE ECONOMY-A

- **ECONOMY-A CODE / INTEGRATION: CLOSED — Windows automated verification.** PR #1 merged at GitHub `main` commit `0689d0ddf0ebd72463d08bad4835c60428c64d24`; gameplay/test SHA `95bf06ecfd2c7fce5026d4485af55a5a3c40d909` and documentation-only PR HEAD `4a6937dc28d477be13ffc0283d44cc74fe610733`. Owner-uploaded `20261015_135007.zip` (SHA256 `2d35d82d7eadf44ae06407c3899a36facf480c05b14c2922b22041062d3531f6`) provides official Windows Godot 4.7.2 detached-worktree QA: **18/18 PASS, 0 FAIL** including Economy-A sim/UI, GP01/02A/02B1/02C1, O3–O9 including O6 unchanged, SAFE01/02 and P3.7 FULL. Local QA did not modify user's original checkout or saves. Prior branch-in-progress table below is historical/superseded, not current merge status.
- **PENDING CI (nonblocking for this owner-directed Windows acceptance):** exact-SHA Linux Actions [#38684703913](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38684703913) could not start runner on three attempts; owner's Actions quota reported exhausted. Do not infer Linux PASS or gameplay regression.
- **PENDING USER / DEVICE:** Windows graphical manual scene/screenshots, Android APK/landscape/touch, real kill/power/storage recovery, 100/500/1000/3000 disciple performance. Automated headless Windows scene PASS is NOT human visual or Android acceptance.
- **GP-02C1 overall QA OPEN; DV2-03 PAUSED; DV2-04/FE-02/Economy-B/C outside scope.** Q03/O6 current Economy-A automated Windows PASS, old-SHA O6 differential attribution remains optional historical issue. Q01/Q02/Q04 latest *headless* Windows automated gates PASS but physical/manual Q05–Q10 remain PENDING. ACTION-GUARD-01, CHAR-AUDIT and CHAR-ISO remain DESIGN/BLOCKED; no closure implied by Economy-A merge.
- **Next priority:** safe sync of local game checkout and targeted physical GUI/device QA; then resume separately authorized character/action/production design debt. Do not replace canonical debt register or reinterpret Economy-A pilot values as locked.

---

Ngày: 2026-10-13 · Repository: `vuanhtuan161094-byte/TongMonBaDao` (`main`) · Engine: Godot **4.7.2**.
Tài liệu điều phối / kiểm thử, **không đổi luật chơi, không cấp phép sửa gameplay**.

## BẢN KIỂM KÊ HIỆN HÀNH — 2026-10-15, BASELINE `c64c610`

Bảng này cập nhật trạng thái hiện hành trong **chính sổ nợ canonical này**; các dòng Q01–Q13 phía dưới là bản ghi lịch sử ngày 13/10, không còn là kết luận current-SHA. Economy-A CODE-A cũ đã đạt Linux Godot 4.7.2 focused/FULL/O6 tại `ed594e45` ([run 38678314842](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38678314842)). Lệnh chủ mới mở đầy đủ Economy-A, phát hiện thiếu merchant buy/stock và cap tự chi; branch `economy-a-market-completion-20261015` đang sửa trong allowlist. `40eaa214` đạt [focused/FULL/O6 official CI](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38682499335) cho merchant-buy trước cap tự chi. Owner đã phê duyệt thêm `BuildingSystem` để đóng đường giao hàng/lương Field và Alchemy. SHA gameplay/test `95bf06e` đạt local Windows Godot 4.7.2 focused/UI/O4/O8/O9/O6 với user data cô lập; FULL Windows 4.7.2 đã PASS (exit 0) tại `95bf06e`; Linux CI exact-SHA còn chờ runner. Các Actions trung gian thất bại không có runner/step, không được coi là assertion FAIL hay PASS. Các file shared khác không có owner cạnh tranh được phát hiện qua open PR search; kiểm tra lại trước merge.

| Mã / nhóm | Owner và file liên quan | Nguyên nhân / ảnh hưởng / bằng chứng | Trạng thái hiện hành và bước tiếp |
|---|---|---|---|
| ECONOMY-A | Economy integration; `economy_system.gd`, `sect_state.gd`, `building_system.gd`, `p3_2_landscape_sect.gd`, dedicated tests | CODE-A cũ thiếu chiều mua/merchant stock, auto daily cap và Field/Alchemy payroll; current branch bổ sung sau owner approval. | **CODE VERIFIED Windows / PENDING Linux CI**; Windows focused/UI/GP/O3–O9/SAFE/P3.7 FULL PASS tại `95bf06e`. |
| ECONOMY-A A2 Field/Alchemy wages | Owner-approved Building integration; `godot/src/simulation/building/building_system.gd` plus existing EconomySystem | New authentic V2 Field plots and Alchemy jobs record wage eligibility; failed Warehouse delivery retains timed work, output success precedes one Sect-funded wage receipt. Old jobs do not gain retrospective wage. | **IMPLEMENTED / Windows focused+O4/O8/O9/O6+FULL PASS at `95bf06e`**; Linux exact-SHA PENDING runner, physical QA PENDING USER. |
| Q13 | Building/Workforce; `building_system.gd`, `workforce_system.gd` | V2 Mine/Forest timer + legacy carry drain đã có focused/offline chứng cứ `ed594e45`; các mức 1/2/4/8 giờ chỉ là thiết kế. | V2 Economy-A timer **CLOSED VERIFIED Linux** tại `ed594e45`; lựa chọn nhiều mức thời lượng **DESIGN ONLY**, packet khác. |
| Q03 / O6 | O6 QA owner; `p3_o6_m1_release_rehearsal_test.gd` | Fail lịch sử ở `a327ab59` chưa rõ nguyên nhân; assertion `==4` nguyên vẹn; standalone PASS tại `ed594e45` và `40eaa214`. | O6 current prior SHA **CLOSED VERIFIED Linux**; historical attribution **BLOCKED** pending optional differential audit; latest branch O6 **PASS local Windows isolated `95bf06e`; Linux exact-SHA PENDING CI**. |
| GP-02C1 / Q01–Q02 | Injury QA; `gp_02c1_injury_settlement_test.gd`, presentation test | Linux focused/FULL PASS `ed594e45`; Windows/manual/device chưa có bằng chứng. Injury 0/1 không đổi. | Gameplay **CLOSED VERIFIED Linux**; overall **PENDING USER**, không đóng GP-02C1. |
| GP-01/02A/02B1 | Respective owners; focused tests/workflows | Official Linux regression PASS `ed594e45` và `40eaa214`. | **CLOSED VERIFIED Linux** at cited SHAs; latest branch **PENDING CI**. |
| O3/O5/O7/O8/O9 | Production owners; respective `p3_o*_test.gd` | Official Linux regression PASS `ed594e45` và `40eaa214`. | **CLOSED VERIFIED Linux** at cited SHAs; latest branch **PENDING CI**. |
| SAFE / Q04 | Save/Warehouse owners; `save_service.gd`, SAFE tests, P3.7 FULL | SAFE + FULL PASS `ed594e45` và `40eaa214`; real device failure cases untested. | **CLOSED VERIFIED Linux**, current extension Windows FULL **PASS `95bf06e`**, Linux CI PENDING, device **PENDING USER**. |
| ACTION-GUARD-01 / Q12 | Character/Workforce owner; `workforce_system.gd`, `NEXT_CHAT_HANDOFF.md` | Existing occupation guards tested, global action guard audit not closed. | **DESIGN ONLY / BLOCKED outside Economy-A**; scope smallest guard diff before code authorization. |
| CHAR-AUDIT-01/01B | Character owner; `DISCIPLE_MASTER_SCHEMA.md`, `CURRENT_CHECKPOINT.md` | Wider character-source and data audit is not evidenced by Economy-A gates. | **BLOCKED outside allowlist**; dedicated read-only data audit. |
| CHAR-ISO-00 | Character owner; `DISCIPLE_V2_ROOT_ARCHITECTURE.md` | Isolation proposal has no Economy-A code authority. | **DESIGN ONLY**; require distinct code packet. |
| DV2-03 | Disciple V2 owner; `DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md` | Residual content/runtime work remains independent. | **PAUSED**, never relabel CLOSED from Economy-A regression. |
| DV2-04 | Disciple V2 owner; `CURRENT_CHECKPOINT.md` | Phase not opened. | **FUTURE PHASE**. |
| ENV-02A / PV-02 | Map/visual owners; `docs/handoffs/ENV02A_CODE_AND_BACKEND_AUDIT_2026-10-13.md`, `NEXT_CHAT_HANDOFF.md` | Device map checks and visual candidate decision absent. | **PENDING USER / FUTURE PHASE**; no production scene/art integration. |
| FE-02 / Spine / Source A | Frontend/asset owners; ADR-0003 and handoff | Production frontend art gate separate, visual approval pending. | **FUTURE PHASE / PENDING USER**; no Economy-A authority. |
| Windows / Android / 1k–3k | QA/device owner; `tools/qa/RUN-QA-DEBTS-WINDOWS.cmd` and device harness | Headless local Windows focused Economy-A passed for branch, but no full manual GUI/touch/APK, actual storage/power or scale evidence. | **PENDING USER**; record exact hardware logs before PASS. |

**Next authorized work in this branch:** obtain latest exact-SHA Linux CI once Actions assigns a runner, preserve old O6 assertion and valid `carried_units`, inspect diff/ownership, then propose integration. Windows official 4.7.2 FULL and required focused regressions already PASS at gameplay/test `95bf06e`; #38684703913 attempt 2 had zero runner/steps. Any broader action-guard, character, Injury, FE, DV2, map, or Economy-B/C fix needs its own allowlist and approval. No test assertion was removed or relaxed in this extension.


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
