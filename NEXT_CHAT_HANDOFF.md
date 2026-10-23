# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

## 2026-10-23 — PLAYABLE V1: MAIN-SCREEN CARE HUNT INTEGRATION

The local branch `integration/b3-playable-care-v1-20261023` is based on tested CARE code `862a6f6ef0f6e557ee6ef6f1044fd30b709870a3` (same Godot source tree as PR #24). Code SHA `42ef6bfdfa497d75d7c0355e3f7f2e5a7ebf9eda`; final test SHA `10dd28765a19402cc74a47e5d62749dac5d545f2`. PR #24 is still draft/open/unmerged and untouched. Do not merge without owner approval.

**Code scope:** `godot/src/presentation/p3_2_landscape_sect.gd` plus `godot/tests/presentation/b3_main_hunt_integration_test.gd`. No scene-file/backend/runtime/save/clock changes; no Source A, MAP25, C4, Character Studio or V5; no hunting EXP. P3.2 now admits a selected authentic V2 disciple into existing B3HuntWorld from the actual main scene; the same runtime owner/SimulationState/Scheduler/SaveService remain authoritative. A real Combat V2 kill credits the canonical Warehouse and durable receipt; defeated member returns to sect with Injury120, AUTO REST recovers, same disciple re-enters the same world at tick120 and earns a later loot receipt; manual return and One Active Job rejection are covered.

**Verification at `10dd287`:** official Windows Godot 4.7.2, clean isolated test profile, focused set **13/13 PASS**, exit 0 and PASS marker for each. Per-test logs plus `RESULTS.json`: `E:/codex/2026-10-22/t-ng-m-n-b-o/outputs/PLAYABLE_V1_CARE_20261023/focused_isolated_final_10dd287/`. Exact in-engine main-screen cycle evidence is in `b3_main_hunt_integration_test.stdout.log`. One earlier run against shared user data hit a historical O6 `.bak`; the clean-profile rerun of O6 and the entire final suite passed. No FULL/CI was run.

**GUI evidence:** actual P3.2 Godot Movie Maker render on Intel Iris Plus, official 4.7.2, 1280×720. Screenshot `E:/codex/2026-10-22/t-ng-m-n-b-o/outputs/PLAYABLE_V1_CARE_20261023/main_hunt_gui_1280x720_10dd287_final.png`; video `.../main_hunt_gui_1280x720_10dd287_final.avi`; logs in the same folder. The capture shows a live regenerated monster, AUTO on, real disciple HP/Injury/Tu Vi, one paid kill, Warehouse +1 and a successful reload of the main SaveService record. Capture is scripted/signal-driven, not manual input.

**PENDING USER:** manual Windows input; Android device/APK/touch/landscape; Source A asset import/provenance/animation acceptance; scale and real power/storage failure tests. Use the two continuity files as status authority. Next work is review of this stacked integration and owner decision on its PR; do not merge it or CARE #24. No adjacent system/code authorization is inferred.

---

## 2026-10-22 — SIX TMB SKILLS SELECTIVE PR; CARE INTEGRATION SEPARATE

Fresh main verified through authenticated GitHub API: `461caca1171462e0da092f21108c5c1733157ad9`. Skill source pinned at `d6fa3d5905af9555a24c7347df6b6434802cb288`, selected paths only: six `.agents/skills/tmb-*/SKILL.md`, two AI_AGENT_SKILLS docs, additive AGENTS routing and these two continuity files. No Godot/Source A/test/balance edit; no FULL or CI requested for this docs-only PR. Worktree: `E:/codex/2026-10-22/t-ng-m-n-b-o/work/TMB_main_skills_20261022`.

Actual Codex app-server skills/list discovery: six repo-scoped enabled TMB skills, no discovery errors; explicit director/evidence skill reads performed. A projectless chat is not the repo skill catalog and no global ChatGPT installation is claimed. See the two skill docs for evidence and routing. Source branch preparation/no-authorization statements are historical; current user authorized this selective integration. **Main does not contain these skills until this PR is owner-reviewed and merged.**

CARE source `35ffa85fd45da42e43722e7ac74b7423602d4491` and FAST-TRACK `1d686dc8e202f4831fa51373c15e6666f44702f9` are authentic local bundle history descending from main through accepted PH0 `97a3d98094451e85e8d5f26e8986a60968512ee5`. Supplied CARE ZIP has 73/73 verified manifest entries, 15/15 focused and real GPU-rendered GUI proof; integration runtime regression is a separate CODE PR gate. Do not relabel provided artifacts as a new run or claim CARE already merged.

**Owner correction:** pill satiety **1000000/day/disciple**, canonical `floor(tick/1440)`; 100000 was a typo. Preserve Hoi Xuan10/+55HP, Tu Khi25/+10000 fixed Tu Vi, recipe2 herbs+1 grain/base6 ticks, Injury120, Combat V2, canonical Warehouse/time/save and One Active Job. This does not authorize any other balance or Source A changes.

All other branch families (G1/MAP25/C4/economy/UI/asset/docs) remain inventory/review items, not blanket merge candidates. Runtime ownership overlap or missing exact integration QA blocks their auto-merge. Windows manual input, Android, physical power/storage failures and 1k–3k performance remain PENDING USER. GP-02C1 overall QA OPEN and DV2-03 PAUSED statuses below are not silently closed.

Next: obtain owner review of the concrete skills PR; prepare the separate CARE PR on current main, rerun affected and cumulative contracts without weakening tests, preserve source provenance and rollback. Record PR/merge SHAs after real operations; never invent a main/merge SHA. No pending decision to change the already-correct satiety cap.

---

## CURRENT HANDOFF — 2026-10-15 ECONOMY-A INTEGRATED ON MAIN (WINDOWS QA VERIFIED)

**Authoritative latest state:** Economy-A PR [#1](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/1) **MERGED** into GitHub `main` via merge commit `0689d0ddf0ebd72463d08bad4835c60428c64d24`; PR HEAD `4a6937dc28d477be13ffc0283d44cc74fe610733`. Last gameplay/test SHA `95bf06ecfd2c7fce5026d4485af55a5a3c40d909`. Post-gameplay branch commits altered **documentation only**. **18/18 official Windows Godot 4.7.2 automated QA PASS, 0 FAIL** from owner-uploaded `20261015_135007.zip`, SHA-256 `2d35d82d7eadf44ae06407c3899a36facf480c05b14c2922b22041062d3531f6` (all exit codes 0 and PASS markers independently inspected): Economy-A simulation/UI, GP-01/02A/02B1/02C1 sim+presentation, O3–O9 including standalone O6 with unchanged `==4`, SAFE-01/02, P3.7 FULL. Isolated detached worktree did not change original local repository or saves. The two expected negative-fixture diagnostic stderr cases (invalid saved PvE and corrupt JSON) do not negate test PASS. Full evidence and pilot balance in the **latest top section of `CURRENT_CHECKPOINT.md`**.

**Validation authority for merge:** owner directed local Windows testing because GitHub Actions quota was exhausted; Windows 18/18 evidence accepted as Economy-A merge gate. Official Linux on the **exact latest gameplay SHA** remains `PENDING CI`, since [#38684703913](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38684703913) failed before runner/job steps on all attempts. Do not convert that to Linux PASS or gameplay FAIL. The previous Linux green SHA `40eaa214` does not test final Field/Alchemy wages.

**Still pending / separate:** Windows **manual GUI screenshot** acceptance, real Android APK/touch/landscape, physical interruption/storage errors, target-hardware 100/500/1000/3000 disciple load; GP-02C1 overall QA remains OPEN, DV2-03 remains PAUSED NOT CLOSED, DV2-04/FE-02/Economy-B/C not authorized. User's original local `main` may be stale (`0439b34b...` in the Windows QA log); do not assume it was synchronized by the detached QA runner. Sync locally only through authorized safe workflow, without losing untracked local QA scripts or saves. No further Economy-A code mutation from this integration alone.

---


## CURRENT HANDOFF — 2026-10-15 ECONOMY-A COMPLETION BRANCH, INTEGRATION QA PENDING

Read `CURRENT_CHECKPOINT.md` top and the current section of the canonical `docs/QA_DEBT_MASTER_AND_BACKEND_REDESIGN_HANDOFF_2026-10-13.md` first. Baseline main `c64c61029ab6f569a66aba1f1cbeed3bd76f796e`; the owner's new comprehensive Economy-A instruction supersedes the old "next packet needs authorization" note below **only for Economy-A**. Earlier CODE-A official Linux Godot 4.7.2 focused/FULL/O6 green at `ed594e45` [#38678314842](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38678314842). The owner requested complete Phường Thị buy/sell/merchant stock and bounded automatic personal spending, which the older implementation did not have.

Branch `economy-a-market-completion-20261015` has the smallest corresponding edits in `SectState`, `EconomySystem`, owner-approved `BuildingSystem`, current P3.2 landscape UI, two dedicated tests and current checkpoint/debt docs. It uses Sect Warehouse for player inventory, persisted merchant stock for NPC inventory, simulation-day limits, actual Stones, receipts and replay checks. Auto HP spending has an adjustable per-disciple daily Stone ceiling, default 6, while auto policy stays OFF by default. The first market-buy SHA `40eaa214` passed official Linux focused/FULL/O6 [#38682499335](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38682499335). Later branch commits added the spending cap and its assertions. Latest exact-SHA official CI is PENDING; intermediate runs with zero runner/steps are infrastructure failures, not gameplay PASS. Official Windows Godot 4.7.2 headless focused Economy-A simulation, live landscape UI, GP-01/02A/02B1/02C1 simulation+presentation, O3/O4/O5/O6/O7/O8/O9, SAFE-01/02 and cumulative P3.7 FULL PASS on gameplay/test SHA `95bf06ecfd2c7fce5026d4485af55a5a3c40d909`, with isolated test user data to avoid historical `.bak` recovery. FULL exit 0, terminal marker `P3.7C1 FOUNDATION + DAN TIEN FULL GATE: PASS`, log SHA-256 `795116691D5F95222A9AE96E59784DFC4C95DE092CA4E51AD688CC43F1606E26`. This is headless test evidence, not physical GUI/device approval. Keep O6 `==4`, Injury 0/1, valid `carried_units`, legacy P2 currency, single Warehouse/Scheduler/job owner and locked balances unchanged.

**Owner-approved Field/Alchemy completion:** `BuildingSystem` now persists Economy-A wage eligibility for new authentic V2 jobs, retains Field/Alchemy work when the Warehouse cannot accept output, and settles one Sect-funded wage after delivery. Old jobs without wage eligibility remain unchanged. Dedicated focused tests cover both facilities at full Warehouse, save/load, retry and replay. Field's existing planting EXP timing remains unchanged; no Injury, O6 assertion, SaveService or Scheduler edit occurred.

Before merging or claiming CLOSED: verify remote main still at expected base, review branch diff against the allowlist, obtain exact-SHA official Linux focused + FULL + O6 once Actions assigns a runner; #38684703913 attempt 2 had no runner/steps. Windows cumulative FULL already passed at gameplay/test SHA `95bf06e`. Then update these docs with Linux run links. Windows GUI/manual and Android APK/device, power/storage and 1k–3k performance remain PENDING USER. GP-02C1 overall QA remains OPEN, DV2-03 PAUSED, Economy-B/C, FE-02, DV2-04, map/visual and Injury redesign outside authorization. If current CI cannot start a runner, report PENDING CI and keep integration open; do not map previous-SHA green to latest code.

---


## CURRENT HANDOFF — ECONOMY-A CODE-A LINUX CLOSURE VERIFIED; NEXT PACKET REQUIRES OWNER AUTHORIZATION

**Owner CODE-A authorization: 2026-10-15.** Main gameplay+test SHA `ed594e45a308eb55ad9373e703b807365b26c9aa`, next commit(s) DOCS ONLY. The original comprehensive Playable Economy A/B/C plan and governance are in `AGENTS.md` §3, `docs/GAME_SYSTEM_ARCHITECTURE.md` §4 and the next historical handoff below. **Current live truth** in the newest `CURRENT_CHECKPOINT.md` top supersedes old DESIGN ONLY instructions below.

**Delivered CODE-A:** seven authorized production files, two new genuine tests, one workflow; optional V2 Sect/personal Stones and durable receipts, authentic V2 Mine/Forestry timed packets while preserving pre-existing carry/haul jobs, wage from Sect only on completion, bounded NPC Warehouse sales respecting stock/reserve, small personal HP restoration service paid with personal Stones (Injury 0/1 UNTOUCHED), Main Hall/Phường Thị/personal balance screens in the existing Godot landscape scene, SaveService/offline no second scheduler. No PvE Spirit Stone split or equipment V2, no new warehouse/manager/renderer. Real pilot defaults: wage **2** stones/batch, duration **10** simulation ticks (modified by real work speed), market **20** units/day and max **5**/order, personal HP service **3** stones for **10 HP**, auto service disabled, sect pay reserve 0. ResourceRegistry existing `market_value` pilot; nothing numerically locked. Enabling from Hall persists via state; legacy systems keep opt-out behavior.

**Verified official CI:** [#38678031221](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38678031221) **COMPLETED/SUCCESS** at gameplay/test `9f109c57`, including Economy focused/UI, GP-02C1/02B1/02A/01, O2/O3/O4/O5/O7/O8/O9, SAFE, DV2 and **P3.7 FULL + O6 standalone PASS** with O6 exact `==4` assertion unchanged. The final **test-only** addition is a true `SimulationRuntimeOwnerV2` saved-timer wall-clock offline replay/reload with one stock and wage settlement at SHA `ed594e45`. [Final run #38678314842](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38678314842) is now **COMPLETED/SUCCESS on exact final gameplay/test SHA `ed594e45a308eb55ad9373e703b807365b26c9aa`**: focused and landscape UI, real wall-clock offline/reload, GP-02C1/02B1/02A/01, O2/O3/O4/O5/O7/O8/O9, SAFE, DV2, **P3.7 FULL cumulative and O6 standalone (`==4` intact) PASS**. The historical old O6 failure origin remains unknown; newer standalone O6 is proven PASS. Since older O6 run `a327ab59` failed, historical cause remains unknown, but O6 on `9f109c` is verified PASS.

**CODE-A accepted closure boundary:** the Economy-A implementation packet is CLOSED for its scoped **official Linux Godot 4.7.2 focused+FULL+O6** contract at gameplay/test SHA `ed594e45` (documentation HEAD may be newer). Windows GUI, Android touch/APK, real failure modes and target-hardware scale are separately PENDING USER, NOT visual acceptance. **Next owner decision:** authorize B V2 equipment/PvE separately; or focus a separate Economy-A2 extension for other activity wages/advanced market/player policy/performance. Keep Injury 0/1 and GP-02C1 QA OPEN until separately accepted; do not start another packet without explicit owner permission, do not weaken O6 or migrate away valid carried_units.

**Unresolved debt:** GP-02C1 still QA OPEN for Windows/physical evidence; DV2-03 PAUSED NOT CLOSED. Windows GUI/Android APK, device kill/storage/power, 100–3,000 population performance **PENDING USER**. Body gate/DV2-04, FE-02, B/C, new Injury 0–3, equipment V2 and PvE 60/40 were NEVER authorized in CODE-A. Future production categories' salary/receipt compression/UI policy depth require separate decisions.

---

## CURRENT NEXT WORK — 2026-10-15 OWNER GOVERNANCE UPDATE + ECONOMY-A DESIGN READY + INJURY REFERENCE STUDY

**READ FIRST: updated `AGENTS.md` §3 and `docs/GAME_SYSTEM_ARCHITECTURE.md` §4.** The owner explicitly removed the global one-phase-at-a-time barrier. Unrelated OPEN QA and PAUSED design debt do not automatically bar newly authorized CODE packets; one writer per overlapping file/system and one integration owner for shared state are mandatory. **No Economy-A or Injury code has been authorized.** This is a DOCS-ONLY governance/handoff change; do not claim a gameplay or CI SHA from it.

### Verified baseline and debt

- TMBĐ `main` before this docs-only chain: `0439b34b16ea516c6100493f96d4a20be1754581`. GP-02C1 gameplay/test: `c8ec094c0bc8653b1438172de1d9338a6c0d28ea`, official [Linux Godot 4.7.2 GP-02C1 focused + P3.7 FULL PASS #38369220631](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38369220631). GP-01/02A/02B1 CLOSED.
- **GP-02C1 OVERALL QA OPEN**: [O6 standalone fail #38360325913](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38360325913) was at older `a327ab59` with exact available-ore `==4` fixture; standalone O6 at current gameplay SHA is NOT VERIFIED. No fixture/prod edits or QA rerun happened in this governance task. **DV2-03 PAUSED NOT CLOSED**. Windows GP-02C1 headless/GUI, Android device, real power/storage failure, scale tests all PENDING USER; earlier GP-02B1 Windows 24/24 is NOT GP-02C1 acceptance.
- QA debt master remains `docs/QA_DEBT_MASTER_AND_BACKEND_REDESIGN_HANDOFF_2026-10-13.md`, and PC collection tool remains `tools/qa/RUN-QA-DEBTS-WINDOWS.cmd`. Do not create competing trackers or erase debts.

### ECONOMY-A — ONE proposed CODE packet, DESIGN/PREP ONLY, user must give new CODE authorization

**Product scope:** Playable Economy V1 milestone A operations/economy, followed separately by B equipment/PvE, C Android/balance. This stage is **one integrated implementation packet**, not several unrelated phases. 1280×720 Android LANDSCAPE current UX baseline.

**Reuse actual authority:**
- V2 Sect balance already `SectState.spirit_stones` and personal V2 balance already `DiscipleState.spirit_stones`. P0–P2 `SectState.treasury` and `DiscipleState.wallet` and `EconomySystem.sell_inventory` are distinct legacy semantics; do NOT relabel, silently migrate, or transfer them into V2 Spirit Stones.
- One `WarehouseSystem` with reserve/lock; only Sect owns item identity `SectState.equipment_items`, whether allocated/equipped. One `SimulationScheduler` with 1 simulation minute/tick, mapped by `SimulationRuntimeClockV2` to 60 real seconds. One disciple active job; idle/passive Tu Vi is not another job.
- Existing Mine+Forest `BuildingSystem` definitions are `carry_cycle`. New Mine/Forest jobs may use `BuildingState.production_state` finish-tick deterministic packets; **legacy-drain** any valid `work_cycle_state` and `carried_units` first without destroying, double-crediting or resetting. Visual moving/mining/hauling is presentation only and must not determine the production settlement.
- Spirit Field plots and existing timed Alchemy `hoi_xuan_dan` are real production and must stay working; forge and equipment P2 functionality are regressions to preserve, NOT a V2 equipment redesign here.
- Define one V2 economy command/receipt transaction family for actual Stone transfers, wages and bounded NPC market settlements; unique IDs and once-only receipts persist with `SimulationState`/Sect state. Sect pays disciple only on **legitimately completed** production jobs; wages are zero-sum transfer, not currency mint. Sect services charged to personal stones only on authorized completed usage. Real NPC market buying Sect surplus is an explicit external Stone faucet, limited by per-period demand and reserve rules. No sale of fictitious/negative stock or automatic use of all stored reserve.
- Sect Master may configure budgets/auto-spend policy and protect reserves. A disciple may spend only personal Stone balance within approved service categories/budgets; no buying/ownership transfer of unique Sect equipment. Currency-negative, repeated-claim, partial-input-consumption and wrong worker owner fail closed.
- **No numeric balance decision in this docs update.** Duration presets (examples 1/2/4/8h), batch quantity, EXP, wages, personal allowance, merchant buyback price/caps, expense budgets, opening treasury and all new rates are explicitly **PILOT UNLOCKED / OWNER DECISION NEEDED**. Do not silently use P2 market prices for V2 commerce. Pilot PvE 60/40 remains for milestone B, not payable in A.

**Proposed CODE-A owner/allowlist (conditional on next specific instruction and fresh main diff):**
1. Core state + V2 transaction API: `godot/src/simulation/economy/economy_system.gd`, `godot/src/simulation/state/sect_state.gd`, `godot/src/simulation/state/disciple_state.gd`, `godot/src/simulation/state/simulation_state.gd`. Preserve P2 APIs and prior GP-02C1 save structure.
2. Single-clock job and settlement: `godot/src/simulation/building/building_system.gd`, `godot/src/simulation/workforce/workforce_system.gd`, `godot/src/simulation/core/simulation_scheduler.gd`; `godot/src/simulation/resource/warehouse_system.gd` only if truly required for reserve/atomic batch integration, no parallel warehouse.
3. Player-facing panels/command bridge: `godot/src/presentation/p3_2_landscape_sect.gd` (and `p3_1_landscape_sect.gd` only if an explicitly justified shared presentation dependency). Reuse current main scene and existing icon/art, no FE-02 or a new map renderer. `godot/src/simulation/save/save_service.gd` and `live_game_runtime_v2.gd` initially OUT OF SCOPE unless compelling evidence proves a targeted migration/clock defect and user extends allowlist.
4. NEW dedicated focused V2 economy/timer/market + E2E tests and one CI workflow under `godot/tests/simulation/`, `godot/tests/presentation/`, `.github/workflows/`, **paths to be named in the actual CODE authorization**, not permission from this plan. Avoid extra service/scheduler manager.
5. B/C OUT: `hunting_pve_run_v2.gd` and V2 reward 60/40, V2 forging/loadout/items, Android APK approval, FE-02, DV2-04, HP/Injury rules, resource grade tables, Rèn Thân costs, new construction economics and unlocked phase balance.

**Acceptance/QA gates for eventual CODE-A:**
- E2E from fresh authentic V2 recruitment → Mine+Forest packet timer → lawful cancellation loses only unearned progress → exactly-one Warehouse material credit and worker EXP/payroll → Field/Alchemy untouched → market sells only real available surplus, bounded external Stone income → personal service debit/policy limit → balance and journal invariants → save before completion / after settle / offline / reload twice with unchanged receipts. Preserve P2 legacy separately.
- Test legacy save with miner/forester in TRAVEL/EXTRACT/HAUL and valid carried units; no loss, no phantom extra +1, no double reward, no action conflict. Injured actor remains eligible for production but not PvE; existing GP-02C1 terminal receipt/save unchanged. Respect one-active-job guards across training/field/alchemy/PvE.
- Parse/FAST official Godot 4.7.2 focused, cross-regression GP-01/02A/02B1/02C1, O3/O5/O6/O7/O8/O9, SAFE-01/02, DV2 live and full P3.7 cumulative before integration/claim of packet PASS. Historical O6 red must first be reproduced/isolated on the actual starting and updated code; since A edits Mine, an O6 fail **cannot be called an unrelated PASS-equivalent**. If old fixture is wrong, request separately authorized TEST-ONLY repair; never weaken `==4`, alter materials or discard valid carried units just to pass. Windows/Android hardware acceptance remains PENDING USER.
- No packet may report CODE-A PASS on static reading or on the previous GP-02C1 SHA. Ask user for explicit CODE-A permission and pilot numeric contract before writing gameplay; current request did NOT supply either.

### Injury redesign study — 最强祖师 reference; **not yet approved as TMBĐ gameplay**

**Verified client evidence at ZQZS-Source-Knowledge `main` 83cbc4ec:**
- `sources/APK/data/config.discipleinjuryconfig_TextAsset_-4470530575966013167.bin.lua`: 0–30 Sức khỏe; 31–100 Thương nhẹ; 101–200 Thương nặng; 201–255 Nguy Kịch; associated effect-code 301/302/303 percentages −10/−50/−75 at bands. Client config alone does NOT prove what each effect code means in server combat or how damage causes injury; fields `autogrow=10`, `rate=25` have unverified server semantics.
- `sources/APK/binary/gui.windows.disciple.uidisciplebatchzhiliaowin_TextAsset_5364069587761784085.bin.lua`: actual client grid displays Injury points, category/icon, treatment pills with `funcparam.heal`, predicted decrement, inventory counts and batch use. `gamesys.fullscreen.uifulldisciplebatchtreatcontrol` shows mass treatment. `gamesys.guildorder.ai.guildorderai_autotreat` shows configurable treatment-auto selection. These are **client UX/logic observations**, not verified real-server progression.
- Existing TMBĐ Injury canonical GP-02C1: `injury_level` only 0/1, any HP=0 during PvE sets HP1/Injury1 at terminal, auto-clear after exactly 120 scheduler ticks including offline; injured cannot PvE, CAN continue production/Chuyên Tu/Rèn Thân; injury and HP independent; settlement/claim exactly-once; previous valid saves migrated safely. The 120 ticks clear the binary flag, NOT one point of an already-live multi-point scale.

**Simplified redesign OPTION (not locked):** 0=Khỏe, 1=Thương nhẹ, 2=Thương nặng, 3=Nguy kịch; HP stays separate, no death/permanent disciple deletion, any Injury>0 blocks PvE, production/training remains legal. Ordinary V2 knocked-down event produces 1 (compat with existing saves); level 2/3 only if explicitly designed special severity sources exist, **not** by re-entering PvE while wounded (impossible under blocked-PvE rule). One existing scheduler clock; candidate each 120 simulation ticks naturally reduces one severity level (so 1→0 in 2h, 3→0 in 6h), while treatment using a real, separately approved canonical pill can reduce one level on exactly-once Warehouse debit; never fabricate a drug, worker/job, another timer or charge. UI compact status/category/remaining time in existing Disciple panel; later optional multi-disciple treatment and auto-policy; if healing is implemented it needs a dedicated Injury CODE packet and actual resource/recipe authorization. No job-speed/EXP/combat debuff copied from ZQZS until explicitly decided; four grades are useful player information, not proof of penalty.
- **Compatibility obligations:** changing accepted `injury_level` range 0–1 to 0–3 requires a controlled version-compatible `SimulationState` invariant, `DiscipleState` serialization, PvE ingress/settlement, recovery timer and save-load-mid-treatment tests. Old Injury1+recover_tick must remain valid and continue clearing at previous tick; no rewinding/healing twice or overriding real HP. Existing `hoi_xuan_dan` is tagged healing, but no approval to make it Injury medicine or consume it automatically.
- Owner asked for redesign according to reference, but has not selected numeric recovery/dosing or penalties; **study only**. Do not modify GP-02C1 production for Economy-A, and do not claim Injury redesign APPROVED.

**Next suggested user actions:** (A) approve CODE-A precise allowlist and explicit pilot values, or (B) review/finalize simplified Injury design; both distinct from this DOCS-ONLY governance change. Do not launch either code packet without the next direct authorization.

---

## GP-02C1 — INJURY CODE + LEGACY SAVE FIX DONE; GODOT 4.7.2 FOCUSED/FULL PASS; OVERALL OPEN

**Live status authority:** top of `CURRENT_CHECKPOINT.md`. Last **gameplay/test** SHA `c8ec094c0bc8653b1438172de1d9338a6c0d28ea`; initial 14-file GP-02C1 packet and later **3 allowed file** compatibility repair only. Official [GP-02C1 CI #38369220631](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38369220631) **COMPLETED/SUCCESS** (exact `c8ec094c`) including parse, Injury focused T01–T23 + legacy save fixtures, genuine V2 terminal win/claim, GP-02B1/GP-02A/GP-01 and **P3.7 FULL cumulative**. Previous migration commit `003fb6f9` also focused+FULL CI green [#38368913311](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38368913311). Subsequent HEAD updates may only be documentation.

**GP-02C1 facts:** HP and Injury 0/1 separate; only battle-downed V2 actor Injury1/HP1 terminal; exactly-once terminal receipt independent of once-only reward claim; PvE reservation prohibits competing jobs; pilot instant in-Sect return after terminal, heal at 120 authoritative ticks, offline deterministic; injured actor remains eligible for legitimate production/Chuyên Tu/Rèn Thân, no new combat/EXP/warehouse/balance/penalty changes. **Fixed legacy active V2 PvE save:** `SimulationState.from_dict()` calls `HuntingPveRunV2.reconcile_loaded_v2_pve()` BEFORE offline catch-up; validates identities, roster ownership, work-state conflicts, HP/snapshot and receipts before mutation; rebuilds missing reservations for active fights; terminal old defeat auto-settles once, real old victory remains claimable once; invalid/conflicting snapshots fail closed with no state publication. Dedicated real SaveService/offline/claim tests PASS. No SaveService or save-version code change.

**Strict remaining issues:** GP-02C1 **NOT CLOSED**: unrelated historic O6 standalone [#38360325913](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38360325913) failed twice on older `a327ab59` with "4 spendable ore"; origin vs pre-GP-02C1 `0a29f9c6` not established and not rerun on last gameplay SHA. Do NOT touch Mine, transport, Warehouse, timers, balance or O6 test inside Injury. Owner specifically wants simple work gameplay and future **one-backend-module-at-a-time** redesign; source 最强祖师 client confirms visible AI work transitions, **not** authoritative server mine timers/yields. Defer architecture/economy redesign to separately authorized phase. Windows GP-02C1 headless/GUI, Android, physical kill/power/storage and 1k–3k load **PENDING USER**; GP-02B1 Windows evidence cannot stand in for GP-02C1. GP-01/02A/02B1 CLOSED, DV2-03 PAUSED NOT CLOSED, DV2-04/FE-02/LAY/ADR/S3/Spine unopened. **No further code authorization.**


---

## GP-02B1 CLOSED — 2026-10-13 · Backend V2 occupation protection / no next CODE permission

**Final tested gameplay SHA:** `0027878eba0b1287e9185bc6e6257060ad53bdb3`; initial code `b2ef5219d4dc1dc1df40c3efa9f0a4a7cfe994bd`, documentation-only closure HEAD `7535a8c1dbccb98bdb40087b0183fb2e4a3ad8c7` (Windows tested). **Run [#38335843100](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38335843100) official Linux Godot 4.7.2 COMPLETED/SUCCESS** covering GP-02B1, GP-02A, GP-01, O2/O3/O4/O7/O8/O9, DV2-E3.1/live, SAFE-01/02, P3.6A gameplay and P3.7 **FULL cumulative**. Read top `CURRENT_CHECKPOINT.md` for exact file diff, test evidence and unclosed debts.

- GP-02B1 code changed exactly `disciple_training_action_v2.gd`, `disciple_body_training_facility_v2.gd`, `workforce_system.gd`; added `gp_02b1_v2_occupation_guard_test.gd` and its workflow. Canonical V2 backend training entrypoints/legacy `COMMAND_CULTIVATE` now fail-closed against active Mine/Linh Forest carry-cycle, Linh Điền growing plot, Alchemy timed recipe; accepted Body/Chuyên Tu transfer and P2 compatibility remain. Body slot reservation no longer auto-settles/abandons a work carry. Real production, earned herb/alchemy receipt, offline save/replay, 1 Tu Vi source, and paid Body slot are exercised. No runtime/save/balance/warehouse/schema rewrite.
- **GP-02B1 Windows headless QA VERIFIED PASS — 2026-10-13:** User-provided `GP02B1_WINDOWS_QA_20261013_095905.zip` SHA-256 `595087982552a8a3d9a056a4570d1ff6fbb6a4e5b2a58a2df460665bd1e6f657`; inspectable `SUMMARY.txt` plus 24 individual logs show **FULL_PASS; 24/24 PASS; all exit 0; timeout=False**. Host `CTIC-LP-054`; Godot `4.7.2.stable.official.ed1daf0bf`; checked `main` docs SHA `7535a8c1dbccb98bdb40087b0183fb2e4a3ad8c7`, unchanged gameplay SHA `0027878e...`. Completed 2026-10-13 10:19:39 UTC+07. `09-GP_02B1_focused.log` and `24-P3_7_FULL_cumulative.log` contain exact PASS markers. Intentionally malformed JSON diagnostics in corrupted-save tests are expected, not regressions. Linux CI #38335843100 separately SUCCESS. ZIP is attached to chat, not stored in GitHub. **Windows headless only:** Windows GUI screenshots/visual acceptance, Android, real kill/power-loss/storage-full and scale 1k–3k remain PENDING/UNVERIFIED.
- **Debts still pending:** AI injury/rest/healing while worker reserved, direct non-training command cancellation semantics and TTL, comprehensive V2 hunting/work-life integration, 1k–3k load, Android device, live Windows/Android GUI/visual acceptance and physical kill/power/storage failure verification **PENDING USER**; Windows headless evidence verified, but no live GUI screenshot/Android evidence claimed. P3.6A Preview historical artifact quota failure remains separate.
- GP-01/GP-02A/GP-02B1 CLOSED; DV2-03 PAUSED NOT CLOSED; no DV2-04/FE-02/LAY/ENV-02B–E, ADR-0003/S3/Spine untouched. **Next safest option: READ-ONLY study of worker emergency HEAL/REST and command TTL, then request a separately bounded CODE decision. Do not automatically open that packet.**

---


## GP-02A CLOSED — 2026-10-13 · Handoff update / NO NEW CODE PERMISSION

**Final tested gameplay SHA:** `05ea66ed9559547d570fdd1a118ded768f243dfd` on `main`; documentation-only closure commit is newer. GP-01 remains CLOSED at gameplay `342aee6441bf4d5ac78258ab84265724bd58c240`. Read newest `CURRENT_CHECKPOINT.md` entry first.

- GP-02A changed exactly the authorized `godot/src/presentation/p3_2_landscape_sect.gd`, plus added `godot/tests/presentation/gp_02a_v2_cultivation_panel_test.gd` and `.github/workflows/gp-02a-v2-cultivation-panel.yml`. V2 Tu Luyện Đài now displays canonical snapshot realm/floor/XP/gate, P2 legacy UI remains isolated; player-facing Chuyên Tu V2 uses existing `_queue_v2_training`, and rejects real carry-cycle/field/timed recipe occupation without disruption. No backend/EXP/save changes.
- **Godot 4.7.2 official Linux CI #38332335827 COMPLETED/SUCCESS on final gameplay SHA**, including new GP-02A, GP-01/O2/O3/O9, DV2/SAFE and P3.7 **FULL**; separate DV2 #38332335736 SUCCESS. First code SHA `a370f6ea` failed P3.6A due debug player-facing text, corrected in `05ea66ed9559547d570fdd1a118ded768f243dfd` and full suite re-passed. P3.6A Preview #38332335834 FAIL artifact upload due GitHub storage quota; gameplay FAST and capture PASS, screenshot delivery not verified.
- **Strict outstanding debts:** only presentation-level occupation denial; an audit of direct backend caller exclusivity remains future. AI daily life (heal/rest/work transitions), PvE V2 integration, scale 1k–3k and real-device crash tests unverified. GP-02B **NOT authorized**; if user wants, propose READ-ONLY audit for smallest next packet. DV2-03 PAUSED NOT CLOSED, DV2-04/FE-02/LAY unopened, ADR-0003 fixed-layout, ENV-02A Windows/Android PENDING USER, S3/Spine untouched. Do not open a new packet automatically.

---


## GP-01 IMPLEMENTATION CLOSED — 2026-10-13, READ BEFORE OLD READ-ONLY HANDOFF

**Official gameplay code SHA `342aee6441bf4d5ac78258ab84265724bd58c240`, main.** User authorized **GP-01 ONLY**; work is **CLOSED**. Read top `CURRENT_CHECKPOINT.md` GP-01 closure for all exact evidence and caveats.

- Player Dẫn Tiên recruits genuine V2 → Mine team → explicit Mine worksite UI; no fake third slot, waiting members identified/blocked; scheduler performs true Mine cycle; Warehouse/EXP/natural Tu Vi canonical; mid-haul save, offline catch-up, replay no double reward.
- [GP-01 focused and full #38329564079](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38329564079) **SUCCESS**; [P3.7 FAST+FULL #38329563945](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38329563945) **SUCCESS**, [DV2 regression #38329564146](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38329564146) **SUCCESS**, all on gameplay code SHA. P3.6A Preview #38329564128 screenshot/artifact **upload FAIL due GitHub quota**, while gameplay/capture steps PASS. It is not a GP-01 code FAIL.
- Exact added files: `godot/tests/presentation/gp_01_v2_mine_vertical_slice_test.gd`, `.github/workflows/gp-01-v2-mine-vertical-slice.yml`. Code change is scoped to `godot/src/presentation/p3_2_landscape_sect.gd`. Existing WorkforceSystem, BuildingSystem, Scheduler, SaveService, WarehouseSystem were reused without modification.
- **No next CODE authorization:** optionally propose GP-02 scoped V2 everyday-action/consumer audit and later code **only on fresh explicit user instruction**. Parent DV2-03 PAUSED NOT CLOSED. ENV-02A Windows/Android PENDING USER, FE-02/LAY unopened, ADR-0003 unchanged, S3/Spine assets untouched, build/land prices TBD, SAFE mobile failure testing and 1k–3k performance unverified.

---


## FIRST NEXT CHAT ENTRY — GAMEPLAY END-TO-END (2026-10-13; NO CODE AUTH)

**Read in full:** [NEXT_CHAT_GAMEPLAY_DISCIPLE_TO_SECT_2026-10-13.md](docs/handoffs/NEXT_CHAT_GAMEPLAY_DISCIPLE_TO_SECT_2026-10-13.md), then CURRENT_CHECKPOINT top and core authority docs. Owner wants next chat to finish gameplay in priority order disciple identity/real effects → Tu Vi/body (DV2-03 still PAUSED) → daily actions/jobs/workers → building production/warehouse/upgrades → hunting/economy → later construction/land/UI. Deliver read-only implemented/partial/design-only gap matrix and one small executable next proposal, then request scoped code approval. SAFE-01/02 CI PASS; ENV-02A Windows/Android PENDING; ADR-0003 fixed layout unchanged; LAY-01–04 / FE-02 / ENV-02B-E NOT OPEN; DV2-03 PAUSED NOT CLOSED; S3 historical eight art approvals protected. No code/production scene/EXP changed by this handoff.

---

## DESIGN APPROVED — BUILDING / LAND (2026-10-13; NO CODE PERMISSION)

Owner **APPROVED DESIGN ONLY**: [`docs/design/SECT_BUILDING_LAND_EXPANSION_DESIGN_V1.md`](docs/design/SECT_BUILDING_LAND_EXPANSION_DESIGN_V1.md) §7. Principles: one future persistent `SectLayoutState` within `SimulationState` for building placement/roads/unlocked regions, existing `TransferMapModel` as projection, 192×192 world and 48×48 starter district, visual 16×16 chunk, Android landscape 1280×720, relocate buildings and pave roads for free V1; build/unlock economy TBD. **Do NOT modify ADR-0003 or implementation** without separate approval; fixed-layout remains production contract. Before LAY-01 code: ENV-02A official Godot Windows import/structure/map/camera/AStar and real screenshots/logs, owner acceptance, then separately authorize ADR migration and LAY-01. Android still PENDING. No `LAY-01–04`, `FE-02`, `ENV-02B–E`, DV2-03 remains PAUSED NOT CLOSED; SAFE-01/02 CLOSED, S3 unchanged.

---

## PRIMARY ENTRY — SAFE-01 / SAFE-02 CLOSED (2026-10-13)

Read `CURRENT_CHECKPOINT.md` top and `docs/handoffs/SAFE01_SAFE02_2026-10-13_CLOSURE.md`. Owner approved two minimal backend data-safety packets; both committed to `main`. `godot/src/simulation/save/save_service.gd` writes staged verified primary + .bak and recovers fallback; `godot/src/simulation/resource/warehouse_system.gd` merges legacy buckets transactionally and SaveService rejects failed migration. Save wire version, gameplay rules and content unchanged.

**Godot 4.7.2 CI PASS:** [SAFE workflow #38324783574](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38324783574), including full P3.7 cumulative. Android real-device crash recovery still PENDING USER. **ENV-02A isolated lab still Windows/Android PENDING; no FE-02/ENV-02B-E; DV2-03 PAUSED NOT CLOSED; S3 eight art approvals untouched.** Do not restart SAFE-01/02 unless new evidence shows regression.

---
## PRIMARY ENTRY — ENV-02A SOURCE MIRROR AND BACKEND AUDIT (2026-10-13; SUPERSEDES EARLIER ENV-01 ENTRY BELOW)

**Read:** `CURRENT_CHECKPOINT.md` top entry and [ENV02A_CODE_AND_BACKEND_AUDIT_2026-10-13.md](docs/handoffs/ENV02A_CODE_AND_BACKEND_AUDIT_2026-10-13.md).

GitHub `labs/env02a/` contains text-source only, not Source A PNG binaries. Full owner-hand-off archive: `TongMonBaDao_ENV02A_192World_Lab.zip`. Use matching original ZIP for Windows QA, not checkout alone. Godot 4.7.2 launcher `RUN_ENV02A_WINDOWS.cmd`; expected logs `ENV02A_TEST_RESULTS/{import.log,env01_regression.log,env02_structure.log,interactive.log,launcher.log}` and two real screenshots. ENV-02A Godot Windows / Android PENDING USER.

ENV-01 v4 import/structure and actual Windows screenshot PASS, manual selection/pan/zoom and Android unverified. Backend P3.7/M2/DV2 and FE-01 tools had historical official CI success, not a current whole-game Android PASS. **No production changes, FE-02/ENV-02B–E unopened, DV2-03 PAUSED NOT CLOSED; eight S3 artworks and Spine pipeline preserved.**

---
## PRIMARY ENTRY — ENV-01 WINDOWS QA (2026-10-12; SUPERSEDES OLD PV-00 HANDOFF)

**READ FIRST:** [`docs/handoffs/ENV01_WINDOWS_QA_HANDOFF_2026-10-12.md`](docs/handoffs/ENV01_WINDOWS_QA_HANDOFF_2026-10-12.md) and the top entry of [`CURRENT_CHECKPOINT.md`](CURRENT_CHECKPOINT.md). The PV-00, FE-01B and old code-gate instructions further below are **historical** and must not restart work already done.

**Current owner instruction:** ENV-01 isolated lab has been reported delivered and is awaiting real Godot 4.7.2 Windows QA, **not yet visual approved**. Next get the **actual ENV-01 ZIP or directory**, read its instructions, and collect real Godot screenshot + **two test logs** under `ENV01_TEST_RESULTS`. Do **not invent artifact paths or log names** and do not claim PASS from an import or historical screenshot. Windows executable: `E:\Godot_v4.7.2-stable_win64_console.exe`.

Original Source A asset handoff: `E:\TongMonIntegrationLab\ChatGPT_Handoff\SourceA_Map_Prep_20261012.zip`, owner/previous-chat audited 428 entries, not a verified ENV-01 code artifact. The chat assistant cannot directly access E:; if the ENV-01 artifact is missing from the new session, request that one file.

**Hard locks:** production P3.1/P3.2 and canonical gameplay/save unchanged; eight S3 artwork approvals unchanged; FE-02/G1 unopened; DV2-03 PAUSED NOT CLOSED; Spine converter parallel and no need to wait for static map. **No repeated catalog scan, no new map prototype.** Approval for isolated ENV-01 does not authorize production integration.

---

## HISTORICAL HANDOFF — FAST VISUAL FIRST (2026-10-12, BEFORE ENV-01; PV-00 ALREADY SUPERSEDED)

**Instruction for new chat:** User wants the fastest sound route to a playable beautiful sect map, not a new round of tool-building. The user has explicitly requested to hand off details on GitHub. **Start immediately with PV-00 READ-ONLY audit**. Do not ask them to upload an existing local MapPrototype ZIP by default; Source Knowledge has reports/indexes, and the complete MapPrototype is local Windows-only. If the current assistant cannot inspect E: directly, provide **one** complete local read-only Codex/PowerShell inspection request and work with its output. Do not claim direct local access.

### Canonical repository baselines
- Game repo `vuanhtuan161094-byte/TongMonBaDao`, live main before this handoff: `877062493796f1f3e7adf61489d9f672919136c9`; fetch CURRENT main on entry (this DOCS-ONLY handoff creates a newer commit). Windows machine formerly had clean `f50de16ee2abfed4ca4540e2dbd0af0348c51a3e`; do not force reset.
- Source Knowledge `vuanhtuan161094-byte/ZQZS-Source-Knowledge`, known main `83cbc4ecbd83eb518a6d6f2b3894377d9d99254d`.
- Engine Godot 4.7.2, mobile **LANDSCAPE 1280×720**. Local executable `E:\Godot_v4.7.2-stable_win64_console.exe`.
- Read in order `AGENTS.md` → `docs/GAME_SYSTEM_ARCHITECTURE.md` → `CURRENT_CHECKPOINT.md` → this handoff → `docs/decisions/0003-fe00-godot-native-data-driven-frontend.md` → `docs/P3_PRESENTATION_MASTER.md`, `docs/P3_ASSET_BUILDINGS.md`, `docs/P3_ASSET_REGISTRY.json`, `docs/P3_SOURCE_RECOVERY_MANIFEST.md`, `godot/data/presentation/source_a_candidate_manifest.json`, exporter and existing P3 scripts.

### Actual asset and code entry points
- FE-01B1 exporter: `tools/fe01b1/export_verified_pack.py`; Windows Main Hall already exported to `E:\TongMonIntegrationLab\TransferKit\FE01B2VerifiedPacks\building.main_hall`. Original `TransferKit\GodotPacks` is legacy and NOT an output target.
- FE-01B2B isolated screenshot lab `E:\TongMonIntegrationLab\FE01B2B_StaticRenderLab\MainHallStaticRender`; `screenshots\main_hall_static_retest.png` visually shows complete Main Hall. Godot reimport metadata succeeded after an initial corrupted .import. **Retest console log and complete gate absent**. Preserve old lab and backup.
- **Reuse local MapPrototype** `E:\TongMonIntegrationLab\TransferKit\MapPrototype`: `project.godot`, `scripts\map_lab.gd`, `scripts\map_model.gd`, `scenes\map_lab.tscn`. Source Knowledge `transferkit/Reports/V1_MILESTONE_REPORT.md` documents Godot 4.7.2 Windows lab acceptance of footprints, doorway, AStar, simple WALK/WORK/IDLE, and one static Main Hall; no evidence it already renders all 3 buildings. Read local code before choosing a minimal isolated clone/copy.
- Production `godot/src/presentation/p3_1_landscape_sect.gd` has `_build_buildings` / `_build_playable_building_token`, `BuildingToken_*` and `BuildingHit_*` click to `_open_building`; `godot/src/presentation/p3_2_landscape_sect.gd` extends it and handles camera/right building panel; `godot/src/presentation/p3/sect_map_presentation.gd` still has screen-space `DESTINATION_POSITIONS`. Main scene `godot/scenes/p3/p3_2_landscape_sect.tscn` must remain unchanged without explicit FE-02 authorization. Preserve ADR-0003 long-term data-driven map/asset architecture instead of hardcoding E: paths or copying Unity gameplay.
- 3 selected exact candidates: `building.main_hall` model `510052`, 7×5, doorway [3,-1]; `building.warehouse` model `510102`, 3×2, doorway [1,-1]; `building.forge` model `520081`, 3×3, doorway [1,-1]. Both latter candidates are catalog VERIFIED, **not yet rendered/approved**. 13 total candidates have 10 VERIFIED / 3 INFERRED_VISUAL_ANALOG. Eight historically approved S3 building visual identities still have missing exact bytes; Source A candidate art cannot silently overwrite approvals. Rights owner instruction `OWNER_CONFIRMED_FULL_RIGHTS`; frozen old manifest fields stay intact.

### Independent Codex stream: avoid duplication
Owner supplied a Codex report: `C:\Users\Admin\.agents\skills\tmbd-spine-to-godot`; `E:\TongMonIntegrationLab\AssetCatalog` catalog has 157,607 raw paths incl. copies and 6,999 Spine path instances (5,618 READY / 1,381 REVIEW); sample `113100_5_s` was baked to 33 total frames/stand-walk-attack1 and imported/smoked Godot 4.7.2 with exit 0. Visual quality is PENDING, source local logs **not independently audited**. Four-sample task (disciple/pet/boss/VFX) is CURRENT CODEX ASSIGNMENT, no completed four-demo acceptance or GitHub push. The frontend lab is free to proceed using PNG/static building visuals immediately; **do not rebuild catalog, Spine converter, animation demo or ask to wait for Codex**. Only later plug approved animated outputs into a presentation renderer contract.

### Proposed work packets / strict gates
1. **PV-00 — READ-ONLY NOW:** inspect GitHub game+Source Knowledge, known documentation and actual Windows MapPrototype (local check by one complete read-only command if needed). Establish whether existing map scripts can safely render three PNGs and detect if existing paths conflict; enumerate file allowlist for lab copy; confirm verified pack export prerequisite for Warehouse/Forge, Godot, renderer strategy and P3.2 integration seam. Output concise GO/NO-GO, missing inputs and **one** recommended PV-01 authorization option. **No edits, no upload request by default.**
2. **PV-01 — LAB CODE ONLY AFTER OWNER APPROVAL:** keep Source A/existing TransferKit/MapPrototype/verified pack untouched; export only 2 additional verified packs with existing FE-01B1 exporter; stage isolated copy of MapPrototype or minimal reuse, place/render **all three original Source A textures on ONE map**, 1280×720, check layering/crop/alpha/anchor, selected footprints/doorways, pan/zoom/click, no overwritten PNGs or malformed Godot import metadata; reject blank screenshot and errors even when exit 0. Produce repeatable one-command run, screenshot and succinct PASS/FAIL log. Static only (no Spine required). No production repo code changes.
3. **PV-02 — VISUAL OWNER ACCEPTANCE:** show screenshot/short capture and a comparison of visual size, entrance, ground collision, depth/selection; user explicitly decides approval of these Source A candidates vs previous S3 visuals, without changing historical status silently.
4. **FE-02 — SEPARATELY AUTHORIZE PRODUCTION CODE:** smallest compatible art renderer/registry integration into existing P3.2 camera, clickable token and canonical building panel; one gameplay/save authority; official Godot 4.7.2 CI focused + cumulative O9/O8/O7/P3.6A, then Windows visual/click and Android PENDING USER until run. No implementation in this handoff.

**Boundaries:** DV2-03 PAUSED NOT CLOSED; FE-02/G1 NOT AUTHORIZED; one-phase-at-a-time. No gameplay, EXP, Warehouse, BuildingState, Workforce, save/load, main scene, git-lfs transport/push, raw binary game push, existing art approval mutation or parallel Spine converter work. No empty screenshot falsely PASS. New chat should make progress from live evidence and ask approval only at PV-01 code boundary, not repeatedly for trivial read-only actions.

---

**2026-10-12 FE-01B2A CLOSED — WINDOWS ISOLATED MAIN HALL REAL PACK PASS (owner-supplied logs).** Game repo preflight SHA `f50de16ee2abfed4ca4540e2dbd0af0348c51a3e` clean; Source Knowledge SHA `83cbc4ecbd83eb518a6d6f2b3894377d9d99254d` unchanged. New FE-01B1 exporter real Windows `--dry-run`: PASS 4 files. Windows 19 synthetic fixture tests: **18 PASS, 1 SKIP (symlink permission), 0 FAIL**; official Linux Godot 4.7.2 CI #38214043053 SUCCESS 19/19 synthetic plus relevant Godot/O9/O8/O7/P3.6A regression. FE-01B2A first **EXPORTED** into isolated `E:\TongMonIntegrationLab\TransferKit\FE01B2VerifiedPacks\building.main_hall`, never legacy GodotPacks: `510052_lum.png` 20,042 bytes, `510052.png` 596,816, `510052.atlas` 176, `510052.skel` 430; 4/4 candidate SHA-256 correct, 617,464 asset bytes, 6 pack files incl. manifest and README. Second run **UNCHANGED**, 6/6 files' length/SHA/mtime unchanged, lock absent, staging 0, Git changes 0. Real Main Hall pack exists ONLY on user's E: drive, not in Git or game. **Source A art rights user decision: `OWNER_CONFIRMED_FULL_RIGHTS`** (user confirms own full usage/edit/redistribution/release rights; do NOT treat this as blocker or ask for proof). Older runtime/exporter manifest values remain unchanged pending separately authorized safe metadata-version packet; no independent legal audit claimed. **FE-01B2B independent Godot 4.7.2 static texture/atlas render NOT OPENED; user authorization required; no game import, no FE-02/Spine/G1.** DV2-03 PAUSED NOT CLOSED; eight S3 missing visuals unchanged, Git LFS push/pull not tested; Windows game visual/click/APK PENDING USER. This entry supersedes older handoff PENDING claims about FE-01B2A/Windows new exporter. Docs-only closure changes checkpoint+handoff only; `p3-presentation-audit.yml` does not trigger on those paths. See CURRENT_CHECKPOINT.md top section.

**2026-10-12 FE-01B1 TOOLING CLOSED / OFFICIAL GODOT 4.7.2 PASS.** Windows user FE-01B preflight logs: 45/45 source paths, 43/43 hashes, Main Hall original dry-run and bundle hash PASS, Git LFS 3.7.1 installed (push/pull NOT TESTED). Implementation commits e51d2950 (new tools/fe01b1 exporter, 19 synthetic tests, workflow), 322180ba (missing source failure normalization). Official Actions #38213775069 SUCCESS: 19 tests + P3/FE-01A validators, Godot registry, O9/O8/O7/P3.6A regressions. An earlier #38213727177 failed one negative test and was corrected. Tool usage: tools/fe01b1/README.md. New exporter real Windows --dry-run, real Main Hall export, Godot static render, LFS push/pull remain PENDING separately. FE-01B2 / FE-02 / G1 / Spine NOT AUTHORIZED. DV2-03 PAUSED, NOT CLOSED; Source A release rights UNVERIFIED; 8 S3 images untouched, gameplay/save/main scene untouched, game Windows visual/click/APK PENDING USER.

**2026-10-12 FE-01A CLOSED / PASS (only approved code packet).** User explicitly paused DV2-03 implementation: **PAUSED, NOT CLOSED**, gameplay untouched. FE-01A code SHA `550c119d06a266a678e1918017edb389008db0c3`; one CI-only quoting correction SHA `35a0d4e912cccdac6d48d148a72a017a0f1b2ab0`; final official Godot 4.7.2 Actions [#38201510657](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38201510657) **COMPLETED/SUCCESS**: P3 registry validator, FE-01A manifest validator + Python negative tests, parse/import, focused Godot visual-registry test and O9/O8/O7/P3.6A regressions all green. First [#38201459390](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38201459390) failed solely during Stage A base64 recovery and was corrected in second run. 13 candidate metadata = 10 VERIFIED/3 INFERRED_VISUAL_ANALOG, source SHA pinned, 8 legacy S3 approvals unchanged, shared model `520031` and texture `cuizhi` explicit. **No Source A binary imported/rendered in game, no main scene/gameplay/save/LFS change, no rights established, Windows visual/click/APK PENDING USER.** Main landscape still 1280×720. **NEXT CODE: NONE AUTHORIZED**. FE-01B needs separate user authorization + real verified local source bytes and binary transport/rights plan; FE-02/G1 prohibited. See `CURRENT_CHECKPOINT.md` top, ADR-0003 and `godot/data/presentation/source_a_candidate_manifest.json`.

**2026-10-12 FE-00 DESIGN REVIEW CLOSED (DOCS ONLY).** Chốt khuyến nghị Godot-native Data-Driven Frontend, xem `docs/decisions/0003-fe00-godot-native-data-driven-frontend.md` + `docs/GAME_SYSTEM_ARCHITECTURE.md §9`. Base audit game SHA `5f5646ce77b7c53b9452a1740070fe9d6e0d84dc`, Source A KB SHA `83cbc4ecbd83eb518a6d6f2b3894377d9d99254d`. Không sửa gameplay, main scene, asset, CI trong FE-00. **FE-01 chưa được CODE AUTHORIZE**; user phải cấp lệnh riêng và giữ `AGENTS.md` one-active-phase rule (DV2-03 vẫn ACTIVE). FE-01 nếu được duyệt: kiểm provenance/quyền/binary transport của 13 candidate assets, bảo vệ 8 building art đã duyệt; làm runtime asset lookup/aliases/manifest/fallback/tests, **không đổi scene, không Spine, không layout editor**. 3 visual analog chưa phải functional exact. ADR-0002 LFS còn PROPOSED. O9 Linux CI vẫn PASS cũ; Windows click/visual/APK PENDING USER. Không mở G1, DV2-04, balance hoặc FE-02 chỉ vì FE-00 closed.

**Bàn giao cập nhật: 12/10/2026 — M2 O7–O9 CLOSED/PASS trên official Godot 4.7.2 Linux. O9 multi-producer/restart rehearsal green. Windows visual/click/APK PENDING USER; PC hiện đã sẵn sàng kiểm tra. Next code NOT AUTHORIZED.**


## M2/O9 CLOSED — MULTI-PRODUCER REHEARSAL GREEN (2026-10-12)

**Status:** O9 is **CLOSED / FOCUSED PASS / FULL PASS**. Production gameplay source remains O8 SHA `8d30579fea28febe79f445de3c5b469e4b0d5f6e`; final O9 acceptance/test SHA is `495a5e4fec141be2ec8bfda22111f8e631baa99e`. M2 O7–O9 is technically closed on official Godot 4.7.2 Linux.

**What O9 proves:** the live P3.2 scene uses newly produced Mine ore + newly produced Forest wood for one real Thanh Thiết Kiếm craft while starter stock is reserved; produces real Thanh Linh Thảo via Linh Điền; commits it once into timed Hồi Xuân Đan; saves with Mine + Forest + Field + Alchemy all active; reloads exact work identities/timers/progress without stock mutation; resumes each exactly once; consumes a canonical pill in Dược Phòng for +55 HP; then proves Mine/Forest/Field and standing Alchemy can continue without per-batch clicking. Final reload has no replay.

**Evidence:** [O9 #38193051636](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38193051636) SUCCESS including O8/O7/P3.6A regressions; [DV2-03 #38193051740](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38193051740) SUCCESS; [P3.7 #38193051669](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38193051669) FAST+FULL SUCCESS. Early O9 reds were test-sequencing assumptions only; no production gameplay file was changed.

**User machine status:** PC is now available. Windows visual/click/APK is still **PENDING USER until actually run**. First recommended command from repo root: `Sync-Main.cmd Run-P3-6A-Playable-Slice.cmd`. If sync stops because local tracked/staged changes exist, preserve them and resolve before retrying; do not force reset.

**Next design direction after Windows smoke:** return to the active DV2-03 bottleneck and review **DV2-03G1 player-started V2 hunting**. Do not start DV2-04, M3 balance, manager system, high-realm C–H content, Equipment V2/Pháp Bảo/Phù or new producer families implicitly.

---

## M2/O8 CLOSED — REAL TIMED ALCHEMY + HEALING CONSUMER GREEN (2026-10-12)

**Status:** O8 is **CLOSED / FOCUSED PASS / FULL PASS**. Backend SHA `5f00790afcdcbb2fcd3b59d69807743ffb9d085f`; final gameplay/UI SHA `8d30579fea28febe79f445de3c5b469e4b0d5f6e`; focused test-isolation child `bc9ddf96fad1d57332c5806685c06eb6ddca385d`; DV2 compatibility-test child `f3d388f2cfca6f37e7d8046cf9ca06b86f2dfd46`.

**Delivered:** `alchemy_hall` / Luyện Đan Điện Lv1, existing `alchemy` profession, `alchemy_crew`, 2 worker slots, building-owned `timed_recipe` jobs, standing recipe policy, canonical `hoi_xuan_dan`, and a real Dược Phòng/Needs consumer. Opening recipe is **3 Thanh Linh Thảo → 1 Hồi Xuân Đan**, base 6 simulation ticks before work-speed modifier. Active job commits inputs once, reserves its worker, persists exact identity/timer/input receipt, completes into the single canonical Warehouse and cannot replay after reload.

**Entry-level correction:** current P3.7 profession level is 0 when XP is 0, so the only opening recipe must require Alchemy Lv0 rather than the design draft's Lv1; otherwise no fresh worker could ever earn first Alchemy XP. No free XP, profession curve, trait/talent or recruitment probability changed.

**Real consumer:** Dược Phòng can consume exactly one available Hồi Xuân Đan on an injured in-sect disciple for **+55 HP capped at max**. It does not consume legacy `medicine_stock` and does not mutate personal wallet or Sect treasury. Legacy HEAL/medicine logistics remains a separate authority.

**Focused evidence:** [O8 #38188554397](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38188554397) COMPLETED/SUCCESS. It proves a real P3.2 chain: Field produces real crops and one exact 3-unit Thanh Linh Thảo batch → lock/reserve denial → real UI Alchemy start → exact-one input commit → no early pill → worker reservation → mid-job save/reload with same job/finish tick and no second debit → exact-one pill completion + Alchemy XP → post-completion reload no replay → real Dược Phòng pill use with +55 HP and no legacy medicine/money mutation → standing policy later starts another legitimate Alchemy job from newly produced Field herbs without another Alchemy work click. O7 and P3.6A scene regressions are green in the same focused job.

**Cumulative evidence on gameplay SHA `8d30579...`:** [O1 #38188487415](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38188487415), [O2 #38188487414](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38188487414), [O3 #38188487382](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38188487382), [O4 #38188487410](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38188487410), [O5 #38188487325](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38188487325), [O6 #38188487321](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38188487321), [O7 #38188487393](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38188487393) all SUCCESS; [P3.7 #38188487320](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38188487320) FAST+FULL SUCCESS. Final corrected DV2 [#38188712696](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38188712696) is full-workflow SUCCESS. The redundant P3.7 rerun on the final test-only child [#38188712704](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38188712704) is also FAST+FULL SUCCESS.

**Historical reds:** initial O8 focused #38188487378 failed only because the test allowed legitimate standing automation to start before its planned manual first-batch click; `bc9ddf96...` fixed isolation only. Initial DV2 #38188487371 failed at F1 because it incorrectly locked the total global ResourceRegistry size; O8's new unrelated pill made that assumption stale. `f3d388f2...` keeps the exact 29 Body recipes and validates the exact 19 protected Body material identities instead. Do not relabel either historical run PASS.

**Preview:** #38188487361 has FAST + capture PASS; only artifact upload fails because GitHub artifact storage quota is exhausted. Windows/mobile visual click-through, screenshots and APK remain **PENDING USER**.

**Reference boundary:** ZQZS deep-dive verified recipe config, assigned worker/profession, timed building state, serial building queue and generic pill-use patterns. Tông Môn Bá Đạo does **not** copy its single-manager serial queue, manual-claim UX, IDs, values, formulas, assets or unknown server behavior.

**Subsequent status:** O9 was separately authorized and is now CLOSED/PASS; see the O9 handoff above. Do not start manager system or M3 balance implicitly.

---

## M2/O7 CLOSED — LINH LÂM + GENERIC BUILDING JOB GREEN (2026-10-12)

**Status:** O7 is **CLOSED / FOCUSED PASS / FULL PASS**. Gameplay source: `c8fe044c14c55f7988408c2d6498623cc92810c7`. Final CI-only compatibility child: `e74e7f5482844254811c3d0f75fa63400b509f23`.

**Delivered:** fresh `linh_forest` / Linh Lâm Lv1, `forestry` / Lâm Nghiệp, `forestry_crew`, 2 Lv1 slots, real 1280×720 map token/panel, real assignment/order, `travel_out → harvesting → haul_back`, canonical `linh_moc` deposit, Forestry XP and autonomous group repeat. Integration baseline = 2 Linh Mộc per Lv1 cycle; M3 owns later numeric tuning. No manager system, Forestry talent roll, rare-tree side content or Forest upgrade economy was added.

**Reusable authority proven:** Mine + Linh Lâm share one carry-cycle Building Job implementation with explicit building/profession/resource identity. Mine keeps its old phases and locked rejection contract; Linh Điền remains separate plot/timer authority. `DiscipleState` persists optional `profession_id/resource_id` only when present so new jobs survive save/load without forcing new keys into old cycle shapes.

**Focused evidence:** [O7 #38185038526](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38185038526) SUCCESS. It proves real UI assignment, zero payout before carry, exact carried settlement during haul, mid-haul save/reload, no duplicate deposit, consumption of newly produced wood by existing Forge, Forestry XP, autonomous repeat, canonical Warehouse/UI agreement, O3 Mine regression and P3.6A scene regression.

**Heavy/cumulative evidence:** [P3.7 #38184826746](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38184826746) FAST+FULL SUCCESS and [DV2-03 #38184826744](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38184826744) SUCCESS on gameplay SHA `c8fe044c14c55f7988408c2d6498623cc92810c7`. Final CI-only fan-out: [O1 #38185038485](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38185038485), [O2 #38185038488](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38185038488), [O3 #38185038500](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38185038500), [O4 #38185038567](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38185038567), [O5 #38185038494](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38185038494), [O6 #38185038557](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38185038557), and O7 #38185038526 all SUCCESS.

**Historical red evidence:** first O7 workflow had malformed literal-`\n` paths and was repaired CI-only. Generic routing initially changed the locked Mine rejection reason and was fixed in production rather than weakening the old test. P3.7 then exposed dropped generic identity fields across save/load; the serializer was fixed compatibly. These failures are not relabeled PASS.

**Reference-game boundary:** O7 uses the architectural lesson “building ↔ profession ↔ explicit work lifecycle” from ZQZS only. Reference server production math remains UNKNOWN; no source formula/code/asset was copied.

**Subsequent status:** O8 and O9 were subsequently authorized and closed; M2 O7–O9 is CLOSED/PASS. Do not add manager system or M3 balance implicitly.

---

**Repo:** `vuanhtuan161094-byte/TongMonBaDao` · **branch:** `main` · **engine:** Godot 4.7.2. **User yêu cầu thao tác bằng GitHub connector trực tiếp; KHÔNG Codex, KHÔNG Work.** Trước mọi sửa đổi phải fetch lại `main` vì SHA sẽ thay đổi sau các commit bàn giao. **Latest DV2-03E3.1 gameplay/test source with focused PASS:** `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c` (slot-transfer, Workforce exclusive priority, invalid orders, 2-slot multi-minute/no-stone regression). Fetch live `main` before the next edit; docs-only handoff commits may move HEAD.



## CURRENT FIRST-PLAYABLE HANDOFF — O6 CLOSED — M1 TECHNICALLY PLAYABLE (2026-10-11)

**Production gameplay source remains:** `6af3fdd715b3adcb1c3391452c7687cac043b610` (O5). O6 acceptance test final SHA `2c13e862287c68491ed04f153e5b815fd0de1811`; CI fan-out SHA `4a7efa51fcaed8453fcb8c08b62239c3ce1c73b4` changes workflows only.

**O6 integrated PASS:** [#38152216814](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38152216814), official Godot 4.7.2 Linux, COMPLETED/SUCCESS. One real fresh P3.2 session proves Dẫn Tiên order + authentic V2 recruit + exactly one live/selectable actor + recruited Field assignment + real paid crop/harvest + real Mine output + canonical Warehouse + produced-ore Forge craft + produced-ore timed Mine Lv1→2 + active save/restart + exact actor/group/plot/command/stock/item/building restoration + no-click continuation and subsequent autonomous Mine/Field production.

**Required cumulative PASS against unchanged gameplay source:** [O1 #38152327679](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38152327679), [O2 #38152327668](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38152327668), [O3 #38152327663](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38152327663), [O4 #38152327718](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38152327718), [O5 #38152327785](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38152327785), [DV2-03 #38152327667](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38152327667) all SUCCESS; [P3.7 #38152327784](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38152327784) FAST + FULL SUCCESS.

**Historical first O6 run #38152156773:** test-only false assumption: after a legitimate harvest the retained herbalism group autonomously planted the next crop. Test was corrected to accept that valid behavior and withdraw only at a plot-release tick. No gameplay logic was changed to force PASS.

**Release decision:** **M1 technically playable = PASS on official Linux CI.** Do not equate this with visual/product sign-off on the user's device. Windows/mobile click-through, screenshots, packaging/APK and final visual acceptance remain **PENDING USER**.

### ZQZS / Ta Là Tông Sư Tiên Môn benchmark — what to learn, not copy

Read-only evidence in `ZQZS-Source-Knowledge`: building definitions carry layout/manage metadata plus `pro_skill_id`; changing a building manager is a real request/response and updates model/HUD + emits `replaceDisciple`; building `planStart/planComplete` drives `beginWorkAI/endWorkAI`; the work command includes building ID/entity/map ID; profession skill level is read to calculate client building effects. Design placement/path preview is separated from authoritative building changes. Server production timer/quantity/final warehouse authority is **UNKNOWN**.

**Post-M1 design lesson for our independent Godot architecture:** preserve `UI → command → simulation state → completion event → Warehouse`; generalize Mine/Field work state into a reusable building-job lifecycle with explicit `building_id + profession_id + phase + start/finish`; add optional building-manager/policy authority above worker groups for 1k–3k scale; make each producer declare its profession binding rather than bespoke UI logic. O7 Linh Lâm and O8 Luyện Đan are ideal places to prove this framework. Do not copy source code/config values/assets.

**O7 was subsequently authorized and closed.** Recommended next is **M2/O8 design review** for Linh Điền → Luyện Đan → consumable using the O7 building/profession/job boundaries. No O8 code is authorized yet.

---

## CURRENT FIRST-PLAYABLE HANDOFF — O5 CLOSED — REAL PRODUCE→SPEND LOOP GREEN (2026-10-11)

**Priority remains M1 opening gameplay, LANDSCAPE 1280×720.** User authorized **CODE O5 ONLY** and O5 is now closed. Production/test SHA: `6af3fdd715b3adcb1c3391452c7687cac043b610`.

**What O5 now provides:** existing Forge crafting is explicitly fail-closed in the UI when canonical `can_craft` is false; the Mine panel now exposes the already-authored timed BuildingSystem upgrade with exact canonical available-material/Stone costs, progress and blocked reasons. Successful upgrade spends through BuildingSystem/Warehouse authority, not presentation.

**Verified produced-resource provenance:** focused [#38151347151](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38151347151) COMPLETED/SUCCESS. Test reserves all 40 starter iron as non-spendable, then uses the real Mine panel/scheduler to produce 10 new ore across five Lv1 batches. Two batches fund a real `Thanh Thiết Kiếm` craft (3 produced iron + 1 wood) through the actual Forge button; reserve and lock denial are tested and immediate retry cannot duplicate the item. Three more batches make exactly seven spendable ore for the authored Mine Lv1→2 upgrade. Actual Mine upgrade UI debits exact ore/wood/Stone once, rejects duplicate start, persists mid-upgrade progress/cost, completes by scheduler timer, and survives final reload. Final iron is exactly the untouched 40 reserved starter units, proving the newly produced 10 ore was the portion consumed by craft+upgrade.

**Verified regressions on same SHA:** [P3.7 #38151347108](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38151347108) FAST + FULL SUCCESS; [O1 #38151347131](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38151347131), [O2 #38151347111](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38151347111), [O3 #38151347045](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38151347045), [O4 #38151347058](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38151347058), [DV2-03 #38151347044](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38151347044) all SUCCESS. [Preview #38151347110](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38151347110) has FAST + capture PASS; only artifact upload fails because storage quota is exhausted.

**O6 was subsequently authorized and closed; M1 technically playable Linux CI = PASS.** See the current O6 handoff above. No M2 packet is authorized yet; Windows visual/click/APK remains PENDING USER.

---

## CURRENT FIRST-PLAYABLE HANDOFF — O4 CLOSED — REAL LINH ĐIỀN LOOP GREEN (2026-10-11)

**Priority remains M1 opening gameplay, LANDSCAPE 1280×720.** User authorized **CODE O4 ONLY** and O4 is now closed. Production/test SHA: `45c1870631fdfd680c65357c01cd733f7ddcc332`.

**What O4 now provides:** a real Linh Điền map destination and management panel backed only by `BuildingSystem`/Spirit Field authority; player assigns Đội Linh Thực, sees policy/crop costs/plot timers/output, and issues a canonical Gieo trồng command. Fresh Lv1 has 4 worker/4 plot slots, AUTO_DEMAND crops cost the existing 3/4 Sect Stones, and harvest goes directly to the one canonical Sect Warehouse. Field outputs are visible consistently in Linh Điền and Kho. Direct Field orders fail closed when no slot/plot/currency exists.

**Reservation bug closed:** while a plot is growing, the assigned disciple can no longer fall through to generic autonomous AI and leave to hunt/rest. The canonical plot owns that worker until harvest; UI blocks withdrawing that worker during growth, and harvest automatically releases the reservation.

**Verified focused PASS:** [#38150623606](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38150623606), official Godot 4.7.2 Linux, COMPLETED/SUCCESS. It proves real UI assignment/order, exact one-time Stone charge, canonical plot reservation, duplicate denial, mid-growth disk reload without restart/recharge, timer harvest to canonical Warehouse, exact Field/Kho stock agreement, post-harvest no-duplicate persistence, worker release and zero-Stone denial. Same job passes P3.7A2R backend and P3.6A scene regression.

**Verified cumulative PASS on same SHA:** [P3.7 #38150623654](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38150623654) FAST + FULL SUCCESS; [O1 #38150623598](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38150623598), [O2 #38150623601](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38150623601), [O3 #38150623629](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38150623629) and [DV2-03 #38150623611](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38150623611) all SUCCESS. [P3.6A Preview #38150623602](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38150623602) has FAST + capture PASS; only artifact upload fails because GitHub storage quota is exhausted.

**O5 was subsequently authorized and completed.** See the current O5 handoff above. **M1 now has only O6 remaining**, and O6 requires explicit user authorization. O7–O9 are M2 expansion, not M1 blockers. Windows current visual/click/APK acceptance remains **PENDING USER**.

---

## CURRENT FIRST-PLAYABLE HANDOFF — O3 CLOSED — REAL MINE LOOP GREEN (2026-10-11)

**Priority remains M1 opening gameplay, LANDSCAPE 1280×720.** User authorized **CODE O3 ONLY** and O3 is now closed. Production gameplay SHA: `8f7097e9f39ba34cf8f2b941a9b69a9a1933a2c5`; final focused test SHA: `513ac6bdaed7abd0fed7bb294b0ecf8d26900af1`.

**What O3 now provides:** the live Mine panel uses authoritative P3.7 active slots and cycle state; player mining orders require a real active Mine slot; removing/changing the worker cancels its Mine work-cycle plus matching direct command; waiting members cannot receive fake mining work. The actual production path remains `P3.2 UI → WorkforceSystem → SimulationScheduler → BuildingSystem travel_out/mining/haul_back → WarehouseSystem`; no presentation-side reward exists.

**Verified focused PASS:** [#38145823173](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38145823173), official Godot 4.7.2 Linux, COMPLETED/SUCCESS. Real-scene test uses UI group/work buttons, observes travel/extract/haul, saves/reloads mid-haul with carried ore, completes exactly one Mine batch into canonical Thanh Thiết, verifies Mine/Kho/top-bar equality and post-deposit persistence, interrupts a later cycle with no phantom output, and tests active-slot/waiting denial. Same job passes P3.7A1 Mine backend and P3.6A scene regression.

**Verified cumulative PASS:** [P3.7 #38145660662](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38145660662) FAST + FULL SUCCESS on gameplay SHA `8f7097e9f39ba34cf8f2b941a9b69a9a1933a2c5`; [O1 #38145660367](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38145660367), [O2 #38145660371](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38145660371) and [DV2-03 #38145660368](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38145660368) all SUCCESS. [P3.6A Preview #38145660698](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38145660698) has FAST + capture PASS but overall FAILURE at artifact upload because storage quota is exhausted.

**Historical red evidence:** #38145659655 = invalid workflow YAML path line, fixed in `84ad73c110a6985f74223e6ba228c2d866e7b931`; #38145683502 = test measurement contaminated by unrelated autonomous hunting forge-loot deposits from the global scheduler. Final test isolates unrelated actors through canonical HOLD; production/reward rules were not changed.

**O4 was subsequently authorized and completed.** See the current O4 handoff above. O5 is the next unstarted M1 packet and requires explicit user authorization; O6 follows only after O5 closes. Windows current click/visual/packaging acceptance remains **PENDING USER**.

---

## CURRENT FIRST-PLAYABLE HANDOFF — O2 CLOSED — FOCUSED + FULL GREEN (2026-10-11)

**Priority remains M1 opening gameplay, LANDSCAPE 1280×720.** User authorized **CODE O2 ONLY** and O2 is now closed. Final gameplay/test SHA: `48871ae3df6d068dc78d7397f84a046eba3885f9`.

**What O2 now provides:** Dẫn Tiên Đài is a real clickable map destination; P3.2 reads/writes only canonical `RecruitmentSystem`; real Dẫn Tiên order, Accept and Reject are player-facing; after successful Accept the authoritative roster is reconciled into one live `ModularDiscipleActor` immediately; the new disciple is selectable and appears in existing workforce UI; save/reload preserves the recruit and assignment without duplicate actor/roster entries. Pre-V2 candidates seeded before live V2 activation remain rejectable but cannot bypass `v2_birth_profile` completeness; their Accept button is disabled. A genuine Dẫn Tiên-generated V2 candidate is the valid acceptance path.

**Verified focused PASS:** [#38141615606](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38141615606), official Godot 4.7.2 Linux, final SHA `48871ae3df6d068dc78d7397f84a046eba3885f9`, COMPLETED/SUCCESS. It proves fresh 6/8, real token debit, V2 candidate creation, exact-once Accept, immediate live actor, selection, Mine workforce assignment, save/reload, duplicate/invalid denial, capacity 8/8 denial and Reject. Dẫn Tiên backend + P3.6A scene regression also PASS in the same job.

**Verified cumulative PASS on same SHA:** [P3.7 #38141615581](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38141615581) FAST + FULL SUCCESS; [O1 #38141615577](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38141615577) SUCCESS; [DV2-03 #38141615561](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38141615561) SUCCESS. [P3.6A Preview #38141615603](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38141615603) has runtime FAST + capture PASS but overall workflow FAILURE at artifact upload because GitHub artifact storage quota is exhausted; do not call its upload step PASS and do not misclassify it as a render/game regression.

**Historical red run:** O2 [#38141471378](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38141471378) failed because its first test tried to accept a pre-V2 candidate after live V2 birth became mandatory. The correction did not weaken the gameplay gate; it made the UI and test honor the canonical V2 candidate rule.

**O3 was subsequently authorized and completed.** See the current O3 handoff above. O4 remains the next unstarted packet and requires explicit user authorization. Windows current click/visual/packaging acceptance stays **PENDING USER** because no PC is available.

---

## CURRENT FIRST-PLAYABLE HANDOFF — O1 CLOSED — FOCUSED + FULL GREEN (2026-10-11)

**Current priority is STILL opening M1, LANDSCAPE 1280×720.** User authorized **O1 ONLY**. O1 canonical Warehouse UI source is committed on `main`: `godot/src/presentation/p3_1_landscape_sect.gd` and `godot/src/presentation/p3_2_landscape_sect.gd` use shared read-only `WarehouseSystem.quantity/available_quantity` projection with legacy fallback only when P3.7 is off. Topbar/Mine/Forge/Kho/base popups/formula preview/Bloodline/Physique counts are synced; recipe preview respects reserve/lock and matches real `EquipmentSystem.can_craft`. No new warehouse, EXP changes, 29 recipe changes or economic tuning.

**Verified PASS:** [O1 official Godot 4.7.2 Linux focused #38138929016](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38138929016), sha `64fe81943f299fcfc69a62cdd2238a25540b46ac`, COMPLETED/SUCCESS. Test `godot/tests/presentation/p3_o1_canonical_warehouse_ui_test.gd` runs the real landscape main scene: real mining deposit→same UI counts, reserve deny, authentic exact one forge craft/debit, lock deny, disk save/reload with canonical totals/lock/equipment and no duplicate legacy balances. Same workflow existing P3.6A player scene regression PASS. Initial CI configuration errors in #38138844577/#38138894260 were fixed in #38138929016. P3.6A screenshot preview [#38138746807](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38138746807) runtime & capture PASS but artifact upload failed on quota.

**FULL VERIFIED PASS:** [P3.7 FAST+FULL #38138746766](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38138746766), latest UI-code SHA `dfc4ac91d4e46a774831ae0ce94c8f301beea1d9`, FAST PASS and FULL cumulative PASS; run directly confirmed **COMPLETED/SUCCESS**. **O1 CLOSED on official Linux Godot 4.7.2**. O2 was later separately authorized and completed; see the current O2 handoff above. Windows native visual/click-through **PENDING USER**; no machine currently. **O3–O9 are not authorized by the completed O2 packet.**

**Do not confuse** prior O0 planning-only status below or old DV2-03 chronology with current execution status. Do not claim opening M1 playable PASS until O2–O6 complete and release gate is actually proven.

---

## HISTORICAL O0 EXECUTION CHECKPOINT (SUPERSEDED BY CURRENT O1 ABOVE)

**One-tap user workflow is a project rule:** `AGENTS.md §11`: every meaningful answer ends with 2–3 **clickable options** (where chat UI supports), each submitting a fully prepared Vietnamese next prompt; recommended next step first; scope/no-scope/CI/Windows handling included; never make user compose command text. Options authorise work **only upon user choosing them**. If buttons cannot be made interactive, provide short copy-ready complete prompts.

**O0 READ-ONLY SOURCE AUDIT COMPLETE, NOT NEW CI/WINDOWS PASS:** full fact matrix in `docs/OPENING_SLICE_EXECUTION_AND_ACCEPTANCE_PLAN.md §O0 EXECUTED`, tracked in `CURRENT_CHECKPOINT.md §O0 AUDIT RESULT`. Code source main before docs commits `47c39a7`; actual startup `P37Factory` with P23/TechniqueSystem supplies **500 Sect Spirit Stones**, not 0; **6 founder disciples**, **capacity 8**, **3 candidates**, **3 tokens**, `SectState.treasury=1000`, **+40 Linh Mộc and +40 Thanh Thiết** added before warehouse migration, Mine/Field/Guidance/Body Training real backend instances, 60 real seconds per simulation minute. Starter field crops cost 3/4 Stones, so initial planting is affordable; old speculative 0-Stone first-plant blocker **disproved**, ongoing Stone income not proven. Two starters assigned mine, two forge, two otherwise unassigned; Linh Điền no initial assigned workforce. Dẫn Tiên Lv1 has base 5 arrivals per simulated day, processed on scheduler day initialization, but UI entrance absent.

**Real barriers:** (1) top bar/Mine/Forge/Kho/recipe previews still read now-empty legacy `forge_materials`/`technique_materials` rather than P3.7 canonical `WarehouseSystem`; this is **first code fix**; (2) no player map/management access to real Field/Guidance; (3) `_spawn_all_disciples` & modular upgrade only on scene-ready and `_sync_actor_positions` skips new IDs, so after recruitment new actor does not materialize dynamically; (4) fresh end-to-end Mine→Warehouse→Forge spend and Field paid plot→Warehouse→save remain untested from player UI. Code authority `godot/project.godot`, `godot/src/presentation/p3_1_landscape_sect.gd`, `p3_2_landscape_sect.gd`, `godot/src/simulation/resource/warehouse_system.gd`.

**Historical O0-only next step (now completed, see O1 above) = CODE O1 ONLY** from approved-priority planning `docs/OPENING_SLICE_EXECUTION_AND_ACCEPTANCE_PLAN.md`: replace the player-facing legacy stock/recipe projections with canonical WarehouseSystem quantity/available_quantity, old-save fallback only when P3.7 disabled, add/execute actual scene targeted tests and official Godot 4.7.2 CI + regression, update checkpoint. **DO NOT** implement O2–O9, new recruitment/Spirit Field UI, reprice Stones, touch EXP/29 Body-gate content or close DV2-03 in O1. Current Windows machine inaccessible, **PENDING USER**. User can choose O1 button or an alternative review/test button; **O1 is not authorized by completing O0**.

## LATEST USER ORDER — RUNNABLE OPENING PRODUCTION FIRST; ECONOMY BALANCE LATER (2026-10-11)

**Do not switch the goal back to DV2 hunting/high realms:** user wants game playable at opening with visible genuine disciples, real production buildings, production→canonical warehouse→real use and persistence. **Numerical economy balance is deliberately deferred** until the first operating vertical slice is stable. Existing real cost/affordability and resource conservation still must work — a zero-Stone start preventing Field production must be diagnosed and presented as a specific approval item rather than silently granting funds.

**Hybrid resource policy: USER ACCEPTED IN PRINCIPLE, NOT FINAL/CODED.** Recorded in `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md §30`. Sect owns equipment/materials and sets allowed spend/reserve/budgets; disciples autonomously work/use ordinary authorized materials, may spend separately owned personal Stones on legitimate services, and cannot consume rare locked or strategic funds without policy. `Cân bằng` default / `Tiết kiệm` / `Ưu tiên phát triển` mode thresholds and economic rates are future proposals, NOT gameplay behavior. Legacy P2.6 personal gear purchase must NOT override newer sect-owned equipment authority.

**One detailed operative plan:** `docs/OPENING_SLICE_EXECUTION_AND_ACCEPTANCE_PLAN.md` newest `PRIORITY RESET` section. **M1 first-playable** O0 fresh start, roster, money/Stone and real building map; O1 canonical warehouse UI projections; O2 V2 Disciple/Dẫn Tiên recruiting and actor sync; O3 Mine actual work→stock; O4 Spirit Field actual paid plot→stock; O5 Mine-output→forge item/use + only valid building upgrade; O6 end-to-end main-scene save/reload + targeted/FULL CI. **M2 expansion (LATER):** O7 Linh Lâm genuine renewable Linh Mộc, O8 one genuine Linh Điền→Luyện Đan→consumable use chain, O9 integrated multiple-producer scene/restart. **M3 later:** numeric balancing and 1k–3k optimization. Avoid promising all reference game's eight professions immediately; only two producer types are already backed by P3.7 BuildingSystem. Forge is an existing consumer. No O-packet is PASS just because docs exist.

**Reference Tông Sư Tiên Môn benchmark** repo `vuanhtuan161094-byte/ZQZS-Source-Knowledge` `main a9a638b6`, `SYSTEM_INDEX.md`, `docs/HOME_BUILDING.md`, `docs/PROFESSION_PRODUCTION.md`, `SOURCE_EVIDENCE_POLICY.md`: AndroidData client `aiManager.beginWorkAI` + `planStart/Complete` + building `pro_skill_id` + manager-change request are VERIFIED only as client call patterns; production result server and APK vs AndroidData loader are UNKNOWN. Use Godot independent architecture and existing gameplay authority, do not copy assets/formulas.

**O0 completed at static/source level; O1 now implemented/focused PASS (see current section).** The original O0 audit checked normal `project.godot` main scene + factory/start seed/save, initial roster, candidates, Stone/initial material affordability, actual three built instances, canonical Warehouse and UI, actor/recruitment lifecycle. Source files/candidate/test statuses and blockers in `CURRENT_CHECKPOINT.md`; report to user with evidence. The current user instruction approved planning, **NOT blanket gameplay coding O1–O9**. Preserve active DV2-03 and completed F0–F7/EXP/29 exact recipes. Keep all new Windows work **PENDING USER**; assistant owns GitHub CI. Avoid redundant MD and status speculation.

## OPENING PLAN CONTROL / SINGLE NEXT PACKET — 2026-10-11 (LATEST)

**Single next-deliverable plan:** `docs/OPENING_SLICE_EXECUTION_AND_ACCEPTANCE_PLAN.md` (created 2026-10-11; **PROPOSED / PLANNING ONLY**). Read it after `AGENTS.md` -> `docs/GAME_SYSTEM_ARCHITECTURE.md` -> `CURRENT_CHECKPOINT.md`; this plan integrates, but does not supersede `docs/P3_6_SECT_MASTER_GAMEPLAY_LOOP_SPEC.md`, `docs/P3_6A_PLAYABLE_VERTICAL_SLICE_SPEC.md`, P3.7 backend specs or Disciple V2 authority. User wants opening live sect with actual disciples and production **before** additional hunting and high-realm content.

**Packet queue O0–O6:** O0 fresh-game/roster/currency/baseline verified matrix (read-only) -> O1 replace legacy `forge_materials`/technique display/recipe preview with P3.7 canonical `WarehouseSystem` reads -> O2 early disciple + accessible legitimate Dẫn Tiên recruiting + map actor refresh -> O3 real UI Mine/haul/warehouse -> O4 real UI Spirit Field plot/plant/timer/warehouse; funding must be legitimate -> O5 output-consuming real craft/authorized upgrade -> O6 complete scene, save/reload, focused+FULL regression and Windows checklist. **No packet PASS has been granted by writing the plan.** Do not code without user instruction; do not run CI and call it new proof if source wasn't changed.

**Source and verified traps:** Main Godot scene is `p3_2_landscape_sect.tscn` 1280x720; real Mine/Field/Guidance backend instances, but main map contains no Field/Guidance token; P3.2 operations switch has no Field/Guidance entry. Top bar / building readouts / forge recipe counts use `forge_materials` or `technique_materials` legacy dictionaries while P3.7 canonical WarehouseSystem owns real stock/crafting, a **priority UI-truth defect**. Planting/upgrades consume `spirit_stones`; real fresh start funding unknown. Startup `_spawn_all_disciples` and later position sync skips unregistered actor IDs, so validate map spawn after accepting new recruits. Reference repo `ZQZS-Source-Knowledge` Lua confirms only client manager->work AI->completion events and profession/building linkage, not server output math or copied config. Preserve source benchmark boundaries.

**Status discipline:** DV2-03 remains ACTIVE; F0–F7 remain already implemented/tested at prior gameplay SHA, no new EXP/29-recipe edits, hunting G1–G4 DEFERRED as next-delivery priority. Existing earlier P3.6A Windows PASS is historical, but all **new changed-scene/first-playable visual Windows checks PENDING USER (PC unavailable)**. Official Godot 4.7.2 GitHub Actions CI belongs to assistant. Report after each small work packet with source SHA/run and PASS/FAIL/BLOCKED; no all-game PASS from backend-only fixtures.

## CURRENT DELIVERY PRIORITY — OPENING PRODUCTION + ACTUAL DISCIPLES (LATEST USER CORRECTION, 2026-10-11)

**User corrected our goal emphatically:** the NEXT DELIVERY is a **runnable early-game scene with real disciples and early production**. This supersedes the previous recommendation to implement V2 hunting G1 immediately. Do NOT prioritize PvE dispatch, repeating Spirit Stone hunt rewards, C–H/high-world/Seal content, 29 Body-gate completion or large-scale balance before the opening loop. Keep DV2-03 ACTIVE; preserve EXP, all 29 formulas, previously implemented F0–F7. The correction changes prioritization, **not** gameplay coding authorization or phase closure.

**First-playable acceptance sequence:** load P3.2 living sect scene → visible real disciples (verify authentic V2 and recruitment/starting roster path) → UI assign miners and Spirit Field workers → actual elapsed/tick-based material production/harvest in canonical Sect Warehouse → UI displays exact balances and exposes an available real production consumer (craft/upgrade) → exit/restart and verify deterministic continuation/no double output. User's Windows PC is unavailable: **ALL local Windows click-through checks remain PENDING USER**; assistant handles GitHub/static review/official Godot 4.7.2 CI. Report each small packet with evidence; do not label Windows PASS.

**Observed live source:** `p3_1_landscape_sect.gd` starts `LiveGameRuntimeV2`, spawns current disciple map actors, timers/autosave, and has bottom nav for Sect/Disciples/Warehouse/World. `p3_2_landscape_sect.gd` has working Mine and Forge management entries, but its building-control match presently lacks Spirit Field; `p3_7a2_spirit_field_test.gd` proves backend planting/harvest/warehouse independently. Starting-scene recruitment flow is not yet established. These are **integration and onboarding gaps to verify/fix**, not proof that opening game already passes. `CURRENT_CHECKPOINT.md` first `TOP DELIVERY TARGET` table is the live acceptance checklist; do not lose its USER Windows pending row.

**Next assistant work packet:** focus on the opening P3.2 scene and production UI / real disciple lifecycle (audit current tests and fix only scoped missing integration once authorized), run targeted official Godot tests; no needless rerun/rewrite of F0–F7. Old G1–G4 post-F7 findings retained below as **deferred audit findings**, not immediate implementation order.

### Source-benchmark checkpoint — 2026-10-11 (READ-ONLY, opening game first)

**Reference repo verified live:** [ZQZS-Source-Knowledge](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge), `main` at `a9a638b6049756038ae199fae90e47e2d02829a4`. Start with `CHATGPT_PROJECT_GUIDE.md`, `SYSTEM_INDEX.md`, `SOURCE_EVIDENCE_POLICY.md`, `SOURCE_TO_GODOT_MAP.md` and `docs/HOME_BUILDING.md`, `docs/PROFESSION_PRODUCTION.md`, `docs/DISCIPLE.md`; consult indexed direct Lua code and check APK vs AndroidData variants (runtime precedence **UNKNOWN**). Source is **reference only**, not gameplay authority; never copy code/assets/formulas.

**Actually cross-checked Lua:** `sources/AndroidData/binary/gamesys.home.aimanager_TextAsset_-1862949912781759658.bin.lua` `beginWorkAI` (around lines 976–1022) enqueues a real work behavior with building ID, cooldowns and work parameters after actor/context checks; `gamecore.behavior.disciplestatemanager_TextAsset_-7023619792469983883.bin.lua` around 178–181 handles `planStart/planComplete` as work AI start/stop; `gamesys.home.zongmenmodel_TextAsset_4454781143516164630.bin.lua` around 2422–2436 ties `pro_skill_id` to building-related profession effects; `zongmencontrol` around 571–573 sends a change-manager request. These **VERIFY client-side structure/calls only**; server-authoritative final output/cost remains **UNKNOWN**.

**Godot independent correspondence:** `WorkforceSystem.assign_group/perform_work` + `SimulationScheduler` and `BuildingSystem` already implement typed assignment/work, Mine and Spirit Field production; `WarehouseSystem` owns stacks. `p3_2_landscape_sect.gd` has real Mine and Forge management but its live building-control switch lacks `TYPE_SPIRIT_FIELD` UI entry. Source benchmark therefore supports the **manager → actual work state → completion/output feedback** pattern, and immediate gap is **opening-scene connection**, not expanding the distant combat/Body system. `P3_6_SECT_MASTER_GAMEPLAY_LOOP_SPEC.md` and `P3_6A_PLAYABLE_VERTICAL_SLICE_SPEC.md` are EXISTING game goal documents and must be checked before selecting work. Startup recruitment entry, production/warehouse/consumption integration, and Windows visual acceptance remain **NOT VERIFIED**. No gameplay or CI was changed by this documentation audit.

**Enforce on every future opening-slice packet:** (1) read active game MD and source index/claim/code, (2) compare source **pattern** to live Godot owner and concrete UI entry, (3) implement the smallest missing link only with approval, (4) run focused + relevant cumulative Godot 4.7.2 CI, (5) update checkpoint including `PENDING USER` Windows. The full game roadmap stays intact; postpone hunting G1–G4 until after this vertical-slice milestone. No DV2-03 closure or EXP/29-formula change.

## POST-F7 LIVE-GAP FOLLOW-UP — AUDIT ONLY (2026-10-11)

**Most recent user request:** read live main, AGENTS, current checkpoint, handoff and DV2-03F §S; do NOT redo F0–F7, close parent DV2-03, alter EXP/29 recipe rows, fake C–H/Seals, or demand PC now. GitHub + official CI are assistant-owned; every Windows item remains **PENDING USER**. Work/report in small packets. Post-F7 audit filed in **`CURRENT_CHECKPOINT.md` → `POST-F7 LIVE CODE AUDIT`** (commit `79c1ff2495a5da70c9700d1c7611fa9d026cab06`). `bfbf62c3..a206cc13` was docs-only 6 commits, focused #38121196765 and cumulative FAST/FULL #38121196717 completed SUCCESS on gameplay SHA `bfbf62c3`. This follow-up is documentation only, **no new CI/Godot gameplay claim**.

**Concrete code gap:** `godot/src/presentation/p3_2_landscape_sect.gd` has paid Body gate but no player-facing V2 hunt start. `godot/src/presentation/p3/hunting_level_selector_v2.gd` can store real per-region difficulty but is not mounted in live Sect UI. `godot/src/simulation/combat/hunting_pve_run_v2.gd` provides verified real start/fight/claim/persistence; header admits not installed in legacy scheduler. `godot/src/simulation/core/simulation_scheduler.gd` uses old `CombatSystem.resolve_encounter` for `COMBAT`. Thus old direct `HUNT_REGION` order is **not** proof of V2 material payout or player-started match. **Historical superseded priority G1 (NOT CURRENT OPENING TARGET)**: connect legitimate V2 region/difficulty/party/start → battle outcome → one-time canonical loot claim → save/resume to live P3.2 UI with scene, denial/replay and official CI tests; auto-hunting remains a separate requirement.

**Economy G2:** `SectState.spirit_stones` default 0; `HuntingMapV2.preview_reward/claim_reward` emits only materials, no Stone credit; paid training costs 1 Stone/min, farm also spends it; Treasury `EconomySystem` is distinct. Design/spec allows hunting Stone rewards but no actual repeatable funding has been proven. Do **not** silently invent Stone rate/split, refill, claim, or convert normal money; first establish production design and conservation tests.

**High realm G3:** Only three authored Nhân hunting regions and current 1..6 Body gates. All 7..29 remain `content_unavailable`. Material/Seal registry IDs and synthetic gate validations are not gameplay content. Require progressively authored high-world zones, bosses, Seal sources, source/demand/time checks before authorizing unlock. **G4/Windows:** natural 10M+ EXP pacing, full player UI route, 1k/3k stress, Windows visual all still unverified. No machine available, preserve USER checkboxes.

**Implementation boundary:** Audit does not authorize gameplay modifications or balance adjustments. If user later requests the hunting stream, implement **G1** as a separate approved slice; the latest opening-production correction takes precedence; remain in parent DV2-03. No forced next-phase jump.

## LATEST AUTHORIZED F3–F7 IMPLEMENTATION + HONEST A/B F7 HANDOFF (2026-10-11)

**Live contract precedence:** User on 2026-10-11 at 14:08 ICT explicitly authorized **CODE F3, F4, F5, F6, F7** (the older statements below saying they are unapproved are HISTORICAL). Still **OPTION A**. Preserve 29 exact Body recipes 562/143/3, 8 groups, 3 Seals, EXP, Tu Vi independent, P3.7 canonical warehouse and no fabricated C–H/high-realm maps. **Do NOT start DV2-04 or close DV2-03 automatically**. **CURRENT_CHECKPOINT.md** top checklist is authoritative for status; full detail `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` **§S**.

**F3 real sources** `HuntingMapV2` on original three Nhân maps now pays **1 Thanh Linh Thảo / real Thanh Trúc won claim**, **2 Tử Vân Thảo / real Bạch Thạch won claim**, and saves a bounded legitimate-win counter delivering **1 Linh Tủy guaranteed per 4 Thanh Trúc won claims**, WITHOUT modifying existing rare drop chance (L1 rare remains 0%), no time-based giveaway or double claim; `SectState.v2_body_material_progress` persisted and restored. Numeric rewards **PILOT ONLY, NOT USER-LOCKED**. `DiscipleBodyGateTransactionV2` production condition allows only Body source realm1–6 while actual A/B regions+resource registry are authored; all 7–29 remain content_unavailable.

**F4 actual live P3.2 UI** `godot/src/presentation/p3_2_landscape_sect.gd` V2 attribute tab has scrollable exact item/EXP/locked-reserve readout and named **"Đột phá Luyện Thể"** real `BodyGateRealCommit` button, disabled if preview disallows; calls authoritative single warehouse/body/receipt transaction and `LiveGameRuntimeV2.save()`. F4 Godot actual-scene test passed.

**F5 arithmetic/current-source** complete scoped QA: A 54 main/15 aux, B 52 main/6 aux; 54 real Thanh Trúc + 26 Bạch victories = **80 hunt-only victories per disciple** for six Body gates under PILOT 1/2/4 supply; 1k/3k ×80 are projections NOT real load tests; full travel/elapsed time, autonomous PvE consumer and recurring Sect Stones **UNVERIFIED/BLOCKED**; don't retune XP or declare all-economy PASS.

**F6 Godot focused verified on SHA `bfbf62c39341f71816bea877881b1137e75fdf03`:** [#38121196765](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38121196765) COMPLETED/SUCCESS. Log: `wins=80,body_gates_A_B=6,paid_body_minute=real,gate_xp_at_10=qa_fixture,high_tier=blocked`. One real Rèn Thân minute earned, but **floor10 EXP at each gate injected only as QA test fixture**: not actual 10,000,000 EXP natural pacing proof. All actual item earnings are genuine 80 completed-map battles settled to Sect Warehouse; successful six production gates, disk save/reload and same-request replay prevention; item and realm sources 7–29 still unavailable. F3/F4/F5 focused steps same SHA also PASS.

**P3.7 cumulative** [#38121196717](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38121196717) same gameplay SHA `bfbf62c39341f71816bea877881b1137e75fdf03`, **COMPLETED/SUCCESS; FAST PASS and FULL PASS** (actual GitHub job steps verified). Official Godot 4.7.2 Linux only; Windows PENDING USER. P3.6A preview #38120846305 captured real image PASS, but **artifact upload failed due GitHub Actions storage quota**; not a render/playability bug or successful image delivery. User Windows PC **NOT AVAILABLE**, keeps all Windows tests **PENDING USER**, no user command needed currently.

**F7 truthful closure:** A/B backend earned items + transaction + real V2 gate button are implemented/tested. **Do NOT call all 29 gates playable or full user-facing hunt loop complete:** direct human PvE dispatch/UI/auto hunting scheduler is not established by F6 backend battle test; true high-tier C–H and repeatable Seals missing, long-term Sect-stone income unverified, full realtime natural EXP pacing and visual click-through on Windows pending. Phase **DV2-03 ACTIVE; DESIGN_LOCKED=false** pending explicit user judgment of remaining scope. Recommend continuing targeted remaining gameplay dependencies before the next character roadmap phase, without redoing F0–F6.


## MOST RECENT — DV2-03F F2 ATOMIC BODY GATE TRANSACTION, FOCUSED GREEN (11/10/2026, CODE F2 ONLY)

User expressly authorized **CODE F2 ONLY** and reiterated they CANNOT use Windows PC now. Do **NOT** code F3–F7 automatically. New production class: `godot/src/simulation/cultivation/disciple_body_gate_transaction_v2.gd`; commands `preview_gate(state,disciple_id)` read-only and `commit_gate(state,disciple_id,request_id)` consume exact F1 29-row manifest from real `WarehouseSystem` + canonical `DiscipleRealmProgressV2.commit_canonical_body_gate`, rollback warehouse resources/count + disciple progression/HP on failed commit; locked/reserve_min respected. `SectState.v2_body_gate_receipts` per actor/realm compact ledger, O(1) transient request-index reconstructed from receipts on JSON save/load. Receipt keyed by actor+source realm and request-id; same retry won't spend twice, reused ID across actors/gates refuses. No extra stone fee. **NO gameplay loot source F3, no F4 UI, no changes to locked EXP/29 recipes.**
  
**F2 is technically coded but PRODUCTION IS FAIL-CLOSED:** all 29 F1 recipes say `content_available=false` and default F2 service refuses `content_unavailable`; QA test-only derived fixture authorizes transaction in simulated sandbox. Do NOT claim playable 29 gates or a real A/B loop until actual sources F3 and visible command F4. F3 must be separately authorized; F5–F7 still separately unapproved. **Next action suggestion: F3 A/B earned source + bounded anti-stuck**, especially early `tu_van_thao` and `linh_tuy`. High-tier C–H/3 Seal source worlds must not be fabricated.

**Verified official Godot 4.7.2 focused:** [DV2-03 #38118632633](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38118632633) at source SHA `8676590de2e499e9689e8548f3583ad704f2c6b0`, **COMPLETED/SUCCESS** including `godot/tests/simulation/dv2_03_f2_body_gate_transaction_test.gd`: QA measured warehouse item costs, no mutation on denied gate/preview, reserve/lock, exact success and HP, JSON+real SaveService disk round-trip, restart replay, failed after-debit rollback, competing actors, actual required Seal gate10. Earlier #38118592396 failing parser due test Variant type was corrected and superseded. [P3.7 FAST + FULL #38118632512](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38118632512) at **same SHA**: FAST PASS; FULL result to check live before marking PASS. Runtime/disk power-loss atomicity of existing SaveService is **NOT proven** by F2 round-trip; don't promise it. `CURRENT_CHECKPOINT.md` checkbox now marks F2 code + focused PASS and Windows **PENDING USER**. More detail in `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` **§R**.

## LATEST CLARIFICATION — PLAYABLE MILESTONE + F1 FULL VERIFIED (11/10/2026)

The user asked why "Thối Thể" differs from "Luyện Thể" and why progress is taking many steps. **They are NOT two progression tracks**: Luyện Thể = full 30-realm, 300-floor Body path; Thối Thể = material-based breakthrough **at floor 10 to next Body realm**. Recommend using clear player-facing label **"Đột phá Luyện Thể"** when UI F4 is authorized; no button implementation yet. Prioritize **one real playable disciple loop**, not more speculative high-tier balancing/large economy: accumulate real Body EXP → earn low-tier A/B materials via verified hunting/region routes and bounded anti-stuck → request major gate → atomic protected Sect Warehouse debit + Body advancement → save/reload and real UI status. This playable milestone requires **F2+F3+F4 implemented and tested**; F1 alone is only data. Preserve one-step-at-a-time delivery/permissions.

[F1 focused CI #38117236823](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117236823) **COMPLETED/SUCCESS** and [P3.7 FAST+FULL CI #38117245351](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117245351) **COMPLETED/SUCCESS** at respective test/config SHAs documented in §Q and checkpoint. This is Linux technical acceptance, **not Windows**, not F2–F7 acceptance. F2 code remains **NOT AUTHORIZED**, F1 completed, high-tier sources unavailable, **DESIGN LOCKED=false**. User cannot turn on PC: Windows **PENDING USER**, no current PC task. The live checklist is in `CURRENT_CHECKPOINT.md`.

## LATEST IMPLEMENTATION — DV2-03F F1 MANIFEST/REGISTRY ONLY (11/10/2026 13:07 ICT, USER APPROVED)

**User explicitly approved CODE F1 ONLY** (repeated message did not extend authority). **F1 implemented** on main: `godot/src/simulation/cultivation/disciple_body_gate_content_v2.gd` creates versioned read-only 29-gate data, strict validator and `content_available=false` for ALL 29 rows; `godot/src/simulation/resource/resource_registry.gd` adds 12 C–H items plus `an_nhan_gioi`, `an_tien_gioi`, `an_than_gioi` (15 new IDs, 4 A/B existing intact, 19 exact gate ID set). `godot/tests/simulation/dv2_03_f1_body_gate_manifest_test.gd` tests independently all 29 rows, totals 562/143/3, invalid-manifest fail-closed, old-save compatibility and no real new drops. CI test registered in DV2-03 focused workflow; P3.7 cumulative trigger updated. **NO EXP changes, NO F2 transaction/service, NO real high-tier drops or F3–F7, no active Body gates.** See `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` **§Q**; §D exact manifest/§O Option A still authoritative.

**Evidence:** [focused Godot 4.7.2 Linux #38117236823](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117236823) @ `1e0cf39f9122796c4c64a71d52f76b263d525051` **COMPLETED/SUCCESS** including F1 specific test (29 gates/19 IDs PASS). [P3.7 FAST+FULL #38117245351](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117245351) @ `dec66e794a08a7ef70d9d43869441639b3a7fe06` **FAST PASS; FULL must be rechecked live before PASS**, because it was in progress at documentation time. Initial early CI #38117169945 failed on a GDScript parse continuation at source SHA `9cd2d27`, fixed at `5c9e9997`; do not hide earlier red run or treat obsolete SHA as current.

**USER PC CHECKLIST:** User currently **cannot turn on Windows PC**, so Windows visual interaction, real Windows native Godot run and future acceptance stay **[ ] PENDING USER**. User does NOT need to do anything now. Assistant must own live GitHub review, official Linux CI and document updates; when a genuine Windows test is needed, give precise commands/steps and continue the explicit checkboxes in `CURRENT_CHECKPOINT.md` (F0/F1 completed, F2..F7 not authorized, Windows pending). DO NOT claim Windows PASS from GitHub Linux.

**NEXT STEP / PERMISSION:** wait for `CODE DV2-03F F2 ONLY` before implementing transaction/receipt/warehouse commit. F2 is **NOT authorized** by F1; F3–F7 also not authorized. `DV2_03F.DESIGN_LOCKED=false`, `DV2-03 ACTIVE`, **29/29 gate material sources NOT playable**.


## HIGHEST PRIORITY — MOBILE-ONLY USER + F0 VERIFIED PASS + PC CHECKLIST (11/10/2026)

User **CANNOT turn on Windows PC now**. The assistant must **do all GitHub review/code/automated tests on its own when authorized**, and preserve a clearly visible outstanding **USER-WINDOWS** task checklist. **DO NOT ASK FOR A PC RUN DURING F1 OR WHILE USER LACKS PC; DO NOT MISREPORT WINDOWS PASS.**

**Canonical checklist (checkboxes and responsibility):** `CURRENT_CHECKPOINT.md` first **"DV2-03F ACTION + PC HANDOFF CHECKLIST"**. F0 focused [#38105919954](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38105919954) **completed/success**, and FAST+FULL P3.7 [#38105926374](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38105926374) **completed/success**, both Godot 4.7.2 Linux. Windows game UI/native validation is **[ ] PENDING USER / NOT DONE**, to be requested *only when genuinely needed*; future exact Windows steps/commands must be supplied when user has a PC.

**This paragraph describes the earlier pre-F1 checkpoint only.** F1 has subsequently been explicitly authorized and implemented as described by the latest F1 section above. No real loot/transaction was added; F2–F7 remain unauthorized and DESIGN LOCK remains false. Locked EXP, 29 quantities, 3 Ấn unchanged. F0 audit and verified evidence in `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` §P.


## TOP CURRENT STATUS — DV2-03F F0 CODE/TEST AUTHORIZED AND EXECUTED (11/10/2026 09:38 ICT)

**User explicitly authorized F0 ONLY** for audit of genuine runtime, EXP, monster/region loot, evidence and correct F0 tests. The previous section saying `CODE_AUTHORIZED=false` is a historical statement from before this approval; effective state is **`F0.CODE_AUTHORIZED=true`, `F1..F7.CODE_AUTHORIZED=false`, `DV2_03F.DESIGN_LOCKED=false`**. Preserve Option A (monster/boss/region primarily, guaranteed anti-stuck for enabled item gates); do not add IDs, resources, 29 gate consumer, event, high-tier map/Seals or retune EXP.

**F0 exact new implementation:** only `godot/tests/simulation/dv2_03_f0_source_baseline_test.gd` (new focused real owner test) and GitHub Actions wiring `.github/workflows/dv2-03-realm-body-progress.yml` (execute test) + `.github/workflows/p3-7a1-building-backend.yml` (run cumulative on test change). There are **NO** `godot/src/` runtime edits. Full evidence matrix is **`docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` §P**; §O remains rollout authority, §D holds exact 29 recipes.

**Verified new F0 CI:** [official Godot 4.7.2 Linux DV2-03 focused #38105919954](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38105919954), source/test SHA `3c48bf7f763acf8b2d6cc6e52b25b81356b72de1`, **COMPLETED/SUCCESS**, including dedicated F0 test **PASS**, 29-gate old mathematical test, active mining and two-slot paid training. Actual F0 log: one valid disciple paid minute = **1,557 Body EXP with its own Căn Cốt** and **−1 Sect Stone**; six-actor real won hunt paid **3 Linh Mộc +1 Thanh Thiết to warehouse**, **0 Sect Stones**, replay prevented/persisted. **Three currently authored Nhân regions**, **no Tử Vân Thảo early hunt route**, **Linh Tủy rare-only with 0 chance in L1**; expedition Body 750 reference has **no proved automatic scheduler consumer**. No reliable earned recurring Sect-stone lower bound. No high-realm balanced playtime proof.

**P3.7 cumulative run (same F0/test configs, no extra gameplay edits):** [#38105926374](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38105926374) at `cd52d4b97b673dc116606e0fb6b413aec16119b1`, **FAST completed PASS**, FULL verified completed/success; see newest priority/status section above. User Windows Godot remains PENDING USER. Later commits in this turn only add F0 docs/checkpoint and do not modify test/gameplay SHA.

**Next:** Finish documenting actual cumulative result if available; do not automatically begin F1. Ask user separately before any new implementation. DV2-03 remains ACTIVE; F0 focused PASS != F1–F7, != 29/29 materials playable or DESIGN LOCKED.


## MOST RECENT DECISION — 2026-10-11 08:12 ICT — OPTION A, RETURN TO DISCIPLE V2 ROADMAP (DOCS ONLY)

**This supersedes the earlier "full F0–F7 all 19 sources in DV2-03F" scope below (history only).** User explicitly chose **A**: focus on getting a real disciple's Realm/Body loop playable; **unchanged 29 gate quantity manifests, 8 ingredient groups, 3 Seals, existing EXP and all locked progress mechanics**. Main acquisition is **actual monster/elite/boss/victorious hunt rewards or completed region-resource activities**; an earned, bounded-result anti-stuck route is mandatory for consumables needed by an enabled gate, preferably via the same hunt/region claim system rather than an unrelated commission engine. **Tử Vân Thảo and Linh Tủy must have a genuine early B route before gate4, regardless of Lv30 field; C–H (12 missing ingredient IDs) and 3 Seals maintain definitions but unavailable high-level reward sources remain DISABLED** until proper map/monster/boss/zone content exists and is user-approved. Do not pretend the 29-gate endgame is playable.

**Canonical newest contract**: `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` **§O**, superseding §N where rollout/supply demands conflict. **Roadmap correction**: `docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md` newest 2026-10-11 section, and active DV2-03 execution spec newest 2026-10-11 section. Workflow within current **DV2-03 ACTIVE** now: F0 baseline → F1 manifest/IDs → F2 atomic gate transaction → F3 earned A/B hunting/region drops+anti-stuck → F4 minimum Body-gate UI → F5 scoped real low-tier F05/F07/F10 verification → F6 Godot focused/full → F7 scope handoff. Later phases DV2-04 Root, 05 Trait/Fate, 06 Bloodline/Physique, 07 techniques/skills, 08 true full loop, 09 complete UI, 10 1k/3k final scale **remain in order**; events, pháp bảo, pills, high-realm economy and full 30-map implementation remain deferred as appropriate.

**Authorization**: user expressly requested GitHub Markdown updates **ONLY**. `DV2_03F.DESIGN_LOCKED=false` and `CODE_AUTHORIZED=false`. Do not create/edit GDScript, scenes, tests or assets; do not claim new Godot PASS. F05 early numbers are **historical PILOT not live code requirements**, F07 verifies the currently operating low-tier sect stone loop, F10 verifies actual current EXP owners but does not demand completed 30-realm final game balance. Locked EXP cannot be modified without a new user decision. E3.1 latest verified gameplay/test Linux official 4.7.2 source = `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c`; old test PASS not new F scope PASS. Windows visual PENDING USER.

**Next step:** await an explicit user decision on separate coding permission for F0 or F0/F1; no automatic coding. When asked, re-fetch live main + gate specs and implement only the specified slice, no full C–H/3-Seal endgame in advance. **Phase closure caveat:** F1/F2 can test 29 recipes synthetically without 29 real acquisition routes; passing A/B doesn't mean full DV2-03 CLOSED. If higher-tier content is required for parent closure, keep phase ACTIVE until user resolves exact closure boundary.


## LATEST USER DECISION — DV2-03F FINAL IMPLEMENTATION CONTRACT APPROVED IN PRINCIPLE (11/10/2026)

User expressly **APPROVED F01–F12 IN PRINCIPLE** from the 29-body-gate source/economy audit. **Did NOT authorize coding** and did not say `DESIGN LOCKED`. Keep section D manifest (29 gates, 562 main+143 aux+3 Seals), all locked XP/Realm/Body/lục duy, 2 Rèn Thân slots, paid 1 Sect Stone/min and 60 seconds per simulation minute unchanged. **F05 3-main/30 active team-min, 1-aux/≤4 qualified wins, 1-Seal/≤8 wins stays PILOT ONLY; F07 genuine repeatable Sect Stone earned income and F10 real Body EXP pace must be VERIFIED with runtime evidence** before economic/release claims. All 19 named materials (4 existing+15 to register, i.e. 12 group +3 Seals) require real accessible earned source, no next-realm/Tu Vi equality lock.

**FULL TECHNICAL/EXECUTION CONTRACT NOW AT:** `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` **section N**. Proposed order **F0 baseline/profiling → F1 manifest/registry/schema → F2 authoritative gate preview+transaction/replay safe → F3 A/B early deterministic acquisition + stone bootstrap → F4 real C–H/tier map/quest/three repeatable Seals → F5 demand-driven warehouse UI/team assignment → F6 measured F05/F07/F10 + 1k/3k → F7 focused/full/Windows integration and closeout**. These are work packets inside **one active parent phase DV2-03**, not new simultaneous phases. No work packet is authorized by this message. Source E3.1 gameplay/test SHA remains `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c` with earlier Linux Godot 4.7.2 focused/full PASS only; no new Godot test, no Windows evidence, no production source IDs, no implemented Body gate transaction.

**NEXT ACTION:** WAIT for user's separate explicit authorization, e.g. `CHO PHÉP CODE DV2-03F, BẮT ĐẦU F0/F1`. Do not use this principle approval as permission for Codex/GitHub gameplay edits; do not set `DESIGN LOCKED`. If user authorizes F0/F1, confirm precise scope from user command and work packet, use direct GitHub connector, test official Godot and preserve everything locked. For F07/F10 gaps, measure and report honestly; request separate numeric/content approval if new balance must change.

## DV2-03F BƯỚC 3 RESEARCH REVIEW — 11/10/2026, AWAIT USER APPROVAL

Research-only Step 3 is now recorded in `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` **section M** (29-row source/access + XP + Sect stone economics + final F01–F12 approval decisions). Source code/testing remains at E3.1 SHA `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c`; GitHub document additions do **not** add gameplay, register IDs, implement sources or validate gates. Latest section-M document commit: `0d946a9e3cab77d58bddf9edcf3c1e4a0ae754fc`. Verify live `main` again before edits.

**Critical new proof:** `DiscipleProgressionBalanceV2` cumulative r1..r29 Body EXP = 37,890,400,000. At unbuffed paid 1,500 EXP/min (60 real seconds/simulation minute), a single actor needs ~48.06 continuous years to enter r30 without other effective sources. Rèn Thân has only 2 slots, 1 stone/min/trainee; expedition source type 750 is **not yet proven an actual automatically operating V2 PvE income stream**. Keep the locked EXP unchanged; do not represent full high-realm progression as economically verified.

**Field Lv30 hidden prerequisite:** upgrading Lv1→Lv30 costs 1,238 linh_moc, 625 thanh_thiet, 3,687 Sect stones, six linh_tuyen_chi_tam (=600 fragments via current 100:1 recipe). 5% base fragment chance => expected 12,000 harvests at factor1, no deterministic time bound. Therefore gate4 must NEVER require Lv30 field/heart. Cohort-funding concern: two paid Rèn slots + 4 full Lv1 plots burn ~4,800 Sect stones/day, while sustainable Sect stone income has no confirmed lower bound; old P0 `treasury` isn't Sect stone. Both B guarantee and genuine earned stone funding need a dedicated pilot.

**Final decisions F01–F12** listed in section M cover quantities, two earned named sources per ID, B early supply, C–H/3 repeatable Seals, optional provisional 3main/30 team-min and 1aux/≤4 wins and 1seal/≤8 wins, nonfree earned Sect Stone revenue, scalable cohort demand, no auto gate by default, atomic source/gate receipts, locked EXP retained, fail-closed release policy, test acceptance. User has **NOT** granted final DESIGN LOCKED or code permission. **Next action:** present decision list and seek explicit approval. No new Godot/Windows test was run in Step 3.

## LATEST DV2-03F DESIGN CHECKPOINT — 11/10/2026 (AWAIT USER FINAL APPROVAL)

User **approved in principle** 8 material groups, all 29 recipe quantities and 3 consumed repeatable Realm Seals (gates 10/20/29), multi-route guaranteed sources, Body gate deterministic 100%, no Tu Vi=Luyện Thể requirement, and no EXP/balance changes. **Do NOT code until final approval.** Full technical proposal saved in `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md`. This is **DRAFT FOR FINAL REVIEW**, not a new closed phase.

Grounded blockers: actual `ResourceRegistry` has four matching existing recipe IDs (`thanh_linh_thao`, `tinh_lang_bi`, `tu_van_thao`, `linh_tuy`); 12 group materials + 3 Seals require new IDs. Tử Vân Thảo crop requires **Linh Điền Lv30**, but gate 4 requires it; Linh Tủy is rare in current Thanh Trúc map with no deterministic fallback. C–H maps/loot/profession sources aren't authored. User must approve early guaranteed commission for B, repeatable 2 routes for Seals and each ingredient, and source accessibility before required gate. Proposal includes exact 29 manifest/ID/quantity rows; sum **562 main + 143 aux + 3 Seals** per full character journey.

Atomicity: `DiscipleRealmProgressV2.commit_canonical_body_gate` owns EXP/HP, `WarehouseSystem.consume_requirements` owns named warehouse quantities/locks; **no combined transaction code yet**. Proposed new service preflights and snapshots, canonical commits, bundle-consumes, rolls back on failure, persists an idempotent receipt in same SimulationState, never accepts caller-provided requirements_verified, never RNG. Existing SaveService direct-write is not power-loss atomic; disk durability is separate explicit implementation risk/test. Production-source guaranteed receipt and AI automation default-manual remain proposed. Official Godot focused/full PASSES cited previously are **E3.1 only**, not DV2-03F. No new tests executed; Windows remains PENDING USER.

**Next:** present final approval options; if approved, implement manifest/content, acquisition pipeline, gate transaction/persistence, UI in slices with real official Godot gates. Always include clickable next action after delivery.

## LATEST USER-ORDERED IMPLEMENTATION — DV2-03E3.1 (11/10/2026)

**E3.1 code and focused plus cumulative Godot PASS at SHA `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c`:** [official focused #38093450321](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38093450321). The new dedicated multi-tick regression and updated map UI regression PASS. Main changes: valid `request_training("cultivation")` releases old dedicated Body slot only after new preview succeeds; Workforce prevents ordinary forge/mining/herbalism schedule stealing a dedicated Body trainer; valid explicit orders/group changes/worksite vacancy free the slot and set manual policy, invalid commands cannot evict; emergency HP path retains precedence; no fabricated EXP/stone refunds and no changed numerical balance. `CURRENT_CHECKPOINT.md` §5.19 and `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md` E3.1 describe the invariant.

**Same-source P3.7 FAST + FULL P0→P3.7 cumulative:** [#38093450298](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38093450298), **COMPLETED / PASS** at source `3c7e9a76` on official Godot 4.7.2 Linux (all workflow steps success). Do not mislabel this as Windows visual approval. No Windows test done; **PENDING USER**. Remaining DV2-03 task is to design and user-approve exact 29 Thối Thể packages and safe major-gate consumer, then do implementation/test. UI search/paging for >12 candidates and PC pixel/touch visual acceptance remain separate open work.

## CURRENT NEXT ACTION — 11/10/2026: DV2-03E3.1 STABILIZATION NEEDED BEFORE DV2-03F

**E3 gameplay/test SHA `b8103b06b9e05af0391ff3e1cd007c07dc8b58df` still PASSED focused [#38070169637](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169637) and same-source P3.7 FAST/FULL [#38070169594](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169594).** Do not confuse these PASSES with proof of every edge-case. **Windows visual NOT RUN**. On 11/10 audit (no gameplay edits) two untested P1 code-path risks were found and recorded at `CURRENT_CHECKPOINT.md` §5.18:
1. Switching a training-slot owner to **Chuyên tu** with `_queue_v2_training("cultivation")` does not release reserved group/worksite; occupied slot becomes stale. Fix atomic transfer/release and test 2→1 capacity, third disciple and save/load.
2. An active `body_focus` trainee with positive forge work_preferences can be picked by Workforce scheduled `work` phases, despite holding Rèn Thân place. Decide/enforce exclusivity of dedicated Rèn Thân and cover schedule cycles without breaking healing/explicit user change/cost fail-closed.

P2 backlog: multi-minute offline depletion test, shortage/paused display, 12-item-only candidate UX and 1,000–3,000 performance, real touch/scroll inspection at 1280×720, P3.6A preview artifact storage quota. Do not make up materials for 29 Thối Thể gates.

**Recommendation: next click = DV2-03E3.1 stabilize above P1 cases and rerun focused + full official Godot; then DV2-03F material design (user approval required).** No request to turn on the user's Windows PC immediately.

## LATEST ACTIVE UPDATE — DV2-03E3 REAL RÈN THÂN MAP + TWO-SLOT UI (10/10/2026)

**Active phase DV2-03, not CLOSED.** User approved dedicated Rèn Thân Đường Lv1 two slots, 1 Sect Spirit Stone and 1,500 base Body EXP per real simulation minute, and requested playable UI management. This is NOW implemented in canonical P3.1/P3.2: distinct map building token `ren_than_duong`, `TRAIN_BODY` actor destination, click opens P3.2 management showing the real level, slots, current wallet, paid minutes, consumed stones and per-disciple training state. Assign via genuine V2 backend `_queue_v2_training("body", disciple_id)`; release via `DiscipleBodyTrainingFacilityV2.release_slot`, freeing slot and setting manual policy (does not refund already paid minutes). Never award XP on UI click. First 12 eligible V2 roster entries shown; future search/pagination not yet built. No fabricated UI roster, economy or second save owner.

**Official Godot 4.7.2 Linux focused PASS:** [run #38070169637](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169637), gameplay source `b8103b06b9e05af0391ff3e1cd007c07dc8b58df` (test includes map click, 3 V2 recruits, slot full denial, release/reassign, single paid minute, save/load). **Latest same-code P3.7 FAST + FULL cumulative:** [#38070169594](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169594), **PASS** (GitHub completed/success, confirmed 11/10/2026). Windows live/visual remains PENDING USER.

**Windows remains NOT RUN/PENDING USER**; no need to request PC immediately. P3.6A preview artifact upload encountered GitHub Actions storage quota on earlier E3 runs; visual screenshot not available. **Pending future gameplay:** 29 user-authorized Thối Thể material packages and real major-gate cost consumer, Rèn Thân upgraded-slot/intensity content (never invent), Dẫn Tiên recruitment → visible disciple → real production UI, and larger roster UX. Next user should select further step using a clickable option. Read CURRENT_CHECKPOINT §5.17 for details and status.

## LATEST ACTIVE UPDATE — DV2-03E3 REAL RÈN THÂN MAP / 2-SLOT UI, 10/10/2026

**One active phase still DV2-03, NOT CLOSED.** User chose dedicated Lv1 two-slot Rèn Thân Đường, 1 Sect Spirit Stone/minute, 1,500 base Body EXP/minute. Those numbers remain immutable.

**E3 built (latest gameplay/test SHA `b8103b06b9e05af0391ff3e1cd007c07dc8b58df`):** one clickable P3.1 `BuildingToken_ren_than_duong`/hit, `SectMapPresentation.DEST_BODY_TRAINING` actor destination for `TRAIN_BODY`, and real P3.2 building management showing exactly two canonical slots, currently assigned disciple names/status, Sect Spirit Stones, cost/rate, persisted paid training minutes, and last scheduler receipt when available. Assign via existing `_queue_v2_training("body", disciple_id)`, with backend authorization + real slot reservation then queued action (NO immediate money/EXP). Release via one `DiscipleBodyTrainingFacilityV2.release_slot`, clears both group and worksite so no ghost slot, cancels `TRAIN_BODY`, sets manual policy to avoid silent requeue, and never refunds a completed minute. Candidate rendering is bounded (12) and only genuine live V2 actors in the sect; profile allows selecting others. Old P2 UI unaffected.

**Official focused Godot 4.7.2 Linux PASS:** [#38070169637](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169637). Includes new `godot/tests/presentation/dv2_03_p3_body_training_building_ui_test.gd` verifying actual scene hit, two slots/3 disciples, denial/release/reassign, real paid minute/treasury/audit and save-load. Earlier full [#38068119472](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38068119472) PASS at pre-E3 source. **Latest same-source P3.7 full [#38070169594](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169594) PASS**, as well as P3.7 FAST (confirmed completed/success 11/10/2026). Confirm current result before declaring E3 FULL PASS.

**Preview caveat:** the P3.6A Godot/screenshot generation steps passed in Linux, but recent GitHub Actions preview workflows failed artifact upload due exhausted storage quota; the user cannot yet download an E3 preview artifact. Windows Godot 4.7.2 gameplay/visual is **UNTESTED / PENDING USER**. Do not ask user to open PC unless real visual validation is needed.

**Next user action choices:** prefer **DV2-03F: author and approve material/tempering prerequisites for all 29 Body major gates** (no invented materials), then implement real gate consumer and full closure; afterwards Dẫn Tiên Đài recruit → visible V2 disciple → authentic work/production UI. Do not jump to equipment/Pháp Bảo.

## LATEST ACTIVE UPDATE — DV2-03E2 P3.2 REAL V2 TRAINING COMMAND UI, 10/10/2026

**Gameplay SHA `ca2f3077d2c2e6d89cb8e11924e7c89fe95e09f9`** (docs-only commits may move main). V2 `Thuộc tính` now has real **Chuyên tu/Rèn thân** buttons and map disciple summary routes authentic V2 through its canonical `DiscipleTrainingActionV2` (never P2 fallback). Rèn thân auto-reserves an eligible slot at the actual Lv1 2-slot Rèn Thân Đường after command/treasury/body-gate checks and queues `TRAIN_BODY`, which **does not debit or grant XP until SimulationScheduler consumes the simulation minute**. `body_focus` persisted on success. Real blocked reasons shown with no fake success, and an actual UI bug clearing feedback on redraw was fixed. Older/P2 characters retain legacy presentation/commands.

**FOCUSED Godot 4.7.2 Linux PASS:** [#38068119502](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38068119502), including V2 UI test for no funds/no mutation, slot reservation, queue with no instant cost, real paid minute and cultivation action. **P3.6A PASS:** [#38068119466](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38068119466). **Latest same-source P3.7 FAST/FULL:** [#38068119472](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38068119472), PENDING at write; verify run before marking latest full PASS.

**Still ACTIVE DV2-03:** needs user-approved exact Thối Thể materials/content and real major-gate consumer; Rèn Thân map clickable/2-slot building panel not yet done; Windows visual/live NOT RUN / PENDING USER. Do not open unrelated gameplay phase or claim recruitment UI exists. Next concrete UI substep inside this phase can be map management of Rèn Thân Đường; then Thối Thể content approvals/closure and subsequent Dẫn Tiên → real recruit → visible disciple → work assignment flow.

## ACTIVE PRIORITY UPDATE — 10/10/2026, DV2-03P2 (FOCUSED PASS)

**Explicit user choice A implemented:** Rèn Thân Đường is a separate V2 P3.7 building, Lv1 **two slots**, exactly **1 Sect Spirit Stone per actual paid training minute**, 1,500 **base Body EXP/minute** before Căn Cốt +0.20%/point. This is not a Tu Luyện Đài shared slot. New/live V2 worlds get the facility via idempotent `LiveGameRuntimeV2` bootstrap; old P3.7 fixtures are preserved. Player can explicitly reserve a slot with `DiscipleBodyTrainingFacilityV2.reserve_slot`; `DiscipleTrainingActionV2.request_training(...,"body")` queues the real `TRAIN_BODY` action; `SimulationScheduler` commits a minute only after the existing Sect Spirit Stone wallet has been debited, and refunds on failure. `body_focus` policy now chooses valid paid Rèn Thân, otherwise legal Tu Vi fallback. Sources remain one natural Body EXP/disciple/minute; no Expedition Stamina spent inside the sect.

**Official focused Godot 4.7.2 Linux PASS:** [run #38066113278](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38066113278) at gameplay SHA `6e10aca2d105f23f026a216f3404e5f9bbbbdf6d`, includes existing DV2-03 focused checks plus `dv2_03_ren_than_duong_integration_test.gd` and real active-mining Body XP integration. **P3.7 previous FAST/FULL cumulative PASS:** [#38065668233](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38065668233) at prior implementation SHA `0be59f86`. **Latest changed-source full cumulative:** [#38066113295](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38066113295), source `6e10aca2`, **PASS on official Godot 4.7.2 Linux** (P3.7 FAST + FULL P0→P3.7). Same source as focused #38066113278. CI/Linux is NOT Windows live/visual acceptance.

**Still blocked/next:** Rèn Thân post-Lv1 upgrade numbers and intensity tiers, exact 29 Thối Thể requirement packages, some future physically demanding production professions and expedition context, and the Rèn Thân UI map token/panel. **Windows user live/visual test NOT RUN.** UI recruitment Dẫn Tiên → accept → visible disciple → production is the next gameplay experience goal but must not be called implemented now. Current DV2-03 phase remains ACTIVE until closure criteria are verified.

**Unity benchmark rule:** Tông Môn Bá Đạo's own canonical runtime/specs are sole gameplay authority. Unity client is only benchmark/pattern/bug-finding reference, not formula owner.

## TRẠNG THÁI HIỆN TẠI — đọc mục này trước, không áp dụng các lịch sử bên dưới

- **Giai đoạn ACTIVE duy nhất: DV2-03 — Tu Vi và Luyện Thể V2.** DV2-01 birth **CLOSED**; DV2-02 combat/group PvE **CORE BACKEND LOCKED** *trong phạm vi stat/encounter proving*, **không phải live PvE hoàn tất**.
- **DV2-03M migration cleanup đã CODE trên main, CHƯA được gọi PASS trên code mới:** authentic V2 không fallback P2; live V2 HP ratio preservation; one floor-10 gate-cost authority; malformed saved V2 progress fail-closed. **Starting rule has since changed:** all NEW production V2 recruits now start Phàm Nhân 1 + Phàm Thân 1, both 0 EXP. The old Luyện Khí-index bridge remains development-save migration only.
- **LATEST LUYỆN THỂ (supersedes older notes):** `production` (real active mining) and `body_training` (real 2-slot paid Rèn Thân Đường) NOW HAVE CONSUMERS and focused Godot evidence in the priority section above. `TRAIN_BODY` and `body_focus` are real when access/cost verified; not generally free/automatic. `expedition` remains typed source-only until outside-map ownership is authorized.
- **LATEST Luyện Thể source contract:** one natural Body source/disciple/minute. Canonical references = **250 production / 1.500 dedicated Rèn Thân / 750 expedition EXP per simulation minute** before Căn Cốt/modifiers. Rèn Thân still requires a real facility/slot + committed minute cost.
- **STEP 1 RUNTIME INTEGRATION COMPLETE / FOCUSED PASS:** `LiveGameRuntimeV2` now boots/loads `P37Factory` live state through `SimulationRuntimeOwnerV2`; P3.1/P3.2 use that exact runtime-owned state. Old fresh `P212Factory` scene state, two-disciple demo recruitment and 0.55s `scheduler.step()` timer are removed. Polling UI every 1s and autosave every 15s do not alter authority: **60 real seconds = 1 simulation minute**. Save/load/offline, corrupt-save fail-closed and P3 binding are covered by latest focused tests.
- **STEP 2 DISCIPLE PRESENTATION SNAPSHOT COMPLETE / FOCUSED PASS:** new `DisciplePresentationSnapshotV2` is the single read-only UI snapshot. Authentic V2 uses `v2_birth_profile` + `v2_realm_progress` + `CombatStatsV2`; hidden Trait/Mutation/Bloodline/Physique/Destiny does not leak; malformed V2 progression never falls back to P2; P3.2 summary/status/tabs branch through snapshot; legacy P2 Bloodline/Physique buttons/actions are hidden/blocked for authentic V2 while legacy compatibility remains tested.
- **Historical Step-2-only focused evidence:** [DV2-03 #38038834727](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38038834727), SHA `5ecb3bbeb7d1adc7644a9aecc3b805d0fc6bb3fa`, official Godot **4.7.2 Linux**, **PASS all focused steps**, including prior progression/runtime gates + unified presentation snapshot + authentic V2 profile UI + legacy P3.2 compatibility. P3.6A production UI [#38038282452](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38038282452) **PASS**; cleanup rerun [#38038535562](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38038535562) **PASS**.
- **WINDOWS / USER VALIDATION: PENDING — CHƯA CHẠY.** User has not yet run Step 2 on Windows Godot 4.7.2, so do not claim Windows PASS or VISUAL ACCEPTED. When user is at the PC: `Sync-Main.cmd Verify-P3-6A-Playable-Slice.cmd`, then `Preview-P3-6A-Playable-Slice.cmd` for visual review.
- **Latest cumulative evidence for Step 1:** [P3.7 Backend #38037386848](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38037386848), SHA `150be2aeaf5c7092f594850bdffa2e349f7c03cf`, official Godot **4.7.2 Linux**, **FAST + FULL cumulative PASS**. This SHA contains the same Step-1 production runtime code; subsequent `35dd076` change is test-only.
- **DV2-03D1 policy scaffolding đã CODE nhưng CHƯA PASS latest runtime:** enum còn balanced/cultivation_focus/body_focus/manual; **body_focus hiện BLOCKED vì facility/cost consumer chưa tồn tại**, không phải vì source model chưa khóa.
- **DV2-03S Tu Vi source model đã CODE, runtime gate chưa xác minh:** natural Tu Vi mỗi phút mô phỏng; `CULTIVATE` = Chuyên Tu. Canonical balance now sets **1.000 Tu Vi/phút, Chuyên Tu ×2**. New recruit = Phàm Nhân 1 + Phàm Thân 1, 0/0 EXP.
- **Đơn vị balance/display:** Tu Vi/phút mô phỏng; typed natural Body sources cũng chuẩn hóa theo Body EXP/phút mô phỏng. 15s không phải balance law.
- **Đã CODE và focused Godot 4.7.2 Linux PASS:** hai hồ sơ Tu Vi + Luyện Thể V2 thật và độc lập (mỗi đường 30 đại cảnh × 10 tầng), đúng 60 tên đã khóa; EXP natural Tu Vi +0,25%/Tư Chất và Luyện Thể +0,20%/Căn Cốt, buff nguồn được nhận dạng rõ trên đúng channel; thưởng EXP fixed không nhân; EXP qua đủ tầng nhỏ tự tăng, tầng 10 dừng trước đột phá. `derive_stats` tính lại 16 combat stats + 10 kháng từ hai đường và Tiềm Lực, săn quái V2 không nhận cảnh giới giả.
- **Major gate balance đã khóa trong latest code:** 29 Tu Vi base chances chính thức + pity +5 điểm %/fail + −10% gate EXP on fail; canonical wrapper dùng đúng shared floor-cost table. Luyện Thể cả 29 gate deterministic: full gate EXP + verified Thối Thể requirements -> 100% advance, no RNG/pity/fail loss. Material packages/consumable consumers remain future content.
- **Progression balance latest (CODE + focused PASS):** shared 300-floor curve for Tu Vi + Body; totals r1 10,000,000 -> r30 10,240,200,000; natural Tu Vi 1.000/min, Chuyên Tu ×2; `LiveGameRuntimeV2` enables canonical V2 rules for the live state while authentic ownership still prevents legacy disciples from receiving V2 progression.
- **Đã CODE + focused PASS ở API lệnh người chơi:** `DiscipleTrainingActionV2.request_training(state, disciple_id, track)` xếp **một lần** activity, không tức thì cộng EXP và không ngắt đánh nhau/việc bận. **Chưa nối API này tới UI P3.2**; nút “Tu luyện” trong scene P3.2 vẫn qua `WorkforceSystem.COMMAND_CULTIVATE` legacy, không có nút Luyện Thể V2 thật.
- **Realtime now connected:** persistent live runtime owner + wall-clock mapping + offline catch-up + save/load are connected to P3.2 and focused PASS. **Still missing:** Windows live/visual evidence and V2-specific presentation/UI surfaces.
- **Số cân bằng progression chính thức đã có:** shared 300-floor curve, Tu Vi 1,000/min, Chuyên Tu ×2, Body reference 250/750/1,500, 29 Tu Vi chances, deterministic Body gate. Test `80/50/100` cũ vẫn chỉ là fixture và không được coi là authority.
- **Chưa kết nối đầy đủ:** V2 character HP live persistence/migration, V2 Equipment 10 ô/12 phẩm, Skills Nhân–Tiên–Thần và Trait/Mệnh/Linh Căn/Huyết Mạch/Thể Chất effects, outside-map live PvE/monster AI. Không coi design-only thành implemented.

**P3 static audit được sửa trong đợt bàn giao:** run [#37897313917](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37897313917) **FAIL** vì hai mục `repo_source` motion/live-map thiếu `source_path`; đã bổ sung **đúng path mã nguồn tồn tại** vào `docs/P3_ASSET_REGISTRY.json`. Run kiểm lại [#37897882946](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37897882946) tại `cb8d5cfe` **PASS**. Đây là kiểm tra tài liệu/registry tĩnh của P3, không phải gate Godot hoặc UI Windows; không cần mở lại thiết kế P3.

## CI thực tế — KHÔNG ghi PASS nếu không có run

- **Focused DV2-03 PASS:** [Actions #37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181), code SHA `e96df1832036c1232f9d0db69d1f37450d0265f9`, official **Godot 4.7.2 Linux**, từng bước Parse/2×300 realm test/`dv2_03_training_actions_test.gd` đều **success**. Bao gồm test lệnh `request_training`, chống EXP trùng, lưu/tải và bảo vệ action `COMBAT`.
- **Full cumulative P3.7 PASS có bằng chứng gần nhất:** [Actions #37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334), code SHA `5296f6106a2fd43d5c1a6f2523854702e9014d63`, fast + full cumulative đều success. **Chạy trước commits lệnh V2 `aa3122a`/test `e96df183`**. Vì vậy **CHƯA có full P3.7 PASS trên cùng source SHA `e96df183`**; đây là MISSING EVIDENCE, không phải FAIL.
- **Windows Godot gate của DV2-03:** **CHƯA CÓ BẰNG CHỨNG**. Không relabel Linux CI thành Windows PASS.
- Test references: `godot/tests/simulation/dv2_03_realm_body_progress_test.gd`, `godot/tests/simulation/dv2_03_training_actions_test.gd`; workflow `.github/workflows/dv2-03-realm-body-progress.yml`. Các commit chỉ chứa MD không tự chứng minh đã chạy lại gameplay CI.

## Thứ tự thực hiện kế tiếp (user đã chốt)

1. **Vẫn DV2-03. STEP 1 runtime + STEP 2 unified disciple presentation snapshot/profile đã focused PASS.**
2. **NEXT — Step 3: minimal real Rèn Thân consumer.** Nối typed `body_training` source vào một consumer facility/slot/cost thật tối thiểu, dùng canonical 1.500 Body EXP/phút trước Căn Cốt/modifiers; giữ `TRAIN_BODY`/body_focus blocked cho tới khi transaction cost + availability được commit thật. Không mở sâu building tree, không invent material catalogue ngoài nhu cầu tối thiểu đã được duyệt.
3. Chạy focused Godot 4.7.2, **FULL cumulative P3.7 trên cùng SHA code cuối DV2-03**, rồi Windows gate và cập nhật checkpoint nếu có bằng chứng. **Chỉ sau khi DV2-03 đóng** mới mở bước 3.
4. **Bước 3 (sau DV2-03):** Trang bị V2/12 phẩm/set, Công Pháp & Combat Skills Nhân–Tiên–Thần, Linh Căn, Đặc Chất, Mệnh Cách, Huyết Mạch, Thể Chất vào đúng runtime source/channel. Các phần chưa consumer phải BLOCKED.
5. **Bước 4 sau bước 3:** live outside-region map group PvE, 5 độ khó mỗi map (kể cả Ngoại Vi vẫn có Boss/Tinh Anh hiếm), AI, né/đỡ AoE, đánh quần công theo tổ đội ≤6 và cụm ≤30, rút lui, drop và cân bằng lại từ đệ tử đủ buff. Không thiết kế thêm quái/map lúc này.

## File bắt buộc đọc ở chat mới

Theo thứ tự: `AGENTS.md` → `docs/GAME_SYSTEM_ARCHITECTURE.md` → `CURRENT_CHECKPOINT.md` → `NEXT_CHAT_HANDOFF.md` → `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md` → `docs/DISCIPLE_MASTER_SCHEMA.md` → `docs/REALM_LADDER_V2_SPEC.md` → `docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md` → `docs/BODY_CULTIVATION_V2_SPEC.md` → `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md` → code/test thực.

Nguồn code: `godot/src/simulation/cultivation/disciple_realm_progress_v2.gd`, `disciple_training_action_v2.gd`, `godot/src/simulation/core/simulation_scheduler.gd`, `godot/src/simulation/state/disciple_state.gd`, `sect_state.gd`, `godot/src/simulation/combat/hunting_pve_run_v2.gd`, `godot/src/presentation/p3_2_landscape_sect.gd`.

**Không hỏi lại các luật đã chốt; không Codex/Work; chỉ code GitHub connector, xác minh live main và gate thật.**

---

## PHỤ LỤC — lịch sử quyết định V2 ở các chat trước (KHÔNG dùng trạng thái ACTIVE/LATEST trong phần dưới làm checkpoint hiện tại)

## Disciple V2 design status

Design-closed:
- Spiritual Root / Ngũ Hành / Dị Linh Căn;
- Combat Stats;
- Disciple Characteristic Framework;
- Traits;
- Mệnh Cách;
- Bloodline;
- Realm Ladder;
- Luyện Thể core + Expedition Stamina;
- Physique base;
- Cultivation + Breakthrough;
- Công Pháp;
- Chủ Đạo / Đạo Lịch;
- Combat Skills;
- Kiếm Tu / Thể Tu / Pháp Tu combat language;
- three-wave Nhân → Tiên → Thần skill evolution.

Do not reopen those systems unless:
- a concrete contradiction is discovered; or
- the user explicitly changes a decision.

---

## Key new skill/path laws to preserve

### Công Pháp
- 1 Chủ Tu + 2 Phụ Tu active;
- inactive learned techniques keep mastery/history but ordinary effects are inactive;
- Tàng Kinh Các transmission is permanent after first archived full manual;
- personal mastery and Sect Nghiên Tu are separate;
- Diễn Hóa creates authored named successors.

### Chủ Đạo
- Chưa Định Đạo → Kiếm / Thể / Pháp;
- no class level;
- no generic class-stat growth;
- Đạo Lịch is lived history, not a free stat multiplier;
- active branches:
  - Kiếm: Ngự / Sát / Hộ;
  - Thể: Bá / Kim Cương / Huyết;
  - Pháp: Ngũ Hành / Y Đạo / Huyền Pháp;
- switching preserves learned content/mastery/history.

### Combat Skills
- mature loadout = 1 Thường + 4 Active + 6 Combat Passive;
- static self passives do not require combat slots;
- triggered/party passives do;
- Nhân Giới learns/opens the full foundational combat language;
- Tiên Giới evolves those families;
- Thần Giới evolves them again with bounded rule-changing effects;
- skill family successor replaces predecessor as active family source;
- skill basis = Tu Vi / Luyện Thể / Hybrid;
- AI = priority 1→4 + skill-specific validity;
- movement uses simple range profiles;
- no universal Mana/Rage/Kiếm Ý resource;
- Ngũ Hành and Tương Sinh are shared skill layers;
- effect tiers Nhân/Tiên/Thần protect control/cleanse/dispel/rule-changing interactions;
- party max 6;
- cluster max 30;
- 0 HP = Bị Hạ;
- monsters/bosses share the same combat primitives.

### Kiếm Cốt dependency
Combat Skills V2 has now defined:
- sword style tag direction;
- weapon requirement separation;
- cast/source/hit attribution.

Kiếm Cốt is **still blocked** until Weapon + Equipment V2 defines:
- canonical weapon types;
- sword equip semantics;
- weapon-requirement checks;
- whether any weapon mastery exists.

Do not enable Kiếm Cốt effectless.

---

## CURRENT NEXT-CHAT PRIORITY — COMPLETE A REAL DISCIPLE V2

The user **changed priority on 2026-10-09**: finish **disciple generation, complete meaningful attributes, real consumer/effects and one playable character** before further equipment forging/upgrading, Pháp Bảo or Phù design.

**Primary work authority:** `docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md`.

Required approach:
1. Audit live main and canonical V2 specs; produce `DV2-00` field → persisted source → derived channel → actual consumer → UI → test status matrix. Distinguish active C1 (validated) from P2 legacy and V2 design-only.
2. Prepare the **smallest first implementation slice**, `DV2-01`: deterministic ONE whole-person candidate/recruit, versioned identity persistence and no hidden rerolls. Then shared derived Combat Stats V2/RealmBodyCore and true progression/element/trait/fate/bloodline/physique/skill effects in tracked dependency order.
3. One recruited disciple must **really cultivate, train body, work and fight**, with stat values used by actual simulation and shown via existing P3.2 real disciple tabs. Any disabled/unimplemented mechanic must be labeled BLOCKED and cannot be shown as active. A real `combat_power` estimate is not the Combat Stats V2 authority.
4. Preserve P3.7C1 open-point lục-duy/recruitment and current Godot 4.7.2 locked baseline, old saves and deterministic generation. No new parallel stats, reroll-on-load or trait/physique grades resurrected as V2.
5. Focused Godot 4.7.2 gate for each slice; cumulative regression on cross-cutting changes and release; 1,000–3,000 disciple cache/perf acceptance; UI visual acceptance remains user-owned.

**Historical handoff at that time:** the user had not yet authorized gameplay code. **Superseded by explicit 2026-10-09 implementation instruction:** DV2-01 is now active; focused DV2-01A Godot 4.7.2 run #37876520342 PASS at commit 22f7d80e; later actual RecruitmentSystem accept-path test and cumulative P3.7 still need their own latest run. Do not claim whole DV2-01 PASS. to start `DV2-01` after audit if not already provided in the new chat; do not create a new numbered P3.x implementation phase without authorization.

**Locked subsystem context still valid:** `docs/DISCIPLE_V2_ROADMAP.md`/Ledger/Master. Realm/Luyện Thể = 30×10 each, Combat Skills = 1 basic + 4 active + 6 combat passive, Core Physique one active/no grades; Kiếm Cốt effect BLOCKED pending legitimate sword-tag/effect. Root/Bloodline/Destiny/Trait are not all implemented just because docs exist.

**Deferred without loss:** `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md` remains approved order but **NOT NEXT**. Equipment 10 slots, 12 phẩm, 24 sets remain locked *design*, no forging implementation. Pháp Bảo/Phù later. Mood/Loyalty/social/family expansion only after core character or smallest genuine dependency.

## Legacy design-document cleanup — 2026-10-08

Superseded legacy design Markdown files for Cultivation/Root/Công Pháp/Path/Combat Skills/Generation/Traits/Bloodline/Physique have been intentionally deleted from the repository.

Legacy runtime code, factories, tests and gates remain until their explicit V2 implementation/migration phases because they still protect regression and old-save compatibility.

Do not recreate or consult deleted legacy design specs as authority.

## 2026-10-09 — STAT-FIRST USER DECISION / NEW DOC AUTHORITIES

User approved correcting all three V2 conflicts: no in-sect Expedition Stamina consumption, no Trait V2 Grade 1–5 (profession talent grades remain), no Combat Power as V2 combat authority. **Design approved, legacy runtime not migrated or tested.**

User approved four-stage work order: base/derived stat audit → combat and production result contracts → effects-to-consumer map → implement canonical birth/character in phases after unresolved inputs are explicitly approved.

Read additionally, **before editing future V2 gameplay**:
- `docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md` — core Lục Duy/Realm/Body, Combat Stats 14+resistance, production channels and open numeric gates;
- `docs/DISCIPLE_V2_EFFECT_SOURCE_MATRIX.md` — 53 original + 48 proposed Traits (101), 24 Fates, 10 Roots, 5 Bloodlines, 15 Physiques;
- `docs/DISCIPLE_V2_ROOT_ARCHITECTURE.md` — whole person/action/owner contract.

Canonical docs corrected: `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md` (Stamina), `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md` (profession talent grade boundary), `docs/TRAITS_V2_SPEC.md` (Cuồng Công gated). Preserve existing backend P3.7C1 gate and old source until migration; `CURRENT_CHECKPOINT.md` is unchanged as no new code gate has run.

**Remaining user design gates:** exact Trait/Mệnh birth weighted eligible IDs + congenital special birth packages; Realm+Body numeric combat growth/Defense mitigation; production material/quantity/quality/rounding by content family; general HP ratio for non-Root sources; DV2-01 version/compatibility decisions. User is willing to reset disposable dev/test characters but has not authorized deleting actual user files automatically.


## DV2-01A REAL CODE/GATE SNAPSHOT — 2026-10-09

- **Active** DV2-01; the first partial integration adds default-off `SectState.disciple_v2_birth_enabled` and canonical `DiscipleBirthProfileV2` domain seeds/version/uninitialized layers. `CandidateState` → `RecruitmentSystem.accept_candidate` → `DiscipleState` save/load deep copies.
- **Godot 4.7.2 focused CI PASS:** [run #37876520342](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37876520342), code commit `22f7d80e`. Original nested JSON int→float failure fixed through normalized seed restore. More complete real-recruit path test at code commit `cbe5438d` awaits latest focused run.
- **P3.7 backend cumulative:** check latest run rather than assume PASS; previous official P3.7C1 closed baseline remains intact by design.
- Numeric proposal **NOT USER LOCKED**: `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`. Work result contract: `docs/DV2_PRODUCTION_RESULT_CONTRACT_V1.md`.
- Never claim 101 active Traits or a complete V2 person yet. Exact per-ID Trait/Destiny weights and relevant birth overrides are still a design gate. Kiếm Cốt birth remains blocked.

**DV2-01A verification update:** official Godot 4.7.2 focused test including real `RecruitmentSystem.accept_candidate` **PASS** [Actions #37876666598](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37876666598) (commit `cbe5438d`). Official **P3.7 full cumulative PASS** [Actions #37876520289](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37876520289) (last changed gameplay runtime commit `22f7d80e`). `CURRENT_CHECKPOINT.md` owns status. **DV2-01 still open**: only versioned identity envelope/seed domains are live under a default-off feature flag. No per-ID Trait/Fate V2 birth rolls, no V2 combat/production consumers. Numeric proposed curves: `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`; production contract: `docs/DV2_PRODUCTION_RESULT_CONTRACT_V1.md`; **full 101-Trait/24-Fate weighted birth pool V1 proposal**: `docs/DV2_BIRTH_WEIGHTS_TRAIT_FATE_V1_PROPOSAL.md` (NOT USER LOCKED, do not activate until reviewed).

## FINAL HANDOFF 2026-10-09 — DV2-01B FULL BIRTH CODE

Current latest code adds `DiscipleBirthCatalogueV2` (101 Trait IDs/weights, 24 Fate IDs/weights, conflict sets), `DiscipleBirthRollV2` (five-root purity, rare mutation, visible/latent Traits, rare fate, Bloodline, Physique and profession talent), integrated into both `RecruitmentSystem.generate_candidate` and Dẫn Tiên `_generate_open_candidate_with_quality`. V2 flag is **OFF** for P3.7 baseline, P2 profile rolls are bypassed only for V2-opt-in new candidates, six foundations and C1 odds not altered. All unreadied effect consumers remain inactive. Latent IDs are stored, never rerolled.

- **Godot 4.7.2 focused/pass:** [Actions #37878256401](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878256401) — candidate→disciple, real ordinary recruitment and **real Dẫn Tiên**, save/load, 100K deterministic births, rates, collisions and no Kiếm Cốt/unsafe fate. Validated 100K samples: Roots 1..5 = [6879,18066,30016,28080,16959]; Bloodline 1969; Physique 2994; Fate 491; Mutation 210, 8 awakened; latent Traits 7986.
- **Cumulative P3.7 real Godot 4.7.2**: [Actions #37878271820](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878271820); consult live result and `CURRENT_CHECKPOINT.md` before closing DV2-01.
- **Numeric Combat V1 user-approved, code DV2-02 not yet begun**: `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`.
- **Trait/Fate weighted birth user-approved, generated by DV2-01B**: `docs/DV2_BIRTH_WEIGHTS_TRAIT_FATE_V1_PROPOSAL.md`.
- **Birth exclusions**: Sword Bone/Kiếm Cốt (weapon consumer missing); Sword Immortal reincarnation fate/Kiếm Tiên Chuyển Thế (birth override not authored); `Thương Binh Kinh Nghiệm` acquired only. Other gated identities can be stored inactive, not applied as buffs.
- **NEXT** after DV2-01 closes: DV2-02 canonical derived modifier engine + real stat-based Combat/Work channels according to the phase roadmap; one phase at a time, official gates mandatory. Legacy working-time stamina and trait grade runtime are migration debts for their applicable phases, not already fixed by births. No tests should be marked PASS without actual job conclusion.

## 2026-10-09 — DV2-02A COMBAT STATS IN PROGRESS (LATEST)

**DV2-01 is CLOSED** with focused [Godot run #37878652697](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878652697) and full C1/P3.7 cumulative [#37878652738](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878652738), both official Linux Godot 4.7.2 at code commit `e697c947a`.

**DV2-02 ACTIVE; DV2-02A focused stat kernel PASS** [Godot 4.7.2 #37880761726](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37880761726), relevant code commit `691e1216`. Code `godot/src/simulation/combat/combat_stats_v2.gd`, test `godot/tests/simulation/dv2_02_combat_stats_test.gd`, CI `.github/workflows/dv2-02-combat-stats.yml`, contract `docs/DV2_02_COMBAT_STAT_EXECUTION_CONTRACT.md`.

What exists: all 14 stats + 10 resistances, 300-floor Realm+Body approved numeric core, Tiềm Lực core-only, typed source validators/unique attribution, deterministic source breakdown, independent DR/resist stacking, stat-rate intervals, status/crit chance and Defense formula, HP ratio. **What does NOT exist yet:** actual monster/boss V2 stat profiles, character's persistent two independent 30×10 tracks (DV2-03 implementation later), skill family action adapters, combat-system migration from `combat_power`, all conditional Trait/Fate/etc effects, real cache/UI. Do not declare DV2-02 finished or pretend PvE uses new stats. Keep one active phase only. Next task stays **DV2-02 actual end-to-end consumer integration with explicit legitimate inputs**; do not jump into production or another character birth pass.

## LATEST 2026-10-09 — DV2-02B LIFESTEAL USER DECISION & ACTUAL HP SLICE

**Now 16 canonical headline Combat Stats (14 previous + 2 new):** `lifesteal` (**Hút Máu**) and `lifesteal_reduction` (**Giảm Hút Máu**). Both default 0; add/subtract via `percentage_points`. **Net Lifesteal = max(0, attacker Lifesteal − defender Anti-Lifesteal)**; calculate healing on **real HP damage lost after all mitigation**, capped by defender's pre-hit HP and attacker's missing HP. No hidden extra heal from overkill, no healing on zero/ineligible damage, no arbitrary 100% upper stat cap. Baseline direct hits allowed; DoT/proc/reflection/summons require explicit opt-in; Healing Done/Received separate.

`godot/src/simulation/combat/combat_stats_v2.gd` now derives **16 + 10 keyed resistances** and exposes `settle_damage_and_lifesteal`. `godot/src/simulation/combat/combat_system.gd` adds isolated `commit_v2_direct_hit` that *actually updates* two `DiscipleState.hp` values once per encounter hit ID without altering legacy P3.7 gameplay routing. Focused official Godot 4.7.2 [PASS #37881952009](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37881952009). P3.7 cumulative CI for the actual CombatSystem touch: [Actions #37881991189](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37881991189), check exact status before claiming anything. User-approved authority: `docs/COMBAT_STATS_V2_SPEC.md` §2.7 and `docs/DV2_02_COMBAT_STAT_EXECUTION_CONTRACT.md` §4A.

**Remain DV2-02 ACTIVE** until genuine character 2-track state, monster HP/ATK/DEF, skill/encounter routing, source activation and regression are complete. No DV2-03 progression implementation, no 101 Trait effect activation, no in-sect Stamina drains, no new production systems in this turn.

## LATEST 2026-10-09 — DV2-02C CONTEXT MODIFIERS / MONSTER FOUNDATION

**User request:** expand useful combat attributes **without diluting core game**, including bonus vs boss, bonus vs species, additional hit after basic attack, preserve future design space, and begin building monsters. **DV2-02 remains the only active phase.**

**Main Combat Stats unchanged:** 16 headlines including Lifesteal/Anti-Lifesteal; 10 keyed elemental resistances. **NEW CONTEXTUAL CHANNELS with real consumers:** `damage_vs_boss`, `damage_vs_elite`, `damage_vs_race/<race_id>`, `basic_followup_chance`, `basic_followup_damage`. Matching boss+race modifiers in same context bucket are **additive**; tiers mutually exclusive, one primary race; additional basic hit is maximum ONE, nonrecursive, noncrit/nonlifesteal/nonproc. Initial extra hit 60% is **pilot tuning, not final user-approved**.

**Monster code:** `CombatContextEffectsV2`, `MonsterCatalogueV2`, `MonsterEncounterV2` under `godot/src/simulation/combat/`; seven V2 species including all three old IDs and new elite/boss variants. Real monster HP/Attack/Defense scale over 30×10 using G as numeric basis and **provisional monster factors**, no `combat_power` damage. Same `CombatStatsV2.resolve_direct_hit` for outgoing and incoming; one hit-ID one payout; initial monster basic retaliation and player bonus basic hit on real HP. New loots and real AI phases not implemented. P0/P3.7 combat path unchanged.

**Focused actual Godot 4.7.2 PASS:** [Actions #37883140317](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37883140317), 16 core/lifesteal tests and 7-monster/300-floor/contextual/boss/extra-hit tests. Previous real P3.7 cumulative [Actions #37882134550](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37882134550) PASS before adding isolated MonsterV2 prototype files; do not pretend same-commit cumulative gate green for new files.

**NEXT work within DV2-02 only:** author actual monster action/AI/skill capability readiness (using shared Combat Skill primitives), contextual effects gate and race taxonomy consistency; then integrate monster stats/skill packets into an opt-in real encounter, with rewards/events/save/progression/readiness and cumulative regression. Do not turn `behavior_id` into an actually working AI merely by naming it, do not enable new item drops, and do not invent permanent birth stats. Written authority: `docs/DV2_02_CONTEXT_STATS_MONSTER_FOUNDATION.md`.

## LATEST 2026-10-09 — DV2-02D GROUP MAP BATTLE (DO NOT ASSUME 1v1)

**User correction/requirements:** Disciples and monsters engage **as real groups on the outside-region map**, not as 1v1 instances. Support 6 disciples per actual party, up to 30 disciples (multiple parties) in a hunting cluster, multiple concurrent monsters. Balanced meaningful encounter challenge; player expects clear positioning, targeting, motion, support, attacks, skills, boss AoE and retreat.

**New source:** `godot/src/simulation/combat/map_battle_v2.gd` (one deterministic 2D arena/encounter with many actors, movement, range, threat via nearest selection, basic and existing `CombatStatsV2` damage, HP siphon, frontline guard, healer same-party heals, mage max-three AoE, elite/boss telegraphed max-three delayed AoE, downed/zero HP no ordinary revive, event trace); `godot/src/presentation/p3/map_battle_world_layer_v2.gd` + `godot/scenes/p3/map_battle_world_layer_v2.tscn` (`Node2D` rendering adapter; reads authoritative 2D positions, health bars, telegraphs; **no RNG/time consumption**, no map camera outcome influence; placeholder art). **Still NO real live outside-region map integration** or live scheduler/hunting group assignment, obstacle paths, rewards, monster AI content, battle save/reload. P0/P3.7 real PvE remains legacy and unchanged; DV2-02 is ACTIVE (NOT PASS).

**Tests:** `godot/tests/simulation/dv2_02_group_map_battle_test.gd` focused official Godot 4.7.2 Linux **PASS** [Actions #37884662844](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37884662844); also earlier focused 16-stat and monster test in same CI. P3.6A scene parse smoke [#37884519447](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37884519447) PASS. 30-member cluster test, 6/party rejection, no cross-party healing, input-order determinism, viewed-map/offscreen identical, real Node2D map position selection, boss area dodge, support and AoE, no permanent death.

**16-seed pilot balance per formation after real iteration:** 3v3 normal **16/16 win, 0 average downed, 15.72s**; 4v5 normal **16/16, 1 downed, 22.02s**; 6v6 elite **16/16, 2 downed, 24.03s**; 6v5 boss+4 guards **16/16, 2 downed, 23.64s**; weak 3v5 vs boss **0/16**; six disciples at +1 major realm vs boss **16/16**; six without healer vs boss **16/16** means build-role balance still needs meaningful work. These are **pilot inputs only**, not game-wide win guarantees. 16 samples do NOT mean a 100% universal win rate. First balance was grossly overtuned elite/boss 0/16, now pilot tier factors elite (HP1.35,ATK1.10,DEF1.10), boss (HP2.50,ATK1.30,DEF1.18). Frontline guard 35% remaining damage reduction for 4s when below 75%, cooldown 9s; healer 1.80×ATK heal every 5sec same party. All new skill numeric values are **PILOT NOT USER LOCKED**. Full report `docs/DV2_02_GROUP_MAP_COMBAT_CONTRACT.md`.

**NEXT WITHIN DV2-02:** real outside-region map/session lifecycle + group assignment and P3.7 compatibility adapter; actual skill content/AI shared cast/projectile primitives; player-driven role/tactics, balanced different lineups/regions/levels; rewards/encounter ID journal, save-reload midbattle, strategic risk/reward. Before production migration, run FULL real Godot cumulative. Do not start unrelated DV2-03. Avoid assuming group pilot already replacing live combat.

## LATEST 2026-10-09 — USER CORRECTED OUTER MAP ELITES/BOSSES & PvE SCOPE

**USER:** “ê mà ngoại vi k có boss với tinh anh à. :v ==!. với lại đi đến pve là đúng chưa nhỉ.” This means earlier pilot spawning **incorrectly locked Boss out of L1–4 and Elite out of L1–2**; correct to **all five difficulty levels may contain Elite/Boss**. Outer tiers must be *rare*, not impossible. Difficulty controls their **encounter chance / number / stats / rewards**, never global monster-taxon eligibility.

**Implemented actual source:** `godot/src/simulation/combat/hunting_map_v2.gd`, five per-map selected levels; **L1 Elite 6%, Boss 1%**; **L2 Elite 14%, Boss 3%**; **L3 ≥1 Elite and Boss 8%**; **L4 ≥1 Elite and Boss 16%**; **L5 guaranteed Boss+2 Elite**. All rates explicitly **PILOT, not user-locked universal spawn rates**. At easy L1/2, a Boss removes optional Elite from that encounter to avoid stacking rare special encounters in a tiny group. Boss/Elite use same species + tier + difficulty modifier stat authority. Rare Boss still needs visible on-map warning/optional engagement/retreat before automated PvE; **not implemented yet**. Do not assert it was.

**Test fix:** `godot/tests/simulation/dv2_02_five_level_pve_test.gd` now tests 1,300 deterministic encounters per level for 1–4, must actually encounter Elite/Boss at each tier, while preserving mostly ordinary encounters L1–2; compare *the same monster species stat scaling*, not the random first monster slot (which may be an unexpected rare Boss). Official Godot 4.7.2 [PASS #37886852624](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37886852624): L1 Elite 87/Boss 14, L2 Elite 182/Boss 37, L3 Elite 1300/Boss 108, L4 Elite 1300/Boss 212 (out of 1300 seeds each).

**Priority/scope clarified:** proceeding to PvE **was correct to give the stat engine real group combat targets and a testable economy feedback loop**, but **NOT** correct to fully design/finalize the entire PvE system before the actual dual 30×10 Tu Vi/Luyện Thể tracks, 10-slot equipment V2, Nhân/Tiên/Thần Combat Skill runtime and activated innate effects exist. Keep DV2-02 active for the canonical stat consumer/monster contract, freeze extended world content, move to remaining character dependencies in planned sequence when DV2-02 is actually eligible to close, and do not call group simulator opt-in runtime "live P3 PvE". The five-map per-region difficulty, opt-in group combat and P3.7 warehouse reward slices remain useful staging code; final balance is OPEN.

**Docs:** `CURRENT_CHECKPOINT.md` and `docs/DV2_02_PVE_FIVE_LEVEL_RESOURCE_LOADOUT_CONTRACT.md`. Latest full P3.7 cumulative after spawn rarity change: GitHub [#37886852526](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37886852526), check current status. Focused latest is green; do not confuse the two.

## LATEST 2026-10-09 — DV2-03 REAL 2×300 TU VI/BODY PHASE (ACTIVE)

**User sequencing locked**: 1. DV2-02 *core* DONE (focused+full Godot), 2. DV2-03 real Tu Vi & Luyện Thể tracks **CURRENT**, 3. real V2 Equipment/skills/innate effect attachment, 4. expanded map PvE/AI/balance. No new monster species, maps or ungrounded EXP/chances.

**Code**: `godot/src/simulation/cultivation/disciple_realm_progress_v2.gd`, `godot/src/simulation/state/disciple_state.gd` and `godot/src/simulation/combat/hunting_pve_run_v2.gd`. Genuine complete V2 birth profile required; real two *separate* 30 major realm ×10 floor states saved; natural gains +0.25% Tư Chất and +0.20% Căn Cốt/pt, explicit validated per-floor costs, deterministic same-channel named XP modifiers, fixed gains not boosted. Minor levels auto, only floor10 major gate requires verified authored requirements/chance. Tu Vi failure 10% gate XP lost, 5pp same-gate pity, no generic HP/stamina loss. Independent Luyện Thể gate requires verified authored Body conditions; no guessed material recipes or Tu Vi chance. Real CombatStatsV2 consumes both tracks; V2 group hunt refuses incoming fake realm coordinates and reads persisted character progress.

**Godot 4.7.2 focused PASS:** [Actions #37893363804](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893363804) at `522c72d8`, covers recruitment, 2×300, EXP laws, gate, status persistence, stat recompute, PvE anti-spoof. **P3.7 latest full cumulative:** [Actions #37893455770](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893455770), inspect completion before claiming PASS. `CURRENT_CHECKPOINT.md` is status authority.

**Still open within stage 2:** real Rèn Thân facility/cost consumer, production/expedition source hookups, exact Body gate material packages, persistent runtime/offline + interface. Shared 300-floor costs and 29 Tu Vi base chances are no longer open. The previous `CultivationSystem.STAGES` legacy XP/chance tables cannot be silently reused; no false "DV2-03 all done" claim. `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md` explains code and limitations. Phase remains ACTIVE, not quietly switching to equipment/skill phase 3.

**Update 2026-10-09 DV2-03 focused gate:** all **60 locked realm names (Tu Vi 30 + Luyện Thể 30)** now exposed from persistent tracks, status [focused official Godot 4.7.2 PASS #37893767560](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893767560) at `57fa72ae882b`. Previous full P3.7 [#37893455770](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893455770) PASS; latest [#37893767454](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893767454) **running at last check**, verify before claiming full same-commit PASS. Explicitly **DV2-03 remains ACTIVE** until real authored XP/chance/body materials/action earning or an explicitly scoped core closeout; do not automatically move to Equipment V2. Detailed source: `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md`.

## LATEST 2026-10-09 — DV2-03B REAL ACTION GAIN IN EXISTING SCHEDULER (CURRENT)

User approved continuing Tu Vi/Luyện Thể V2 before real equipment, skills and map AI. **Historical note:** this slice originally routed both `CULTIVATE` and provisional `TRAIN_BODY`. **Superseded 2026-10-09:** only Tu Vi has a live time-source contract (`base_tuvi_per_minute` + Chuyên Tu multiplier). `TRAIN_BODY` is fail-closed because Luyện Thể training mechanics were not actually locked. Body keeps only generic 30×10 progression/grant math for future authored sources. `SectState.v2_training_enabled` remains default-off and **canonical shared 300-floor EXP curve now exists**.

**FOCUSED real Godot 4.7.2 Linux PASS** [DV2-03 #37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181) at code `e96df183`, runs two-track + `dv2_03_training_actions_test.gd` test. Test values (e.g. 80/50 EXP action and 100 EXP floor cost) are **ONLY test fixtures**, not canonical game balance. Full P3.7 [#37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334) **PASS** at scheduler code `5296f610`; newer player-request focused gate also PASS, but **not a full cumulative on identical latest SHA**. Detailed contract `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md`.

**Next within DV2-03:** deliberate approval of 300-floor per-track cost curves, real training EXP/action rates, 29 major Tu Vi baseline chances & breakthrough material conditions for Body, plus V2 actor autonomous training policy/priority, full old→V2 HP authority/scheduler transition. Keep phase **ACTIVE**, do not jump to equipment/skills or outside-map PvE, and do not claim finished V2 naturally scales through all 300 floors while default rules are empty.
