# TÔNG MÔN BÁ ĐẠO — LUYỆN KHÍ Lv30→75: KỊCH BẢN 1/7/30/90 NGÀY, 1.000–3.000 ĐỆ TỬ, NGHIỆM THU THIẾT KẾ
## Trial-only seeded cashflow modeling and 28 negative/positive gates; do not call this a Godot or actual Sect run

**Date 2026-10-25 · DOCS ONLY · NO CODE / PR29 / PR31 / MAP-D0 / SOURCE A / UI / MERGE / CI.** Owner running Codex MAP-D0 on independent PR31-based docs map redesign. This document is isolated Forge economic research, branch from MAIN SHA `29b5fba448b0178cb520a4ada44b375b4b934e31`. Main profile study: `docs/design/TMB_FORGE_LV30_LV75_THREE_ECONOMY_PROFILES_R20_OWNER_REVIEW_2026-10-25.md`. Ancestor docs branch `docs/forge-lv30-75-r20-predivine-source-cost-softlock-20261024`. Actual sources: `godot/src/simulation/building/building_system.gd`, `resource/{resource_registry,warehouse_system}.gd`, `economy/economy_system.gd`, `state/sect_state.gd`, `combat/hunting_map_v2.gd`, `save/save_service.gd`, P3.7 profession spec and canonical architecture. [OWNER] strict Lv75 before R21 Forge, [SOURCE] code, [PILOT] unapproved balance, [ASSUMPTION] input to math, [SIM] synthetic, [NOT RUN] Godot/Android.

## 1. Formal budget and critical path
**Portfolio profiles taken from companion:** Nhanh `(wood3595,ore5384,Stone3595,yeudan15,build_ticks2758)`; Cân bằng `(5384,7169,7169,30,4102)`; Dài hạn `(7169,10746,21473,45,5330)`. These are 45 real-level payment requirements under HYPOTHETICAL Forge coefficients, not applied in the game.
**Actual capital prerequisite:** one registered real Forge facility at level30, with future owner-approved level31..75 upgrade definition. Current main has NO Forge definition. All construction inputs are pre-R21 registered families, but their possession, route, production rates and settlement are not guaranteed. Then any R21 equipment must separately spend proper Thần material/blueprint/worker time. Defend against a cycle where source for Lv75 first requires R21 equipment.
**Funding formula for surplus ore NPC sales [SOURCE POLICY + SIM]:** default sale20 units/day global to entire Sect, max5 per action, `thanh_thiet` value8 Stones/unit. When `S` actual Sect treasury, `C` proposed building fee, `k` physical surplus ore/day supplied by legitimate source and unreserved, and `e` daily legitimately paid other costs: `NetStockGain_d = max(0, S_d+8×min(k,20)−e_d)`, with actual source/market receipts and negative money never allowed. No new Stone faucet. Source `ResourceRegistry.market_value` alone doesn't prove NPC market eligibility; only four V2 catalog goods qualify.
**Real elapsed time has at least THREE workstreams:** Mine/Linh Lâm/Hắc Phong actual resource accrual; Stone liquidity (NPC daily sale policy); construction on real canonical building ticks. These may overlap only under legitimate different jobs/authorities. Time to unlock first R21 item is even longer due to NEW R21 ore/fiber/beast source, true research recipe, R21 crafting work and legal wearer.

## 2. Upper-bound progress checkpoints 1 / 7 / 30 / 90 days [SIM]
[SIM] Assume initial treasury0, every eligible day an EXTRA20 ore is sold for160 Stones, no other cash income or cost, limitless TRUE stock of construction wood/ore/Yêu Đan from before simulation, market policy unchanged; each level individually completed using at least its ceil(ticks), one building lane, no travel. For each day D, choose the largest complete target level such that cumulative Stone cost≤160D **AND** cumulative construction ticks≤1440D. Because those two constraints alone do not enforce every intra-day funding/payment chronology, the displayed level is a **mathematical UPPER BOUND, not an achieved trajectory**.
| Profile | Day1 level upper bound | Day7 | Day30 | Day90 | Capital-only minimum market days |
|---|---:|---:|---:|---:|---:|
| **Nhanh** | Lv34 | Lv51 | Lv75 | Lv75 |23|
| **Cân bằng** | Lv32 | Lv43 | Lv66 | Lv75 |45|
| **Dài hạn** | Lv30 | Lv35 | Lv48 | Lv66 |135|
| **Old 24/10 pilot** | lower ≤Lv30–31 [not recalculated]|[not recalculated]|[not recalculated]|[not recalculated]|224|
It is wrong to report “Lv66 reached on day30” as tested progress. These bounds assume all raw material and special milestone components already existed and ignore committed worker/repair Stone sinks; in a real new Sect that cannot simultaneously mine or farm the needed quantities, actual level is lower. No Godot scenario or wall-clock projection was run.

## 3. 5,000-run deterministic Monte Carlo — ONLY funding stochasticity, not material or combat
**[ASSUMPTION]** To bracket ordinary operations, generate independent day-by-day variation in ore units SOLD to registered NPC (not an automatically generated ore producer) and other actual potential expenses; all eligible ores are assumed genuinely available separately. Two synthetic budget-policy archetypes:
- “Sect 1.000” [MODEL ONLY]: daily ore NPC sold UniformInteger[10,20], daily other Sect Stones spent UniformInteger[0,24]. Sale cap20, per-request5 enforced conceptually. No start cash or bonus; net receipts at day end.
- “Sect 3.000” [MODEL ONLY]: daily ore sold UniformInteger[12,20], expenses UniformInteger[24,80]. Larger roster doesn't raise NPC daily cap; it may use more resources/pay wages, but REAL expenditure is receipt-based, NOT “every disciple costs1Stone/day”. The two expense ranges are scenario inputs, not authoritative Economy-A policies.
**Algorithm implemented as standalone numerical study (JS arithmetic, NOT Godot):** one continuous xorshift32 uint32 stream, seed `20261025`, 5,000 trials per (Sect model, profile) in order Sect1000×(Nhanh,CanBang,DaiHan), Sect3000×same; each trial starts S=0 and runs max365 sim days. Each day `sold = lower + floor(u×(upper-lower+1))` and `expense` similarly, then `S=max(0,S+8×sold−expense)`. Record first day when S≥full construction fee; if not before day365 report>365; sort hit days, p50/p90/p99 at zero-based floor((n−1)×p). **The code holds NO capital cost debits during accumulation and assumes no extra ore shortage**, so these are funding-horizon estimates only, not actual building completion times. Reproducible outcomes:
| Synthetic group | Profile | Funding-day P50 | P90 | P99 | Completed funding by day90 /5,000 |
|---|---|---:|---:|---:|---:|
| Sect1.000 | Nhanh |34|36|37|5,000|
| Sect1.000 | **Cân bằng** |67|69|72|5,000|
| Sect1.000 | Dài hạn |199|204|207|0|
| Sect3.000 | Nhanh |48|51|54|5,000|
| Sect3.000 | **Cân bằng** |95|99|103|485|
| Sect3.000 | Dài hạn |283|291|297|0|
**All 30,000 trials funded by day365** under these favorable simulated assumptions. This does not prove completion: actual Forge definition, Yêu Đan acquisition, business expenses, inability to sell20 real ore/day, Stone reserve, construction work and R21 source are blockers. Expense ranges, sale policy and hypothetical treasury starting cash materially influence results. No controlled in-game money factory was created.

## 4. Funding sensitivity and failure conditions
- Stone income only from20 daily ore sales ≤160/day, global: zero money and no previous inventory implies needs genuine mining time; if miners cannot produce extra ore, 23/45/135 days are **optimistic lower bounds**. If market limit is custom changed, re-evaluate using actual player policy, don't hardcode20 into future price balance.
- If `market_remaining()=0` for a day, no additional NPC sale receipt that day; spending can continue and cause delayed build, but cannot bypass cap with more disciples or parallel shops. If sell prices differ from current ResourceRegistry or player policy, refresh source and rerun.
- If with policy the only Stone drain is >160/day from actual completed wage/service receipts, capital accumulation from ONLY ore selling becomes impossible; this is **economic infeasibility**, not license to print Stone. Need an authorized independent accessible revenue source/real initial treasury or revised Forge tariff.
- A locked Warehouse ore reserve or a second real repair/job consuming the last component can prevent Lv50/75 payment even after funds are sufficient; keep blocked until released/cancelled by legitimate owner policy.
- For complete 30–45 Yêu Đan milestones at base Lv1 `Hắc Phong Cốc` 2 units per TRUE completed victory, Nhanh15→at least8 encounters; Cân bằng30→15; Dài hạn45→at least23. A Lv1 encounter completion is not one individual monster kill, and is not free just because the map content data exists.

## 5. 1,000–3,000 roster scaling: building bill once, real post-gate outfitting
A canonical ONE Sect Warehouse owns materials and unique items, while 30 is the first hunting-world deployed fighter count. The number of 1,000–3,000 disciples is overall Sect capacity, **not active on a single map**. Any economic throughput for 3,000 must be earned by actual buildings/worker slots/jobs; cannot multiply the market cap20 by roster size.
[PREVIOUS P] Future R21 **ten basic slots**:15 new `eqv2_r21_ore`+21 new `eqv2_r21_fiber`+4 new `eqv2_r21_beast`+420 Sect Stones and320 base Forge ticks *per complete new kit*; additional once-per-Sect research may consume1 ore+1 beast. These IDs/recipes are unregistered, no actual production rates. They remain independent of Lv75 old-world building costs.

| Plan | Fresh R21 kits | R21 ore including one-time research | R21 fiber | R21 beast including research | Post-gate kit Stones |
|---|---:|---:|---:|---:|---:|
| First combat force |30|451|630|121|12,600|
| Hypothetical 10% cohort of Sect1.000 |100|1,501|2,100|401|42,000|
| Hypothetical 10% cohort of Sect3.000 |300|4,501|6,300|1,201|126,000|
| ALL Sect1.000 replaced (not recommended upfront) |1,000|15,001|21,000|4,001|420,000|
| ALL Sect3.000 replaced (not recommended upfront) |3,000|45,001|63,000|12,001|1,260,000|

**Combined initial Stone investment for FIRST30 fighters** (facility ONE instance + kits30): Nhanh **16,195**, Cân bằng **19,769**, Dài hạn **34,073**; old model48,377. The 12,600 additional Stones are not obtainable from existing R21 loot codes because that content is not authored. Old R20 sets may be reused/handed down; do not automatically destroy the old Tiên set without the explicit owner-approved donor inheritance receipt. R21 item wearable legality independently follows Tu Vi/Luyện Thể and weapon/slot, not only facility Lv75.
**Strategic recommendation:** protect building upgrade Stone budget separately from the post-gate first30 squad budget as a scheduling target, not a second wallet; one combined canonical Sect Stones ledger still rules all. First target active30, second one or two selective hunter groups as real demand warrants, then scale toward 10% of roster; otherwise Lv75 capital pays off into a gear-production bottleneck at 3,000.

## 6. Economic anti-arbitrage and 28 candidate QA fixtures [NOT EXECUTED]
| ID | Fault / stress | Expected design response |
|---|---|---|
| Q01 | Luyện Khí type missing in main BuildingSystem | cannot create/upgrade Lv75; don't mark gameplay PASS |
| Q02 | R21 craft attempt from Forge Lv74, any profile | reject for ALL Forge-created R21 items |
| Q03 | Worker forging profession level75 but facility Lv30 | reject R21; worker Lv not facility Lv |
| Q04 | Forge Lv75 but R21 ore/beast not registered | reject before stock debit |
| Q05 | Forge Lv75 and no learned R21 blueprint | no item output |
| Q06 | Source R21 frontier requires itemR21 before gathering | content softlock; author accessible from R20 gear |
| Q07 | Lv49→50 catalyst paid twice on Save reload | one debit/receipt, same target Lv50 |
| Q08 | Lv74→75 requires Thần Boss relic | dependency loop reject, choose pre-R20 source |
| Q09 | Sell same ore twice by repeated NPC action key | idempotent market receipt, one real Warehouse debit |
| Q10 | Two separate sale requests beyond20 global daily quota | second rejected; 3,000 roster doesn't lift limit |
| Q11 | Ore price changed without balance reforecast | recalc funded-days and extra ore, no stale UI static amounts |
| Q12 | Locked warehouse 20 ore at milestone step | reject start, preserve user reserve and all inventory |
| Q13 | Funds needed for build and 30 R21 kits simultaneously | single Sect balance, cannot spend twice |
| Q14 | Alchemy worker re-assigned to Forge and Hunt simultaneously | One Active Job rejects overlapping job |
| Q15 | Forge worker injured during gear job | pause/recover Injury1/120, no output |
| Q16 | Building UPGRADING with ongoing item forge order | drain/freeze known job with one receipt; no phantom product |
| Q17 | Crash after Stone debit but before level mutation | replay atomic result or rollback, no partial charge |
| Q18 | Crash after Lv75 marked but before Save ACK | durable Lv75 once; R21 only when current state ACTIVE |
| Q19 | Active completed job gains XP twice on reload | dedup worker XP by job receipt |
| Q20 | Group30 Boss fight grants 30 Yêu Đan receipts from same death | one encounter/boss life pool, not participant× |
| Q21 | Player uses P2 forge_materials while P3.7 Warehouse on | canonical migration once, no parallel bucket |
| Q22 | A high-tier Body-Gate seal appears in candidate Lv75 bill | reject; no auto resource reassignment |
| Q23 | Clan daily ore sale zero for30 days | no claim capital goal reached; show insufficient valid income |
| Q24 | NPC daily revenue smaller than real recurring Stone sink | funding infeasible absent other verified revenue or stock |
| Q25 | 3,000 disciples apply forge bonus to one construction instance×3,000 | forbid, actual building authority tick only |
| Q26 | R20 Tiên4 set and new R21 Thần piece mixed | no invalid same-generation set4; stash/swap coherently |
| Q27 | MAP-D0 Codex changes branch/PR31 during research | no touch, no claim head stable; only docs branch from main |
| Q28 | Godot4.7.2, Android device and gameplay tests absent | all UI/QA/playable verdicts PENDING, not PASS |
**No runtime tests, Codex MAP-D0 actions, benchmarks, downloads or merges performed.** Trial simulation is purely in-memory arithmetic.

## 7. Owner sign-off recommendation (no implicit CODE permission)
Choose **Cân bằng as tentative trial**, then request a *separate* owner balance review against an actual R20 save with genuine inventory, Market price/policy, accumulated Stones, task queue, 30 hunter role assignments, and real source rates; do not overwrite current canonical economy or Code. If available data shows 1,000-person median67 modeled funding days too slow, adjust tariff or prove additional revenue, not remove mandatory Lv75. If a 3,000-person player already controls enough funds, profile shape still costs genuine materials and time rather than guaranteeing any delay.
Two subsequent docs paths: (A) verify themed Yêu Đan vs true named Lô Tâm/Hỏa Chủng catalyst sources without code; (B) independent future Forge BuildingSystem upgrade/reservation/migration CODE packet prep ONLY after explicit owner request, not during MAP-D0. A choice of the profile or a signed docs acceptance is not authorization to start a competing Codex implementation.
