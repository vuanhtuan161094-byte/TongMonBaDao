# GAME SYSTEM ARCHITECTURE — TÔNG MÔN BÁ ĐẠO

Status: CANONICAL STRUCTURE AUTHORITY  
Updated: 2026-10-06

This document defines **where each gameplay system belongs** and **how phases are allowed to progress**.

It is not a progress log. Current implementation status lives only in `CURRENT_CHECKPOINT.md`.

---

## 1. Product identity

Tông Môn Bá Đạo is a large-scale living-sect management game.

The player is the Sect Master:
- builds infrastructure;
- sets policy;
- allocates groups/teams/resources;
- recruits and develops disciples;
- chooses strategic hunting/economic direction;
- intervenes directly only when useful.

Disciples are autonomous people:
- work;
- cultivate;
- hunt;
- recover;
- spend;
- equip themselves;
- form relationships;
- accumulate history.

The target long-term population is roughly 1,000–3,000 disciples.
The live map only needs to render a useful visible subset.

---

## 2. Authority layers

### Layer A — Core simulation

Owns deterministic gameplay state and rules.

Main areas:
- economy;
- needs;
- relationships;
- cultivation;
- spiritual roots;
- techniques;
- cultivation paths;
- combat skills;
- equipment;
- workforce;
- disciple generation/traits;
- root refinement;
- bloodline;
- physique;
- P3.7 resources;
- P3.7 buildings;
- future professions/hunting/personal economy.

Gameplay truth must live here.

### Layer B — Persistent state

Owns save/load-compatible data:
- `SimulationState`;
- `SectState`;
- `DiscipleState`;
- building/resource/item state;
- future hunting/team/profession state.

A presentation screen must never become the sole owner of gameplay values.

### Layer C — Presentation / map / management UI

Reads simulation authority and sends real commands.

Presentation may:
- display;
- select;
- focus;
- filter;
- issue commands;
- open management panels.

Presentation may not fabricate:
- building level;
- resource quantity;
- queue;
- production;
- upgrade progress;
- injury;
- ownership;
- cultivation;
- profession level;
- hunting reward.

### Layer D — Content definitions

Static definitions and balance tables:
- resource registry;
- building definitions;
- profession definitions;
- monster definitions;
- techniques/equipment/content data.

Content definitions describe possibilities.
Persistent state records what actually exists in the current run.

---

## 3. System boundaries

### Character authority
Canonical master:
`docs/DISCIPLE_MASTER_SCHEMA.md`

Separate:
- innate foundation;
- learned progression;
- bloodline;
- physique;
- spiritual root;
- traits/personality;
- equipment/loadout;
- living state;
- organization/social state.

Do not collapse these into one generic quality score.

### Resource / warehouse authority
Canonical spec:
`docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`

P3.7 uses:
- explicit resource IDs;
- realm-grade metadata;
- explicit realm/tier metadata;
- quantity-based resource use;
- one canonical Sect Warehouse for stackable resources;
- very large stacks;
- reserve/lock policy;
- no gameplay storage-capacity ceiling.

### Building authority
Canonical spec:
`docs/P3_7_BUILDING_TREE_SPEC.md`

Buildings use:
- real instances;
- Lv.1–100;
- worker slots/capacity;
- timed construction/upgrades;
- normal levels for scaling;
- milestones for new mechanics;
- specialty items only where thematically justified.

### Shared profession/work authority
Canonical spec:
`docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`

Owns:
- profession-level work-speed formula;
- generic percentage modifier channels for traits/content;
- graded profession-talent XP bonus;
- the shared lục-duy factor curve and one-role mapping;
- Cơ Duyên rare-event factor;
- Thông Tuệ profession-XP factor;
- passive Tu Vi while actually working.

Căn Cốt belongs to body-training/development authority and is not a generic profession stamina or hauling multiplier.

### Spirit Field authority
Canonical spec:
`docs/P3_7_SPIRIT_FIELD_SPEC.md`

Owns:
- plots;
- crops;
- seeds;
- crop policy;
- planting/growth/harvest timing;
- farming yield/quality;
- field-specific worker assignment and milestones.

### Time / movement / work authority
Canonical spec:
`docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`

Keep separate:
- movement speed;
- attack speed;
- cast time;
- skill cooldown;
- profession work speed;
- construction time;
- recovery/downtime.

### Hunting / loadout authority
Canonical spec:
`docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`

Hunting is the primary outward progression loop.
Ordinary material/item rewards go directly to the main Sect Warehouse.
There is no reward Loot Warehouse and no persistent Team Loot Bag.

### Long-term economy authority
Canonical parent:
`docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`

This owns high-level relationships between:
- hunters;
- rear-base professions;
- personal economy;
- Contribution;
- Sect economy;
- long-term scale.

---

## 4. One-phase-at-a-time development rule

There is **at most one active implementation phase**.

A phase is not complete until all five conditions are met:

1. **Contract** — scope and ownership are explicit.
2. **Implementation** — no known placeholder/fake authority remains inside the phase.
3. **Focused gate** — active-phase tests pass on Godot 4.7.2.
4. **Cumulative gate** — locked earlier systems still pass when phase is being closed.
5. **Checkpoint lock** — `CURRENT_CHECKPOINT.md` is updated and the next phase is named.

Before those five conditions are met:
- do not start the next gameplay phase;
- do not partially implement a neighboring system “while here”;
- do not expose unfinished backend values in presentation;
- do not add speculative UI for data that does not exist.

A newly discovered dependency belongs to the current phase if it is necessary to make that phase correct.
Otherwise it is recorded as future work and left untouched.

---

## 5. Status vocabulary

Use only these meanings:

### DESIGN LOCKED
Rules are agreed, but runtime may not exist.

### IMPLEMENTED / FOCUSED GREEN
The phase implementation and focused gate are green.
This alone does not close a phase if cumulative regression is still pending.

### BACKEND LOCKED
Implementation + focused gate + cumulative gate are green.
Presentation may still be separate.

### REAL WINDOWS PASS
The required gate was run on the user's Windows Godot 4.7.2 environment and passed.

### VISUAL ACCEPTED
User accepted the visual result.
Never infer this from backend/CI green.

GitHub Actions using official Godot 4.7.2 is valid runtime evidence, but do not relabel it as Windows evidence.

---

## 6. Locked baseline

Locked earlier gameplay/runtime:
- P0–P2.12;
- P3.1;
- P3.2 map/camera/selection/real disciple tabs;
- P3.3 disciple operational flow;
- P3.4 building management;
- P3.5 living-sect cues;
- P3.6A runtime slice.

P3.6A final visual acceptance remains user-owned and is not a blocker for backend P3.7.

Do not reopen locked phases without actual regression evidence.

---

## 7. P3.7 completed backend foundation

Completed backend foundation currently consists of:
- A1: generic BuildingState/BuildingSystem + Mine;
- A2: Spirit Field on the same building framework;
- B1: ResourceRegistry + one canonical Sect Warehouse.

Implementation evidence and exact gate status live in `CURRENT_CHECKPOINT.md`.

---

## 8. Current work discipline

At any moment:

- `CURRENT_CHECKPOINT.md` names the active phase, or explicitly states that no implementation phase is active.
- `NEXT_CHAT_HANDOFF.md` explains only how to continue that phase.
- design specs contain design, not chronological implementation diaries.
- completed-phase history is not duplicated across every spec.
- the next phase may be named, but may not be implemented until the current phase is locked.

---
