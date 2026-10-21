# TÔNG MÔN BÁ ĐẠO — Chủ trương Source A & bàn giao backend (21/10/2026)

> **TRANG ĐIỀU HƯỚNG DUY NHẤT CHO CHAT MỚI / CODEX**  
> Quyết định owner mới nhất: **GIỮ SOURCE A CHIBI cho toàn game**. Không chuyển sang pixel, không sao chép nguyên combat JX1. **Combat V2** vẫn là luật gameplay; skill/VFX JX1 chỉ chọn lọc khi hợp mỹ thuật. Godot 4.7.2, Android landscape 1280×720.

## Những file đang sử dụng (ACTIVE)

1. **[Kế hoạch / rà soát dự án và lộ trình Source A](active/TMB_SOURCE_A_COMBAT_V5_PROJECT_AUDIT_ROADMAP_2026-10-21.md)** — Roadmap chính P0/P1/P2, audit các nhánh và animation Source A.
2. **[Prompt giao Codex Source A P0–P2](active/CODEX_TMB_SOURCE_A_COMBAT_V5_P0_P2_2026-10-21.md)** — Codex trên Windows, source `E:\TongMonBaDaoWorkspace`, chỉ triển khai visual pilot nếu asset thật đủ chứng cứ.
3. **[Bàn giao nghiên cứu backend cho chat mới](active/TMB_BACKEND_RESEARCH_NEXT_CHAT_HANDOFF_2026-10-21.md)** — Combat V2, AI/skill, Economy V2, sản xuất, save/offline, performance; chỉ đọc và thiết kế song song Codex.
4. **[Prompt mở đầu chat backend mới](active/PROMPT_CHAT_MOI_BACKEND_TMB_2026-10-21.md)** — Copy hoặc yêu cầu chat mới đọc trực tiếp GitHub, không cần đính kèm tệp.

**Điểm xuất phát code:** `work/playfirst-demo-max-v3-20261020`, known HEAD `aad7cec147e5df587ab13614e1c9ef2ac752a8d7`; **phải fetch lại HEAD** khi làm. `main` còn cũ, không được dùng làm baseline combat/G1 tích hợp nếu chưa so sánh. Asset Forge có nhánh riêng `tools/af-jx1-player-forge-20261020` (known HEAD `4dcb2daf`).

## Cách làm việc — không cần download/upload file

- **Trong Codex:** truy cập repository, `git fetch origin docs/sourcea-v5-backend-handoffs-20261021`, rồi đọc file bằng `git show origin/docs/sourcea-v5-backend-handoffs-20261021:docs/owner_handoffs/2026-10-21/active/CODEX_TMB_SOURCE_A_COMBAT_V5_P0_P2_2026-10-21.md` và roadmap active cùng thư mục. Không merge nhánh docs vào code để chỉ đọc tài liệu.
- **Trong chat mới:** mở repository bằng GitHub connector; truy cập nhánh tài liệu `docs/sourcea-v5-backend-handoffs-20261021`, đọc `docs/owner_handoffs/2026-10-21/active/TMB_BACKEND_RESEARCH_NEXT_CHAT_HANDOFF_2026-10-21.md` và `PROMPT_CHAT_MOI_BACKEND_TMB_2026-10-21.md`. Bắt đầu B0 backend read-only ngay.
- **Phân quyền file:** Codex Source A làm visual/Spine/atlas/map; chat backend chỉ nghiên cứu và đề xuất packet. Không có hai writer trên một file. Không CI/FULL/merge, không thay Combat V2, RNG, One Active Job, Injury 0/1/120, Warehouse hoặc save khi chưa cấp phép riêng.

## Tài liệu lịch sử / tham khảo (REFERENCE — KHÔNG PHẢI LỆNH ĐANG CÓ HIỆU LỰC)

Những file sau giữ nguyên để không mất kết quả nghiên cứu; **không chạy prompt cũ** nếu mâu thuẫn với quyết định giữ Source A.

- [Thiết kế sâu Source A Combat V5](reference/TMB_COMBAT_V5_SOURCE_A_DEEP_DESIGN_2026-10-21.md) — **tham khảo thiết kế**, không phải code/QA PASS.
- [Khuyến nghị Combat V5 ban đầu](reference/TMB_COMBAT_V5_STRATEGY_2026-10-21.md) — lịch sử.
- [So sánh Source A / JX1](reference/TMB_COMBAT_A_VS_B_DEEP_COMPARISON_2026-10-21.md) — quyết định A/B đã chốt về Source A.
- [Kế hoạch thử pixel vs chibi](reference/TMB_COMBAT_V5_AB_VISUAL_PILOT_CODEX_PLAN_2026-10-21.md) — **dừng**, không triển khai pixel.
- [Prompt kiểm toán V5-G0 cũ](reference/CODEX_COMBAT_V5_DESIGN_AUDIT_2026-10-21.md) — đã thay bởi prompt Source A active.
- [Khảo sát JX1 combat từ G0C](reference/CODEX_C4_JX1_COMBAT_VISUAL_PARITY_FROM_G0C_2026-10-21.md) — **dừng bê nguyên JX1**.
- [Prompt bóc JX1 combat cũ](reference/CODEX_01_JX1_COMBAT_SOURCE_EXTRACTION_2026-10-21.md) — dùng dữ liệu tham khảo, không triển khai JX1-first.
- [Prompt nhóm asset Source A](reference/CODEX_02_SOURCE_A_ASSET_GROUP_LIBRARY_2026-10-21.md) — chỉ chọn lọc theo nhu cầu P1, không chuyển toàn kho.
- [Prompt tổng hợp JX1 + Source A cũ](reference/CODEX_TMB_JX1_COMBAT_SOURCEA_ASSET_GROUPS_2026-10-21.md) — không thực hiện phạm vi cũ nếu xung đột.

## Trạng thái bằng chứng

Tài liệu này chỉ được **upload GitHub**, không có nghĩa đã chạy Source A combat pilot hoặc nghiệm thu Android. Owner visual **PENDING**; Codex P0/P1 hiện là công việc đã giao, không phải đã hoàn thành. Chính sách gameplay thật thuộc `docs/GAME_SYSTEM_ARCHITECTURE.md`, `AGENTS.md` và các master spec/owner overrides theo thời gian.

**Lưu trữ:** bộ 13 Markdown này được đồng bộ nguyên văn từ file giao trong cuộc trò chuyện ngày 21/10/2026. Đường dẫn GitHub thay thế thao tác tải về và đính kèm.
