> **HISTORICAL ARCHIVE — NOT LIVE INSTRUCTIONS (2026-11-04).** This is a verbatim snapshot of `NEXT_CHAT_HANDOFF.md` before the one-game release-train cleanup. Its old SHAs, PRs, run commands and implementation status must NOT be used as current directions. Use `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md` and [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56) from the live integration branch. Original source blob SHA: `419290aad4fd8456327255913a6274e03e0dd618`.

---

# TRI-03 G0 → G1 → G2 update — 2026-11-03

**Latest source commit:** `36532c39f294e1eb56d73d8ce0c0eb7cb68c5567` on `integration/tri-facility-a-b-playable-20261102`, parent `c136600f5579871d476e0feca2d78ea3c74e6b1f`. PR #67 remains Draft, open and unmerged. The completed evidence set is in [G0_G1_G2_EVIDENCE](docs/qa/TRI03_OWNER_FINAL_20261103/G0_G1_G2_EVIDENCE/EVIDENCE_INDEX.md).

- G0 current-source focused Save/Reload regressions: PASS. Full 14-case G0 rerun from a clean checkout of this source commit: PENDING; prior 14/14 is historical evidence only.
- G1 New Game paid Residence construction, actor-occupied placement rejection, real candidate recruitment/profile/assignment, Save, and second-process Reload: PASS in a windowed OpenGL harness at 1280×720. Input was harness-injected.
- G2 B1 UI contract/live callback tests and 1280×720 Godot captures: PASS. Source A 510052/510076/510111 hashes unchanged. Generated 16-icon UI atlas is explicitly original generated art, not Source A, and awaits owner approval.
- The Windows checkout remains local HEAD `27ed01cd8f377994e5e50bac9ede84e78e8895bd` with existing dirty/generated QA files preserved. Its 49 pinned source blobs match the source commit’s Git tree exactly; this is not a clean Git checkout at the source commit.
- The one-click launcher verified and opened the normal Godot window (PID 13624), left open for the owner. UI Computer Use did not enumerate that Godot window, so physical Windows mouse acceptance is PENDING. Android/touch and owner visual sign-off are also PENDING.
- Godot stderr contains a non-fatal Windows root-certificate-store warning. No parse errors were found; certificate checks were not disabled. No owner default save was touched.

Evidence: [matrix](docs/qa/TRI03_OWNER_FINAL_20261103/G0_G1_G2_EVIDENCE/TEST_MATRIX.csv), [filtered logs](docs/qa/TRI03_OWNER_FINAL_20261103/G0_G1_G2_EVIDENCE/RAW_LOGS_FILTERED.txt), [source and asset hashes](docs/qa/TRI03_OWNER_FINAL_20261103/G0_G1_G2_EVIDENCE/SOURCE_MANIFEST.json). This status supersedes the older checkpoint text below.

---

## FINAL DELIVERY — Windows playable RC status (2026-11-02)

**Status: BLOCKED for physical Windows delivery; automated focused QA PASS.** Live PR #67 HEAD was checked as `df6f55ee63d36c77e52b5d9eaf3c5743349b935a`; code/capture SHA tested by official Godot 4.7.2 is `8979dca68495a74ad272ca4c861034040bf385f7`. PR stays Draft and unmerged.

### Exact-SHA evidence

[Godot 4.7.2 O2 workflow 41402324227](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41402324227) completed SUCCESS: import/parse, O2, P3.7C1/Dẫn Tiên, B1 contract/live callbacks, independent two-process SaveService reload, DD092, Source A checks, four 1280×720 map/B1 captures and P3.6A. [Capture artifact](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41402324227/artifacts/13122450868). This was Ubuntu/Xvfb/llvmpipe, not Windows mouse acceptance.

### E: source and launcher

- Canonical `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao` is unchanged on `main` @ `5e6fdd966bdf710b71e2a1539bb712e44069a4bb`, with the existing seven untracked QA entries preserved. No user save was accessed.
- Exact-source folder `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao_PR67_QA` and launcher `E:\TongMonBaDaoWorkspace\01_Game\CHOI-GAME-THU.cmd` are **not present**. The official binary exists at `E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe` and reports `4.7.2.stable.official.ed1daf0bf`.
- Local Git does not contain commit `df6f55ee63d36c77e52b5d9eaf3c5743349b935a` (`git cat-file -e` failed). E: main is 259 commits behind PR base `970af33b` by ancestry; it cannot serve as a PR67 checkout.
- Fetch attempts: Git HTTPS/GCM returned `SEC_E_NO_CREDENTIALS`; disabling the helper for a read-only OpenSSL attempt could not prompt without a TTY; codeload and the signed Actions artifact URL both returned Windows `Authentication failed`; Node fetch also failed. The authorized GitHub connector provides metadata/text but not a local binary source archive.
- No launcher was created against a missing checkout, so it cannot be mistaken for a playable PR67 build.

### O6 / GP-01 / GP-02A locator assessment

Static review at PR #67 shows those older tests search for `GuidanceRecruitOrder` and `AcceptCandidate_<id>`. Current B1 controls are named `UseRecruitmentOrder` and `AcceptCandidate`; the live adapter connects those controls to canonical RecruitmentSystem callbacks. The exact-SHA O2 live integration gate passes real recruitment and independent reload. This supports a **legacy test-locator mismatch**, not evidence that recruitment gameplay is broken. No fake controls were added and no assertion was weakened. The complete O6/GP runs remain **PENDING** on Windows.

### Final gates

| Gate | Status |
|---|---|
| Exact-SHA Godot 4.7.2 automated focused suite and 4 captures | PASS |
| Windows PR67 QA checkout and one-click playable launcher | BLOCKED — source transfer/auth unavailable |
| Windows 1280×720 mouse playthrough of three facilities | PENDING USER |
| GUI Save → exit → launcher → Reload receipt verification | PENDING USER |
| Android/touch and owner visual acceptance | PENDING USER |

Safe workaround: restore official Git Credential Manager sign-in in the Windows session (no token/password in chat), then fetch this existing branch into the isolated QA folder. The canonical game directory and untracked files must remain untouched. Do not claim PLAYABLE RC until the launcher runs this exact PR source.

---


## Safe continuation

Use only official interactive Git Credential Manager login in the Windows session to restore source fetch. Then create the isolated exact-SHA worktree, set a separate QA APPDATA/profile, create and test the launcher, and complete physical input + Save/exit/reload. Keep the current main checkout and its untracked entries unchanged.

# NEXT CHAT HANDOFF — TRI-03 Windows GUI gate

Continue only on PR #67 branch `integration/tri-facility-a-b-playable-20261102`; fetch its current live HEAD before work. Latest code tested is `8979dca68495a74ad272ca4c861034040bf385f7`; the documentation commits may make the branch HEAD newer. Do not merge main or use the canonical E: game folder as a QA source.

## Completed at exact code SHA

Official Godot 4.7.2 O2 workflow [41402324227](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41402324227) succeeded. It passed project import/parse, O2, P3.7C1/Dẫn Tiên, B1 contract/live callbacks, independent two-process SaveService reload, DD092, Source A alpha assertions, four actual 1280×720 map/B1 renders, and P3.6A. Screenshot artifact: [13122450868](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41402324227/artifacts/13122450868). Full markers and matrix: `docs/uiux/B1_TRIFACILITY_UI_QA_20261102.md`.

Code delta so far is only the B1 button minimum target increase to 48 px. CI review thumbnails show no new overlap/clipping, but full-resolution Windows owner visual review is not complete. Facility hashes remain pinned; Guidance building art is distinct from candidate portrait fallback.

## Required next action

1. Restore a secure authenticated Git CLI/GCM session or otherwise make a verified exact-SHA PR #67 checkout in an isolated QA directory on E:. Keep `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao` untouched; it is main @ `5e6fdd966bdf710b71e2a1539bb712e44069a4bb` and contains untracked QA files.
2. Use official Windows Godot 4.7.2 with a separate QA profile, then perform the real 1280×720 mouse journey: map→Hall/Residence/Guidance, legal/disabled actions, pan/zoom, close/reopen, Save→Return→Reload, and verify no duplicate receipts. Capture native PNGs and logs.
3. Compare the full-resolution captures to artifact 13120779305 and current artifact 13122450868. Keep Android/touch **PENDING USER** until tested on device. Do not claim physical GUI acceptance from CI renders.

No game save was touched in the prior run. Keep PR Draft. The Windows session currently lacks working Git/GCM HTTPS auth; no branch checkout was fetched locally.

---

# NEXT CHAT HANDOFF — ONE GAME V6.5 / HS-09 QA

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