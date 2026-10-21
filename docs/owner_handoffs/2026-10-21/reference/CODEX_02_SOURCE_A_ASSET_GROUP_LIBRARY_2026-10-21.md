# CODEX — TÔNG MÔN BÁ ĐẠO

**Windows local, Godot 4.7.2, Android landscape 1280×720.**
Bạn là kỹ sư chịu trách nhiệm thực thi nhiệm vụ dưới đây trên máy Windows có ổ E:. Không hỏi lại quyền sử dụng asset đã được owner xác nhận; kiểm chứng file thực, hash, không tự bịa đầu ra, không full/CI/merge, không sửa gameplay/Combat V2/save. Tự làm theo bằng chứng; nếu thiếu file, xuất blocker chính xác.

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


## Kết quả bắt buộc

Trả lại report và manifest trên ổ E: cùng commit nếu có, focused test PASS/FAIL, file hash, preview/contact sheets, gói pilot nhỏ, list asset thiếu. Phân biệt kiểm thử synthetic với runtime Windows Godot thực. Không để chủ game phải copy hàng chục GB vào chat. Chỉ sửa tools, tài liệu và presentation-only pilot khi có nguồn thật và không đụng writer khác.
