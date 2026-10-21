# TÔNG MÔN BÁ ĐẠO — B3 V2 PERSISTENT PvE WORLD RUNTIME CONTRACT

**Ngày:** 2026-10-22 · **Trạng thái:** DESIGN PROPOSAL / NO GAMEPLAY CODE AUTHORIZATION  
**Nền code đã đối chiếu:** GitHub main 461caca1171462e0da092f21108c5c1733157ad9 (code public trên remote; không đại diện dirty Windows).  
**Parent design:** docs/design/B3_V2_LIVING_SECT_CONTINUOUS_HUNT_ARCHITECTURE_2026-10-22.md, nhánh docs/b3-v2-architecture-redesign-20261022.  
**Khác biệt bắt buộc:** B3 **không có trận 90 giây, không reset sau WIN, không nối các cuộc battle hữu hạn, không clear wave**, không thả quái từ UI. Combat V2 tiếp tục là công thức và luật gây tác động lên HP. Không CI, không merge, không chỉnh hệ Map, Character Studio, Source A, V5.

> **TEAM AI DEEP DIVE 2026-10-22:** [B3_V2_TEAM_AI_TARGETING_AGGRO_RECOVERY_CONTRACT_2026-10-22.md](B3_V2_TEAM_AI_TARGETING_AGGRO_RECOVERY_CONTRACT_2026-10-22.md) — lựa chọn mục tiêu/aggro/đơn-đa đội/Boss, khoảng cách và skill theo Combat V2, retreat/recovery/auto-resume không cướp One Active Job; state transitions, đề xuất API và test; **DESIGN-ONLY, NOT CODE AUTHORIZATION**.

> **NEW EVIDENCE AUDIT (FOUR ZIP, 2026-10-22):** [Review checkpoint](../handoffs/2026-10-22/TMB_FOUR_REVIEW_PACKETS_TRIAGE_AND_INTEGRATION_PLAN_2026-10-22.md) verified user-supplied B2.4 source ZIP. Contrary to legacy `main` finite-only runtime, local B2.3/B2.4 snapshot already includes an **opt-in continuous_mode** in `MapBattleV2` with no 90-second/empty-monster termination in that mode, individual spawn/removal, stable death/receipt IDs, snapshot v2 supporting v1 reader, and an isolated 6-actor sandbox. **It is NOT pushed/merged/production**; still needs live World/Team AI, authoritative per-kill source and canonical SaveService. Future CODE plans must **reuse/audit this existing kernel patch instead of implementing a duplicate combat engine**. No CODE is authorized by this note.

## 0. Phạm vi quyết định — phân biệt authority chính xác

**LOCKED by owner/current canonical architecture**
- Kiểu PvE: **Evil Hunter Tycoon continuous in-place** + trải nghiệm săn quái Võ Lâm; bãi quái sống độc lập với camera/màn hình, đệ tử tự đi, đánh, cast, nhặt thưởng ở level simulation, hồi phục/săn tiếp. Không giới hạn theo đợt 90 giây.
- Mỗi con quái có vị trí chân riêng, instance/lifecycle riêng, thưởng và hồi sinh riêng. Quái Tinh Anh/Boss có thể tồn tại cùng quái thường; không gộp loot cả wave/trận.
- Combat V2 là **duy nhất** về damage/stat/range/attack interval/learned skill/cast/target RNG/context semantics. Không thay bằng combat JX1. Map farm đơn giản: sàn phẳng + hoa cỏ, không địa hình cản, không navmesh/pathfinding hoặc collision môi trường.
- Team tối đa 6; đệ tử vẫn có One Active Job; Injury 0/1/120 canonical ticks; Tu Vi 30x10 + Luyện Thể 30x10, không reset/cấp tài nguyên không phép; một Kho/unique registry Sect-owned; determinism/save/offline.
- Thông tin tiến độ khác nhau phải có source: tại main PvE finite 90s, B2.4 sandbox local reviewed chỉ có test-drop/clone Warehouse, không có live production payout.

**PROPOSED, not locked:** thiết kế versioned world/schema/API bên dưới, tick ordering, 0.25s global substeps, policy aggro/leash, cấp Boss/mob budgets, participant reward split, offline catch-up cap, anti-churn, loot tables/weights/crafting/equipment tuning.

**BLOCKED until separate CODE packet:** sửa runtime, migrate SaveService/SectState/DiscipleState, biến B2.4 test loot thành production, đổi Combat V2 internals, tích hợp scene/camera/Studio, run Godot QA.

## 1. Đọc chính xác code hiện tại và nợ kỹ thuật

| Nguồn trong main | Sự thật đã đọc | B3 không thể kế thừa nguyên trạng |
|---|---|---|
| map_battle_v2.gd | 0.25s/step; MAX_SECONDS=90; _count_alive(monster)==0 => win; step() stops on all disciple dead/timeout; setup() resets now, actors, pending_casts, skill_ready, events and counters. `ARENA=(0..36,0..20)`, MAX_DISCIPLES=30, MAX_MONSTERS=40 are existing **legacy battle** constraints. | Simply removing MAX_SECONDS will still end on empty monsters; re-setup wipes live HP/cooldowns/casts. Future world has independent actor lifetime and streaming spawn. 30/40 is NOT whole-sect maximum. |
| map_battle_snapshot_v2.gd | VERSION=1; saves one encounter as Godot Variant bytes in base64 to avoid floating precision drift; restore **rejects time > MapBattleV2.MAX_SECONDS** and validates bounded roster. | Must introduce separate versioned WORLD snapshot; do **not** loosen legacy parser and silently reinterpret old saves. Preserve exact numeric representation and validation. |
| map_battle_v2.gd skill details | _try_learned_damage_skill currently considers already-learned authored direct damage skills only; cast/projectile travel via pending_casts; AoE max 3 targets in the current engine; _deal_direct emits downed and linked HP. Debuff/Burn/Dash and other proposed mechanics may be deferred. Presentation event list capped at 2400. | Don't claim actual DoT/complex skill engine exists in this main. Future DoT gets separately authored test; kill events cannot be sourced solely from capped UI events. |
| hunting_pve_run_v2.gd | begin/advance/finish/claim, actor reservation via active_pve_encounter_id; no linked DiscipleState pointer in battle; _settle_terminal routes HP, down => HP1/Injury1 +120 ticks and auto-return. | Existing encounter completion cannot be B3 continuous life-cycle. Need world occupation marker/migration preserving this behavior and never leaving actors stranded/double injured. |
| simulation_scheduler.gd | One-minute step; legacy COMBAT calls CombatSystem.resolve_encounter, LOOT writes personal pending_loot; V2 active PvE causes regular disciple action short-circuit. | No overlapping autonomous P2 hunt award or duplicated passive Tu Vi/work. Add world duty as an explicit alternative execution mode behind migration. |
| simulation_runtime_clock_v2.gd | Canonical 60 wall seconds = 1 scheduler minute; stores runtime_last_wall_unix and runtime_unconsumed_wall_seconds; negative time refused; offline max_steps can limit work. | New quarter-second cursor MUST be one child timeline owned by clock; must account for stored remainder/backlog, never process same minute/substep twice. |
| warehouse_system.gd | resource registry; add() checks positive amounts/max_safe_stack; available_quantity() accounts for lock/reserve on **consumption**. | Credits use valid registered source/material; outflows honor reserve. Need atomic multi-channel receipt, no secondary loot warehouse. |
| save_service.gd | CURRENT_VERSION=2, writes temporary staged payload, load validation, backup. | New world save migration and receipt/sector serialization have separate version; never stamp new world payload into v2 if reader discards it. Don't claim crash-proof until actual fs fault tests. |
| organization_system.gd, workforce_system.gd, decision_system.gd | Organization max team 6; work commands may change current jobs; DecisionSystem.evaluate/choose_region mutate last_decision. | Admission preflight must be pure and never silently cancel Mine/Forest/Spirit Field/Alchemy/Body jobs. GUI previews cannot call state-mutating decision functions. |

### Implementation traps specifically banned
1. Delete only 90s check and rename battle to world — **FAIL**.
2. Run new MapBattleV2.setup() after each killed group, or spawn a duplicate monster per team — **FAIL**.
3. Use only visible animation death, 2400-event UI array, or pickup icon as authority — **FAIL**.
4. Replenish actor HP, pending_casts, skill cooldown, RNG or world positioning when a slot respawns — **FAIL**.
5. Credit loot from legacy CombatSystem, V2 encounter claim and B3 world kill for the same source — **FAIL**.
6. Assume field/ore worker available because GUI shows IDLE while its timer/plot reserves it — **FAIL**.
7. Promise future DoT/Boss cooperation/equipment affix mechanics exist just because they are in specs — **FAIL**.

## 2. Logical ownership graph: ONE world owner and ONE battle-law kernel

~~~text
SimulationRuntimeOwnerV2 / one SimulationScheduler / SimulationRuntimeClockV2
       |  canonical world time + approved owner commands
       v
PersistentPveWorldService (new opt-in mode, world session authority)
       |--- PvEWorldState + RegionInstanceState + SpawnSlots
       |--- TeamDuty, ActorRuntime, Targeting/Engagement, schedules
       |--- CombatV2WorldStep (shared Combat V2 rule implementation)
       |     |--- canonical stats, movement/range, basic attack timing
       |     |--- skill cast/projectiles/AoE/guard/buffs that ACTUALLY exist
       |     '-- gameplay HP transition + participant contribution
       |--- MonsterLifecycleService (death/spawn deadline per slot)
       |--- KillRewardCoordinator -> immutable RewardReceipt -> canonical mutations
       '-- WorldSnapshotV1 -> SectState/SimulationState -> SaveService
                     |
                     v
             read-only WorldViewSnapshot / GameplayEventStream
                     |
              Map renderer | V5 UI | Character Studio rig resolver
~~~

**Kernel sharing**: The new world driver must call a refactored shared Combat V2 rule component, or run an equivalent world mode in the same kernel source. It may change battle **lifetime/actor admission** but cannot copy damage math into a second implementation that drifts later. Legacy MapBattleV2 finite mode remains intact as an opt-in legacy adapter for old save/tests. The B2.4 editor can supply validated spawn/loot data once checked, not runtime credit authority by itself.

**Subtleties**:
- The world is the sole owner of **each monster's HP and generation**; teams are real actors in the same world actor index, not nested private battles containing clones.
- Party_id is a grouping property, **not separate monster world copies**. Multiple teams may hit one monster; one HP and one death. Do not impose an artificial mutual-exclusion kill lease that prevents legitimate shared damage.
- A killed monster instance is logically retired; ID **never reused** for respawn generation. Pending projectile at old generation must not hit new generation even at the same spawn point.
- Visuals may be hidden or switched without world reinitialization. A sprite object and an authoritative entity are different things.

## 3. Versioned state schema, identities and invariants (proposed)

All fields below are **contract candidates, no actual file or SaveService migration done**. Data structures may be optimized internally if invariants hold.

### 3.1 WorldSnapshotV1

| Field | Meaning / validation |
|---|---|
| schema_version=1; runtime_mode=B3_CONTINUOUS_WORLD | Explicit opt-in, never auto-activate for old saves/runs. |
| world_id; region_instance_id; region_def_version; content_hash | Stable run/world instance and authored content provenance; reject stale/malformed IDs or unknown content except explicit migration. |
| absolute_step: nonnegative int64; scheduler_minute_cursor; remainder_substeps | One time cursor, not second paying clock; no negative/backward processing. Proposed 240 substeps/min at 0.25s each. |
| combat_rng_state; world_spawn_rng_state; reward_seed_domain | Deterministic, separately domain-seeded streams. RNG order stable within event sort, no UI sampling. |
| monster_slots[stable slot id] | source species/tier/content, current generation, ALIVE/DEAD/RESPAWN_PENDING, current instance id, respawn_at_step, failure/status reason. |
| actor_runtime[unique entity id] | disciple_id/team_id or monster instance ref, foot_xy, facing, HP/max HP, active status, basic/skill ready_at_step, guard/buff timers, pending cast reference, movement intent. |
| team_duties[canonical team id] | policy ID/revision, roster ID reference, active location, duty/status/return request/supply state, no duplicate roster authority. |
| pending_casts[event id] | caster/source generation, immutable target entity ID or AoE center, due substep, skill/content version, real V2 effect properties; no stale retarget to new monster generation. |
| pending_events/agenda | Sorted spawn/respawn/skill/death/retreat due times and cursor. Persistent gameplay queue is separate from throwaway UI VFX/history. |
| receipt ledger + provenance watermark | PENDING and COMMITTED immutable reward envelopes, item IDs and last settled generation per slot; compaction only with proven replay protection. |
| lifecycle/adapter_version; last_save_barrier | Can restore deterministic world state and resolve/hold missing content safely; no direct Godot object references/Character Studio resources in authoritative save. |

### 3.2 Identifiers and uniqueness

- **monster_instance_id = world_id/region_instance_id/slot_id/generation**. A respawn is a new generation with its own id, even for the same species, position or art rig.
- **kill_id = monster_instance_id + one canonical death transition**; exactly one Killed event after HP >0 to HP <=0.
- **reward_receipt_id = namespace(B3_WORLD_KILL) + kill_id**. Not legacy V2 encounter_id or P2 pending_loot identity.
- **actor_id for disciple = persisted disciple_id**, not generated by UI or sprite; TeamState canonical membership the reference. One disciple cannot live in two worlds/teams or active jobs.
- **world_event_id** monotonic sequence within world plus absolute substep, for UI de-dup; does not grant resources. Cast events refer to an unambiguous **caster generation**; stale projectile/AI targets cannot accidentally hit a respawn.

**Validation**: no two current LIVE instances per stable slot; no duplicate actor refs; DEAD cannot be targetable, cannot carry live cast source if V2 rule cancels caster on death; receipt source matches slot generation exactly; receipt COMMITTED cannot be re-rolled; new generation increments monotonically. Missing old content must BLOCK spawn/reward and retain original state for repair, not silently mint fallback loot.

### 3.3 Slot life-cycle

~~~text
UNINITIALIZED (validated source)
   | spawn_at eligible global step
   v
ALIVE (one entity with HP, skill cooldown, foot position, target)
   | authoritative HP >0 -> <=0, once
   v
DEAD_PENDING_REWARD (freeze kill source + attribution)
   | ledger PENDING immutable, do not reroll
   v
RESPAWN_WAIT (old entity no longer targetable, deadline persisted)
   | when due, validate slot/content/budget, generation += 1
   v
ALIVE (NEW monster instance ID, NEW HP & allowed initial cooldown)
~~~

An absent/invalid source is **BLOCKED_SOURCE**, not a fallback guaranteed drop. World continues for other monsters. Respawn when no actors view the region is scheduled by state time, not sprite lifecycle. A due slot with capacity blocked remains PENDING without unbounded spawn backlog. Zero respawn interval must be validated/handled against same-tick infinite loops; exact minimum value is OPEN, not a production balance lock.

**Elite/Boss** may use different authored slot rules or rare opportunity event gates. These are *not* injected out of nothing by a fixed "5 battles" rule; species/tier/realm spawn table and boss world ownership must exist first.

### 3.4 Disciple/Team life-cycle

~~~text
AVAILABLE → [preflight] PREPARE → TRAVEL → PATROL/SEARCH
        → ENGAGE (Combat V2 in living world) → PATROL/SEARCH ...
        ↘ if injury/hp/supply/retreat/owner STOP: WITHDRAW → RETURN → RECOVER/RESUPPLY
        → AVAILABLE or AUTO_RESUME (only if policy and eligibility allow)
~~~

World has **no** WIN, DEFEAT, TIMEOUT, CLAIM screen. Team exits/individual Injury are not world terminal states. Other teams/mobs continue while one team returns or loses all available members.

Safety precedence: genuine Injury/HP and existing work reservations; explicit owner directive subject to eligibility; team policy; personal preference. A forced STOP prevents *new* action admission but must resolve already legal casts/damage/death/receipts with an explicitly defined withdrawal barrier (OPEN micro-timing; test before code). Team membership change while actively hunting is a command transaction, not a silent actor teleport.

No regular GUI or world manager gets to call DecisionSystem.evaluate()/choose_region() as a "pure" preview. Risk or target scores can be factored into a no-side-effects predictor for actual dispatch.

## 4. CombatV2WorldStep contract and ordering

### 4.1 API candidates (typed proposal, not GDScript implementation)

~~~text
read_only_world_snapshot(state, world_id) -> WorldViewProjection
validate_world_command(state, command) -> {ok, reason, conflict_ids, policy_revision}
submit_world_command(state, command_id, expected_revision) -> CommandReceipt
advance_world_to(state, authoritative_target_step, budget) -> {status, processed, backlog_cursor}

lookup_actor(world_id, persistent_actor_id) -> ActorState
add_actor_validated(world_id, actor_record, source_kind) -> AdmissionResult
remove_actor_for_return(world_id, disciple_id, expected_actor_revision) -> ReturnResult

spawn_due_slots(world_id, step, budget) -> [new_monster_instance_id]
evaluate_actor_intents(world_id, step) -> [ordered_action_proposal]
combat_v2_world_step(world_id, step, actions) -> [domain_events, next_actor_state]
on_lethal_transition(monster_instance_id, step, damage_provenance) -> immutable KillEnvelope

plan_reward_once(kill_id, source_version) -> Receipt(PENDING)
commit_reward_once(receipt_id, SimulationState) -> {COMMITTED | RETRY_PENDING | BLOCKED}
save_canonical_world(world_id, state, SaveService) -> SaveResult
restore_canonical_world(saved_state) -> {valid_state | fail_closed_reason}
~~~

**Rules:** External callers may issue **commands**, not mutate actor dictionaries/HP/respawn timers directly. Functions that grant world time / move actors / apply rewards only run in one canonical owner. Read-only preview must return detached copies and be mutation-free. All commands have idempotent IDs and revision preconditions; duplicate UI taps and replays do not double-deploy/stop/give loot. API names/shape NOT LOCKED.

### 4.2 Deterministic step order recommendation (OPEN until code design)

**Proposed single global tick agenda** (stable IDs, stable float/Variant, no Dictionary insertion reliance):
1. Accept validated due commands/economic minute-boundary status (see section 7) at a **documented priority**. No world event advances from UI render calls.
2. Process due **respawns and scheduled world events** at canonical timestamp with authored capacity constraints; new generation is created only once, before actor intent computation for that step.
3. Release **due pending casts/projectiles/AoE** via Combat V2 V2 semantics; never retarget a newly respawned generation by old entity ID. Apply HP and lethal transitions in deterministic order, before new actions if preserving existing MapBattleV2 order.
4. Evaluate actor intents in stable unique ID order: follow V2 AI/role/skill readiness; movement is straight toward targets on flat ground with V2 range and move-speed behavior; no navmesh. Apply Combat V2 effects and HP transitions.
5. For each new Killed source, enqueue immutable individual kill receipt and schedule respawn deadline; reward coordinator processes eligible PENDING receipts independent of UI event-history cap; applying reward must not mutate Combat V2 RNG.
6. Resolve disciple HP0/return/recovery and occupation release **using Injury 0/1/120** and the one scheduler/tick owner; no double terminal settlement.
7. Publish compact read-only delta/event stream, trim VFX history for memory **without** deleting authoritative receipt/replay protection.
8. At a defined time barrier, persist core snapshot/ledger/warehouse/disciples in **one SaveService transaction**, not separate saves per subsystem.

**Critical ordering correction:** Existing MapBattleV2.step() increments now then _release_casts() then iterates sorted actors; switching this order without checking parity changes combat outcomes. The above recommendation intentionally keeps due-cast-before-new-actor-actions. Respawn-before-cast, scheduler boundary and injury timing need simulation parity tests and owner approval before final API freeze.

### 4.3 Existing mechanics / future mechanics firewall

- **CURRENT kernel implemented:** ordinary direct hits, crit/lifesteal via CombatStatsV2, learned direct-damage skill with cast/projectile travel, boss/elite telegraphed area slam, healer/guard actions and limited mage AoE. MAX_TARGETS_AOE=3 in current runtime. Refer to actual source version when extracting kernel.
- **MAY BE NOT IMPLEMENTED in main:** full DoT, advanced control/dispel, direct player movement skill, universal status engines, Chân Văn effects. Design kill envelope is generic enough, but these need separately scoped implementation; tests with synthetic DoT do **not** establish live DoT PASS.
- A combat parity fixture compares **same actors, identical seed, action order, positions and step window**: damage, HP, cooldown, cast release and RNG checkpoint must match legacy MapBattleV2 while equivalence is meaningful; added world spawns change population and therefore expected action choices, so do not compare those as identical encounters.
- The rule says no rewriting Combat V2 formulas, **not** "no legal refactoring of battle loop". Extract rule engine/wrapper with focused parity coverage, preserve legacy version and authority.

## 5. Multi-team combat, targeting and bosses

### 5.1 Same live HP index for all teams

A monster is ONE live instance regardless of how many parties can see/hit it. Multiple teams participating in one zone share the authoritative actor index, positions, target range and HP. World actor update is scheduled in one globally ordered queue; no duplicate target instance per team.

When two attacks at same substep deal lethal:
1. Apply first in stable event order: HP>0 → 0 emits one Killed.
2. Apply later: target already DEAD, no second HP transition/reward; do not aim automatically at new-generation monster.
3. Both attacks may contribute to participation **only under an authored rule that preserves attribution**; no double Sect material payout regardless.

### 5.2 Targeting & AI policy

**Default design proposal**: aggro only where monster/AI source supports, target score considers distance-to-foot, threat/risk, damage/survival role, player hunt preference, elites/boss opportunities, retreat/HP, leash/source availability. Rule computation must not introduce a new Combat Power as damage/stat authority; optional strength estimates are advisory.

- Move/attack/skill: actor follows real V2 attack range, move_speed, cast time, basic interval, skill cool-down. UI's animation state is inferred from events; it does not open another damage window.
- No physical obstacle/pathfinding, but **no teleport to target** and no sprite-center target authority; move on consistent 2D world coordinates/clamped region bounds.
- A monster dragged away from its spawn point may need an aggro leash/reset design. **Leash radius, HP reset policy, return speed and exploitation prevention are OPEN**; cannot change encounter fairness while designing only.
- Team autonomy: one team hunter can pull 1–N nearby mobs as permitted, not forcibly snap to a 6-person formation; individual positions and attacks remain real.
- Boss: normal/elite/boss tiers support authored spawn conditions; **multiple teams on one boss share HP and one kill**. Personal Contribution/Tu Vi attribution, first-tag vs participation, anti-leech eligibility and unique gear distribution all remain **OPEN**; do not invent hardcoded "last hit owns Boss" rules.
- In first CODE pilot, one world, one team, several mobs. Multi-team sharing comes after ledger/world state correctness; do not pretend a per-team lease allows shared boss damage.

### 5.3 Session and command conflicts

Policies may use Sect/Team/Disciple layers, but a team member's canonical assignment is unique. A hunter cannot simultaneously produce Mine/Forest/Field/Alchemy/Body output. Admission checks existing active_v2_pve, live work_cycle/timed job/plot/body reservation and Injury before any mutating command. If blocked, reason WAITING_OCCUPATION or RECOVERING, never cancel old paid jobs automatically.

Team reassign/removal/equipment switch while a pending attack or boss reward exists requires defined command barrier. Protect old completed kills/receipts; avoid orphaned actor/cast and duplicate personal reward. Lock/reserve item rules remain canonical, no separate team bag.

## 6. Per-kill rewards, progression and save exactly-once

### 6.1 One source → one immutable receipt

~~~text
Combat V2 lethal on monster_instance_id
   ↓ validate alive-to-dead + generation + content + participants
KillEnvelope (source species/tier/realm, world step, roll seed domains)
   ↓ deterministic resolve ONCE from approved production table
RewardReceipt PENDING (stacks, unique items, Sect/personal stones,
                       Tu Vi, skill mastery/Contribution candidate deltas)
   ↓ preflight ALL affected canonical recipients / amount ranges / IDs
   ↓ atomically apply resource additions, item creation, currencies,
                        personal progression and receipt COMMITTED
   ↓ canonical SaveService persists whole accepted state
World view publishes committed reward visual/notice (not a credit authority)
~~~

Separate **kill identity**, **combat participation evidence**, **source table version**, **personal attribution** and **wallet partitions**. A killed monster with no authorized payout table may have a kill for combat world purposes, but **must not** mint fake loot; mark NO_AUTHORIZED_TABLE/BLOCKED and preserve trace for later authorized resolution, not silently replay with newly authored table and reroll. No hidden boss guarantee or per-kill reinterpretation of old 4-successful-encounter guarantee.

**Atomicity** here means in-memory state mutation is staged or rollback-safe across stacks, unique registries, currencies, personal XP/mastery, contribution and ledger status, then persisted within a single verified SaveService snapshot. It is **not proven** by B2.4 sandbox clone, and it is not proof of arbitrary power-loss durability without fault tests. If SaveService save fails, do not acknowledge durable payout or advance replay protection independently; upon restart replay from last valid coherent snapshot and deterministic world/time cursor. Prefer UI labeling unsaved progress as provisional if display precedes a successful durable save.

### 6.2 Receipt fields, replay logic, resource guarantees

Suggested immutable body:
- id, world/zone/slot/generation, species/tier/realm, content_version/table_version;
- step, combat_source_event_id, attributed_disciple_ids + participation evidence/checksum;
- combat-independent reward_seed, rolled_stacks, rolled_unique_item_templates+deterministic-instance-IDs;
- sect_stone_delta, personal_stone_deltas, TuVi/mastery/Contribution deltas (after actual canonical eligibility rules);
- receipt_hash, status(PENDING/COMMITTED/BLOCKED), applied_at_step, save_generation.

Receipt state machine: ABSENT → PENDING immutable roll → COMMITTED exactly once, or BLOCKED retaining unmodified payload and reason. On re-entry, COMMITTED is no-op; PENDING commits same frozen deltas (do not reroll); conflicting receipts for same kill ID fail closed.

**Validation**: resource registry ID real, nonnegative quantities within MAX_SAFE_STACK; item instance identity unique + legal Sect ownership; personal gains map to existing disciples, current progression limit/realm; sect/personal money arithmetic checked; source/participant not from UI; no stock reading from legacy personal pending_loot; Warehouse available_quantity locks/reserve for **spending**, not illegal input filtering on rightful incoming loot. No item/XP duplication from repeated cast or save/reload.

### 6.3 Old modes retained, but mutually exclusive credit

| Current authority | Actual payout timing | Future treatment |
|---|---|---|
| P2 legacy scheduler COMBAT/LOOT | Legacy personal pending loot and later storage/selling | Do not delete/migrate pending loot on feature flag enable; existing actions must settle through legacy path, cannot also receive B3 reward. |
| HuntingMapV2 + HuntingPveRunV2 | Claim after a finite WIN encounter, old Linh Tủy every 4 victorious claims rule | Keep old saved encounters in finite mode to completion/claim; do not count per-kill deaths as encounter win. |
| B2.4 opt-in sandbox | Synthetic per-kill in cloned Warehouse | No live economy permission or SaveService durability. Reuse only proven validation/receipt logic after audit. |
| B3 production world | Authoritative individual monster HP0, immediately create one kill receipt | Source of truth when explicitly enabled per migrated world; no duplicate legacy claim, no loot bag. |

## 7. ONE clock, online/offline equivalence, event batching

### 7.1 Candidate time encoding

**Currently LOCKED runtime bridge:** 60 wall seconds = 1 economy scheduler minute. Existing battle uses STEP_SECONDS=0.25. Proposed world maintains **absolute quarter-second index** as integer and projects economic scheduler minute boundaries every 240 substeps; this is a **DESIGN proposal**, not a new approved rate or permission to introduce a second authoritative ticker.

Proposed clock fields: last_processed_absolute_step, saved_runtime_clock_minute, saved_fractional_accumulator, backlog_target_step, mode/version. Canonical owner serializes wall-time injection; no separate render FPS driver and no extra "work" scheduler. A save at 07:15:32.75 must restore exact cast/respawn deadlines, not round to nearest minute. Existing runtime_last_wall_unix integer-second precision might require compatible migration to preserve subsecond accumulator; must not double-account old unconsumed seconds.

**Minute boundary contract (proposed):** process economic/minute actions once at the correct boundary and order relative to combat completions deterministically, e.g. on transition from world-step 239→240. This exact priority is OPEN because injury recovery/job release/spawn/loot at boundary may affect eligibility. Tests must freeze what "at step 240" means before production.

### 7.2 Offline behavior: correctness tiers

**Tier A (first B3 production pilot):** continuous world sim only when actual canonical time can be stepped/replayed safely. Offline elapsed backlog may be processed with CPU budget until caught up; while lagging show CATCHING_UP and do **not** repeatedly grant same time. Do not award estimated per-hour drops as a substitute for real combat.

**Tier B (later):** event-skip algorithm for periods in which outcomes are provably identical to 0.25s stepping, e.g. empty fields with known future respawn deadline or actors safely idle. Jump to next event without skipping legally due damage/cast/actor intention.

**Tier C (after measured equivalence):** exact deterministic batched simulation for 1k–3k players. Must compare kill IDs, loot identities, RNG, HP, supplies, Injury, cooldown and job reservations against full step replay. No blanket "elapsed * expected kills" payout. If full equivalence at huge offline duration is impractical, cap processed backlog and persist remaining backlog with **no credit for unprocessed time**; owner chooses a visible product policy. Backlog limit/rates not locked.

**Rule for clock rollback:** negative wall time is rejected as existing SimulationRuntimeClockV2 does; guard repeated time injection, online vs offline transitions, save while backlog pending, and any time acceleration option (separately authorized).

### 7.3 Cost scale and map loading

- Simulation actor index partitioned by world/region/zone cell; no per-frame all-world full scan for 1,000–3,000 disciples.
- Fixed substeps only for truly active combat actors; event agendas for respawn and idle actors; never scale by rendering every rig. Scene camera move/hide does not cancel future gameplay of **already active authorized hunts**.
- Spatial nearest-neighbor indexing or coarse cells are optimization choices, NOT obstacle/pathfinding. Require same targeting tie-breaks as baseline.
- Five teams/30 disciples vs 40 monsters is a relevant **legacy focused stress fixture**, not the ultimate population/monster budget.
- Boss and multiple teams share one world update owner; partitioning must not create two independent copies of same monster and double payout.
- Persist only compact source IDs, positions and authoritative state. Source A files/images, animation frames, editor previews and VFX events do not belong to world save.
- Metrics: world actor/mob count, active region count, processed substeps/sec, backlog seconds, save size, immutable receipt/commit count, RAM peaks on Android + Windows 8GB, offline resume delay, source-perf regression.

## 8. API adapter with existing Map / Character Studio / Source A owners

**Map owner (report ACTIVE by user)**: owns flat ground, decoration, camera pan/zoom, fog/scene projection, authored world-to-canvas mapping and visible spawn anchors if available. B3 does NOT edit their scenes, tiles, layout, camera, click handling or Godot project registration.

**Character Studio owner (report ACTIVE by user)**: owns rig/clip/skin outfit library/presentation mapping. B3 outputs only stable actor ref, monster species, foot XY, heading, health fraction, visible gameplay cast/hit/death events and skill id. Studio decides actual sprite/animation; absence of actual mining/chopping/attacking clip cannot fabricate combat.

**Source A SA-LIB owner**: runs independent converter/QA/resolver pipeline subject to local RAM safety. B3 only reads later approved pack metadata; never calls converter on runtime/preview.

**V5 combat visual owner**: renders events, HUD, actor movement, camera/shadows. VFX can repeat/drop frames without changing world HP/RNG/reward. Map may show one actor and many monsters; all others exist in same world state.

**B2.4 Spawn/Loot Studio**: authoring/schema validator on separate sandbox. Content ID + table version + independently seeded receipt logic can be migrated after static/diff QA, not assumed compatible production. No B2.4 runtime re-run or worktree changes from design task.

### Narrow wire contract proposal

~~~text
Map/Content → backend:
  zone_id, zone_definition_revision, world_rect,
  spawn_anchors[{stable_spawn_point_id, foot_xy, species_pool_id, tags}],
  traversable_flat_rect (no walls/navmesh)

Backend → Map/Studio presentation:
  world_id, absolute_step, actor_id, source_species_or_disciple_id,
  rig_catalog_ref_when_known, foot_xy, facing, visible_hp_ratio,
  action_state, cast_id, skill_id, event_seq, VFX-only loot hint

UI command → backend:
  command_id, expected_world_revision, team_id, policy_id,
  preferred_region, risk/return/target/stop flags
~~~

No Source A `Texture2D`, animation resources, rig bytes or scene nodes are in persistent world data. Back-end does not decide which Spine rig is female, equipped skin, animation clip timing VFX or camera position. UI preview is read-only and causes no loot.

## 9. Worked edge-case matrix — OWNER-LOCKED EXPECTATIONS vs OPEN mechanics

| Case | Correct outcome | Gate/review requirement |
|---|---|---|
| Last currently alive monster dies at 89.9s | **No WIN, no reset**. Existing A gets receipt, world keeps running, old slots wait independent respawn. | Fails if legacy _count_alive(monster)==0 branch executes in world mode. |
| World passes 90s, 180s, 1h | No timeout/payout multiplier; actor HP/cast/cooldown/positions persist. | Snapshot of hours of gameplay must load; old v1 battle snapshot remains limited in legacy mode only. |
| A dead, B alive, A respawn | B and team remain in combat; A' is new generation and independent. | Deterministic due time; old A receipts aren't regenerated. |
| Projectile fired at A, then A dies, A' respawns before projectile arrives | Projectile cannot hit A' by recycled slot ID; target old generation is DEAD. | Generation-stable target ID. |
| AoE kills two mobs same 0.25s frame | Two distinct kill keys/receipts; none lost by MAX_EVENTS cap. | Synchronous domain death events, stable sort. |
| Two teams hit same Boss at same moment | Shared one HP; only one terminal kill/sect loot, personal split **OPEN**. | Multi-team attribution test before cooperative Boss activation. |
| Member under Mine/Field/Body timer ordered into hunt | Request WAITING_OCCUPATION unless explicit allowed safe transition; no vanished production. | Existing GP-02B1/02C1 focused guard tests; pure preflight. |
| Injury1 while team continues | Injured member leaves action, recovery at+120 ticks; other team members/world continue if eligible. | Separate HP/Injury/admission receipts. |
| Camera pan/close app / studio rig missing | Source A visual may fail/placeholder but gameplay state/loot unaffected. | Viewed/unviewed parity, fallback not content reward. |
| Save before/after death/credit/respawn | Same monster generations, resources/gear/personal gains and RNG on replay; 1 reward per generation. | Fault injection in canonical SaveService, no negative deltas. |
| Legacy save v2 has ongoing finite encounter | Continue old finite mode and encounter-level claim; no B3 payout overlap. | Explicit version/mode migration test. |
| Missing loot table or resource registry key | No fabricated material; blocked source/receipt retains reason; world can keep legal combat. | Fail closed; content authoring fix separate from live gameplay. |
| Event queue reaches 2400 | UI VFX history may roll/trim, canonical Killed/receipt processing never stops. | Sustain long-duration simulation test. |
| 24h offline on phone with limited CPU | Saved backlog; no claim unprocessed monsters or double-spend; UI honestly shows catching up if policy so chooses. | Offline budget and stop policy **OPEN**. |
| Spawn point congested / monster leash exceeds region bounds | Deterministic postponement/return rule after owner approves thresholds; never infinite same-tick loop. | OPEN balance/geometry policy, bounded queue. |

## 10. Independent CODE packets recommended (all NOT authorized)

Scope boundaries intentionally avoid active Map/Character/Source A owners. Every packet requires fresh main/worktree audit, exact parent SHA, allowed paths, prohibition list, rollback, migration, one CODE writer and focused tests. No packet may auto-merge.

| Packet | Scope/result | Approval/gates |
|---|---|---|
| **B3-W0 Contract audit / frozen fixtures (DOCS ONLY)** | Reconfirm authority, cite current APIs, define time/identity/source/loot fixtures and sign off open clock/session semantics. | This document provides proposal only; no GoDot QA claim. |
| **B3-W1 Pure world state and spawn** | New opt-in world/zone/slot/generation state, deterministic spawn/respawn and validation, no COMBAT payouts; no map scene or core save changes unless separately authorized. | Focused headless: 2 independent slots, death/respawn, missing source, stable order, 0 vs >90s. |
| **B3-W2 Shared Combat V2 continuous kernel** | Refactor common Combat V2 attack/skill math usage without second combat engine. New actor admission/retire/targeting/step for living world; no legacy WIN/90s, old encounter branch untouched. | Hardest gate: parity on same seeded fixed roster, casts/projectile/AoE, one lasting world beyond 1h, no reset, legacy finite tests pass. |
| **B3-W3 Reward + State/Save integration** | Authored **one** production source, one real kill receipt, mixed reward channels when explicitly authorized; SaveService migration, Warehouse/unique/personal deltas atomic. | Two writers forbidden; one integration owner, rollback/corruption/overflow/duplicate/mid-death save tests; no pilot test-only free loot. |
| **B3-W4 Continuous hunt duty/team AI** | Team command/preflight, patrol/target, fight/return/recover/auto-resume, no occupation theft; optional FarmOrder priority not default stop. | Focused Injury/One Active Job, multi-team shared boss HP without unapproved split, no AI preview side effects. |
| **B3-W5 Clock/offline + scale** | Single quarter-second clock child of canonical runtime, persistent accumulator, save event scheduler, measured safe offline batching; one region then multiple regions. | Online/offline equality, multi-day backlog semantics, Android memory/time; no estimated loot minting. |
| **B3-W6 Visual integration after owner handoffs** | Consume agreed world view stream in Map/Studio/V5, no UI authority. | Requires Map and Studio owner outputs, no concurrent overlapping code; 1280x720 visual/device review owner-owned. |
| **B3-W7 Content/balance/gear** | Author multiple region/spawn/loot sources, Elite/Boss, direct gear/forge links, later 10/12/24 item migration and rates. | Separate authoring/balance approval; no forced 3-region/5-recipe product limit. |

**Practical dependency warning:** W2, W3 and W5 interact strongly through actor identity, world time and save. Implement as contracts in order, and use **one authority/integration writer** whenever shared files are touched. W1 tests can use fake clock and no live payout, but **do not** claim production PvE from W1 or W2. W4 does not grant a second damage/loot source.

**Recommended next real CODE packet after owner approval:** W1 *only* if B2.4 ZIP/code adapters rechecked and source contracts precise; or combine W1/W2 into one authorized owner packet after reviewing collision, not automatic authorization from this document. Old legacy 90s may remain for old saves until explicit migration, but **no 90s limit exists in B3 target world**.

## 11. Spec acceptance checklist (design, NOT Godot PASS)

- [x] In-place world, no encounter chain, no 90s/wave terminal, actor state persists: owner lock reflected.
- [x] Individual spawn, kill, independent respawn and boss/elite source; one HP per instance across teams.
- [x] Shared Combat V2 formula boundary, no phantom DoT or VFX-as-gameplay.
- [x] Typed persistent world schema, domain events, API candidates and replay identity.
- [x] Single clock architecture, online/offline candidate/caveats; scale with bounded backlog policy.
- [x] Exactly-once receipt includes Warehouse, unique, personal progression/economy, canonical save, with explicit durability limitations.
- [x] Multi-team/partial down/retreat, existing occupation/Injury and previous legacy reward isolation.
- [x] Map/Character Studio/Source A/V5 collaboration contract without editing their branches.
- [x] Focused edge-case tests + CODE packets, explicitly NOT authorized.
- [ ] Owner approval of proposal details: world clock substep / event order / auto-resume policy / Boss participation / offline cap / monster leash.
- [ ] Live ZIP/worktree audit and separate exact-sha CODE authorization.
- [ ] Godot focused tests, user gameplay/visual/Android acceptance after code implementation.

## 12. Authority references audited

GitHub main @ 461caca: AGENTS.md; docs/GAME_SYSTEM_ARCHITECTURE.md; docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md; docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md; docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md; docs/COMBAT_STATS_V2_SPEC.md; docs/COMBAT_SKILLS_V2_SPEC.md; docs/WEAPON_EQUIPMENT_V2_SPEC.md; docs/EQUIPMENT_SETS_V2_SPEC.md.

Actual source inspected: godot/src/simulation/combat/map_battle_v2.gd, map_battle_snapshot_v2.gd, hunting_pve_run_v2.gd, hunting_map_v2.gd; godot/src/simulation/core/simulation_scheduler.gd, simulation_runtime_clock_v2.gd; godot/src/simulation/ai/decision_system.gd; godot/src/simulation/organization/organization_system.gd; godot/src/simulation/workforce/workforce_system.gd; godot/src/simulation/resource/warehouse_system.gd; godot/src/simulation/equipment/equipment_system.gd; godot/src/simulation/save/save_service.gd.

Handoff: docs/handoffs/2026-10-21/TMB_FOUR_ZIP_REVIEW_AND_NEXT_CODEX_2026-10-21.md; parent B3_V2_LIVING_SECT_CONTINUOUS_HUNT_ARCHITECTURE_2026-10-22.md.

**No runtime/gameplay/Map/Character Studio/Source A modification performed.**
