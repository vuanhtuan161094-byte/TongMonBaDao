# TÔNG MÔN BÁ ĐẠO — O6 BLOCKER FORENSIC & SAFE RECOVERY PACKET

**Date:** 2026-10-23 · **Authority:** READ-ONLY EVIDENCE / DESIGN-ONLY. **No gameplay change, no merge, no change to PR #24, no CI/FULL launch by this packet.**
**Source:** owner-uploaded `MAIN_SKILLS_CARE_INTEGRATION_20261022.zip`, manually read and cross-checked against GitHub source and [PR #24](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/24). Use actual Codex-generated ZIP logs, not a fabricated baseline.
**Repository:** `vuanhtuan161094-byte/TongMonBaDao`. Main checked at `29b5fba448b0178cb520a4ada44b375b4b934e31`. CARE draft PR #24 head `12387e12adc500d84b95cbfc433f297c3f6475f2`; last tested gameplay SHA `98ee31e9e87f228da39b3863e76063cb30bc40d1`.
**Skills:** `tmb-project-director` + `tmb-godot-evidence`. Codex worktree remains exclusive to Codex.

## 1. Verified technical status (not acceptance)

- PR #23 six skills merged to main and Codex 6/6 skills discovered, no errors.
- PR #24: **DRAFT**, not merged. Replayed 7 source CARE/FASTTRACK commits; contains 27 files (25 Godot + 2 checkpoint/handoff docs). Source-to-API SHA mapping inside ZIP `CARE_SOURCE_TO_API_COMMITS.json` is essential; source FASTTRACK `b56b85f...` corresponds to GitHub `a0a489ce...`.
- Official Godot `4.7.2.stable.official.ed1daf0bf`; `INTEGRATION_FOCUSED_RESULTS.json`: **27/28 PASS**, 1 FAIL, code SHA `98ee31e...`. B3 CARE, PillSatiety (1,000,000/day/actor), FASTTRACK, PH0, CombatV2, Injury02C1, focused Warehouse etc PASS. Failing exact test `godot/tests/presentation/p3_o6_m1_release_rehearsal_test.gd` (real GUI/scheduler Mine+Field+Forge+Save integration, NOT a cosmetic test).
- FULL log `FULL_NATIVE_INTEGRATION_RETRY.log` **INCOMPLETE**: ends at `[Parse 227/240]` without final marker; no PASS or FAIL determination of FULL from this log. Do not classify it as a concrete parse error without an engine error stack. Related focused runner reports two unusual long elapsed durations (`gp_02b1_v2_occupation_guard_test` ~9156 seconds, `safe_02_warehouse_migration_test` ~6366 seconds), exit0 with PASS; independently triage stall/host overhead before heavy full gates, not proof of gameplay slowness.
- User's package includes baseline snapshots and staged diagnostics. PR #24 should remain draft until targeted O6 gate and then any agreed broader gate close. Windows GUI human/manual and Android device still PENDING.

## 2. First-bad-stage evidence and current hypothesis

The ZIP contains source-bundle staged reproductions:
- Skills-only published baseline `ab399974...`: O6 test **PASS** (`baseline_p3_o6_m1.json`).
- PH0 source stage `97a3d980...`: O6 **PASS** after isolated editor import (`o6_stage97a3.json`).
- **FASTTRACK source stage `b56b85f2...`**: O6 **FAIL** (`o6_stageb56.json`), stays FAIL at `1d686dc8...` and integrated code SHA. First-bad GitHub-mapped commit `a0a489ce3586b6af33e74dbdb5e211468c735357`; good predecessor `a141aa876480da0c4854cef21abd5cbeb6f1fb83`.
- `diag_batches_baseline.stdout.log`: first two completed batches **+2 then +2** ore. `diag_batches_published.stdout.log`: **+3 then +2**. The baseline log completed five batches. No evidence of duplicate Mine batch: baseline and stage diagnostics each show 1 then 2 `production_batches`.
- `diag_baseline_o6.stdout.log`: `DIAG_ORE_AVAILABLE=4 ORE_QTY=44`. `diag_published_o6.stdout.log`: `AVAILABLE=5 QTY=45`, starter 40 still reserved; an additional +1 occurred.
- Crucial upstream divergence appears **at tick0 before actual Mine work**: `diag_start_baseline.stdout.log` or `diag_workers_baseline.stdout.log`: mine worker set `[trieu_linh_nhi, lam_thanh_vu]`, selected `trieu_linh_nhi`. First-bad `diag_start_stageb56.stdout.log` / `diag_workers_stageb56.stdout.log`: mine workers `[co_truong_phong,trieu_linh_nhi]`, selected `co_truong_phong`. Creator seed reports same `31012026`; active jobs/workgroups differ. `diag_factory_*.stdout.log` and `diag_ui_stages_*.stdout.log` show different choices at various instrumentation stages; do not confuse distinct diagnostic checkpoints as a same-tick equality proof.
- On GitHub `godot/tests/presentation/p3_o6_m1_release_rehearsal_test.gd` line ~103 picks **`miners[0]`**; line ~190 hardcodes exactly 4 spendable ore after two batches; helper `_mine_one_explicit_batch` merely verifies stock rose and `production_batches` advanced exactly once, not exact quantity of each origin.
- **`godot/src/simulation/building/building_system.gd`** at main defines `_resource_job_batch_units(building)` = `base_batch_units + floor(level/10)`, ordinary Lv1 baseline 2; FASTTRACK first-bad code diff `a141..a0a` **does NOT modify BuildingSystem**, but modifies the state/runtime bootstrap, clock, owner and adds persistent B3 world/scene. This points to an **indirect change of initialization, worker selection or a second authoritative ore source**; not proof BuildingSystem algorithm itself is wrong.

**Hypothesis H1:** the first-bad bootstrap/state path changes which legal miner/workgroup is selected in O6, exposing a profession/policy/scheduler side effect or extra ore award in the first batch. **Hypothesis H2:** a second job/legacy output source emits +1 while the targeted `production_batches` remains 1. **Hypothesis H3:** unexpected prior available-resource state or effective source/receipts; the identical reserved starter-40 in logs makes this less likely, but verify exact source. The fact miner IDs differ is **not itself a proven cause of extra ore**; test both miners under the same snapshot. No data so far prove hidden cheating, duplicate mining, or a legitimate bonus. Do NOT "fix" by changing test 4→5, altering global Mine yield or reverting whole FASTTRACK blindly.

## 3. Minimal proof-driven Codex DIAGNOSTIC STEPS (READ-ONLY or temporary non-committed instrument)

**Goal**: locate *first state/event divergence*, then one specific root cause and narrow SAFE code fix proposal (no speculative code edits).

1. Separate clean temporary worktrees (E: as already used), same official Godot 4.7.2, fresh editor import and truly separate `user://` data dir. Match `31012026` and O6's exact script; verify GH source commits `a141aa...` good vs `a0a489...` bad by **same test command**. Capture process exit, PASS marker, canonical tick.
2. Record before and after initial `P37Factory.create_state`, `LiveGameRuntimeV2.start`, `_configure_live_state`, `SimulationRuntimeOwnerV2.attach/update`, `SaveService.load`, recruitment, assignment and first O6 UI action: sorted `disciple_id`, role/workgroup/worksite, active job, `state.seed`, `rng_state`, B3 world ownership, Mine level/job table, `qty/available/reserved`, chosen miner. Identify first mismatch BEFORE claiming an ore computation bug. Randomness/dictionary iteration and save contamination must be ruled out.
3. Repeat identical seeds under same command at least 3–5 independent clean userdata paths per good and bad SHA to see deterministic vs flaky outcomes. Try *pinning legal miner identity* in a disposable diagnostic fixture (not committed test) to separate "who was picked" from "what was produced".
4. Trace EVERY authoritative Thanh Thiết `warehouse.add`/stock-change during ticks 0..47 with source kind, job/receipt ID, worker ID, old/new qty, building ID, `production_batches` and exact tick. Compare two first cycles (+2 vs +3) and note whether the extra +1 originates from resource timer, P0/P1 legacy work, other building, pending job, or a reward replay. Verify queue job `output_quantity` at **creation**, and again at settlement. Do not infer from cumulative quantity alone.
5. If and only if real cause proven, propose the smallest source path allowlist. Candidate review-only paths: `godot/src/simulation/core/live_game_runtime_v2.gd`, `.../simulation_runtime_owner_v2.gd`, `.../simulation_runtime_clock_v2.gd`, `.../state/simulation_state.gd` and O6 script/Workforce/BuildingSystem **for read-only audit**. The actual CODE allowlist follows evidence, not guesswork.
6. Maintain One Active Job and preserve real bonus economics. If first-bad behavior is *legitimate and only test is over-specific*, obtain owner signoff for a stronger invariant test using genuine receipt/job source amounts rather than silently raising hardcoded 4. If it is duplicate/phantom output, fix authoritative source, not test. Do not modify O6 expectation until explained and approved.
7. Send back a compact report: first divergent *call + state field*, exact two reward sources if +3, minimal fix plan + risk, affected regressions, whether O6 can legitimately retain exact 4.

## 4. Controlled gate after owner authorizes a narrow fix

- First target O6 test at new CODE SHA, repeat 3–5 runs with clean userdata. Confirm `starter=40` genuinely reserved, `available` exact and conservation, first two batches attributable to real jobs, no equipment/Field drift.
- Then rerun 28 focused/cross-contract official tests on **new** CODE SHA; no 27/28 reuse from old code SHA.
- Do not mark FULL PASS from 227/240 parse log; independently inspect why process ended (manual kill, resource, timeout, OOM, runner reset or actual GDScript error), collect exit status. On 8GB RAM use isolated runner and small focused gates first; only attempt an appropriately authorized broader/full gate after narrowing memory/time and resolving O6.
- GUI independent native 1280×720 and physical Android acceptance remain separate. PR #24 stays draft while blocked. Never merge main, Source A, G1/MAP25/C4 as a "fix".

## 5. Relation to B3-XP-01 design

The owner already locked **direct fixed Tu Vi per genuine eligible monster death**; optional rare Tinh Nguyên is NON-XP by default. A docs-only canonical packet exists at `docs/b3-xp01-direct-kill-canonical-20261023`, file `docs/handoffs/B3_XP01_DIRECT_HUNT_TUVI_IMPLEMENTATION_PACKET_2026-10-23.md`. **Do not import that canonical branch into CARE PR** while O6 is blocked. After CARE/QA gate is closed, fresh branch B3-XP-01 with exact CODE path list and observed 1/3/6-role/kill traces. Further numeric balances for 30×10, 60/40 Boss stones, actor thresholds and high-tier map contents should be calibrated using real gameplay; not a reason to block forensic O6 work.

## Ready-to-send Codex prompt — narrow diagnosis only

```text
TÔNG MÔN BÁ ĐẠO — O6 ROOT-CAUSE FORENSIC, READ-ONLY, keep PR #24 DRAFT.
Read docs/handoffs/B3_CARE_O6_FORENSIC_RECOVERY_PLAN_2026-10-23.md from branch docs/b3-care-o6-recovery-and-design-gates-20261023 and the ZIP MAIN_SKILLS_CARE_INTEGRATION_20261022.zip if accessible. Use official Godot 4.7.2 and independent E: worktrees/userdata. Map source good 97a3d980 to GitHub a141aa876 and bad source b56b85f2 to GitHub a0a489ce, per CARE_SOURCE_TO_API_COMMITS.json. Do NOT edit O6 test or gameplay yet. Find first divergence: baseline picks trieu_linh_nhi, FASTTRACK picks co_truong_phong, first Mine batches +2/+2 versus +3/+2, with only 1 completed batch metric. Trace every authorized Warehouse ore add, job source, worker, tick, and RNG/workgroups. Pin worker in temporary diagnostic runs to separate identity from side effect. Return concrete cause/evidence, minimal authorized CODE allowlist proposal and targeted regression plan; no CI/FULL/merge, no Source A, no G1/MAP25/C4, no XP implementation. Do not change CAP 1,000,000.
```

**Scope status:** DESIGN DOC ONLY / FIRST-BAD EVIDENCE. No GoDot tests run by ChatGPT; baseline result from Codex-uploaded logs only. No code or existing tests modified.
