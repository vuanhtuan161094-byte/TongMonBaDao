# TÔNG MÔN BÁ ĐẠO — PACKET CODEX: RETIRE FINITE 45s/90s, GIỮ WORLD CONTINUOUS, KHÔNG MẤT DATA
**2026-10-25 | STATUS: DESIGN-ONLY / FUTURE CODE AUTHORIZATION REQUIRED.** Soạn từ checkpoint CODE-CLEAN `5fbdbc6309c3f1386f0d8b619831e007c5a52824` descendant PR31 `9eb4fd55733bb49bbb069240b8e332d37d22aced`. Documents-only change in dedicated branch `docs/combat-finite-retirement-full-caller-save-migration-20261025`; không sửa runtime/tests/workflow/UI/asset ở lượt này; không merge.

**Read-first sequence**: `AGENTS.md`; `docs/GAME_SYSTEM_ARCHITECTURE.md`; `CURRENT_CHECKPOINT.md`; `NEXT_CHAT_HANDOFF.md`; parent `docs/handoffs/TMB_COMBAT_CODE_CLEAN_FINITE_WORLD_BOUNDARY_2026-10-25.md`; companion inventory `docs/research/TMB_COMBAT_FINITE_RETIREMENT_EXHAUSTIVE_CALLER_INVENTORY_2026-10-25.md`; companion migration `docs/design/TMB_COMBAT_FINITE_TO_CONTINUOUS_SAVE_ENTITLEMENT_MIGRATION_CONTRACT_2026-10-25.md`. These are instructions for a FUTURE EXPLICITLY AUTHORIZED Codex code run, not permission from this docs task.

## 1. Target result user actually sees
- Player picks hunting region; disciple/group travels into **persistent map World**, uses learned skills/statuses/physical attacks via the existing CombatStatsV2 + Combat V3-S1 effects, can fight continuously beyond 45s/90s. No new “wave over/auto-retreat due fixed elapsed seconds” on World.
- Monster life occupies a stable spawn slot and generation. One real HP0 death => one committed material entitlement and Warehouse credit; asynchronous respawn creates next generation only after valid interval. Auto-hunt may rest, heal, retreat, redeploy and resume same world without resetting paid generations.
- Original sect work/travel/injury/XP/warehouse/save still has ONE owner. 30–300+ disciples must use multi-party World authoring and background batch simulation, NOT spawn 300 actors into B3's single-player single-slot pilot.
- Old playable progress and valid saved finite rewards remain claimable; no reset/free conversion/invented loot. Legacy map/Body low-tier sources still obtainable after new source parity.

## 2. Blocker diagnosis from exhaustive source
1. `SimulationScheduler._step_disciple` still uses `COMBAT -> CombatSystem.resolve_encounter`. This is **real live scheduling**, and `CombatSystem` uses 20-round older resolver or **45s max realtime** depending on skill flag. Winner enters `LOOT` and personal `pending_loot`, not the per-life World Warehouse owner.
2. `HuntingPveRunV2` and `HuntingMapV2.claim_reward` still implement genuine finite **90s max** group battle/whole-win claim and are required to load historical active/terminal snapshots and GP-02C1.
3. `HuntingMapV2` owns low-tier source catalog, 5 grades and four-win Linh Tủy guarantee; `DiscipleBodyGateTransactionV2` consumes its source readiness. Never delete without replacement.
4. `B3HuntWorld` is correct continuous **pilot** only; it currently validates exactly one monster slot and (up to) one member. Its `MapBattleV2` kernel can support broader actors, but that does NOT provide a real 30-versus-40 world or multi-camp authoritative source manager by itself.
5. `SaveService` supports version 3 / CARE version 4 plus staged/bak and float64; `SimulationState.from_dict` calls old `HuntingPveRunV2.reconcile_loaded_v2_pve`. New schema must not trash historical running or won-but-unclaimed fights.
6. Parent CODE-CLEAN has cross-mode guards/new test, **unverified** Godot QA. R0 gates must settle that debt before broad edits.

## 3. Phased implementation plan — DO NOT DO ALL IN ONE UNSCOPED COMMIT
| Phase | Real behavior deliverable | Code owner / candidate paths (future, not currently authorized) | Gate |
|---|---|---|---|
| **R0 QA + all-extension grep** | Reproduce parent focused tests; Windows/Godot 4.7.2; prove current finite/World boundary. | Tests only if broken: `combat_finite_world_reward_isolation_test.gd`; current five parent code files; no opportunistic changes | New test + B3 fasttrack/care/PH0, V2 PVE, GP-02C1, World S1 all green, exact SHA |
| **R1 Canonical source parity** | Move R1–R6 earned materials, `linh_tuy` deterministic four-eligible-event counter and technique/equipment drop source policy into distinct non-encounter World content owner. Explicit receipt-based source. | Proposed NEW `godot/src/simulation/combat/world_reward_catalog_v2.gd`, `world_source_receipt_v2.gd` (names proposal), `hunting_map_v2.gd`, `disciple_body_gate_transaction_v2.gd`, `resource_registry.gd`, legal reward tests | F0/F3/F5/F6 body gates, earned material origin, common/rare, NO_DROP and dedup 100 replays |
| **R2 Scheduler WORLD admission** | User-facing `HUNT/COMBAT` no longer dispatches 45s/20-round resolver for V2 World hunting. Map/AI/one-job assignment routes to persistent World; party grouping, continuous safe return; preserved social/memory/profession/skill progression semantics. | `simulation_scheduler.gd`, `workforce_system.gd`, proposed world orchestrator (NOT reuse single-slot B3 blindly), `simulation_runtime_owner_v2.gd`, `simulation_runtime_clock_v2.gd`, `b3_hunt_world.gd` adapter only if explicitly authorized; focused integration tests | A true human-selected hunter doing >90s genuine multi-life without legacy `resolve_encounter`, correct medical/injury and one Warehouse |
| **R3 Close NEW finite admissions, keep old compatibility** | Disable new `HuntingPveRunV2.begin` for production after R1–R2 readiness; keep private finite resume/claim/settlement for supported old saves. Move public five-level UI to World zone policy; keep historical rare/normal content as source rather than fake encounter choice. | `hunting_pve_run_v2.gd` (compat gate); `hunting_level_selector_v2.gd`; `p3_2_landscape_sect.gd` only if needs real UX; `hunting_map_v2.gd`; `sect_state.gd` | No new finite sessions; old saved S01/S03 can still resume/redeem once; no softlock at early body tiers |
| **R4 Save migration adapter** | Deterministic classify S00–S15, reserved namespace, claim tombstone, pending LOOT, backup/rollback. Carry historical counter, support old finite v1/v2 wrappers and B3 v3. | `save_service.gd`, `simulation_state.gd`, `sect_state.gd`, `disciple_state.gd`, `map_battle_snapshot_v2.gd`, legacy migration new adapter, strong focused state tests | 100 save/load cycles + torn writes, claim/retry/crash, float64 identity, Injury120, no double mint or lost legacy goods |
| **R5 Remove old FINITE GAMEPLAY code** | Once legacy adapters only have supported history readers and R1–R4 PASS, remove runtime finite 90/45 path and `HuntingMapV2.claim_reward` from player-facing flows. `CombatSystem.commit_v2_direct_hit` stays. Tombstones/readers kept if still required by save policy. | Removal allowlist **cannot be locked before R0–R4 prove callsites**; add static no-new-finite-admission test, preserve historical fixture data | No production code references to old dispatch/rewards, all historical save fixtures recover, continuous game >3600s and multi-kill stable |
| **R6 Long soak / release acceptance** | 7/30-day canonical time, 30/100/300 roster, no offscreen loot; Android 1280×720 image/camera; CI + Windows nonadmin + hardware acceptance | QA tools, not arbitrary game rebalance or renderer rewrite | Signed exact SHA logs, genuine APK/device and owner visual acceptance before release |

**Dependencies**: R0 -> R1 -> R2 -> R3/R4 (may parallelize docs, not overlapping code writers) -> R5 -> R6. Do not call a phase DONE from prior branch's logs, docs-only specs or synthetic economy sheets. Each CODE packet needs explicit owner permission, exact fresh integration SHA and small allowlist. No FULL/CI unless its CODE packet and QA process authorize the run.

## 4. Suggested CODE allowlists by owner (future packets)
### R1/Earned Source Owner
- Read/write: `godot/src/simulation/combat/hunting_map_v2.gd` for extraction only, new source registry/loot owner files, `godot/src/simulation/cultivation/disciple_body_gate_transaction_v2.gd`, narrow ResourceRegistry changes if explicitly mapped, associated focused tests.
- Forbidden: stat formulas `combat_stats_v2.gd`, UI, rendered assets, `save_service.gd`, scheduler until next phase.

### R2/World Scheduler Owner (one writer on overlapping simulation)
- Read/write narrowly: `simulation_scheduler.gd`, World orchestration/actor admission, `workforce_system.gd` reservation bridge and relevant integration tests; include clock/runtime owner only if cutover cannot be done otherwise, evidence in PR.
- Forbidden: arbitrary loot formulas, editing combat V2 damage/crit/HP math, fake actor/FX, restaging R11 content, separate reward warehouse.

### R4/Save Owner
- Read/write: `save_service.gd`, `simulation_state.gd`, `sect_state.gd`, `disciple_state.gd`, `map_battle_snapshot_v2.gd`, dedicated compat migrator and fault tests; coordinate with R2 to avoid two writers to state/scheduler.
- Forbidden: silent in-place save rewrite on load, removal of `.bak`, timer/injury rebalance, forced claim, downgrade of CARE4.

### R5/Legacy Removal Owner
- Only after test gates: legacy resolver methods within `combat_system.gd` and finite methods within `map_battle_v2.gd`, `hunting_pve_run_v2.gd`, `hunting_map_v2.gd`, snapshot *writer* if no new callers. Retain separate *reader* for supported archive snapshots.
- `CombatSystem.commit_v2_direct_hit` is V2 authoritative call site and **must remain or relocate transparently** with exact regression. Deleting `CombatSystem` file wholesale is not authorized by “remove old PvE”.

## 5. Data-authority checkpoints (each is a release blocker)
**World reward proof**: ordinary genuine combat HP0 → immutable `kill_id` → validated loot or frozen NO_DROP → single Warehouse add + receipt + source depletion + save → only then ACK; failure doesn't erase entitlement. Camera/UI independent.

**Early Body proof**: obtain four eligible sources under new policy with equal earning cost/rarity semantics, exactly one `linh_tuy` guaranteed when due; old 3/4 counter carries into World without double counting. Tests `dv2_03_f3_body_material_earned_claim_test` and `dv2_03_f6_real_earned_body_gate_integration_test` not deleted just to avoid rewriting.

**Scheduler proof**: no `CombatSystem.resolve_encounter` in World gameplay dispatch, no `pending_loot` personal inventory double route. Existing unsent LOOT in old saves still consumed by old owner exactly once. One Active Job remains.

**Saved finite proof**: old valid running battle remains resumable via a sealed compatibility adapter; terminal winning unclaimed entitlements remain claimable after load; losing/timeout historical receipt preserved. Full removal of compatibility needs explicit owner approval with proof of no supported saves requiring it.

**Care/HP proof**: Injury0/1 and 120 ticks untouched, no double healing on load/return. Pause manual, medicine jobs, rest and auto-redeploy canonical.

## 6. A/B/C implementation choices for next owner approval
- **A — SAFE CUTOVER (RECOMMENDED)**: stop creation of legacy 45s/90s encounters, migrate new hunting to continuous World, KEEP frozen old-reader/claim adapter for legal historical saves. Gives gameplay modernized quickly with no forfeited entitlements. Implement R0 then R1/R2/R3/R4 on separate code packets.
- **B — TRUE PHYSICAL DELETION NOW**: REJECT under current constraints: breaks S01 running HP/RNG and S03 unclaimed win, R1–R6 body sources, scheduler's pending loot, 45s legacy test compatibility.
- **C — RETAIN BOTH FOREVER**: low immediate risk, but leaves confusing dual gameplay/reward authorities. Only acceptable as temporary migration state.

## 7. Targeted Godot 4.7.2 focused matrix (planned)
```powershell
# Do not claim these have been executed. Adjust official engine path, but not the test assertions.
godot --headless --path godot --script res://tests/simulation/combat_finite_world_reward_isolation_test.gd
godot --headless --path godot --script res://tests/simulation/b3_ph0_continuous_kernel_test.gd
godot --headless --path godot --script res://tests/simulation/b3_fasttrack_hunt_test.gd
godot --headless --path godot --script res://tests/simulation/b3_care_pills_autohunt_test.gd
godot --headless --path godot --script res://tests/simulation/dv2_02_five_level_pve_test.gd
godot --headless --path godot --script res://tests/simulation/dv2_02_group_map_battle_test.gd
godot --headless --path godot --script res://tests/simulation/dv2_02_battle_snapshot_test.gd
godot --headless --path godot --script res://tests/simulation/gp_02c1_injury_settlement_test.gd
godot --headless --path godot --script res://tests/simulation/dv2_03_f0_source_baseline_test.gd
godot --headless --path godot --script res://tests/simulation/dv2_03_f3_body_material_earned_claim_test.gd
godot --headless --path godot --script res://tests/simulation/dv2_03_f6_real_earned_body_gate_integration_test.gd
godot --headless --path godot --script res://tests/simulation/combat_v3_s1_effects_test.gd
godot --headless --path godot --script res://tests/simulation/combat_v3_s1_edge_contract_test.gd
godot --headless --path godot --script res://tests/simulation/p2_5_combat_skill_test.gd
godot --headless --path godot --script res://tests/simulation/p2_6_equipment_combat_effects_test.gd
godot --headless --path godot --script res://tests/simulation/safe_01_save_recovery_test.gd
godot --headless --path godot --script res://tests/simulation/safe_02_warehouse_migration_test.gd
```
Need also dedicated future tests not present: `combat_world_legacy_45s_scheduler_cutover_test.gd`, `combat_old_finite_save_claim_migration_test.gd`, `combat_v2_world_source_body_gate_test.gd`, `combat_world_multi_squad_30_300_load_test.gd`; names proposed, don't pretend files currently exist. Record Godot version, exact SHA, CI/Windows job logs, every exit code and PASS markers; no tests == QA PENDING. An outage of GitHub runner does not automatically validate game.

## 8. Suggested ready-to-send command for future CODE execution (DO NOT EXECUTE JUST FROM THIS DOC)
> TÔNG MÔN BÁ ĐẠO — Tôi cấp phép CODE-R0 ONLY trên một nhánh riêng từ CODE-CLEAN HEAD đã kiểm toán. Đọc AGENTS và toàn bộ 3 file packet ngày 25/10. Chỉ chạy read-only `git grep` all-extension và focused QA Godot 4.7.2 trước. Nếu có lỗi do patch CODE-CLEAN, sửa đúng file/test liên quan và lưu raw logs, không merge/đụng PR28/29/31. Báo exact SHA/FAIL/PASS và chuẩn bị R1 authorization. **Không tự triển khai R1–R5.**

For future R1/R2 authorization require corresponding new, explicit packet with owners, allowed paths, initial and target state, tests, rollback and separate author consent; this packet itself authorizes nothing.

**Outcome now:** **DESIGN PACKET COMMITTED ONLY; no runtime change; no claims of Godot QA or full legacy removal.** Preferred staged replacement A with finite compatibility adapter until saved entitlement drain.
