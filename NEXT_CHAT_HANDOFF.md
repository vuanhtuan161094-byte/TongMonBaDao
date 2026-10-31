# NEXT CHAT HANDOFF — ONE GAME V6.5 / HS-09

Continue on integration/one-game-v65-20261030. Fetch the live branch first. HS-09 code commit is be37bca1725e9cc19e710dba3f3f796041ac78e7; a documentation-only checkpoint follows it. The latest previously runtime-tested code is R6/D6 at 1ffa078099d86e893eec7434ecaa2934791e6e41. Do not describe the newer HS-09 code as tested.

## Immediate authorized work

HS-09 code commit be37bca1725e9cc19e710dba3f3f796041ac78e7 adds the seven-tab disciple profile, read-only gated V6.3 projection and dual-foundation radar. Exact changed paths:

- godot/src/presentation/p3_2_landscape_sect.gd
- godot/src/presentation/disciple_presentation_snapshot_v2.gd
- godot/src/presentation/p3/hs09_dual_foundation_radar.gd
- godot/tests/presentation/hs09_disciple_profile_test.gd

Owner approved those paths plus their Godot-generated .uid sidecars and these two handoff documents. Do not expand into simulation, save, economy, gate defaults, assets, main or PR #52 without a new exact-path authorization. The HS-09 runtime/test source has NOT been run through Godot yet.

## QA blocker and preserved environment

- The radar's label string includes a newline but currently uses draw_string; static review records multiline rendering/clipping as PENDING, not a confirmed defect. Verify the real 1280x720 render before any fix.

- Latest process check: PID 15996 remains listed as Godot_v4.7.2-stable_win64, Responding=true, 28,672-byte working set, no main-window title. Windows denied start time, user, executable path and command-line queries; tasklist/CIM returned Access denied. PID 6944 was transiently observed at 164,552,704 bytes and absent on the next enumeration. Latest available-memory sample was 1,394 MB (recent samples 1,074–1,394 MB). Do not kill any user process or start a second Godot while ownership remains unknown and RAM is low.
- The previous launcher smoke used a stub executable: contract-only PASS, not a game launch.
- Stage A installer restored 42 PNGs in the isolated QA snapshot, pack SHA-256 6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca. Godot import and Stage A test remain PENDING.
- Source A UI intake contains 26 hashed CANDIDATE assets, all owner review/mapping pending. Do not import or replace art.
- Keep the old dirty E: checkout and all owner saves untouched. Use only the isolated ONE GAME QA checkout and redirect test APPDATA/user data there.
- The available archive snapshot at E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030\checkout_095ff has no local HEAD and contains the 095ff source as untracked files; it is not current SHA 3ccaa15. The canonical E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao was read at 5e6fdd966bdf710b71e2a1539bb712e44069a4bb with seven untracked paths; leave it untouched.

## Next steps, in order

1. Once PID 15996 exits or the owner confirms the active session is safe to close, verify Godot 4.7.2 and free memory; update the isolated QA snapshot from the exact live branch SHA without touching old workspaces.
2. Run editor import once, then sequentially run hs09_disciple_profile_test.gd, existing P3.2/presentation and DV2/radar tests, D3 learning UI/job, D2 Archive/drop receipts, P3.7 Warehouse, SaveService async round-trip, SAFE-01 recovery and PvE Save/Return/Reload. Generate only Godot-authored .uid files. Record command, exit code and log for each; repair only direct HS-09 regressions within the approved paths.
3. Use Run-OneGame-NewGame.cmd with an isolated fresh profile for actual P3.2 New Game and bounded player journey. Capture real gameplay only from Godot. Do not substitute Run-PVE-Play's 130-disciple seed or the prior stub smoke.
4. Inspect canonical HP0/loot/EXP receipts and Save/Return/Reload. Keep unresolved reward definitions BLOCKED; never invent EXP or drop rates.
5. Compare the actual Godot profile to the approved HS-09 HTML direction. Physical visual review, Source A rights/mapping, Android and FPS/RAM remain separate gates.
6. Update this checkpoint and Issue #56 once there is meaningful evidence. Commit/push only to the existing integration branch; do not merge.

## Prior verified history

- D4-A runtime focused suite: commit 020531cb555cce949442ec4a257ca557255c9e4a; D4-B coverage efb26c1288575ab6a0477278f6d71d6e14830bd5; D5 coverage 6f42f2a2fea2799427838c7c3d83bfb3bc6dc5bb.
- R6/D6 runtime/test commit 1ffa078099d86e893eec7434ecaa2934791e6e41; Windows Godot 4.7.2 import plus 15 focused tests, 16/16 exit 0, on that exact older commit.
- D7/D8 selected 18-test evidence is recorded for 36deee77758027e3394230a0594df5574b42bcf5; rerun affected suites after the HS-09 commit.

Do not claim the game is playable/accepted or FULL COMPLETE until real New Game, production, skills/PvE, rewards and Save/Return/Reload pass on one exact SHA with GUI evidence. Preserve one canonical runtime, save, scheduler, One Active Job, Injury120 and Warehouse.