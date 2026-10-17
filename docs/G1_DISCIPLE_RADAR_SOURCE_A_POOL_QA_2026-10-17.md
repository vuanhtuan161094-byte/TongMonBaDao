# G1 — RADAR LỤC DUY + SOURCE A VISUAL POOL (17/10/2026)

**Trạng thái:** CODE COMMITTED / STATIC STRUCTURAL PASS / GODOT 4.7.2 RUNTIME PENDING / VISUAL PENDING / ANDROID PENDING.
**Đích:** draft PR #19 `map25-uiux-finalization-20261017` @ `5ce3c0f7ca4bd9eb0295f56b421ef96fca3a2bc7`.
**Nhánh:** `g1-disciple-radar-sourcea-pool-20261017` · Code/test HEAD trước cập nhật docs: `5ac9d5cad86887cefa0ad05c6bdee05f743e79fd`.
**Không CI, không merge, không sửa main hoặc gameplay V2.**

## 1. Đã triển khai

- `godot/src/presentation/p3/disciple_six_dimension_radar.gd`: Godot Control vẽ lưới/đa giác **sáu Lục Duy thật**, số tuyệt đối ở từng trục, thang vẽ động. Chỉ nhận snapshot `DisciplePresentationSnapshotV2.foundations.current`; reject thiếu trục, âm, NaN/Inf; không chỉnh nguồn hoặc giới hạn gameplay. Model legacy 0..1 dùng thang tương thích; V2 là điểm mở.
- `godot/src/presentation/p3/disciple_source_a_visual_pool.gd`: whitelist Scene hợp lệ theo giới tính và seed; tái sử dụng rig nữ `1113028_1`, đúng file `res://assets/actors/1113028_1/actor.tscn` đã tồn tại trong PR19. **Hiện chỉ 1 rig thật có binary trong GitHub.** Nam fallback actor cũ, không giả danh rig nữ. Asset Batch-01 còn lại ở E: ngoài repo, không giả nhận đã nhập.
- `godot/src/presentation/p3_2_landscape_sect.gd`: map actor/showcase đọc pool chung; tab Thuộc tính đặt radar tại x18/y52 và cuộn text thật ở cạnh phải, giữ sáu tab/nút/các lệnh sẵn có; thêm chú thích ý nghĩa thật của sáu thuộc tính, không kích hoạt effect chưa có consumer.
- `godot/tests/presentation/sect_g1_disciple_radar_test.gd`: kiểm tra giá trị thực, trần hiển thị 7000 cho ví dụ Lâm An 6500 điểm, tình trạng input lỗi không mutate, ổn định seed/giới tính, Scene Source A thật, tích hợp deep-profile, không tạo radar ở tab khác, không sửa `DiscipleState`.

## 2. Quy tắc giữ nguyên

- Tu Vi 30×10, Luyện Thể 30×10; Tư Chất +0.25%/pt natural Tu Vi; Căn Cốt +0.20%/pt Body EXP; Thông Tuệ +0.15%/pt approved profession/learning EXP; Tiềm Lực +0.05%/pt RealmBody core HP/ATK/DEF.
- Cơ Duyên và Mị Lực chỉ tham gia meaningful event/social check có owner/consumer thực, không hiện buff giả.
- Một Active Job; Injury 0/1/120; một Warehouse/Scheduler, PR #9 sản lượng ×10,000, bốn ô Linh Điền, mỗi Mỏ/Linh Lâm/Linh Điền một worker.
- Không thay `DiscipleState`, `FoundationSystem`, `CombatStatsV2`, `BuildingSystem`, `WorkforceSystem`, `SaveService`, `EconomySystem`, `SimulationScheduler`, `ProductionPlanRegistry`.
- Không re-run converter, không tạo NPC/ảnh giả từ file chưa có, không thay đổi seed hoặc hệ chọn giới tính.

## 3. Evidence và gate

| Gate | Trạng thái |
|---|---|
| GitHub compare với PR19 | Mã thay đổi giới hạn 4 file presentation/test |
| Structural delimiter/string/comment scan | PASS, chỉ static |
| Godot 4.7.2 parser/import trên exact SHA | PENDING |
| G1 focused scene/test | PENDING |
| V2 authentic deep profile + P3.3 + Source A pilot | PENDING rerun |
| Workforce/production/persistence/O6/SAFE + P3.7 FULL | PENDING cumulative exact HEAD |
| 1280×720 GUI screenshot và radar/roster mobile readability | PENDING |
| MAP25 pan/zoom 600 frames + draw calls sau G1 | PENDING; PR19 trước G1 Windows target PASS |
| Android GPU/touch/save | PENDING |

**QA Windows (trên isolated fresh clone và `user://` riêng, không dùng save người chơi):**

```powershell
$game = "C:\PATH\TO\ISOLATED_CLONE\godot"
$godot = "E:\Godot_v4.7.2-stable_win64_console.exe"
& $godot --headless --path $game --import
& $godot --headless --path $game --script res://tests/presentation/sect_g1_disciple_radar_test.gd
& $godot --headless --path $game --script res://tests/presentation/dv2_03_p3_v2_disciple_profile_test.gd
& $godot --headless --path $game --script res://tests/presentation/sect_source_a_actor_pilot_test.gd
& $godot --headless --path $game --script res://tests/presentation/gui_workforce_v1_e2e_test.gd
```

Các lệnh trên là **runbook chưa chạy**, không phải chứng cứ PASS. Cần tiếp tục các script P3.3, Map25 scene/performance và focused+cumulative P3.7/O3–O9/O6==4/GP-02B1/02C1/SAFE trước nghiệm thu. Chỉ đo thời gian pan/zoom trên cùng thiết bị/cùng scenario rồi so PR19 baseline p95 18.770/19.968 ms (pan/zoom) với tiêu chí p95 <=33.3ms và mean draws <=600.

## 4. Nợ/next

1. Nếu Godot báo parse/runtime, chỉ sửa lỗi thật vào nhánh G1, không hạ test/assertion.
2. Chụp ảnh thật tab Thuộc tính có radar, chuyển tab, roster chọn nam/nữ, các panel sản xuất và toàn map.
3. Từng rig Batch-01 chỉ được thêm vào `VERIFIED_ACTORS` sau khi có Scene binary, giới tính xác minh, stand/walk, SHA manifest và foot anchor.
4. G1 không giải quyết riêng actor/roof, male fallback, marker/công trình thiếu art; đây là visual debt kế tiếp, không giả CLOSED.
5. PR phải giữ draft, chưa merge main. Đợi owner duyệt trải nghiệm khi runtime có bằng chứng.
