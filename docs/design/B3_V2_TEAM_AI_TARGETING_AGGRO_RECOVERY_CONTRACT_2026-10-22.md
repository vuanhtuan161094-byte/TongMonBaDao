# TÔNG MÔN BÁ ĐẠO — B3 V2 TEAM AI: TARGETING, AGGRO, CONTINUOUS HUNT, RECOVERY

**Ngày:** 2026-10-22 · **Tình trạng:** DESIGN / PROPOSED API & STATE CONTRACT — **NO CODE, NO GAMEPLAY CHANGE, NO MERGE**  
**GitHub main audited:** `461caca1171462e0da092f21108c5c1733157ad9`  
**Design branch:** `docs/b3-v2-architecture-redesign-20261022`  
**Parent:** `B3_V2_LIVING_SECT_CONTINUOUS_HUNT_ARCHITECTURE_2026-10-22.md`  
**Required sibling:** `B3_V2_PERSISTENT_PVE_WORLD_RUNTIME_CONTRACT_2026-10-22.md`  
**Concurrent owners:** Map, Character Studio, Source A SA-LIB (owner-reported running); Combat V5 visual owner pending. Do not touch their worktrees, outputs or scene/rig/converter files.

## 0. Executive decision — AI phải có thể chơi kiểu Evil Hunter, không biến thành bot chọn trận

**ĐÃ CHỐT (owner/canonical)**:
- PvE diễn ra **liên tục trên cùng map thế giới**, không 90s, không nối/reset finite battles, không màn WIN/claim theo đợt. Quái sống/chết/rơi/hồi riêng; Elite/Boss có thể tồn tại ngay bên cạnh quái thường.
- **Combat V2** vẫn tính mọi hit/crit/damage/lifesteal/cast/cooldown/range/effect/RNG. Phong cách Evil Hunter/JX1 chỉ là vòng gameplay/world + presentation, **không phải đổi combat formula**.
- Đệ tử vận hành tự động, người chơi quản lý tông môn theo policy → đội → chỉ thị ngoại lệ; mỗi đội tối đa 6; đội thường 5 là hướng spec, solo có thể theo trait/decision.
- **One Active Job**; không để AI chiếm người đã nhận Mine/Forest/Spirit Field/Alchemy/Body/reserved PvE; Injury production **0/1** với 120 ticks phục hồi và HP hạ gục theo settlement; không permanent death.
- Không địa hình cản/pathfinding/navmesh cho map săn, chỉ foot XY, mặt đất, hoa/cỏ trang trí. Những vật thể mỹ thuật không tham gia AI hay collision.
- Single clock, một Kho chung, reward per independent kill / exactly once; UI/Map/Studio không được phát lệnh damage/loot theo frame.
- Skill-use default theo `COMBAT_SKILLS_V2_SPEC.md`: xét active slot 1→4, điều kiện/cast/cooldown/range; dùng Thường Kỹ nếu không có active hợp lệ; chỉ 1 active action committed, không MOBA-grade kiting.

**MỚI ĐỀ XUẤT, CHƯA KHÓA:** TeamDuty policy structure, target score/risk gates, aggro model, pursuit/leash, team cohesion, healer support priorities, solo tuning, anti-churn, auto-resume thresholds, multiple-team assist, Boss eligibility/participation and AI tick cadence. **Không bịa số**: thresholds/timers/weights in examples below are testing fixtures only, never production balance defaults.

## 1. Findings actual GitHub `main` — what may be reused, what cannot

| Source | Evidence | Consequence |
|---|---|---|
| `godot/src/simulation/ai/decision_system.gd` | `evaluate` reacts to HP/stamina/personal goals; region chooser scores risk/profit/relationships/organization. Both write `disciple.last_decision`. Personal retreat uses `disciple.retreat_hp_ratio()`. | Reuse *concepts*, not as pure preview or per-0.25s planner; do NOT call `evaluate/choose_region` from UI to rank hypothetical teams. |
| `godot/src/simulation/ai/goal_system.gd` | Chooses personal RECOVER/WEALTH/GLORY/SECURITY/PREPARE/GROWTH, with legacy HP/stamina/wallet and inventory thresholds. | Legacy personal goals can influence optional safe preference, never override genuine team command or survival constraints. |
| `godot/src/simulation/organization/organization_system.gd` | `MAX_TEAM_SIZE=6`; canonical `TeamState.member_ids`/leader and `disciple_team_ids`; `hunter/logistics/guard` are legacy adventure behavior labels, explicitly **not** professions or rank. | Do NOT confuse organization `guard` with combat `frontline`; no second team membership list. Proposed TeamDuty references canonical team ID. |
| `godot/src/simulation/workforce/workforce_system.gd` | `issue_command()` can cancel a resource timer under permitted direct controls, release Body slot for accepted non-Body commands, and call `cancel_work_cycle(..., true)`; direct HUNT_REGION checks injury but is not a pure noninterruptive batch dispatcher. `next_action()` also mutates expiry/last_decision. | Team planner **must never use issue_command as eligibility test**; cannot silently call it on every chosen hunter. Create **pure admission check** and, only on granted transition, one authorized command owner preserving paid work. |
| `godot/src/simulation/combat/hunting_pve_run_v2.gd` | Begin validates 1..MAX_DISCIPLES, injury0/HP>0, saved active PvE, work cycle/Spirit Field/timed alchemy/Body slot. Its actor field `party_id` is explicit. | Reuse/extend admission contract while avoiding encounter terminal/claim. A member may be "team member" but not available to deploy until all guards pass. |
| `godot/src/simulation/combat/map_battle_v2.gd` | Actor loop sorted ID per 0.25s; current `_nearest_enemy` just closest living enemy (distance²), not risk-aware. Range/movement uses actual `move_speed`; healer heals ally same party if HP ratio below current 0.65; frontline self-guards when below 0.75; learned direct-damage skills first legal in configured loadout; boss/elite telegraph AoE; UI events capped. | Target selection policy can become world intent; **do not alter** V2 damage/speed/skill formula. Preserve real cooldown/action conditions and healer/guard semantics when refactoring. 0.65/0.75 are existing code conditions, not B3 team retreat defaults. |
| `docs/COMBAT_SKILLS_V2_SPEC.md` §§11–16 | Damage/support geometry/target limits, range profile melee/mid/ranged/backline; skill-slot priority 1..4, no default MOBA kiting, cooldown/cast travel distinct, no universal GCD. | Team AI is *simple layered choices*; don't invent predictive large utility optimizer for each combat action. |
| `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md` | Sect policy → team/group → profession roles → direct commands, survival overrides unsafe requests; team usually 5, solo traits direction. Historical injury 0–100 prose. | Implement 0/1/120 newer runtime authority, not old conceptual 0–100 bands. Hunter vs producer distribution approx 70/30 is soft policy target, not enforced quota. |
| `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md` | Auto-equip Sect-owned items/personal economy and skill progression, no mini-inventory loot bag; injury/meds/supplies/downtime are cost. | Team readiness considers *real equipped kit and supplies*; gear review belongs to item/workforce system, not a fake combat-power damage stat. |

### Important technical gap
`MapBattleV2` uses finite `setup()/run()`, WIN-on-empty-monsters and 90s timeout; its sorted-actor attack loop/skill runtime are relevant to port, but world AI **cannot be implemented by repeatedly calling `setup()`** after an encounter. Parent Persistent PvE World contract owns world actor lifetime and a shared Combat V2 kernel. This AI contract assumes that runtime only after a separate authorized CODE integration.

## 2. Three tiers of decision ownership (clean single owner)

~~~text
SectMasterDirective (POLICY / priority / risk / deployment ceiling)
     ↓  when roster/job/goal/region/source changes
TeamPlanner (PURE; TEAM-SCOPE; decide zone/patrol/fallback/boss eligibility)
     ↓  valid admission + one authorized TeamDuty transition
TeamDuty Runtime (WORLD-SCOPE; depart, travel, patrol, fight, withdraw, recover)
     ↓  at a real canonical AI decision point / change of target
ActorIntentSelector (PERSONAL-SCOPE; target, preferred distance, movement intent)
     ↓  action/skill slot validation
CombatV2WorldStep (AUTHORITATIVE attacks/heal/cast/projectiles/range/RNG)
     ↓
Kill/HP/Task domain events -> World/Team policy reevaluation as needed
~~~

**Write ownership**
- UI: issues idempotent command IDs and displays reason codes; no change to HP, movement, cooldown, rewards or elapsed time.
- Team planner: pure input snapshot → immutable proposal; deterministic tie-break; no update to `DiscipleState.last_decision` or workforce command.
- World team executor: one place reserves team/actor duty and dispatches commands when admitted; cannot create a separate clock/damage source.
- Actor intent: controls intent/target selection within legal bounds; true cast selection and effects remain Combat V2. Face/animation state exported for presentation, never an AI input.
- Personal `GoalSystem` remains separate when not assigned to continuous hunt; one actor not simultaneously in legacy COMBAT or production.

**Priority rule (proposed ordering):** authoritative fatal/unsafe state or real job reservation → explicit valid player override (within safety limits) → team duty/policy → personal preference. The owner may **request** a forced high-risk hunt, but the engine should reject a guaranteed invalid action (injury, unavailable member, missing source, active work) rather than fake success.

## 3. Persistent data model (proposal, no live schema)

### 3.1 TeamPolicy

~~~yaml
team_id: canonical TeamState.id
policy_revision: int
mode: CONTINUOUS | PROGRESSION | MATERIAL_PRIORITY | GEAR_CHASE | BOSS_HUNT | RETURN | HOLD
region_allowlist: [zone_id]
patrol_area_id: authored boundary
target_tags_allowlist: [species_or_tier_tags]
target_tags_blocklist: [boss_if_unsafe_or_owner_choice]
boss_permission: DISALLOW | ALLOW_WHEN_SAFE | PLAYER_PINNED
risk_posture: CAUTIOUS | BALANCED | AGGRESSIVE
retreat_policy_id: validated health/supply/party policy source
supply_policy_id: canonical medicine/consumables
after_goal: CONTINUE | NEXT_OBJECTIVE | RETURN
auto_resume: true_or_false
priority: owner-defined order
~~~

All choices are **proposed keys**, NOT production defaults. Avoid duplicating member list. A policy change is a versioned command; applying it must never retroactively reroll loot or interrupt a committed cast without defined world rule.

### 3.2 TeamDuty state

~~~yaml
team_id: canonical
policy_revision: int
state: WAITING_TEAM | PREPARING | TRAVELLING | PATROLLING | ENGAGED |
       WITHDRAW_REQUESTED | RETURNING | RESTING | RECOVERING | BLOCKED |
       PAUSED_BY_OWNER
world_id: actual world key or empty
zone_id: actual zone id or empty
eligible_member_ids: [canonical ids at admission / revisable via safe transition]
formation_hint: none_or_authored_profile
current_goal_id: optional
current_target_instance_id: optional (never generic species only)
last_objective_switch_step: int64
last_target_change_step: int64
issued_command_id: stable id
owner_stop_pending: bool
blocked_reason: typed code
resume_after_recovery: bool
~~~

**Invariants:** no team has two active duties in different worlds; no disciple in two active team duty rosters, even when historical TeamState differs; team member removal/transfer during ENGAGED requires safe transition; combat actors maintain their own HP/cast/cooldown across target changes. Note that TeamDuty `eligible_member_ids` is a *current admission snapshot*, not a rival organization membership authority; rebuild against canonical TeamState on resume.

### 3.3 Actor AI intent state

~~~yaml
disciple_id: canonical
world_actor_id: stable ID
team_id: canonical or explicitly solo
ai_state: IDLE | FOLLOWING | SEARCHING | APPROACHING | ATTACKING |
          CASTING | SUPPORTING | RETREATING | DOWNED
target_monster_instance_id: generation-aware ID or empty
assist_ally_id: optional
movement_goal_foot_xy: canonical world coordinates
preferred_range_profile: MELEE | MID | RANGED | BACKLINE
next_reconsider_at_step: nonnegative int64
target_lock_until_step: nonnegative int64 (policy anti-churn; not physics)
last_safe_decision_reason: typed code
~~~

`hp`, cooldown, buffs, pending cast and actual foot XY belong to **PvEWorld actor runtime**, NOT a second AI database. Intent stores references and decision schedule only. If an actor is downed, AI intent cannot revive them; Injury settlement belongs to canonical character/world.

### 3.4 Monster engagement state

`monster_instance_id` uses immutable `world/zone/spawn_slot/generation`. AI may reference monster `target_actor_id`, current combat participant IDs, spawn home foot XY and last legal attack time, but **must not** duplicate authoritative HP/RNG per team. Engagement target claims are **soft hints only**, NOT exclusive leases: two teams or several disciples may target/strike the same monster.

**Not implemented:** generalized Threat/Aggro score as new Combat Stat. `docs/COMBAT_STATS_V2_SPEC.md` forbids a universal `Threat` stat. Aggro here is **a stateful target-selection rule/attention behavior**, not a new character attribute, damage multiplier or taunt power unless authored skill already provides it.

## 4. Team state transitions and legal event sources

~~~text
                             STOP / HOLD / no team
                              ┌─────┴───────┐
CREATED → WAITING_TEAM ──→ PREPARING ──→ TRAVELLING ──→ PATROLLING
             ↑                 │                  ↑         │  ↑
             │    BLOCKED/     │                  │         │  │ kill / target dead
             │    no supplies  v                  │         v  │
             └─────────── BLOCKED             [zone] ←── ENGAGED
                                  ▲                          │
                                  │                    low HP / depleted
                                  │                          v
                     RECOVERING ← RESTING ← RETURNING ← WITHDRAW_REQUESTED
                          │
                          └─ eligibility+auto_resume → WAITING_TEAM/PREPARING
~~~

Transitions are gameplay-authoritative and event-driven, **not per-frame state writes**. Team state can be `ENGAGED` even when individual disciples select different monsters; no WIN/DEFEAT/TIMEOUT of whole map.

| Source event | Team transition / response | What must NOT happen |
|---|---|---|
| owner assigns continuous hunt | WAITING_TEAM → PREPARING only on pure admission OK | No implicit issue_command() on occupied workers, no silent cancel |
| member occupied/injured/HP<=0 | WAITING_TEAM or BLOCKED with exact reason; optional legal subset only after explicit policy | Never steal Body slot/Field timer or fake team roster |
| supplies ready + region valid | PREPARING → TRAVELLING and track canonical elapsed travel | No 0-time teleport unless real source travel authority allows |
| reached zone | TRAVELLING → PATROLLING/SEARCHING | No reset of PvE world/monster generations |
| target identified in valid range | PATROLLING → ENGAGED | No separate MapBattleV2.setup per target |
| monster died | Kill receipt independent; actor reacquires target; if team has no targets, PATROLLING until respawn | No WIN wave/Claim/90s reset |
| another team targets same mob | Both can attack one HP; individual AI may switch via soft assignment | No cloned monster or double reward |
| target Boss too dangerous | exclude Boss and continue other legal farm; if only Boss remains, PATROLLING/BLOCKED_TARGET rather than suicide | No forced Boss chase for MATERIAL_PRIORITY |
| HP/supply/risk threshold crossed | WITHDRAW_REQUESTED; committed casts and injury processed by world; return when legal | No mid-cast deletion of valid kill/receipt |
| disciple downed | personal DOWNED, after canonical Injury settlement; safe remaining team evaluates policy | No world terminal defeat; no full-party HP reset |
| returned | RETURNING → RESTING/RECOVERING; real medicine/heal/duration | No instant Injury clear; no loot bag invented |
| healed/recovery timer reached | eligible AUTO_RESUME → WAITING_TEAM → PREPARING, re-check **all jobs** | No automatic theft of subsequently assigned Mine/Field work |
| owner PAUSE | prevents new target intent/deploy at barrier, settles already committed domain events | No rollback committed kill or dead monster resurrection |
| owner RETURN | safe withdrawal/return even if target alive; other actors keep world running | No terminal WIN/loot for leaving |

**Transitions open for owner design:** if team has 5 and two fall, whether survivors continue with 3 or withdraw immediately; when an injured disciple is replaced; a group command may be postponed until finished casts. Make these config policy, not a universal hardcoded "team all retreat at one injury."

## 5. Target-selection AI without unnecessary complexity

### 5.1 Candidate collection / hard filters

At target acquisition or meaningful world event, collect monster instances in actor perception radius from authoritative world index. Sources:
1. living instance, HP>0, same accessible region/world, not out of legal region footprint;
2. targetable by actual Combat V2 / intended skill geometry and movement rules; do not aim at old generation or phantom sprites;
3. not prohibited by Sect/Team policy (rare/Boss allowlist, region restriction, manual protect tag);
4. obey leader/team danger policy, current actor/team HP/readiness and available supplies; no suicidal order;
5. not an ally, no collidable obstacle/navmesh because maps are flat.

**Boss danger gate precedes any scoring**; if excluded, 1,000% imagined loot value cannot override it. A high-risk policy may allow harder targets only *within valid equipment/HP/content constraints*; score is advisory, not damage authority.

### 5.2 Soft assignment and target selection

Use two passes (proposed):
- **Team opportunity** (event-based): choose local area and monster tier/source objectives with stable preference. Avoid oscillating region every 0.25s; change on safety, invalid target, objective complete or meaningful improvement. Do not block all team actors onto one monster.
- **Personal actor target** (on target death/loss/new command/reconsider tick): choose eligible local enemy by risk-safe desirability and real foot distance, optionally lightly penalize monsters already pursued by enough allies. For Boss/elite allowed by policy, permit multiple actors/teams to focus same target. Stable IDs break equal-score ties.

Example symbolic score:
`candidate_utility = policy_goal_fit + reachable_proximity + party_role_synergy + useful_source_fit - validated_risk_cost - soft_overfocus_cost - pursuit_time_cost`.
**No numeric weights approved.** Hard safety and target validity run first. Risk may estimate V2 derived stat consequences, relative realm, present HP and skill range, but `combat_power` is **not** authority for damage or a guaranteed survival oracle.

**No target flapping**: keep an existing valid target until dead, unreachable, prohibited, unsafe or a materially better candidate is presented under a configured reconsider rule. Pure stable tie-break by `world_id/instance_id`. Target lock NEVER prevents emergency retreat/heal/owner STOP.

### 5.3 Movement and engagement distance

- Position input is authoritative **foot XY**, not sprite top-left or animation center. Two sprites may visually overlap, foot positions remain distinct.
- **MELEE** approaches into legal basic/skill range; **MID/RANGED** moves into preferred legal range; **BACKLINE** follows/supports legal ally within healing/cast range. Do not hardcode one shared radius for every weapon/skill.
- Simple straight-line pursuit on flat bounded ground. Actor turns, walks or attacks at V2 move speed and 0.25s steps. No pathfinding, collision obstacles or unnatural instant teleport.
- If a ranged actor has an enemy too close, optional modest repositioning can be designed only after parity, without default kiting loops or free extra attack while moving. **OPEN.**
- **No arbitrary cooldown reset when changing target, region or team.** A cast already committed has its own target ID/due time and Combat V2 cast interruption law; auto retarget only if the real authored skill permits.
- Group leader may suggest patrol destination/cohesion. Do not require rigid six-actor formation; mixed-range parties spread naturally. `TeamState.role_assignments` legacy Hunter/Guard/Logistics cannot create unapproved defensive mechanics.

### 5.4 Aggro and leash — conceptual, not new combat stats

Monster attention can use **current legal target reference + deterministic retarget event**, not a global `Threat` attribute. Suggested inputs: valid enemy within detection range, distance, actively damaged/attacked, return-to-spawn region, authored behavior tag (normal/elite/boss). **Distance/priority rules are OPEN and versioned content**, never silently change V2 damage calculation.

A monster chasing beyond its spawn home may enter **RETURN_TO_HOME**. If source policy resets HP upon return, whether to do so and how to prevent infinite kiting/Boss heal exploit MUST be explicitly signed off later. In the meantime, world test marks unreachable monster as not farmable and logs reason rather than creating repeat kill.

**Boss:**
- Conservative AI excludes Boss when absent `ALLOW_WHEN_SAFE` or explicit permission, before utility score.
- A weak team prefers normal monsters even when Boss is visually near.
- If several teams engage the same Boss: one HP, one instance, one death/loot. Personal participation and anti-leech/raid distribution **OPEN**; don't invent "last hit gets everything."
- If Boss is too strong, safe team can seek normal mobs or leave. Actor must not stand endlessly attacking a target permanently out of reach.

## 6. Skills and actor local decisions: Combat V2 ownership

The World Team AI **does not** implement another skill selector or free skill uses. Its actor AI provides target and movement intent; the **Combat V2** active-action flow remains:
1. Check committed cast/action: cannot begin another active action if current action occupies actor, except authored mechanic.
2. Eligible support: healer's real same-party heal, frontliner's legal guard and own role/skill behavior per actual V2 kernel.
3. Scan learned authored active skills in slot order **1 → 4** for target/range/cooldown/geometry/effect conditions. In current `main`, `_try_learned_damage_skill` only implements some learned direct damage skills; do not pretend future Burn, Dash, Cleanse, etc. work.
4. If no skill legal, approach target until basic attack range, then ordinary Thường Kỹ when ready.
5. Projectile and telegraphed AoE release only at authored ready time, with deterministic target/caster identity; cast cannot hit re-spawned new generation accidentally.
6. Cooldown/cast/attack/move speed separate; no generic global speed stat or universal mana/GCD invented.

**Special attention:** the existing healer uses ally <0.65 HP ratio and range<=6; frontliner guard below 0.75 own HP; these are *current runtime thresholds*, not B3 party retreat HP settings. Skill AI spec permits conditional support, but only implement actual supported skills when extracted into world kernel. No free healing in PATROLLING unless authorized rest/heal consumer exists.

## 7. Retreat, sustain, reinforcements and auto-resume

### 7.1 Safety evaluated independently of target desirability

**Hard stop on admission:** Injury!=0, HP<=0, active conflicting work/PvE, missing character/zone, invalid canonical equipment/content, missing supply if policy requires. If owner explicitly orders unsafe content, return an actionable reason code. No forced cancel by automation.

**Ongoing hunting safety:** actor HP and party survival, actual spent medicine/consumables, exhausted supplies, live target tier/skill risk, combat channel status and injury transitions. Trigger RETREAT_REQUESTED only when a policy threshold or hard invalidity is met. The threshold should be based on actual HP ratio/personal `retreat_hp_ratio()` where compatible, but party threshold composition/override needs owner confirmation.

**Withdrawal behavior proposal:** stop acquiring new hostile targets first; existing cast/projectile/valid kill events follow Combat V2 rules, then movement toward a safe return anchor with time cost. Retreat is **not invulnerability** and no teleport; enemy chase/leash must be decided. World death while withdrawing still settles injury once. If the implementation cannot guarantee safe incremental retreat, `BLOCKED_WORLD_RETREAT_CONTRACT` is more honest than deleting combat actors mid-AoE.

### 7.2 Recovery and return (no fake heal)

- Once an actor is downed, authoritative HP/Injury settlement remains **HP=1, Injury=1**, recovery after 120 **scheduler** ticks from recorded tick as in current `HuntingPveRunV2`; no death permanent, no instant stand-and-fight without real heal law.
- Other members can keep fighting **if** policy permits and legal party/readiness remains; one actor Injury does not end entire world or reset enemy HP.
- Returned members REST/HEAL with actual existing services/materials/ticks; production code must decide what legitimate heal makes one hunter eligible again. Do not set HP to max on resume just because time elapsed.
- `AUTO_RESUME` only when a team policy explicitly enables it (recommended default subject to owner signoff) and all selected members are once again eligible, supplies affordable, region unlocked, team membership stable, no new job/training reservation, old world duty already released, no lingering receipt/injury task.
- **Critical race:** while a hunter rests, manager can assign them to Linh Điền or Rèn Thân Đường. Auto-resume must **not cancel the new job** or call `issue_command` on that worker. Team goes WAITING_OCCUPATION or forms approved legal subset; it does not force redeploy.
- A mixed team policy may either WAIT_ALL, DEPLOY_ELIGIBLE_SUBSET (at least one, <=6, with safety), or ASSIGN_AUTHORIZED_STANDBY; all **OPEN**, not an automatic substitution stealing another team's member.
- Boss kill after owner STOP may still be payable if a committed in-flight cast legally killed Boss; reward persists and leader returns, not a second Boss kill after resume.

### 7.3 Supply economics

Hunting never pays an arbitrary entry fee. Real costs: travel time, valid stamina/supplies, medicine, injury, recovery and potentially authored durability. `SupplyPolicy` references canonical services and stock; no invented personal loot inventory. Consumption must be exactly once at actual valid action and not per AI evaluation. Refit at sect uses sect shared stock only under authorized policy/locks; no double-spend if two teams request last medicine.

## 8. Solo vs multi-team vs Boss (worked examples, fixtures not balance locks)

**Scenario A — Solo Kiếm Tu against 3 normal mobs**  
Disciple has allowed solo policy; begins at safe spawn foot, chooses nearest legal safe normal mob, approaches to own weapon/skill range, slots 1→4 then Thường Kỹ as valid. On death of mob A, A receipt committed once and A respawn deadline recorded; actor continues to B (not new battle). Trait Cô Tinh/Độc Hành potential bonuses **not injected** until real V2 trait consumer exists. If more mobs pile on and HP crosses real safety threshold, actor retreats/returns; no automatic solo bonus with invented multiplier.

**Scenario B — Team of five, mixed roles**  
Two melee frontliners and ranged/mage/healer characters share a persistent world; target preferences spread against A/B/C normals if focus-firing would overkill; healer only heals same-party eligible ally with valid current skill; combat targets stay legal. A and B die on different steps, each one receipt and respawn. When none alive, team PATROLS/WAITS for eligible spawn while cooldown/HP/time continue; 120 seconds passes without world ending. Visual effects come from Map/V5, not authority.

**Scenario C — Weak party sees Boss while farming rare herb**  
Boss present with 3 weaker mobs. Hard policy blocks Boss given risk/source-readiness; party selects normals/herb-source mobs. If only Boss exists, party does not suicide or glitch: WAIT_TARGET / change legal patrol area or return based on policy. No fake guaranteed herb from Boss or default 5-battle rare chance.

**Scenario D — Two parties target one elite/Boss**  
Team A and Team B act in same zone. They share one monster_instance_id and its HP. Both may cast; if both final attacks land in same 0.25s step, one lethal transition/sect loot receipt. Personal credit rules await distinct boss-cooperation contract; no double drops, no copy of Boss for each team. A team ordered RETURN exits only via lawful withdrawal; team B's combat continues.

**Scenario E — One member is at Mine or Body Training**  
Leader attempts to dispatch five; 4 eligible, one has real mining/Body reservation. Planner returns WAITING_OCCUPATION / proposed four-member subset **if** policy allowed; no `issue_command` to test, no canceled timer or stolen job. After miner finishes, team may dispatch when permission/eligibility true, without time retroactivity.

**Scenario F — Injury and auto-resume race**  
Hunter goes HP0. Combat V2 down transition triggers canonical Injury1; at sect actual +120 scheduler ticks recovery (assuming still correct mode) plus legitimate HP/medicine readiness. During downtime Sect Master assigns hunter to Linh Điền. Even when Injury clears, TeamDuty keeps WAITING_OCCUPATION; no auto-cancel field to restart hunt. Once freely available and policy permits, deploy via new command ID.

**Scenario G — Ranged DPS changes target while projectile in flight**  
Target A dies from another attack; projectile cast against A generation 12 remains linked to that exact identity and follows real V2 cancel/miss rules. A generation 13 respawns at same XY but doesn't inherit the old projectile. No duplicate AoE or reset cooldown.

**Scenario H — Empty zone at 90s and again at 10 minutes**  
Team stays PATROLLING, no WIN or fake claim, cooldown remains. If next respawn occurs while no viewer/map scene loaded, world event agenda still provides it at canonical time if that region is active under approved offline simulation. No animation-based respawn or memory leak.

## 9. API proposal — separate pure plan from mutation

~~~text
# Reads only
get_team_policy(state, team_id) -> TeamPolicyReadOnly
get_team_status(world_state, team_id) -> TeamDutyView
preflight_team_deployment(snapshot, team_id, region_id, policy_revision)
  -> {eligible_ids, conflicts[{disciple_id,reason}], risk_flags, can_deploy}
rank_region_candidates(snapshot, team_id, allowed_regions) -> [SafeRegionProposal]
plan_team_target(snapshot, team_id, local_instances) -> {target_ids, reasons}
plan_actor_intent(snapshot, actor_id) -> {target_generation_id, movement_goal, skill_target_context}

# Single authoritative owner only, no UI direct writes
submit_team_policy_command(command_id, expected_revision, policy_delta)
  -> {accepted, revision | rejected_reason}
authorize_team_deployment(command_id, expected_team_revision, preflight_revision)
  -> TeamDutyTransition
advance_team_duties_at_world_step(authoritative_step)
  -> [validated_actor_intents]  # no damage
apply_combat_v2_world_step(actor_intents) -> world domain events  # damage owner
observe_world_events_in_order(domain_events) -> TeamDuty transitions
request_safe_withdrawal(team_id, command_id) -> {accepted, effective_barrier}
reconcile_team_duties_on_load(saved_world_state) -> idempotent WorldDutyResult

# Output only
project_team_ai_view(snapshot, team_id) -> {state, target, HP/supply, risk, reason}
~~~

Contracts: every read-only call must operate on immutable/detached state; all command APIs have stable IDs and revision guards, no double deployment, no RNG use from preview and no immediate reward. The canonical world advances time only once; AI planning runs at event/reconsider points, while Combat V2 kernel has its real authoritative 0.25s stepping. UI must never call `MapBattleV2.step` itself. Actual names/implementing files are **NOT LOCKED**.

**Reason codes (proposal):** `WAITING_OCCUPATION`, `WAITING_INJURY`, `LOW_HP`, `NO_SUPPLIES`, `NO_VALID_ZONE`, `NO_SAFE_TARGET`, `WAITING_RESPAWN`, `OUT_OF_RANGE`, `TARGET_GENERATION_EXPIRED`, `BOSS_RISK_EXCEEDED`, `ACTOR_ALREADY_RESERVED`, `WORLD_SAVE_PENDING`, `COOLDOWN_PENDING`, `OWNER_PAUSED`, `NEEDS_RECOVERY`. A reason code must not trigger new payout or a fake terminal battle result.

## 10. Scheduling, determinism and mobile performance

**Proposal:**
- Combat continues at V2 0.25s authoritative steps under one clock.
- **Team policy evaluation only on events** (new directive, roster change, vacancy, zone depleted, explicit target priority, retreat, recovery, source unlock), not 4x per second per 3,000 disciples.
- **Actor target re-evaluation** on target death, out-of-range/lost, illegal target, incoming severe risk, scheduled reconsider; cache short legal intent between events. No per-frame global scan for every enemy.
- Spatial indexing by small buckets of foot XY may speed up nearest-candidate reads with no navigation/obstacle physics. Sort stable entity IDs when costs are equal; no dictionary-order RNG.
- Anti-flapping: minimum dwell/meaningful-improvement thresholds are tuning **OPEN**; target lock never outranks danger/cancel/owner controls.
- Rendering viewport only sees a subset; off-screen authorized teams keep the same deterministic actor intent and domain events, not a simplified alternate reward generator.
- Persistence includes team duty + target/command/reconsider cursor and world actor combat state + RNG; closing app/zoom/pan/restarting doesn't change outcomes with identical state/commands.
- Offline backlog is bounded and explicitly recorded when not processed; no pseudo kills/hours × average drop.

Measure: `AI_proposals/minute`, `target_switches/minute`, `path_distance/kills`, `unproductive_chase_time`, `rejected_job_steals`, `valid_hero_skill_casts`, `Boss_survival`, `reattempt_after_injury`, `world_substeps/sec`, `save_restore_parity`, `combat_profiling_memory`. Telemetry must not seed gameplay RNG.

## 11. Focused behavior/contract test design (NOT RUN)

| Gate | Test case | Pass definition |
|---|---|---|
| TAI-01 | Team 1–6 members, duplicate ID, member in two teams, leader absent | Invalid admission rejected; valid team canonical only |
| TAI-02 | Mine timer, Forest carry, active Field, Alchemy, Body reserved | No implicit timer cancellation, item loss or job stealing |
| TAI-03 | `preflight_team_deployment` repeated 1k times; UI preview | State/hash/RNG unchanged |
| TAI-04 | One world >90s and >10m, spawn independent | No world terminal/no HP/skill reset, two independently credited kills |
| TAI-05 | Target A death generation 12, new A' gen13 same spot | Projectile/AI stale target cannot damage A'; no stale reward |
| TAI-06 | Boss too strong, normal mobs nearby | Risk hard filter excludes Boss, party picks legal normal mob |
| TAI-07 | Healer and guard actual V2 abilities with same-party restriction | No invented skill effect, timing/cooldown matches Combat V2 |
| TAI-08 | 5-member mixed range team, 3 normal enemies | Foot XY movement, legal range, no rigid formation/teleport |
| TAI-09 | Solo permitted, no trait bonus implemented | Valid solo behavior, no made-up multiplier or guaranteed loot |
| TAI-10 | Two teams hit one Boss same substep | One HP, one monster death and Sect receipt; personal attribution unimplemented remains blocked |
| TAI-11 | 2 members injured, 3 survivors available | Policy-defined safe continuation/withdrawal; no whole-map defeat |
| TAI-12 | Returning member receives a new paid field task | Auto-resume does not steal Field, waits until available |
| TAI-13 | Forced STOP during cast/boss death | No duplicate credit, no disappearing accepted kill, safe withdrawal barrier |
| TAI-14 | Same state/seed elapsed: viewed/unviewed/offline/restart | Equal target choices/HP/RNG/kill IDs within identical legal world |
| TAI-15 | 1k–3k background roster; few live teams | No 0.25s all-actor replan, memory stable, targeted performance benchmark |
| TAI-16 | Character Studio rig missing or Map scene unloaded | No gameplay authority change, visible fallback only |
| TAI-17 | Multiple policy revisions/duplicate command taps | Idempotent team command, no double movement/loot/time |
| TAI-18 | Boss cooperation/injury/retreat threshold policies not authored | BLOCKED/UNKNOWN with reason, not unreviewed default boss rewards |

**Comparability note:** B2.4 sandbox tests cannot certify TAI-04/10/12/14 live production. Actual Godot tests are future CODE-phase deliverables, not completed by this document.

## 12. Proposed independent code packets — NOT AUTHORIZED

| Packet | Responsibilities / narrow outcome | Dependency / stop condition |
|---|---|---|
| **TAI-D0 (DONE: design)** | This AI behavior contract, source matrix, policy/open decisions, focused test packet. | Docs only; no Map/Studio/SA-LIB impact. |
| **TAI-C1 PURE PREFLIGHT** | Read-only snapshot-based eligibility of team/occupations/injury/zone, pure personal/team target selector (no mutations), seeded fixtures. | Once parent Persistent World state schema W1 approved; do not edit `WorkforceSystem.issue_command` without explicit integration owner. |
| **TAI-C2 TEAM DUTY FSM** | Serialize team policy/directives, WAIT/PREPARE/TRAVEL/PATROL/WITHDRAW/RECOVER/AUTO_RESUME transitions, idempotent command IDs. | W1 WorldState, W2 continuous Combat kernel and W5 clock contract at least specified; one writer for save/workforce. |
| **TAI-C3 WORLD INTENT HOOK** | Attach actor intent/soft target selection to CombatV2WorldStep without changing skill formula; multi-team same HP, no target clones. | Combat parity fixture, source-specific targets and kill ledger W3. |
| **TAI-C4 RETREAT / HEAL / RESUME** | Canonical Injury 0/1/120, real supplies, job-constrained auto-resume, proper world withdrawal. | W3 receipts + Save integration and GP-02C1 regressions; requires one owner for shared files. |
| **TAI-C5 PERFORMANCE + UI PROJECTION** | Event-driven scheduling/spatial query, read-only Map/Studio status bridge after owner handoffs. | Benchmark one-world 5-team and Android UI, no simultaneous active Map/Studio file edits. |

**No automatic implementation authorization.** All shared SaveService/SectState/DiscipleState/Workforce/Combat/Map scene changes need one explicit integration writer, audited HEAD and allowed paths, legacy version compatibility, official focused QA, no auto merge.

## 13. Owner decisions still open — recommended choices, NOT locked

1. **Team autonomy:** recommend continuous hunt by default, choose cautious/balanced/aggressive risk + optional Boss permission (no guaranteed Boss loot). Player direct STOP/RETURN/override remains possible; survival guard always precedes loot urgency.
2. **When 1–2 members down:** recommend policy selectable `WAIT_ALL` vs `CONTINUE_SAFE_SUBSET`, default conservative until tested; do not force 5-person minimum because team max is 6 and solo is allowed.
3. **Preferred range movement:** recommend simple approach/hold-range, optional minor ranged backstep only after combat-parity test; no MOBA kiting.
4. **Aggro/leash:** attention/target references, not a new Threat stat. Need explicit spawn-home leash and HP-reset policy to avoid exploit.
5. **Boss targeting:** allow only when source+policy+safety valid, no auto-suicide; cooperative personal credit requires separate signed design.
6. **Retreat threshold:** combine real `retreat_hp_ratio()` and team posture sensibly; exact percentages OPEN, no hardcoded example defaults.
7. **Auto-resume after recovery:** recommend enabled for continuous-duty when fully eligible; if reassigned during healing do not overwrite new job.
8. **Source content scale:** no limit of three pilot zones/five recipes as architecture; author region/zone difficulty later with safe source contracts.
9. **Supply costs:** never require arbitrary hunt entry fee; medicine/travel/recovery real consumers.
10. **Scheduling:** event-driven team decisions and cached actor intentions to fit mobile/8GB development PC; numerical reconsider intervals to benchmark.

**Acceptance boundary:** The *player-facing principles* above derive from locked owner direction; none of the precise scheduler callbacks, thresholds, aggro/leash rules, Boss sharing/reward splits or AUTO_RESUME defaults are newly locked by merely committing this file.

## 14. Sources

- `docs/design/B3_V2_PERSISTENT_PVE_WORLD_RUNTIME_CONTRACT_2026-10-22.md` — primary persistent world/time/reward contract.
- `docs/design/B3_V2_LIVING_SECT_CONTINUOUS_HUNT_ARCHITECTURE_2026-10-22.md` — B3 umbrella design.
- `docs/GAME_SYSTEM_ARCHITECTURE.md`; `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`; `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`; `docs/COMBAT_STATS_V2_SPEC.md`; `docs/COMBAT_SKILLS_V2_SPEC.md`.
- `godot/src/simulation/ai/decision_system.gd`, `goal_system.gd`; `godot/src/simulation/organization/organization_system.gd`; `godot/src/simulation/workforce/workforce_system.gd`; `godot/src/simulation/combat/map_battle_v2.gd`, `hunting_pve_run_v2.gd`, `map_battle_snapshot_v2.gd`; `godot/src/simulation/core/simulation_scheduler.gd`.
- `docs/handoffs/2026-10-21/TMB_FOUR_ZIP_REVIEW_AND_NEXT_CODEX_2026-10-21.md` — B2.4 sandbox distinction and parallel-source handoff.

**Proof:** doc read/source reasoning ONLY. No runtime testing, Godot QA, production AI agent, gameplay patch, merge, Map/Studio/Source A task or cross-worker intervention occurred.
