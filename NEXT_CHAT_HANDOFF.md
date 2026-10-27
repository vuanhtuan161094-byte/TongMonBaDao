# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

**Updated: 27/10/2026. Only one official game/version at a time.**

## Start here, not in old branch handoffs

1. Read `AGENTS.md` + `docs/GAME_SYSTEM_ARCHITECTURE.md` for **game authority**.
2. Read [CURRENT_CHECKPOINT.md](./CURRENT_CHECKPOINT.md) for **the only live status, exact SHA and today's RED/PENDING gates**. Its linked historical pages are archives, NOT second authorities.
3. Check live GitHub `main`, `feature/pve-jx-continuous-world-20261026`, Issue [#37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37) and Codex recovery candidates before changing code. No historical branch name automatically means latest.

## Single-game branch model

- `main`: sole official stable branch. At the audit, it did NOT contain the current PvE candidate.
- `feature/pve-jx-continuous-world-20261026`: ONE next-game candidate pending SaveService, movement, GUI/FPS gates. It is not a stable release.
- `recovery/pve-core-a1-20261027` and `recovery/pve-playable-visual-a1-20261027`: two temporary separate Codex worktrees, **only if live branches have been created**. Their status needs actual commit/QA evidence.
- All older `integration/*`, `feature/*`, `docs/*`, `economy-*`, `c4-*` are source/archival references, not alternative running games, until selectively reconciled by exact SHA.
- **No new permanent `develop` branch.** After full real Godot 4.7.2 and owner acceptance, compose reviewed PvE code once into `main`, tag release and retire temporary branches only after confirming no worktree or PR depends on them.

## Two currently assigned Codex jobs

**Codex 1 — Core**: [full contract](./docs/operations/TMB_CODEX1_CORE_RECOVERY_EXECUTION_2026-10-27.md) — AUX-01 clock-owner SaveService failure and valid D7 fixture investigation, AUX-02 C17 + formation, controlled 20-camp hop, Injury120 and exactly-once. Only simulation/own QA files. Godot slot FIRST.

**Codex 2 — Visual**: [full contract](./docs/operations/TMB_CODEX2_PLAYABLE_VISUAL_FPS_EXECUTION_2026-10-27.md) — AUX-03 Source A/JX #158 event/reload, 1280×720 PvE GUI, real mouse and logger OFF/ON FPS, readable UI, no renderer rebuild. Only presentation/own QA files. Wait until Codex 1 posts `CODEX1_GODOT_QA_RELEASE` to Issue #37 before new engine run.

[Coordination, file ownership and shared Windows 8GB process rules](./docs/operations/TMB_TWO_CODEX_COORDINATION_2026-10-27.md).

## Acceptance — no historical PASS reuse

**Current red:** owner SaveService `FAILED=1` after two correct clock ticks; C17 within-cell stall; low-level six-person formation duplicate slots. Proposed Draft PRs #46/#47/#48 have NOT passed Godot QA.

**Pending:** 20-camp zone transition, full-run Injury120, GUI/mouse, 15s Sect/30–60s PvE/Save-Return, exact FPS P95/P99/1%low, real screenshots, AUX-03 runtime cast/projectile/impact no replay, Android device.

**Previously achieved** (not a current release PASS): 6v10, 79 simulated seconds, nine kills, shared-clock Save/Load at `7c79a77`; previous targeted Injury120 PASS and AUX-01 50 checks PASS on their own prior SHA. Loot remains intentionally `LOOT_PENDING`.

## Latest user direction

**Unify project, stop parallel game versions and gradually retire old branches/docs.** Preserve unique designs, asset provenance and historic QA; do not blindly merge all 40 draft PRs, edit `main`, delete remote branches or clean E: data while the two Codex sessions run. Exact 166-branch retirement register is on the [independent audit branch](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/audit/tmb-whole-project-readiness-20261027/docs/operations/TMB_GITHUB_BRANCH_CONSOLIDATION_REGISTER_2026-10-27.md).

**Current docs packet:** [Draft PR #49](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/49), a proposal against the PvE feature only. This file and CURRENT_CHECKPOINT are not merged to `main` and do not alter Windows worktrees.

## Important: archived old handoff

Previous long handoff remains recoverable at [`6b3fd18` exact commit](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/6b3fd181392c96c2386e5aa85950d2e993d67dda/NEXT_CHAT_HANDOFF.md). Do not resurrect outdated P2.1/PR32-first directives from history as current priorities.
