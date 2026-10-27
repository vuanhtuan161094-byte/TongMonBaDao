# TÔNG MÔN BÁ ĐẠO — AUX-01 SaveService forensic QA (deferred integration)

**Date:** 2026-10-27  
**Baseline:** `feature/pve-jx-continuous-world-20261026` at `6b3fd181392c96c2386e5aa85950d2e993d67dda`  
**Isolated branch:** `qa/pve-save-forensics-20261027`. No changes to production SaveService, SimulationRuntimeOwnerV2, Combat V2, Godot gameplay, `main` or Windows game files.  
**Status:** CODE COMMITTED / GODOT 4.7.2 RUNTIME QA PENDING / ROOT CAUSE UNCONFIRMED.

## Reason for this packet

AUX-01 Issue #41 ran official Windows Godot 4.7.2 at QA code SHA `c26491c1bfdb40deb67cc3e3c7f5cdb4931509af`. Seven focused save/clock/receipt tests passed, including 50 active Save/Return/Reload checks. But `dv2_03_runtime_clock_test.gd` returned `{ok:false, error:1, steps_run:2, pending_minutes:0}` for a call to `SimulationRuntimeOwnerV2.save_to_path(path, 2120)`, despite state having `tick=2`, `runtime_last_wall_unix=2120`, `remainder=0`. This is a **real test failure**, but the available log did not identify the failed save stage.

`SaveService.save_to_path` (1) serializes state, (2) writes and validates `.tmp`, (3) handles corrupt primary and `.bak`, (4) rotates valid primary to backup and (5) renames the staged save into place. Numeric Godot error `FAILED=1` may arise during staged validation *or* be returned by a filesystem operation; the error alone does not attribute the step.

## Specific newly discovered source-level hypothesis — invalid test fixture, NOT proven yet

`dv2_03_runtime_clock_test.gd::_make_state` recruits a generated D7 disciple then performs `disciple.aptitude = 0.0` directly (without any Foundation mutation/quality contract). The generator `DiscipleGeneratorOpenPoints.generate_candidate` creates D7 model 3, immutable `foundation_birth_values` and `disciple_quality`. `FoundationSystem._can_migrate_disciple_to_d7` rechecks exact D7 birth provenance, seven attributes and `disciple.disciple_quality == quality_for_total(total_disciple(disciple))`. `SaveService._load_exact` invokes `FoundationSystem.enable_d7` on P3.7 load, which may reject a mutated candidate if the total crosses a quality threshold. Seed-specific differences between 44421 and 77221 could therefore explain why the old fixture saves and the new owner fixture does not.

**This is only a high-priority hypothesis.** If the mutated candidate remains within the original quality band, validation might still pass. The Godot A/B test below must check actual `foundation_errors`, exact staged read, no-aptitude mutation control, and file rotation before any root-cause assertion.

## What was implemented

`godot/tests/simulation/pve_aux01_save_stage_differential_test.gd` is a read-only-for-game, standalone SceneTree QA script. It uses private `user://qa_pve_save_forensics_20261027/*.json` test files exclusively; does NOT open, overwrite, clean or migrate real player saves.

It covers:

1. Fresh target: seed 77221, owner from t2000 -> t2120, no existing save.
2. Same-seed rotation: old primary seed77221/t2060 and new owner seed77221/t2120.
3. Cross-seed rotation: old primary seed44421/t1060 and owner seed77221/t2120 — exact original owner-save fixture relationship.
4. A/B controls: same fresh and cross-seed cases **without direct aptitude overwrite**.
5. Independent wire probe at the exact target state: file open/write, JSON parse, float64 unwrap, CARE envelope, required payload shape, `SimulationState.from_dict`, `SaveService._load_exact`, source invariant count, Foundation validity count.
6. Negative invalid CARE save with an existing good primary: failed staged validation must leave original primary intact and loadable.
7. Negative missing-parent file path: file-open failure must not invent a save.
8. Same-directory two-stage sentinel rename: distinguishes general Windows rename/ACL problems from validation faults. This does *not* claim the real SaveService rotation is identical.
9. Synthetic P0 lightweight version headers v0–v3 versus deliberately invalid v4-without-CARE and future v99. Versions 0–1 use historical ordinary JSON float wire; v2–v3 use float64 wrappers. This is synthetic migration coverage, not a substitute for genuine archived legacy-save tests.
10. Successful cases require **not just `ok`**, but exact persisted `seed`, `tick`, `runtime_last_wall_unix`, and exactly two canonical simulation steps. Cannot label malformed/misassociated saves PASS.

Output records are one-line JSON under `PVE SAVE FORENSICS CASE:` and `PVE SAVE FORENSICS NEGATIVE:`, without raw game saves or personal data.

## Decision matrix after actual Windows execution

| Observation | Likely explanation / action |
| --- | --- |
| Mutated `foundation_errors > 0`, natural-aptitude controls save and reload, mutated cases fail staged read | **Invalid legacy QA fixture** strongly supported. Fix test fixture through legitimate D7 rules and derive expected XP without direct birth-stat mutation. Do **not** change production SaveService. |
| Fresh, same-seed and cross-seed have `wire_probe.exact_read=false`, but `foundation_errors=0` | Real payload load/migration/validation failure remains; inspect schema, D7 enable and canonical B3 reconciliation with exact seed. |
| `wire_probe.exact_read=true` but `save_error!=0` | Writer/primary-rotation/publish error likely; inspect same-folder rename sentinel, `.bak` states, OS log, antivirus/ACL. Do not skip atomic-save checks. |
| Only cross-seed rotation fails, fresh and same-seed succeed | Investigate existing-primary or backup handling separately from new-state validity; no clock formula change. |
| Invalid CARE stage doesn't fail or overwrites a valid primary | Critical SaveService recovery contract regression; block integration. |
| Any reported success has wrong `seed/tick/wall` | Critical exactly-once/save identity mismatch; block integration. |

## Execution after the owner opens Windows

Launch on an **isolated checkout/worktree** with official Godot 4.7.2. Do not use the owner's active feature worktree while Codex is editing it.

```powershell
E:\Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/simulation/pve_aux01_save_stage_differential_test.gd
```

The script exits **0** only if the differential suite confirms all sampled Save/Load identities and negative fail-closed cases. **Exit 2** means the original fixture failure survives and must be investigated. **Exit 1** means another required safety or schema gate failed. **Exit 3** indicates a previously valid primary may have been changed/lost following an unsuccessful save (or the Windows launcher cannot locate its Godot binary). Preserve exact SHA, engine version, stdout/stderr and Godot engine log.

Suggested official regressions to run only after root-cause resolution: `dv2_03_runtime_clock_test.gd`, `dv2_03_live_runtime_integration_test.gd`, `pve_save_return_reload_exactly_once_test.gd` (AUX-01 isolated test), `safe_01_save_recovery_test.gd`, `gp_02c1_injury_settlement_test.gd`, and P3.2 6v10 Save/Return focused suite.

**Integration: intentionally deferred by owner.** No production-code fix has been authorized merely by a hypothesis; do not weaken validation, bypass D7 integrity, or delete prior saves/backups.
