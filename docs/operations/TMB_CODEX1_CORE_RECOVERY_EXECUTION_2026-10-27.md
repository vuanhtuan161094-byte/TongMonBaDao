# CODEX 1 — CORE RECOVERY: SAVE / MOVEMENT / ZONE / INJURY (2026-10-27)

**Mission mode: CODE + ROOT-CAUSE QA + INTEGRATION CANDIDATE, NOT MAIN MERGE.** Owner wants remaining work completed on Windows Godot 4.7.2 in two separate Codex sessions. This session is **SOLE WRITER** for SaveService investigation and PvE simulation movement/transition tests. **CODEX 2** exclusively owns GUI, P3.2 renderer, Source A/JX VFX and FPS tools; never edit those files.

## Initial exact evidence — revalidate before touching files

Repository `vuanhtuan161094-byte/TongMonBaDao`. Audit snapshot 2026-10-27:
- `main`: `29b5fba448b0178cb520a4ada44b375b4b934e31`;
- active PvE feature `feature/pve-jx-continuous-world-20261026`: `6b3fd181392c96c2386e5aa85950d2e993d67dda`;
- AUX-01: Draft [PR #45](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/45), `0a69ac951c0ea80c13b50e16855a61d3f4a9ba4f`, historical official Windows QA code `c26491c1bfdb40deb67cc3e3c7f5cdb4931509af`;
- AUX-02: branch `qa/pve-aux02-world-input-contract-20261027` `32545b31262b11d5fb30510790765245c9d70c1b` (exact test `godot/tests/presentation/pve_aux02_world_input_contract_test.gd`);
- C17 proposal: Draft [PR #46](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/46) `49db887a7785a3111278d1bb992037e8884b5861`;
- unique six-person formation proposal: Draft [PR #47](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/47) `528f6914261cd4b7725fd972dc39226e33954d50`;
- owner-save A/B forensic: Draft [PR #48](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/48) `5915fca17b8e23b3afb597f1f379c4d2d60cecbb`.

Check remote again; old SHAs above are **baselines, not assumptions about latest HEAD**. Read `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md` newest block, `docs/operations/TMB_WHOLE_PROJECT_AUDIT_2026-10-27.md` and `docs/operations/TMB_PVE_AUX01_SAVE_FORENSICS_2026-10-27.md` from their respective audit/PR branches, plus Issue #37, #41, #42 and all PR diffs. Audit docs may not exist in current feature branch, fetch them from `audit/tmb-whole-project-readiness-20261027`.

## Worktree & scope: never race another session

1. Inventory `git status --porcelain=v1`, `git worktree list --porcelain`, remote branches, Godot binary `--version`; identify and preserve **every** existing dirty/untracked file. Do not run `git clean`, `reset --hard`, force push, `git gc` or delete E: masters/saves. Start own new worktree from **latest** PvE feature, branch `recovery/pve-core-a1-20261027` (or a new timestamp suffix if taken). Do not checkout/rebase the active Codex PvE worktree.
2. **Exclusive writable production paths:** `godot/src/simulation/save/save_service.gd` (only if proven SaveService bug); `godot/src/simulation/combat/map_battle_v2.gd` (navigation / party-slot commands ONLY); `godot/src/simulation/combat/hunting_pve_run_v2.gd` (world transition only if an actual reproducible issue exists); bounded related *new* simulation QA fixtures and `godot/tests/presentation/pve_aux02_world_input_contract_test.gd` for imported QA. Scope is the demonstrated defect, not gameplay redesign. Disallowed: `simulation_runtime_owner_v2.gd`, Combat damage/AI/RNG, HP rules, Injury 0/1/120 contract, loot/economy/Forge/warehouse payouts, all Source A/JX renderer/atlas/UI, `godot/src/presentation/p3_2_landscape_sect.gd`, Codex 2's test files, `main`.
3. **QA engine ownership:** on 8GB Windows, CODEX 1 runs Godot QA FIRST, while CODEX 2 does static/asset work only. Publish `CODEX1_GODOT_QA_START SHA=...` to Issue #37 before executing; publish `CODEX1_GODOT_QA_RELEASE status=PASS/FAIL/BLOCKED...` after stopping all your Godot test processes. Don't terminate someone else's Godot instances; if nine old Godot processes persist, document ownership and BLOCKED, do not spawn another. CODEX 2 may start its engine work only after the release comment and after checking no foreign GUI processes.
4. Only your owned worktree gets commits/pushes. No staging CRLF-only leftovers from another tree. Do not merge PRs directly into feature/`main`.

## Execution work packets — follow this order

### A1 / SaveService first (blocker, data integrity)

Re-run baseline `godot/tests/simulation/dv2_03_runtime_clock_test.gd` on official Godot 4.7.2 and on the core recovery candidate. Historical failure is specific: owner advances from wall 2000 to 2120, two ticks, `save_to_path` => `{ok:false,error:1,steps_run:2}`. Prior successful AUX-01 tests: 50 Save/Return/Reload, identity, GP-02C1, HP0, population idempotency, two live-runtime runs.

Port the exact QA logic from PR #48, do not blindly merge an older branch. Run `Run-PVE-Save-Forensics.cmd` and inspect A/B: generated D7 candidate with original aptitude vs direct `disciple.aptitude=0`, `foundation_errors`, stage JSON/float64, CARE envelope, `_load_exact`, same-seed/cross-seed backup rotation, unsupported migration and OS file errors. **Root-cause hypothesis only** until a failing test proves which layer. If the culprit is an invalid **test fixture**, correct the fixture preserving D7 rules and actual intent, add a regression on natural D7, leave production `SaveService` untouched. If it truly is `SaveService`, apply minimal, atomic, fail-closed fix **only** within allowed file and protect last-good `.bak`; demonstrate corrupted-input rejection, old valid primary unchanged after failure and exact post-save seed/tick/wall identity. If outside allowed files, stop that subpacket and report FILE_OWNERSHIP_BLOCKED.

Required: original runtime-clock, A/B forensic, `safe_01_save_recovery_test.gd`, `dv2_03_live_runtime_integration_test.gd`, `gp_02c1_injury_settlement_test.gd`, AUX-01 `pve_save_return_reload_exactly_once_test.gd` on exact candidate SHA. Failed log remains red in evidence; don't suppress errors, weaken validation or rewrite player saves. Separate real-world clock/wall progression from mock owner tests.

### A2 / Movement, exact C17 and six-slot atomicity

Review patches and tests from PR #46 and #47, both touching **the same `MapBattleV2` file**. Apply only proven compatible hunks **together** on your isolated branch. Verify:
- C17 same-cell condition: current actor approx `(96.35806,168.0268)` and goal `(96.5,168.5)`, separation `0.494` exceeds stop threshold `0.45` although BFS path [] for the same grid cell. Correct bounded within-cell final motion without allowing blocked cells or modified Combat V2 semantics.
- Low-level `order_group_move` with six disciples near blocked target `(92,68)` had only 3 unique destinations; enforce deterministic, distinct, walkable, all-or-nothing reservation. The **production P3.2 handler already yielded 6 unique goals**; this is a low-level contract defect, do not claim physical mouse failure from injected signals.
- On exact candidate commit run `pve_same_cell_move_c17_regression_test.gd`, `pve_group_move_unique_formation_test.gd` and imported `pve_aux02_world_input_contract_test.gd`. Include camera/minimap coordinate parity tests without changing CODEX 2's presentation implementation. Test held orders surviving Save/Restore, formation determinism, no disappearing squad and no illegal geometry.

### A3 / Full PvE 20-camp & Injury120 integration

**Do not classify AUX-02's forced-movement C01 defeat (`kills=0`) as a zone-hop defect without equivalence control.** Baseline Codex had 79s / 9 actual kills in a 6v10 combat sequence but did NOT reach full zone-hop/Injury120. Set up two explicitly different reproducible scenarios:
1. Same-seed/same-settings autonomous 6v10 no injected movement, then extended until documented zone change/respawn or bounded fixture threshold; prove authoritative HP0 and valid registered slot lifecycle. If bottleneck is near-impossible combat, capture HP/AI path trace, not fake a kill.
2. Injected user move/camera/blocked click test; assert legal movement and retain real combat outcomes, do not demand nine kills from changed decisions.
3. On authentic downed participant, verify Injury level 1, auto-return and recovery at exactly 120 scheduler ticks (not seconds), **no duplicate rewards** across Save/Load/Return. Loot remains explicitly `LOOT_PENDING`; `acknowledge_no_reward_receipt` is legitimate and NOT a paid drop.

If world topology prevents reaching C17 or camping transition, log exact world identity/nav SHA, seed, snapshot state, path and camp. Only repair a source-proven navigation/zone orchestration bug. Do not turn all 200–400 population slots into live actors (max 30 disciples/40 monsters).

### A4 / QA evidence and deliverables

Run official Godot **4.7.2** headless import + focused suites in this order, serial with exit codes. Capture test run and **candidate exact SHA**, engine version, command, stderr/stdout, logs, runtime receipts/counters. Perform static diff and consistency verification; new code must compile. If CPU/memory/old GUI prevents a full test, identify which blocked and leave **QA_PENDING**, not PASS. No GUI/mouse PASS claim.

Commit/push candidate branch, open ONE **Draft PR targeting current PvE feature**, with direct description of what was used from PR #45/#46/#47/#48 and AUX-02 QA branch (not another stack of overlapping active PRs). Update Issue #37 and #41/#42 with exact SHA, tests and PR URL. Mark only proved subpackets PASS.

**Exit contract:** either (i) SaveService failure's proven root cause fixed or fixture corrected plus full safety tests green, C17/formation verified, 20-zone+Injury120 accepted; OR (ii) precise red tests, raw logs and remaining blocker reproducible. Never assert completed gameplay without exact evidence. Release Godot QA slot to CODEX 2 after all tests/failed launch attempts end.

**Final handoff to user:** concise Vietnamese table for SAVES/ATOMICITY, MOVE-C17, PARTY-UNIQUE, 20-CAMP, INJURY120 with `PASS/FAIL/BLOCKED`, exact SHA, PR URL and required integration action. No merge to `main` or feature branch without owner approval.
