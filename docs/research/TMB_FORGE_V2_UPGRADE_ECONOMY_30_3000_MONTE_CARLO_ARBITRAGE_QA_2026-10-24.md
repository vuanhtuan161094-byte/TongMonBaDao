# TÔNG MÔN BÁ ĐẠO — LUYỆN KHÍ V2: CUNG/CẦU 30–3.000, MONTE CARLO & CHỐNG ARBITRAGE
## Đính kèm cho hợp đồng năm thao tác; CHỈ SỐ ĐỀ XUẤT, CHƯA CÓ CODE

**2026-10-24 · DOCS-ONLY, SYNTHETIC RESEARCH; NO GODOT RUN/QA; NO PR29/UI/Source A/MERGE.**
Companion authoritative **proposal**: `docs/design/TMB_FORGE_V2_FIVE_UPGRADE_OPERATIONS_INVESTMENT_CONTRACT_2026-10-24.md` same branch. Sources: main `29b5fba448b0178cb520a4ada44b375b4b934e31` and previous Forge V2 docs `docs/forge-v2-transaction-blueprint-grade-salvage-inheritance-20261024`, basic 10-slot &96-set docs `docs/gear-v2-basic-rare-24sets-camp-sources-20261024`, rarity HIẾM docs `docs/ttl-v3-rare-loot-three-profiles-gear-scaling-20261024`. ALL costs, probabilities, worker lanes, time, inherited-credit rates are synthetic [PROPOSED], not current code or user-locked balance.

## 1. Real SOURCE price/stock distinction
**Actually registered in ResourceRegistry**: `linh_moc,thanh_thiet,huyen_thiet,tinh_lang_bi,yeu_dan,linh_tuy`; newer specific `ttl_*` materials NOT registered. Registry `market_value` is metadata, not automatically a trade contract. Current Economy-A NPC V2 `V2_MARKET_CATALOG` is **only** `linh_moc,thanh_thiet,thanh_linh_thao,linh_coc`; V2 `sect.spirit_stones` is separate from P2 `wallet` and `treasury`. Do not pretend can buy infinite Huyền Thiết/Yêu Đan or sell upgraded gear to NPC at invented rates.
**Canonical supply** Mine/Forest and authentic hunt kill receipts → registered Warehouse stack only, no phantom reward; rare materials from 7 new species must be authored first. Warehouse stack unbounded apart from safe integer and reserve/lock; one operation reservation journal proposed, NOT already in WarehouseSystem. Old `EquipmentSystem.craft` is P2 5 recipes and 3 qualities, not proof of V2 upgrade service.

## 2. Cost and throughput model: three combat-important slots per person to +3
**Clearly labelled experimental roster policy** (not automatic class gearing): prioritize weapon, armor, boots when actual skills/realm/role permit; 3 pieces/disciple, each from +0→+3. No fabricated gear generation; each physical item must exist and already be Sect-owned. A 30-deployed-person map is the live combat subset, 1,000–3,000 global Sect roster is the labor pool. All-troop upgrade policy is an intentionally costly counterfactual.
**Test inputs from contract**: 1 item `+1=ore2+wood1+Stone5`; `+2=ore3+wood1+Stone8`; `+3=ore4+wood2+Stone12`, all three are **100% successful for simulated valid orders**, each base8 ticks. Per item fully +3: **9 Thanh Thiết +4 Linh Mộc +25 Sect Stones +24 base ticks** and THREE orders. One worker/one running lane hypothetical, unmodified 1sim-day=1440 canonical ticks, no travel/injury/expense for producing item or input stocks.

| Total roster to enhance | Priority item count (3 each) | Enhancement order count | Thanh Thiết | Linh Mộc | Sect Stones | Serial 1-lane days | Hypothetical 4-lane days |
|---|---:|---:|---:|---:|---:|---:|---:|
|30 deployed|**90**|270|**810**|**360**|**2,250**|**1.5**|0.375|
|1,000 all|3,000|9,000|27,000|12,000|75,000|50|12.5|
|3,000 all|9,000|27,000|81,000|36,000|225,000|150|37.5|
|1,000 roster, **10% selected**|300|900|2,700|1,200|7,500|5|1.25|
|3,000 roster, **10% selected**|900|2,700|8,100|3,600|22,500|15|3.75|

These figures **exclude the cost of obtaining/crafting the original items**. In the older basic 10-slot recipe proposal, an entire neutral set of ten costs **15 Thanh Thiết+21 Linh Mộc** per disciple, so full ten-slot base + exactly three +3 items would cost, in this toy model, **42 Thanh Thiết+33 Linh Mộc+75 Sect Stones per person**. This assumes Forge runs can obtain material, and excludes wage, item repair, warehouse reservations, facility upgrades, player lock, quality, source affinity, profession worker shifts, injuries and real device limits. 4 lanes are an arithmetic scenario, **not** a built capacity or a right to force 4 workers on a Lv1 facility.
**24/168/720 sim-hour target at 1 lane**: base8 ticks/order, max `1440/8=180 orders/day` if one Forge lane works continuously; 3 orders/item,3 items/person ⇒20 eligible fully +3 persons per day; **140 per 7 days**, **600 per 30 days** with endless input/fully legal workers. At 4 hypothetical lanes those become80/560/2,400 persons under impossible full utilization. In practice these are UPPER CAPACITY bounds, not promises of ready equipment. One worker cannot keep two jobs; profession speed reduces work duration only, not reward count.
**More realistic staged policy [PROPOSED]:** tier0 full 10-slot *basic* equipment for authorized hunting front; tier1 three important pieces +3 for 30 deployed; tier2 selectively upgrade tank/DPS/healer rare gear with backup set pieces held; tier3 noncombat workers prioritize relevant craft/profession sets only when actual output consumer works. Do NOT enhance every item for all3,000 automatically; set integrity and owner locks may override score ranking.

## 3. Monte Carlo: success/failure +1→+9 when high sources eventually exist
**What was actually computed:** private JavaScript xorshift32 deterministic synthetic Bernoulli loop, initial decimal seed `20261024` and 20,000 replicates sequentially for groups of1/30/300 candidate items. Per item nine ordered enhancement successes, with trial probabilities `p(+1..3)=1.0`, `p(+4..6)=0.80`, `p(+7..9)=0.55`. Only counts *attempts*, not ore/Stone at these later steps (higher recipes/materials are NOT authored). Every failed attempt leaves item/level intact and spends an actual proposed input if later authorized.
**Exact formula:** expected attempts/item `E[N]=3×1 +3/.80 +3/.55 = 12.204545...`; expected failures/item =`3.204545`. At least three attempts are successful early, but the +7→+9 stages cannot currently run from actual content. 20,000 synthetic draws:
| Requested group size | Analytical mean attempts | Sample mean | P10 | P50 | P90 |
|---:|---:|---:|---:|---:|---:|
|1 item to +9|**12.205**|12.213|10|12|15|
|30 items to +9|**366.136**|366.047|350|366|382|
|300 items to +9|**3,661.364**|3,661.714|3,611|3,661|3,714|
**Reproducibility**: seed has single continuous RNG stream; array order group1 then30 then300, each 20,000 trials. xorshift32:
~~~text
state = signed32(20261024)
random:
    state ^= state << 13
    state ^= unsigned(state) >> 17
    state ^= state << 5
    return unsigned(state)/4294967296
for items in [1,30,300]:
  repeat 20000:
    total_attempts=0
    repeat items:
      for target_level in [1..9]:
        p = 1 if target_level<=3 else (.8 if target_level<=6 else .55)
        do total_attempts += 1 while random() >= p
    append total_attempts
  sort totals; p10/p50/p90 use floor(p*(20000-1))
~~~
**Limits:** no global +9 enhancement ceiling is set by this math. Stage7–9 require genuinely authored high-rank sources; no high-stage cost or Stone fee is invented. If P for advanced stages changes, expected attempts change; if p=0.3 for7–9 instead, expected attempts/item rises to `3+3/.8+3/.3=16.75`, 37.2% above12.205. Even p=.55 doesn't automatically create a valid high-rank item or allow grade12.

## 4. Five upgrade systems: realistic economic sinks, NOT one interchangeable rarity resource
| Action | Verified source ingredient gate | Example proposed attempt cost | OUTPUT | Cost if failed | Anti-exploit |
|---|---|---|---|---|---|
| enhance +1/+2/+3 | [SOURCE] Thanh Thiết/Linh Mộc | +1:2ore+1wood+5Stones; +2:3+1+8; +3:4+2+12 | selected item bounded approved base component | real spent attempt even if failed (all3 P100 in pilot) | unique gear ID/operation receipt, no double material |
| enhance +4..6 | [SOURCE] Huyền Thiết/Yêu Đan, but not authored recipe | exact quantities/fees UNKNOWN, P80% **toy** | additional enhancement only within allowed material/form | spend one attempted cost | no low-tier material substitution |
| enhance +7..9 | [DEFERRED] advanced tier/source recipe | no valid high-tier input amount, P55% **toy** | high stage ONLY with actual Lv75+ approved source | spend attempted cost | no forged Thần on Lv1 iron |
| refine value | [SOURCE] basic ore, actual affix consumer | `thanh_thiet×1+5 Stones` as pilot | new candidate SAME line ID | pay even if old retained | candidate frozen, no quit-reroll |
| reroll line | [SOURCE] Huyền Thiết+Yêu Đan, exact source authoring missing | `huyen_thiet×1+yeu_dan×1+12 Stones` pilot | legal new line ID from A/B/C | pay even if old retained | no Chân Văn, illegal duplicates |
| promote grade | [SOURCE] starter material; [DEFERRED] grade4+ catalyst | grade1→2:ore4+Stone15 P100; grade2→3:ore6+huyen_thiet1+Stone30 P70 | legal grade g+1 + capacity, NOT auto filled | spent fee/input, old phẩm kept | item/source cap & explicit edge required |
| promote item realm | [DEFERRED] next-realm template/material | UNKNOWN before realm1→2 and 10→11/20→21 authoring | gear realm r+1 and true base curve | charged eligible attempts only | cross-gen/sets no free swap |
| inherit | [SOURCE] donor/target physical gear; [DEFERRED] investment ledger | example70% discounted eligible paid investment + future transfer fee | donor consumed, target retained with one new version | invalid precheck costs0; successful consumes donor | no liquid credit and provenance once |

**Perceived player value:** enhancement improves combat-supportive stat actually used; refine targets a chosen affix/value; promote-grade opens additional valid line capacity and potentially higher base; promote-realm expands the item base curve for actual new enemy realm; inheritance protects some *paid enhancement* from becoming dead money when switching gear. Each has a distinct decision, material source and sink. If two systems grant the same passive power with cheap common ore, one dominates the economy and invalidates rare hunting.

## 5. No-arbitrage tests with real entity constraints
**[SOURCE]** ResourceRegistry market value `linh_moc=2`, `thanh_thiet=8`, `huyen_thiet=34`, `yeu_dan=18` (metadata; not a guaranteed liquidation rate). Economy-A NPC V2 market only trades `linh_moc,thanh_thiet,thanh_linh_thao,linh_coc` and has its own buy markup, stock and daily buy/sell limits. Unsupported item/resale/catalyst has no known cash price and MUST NOT be assigned a fictionally grounded positive Stone value.
**Concrete early input opportunity valuation ONLY (metadata, no real market guarantee):** one item to +3 consumes9 ore×8 +4 wood×2 =`80` metadata units, plus25 real proposed Sect Stone fee. In a legal sell-and-salvage system, recovering the same9 ore+4wood and full Stone fee would nullify the work sink, and if sell price exceeds input, arbitrage. Recommended **conservative component-wise rule**: salvage of a crafted/enhanced item must not return more of ANY live resource ID than genuinely paid and not previously refunded, and must NEVER reimburse paid work or Spirit Stone fee in these early pilot operations. Necessary, not sufficient if exchange/market pathways convert resources at different ratios; later check graph cycles with NPC buy/sell/spreads, fees, quest rewards and item upgrade receipts.
**Attack vectors to block**:
- craft cheap basic gear → raise phẩm with common ore → salvage to scarce new `ttl_*` material ⇒ REJECT unless actual rare materials were input and authenticated transformation recipe authorizes conversion.
- refine line → keep old → cancel operation after preview ⇒ payment remains spent, old stats preserved, candidate id/seed frozen, no free second roll.
- donor A inherited into target B 70% → B inherited into C claims 70% of A PLUS new B credit ⇒ REJECT; track original settled provenance, original cost counts once and no credit from inherited credit as fresh expense.
- two simultaneous UI buttons upgrade identical item→ two levels for one fee ⇒ reject item lock/expected_version before second reservation, same idempotency key returns same operation.
- Save after currency/resource debit before target change → no atomic rollback or replay => item loss; **mandatory** receipt+state atomicity.
- invalid cross generation 10→11 or20→21 without actual higher source, or low-rank Phàm→Chí Tôn via common materials: fail BEFORE debit.
- actual source material lock/reserve_min vs operation reservations: one Sect Warehouse, compute `allocatable=stock−user_min−all_job_reservations`, no other inventory.
- unusable 4-piece set automatically replaced by one higher-graded mismatch: protected until staged swap, same generation.
- upgrade attempt from a worker already hunting on World map violates One Active Job; never double profession XP/reward or stop current hunt silently.
- 1,000–3,000 autooperations must batch plan at MOST intended active workforce facility work lanes, and never spawn those disciples simultaneously in one hunt map.

## 6. 30 future acceptance fixtures (NOT EXECUTED)
| ID | Expected input/fault | Expected invariant |
|---|---|---|
| U01 | Duplicate `operation_id` before and after settlement | exactly same receipt once |
| U02 | Different keys targeting same `item_instance_id` concurrent | one lock winner, second rejects before stock debit |
| U03 | Donor and target same ID | reject, nothing consumed |
| U04 | unregistered new material/catalyst | fail-closed, no phantom item |
| U05 | Basic +1…+3 recipes in registered inventory | exactly specified 9ore+4wood+25Stone per completed +3 |
| U06 | Warehouse resource reserve_min and locked on normal resource | new order blocked without reducing old reservation |
| U07 | Sect Stones short after fee reserve | fail before worker/job starts, no partial debit |
| U08 | P2 wallet sufficient but Sect Stones insufficient | reject; no P2-to-V2 currency cross-substitution |
| U09 | Worker active hunting on one map | cannot work second Forge job |
| U10 | One worker becomes Injury1 mid-operation | pause with remaining ticks, auto-return/recovery120, no duplicate |
| U11 | On reload at RESERVED/RUNNING | same item/reservation/remaining work |
| U12 | Save at RESULT_FROZEN 100× | identical success/failure/affix/target version |
| U13 | Crash after material debit before item change | rollback/replay, no material-only loss |
| U14 | Crash after target state change before receipt ACK | replay returns identical, not double target level |
| U15 | Refine lower value candidate, choose keep old | cost paid, old ID/value stays |
| U16 | Refine better candidate, choose accept new | old replaced one time and same persistent item id |
| U17 | Reroll line from invalid affix channel/duplicate A/B | reject or resample deterministically from legal pool, never wrong proc |
| U18 | Try ordinary reroll on individual Chân Văn | reject, skill authority unaffected |
| U19 | Upgrade grade1→3 within eligible authored source | only correct next-edge and capacity/line limits |
| U20 | Attempt grade12→13 | reject before debit |
| U21 | Grade9–12 on starter profile with no named source | reject, no invisible ultra-low RNG |
| U22 | Upgrade item realm30→31 | reject |
| U23 | Try rank10→11 with old-world ore, no target template | reject before debit, old set intact |
| U24 | Stage new-generation 4-piece replacement | do not mix 2/3/4 across generations |
| U25 | Enhance invalid power channel tries scaling all Disciple HP | disallow, apply only authored item base component |
| U26 | Inherit paid donor→target after refines, donor equipped | policy lock/refuse unless explicit safe unequip; never clone donor |
| U27 | Inherit twice/replay target changed while same donor | once-only donor consumption and credit provenance |
| U28 | Double salvage vs inherit race on same unique gear | one wins, other rejected, material outputs once |
| U29 | Craft→enhance→salvage→market→recraft multi-cycle | no net new registered resource/Stone without source/work |
| U30 | 30 active, Sect roster1k/3k, 1/4 Forge lanes synthetic vs real | bound jobs/throughput, no 3,000 World actors, no performance PASS unless tested |

## 7. Owner approvals needed before CODE in a completely separate packet
- S1: Choose whether low +3 only pilot or different initial subset; trial2% per enhancement component must be benchmarked against HP/ATK/DEF and actual Combat V2.
- S2: Non-destructive failure consumes real materials and Sect Stones, uses one frozen result; ordinary refine keep-old still consumes cost.
- S3: Permit grade-specific promotion edges with exact material source and difficulty; forbid grade9–12 local sources until legitimate late-game content; cross10/20 generation rules explicit.
- S4: Decide on 70% inheritance as illustrative **non-tradable future cost discount**, no donor cloning; choose loss and material-specific cap with approved market value/registry rather than equating all IDs.
- S5: No numeric salvage outputs, high-stage costs or +10…cap until source+sink evidence; no one-lane/4-lane runtime claim.
- S6: Author real Forge operation serial job/reservation/one-item version/Stone-account/receipt, one writer only after separate code approval and PR29 coordination. This packet **does not authorize coding**.

**Status: RESEARCH-ONLY.** The 30 fixtures are proposed and synthetic attempts are a private model, not Godot 4.7.2 runtime, Windows/Android, CI or owner visual acceptance.
