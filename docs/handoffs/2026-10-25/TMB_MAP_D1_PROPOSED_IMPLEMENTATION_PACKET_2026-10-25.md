# MAP-D1 — Packet triển khai đề xuất (chờ owner chọn phương án)

**Trạng thái:** DESIGN ONLY. Chưa có quyền sửa code/asset.  
**Nguồn:** MAP-D0 report trên cùng branch.  
**Baseline đề xuất:** PR #31 evidence HEAD 9eb4fd55733bb49bbb069240b8e332d37d22aced (code/test snapshot 4b02a0c61a2771d9d4638129d96b68ad292270dc).  
**Khuyến nghị:** B, trục vào → courtyard → Main Hall với ba khu.

## Mục tiêu

Thử bố cục sect map dễ đọc hơn bằng anchors, đường và art hiện tại. Giữ gameplay authoritative, runtime, simulation, selection identity, camera, SubViewport, production worksite cue, Warehouse và SaveService nguyên trạng. Sect map không nhập world Thanh Trúc Lâm hoặc 20 hunt camps.

## Preflight khi owner chọn B

Trước khi bắt đầu CODE:
1. Xác nhận PR #31 HEAD/evidence commit và nhánh mẹ còn nguyên; tạo nhánh mới từ chính baseline đã duyệt.
2. Kiểm tra AGENTS.md, status của worktree và thay đổi chưa commit. Không reset/clean/overwrite.
3. So sánh các contract hiện tại trong map model, renderer, camera, P3.2 controller, worksite cue và tests. Nếu phải chạm file ngoài allowlist dưới đây, dừng trước khi sửa và báo cụ thể lý do.
4. Xác minh manifest + raw SHA Source A vẫn 32/32; không đổi art.
5. Ghi snapshot baseline cho test/log/ảnh trước code.

## Allowlist nhỏ nhất đề xuất

| File | Vai trò |
|---|---|
| godot/src/presentation/p3/sect_isometric_world_v1.gd | Tái bố trí presentation anchors/road layout. Giữ constants grid/chunk/projection, asset gate, refresh/state contract, screen pick contract |
| godot/tests/presentation/sect_iso_main_integration_test.gd | Chỉ sửa khi test hiện có cần cập nhật expectation layout; không xóa/bỏ assertion |
| godot/tests/presentation/sect_map_d1_layout_contract_test.gd | Có thể tạo test focused mới cho bất biến B nếu owner CODE authorization bao gồm tests |

Không dự kiến sửa p3_2_landscape_sect.gd, sect_map_camera.gd, sect_map25_source_art.gd, sect_production_worksite_cue.gd, scene/resources, assets/manifest, Simulation, Combat/CARE, Warehouse, SaveService, economy, scheduler hoặc UI panels. Nếu không thể đạt kết quả trong allowlist thì pause trước khi mở rộng.

## Không được làm

- Không đổi grid 192×192, chunk16, starter rect, coordinate/projection dimensions hoặc camera behavior.
- Không đổi type IDs, site identity, resource IDs, worksite lifecycle, worker, ETA, yield, production settlement, combat/CARE, time authority hoặc save schema.
- Không tạo state riêng cho layout, district unlock, worksite, map save hay demo.
- Không thêm renderer, TileMapLayer migration, navmesh/pathfinding gameplay hoặc collision body cho props.
- Không dùng asset chưa được SHA-gate, không dựng mock building/cổng/ruộng/núi/nước, không giả animation/chặt/đào/trồng.
- Không chuyển 20 hunt camps hoặc hunt camera sang sect map.
- Không full test/CI, merge, push hoặc sửa PR #24–31. Việc push/PR cần scope được ghi rõ trong authorization riêng.

## Thiết kế B

- Visual trunk: entry reserve (labelled asset gap) → stone courtyard → Main Hall 510052.
- Reuse Forge 520081 and Warehouse 510102 in production cluster; keep resource/site anchors Mine, Forest, Field unchanged as gameplay identities.
- Group currently verified vegetation to suggest edges/grove only; do not assert a tree is an active worksite.
- Layout paths must remain connected from spawn/hub to Hall, Forge, Warehouse and each real site marker. The path art remains decorative; AStar preview remains presentation-only.
- Place key buildings inside the default 1280×570 camera safe frame at default zoom; verify pan/zoom extremes without clipping essential selectors.
- Retain existing worksite selection cue and production/result panel. Do not repaint the panel.
- All zones that require missing buildings remain reserved/hatched in design docs until approved art exists.

## Focused verification gate

Run only focused Godot official 4.7.2 checks after the owner authorizes CODE. Record exact executable/version, command, cwd, SHA, exit code and unedited log. Required cases:

1. Existing sect map projection, cell↔screen, camera pan/zoom and selection test.
2. Layout contract: exact real building art IDs; anchors unchanged; path preview reaches hub and site nodes; route does not traverse building footprints; no inaccessible selection targets.
3. Existing site cue and production timeline behavior for Mine, Linh Lâm and Linh Điền.
4. Source A SHA-gate remains accepted=32, missing=0, rejected=0.
5. Canonical Warehouse and Save/Load related focused tests unchanged and pass.
6. Existing PR31 regression: CARE focused 28/28 including O9; S1 edge 56/56.
7. Godot real P3.2 screenshot at 1280×720: default view, site selection, production settlement, Warehouse, profile and return-from-hunt. Save hashes in evidence packet.
8. Compare A baseline screenshot to B at same resolution/runtime state. Mark owner visual review PENDING until owner inspects.

No FULL/CI. If a test fails, report actual result; only repair within allowlist; do not weaken expected values to get PASS. If failure requires expansion, stop and report.

## Performance/evidence

MAP-D1 is not a performance certification. At minimum collect default/min/max zoom and four pan bounds, frame-time/FPS samples, memory definition/source, hardware/GPU/driver, Godot renderer and any stutter. Keep screenshot/runtime proof separate from schematic. Windows/manual, Android and owner visual remain pending until directly evidenced.

## Deliverables after authorization

- New isolated branch from exact PR31 baseline; no merge.
- Commits/checkpoints grouped by presentation change and focused test.
- Focused pass/fail logs and 1280×720 runtime screenshots.
- Before/after comparison with same state, camera scale and display bounds.
- Updated issue matrix with closed vs pending gaps and source provenance.
- Stop report if required scope exceeds allowlist.

## Owner decision requested

Choose A, B or C in MAP-D0. Recommended: **B**. That selection approves design direction only. A separate explicit CODE authorization should specify the selected option, baseline SHA and allowlist before implementation begins.
