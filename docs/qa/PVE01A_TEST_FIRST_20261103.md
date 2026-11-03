# PVE-01A TEST-FIRST — DV2-03 oracle, Source A 6v10 contract

**Date:** 2026-11-03, Asia/Bangkok
**Package:** PVE-01A ONLY; explicit owner CODE authorization
**Repository:** vuanhtuan161094-byte/TongMonBaDao
**Base:** PR #67 branch integration/tri-facility-a-b-playable-20261102 @ c136600f5579871d476e0feca2d78ea3c74e6b1f (Draft, unmerged)
**Main:** c0c1382f119599497b52d8ee8abd9e830a883f1e (unchanged)
**Isolated branch:** feature/pve01a-dv203-test-first-20261103

## Scoped changes / ownership

Only:
- godot/tests/simulation/dv2_03_realm_body_progress_test.gd
- godot/tests/simulation/pve_01a_6v10_v63_gate_contract_test.gd
- docs/qa/PVE01A_TEST_FIRST_20261103.md (this evidence file)

Never modify: CombatStatsV2, DiscipleRealmProgressV2, P3.2, V63 runtime/scheduler/SaveService/state, economy, rewards, balance, main, PR #67 or owner save. TRI-03 retains writer ownership of P3.2. No other active PVE01A branch or PR #67 file overlap was found at authorization time; unpushed local writer state cannot be inspected remotely.

## Reproduction and root cause

Existing Godot 4.7.2 CI on a166252e634127337c9d74ee125f02e4a477a2d1 fails at dv2_03_realm_body_progress_test.gd:125:

\`Persistent Tu Vi/Body coordinates produced incorrect canonical combat stats.\`

The fixture is a D7 V2-born disciple with potential=100. Production \`DiscipleRealmProgressV2.derive_stats\` derives with \`potential_realm_only = disciple.foundation_model_version >= FoundationSystem.MODEL_D7\`. The old test called \`CombatStatsV2.derive(1,3,1,2,potential)\`, hence its *legacy-mode* default was compared against an explicitly D7-mode result.

PVE-01A test change supplies D7 mode for the direct equality and computes **independent oracle** for every core channel:
- D7 expected = realm_piece × (1+0.0005×potential) + body_piece.
- Legacy expected = (realm_piece+body_piece) × (1+0.0005×potential).
- Realm 1 floor 3 growth=1.03²; Body 1 floor 2 growth=1.03. For potential 100:
  - max_hp: D7 204.0945, legacy 208.7295
  - attack: D7 25.3689, legacy 25.5234
  - defense: D7 20.57734, legacy 20.93784
Both formulas remain separately asserted; live HP ratio, XP and breakthrough assertions are preserved. No balance formula was changed.

## Real Godot QA already observed

**Godot official v4.7.2.stable.official.ed1daf0bf**, run on commit \`b7b9ad503ccf9d9bffa668f982bc1114a796a2d9\`:
- https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41579630344
- The previously failing **DV2-03 2×300 REAL TRACKS + XP SOURCES + BREAKTHROUGH GATES + SAVE: PASS** marker appeared, exit 0 for that specific test.
- Next 14 individual DV2 tests through E3.1 also PASS.
- **DV2-03 workflow overall FAIL** at \`dv2_03_p3_body_training_building_ui_test.gd:81\`: \`E3 requires three authentic V2 disciples.\` This is a **separate** failure in an out-of-allowlist presentation test. The E3 test source is byte-identical between current main and PR branch, but its behavior can be affected by newer Residence capacity authority; do not conclude its precise root cause without the admission receipt. No E3 test was changed.
- P3.7 Backend workflow https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41579630422 was still running when this document was first authored; inspect live result.

**PVE-01A 6v10/V63 test status: NOT_TESTED as a standalone Godot process.** No local Godot executable or private repo checkout exists in the current analysis container; public downloads fail DNS. Do not infer runtime PASS from static inspection or the main DV2 workflow. Its source is designed to go **RED** until PVE-01B authorizes a runtime gate fix.

## New 6v10 test-first contract

\`godot/tests/simulation/pve_01a_6v10_v63_gate_contract_test.gd\`:

1. Opens isolated fresh New Game through canonical LiveGameRuntimeV2, **prints the natural number of V2-ready founders**; never creates free New Game recruits to satisfy the six-person gate.
2. Stages the **committed 130-disciple endgame QA seed via SaveService** into the unique \`user://pve01a_6v10_v63_gate_20261103.json\`. This avoids bypassing real Residence/bed capacity (RecruitmentSystem refreshes it).
3. Selects six authentic, healthy, unoccupied V2 disciples; sets genuine V63 persisted opt-in in QA save; acquires a single QA manual via WarehouseSystem, archives via SectArchive, learns and equips \`tmb.skill.bow.liep_anh.active_01.human\` through the production authority API.
4. Builds real 192×192 Source A topology, begins one authoritative \`HuntingPveRunV2.begin_multicamp\` with exactly **six disciples and ten live monster actors**, and checks save identity.
5. Asserts V63 ON for the previously equipped actor. This is **expected RED with current implementation**, because \`begin_multicamp\` does not propagate preview overrides.
6. After a future PVE-01B fix, further asserts independent SaveService reopen retains both equipped loadout and enabled combat gate.

Fixture note: one QA-only manual and persisted opt-in are setup, not naturally earned progression. This test is *not* a full New Game→PvE GUI/loot/skill rotation acceptance test. No user save or warehouse outside this isolated QA path is touched.

Command on a real checkout with official Godot 4.7.2:
\`\`\`bash
godot --headless --path godot --editor --quit
godot --headless --path godot -s res://tests/simulation/dv2_03_realm_body_progress_test.gd
godot --headless --path godot -s res://tests/simulation/pve_01a_6v10_v63_gate_contract_test.gd
godot --headless --path godot -s res://tests/simulation/pve_save_return_reload_exactly_once_test.gd
\`\`\`
Expected behavior before PVE-01B: all setup assertions + PVE01A_6V10_BASELINE_PASS, then PVE01A_TEST_FIRST_EXPECTED_RED and exit 1. If any earlier assertion fails, it is a test fixture/setup blocker, NOT proof of the gate defect. After PVE-01B, same test must exit 0, and additional real cast/HP-delta and offline-clock tests remain required in the separately authorized packet.

## Remaining blockers and rollback

- **P0-B:** V63 multicamp begin+shared-clock resume gate remains unfixed. Out of current CODE allowlist.
- **P0 baseline:** exact New Game with six legitimate V2 disciples is not yet proven to be reachable without recruitment/Residence progression.
- **CI residual:** official DV2-03 entire job is FAIL at E3 presentation admission; owner must separately authorize out-of-allowlist repair if a new packet is needed. Never call FULL green.
- **PVE gate RED test:** new standalone test has not been run on this branch.
- **Windows GUI/Android:** PENDING USER.
- **P3.7 full cumulative:** record its actual result independently.

Rollback: feature branch is descendant of c136600f and contains only authorized test/evidence files. Revert feature branch commits in reverse order or abandon the branch; PR #67/main and user saves remain untouched. Do not cherry-pick this packet to PR #67 while test/cumulative gates are unresolved.


## Final exact-code recheck, 2026-11-03

**Code/test SHA rechecked:** \`b759dde5e3c0ddda2793988616788300233ebcd1\`.
**Run:** https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41579993344
**Job:** 125732318482, official \`4.7.2.stable.official.ed1daf0bf\`.

Actual official log:
- \`Parse complete Godot project\`: SUCCESS. This parses the committed test source, **not** standalone execution of the new 6v10 test.
- \`PVE01A_DV203_D7_LEGACY_INDEPENDENT_ORACLE_PASS channels=3 potential_mode=D7_realm_only legacy_mode=full_core\`: observed.
- \`DV2-03 2×300 REAL TRACKS + XP SOURCES + BREAKTHROUGH GATES + SAVE: PASS\`: observed with exit 0.
- 14 following DV2 subtests through \`DV2-03E3.1 SLOT TRANSFER ...: PASS\`: observed with individual exit 0.
- **Workflow FAILURE** at \`dv2_03_p3_body_training_building_ui_test.gd:81\`: \`E3 requires three authentic V2 disciples.\` Exact test source is identical between main and PR branch (blob \`80f82b37914119819e261d38b15f027045126947\`). Its \`_recruit\` raises \`disciple_capacity\` but production \`RecruitmentSystem.accept_candidate\` refreshes capacity from SectResidence when Hall is installed; test-only capacity inflation can therefore be ineffective. **High-confidence fixture cause, not fixed or proven by standalone retest.** This file is out of PVE-01A allowlist.
- P3.7 Backend: https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41579993377 — \`Run P3.7 full cumulative gate\` still IN_PROGRESS at final review, **not PASS**.
- New \`pve_01a_6v10_v63_gate_contract_test.gd\`: source parsed in official editor import, but standalone test not invoked by workflow. Runtime 6v10, expected RED at V6.3 gate, and cross-process Save/Reload are **NOT_TESTED**. Command listed above must be executed in the next authorized/runtime-capable gate.

**Acceptance:** PVE-01A D7 root cause / scoped test fix = **FOCUSED PASS**. PVE-01A as a complete packet remains **QA OPEN** due cumulative E3 failure and standalone 6v10 gate not executed. No gameplay or save migration; no merger into PR #67/main. Windows/Android **PENDING USER**.

## PVE-01A.1 — E3 canonical Residence repair and standalone RED evidence (03/11/2026)

**Authorization:** owner explicitly allowed the additional E3 presentation test file, existing PVE-01A test files, and docs/qa evidence. Production `BuildingSystem`, `SectResidenceSystemV1`, `RecruitmentSystem`, CombatStats, UI, SaveService and feature gates were NOT modified. PR #67/main remain untouched. E3 uses only an isolated `user://dv2_03_e3_body_building_ui_test.json` profile.

### Root cause and minimal fix

- Fresh game has 6 founders, 1 active Lv1 Residence, exactly 8 beds; Hall rank-1 population limit is 12.
- The old `_recruit` raised `state.sect.disciple_capacity` directly, but production `RecruitmentSystem.accept_candidate()` always invokes `SectResidenceSystemV1.refresh_capacity()` under an installed Hall, resetting legal capacity to min(rank cap, actual beds)=8. Third new recruit fails `capacity_full`.
- In the E3 test ONLY, `_prepare_residence_for_three_recruits()` computes the real canonical Residence Lv1→Lv2 upgrade cost, supplies a **test-only** canonical Warehouse/treasury budget, then calls `BuildingSystem.start_upgrade(state,residence_001,stable_request_id)` with actual debit/receipt. It advances the isolated simulation through 12 real BuildingSystem ticks until Level 2, verifies 10 legal beds and idempotent receipt replay, then admits 3 genuine V2 candidates using `RecruitmentSystem.accept_candidate` with no capacity override. Hall stays Lv1. Only then is the original 9-stone Body Training test wallet configured.
- **No direct changes to House level, production values, starter roster, rank limit, recruitment gate, state schema or user save.** This is a legitimate QA prerequisite, not evidence the player can buy/upgrade it from fresh New Game in 12 wall-clock seconds.

Official **Godot v4.7.2.stable.official.ed1daf0bf** on commit `d10d607c8e5213b412ca263e3bf23da6a8e2a256`:
- https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41580609681 — **DV2-03 workflow SUCCESS (31 steps)**.
- `DV2_03_E3_CANONICAL_RESIDENCE_PREREQ_PASS {"beds":10,"founders":6,"hall_level":1,"house_id":"residence_001","legal_capacity":10,"level":2,"paid_receipt":"e3_qa_residence_lv2_one_receipt","source":"isolated_qa_warehouse_and_treasury","upgrade_work_ticks":12}`.
- `DV2-03E3 REAL RÈN THÂN MAP + TWO-SLOT UI: PASS`.

### Independent Source A PvE 6v10: actual RED reproduced

To avoid claiming a standalone test ran when only the editor parsed it, a **temporary** subprocess call was added to E3 **only on commit** `b6b244e0434c2bb171b3f6f0f7120ba5da86330b`. It launched `OS.get_executable_path()` using `--headless --path <project> -s res://tests/simulation/pve_01a_6v10_v63_gate_contract_test.gd` in a **separate actual Godot process**. The parent CI asserted the expected RED result, recorded the complete transcript and succeeded. The temporary subprocess runner was then **removed** from E3 at commit `aad81571402feb90983564eae5f4ed352b818b02` (final E3 test stays single-purpose).

- Run: https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41580924908, official Godot 4.7.2 job **SUCCESS**; child exit code **1** (intentional RED).
- `PVE01A_FRESH_NEW_GAME_OBSERVATION {"can_start_6v10_without_recruitment":false,"initial_roster":6,"naturally_ready_v2":0}`: natural New Game does **not** provide 6 eligible V2 hunters.
- `PVE01A_6V10_BASELINE_PASS {"disciples":6,"monsters":10,"source_map":"sect_isometric_source_a_pve_v1","source_sha":"c0e6b9952ce6303718938f5705a0327d0a14b136"}`: six existing authentic V2 members selected from committed 130-roster QA seed and ten live Source A world monsters. These were fixture participants, not natural New Game hunters.
- `PVE01A_TEST_FIRST_EXPECTED_RED V63_ON_IN_SAVE_BUT_MULTICAMP_ACTOR_HAS_NO_ACTIVE_EQUIPPED_SKILL`.
- `PVE01A_6V10_V63_GATE_FAIL: persisted V63 ON was not propagated into the authentic 6v10 actor; PVE-01B pending`.
- `PVE01A_TEMP_STANDALONE_RUN_RESULT {"baseline_6v10":true,"child_exit":1,"engine":"4.7.2-stable (official)","expected_v63_red":true}`.

Interpretation: **6v10 battle creation and identity PASS, V6.3 multicamp gate FAIL reproduced by real Godot; Save/Reload after the gate is not yet reached and remains NOT_TESTED for the V63-enabled path.** This is not an AI rotation/visual/Android acceptance or loot completion.

### Clean-up / rollback

- Permanent changes are test-only: `godot/tests/simulation/dv2_03_realm_body_progress_test.gd`, `godot/tests/simulation/pve_01a_6v10_v63_gate_contract_test.gd`, `godot/tests/presentation/dv2_03_p3_body_training_building_ui_test.gd`, and this `docs/qa` evidence file.
- The new 6v10 test remains deliberately RED and is not part of DV2-03's habitual positive suite. The temporary CI subprocess adapter has been removed.
- Revert only this feature branch's test commits or abandon the branch; do not cherry-pick a RED PvE gate into PR #67 without an explicit PVE-01B integration plan. No save schema change or migration needed. Windows physical mouse/Android **PENDING USER**.
