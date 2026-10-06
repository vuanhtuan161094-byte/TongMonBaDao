# P3.7 — LINH ĐIỀN / SPIRIT FIELD SPEC

Status: CANONICAL DESIGN AUTHORITY  
Updated: 2026-10-06

Parents:
- `docs/GAME_SYSTEM_ARCHITECTURE.md`
- `docs/P3_7_BUILDING_TREE_SPEC.md`
- `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`
- `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`

This file owns Linh Điền gameplay.
Implementation status belongs only in `CURRENT_CHECKPOINT.md`.

---

# 1. Design goal

Linh Điền must be easy to understand at a glance.

The player needs to know:
- trồng cây gì;
- mất bao nhiêu Linh Thạch;
- bao lâu thu hoạch;
- thu được bao nhiêu;
- đệ tử nào làm nhanh/chậm hơn;
- có cơ hội bội thu hay không.

Do not simulate unnecessary agricultural micro-management.

---

# 2. One simple crop timer

Each plot uses one authoritative timer:

**start planting -> countdown -> harvest resolves**

There are no separate backend timers for:
- gieo;
- chăm;
- sinh trưởng;
- thu hoạch;
- vận chuyển về kho.

All of those are abstracted into one **Crop Cycle Time**.

Presentation may animate planting/watering/harvesting, but animation is not gameplay authority.

---

# 3. Plot model

Every Linh Điền owns multiple independent plots / luống.

Each plot only needs:

```
plot_id
crop_id
status: empty | growing
started_tick
finish_tick
assigned_worker_id
paid_spirit_stones
```

When `finish_tick` is reached:
- yield resolves;
- lucky-harvest multiplier resolves;
- output goes directly to the main Sect Warehouse;
- plot becomes empty;
- AI may start another crop according to field policy.

There is no carried-harvest state.

---

# 4. Worker slots and plot slots

Worker slots and plots are separate.

## Worker slots

How many disciples may actively operate the field at the same time.

Baseline:
- Lv1: 2 workers;
- +1 worker every 5 building levels.

## Plot slots

How many crops may grow simultaneously.

Baseline:
- Lv1: 4 plots;
- +1 plot every 5 building levels.

A worker is not locked for the whole crop timer.
The worker's stats are sampled when starting that plot and determine the plot's final cycle time.

A worker may then start another plot or perform another valid activity.

---

# 5. Multiple Spirit Fields

Multiple Linh Điền instances must work independently.

A farming assignment contains:
- profession = Herbalism / Linh Thực;
- worksite_id = a specific Spirit Field.

Do not route all farmers through the first Spirit Field.

AI may auto-assign workers according to:
- worker slots;
- empty plots;
- crop policy;
- current demand.

---

# 6. Crop definition

Every crop has a simple canonical definition.

Minimum fields:

```
crop_id
display_name
output_resource_id
realm_rank
required_field_level
plant_cost_spirit_stones
base_cycle_time
base_yield
optional_affinity_elements
tags
```

No seed item is required.

No Phẩm Lực exists in crop production.

Resources remain distinct by resource ID and realm/tier.

---

# 7. Planting cost

Starting a plot immediately consumes:

**plant_cost_spirit_stones**

from Sect Spirit Stones.

No seed inventory is used.

If Sect Spirit Stones are insufficient:
- the plot cannot start;
- AI tries another affordable eligible crop;
- otherwise the plot stays empty.

If a planted crop is manually canceled after payment:
- default V1 refund = 0%;
- special future policy may change this explicitly.

This prevents free cancel/restart exploitation.

---

# 8. Crop cycle-time formula

For crop `c`, worker `d`, field `b`:

**Actual Cycle Time = Base Cycle Time / Total Speed**

Where:

**Total Speed = Profession Speed × Work Trait × Field Speed × Optional Affinity**

## Profession Speed

From shared profession authority:

**1 + 0.01 × Herbalism Level**

## Work Trait

- no work trait -> ×1.00;
- Cần Mẫn grade 1–5 -> ×1.05 / ×1.10 / ×1.15 / ×1.20 / ×1.25;
- Cẩu Thả grade 1–5 -> ×0.95 / ×0.90 / ×0.85 / ×0.80 / ×0.75.

## Field Speed

Baseline:

**Field Speed = 1 + 0.005 × (Field Level − 1)**

Examples:
- Lv1 -> ×1.000;
- Lv20 -> ×1.095;
- Lv50 -> ×1.245;
- Lv100 -> ×1.495.

Milestones may add explicit additional modifiers.

## Optional elemental affinity

If the crop defines elemental affinity and the worker has a matching Spiritual Root element:

**×1.05**

No mismatch penalty.

---

# 9. Yield formula

Routine harvest quantity is deliberately simple.

**Routine Yield = round(Base Yield × Field Yield Factor)**

Where:

**Field Yield Factor = 1 + 0.005 × (Field Level − 1)**

Examples:
- Lv1 -> ×1.000;
- Lv20 -> ×1.095;
- Lv50 -> ×1.245;
- Lv100 -> ×1.495.

Profession level does not also multiply routine yield.
Profession mastery already improves output/hour by reducing cycle time.

This avoids double-counting profession mastery.

---

# 10. Cơ Duyên and lucky harvest

Cơ Duyên does not increase routine yield directly.

Use the shared Fortune formula:

**Luck Factor = 1 + 2 × Cơ Duyên**

For each completed crop, roll one lucky-harvest result from highest multiplier to lowest:

| Result | Base chance |
|---|---:|
| ×4 harvest | 0.20% |
| ×3 harvest | 0.80% |
| ×2 harvest | 3.00% |
| ×1 harvest | remainder |

Actual chance for each rare result:

**Actual Chance = Base Chance × Luck Factor**

Examples:

At Cơ Duyên = 0.00:
- ×4 = 0.20%;
- ×3 = 0.80%;
- ×2 = 3.00%.

At Cơ Duyên = 0.50:
- Luck Factor = ×2;
- ×4 = 0.40%;
- ×3 = 1.60%;
- ×2 = 6.00%.

At Cơ Duyên = 1.00:
- Luck Factor = ×3;
- ×4 = 0.60%;
- ×3 = 2.40%;
- ×2 = 9.00%.

Use one deterministic random roll:
1. check ×4 band;
2. then ×3;
3. then ×2;
4. otherwise ×1.

Final output:

**Final Yield = Routine Yield × Lucky Multiplier**

---

# 11. Character interaction

Linh Điền uses the shared profession authority.
It does not invent a private character-stat formula.

## Tư Chất
No farming-production bonus.

It affects cultivation absorption through the shared cultivation system.

## Căn Cốt
Uses the shared work-stamina rule:

**Stamina Cost = Base × (1 − 0.25 × Căn Cốt)**

No direct yield bonus.

## Cơ Duyên
Uses the lucky-harvest formula in section 10.

## Thông Tuệ
Uses the shared profession-XP formula.

## Mị Lực
No ordinary farming bonus.

## Tiềm Lực
No immediate farming bonus.

---

# 12. Linh Thực profession talent

Canonical profession-specific talent:

**Linh Thực Thiên Phú**

Grades:
- Nhất phẩm: +5% Herbalism XP;
- Nhị phẩm: +10%;
- Tam phẩm: +15%;
- Tứ phẩm: +20%;
- Ngũ phẩm: +25%.

Talent affects learning, not direct yield.

Generation probabilities are owned by:
`docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`

---

# 13. Profession XP

On starting/completing a valid crop cycle, Linh Thực activity grants profession XP through the shared formula:

**Profession XP = Base XP × (0.75 + 0.50 × Thông Tuệ) × Profession Talent Factor**

Exact Base XP per crop is crop data/balance.

Do not add extra private comprehension or talent formulas inside Linh Điền.

---

# 14. Passive Tu Vi while farming

Farming counts as ordinary work.

Use the shared work-cultivation formula:

**Raw Work Tu Vi / hour = Current Stage Requirement × 0.0005 × (1 + 0.0005 × Herbalism Level)**

Then pass the raw gain through the existing cultivation-gain authority.

Therefore:
- Tư Chất;
- Spiritual Root;
- cultivation technique/path;
- relevant cultivation traits;
- Bloodline;
- Physique

continue to affect cultivation naturally.

Linh Điền does not create another Tu Vi formula.

---

# 15. Crop policy

The player does not click every plot forever.

Each field has one policy.

## AUTO_DEMAND
Default.

Select an unlocked crop using:
- warehouse target quantity;
- downstream demand;
- affordability;
- crop priority.

## PRIORITY
Player gives preferred crop weights.

Example:
- Thanh Linh Thảo 70%;
- Linh Cốc 30%.

## FIXED
Only plant the selected crop while affordable.

---

# 16. Realm/tier unlocks

Crops are divided by explicit realm/tier.

Examples:
- Phàm;
- Luyện Khí;
- Trúc Cơ;
- Kim Đan;
- later realms.

Higher Linh Điền levels/milestones unlock higher crop tiers.

There is no continuous Phẩm Lực number.

A higher-tier crop is a different crop/resource definition with:
- its own cost;
- cycle time;
- yield;
- unlock requirement.

---

# 17. Building-level rules

Ordinary field levels improve:
- worker slots;
- plot slots;
- field speed;
- field yield;
- access thresholds where defined.

Baseline numeric rules:
- worker slots: 2 at Lv1, +1 every 5 levels;
- plot slots: 4 at Lv1, +1 every 5 levels;
- field speed: +0.5% per level after Lv1;
- field yield: +0.5% per level after Lv1.

---

# 18. Milestones

## Lv1
- starter plots;
- starter crop pool.

## Lv10 — Irrigation + policy
- unlock crop policy controls;
- additional −10% crop cycle time after normal formula;
- current specialty component: Linh Tuyền Chi Tâm.

## Lv20 — Rotation
- +10% routine yield;
- unlock next crop-family/tier content as defined.

## Lv30 — Advanced crops
- unlock advanced medicinal/flower crops;
- +10% profession XP from Linh Điền work.

## Lv50 — Mutation
- unlock mutation/rare crop event tables;
- Cơ Duyên uses the shared rare-event formula.

## Lv75 — Internal Spirit Spring
- additional −15% crop cycle time;
- +10% routine yield.

## Lv100 — Grand Spirit Field
- additional +20% routine yield;
- +20% Linh Thực profession XP.

Milestone bonuses stack multiplicatively unless explicitly stated otherwise.

Exact milestone specialty item IDs after Lv10 must exist as real content before those milestones are enabled.

---

# 19. No Phẩm Lực

Linh Điền does not use:
- crop PL;
- processing PL;
- output PL;
- PL threshold;
- PL refinement.

Crop difficulty/progression is represented by:
- realm/tier;
- field-level requirement;
- Spirit Stone cost;
- cycle time;
- base yield.

This is the canonical simplification.

---

# 20. Completion gate

Linh Điền backend is complete only when tests cover:

1. one simple crop timer;
2. planting cost paid in Sect Spirit Stones;
3. insufficient-funds behavior;
4. cancel gives no default refund;
5. multiple independent plots;
6. multiple workers start different plots;
7. worker is not locked for full crop timer;
8. multiple Spirit Field instances use separate worksite assignments;
9. field policy selection;
10. profession-level cycle-time effect;
11. graded Cần Mẫn/Cẩu Thả cycle-time effect;
12. Căn Cốt stamina formula;
13. graded Linh Thực talent XP effect;
14. Thông Tuệ XP formula;
15. Cơ Duyên ×2/×3/×4 lucky-harvest formula;
16. field-level speed/yield formula;
17. Lv10 real policy/irrigation behavior;
18. higher milestone availability is honest;
19. passive work Tu Vi uses the shared authority;
20. output deposits directly into canonical warehouse;
21. save/load mid-cycle;
22. deterministic continuation;
23. old P0–P2 baseline remains green;
24. cumulative P3.7 A1/B1 regression remains green.

Detailed pathfinding/walking/hauling is not part of this backend completion gate.
