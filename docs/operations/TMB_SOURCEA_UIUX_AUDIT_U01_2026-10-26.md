# TÔNG MÔN BÁ ĐẠO — SOURCE A UI/UX ASSET AUDIT U01

**26/10/2026 | OWNER chọn A | trạng thái: GitHub evidence reviewed; E: original image/prefab QA = PENDING CODEX WINDOWS | chỉ DOCS.**

Đây là một **audit độc lập, ưu tiên đọc dữ liệu gốc**, không phải lệnh viết lại UI hoặc dừng PvE. Sử dụng cùng quy tắc điều phối [ChatGPT ↔ Codex](TMB_CHATGPT_CODEX_CONTROL_CONTRACT_2026-10-26.md) (tài liệu nằm tại nhánh cha, đường dẫn thực tế ` docs/operations/TMB_CHATGPT_CODEX_CONTROL_CONTRACT_2026-10-26.md). Kênh checkpoint duy nhất: [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37).

## A. Kết quả điều tra trên GitHub — BẰNG CHỨNG THỰC TẾ

### A1. Kho kiến thức Source A ngoài repo game — kiểm tra trực tiếp

Private source knowledge: [ZQZS-Source-Knowledge](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge) và [SOURCE_CATALOG](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/SOURCE_CATALOG.md).
- [catalog_summary.json](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/analysis/DeepAnalysis/data/catalog_summary.json): nhóm **UI=42.724** mục catalog; toàn catalog có **36.112 Sprite, 22.701 Texture2D, 3.330 AnimationClip** (những tổng này gồm **mọi** nhóm, không phải số UI assets thực dụng). Đây là snapshot cũ từ thư mục extract; KHÔNG suy ra 42.724 PNG UI độc lập, không suy ra tỷ lệ trùng hay trạng thái playable.
- [index_stats.json](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/indexes/index_stats.json): 24.102 Lua modules; **5.609 UI-window call edges**; trong nhóm UI_UX có 3.893 module APK + 4.033 module AndroidData (**không** khẳng định 7.926 module duy nhất hay runtime active).
- [docs/UI_UX.md](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/docs/UI_UX.md) và [indexes/ui_calls.csv](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/indexes/ui_calls.csv): controller đọc model/phát command, UI-window strings chỉ là edges ứng viên; code inspection cần đọc callsite. Do NOT suy từ logic client thành game authority.
- [SOURCE_EVIDENCE_POLICY.md](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/SOURCE_EVIDENCE_POLICY.md) + [SOURCE_TO_GODOT_MAP.md](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/SOURCE_TO_GODOT_MAP.md): distinguish VERIFIED / INFERRED / UNKNOWN, APK ≠ AndroidData, IL2CPP declarations ≠ C# runtime source, metadata ≠ complete scene/asset. Repository Source Knowledge cố ý **không chứa ảnh/atlas/audio/AssetBundle**.
- Bằng chứng prefab có thật: [building_ui.json](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/analysis/DeepAnalysis/data/building_ui.json) từ ` E:\GameAssetExtract\GameData\com.vnzqzs.and\Android\ui\windows\home\uibuildingmsgwin.ab và prefab ` assets/prefabs/ui/windows/home/uibuildingmsgwin.prefab. Đã phân tích **20 GameObject + 20 RectTransform, 11 CanvasRenderer, 4 CanvasGroup**; phân loại MonoScripts thấy ` Image, Text, Button, ScrollRect, RectMask2D và controller CSGUI; tên node có ` bg, icon, close, viewport, #scrollview, msgitem. [Sample graph summary](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/analysis/DeepAnalysis/data/sample_bundle_graph_summary.json) ghi **194 liên kết nội bộ**. Đây là **một prefab thực có hierarchy**, nhưng **chưa chứng minh độ đầy đủ của texture dependencies, Sprite border, font, material, UI skin hoặc chạy được trên Godot**.
- Catalog Source A đã được bóc từ ` E:\GameAssetExtract (xem SOURCE_CATALOG), trong khi user cũng có các nguồn Source A game-related khác trên E. Không mặc định đây là path đầy đủ duy nhất: Codex phải phát hiện và hash volumes/phân vùng **chỉ thuộc game**.

### A2. Hiện trạng asset/game Godot kiểm tra tại remote ` feature/pve-jx-continuous-world-20261026, commit 038873592b908c05a28ac7f827a8b831fce000c8

- ` godot/src/presentation/assets/visual_asset_registry.gd và ` visual_asset_record.gd đã có **visual asset registry**; dùng lại interface/contract thực tế nếu phù hợp.
- ` godot/src/presentation/p3_2_landscape_sect.gd và ` godot/scenes/p3/p3_2_landscape_sect.tscn là luồng HUD/P3.2 cần tôn trọng; các bài ` godot/tests/presentation/tmb_pr27_ui_readability_test.gd, ` p3_2_disciple_ui_test.gd, ` p3_4a_building_operation_panel_test.gd đã có.
- ` godot/art/source_a_env02a có cây/map/đường/công trình, ` godot/assets/actors có actors, nhưng trong ` godot/assets hiện quan sát nhóm ` actors, ` combat_v4, ` combat_v5_source_a; **chưa thấy thư viện UI Source A chuyên biệt, verified và reusable** trong các thư mục kiểm tra. KHÔNG kết luận không tồn tại UI nơi khác hoặc trên local E:.
- ` godot/data/presentation/source_a_candidate_manifest.json chỉ mô tả **candidate/registry**, không là UI acceptance. ` outputs/endgame_qa_20261026/assets/sourcea_qa_pass_asset_catalog.csv ở PR39 kiểm kê actor Spine QA, **không được dùng thay UI atlas inventory**.
- PvE-VIS-01 vẫn có local dirty/remote divergence có thể tồn tại: **TẤT CẢ file gameplay/PvE VFX/branch đó cấm viết trong packet U01**.

## A3. GATE ƯU TIÊN MỚI — TÌM TẤT CẢ SPINE ĐÃ CHUYỂN SANG GODOT TRƯỚC (OWNER 26/10)

**CÓ catalog chuyển đổi sẵn, U01 trước đó mới kiểm kê sơ bộ chứ CHƯA forensic-audit toàn bộ thư viện converted cho UI.**

Bằng chứng GitHub:
- § outputs/endgame_qa_20261026/assets/sourcea_qa_pass_asset_catalog.csv (PR #39 § feature/endgame-visual-lod-pve-world-foundation-20261025): **263 hàng/263 § QA_PASS**, mỗi hàng có § source_sha256, § output_sha256, § godot_scene, § spriteframes, § clips và đường dẫn source. Đây là **263 bản ghi actor/rig Spine converted**, chưa phải 263 UI asset; đa số § role=UNKNOWN. Số **269 asset PASS** Codex từng báo là một định nghĩa/count khác chưa đối chiếu; không tự nhập 269 vào cùng thước đo 263.
- Ở remote § feature/pve-jx-continuous-world-20261026 (03887359) thư mục § godot/assets/actors/ có bảy thư mục (1113028_1, body_1110201, body_1120402 và bốn actor V5), cùng § godot/assets/combat_v5_source_a/visual_manifest.json; đây là tập được nhập vào **nhánh game**, khác với toàn thư viện **263 pack** nằm trên E. Không tự kết luận toàn bộ pack đã nằm trong GitHub.
- § docs/handoffs/2026-10-24/WORKER_ASSET_CATALOG.json (trên nhánh handoff) chứa các mẫu converted Godot + source SHA/atlas SHA, timing/pivot/clip. § godot/data/presentation/source_a_candidate_manifest.json là candidate art registry, không xác nhận UI source.

**Thay đổi thứ tự công việc U01:**
1. **G0: Existing-conversion-first** — lập inventory read-only mọi Godot-ready Source A trong repo và các thư viện chuyển đổi đã có ở E, không chỉ § godot/assets/actors/; đối chiếu § source SHA + clip/scene names + § animations.tres, § actor.tscn, § atlas_*.webp, § SpriteFrames + local QA logs. Phân biệt § REPO_IMPORTED, § E_CONVERTED_QA_PASS, § CONVERTED_NEEDS_VISUAL_QA, § RAW_ONLY, § DUPLICATE_BY_SHA.
2. **G0.1: Tìm UI trong converted** — lọc animation/tag/skeleton name liên quan cửa sổ, summon, dialog, icon effect, scrolling decoration, portrait, notification, button, progress; kiểm tra contact-sheet/animation thật, không biến rig đánh nhau thành asset UI vì chỉ thấy § attack. Phân loại actor portrait nếu thực sự dùng được, **không gọi actor sprite là panel hoặc button**.
3. **G0.2: Gap analysis** — so nhóm UI/9-slice atlas/prefab từ § ZQZS-Source-Knowledge với converted inventory; xuất bảng § existing_path, source_sha256, godot_resource, clips, visual_role, provenance, qa_state, missing_dependencies, reimport_needed. Nếu không có UI trong converted, ghi § VERIFIED_NOT_FOUND_IN_SCANNED_SCOPE (nêu phạm vi), mới chuyển sang scan raw Unity bundles có mục tiêu.
4. **Không convert lặp** pack § QA_PASS nếu binary/source hash tương đương. Cần đổi metadata/pivot/import settings thì dùng derivative/branch riêng, báo rõ không ghi đè master. Có thể tạo portrait/UI frame sử dụng scene actor đúng vai trò, nhưng phải bảo đảm sizing và performance; không tự ý chỉnh runtime actor.

**U01 acceptance bổ sung:** một mục § Converted-first audit trong báo cáo, nêu tổng số distinct SHA / § Godot scenes scan thật / bao nhiêu ứng viên UI đủ evidence / bao nhiêu chỉ là actor / bao nhiêu missing; gắn sample paths/screenshots của 5–10 asset. Chỉ sau G0 mới đi § uibuildingmsgwin.ab → external dependencies → source atlases / Godot UI-lab.

## B. Nhiệm vụ CODEX WINDOWS — U01 Asset-forensics (KHÔNG sửa gameplay)

### Mục tiêu rất cụ thể

Bóc **một thư viện UI thực tế có chứng cứ** từ Source A: cửa sổ, button, panel, icon, portrait, 9-slice, atlas, font và UI motion. Sau đó cung cấp **một gallery xem được** và **một pilot Godot UI-lab không gắn vào runtime**. **Không đo tiến độ bằng số file đã quét.** Chọn pilot **Building/Worksite Details Window** vì prefab ` uibuildingmsgwin.ab đã có đường dẫn + hierarchy proven; có thể thay bằng một UI window khác **nếu** dependency đủ và ảnh gốc rõ hơn, báo lý do.

### Ranh giới an toàn và ownership

- Codex UI audit dùng **worktree/tên branch hoàn toàn mới**, ví dụ ` E:\codex\2026-10-26\TMB_UI_SOURCEA_U01_WORKTREE và ` research/sourcea-uiux-u01-20261026. **Đừng checkout/reset/sửa** ` feature/pve-jx-continuous-world-20261026 hoặc worktree PvE hiện hành.
- Khi PvE Codex đang chiếm RAM/Godot, **không chạy scan/render nặng đồng thời** trên máy Windows 8GB. Audit metadata read-only trước; screenshot Godot UI lab lúc an toàn.
- Đọc dữ liệu game-related ở ` E:\GameAssetExtract\... và các thư mục game Source A thực được phát hiện. **Không đọc, sửa, sao chép hoặc upload dữ liệu cá nhân/người dùng ngoài game** kể cả dữ liệu profile trong GameData. Không xoá, đổi tên, chuyển đè file gốc, không bulk-convert hàng vạn file.
- Backup manifest và SHA256 cho nguồn **được chọn**; dedup SHA trước khi convert. Mỗi export dẫn được về root/bundle/pathID + source SHA. Không push binary masters, font proprietary hoặc hàng GB bundle lên GitHub. Gallery chỉ gồm ảnh QA kích thước vừa phải trong **private repo** khi nguồn/quyền nội bộ phù hợp.
- Không tự merge main, không sửa Combat V2/One Active Job/Injury120/Warehouse/Save/economy hoặc ảnh Source A PvE đã nghiệm thu. Không thay thiết kế UI sản xuất live ở U01.

### Tìm có chủ đích, không quét mù

1. **Định vị asset** từ ` Android/ui/windows/home/uibuildingmsgwin.ab → prefab name/pathID → RectTransform, Image/Button/Text, Sprite/Texture2D/Material/Font theo external references. Kiểm tra path bundle variant (APK/SplitAssetPack/AndroidData) và bản đang dùng nếu xác minh được; nếu không → UNKNOWN.
2. Quét metadata các namespace ` ui/windows, ` ui/common, ` icon, ` bag, ` disciple, ` equip, ` gongfa, ` home, ` gui, ` atlas, ` sprite, ` font, ` effect/ui, các path tiếng Trung tương đương nếu tồn tại. Liên hệ ` indexes/ui_calls.csv để ưu tiên cửa sổ tông môn/đệ tử/công trình/kho/Forge; không biến call string thành bằng chứng ảnh.
3. Phân loại: **panel/window/background; 9-slice border; button idle/pressed/disabled/focus; tabs; icon & quality frame; portrait/head; status/progress bar; scroll/list; tooltip/dialog; particles/UI animation; shader/material; SFX; TMP/dynamic/font/glyph**. Một texture có nhiều sprite con ghi atlas rect/trim/rotation, không nhân số sprite sai.
4. Với mỗi **asset được chọn** đối chiếu: container bundle; Unity asset ID/pathID; texture size; pixels per unit nếu có; Sprite rect, original rect, pivot, border 9-slice {L,T,R,B}, packing rotation/trim; alpha, material/blend; animation clips/timing; external font refs; SHA256. Không suy ra border từ ảnh nếu metadata vắng mặt — flag ` NEEDS_MANUAL_SLICING.
5. Export nhỏ để preview **không mất alpha**: ít nhất 1 contact sheet nhóm panel/window, 1 nhóm button+states, 1 nhóm icon/portrait, 1 prefab tree annotated, 1 short UI-motion capture nếu có thật; mỗi ô gallery có ID/path/hash/VERIFIED vs CANDIDATE. Font: lưu tên/family/glyph coverage và tình trạng giấy phép, **không xuất font proprietary**.
6. Thử Godot 4.7.2 import **một số asset verified** vào sandbox UI-lab độc lập, kiểm tra 9-slice scale ở ba kích cỡ, button normal/hover/pressed/disabled, typography tiếng Việt, controls 1280×720, hit region đủ touch, visual no alias/bleed, RAM/render budget. Nếu thiếu dependencies, không dựng ảnh giả gọi là original; đánh dấu BLOCKED/PARTIAL và trình bày hierarchy/ảnh đơn lẻ đúng mức.

### Cột bảng manifest bàn giao ` ui_sourcea_verified_manifest.csv

` candidate_id, category, display_role, evidence_state, variant, source_bundle, asset_path, unity_path_id, source_sha256, exported_sha256, export_path, texture_size, atlas_rect, trim, rotation, pivot, sprite_border_ltrb, ppu, material, dependencies, animations, font_metadata, godot_target, screenshot, issue

Evidence states (phân biệt):
- ` VERIFIED_METADATA — path/binary/hash/metadata thực đối chiếu được, chưa chấp nhận hiển thị;
- ` VERIFIED_VISUAL — đã xem ảnh frame/contact sheet gốc và đối chiếu asset;
- ` GODOT_QA_PASS — import/correct resize/alpha/interaction tại exact SHA trên Godot 4.7.2;
- ` CANDIDATE_ONLY — tên/path suy đoán chưa verify;
- ` MISSING_DEPENDENCY / UNSUPPORTED / DUPLICATE — báo lý do, không tuyên bố asset dùng được.

Tổng kết có ` scanned roots, số bundle/Sprite/Texture2D duy nhất theo source SHA, số candidates, số từng gate (không cộng pack/texture/sprite/prefab khác đơn vị), ngưỡng ảnh hưởng perf, lỗi thiếu. SHA manifest phải có khả năng tái chạy bằng script nhẹ và kiểm tra được.

## C. Component Godot đề xuất — reuse image thật, **chưa claim implemented**

Sau U01 metadata gate, Codex tạo pilot riêng (no production state writing), không fork UI runtime.

| Component | Godot primitives | Source A asset dependency | Runtime contract |
|---|---|---|---|
| ` TmbWindowFrame | ` PanelContainer + NinePatchRect + VBoxContainer | verified 9-slice panel + corners/cap | chrome-only, close/focus/drag when legitimate, responsive |
| ` TmbImageButton | ` TextureButton + Label | idle/hover/pressed/disabled sources from same button family | emits ` pressed; no direct economy |
| ` TmbIconSlot | ` Control/TextureRect/NinePatchRect | icon atlas rect + quality rim/mask + tooltip art | displays bound item resource ID; no fictitious item |
| ` TmbProgressStrip | ` TextureProgressBar + Label | filled/empty/decoration from verified atlas | reads production/exp actual value, no timer authority |
| ` TmbPortraitTile | ` TextureRect + optional animated actor view | portrait/head frame (not replace world actor) | reads V2 disciple visual mapping, no state creation |
| ` TmbTabbedScrollWindow | ` ScrollContainer + tab buttons | verified tab states, scroll/background | content driven by existing P3.2 query adapter |

**Pilot ưu tiên:** ` TmbWindowFrame + ` TmbImageButton + ` TmbIconSlot trong **Building Details Window** để đối chiếu prefab ` uibuildingmsgwin. Chỉ mở rộng thêm thành phần nếu ảnh thật và state binding có bằng chứng.

**Data flow:** ` SimulationState/Runtime -> existing presentation snapshot/read-only adapter -> UI node render. User interaction -> ` signal (intent) -> existing validated gameplay command → state refresh. Widget animations/particles chỉ mang tính hiển thị. UI theme cần explicit color/contrast/icon/touch-state; không dùng sprite trắng thay asset không tìm thấy rồi tuyên bố Source A.

**Folder đề xuất cho sandbox** ` godot/tools/qa/sourcea_ui_lab/; output small ` godot/outputs/sourcea_ui_u01/; eventual reusable component proposal ` godot/src/presentation/ui_components/ **chỉ sau khi visual evidence được duyệt**. Trong U01, không đụng live ` godot/scenes/p3/p3_2_landscape_sect.tscn. Chụp 1280×720 cùng một state với UI hiện tại để so, không gọi ảnh tĩnh Photoshop là runtime.

## D. Giao tiếp ChatGPT ↔ Codex (giữ PVE-VIS-01 làm nhiệm vụ gameplay ưu tiên)

- Đây là **U01-R&D (parallel documentation/isolated lab)**. Issue #37 tiếp tục có **PVE-VIS-01 là active gameplay delivery packet**; không thay ưu tiên, không cướp writer of production UI/PvE.
- Codex UI có thể chạy **riêng** khi máy cho phép hoặc sau checkpoint PvE. Điều kiện bắt đầu là owner đã giao A, không cần hỏi từng file. Nếu không thể chạy vì session/CPU/RAM, phải cập nhật ` BLOCKED: LOCAL_EXECUTION_NOT_STARTED; ChatGPT từ GitHub **không tự điều khiển Computer Use/Codex đang mở**.
- Kết thúc bằng **một commit docs+gallery+manifest (nhẹ)** trên branch mới; 1 comment Issue #37: ` U01/AUDIT, local/remote SHA, scan roots, counts by unit, 10 asset samples with direct source proof, gallery hyperlinks, UI lab Godot state, risks, next best *single* UI pilot. Không mở PR gameplay hoặc merge.
- Chính sách kết luận: review GitHub có thể xác nhận metadata/text; **UI visual-pass yêu cầu preview PNG/runtime thực** và owner duyệt đẹp.

## E. Prompt gửi Codex Windows, dùng nguyên trong phiên riêng

> TÔNG MÔN BÁ ĐẠO — thực hiện U01 Source A UI/UX forensic audit (owner chọn A, 26/10). Đọc Issue #37 và tài liệu ` docs/operations/TMB_SOURCEA_UIUX_AUDIT_U01_2026-10-26.md trên nhánh ` docs/sourcea-uiux-audit-20261026 **mà không checkout đè PvE**. Tạo worktree UI-only riêng. Kiểm tra git dirty/process/RAM trước. Đối chiếu ` vuanhtuan161094-byte/ZQZS-Source-Knowledge (catalog_summary.json, index_stats.json, building_ui.json) với **AssetBundle UI thật trên ổ E**, bắt đầu từ ` uibuildingmsgwin.ab; rà atlas, sprites, prefab dependencies, button normal/pressed/disabled, panel/9-slice, icon, portrait, animation, fonts; SHA source/export và phân loại verified/candidate/duplicate/missing. Không upload masters/fonts hoặc convert toàn kho. Bàn giao CSV manifest, gallery ảnh thật có nhãn ID/SHA, cây prefab annotated, và sandbox Godot 4.7.2 Building Details Window có 3 component tái sử dụng (WindowFrame, ImageButton, IconSlot) **chỉ nếu** asset+dependency verified; test resize/click/alpha/1280×720, ảnh runtime. Nếu thiếu asset phải ghi rõ, không placeholder giả và không gắn vào gameplay. Commit/push nhánh độc lập an toàn, comment checkpoint vào Issue #37 với exact SHA, links, gaps. Giữ PVE-VIS-01 là packet gameplay chính, không sửa worktree/branch/code PvE, không merge main.
