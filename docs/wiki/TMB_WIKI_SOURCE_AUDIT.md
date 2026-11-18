# TMB Wiki — kiểm kê nguồn và coverage

- Snapshot source HEAD: `459b58b19f1e25fe7dacc68172b1935cfee8cd96`
- Schema: `1` · chế độ: `LOCAL_ONLY_PRIVATE_BY_DEFAULT` · đồng bộ: một chiều game → Wiki.
- Generated projection chỉ chứa nguồn repo; ghi chú và đề xuất owner nằm trong localStorage của trình duyệt, không được ghi vào repo.
- SHA trong bảng là SHA-256 tại snapshot này; file văn bản chuẩn hóa CRLF/CR thành LF trước khi băm để kết quả ổn định giữa Windows/Linux. File nhị phân (nếu bổ sung sau) giữ hash byte gốc.

## Coverage đã trích xuất

| Nhóm | Số lượng | Diễn giải trạng thái |
|---|---:|---|
| Môn phái | 12 | Design taxonomy |
| Nhánh | 36 | Art guide, chưa xác nhận animation runtime |
| Skill V6.3 | 2196 | ID duy nhất 2196; catalog ứng viên, gate OFF |
| Skill family | 420 | ID `family_id` duy nhất trong catalog |
| Presentation entry | 553 | Metadata manifest, không phải asset art/GUI approval |
| Thiếu presentation entry | 1643 | Tính bằng ID chéo manifest / catalog |
| Công pháp | 84 | Candidate; learning gate OFF |
| Cảnh giới | 30 | Hai track từ code; DV2-03 QA open |
| Định danh đan dược | 476 | Sinh theo catalog; không đồng nghĩa recipe có thể chế |
| Recipe đan authored | 8 | Recipe definition trong MedicineCatalogueV2 |
| Recipe đan legacy | 2 | Giữ riêng; không trộn ID legacy vào tập 119 định danh V2 |
| Recipe trang bị | 5 | Từ EquipmentSystem; có gap so với spec 10 slot |
| Resource | 34 | Từ ResourceRegistry |
| QA source liên kết | 4 | File test hiện hữu; kết quả chưa được chạy/đối chiếu lại tại snapshot này |

## Gap register

| ID | Mức | Tình trạng | Mô tả | Nguồn | SHA-256 |
|---|---|---|---|---|---|
| GAP-SCHOOL-REGISTRY-COVERAGE | OWNER_REVIEW | SOURCE_CONFIRMED_SCOPE_GAP | Nguồn art/design có 12 môn phái và 36 nhánh; registry runtime hiện khai báo 6 phái/18 path và enabled=false. | `godot/data/combat/v63_content_registry.json` | `f84a94523095a5a778539ce5a31182a04406a0c003fade26aae8eaea6910e349` |
| GAP-V63-OFF | STATUS_ONLY | EXPECTED_GATED_OFF_NO_FIX_REQUESTED | Có 2196 skill ID ứng viên trong catalog V6.3; 18 consumer gate mặc định đều false. Đây là trạng thái hiện hành, không phải lỗi bắt buộc sửa; chỉ xem xét bật khi Owner mở packet phát hành riêng. | `godot/src/simulation/combat/v63_feature_gates.gd` | `ee904e9321a7803e503c77cd38748ef450a956fba66b839248e3acd920e6fb0b` |
| GAP-PRESENTATION-LINK | DESIGN_QA | MANIFEST_LINK_MISSING | Manifest có 553 entry metadata trên 2196 skill; còn 1643 skill không được liên kết entry. Entry metadata không đồng nghĩa sprite/VFX asset hay GUI approval. | `godot/data/presentation/v63_skill_presentation_manifest_v1.json` | `aad56bc4216e8fa8e33f5d0e89b0eeb02e90a7d0833b341588fc1dcbbdda7369` |
| GAP-FORMULA-TRACE | RUNTIME_TRACE_PENDING | FORMULA_CONSUMER_LINK_UNKNOWN | Các damage_ratio/power/duration trong candidate catalog là dữ liệu; không được coi là runtime formula. V6.3 gate đang OFF và catalog chưa lưu consumer function/test ID cho từng node. | `godot/src/simulation/combat/v63_feature_gates.gd` | `ee904e9321a7803e503c77cd38748ef450a956fba66b839248e3acd920e6fb0b` |
| GAP-DUPLICATE-SKILL-ID | DATA_INTEGRITY | CLEAN_NO_DUPLICATE_ID | Validator so sánh ID thô qua tất cả catalog đầu vào trước khi khử trùng. Duplicate ID phải sửa nguồn; không gộp âm thầm. | `godot/data/combat/v63_blade_combat_catalog.json` | `7454eb1e080958d4caf529c13acbadc85ada5ae3ef42135989d68ff61e5b3192` |
| GAP-SUSPECTED-DUPLICATE-PAIRS | REVIEW_CANDIDATE | NO_EXACT_NAME_COLLISION | Đối chiếu tên chuẩn hóa + school + branch + generation. Đây chỉ là heuristic để review; cùng family/slot qua nhiều node không tự động là lỗi. | `godot/data/combat/v63_blade_combat_catalog.json` | `7454eb1e080958d4caf529c13acbadc85ada5ae3ef42135989d68ff61e5b3192` |
| GAP-VFX-ART | ART_PENDING | ART_OR_RENDER_NOT_PROVEN | VFX manifest có 0 asset_files; presentation manifest ghi capture NOT_CAPTURED và GUI PENDING. | `godot/data/presentation/v63_combat_vfx_manifest.json` | `5d9bd09e01043083a767749fe6ca200a0c8ed079fd25cd17be7c1cefa99ecb3d` |
| GAP-ART-ANIMATION | ART_PENDING | NO_VERIFIED_BRANCH_ANIMATION | Art guide xác nhận chuyển động theo từng nhánh chỉ là storyboard direction; không có rig/animation VERIFIED trong bảng coverage. Độc Tu V4 chỉ là candidate theo từng hướng dẫn mỹ thuật. | `docs/animation/TMB_DISCIPLE_SCHOOL_VISUAL_MOTIFS_20261111.md` | `fc768dcd62847ab305d66807647f7a84d0118fd5bfbc47e7fbfb61437366a7e8` |
| GAP-EQUIPMENT-AUTHORITY | OWNER_REVIEW | SOURCE_CONFLICT_REQUIRES_RECONCILIATION | EquipmentSystem source khai báo 3 slot hợp lệ (weapon/armor/talisman); Weapon Equipment V2 spec mô tả 10 ordinary slots cộng loadout riêng. Giữ hai nguồn cạnh nhau, không tự hợp nhất thành gameplay authority. | `godot/src/simulation/equipment/equipment_system.gd` | `7c12e45082d6a5b8f7db2f19ef3b156f3c87b7ae3850679c7a2ba8fdf9703e85` |
| GAP-REALM-QA | QA_PENDING | CODE_PRESENT_QA_OPEN | Mã DiscipleRealmProgressV2 có cả hai track 30 realm; checkpoint/handoff là authority trạng thái chấp nhận. Wiki chỉ liên kết test source, không suy diễn PASS từ file test. | `godot/src/simulation/cultivation/disciple_realm_progress_v2.gd` | `5f3f70e4152160a645825593b802b0d7f30da9302e7113fd6a57a4ee4bbd54c5` |

## Giới hạn đọc dữ liệu

- `PENDING`/`UNKNOWN` nghĩa là nguồn hiện tại chưa cho phép kết luận; Wiki không đoán PASS.
- `SPEC_ONLY` không được đổi thành `LIVE_VERIFIED`; `TECH_PASS` không được đổi thành `ART_APPROVED`.
- Dashboard phân biệt dữ liệu thiết kế, mã/registry, feature gate, test source, kết quả test và phê duyệt owner.
- Không có file save cá nhân hoặc dữ liệu người chơi được đưa vào catalog.

## E recovery overlay — 2026-11-19 (PR #72 exact HEAD)

- Recovery code snapshot: [`264514ff760eaf22b339cb75ca29be53f9ab8351`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/264514ff760eaf22b339cb75ca29be53f9ab8351); PR #72 còn Draft. Bốn lớp asset được theo dõi riêng: file, import, binding runtime, render nhìn thấy; phê duyệt mỹ thuật là cổng riêng.
- Inventory read-only đã xuất tại `E:\\TongMonBaDaoWorkspace\\03_QA_Logs\\ONE_GAME_INVENTORY_20261119_002036`. E canonical đang dirty nên không đồng bộ hoặc chạy game. Chi tiết worktree/launcher nằm trong inventory ngoài repo.
- Map manifest có 34 file: 29 texture môi trường Source A còn được renderer nạp có điều kiện theo SHA; 5 ảnh công trình Source A cũ vẫn có trong manifest nhưng không còn được chọn làm texture công trình hiện tại. Hai checkout E khớp SHA 34/34; sidecar/cache có nhưng đó không phải Godot import PASS.
- Bảy gói actor có asset.json khớp Git blob 7/7; 31 file dẫn xuất có mặt mỗi checkout, nhưng chỉ 21/31 khớp SHA, 10 lệch chưa giải thích. 24 khai báo clip: 23 frame-count khớp, 1 lệch ở clip dead của Boss-slot candidate (khai 30, lưu 21). Chưa gán danh tính Boss; không có capture hiện hành để gọi chúng là nhìn thấy trong gameplay.
- Cổng hiện tại: Godot 4.7.2 import/GUI, player test và capture ở exact HEAD đều **NOT_EXECUTED**; render/duyệt Owner **PENDING/UNKNOWN**. Không suy diễn từ `.import` cache hoặc code wiring.
