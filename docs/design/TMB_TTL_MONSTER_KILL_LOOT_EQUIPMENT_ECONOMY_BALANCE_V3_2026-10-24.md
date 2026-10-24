# TÔNG MÔN BÁ ĐẠO — THANH TRÚC LÂM: KINH TẾ RƠI ĐỒ THEO TỪNG CON QUÁI V3
## B. Trang bị 10 ô/12 phẩm, vật liệu ngũ hành, Yêu Đan, bí tịch, mảnh, xác suất nhiều tầng và sản lượng/giờ
**Ngày:** 2026-10-24 · **DESIGN/BALANCE STUDY ONLY, NOT LOCKED, NOT RUN IN GODOT.**
**Companion A (same branch):** `docs/design/TMB_TTL_20_CAMPS_MONSTER_SPECIES_FIVE_ELEMENTS_CATALOG_V3_2026-10-24.md`. Scope owner confirmed: 20 farm camps ×10–20 quái each, 30 disciples on one continuous map, heterogeneous species/realm/element and JX-like monster-specific gear/material drop. **No CODE, no Codex packet, no PR29/UI/Source A edits or merge.**
**Current main source:** `29b5fba448b0178cb520a4ada44b375b4b934e31`. Source authorities: `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`, `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`, `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`, `docs/WEAPON_EQUIPMENT_V2_SPEC.md`, `docs/EQUIPMENT_SETS_V2_SPEC.md`, `docs/TECHNIQUE_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, and actual `godot/src/simulation/{combat/hunting_map_v2.gd,combat/monster_catalogue_v2.gd,equipment/equipment_system.gd}`.
**Legend:** [LOCKED] existing canonical; [SOURCE] existing code; [PROPOSED] numerical pool/content NOT owner-approved; [EXAMPLE] arithmetic of assumptions not a prediction; [PENDING] new registry IDs, stat tables and QA.

## 1. Core economic rule: a kill rolls one decision, may yield 0/N legal items
- One real living monster life ID: `map_instance_id:camp_id:spawn_slot_id:spawn_generation`. A full kill resolves its `LootDefinitionV3` once, **not one old finite “victory reward” for every enemy killed**.
- A kill produces one frozen **loot decision record** with potentially multiple **independent authored categories** (material, core, equipment, manual fragment, manual/skill, Stones/personal progression when authorized), each of which may yield zero items. “One decision” != “always one item”.
- Eligibility depends on **actual species + tier (normal/Elite/Boss) + own monster realm/floor + element + map/camp/event + selected map grade + content source template**. A generic global player-based scaling factor is not a source. Quái level and item-realm requirement are NOT the same axis.
- [LOCKED] All physical items/equipment = Tông Môn property. Stack materials by genuine ResourceRegistry item ID in **ONE logically unbounded canonical Sect Warehouse** (integer-safe counts, reserves/locks); unique gear/manuals and Boss artifacts retain unique instance identity. No personal loot bag or arbitrary warehouse capacity gate, no drops attached to camera/UI. Personal Tu Vi/contribution/Stones only via separately authorized original reward channels, not invented from VFX or global kills.
- [SOURCE] `HuntingMapV2.preview_reward` bases resources on **one completed finite win**; `rare` chances and `LINH_TUY_GUARANTEE_WINS=4` count winning encounters, not monsters. `EquipmentSystem.forge_loot_for_victory` is legacy P2 species material source. **Exactly one mutually exclusive route for a WORLD kill**; never pay old win reward + old forge loot + proposed WORLD loot simultaneously.

## 2. Full loot source taxonomy: creature-specific, element-specific AND player-useful

**Registered/original example IDs (source-backed but still must check future actual ResourceRegistry at write time):** `linh_moc`, `thanh_thiet`, `thanh_linh_thao`, `tinh_lang_bi`, `yeu_dan`, `linh_tuy`, `huyen_thiet`. Those are observed in current HuntingMap/legacy equipment/P3.7 docs; they are NOT all authorized per-kill drops from the listed species. **New display labels have NO registered ID yet**.

| Monster profile (A docs) | Element | Material/core families per kill, PROPOSED | Eligible equipment family/slot, PROPOSED | Technique/skill source, PROPOSED |
|---|---|---|---|---|
| `truc_thu` [SOURCE] | Mộc | Linh Mộc, basic herb input if authored | low-tier `gloves`/`boots`/`pendant`; healer work pieces | Mộc-related common pages only with approved manual ID |
| `thanh_lang` [SOURCE] | Mộc | Tinh Lang Bì, Thanh Thiết via authored drop table not guaranteed | light `armor`/`cloak`/`boots`, Truy Phong/Huyết Liệp set eligibility | wolf mobility/pack skills only when approved |
| `hac_lang` [SOURCE] | U Minh | wolf hide/fang, Yêu Đan conditional | `weapon`/`ring`, eligible U Minh conditional lines | shadow/debuff pages, not fake Fire manuals |
| `ttl_thuy_vu_linh` [NEW] | Thủy | water essence, medicine reagents [NEW] | `pendant`/`ring`/`head` support items | Y Đạo/Thủy utility if content exists |
| `ttl_thuy_tinh_giai` [NEW] | Thủy | water shell, durable healing reagent [NEW] | `armor`/`bracers`/`belt` defensive templates | shield/water specialty, gated |
| `ttl_kim_giap_trung` [NEW] | Kim | alloy/ore/metal shell [NEW] | `weapon`/`armor`/`bracers`, Phá Cương candidate | metal techniques/blueprints if authored |
| `ttl_thiet_tiem_thu` [NEW] | Kim | sharp shard/weapon alloy [NEW] | `weapon`/`gloves`, Sát Tinh candidate | piercing/line follow-up, gated |
| `ttl_hoa_van_lang` [NEW] | Hỏa | Hỏa essence, burned fang [NEW] | `weapon`/`cloak`/`ring` | fire combo pages, legal mastery prerequisites |
| `ttl_xich_viem_trung` [NEW] | Hỏa | flame shell, talisman ink input [NEW] | `pendant`/`head`, effect-hit templates | AoE or Fire proc fragments, only legal content |
| `ttl_thach_bi_thu` [NEW] | Thổ | rocky hide, Earth core [NEW] | `armor`/`belt`/`boots`, Hộ Sơn candidate | guard/defense support skills |
| `nham_giap_thu` [SOURCE Elite] | Thổ | armored shell/core [NEW ID pending] | Earth defensive **eligible higher grade**; Hộ Sơn / Trấn Yêu if template exists | rare Earth technique fragment |
| `huyet_lang_dau_dan` [SOURCE Elite; outside base TTL] | Hỏa | fire blood core / rare fang [NEW] | Hỏa lineage elevated gear | named Fire manual fragment only if owner adds TTL event |
| `hac_lang_vuong` [SOURCE Boss] | U Minh | authored named Boss core/rare manuscript/unique relic | unique Sect-owned eligible template/sets, not guaranteed Chí Tôn | Boss family complete manual or research item after content gate |

This table **does not create loot tables**, no automatic material IDs such as “Linh Dịch Thủy” exist today. A drop row with missing ResourceRegistry ID is DISABLED/UNKNOWN, not a fake “loot_ready=true”. Element influences *source eligibility*, not a universal chance boost or magical element conversion based on killing skill.

### 2.1 Farming should be targetable
- Player can order “Thiếu 60 Tinh Lang Bì → Thanh Lang camps C02/C05/C11”; actual map count and item source identity confirm viability. Don't assign elite boss-only stock to trivial rat farms.
- Player can seek source family “Mộc gear/Ngọc Bội/Thủy vật liệu/Boss bí tịch”; camp tooltips show confirmed known drop candidates and estimated danger, NOT full future unregistered artifact promises.
- Auto Hunting Policy chooses camp with true reachable monsters, ability to survive independent monster realm/floor and legal elemental skills, missing Warehouse materials, expected payout per sim hour, travel & medicine costs. Danger/supply/OneActiveJob/Manual OFF gates BEFORE utility optimization. No infinite ping-pong by small forecast differences.
- Basic materials are genuinely useful in large counts, while rare armor/manual/blueprint needs deeper risky bãi or Elite/Boss; do not obsolete normal maps entirely.

## 3. Multi-stage loot formula — distinguish definition, roll and unique instantiation

### 3.1 Data contract proposed
~~~yaml
loot_profile_id: ttl_hac_lang_v1                 # PROPOSED authoring ID
owner_source:
  species_id: hac_lang                          # CODED monster ID
  tier: normal
  element: nether
  map_id: thanh_truc_lam
  min_monster_realm: authored
  camp_tags: [eastern_woodland]
rolls:
  common_material:
    candidates: [registered_resource_ids_only]  # NO placeholders accepted
    probability: owner_approved_per_kill
    quantity_range: owner_approved
  monster_core:
    candidates: [registered_ids_only]
    probability: owner_approved_per_kill
  equip_event:
    probability: owner_approved_per_kill
    templates: [approved_v2_equipment_templates]
  manual_fragment:
    probability: owner_approved_per_kill
    family_and_piece_ids: [registered_manual_piece_ids]
  complete_manual:
    probability: owner_approved_per_kill
    sect_technique_id: approved_only
rng_key: [map_instance_id, camp_id, spawn_slot_id, generation, table_version]
settlement: single_canonical_world_reward_route
~~~

### 3.2 Exact order, not a one-line rarity multiplier
**Gate0:** verify legitimate HP>0→0, actor life present, valid loot source + eligible kill; one kill_id recorded durably, real contribution attribution. Reject duplicate/dead/training VFX.
**Gate1:** freeze species/tier/element/own realm/camp/map grade, dropsource version and eligible pool; don't derive a rare roll from player's current inventory or camera view.
**Gate2:** each authored category gets a scoped deterministic RNG substream using `kill_id + table_version + category_id`. Validate `0<=P<=1`, positive/legal quantity and item IDs, no dynamic code expression or unbounded "pick from all items".
**Gate3:** category-success selects a **specific registered ID** with weighted conditional pool. Monster material, elemental material, gear item and manual are distinct categories; there may be none or several.
**Gate4 equipment:** select eligible template/family/slot and 1..30 equipment realm according to an authored band; choose quality **one of V2 grades1..12** with an item-tier-specific distribution; roll only its legal 0..6 normal lines, 0..2 rare stat lines and 0..1 Chân Văn capacity (at Chí Tôn), then choose valid set-lineage/generation if eligible. New Chân Văn mechanic itself is NOT granted for free by high quality; no guaranteed proc without separate item/inscription rules.
**Gate5 manuscript:** complete book registered as one Sect transmission after archival, unlock teaching without consuming new full manuals; duplicates can feed approved research/fragments, but do **not** mint a new full manual, arbitrary skill or full kit for every hunter. Skills and techniques remain independent, learned/active and five-stage mastery. Fragment recipes/amounts not specified must not be invented.
**Gate6:** frozen roll outcome written with unique-item instance IDs and immutable final receipt; canonical Warehouse/unique-item registry and authorized participant personal progression credited atomically or through durable pending retry; ACK exactly once. No reroll by quitting between HP0/roll/deposit. Overflow concerns only safe integer/item constraints; warehouse storage is logically unbounded for stackables.
**Gate7:** spawn slot schedules next generation **after** death identity/settlement contract, not via random duplicate monster. If an item template or legal recipient consumer does not exist, fail closed with documented missing-source status; never fabricate placeholder item.

### 3.3 Selected map difficulty is independent of monster and loot
**Source finite battle** has one grade1..5 per region; pilot stat multipliers e.g L1 HP×.75/ATK×.82/DEF×.88, L5 HP×2.70/ATK×1.65/DEF×1.45. Those may be adopted as world scenario modifiers **once per monster** after approval. Their `yield/rare/boss/elite` values are PER FINITE ENCOUNTER — no direct `p_gear *= 3.5` or 26% rare on every kill in L5. A map L1 can contain a monster with higher own realm than nearby other monsters. World loot uses authored profile/table matched to true source and grade only when design approved.
Boss schedule = a bounded **world event**, NOT one chance per tick/camp/mob. Boss shared HP and shared Sect reward pool, contribution-based personal distribution with no last-hit claim. Stone Sect/personal split 60/40 is unapproved proposal, not numeric lock.

## 4. Equipment V2 constraints baked into the drop resolver
- **Ten ordinary slots:** weapon, head, armor, cloak, bracers, gloves, belt, boots, pendant, ring. Phù3 + Pháp Bảo2 are separate; do not drop ordinary item with `talisman` legacy slot and pretend V2.
- **Twelve grades:** 1 Phàm, 2 Tinh, 3 Thượng, 4 Cực, 5 Linh, 6 Huyền, 7 Địa, 8 Thiên, 9 Vương, 10 Thánh, 11 Đế, 12 Chí Tôn. Graded affix capacity is from authoritative Equipment V2 spec. One item realm tier1..30 independent from monster realm, five skill mastery stages and Nhân/Tiên/Thần generation.
- **24 set lineages, 4 pieces each**, thresholds 2/3/4 cumulative and positional/generation rules exactly from `EQUIPMENT_SETS_V2_SPEC.md`. A set family isn't the same as automatic “Boss ultimate skill”; 4th set bonus cannot spawn extra attacks unless real authored effect and separate approved consumer allow (current sets are stat-based).
- **Common vs rare lines vs Chân Văn:** common property only real existing stat/action channel; a rare special-stat line does not generate a new active attack. Chân Văn, if ever inscribed, is one unique mechanic on an eligible Chí Tôn item only, bounded by real trigger/ICD/owner.
- Forge/upgrade/spec 1..9 order remains deferred; drops must not secretly implement or override crafting. All actual items are Sect-owned, can be auto-assigned legally, not personally looted into 30 bags.
- User wants many distinct items like JX, but **100 unique icons are not a working item catalogue**. Require template ID, eligible source, stat lines, equip gate, sprite ID, crafting/salvage sinks and real consumer, else mark DEFERRED.

## 5. Numerical balance worksheet — ENTIRE SECTION IS PROPOSED EXAMPLE, NOT CANONICAL

### 5.1 Explicit illustrative event probabilities
| Kill source | Example P(any eligible gear event) | Example P(manual fragment event) | Example P(complete manual event) |
|---|---:|---:|---:|
| Normal mob | **0.30%** | **0.10%** | **0%** |
| Elite kill | **4.00%** | **2.00%** | **0.05%** |
| Boss kill (one life/event) | **35.00%** | **20.00%** | **2.00%** |

**Not automatically all grades:** probability "gear event" only permits an eligible item; its item quality, realm, set, slot, affix and identity require separate conditioned authored rolls. These numbers are illustrative deliberately **not locked**; no source file proves them. Different actual species/camps/grades need individualized chances after owner approval; table here is a synthetic test input and not production parameter. A “complete manual” may be technique or skill transmission according to chosen pool, not whole kit. For normal material sample assume a separate 60% chance of material stack, conditional mean quantity1.5 → expected0.9 common material **units** per regular kill; **NOT** per-species live data.

### 5.2 Expected volume per HOUR OF CANONICAL SIMULATION under different hunt throughput
The throughput numbers below are **synthetic input assumptions, NOT measured kills/hour**. “Boss0.25/h” is a long-run one Boss kill per 4 sim hours on average, not fractional Boss in the game. Assume eligible drops and independent category rolls; not modeling travel, injury, consumables, spawn downtime, actual boss losses or party inefficiencies. These would lower realized throughput.

| Sample load | Normal kills/h | Elite kills/h | Boss kills/h avg | Expected gear/h | Gear /24 full sim h | Fragment events/h | Complete manuals/h | Common material units/h (normal only) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| S — low | 120 | 1 | 0 | **0.4000** | 9.6 | .14 | .0005 | 108 |
| M — base | 360 | 3 | .25 | **1.2875** | 30.9 | .47 | .0065 | 324 |
| H — high | 720 | 6 | .50 | **2.5750** | 61.8 | .94 | .0130 | 648 |

**Derivation:** `E[gear/h]=NormalKills×0.003+EliteKills×0.04+BossKills×0.35`. For M: `360×0.003 + 3×0.04 + .25×0.35 = 1.2875 gear/h`. Fragments similarly `360×.001+3×.02+.25×.20=.47/h`; fully-authored manuscript `0+3×.0005+.25×.02=.0065/h`. Common material `360×.6×1.5=324 units/h`. Do not confuse materials stacks with unique equipment items.
**Probability approx** given Poisson arrival assumption (not source behavior): `P(at_least_one_gear_in_one_hour)≈1−exp(−E[gear/h])` → **S≈33%, M≈72%, H≈92%**. This is a convenient rare-loot intuition, NOT a Monte Carlo or game QA measurement, and a scheduled Boss violates a literal Poisson assumption. Actual 24-hour throughput depends on actively deployed disciples, medicine, camp respawn, risk, player speed setting and total simulated time; 24sim-hour row is an **upper straight-line multiplication of a sustained rate**, not a promise of 24h farming.
If 30 disciples on one map achieved M: gear per 12 sim hours at 100% equivalent = ~15.45; common material ~3,888. These values signal a **potential warehouse/equipment saturation** problem after days of autonomous farming; salvage/crafting/upgrading, reserve/lock and equipment distribution need sinks. Neither “gear 1.29/h” nor “material324/h” can be locked before seeing real kills/h and original economy outputs.

### 5.3 Supply-and-demand diagnostics, not invented final balance
- For each source material m and gear family g, gather `K_{species,camp,tier,realm,grade}(hours)` from real hits/kills, death pressure, respawn and recovery; model `E[inflow_m] = Σ K×P_m×E[quantity|drop]` and compare to `E[outflow_m] = actual forge/medicine/upgrade/build/market consumption`.
- Material can have **multiple sources** (Mine/Forest/Field vs Hunt); distinct ResourceRegistry IDs avoid a fake “material power” wallet. Do not overvalue farm drops that already exist at X100 production scale; use real relative value and required sinks.
- Track per 1, 7, 30 **sim days** (sim day from canonical tick owner), scenarios 3/10/30 active hunters and 200/300/400 live mobs. Include backpressure on loot roll receipts, unique item counts, manual completion progress and Sect-owned sets. Daily personal Tu Vi must be tied to true source; avoid unapproved free direct kill XP or autofarm exploit.
- Equip economy sinks: assign items to 30 active disciples (up to300 ordinary positions), store spare roles/sets; forging uses real materials, upgrading consumes true registered inputs, salvage old nonreserved gear through approved recipes only, not endless material duplication. At 1,000–3,000 Sect members, gear allocation must be batch/auto policy, not manual popup after every kill.
- Fast farm on weak monsters can flood ordinary low-tier materials, but should not produce rare high-realm Chí Tôn equipment because gear grades and realm eligibility tables exclude it. Monster weakness doesn't force zero common drops; Tu Vi diminishing returns on extreme level gap is a separate proposed personal progression rule, not global material penalty.
- Avoid mandatory Boss/event farming for every profession supply unless alternate sane source exists; no inaccessible recipe/missing registry ID softlock. Evaluate rare-manual completion distribution separately, especially first complete book archived permanently in Tàng Kinh Các.
- Roll frequencies should be tuned to *valuable gear per hour per map* and *sets reasonably obtainable* rather than blindly copy JX original drop percentages, which have NOT been verified.

### 5.4 Parameter sensitivity to review with owner
- Increase normal gear roll from .3% to .6% doubles normal source gear/h; e.g at 360 normal kills/h baseline normal contribution rises 1.08→2.16 gear/h. New total (with Elite/Boss unchanged) = **2.3675 gear/h**. This is not a minor rarity cosmetic change.
- If time/medicine makes real kills/h only half M, gear/material inflow from normal halves, but Elite/Boss must be separately recalculated (don't halve Boss by convenience).
- 400 alive mobs does **not** imply 400 kills/h. Live population is an occupancy target; kill/h is a function of AI actions, kill-time, respawn delay, overpull, deaths/retreat and travel. Inventory balancing cannot substitute `live_count` for kill count.

## 6. Important uncertainties / approvals required before coding
- Exact species-to-material tables, whether generic Trúc Thử also drops current `thanh_linh_thao` directly, and whether current `linh_tuy` ever drops from one normal (current source is per-four-victory bonus) — **UNDECIDED**.
- Normal/Elite/Boss **actual** gear event %, manual fragments and complete manual %, conditional item grade 1..12 distributions, slot distributions, equipment realm restrictions, amount of unique sets/gear per day, rare guarantees, salvage economics.
- New 7 element species IDs/Source A visual rig availability and corresponding registered resources, enemy skills and behavior consumers; Hỏa Elite from other region only if owner changes regional event pool.
- World map difficulty1..5 and Boss event frequency denominator, per-camp vs map-wide and Elite slot substitution policy; no per-encounter 26% rare automatically ported to all monster kills.
- Personal Tu Vi/Stone/Contribution source and participant allocation, 60/40 ratio not locked. Loot item Sect-owned even when last hitter different; combat role DPS/tank/healer/support contribution evidence must be actual.
- Workload profiling/actual kills/h, 200→400 mobs, 30 active disciples, Android landscape Godot4.7.2. No actual Windows/Android PASS for World V3.

## 7. Future test fixture contract (NOT RUN)
B01 registered source identities; eligible sources produce only registered resources and unique gear templates with valid 10-slot/12-grade/same-set/generation rules.
B02 normal wood Trúc Thử vs a Metal elite produce distinguishable pools under identical RNG seed namespace; rare eligibility follows authored source, not attacker skill.
B03 300 live mobs and 30 disciples on separate camps; per-kill loot count, items/h and kill/h logged by species/realm/tier/element/camp, no camera dependency.
B04 two disciples and DoT finish same wolf during same canonical tick; one kill decision, one Warehouse receipt, one unique gear item at most per approved gear roll.
B05 save after HP0 before roll, roll before deposit, deposit before ACK and before respawn; same frozen materials/gear IDs, no quickload re-roll or double payout.
B06 a new species without registered `loot_profile_id` or ResourceRegistry item fails closed visibly; no fake coins or nil item.
B07 a tier-1 low-monster kill cannot generate a higher equipment realm or max grade unless an explicitly approved unique exception source is installed.
B08 current finite victory payout and new world per-kill route are mutually exclusive; guaranteed Ling Tuy every four old victories isn't copied as four monster kills.
B09 sim economics 3/10/30 deployed, 200/300/400 world mobs with 1/7/30 sim days, stop/open item inflation and impossible recipes with recorded actual source outputs.
B10 boss HP shared across many teams; Boss event one loot pool, crew credit derived from actual DPS/tank/heal/support and no last-hit bonus duplication.
B11 no overflow stop for ordinary infinite-cap warehouse; only safe integer and valid templates/reserve/lock rules.
B12 Source A/Minimap show loot on committed receipt only; camera pan and offscreen don't change roll or loot, despite visual effect LOD.

**End:** deep design of loot rules and numerical *sensitivity examples* only. Not all ID rows exist, no new game code/loot table/QA. No PR29/UI/Source A touch, no merge, no Codex packet. Next owner task is to review source species + conditional loot pools, then build a complete approved minimal one-camp actual kill→material/gear→warehouse vertical-slice contract **only if separately authorized to prepare it**.
