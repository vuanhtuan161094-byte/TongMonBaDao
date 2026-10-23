# CPV2-C4 — KIỂM ĐỊNH ĐỊNH LƯỢNG: P50/P90, NHẠY CẢM NHỊP BOSS, CHI PHÍ HỌC, OPTIONS

**Ngày:** 2026-10-23; **nghiên cứu/toán học/mô phỏng độc lập — KHÔNG phải test Godot 4.7.2, không phải rates runtime**.  
**BASE:** `main@29b5fba448b0178cb520a4ada44b375b4b934e31`. **Chỉ docs**, không sửa Codex recovery hoặc PR#24/#25; companion `CPV2_C4_BOSS_VS_RESEARCH_SOURCE_ECONOMY_COMPARISON_2026-10-23.md`.  
**Owner status:** C4 LOCKED. CP1/CP2/CP3 OPEN. Every new p/K/time/rate/recipe and milestone below is **ASSUMPTION/PROPOSED, NOT OWNER APPROVED**. `TechniqueSystem` current six P2 identities, fragment thresholds and learning currency are SOURCE P2 only.

## 1. Probability methods and units

**Independent repeated successful eligible events** with fixed p:
- full book: `P(at least one by n)=1-(1-p)^n`; `mean=1/p` events, `P50=ceil(log(0.5)/log(1-p))`, `P90=ceil(log(0.1)/log(1-p))`.
- `K` fragments, Bernoulli p each valid event, one fragment/success: `P(assembled by n) = P[Binomial(n,p)>=K]`; `mean=K/p`, `P50/P90=min integer n meeting 50%/90%`.
- **Quantiles here are acquisition event counts**, not in-game minutes/hours nor real wall-clock. Actual boss respawn, battle duration, pathfinding, injury120, One Active Job and failure probability are NOT measured.
- Quantities are per Sect knowledge archive, not per disciple: once first complete book is archived, V2 Sect teaching can serve many eligible disciples subject to personal cost/time.

### 1.1 Model B — FULL manuscript Boss-only (OPTIONAL named technique)

**ASSUMPTIONS:** first actual named Boss species has a real eligible `boss_death_id`, one shared Sect reward owner; per successful Boss death independently `p_full`, no fragments, no guarantees or pity. No loot currently live on Hắc Lang Vương in main.

| PROPOSED full-book p per successful Boss death | Mean successful Boss defeats to first copy | P50 Boss defeats | P90 Boss defeats |
|---:|---:|---:|---:|
| **2%** | 50 | 35 | 114 |
| **5%** | 20 | 14 | 45 |
| **15%** | 6.67 | 5 | 15 |
| **25%** | 4 | 3 | 9 |

**Conclusion:** "5% sounds common" but 10% of independently farming sects still require **more than 45 successful Boss defeats**. Suitable as an **optional unique** book, not an unreviewed required main-stage key. Boss loot is paid one time to Sect even with 3 teams and no last-hit preference. `p` applies to a *specific eligible Boss type*; normal/other Boss/Secret chance for a Boss-EXCLUSIVE book is exactly zero.

### 1.2 Model R — repeatable named fragments then research

**ASSUMPTIONS:** `K=8` fragments (taken solely as a calibration reference from actual P2 `duong_khi_quyet.fragment_required=8`; NOT a V2 number lock). Each *eligible paid normal kill* rolls independently one named fragment with probability `p_frag`. Once at least8, a separately authorized real research order would require input debit/time and create one full book, and first archive grants Sect teaching permanently. No full drops in this scenario.

| PROPOSED named fragment p per eligible normal kill | Expected normal paid kills | P50 paid kills | P90 paid kills |
|---:|---:|---:|---:|
| 4% | 200 | 192 | 292 |
| **8%** | **100** | **96** | **145** |
| 12% | 66.67 | 64 | 96 |

At constant p=.08, a `Huyền Giáp Công` **P2 K=12 threshold as reference**, not V2 approved: **P50=146 paid kills, P90=205**, mean150 kills. High-K books require better fragments/milestones or research to stay viable; do not copy a flat p across all rarities. P2 `danger` farm fragment chance 26/34/42% PER `roll_farm_loot` invocation is a different unit and can never be used as actual `p_frag` here.

**R downside:** time to one first book may be more predictable than Boss, but research and apprenticeship can become hard gates if herbs/Stones/teacher slots or hidden One Active Job are unavailable. Source→sink viability requires actual recipe IDs, nonnegative stock and no item duping. A fragment pile with no registered reconstruction consumer remains BLOCKED.

### 1.3 Model H — hybrid named fragment + Boss unique full + Boss milestone fragment

**ASSUMPTIONS FOR A COMPARABLE SIMULATION, NOT CURRENT SPAWN RATE:**
- Target is ONE hypothetical rare book, `K=8` named fragments or one full manual, whichever comes first.
- Each **valid normal kill** has independent p=.06 for **1 named fragment**.
- Precisely **one successful eligible named Boss defeat after every B=30 valid normal kills**, a deterministic schedule for this sensitivity fixture, **NOT** an observed CARE boss cadence, nor HuntingMapV2 `boss_chance`.
- Each *actual Boss defeat* independently rolls p=.05 for **one Boss-exclusive full book**, and also grants **1 guaranteed named milestone fragment** via a single co-op Sect receipt (when still needed). Fragments can therefore be collected from normals; the technique is *full manuscript Boss-exclusive*, not wholly Boss-exclusive.
- No research materials/time added to **acquisition count**, those are separate sink/cost/time after receiving K fragments.
- Boss deaths are shared across teams, not individual. The event schedule assumes every such Boss is defeated; if battle fails or Boss availability is lower, reduce eligible successful Boss cadence.

At n normal paid kills, b=floor(n/B) successful Boss victories and normal fragments X~Binomial(n,.06), probability NOT YET acquired:
`S(n) = P(X < K-b) × (1-.05)^b`; clamp `P(X<K-b)=0` if `K-b<=0`. This assumes independent Boss-full rolls and normal fragment rolls, with milestone fragments guaranteed only on real Boss wins. Then CDF=1-S(n), P50/P90 minimal n with CDF≥.5/.9. Boss event counts are `floor(n/B)`; don't treat Boss as free in actual time.

| ASSUMED successful Boss frequency | Exact P50 paid NORMAL kills | Exact P90 paid NORMAL kills | Exact expected paid NORMAL kills |
|---|---:|---:|---:|
| One Boss every **15** normals | 60 | 81 | 59.58 |
| **30** normals / Boss | **90** | **120** | **84.44** |
| **60** normals / Boss | **109** | **150** | **106.67** |
| **120** normals / Boss | **120** | **172** | **122.94** |

Do **NOT** mistake 120 normal kills as total combat encounters: to hit the B30 P90 scenario, a player must also defeat up to **four real Bosses** in that stretch; their prep, uptime, injury and fight durations must be counted separately to get time. As B rises, hybrid converges toward normal-fragment-only K8 p=.06 (P50 128/P90 194). Boss progression is real only if the required named Boss can actually be found and paid.

### 1.4 Source-level chance is not time to successful Boss

**SOURCE:** `HuntingMapV2.LEVELS[2].boss_chance=.03` is probability an *encounter contains a Boss*, not an already-paid kill. Separate **ASSUMPTION** win chance given Boss presence `P(win|boss)=.70`, source-specific full chance given won Boss `p_full=.05`, one independent encounter opportunity per trial. The probability to obtain one full book per SUCH eligible encounter is **.03×.70×.05=.00105 = .105%**, only under the 3 assumptions. The conditional P50≈**660 encounters** and P90≈**2192 encounters**. These are encounter counts, not normal paid kills (difficulty2 encounter has multiple mobs); the real PLAYABLE CARE scheduler does not necessarily use this historic encounter probability/cadence. Changing to difficulty5 with Boss included or a raid marker radically alters the assumptions, and no such translation is authorized.

**Boss spawn/defeat dilution illustrates why "5% Boss drop" cannot be interpreted as 1 book per 20 typical wolf kills.**

## 2. Independent seeded Monte Carlo CROSS-CHECK (not code in repository)

**Execution method:** local offline Python `numpy.random.default_rng(20261023)` with **N=200,000 independent trials per scenario**, no network/gameplay/UI, used to cross-check analytic law; one vectorized random process for hybrid. No generated game CODE or attached script. Sample medians/90th percentiles use `numpy.quantile(...,method="higher")` for discrete event counts. Exact analytic values above are authoritative for scenario probabilities; differences of ±1 near a quantile boundary are sampling variation.

| Trial distribution | N / seed | MC mean | MC P50 | MC P90 | Exact P50 / P90 | Verified interpretation |
|---|---|---:|---:|---:|---|---|
| Boss full p=.05 | 200,000 / 20261023 | 20.00 Boss wins | 14 | 45 | 14 / 45 | matches |
| R eight fragments p=.08 | 200,000 / 20261023 | 100.06 normal kills | 96 | 145 | 96 / 145 | matches |
| H B30: p_frag=.06, p_full=.05, milestone1/Boss | 200,000 / 20261023 | 84.33 normal kills | 89 | 120 | 90 / 120 | P50 differs by one due to random sampling; NOT a gameplay divergence |

**No Godot engine was run.** Monte Carlo uses sample independent event rolls and **presumes eligible encounters have already resolved**; no real drop tables, Boss combat role credit, delayed spawn, level-gate/chunk/map, player defeat, satiety, stock or save timing measured.

## 3. Learning and research economics: separated ONE-TIME vs PER-DISCIPLE

P2 `TechniqueSystem.learn_technique` genuine fee: `duong_khi_quyet` **40 Contribution +15 personal Stones** and `huyen_giap_cong` **75 Contribution +30 personal Stones** per learner. P2 personal Stones are transferred into Sect Stones, **not deleted currency** (transfer; net Sect economy is different from pure sink). These fees are **NOT new V2 tuition locks**. V2 has additional **time** and authored prerequisites and a different learned/active model.

| Scope | P2 Dưỡng Khí reference fees | P2 Huyền Giáp reference fees | Number of first archived Sect copies needed |
|---|---|---|---:|
| One learner | 40 Contribution,15 personal Stones | 75 Contribution,30 personal Stones | 1 |
| Six eligible team members | 240 Contribution,90 Stones transferred | 450 Contribution,180 Stones transferred | **1** |
| 1,000 eligible learners | 40,000 Contribution,15,000 Stones transferred | 75,000 Contribution,30,000 Stones transferred | **1** |
| 3,000 eligible learners | 120,000 Contribution,45,000 Stones transferred | 225,000 Contribution,90,000 Stones transferred | **1** |

**Do not multiply BOOK DROP events by disciples.** Acquisition once per Sect, then train each legal learner; costs and time scale with learners. The Sect could potentially subsidize training with separately authorized economy/policy but this is not an automatic transfer or a free grant. V2 time ticks per learning, concurrent teaching capacity and research recipe inputs are currently OPEN.

**Sensitive teaching throughput (100% ASSUMPTION, NOT gameplay):** if one instruction needs 30 sim ticks and one teacher works on one learner, 1,000 disciples consume **30,000 teacher-service ticks**; if ten independent authorized teacher-slots operate continuously with sufficient currency and capacity, ideal lower bound **3,000 sim ticks** (actual scheduling/job conflicts make longer). Alternative time10 or time120 multiplies totals accordingly. Never turn these what-if values into a Tàng Kinh Các building level gate without owner signoff. Remember single disciple One Active Job conflicts with simultaneous hunt/production.

**Research cost placeholders:** for fragment→manual require `K` named fragments + exact registered extra resources (if any) + author-approved time, profession/building and receipt; candidate time0/30/120 ticks are *scenario labels only*, not any approved recipe. Require a real duplicate/manual sink, no gacha reroll during research, preserve old unique ID and provenance.

## 4. Comparative decision matrix

| Criterion | Model B Boss-only | Model R fragments/research | Model H hybrid |
|---|---|---|---|
| Targeted, distinctive drop | **Excellent** | strong if named region/species | **Excellent** |
| Reliable first required book | weak; probability tail | good if stable repeatable normal+research | **good** if fragments exist beyond unreliable Boss |
| Player excitement | high burst reward | medium, accumulative | **high + tangible progress** |
| Multi-team Boss exploit surface | one sect pool critical | none for normal fragments | one Boss full + milestone receipts critical |
| Risk of rare book cloning through Sect | same archive-once contract | same | same |
| Source content implementation burden | low probability model, HIGH boss engine/source requirement | medium research/teaching+fragments source | highest logic but reuses both |
| Infinite grind hazard | **highest** without milestone protection | moderate if K/p too high | lower with genuine milestone |
| Recommended usage | optional unique Boss/Secret identity | common/mid-grade practical lineage | source-specialized rare line with optional full drop + finite fallback |

**Designer recommendation: tiered portfolio by *meaningful source/role*, NOT one acquisition method for all rarities.** Basic/required progression: reliable Sect starting technique + repeatable fragments or research; optional rare/novel Boss or Secret full-only; intermediate regional techniques: H hybrid, if milestone rewards have owner-verified ledger and production availability. Do not confuse this recommendation with prior owner CP1/CP2/CP3 approval (still OPEN).

## 5. Owner choices: do not require a decision on 30 different rates

**C4 remains LOCKED. CP1–CP3 remain OPEN.** This comparison adds ONLY two policy/numeric design questions:

| Choice | A (recommended) | B | C |
|---|---|---|---|
| **CP4 — acquisition portfolio** | MIXED: mandatory early basic via Sect/research, mid rare via regional fragments + optional Boss full + milestone; unique Boss-only/Secret optional | ALL basic/rare via fragments/research, Boss only bonus materials | ALL advanced via Boss-only full, no fragment research; high frustration risk |
| **CP5 — optional named Boss manuscript rarity TARGET (per successful named Boss death)** | target testing **15%** full book with finite milestone fragment path for rare but regular sidegrade | **5%** full book with same milestone/research support; notably rarer, 45 Boss wins at P90 if pure full | **2%** full book optional ultra-rare with no guaranteed alternative; exceptional collection only |

This does **NOT** mean 15% every Boss drops any book, nor a global grade drop. The 15%/5%/2% values are conditional probability for ONE explicitly named item from ONE exact eligible Boss source, and require reward budget across all eligible Boss goods. Even CP5=A does not set the number of fragments, boss availability or specific named book until authored source/consumer exists.

**Optional additional question deferred deliberately:** should the game use a guaranteed milestone fragment every single successful Boss death? This scenario uses that AS A HYPOTHESIS only; owner must explicitly choose milestone interval/amount, competition with other Boss loot and cooldown after first archive. The design may instead choose first-clear or cumulative per-sect reward, only after Boss credit fixture.

### Acceptance gates if owner chooses any direction

1. A book has an authored actual gameplay effect with real Combat V2/cultivation consumer, not effect-only design flavor; rare books optional unless alternative progression exists.
2. A specific `source_id` exists, exact victory/kill receipt, grade/type pool and registered items; exclusive chance exactly zero elsewhere.
3. First sect archive one, personal training reasonable, sensible duplicates sink and strong one-main/two-aux passive uniqueness.
4. Solo/Boss partial retreat and multiple squads never duplicate loot or give last-hitter full ownership.
5. Real 24h/7d/30d farm throughput and death/injury windows measured after CODE separately: the n-event values in this document do not prove time.
6. Legacy P2 saved manuals and weights preserved, no second loot bag, no routine migration invented.

**NEXT DESIGN PROMPT (NOT CODE):** owner can approve CP4=A and select CP5=A or B, or defer numbers and ask for a 6-person/1000-disciple rate/teaching test with actual P2 economy references. From next fresh main, research FIRST one truly sourced P2 existing book teaching path, then one optional named Boss/Secret title with validated real consumer; commit only docs, do not touch master recovery.
