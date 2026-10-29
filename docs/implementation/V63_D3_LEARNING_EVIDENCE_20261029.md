# V6.3 D3 — Gated personal technique learning

## Result

D3 is implemented on `feature/v63-v64-full-combat-20261029`. Initial code/test commit: `677184c3f05eb84e31aed66e48ee42c383acc222`, parent `4b914d05eb601d2788968a0419e5dda63c79b6fc`; completed-save reload regression: `677184c3f05eb84e31aed66e48ee42c383acc222`. The approved main baseline remains `c0c1382f119599497b52d8ee8abd9e830a883f1e`; no main change, PR creation, or merge occurred. PR #52 remains Draft/open.

The D3 learning system is additive and globally gated. The catalog has 12 candidate techniques across bow, fist and poison: three school foundations and nine branch techniques. A disciple must have access to the matching archived Sect Archive manual, satisfy deterministic prerequisites, and have no active job or reserved occupation before study can start. Starting study reserves Contribution and personal spirit stones once; scheduler ticks advance it; retry-safe receipts protect start, cancel, completion and mastery operations. Cancellation returns the reserved cost once. Completion grants personal technique knowledge once. A disciple can equip one main and two auxiliary techniques and retain personal mastery milestones.

Legacy P2.3 `learned_techniques` and `active_technique_id` remain intact. SaveService adds schema v3→v4 migration defaults; CARE envelope v3/v4 compatibility remains supported while current CARE writes use envelope v5. No identity crosswalk was approved or applied. Gate rollback pauses new progress/effects while retaining D3 records. Technique costs and tick durations are explicitly candidate values; all combat effects remain disabled.

## Exact changed code, catalog and test paths

- `godot/data/combat/v63_learning_catalog.json` (new)
- `godot/src/simulation/technique/v63_learning_system.gd` (new)
- `godot/src/simulation/state/disciple_state.gd`
- `godot/src/simulation/state/sect_state.gd`
- `godot/src/simulation/state/simulation_state.gd`
- `godot/src/simulation/save/save_service.gd`
- `godot/src/simulation/core/simulation_scheduler.gd`
- `godot/src/simulation/building/building_system.gd`
- `godot/src/simulation/combat/hunting_pve_run_v2.gd`
- `godot/src/simulation/combat/v63_feature_gates.gd`
- `godot/src/presentation/disciple_presentation_snapshot_v2.gd`
- `godot/src/presentation/p2_3_techniques.gd`
- `godot/tests/simulation/v63_d3_learning_job_test.gd` (new)
- `godot/tests/presentation/v63_d3_learning_ui_test.gd` (new)

## Runtime evidence

Engine: `Godot Engine v4.7.2.stable.official.ed1daf0bf`, Windows x86_64 console build. Logs were captured under `C:/Users/Admin/Documents/Codex/2026-10-29/files-pasted-by-the-user-codex/outputs/v63_d3_learning_validation`. All commands were sequential, and each returned exit code 0. The 14 local source/catalog/test files were compared with the committed GitHub files at `677184c3f05eb84e31aed66e48ee42c383acc222`; all 14 contents matched exactly.

Import command: `E:\\Godot_v4.7.2-stable_win64_console.exe --headless --editor --path godot --import` — PASS, exit 0.

Focused and cumulative commands used `E:\\Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script <res:// test path>`:

| Script | Result | Log SHA-256 |
| --- | --- | --- |
| `v63_d3_learning_job_test.gd` | PASS, 62 checks | `41151BC2DA6B8E0F1776FAFE6E72E48E6676F2D54531D035DD5DBEE1EBE20290` |
| `v63_d3_learning_ui_test.gd` | PASS | `09BBA4AE4C9A77E655AB896101434844198BDCF31EBC795B7F7CB0F9AB5FD25B` |
| `p2_3_technique_test.gd` | PASS | `BFA2B6B11AC7B869E13AE679E02533002B05C70CA3986AD9AA47FF5CBD71D489` |
| `v63_d2_sect_archive_test.gd` | PASS | `959D816471A828B41888FCAE7A3A710E686C578B9EC60B419D1CA0A6786DAC0F` |
| `v63_d2_codex_drop_receipts_test.gd` | PASS | `024C95CD79EE2A24FFFD63321448EBE1D96C31645A53ED796C18E8D13405DCC7` |
| `p3_7b1_warehouse_test.gd` | PASS | `B5F6A6CC57778EF471A1FDE29FF863547DA56AEE509291B94187CEA23EC67A0B` |
| `save_service_async_roundtrip_test.gd` | PASS, 10 checks | `19EB65DF588D863FE61D5551128C7332E966AD2B1821073BDBF773104D7734DF` |
| `safe_01_save_recovery_test.gd` | PASS | `3382CFF6FA69886231F84577A79386A6D10C4FE792EE20076BF21C3E26BB4B03` |
| `pve_save_return_reload_exactly_once_test.gd` | PASS, 50 checks | `3FC731232B04D34BD1414151E8AA0EF70A7A29422F68B2E34BAA6BD102000E59` |
| `pve_multicamp_combat_hp0_bridge_test.gd` | PASS | `C36462FC3A61D99E499949C4BE90BF39C9BE6E7B8B0BDB88B8F5EEE1F3420D30` |

Import log SHA-256: `94DBC584EFB654A761C2693A8C79EECC5934468CF3F42CF5A9E3612D1FB311BB`. Matrix summary SHA-256: `7CC2A07A307708535E2C1FDD3E7E2F2CD40BE7BFB8EFB311E31E34DE69842656`.

## Limits and remaining acceptance

- Every Windows Godot invocation printed `Failed to read the root certificate store`; import/tests still returned exit 0. SAFE-01 also prints the expected JSON parse errors while testing corrupt-save recovery, followed by its PASS marker and exit 0.
- These are headless Windows engine results. Physical mouse/GUI play at 1280×720, Android device play and owner visual acceptance remain PENDING; no PLAYABLE/UI/Android acceptance is claimed.
- The E: feature worktree at D2 SHA `d45ab195c53c00f0f29732124dd7678fd42cb351` had four in-scope files with uncommitted EOF-only line-ending changes, so it was not overwritten. Validation used the Windows scratch checkout; its exact 14 code/catalog/test file contents match the published D3 code commit.
- No live skill effects, bosses, approved production balance/drop rates, SaveService replacement, new Warehouse/scheduler, D4+ work, PR, or merge to `main` are included.
