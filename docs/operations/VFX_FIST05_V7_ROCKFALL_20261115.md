# FIST05 V7 — Địa Mạch Liên Chấn: sửa đất đá cuối (15/11/2026)

## Lý do rework
Owner chỉ ra V6 vẫn chưa đạt ở **đất đá cuối**. Xem native Godot các mốc 1.55, 1.93, 2.40: nguyên tảng đá lửa dừng ở tư thế đứng, chỉ giảm alpha tới biến mất. Đó là decal fade chứ chưa có cảm giác vật liệu nặng rơi xuống.

## V7 art patch — KHÔNG đổi hiệu ứng đã ổn
- Giữ pha tụ khí 0–0.45, một vết nứt 0.45–1.01, contact 3 mục tiêu và contract damage / fire / circle radius 3 / cap 3 / cast 0.45.
- Cùng một master đá original được tách thành **6 mảng đá bất quy tắc** trong frame atlas, mỗi mảng có góc xoay, vận tốc ngang, lực đẩy và trọng lực khác nhau; đá bị vỡ vật lý ngay cuối pha trồi và **rơi xuống**, không còn cột đá nguyên khối fade.
- Bụi trầm màu đất, bám sát chân đá, tàn sáng nhỏ và mảnh đá vụn có chuyển động riêng. Không bổ sung vòng tròn neon, không làm biến mất enemy.
- **Kích thước texture giữ nguyên:** 16 frame CORE 1024×1024, 8 frame CONTACT 1024×512, fissure 1024×256 → 7,340,032 byte = 7.00 MiB RGBA uncompressed. **24 frame**, ba texture, 0 draw call bổ sung trong Godot scene. V7 thay **nội dung pose** chứ không nhân bản node/atlas.
- Video 1280×720 xuất bằng fixed clock không phải phép đo FPS Android. Stress 1/6/12/30 trên Ubuntu/Xvfb chỉ so sánh cùng máy, không xác nhận gameplay trên máy thật.

## Checklist art
Đánh giá tại 1.28 (đá dâng), 1.55 (đỉnh), **1.93 (vỡ mảng), 2.12 (rơi), 2.40 (bụi lắng), 2.83 (trống)**; thấy rõ 3 mục tiêu và không có hộp alpha. Cần xem MP4 native, so với V6; chưa xin owner phê duyệt nếu chưa kiểm chứng exact SHA.

## Giới hạn
Chỉ sửa `tools/vfx/generate_fist05_v3_optimized.py`, nhãn revision Godot/LAB test, workflow gate và hồ sơ FIST05. Không rig, không Codex, branch, merge, không Combat V2 / SaveService / economy / live PvE / V6.3, không đổi các skill khác. **OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD**.
