# NEXT CHAT HANDOFF — ONE GAME V6.5 / HS-09 QA

## AN-01 / AN-02 SHADOW ANIMATION LAB — 2026-11-03 (isolated)
One-click Windows launcher: MO_ANIMATION_LAB.cmd (branch-only); checks E:\\Godot_v4.7.2-stable_win64.exe or TMB_GODOT, uses isolated APPDATA. NOT TESTED ON WINDOWS.

Work only on feature/an01-an02-shadow-animation-lab-20261103 from RC 970af33b23076c80d677cf5898a721a27504708f. Added new .agents/skills/tmb-sprite-animation/SKILL.md, docs/animation/*, godot/scenes/labs/an02_animation_lab.tscn, godot/src/presentation/labs/an02_animation_lab.gd + shader and a focused presentation test. Main scene, PvE, skill logic, Combat V2, SaveService and canonical user saves untouched. The Shadow look is an unapproved visual-only silhouette shader on verified Source A male frames and does not provide genuine 8-way clips. User saw an image mockup in chat, NOT an engine screenshot.
Run official Godot 4.7.2 scene manually: res://scenes/labs/an02_animation_lab.tscn. Focused headless: godot --headless --path godot --script res://tests/presentation/an02_animation_lab_contract_test.gd. Current container lacks official Godot, so test execution is PENDING_ENGINE (do not report PASS). Verify 1/6/30 actor performance, offsets/feet/mirror and 1280×720 actual screenshot, then owner art approval. Windows GUI/Android PENDING USER. Do not merge main or automatically integrate Shadow with gameplay.

---

Continue on `integration/one-game-v65-20261030`. Fetch GitHub branch HEAD before any work. Current tested source SHA is `79dab92ccc95a93b39dcb563fe06c93a9aa422da`; main remains `c0c1382f119599497b52d8ee8abd9e830a883f1e`. A docs-only checkpoint commit `07d8b211199d580c6086af31829bc0edc3dfbe31` updates CURRENT_CHECKPOINT; this file's update follows it. The issue comment will carry the final docs SHA. Do not change main, PR #52, V6.5 source or canonical E: checkout.

## Verified in isolated QA

- Official Godot 4.7.2 import PASS at exact source SHA `79dab92`, exit 0, 103 import steps, on a Git archive snapshot with a separate import cache. The log includes one root certificate-store diagnostic despite a successful import.
- Stage A installer PASS, 42 PNGs restored, pack SHA-256 `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`; Female Stage A down and 3-direction tests PASS.
- 14 selected focused tests PASS: HS-09; Stage A x2; DV2 profile/runtime binding x2; D2 archive and open-world codex receipt; D3 learning job/UI; SaveService async, SAFE-01 and PvE save/return/reload; D6 divine lineage and rare successors. Logs under `E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030\qa_hs09_400baa`, each test log records source SHA, exact command and exit code.
- The first HS-09 test attempt failed at parent `400baa11403720fb816075d65f3cb74e8f4ad505` because the test omitted a `text_changed` signal. Test-only fix committed as `79dab92`; latest rerun passed. SAFE-01 emits expected malformed-JSON fixture diagnostics before its PASS marker. Automated PvE test reports 50 checks and `loot=LOOT_PENDING`.

## Real New Game status

The committed `tools/windows/run/Run-OneGame-NewGame.cmd` launched official Godot GUI at 1280×720 from the project main scene using an empty isolated profile. Read-only inspection found a version-4 canonical save with six starting disciples, six standard buildings, two teams, 500 spirit stones, and tick 8. Profile/save is confined to:

`E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030\checkout_400baa\godot\outputs\one_game_newgame\sessions\12863_18370_19894_3279`

The game window process is PID 8136 and remains open. No user save/profile was opened.

## Remaining acceptance gate

**GUI / gameplay is PENDING.** Computer Use window capture timed out twice, including the one allowed reselect/retry; no input or screenshot was obtained. Do not mark gameplay, PvE, or manual Save/Return/Reload as PASS. The automated save/PvE tests are regression coverage only. Current session needs actual 1280×720 input and a capture when the UI control channel is available, then P3.2 start → PvE → Save/Return/Reload in this same isolated profile. Capture and review the visible Stage A art, radar labels, HP/damage text and PvE results. Do not invent loot/EXP. Android, Source A owner visual review, and full-game FPS remain separate PENDING gates.

No actual code defect was confirmed beyond the test-only signal fix. Import-generated files in the isolated checkout were not staged. Existing owner workspaces and real saves remain untouched. The failed Git worktree metadata operation was avoided by importing a read-only archive snapshot; no branch/worktree was created.

## Prior verified history

- D4-A runtime focused suite: commit 020531cb555cce949442ec4a257ca557255c9e4a; D4-B coverage efb26c1288575ab6a0477278f6d71d6e14830bd5; D5 coverage 6f42f2a2fea2799427838c7c3d83bfb3bc6dc5bb.
- R6/D6 runtime/test commit 1ffa078099d86e893eec7434ecaa2934791e6e41; Windows Godot 4.7.2 import plus 15 focused tests, 16/16 exit 0, on that exact older commit.
- D7/D8 selected 18-test evidence is recorded for 36deee77758027e3394230a0594df5574b42bcf5; rerun affected suites after the HS-09 commit.

Do not claim the game is playable/accepted or FULL COMPLETE until real New Game, production, skills/PvE, rewards and Save/Return/Reload pass on one exact SHA with GUI evidence. Preserve one canonical runtime, save, scheduler, One Active Job, Injury120 and Warehouse.