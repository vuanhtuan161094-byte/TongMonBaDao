# Final Unified RC — QA & project consolidation
Ngày QA: 2026-10-27 (Windows, +07)

## Phạm vi và exact source

- Repository: `vuanhtuan161094-byte/TongMonBaDao`
- RC: `integration/pve-unified-rc-20261027`, exact SHA **`0d3952dd11f85bebbde60176deafc4f19afc8a6f`**
- Parent `9ad0c29cb04776f692a48e89558277e855e63aef`; commit mới chỉ cập nhật `README.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`.
- Engine: `4.7.2.stable.official.ed1daf0bf`
- PR #52: Draft/Open, chưa merge; base `feature/pve-jx-continuous-world-20261026`.
- `main`: `29b5fba448b0178cb520a4ada44b375b4b934e31`; RC ahead 142 commits, behind 0.

## Gate

| Gate | Kết quả | Bằng chứng / giới hạn |
|---|---|---|
| A1 — GUI, chuột, camera, Save/Return | **PENDING_GUI** | Computer Use/Sky không liệt kê cửa sổ Godot. Phiên này không gửi input chuột/camera/PvE trong GUI. |
| A2 — FPS OFF/ON | **PENDING_GUI** | Chưa có frame-time percentile, 1%-low, spike attribution hoặc peak RAM theo pha. Headless không thay số đo GUI. |
| A3 — screenshot/video thật | **PENDING_GUI** | Không có ảnh/video capture thật trong phiên này. |
| B1 — 22 regression | **PASS 22/22** | Từng lệnh exit 0 trên exact SHA ở trên, official Godot 4.7.2. |
| B1 bổ sung — Female Stage A | **PASS** | Installer exit 0; transport SHA đúng; editor import cô lập exit 0; 42/42 PNG; hai Stage A contract tests sau import exit 0. |
| B2 — integration/invariants | **PASS headless** | C17, 6 formation slots, 20 camp, HP0/respawn, Save/Reload, Injury120 và JX VFX có test tương ứng. Chuột thật vẫn chưa test; Injury120 độc lập PASS nhưng encounter P3.2 không chạm 120. Không tạo loot. |
| C1 — main → RC content audit | **PASS audit; feature gate còn chặn** | 142 ahead / 0 behind; 742 unique paths đã kiểm tra theo 8 chunked compares. Feature matrix ở [MAIN_MERGE_READINESS.md](MAIN_MERGE_READINESS.md). |
| C2 — canonical RC docs | **PASS** | README/checkpoint/handoff được đồng bộ trên SHA này; architecture authority hiện có được giữ nguyên. |
| C3 — main readiness | **BLOCKED: MAIN_MERGE_BLOCKED_BY_GUI_AND_FPS** | Chưa đủ bằng chứng A. Không tạo hoặc merge PR vào main. |
| C4 — merge/cleanup | **WAITING_OWNER_APPROVAL** | Không merge main, không đóng/xóa PR hoặc branch. |

## Kết quả kỹ thuật đáng chú ý

- Full suite chạy tuần tự từ 12:27:59 đến 12:36:46 (+07), 22/22 exit 0.
- P3.2 live integration headless: 6 người / 10 quái; sáu vị trí hợp lệ, spacing tối thiểu 2.83; save/load và zone hop PASS; 10 kills; Injury120 chưa đạt trong encounter; loot `LOOT_PENDING`.
- P3.2 integration mất **256.765 giây wall time**. Đây là dấu hiệu tải simulation cần đo profiler GUI; không phải FPS và chưa xác định được nguyên nhân.
- JX #158: Combat V2 cast → projectile → positive hit → một impact; không giả hit explosion; SaveService reload không replay tác động.
- D7 Save A/B: error 1 được tái hiện từ fixture D7 không hợp lệ (aptitude/quality bất nhất). Fixture tự nhiên lưu/tải PASS; save/backup hợp lệ được giữ nguyên. Không thay đổi SaveService.
- Female Stage A: package transport SHA-256 đúng `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`; import sạch exit 0; hai contract tests nạp texture 128×128 và PASS.
- Godot báo `Failed to read the root certificate store` trong môi trường Windows. Lần import đầu cũng quét cache QA cũ dưới `godot/outputs`; lần import cô lập sau đó loại riêng output cache khỏi scan bằng `.gdignore` tạm, exit 0, không còn lỗi scan. File tạm đã gỡ và không được commit. Negative-save logs là các case fail-closed mong đợi.

## Files và provenance

Xem [EVIDENCE_INDEX.md](EVIDENCE_INDEX.md), [FULL_22_TEST_MATRIX.csv](FULL_22_TEST_MATRIX.csv), [FULL_22_SUMMARY.json](FULL_22_SUMMARY.json), [GUI_ACCEPTANCE.md](GUI_ACCEPTANCE.md), [FPS_OFF_ON_COMPARISON.csv](FPS_OFF_ON_COMPARISON.csv), [REGRESSION_DIAGNOSIS.md](REGRESSION_DIAGNOSIS.md), [MAIN_MERGE_READINESS.md](MAIN_MERGE_READINESS.md), [SHA256SUMS.txt](SHA256SUMS.txt), và [full sanitized log bundle](logs/FULL_22_LOGS_AND_IMPORT.zip).

Không dùng kết quả SHA lịch sử thay cho exact-SHA suite. Không tuyên bố GUI/PERFORMANCE/PLAYABLE PASS.
