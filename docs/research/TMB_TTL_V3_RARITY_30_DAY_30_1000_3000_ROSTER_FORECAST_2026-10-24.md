# TÔNG MÔN BÁ ĐẠO — LOOT HIẾM V3: 24H / 7 NGÀY / 30 NGÀY VÀ NHU CẦU 30 / 1.000 / 3.000 ĐỆ TỬ
## Dữ liệu tính, các phân vị, 10-slot coverage, 24 bộ 4 món, Công Pháp first book — nghiên cứu tổng lượng và độ phù hợp
**Ngày:** 2026-10-24 · **SYNTHETIC MODEL ONLY**; neither official Godot 4.7.2 gameplay test nor real Android benchmark. All probabilistic inputs unapproved. No gameplay code, UI, PR29/Source A, merge, Codex packet.
**Primary contract:** `docs/design/TMB_TTL_V3_THREE_RARITY_PROFILES_EQUIPMENT_MANUAL_GRADE_OWNER_CONTRACT_2026-10-24.md` same docs branch. Sources: previous accepted 20 camps/300-slot distribution and parent scenario `docs/research/TMB_TTL_V3_LOOT_SUPPLY_CRAFTING_FRAGMENT_SENSITIVITY_2026-10-24.md` branch `docs/ttl-v3-loot-recipe-eligibility-balance-20261024`. Source data from actual ResourceRegistry/Equipment V2/Technique V2 specs vs proposed exact odds are explicitly distinguished below.

## 1. Dimensions and scenario inputs
- [OWNER DESIGN INTENT] One large Thanh Trúc Lâm map =20 camps, each10–20 monsters at filled capacity, 30 deployed disciples and 200–400 living monsters, including Kim/Mộc/Thủy/Hỏa/Thổ plus existing Nether U Minh; monster realm is independently authored. A tông môn of1,000–3,000 is the GLOBAL roster, **NOT** a player putting1,000–3,000 actors onto a 30-cap hunting map.
- [SOURCE-CONSISTENT] 10 canonical ordinary equipment slots per disciple = **300 slot demands for30**, **10,000 for1,000**, **30,000 for3,000**. Separately 24 lineage sets have FOUR authored distinct positions, 2/3/4 piece bonuses; full 10-slot equipment coverage **is not** a completed canonical 4-piece set.
- [PROPOSED MAP MIX] 300 live normal slots: T60 Trúc Thử, L71 Thanh Lang, H39 Hắc Lang, W39 Thủy Vụ Linh, WG6 Thủy Tinh Giải, K28 Kim Giáp Trùng, KT12 Thiết Tiêm Thú, F21 Hỏa Văn Lang, FT7 Xích Viêm Trùng, E17 Thạch Bì Thú. Exactly SUM300. Four of those source families are not implemented; no gameplay claim.
- [SYNTHETIC INPUT ONLY] at **30 active HUNT disciples +300 filled monster slots** assume **360 NORMAL monster kills per canonical simulation hour**, 3 Nham Giáp Thú Elite successful kills/hour, 0.25 Hắc Lang Vương Boss successful kills/hour averaged (=1 successful Boss every4 sim-hours in a hypothetically continuous authored map EVENT cycle). There is **no world Boss scheduler built** and no evidence these rates are achievable. No injury, medicine travel, Forge worker scheduling, long respawn, failed Boss or time spent selecting camp. Constant rate across30 days is a deliberately optimistic stress test.
- Source rarity baseline species gear probabilities previous doc: T.15%, L.25%, H.4%, W.25%, WG.35%, K.3%, KT.35%, F.3%, FT.4%, E.35%, weighted by the above relative source share. `Pnormal_prev=(60×.0015+71×.0025+39×.004+39×.0025+6×.0035+28×.003+12×.0035+21×.003+7×.004+17×.0035)/300=0.0027283333333.`
- Parent previous expected gear/h =`360×0.0027283333333+3×.04+.25×.35 =1.1897`. New three alternative profiles uniformly scale equipment events0.5/0.25/0.1 by source but also make higher grades rarer via **conditional grade vectors** in primary doc. Neither “400 monsters” nor “30 disciples” directly defines actual killed/hour.
- Normal species distribution among kills assumed same as full populated slots for this worksheet; targeted hunts or rarecamp bottlenecks alter distribution. A famous named set drop chance is NOT AUTHORED and cannot be estimated by assuming all24 sets are equivalent.

## 2. Expected GEAR-EVENT output by profile (not necessarily useful)
| Rarity trial | Normal gear/h | Elite gear/h | Boss gear/h | Total gear/h | 24 simulated hours |168h (7sim days)|720h (30sim days) |
|---|---:|---:|---:|---:|---:|---:|---:|
| PARENT old proposal |.9822|.1200|.0875|**1.18970**|28.55|199.87|856.58|
| **THƯỜNG** |.4911|.0600|.04375|**.594850**|**14.28**|**99.93**|**428.29**|
| **HIẾM** |.24555|.0300|.021875|**.297425**|**7.14**|**49.97**|**214.15**|
| **RẤT HIẾM** |.09822|.0120|.00875|**.118970**|**2.86**|**19.99**|**85.66**|
**Units:** item **event counts**, not guaranteed suitable items, useful 4-piece sets, 12th grade or unbounded live entity count. A simulated day =1440 ticks in current owner time/care model; 24/168/720 simulated hours denote corresponding synthetic canonical durations, NOT constant real-time play after time speed/offline controls. The model is not exact world tick execution.

### 2.1 Synthetic distribution of total gear event counts across 24h / 7d / 30d
Monte Carlo: **30,000** draws per profile/horizon, NumPy PCG64 `default_rng(20261025)`, separate Poisson draws `N~Poisson(lambda=hours×expected_total_gear_per_hour)`. Because Boss event frequency and target hunting cause dependencies, Poisson is a **deliberate forecast approximation** only, not an exact per-spawn process.
| Profile | Horizon | Analytic E[gear] | Monte Carlo P10 | Median P50 | P90 |
|---|---|---:|---:|---:|---:|
| Thường | 24h |14.28|10|14|19|
| Thường | 168h |99.93|87|100|113|
| Thường |720h|428.29|402|428|455|
| Hiếm |24h|7.14|4|7|11|
| Hiếm |168h|49.97|41|50|59|
| Hiếm |720h|214.15|195|214|233|
| Rất Hiếm |24h|2.86|1|3|5|
| Rất Hiếm |168h|19.99|14|20|26|
| Rất Hiếm |720h|85.66|74|85|97|
There is NO guarantee of any usable grade7+ or four-piece set because source band and grade selection are separate. With R1 normal most grade drops are low 1/2; 9–12 are **not in any currently authored TTL source pool** in all three scenarios.

## 3. “Có đồ” ≠ “đồ đúng build” ≠ “đồ bộ”
**Hypothetical fit gate, NOT canon:** of all unique equipment item events, assume a fixed `q=0.40` turn out valid for the roster's **target tier, role/path, minimum desired quality and item applicability**. Among these usable items assume the **ten ordinary slots are evenly likely** and that Sect Warehouse intelligently assigns each accepted item to a not-yet-filled slot on one of the active disciples. This is optimistic — a real source pool has uneven slots, repeated same-set items, missing templates, different Tu Vi/Body eligibility, combat stats, 24 set lineages and acquisition costs. No extra imaginary conversion from the other60%; rejects remain existing valuable/low-grade spare gear, can later be equipped elsewhere/forged or salvaged only when authorized.
- **Raw one “useful 10-slot outfit” for a SINGLE chosen disciple:** waiting for at least one usable item in each of ten slots is an approximate coupon collector with Poisson-thinned arrivals `q/10` per slot; expected raw gear events ~`(10/q)×H_10 =25×2.928968≈73.22`. This assumes one designated build and dedicated allocation, NOT ten matching gear items magically appearing.
- **All30 disciples have some compatible gear in all ten slots:** need at least30 usable items of EACH slot. Approximate Poissonization: each of ten slots has arrival intensity `q/10` per raw event, and time-to-30 in each slot ~ Gamma(shape30, scale10/q). Take maximum among ten; **25,000 synthetic Gamma ten-slot realizations, NumPy PCG64 default_rng(20261024)**. Median raw events approximately **964**, expected ~974, P10 ~859, P90 ~1100. This is a **model of matched ordinary-slot coverage ONLY**, NOT named 4-piece set, chosen rare-grade perfect build or actual item paths; discrete exact-game outcomes will differ.
- **Other rosters:** same synthetic idealized q=.4 complete-equipment criterion, median required raw gear events: 1,000 disciples ~**26,192**; 3,000 disciples ~**77,068**. These counts are for the TOTAL Sect inventory demand, not units that can stand on one map.
- **What does not count as coverage:** wrong equipment tier, unsuitable path, currently locked/reserved by another disciple, duplicate slot not reassignable, advanced-set mismatched generation, unequippable template/SourceA-only thumbnail. If actual q=.2 or source slot probabilities skew, the times below **increase**. If legal forging provides baseline items and lower-grade loot is acceptable for a beginner, achievable outfit time decreases sharply.

### 3.1 From raw events to hypothetical full 10-slot coverage time (ONE World providing all drops)
These numbers divide coupon model MEDIAN raw events by source-controlled trial `gear_events_per_hour`, using **ONE fully active 30-hunter map's steady throughput** even to supply 1,000–3,000 Sect members. That's a severely bottlenecked extreme, not an accepted long-term game design.
| Gear rarity | 1 designated disciple (median sim h) | Full30 disciples (median sim h) | All1,000 disciples (median sim h if one map only) | All3,000 (median sim h if one map only) |
|---|---:|---:|---:|---:|
| THƯỜNG |~113|**~1,621**|~44,031|~129,558|
| HIẾM |~227|**~3,241**|~88,062|~259,116|
| RẤT HIẾM |~567|**~8,103**|~220,156|~647,790|

**Why this matters:** Full ordinary 10-slot matched gear for 30 via rare world drops ALONE is an overly slow primary progression source (67.5/135/337.6 *sim days* under these three profiles), even with unrealistic continuously successful farming! It is NOT advisable to make ten slots depend on rare hunting. Baseline everyday gear should come from legitimate normal crafting/drops/other authored sources, while drops here are exceptional affix/quality chase. No new 10-piece free starter bundle approved in this document.

### 3.2 Scaling to the 1,000–3,000 disciple Sect responsibly
- One map = up to30 deployed hunters. **1,000 combat active simultaneously would require at least34 30-cap map-equivalent deployments, 3,000 at least100** — these are *arithmetical hypothetical supply lanes*, NOT existing instances/multiple worlds, save performance or owner-approved all-hunt policy. Canonical workforce has professions, recovery and cultivation; 1,000–3,000 Sect TOTAL disciples cannot all be hunting all the time.
- With hypothetical34/100 copies of the SAME 30-hunter eligible drop throughput but no cross-source bottlenecks (NOT REAL gameplay), divide the one-world median supply hours by34 for 1,000 and100 for3,000: **Thường ~54 sim days, Hiếm ~108 sim days, Rất Hiếm ~270 sim days** for the q=.4 lower-bound ordinary 10-slot coverage. These are NOT a roadmap to spawning100 real maps or a feasible device performance claim. Actual content maps differ in realm, monster pools and roster distribution.
- Warehouse pools gear at Sect level and 24 sets match author-defined positions. “All1,000/3,000 have full 10 rare-hunt-slot gear” is **not the right early-game KPI**; more meaningful: a) all deployed 30 have at least basic valid gear; b) high-risk teams gradually upgrade selected slots; c) Sect-wide remaining workers get lower-grade proven crafts and legitimate hand-me-downs; d) long-term rare set lines obtained only from named sources/research/Forge.
- One rare item may be valuable to a promoted successor, without using duplicates/clone. One complete manual archived once can serve 3,000 learners over time subject to resources, unlike gear requiring distinct physical instances.
- If 30 active require300 items, after30days base HIẾM produces only214 raw events, **before** q-fit (expected~86 compatible items under40% assumption). Rất Hiếm produces86 raw, ~34 fit. There is no honest interpretation in which 30 disciples receive300 useful unique rare drops from these supplies in the first30days.

### 3.3 Genuine four-piece SET acquisition cannot be inferred yet
**LOCKED** exactly24 sets, each exactly four named positional item templates chosen among head/armor/cloak/bracers/belt/boots, mốc 2/3/4, generations cannot mix Nhân/Tiên/Thần and weakest tier limits bonus. **Neither the 7 species nor the current V2 drop proposals author exact set-lineage and piece-source distribution**; therefore no validated expectation can be computed for “how long to complete one Hộ Sơn 4-piece set” or “30 complete Trấn Yêu sets”.
**Pure counterfactual (DO NOT USE AS DROP RATE):** if just5% of ALL gear events ever carried any set lineage, those were uniform among24 lineages, and a selected lineage's four pieces were equally likely, fraction per target set piece category~`0.05/(24×4)=0.00052083` of all gear events. Expected raw gear events to see all four different target set pieces once~`(24×4/.05)×H_4=(1920×2.0833)≈4,000` gear events — **more than30-day map supply by an order of magnitude**. This is NOT gameplay source evidence; a warning that untargeted random-24-set loot is unacceptable for intentional farming. The game should author named camp/Elite/Boss sources per piece and/or a Forge/exchange/salvage route with real costs; do not automatically make every Boss contain pieces of any of24.
**Set eligibility never extrapolates from a style name:** member IDs, gear realm and generation, position, role and quality are actual required checks, not cosmetics.

## 4. Six Công Pháp FIRST transmission via fragment synthesis (not six combat skills)
Source-weighted fragment rates before rarity under base synthetic kill mix, from parent 20 camp worksheet:
| Family / proposed fragments required | Parent fragments/h | THƯỜNG fragments/h | HIẾM fragments/h | RẤT HIẾM fragments/h |
|---|---:|---:|---:|---:|
| `duong_khi_quyet` 12 |1.4400|.7200|.3600|.1440|
| `huyen_giap_cong` 18 |.4848|.2424|.1212|.04848|
| `liet_chien_quyet` 18 |.4536|.2268|.1134|.04536|
| `thanh_phong_kiem_quyet` 28 |.4800|.2400|.1200|.04800|
| `xich_viem_chan_quyet` 28 |.5040|.2520|.1260|.05040|
| `han_nguyet_tam_phap` 40 |.4464|.2232|.1116|.04464|
**Mean completion-time HEURISTIC `required_fragments/(expected_fragments_per_hour)`, if no direct books or other sources, real targeting/risk/downtime:**
| First transmission family | THƯỜNG sim h | HIẾM sim h | RẤT HIẾM sim h |
|---|---:|---:|---:|
| Dưỡng Khí Quyết |16.7|33.3|83.3|
| Huyền Giáp Công |74.3|148.5|371.3|
| Liệt Chiến Quyết |79.4|158.7|396.8|
| Thanh Phong Kiếm Quyết |116.7|233.3|583.3|
| Xích Viêm Chân Quyết |111.1|222.2|555.6|
| Hàn Nguyệt Tâm Pháp |179.2|358.4|896.1|
This is NOT a guaranteed time: real first-copy waits for the integer-th fragment in a stochastic process. Direct Nham Giáp Thú `huyen_giap_cong` book probability (separate roll) is .125/.0625/.025% per eligible Elite, with hypothetical3 Elite kills/h: rate .00375/.001875/.00075 full books/h, and simplistic `1−exp(−720λ)` gives approx**93.3% /74.1% /41.7%** chance of at least one direct-book event in30 sim days before account for shared kill/fragment priority and event schedule (still **SYNTHETIC**). Having a full book from fragments FIRST ends need to farm direct one; don't add these chances to fragment completion as independent “ownership chances” without a competing-risk model.
For Hàn Nguyệt, under RẤT HIẾM synthetic fragments λ30days≈32.14 and required40: simple Poisson tail chance `P(Poisson(32.14)≥40)≈10.0%`. This is a potential severe gate for first transmission unless separately authored quest/mentor/higher map/Bí Cảnh source exists. In HIẾM λ80.35 and chance before30days ≈100% given continuous synthetic farm, but much slower with fewer actual hunters.
**Archive once:** first full book → single permanent Sect transmission for potentially1,000–3,000 disciples over time; duplicates can feed authored research or be redirected, NOT unlock new skills or form another full item per disciple. This dramatically changes scaling: manual has roughly SECT-wide one-copy demand, ordinary gear has ten physical items PER equipped disciple. Fragment ownership must be deterministic and same-build save safe, not farm cast-spam.

## 5. Sensitivity and governance: why choose one profile only for an evidence trial
- If actual 30 hunters make only HALF assumed normal/Elite/Boss kills, expect HALF all gear/h under fully proportional assumptions; changing Boss cadence independently invalidates simple halving. A 400 live-monster map can still have lower K/hour than a 200 map if mobs are resistant and far apart. Healing, path congestion and 120-tick Injury reduce work availability.
- If all effective grade≥3/role matches produce `q=.20` instead of .40, median 30-person kit events approximately double from~964 to~1928; profile HIẾM then ~6,482 sim h. If q higher from reliable Forge and loot recycling, time decreases. q is invented, not actual grade-compatible roll calculation.
- Selected map difficulties from code (five per-map encounter grades) are NOT rarity profiles and may scale monster HP/ATK/DEF once, altering throughput; their finite `rare`/Boss odds may NOT be applied again per kill. Boss is one global HP/loot pool, never30 copies for30 attacking disciples.
- Rare gear needs legal content source, affinity, role and actual V2 affix/slot consumer, not just number scarcity. Chí Tôn drop0 from currently un-authored regional grade9–12 is source-gated, not a universal grade ban.
- Source A visual culling must not change RNG, damage or items. Owner's DEV fresh-save rule doesn't waive same-build snapshot correctness: unique kill life ID, loot decision version, item instance UUID, archived manual ID and receipt ACK must survive quickload/death/respawn.
- Material/recipe input/forge quantities unchanged, including sparse Water Shell and Fire Shell corrections. Keep ordinary forest/mining production as primary high-volume source, rare hunting material as distinct source and role specialization; no free resources when drop is rare.
- **One 4-piece set ETA remains UNKNOWN** until each of24 lineage four piece IDs are mapped to exact camp/Elite/Boss or named forge sources; arbitrary uniform example in `3.3` demonstrates why source authoring matters.

## 6. Model reproducibility / exact method
**Gear event analytic rates:** old source-weighted normal E=.0027283333333 per normal kill. Three profiles scale all normal/Elite/Boss event probabilities by m=.5/.25/.1. Holding original sample K_n=360/h, K_e=3/h and K_b=.25/h, baseline1.1897/h → m×1.1897/h. For 24/168/720h lambda=h×rate.
**Monte Carlo #1:** `numpy.random.default_rng(20261025)`, PCG64, 30,000 Poisson samples at each (profile,horizon), executed in profile order Thường→Hiếm→Rất Hiếm, horizon24→168→720; sample quantile probabilities .10/.50/.90.
**Matched kit coupon Monte Carlo #2:** `numpy.random.default_rng(20261024)` independent PCG64 state; 25,000 samples of 10 independent Gamma(shape=roster_size, scale=10/0.4) waiting times measured in expected raw gear-event units, maximum across slots; rosters simulated order1→30→1000→3000; quantile .10/.50/.90. This is a **Poissonization approximation** to random slot allocation, not the exact discrete random stream of V2 item templates. Sampled median raw item-event thresholds: `one≈67.5`, `30≈964`, `1000≈26191.9`, `3000≈77067.6`.
**Fragment rate:** parent six family source kill-weight rates calculated from `360×species_count/300×base fragment chance`, plus elite3×8% in Huyền Giáp. Profile scales all fragments by m. Base Huyền .2448 ordinary+hunter and .24 elite =.4848/h; at rare profiles direct-book roll is separate and the fragment roll is skipped if full book succeeded (very slight correction to simple fragment rate); differences negligible at this small direct-book probability but must be included in future exact simulation.
**Not modeled:** actual combat hit/no-hit, level distribution and enemy HP, false idle windows, real spawn cooldown, Boss scheduler, 5 five difficulty stat factors, per-person active job allocation, item economy sinks, real forging, set-targeting, discrete permanent books archive, map selection, save/load and UI. **Every output is a DESIGN forecast.**

## 7. Owner action / suggested next gates (NO CODE REQUEST)
**Recommendation:** **HIẾM** as the single next research baseline, not a final lock. It creates about214 gear events/30 sim-days at synthetic active30-hunter conditions and ~86 role/realm/grade-fit items under q=.4. This is far below full300-slot gear coverage, so BASIC item sources through legal Forge/low-grade rewards must be authored before treating rare drops as the only source.
1. Approve whether the midpoint rarity profile should be the single subsequent balance **experiment**, and whether whole low-level normal materials remain unchanged (recommended).
2. Define role- and grade-appropriate gear criteria, by path and 10-slot source IDs; assign four named positional templates to every set lineage with source and forge/loot eligibility. This would permit honest 4-piece ETA instead of fabricated chance.
3. Next source-level profile target: real 30 active disciples / 20 camps /200→400 monsters, instrument actual kills/hour, gear quality distributions, Boss cycle, save/loot receipt and Forge production. Only AFTER separate owner CODE authorization and PR29 one-writer integration coordination.
4. Confirm proper tutorial/basic-gear source before specialized Lv30 forge and secondary manuscript/fragment source for ultra-rare scenarios so no 1,000–3,000 roster soft lock occurs.

**NOT A MERGE / NOT AN IMPLEMENTATION / NOT QA PASS.** Two related Markdown research files on a new docs branch only.
