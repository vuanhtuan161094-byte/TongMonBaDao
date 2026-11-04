# NEXT CHAT / CODEX HANDOFF — RELEASE TRAIN PR #72 → MAIN (2026-11-04)

**Không tiếp tục trên PR #52, #67, `one-game-v65` hoặc các SHA tháng 10.** Các hướng dẫn cũ được bảo tồn trong [bản archive](docs/archive/checkpoints/NEXT_CHAT_HANDOFF_LEGACY_PRE_RELEASE_TRAIN_20261104.md), **không còn hiệu lực để thực thi**. Đọc [Issue #56 — live R0–R5](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56), [PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) và [canonical release register](docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md).

## Mục tiêu

One game, one authority, one final `main`, one working launcher. **Không tạo PR/branch gameplay song song.** Chỉ PR #72 là source candidate; hiện là Draft, chưa merge. PR #67 là ancestor/base của #72; không merge lặp. 25 PR cũ đã đóng hành chính, không xóa code/branch; còn 36 PR tại lúc chụp trạng thái 2026-11-04.

## Bắt đầu công việc (thứ tự bắt buộc)

1. **R0 — E: safety first.** Trên Windows, `git status` / `git worktree list` / tiến trình Godot đang chạy; backup đầy đủ khoảng 196 dirty/untracked source và save + manifest SHA256. Không `git reset --hard`, `git clean`, checkout cưỡng bức hay xóa người chơi.
2. **R0 — conclude remaining 30 diverged PRs**, verify substantive behavior/QA in current PR #72 rather than assuming old git commit ancestry. Classify each `PORT_TO_72 | FUNCTIONALLY_SUPERSEDED | ARCHIVE_ONLY`. Old economy/workforce #2/#6–#20; combat/PvE #29/#30/#34/#44–#50; docs/tools/QA #53/#55/#59; #61 policy, #64 Hall/Residence, #66 B1 UI. Four animation labs #68/#69/#71/#74 remain experimental until Owner Visual + QA.
3. **R1 — code:** only forward-port missing approved production behavior to PR #72; preserve SaveService, One Active Job, Injury 0/1/120 ticks, Warehouse, 20-zone/30-hunter PvE, 27 sect ranks; keep Tam Căn / Tứ Tính UI naming as requested after checking canonical stat authority.
4. **R2 — Windows launcher:** investigate `ig11icd64.dll` GLES3 crash and inaccessible PID safely; 3 clean launch/exit cycles. Select/verify actual `CHOI-GAME.cmd` or `MO_GAME.cmd` one-click entry from E, do not bypass fingerprint.
5. **R3 — one QA save full journey:** New Game → Housing → real recruit → Mine → Warehouse → solo + join/withdraw PvE → kill receipts/real Tu Vi+Luyện Thể+loot → Save/Exit → independent cold Reload → continue, no duplicate.
6. **R4 — release QA:** Godot 4.7.2 official regression + actual 1280×720 Windows GUI mouse/screens; do not call headless injected input human/physical acceptance.
7. **R5 — final merge** only after required gates PASS: preserve `main`'s divergent `AGENTS.md`, retarget PR #72 to `main` safely, merge once, test exact post-merge SHA, tag release, finalize Windows launcher. Close remaining obsolete PRs with detailed reasons but do not delete branches without separate decision.

## What is known at exact evidence SHA

- PR #72 prior code SHA `e92ef09fc2c9b2ccb870910577b295881ccc6527`, evidence commit `e888c010d6cfb09a97ce48af19d1a2f42a401240`; later documentation commits exist, **fetch live HEAD**.
- Import + 14 focused Godot suites 15/15 exit 0; simulated PvE 20 camps/30 hunters/40 active monsters/200 slots PASS; natural solo 10 kills/10 receipts, XP+materials, generation2, cold reload PASS.
- **Windows GUI NOT ACCEPTED:** second launcher run crash `signal 11` in Intel `ig11icd64.dll` at GLES3 init; PID blocked; real mouse, one-save full loop and Android PENDING. `main` remains unchanged.
- GitHub-only cleanup changed docs/PR metadata, not owner Windows E: filesystem, not game code. Do not claim R0 complete.

## Reporting contract

After each gate: `Gate / branch / code SHA / changed paths / Windows E backup manifest / Godot build / tests PASS-FAIL / GUI actual vs injected / screenshots/logs / blocker / next action`; report in [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56) and PR #72. **Do not substitute another checklist or open new status-only PRs.**
