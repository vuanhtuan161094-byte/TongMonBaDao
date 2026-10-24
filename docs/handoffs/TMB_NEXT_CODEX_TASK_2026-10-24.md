# NEXT CODEX TASK — TÔNG MÔN BÁ ĐẠO PR #28 UI + SOURCE A WORKER ASSETS
Ngày: 2026-10-24
**Hướng dẫn hiện hành trên nhánh PR #28; thay thế phần prompt UI-only cũ tại file này.**

## Sự cho phép và đối tượng

Owner **đã mở rộng** nhiệm vụ: vừa sửa UI/UX trực tiếp trong Godot P3.2, vừa **gắn thêm asset đã được worker chuyển đổi** nếu manifest/hash/runtime QA đạt. Chỉ đổi visual adapter, asset registry, UI và test; giữ toàn bộ gameplay canonical. Không xây renderer mới, không giả action clips.

Repo: vuanhtuan161094-byte/TongMonBaDao
Base PR #27 head: deeae081bcfbe1413d4cf60a29db7e58150888b5
Draft PR #28 head branch: ui/pr27-runtime-readability-20261024
Godot: official 4.7.2; Android landscape reference 1280x720
PR #24–#28: không merge; không FULL/CI; không rebase vào main.

**BẮT BUỘC đọc toàn bộ packet mới trước khi làm:**
docs/handoffs/TMB_PR28_UI_SOURCEA_WORKER_ASSET_INTEGRATION_PACKET_2026-10-24.md

Cũng đọc AGENTS.md, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md, các handoff PR27, docs/P3_ART_BIBLE.md, manifest Source A, Codex handoff ZIP và tài liệu PR28 UI PASS1.

## Prompt thực thi rút gọn

TÔNG MÔN BÁ ĐẠO — TIẾP TỤC PR #28. Hãy fetch HEAD mới nhất của nhánh ui/pr27-runtime-readability-20261024 và đọc đầy đủ docs/handoffs/TMB_PR28_UI_SOURCEA_WORKER_ASSET_INTEGRATION_PACKET_2026-10-24.md. Thực hiện trọn G0→G3 trong packet: kiểm kê output asset Source A do worker tạo (repo, các branch chuyên dụng, worktree/output local đã có quyền), đối chiếu SHA, clips, FPS/frames, pivot, giới tính/loài, import Godot; skip trùng và reject asset lỗi. Gắn các asset VERIFIED mới vào chính scene P3.2 đang chạy: map/công trình/Mỏ–Linh Lâm–Linh Điền, nhân vật/hồ sơ D7 và Combat V5 view adapter, theo thứ tự ưu tiên. Sửa tiếp readability UI PR28, KHÔNG viết lại renderer hoặc giả animation đào/chặt/trồng/Boss. Không sửa Combat V2/V3, HP/ATK/DEF/balance x100, D7 odds, CARE, Warehouse, scheduler, thuốc, Injury120, SaveService, economy. Chạy Godot 4.7.2 official focused với userdata cách ly; chụp screenshot thật 1280x720 trước/sau ở cùng tình huống; giữ log FAIL O9 ban đầu và clean PASS tách biệt; chứng minh Warehouse receipt / actor save-load không bị ảnh hưởng. Commit từng category nhỏ lên nhánh PR28, cập nhật báo cáo/manifest/issue matrix trong GitHub, nêu SHA và gate PENDING. Không FULL/CI, không merge PR #24/#25/#26/#27/#28. Windows manual/Android/Owner Visual chỉ PASS khi có bằng chứng thực tế. Nếu worker outputs chưa truy cập được thì thực hiện phần có asset VERIFIED và báo rõ BLOCKED_ASSET theo đường dẫn, không bịa ảnh hay asset.

**Nhiệm vụ kết thúc** sau khi bàn giao README/report và evidence; không tự merge. Thứ tự ưu tiên phải theo packet G0→G3, không quay về prompt cũ cấm động vào mọi asset/visual adapter.
