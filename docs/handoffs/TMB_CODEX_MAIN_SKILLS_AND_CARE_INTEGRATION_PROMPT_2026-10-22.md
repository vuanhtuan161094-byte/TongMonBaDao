# CODEX MAIN INTEGRATION — USER-READY PROMPT

**Owner approval status:** prompt is prepared but has **not been sent to Codex by ChatGPT**. Its authorizations become operative only when owner sends it; maintain repo gates and PR review. Skill source branch: `docs/tmb-agent-skills-20261022`. Last owner correction: **1,000,000 pill satiety points/day/disciple**. 

## Copy this entire prompt into Codex

```text
TÔNG MÔN BÁ ĐẠO — TÍCH HỢP SKILLS VÀ HỢP NHẤT MAIN CÓ KIỂM SOÁT (22/10/2026).

REPO: vuanhtuan161094-byte/TongMonBaDao.
NGUỒN SKILL: nhánh docs/tmb-agent-skills-20261022, HEAD mới nhất (fetch, không đoán SHA).
MAIN MỐC ĐÃ ĐỐI CHIẾU: 461caca1171462e0da092f21108c5c1733157ad9. Phải fetch lại main trước khi làm, dùng HEAD thực tế nếu đã thay đổi.
B3 CARE LOCAL: commit 35ffa85fd45da42e43722e7ac74b7423602d4491 (parent B3 FAST-TRACK 1d686dc8e202f4831fa51373c15e6666f44702f9); ZIP trên máy E:/codex/2026-10-22/t-ng-m-n-b-o/outputs/B3_CARE_FASTTRACK_HANDOFF.zip, hoặc Git bundle cùng nội dung trong ZIP. Nếu không tìm thấy thì báo BLOCKED, tuyệt đối không giả commit hay tự tạo lại code.
OVERRIDE CHỦ DỰ ÁN 22/10: Đan Bão Hòa chính thức 1.000.000 điểm/ngày/đệ tử theo simulation day=floor(tick/1440). 100.000 là lỗi gõ thiếu số 0. Không "sửa ngược" code đúng của CARE. Các luật Combat V2, One Active Job, canonical Warehouse/time/save, Injury120 và các giá trị 10/25/+55HP/+10.000 Tu Vi giữ nguyên.

NHIỆM VỤ THEO THỨ TỰ, KHÔNG MERGE Ồ ẠT:

A. INVENTORY + SAFETY BASELINE
1) Read AGENTS.md, docs/GAME_SYSTEM_ARCHITECTURE.md, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md và code hiện có tại main thật. Kiểm tra git status/branch/refs/merge-base, bảo toàn uncommitted user changes. Làm việc trong worktree mới thuộc E:/TongMonBaDaoWorkspace/ hoặc E:/codex/, không dùng profile Admin, không nâng quyền Administrator.
2) Rà các nhánh PR/code đang mở và provenance, đặc biệt B3 FAST-TRACK/CARE, G1/MAP25, C4, Source A, docs. Phân loại CODE READY/TESTED, DESIGN ONLY, REVIEW PENDING, UNMERGEABLE; không tự kết luận mọi branch đều phải merge. Bất kỳ nhánh nào đè cùng runtime owner hoặc thiếu test => BLOCKED, không auto-merge.
3) Đối chiếu thật CARE ZIP 73/73 hash, diff, allowlist, full git bundle, focused Godot 4.7.2 15/15 PASS theo bàn giao; đó không phải Windows manual hay Android PASS. Nếu thiếu log/bundle => ghi PENDING, không tự kể PASS. Giữ một nguồn Gameplay authority.

B. HỢP NHẤT SKILL TRƯỚC (DOCS-ONLY PR RIÊNG, KHÔNG ĐỤNG CARE)
4) Từ source docs/tmb-agent-skills-20261022, chọn CHÍNH XÁC sáu thư mục:
   .agents/skills/tmb-project-director/
   .agents/skills/tmb-balance-lab/
   .agents/skills/tmb-autoplay-ai/
   .agents/skills/tmb-godot-evidence/
   .agents/skills/tmb-asset-gate/
   .agents/skills/tmb-ui-playtest/
   và tài liệu docs/AI_AGENT_SKILLS_TMB_2026-10-22.md, docs/AI_AGENT_SKILLS_AUTO_DISCOVERY_CARE_QA_2026-10-22.md. Có thể chọn bản thiết kế Balance Lab nếu chỉ cập nhật docs, nhưng KHÔNG cherry-pick nguyên nhánh B3 docs hay nhánh skills.
5) Merge bằng selective paths/reconcile root AGENTS.md: giữ nguyên toàn bộ governance ban đầu; chỉ thêm một phần "TMB Agent Skills" ngắn chỉ đường đến sáu skills, lời nhắc ưu tiên quyết định user và authoritative code, routing 1 director+1 chuyên môn; các tài liệu phải dùng CAP 1000000 là latest. Chỉ sửa docs/AGENTS/skills, KHÔNG sửa godot, Source A, tests, balance.
6) Kiểm tra frontmatter mỗi SKILL.md có name/description và đường dẫn reference hợp lệ, gọi thử explicit $tmb-project-director và $tmb-godot-evidence, ghi evidence auto-discovery hoặc explicit read nếu Codex không auto-load. Không cài installer/script lạ, không thêm agent vô hạn. No FULL/CI cho PR docs-only. Commit/push PR docs-only lên main; merge chỉ khi diff allowlist đúng và owner đã phê duyệt nội dung (yêu cầu này là ủy quyền để tạo PR, KHÔNG ủy quyền bỏ qua review).

C. TÍCH HỢP B3 CARE CÓ GATE (PR CODE RIÊNG)
7) Trên main mới nhất sau PR skills (hoặc branch integration khác từ main hiện hành), import đúng B3 FAST-TRACK->CARE lịch sử từ local git bundle; không giả SHA, không squash nếu làm mất nguồn chứng cứ, không coi B3 code đang hiện diện trên remote nếu chưa kiểm tra. So sánh git merge-base, diff/allowlist và resolve conflicts bằng đúng canonical ownership. Nếu B3 nền bị lệch phiên main và không thể integrate mà không sửa ngoài allowlist: STOP, đưa blocker, KHÔNG force cherry-pick.
8) Chỉ tính CAP=1000000. B3 CARE +55 HP Hồi Xuân 10 điểm; Tụ Khí +10000 fixed Tu Vi 25 điểm; recipe 2 Thanh Linh Thảo + 1 Linh Cốc /6 sim ticks; injury120, auto-heal/rest/redeploy same world, real kills+Warehouse receipt, save/offline exactly-once. Không thêm per-kill Tu Vi, thuốc cấp cao, map r2-r30, Boss coop rules chưa khóa, không thay asset/Combat V2.
9) Chạy official Godot 4.7.2 focused tests đúng affected contract; bổ sung kiểm tra integration regressions của 30x10, ResourceRegistry, production/scheduler, One Active Job, save/old-save/migration và B3 (mốc ít nhất 15/15 khi chạy trên commit tích hợp). Cumulative FULL nếu cần để đóng CODE và trong khả năng runner; không gọi FULL PASS nếu không chạy. CI theo quota/owner; nếu bị hạn chế dùng local Windows official runner và phân biệt máy thật/Android PENDING USER. Test fail ở phạm vi sửa => BLOCK merge, không xóa assertion. Giữ khả năng rollback.
10) Sau PASS thực sự: tạo PR CODE integration, ghi exact SHAs/logs, allowlist diff, tests, debts, QA cần user. Không merge code PR nếu còn xung đột gameplay, mất dữ liệu save, hoặc thiếu regression cần thiết. Khi đạt gate, merge vào main theo workflow đã được owner cấp; không force push, không hard reset và không ghi nhãn Android PASS khi chưa test.

D. CÁC NHÁNH CÒN LẠI + BÀN GIAO
11) Chỉ thống kê các nhánh G1, MAP25, C4, UI, docs, asset tồn đọng với PR/base/HEAD/test/owner visual/status; đề xuất integration order nếu hợp lệ. KHÔNG tự merge "mọi phiên" nếu thiếu authority/code gate hoặc có conflict.
12) Update CURRENT_CHECKPOINT.md + NEXT_CHAT_HANDOFF.md trên PR hợp lệ: CAP=1000000, 6 skill paths in main, B3 CARE exact code integration status, separations PASS/PENDING, next permitted packet. Ghi SHA of main after each merge, PR URLs, changed paths, focused/cumulative results, pending Windows manual+Android.
13) Bàn giao báo cáo PASS/FAIL/BLOCKED + GitHub link, có 2 hoặc 3 lệnh đi tiếp sẵn cho owner. Không hỏi lại luật đã chốt. Không sửa Source A, không tái cấu trúc Combat V2, không nhúng skill thành gameplay runtime. 
```
