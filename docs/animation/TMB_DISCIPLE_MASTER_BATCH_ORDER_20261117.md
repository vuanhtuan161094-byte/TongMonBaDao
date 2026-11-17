# TMB — Master Batch Production Order cho asset đệ tử — 2026-11-17

**Mục tiêu:** sản xuất asset nhìn ra ngay trường phái và mở rộng family được mà không clone.  
**Status:** thứ tự kiểm chứng đề xuất, chưa owner duyệt. Không thay đổi runtime/gameplay.

## Lô master

1. **Kiếm Tu** — có owner-liked identity/weapon direction cụ thể; validate tóc/ấn/kiếm và giới hạn nguồn tham chiếu.
2. **Cung Tu** — kiểm tra bow readability, đường cong và grip nhỏ.
3. **Đao Tu** — so lưỡi rộng/khối nặng với jian thẳng.
4. **Song Đao** — kiểm tra đọc đúng hai item độc lập, không giống clone Kiếm.
5. **Thương Tu** — kiểm tra vũ khí dài, canvas, grip và occlusion.
6. **Phù Tu** — giấy/bút cần đọc tốt mà không dựa vào chữ sai.
7. **Trận Tu** — phân biệt pháp cụ la bàn/thẻ neo với Phù.
8. **Độc Tu** — giữ nguyên identity Nữ Độc Tu đã khóa; chỉ thêm item concept tách biệt sau review.
9. **Quyền Tu** — kiểm tra silhouette nắm tay và bảo hộ mềm.
10. **Chưởng Tu** — kiểm tra bàn tay mở và tay áo; không dựa palette để phân biệt.
11. **Chú Tu** — kiểm tra mouth/seal/chuỗi đồng khác Phù.
12. **Triệu Hồi** — khó giữ khoảng trống mà không tự vẽ companion; làm cuối để stress-test.

Đây là thứ tự giảm rủi ro lẫn shape, không biểu thị sức mạnh, unlock, kinh tế, cấp độ hay mức độ ưu tiên gameplay. Sau master của mỗi phái phải review ở 1×/zoom in trước khi mở rộng family. Mọi đệ tử khác trong phái biến thể mặt/tóc/dáng/ornament, nhưng giữ đúng DNA; không nhân bản một body rồi đổi màu.

## Gate qua master sang batch

- **M0 — nguồn:** tên trường phái/nhánh đúng catalogue; owner-locked art immutable; prompt/source/hashes giữ nguyên.
- **M1 — silhouette:** view thu nhỏ 60–75 px, nền sáng/tối, nhận diện không cần label.
- **M2 — item:** vũ khí/đạo cụ đọc đúng loại; tay cầm, guard, grip và tỷ lệ rõ.
- **M3 — continuity:** face/hair/costume/weapon giữ cùng identity ở 4 góc; right/left không flip mù.
- **M4 — game asset:** source layer thật, 256×400/128×128 export phù hợp spec, foot pivot ổn định, alpha clean, không cắt vũ khí; hi-res source tối thiểu ~320px body nếu áp dụng Kiếm Tu.
- **M5 — motion:** storyboard, key pose thật cho Idle/Walk/Cast/Attack/Hit/Death; không rig, không skeletal, không whole-image wobble.
- **M6 — Godot:** official 4.7.2 import, isolated lab screenshot 1280×720 và engine playback; không production integration cho đến owner art gate.

## Tách trạng thái

DESIGN_CANDIDATE → MASTER_CANDIDATE → OWNER_ART_APPROVED → SOURCE_LAYER_VERIFIED → ENGINE_TESTED → ANIMATION_APPROVED → PRODUCTION_INTEGRATED.

Không nhảy trạng thái; PASS validator không thay cho review mỹ thuật. Với lô 2026-11-17, mọi ảnh mới là MASTER_CANDIDATE, ảnh Nữ Độc Tu hiện hữu giữ OWNER_LOCKED_REFERENCE; chưa có sprite animation hay Godot engine QA.
