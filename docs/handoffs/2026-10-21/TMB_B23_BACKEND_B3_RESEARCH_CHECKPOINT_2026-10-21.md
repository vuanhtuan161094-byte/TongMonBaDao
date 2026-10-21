# TÔNG MÔN BÁ ĐẠO — B2.3 BACKEND AUDIT + B3 RESEARCH CHECKPOINT

> **LATEST OWNER/FOUR-ZIP UPDATE — 2026-10-21:** B2.3 sandbox pilot was reviewed: ZIP SHA-256 `f9a934abbc9aa8712296447c466897ef686f27720caddcd2a32b736a9b12408e`; seven focused/regression tests reported PASS. Its live SaveService hook, production per-kill tables and true Editor manual acceptance are *not* complete. **P0 is now B2.4 playable/observable sandbox**, Codex Prompt 01 **RUNNING per owner**; **P1 Source A library** Codex Prompt 02 **RUNNING per owner**, but any RAM-heavy conversion/QA must wait for safe hardware gate and must not overlap B2.4 Godot runtime. **V5.1/Character Studio V2 remain HOLD**. The B2.3-original statements below are retained as research history and may be superseded by the ZIP checkpoint. See `TMB_FOUR_ZIP_REVIEW_AND_NEXT_CODEX_2026-10-21.md`. No local worktree/Codex task progress can be directly asserted from GitHub.

**Date:** 2026-10-21 · **Status:** READ-ONLY CODE AUDIT + DESIGN PROPOSAL; NOT CODED, NOT RUNTIME-TESTED · **Research base:** `main` @ `461caca1171462e0da092f21108c5c1733157ad9` · **Document branch:** `docs/tmb-status-20261021-v5-sa-lib`.

> **HISTORICAL OWNER PRIORITY (BEFORE FOUR-ZIP REVIEW; SUPERSEDED ABOVE):** 1 main task = B2.3 Spawn & Loot Runtime; 1 secondary task = Source A library conversion only when safe hardware gates permit. V5.1 Combat/Character Studio V2 hold. No user Windows requirement. No merge, CI/FULL, balance lock, Source A metadata upload, or gameplay change is authorized by this research note.

## 1. Findings from actual GitHub main code (not the unavailable local B2.3 worktree)

| Component | Main-code observation | Consequence for B2.3 |
|---|---|---|
| `MapBattleV2` | `setup` accepts max 30 disciples / 40 monsters, 6 per party. `step` stops once all monsters die or all disciples die or timeout. `_deal_direct` emits a `downed` event when HP goes to zero. `events` truncates at `MAX_EVENTS = 2400`. | Continuous respawn needs a separate authoritative runtime/encounter coordinator; **do not depend solely on a capped presentation event queue for reward settlement**. |
| `HuntingMapV2` | `spawn` creates a deterministic finite encounter roster. `preview_reward` calculates encounter-level rewards from `reward_seed + 7331`; `claim_reward` credits Warehouse only after a win, with `v2_pve_reward_claims[encounter_id]` idempotence. | Legacy **encounter-win payout is not per-kill**. New opt-in per-kill routing must not also call this reward path for the same kills. |
| Body-material progression | `HuntingMapV2` has `LINH_TUY_GUARANTEE_WINS = 4` and `v2_body_material_progress` based on successful encounters at Thanh Trúc Lâm. | Preserve legacy guaranteed-source behavior; do not silently substitute per-kill guarantee or reset counters during migration. Any production-mode mapping needs separate explicit design. |
| `HuntingPveRunV2` | Stores active battle in `sect.v2_pve_active_runs`; terminal HP/Injury auto-return uses separate `v2_pve_settlement_receipts`; only `claim()` routes legacy reward and erases completed win snapshot. | Maintain separate battle terminal, kill reward and old claim identities. Never use kill receipts to bypass existing Injury/One Active Job settlement. |
| `MapBattleSnapshotV2` | Version 1 serializes battle RNG, actors, pending casts and event state. `HuntingPveRunV2.restore_state` re-creates **original** monster roster to validate source identity. | A persistent respawning world requires its own versioned save data and validation; cannot merely place additional respawn generations into an unmodified legacy snapshot. |
| `WarehouseSystem` | Canonical stack `sect.warehouse_resources`, `MAX_SAFE_STACK` guard, checked `add` and `consume_requirements`. Legacy `claim_reward` preflights all stacks and rolls back on failure. | B2.3 must do the same across **all** stack rewards and any unique-item mutations, with receipt committed atomically in simulation state. No Loot Warehouse / persistent team bag. |
| `EquipmentSystem` | Main-code pilot exposes only **3** slots (`weapon/armor/talisman`), **3** qualities (`pham/tinh/thuong`) and five recipes; item instances in `sect.equipment_items`. | Do not label this as the 10-slot/12-grade/24-set target implemented. B3 requires separately authorized extension/migration and compatibility. |
| `SaveService` | Wire `CURRENT_VERSION = 2`, staged `.tmp`, verified load and `.bak` backup; `SectState` + `SimulationState` serialize reward/settlement dictionaries. | Persist spawn slots, generation, deterministic rewards and receipt states together in the canonical saved snapshot; ensure old v2 saves load unchanged. |

**Remote-state limitation:** GitHub `main` is still `461caca`; no searchable remote B2 branch or B2.3 completion commit was located in this audit. The previous B2 editor MVP is documented in handoff ZIP; new B2.3 local work and any fresh review ZIP remain **UNVERIFIED**, not necessarily absent. The SA-LIB remote tooling branch was rechecked at `87d6b60123c85930e9eb571949f4aafbb8f8ac7d`. V5.1 remains documented as a local dirty change, not a remote integrated feature.

## 2. B2.3 proposed technical contract — opt-in sandbox, NOT production authority

### 2.1 Lifecycle: one live monster, one death, one generation

- `runtime_mode = legacy_encounter | sandbox_per_kill`; old saves default to **legacy**. No automatic conversion of old paid/not-yet-paid encounters.
- A per-zone `spawn_slot_id` is stable; each respawn increments a persistent `generation`. `mob_instance_id` uniquely identifies **zone + slot + generation**. Spawn is data-driven from editor-validated entries (actual species/tier/region identifiers).
- On verified **alive → dead** authoritative HP transition, produce one `kill_key = run_id/zone_id/slot_id/generation`. Damage source (basic, skill, projectile, DoT, AoE) does not alter kill identity. A second lethal callback cannot create another key.
- Mark the generation dead and set `respawn_at_tick` using the **one canonical simulation tick**; no parallel wall-clock timer. Refill that same slot only at its due tick, regardless of UI visibility; limit live monsters to current max 40 per active battle. No infinite spawn backlog after offline time.
- `MapBattleV2` is an individual bounded combat slice; a coordinator may start or reuse bounded slices, but may **not** change Combat V2 hit/damage/critical/RNG/skills/targeting laws merely to keep the world alive. An alternate continuous-battle refactor requires a separately scoped code packet.

### 2.2 Separate loot randomness and stable tables

- Source identity is server/simulation state, never the UI's `downed` animation. Loot eligibility must come from validated `species_id`, `tier`, authored `table_id`, `table_version`, zone and generation.
- Roll loot **once** from an independent, domain-separated deterministic seed derived from persistent run seed + `kill_key` (stable documented integer hash; never reuse/advance `MapBattleV2.rng`). Iterate table entries in canonical sorted order.
- Persist the **already rolled payload** in a durable pending/committed receipt; changing an authoring table or re-opening preview does not reroll a killed monster. Preview and editor simulator remain pure/non-paying.
- All numerical rates, count ranges, respawn intervals, boss odds and gear qualities are **SANDBOX FIXTURES ONLY** until separately approved. No fake registered materials, no unverified auto-added recipe.

### 2.3 Exactly-once ledger and warehouse transaction

Suggested schema (names are proposals): `KillReceipt {kill_key, run_id, zone_id, slot_id, generation, source_species_id, tier, loot_table_version, rolled_stacks, rolled_unique_items, loot_hash, status: PENDING|COMMITTED, created_tick, committed_tick}`.

1. Validate kill key and source against authoritative saved spawn slot; reject replay/conflict and malformed content.
2. Resolve deterministic payload once; validate every `ResourceRegistry` ID, nonnegative quantity and `WarehouseSystem.MAX_SAFE_STACK` headroom; validate any unique-item IDs/ownership/slot against canonical Sect equipment registry.
3. Treat resource credit + unique item creation + receipt status transition as **one state mutation**: preflight; stage/rollback all affected dictionaries and counters; commit `COMMITTED` only after all effects succeed. On failure, leave the exact payload in `PENDING` for bounded retry without a reroll or partial credit.
4. Snapshot the committed Warehouse and receipt in the **same canonical SaveService save**. On reload/retry, `COMMITTED` means never award again; `PENDING` retries stored payload once. Old encounter reward claims remain a different namespace; do not invoke both settlement paths.
5. Save/load integrity checks reject impossible duplicates (`kill_key` generation mismatch, duplicate unique ID, committed receipt missing provenance). Fail closed instead of silently discarding malformed records. Receipt compaction/retention is a separate scale design; never prune live replay-protection arbitrarily.

### 2.4 Persistence and performance

- Versioned `sandbox_hunt_state` includes mode, run/zone, persistent tick/cursor, spawn slots and generations, next due ticks, table versions, pending and committed receipt identities, deterministic loot state; serialize in `SectState` once, not in a second save file. Specify migration and backwards compatibility at allowed-path CODE authorization time.
- Serialize order independent of Dictionary insertion order. Save mid-fight and between death/credit/respawn. Compare viewed/unviewed combat and death/loot/reward snapshots using the same seeds.
- Keep unloaded zones cheap: update respawn deadlines based on ticks without per-frame actor AI; do not eagerly allocate 6,578 Spine rigs or fully simulate inaccessible off-map monsters. Presentation reads snapshot and foot/pivot; does not govern timing, loot or HP.

### 2.5 Minimal true runtime gates

**Mandatory focused tests on the exact implement SHA:**

1. One monster death grants exactly one receipt and expected stack delta; second lethal callback and duplicate kill replay grant zero.
2. Two different generations of the same slot grant at most one reward **each**; independent slots respawn at independent stored tick deadlines.
3. Save/load at alive, dead-before-credit (PENDING), committed and before/after respawn; replay has unchanged total resources, unique IDs and RNG outcome.
4. Simultaneous AoE, DoT, projectile-like delayed lethal / 40-mob boundary; no lost kills due to `MAX_EVENTS` presentation cap.
5. Repeat fixed seed under viewed/unviewed modes, including save/resume, with identical combat/RNG and loot ledger.
6. Legacy V2 encounter win + claim + Thanh Trúc Lâm material guarantee still work; no duplicate per-kill reward when sandbox mode enabled.
7. Warehouse overflow/failure and corrupt receipt fail closed, no partial credit, no item duplication; no mutation from editor preview.
8. One Active Job/Injury/terminal settlement remain identical; 6-party, 30 disciple and 40 monster caps honored.

FAST tests first; add wider cross-subsystem regression only at a real integration gate. Static inspection is never called runtime PASS.

## 3. B3 farm → craft → equip design (RESEARCH / NO BALANCE LOCK)

### 3.1 Canonical spec to preserve

- `docs/WEAPON_EQUIPMENT_V2_SPEC.md`: **10 ordinary equipment slots, 12 quality grades**; quality grade is not cultivation realm/equipment tier.
- `docs/EQUIPMENT_SETS_V2_SPEC.md`: **24 set lineages = 18 combat + 6 profession**, each four authored position pieces, legal 2/3/4 thresholds; 3+3 sets can be combined only where position matrix permits.
- `docs/WEAPON_EQUIPMENT_V2_REALM_MAP_SET_MATRIX.md`: 30 realm-oriented maps ×10 clusters is a design projection, not implemented. Separate tier/quality/set/content catalogs.
- `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`: all gear is Sect-owned; disciple only assigned; standard materials go immediately into Sect canonical Warehouse, unique gear into canonical unique registry; no personal loot bag.
- `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md`: design-order authority, **not** numeric caps, recipes, upgrade odds or completed code.

### 3.2 First playable 3-region vertical slice

Use the three **existing real** `HuntingMapV2` regions as source anchors: `thanh_truc_lam`, `bach_thach_khe`, `hac_phong_coc`. Do not materialize all 30×10 planned regions. Each region needs confirmed authored normal/elite/boss roster, spawn slots, real registered common materials, optional chase reward, compatible craft input/gear blueprint and actual farm target rule. Any content gap must be shown as blocked, not padded with invented IDs.

**Player loop:** choose hunt region/target → 6-person team hunts until stop/injury/limit → individual kills award tracked materials → canonical Warehouse grows → one authorized real forge order consumes reserved materials → unique Sect-owned item goes to storage → automatic equipment assignment evaluates compatible slot+stats+valid set thresholds → measurable combat improvement → next hunt tier. Support manual override and locks, preserve One Active Job.

**Early B3 product target:** one fully traceable material-to-item order on the existing pilot inventory, not immediate all-10-slot conversion. A later, separately scoped `Equipment V2` schema/migration packet must extend 3→10 slots and 3→12 grades + set matrix without destroying historical `equipment_items`.

### 3.3 Balance workbench: measure before setting rates

For each region/tier/species capture `kills/hour`, `deaths/defeats`, active hunt time, respawn-limited idle time, per-item expected/observed drops, `materials/hour`, recipe consumption/hour, `hours-to-first-craft`, `hours-to-useful-upgrade`, `unique-item duplicates`, Sect inventory stock/inflow/outflow, auto-hunter utilization and boss chase variance. Calculate projected materials/hour as the **sum over actual eligible kills/hour × drops/eligible kill × quantity/drop**, subject to respawn and combat cap. For recipe `r`, sustainable crafts/hour is limited by the minimum material supply-to-cost ratio and authorized forge throughput. Simulate with explicit SANDBOX-only table assumptions and show ranges rather than presenting a single lucky roll as canonical.

Assess **three stress layers** separately: one party, multiple parties sharing the same cluster, and 30 disciples versus max 40 live monsters. No involuntary rigid formation/teleport trick to improve visual clarity. Ensure low-rank basic materials remain repeatably accessible without mandatory lucky boss RNG, while higher-rank set variants may require targeted elite/boss farming. Pity/boss guarantee/upgrade cap/equipment quality rates all require owner sign-off.

### 3.4 B3 implementation order after B2.3

1. **B3-DATA**: versioned, validated loot/recipe/equipment source maps, actual `ResourceRegistry` matching and content coverage checks. No production rates.
2. **B3-LOOP**: one real forge transaction, Sect-owned unique item, deterministic crafting receipt, full warehouse consume+item commit; old pilot remains valid.
3. **B3-AUTO**: hunt target priority (specific material/recipe/gear), stop when goal stock reached, roster capacity/injury/One Active Job gates; avoid forced unlimited auto-hunt.
4. **B3-GEAR**: separately authorized 10-slot/12-grade/24-set migration and actual combat/stat consumers; prevent paper-only set bonuses.
5. **B3-BALANCE**: playtest-derived rates, crafting costs, boss targeting, anti-inflation and sink cadence; proposal to owner before locking any numbers.

**Do not couple B3 to SA-LIB-01 conversion throughput.** First pass can use verified pilot Source A packs/fallback render assets while simulation proves full real loop. No duplicate converter in Character Studio.

## 4. Integration and next action

- **Now, mobile-only:** research/record B2.3 boundaries and B3 open design here, no Windows operations. Request no additional owner decision on numerical loot yet.
- **Next Codex evidence, not scheduled by this document:** inspect newest B2.3 ZIP + full tracked/untracked status and exact active branch; audit actual code against section 2 before instructing more work. Do not overwrite local dirty work. Every Codex code task delivers review ZIP + SHA256SUMS, changed+untracked inventory, complete diff, focused logs/visuals and Markdown checkpoint.
- **Source A secondary:** leave current 2,200 MiB free RAM safety threshold intact; status -> 5–10 current-fingerprint rig QA only if safe. No 66 metadata-chunk GitHub upload.
- **V5.1/Character Studio:** hold pending owner visual/approved pack. Baseline red One Active Job/hunting UI/GP-02C1 tests remain red; no unapproved repair masquerading as presentation QA.
- **No GitHub `main` edits/merge.** This Markdown is a research output; it neither authorizes B2.3 runtime code nor certifies integration.

## 5. Provenance

GitHub main source inspected: `godot/src/simulation/combat/{map_battle_v2.gd,map_battle_snapshot_v2.gd,hunting_map_v2.gd,hunting_pve_run_v2.gd,monster_catalogue_v2.gd}`, `godot/src/simulation/{resource/warehouse_system.gd,equipment/equipment_system.gd,state/{sect_state.gd,simulation_state.gd},save/save_service.gd}`, plus the five 2026-10-21 handoff Markdown documents. All conclusions about **local** V5.1/B2.3/Character Studio state rely on prior handoff provenance, **not** live access to a user's Windows worktree or its ZIP.

---

## 6. ADDENDUM 2026-10-21 — POST FOUR-ZIP B3 AI FARM / BRANCH INTEGRATION RESEARCH

**Reason for update:** Owner reported both Codex Prompt 01 (B2.4) and Prompt 02 (SA-LIB) are currently in progress. This addendum is read-only design; no new Codex prompt, code editor, tests or conversion has been run here. GitHub main still reads `461caca1171462e0da092f21108c5c1733157ad9` at the time of audit.

### 6.1 Four ZIP reality and forward dependencies

| Stream | Verified in the current four-ZIP handoff | Next dependency / current decision |
|---|---|---|
| B2.3 → **B2.4** | 72-entry B2.3 ZIP; 7 focused/regression PASS; Editor schema v2/UndoRedo, independent spawn/per-kill/ledger, 30v40 ×160, snapshot rollback | B2.4 must show a true standalone Godot demo and manual Editor GUI; keep rewards **seeded test-only** and sandbox Warehouse clone; don't claim live SaveService/production payout. Local B2.3 worktree had 5 tracked +24 untracked pending. |
| Source A SA-LIB | 6,578 indexed rigs, 5,328 SOURCE READY, 1,250 REVIEW; 10 historical QA PASS, **0 current fingerprint PASS** | 2,200 MiB free RAM guard and >=5 GiB disk; no simultaneous Godot conversion/runtime. 66 detailed catalog chunks remain local, no repo upload authorization. |
| Combat V5.1 | Actual Source A pilot screenshots and camera/shadows, focused QA | Dirty local branch, owner visual pending, manual reset click/Android pending; hold. |
| Character Studio V2 | 8 real GUI frames; 7 rig candidates, 42 clip cells (22 verified, 2 unverified, 18 missing), 0 verified outfits | Local commit not pushed; hold until current-fingerprint SA-LIB approved packs. No second converter. |

**Trust boundary:** the four ZIP review is the authority for the above handoff evidence; GitHub connector accesses only published code/Markdown. Do not claim local dirty code is at `main` or completed Codex work as a committed branch.

### 6.2 Existing AI farm code already present — do not duplicate

| Actual main file | Existing runtime role | B3 integration rule |
|---|---|---|
| `godot/src/simulation/ai/decision_system.gd` | Chooses `HUNT/REST/HEAL/SELL/BUY/CULTIVATE` from HP/stamina/inventory, goals and preferences; `choose_region` scores profit, region danger, combat power, organization and social signals. | **Reuse as advisory preference/risk scoring**, not a second direct monster-loot authority. For a B3 explicit farm goal, apply policy constraints before selecting a permitted region. |
| `godot/src/simulation/ai/goal_system.gd` | `RECOVER/WEALTH/GLORY/SECURITY/PREPARE/GROWTH` goals; e.g. inventory triggers WEALTH. | Preserve personality goals for background behaviors; don't conflate per-disciple WEALTH or individual inventory counts with Sect-wide material targets. |
| `godot/src/simulation/organization/organization_system.gd` + `team_state.gd` | Canonical team memberships, max 6 members; roles hunter/logistics/guard and leader. | Reuse existing team IDs/membership; B3 team-farm order should reference teams, never maintain a parallel roster with different 6-member rules. |
| `godot/src/simulation/workforce/workforce_system.gd` | Supports explicit `COMMAND_HUNT_REGION`, other job commands, worksite reservations. | Reuse command semantics where compatible, but target material/monster is a **higher-level policy**. One Active Job check must precede deploying the actual hunt. |
| `godot/src/simulation/core/simulation_scheduler.gd` | Advances canonical minute ticks and legacy autonomous `HUNT→TRAVEL→COMBAT→LOOT→EVALUATE`; legacy `COMBAT` uses `CombatSystem.resolve_encounter` and sets `disciple.pending_loot`, then deposits/sells later. | **Important collision:** legacy personal pending-loot route is NOT B3 canonical immediate Sect Warehouse per-kill settlement. B3 must not route identical monster deaths through both systems. Preserve legacy unchanged by opt-in mode and use B2.4 per-kill authority only in designated sandbox until integration is separately approved. |
| `godot/src/simulation/core/simulation_runtime_owner_v2.gd`, `simulation_runtime_clock_v2.gd` | One canonical `SimulationScheduler`, state/save owner, online/offline tick integration. | When promoted from standalone sandbox, B3 scheduler consumes this one tick clock; do not build a second simulation ticker or persist an independent farm reward save. |
| `godot/src/simulation/combat/hunting_pve_run_v2.gd` | Authoritative V2 battle run, participant reservation and terminal Injury/HP; legacy encounter rewards separate. | Must be reconciled at the integration owner boundary with B2.4 sandbox before live reward enablement. No early guess that B2.4 API has already been merged. |

### 6.3 Proposed B3 farm-order contract (design only)

A Sect Master creates a **farm objective**, not individual loot claims: `farm_order_id`, target registered `material_id` or exact approved gear/recipe goal, required stock delta or absolute stock floor, prioritized region/eligible tiers/species, team IDs, safety settings, start/stop/pause, source table version and policy revision. Treat unknown item IDs, invalid zones and unapproved per-kill production tables as **BLOCKED** rather than falling back to free payouts. Persist these orders via canonical simulation state only after a scoped CODE authorization.

**Five states:** `WAITING_FOR_RESOURCES` (target validation / actor & zone eligibility) → `DEPLOY` (reserve one existing team and 0/1 active jobs) → `FARM` (B2.4/approved V2 simulation alone owns kill, receipt, warehouse) → `RETURN_RECOVER` (HP/Injury/timeout/command stop) → `GOAL_REACHED` (verified canonical Warehouse objective). `PAUSED/BLOCKED` is a controlled status for conflicts and unavailable sources. Never calculate loot in the AI policy itself.

**Scheduling rule:** a cheap policy evaluation at known simulation tick boundaries computes shortages from `WarehouseSystem.quantity` (and existing reserve/locked rules) and ranks objectives by urgent crafting goal, source viability, expected rate and risk. Policy requests hunting only when no competing job/reservation, valid team capacity, valid region/realm, approved content and safe combat readiness. A kill receipt independently updates Warehouse; the next evaluation reads that *committed* stock and stops/redirects the farm when the goal is reached. No extra reward on stopping, no "idle loot" from offline catch-up, no 1,000 individual per-frame planners.

**Offline/safety:** no unbounded respawn backlog; offline farm duration, max events, injury and consumption policy must be explicit before production. B2.4 may exercise only an isolated sandbox/save clone. Any long-running offline payout must be separately authorized and bounded to guard against infinite resources or receipt growth. Relative HP, danger, retreat behavior and One Active Job belong to V2 simulation; UI cannot override them.

### 6.4 AI farm numeric research without locking drop rates

Let `K_{z,s,t}` be *actual committed eligible kills per hour* in zone `z` for species/tier `s,t` (accounting for movement, respawn, fights, waiting, recovery, and multi-team contention), `P_{s,t,i}` the **proposal** drop probability for material `i`, and `Q_{s,t,i}` the mean awarded quantity if dropped. Then:

- `E[material_i/hour] = Σ_z,s,t K_z,s,t × P_s,t,i × Q_s,t,i`.
- For recipe `r` with `cost_{r,i} > 0`, `max_sustainable_crafts/hour <= min_i(E[material_i/hour] / cost_{r,i})`, and also bounded by the real forge/worker capacity. This is an **upper bound**, not a promise: luck, injury, stock reserves and correlated drops lower real output.
- Time to first craft must use **distribution quantiles and pre-existing stock**, not only expected value. Track median, p90, p95 elapsed simulated game time until material goal, zero-progress runs, duplicate-receipt count (should be zero), no-affordable-action cases, storage delta and injury downtime.

**Recommended first B3 playtest:** the three real V2 zones `thanh_truc_lam`, `bach_thach_khe`, `hac_phong_coc`; one 6-disciple party, approved existing low-tier material, one actually available forge recipe from the legacy pilot and one genuine equipment instance. No need to author 300 clusters or implement all 12 grades to prove usefulness. Later scale tests can use 5 teams/30 disciples and 40 simultaneous monsters after the single-party path is correct.

### 6.5 Integration matrix and stop conditions

| Merge surface | Likely collision | Safe handoff / stop condition |
|---|---|---|
| `project.godot`, addons and scene registration | B2.4 Editor dock versus Character Studio addon; V5.1 pilot launcher | Explicit plugin IDs and isolated demo scene. Never copy entire `project.godot` wholesale from a dirty branch. |
| Combat `MapBattleV2`, `HuntingPveRunV2`, snapshot/kill source | B2.4 per-kill runtime versus legacy encounter-win claim versus V5.1 view | B2.4 sandbox must be isolated. Promotion requires one designated combat integration owner and proof of exactly one authoritative kill/reward route. |
| `SectState`, `SimulationState`, `SaveService`, `WarehouseSystem`, `SimulationScheduler` | B3 farm orders vs B2.4 ledger vs Economy V2/One Active Job | No independent parallel writes. Integration owner chooses one versioned save/schema and tests mid-receipt rollback and legacy migration. |
| Source A content manifests/resolver | SA-LIB library pack vs Character Studio V2 vs V5.1 | Accept a **specific current-fingerprint QA pack**, never generic `READY` catalog status. One lazy resolver; no second converter or copy of all indexed rigs into game. |
| `equipment_system.gd` and unique registry | Pilot 3 slots/3 grades vs spec 10 slots/12 grades/24 sets | B3 starts with one pilot forge flow; large schema migration is **a distinct authorization/packet** with old item compatibility. |
| Base QA | Three V5-era red baseline tests, conflicting B2.3 GP-02C1 focused PASS on another checkout | Compare exact test SHA/fixtures/runners before attributing fixes. Never call baseline red tests green. |

**Integration readiness gate (after Codex completion):** receive B2.4 ZIP and SA-LIB ZIP with exact branch/HEAD, dirty tracked+untracked diffs, artifact SHA256SUMS, current-fingerprint proof, focused logs, GUI/screenshots, repeatable sandbox steps. Preserve local worktrees; inspect two ZIPs and parent commits; then propose a scoped **read-only** collision matrix before any merge. Only after approval may an integration owner choose the exact parent, paths, migrations and tests. No unattended merge.

**Owner action now:** none. Codex Prompts 01/02 remain ongoing; do not resend them, restart them, or perform extra heavy QA here. This addendum is usable for immediate backend/B3 research while waiting for evidence.


---

## 7. B3 AI FARM DEEP DIVE — ACTUAL SOURCE GRAPH, POLICY, SAFETY, MVP GATES (2026-10-21)

**Scope:** independent READ-ONLY design while Codex Prompt 01 B2.4 and Prompt 02 SA-LIB are running. No Godot code, runtime test, raw asset movement, table-rate lock or merge. Current `main` confirmed at `461caca1171462e0da092f21108c5c1733157ad9`. The in-progress Source A report states available RAM 1,011 MiB (<2,200-MiB gate), E: 51.36 GiB free, 0 Godot processes; converter **must remain stopped**. The CLI SQLite failure is a task write-root permissions problem as reported, **not evidence that the DB itself is corrupt**. If the task requests scope, prefer write access only to DB/checkpoint/output paths; preserve raw Source A immutably. Classification from current Codex message (not separately locally rerun): REVIEW = 915 parser / 162 atlas / 173 texture (sum = 1,250), multi-skin candidate `2123019_10` (12 skins, parse pass). No current-fingerprint QA has been demonstrated by these findings.

### 7.1 Critical design collision to resolve before live B3

1. **Time units are not interchangeable**. `SimulationRuntimeClockV2` explicitly defines 60 wall seconds = 1 simulation minute = 1 scheduler step, while `MapBattleV2.STEP_SECONDS` = 0.25 *battle seconds*. B2.4's sandbox time does not automatically authorize one hunt kill per scheduler tick, or unlimited offline wins. A separately approved integration packet must define a **bounded combat-to-simulation step accounting policy** and prove online/offline equivalence without multiplying income.
2. **DecisionSystem methods are not pure preview functions.** `DecisionSystem.choose_region()` writes `disciple.last_decision`; `evaluate()` also mutates it. A read-only B3 UI planner must not call either in render loops or hypothetical simulations; use a pure candidate score extractor/adapter or execute only inside a canonical authorized command.
3. **One Active Job is an ingress restriction, not merely a UI label**. `WorkforceSystem.issue_command()` can release Body training and cancel work on accepted explicit orders. An autonomous farm proposal must **never issue the command before a pure occupation/reservation preflight**. Default AI cannot evict a paid training slot, drain a production timer or cancel carried legacy goods. A human override must use the existing safe cancellation semantics; no quiet bypass.
4. **Legacy hunt loot path differs from V2**. `SimulationScheduler` still runs P2 `HUNT→TRAVEL→COMBAT→LOOT` into `DiscipleState.pending_loot`, while `HuntingMapV2.claim_reward()` grants after victory to Warehouse and B2.3 sandbox records per-kill receipts. Treat these as *three separate modes*, with **one and only one authoritative credit owner** per run; do not join all three on the same kill.
5. **Warehouse usable stock is not raw stock.** `WarehouseSystem.available_quantity()` returns 0 for locked materials or max(0, stock-reserve_min). B3's crafting demand must honor locks/minimum reserves. Planner-level predicted assignments are **nonphysical demand bookkeeping**, not a second warehouse or real item reservation until such a contract is separately approved.

### 7.2 Confirmed candidate source graph, with truthful payout mode

These are **existing authored encounter-level V2 pilot** resources (`HuntingMapV2.REGION_CONTENT`), *not* approved per-kill loot tables. B2.3/B2.4 production per-kill table is EMPTY; no material may actually be emitted from an unapproved live per-kill path.

| Existing hunting region | Encounter-level pilot resources | Special source | Use for B3 source-planning feasibility |
|---|---|---|---|
| `thanh_truc_lam` | `linh_moc`, `thanh_thiet`, `thanh_linh_thao` | `linh_tuy` pilot rare, old 4-win body guarantee | Wood+ore starter, herbs, body material preserve legacy guarantee |
| `bach_thach_khe` | `thanh_thiet`, `tinh_lang_bi`, `tu_van_thao` | `huyen_thiet` pilot rare | Iron+hide, Trúc Cơ herb |
| `hac_phong_coc` | `tinh_lang_bi`, `yeu_dan` | `huyen_thiet` pilot rare | Hide+monster core, advanced target |

Existing `EquipmentSystem.RECIPES` and *suggested* basic farm paths (material ID and recipe costs are already present in main pilot; these are NOT new B3 costs):

| Existing pilot recipe | Existing material cost | Feasible source planning, **not** validated per-kill release |
|---|---|---|
| `thanh_thiet_kiem` | `thanh_thiet:3` + `linh_moc:1` | Thanh Trúc Lâm for both; Bạch Thạch Khê optionally supplements ore |
| `huyen_thiet_quyen_sao` | `thanh_thiet:3` + `tinh_lang_bi:1` | Bạch Thạch Khê supplies both |
| `linh_moc_phap_truong` | `linh_moc:3` + `yeu_dan:1` | Thanh Trúc Lâm wood + Hắc Phong Cốc core |
| `tinh_lang_giap` | `tinh_lang_bi:3` + `thanh_thiet:1` | Bạch Thạch Khê supplies both |
| `hoa_van_ngoc` | `yeu_dan:2` + `linh_moc:1` | Hắc Phong Cốc core + Thanh Trúc Lâm wood |

**Most efficient first REAL loop candidate (only after reward integration authorization):** one party, `huyen_thiet_quyen_sao` or `tinh_lang_giap` sourced from Bạch Thạch Khê to minimize cross-region switching. Both inputs exist in the same region in the **legacy encounter reward content**; per-kill equivalence must be separately authored/verified before live farm automation. This is a feasibility proof, not current working game functionality.

### 7.3 FarmOrder proposal — exact interface between player goal and old systems

**User actions (design):** choose item/recipe or registered material; choose one existing team or auto-select from available valid teams; choose a maximum acceptable risk and stop objective; optional preferred region. The user never needs to select individual monster instance IDs. Do not add a global AI system when existing `DecisionSystem`, `GoalSystem`, `OrganizationSystem` and `WorkforceSystem` can be reused.

Proposed persisted `FarmOrder` fields (unimplemented): `order_id`, `objective_type` = material_stock / recipe_batch / approved_gear_target; `objective_id`, `target_amount`, `team_id`, `preferred_regions[]`, `eligible_sources_version`, `risk_policy`, `retreat_policy`, `max_duration_ticks`, `min_useful_stock`, `priority`, `status`, `reason_code`, `last_evaluated_tick`, `generation`. Owner of future persisted orders must be **canonical SimulationState/SectState**, not Scene/Character Studio/asset catalog.

**Source resolver:**
- For material target, validate `ResourceRegistry.has(material_id)`; join **explicit validated mapping of species+tier+zone+loot table**; only live-eligible if an approved payout table exists. Existing per-encounter `REGION_CONTENT.resources` can drive *read-only candidate discovery*, not live per-kill payouts.
- For recipe goal, read `EquipmentSystem.recipe(recipe_id)` (existing pilot only); compute deficits from `WarehouseSystem.available_quantity()`, considering other approved committed allocations **once**. Do not count pending loot receipts as committed stock.
- For set/unique-item chase, require verified `equipment_items` identity/content, tier, quality and legal set lineage; if unimplemented, report `CONTENT_NOT_AUTHORED`, never invent a Boss guaranteed drop.
- If multiple eligible zones, minimize *estimated risk-adjusted time to satisfy current bottleneck*, not merely maximize rarity or raw drops. Maintain `source_confidence = VERIFIED_PRODUCTION | SANDBOX_ONLY | PROPOSAL | UNAVAILABLE`; only VERIFIED_PRODUCTION is eligible for live auto-farm.

### 7.4 Scheduler/policy: safe deterministic state machine

States proposed: `DRAFT`, `VALIDATING`, `QUEUED`, `DEPLOYING`, `HUNTING`, `RETURNING`, `RECOVERING`, `COMPLETED`, `PAUSED`, `BLOCKED`, `CANCELLED`. A state change has an explicit tick, reason, and single owner; UI is a projection of those values.

At an authoritative tick/event, the policy:
1. Checks output goal from **committed** canonical Warehouse stock and valid craft recipe input (including lock/reserve constraints). Do not interpret locked goods as available for auto-crafting or declare completion falsely.
2. Verifies team member identity, max 6 in one party, valid scene/zone, all members not injured (Injury 0), positive HP, currently usable gear/loadout, and absence of any active competing job/PvE reservation. **No forced job cancellation**.
3. Applies **hard safety filters before utility ranking**: player maximum risk, retreat threshold, source content verification, no unsupported tier and no simultaneously assigned team. Predictive power estimates are advisory, not permission to override V2 survival AI.
4. Orders eligible teams by current objective urgency, real inventory shortage, estimated useful drops per activity time, travel/recovery and future crafting bottleneck. Stable IDs break ties, avoiding Dictionary-order/RNG nondeterminism.
5. Issues a single canonical authorized command only on state transitions, not repeatedly every frame/minute; does not create a separate tick owner or secondary monster simulator.
6. Reacts to **COMMITTED** B2.4-derived reward ledger signals only after separately approved production hookup. On target reached, stop new deployment. Finish/settle existing real battle safely; no mid-attack deletion, no extra stop reward.
7. If workers become injured, source invalid, supplies insufficient, or a locked reserve blocks crafting, transition to PAUSED/BLOCKED or RETURNING/RECOVERING with a precise reason. A paused order cannot mint loot while unloaded.

**Anti-churn:** never bounce region every tick because a slightly different score wins; require a materially better feasible option or an event (goal reached, injury, region unavailable, explicit owner order). Any numeric minimum dwell/cooldown is **proposed tuning**, not locked. Resume reads persisted status and prior receipts without rerolling.

### 7.5 Production/reward/persistence gates

- No instant "farm in background" payout proportional to elapsed wall clock. `SimulationRuntimeClockV2` has real 60s→1-minute ticks; `MapBattleV2` has 0.25s battle steps and a bounded 90-second arena. An integration owner must define how bounded battle steps consume simulation action time. **No equivalent conversion is currently authorized.**
- B2.4 sandbox cloned Warehouse and local restart are not `SaveService` production durability evidence. `KillReceiptLedger` status and Warehouse must eventually be saved atomically in canonical state; independently verify crash/reload around PENDING→COMMITTED, unique items and legacy encounter claims.
- Idle/off-screen farms must use bounded accrual and state replay; if offline details are unresolved, **pause live rewards** rather than silently fast-forward infinite kills.
- Combat V2 decides death; loot subsystem decides deterministic reward; Warehouse commits receipt; AI chooses next objective. Never let an AI goal or V5.1 animation call `warehouse.add()` directly.
- Gear in Sect unique-item registry is 100% Sect-owned. `owner_id` in old P2.6 code is a migration-era equipped-user marker; do not give private ownership. Auto-equip computes **whole loadout utility including legal set thresholds** once 10-slot/24-set subsystem is actually implemented; in first pilot only existing 3 slots/3 grades/5 recipes exist.

### 7.6 Policy cost model and telemetry (NO numerical rates locked)

Inputs from real playtest: `eligible_kills_per_hour`, actual `seconds_per_kill`, travel seconds, waiting/respawn seconds, `time_injured`, repaired/medicine cost, canonical usable stock, actual recipe material consumption, forge completions, Boss chase outcomes, capped active monsters, loot receipts and `bad_duplicate_count`. The first benchmark must track **simulated game time separately from real wall time**.

Let `rate_i(z)` denote verified credited units of material i per *simulated hunt hour* for zone z. `time_to_goal` estimate is driven by the slowest `max(0, required_i - available_i)/rate_i(z)` after accounting for mixed sources and actual region switching. Do not use `HuntingMapV2.LEVELS.rare` encounter percentages as per-kill probabilities. If any required `rate_i` is unknown, show `UNKNOWN` rather than invent a forecast.

**Test scenarios required before first live AI packet:**
- Same recipe goal can be fulfilled using existing stock+one team; no more loot once target reached.
- Two competing recipe orders do not *double-count* the same eligible material stock; locked/reserved stock is not taken.
- One team is never deployed to two concurrent hunting orders; no >6 in party, no >30 disciples / >40 monsters in active battle.
- A member with active Mine/Forest/Field/Alchemy/Body job or Injury=1 is not silently stolen. No canceled old carries.
- Missing material source or empty production per-kill table gives `BLOCKED` and **zero live payouts**.
- Save/load a running hunt, PENDING receipt and completed receipt; compare viewed/unviewed and offline boundaries; no double payout or repeated reward on UI preview.
- Retreat, defeat, timeout and recovery preserve HP, Injury 0/1/120, member availability and existing GP-02C1 settlement invariants.
- Equipment craft input uses actual Warehouse; successful forge creates unique registered Sect item; disabled/invalid item and item ownership fail safely.
- In first real proof, connect **one approved production material source and one existing recipe** before broadening sources; measure p50/p90/p95 time to first useful craft and risk hours.

### 7.7 Shortest viable implementation packets AFTER B2.4 evidence (not active authorizations)

1. **B3-D0 DATA READ-ONLY:** validate existing encounter source map vs ResourceRegistry, recipe ingredient IDs, target feasibility, unavailable per-kill tables; expose read-only content and shortages report. Does not collide with B2.4 runtime writer if kept entirely docs.
2. **B3-D1 POLICY/PURE PLANNER (separately authorize):** design a pure demand/source/team evaluator with seeded fixtures only; no `SimulationScheduler`/`SectState` mutation. Focused dry-run tests only. Must choose allowed paths and new parent SHA first.
3. **B3-D2 INTEGRATION CONTRACT (separately authorize):** one owner wires explicit opt-in V2 hunting runtime, kill receipt+Warehouse and genuine canonical SaveService with migration; preserve legacy modes and no double payout; focused V2 + economy gates.
4. **B3-D3 FARM ORDER RUNTIME (separately authorize):** persist goal/queue and team assignments, policy decisions at canonical tick boundaries, survival priority, stock-based stop, missing-content BLOCKED. One code writer for shared Scheduler/Workforce/Save files.
5. **B3-D4 CRAFT/EQUIP:** first existing pilot recipe/item, then distinct 10-slot/12-grade/24-set migration packet; no premature universal gear overhaul.
6. **B3-D5 BALANCE:** compare observed material/recipe/gear progression and injury tradeoffs before requesting owner rate, guarantee, cap and Boss source approvals.

**Next owner action while Codex 01/02 continue:** none required. This is a design checkpoint; do not start B3 code or extra QA, do not grant converter permission by changing RAM gates. Wait for new B2.4/SA-LIB evidence in the normal conversation, then inspect ZIP and branches before selecting a single CODE integration owner.

---

## 8. B3-D0 — MA TRẬN NGUỒN → KHO → CÔNG THỨC → FARM ORDER (READ-ONLY AUDIT, 2026-10-21)

**Permission and provenance:** this section is **DOCS-ONLY**, based on GitHub `main` @ `461caca1171462e0da092f21108c5c1733157ad9` and the latest 2026-10-21 four-ZIP/B3 checkpoints; no runnable game QA, save upload, claim production-per-kill table, Codex takeover or balance approval. User intends to focus Source A only **after B2.4**, but SA-LIB currently remains blocked on local resources. No `main` edit, CI, merge, or new converter.

### 8.1 Existing source graph — exact IDs, no ghost loot

**Static cross-reference result:** 8 unique relevant source/recipe resource IDs examined against `ResourceRegistry.DEFINITIONS`; **0 missing**. This checks declaration presence, not persisted stock or eligibility of a future per-kill table.

| Item (`ResourceRegistry`) | Existing V2 encounter source | Other current pilot use | B3 D0 status |
|---|---|---|---|
| `linh_moc` | Thanh Trúc Lâm | Ingredient in `thanh_thiet_kiem`, `linh_moc_phap_truong`, `hoa_van_ngoc`; also Linh Lâm output | SOURCE_EXISTS_ENCOUNTER; per-kill production **UNAPPROVED** |
| `thanh_thiet` | Thanh Trúc Lâm, Bạch Thạch Khê | Ingredient in `thanh_thiet_kiem`, `huyen_thiet_quyen_sao`, `tinh_lang_giap`; also Mỏ output | SOURCE_EXISTS_ENCOUNTER; per-kill production **UNAPPROVED** |
| `tinh_lang_bi` | Bạch Thạch Khê, Hắc Phong Cốc | Ingredient in `huyen_thiet_quyen_sao`, `tinh_lang_giap` | SOURCE_EXISTS_ENCOUNTER; per-kill production **UNAPPROVED** |
| `yeu_dan` | Hắc Phong Cốc | Ingredient in `linh_moc_phap_truong`, `hoa_van_ngoc` | SOURCE_EXISTS_ENCOUNTER; per-kill production **UNAPPROVED** |
| `thanh_linh_thao` | Thanh Trúc Lâm | Herb / alchemy, **not ingredient** in five equipment recipes | SOURCE_EXISTS_ENCOUNTER; do not farm for ordinary gear pilot |
| `tu_van_thao` | Bạch Thạch Khê | Herb / alchemy, **not ingredient** in five equipment recipes | SOURCE_EXISTS_ENCOUNTER; do not farm for ordinary gear pilot |
| `linh_tuy` | Thanh Trúc Lâm, existing rare/4-win Body guarantee | Body milestone, **not ingredient** in five gear recipes | LEGACY_GUARANTEE; preserve 4 completed wins, not 4 monster kills |
| `huyen_thiet` | Bạch Thạch Khê and Hắc Phong Cốc rare | Registered, **not used** in five pilot equipment recipes | RARE_EXISTS_ENCOUNTER; not a default target for first forge goal |

**IMPORTANT payout isolation:**
1. `HuntingMapV2.preview_reward()/claim_reward()` grants registered resources **once per victorious, completed PvE encounter**, not per individual monster, from `REGION_CONTENT` and level yield. Includes rare pilot roll and Thanh Trúc Lâm four-victory guarantee; retained legacy authority.
2. `EquipmentSystem.forge_loot_for_victory()` is a **different older route** keyed by individual resolved legacy `species_id`: `truc_thu` → `linh_moc:1`; `thanh_lang` → `thanh_thiet:1,tinh_lang_bi:1`; `hac_lang` → `thanh_thiet:2,tinh_lang_bi:1,yeu_dan:1`; moves into disciple pending inventory and later deposited. **Do not add to V2 encounter payout or rebrand as B2.4 per-kill tables.**
3. B2.4 editor/runtime prototype is an **isolated seeded sandbox**, not live `SaveService` or production drop tables; no live B3 loot should flow through it until an authorized integration owner establishes a single payout route.
4. Monster `normal/elite/boss` composition in V2 is encounter-authored; the `rare` percentage applies **per won encounter**, not a per-kill chance or inferred Boss legendary drop.

### 8.2 Exact encounter-level material matrix (existing pilot figures, NOT new B3 balance)

For **each win** at the listed level, before any legacy rare bonus and when eligibility/settlement succeed: `max(1, round(base_resource * LEVELS[level].yield))`; fixed factors Level 1–5 are 1, 1.35, 1.8, 2.5, 3.5. Displaying existing code values **does not freeze future B3 drop rates**, and losing, retreating or unclaimed runs grant none via this claim method.

| Vùng / `region_id` | Level (pilot) | Quái/trận | Vật liệu chắc chắn theo *thắng encounter* |
|---|---:|---:|---|
| Thanh Trúc Lâm / `thanh_truc_lam` | 1 | 3 | `linh_moc` **3**; `thanh_thiet` **1**; `thanh_linh_thao` **1** |
| Thanh Trúc Lâm / `thanh_truc_lam` | 2 | 4 | `linh_moc` **4**; `thanh_thiet` **1**; `thanh_linh_thao` **1** |
| Thanh Trúc Lâm / `thanh_truc_lam` | 3 | 5 | `linh_moc` **5**; `thanh_thiet` **2**; `thanh_linh_thao` **2** |
| Thanh Trúc Lâm / `thanh_truc_lam` | 4 | 6 | `linh_moc` **8**; `thanh_thiet` **3**; `thanh_linh_thao` **3** |
| Thanh Trúc Lâm / `thanh_truc_lam` | 5 | 7 | `linh_moc` **11**; `thanh_thiet` **4**; `thanh_linh_thao` **4** |
| Bạch Thạch Khê / `bach_thach_khe` | 1 | 3 | `thanh_thiet` **2**; `tinh_lang_bi` **2**; `tu_van_thao` **2** |
| Bạch Thạch Khê / `bach_thach_khe` | 2 | 4 | `thanh_thiet` **3**; `tinh_lang_bi` **3**; `tu_van_thao` **3** |
| Bạch Thạch Khê / `bach_thach_khe` | 3 | 5 | `thanh_thiet` **4**; `tinh_lang_bi` **4**; `tu_van_thao` **4** |
| Bạch Thạch Khê / `bach_thach_khe` | 4 | 6 | `thanh_thiet` **5**; `tinh_lang_bi` **5**; `tu_van_thao` **5** |
| Bạch Thạch Khê / `bach_thach_khe` | 5 | 7 | `thanh_thiet` **7**; `tinh_lang_bi` **7**; `tu_van_thao` **7** |
| Hắc Phong Cốc / `hac_phong_coc` | 1 | 3 | `tinh_lang_bi` **2**; `yeu_dan` **2** |
| Hắc Phong Cốc / `hac_phong_coc` | 2 | 4 | `tinh_lang_bi` **3**; `yeu_dan` **3** |
| Hắc Phong Cốc / `hac_phong_coc` | 3 | 5 | `tinh_lang_bi` **4**; `yeu_dan` **4** |
| Hắc Phong Cốc / `hac_phong_coc` | 4 | 6 | `tinh_lang_bi` **5**; `yeu_dan` **5** |
| Hắc Phong Cốc / `hac_phong_coc` | 5 | 7 | `tinh_lang_bi` **7**; `yeu_dan` **7** |

Rare resources `linh_tuy/huyen_thiet` are separate pilot rolls (plus the old 4-win guarantee where applicable), omitted from fixed material matrix. The per-kill B2.4 synthetic QA award is **not** this table. Higher difficulty has more monsters and difficulty multipliers; more items *per win* does not imply a higher real material-per-hour throughput.

### 8.3 Existing real recipe matrix and cheapest *encounter-count* paths

The following costs were read from `EquipmentSystem.RECIPES`; all ingredient IDs appear in `ResourceRegistry.DEFINITIONS`. The example count is **illustrative static arithmetic**, not an actual available stock/party risk/time measurement; its assumptions are zero starting Warehouse, no reserved/locked goods, L1 successful claim per encounter, no rare bonus or competition.

| Recipe ID hiện có | Vật liệu chính xác / một món | Vùng V2 cung ứng đầu vào | Kết luận với kho ban đầu = 0, không reserve, level 1, mọi trận thắng |
|---|---|---|---|
| `thanh_thiet_kiem` (weapon) | `thanh_thiet` ×3 + `linh_moc` ×1 | thanh_thiet ← Thanh Trúc Lâm, Bạch Thạch Khê; linh_moc ← Thanh Trúc Lâm | 1 thắng Thanh Trúc Lâm + 1 thắng Bạch Thạch Khê → có đủ; 2 chuyến/vùng (chưa tính đi lại). Chỉ Thanh Trúc Lâm cần 3 thắng. |
| `huyen_thiet_quyen_sao` (weapon) | `thanh_thiet` ×3 + `tinh_lang_bi` ×1 | thanh_thiet ← Thanh Trúc Lâm, Bạch Thạch Khê; tinh_lang_bi ← Bạch Thạch Khê, Hắc Phong Cốc | 2 thắng Bạch Thạch Khê → có đủ. |
| `linh_moc_phap_truong` (weapon) | `linh_moc` ×3 + `yeu_dan` ×1 | linh_moc ← Thanh Trúc Lâm; yeu_dan ← Hắc Phong Cốc | 1 thắng Thanh Trúc Lâm + 1 thắng Hắc Phong Cốc → có đủ; cần hai vùng. |
| `tinh_lang_giap` (armor) | `tinh_lang_bi` ×3 + `thanh_thiet` ×1 | tinh_lang_bi ← Bạch Thạch Khê, Hắc Phong Cốc; thanh_thiet ← Thanh Trúc Lâm, Bạch Thạch Khê | 2 thắng Bạch Thạch Khê → có đủ. |
| `hoa_van_ngoc` (talisman) | `yeu_dan` ×2 + `linh_moc` ×1 | yeu_dan ← Hắc Phong Cốc; linh_moc ← Thanh Trúc Lâm | 1 thắng Hắc Phong Cốc + 1 thắng Thanh Trúc Lâm → có đủ; cần hai vùng. |

**A particularly compact feasibility pilot:** `tinh_lang_giap` from Bạch Thạch Khê alone. At existing Level 1 content, 2 victorious encounters yield `tinh_lang_bi:4` + `thanh_thiet:4`, enough for armor cost `tinh_lang_bi:3` + `thanh_thiet:1`, **assuming stock starts at 0 and claims succeed**. At Level 2, one victorious encounter yields `3+3`, enough in material count, but higher battle danger may make Level 1 preferable. These are **old encounter claim** calculations, NOT a forecast of B2.4 per-kill drop, measured hunt time, actual available warehouse or free player reward.

**Source switching principle:** when the necessary input is already produced by Mine/Linh Lâm, AI should compare real warehouse supply and the committed building timer before redirecting a team. `huyen_thiet` is not a component of `huyen_thiet_quyen_sao` despite its name; the existing recipe requires `thanh_thiet` and `tinh_lang_bi` only. Do not chase the rare Huyền Thiết just to craft that weapon.

### 8.4 Canonical Warehouse demand, reserve, competing orders, stop conditions

**LIVE STOCK GAP:** No user's current `SimulationState` save is attached/accessible from GitHub. Therefore no factual `warehouse_resources` quantities, rules, currently queued jobs, team HP or actual deficits can be claimed. A code declaration is *not* a live inventory snapshot. All D0 results requiring a live save must explicitly report `UNKNOWN_STATE`.

For each ingredient `i`, output goal type `recipe_batch` and quantity `n`:

- `required_i = recipe.materials[i] × n`.
- `usable_i = WarehouseSystem.available_quantity(state, i)`, which accounts for `locked` and `reserve_min`; **do not** infer this from raw quantity if rules exist.
- `committed_other_orders_i` is a *policy accounting constraint* for future approved orders (not a new real wallet/warehouse or item transfer).
- `uncommitted_usable_i = max(0, usable_i - committed_other_orders_i)`.
- `deficit_i = max(0, required_i - uncommitted_usable_i)`. A zero deficit means **MATERIALS_READY**, not that an actual gear item was crafted.
- A **material stock** goal may complete when its actual committed stock condition is satisfied. A **gear craft** goal completes only when an actual `equipment_items` unique item exists with the intended recipe and lawful Sect ownership, after a validated forge transaction. If the goal also includes equipping, verify a genuine assignment to the chosen existing disciple before `COMPLETED`.
- If the goal targets `n` units of *spendable material*, satisfy `available_quantity` rather than `quantity` and preserve existing reserve; don't subtract reserve twice.
- An AI objective must not count `pending_loot`, preview panels, uncommitted receipts, unprocessed job timers, static region rewards, shop listings, personal inventory, or hypothetical market purchases as credited Sect material.

**Deterministic tie-break example (not real save):** For `tinh_lang_giap`, suppose `tinh_lang_bi` physical stock 2 with `reserve_min=1`, `thanh_thiet` physical stock 5 with `reserve_min=2`, neither locked, and no other claim. Usable hide = 1, usable ore = 3; deficit hide = 2, ore = 0. AI's **material target** is hide only. If a second order has already allocated that one usable hide in a canonical future policy, hide deficit becomes 3. These are *illustrative figures only*. Once loot increases stock, re-evaluate `available_quantity` at a canonical tick/event and stop redeployment at goal; avoid per-frame state writes.

**Order priority across recipes:** one deterministic ordering per policy revision/tick: player explicit priority, urgent validated shortfall, source viability, risk-adjusted expected *useful* credited materials per total elapsed hunt time, available eligible team, then stable order ID. **No planner-made pseudo-reservations may be committed or exposed as actual Warehouse reserved stock.** More than one recipe order sharing the same material must have either one documented allocation ledger inside canonical state or be queued serially to prevent double counting.

### 8.5 Team selection and job conflicts (safe AI farm)

Reuse `OrganizationSystem` canonical `TeamState`, `DecisionSystem` risk/region scoring, `WorkforceSystem` occupation preflights and `HuntingPveRunV2.begin()` actual eligibility validation. Policy recommendations are not a second authoritative job admission path:

1. Gather existing team IDs in stable lexical order and their actual `member_ids`; require 1–6 members (one currently existing battle's global cap 30 disciples and 40 monsters remains separate). Reject missing/duplicate members or simultaneous team deployments.
2. Reject injuries `injury_level != 0`, HP<=0, existing PvE reservations, invalid current region/action, active Mine/Forest resource timer, Spirit Field plot, Alchemy timed recipe, Body facility, any nonempty work cycle or conflicting direct command. **Do not call `issue_command` as a preflight**; accepted explicit commands can release/cancel work.
3. Require actually registered region, unlocked/eligible V2 difficulty and genuine source evidence. `DecisionSystem.choose_region` and `evaluate` **mutate** `last_decision`; UI planner must use pure extraction/ranking, not call them per render frame.
4. Hard-filter by owner danger/retreat policy and stable V2 HP/Body combat readiness, then rank eligible region/team pairs. Leadership, skill/path/equipment bonuses may inform predicted safety but must never spoof V2 canonical combat stats.
5. Choose one order/team at a time; leave busy teams `WAITING_FOR_TEAM` (not `FAILED`). On urgent Injury/defeat/retreat, let real V2 terminal HP/Injury/return settlement finish before issuing another plan; no arbitrary auto-redeploy.
6. If a run is already active at the moment target becomes available, **stop scheduling new runs** but let the current authoritative encounter finish and settle. Do not delete the battle or revoke a valid existing kill receipt just to stop farm.

**Source confidence status:** `VERIFIED_LEGACY_ENCOUNTER`, `VERIFIED_LEGACY_DISCIPLE_INVENTORY`, `SANDBOX_TEST_ONLY`, `VERIFIED_PRODUCTION_PER_KILL`, `UNAVAILABLE`. None of the currently observed B2.3/B2.4 synthetic records qualifies as `VERIFIED_PRODUCTION_PER_KILL`. Use `BLOCKED_NO_PRODUCTION_TABLE` for hypothetical *live per-kill* FarmOrder until separately authorized; do not disable legacy PvE to claim B3 is ready.

### 8.6 Real time, forge time, ETA — separate existing authorities

| Stage / actual existing code | Timing authority | Fact/status for B3 |
|---|---|---|
| Economy-A authentic V2 Mine / Linh Lâm resource packet | `BuildingSystem._start_resource_timer` uses `base_duration = economy_a_policy.resource_duration_ticks` default **10 scheduler ticks** and `duration = ceil(base_duration / max(work_speed,0.25))` min 1; real persisted `finish_tick`; starts only on valid worker slot | **IMPLEMENTED** when Economy-A enabled. Read actual policy/actor speed and timer progress before choosing farm over passive production. Do not assume ten minutes final for every job. |
| Other P3.7 work cycles/Field/Alchemy | `BuildingSystem` job/plot timers and `SimulationScheduler.step()` | **IMPLEMENTED by respective subsystems**, durations and conditions depend on real building/worker/recipe; don't collapse into the Mine/Forest ten-tick timer. |
| `WorkforceSystem` forging profession cycle | `FORGING_DURATION=5.0` legacy work-progress units under work-speed modifiers | **NOT a scheduled forge recipe**. This produces profession XP/support channels; it is not a five-minute guaranteed equipment forge. |
| `EquipmentSystem.craft(recipe_id, list_for_sale=true)` | Synchronous function: checks/consumes materials then creates a unique `equipment_items` entry and increments forge index | **NO forged gear timer in current pilot**. `list_for_sale=false` initially stores item; default puts it in `LOCATION_SHOP`. Do not show invented forging progress/ETA or claim a durable forge queue exists. |
| Autonomous legacy expedition vs V2 map combat | `SimulationRuntimeClockV2` 60 wall seconds = 1 scheduler-minute; `MapBattleV2` 0.25 battle-seconds per combat step and 90 battle-second cap | **NO approved general conversion between combat steps and scheduler minutes for B3 repeated farm**. Thus expected minutes/gear is `UNKNOWN` until an integration owner defines and tests the accounting. |
| B2.4 sandbox per-slot respawn | Separate sandbox runtime from Codex Prompt 01 | Do not reuse sandbox respawn seconds as production earning clock or treat seeded fake drops as B3 material/hour. |

**ETA proposal (not implemented):** `T_total = T_wait_for_eligible_team + T_travel + Σ(real successful and failed encounters + respawn/wait + recovery + claim) + T_real_forge_queue_if_it_exists + T_assignment`. For the current direct `EquipmentSystem.craft()`, `T_real_forge_queue` is **0 synchronous code execution**, *not* an approved gameplay instant-forge policy for V2 equipment. If any time/rate/payout eligibility is unknown, UI displays `ETA_UNAVAILABLE` with reason, rather than fabricating a countdown. Measure wall time and simulation time separately.

### 8.7 Stop/recovery and B3-D0 acceptance contract

| Trigger | State transition (proposal, no code) | Forbidden shortcut |
|---|---|---|
| Missing/empty approved production per-kill table | `BLOCKED_NO_PRODUCTION_TABLE` | No synthetic/legacy payout substituted for B2.4 |
| Material ID unregistered, ingredient source unverified, zone inaccessible | `BLOCKED_SOURCE` | Never invent resource, region, mob or item |
| Material stock target met from committed Warehouse | `COMPLETED` for material-stock objective only | No phantom gear completion |
| Recipe inputs become affordable without touching lock/reserve | `MATERIALS_READY` → wait for authorized real craft | Do not debit twice or count other orders' reservations |
| Unique item actually crafted | `CRAFTED` → optional `ALLOCATING` / `COMPLETED` | No clone gear or personal resale |
| HP retreat, Injury=1, team conflict or supply shortage | `RETURNING/RECOVERING` or `WAITING_FOR_TEAM/SUPPLIES` | No forced job transfer, skipped Injury, or infinite farm |
| Stop/pause/cancel by owner | stop *new* dispatch; settle active run and outstanding receipts exactly once | No mid-battle kill deletion or rollback of earned valid loot |
| Offline/save reload, process interruption | resume from canonical persisted state *when integrated*; otherwise sandbox no live rewards | No proportional offline payout without actual simulated bounded combats |

**Next meaningful non-Godot verification before authorizing B3 code:** inspect B2.4 ZIP for actual per-kill source map, table validator, receipts and one tick/clock owner; inspect first current-fingerprint SA-LIB pack only for visual asset usability (not a blocker for D0); obtain **a safe read-only exported save/warehouse snapshot** when available to replace `UNKNOWN_STATE` with actual stock and team eligibility. Do not request Windows action now.

**Minimal future focused tests when code is separately authorized (not executed):** (1) one recipe / one region / real stock deficit; (2) locked reserves & two competing orders; (3) no duplicate payout across legacy and B2.4 modes; (4) busy/injured/team-full rejection; (5) provenance of completed Forge registry item; (6) online/offline tick equivalence with bounded combat advancement; (7) early-stop not deleting valid receipts; (8) no fabricated forge timer. Retain existing 3 baseline red regressions and test SHA provenance.

**D0 exit today:** source/recipe IDs **statically cross-checked**; model & first pilot chosen; real stock and quantitative farm/forge ETA **UNKNOWN** by evidence. No Godot PASS, balance lock or production AI implementation claimed. The next CODE packet is **not authorized by this document**.
