# P3 — PRESENTATION MASTER / AUTHORITY INDEX

Date: 2026-10-03
Status: CANONICAL ROUTER FOR UI/UX + VISUAL ASSETS

## 0. Mục đích

File này là **điểm vào duy nhất** trước mọi việc liên quan UI/UX, mockup, map art, công trình, actor, icon, panel, VFX và asset presentation của P3.

Không dùng file này để chứa toàn bộ chi tiết từng hạng mục. File này chỉ:

1. chỉ đúng authority cần đọc;
2. ghi trạng thái asset đã duyệt/chưa duyệt;
3. khóa workflow tạo ảnh;
4. ngăn AI tự sáng tác lại một hạng mục đã có asset chuẩn.

Nếu một hạng mục đã có asset/canon được user duyệt, **asset/canon đó có quyền cao hơn prompt mới do AI tự nghĩ**.

---

# 1. Workflow bắt buộc trước mọi ảnh mới

Mọi lần generate/edit/mockup hình ảnh phải đi theo thứ tự:

1. đọc `P3_PRESENTATION_MASTER.md`;
2. đọc MD riêng của hạng mục đang làm;
3. kiểm tra asset/reference đã được user duyệt;
4. trình **PLAN bằng chữ cho user trước**;
5. plan phải nêu: mục tiêu, bố cục, asset kế thừa, phần được thay đổi, phần bị khóa, tỷ lệ/kích thước, phong cách, điểm khác bản trước;
6. chỉ generate sau khi user duyệt plan;
7. sau khi user duyệt hình, cập nhật MD hạng mục để khóa quyết định mới.

**Không được generate ngay khi chưa có plan được user duyệt.**

---

# 2. Authority theo hạng mục

| Hạng mục | Authority chính | Trạng thái |
|---|---|---|
| Tổng thể P3/UI hierarchy | `P3_2_UI_ART_PRODUCTION_SPEC.md`, `P3_REFERENCE_UI_AUDIT.md` | Đã khóa structure |
| Main map UX | `P3_UX_MAIN_MAP.md` | Canon đang hoạt động |
| Công trình | `P3_ASSET_BUILDINGS.md` | Có bộ asset/style đã duyệt; không tự thiết kế lại |
| Map/terrain/environment | `P3_ASSET_MAP_ENVIRONMENT.md` | Đang production |
| Đệ tử map actor | `P3_2_MODULAR_ACTOR_SPEC.md`, `P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md` | female proof đang làm |
| Màn Đệ Tử | `P3_UX_DISCIPLE_SCREEN.md` | Structure đã khóa, visual polish tiếp tục |
| UI skin/icon | `P3_UI_SKIN_AND_ICONOGRAPHY.md` | Style canon mới |
| Asset manifest tổng | `P3_2_ASSET_MANIFEST.md` | Inventory/checklist; không thay authority chi tiết |
| Simulation/identity nhân vật | `DISCIPLE_MASTER_SCHEMA.md` | Gameplay authority |

Nếu có xung đột giữa một manifest cũ và MD hạng mục mới hơn, **MD hạng mục mới hơn thắng ở presentation**, miễn không vi phạm gameplay authority.

---

# 3. Visual direction tổng đã chốt

Game là **mobile landscape 1280×720**.

Cảm giác tổng:

- game quản lý tông môn sống;
- map là trung tâm, không phải dashboard;
- tiên hiệp 2D vẽ tay;
- isometric/top-down nhẹ;
- pastel/thủy mặc nhưng nét rõ;
- xanh xám/ngọc trầm + giấy ngà + gỗ nâu đỏ + vàng đồng;
- hình khối gọn, hơi cute nhưng không trẻ con/quá chibi;
- có độ cũ, có khí chất, không palace-fantasy quá hoành tráng;
- NPC nhỏ liên tục đi lại/làm việc;
- UI parchment/ink/wood/jade, không SaaS hiện đại.

User ngày 2026-10-03 thích visual asset của mockup V3 hơn các mockup trước. Hướng đó được dùng làm **UI/map mood reference**, nhưng không được dùng để thay thế asset công trình đã duyệt.

---

# 4. Quy tắc tái sử dụng asset đã duyệt

Khi dựng mockup tổng hợp:

- công trình phải lấy từ family/style công trình đã duyệt;
- actor phải lấy từ character canon/approved actor family;
- terrain phải lấy từ terrain/path/environment canon;
- UI phải lấy từ skin canon;
- không để image model tự đổi kiến trúc/camera/palette của một nhóm chỉ vì đang dựng mockup mới.

Mockup là **composition test**, không phải cơ hội redesign asset đã khóa.

Nếu binary asset chưa nằm trong GitHub, MD hạng mục vẫn phải ghi rõ asset đó tồn tại và là reference bắt buộc. Khi generate ảnh mới, phải dùng reference image/source asset trực tiếp nếu công cụ cho phép.

---

# 5. Main-map UX hierarchy

Canonical interaction order:

`map -> edge HUD -> actionable bubble -> compact quick panel -> deep overlay/page`

Map phải giữ cảm giác chiếm khoảng 85–90% thị giác khi không có deep overlay.

Không dùng:

- fixed sidebar lớn thường trực;
- panel đệ tử chiếm nửa màn hình ở trạng thái map bình thường;
- label tên trên mọi công trình mọi lúc;
- quá nhiều icon/menu thường trực;
- text dày trên NPC.

---

# 6. Binary asset policy

GitHub connector phù hợp cho text/code/manifest, **không dùng làm đường vận chuyển binary production chính** nếu có nguy cơ hỏng dữ liệu.

PNG/ZIP production hoặc diagnostic:

- gửi file trực tiếp cho user khi cần;
- GitHub giữ manifest, checksum, code, naming contract, installer/test;
- chỉ commit binary khi có đường upload binary đáng tin cậy.

---

# 7. Khi hoàn thành/duyệt một hạng mục

MD hạng mục phải cập nhật tối thiểu:

- `Status`;
- approved visual references;
- locked style;
- dimensions/registration nếu có;
- asset IDs đã có;
- asset IDs còn thiếu;
- điều cấm thay đổi;
- next production step.

Không dựa vào trí nhớ chat khi repo đã có authority tương ứng.
