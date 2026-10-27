# Night Shift — safe E workspace finalization

**Captured:** 2026-10-27 19:22 Asia/Saigon  
**Authority:** [Issue #37 comment 6441454591](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37#issuecomment-6441454591), [PR #52 comment 6441455832](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/52#issuecomment-6441455832).  
**Remote candidate:** `integration/pve-unified-rc-20261027`, Draft PR #52, exact HEAD `0bc96348e6ef1a2eb945e9713e3faeb8912fb07d`; tree `485d79b3060f22a8b552b52c3e0352f34ccaefb1`. GitHub confirms the branch is 2 commits ahead of `0d3952dd11f85bebbde60176deafc4f19afc8a6f`, so the launcher’s remote ancestry baseline is valid.

## Result

No source checkout was switched, overwritten, or deleted. No Godot process or Source A/Python/Spine/MovieWriter/FFmpeg worker was found in the process-name scan. The resource gate **FAILED**: during a 60-second read-only CPU sample, CPU reached 76.9%; available RAM ranged from 1,645 to 2,172 MiB after the initial 2,052 MiB reading, below the required 2,200 MiB. System log sampling found nine recent Kernel-Power 41 events among the most recent 200 Level 1/2 System events from the last seven days. Therefore no Godot editor/import/test, GUI launcher, FPS benchmark or gameplay capture was started.

Git CLI uses Git Credential Manager `2.9.0+194ba290ce533465310d50f811684ab180536ae7`. After network permission was granted, read-only `git ls-remote` failed with `SEC_E_NO_CREDENTIALS (0x8009030e)` (exit 128). No credential was changed or requested in chat. The authenticated GitHub connector still verified the remote PR/head/tree. Local Git repositories are owned by other Windows sandbox identities, so commands used per-invocation `safe.directory` only; no global Git trust setting changed.

## Workspace state

| Path | State observed | Action |
| --- | --- | --- |
| `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao` | Real directory, not a junction; branch `main`, HEAD `5e6fdd966bdf710b71e2a1539bb712e44069a4bb`; 46 root CMD files; seven untracked status entries shown (some directories collapse multiple files). | **KEEP.** Not switched; untracked/ignored data untouched. The older 435-entry SHA register matched in the prior shift, but this shift did not rehash it because resource pressure was already high. |
| `E:\TongMonBaDaoWorkspace\01_Game\TMB_RC_STAGING_8aee3d88` | Clean local rehearsal branch `cmd-migration-rehearsal`, synthetic HEAD `8ec30dfbc5734730a01ea7c3fbfb7e0763da6aad`, tree `485d79b3060f22a8b552b52c3e0352f34ccaefb1`, matching the remote RC tree. It does **not** contain remote commit objects `0bc963…`, `8aee3d…` or `0d3952…`. | **KEEP as staging only.** Same files/tree are not the same exact commit. No Desktop shortcut may target this path. |
| `E:\codex\2026-10-26\TMB_PVE_UNIFIED_RC_QA_WORKTREE_20261027` | Branch `integration/pve-unified-rc-20261027`, local HEAD `4ba1ccad25c1d03053cefbc724c1a19287d4c0f3`; modified checkpoint/installer/test and numerous untracked `.import`, QA evidence and userdata paths remain. | **KEEP.** No reset/clean or file edits. |
| `[Codex-managed C: recovery worktree]` | Branch `recovery/pve-playable-visual-a1-20261027`, HEAD `59c6dea9041653026e02a55b0bc1f4e298976835`; 3 modified files + 1 untracked file; long-path warnings while reading status. | **KEEP.** No C: files changed. |
| `E:\codex` | Nine top-level dated/app-managed directories observed. | **KEEP.** No session/worktree folders moved or deleted. |

E: free space was 30.31 GiB; C: free space 9.90 GiB. Earlier verified backups and original asset/save locations remain untouched. No deletion or migration was performed in this shift.

## One-click entry / scripts

- Canonical E checkout is still old `main`, not RC; so `MO_GAME.cmd` is not a verified PvE entry from the canonical path. Desktop link `%USERPROFILE%\Desktop\MỞ GAME TÔNG MÔN BÁ ĐẠO.lnk` is **absent and intentionally not created**.
- Canonical `main` currently has 46 root `.cmd` files. The separate RC staging tree has one root `.cmd`, `MO_GAME.cmd`; it also contains the four expected moved scripts. This is static inventory only, not a new local exact-RC checkout.
- Female Stage A’s expected hair PNG and all 42 PNGs were present in the staging tree. Official editor path exists at `E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe`; the separate console binary exists at `E:\Godot_v4.7.2-stable_win64_console.exe`. Engine version/import and CMD execution were not checked this shift.
- The PVE launcher, FPS launcher and installer were inspected statically. No smoke command was executed. Earlier Stage A install-only evidence is historical and is not presented as a test on the current exact RC commit.

## Status by P0–P5

| Item | Result |
| --- | --- |
| P0 CPU/RAM/process safety | **DONE / FAILS RUN GATE** — CPU/RAM over limits; recent Kernel-Power events; no game/Source A worker visible. |
| P1 canonical E checkout | **PENDING** — preserved `main`; exact remote checkout blocked by Git CLI `SEC_E_NO_CREDENTIALS` in this sandbox. Remote source tree is known, local RC commit objects are absent. |
| P2 Desktop shortcut | **PENDING** — canonical checkout not verified as RC; no misleading shortcut created. |
| P3 moved CMD/Godot QA | **STATIC PARTIAL** — canonical 46 vs staging 1; required paths and Stage A asset files exist in staging. No runtime/Godot tests. |
| P4 P3.2 performance audit | **STATIC REVIEW COMPLETE; profiler PENDING** — see `P3_2_STATIC_PERFORMANCE_REVIEW.md`. No causal GUI/FPS claim. |
| P5 GitHub evidence | Local files are ready; Issue #37/PR #52 comments will link this report and state GUI/FPS remain pending. Git CLI push is blocked; authenticated GitHub connector remains available for the non-code evidence report. |

No gameplay code was changed. No main merge, reset, clean, force push, new branch or deletion occurred.

