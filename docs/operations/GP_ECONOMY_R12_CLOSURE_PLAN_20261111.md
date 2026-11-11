# GP-ECO-R12 — Tông Môn Bá Đạo, economic closure implementation plan

## ECO-04 r1 IMPLEMENTED — FOCUSED GODOT PASS / FULL CUMULATIVE STILL RUNNING (2026-11-11)

- **Scope and source SHA:** PR #72 Draft on its existing branch; code [`21be58a3f4bc874267ed42c6ca3ed837e250d293`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/21be58a3f4bc874267ed42c6ca3ed837e250d293), subsequent **test-only** strict GDScript cleanup fix [`9a8f5bf84ee7a6ce211f7f068f2469eac3a47cc3`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/9a8f5bf84ee7a6ce211f7f068f2469eac3a47cc3). Official [ECO-04 exact-SHA workflow #42988582430](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42988582430) on `9a8f5bf8`: **strict parse + ECO-04 0/30/70/100 tax model/1-vs-60/90/180 + funded W2 + partial deferred T2, cold Save and duplicate/forged receipt checks PASS; canonical SX-V55 real Mine/Forest/Field r1–r2 source-backed LT2/T2/W2 and Save PASS; original 1/7/30/30 realm/source HOLD gate PASS.** O4 had passed when last inspected; Economy-A and remaining O3/O7/O9/O6/P3.6A/FULL P3.7 continue. **DO NOT MARK FULL PASS until terminal SUCCESS.**
- **Production fix and authority:** `EconomySystem` uses one read-only money-split helper for authentic LT2 earned gross, W2 shortfall only when gross is below floor, and T2 as personal→Sect internal transfer. New snapshots pin `tax_pct`, old snapshots without the key remain compatible with the frozen site baseline. `pay_work_wage_arrears` now verifies matching persisted `sxv55-work` authority before transferring late W2; reuses existing receipt ledger and cumulative tax rounding so splitting requests across Save/Load cannot avoid T2. `wage-arrears` receipts record gross debt cleared, tax withheld, and actual Sect net paid; **legacy Economy-A normal wages without W2 keep original full transfer**. No SaveService/schema or second currency authority.
- **QA vs LIVE distinction:** 0/30/70/100 site tax values are only arithmetic **nonmutating QA previews**, not player-configurable controls; 1-minute topup arrears uses a **synthetic transfer-only unit fixture**, not a claim that an unauthored real 1-minute job produced income. Existing genuine Mine/Forest/Field real timed jobs have separate strict runtime regression. `configure_v1` continues to reject player `sx_v55_r12_economy`; public LT2/W2/T2, 0-100% worksite tax UI, r3+ and r2 pricing remain **HOLD** pending ECO-05 and explicit release authorization. Unchanged original r1/r2 source rates.
- **Initial red QA** [#42988426053](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42988426053) was a strict parse error for the new test cleanup `path` variable, fixed in follow-up test-only SHA; red run is NOT production settlement failure. Source code freeze and final full closure require exact-SHA evidence.
- **Physical QA** Windows 1280×720 and Android real device PENDING USER; no branch/merge, no combat/VFX/skills/enemies, no SaveService/shared-state edits. ECO-05 not yet opened.

Date: 2026-11-11 | PR #72 Draft | One branch: `integration/pve-p0-playable-ui-20261103`
Status: **DESIGN / STAGED CODE PLAN ONLY; NOT IMPLEMENTED**. Scope: r1-r2 non-combat Economy. Do not enable locked LT2/W2/T2 or r3+ before acceptance. Read `AGENTS.md`, `CURRENT_CHECKPOINT.md`, GP-PLAY01 master §14–15 and exact latest SHA before each phase.

## 0. Evidence and present source authority

- Player starter Sect treasury in `P37Factory` = **500 Linh Thạch**. Live Economy-A default `wage_per_batch=2`; Field real plot debit Linh Cốc 3 LT, Thanh Linh Thảo 4 LT, Tử Vân Thảo 14 LT. Valid Mine/Forest/Field production -> canonical Warehouse -> real consumption/market settlement already exists.
- Actual, player-exposed `EconomySystem.sell_to_npc_v1`: only allowlisted material stock is sellable; Thanh Thiết **8 LT/unit**, Linh Mộc **2 LT/unit**, capped at 20 units/day for 6 owned actors and up to 240/day for 30 owned actors; per-sale max 5 unless current policy changes. Sale consumes **spendable real Warehouse stock** and issues once-only receipt. NPC sale is not automatic or guaranteed.
- Existing optional `SXV55_EnableBulk` is **production-only**, separate from locked economy. Bulk canonical plan example: Thanh Thiết 10,000/60 sim ticks; Linh Mộc 8,000/60; Linh Cốc 2,500/60; Thanh Linh Thảo 2,000/90; Tử Vân Thảo 1,000/180. These are not NewGame default and never apply to unauthored IDs.
- `EconomySystem.SX_V55_R12_POLICY` and the PvE reward pilot are **player HOLD**. Internal r1/r2 gross minute rates 1,000 / 2,000 and W2 wage **floor**, not additional payroll; frozen QA tax BASE 70% Mine, 30% Forest, 40% Field is **not a 0–100% player UI**.
- Legacy economic stress uses a **conditioned 360 effective work minutes/worker/day scenario**, 6 active producers: 34 jobs/day, 34 LT seeds, 68 LT wages, total 102 LT/day; 30 active conditional 170 jobs, 170 LT seeds +340 LT wages=510 LT/day. **30 owned != 30 active funded worksite slots.**
- Official Godot 4.7.2 [run #42952728803](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42952728803) **WHOLE SUCCESS 20/20** on exact test SHA `efea6ba0c6fb2a6b854abaa3ae597023ddbc0c25`, including 6/30 no-NPC 1/7/30 stress and P3.7; not general full-HEAD proof because other chat later edited combat. GP2-A/B previously passed Economy-A/O6 exact SHA `a1f686a`.

## 1. Owner-directed design goals

1. **Never permanently softlock the basic capital loop** even at Sect treasury 0 LT, NPC unavailable, no tax revenue. The Sect must have a source-backed, player-visible *free-to-start* job that yields cash after real simulated time and labor.
2. Preserve purposeful production. Mine and Forest make tangible source-backed inputs; Field requires explicit seed cash; alchemy and forge consume canonical stock; no ghost warehouse entries or resale of proposed r1/r2 IDs.
3. No unchecked inflation. Starter safety income is **one payout per Sect per 1440 sim ticks**, independent of roster size (6/30/480) or worker swaps, and cannot be repeatedly claimed through load/restart.
4. Wages are Sect→personal transfer (or durable arrears); T2 is worker→Sect transfer. Those are **not** external money creation. Show Sect, personal and combined conservation separately.
5. High-tier costs should create meaningful decisions, not force players to idle hundreds of days. Reconcile V5.5D ×1000 capital prices, Field seed denomination and actual capital access **before** public LT2/W2/T2 unlock.

## 2. ECO-01: Proposed source-backed basic income — *Linh Mạch Khởi Nguyên*

| Attribute | Proposed gameplay contract (subject to exact-SHA feasibility QA) |
|---|---|
| World source | A small permanent `Linh Mạch Khởi Nguyên` vein at/under starter Sect Hall; in-world deposit, **not NPC trade or pretend item sale** |
| Unlock | NewGame, no construction/upgrading cost, accessible when treasury=0 |
| Worker | One real present, eligible non-injured Sect disciple; consumes a valid active job slot, never works concurrently on any other job |
| Input | 0 LT; 0 purchased materials; no seed/tools market dependency |
| Duration | **60 simulated ticks** per attempt, real offline progress under canonical clock |
| Output | **1,000 LT gross per eligible completed cycle** to Sect economy, not a new mine ore inventory ID or an external NPC transaction |
| Wages | Use existing Economy-A wage receipt on settlement, paid from *newly earned proceeds* rather than a start fee. At current 2 LT wage, Sect +998 and disciple +2; **1000 gross is not 1000 net** |
| Production limit | At most 1 cash-yielding completion per Sect **per 1440 simulated ticks** with a cooldown across the day boundary. No multiplication by workers, sites, realms, offline elapsed minutes, or game resets |
| Failure | Invalid worker, active job conflict, missing real starter location or forged job: no payout; recover/reassign existing worker without a money charge |
| Old saves | Existing saves retain identity; if Hall exists, source is exposed through derived/guarded migration-free authority. No SaveService or shared-state schema modification without separate approval |
| Accounting | Canonical `BuildingSystem/WorkforceSystem` validates job; `EconomySystem` settles once and writes a deterministic persistent receipt in existing allowed ledger, same SHA job and sim tick; all updates atomic and replay-idempotent |
| Player UI | In Hall/Mine: icon, name, `Miễn phí · 60 phút · +1.000 LT gộp`, actual worker, time left, completed today / next ready and Sect treasury amount |

If an always-available site cannot be anchored in currently persisted canonical building authority without SaveService/shared-state edits, **ECO-01 halts** and redesigns using an existing persisted job owner. Never substitute a memory-only UI timer or write a second wallet. Production must be source-backed in game world; no daily login gift, fake stock, or free NPC sale.

## 3. Cashflow design: layered income and sinks

**Layer 1 (survival):** ECO-01 starter vein: guaranteed route from 0 LT to a source-backed payout **after active work**, no NPC/tax needed. The daily cap is per Sect, not per actor.

**Layer 2 (real enterprise):** Mine, Forest and Field output actual Warehouse materials. Actual user-initiated NPC sales and real crafting consume stock. Maintain already-live sell prices and caps until a scenario-backed deficit demonstrates a need to change them.

**Layer 3 (advanced r1/r2 wages and tax):** after ECO-01 and explicit analysis, refit LT2 into source-authored completed job income with frozen snapshot, one external gross per valid job, W2 topup funded from Sect only, T2 as transfer. A future 0–100% per-worksite tax control is **a separate gate**; tax=0 must not break Layer 1.

**Layer 4 (expensive progression):** invest in meaningful real production upgrades, real rare input access and alchemy/forge; expensive pilot `Hall+Field+Mine+Forest Lv1→2` wave =649,000 LT +42k ore+46k wood **only when QA-locked denomination is enabled**. That wave must not be pushed into public default just because ECO-01 yields ~1k/day: it would otherwise demand hundreds of days of survival income alone.

Proposed money accounting invariant:
`external_payouts = Δ(Sect LT + Σ personal LT) + real currency sinks - other verified external payouts`, with T2/W2 *internal transfers* cancelling in the aggregate. No negative balances, money from expected (not completed) batches or duplicate offline cycles. Record rare material inventory and Warehouse reserved stock separately.

## 4. Illustrative 6/30 break-even (model, not runtime proof)

At current conditional 360-valid-minute plan and no NPC, T2=0, existing Economy-A 2 LT wage/job:

| Active paid producers | Mỏ/Lâm/Điền jobs/day | Seed LT | Wages LT | Total LT requests | One ECO-01 1,000 LT gross/day | Expected net Sect after expenses, current wage2 included in `wages`? |
|---|---:|---:|---:|---:|---:|---:|
| 6 (2+2+1+1) | 34 | 34 | 68 | 102 | 1,000 | +896 LT/day if vein incurs another paid 2 LT wage; otherwise +898 |
| 30 (10+10+5+5), PAID worksite slots required | 170 | 170 | 340 | 510 | 1,000 | +488 LT/day if vein incurs another paid 2 LT wage; otherwise +490 |

These are *planning ceilings* with assumed 1 completed starter vein cycle/day. A worker assigned to the vein is not simultaneously available to complete a full day's producer work; therefore executable tests MUST reduce production or allocate one additional eligible worker, rather than asserting two full-time simultaneous jobs. For a 6-owned roster, a baseline 6-active work plan with the same six actors can only complete the vein by reallocating time. This table is an upper bound and must not be labeled an observed net profit.

The vein is a **capital safety rail, not primary upgrade financing**: baseline progression investment needs legitimate sale proceeds and/or later approved source-backed LT2 at balanced wages/tax. Keep 0%-tax/no-NPC cases playable at the minimal paid seed level; do not promise every expensive progression with only the fallback.

## 5. Phase-gated implementation sequence (one active CODE packet at a time)

| Gate | Files/authority | Work to implement/test | Acceptance evidence |
|---|---|---|---|
| **ECO-00 baseline** | Read existing EconomySystem, BuildingSystem, WorkforceSystem, Warehouse, SpiritCropRegistry, Market, P37Factory and actual UI | Compare full latest HEAD with tested SHA, source-backed balance table; distinguish 6 owned from paid 6 active and 30 owned from paid 30 active | Official 4.7.2 baseline O3/O4/O5/O7/O9, SX V55, P3.7; exact SHA; no combat edits |
| **ECO-01 survival income** | Noncombat real work job + Sect existing receipt and UI | Anchor original vein, free start even with 0 LT, one real 60 tick active job, 1000 gross once/24h, wage paid from proceeds, no second money authority | 0 LT/0 NPC/T2 0 cycle recovers, One Active Job, 1-day/cross-midnight, double-click, aborted job, cold Save, 180min offline once, forged IDs fail |
| **ECO-02 truthful market** | EconomySystem, Warehouse, UI; no fake supply | Preserve only allowlist sellable and market cap, display minimum reserve and user-prompt sale flow, test 0 buyers and reserved stock | 13 ore/day conditional break-even for 6 active and 64/day for 30 active; disabled buyer=zero money; Sell receipt once after reload |
| **ECO-03 money and production costs** | CropRegistry/BuildingSystem/EconomySystem, unchanged V2 Save | Trace seeds and wages preflight; one job/worker; avoid starvation from affordability; reconcile cash cost of actual plant vs V5.5D spreadsheet | 1/7/30 days, 6/30 active conditional schedules, no negative Sect balance, no unpaid wage phantom transfer, no non-source crops |
| **ECO-04 T2/W2/LT2 stage r1 only** | QA-locked rates/policy; needs separate activation authorization | Preserve frozen job snapshot; wages as floor shortfall; site tax 0–100% only after funded paths; prevent yield/cash double-counting | Sect+personal money conservation, 0/30/70/100% tax, 1m vs 60/90/180m, max output, replay/Save/old jobs; keep player HOLD until green |
| **ECO-05 r2 capacity/progression** | Genuine Lv10/milestone, R1→R2 sources and upgrade quote | Reconcile 649k pilot quote, r2 wage/tax and actual upgrade time/money, 6→30 affordable site capacity via real buildings | 1/7/30-day source-backed stress; no magic paid 30 staff, no upgrading without true ore/wood/money |
| **ECO-06 economic feedback UI** | OneGame Hall/Worksites/Market/Warehouse | Clearly label startup income vs sale vs tax vs wage, production ETA/plot cost/available stock and imminent shortage | 1280×720 GUI harness; no panel close/restart; no misleading gross vs net |
| **ECO-07 full audit and acceptance** | Existing test workflows only, no disabled assertions | 0/500 LT starts, no NPC or NPC enabled, 0/100% tax future pilot, 6/30/480 roster, jobs and offline 60–180m, cold Save/Load | Focused exact SHA + P3.7/O2/O3/O4/O5/O6/O7/O8/O9/GP02B1/C1/SX-V55 and Economy-A full SUCCESS; ownership isolation |

**Negative paths mandatory**: pressing claim twice, cross-day fast-forward, reloading after early start, loading old Save with no new source receipt, swapping worker during job, Injury/worker busy, player toggling bulk mid-batch, money near overflow, inventory/reserve errors, market closed, simultaneous UI interaction.

## 6. Release gates and blockers

- **No ECO-01 runtime code until user selects implementation step**. This file is a plan, not deployed income; prior 500 LT/3–4 LT crops and QA runs are factual baseline.
- **Design tradeoff to retain:** 1000 gross/day/sect is an initial conservative proposal; if empirical inflation/upgrade stall occurs, rebalance through real economics rather than spawning currency: alter time/output/cap only after source-based 1/7/30 and ROI simulation, record owner decision.
- **Player LT2/W2/T2 remains HOLD** until ECO-01 rescue path, ECO-03 costs, ECO-04 tax floor and ECO-05 upgrade price are reconciled. r3+, 111 candidate pill recipes, PvE combat rewards remain other scopes.
- **One branch/PR #72**, no merge, no SaveService or shared state updates, no combat/monster/VFX/skills. Windows E: 1280×720 and Android physical QA **PENDING USER** until the owner runs hardware evidence.
- **Order:** ECO-00 → ECO-01 → ECO-02 → ECO-03 → ECO-04 → ECO-05 → ECO-06 → ECO-07. Do not open all feature toggles at once.

## 7. ECO-00 → ECO-01 source implementation and evidence ledger — 2026-11-11

**STATUS: CODE + focused official Godot 4.7.2 PASS, cumulative CHECKING at this evidence snapshot.** Exact code/test SHA [`75c01285a79b64bcae51a081d6462a6322e49b3e`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/75c01285a79b64bcae51a081d6462a6322e49b3e); integrated workflow [ECO-01 #42960180733](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42960180733).

### Modified authority (no SaveService or shared state schema edits)

- `godot/src/simulation/economy/eco01_origin_vein.gd` — one canonical Hall `production_state.eco01_origin_vein.job`, 60 sim ticks, 1,000 gross LT, 1/1440 tick Sect cooldown, existing Economy-A wage+receipt, deterministic job ID, explicit cancellation, frozen start/finish, no extra inventory, zero-LT start, overflow and invalid-worker fail-closed.
- `godot/src/simulation/building/building_system.gd` — calls vein settlement once from the existing Godot scheduler's BuildingSystem tick, including offline simulation catch-up; no second game clock.
- `godot/src/simulation/workforce/workforce_system.gd` — ECO-01 `active_job_id` blocks other profession jobs, direct commands and worksite/group transfers until the actual job finishes or is cancelled.
- `godot/src/presentation/p3_2_landscape_sect.gd` — Đại Điện controls for actual eligible worker, source cost 0, +1.000 gross, ETA, cooldown, begin/cancel; automatic canonical Save request on mutation; UI does not credit money.
- `godot/tests/simulation/eco01_origin_vein_loop_test.gd`, `godot/tests/presentation/eco01_origin_vein_hall_ui_test.gd`; official workflow `.github/workflows/eco-01-origin-vein.yml`. Test actual 0-LT initial account, business wage transfer, receipt and anti-replay, day boundary, cancellation, 6/30 real candidate IDs with QA-only housing cap override, cold Save and `LiveGameRuntimeV2` 60-minute offline replay, real 1280×720 Hall scene harness (NOT physical).

### QA provenance

- Historical first workflow [#42958399940](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42958399940) FAIL **test-only/GDScript compile** (`valid` inferred type), fixed by declaring `bool`, no gameplay change. Subsequent [#42958551352](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42958551352) failed second-day test's worker-busy assumption: the first real worker had legitimately started another job. Test now selects truly eligible worker and refuses to clobber active jobs.
- Next [#42958854957](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42958854957) observed +8 LT additional external personal source during a full 60-tick scheduler run (separate P2 economy) beyond ECO-01's own +1,000 gross. Test now isolates ECO-01 deterministic receipt, exact wage and cash consistency instead of treating parallel P2 rewards as nonexistent.
- [#42959252057](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42959252057), [#42959411408](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42959411408), [#42959577752](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42959577752), [#42959770997](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42959770997), [#42960013448](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42960013448) encountered over-strict test comparison of SaveService JSON-normalized numeric values `1000` vs `1000.0`, not actual money loss: both pre/post cold Save Sect balances **1,996 LT** and the source + wage receipts persisted. The test now compares exact integral numeric values and core receipt fields rather than JSON key insertion order/string formatting. No source amount, cooldown, wage or SaveService relaxed.
- [#42960180733](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42960180733) official Godot 4.7.2 exact `75c01285`: Import, strict parse, **ECO01 backend simulation/0 LT/60-tick/Save/offline/6-30 test SUCCESS**, **real Hall 1280×720 UI test SUCCESS**, original Economy-A Hall/market/arrears UI test SUCCESS; O3/O4/O7 focused and full cumulative still in-progress at this checkpoint. Do not claim full until whole job SUCCESS with no affected failures.

**Open gates**: O3/O4/O7/O9/O6/P3.6A/P3.7 cumulative exact SHA; Windows PC and Android physical PENDING USER. LT2/W2/T2 player activation and r3+ remain HOLD. Other writer's V63-only test commits after tested ECO source SHA require their own combat QA; do not label full newer HEAD PASS.
