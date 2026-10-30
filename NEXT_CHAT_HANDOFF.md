# NEXT CHAT HANDOFF — ONE GAME V6.5 INTEGRATION

Continue from `integration/one-game-v65-20261030`. Fetch GitHub first; gameplay code through R3 was last tested at `f18e4d6419f9ac43cf4a9fac119a415cb4f0c40d`. A documentation-only checkpoint may sit on top; always use the live branch SHA.

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

Proceed to R4 / D4-A on the same branch. Before touching shared runtime files, compare live integration HEAD with PR #52 and review Issue #54's per-file matrix. Graft the smallest Human combat slice into the existing Combat V2 authority, keeping the gate OFF for legacy saves. Preserve Injury120, six-person parties, receipts, one Warehouse, active jobs, SaveService async/backups and RC recovery. Use source-authorized VFX only.

After each package: exact allowlist and rollback, Godot import, focused tests, affected regressions, then commit/push by compare-and-swap and update Issue #56. Do not open the broad 46-test matrix for a small packet. Human GUI, Android, Source A visual review and performance remain PENDING until actually exercised.
