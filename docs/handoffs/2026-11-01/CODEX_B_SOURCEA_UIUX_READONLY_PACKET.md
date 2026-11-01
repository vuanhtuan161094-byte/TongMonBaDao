# COPY-READY CODEX B PACKET — SOURCE A BUILDINGS & NATIVE GODOT UI/UX DESIGN ONLY
**OWNER SUGGESTION; NOT YET SENT TO CODEX. B0 is separated from TRI-01 Codex A.**

> Bạn là Codex B, kỹ sư chuyên giao diện 2.5D Godot/asset provenance cho TÔNG MÔN BÁ ĐẠO. Hiện Codex A là người DUY NHẤT được viết gameplay/hợp nhất Đại Điện V2, Đệ Tử Xá V2 và Dẫn Tiên Đài V2. Nhiệm vụ B0 của bạn là kiểm toán sâu toàn bộ game về bề mặt đồ họa và chuẩn bị thiết kế nâng cấp UI/UX. **CHƯA VIẾT GDSCRIPT GAMEPLAY, CHƯA IMPORT ASSET NHỊ PHÂN, CHƯA CHẠY GODOT, CHƯA TÍCH HỢP/CHERRY-PICK/MERGE.** Không chạy ngầm hoặc tự động tải cài đặt gì nặng. Chỉ có quyền đọc source và tạo tài liệu nghiên cứu trên nhánh docs riêng do chính bạn tạo.

## Repo & checkpoint

- Game: vuanhtuan161094-byte/TongMonBaDao
- Nguồn tài liệu trước tiên: `docs/dual-codex-sourcea-uiux-audit-20261101` / `docs/handoffs/2026-11-01/TMB_DUAL_CODEX_SOURCEA_UIUX_AUDIT.md`.
- TRI-01 Codex A: `docs/three-buildings-codex-handoff-20261101` / `docs/handoffs/2026-11-01/CODEX_TRI_FACILITY_INTEGRATION_PROMPT.md`.
- Reference source assets: vuanhtuan161094-byte/ZQZS-Source-Knowledge @ `83cbc4ecbd83eb518a6d6f2b3894377d9d99254d` path `transferkit/Catalog/BUILDING_VISUAL_INDEX.csv`, `transferkit/Catalog/UI_SCREEN_INDEX.csv`, `transferkit/Catalog/UI_PREFAB_PROBE.json`.
- Game manifest: `godot/data/presentation/source_a_candidate_manifest.json`, `godot/data/presentation/map25_source_a_verified.json`, `docs/P3_ASSET_REGISTRY.json`.
- Last verified RC: `rc/one-game-playable-20261101` SHA `970af33b23076c80d677cf5898a721a27504708f`; PR #64 DD09.2 SHA `bf3ed0310899c554eea4e6b2e1967dcada2d68dd`. Fetch LIVE refs again before reporting; these may change.

## B0.1 — Rà soát toàn bộ game về visual UX

Đi tuần tự theo source path:
- Bản đồ chính: `godot/src/presentation/p3/sect_isometric_world_v1.gd`, `godot/src/presentation/p3_2_landscape_sect.gd`, camera, actor overlays, building click-focus.
- Công trình: Hall (PR64 `dai_dien_screen_v1.gd`), Residence (PR64 `sect_residence_system_v1.gd` + UI), Dẫn Tiên (RC `dan_tien_screen_v2.gd`), Kho, Mỏ, Linh Lâm, Linh Điền, Luyện Đan, Luyện Khí, Tu luyện.
- Đệ tử / D7 / hồ sơ HS09 / công pháp / lựa chọn nhân sự, chế độ PvE HUD — chỉ REVIEW, không sửa.
- UI control scaffolding, fonts, theme, panel clipping, touch 1280×720 landscape, data ownership, asset registry + actual loaded sprite paths.
- Liệt kê từng mặt UI: dữ liệu người chơi cần, action canonical, yếu tố quá nhiều chữ, ảnh còn trống, icon thiếu, gợi ý progressive disclosure. Không phán xét chất lượng ảnh khi chưa xem capture thật.

## B0.2 — Kiểm kê & nghiên cứu Source A

- Kiểm hết 13 ứng viên công trình trong manifest (trong đó **Residence 510076 và Guidance 510111 là hai thiếu hụt ưu tiên**; Hall 510052, Warehouse 510102, Forge 520081 đã có PNG runtime candidate). Không suy diễn có 13 asset sạch, không dùng tên file làm bằng chứng bản quyền/kỹ thuật.
- Ghi rõ `logical_id`, Source A config id, `source_model_id`, SHA256, alpha/canvas dimensions, atlas vs precomposed sprite, Spine skeleton/atlas dependencies, pivot/anchor/pixel-door, frame orientation, fallback, quyền khai thác và cấp phép.
- Đặc biệt đối chiếu **Residence source door [1,-1]** với **DD09.2 plot door [1,3]**; báo discrepancy có hình/geometry evidence, TUYỆT ĐỐI KHÔNG sửa actor route/save/footprint/door offset; Codex A quyết định remedy sau khi có Godot real evidence.
- Catalog chỉ chứa văn bản và đường dẫn E:\GameAssetExtract gợi ý, **không chứng minh file PNG/atlas ấy hiện tồn tại hoặc đã được phép phân phối**. Nếu không có file hoặc rights: ghi BLOCKED, không bịa asset.
- Kiểm tra Source A `uibuildingmsgwin` và `uilayouteditwin` metadata như reference, không port prefab Unity hoặc chép UI sprite chưa rõ rights. Các ví dụ screenshot ngoài web chỉ dùng để phân tích composition/hierarchy, KHÔNG lấy cắp ảnh/asset game thứ ba.
- Không dùng JX/JXQY hay game gốc làm gameplay/code authority; Source A chỉ làm visual benchmark/asset ứng viên khi chủ dự án có quyền hợp lệ.

## B0.3 — Thiết kế 3 bản UI Godot native để sau tích hợp

Đặc tả chi tiết màn 1280×720, ưu tiên ảnh hơn chữ:
1. **Đại Điện**: minh họa công trình chiếm 32–36%, rank 27 bậc dạng thanh/mốc, 7 ghế chức vụ ảnh đệ tử + cấp tinh thông + hiệu ứng chip; chọn chức vụ mới hiển thị card suitability và action, cost/upgrade/requirement theo 2 cột, CTA cố định.
2. **Đệ Tử Xá**: art nhà Source A 510076 khi đủ điều kiện, số giường hiển thị bằng biểu tượng/slot chứ không liệt kê dài, danh sách cư dân có ảnh, chọn lô nhanh, progress xây dựng/upgrade, giá/kho ngay cạnh nút. Không cần đường kết nối, nhân vật tương tác tại cửa ngoài.
3. **Dẫn Tiên Đài**: giữ nguyên RC `CandidateDecisionActions`; card thumbnail/page, chân dung Source A, radar D7 lồng nhau (nếu chuẩn HS09), icon Linh Căn/thiên hướng, 2 nút nhận/từ chối neo cuối, mã chiêu mộ và cap hiển thị rõ. Không thêm gacha/đổi odds.
Màu gợi ý: giấy ngà + ngọc bích + mực xanh thẫm + vàng đồng; chỉnh để thống nhất Source A và HS09 nhưng phải tự sáng tạo UI panel/crop không vi phạm quyền. Icon tối đa 24–32 px, hit area 44–48 px, typography màn hình 1280×720 đủ đọc, không che map/hotbar. Kiểm tra vùng portrait, visual state empty/loading/blocked/ready, tác động của bấm nút và focus.
Đề xuất hai cấp: chạm nhà trên bản đồ -> drawer gọn phải rộng 400–440px với 2 CTA; bấm Quản lý -> màn detail/overlay; chỉ màn cần hành động phức tạp mới chiếm phần lớn viewport.
Tất cả hình phải có chú thích `EXISTING`, `CANDIDATE NOT APPROVED`, `RIGHTS BLOCKED`, `MISSING`, hoặc `ORIGINAL DESIGN`.

## B0.4 — Deliverable GitHub docs-only

Tạo nhánh docs/visual-b0-sourcea-ux-20261101 từ LIVE RC (nếu tên đã tồn tại chọn hậu tố mới). Chỉ commit:
- `docs/uiux/B0_BUILDING_ASSET_PROVENANCE_MATRIX_20261101.md`: 13 ứng viên source A + 3 runtime, rights/SHA/door/texture atlas.
- `docs/uiux/B0_GAME_UI_SURFACE_AUDIT_20261101.md`: bảng toàn bộ màn thật có mã file và lỗ hổng visual/UX + mức P0/P1/P2.
- `docs/uiux/B0_TRI_FACILITY_NATIVE_SCREEN_BLUEPRINT_20261101.md`: đặc tả UI nêu trên, thứ tự tương tác 1280×720; nếu có wireframe thì tạo bằng markup gốc chỉ để mô tả, KHÔNG tuyên bố gameplay mock là screenshot Godot.
- `docs/uiux/B0_INTEGRATION_BOUNDARY_20261101.md`: danh sách file B sẽ được phép tạo MỚI ở pha B1 sau khi A ổn định, cấm file chung/canonical state, tất cả QA đề xuất và vấn đề cần owner quyết định.
Không thêm .gd, .tscn, .tres, ảnh nhị phân, Unity bundle, asset quyền chưa rõ. Không tạo CI, telemetry, FPS logger, không chạy Godot để cạnh tranh RAM/PID của Codex A.

Báo 1) HEAD đọc, 2) nguồn và SHA manifest, 3) danh sách file docs và commit SHA, 4) đề xuất file allowlist pha B1, 5) BLOCKER asset/missing rights, 6) xác nhận các file game/RC/PR64 vẫn không thay đổi. Dừng tại B0, chờ chủ dự án cho phép B1. **Chưa được viết runtime UI hay merge.**
