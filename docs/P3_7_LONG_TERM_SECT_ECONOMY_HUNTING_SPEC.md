# P3.7 — LONG-TERM SECT ECONOMY, PROFESSIONS & HUNTING SPEC

Status: CANONICAL DESIGN AUTHORITY  
Date: 2026-10-05

This document is the canonical authority for the long-term management direction agreed with the user after reviewing the current playable slice and reference gameplay.

Do not simplify this back into a short "mine -> iron -> upgrade" loop. The target is a long-running sect simulation with 1,000–3,000 disciples, a hunting-centric economy, autonomous disciple growth and a deep but low-micro management layer.

---

## 1. Core identity

Tông Môn Bá Đạo is primarily:

**a hunting/cultivation sect simulation with a living economic rear base.**

Long-term target population:
- 1,000–3,000 disciples;
- only a limited visible subset is rendered on the live Godot map;
- most disciples are managed through teams, halls, assignments, policies and AI;
- the player may directly intervene in important individuals.

Target labor split:
- roughly 70% hunting / expeditions / outside activity;
- roughly 30% rear-base production, healing, logistics, cultivation services and commerce;
- this ratio is a policy target, not a hard invariant.

The player is the Sect Master, not a worker-clicking RTS controller.

---

## 2. Player control hierarchy

1. Sect-wide policy.
2. Hall/team/group assignment.
3. Long-term disciple role/profession assignment.
4. Direct order for exceptions or important disciples.
5. Survival AI always overrides suicidal commands.

Disciples may have preferences and propose choices, but the Sect Master retains final authority.

---

## 3. Hunting is the main outward gameplay

Default hunting is autonomous.

The player chooses:
- team;
- region;
- target type;
- risk posture;
- retreat threshold;
- supply policy.

Standard team size:
- 5 disciples.

Some traits may support solo play:
- Cô Tinh;
- Độc Hành;
- Sát Tinh;
- future equivalent traits.

Soloing may grant specific advantages but carries higher risk.

No permanent disciple death in the current design.

Failure generates **Thương Thế** instead.

### Thương Thế

Range: 0–100.

Conceptual bands:
- 0–20: light injury;
- 21–50: meaningful combat penalty;
- 51–75: cannot normally depart;
- 76–100: severe injury, requires substantial recovery.

Exact thresholds are balancing data, not immutable constants.

Recovery:
- rest;
- medical hall;
- pills/medicine;
- sect buffs;
- later specialist healing systems.

---

## 4. Hunting costs

Hunting does not require an arbitrary entry fee.

Natural costs:
- time;
- stamina;
- medicines/pills consumed;
- equipment durability;
- injury risk;
- team travel time;
- later logistics/supply capacity.

---

## 5. Hunting rewards

Hunting may directly drop:
- cultivation EXP / Tu Vi reward;
- Spirit Stones;
- monster materials;
- Monster Cores / Yêu Đan;
- equipment;
- pills;
- techniques;
- talismans;
- rare items;
- treasure fragments;
- sect-treasure fragments;
- encounter/opportunity rewards.

Do not over-rationalize why monsters drop Spirit Stones. Gameplay clarity is more important.

Weak monsters may still drop loot, but cultivation reward should diminish sharply when the power gap is extreme.

---

## 6. Hunting inventory model — no giant personal inventories

With 1,000–3,000 disciples, every disciple must NOT have a full RPG inventory.

A disciple owns only:
- equipped gear;
- personal Spirit Stones;
- Contribution Points;
- a very small consumable/loadout allowance;
- personal state and progression.

Hunting does **not** use a secondary loot warehouse or persistent reward bag.

When an encounter resolves:
- item/material loot -> main Sect Warehouse immediately;
- sect Spirit Stone share -> sect economy immediately;
- personal Spirit Stone share -> participating disciples immediately;
- Tu Vi / Contribution / combat or hunting progression -> participating disciples immediately.

The team's carried inventory is only an outward **supply loadout** (medicine, pills, talismans, food, emergency items). It is not used to store hunting rewards.

---

## 7. Loot settlement and ownership

Default concept:
- most raw material loot is sect property;
- a configurable share of Spirit Stones becomes personal team income;
- rare equipment enters the main Sect Warehouse as sect-owned property;
- hunters receive Contribution Points for bringing valuables home.

Sect policies may later define the split.

Example policy:
- 60% Spirit Stones to sect;
- 40% divided among participants.

High sect cut:
- enriches sect;
- slows personal disciple growth;
- may reduce satisfaction.

High personal share:
- disciples buy better services/equipment and progress autonomously;
- sect treasury grows more slowly.

This is intended management gameplay.

---

## 8. Equipment distribution

Default: policy-driven automation.

Possible rules:
- hunters have priority;
- higher combat need has priority;
- Inner Disciples receive discounts;
- Direct Disciples receive free allocation;
- ordinary disciples exchange Contribution Points or Spirit Stones.

The Sect Master may directly grant/lock equipment for important disciples.

Do not require manual equipment management for thousands of disciples.

---

## 9. Disciple growth has several independent axes

A disciple can grow through:

1. Cultivation realm.
2. Profession levels.
3. Combat skills / techniques / mastery.
4. Equipment and treasures.
5. Personal wealth.
6. Contribution Points.
7. Relationships / traits / future life history.

Realm and profession are not the same thing.

A low-realm legendary farmer/miner/crafter must be possible.

A high-realm cultivator may still perform low-tier work if desired.

Prefer soft economic inefficiency over hard content locks.

---

## 10. Profession system

Target:
- profession levels may exceed 100 and can reach 1,000+;
- profession levels never decay;
- each profession level grants +1% base profession efficiency;
- EXP requirement increases every level;
- very high profession levels become progressively harder.

Basic efficiency:
**Profession multiplier = 100% + profession level × 1%.**

Examples:
- Lv.1 -> 101%;
- Lv.100 -> 200%;
- Lv.500 -> 600%;
- Lv.1000 -> 1100%.

Final production still also depends on building, condition, tools, buffs and material/process constraints.

---

## 11. Profession talents

Profession talent should primarily accelerate **profession EXP gain**, not simply hand out huge instant output.

Example:
**Khoáng Mạch Thân Hòa**
- Mining EXP +80%;
- possibly a small rare-resource bonus.

This produces long-term specialists naturally.

Two disciples may start at the same Mining level but diverge greatly after years of work.

---

## 12. Profession specialization milestones

High profession level must not be only +1% repeated forever.

Professions also have **specialization milestones**.

Example Mining milestones:
- Lv.10: small rare-ore discovery bonus;
- Lv.50: lower stamina cost;
- Lv.100: improved material quality;
- Lv.250: detect hidden veins;
- Lv.500: access special mining phenomena;
- Lv.1000: legendary grandmaster effect.

Exact milestones differ by profession.

Principle:
- breadth across many professions -> broad life/physical bonuses;
- deep specialization -> powerful profession-specific advantages.

---

## 13. Broad profession experience can strengthen the disciple

Working should not create permanently weak disciples.

A disciple may gain small general bonuses from accumulated profession milestones, for example:
- HP;
- DEF;
- ATK;
- stamina;
- other modest universal bonuses.

This is **Bách Nghệ Lịch Luyện**.

It must remain secondary to cultivation/combat progression, but enough that a disciple with a long working life feels seasoned rather than wasted.

---

## 14. Unified cultivation rate model

Every disciple has a **Base Cultivation Rate** expressed directly as Tu Vi per time unit.

Example:
- Base Cultivation Rate = 100 Tu Vi/hour.

This rate comes from:
- spiritual root;
- realm;
- technique;
- physique;
- bloodline;
- sect-wide cultivation buffs;
- other authority systems.

Activities apply clear modifiers.

Conceptual examples:
- focused cultivation: around 100% of base;
- working: significant passive portion, roughly 30–40% starting design;
- resting: lower passive portion plus recovery;
- secret chamber: strong multiplier in exchange for personal Spirit Stones;
- hunting/travel: passive cultivation plus kill/encounter cultivation rewards.

UI should preferably show the resulting value directly:
**+43 Tu Vi/hour**
rather than forcing players to calculate hidden percentages.

Exact rates require balancing and are not locked constants yet.

---

## 15. Workers must not become obsolete cultivators

Working gives:
- profession EXP;
- passive Tu Vi;
- wage / Contribution Points / personal economic value;
- chance of profession insight;
- broad life/profession milestone progress.

A worker can later spend personal Spirit Stones on:
- Secret Chamber;
- pills;
- equipment;
- market goods;
- future auctions/services.

Thus:
**work -> wealth/profession -> self-investment -> combat/cultivation growth.**

Focused cultivators gain realm faster but produce less economic value.

Hunters gain loot and combat/cultivation progression but pay risk and consumption costs.

These are different viable life paths.

---

## 16. Secret Chamber / Mật Thất

Secret Chambers are paid cultivation services.

They are not automatically free just because a disciple belongs to the sect.

A disciple may pay personal Spirit Stones for a stronger cultivation multiplier.

The Sect Master controls:
- price;
- discounts;
- priority;
- free access for selected statuses;
- later capacity policies.

Possible policy examples:
- ordinary disciple: full price;
- Inner Disciple: 20% discount;
- Direct Disciple: 80% discount;
- Elder: free.

Disciple AI chooses whether to spend based on personality, habits, wealth and goals.

The player may override important individuals.

---

## 17. Personal Spirit Stone AI

Disciple AI may use personal wealth differently according to personality/habits.

Examples:
- ascetic -> Secret Chamber, pills, techniques;
- battle-mad -> equipment, medicines, hunting supplies;
- hedonistic -> tavern/services/luxury;
- frugal -> saves;
- treasure-seeker -> auctions/items.

The Sect Master may impose restrictions or priorities.

---

## 18. Rear-base profession families

The rear economy must expand well beyond six jobs.

Planned profession families include:

### Resource
- Mining;
- Spirit Farming;
- Forestry;
- Gathering.

### Crafting
- Artifact Refining;
- Alchemy;
- Talisman Crafting;
- Formation Inscription.

### Spirit beasts
- Taming;
- Rearing;
- Beast Medicine.

### Logistics
- Warehousing;
- Supply;
- Construction.

### Lifestyle/support
- Cooking;
- Brewing;
- Medicine.

### Commerce
- Trading;
- Appraisal.

### Cultivation support
- Teaching;
- Guardian duty.

### Exploration
- Monster Hunting;
- Exploration.

Not all professions are available at game start.

---

## 19. Resource model — explicit identity + realm/tier

Resources remain distinct item identities.

Examples:
- Thanh Linh Thảo;
- Huyền Thiết;
- Yêu Đan.

Each resource has:
- explicit ID/name;
- family/tags;
- realm/tier;
- quantity;
- source/usage/market data.

There is no continuous Phẩm Lực value.

Higher progression unlocks higher-tier resource IDs rather than converting all materials into one hidden power number.

---

## 20. No hard disciple-realm work lock

A high-realm disciple may perform low-tier work.
A low-realm disciple with strong profession mastery may perform difficult work when the facility/content permits it.

Do not hard-block normal work simply because the disciple realm is below the resource realm unless lore/physics explicitly requires it.

Prefer explicit:
- required profession level;
- building level;
- recipe/crop unlock;
- more time/cost/risk where appropriate.

---

## 21. Material upgrading/refinement

Low-tier materials may be processed into higher-tier named resources only through explicit recipes.

Example:
- many Thanh Thiết + cost -> fewer Huyền Thiết;

if such a recipe exists.

Do not use a generic PL conversion pool.

---

# 22. BUILDING CONSTRUCTION RESOURCE AUTHORITY

This section is the current proposed common rule for all normal buildings.

The goal is to avoid each building level requiring a unique shopping list.

## 22.1 Three universal construction inputs

Normal building construction/upgrades primarily consume:

### A. Linh Mộc
Structural wood / organic construction resource.

Sources:
- forestry;
- gathering;
- later monster/rare plant sources.

### B. Khoáng Liệu
Structural mineral/stone/metal resource.

Sources:
- mines;
- hunting;
- exploration.

### C. Linh Thạch
Money + construction energy + formation activation cost.

This is both an economy sink and a cultivation-world construction resource.

These three are the universal base.

---

## 22.2 Construction uses explicit quantities

Building requirements use:
- explicit resource families/IDs;
- explicit quantities;
- Spirit Stones.

Example:
- 120 Linh Mộc;
- 80 Thanh Thiết;
- 500 Spirit Stones.

Higher construction tiers may require higher-tier named resources.

Warehouse reserve/lock rules protect valuable materials.

Do not convert unlike materials into one hidden construction-power value.

---

## 22.3 Building-specific specialty material only at milestone upgrades

Ordinary levels use:
- Linh Mộc;
- Khoáng Liệu;
- Linh Thạch.

Major milestones may require one thematic specialist component.

Examples:

### Spirit Field
Milestones may require:
- Linh Tuyền;
- Spirit Soil;
- formation component.

### Mine
Milestones may require:
- exploration formation core;
- reinforcement component;
- special drilling/refining part.

### Alchemy Hall
Milestones may require:
- furnace core;
- Fire Essence;
- medicinal formation component.

### Artifact Hall
Milestones may require:
- furnace core;
- special metal;
- Fire Essence.

### Secret Chamber
Milestones may require:
- Formation Core;
- spirit-jade / energy-conducting material.

### Beast Hall
Milestones may require:
- Beast Core;
- taming formation component.

The specialty item exists to make milestone upgrades memorable, not to create dozens of routine currencies.

---

## 22.4 Construction progression

Normal building level range:
**Lv.1–100.**

Routine levels increase a combination of:
- efficiency;
- local storage;
- process capacity;
- quality/success chance;
- automation;
- facility power;
- minor operational parameters.

Milestone levels unlock meaningful mechanics.

Conceptual milestone cadence:
- Lv.10;
- Lv.20;
- Lv.30;
- Lv.50;
- Lv.75;
- Lv.100.

This cadence is design data and may vary by building.

---

## 22.5 Scale comes from more buildings, not Lv.8,000 mines

Building level does not need to be infinite.

Default cap:
**Lv.100 per instance.**

Scale long-term by increasing the number of facilities.

Example:
- initial cap: 10 Spirit Fields;
- when all 10 reach the required mature/max condition plus sect requirements, unlock Spirit Field #11;
- later #12, etc.

This supports thousands of disciples without absurd single-building levels.

Individual facilities may specialize:
- herb field;
- grain field;
- spirit-flower field;
- rare medicine field.

---

## 23. Building categories planned

Core:
- Main Hall;
- Warehouse;
- Disciple Residence;
- Spirit Field;
- Mine;
- Spirit Forest;
- Cultivation Platform;
- Secret Chamber;
- Medical Hall.

Production:
- Alchemy Hall;
- Artifact Hall;
- Talisman Hall;
- Formation Hall;
- Kitchen;
- Brewery.

Beast/logistics:
- Spirit Beast Hall;
- Beast Pens;
- Supply Hall;
- Transport/warehouse extensions.

Economy/life:
- Market;
- Tavern;
- Flower House;
- luxury/leisure services;
- auction functions later.

World/combat:
- Sect Gate;
- Hunter Hall;
- Expedition Hall;
- future mission/intelligence facilities.

The canonical detailed building tree is defined in `docs/P3_7_BUILDING_TREE_SPEC.md`.

---

## 24. Sect Treasures / Chí Bảo

All owned sect treasures may contribute their effects.

Do NOT force the player to activate only 3–5 and leave the rest useless.

UI should aggregate the total effects.

Possible effects:
- all-disciple damage;
- HP;
- DEF;
- cultivation rate;
- profession EXP;
- production;
- market income;
- hunting loot;
- rare discovery;
- healing;
- travel.

Duplicate treasures/fragments may improve **Cộng Minh** or equivalent growth rather than becoming trash.

---

## 25. Sect Level

Sect Level represents organizational scale, not direct raw combat power.

It can govern:
- disciple capacity;
- hunting team capacity;
- land;
- building count limits;
- accessible world regions;
- market scale;
- policy sophistication;
- reputation;
- branch-sect capability;
- visitor/merchant quality.

Do not make Sect Level simply "+X% ATK".

---

## 26. Building scale and 70/30 economy

Rear base roughly supports the hunting majority through:
- pills;
- medicine;
- equipment;
- talismans;
- formations;
- food;
- spirit beasts;
- carrying capacity;
- healing;
- Secret Chambers;
- commerce;
- storage/logistics.

Hunters return:
- Spirit Stones;
- monster cores;
- monster materials;
- rare items;
- treasure fragments;
- techniques;
- opportunities.

The two halves feed each other.

---

## 27. Locked design principles

1. 1,000–3,000 disciples are allowed.
2. The player never manually manages thousands of full inventories.
3. Team/group/policy automation is mandatory.
4. Standard hunting team is 5; solo traits can override.
5. Combat defeat does not permanently delete a disciple; injury is the normal combat loss state. Lifespan expiry follows the separate Ma/Hồn persistence rule.
6. Hunting consumes natural resources/time/durability/medicine.
7. Hunting is a primary progression/reward source.
8. Work also develops the disciple.
9. Professions can reach 1,000+ and do not decay.
10. Every profession level grants +1% profession efficiency.
11. Profession EXP requirement rises with level.
12. High profession milestones add specialization effects.
13. Sect members gain passive cultivation even while working; exact balance comes later.
14. Secret Chambers consume personal Spirit Stones and strongly accelerate cultivation.
15. Personal AI spends money according to personality/habits; Sect Master may intervene.
16. Equipment distribution is policy-driven with manual override.
17. Resources use explicit IDs, realm/tier and quantity; there is no continuous Phẩm Lực.
18. Higher progression unlocks higher-tier named resources.
19. High-realm disciples may do low-value work; low-realm profession masters may perform difficult work if capable.
20. Buildings use a common construction language and cap around Lv.100 per instance.
21. Long-term scale comes from more facilities, teams, land and disciples.
22. All Sect Treasures may contribute; no tiny active-slot limit.
23. Hunting/outside activity is the main long-term direction; rear economy exists to support and profit from it.

---

# 28. CHILD AUTHORITY MAP

This parent spec owns only the high-level long-term sect-economy direction.

Use the child specs for concrete subsystem rules:

### Buildings
`docs/P3_7_BUILDING_TREE_SPEC.md`

Owns:
- building families;
- Lv.1–100 behavior;
- worker/capacity rules;
- milestone mechanics;
- building dependencies.

### Resources / warehouse / base growth
`docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`

Owns:
- resource identity;
- realm-grade metadata;
- realm/tier + quantity;
- one canonical Sect Warehouse;
- stack/reserve/lock semantics;
- passive cultivation;
- six-foundation integration;
- home self-investment.

### Time / movement / work cycle
`docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`

Owns:
- movement speed;
- attack speed;
- work speed;
- cast time;
- cooldown;
- construction duration;
- recovery/downtime;
- physical work cycles.

### Disciple loadout / hunting progression
`docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`

Owns:
- scalable personal loadout;
- item ownership;
- autonomous equipment choice;
- Contribution;
- monster realm/reward scaling;
- hunting cultivation targets.

### Disciple lifespan
`docs/DISCIPLE_LIFESPAN_CANON.md`

Owns:
- lifespan expiry;
- Ma/Hồn persistence;
- longevity/revival effects;
- roster-removal semantics.

Implementation progress does **not** belong in this design spec.
Read `CURRENT_CHECKPOINT.md` for current runtime status.

---

# 29. LOCKED CROSS-SYSTEM CORRECTIONS

## Hunting reward routing
- no Loot Warehouse;
- no persistent Team Loot Bag for rewards;
- ordinary item/material rewards go directly to the main Sect Warehouse when generated;
- personal Tu Vi, Contribution, mastery/progression and personal Spirit Stone share are granted directly to the participating disciple;
- carried team inventory outside the sect is for supplies/logistics only.

## Lifespan persistence
- lifespan expiry does not delete the disciple record;
- the disciple transitions to Ma/Hồn state;
- roster/history/relationships remain;
- valid longevity/revival effects may restore life;
- only expulsion removes the disciple from the sect roster.

## Warehouse
- no gameplay storage-capacity ceiling;
- resource IDs remain distinct;
- there is no continuous Phẩm Lực system;
- P3.7 uses one canonical Sect Warehouse for stackable resources.

## Phase discipline
- design specs define mechanics;
- implementation status lives only in `CURRENT_CHECKPOINT.md`;
- only one gameplay implementation phase may be active at a time.
