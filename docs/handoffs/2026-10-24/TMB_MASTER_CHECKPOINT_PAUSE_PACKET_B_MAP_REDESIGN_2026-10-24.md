# TÔNG MÔN BÁ ĐẠO — MASTER CHECKPOINT / PAUSE PACKET B / CHUYỂN SANG NGHIÊN CỨU MAP V2
**Ngày chốt:** 24/10/2026 (Asia/Bangkok)  
**Trạng thái:** CHECKPOINT ĐÓNG BĂNG ĐỂ BẢO TOÀN BẢN ĐÃ KIỂM THỬ; các PR vẫn OPEN/DRAFT/UNMERGED.  
**Ưu tiên tiếp theo do owner chỉ định:** **TẠM NGHỈ gameplay/Combat/UI implementation để tập trung thiết kế lại MAP TÔNG MÔN.**  
**Giới hạn:** Tài liệu và nghiên cứu cho map là bước kế tiếp; tuyệt đối không coi file này là ủy quyền đổi renderer, thay asset, rewrite tọa độ, đổi gameplay hoặc merge PR.

## 0. Đọc mục này trước tiên khi tiếp quản

Dự án không cần làm lại từ đầu. Đã có bản game **PR #31** chạy kết hợp sản xuất + quản lý đệ tử D7 + CARE săn Thanh Lang + Combat V3-S1 + UI Source A ở scene chính P3.2. Bản đó đạt official Godot 4.7.2 focused regression 28/28 và 19 khung hình gameplay tự động. **Giữ nguyên làm baseline/rollback trước khi thiết kế map mới**. Mục tiêu giai đoạn tiếp theo là **thay đổi trải nghiệm/quy hoạch/hình ảnh MAP**, chứ không phải tái triển khai những hệ thống simulation đã có.

Checkpoint này được soạn trên **NHÁNH DOCS RIÊNG** từ exact PR31 HEAD, tránh thay đổi PR31. Hãy đọc chi tiết báo cáo PR31 và các authority trong mục 2 trước khi tạo đề xuất. File này chứa sự kiện đã kiểm chứng + backlog, **không thay thế** nguyên tắc authority của AGENTS.md, docs/GAME_SYSTEM_ARCHITECTURE.md, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md hay Art Bible. Khi chưa owner duyệt bản đồ mới, mọi thông số map thay đổi là **ĐỀ XUẤT**, không phải canonical lock.

## 1. GitHub freeze — CHÍNH XÁC KHÔNG NHẦM SHA

**Repository:** vuanhtuan161094-byte/TongMonBaDao  
**Engine:** Godot 4.7.2.stable.official.ed1daf0bf  
**Target:** Android landscape 1280×720; Windows is validation platform.  
**Latest actual playable integrated candidate:** [draft PR #31](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/31)

| Checkpoint | Ref hoặc SHA | Ý nghĩa / tình trạng tại lúc đọc |
| --- | --- | --- |
| PR24 | B3 CARE base; draft | Nền gameplay CARE; chưa merge |
| PR25 | P3.2 main hunt; draft | Săn trên scene chính; chưa merge |
| PR26 | MAP25/Source A recovery; draft | Nền đồ họa map và Combat V5 view; chưa merge |
| PR27 | deeae081bcfbe1413d4cf60a29db7e58150888b5 | D7, QA tiền tích hợp; chưa merge |
| PR28 | e9190f490ebea82d2badf7f3fc44b34dd24bd425 | Source A/UI/Map25, 21/21 focused riêng; chưa merge |
| PR29 | 9522812e91b7ca5bc0cc108eb92e000e930fe850 | Combat V3-S1 nền; chưa merge |
| PR30 | f86ab7e7d42d6d275314368554489514f7edb98f | S1 fixes + 14/14 focused, 56/56 edge riêng; chưa merge |
| **PR31 CODE TESTED** | **4b02a0c61a2771d9d4638129d96b68ad292270dc** | **Exact code/test SHA đạt integrated focused PASS** |
| **PR31 TESTED TREE** | **352700b65d3cd0ef7039df22a1153d81b2fd7b82** | Tree đã dùng cho 28/28 + actual GUI capture |
| **PR31 BRANCH HEAD / EVIDENCE** | **9eb4fd55733bb49bbb069240b8e332d37d22aced** | Docs/log/screenshot sau tested code; là HEAD lúc pause |
| **PR31 BRANCH** | **integration/pr28-combat-v3-s1-playable-qa-20261024** | 4 commits ahead / 0 behind PR28; **OPEN/DRAFT/UNMERGED**, mergeable true |
| **PAUSE DOCS BRANCH** | **docs/map-redesign-checkpoint-20261024** | Docs-only từ PR31 HEAD; không tự tạo gameplay revision |

**Không đánh đồng** code-tested SHA với docs/evidence HEAD. Cần ghi cả hai trong mọi báo cáo map về sau. Bắt đầu từ PR31 hoặc từ map-design-doc branch theo mục đích; **KHÔNG bắt đầu lại từ main** rồi tái tạo thủ công toàn bộ tính năng. Việc các PR đều chưa merge có nghĩa là main KHÔNG mặc nhiên chứa đầy đủ gameplay PR31.

### GitHub evidence authority

- PR31 implementation report: docs/handoffs/2026-10-24/TMB_PR28_S1_END_TO_END_INTEGRATION_REPORT_2026-10-24.md
- PR31 issue matrix: docs/handoffs/2026-10-24/TMB_PR28_S1_END_TO_END_ISSUE_MATRIX_2026-10-24.md
- PR31 next handoff: docs/handoffs/2026-10-24/TMB_PR28_S1_NEXT_HANDOFF_2026-10-24.md
- PR31 exact evidence dir: docs/handoffs/2026-10-24/evidence/packet-b/sha4b02/
- Full test table: evidence/packet-b/sha4b02/focused_results.csv
- Runtime event/state values: evidence/packet-b/sha4b02/capture_state_manifest.json
- Gameplay screenshots: evidence/packet-b/sha4b02/screenshots/
- Asset/source hashes: evidence/packet-b/sha4b02/source_manifest.json

## 2. Đã làm được gì — KHÔNG BỎ CÔNG KIỂM THỬ CŨ

| Hệ thống | Bằng chứng đạt / giới hạn |
| --- | --- |
| Gameplay trên P3.2 | Game thực chạy scene res://scenes/p3/p3_2_landscape_sect.tscn, thống nhất runtime owner; không có simulation clock/warehouse/loot riêng để làm demo |
| Môi trường tông môn | MAP25 Source A curated **32 asset đạt SHA gate** được giữ; camera pan/zoom, map, Mỏ/Linh Lâm/Linh Điền/Kho đã lên GUI 1280×720 |
| Sản xuất / One Active Job | O9 và Mine thực qua focused; capture mine_001/worker trieu_linh_nhi đi travel_out → mining → haul_back, Thanh Thiết canonical Kho **37→39 (+2)** |
| Đệ tử D7 / tuyển / hồ sơ | D7 và authentic V2 profiles, Source A actors nam/nữ hiện trong capture; test D7 foundation 139 checks trước đây và PR31 focused suite PASS |
| Săn quái CARE tự động | Đệ tử V2 thật candidate_73025 vào hunting world b3:vs1:bach_thach_khe:31012026:60, AUTO, chiến đấu Thanh Lang, quay về tông môn |
| Combat V3-S1 | Learned burn Hỏa Cầu, weaken Hàn Sương Ấn, learned guard Kim Cương Hộ Thể, đòn thường/cast/cooldown; V2 combat state vẫn authority, V5 chỉ vẽ/read-only |
| Learned guard proof | factor 0.62, active ở 11.0s, hết ở 14.0s; Hàn Sương Ấn applied weaken tại 5.0s; real events/capture có đối chiếu |
| Dữ liệu thật/luật nhận thưởng | Thanh Lang kill receipt COMMITTED tinh_lang_bi ×1; **paid_generation=1**, canonical Warehouse stock 1, restart/reload đúng, không trả trùng; same-world respawn |
| Capture setup thật | Test đệ tử đủ điều kiện học skill qua **185 lần cultivate, 63 rest, 3 successful breakthroughs** bằng API canonical trên profile cách ly; KHÔNG sửa trực tiếp status/effect/reward |
| Asset combat được xác minh | Source A male v5_sa_male_body_1110201; female v5_sa_female_1113028_1; monster v5_sa_monster_1113031_1; Boss-slot art tồn tại nhưng không được claim là Boss live |
| Official Godot QA | **28/28 focused PASS** trên tested code 4b02a0c; S1 edge test **56/56 checks PASS**, O9 PASS. Isolated user profile; no parse/assertion fail; log vẫn giữ environment diagnostic |
| Runtime GUI | **19 screenshots** của scene chính P3.2 ở **1280×720** gồm map, camera, sản xuất, mine đã kết toán, profile nam/nữ, burn, weaken, guard/expiry, loot, respawn, return; automated capture, chưa phải người chơi thao tác |
| Portable Windows candidate | Project Godot + run_tmb_windows.cmd + README; ZIP local 48,206,898 bytes, SHA-256 **8f912d8c3ede8051f6d238e6aee677d6c64f8ea243368e5460bc99b975bd7ce9**; automated smoke exit 0; không phải standalone EXE |

### Các ràng buộc kỹ thuật quan trọng đã giữ

- SimulationState / SimulationRuntimeOwnerV2 / B3HuntWorld / Combat V2 / canonical Warehouse / SaveService là nguồn dữ liệu thật.
- Presenter Source A Combat V5 đọc trạng thái thật, không viết AI/damage/loot riêng.
- Injury120, CARE exactly-once, one active occupation/job và SaveService không được thay để làm cho map đẹp hơn.
- **Save policy development:** không phải migration save lịch sử mỗi lần thay bản dev; **vẫn bắt buộc** save/load cùng version, exactly-once và fail-closed khi dữ liệu sai.
- Combat V3-S1 **chưa phải S2**: dash Truy Phong Bộ / fire_combo Liệt Diễm còn deferred. Giữ pilot burn hiện hữu mất khi caster bị hạ, chưa khóa vĩnh viễn cân bằng.
- Không tự động thêm Công Pháp V2/B3 long-horizon economy/balance đã thiết kế vào gameplay hiện có chỉ vì có tài liệu.

## 3. Còn PENDING / BACKLOG — phân biệt chưa làm với thất bại

| Nhóm | Tình trạng đúng | Ý nghĩa |
| --- | --- | --- |
| Windows mouse manual | **PENDING** | Chưa có trải nghiệm người chơi thật double-click/click/drag; portable project smoke tự động không chứng minh điều khiển thực tế |
| Android landscape/touch | **PENDING** | Chưa có QA máy Android, pinch/tap/pan/touch targets |
| Hiệu năng liên tục | **PENDING** | Capture sampling FPS **1–24** và static engine memory **62.7–73.7 MiB** không phải FPS/RAM benchmark kéo dài; cần đo cùng thực tế phần cứng, save và lượng actor |
| Owner visual sign-off | **PENDING** | Source A style đã chốt, nhưng layout map hiện tại chưa được owner phê duyệt cuối; thực tế owner yêu cầu NGHIÊN CỨU THIẾT KẾ LẠI MAP |
| Windows standalone EXE | **NOT AVAILABLE** | Export templates Godot Windows chưa có; portable project ZIP là deliverable đang có, không giả vờ là .exe |
| Editor-only settings smoke | **PARTIAL DIAGNOSTIC** | Isolated headless-editor quét project/exit 0 nhưng log lỗi save Editor Settings vào empty path; chưa có chứng cứ editor settings sạch |
| Godot Windows CA diagnostic | **KNOWN ENV DIAGNOSTIC** | Failed to read root certificate store xuất hiện, không gây parse/assertion FAIL; không được xóa dòng này khỏi báo cáo |
| GitHub Actions | **CI UNKNOWN / AUTOMATIC PUSH RUNS** | Owner/Codex không chủ động FULL/CI; nhưng GitHub branch có workflow push runs báo failure ở commit trước, chưa đủ log để kết luận code fail; xem docs/handoffs/2026-10-24/TMB_GITHUB_ACTIONS_AUTO_TRIGGER_AUDIT_2026-10-24.md trên docs/pr28-pr29-coordination-20261024 |
| Boss thật | **NOT IMPLEMENTED HERE** | Boss-slot Source A chỉ là presentation asset, không có canonical CARE Boss-event mapping |
| Production building packs | **ASSET GAPS** | Mỏ/Linh Lâm/Linh Điền chưa có bộ binary Source A hoàn chỉnh được QA; không được tự điền asset giả |
| Human-facing UI polish | **NOT FINAL** | P3.2 đã chạy được, nhưng map mới cần ra hệ thiết kế với visual hierarchy tốt hơn, không được gọi owner-approved |
| FULL CI / release | **NOT EXECUTED / NOT AUTHORISED** | Focused PASS không phải release QA; không merge lên main |
| Combat S2, Boss, x100/medicine/item balance | **DEFERRED** | Không đẩy ngay trong giai đoạn thiết kế map |
| Long-run 1,000–3,000 disciples | **NOT VALIDATED** | Tầm nhìn kiến trúc cho đệ tử quy mô lớn, không suy diễn PR31 đã stress-test đủ lượng |

### Lưu ý artifact

Local ZIP được báo ở Windows worktree \`E:/codex/2026-10-24/TMB_PACKET_B_PR28_COMBAT_V3_S1_20261024_WORKTREE/artifacts/packet_b/windows_candidate/TMB_Playable_Windows_PacketB_4b02.zip\`. Đây là **đường dẫn local máy owner/worker**, không phải file ZIP đã có trên GitHub và không phải sandbox download link. Metadata launcher/README được commit trong evidence; file ZIP 48 MB chưa commit vì tránh phình Git. Khi cần demo sau này, yêu cầu worker xác nhận file/hashes còn tồn tại.

## 4. Map hiện tại: thành phần kỹ thuật đã xác minh từ source PR31

**Active visual implementation**: godot/src/presentation/p3/sect_isometric_world_v1.gd  
**Supporting model**: godot/src/presentation/p3/sect_iso_map_model_v1.gd  
**Art adapter**: godot/src/presentation/p3/sect_map25_source_art.gd  
**Runtime wrapper**: godot/src/presentation/p3_2_landscape_sect.gd  
**Camera source**: godot/src/presentation/p3/sect_map_camera.gd và world Camera2D.  
**Canonical design docs to read:** docs/P3_ART_BIBLE.md, docs/P3_ASSET_MAP_ENVIRONMENT.md, docs/P3_UX_MAIN_MAP.md, docs/P3_1_LANDSCAPE_SECT_SHELL_SPEC.md, docs/P3_ASSET_REGISTRY.json, docs/P3_2_ASSET_MANIFEST.md.

Current source \`SectIsometricWorldV1\` defines:
- **GRID 192×192**, **CHUNK 16**, **STARTER Rect(72,72,48,48)** — these are current code constants, not an owner-approved redesigned map scale.
- Projection geometry **HALF_W 25**, **HALF_H 13** (iso 50×26 logical projected tile footprint).
- **VIEW_SIZE (1280,570)** and camera inside SubViewport; HUD anchored outside camera. Existing P3 Art Bible calls for main map mobile landscape 1280×720, isometric/top-down nhẹ, default 1.0, zoom design 0.75–1.80.
- \`TYPE_ANCHORS\` positions for main_hall, warehouse, forge, residence, cultivation, ren_than_duong, medicine, alchemy_hall, mine, linh_forest, spirit_field, guidance, gate; these are **current view anchors**, not proof all buildings have final verified art or construction gameplay.
- Real AStarGrid2D/navigation lab geometry and paths; presentation world does not own the canonical simulation/economy/save. Camera interacts with visible scene, not with combat RNG or worker production.

Current style lock: **Source A chibi + 2D hand-painted Chinese xianxia sect**, not King God Castle pixel art, not JX1 wholesale map renderer. A future map design can examine composition/layout/tiles/ground art but must not silently change gameplay or overwrite art-authority contracts without explicit approval.

Current asset reality:
- 32 MAP25 Source A PNGs used under SHA-gated manifest (real and verified).
- Main Hall / Warehouse / Forge proven visual examples: Source A IDs 510052 / 510102 / 520081 in existing world sources.
- Source A actor packs (male/female/Thanh Lang) imported and reused.
- Long-term environment docs may mark other terrain/water/deco assets as missing/production-pending. Do not mistake a recovered/verified MAP25 subset for a complete final terrain kit.

## 5. PHASE CHANGE — MAP REDESIGN: SCOPE ĐÃ CHỌN VS CHƯA CHỐT

### ĐÃ CHỌN

1. **TẠM DỪNG CODE gameplay, Combat, economy, Save, asset pipeline** sau PR31; preserve QA artifacts and worktrees.
2. **CHUYỂN SANG THIẾT KẾ / NGHIÊN CỨU MAP**, từ thực tế source và 19 screenshot của PR31.
3. Giữ baseline Source A hand-painted/sect-management, mobile landscape 1280×720, một world/camera family, camera tự do pan/zoom không khóa mãi một đệ tử, combat presentation đọc state thật.
4. Ưu tiên map đẹp hơn, có trật tự và có cảm giác tông môn đang sống; không làm lại gameplay đang PASS và không phá quy mô mở rộng dự kiến.

### CHƯA ĐƯỢC CHỐT — CẦN NGHIÊN CỨU, TRÌNH OWNER DUYỆT

- Chính xác vấn đề hình ảnh của 19 screenshots (độ đẹp, scale, bố cục, đất trống, độ dày foliage, visibility building, roads, bố trí HUD và actors); chưa có owner visual approval.
- Khu trung tâm/Đại Điện, cổng, khu cư trú, nơi luyện, khu sản xuất, sân công cộng, con suối, đồi/núi/hàng rào; chưa có approved full map layout mới.
- Tỉ lệ terrain, chiều rộng đường, footprint từng building, level of detail, tầm nhìn camera; so sánh theo gameplay và asset thực có.
- Phương án giữ GRID 192×192/chunk16/starter48 hay thay grid/district scale; **không thay chỉ vì số 192 có trong code**. Đo camera/perf/navigation và lập migration impact trước.
- LOD/culling/chunk mesh, collision và phân vùng spawn, giới hạn rendered actors so với roster 1,000–3,000 là kiến trúc cần đo, chưa được test stress.
- Làm thêm asset Source A hay chỉ sắp xếp bộ hiện có, nguồn master/hashes và license; mọi asset mới cần provenance/QA trước khi runtime.
- Xử lý map đường, cây, nước, terrain base, che khuất nhà và đệ tử, occlusion, selection footprints; không tự giả action animation.
- Map bên trong tông môn so với **bản đồ thế giới/bãi săn riêng**: đề xuất riêng ranh giới màn và camera, không lẫn vào CARE hunting world đang PASS.

**Đề xuất thứ tự nghiên cứu map (không phải lệnh CODE):**

M0 — **Audit baseline:** đọc source và render/capture PR31 (19 ảnh), đánh dấu lỗi scale, bố cục, camera, overlap, line-of-sight, trống/dày/chặn, UI, vị trí thực tế. Mọi nhận xét phải gắn ảnh/screenshot ID, không chấm dựa mô tả mơ hồ.

M1 — **Ba concept trên một bộ tiêu chí:** A giữ map gốc, cải thiện composition/terrain; B bố trí lại khu starter 48×48, kiến trúc rõ khu chức năng; C chia bản đồ lớn 192×192 thành các district (hub + kinh tế + tu luyện + ngoại vi) có đường xuyên suốt. Đánh giá theo Source A fidelity, actor/roof occlusion, tông môn sống, camera readability, map expansion, asset coverage, effort/cost, Godot 4.7.2 performance. Những phương án này là ứng viên để lựa chọn, không phải quyết định owner.

M2 — **Master layout blueprint:** phân bố khu, đường chính Cổng→Sân→Đại Điện, nhánh đến Kho/Mỏ/Linh Lâm/Linh Điền/Tu Luyện, lối đi actor, điểm spawn, clickable footprints, safe distance, camera focus; vẽ overview và 3 vùng cận cảnh ở kích thước có thể xem trên mobile.

M3 — **Art plan grounded:** xác nhận 32 MAP25 PNG và các assets đã có, gap map/terrain/road/water/deco/building; tách RESTORE / REUSE / PROPOSE_NEW / MISSING / REJECTED với SHA, evidence/ownership, chi phí chuyển đổi. Không xin Codex tạo fantasy asset suy diễn khi chưa nguồn.

M4 — **Implementation impact before permission:** trace \`SectIsometricWorldV1\`, \`SectIsoMapModelV1\`, Scene P3.2, camera, map25 SHA gate, jobs/worksite cues, navigation, actor overlay, Combat V5 view, canonical world state. Lập allowlist code/map data và regression plan; thiết kế adapter/migration visual map (nếu cần) nhưng không sửa live gameplay.

M5 — **Owner approval packet:** gói MD, mockups/sơ đồ A/B/C, existing-vs-proposed map, cost/risk matrix, recommended option và checklist chấp nhận. Chỉ sau khi owner chốt mới viết prompt triển khai CODE map mới trên branch cách ly; PR31 vẫn là rollback.

Map QA future proposal: 1280×720 image evidence actual Godot, 192×192/zone navigation as applicable, free camera pan + mouse drag + pinch, building click vs occlusion, realistic production path/worker, 32 Source A hash gate, gender actor map, P3.2 UI, O3/O9, CARE hunt + save, 8GB Windows baseline and Android physical later. Không dùng mockup để khẳng định code PASS.

## 6. Chính sách đóng băng / chống xung đột trong thời gian nghiên cứu map

- PR31 = **stable code checkpoint for focused tests**, **not merged into main**; DO NOT merge/rebase/force-push PR24–31.
- No simultaneous writers of \`godot/src/presentation/p3_2_landscape_sect.gd\`, \`sect_isometric_world_v1.gd\`, \`sect_map25_source_art.gd\`, \`sect_map_camera.gd\`, shared simulation/world/save, or MAP25 manifest. Nếu một phiên khác đề xuất CODE các file này, phải báo conflict trước.
- MAP DESIGN outputs nên commit vào nhánh docs mới tách từ PR31 (hoặc nhánh docs/map-redesign-checkpoint-20261024), chỉ tạo files dưới docs/; không sửa code/test/workflows/assets trong giai đoạn M0–M5.
- Không chạy FULL/CI, không âm thầm chạy build hoặc reset save; GitHub auto-push workflows có thể kích hoạt khi chạm path; giữ nguyên failure history.
- Giữ tất cả PR31 reports, focused CSV, evidence PNG, local Windows package metadata; không reset/clean local metadata .import, logs, archive hay người dùng.
- Không yêu cầu mobile manual QA bây giờ nếu owner muốn nghỉ; kết quả không biến thành PASS do thời gian trôi qua.
- Bất cứ thay đổi luật production, Combat, learner, CARE, save/loot, D7, nhân vật phải là packet CODE riêng với authorization riêng. Map là presentation/layout strategy trước.

## 7. Bàn giao cho cuộc trò chuyện map tiếp theo — copy-paste prompt

TÔNG MÔN BÁ ĐẠO — TIẾP QUẢN THIẾT KẾ LẠI MAP TỪ CHECKPOINT 24/10/2026. Trước hết đọc trên GitHub nhánh \`docs/map-redesign-checkpoint-20261024\`, file \`docs/handoffs/2026-10-24/TMB_MASTER_CHECKPOINT_PAUSE_PACKET_B_MAP_REDESIGN_2026-10-24.md\`, sau đó đối chiếu bản thật PR31 HEAD và 19 screenshots/evidence đúng SHA 4b02a0c. Không phát triển lại Combat, sản xuất, Save hoặc UI/gameplay đã PASS; giữ PR31 draft, không merge. Trong bước này chỉ nghiên cứu và thiết kế map: audit \`SectIsometricWorldV1\`/192×192/chunk16/starter48/MAP25, camera, 32 Source A assets, navigation, vị trí công trình và các gaps; đề xuất A/B/C có minh họa, master layout khu trung tâm–sản xuất–tu luyện–ngoại vi, art-provenance matrix, 1280×720 UX, tác động hiệu năng và kế hoạch chuyển đổi không phá gameplay. Commit docs thiết kế lên nhánh riêng từ PR31; không code, không thay asset, không viết renderer mới và chưa giả định chủ game đã duyệt layout. Đưa ra phương án có căn cứ để owner chọn.

## 8. Status cuối của checkpoint này

**FEATURE/COMBAT/PRODUCTION IMPLEMENTATION:** PAUSED at PR31 exact SHA.  
**PR31 ACCEPTANCE:** INTEGRATION_FOCUSED_PASS + AUTOMATED_GUI_PASS; OWNER_VISUAL / WIN_MANUAL / ANDROID / SUSTAINED_PERF PENDING.  
**MAP:** REDESIGN_RESEARCH_NEXT (design only; chưa khóa phương án).  
**GITHUB:** Docs-only checkpoint branch. Không thay runtime, không merge.  
**NEXT USER ACTION:** không bắt buộc làm gì ngay; khi tiếp tục chỉ cần dùng prompt trong mục 7. 
