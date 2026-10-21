# TÔNG MÔN BÁ ĐẠO — CODEX MASTER PROMPT
## JX1 combat source extraction + Source A (Ta Làm Tông Sư / 最强祖师) asset group library

**Ngày lập:** 2026-10-21  
**Người thực hiện:** Codex chạy trên **máy Windows có quyền đọc ổ E:**  
**Repo game:** `https://github.com/vuanhtuan161094-byte/TongMonBaDao`  
**Engine:** Godot 4.7.2, Android landscape 1280×720  
**Chế độ làm việc:** TỰ TRIỂN KHAI THEO PHẠM VI CHỈ ĐỊNH, ít QA nhưng QA đúng chỗ; báo kết quả, không đẩy việc lại cho chủ game.  
**Nguồn và quyền:** Chủ game đã xác nhận quyền sử dụng Source A và nguồn JX1 được cung cấp. Không hỏi xác nhận lại. Vẫn ghi provenance/SHA để tránh trộn dữ liệu hay nhận diện nhầm.

---

# PROMPT CHÍNH — DÁN NGUYÊN KHỐI NÀY CHO CODEX

Bạn là kỹ sư reverse-engineering tài nguyên, game-tools và technical artist chịu trách nhiệm **hai workstream rõ ràng, không trộn dữ liệu** cho Tông Môn Bá Đạo. Tôi đã có game JX1/client/server và Source A từ game tham chiếu *Ta Làm Tông Sư / 最强祖师* trên máy Windows. **Tôi cần thành phẩm dùng được, không cần kế hoạch suông, không yêu cầu duyệt từng bước, không tạo lại công cụ đã có.**

## 0. Nguồn, HEAD và quy tắc bắt buộc

1. FETCH GitHub live repo `vuanhtuan161094-byte/TongMonBaDao` trước khi chỉnh. Đọc `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md` và các handoff nêu dưới đây. Đối chiếu `main`, các draft PR liên quan và HEAD nhánh tool hiện tại. **Không mặc định bất kỳ SHA dưới đây vẫn là HEAD mới nhất.**
2. Nhánh Asset Forge đang có tại thời điểm viết: `tools/af-jx1-player-forge-20261020`, checkpoint **`4dcb2daf01e6a14971b32131b7b69d7c67ae563f`** (C5 JX1 combat intake). Code có `tools/asset_forge/jx_combat_intake.py`, `QUET_SOURCE_COMBAT_JX1.cmd`, `jx1_pak_v2.py`, `jx1_adapter.py`, `jx1_tables_v2.py`, `jx1_player_pipeline_v4.py`, `web_ui.py`. **Tận dụng và mở rộng đúng phần còn thiếu, không viết parser/Asset Forge thứ hai.**
3. Không động đến gameplay authority **Combat V2**: sát thương, tỷ lệ trúng, RNG, cấp Tu Vi/Luyện Thể 30×10, spiritual roots, injury, save, warehouse, economy, workforce, skill formulas, cooldowns, target decisions. JX1 là chuẩn **mỹ thuật, sprite, map, animation, các ID kỹ năng và hiệu ứng**; chuyển nội dung qua adapter có nguồn, không bê JX1 damage formula sang.
4. Không sửa nguồn/client/server gốc. Không giải nén ồ ạt hàng chục GB; chỉ trích xuất asset chọn lọc theo manifest. Không chạy `.exe/.dll/.bat` lạ lấy từ client/server. Không xóa hoặc ghi đè output đã kiểm SHA. Mọi bản gốc bất biến.
5. **Phân tách:**
   - `JX1_OWNER` phục vụ **combat visual/content**; source local: **`E:\Source`** (client/server/source) và **`E:\Tool JX`** (công cụ JX).
   - `SOURCE_A` phục vụ **map tông môn, công trình, đệ tử, linh thú, UI, trang trí, animation**, có workspace riêng phía dưới.
   - Không gộp ID/hash/catalog/raw/assets giữa hai họ. Không giả định Source A ở `E:\Source`.
6. Phạm vi CODE: chỉ `tools/asset_forge/**`, **công cụ đã có** trong `E:\TongMonBaDaoWorkspace` và tài liệu/manifest/báo cáo mới trong `docs/` (nếu thực sự cần); một **presentation-only pilot** trong `godot/src/presentation/**`, `godot/assets/**` được phép khi đã chứng minh asset thật và không đụng gameplay. Nếu mã presentation đã có concurrent writer/PR, **không sửa chồng**, tách nhánh, chỉ nộp report/pack đề xuất để người tích hợp dùng. Không sửa simulation/gameplay/save; không CI, FULL, merge; focused tests đủ để kiểm nhiệm vụ. Không push asset thô/large packs lên GitHub.
7. Đầu ra chính lưu trên Windows, không đặt trong các thư mục raw:
   - Vault chung: `E:\TongMonBaDao_AssetVault`.
   - JX: `E:\TongMonBaDao_AssetVault\06_reports\JX1_Combat_Intake` và `05_approved_packs\JX1_COMBAT_PILOT`.
   - Source A: `E:\TongMonBaDao_AssetVault\02_catalog\SOURCE_A_GROUPS` và `05_approved_packs\SOURCE_A_PILOT`.
   - Handoff/log: `E:\TongMonBaDao_AssetVault\06_reports\CODEX_ASSET_HANDOFF_2026-10-21`.
   - Giữ `01_raw/JX1_OWNER` tách biệt `01_raw/SOURCE_A`; ưu tiên tham chiếu đường dẫn raw gốc, không copy toàn kho.

## 1. WORKSTREAM JX — Bóc đúng asset để combat JX1 mượt

### JX-A. Bằng chứng nguồn tự động

- Tự chạy công cụ **`QUET_SOURCE_COMBAT_JX1.cmd`** hiện có (hoặc CLI `jx_combat_intake.py`) trên **`E:\Source` và `E:\Tool JX`**, lấy kết quả `JX1_COMBAT_SUMMARY.md` và `JX1_COMBAT_SOURCE_MANIFEST.json`. Không yêu cầu tôi chạy thủ công nếu Codex đang có quyền Windows.
- Kiểm tra từng root là thư mục hay chứa archive/clone lồng. Phân biệt code/server, tài nguyên client, script/tool, `.pak` header `PACK`, `.spr`, `.map`, `.mpi`, `.txt/.ini`, âm thanh. Nếu còn RAR/7z chưa giải nén, chỉ lập danh sách và dùng bộ giải nén tin cậy **khi thực sự cần một vài entry** (không tự bung tràn ổ E:).
- Đối chiếu `settings/skills.txt`, `settings/missles.txt`, bảng `settings/npcres/人物类型.txt`, Kind→Part→Sect, ini thứ tự lớp, bảng skin/weapon. Truy tên asset → ID hash nguyên bản → PAK entry → SPR bytes. Ghi lý do nếu thiếu.
- Nhân vật playable phải có **dòng nguồn người chơi** (`男主角`/`女主角` hoặc bằng chứng tương đương bản client), NPC, quái và boss phân loại riêng. Không gắn bừa NPC `特殊npc` thành đệ tử/player.

### JX-B. Trích xuất mẫu **ít nhưng thật**, chạy được ở Godot

Chọn theo bằng chứng thực tế (không invent ID):

1. **Một map rừng/thôn/luyện công gốc JX1** với nền và tile thật; thiết lập camera pan chuột/touch tự do và viewport/chunk culling. Không nền bốn màu tự vẽ thay JX1.
2. **Một playable đeo trang bị**, tối thiểu `idle/stand`, `walk`, `attack`, `hit`, `die` nếu nguồn có đủ; 8/16 hướng đúng theo sprite và order, có hash/anchor/foot.
3. **Một quái thường và một boss**, cùng pose tối thiểu có thật, HP/nameplate không che mặt.
4. **Một kỹ năng thật** đối chiếu `skills.txt` → `missles.txt` → animation `cast → projectile → impact / AoE`; ghi skill_id, fx_id, frame/duration/offset và các file resource thực tế. Không sáng tác skill, không thay hệ số gây damage V2.
5. Xuất **contact sheet** theo nhiều hướng cho nhân vật, quái/boss, skill và một **preview scene 1280×720**, chú thích từng hướng/clip, bản gốc, SHA256.

### JX-C. Mục tiêu mượt và đo đạc thực

- Ưu tiên **atlas chia sẻ texture**, định danh cache, pool FX, giới hạn đồng thời các effect nặng; không tạo texture/new SpriteFrames mỗi tick. Không cắt sprite thành 1000 node rời.
- Tính vị trí render bằng interpolation các snapshot V2, không nội suy giả trạng thái HP/damage/cooldown; hệ Y-sort theo chân và layer sort theo bảng gốc; dùng camera tự do, follow khi người chơi chọn.
- Profile Godot **4.7.2** ở **1280×720** với mức nhỏ 6 đệ tử + 5 quái, và fixture stress **30 đệ tử + 40 quái** (visual-only hoặc state thực đã có). Ghi FPS trung bình, frame time P50/P95, draw calls, VRAM nếu công cụ đo cung cấp, CPU và thời gian tải scene. Android **PENDING** nếu không có máy Android; không gọi Linux synthetic test là Windows/Godot pass.
- Nếu asset map/skill gốc không có hoặc decoder fail, xuất `BLOCKED` với đường dẫn/ID/error cụ thể. Không dùng placeholder rồi đánh dấu “JX1 PASS”.

### JX-D. Tệp đầu ra

- `JX1_COMBAT_SUMMARY.md` (báo cáo nguồn thật), `JX1_COMBAT_SOURCE_MANIFEST.json` (gốc).
- `JX1_COMBAT_ASSET_MATRIX.csv` / `.json` — `source_family; category; source_path; archive_path; pak_id; source_table; actor/skill_id; action; direction_count; frames; duration; anchor; layer; SHA256; extraction_status; Godot_path; QA_status`.
- `JX1_COMBAT_PILOT/` — 1 map, 1 playable, 1 mob, 1 boss, 1 skill thật đủ chứng cứ và manifest (chỉ khi file gốc tồn tại/giải được).
- `JX1_CONTACT_SHEETS/` — ảnh preview nhiều hướng, mỗi ảnh có index nguồn.
- `JX1_GODOT_FRAME_TIME_QA.md` — số đo thật; chưa chạy phải ghi PENDING.
- `JX1_BLOCKERS.md` — thiếu file/map, decoder chưa hỗ trợ, không tìm được ID, xung đột table/pack và bước sửa tối thiểu.

## 2. WORKSTREAM SOURCE A — Bóc **từng nhóm asset** game *Ta Làm Tông Sư / 最强祖师*

**Quan trọng:** Tôi không cần bản thống kê 157.607 file lặp lại. Tôi cần **THƯ VIỆN CÓ NGỮ NGHĨA**, xem ảnh, tìm ID, biết công trình/nhân vật/UI nào, các clip nào, dùng lại trong Godot 4.7.2, không mất dữ liệu nguồn.

### SA-A. Xác định nguồn thực tế và công cụ đã có

Trước khi tạo tool mới, hãy **tìm và tái sử dụng**:

- **Kho Unity/Source A đã trích**: `E:\TongMonBaDaoWorkspace\02_SourceA\GameAssetExtract`.
- **Workspace**: `E:\TongMonBaDaoWorkspace`.
- **Catalog đã có**: `E:\TongMonIntegrationLab\AssetCatalog` (~157.607 file đã index trước đây; **không quét full lại**).
- **Bộ Spine converter đã kiểm**: `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472`; launcher `E:\TongMonBaDaoWorkspace\MO_CONG_CU_SPINE.cmd`.
- **Godot-ready assets cũ**: `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472\<asset_id>`.
- **Các lab/asset staging**: `E:\TongMonIntegrationLab` (TransferKit, MapPrototype/ENV01/ENV02A, AssetVisualLabV1) nếu thực tế còn trên máy.
- **Knowledge repo**: `https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge` — code/prefab/config/ref cho game tham chiếu. **Không giả định repo này chứa texture/atlas gốc**.
- **Tông Môn repo handoff**: `docs/P3_SOURCE_A_ANIMATION_ASSET_UI_UX_HANDOFF_2026-10-17.md`, `docs/MAP25_MAIN_ENV02A_INTEGRATION_2026-10-16.md`, `godot/data/presentation/map25_source_a_verified.json`, `labs/env02a/ENV02A_BASELINE_ASSET_SHA256.json`.

Nếu đường dẫn không tồn tại ở máy Codex: tìm qua đường dẫn E: liên quan và log vị trí thực; không bịa ra path, không yêu cầu tôi mô tả lại khi máy có thể tự kiểm tra.

### SA-B. Phân **nhóm theo ý nghĩa chơi game** (bắt buộc)

Xuất taxonomy có nhánh con, không chỉ group theo phần mở rộng:

| Mã nhóm | Nhóm dùng cho Tông Môn Bá Đạo | Thông tin cần nhận diện |
|---|---|---|
| `SA_ENV_GROUND` | Nền/đất/đá/nước/biên nền | Tile, scale, isometric projection, atlas rect, terrain layer |
| `SA_ENV_ROAD` | Đường đi/bậc thang/cầu/lối vào | Tile nối, junction, grid và footprint |
| `SA_ENV_NATURE` | Cây, đá, núi, bụi, linh thảo, cảnh vật | Foot anchor, canopy/occlusion, layer, biến thể kích thước |
| `SA_BUILDINGS` | Đại Điện, Kho, Mỏ, Linh Lâm, Linh Điền, Lò Rèn, Phường Thị, nhà ở, các cấp | **Building ID**, tên, chức năng, prefab, footprint, hướng, level/upgrade visuals, animation |
| `SA_CHAR_PLAYER` | Đệ tử nam/nữ, kiểu cơ thể/đầu/tóc/trang phục | Skeleton, Spine skin, slot attachment, clip thật, anchors, reusable rig |
| `SA_CHAR_NPC` | NPC thương nhân/khách/nhân vật môi trường | Nguồn danh tính và mục đích, không gắn nhầm người chơi |
| `SA_PETS_MOBS` | Linh thú/thú/quái/trang trí sống | Loài, kích thước, clip và nguồn kỹ thuật |
| `SA_UI_LAYOUT` | Panel Mỏ/Linh Điền/Linh Lâm, roster đệ tử, hồ sơ, Đại Điện, popup, HUD, thanh tiến độ | Prefab → texture 9-slice → bố cục màn ngang 1280×720, tên node/chỉ dẫn UI |
| `SA_UI_ICONS` | Item, kho, tài nguyên, tiền, chức năng, trạng thái, nghề, skill icons | Sprite ID, atlas subrect, pixel density, nhóm ngữ nghĩa |
| `SA_VFX_SFX` | Hiệu ứng map, thu hoạch, thăng cấp, ánh sáng, âm thanh/UI | Loại emit, hệ trục, các file phụ thuộc; không đưa combat V2 khi chưa mapping |
| `SA_DATA_LINKS` | Scene/prefab/config, mã Lua/C#, bảng mapping, Spine atlas dependency | ID ↔ tên ↔ đường dẫn ↔ bundle ↔ prefab ↔ actual binary |

Cho phép các nhánh phụ khác nếu có **bằng chứng**, nhưng 10 nhóm trên là danh mục yêu cầu.

### SA-C. Bóc theo **dependency**, không giải nén toàn bộ bundle

1. Dùng AssetCatalog sẵn có để **lọc candidate theo ID, prefab/path, scene, component, asset type**, tránh full scan lại. Cần scan bổ sung thì incremental, fingerprint/hash, chỉ scan thư mục thay đổi.
2. Với Unity `.ab`/AssetBundle và metadata: đọc object index; xác minh `Texture2D`, `Sprite`, `TextAsset`, `GameObject`, `MonoBehaviour`, `Spine.Unity.SkeletonDataAsset`, `SpineAtlasAsset`, material và Atlas texture. Truy các **dependency** từ prefab→atlas/PNG, skel→atlas→texture. Không chỉ lấy ảnh preview lẻ và gọi là asset hoàn chỉnh.
3. Đối chiếu mã tham chiếu/UI names trong `ZQZS-Source-Knowledge` để giải nghĩa. Không tự gán tên “Mỏ/đệ tử/skill” nếu không có ID/code/scene hoặc hình ảnh kiểm chứng.
4. **Spine 3.8**: dùng converter hiện có; rig gốc **triplet** `.skel/.atlas/.png`, xuất `actor.tscn`, `animations.tres`, `atlas_*.webp`, `asset.json` ở Godot 4.7.2. Giữ skin/attachment và clip có thật; không ghi đè Batch-01 đã đạt hash và không giả clip work/action. 10 rig/31 clip/1.016 frame hiện có là **mẫu đã kiểm**, không phải toàn kho đã PASS.
5. **Sprite/PNG/UI:** giữ RGBA, transparent padding cần thiết, pivot/anchor, spritesheet rect, 9-slice border, scene z-order và kích thước nguồn; không làm “xấu đi” vì resize cứng hoặc cắt mất mép. Nếu texture atlas xuất từng sprite, giữ parent atlas ID và pixel rect để có thể khôi phục.
6. Dùng **manifest tự động** và contact sheet: mỗi asset có preview thumbnail, ID nguồn, file gốc, bundle, SHA256, chủng loại, biến thể, trạng thái decode, các dependency; xuất danh mục HTML tĩnh/offline hoặc giao diện tab Source A **trong Asset Forge Studio đang có** (không làm một web app thứ hai).
7. Ưu tiên **ít mà dùng được**: nhóm map/đường/cây, 3–6 công trình, 2–3 rig người, UI Mỏ/roster/hồ sơ, một nhóm icon vật phẩm. Các phần còn lại chỉ cần phân nhóm theo metadata, không chuyển binary hàng loạt.

### SA-D. Pilot Source A ưu tiên cụ thể

**Dùng lại asset đã có, kiểm hash trước, không bake lại vô cớ:**

- Map/ENV02A: **32 PNG** gốc đã có manifest; cây/đường/nền/3 building đã từng xác minh.
- Công trình: `510052` **Đại Điện**, `510102` **Kho**, `520081` **Lò Rèn**; đối chiếu thêm **Mỏ `520051`** và các ứng viên sản xuất khác **chỉ nếu code/metadata chứng minh**.
- Nhân vật: `1113028_1`, `body_1120402`, `body_1110201`, rồi rig/monster ưu tiên đã nằm trong `Batch01`; kiểm clip `stand/walk` thật.
- UI: tham khảo `UIBuildingInfoWin`, `UIMDiscipleSelect_manager` cùng panel công trình bên phải, chọn/đổi/gỡ worker, timer, sản lượng và bảng đệ tử; **chỉ trích art/prefab/9-slice và mapping**, không thay logic workforce, timer, scheduler hay kho.
- Mỗi nhóm ở pilot phải có **ít nhất một ảnh preview có nguồn**, metadata kỹ thuật và trạng thái `READY` hoặc `BLOCKED`; không coi hình minh họa tự tạo là asset gốc.

### SA-E. Bộ tài liệu/công cụ cần giao

- `SOURCE_A_GROUP_INDEX.json` và `.csv` với cấu trúc:
  `source_id,group,subcategory,asset_id,original_name,description,evidence_type,evidence_path,original_file,bundle,dependency_ids,source_sha256,format,dimensions,atlas_rect,pivot,foot_anchor,clip_names,spine_version,skin_names,godot_output,preview_path,technical_status,visual_review_status`.
- `SOURCE_A_GROUPS_README.md`: cây nhóm rõ ràng; mô tả thành phần, cách tìm/tải/mở preview, phân biệt `PRESENT_METADATA_ONLY`, `BINARY_FOUND`, `DECODED`, `GODOT_EXPORTED`, `GODOT_VERIFIED`, `BLOCKED`.
- `SOURCE_A_DEPENDENCY_GRAPH.json`: prefab/ID→sprite/atlas/texture/skeleton/config; không lẫn bundle Source A và JX.
- `SOURCE_A_CONTACT_SHEETS/`: sheet riêng `environment`, `roads`, `buildings`, `characters`, `ui`, `icons`, `vfx`, có ID ghi dưới thumbnail.
- `SOURCE_A_GODOT_PILOT/`: thư mục con theo đúng taxonomy, chứa các asset **được chọn và kiểm hash**, không dump toàn kho, giữ scene `.tscn` / `.tres` / `.webp` đầy đủ dependency.
- `SOURCE_A_DUPLICATE_REPORT.md`: chỉ ra những asset đã có trong Game/TransferKit/Batch01/ENV02A để **reuse**, không lại copy nhiều lần.
- `SOURCE_A_MISSING_AND_BLOCKED.md`: các ID thiếu binary, metadata bị mơ hồ, bundle hỏng, mất atlas, thiếu tool; chỉ dẫn ngắn cho từng blocker.
- **Công cụ:** bổ sung tab/CLI Source A vào **Asset Forge Studio hiện tại** nếu thật sự cần để tìm theo group/ID, xem thumbnail, lọc `GODOT_READY`, bấm export pilot; đừng bắt tôi nhập tay hàng nghìn ID.

## 3. Kiến trúc thư viện chung: tìm dễ, không nhầm nguồn

```text
E:\TongMonBaDao_AssetVault\
├── 01_raw\
│   ├── JX1_OWNER\              # Chỉ các item chọn lọc nếu cần stage
│   └── SOURCE_A\               # Chỉ các item chọn lọc nếu cần stage
├── 02_catalog\
│   ├── JX1_COMBAT\
│   └── SOURCE_A_GROUPS\
│       ├── SOURCE_A_GROUP_INDEX.json
│       ├── SOURCE_A_GROUP_INDEX.csv
│       └── SOURCE_A_DEPENDENCY_GRAPH.json
├── 03_derived\
│   ├── JX1_COMBAT\
│   └── SOURCE_A\
├── 04_previews\
│   ├── JX1_CONTACT_SHEETS\
│   └── SOURCE_A_CONTACT_SHEETS\
├── 05_approved_packs\
│   ├── JX1_COMBAT_PILOT\
│   └── SOURCE_A_PILOT\
└── 06_reports\
    ├── JX1_Combat_Intake\
    └── CODEX_ASSET_HANDOFF_2026-10-21\
```

Không đổi cấu trúc Vault đang dùng nếu đã có; tạo những thư mục trên **theo cách tương thích**, không di chuyển phá manifest cũ. Mỗi asset output phải có `source_family`, `source_path`, `source_sha256`, `conversion_tool_version`, `output_sha256`, `origin_catalog_id`, `status`, `issues`.

## 4. Hiệu năng và nghiệm thu

**Quy tắc QA:** chỉ focused; kiểm hash, parser, import vài asset, render đầu/giữa/cuối clip, contact sheet và một scene thật; không CI/FULL/merge trừ khi tôi lệnh riêng. Không tự gọi đủ tiêu chuẩn “PASS” khi chưa nhìn thấy đúng binary và Godot 4.7.2.

- `SOURCE_A`: so sánh nguồn ↔ kết quả convert RGBA/anchor/clip trên **1 rig + 1 building + 1 UI**; không test trọn 157k file. Godot import nhỏ và hình 1280×720 nếu máy có Godot runner.
- `JX1`: test một asset cho mỗi loại và một map; stress visual Godot có FPS/frame-time. Không thay logic/simulation để tăng FPS.
- Gói runtime cần metadata để tái dựng asset; source/asset bao lớn không đẩy bừa lên git; SHA giúp phân biệt trùng và dedupe.
- Trạng thái luôn tách: `STATIC_VERIFIED`, `SOURCE_BINARY_VERIFIED`, `CONVERSION_VERIFIED`, `GODOT_RUNTIME_VERIFIED`, `ANDROID_PENDING`, `OWNER_VISUAL_PENDING`, `BLOCKED`.
- Trước khi push phải kiểm `git diff --name-only`, xác nhận không chạm `godot/src/simulation/`, `SaveService`, economy, CI/workflows hoặc file người khác đang sửa. Git commit lên nhánh riêng, **không merge**.

## 5. Cách Codex thực hiện ngay, không hỏi vòng vo

**Bước 1 — Preflight:** Kiểm ổ E:, xác định chính xác thư mục nguồn, pinned Git HEAD, Python, Godot, dung lượng trống, permissions; mở và đối chiếu 2 catalog cũ. Báo ngắn blocker nếu không có quyền truy cập, không tự nhận đã quét khi chưa chạy.

**Bước 2 — Chạy C5 JX:** Quét `E:\Source` và `E:\Tool JX`; xuất summary+manifest; xác thực một PAK/SPR và bảng skill; chọn ứng viên 1 map + 1 playable + 1 mob + 1 boss + 1 skill theo bằng chứng.

**Bước 3 — Phân nhóm Source A:** Dùng AssetCatalog 157.607 và nguồn đã extract; tạo 10 nhóm, cross-reference prefab/bundle/Spine, de-dup Batch01 & ENV02A; xuất danh mục và preview theo nhóm.

**Bước 4 — Pilot:** Chuyển tối thiểu *một lát cắt thực dụng* của cả hai source thành output Godot-ready, không copy lại toàn bộ raw. Nếu thiếu bản gốc trong máy, nêu chính xác blocker và hoàn thiện catalog metadata thay vì tạo fake art.

**Bước 5 — Focused QA và giao:** Chạy những focused tests sẵn có, test mới cho chức năng mới, pilot Godot khi runner khả dụng. Ghi số PASS/FAIL, SHA, hình/lệnh tái lập, performance thật. Cuối cùng xuất một ZIP chỉ gồm **report, manifest, preview/contact sheets, launcher và những pilot asset nhỏ**; tuyệt đối không nhét hàng chục GB source/client vào ZIP. Đẩy code/tool vào nhánh riêng khi có quyền; không CI, FULL, merge.

### Định dạng câu trả lời cuối của Codex — phải điền số liệu thật

```text
GITHUB BRANCH/HEAD: ...
WINDOWS ENV: Python ..., Godot ..., E: free ...
JX1 ROOTS: E:\Source [FOUND/MISSING], E:\Tool JX [FOUND/MISSING]
JX1: files scanned ..., real PACK ..., real SPR ..., map ..., skill/missile tables ..., candidate player/mob/boss ...
JX1 OUTPUT: exact absolute paths ...
JX1 REAL-PILOT: [PASS/PARTIAL/BLOCKED] + lý do
SOURCE A ROOT: ...
SOURCE A: existing catalog reused? ...; groups ...; asset IDs linked ...; preview ...; Spine clip ...
SOURCE A OUTPUT: exact absolute paths ...
SOURCE A REAL-PILOT: [PASS/PARTIAL/BLOCKED] + lý do
FOCUSED TESTS: ... PASS / ... FAIL
GODOT 4.7.2 RUNTIME: ... (nếu chưa chạy ghi PENDING)
VISUAL PERF 1280×720: FPS ..., P95 frame time ... hoặc PENDING
FILES MODIFIED: ...
COMMIT/PUSH: ... / ...
BLOCKERS (nêu đường dẫn & ID): ...
NEXT SINGLE ACTION: ...
```

**Không kết thúc ở “đã viết script kiểm kê”. Tôi cần ít nhất catalog nhóm Source A đọc được và báo cáo JX1 có bằng chứng trên máy E:, hoặc blocker thực sự, cùng công cụ dùng lại được. Bắt đầu thực hiện ngay.**

---

# PROMPT NGẮN THAY THẾ (nếu Codex giới hạn context)

Đọc trọn file Markdown này và thực hiện lần lượt **JX1 combat source intake** (`E:\Source`, `E:\Tool JX`, repo Asset Forge branch HEAD C5 hiện tại) và **Source A asset group extraction** (workspace `E:\TongMonBaDaoWorkspace`, `E:\TongMonIntegrationLab\AssetCatalog`, knowledge repo `ZQZS-Source-Knowledge`). Không lập catalog khổng lồ từ đầu, không viết converter Spine thứ hai. Tạo library nhóm bản chất game gồm map, roads, nature, buildings, đệ tử, NPC, pets/monsters, UI, icons, VFX và dependency/code mapping. Trích asset chọn lọc có source hash, preview và Godot-ready pilot. JX1 làm map/actor/mob/boss/skill combat thật + kiểm FPS trình bày; giữ Combat V2 authority và save. Chỉ sửa tool/presentation phù hợp, focused QA, không CI/FULL/merge. Báo đường dẫn tuyệt đối tới report/manifest/contact sheets/gói pilot, các ID đã xác thực và blocker. Không hỏi lại quyền dùng asset; chủ game đã xác nhận.
