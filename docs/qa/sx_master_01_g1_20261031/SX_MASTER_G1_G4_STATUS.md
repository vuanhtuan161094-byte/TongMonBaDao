# SX-MASTER-01 — G1 review and G2–G4 checkpoint

Date: 2026-10-31 (Asia/Saigon). This is an evidence checkpoint, not a release acceptance.

## Exact source refs

- ONE GAME integration/one-game-v65-20261030 remains at 199f888c7fd690830728dfbf29b6b79276e3b283 (verified with GitHub compare).
- G0 evidence/code branch codex/sx-master-01-g0-async-save-20261031: 70ee0de829702aeefba63f89d7bf320f5ee57673. PR #59 is open Draft, base remains ONE GAME. G0 code/test SHA is fa010df49b455dc896a9b5c509c85fccfce09448.
- PR #57 feature/sx01-pill-policy-20261031: 7d5887cb5f5db452177f06649806dbf44c21e461, 13 commits ahead of verified base.
- PR #58 feature/sx02-realm-grade-medicine-20261031: 30aa335f70fafb6382e4448ca77ebe1f6991db7d, 38 commits ahead. Its PR base is PR #57; compare confirms shared ancestry at 199f888.
- No candidate code was integrated. PR #57/#58 remain Draft; no merge was performed.

## G0 — Save/Reload

**PASS 14/14** on official Windows Godot 4.7.2.stable.official.ed1daf0bf, code/test SHA fa010df49b455dc896a9b5c509c85fccfce09448; import exit 0. The minimal fix awaited the existing async autosave in O3/O7/O8/O9 tests; production SaveService and validation were unchanged. Evidence is on [PR #59](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/59): [report](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/codex/sx-master-01-g0-async-save-20261031/docs/qa/sx_master_01_g0_20261031/G0_REPORT.md), [14-row matrix](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/codex/sx-master-01-g0-async-save-20261031/docs/qa/sx_master_01_g0_20261031/G0_TEST_MATRIX.csv), and raw per-test logs.

## G1 — Draft candidate runtime QA

Godot 4.7.2 results are in [G1_TEST_MATRIX.csv](G1_TEST_MATRIX.csv) and selected raw markers below.

- PR #57: **2 PASS / 6 FAIL**. Economy-A playable and SaveService async roundtrip pass. Policy roundtrip fails; O4/O8/O9 and renderer parse fail; B3 satiety and CARE replay assertions fail.
- PR #58: **7 PASS / 4 FAIL**. Catalogue registry test passes 856 checks, but this verifies identifiers/catalogue only. P3.7A1, P3.7A2, Economy-A, SaveService async, SAFE-01 and SAFE-02 pass. Medicine runtime parse, SX01 policy roundtrip, B3 satiety compatibility assertion and CARE reload assertion fail.
- Root cause for policy persistence: SectState.from_dict only accepts a saved value when typeof(saved) == typeof(default); an isolated JSON reproduction observed an integer default, a float decoded value, then reset to the default (including auto_day). This is a candidate policy persistence defect, not a G0 SaveService regression.
- PR #57/#58 renderer parse error: p3_2_landscape_sect.gd cannot infer variable name (PR #57 line 3410; PR #58 line 3484). PR #58 medicine runtime test also cannot infer cultivation_before.
- B3 satiety failure is a stale test expectation: the test requires save version 4 while candidate CARE writes CARE_VERSION=5. Do not weaken CARE validation to make it pass.
- CARE reload test fails exact RNG/HP/timer/receipt/policy equality; policy numeric type loss is a reproduced contributor. Other state fields still need isolated differential proof.

See [G1 failure log excerpts](G1_FAILURE_LOG_EXCERPTS.md). Full raw PR57/58 stdout/stderr remain on this Windows QA host under E:/TongMonBaDaoWorkspace/QA_Evidence/SX_MASTER_G1_QA_20261031/pr57_7d5887c/ and .../pr58_30aa335/.

## G2 — facilities and source gates (static, source SHA 199f)

Independent source audits: [423-ID resource lineage matrix](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/sx04-master-audit-handoff-20261031/docs/qa/SX_RESOURCE_FULL_LINEAGE_20261031.csv), [600 facility rows](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/sx04-master-audit-handoff-20261031/docs/qa/SX_BUILDINGS_ALL_600_LEVEL_ROWS_20261031.csv), [root-cause report](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/sx04-master-audit-handoff-20261031/docs/qa/SX03A_DEEP_ROOT_CAUSE_REPORT_20261031.md).

Code-derived totals generated locally from BuildingSystem (formula only; not a time/rate benchmark):

| Facility | Current source-reachable level | First gate / finding | Cumulative Lv1→100 costs if code path is enabled |
|---|---:|---|---|
| Mine | 9 | Lv10 requires tam_mach_ban without an identified gameplay producer/market; target 20 has no milestone component mapping | Through code gate 19: 280 wood, 415 ore, 1,365 stones, one tam_mach_ban |
| Linh Lâm | 1 | upgrade_enabled=false | Disabled |
| Linh Điền | 100 (code path) | Heart component gates at 10/20/30/50/75/100; 29 hearts total, 100 fragments/heart, fragment chance 5%×rare factor | 26,216 wood, 13,132 ore, 78,564 stones, 29 hearts |
| Luyện Đan Điện | 1 | upgrade_enabled=false | Disabled |
| Rèn Thân Đường | 1 | Explicit upgrade content-pending gate | Disabled |
| Dẫn Tiên Đài | 100 (code path) | Generic costs; no special component | 21,857 wood, 17,490 ore, 104,741 stones |
| Luyện Khí | 1 | Workforce group only; no levelled BuildingState | No level path |

The 5% fragment chance implies 2,000 harvests/heart in expectation at rare-factor 1, not guaranteed completion; 29 hearts is 58,000 expected harvests. This is a source-rate calculation, not elapsed play time. Owner target Lv100 common-resource yield ×10,000 is not met: Mine's authored batch rises 2→12 (=×6), and no real measured throughput supports an extrapolation to ×10,000.

## G3 — economy, medicine and PvE source/sink status

The [medicine candidate matrix](SX_MEDICINE_SOURCE_QUALITY_MATRIX.csv) expands the candidate's 240 IDs but labels registry, authored recipe, ingredient path and grade reachability separately; its multipliers/thresholds remain provisional. Only the four realm-1/2 recipe definitions exist. Realm 2 consumes tu_van_thao and requires Alchemy Hall Lv10/profession Lv3; tu_van_thao is gated by Field Lv30. Real crop→craft→graded stock→B3→Save/Reload has not passed.

The [event ledger](SX_ECONOMY_LEDGER.csv) records only code-authored flows and marks period projections unmeasured. Economy-A is optional/off by default. Its active market catalogue has four resources; the independent audit derives at most 160 stones/day for the bounded channel under the documented global 20-unit cap and maximum unit value 8. A continuous Body Hall actor consumes 1,440 stones/day. This comparison is a throughput warning, not a complete cashflow simulation. PvE settlement still has no actual resource/stone payout; map reward previews are metadata, not loot receipts. No loot was added.

## G4 — import and GUI evidence

- Official Godot 4.7.2 headless import on the G0 source SHA: **exit 0**, 103 asset steps. Runtime startup has one nonfatal Windows root-certificate-store diagnostic.
- The game was launched from the exact QA checkout with an isolated save profile; the OS reports Tong Mon Ba Dao (DEBUG), PID 13508, responding, working set about 589 MiB at the sampled moment. This is an idle sample, not gameplay or an FPS benchmark.
- Computer Use returned no targetable Godot window after refresh; therefore no mouse journey, screenshot, Save/Return/Reload, offline test or video was obtained. **GUI_BLOCKED / FPS_PENDING**. Process startup or headless PASS is not playable acceptance.
- QA import generated tracked/untracked .import metadata in the existing E: worktree. It was left unstaged/uncommitted; pre-existing local edits were also preserved. Exact committed source remains 70ee0de... No generated import output was added to the branch.

## Gate status and blockers

- G0 async Save/Reload harness: **PASS**.
- G1 PR #57/#58 candidate QA: **FAIL**, no integration.
- G2 facilities: **FAIL/PENDING** on missing milestone content and disabled upgrades.
- G3 economy/medicine/PvE: **PENDING** on approved numeric rules, lawful ingredient/source paths, measured pacing and real reward receipts.
- G4 GUI/Save/Offline/performance: **BLOCKED** because Godot is not exposed as a targetable Computer Use window; no true-play evidence.
- A previous broad integration attempt was rejected by automatic approval review because it would import unapproved candidate balance values. No retry/bypass was made. To resume code integration, owner needs to lock/approve medicine quality/potency policy, SX01 auto-use defaults/quota/targets, and candidate Hall upgrade economics; missing resource sources and disabled building gates remain content blockers even after that.
