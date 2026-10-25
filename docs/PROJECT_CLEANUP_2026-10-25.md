# TÔNG MÔN BÁ ĐẠO — BIÊN BẢN TỔNG HỢP VÀ DỌN TÀI LIỆU

Ngày 25/10/2026 (Asia/Ho_Chi_Minh). Yêu cầu owner: “Tổng hợp lại dự án. Xem các mục nào cũ. K còn áp dụng thì xoá”.

## 1. Phạm vi đã làm

Rà trực tiếp GitHub: root policy/architecture/checkpoint/handoff/README/sổ nợ; danh mục **143 nhánh, 34 PR (30 OPEN/DRAFT, 2 MERGED, 2 CLOSED WITHOUT MERGE)** tại thời điểm đọc; báo cáo và raw focused CSV của PR31/32; checkpoint PR33/34; CODE-CLEAN/R0 và cập nhật điều tra runner.

Đây là kiểm kê metadata toàn repo và review có mục tiêu các authority/evidence hiện hành, **không phải line-by-line audit mọi nhánh/code/asset**. Số nhánh/PR sẽ tăng khi tạo nhánh/PR dọn này. Không dùng inventory cũ 131 nhánh làm số hiện tại.

Base của thay đổi: `29b5fba448b0178cb520a4ada44b375b4b934e31` trên main. Chỉ thay Markdown; toàn bộ runtime/art/tests/workflows và các feature/QA refs giữ nguyên. Không có merge hoặc force-push.

## 2. Đã xoá các mục nào khỏi entrypoint hiện hành

| Mục cũ | Vì sao không còn áp dụng / thay thế |
| --- | --- |
| “Skills chưa có trong main; chờ owner merge” | PR #23 đã MERGED ngày 22/10. Bỏ next-action đã hoàn tất. |
| “Economy-A DESIGN/PREP / đang chờ tích hợp” | #1 đã MERGED ngày 15/10. Giữ SHA/evidence và nợ physical; bỏ thứ tự công việc cũ. |
| README “first unresolved gate P2.1” và lệnh Sync-P2-6.cmd | Không còn mô tả tiến độ mới; launcher này cũng không có ở main tree hiện tại. README trỏ checkpoint và Sync-Main hiện có. |
| Hàng chục CURRENT/LATEST/NEXT của ENV-01/02A, O0–O9, DV2-01/02/03, F0–F7 | Là thứ tự thực hiện ở các ngày trước. Bỏ toàn bộ timeline nối đuôi khỏi checkpoint/handoff; dùng kết quả hiện hành và link history cho SHA/run chi tiết. |
| “O6 cũ FAIL => vẫn là blocker hiện hành” | Có Linux/Windows PASS về sau tại SHA đã ghi. Giữ failure cũ trong history, không gọi nguyên nhân đã biết. |
| “Chưa từng có Windows GP-02C1/SAFE/FULL” | Economy-A đã có Windows automated 18/18. Giữ nợ manual/Android/fault thật, không chạy lại lịch sử mặc định. |
| FE-01 là việc chưa bắt đầu theo queue 12/10 | Không còn là chỉ dẫn hiện hành sau các bước frontend/map về sau. Giữ ADR/architecture và routing theo checkpoint. |
| Chỉ có Combat V2 / chỉ dừng ở C1 / B3 vẫn thuần nghiên cứu | Tách đúng V2 math + S1 runtime, D7, CARE đã có evidence ở integration; chúng vẫn chưa merge main. |
| “MAP-D0 là bước cần làm ngay” | MAP-D0 đã qua, Option B #32 có code/evidence; #33 đang là candidate mới chưa QA. |
| “PvE 20 bãi/300 quái đã xong” hoặc suy PASS từ nhánh cha | Không có bằng chứng runtime đó. Registry hiện tại ghi rõ topology preview và 0/21 R0 executed. |
| Sổ nợ chứa lệnh tạm ngừng/tái làm toàn backend, next merge Economy-A | Đã hết phạm vi thời điểm bàn giao. Giữ Q01–Q17 và GUI findings, cập nhật trạng thái, bỏ prompt mở việc sai luồng. |

Không sao chép timeline cũ sang archive file mới: Git đã giữ nguyên phiên bản trước dọn. Các bằng chứng duy nhất, spec và quyết định chi tiết không bị mất; mở immutable parent revision khi cần, không dùng nhãn NEXT lịch sử làm lệnh mới.

## 3. Những phần vẫn cần giữ

- GP-02C1 QA OPEN, DV2-03 administrative PAUSED NOT CLOSED, Q01–Q17, CHAR/ACTION-GUARD và ba GUI findings cũ với trạng thái đối chiếu rõ.
- Windows/manual, Android, owner visual, physical faults và 1k–3k performance chưa được suy PASS.
- Toàn bộ Source A manifest/PNG/atlas, conversion provenance, runtime source, finite save/receipt/material consumers, regression tests và logs/screenshot.
- Old JX/C4/Unity, economy/disciple forks và docs research không còn là đường bắt đầu mặc định. Chúng có thể còn unique code/asset/design, **chưa đủ bằng chứng xoá**.
- Không đổi gameplay, balance, quyền CODE của packet khác hoặc nội dung các skill. Quyết định owner và authority hiện hành tiếp tục cao hơn ví dụ skill cũ.
- Cần giảm số branch về sau phải có net-diff/provenance trước; xoá branch không tự tăng FPS hoặc xoá Git blob lịch sử.

## 4. Dấu vết thay đổi và khôi phục

Parent revision cố định: [29b5fba448b0178cb520a4ada44b375b4b934e31](https://github.com/vuanhtuan161094-byte/TongMonBaDao/tree/29b5fba448b0178cb520a4ada44b375b4b934e31). Mọi bản gốc bên dưới khôi phục được từ parent; blob SHA là định danh nội dung Git, không phải SHA256.

| File | Original blob SHA | Số dòng trước → sau |
| --- | --- | --- |
| `README.md` | 3b186867bd399ad0acb200d126310e2ac3bf12b7 | 88 → 30 |
| `CURRENT_CHECKPOINT.md` | f66a3a00a15002f3e615a3a0907d3e0f47e23b80 | 1411 → 77 |
| `NEXT_CHAT_HANDOFF.md` | 85a24ffb7f4ca7e00fda79214064ed38926fcf8d | 880 → 42 |
| `AGENTS.md` | 49d88aa9293384778c6ca4a5dc22355c72f29332 | 263 → 263 |
| `docs/GAME_SYSTEM_ARCHITECTURE.md` | 55d4b7711920ab0faf0b2cef4dbeeab5b7e3b6ac | 312 → 312 |
| `docs/QA_DEBT_MASTER_AND_BACKEND_REDESIGN_HANDOFF_2026-10-13.md` | ab09a9f31c1dc383a34bbd67716f0432d53b5630 | 128 → 56 |

CURRENT_CHECKPOINT + NEXT_CHAT_HANDOFF: **382.658 ký tự → 14.264 ký tự**, giảm khoảng **96,3%**. Đây là giảm lượng văn bản đầu vào phải đọc; không phải benchmark game hay cam kết số token/FPS.

## 5. Kiểm tra và giới hạn

- Đối chiếu raw CSV: PR31 28 dòng PASS/exit0; PR32 29 dòng PASS/exit0, có test S1 checks=56. Không chạy lại Godot trong đợt này.
- So sánh tested PR31 SHA `4b02a0c61a2771d9d4638129d96b68ad292270dc` tới HEAD `9eb4fd55733bb49bbb069240b8e332d37d22aced`: chỉ tài liệu/evidence được thêm, không thay runtime.
- Kiểm tra link nội bộ, target/path immutable của evidence, các invariant và ID nợ còn đủ; kiểm diff chỉ Markdown trước/sau commit.
- Không chạy CI/FULL/runtime cho thay đổi tài liệu. Không tuyên bố đã dọn mọi mã chết hoặc đã sửa các lỗi chưa tái hiện.
- Bản dọn nằm trên nhánh docs riêng để review. Main và những nhánh tính năng khác chưa tự nhận các chỉnh sửa này; chat sau phải đọc đúng nhánh dọn hoặc sau khi nó được merge có uỷ quyền.
