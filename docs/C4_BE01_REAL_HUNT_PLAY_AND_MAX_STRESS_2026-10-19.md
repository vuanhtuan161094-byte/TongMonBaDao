# C4-BE01 — REAL HUNT PLAY LOOP + MAX STRESS TEST (2026-10-19)

**Status:** CODE COMMITTED, STATIC INSPECTED; **official Godot 4.7.2 tests, real Windows 1280×720 UX and Android PERFORMANCE PENDING**. Specific owner instruction: implement backend audit Priority 1 now; always include maximum-level, maximum actor/skill coverage in QA (max-state tests isolated from real saved character stats). Branch: `c4-be01-hunting-playable-and-max-fixture-20261019`, forked from C4/JX source renderer `f757c5f162f85ebccda936b06ba8a06b07eac003`; main previously `461caca1171462e0da092f21108c5c1733157ad9`, unchanged by this packet.

## What is now wired

- `godot/src/presentation/p3_2_landscape_sect.gd`: live P3.2 sect **Thế Giới** button now opens the actual `HuntingPlayPanelV2` instead of passive Gate information. Existing Gate building remains as before. Independent panel is added to existing popup layer; no new simulation time source.
- `godot/src/presentation/p3/hunting_play_panel_v2.gd`: region/5 local difficulties, search/capped 90 visible roster rows (protect 1k–3k disciples), 30 chosen disciples, six-per-team, explicit role and valid arena positions. Only actual saved V2 progression, alive, uninjured, idle/not-reserved and eligible source players are selectable. **Never give an old/legacy disciple a fabricated realm.** New V2 recruits can be acquired via normal recruitment. Select difficulty through canonical `HuntingMapV2.choose_level`, begin a genuine `HuntingPveRunV2`. It owns real combat, warehouse rewards, HP/Injury recovery 120 ticks and exactly-once settlement. `MapBattleWorldLayerV2` observes true combat events only; actual monster rank from spawn, disciple name/Tu Vi/Luyen The from true persisted V2 source (read-only display). Battle update calls `session.advance(true)` in bounded 0.25s ticks while view is open and persists canonical active checkpoints; **not** a parallel warehouse or offline scheduler. Close saves; reopen world resumes oldest live saved hunt, or offers reward claim after a finished win. Save immediately on begin/terminal/claim/close; no reward before settled win. UI does not inject skills or upgrade ranks. `LiveGameRuntimeV2` remains the sole autosave and wall-clock owner.
- **Open items explicitly not marked complete:** native scene smoke, device UX/performance, multiplayer/session scheduling, complete all-production hunting from main without a real V2 recruit, 7 deferred non-damage P2 skill consumers, and accuracy/evasion/Boss warning AI separate gameplay migrations.

## Godot QA — one-click isolated official Windows

`C4_BE01_HUNTING_MAX_ONE_CLICK.zip` launcher clones ONLY exact SHA to TEMP, uses private Godot user data/save, runs official Godot 4.7.2 import, 10 focused tests (prior 8 + original 5-level real PvE/snapshot/warehouse + new MAX stress), 1280x720 headless P3.2 sect smoke, opens P3.2 for manual click **Thế Giới → chọn khu/đội → thử trận → đóng/mở lại → nhận thưởng**. Archive `C4_BE01_HUNTING_MAX_QA_LOGS.zip` appears beside launcher, even if error. No CI, FULL or merge, no admin. Runtime PASS only with real log+video from exact HEAD.

### Maximum standalone test (always pair with ordinary-gameplay regression)

`godot/tests/simulation/c4_be01_max_hunting_stress_test.gd`:
1. **30 actual MapBattleV2 actors** split into five 6-person teams, **40 monsters** including true Boss/Elite from `MonsterCatalogueV2`. All fighters and monsters explicitly created at **Tu Vi realm30/floor10 + Luyện Thể realm30/floor10** (monster has a single 30x10 scale), not based on guessed HP. Potential input of 100 is a high deterministic fixture, *not falsely claimed as a cap on an uncapped attribute*.
2. Coverage for all five implemented JX pilot skills with ≤4 legal skill slots per actor, plus both currently implemented learned P2 damage skills; no mixed bars. Full nine learned P2 skill library is intentionally checked: two active damage consumers plus seven deferred effect consumers (dash, guard, weaken, burn, combo). Having a definition is NOT evidence of operational runtime skill effect.
3. Genuine equipment `move_speed` in a valid Armor slot increases derived and actual movement input at cultivation/body 30x10 in **sandbox**. No saved equipment changed.
4. Snapshot after several 0.25s authoritative ticks → Godot Variant b64 → JSON round trip → `MapBattleSnapshotV2.load` → two complete runs (render viewed/unviewed) must have identical exact battle `summary()`, RNG state, bounded events and AoE cap 3.
5. Negative boundary: 31st disciple rejected; 41st monster rejected.
6. Zero writes to live save. Pair test with existing 5-level PVE and GP02 Injury/scheduler regression to avoid testing only max and forgetting early progression.

## Rollback / non-changes

Rollback by checking out source baseline `f757c5f162f85ebccda936b06ba8a06b07eac003` in an isolated TEMP clone. `MapBattleV2`, `HuntingPveRunV2`, `HuntingMapV2`, `CombatStatsV2`, `MapBattleSnapshotV2`, `DiscipleState`, `SimulationScheduler`, `SaveService`, Economy and unrelated PR20 are **not modified**. No synthetic rewards, RNG cheats, skill grant, max-stat production injection, CI/FULL/merge. Need user Windows QA to call actual launcher runtime/UX PASS.

## 2026-10-19 owner Windows QA upload: partial PASS, obsolete camera test corrected

Owner uploaded `C4_BE01_HUNTING_MAX_QA_LOGS.zip`. ZIP integrity checked; `SUMMARY.txt` expected and actual pinned HEAD **`c194a0c3153814460addab0dca88de96c8b55a60`**, official **Godot `4.7.2.stable.official.ed1daf0bf`** at `E:\\Godot_v4.7.2-stable_win64_console.exe`. Import completed. Focused `02_pilot_effects`, `03_snapshot`, `04_group_battle` all emit their correct PASS markers. **3/10 passed before abort**; test 05 failed at `c4_pres01_view_motion_readability_test.gd:270`; no evidence from 06–11, scene smoke or manual game (SUMMARY `visual_scene_opened=False`). Failure was a **stale assertion** expecting zoom >1.0 while current owner-authored `combat_v4_jx_pilot.gd` sets spectator zoom ceiling **1.0x** for classic overview. It was not evidence that actor positions were wrong, nor proof backend failed.

Follow-up commits:
- Fix focused camera test to require exactly 1.0x *and* canonical midpoint of real 6v5 living actors; retain forward/inverse camera and RNG/state invariance checks. **Do not change renderer zoom behavior** merely to satisfy outdated assertion.
- Reduce arena roster scroll min-size to keep action buttons visible at 1280x720, preserving 90-row search limit.
- New `godot/tests/presentation/c4_be01_real_hunting_ui_smoke_test.gd`: isolated real new-game P3.2 scene, actual Thế Giới button, actual HuntingPlayPanelV2 showing 3 authored regions / 5 tiers, canonical state not touched by open and no imaginary encounters.
- Superseding one-click bundle pinned to later HEAD runs **previously unexecuted 05–11 plus new UI smoke**. It collects **all** focused outcomes before reporting and avoids PowerShell 5.1 native stderr terminating early. Earlier 02–04 PASS evidence is retained with its exact SHA and unchanged simulation code; optional rerun in future if authority code changes.
- This log does not make any later SHA automatically PASS. Godot 4.7.2 focused/runtime / 1280×720 click-through and real PvE claim still pending.

