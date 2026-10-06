# P3.7 — DISCIPLE LOADOUT, OWNERSHIP & HUNTING PROGRESSION SPEC

Status: CANONICAL DESIGN AUTHORITY / RUNTIME NOT STARTED  
Date: 2026-10-05  
Parents:
- `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`
- `docs/P3_7_BUILDING_TREE_SPEC.md`

This spec locks the next layer requested by the user:
- scalable personal loadout without full personal inventories;
- autonomous equipment selection;
- sect-owned vs disciple-owned gear;
- Contribution/Spirit Stone economy around gear;
- hunting cultivation reward scaled by realm/challenge;
- hunting as the main fast-growth path.

Important compatibility note:
P2.1 currently gives only +2 cultivation per victory and explicitly makes combat slower than deliberate cultivation. That remains a locked historical P2.1 baseline. P3.7 intentionally introduces a NEW hunting progression layer that supersedes that balance only when P3.7 is implemented behind its own authority/gates. Do not silently modify P2.1 before migration.

---

# 1. Personal inventory philosophy

Target population is 1,000–3,000 disciples.

A disciple must NOT own a full RPG backpack with dozens of arbitrary stacks.

Personal state should consist of:

1. equipped combat gear;
2. active talisman loadout;
3. active techniques;
4. equipped artifacts / Pháp Bảo;
5. a small consumable loadout;
6. personal Spirit Stones;
7. Contribution Points;
8. progression/state.

Raw materials and ordinary loot do **not** live in a secondary loot warehouse or a long-lived personal/team loot inventory.

On reward resolution:
- personal progression rewards are granted to participating disciples immediately;
- personal Spirit Stone share is granted immediately according to the active split rule;
- item/material loot belonging to the sect is deposited directly into the **main Sect Warehouse**.

The team loadout exists for supplies taken **out** (medicine, pills, talismans, food, emergency items), not as a loot-storage system.

---

# 2. Canonical personal loadout V1

## 2.1 Equipment

Core equipment:
- 1 Weapon slot;
- 1 Armor slot.

Future accessories may be added only if they create meaningful build decisions.

Do not add ten generic RPG body slots just for complexity.

## 2.2 Talisman slots

Default target:
- 3 active Talisman slots.

Talismans may be:
- consumable;
- charged;
- passive while equipped;
- trigger-based.

Examples:
- escape talisman;
- shield talisman;
- burst-damage talisman;
- healing talisman.

AI may auto-use them according to risk policy.

The current P2.6 single `talisman` slot is a baseline to be migrated later, not immediately broken.

## 2.3 Technique loadout

A disciple may learn many techniques, but only a small active set drives current behavior.

Target active structure:
- 1 **Main Cultivation Technique / Chủ Tu Công Pháp**;
- up to 2 **Auxiliary Techniques / Phụ Tu Công Pháp**;
- combat skills remain under the existing combat-skill authority and may have their own active selection.

Purpose:
- Main technique defines the primary cultivation/combat path;
- Auxiliary techniques provide supporting modifiers, utilities or specialized effects;
- learned-technique library can be larger than active loadout.

The current P2.3 single `active_technique_id` is a baseline and will require backward-compatible migration when this system is implemented.

## 2.4 Pháp Bảo slots

Default target:
- 2 equipped Pháp Bảo slots.

Pháp Bảo may provide:
- combat stats;
- automatic active effects;
- survival;
- hunting/loot utility;
- movement;
- cultivation utility.

Very rare traits/realms/content may later modify usable Pháp Bảo count, but V1 must remain small and readable.

## 2.5 Consumable belt

Default:
- 4 consumable categories/slots.

Examples:
- healing;
- stamina;
- cultivation/support pill;
- emergency escape/utility.

This is a **loadout**, not storage.

Hậu Cần Điện restocks it from sect supplies according to policy.

---

# 3. Autonomous item selection

Disciples must be able to improve themselves without the player manually equipping 1,000 people.

When at sect and allowed by policy, a disciple may search:
- Sect Exchange / contribution store;
- sect sale inventory;
- Phường Thị;
- future auction;
- eligible items in the main Sect Warehouse;
- items offered directly by the Sect Master.

AI evaluates items using an **Expected Utility Score**, not raw PL alone.

Score inputs may include:
- actual combat gain;
- path/element compatibility;
- active techniques;
- role in team;
- survival need;
- durability;
- hunting region;
- existing item;
- personality/spending habit;
- price in Contribution/Spirit Stones.

AI should avoid constant churn:
- only replace an item when improvement exceeds a configurable minimum;
- do not repeatedly buy tiny +1% upgrades;
- respect locked/manual slots.

---

# 4. Item ownership states

Every equippable item must have an explicit ownership state.

## 4.1 Sect-owned

The item belongs to the sect.

It may be:
- stored;
- loaned to a disciple;
- assigned by policy;
- reassigned by the Sect Master.

Reassigning sect-owned gear is normally free.

This is the default for:
- crafted gear not yet exchanged;
- most hunting item loot deposited directly into the main Sect Warehouse;
- equipment explicitly marked as sect property.

## 4.2 Disciple-owned

An item becomes disciple-owned when the disciple:
- exchanges Contribution Points for it;
- buys it with personal Spirit Stones;
- receives it as an explicit personal gift;
- receives it through a future personal-ownership reward rule.

Disciple-owned items are not ordinary sect stock.

## 4.3 Requisitioning personal property

The Sect Master may still override ownership.

If a disciple-owned item is forcibly removed and given to another disciple:
- a **Contribution compensation cost** is incurred;
- the former owner receives compensation/credit according to the item's exchange value;
- repeated forced requisition may also reduce mood/loyalty if not covered by a favorable policy or relationship.

This implements the user's rule:
**normal sect-owned reassignment is ordinary; taking a disciple's personally owned item to give to someone else has a Contribution cost.**

Exact compensation ratio is balancing data.

## 4.4 Gift

The Sect Master may gift an item:
- free to the recipient;
- item becomes disciple-owned unless explicitly marked as a sect loan.

This distinction must be visible:
- **Ban tặng** = personal ownership;
- **Cấp dùng** = sect-owned loan.

---

# 5. Contribution Points

Contribution is a personal sect currency measuring service to the sect.

Sources include:
- hunting victories;
- deposited loot;
- dangerous missions;
- rear-base work;
- special achievements;
- teaching/service;
- sect missions.

Hunting should be a strong Contribution source.

Contribution may be spent/exchanged for:
- equipment;
- pills;
- techniques/manual access;
- Pháp Bảo;
- special services;
- priority or discounts where appropriate.

Contribution never decays merely because time passes.

---

# 6. Hunting rewards — final category set

A successful hunt can reward:

## Personal progression
- Tu Vi;
- combat skill mastery;
- technique/path mastery;
- Hunting/Exploration profession EXP if enabled;
- Contribution Points.

## Personal economy
- personal share of dropped Spirit Stones according to sect split policy.

## Sect economy
- sect share of Spirit Stones;
- monster materials;
- Yêu Đan;
- equipment;
- pills;
- techniques/manuals;
- talismans;
- Pháp Bảo;
- milestone materials;
- treasure/Chí Bảo fragments;
- rare seeds/ore/maps.

Item/material loot is deposited directly into the main Sect Warehouse when the reward is resolved. There is no Loot Warehouse and no required return-settlement step for ordinary loot.

---

# 7. Monster progression authority

Every combat monster/encounter should expose at least:

- `realm_rank` — monotonic stage index compatible with disciple cultivation stage ordering;
- `grade` — normal / elite / boss / future special grades;
- `combat_power` or equivalent actual fight power;
- HP/defense/skills;
- loot table;
- base danger;
- optional species/family/tags.

## 7.1 Realm rank

Do not hardcode XP by names such as "Kim Đan gives 500".

Instead, realm rank is relative.

Example:
- Luyện Khí 1 = rank 0;
- Luyện Khí 2 = rank 1;
- ...
- Trúc Cơ sơ = next rank;
- future realms continue monotonically.

New realms can be appended forever without replacing reward logic.

---

# 8. Cultivation reward scales with CURRENT stage requirement

This is the key scalability rule.

Let:

- `R_i` = Tu Vi required for disciple i to complete the current stage;
- `base_pct` = base reward percent for an equal-rank normal encounter;
- `realm_mult` = multiplier from monster rank vs disciple rank;
- `grade_mult` = normal/elite/boss;
- `challenge_mult` = actual team danger;
- `participation_mult` = disciple participation/support contribution.

Then:

**Hunt Tu Vi reward = R_i × base_pct × realm_mult × grade_mult × challenge_mult × participation_mult**

This automatically scales from Luyện Khí through any future realm.

No global list of fixed XP rewards per realm is required.

---

# 9. Relative realm multiplier V1

Starting design:

| Monster rank relative to disciple | realm_mult |
|---|---:|
| -4 or lower | 0.02 |
| -3 | 0.05 |
| -2 | 0.15 |
| -1 | 0.45 |
| equal | 1.00 |
| +1 | 1.35 |
| +2 | 1.75 |
| +3 | 2.20 |
| +4 or higher | capped around 2.60–3.00 |

Reason:
- farming trivial monsters gives almost no cultivation progress;
- equal/harder enemies are rewarding;
- reward does not become infinite just because someone is carried against a vastly stronger monster.

Exact values are balancing data, but the curve shape is canonical.

---

# 10. Monster grade multiplier V1

Starting design:

- Normal: ×1.0
- Elite: ×3.0
- Boss: ×10–15
- World/rare boss: content-specific multiplier/reward package

Bosses should also reward unique loot so raw Tu Vi is not their only purpose.

---

# 11. Team challenge multiplier

Realm alone is not enough because equipment, techniques, bloodline and team composition matter.

Define challenge using actual team power versus encounter power.

Conceptual bands:

- team massively overpowers encounter -> 0.25–0.50;
- comfortable favorable fight -> 0.75;
- appropriate/contested fight -> 1.00;
- dangerous but viable -> 1.15–1.30;
- suicidal/unreasonable -> reward may rise slightly but survival AI should normally retreat.

This prevents:
- a godlike senior carrying four weak disciples through trivial content for full EXP;
- endless low-risk farming being optimal.

Do not make challenge multiplier so strong that players feel punished for becoming stronger.

---

# 12. Participation multiplier

Every living team member may gain reward, but participation matters.

Examples of valid participation:
- damage;
- tanking;
- healing;
- support;
- crowd control;
- formation support.

Do not require raw damage to earn full reward.

Starting range:
- meaningful participant: 0.8–1.0;
- low participation: 0.4–0.7;
- effectively carried/no participation: lower.

This can remain lightweight in the first implementation.

---

# 13. Relative activity growth targets

The user explicitly wants hunting to be much faster than farming/rear-base work.

Balance target:

Let **1x** = passive cultivation while doing ordinary rear-base labor.

Then the design target is approximately:

| Activity | Cultivation-rate target |
|---|---:|
| Resting | ~0.5x |
| Ordinary work | 1x |
| Focused sect cultivation | ~4x |
| Training/Diễn Võ | ~3–6x depending purpose |
| Secret Chamber | ~6–15x depending room and spending |
| Hunting appropriate monsters | **~10–20x average** |
| Elite/Boss hunting | burst higher, but not steady/safe |

These are relative balance targets, not literal hard multipliers stored everywhere.

The important rule is:

**a healthy, supplied hunting disciple fighting appropriate enemies should progress in realm dramatically faster than a farmer/miner who merely receives passive cultivation.**

That is intentional.

---

# 14. Why rear-base disciples still matter

A worker is slower in realm growth, but gains:

- profession EXP;
- Contribution;
- wage/personal Spirit Stones;
- Bách Nghệ Lịch Luyện bonuses;
- low-risk passive cultivation;
- money to buy pills/gear;
- money to rent Secret Chamber;
- stable long-term specialization.

Therefore rear-base work is:
- safer;
- economically productive;
- profession-rich;
- cultivation-slower.

Hunting is:
- fast cultivation;
- Contribution-rich;
- Spirit-Stone-rich;
- loot-rich;
- injury/consumable/durability heavy.

Focused cultivation is:
- predictable;
- safer than hunting;
- no direct economic output.

These paths should not be equal in every reward category.

---

# 15. Target passive cultivation normalization

Instead of fixed "+2 per victory" style values for P3.7, long-term balance should target progress as a percentage of current-stage requirement.

Suggested starting bands per real simulation hour:

- rear-base ordinary work: about **0.04–0.06% of current-stage requirement/hour** before disciple multipliers;
- focused sect cultivation: about **0.16–0.25%/hour**;
- Secret Chamber: about **0.30–0.75%/hour** depending room/cost;
- healthy appropriate hunting: about **0.5–1.0%/hour average**, driven by actual encounter rate.

These bands yield roughly 10–20× hunting vs ordinary labor while remaining scalable across realm requirements.

They are tuning targets, not immutable constants.

The existing P2.1 `CULTIVATE_GAIN = 8` and victory +2 remain legacy slice constants until P3.7 migration.

---

# 16. Spirit Stone rewards from hunting

Hunting may directly drop Spirit Stones.

No lore contortion is required.

Spirit Stone handling:

1. encounter reward is resolved immediately;
2. sect item/material loot -> main Sect Warehouse immediately;
3. sect Spirit Stone share -> sect Spirit Stones immediately;
4. personal Spirit Stone share -> participating disciples immediately according to contribution/role policy;
5. Contribution and cultivation/combat progression -> participating disciples immediately.

Possible split dimensions:
- equal share;
- captain bonus;
- participation weighted;
- sect rank bonus;
- solo trait behavior.

V1 should prefer simple equal team share after sect cut unless strong reason otherwise.

---

# 17. Contribution from hunting

Hunting should award Contribution from two sources:

## 17.1 Encounter service
A base amount from:
- monster realm;
- grade;
- danger;
- mission importance.

## 17.2 Loot value
Additional Contribution may be based on valuable loot generated by the encounter and deposited into the main Sect Warehouse.

This means:
- killing monsters matters;
- valuable sect loot matters;
- Contribution is not solely raw kill count.

Because loot is deposited immediately, ordinary Contribution does not wait for a "return to sect" settlement step.

---

# 18. Contribution and loot ownership interaction

When hunting generates an item:
- item is deposited directly into the main Sect Warehouse as sect property;
- participating hunter(s) receive Contribution credit immediately;
- a hunter may later exchange Contribution to claim it personally;
- Sect Master may directly grant it;
- auto-equipment policy may loan it as sect property.

This cleanly separates:
- service reward;
- item ownership;
- equipment allocation.

---

# 19. Automatic self-improvement loop

A disciple AI may autonomously do:

1. hunt/work;
2. gain Contribution and/or personal Spirit Stones;
3. evaluate equipment/Pháp Bảo/talisman upgrades;
4. exchange/buy if allowed;
5. rent Secret Chamber;
6. buy pills;
7. return stronger;
8. take harder assignments.

Sect Master may:
- lock a slot;
- gift an item;
- lend sect gear;
- forbid categories;
- set spending caps;
- set role priorities.

This is essential for 1,000+ disciples.

---

# 20. Solo traits

Traits such as Cô Tinh / Độc Hành may alter solo behavior.

Possible effects:
- willingness to depart alone;
- lower penalty from absence of team roles;
- improved personal loot share;
- extra solo combat utility;
- increased solo EXP;
- higher risk tolerance.

Do NOT make all solo hunters automatically better than teams.

Solo is a build/trait path.

---

# 21. Injury and hunting pace

There is no permanent death in current design.

Fast hunting progression is balanced by:
- injury;
- medicine use;
- stamina;
- durability;
- return travel;
- supply;
- downtime in Y Quán;
- possible failure/retreat.

A hunter that repeatedly enters dangerous content may earn enormous progress but spend long periods recovering.

This creates the intended loop:
**hunter ↔ rear base**.

---

# 22. PvE region design implication

Every hunting region should expose:

- recommended realm range;
- enemy realm distribution;
- elite rate;
- boss opportunities;
- main material families;
- Spirit Stone yield tendency;
- injury risk;
- travel time;
- supply demand.

The player can then understand:
- safe farm;
- optimal growth;
- risky push;
- material target.

Săn Yêu Điện should surface these at a high level rather than raw formulas.

---

# 23. UI simplification

For ordinary players, do not display the full reward formula.

Show:

**Khu vực:** Hắc Phong Cốc  
**Khuyến nghị:** Trúc Cơ trung kỳ  
**Đội hiện tại:** Trúc Cơ trung–hậu  
**Nguy hiểm:** Vừa  
**Tu Vi dự kiến:** Rất cao  
**Linh Thạch:** Khá  
**Yêu Đan:** Cao  
**Nguy cơ Thương Thế:** Trung bình

Advanced detail may reveal numeric modifiers.

---

# 24. Compatibility / migration requirements

Future P3.7 implementation must preserve old saves where possible.

Known migrations:

## Equipment
Current P2.6:
- weapon;
- armor;
- one talisman.

Future:
- weapon;
- armor;
- 3 talisman slots;
- 2 Pháp Bảo slots;
- personal ownership state.

Old talisman becomes Talisman slot 1.

## Techniques
Current:
- learned techniques dictionary;
- one active technique.

Future:
- learned list preserved;
- old active technique becomes Main Technique;
- Auxiliary slots empty by default.

## Inventory
Current DiscipleState has an inventory dictionary.

Future P3.7 should not expose this as a large personal player-managed inventory.
It may be migrated/reinterpreted into:
- small consumable loadout;
- legacy transient holdings;
- direct deposit to the main Sect Warehouse.

Do not delete legacy inventory without save migration.

## Cultivation
Current P2.1 fixed gains remain untouched until the P3.7 hunting reward authority is implemented and gated.

---

# 25. Locked decisions from this spec

1. Personal loadout expands, personal warehouse does not.
2. Target talisman loadout: 3 slots.
3. Target Pháp Bảo loadout: 2 slots.
4. Techniques: one Main + up to two Auxiliary techniques; learned library may be larger.
5. Consumables are a small loadout, not storage.
6. Disciples autonomously seek upgrades compatible with role/build.
7. Sect Master can gift, loan, lock or override.
8. Sect-owned items may be reassigned normally.
9. Disciple-owned items require Contribution compensation when forcibly requisitioned.
10. Hunting grants strong Contribution and may directly drop Spirit Stones.
11. Hunting item/material loot is deposited directly into the main Sect Warehouse; hunter gets Contribution credit immediately.
12. Hunting cultivation reward scales against the disciple's CURRENT stage requirement.
13. Monster realm is relative/monotonic, not a hardcoded name-based XP table.
14. Hunting appropriate enemies targets roughly 10–20× ordinary-work cultivation speed.
15. Rear-base work remains valuable through profession, economy, passive cultivation and low risk.
16. No permanent death; injury/downtime/consumables balance the fast PvE route.
17. Existing P2.1/P2.3/P2.6 locked baselines are migrated later under explicit P3.7 gates, not silently overwritten.


---

# 26. Resource/base-growth authority link

For passive cultivation, six-foundation integration, at-home pill/Mật Thất spending, and resource-stack semantics, use:

`docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`


---
  
# 27. STATUS LOCATION

The no-Loot-Warehouse rule is already integrated into the main sections above:
- ordinary item/material rewards go directly to the main Sect Warehouse;
- personal progression/economy rewards go directly to participating disciples;
- carried team inventory is supplies-only.

Implementation status belongs only in:
`CURRENT_CHECKPOINT.md`
