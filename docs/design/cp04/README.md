# CP-04 — Công Pháp & Kỹ Năng (Visual-first)

**Owner đã duyệt bố cục:** 2026-10-31, CP-04 phương án A.

Đây là **gói thiết kế HTML offline**, không phải chức năng đã triển khai trong Godot. Đồ họa chưa gắn Source A/VFX thật, media slot vẫn là placeholder để nhận PNG/APNG/WebP/GIF sau này.

## Các thành phần lưu trong GitHub
- **[HTML tương tác](./TMB_CP04_CongPhap_KyNang_VisualSlots_Offline.html)** — bản đã duyệt, mở offline sau khi tải; nút demo không sửa Save.
- **[Đặc tả UI/UX](./CP04_UIUX_SPEC.md)** — 4 màn Công Pháp/Kỹ Năng/Tiến Hóa/Nghiên Tu, bố cục visual-first và luật backend.
- **[QA HTML](./CP04_Design_QA.md)** — kết quả và giới hạn kiểm tra Chromium ở 4 kích cỡ.
- **[8 ảnh Chromium](./screenshots/)** — ảnh màn thật tại 1280×720 và 915×412.
- **[Danh mục SHA-256](./SCREENSHOT_MANIFEST.md)** — chứng thực tệp.

## Handoff rule
Không sửa `main`, nhánh `integration/one-game-v65-20261030`, PR #52 hoặc file `godot/**` khi thực hiện checkpoint này; không tự ý tạo việc mới cho Codex. Đề xuất thực thi có thể bắt đầu sau khi tích hợp ONE GAME được ổn định và owner yêu cầu.

**Phần tiếp theo được đề xuất:** CP-05 thử gắn asset/VFX đã có nguồn hợp lệ vào các ô PNG và animation preview trong bản sao HTML độc lập, **không sửa Godot**; hoặc khóa thiết kế trước rồi quay về Kho/Trang Bị.
