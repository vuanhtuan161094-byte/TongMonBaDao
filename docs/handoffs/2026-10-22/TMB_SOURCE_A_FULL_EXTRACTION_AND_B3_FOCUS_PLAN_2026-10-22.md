# TÔNG MÔN BÁ ĐẠO — SOURCE A FULL EXTRACTION FIRST / B3 DESIGN SECOND

**Ngày:** 2026-10-22 · **Trạng thái:** owner-requested priority & execution design; NOT a completed extraction or authorization to change core gameplay.  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao` · **Docs branch:** `docs/b3-v2-architecture-redesign-20261022` · no merge.
**User goal:** Bóc hết/toàn bộ Source A trước, không chỉ rig Spine; xây **một catalog đầy đủ** về mọi loại file/asset/code/data và một thư viện Godot dùng được, tự động và có thể resume, phù hợp Windows 8GB RAM; B3 tiếp tục backend design riêng, không chạm Source A worker.

## 1. Dữ liệu baseline kiểm chứng từ ZIP ngày 22/10

File nhận: `TMB_SALIB_OVERNIGHT_REVIEW.zip` (ảnh, reports, SQLite catalog snapshot, converter scripts). Read `CHECKPOINT_2026-10-22.md`, `CODE_CHANGES.md`, `catalog_snapshot/summary.json`.

- `source_root: E:\TongMonBaDaoWorkspace\02_SourceA\GameAssetExtract\Assets` — **chỉ phạm vi asset Spine hiện có**, không đại diện toàn bộ Source A.
- 6,578 rigs, 20,507 input files, gồm 6,578 skeleton, 6,578 atlas, 7,010 textures, 341 animation metadata. Note: asset catalog may deduplicate aliases.
- 5,328 source READY về mặt phân loại, 1,250 REVIEW. Converter current fingerprint `54b0575661a2384e13595eefb3d327e2bc7b29d417329a29814ac481b25839b1`.
- 36 current converted PASS (35 fast, 1 full); 1 crop FAIL `2123019_10` with 768 canvas; 10 duplicate aliases; 5,273 READY blocked by resource-gate. 8 READY historical outputs await fresh verification; 9 historical PASS from older converter not current.
- REVIEW 1,248 PENDING classified **914 parser, 161 atlas/group, 173 texture/page**; remaining 2 not pending. **Classification is NOT proof files corrupted**, nor proof converter was run on all REVIEW. Need representative root-cause and systematic parser repairs when approved.
- 12 on-demand skins need 1536×1536 for validated full QA; don't force 768/1024 when crops.
- Existing converter `sourcea_library.py --config library.local.json resume --limit 4 --qa-mode fast` supports resume, skip fingerprints, manifests, checksum. Working output `E:\TongMonBaDaoWorkspace\03_AssetLibrary\SourceA\GodotAssets`.
- Windows 8GB / prior services.exe 0xEF BSOD: single conversion worker, RAM+CPU+disk resource gates, no forced converter under red gate; do not kill Windows services or disable pagefile/security.

## 2. Định nghĩa chính xác “BÓC HẾT” — no false 100% claims

**Gate A — FULL SOURCE INVENTORY COMPLETE:** scan WHOLE `E:\TongMonBaDaoWorkspace\02_SourceA\` recursively, not just `GameAssetExtract\Assets`, with excluded *generated/outside* outputs and no secret leaks. Enumerate every file (path, safe extension/type by signatures when possible, size, hash if feasible, parent archive/pak if known, proposed domain and status). Include:
- Spine skeleton (.skel/.json), .atlas, textures/pages, clip metadata, skin;
- all independent images / frame atlases / sprites / portraits / UI/HUD/icons / backgrounds / maps / tiles / VFX textures;
- audio/music/SFX/voice, fonts and localized text;
- configuration tables/JSON/CSV/XML/text, gameplay definitions & formulas, NPC/item/skill/role/template metadata, prefab/scene/material/shader/animation/controller;
- human-readable source code/scripts/modules/documents (static review only), executable/binary library catalog (do NOT run binaries just to identify), archives containers, unknown files classified explicitly.
These are categories to discover, not claims that Source A contains every category.

**Gate B — FULL CLASSIFICATION COMPLETE:** each file/asset has one primary `DISCOVERED | READY | REVIEW | UNSUPPORTED | DUPLICATE | MISSING_DEPENDENCY` status with source evidence. Derive stable owner/usage type `disciple_male/female/monster/elite/boss/unknown` only from reliable metadata/content links, never filenames alone. Separate gameplay data/code observations from converted Godot asset files. Identify reference graph (rig→atlas→textures→clips, map→tiles, UI→image, skill→VFX, script→content table) where provable; list unresolved cross-reference questions.

**Gate C — CONVERSION CAMPAIGN:** every supported eligible asset is attempted or given explicit well-typed not-attempted reason. For 5,273 READY Spine, continue batch-loop 1–4 rigs per batch on allowed resource gate, single worker, resume and persist per-rig status. Move supported non-Spine media via import recipes under separate lightweight converters/manifest; do not raw-copy giant binaries into Godot game or Git. Convert only meaningful/allowed formats, never invent or synthesize missing animation clips. Keep fallback/unusable flagged, don't silently leave out.

**Gate D — REVIEW TRIAGE CAMPAIGN:** 914 parser/161 atlas/173 texture/page grouped by signature/version, representative 5–10 samples per failure family, diagnose root cause and propose safe converter fix with fixed-seed regression and fingerprint bump; after approved converter fix rerun only impacted candidates, preserve old output provenance. Unknown/corrupt/unsupported stays explicit `UNRESOLVED`; never falsify 100% usable.

**Gate E — GODOT-READY CATALOG:** importable manifest with `logical_id`, canonical source path/hash, pack revision, type, Godot output path, converter version/fingerprint, QA mode, rig clips/skins/canvas/pivot/foot metadata, source/group linkage, dependencies, usage tags + verification status. Game runtime loads only selected approved packs on demand. Combat-ready actor requires *actual* stand/walk/attack/hit/dead clips or explicitly documented partial set; converter PASS alone is not playable actor proof. Bundle source code findings as metadata/architecture notes, do NOT execute unknown source executables.

“**FULL EXTRACTION COMPLETED**” means **all source entries inventoried, all supported candidates attempted or transparently blocked, unresolved counts visible**, not magically every asset converted/PASS. Do not promise all 6,578 rigs or 914 parser records will become playable.

## 3. Output workspace layout (proposed; preserve existing paths)

```text
E:\TongMonBaDaoWorkspace\
  02_SourceA\                         # IMMUTABLE original/raw extracted source
  03_AssetLibrary\SourceA\
    GodotAssets\                      # current converter output; never wipe
    catalog\
      source_all_files.sqlite           # canonical consolidated inventory
      source_all_files.csv              # export snapshot
      source_type_counts.csv
      unresolved_dependencies.csv
      actor_gameplay_readiness.csv
      source_code_data_index.csv
    manifests\
      library_manifest.json
      pack_index.jsonl
      actor_clip_manifest.jsonl
    reports\full_extraction\
      CHECKPOINT_CURRENT.md
      BLOCKERS_CURRENT.csv
      CONVERTER_FAILURE_FAMILIES.md
      RESOURCE_GATE_LOG.csv
      PHASE_ACCEPTANCE.md
      FINAL_ASSET_REVIEW.md
    tools\                             # reuse existing converter, no duplicate pipeline
```

The directory structure is advisory; if current tool already stores canonical DB elsewhere, adopt it instead of making competing SQLite DB authorities. **One canonical catalog DB, many read-only exports**; don't create two rival databases.

## 4. Execution pipeline safe for 8GB RAM

1. **Inventory-only pass**: static scan all SOURCE A, classify file types and family tree, detect archive/container candidates without executing binaries, record aggregate sizes and disk budget. Hash incrementally, avoid loading large file bytes into RAM. Preserve immutable raw file path. Skip generated `03_AssetLibrary`, Codex outputs, Godot import cache and any source symlinks escaping root.
2. **Reconcile with existing Spine DB**: merge by stable full path+hash, aliases tracked; current QA fingerprint untouched, no bulk rehash all previously verified assets. Export coverage: file_count, bytes, type histogram, duplicate counts, dependency completeness, convertibility estimates.
3. **READY conversion queue**: one worker, max 1–4 rigs per batch, FAST metadata/hash QA for each, optionally sample FULL Godot on converter change/risky canvas. A batch completes atomic state checkpoint; restart only unfinished. After safety gate goes red: pause conversion and return inventory/code tables review; do not force RAM load. Respect free disk and reserved-space floor measured rather than invent a threshold. Do not start full backlog in one launch without stop/control.
4. **Other asset families**: create input→Godot import strategy for UI/icons/maps/VFX/audio/fonts/config/code separately; classification first, then conversion pilot by family, only after owner permits code changes. Maps can be background assets in catalog without modifying Map owner scenes.
5. **REVIEW repair plan**: histogram errors grouped by parser exception/callsite + spine source version/atlas structure; 5–10 representative samples; minimal fix in converter script then tests and fingerprint bump. After scope approved, requeue safe related examples; no patching raw source or altering checksums.
6. **Packaging**: final index/report/manifest snapshots, optional *thin* reproducibility ZIP with configs/logs/sample scenes and checksums, NOT entire multi-GB asset bank inside ZIP/Git. Leave master outputs on E drive; selective Godot-ready pack copies for downstream Studio/Map/V5 after owner handoff.
7. **End-of-session**: `converted_PASS_current`, `FAILED_current`, `SKIP_same_fp`, `REVIEW_by_family`, `RAW_TOTAL_FILE_COUNTS`, `UNKNOWN`, disk/RAM gate, last resume ID, output hashes, exact next command. No repetitive huge QA ZIP each batch.

No unattended overload guarantee on 8GB. Persist after each rig/batch; stopping/restarting is a normal operation. Do not auto schedule shutdown or background tasks unless user explicitly requests separately.

## 5. Coordination with B3

**Source A worker owns**: catalog/converter/asset pack/metadata/rig classification/clip QA. No AI/gameplay code/Map/Studio/V5 scene editing.
**B3 researcher owns**: docs/architecture, canonical Combat V2 + per-kill Save/AI/loot authority contracts. No Source A conversion, no test/gameplay edits.
**Next cross-stream handoff** only after a curated pack exists: `source_asset_id, verified pack_hash, actor_kind, clip_ids, pivot/foot_xy, visual_scale, source_content_metadata`; B3 world actor references IDs, not specific raw .skel paths. Character Studio consumes verified packs later with its own owner; never infer character rigs from NPC/monster animations.
**Temporary priority:** Source A FULL inventory and ongoing conversion 80% of active resources; B3 design 20%. No B3 integration/code until a separate user CODE packet, even when Source A is complete.

## 6. Master Codex instruction — SEND ONLY TO SOURCE A AGENT

TÔNG MÔN BÁ ĐẠO — SOURCE A FULL EXTRACTION CAMPAIGN / ONE CANONICAL LIBRARY

Tôi chốt ưu tiên **bóc tách toàn bộ Source A trước**, không chỉ Spine, nhưng vẫn giữ máy Windows 8GB an toàn và backend B3 trên nhánh nghiên cứu độc lập.

Đọc checkpoint `E:\TongMonBaDaoWorkspace\03_AssetLibrary\SourceA\reports\overnight_20261022\CHECKPOINT_2026-10-22.md` và toàn bộ pipeline `sourcea_library.py` / `spine_to_godot472.py`, fingerprint converter `54b0575661a2384e13595eefb3d327e2bc7b29d417329a29814ac481b25839b1`; đọc repo AGENTS.md và kế hoạch này trên GitHub. Không đánh mất 36 QA PASS hiện tại, không coi 9 PASS lịch sử như pass converter mới.

**PHASE 1 REQUIRED:** quét read-only TOÀN BỘ `E:\TongMonBaDaoWorkspace\02_SourceA\` — không giới hạn `GameAssetExtract\Assets` — với manifest tất cả file, size/hash/type, parent/archived file, dependency, domain: rigs/sprites/tiles/maps/UI/VFX/audio/font/config/code/scripts/binary unknown. Không chạy exe/dll lạ, không load full vào RAM, không sửa raw source. Báo rõ những thư mục không accessible và asset type vắng mặt. Gộp vào **một catalog canonical** (reuse DB), phiên bản và nguồn chứng minh; exports CSV/JSONL và coverage numbers.

**PHASE 2:** lập hàng đợi conversion mọi asset loại supported, dedup aliases, resume/skip fingerprint, ưu tiên asset có clip/sử dụng gameplay. Chạy converter Spine đã có `resume --limit 4 --qa-mode fast` theo batch nhỏ, một worker, gated RAM/CPU/disk, checkpoint sau batch, sample FULL QA khi thay converter hoặc asset đặc biệt; không Godot per rig. Nếu thiếu RAM, không ép chạy mà chuyển audit/data triage. Asset ngoài Spine thì lên converter/import recipes nhẹ và pilot có căn cứ, không viết ồ ạt pipeline khác khi chưa biết định dạng.

**PHASE 3:** nhóm 914 parser/161 atlas/173 texture/page theo root error signatures, chọn 5–10 mẫu tiêu biểu mỗi nhóm. Phân tích parser version, source structure, lỗi common; đưa ra repair plan + focused test pilot. Chỉ sửa converter trong thư mục làm việc riêng khi đã có evidence và scope đồng ý; KHÔNG sửa raw asset, KHÔNG bulk REVIEW trial không kiểm soát.

**PHASE 4:** tạo `actor_gameplay_readiness`: rig nam/nữ đệ tử, normal monster, Elite/Boss candidate với nguồn metadata hợp lệ, clip stand/walk/attack/hit/dead thực có và provenance. Tạo Godot-ready index/pack manifests nhưng **không copy cả vài GB vào GitHub**, không đụng Character Studio/Map/V5/Combat/Save. Tách rõ CONVERSION_PASS khỏi actor COMBAT_READY/visual QA.

**QA:** nhẹ và tự động, file đọc được/hash/manifest/clip-frame count/canvas bounds; PASS/FAIL/SKIP/REVIEW; chỉ smoke sample. Không tạo nhiều ZIP QA. Không ẩn lỗi crop bằng giảm kích cỡ hoặc sửa hash giả. Giữ một bảng lỗi có lý do. Kết thúc mỗi session bằng tổng tồn backlog và cách resume.

**Outputs:** `03_AssetLibrary\SourceA\catalog`, `manifests`, `reports\full_extraction` theo layout thực tế đang tồn tại; một Markdown báo cáo tổng, export catalog và checksum, đường dẫn E:, command resume, blockers. Không reset dirty worktree hoặc merge. Nếu hiện giờ chỉ hoàn thành một phần khối lượng lớn, **bàn giao kiểm kê hoàn chỉnh + conversion checkpoint trung thực**, không báo “đã bóc hết” sai.

Trong khi Source A tiến hành, không giao Codex khác chạy Godot/Spine nặng. Backend B3 chỉ design/docs độc lập. Không tự hẹn shutdown mới.

## 7. B3 companion prompt — DESIGN ONLY

TÔNG MÔN BÁ ĐẠO — B3 CONTRACT REFINEMENT WHILE SOURCE A EXTRACTS

Đọc GitHub `docs/b3-v2-architecture-redesign-20261022` và B2.4 handoff ZIP; hoàn thiện kế hoạch tích hợp đã có `continuous_mode` sang một persistent world thật, một nguồn HP/kill per monster, AI team, SaveService/canonical Warehouse receipts, legacy snapshot v1/v2 and authoritative time/online/offline. Không tạo B3 code, không Godot FULL, không merge, không thêm converter, không đụng Map/Studio/V5 worktree. Đầu ra thiết kế packet hẹp để chờ owner CODE authorization sau khi Source A deliver verified core gameplay packs. Không giả định cần chuyển 100% asset mới có thể tích hợp.

**Correct success definition:** complete indexed Source A coverage + real verified Godot asset conversions + explicit unresolved/corrupt inventory; design-only B3 stays separate and ready to code when approved.
