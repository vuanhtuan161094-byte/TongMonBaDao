# TÔNG MÔN BÁ ĐẠO — RTS HUNT MAP V3: 30 ĐỆ TỬ / 120–200+ QUÁI / HỆ PHÁI CHUYÊN-HỖN TU
## Deep design review, before any SK-A/B Codex packet

**Ngày:** 2026-10-24 | **STATUS: RESEARCH / DESIGN PROPOSAL ONLY** | NO CODE, NO SK-A/B IMPLEMENTATION PACKET, NO PR29/UI/SOURCE A EDITS, NO MERGE.
**Newest direct owner corrections:** This is a large, persistent **RTS-style hunting map**. Player controls assignments with mouse like Age of Empires, disciple arrives and auto-farms. **30 deployed disciples / one wide map; minimum desired ~120 monsters, target ~200 currently present, potentially more; 10–20 monsters in a chosen disciple's farming patch/camp over the life of the patch; minimap mandatory in design.** Explore path specialization, chosen build, dual/mixed paths before any implementation package. Do not overfocus on 30v40 sealed encounter.
**Parent review:** `docs/design/TMB_COMBAT_V3_MULTI_DISCIPLE_JX_SKILL_ENGINE_ARCHITECTURE_2026-10-24.md` on `docs/combat-v3-multi-disciple-jx-mechanics-engine-design-20261024` remains a prior DESIGN proposal; its 30v40 is an implementation cap of ONE local `MapBattleV2`, **not owner-approved cap on overall hunting world**.
**Source baseline:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`; PR #29 S1 at `9522812e91b7ca5bc0cc108eb92e000e930fe850`, OPEN/DRAFT official focused QA pending when checked. Current `AGENTS.md` authority order respected; actual sources reviewed `docs/GAME_SYSTEM_ARCHITECTURE.md`, `docs/CULTIVATION_PATH_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `godot/src/simulation/combat/map_battle_v2.gd`, `hunting_map_v2.gd`, `hunting_pve_run_v2.gd`, `godot/src/presentation/p3/map_battle_world_layer_v2.gd`, `sect_map_camera.gd`, `labs/env02a/scripts/env02_world.gd`, `godot/src/simulation/cultivation/cultivation_path_system.gd`.

## 1. Which map is this? Different map concepts CANNOT be interchanged

| Existing artifact | What code REALLY does | Does not yet prove |
|---|---|---|
| `HuntingMapV2.LEVELS` | Generates groups of 3/4/5/6/7 per five region difficulty grades; occasional Elite/Boss | 120–200 monsters or physically persistent hunt camps |
| `MapBattleV2` | Fixed local arena Rect(0,0,36,20), at most 30 disciple and 40 monster records; each party <=6; step=0.25 sec; nearest target, moving/attacking and S1 effects; maintains separate durable HP0 kill journal for continuous mode | entire 200-monster map, seamless 30 independent area assignments, RTS commands or pathfinding with terrain |
| `MapBattleWorldLayerV2` | Presentation adapter maps 36×20 logical to stage rectangle, draws dots/HP/boss markers, actor pick | source-quality final world, minimap, drag select / attack-move |
| `SectMapCamera` | zoom/pan/coordinate transform for a 1280×720 view | battlefield click-to-command, minimap |
| `labs/env02a` | 192×192 **sect environment preview** with chunk16, initial48×48, buildings+camera/touch pan, NOT persistent hunting actors | settled hunting world 192×192, monsters, RTS orders |
| `CultivationPathSystem` | P2 generic path XP and UI labels based on historical XP shares (65% primary, 25% secondary); static path stat effects | canonical V2 progression/three generations; P2 share thresholds are NOT the new V2 class formula |
| `CULTIVATION_PATH_V2_SPEC` | ONE soft active Chủ Đạo and ONE active branch; retains multiple path histories, switching outside combat; no generic ClassLevel | full path/branch loadout and hybrid combat implemented |

**Key correction:** The current 30v40 limit comes from local `MapBattleV2` and must NOT be carried into the design as "only 40 monsters in the full wilderness map." Do NOT simply set MAX_MONSTERS=200: it ignores world map/actors, orders, respawn zones, target generation, 30 active controls, navigation/visibility and backpressure.

## 2. Population arithmetic and different definitions of 10–20 monsters per disciple

**Owner-confirmed direction:** minimum about 120 monsters, target about 200 monsters on one open hunting map, 30 disciples active, individual camps/farming patches with 10–20 monster opportunities.

**If 30 distinct NON-overlapping camps each have 10–20 living monsters simultaneously**, map requires **300–600 concurrently living monsters** (30 × 10..20), not 120–200. These statements should not be silently reconciled by reducing the owner's desire.

### Design alternatives for clarification (not owner locked)
- **M1 recommended as first benchmark**: **200 alive simultaneously**, **~30 authored/assignable farm patches** with per-patch **10–20 slot registry/capacity over respawn cycle**, but only ~4–8 alive in some patches at once. Camps refill as monsters die; a disciple farms its patch continuously without running out. Distinguish **live_count** vs **spawn_slot_count**, and make camps truthful in UI (e.g., “Sơn Lang — đang có 6/15 con, tổng 15 vị trí sinh quái”). This accommodates 120–200 active map-wide while preserving 10–20 target opportunities **over time**, not at one instant.
- **M2 dense authored camps**: 10–20 monsters currently alive PER 30 personal patches = **300–600 simultaneous monsters**, considered a higher benchmark tier. A hard request for every disciple's distinct patch to have 10–20 simultaneously requires M2, not M1. A max200 world cap would be wrong here.
- **M3 shared camps**: 10–15 larger camps with ~12–20 live monsters each = 120–300 alive; assign 2–3 disciples per camp, area-owner/jobs separate per disciple. Supports shared tank/heal combos, less distinct location for all 30.
- **Mixed natural world**: authored clusters + roaming enemies + elite/boss regions, 120–200+ live actors; camps are **logical farming regions**, not artificial tiled fenced arena boxes. A disciple may cross boundaries via explicit player order/leash pursuit; monsters aren't teleported to private arena.

**Definition proposal:** `WorldLiveMonsterCount` = actually spawned, alive, with canonical ID/HP/position; `CampSpawnCapacity` = registered slots; `CampReadyNow` = alive in that camp; `CampRepopulation` = future scheduled unique slot generations; `CampEncounterPressure` = concurrently aggro'd monsters vs one disciple (danger). These four numbers must NOT be conflated. Spawn capacity and alive count are not the same, and `respawn_rate` must be authored/benchmark-tested rather than silently fixed in this review.

### Example M1 workload (PROPOSED, not final content)
30 deployed disciples, 30 addressable farming areas, 200 live monsters across map plus bounded respawn, plus world producer budgets. All 30 areas may advertise 10–20 **total registered/replenishing slots**, while individual ready-live number fluctuates. Every monster belongs to exactly ONE world instance/spawn slot/generation at a time; it can walk across camp boundaries. Elite/Boss optional and not allowed to spawn copies for each team. Do not invent 30 independent loot worlds.
**Example M3 alternative:** 12 camps ×15 currently alive ≈180 live. 30 disciples distribute 2–3 per camp, with some camps for solo exploration. This may feel less personally independent than the owner's per-disciple idea.

## 3. Direct player RTS command design (desktop and Android)

### 3.1 Desktop interaction — map is continuous
- Left-click disciple or portrait → selects ONE, shows name/HP/Path/skill readiness/assigned camp. Shift+click adds/removes from group. Left-drag over ground → drag-box selects multiple visible disciples; click on monster without selected units shows its info. Keyboard groups (Ctrl+1..9) optional, not necessary for minimum.
- **Right-click terrain** with selection → MOVE order or ATTACK-MOVE order based on selected command mode. **Right-click enemy** → attack that monster if legal and path exists. Right-click a camp marker → ASSIGN_AUTO_FARM(area_id) if available and licensed by One Active Job / HP / Injury gates; show visible confirmation path/flags and minimap assigned territory.
- **Separate these**: `MOVE` = go to destination and HOLD/IDLE; `ATTACK_MOVE` = travel toward destination and engage nearby enemies; `FARM_AREA` = roam, kill eligible spawn slots, return to anchor, respawn/reengage, rest/retreat at policy threshold; `FOCUS_TARGET` = hunt single valid monster/Boss; `RETREAT` = leave fight/go to safe node; `HOLD_POSITION` = hold within tether and shoot if in range. No ambiguous “move always attacks along route” unless command type specifies.
- **Right-button conflict current ENV02A**: demo uses right-drag camera pan. To make right-click an actionable RTS order, migrate pan to **middle-drag / space+left-drag / screen-edge pan / minimap drag**, or distinctly separate right-click from drag based on drag threshold, with tested click-vs-drag. This is a UI proposal, NOT permission to edit source now.
- Camera stays free and does not lock to a selected disciple. Follow only when explicit camera-follow toggle. Wheel zoom, minimap click-to-pan. Hold/disable auto orders should never override owner-issued manual orders.

### 3.2 Android landscape 1280×720 — no assumed right mouse
- Single tap disciple/portrait selects; tap ground with selection triggers current order mode; tap camp icon opens “Di chuyển / Săn tại đây / Giữ vị trí”, long-press optional radial menu. Touch box selection via explicit multi-select button to avoid stealing camera drag.
- One-finger drag PANS if not in selection box mode; pinch zoom. Minimap tap moves camera, longer press + tap command order with explicit selected state; no overlapping tap target or moving disciples accidentally while panning. Accessible hit areas and overlay priority.
- Hero focus and loot alerts should remain unobtrusive on small display; mini-map zoom frame, colored ally/monster/Elite/Boss indicators and clicked point can be toggled.

### 3.3 Truthful command pipeline
`selection (UI-only) → immutable order{request_id, actor_ids, world_id, kind, destination/area_id, policy_version} → canonical validator (actor alive, no Injury, One Active Job, reserved job/encounter, reachable/visible/known target policy) → acceptance/refusal reason → world movement and farm FSM → local Combat V2 interactions → status/reward/source journaling → save snapshot → UI feedback`.
One order for 6/30 actors is **one user request** but each actor has own effective job/arrival/target; no unconditional teleport/same position. Idle/manual retreat/OFF remains authoritative. Repeated request_id idempotent. Switching FARM_AREA A→B cancels/returns per defined state and must not duplicate kill or lose pending projectile.

## 4. World architecture — which option is safe for 30+200 and perhaps 600?

### Candidate W1: one gigantic MapBattleV2 with MAX_MONSTERS=200 or600
**Rejected as an unreviewed shortcut.** Current `_nearest_enemy` scans sorted actors for each actor on every .25s step, `_actor_casting` scans all pending casts; large actor counts and multi projectile/proc multiply work, and 36×20 coordinate assumptions, fixed world bounds, kill queues, 90s finite battle, role priorities and snapshot actor cap all need redesign. Raising one constant would not meet RTS UX or actual world ownership.

### Candidate W2: independent sealed MapBattle mini-arenas for every disciple/patch
**Risky for seamless open map**: a disciple can walk between zones; monster moves through boundary; a boss is attacked by two teams from adjacent cells; one old projectile lands after a transfer. Independent HP/target/kill ledgers create ghost kills, duplicate Boss pools and fake teleports if no cross-zone ownership.

### Candidate W3: ONE authoritative wilderness world with spatial partitions and one Combat V2 resolver — RECOMMENDED DESIGN TO VALIDATE
- World actor registry owns stable `world_id, entity_id, spawn_slot+generation, pos, HP, current job/order/AI intent, status/cooldowns`; same map spans all farm camps and positions.
- Partition world into **spatial cells/chunks for indexing and scheduling**, not private fight dimensions. Each entity exists in exactly one **actor-owner** record and one deterministic current bucket; path/missile/AoE can cross bucket boundaries via authoritative queries. Actor transferring buckets does not recreate identity/HP/status, doesn't reset cast/CD.
- Combat V2 hit/crit/resist/DoT remains the single math and kill resolver. Existing `MapBattleV2` can serve **as a reference implementation/local encounter kernel**, but a true `WorldCombatDomain` or adapter must be designed if per-encounter actor ownership cannot support seamless cross-sector interactions. **Decision is not locked to copying 30v40 encounters**; choose code integration only after profiling and owner acceptance.
- **One global wilderness Boss actor per world spawn** (one HP and generation); multiple teams attacking it settle through same ordered action queue; no duplicated local encounter "boss copy." If desired a special Boss engagement zone may temporarily coordinate parties, but must not fork authority.
- One world simulation clock and deterministic queue: movement intents, spawn, status due ticks, cooldown releases, casts, hit packets, HP0 and Warehouse/CARE receipts. Stable tie order (time/actor_id/cast_id/hit_index) with RNG state; no camera input.
- A **map chunk is a scheduling/query index**, not a fake zone with separate loot/XP timers. No gameplay downgrade just because region is off-camera.
- Current canonical `MapBattleV2.MAX_MONSTERS=40` remains **CURRENT CODE CAP**; W3 is a **future NEW authorization** requiring explicit refactor/gates, not already implemented.

### 4.1 Pathfinding and aggro
- World grid/waypoints with walkable terrain and constraints; path requested on new MOVE/FARM command or significant obstruction, **not every rendered frame**; request path cost budget and per-actor cached waypoint route. Potential map nav separate from combat arena.
- Local steering/collision avoidance to avoid 30 disciples stacking on exact cell; deterministic separation tie break; don't introduce arbitrary invulnerable collision pushing or teleport to clear congestion. Test bridge, corner, narrow pass and crowded spawn area.
- Aggro radius, target-claim policy and tether/leash belong to **camp/monster definitions**, with player farm area policy; nearest monster alone must not force disciple to run from one assigned camp to entire map. Distinguish `camp anchor radius` from `attack range`, `chase leash`, `retreat/safe node` and `boss warning`.
- Claiming spawn slots prevents all 30 disciples chasing one cheap wolf when distinct camps exist; but **not exclusive ownership of world monsters** if two disciples legitimately hit same target. Loot belongs to canonical Sect rules, not camp-exclusive private loot.
- Monster respawn at authenticated slot/generation, next_spawn_tick only after death and valid timer; never spawn a new monster into same slot while predecessor identity is still alive. Spawn pressure per region stops infinite escalation; rare Elite/Boss uses authored regional events independent of camera.
- Persistent passive crowd effects require per-actor/per-area caps, one Boss CC immunity policy, collision/area query cap; AoE geometry doesn't automatically damage 200 mobs with one click.
- New terrain collision/LOS is a separate explicit gameplay rule. Fancy navigation not required on first benchmark if open grass map; do not fake LOS while obstacles visibly block.

## 5. Real combat order loop per disciple (not a human manually casting JX)
`AT_SECT → ASSIGN_ORDER → TRAVEL_TO_AREA → SEEK_MONSTER → APPROACH → CAST/BASIC/FIGHT → CONFIRM_KILL → SEEK_NEXT → RESTOCK/RETREAT/RECOVER → RETURN_TO_CAMP`. The actor has **One Active Job**; if no enemy within camp but respawn pending, wait/patrol bounded; don't escape to another map automatically unless owner set such a policy.

**Auto skill decision** (canonical V2): 1 Basic+4 Active+6 reactive passives when unlocked, ordered active priority1→4 with hard gates; heal genuine missing HP, guard when threat, finisher only if authored Burn/mark on target, AoE when legally useful, dash for actual gap; no giant per-frame utility tree. All projectiles/child actions capped by hit policy and stable cast IDs. Same simulation whether on camera or off, Source A only draws visible cast/projectile/hit cues.

**Safety:** If HP falls below owner-configured retreat threshold, no medicine, too many enemies or Injury occurs, stop hunt, withdraw legally, use real supplies/cost, recover for 120 injury ticks if Injury=1, return only when ready and auto enabled. Do not invent free kill EXP or fake intermediate loot. If a healer is in a separate camp, cannot heal across world unless their skill actually has appropriate range/target query.

## 6. Minimap is a required gameplay navigation instrument, not decoration

**Required design behaviors (NOT YET IMPLEMENTED):**
- Accurate whole-hunt-map coordinate projection of all relevant world actors and terrain/camp markers; minimap maps from world positions, not from the 36×20 legacy arena renderer.
- Distinguish 30 allied disciples/parties, normal monster *clusters* (don't spam 200 overlapping icons), Elite, Boss, camp anchors, selected units, command targets, currently viewed camera rectangle and warning/loot events.
- Click/tap minimap to move the CAMERA; with explicit command mode, tap a camp marker to assign selected units; in default mode a minimap click **must not silently reassign the job**. Shift/zoom behaviors separate.
- Selected one disciple: strong highlight of its assigned camp, path arrow, HP and hunt state. Selected multi: group markers / average HP / danger, and optionally drag a control group from minimap.
- Colorblind-readable symbol/shape hierarchy; large touch targets, minimap never covers a high-priority HP/retreat button. Panning updates only camera, not world simulation.
- Performance: maintain cached terrain raster and update actor dots at a bounded presentation refresh; moving 200 mobs shouldn't redraw entire detailed map per frame. UI reads snapshots, no sprite/physics owner.
- [OPEN] UI size/position, fog-of-war, monster visibility before exploration, off-camera marker reveal conditions, layer controls, camp/filter legend, Android tap mapping. No "whole map reveal" assumption without owner decision.

## 7. Disciple specialization, branching and MIXED cultivation

### 7.1 Canonical source facts
- `CULTIVATION_PATH_V2_SPEC` [LOCKED] one **soft active Chủ Đạo**: Chưa Định Đạo → Kiếm / Thể / Pháp; one active branch at a time; learned techniques/skills/mastery and **all prior path histories** retained. Switching explicitly in Sect/with real requirements, **never mid-battle**.
- Nine branch names [LOCKED]: Kiếm Ngự/Sát/Hộ; Thể Bá/Kim Cương/Huyết; Pháp Ngũ Hành/Y Đạo/Huyền Pháp. Branch chooses compatibility/eligible skill families and AI tendency, not a generic +ATK/DEF per class level.
- Techniques [LOCKED] can have 1 Main +2 Support; skills at maturity 1 Basic+4 Active+6 combat passive, learned library can be larger. A requirement tagged `path, branch, technique, realm, body` gates content **where authored**, not universal all-mismatch ban.
- Ngũ hành root and learned Path independent. Fire roots do NOT mean assigned Pháp path; Sword can author a Fire skill if eligible, Body can author water guard etc.
- `CultivationPathSystem.gd` P2 path-history percentages 65% primary /25% secondary and P2 path XP stat multipliers are **LEGACY SOURCE CODE**, not V2 lock; V2 expressly replaces generic path XP power multipliers with Đạo Lịch. Do NOT revive P2 thresholds to define canonical new hybrid.
- V2 requires actual `Diễn Đạo` conditions for active branch: main compatible technique, skill family mastery, realm/body gates, Đạo Lịch, Sect time/resource. Player can deliberately switch, retaining old mastery. No automatic class lottery.

### 7.2 Four attractive build archetypes, all proposed content styles (NOT extra permanent class types)
| Build archetype | Active Chủ Đạo | Learned history/techniques | Equippable combo examples | Tradeoff without hidden nerf |
|---|---|---|---|---|
| **Chuyên Kiếm/Sát Kiếm** | Kiếm/Sát | main Sword + support Sword/Fire (if legal), high sword-family mastery | Truy Phong Bộ gap-close → Thanh Phong Trảm / Ngự Kiếm; counter passive | Very strong chosen family synergy, fewer known heal/guard utilities |
| **Chuyên Pháp/Ngũ Hành** | Pháp/Ngũ Hành | Fire78/Water46/Wood34, main Fire, legal Water support | Hỏa Cầu Burn → Liệt Diễm payoff, Hàn Sương Ấn weaken, healing if learned | Ranged setup+element coverage, weaker close tanking |
| **Song tu Kiếm–Pháp** | **ONE active Kiếm OR Pháp**; other is retained history, not a second active class | main Sword or Spell, 1–2 support from other source if authored | ranged opener/mark + Sword close finisher, optional Water escape | 4 active slots must be shared across both; out-of-branch bonuses/gates may be unavailable; not an arbitrary global -20% “hybrid penalty” |
| **Thể–Pháp hỗn tu** | **ONE active Thể OR Pháp** | good Body+TuVi, Earth guard, healing/Y medicine history | Guard/taunt to protect allies, effective Heal and controlled AoE | Strong utility, slower solo burst due to actual chosen slots/skills, not a mandatory attribute penalty |

Three-history `Kiếm–Thể–Pháp` long-term hero is not forbidden in learning/history, but only one active identity/branch and one 1+4+6 loadout. Mixed builds remain choices, not optimal forever by default. A skill with progression basis `HYBRID` may explicitly read both TuVi and Luyện Thể, and conditions must specify ratios and mechanics; no default 50/50 rule. Avoid adding a second universal “Kiếm Ý/Mana/Thể Lực” resource in response to hybrid design.

### 7.3 Distinguish combat role, Path and camp policy
- **Path/branch** = current cultivation identity, recorded.
- **Fight role** = loadout and target/heal/guard behavior **per encounter**, e.g. frontline, ranged, healer, control. Role can change when equips change even if active Path does not.
- **Camp assignment** = location and farming policy, not changing Path. Two Sword disciples may farm separately; same disciple may become healer-support in another team only if its actually learned skills allow.
- **Root elements** = real per-element purity/passive/matching bonuses and counters, not free extra class. Character with Fire78/Water46/Wood34 may main Sword or Spell.

### 7.4 Hybrid learning and tradeoff questions for owner to resolve
**H1 strict authored prerequisites:** some rare branch-specific Trấn Phái move requires active matching branch; lower/common cross-path moves may be learned/trained freely when manual/TuVi/Body requirements met. **Recommended** preserves distinctive specialist styles while enabling varied builds.
**H2 equip authorization:** rare off-path skills can remain *learned* but are unequippable if their definition requires active branch; others legal and potentially less well supported by current main technique. Switching path outside battle re-evaluates 4 active+6 passive and not auto-erases mastery.
**H3 mixed “combination skills”**: explicit one authored HYBRID skill may be created for Kiếm–Pháp or Thể–Pháp with dual basis and prerequisites; not automatically obtained by possessing two histories. Optional future unlock, not required to enjoy mixed loadouts.
**H4 UI presentation:** show “Chủ Đạo hiện tại: Kiếm Tu / Nhánh Sát Kiếm” plus “Đạo Lịch: Pháp Tu đã từng tu luyện, 3 bí tịch, 2 kỹ năng thông thạo” and one distinct combat role “Sát thương/Khống chế” — never mislabel “2 active classes.” Skill filter by eligible/current path/learned/root/role.

## 8. Stepwise investigation gates — NOT CODE packets
Before writing an SK-A/B packet:
1. **World sizing decision:** clarify whether 10–20 *simultaneously alive* at each of 30 independent camps (300–600 map total), or a replenishing camp registry with 120–200 live world-wide. Show an actual representative map layout with monster counts.
2. **World architecture choice:** design ownership for one open world actor registry, camp spawn IDs, 30 move paths, 200 monsters, cross-zone travel and Boss single HP. Prove conceptual mapping to existing MapBattleV2 math and CARE; no fake private arenas. Need explicit compatibility plan and profiling test.
3. **RTS input/mini map UX decision:** decide desktop left-select/right-order vs current right-drag pan, Android gestures and minimap default click behavior; establish command types and real feedback. UI owner pending.
4. **Cultivation flexibility decision:** owner choose whether H1 strict branch-only Trấn Phái with cross-path common skills, whether multiple active path identity is forbidden (currently locked to one), and when cross-path support techniques are valid; do NOT override locked soft active rule without approval.
5. **Stat/balance modeling:** solo1 vs camp10–20 aggro limits, respawn cycle, early/late danger, 30m vs200m performance, number of AoE target hits; inspect actual drop/EXP economy separately, no invented per-kill XP.
6. **First non-code playable storyboard:** assign 3 separate disciples to camps with right-click while 2 other squads fight Elite/Boss; pan to minimap; switch hero; select all; SAVE midcast, boss kill exactly once, no action from UI-only camera.
7. Only AFTER owner approves the design and S1 focused gate verified should anyone prepare actionable SK-A/B/W3 CODE packets; this review is intentionally **not** such a packet.

## 9. Explicit status and safety
- No current code supports 120–200 monsters in one seamless RTS map, minimap, attack-move/patrol/farm order controls or multi-path V2 runtime in full. This document is NOT an implementation claim.
- No new world hardcap 200; owner called 120–200 **desired minimum/target**, higher density remains a viable option.
- Don't change/save/merge to PR29, Source A renderer, or TMB UI; no source migration from old DEV save. Within one build save/load and receipt accuracy remains canonical.
- **Recommendation for deep review:** choose W3 world authority and M1 200-live respawning camps as a FIRST performance benchmark, explicitly mark M2 300–600 concurrent if “10–20 alive per disciple” is the intention. Support one active soft Path plus genuine hybrid learned combinations. Avoid issuing a Codex code packet prematurely.
