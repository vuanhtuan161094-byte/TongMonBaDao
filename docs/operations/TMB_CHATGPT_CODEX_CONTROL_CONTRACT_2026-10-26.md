# TÔNG MÔN BÁ ĐẠO — HỢP ĐỒNG ĐIỀU PHỐI CHATGPT ↔ CODEX WINDOWS

**Hiệu lực điều phối:** 26/10/2026 · **Trạng thái:** chỉ tài liệu, không thay gameplay, không merge.  
**Master discussion:** [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37).  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao` · Godot 4.7.2 · Android landscape 1280×720.

## 1. Vì sao cần hợp đồng này

`AGENTS.md` và các checkpoint lịch sử vẫn có quy định workflow/mục tiêu cũ (ví dụ quy mô 1.000–3.000 đệ tử, hạn chế Codex), còn Issue #37 ghi nhiều lần chủ dự án đổi hướng. `CURRENT_CHECKPOINT.md` và `NEXT_CHAT_HANDOFF.md` chứa lịch sử rất dài; **không dùng mục gần đầu hoặc một test PASS làm bằng chứng trạng thái sản phẩm mới nhất**. Chủ dự án đã xác nhận mục tiêu khoảng 200–500 đệ tử tông môn, PvE 20 vùng/200–400 quái/≤30 người săn là *mục tiêu dài hạn*, không bắt buộc 3.000 đệ tử.

**Quy tắc phân xử:** quyết định mới, rõ ràng của owner ngày 26/10 > chỉ dẫn điều phối trong tài liệu này > các quy định thao tác cũ khi mâu thuẫn. Các gameplay invariants trong `docs/GAME_SYSTEM_ARCHITECTURE.md`, `AGENTS.md`, Combat V2 và code authority vẫn được giữ nguyên; hợp đồng này **không cấp quyền thay đổi luật combat, loot, economy hay save**. Nếu nhánh local có quy định mới hơn của owner, báo rõ xung đột và áp dụng chỉ thị mới hơn, không bí mật đổi scope.

## 2. Phân quyền và kênh trao đổi (không có điều khiển trực tiếp ngầm)

| Vai | Chịu trách nhiệm | Tuyệt đối không làm |
| --- | --- | --- |
| Owner | Khóa trải nghiệm/visual, duyệt gameplay thay đổi và nghiệm thu hình ảnh | Không phải làm QA thủ công thay Codex |
| ChatGPT qua GitHub | Đọc HEAD/PR/diff/Issue; đối chiếu bằng chứng; quyết định ưu tiên sản phẩm; review rủi ro; cập nhật **một** packet chỉ đạo | Không ghi đè file/nhánh Codex Windows đang sửa, không nhận PASS từ báo cáo suông |
| Codex trên Windows E: | Đọc packet, khảo sát local dirty state, tự code/test/Godot GUI/capture, backup, commit/push nhánh sở hữu, đăng checkpoint vào Issue #37 | Không reset/clean/force-push dữ liệu chưa bảo vệ, không merge main, không tự chế loot, không đổi visual authority |
| GitHub | Sổ bàn giao: Issue #37 = ưu tiên hiện hành; feature branch/draft PR = code; log/ảnh/báo cáo = bằng chứng theo SHA; docs riêng = luật điều phối | Không phản ánh tự động mọi file local chưa push |

**Quan trọng:** Comment GitHub **không tự động điều khiển** phiên Codex đã chạy. Codex phải đọc lại Issue #37 và hợp đồng này khi bắt đầu **và trước checkpoint/đổi giai đoạn**. Nếu mạng/GitHub không đọc được, Codex không được giả định chỉ thị mới; giữ nguyên packet hiện tại và báo blocker.

## 3. Một ACTIVE DELIVERY PACKET, không tạo hàng chục đầu việc

Mỗi thời điểm chỉ **một packet implementation sở hữu các file giao nhau**. Các nghiên cứu/kiểm toán không thay runtime có thể thực hiện song song. Packet có tối đa 7 trường:

- **ID / version / chủ sở hữu file**;
- **Outcome người chơi thấy được**;
- **Local worktree/branch/base và remote observed SHA** (hai thứ có thể khác);
- **Authority không được đổi**;
- **Đầu ra và điều kiện nghiệm thu kỹ thuật + hình ảnh**;
- **Điểm dừng nếu blocker thật**;
- **Checkpoint: exact commit / trạng thái local / log / ảnh/video / FPS/RAM / nợ**.

Tạo ít tài liệu; dùng Issue #37 làm bảng điều khiển và **một** báo cáo checkpoint cập nhật, không copy trạng thái qua hàng chục tệp. Sau khi local được commit/push an toàn, điều chỉnh phần quy tắc thao tác cũ trong `AGENTS.md` trên **chính nhánh thực thi đang sở hữu**, với diff riêng/review trước; không vội chỉnh `AGENTS.md` trên một nhánh remote chồng lên việc chưa push.

### ACTIVE — PVE-VIS-01 (26/10/2026)

**Owner:** Codex Windows, thư mục `E:\codex\2026-10-26\TMB_PVE_JX_CONTINUOUS_WORKTREE_20261026`, nhánh `feature/pve-jx-continuous-world-20261026`.  
**GitHub observed 26/10:** remote nhánh này ở `038873592b908c05a28ac7f827a8b831fce000c8`; đây **không phải** bằng chứng HEAD local. Codex báo có sửa adapter `pve_jx_sword_vfx_adapter_v1.gd`, `sect_isometric_world_v1.gd`, JX manifest và GUI harness **chưa commit**. Cần tin `git status` local hơn GitHub đối với file chưa push.

**Một mục tiêu:** P3.2 Windows Godot 4.7.2 chạy bình thường **một bản đồ PvE liên tục, gần full-screen, có Source A terrain/rừng/trúc/đường**, 6 đệ tử thật click đất đi qua vùng, 10 quái tuần tra/aggro/Combat V2 tại chỗ, camera và minimap cùng world, kiếm JX #158 có cast → projectile/impact **chỉ sau hit thật**; có ảnh 1280×720 và video chơi thật, FPS/RAM và Save/Load. Nếu demo A/B/C khả thi với FX Source A đã xác minh thì ghi thêm; **không** để thiếu A/B/C ngăn phát hành video gameplay B có nguồn JX đúng.

**Giữ:** `SectIsometricWorldV1` / Source A map vibe; World PvE không phải 20 nút hoặc bản đồ tuyết JXQY2; Combat V2, One Active Job, Injury120, clock, canonical Warehouse, exactly-once Save. `LOOT_PENDING` phải công khai, không bịa loot. Không ưu tiên scale 20 vùng/400 quái, Forge, quét cả kho VFX hay Android trước khi lát cắt GUI nhìn/chơi đúng.

**Nghiệm thu:** (a) official Godot focused test trên exact SHA; (b) launcher P3.2 thông thường, không chỉ headless/harness; (c) ảnh/video thật có move→aggro→cast→positive hit→impact trong cùng world + minimap, không có modal battle; (d) kiểm tra Save/Load, đo FPS/frame-time/RAM; (e) mã mới được backup/commit/push không force, GitHub Issue #37 có checkpoint. Khi Computer Use/Escape ngắt: ghi **GUI PENDING**, không nhận VISUAL_PASS. `PVE-VIS-01` kết thúc ở một demo C01 playable; không tự nhảy sang PVE-SCALE.

## 4. Vòng lặp vận hành

**Codex nhận việc:** `git status --porcelain=v1 -uall`, `git branch --show-current`, `git rev-parse HEAD`, `git remote -v`, kiểm tra process Godot/MovieWriter, backup dữ liệu gốc và file unique/dirty. Đọc `AGENTS.md`, Issue #37 **comment mới nhất**, hợp đồng này (có thể `git fetch origin docs/chatgpt-codex-control-plane-20261026` rồi `git show origin/docs/chatgpt-codex-control-plane-20261026:docs/operations/TMB_CHATGPT_CODEX_CONTROL_CONTRACT_2026-10-26.md` để **đọc mà không checkout**), chỉ những source liên quan. Không `git reset --hard`, `git clean -fd`, checkout đè, force-push, tắt process không xác minh.

**Trong khi làm:** Codex tự chọn kiến trúc tối thiểu khả thi; implement→official Godot verify→GUI chơi thật→sửa visual/UX→verify lại. Ưu tiên kết quả trông/điều khiển đúng hơn tăng số bài test. Có lỗi máy, GUI, thiếu asset thì báo nguyên nhân và kết quả thật, không tạo placeholder đẹp giả hoặc PASS.

**Checkpoint:** sau một thay đổi runtime có ý nghĩa hoặc ngay khi blocker, tạo commit checkpoint có rollback rõ, push đúng nhánh khi an toàn, đăng **một comment ngắn** vào Issue #37:
```text
PACKET: PVE-VIS-01 | local branch/worktree:
LOCAL HEAD: ... | REMOTE HEAD: ... | DIRTY/UNPUSHED: ...
BUILT: ... | VERIFIED: official Godot version / test name / exit / SHA
GUI: PASS/PENDING/BLOCKED | SOURCE A VISUAL: ACCEPTED/PENDING/REJECTED
EVIDENCE: image/video/log paths or GitHub URLs | FPS/RAM: measured/not measured
KNOWN GAPS: ... | NEXT: ONE proposed playable improvement | NEED OWNER: only genuine decision
```
Không ghi toàn bộ nhật ký dài vào comment, dẫn liên kết file báo cáo/PR. Trước bước lớn tiếp theo đọc lại comment mới nhất và `git status` để bắt thay đổi ưu tiên.

**ChatGPT nhận checkpoint:** fetch remote refs thật, so commit/test SHA và comment, review ảnh/video có thể truy cập; phân loại VERIFIED BY CHATGPT / REPORTED BY CODEX / UNKNOWN; phát hiện lệch visual/authority; cập nhật **một** chỉ đạo hành động trong Issue #37, không làm thêm nhánh code giao nhau. Nếu chưa có commit thì không khẳng định ChatGPT đã thấy code local.

## 5. Prompt khởi chạy dành cho Codex Windows

> TÔNG MÔN BÁ ĐẠO — thực hiện **PVE-VIS-01**, tập trung kết quả **một PvE C01 Source A liên tục có thể mở/chơi/xem video**, không làm lại world JX tuyết, không tăng quy mô hoặc Forge. Đọc Issue #37 và `docs/operations/TMB_CHATGPT_CODEX_CONTROL_CONTRACT_2026-10-26.md` tại nhánh `docs/chatgpt-codex-control-plane-20261026` **mà không checkout đè worktree**. Đầu tiên kiểm tra, backup worktree `E:\codex\2026-10-26\TMB_PVE_JX_CONTINUOUS_WORKTREE_20261026`, xác minh local dirty HEAD so với remote. Tiếp tục sửa lỗi harness A/B/C nếu nó chặn capture, đóng an toàn MovieWriter thuộc phiên thử nghiệm, chạy official Godot 4.7.2 focused+normal GUI. Hoàn thành gameplay màn hình lớn với 6 người/10 quái đi và đánh trực tiếp trên map Source A, minimap đúng camera, JX #158 event-driven chỉ khi hit thật, Save/Load ổn; dựng ảnh/video 1280×720 thật và đo FPS/frame-time/RAM. Tự sửa đến mức nghiệm thu kỹ thuật, đừng lấy PASS headless thay cho trải nghiệm. Giữ Combat V2/clock/One Active Job/Injury120/Warehouse/Save; loot vẫn `LOOT_PENDING`; không thay Source A gốc, không tạo placeholder/trận modal. Tạo commit checkpoint/push feature branch an toàn và gửi báo cáo theo mẫu trên Issue #37; không merge main. Nếu ngắt GUI/hardware, báo đúng phần chưa kiểm chứng, bảo toàn thay đổi rồi dừng, không tuyên bố VISUAL_PASS.

## 6. Khi hoàn tất PVE-VIS-01

ChatGPT review đúng commit/evidence; **owner nghiệm thu visual**. Sau đó mới phát hành packet mới riêng cho (1) mở rộng PvE vùng/spawn/AI, (2) loot hợp lệ, (3) Forge, theo mức phụ thuộc và ownership. Không nâng `PVE-VIS-01` thành dự án vô thời hạn; không biến 20 bãi thành 20 cửa sổ.
