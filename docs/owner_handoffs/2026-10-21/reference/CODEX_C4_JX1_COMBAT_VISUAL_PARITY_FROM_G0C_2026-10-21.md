# CODEX — TÔNG MÔN BÁ ĐẠO C4: SỬA COMBAT KHÁC JX1 TỪ CHỨNG CỨ CLIENT THẬT

**Giao việc:** 21/10/2026. **Ưu tiên:** thành phẩm visual/runtime thật, không lập kế hoạch suông.  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao`. **Nhánh kiểm tra Asset Forge:** `tools/af-jx1-player-forge-20261020`, commit nền đã kiểm tra `4dcb2daf01e6a14971b32131b7b69d7c67ae563f`. **Nhánh work/game có C4:** `work/playfirst-demo-max-v3-20261020`, mốc kiểm tra `aad7cec147e5df587ab13614e1c9ef2ac752a8d7`. **Không giả định main đã có các thay đổi này**; fetch HEAD mới nhất và xác định đúng branch/PR trước khi sửa.

## 1. Chỉ đạo của owner — điều bắt buộc

Owner có client + server JX1 đầy đủ ở máy Windows, các vùng làm việc chính `E:\Source` và `E:\Tool JX`. Mục tiêu là **phần nhìn/cảm giác đánh nhau giống Võ Lâm Truyền Kỳ 1**: map gốc, tỷ lệ nhân vật, trang phục/vũ khí nhiều lớp, animation 8/16 hướng, tư thế, cast/projectile/impact, quái/Boss thật, camera thả tự do, săn quái liên tục, mượt tại Android ngang 1280×720. Không nhầm việc 'có tên kỹ năng JX1' với 'đã tái hiện combat JX1'.

**D01 đã khóa:** Combat V2 tiếp tục giữ quyền tính damage, defense, hit/miss, critical, elemental/spiritual-root, RNG, cooldown, injury, loot, persistence và tiến trình đệ tử. JX1 là nguồn **visual + nội dung ID-backed**, không tự sao chép công thức damage/server. **D02/D03:** mục tiêu vùng săn quái liên tục + AI tự chọn mục tiêu và cast skill đã học; riêng thay đổi simulation/world/AI cần packet rõ ràng, không được ngầm sửa ở tác vụ *visual parity* này. Không chỉnh save, scheduler, economy, M1/M2/V-01 hoặc các gameplay luật khóa.

Owner đã xác nhận quyền sử dụng asset JX1/Source A do họ cung cấp. Không hỏi lại quyền. Giữ phân biệt chứng cứ file thực tế và giả định kỹ thuật; không gọi alias NPC là 'người chơi' nếu không có Kind/Part/Sect chứng thực.

## 2. Nguồn dữ liệu phải đọc

### 2A. Báo cáo G0C gửi ngày 21/10/2026

`G0C_AUDIT_2026-10-21.zip` (owner đã gửi trong hội thoại này). Trên Windows tìm bản báo cáo Codex đã xuất ở workspace của dự án **JX Web MOD** (ví dụ vùng `E:\codex\2026-10-21\...\outputs\G0C_AUDIT_2026-10-21`) hoặc yêu cầu file ZIP được đặt cạnh launcher nếu Codex không mở được file đính kèm. Không đoán thư mục nguồn nội bộ dựa vào basename; công cụ phải tự phát hiện trong `E:\Source` và `E:\Tool JX`.

Đọc lần lượt: `G0C_LOCAL_SOURCE_AUDIT.md`, `G0C_ASSET_SAMPLE_PLAN.md`, `catalog/asset_family_index.csv`, `catalog/boss115_sample.csv`, `catalog/skill_asset_mapping_sample.csv`, `catalog/dependency_presence.csv`, `catalog/root_summary.csv`, `QA/audit_log.txt`, và nếu cần `catalog/full_manifest_local.csv`.

**Những con số là chứng cứ STATIC, không phải runtime PASS:**

- Client `21.511` file / `15.941.790.074` byte; Server `315` file / `3.176.363.847` byte.
- Client có `17.544` `.spr` (~8,10 GB), `32` `.pak` (~7,65 GB). `data/maps.pak` = `91.776.706` byte; `data/spr.pak` = `738.486.991` byte, đều có header **`PACK`**. Phần lớn sprite/map vẫn cần giải mã; không có `.map/.mpc/.asf` rời được kiểm kê.
- `settings/maplist.ini` có **987 map ID**; `MapId=1`, tên `西北南区\凤翔`, chỉ là pilot giải mã bản đồ, **không khẳng định** là Thanh Trúc Lâm.
- `settings/skills.txt`: **1.406 SkillId số**, SHA-256 `59fc54e09ce50578c218e93318919069d6c7dba922fced7241b24f2cbcac10a9` (client chính). `settings/missles.txt`: **551 MissileId số**, `511` hàng có sprite ref. Chưa xác minh đủ SkillId → MissileId/child skill.
- Source nữ ghép layer: body `FM_BD_001/002`, weapon `FM_RW_001/002` và trạng thái ST/WK/AT. Các SPR tham chiếu có thể nằm trong PAK; join item `goldequip.txt` → layer player **PENDING**.
- **Boss 115 SPR rời, đã kiểm header `SPR\0` và hash:**
  - `spr\npcres\boss\boss115\boss115_st01.spr` — SHA `5E16DB353CF6BC81F41DB69000CC1253631A3E2CAF97804D22FEC91CFA562046`
  - `spr\npcres\boss\boss115\boss115_wlk.spr` — SHA `D9DF9B7C9688034E7BB84BE13C5E31B0E2CC03`
  - `spr\npcres\boss\boss115\boss115_at01.spr` — SHA `2B934D22FFBA3DDF34067B9142BB797DE97B724A29438150ADC43C5AAE745F6C`
  - `spr\npcres\boss\boss115\boss115_die.spr` — SHA `126016DA9A82A19F23BE1CE5199648C457D55EA85397FBE9DE92DFCE56912CDE`
- **Ba skill mẫu có PreCast SPR rời thật** (chỉ dạng asset candidate, chưa khẳng định tác dụng/tên kỹ năng):
  - SkillId `1584`: `spr\skill\magic\dark-cast.spr`, SHA `5A3D9C3536EF9A67F48BA050DD49B7E894FB89B2798D60EA19F6F81CCB0FE6A9`.
  - SkillId `1218`: `spr\spr moi\110_precast_ThienDia2.spr`, SHA `E7A8AF0E23D9DA115A4267FBE6B6A27B469B045C692AC97269A4677329AA8148`.
  - SkillId `1595`: `spr\skill\magic\thunder-cast.spr`, SHA `64FE63F58EE1C047A93578FF502FC9C546FCBBF74BE6A89B19A0A3CBDB56D75D`.
- Main Client và Server V3/V3.1 khác kích thước/hash settings; **không trộn bảng giữa phiên bản** nếu chưa có manifest compatibility. Không chạy game.exe, DLL, server ELF, QEMU hoặc Lua lạ để thử parser; chỉ đọc và chuyển đổi có kiểm soát.

### 2B. Đọc repo game đang dùng

- `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/C4_JX1_SOURCE_FIRST_WORLD_AND_FREE_CAMERA_2026-10-20.md` (đọc phần OWNER CORRECTION ở đầu, các mâu thuẫn bên dưới đã bị supersede).
- `godot/src/simulation/combat/map_battle_v2.gd`: 0,25s tick, ARENA 36×20 mặc định, `MAX_SECONDS=90` áp cho encounter không continuous; có **`continuous_world` opt-in**, không kết luận code hoàn toàn không hỗ trợ vùng liên tục.
- `godot/src/presentation/p3/map_battle_world_layer_v2.gd`: `draw_pilot_ground`, fallback `_draw_source_a_forest_floor`, `art_key=hero/wolf`, draw circles khi art fail; camera/snapshot interpolation/VFX.
- `godot/src/presentation/p3/combat_v4_sprite_atlas.gd`, `godot/assets/combat_v4/source_vl/atlas_manifest.json`: manifest hiện chỉ hai khóa actor `hero` và `wolf` với idle/run/attack/hit/die, không phải toàn bộ JX1 client 17.544 SPR.
- `godot/src/presentation/p3/combat_v4_effect_atlas.gd`, `godot/assets/combat_v4/jx1_skill_fx/fx_manifest.json`, `godot/data/presentation/c4_jx1_pres00_five_skill_asset_manifest.json`: VFX import một phần, các ID/chains chưa phủ kín.
- `godot/src/presentation/p3/combat_v4_jx_pilot.gd`: fixture 6v5, chưa phải bản săn quái thế giới liên tục. Các ID hiện tại ví dụ `jx_wudang_158`, `jx_wudu_63`, `jx_emei_93` **không được nối nhầm** sang các SkillId G0C `1584`, `1218`, `1595` chỉ vì tên gần nhau.
- `godot/src/presentation/p3/jxqy2_source_slice_v1.gd`: JXQY2 là nhánh nội dung khác JX1 PC; không dùng làm bằng chứng bản đồ/SPR JX1 PC.
- Các tool sẵn có trong `tools/asset_forge/` (AF-03/04 `jx1_pak_v2.py`, `jx1_adapter.py`, `jx1_tables_v2.py`, `jx1_player_pipeline_v4.py`; C5 `jx_combat_intake.py`, `QUET_SOURCE_COMBAT_JX1.cmd`). **Reuse, không viết lại cùng parser nếu đã có.**

## 3. Chẩn đoán bắt buộc trước khi code

Tạo bảng **JX1 client thật vs đang render ở Godot** với ít nhất 6 nhóm: map/terrain+collision; hero/equipment; NPC/monster/Boss; animation timing/pivot/foot anchor; skill cast/projectile/impact/sound; camera/viewport/culling. Mỗi hàng có: exact source path/asset ID/SHA, đường dẫn Godot hiện tại, bằng chứng, mức chênh và nguyên nhân, cách sửa, trạng thái. Không được dùng 'đã import skill' làm tương đương visual parity.

Lưu ý: `SOURCE_A_FLOOR`, `FOREST_A/B/C` là scenic fallback chứ không phải JX1 map. Renderer hiện chọn tất cả đệ tử `hero`, Thanh Lang/Hắc Lang/Hắc Lang Vương `wolf`; Boss còn được scale to nhưng vẫn chung art. Có fallback `draw_circle`; nếu asset fail sẽ trông như prototype. Các hiệu ứng JX1 chỉ là subset event-mapped; chưa chứng minh đường đạn và cast timeline là nguyên bản. Trong fixture `MapBattleV2` vẫn bước 0,25s/arena, dẫn đến nhịp có thể khác JX1 khi animation mapping chưa đầy đủ.

## 4. Công việc triển khai — một vertical slice JX1 TRƯỚC, không làm cả kho

### A — Khoá baseline nguồn và lập catalog có chứng cứ

1. Kiểm tra và đánh dấu thư mục nào trong `E:\Source`, `E:\Tool JX` là root Client thật; không mặc định hai root cùng định dạng. Read-only scan có giới hạn, bỏ qua symlink/reparse, không chạy binary. Ghi root alias (không ghi private path lên repo nếu có sensitive segments), SHA selected files, version conflicts.
2. Xác minh bảng skills/missles/npcres và các PAK thực tế, đối chiếu SHA G0C. Nếu khác nguồn, lập biến thể `G0C_BASELINE_MISMATCH`, tuyệt đối không lặng lẽ trộn.
3. Tạo `JX1_COMBAT_PARITY_GAP_MATRIX.csv/json` và `JX1_COMBAT_SOURCE_SELECTED_MANIFEST.json` có trạng thái rõ: `FILE_VERIFIED`, `PACK_ENTRY_VERIFIED`, `SPR_DECODED`, `ANIMATION_RENDERED`, `GODOT_VERIFIED`, `PENDING`.

### B — Giải mã pilot thật an toàn (chỉ file chọn lọc)

1. Dùng AF-04 PACK signature `PACK`, filename-hash, metadata/SPR parser sẵn có. Giải mã **1 SPR rời boss115** đầu tiên, lập contact sheet 8/16 hướng, kiểm alpha, frame count, delay, foot anchor; xuất WebP lossless atlas + JSON rect/pivot/duration/source SHA. Không gọi thành công nếu parser chỉ đọc header.
2. Nối theo source Kind/Part/Sect **một nhân vật chính + thân + (nếu chứng minh được) trang phục/vũ khí**, một action `stand/walk/attack`. Nếu chưa xác định join thật, xuất catalog với trạng thái PENDING, không tô vũ khí bất kỳ lên hero.
3. Đọc index `data/maps.pak`, trích chỉ 1 entry map theo ID có chứng cứ; định dạng geometry/tiles/objects/collision phải giải mã và xác minh trước khi dùng trong pilot. `MapId 1` dùng để chứng minh parser, không đồng nhất với khu vực Thanh Trúc Lâm. Nếu chưa giải mã được, trình bày rõ `MAP_JX1_PENDING` thay vì sử dụng nền Source A mà gọi là JX1.
4. Thử 1 skill PreCast rời trong nhóm `1584`, `1218`, `1595`; nối missile/child chain bằng ID và nguồn đồng phiên bản; chưa hiểu field/runtime thì chỉ preview clip, không gán nhãn 'đã có projectile/AoE thật'.

### C — Tích hợp hiển thị Godot như JX1

- Trên **nhánh riêng** từ HEAD tích hợp hợp lệ, ưu tiên file presentation/asset importer/manifest/test; không sửa `MapBattleV2`, CombatStatsV2 hoặc save. Không đổi gameplay để làm đẹp.
- Render nền/map JX1 thật, foreground occlusion và actor depth theo chân; camera kéo bằng chuột/touch, không auto-follow khi chưa chọn actor; pan/zoom vẫn giữ đúng map world coordinates.
- Thay **generic hero/wolf art-key** bằng actor visual ID có chứng cứ, có bảng animation per-character/species, ít nhất stand, walk, attack, hit, die. **Boss115 không được giả định là Hắc Lang Vương**; pilot hiển thị `boss115` đúng tên/asset nếu sử dụng.
- Equip layers/skins: theo chính bảng Kind/Part/Sect, hướng và sort `Dir1..Dir16`/frame overrides, giữ foot pivot, sprite anchor; không dán một sprite toàn thân thay cho trang phục nhiều lớp mà báo 'JX1 parity'.
- FX: V2 event → content mapping (cast, missile spawn/flight, impact, hit, death), không phát FX trúng đích khi V2 báo miss; dùng pooled draw commands/atlas cache, giới hạn hiệu ứng che tầm nhìn mà không bỏ sự kiện authority. Âm thanh chỉ map khi asset thật được chứng minh.
- UI/HUD JX1-inspired phải nhìn rõ tại 1280×720, hạn chế text che chiến trường. Không xây lại renderer nếu có thể sửa các adapter hiện hữu; tránh dồn tất cả khung hình/layer vào một node `_draw()` gây vòng lặp lớn.

### D — Kiểm thử hiệu năng có số liệu

- Chạy **focused** parser/unit với fixture + binary thật đã chọn: hash, frame count, alpha, multi-direction, invariant sort, stage/dedupe/pack SHA.
- Godot 4.7.2 Windows 1280×720: screenshot/video **trước-vs-sau** cùng camera và đội hình; cùng một đoạn 30–60s quan sát chuyển động, không chỉ một ảnh.
- Công cụ hiển thị frame-time CPU/GPU, FPS median/p95, draw calls, texture/atlas memory, số actor/FX đang vẽ, cache hit/miss, pause spike và chi phí lần load đầu; thử pilot 6v5 rồi fixture cực đại **30 đệ tử + 40 quái**. Báo thông số thực tế/thiết bị/driver, không gắn PASS chỉ vì một frame đẹp. Android landscape 1280×720 vẫn PENDING nếu chưa có máy thật.
- Không full scan/hàng loạt giải nén/copy PAK 7,65 GB, không chạy CI/FULL/merge, không đụng client/server nguyên bản, không thêm game combat formulas hay auto farm gameplay trong packet visual.

## 5. Deliverables bắt buộc để owner có kết quả xem được

1. `C4_JX1_G0C_GAP_REPORT_2026-10-21.md` — giải thích **vì sao trước đây khác JX1** và các nguyên nhân đã thật sự sửa.
2. `JX1_COMBAT_PARITY_GAP_MATRIX.csv` và `JX1_COMBAT_SOURCE_SELECTED_MANIFEST.json` — ID/hash/file evidence/target scene.
3. **Một pilot có thật**: 1 map JX1 có nguồn xác minh *nếu giải mã được*, 1 nhân vật trang bị *nếu nguồn đủ*, 1 Boss/monster (`boss115` nếu cần), 1 skill VFX thật; cùng contact sheet, rect/pivot JSON, Godot preview/video.
4. `C4_JX1_G0C_FOCUSED_QA.md` — log/test/ảnh/video, chính xác từng PASS/PENDING, lỗi/giới hạn. Có thể gửi ZIP nhẹ gồm manifests, code diff và hình/video preview, không đóng gói cả client.
5. GitHub commit/draft PR trên branch thích hợp **chỉ khi code thật đã hoàn thành và focused tests đạt**; không CI/FULL/merge. Handoff cập nhật theo repo. Nếu quyền/asset/renderer hạn chế, ưu tiên hoàn thành ít nhất converter Boss115 và manifest đúng, không báo game đã giống JX khi chưa có runtime evidence.

**Câu lệnh bắt đầu cho Codex:** Tự tiếp quản từ tài liệu này; làm ngay trên Windows và GitHub theo thứ tự A→B→C→D. Không hỏi owner lại quyền dùng asset và không yêu cầu phê duyệt từng bước. Tuyệt đối trung thực nếu JX1 PACK/SPR/map chưa decode hoặc visual chưa thể kiểm chứng.
