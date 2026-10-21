# CODEX — TÔNG MÔN BÁ ĐẠO: CHỐT SOURCE A / PHỤC HỒI COMBAT V5 (P0 → P2 CÓ ĐIỀU KIỆN)

**Ngày:** 2026-10-21  
**Trạng thái:** LỆNH GIAO CÔNG VIỆC CHO CODEX, CHƯA THỰC THI TRONG CHAT  
**Bắt buộc đọc:** file đính kèm `TMB_SOURCE_A_COMBAT_V5_PROJECT_AUDIT_ROADMAP_2026-10-21.md` trước khi hành động.

## 0. Owner decision — tuyệt đối không tranh luận lại

**Phong cách game cuối cùng: Source A chibi tu tiên 2.5D** cho sect + world + combat. DỪNG pixel/King God Castle A/B; DỪNG yêu cầu port nguyên JX1 combat/mỹ thuật. **Combat V2 là authority**, chỉ build pipeline asset/renderer/visual adapter để ra bản demo hình ảnh chiến đấu Source A thật và mượt. Giữ mã/asset 5 skill JX1 pilot để tùy chọn tái sử dụng VFX/logic hợp lệ, không xóa và không biến JX1 thành chuẩn mỹ thuật. Không tự thêm kỹ năng/damage/mana/XP mới.

Godot **4.7.2** / Android landscape **1280×720**. One Active Job, Injury 0/1/120 tick, canonical Warehouse, 30 Tu Vi ×10 và 30 Luyện Thể ×10, 6 đệ tử/đội, ≤30 trong cụm, long-term scalability. Bảo toàn save/offline exactly-once và không cho visual tạo hit/loot giả.

## 1. Máy và dữ liệu của owner

- **Source A:** `E:\TongMonBaDaoWorkspace\02_SourceA\GameAssetExtract`.
- **Converter đã chạy:** `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472`; launcher `E:\TongMonBaDaoWorkspace\MO_CONG_CU_SPINE.cmd`.
- **Godot-ready output hiện có:** `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472`.
- **Godot runtime:** ưu tiên `E:\Godot_v4.7.2-stable_win64_console.exe`, verify binary/runtime thật.
- **Project output mới (chỉ derivative/report):** `E:\TongMonBaDaoWorkspace\05_DauRa\CombatV5_SourceA_Pilot`.
- **JX1 client/server (`E:\Source`, `E:\Tool JX`) chỉ giữ để tra cứu skill khi cần**, KHÔNG quét/chuyển lại toàn bộ JX1 trong task này.
- **Source A catalog GitHub:** `vuanhtuan161094-byte/ZQZS-Source-Knowledge`, dùng bảng đã có; không full-scan ~157.607 file nếu không có chứng cứ catalog sai.
- Máy khoảng 8 GB RAM, không nâng RAM; mọi thao tác tuần tự, batch rất nhỏ, cache imports. **Không dùng Windows Administrator hoặc ghi vào `C:\Users\Admin`.** Không sửa/ghi đè input, không tự xóa kho cũ.

## 2. Repo/ref; kiểm lại HEAD khi bắt đầu

`vuanhtuan161094-byte/TongMonBaDao`

- `main` observed `461caca1171462e0da092f21108c5c1733157ad9` (KHÔNG baseline đầy đủ).
- G1 PR20 `g1-disciple-radar-sourcea-pool-20261017` observed `2219535fc3519ce811265ceed5cb85001efe5e45`.
- **Baseline ưu tiên:** `work/playfirst-demo-max-v3-20261020` observed `aad7cec147e5df587ab13614e1c9ef2ac752a8d7`. Gồm G1+MAP25+DEMO/C4/JXQY2. Đừng clone `main` rồi tái tạo UI cũ.
- Asset Forge là **nhánh khác** `tools/af-jx1-player-forge-20261020` observed `4dcb2daf01e6a14971b32131b7b69d7c67ae563f`; không cherry-pick tất cả vào runtime.

Đọc đúng thứ tự `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/P3_PRESENTATION_MASTER.md`, `docs/P3_ART_BIBLE.md`, `docs/P3_SOURCE_A_ANIMATION_ASSET_UI_UX_HANDOFF_2026-10-17.md`, `docs/P3_2_MODULAR_ACTOR_SPEC.md`, `docs/MAP25_SOURCE_A_ORIGINAL_ASSET_RECOVERY.md`, `docs/G1_SOURCE_A_WORK_ACTION_MINIMAL_PACKET_2026-10-17.md`, `docs/C4_G1_MAP25_COMBAT_INTEGRATION_QA_DEBTS_2026-10-19.md`, `docs/M2_JXQY2_LOCAL_SLICE_QA_2026-10-20.md`, `docs/COMBAT_SKILLS_V2_SPEC.md` và manifest/rig thật. **HEAD/cmd có thể thay đổi; ghi HEAD mới nhất bạn kiểm được.**

## 3. Việc phải làm ngay — P0 audit read-only (không chờ xác nhận)

1. Dùng checkout/clone riêng trên E: và save cách ly, đọc repo current. Lập bảng source-of-truth: G1 MAP25, Economy V2, Disciple V2, C4/DEMO, Source A assets, JX skills, Asset Forge; mỗi dòng `code_present / imported_asset_verified / official_Godot_focused / GUI capture / Android / owner_accepted`.
2. Đối chiếu file thực: `godot/assets/actors/1113028_1`, `body_1110201`, `body_1120402`; `godot/art/source_a_env02a`; demo launcher; `MapBattleWorldLayerV2`; real hunting; camera; persistent demo saves. Verify sample hashes, existing `.tscn`, `.tres`, `asset.json` and `WebP`. Phân biệt thành quả branch với main.
3. Không chạy FULL/CI. Chạy smoke/launcher nhanh nhất được hỗ trợ trên Windows; nếu chưa xác lập sandbox path/save hash an toàn, **không chạy gameplay thật bằng profile user**. Ưu tiên chụp 2 ảnh hiện trạng 1280×720: tông môn/G1 và combat/DEMO. Không đánh giá UX bằng log tĩnh.
4. Ghi `P0_CURRENT_STATE_MATRIX.md` + `P0_QA_EVIDENCE.md`. Nêu rõ đã thấy/không thấy, thời điểm, runner Godot, HEAD, đường dẫn thật.

## 4. P1 — Kiểm toán chính xác Source A animation/combat/skin

**Không viết lại parser, converter, GUI hoặc giải mã cả kho.** Dùng SpineToGodot472 hiện có: nó đã đạt Batch-01 10 rig/31 clip/1.016 frame, 28 WebP atlas. **Trước tiên inspect metadata JSON & Spine sources; nếu tool cần thêm chế độ list animation/skin thì mở rộng tối thiểu trong tool hiện tại, không thêm tool song song.**

Danh sách tối thiểu:

- Đệ tử đã trong repo: `1113028_1`, `body_1110201`, `body_1120402` — hiện import chỉ `stand/walk`; kiểm các animation Spine gốc thật `attack`, `attack1..7`, `hit`, `dead/die`, `cast`, `idle` nếu có. **String từ CSV không đủ chứng minh clip tồn tại.**
- Ưu tiên thử `body_1120101_s` (13 clip đã chuyển trong Batch-01) nếu 3 rig trên thiếu; giữ đúng provenance và class/sex/role bằng manifest, không gọi NPC thành đệ tử khi chưa kiểm silhouette/asset type.
- Quái ứng viên `1113031_1`, `410041_1`; Boss chỉ chọn từ asset Source A khi đã có rig/skeleton và clip xuất chiêu/trúng/chết, không dùng Skin JXQY2 dán nhãn Source A.
- Map/vegetation/stone/roads/buildings: kiểm 32 PNG Source A đã có, atlas/pivot/scale với map 2.5D; chọn một khu săn thuyết phục. Nếu không có bộ map combat thực, ghi `MAP_ART_GAP`, chỉ làm neutral QA stage được gắn nhãn, không tuyên bố visual final.

Cho **mỗi** asset lập row CSV: `asset_id`, `source_path`, `source_kind`, `source_sha256`, `skel_version`, `source_atlas`, `source_png`, `Spine_skins`, `slots/attachments`, `clip_exact_names`, `clip_duration`, `directions_or_mirror_safe`, `fps`, `foot_anchor`, `weapon_socket`, `color/tint_limit`, `converted_output`, `verified_frames`, `intended_role`, `visual_compatibility`, `status/proof_path`, `blocker`.

Output:

- `SOURCE_A_COMBAT_ASSET_MATRIX.csv` + `SOURCE_A_COMBAT_ASSET_AUDIT.md`.
- Contact sheet/video động thật `stand/walk/attack/hit/dead` cho **ít nhất một ứng viên nhân vật và một ứng viên quái**, nếu có; kiểm source vs baked output. Ảnh test phải hiện đúng foot line, clip name, frame, hướng.
- `SOURCE_A_EQUIPMENT_VISUAL_PROOF.md`: xác nhận source Spine có skin/attachment đổi áo/tóc/vũ khí thực hay không, cùng 2 biến thể thử nếu có. Không claim P3.2 modular tự tương thích với Spine vì đều có bones.
- Nếu thiếu raw triplets trên E: hoặc hash sai, nêu chính xác 3 tên/path cần phục hồi; `BLOCKED_BINARY` và dừng G2 liên quan. Không tự chế asset giả Source A.

**Quan trọng:** G1 production **không cần** clip đào/chặt/trồng, không audit lại vì lý do này.

## 5. P2 — Chỉ nếu P1 đã xác minh source thật: một Source A Combat Visual Pilot trong Godot

Tạo **nhánh CODE cách ly** từ HEAD Playfirst mới nhất: gợi ý `work/v5-sourcea-combat-visual-slice-20261021`. Không chuyển toàn repo Source A. Không sửa production current save. Scope chỉ chuyển presentation actor/map/visual cue của sandbox pilot sang Source A thật:

1. Chọn một rig đệ tử nam/nữ có animation combat thật, một quái, một Boss **nếu Boss có binary đủ**; load actor catalog/`SpriteFrames` và atlas bằng share cache, reuse giữa 6 nhân vật. Nếu thiếu Boss, báo asset gap và chạy fixture chỉ với quái, không giả PASS boss.
2. Dùng converter cũ bake incremental chính xác `stand/walk/attack/hit/dead` và (nếu có) `cast`, export cùng `asset.json`; không full batch, không ghi lại source A; SHA/fingerprint output. Gắn vào scene 2.5D theo foot anchor, Y-sort, z-order, map-space, alpha. Không mirror vũ khí bất đối xứng khi không được phép.
3. Adapter **chỉ quan sát** state/event Combat V2 hiện có. Actor clips theo event thật, không dùng tween/VFX để tạo tác động logic; map 2.5D Source A từ asset hợp lệ, camera tự do/follow có chọn, zoom/touch. VFX bốn họ theo art bible, **thử hai cue đã có V2 consumer** trước. Nếu heal/fire chưa có consumer, KHÔNG cho biểu diễn heal/burn giả. Bảo lưu `JxPilotSkillsV1`/`JxPilotRuntimeV1` và tất cả WebP/VFX đã xác minh; không đổi ID.
4. Phương án skin: ưu tiên source skin/attachment có chứng cứ; nếu không, dùng vài whole-body variant và lập debt modular. Không tạo mọi tổ hợp full atlas, không patch vào locked P3.2 contract.
5. QA **focused** bằng Godot 4.7.2: import, asset playback, V2 event/cast/impact, camera, real-Hunting smoke, snapshot/replay và One Active Job unaffected, performance sample 6v5; stress 30v40 riêng nếu runner đủ. Chụp ảnh game thật 1280×720 ở 5 giai đoạn idle/walk/cast/impact/hit-die; video H.264 ngắn đủ quan sát và ảnh so G1 ↔ Combat. Runtime/fps Android PENDING tới khi thực sự chạy thiết bị.
6. Nếu phát hiện lỗi ở gameplay core, **không được tự thay** `MapBattleV2`, CombatStatsV2, RNG, reward, SaveService, Warehouse, Scheduler hoặc G1 work timeline. Lập regression debt và chỉ sửa presentation trong allowlist đã dùng. Khi bắt buộc đổi core, báo riêng owner cần CODE packet chuyên biệt.

**Chấp nhận partial hợp lệ:** nếu P1 chỉ có stand/walk, Codex kết thúc tại P1, không bịa combat động. Phải đưa ra đúng shortlist Source A mới với bằng chứng trong catalog và số clip cần có để vượt P2.

## 6. QA và quyết định PASS/FAIL

- PASS asset chỉ khi raw source hash + parsed animation + playback/frames hợp lệ.
- PASS Windows chỉ khi *official* Godot 4.7.2 focused trên **HEAD mới**, exit 0, log và ảnh/video màn chơi.
- Không để 8 GB RAM sinh song song hàng trăm atlas; incremental export, chọn texture size, cache và tránh reimport 57 asset groups mỗi lần mở DEMO.
- **Không CI, FULL, merge**, không đóng PR, không dùng admin, không thay dữ liệu chủ dự án, không push các binary nguồn nguyên bản số lượng lớn. Không yêu cầu owner tải lại source mà máy đã có.
- Kiểm startup demo Play-only không auto clone/reimport/test, và **ghi riêng** thời gian vào game vs thời gian chạy QA; thiếu Android runner thì `PENDING DEVICE`, không tự nhận 30/60 FPS.
- Owner **chỉ duyệt hình ảnh** sau khi nhận ảnh/video; không gọi owner visual PASS hộ.

## 7. Bàn giao bắt buộc

Đặt mọi báo cáo ở `E:\TongMonBaDaoWorkspace\05_DauRa\CombatV5_SourceA_Pilot\` (cùng một project output, không tạo hàng chục thư mục rải rác):

1. `P0_CURRENT_STATE_MATRIX.md` — nhánh/HEAD/tính năng/QA.
2. `SOURCE_A_COMBAT_ASSET_MATRIX.csv` + `.md` — raw/mapped/Godot-ready/skins/clip exact.
3. `SOURCE_A_EQUIPMENT_VISUAL_PROOF.md` — quyết định skin vs wholebody vs P3.2, bằng chứng.
4. `PREVIEW_INDEX.md` — đường dẫn contact sheet/PNG/frame/video từ Godot và nguồn mỗi ảnh.
5. `P2_VISUAL_QA.md` — test/engine/memory/FPS nếu P2 được thực hiện; `BLOCKED` nếu thiếu clip.
6. **Một file tổng** `CODEX_V5_SOURCE_A_HANDOFF.md` — ngắn gọn: kết quả, commit SHA, READY/BLOCKED/PENDING, công việc kế tiếp; không bắt owner đọc từng log.

Nếu có code/asset chọn lọc, commit/push trên nhánh cách ly + cập nhật `CURRENT_CHECKPOINT.md` và `NEXT_CHAT_HANDOFF.md` để chat sau tiếp quản. **Không merge**, không thay `main`.

## 8. Tiêu chí thực sự xong

**G0/P1 DONE:** biết chính xác và có chứng cứ Source A nào đủ animation combat, quái/Boss/map, khả năng thay trang phục; không ghi “đã nhập vào Godot” khi mới thấy trên ổ E.  
**P2 CODE DONE:** đã gắn đúng asset Source A vào một màn chiến đấu bằng authoritative Combat V2, Android 1280×720 visual layout; game có thể mở qua Play-only launcher.  
**P2 TECH PASS:** Godot 4.7.2 focused + GUI screenshots/video có nguồn; gameplay/save không đổi.  
**OWNER VISUAL PASS và Android perf:** vẫn PENDING đến khi chủ dự án duyệt bằng chứng và chạy được thiết bị thật.

## 9. Câu kết Codex phải trả

> Đã làm: [asset nào, file nào, kỹ năng nào, clip nào], HEAD/branch [SHA], ảnh/video tại [đường dẫn], QA [PASS/FAIL theo phép thử], đã giữ nguyên [Combat V2, save, Economy, One Active Job], còn thiếu [binary/clip/skin/map/perf]. Bước tiếp theo đề xuất **duy nhất** có bằng chứng; không hỏi lại đã chốt Source A hay chuyển sang pixel.
