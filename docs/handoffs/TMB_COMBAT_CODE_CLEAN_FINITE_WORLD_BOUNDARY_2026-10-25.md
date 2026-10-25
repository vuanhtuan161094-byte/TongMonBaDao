# TÔNG MÔN BÁ ĐẠO — CODE-CLEAN: FINITE 90s / CONTINUOUS WORLD REWARD ISOLATION
## Kiểm toán caller, thay đổi có giới hạn, bằng chứng & QA gate

**2026-10-25. SOURCE CHANGES COMMITTED ON ISOLATED BRANCH; QA NOT YET GREEN.**
**Requested baseline**: PR #31 integration/pr28-combat-v3-s1-playable-qa-20261024 HEAD `9eb4fd55733bb49bbb069240b8e332d37d22aced`. **New branch** `code/code-clean-finite-reward-20261025`, forked from this EXACT SHA; NO changes to PR #28, #29, #31 themselves, no merge into main. Audit basis: `docs/research/TMB_COMBAT_CONTINUOUS_VS_LEGACY_90S_DEPRECATION_AUDIT_2026-10-25.md` on docs branch `docs/r11-s1-s2-quant-economy-combat-softlock-20261025` (NOT automatically cherry-picked into this code branch).

## 1. Finding: 90s legacy is NOT canonical hunting World time
- `MapBattleV2.setup(..., keep_encounter_open=true)` = continuous-mode combat owner.
- `MapBattleV2.step`: timeout is conditioned on **not continuous_mode**; World combat may persist indefinitely subject to proper event/batch budgets. B3 pilot World works through `B3HuntWorld.begin` with true flag; 120s and >3600s headless fixtures exist on PR31.
- `B3HuntWorld` owns persistent world ID, one life slot/generation, per-kill receipt, warehouse credit and save barrier. `B3MedicalAutoplayV1` handles care/recovery. The B3 demo does NOT depend on `HuntingMapV2.claim_reward` to pay an entire wave.
- `HuntingPveRunV2` is a **different, retained legacy finite PvE subsystem**. It loads/saves v1 finite snapshots, has battle terminal results (including `timeout_retreat`) and settles whole-encounter rewards via `HuntingMapV2.claim_reward`; historical tests and saved encounter snapshots rely upon it.
- `MapBattleSnapshotV2` writes legacy finite version 1 and PH0 continuous version 3; old v2 snapshots remain readable. Delete/rewrite without migration would violate SAVE/EXACTLY-ONCE contracts.
- This audit DOES NOT claim the prototype B3 single-member/single-spawn World implements the R11 30-hunter/3-node frontier content; still awaiting World v2 ownership, nav, materials, monster species, and real full game integration.

## 2. Caller inventory / ownership chain (source-read, PR31 SHA)
| Caller / path | Current use / ownership | Verdict |
|---|---|---|
| `godot/src/simulation/combat/map_battle_v2.gd` | `setup(...,keep_encounter_open)`, `step/run`, finite timeout and World event queue | **DUAL MODE**; timeout must remain only in finite branch |
| `godot/src/simulation/combat/b3_hunt_world.gd` | `battle.setup(id,[],[monster],true)`, per-kill settle/save, respawn; NO `HuntingMapV2.claim_reward` call | **CANONICAL B3 PILOT WORLD**, KEEP |
| `godot/src/simulation/combat/b3_pilot_content.gd` | Uses `HuntingMapV2.REGION_CONTENT` for older map scale only; independently owns fixed genuine per-kill source | KEEP; shared data is not shared payout |
| `godot/src/simulation/combat/hunting_pve_run_v2.gd` | `setup` finite; `finish`, `claim`, `_settle_terminal`, `restore_state` and legacy save migration | **FINITE LEGACY**, KEEP WITH CROSS-MODE GUARDS |
| `godot/src/simulation/combat/hunting_map_v2.gd` | Whole encounter spawn/preview/claim; reward claim is an old map class, not world | KEEP FINITE, NEW FAIL-CLOSED GUARD |
| `godot/src/simulation/combat/map_battle_snapshot_v2.gd` | Uses timeout bound solely when loading finite old snapshots, otherwise large World elapsed range | KEEP SAVE COMPAT, MAKE LEGACY REFERENCE EXPLICIT |
| `godot/src/simulation/core/simulation_runtime_owner_v2.gd` | Owns B3HuntWorld checkpoint/commit under simulation clock and SaveService | KEEP |
| `godot/src/presentation/b3_playable_hunt.gd`, `godot/src/presentation/p3_2_landscape_sect.gd` | Invoke `B3HuntWorld.begin/return/restore`; do not directly settle finite rewards | KEEP READ-ONLY PRESENTATION |
| `godot/tests/simulation/b3_ph0_continuous_kernel_test.gd` | Includes both finite timeout regression and continuous >3600s scenario | KEEP BOTH UNTIL DELIBERATE LEGACY RETIREMENT |
| `godot/tests/simulation/b3_fasttrack_hunt_test.gd` | Same world 120s, multi-generation kills, save retry, exactly-once | KEEP |
| `godot/tests/simulation/dv2_02_five_level_pve_test.gd`, `dv2_02_group_map_battle_test.gd`, `dv2_02_battle_snapshot_test.gd` | Exercise old finite APIs and snapshot V1, including rewards and save | KEEP REGRESSIONS |
| `godot/tests/simulation/combat_v3_s1_edge_contract_test.gd` | Builds direct old finite and continuous fixtures, damage/status/typed snapshots | KEEP |
| `godot/tests/simulation/combat_finite_world_reward_isolation_test.gd` | New negative mixed-mode and forged-world-claim test | NEW; MUST RUN ON GODOT |

**Limit of audit:** Explicit production owners + known focused integration tests have been source-read and their code paths traced. A full repository-wide regex scan of all scripts, assets, docs and historical branches was NOT successfully completed through available connector execution limits; do not claim that every historical use of `MAX_SECONDS` or `HuntingPveRunV2` has been exhaustively enumerated. The above list is adequate to scope this conservative fail-closed patch, **not** authorization to delete legacy classes.

## 3. ACTUAL patch allowlist / changes
| Modified/added path | Intent |
|---|---|
| `godot/src/simulation/combat/map_battle_v2.gd` | Name old finite timeout `LEGACY_FINITE_MAX_SECONDS=90.0`; retain `MAX_SECONDS` alias for old callers; `step/run` use explicitly named finite constant under `not continuous_mode`. No change to combat physics, RNG, HP, cooldown or continuous limits. |
| `godot/src/simulation/combat/map_battle_snapshot_v2.gd` | Legacy v1 timeout validation references explicit finite constant; continuous v3 remains independent. No format/version bump. |
| `godot/src/simulation/combat/hunting_map_v2.gd` | Reject continuous_mode or reserved B3 world IDs **before** warehouse mutation, even if caller fakes terminal `win`. Error `continuous_world_requires_per_kill_receipts`; valid finite payout unchanged. |
| `godot/src/simulation/combat/hunting_pve_run_v2.gd` | Finite setup passes `false` explicitly; reserved B3 world prefix rejected on begin/restore; continuous snapshots rejected on restore; `advance,finish,claim,_persist_live_state,save_state,_settle_terminal` reject continuous. Prevent partial mutation/receipt collisions. Legacy-only lifecycle remains available. |
| `godot/tests/simulation/combat_finite_world_reward_isolation_test.gd` | Negative tests for live/fake terminal World claims, spoofed B3 ID on finite, arbitrary future R11 continuous ID, invalid V3-to-finite restoration, side-effect-free lifecycle checks and immutable warehouse/receipt state. |

No changes to `B3HuntWorld`, `B3MedicalAutoplayV1`, `WarehouseSystem`, `SaveService`, `CombatStatsV2`, `SectState`, `Injury`, `ResourceRegistry`, UI/asset, or PR branches. No free resources, no duplicate reward owner. No R11 content addition.

## 4. Explicitly NOT deleted — WHY
`timeout_retreat`, the 90s finite constant, and `HuntingPveRunV2` are **legacy compatibility**, not World gameplay canon. Deleting them immediately without migrating saved v1/v2 finite snapshots and updating retained PvE tests would break deterministic SAVE/INJURY exactly-once and violate this packet's preservation constraints. `MAX_SECONDS` remains an alias while callsites/tests are audited in a later strictly authorized retirement packet. The old 36×20 local combat arena is not proof of R11 world geometry; do not change it here.

## 5. Verification protocol and actual evidence
### Structural evidence [YES]
- Branch created from exact PR31 head; source-level owner/caller analysis complete for scope above; code commits and test added with GitHub contents API; no PR/merge mutation.
- Existing PR31 Packet B documented **28/28 Godot focused tests PASS on its own code SHA `4b02a0c61a2771d9d4638129d96b68ad292270dc`**, not on this CODE-CLEAN branch. Do not transfer GREEN status.

### New branch Godot gate [NOT PASS]
The execution container has **no Godot 4.7.2 executable**; network cannot clone the private/connected working tree into that container. Therefore **no local Godot focused test has been run here**. Github push triggered automatic workflows; for example [run 40160260276](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/40160260276) reported FAILURE, and connector jobs metadata contains `steps=null`, `logs_url=null`. No successful runtime test evidence can be established, nor can root cause be assigned to this patch without readable logs. Keep **QA BLOCKED/UNVERIFIED**, not PASS and not a proven regression. Windows/Android remain PENDING USER.

Run from an intact checkout of this branch, using **official Godot 4.7.2**:
```powershell
godot --headless --path godot --script res://tests/simulation/combat_finite_world_reward_isolation_test.gd
godot --headless --path godot --script res://tests/simulation/b3_ph0_continuous_kernel_test.gd
godot --headless --path godot --script res://tests/simulation/b3_fasttrack_hunt_test.gd
godot --headless --path godot --script res://tests/simulation/b3_care_pills_autohunt_test.gd
godot --headless --path godot --script res://tests/simulation/combat_v3_s1_edge_contract_test.gd
godot --headless --path godot --script res://tests/simulation/dv2_02_five_level_pve_test.gd
godot --headless --path godot --script res://tests/simulation/dv2_02_group_map_battle_test.gd
godot --headless --path godot --script res://tests/simulation/dv2_02_battle_snapshot_test.gd
godot --headless --path godot --script res://tests/simulation/gp_02c1_injury_settlement_test.gd
```
Required results: **new test green**, historical finite Win/Defeat/90s regression unchanged, continuous worlds still live after >90s and >3600s, genuine per-life payout/save dedup unchanged, all legacy correct encounter claims still paid once, Injury120 + no cross-owner resurrection. Capture Godot version, branch HEAD, stdout/stderr, actual exit codes. Run affected cumulative/full gates before integration closure. A failure demands repair on this isolated branch; no test removal or claim of PASS from docs.

## 6. Next retirement packet (NOT AUTHORIZED BY THIS PATCH)
1. Exhaustive whole-repo callsite search across all .gd, data, scripts and tests at CURRENT integration HEAD and any incoming PR changes; freeze concrete allowlist.
2. Inventory all saved finite v1/v2 checkpoint fixtures plus `v2_pve_active_runs`, `v2_pve_reward_claims`, `v2_pve_settlement_receipts`; choose official migration/rollback policy that preserves claims.
3. Migrate any remaining user-facing finite routes to World continuous per-kill owner, with atomically settled source receipts and persistent generation. Do not silently change legacy grants to per-life without reconciliation.
4. Only after focused+full Godot 4.7.2 PASS may future packet remove finite-specific timeout, `HuntingPveRunV2`, `HuntingMapV2.claim_reward` and compatibility tests; preserve historical QA provenance as docs/archive, not erase evidence.
5. World R11 S1/S2 remains BLOCKED: ore/fiber nodes, real deer species, route/retreat/recovery, 30–300 roster, World source per-life receipts and content authoring still missing.

**Current verdict:** CODE-CLEAN PATCH COMMITTED / STATIC OWNER BOUNDARIES INSPECTED / NEW QA AND REGRESSION NOT RUN / CI FAILURE UNATTRIBUTED / NO MERGE. Owner should authorize no wider deletion until this scope runs clean.
