# PROMPT CHAT MỚI — BACKEND TÔNG MÔN BÁ ĐẠO

TÔNG MÔN BÁ ĐẠO — TIẾP QUẢN NGHIÊN CỨU BACKEND SONG SONG CODEX SOURCE A.

Đọc toàn bộ file `TMB_BACKEND_RESEARCH_NEXT_CHAT_HANDOFF_2026-10-21.md` kèm theo. Chủ dự án **đã khóa phong cách Source A chibi**, không pixel, không bê combat JX1 làm luật. Codex đang làm riêng khảo sát/visual pilot Source A; **chat này chỉ kiểm toán, nghiên cứu và thiết kế backend**, không code, không sửa repo/save, không CI/FULL/merge và không đụng các file Codex đang xử lý.

Repo: `vuanhtuan161094-byte/TongMonBaDao`. Đọc `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md` và các spec. Kiểm toán nhánh `work/playfirst-demo-max-v3-20261020` từ HEAD mới nhất (đã biết `aad7cec1`, hãy fetch lại), không dùng `main` cũ làm baseline chơi thử.

Nghiên cứu chuyên sâu 5 tuyến: (1) Combat V2 — skill loadout, Kiếm/Thể/Pháp, AI, mục tiêu, boss warning, săn quái, loot, Accuracy/Evasion design-only, (2) Economy V2 — Mỏ/Linh Lâm/Linh Điền, hiệu suất, batch, Warehouse, sản lượng, các sink, (3) Đệ tử — Tu Vi/Luyện Thể 30×10, One Active Job, Injury 0/1/120, (4) save/offline — deterministic snapshot, exactly-once reward, idempotency, (5) performance — 1.000–3.000 đệ tử, 6/đội, 30/cụm, fixture 30v40, event-driven.

**VÒNG ĐẦU THỰC HIỆN B0**: lập feature truth matrix theo spec → class/caller/consumer → focused tests → chứng cứ và QA đúng SHA → lỗ hổng → rủi ro → đề xuất. Xếp hạng 3 blocker backend quan trọng nhất đến phiên bản chơi được. Đề xuất 2–3 gói CODE độc lập cho bước sau nhưng **không thực hiện khi chưa được tôi chấp thuận**. Không viết lại những gì đã có, không đánh đồng thiết kế với implementation, không tự đổi balance/gameplay/save. Trình bày tiếng Việt, có link code/commit, ngắn gọn trong câu trả lời nhưng đủ chứng cứ.
