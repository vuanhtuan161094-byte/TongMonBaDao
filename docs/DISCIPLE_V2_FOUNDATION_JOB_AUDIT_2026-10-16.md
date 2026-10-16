# DISCIPLE V2 — LỤC DUY / REALM–BODY / ONE ACTIVE JOB AUDIT

## Addendum — 2026-10-16 PR #18 integrated guard+handoff repair

Post-merge code/test SHA: `333172bd2d50f97f853a0b5ec4fb0f2a9cbe79ff`. PR #18 is still a draft targeting PR #9. Direct production entrypoints now use an execution-only action/direct-command conflict gate, preserving WORK-command replacement preflight. Legal Body transfer clears conflicting saved HOLD/Chuyên Tu only after fully valid reservation. Founding Three test regressions are still unexecuted; extended One Active Job test now covers Forest, synthetic incompatible actions, actual Mine timed batch serialization and deterministic scheduler completion exactly once, receipt keyed by `wage:job_id`, and Body transfer; Foundation test checks save-roundtrip without changing growth source/provenance. All locked Economy V2, V2 combat stats and 30×10 tracks untouched.

**Validation disclaimer:** static delimiter/quote/comment scan 8/8 GDScript files; NOT official Godot 4.7.2 parse, import, headless or Windows test. No CI or merge. Run proper real runtime gates, including O6 ==4/O8/SAFE/GP-02B1/02C1/P3.7 FULL; do not claim these fixes passed in game yet. Historical PR #9 official Windows FULL_EXIT=0 at `453df9a` remains separate prior evidence.

---
Date: 2026-10-16
Status: **CODE WRITTEN; STATIC STRUCTURAL VALIDATION ONLY; GODOT 4.7.2 RUNTIME PENDING**.
Repository: `vuanhtuan161094-byte/TongMonBaDao`.

## Git topology and precise boundary

- `main` observed at `461caca1171462e0da092f21108c5c1733157ad9`, untouched.
- Draft PR #9 Economy V2 observed at `cf11d53f2ac48e9b7a220500fece983b675dcd62`. Its balance is **not edited** in this packet.
- Draft PR #10 `disciple-v2-scale-20261016` observed at `f374bc78a5556ad1003d92b27d6ec89c7c929aa3`, our **exact stacked parent**.
- New branch `disciple-v2-foundation-job-20261016` is based on PR #10, not on PR #9 directly. PR #9 has moved relative to older handoff SHA; **do not assume all subsequent PR #9 changes are present in PR #10's ancestry without comparing/rebasing later**. Do not rewrite either parent PR in this packet.
- Scoped production: `foundation/foundation_system.gd`, `building/building_system.gd`, `workforce/workforce_system.gd`, `cultivation/disciple_body_training_facility_v2.gd` under `godot/src/simulation/`.
- No edit to `CombatStatsV2`, `DiscipleRealmProgressV2`, `SimulationScheduler`, SaveService, Warehouse, Injury, scripts/scenes for UI, production balance tables or GitHub workflows.

## Source → owner → effect → runtime consumer

| Lục Duy | User-locked effect | Actual consumer/limit verified in source |
| --- | --- | --- |
| Tư Chất | +0.25%/pt natural/base Tu Vi, fixed XP exempt | `DiscipleRealmProgressV2.grant_xp(...,"cultivation","natural")`; one passive Tu Vi minute owned by scheduler/TuViFlow |
| Căn Cốt | +0.20%/pt natural Body XP, fixed exempt | `DiscipleRealmProgressV2.grant_xp(...,"body","natural")`; paid Rèn Thân, active production and expedition paths require source/context guards |
| Thông Tuệ | +0.15%/pt profession XP | `ProfessionModifierSystem.total_profession_xp_factor` through `WorkforceSystem._learning_multiplier`; no direct bulk yield multiplier |
| Cơ Duyên | `RNG(0..9999)+Cơ Duyên−Difficulty` for meaningful outcomes | `FoundationSystem.luck_score` available; legacy rare-event factor still uses bounded compatibility bridge. **Full meaningful-event migration OPEN**; no per-tick lucky resource mint |
| Mị Lực | social score and Dẫn Tiên guide/recruitment | `FoundationSystem.social_score`; `RecruitmentSystem` guide quality/daily limit and snapshots. **General social action consumers OPEN** |
| Tiềm Lực | +0.05%/pt **Realm+Body core** ATK/DEF/HP, retroactive | Existing `CombatStatsV2.derive` already multiplies only summed Realm + Body component BEFORE unrelated flat; `DiscipleRealmProgressV2.derive_stats` passes live Potential. **New:** permanent growth primitive immediately synchronizes live HP with ratio preserved, rolling back the foundation mutation/quality/HP if sync fails; rejects NaN/Inf/invalid HP |

Birth six-value snapshot is not modified; current quality is rederived from current six permanent values. Cultivation and Body realm progression remain 30×10 each, independent, with no speculative breakthrough/EXP changes.

**Growth-source truth:** `FoundationSystem.add_permanent_points` is a checked **mathematical primitive, not a gameplay earning source**. A concrete item/event with inventory debit, eligibility, one-shot event receipt and save/replay coverage for each proposed permanent growth reward still needs authorization and implementation. The regression uses test-only synthetic grants to verify math; this is **not evidence of an earned player faucet**. Unbacked passive/timer permanent growth was deliberately not introduced.

## One Active Job audit / changed ingress

- `WorkforceSystem.assign_worksite`: a live Alchemy, Mine or Forest timer cannot be moved/cleared through worksite reassignment; same saved worksite is unchanged.
- `WorkforceSystem.perform_work`: direct backend call cannot enter a second profession while saved timed job, Body reservation or different legacy carry cycle exists. Same legacy carry profession still drains; same Field duty may legitimately plant multiple plots.
- `BuildingSystem.perform_resource_job_step`: direct Mine/Forest producer cannot start/advance alongside independent timed recipe or growing Field duty.
- `BuildingSystem.work_available` and `perform_spirit_field_step`: exclude other timed work/legacy carry without disallowing multiple plots under **one Field duty**.
- `BuildingSystem.alchemy_can_start`: prevent additional recipe beside old carried cycle or growing plot before ingredient charge.
- `DiscipleBodyTrainingFacilityV2._prepare`: reject timed recipe/legacy cycle before committed Stone payment and Body XP.
- Already guarded and deliberately retained: Mine/Forest/Field worker assignments, `WorkforceSystem.issue_command`, `DiscipleTrainingActionV2.request_training`, Body `reserve_slot`, PvE `HuntingPveRunV2.begin` and legacy reconciliation. `disciple_has_active_timed_recipe` already covers both Alchemy and Economy-A resource timers; no duplicate occupation authority was added.
- Injury behavior remains **0 / 1 / 120 simulation ticks**. Existing P2 paths and legitimate HOLD cancellation/legacy carried-unit settlement are preserved.

## Focused regression files — committed but NOT executed

1. `godot/tests/simulation/disciple_v2_foundation_core_regression_test.gd` — authentic recruit; nonfinite/invalid foundation rejection; corrupt live-HP refusal; retroactive three-core Potential factor; unrelated +100 flat ATK remains flat; HP ratio, birth snapshot and quality; typed Tu Vi/Body XP natural vs fixed, learning/Luck/Social formula; dry-run progression isolation.
2. `godot/tests/simulation/disciple_v2_one_active_job_entrypoints_test.gd` — authentic Economy V2 Mine timer, cross-command/worker/training/worksite conflicts, HOLD cancellation without ore/wage/EXP, legal transfer to Body; Field multi-plot as one duty with other job rejected; Alchemy committed timer rejects reassignment/overlap/second input charge.

Static validation performed: GDScript delimiter/comment/string structure for changed scripts and test source; scoped text inspection versus PR #10 and contracts. **Not a GDScript parser/import gate, not a Godot runtime PASS.** No CI, no merge, no Windows or Android request.

## Mandatory Godot 4.7.2 verification when available (PENDING, not assigned to user)

Run targeted tests at exact new branch tip, then affected regressions:
```text
godot --headless --path godot --script res://tests/simulation/disciple_v2_foundation_core_regression_test.gd
godot --headless --path godot --script res://tests/simulation/disciple_v2_one_active_job_entrypoints_test.gd
godot --headless --path godot --script res://tests/simulation/disciple_v2_scale_safe_path_test.gd
godot --headless --path godot --script res://tests/simulation/dv2_03_realm_body_progress_test.gd
godot --headless --path godot --script res://tests/simulation/dv2_03_body_xp_source_test.gd
godot --headless --path godot --script res://tests/simulation/gp_02b1_v2_occupation_guard_test.gd
godot --headless --path godot --script res://tests/simulation/mine_v2_one_worker_test.gd
godot --headless --path godot --script res://tests/simulation/economy_a_playable_test.gd
godot --headless --path godot --script res://tests/simulation/economy_v2_bulk_production_test.gd
```
Re-run O6/SAFE/save-offline/full cumulative on a real Godot runner before any integrated acceptance. Do not claim a green test from script structure alone. Windows GUI, Android and 1k–3k sustained simulation remain PENDING. Keep PRs stacked/draft/unmerged.

## OPEN

Permanent improvement item/event provenance and durable claim owner; meaningful Fortune events and general social checks; all source→consumer end-to-end runtime evidence; full integration with advanced Trait/Destiny/Bloodline/Physique content; balance of high-realm earned costs; full O6/SAFE/runtime QA and performance; PR #9 advanced-tip ancestry review before parent-stack merge/rebase. No other work is authorized by this audit.
