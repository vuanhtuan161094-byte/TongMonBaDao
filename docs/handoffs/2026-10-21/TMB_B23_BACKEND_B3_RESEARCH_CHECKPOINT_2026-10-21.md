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
