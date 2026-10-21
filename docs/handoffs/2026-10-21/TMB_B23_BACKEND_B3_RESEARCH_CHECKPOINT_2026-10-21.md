# TÔNG MÔN BÁ ĐẠO — B2.3 BACKEND AUDIT + B3 RESEARCH CHECKPOINT

**Date:** 2026-10-21 · **Status:** READ-ONLY CODE AUDIT + DESIGN PROPOSAL; NOT CODED, NOT RUNTIME-TESTED · **Research base:** `main` @ `461caca1171462e0da092f21108c5c1733157ad9` · **Document branch:** `docs/tmb-status-20261021-v5-sa-lib`.

> **OWNER PRIORITY:** 1 main task = B2.3 Spawn & Loot Runtime; 1 secondary task = Source A library conversion only when safe hardware gates permit. V5.1 Combat/Character Studio V2 hold. No user Windows requirement. No merge, CI/FULL, balance lock, Source A metadata upload, or gameplay change is authorized by this research note.

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
