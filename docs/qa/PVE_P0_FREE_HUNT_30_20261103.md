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
- [Official Godot 4.7.2 run 41599326867](https://github.com/vuanhtuant161094-byte/TongMonBaDao/actions/runs/41599326867): **SUCCESS 25/25 CI steps**, 30x20/hold/minimap and genuine natural solo 10 HP0 receipts, canonical EXP/loot/replay, 2-process offscreen Save/Reload **GREEN**. Relevant log markers: `PVE_P0_30_HUNTERS_PASS checks=18`, `PVE_P0_REAL_KILLS_XP_PASS` with body XP 279.5 / Tu Vi 856.875, `PVE_P0_NATURAL_SAVE_RELOAD_PASS`, `PVE_P0_NATURAL_SOLO_PASS checks=43`, `PVE_P0_TEST_FIRST_GREEN`. Source/test code at `310a040d8a9bc0f93c520b50ae9a28ce567c8255`.
- [Official Godot 4.7.2 run 41599909474](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41599909474): later source adds V6.3 optional-party heal/area regression and strict snapshot validation. **Pending actual job conclusion in this document revision; do not substitute the earlier GREEN for later exact SHA**.
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
