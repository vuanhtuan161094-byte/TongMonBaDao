# CURRENT CHECKPOINT — TÔNG MÔN BÁ ĐẠO

**Owner-approved organization goal (2026-10-27): one official game, no parallel competing version authorities.** This is the single current-status page. Git history, designs and prior PRs remain evidence, not alternative "latest game" claims.

## Which version is THE game?

| Role | Branch at this audit | Status / authority |
| --- | --- | --- |
| **Official stable game (protected)** | `main` @ `29b5fba448b0178cb520a4ada44b375b4b934e31` | GitHub default. **Only merged/accepted baseline**; NOT the newest PvE. Contains official Economy-A and six repo skills (#1 and #23). Never change branch default or update without accepted gated integration. |
| **ONE current next-game candidate** | `feature/pve-jx-continuous-world-20261026` @ `6b3fd181392c96c2386e5aa85950d2e993d67dda` | Latest audited running PvE code, 137 commits ahead of main / 0 behind at audit. **PLAYABLE_BLOCKED pending GUI and SaveService QA**, not certified as release or as all historical functionality. |
| Temporary core repair worktree | `recovery/pve-core-a1-20261027` (Codex 1 assignment) | Future/in-progress only; never assume remote branch/commit exists until verified. Owns SaveService, C17 movement, 6-actor formation, 20-zone and Injury120 tests. |
| Temporary visual/GUI worktree | `recovery/pve-playable-visual-a1-20261027` (Codex 2 assignment) | Future/in-progress only; verify remote. Owns Source A/JX #158 VFX, P3.2 presentation/GUI, FPS tools. |
| Docs handoff packet | Draft [#49](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/49), `docs/tmb-two-codex-recovery-20261027` | Documentation and governance only. Not gameplay code or a new version. |

**No separate `develop`, second integration mainline, automatic newest-by-branch-name rule, or automatic 39/40-PR merge.** When the combined PvE candidate passes official Godot 4.7.2 and owner approves, merge it **once into `main`**, tag a reproducible checkpoint, retire the temporary feature/recovery branches after checking local Windows worktrees; `main` then becomes the sole official gameplay target again.

## Gameplay and asset truth in the ONE PvE candidate

- Engine **Godot 4.7.2**; target Android landscape **1280×720** (desktop GUI tests do not certify Android).
- Source A presentation art and original production map retained. The visible PvE entry is **Săn quái / Thanh Trúc Lâm** with a six-member authentic V2 selector.
- Active canonical simulation: Combat V2 (no second combat authority), one scheduler/time clock, Warehouse, SaveService, One Active Job; Injury 0/1 with auto-return and **120 scheduler ticks**. UI/VFX are visual consumers, not reward or damage sources.
- World/PvE: authored 192×192 map and 20 camps. The 200–400 spawn registry *slots* are NOT 200–400 simultaneous active actors. `MapBattleV2` caps 30 disciples / 40 monsters. No new per-monster loot contract is approved; **`LOOT_PENDING`** remains intentional.
- Codex gameplay/test SHA `7c79a7740938e4a5852234fa3826850db902b167`: previous official Windows headless focused tests reported six real disciples vs ten monsters, 79 simulation seconds, 153 combat actions, nine kills and active Save/Load. This run **did not** prove 20-zone hop, Injury120 in that encounter, physical mouse, normal-GUI FPS or Save/Return acceptance. Feature handoff HEAD `6b3fd181...` only updated status after that test.
- Historical UI/Combat V3, Economy-V2, CPV2, Forge, B3 and Boss/Công Pháp design branches are **research/proposals unless proven in the current gameplay source and verified by exact-SHA QA**. Do not turn proposed production ×100 or combat skill/loot tables on just because a draft branch exists.

## Today's RED/PENDING gates (do not overwrite with older PASS)

| Gate | Status as of this audit | Authoritative work packet |
| --- | --- | --- |
| Runtime-owner SaveService | **FAIL in AUX-01 Godot 4.7.2**: owner reached tick 2 / wall 2120, but save returned `FAILED=1`. Cause not yet proven. | AUX-01 #41 / Draft #45; proposed staged/D7 A/B diagnostic Draft #48; **Codex 1** to verify/fix |
| C17 move-final / six-person destination uniqueness | **Two AUX-02 findings**: same-cell gap 0.494 > 0.45; 6 low-level destinations collapsed to 3. P3.2 independent slot handler did pass 6/6; actual physical mouse still pending. | AUX-02 #42; draft fixes #46, #47 **Godot QA pending**; **Codex 1** |
| 20-camp zone-hop / Injury120 full-run | **PENDING / fixture mismatch**, AUX-02 forced-movement full fixture ended defeat C01 with 0 kills and `injury_valid=true`. Standalone GP-02C1 Injury120 PASS on old QA SHA, not current integration. | **Codex 1** |
| JX #158 / Source A VFX | **ASSET PROVENANCE PARTIALLY VERIFIED**: sheets 10+17+8=35 valid source rects/anchors. Unity prefab/skill/pivot binding remains unverified; AUX-03 Godot event/reload test not run. | #43 / Draft #44; **Codex 2** |
| GUI, FPS, controls | **PLAYABLE_BLOCKED**: Codex GUI screenshot API timed out; 15s Sect + 30–60s PvE + Save/Return with real mouse, FPS P50/P95/P99 and 1%-low, logger OFF/ON not yet evidenced. | #37; **Codex 2** |

### Dedicated evidence/coordination

- [Issue #37 — single PvE execution scoreboard](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37).
- [Two-Codex owner/worktree/engine matrix](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/tmb-two-codex-recovery-20261027/docs/operations/TMB_TWO_CODEX_COORDINATION_2026-10-27.md).
- [Codex 1 Core assignment](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/tmb-two-codex-recovery-20261027/docs/operations/TMB_CODEX1_CORE_RECOVERY_EXECUTION_2026-10-27.md).
- [Codex 2 Visual assignment](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/tmb-two-codex-recovery-20261027/docs/operations/TMB_CODEX2_PLAYABLE_VISUAL_FPS_EXECUTION_2026-10-27.md).
- [Whole-project review](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/audit/tmb-whole-project-readiness-20261027/docs/operations/TMB_WHOLE_PROJECT_AUDIT_2026-10-27.md).
- [Full 166-branch inventory / retirement candidate register](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/audit/tmb-whole-project-readiness-20261027/docs/operations/TMB_GITHUB_BRANCH_CONSOLIDATION_REGISTER_2026-10-27.md).

## Branch retirement: what happens and what is forbidden

As of the audit: **166 remote branches, 40 open Draft PRs, 2 merged PRs**. Many old branches already appear in the current PvE ancestry: PR #24, #26, #27, #31, #33, #38, #39 head SHAs are ancestors. The historical Economy-V2 PR #9 and PvE-presentation PR #34 **diverge** from the current feature. Ancestor relation alone doesn't prove UI/economics acceptance or lack of reverts.

**Stage 1:** After both recovery Codex reports, create ONE read-only final matrix of current code, independent contracts, PR changes and exact-runtime evidence; reconcile divergent designs and preserved tests/asset rights, without mass merging.

**Stage 2:** Fix only demonstrated gates in temporary, reviewed worktrees, run Windows Godot 4.7.2 on the **combined exact SHA**, then request owner approval before the final `main` integration. No game version is "official" from a draft or headless-only GUI test.

**Stage 3:** Archive meaningful docs and evidence with SHA links, **close proven superseded PRs** with an explicit replacement pointer, and retire branches in small owner-approved batches after checking `git worktree list`, PR head/base dependencies, unique commits and Source A provenance. Never delete branches solely because names are old, or clean E: game-related masters, save/backup or testing evidence without preservation.

**Target operational state:** one stable mainline, no standing develop branch, at most 2–4 short-lived work branches at a time; release tags instead of permanent parallel versions. Actual branch count may temporarily exceed that while archiving.

## Old status history (preserved, not a second authority)

The previous multi-month chronological checkpoint is preserved in Git at exact audited feature commit:
- [Legacy CURRENT_CHECKPOINT (6b3fd18)](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/6b3fd181392c96c2386e5aa85950d2e993d67dda/CURRENT_CHECKPOINT.md).
- [Legacy NEXT_CHAT_HANDOFF (6b3fd18)](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/6b3fd181392c96c2386e5aa85950d2e993d67dda/NEXT_CHAT_HANDOFF.md).
- [Earlier PR #35 cleanup proposal](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/35), dated 25 October, superseded as live-status authority by this 27 October packet but retained as document history.

**This file is a docs candidate in Draft PR #49**, not merged into active Codex feature or `main`. When either Codex produces a new tested commit, UPDATE this status with exact SHA and its evidence after review. Do not change the simulated rules to fit status prose.
