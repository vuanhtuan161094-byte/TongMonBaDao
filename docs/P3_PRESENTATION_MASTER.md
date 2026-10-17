# P3 — PRESENTATION MASTER / AUTHORITY INDEX

Date: 2026-10-04
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
| V3 core UX flow | `P3_UX_FLOW_V3.md` | V3.1 -> V3.2 right panel -> V3.3 deep screen USER APPROVED |
| P3.3 disciple operational implementation | `P3_3_DISCIPLE_OPERATIONAL_FLOW_SPEC.md` | Implemented on main; real Godot gate pending |
| P3.4 building management | `P3_4_BUILDING_MANAGEMENT_SPEC.md` | REAL PASS / locked |
| P3.5 living sect cues | `P3_5_LIVING_SECT_CUES_SPEC.md` | REAL PASS / locked |
| P3.6 Sect Master gameplay loop | `P3_6_SECT_MASTER_GAMEPLAY_LOOP_SPEC.md` | Real gameplay-loop playtest pending |
| Main map UX | `P3_UX_MAIN_MAP.md` | V3.1/V3.2 locked |
| Building interaction UX | `P3_UX_BUILDING_INTERACTION.md` | Building right-panel + deep management design USER APPROVED |

| Công trình | `P3_ASSET_BUILDINGS.md` | Visual family approved; exact source bytes cần phục hồi |
| Map/terrain/environment | `P3_ASSET_MAP_ENVIRONMENT.md` | Design contract locked; source availability mixed |
| Đệ tử map actor | `P3_2_MODULAR_ACTOR_SPEC.md`, `P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md` | female proof đang làm |
| Màn Đệ Tử | `P3_UX_DISCIPLE_SCREEN.md` | V3.3 locked; 6 real tabs |
| UI skin/icon | `P3_UI_SKIN_AND_ICONOGRAPHY.md` | Style canon locked; runtime asset family pending |
| Asset manifest kỹ thuật cũ | `P3_2_ASSET_MANIFEST.md` | Inventory/checklist; không thay registry/authority mới |
| Source A Spine converter / Batch-01 / Godot UI asset handoff | `P3_SOURCE_A_ANIMATION_ASSET_UI_UX_HANDOFF_2026-10-17.md` | 10 rig technical PASS ngoài repo; UI visual/Android và MAP25 binary import PENDING; **không thay rig modular canon** |
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

`map V3.1 -> tap disciple -> right summary panel V3.2 -> Xem chi tiết -> deep disciple screen V3.3`

Map phải giữ cảm giác chiếm khoảng 85–90% thị giác khi không có deep overlay.

Không dùng:

- fixed sidebar lớn thường trực;
- panel đệ tử mở mặc định ở trạng thái map bình thường;
- floating disciple quick-card cũ thay cho V3.2 right summary panel;
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


## P3.6A playable vertical slice status

Real user video on 2026-10-05 showed that the live main scene still reads as a QA/debug shell despite P3.3/P3.4/P3.5 being runtime-green. Productization authority: `P3_6A_PLAYABLE_VERTICAL_SLICE_SPEC.md`. P3.6 manual product-loop playtest is blocked until P3.6A visual acceptance. P3.6A code productization is now implemented on main; runtime is REAL PASS and real visual review is pending. Its procedural building silhouettes are temporary stand-ins only and do not supersede approved building art.

---

## FE-00 production frontend architecture (2026-10-12 — DESIGN ACCEPTED)

Read `docs/decisions/0003-fe00-godot-native-data-driven-frontend.md` before any production frontend/asset transfer work. This decision establishes one Godot-native presentation pipeline (canonical simulation -> snapshots/view-models -> controllers -> visual registry/components) and a fixed-layout isometric world/navigation model. It **does not supersede** V3.1/V3.2/V3.3 UX, the eight approved historical building visuals, `P3_ASSET_REGISTRY.json` or the source recovery manifest. TransferKit's 13 Source A visual records are candidate mappings; three remain INFERRED_VISUAL_ANALOG. Only an explicitly approved visual replacement may change a historically approved building identity. ADR-0002 LFS remains PROPOSED.

FE-00 is closed as design review only, FE-01 code/art transfer is **QUEUED / NOT AUTHORIZED**, Windows click/visual/APK remains PENDING USER. Preserve the single authoritative gameplay state and existing landscape 1280x720 acceptance.

## FE-01A accepted implementation status (2026-10-12)

The FE-00 architecture decision (ADR-0003) remains authoritative. User separately authorized **FE-01A only**, which is now **CLOSED / OFFICIAL GODOT 4.7.2 FOCUSED + RELEVANT REGRESSION PASS** at [Actions #38201510657](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38201510657), source SHA `35a0d4e9`. Runtime candidate resolver: `godot/src/presentation/assets/visual_asset_registry.gd`; source-provenance manifest: `godot/data/presentation/source_a_candidate_manifest.json`; checker: `tools/validate_fe01_manifest.py`. The 13 records are **candidate metadata only**, 10 source VERIFIED/3 inferred visual analogs, shared model/texture marked. Original eight building S3 artwork approvals and `P3_ASSET_REGISTRY.json` remain unchanged. Runtime returns placeholder/fallback metadata; 13 binary source textures have **not** been imported or approved. No Source A redistribution rights confirmed. **FE-01B / FE-02 not authorized**, DV2-03 remains PAUSED BY USER (not closed), Windows visual/click/APK PENDING USER. This status supersedes the prior FE-00-era wording `FE-01 NOT AUTHORIZED` for **FE-01A only**; no future packet is implicitly authorized.
