# X1 — R01–R03 KINH TẾ, NGUỒN/TIÊU, QUYẾT ĐỊNH OWNER VÀ GATES TRIỂN KHAI

**2026-10-23 · DOCS ONLY · X1 research package.** Cross-read:
- [X1 equipment/mobs/materials](X1_R01_R03_EQUIPMENT_MONSTERS_MATERIALS_CATALOG_2026-10-23.md)
- [X1 pills/techniques/skills](X1_R01_R03_PILLS_TECHNIQUES_SKILLS_PROGRESSION_2026-10-23.md)
- [X0 cross-system contract](TMB_CROSS_SYSTEM_REALM_CONTENT_INTEGRITY_CONTRACT_2026-10-23.md).
**No code, no merge, no PR#24/#25 edit. Nothing in X1 can claim real gameplay or Godot PASS.**

## 1. Economic quantities separated by SOURCE vs PROPOSED vs derived arithmetic

**Evidence sources**:
- Real `ResourceRegistry.market_value` is a **reference metadata scalar** not a guarantee that merchant buys or sells unlimited quantities at that value.
- Real `SpiritCropRegistry`: 3 `thanh_linh_thao` per **12 base plot cycle ticks**, 5 `linh_coc` per **10**, 3 `tu_van_thao` per **24**; actual output requires legitimate plots, workers/job compatibility, skills/building levels, settled Warehouse and scheduler. These are not unconditional production/minute faucets.
- Real legacy Economy-A Mine and Forest have Lv1 batches +2 common each per base 10 ticks in qualified timer paths (official O6 production had +2 and +2 for two batches). Their exact operation must be re-read at selected integrated SHA before any balance code or claim that every mine gives every ore tier.
- CARE fixed `Tinh Lang Bì` = 1 item per legitimate `Thanh Lang` paid generation kill. Existing `HuntingMapV2.preview_reward()/claim_reward` is **per won encounter**, so do not add it to CARE kill reward without one explicit de-duplication owner.
- R02/R03 proposed normal-kill rates from X1 equipment catalog: R02 `thanh_thiet p=.70`, `tinh_lang_bi p=.60`, `yeu_dan p=.12`; R03 `huyen_thiet p=.55`, `x1_r03_thach_thu_bi p=.55`, `yeu_dan p=.16`. Rolls independently per **eligible valid kill** after authored species source; 1 unit if each succeeds. These probabilities are **unapproved guesses to be calibrated**, not existing code/loot.

### A. One equal-rank disciple: full 10-slot ordinary Phàm loadout requirements and source availability

| Tier | Required for ONE complete set (one selected weapon) | Producer present NOW? | Source constraints |
|---|---|---|---|
| R01 | **5 `thanh_thiet` + 16 `linh_moc` + 6 `tinh_lang_bi`** | all three IDs exist and have some valid source; CARE wolf hide real, Mine/Forest real | full crafted ten-slot V2 and Lv1 animal-material eligibility are **not implemented/approved** |
| R02 | **18 `thanh_thiet` + 4 `linh_moc` + 11 `tinh_lang_bi`** | IDs exist but **new realm2 zone/normal drop PROPOSED**, no V2 template output | cannot relabel `bach_thach_khe realm1/floor3` to R02 |
| R03 | **18 `huyen_thiet` + 4 `linh_moc` + 11 `x1_r03_thach_thu_bi`** | Huyền Thiết exists as early rare reward, but new R03 normal source and proposed hide ID **not live** | baseline R03 armor must not require a unique Boss-only material |

**Per-disciple proxy cost if using SOURCE market_value as accounting proxy, not guaranteed player prices:** R01 `5×8+16×2+6×10=132` Stone-equivalent resource value; R02 `18×8+4×2+11×10=262`. R03 `18×34+4×2+11×UNKNOWN` (**NOT NUMERIC YET**; new hide `market_value` has no source). If owner later selects candidate hide-value 20, R03 would be 840 *illustrative*, not currency actually debited/received in a live forge. Before code, cost model must be based on real opportunity: craft recipes consume canonical Warehouse units; optional wage/contribution fees are separate and **OPEN**.

### B. 100-kill static binomial scenario (not Godot, not FPS/wall-time)

Assume one normal encounter per eligible rewarded kill with independent drops; **no injury, no fatigue, no duplicate receipt, no labor, no geography**. For per-kill success p and exactly 100 paid kills, `count~Binomial(n=100,p)`. 5th/50th/95th percentiles are binomial analytical quantiles. This is a scenario, NOT a Monte-Carlo Godot run.

| Tier/source | N paid normal kills | Mean units | Median | ~P05 | ~P95 |
|---|---:|---:|---:|---:|---:|
| R02 ore p70% | 100 | **70** | 70 | 62 | 77 |
| R02 hide p60% | 100 | **60** | 60 | 52 | 68 |
| R02 Yêu Đan p12% | 100 | **12** | 12 | about 7 | about 18 |
| R03 ore p55% | 100 | **55** | 55 | 47 | 63 |
| R03 hide p55% | 100 | **55** | 55 | 47 | 63 |
| R03 Yêu Đan p16% | 100 | **16** | 16 | about 10 | about 23 |

**Normal-gear affordability — statistical PROPOSED scenario only**, assume wood already supplied, no conflicting consumption, exactly the two necessary independent drop streams:
- R02 full ten slots require ore≥18 and hide≥11. At **30 paid kills**, `P(ore>=18)≈91.55%` and `P(hide>=11)≈99.71%`; simultaneous **≈91.29%**.
- R03 full ten slots require ore≥18 and hide≥11. At **30 paid kills**, simultaneous **≈35.42%**; at **40 paid kills**, **≈92.32%**.
- Real probability is lower if your monster mix yields different tables, elite/boss compete for spawn slots, workers are injured, loot is reserved, wood unavailable, profession/building requirements aren't met, crafting has failures, or Forge time/skill restricts. **All rates OPEN.**
- A full set for 1,000 disciples multiplies material demand (R02 **18,000 ore/11,000 hide**, R03 **18,000 ore/11,000 hide**) before replacing worn gear; do not claim a single map can support this population or infer kills/hour from the above.

### C. Throughput tests before rates may be locked

**Named clock:** 1 simulation tick=1 simulation minute, day=1440 ticks. The existing CARE visual MovieWriter accelerated proof with 120 Injury ticks is not real 120 wall minutes. Re-run against real scheduler to calibrate hunt throughput.

For one **dedicated, continuously operating** crop plot with BASE parameters only (not claiming enough workers/plots):
- Thanh Linh Thảo: (3/12=0.25) herbs/sim tick, (360) herbs per 1440 ticks *upper-bound steady-state average*.
- Linh Cốc: (5/10=0.5) grain/tick, (720) per 1440 ticks *upper bound*.
- Tử Vân Thảo: (3/24=0.125) plants/tick, (180) per 1440 ticks *upper bound*.
- One R01 Tụ Khí consumes 2 herbs+1 grain; possible *herb-only* steady-cycle bound from one such plot (360/2=180) pills/day; **other plot, alchemist, cure/cultivation shared herb competition, downtime and Warehouse can make actual much less**. Single field cannot grow all three crops at once. R02 XP pill consumes3 herbs (+Yêu Đan), so ~120/day herb bound per one dedicated crop plot; R03 XP pill consumes3 Tử Vân (+Yêu Đan), so ~60/day purple-herb bound per one plot. NOT actual throughput without independent Alchemy job/source/wage and Yêu Đan.
- At equal Realm+Body rank, baseline R01 HP190, R02 HP313.5, R03 HP517.275 before Potential/gear/buffs. Proposed heal item +55/+110/+190 yields 28.95%, 35.09%, 36.73% of this specific baseline respectively, but real battle numbers depend on actual maxHP.
- Distinct **wage/market/material currency** vs **personal contributions** vs **personal Tu Vi** are separate. Do not convert market value into free stones when a monster drops hide.

**Sensitivity scenarios:**
`K=30/100/300 legitimate normal kills per 1440 simulation ticks per active world` are *ASSUMPTIONS FOR INPUT CHECKS ONLY*, not current CARE throughput. Expected R02 ore (0.7K), hide (0.6K), Yêu Đan (0.12K); expected R03 ore (0.55K), hide (0.55K), Yêu Đan (0.16K). Multiply by 7/30 for weeks/months only if availability/downtime/respawns stay the same, **which must be independently shown**. Design target: ensure non-Boss repeatable sources provide at least 1 baseline weapon+armor+some potion production without softlocks; rare optional chase remains exciting.

## 2. Material sink and anti-exploit balance checklist

| Item/source | Faucet | Consumer/sink | Infinite/softlock risk | Future invariant |
|---|---|---|---|---|
| `linh_moc` | real forest and some encounter rewards | every rank's ingredient + buildings | if production 10k/hour exceeds demand, accumulation; no arbitrary storage cap to hide it | actually crafted recipes, MARKET controls optional |
| `thanh_thiet` | Mine, early PvE source, proposed R02 normal kills | R01 bridging and R02 ten-slot forge | double count Mine+Combat when testing O6; wrongly changing base2 | separated source receipts, raw stock unchanged |
| `tinh_lang_bi` | B3 1/legitimate kill, proposed R02 hides | armor/boots/garments | duplicate kill root across B3 and legacy encounter-win | exactly-once unique kill payout |
| `huyen_thiet` | early rare encounter (SOURCE), proposed R03 repeatable | R03 new item family, old P2 technique upgrades | mandatory rarity softlock / wrong realm map ID | independent normal R03 source after CODE |
| `x1_r03_thach_thu_bi` | **NONEXISTENT** future normal monster | R03 armor/weaver items | cannot craft until resource registered and source test | fail-closed until authoritative source |
| `yeu_dan` | early win resource, proposed R02/R03 normal p12/16 | high-rank pills/skill/technique | pill farming competing with skill upgrades | explicit shared resource demand / reserve |
| `thanh_linh_thao` | actual Spirit Field crop | two real R01 pills, candidate R02 pills | many recipes compete for same herb; wrong expected stock if work jobs overlap | One Active Job and actual plot-time evidence |
| `tu_van_thao` | actual crop, early encounter reward | new R03 pills | output vs consumptions, building/profession availability | separate Field plot work and Alchemy job |
| manuals/fragments | P2 gacha/legacy, future authored kill/transmission | Sect archive then individual learning/research | repeated manual purchase, class/gear synergy fake | archive once, learned/mastery separate |
| boss blueprints/direct rare equipment | future authored only | forge/unique Sect item UID/upgrade | last hit/team duplicates or Boss-only baseline | one Sect loot pool/receipt per Boss death |

**Daily economy gate** for any designed chapter: report actual produced/consumed/stock remaining/locked reserve by resource ID, per paid kill/encounter/work packet, after one day/week/month of canonical ticks; percentage of legit kills, Medicine satiety and HP needs, actual work/building dependencies and opportunity costs. A numerical design table alone is not a test gate.

## 3. Clear separation of valid gameplay transactions for future implementation

```text
PAID KILL OR ENCOUNTER WIN (one root; never both for same event)
   ├─ repeatable resource drop → canonical Sect Warehouse.add() once
   ├─ rare unique item → one Sect-owned unique item UID once
   ├─ blueprint/manual fragment → real registered reward/knowledge item once
   └─ personal direct fixed Tu Vi receipt for eligible contributors [future B3-XP01, NOT CODED]
           ↓
Warehouse real stock + worker/profession/building/stones + One Active Job
   ├─ F1 forge order (target slot/template/tier) → durable receipt → one item
   │       → manual/AI assignment to one wearer → CombatStatsV2 recalculated
   ├─ real alchemy recipe → one pill stack
   │       → use: satiety cap check + consume + real effect receipt
   └─ Sect technique archive/teaching → learned ID/mastery
           ↓
Save/offline deterministic exactly-once, not rewards from UI/preview
           ↓
Player makes rank progress, reevaluates risk/maps/Body independently
```

No hidden payout from clicking preview/reload, no retry-roll to another Grade12, no duplicated Spirit Stones Sect/personal, no fake materials granted to create a missing recipe. R01 existing P2 material flow isn't directly V2 Forge authority; version-safe migration later.

## 4. Six independent OWNER choices; recommended package reduces burden

**Owner has already LOCKED S2 + F1 + Q1. Do NOT ask again.** The six *new* content/economic decisions are genuinely unresolved:

| Decision | Option A / stable (RECOMMENDED) | Option B / high-drop/fast | Option C / scarcity/hard |
|---|---|---|---|
| **D1 — Main obtain** | normal gives rank-appropriate materials; targeted F1 base craft; Elite/Boss extra rare direct piece/blueprint | normal also may directly drop ordinary equipped items (extra lower-grade) | all ordinary gear only craft, rare must Boss |
| **D2 — Early hide forging** | permit clearly bounded **basic hide** Lv1/Lv? for starter ordinary gear, while **advanced monster-material** recipes stay Lv30 | no basic hide exception; all hide-based R01–03 gear waits Lv30 (requires new ore/wood starter alternatives) | ignore Lv30 constraint (NOT RECOMMENDED) |
| **D3 — Pilot grade outcome** | base **75% Phàm/20% Tinh/5% Thượng**, no grade4+ under E0 | 60/30/10 | 90/9/1 |
| **D4 — Nonboss R02/03 ore/hide drop** | R02 **70%/60%**; R03 **55%/55%** independent per valid kill, amount1 | generous R02 90%/75%; R03 75%/70% | scarce R02 45%/40%; R03 35%/35% |
| **D5 — New pills** | R02 heal **110** / Tu Vi **25,000**; R03 heal **190** / Tu Vi **50,000**, sat18/40 & 26/60, recipes above | fast growth R02 heal150/35k; R03 heal260/80k | restrained R02 heal90/15k; R03 heal145/25k |
| **D6 — learning & preservation** | keep P2 old learned+UID and author V2 Sect archive/1 main2 aux; early manuals available via repeatable nonboss fragment sources with boss acceleration | only elite/boss manuals (risk required path lock); no free starter manual | auto-grant all R01–R03 class skills at each breakthrough (violates explicit skill learning; REJECT) |

**Provisional preferred group: D1=A + D2=A + D3=A + D4=A + D5=A + D6=A.** Owner may mix. These options are **not approvals/locks until owner replies**.

**Additional numeric gates NOT included in owner choices yet:** chance of Chí Tôn under real costly E2 craft, R02/R03 boss 5% equipment/25% blueprint fragment, Forge basic time10 ticks, income/rare equipment prices for new `x1_` materials, Body gate ingredients, skill manual learning time, real full-item quality affix values, R03 monster HP/ATK/DEF values and special effects. These remain explicitly **OPEN** and must be calibrated after first real integration fixture. User shouldn't be forced to decide 100 probabilities before seeing playable progression.

## 5. Five implementation slices after DESIGN acceptance (each separately owner-authorized)

| Slice | Minimal future scope | Gate and required tests |
|---|---|---|
| X1-CODE-A | data/content foreign-key validator + true R01 safe IDs/versioned migration, no game command yet | verifies no fake `x1_` refs in live table, all future test data conditionally defined; legacy save |
| X1-CODE-B | one R01 real paid wolf hide or other existing nonboss material→one F1 targeted R01 sword/armor; register unique item and source→CombatStatsV2 | exactly-once debit+forge+equipment, One Active Job, save/offline, visible real stats, no wrong grade rolls |
| X1-CODE-C | add R02 authored region and nonboss normal drop, rank-specific gear and two pills; implement actual material sinks | 1/3 actor role fixture, no Boss-only gating, 100 paid kills distribution under deterministic seed |
| X1-CODE-D | add R03 authored region, normal sources `huyen_thiet` and new hide, own gear/pills; nonboss manuals/transmission pilot | full R01→R02→R03 loot/forge/learn/equip, old save preserved |
| X1-CODE-E | Elite/Boss rare content + source/participation/quality control; only approved item/effect sources | single sect loot, eligible personal XP, no 60/40 assumption, withdrawal tests |

**No code is authorized by this research.** Game UX migration is a separate single-writer path; PR#24 CARE / #25 main integration remain draft and untouched. Only after owner accepts numeric data *and* separately grants paths/branch/QA may these change runtime.

## 6. Truthful acceptance report at this exact source checkpoint

- **X1 design authored:** 36 stage-unique gear candidates, real vs proposed resources, 4 candidate higher-tier medicines, real P2 technique+skill identities, proposed book/manual sources, stochastic/economy input assumptions, anti-dup tests and options.
- **X1 design NOT approved:** exact item names/IDs/stats, 75/20/5 grade chance, normal monster drops, new herb/medicine costs, time10 ticks, E2/Grade12 probability, skill/Body upgrade availability.
- **Runtime NOT authored:** R02 or R03 active region, V2 ten-slot system/36 item registry, any new `x1_` resource/recipe, any R02/R03 medicine, new V2 learning/transmission, any actual new Boss rare drops, tested economic loop.
- **Existing PASS preserved:** CARE post-O6 28/28 focused, main P3.2 integration 13/13 focused were previously reported at their exact code/test SHAs; they do NOT prove R02/R03 content or Windows physical/Android visual acceptance.
