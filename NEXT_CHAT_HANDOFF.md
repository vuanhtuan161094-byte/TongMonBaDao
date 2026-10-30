# NEXT CHAT HANDOFF — ONE GAME V6.5 INTEGRATION

Continue from `integration/one-game-v65-20261030`. Fetch GitHub first; R4 / D4-A gameplay code was tested at `020531cb555cce949442ec4a257ca557255c9e4a`. A documentation-only checkpoint may sit on top; always use the live branch SHA.

## Read before editing

1. Repository `AGENTS.md` §3 and `docs/operations/TMB_V65_FULL_COMBAT_EXECUTION_CONTRACT_20261029.md`.
2. Owner authorization and latest checkpoint on [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56); shared-file conflict matrix on [Issue #54](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/54#issuecomment-6520099847).
3. This file and `CURRENT_CHECKPOINT.md`.

## Work lane and preserved state

- You are the exclusive writer on the existing integration branch only. Do not edit PR #52, V6.5 source, `main`, or create another branch/PR.
- Use the isolated E: checkout `E:\TongMonBaDaoWorkspace\01_Game\TMB_ONE_GAME_V65_20261030` for Windows Godot QA. Do not use, clean, move, or delete the older workspaces or real saves.
- Godot: `E:\Godot_v4.7.2-stable_win64_console.exe` (4.7.2 stable).
- QA logs: `E:\TongMonBaDaoWorkspace\QA_Evidence\ONE_GAME_V65_20261030`. The local clone has generated import sidecars and test mirrors; do not stage them.

## Verified checkpoints

- R1 `70271184a7c3d1d1dfb374c0050424e263bf7a16`: content registry and gates.
- R2 `f4316ab0881c3a34c24c754aec922030be911971`: Archive/Warehouse and open-world exactly-once codex receipts.
- R3 code `d0223f93cba330dcc562edb4ec48e953217f3334`; D3 picker correction `f18e4d6419f9ac43cf4a9fac119a415cb4f0c40d`: gated Human/base technique study, one active job, scheduler, additive SaveService migration, 12-item D3 picker, tested against legacy/save/production regressions.

All R3 focused tests pass. SAFE-01 recovery prints expected malformed-save parser diagnostics while exiting 0 with PASS. See `CURRENT_CHECKPOINT.md` for exact commands/log hashes.

## Next authorized code packet

Proceed to **R6 / D6: Divine lineage and rare successors**, on this same integration branch. Fetch both live refs first, then inspect `v63_d6_divine_lineage_combat_test.gd` and `v63_d6_rare_successors_test.gd`. Reuse the single Combat V2 adapter, the D3 single active study job, current SaveService and Warehouse. Keep Divine gate OFF for legacy saves and preserve Injury120 and six-person PvE. Run the two D6 focused tests plus D5, D4-A/B, D3 learning and Save/PvE regressions after import.

D4-B coverage commit `efb26c1288575ab6a0477278f6d71d6e14830bd5`; D5 coverage commit `6f42f2a2fea2799427838c7c3d83bfb3bc6dc5bb`. D5 import + focused D4/D5/D3/Save/PvE tests passed 10/10 on Windows Godot 4.7.2. D2 single-encounter codex reward routing, D6–D8, live P3.2 HUD/VFX, GUI/owner visual review, Android and overall performance remain pending. Do not claim a full playable accepted build until the end-to-end route and visual/device gates pass.
