# TÔNG MÔN BÁ ĐẠO — ACTIVE BRANCH INDEX / SAFE CLEANUP / MAP PERFORMANCE CHECKPOINT

**Ngày:** 25/10/2026. **Owner đang không mở được máy**. Các thay đổi được thực hiện trực tiếp bằng GitHub connector. **Không tự merge, không xóa source/PR, không khẳng định đã chạy Godot.**

## 1. Khi truy xuất project, chọn đúng version

| Mục tiêu | Branch/PR chính xác | Trạng thái |
| --- | --- | --- |
| **Nền gameplay đã QA tích hợp** | PR #31 `integration/pr28-combat-v3-s1-playable-qa-20261024`, head `9eb4fd55733bb49bbb069240b8e332d37d22aced`, code-tested `4b02a0c61a2771d9d4638129d96b68ad292270dc` | 28/28 scoped Godot PASS và S1 edge 56/56 **trên SHA cũ này**, Draft |
| **Map tông môn B đã QA** | PR #32 `feature/map-d1b-functional-hub-playable-20261025`, head `c6bde70f6e98f482c91cd6d2c386e58437877209` | 29/29 focused báo cáo PASS tại SHA của PR32, Draft |
| **Map tông môn mới để tiếp tục code/tối ưu** | PR #33 `feature/map-d2-direct-chatgpt-visual-upgrade-20261025` | Source A 32 nguyên vẹn; worksite SVG mới candidate; **Godot QA PENDING**, Draft |
| **Map PvE CARE + bản xem thử Thanh Trúc Lâm** | PR #34 `feature/pve-map-presentation-upgrade-20261025`, head tại kiểm tra `dae86efd37a61e2e82c64ea00608fc062c4b423c` | PvE battle 36×20 presentation; scene 20 bãi là **design prototype**, **Godot QA PENDING**, Draft |
| **Official trunk** | `main` | Chưa có code tích hợp PR #31–#34; không dùng làm baseline thử tính năng mới |

**Tránh truy xuất sai:** Tra cứu bằng **đúng branch/ref và đường dẫn đã nêu**; không suy diễn file của PR34 có trong PR33, không đọc `main` rồi kết luận "game chưa có CARE/D7", không coi tài liệu 20 bãi là code spawning 300 quái. Refresh HEAD từ GitHub tại mỗi phiên vì trong lúc làm có thể có commit mới. PR33 và PR34 chưa chung một tree và **không có QA tích hợp đồng thời**.

## 2. Việc đã tối ưu code THỰC trên PR #33

1. **Nguồn art:** candidate SVG Mỏ/Linh Lâm/Linh Điền được probe bằng `ResourceLoader.exists(path,"Texture2D")` trước khi load; nếu thiếu import/asset thì fallback marker cũ, không phát sinh vòng lặp load lỗi từng frame. Original 32 Source A SHA guard vẫn giữ; sửa ghi chú lỗi thời trong `sect_map25_source_art.gd` (không đổi logic kiểm SHA).
2. **Ground/road static overlay caching:** `sect_isometric_world_v1.gd` tạo `terrain_overlays_by_chunk` và `road_overlays_by_chunk` một lần sau khi nạp texture và chốt 9 tuyến đường. Draw chỉ duyệt các hàng cache thuộc active chunks. Trước đó hai vòng lặp 16×16 quét từng chunk **mỗi lần redraw**, chạy `_terrain_texture_key`, `_road_key`, lookup chuỗi/path và phân loại tint lặp lại. **Không xóa drawing/chức năng nào**, dữ liệu cache được xác nhận bằng test mới so đếm chính xác với toàn bộ tile gốc.
3. **Canonical BuildingState index:** `refresh_from_state` tạo bucket một lần theo `building_type`, sort mỗi nhóm theo ID, rồi map vào những destination hiện có. Trước kia quét toàn bộ `state.buildings` lặp cho mỗi loại producer; giờ một lượt. Giữ nguyên instance ID, worksite/selection, sort/authority.
4. **AStarGrid2D startup:** chín visual route trên 192×192 và ba kiểm tra doorway trước kia tái tạo `_navigation()` **12 lần**; nay một lưới dùng chung cho nhóm này, mỗi đoạn đường mới cập nhật `set_point_weight_scale(cell,0.7)` để giữ tương đương đường đã xây trong `SectIsoMapModelV1`. Tiết kiệm 11 lần dựng grid lặp, không thay đường/collision/SectIsoMapModel/SavedState. Ba lần validate riêng khi đặt PV01 ban đầu vẫn chạy nguyên.
5. **Regression mới:** `sect_map_d2_visual_contract_test.gd` kiểm tra scene P3.2 live, Source A view gate, 3 candidate SVG có thể import, đủ 9 preview routes, cache road/terrain chính xác, ID producer/bucket và không mutate `SimulationState`. Legacy D1B route tests giữ nguyên.

**Không có benchmark mới** khi offline. Độ nhanh CPU/RAM chưa đo: chỉ có suy luận từ thuật toán (ít AStar grid dựng lại, ít scan/tạo String khi redraw). Cần official Godot 4.7.2 xác thực và đo. Không được gọi QA PASS vì chưa chạy.

## 3. Cleanup nhỏ, đúng phạm vi trên PR #34

Đã **xóa chính xác hai thành phần không sử dụng** của scene xem thử PvE:
- constant `BRIDGE_ROWS`: không có người đọc; graph thực được tạo qua `design_edges()`.
- biến `drag_start` và assignment: không có người đọc; `drag_sum` mới là state để phân biệt click vs drag.

**Không xóa:** `JX_PRIVATE_BACKDROP` compatibility marker, code Combat/PvE simulation, Source A art, old tests, 19 screenshots PR31/PR32, logs exact SHA, ZIP evidence, hoặc nhánh cũ do chưa chứng minh đủ rằng có thể bỏ. Xóa branch không cải thiện FPS; xóa các log nhỏ cũng không cải thiện render. Chỉ có thể làm nhỏ git checkout/history thực sự bằng kế hoạch archive/squash/cutover sau khi có QA và lựa chọn owner. Không force rewrite lịch sử chỉ để giảm số branch.

## 4. Inventory repo và khả năng dọn tiếp

GitHub recursive tree tại PR31: khoảng **997 entry**, không truncated; metadata repo `size` ~51,589 KB. Một video QA lịch sử `outputs/MASTER_RECOVERY_INTEGRATION_20261023/screenshots/f5715ad/master_recovery_p3_2_1280x720.avi` khoảng **6.9 MB**; rất nhiều log QA nhỏ dưới `outputs` và `docs/handoffs/evidence`. **Đây là artifact kiểm thử theo SHA có giá trị pháp chứng**; không xóa tự động khi người dùng không thể QA bản mới. Nếu sau này dọn dung lượng, nên chuyển bản lịch sử đã hash ra archive/Release đã xác minh, cập nhật manifest/liên kết, rồi đề xuất PR delete riêng; xóa trong HEAD không xóa Git blob ở lịch sử và không bảo đảm download nhanh hơn đáng kể.

Repo đã có `godot/.gitignore` bỏ `.godot/`, `*.tmp`, `*.gd.uid`, reports/; không tạo thêm ignore trùng hoặc ignore hết PNG Source A. Không delete/collapse PR24–34.

## 5. QA phải thực hiện khi có máy/official Godot

- **PR33**: Godot 4.7.2 import/parse SVG; chạy `sect_map_d2_visual_contract_test.gd`, `sect_map_d1b_layout_contract_test.gd`, `sect_iso_main_integration_test.gd`, `sect_map25_verified_art_gate_test.gd`, O9, full 29 focused baseline PR32 và 56 S1 edges trên SHA cuối mới. Chụp màn P3.2 1280×720, kiểm tra click Mỏ/Lâm/Điền, zoom/pan, overdraw, frame time p95/p99 và working set.
- **PR34**: Godot 4.7.2 import/parse scene xem thử; chạy `pve_world_topology_preview_contract_test.gd`, `b3_pve_hunt_landscape_contract_test.gd` và full relevant CARE/S1 focused. Nhớ 256×192/20 camp/300 monster **chỉ mới ở mức layout thiết kế**, không phải combat 300 con thật.
- **Sau đó** mới đưa PR33+PR34 vào một nhánh integration mới, chạy regression trên combined final SHA, nghiệm thu đồ họa và quyết định hợp nhất. Giữ nguyên hai PR làm rollback.
- **Không sửa Github Actions** chỉ để làm mất báo cáo failure: các workflow push từng FAIL với logs 404/BlobNotFound, nguyên nhân UNKNOWN.

## 6. Quy tắc tối ưu tiếp

1. Dùng nguồn `main` để đọc policy/AGENTS, nhưng **đọc runtime code từ exact PR31/32/33/34 như mục 1**; đọc file một lần theo HEAD, không dò tuần tự hàng chục nhánh cũ nếu không có thiếu feature/asset cụ thể.
2. Code có owner `godot/src/simulation/**`, CARE/Combat, Warehouse, Save, D7, scheduler không được dọn hoặc "tối ưu" mà chưa có regression/data proofs.
3. Cảnh quan mới hay SVG candidate không được trộn với 32 PNG Source A hash-gated hoặc mạo nhận art đã được duyệt.
4. Nếu một module trở thành unreferenced, xác nhận qua full-repo static reference graph + Godot import + connected QA trước khi xóa; ưu tiên xóa biến nhỏ rõ ràng trước khi xóa class/asset.
5. Mọi test/benchmark cần SHA **được chạy thật**; không lấy PASS của PR32 để chứng minh PR33.

**Current status:** `SAFE_OPTIMIZATION_CODE_COMMITTED / PREVIEW_UNUSED_STATE_REMOVED / OFFICIAL_GODOT_QA_PENDING / MAIN_UNCHANGED`.
