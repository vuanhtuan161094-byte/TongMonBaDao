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
