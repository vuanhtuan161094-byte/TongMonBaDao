# GAME SYSTEM ARCHITECTURE — TÔNG MÔN BÁ ĐẠO

Status: CANONICAL STRUCTURE AUTHORITY  
Updated: 2026-10-15 (governance section 4 only; gameplay specs unchanged)

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
- work/profession consumers of the canonical lục-duy authority;
- no separate generic work-Tu-Vi award for authentic V2 disciples. V2 passive Tu Vi belongs to cultivation/time authority and continues during ordinary work.

Canonical open-point six-foundation rules, quality derivation, Cơ Duyên checks and Dẫn Tiên recruitment are owned by:
`docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`.

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

## 4. Scoped implementation ownership and honest closure (OWNER DECISION 2026-10-15)

The former repository-wide **one-active-phase barrier is replaced**. Unclosed QA or a paused, non-overlapping roadmap phase does not automatically prohibit a separately authorized playable-game implementation packet.

- **One code writer per overlapping file/subsystem at a time.** Concurrent READ-ONLY design and QA are allowed. Two CODE packets may coexist only with explicit owner approvals, disjoint file/authority ownership, a common integration HEAD and no competing mutation of shared state/save/scheduler/contracts.
- **No implicit permission:** every CODE packet still requires a fresh owner instruction naming scope, path allowlist, preserved locked rules, persistence/migration risks, tests and exclusions. Design approval or this governance amendment alone is not CODE authorization.
- **Dependency gate, not bureaucratic queue:** existing OPEN/PAUSED work stays labeled OPEN/PAUSED. A known failure unrelated to the new packet is retained as a named debt with baseline SHA/evidence. If the packet **touches** that subsystem/scenario, reproduce or isolate the baseline, run focused comparative regression and resolve or explicitly gate the affected scenario before claiming integrated PASS. Never weaken assertions, erase legacy save goods or fake rewards to make a test green.
- **Evidence discipline:** no phase/piece is CLOSED without (1) explicit contract/ownership, (2) completed code for that contract, (3) official Godot 4.7.2 focused PASS, (4) cumulative regression PASS or clearly scoped, owner-accepted pre-existing exceptions that are proven unrelated, and (5) an updated `CURRENT_CHECKPOINT.md` naming the next work and debt. A documented exception is not a PASS and cannot waive a failing regression in a subsystem changed by the packet.
- **Physical/device evidence stays separately labeled:** Windows GUI, Android device, crash/storage-failure and large-population acceptance are never inferred from Linux headless CI. Only make such tests release-blocking for a packet when they are stated in its explicit acceptance contract; otherwise carry them as PENDING USER/release-gate debt.
- **Authority remains unchanged:** one canonical Warehouse, one scheduler/time source, one active disciple job, canonical V2 HP/Injury/EXP/realm, Sect-owned equipment, deterministic save/offline. New UI may only reflect genuine backend state.
- **Current priority:** owner chose Economy-A as the next **candidate** CODE packet while GP-02C1 is QA OPEN and DV2-03 PAUSED NOT CLOSED. Economy-A is DESIGN/PREP ONLY until a separate CODE allowlist authorization. Injury redesign inspired by 最强祖师 is DESIGN ONLY and must not silently replace verified GP-02C1 runtime.

This section supersedes historical single-phase instructions elsewhere in older checkpoints/specs; do not rewrite their historical evidence. A truly blocking overlapping dependency must be handled within the expressly approved scope or returned to the owner for a revised allowlist.

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
- A2R: Spirit Field on the same building framework;
- B1: ResourceRegistry + one canonical Sect Warehouse;
- C1: open-point six-foundation authority + Dẫn Tiên Đài recruitment.

Implementation evidence and exact gate status live in `CURRENT_CHECKPOINT.md`.

---

## 8. Current work discipline

At any moment:

- `CURRENT_CHECKPOINT.md` lists current CODE packets, QA-only OPEN debt, PAUSED work and independently approved design; status never changes merely because another packet starts.
- `NEXT_CHAT_HANDOFF.md` records the immediate authorized next action, file ownership, explicit exclusions and evidence obligations.
- Design specs describe intended mechanics and decisions, not proof of production/runtime readiness.
- A separately authorized, non-overlapping packet can start without administratively closing an unrelated historical phase, under section 4. The integration gate must expose any pre-existing failures as debts, not turn them into PASS.

---

## 9. FE-00 production frontend architecture (DESIGN ACCEPTED 2026-10-12)

Long-term decision: `docs/decisions/0003-fe00-godot-native-data-driven-frontend.md` (ADR-0003, accepted DESIGN ONLY). Godot-native data-driven frontend with one canonical gameplay/save authority; presentation-only `PresentationQuery`, read-only view-model snapshots, `VisualAssetRegistry`, fixed `SectLayoutDefinition`/isometric `SectMapModel`, visual actor controller/renderer, reusable Godot UI. Source A is benchmark/candidate art, NOT transplanted Unity authority. Existing `docs/P3_ASSET_REGISTRY.json`, historical approved visual contracts, source recovery and ADR-0002 LFS gate remain controlling. Fixed layout does NOT add placement fields to `BuildingState`. 13 Source A building candidates do NOT imply 13 persistent building instances. Android/Windows visual acceptance remains PENDING USER.

FE-00 review/design **CLOSED**, no Godot runtime pass implied. FE-01 is separately queued, **NOT CODE AUTHORIZED**; section 4 scoped-ownership/code-authorization policy applies. Do not switch main scene, enable Spine, import binaries by unverified transport, or rewrite gameplay in FE-00.
