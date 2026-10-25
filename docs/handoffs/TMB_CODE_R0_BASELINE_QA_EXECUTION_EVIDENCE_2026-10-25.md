# TÔNG MÔN BÁ ĐẠO — CODE-R0 QA BASELINE: EXECUTION, STATIC AUDIT, CI BLOCKER

**Date:** 2026-10-25. **User-authorized R0 only**: audit all-extension finite/continuous references, focused Godot 4.7.2, fix only reproducible defects in parent CODE-CLEAN allowlist, preserve V2 Injury120 and Save/Warehouse, NO PR28/29/31 changes or merge. **Verdict:** **R0 INFRA BLOCKED, QA NOT PASS, NO GAMEPLAY CODE MODIFIED.**

## 1. Provenance: exact refs
- Original code baseline: `code/code-clean-finite-reward-20261025` @ **`5fbdbc6309c3f1386f0d8b619831e007c5a52824`**. This inherits PR #31 @ `9eb4fd55733bb49bbb069240b8e332d37d22aced`; not main.
- New isolated QA/code branch: `qa/code-r0-finite-world-20261025`, created from **exact** original code SHA above.
- R0-only added files: `.github/workflows/code-r0-finite-world-gate.yml` (CI workflow, commit `a9f1dcad9c713d8cfecedeef8513d0bf51afd39b`); `tools/qa/Invoke-CodeR0-Focused.ps1` (local Windows/code agent runner, commit `8cfd5da766f92a3462995f100a812cb3a37d6600`); THIS EVIDENCE MD. Zero game simulation/src/test changes in the R0 branch at the time of this report, no merge.
- Docs inputs read from `docs/combat-finite-retirement-full-caller-save-migration-20261025`: exhaustive GDScript/scene caller audit, exact old-save/entitlement migration matrix S00–S15 and phased retirement implementation packet. R0 is **not authorization** for R1–R6.

## 2. Exhaustive tracked-source-text matching, with honest execution distinction
- GitHub REST `GET /git/trees/{baseline_sha}?recursive=1` listed **999 entries, truncated=false** at the fixed baseline.
- Connector programmatic per-file content search completed on:
  * **273/273 `.gd`** (from the preceding same-SHA CODE-CLEAN B exhaustive audit);
  * **43/43 `.tscn/.tres`** (same-SHA prior audit);
  * **272/272 `.ps1/.cmd/.py/.yml/.yaml/.json/.md`** (this R0 turn, fetched each file and inspected its literal lines, batches 0–272; no tool errors).
  * TOTAL covered **588/588 source-text files** for the exact extension allowlist, all from same immutable parent SHA. Nontext assets, binary ZIP, WebP, log files and file extensions outside allowlist were not searched and are not live code callsites by this audit.
- Search alternations: `MAX_SECONDS|LEGACY_FINITE_MAX_SECONDS|MAX_REALTIME_SECONDS|timeout_retreat|HuntingPveRunV2|HuntingMapV2|claim_reward|v2_pve_active_runs|v2_pve_reward_claims|v2_pve_settlement_receipts|active_pve_encounter_id|MapBattleSnapshotV2|MapBattleV2|CombatSystem|resolve_encounter`. Literal per-file grep equivalent: NOT equivalent to native `git grep` execution provenance or shell-generated all-match artifact, and cannot detect dynamic dispatch.
- Non-GDScript matches include history/plans (`CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/DV2_02_*;` `docs/DV2_03F_*`, etc.), the parent CODE-CLEAN report, and **one VFX manifest JSON**; these are **not** additional production calls and must never be deleted as an “obsolete caller” simply because they mention the old name.
- Exact live callers still found at baseline:
  * `godot/src/simulation/core/simulation_scheduler.gd:164` -> `CombatSystem.resolve_encounter` (legacy 20 rounds or 45s when `combat_skills_enabled`);
  * `godot/src/simulation/combat/map_battle_v2.gd:11,13,217–218,226` finite **90s** condition explicitly only `not continuous_mode`;
  * `godot/src/simulation/combat/hunting_pve_run_v2.gd` whole encounter lifecycle, `HuntingMapV2.claim_reward`, saved v1 finite resurrection/settlement;
  * `godot/src/simulation/combat/b3_hunt_world.gd` persistent true `continuous_mode`, HP0 kill receipt, Warehouse save barrier;
  * `godot/src/simulation/state/simulation_state.gd:417` mandatory old finite `reconcile_loaded_v2_pve` on load; `sect_state.gd` persists old claims, receipts and B3 separately;
  * `godot/src/simulation/cultivation/disciple_body_gate_transaction_v2.gd:17` consumes `HuntingMapV2.early_body_sources_ready`: removal before material source parity is a **progression softlock risk**.
- Those source observations justify **no further R0 gameplay edits**. Existing CODE-CLEAN cross-mode isolation patch remains *unverified* by Godot and cannot be called green merely because the guard looks correct.

## 3. Native `git grep` and Godot QA were attempted via GitHub Actions, NOT EXECUTED
- GitHub Actions workflow `.github/workflows/code-r0-finite-world-gate.yml` created; jobs configured:
  1. `R0 git grep tracked files and SHA` runs native `git grep -n -E` over exact extension list and uploads raw lines.
  2. `R0 official Godot 4.7.2 focused simulation suite` verifies download SHA256 from repository's preexisting official Godot 4.7.2 CI lock, parses project, runs **21** focused tests independently and stores stdout/stderr and exit codes.
- Run #1: [40163016429](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/40163016429), workflow code SHA `a9f1dcad9c713d8cfecedeef8513d0bf51afd39b`, conclusion `failure`.
  * Git grep job `121078339199`; Godot suite job `121078338086`; both `completed/failure`.
  * `fetch_workflow_job_steps` returned **[]** and GitHub job logs endpoint returned **404 BlobNotFound** on both. **No proof of Checkout/start, grep process or Godot invocation.**
- Run #2: [40163116780](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/40163116780), workflow + Windows runner SHA `8cfd5da766f92a3462995f100a812cb3a37d6600`, conclusion `failure`.
  * Git grep job `121078627407`; Godot suite job `121078627361`; again **0 reported job steps**, logs returned **404 BlobNotFound**.
- Earlier CODE-CLEAN workflows had the same `failure` and missing step metadata, e.g. [40160260276](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/40160260276). This is a **pre-step or job-provisioning class blocker by observation**; the exact underlying GitHub Actions cause is UNKNOWN. Do not claim billing, quota, permission or Godot binary hash is the cause without logs/admin evidence.
- In the current execution container, `command -v godot`, `command -v godot4`, system path search found **no Godot executable**; `git ls-remote` for repo failed `Could not resolve host: github.com`. Direct local clone/official Godot headless regression therefore **NOT POSSIBLE HERE**; no local test was run.
- Consequently **native `git grep` has not executed**, despite equivalent fixed-SHA content scan completion; **0/21 official Godot tests executed** on this R0 branch. Neither is a gameplay QA fail or pass. Only github CI job `failure` is proven.

## 4. Reproducible QA execution once environment available
Windows/Codex from checkout of exact R0 branch, official engine **Godot 4.7.2**:
```powershell
git switch qa/code-r0-finite-world-20261025
git rev-parse HEAD
pwsh -NoProfile -File tools/qa/Invoke-CodeR0-Focused.ps1 -GodotBin "E:\\Tools\\Godot_v4.7.2-stable_win64_console.exe"
```
Path shown is a **placeholder**; use the actual verified 4.7.2 binary path. Runner refuses wrong Godot version, verifies CODE-CLEAN ancestor, captures exact SHA/branch and tracked paths, runs native `git grep` over all ten extension patterns, imports project, runs **21 named real headless tests**, writes `test-exit-codes.csv`, individual stdout/stderr and `summary.txt` under `artifacts/qa/code_r0/<timestamp>/`. A grep-only pass is available with `-GrepOnly` but cannot substitute for the Godot matrix.

Existing CI workflow is configured to upload raw logs and grep matching lines as separate artifacts *if jobs actually start*. No evidence artifact exists from failed zero-step jobs as of this report. **Do not copy or invent log paths and claim runs happened.**

Manual checks after matrix returns PASS:
1. Confirm World continuous reaches 120s and >3600s without 45s/90s timeouts, with genuine per-life kills and persistent slot generation/paid receipt;
2. Confirm finite legacy 90s still has deterministic bounded contract while supported old saves exist; old winning run saves/reloads and claims only once;
3. Canonical HP V2 damage/status math untouched, Injury0/1+120 tick, wounded auto-return and quarantine from new work;
4. `linh_tuy` early Body four-win guarantee and necessary materials remain earned from real accepted PvE; no R1–R6 gate softlock;
5. Warehouse/Save torn-write and backup fail closed; cross-mode forged claim fails with no stock delta.

## 5. R0 focused QA matrix (21 tests, all PENDING)
```text
combat_finite_world_reward_isolation_test
b3_ph0_continuous_kernel_test
b3_fasttrack_hunt_test
b3_care_pills_autohunt_test
combat_v3_s1_edge_contract_test
combat_v3_s1_effects_test
dv2_02_combat_stats_test
dv2_02_group_map_battle_test
dv2_02_battle_snapshot_test
dv2_02_five_level_pve_test
dv2_02_five_level_balance_test
gp_02c1_injury_settlement_test
dv2_03_f0_source_baseline_test
dv2_03_f1_body_gate_manifest_test
dv2_03_f2_body_gate_transaction_test
dv2_03_f3_body_material_earned_claim_test
dv2_03_f6_real_earned_body_gate_integration_test
p2_5_combat_skill_test
p2_6_equipment_combat_effects_test
safe_01_save_recovery_test
safe_02_warehouse_migration_test
```
**Important distinction:** 21 cases listed/configured, **zero executed**; running a workflow that fails before recording steps is not running a test. Need official runtime proof before release.

## 6. Scoped conclusion & pending owner action
- **DONE**: branch forked at correct SHA; exhaustive fixed-SHA source-text callsite equivalence across requested extensions, provenance records; independent GH Actions QA workflow committed; local Windows/agent PowerShell runner committed; CI attempted twice; observed CI pre-step failure and logs endpoint failure.
- **NOT DONE / BLOCKED**: actual git grep process, official Godot 4.7.2 and full cumulative pass, reliable root-cause analysis of GH Actions no-runner/zero-step job, Windows and Android QA.
- **NOT AUTHORIZED YET**: R1 source registry, R2 scheduler cutover, R3–R5 finite removal, PR/main merge.
- **No gameplay fix without reproducible failing source/test**: user mandated “only fix evidence-backed R0 failures.” Zero-step CI failure is NOT a valid reason to edit MapBattle gameplay tests or invent a PASS. No src code modified on this QA branch.
- Next permissible action is **recover a working official Godot 4.7.2 execution environment/runner** and run QA; if a focused test fails, quote exact file/test assertion/raw log and fix within existing CODE-CLEAN allowlist only.
