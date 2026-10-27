# TÔNG MÔN BÁ ĐẠO — Godot 4.7.2

**One game, one official branch.** Chinese cultivation-sect management + Source A sect production + continuous PvE. Android target **landscape 1280×720**. Combat V2, canonical SaveService/clock/Warehouse, One Active Job and Injury 0/1/120 ticks remain gameplay authority.

## Which branch should I use?

| Branch | Meaning |
| --- | --- |
| [`main`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/tree/main) | **The only officially accepted stable baseline.** It is currently behind the PvE candidate, so do not expect the newest playable game here yet. |
| [`feature/pve-jx-continuous-world-20261026`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/tree/feature/pve-jx-continuous-world-20261026) | **The one current PvE release candidate**, with beautiful Source A production, Thanh Trúc Lâm entrance and authentic six-person combat. **NOT YET PLAYABLE-PASS**: SaveService/GUI/FPS gates are open. |
| `recovery/*` | Short-lived isolated Codex bugfix and presentation jobs. **Do not consider these independent game versions.** |
| Historic `docs/*`, `integration/*`, `economy-*`, `c4-*` | Design, experiments and implementation history; not current gameplay authority unless selectively reconciled and verified. |

**Always read [CURRENT_CHECKPOINT.md](./CURRENT_CHECKPOINT.md) for exact SHAs, PASS/FAIL/PENDING gates and recent user decisions.** Read [NEXT_CHAT_HANDOFF.md](./NEXT_CHAT_HANDOFF.md) only for today's handoff, not as another parallel authority. The older long checkpoint and historic P2/P3 commands remain in Git history for audit, not as the active startup guide.

## Run and verify the current PvE candidate (Windows)

1. Use an **isolated clean checkout/worktree** of the PvE candidate; never overwrite a Codex worktree or personal save.
2. Confirm official Godot **4.7.2** and your exact checkout SHA. Do not execute multiple heavy Godot GUIs on the 8 GB development computer.
3. `Run-PVE-Play.cmd`: normal real P3.2 GUI from a synthetic isolated 130-disciple QA seed; click **Săn quái**, select six eligible V2 disciples and test Thanh Trúc Lâm. This is QA/demo mode, not organic player progression.
4. `Run-PVE-FPS-QA.cmd` (logger OFF), then `Run-PVE-FPS-QA.cmd /log` (logger ON) **serially**, using exact-SHA logs to investigate P50/P95/P99, 1%-low and worst spikes. The log filename guard fix is proposed in the separate audit packet until verified/applied.
5. Normal GUI mouse/camera/PvE/Save-Return and Godot official focused tests are still required before calling the game playable. See [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37) and the [Windows one-session QA guide](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/audit/tmb-whole-project-readiness-20261027/docs/operations/TMB_2026-10-27_ONE_SESSION_WINDOWS_EXECUTION.md).

If the launcher cannot find the required game seed, Godot executable or a clean repository, **stop and report the blocker**. Do not run an old `Sync-P2-6.cmd` expecting it to bring PvE code into `main`.

## Gameplay/asset design constraints

- Production: preserve already accepted Source A map and real worker progress/ETA. Do not recreate the renderer or invent an actor animation to simulate harvesting.
- Combat: `MapBattleV2` is authoritative for combat state, hits, HP0 and kills. Renderers and JX #158 VFX are cosmetic consumers only.
- Real PvE: 20-camp world, real groups of six, Save/Restore, respawn registry; spawn slots are not simultaneous active monsters. Per-monster loot is **`LOOT_PENDING`** until owner approves a canonical exact-once transaction.
- Economy, CPV2, equipment, Combat V3 and Boss documents are valuable R&D, not automatically implemented features. Do not silently enable older draft rebalance formulas.
- No destructive asset/branch/save deletion while two Windows Codex recovery sessions work. Cleanups must preserve archival SHAs and check local worktree/PR dependencies.

## Source of truth for development

1. `AGENTS.md` — operating and safety rules.
2. `docs/GAME_SYSTEM_ARCHITECTURE.md` — canonical gameplay architecture.
3. **`CURRENT_CHECKPOINT.md`** — one current status matrix.
4. `NEXT_CHAT_HANDOFF.md` — concise current execution queue.
5. Subsystem master specs + real source code and exact-SHA Godot QA.

**Merge policy:** One reviewed/gated integration candidate becomes `main` only after owner approval; then retire temp branches, keeping historical evidence reachable by commit/tag rather than parallel long-lived game versions.
