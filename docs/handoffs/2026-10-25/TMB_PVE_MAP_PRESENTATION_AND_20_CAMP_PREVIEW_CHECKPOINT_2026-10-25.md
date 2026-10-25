# TÔNG MÔN BÁ ĐẠO — PvE MAP CODE CHECKPOINT 2026-10-25

**Trạng thái:** CODE COMMITTED / NOT GODOT-VERIFIED / NOT MERGED. Không phải bản PvE 300 quái đã vận hành.

**Nguồn kế thừa:** PR #31 HEAD `9eb4fd55733bb49bbb069240b8e332d37d22aced` (28/28 focused QA ở nhánh gốc). PR #33 MAP-D2 tông môn nằm trên PR #32 và tách nhánh; không gộp thay đổi PvE vào nhánh #33 để tránh trộn lỗi.  

**Nhánh:** `feature/pve-map-presentation-upgrade-20261025`.

## Thực hiện thực tế

### 1. Trận PvE CARE đang chạy (36×20 battle coordinates)

- Tạo `godot/src/presentation/p3/b3_care_hunt_landscape_v2.gd` (presentation-only): sáu mảng rừng và những điểm hoa/cỏ/đất trống nhẹ, di chuyển theo phép chiếu camera của Combat V5. Không tạo vật cản/đường điều hướng mới, không thay tốc độ/tầm đánh hay tỷ lệ rơi đồ.
- Sửa `godot/src/presentation/p3/b3_care_combat_v5_presenter.gd` để gọi landscape supplement khi `draw_pilot_ground=true` và `jxqy2.active=false`, đồng thời bổ sung 4 cây Source A ở mép cảnh tránh che vùng chiến đấu. Cây đều dùng ba PNG đã có trong repo, không import JX mới. Trạng thái AoE và actor vẫn được vẽ sau nền.
- Test mới `godot/tests/presentation/b3_pve_hunt_landscape_contract_test.gd`: MapBattleV2 fixture thật, kiểm tra floor projection = actor projection sau pan + zoom và MapBattleSnapshotV2 không bị mutation bởi renderer.

### 2. Màn xem thử quy hoạch Thanh Trúc Lâm (độc lập game live)

- Tạo `godot/src/presentation/p3/pve_world_topology_preview_v1.gd` và `godot/scenes/p3/pve_world_topology_preview_v1.tscn`: màn riêng tỷ lệ thiết kế `256×192`, 20 bãi C01–C20 ở 5 cột × 4 hàng, dự kiến tổng 300 quái normal, suối trục x=148, ba cầu và tổng 30 cạnh giao thông. Có chuột kéo, zoom tại trỏ, chạm chọn bãi và sidebar giải thích; Source A vegetation ở phần trang trí.
- Không có và không giả lập gameplay 300 quái: **không** sinh monster instances, bãi tự đánh, Boss event, AI/loot/minimap authoritative. Các con số là **DESIGN ONLY** theo đúng nhánh `docs/ttl-20-camps-map-topology-five-difficulties-design-20261024`.
- Không sửa `MapBattleV2` (giới hạn battle 36×20/40 monster), `B3HuntWorld`, `HuntingMapV2`, Kho, Save, camera tông môn hoặc user save.
- Test mới `godot/tests/presentation/pve_world_topology_preview_contract_test.gd` kiểm tra 20 camp, tổng population proposal 300, 30 edges, graph connected, ba cầu C03-C04, C13-C14, C18-C19, cạnh C08-C09 bị chặn, phép chiếu và camera select/pan/zoom.

## Vì sao chưa thể tuyên bố "map PvE 20 bãi đã xong"

Contract PVE world thiết kế khác hẳn Combat V2 encounter: cần **world actor registry**, 200–400 monster slots, 30 disciples, canonical multi-wave kill journal/receipt, spawn generation/respawn, assignment/FARM_AREA commands, AI pathfinding, RTS drag/select/minimap camera, save versioning/rollback. Việc đó chạm gameplay simulation/CARE/Save authority và cần nhiều integration/regression. Nhánh này không tự lén thay Combat V2 để vừa đạt con số 300 vừa giữ test giả.

## Chưa kiểm chứng / phải chạy khi có Godot

- Godot executable official 4.7.2 không có ở môi trường ChatGPT container. **Chưa parse/import/run GUI/test** của nhánh này. Không dùng kết quả PASS PR31 làm bằng chứng PASS cho mã mới.
- Yêu cầu chạy **focus**: `res://tests/presentation/b3_pve_hunt_landscape_contract_test.gd` + `res://tests/presentation/pve_world_topology_preview_contract_test.gd` + `b3_care_combat_v5_presenter_test.gd`, `pr28_s1_combat_status_presenter_test.gd`, camera/picking/B3 hunt/save/loot + toàn bộ 28 focused PR31 và 56 S1 edge checks trên exact new code tree.
- Cần actual screenshot `p3_2_landscape_sect.tscn` khi CARE săn quái và preview scene `pve_world_topology_preview_v1.tscn` ở 1280×720; Android/touch, sustained FPS/RAM đều PENDING.
- Nếu preview scene load lỗi hoặc projection state khác: sửa dưới PvE map presentation/tests only và chạy lại. Không giảm assertions hoặc giả PASS.
- Preview mở thủ công trong Godot: chọn `res://scenes/p3/pve_world_topology_preview_v1.tscn`. **Đây không phải entry point của main game**.

## Chia nhánh và kế hoạch merge

- PR31 nền gameplay unchanged.
- PR33 tông môn MAP-D2 độc lập, NOT VERIFIED.
- PvE nhánh này độc lập dựa trên PR31; có thể kiểm thử riêng. Sau khi cả hai qua official Godot QA và owner visual, dùng nhánh integration mới để kết hợp vào P3.2. Không merge hai nhánh đã QA khác SHA bằng suy đoán.

**Verdict:** `PVE_MAP_PRESENTATION_IMPLEMENTED_UNVERIFIED`, `PVE_20_CAMP_TOPOLOGY_PREVIEW_IMPLEMENTED_UNVERIFIED`, `PVE_WORLD_300_MOBS_NOT_IMPLEMENTED`. 
