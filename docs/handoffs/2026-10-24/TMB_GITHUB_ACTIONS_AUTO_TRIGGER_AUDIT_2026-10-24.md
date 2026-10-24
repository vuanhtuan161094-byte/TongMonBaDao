# TMB — GitHub Actions Auto-Trigger & Failure Triage
Audit: 2026-10-24 (Asia/Bangkok) | Scope: PR28, PR29, S1 fix | Status: DOCS ONLY.

## Key conclusion

GitHub Actions WERE auto-triggered by PUSH on feature branches, even though Codex was asked not to manually run FULL/CI. A Codex instruction cannot override existing GitHub Actions event configuration.

- "Codex did not deliberately run FULL/CI" can be true.
- "No CI run was triggered" is inaccurate on sampled commits.
- At least some auto runs show FAILURE, but actual Godot/test failure remains **UNCONFIRMED**. Keep local official Godot 21/21 PASS evidence and remote FAIL evidence separate.
- No workflows or settings have been modified in this coordination.

## 1. Exact direct evidence

| Branch / SHA | Workflow | GitHub run | Result |
| --- | --- | --- | --- |
| PR28 code 47b704270ae165504aeef526963e8d03f87bc579 | P3 O3 Real Mine Loop | https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/40060704374 | push 2026-10-24T04:01:46Z; completed FAILURE by 04:01:48Z |
| PR28 same code | GP-02C1 Injury Terminal Settlement | https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/40060704379 | FAILURE |
| S1 fix code 511b635c3224357b2892dfa48bcfbfdba1eabac7 | DV2-02 Combat Stats | https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/40061773747 | push 04:17:43Z; completed FAILURE by 04:17:46Z |
| S1 fix same code | P3.7 Backend | https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/40061773846 | FAILURE |

First-page metadata returned failing job records, but useful step details were not exposed. Attempting to download decoded job logs through the connected GitHub tool yielded BlobNotFound/404. ROOT CAUSE IS UNKNOWN. Two- or three-second runs suggest very early failure but do not prove runner provisioning, Godot download, YAML or game-code defect. Similar historical failures occurred on other branches, including main.

## 2. Auto-trigger diagnosis from existing workflow source

- .github/workflows/p3-o3-real-mine-loop.yml: on.push.paths watches godot/src/presentation/p3_2_landscape_sect.gd, which PR28 modified at 47b70427.
- .github/workflows/gp-02c1-injury-settlement.yml: on.push.paths also watches that P3.2 UI source, even though no Injury business logic changed.
- .github/workflows/p3-7a1-building-backend.yml: watches both map_battle_v2.gd and p3_2_landscape_sect.gd; therefore UI and Combat can cause broad backend job fanout.
- .github/workflows/dv2-02-combat-stats.yml: watches map_battle_v2.gd, map_battle_snapshot_v2.gd, and disciple_combat_loadout_v2.gd, which S1 changes.
- .github/workflows/safe-data-integrity.yml: a save/warehouse/runtime-triggered job also includes the FULL cumulative backend script when relevant files change.
- .github/workflows/p3-o9-m2-production-rehearsal.yml: narrow push paths, mostly its dedicated tests/workflow.
- .github/workflows/p3-presentation-audit.yml: watches docs/P3_*.md, docs/decisions/**, source_art/**, registry and validator; does NOT watch arbitrary docs/handoffs/**.

Inspected the workflow YAML inventory (25 workflow definitions). Existing push-based workflow definitions use path filters without a push BRANCH allowlist, with p0-gate using a different trigger. Thus branch restriction is the main verified reason for the *fanout*; path filtering is not evidence for the cause of FAILURE.

## 3. Required CI triage protocol

1. Capture exact SHA + branch + UTC event time; list workflow runs for SHA, not only combined status checks.
2. Inspect jobs/steps/logs/artifacts where accessible. If inaccessible, record LOGS_UNAVAILABLE (never invent a Godot error).
3. Classify as CI_TRIGGER_ONLY, CI_ENVIRONMENT_FAIL, CI_GODOT_CODE_FAIL, CI_CONFIG_FAIL, or CI_UNKNOWN. Assign last four only with appropriate proof.
4. Reconcile separately with official local Godot exact-SHA suite. Local PASS is not remote CI PASS; remote UNKNOWN is not automatically a local gameplay FAIL.
5. Keep all red history and original test assertions. Do not edit code, workflow, or test merely to make red indicators disappear.
6. The integration QA packet may label FOCUSED_LOCAL_PASS and CI_UNKNOWN separately; final release gate requires a new owner instruction.

## 4. Proposed workflow ownership change — NOT AUTHORIZED YET

- Gate push triggers to main / approved integration or release branches after explicit owner approval; keep manually requested workflow_dispatch, or PR-scoped workflows where useful. Do NOT blindly shut off safety checks.
- Tighten overly broad paths when jobs are not actually related; separate focused tests from full cumulative suite.
- Before any workflow edit, investigate one sampled run using the GitHub web UI for Actions error annotation or accessible runner logs, then reproduce one bounded smoke test.
- No .github/workflows changes, no workflow cancellations, no repo settings updates in this docs-only task.

## 5. Status ledger

TRIGGER_FANOUT: VERIFIED. FAILURE_CAUSE: CI_UNKNOWN. GODOT_LOCAL_QA_PR28: reported 21/21 PASS on exact SHA from owner/PR28 evidence. WORKFLOW_EDIT: NOT_AUTHORIZED. NEW_CI_TEST: NOT_RUN. NEXT STEP: exact-SHA S1 focused QA, then planned isolated integration.
