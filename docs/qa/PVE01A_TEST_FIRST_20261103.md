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
