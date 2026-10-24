# TÔNG MÔN BÁ ĐẠO — THANH TRÚC LÂM: 1 BẢN ĐỒ, 20 BÃI QUÁI, 200–400 QUÁI
## RTS world-hunting architecture, density, spawn, autonomous farming, minimap and Combat V2 compatibility — DEEP REVIEW

**Ngày:** 2026-10-24. **Trạng thái:** DESIGN REVIEW ONLY / docs-only, no Codex SK-A/B packet, no code, no PR29/UI/Source A edit, no merge.
**Latest owner clarification:** “ví dụ thanh trúc lâm có 20 bãi quái chẳng hạn.” This supersedes the prior author's mistaken picture of **~12 named maps each containing 15 monsters** or 30 personal camps by default. It is **one named hunting map with many independently assignable spawn camps**.
**Owner request context:** 30 disciples deployed on a wide map; player uses RTS-like mouse/touch commands and minimap; arriving disciples auto-farm; camp may have ~10–20 mobs; skill engine inspired by JX mechanics, but many independent disciples all over map. No further original JX source extraction required.
**Count status:** “20 bãi tại Thanh Trúc Lâm” is an **example** from owner, not a global lock that all regions have exactly 20; “10–20 quái/bãi” is an expressed design desire. **200–400 live in Thanh Trúc Lâm** follows only if 20 camps each maintain 10–20 alive *at once*. 600 is a **stress extension** and not a newly locked cap.
**Source baseline:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`; PR29 S1 `9522812e91b7ca5bc0cc108eb92e000e930fe850` OPEN/DRAFT, official focused QA PENDING at last read. AGENTS/GAME_SYSTEM_ARCHITECTURE/CURRENT_CHECKPOINT/NEXT_CHAT_HANDOFF, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/CULTIVATION_PATH_V2_SPEC.md` read. Current code examined: `godot/src/simulation/combat/{map_battle_v2,hunting_map_v2,hunting_pve_run_v2}.gd`, `godot/src/presentation/p3/{map_battle_world_layer_v2,sect_map_camera}.gd` and `labs/env02a/scripts/env02_world.gd`.
**Owner DEV-save policy:** gameplay revision -> fresh dev world/roster; no P2 dev-save migration. Preserve SAVE/Load, Injury 0/1/120, One Active Job and exactly-once loot in a **single build**. No destructive actions executed.

## 1. Three levels of geography — do not conflate with a combat arena

\`\`\`txt
TÔNG MÔN / THẾ GIỚI
  ├─ Bản đồ săn #1: THANH TRÚC LÂM  [one continuous large world]
  │    ├─ Bãi #01 ... Bãi #05
  │    ├─ Bãi #06 ... Bãi #10
  │    ├─ Bãi #11 ... Bãi #15
  │    ├─ Bãi #16 ... Bãi #20
  │    ├─ Đường đi, khe suối, chướng ngại, hành lang liên kết, quái tuần tra
  │    └─ Vị trí Boss/Tinh Anh theo sự kiện và quy tắc riêng
  ├─ Bản đồ săn #2: BẠCH THẠCH KHÊ [current region ID, camp count not specified]
  └─ Bản đồ săn #3: HẮC PHONG CỐC [current region ID, camp count not specified]

Một bãi: SpawnCamp(camp_id + footprint + registry slots)
  ├─ SpawnSlot #1 ... SpawnSlot #10–20 [when owner chooses this density]
  ├─ Monster actor (id, HP, position, generation) for currently living slots
  ├─ kill → respawn schedule for that slot (not a new battle instance)
  └─ assigned disciple(s), player policy, leash zone, safe route
\`\`\`

**Important:** One farm camp is a logical region/anchor and population budget, **NOT an isolated CombatV2 arena, private loot instance, or 1:1 permanent ownership by one disciple**. Creatures and disciples move between nearby chunks; leaving the screen doesn't reset the fight. One monster globally has one stable identity and one authoritative HP. A map may later have a much different camp count, monster grade or capacity.

### Current implementation facts and gaps
| Current source | Verified facts | Architectural mismatch |
|---|---|---|
| `HuntingMapV2.REGION_CONTENT` | region IDs `thanh_truc_lam`, `bach_thach_khe`, `hac_phong_coc`; Thanh Trúc Lâm base realm1/floor1, normal weights Trúc Thử0.65/Thanh Lang0.30/Hắc Lang0.05, elite Nham Giáp Thú, boss Hắc Lang Vương; five selectable encounter difficulties | Has **no CampId, world footprints, respawn per slot**; `LEVELS.count` = 3–7 monster per selected **encounter**, not 200–400 monsters per map |
| `MapBattleV2` | Arena (0,0)-(36,20), MAX_DISCIPLES30, MAX_MONSTERS40, 6 per party; STEP_SECONDS0.25, MAX_SECONDS90 finite fight; offscreen flag does not control sim; simple nearest target scan and skill events | Not a continuous wide-world with 20 camps, persistent respawn, 200–400 monster actors, world click orders, terrain navigation |
| `HuntingPveRunV2` | begin one spawned encounter, advance/finish terminal, settle on a finished win; checks One Active Job/Injury and receipts | Continuous hunting needs **kill-per-monster receipts** over hours; cannot require “all 300 mobs dead” or terminal 90s to pay loot |
| `MapBattleWorldLayerV2` | 36×20 arena renderer, actor dots and boss cues, pick actor by map point | Not a large-world minimap or camp assignment UI |
| `SectMapCamera` and `labs/env02a` | Camera pan/zoom prototypes; ENV02A **192×192 is SECT map environment preview** with chunk16 and initial48×48 | Their map/world tile scale NOT automatically the hunting map dimensions, no actual camp/monster navigation/actor state |
| `CULTIVATION_PATH_V2_SPEC` | soft one active Chủ Đạo/branch, histories for Kiếm/Thể/Pháp; multiple learned techniques/skills possible | No need to invent fixed MMORPG classes to assign farms |

**Revised status:** 20 camp map and 200–400 monsters is **DESIGN TARGET**, absolutely **NOT code implemented**. Avoid “just change MAX_MONSTERS40 to400,” “split 20 sealed battles and duplicate Boss,” or “fake one farm reward per X minutes.”

## 2. Capacity arithmetic and a 20-camp exemplar

| Live mobs per camp | Camps | Living normal/elite slots across Thanh Trúc Lâm | Relation to owner example |
|---|---:|---:|---|
| 10 | 20 | **200** | low-density first correct map target |
| 15 | 20 | **300** | balanced design example, no final tuning |
| 20 | 20 | **400** | dense intended map |
| 30 | 20 | **600** | STRESS EXTENSION only; violates earlier 10–20/camp example unless camps increased or density is explicitly overridden |

**Alive counts vs slots:** Registered 15 slots per camp is NOT necessarily 15 alive every frame while mobs are killed awaiting respawn. For a design promising “~15 con sống tại bãi”, camp refill policy needs a target live pressure and visibly truthful current count. Under active farming, a transient 13/15 is legitimate; never claim fixed 300 living all the time if regen delay is significant.
**Boss/Tinh Anh inclusion policy is OPEN:** high-tier creatures may REPLACE some normal spawn slots to preserve camp cap, or occur as additional bounded world events with honest over-cap counts. Do not silently append a Boss per disciple or 20 independent Boss clones. World raid Boss instance id must be unique.

### 2.1 Example schematic: 5 columns ×4 rows, 20 camps (not actual tile map)
\`\`\`txt
          Western slope   Bamboo core       Creek        Wolf path      Eastern ridge
   North     C01             C02             C03            C04             C05
   Upper     C06             C07             C08            C09             C10
   Lower     C11             C12             C13            C14             C15
   South     C16             C17             C18            C19             C20

Main approach routes: from Sect gate(s) to north/west trail, branching into all camps.
Each Cxx = 10–20 monster spawn slots, with patrol geometry and a safe anchor.
A regional roaming Boss, if triggered, appears at an authored place/slot, NOT cloned for each camp.
\`\`\`
Actual area footprints should feel organic (bamboo thickets, hills, bridges, streams, little clearings), not 20 fenced boxes. Each camp has a unique center, footprint polygon/cells, nav connected route(s), aggro domain and patrol area. The 5×4 view is a topology/composition sketch, not a requirement that all camps are equal 5×4 square chunks.
Suggested monster mix starts from the canonical Thanh Trúc Lâm species weights; individual camp subtype variation, loot and elite placement require content review, not a free new enemy catalogue.

### 2.2 Assign exactly 30 disciples to 20 camps
A truthful simple distribution (PROPOSED):
- Camps C01–C10: **2 disciples each** = 20 disciples;
- Camps C11–C20: **1 disciple each** = 10 disciples;
- Total **30**, all can farm simultaneously, while camps vary in danger and distance.
**20 camps cannot give 30 disciples 30 distinct exclusive camps** simultaneously. If the owner later demands every one of 30 disciples occupies an EXCLUSIVE patch, change camp count to 30+ or allow separate map instances. Do not invent invisible 10 extra camps.
Alternative owner strategy: solo 15 camps, group remaining 15 disciples into 5 camps ×3; allow shift-click to command squads. Assignment is not welded forever: two workers can share one area or one can switch to another map on legal orders.

## 3. Camp entity, world actor and spawn model — proposed authoritative schema

### 3.1 Static CampDefinition
\`\`\`yaml
map_id: thanh_truc_lam
camp_id: ttl_c07
display_name: "Bờ Trúc Bắc"        # placeholder, not canon
shape_cells: []                   # reviewed polygon/nav cells, authored later
anchor_cell: [0,0]               # example placeholder, must fit actual map when drawn
max_live_mobs: 15                 # PROPOSED density example, NOT locked
spawn_slots: [slot_01, slot_02]  # illustrative partial list, 15 real slots later
monster_pool_ref: thanh_truc_lam_normal
elite_event_profile: optional   # no unapproved rates
boss_event_profile: none        # no per-camp boss by default
patrol_bounds: authored
aggro_profile_id: common_pack
leash_profile_id: woodland_leash
respawn_policy_id: camp_refill
safe_return_anchor: authored
navigation_connectivity: checked
difficulty_hint: normal          # *proposal*; existing five grade levels separate
\`\`\`
Each camp may contain 10–20 **actual** spawn slots. No hard-coded monster count of the current `HuntingMapV2.LEVELS` is inherited without a new approved encounter/world source.
### 3.2 MonsterEntity state
`{map_instance_id, monster_actor_id, camp_id/home_spawn_slot_id, spawn_generation, species_id, tier, current_hp, position, aggro_owner/target_id, ai_state, leash, status_effects, skill_cooldowns, spawned_at_tick, last_authority_tick}`.
- `monster_actor_id` is unique within authoritative map instance; `(map_instance_id,camp_id,spawn_slot_id,generation)` is a globally unique life/kill identity. Death generation G cannot be confused with respawn generation G+1. It may cross chunk boundary without creating a second actor.
- On death → durable HP0/kill journal → loot transaction credited once to Sect authority → slot enters `RESPAWN_PENDING` until legal next tick, then increments generation and spawns once. No fake loot during pending respawn.
- Running out of nearby valid targets → disciple waits/repositions/retreats per farm policy; camp replenishes honestly. Never teleport monsters under the player solely for AFK gain.
### 3.3 FarmAssignment state
`{actor_id, map_instance_id, camp_id, order_kind=FARM_AREA, order_request_id, authored_radius, policy_id, accepted_tick, state, path_id, target_id, explicit_owner_override}`. This is **one HUNT job + within-job suborders**, not a second ACTIVE JOB. A move command cancels/replaces existing farm suborder according to explicit owner policy; true interrupt/retreat gates respected. Assignment remains valid through camera move, save/load and an idle wait for respawn. A player may move one actor or group of actor IDs.

### 3.4 Authoritative farm FSM
`AT_SECT → DEPLOY_RESERVED → TRAVEL_TO_CAMP → SEEK_VALID_TARGET → APPROACH → AUTO_CAST_OR_BASIC → VERIFY_KILL → SEEK_NEXT`. If no monsters: `WAIT_FOR_RESPAWN` or bounded patrol; risk/low HP: `RETREAT_TO_SAFE_POINT → RETURN_SECT/RECOVER`; Injury1: recover120 canonical ticks, after that redeploy only if auto policy and job gating permit; Manual Hold/Auto OFF overrides. Don't secretly continue issuing damaging casts after a retreat that cancelled them, except authored already-released projectile semantics.
Distinguish **aggro pack count** (number that attack a single disciple) from **camp live 10–20**. Ten wolves in a camp need not all target one disciple at once. Initial aggro/leash/risk numbers are OPEN; enemy pack behavior is an actual gameplay challenge, not arbitrary safe mobs. Team fights should be possible and deliberate.

## 4. RTS commands and camera/minimap input truth

### 4.1 Commands, distinct not conflated
| Command | Player input candidate | Result |
|---|---|---|
| SELECT | left click / shift-click / drag box | selected actor IDs in UI, no job change |
| MOVE | right click terrain in move mode | travel point, then hold/idle; is not permanent hunting |
| ATTACK_MOVE | explicit command mode + right click destination | move to destination, engage eligible mobs en route, then follow finish policy |
| FOCUS_TARGET | right click monster with units selected | move to attack if legal, obey leash/safety; no permanent camp assignment unless chosen |
| FARM_AREA | selected actor(s) + right click camp icon or Farm action | accept camp assignment, travel, farm valid mobs, wait for respawn and repeat |
| HOLD_POSITION | toolbar command | keep location with declared attack radius; no map-wide chase |
| RETREAT | hotkey/context action | interrupt/withdraw, Injury/One Active Job and manual priority respected |
| FOLLOW_CAMERA | explicit focus toggle ONLY | camera follows selected actor; normal select leaves camera freely pannable |

Right-drag is already used for camera pan in ENV02A; **new proposed RTS controls must resolve drag-versus-click**: middle-drag, Space+left-drag, edge pan or pixel threshold, with Android tap/drag/pinch distinct. Touch defaults to tap select and explicit Farm button; do not interpret an ordinary single-finger camera drag as move orders.

Command pipeline: `UI selection → order{request_id, actor_ids, map_id, camp_id/point, command_type, issuer_tick} → validation OneActiveJob, Injury, HP, already assigned, reachable, spawn/actor reference → accepted/error reason → navigation path → skill AI → CombatV2 hit/status/HP → CARE/warehouse kill receipt → persisted world → UI notifications`. Repeated same request_id is idempotent; UI has no direct loot authority.

### 4.2 Minimap
Minimap must display the **entire Thanh Trúc Lâm** (not the 36×20 battle arena), camera rectangle, 20 camp centers, 30 disciple dots/party/group coloring, enemy clusters (aggregate 200–400 normal mobs, don't spam glyph overlap), Elite/Boss distinct markers, selected destination/arrows, dangerous areas. Default minimap click moves only CAMERA, not actor. Assign from minimap only in clearly engaged order mode. Refresh indicator data at bounded UI frequency, combat simulation independent. Android hit targets and overlays keep readable at landscape1280×720. Fog-of-war/exploration/visibility policy OPEN, no automatic perfect information assumption.

## 5. Authoritative world combat architecture — comparison of viable choices

| Architecture | Pros | Major fail mode | Review verdict |
|---|---|---|---|
| **A** — one existing `MapBattleV2` MAX_MONSTERS raised to400 | superficially few edits | arena36×20, 90s terminal, global nearest scans, no camps/path, no true continuous rewards | **REJECT as shortcut** |
| **B** — twenty independent combat arenas (one per camp) | can reuse actor-count limits, simple first test | actor crosses camp, projectile crossing boundary, healer from adjacent camp, one Boss attacked by >1 party => duplicated HP/loot or invisible barriers | **Avoid for promised seamless open-world behavior**, unless an explicit single-world authority arbitrates cross-boundary interactions |
| **C** — single **map-owned world actor registry** + spatial/chunk index + shared Combat V2 math/effect resolver | supports 20 camps, 30 actors walking among camps, 200–400 spawn actors, camera-independent, unique Boss | requires real new world clock/movement/navigation and integration, strong QA; not already implemented | **RECOMMENDED conceptual target**, subject to CODE owner decision after design/profiling |

**Note** option C is not permission to replace Combat V2 math with a second damage engine. Shared authoritative CombatStatsV2 hit/resistance/crit/lifesteal rules + MapBattleV2 legitimate skills/status should be extracted or reused **without duplicated HP/collision ownership**, while world handles actor positions, target queries, camps and spawn. If full world CombatV2 owner must evolve, architecture authority boundary review precedes code changes. Need a clear state transition from finite `HuntingPveRunV2` receipt-at-terminal to continuous per-kill receipt; no separate unofficial wallet/loot queue.

### 5.1 Logical spatial chunks versus gameplay boundaries
Three distinct grids: **map navigation cells** (walkable terrain), **spatial query buckets/chunks** (accelerated nearby actors) and **presentation chunks** (Source A ground/vegetation culling). Can share coordinate transform carefully, but are NOT the same authority.
- Monster/disciple can cross spatial bucket edge; entity state stays singular, no teleport or cooldown reset.
- Query aggro/target, heal/party, AoE hits only buckets intersecting real radius/shape; stable IDs and deterministic distance/ID tie-breaking.
- Skill missile can fly across buckets, ends at legal collision/event or lifespan, doesn't disappear merely because the camera is elsewhere.
- Boss unique actor in world with one HP bar/kill identity and no independent camp copies.
- If several hunting **maps/instances** run simultaneously, namespaces include `map_instance_id`; different worlds don't share one actor ID/mob slot/reward claim. Access gates/how many maps run concurrently is future policy.

## 6. Performance: 30 disciples + 200–400 mobs, 600 stretch

### 6.1 Why naive repeated whole-map scan can be expensive
Existing `MapBattleV2` calls nearest-enemy over all actors per living actor, sorts actors each 0.25s step, and scans casts. At **230 actors** (30+200) naïve all-pairs has about **52,900 candidate comparisons per step**; at **430 actors** (30+400) ≈**184,900 per step**, *before* collision, effects, path, status, animation and alloc overhead. This is illustration of upper bound N² scan, **not a measured number of actual source loop iterations**. No blanket assumption that 200–400 can be processed under frame budget on Android.
- Add spatial buckets to reduce **candidate search** to nearby monsters/disciples (not a guarantee of global O(n) for worst-case all-packed actors).
- **Event-driven tiered AI:** active aggro/casts/status/respawn resolve at canonical due ticks; idle wild mobs evaluate patrol periodically using deterministic stagger. **No arbitrary FPS-dependent tick skipping or camera-based damage**.
- Pathfind only after new assigned camp/target loses route/obstruction; reuse cached paths for patrol, and avoid 30×navigation requests every visible frame.
- Central schedule for cooldown/DoT/respawn and bounded proc/child packets; backpressure and resumable cursor if tick cannot finish, never discard HP0 receipts or generate “estimated” kills.
- **Renderer:** visible Source A sprites/atlas plus VFX budget, distant mobs and minimap represented with icons/clusters; don't spawn 400 animated nodes with costly per-frame skill trees if offscreen. Culling changes only appearance, not actual mob HP/status.
- Damage/loot/skills deterministically same on-camera/off-camera and after Save/Load. Field test FPS, p95/p99 sim tick CPU, memory, nav backlog, active targets, pending projectile count, status events and VFX drawcalls on **real** 8GB Windows and Android 1280×720.

### 6.2 Four progressive benchmark tiers, **not a new fixed world cap**
| Stage | Active disciples | Camps | Base living mobs | Purpose |
|---|---:|---:|---:|---|
| P0 geometry/input | 3 | 2–3 | 20–30 | command, navigation, respawn/kill |
| P1 opening full map | **30** | **20** | **200** (10/camp) | first owner density with realistic assignments |
| P2 mid density | **30** | **20** | **300** (15/camp) | realistic battle pressure and all-camp simulation |
| P3 dense target | **30** | **20** | **400** (20/camp) | desired full camp density |
| P4 stress only | 30 | 20 /30 conditional | 600 | measure scalability, not implicitly lock30 per camp |

P0/P1-P4 are test DESIGN, not evidence of executed benchmark or delivered code. Elite/Boss may be included by replacing slots as content decision; count separately if they add world actors.

### 6.3 Failure and exploit fixture matrix
- 30 disciples to 20 camps: 10×2 +10×1, no duplicate job, no one-person ghost camp.
- Single camp 15 spawn slots: kill slot#3 generation12 → one loot+mastery/taxonomy event, respawn generation13 after policy time; save between kill/ACK, no duplicate reward.
- Two disciples strike same monster within same canonical step (including one DoT and one projectile): at most one HP0 kill receipt, actual per-disciple contribution attributed.
- Moving actor crosses chunk boundary and starts targeting one mob in neighboring camp; target generation invariant; projectile launched before crossing still follows authored rules.
- One Boss crosses multiple camp boundaries; 5 teams can help; one Boss HP, no last-hit-only loot, no 20 independent Boss pools, eligibility to join and fight governed by world.
- Pan camera and minimap repeatedly over identical seed/actions; HP, monster count, positions and receipts identical; only visual stream diverges.
- 20 camps respawn same tick: no new spawns over cap, stable order, no hitch silently dropping rest; resume cursor after save.
- Multiple monsters aggro solo disciple at one of 20 camps; retreat/leash safe, no permanent stunlock without exact status/Boss resistance design.
- V2 skill on 200 mobs: range/target cap respected, AoE doesn't hit entire camp via global actor scan bug, multiple visual missiles do not multiply real damage.
- Selection/drag vs command: left select, right click order, right drag pan conflict, pinch pan touch, minimap camera-only default; wrong-map/occluded/unreachable camp returns truthful rejection.
- One Active Job while moving, target dead, manual Auto OFF, Injury at tick119/120 and return; no simultaneously produce Mine and farm monsters.
- Map instance save/load offscreen: one actor ID; no full-map terminal Victory receipt; per-kill source and material Warehouse exactly once.
- Canonical 5 area difficulty levels from HuntingMapV2 remain historically separate from 20 camp count: changing map difficulty mode must not accidentally multiply number of world instances/loot pools. How difficulty grades apply to an open-world region requires owner design.

## 7. Gameplay depth and path specialization in twenty camps
A hunting **camp** can be authored with enemy species, element, resist, mobility, terrain, threat and drop families. This creates genuine matchups without artificial "specialist +20% damage" labels:
- **Sát Kiếm specialized** can focus isolated elite/high HP camps when its own learned attack/talent matches.
- **Pháp Ngũ Hành** can choose areas with mob groups suitable for an authored capped AoE, with resist matchup RootV2 when that feature actually exists.
- **Kim Cương Thể** can escort a healer/support on dense patrol and survive actual aggro.
- **Kiếm–Pháp mixed** has learned both style families but **one active soft Chủ Đạo/branch** per V2, 1 Main+2 Support Techniques and 1 Basic+4 Active+6 Combat Passive; only legal equipped skills fire. No global mixed penalty invented.
- Some camps offer authored rare monster/manual/bloodline/material drops (B3), and the AI/owner selects based on missing materials and proven survivability; current region sources/levels should not be overwritten without a new balance decision.
- Visible player choice: right-click a camp to dispatch disciple(s), view estimated danger/mob types/drops, keep farm/retreat; switch camp in response to Boss warning/shortage rather than micromanaging every attack.

## 8. Outstanding owner decisions, with a default proposal rather than a forced numeric lock
**O1 geography:** 20 camps within Thanh Trúc Lâm is the working **example**. Other maps may have other numbers. Recommend 20 authored camps for first meaningful world study, NOT one combat instance per camp.
**O2 counts:** recommend **initial 15 alive slots ×20=300** as explanatory center, with 200/400 benchmark; owner may later demand low/high variation by camp. No hard cap of 200.
**O3 distribution:** allow ≥1 disciple per camp and shared camps/team play; with 30 people and20 camps, default test 10×2 +10×1. A strict one-person-per-camp policy would require 30 camps or send remaining10 to another map.
**O4 world combat authority:** candidate C single authoritative map actor registry + spatial chunks; reuse canonical Combat V2 hit/status/loot rather than clone mini-battles. Implementation risk high; do not approve yet.
**O5 minimap and mouse semantics:** selected player units + right-click route/orders + camp farm; camera separate; Android explicit touch mode. Visual design and input priority still owner/UI review pending.
**O6 Elite/Boss/regeneration:** authored per-map schedule, monster spawn generation, Boss one HP per world; exact spawn timer/aggro and reward/respawn pressure OPEN.
**O7 five difficulty grades:** decide if global map difficulty selection persists as a modifier to all camps, or each camp has authored difficulty within one map, or both; preserve original P3.7 pilot behavior until separately approved. Avoid five separate maps named Thanh Trúc Lâm being created merely for five grade selectors.
**O8 progression:** same user-approved DEV fresh-world-per-code-version, within-version save/loot/journal exact once; no old DEV save migration packet.

## 9. Deep-design dependency path — NOT A CODEX PACKET
1. Verify with owner the semantics **20 camps on ONE Thanh Trúc Lâm map** and independent density 10–20, make a design topology drawing/mock camp metadata not a Godot UI change.
2. Compare one-world versus local arenas **across chunk and Boss/DoT incidents**; identify the minimal reusable part of MapBattleV2 CombatStats and continuous kill receipts. No simultaneous PR29 writer.
3. Detail camp spawn/respawn economics and AI FarmFSM, including solo/rally/group, wait, threat and retreat with current OneActiveJob and Injury120.
4. Define input mode & minimap with Android 1280×720 acceptance cases, UI owner separately.
5. Benchmark 200→300→400→600 with authentic canonical Combat simulation once CODE authorized; until then never promise FPS/device acceptance.
6. Only **after architecture approval AND separate explicit CODE permission** prepare a narrow scoped integration packet. NOT SK-A/B yet, not a 20-camp implementation in this iteration.

**End state:** conceptual geography corrected; authoritative scope and dependencies documented; repo code and every Codex PR untouched; no Godot tests/performance or actual in-game RTS functionality claimed.
