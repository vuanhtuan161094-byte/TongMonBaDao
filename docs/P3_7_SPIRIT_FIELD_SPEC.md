# P3.7 — LINH ĐIỀN / SPIRIT FIELD SPEC

Status: CANONICAL DESIGN AUTHORITY  
Updated: 2026-10-16

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

Linh Điền should answer only the useful questions:
- trồng cây gì;
- tốn bao nhiêu Linh Thạch;
- bao lâu hoàn thành;
- thu được bao nhiêu;
- đệ tử nào làm nhanh hơn;
- có bội thu hay không.

Do not simulate agricultural micro-management that does not create a meaningful player decision.

---

# 2. One operator = one Field duty; plots are internal timers

Canonical lifecycle:

**assign one Linh Thực operator -> start Field duty -> internal plot timers -> harvest resolves**

Each Linh Điền instance has exactly **one responsible disciple at every building level**.
The field's plots are subordinate production timers owned by that one occupation; they are
not four independent disciple jobs and never justify four active-job reservations.

There are no separate backend phases for:
- walking to the field;
- planting;
- tending;
- passive growth worker occupancy;
- harvesting;
- hauling.

Presentation may animate these actions, but presentation is not gameplay authority.

---

# 3. Plot state

Each Spirit Field owns multiple independent plots.

Canonical plot data:

```
plot_id
crop_id
status: empty | growing
started_tick
finish_tick
assigned_worker_id
paid_spirit_stones
routine_yield
rare_factor
```

The relevant worker and facility factors are sampled when the plot starts.

All growing plots created by one Field duty carry the same responsible operator.
That disciple remains reserved by the Linh Điền while any plot from the duty is unresolved.
There are still no detailed walking/tending/harvest backend phases.

When `finish_tick` is reached:
- routine yield resolves;
- lucky multiplier resolves;
- output is deposited directly into the canonical Sect Warehouse;
- the plot becomes empty.

There is no carried-harvest state.

---

# 4. Worker slots and plot slots

Worker slots and plot slots are separate.

## Worker slots

**Owner lock 2026-10-16:**
- every Linh Điền instance has exactly **1 operator**;
- building level never increases worker count;
- one disciple still obeys One Active Job.

The operator manages the whole field duty. Internal plot timers do not create extra
disciple occupations.

## Plot slots

**Economy V2 pilot: exactly 4 plots per Linh Điền at every level.**

Building level may improve speed/yield/content unlocks, but does not automatically add
plots. More aggregate farming capacity comes from stronger fields and additional
Spirit Field instances under the building-count progression rules.

A single duty may start several empty plots. All such plots retain the same operator
identity and may have independent crop timers. Economy-A wage identity is per Field
duty, not per plot; replaying completion from several plots must not pay four wages.

---

# 5. Multiple Spirit Fields

Multiple field instances work independently.

A disciple may have a concrete:

`worksite_building_id`

For Linh Thực, this identifies the exact Spirit Field instance.

Rules:
- explicit worksite -> use that field only;
- empty worksite -> backward-compatible primary-field fallback;
- a worker assigned to Field B must not silently produce in Field A.

---

# 6. Crop definition

Minimum crop data:

```
crop_id
display_name
output_resource_id
realm_grade / realm_rank
required_field_level
plant_cost_spirit_stones
base_cycle_ticks
base_yield
base_work_xp
optional_affinity_elements
tags
```

AUTO_DEMAND may also use a simple stock target.

No seed item.
No Phẩm Lực.
No crop-specific hidden stamina formula.

---

# 7. Planting cost

Starting a plot immediately consumes:

**plant_cost_spirit_stones**

from Sect Spirit Stones.

If insufficient:
- no plot starts;
- no partial payment occurs.

Manual cancellation:
- V1 refund = 0%.

---

# 8. Cycle time

For crop `c`, worker `d`, field `b`:

**Actual Cycle Ticks = ceil(Base Cycle × Milestone Time Factor / Total Speed)**

Where:

**Total Speed = Profession Speed × generic work_speed modifiers × Field Speed × Optional Affinity**

Profession Speed:

**1 + 0.01 × Linh Thực Level**

Field Speed:

**1 + 0.005 × (Field Level − 1)**

Optional crop/root affinity:
- matching declared Spiritual Root element -> ×1.05;
- no mismatch penalty.

Cần Mẫn, Cẩu Thả and future named content affect this only through generic modifier data.

---

# 9. Routine yield

**Routine Yield = round(Base Yield × Field Yield Factor)**

Base Field Yield Factor:

**1 + 0.005 × (Field Level − 1)**

Profession level does not multiply routine yield a second time.

Cơ Duyên does not increase routine yield.

---

# 10. Cơ Duyên and lucky harvest

Base bands per completed crop:

| Result | Base chance |
|---|---:|
| ×4 | 0.20% |
| ×3 | 0.80% |
| ×2 | 3.00% |
| ×1 | remainder |

Actual chance uses:

Current A2R runtime keeps its snapshotted bounded `rare_factor` compatibility path so the locked Spirit Field contract is not silently rewritten inside C1.

Canonical new Cơ Duyên authority is now:

**Luck Score = RNG(0..9999) + Cơ Duyên - Difficulty**

with result tiers owned by `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`.

A future Spirit Field migration may replace the compatibility rare-factor roll with one meaningful Cơ Duyên check at harvest resolution. Do not introduce another uncapped percentage formula.

The relevant rare factor is sampled when the plot starts.

Use one deterministic roll, highest band first:
1. ×4;
2. ×3;
3. ×2;
4. otherwise ×1.

Final output:

**Final Yield = Routine Yield × Lucky Multiplier**

---

# 11. Linh Thực learning

Profession XP formula:

**Linh Thực XP = Base XP × Thông Tuệ Factor × Linh Thực Talent Factor × generic profession_xp modifiers × Field XP Factor**

Thông Tuệ uses the common lục-duy curve.

Linh Thực Thiên Phú grades:
- grade 1: +5% XP;
- grade 2: +10%;
- grade 3: +15%;
- grade 4: +20%;
- grade 5: +25%.

Talent accelerates learning; it does not directly multiply routine yield.

---

# 12. Passive Tu Vi while farming

Only the actual **start-crop work action** counts as active Linh Thực work in this simplified backend.

Passive crop countdown:
- keeps that disciple assigned to the plot;
- does not count as an active work action;
- does not grant work Tu Vi.

Use the shared work-cultivation authority.

---

# 13. Crop policy

## AUTO_DEMAND

Default.

Select an unlocked, affordable crop from current warehouse stock deficit versus its target.

## PRIORITY

Available from Lv10.

The player supplies crop weights.
Selection is deterministic.

## FIXED

Available from Lv10.

Plant only the selected crop while:
- unlocked;
- eligible;
- affordable.

---

# 14. Building-level rules

Baseline:
- worker slots: 4 at Lv1, +1 every 5 levels;
- plot slots: 4 at Lv1, +1 every 5 levels;
- worker slots and plot slots stay 1:1;
- field speed: +0.5% per level after Lv1;
- field yield: +0.5% per level after Lv1.

---

# 15. Milestones

## Lv10 — Irrigation + policy
- unlock PRIORITY/FIXED controls;
- additional ×0.90 crop cycle time;
- requires 1 Linh Tuyền Chi Tâm.

## Lv20
- ×1.10 routine yield;
- requires 2 Linh Tuyền Chi Tâm.

## Lv30
- ×1.10 Linh Thực XP;
- advanced crops may unlock by content data;
- requires 3 Linh Tuyền Chi Tâm.

## Lv50
- rare/mutation crop content may unlock when real content exists;
- requires 5 Linh Tuyền Chi Tâm.

## Lv75
- additional ×0.85 crop cycle time;
- ×1.10 routine yield;
- requires 8 Linh Tuyền Chi Tâm.

## Lv100
- ×1.20 routine yield;
- ×1.20 Linh Thực XP;
- requires 10 Linh Tuyền Chi Tâm.

Linh Tuyền Chi Tâm fragments:
- each completed plot has a low base 5% chance to obtain 1 Mảnh Linh Tuyền Chi Tâm;
- the chance is multiplied by the snapshotted Cơ Duyên / rare factor;
- 100 fragments automatically convert into 1 Linh Tuyền Chi Tâm.

Milestone numeric factors stack multiplicatively.

A milestone that requires specialty content must not be enabled without real content.

---

# 16. Save migration

Old A2 saves may contain one shared field state:
- growing;
- harvest_ready;
- growth progress/required;
- resource ID;
- planted-by worker.

A2R migration converts that state once into the first canonical plot and preserves the remaining timer as closely as practical.

New saves persist the multi-plot model directly.

---

# 17. Completion gate

A2R closes only when runtime evidence covers:

1. one timer per plot;
2. Spirit Stone planting cost;
3. insufficient-funds behavior;
4. cancel with no default refund;
5. four independent internal plot timers per Linh Điền;
6. exactly one responsible disciple for the whole Linh Điền instance;
7. that operator remains reserved while any duty plot is unresolved and releases after the duty drains;
8. multiple Spirit Field instances, each with its own one operator;
9. concrete worksite assignment;
10. AUTO_DEMAND / PRIORITY / FIXED;
11. profession-level cycle-time effect;
12. generic graded work modifier effect;
13. Thông Tuệ profession-XP effect;
14. graded Linh Thực talent XP;
15. Cơ Duyên lucky-harvest bands;
16. field-level speed/yield formulas;
17. milestone numeric behavior;
18. passive work Tu Vi only during actual work;
19. canonical warehouse deposit;
20. save/load mid-cycle;
21. deterministic continuation;
22. legacy A2 migration;
23. locked earlier gates remain green.

Detailed walking/pathfinding/hauling is explicitly outside Linh Điền backend authority.
