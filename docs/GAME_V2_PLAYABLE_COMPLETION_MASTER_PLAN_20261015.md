# TÔNG MÔN BÁ ĐẠO — MASTER PLAN HOÀN THIỆN GAME V2 (15/10/2026)

**Trạng thái:** AUDIT + PLAN ONLY, chưa cấp phép sửa production/code, chưa QA trên commit mới.  
**Engine:** Godot 4.7.2, Android landscape 1280×720. Unity pilot/Spine runtime: PAUSED.  
**Gameplay source of truth:** `TongMonBaDao/main` @ `461caca1171462e0da092f21108c5c1733157ad9`.  
**Nguồn đối chiếu UI/Unity-Lua:** `vuanhtuan161094-byte/ZQZS-Source-Knowledge`; chỉ học client interaction + layout + config có bằng chứng, không bê giả định server, balance hoặc thay gameplay V2.  
**Mục tiêu:** MỘT game mở chơi được và nhìn như game tu tiên quản lý tông môn; không lập thêm roadmap phân tán, không mở hệ mới khi lõi chưa chơi tốt.

## A. Kết luận quản trị

1. Ưu tiên **một đường chơi thật**: mở Tông Môn → chọn một Mỏ → một đệ tử được nhận việc → timer thật → quặng vào kho canonical → EXP/lương thật → dùng tài nguyên → lưu/tải. Sau đó mới mở rộng Linh Điền/Linh Lâm/Luyện Đan/Luyện Khí/PvE.
2. **Luật mới do chủ dự án chốt 15/10:** MỘT MỎ chỉ có MỘT đệ tử, tại mọi cấp. Đầu ra khai thác phụ thuộc cấp đệ tử và Lục Duy theo kênh hợp lý. Đây là thay đổi GAMEPLAY, không che các slot bổ sung ở UI.
3. **Chủ dự án đồng ý reset SAVE THỬ NGHIỆM** khi đổi luật Mỏ. Không viết migration để giữ nguyên nhân sự/quặng trong các save thử. Reset phải rõ ràng và giới hạn ở dữ liệu thử nghiệm game, không xóa file cá nhân/asset/worktree/untracked. Sau khi reset, save/offline và exactly-once của phiên mới vẫn bắt buộc.
4. Không xây thêm scheduler/warehouse/occupation-manager/economy song song. Một authority cho việc, thời gian, kho, công trình. Mọi UI đọc backend và phát lệnh.
5. Tập trung hoàn thiện giao diện 3 màn dùng thường xuyên trước: **Main Map → Building Quick Panel → Chọn đệ tử**. Chất lượng hình phải dựa trên asset xác minh (Source A hoặc art tự tạo), không chấp nhận bảng kỹ thuật và mockup không chạy.
6. Mỗi CODE packet có owner, allowlist, kiểm thử focused + affected cumulative, ảnh Godot thực và status thật; không lập 20 tài liệu nhỏ thay cho cải thiện game.

## B. Tình trạng hiện tại — có bằng chứng và giới hạn

| Hệ | Bằng chứng trong main | Kết luận hành động |
|---|---|---|
| Simulation và single clock | `SimulationScheduler`, `SimulationRuntimeOwnerV2`, `SimulationRuntimeClockV2`, save | GIỮ; audit đường đổi việc và offline, không lập đồng hồ thứ hai |
| Nhân vật | `DiscipleState`, `FoundationSystem`, `WorkforceSystem`, Tu Vi/Body/Injury 0/1 | Dùng dữ liệu thật; audit selection, action, occupation và profession; không thiết kế nhân vật từ đầu |
| Mỏ | `BuildingSystem.DEFINITIONS["mine"]`: `base_worker_slots=2`, `worker_slot_every=5`; `worker_slots()` tăng | **SAI LUẬT MỚI**; sửa core/fixture, không chỉ đổi 2/3 thành 1/1 trong UI |
| Mỏ output | `_start_resource_timer()` snapshot `output_quantity=_resource_job_batch_units(producer)`; `_resource_job_batch_units()` dùng cấp CÔNG TRÌNH | Bổ sung phép tính có owner rõ, dựa vào người làm thật, không nhân hai lần work-speed |
| Cấp nghề | `WorkforceSystem.profession_level_for_state()`; P3.7 `floor(sqrt(XP/24))`; `ProfessionModifierSystem` | Đề xuất dùng **cấp nghề Khai Khoáng** làm `cấp` đầu ra, KHÔNG tự dùng cảnh giới Tu Vi |
| Lục Duy | `FoundationSystem` sáu trục, nghiệp vụ hiện có theo kênh; `DV2_PRODUCTION_RESULT_CONTRACT_V1` DESIGN | Cần một chính sách outcome typed riêng cho Mỏ, không gộp cả sáu thành một `WorkPower` ảo |
| Đổi nhân sự | `WorkforceSystem.assign_group` + `assign_worksite` là hai lệnh; `assigned_worker_ids` có fallback nhóm ở primary building | Nguy cơ nhiều người `assigned` nhưng chỉ `active` bị cắt theo slot; cần một lệnh phân công Mỏ **nguyên tử** |
| Vòng producer | Mine/Forest timed jobs Economy-A, Field plots, Alchemy timers, Forge consumer | Đã có backend đáng kể; kiểm tra end-to-end qua game thực, không làm lại |
| Economy-A | PR #1 merged; official Windows Godot 4.7.2 headless **18/18 PASS** ở gameplay/test SHA `95bf06e...` | Code integrated nhưng GUI thật chưa accepted. Pilot price/duration/wage chưa phải balance cuối |
| UI | main `p3_2_landscape_sect.gd` ~3498 dòng; GUI PR #2 thêm picker bằng row/text; video xác nhận contrast/width/scroll defect | Thay lối present, tái sử dụng logic picker PR2 sau khi QA, không merge mù |
| Source A | `source_a_candidate_manifest.json` có 13 mô hình, Mỏ `520051` VERIFIED candidate; kho GitHub chủ yếu metadata, không chứa PNG đúng source | Cần lấy đúng asset pack tối thiểu và hash; PV-01/ENV-01 PASS chỉ là lab, chưa chứng minh UI live production |
| Map & layout | ENV-02A 192×192, chunk 16×16; building placement/expansion design approved, code chưa mở | Để sau lõi phân việc/sản xuất, không làm bản đồ lớn thay cho gameplay |
| QA/device | Windows headless 18/18 Economy-A ở commit cũ; PR2 chưa runtime gate; Android physical PENDING | Tách backend PASS, Windows visual PASS, Android PASS, scale PASS; không trộn bằng chứng |

### GUI defects thực tế trong `docs/QA_DEBT_MASTER_AND_BACKEND_REDESIGN_HANDOFF_2026-10-13.md`
- Chữ tên đệ tử quá thấp tương phản trên nền giấy.
- Row quản lý Mỏ ~436px nhưng vùng cha ~384px, hành động bị cắt và scroll ngang.
- Khối thông tin công trình chiếm 420px trong scroll ~442px, khiến nút cần dùng bị đẩy khỏi màn hình.
- Video GUI không chứng minh Economy-A đã bật hoặc đã thao tác hoàn chỉnh các vòng market/timer/payroll. Không gọi GUI PASS.

### Nguồn ZQZS/Unity-Lua đã kiểm tra
- `sources/AndroidData/binary/gui.windows.manufacture.uimdiscipleselect_TextAsset_-7732737977019007156.bin.lua`: slot role-list, search, chọn/cho thôi việc.
- `...uimdiscipleselect_manager_TextAsset_-5550305269121807973.bin.lua`: check trạng thái `eSelectWork`, cấp nghề `getDiscipleJobLevel`, chọn người phù hợp, thứ tự ưu tiên, scroll item tạo trì hoãn; tính năng `Thay thế`/khả năng chọn gợi ý.
- `...gui.windows.manufacture.uibuildinginfowin_TextAsset_6753192775076251433.bin.lua`: tầng thông tin tên/cấp/chi phí/progress.
- `...gamesys.home.zongmencontrol_TextAsset_1880845611734797181.bin.lua`: `reqChangeBuildingManager` gửi 3,44 ở client; **không khẳng định công thức server**.
- `docs/HOME_BUILDING.md`: cấu trúc vị trí/cửa/đường/map reference; thuật toán native `_MapManager` và kết quả sản lượng server không có thân hàm.
**Rút ra:** học quy trình `chạm nhà → xem người đang phụ trách → đổi người → thấy hệ quả`, trình bày bằng portrait, lọc theo khả năng nghề, không sao chép networking/unknown balances.

## C. Hai mốc thành công, để dự án không lan man

**Mốc P (PLAYABLE CORE)** — người chơi làm được toàn bộ 8 bước bằng UI Godot thật: (1) mở game; (2) vào Mỏ; (3) chọn 1 đệ tử thích hợp; (4) thấy timer/output explanation; (5) thu nhập kho/lương/EXP; (6) gửi người đến Linh Điền/Linh Lâm/Luyện Đan/Luyện Khí; (7) dùng tài nguyên ít nhất một lần; (8) lưu–thoát–mở lại, không mất/nhân tài nguyên. Giao diện đọc được, 1280×720 landscape. Đây là mục tiêu **ưu tiên tuyệt đối**.

**Mốc R (ANDROID PLAYABLE V1)** — sau Mốc P: recruitment/nhân vật đầy đủ dùng được, PvE loop dễ thao tác, bản đồ/camera/touch Android, tối ưu asset và FPS trên thiết bị, 1 quy trình kiểm thử/đóng gói đơn giản. **Không đợi hoàn thành tất cả nghề/môn phái/rare event/1k–3k mới ra bản chơi được.**

## D. Thứ tự CODE packets — đề xuất kiểm soát theo đầu ra, không phải tuần/ngày

### P0 — BASELINE + CLEAN START (một PR nhỏ)
**Mục tiêu:** biết một lần mở game đang chạy luật nào; không lẫn code old/offline opt-out.
- Ghi startup scene/factory path, ID Mỏ thật, group mặc định, nút Economy-A bật ở đâu, dữ liệu hiển thị.
- Thêm nút/chế độ DEV reset dùng riêng cho test hoặc thao tác clear-save tường minh; không xóa untracked/asset hay các thư mục ngoài user:// game cụ thể. Game lúc phát triển **không cam kết nâng cấp save thử cũ**.
- Tách test fresh game: đệ tử, initial resources, Economy-A flag, Mine/Field/Forest/Alchemy tồn tại và có đủ điều kiện khởi chạy.
- Deliverable: trạng thái clean fresh-start tái lập và một startup QA report ngắn, không cần tài liệu dài.
- **Gate:** focused fresh-start, SaveService clean roundtrip; old regressions không bị đổi chỉ vì chạy reset.

### P1 — MINE-ONE-OWNER (đơn vị CODE gameplay đầu tiên, ưu tiên #1)
**Mục tiêu:** Mỏ thật 1/1, 1 worker tối đa, sản xuất chịu ảnh hưởng cá nhân.
- `BuildingSystem.DEFINITIONS["mine"]`: worker slot luôn 1; không gia tăng theo cấp. `worker_slots()` trả 1 cho Mỏ dù level=1/5/100.
- Factory initial assignment **không auto giữ hai thợ Mỏ**, không còn logic nhóm-only tạo người chờ ở cùng Mỏ. Audit `assigned_worker_ids`, `active_worker_ids`, `can_disciple_work`, `building_for_profession`, `work_available`.
- Một API phân công **atomic**: validate candidate availability, current work, target Mine active, 0/1 capacity → assign work group + worksite + optional command cùng một thao tác; reject không để tình trạng gán nhóm nhưng mất worksite. Thay người chỉ hợp lệ nếu người cũ rảnh/hết mẻ hoặc phát lệnh dừng với hậu quả được thông báo. Không phá One Active Job.
- Kết quả mẻ tính từ `MineOutcomeResolver` nhỏ hoặc helper **thuộc BuildingSystem**: đầu vào actual disciple id/current skill/current Lục Duy + building grade + recipe. Không tạo manager/warehouse mới. `output_quantity` snapshot ở lúc bắt đầu timer để không đổi số giữa mẻ khi tăng EXP, có giải thích được trên UI.
- **Phân vai thuộc tính đề xuất, cần khóa balance:** Level nghề và work-speed → throughput; Căn Cốt có thể tác động output đúng loại Mỏ; Thông Tuệ → XP nghề (đã khóa), Cơ Duyên → rare event hợp lệ; Tư Chất → Tu Vi, Tiềm Lực → trưởng thành; Mị Lực không tự nhân quặng. Nếu chủ dự án muốn **Tổng Lục Duy trực tiếp cộng lượng quặng**, phải chốt ngưỡng/hệ số/rounding trong packet này. Chưa được tự áp mọi trục thành phần trăm output.
- Để PLAYABLE nhanh, đề xuất đầu tiên chỉ **Thanh Thiết thường + quantity integer**, không mở tier/đặc sản hiếm mới; giá trị 2/mẻ hiện tại là pilot baseline, không khóa.
- DEV save cũ được **bắt đầu lại**; không viết migration giữ quặng/worker trên bản chơi thử. Test mới vẫn bắt buộc chứng minh tick/claim/output/wage exactly-once.
- Test: Lv1, Lv5, Lv100 = 1 slot; xếp 2 người FAIL; 2 Mỏ mỗi Mỏ 1; idle/busy/PvE/Injury; skill low/high; Lục Duy thấp/cao; snapshot mẻ; save/reload; warehouse full; duplicate receipt; offline. O3 fixture cũ giả định 2 worker phải **chuyển thành test đúng luật mới có lý do**, không xóa test. O6 trước đây `==4` cho 2 packet phải có fixture/công thức tương thích hoặc thay assertion CHỈ khi chủ dự án duyệt outcome mới, không sửa test để che bug.
- **Gate:** focused P1, Economy-A, GP-01, GP-02B1/02C1, O3/O5/O6/O7/O9, SAFE, FULL; exact-SHA, không đổi Injury.

### P2 — WORKFORCE ONE-CLICK (sau P1, presentation + command safety)
- Tách picker đang có trong draft PR2 thành một thành phần Godot reusable, **không tự merge PR2**. Dữ liệu portrait/name/level/job/reason đọc canonical state.
- Người chơi chạm một ô đệ tử trống của Mỏ → chọn qua danh sách có chân dung, search, lọc `Rảnh` và sắp xếp **phù hợp khai khoáng** → một nút `Phân công` → hiển thị worker + tiến độ thật.
- Nếu đã đủ 1/1: nút `Đổi đệ tử`, trả lời lý do nếu đang có mẻ không thể đổi; không cho chuyển ngầm từ Linh Điền/PvE.
- Cùng picker dùng cho Linh Lâm/Linh Điền/Luyện Đan/Rèn Thân, mỗi công trình có slot và điều kiện **theo backend loại đó**, tuyệt đối không ép tất cả thành 1 slot.
- Bỏ các nút Group/FieldGroup/Work thô khỏi **chế độ người chơi**; giữ tương thích test bằng adapter/DEV-only cho tới lúc test được migrate an toàn.
- Test UI real scene tại 1280×720, không scroll ngang/nút cắt/không đóng sai overlay; 100–3000 roster cần phân trang/virtualization theo lượng hiển thị.

### P3 — UI/ART 3 SCREENS (chất lượng thị giác; chỉ presentation)
- Screen 1: main map map-first, HUD sát mép, nhà có tên/progress cue, 1 selected-target panel; camera không ảnh hưởng UI.
- Screen 2: Mine right panel **một portrait 1/1**, cấp nghề/lục duy liên quan, real ETA/output, đổi người/quản lý; không fake số lượng.
- Screen 3: picker portrait cards/grid + filter/label phù hợp; ngôn ngữ giấy ngà, ngọc xanh, gỗ/vàng đồng/son đỏ.
- Dùng đúng source A texture được xác minh (Mỏ candidate `520051.png`, PV-01 Main Hall `510052`, Kho `510102`, Forge `520081`), nếu không có bytes thì không tự nhận đã tích hợp. Tối ưu pack các icon/panel thực sự dùng, bỏ intermediate rác; tạo art gốc thay vì chờ vô hạn.
- Tách `p3_2_landscape_sect.gd` thành component presentation rõ ràng khi hữu ích, không di chuyển simulation state sang UI.
- **Gate:** actual Godot 1280×720 screenshot/video do runtime tạo; người dùng duyệt bằng mắt. Code headless PASS một mình chưa đủ.

### P4 — ECONOMY & CÔNG TRÌNH VẬN HÀNH KHÉP KÍN
- Kết thúc đường **Mỏ → Kho → nâng cấp/chế tạo**, Linh Lâm → Kho, Linh Điền → thảo/cốc → Dược Phòng → Kho/tiêu dùng, tiền công tông môn → cá nhân, Phường Thị mua/bán có stock/limit.
- Dùng các đường P3.7/Economy-A đã có; chỉ sửa nơi kiểm thử chứng minh bug/missing UX. Kiểm tra Economy-A default for new fresh save và người chơi nhìn rõ bật/tắt thay vì vô tình chơi ở opt-out.
- Hiển thị mỗi nhà một câu trả lời: `ai đang làm?`, `đang làm gì?`, `còn bao lâu?`, `sản phẩm đi đâu?`, `thiếu gì?`. Tối đa 1–3 action primary.
- Đảm bảo một đệ tử một active job; tiêu thụ/cấp vật tư và trả lương đúng một lần; nút nâng cấp dùng chi phí thật. Tính sản lượng Mỏ riêng, không áp logic này ngầm sang các nghề khác.
- **Gate:** O3–O9, Economy-A UI/sim, Warehouse FULL/backpressure, save/reload, cả chuỗi UI→real outcome.

### P5 — HỒ SƠ ĐỆ TỬ / TIẾN TRÌNH / PvE CHƠI ĐƯỢC
- UI roster + một hồ sơ đệ tử sâu: Lục Duy, Cảnh Giới, Tu Vi, Luyện Thể, nghề, hiện đang làm, trang bị/skill đã có, injury. Dữ liệu thật từ DiscipleState/V2 read model.
- Chuyên Tu/Rèn Thân giữ cơ chế đã khóa; Injury=0/1 hồi 120 tick từ auto-return: Injury=1 chặn PvE nhưng không chặn Mỏ/Linh Điền/Chuyên Tu/Rèn Thân.
- PvE: chọn đội/vùng, nhìn đúng HP, kết quả, loot vào canonical Warehouse/owner, retreat/return; không tự chốt Economy-B PvE 60/40 hoặc nâng cấp trang bị V2 nếu chưa có packet riêng.
- Chỉ thêm UX/entry cho gameplay đã có trước; đóng bug thật mới mở thêm gameplay sâu. Quy mô nhân vật 1000–3000 là target tối ưu sau, không ép phải render tất cả.
- **Gate:** GP-01/02A/02B1/02C1, DV2 combat, P3.7 FULL và walkthrough người chơi.

### P6 — BẢN ĐỒ / XÂY NHÀ / ĐỒ HỌA THỰC
- Migrate kế hoạch đã duyệt `SECT_BUILDING_LAND_EXPANSION_DESIGN_V1`: một `SectLayoutState` giữ placement/road/unlocked-region trong `SimulationState` khi cấp phép; không double owner.
- World 192×192, vùng đầu 48×48, chunk 16×16, camera Android pan/pinch/focus; tăng diện tích và build multi-instance chỉ sau khi `building_for_profession`/primary fallback sẵn sàng.
- Xây mới bằng Warehouse/Stones thật; di chuyển/đường miễn phí V1 theo quyết định thiết kế; không bịa giá mở đất/nhà chưa khóa.
- Nguồn art ưu tiên Main Hall/Kho/Forge PV-01 và Source A phù hợp; nhân vật sprite-sheet/Godot AnimationPlayer/Skeleton2D, **không bắt buộc Spine runtime**.
- **Gate:** không chồng footprint, đường/cửa hợp lệ, camera + touch; nhà tạo/move đúng BuildingState, reload giữ layout.

### P7 — ANDROID / ĐÓNG GÓI / CHẤT LƯỢNG
- APK landscape 1280×720 logical, responsive safe area, thao tác nút/roster/dropdown/popup bằng tay.
- Test device suspend/resume/force stop/save, render GPU/CPU, 100/500/1000/3000 simulated disciples với actor visible subset; đo FPS/frame hitch/memory, không đoán.
- Test long offline / 1k jobs / duplicate event, fail-closed corrupted save theo SAFE-01/02.
- Chuẩn bị một nút sync/test Windows ổn định với log/screenshots; bảo vệ untracked/source art. Chỉ release candidate sau user physical acceptance.

## E. Thứ tự dependency (không thực hiện đồng thời trên cùng file)

`P0 fresh baseline` → `P1 one-owner mine` → `P2 pick/assign UI` → `P3 visible UI/art` → `P4 full production/economy` → **MỐC P playable core** → `P5 character/PvE` → `P6 map/building` → `P7 Android QA` → **MỐC R**.

**Song song được phép khi không overlap:** Source A asset discovery/small art kit P3 có thể chuẩn bị độc lập lúc P1 đang code, nhưng không cùng lúc sửa `p3_2_landscape_sect.gd` ở PR2/P3/P4. Mỗi hệ dùng một người sở hữu thay đổi/integration branch.

## F. Bắt đầu ngay với một CODE packet thực tế

**Tên đề xuất:** `MINE-V2-ONE-WORKER-01` (P1) — không mở lại phiên tranh luận về mockup.

**Đề xuất allowlist trước review:** `godot/src/simulation/building/building_system.gd`, `godot/src/simulation/workforce/workforce_system.gd`, (nếu cần) `godot/src/simulation/core/p3_7_factory.gd` hoặc factory khởi tạo thực, các tests focused `p3_o3_real_mine_loop_test.gd`, `gp_01_v2_mine_vertical_slice_test.gd`, `economy_a_playable_test.gd`, `p3_o6_m1_release_rehearsal_test.gd` và tests thuộc dependencies khi đúng thay đổi; một record tiến độ. **Allowlist cuối phải được rà exact HEAD trước code**, không mở quyền tự động cho toàn bộ glob.

**Không thay:** SaveService/Scheduler/Warehouse core, Injury, Body/Cultivation, combat, FE-02, Unity/Spine. Save thử được reset từ user:// đúng mục tiêu nếu không tương thích; không viết migration quặng/worker cũ.

**Chưa chốt pilot lượng khai thác:** đây là một biến số nhỏ nhưng quan trọng để không lập trình sai hai lần. Đề xuất giữ `2 quặng/mẻ` như điểm xuất phát, để `Cấp nghề` cải thiện throughput (đã có), và chốt *một* output modifier typed của Mỏ theo Lục Duy phù hợp (nếu muốn số lượng quặng tăng trực tiếp). Quyết định này được ghi rõ trong PR code trước khi commit production; tuyệt đối không tự dùng các con số +78% hay +5/chu kỳ từ ảnh mockup.

**Dấu hiệu DONE:** nhấn Mỏ → chỉ 1 vị trí; chọn một người → thực nhận việc; nâng Mỏ vẫn 1 người; làm xong đúng lượng có nguồn giải thích → Kho + EXP + lương; đổi người khi hợp lệ, người bận bị chặn; 2 Mỏ hoạt động riêng; save/offline không nhân quặng. TEST FAIL thì packet không đóng.

## G. Trạng thái và điều không được tự nhận

- P0–P7 là KẾ HOẠCH, không phải các gói đã được user cấp quyền CODE.
- PR #2 GUI-WORKFORCE vẫn DRAFT; tham khảo logic an toàn, không merge.
- PR #4 UI-REF vẫn DESIGN DRAFT và chứa luật một Mỏ/một người.
- Unity PR #3 tạm dừng; Spine runtime không được gộp vào backlog bắt buộc.
- Mốc P/Mốc R chưa PASS. Khi chưa có PC/CI runner, kiểm tra tĩnh hoặc commit code chỉ được gọi `CODE WRITTEN/QA PENDING`, không phải Godot runtime PASS.
- Không nhân rộng asset/nguồn gốc hoặc lập thêm nhiều tài liệu checklist; **file này là roadmap duy nhất** cho đợt hoàn thiện, sổ QA canonical vẫn duy trì.

## H. Bằng chứng/truy vết tối thiểu

Game: `AGENTS.md`, `GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `QA_DEBT_MASTER_AND_BACKEND_REDESIGN_HANDOFF_2026-10-13.md`, `DV2_PRODUCTION_RESULT_CONTRACT_V1.md`, `P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`, `P3_7_BUILDING_TREE_SPEC.md`, `P3_UX_BUILDING_INTERACTION.md`, `docs/design/UI_REF_01_MAP_MINE_DISCIPLE_UX_V1.md` (PR4), `godot/src/simulation/building/building_system.gd`, `godot/src/simulation/workforce/workforce_system.gd`, `godot/src/simulation/core/simulation_scheduler.gd`, `godot/src/simulation/economy/economy_system.gd`.

Source A: `ZQZS-Source-Knowledge/docs/PROFESSION_PRODUCTION.md`, `docs/HOME_BUILDING.md`, `docs/UI_UX.md`, `analysis/SystemResearch/HOME_BUILDING_DEEP_DIVE.md`, Lua client manager/building selections above. Không có bằng chứng server source.
