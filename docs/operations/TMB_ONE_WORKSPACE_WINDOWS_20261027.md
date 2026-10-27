# TMB — ONE WINDOWS WORKSPACE + GITHUB SOURCE OF TRUTH (27/10/2026)

Owner: gom tat ca game, tools, asset va QA ve o E, chi mot game, mot noi mo; script CMD cu phai duoc phan loai va thu gon, khong xoa du lieu tu tien.

## Locked local layout

| Role | Location |
| --- | --- |
| Canonical owner game checkout | E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao |
| Source A / JX masters, original rights/provenance | E:\TongMonBaDaoWorkspace\02_Assets |
| QA stdout, logs, FPS, screenshots | E:\TongMonBaDaoWorkspace\03_QA_Logs |
| Godot 4.7.2, portable tools | E:\TongMonBaDaoWorkspace\04_Tools |
| Preserved old unique worktrees/outputs | E:\TongMonBaDaoWorkspace\90_Archive |

Current development authority remains PR #52 on integration/pve-unified-rc-20261027. main is stable until explicit owner approval after GUI/FPS, and audit/tmb-whole-project-readiness-20261027 stores QA evidence. Last clean full Godot headless regression belongs to source tree 0d3952dd11f85bebbde60176deafc4f19afc8a6f, 22/22 PASS. A workspace/launcher change is NOT a new gameplay or GUI QA PASS.

## .cmd root inventory at source SHA 0d3952dd

44 root CMD launchers: 5 Run-, 9 Sync-, 23 Verify-, 6 Preview-, 1 Install-. 95 CMD/BAT/PS1 files total in repository. Most are OLD QA/phase controls, not distinct user game releases. Root currently has %~dp0-dependent launchers, so blindly moving those scripts breaks relative callers.

User entrypoint = MO_GAME.cmd, located in canonical game directory on E and desktop shortcut pointing to that file. This verifies that checkout descends from QA RC baseline, finds Godot on E, bootstraps Stage A only if missing with official checksum, calls Run-PVE-Play.cmd. Technical launchers now live under tools/windows/{run,qa,sync,preview,bootstrap}; root keeps MO_GAME.cmd as the only user entrypoint. Re-run the launcher and focused Godot regressions after migration.

Final desired GitHub root: one owner-visible game launcher; technicians under tools/windows/qa, tools/windows/sync, tools/windows/preview, tools/windows/bootstrap or tools/windows/legacy. Moving them requires cross-file caller search, update relative paths and GitHub/Windows QA, not deleting all 44 now.

## CODEX: mandatory C+E inventory and safe migration (execute; not planning-only)

1. Inspect these EXACT existing paths without deletion or recursive junction following:
   - C:\Users\Admin\Documents\Codex\2026-10-26\t-ng-m-n-b-o-4\work\TMB_RECOVERY_WORKTREE
   - E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao
   - E:\codex and known PR #50/#51/#52 QA worktrees
2. Per root: physical/reparse point/junction target, HEAD + branch, worktree common dir, dirty tracked/untracked/ignored files, top-level asset/output sizes, save locations, locks/active Codex process, free E disk. Use git worktree list --porcelain, git status -uall, Get-Item Attributes/LinkType/Target. Do not run Git reset, clean, gc, fetch on broken shared object store or follow junction loops.
3. Write BEFORE inventory and SHA preservation register to E:\TongMonBaDaoWorkspace\03_QA_Logs. Classes: CANONICAL, ACTIVE_CODEX_WORKTREE, UNIQUE_UNTRACKED, ASSET_MASTER, QA_OUTPUT, VERIFIED_DUPLICATE, APP_MANAGED_SESSION, UNKNOWN. Never infer duplicate only from name/date/size.
4. If game path is existing junction or dirty checkout, do NOT overwrite. Use new clean E staging checkout from exact RC ref, compare and copy-first backup user saves/unique assets, verify checksum and repo SHA, then promote only if target is safe. New checkout on E is NOT a new GitHub game branch. Do not move an active Git worktree with Explorer; git worktree move if supported/safe or preserve and fresh clone.
5. Codex app can keep session metadata/cache under C despite source working in E; do not delete app-owned active files. Opening E checkout in Codex and choosing E as its workspace must become default.
6. Under E canonical checkout, run the new MO_GAME.cmd for real GUI (if accessible) and create desktop shortcut with Vietnamese title. No shortcuts to C Codex cache. No editor/project-relative save outside isolated test path.
7. Script cleanup: generate complete invocation/call graph from all .cmd/.bat/.ps1/.gd/workflows and currently used docs. For each of 44 root scripts, classify OWNER_ENTRY, ACTIVE_QA, REQUIRED_DEPENDENCY, HISTORICAL_LEGACY, SAFE_ARCHIVE. Move historical files via git mv to tools/windows/* on RC, update paths/callers/working-directory semantics, keep only needed compatibility stubs, test moved entrypoints and full relevant Godot regression. Goal root <=3 CMD after safe staged migration, eventual root 1 if no technical contract blocks; don't weaken tests to hit count.
8. Commit/push scoped launcher/root restructuring only on existing RC branch, and sanitized inventory/evidence to existing audit branch. Recheck SHA and document which test results apply to which commit.
9. Physical moving/removing C/E source directories only after before/after hashes, active-session release, rollback and owner review of deletion list. Do not delete player saves, original Source A/JX packs, .import/untracked unique data. Avoid robocopy /MIR, del /s, rd /s, hard reset, force push.

## Exit report required

- E canonical actual path + checkout exact SHA, Desktop shortcut target, real launch result, any missing Windows input.
- Root CMD before 44 -> after N, list old->new path and caller/test proof.
- C/E directories with statuses KEEP/MOVED/ARCHIVED/DELETION_PENDING_OWNER, sizes, hashes and recovery paths; confirm no hidden Git/asset or save loss.
- GitHub PR #52 branch SHA, Issue #37 links, audit evidence commit; current GUI/FPS status truthfully PENDING if not captured.
