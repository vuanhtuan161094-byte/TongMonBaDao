# MAP-D0 — Kiểm toán và thiết kế lại map tông môn

**Ngày:** 2026-10-25  
**Repository:** vuanhtuan161094-byte/TongMonBaDao  
**Baseline:** PR #31, nhánh integration/pr28-combat-v3-s1-playable-qa-20261024, evidence HEAD 9eb4fd55733bb49bbb069240b8e332d37d22aced. PR #31 đang OPEN / DRAFT, chưa merge.  
**Phạm vi:** nghiên cứu, sơ đồ và packet thiết kế. Không sửa code, asset gốc, gameplay, UI đã QA, hoặc chạy test mới.

## Kết luận điều hành

Map tông môn đang chạy được và có bộ art Source A được SHA-gate: Main Hall, Forge, Warehouse, terrain đá, đường lát và props thực vật. Vấn đề chính là bố cục và độ đầy đủ ngữ nghĩa: các công trình gom lệch sang phải trên mặt cỏ xanh lặp lại; điểm Mỏ/Linh Lâm/Linh Điền có state thật nhưng chưa có bộ công trình/worksite art đủ rõ để người chơi nhận ra ngay trên bản đồ.

Đề xuất **B — trục cổng, sân trung tâm, ba khu chức năng**, giữ nguyên lưới, chunk, camera đơn, runtime, selection, production cue và authority. Chỉ thay vị trí presentation anchors và tuyến đường trong phạm vi map. Các site thiếu art phải tiếp tục được đánh dấu thiếu, không vẽ giả công trình hay animation.

Đây là đề xuất thiết kế, chưa phải CODE authorization. Owner cần chọn A/B/C trước một packet code riêng.

## 1. Nền xác minh

| Mục | Đã xác minh |
|---|---|
| PR #31 | OPEN, DRAFT, chưa merge; base ui/pr27-runtime-readability-20261024; head 9eb4fd55733bb49bbb069240b8e332d37d22aced |
| Code/test snapshot | 4b02a0c61a2771d9d4638129d96b68ad292270dc; tree 352700b65d3cd0ef7039df22a1153d81b2fd7b82 |
| QA được ghi trên PR #31 | Godot official 4.7.2: focused 28/28 PASS (gồm O9), S1 edge 56 checks PASS; MAP-D0 không chạy lại |
| Runtime evidence | 19 ảnh 1280×720, manifest SHA; 19/19 file ảnh khớp manifest |
| Source A gate | Godot official 4.7.2: MAP25 SOURCE A SHA-GATED ART CONTRACT PASS accepted=32 missing=0 rejected=0 |
| MAP-D0 | Nhánh tài liệu được tách từ đúng PR31 HEAD; không cập nhật main |

Đã đọc AGENTS.md, branch audit và next-steps, map checkpoint, game architecture, PR31 evidence packet, screenshot manifest, 19 runtime captures, QA log, map scripts/camera, Source A manifest và ART BIBLE references.

## 2. Kiểm toán map hiện tại

### Runtime và điều khiển

- Sect map là world isometric riêng: grid 192×192, chia chunk 16×16; khu khởi đầu Rect(72,72,48,48).
- Projection dùng nửa trục 25×13 px; world map nằm trong SubViewport 1280×570, HUD ngoài camera.
- Camera map pan/zoom dùng chung; zoom 0.75–1.8, mặc định 1.0, focus 1.35. Ảnh runtime chứng minh thao tác hoạt động.
- Map model giữ footprint/doorway anchors và AStarGrid2D preview. Đây là hỗ trợ layout/đường xem trước, không phải navigation AI của đệ tử hoặc dữ liệu xây dựng đã lưu.
- Picking dùng screen-to-world/projection và ellipse quanh điểm chọn; props không phải từng PhysicsBody2D.
- Mỗi chunk 16×16 tối đa 1024 vertices/1536 indices. 144 chunk toàn bản đồ tương ứng 147,456 vertices nếu dựng hết. Renderer giới hạn vùng theo camera và margin ba ô. Ước lượng 9–36 chunk nằm trong vùng culling theo zoom được suy ra từ code; chưa phải benchmark.
- Ground hiện xanh lặp lại; palette có bốn terrain nhưng draw đang dùng stone_courtyard. Route preview nối spawn với Hall/Warehouse/Forge, chưa có tuyến ngữ nghĩa hoàn chỉnh đến mọi producer site.
- Anchor chức năng có Hall, Forge, Warehouse, Mine, Forest, Field, residence và các loại site khác. Anchor gameplay không đồng nghĩa đã có art/công trình site.

### Bằng chứng trong 19 ảnh

| Ảnh | Trạng thái / kết quả |
|---|---|
| 00 | Map chính: ba building Source A rõ; mặt cỏ phẳng lớn, cụm lệch phải; thiếu trục vào → sân → chính điện |
| 01 | Pan/zoom 135% hoạt động; Hall/công trình sát rìa crop; anchors rải |
| 02 | Panel Mỏ đọc mine_001; tinh thạch cạnh đó là prop, không phải building Mỏ |
| 03 | Panel Linh Lâm đọc linh_forest_001; cây tạo grove nhưng chưa có trạm lâm nghiệp |
| 04 | Panel Linh Điền đọc spirit_field_001, bốn plot trống; map thiếu cụm ruộng/cây trồng dễ đọc |
| 05 | Kho hiển thị số canonical |
| 06–07 | Hồ sơ đệ tử; không phải map state, giữ nguyên UI |
| 08 | Kết toán Mỏ thật tick20, worker trieu_linh_nhi, phases travel_out → mining → haul_back; Thanh Thiết 37 → 39 (+2) |
| 09–15 | Thanh Trúc Lâm / hunt-world CARE + Combat V3-S1: chiến đấu, hiệu ứng, HP, kill, loot, same-world respawn. Không phải sect map |
| 16 | Trở về đúng map tông môn sau săn |
| 17–18 | Runtime capture cuối và SaveService reload evidence |

**Ranh giới:** Map tông môn là không gian sinh hoạt/tu luyện/sản xuất. Map săn Thanh Trúc Lâm có 20 bãi và là world riêng. Không chuyển 20 bãi, mob spawn hay hunting camera vào thiết kế sect map.

## 3. Source A asset audit

### Có và SHA-verified

Có 32 PNG trong godot/art/source_a_env02a, tổng 2,169,285 bytes trên đĩa; không phải VRAM/RAM texture. Manifest godot/data/presentation/map25_source_a_verified.json chứa SHA-256; raw hash local khớp 32/32. Godot gate chấp nhận 32, thiếu 0, reject 0.

- 4 stone terrain, 6 road/path, 19 vegetation/props đánh số.
- 3 building PV01: Main Hall 510052, Warehouse 510102, Forge 520081.
- Layout dùng 18/19 props; 570183 nằm trong manifest/gate nhưng chưa được đặt.
- Kích thước hiển thị xấp xỉ Hall 300×201, Warehouse 162×138, Forge 205×164 px; đây là sprite extents, không phải footprint.
- Art map hiện là raster tĩnh. Manifest/clip set được rà không có animation clips/FPS, atlas metadata hoặc pivots đủ căn cứ suy diễn animation.
- Crystal-rock 570073 là prop, không phải building Mỏ. Numeric asset ID không chứng minh nghĩa gameplay.
- Registry/source recovery docs ngày 2026-10-03 đã cũ so với 32 PNG được SHA-gate trên PR31. Ba buildings đang có cũng không chứng minh cả family tám building từng được owner duyệt đã phục hồi.

### Thiếu hoặc phải xác minh riêng

| Thành phần cần | Trạng thái | Khuyến nghị D0 |
|---|---|---|
| Cổng, tường/rào, điểm vào | Chưa chứng minh có art trong manifest | Chỉ bố trí trục; không vẽ giả cổng |
| Suối/nước/cầu, núi/vách, đất tự nhiên | Chưa có bộ được SHA-gate trong palette hiện tại | Không tự lấy asset chưa xác minh |
| Nhà/khu sinh hoạt | Chưa có site building nhận dạng | Để reserve và ghi asset gap |
| Công trình Mỏ | Có anchor và props đá/tinh thể | Giữ cue/site thật; không đổi prop thành building |
| Trạm Linh Lâm | Có cây; thiếu trạm/animation được xác minh | Grove chỉ dùng cây hiện có; ghi rõ gap |
| Plot/cây trồng Linh Điền | Props chưa đủ semantic/animation proof | Không giả chu kỳ/cây trồng |
| Tu luyện/đấu luyện/luyện đan | Chưa có bộ building được xác minh | Zone reserve, chưa có art claim |

Danh sách tên file, SHA-256, bytes và mapping snapshot đầy đủ ở Asset & Evidence Matrix cùng branch.

## 4. Vấn đề bố cục và tỷ lệ

1. Ground xanh lớn, đơn sắc khiến các silhouette thật chiếm ít diện tích thị giác.
2. Không có hierarchy cổng vào, courtyard, Main Hall, rồi các khu chức năng.
3. Người chơi chọn được Mỏ/Lâm/Điền bằng panel nhưng map chưa thể hiện rõ nghĩa công việc.
4. Stone path tồn tại nhưng chưa tạo trunk hub với nhánh đến các site và Warehouse.
5. Zoom/pan hoạt động, nhưng composition 135% crop building sát rìa; landmark quan trọng cần nằm trong vùng an toàn ở zoom mặc định.
6. Terrain không phân biệt khu vực; không được chữa bằng hình mockup, cây tròn hay đổi sang hunt map.
7. 192×192 cho phép reserve vùng mở rộng nhưng cần phân biệt rõ layout concept với trạng thái unlock/placement đã lưu.

## 5. Ba phương án bố cục

Các sơ đồ 1280×720 kèm theo là SVG tĩnh để thảo luận, không phải screenshot game hoặc runtime proof. Hatch và nhãn ASSET GAP chỉ vùng chưa có art đã xác minh.

### A — Bảo thủ, tái phân bố trong starter area

Giữ grid, chunk, khu 48×48, camera và contracts. Sắp lại Hall/Forge/Warehouse, cây/đường để giảm lệch; nối ngắn tới site marker thật; dùng art có sẵn. Không dựng cổng/nhà/mỏ/ruộng giả.

**Ưu:** chi phí và rủi ro thấp, hầu hết dùng asset hiện có.  
**Nhược:** hierarchy ba khu còn yếu, semantics các worksite chưa rõ.

### B — Trục cổng → sân → chính điện, ba khu (**khuyến nghị**)

Giữ grid/chunk/projection/SubViewport, camera đơn, picking, runtime/state/anchors. Tạo trục lối vào (asset gap) → courtyard đá → Main Hall. Nhóm ba khu có route riêng: sinh hoạt (reserve), tu luyện (reserve), sản xuất (Forge + Warehouse thật, các Mỏ/Lâm/Điền giữ identity/cue thật và art gap có nhãn). Dùng art Source A đã xác minh. Đưa landmarks vào safe bounds ở zoom mặc định; kết nối hub ↔ production ↔ Warehouse.

Bố cục chỉ là presentation. Không tạo save field/unlock state; không dùng hunt map.

**Ư:** hierarchy dễ đọc, tận dụng assets, scope có thể nghiệm thu bằng focused tests.  
**Trade-off:** vẫn thiếu cổng/nhà/trạm/ruộng để art hoàn chỉnh.

### C — Tông môn phân district trên 192×192

Dùng 12×12 chunk cho sơ đồ tổng thể: hub/courtyard, sinh hoạt, tu luyện, sản xuất và vùng mở rộng. Starter 48×48 là khu chơi đầu. Overview toàn cõi chỉ là planning map; không thể hiển thị đầy đủ cùng lúc trong camera 1280×720 mà landmarks vẫn đọc được.

**Ư:** hướng mở rộng dài hạn rõ.  
**Rủi ro/chi phí cao:** yêu cầu art nhiều hơn, culling/performance profiling và camera/focus rules; nguy cơ nhầm vùng dự kiến với state đã persist; zoom-out làm nhỏ UI/landmarks. Chưa nên làm trước B.

## 6. Sơ đồ 1280×720

- A: evidence/map-d0/option-a-conservative.svg
- B: evidence/map-d0/option-b-functional-hub.svg
- C: evidence/map-d0/option-c-district-expansion.svg

Sơ đồ đánh dấu asset đã có bằng ID/nhãn, và đánh dấu vùng thiếu art. Không chứng minh runtime camera feel hay performance.

## 7. Giới hạn Godot và hướng kiểm tra

### Camera, SubViewport, CanvasItem

Camera thuộc Viewport và áp transform camera trong viewport đó. Map P3.2 ở SubViewport 1280×570; HUD ở ngoài. Giữ duy nhất một camera authority cho map viewport, không thêm camera theo zone hoặc đưa hunt camera vào sect map. Giữ HUD đứng yên khi pan/zoom. Không viết renderer mới ở D0/D1; giữ redraw, draw order và culling hiện hữu cho tới khi có benchmark chứng minh cần đổi.

### AStar, grid và picking

AStarGrid2D có thể tìm path trên lưới 2D; hiện nó chỉ là preview/layout aid, không phải disciple navigation. Nếu chọn B, focused checks cần xác nhận cell-world projection, footprint/doorway, blocked cells, path hub tới tất cả site và không cắt building footprint. Picking đang dùng tọa độ/projection và ellipse; sau đổi anchor phải xác minh vùng bấm, z/sort order khi sprite chồng đường. Không thêm collision bodies cho từng prop trang trí.

### Chunk/performance

Chunk 16×16 có 256 cell; 144 chunk phủ 192×192. Ước lượng 9–36 chunk trong camera là suy từ bounds/culling, chưa đo. Capture ghi 1–24 FPS và static memory khoảng 62.7–73.7 MiB trên Intel Iris Plus/OpenGL Compatibility; đây là mẫu capture, không phải sustained FPS, process RSS hay VRAM. **Không kết luận hiệu năng đạt.** Windows sustained/perf và Android thật còn PENDING.

Sau khi được cấp CODE: đo ở zoom 0.75/1.0/1.8, pan bốn góc, mở từng panel/site, ghi frame time/FPS/GPU/driver và lỗi parse/render tại 1280×720. Không FULL/CI.

### Asset scale/animation

Manifest hiện thiếu pivot/FPS/clips. Asset mới cần provenance, SHA-256, dimensions, alpha bounds, intended size, pivot/contact point, facing, animation frame/rate/action semantics và license/owner acceptance. Không animate props tĩnh thành hành động gameplay.

Tham khảo tài liệu Godot chính thức 4.7: [Camera2D](https://docs.godotengine.org/en/4.7/classes/class_camera2d.html), [CanvasItem](https://docs.godotengine.org/en/4.7/classes/class_canvasitem.html), [AStarGrid2D](https://docs.godotengine.org/en/4.7/classes/class_astargrid2d.html), [TileMapLayer](https://docs.godotengine.org/en/4.7/classes/class_tilemaplayer.html), [2D transforms](https://docs.godotengine.org/en/4.7/tutorials/2d/2d_transforms.html), [Navigation maps](https://docs.godotengine.org/en/4.7/tutorials/navigation/navigation_using_navigationmaps.html), [Path-query objects](https://docs.godotengine.org/en/4.7/tutorials/navigation/navigation_using_navigationpathqueryobjects.html), [Performance](https://docs.godotengine.org/en/4.7/tutorials/performance/).

## 8. So sánh chi phí và rủi ro

| Hạng mục | A | B | C |
|---|---|---|---|
| Chi phí tương đối | Thấp | Trung bình | Cao |
| Dự kiến chạm code nếu được cấp phép | Một map layout/presentation script | Map layout + focused layout test | Layout, camera/chunk rules, nhiều QA |
| Asset tái dùng | Hall, Forge, Warehouse, roads, terrain, plants | Cùng bộ A, tổ chức theo zone | Cùng bộ; cần thêm district kits |
| Asset gap | Cổng/nhà/Mỏ/Lâm/Điền | Như A, thêm tu luyện/sinh hoạt/site silhouettes | Nhiều nhất, toàn district/terrain/landmark |
| Gameplay/save risk | Thấp nếu chỉ đổi anchors | Thấp–trung bình; giữ identity/anchor invariants | Trung bình–cao, nguy cơ nhầm planning/persisted state |
| Camera/readability risk | Thấp–trung bình; hierarchy còn yếu | Trung bình; kiểm tra safe bounds/picking/route | Cao; overview toàn map chỉ đọc ở zoom nhỏ |
| QA | Projection, camera, selection, screenshots | A + path/connectivity, site cue, production/save | B + extensive chunk/performance/camera |
| Quyết định | Fallback rẻ | **Khuyến nghị MAP-D1** | Hoãn |

Chi phí là so sánh tương đối, không phải ước lượng giờ công.

## 9. Invariants và focused QA sau CODE authorization

Không thay đổi Combat V2/V3, CARE/medical, Injury120, hunt world/20 camps; Warehouse/SaveService/offline/economy/production scheduler; P3.2 runtime/state/canonical identity/One Active Job; D7/stat/balance/XP; UI/panels đã QA; Source A gốc/manifest/import output; PR #24–31. Không merge và không chạy FULL/CI.

Focused regression đề xuất: map projection/camera/picking, layout/path/footprint, worksite cue/settlement, 32 SHA art gate, canonical Warehouse/save-load, 28 CARE-focused/O9 và 56 S1 edge checks. Lệnh test chính xác phải được xác nhận theo AGENTS/checkpoint khi có CODE packet.

## 10. Đề xuất và gate

Đề xuất chọn B. Nó giải quyết hierarchy bằng art đã tồn tại, giữ layout contracts và không phụ thuộc tạo placeholder. Những công trình chưa có sẽ được biểu diễn là asset gap rõ ràng cho tới khi có Source A hợp lệ.

Trước MAP-D1, owner cần xác nhận:
1. Chọn A, B hoặc C.
2. Cổng/nhà ở có thể là vùng reserve có nhãn asset gap, không mockup.
3. Vị trí là presentation anchors, không lưu placement/unlock mới.
4. Route đọc chính: vào → courtyard → Main Hall, nhánh production/Warehouse.

Lựa chọn phương án không tự cấp quyền sửa code/asset. Packet D1 đề xuất phạm vi B riêng trong TMB_MAP_D1_PROPOSED_IMPLEMENTATION_PACKET_2026-10-25.md.

## Trạng thái

- MAP-D0 research/design: COMPLETE.
- Runtime/code/asset change, test run: NOT DONE; không được cấp phép trong scope nghiên cứu.
- Owner option A/B/C: PENDING.
- Windows manual, Android, sustained performance và owner visual acceptance: PENDING.
- Sect map và Thanh Trúc Lâm: hai world riêng.
