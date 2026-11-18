# TMB One Game / E Recovery — kết quả 2026-11-19

## Kết luận và snapshot

- PR #72: `264514ff760eaf22b339cb75ca29be53f9ab8351`, branch `integration/pve-p0-playable-ui-20261103`, **OPEN / DRAFT**, chưa merge. PR base hiện là `integration/tri-facility-a-b-playable-20261102`.
- `main`: `c0c1382f119599497b52d8ee8abd9e830a883f1e`. So với PR #72: **DIVERGED**, PR ahead 2,747 commit và behind 1. Không merge.
- E canonical: `E:\\TongMonBaDaoWorkspace\\01_Game\\TongMonBaDao`, branch `integration/tri-facility-a-b-playable-20261102`, HEAD `27ed01cd8f377994e5e50bac9ede84e78e8895bd`; là ancestor của PR HEAD (PR ahead 2,417, behind 0). Checkout có **470 tracked changes và 362 untracked**; tuyệt đối không pull/sync/checkout đè hoặc chạy từ đây.
- PR QA checkout ở E: `E:\\TongMonBaDaoWorkspace\\01_Game\\QA_WORKTREES\\TMB_PVE_P0_QA_20261103`, SHA `e888c010d6cfb09a97ce48af19d1a2f42a401240`, dirty (233 tracked, 151 untracked). Không cập nhật.
- Snapshot Git worktree: 23 registrations, 7 đường dẫn cũ thiếu, 12 worktree còn tồn tại có thay đổi. Các tên thư mục tương tự không được xem là duplicate nếu chưa xác minh nội dung.

## Inventory E: (read-only)

Bằng chứng được xuất tại:

`E:\\TongMonBaDaoWorkspace\\03_QA_Logs\\ONE_GAME_INVENTORY_20261119_002036`

Thư mục có `inventory.csv/json`, `worktrees.txt/json`, `launchers.txt`, `PROPOSED_CLEANUP_ONLY.md`, README, danh sách asset Source A, kết quả hash tĩnh và smoke harness Wiki. Inventory có 90 mục; đã nhận diện 15 thư mục con tức thời dưới `01_Game` và 35 launcher. Không follow junction/reparse point khi duyệt. Không xóa, di chuyển, dọn hoặc ghi đè nội dung nào trên E:.

- E còn trống xấp xỉ 43.08 GiB tại thời điểm đo.
- Backup R0 `E:\\TongMonBaDaoWorkspace\\90_Archive\\TMB_R0_BACKUP_20261104_145049` còn nguyên; manifest checksum đối chiếu khớp `EA753053E1DFBFD490E725C7FDD86B26FF565EA4BB10920805AA74571EDEF509`. Không mở hoặc thay đổi nội dung Save.
- Source roots thấy trong workspace: `02_Assets\\AssetLibrary_SourceA\\SourceA`, `02_Assets\\Character_Animation`, `02_Assets\\SourceA_Original\\GameAssetExtract`, `02_Assets\\SourceA_Original\\ZQZS-Source-Knowledge`.
- Một project `TMB_V65_D4A_20261029` còn file game nhưng gitlink trỏ tới worktree C: không còn; phân loại `BROKEN_GITLINK_KEEP`, không xóa.
- Các folder thiếu `project.godot`, checkout bẩn và archive chưa được gom/xóa. `PROPOSED_CLEANUP_ONLY.md` chỉ là đề xuất để Owner xem xét.

### Godot và launcher

- Godot official tại `E:\\TongMonBaDaoWorkspace\\04_Tools\\Godot\\Godot_v4.7.2-stable_win64.exe`, version `4.7.2.stable.official`, SHA-256 `AB1824F85BFD8E0E4128182C000C4003A3E042245B2967848D089B2A04B22424`.
- Canonical launcher được tài liệu chỉ định: `E:\\TongMonBaDaoWorkspace\\01_Game\\TongMonBaDao\\MO_GAME.cmd`. Nó chưa được chạy; checkout của nó đang dirty. Vì vậy launcher là **INTENDED / NOT_VERIFIED**, chưa thể xác nhận đây là đường mở an toàn hoạt động với HEAD PR hiện tại. 35 launcher được liệt kê trong inventory; không launcher nào được chạy.

## Source A — tình trạng tích hợp thật

Nguồn đối chiếu là PR HEAD `264514ff760eaf22b339cb75ca29be53f9ab8351`; các commit từ snapshot Source A trước đó chỉ đổi AGENTS/VFX, không đổi các file asset/renderer được dẫn dưới đây.

- Map manifest `godot/data/presentation/map25_source_a_verified.json` (Git blob `234cfd75e3e5db19cc6f98ea610debda35363c6b`) có **34 file**: 29 terrain/road/vegetation Source A còn được map renderer nạp có điều kiện theo exact SHA; 5 ảnh nhà Source A cũ còn ở manifest nhưng không còn là lựa chọn texture công trình hiện hành. Hai checkout E khớp hash **34/34**; `.import` sidecar/cache có đủ **34/34** nhưng chưa chạy Godot import, nên **GODOT_IMPORTED = NOT_EXECUTED**.
- Runtime code: `sect_map25_source_art.gd` SHA blob `f18651f9b224b558ef1512a13aaa589dfda117c4`; map world SHA blob `71ba03ad3a0c798631758171f6355c77f56a3ed2`. Binding có điều kiện không chứng minh đã render trong GUI. Environment hiện vẫn dùng Source A; chỉ các ảnh BUILDINGS cũ được thay/retire khỏi lựa chọn map, không phải toàn bộ Source A.
- Công trình: 5 ID cũ 510052/510076/510102/520081/510111 vẫn làm key. Code ưu tiên VIS11 A, rồi VIS08; mỏ ưu tiên VIS11 A, fallback VIS09. VIS11 có 6 cặp A/B; code chọn A/B theo `view_direction`, nhưng chưa chụp GUI ở exact HEAD để xác minh hiển thị hai hướng. VIS08/VIS09 còn pending Owner visual review; sheet VIS11 đã được duyệt ở cấp sheet, render hiện tại vẫn cần xem lại.
- Actor: 7 package manifest có asset.json blob khớp **7/7**; 31 file xuất mỗi checkout đều hiện diện, chỉ **21/31** hash khớp, **10/31** mismatch nằm trong actor.tscn/animations.tres của 5 package và nguyên nhân chưa được xác minh. 24 clip declarations có 23 frame-count khớp; Boss-slot `dead` khai 30 nhưng chỉ có 21 frame. Không gọi Boss identity hoặc COMBAT_READY. Bảy package được phân loại trong Wiki: identity/role unknown, nữ candidate, nam package, monster, Boss-slot candidate.
- Visual manifest Source A khai 4 role (đệ tử nữ, đệ tử nam, quái 1113031, Boss-slot 410041); code V5 atlas có đường kết nối có điều kiện. Không có ảnh capture mới xác nhận actor xuất hiện trong combat/map.

## Tàng Kinh Các

Đã cập nhật đúng Wiki hiện có, không tạo Wiki/dashboard mới:

1. `wiki/data/game_system_audit.json`: thêm `sourceARecoveryAudit` với snapshot HEAD, manifest/hash, E copies, clip/status, runtime callsites và gaps.
2. `wiki/guide.js`: thêm panel Source A nằm trong trang tiến độ toàn game; không thay tổng 49 mục hiện có. Panel tách FILE_PRESENT / import cache / RUNTIME_BOUND / VISIBLY_RENDERED / Owner approval và hiển thị mismatch.
3. `docs/wiki/TMB_WIKI_SOURCE_AUDIT.md`: thêm overlay 2026-11-19, giữ snapshot catalog nền cũ làm lịch sử.

Các gap còn mở: công trình 26 thiết kế so với 8 runtime type (6 trong cây + 2 ngoại lệ), trang bị spec 10 slot so với 3 slot runtime (Owner quyết định), SX07 630 slot thiết kế/11 ID đăng ký; 270 source profiles không phải điểm farm thật; 476 định danh đan, 119 recipe IDs nhưng 8 bodies/cảnh giới có recipe và 444 mã thiếu recipe body; 101 trait V2, 41 hiệu ứng mô tả/12 blocked/48 chưa duyệt/0 hiệu ứng V2 được xác minh; 2,196 V6.3 candidate IDs / 420 family, gate vẫn OFF và không phải gameplay live.

## Kết quả kiểm tra và phần chưa làm

- PASS: kiểm kê tĩnh các checkout/worktree/launcher theo phạm vi chỉ định; bản kê bằng chứng được copy sang QA Logs.
- PASS: hash Source A map 34/34 ở hai checkout E; asset.json manifest blob 7/7.
- PASS: JSON schema parse, JavaScript syntax và focused source-render smoke cho panel Wiki trên candidate trước khi ghi (34 dòng map/7 actor).
- NOT_EXECUTED: Godot import/headless/GUI, screenshot 1280×720, launch game, player test, FPS/RAM. Không gọi cache sidecar là import PASS.
- NOT_EXECUTED: xóa/dọn/sync checkout, di chuyển project/asset, đụng Save. Mọi dữ liệu owner/worktree dirty vẫn được giữ nguyên.
- Owner art review: **PENDING**; render exact HEAD: **PENDING**.

**Một lệnh mở game:** hiện chỉ có đường dẫn canonical dự định là `MO_GAME.cmd` nêu trên; do checkout E đang dirty và launcher chưa chạy, trạng thái vẫn **NOT_VERIFIED**. Không thể xác nhận một launcher an toàn dùng được mà không có bước Owner chọn/QA checkout sạch sau này.

## Liên kết bằng chứng

- Inventory folder: `E:\\TongMonBaDaoWorkspace\\03_QA_Logs\\ONE_GAME_INVENTORY_20261119_002036`
- PR #72: https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72
- Issue #56: https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56
