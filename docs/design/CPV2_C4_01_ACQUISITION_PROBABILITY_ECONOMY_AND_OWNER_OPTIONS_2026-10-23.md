# CPV2-C4-01 — Mô hình số lượng quái/Boss, P50/P90, công thức nghiên cứu và các lựa chọn cần duyệt

**2026-10-23 | Docs only | base main `29b5fba448b0178cb520a4ada44b375b4b934e31`**. Owner **C4 LOCKED**, **CP4=A LOCKED**. **CP1/CP2/CP3/CP5 OPEN; không khóa xác suất Boss.** 100% NEW probabilities, K V2, durations and curriculum/research recipes in this paper = **PROPOSED ASSUMPTIONS**, **NOT CODED**. See companion source-to-teaching contract. No code/CI/merge or touching recovery/PR24/#25.

## 1. Evidence vs scenario

- SOURCE P2 `TechniqueSystem.TECHNIQUES`: Dưỡng Khí `fragment_required=8`, Huyền Giáp `fragment_required=12`, tuition DQ 40 contribution+15 personal Stone, HG 75+30, actual `gacha_weight` 38/20 (among 6 P2 weighted choices) **not drop rates**.
- SOURCE P2 `roll_farm_loot` has *per invocation* chance 26/34/42% depending danger; this is NOT the B3 `paid_kill` chance and cannot simultaneously settle loot over the same event. Cannot derive real kills/hour or books/day from it.
- SOURCE `HuntingMapV2.REGION_CONTENT["thanh_truc_lam"]`: on a *normal monster selection slot* weights .30 Thanh Lang, .65 Trúc Thử, .05 Hắc Lang. **These are composition weights, not directly paid kill proportions**, because different monster stats, elites/Boss, success, scheduling and rewards matter.
- SOURCE Nham Giáp Thú Elite and Hắc Lang Vương Boss actual species exist, **both loot_ready=false**. No V2 book or mảnh currently drops from them. No verified CARE Boss success cadence; the five pilot `HuntingMapV2.LEVELS` are selectable encounter difficulties, not seven map realms.
- **All** percentages below are conditional on a successfully paid qualifying event / source, not a guarantee of loot in today's game. `market_value` ResourceRegistry is a reference scalar, not real cash availability.

## 2. Mathematics + simulation protocol

For K independent fragments per qualifying paid event with per-event p:
`P(acquired by n) = 1 - sum_{j=0}^{K-1} C(n,j)*p^j*(1-p)^(n-j)` (binomial upper tail).
`P50/P90` = smallest INTEGER n with probability ≥ 50%/90%. Expected qualifying events `K/p`.

For a full book with p each successful eligible Boss death: `P(at least one)=1-(1-p)^b`, mean `1/p` and integer P50/P90 accordingly.

**Independent numerical cross-check:** Python NumPy generator `np.random.default_rng(20261023)`, **100,000 independent randomized trials per scenario** using negative-binomial fragments, array event rolls for mixed Elite+normal, geometric boss full and deterministic milestone cap. P50/P90 sampled as first discrete count satisfying empirical quantiles; analytical numbers below (binomial/Poisson-binomial exact) are used as point reference, not Monte Carlo noise. **No Godot code or UI test run.**

## 3. DƯỠNG KHÍ — source-conditioned normal fragment model

**PROPOSED:** K=8 (equal to genuine P2 threshold as *scenario only*), P(named DQ fragment | actually paid `thanh_lang` kill in `thanh_truc_lam`)=12%. Not a live drop or approved V2 K.

| Counting convention | Effective event p | Exact P50 | Exact P90 | Mean event count |
|---|---:|---:|---:|---:|
| Only eligible **paid Thanh Lang kills** | **12.0%** | **64 Thanh Lang** | **96 Thanh Lang** | 66.7 eligible kills |
| All normal enemy **selection slots** in Thanh Trúc Lâm, assuming 30% Thanh Lang independent and each slot becomes one paid normal kill | **30%×12%=3.60%** | **213 slots** | **325 slots** | 222.2 slots |

**Do not present 64 as the number of *all* wolves/rodents**; using the full zone's normal mix raises it >3×. MC cross-check yielded 64/96 for conditional, 213/324 for all-normal; one-count quantile sampling variation is expected. Exact first-use source still BLOCKED because the `cpv2:fragment:duong_khi_quyet` drop has no registered paid-kill event.

**Scenario speed:** if player completes **6/12/24 successful normal kills per 60 simulation ticks** *ASSUMPTION ONLY*, and farmed slots have the mixture above, the **P90 325 normal slots** corresponds to about **3,250/1,625/813 sim ticks** before research/teaching, respectively. Express as `n * (60/kills_per_hour)`; this assumes no travel, respawn, field/forge competition, Injury120, failures or elite substitutions. These rates are NOT observed CARE kills/hour. The 12-sim-tick proposed research job is an extra cost, not magically included.

**CP2 OPEN:** a deterministic one-time Sect first milestone that grants/archives a legal basic manual would remove this required early grind; alternatively fragments-only requires lower P90 and an accessible source. DO NOT assume free starter books until owner approves CP2.

## 4. HUYỀN GIÁP — normal + Elite specialty source, keeping a backup

**PROPOSED** K=12 (P2 reference only), P(named HG fragment|paid `truc_thu`)=6%; P(named HG fragment|paid `nham_giap_thu`)=25%, Elite loot **currently blocked**.

| Eligible source and event convention | Explicit assumed p | Exact P50 | Exact P90 | Mean |
|---|---:|---:|---:|---:|
| Only **paid Trúc Thử kills**, no Elite | 6% | 195 Trúc Thử | 274 Trúc Thử | 200 |
| All R01 Thanh Trúc Lâm **normal selection slots**, assumes 65% Trúc Thử and all selected normals settled | 65%×6%=**3.90%** | **299 normal slots** | **423 normal slots** | 307.7 |
| Idealized schedule of 1 *successfully paid* Nham Giáp Elite after every **10** normal paid slots, normal p=3.9%, Elite p=25% independent | two independent event types; no single constant p | **183 normal slots + 18 eligible Elite wins** | **257 normal slots +25 eligible Elite wins** | ~188.7 normals under seeded simulation |

The last row **is not the live spawn rate**. It presupposes a named paid Elite win each 10 normal paid kills and ignores availability/injury. It uses normal effective **3.9%**, not 6% on every normal. Exact P50/P90 obtained by convolution `P[Bin(n,.039)+Bin(floor(n/10),.25)>=12]`, with 100k-seed simulation yielding P50=183/P90=256, one-count difference.

**Anti-softlock:** if real Elite source remains `loot_ready=false`, the normal `truc_thu` route must still be authored first; if both are missing, **NOT FARMABLE**, not a false promise. Research candidate uses `linh_tuy:1+tinh_lang_bi:2`; `linh_tuy` is in a genuine legacy encounter-win source, not a CARE kill-root guarantee. Both must be explicitly obtainable in ONE canonical runtime before saying this book is accessible. Huyền Giáp is a build alternative, not a mandatory character-stage blocker.

## 5. HẮC LANG HỒN QUYẾT — OPTIONAL named Boss book (NO CONSUMER YET)

**Source candidate:** `hac_lang_vuong` (registered Boss, `loot_ready=false`), `cpv2_proposed_hac_lang_hon_quyet` is a **new hypothetical ID**, no active V2 ability, grade, or registered fragment. NO boss loot probability approved. Model p as a *conditional chance per successful eligible shared Boss death*:

| p specific Boss full-book/actual paid Boss death **PROPOSED** | Mean eligible Boss wins | P50 Boss wins | P90 Boss wins |
|---:|---:|---:|---:|
| 2% | 50 | 35 | 114 |
| 5% | 20 | 14 | 45 |
| 15% | 6.67 | 5 | 15 |

If there is no fallback, 5% implies **P90 45 eligible Boss defeats** and 2% implies P90 114. Since Boss availability/win time is NOT measured, neither is a justified percent-to-hours promise.

**Finite-progress alternative, STILL PROPOSED/CP3 OPEN:** Every **3** distinct paid wins over the SAME eligible named Boss grant **one named milestone fragment** to Sect, `K=8` fragments require at most **24 real Boss wins** to assemble one optional book if first-book conditions remain valid; independent full-book drop still p=5% as illustration. Then `T=min(Geom(0.05),24)`: **P50=14, P90=24 Boss victories, mean≈14.16** vs P50 14/P90 45 unprotected. Milestone receipt = once per Boss death, shared among any number of squads, not last-hit nor a distinct Boss duplicate pool. **Before OWNER CP3 approval, this is no more than a compared scenario**; it should not show in UI as available.

**Do not interpret `HuntingMapV2.LEVELS[2].boss_chance=.03` as p=3% Boss success per normal kill:** it is chance of adding Boss to a single eligible encounter at difficulty2. Additional win rate = ASSUMPTION; if `p_spawn=.03`, `p_win_given_spawn=.70` **ASSUMED**, `p_full_given_win=.05` ASSUMED, then per such encounter `p=.03×.70×.05=.00105`. P50≈660 and P90≈2192 **encounters**, not normal kills or paid Boss deaths. The CARE loop may have different spawn logic; never claim this as observed runtime.

## 6. Cross-system economics: actual vs proposed

### 6.1 First Sect archive cost vs repeated teaching

| Content | P2 per-learner fees (SOURCE P2 ONLY) | Six learners | 1,000 learners | First archived manuscript |
|---|---|---|---|---:|
| Dưỡng Khí | 40 Contribution,15 **personal→Sect** Stones | 240 Contribution,90 transferred Stones | 40,000 Contribution,15,000 Stones | **1** |
| Huyền Giáp | 75 Contribution,30 **personal→Sect** Stones | 450 Contribution,180 transferred Stones | 75,000 Contribution,30,000 Stones | **1** |

This is NOT a V2 fee lock. V2 learning time remains OPEN; if ONE teacher takes **30 sim ticks/student** (pure scenario), 1,000 learners consume **30,000 teacher-service sim ticks**, and 10 truly independent valid teacher slots could theoretically process this in **3,000 ticks** assuming no contention. This is a model, not approval of 10 teacher positions/building slots. One Active Job can reduce throughput further.

### 6.2 Research material inputs; proposed opportunity value only

| Candidate recipe after named fragments | SOURCE ResourceRegistry values (market_value) | Proposed material cost | Proposed worker/order time |
|---|---:|---:|---:|
| DQ: `linh_moc:2` | 2 each | **4 proxy Stones** | 12 sim ticks |
| HG: `linh_tuy:1 + tinh_lang_bi:2` | 14 +2×10 | **34 proxy Stones** | 24 sim ticks |
| Boss: `yeu_dan:1 + linh_tuy:2` | 18+2×14 | **46 proxy Stones** | 36 sim ticks |

**Neither these inputs nor tick costs exist in P2 craft_manual**, where K fragments directly yields one manual. The proxy is NOT an automatic Sect treasury debit or sellable merchant price. Forge, Alchemy and Body breakthroughs compete for the same real resources; no free `research_mana` or invisible currency. Note one-time Sect archive means 1,000 learners multiply tuition/service, NOT the book or one-time recipe K.

## 7. Acceptance criteria for next real content slice (future separate CODE packet only)

- A SOURCE `monster_species_id,region_id,event_id,loot_table_revision` returns one verified named fragment/manual with no duplicate pay via `HuntingMapV2.claim_reward` and CARE `paid_kill`.
- Valid `p` per species/zone passes analytic and 100,000-seed statistical tests and illegal source has probability **0**; separate spawn chance and per-defeat source chance.
- Research order checks canonical Warehouse, named fragment stock, worker and single job, committed outcome and save exactly once; first complete book archive persists and never consumes more than one copy; old P2 save migrates safely.
- V2 technique learned library, main/aux, active-only effect and conflict key do not stack old/new owners or fake passive; Combat V2 source test proves the real consumer.
- Optional Boss reward remains one Sect pool regardless of teams, no extra personal copies, retreat/resume under approved qualification rules, no 60/40 stone split assumed.
- Before any owner-visual claim, actual Godot4.7.2 focused, Windows manual and Android device evidence are separately reported. This docs analysis has run NO GAME.

## 8. Items STILL requiring OWNER (not re-asking C4/CP4)

**Open prior CP1/2/3/5**. New decisions best staged (no numeric freeze yet):
- **O-A** CP2: basic first Công Pháp via an authored deterministic tutorial/sect milestone or first book via only random fragments? Recommend deterministic starter access + specializations via hunt; no free grant until approved.
- **O-B** CP3: optional Boss full-manual-only vs milestone fragments on same Boss/rare named pool? Recommend configurable finite-chase *direction* before values; no actual p now.
- **O-C** proposed research recipe costs K and 12/24/36 sim ticks: owner may accept as experiment inputs only; NEED measured G1/CARE sourcing to justify locked economy. CP5 percent **leave OPEN** until actual Boss farm cadence evidence.
- **O-D** source distribution: conditional specific species only vs a known region pool with fixed award per normal; recommend species-specific targeting with an alternate sensible ordinary/research path so the UI can direct hunters.

**Preferred next DOCS task, NOT CODE:** trace actual event and consumer entrypoints on PR24/25/recovered HEAD when available (no edits), then balance P50/P90 using legitimate paid kill throughput and true Boss spawn/death fixtures; after that present CP2/CP3 and first full training-time options to owner for explicit approval. No new large technique catalog invented.
