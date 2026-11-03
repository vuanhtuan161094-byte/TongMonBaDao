# G0 TEST-FIRST — Natural New Game → six V2 recruits → Source A 6v10 → Save/Reload

**Date:** 2026-11-03 (Asia/Bangkok)  
**Official engine:** Godot `4.7.2.stable.official.ed1daf0bf` (Linux GitHub Actions headless; **not** Windows physical mouse or Android)  
**Overall:** **G0 NATURAL ENTRY-TO-PVE: PASS**. Full match completion, rewards, V6.3 post-integration, visual acceptance: **NOT_TESTED / PENDING**.

## Exact source authority and immutable scope

- Repository: `vuanhtuan161094-byte/TongMonBaDao`.
- PR [#67](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/67) code branch source snapshot used: `f2ae694af791a27deec4e1de7ae7c122914be635` (Draft, not merged).
- `main` was `c0c1382f119599497b52d8ee8abd9e830a883f1e`, untouched.
- Isolated QA branch: `qa/g0-natural-newgame-six-v2-pve-20261103`, branched **directly** from this PR HEAD. No production or gameplay files changed. Permanent artifact: `godot/tests/presentation/g0_natural_newgame_six_v2_pve_test.gd`, plus this report.
- Temporary bridge was inserted into `godot/tests/presentation/p3_o2_recruitment_map_test.gd` **on QA branch only** to invoke the new test in a separate official Godot executable through the existing O2 workflow. It was removed after evidence capture by commit `c8c1b95bcef0d67db918b1badf58fab3aeadeb80`. Final O2 blob `04041836e4a7c122caa4d6fd2c9f7a8d61552348` is **byte-identical** to the exact PR #67 base.
- No new/replaced `DiscipleState`, `CandidateState`, item, token, gold, resource, House or combat actor was fabricated. Never used the 130-disciple endgame QA seed, copied hand-created V2 recruit fixture or retroactively promoted the six legacy founders. The fresh P3.2 game scene creates the state through `LiveGameRuntimeV2.start()` and `P37Factory`.
- No changes to P3.2, source assets, CombatStats, recruitment/building/housing authority, runtime clock, SaveService, PvE combat, economy, loot, balance, V6.3 feature gates, telemetry, PR #67 or main. This QA branch may be abandoned without affecting the player save.

## Official runtime: GREEN evidence (not static inspection)

**[Run 41592972229 — P3 O2 Recruitment Map GitHub Actions](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41592972229)**  
Tested SHA: `6ba0c6a17b9b978ced8e093fc446848da5666609`; job `125773708743`; workflow **SUCCESS**, **25/25 GitHub job steps**. O2's own production acceptance PASS. Then O2 launched a **separate official Godot executable** with `--headless -s res://tests/presentation/g0_natural_newgame_six_v2_pve_test.gd`; the child test reported **exit code 0** with `G0_NATURAL_TEST_FIRST_GREEN`. All G0 results below are **from the separate child process**, not inferred from O2's parent success.

| Stage | Actual official Godot log evidence | Result |
|---|---|---|
| Natural New Game | `G0_NATURAL_NEWGAME_BASELINE_PASS`: six legacy founders, 0 PvE-ready V2; 8 beds, 3 original Chiêu Mộ Lệnh, 3 initial candidates, 500 initial spirit stones | **PASS** |
| Paid House #2 | `TRI03_G1_NEW_GAME_BUILD_PASS`: legal site (94,73), explicit map confirmation, 40 Linh Mộc, 30 Thanh Thiết, 500 stones debited **exactly once**; real receipt `map-house:0:94:73:new`, 60 simulation-minute construction timer | **PASS** |
| No premature beds | 8 legal beds retained until completing the scheduled last tick; actual `BuildingSystem.process_tick` via the canonical `SimulationScheduler` | **PASS** |
| Construction COMPLETE | `G0_NATURAL_ANNEX_COMPLETE_PASS`: 60 canonical scheduler ticks, second Residence ACTIVE, **16 actual beds**, Hall rank Nhân 1 **legal recruitment cap 12**, original receipt preserved | **PASS** |
| Six real Dẫn Tiên acceptances | `G0_NATURAL_RECRUIT_ACCEPT_PASS` six times; IDs `candidate_0004`, `candidate_0005`, `candidate_0006`, `candidate_0007`, `candidate_0008`, `candidate_0003`; roster rises 7→8→9→10→11→12; all six complete V2 birth and `DiscipleRealmProgressV2.progression_ready` | **PASS** |
| No fake recruitment grants | All three original Chiêu Mộ Lệnh **remain at 3** after six real accepts; initial P37 queue and canonical Dẫn Tiên daily arrivals supplied candidates. No manual candidate injection or free token grants | **PASS** |
| Eligibility / UI picker | `G0_NATURAL_PVE_SELECTOR_PASS`: exactly six legally admitted V2 disciples are healthy, Injury=0, at sect, free of conflicting work/persistent hunt, and **actual P3.2 selector is enabled** | **PASS** |
| Actual Source A hunt | `G0_NATURAL_SOURCE_A_6V10_PASS`: clicked real `PvePartyPickerStart` via button signal, encounter `pve:thanh_truc_lam:c01:31012026:60:0`, one canonical active multicamp, **six disciple actors + ten monster actors** | **PASS** |
| Save/Reload in process 2 | `G0_NATURAL_PROCESS2_SAVE_RELOAD_PASS`: independent Godot process loads original SaveService JSON; two houses, 12 roster, six V2, identical active encounter, same 6v10 actor counts | **PASS** |
| No premature invented loot | zero reward claims and zero settlement receipts before full victory; parent warehouse unchanged by early hunt/save; no fabricated monster loot or XP | **PASS (within early-active-run scope)** |
| Final marker | `G0_NATURAL_NEWGAME_SIX_V2_PVE_PASS`; `G0_NATURAL_STANDALONE_EXIT=0` | **PASS** |

**Testing time / wallet clarification:** the test **fast-forwards 60 real game simulation minutes by invoking the canonical scheduler**, not by sleeping 60 wall-clock minutes. It never sets a House's `status`, `level`, construction due tick, inventory or capacity directly. The 40/40 initial warehouse resources and 500 stones come from the real new-game factory; construction consumes 40 Wood, 30 Ore, 500 stones once. This proves that the authored economy/bootstrap makes the *first* annex affordable, **not** that a human played for 60 real minutes.

## Red/green chronology and parser fix (no game bug)

- First official O2 CI [41592452343](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41592452343): parent O2 SUCCESS but child **exit 1** due to test-only GDScript mixed tabs/spaces, `Parse Error: Used space character for indentation instead of tab`. **Not a gameplay blocker.**
- Commit `9dae6734e2be6ad4f8ccdb4af4a9884e85af9b3c` converted QA test lines to canonical tab indentation, no production change.
- Second official O2 CI [41592972229](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41592972229): child **exit 0** and all listed natural six-V2 markers GREEN.
- Temporary test adapter removed and original O2 source fully restored at `c8c1b95bcef0d67db918b1badf58fab3aeadeb80`. This means final QA checkout has precisely the tested G0 script and PR67 production code; the O2 temporary bridge itself is not retained.

## Honesty boundary / remaining G0 and PvE gates

- **NOT_TESTED:** defeating all ten monsters, persistent full skill rotation, genuine skill hit/HP delta for a natural newly recruited team, organic loot/XP settlement, respawn, 20 zones, economy progression after victory, long play-session/save after combat resolution.
- The prior **PVE-01B independent** QA test proved V6.3 ON/OFF, an authentic cast and **28.56 HP damage** and two-process Save/Reload, but used a **130-disciple QA fixture**. That remains separate; **PVE-01B two backend commits have NOT been cherry-picked into PR #67**, so the natural-path test is only for current default-OFF V6.3.
- The test proves actual **B1 UI callback route with synthetic test input signals**, not physical mouse/touch acceptance. Android landscape and owner visual approval remain **PENDING USER**.
- `6v10` is the **current Thanh Trúc Lâm party pilot**, not a hard global PvE roster cap. `HuntingPveRunV2.begin_multicamp` accepts 1–6 members in a team and group/cluster limits are distinct.
- Other old PR #67 CI debts, including DV2-03 old oracle, GP/O6 locators and DV2-02 balance, are outside this QA-only task; do not declare repository-wide G0/G1/G2 or PvE completion based only on this focused GREEN.
- Gameplay blockers to **enter** PvE from natural New Game on this pinned SHA: **none reproduced**. This is evidence of reachability, not end-to-end progression balance.
- Physical Windows mouse, Windows UI/GPU stability, Android and owner sign-off are **PENDING USER**.

## How to rerun (official Godot 4.7.2)

```bash
godot --headless --path godot --editor --quit
godot --headless --path godot -s res://tests/presentation/g0_natural_newgame_six_v2_pve_test.gd
```

The test uses an isolated `user://tri03_recruited_hs09_flow_natural_six_v2_<pid>.json` save path and deletes only its own QA save/temp artifacts after PASS. For official Windows use the installed Godot 4.7.2 binary, a dedicated QA profile, and do not touch the player's default save. The 1280×720 physical mouse and Android device tests are separate acceptance items.

**Rollback:** drop branch `qa/g0-natural-newgame-six-v2-pve-20261103`; PR #67 and main were never changed. Reverting QA-only commits has zero production migration/SaveService impact.
