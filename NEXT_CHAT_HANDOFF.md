# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO / 29-10-2026

**Một stable `main`; một ứng viên PvE tích hợp `integration/pve-unified-rc-20261027`.** Không gọi các PR/nhánh cũ là game độc lập.

## Cập nhật hiện tại — V6.5 full combat / D3

- Stable `main` remains `c0c1382f119599497b52d8ee8abd9e830a883f1e`; no merge occurred. Active feature branch is `feature/v63-v64-full-combat-20261029`.
- D3 implementation commit: `9bbc5edacf73388505a16c8db0e3b9097a41d55a`, based on approved feature head `4b914d05eb601d2788968a0419e5dda63c79b6fc`; follow-up persistence test commit: `677184c3f05eb84e31aed66e48ee42c383acc222`. Together they add gated personal study jobs, the D3 learning catalog/system, additive disciple/sect/save records, existing-screen study/loadout controls, and focused tests.
- Official Windows Godot `4.7.2.stable.official.ed1daf0bf` import and all 10 approved focused/cumulative scripts PASS, exit 0. The 14 source/catalog/test files tested locally match final D3 source/test commit `677184c3f05eb84e31aed66e48ee42c383acc222` exactly. Read [D3 evidence](docs/implementation/V63_D3_LEARNING_EVIDENCE_20261029.md) for each command and log SHA-256.
- `technique_learning` and `sect_codex` default OFF. Economy values remain candidate-only, no skill/combat effects are enabled, and legacy P2.3 knowledge/loadout are preserved without an identity crosswalk.
- The E: feature checkout retains its existing QA/import artifacts and four EOF-only uncommitted in-scope edits; it was left untouched. Physical GUI, Android and owner visual acceptance remain PENDING.
- PR #52 remains Draft/open. No new PR or merge to `main` was performed. Next is D4 planning and a separately authorized exact CODE packet; D4+ code is not authorized by this handoff.


## Người mới tiếp quản phải đọc

1. `AGENTS.md` và `docs/GAME_SYSTEM_ARCHITECTURE.md` — luật gameplay/authority.
2. `CURRENT_CHECKPOINT.md` — trạng thái duy nhất hiện tại và điểm đã/chưa nghiệm thu.
3. [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37), PR #51 (core PASS at own SHA), PR #50 (asset static PASS/runtime PENDING), PR #49 (docs), và Draft RC (nếu đã mở).
4. GitHub live HEAD của RC, `main`, feature; không lấy SHA cũ làm mặc định.

## Việc được hoàn thành

- Codex 1 `recovery/pve-core-a1-20261027`, commit `c217471bd3fbe88b95e6e7537b39dc07ae683e41`, [PR #51](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/51): 14/14 focused headless Godot 4.7.2 exit 0 theo báo cáo Codex; D7 invalid fixture (SaveService production đúng), C17/formation, C01→C02, HP0/respawn, Save/Reload, GP-02C1 Injury120 độc lập. CODEX1_GODOT_QA_RELEASE đã ghi trên #37.
- Codex 2 `recovery/pve-playable-visual-a1-20261027`, commit `59c6dea9041653026e02a55b0bc1f4e298976835`, [PR #50](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/50): Source A và JX provenance static PASS; focused test VFX SaveService→resume cập nhật nhưng chưa chạy; FPS launcher log timestamp sửa nguồn; không chụp GUI/FPS.
- PR #49 rút gọn checkpoint/handoff và chuẩn hóa một phiên bản, giờ áp dụng chọn lọc vào RC; bản cũ vẫn tra cứu bằng SHA.

## Còn lại trước khi đề xuất đưa RC vào main

1. Full regression headless 22/22 PASS trên RC; exact SHA, matrix và logs được liên kết từ Issue #37 và evidence branch audit.
2. PENDING USER/GUI: chuột thật 1280x720, chọn 6 đệ tử, di chuyển/combat/camera/minimap, Save/Return/Load; chụp ảnh/video thật. Computer-use hiện không liệt kê cửa sổ Godot dù Win32 có cửa sổ.
3. PENDING FPS: hai lượt logger OFF/ON tuần tự cho sản xuất 15 giây, PvE 30-60 giây, Save/Return; báo P50/P95/P99, 1%-low, spikes và RAM.
4. P3.2 integration headless ở roster 130 mất 252,956 giây cho 50 polls; cần đọc profiler và GUI performance trước khi chấp nhận. Injury120 riêng PASS, nhưng encounter ngắn chưa chạm Injury120. Loot remains LOOT_PENDING.
5. Mainline merge và C4 cleanup chờ owner duyệt rõ ràng. Không thay renderer Source A, Combat V2 damage, SaveService, Injury120, economy/loot hoặc nhánh PR khác.
**Không tạo nhánh permanent develop hoặc thêm nhiều phiên bản game.** Các PR #44–#51 là provenance/đầu nguồn, RC là ứng viên tích hợp DUY NHẤT, main là stable chính thức.
