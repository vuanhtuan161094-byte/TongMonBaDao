# TMB R0/R1 — ĐỐI CHIẾU 20 PR CODE ĐANG MỞ VỚI PR #72 (2026-11-04)

**Nguồn kiểm tra:** live [PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) tại `65221afdf914275459e79bfb45b005ee7fb552f4` trước bản báo cáo này; `fetch_pr_patch`, `compare_commits`, blob source/test trên đúng branch. Bản này không xác nhận Windows GUI hoặc Godot runtime mới; mọi kết luận bên dưới là **static code/function parity**, không phải full gameplay QA. **Một game production duy nhất. Lab #71/#74 độc lập, không đưa code lab vào game nếu chưa có Owner Visual PASS.**

**Phân loại:** `SOURCE_SUPERSEDED` = thay đổi old PR đã hiện diện hoặc có bản mới hơn trong candidate; việc đóng PR không xóa code hoặc chứng minh PLAYABLE. `HOLD_PORT_CHECK` = có file/class/test riêng còn thiếu hoặc có thay đổi chưa thể xác nhận tương đương. `HOLD_DESIGN` = hành vi cũ có thể mâu thuẫn quyết định mới, không tự port. `HOLD_VISUAL` = UI hiện hành khác hợp đồng/nhãn; cần giải quyết theo owner.

| PR | Hạng mục gốc | Đối chiếu thực tế trên PR #72 | Trạng thái và hành động |
|---|---|---|---|
| [#2](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/2) | Picker phân công workforce | P3.2 có `_open_disciple_quick_assignment` và UI mới; **`gui_workforce_v1_picker_test.gd` không tồn tại** trên #72; chưa chứng minh hành vi picker cũ đã phủ đầy đủ | **HOLD_PORT_CHECK**: kiểm tra thao tác picker đa công trình và port regression còn có giá trị |
| [#6](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/6) | Mỏ 1 worker/instance + atomic assignment | Có `BuildingSystem.active_worker_ids()` và `WorkforceSystem.assign_worksite()`; **`mine_v2_one_worker_test.gd` không có**; chưa so toàn bộ path tranh chấp | **HOLD_PORT_CHECK**: nghiệm thu 1 worker/instance, job exclusivity + test |
| [#7](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/7) | Economy V2 core Forest/Field và timer | Candidate có Mỏ/Linh Lâm/Linh Điền, crop registry, `BuildingSystem` và workforce; **`economy_v2_core_foundation_test.gd` không có** | **HOLD_PORT_CHECK**: so sản lượng, thời gian, boost, milestone với quyết định SX mới; không ép balance 16/10 |
| [#8](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/8) | Bulk production, `ProductionPlanRegistry` | **`production_plan_registry.gd` và `economy_v2_bulk_production_test.gd` không tồn tại** trên candidate; `BuildingSystem` không tham chiếu `production_plan` | **HOLD_PORT_CHECK / HIGH**: chức năng bulk + scale source→consumer có thể chưa có. Chỉ port theo hợp đồng SX-03 đã duyệt, tránh lấy số cũ làm chuẩn |
| [#9](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/9) | Economy UI, finite market, production integration | Candidate có Economy-A/policy, production và Warehouse; PR #9 dựa trên `ProductionPlanRegistry` còn thiếu ở #72. Không chứng minh vòng nguồn/tiêu thụ tương đương | **HOLD_PORT_CHECK**: kiểm tra market, auto demand, tiêu thụ theo 1 save; không copy source cũ trọn nhánh |
| [#10](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/10) | Scale-safe Tu Vi/workforce | Candidate có Tu Vi/Workforce; **`disciple_v2_scale_safe_path_test.gd` không có** | **HOLD_PORT_CHECK**: compare path/hành vi, port test hiệu năng-chức năng nếu còn hợp lệ; không mở performance telemetry mới |
| [#12](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/12) | Giới hạn mở 30/30/40 | `resource_building_expansion_policy_v2.gd`, test cap preview không có trên #72; đây là **quy tắc cap lịch sử**, có thể xung đột mong muốn giảm giới hạn | **HOLD_DESIGN**: KHÔNG tự port cap, chờ đối chiếu quy tắc xây công trình mới |
| [#14](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/14) | Earned Potential + One Active Job | `foundation_growth_v2.gd` (1000 Tử Vân Thảo → +1) và test action guard v2 không tồn tại trên #72; FoundationSystem mới có tăng % theo điểm nhưng không có `FoundationGrowthV2` | **HOLD_PORT_CHECK / HIGH**: xác minh điểm Tiềm Lực tăng thật đã chốt hay chưa; không thêm ví/receipt song song |
| [#16](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/16) | Đóng ingress lỗ direct/group/tu luyện | Candidate có các guard trong WorkforceSystem, nhưng **`disciple_v2_active_job_ingress_test.gd` không có** | **HOLD_PORT_CHECK**: compare ingress chính xác và port regression không phá save |
| [#17](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/17) | Potential/HP sync, One Active Job | Candidate có FoundationSystem và worksite guards; **`disciple_v2_foundation_core_regression_test.gd`, `disciple_v2_one_active_job_entrypoints_test.gd` không có** | **HOLD_PORT_CHECK**: xác minh HP/quality mới đúng authority D7 và One Active Job; thêm test theo current model |
| [#18](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/18) | Kết hợp econ/disciple, Map25 env, land preview | Map runtime và Source A hiện có; **`sect_land_region_preview_v2.gd` không có**; nhiều ảnh map và hợp đồng test lịch sử riêng | **HOLD_DESIGN/PORT_CHECK**: không nhập preview land cũ nếu cơ chế đất đã thay; kiểm chứng map/road assets và các contract đi kèm |
| [#19](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/19) | Actor Source A, camera, Map25 UI | Candidate có `sect_isometric_world_v1.gd`, `sect_map_camera.gd`, actor renderer; chưa đối chiếu toàn bộ asset hash và điều khiển UI nguồn cũ | **HOLD_PORT_CHECK**: asset manifest / camera / screenshot QA, không hồi quy về UI cũ |
| [#20](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/20) | Radar, Source A actor pool | `disciple_six_dimension_radar.gd` và `disciple_source_a_visual_pool.gd` tồn tại (blob mới), nhưng D7 canonical là Tam Căn/Tứ Tính còn radar B1 trên #72 đang vẽ **sáu** chỉ số | **HOLD_VISUAL / HIGH**: xử lý nhất quán cơ chế D7 và nhãn hiển thị. Không biến `mind_nature` thành chỉ số chiến đấu mới nếu owner chưa duyệt |
| [#29](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/29) | Combat V3-S1 statuses/cadence | `map_battle_snapshot_v2.gd` đã validate statuses; test `combat_v3_s1_effects_test.gd` có bản mới; #30 bổ sung edge QA | **SOURCE_SUPERSEDED**: duy trì trên #72, không nhập bản code combat cũ |
| [#30](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/30) | Combat S1 official QA fixes | **`combat_v3_s1_edge_contract_test.gd` có blob SHA giống hệt** hai nhánh (`3ca5ede...`); runtime/snapshot đã phát triển tiếp | **SOURCE_SUPERSEDED**: giữ current test, chạy Godot regression lại ở R4 |
| [#46](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/46) | Same-cell move + SaveService diagnostic | `map_battle_v2.gd::_move_world_actor` trên #72 chứa đúng logic di chuyển nội ô; **`pve_same_cell_move_c17_regression_test.gd` cùng blob `27a8fe1...`**. Riêng `pve_aux01_clock_owner_save_diagnostic_test.gd` không có | **SOURCE_SUPERSEDED with QA carry-forward:** bản di chuyển đã có; đăng ký test clock/save missing để R4 đánh giá |
| [#47](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/47) | Formation unique/atomic | `order_group_move` trên #72 vẫn plan toàn bộ điểm trước commit, reserved unique; còn có reachability + gap 3.5 cells; `pve_group_move_unique_formation_test.gd` tồn tại, khác blob do cập nhật | **SOURCE_SUPERSEDED**: không lấy logic cũ đè mới; chạy formation regression R4 |
| [#61](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/61) | SX01 policy roundtrip int/float | `SectState._sx01_normalize_saved_policy()` và `from_dict` giữ normalization/range; **`sx01_json_policy_roundtrip_test.gd` cùng blob SHA `e718a0...`** | **SOURCE_SUPERSEDED**: chức năng đã vào candidate; test ở R4, đóng PR cũ không merge |
| [#64](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/64) | Đại Điện/Đệ Tử Xá/27 bậc | Đã kiểm tra function-name parity: `DaiDienScreenV1` **33/33 cũ**, `SectHallSystemV1` **28/28**, `SectResidenceSystemV1` **19/19** và `SectResidenceSiteV1` **6/6**; candidate còn thêm chức năng chuyển nhà/đường vào cửa; **`dai_dien_housing_full_loop_test.gd` cùng blob** | **SOURCE_SUPERSEDED** ở API/code; QA exact SHA Windows còn PENDING, không merge lại #64 |
| [#66](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/66) | UI B1 ba công trình | Candidate có các panel B1 và nhiều callback mới, nhưng `sect_d7_radar_v1.gd` khác bản gốc: PR #66 vẽ Tam(3)/Tứ(4); #72 vẽ radar 6 và bỏ `mind_nature`; source `FoundationSystem` vẫn có D7 `TAM_CAN_DIMENSIONS` 3 và `TU_TINH_DIMENSIONS` 4 | **HOLD_VISUAL / HIGH**: không kết luận superseded toàn bộ UI; làm rõ authority/hiển thị sau đó mới đóng |

## Các sai khác cần xử lý ưu tiên — không tự động chọn luật cũ

1. **Tam Căn/Tứ Tính:** `FoundationSystem` hiện có `DIM_MIND_NATURE`, `TAM_CAN_DIMENSIONS` 3 và `TU_TINH_DIMENSIONS` 4, nhưng `sect_d7_radar_v1.gd` trên #72 cố tình bỏ Tâm Tính và dùng 6 thông số. P3.2 còn nhiều chuỗi 6 nhãn. Đây là **mâu thuẫn model/presentation thực tế**; cần review owner decision và code thật, sửa UI thống nhất với authority mà không phát minh bonus cho Tâm Tính.
2. **Economy V2 vs SX-03:** `ProductionPlanRegistry`, `ResourceBuildingExpansionPolicyV2`, `FoundationGrowthV2` là code thực trên branch tháng 10 nhưng vắng ở #72. **Không suy diễn 'đã merge tất cả', cũng không port 1.000× bulk/cap 30/30/40 hoặc giá cũ nếu chưa đúng SX-03 được duyệt.** Audit source→consumer/Save/milestones và quyết định giữ/thay/loại riêng.
3. **Missing regression:** các test `mine_v2_one_worker`, `economy_v2_core_foundation`, `economy_v2_bulk_production`, `economy_v2_expansion_cap_preview`, `disciple_v2_active_job_ingress`, `disciple_v2_scale_safe_path`, `disciple_v2_one_active_job_entrypoints`, `gui_workforce_v1_picker` chưa ở #72 theo path; phải xác minh lại equivalence và chỉ port test hợp lệ với kiến trúc hiện tại.
4. **Do not touch the lab branches:** #71 AN-03 and #74 AN-04 independent experiments; không trộn asset/rig vào gameplay khi chưa có Owner Visual + Engine QA. #67 là base của #72, không đóng vội.

## Hành động GitHub release train

Các PR `SOURCE_SUPERSEDED` (#29/#30/#46/#47/#61/#64) **có thể được đóng hành chính** sau khi ghi comment đối chiếu, giữ branch/commits. #46 mang thêm test diagnostic cần xem xét ở R4. Không gọi `merged`. Nhóm `HOLD_*` vẫn mở đến khi đã quyết định thiết kế/có integration + QA.

**Release gates chưa đổi:** R0 còn thiếu backup 196 dirty/untracked E + save; R1 chưa nghiệm thu tính năng; R2 Intel GLES3 Windows crash; R3 same-save loop; R4 QA; R5 single `main` merge. Chỉ thống nhất mã game production, không thống nhất/merge các phòng lab độc lập.

## R0/R1 execution result — 2026-11-04

**Exact tested source/test/evidence commit:** [`b56b6fe8fa29ae663994a65098a56b60c3b42513`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/b56b6fe8fa29ae663994a65098a56b60c3b42513) on PR #72's existing branch. This commit changes presentation and test code only; it does not modify canonical simulation, economy, Combat, SaveService, or player data. The local Godot source snapshot was byte-compared to the live source before the patch; every committed blob was checked against its local Git blob SHA.

### R0 — backup and protection

- Preserved the E: production checkout at `27ed01cd8f377994e5e50bac9ede84e78e8895bd`; its 196 working-tree items (108 modified, 88 untracked) were not overwritten or cleaned.
- Copied 196 working files plus 93 player save files and one QA save (290 files total) to `E:\\TongMonBaDaoWorkspace\\90_Archive\\TMB_R0_BACKUP_20261104_145049`; source/destination SHA-256 matched.
- Backup manifest SHA-256: `EA753053E1DFBFD490E725C7FDD86B26FF565EA4BB10920805AA74571EDEF509`. No player save was read for gameplay or changed.
- Protected Godot PID 2188 was not terminated.

### R1 — implemented and tested

- Restored the read-only D7 presentation to the canonical 3 Tam Căn + 4 Tứ Tính values in recruit, profile and radar views. Tâm Tính remains part of the displayed D7 quality calculation, with no distinct gameplay modifier or save-schema change.
- Corrected presentation tests and isolated O1/O2/O3/O7/O8/O9 fixtures. O3 now removes stale QA sidecars before its fresh-run assertion. O7 now awaits the canonical async save barrier before teardown, preventing the stale reload/thread-not-joined false failure.
- No historical economy rates, production caps, expansion limits, or FoundationGrowth rules were imported: there is no approved current SX-03 numeric/authority contract for those differences.

| Open production/UI PR | Disposition | Function-level result |
|---|---|---|
| #2 | SUPERSEDED | Existing assignment/read-model path remains in the current candidate; current disciple/radar regression is in the focused suite. No historical duplicate authority ported. |
| #6 | DESIGN_HOLD | Historical single-worker Mine cap conflicts with current canonical two-slot Mine. Current O3 exercised two real workers; retain current capacity, do not port stale cap. |
| #7 | SUPERSEDED | Current Mine, Spirit Field, Linh Lâm, production→consumption and multi-producer paths passed O3/O4/O5/O7/O9. Historical rates were not ported. |
| #8 | DESIGN_HOLD | Historical `ProductionPlanRegistry` is absent; its bulk rates need an approved SX-03 contract before implementation. |
| #9 | DESIGN_HOLD | Current economy/market and produce-consume loop passed ECONOMY-A/O5; old registry rates and market values remain unapproved. |
| #10 | DESIGN_HOLD | No current canonical equivalent or exact scale-safe regression was established in this packet; retain for R4 design/code review. |
| #12 | DESIGN_HOLD | Historical 30/30/40 expansion caps are not approved for current balance; no cap was imported. |
| #14 | DESIGN_HOLD | Historical `FoundationGrowthV2` is absent and its growth formula is not approved; no implied stat bonus was added. |
| #16 | SUPERSEDED | Current One Active Job / occupation guard passed GP-02B1. Do not reapply stale entrypoint code; missing old test-path equivalence remains a later QA concern. |
| #17 | SUPERSEDED | Current Foundation/Dẫn Tiên and occupation paths passed P3.7C1/GP-02B1; D7 presentation is handled by the source/test change in this commit, without a new gameplay bonus. |
| #18 | DESIGN_HOLD | Historical land-region preview was not shown equivalent to the current map; no approved current requirement or visual QA was available. |
| #19 | DESIGN_HOLD | Current map renderer/input source was left untouched; camera/render acceptance requires R2/R4 GUI evidence. |
| #20 | PORT | Ported the approved Tam Căn/Tứ Tính 3+4 read-only radar presentation and added exact 7-value/profile/contract assertions. |
| #66 | PORT | Ported the B1 D7 3+4 presentation only; existing facility callback/gameplay authority was preserved. |

### Exact-SHA Godot evidence

Official Windows Godot `4.7.2.stable.official.ed1daf0bf`, isolated QA profile; sequential run: import plus 19 focused tests, **20/20 exit 0**. See [matrix](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/b56b6fe8fa29ae663994a65098a56b60c3b42513/godot/outputs/qa_evidence/PR72_R0_R1_20261104/QA_MATRIX.csv), [combined log](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/b56b6fe8fa29ae663994a65098a56b60c3b42513/godot/outputs/qa_evidence/PR72_R0_R1_20261104/godot_focused_tests.log), [evidence README](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/b56b6fe8fa29ae663994a65098a56b60c3b42513/godot/outputs/qa_evidence/PR72_R0_R1_20261104/README.md), and [SHA-256 list](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/b56b6fe8fa29ae663994a65098a56b60c3b42513/godot/outputs/qa_evidence/PR72_R0_R1_20261104/SHA256SUMS.txt). The only import/test stderr note was a nonfatal Windows root-certificate-store warning. The final O7 run had no unjoined-thread warning.

**Not accepted in this packet:** real Windows GUI/mouse, Source A visual screenshots, R2 Intel GLES3 launcher stability, Android/touch, one continuous player-save R3/R4 loop, and R5 merge. No GUI or PLAYABLE PASS is claimed. Stop here before R2 pending owner acceptance.
