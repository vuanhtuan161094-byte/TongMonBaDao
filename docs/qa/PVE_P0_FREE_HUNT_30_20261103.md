# PVE-P0 Free Hunt — 30 independent disciples, 20 World zones, per-kill loot + XP

**Date:** 2026-11-03 · Tông Môn Bá Đạo · Godot **4.7.2.stable.official.ed1daf0bf**  
**Owner P0 rules (2026-11-03):** A disciple can hunt **solo**, without mandatory party. Up to **30 disciples** in one world/combat cluster, optionally partitioned into parties of **up to six**. Party buffs/heals and team XP apply only to actual same-party IDs **and correct range**. Choose disciple then click minimap to order to a distant zone; chosen hunting policy follows them. An explicit **HOLD** order keeps a disciple in place; **AUTO** hunts the local area. Keep **Return to Sect** (an actual retreat). Closing/map not being watched must not itself retract the team; shared-runtime offline/backlog is independent.

**Code source baseline:** exact PR [#67](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/67) `f2ae694af791a27deec4e1de7ae7c122914be635`, Draft/unmerged. This source branch does **not** write PR67 or `main`. **Feature branch:** `feature/pve-p0-free-hunt-30-20261103`.

## 1. Implementation inventory (isolated feature branch ONLY)

| Code | New behavior |
|---|---|
| `godot/src/simulation/combat/map_battle_v2.gd` | Reuses canonical combat, 30-player/40-live-monster bounds and collision/pathfinding; per-disciple persistent `hunt_policy` and local radius, `order_group_move(..., arrive_policy)`, atomic `set_disciple_hunt_policy(ids,"auto"/"hold")`, guard does not chase, on arrival reanchors; monster suspend/reactivate retains original life ID and HP |
| `godot/src/simulation/combat/pve_distributed_world_v1.gd` (new) | 20 actual Source A zones, 200 persistent spawn slots, activates zones occupied/targeted by hunters; exactly at most 40 monster actors active (20 occupied = 2 per zone, one occupied = 10), dormant monster snapshot retains HP/state/generation without respawn or loot; includes saved identity validation |
| `godot/src/simulation/combat/hunting_pve_run_v2.gd` | `begin_multicamp` can prepare 1–30 human actors on the one real Source A world (max 6 per explicit `party_id`; missing party ID creates independent `solo:disciple_id`); P0 opt-in only by `options["p0_distributed_world"]` or 7+ members with legitimate topology; dynamic LOD during official game-clock frames; real HP0 receipt/EXP/loot pipeline; validates P0 snapshot separately from legacy strict 6v10; preserved legacy non-P0 reward path |
| `godot/src/simulation/combat/pve_per_kill_reward_v1.gd` (new) | Only actual `MapBattleV2.pending_kill_events()` for dead catalogue actor trigger. Stable `kill_id` + generation → deterministic seeded item roll; canonical Warehouse add; `DiscipleRealmProgressV2.grant_xp` to Tu Vi and Body, dry-run + rollback; bounded per-spawn-slot last-lifecycle receipt for exact-once (even when no items). Codex V63 special receipt remains separate. |
| `godot/src/presentation/p3/pve_sect_world_view_v1.gd` | On selected disciple(s), clicking minimap emits existing authoritative `move_ordered(ids,walkable_location)`; with none selected focuses camera (AoE/LoS nav still canonical). Does not directly mutate backend from UI. |
| `godot/src/simulation/combat/map_battle_snapshot_v2.gd` | Validates persisted individual AUTO/HOLD, arrival policy, bounds and anchored local radius while preserving old snapshot defaults; no new SaveService/state schema. |
| `godot/src/simulation/combat/v63_human_skill_combat_system.gd` | V6.3 healing/guard/cleanse support selector and area/line/point support effects cannot heal other solo or other-party humans. Same-party allies can share. Boss-monster side retains faction semantics. |
| `godot/src/simulation/core/simulation_runtime_clock_v2.gd` | Carries independently proven PVE-01B persisted V6.3 opt-in on offline/cold-cache world restore, preserving the single scheduler. |
| `godot/tests/simulation/pve_p0_30_independent_hunters_test.gd` (new) | Real Source A path grid with 30 **synthetic engine-only** actors/20 zones; bounded live/dormant quads; solo+six-member mixed teams; individual HOLD and atomic refusal; Save/Restore; optional-party V6.3 target isolation; selected/unselected minimap tests. NOT a 30-person New Game recruitment claim. |
| `godot/tests/simulation/pve_p0_natural_solo_reward_test.gd` (new) | Actual `LiveGameRuntimeV2.start` and `P37Factory`, real B1 V2 candidate acceptance, **one** true V2 solo hunter into Source A; forces *real* battle HP0 through combat test API 10 times (NOT organic solo survival) → 10 genuine receipts/EXP/loot; no fake inventory/candidates; replay same kill duplicate, offscreen `runtime.poll` without a view; SaveService second operating-system Godot process cross-reload. |

**Explicit excluded files:** PR67 `godot/src/presentation/p3_2_landscape_sect.gd` is owned exclusively by TRI-03. This feature branch has not modified that shared 7,800-line scene or PR67, `main`, `SimulationState`, `SectState`, DiscipleState, CombatStats, WarehouseSystem, SaveService, loot item registry or Godot engine version.

## 2. Pilot EXP + drop authoring, NOT owner-locked balance

| Normal monster | Independent drop rolls per actual kill | Natural XP for credited killer |
|---|---|---|
| Trúc Thử | 25% 1 Linh Mộc, 5% 1 Thanh Linh Thảo | 75 Tu Vi + 25 Luyện Thể |
| Thanh Lang | 35% 1 Tinh Lang Bì, 3% 1 Yêu Đan | 75 + 25 |
| Hắc Lang | 30% 1 Tinh Lang Bì, 8% 1 Yêu Đan | 75 + 25 |

- All listed items already exist in the actual `ResourceRegistry`. Each drop line is rolled independently with deterministic `GameRng` seeded by official encounter reward seed and authentic `kill_id`; zero drops is valid.
- `DiscipleRealmProgressV2.grant_xp` applies authentic Tư Chất/Căn Cốt bonuses and canonical 300-floor XP gate; XP is not secretly converted to classic combat power. Killer gets 100%; each living same-party disciple within 12 map cells gets a **pilot 40%** XP share. Unaffiliated solo hunters receive **no** adjacent-party share. Values to be audited against `docs/SX-03` before any production merge. 75/25 and all percentages are **not final game balance**.
- Monsters outside the already approved common-species/ResourceRegistry scope do not drop imagined equipment, fragments, currencies, or legendary skills. `loot_ready=false` stays no common drop until authored. Codex/manual-drop source remains controlled by V63Archive gating.
- Warehouse full means a **backpressure barrier**, never a phantom roll or lost kill receipt. One slot/generation/kill ID can settle at most once. Resurrected higher generation can legitimately roll again; no global final-battle reward.

## 3. 30 disciples / 20 areas, map commands, offline

- A **map** has 20 persistent zones with 10 slots each = **200 registered lives**, not 200 AI actors running simultaneously. 20 occupied by hunters activates two live monsters per zone: maximum **40**. Empty zones remain dormant and their life/respawn timers still exist.
- Solo is the default when `party_id` is not supplied. True voluntary parties can hold **up to six** members each; 30 people may form five six-member teams or 30 solo IDs or any mixture.
- Selected actor click on minimap issues a move order to a real reachable grid cell. Without selection, minimap moves the camera. No teleport.
- AUTO hunts local living mobs within 18 cells in the current pilot; HOLD never chases targets outside immediate attack range. Move arrival policy may choose AUTO/HOLD.
- The canonical `SimulationRuntimeClockV2` and `SimulationRuntimeOwnerV2` work regardless of whether the PvE view is currently drawn. Offline catch-up obeys existing per-poll frame budget; do not assert indefinite zero-cost 24h simulation. All state changes must survive a separate process Save/Reload.

## 4. CI and evidence — distinction between focused and release gates

- [Official Godot 4.7.2 run 41598313661](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41598313661): original O2 parent PASS; 30x20 test initial code PASS up to activation but **TEST RED** due wrong oracle expecting no dormant C01 actors after reducing its active quota from ten to two. Corrected test-only expectation to eight suspended C01 actor snapshots.
- [Official Godot 4.7.2 run 41598886374](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41598886374): **30x20 18 checks PASS**, 20-zone LOD/guard/minimap PASS, natural solo RED at first finite **P3 arena position fixture** `invalid_party_actor`. Corrected the test to use the exact real P3 UI's initial arena position (8,9), which the engine then reprojects into the real Source A spawn.
- [Official Godot 4.7.2 run 41599326867](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41599326867): **SUCCESS 25/25 CI steps**, 30x20/hold/minimap and genuine natural solo 10 HP0 receipts, canonical EXP/loot/replay, 2-process offscreen Save/Reload **GREEN**. Relevant log markers: `PVE_P0_30_HUNTERS_PASS checks=18`, `PVE_P0_REAL_KILLS_XP_PASS` with body XP 279.5 / Tu Vi 856.875, `PVE_P0_NATURAL_SAVE_RELOAD_PASS`, `PVE_P0_NATURAL_SOLO_PASS checks=43`, `PVE_P0_TEST_FIRST_GREEN`. Source/test code at `310a040d8a9bc0f93c520b50ae9a28ce567c8255`.
- [Official Godot 4.7.2 run 41599909474](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41599909474): **SUCCESS 25/25 job steps** on final tested source SHA `659457f099b1e1415da12cbf2d018a3444f32b82`. Standalone **30 hunters /20 zones / HOLD / minimap / optional-party V6.3 heal** `PVE_P0_30_HUNTERS_PASS checks=21`, child exit **0**; standalone **true New Game one V2 +10 real HP0 event/loot and 856.875 Tu Vi /279.5 Body, cold two-process Save/Reload** `PVE_P0_NATURAL_SOLO_PASS checks=43`, child exit **0**. `PVE_P0_OPTIONAL_PARTY_SUPPORT_PASS` confirms AoE heal excludes unaffiliated solo hunter. Parent marker `PVE_P0_TEST_FIRST_GREEN both_standalone_processes=true`. Those tests are *focused*; they do not prove organic fighting endurance, native Windows or full release.
- **Temporary O2 QA subprocess launcher was removed completely** in commit `56d7621ba47789f0bd3339b5b06ab4dd73c462e4`; the original O2 script blob exactly matches PR67 baseline `04041836e4a7c122caa4d6fd2c9f7a8d61552348`. Final production and new P0 tests are byte-identical to the run-41599909474 code; only O2 launcher removal and documentation differ. The permanent test files can be invoked directly, without changing any workflow.
- [P3.7 backend gate 41597882869](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41597882869): **SUCCESS** on earlier P0 source snapshot `51226548`; [GP-02C1 Injury 41597882986](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41597882986): **SUCCESS** on same SHA; [Economy-A 41597883105](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41597883105): **SUCCESS** on same SHA. These are not final exact-head cumulative proof.
- [DV2-02 Combat Stats 41597882948](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41597882948): **FAIL** known preexisting five-level balance fixture (also FAILED on PR67 baseline before PVE-P0). [DV2-03 41599531415](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41599531415): **FAIL** old oracle still not ported from independent PVE-01A test-fix branch. Both remain QA OPEN; do not claim all repo cumulative PASS.

The permanent scripts above can be executed with official Godot:
```bash
godot --headless --path godot --import
godot --headless --path godot --check-only --script res://tests/simulation/pve_p0_30_independent_hunters_test.gd
godot --headless --path godot -s res://tests/simulation/pve_p0_30_independent_hunters_test.gd
godot --headless --path godot -s res://tests/simulation/pve_p0_natural_solo_reward_test.gd
```

## 5. INTEGRATION BLOCKERS — not P0 playable yet

1. **TRI-03 ONLY owns `p3_2_landscape_sect.gd`.** Its current `PvePartyPicker` still requires exactly six, and its `begin_multicamp(...,party,10,world_options)` does not opt in `world_options["p0_distributed_world"]=true`. Thus **the player cannot yet issue solo/30-hunter P0 commands from the integrated PR67 UI**. The test calls the new authoritative backend directly on an isolated QA branch. TRI-03 must explicitly grant one integration writer exclusive ownership to change these scene methods; no simultaneous edits.
2. **UI command wiring required:** connect a compact real 1280x720 selected-disciple AUTO/HOLD control to `session.battle.set_disciple_hunt_policy(ids,policy)`, check `result.ok`, persist through `session._persist_live_state()` then canonical `_save_runtime_async_barrier()`. Normal click-to-move and newly emitting minimap `move_ordered` use existing `_on_open_world_move_ordered`; optionally pass explicit `arrive_policy` from the player's command, not teleport state.
3. **No mandatory party:** replace `_multicamp_party_for_ids` exactly-six gate with 1–30 individual hunter selection; optional group assignment `party_id`, max six per group, stable identity across Save/Load; one session encompasses up to 30 actors, rather than five separate conflicting `v2_pve_active_runs`. UI should show whether a hunter is grouped or solo. Do NOT change 6-party team limit or 30-instance engine cap.
4. **Close map vs leave world:** maintain existing **Về tông môn** button calling `retreat_multicamp` as actual retreat. Add an independent **Đóng bản đồ** action that hides the map and lets the runtime's single clock keep all deployed hunters fighting, plus a clear reopen entrypoint. Do NOT stop/settle active battle when closing.
5. **Long-time QA still required:** stay in a bãi 10–30min, leave map and keep game open, quit/relaunch with offline catch-up budget, monster generation2→3 same slot, no duplicate XP/drop/codex receipt, try full warehouse and return when injured, 30-hunter formation crossing bridges, 30-hunter memory/cpu on Windows and Android.
6. **World content expansion:** only Thanh Trúc Lâm is one continuous Source A world and common `Trúc Thử/Thanh Lang/Hắc Lang` drops exist in P0 pilot. Elite, Boss, other maps, material rarity and skill balance are separate content authoring, not silently generated from 5-tier finite encounter table.
7. **UI UX quality:** minimal HUD near edges, clear HP bars and icon notifications, selected Hunter action glyphs, minimap selected markers, no text-heavy overlays. User must test physical Windows mouse/touch; screenshots alone are not acceptance.
8. Official Windows mouse and Android/touch **PENDING USER**. No main/PR67 merge and no player default save access.

## 6. Rollback and ownership

All PVE-P0 code is on branch `feature/pve-p0-free-hunt-30-20261103`, based on fixed PR67 SHA. To revert safely **before any integration**, abandon that branch; PR67 and `main` remain untouched and legacy code unaffected. If adopting, the exclusive integration writer must cherry-pick only reviewed production code/test blobs, verify PR HEAD and diff, run official Godot 4.7.2 focused/cumulative and user-facing scene QA, and preserve valid legacy saves. Avoid merging entire branch or leaving the temporary O2-child CI bridge; restore O2 byte-for-byte before final handoff. Any 30-player integrated demo acceptance requires separate authored roster/economy progression beyond opening Hall's current 12-disciple cap.

**Status:** Backend P0 architecture and focused engine tests GREEN at recorded SHA; final optional-team regression pending; PR67 UI integration and full playable/visual acceptance OPEN. This is a testable P0 feature branch, not an assertion that the shipped game already has all P0 functions.


## 7. Follow-up code pass — 2026-11-03; NOT yet a shipped P0

**Source HEAD before this report update:** `a7b551b6238bfe74c770f60889ce18c8ae9b18af`. The latest code **has NOT passed Godot** on that exact SHA. The last confirmed official GREEN remains [run 41599909474](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41599909474) from previously tested source `659457f099b1e1415da12cbf2d018a3444f32b82`. [Run 41599326867](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41599326867) earlier confirmed 18 assertions for 30x20 and 43 assertions for a genuine New Game V2 solo kill/loot/EXP/cold process. **These PASS claims are limited to their respective tested SHAs.**

### New source changes after the last GREEN

| File | New correction / purpose | Current status |
|---|---|---|
| `pve_distributed_world_v1.gd` | Keep **departure** monsters active while a real hunter walks toward another zone, prefetch destination without teleport. On monster activation, search a nearby legal free cell if an existing live disciple occupies the canonical slot; do not invent/clone a spawn or shift its slot ID. If no safe cell exists, keep it READY and retry later. | **CODED; GODOT PENDING** |
| `map_battle_v2.gd` | `order_group_move(..., arrival_policy="keep")` preserves independent AUTO/HOLD on each moving actor; explicit auto/hold still supported. | **CODED; GODOT PENDING** |
| `pve_sect_world_view_v1.gd` | P0 distributed world starts with **no implicitly selected 30-member squad**, preventing a single minimap click from ordering every hunter. Legacy six-actor view keeps its old selection contract. Adds small AUTO/HOLD buttons and `hunt_policy_ordered(ids,policy)` signal, **hidden until the P3.2 owner connects the authoritative callback**, so there is no deceptive inert gameplay control. | **CODED; GODOT PENDING; P3.2 CALLBACK OPEN** |
| `pve_p0_commands_v1.gd` (new) | Stable owner-only API: `build_members`, `deploy`, `move`, `hunt_policy`. Rejects duplicate/injured/occupied actors, caps 30 per world and 6 per real voluntary party, defaults each missing party to `solo:id`, uses Source A topology, cached single world runtime, persisted V6.3 gate and a game-state checkpoint. Success **returns `save_required=true`** for gameplay to call the existing SaveService barrier; no second clock or UI-side battle mutation. | **CODED; GODOT PENDING; P3.2 CALLSITE OPEN** |
| `pve_p0_30_independent_hunters_test.gd` | Adds departure-vs-destination zone retention, HOLD-after-travel, occupied-spawn collision, no implicit 30-person selection, disabled-without-listener AUTO/HOLD, selected minimap and same-party heal isolation. | **TEST WRITTEN; NOT RUN AFTER CHANGES** |
| `pve_p0_natural_solo_reward_test.gd` | Uses the new actual-runtime `PveP0CommandsV1.deploy` rather than invoking a private battle start; validates `move`, `hunt_policy`, malformed selection refusal, cold process preserving HOLD. Still one authentic New Game recruit, and the ten HP0 are **test-API kills**, not organic solo victory. | **TEST WRITTEN; NOT RUN AFTER CHANGES** |
| `.github/workflows/pve-p0-free-hunt.yml` | Adds permanent official Godot 4.7.2 import, parser, natural solo, 30x20, existing Source A input/formation and per-kill Codex regression checks. Does not require a temporary O2 test bridge. | **WORKFLOW CREATED; RUNNER BLOCKED** |

### GitHub Actions infrastructure limitation

Run [41600657130](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41600657130) (the existing unchanged O2 regression) and dedicated P0 runs including [41601242834](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41601242834) and [41602300262](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41602300262) returned **FAILURE after 2–5 seconds with zero reported job steps**. This is **not** a GDScript assertion failure, import failure or gameplay result: no job test steps executed. The GitHub API exposes neither step details nor downloaded logs for those attempts, so the exact infrastructure cause (e.g. account Actions quota/billing restriction) **is unconfirmed**. Do not mask this as PASS. Once a runner is available, rerun the dedicated workflow on the final SHA.

### TRI-03 integration contract — exclusive P3.2 writer only

No changes have been made in `godot/src/presentation/p3_2_landscape_sect.gd` or PR67. The writer must:
1. Change the source player-facing hunter picker from exactly six to **1–30** healthy V2 participants; do not auto-assign a 6-member party. Use `PveP0CommandsV1.build_members(state, selected_ids, role_map, optional_real_party_ids)` to validate before confirmation.
2. On Source A deployment, call `PveP0CommandsV1.deploy(runtime_session.owner, encounter_id, seed, selected_ids, b3_pve_world_view.get_open_world_options(), role_map, optional_real_party_ids)`; this automatically opts in the real 20-zone distributed world without faking any roster or resource.
3. Bind `b3_pve_world_view.hunt_policy_ordered.connect(_on_p0_hunt_policy)`. The callback must call `PveP0CommandsV1.hunt_policy(runtime_session.owner,ids,policy)`, then `await _save_runtime_async_barrier()`, and show feedback for failure. Controls only appear after this authoritative listener is connected.
4. Route the existing `move_ordered` signal through `PveP0CommandsV1.move(runtime_session.owner,ids,destination,"keep")` and then the same SaveService barrier; this avoids 30 individual partial move orders and preserves solo HOLD status when moving.
5. Keep **Về tông môn** as a real retreat. Add a separate **Đóng bản đồ** button to hide the view and let the canonical runtime keep hunting, with a clear way to reopen. Never call retreat on view-close.
6. Do not merge P0 to PR67 until the official engine parser, 30x20, New Game natural solo rewards, offscreen/cold reload and exact integrated SHA regressions are GREEN; Windows physical mouse and Android still **PENDING USER**.

**Important currently missing gameplay:** Adding a new recruit **into an already active hunt** and returning **one selected hunter without retreating the whole world** have not been implemented. Current P0 enables *initial deployment of 1–30* and individual commands inside that same run, not dynamic participant join/leave; record this as an OPEN playable P0 requirement, not as supported behavior. 30 recruited from a naturally progressing New Game also requires legitimate Hall/residence progression, and is not proved by the synthetic 30-actor simulation fixture.

### Exact ownership and rollback

- Production scene `p3_2_landscape_sect.gd`: **TRI-03 only**. No parallel edits on this feature branch.
- PR #67 remains Draft, unmerged; `main` unchanged.
- All patches are still isolated under `feature/pve-p0-free-hunt-30-20261103`, with one dedicated QA workflow and permanent tests; **do not cherry-pick the entire feature branch**. Review the two existing independent PVE-01B backend changes when integrating, because this branch also includes its saved-gate fix.
- Windows/Android: **PENDING USER**. No performance or UX claims without screenshots and actual device input.


## 8. P0 independent living roster — user-directed continuation (2026-11-03)

**OWNER:** Finish PvE backend alone; defer P3.2 and Codex integration. One Source A world is authoritative; individual disciples do **not** need a mandatory party. Changes isolated to `feature/pve-p0-free-hunt-30-20261103`, not PR67 or `main`.

**P0-ROSTER-01 CODED, NOT YET GODOT GREEN on latest SHA:**
- `MapBattleV2.add_world_disciple(row)`: creates one complete canonical live combat actor with original loadout and optional V6.3 skills; clamps total humans at 30 and individual voluntary `party_id` at six; preserves one combat timeline and event journal.
- `MapBattleV2.withdraw_world_disciple(id)`: removes **one** owned actor while at least one teammate is alive, without calling terminal settlement. Blocks return if the actor is involved in pending kills, casts, burn/weaken or V6.3 poison effect provenance, because dropping their caster ID would corrupt a future Save/Reload. Last member uses the existing explicit whole-world `Về tông môn` action.
- `PveP0CommandsV1.join_one(owner,id,role,party_id)`: validates actual Sect V2 disciple, injury, one active job, existing run reservation, real Source A walkable entrance, and then reserves existing active encounter + checkpoints that exact world. No synthetic candidate or free EXP.
- `PveP0CommandsV1.return_one(owner,id)`: commits only the returning person's canonical HP/Injury (HP=1 and recover at +120 ticks if downed), returns them to Sect and clears active PvE reservation. Remaining hunters, their real HP, earned XP, rewards, monster state and original encounter ID remain unchanged. All new commands return `save_required=true`; the future P3.2 owner must invoke the existing SaveService async barrier. Both commands undo local changes if the in-memory checkpoint fails.
- New Godot assertions: `pve_p0_natural_solo_reward_test.gd` now accepts **two actual V2 candidates in one New Game** (six founders + two, within eight real beds), deploys one, kills ten normal monsters via actual HP0 combat test API, then joins/returns second; rejects duplicate join/return and last-hunter withdrawal, finally cold-reloads the continuing first hunter and verifies second is back at Sect, with the same 10 receipts/XP/warehouse.
- Engine 30-actor fixture now explicitly refuses a synthetic 31st actor without changing the live roster. This is cap testing only, **not** New Game recruitment of 30.
- Workflow `.github/workflows/pve-p0-free-hunt.yml` parses the new command source and executes both headless suites and legacy nearby regressions when GitHub Actions jobs can start.

**QA limitation:** The latest P0 workflow [run 41608607713](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41608607713) finished FAILURE after seconds without exposing any executed job steps. Official Godot 4.7.2 **has not executed this new dynamic roster code**, so status is CODED/QA BLOCKED, not PASS or playable. Earlier [run 41599909474](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41599909474) was GREEN on an older SHA for 30x20, one original V2 solo HP0 loot/EXP/cold reload and party isolation only; it does **not** validate join/return.

**Next backend-only gates:** (1) Godot parser and both focused tests at exact new SHA, (2) same-slot monster death→generation2→3, real per-kill receipt/XP once each, 30+ minute offscreen bounded backlog, (3) normal and injured single-character return with live teammates, (4) bounded 30 world actors in 20 zones with stable runtime cost. No 130-person fixture for natural New Game, no P3.2 edit, no merge, Windows mouse/Android PENDING USER.
