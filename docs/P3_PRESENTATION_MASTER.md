# P3 — PRESENTATION MASTER / AUTHORITY INDEX

Date: 2026-10-03
Status: CANONICAL ROUTER FOR UI/UX + VISUAL ASSETS

## 0. Mục đích

File này là **điểm vào duy nhất** trước mọi việc liên quan UI/UX, mockup, map art, công trình, actor, icon, panel, VFX và asset presentation của P3.

Không dùng file này để chứa toàn bộ chi tiết từng hạng mục. File này chỉ:

1. chỉ đúng authority cần đọc;
2. ghi trạng thái asset đã duyệt/chưa duyệt;
3. khóa workflow tạo ảnh;
4. ngăn AI tự sáng tác lại một hạng mục đã có asset chuẩn;
5. chỉ tới machine-readable asset registry, source-recovery inventory và decision history.

Nếu một hạng mục đã có asset/canon được user duyệt, **asset/canon đó có quyền cao hơn prompt mới do AI tự nghĩ**.

---

# 1. Workflow bắt buộc trước mọi ảnh mới

Mọi lần generate/edit/mockup hình ảnh phải đi theo thứ tự:

1. đọc `P3_PRESENTATION_MASTER.md`;
2. đọc `P3_ART_BIBLE.md`;
3. đọc MD riêng của hạng mục đang làm;
4. kiểm tra `P3_ASSET_REGISTRY.json`;
5. kiểm tra `P3_SOURCE_RECOVERY_MANIFEST.md` để biết exact source có thực sự tồn tại/recover được hay không;
6. kiểm tra asset/reference đã được user duyệt;
7. trình **PLAN bằng chữ cho user trước**;
8. plan phải nêu: mục tiêu, bố cục, asset kế thừa, source nào đang dùng, phần được thay đổi, phần bị khóa, tỷ lệ/kích thước, phong cách, điểm khác bản trước;
9. chỉ generate sau khi user duyệt plan;
10. sau khi user duyệt hình, cập nhật MD hạng mục + registry + recovery manifest khi source state thay đổi.

**Không được generate ngay khi chưa có plan được user duyệt.**

Nếu quyết định làm thay đổi architecture/pipeline lâu dài, tạo ADR mới trong `docs/decisions/` thay vì chỉ sửa mất lịch sử trong spec hiện tại.

---

# 2. Authority theo hạng mục

| Hạng mục | Authority chính | Trạng thái |
|---|---|---|
| Visual cross-cutting | `P3_ART_BIBLE.md` | Canonical |
| Asset/status index | `P3_ASSET_REGISTRY.json` | Machine-readable canonical registry |
| Source availability / recovery | `P3_SOURCE_RECOVERY_MANIFEST.md` | Canonical source inventory |
| Tổng thể P3/UI hierarchy | `P3_2_UI_ART_PRODUCTION_SPEC.md`, `P3_REFERENCE_UI_AUDIT.md` | Đã khóa structure |
| Main map UX | `P3_UX_MAIN_MAP.md` | Canon đang hoạt động |
| Công trình | `P3_ASSET_BUILDINGS.md` | Visual family approved; exact source bytes cần phục hồi |
| Map/terrain/environment | `P3_ASSET_MAP_ENVIRONMENT.md` | Design contract locked; source availability mixed |
| Đệ tử map actor | `P3_2_MODULAR_ACTOR_SPEC.md`, `P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md` | female proof đang làm |
| Màn Đệ Tử | `P3_UX_DISCIPLE_SCREEN.md` | Structure đã khóa, visual polish tiếp tục |
| UI skin/icon | `P3_UI_SKIN_AND_ICONOGRAPHY.md` | Style canon locked; runtime asset family pending |
| Asset manifest kỹ thuật cũ | `P3_2_ASSET_MANIFEST.md` | Inventory/checklist; không thay registry/authority mới |
| Decision history | `docs/decisions/` | Append-only rationale for major decisions |
| Simulation/identity nhân vật | `DISCIPLE_MASTER_SCHEMA.md` | Gameplay authority |

Nếu có xung đột giữa một manifest cũ và MD hạng mục mới hơn, **MD hạng mục mới hơn thắng ở presentation**, miễn không vi phạm gameplay authority.

Registry không chứa art spec chi tiết; nó chỉ trả lời: `asset nào / authority nào / source status nào / visual đã duyệt chưa / runtime đã xanh chưa`.

Recovery manifest trả lời thêm: `exact bytes có thực sự tìm lại được không / evidence class nào / cần phục hồi hay sản xuất mới`.

---

# 3. Source evidence classes

Canonical source evidence model:

- `S0` — repo canonical exact source;
- `S1` — exact external pack/file có checksum đủ xác minh;
- `S2` — exact persistent external file có locator bền vững;
- `S3` — historical approved identity nhưng exact bytes hiện chưa recover;
- `S4` — design only / production source chưa tồn tại.

Luật quan trọng:

- `visual approved + S3` nghĩa là **thiết kế/hình đã được user duyệt nhưng source file đang thất lạc**, không được generate lại rồi coi bản mới là source cũ;
- `S4` nghĩa là được phép sản xuất mới sau plan vì chưa có approved exact source cần bảo tồn;
- chỉ `S0/S1/S2` mới chứng minh được exact source/file bytes hiện có.

Chi tiết recovery priority xem `P3_SOURCE_RECOVERY_MANIFEST.md`.

---

# 4. Visual direction tổng đã chốt

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

Chi tiết cross-cutting phải đọc `P3_ART_BIBLE.md` thay vì lặp lại toàn bộ vào từng hạng mục.

User ngày 2026-10-03 thích visual asset của mockup V3 hơn các mockup trước. Hướng đó được dùng làm **UI/map mood reference**, nhưng không được dùng để thay thế asset công trình đã duyệt.

---

# 5. Quy tắc tái sử dụng asset đã duyệt

Khi dựng mockup tổng hợp:

- công trình phải lấy từ family/style công trình đã duyệt;
- actor phải lấy từ character canon/approved actor family;
- terrain phải lấy từ terrain/path/environment canon;
- UI phải lấy từ skin canon;
- không để image model tự đổi kiến trúc/camera/palette của một nhóm chỉ vì đang dựng mockup mới.

Mockup là **composition test**, không phải cơ hội redesign asset đã khóa.

Nếu registry/recovery manifest ghi `S3`:

- cố phục hồi source cũ trước;
- nếu chưa phục hồi được, giữ silhouette/identity bằng placeholder hoặc mô tả authority;
- không generate một lookalike mới rồi gắn nhãn “approved source cũ”.

Nếu ghi `S4`, có thể production mới sau plan + user approval.

---

# 6. Asset registry — nguồn trạng thái chuẩn

`docs/P3_ASSET_REGISTRY.json` là source machine-readable cho trạng thái presentation asset.

Không dùng một status duy nhất vì visual và runtime có thể tiến triển độc lập. Registry tách:

- `design_status`;
- `source_status`;
- `source_evidence_class`;
- `visual_status`;
- `runtime_status`.

Ví dụ hợp lệ:

- building đã được user duyệt nhưng exact source đang thất lạc: `visual=approved`, `source=missing`, `source_evidence_class=S3`, `runtime=not_integrated`;
- terrain mới chỉ có design contract: `design=approved`, `source=missing`, `source_evidence_class=S4`, `visual=pending`;
- Stage A diagnostic ZIP xác minh được: `source=external_pack`, `source_evidence_class=S1` + size + SHA-256.

`tools/validate_p3_presentation.py` kiểm registry/docs/source evidence tĩnh. **PASS của script này không phải Godot runtime PASS.**

---

# 7. Main-map UX hierarchy

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

# 8. Binary asset policy

GitHub connector phù hợp cho text/code/manifest, **không dùng làm đường vận chuyển binary production chính** nếu có nguy cơ hỏng dữ liệu.

Hiện tại:

- PNG/ZIP diagnostic có thể gửi trực tiếp cho user;
- GitHub giữ registry, recovery manifest, checksum, code, naming contract, installer/test;
- source-art durable workflow qua Git LFS đang ở trạng thái **proposed**, xem `docs/decisions/0002-adopt-git-lfs-for-production-art.md`;
- chưa bật LFS cho production art cho tới khi kiểm thật trên máy Windows.

Planned source master root: `source_art/`, nằm ngoài `godot/` để Godot không tự import file edit/master không cần thiết.

---

# 9. Decision history

Dùng ADR cho quyết định có hậu quả lâu dài, ví dụ:

- thay architecture actor;
- thay pipeline binary source;
- thay authority/read-order;
- thay target platform/resolution lớn.

Không dùng ADR cho:

- thêm hair variant;
- chỉnh một pivot;
- đổi text nhỏ;
- tuning visual thông thường.

Accepted ADR không rewrite lý do cũ. Nếu đổi hướng, tạo ADR mới supersede quyết định trước.

---

# 10. Khi hoàn thành/duyệt một hạng mục

MD hạng mục phải cập nhật tối thiểu:

- `Status`;
- approved visual references;
- locked style;
- dimensions/registration nếu có;
- asset IDs đã có;
- asset IDs còn thiếu;
- điều cấm thay đổi;
- next production step.

Registry phải cập nhật:

- visual/runtime/source status;
- source evidence class;
- approval/runtime evidence khi có;
- source/runtime path nếu đã được ingest vào repo;
- recovery action nếu source missing.

Recovery manifest phải cập nhật nếu exact source được tìm thấy, ingest, supersede hoặc xác nhận là production-pending.

Không dựa vào trí nhớ chat khi repo đã có authority tương ứng.

---

# 11. Static audit

CI/local static check:

```bash
python tools/validate_p3_presentation.py
```

Nó kiểm:

- JSON registry parse được;
- asset ID không trùng;
- status hợp lệ;
- authority MD tồn tại;
- source evidence class hợp lệ;
- `missing` source có recovery action;
- `external_pack` có filename + size + SHA-256 và phải là S1;
- `repo_source` phải là S0 và path tồn tại;
- visual approved có approval evidence;
- runtime green có runtime evidence;
- repo-managed runtime path tồn tại;
- Master trỏ đủ Art Bible + registry + recovery manifest + domain authorities.

Không được dùng static audit này để thay thế FAST/FULL Godot gate.
