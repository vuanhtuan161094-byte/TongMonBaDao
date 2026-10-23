# TÔNG MÔN BÁ ĐẠO — THIẾT KẾ TỪ GỐC: PHÂN LOẠI NỘI DUNG, LUẬT RƠI ĐỒ, RÈN, ĐAN, CÔNG PHÁP VÀ KINH TẾ

**2026-10-23 — FOUNDATION DESIGN / DOCS ONLY / OWNER OPTIONS PENDING.**
**Branch:** `docs/mainline-governance-content-foundations-20261023`, **created from main SHA `29b5fba448b0178cb520a4ada44b375b4b934e31`**, no code/CI/merge; PR #24/#25, MASTER RECOVERY local writer untouched.  
**Why this doc:** Stop inventing per-realm sword, pill, boss, technique and probability spreadsheets without a stable world-content taxonomy, economy loop, provenance, authoring grammar and source-specific drop definitions. **This is a design framework, NOT automatic procedural creation of 300 stages or authoritative gameplay.**  
**Read first:** `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `docs/WEAPON_EQUIPMENT_V2_SPEC.md`, `docs/EQUIPMENT_SETS_V2_SPEC.md`, `docs/TECHNIQUE_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`, `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`, `docs/REALM_LADDER_V2_SPEC.md`; later owner decisions X0/X1 and actual P2/CARE source. This doc must not override any LOCKED gameplay.

## 0. Three design levels, in the CORRECT order

1. **LAW / TAXONOMY**: what kinds of game entities exist, what makes one different and what mechanics consume them? Locked contracts first. Examples: equipment 10 slots +12 grades + realm tier, technique grade Phàm/Huyền/Địa/Thiên/Tiên/Thần, Sect archive, distinct Combat Skills, named rank/Body families, source-specific monster/zone tags, item UID versus stackable resource.
2. **CATALOG / CONTENT GRAMMAR**: which finite **authored** families/templates/techniques/recipes exist? Each item has a job, identity and rarity source. A unique recipe or named spell is never created merely by appending realm rank to a string. Define family → role → element/style → genuine real consumer → rarity/rarity exception → source, then author individual content.
3. **ECONOMY / BALANCE**: what chance, input counts, recipe time and output do ACTUAL source+sink pairs need so players can progress and rare finds remain rare? Run sourced/simulated time-to-first-completion and percentile checks; lock values only after owner review.

**Wrong earlier method:** create dozens of names and numeric bonuses for all R04–R10 before defining source/consumer/rarity and economic time budget. **Therefore** previous X1/X2 item tables are **working candidates requiring review, NOT a canonical/generated item system**. Preserve user-locked X1 D2/3/4/5, S2/F1/Q1, but do NOT silently promote other X1/X2 invented item IDs and rates to game authority. Where owner-approved rates exist (e.g. X1 R02/R03 normal ore/hide), retain as approved *pilot assumptions/policies for those sources*, requiring real runtime source registration and balancing against true kill throughput.

## 1. Universal content identity — separate dimensions

| Axis | What it means | What it does NOT mean |
|---|---|---|
| `cultivation_realm_index` 1..30 and `floor`1..10 | Character realm/level; Combat V2 Core and breakthrough | Equipment grade or technique rarity |
| `body_realm_index` 1..30 and own floor | Independent Luyện Thể progression and gates | Automatically equals Tu Vi |
| `content_tier` / `equipment_realm_index` 1..30 | Recommended source difficulty and author-defined gear family/equip rank | Make a named rank1 item multiply across 30 ranks |
| `equipment_grade_id` 1..12 | LEGAL normal/special/Chân Văn capacities | Item realm; grade12 impossible from basic forge |
| `technique_grade` | six V2 grade categories, rarity/depth/complexity | A direct realm requirement or ×damage factor |
| `skill_generation` | Nhân/Tiên/Thần **successor families** | A new skill kit automatically granted every realm |
| `acquisition_origin` | normal/elite/Boss, unique location, Secret Realm, research, inheritance, shop, profession | Generic global loot from any monster |
| `effect_tags`/`role`/`element` | Real CombatV2/work/learn consumer and build synergy | A generated new combat stat with no code |
| `item_type` | material stack / unique equipment / manual archive / fragment / pill / blueprint / currency receipt | All stack into one `ResourceRegistry` item automatically |

**Canonical existing locks**:
- Ordinary gear 10 positions; 3 Phù+2 Pháp Bảo separate; 4 medicine-loadout positions; Sect owns all unique gear; 12 quality capacities; 24 four-piece set lineages with cumulative 2/3/4 and allowed 3+3; three generations. Gear baseline budget S2, targeted forge F1 and affix-led quality Q1 owner selected.
- `TECHNIQUE_V2_SPEC.md`: learned many, 1 main/2 auxiliary active, five personal mastery stages, archive once in Tàng Kinh Các then deterministic Sect teaching, successor `Diễn Hóa`, special discovery and `Khắc Lục`; duplicates/conflicts handled by unique family. Grade is not multiplied into power.
- `COMBAT_SKILLS_V2_SPEC.md`: skills independent of Công Pháp; different training/moves, 3 generational waves; one learned technique does NOT automatically grant a complete move set.
- One Warehouse, one unique-item Sect registry, single authoritative Combat V2 kill+loot receipt/clock/SaveService; no reward bag and no content spawned by UI.

## 2. Công Pháp — build a **family catalogue**, not a flat list of arbitrary chances

### 2.1 A finite *AUTHORED* content template schema

Every Công Pháp definition requires:
```yaml
technique_id: "authored_stable_id"                 # UNIQUE never regenerated per loot
family_id: "named_origin_lineage"                  # successors and conflict key
grade: pham|huyen|dia|thien|tien|than
path: sword|body|spell|...                         # allowed tags from actual game
role: growth|offense|defense|stability|support
element: metal|wood|water|fire|earth|none
core_identity: "one clear, distinct use-case"
passive_source_ids: ["real V2 consumers only"]
acquire_sources: [{source_id: "real/boss/secret/sect_research", pool_id: "authored"}]
source_exclusivity: world|region|monster|boss|secret|research|inheritance|none
fragment_item_id: "actual_registered_id_or_BLOCK"
fragments_for_archive: "OPEN authored threshold"
archive_once: true
teach_prerequisites: ["authored conditions"]
mastery_milestones: ["So Hoc", "Nhap Mon", "Tieu Thanh", "Dai Thanh", "Vien Man"]
active_effect_conflicts: ["family/unique_key"]
successor_technique_id: "authored ID or null"
ui_flavor: "text that matches actual effect"
status: PROPOSED|SOURCE_P2|OWNER_LOCKED|LIVE_V2|FOCUSED_PASS
```
This is a **future schema proposal**, NOT live Godot tables. A source-specific book cannot be in a generic normal pool unless explicitly authored. The archive may let all eligible disciples study a unique book after it is acquired; drop rarity controls **first acquisition/collection**, not repeated learning per disciple.

### 2.2 Quantity of catalog items vs rarity of each drop: TWO unrelated decisions

The owner's example "Phàm 3 công pháp, Thần 10 công pháp" is an excellent *candidate catalog structure*, **not locked numeric canon**. Possible first authored collections:

| Choice | Phàm | Huyền | Địa | Thiên | Tiên | Thần | Total content definitions | Review tradeoff |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| **C1 Compact (recommended PILOT framework)** | 3 | 4 | 5 | 6 | 8 | 10 | **36** | 36 meaningful identities to balance; God-tier diversity even if very rare; may need later expansion for 1000+ disciples |
| **C2 Mid** | 3 | 5 | 7 | 9 | 12 | 15 | **51** | more paths and longer content authoring/QA; less duplicate books |
| **C3 Rich** | 5 | 8 | 12 | 16 | 20 | 24 | **85** | rich exploration, high cost of consumer-backed effects and art/QA, avoid until C1 playable |
| **C4 Role-balanced quotas** | owner's total to choose | | | | | | not yet numeric | demand-driven by sword/body/spell & growth/offense/defense/support rather than monotonic grade counts |

**Critical:** 10 Thần titles does NOT mean a Thần title is ten times easier to obtain than a Phàm title. Total *eligible pool chance* and *within-pool book weight* are independently authored. Endgame rare title may exist in only ONE specific Boss/Secret Realm, with zero chance elsewhere. Rarity ≠ power formula ≠ realm.

**Current P2 provenance:** `TechniqueSystem.TECHNIQUES` currently contains six legacy P2 books: `duong_khi_quyet`, `huyen_giap_cong`, `liet_chien_quyet`, `thanh_phong_kiem_quyet`, `xich_viem_chan_quyet`, `han_nguyet_tam_phap` with old `gacha_weight=38,20,18,10,9,5`, summing to 100 in that old gacha context. **These are not monster drop percentages, nor a V2 six-grade catalog**: old P2 only has common/mysterious/earth/heaven; V2 Tiên/Thần are not present in this P2 list. Preserve old saves and provenance; do not auto-convert gacha weights to X2 loot tables.

### 2.3 A concrete miniature example: three Phàm techniques (only one actual P2 identity)

| Provisional ID | Identity | Distinction | Status |
|---|---|---|---|
| `duong_khi_quyet` Dưỡng Khí Quyết | growth / spell / wood | real P2 definition; **do not carry its level-% as V2 lock** | SOURCE P2 |
| `proposal_tuc_mach_cong` Tức Mạch Công | stable natural training; user-useful when a real cultivation source exists | hypothetical V2 consumer, numeric effect unknown | PROPOSED |
| `proposal_truc_anh_quyet` Trúc Ảnh Quyết | movement/stability utility with genuine time/travel consumer | hypothetical V2 consumer, numeric effect unknown | PROPOSED |

These three are a **C1 design illustration** only, not approved gameplay content. If the latter two can't identify a non-overlapping, implemented consumer, **DO NOT SHIP** them merely to fill the quota; devise distinct real mechanics or leave slots empty. Similarly the "10 Thần" group should FIRST allocate among role/path/element and source-exclusivity identities, and only then author ten effects—not create 10 arbitrary 10% multipliers.

### 2.4 Multi-stage exact drop probability, conditioned on the actual source

For a valid paid event and one eligible source:
```text
P(specific item per eligible event)
= P(manual/fragment-category payout | source_event)
  × P(grade | that_source + category)
  × P(item | grade + source pool, normalized author weights)

item_pool_weighted_selection:
 P(book_i | source, grade) = w_i / SUM(w_j for ELIGIBLE candidates ONLY)
```
- The event root can be **normal monster paid kill**, **Elite kill**, **ONE Boss death Sect loot**, **Secret Realm reward**, or **research completion**; don't mix into the same per-kill bucket or pay both legacy encounter-win and CARE paid-kill for one event.
- Example **PROPOSED ARITHMETIC ONLY**: a particular normal has category chance 4%, within it Phàm share80%, its three eligible books have conditional weights 50/30/20. Effective chance per legitimate kill: **1.60% / 0.96% / 0.64%** for those three books, total Phàm manuals3.2%, with the other 0.8% category event reserved for other eligible grades. **NOT a registered rate**, and full manual vs fragment distinction must be separately authored.
- **Exclusive**: a book tagged `boss_id=x` has **zero probability elsewhere**. A book tagged `secret_region=y` is never put in an ordinary map loot table. Multiple sources can be authored explicitly when intended, e.g. Boss full manual + normal fragment path, without turning rare full manual into general loot.
- For a pool of 10 Thần books, if a Boss eligible event's total chance of *any Thần book* is 1%, ten equal items are **0.1% per Boss** each; expected 1000 such kills *per specific book* if independent and no alternate source; this is likely an excessive chase for required progression. **Need special-source guarantees, pity/milestone, tradable/fragment paths or optional-only nature before locking**; none is auto-implemented.
- No global "Phàm must be 20% from every mob" or “Thần drops in any r30 boss at 0.2%”; every pool has explicit eligibility. Normal/Elite/Boss can share a grade category but have different legal book IDs and rates.
- A rare technique cannot be the **only mandatory gate** behind an inaccessible/rare Boss; alternative reasonable acquisition or a nonmandatory chase must be authored. Sect transmission of one acquired copy is a powerful source of progression; balance the acquisition around one Sect, NOT 1000 separate book copies.

## 3. Trang bị: compose from classification, not realm multiplier

### 3.1 Seven axes for each unique equipment template
1. `equip_slot` among 10 ordinary positions.
2. `weapon_family_or_armor_archetype` (sword/blade/spear/fist/staff/fan/pearl; heavy/light/robe; etc).
3. `item_family_id` AND `authored_template_id`: named identity, build/narrative/shape and actual Source A art availability; tier successors are **separate authored templates**, not merely a cloned low-tier sword `×1.65^r`.
4. `equipment_realm_index`1..30 and any Tu Vi OR Body track eligibility.
5. `grade_id`1..12 (ordinary/rare lines/Chân Văn capacities); source-dependent grade legal set.
6. `affix_pool_profile` A=general max2, B=skill/role/filter, C=profession/cultivation/work consumer. Only actual Combat V2/production channel.
7. `origin_tier` and `source_ids`: common ore/wood/hide F1 forge, Elite/Boss/Secret-specific blueprints or direct unique; set_lineage where allowed and **six set positions/24 sets** preserved.

**Equipment generation/design grammar PROPOSAL:**
```text
Author: choose realm content family → chosen role/style → ONE compatible slot/template
       → valid source & material genealogy → template base stats tied to authored realm power budget
       → legal grade/capacity + slot affix A/B/C pool
       → unique-origin override for Elite/Boss/Secret (still consumer-backed)
       → real recipe or direct-drop identity → econ/QA.
Generate at runtime: only deterministic instance rolls from APPROVED, FINITE, existing authored pools.
```
**Crucial:** a *design generation grammar* is for human/data authoring and content validation, **not random creation of new unreviewed monster/item/skill effects**. Item base stats can be calibrated to Combat V2 `Realm+Body` same-tier baselines but aren't all instances of one `Thanh Thiết Kiếm` multiplied across 30 ranks. The 24 set lineages should be reused with their already approved slot matrices, not 24 unrelated random sets per map.

**F1 example only:** a R02 approved Sword template is targeted in forge; legal recipe consumes exact ore/wood/hide quantities at a true worksite with one worker and one job; template guaranteed usable, quality from eligible `grade_table_id`, affixes from compatible slot/role pool, one unique Sect item UID, exactly one debit/result receipt. X1-approved **E0** pilot 75% Phàm /20% Tinh/5% Thượng applies to an E0 basic eligible recipe, **not globally** to higher BOSS or all 30 ranks. `S2` role-performance balance must be measured from sustained DPS/tank survival/heal contribution, not one arbitrary global stat formula.

**Distinct special types:**
- **Normal**: repeatable mine/hunt materials, forgeable baseline item.
- **Elite**: specialty affix pool or unique set fragment/recipe from a defined species.
- **Boss**: one Sect pool with named blueprints/set piece/unique item; drop eligibility names actual Boss/region/difficulty.
- **Secret Realm / achievements / Sect craft research**: exclusive authored recipes or item style unlocked by event; no Boss last-hit ownership.
- **Phù/Pháp Bảo**: separately owned slots, deferred until consumer implementation, never hidden in ordinary ten-slot arrays.

## 4. Đan dược and recipes: families tied to NEED, not one pill×realm

Medicines should be **families with actual effects**, not random names by rank:
- **HP recovery** / medical injury treatment (Injury 120 belongs to its own law).
- **Tu Vi fixed source** (Tụ Khí pilot +10,000 XP, 25 satiety; no Tư Chất multiplier).
- **Body XP** if explicitly authorized with a legitimate consumer.
- **Breakthrough material/catalyst** separate from generic EXP.
- **Lifespan/rare preparation** when appropriate canonical consumers exist.

Each output needs `pill_id, effect_kind, effect_amount, satiety_cost, true input ResourceRegistry IDs, recipe_id, building/profession gates, craft duration, source location/harvest, rarity, legal use rules, receipt`. Lower-tier pills may still be used at higher realms where authorized; they need not be inflated by a generic multiplier. Owner current medicine decisions: Hồi Xuân +55 HP cost10, Tụ Khí +10k Tu Vi cost25, shared **1,000,000 satiety/day/disciple**; X1 R02/R03 options **D5=A** owner approved as design but not live recipes. Never create fake all-purpose pill grade table disconnected from herb-source rates.

A medicine is **not authored** until its producer and consumer exist; competition with Body breakthrough herb/hide sinks must be included.

## 5. Economy foundation: a closed producer→consumer graph

Each content entry must connect:
```text
Sect time/work (real ticks, worker and job)
 + [Mine/Forest/Field] or [Normal/Elite/Boss/Secret PvE world]
 -> named resource/item/manual/fragment/blueprint drop
 -> canonical Warehouse stack or Sect unique instance/archive receipt
 -> [Forge F1 / Alchemy / Learn-Transmit / Gate / Construction / Sale]
 -> actual CombatStats/TuVi/Body/profession/world access & player goal
 -> upgraded hunt/work activity; Save+offline exactly once.
```
**No orphan source:** If a resource has no consumer, classify optional sell/collectible explicitly or mark **INCOMPLETE**. **No orphan sink:** If a required recipe/gate input has no repeatable source, it is **BLOCKED**. Do not fix shortages by granting unapproved free resources.

### Balance model at the level players feel
- `faucet[s,tier,source]`: honest expected stack/material items per **legitimate kill** or per **settled work cycle** (not per GUI frame or arbitrary hour). Grade-specific source and per-zone active availability.
- `sink[recipe]`: output count, item material ID/quantity, production tick/time, worker/profession/building eligibility, optional stones/contribution; anti-arbitrage and nonnegative stock.
- `population demand`: one actual role-balanced squad, 6-person team, 30-person mix, later 100/1000/3000 disciples; Sect gear-owned/shared lock semantics.
- `drop-probability budget`: sum of outcome shares normalized within source event, finite weight pools and exclusions; special boss source never double settles with normal per-kill code.
- `time-to-utility`: median/p90 time to first weapon, first useful pill, first book/skill for selected path, then a **full 10-slot** loadout, and actual stage-gate. Include injury/rest/One Active Job/other sinks, not just kills.
- `economic feasibility`: 24h/7d/30d **simulation-time**, with explicit worker, field plot, monster respawns, RNG seed, offline rules and consumption; compare low/normal/high kill rates and selected alternate source bottlenecks. No fabricated real hours.
- `rare source accessibility`: for an exclusive Boss book, expected attempts, P50/P90, recovery and alternative path; decide whether chase is optional and preserves player agency.
- `saturation`: no infinite free stacks/money from repeatedly selling/crafting; probability distributions for high-quality item cannot be financed by zero-cost basic ore alone.
- `UI truth`: if source/type/rate not yet live, tooltip must not imply the item can drop; no fake count from a design spreadsheet.

### Proposed **validator** before implementing large catalogs (requires separate future CODE authorization)
```text
For each realm/content family:
  - entity ID unique; correct enum and payload schema
  - referenced monster/region/recipe/material/pill/manual/item/skill actually registered
  - compatible realm/Body/weapon/slot/style, generation and grade tables
  - strict source eligibility and probability normalization; missing source = fail
  - at least one real consumer for mandatory acquisition
  - no mandatory progress through exclusive RNG-only path
  - no duplicate UID/kill/order/learning receipt after reload/offline
  - UI and Save use real IDs/status, no alternate reward owner
  - version-safe P2 migration (gacha weights != V2 drop probabilities)
```

## 6. WHAT TO WORK ON IN PARALLEL WHILE RECOVERY CODE IS RUNNING

| Track | Deliverable docs (one small research task) | May run at same time? | Evidence needed before numeric lock |
|---|---|---|---|
| **B0 — ROOT RULES** | THIS framework + owner chooses a **catalog architecture** (C1/C2/C3/C4) and source-specific loot model; links to existing V2 laws | **FIRST**, docs-only; unlocks later tracks | P2 sources+V2 owners, role coverage, each ID has legal consumer |
| **B1 — GEAR TAXONOMY** | 10 slot families/weapon archetypes, 24 real sets, affix A/B/C allowed-source map, template naming conventions, forge output conditions | **YES** after B0, no Godot edits | S2/F1/Q1, Combat V2 source channels, 1-6-10-slot benchmarks |
| **B2 — TECHNIQUE AND BOOK LOOT** | 6 rarity grades with catalog count candidates, path/role/element/unique identity quotas; source pools: normal/Elite/Boss/Secret/Sect research; manual vs fragments | **YES** after B0 | no P2 gacha weight transplanted, no mandatory exclusive RNG |
| **B3 — ECONOMIC FAUCETS/SINKS** | true market/profession/production baseline + material-family sources and sinks at R01–R03; scales to R04–R10 only after closure | **YES**, can audit in parallel, lock after B1+B2 | live production/kill logs (PR25/recovery), real worker/day/Body herb demand |
| **B4 — ALCHEMY AND SPECIAL MATERIALS** | five pill function families, known and proposed recipes, satiety and return on ingredient/time, Body gate source | **YES**, after B0, lock with B3 | actual crop/HP/gates, no second satiety rule |
| **B5 — BOSS CONTRIBUTION** | shared Boss credit/drop/stone split evidence, source exclusivity and anti-leech/retreat | **YES**, independent docs, no code | actual Combat V2 fixtures; 60/40 split still UNLOCKED |

**Do not:** keep authoring 7×12 item catalog rows just because a content roadmap says R04..R10, or spawn three new parallel CODE branches. **Current Codex recovery remains the only CODE writer.** This assistant can continue backend design/docs on short-lived branches rooted in current main and later rebase into the recovered main.

## 7. Three high-value OWNER CHOICES (only new choices, already-locked laws not repeated)

**O1 — size of first finite Công Pháp catalog:** `C1` **36** (3 Phàm, 4 Huyền, 5 Địa, 6 Thiên, 8 Tiên, 10 Thần) **RECOMMENDED as PILOT target**, `C2` 51, `C3` 85, or `C4` content budget by role and source with counts derived afterwards. This is catalog COUNT, not drop chance.
**O2 — special origin structure:** `P1` (recommended) **three layers**: repeatable normal source for mandatory basic fragments, Elite/Boss valuable named rare book/blueprint, Secret Realm/Sect research exclusive authored techniques with distinct acquisition paths; `P2` Boss-only for all high grade (high softlock risk); `P3` global rarity pool regardless of region (destroys targeted hunt).
**O3 — authoring order:** `A1` (recommended) one Phàm book trio + one distinct realm-tied ordinary gear family + one Boss-exclusive optional technique, followed by realistic 1-team source/sink and P90 acquisition checks; `A2` author all 36 techniques/30 realm gear series upfront then test; `A3` fully random generated abilities (contradicts finite authored consumers and V2 balance guardrails).

Assistant recommends **O1=C1, O2=P1, O3=A1** as a first **DESIGN** scope, not final fixed full-game cap. Owner may override later. Technique count, special source weights, high-rarity Boss odds and crafting rates must be explicitly approved before any CODE.

## 8. Concrete first research deliverable (this assistant, not Codex)

**B0-01**: build a three-book Phàm rarity pilot using `duong_khi_quyet` as verified SOURCE P2, plus two proposed identities only if real consumers exist; define source pools for 3 different paths, one rare conditional source and a precise chance tree `source→category→grade→id`. Link ONE E0 gear baseline and ONE actual R01 medicine receipt, to true warehouse/sect archive semantics. Validate no false V2 effects and no progression softlock. Then present exact options/drop tables to owner for selection before moving to Huyền/Địa/Thiên/Thần catalog. Never claim the two proposed techniques or 10 God books exist in code.

**Suggested next prompt (DOCS ONLY):**
```text
TÔNG MÔN BÁ ĐẠO — B0-01: THIẾT KẾ GỐC CÔNG PHÁP + NGUỒN RƠI, KHÔNG CODE.
Đọc AGENTS.md, docs/design/TMB_FOUNDATIONAL_CONTENT_TAXONOMY_AND_DROP_ECONOMY_FRAMEWORK_2026-10-23.md ở nhánh docs/mainline-governance-content-foundations-20261023, và canonical TECHNIQUE_V2_SPEC/WEAPON_EQUIPMENT_V2_SPEC/P3_7_LONG_TERM_SECT_ECONOMY. Phân tích ba cách xác định số lượng công pháp theo phẩm, archetype/path/role/element và nguồn đặc biệt, lập một mini-catalog Phàm + một đường Boss/Secret độc quyền, tính P(item)=P(category)×P(grade)×P(id|pool) có công thức và mô hình P50/P90 theo nguồn. Mọi tên mới/số mới phải gắn PROPOSED, không coi gacha P2 là drop rate V2. Gửi lựa chọn owner và commit Markdown lên nhánh docs mới từ main. Không chạm Codex recovery, PR #24/#25, không code/merge/FULL/CI.
```
