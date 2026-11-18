# CODEX WINDOWS LOCAL — ONE GAME / E: / SOURCE A / CHỨC NĂNG THẬT

Ngày giao: 18/11/2026. Người dùng yêu cầu giao Codex xử lý tình trạng nhiều bản game trên E:, các asset thay Source A chưa nhìn thấy trong game và nhiều mục chỉ có tên chưa có thiết kế/chức năng.

Repository: vuanhtuan161094-byte/TongMonBaDao
Production candidate: PR #72 Draft, branch integration/pve-p0-playable-ui-20261103.
One-game release tracking: Issue #56. Không tạo thêm PR release, Wiki, issue hoặc bản RC riêng.
**CODEX LOCAL WINDOWS BẮT BUỘC cho kiểm tra ổ E:** Nếu Codex đang chạy Cloud và không truy cập được ổ E thật, ghi LOCAL_E_ACCESS_BLOCKED, chỉ làm phần kiểm kê GitHub; tuyệt đối không giả khẳng định đã quét hoặc dọn E.

## MỤC TIÊU BÀN GIAO

Chỉ còn một bản game ứng viên xác định được nguồn, HEAD và launcher. Asset có bốn trạng thái riêng: FILE_PRESENT / GODOT_IMPORTED / RUNTIME_BOUND / VISIBLY_RENDERED + trạng thái chủ dự án duyệt. Hệ thống game có các trạng thái riêng: DESIGN_ONLY / CATALOG_ONLY / CODE_PRESENT / CONSUMER_WIRED / PLAYER_TESTED. Xuất báo cáo ngắn, không thêm bảng kiểm song song ngoài Tàng Kinh Các.

## 0 — PRE-FLIGHT

1. Fetch LIVE PR #72 HEAD và trạng thái main, không dùng SHA cũ. Đọc AGENTS.md, CURRENT_CHECKPOINT.md, docs/operations/TMB_ONE_WORKSPACE_WINDOWS_20261027.md, docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md và các tài liệu VIS-08, VIS-09, VIS-11, VFX coordination/handoff. Có các chat/Codex khác đang viết nhánh #72, tuân thủ mỗi file một writer; kiểm HEAD trước mỗi ghi.
2. Lấy bản ghi git worktree list --porcelain, git status --porcelain=v1 -uall, git rev-parse HEAD và remote origin ở từng checkout; xác minh reparse point/junction để không đi vòng vô hạn.
3. KHÔNG chạy git clean / git reset --hard / Remove-Item / robocopy /MIR / git gc / git worktree prune / force-push / merge / rebase / thay driver, không xóa Save, ảnh nguồn, output unique. Không thực hiện đồng bộ ghi đè khi chưa kiểm tra untracked/dirty/backup.

## 1 — KIỂM KÊ Ổ E (CHỈ ĐỌC)

Ưu tiên kiểm tra:
- E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao — canonical checkout theo hồ sơ.
- E:\TongMonBaDaoWorkspace\02_Assets — Source A và masters, không quét sâu toàn bộ file texture.
- E:\TongMonBaDaoWorkspace\03_QA_Logs — nơi xuất bằng chứng.
- E:\TongMonBaDaoWorkspace\04_Tools — Godot 4.7.2.
- E:\TongMonBaDaoWorkspace\90_Archive — bảo toàn, không xóa.
- E:\codex và các game/worktree khác có thực (quét danh sách thư mục theo giới hạn, không follow junction, không duyệt sâu toàn ổ).

Mỗi nơi có dấu hiệu game: absolute path, physical/junction target, Git branch, exact SHA, commit date, dirty tracked/untracked, loại bản game và launcher, Godot project path, app-managed Codex session, Save/asset master độc nhất, dung lượng xấp xỉ. Phân loại CANONICAL / ACTIVE_CODEX_WORKTREE / SAVE_PROTECTED / MASTER_ASSET / QA_OUTPUT / VERIFIED_DUPLICATE / ARCHIVE / UNKNOWN. Không đánh dấu trùng chỉ do tên giống hay ngày giống; hash xác minh mẫu khi thực sự cần.

Xuất tại E:\TongMonBaDaoWorkspace\03_QA_Logs\ONE_GAME_INVENTORY_<timestamp>\ các tệp inventory.csv, inventory.json, worktrees.txt, launchers.txt và PROPOSED_CLEANUP_ONLY.md. KHÔNG DI CHUYỂN, XÓA HOẶC DỌN BẤT KỲ TỆP NÀO TRÊN E TRONG TASK NÀY. Nếu chưa xác định được root game thì dừng sync, nêu lý do.

Giữ backup R0: E:\TongMonBaDaoWorkspace\90_Archive\TMB_R0_BACKUP_20261104_145049; bảo toàn mọi Save/tranh gốc và lịch sử commit.

## 2 — RÀ ASSET THAY SOURCE A VÀ KHẢ NĂNG NẠP THẬT

Đối chiếu GitHub HEAD và bản E thực:
- Renderer godot/src/presentation/p3/sect_isometric_world_v1.gd: _load_verified_source_art().
- Các nhà cũ giữ ID 510052 / 510076 / 510102 / 520081 / 510111 làm key, KHÔNG nhất thiết đang hiển thị ảnh cũ.
- Code đã thấy tại checkpoint: VIS11_AB.texture_for(house, A) ưu tiên; sau đó VIS08. Mỏ ưu tiên VIS11 A, dự phòng VIS09. Kiểm tra đúng SHA xem trật tự đã đổi chưa.
- 6 cặp A/B của godot/src/presentation/p3/tmb_building_art_ab_v7.gd và godot/art/tmb_buildings_ab_v7. Có hai hướng trong pack KHÔNG chứng minh runtime đã chọn cả A+B.
- Đại Điện, Mỏ VIS09; 12 ảnh V3 Linh Lâm/Linh Điền/Luyện Đan; nơi UI facilities lấy texture riêng.
- Đường, sân, cây trong godot/art/source_a_env02a vẫn được code nạp: chỉ retire Source A BUILDINGS, không tuyên bố game sạch toàn bộ Source A.
- Nhân vật AS-CHAR-38/39/49, các gói animation, VFX: không xem video/GIF/lab là đã xuất hiện trong PvE chính; riêng VFX theo gate duyệt của nhóm, không tùy ý tích hợp.
- Mỗi asset: ID, SHA/hash, nguồn ảnh/master, Godot import OK?, runtime binding/callsite, phía map UI nào, pivot/scale, screenshot thực Godot 1280x720 tại exact SHA, trạng thái owner APPROVED/PROVISIONAL/REJECTED/UNKNOWN. Không tự thay asset owner chưa duyệt.

Nếu asset độc lập đã được người dùng duyệt rõ và có đầy đủ master/import, Codex có thể đề xuất/triển khai **một sửa chữa trình bày nhỏ và tách biệt** trên PR #72 khi không xung đột file; chạy Godot 4.7.2 import + một screenshot native, ghi exact SHA. Không sửa combat, gameplay, kinh tế, SaveService hoặc kích hoạt VFX chưa duyệt. Những gì cần owner art review ghi PENDING thay vì gọi DONE.

## 3 — CHỨC NĂNG CHỈ CÓ TÊN VÀ CÔNG TRÌNH

Không xây Wiki mới: cập nhật Tàng Kinh Các hiện có tại wiki/guide.html và wiki/data/* với bằng chứng code. Bóc tách ID/name, design_state, runtime_state, source paths, consumer, output, upgrade, UI access, chi tiết còn thiếu.
- D7 nhân vật: 101 Trait, Thiên Mệnh/Thể Chất/Huyết Mạch, 16 combat stats, 10 kháng hệ, tu luyện và tu thân. Không gọi tên đặc tính = hiệu ứng đã chạy.
- Cây công trình 26 loại, 8 runtime type (6 trùng cây + 2 ngoại lệ), 20 loại thiết kế chưa có; xét từng loại Lv1-100 và chức năng nâng cấp thực.
- Trang bị V2 10 ô + đồ bộ 24, 12 phẩm, nơi nhận trang bị, rèn, tháo/đeo, nâng cấp, so với hệ 3 ô cũ.
- Nguyên liệu 630 design slot với 11 ID đã đăng ký trong phạm vi; 270 source design profile không phải điểm farm thật; 476 mã đan, 119 recipe ID, 8 họ/cảnh giới có recipe body, 444 mã thiếu recipe.
- V6.3, trận đấu, VFX, UI, Warehouse, jobs, Save: phân biệt import, callback, runtime gate, player QA; không sinh mới hàng trăm placeholder để tăng tổng.

Mục tiêu là **trạng thái thật và việc cần làm**, không được khai báo "đã hoàn thiện thiết kế" chỉ vì có tên hoặc spec ứng viên. Có thể sửa mô tả/dữ liệu Wiki khi có nguồn; không tự lập trình các cơ chế D1-D6 chưa được người dùng chốt.

## 4 — XÁC LẬP MỘT NƠI CHƠI

Tài liệu canonical chỉ định E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao và launcher MO_GAME.cmd. Repo còn CHOI-GAME.cmd (launcher có kiểm chứng riêng); cần thống kê phụ thuộc trước khi ẩn/gỡ. Mục tiêu báo cho người dùng **MỘT đường dẫn mở game**, kèm checkout SHA, tình trạng đồng bộ PR #72 và tình trạng Godot 4.7.2.

Nếu E game dirty/có unique untracked, KHÔNG git pull --overwrite, không checkout mới rồi đổi shortcut âm thầm. Xuất kế hoạch bảo toàn/đồng bộ và đánh dấu BLOCKED. Nếu có môi trường chạy, chỉ thực hiện QA tối thiểu đúng phần sửa: Godot import + ảnh scene thật, launcher preflight; không lặp lại P0 end-to-end. Không gắn physical GUI PASS nếu chỉ là automation/headless. Không merge main.

## DELIVERABLE & KẾT THÚC

- Báo cáo trên PR #72: docs/operations/TMB_ONE_GAME_E_RECOVERY_RESULT_<date>.md (khi an toàn, một writer), nêu rõ E thực đã quét hay chưa, từng worktree/đường dẫn, bản đang mở, E root SHA, MAIN-vs-PR72, Save cần giữ, asset cần thay/thay rồi, công trình/nhân vật/item còn gap, một launcher để mở game.
- Chỉ có một Tàng Kinh Các: cập nhật các dòng đã kiểm được, không tạo dashboard phụ.
- Phần asset đã duyệt có thể tích hợp từng nhóm nhỏ nếu có bằng chứng, còn owner visual pending ghi HOLD.
- Comment kết quả vào Issue #56; không mở issue/PR mới.
- Trình bày tiếng Việt, rõ từng việc ĐÃ LÀM và CHƯA LÀM; không tự đòi người dùng đóng vòng P0 lần nữa.

**Không có tool Codex remote trong chat này.** File handoff chỉ là chỉ dẫn; phải có một phiên Codex Desktop/Local được người dùng mở mới thực thi được các bước trên E.
