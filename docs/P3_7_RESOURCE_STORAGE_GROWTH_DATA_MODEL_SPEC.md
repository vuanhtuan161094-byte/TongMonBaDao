# P3.7 — RESOURCE, STORAGE & BASE GROWTH DATA MODEL SPEC

Status: CANONICAL DESIGN AUTHORITY / IMPLEMENTATION NOT STARTED  
Date: 2026-10-05

Parents:
- `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`
- `docs/P3_7_BUILDING_TREE_SPEC.md`
- `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`

This spec resolves the data-model decisions needed before implementation:
- clear distinct resource items;
- realm-grade resource progression;
- very large/unlimited sect storage;
- Phẩm Lực without averaging unlike items together;
- universal passive cultivation;
- six-foundation integration.

---

# 1. Resource items stay distinct

Do NOT merge different item identities into one generic "material power" pool.

The player must be able to see and understand real item identities.

Examples:
- Phàm Thiết;
- Thanh Thiết;
- Huyền Thiết;
- Hàn Tủy Thiết;
- Thanh Linh Thảo;
- Tử Vân Thảo;
- Huyết Linh Sâm;
- Yêu Đan;
- Giao Long Cốt.

Each resource definition has its own:
- resource_id;
- display_name;
- family/tags;
- realm_grade;
- base_pham_luc;
- stack_size;
- source tags;
- usage tags;
- market value;
- optional special properties.

Do not average unlike item identities together.

---

# 2. Realm-grade resource progression

Resources use a cultivation-flavored grade ladder for readability and long-term progression.

Example grade order:

1. Phàm phẩm;
2. Luyện Khí phẩm;
3. Trúc Cơ phẩm;
4. Kim Đan phẩm;
5. Nguyên Anh phẩm;
6. future realms appended from the canonical cultivation realm table.

This grade is a **resource/item grade**, not a hard permission lock.

Higher building levels, deeper hunting regions, better professions and harder encounters gradually expose new materials from higher realm grades.

Example metal family:

- Phàm Thiết — Phàm phẩm;
- Thanh Thiết — Luyện Khí phẩm;
- Huyền Thiết — Trúc Cơ phẩm;
- Tử Kim / equivalent — Kim Đan phẩm;
- future rare metals — later realm grades.

Names are content data and may change. The progression model is locked.

---

# 3. Phẩm Lực is continuous value inside the item system

Phẩm Lực remains canonical, but it is NOT used to hide item identity.

For raw stackable resources, prefer a stable/base Phẩm Lực per resource definition rather than random per-unit PL.

Example:

- Phàm Thiết: base PL 1/unit;
- Thanh Thiết: base PL 8/unit;
- Huyền Thiết: base PL 40/unit.

Then:
- 1,000 Thanh Thiết = 8,000 construction PL;
- 200 Huyền Thiết = 8,000 construction PL.

The items remain visibly different.

Special variants may exist as separate resource definitions instead of creating thousands of mixed-PL sub-stacks.

Example:
- Huyền Thiết;
- Tinh Luyện Huyền Thiết;
- Huyền Thiết Tủy.

This keeps stacking and UI understandable.

---

# 4. No sect warehouse capacity limit

The user explicitly does not want a storage-capacity game.

Sect resource storage is logically unbounded for normal stackable resources.

Stacks may reach:
- millions;
- billions if long-term progression requires.

Implementation must use numeric types safe for very large counts.

Do NOT stop production because the warehouse is full.

Do NOT require the player to build warehouses merely to increase numeric storage capacity.

---

# 5. Purpose of Warehouse building after removing capacity

Kho Tông Môn remains useful, but not as a capacity gate.

Its level/function governs:

- sorting/automation;
- reserve rules;
- protected/locked resources;
- auto-routing to production;
- auto-routing to market;
- auto-restock hunting teams;
- priority between construction/crafting/market;
- unique-item/loot handling;
- processing throughput if simulation needs a logistics rate;
- reporting/search/filter quality.

Milestones may unlock:
- reserve rules;
- protected material lists;
- automatic low-grade-first consumption;
- hunting settlement routing;
- auto-market overflow/surplus;
- multi-location warehouse network.

Do not reintroduce a hidden capacity ceiling later without explicit user approval.

---

# 6. Stack model

For stackable resources, canonical stack key is primarily:

**resource_id**

A stack stores:
- quantity;
- optional metadata only when the whole stack shares that metadata.

Do not split stacks because of individual unit history.

If two resources meaningfully differ in:
- realm grade;
- quality behavior;
- recipe eligibility;
- special effect;

they should normally be distinct resource IDs.

This makes "what is this item?" obvious to the player.

---

# 7. Unique items remain individual

The large-stack rule applies to commodities.

The following normally remain individual instances:
- equipment;
- Pháp Bảo;
- Chí Bảo;
- manuals/unique techniques where identity matters;
- rare quest/story objects;
- special boss artifacts;
- individually rolled crafted items.

Their data can contain:
- unique id;
- ownership;
- Phẩm Lực;
- affixes;
- durability;
- history;
- creator;
- etc.

---

# 8. Building material consumption

Normal construction still consumes:
- Linh Mộc-family resources;
- Khoáng-family resources;
- Spirit Stones.

Requirements may be expressed in required Phẩm Lực by family.

The resolver selects real item stacks.

Example:
Need 8,000 Khoáng PL.

Eligible stock:
- Thanh Thiết: 1,500 units × PL8;
- Huyền Thiết: 200 units × PL40.

Policy can say:
- consume lowest realm grade first;
- preserve at least N of named resource;
- lock rare resources;
- allow/disallow specific resources.

Thus the system stays flexible without hiding actual items.

---

# 9. Higher profession/building progression unlocks higher-grade resources

Progression should gradually expose new resource types.

Examples:
- higher Mining profession + deeper mine -> discovers higher-realm ores;
- higher Spirit Farming + stronger fields -> can reliably cultivate higher-realm herbs;
- higher hunting regions -> higher-realm monster parts/cores;
- higher crafting -> can use those materials efficiently.

This is a soft progression web.

Do NOT make the rule:
"profession Lv.100 = exactly Trúc Cơ material".

Profession, building capability, region and resource grade all contribute.

---

# 10. Universal passive cultivation

Every disciple has a cultivation gain floor even when not explicitly cultivating.

No normal sect activity should freeze realm progression entirely.

The authoritative gain pipeline is:

**Base cultivation flow**
× spiritual-root system
× technique/path
× six-foundation contribution
× bloodline/physique/traits
× sect-wide buffs
× activity modifier
× local building/service modifier
+ event/combat rewards.

Existing P2 authorities remain intact until the P3.7 migration implementation.

---

# 11. Six-foundation roles

Use the canonical six foundation fields only:

- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

They are not all direct cultivation multipliers.

## 11.1 Tư Chất
Primary natural learning/cultivation aptitude.

Main effects:
- baseline cultivation efficiency;
- learning speed for cultivation-related content.

## 11.2 Căn Cốt
Physical foundation.

Main effects:
- stamina/endurance;
- body-training efficiency;
- HP/physical resilience contribution;
- work endurance.

May indirectly improve uptime, not raw cultivation speed as strongly as Tư Chất.

## 11.3 Cơ Duyên
Fortune/opportunity.

Main effects:
- rare encounter chance;
- special loot/opportunity weighting;
- insight event chance;
- unusual discovery.

Do not make it a flat damage stat.

## 11.4 Thông Tuệ
Comprehension/intelligence.

Main effects:
- technique mastery;
- profession learning/EXP efficiency;
- combat-skill learning;
- research/teaching effectiveness.

May slightly help cultivation comprehension, but should not duplicate Tư Chất.

## 11.5 Mị Lực
Social presence.

Main effects:
- relationship gain;
- commerce/social service;
- team/social interactions;
- recruiting/teaching influence where appropriate.

Not a raw combat stat.

## 11.6 Tiềm Lực
Long-term growth potential.

Main effects:
- scaling of permanent growth opportunities;
- high-realm/stat-growth efficiency;
- rare long-term improvement;
- future breakthrough/growth systems.

Do not use Tiềm Lực as a simple duplicate of Tư Chất.

Exact formulas remain balancing data.

---

# 12. Base cultivation should be readable in UI

The player should see a derived value such as:

**Tu Vi nền: +120/giờ**

Advanced detail can explain:
- Linh Căn +X%;
- Tư Chất +Y%;
- Công pháp +Z%;
- Thể Chất/Huyết Mạch;
- Chí Bảo/Tông Môn;
- current activity.

Then activity changes the result.

Example:
- working -> lower rate but profession/economy rewards;
- focused cultivation -> higher;
- Secret Chamber -> much higher at personal Spirit Stone cost;
- hunting -> passive base + large encounter rewards.

---

# 13. At-home autonomous self-investment

A disciple at sect may autonomously spend personal Spirit Stones on:

- Secret Chamber;
- pills;
- equipment;
- talismans;
- Pháp Bảo;
- market goods;
- future auctions/services.

Pill use is allowed as an autonomous progression choice.

AI choice depends on:
- personality;
- current wealth;
- realm progress;
- injury;
- role;
- player policy;
- expected utility.

The Sect Master may override/lock priorities.

---

# 14. Pill logic

Pills are not only emergency consumables.

They may support:
- direct cultivation gain;
- cultivation-rate buff;
- breakthrough;
- healing;
- stamina;
- combat preparation.

An AI disciple may choose to consume cultivation pills at home when:
- it owns/has access to them;
- expected value is good;
- policy allows;
- no wasteful overdose/realm mismatch rule blocks it.

Lower-grade pills may still work on high-realm disciples but become economically inefficient rather than hard-blocked.

---

# 15. Locked decisions

1. Normal resource items remain distinct and visible.
2. No averaging different resource identities into one stack.
3. Raw commodity stacks can become extremely large.
4. No normal sect warehouse capacity cap.
5. Warehouse progression is automation/logistics, not storage-space expansion.
6. Resources have realm-grade labels tied to the cultivation progression ladder.
7. Higher progression reveals new higher-grade material types.
8. Phẩm Lực remains a numeric comparison/construction/crafting magnitude.
9. Prefer stable PL per raw resource definition for clean stacking.
10. Unique gear/artifacts remain individual items.
11. All disciples have passive cultivation growth.
12. The canonical six foundation fields influence different growth systems and must not be collapsed into one "talent" stat.
13. Disciples at home may autonomously spend Spirit Stones on Secret Chambers and pills to accelerate growth.
