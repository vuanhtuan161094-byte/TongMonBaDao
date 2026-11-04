# NEXT CHAT / CODEX HANDOFF — RELEASE TRAIN PR #72 → MAIN (2026-11-04)

**Không tiếp tục trên PR #52, #67, `one-game-v65` hoặc các SHA tháng 10.** Các hướng dẫn cũ được bảo tồn trong [bản archive](docs/archive/checkpoints/NEXT_CHAT_HANDOFF_LEGACY_PRE_RELEASE_TRAIN_20261104.md), **không còn hiệu lực để thực thi**. Đọc [Issue #56 — live R0–R5](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56), [PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) và [canonical release register](docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md).

## Mục tiêu

One game, one authority, one final `main`, one working launcher. **Không tạo PR/branch gameplay song song.** Chỉ PR #72 là source candidate; hiện là Draft, chưa merge. PR #67 là ancestor/base của #72; không merge lặp. 43 PR cũ đã đóng hành chính, không xóa code/branch; còn 18 PR tại checkpoint 2026-11-04.

## Bắt đầu công việc (thứ tự bắt buộc)

1. **R0 ĐÃ PASS:** 196 source working items và 94 save được sao lưu + hash xác minh trong `E:\\TongMonBaDaoWorkspace\\90_Archive\\TMB_R0_BACKUP_20261104_145049`; manifest `EA753053E1DFBFD490E725C7FDD86B26FF565EA4BB10920805AA74571EDEF509`. Giữ nguyên backup, không reset/clean/overwrite.
2. **R0 ĐÃ PASS — 14 PR đã phân loại** trên ma trận mới (PORT/SUPERSEDED/DESIGN_HOLD); không lặp kiểm toán chỉ vì PR cũ còn open. Old details: Classify each `PORT_TO_72 | FUNCTIONALLY_SUPERSEDED | ARCHIVE_ONLY`. Old economy/workforce #2/#6/#7/#8/#9/#10/#12/#14/#16/#17/#18/#19/#20 and #66 B1 UI remain open for behavior parity/decision. Combat/PvE #29/#30/#46/#47, SX JSON #61 and Hall #64 were closed administratively after source/test review; #46 clock/save diagnostic test remains QA debt. Archived references #13/#53/#55 and unique QA/tests #34/#44/#45/#48/#50/#59 remain available at R1/R4. See `docs/operations/TMB_PR72_FUNCTION_PARITY_MATRIX_20261104.md`. Animation labs #71/#74 remain experimental until Owner Visual + QA; #68/#69 PRs are closed, branches retained.
3. **R1 ĐÃ PASS trong phạm vi canonical:** code/test SHA `b56b6fe8fa29ae663994a65098a56b60c3b42513`; Godot 4.7.2 import + 19 tests = 20/20 exit 0. D7 đã hiển thị Tam Căn(3)+Tứ Tính(4). Luật Economy bulk/cap/FoundationGrowth cũ chưa duyệt vẫn DESIGN_HOLD, không đưa vào release tự động.
4. **R2 — START NOW:** follow [Owner continuous R2→R5 task](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72#issuecomment-6627064335), investigate `ig11icd64.dll`, process overlap and real `CHOI-GAME.cmd` → `Start-TRI03Game.ps1` lifecycle. `godot/project.godot` **already uses `gl_compatibility`**, switching to the same renderer is not a fix. Verify three sequential clean opens/GUI/exits and fingerprint without bypass.
5. **R3 — one QA save full journey:** New Game → Housing → real recruit → Mine → Warehouse → solo + join/withdraw PvE → kill receipts/real Tu Vi+Luyện Thể+loot → Save/Exit → independent cold Reload → continue, no duplicate.
6. **R4 — release QA:** Godot 4.7.2 official regression + actual 1280×720 Windows GUI mouse/screens; do not call headless injected input human/physical acceptance.
7. **R5 — final merge** only after required gates PASS: preserve `main`'s divergent `AGENTS.md`, retarget PR #72 to `main` safely, merge once, test exact post-merge SHA, tag release, finalize Windows launcher. Close remaining obsolete PRs with detailed reasons but do not delete branches without separate decision.

## What is known at exact evidence SHA

- PR #72 prior code SHA `e92ef09fc2c9b2ccb870910577b295881ccc6527`, evidence commit `e888c010d6cfb09a97ce48af19d1a2f42a401240`; later documentation commits exist, **fetch live HEAD**.
- Import + 14 focused Godot suites 15/15 exit 0; simulated PvE 20 camps/30 hunters/40 active monsters/200 slots PASS; natural solo 10 kills/10 receipts, XP+materials, generation2, cold reload PASS.
- **Windows GUI NOT ACCEPTED:** second launcher run crash `signal 11` in Intel `ig11icd64.dll` at GLES3 init; PID blocked; real mouse, one-save full loop and Android PENDING. `main` remains unchanged.
- **Do not stop between R2/R3/R4/R5 for routine approval.** Codex R0/R1 has a verified Windows E backup and patched game UI; those earlier doc-only statements are superseded. Do not claim Windows PLAYABLE/Android/main merge without actual evidence.

## Reporting contract

After each gate: `Gate / branch / code SHA / changed paths / Windows E backup manifest / Godot build / tests PASS-FAIL / GUI actual vs injected / screenshots/logs / blocker / next action`; report in [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56) and PR #72. **Do not substitute another checklist or open new status-only PRs.**
