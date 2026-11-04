# Tông Môn Bá Đạo — PVE-P0 gameplay integration packet (2026-11-03)

**STATUS: INTEGRATED IN AN ISOLATED GITHUB BRANCH; GODOT/PLAYER RC ACCEPTANCE OPEN.**
**Integration branch:** `integration/pve-p0-playable-ui-20261103`, created from hardened backend `d5c1e2c3d144adb6fdb53d57aeaf836424780f9e`. That backend is a descendant of PR #67's remote HEAD `f2ae694af791a27deec4e1de7ae7c122914be635`. This is not a change to PR #67, the public `main`, or any Windows user save.

## What is wired into the main Godot 1280×720 scene

- Start Thanh Trúc Lâm with **1–30 genuinely recruited and eligible V2 disciples**, default `solo:disciple_id` identities. No six-person obligation for normal open-world hunting.
- Existing **Boss** path keeps its **exactly-six-person formation rule** and original boss-specific flow, rather than silently turning Boss into 30 solo members.
- During a live distributed world, **+ Đệ tử** opens the authentic recruitment eligibility selector (one new person per join) and calls `PveP0CommandsV1.join_one` plus the live SaveService barrier. A disciple's own summary can also join an active P0 world.
- Select exactly one live hunter then **Rút 1 người** calls `PveP0CommandsV1.return_one` and the SaveService barrier. The last living hunter must use the existing explicit **Về tông môn** whole-world retreat.
- Select a hunter on the real Source A map, use **AUTO/HOLD** or click-map / minimap; callbacks call `PveP0CommandsV1.hunt_policy` or `PveP0CommandsV1.move` on the runtime owner, not renderer authority.
- **Đóng bản đồ** is separate from **Về tông môn**: a successful SaveService barrier closes only the map and leaves the single canonical scheduler/active hunt running. Quick-entry reopens the cached/resumed encounter.
- P0 world status now describes **Tu Vi + Luyện Thể + materials delivered to the canonical Warehouse**; the legacy text “LOOT_PENDING” is not shown for distributed-P0 kills. No new EXP wallet, synthetic equipment, second scheduler or PvP.

## Changed scope

Production scene: `godot/src/presentation/p3_2_landscape_sect.gd` (UI-owned integration on this **new** branch only). It calls the already implemented, hardened P0 simulation files present in the parent branch. A new UI test `godot/tests/presentation/pve_p0_ui_player_entry_test.gd` stages New Game with real recruitment and an isolated `user://qa_pve_p0_live_ui_<pid>.json` SaveService; it exercises solo dispatch, selected HOLD, closing/reopening, late joining/individual withdrawal. Existing test artifacts and the P0 focused workflow are retained; the workflow now attempts an official Godot 4.7.2 P3.2 parse and UI test in addition to simulation and cold-reload test.

## Hard evidence boundary

Codex's report from the **owner's E: checkout** states a New Game -> Residence -> recruit -> Mine -> PvE -> separate-process Save/Reload cycle passed, but the PvE run ended `timeout_retreat` without a documented rewarded monster kill. That is valid evidence of deployment and save, **not a P0 per-kill loot acceptance** and not proof of a finite hunt “win”. P0 free-hunt is continuous: the correct reward oracle is **authoritative HP=0 -> receipt -> Tu Vi / Luyện Thể / canonical Warehouse**, followed by generation2 -> another receipt, with replay/cold-load idempotency.

**Local-source blockade:** The reported E:\\TongMonBaDaoWorkspace\\01_Game\\TongMonBaDao checkout is at `27ed01cd8f377994e5e50bac9ede84e78e8895bd` with **196 dirty/untracked items**. The currently exposed GitHub connector **cannot read, copy, back up, change, merge or launch files on E:**. DO NOT run `git reset --hard`, `git clean -fd`, destructive checkout, or copy a GitHub source tree over that directory. Before adopting the integration, preserve those local changes, compare each shared file to the verified branch and use a distinct clean E: worktree/backup. A local preflight manifest/fingerprint failure in `CHOI-GAME.cmd` remains a separate launcher blocker, not something this branch has magically fixed.

## CI and remaining gates

Official Godot **4.7.2** execution was requested via the branch-triggered `.github/workflows/pve-p0-free-hunt.yml`. Initial GitHub workflow runs on the branch were reported as FAILED **with zero job steps**. A failed workflow that never reached import or test provides **no proof of a code regression or success**. Obtain a Godot runner with actual log/step evidence.

Acceptance requires, at minimum:
1. Godot import and parse all changed GDScript, PVE-P0 New Game solo natural test including second-generation per-kill rewards and cold-load, 30x20 world-cap, P3.2 UI new test, original minimap/formation, V6.3 Codex receipt, Injury120 and affected economy/Save regressions.
2. Windows visible game: click to choose 1–30, select live hunter, AUTO/HOLD, late-join, withdraw one, hide/reopen map, Save/Exit/Reload, real kill and visible warehouse/character progression. Confirm the joystick/touch alternative on Android later.
3. Preserve the E: 196 working-tree changes; resolve collisions with local Codex P3.2 modifications by explicit review, not blanket cherry-pick/merge. Launcher fingerprint must be intentionally regenerated only for a verified source and never bypassed.

**Not accepted as complete:** whole G0/G1/G2 RC, player-visible PvE kill+loot, launcher Windows, physical input, or source E: sync.
