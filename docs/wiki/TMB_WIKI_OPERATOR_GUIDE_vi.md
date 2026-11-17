# Tàng Kinh Các — hướng dẫn vận hành nội bộ

## Mục đích và quyền riêng tư

Tàng Kinh Các là công cụ quản trị thiết kế **chỉ dành cho chủ dự án**. Nó không phải wiki public và không có bước publish/deploy. Launcher chỉ bind loopback `127.0.0.1`, dùng port 8766 hoặc port trống tiếp theo đến 8781; không mở giao diện ra LAN/public. Browser cũng từ chối hostname không phải loopback.

Ghi chú, đề xuất và Change Request được lưu ở `localStorage` trong profile trình duyệt hiện tại. Chúng không nằm trong `wiki/data/catalog.json`, không được source sync ghi đè và không được commit tự động. Nếu cần chuyển máy, dùng nút xuất JSON; file export do người dùng tự giữ ở nơi riêng.

## Mở Wiki

1. Mở checkout nội bộ PR #72 trên Windows.
2. Nhấp đúp `tools/wiki/OPEN_TANG_KINH_CAC.cmd`.
3. Cửa sổ Python giữ local server hoạt động; đóng cửa sổ đó để dừng.
4. Nếu port 8766 đang được dùng, launcher thử bind loopback tiếp theo trong dải 8766–8781 rồi mở URL đã in; nó không kết nối vào process có sẵn.

Python 3 là dependency duy nhất ngoài browser có sẵn. Không có framework, package manager hay external font/CDN.

## Tìm cứu và lọc

- Tìm toàn bộ catalog từ thanh trên cùng; `Ctrl+K` đưa focus vào ô tìm kiếm.
- Mở danh mục để lọc theo môn phái, trạng thái hoặc chuỗi ID/tên.
- Bấm dòng để xem chi tiết. Traceability hiển thị source path, SHA-256, version, runtime status và trạng thái/link QA.
- Mọi bản ghi chưa có QA theo ID vẫn mang `NOT_LINKED`, `PENDING` hoặc `UNKNOWN`.

## Dashboard và Gap Analysis

Dashboard tách số liệu thiết kế, code/registry, gate, test source, kết quả test và phê duyệt. Một file test có mặt **không** đồng nghĩa test PASS. Một entry trong manifest presentation **không** đồng nghĩa có artwork đã duyệt.

Gap Analysis liệt kê chênh lệch đã đối chiếu từ nguồn. Cặp kỹ năng tương tự chỉ là heuristic review, không được gọi trùng/lỗi nếu chưa có bằng chứng và quyết định thiết kế.

## Đề xuất và Change Request

1. Chọn record → `Đề xuất thay đổi`, hoặc mở `Design Editor`.
2. Nhập ID, field path, giá trị đề xuất, ghi chú và lý do.
3. Xem so sánh trước/sau; lưu vào local profile.
4. Tạo CR kèm giá trị hiện tại/đề xuất, priority, acceptance criteria và trạng thái.

- Design Editor có nút Xuất bản sao JSON / Nhập JSON cho đề xuất; Change Request Manager có nút riêng cho CR. File schemaVersion 1 được nhập theo kiểu gộp theo localId; bản ghi trùng ID hiện có được giữ nguyên.
- Wiki kiểm tra toàn bộ gói trước khi ghi localStorage. Nếu JSON sai hoặc lưu thất bại, dữ liệu trước đó được khôi phục khi trình duyệt cho phép.

Các trạng thái phê duyệt trong UI chỉ là quản trị nội bộ; chúng không tự cấp quyền code. Thay đổi nguồn game vẫn cần yêu cầu/ủy quyền riêng, packet phạm vi và QA đúng hệ thống.

## Đồng bộ nguồn một chiều

Nhấp đúp `tools/wiki/OPEN_TANG_KINH_CAC.cmd`; launcher chạy source sync trước khi mở server. Nếu cần chủ động đồng bộ riêng, chạy `tools/wiki/SYNC_WIKI_SOURCE.cmd` hoặc:

```powershell
python tools/wiki/build_wiki_catalog.py --write
python tools/wiki/build_skill_progress_v2.py --write
```

Script chỉ cập nhật `wiki/data/catalog.json` và file kiểm kê này. Kiểm tra stale projection bằng:

```powershell
python tools/wiki/build_wiki_catalog.py --check
python -m unittest discover -s tools/wiki/tests -v
```

Không có chức năng ghi ngược từ Wiki vào `godot/`. Không chép localStorage vào repo public.

## Cách hiểu trạng thái

- `SPEC_ONLY` / `DESIGN_ONLY`: thiết kế hoặc tài liệu, không phải runtime.
- `GATED_OFF`: có code/dữ liệu nhưng feature gate đóng.
- `CODE_PRESENT_*`: source code hiện diện; chưa tự chứng minh production release hoặc QA PASS.
- `NOT_LINKED`: chưa tìm thấy liên kết bằng chứng theo item ID.
- `PENDING` / `UNKNOWN`: chưa đủ nguồn để kết luận.
- `TECH_PASS` không tương đương `ART_APPROVED`.

## Phạm vi snapshot hiện tại

Source audit ở [TMB_WIKI_SOURCE_AUDIT.md](TMB_WIKI_SOURCE_AUDIT.md) nêu count và gap tại source snapshot. Wiki không đọc save, tài khoản, dữ liệu người chơi hay thư mục bên ngoài repo.

## Tiến độ toàn bộ kỹ năng — Wiki V2

1. Mở **Tiến độ skill V2** để duyệt 12 môn phái, 36 nhánh và từng skill ID. Có thể lọc theo môn phái, nhánh, trục trạng thái và tìm kiếm.
2. Bấm một skill để mở trang chi tiết. Trang tách riêng nguồn thiết kế, runtime, VFX ledger/packet, animation, test, GitHub Action và Owner Art. Link asset theo packet chỉ được gắn khi packet nêu đúng skill ID.
3. **V6.3 candidate** là nội dung thiết kế. V6.3 đang OFF nên candidate không được tính là gameplay đang chạy. Presentation metadata không phải asset.
4. **TECH_PASS_REPORTED** chỉ là trạng thái kỹ thuật được ghi nguồn; không chứng minh chất lượng mỹ thuật. **PROVISIONAL_NOT_FINAL** không phải Owner Art Approval cuối. Test source có ID chỉ là liên kết mã, chưa chứng minh test chạy.
5. Manifest animation Nữ Độc Tu cho biết các atlas cấp nhân vật, frame count, pivot và SHA khai báo. V2 không suy ra chiêu nào dùng clip nào khi không có mapping. SHA của ảnh lấy từ manifest và được ghi rõ là chưa rehash trong quá trình Wiki build.
6. **Việc cần xử lý** gom các thiếu hụt bằng chứng và chép nguyên 10 gap của V1. Gate V6.3 OFF là trạng thái chủ động, không tự biến thành đề xuất bật gameplay. Gap 3/10 slot thiết bị tiếp tục chờ Owner quyết định.
7. Trong Design Editor hoặc Change Request Manager, bấm **Backup toàn bộ JSON · v2** để tải snapshot local. **Restore hợp nhất** chỉ thêm localId mới; bản ghi cùng ID hiện có được giữ, file sai schema hoặc trùng localId sẽ bị từ chối. Schema V1 cũ vẫn được nhập.
8. Source sync chạy tools/wiki/SYNC_WIKI_SOURCE.cmd; lệnh gọi hai builder tuần tự và chỉ cập nhật projection/report đã sinh. Nó không ghi ngược đề xuất vào nguồn gameplay.

### Trục coverage

- **Thiết kế:** candidate metadata trong catalog V1.
- **Runtime:** status registry/feature gate; V6.3 vẫn GATED_OFF.
- **VFX:** trạng thái raw từ 12 ledger, packet exact-skill nếu có, asset/scene path và availability.
- **Animation:** UNKNOWN per skill khi chưa có mapping; manifest cấp actor được hiển thị riêng.
- **Technical QA:** Action exact-SHA nếu có; còn lại có test source chỉ ghi NOT_EXECUTED.
- **Owner Art:** raw gate được giữ nguyên và phân loại APPROVED / PROVISIONAL / PENDING, không suy ra từ TECH_PASS.

Coverage được sinh tại wiki/data/skill_progress_v2_coverage.md khi source sync chạy; evidence GitHub được đóng gói trong docs/wiki/TMB_WIKI_V2_GITHUB_EVIDENCE_20261117.json. Trang vẫn chỉ bind localhost và không có bước deploy.
