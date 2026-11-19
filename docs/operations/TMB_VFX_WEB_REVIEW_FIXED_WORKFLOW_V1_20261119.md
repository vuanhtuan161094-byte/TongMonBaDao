# TÔNG MÔN BÁ ĐẠO — WEB VFX REVIEW · QUY TRÌNH CỐ ĐỊNH V1

**OWNER LOCK (19/11/2026):** Một địa chỉ `/vfx/` cho toàn bộ 12 phái / 36 nhánh, trên **cùng Pages site** với `/play/` và `/wiki/`. Đây là **một bước review cố định**, không phải SOP mỹ thuật mới: **Art-First V4 vẫn là nguồn chuẩn và mọi gate G0–G8 giữ nguyên**. Không có 12 web riêng, không xuất MP4 thường xuyên, không rig, không Codex Cloud, không sửa gameplay/Save, G8/PvE HOLD, không merge.

## 1. Input của mỗi skill (không tạo checklist dài)

- `skill_id` chính xác từ canonical ledger, school/branch/tier, tên, cơ chế/hình chiêu, dạng mục tiêu.
- **Master RGBA G3 thật** cùng 3–5 pose chức năng (charge / peak / release / contact / dissipate); VFX là ánh sáng sống, không crop poster, không vector giả thay tranh. Tại 1× phải nhận diện được nhánh/phái và không che mất actor.
- Một LAB scene/binding read-only theo `tmb.vfx_bindings.v1`: anchor theo frame/sự kiện; source actor do nhóm Asset cấp; nguồn tách biệt và bất biến.
- Đăng ký candidate thật vào `docs/operations/vfx_web_catalog_v1.json` với scene, source files, mức duyệt và hướng **thực có**. Không thêm các phái/hướng bằng UI giả để đủ 12/36.

## 2. Một reviewer, một kiểu điều khiển

Trên web `/vfx/`: chọn **skill đã có source**, xem scene 1280×720, click **Thử lại**, **Pause**, **quái di chuyển**, **bật/tắt VFX**, **nền sáng/tối**, **1×/2×**, **0.25×–2×**, lựa chọn hướng **chỉ khi source 4 hướng thật có**. Chạy theo đúng Combat V2 semantic (hoặc ghi rõ LAB synthetic), không gán damage/kill/status bằng VFX.

## 3. Luồng ít QA nhưng không được bỏ kiểm tra thực

1. **G0–G3 Art-First V4:** kiểm source 1× trước; G3 FAIL thì dừng, không build web/native. Lần đầu AS48 là `TECH_CUE_ONLY` để kiểm bridge, không nâng lên `G3_PASS`.
2. **Web staging/parse:** chỉ đưa byte nguồn thật cần test vào gói Godot Web nhỏ, tự kiểm file/skill/anchor, không tạo game 2.
3. **Web browser pixel gate:** dùng Chromium tải trang xuất thực (HTML/JS/WASM/PCK); chụp canvas và kiểm **có pixel nhân vật + quái**. Ảnh 19/11 thấy 2 vùng rỗng, nên **WebGL build/logic PASS ≠ browser visual PASS**. Trượt gate = không deploy bản mới; lưu 1 PNG bằng chứng thay vì MP4.
4. **Owner review trực tiếp:** đẹp, mượt, đúng skill/nhánh, va chạm đúng quái WALK, không che thân, sáng/tối, 1×. Owner nói đạt thì ghi revision cụ thể, không tự suy approved.
5. **Godot native G3.5 / G7 exact SHA:** vẫn giữ như V4 nhưng chạy tập trung khi source G3 đủ hoặc có khác biệt browser; không lặp MP4 sau mỗi chỉnh sửa nhỏ. Native proof không bị web thay thế.

## 4. Cách thêm skill tiếp theo

- VFX producer sản xuất RGBA riêng trong thư mục phái, thêm LAB scene dùng review_* contract.
- Thêm **một entry** vào catalog với ID canonical, status, directions thực, scene và các `source_paths` liên quan; không phải sửa root Godot/project main/gameplay.
- `tools/vfx/stage_vfx_web_review.py` dựng project tạm CI (không commit game copy), chung GitHub Pages workflow xuất `/vfx/`.
- Nếu cảnh mới làm mất nhân vật/quái Web, browser gate FAIL tự chặn publish; xử lý ở adapter/LAB, không sửa asset đã duyệt.

## 5. Bản đầu/giới hạn thành thật

AS48 Kiếm Tu nam, Ngự Kiếm, Phi Kiếm Truy Ảnh Nhân: FRONT 4 cels + sword + quái thật; G3 SOURCE_PENDING, TECH_CUE_ONLY, actor owner pending. 4 hướng không tự mirror. Ảnh owner báo **actor và monster hoàn toàn không thấy**; fix được xem là đạt **chỉ khi Chromium screenshot có pixels ngoài nền** và owner mở lại trang xác nhận. Người làm sau phải đọc SOP này và Art-First V4, không mở SOP cạnh tranh.

**Bàn giao:** exact SHA, Web build, Browser Pixel Gate, G3_ART, G3.5_NATIVE, OWNER_ART, PVE_HOLD; chỉ một dòng ngắn/skill. Lỗi hiển thị là blocker, không được báo hoàn tất chỉ vì workflow export xanh.
