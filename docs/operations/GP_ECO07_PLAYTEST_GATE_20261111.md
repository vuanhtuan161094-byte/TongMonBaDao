# ECO-07 — Owner Playtest Release Gate (preparation only)
**Project:** Tông Môn Bá Đạo | **PR:** #72 Draft | **Branch:** `integration/pve-p0-playable-ui-20261103` | **Godot:** 4.7.2 | **Display:** landscape 1280×720
**Status:** `PREPARED / ECO-06 FULL QA GATE PENDING`. This document does NOT start ECO-07 gameplay changes and does NOT certify hardware testing.

## 0. Entry gate and source provenance
- ECO-05 accepted: [Godot run #42996610325](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42996610325) completed SUCCESS, 22/22 official steps, tested source SHA `81dd8eb0021f07b32b71299284c1502f81a22ac7`. 32 source-funded paid production slots at Hall Lv8 and a separate synthetic 480-roster index/Save stress were proven; **not** 30 simultaneous real employed disciples.
- ECO-06 UI code: `d5c782dd05e10d18d1878b98e5a9fa0d8fff7411`, `c5a3bac625d1a9a24eccf4e645117780132abe2a`; workflow added `132c84158c0cf96e67740dcbe8450ba6b3059e01`.
- [ECO-06 original workflow #43001562896](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43001562896) tests `132c8415`. It has already passed import, strict parsing, actual main-scene UI focused test and real Economy-A interactive UI at last inspection, but FULL P3.7 still pending.
- Test-only correction `6b132c7abb901afdb4ecf6446b79fd0c2c89ca89` ensures Field seed affordability checks `ĐỦ PHÍ` **or** `THIẾU LT` against actual wallet, including the required 0-LT New Game path. The exact-SHA [ECO-06 rerun #43004049546](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43004049546) has not yet completed.
- **DO NOT OPEN ECO-07 until the latest ECO-06 focused and FULL Godot workflow is completed/success, all regression steps confirmed and checkpoint/handoff updated with exact SHA/log.** No automation/recurring monitoring by owner instruction.

## 1. Windows OneGame real-machine route
1. On the owner's existing PC, inspect `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao`: verify Git remote/branch/HEAD, working tree, save and archive; never silently pull, reset, clean, merge or overwrite.
2. Use the existing single owner entrypoint `MO_GAME.cmd` from this canonical checkout; it checks Git ancestry and Godot 4.7.2 and starts `tools/windows/run/Run-OneGame-NewGame.cmd`. **Do not invent another launcher/game.**
3. The launcher uses an isolated persistent player test profile at `godot\outputs\one_game_newgame\owner_playtest_profile`; per-launch logs live under `godot\outputs\one_game_newgame\sessions\<run_id>\logs\game.log`. Copy/backup original user data before any destructive experiment. A missing executable/asset means PENDING USER, not PASS.
4. Record actual native fullscreen/window 1280×720 landscape screenshots, readable labels, tap/click hitboxes, close/open and retained scroll/focus, FPS/frame time, RAM, crashes/driver messages and both mouse and Android touch behavior. Do not extrapolate physical performance from headless Linux CI.

## 2. Owner journey matrix (real canonical sources only)
| ID | Player action | Truthful acceptance |
| --- | --- | --- |
| W01 | Clean/legacy Save, New Game with **0 LT** | No invented starting cash; Hall Linh Mạch 60-minute real free worker job, 1000 LT gross once/1440 sim ticks; duplicate/cross-day guard |
| W02 | Recruit and assign 6 real disciples | One Active Job, available Mine/Forest/Field capacity and worker busy/hold visible; no second job or fake position |
| W03 | Mine and Forest | Actual selected resource and amount, active ETA/workers, carry/harvest settlement appears in canonical Warehouse only once |
| W04 | Field | Per-crop seed fee/affordability (0 LT block), reserved plot, ETA, no premature stock, actual Warehouse harvest receipt |
| W05 | Main Hall | Partial ledger distinguishes market sale, Origin Vein gross, purchases, seeds, actual wage paid and real Sect balance. Never call `net_recorded` total profit |
| W06 | Phường Thị | Stock/reserve/lock and effective NPC daily cap; preview does not debit, confirm once actually debits/credits; 0-NPC scenario shows no real sales |
| W07 | Kho -> Luyện Đan -> Consumer | Recipe inputs debit once; inventory quantity, reserve and usable stock remain consistent after cold Save |
| W08 | Upgrade Hall / paid annex | Prices are real stone/ore/wood; insufficient funds blocks; idempotent transaction; source-backed site counts |
| W09 | 30-worker scenario | **Separate from 32 funded slots:** recruit/assign **30 valid real disciples**, test simultaneous work, wages/taxes, offline time, and Save/Load. Unproven until actual test |
| W10 | Max-roster 480 scenario | Distinguish synthetic QA index/Save stress from legitimate player recruitment and active work; measure UI and Save latency, no 480-fold fabricated revenue |
| W11 | Save/reopen at 60/90/180-minute jobs; offline/day roll | No double harvest/receipts; original prior save unchanged; one worker cannot settle two jobs |
| W12 | PvE entry/return and inventory | Confirm 6-unit team, health/injury gating and returning to OneGame. Combat/VFX/skills remain owned by separate stream; do not mark its unfinished work as ECO pass |

## 3. Android hardware gate
- Install only a genuine versioned Android build if an export pipeline and compatible device are available; no simulated Android APK certification.
- Physical landscape gestures, pinch/pan and zoom, buttons at least tap-safe, panels near full screen, fonts, overlaps and map occlusion; log device model, Android version, FPS, RAM, crash/ANR and Save/Load.
- Windows/Android unrun = `PENDING USER`; screenshotless headless tests are `AUTOMATED ONLY`. Owner visual acceptance is a separate gate.

## 4. Scope/release controls
- Public `LT2/W2/T2` and site tax 0–100%, r3+, combat/VFX/monsters/skills remain **HOLD** within this economic packet. No SaveService or shared-state edits, no new branch/merge, no production money/material injection.
- Maintain PR #72 Draft until user signs off. For any bug: record reproducible exact source SHA, player steps, expected vs actual, device/log, implement smallest scoped fix, rerun focused + cumulative on its new SHA, update checkpoint and handoff.
- **ECO-07 can begin only after ECO-06's own exact-SHA terminal FULL SUCCESS.** Deliver a OneGame playtest launch packet and honest PASS/FAIL/PENDING evidence, not a claimed released Android/Windows binary without physical testing.
