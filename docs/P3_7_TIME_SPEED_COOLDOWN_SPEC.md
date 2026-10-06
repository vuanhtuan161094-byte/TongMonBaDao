# P3.7 — TIME, SPEED, WORK CYCLE & COOLDOWN AUTHORITY

Status: CANONICAL DESIGN AUTHORITY  
Date: 2026-10-05

Parents:
- `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`
- `docs/P3_7_BUILDING_TREE_SPEC.md`
- `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`
- `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`

This spec separates movement, attack speed, work time, construction time and real cooldowns.

---

# 1. Do not use one generic "speed" stat

The game has distinct timing domains.

## 1.1 Movement Speed / Tốc độ di chuyển

Meaning:
- how fast a disciple physically moves;
- used for movement inside combat;
- used for travel between sect work points when real map distance is relevant;
- later may affect expedition/local travel where appropriate.

Existing authority already has combat `move_speed`.

World/work movement should derive from a canonical movement-speed value rather than inventing an unrelated second "walking speed" unless a later system requires it.

Carrying heavy loads may apply a hauling modifier without changing the underlying personal movement stat.

## 1.2 Basic Attack Speed / Tốc đánh thường

Existing equipment stat:
- `basic_speed`.

Existing combat behavior:
- modifies `basic_interval`;
- higher attack speed means shorter time between basic attacks.

This is separate from movement speed.

## 1.3 Skill Cast Time / Thời gian thi triển

Existing combat skills already expose:
- `cast_time`.

This is how long the character needs to execute/cast the skill.

Do not automatically make move speed or basic attack speed reduce cast time.

Future cast-speed modifiers must be explicit.

## 1.4 Skill Cooldown / Hồi chiêu

Existing combat skills already expose:
- `cooldown`.

This is a true cooldown:
after use, the skill cannot be used again until ready.

## 1.5 Profession Work Speed / Tốc độ làm nghề

Existing workforce already has:
- profession work duration;
- work speed;
- profession level;
- comprehension/talent/trait modifiers.

P3.7 expands this authority.

Work speed affects how quickly the actual work phase completes.
It is NOT attack speed and NOT movement speed.

---

# 2. Timing vocabulary

Use these terms consistently.

## Travel / Logistics Time
Time overhead caused by moving between work, storage and service points.

Backend does not require exact path simulation.

It may be represented as:
- explicit travel time when spatial distance matters;
- or a deterministic logistics-time component folded into the work action.

Movement speed may modify this overhead when appropriate.

## Action Duration
Time actively spent doing the task:
- mining;
- planting;
- harvesting;
- forging;
- alchemy;
- healing;
- studying.

## Construction Time
Time from starting a construction/upgrade until the new building level/function becomes available.

## Cooldown
A lockout AFTER a discrete reusable action:
- combat skill;
- active artifact;
- special formation activation;
- rare emergency ability.

Do not add cooldown to ordinary actions simply to slow the player.

## Recovery / Downtime
Time caused by state:
- injury;
- fatigue;
- failed breakthrough;
- treatment;
- rest.

This is not a fake cooldown.

---

# 3. Mine is a physical workplace, not an abstract +ore timer

The Mine building and its mineral work area are one gameplay facility.

A disciple assigned to a Mine does not instantly generate ore from anywhere.

Canonical work loop:

1. **Receive/retain assignment** to a Mine instance.
2. **Travel to the Mine work area** using movement speed.
3. **Enter mining work phase**.
4. Complete one or more mining cycles using profession work speed.
5. Ore accumulates as a temporary **carried work batch**, not as a player-managed personal inventory.
6. When the batch reaches the current haul threshold, the work session ends, or AI decides to rest:
   - disciple travels to the Mine deposit/building point;
   - the batch is deposited;
   - the corresponding resource stack is credited directly to the main Sect Warehouse.
7. If still assigned and healthy, disciple returns to the work area and continues.

No separate Mine Warehouse UI is required.

The Mine building is the physical receiving point; the main Sect Warehouse remains the canonical inventory authority.

---

# 4. Why movement speed matters to mining

Mining output over time is not only:
**mining skill × building efficiency**.

It also includes time lost to movement/hauling.

Conceptual total cycle:

**travel to work + mine for batch + haul/deposit + return/reposition**

A faster disciple:
- spends less time walking;
- therefore spends a larger fraction of the schedule actually mining.

A stronger/better hauler may:
- carry a larger batch;
- need fewer deposit trips.

This creates natural usefulness for:
- movement speed;
- Căn Cốt / stamina;
- profession level;
- tools;
- logistics buffs;
- transport spirit beasts later.

Do NOT make workers run back after every single ore unit.
They mine a batch, then haul/deposit.

This avoids visual ping-pong and excessive simulation churn.

---

# 5. Mining work-time authority

Mining has at least:

- base action duration;
- work speed;
- batch size;
- movement/haul time;
- stamina consumption;
- resource yield;
- rare-resource rolls.

Existing P2.7:
- `MINING_DURATION = 4.0`;
- profession/work-speed authority already exists.

P3.7 should migrate this into building-aware data rather than deleting the concept.

Example structure, not final balance:

```
mine_instance:
  base_mining_duration
  base_batch_capacity
  worker_slots
  work_points
  deposit_point
  production_multiplier
  rare_find_modifiers
```

Disciple contributes:
- Mining profession level;
- profession talent;
- Thông Tuệ to learning;
- Căn Cốt/stamina to sustained work;
- movement speed to commuting/hauling;
- traits/tools/buffs.

---

# 6. Visual consequence on the live map

The map should show the physical loop when the disciple is in visible simulation range:

- moving toward/around a work facility where presentation benefits from it;
- working;
- carrying/processing where presentation benefits from it;
- leaving for another activity or rest.

These visuals do not require one-to-one backend path simulation.

Do not require one actor animation for every resource unit.

When the disciple is outside visible-detail simulation, the same timing model may resolve deterministically in batches.

Presentation must not create resources itself.

---

# 7. Spirit Field / Forestry use the same timing framework

The framework generalizes.

## Spirit Field
Detailed authority:
`docs/P3_7_SPIRIT_FIELD_SPEC.md`

Backend timing is:
- planting/tending labor time;
- passive crop growth time;
- harvest/processing labor time;
- optional logistics overhead folded into labor timing.

Exact walking/pathfinding is not required for farming authority.

Crop growth remains a real duration.
The worker is free to perform other valid activities while crops grow.

## Spirit Forest
- travel;
- gather/cut/tend;
- haul batch;
- deposit.

Different professions/content supply different action duration and batch logic.

---

# 8. Construction and building upgrades MUST take time

Building construction/upgrade is not instant.

When upgrade begins:

1. validate requirements;
2. reserve/consume required materials according to construction authority;
3. set building to an `upgrading` state;
4. record:
   - upgrade start tick/time;
   - required construction work/time;
   - target level;
   - milestone data if applicable;
5. progress over simulation time;
6. only when complete:
   - apply new level;
   - unlock milestone;
   - recalculate relevant building effects;
   - emit a completion event/cue.

A player cannot press Upgrade and receive the new level immediately.

---

# 9. No fake post-upgrade cooldown

Construction time itself is the pacing cost.

After an upgrade completes:
- the building may start another upgrade immediately if all requirements are met;
- there is no arbitrary "wait 5 minutes before upgrading again" cooldown by default.

If a specific building needs a recovery/stabilization period for lore/gameplay, model that explicitly as a building state, not a universal fake cooldown.

---

# 10. Building operation while upgrading

Default rule:

**ordinary level upgrade keeps the old level's function active until construction finishes.**

The new level effect is unavailable until completion.

Major milestone upgrades may define:
- full shutdown;
- partial operation;
- special preparation.

This is building data.

Do not globally stop all production during every minor upgrade.

Reason:
with many long-duration buildings, universal shutdown would make upgrading feel punitive and create unnecessary micro.

---

# 11. Construction speed

Construction duration may be affected by:

- base upgrade requirement;
- building type;
- upgrade level;
- Kiến Trúc / construction profession;
- number of construction workers;
- relevant sect policy;
- Chí Bảo;
- special tools/formations;
- temporary events.

Early game must remain playable without a specialized construction department.

Canonical direction:
- baseline construction progresses automatically;
- assigning construction specialists accelerates it;
- later, a Construction/Infrastructure organization may become strategically important.

---

# 12. Systems that MUST have real duration

These systems should not resolve as instant clicks in the long-term P3.7 authority:

1. building construction;
2. building upgrade;
3. mining/gathering work;
4. crop growth/harvest cycles;
5. forging;
6. alchemy;
7. talisman crafting;
8. formation crafting/installation;
9. medical treatment;
10. Secret Chamber occupancy;
11. rest/recovery;
12. travel to work points where map distance matters;
13. expedition/hunting travel;
14. hunting encounter/combat itself;
15. equipment repair;
16. spirit-beast training/rearing where implemented;
17. teaching/training sessions;
18. breakthrough attempt/preparation when long-term cultivation pacing is migrated.

Exact durations are data, not locked here.

---

# 13. Systems that should use TRUE cooldowns

True cooldowns are appropriate for:

- combat skills;
- active Pháp Bảo abilities;
- active Chí Bảo abilities if such actives exist;
- emergency escape ability;
- special formation activations;
- rare building active powers;
- boss/rare-world respawn timers where content requires it.

Do NOT use true cooldowns for:
- opening UI;
- assigning workers;
- changing normal policy;
- ordinary resource deposit;
- ordinary market sale;
- routine building upgrade after previous construction is complete.

---

# 14. Systems that use recovery/downtime instead of cooldown

Use stateful recovery for:

- fatigue;
- injury / Thương Thế;
- medicine treatment;
- failed breakthrough consequences;
- equipment repair;
- exhausted spirit beast;
- disciple stress/mood recovery.

This is more readable and creates real simulation consequences.

---

# 15. Crafting timing

Existing P2.6 forge craft is currently immediate.

P3.7 migration target:

**request/order -> crafter/facility works for real duration -> output item created at completion.**

Routine production can be policy/queue driven.
The player should not manually click every batch.

Craft duration depends on:
- recipe complexity;
- material/recipe realm tier and complexity;
- building capability;
- profession level;
- tools/buffs.

The same pattern applies to Alchemy, Talismans and related production.

---

# 16. Hunting timing

Hunting is not a button that instantly rolls loot.

A hunting trip includes:
- preparation;
- outward travel;
- searching/encounter interval;
- combat duration;
- rest/supply behavior if applicable;
- further encounters or return travel.

Rewards are still routed immediately when each encounter resolves according to the current loot authority:
- item/material -> main Sect Warehouse;
- personal progression/Contribution/Spirit Stone share -> disciple immediately.

No loot bag is required.

---

# 17. Timing and 1,000–3,000 disciple scale

Visible/important disciples may use detailed movement/work phases.

Background population must preserve the same expected timing without simulating every animation frame.

Batch resolution may use:

**elapsed time -> deterministic number of completed travel/work cycles -> exact state/resource/progression deltas**

Requirements:
- deterministic;
- save/load stable;
- no free resources;
- same authority as detailed simulation.

This is required before very large populations.

---

# 18. Locked decisions

1. Basic attack speed and movement speed are separate.
2. Existing skill cast time and cooldown remain separate timing fields.
3. Profession work speed is separate from combat speed.
4. Mining is a physical travel/work/haul/deposit loop.
5. Ore goes through the Mine's deposit point but ultimately enters the main Sect Warehouse.
6. Workers mine batches before hauling; no one-unit ping-pong.
7. Movement speed meaningfully affects real work throughput because travel consumes time.
8. Building construction/upgrades require real time.
9. Upgrade completion, not button press, applies the new level.
10. No generic post-upgrade cooldown.
11. Ordinary upgrades can keep the previous level operating; milestone shutdown is data-driven.
12. Crafting/healing/Secret Chamber/travel/repair also require real duration when their P3.7 migrations are implemented.
13. True cooldown is reserved for reusable powers/actions where a cooldown makes semantic sense.
14. Background large-scale simulation must preserve the same timing model deterministically.


---
