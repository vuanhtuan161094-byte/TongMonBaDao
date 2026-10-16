# TÔNG MÔN BÁ ĐẠO — Xây dựng, di chuyển công trình và mở đất (DESIGN PROPOSAL V1)

**Ngày:** 2026-10-13. **Trạng thái:** DESIGN APPROVED — DESIGN ONLY; CODE NOT AUTHORIZED. Quyết định chủ dự án ngày 2026-10-13; ADR-0003 giữ nguyên.  
**Nền:** `main` sau SAFE-01/SAFE-02 CLOSED; ENV-02A 192×192, Windows/Android PENDING USER.  
**Sản phẩm:** Android, LANDSCAPE, thiết kế 1280×720; Godot 4.7.2.  
**Không mở:** FE-02, ENV-02B–E, DV2-03 (PAUSED NOT CLOSED), artwork S3, pipeline Spine.

## 1. Căn cứ thực tế và bài học nguồn tham khảo

- **Source Ta Là Tông Sư — VERIFIED client:** `ZQZS-Source-Knowledge/docs/HOME_BUILDING.md` và `analysis/SystemResearch/HOME_BUILDING_DEEP_DIVE.md`. Source có `buid_size`, `doorway`, `x/y/orientation`, kiểm tra vị trí, lệnh xây/di chuyển, bản thiết kế local, vẽ đường, mở area và điều động AI theo công trình. Không có thân thuật toán `_MapManager.IsCanPlace/FindPath`, không có bằng chứng đầy đủ về giao dịch vật tư phía server. Học luồng thao tác và phân quyền dữ liệu; **không bê networking, thuật toán chưa xác minh hoặc balance**.
- **Game hiện tại:** `BuildingState` lưu ID/loại/cấp/nhân sự/sản xuất, **không có tọa độ**. `BuildingSystem` hiện quản lý các instance thật, tăng cấp và sản xuất; một số consumer vẫn chọn `primary_building`. `WarehouseSystem` là kho nguyên liệu duy nhất. Ba sprite Source A của ENV-02A chỉ là preview lab, **không tự động tương đương ba BuildingState production**.
- **Authority ADR-0003:** fixed-layout V1; geometry trong `SectLayoutDefinition`/map model là presentation. Nếu tương lai cho phép người chơi sửa bố cục thì phải **duyệt cơ chế persistent layout/migration và chuyển quyền sở hữu vị trí một cách độc quyền**. Tài liệu này chỉ đề xuất quyết định tiếp theo; không tự ý sửa ADR.
- **Gameplay master:** `docs/P3_7_BUILDING_TREE_SPEC.md`: công trình Lv1–100 theo instance, một số trung tâm độc nhất, nhiều instance được mở theo tiến trình. **Không đồng nhất xây mới với nâng cấp**, không tự bịa nguyên liệu/giá hay mở sẵn 463 công trình từ Source.

## 2. Trải nghiệm người chơi: 3 thao tác, 1 menu

Tại bản đồ tông môn, màn hình bình thường vẫn map-first, HUD sát mép, không mở sidebar khi chưa chọn.

1. Chạm **Xây Dựng** → menu gọn có **Công trình / Đường / Mở đất**.
2. Chọn công trình → preview chân nhà/footprint (xanh = hợp lệ, đỏ = bị chặn) → chạm ô đặt → **Xác nhận** hoặc **Hủy**. Chỉ hiện nút xoay nếu art/footprint hỗ trợ hướng đó.
3. Chạm công trình có thật → **Quản lý** hoặc **Di chuyển**; dời nhà bằng preview ở vị trí mới → xác nhận. Giữ nguyên `building_instance_id`, cấp, nhân lực, việc đang làm và sản phẩm; không tự reset timer.

Android: một ngón vuốt map khi không ở chế độ đặt; khi chọn preview, chạm vùng đích để đặt, không hiểu nhầm pan là xây. Hai ngón pinch vẫn zoom; HUD/panel nằm ngoài camera. Có vùng bấm tối thiểu đủ chạm và hiển thị lý do không đặt được. PC sử dụng chuột chỉ để phát triển/test cùng luật.

## 3. Quy mô bản đồ / đất

- World logic **192×192** (36.864 ô), chỉ là kiến trúc thử nghiệm có khả năng mở rộng; bản đồ render bằng chunk **16×16** (144 chunk). Chunk là **đơn vị culling**, **không phải** đơn vị sở hữu đất hoặc mở khóa kinh tế.
- Khu mở đầu **Rect2i(72,72,48,48)** như ENV-02A; kích thước 2.304 ô, không giả vờ cả map đã được mở. Trong khu này có đất trống, sân/đường và các công trình đã xác minh.
- **Đất mở:** danh sách `region_id` cùng polygon/hình chữ nhật authored, có thể độc lập với ranh giới chunk. Ví dụ vùng thử nghiệm lân cận khu mở đầu: Bắc `(72,40,48,32)`, Đông `(120,72,32,48)`, Nam `(72,120,48,32)`, Tây `(40,72,32,48)`; **chỉ là khu gợi ý để duyệt, không có giá hay quyền mở khóa đã xác lập**. Các góc và vành ngoài dành cho về sau.
- Người chơi có thể ngắm xa vùng khóa qua camera nhưng chưa được xây trên đất chưa mở; địa hình khóa có lớp chỉ báo nhẹ. Khi mở vùng, ghi ID vùng, không phải ghi hàng nghìn boolean ô.
- Kiểm tra mở vùng: region tồn tại, chưa mở, tiếp giáp ít nhất một vùng đã mở, không làm mất đường hợp lệ. **Giá mở đất, mốc tiến trình và thời gian chưa có authority** → trạng thái **TBD**, tuyệt đối không kích hoạt gameplay tính tiền giả.

## 4. Quyền sở hữu dữ liệu: chỉ MỘT sự thật

**Đề xuất nếu ADR-0003 được sửa bằng phê duyệt riêng:** một `SectLayoutState` nhỏ được sở hữu bởi `SimulationState`, chỉ có:
- `layout_schema_version`, `map_content_id`, `layout_revision`;
- `placements`: map `building_instance_id -> {x:int,y:int,orientation:int}` đối với **building gameplay thật**;
- `unlocked_region_ids`: tập ID đã mở (serialize sắp xếp);
- `roads`: tập tọa độ ô đường đã xác nhận (serialize sắp xếp).

**Không lưu trùng:** cấp, tài nguyên, worker, queue vẫn ở `BuildingState`/`WarehouseSystem`; địa hình, loại/tên/footprint/doorway/art và các landmark không quản lý vẫn là content definition. `TransferMapModel` được dựng như **projection/cache kiểm tra geometry** từ content + persistent layout, không được tự ghi save hay giữ authority thứ hai. Nút ở UI chỉ gửi lệnh tới một owner giao dịch, chờ kết quả rồi redraw.

Với **save cũ**, layout mặc định chưa kích hoạt. Sau khi người dùng phê duyệt migration, hệ thống seed **một lần** các công trình có `BuildingState` thật theo layout được thẩm định; kiểm tra đủ ô, không chồng lấn, doorway hợp lệ; lỗi → fail closed và giữ save SAFE-01. Khi đã bật editable layout, không đồng thời đọc vị trí từ fixed-layout làm nguồn song song. Asset `main_hall/warehouse/forge` trong lab phải được phân loại `managed_building` (có đúng ID canonical) hoặc `landmark` (visual-only); **không gán level/production giả cho landmark**.

## 5. Luật đặt nhà, dời nhà, đường và giao dịch

**Placement preview chỉ đọc**. Validator dùng geometry hiện có: tọa độ trong map, region mở, footprint không chồng nhà/ô cấm/cổng quan trọng, cửa ở ngoài footprint và không bị chiếm, đường từ điểm nối chính tới tất cả doorway quan trọng vẫn thông (AStar). Khi dời, tạm loại footprint chính nó bằng `ignore_id`. Recheck toàn bộ trên canonical state ngay trước commit; số `layout_revision` đổi thì preview cũ hết hiệu lực.

**Dời nhà V1:** thay đổi vị trí/hướng, giữ nguyên `building_instance_id`, `BuildingState` và nhiệm vụ đang chạy. Khuyến nghị **miễn phí** trong giai đoạn đầu để giảm scope; đây là đề xuất cần duyệt, chưa phải luật gameplay chốt.

**Đường V1:** vẽ/xóa theo danh sách ô qua preview, không xuyên footprint/cổng/đất khóa; làm đổi chi phí hình ảnh cho AStar, **không tự tạo bonus tài nguyên hoặc thưởng công việc**. Phí làm đường chưa được phê duyệt; đề xuất ban đầu coi là chỉnh bố cục miễn phí, cho chốt riêng.

**Xây mới:** chỉ khi `BuildingSystem` hỗ trợ loại/instance đó và bảng chi phí **đã được phê duyệt**. Giao dịch duy nhất: kiểm tra phép xây và giới hạn instance/đất → kiểm tra Warehouse reserve/lock và Linh Thạch → trừ đúng một lần → tạo `BuildingState` ID duy nhất và thêm vị trí trong layout → lưu trong cùng `SimulationState`. Nếu thất bại, rollback toàn bộ. Preview không tiêu hao. Không dùng `start_upgrade` để giả lập xây công trình mới. Các consumer hiện dùng `primary_building` phải được đánh giá trước khi bật nhiều instance; không tự mở vô hạn instance. Lệnh lặp do chạm kép/tải lại phải không bị trừ tài nguyên lần hai (request receipt có giới hạn hoặc nguyên tắc idempotency đã kiểm thử).

**Mở đất:** chỉ thay đổi danh sách vùng sau khi mọi điều kiện và chi phí authored được kiểm tra tại gameplay authority. Không phát thưởng/EXP/cấp building chỉ vì mở vùng. Không có bảng giá được duyệt → nút chỉ là UI/preview thiết kế, chưa được phép giao dịch thật.

## 6. Thứ tự triển khai sau khi chủ dự án duyệt code (CHƯA MỞ)

| Packet đề xuất | Nội dung tối thiểu | Gate |
|---|---|---|
| **LAY-01** | Duyệt thay đổi ADR và schema `SectLayoutState`; seed/migrate an toàn các BuildingState thật, đối chiếu 3 visual lab; chưa cho xây | Save cũ/nguyên trạng; 1 authority; không chồng footprint; Godot CI |
| **LAY-02** | Tap/chọn/dời công trình hiện có, preview xanh/đỏ, pan/pinch, lưu tọa độ | Dời–lưu–tải; không mất sản xuất/nhân lực; cửa/AStar vẫn thông |
| **LAY-03** | Xây instance mới theo bảng giá/giới hạn đã duyệt, road editing đơn giản | Kho trừ đúng một lần, request replay, undo preview; sản xuất nhiều instance test riêng |
| **LAY-04** | Author vùng mở đất, unlock transaction, chỉ báo vùng khóa; Android acceptance | Không mở trùng, save/load, hiệu năng khu lớn, thao tác cảm ứng |
 
Mỗi packet được **duyệt riêng**, không code khi ENV-02A Windows chưa có kết quả, không coi ảnh đẹp là đủ nghiệm thu gameplay. **FE-02 production asset integration là quyết định riêng**, không bị LAY-01 tự mở. DV2-03 PAUSED NOT CLOSED.

## 7. Quyết định chủ dự án — ĐÃ DUYỆT THIẾT KẾ, CHƯA DUYỆT CODE

1. **ĐÃ DUYỆT nguyên tắc:** chỉ một `SectLayoutState` giữ vị trí/đường/vùng mở **bên trong** `SimulationState`, tái sử dụng `TransferMapModel` như geometry projection; `BuildingState`, `BuildingSystem`, `WarehouseSystem` giữ authority gameplay riêng, không tạo bản đồ/save hoặc kho thứ hai.
2. **ĐÃ DUYỆT quy mô thử nghiệm:** world 192×192, vùng đầu 48×48, chunk render 16×16; Android landscape thiết kế 1280×720. Đây **không phải** cam kết tối ưu Android hay kích thước thế giới vĩnh viễn.
3. **ĐÃ DUYỆT V1:** dời nhà và lát đường miễn phí; giữ nguyên building ID, cấp, nhân sự, job và sản xuất; đường chỉ tác động tuyến visual/path, không tự sinh tài nguyên.
4. **CHƯA DUYỆT:** công thức/giá xây mới và mở đất, giới hạn instance chi tiết, cơ chế tăng giới hạn đất; không invent số liệu.
5. **CHƯA CẤP QUYỀN:** sửa ADR-0003, schema/save production, code LAY-01–04, FE-02, ENV-02B–E, xây tự do hay mở đất. ADR-0003 **fixed-layout V1 vẫn có hiệu lực** cho production hiện tại, cho đến quyết định sửa đổi riêng.
6. **ENV-02A** vẫn Godot Windows/Android **PENDING USER**. Không dùng việc duyệt design làm bằng chứng runtime. DV2-03 **PAUSED NOT CLOSED**, SAFE-01/02 CLOSED, S3 tám artwork không đổi.

### Các cổng trước khi chủ dự án có thể cấp phép code

**GATE A — ENV-02A technical acceptance (trước LAY-01):**
- Godot **4.7.2 Windows** import/parse sạch; scene 192×192 / chunk 16×16, camera pan/zoom/culling, ba art Source A và selection/door/AStar chạy đúng; hồi quy `TransferMapModel` 20×13 PASS.
- Có **log thực** `ENV02A_TEST_RESULTS`, ảnh Godot thực tế (khu trung tâm + vùng xa) và chủ dự án xác nhận. Không báo Windows/Android PASS bằng kiểm tra tĩnh/GitHub.
- Android APK, pinch/tap, FPS và save-kill là gate riêng khi làm mobile; kết quả vẫn **PENDING USER** nếu chưa chạy thiết bị.

**GATE B — Quyết định kiến trúc trước khi viết vào save production:**
- Chủ dự án **duyệt riêng** sửa đổi/bổ sung ADR-0003 để chuyển từ fixed-layout sang editable-layout độc quyền: `SectLayoutState` là vị trí persistent **duy nhất**, content fixed seed chỉ dùng một lần khi migrate.
- Chốt manifest visual ↔ `building_instance_id`: công trình gameplay thật khác landmark/trang trí, không giả sản lượng/cấp.
- Chốt quy trình save cũ → layout seed kiểm tra ô/cửa/đường → save lại an toàn, migration idempotent, fail-closed; kiểm thử hồi quy SAFE-01/02 và rollback dữ liệu khi lỗi.

**GATE C — Tiêu chí nghiệm thu mỗi packet chỉ khi được duyệt riêng:**
- `LAY-01`: save/load layout exact, stable IDs, no duplicate authority, không chồng lấn/đứt doorway; hồi quy backend Godot 4.7.2 official CI PASS; không mở cơ chế xây mới.
- `LAY-02`: dời nhà không đổi sản lượng/job/cấp/worker; vị trí persist qua reload; camera chạm/vuốt/phóng to không thành lệnh đặt nhầm; AStar và đường còn hợp lệ.
- `LAY-03`: **chỉ sau khi** duyệt chi phí và luật instance; xây/đường fail-closed, preflight kho reserve/lock, trừ **đúng một lần**, không double tap/replay, rollback khi thiếu tài nguyên, test consumer `primary_building` với nhiều instance.
- `LAY-04`: **chỉ sau khi** duyệt điều kiện và chi phí mở đất; vùng liền kề, không mở trùng, save/load, Android cảm ứng/culling và giới hạn 1.000–3.000 đệ tử được đánh giá bằng benchmark riêng.

**Điều kiện triển khai bất biến:** không mở bất kỳ LAY packet hoặc FE-02 nào chỉ từ việc chốt V1 này. Chủ dự án phải cấp **lệnh CODE rõ tên packet**, sau khi các gate thích hợp đã được chứng minh.

## 8. Bằng chứng / đường dẫn

- [Source Home/Building](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/docs/HOME_BUILDING.md)
- [Source deep dive](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/analysis/SystemResearch/HOME_BUILDING_DEEP_DIVE.md)
- [ADR-0003 Godot Native](../decisions/0003-fe00-godot-native-data-driven-frontend.md)
- [Canonical building tree](../P3_7_BUILDING_TREE_SPEC.md)
- [Main map UX](../P3_UX_MAIN_MAP.md)
- [Lab ENV-02A](../../labs/env02a/scripts/env02_world.gd)
- [BuildingState](../../godot/src/simulation/state/building_state.gd)


---

## 9. 2026-10-16 — LAY-01 / Economy V2 executable design preparation (REVIEW PROPOSAL ONLY)

**Status: DESIGN REVIEW / OWNER APPROVAL REQUIRED, NO RUNTIME AUTHORIZATION.**
This addendum responds to the owner's request to finish the 30/30/40 resource-building expansion design while leaving ADR-0003 fixed-layout in force. It supplements rather than silently amends the 2026-10-13 accepted DESIGN ONLY policy in Sections 1–8.

### 9.1 Live-source evidence and blockers

Audited stacked PR #12 branch `economy-v2-resource-expansion-gates-20261016`:
- `ResourceBuildingExpansionPolicyV2` is read-only and **always** returns `ok=false`, because the proposed Hall level argument is hypothetical; it can preview 1/1/1 → 30/30/40 but does **not** unlock construction.
- `BuildingSystem.create_building(type,index)` only manufactures a `BuildingState` object with a deterministic ID; it has **no land/cost/receipt/placement transaction**. Never expose it as a free player "Build" command.
- The current `BuildingSystem.DEFINITIONS` has no `main_hall` building type. ENV-02A visually previews a main hall, warehouse and forge, but these are not verified one-to-one canonical production instances. Hall level, Hall unlocks and construction prices have **no current gameplay authority**.
- `SimulationState` owns `buildings` and `to_dict/from_dict`, but no `SectLayoutState`. `SaveService.CURRENT_VERSION=2` has staged `.tmp`, verified data, `.bak` rotation/recovery; future layout save migration must reuse this path, not write another independent map save.
- `docs/handoffs/ENV02A_CODE_AND_BACKEND_AUDIT_2026-10-13.md` records a text-only ENV-02A GitHub mirror. The GitHub tree has static reports and `RUN_ENV02A_WINDOWS.cmd`, **but not a verified official Windows ENV-02A runtime acceptance package** with two actual screenshots, pan/zoom/path/culling evidence and matching 35 asset PNGs. ENV-01 Windows import/structure evidence is distinct; Android is unverified.
- The existing `docs/decisions/0003-fe00-godot-native-data-driven-frontend.md` explicitly keeps fixed placement in `SectLayoutDefinition` and forbids persistent placement until a separately approved authority change. **Do not treat this design as that approval.**

### 9.2 Proposed architecture: one canonical owner for each fact

| Fact | Proposed sole authority after separate LAY-01 approval | Never put it in |
|---|---|---|
| Building ID/type/level/operator/production/current status | existing `SimulationState.buildings[id] : BuildingState` | layout projection, visual registry |
| Real player-editable location, road cells, unlocked land | one `SimulationState.sect_layout : SectLayoutState` | `BuildingState`, separate save, camera or TransferMapModel |
| Realm/profession and One Active Job | existing Disciple/Workforce/Building authority | building sprite or Hall preview |
| Sect Stone and all stackable materials | existing `SectState.spirit_stones` and Warehouse | construction layout, local UI inventory |
| Hall Lv1–100 | **proposed singleton `BuildingState(main_hall_001)`** via explicit `BuildingSystem.TYPE_MAIN_HALL` | separate mutable `SectState.hall_level` |
| Hall-derived 30/30/40 cap | current `ResourceBuildingExpansionPolicyV2`, supplied **actual Hall BuildingState.level** | UI config or invented player Hall value |
| Map shape, footprint, door, restricted terrain and projection | versioned authored Map/BuildingVisual content + geometry validator | duplicate persisted room/cell ownership |
| Real building/land jobs + idempotent receipts | existing SimulationScheduler ticks; one construction owner writing `BuildingState` / layout / existing receipt ledger | second clock/OccupationManager/warehouse |

**Proposed data contract; DO NOT CREATE GDScript/serialization until approved:**

```text
SimulationState
  sect_layout: SectLayoutState?      # absent on V1 fixed-layout save
SectLayoutState
  schema_version: 1
  map_content_id: "sect_world_192_v1"
  layout_revision: int >= 0
  placements: {
    canonical_building_instance_id: { x:int, y:int, orientation:int }
  }
  unlocked_region_ids: [sorted unique authored region_id]
  roads: [sorted unique (x,y) canonical cells]
  pending_land_projects: {
    region_id: {request_id, started_tick, finish_tick, cost_snapshot}
  }                                     # proposed optional LAY-04 extension
```

`placements` stores only verified real `BuildingState` IDs and coordinates; no production state, no asset PNG references, no phantom Hall/warehouse/forge stats. Pending building construction uses one new `BuildingState.status="constructing"` with a non-productive start/finish snapshot, with footprint held in the matching layout placement. One canonical Scheduler tick drives completion; no extra job clock. Proposed `construction_receipt:<request_id>` and `land_receipt:<request_id>` live in the existing persistent Sect receipt authority with namespaced, payload-checked identities (or a separately approved equivalent single ledger), never in a parallel unsaved UI list.

**Projection:** the existing ENV-02A `MapModel`/`TransferMapModel` may be used as a read-only geometry validator and rebuildable cache from the authored terrain/visual manifest plus `SectLayoutState`. Its occupant cells/route results are not an independently saved truth. Fixed `SectLayoutDefinition` is used *only to seed verified legacy placement once*. After `sect_layout` exists, the editable layout is exclusive; fixed content cannot overwrite saved player moves.

**Status gates:** before changing `SimulationState`, `SaveService` or `BuildingSystem`, record an explicit ADR-0003 amendment authorizing ownership transfer and exact LAY packet. This annex alone conveys no code permission.

### 9.3 Migration from older saves — fail closed without destroying progress

Proposed future flow:

1. Load **without offline tick** through existing SaveService staged/bak recovery; preserve exact legacy save bytes until staged new version is verified.
2. If `sect_layout` already exists, validate schema, map ID, coordinate bounds, unlocked regions, unique building-ID references, rotated footprints, doors/routes and no overlap. Do **not** seed again. Invalid layout → reject or recover valid `.bak`; never silently drop a building/worker/job/material.
3. If absent: enumerate **all actual** `state.buildings` IDs in stable order, including Mine/Forest/Field/Alchemy/Guidance/Body facilities that may exist in old saves. Build a reviewed content-to-instance placement manifest. Distinguish the three ENV-02A visual previews from real building instances: a visually shown main hall, warehouse or forge is not automatically an instance.
4. Verify every authoritative building has exactly one legal authored seed placement (unless explicitly approved as a non-spatial service building); no duplicate IDs, no unbound mandatory managed IDs, no occupied collisions, all doors/routes usable, inside starter-unlocked land. If no correct mapping exists, **abort migration with a reason**, preserve save; do not assign random free cells.
5. Seed layout exactly once with `schema_version=1`, `map_content_id`, `starter` opened, valid placements/roads and monotonic `layout_revision`. Do not seed extra Linh Thạch, raw resources, workers, production batches or a new Hall automatically from a visual token.
6. Validate canonical state, layout and full deterministic round-trip (`to_dict` → save → load → `to_dict`) **before** publishing new file. Use existing `.tmp` + `.bak` and restore on fault. Offline catch-up resumes only after migration/ownership checks pass.
7. Replay same load or same construction/land request: identical result, no new building, no second debit, no changed job finish tick; divergent payload with same request ID fails with `conflicting_request_replay`.
8. Only after real 1280×720 scene/mapping QA, authorize switching presentation projection from fixed-layout-only to persistent placement.

**Critical limitation:** existing ENV-02A only shows three visual objects; it is insufficient to seed every real gameplay `BuildingState`. LAY-01 cannot truthfully PASS until an all-instance placement manifest is reviewed and verified.

### 9.4 Authored land geometry proposal, 192×192 without overlap

Map coordinate system: zero-based `x,y` in `[0,191]`. The starting unlocked rectangle is `starter: Rect2i(72,72,48,48)` (2,304 cells). Proposed non-overlapping regions:

| Region ID | Rect2i(x,y,w,h) | Phase candidate |
|---|---|---|
| starter | (72,72,48,48) | starting, no charge |
| north_01 | (72,40,48,32) | Hall Lv10 |
| east_01 | (120,72,32,48) | Hall Lv20 |
| south_01 | (72,120,48,32) | Hall Lv40 |
| west_01 | (40,72,32,48) | Hall Lv60 |
| north_02 | (72,0,48,40) | Hall Lv60 |
| south_02 | (72,152,48,40) | Hall Lv60 |
| east_02 | (152,72,40,48) | Hall Lv80 |
| west_02 | (0,72,40,48) | Hall Lv80 |
| northeast | (120,0,72,72) | Hall Lv80 |
| southeast | (120,120,72,72) | Hall Lv80 |
| southwest | (0,120,72,72) | Hall Lv80 |
| northwest | (0,0,72,72) | Hall Lv80 |

These 13 disjoint rectangles partition 192×192 = 36,864 cells, **not** a claim that all cells are constructible. Each region remains subject to authored blocked terrain, valid footprints, doorway reachability, orthogonal adjacency to already unlocked land, and a real Hall level. If the artistic road spine or footprint prevents all 100 raw producers from fitting, change authored region/footprint content **before** claiming 30/30/40 is playable. Do not hardcode the chunk-16 renderer as an economic land-ownership grid.

**No actual region has been unlocked by this proposal.** Each unlock is a paid, timed, once-only gameplay transaction in future LAY-04, not an instant UI visibility toggle.

### 9.5 Proposed economic pilot for paid *new* raw-resource instances

These are **CANDIDATES FOR OWNER BALANCE APPROVAL**, not current code or previously locked balance.

| New instance type | Baseline common input | Sect Stones | Construction duration | One operator when active |
|---|---|---:|---:|---|
| Mỏ | 80,000 Linh Mộc + 40,000 Thanh Thiết | 200 | 240 ticks (4h) | 1 Khai Khoáng |
| Linh Lâm | 40,000 Linh Mộc + 30,000 Thanh Thiết | 150 | 180 ticks (3h) | 1 Lâm Nghiệp |
| Linh Điền | 50,000 Linh Mộc + 20,000 Thanh Thiết | 180 | 180 ticks (3h) | 1 Linh Thực; 4 subordinate plots |

Initial existing `001` instances are preserved, not billed retroactively; no duplicate "starter gift". For newly built **nth instance** `n >= 2`: `material_and_stone_cost = ceil(base_cost × [1+0.10×(n-2)])`; `construction_minutes = ceil(base_minutes × [1+0.02×(n-2)])`. Compute per component safely (no int64 overflow). At Mine 002, the base costs apply; Mine 030 multiplies costs ×3.8, time ×1.56. No construction produces output or pays work wages until it is ACTIVE and assigned a valid operator. Consumers keep independent `building_instance_id`, not `primary_building` fallback for non-primary sites.

**Existing producer *upgrade* cost must remain current code authority**: `BuildingSystem.upgrade_cost_for_state(state,building)` contains the actual Wood/Ore ×1,000 bulk adapter, Spirit Stones and tier-2/milestone requirements, plus `upgrade_required_work`. Do not overwrite this live upgrade curve merely by presenting the construction table. A later balance review can compare total input/time of build-vs-upgrade under PR #9 ×10,000 yield and warehouse stock pause.

### 9.6 Proposed singleton Main Hall Lv1–100 (NOT existing runtime)

Main Hall must become one real `BuildingState` **only after an explicit authorization and proven visual-to-instance manifest**:
- type `main_hall`, exactly one stable ID `main_hall_001`; `BuildingState.level` is the *only* Hall level. Do not add a second independently mutable `SectState.hall_level`.
- new Hall Lv1 is seeded once from an approved starting game state, not by interpreting ENV-02A artwork as a game building. Legacy-save conversion requires explicit migration policy; no invented Hall progress.
- Hall levels unlock the already-coded cap table: 1–9 → 1/1/1; 10–19 → 2/2/3; 20–39 → 5/5/7; 40–59 → 10/10/14; 60–79 → 18/18/24; 80–100 → 30/30/40.
- Average existing building levels before adding a further instance: at Hall 10/20/40/60/80 require 5/10/20/35/50 for the type being expanded, as proposed in `ResourceBuildingExpansionPolicyV2`. A missing Hall always blocks real construction; a hypothetical Hall level never authorizes it.
- Hall upgrade costs and time **provisional** at target `T=2..100`: `F(T)=1+0.05×(T−2)+0.002×(T−2)^2`, evaluated using integer/fixed-point arithmetic so binary floating-point rounding never adds a phantom material unit. Common input `ceil(10,000×F)` Linh Mộc, `ceil(8,000×F)` Thanh Thiết, `ceil(20×F)` Sect Stones; timer `20+3T` ticks. At `T in {10,20,40,60,80,100}`, multiply each material/Stone subtotal ×2 and timer ×1.5 (round up). Hall never becomes a raw-production building or requires a second operator.
- Sample Hall level-up costs at T10: 30,560 wood + 24,448 ore + 62 Stones, 75 ticks; T20: 50,960 + 40,768 + 102, 120 ticks; T40: 115,760 + 92,608 + 232, 210 ticks; T60: 212,560 + 170,048 + 426, 300 ticks; T80: 341,360 + 273,088 + 684, 390 ticks; T100: 502,160 + 401,728 + 1,006, 480 ticks.
- Do not implement until the owner approves those prices **and** Hall upgrade V2 progression is reconciled with actual ordinary yield ×10,000, market purse and late-tier component sinks. A generic Hall upgrade cannot silently bypass building tier gates.

### 9.7 Proposed land unlock tariffs (separate from building cost)

**Owner approval required** before exposing these transactions:

| Land group | Required actual Hall level | Common materials | Sect Stones | Duration | Specific gate |
|---|---:|---|---:|---:|---|
| starter | seeded | none | 0 | 0 | migrated/initial, once |
| north_01 | 10 | 80,000 wood + 40,000 ore | 200 | 180 ticks | touches starter |
| east_01 | 20 | 120,000 wood + 60,000 ore | 350 | 240 ticks | touches unlocked land |
| south_01 | 40 | 200,000 wood + 100,000 ore | 600 | 300 ticks | touches unlocked land |
| west_01 | 60 | 300,000 wood + 150,000 ore | 1,000 | 360 ticks | touches unlocked land |
| north_02 / south_02 | 60 | 400,000 wood + 200,000 ore each | 1,400 each | 480 ticks each | cardinal adjacency |
| east_02 / west_02 | 80 | 400,000 wood + 200,000 ore each | 1,400 each | 480 ticks each | cardinal adjacency |
| four corner regions | 80 | 800,000 wood + 400,000 ore each | 2,500 each | 720 ticks each | cardinal adjacency |

Large and late regions may need Huyền Thiết or additional real tier inputs before final balance approval; do **not** invent a new rare-resource faucet. The exact region footprint, adjacency and authoring rules must be validated as content on the actual map. No region goes active while its timed land project is pending.

### 9.8 Proposed exactly-once construction transaction and cancellation

All phases use **one existing `SimulationScheduler`**, canonical Warehouse and Sect Stones:

```text
preview(request) [read only]
  -> validate actual Hall BuildingState, cap, existing average levels
  -> validate region unlocked, footprint, doorways, route, construction slot
  -> re-read current layout_revision and actual resources/reserve/locks
  -> check request_id and immutable payload digest in saved receipt ledger
  -> atomically debit Warehouse + Sect Stones ONCE
  -> create non-producing BuildingState(status="constructing")
  -> reserve/record its single placement in SectLayoutState
  -> append immutable receipt, increment layout_revision
  -> on existing scheduler finish_tick => set ACTIVE exactly once
  -> only then may an assigned, eligible operator start production
```

A duplicate identical request returns its receipt; same request ID with different content fails. A rejected request does not debit, insert building or increment revision. Any validation/consumer failure must rollback **all** state mutations in the same transaction before returning. Never rely on UI double-click protection as the only safeguard. Keep independent `building_id` in worksite assignments and field timers.

**Pilot construction cancellation recommendation: disabled once paid construction starts**, rather than introducing partial refunds/ambiguous material claims in V1. User may cancel a preview freely, with no charge. Land expansion projects are similarly non-cancellable after the atomic paid start unless a separately approved refund contract exists. Saved in-flight construction continues offline via the sole scheduler, and restores from backup without duplicate debit or completion.

### 9.9 Gate-by-gate acceptance before any claim of real construction

| Gate | Required proof | Present status |
|---|---|---|
| **ENV-02A Windows** | exact 35 PNG hash/provenance, official Godot 4.7.2 import/scene, 192×192/16×16/camera/culling/AStar, 20×13 compatibility, two actual screenshots, logs | **PENDING USER**; code-only static report is not sufficient |
| **ADR-0003 LAY amendment** | explicitly transfer placement ownership from fixed layout to one persistent SectLayoutState, without second authority | **OWNER DECISION REQUIRED** |
| **LAY-01 code** | approved schema + full real-instance seed manifest, migrate/replay/roundtrip, no fake Hall/building, rollback on failure | **NOT AUTHORIZED** |
| **Hall/instance cost balance** | owner approves proposed Hall, raw building and land costs/timers and level thresholds after simulation | **OWNER DECISION REQUIRED** |
| **LAY-02 code** | moved building ID, job, worker and production preserved; snapshot revisions/pan/tap; no stale route or phantom UI | **NOT AUTHORIZED** |
| **LAY-03 code** | paid build, no over-cap/overlap, material reserve, one-time receipts, offline timer, all-instance operator/UI and exact save/load | **NOT AUTHORIZED** |
| **LAY-04 code** | adjacent region, paid timed unlock, no repeat/free regions, valid land capacity and Android acceptance | **NOT AUTHORIZED** |
| **Windows/Android QA** | focused + affected cumulative Godot 4.7.2 on exact SHA; real GUI and Android taps/save-kill/performance | **PENDING USER** |

**Evidence distinction:** Codex-reported Windows P3.7 FULL exit 0 at `453df9aa...` applies to an earlier Economy V2 PR #9 code/test SHA; it does not validate the proposed LAY schema, real ENV-02A scene or any future construction implementation. PR #12's cap preview and this document do not authorize enabling build UI.

### 9.10 Decisions to request from owner before CODE LAY

1. Approve the **ADR-0003 ownership change** to persistent `SimulationState.sect_layout` for managed buildings; no duplicate `BuildingState` x/y.
2. Approve LAY-01 **CODE scope only** (schema, explicit static-seed manifest, migration tests, no build/move/unlock). Gate ENV-02A Windows and reviewed placement assets still need proof before declaring accepted.
3. Approve Main Hall as singleton `BuildingState`, with Hall level as the sole source for future caps; distinguish managed real instance from Source A art landmark.
4. Approve or adjust numeric **construction, Hall-upgrade and land tariffs/timers** in 9.5–9.7; this is pilot balance, not merged authority.
5. Decide the first map regions and reviewed footprint/doorway manifest with reproducible ENV-02A evidence, including whether all 100 raw buildings really fit after blocked terrain and roads.
6. Keep LAY-02/03/04, FE-02, Combat and Android art integration unopened until separately authorized; prohibit any free construction/UI claims before the actual command passes.

