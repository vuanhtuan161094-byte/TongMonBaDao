# TÔNG MÔN BÁ ĐẠO — HỒ SƠ NGHIỆM THU THIẾT KẾ LIÊN RANH GIỚI NHÂN→TIÊN, TIÊN→THẦN
## Dependency graph, softlock, migration hiện trạng, QA fault injection, mô phỏng vật tư và owner sign-off

**24/10/2026 · DESIGN ACCEPTANCE PACKET, NOT CODE IMPLEMENTATION PACKET.** User agrees THREE COMMON material SOURCE model + independent rare chase in principle, but NO rates, numeric recipe/ID, code, merge, PR29/UI/Source A changes approved. [S]=current verified main, [L]=canonical approved design, [P]=new proposal, [SIM]=artificial mathematical experiment, [D]=runtime missing. **DO NOT CALL A SIM A GODOT TEST.**
**Read sources at main `29b5fba448b0178cb520a4ada44b375b4b934e31`:** `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/REALM_LADDER_V2_SPEC.md`, `docs/WEAPON_EQUIPMENT_V2_SPEC.md`, `docs/EQUIPMENT_SETS_V2_SPEC.md`, `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md`, `docs/P3_7_BUILDING_TREE_SPEC.md`, `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`; Godot `state/{sect_state,simulation_state,disciple_state,building_state}.gd`; `save/save_service.gd`, `resource/{resource_registry,warehouse_system}.gd`, `combat/{monster_catalogue_v2,hunting_map_v2}.gd`, `workforce/workforce_system.gd`. Proposed parent catalog ``docs/forge-r11-r30-source-blueprint-economy-anti-softlock-20261024` and previous Lv1/Lv30/Lv75 Forge journals/gear V2 source matrices. Specific boundary dossiers this branch: `docs/design/TMB_R10_R11_FIRST_ASCENSION_GEAR_DESIGN_ACCEPTANCE_2026-10-24.md`, `docs/design/TMB_R20_R21_FIRST_DIVINE_ASCENSION_GEAR_DESIGN_ACCEPTANCE_2026-10-24.md`.

## 1. Actual code blockers — do not misclassify proposed data as runtime
| Scope | Existing SOURCE main | Needed for R11 and R21 | Design readiness |
|---|---|---|---|
| Resource IDs | `ResourceRegistry` current low common resources; late `body_gate_*` resources/seals are NOT gear Forge consumer IDs | `eqv2_r11_ore/fiber/beast` and `eqv2_r21_ore/fiber/beast` + optional Elite/Boss IDs with real source & approved tags | **ABSENT / source blocked** |
| Actors | `MonsterCatalogueV2` 7 starter species, some `loot_ready=false`, `HuntingMapV2` 3 starter regions/5 per-encounter difficulties | R11 Vân Giác Lộc and R21 Sơ Thần Thạch Nhân, authentic world spawn, stats, real kill→Warehouse | **ABSENT** |
| Mine/Forest source | Existing lower-tier P3.7 node/building labor | a **physically accessible** next-tier node at R−1 gear, real persistent harvest and source receipt | **NOT AUTHORED** |
| Blueprint archive | Earlier docs only [P] learned-once knowledge, `SectState` no V2 blueprint archive | per-rank Sect-wide unlock persisted and journaled only after 1ore+1beast consumption | **ABSENT** |
| Forge | P2 EquipmentSystem 3 legacy slots/5 recipes, BuildingSystem/Workforce foundation exists | V2 10 slots, selected item template, worker/job, item realm/generation/grade, legitimate Lv30/75 facility operation | **ABSENT** |
| Warehouse | `WarehouseSystem` stackable registry checks and user reserve_min/locked, `MAX_SAFE_STACK`, legacy P2 bucket bridge | per-order resource/Stone reservation, one unique gear item registry and atomic debit+credit+XP settlement | **ABSENT** |
| Save | `SaveService.CURRENT_VERSION=2` with staging/backup recovery; `SimulationState.SAVE_VERSION=1` and opt-in `SectState` | versioned new schema/content, no duplicate item/resource/blueprint when loading, safe downgrade behavior | **NOT MIGRATED** |
| Gear eligibility | design V2 item realm1..30, quality1..12, Sect-owned, legal skills and set generation | R11 Tiên and R21 Thần wearable only with correct cultivation track and canonical slot, staged swap | **NOT LIVE** |
| Work/clock | P3.7 worker XP speed curve `1+.01×level`, One Active Job and Injury0/1/120 direction, time tick one sim minute | real R11/21 profession jobs, independent gather/forge assignments, offline replay once | **JOB INTEGRATION OPEN** |

## 2. Formal directed prerequisite graph and first-source proof
**Per boundary B ∈ {11,21}:**
~~~text
old legally equipped combat/gathering team R=B−1
        |
        +--> [travel route and frontier spawn reachable with old gear] ---+--> ore node (M)  ---+
        |                                                               +--> fiber node (F) ---+---> Sect Warehouse
        +--> [combat-survivable ordinary mob R=B frontier margin] ------+--> beast drop (N) --+
                                                                                                  |
real authorised qualified Forge worker & facility reachable from old tier -----------------------+
                                                                                                  |
                                                                                  learn basic catalog ONCE:
                                                                          debit 1 ore + 1 beast + work
                                                                                                  |
                                                                                choose actual gear slot
                                                                                                  |
                                                                       reserve ore+fiber+beast+Stones
                                                                                                  |
                                                                                 work canonical ticks
                                                                                                  |
                                                           frozen RNG → one physical item + single receipt
                                                                                                  |
                                                   eligible wearer → assignment / coherent set replacement
~~~
**Cycle detection:** a candidate source is INVALID if `requires_gear(B)`, `requires_blueprint(B)`, `requires_boss(B)` or `requires_building_lvl75` whose OWN bill uses `gear(B)`, unless another independent old-tier source path is already proven. Research unlock must not require equipment produced by that same research. The R21 strict Lv75 option adds a second dependency branch; it is admissible only when Lv30→75 facility bills are all genuinely payable using ≤R20 sources and work ability.
**Emergency recovery policy:** loss of an R10/R20 party due Injury is a TEMPORARY delay only if 120-tick recovery/return remains accessible and a lawful hunter/worker can be reassigned afterwards. If the only party permanently dies/loses all gear and no production or recruit option can regain entry, the content may be permanently softlocked; owner must approve true recovery avenue rather than instantly respawning free R11/R21 loot. Reassignment respects One Active Job. No fake passive grinding while all units injured.

## 3. Deterministic arithmetic for 10-slot baseline and catalog learning
Parent trial ingredient vector per complete10-item kit =15 ore +21 fiber +4 beast. Proposed Sect-wide **one-time research unlock** requires1 ore +1 beast, not one per disciple. Proposed currency per kit: `20×R` Sect Stones, work per item: `t_R=12+2(R−11)` Sect ticks. Real speed/lanes/staff, source rates and ability remain unapproved.
| Boundary / tier | 1 kit before research | 30 kits + first research input | 300 kits + research | 1,000 kits + research | 3,000 kits + research |
|---|---|---|---|---|---|
| R10→**R11** | 15/21/4 ·220 Stones ·120 ticks | **451/630/121 ·6,600 Stones ·3,600 ticks** | 4,501/6,300/1,201 ·66,000 Stones ·36,000 ticks | 15,001/21,000/4,001 ·220,000 Stones ·120,000 ticks | 45,001/63,000/12,001 ·660,000 Stones ·360,000 ticks |
| R20→**R21** | 15/21/4 ·420 Stones ·320 ticks | **451/630/121 ·12,600 Stones ·9,600 ticks** | 4,501/6,300/1,201 ·126,000 Stones ·96,000 ticks | 15,001/21,000/4,001 ·420,000 Stones ·320,000 ticks | 45,001/63,000/12,001 ·1,260,000 Stones ·960,000 ticks |
**Notation:** `ore/fiber/beast`. ONE research unlock for the whole Sect included ONLY in materials column; its research ticks/Stone/work are **NOT defined** and excluded; other production/recruit/re-equip/boss/repair, travel or injury excluded. **30 deployed in ONE world** not all3,000 deployed. Disciples already wearing eligible gear/hand-me-downs reduce demand. Building upgrade cost to Lv30/75 is excluded. At1,440 sim ticks/day, serial continuous Forge-only durations for30/1k/3k R11 =2.50/83.33/250 days, R21 =6.67/222.22/666.67; these ARE NOT calendar ETA or in-game tested throughput.
**Sourcing bottleneck:** if beast common material per TRUE ordinary kill is stochastic Bernoulli with trial q, expected kills to obtain K drops `E=K/q`, and negative-binomial tail matters. First30 complete gear kits plus research require K=121 beast units. No high-rank kill/hour in code; do NOT claim how many hours/months sourcing takes. Without a bounded source, an unlucky player may have no material to start catalog research. Recommended design tradeoff: per-eligible-kill **one guaranteed COMMON material**, while rare gear/blueprints/Boss relic use the independently approved HIẾM rarity, OR one progression counter guaranteeing common material after N genuine kills. Both require owner approval and actual shared receipt source.

## 4. Synthetic loot stress with reproducible seed (NOT GODOT)
**Exact synthetic procedure executed off-runtime:** one continuous xorshift32 uint32 stream seeded `20261024`; `q∈{1,.5,.25}` in order; for each q, target K∈{1,121}, 10,000 independent repeated trials, count Bernoulli trials until K successes, record mean/median/p90/p99. Percentiles by floor(p×(N−1)). This is NOT an R11/R21 drop simulation, just the statistical mechanics of a proposed future common-material source.
| P(beast per authentic eligible kill) trial | Needed successful beast units | Analytical expected kills | Synthetic mean kills | Median | P90 | P99 |
|---:|---:|---:|---:|---:|---:|---:|
|100%|1|1|1.00|1|1|1|
|100%|121|121|121.00|121|121|121|
|50%|1|2|1.998|2|4|7|
|50%|121|242|241.741|241|262|281|
|25%|1|4|4.011|3|9|17|
|25%|121|484|484.216|483|535|576|
**Suggested owner choice:** unlike rare quality gear, common next-rank beast source must be reliable to avoid systematic progression stalls at population1,000–3,000. A guaranteed **COMMON crafting material** per true kill doesn't mean rare gear or first-book automatically drops; do not multiply enemy kills by30 participants or apply five per-encounter difficulty odds per monster.
**Pseudocode for future independent reproducibility (no runtime tests executed):**
~~~text
rng_state = int32(20261024)
random():
  rng_state ^= rng_state << 13
  rng_state ^= unsigned(rng_state) >>> 17
  rng_state ^= rng_state << 5
  return unsigned(rng_state) / 4294967296
for q in [1.0,0.5,0.25]:
  for K in [1,121]:
    10000 independent samples: count genuine hypothetical kills until K Bernoulli(q) successes
~~~

## 5. Migration design contract: ADDITIVE, FAIL CLOSED, never fabricate V2 state
**[SOURCE] existing reality**: SaveService writes staged, validates and preserves backup; its CURRENT_VERSION=2, while SimulationState.SAVE_VERSION=1 is a separate internal constant. `SectState` already has `equipment_items,forge_materials,equipment_forge_index` for old P2 equipment, `warehouse_resources,p3_7_resources_enabled,warehouse_rules` for newer canonical material stacks and `spirit_stones`; `DiscipleState` has legacy locked equipment slots and profession work states, `BuildingState` has level/upgrading/progress/worker group, and stored PvE state contains old encounter receipts. Do not treat these as already holding the proposed blueprint archive or 10-slot unique gear journal.
**[P] new field families must be additive with independent migration:**
- `sect.eqv2_content_schema_version` and `sect.eqv2_archive_learned_recipe_ids` (Sect-wide unlock keyed exact rank recipe ID; never a stack that may be doubled)
- `sect.eqv2_gear_unique_items` keyed global unique instance_id, with content/template version, item_realm, generation, grade, genuine source receipt, canonical slot, legal affixes, assignee/lock state.
- `sect.eqv2_source_receipts` keyed (world_instance,node_or_actor_id,life_or_harvest_generation,source_version) with dedup and spent/effects; `sect.eqv2_forge_order_journal` keyed order_id and idempotency_key, reference resource reservation, frozen result and settle receipt.
- `sect.eqv2_resource_order_reservations` as an overlay on the **one** canonical `warehouse_resources`; `sect.eqv2_stone_reservations` on canonical Sect spirit_stones, not P2 personal currency. No second Forge material bucket or new wallet.
- `disciple.eqv2_assigned_unique_item_ids` separately keyed canonical 10 ordinary slots with lawful source item location, no automatic `talisman→pendant` and no cloning old legacy P2 gear. Protect old source items from double migration.
- `building.eqv2_real_forge_lane/order_ref` only if one actual facility and worker job authority supports it; don't equate theoretical2 worker slots with two legal concurrent orders.
**[P] migration order, no implementation now:** (1) read and validate original signed/versioned Save payload into isolated snapshot; (2) preserve untouched original backup; (3) detect old P2 vs P3.7 enabled and perform ONLY the already-authorized legacy warehouse bridge once; (4) initialize new V2 fields EMPTY/disabled (not free Tiên/Thần blueprint or item); (5) register new actual content IDs via separately approved ResourceRegistry migration before accepting any future high-tier stack, fail closed on unknown IDs; (6) validate all material totals/unique item owners/assignees and item versions; (7) publish one atomic/backup-safe upgraded Save only if all invariants pass; (8) test Save→Reload→Save N times stable. **Never claim a SaveService version bump has been made or select a version number from thin air.**
**Legacy compatibility:** keep old `equipment_items` and P2 `forge_materials` ownership until explicit adapter/phase; no conversion to generic R11/R21 item for level>=11/21 and no material bridging twice. Current real registry rejects unknown IDs; if new Save with future `eqv2_r11_ore`/`eqv2_r21_ore` is opened by older runtime, the older app MUST reject newer schema safely or use backup; stripping unknown materials/gear while retaining spent costs is data LOSS, unacceptable. Downgrade needs archived pre-migration snapshot and an owner-approved discard/projection contract; do not promise older client reads future save.
**Crash cut points, all mandatory later:** after mining/gather source receipt, after kill loot before ACK, during blueprint research RESERVED and consumed, at unlock persisted, Forge RESERVED, RUNNING, RESULT_FROZEN, after stock/Stone debit before unique item insert, after item insert before completion ACK, on equip/set swap/inheritance donor destroy. Do not trigger loot/XP from UI.

## 6. Severity-coded fault injection scenarios and design expected outcome (NONE EXECUTED)
| ID | Boundary | Fault setup | Expected authoritative outcome |
|---|---|---|---|
| F01 | R11 | R10 party is unable to path to ANY `eqv2_r11_ore` node except through R11-gear gate | **BLOCKER: author old-gear accessible frontier route** |
| F02 | R21 | R20 miner cannot reach `eqv2_r21_fiber` except via Lv75 R21-ore requiring craft | **BLOCKER: break dependency cycle with lower-tier access** |
| F03 | R11 | normal beast R11 never drops crafting material after100 eligible real kills | if q<1, evaluate bounded guarantee; no UI gift or fake kill |
| F04 | R21 | R20 team fights only full R21 boss to earn basic beast | **BLOCKER: add normal accessible R20-high encounter** |
| F05 | R11 | first blueprint research requires result item R11 itself | **BLOCKER: replace circular prereq** |
| F06 | R21 | Lv75 requires R21 boss relic as building upgrade ingredient | **BLOCKER if Lv75 mandatory for first gear; choose legal Lv30 bridge or earlier building bill** |
| F07 | R11/21 | only qualified worker injured, Injury1 recovery120 | no new item/work while ill, persistent pause, lawful recovery/reassignment and no double job |
| F08 | R11/21 | same worker actively hunting and also accepted Forge work | reject/pause one command; One Active Job canonical |
| F09 | R11 | warehouse user reserve_min would be violated by blueprint research | refuse before debit, no free archive unlock |
| F10 | R21 | resource `eqv2_r21_ore` not registered | no fake stock or gear, order disabled |
| F11 | R11 | `an_tien_gioi` used as Forge ore input | reject; Body-Gate seal never reused without explicit shared contract |
| F12 | R21 | `an_than_gioi` used as Forge catalyst | reject; original Body-Gate consumer protected |
| F13 | R11 | player switches five map difficulty grades to force ore rewards | encounter-level odds never become high-rank per-kill material faucet |
| F14 | R21 | Boss attacked by30 disciples and 5 parties, killed in same step | one HP pool, one kill/receipt, no reward×30 |
| F15 | R11/21 | mine node harvested then Save reloaded before UI toast | one node-generation resource receipt, not two |
| F16 | R11/21 | same beast actor ID respawns/reloads after death | actor generation differentiates lives; stale death receipt not paid twice |
| F17 | R11/21 | blueprint research accepted twice from same source receipts | one archive unlock/one debit, duplicate request returns original receipt |
| F18 | R11/21 | two Forge orders reserve same final ore unit | first reserve wins, second fails BEFORE start |
| F19 | R11/21 | forge tier-specific quality RNG rerolled by reload at RESULT_FROZEN | same frozen quality/affixes/item ID |
| F20 | R11/21 | crash after deducted material+Stones before unique item insert | rollback or durable redo, NEVER material-only loss |
| F21 | R11/21 | crash after unique item insert before acknowledgment | replay returns one gear item, one input debit and one worker XP |
| F22 | R11 | old legacy `talisman` in P2 gear while adopting 10 slots | never auto map it to V2 `pendant` or clone inventory |
| F23 | R21 | R20 Tiên set4, one new R21 Thần piece autoequipped | no false4-piece mixed-generation bonus and old set locked/staged |
| F24 | R21 | donor R20 piece inherits into new R21 target then crash | donor consumed once; target unique ID/version once, optional noncash credit once |
| F25 | R21 | alpha70% A→B→C chain counts original paid value twice | reject double credit, permit only owner-approved one-hop or diminishing provenance |
| F26 | R11/21 | user cancelled after seeing rolled bad grade | refuse cancel after result freeze; no free roll reset |
| F27 | R11/21 | level-up of wearer alone “promotes” gear R10→11 or R20→21 | no mutation/free generation, new source gear required |
| F28 | R11/21 | old client loads future gear/material IDs | safe schema rejection or backed-up rollback; no silent deletion |
| F29 | R11/21 | 3,000 roster scheduled on one 30-hunter world | forbid unrealistic deployment; schedule only legal actors |
| F30 | R11/21 | physical Android/Godot test not run | mark NOT TESTED; no UI/CI/FULL/visual acceptance claim |
| F31 | R21 | new R21 set piece claimed Hỗn Độn bonus without real source/consumer | refuse; Thần generation eligibility alone insufficient |
| F32 | R11/21 | protected warehouse lock introduced while running existing reserved order | accepted reservation retains its journal rule, new order blocked; cancellation policy explicit |
| F33 | R21 | Forge Lv75 upgrade source payable only by already-forged R21 weapon | BLOCKER under Path B; choose Path A or genuine old-tier facility bill |
| F34 | R11 | source kills/headless offline reprocess without actual life IDs | no rewards or profession XP from replayed ghost battles |
| F35 | R11/21 | 2/4 worker slots assumed to equal2/4 actual queues | capacity must be proven by facility/worker integration; otherwise one lane only |
| F36 | R11/21 | candidate item realm exceeds wearer eligibility | gear remains in Sect Warehouse, no equip or stat bonus |

## 7. Acceptance decisions and genuine status — sign-off sheet
| Gate | Design packet provides | Still mandatory before a GAMEPLAY PASS | Status |
|---|---|---|---|
| A. Canonical realm and gear | R10→11, R20→21 generations, 10 slots,24 sets,One Job | actual valid item templates/consumer under Combat V2 | **DOCS traced / runtime pending** |
| B. First-source before target | accessible old-geared ore,fiber,normal beast graph | authored map path, nodes, species, kill/harvest reward receipts | **BLOCKED runtime** |
| C. Common vs premium | Boss/Elite/Bí Cảnh separate and cannot gate 10 basic slots | source drop/guarantee denominator, one Boss HP/loot event | **OWNER source policy open** |
| D. Basic library and Forge | exact trial [1ore+1beast] research,10 selected recipes,work ticks & Warehouse settlements | V2 worker, archive, item registry, reservation and journal | **BLOCKED runtime** |
| E. Lv30/75 | R11 Lv30 candidate; R21 Path A Lv30 basic or Path B proven Lv75 | FULL Lv75 bill payable from R20 and facility ability if B chosen | **OWNER DECISION OPEN** |
| F. Save migration | current versions and additive schema plan, safe backup/downgrade | official Save/Load/recovery/legacy regression + simulated crash fixtures run in engine | **BLOCKED implementation** |
| G. Economy scale | 30/300/1k/3k input arithmetic & reproducible q model | authentic ore/fiber production and kill/hour, economy/stones/travel/One Job benchmarks | **TRIAL model, not balanced** |
| H. Verification | 36 explicit future fault fixtures & rollback | official Godot4.7.2 focused/cumulative and Windows/Android physical, owner UX sign-off | **NONE EXECUTED** |

**Recommend owner approve only these design principles next:** (1) A next-rank normal ore/fiber/beast route available with old gear; (2) true source-backed once-per-Sect basic blueprint; (3) 10 basic output recipes requiring real worker/canonical Warehouse/tick; (4) R11 Lv30 and **R21 Path A Lv30 basic** with Lv75 reserved advanced (OR choose proven R20-paid Path B); (5) generation-safe new target and optional noncash inheritance. All candidate IDs/numbers/source maps/drop curves/content and +3/80/55/70% legacy trials remain OPEN, and THIS DOC NEVER authorizes coding or PR29 changes.
