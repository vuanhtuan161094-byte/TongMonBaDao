# ONE GAME RC — kiểm thử cuối 01/11/2026

## Nguồn và phạm vi

- Nhánh RC: `rc/one-game-playable-20261101`.
- Godot gameplay test input: local exact commit `42fecb3ff98c706f3d6f1fc65704e54df5094585`; Git tree `74b9d9ac6c2f846b156ec1929597aa7e25c05cf4`.
- Branch GitHub RC đầu cuối sau sửa launcher: `eb5e139d61adb5e9881ccb85d4cd823ad7a84263`. Chỉ khác tree test ở hai script CMD: Git per-checkout safe-directory và profile save persistent; Godot/runtime source không đổi. Local launcher smoke chạy đúng hai file này trước khi cập nhật lên GitHub.
- Official Godot: `4.7.2.stable.official.ed1daf0bf`, Windows, OpenGL Compatibility / Intel Iris Plus.
- O8 lifecycle fix `84e82f301b86616c24e241e02fbe798681803a99` is integrated as test-only harness correction; no production SaveService changes. Final focused stderr scan: zero parser/script/thread-destruction warnings.
- Source A Female Stage A installer reported verified transport SHA-256 `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`; 42 canonical PNGs exist in the QA checkout after install.

## Integration review and dependencies

The isolated integration first-parent sequence is: baseline `199f888c7fd690830728dfbf29b6b79276e3b283` → `0c506bf` (PR #60 Dẫn Tiên C2) → `fe9c262` (PR #57 SX-01 pill policy) → `4710196` (PR #58 SX-02 medicine runtime) → `a5bf249` (reviewed `e7643ba` pill correction) → `b3c102e` (PR #62 JSON/Save policy) → `7325922` (O8 test lifecycle fix `84e82f3`) → game tree tested at `42fecb3`.

- **PR #60** contributes the Dẫn Tiên recruitment runtime/UI and C2 smoke. Its change is code plus tests; it remains separate from fully validated mouse acceptance.
- **PR #57** contributes SX-01 policy/state/presentation and policy tests. **PR #58** contributes SX-02 catalogue/allocation/alchemy/B3 runtime and tests. **`e7643ba142f5ffbf22b2c56d5086bdbb6cec32cd`** contributes a reviewed manual pill correction after #58.
- **PR #61** was reviewed, not merged as a branch. Its JSON normalizer and roundtrip-test hunks are identical to the corresponding #62 hunks; the P3.2 alchemy presenter’s explicit `String` type correction is present in the integrated file. **PR #62** is the integrated JSON/Save correction and its 13-check roundtrip test is in the RC.
- **PR #63 / O8 `84e82f301b86616c24e241e02fbe798681803a99`** changes only the O8 test lifecycle. No production SaveService thread/scheduler code was altered by this fix.
- Feature scope remains intentionally incomplete: SX-02 registers many SKUs but only four authored new recipes for realm ranks 1–2; it is not 240 recipes or a full 30-rank pill progression. No balances or recipes were invented. PvE loot remains pending. Large building Lv1–100/economy completion is not part of this RC acceptance.
- The original PR refs and `main` were not changed or merged.
## Evidence

- GitHub audit folder: `docs/qa/one_game_playable_rc_20261101/` on `audit/tmb-whole-project-readiness-20261027` (matrix/logs/images below).
- RC source branch: [rc/one-game-playable-20261101](https://github.com/vuanhtuan161094-byte/TongMonBaDao/tree/rc/one-game-playable-20261101), final branch commit `eb5e139d61adb5e9881ccb85d4cd823ad7a84263` (launcher-only delta from tested game tree).

- `FINAL_REGRESSION_MATRIX.csv`: per-test SHA, exit code, result, mode, count/limitations.
- `RAW_LOGS_REDACTED.txt`: stdout/stderr for all final focused tests, including the timed-out first B3 CARE attempt, successful isolated retry, and headless multicamp harness failure. Local drive and user paths were redacted; test values and markers retained.
- `pve_jx_combat_1280x720.png`: Godot non-headless engine-rendered P3.2 Source A world frame; 1280×720; six party, ten monsters; zoom controls, minimap, V5 combat HUD; one cast/hit/impact fixture.
- `pve_jx_formation_1280x720.png`: engine capture of 6 unique formation positions, 10 monster records.
- Zoom captures `pve_selection_rings_zoom_080.png` and `pve_selection_rings_zoom_135.png`.
- Screenshot SHA-256: combat PNG `9d040254bb93fc2a920a94f38cecc82397143e7dcf5ac5a0b88de2f48d2fa6fb`; formation PNG `8885a888e5fd5cef0a2f92258c5baab991894829b4b65f9e7ce25faaef3af440`.
- Launcher Desktop shortcut: `%USERPROFILE%\Desktop\MỞ GAME TÔNG MÔN BÁ ĐẠO (RC).lnk` → `MO_GAME.cmd`; its real launch created a visible Godot window and stable save+backup under the isolated profile `godot/outputs/one_game_newgame/owner_playtest_profile/`.

## Result / acceptance boundaries

- Focused engine paths: PASS as itemized in the matrix. This includes Dẫn Tiên smoke/recruitment, SX-01 13+32 checks, SX-02 856+47, B3 pill 45 and CARE 39, async SaveService 10, P0 Save/Reload, Injury120 T01–T23, O4, O8, and PvE save/return, zone, C17, formation, six Combat V2 actors.
- Automated real engine GUI render/input at 1280×720: PASS for the harness. Wheel zoom, +/−, anchor stability through refresh, six move orders, Save/Load and a JX impact draw were checked. It is not a human mouse playtest.
- Not complete: continuous same-profile New Game→recruit→field→harvest→Alchemy→Warehouse→pill→Save/Reload→PvE was not executed as one play session; the component flows were tested separately. PvE capture lasted 35s with 1 cast/hit/impact, no kills; autonomous progression test lasted 40s with 10 kills/2 respawns. 120s active combat, FPS distribution P50/P95/P99/1%-low, and manual mouse acceptance remain PENDING. 60.06 in the capture log is a single sample, not a performance distribution.
- Loot remains `LOOT_PENDING`; no reward or balance values were invented. Source A boss event mapping remains unverified (`boss_event_mapped=false`). Windows CA store error appears in Godot stderr; it did not cause parser/test exits. No unjoined Thread warnings appeared in final focused stderr scan.

## Play

Double-click `MỞ GAME TÔNG MÔN BÁ ĐẠO (RC)` on Desktop, or open `MO_GAME.cmd` in the RC checkout. The launcher restores and SHA-verifies Female Stage A if missing, chooses official Godot 4.7.2, checks ancestry with a scoped Git safe-directory setting, and starts 1280×720. User save persists in the isolated `owner_playtest_profile`, distinct from seeded QA and canonical player saves. The RC checkout used here is `<QA_CHECKOUT>`; no source-main/E canonical checkout was replaced.

## GitHub hình ảnh

Hai ảnh được lưu như Base64 text vì GitHub connector hiện không tạo trực tiếp binary tree trên nhánh kiểm toán:

- `screenshots/pve_jx_combat_1280x720.jpg.base64` — JPEG 1280×720, SHA-256 sau giải mã `56E8E7DE4A7D796959F3AC3AC6940D8586E9B37959E1003E1052DFEAB55BC3F3`.
- `screenshots/pve_jx_formation_1280x720.jpg.base64` — JPEG 1280×720, SHA-256 sau giải mã `1EFD10C1BDE5DABACBA0005AE652DD5EB604C3F1CE335DBD44C7BEAB3826B51F`.

Giải mã bằng PowerShell: `$b=[IO.File]::ReadAllText('pve_jx_combat_1280x720.jpg.base64'); [IO.File]::WriteAllBytes('pve_jx_combat_1280x720.jpg',[Convert]::FromBase64String($b))` (tương tự cho ảnh đội hình). PNG gốc không bị sửa và vẫn ở thư mục QA local; hash PNG được ghi trong log render.