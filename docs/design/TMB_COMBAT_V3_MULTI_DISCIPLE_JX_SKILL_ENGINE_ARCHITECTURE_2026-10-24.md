# TÔNG MÔN BÁ ĐẠO — COMBAT V3: SKILL ENGINE NHIỀU ĐỆ TỬ THEO CƠ CHẾ JX
**Ngày:** 2026-10-24 | **STATUS:** PROPOSED ARCHITECTURE / DOCS ONLY / KHÔNG CODE, KHÔNG PR29/UI/Source A, KHÔNG MERGE
**Owner direction:** “thôi khỏi cần bóc đi. t cần bạn học cơ chế ấy. với nhớ rằng game mình là nhiều đệ tử trong map nhé. xây dựng hoạt động tốt hãy làm.” → STOP original-JX extraction as dependency; prioritize game that works well with concurrent autonomous disciples.
**Branch baseline:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`; PR29 Combat V3-S1 HEAD `9522812e91b7ca5bc0cc108eb92e000e930fe850` remains draft, official Godot 4.7.2 QA pending at drafting.
**Existing authorities:** `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/COMBAT_STATS_V2_SPEC.md`, `docs/TECHNIQUE_V2_SPEC.md`, `docs/SPIRITUAL_ROOT_V2_SPEC.md`, `docs/CULTIVATION_PATH_V2_SPEC.md` and real PR29 code; design references the previous JX forensic report (derivative JX IDs/INI), but NO new JX extraction.
**Legend:** [LOCKED] canonical V2/owner; [CURRENT CODE] read directly at PR29 SHA, no test PASS implied; [PROPOSED V3] architecture/content needing owner CODE gate; [OPEN DECISION] numerical/detail choice not yet locked.

## 0. Product identity: This is NOT a one-hero JX combat clone

- [LOCKED] Player is a **Sect Master** commanding **many autonomous disciples**. World roster long-term **1,000–3,000 disciples**; only a visible/useful subset should render. Map/camera can freely roam; actor follow-camera only on explicit selection.
- [CURRENT CODE] One `MapBattleV2` local encounter accepts **up to 30 disciples, 40 monsters**, **max 6 disciples per party_id**, ARENA **36 × 20 logical world units**; `STEP_SECONDS=0.25`, standard finite battle `MAX_SECONDS=90`; current learned P2 catalog only 9 skills. The 36×20 simulation arena is NOT the 192×192 Sect world map, nor is 30 the maximum sect-wide disciple count.
- [LOCKED] Combat V2 remains authoritative, alongside canonical HP/Injury 0/1/120, skill learning, one active job, Warehouse, B3 CARE kill settlement and save/offline exactly once. Source A chibi style remains; learn JX mechanics, NOT impose a JX renderer.
- [PROPOSED V3] Scale architecture is **many concurrent local encounters** coordinated by one world scheduler, not 3,000 actors in one MapBattle. An encounter can contain multiple parties; Boss shared across parties in the **same local encounter** (one Boss HP, one kill event, one Sect loot pool; individual participation rules remain separate design and 60/40 NOT locked).
- [LOCKED DEV] On gameplay/code development version changes generate fresh DEV world/roster instead of migrating obsolete P2 disciples. **Within a build**, mid-battle save/reload, kill receipts, offline deterministic catch-up and inventory atomicity remain required. No save deletion or launcher edit in this design.

### 0.1 The on-screen gameplay test
In a world with 5 teams of 6 disciples and a 40-monster hunt area, players see some cast Fireball, Sword strikes, Guard and Heal, more than one elite spawn, teams reposition and fight continuously, actual enemies HP go to 0 exactly once, and correct rewards enter the canonical queue. Panning the camera must change only **visual workload**, not monster HP, encounter outcome, learning progress or drops. A different map area may run a distinct encounter in parallel without reusing the same monsters or Boss pool.

## 1. What to learn from JX mechanics (NOT original JX formula import)

| JX-like pattern | Original TMB mechanic | Multiple-unit hard rule |
|---|---|---|
| Martial path/branch, special technique | Skill family, explicit learning requirements, 3 lineages Nhân/Tiên/Thần | no auto-grant all clan skills or skills from visible VFX |
| Missile formation: single/spread/line/fan/ring | An authored projectile/geometry pattern, with explicit hit policy | 5 missiles do NOT automatically cause 5 valid hits on same target |
| Multiple strike pulses and child events | Bounded HitPacket/ChildPacket from ONE committed cast | casts have ID; each child has index, depth and per-target cap; no recursion |
| Opening/follow-up/finisher (JX2) | Typed target condition, actor combo state and optional short window | 30 actors have separate cooldown/window; no shared free proc state |
| On-hit and on-status proc (Kiếm Thế) | Conditional passive trigger, bounded ICD, stack cap and unique source | event-trigger budget per cast AND per encounter; no proc storm |
| Buff/debuff/control | Typed status with source+duration+stack/strongest rule+Boss eligibility | buffs by party/area/target explicitly; no full-map implicit buffs |
| Secret manual enhancing named move | Công Pháp/Mật Tịch modifier keyed by skill_family, source and uniqueness | one Main + two Support, no hidden global x2 from every known manual |
| Evolved ultimate with new geometry | Successor variant of a skill family | one exclusive successor equipped per family; caps declared per skill |
| Cooldown/cast/impact | Distinct fixed-step action, travel, status tick and cooldown | animation interpolation MUST NOT create gameplay hits |
| Skill learning/proficiency | 5 mastery stages with contribution-based XP | offscreen vs onscreen same XP if real effective contribution |

**Provenance caution:** Previous read of user Drive 270 VLTK catalog entries was a derivative browser catalogue with own balancing, not 270 verified raw executable JX1 skills. JXQY2 INI effect values lack known resolver units and JXQY2 is not JX2 Online. This proposal imports zero unverified numeric formulas. Learn mechanic categories, not port unknown values.

## 2. Ownership: one authority per outcome

### 2.1 Proposed operational boundaries
`SectPolicy/JobScheduler` (canonical): may issue legal HUNT/RETREAT/REST intents; One Active Job and Injury gates always checked. No minting loot/XP.
`WorldHuntCoordinatorV3` [PROPOSED new orchestration layer, not yet class/code]: assign ready parties to world_id/map_zone, own encounter lifecycle routing, allow multiple active local encounters and maintain encounter instance ID. Uses **same canonical simulation clock**; does not create a new real-time timer or separate resource wallet.
`MapBattleV2` [CURRENT CODE]: canonical actor HP/position, target, casts, status, RNG, hit settlement, HP0/domain kill event. V3 effect executor operates **inside** this authority or calls into it, NOT a second damage calculator.
`SkillCatalogV3` [PROPOSED immutable authored data]: skill definitions, geometry, status, condition, per-mastery/per-generation profiles, visual event IDs.
`SkillRuntimeV3` [PROPOSED helper executing inside MapBattle owner]: choose eligible slot, enqueue action, release packet, resolve targets, emit authorized damage/heal/status/move operations; NEVER commit kill/loot independently.
`CARE/PH2 + Warehouse/SaveService` [existing authority]: receives domain kill events with stable kill_id, commits receipts once, owns item/currency/material/XP changes. Owner rules for group participation/reward division may be documented independently; no 60/40 assumption.
`Source A Presentation` [existing presentation]: subscribe to semantic cast, projectile path, status/impact/death events; GPU/CPU particle budgets apply **only to visuals**. Camera does not feed simulation decisions.

### 2.2 A state transition must be observable and testable
valid disciple at Sect → queued HUNT intent → actual on-map encounter membership → AI slot choice → CastAccepted → projectile/child schedule → hit/guard/heal/status → kill event queue → canonical receipt/debit/credit → SaveService barrier → player-visible HUD/timeline. The UI never gets to invent a hit or resource. Replay of cast/impact/kill stays idempotent.

### 2.3 There are THREE different scales; do not mix
1. `World population` 1,000–3,000 disciples: mostly non-combat jobs/cultivation/rest, managed by cohort scheduling, not every actor with a per-frame brain.
2. `Active encounters` potentially several on a large map at the same time: distinct encounter_id / spatial zone; one encounter may contain several groups.
3. `One MapBattleV2` at present max 30 disciple actors / 40 monster actors and party ≤6: do **not** raise hard caps in a docs packet. If too many teams converge, coordinator queues/redirects/excludes excess *before* joining, never silently spawns extra copies of a Boss or splits one Boss into independent kill pools.

**[OPEN DECISION]** Maximum simultaneous local encounters on device, cross-zone pursuit, terrain/LOS grid resolution, whether every farm team needs a physical persistent map actor while camera far away, visualized combat load. Those need profiling and owner approval, not made-up device guarantees.

## 3. Data contracts, split immutable definitions from compact per-actor runtime

### 3.1 Proposed SkillDefinition v3 (authoring, not current Godot API)
| Field / type | Required meaning |
|---|---|
| `skill_id:StringName`, `family_id:StringName`, `generation:{nhan,tien,than}` | stable original content and lineage identity, distinct from graphics ID |
| `slot_type:{basic,active,combat_passive,static_modifier}` | 1+4+6 equipped caps; self-only stat modifiers don't consume reactive passive |
| `path_tags`, `branch_tags`, `element_tags`, `basis:{tuvi,body,hybrid}` | no automatic compatibility from art/color; RootV2 only where defined |
| `grade`, `learn_requirements[]`, `manual_id`, `training_cost` | realm/floor/Path/mastery/book/sect costs checked before learned=true |
| `cast{seconds,interrupt_rule,initial_delay,consume_timing}`, `cooldown{base,minimum}` | includes 0.25 s step quantization as current kernel policy |
| `target_query{side,relationship,sort,range,los,geometry,max_targets,friendly_fire}` | every AoE capped by its own definition, deterministic ties by IDs |
| `use_condition{}`, `trigger_predicate{}`, `priority_slot` | V2 slot1→4 policy; role/heal/CC guards resolved as predicates |
| `effect_graph_id`, `projectile_profile_id`, `status_ids[]` | reuses a small set of typed handlers, not bespoke scripts per skill |
| `mastery_profile_id`, `visual_event_ids[]`, `audio_cue_ids[]` | mechanics and visuals independent; 5 mastery stages |
| `max_child_depth`, `max_hit_packets_per_cast`, `max_trigger_count_per_cast` | anti-exploit runtime budgets; numeric ceilings to benchmark, not locked here |

Static authoring data is validated once at catalog initialization, indexed by ID, enums finite; refuse invalid links/cycles/negative durations/zero or unbounded target caps. **No arbitrary script expressions** embedded in skill records.

### 3.2 Per disciple (persisted), per encounter (ephemeral but snapshotable)
Personal persistent state: `learned_skill_ids`, `skill_mastery_xp_by_id`, `mastery_stage/gate`, `known_skill_history`, `equipped_basic_id`, `equipped_active_ids[<=4]`, `equipped_passive_ids[<=6]`, selected per-party policy/priority, `MainTechnique + Support2`, canonical spiritual roots/D7, TuVi/Body, current health/injury/job. These are **proposed V2 consumers**, not present in old P2 boolean-only skill store.

Encounter actor runtime: `actor_id`, `party_id`, `encounter_id`, `spawn_slot_id/generation` for monsters, `cast_sequence`, `casting_action_id`, `cooldown_until[skill]`, `next_basic`, `position`, `target_ref`, `status_instances`, `combo_windows`, `proc_cooldowns`, `contribution_evidence`, RNG stream/substream state. Actor-local proc state must **never** be stored as a single static global variable shared by 30 disciples.

One encounter runtime: sorted actor IDs or stable initiative, due-action heap/array, cast/impact records, spatial index, region zones, pending HP0 kill journal, ledger of stable committed hit/cast IDs and RNG state, versioned snapshot. No rendering sprites/camera handles in this snapshot.

### 3.3 Proposed CastAction/HitPacket identity (no duplicates on reload)
\`\`\`yaml
cast:
  encounter_id: encounter_42
  source_actor_id: disciple_17
  cast_seq: 122
  skill_id: hoa_cau
  target_actor_id: monster_8
  target_spawn_generation: 6
  start_step: 300
  release_step: 303
  result: pending | released | cancelled | resolved
  committed_cooldown_step: 300
effect:
  cast_seq: 122
  child_index: 0
  hit_index: 0
  collision_target_id: monster_8
  collision_target_generation: 6
  packet_kind: damage | heal | status | movement | visual_cue
\`\`\`
This YAML is a **schema illustration**, not an implementation and does not alter P2 existing cooldown rules. Deterministic action identity could be `encounter_id:actor_id:cast_seq`; hit identity appends `child_index:hit_index:target_slot:generation`. Disallow collisions/reuse. For a released projectile whose target dies or recycles in the same slot, **old generation must not hit new spawn**. Settle exactly once even if a frame is retried after save or network lag.

### 3.4 EffectGraph as bounded DAG, not free recursion
Types: `DirectHit`, `ProjectileLaunch`, `ChildHit`, `StatusApply`, `HealEffective`, `Guard`, `Mobility/Dash`, `AreaQuery`, `ZoneTick`, `BuffAuraApply`, `Cleanse`, `ComboOpen/Consume`, `VisualCue`.
Graph check: source→node links acyclic; explicit max depth, hits and proc per cast. Secondary hit does NOT itself trigger another identical secondary unless its authored rule explicitly permits a bounded branch and passes anti-recursion gates. Proc chain can't recursively generate kill credit or mastery repeatedly from one child.
Damage/crit/resist/damage reduction/roots/stat modifiers must route ONCE through `CombatStatsV2` + authoritative `MapBattleV2`; elements/readiness/strongest-status policies from canonical specs. One damage packet is one settlement; multiple graphical hit particles are NOT multiple settlements.

## 4. Deterministic multiple-team skill simulation (main implementation risk)

### 4.1 Four active slots and useful AI in a crowd
[LOCKED] Active slot priority 1→4; each is checked if cooldown/cast lock, range/geometry, valid target and **skill-defined condition** are satisfied. Fallback to basic attack. Do NOT turn into a global MOBA utility scorer.

**[CURRENT CODE GAP]** `MapBattleV2.step` currently checks healer generic `_heal_ally` and frontline generic `_guard_frontline` BEFORE `_try_learned_skill`; and it takes an array of learned skills, not an authoritative equipped 4-slot V2 structure. This produces potential skill starvation / role action not represented by learned book. V3 must propose a unified action candidate schedule respecting the locked priority **without silently deleting existing role actions**. This requires an explicit CODE owner gate and regression.

A future eligible skill decision:
- Hard guards: actor alive, not midcast/downed/Injury, correct encounter/party and equipped/learned, mastery gate, legal use, cooldown, target alive and generation current.
- Slot1→4 order: if Heal requires meaningful missing HP, guard requires threat, fire finisher requires active Burn at authored check point, AoE requires enough valid opponents, dash only if real distance gap, mana **not universal**. Invalid slot is skipped.
- Range/LOS/spatial query uses normalized world coords, stable deterministic tie break; healer party-scoped if the authored skill says party, not entire world. Support can broaden to allies in radius only when definition explicitly permits.
- Priority starvation test: a spammable slot1 should not prevent a slot2 follow-up if slot1's authored condition becomes false after its meaningful application; do not secretly reorder slots during combat.
- When AI can't find candidate, use basic strike/move to configured preferred combat band. Navigation path cache invalidated only on meaningful target/movement changes. NOT one pathfinding query per entity per rendered frame.

### 4.2 Multi-projectile / area semantics
- `ProjectilePattern`: direct, line, spread, ring, sequential, chain, ground persistent. Geometry and target count/missile count are DISTINCT.
- `hit_policy` one-per-target-per-cast, per-missile, or authored capped multi-hit, never default "every missile x full damage". `max_hits_per_target` explicit; `damage_budget_per_target` can be an authoring constraint, not a hidden nerf.
- Exactly one authoritative position/LOS/collision resolver and one source record at hit time. If projectile hits while target moves out of line: it applies or misses according to **specified** collision policy. Camera visibility irrelevant.
- Projectiles can be purely VFX for instantly resolved packets OR authoritative travel-time collisions; explicit `projectile_gameplay_mode` to prevent VFX animation pretending to be real impact. Start with existing P2 travel-time commit semantics for vertical slice.
- AoE target selection deterministic: filter legality then geometry, stable distance/ID ordering, cap; no global `MAX_TARGETS_AOE=3` assumption for all future skills. Maintain current generic=3 until an authorized typed-skill override lands.

### 4.3 Status/proc concurrency across six-person parties
- `StatusInstance` source actor, skill, target+generation, type, magnitude, apply_step, expiry_step, tick_step, stack_count, max_stacks/unique_group, dispel tier, interrupt policy.
- V2 current S1 burn/weaken strongest-only single status per family; V3 must not silently change burn into stackable 5 layers. New stackable mark/status TYPES explicitly authored separately, with test and owner sign-off.
- Cross-party behavior explicit: party heal defaults party; ally AoE may cover other parties only when written. Boss debuffs shared on **one Boss actor**, not copied into five per-team mirrors.
- Enemy control resistance/refractory must be bounded: multiple mages may not stunlock Elite/Boss with 30 independent freeze loops; actual immunity/tier values remain OPEN balancing.
- Trigger queue runs after committed effect, with per-source internal cooldown and per-step/per-cast safety ceiling; if capped, fail closed for that proc while preserving primary damage and note a testable diagnostic. Never drop domain kill journal or HP0 outcome to preserve VFX budget.
- Apply root/technique/equipment modifiers via source-key uniqueness groups so 30 party auras do not stack into runaway ATK. Status source ownership persists if caster leaves or dies according to explicit policy. S1 currently drops Burn when caster dies; change would require explicit approval and regression.

### 4.4 Shared Boss and reward integrity
Five parties can fight ONE Boss with ONE HP ledger and a single durable death identity `encounter_id:spawn_slot_id:generation`. All direct, DoT and proc packets are attributed to actual caster/source, so DPS/Tank/Heal/Support participation can be calculated from **effective** in-encounter evidence. No last-hit winner by default; **owner previously chose single Sect reward pool and individual TuVi rewards**, and 60/40 allocation remains UNLOCKED. No multi-hit damage should multiply drops. Downed disciple enters Injury once; no extra spawn/reward by toggling camera or leaving map.

## 5. World scheduler + render strategy for 1,000–3,000 disciples

### 5.1 Two-level scheduling (PROPOSED)
- **Tier A world cohorts:** 1k–3k roster receives infrequent canonical sim-tick policy/reassignment updates by team/work cohort (AT_SECT, DEPLOY_ELIGIBLE, HUNTING, DOWNED, RECOVERING, MANUAL_PAUSE). Check One Active Job, health, medicine, Injury120, active/retreat overrides before any scoring.
- **Tier B active encounters:** only teams currently engaged run actual Combat V2 action steps. Multiple encounters own independent IDs/RNG state and shared world clock mapping. For repeated camera switches, these must not be created or destroyed in a way that changes gameplay.
- **Tier C presentation:** only camera-visible actors, cast VFX, HUD indicators and important death/loot cues render at 1280×720. Sprite frame animation, distant particle detail, nameplates and particles may be culled/LOD. LOD MUST NOT cull authoritative hits, statuses, loot events or one HP pool.
- **Offscreen combat:** advance SAME Combat V2 rules with a bounded step budget, resumable deterministic catch-up. Coarse simulation may summarize movement/policy ONLY after proven equivalent; NEVER fabricate aggregate kills or drops in place of hit calculations. World encounter backlog must not be silently discarded if budget saturated.
- **Continuous maps:** no artificial end-of-fight 90s for continuous map mode; existing finite timeout stays for finite encounters. Encounter membership/spawn slot generations stable even on view/camera transitions.

### 5.2 Practical acceleration components, in approved order
1. Avoid sorting all actors and scanning all target candidates repeatedly when no candidates changed; stable cached IDs and dirty flags.
2. Spatial bucketing/grid for nearest-enemy/heal/area queries; deterministic squared distance + actor_id tie-break. Cache within step and invalidate on movement/death/spawn, not a stale proximity false hit.
3. Schedule cooldown/status/DoT events by next-due time; batch active work only, **preserve exact 0.25-second settlement**; do not skip actual combat due events or change RNG call sequence.
4. Reuse immutable skill definition references and compiled geometry parameters, avoid per-hit large Dictionary.deep_duplicate on 30×40 loops.
5. Render culling by camera/viewport, atlas reuse/Source A pooling, event rate cap for only visual streams, no per-frame UI state copy per actor.
6. Bounded progressive world ticks/offline catch-up; serialize a resumable cursor so 8 GB Windows and Android cannot freeze while settling 3,000 disciples.
7. Profile first; proposed budgets must be revised from actual Windows/Android traces before becoming hard limits. DO NOT rewrite renderer to fix backend scaling.

**Crucial engineering caution:** The current MapBattle implementation sorts actor IDs each 0.25s step, `_nearest_enemy` scans all actors for each actor, and `_actor_casting` scans pending casts. At 30×40 this can be a bottleneck if repeated across many encounters. Spatial index/due-action heap are FUTURE OPTIMIZATIONS; they must be parity tested, not merely assumed faster. Do not ship a new pathfinder or scheduler owner without actual perf evidence.

### 5.3 Capacity and QA proposals (targets, NOT locked caps)
| Fixture | Purpose | Acceptance required, no guessed measured FPS |
|---|---|---|
| F0: 1 team 6 vs 8 normals | P2/S1 baseline+single skill+save | exact SHA official Godot focused, no regression |
| F1: 3 teams (18) vs 24 monsters | ally scope, crowd targeting, AoE, heal/buffs | no cross-party phantom heal; deterministic hit order |
| F2: 5 teams (30) vs 40 monsters | max current local encounter, multi-hit/proc stress | no dropped HP0 receipt, bounded memory/CPU under benchmark |
| F3: one Boss + 5 teams | one Boss HP, different contributions, status/refractory | exactly one kill/loot settlement; no last-hit-only |
| F4: two or more independent active encounters | world orchestration + different map zones | no actor/missile ID collisions, no reward contamination |
| F5: roster 1,000 then 3,000 with few active teams | scheduling and memory | idle disciples no combat-scene per-frame processing |
| F6: camera on/off around same fight + mid-cast save/reload | presentation parity and state | HP/skill/mastery/rewards identical, VFX difference allowed |
| F7: 30 mages simultaneously cast multi projectile + status | 30×proc/collision upper stress | no proc recursion, hard guards; actual device frame budget measured |
| F8: far-map catch-up & replay after interruption | deterministic chronological catch-up | no fabricated result, idempotent journal and warehouse |

**Performance proposals only**: aim for responsive landscape 1280×720 on target Android and tolerable 8 GB Windows test box; use p50/p95 frame time, map sim-ms/tick, memory peak and queue lag as recorded metrics. Do not claim "60 FPS / 100 maps" without hardware. Camera may LOD visuals but never lower combat simulation correctness. Partition pressure thresholds based on PROFILING, not intuition.

## 6. Skill growth + large catalogue across the Sect
- [LOCKED] 1 basic +4 active +6 reactive passives **equipped** at mature stage, but arbitrary larger KNOWN list; static self-only stat modifiers outside 6 reactive slots. 3 paths Kiếm/Thể/Pháp, nine broad branches, 30 TuVi realms×10 +30 Body realms×10, root 1–100, techniques 1 main+2 support; same ability can be "Pháp/Hỏa/Active/DoT".
- [LOCKED] Five mastery stages Sơ Học→Nhập Môn→Tiểu Thành→Đại Thành→Viên Mãn and three distinct successor waves Nhân→Tiên→Thần. No imported JX universal 10/20 skill point level ladder. Cost, grade, exact unlock realm and curve need authored review.
- [PROPOSED] Data-driven skill family trees and typed effect primitives allow large shared catalogue without one GDScript file/hardcoded conditional per ability. Begin with **9 existing P2 skills** + 1 useful passive + one multi-projectile that verifies the engine. No hundreds of skill definitions before the engine is proven.
- [LOCKED] Skills known individually; sect archives/manuals, eligible learning and real contribution mastery. Kill provides rewards only from authorized canonical sources; no free "skill-cast XP" by firing at invulnerable targets or overhealing.
- [CURRENT CODE] PR29 S1 handles damage/burn/weaken/self-guard; `truy_phong_bo` dash and `liet_diem` burning payoff deferred S2. S1 official Godot focused **PENDING**, do not label PASS.
- [OPEN] exact content loadout, group aura stacking policy, Source A visual event mapping, boss control immunity, monster skill parity, skill family successor naming, per-mastery incremental ratios.

## 7. Non-negotiable replay and safety invariants
1. **One authoritative clock** and unambiguous mapping world tick ↔ battle 0.25 seconds; no time source derived from camera FPS. Mapping currently not proven across all parallel battles and must be made explicit before scheduling changes.
2. Deterministic actor IDs, spawn generation, source skill/cast sequence, target geometry ordering and seeded RNG. Independent world encounters must not unintentionally share one RNG stream or vary due to camera.
3. `CastAccepted` at most once per actor action slot; pending cast persists through save; an animation redraw cannot issue a new hit.
4. A single projectile/child hit ID settled at most once; no same target double-hit unless authored; no double life steal/crit/proc.
5. Boss single live actor/HP record per encounter; multiple parties do not create separate loot pools. Kill identity `encounter_id:slot:generation`, PH0 journal and PH2 durable receipt ACK only after committed save barrier.
6. World/camera toggle, quit/reopen, offline catch-up must not change the result for the same seed/time/inputs, except deliberate user-issued commands. No fast-forward drops of pending events.
7. Status, internal CD, combo windows, already released missiles and pending damage state must be snapshot-compatible in the same build. Owner DEV reset only removes **legacy compatibility obligation**, not save/replay correctness.
8. Injured 0/1/120 cannot redeploy at tick119; no One Active Job double assignment; actor leaving encounter via retreat does not secretly finish casts/collect drops.
9. Backpressure must halt/queue while preserving authoritative kills, not silently trim them with the visual event ring. Current code uses separate PH0 pending kill events; keep them separate from capped `MAX_EVENTS`.
10. Do not alter existing fixed combat bounds `30v40`, 6 per team, default AoE=3, MAP coordinates or attack tick without measured proof and explicit owner CODE approval.

## 8. Dependency order and architectural decisions
**Stage 0: FINISH PR29 S1 focused QA** separately by Codex; no overlapping writer.
**Stage 1: S2 existing P2 skill parity** — dash + burning combo under current MapBattle logic, unchanged author ratios, focused tests and snapshots.
**Stage 2: Minimal SkillCatalogV3 adapter & 4-slot AI** — typed learn/loadout, single valid skill dispatcher, role baseline conflict decisions; keep existing behavior behind test comparison.
**Stage 3: New bounded multi-hit/projectile/proc** — add 1 original multi-projectile family and 1 passive trigger, test 30v40 + no double kill/loot.
**Stage 4: Multi-encounter world coordinator** — multi team/map scheduling with actor/monster identity and one Boss pool, exact offscreen determinism and performance profiling.
**Stage 5: Manual mastery 5 stages + 1 Main/2 Support technique/root modifiers**, content-first rollout; link actual item receipt/manual archive and avoid a second warehouse.
**Stage 6: Expanded authored content 3 paths, evolving families** → evidence-led playable QA on Android landscape; Source A renderer reads semantic events and stays separate.

Stages are **DEVELOPMENT PROPOSAL**, not prior CODE authorization or locked historical phase numbering. Order can split backend workstreams only when file ownership does not overlap. Do not begin Stage2 while another Codex agent is editing same MapBattle/SkillLoadout files.

### Suggested review/owner gates
- **D1**: approve one Combat V2 authority + many independent encounters and one shared Boss HP per encounter.
- **D2**: approve typed SkillDefinition/EffectGraph including multi-hit/child/proc cap semantics (not numeric caps yet).
- **D3**: approve 4-slot learned AI precedence over existing generic healer/frontline role actions after compatibility tests.
- **D4**: approve explicit offscreen deterministic catch-up scheduling policy, platform-target profiler gates.
- **D5**: approve starter vertical slice versus broad catalog expansion; do not mistake design for implementation.

## 9. What was NOT done
No Source JX unpacking, no JX engine reverse engineering, no JX assets imported; no PR29 S1 code touched; no Godot executable or test run; no official performance evidence; no Source A/UI changes; no merge. This file is only the CONTRACT PROPOSAL for user review and later Codex packets.
