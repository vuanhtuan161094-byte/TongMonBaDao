# TÔNG MÔN BÁ ĐẠO — MAP-D2 trực tiếp từ ChatGPT / bản thử nghiệm code

**Ngày:** 25/10/2026 · **Trạng thái:** CODE COMMITTED / **GODOT 4.7.2 QA PENDING** / OWNER VISUAL PENDING / NOT RELEASE.

**Repo:** `vuanhtuan161094-byte/TongMonBaDao`.  
**Nhánh mới:** `feature/map-d2-direct-chatgpt-visual-upgrade-20261025`.  
**Nền:** PR #32 `c6bde70f6e98f482c91cd6d2c386e58437877209`; không sửa PR #31/#32, không merge.

## 1. Đã CODE — không chỉ lập kế hoạch

- **Ba SVG minh họa worksite nguyên gốc, tự tạo để thử nghiệm**, trong `godot/art/map_d2_candidate/`: `mine_worksite_v1.svg`, `linh_forest_worksite_v1.svg`, `spirit_field_worksite_v1.svg`. Có cửa hầm/khung gỗ, bãi gỗ/cây, thửa ruộng/cây trồng. **CHƯA PHẢI asset Source A, CHƯA duyệt, KHÔNG phải animation sản xuất hay công trình gameplay mới.**
- Cập nhật `godot/src/presentation/p3/sect_isometric_world_v1.gd`: nạp SVG ứng viên dưới dạng view-only Texture2D với fallback về marker cũ nếu import thất bại; chỉ vẽ khi `managed` lấy từ **BuildingState thực**. Không sửa ID, lệnh vào panel, khung thời gian/sản lượng hoặc save; không đưa SVG ứng viên vào `SectMap25SourceArt`.
- Tạo `godot/src/presentation/p3/sect_map_d2_landscape.gd`: tính palette vùng chức năng và ground màu biến thiên chậm, không còn tile xanh checkerboard lặp thô; lớp phụ cảnh quan `pond/reeds/flowers/stone` tự vẽ. Phần cảnh quan này là **S4 candidate trang trí**, không định nghĩa địa hình có collision, vùng unlock, quái/nước gameplay hoặc sản lượng mới. Giữ nguyên camera/chunk/AStar preview và đường thật SHA-gated từ bộ gốc.
- Viền đường màu đất mờ giúp chuyển giữa đá Source A và nền, giữ 6 ảnh đường đã xác minh, vẫn dùng chunk mesh cũ.
- Test mới `godot/tests/presentation/sect_map_d2_visual_contract_test.gd`: scene P3.2 thật, Source A view-status, 3 SVG Texture2D, nguồn file tách khỏi MAP25, đủ 9 tuyến đường, palette khác biệt, managed instance trùng state, render không làm thay đổi canonical SimulationState.
- Tài liệu provenance `godot/art/map_d2_candidate/README.md` ghi candidate/owner review cần thiết, không giả mạo nguồn từng được duyệt.

## 2. Chưa làm hoặc không thể chứng minh tại phiên này

- **Chưa có Godot engine executable trong môi trường chạy ChatGPT**, không chạy parse/import/GDScript tests/Godot GUI capture/benchmark. Kiểm tra source là kiểm tra cấu trúc tĩnh, **KHÔNG được gọi PASS**.
- Google Drive metadata search theo `Source A`, `TMB_SOURCEA`, `sourcea` và `510052` không tìm được exact Source A building master đáng tin từ tên. Không kết luận toàn bộ Drive/các ZIP local đã vắng source; cần kiểm kê có căn cứ ở một runtime/trình truy cập đầy đủ.
- **Không phục hồi đủ 8 building family đã được duyệt**; ba SVG thử nghiệm không thay cho building master lịch sử; vật liệu ao/hoa là đồ họa gợi ý, chưa chuẩn Source A. Không thay `docs/P3_ASSET_REGISTRY.json` hoặc `godot/data/presentation/map25_source_a_verified.json`.
- Chưa biết SVG có thực sự import/hiển thị đúng Godot 4.7.2 trên Windows hay không; chưa kiểm được vị trí crop/hitbox/actor overlap.
- 29/29 test & 56 S1 edge checks là **KẾT QUẢ CŨ PR32**, không phải kết quả trên MAP-D2 branch. Không tái sử dụng các số ấy để tuyên bố QA MAP-D2.
- Chưa có ZIP Windows MAP-D2; PR32 ZIP cũng không tự biến thành MAP-D2.
- Chưa có Owner visual approval/Windows manual/Android physical/FULL.

## 3. Bắt buộc QA trước khi xem là một bản chạy được

1. Fetch nhánh mới và đảm bảo HEAD, worktree sạch; **không reset máy/worktree hiện tại**. Đọc AGENTS.md/Art Bible/source art review.
2. Dùng official Godot `4.7.2.stable.official.ed1daf0bf`. Chạy import/parse của project Godot trong userdata profile cách ly (Windows máy 8GB chỉ một Godot process). Kiểm tra ba SVG nhận Texture2D và ảnh thực tế alpha/scale.
3. Chạy test mới `res://tests/presentation/sect_map_d2_visual_contract_test.gd`, `sect_iso_main_integration_test.gd`, `sect_map_d1b_layout_contract_test.gd`, `sect_map25_verified_art_gate_test.gd`, map camera và O9. Mọi log ghi exact commit/tree, engine, exit, marker, tài nguyên thiếu.
4. Chạy lại **full deduplicated 29 scoped PR32 tests** cộng test D2 mới = tối thiểu **30 test paths** nếu tất cả tồn tại, cùng Combat S1 56 edge checks, trên *cùng code/tree*. Nếu fail, không giảm asserts.
5. Chụp scene P3.2 thực ở 1280×720 (default, Site Mỏ/Lâm/Điền, zoom, focus, Kho, mẻ sản xuất), so sánh PR32 before/after, nhân vật, texture, labels. Nếu candidate SVG lệch phong cách, báo owner Visual PENDING, **không ép lên map chính**.
6. Đo frame-time p95/p99 và Working Set cùng phương pháp PR32 vì thêm texture/layer; không suy ra FPS từ ảnh tĩnh.
7. Đóng gói portable Windows chỉ sau khi import và focused PASS; tuyệt đối không ghi là standalone EXE nếu thiếu export templates.

## 4. Ranh giới không thay

`godot/src/simulation/**`, Combat V2/V3-S1, CARE, WarehouseSystem, SaveService, scheduler/production, Injury, D7, gameplay map world và luật kinh tế. Không thay Source A 32 PNG/manifest, scene/p3_2 runtime owner, camera authority. Không merge main hoặc PR #31/#32.

## 5. Trạng thái hiện tại

**DELIVERED:** nhánh code, 3 SVG trang trí sản xuất ứng viên, palette/cảnh quan/viền đường, wiring live presentation, test script và provenance.  
**NEED LOCAL GODOT:** import + 30-test QA + screenshot + performance.  
**NEED OWNER:** xem ảnh runtime trước khi duyệt asset và bản đồ.  
**Verdict:** `IMPLEMENTATION_PARTIAL_UNVERIFIED` — một bước code thực trên GitHub, không phải bản map hoàn tất.

**Lưu ý dài hạn:** Chất lượng thị giác thật còn phụ thuộc vào nguồn building/terrain/water trong Source A; những SVG này là thử nghiệm nhằm giảm marker sơ sài, không phải cách thay thế đủ toàn bộ art pipeline.
