# TÔNG MÔN BÁ ĐẠO — PR #28 UI + WORKER ASSET INTEGRATION PACKET
Ngày: 2026-10-24
Trạng thái: OWNER-AUTHORIZED SCOPE / IMPLEMENTATION BY CODEX PENDING
Ưu tiên: Tích hợp asset hiện có vào gameplay thực tế, không vẽ mockup độc lập và không thay renderer.

## 0. Kết luận và quyền quyết định mới nhất

Owner đã mở rộng phạm vi UI PR #28: ngoài sửa layout, **được tích hợp những asset đã được worker xử lý** vào map, production, hồ sơ D7 và trình diễn Combat V5 của scene P3.2. Đây là **override có giới hạn đối với ràng buộc 'không chạm Source A/renderer' trong prompt PR #28 cũ**: cho phép cập nhật asset registry/manifest và adapter/presentation tối thiểu, KHÔNG cho phép thay renderer, combat gameplay hay các hệ thống authoritative.

Bắt buộc dựa trên code, screenshot thật và manifest. **Không giả định mọi output của worker đã ở trên GitHub hoặc đã đủ chất lượng**. Nếu asset mới chưa có bản xuất, cần phát hiện và kiểm kê ở nguồn worker/local được owner cấp quyền; gắn những asset thực sự có thể xác minh; báo danh sách còn thiếu, không dựng asset giả.

**Tách quyền sở hữu:**
- PR #28 / chat UI: presentation P3.2, mapping asset Source A, atlas, manifest, animation playback ở tầng visual, tests/ảnh QA.
- Chat Combat V3 độc lập: HP, ATK, DEF, skill, Boss pacing, cân bằng x100 — KHÔNG sửa hoặc cherry-pick ở đây.
- SimulationState, Combat V2, B3 CARE, Warehouse, SaveService, Recruitment D7, Injury120, scheduler, economy là authority giữ nguyên.

## 1. Baseline SHA / nhánh / thứ tự đọc

- Repo: vuanhtuan161094-byte/TongMonBaDao.
- Main HEAD đã kiểm tra khi soạn packet: 29b5fba448b0178cb520a4ada44b375b4b934e31 (chỉ để truy vết, KHÔNG đổi base).
- PR #26 head: 53ff0b223f4e77ccfbe5c77d2203496ac0cc37a9.
- PR #27 head: deeae081bcfbe1413d4cf60a29db7e58150888b5.
- PR #28 UI branch: ui/pr27-runtime-readability-20261024; audited code/doc head trước packet: 1cdbe715bf89e3bb297b2d9c3aac273221be887d.
- Codex phải fetch PR #28 HEAD thực tế khi bắt đầu, ghi HEAD trước/sau, tuyệt đối không checkout main rồi chép đè.
- Engine chính thức: Godot 4.7.2; Android landscape UI baseline: 1280x720.
- Không merge PR #24/#25/#26/#27/#28; không FULL/CI nếu chưa có lệnh riêng.

**Authority bắt buộc:**
1. AGENTS.md; docs/GAME_SYSTEM_ARCHITECTURE.md; CURRENT_CHECKPOINT.md; NEXT_CHAT_HANDOFF.md.
2. .agents/skills/tmb-project-director/SKILL.md, .agents/skills/tmb-ui-playtest/SKILL.md, .agents/skills/tmb-asset-gate/SKILL.md.
3. docs/P3_ART_BIBLE.md; docs/P3_2_ASSET_MANIFEST.md; docs/P3_2_MODULAR_ACTOR_SPEC.md; docs/P3_ASSET_REGISTRY.json.
4. docs/handoffs/TMB_MASTER_V3_IMPLEMENTATION_REPORT_2026-10-24.md; TMB_MASTER_V3_UI_ISSUE_MATRIX_2026-10-24.md; TMB_CHATGPT_SUMMARY_PACKET_2026-10-24.md.
5. docs/handoffs/TMB_PR27_UI_RUNTIME_PASS1_REPORT_2026-10-24.md và packet này.
6. Source/runtime thực tế; manifest/asset SHA; test hiện tại. Tài liệu thiết kế cũ không ghi đè owner override mới.

## 2. Hiện trạng Source A ĐÃ quan sát trên GitHub

**Đã có trong tree PR #28**:
- godot/assets/actors/ có **7 thư mục**:
  1113028_1, body_1110201, body_1120402,
  v5_sa_boss_410041_1, v5_sa_female_1113028_1,
  v5_sa_male_body_1110201, v5_sa_monster_1113031_1.
- godot/src/presentation/p3/disciple_source_a_visual_pool.gd có 3 rig bản đồ whitelist theo giới tính: nữ 1113028_1, nam body_1110201 và body_1120402. Có fallback khi scene không hiện diện.
- godot/assets/combat_v5_source_a/visual_manifest.json có keys disciple_female, disciple_male, monster_1113031_1, boss_slot_410041_1. Boss-slot là dữ liệu trình diễn, **không phải bằng chứng CARE đang phát Boss thật**.
- godot/src/presentation/p3/combat_v5_source_a_atlas.gd đọc actor packs theo manifest và các clip stand/idle, walk/run, attack1/attack, hit, dead/die.
- godot/src/presentation/p3/sect_map25_source_art.gd đọc SHA whitelist từ godot/data/presentation/map25_source_a_verified.json; test sect_map25_verified_art_gate_test.gd hiện kỳ vọng **32 ảnh** được kiểm kê.
- godot/data/presentation/source_a_candidate_manifest.json chứa building candidates, nhưng vài mục ghi CANDIDATE_NOT_APPROVED / binary_imported=false. **Candidate metadata KHÔNG tự động là approved runtime asset**.
- godot/src/presentation/p3/b3_care_combat_v5_presenter.gd đã có real Source A visual và camera/VFX adapter. Giữ nguyên renderer, camera free/follow và hướng ưu tiên visual.
- Branch sa-lib-01-sourcea-spine-library-20261021 tồn tại; là nguồn điều tra, không ngầm coi là merged.
- Các báo cáo lịch sử có nhắc thư viện Spine chuyển đổi nhiều clip/atlas, nhưng **số lượng đó không được coi là asset đang sẵn trong PR #28**, phải xác nhận lại bằng manifest+file thật.

**CHƯA xác nhận trong GitHub**: toàn bộ các file asset MỚI 'worker vừa làm', đường dẫn output worker mới nhất, trạng thái clip/atlas và độ hợp lệ của từng binary. Source PR #27 ZIP chỉ là ảnh/log/evidence, không tự coi là gói worker assets. Nếu asset mới chỉ ở local, ghi cả absolute path + SHA + ngày output; không giả tạo tên/path.

## 3. Gate G0 — Discover / compare / provenance (bắt buộc trước import)

1. Kiểm kê các nguồn theo thứ tự:
   (a) PR #28 current tree và manifests;
   (b) nhánh Source A chuyên dụng như sa-lib-01, các worktree/staging outputs đã được người dùng tạo trước đó;
   (c) gói xuất/manifest của worker ở workspace local được quyền truy cập;
   (d) các Drive/project nguồn mà Codex thực sự được cấp quyền đọc.
   Không dò dữ liệu cá nhân ngoài vùng dự án; không giả vờ truy cập nơi không có quyền.
2. Xuất CSV hoặc JSON catalog cho TẤT CẢ candidate thực sự tìm thấy: source_path, source_branch/commit, asset_id, category, sex/species, player/NPC/monster/building, source hash, exported hash, clip inventory, direction, frames/FPS, canvas/pivot/footpoint, transparency, texture size, atlas pages, import status, QA verdict, target mapping, reason if rejected.
3. Chia bốn trạng thái: PRESENT_VERIFIED, CANDIDATE_NEEDS_QA, MISSING, REJECTED. Có cột EXISTING_IN_PR28 để skip asset trùng hash; không viết lại file/atlas đã đạt.
4. Đọc từng asset.json/animations.tres/actor.tscn và đối chiếu file_sha256 trước khi tham chiếu scene. Soi ít nhất first/middle/last frame và contact sheet mỗi clip. Kiểm tra không mất alpha, sai pivot, ngược hướng, thiếu sprite, rig đứng trong suốt, bất thường scale và clip không đủ frame.
5. Phân biệt rõ rig player, NPC, monster, boss-slot; không dùng NPC/quái làm đệ tử có môn phái nếu không có mapping hợp lệ. Không lấy ảnh/chibi fanmade khác phong cách.
6. Nguồn quyền đã được owner cho phép sử dụng trong dự án cá nhân, nhưng phải giữ source hash, provenance và cảnh báo về phân phối lại. Không commit original .skel/.atlas/.json/source bundle nếu pipeline trước đó chỉ cho phép output đã chuyển đổi; không đặt riêng asset chưa được phép công bố lên kho công khai.
7. **G0 output**: WORKER_ASSET_DISCOVERY.csv, WORKER_ASSET_DIFF.md, contact sheets, candidate allowlist. Ghi rõ đếm asset found / new / skipped / pending / rejected. Không PASS nếu mới chỉ tìm thấy tên file.

## 4. Gate G1 — Asset import tối thiểu, dùng pipeline có sẵn

- Không tự viết lại Spine renderer hoặc làm 1 pipeline mới. Dùng converter/manifest/hash/import hiện có; mỗi batch 1–2 rig hoặc một nhóm building/icon nhỏ để phù hợp máy 8GB RAM.
- Converted-only outputs: scene, SpriteFrames/atlas WebP, asset.json, nguồn hash/provenance/manifest, tùy loại có .import. Kiểm soát lặp SHA; không đưa file trung gian dư thừa vào repo.
- Ưu tiên các file đã có runtime contract, không phá scene cũ. Nếu bị thiếu atlas đầu vào thì skip + ghi MISSING, không tăng phiên bản logic hoặc fake fallback.
- Đối với original PNG MAP25, giữ nguyên SHA gate. **Không cập nhật hash whitelist chỉ để ép một bản khác qua test**; asset mới phải là mapping/entry có provenance được duyệt riêng, và test tương ứng. Không biến 32 ảnh locked thành số khác bằng cách sửa test cũ.
- Không commit binary cỡ lớn vượt chính sách Git hoặc gây import Android bất thường; nếu cần transport/LFS, đóng gói ở nguồn được owner phép và chỉ tham chiếu manifest khi thật sự khả dụng.
- Mỗi category phải chạy thử Godot import ở TEMP isolated profile, lấy screenshot và kiểm tra warning/parse error/transparent frames.

## 5. Gate G2 — Tích hợp có thứ tự vào gameplay P3.2 THẬT

Thứ tự ưu tiên có điều kiện: chỉ triển khai category có asset **PRESENT_VERIFIED**; thiếu asset mới thì giữ cũ và báo PENDING. Không yêu cầu thay mọi thứ cùng lúc.

### A. Main map / building / môi trường
- Giữ SectIsometricWorldV1, Map25 world renderer, transform, z-order, camera pan/zoom, collision/pick, hitbox và coordinates gốc.
- Gắn thêm building/terrain/vegetation/ground/ambient Source A đã xác thực đúng asset_id => building type/instance_id canonical. Không tạo building gameplay mới. Không thay đất/nền thật bằng panel mockup.
- Giữ màn hình sạch: không che actor/action, giảm haze/VFX che cảnh, không phát animation giả. Kiểm tra layer tree foreground/actor/roof và scale tại zoom 0.75/1.0/1.35/1.80 nếu thuộc range thực tế.
- MAP25 source whitelist cũ không bị re-hash tùy tiện.

### B. Mine / Linh Lâm / Linh Điền / worksite
- Dùng ảnh nhà/cây/ore/field đã verified; giữ một đối tượng canonical theo BuildingState. Thẻ tiến độ luôn đọc từ state, worker/job thật và Warehouse settlement.
- Rõ ID công trình, worker active/chờ, %/ETA, sản lượng dự kiến, sản lượng **đã nhập Kho** và sự kiện receipt, không cộng stock bằng animation.
- Nếu clip mining/chopping/planting thực tế không tồn tại hoặc không match actor và role thì giữ stand/walk/di chuyển thật. **Tuyệt đối không giả hành động đào/chặt/trồng** bằng clip tùy tiện.
- Bổ sung icon progress/receipt nếu có asset verified, không để animation cản thao tác nút.

### C. Nhân vật đệ tử / hồ sơ D7
- Tích hợp rig playable Source A đã verified theo giới tính và mã visual seed; đảm bảo stable selection/save-load, fallback cho cả nam và nữ. Không gán female làm male, monster làm disciple.
- D7 radar 7 trục vẫn là dữ liệu canonical Tam Căn/Tứ Tính; có thể dùng khung/chất liệu nền, icon thật đã verified nếu tăng độ đọc. Không thay bảy chỉ số bằng texture biểu diễn sai.
- Nếu worker tạo portrait chất lượng hơn, chỉ sử dụng khi asset được xác minh đúng nhân vật/giới tính/format, không làm UI giả quality/bloodline unrevealed.

### D. Combat V5 / HUD CARE
- Đưa thêm clip attack/hit/dead/walk/stand/VFX Source A đã verified vào adapter hiện có; battle time, hit, dodge, cast, damage, reward, injury vẫn từ **Combat V2 / CARE authoritative snapshot**.
- Quái pilot vẫn là canonical Thanh Lang; asset monster theo mapping species_id. Không cho Boss-slot 410041_1 xuất hiện như Boss live khi B3 CARE không cấp event.
- Ưu tiên giảm số damage/VFX bị chồng actor; không xóa damage event/receipt hay tăng/sửa battle timestep. Giữ click/tap camera free và follow đúng quy tắc.
- Nếu không có clip cast/hit/dead hợp lệ, fallback chính xác về animation cũ và ghi MISSING. Không làm lại renderer để phục vụ asset.

### E. UI skin/interaction
- Chỉ dùng atlas/panel/button/icon có xuất xứ phù hợp art bible, alpha sạch, color contrast đạt; 9-slice hợp lệ tránh giãn họa tiết.
- Với bản UI PR28 đã chỉnh, giữ minimum touch target ~44px, font Việt dễ đọc ~14–16px, trạng thái nút selected/disabled/hover và bố cục 1280x720.
- Không hardcode số liệu gameplay lên texture: counters, label, quality, worker, loot luôn phải là state thật.

## 6. Allowlist sửa code và dữ liệu trong packet mới

**Cho phép ở đúng nhánh PR #28**:
- godot/src/presentation/p3_1_landscape_sect.gd
- godot/src/presentation/p3_2_landscape_sect.gd
- godot/src/presentation/p3/disciple_source_a_visual_pool.gd
- godot/src/presentation/p3/disciple_actor_visual_catalog.gd (CHỈ presentation mapping)
- godot/src/presentation/p3/sect_isometric_world_v1.gd (CHỈ visual mapping, không thay camera/collision)
- godot/src/presentation/p3/sect_map25_source_art.gd (chỉ non-breaking asset lookup, giữ SHA gate)
- godot/src/presentation/p3/sect_production_worksite_cue.gd
- godot/src/presentation/p3/disciple_six_dimension_radar.gd
- godot/src/presentation/p3/combat_v5_source_a_atlas.gd
- godot/src/presentation/p3/b3_care_combat_v5_presenter.gd (CHỈ visual adapter/overlap khi thật sự cần, không viết lại)
- godot/src/presentation/assets/ (catalog-only adapter, nếu cần)
- godot/assets/actors/ (chỉ verified converted assets, không overwrite legacy)
- godot/assets/combat_v5_source_a/visual_manifest.json (chỉ mapping verified)
- godot/art/source_a_env02a/ (chỉ provenance-verified mapping, giữ existing)
- godot/data/presentation/ (new verified manifest entries; không đổi hash cũ thiếu căn cứ)
- godot/tests/presentation/ và test asset import/render liên quan trong godot/tests/
- docs/handoffs/ và tài liệu asset manifest mới liên quan.
- outputs/ riêng trong Codex worktree: ảnh screenshot/manifest/QA log; **không commit log/binary hàng loạt ngoài hướng dẫn repo**.

**TUYỆT ĐỐI KHÔNG CHO PHÉP**: src/simulation/**; runtime world/clock; CombatStatsV2, MapBattleV2, B3 CARE, D7 generator/odds, Injury120, medicine/satiety, Warehouse, SaveService, authoritative scheduler, economy, battle RNG; không thay state schemas, UI scene chính, preload nguồn JX không được xác minh, hoặc test hiện hành để biến FAIL thành PASS. Nếu thật sự cần sửa path ngoài allowlist thì ghi BLOCKED và xin owner cấp phép riêng, đừng tự mở rộng.

## 7. Gate G3 — Regression và engine-rendered evidence

- Trước mọi code mới: capture/log PR #28 đúng HEAD bắt đầu (để xác định có parse/runtimes FAIL đã tồn tại; không dùng screenshot của PR #27 làm after của PR #28).
- Godot official 4.7.2, 1280x720, isolated user:// mỗi lượt; import/parse cho toàn bộ asset mới, không lấy editor thumbnail thay screenshot game.
- Chạy test mới tmb_pr27_ui_readability_test.gd và các focused liên quan: p3_2_map_camera_test, dv2_03_p3_v2_disciple_profile_test, sect_g1_disciple_radar_test, sect_map25_verified_art_gate_test, sect_iso_main_integration_test, b3_care_combat_v5_presenter_test, b3_main_hunt_integration_test, p3_o9_m2_production_rehearsal_test, d7_foundation_v3_migration_test và test Source A scene/import. Danh sách CLI thật xác minh theo repo trước khi chạy.
- Ưu tiên giữ nguyên tập **20 focused** đã chứng minh ở PR #27; chạy lại những bài impacted theo thiết kế. Bản trước có lần đầu O9 **19/20 FAIL**, sạch userdata **20/20 PASS** nhưng chưa xác nhận root cause. Giữ log FAIL/PASS riêng biệt, không đổi test để làm xanh.
- Check input mouse pan/wheel/right drag, double-tap/pinch nếu giả lập có thể tin cậy, focus free/follow, zoom và không đè tap khi panel hiện. Physical Windows/Android chỉ PASS với chứng cứ thiết bị thực.
- Screenshot trước/sau bắt buộc: overview map, map zoom, Mine idle/running/settled, Linh Lâm, Linh Điền, selected worker panel, D7 profile nữ/nam, CARE idle/hit/skill/loot-receipt, màn return. Mỗi ảnh liên kết code HEAD SHA, Godot version, kích thước/seed/tick/canonical IDs (cái không ghi được thì UNKNOWN). Với Injury120 chưa có frame thì giữ PENDING.
- Review visual: clipping/trùng panel, chữ Việt dấu, tone Source A, sprite player đúng sex, footpoint/shadow, scene alpha, FPS/memory/load time trên PC 8GB; Android compression/touch nằm ở PENDING nếu không có thiết bị.
- Save/load: cùng actor visual selection, canonical Warehouse and paid_generation exactly-once. Asset fail/missing không ngăn load save hoặc phá game.
- Nếu regression thực: rollback riêng category asset fail hoặc fix trong allowlist, rerun focused; không sửa gameplay để chữa lỗi visual.
- KHÔNG tuyên bố UI/UX hoàn tất, visual owner PASS hoặc Android PASS khi chưa có bằng chứng. KHÔNG FULL/CI và KHÔNG merge.

## 8. Output contract Codex

Bàn giao trên **nhánh PR #28** và link trực tiếp (không chỉ local E:/):
1. docs/handoffs/TMB_PR28_UI_ASSET_INTEGRATION_REPORT_2026-10-24.md: inventory found/new/skip/reject/missing, mapping per category, thay đổi code SHA và nguồn quyền/hash, rủi ro.
2. docs/handoffs/TMB_PR28_UI_ASSET_ISSUE_MATRIX_2026-10-24.md: mỗi issue MAP/PRO/PROFILE/COMBAT, status REAL_RUNTIME_PASS / REPRO_FAIL / PENDING_OWNER / BLOCKED_ASSET.
3. Manifest CSV/JSON của asset worker, cùng manifest code integration và snapshot before/after; nêu định vị cụ thể asset mới đã dùng trong game.
4. Screenshot engine thật 1280x720 trước/sau và log import/focused/perf; có link/path có thể mở được. Không gửi mockup tĩnh rồi gọi after.
5. Checklist QA: test/exit code/PASS marker/script errors/known prior FAIL, O9 log ban đầu và rerun giữ tách biệt.
6. Dòng cuối: HEAD SHA, PR URL, 6–12 vấn đề thực tế đang mở (nếu có), PENDING USER/OWNER. Tạo commit thường, giữ DRAFT; không merge.

Nếu đầu vào asset worker chưa có hoặc không được quyền truy cập: vẫn hoàn tất QA UI existing PR #28; tạo catalog MISSING với locator và hash cần bổ sung, không chặn các category đã verify. Không hỏi owner lặp lại quyền sử dụng Source A đã cấp.

## 9. Điều kiện cuối

**Mục tiêu thật**: asset worker chuyển đổi được gắn vào đúng scene và người chơi có thể nhìn thấy map/công trình/nhân vật/combat rõ hơn, đồng thời gameplay canonical không đổi.

**Không chấp nhận**:
- 'Converted' nhưng không xuất hiện runtime;
- asset xuất hiện nhưng sai giới tính/loài, sprite mất frame, ghép sai pivot;
- kho/reward/injury/HP/số liệu HUD fake;
- giả animation đào/chặt/trồng hoặc fake Boss live;
- screenshot Photoshop/mockup thay Godot;
- hạ test assertion, ghi đè known FAIL, merge PR.

**Ưu tiên tối thiểu để nhanh có màn chơi đẹp hơn**: (1) verified map/buildings/worksite, (2) verified disciple idle/walk/profile, (3) verified combat clip/VFX adapter, (4) UI icons/skins. Không mở asset batch khổng lồ làm máy 8GB treo.

## 10. Hướng dẫn rollback / concurrency

- Nếu thêm pack gây crash/lag/opacity bất thường: revert asset mapping mới theo từng category, giữ fallback cũ; KHÔNG revert simulation hoặc sửa save để chữa UI.
- Giữ nhánh PR #28 là writer duy nhất với presentation files đã liệt kê. Chat Combat V3 không được đồng thời commit các file này.
- Commit nhỏ, đúng một category mỗi lần; trước và sau mỗi batch ghi hash + focused gate. Khi worker asset vẫn tiếp tục ra lò thì chỉ nhận output đã đóng dấu fingerprint; batch đang chạy không được nhặt giữa chừng.
