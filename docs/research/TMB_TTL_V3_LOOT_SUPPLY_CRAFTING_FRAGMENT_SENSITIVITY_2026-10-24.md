# TÔNG MÔN BÁ ĐẠO — TTL V3 / BALANCE SENSITIVITY AND SUPPLY WORKSHEET
## 20 bãi ×300 slots, 10 species, 7 material sources, 10 equipment recipes, 6 Công Pháp transmissions, 3/10/30 đệ tử
**Ngày:** 2026-10-24. **STATUS: NUMERIC RESEARCH ONLY / SYNTHETIC, NOT GODOT BENCHMARK AND NOT APPROVED BALANCE**.
**Source & proposed probabilities:** `docs/design/TMB_TTL_V3_MONSTER_LOOT_RECIPE_GRADE_MANUAL_BALANCE_OWNER_REVIEW_2026-10-24.md` on SAME branch. Input species mix from 20-camp A docs `docs/ttl-20-camp-monster-catalog-loot-economy-v3-20261024`. No implementation, no PR29/UI/Source A edits, no Codex packet and no merge.

## 1. Do not confuse world population with kill throughput
- `P=200/300/400` = total registered **LIVE spawn slots** from 20 camps each with 10–20. It does NOT mean kills/hour, kill XP or one payout per respawn.
- `H=3/10/30` = actual independently deployed HUNT disciples in THIS ONE world, not total Sect population. Not all30 combat simultaneously; one Actor/monster has one HP/death/loot.
- `K` = number of legal completed monster kills/hour in canonical sim time. Not measured from CombatV2 yet. Need actual KillReceipt telemetry/respawn/path/AI/retreat before hard balancing.
- Exactly same Source A visual should show only actual loot receipt and legal world actors, independent of camera/LOD. Any probability applies to each **actual unique monster life** killed, not to each cast or damage tick.
- Canonical tick day: `day=floor(tick/1440)`; a “24 sim-hour” period is **1,440 sim ticks**, not 24 real-clock hours for arbitrary game speed. Benchmarks at 1x and accelerated/offline must preserve consistent sources without fake kill rewards.

## 2. Source-weighted census from the already proposed 20-camp 300-slot map
Count each species by SUM of the 20 specific camp rows; **this is a chosen example, not a runtime or canonical RNG mix**.
| Species shorthand | Exact ID | Spawn slots | Share in 300 | Main source | Proposed primary material P | Expected units/kill of THAT species |
|---|---|---:|---:|---|---:|---:|
| T | `truc_thu` | **60** |20.0%| `linh_moc` |38% ×2 |0.760|
| L | `thanh_lang` | **71** |23.67%| `tinh_lang_bi` |38% ×mean1.5 |0.570|
| H | `hac_lang` | **39** |13.00%| `yeu_dan` |20% ×1 |0.200|
| W | `ttl_thuy_vu_linh` [NEW] | **39** |13.00%| `ttl_thuy_vu_tinh` [NEW] |35% ×1 |0.350|
| WG | `ttl_thuy_tinh_giai` [NEW] | **6** |2.00%| `ttl_thuy_tinh_giap` [NEW] |30% ×1 |0.300|
| K | `ttl_kim_giap_trung` [NEW] | **28** |9.33%| `ttl_kim_giap_xac` [NEW] |40% ×1 |0.400|
| KT | `ttl_thiet_tiem_thu` [NEW] | **12** |4.00%| `ttl_thiet_tiem` [NEW] |35% ×1 |0.350|
| F | `ttl_hoa_van_lang` [NEW] | **21** |7.00%| `ttl_hoa_lang_nanh` [NEW] |35% ×1 |0.350|
| FT | `ttl_xich_viem_trung` [NEW] | **7** |2.33%| `ttl_xich_viem_xac` [NEW] |28% ×1 |0.280|
| E | `ttl_thach_bi_thu` [NEW] | **17** |5.67%| `ttl_thach_bi_giap` [NEW] |36% ×1 |0.360|
| **SUM** | | **300** |**100%**| | | **Weighted 0.46717 primary material units / normal kill** |

Formula: `E[material units per normal kill] = Σ_s [slots_s/300 × P_primary_s × E(quantity|success)] = 0.4671666667.` Does **not** include optional `thanh_thiet/huyen_thiet` extra rolls, elite/boss secondary items, manual/gear rewards, or resources produced by Mine/Forest/Field.

### Worked base example: 30 hunters, 300 full slots, 360 normal kills/sim-hour
**ASSUMPTION, NOT OBSERVATION:** the rate `360 normal kills/hour` is a synthetic stress/economy input. It is **not** justified by max 300 live monsters. Each species' killed share is *assumed proportional* to spawn count; targeted camping will change the shares, perhaps radically.
| Species | Normal kills/sim-hour | Primary material units/sim-hour | Ingredient relevant |
|---|---:|---:|---|
| Trúc Thử T |72|**54.72**| Linh Mộc |
| Thanh Lang L |85.2|**48.56**| Tinh Lang Bì |
| Hắc Lang H |46.8|**9.36**| Yêu Đan |
| Thủy Vụ W |46.8|**16.38**| Thủy Vụ Tinh |
| Thủy Tinh WG |7.2|**2.16**| Thủy Tinh Giáp |
| Kim Giáp K |33.6|**13.44**| Kim Giáp Xác |
| Thiết Tiêm KT |14.4|**5.04**| Thiết Tiêm |
| Hỏa Lang F |25.2|**8.82**| Hỏa Lang Nanh |
| Xích Viêm FT |8.4|**2.352**| Xích Viêm Xác |
| Thạch Bì E |20.4|**7.344**| Thạch Bì Giáp |
| **TOTAL** |**360**|**168.18**| excludes other sectors |

This is an idealized estimate. Enemy HP, realm, defense, element resist, walk distance, number of campers, initial stock, monster respawn, attack cooldowns, medical travel, poor camp assignment and One Active Job constraints can reduce real rates substantially. Never replace real species-kill counts with world live count. Mine10,000/Forest8,000/hour are owner proposal from previous economy study, not guaranteed current level-one sources; avoid asserting confirmed production parity without live evidence.

## 3. Recipe supply — why TWO substitutions are recommended
Ten [NEW] gear templates each crafted once use proposed total inputs:
- Registered resources: `linh_moc×8`, `thanh_thiet×5`, `thanh_linh_thao×1`, `tinh_lang_bi×4`, `yeu_dan×2`.
- New normal ingredients: `ttl_thuy_vu_tinh×5`, `ttl_thuy_tinh_giap×1`, `ttl_kim_giap_xac×4`, `ttl_thiet_tiem×3`, `ttl_hoa_lang_nanh×3`, `ttl_xich_viem_xac×1`, `ttl_thach_bi_giap×4`.
- Elite/Boss materials: `0` until registered named consumer. **No ghost relic stock**.

### Theoretical lower-bound material farming to craft one 10-item kit for EACH of 30 active disciples
Formula per material `m`: `T_m = 30×recipe_quantity_m_per_kit / E[material_m/h]`. The **largest T_m is a theoretical MATERIAL BOTTLENECK LOWER BOUND** if sources run simultaneously at stationary per-species rates. It does NOT include actual crafting time, drop variance, access to Lv30, travel/injury/idle, other sinks, routing or limits to concurrent Forge jobs.

| New material | Proposed mean units/h at synthetic 360 kills/h | OLD 10-recipe quantities/item-kit | OLD 30-kit material-hours | REVISED quantities/item-kit | REVISED 30-kit material-hours |
|---|---:|---:|---:|---:|---:|
| `ttl_thuy_vu_tinh` |16.38|3|5.5|**5**|**9.2**|
| `ttl_thuy_tinh_giap` |2.16|3|**41.7**|**1**|**13.9**|
| `ttl_kim_giap_xac` |13.44|4|8.9|4|8.9|
| `ttl_thiet_tiem` |5.04|3|**17.9**|3|**17.9**|
| `ttl_hoa_lang_nanh` |8.82|2|6.8|**3**|**10.2**|
| `ttl_xich_viem_xac` |2.352|2|**25.5**|**1**|**12.8**|
| `ttl_thach_bi_giap` |7.344|4|16.3|4|16.3|
| **Theoretical maximum bottleneck** | | |**41.7h**| |**17.9h**|

The *revised* strongest among these constraints is Thiết Tiêm ~17.9h, but true full team gear time is **not** 17.9h, because 30 disciples may need different templates/gear realm/quality, Forge Lv30/time/slots, nonuniform camp targeting, auxiliary materials, safety losses and recipe conflicts. More important, starter 10-slot **basic** availability must exist before specialty Forge Lv30, or progression softlocks while a character has empty slots.
**Trade-off:** Water bracers and Fire cloak become more attainable by requiring 1 scarce source plus more accessible second source. Their combat value must remain in real V2 stat/skill channels; rarity/quality of these templates shouldn't be covertly multiplied to “compensate” without separate authoring.

### Niche content accessibility
- If a player leaves C08/C17 without hunters or respawn is slow, supply of 2.16 WG or 2.352 FT per hour collapses. Role-based auto-hunt sourcing must match actual deficit and legal travel/risk.
- If one 30-person team focuses ALL on six Water Shell spawns and spawn timer is slow, the earlier proportional estimate overstates gains; occupancy alone does not provide infinite kill-throughput.
- A future 3/10/30-devoted-hunters benchmark should log **per-camp** kills/h and sources, since uniform-share approximation hides individual scarcity.
- Sect owns gear, so item duplicates can be assigned to other disciples; gear source variety matters more than a forced always-complete 10-piece same-template set. A 24-set item is among only its correct four positional slots; no sword+ring mixed-in as a set component.

## 4. Equipment-faucet expectation from creature mix
Normal per-species gear-event input [PROPOSED] in primary document:
| Species | Normal gear event P/kill |
|---|---:|
| T|0.15%|
| L|0.25%|
| H|0.40%|
| W|0.25%|
| WG|0.35%|
| K|0.30%|
| KT|0.35%|
| F|0.30%|
| FT|0.40%|
| E|0.35%|

`Weighted average p_normal_gear = Σ_s slots_s/300 × p_s = 0.002728333333 (0.2728333%).`
**Synthetic full-map base assumptions:** normal `K_n=360/h`, Nham Elite successful kills `K_e=3/h`, Hắc Lang Vương Boss successful kills averaged `K_b=0.25/h` (one successful Boss per four sim hours; actual event schedule NOT authorized and Boss cannot spawn 0.25 of a creature at once).
`E[gear/h] = K_n×0.0027283333 + K_e×0.04 + K_b×0.35 = 0.9822 + 0.12 + 0.0875 = 1.1897 items/h.`
`E[gear/24 sim h]=28.5528; E[gear/7 sim days]=199.8696; E[gear/30 sim days]=856.584.` These are TOTAL gear-event results irrespective of usefulness, slot, grade, set, equip legality, player storage/reserve and actual timing. **An item event is not a grade8 drop** unless eligible and its conditional quality draw succeeds. The proposed normal baseline differs from previous doc B single 0.30% for ALL normal monsters; this per-species weighted figure is a more specific, **not yet approved** replacement proposal.

### Five throughput/risk reference points at different map population
**Synthetic kill-throughput assumptions for this worksheet only:**
- each actively deployed hunter produces `12 valid normal kills/h` *at P=300*, before a density/competing-resource factor;
- illustrative density factor `d(P=200)=0.75`, `d(300)=1.0`, `d(400)=1.10`; NOT generated from a Godot 4.7.2 pathfinding/simulation benchmark;
- successful Elite kills/h `K_e=K_n/120`, an authorable event goal, not actual `HuntingMapV2.LEVELS.elite_chance`;
- successful Boss kills/h `K_b=min(0.25, 0.25×(Hunters/30)×d(P))`; 0.25/h is the proposed **map-wide event ceiling**, not 20 × per-bãi Boss chance; **5 squads may cooperatively kill the same Boss but it still pays once**;
- no real injury/miss/gear shortage/allied-loss dropout is modeled. Higher map difficulty1–5 MUST change actual kill pace and survivability, not simply multiply drops by old per-encounter `yield` factor.

| Active hunters | Living slots P | Assumed normal kills/h | Elite kills/h | Boss kills/h successful avg | Gear items/h expected | Primary normal material units/h |
|---:|---:|---:|---:|---:|---:|---:|
|3|200|27|0.225|0.0188|0.0892|12.61|
|3|300|36|0.300|0.0250|0.1190|16.82|
|3|400|39.6|0.330|0.0275|0.1309|18.50|
|10|200|90|0.750|0.0625|0.2974|42.05|
|10|300|120|1.000|0.0833|0.3966|56.06|
|10|400|132|1.100|0.0917|0.4362|61.67|
|30|200|270|2.250|0.1875|0.8923|126.14|
|30|300|360|3.000|0.2500|**1.1897**|**168.18**|
|30|400|396|3.300|**0.2500 cap**|1.2999|185.00|

This table is an invented **sensitivity surface**, not actual source gameplay or a “400 monster performance PASS.” Respawn schedules must respect actor life and map caps; the event rates are trial targets only. Boss per-hunting-hour is an average across successful encounters, not a guarantee of Boss every four wall-clock hours.

## 5. Six technique fragments — expected FIRST Sect transmission availability
Author candidate fragment→complete book thresholds: Phàm12, Huyền18, Địa28, Thiên40 (these are not P2 thresholds8/12/18/30, not V2 locks). SOURCE per-species trial rate from primary doc; at the uniform-mix **360 normal kills/h**:

| Technique family | Effective source calculation | Expected fragment events/h | Proposed fragments/book | Heuristic mean sim-hours to collect fragments, if no extra rewards |
|---|---|---:|---:|---:|
| `duong_khi_quyet` | T72 kills×2% |**1.4400**|12|**8.3h**|
| `huyen_giap_cong` | E20.4×1.2% + Elite3×8% |**0.4848**|18|**37.1h**|
| `liet_chien_quyet` | F25.2×1.8% |**0.4536**|18|**39.7h**|
| `thanh_phong_kiem_quyet` | K33.6×1% +KT14.4×1% |**0.4800**|28|**58.3h**|
| `xich_viem_chan_quyet` | F25.2×1.5%+FT8.4×1.5% |**0.5040**|28|**55.6h**|
| `han_nguyet_tam_phap` | W46.8×0.8%+WG7.2×1% |**0.4464**|40|**89.6h**|

**Special note:** `huyen_giap_cong` also has *proposed* direct Elite full-book chance0.25% per actual Nham Giáp Thú kill; `3×.0025=.0075 book/h`; mean waiting time for a direct book alone ~133.3h. Fragment and direct-book paths compete: **don't add 37.1+133.3 or say first copy guaranteed within37.1h**. More concentrated hunting changes rates; if one elite misses, or new species are unavailable, time lengthens drastically. The 3/h Elite synthetic rate is not a source fact.
- Each first complete book is archived permanently at Sect Tàng Kinh Các; duplicates follow an **authored** Nghiên Tu sink, not repeated unlock or guaranteed skills for30 hunters. This tends to be a **one-time milestone** economy; fragment faucet must have a post-archive purpose or a sensible explicit stop/convert option, else 30-day warehouse clutter.
- A normalized high-grade `han_nguyet_tam_phap` may be deliberately slower than intro manuals in an opening map; if player wants it accessible sooner, alternative quest/Elite/Bí Cảnh source must be authored, not invisible boost to all Thủy monster drops.
- Boss Hắc Lang Vương remains U Minh, NOT an automatic Fire/Water book source to fill a blank table. Six V2 manual IDs and six fragment IDs are **not** in ResourceRegistry; dedicated transmission/unique-item schema and owner-approved learning cost/prerequisites are still required.

## 6. Deterministic synthetic Monte Carlo for total GEAR events only
**What was simulated:** 5,000 independent hypothetical trials per horizon of **24, 168 and 720 canonical sim-hours**. Each sim-hour gear arrival is **Poisson(λ=1.1897)** by Knuth inversion loop. The sample mean and empirical distribution were computed with xorshift32 PRNG **seed 2,401,024**. Stated seed is decimal (not date format). This is a **synthetic event-count model** holding kill throughput constant, not stochastic Godot monster movement, real drop RNG, actual item grades, melee DPS or saved loot.
**Repro outline (deterministic when this PRNG/rounding is held constant):**
~~~text
seed = signed_32(2401024)
rand():
  seed ^= seed << 13; seed ^= logical_unsigned(seed) >> 17; seed ^= seed << 5
  return unsigned_32(seed) / 2**32
draw_poisson(lambda):
  k = 0; p = 1; threshold = exp(-lambda)
  do k += 1; p *= rand() while p > threshold
  return k - 1
for horizon in [24,168,720]:
  for trial in 1..5000:
    total = sum(draw_poisson(1.1897) for every 1 sim-hour)
  sort totals; p05=index floor(.05*(5000-1)); median=floor(.5*(5000-1)); p95=floor(.95*(5000-1))
~~~

| Synthetic horizon | Expected gear count analytically | Monte Carlo p05 | p50 | p95 | Sample mean |
|---|---:|---:|---:|---:|---:|
|24 simulated hours|28.55|**20**|**28**|**38**|28.62|
|168h /7 sim-days|199.87|**177**|**200**|**224**|200.01|
|720h /30 sim-days|856.58|**807**|**856**|**904**|856.12|

**Interpretation:** 30 days @ this assumed perfect continuous rate would create around **857 new unique gear EVENT outcomes** for 30 active disciples, much more than their 300 ordinary equipped slots, but many duplicates/unusable/off-role grades mean NO guarantee that everybody will be well-geared. Need true Forge sinks, replacement/salvage, family-aware allocation, shop/market as authorized; 1,000–3,000 Sect roster still has separate demand. It's an upper scenario with no downtime/health recovery. The synthetic Poisson assumption ignores event-driven Boss cadence and correlation; it is for order-of-magnitude sensitivity, NOT a verified probabilistic prediction of gameplay.

### Break-even sensitivity examples
- Doubling all normal gear probabilities would make normal gear contribution `0.9822→1.9644/h` and total `1.1897→2.1719/h` if Elite/Boss unchanged. A small percent-looking change leads ~83% more total gear supply, not necessarily 2× total.
- Halving real normal kills only while Elite/Boss remain unchanged gives `0.4911+0.12+0.0875=0.6986 gear/h`. Halving **all successful kills** yields `1.1897/2≈0.59485 gear/h` under direct linear scaling, but real Boss event cap/kill success breaks exact proportionality.
- Targeted FT/WG camp farming can temporarily raise their observed material output vs `2` global proportional share; it requires the map/respawn to actually support the increased kill rate and safe return. Reward model cannot manufacture a shortage resource without a valid death.
- If boss+Elite events do not occur (event cadence not built), keep `K_e=K_b=0` and the base material/gear line falls to **normal gear0.9822/h**, fragments `huyen_giap_cong` down from0.4848 to0.2448/h, expected fragments18/(0.2448)=**73.5h**. Reveals source dependency, not a promised content availability.

## 7. Canonical conflict / abuse checks that can BLOCK approval
| Concern | Source condition | Recommendation / owner gate |
|---|---|---|
| Per-encounter vs per-monster | `HuntingMapV2.LEVELS` yields materials/rare odds for **victory once**; `LINH_TUY_GUARANTEE_WINS=4` counts victories | new per-life loot data must NEVER also trigger `forge_loot_for_victory` / finite rewards on that same kill; no 4-kill Linh Tủy |
| Missing new items | 7 new species, 9 proposed resources, 10 V2 item templates and 6 V2 manual books are not registered | fail closed, no in-game item before registered definition and actual consumer; 2 relics deferred |
| Lv1 10 gear slots vs Lv30 Forge | V2 permits equip all ten from early game, Forge roadmap Lv30 monster-material forge | provide early basic item sourcing in every slot; Lv30 specialist recipes are NOT the only way to fill early slots |
| Five map difficulties | `selected_level(region_id)` per-map and original elite/boss rolls per finite battle | keep one chosen map level and independently authored monster realm, event schedule/loot denominator separate |
| Body breakthrough drops | `ResourceRegistry` includes high-tier body/seal materials | early Trúc Thử cannot yield Tiên/Thần gate components just because registered |
| Spirit stones/Tu Vi | P3.7 direction allows sourced reward, Combat and B3 rule protect XP | do not add unconditional kill XP/Stone rates until explicit source/participant policy and true account ledger |
| Forging steps | Equipment forge/upgrade probabilities, facility/profession effect and enhancement remain OPEN | trial Lv1 vs Lv30 times/quality choices cannot be labeled V2 locked |
| Chân Văn/set procs | V2 Chí Tôn capacity one, sets stat based | no trigger spell or Chân Văn inscribed from grade12 or set4 bonus |
| Alchemy conflict | actual recipe3 Thanh Linh Thảo; owner newer2 Thanh Linh Thảo+1 Linh Cốc/6 ticks | flag separate code reconciliation; don't build wrong herb-cost economy |
| DEV reset vs active Save | old DEV saves may be regenerated after future code change per owner | still test pending kill result, immutable seed, Warehouse exactly once on save/load of same build |
| AI/Android perf | 30 disciples, 200–400 live mobs, 600 stress only | do not call profile PASS until real Godot4.7.2/Android p95 tick/frame/path/receipt results |

## 8. Smallest future evidence set — DOCS ONLY, NOT A CODEX PACKET
1. When later authorized, a developer can instrument one real 15-monster camp, record species/own realm/floor, actual kills/h, mob aggression and respawn; compare to assumed12 kill/h/disciple.
2. Validate ResourceRegistry additions and unique item template and Source A visual before allowing each V3 loot source; no placeholders.
3. One true kill with two attackers and late DoT/arrow → one life ID/receipt and one frozen reward decision. Boss 5 parties → one pool/role contributions; exact Stone split not yet locked.
4. Store/reload after death before roll, after roll before Warehouse, after Warehouse before ACK, during respawn; same outcome, no free reroll.
5. Check each of ten forge recipes against legal ingredients, profession, milestone, ticks and actual atomic warehouse reservation; synthetic throughput must not override real Forge queue.
6. Measure 3/10/30 hunters at200/300/400 live mobs for1/7/30 sim-days, with 30-slot actual team and longer 1,000–3,000 Sect cohorts. Capture real per-camp kill rates, materials by ID, grade/slot, fragment completions, unique items/gear storage, source/sink flow, lost time due Injury/movement, real runtime 8GB Windows+Android landscape1280×720.

**Owner approval requested, not taken:** use chosen per-species rates and two ingredient substitutions **as balance experiment**, confirm six transmission fragment bands12/18/28/40, the five-horizon example, and decide whether to prioritize content add or one-camp live-data measuring later. All new probabilities/table prices remain PROPOSED, no code/PR/UI changes.
