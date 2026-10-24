# TÔNG MÔN BÁ ĐẠO — LUYỆN KHÍ V2: KIỂM TRA CUNG/CẦU, BẢN VẼ 96 MÓN, MÔ PHỎNG PHẨM VÀ EXACTLY-ONCE
## Bảng review để OWNER chọn cơ chế trước khi cấp quyền CODE riêng

**Ngày:** 2026-10-24. **STATUS: DOCS-ONLY SOURCE/NUMERICAL RESEARCH. ALL NEW NUMBERS PROPOSED. NO GODOT QA EXECUTED.** Không code/packet Codex, PR29/UI/Source A/merge.
**Companion:** `docs/design/TMB_FORGE_V2_END_TO_END_ORDER_STATE_BLUEPRINT_GRADE_TRANSACTION_CONTRACT_2026-10-24.md`. **Source of exact 96 names/source proposal:** `docs/design/TMB_EQUIPMENT_V2_24_SETS_96_PIECES_TTL_SOURCE_MATRIX_2026-10-24.md` on `docs/gear-v2-basic-rare-24sets-camp-sources-20261024`. Source of ten Lv1 starter inputs: `docs/design/TMB_EQUIPMENT_V2_BASIC_10_SLOT_FORGE_RARE_CHASE_30_TO_3000_2026-10-24.md` same branch. Main `29b5fba448b0178cb520a4ada44b375b4b934e31`.
**Legend:** [CANON] approved system identity; [CODE] implementation actually in current main; [PROPOSED] data/content/recipe/percentage/queue design; [DEFERRED] missing source/consumer; [SIM] mathematically computed under explicitly invented throughput; [QA-PENDING] conceptual fixture, not executed.

## 1. Source-side readiness ledger: ALL canonical 24 families without manufacturing 96 working recipes
Canonical `docs/EQUIPMENT_SETS_V2_SPEC.md` names/positions are authoritative and are NOT changed by this packet. Earlier approved-in-principle 96-source matrix was recounted mechanically from each row:
| Readiness group of previous source proposal | Number of canonical individual pieces | Meaning for this Forge design |
|---|---:|---|
| Proposed `F30` | **46** | piece-specific authoring at Lv30 after real monster material + blueprint + worker/facility + template registry |
| Proposed `F75` | **22** | advanced authoring at Lv75; NOT automatic Grade8 eligibility |
| Proposed `ELITE` Nham Giáp Thú | **3** | candidate direct drop; no guaranteed blueprint or piece, and no cloned elite reward |
| Proposed `BOSS` Hắc Lang Vương | **1** | candidate single Boss source; exact template-conditioned chance unknown |
| `FUTURE/DEFERRED` | **24** | no legal first-map source/consumer, never F30 fake material |
| **TOTAL** | **96** | 18 combat+6 profession; 24 lineages×4 each |

### 1.1 All 24 families; exactly one source maturity interpretation each
| Canonical set family | Realm/role focus | Existing piece source proposal by route | Proposed eligibility |
|---|---|---|---|
| Sát Tinh | Kiếm crit skills | 4 F75 | Advanced, item/line consumer required |
| Phá Cương | Kiếm/Thể xuyên phòng | 3 F30 +1 Elite | Low-level partial craft, one Elite-specific piece |
| Huyết Chiến | Thể low-HP | 4 F75 | Advanced; actual low-HP channel |
| Truy Phong | Kiếm mobility | 4 F30 | Low rank, requires real movement skill bonus channel |
| Thiên Kích | Basic hits | 4 F30 | Low rank, no auto additional strike |
| Trấn Yêu | Boss hunter | 2 F75 +1 Elite +1 Boss | Higher-risk set, one shared Boss source |
| Hộ Sơn | Thể defense | 3 F30 +1 Elite | Low-rank partial craft, Elite bracers source |
| Tịnh Thần | debuff resist | 4 F75 | Advanced |
| Thiên Trận | real group shields | 4 F75 | Advanced consumer-gated |
| Phản Kiếm | defensive learned Sword skills | 4 F30 | Low-rank source, no free counter skill |
| Huyết Liệp | wolf/HP-low target | 4 F30 | Low-rank |
| Thanh Linh | Y Đạo healing | 4 F30 | Real heal/shield consumer only |
| Ngũ Hành | real elemental skills | 4 F30 | Needs multiple camps and legal tagged skills |
| Hàn Vân | Water/ice effect | 4 F75 | Ice status must actually exist, else bonus deferred |
| Cửu Lôi | Lightning skills | 4 DEFERRED | No first-map Lightning-source/consumer |
| Thực Cốt | authored DoT | 4 DEFERRED | No approved first-map set source/consumer |
| Huyền Ấn | named debuff | 4 DEFERRED | No approved set source |
| Hỗn Độn | THẦN-only | 4 DEFERRED | item realm21–30 not first-map realm1/2 |
| Thiên Công | Luyện Khí profession | 4 F30 | work_speed/profession_xp real consumer only |
| Đan Tâm | Luyện Đan profession | 4 F30 | producer actual worker |
| Mộc Linh | Linh Thực | 4 F30 | producer actual worker |
| Địa Mạch | Khai Khoáng | 4 F30 | producer actual worker |
| Phù Văn | Phù worker | 4 DEFERRED | actual Phù work consumer deferred |
| Thiên Cơ | Trận Pháp worker | 4 DEFERRED | formation work consumer deferred |

**Critical distinction:** This table **does not mean** full 12 set families become craftable at Lv30; Phá Cương and Hộ Sơn need one Elite-specific candidate piece. Nor does a listed F75 mean a Lv75 building has an actual recipe registered. Every row in previous 96-piece document already retains canonical **piece name, exact slot, proposed camp/source and new candidate template ID** and MUST be consulted to author a specific recipe. Do NOT regenerate 96 generic set names with invented slots.
**Blueprint policy proposed:** first full `blueprint_v2:set:<lineage_id>:<slot>` Sect archive unlocks recipe for repeated item creation; blueprint acquisition source comes from that **piece's exact camp/elite/boss**, no generic all-24-token exchange; no blueprint currently exists in ResourceRegistry. Boss source no last-hit ownership and no multiplicative reward to all squads. A blueprint can have rarity separate from material, but probability can be coded ONLY after per-item source pool, species, tier, event and consumer approved. Hỗn Độn cannot become Nhân item by discarding the realm gate.

## 2. TEN Lv1 ordinary recipes and their aggregate real-registered costs
All ten `gear_v2:basic_<slot>` candidate outputs and their full input dictionary are in `TMB_EQUIPMENT_V2_BASIC_10_SLOT_FORGE_RARE_CHASE_30_TO_3000_2026-10-24.md`. They use only real `ResourceRegistry` IDs `thanh_thiet` and `linh_moc`. Proposed item templates and Forge recipes do not yet exist. For ONE valid neutral Grade1+ outfitting all 10 slots, totals are:
**15 Thanh Thiết +21 Linh Mộc =10 unique objects**, and at [PROPOSED] base `12 ticks` per order (actual effective duration depends on profession work speed, facility and approved job model).
| Roster scenario | Needed items if ALL 10 slots newly filled | Total ore [SIM 15/person] | Total wood [SIM 21/person] | Minimum serial work ticks [SIM 12/item] |
|---|---:|---:|---:|---:|
| 30 deployed at Thanh Trúc Lâm |300|450|630|3,600|
| 1,000 Sect roster |10,000|15,000|21,000|120,000|
| 3,000 Sect roster |30,000|45,000|63,000|360,000|

These calculations presume every disciple needs ten fresh items and their weapon variant follows same ingredient profile; replacements/hand-me-downs lower demand. NOT all Sect members must be combat-equipped. Authoritative World Combat allows30 deployed on ONE map, not simultaneous 3,000 actors.
**[SIM] Assume 1440 ticks/day, 1 worker serving 1 serial Forge lane, uninterrupted job duration12 ticks per base item, no material shortage, no moves/injury/changes/queue gaps.**
| People outfitted | ONE hypothetical Forge lane | TWO lanes hypothetical | FOUR lanes hypothetical |
|---|---:|---:|---:|
|30|**2.50 days**|1.25 days|0.625 days|
|1,000|**83.33 days**|41.67 days|20.83 days|
|3,000|**250 days**|125 days|62.50 days|
**Worker slots != capacity to run that number of independent queues automatically.** Building Tree Lv1 craft buildings default two worker slots, but actual Forge worker→job lane authority is unimplemented. Two/four lanes are scenario quantities, not features. Canonical profession and facility modifiers can shorten duration **without increasing item count**; wage, material production/competition and workplace travel extend or constrain throughput. Compare real Mine/Forest actual output after deployed gameplay rather than assuming infinite `thanh_thiet/linh_moc`. Official loading on 8GB Windows / Android and 1k–3k roster pending.

## 3. Three Forge grade sampling pools tested under reproducible synthetic RNG
The separate baseline HIẾM from hunting changes `P(item event from monster death)` only; actual Forge chance must have its OWN authored recipe pool. Proposed first quality test:
| Pool | Quality grade weights (each row sums 100%) | Source legality |
|---|---|---|
| `F1_BASIC` | Phàm85%, Tinh13%, Thượng2% | normal item realm1, no set |
| `F30_MONSTER` | Phàm55%, Tinh25%, Thượng12%, Cực6%, Linh2% | actual Lv30, real monster materials and item-specific blueprint |
| `F75_ADVANCED` | Tinh40%, Thượng28%, Cực17%, Linh9%, Huyền4%, Địa1.5%, Thiên0.5% | actual Lv75 PLUS eligible source/realm/material, cannot upgrade starter to grade8 for free |
| Grade9..12 | **NO VALID EARLY REGIONAL SOURCE/TABLE** | May be authored high-rank/exceptional in a later owner-approved chapter; the global 12-grade structure remains |

**Deterministic synthetic experiment only:** xorshift32 seed decimal `20261024`, convert random uint32 to [0,1), sequentially draw `N=10000` items per pool order F1→F30→F75 with cumulative grade weights, nearest first cumulative bucket. JavaScript signed xor + unsigned shift:
~~~text
state = signed32(20261024)
random():
  state = xor(state, state << 13)
  state = xor(state, unsigned(state) >> 17)
  state = xor(state, state << 5)
  return unsigned(state) / 4294967296
for pool in [F1_BASIC,F30_MONSTER,F75_ADVANCED]:
  repeat 10000: cumulative_draw(pool, random())
~~~
**Raw generated counts [SIM], not item instances or source gameplay:**
| Pool | Observed grade counts (ascending grade order) | Total | Forbidden higher grades |
|---|---|---:|---|
| F1_BASIC | grade1=8478, grade2=1311, grade3=211 |10000|grade4–12=0|
| F30_MONSTER | grade1=5541, grade2=2504, grade3=1191, grade4=565, grade5=199 |10000|grade6–12=0|
| F75_ADVANCED | grade2=4132, grade3=2798, grade4=1582, grade5=903, grade6=390, grade7=145, grade8=50 |10000|grade1/grade9–12=0|
Do NOT claim F75 0.5% Thiên universally; author-specific grade8 source and viable affix/realm must exist before eligible pool is enabled. **Every valid Forge attempt in proposed deterministic creation model produces one item**; "desired grade failed" just yields a lower legally graded item. A failed upgrade to an EXISTING item later is an independent owner's unapproved recipe; default proposed non-destructive keep-quality rule cannot silently change enhancement cap or tier logic.
**Balance insight:** 10,000 F30 accepted operations under these weights create ~200 grade5 items in expectation, but only if real materials and operational capacity can actually complete 10,000 F30 jobs. These are not free gear from 10,000 simulated RNG calls.

## 4. Work/quality, material faucets/sinks and anti-arbitrage
- Profession formula is [LOCK] `Level=floor(sqrt(XP/24))` and throughput `1+.01×Level`. `work_speed` generic modifiers and actual facility factor affect duration, not output count. Profession talent Grade1–5 mostly XP bonus; Trait V2 not a generic numeric grade table. `Cơ Duyên` influences approved rare Luck Score checks, no unconstrained +% to every item grade.
- Valid Forge recipe snapshots time and inputs; user reserved stock applies once; actual `warehouse_rules.reserve_min` is NOT identical to a job reservation. Creating 1 new item consumes registered ingredients once. Never mint crafting profession XP at order submission, animation frame or duplicate ACK. Productive work must have a genuine worker/One Active Job.
- V2 base items [PROPOSED] consume high-volume Mine/Forest resources; rare monster materials with new IDs must first be registered and successfully looted under SOURCE. For specialized fire cloak [PROPOSED unchanged]: `ttl_xich_viem_xac×1+ttl_hoa_lang_nanh×1+linh_moc×2`; for Water bracers: `ttl_thuy_tinh_giap×1+ttl_thuy_vu_tinh×2+tinh_lang_bi×1`. Both scarce species' dependencies must be reachable. No new general "gear power" currency or dynamic buying all set pieces from a fake Forge menu.
- **Check craft→salvage→craft cycle at all accepted efficiencies.** Let inputs value `V_in` from real market/source opportunity, work cost `V_work`, salvage output `V_out`. Require `V_out ≤ V_in` strictly after fee/rounding whenever same item can be crafted again; include vendor buy/sell spread, reserve resources, promotions and profession efficiency. Existing source prices for new materials undefined, so NO balance-ready salvage recipe now. A per-item "25%" formula might yield 0, so no promised refund.
- **Inherit→salvage duplication:** both donor and recipient lock, donor destroyed exactly once at inheritance receipt; item grade/realm generation and Chân Văn cannot propagate as a cloned second independent instance. Locked 24-set pieces require user explicit release policy for full-threshold break. No automatic destroying 2/3/4 set for one-point improvement.
- Warehouse stacks logically unbounded except integer safe limits; Source A effects/camera never own crafting, RNG, selection or loot. 5 existing hunting map difficulties and baseline HIẾM are DIFFERENT axes; do not multiply monster rarity and Forge chance as if one difficulty switch.

## 5. Twenty-five concrete future QA fixtures — no runtime tests have been executed
| ID | Test input/fault | Expected authoritative behavior |
|---|---|---|
| F01 | Submit valid basic `weapon` selected sword or legal staff variant | exact template/slot/weapon gate; item instance accepted, not random other slot |
| F02 | Try legacy `talisman` as V2 `pendant` | reject; no obsolete slot accepted |
| F03 | Submit same idempotency key twice, before first due tick | one Forge order/reservation, same order ID returned |
| F04 | Two workers reserve more `thanh_thiet` than allowed stock−user reserve_min | second reject, first unchanged; no negative stock |
| F05 | Resource lock turns on between validation and reserve | accepted only if reservation at one atomic point; otherwise reject |
| F06 | User changes reserve minimum after A was accepted | existing A remains reserved; B sees true lower availability |
| F07 | Unknown `ttl_*` item material not registered yet | fail closed; no placeholder item or work XP |
| F08 | `blueprint_v2:set:*` missing / wrong lineage / wrong slot | reject before reserve/debit |
| F09 | F30 recipe attempted at Forge Lv1 | no start; no 96-piece phantom gear |
| F10 | F75 recipe attempted Lv75 without advanced source/material | reject or inactive; no grade8 free |
| F11 | One worker manually assigned to another active job mid Forge | correct One Active Job authority, pause/reassign policy without duplicate work |
| F12 | Worker Injury1, recover after120 ticks; resume same job | remaining ticks durable, no second item or XP |
| F13 | Save at RESERVED before first progress | same reservation/job after load, stock not lost |
| F14 | Save RUNNING mid-tick and offline time advance across due tick | exactly one eventual completion at canonical due, no wall-time exploit |
| F15 | Save at RESULT_FROZEN then 100 reloads | identical grade, affixes, instance ID and recipe version |
| F16 | Crash after resource debit before unique item/receipt | atomic rollback or redo from prepare, never material-only loss |
| F17 | Crash after unique item insert before ACK | item remains ONE, retry returns same receipt, no duplicate input charge |
| F18 | Double claim completion from UI/auto and queued callback | no duplicate settlement, profession EXP or item |
| F19 | Cancel RUNNING before grade frozen | return reservation exactly once, no gear or EXP, cannot peek grade |
| F20 | Cancel once RESULT_FROZEN | refuse; must complete same frozen outcome |
| F21 | F1/F30/F75 10,000 seeded rolls | distribution approximate weights, all outputs within legal grade, no grade9–12 without explicit source |
| F22 | Grade12 dedicated synthetic item + illegal affix/Chân Văn prefill | max6+2+1, one Chân Văn slot EMPTY, illegal proc/duplicate affix rejected |
| F23 | Equip canonical set 3+3, then one wrong-generation piece | apply appropriate2/3 thresholds by lineage/generation; protect valid set on reassignment |
| F24 | Double salvage one unique item / salvage locked piece | once-or-reject; no material/gear duplication, correct saved receipt |
| F25 | Inherit donor→target then crash/retry | donor remains consumed ONCE, target same ID versioned, no two investment copies |

**Additional QA debt, not executed:** 30 disciples hunting map 20 camps200/300/400 monsters, 1,000/3,000 overall Sect supply and queue/autoequip, Android landscape1280×720, 8GB Windows, official Godot4.7.2 focused/cumulative gates and owner visual QA. No claims of PASS. This is NOT a Codex implementation packet and should not be used as direct authorization to code.

## 6. Owner review options that must stay separate
**O1 — standard-order failure:** use no-destructive, one guaranteed lawful output per validated Forge job, low-grade variance rather than "destroy materials with nothing". Cancel pre-freeze returns material reservations; post-freeze cannot cancel. If owner wishes partial-loss high-end crafting, defer separate explicit mechanic.
**O2 — blueprint semantics:** first complete piece-blueprint sect archive permanently unlocks piece-specific Forge recipe versus expend-one-copy-per-item; recommend archive for 30–3,000 scale. Item materials remain consumed each craft. No invented general set token or extra drop roll.
**O3 — grade vectors:** F1(85/13/2), F30(55/25/12/6/2), F75(40/28/17/9/4/1.5/.5 across grades2–8) as TEST PROFILE only, and future grade9–12 source/realm profiles not authored.
**O4 — Lv30/Lv75 source gating:** strict piece-source matrix from prior 96 rows (46/22/3/1/24) and only real registered materials/blueprints; owner approves named source/family when item consumers exist. Hỗn Độn Thần-only.
**O5 — salvage/inheritance:** require separate fixed-price, no arbitrage and ownership-compatible transaction design. For now protect rare items and do not automatically salvage; inheritance donor consumption recommended, numeric carry-over remains OPEN.
**O6 — queue/profession:** worker slots do not automatically equal parallel queues; must identify capacity by real facility and One Active Job, test own worker time/cancel/Injury and offline receipt. All numeric ticks and work efficiencies are not locked.

**Status after this packet:** Two Markdown design/research artifacts are proposed for review, no canonical numeric authorization, no Godot implementation or tests. Need separate owner approval before coding, do not touch PR29/overlapping simulation writers.
