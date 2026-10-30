# TÔNG VỤ UI/UX V1.0 — Visual Reference Ledger
Date: 2026-10-30
Owner: 3 screen layout designs accepted in conversation.
Status: AI CONCEPT REFERENCES ONLY. NOT Source A raw files, NOT Godot captures, NOT game-ready UI textures.

| Screen | Approved status | 1280x720 reference file inside downloadable ZIP | SHA-256 |
| --- | --- | --- | --- |
| Tổng Quan | APPROVED layout & style | `01_Tong_Quan_APPROVED.png` | `0bb3a6a434135f8bb84c09e2b1fcdb4ae48eede9c3f627b395839aac8cb4e76c` |
| Sản Xuất | APPROVED layout WITH UX FIXES | `02_San_Xuat_APPROVED_WITH_UX_FIXES.png` | `991c88104a0d4cff8113ca39252a03ab9106d5e56084778051861feb45ba4b96` |
| Nhân Sự | APPROVED layout & visual concept (option A) | `03_Nhan_Su_LAYOUT_APPROVED.png` | `2ed35e9ea4d5ae9db5949c85efc195bc3ab05104845665ed53c37a024153726e` |

## Preservation

- The ZIP `TongVu_UIUX_FINAL_APPROVED_20261030.zip` was packaged and provided in the originating ChatGPT conversation, with 3 PNG reference views, interactive personnel wireframe, readme, SHA256SUMS.
- **Important limitation:** the ZIP/PNG bytes are **not uploaded to GitHub by this design checkpoint**. This ledger only preserves their authoritative names, hashes and review states. Retain the ZIP from the conversation or upload it to durable storage; do not report GitHub media archival as complete.
- The GitHub text documents carry the durable feature specifications, decisions and engineering backlog; the image archive is a separate deliverable.

## Layout/UX corrections before implementation

1. Production list must not duplicate the same rows in two tables.
2. Per-row actions: `Tới`, `Quản lý`; details own Nâng cấp/Phân công/Chọn cây/Chọn đan phương.
3. Do not show "Đổi sản phẩm" for Mine/Forest; check actual building status and upgrade gates.
4. Do not show fake warehouse fullness percentage or "Kho sắp đầy" without actual capacity.
5. Personnel sorting prioritizes eligible idle disciples and profession mastery; active workers remain unchanged unless explicitly confirmed.
6. Preserve consistent typography/style across all 3 screens and touch readability at 1280x720.

## Next code handoff (deferred)
- Source: `TMB_TONG_VU_UIUX_V1_20261030.md`
- Blockers: `TMB_TONG_VU_BACKEND_GAPS_20261030.md`
- Target: once integration/one-game-v65-20261030 is stable and owner expressly authorizes implementation.
- No immediate new Codex task, PR, merge or writes outside `design/tong-vu-uiux-v1-20261030`.
