# TÔNG MÔN BÁ ĐẠO — S1/S2 R11: RECEIPT, SAVE/LOAD DEDUP, QA FAULT MATRIX
## Contract cho NodeHarvestKey / ActorLifeKey / anti-dupe trước khi thực sự code

**2026-10-25 · DOCS-ONLY, NO GODOT/CI CODE OR TEST EXECUTION.** Không code, packet Codex, PR29/UI/Source A/merge. Nội dung schema/event và tất cả ID `eqv2_*` là đề xuất, chưa có trên main và không phải code allowlist.
**Source inspection:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`; `WarehouseSystem`, `ResourceRegistry`, `MonsterCatalogueV2`, `HuntingMapV2`, `HuntingPveRunV2`, `BuildingSystem`, `SectState`, `SaveService`. Parent `docs/ascension-r11-r21-vertical-slice-source-proof-20261025`; companion source contract `docs/design/TMB_R11_S1_S2_TIEN_THIET_VAN_MOC_VAN_GIAC_LOC_SOURCE_CONTRACT_2026-10-25.md` and softlock report `docs/research/TMB_R11_S1_S2_OLD_GEAR_FRONTIER_SOFTLOCK_ECONOMY_PROOF_2026-10-25.md`.

## 1. No repeated physical credit: existing code vs missing world journal
**[CODE]** `WarehouseSystem.add(state,id,amount)` validates Registry ID, positive amount, safe integer and enabled Warehouse, then changes `sect.warehouse_resources` and `warehouse_event_count`. Event count is not an entitlement or dedup key; simultaneous reward writers can call `add` twice.
**[CODE]** `HuntingMapV2.claim_reward` pays a verified whole **win encounter** and guards `sect.v2_pve_reward_claims[encounter_id]`. `HuntingPveRunV2` has active snapshots and per-encounter terminal settle receipts. Neither structure proves a unique reward for every **monster life** in an open World, nor a **harvest generation** from a physical node. S2 may NOT reuse encounter claims as per-life claims and pay both owners for one death.
**[CODE]** `SaveService.CURRENT_VERSION=2` persists complete state with staged file, validation, backup and newer-version rejection. This is a usable save primitive, but no new source journal or world node state has been registered, hence no promise of exactly-once for these proposed sources.

## 2. Source receipt schema and immutable dedup identity [PROPOSED]
| Proposed field | Required invariant |
|---|---|
| `receipt_id` | stable from canonical source key + reward policy, not UI random/time |
| `source_kind` | `ore_node, fiber_node, normal_monster_life` |
| `world_instance_id, zone_id, source_slot_id` | persisted world namespace; not camera, node visual sprite or actor display ID |
| `source_generation` | monotonically advances only after old source transaction committed |
| `source_definition_id, source_definition_version` | actual ore/fiber/deer source, not generic `realm11_reward` |
| `worker_id / lethal_event_id` | genuine completed worker delivery OR Combat V2 death (not preview) |
| `frozen_items` | specific registered resource IDs, quantities, legitimate common-material roll and RNG provenance |
| `sect_owner, canonical_tick` | one recipient Sect Warehouse, no personal 30× loot |
| `status, settlement_hash` | dedup, conflict detection, crash-replay; UNKNOWN IDs fail closed |

**Identity key for ore/fiber [P]:** `NodeHarvestKey=(world_instance_id,zone_id,source_slot_id,harvest_generation)`.
**Identity key for deer [P]:** `ActorLifeKey=(world_instance_id,camp_id,spawn_slot_id,monster_life_generation)`.
A node can be rendered 100 times and still have one harvest generation; a monster reused display ID after a true respawn has a NEW generation. Key includes different source namespaces. Current `warehouse_event_count` and PvE `encounter_id` are NOT substitutes. Keep receipt tombstone/high-watermark across compaction; never delete enough history to make old generations claimable again.
**Result freeze:** chance(q) may yield no common hide; even a `NO_DROP` life MUST be marked settled and persist, else reload allows repeated rerolls. Freeze original source table version and outcome before later balance changes; repeated call with same key/different qty/source version is `CONFLICT_SOURCE_RECEIPT`, never an overwrite.

## 3. One source event owns one Warehouse settlement [PROPOSED]
~~~text
ORE/FIBER:
  AVAILABLE → RESERVED_WORKER → TRAVEL_WORK_HAUL → FROZEN_DELIVERY
  → PREPARED → COMMITTED(once: Warehouse+receipt+node depletion+XP)
  → COOLDOWN → NEXT_GENERATION (only after commit)

VAN GIAC LOC:
  ALIVE(HP>0, unique life) → COMBAT → DEAD(HP=0, one terminal death)
  → LOOT_FROZEN(possibly NO_DROP) → PREPARED
  → COMMITTED(once: Warehouse delta+receipt+actor death mark)
  → RESPAWN_WAIT → NEXT_GENERATION (only after commit)
~~~
**Atomicity guarantee [P]:** preflight actual ID, `MAX_SAFE_STACK`, positive qty, source version and unique key. Publish a single logical `SimulationState` update containing stock credit, source receipt, work XP, source depletion and respawn schedule. `SaveService` then persists the SAME state snapshot. If a crash occurs between debit/status/stock, rehydrate as an old frozen pending record or entirely roll back, but NEVER give another roll/payout or permanently lose stock. No false separate World bag or quest currency. If Warehouse overflow, hold the same pending result without spawning new life; don't discard a legitimate already-earned item silently.
**Delivery:** a worker cannot credit ore at pick-axe VFX AND again after hauling to Sect. If a work job is interrupted before settled delivery, material is pending or canceled according to saved source job policy, never silently doubled. One worker One Active Job; Injury1 auto return/recovery120 ticks must use same canonical clock. A multiplayer-looking camp with30 disciples attacking one normal deer still awards **one Sect packet** after one true life ends, not one per participant or squad.
**Mode gating:** legacy `HuntingMapV2` remains old encounter payout owner. A future live-world source owner may settle per death; one source entitlement must never cross both modes. A migration/feature-flag rule resolving old encounter snapshots is required *before* introducing per-life rewards.

## 4. Save migration plan, not a version bump
[CODE] `SectState` contains `warehouse_resources,warehouse_rules` plus legacy `forge_materials/technique_materials`, and `v2_pve_active_runs/v2_pve_reward_claims/v2_pve_settlement_receipts`. Existing Warehouse migration merges old buckets ONCE when P3.7 enabled.
[P] Add only schema families `sect.eqv2_world_source_receipts`, `sect.eqv2_world_source_slot_states` (generation, depletion, HP, job phase and pending reward), `sect.eqv2_world_content_version`, and a typed mode flag. No new `sect.eqv2_warehouse_resources`. Old saves initialize new ledgers EMPTY without free R11 ore, free drops or discarding old encounter claim. Validate new registered content IDs before migration, unknown item in future save causes safe rejection/backup, not deleting a legitimate item. Older clients must reject unsupported newer schema rather than silently downgrade. **Do not choose or claim a new SaveService version has been implemented.**
**No actor reset on load:** persist `world_instance_id` and source generations; don't generate a fresh instance key on each Save/Load. Offline sim updates respawn/hauling at canonical due ticks and freezes at most genuine eligible events with correct job/actor provenance; crossing ten respawn due-times while no valid actor kill or worker must NOT issue ten free materials. One accepted life death/harvest generation corresponds to at most one credited source receipt.

## 5. Fault injection & future QA: 36 fixtures; NONE RUN
| ID | Fault / setup | Expected result |
|---|---|---|
| T01 | `eqv2_r11_ore` not registered, harvest attempted | no stock/XP, fail closed |
| T02 | mapped R11 ore to real `an_tien_gioi` seal | reject cross-purpose use |
| T03 | same resource ID declared twice | Registry authoring validation fails |
| T04 | source defined, no actual world node | content S1 only; S2 BLOCKED |
| T05 | old R10 gear cannot path to ore | softlock FAIL, no fake gift |
| T06 | ore reachable but return/haul impossible | softlock FAIL |
| T07 | deer source can only be farmed after R11 gear | softlock FAIL |
| T08 | injury during R10 travel/haul | work paused/canceled lawfully, no payout, recovery120 |
| T09 | two workers reserve one node generation | at most one valid reservation |
| T10 | same worker simultaneously hunts and mines | One Active Job rejects |
| T11 | ore visual animation shown 100 times | no Warehouse credit before delivery |
| T12 | delivery completes, app crashes before reward toast | same credit one receipt |
| T13 | node camera leave/return 100 times | same depleted state/generation |
| T14 | node respawn tick crossed while reward still pending | no gen+1 until committed |
| T15 | identical NodeHarvestKey submitted twice | idempotent, one stock credit |
| T16 | same NodeHarvestKey mismatched qty/item | immutable conflict, no extra credit |
| T17 | 30 attackers in 5 squads hit deer | one HP/death/receipt only |
| T18 | two lethal packets same combat tick | one terminal life result |
| T19 | deer death offscreen | single event from simulation, not UI |
| T20 | same display actor respawns at gen+1 | legitimate new life after previous settled |
| T21 | old gen death replayed after Save/load | no new loot/kill receipt |
| T22 | per-kill source and legacy encounter claim both requested | no double payout for same entitlement |
| T23 | reward preview/map difficulty switched | never grants a resource |
| T24 | q=.25 yields NO_DROP on true kill | no-drop receipt persists, no reload reroll |
| T25 | common material q=1 proposal | one hide per eligible death, rare gear independent |
| T26 | reward definition version changed after frozen result | replay original frozen payload |
| T27 | unknown ID in frozen source output | no partial stock update |
| T28 | Warehouse at MAX_SAFE_STACK | pending/reject atomically, no ghost depleted node |
| T29 | two-resource bundle one ID overflow | all-or-nothing, no partial valid addition |
| T30 | crash after stock write before receipt acknowledgment | recover same one logical commit |
| T31 | Save/load repeated100× | identical ledger, node gen, actor life, Warehouse quantities |
| T32 | offline advances beyond respawn due | at most real actor/node events, no idle free windfall |
| T33 | reserve_min/locked changed between node harvest and credit | incoming approved resource not erased; legitimate outgoing rules preserved |
| T34 | old Save2 loaded with new world mode off | empty new ledger, old reward claims unchanged |
| T35 | new Save contains material old client cannot decode | reject safely/backup, never silently drop R11 item |
| T36 | documentation asserts FPS/200–400 mob Android PASS | refuse status; real Godot/Android testing outstanding |

## 6. Required evidence per future test; owner decisions
Future proof must include actual code SHA, Godot4.7.2, fixture save hash, valid R10 actor/worker and path coordinates, real node/monster life and spawn generation, original and final `warehouse_resources`, `world_instance_id`, source receipt and operation idempotency, XP/OneJob/Injury changes, QA stdout/exit codes, and Android/Windows performance evidence where relevant. **None produced by this docs-only work.**
**Owner approval OPEN:** names/IDs and resource tags; source Work+Haul vs node producer design; R10 outer monster tier balancing; common hide q guaranteed1 vs bounded alternate; receipt retention+source-mode cutover. These may be approved as DESIGN without granting code. Code later needs its own fresh baseline, narrow path allowlist, one-writer integrator across SectState/Save/Warehouse/Combat, rollback+focused regression; PR29 untouched until explicitly authorized.
