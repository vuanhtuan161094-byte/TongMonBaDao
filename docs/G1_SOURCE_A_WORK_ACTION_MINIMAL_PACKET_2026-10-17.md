# G1 — Source A work-action pilot (minimal asset packet, ART PENDING)

## 2026-10-18 — QUYẾT ĐỊNH OWNER: G1 KHÔNG CẦN ACTION CLIP (SUPERSEDES ART PENDING)

**Quyết định mới nhất:** Người chơi **không cần hoạt ảnh đào mỏ/chặt cây/trồng trọt**. Với Mỏ, Linh Lâm và Linh Điền, chỉ cần **thanh tiến độ/timeline sản xuất thật**, thời gian còn lại, sản lượng dự kiến và số thực nhập kho tại đúng ID công trình; có thể hiển thị đệ tử bằng Source A `stand/walk` đã xác minh. Chuyển trạng thái hạng mục `mining/chopping/planting action clips` từ **ART REQUIRED/PENDING** sang **NOT REQUIRED — OUT OF G1 SCOPE**.

- **DỪNG** mọi đề xuất tìm `113116_1_s`/`113116_1` để làm action, audit lại Spine, rebake Batch-01, tạo animation mới, hoặc đòi binary gốc chỉ vì action G1. Phần kiểm toán phía dưới lưu **bằng chứng lịch sử**, **không phải danh sách việc còn phải thực hiện**.
- **G1 gameplay visual acceptance** chỉ tập trung `SectProductionWorksiteCue` và panel: đúng công trình/đệ tử, tiến độ % từ mốc tick chính thức; linh điền nhiều ô chỉ nêu tiến độ ô gần nhất, không giả % tổng; giữ thông báo `+N đã vào kho` chỉ sau settlement và trạng thái chưa phân công/rảnh/chờ kết toán. Không tạo timer hay kho song song.
- **Tình trạng code tại baseline `663fe80e7a5b`:** `godot/src/presentation/p3/sect_production_worksite_cue.gd` đã có ProgressBar + phần trăm, `godot/src/presentation/p3_2_landscape_sect.gd` đã lấy dữ liệu từ job/plot và metrics theo instance ID; panel có progress header. Đây là kiểm tra **mã tĩnh**, chưa phải xác nhận timeline dễ đọc/chạy đúng qua Godot 4.7.2.
- **Cổng nghiệm thu còn lại:** focused Godot 4.7.2 cho PR #20 HEAD mới nhất, một lượt Windows UX 1280×720: progress/ETA/yield/received, đúng instance, không chồng badge, không lỗi tương tác, không lag nghiêm trọng. Owner UX **PENDING**; Android performance PENDING. Không CI/FULL/merge/G2.

---

## 2026-10-18 — G1 read-only source/manifest action audit (PR #20 baseline `207eaf45fe74`)

**Evidence scope / truth:** GitHub PR20 textual manifest + checked-in SpriteFrames and recursive tree were read directly; external [ZQZS-Source-Knowledge `ANIMATION_LIBRARY_INDEX.csv`](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/83cbc4ecbd83eb518a6d6f2b3894377d9d99254d/analysis/DarkEdition/ANIMATION_LIBRARY_INDEX.csv) was parsed at pinned knowledge commit `83cbc4ecbd83eb518a6d6f2b3894377d9d99254d`. Source-knowledge CSV is **binary-string candidate inventory**, explicitly **not a parsed Spine animation list**. No access to owner's E: raw Spine bytes in this session; **no source binary was hashed or played back now**.

### Repo-backed current rigs — exact input dependency packets

Each `godot/assets/actors/<id>/asset.json` and its `animations.tres` independently lists only `stand` (48 frames) and `walk` (24 frames), 30 FPS; all three Scene references point to the respective `animations.tres`. Four WebP pages **are physically present in GitHub** across the three rigs (2+1+1), alongside the .tres/.tscn manifests. **Zero** matching original `.skel`, `.atlas`, or original input PNG triplets are present in the game repo tree. Nine exact upstream input files are therefore **not accessible inside PR20**; paths/hash below are manifest RECORDS, **not independently verified current E: bytes**.

- **`1113028_1`**: skeleton `1113028_1.skel_TextAsset_2464183327200521619.bin` (262819 B; SHA256 `8c089d8837cf87bc573c63f39e37577af1b0062a9903a1acc2ecbd8ccedb00d8`); atlas `1113028_1.atlas_TextAsset_4732095381105324012.bin` (3745 B; SHA256 `01c4fa52a3e782fc2c08ad9dbdfb08ad025eca03334fb5b555d42ec74d22cc75`); texture `1113028_1_Texture2D_735480216125144147.png` (105725 B; SHA256 `5d5019d01279254be3e2f3430da8955a685b35ab5e93ad1798c753be189582d1`).
- **`body_1110201`**: skeleton `body_1110201.skel_TextAsset_-6433388427377235896.bin` (187109 B; SHA256 `89048d6b4c385cdb70f5382637b28469e13ebbd423d53cb39112d4f442eff5f2`); atlas `body_1110201.atlas_TextAsset_3407224732438477998.bin` (4755 B; SHA256 `5536436440f1104dcd7c4ba1531323580b9bb2c5ed2652fb87f4101deef8e56c`); texture `body_1110201_Texture2D_181697431273634149.png` (83166 B; SHA256 `13438d351fa83f0454b208b615954d32c069443e5e6c5ba6125708c28fbb7670`).
- **`body_1120402`**: skeleton `body_1120402.skel_TextAsset_8454442484532860036.bin` (213545 B; SHA256 `e9d6075c4673690a55d9029bf60ba210ea9610e369a3de13d890c26f90072a3d`); atlas `body_1120402.atlas_TextAsset_4916636876815428352.bin` (7227 B; SHA256 `73c83bce3828e3afd6dba522ce771368a06682d8d9256df2c7e8501edee0b2e4`); texture `body_1120402_Texture2D_907649722946377334.png` (133372 B; SHA256 `1ed18ce80a4096c0cc1cd170db4dbd7c74dd0ca20296fcada87e744ffc5aefd4`).

The SHA256 values above are metadata in `asset.json` for matching owner-held inputs, not hashes calculated during this audit. No `mining`, `chopping`, `planting`, `work`, `dig`, `attack` animation has been imported into any of the three SpriteFrames. This does **not** prove the original `.skel` lacks other authored clips: Batch-01 deliberately exported `stand/walk` for the current game rigs.

### Source Knowledge cross-check — 803 candidate skeleton records

| Live rig | CSV category (folder label, **not visual-sex proof**) | Binary candidate strings (not confirmed clips) |
|---|---|---|
| `1113028_1` | `body_female` | `attack1|attack2|attack3|attack4|attack5|dead|hit|idle1|idle2|idle3|idle4|idle5|run|stand|walk` |
| `body_1110201` | `body` | `attack1|attack2|attack3|attack4|attack5|attack6|attack7_1|attack7_2|attack7_3|dead|hit|idle1|idle2|idle3|idle4|idle5|run|stand|walk` |
| `body_1120402` | `body_female` | `attack1|attack2|attack3|attack4|attack5|attack6|attack7_1|attack7_2|attack7_3|dead|hit|idle1|idle2|idle3|idle4|idle5|run|stand|walk` |

- All **803** CSV rows explicitly record `confirmed_clip_list = NO - binary strings only` and `godot_playback = NOT TESTED` (source-knowledge report status, not a claim about our separately baked `stand/walk` imports). Across candidate tokens, **zero** exact `mining/mine/chop/chopping/plant/planting/dig/sow/harvest`; only **two** candidate `work` records. This is limited to this indexed sample and candidate naming; other action names or non-skeletal VFX remain UNKNOWN.
- `113116_1_s` (category `body_special`): skeleton `E:\GameAssetExtract\Assets\Characters\AndroidData_character\spinelib\body_special\113116_1\113116_1_s_skeletondata\113116_1_s.skel_TextAsset_8213755544725650990.bin`, 273297 B, SHA256 `7e2265246f65528fe047a934108d2574400ab236effb4b2e05cba6221f2b7465`; candidate state `work`; `confirmed_clip_list = NO - binary strings only`, `godot_playback = NOT TESTED`; texture_file EMPTY IN INDEX — prerequisite unresolved.
- `113116_1` (category `body_special`): skeleton `E:\GameAssetExtract\Assets\Characters\AndroidData_character\spinelib\body_special\113116_1\113116_1_skeletondata\113116_1.skel_TextAsset_-4762236696095387839.bin`, 851699 B, SHA256 `d5966896793e9b0f9a9d3ec6914fdbe3c1209779473c566397c04c88634a8136`; candidate state `work`; `confirmed_clip_list = NO - binary strings only`, `godot_playback = NOT TESTED`; texture_file EMPTY IN INDEX — prerequisite unresolved.
- **Classification conflict to verify, not auto-fix:** `body_1120402` sits under `body_female` in Source Knowledge but the live `DiscipleSourceAVisualPool` labels it `male` from previously inspected artwork. This is evidence of disagreement between folder category and the project's visual labeling, **not** proof that either identification is wrong. Do not silently swap sex rigs or alter presentation without a fresh visual check.
- The existing Batch-01 `body_1120101_s` **13-clip technical converter PASS** is a *different skeleton* and, without the exact imported names and real visual action, **does not substantiate mining/chopping/planting** on our three map rigs.

### Smallest honest pilot and binary gate — ART PENDING

1. **No Windows needed for this docs audit.** The missing proof is in the owner's existing original Source A location `E:\TongMonBaDaoWorkspace\02_SourceA\GameAssetExtract` (historical Source Knowledge uses `E:\GameAssetExtract`), existing `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472` converter and `05_DauRa\Assets_Godot472`. No new tools, full-batch conversion or ZIP upload required now.
2. In a **separate future authorized, isolated read-only source check**: first test **one smallest candidate skeleton** `113116_1_s` (273,297 B; SHA256 `7e2265246f65528fe047a934108d2574400ab236effb4b2e05cba6221f2b7465`) and its **matching atlas AND texture**. The CSV has no texture_file metadata for this candidate: recover/check the correct companion triplet before any converter attempt. Parse source animation names with already working Spine 3.8 pipeline; inspect genuine `work` timeline/playback for visible hand/tool/contact/recovery. If the clip or required texture is absent or artwork is not appropriate, **STOP / record `SOURCE_A_AUTHORED_WORK_ACTION_NOT_PROVEN`**. Its `body_special` category does not establish human-disciple suitability or sex.
3. Separately verify the original .skel triplets above for the current male/female game rigs; do not infer work-action availability from attack/idle candidate strings, and do not repurpose attack as mining/chopping/planting. For exact Mine/Forest/Field animation, require verifiable authored action pose, not just a `work` name.
4. **Only if** real artwork, lawful reuse scope, exact SHA256, clip playback and proper character sex/foot anchor are proven: export **one rig × one authentic action** using the existing converter, retain immutable source and scene/import hashes, then focused Godot 4.7.2 image/playback at 1280×720. Expand later only after owner art approval. Keep existing `stand/walk` and receipt/progress UI unchanged otherwise.
5. **No source-authored action suitable for G1 proven as of this audit.** G1 visual owner acceptance, Android frame-time/device and latest-HEAD official Godot runtime remain PENDING. Commercial redistribution rights are not proven by owner personal-use access. No CI/FULL/merge/G2 or gameplay/Save/Economy V2 authority changes.

---


**17/10/2026 · PR #20 stacked draft · Godot 4.7.2 · target 1280×720.** This is an **asset-proof packet only**. It does not authorize fabricated assets, new gameplay/animation clock, copying unverified binaries, CI, FULL or merge.

## 1. Verified repo audit (read from exact Source A binaries metadata)

All **three** current verified baked character rigs have **only `stand` and `walk`** in both `godot/assets/actors/<id>/asset.json` (`clips[].name`) and `animations.tres` SpriteFrames:

| Rig | Sex proven by prior actual artwork inspection | Repo clips | Missing |
| --- | --- | --- | --- |
| `1113028_1` | Female | `stand`, `walk` | `mining`, `chopping`, `planting` |
| `body_1110201` | Male | `stand`, `walk` | `mining`, `chopping`, `planting` |
| `body_1120402` | Male | `stand`, `walk` | `mining`, `chopping`, `planting` |

Current `ModularDiscipleActor` chooses an *actually present* action animation if provided, otherwise `stand`; the displayed map job/progress cue is **not an animated dig/chop/plant action**. No real action clip has been imported or visually tested. This explains the owner's “đi mỏ nhưng không thấy đào” feedback despite production jobs working.

## 2. Smallest feasible verified-asset task (future separately authorized art work)

1. Work with the owner's **already existing** Batch-01 conversion output at `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472` and the original accessible, licensed Source A Spine sources. Inspect the *actual animation names* / captured playback for `1113028_1`, `body_1110201`, `body_1120402`; never infer action presence from filenames or game concepts. Do not rerun/rebake all 10 rigs.
2. Prefer a **single male rig + single female rig** as pilot, reusing rig across disciples by sex/cosmetic seed. For each, search for authored action compatible with mining/chopping/planting; require actually animated hands/tool/contact/feet. If genuinely absent, report `SOURCE_A_AUTHORED_ACTION_NOT_FOUND` with precise rig and animation inventory. **Do not relabel stand/walk as digging or invent the clip.**
3. Only if authentic action frames exist, export at the converter's already verified settings, preserve the same frame registration/foot anchor and cropping/scale, add to `animations.tres` and update `asset.json` `file_sha256` based on actual bytes; preserve provenance manifest and original atlas. Check SHA256 for every listed binary; run only one pilot renderer check. If output/manifest cannot be safely updated, do not integrate.
4. When valid, visually map action to `ModularDiscipleActor` **only when the corresponding real saved job/plot exists**, with left/right facing/mirror; vertical movement still uses the same horizontal artwork. Existing `stand/walk` fallback continues for rigs missing verified action. Do not alter `SimulationScheduler`, work duration, receipt timing, resource amounts, paths or SaveService.
5. Acceptance: one native 1280×720 screenshot/video with a selected Mine worker showing actual action and worksite progress, another for Linh Lâm / Linh Điền if real clips were found, plus focused play/sex/seed/loop tests. **Android and owner visual signoff remain PENDING** until performed.

**IMPORTANT:** Source A Batch-01 converted technical PASS does **not** prove source contains mining/forest/planting animations. Existing Windows user has these binaries locally; avoid requesting mass asset reuploads. If no verified original action exists, plan a **separate explicitly authored artwork job**, identified honestly as *new art*, not Source A extraction. Do not create that artwork within this packet.

## 3. Immediate current implementation

PR #20 presentation already has a small per-instance `SectProductionWorksiteCue` with saved scheduler progress, planned output and settlement-only `+N đã vào kho`. The actual digging motion is **separate missing art debt**, not a reason to create fake yield or add carry-cycle simulation. G1 owner visual acceptance stays **OPEN**.
