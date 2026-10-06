# P3.7 — LINH ĐIỀN / SPIRIT FIELD SPEC

Status: CANONICAL DESIGN AUTHORITY  
Updated: 2026-10-06

Parents:
- `docs/GAME_SYSTEM_ARCHITECTURE.md`
- `docs/P3_7_BUILDING_TREE_SPEC.md`
- `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`
- `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`

This file owns the complete gameplay contract for Linh Điền.
Implementation status belongs only in `CURRENT_CHECKPOINT.md`.

---

# 1. Purpose

Linh Điền converts:
- seeds/planting stock;
- disciple labor;
- time;
- field capability;

into:
- herbs;
- spirit grain;
- spirit flowers;
- other plant resources;
- recovered seeds;
- rare/mutated products at higher milestones.

The system must scale to many disciples without requiring the player to click every crop cycle.

---

# 2. What Linh Điền does NOT simulate

Backend does not need detailed pathfinding such as:
- walking to a precise tile;
- carrying every harvested unit across the map;
- returning to a deposit point step by step.

Movement/logistics may contribute a deterministic **time overhead**.

Presentation may animate disciples walking/working, but those animations are not gameplay authority.

The authoritative farming cycle is based on:
- planting/tending time;
- passive growth time;
- harvest/processing time;
- output quantity/quality.

There is no mid-haul inventory state and therefore no cancel-haul teleport exploit.

---

# 3. Field structure

Every Linh Điền is a real BuildingState instance.

Each field owns multiple independent **plots / luống**.

A plot is the minimum crop-production unit.

Canonical plot phases:
1. `empty`
2. `planting`
3. `growing`
4. `ready`
5. `harvesting`

A field may have many plots in different phases at the same time.

This replaces the old one-field/one-production-state model.

---

# 4. Worker capacity vs plot capacity

Worker slots and plots are different.

## Worker slots
How many disciples may actively perform Linh Thực labor in the field at once.

Baseline:
- Lv1: 2 workers;
- +1 worker every 5 building levels.

## Plot capacity
How many crop batches may exist in the field simultaneously.

Initial direction:
- Lv1: 4 plots;
- +1 plot every 5 building levels.

Exact tuning is data, but:
- multiple workers must have real parallel work;
- increasing worker slots must be useful;
- one worker must be able to service multiple plots over time;
- growing plots do not occupy a worker.

---

# 5. Multi-instance authority

Multiple Linh Điền instances must work independently.

A disciple assigned to farming needs a real worksite assignment:
- profession = Herbalism / Linh Thực;
- worksite/building ID = a specific Spirit Field instance.

Do not route every farmer through `primary_building(TYPE_SPIRIT_FIELD)`.

AI may assign workers automatically according to:
- available worker slots;
- field policy;
- crop demand;
- distance/logistics later if relevant.

The player should normally manage field/group policy rather than manually placing every worker.

---

# 6. Crop definition

Every plantable crop has a canonical definition.

Minimum fields:

```
crop_id
display_name
seed_resource_id
output_resource_id
realm_rank
required_field_level
required_processing_pl
base_seed_cost
base_plant_time
base_growth_time
base_harvest_time
base_yield
base_seed_return
base_output_pl
rare_table / mutation_table
tags
optional_affinity_elements
```

Resource identity remains authoritative through ResourceRegistry.

Phẩm Lực does not replace crop identity.

---

# 7. Seeds are real inputs

Planting is not free.

When a plot starts planting:
- required seed is reserved/consumed from the main Sect Warehouse;
- the plot records the crop and committed seed;
- interruption does not magically refund or duplicate seed;
- another valid worker may continue unfinished planting.

If no valid seed is available:
- that crop cannot be planted;
- AI chooses another eligible crop or leaves the plot idle.

No resource may appear from nothing.

---

# 8. Crop policy

The player should not manually click every plot.

Every field has a farming policy.

Minimum policy modes:

## AUTO_DEMAND
Default.

Choose among unlocked crops using:
- warehouse reserve targets;
- downstream demand;
- seed availability;
- crop priority;
- field capability.

## PRIORITY
Player gives one or more preferred crops/weights.

## FIXED
Field only plants the selected crop while seed is available.

Policy is field-level, not plot-click micromanagement.

---

# 9. Production cycle

For one plot:

## Planting / tending

Worker performs labor for:

**Plant Time = Base Plant Time × Crop Difficulty × Building Modifier ÷ Worker Labor Efficiency + Logistics Overhead**

At completion:
- plot enters `growing`;
- no worker remains bound to the plot.

## Passive growth

Growth advances from simulation time:

**Growth Time = Base Growth Time × Crop Difficulty × Field Growth Modifier**

Worker does not stand at the plot during the whole growth timer.

Building milestones, formations, sect buffs and crop-specific effects may modify growth.

## Harvest / processing

When ready, a worker performs:

**Harvest Time = Base Harvest Time × Crop Difficulty × Building Modifier ÷ Worker Labor Efficiency + Logistics Overhead**

At completion:
- output is resolved;
- resources deposit directly into the main Sect Warehouse;
- seed return is resolved;
- rare/mutation rolls are resolved;
- plot becomes empty;
- AI may immediately schedule a new crop according to policy.

---

# 10. Disciple stat interaction

Do not make every stat affect every farming result.

## 10.1 Tư Chất — Aptitude

No generic direct Linh Điền production bonus.

Tư Chất remains primarily cultivation aptitude.

Specific future crops/events may explicitly reference it, but routine farming does not.

## 10.2 Căn Cốt — Constitution

Affects physical labor endurance.

Canonical effects:
- lower stamina cost for planting/harvesting;
- modestly improves sustained labor efficiency;
- reduces fatigue-driven downtime.

It does NOT directly increase crop Phẩm Lực.

## 10.3 Cơ Duyên — Fortune

Affects low-probability positive outcomes.

Canonical effects:
- rare crop chance;
- mutation chance;
- exceptional seed recovery;
- unusual farming event chance.

Cơ Duyên modifies small base chances.
It must not turn ordinary farming into guaranteed jackpots.

## 10.4 Thông Tuệ — Comprehension

Primary universal learning stat for professions.

Canonical effects:
- profession XP gain;
- learning difficult crop handling;
- modest reduction to high-difficulty processing penalty.

It is not a raw yield stat.

## 10.5 Mị Lực — Charisma

No generic direct production bonus.

Mị Lực belongs to social/market/teaching/relationship systems unless a specific farming content rule says otherwise.

## 10.6 Tiềm Lực — Potential

No immediate crop-output multiplier.

Potential may matter to long-term profession development systems later, but Linh Điền does not invent a parallel use for it.

---

# 11. Profession interaction

Linh Thực / Herbalism is the primary disciple skill for Linh Điền.

The field reads the global profession authority.
It does not own a separate private farming-level system.

Locked profession direction from the parent design:
- profession progression eventually supports Lv1–1000+;
- each profession level contributes +1% overall profession efficiency;
- profession talent primarily accelerates profession XP;
- profession milestones add mechanics.

To avoid quadratic scaling, when the global profession authority reaches that model:

**Profession Efficiency = 1 + Profession Level × 0.01**

For farming throughput, split that efficiency between labor time and yield:

**Labor Speed Factor = sqrt(Profession Efficiency)**  
**Yield Factor = sqrt(Profession Efficiency)**

Therefore total output/time scales approximately with Profession Efficiency instead of being squared.

Until the global profession migration is implemented, Linh Điền uses the current profession interface rather than creating a second level system.

---

# 12. Linh Thực talent

Add a real profession talent:

`herbalist_affinity` / **Linh Thực Thiên Phú**

Primary effect:
- +80% Herbalism profession XP gain.

Small secondary effect allowed:
- modest seed-recovery or rare-quality assistance.

Do not give a huge direct yield multiplier.
Talent accelerates mastery; profession level produces long-term dominance.

Candidate generation and profession suitability must recognize this talent.

---

# 13. General traits

Existing general traits may affect farming where semantically appropriate.

## Cần Mẫn / Diligent Worker
- faster routine labor;
- normal or slightly improved learning.

## Cẩu Thả / Careless Worker
- slower/less reliable routine labor;
- may slightly reduce seed recovery or quality consistency.

Do not automatically apply crafting-specific hidden traits to agriculture unless their definition is broadened explicitly.

---

# 14. Spiritual Root / Bloodline / Physique

No universal agriculture multiplier.

## Spiritual Root
A crop may optionally define affinity elements.

If the disciple has a matching Spiritual Root element:
- allow a small positive quality/rare-effect bonus.

No mismatch penalty by default.

Example:
a Wood/Water-aligned medicinal crop may benefit slightly from a matching root.

## Bloodline
Current combat/cultivation bloodlines do not automatically buff farming.

A future bloodline may explicitly define a farming effect.

## Physique
Current physiques do not automatically buff farming except through already-valid physical endurance mechanics.

Do not turn special combat physiques into universal profession bonuses.

---

# 15. Building-level effects

Ordinary Linh Điền levels may improve:
- worker slots;
- plot capacity;
- planting/harvest labor modifier;
- growth-speed modifier;
- baseline yield;
- maximum crop difficulty / processing PL.

Do not make every level unlock a new mechanic.

---

# 16. Milestones

## Lv1
- starter plots;
- starter Luyện Khí crop pool;
- manual/basic irrigation represented in base labor time.

## Lv10 — Irrigation + crop policy
- unlock automated irrigation effect;
- reduce routine planting/tending labor;
- unlock crop policy controls;
- milestone specialty component required.

Current canonical specialty component:
**Linh Tuyền Chi Tâm**

## Lv20 — Rotation + seed recovery
- crop rotation;
- improved seed recovery;
- reduced repeated-crop penalty if such penalty is enabled.

## Lv30 — Higher processing + Linh Hoa
- higher crop processing threshold;
- unlock Linh Hoa / advanced medicinal crop families;
- reduced penalty on higher-PL crops.

## Lv50 — Mutation
- controlled mutation chance;
- rare seed variants;
- profession/fortune-sensitive mutation resolution.

## Lv75 — Internal Spirit Spring
- major growth modifier;
- rare-product chance;
- improved high-realm crop stability.

## Lv100 — Grand Spirit Field
- strong output-PL bonus;
- Herbalism profession XP bonus;
- top field-capability threshold for the current content tier.

Exact specialty component IDs for Lv20/30/50/75/100 must be defined as real resource content before those milestones are enabled.
Do not silently allow an undefined milestone and do not pretend max level is reachable while required content is missing.

---

# 17. Yield resolution

Base output is crop-specific.

Conceptual:

**Yield = Base Yield × Yield Factor × Building Yield × Policy/Event Modifiers**

Where Yield Factor is primarily profession-derived.

Căn Cốt should not directly multiply yield.
Thông Tuệ should not directly multiply yield.
Cơ Duyên should affect exceptional results, not routine quantity.

Round only at final item-resolution step using deterministic rules.

---

# 18. Phẩm Lực / output quality

Every crop has a base output Phẩm Lực from resource/crop definition.

Output PL may be modified by:
- field level/milestone;
- profession mastery;
- crop difficulty handling;
- matching crop/root affinity if explicitly defined;
- rare/mutation result;
- sect formation/treasure later.

Do not average different item identities together.

If a harvest produces a different resource/variant, it enters the warehouse under its own resource ID.

---

# 19. Seed return

Harvest may return seeds.

Conceptual:

**Seed Return = crop base return × field seed-recovery modifier × profession modifier**

Cơ Duyên may influence exceptional extra seed events.

Lv20 is the first major seed-recovery milestone.

Seed return must be deterministic for a given simulation state/seed.

---

# 20. Worker interruption

Planting/harvest progress belongs to the plot, not only the worker.

If a worker stops:
- unfinished plot progress remains;
- seed already committed remains committed;
- another assigned worker may continue;
- no output is granted early;
- no logistics teleport is needed because logistics is folded into task duration.

This prevents:
- duplicated seed;
- canceled-work refunds;
- teleporting harvested goods;
- stale competing worker cycles.

---

# 21. Worker and crop AI

AI chooses work in this order:

1. ready plots needing harvest;
2. unfinished planting/harvest work;
3. empty plots with an eligible crop under field policy;
4. otherwise no Linh Điền job is currently available.

A growing plot is not an active worker task.

Workers may rest/cultivate/do other valid work while crops grow.

---

# 22. Dependency boundaries

Linh Điền owns:
- field plots;
- crop lifecycle;
- crop policy;
- seed consumption/return;
- field-level/milestone modifiers;
- yield/quality resolution;
- field-specific worker scheduling.

Linh Điền reads but does not own:
- global profession progression curve;
- universal passive cultivation while working;
- wages/personal Spirit Stones;
- Contribution rewards for labor;
- generic injury/fatigue;
- warehouse;
- resource registry;
- character foundation.

Those shared systems must not be reimplemented privately inside Linh Điền.

---

# 23. Completion gate

Linh Điền backend is not considered complete until tests cover:

1. seed required and consumed exactly once;
2. no-seed idle/fallback behavior;
3. multiple independent plots;
4. multiple workers with real parallel contribution;
5. growth without worker lock;
6. harvest output into canonical warehouse;
7. deterministic yield/rare/seed resolution;
8. worker interruption and continuation;
9. multiple Spirit Field instances with separate worker assignments;
10. crop policy selection;
11. field level effects;
12. Lv10 real irrigation/policy behavior;
13. higher milestones do not claim availability without content;
14. save/load mid-planting;
15. save/load mid-growth;
16. save/load mid-harvest;
17. reserve/lock interaction for seeds;
18. large warehouse stack compatibility;
19. legacy P0–P2 baseline remains green;
20. cumulative P3.7 A1/B1 regression remains green.

Presentation/path animation is NOT part of this backend completion gate.
