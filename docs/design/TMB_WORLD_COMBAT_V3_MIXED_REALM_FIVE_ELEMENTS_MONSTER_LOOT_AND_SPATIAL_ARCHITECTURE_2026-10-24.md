# TÔNG MÔN BÁ ĐẠO — WORLD COMBAT V3 / THANH TRÚC LÂM
## 30 đệ tử, 20 bãi quái, 200–400 quái độc lập cảnh giới và ngũ hành, loot trang bị/vật tư từng con, RTS auto farm

**Ngày:** 2026-10-24. **Chế độ:** DESIGN/DOCS ONLY. KHÔNG CODE, KHÔNG PACKET CODEX SK-A/B, KHÔNG SỬA PR29/UI/SOURCE A, KHÔNG MERGE.
**Owner approval/direction:** “cùng một map quái khỏe cũng khác nhau, không nhất thiết phải có cùng cấp độ với nhân vật. có rớt các loại trang bị vật tư khác nhau, như Võ Lâm. hệ khác nhau nữa: Kim Mộc Thủy Hỏa Thổ. Chọn A World Combat, còn lại ok.”
**Status split:** OWNER INTENT = một map lớn Thanh Trúc Lâm có khoảng 20 camp ×10–20 mobs, 30 disciples, không cùng cấp quái; đồ rơi phong phú/có ngũ hành. PROPOSAL = kiến trúc, phạm vi cảnh giới từng bãi, chi tiết loot, tọa độ, event frequency. LOCKED = Combat V2 math, One Active Job, Injury 0/1/120, single Warehouse/CARE, same-build exactly-once, canonical Spiritual Root/Equipment V2, Source A visuals. CODE = not implemented. QA = no actual Godot load tests run.

**Verified main:** `29b5fba448b0178cb520a4ada44b375b4b934e31`. PR29 HEAD `9522812e91b7ca5bc0cc108eb92e000e930fe850` OPEN/DRAFT, focused QA pending at latest read.
**Checked authorities:** AGENTS.md, docs/GAME_SYSTEM_ARCHITECTURE.md, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md, docs/COMBAT_SKILLS_V2_SPEC.md, docs/SPIRITUAL_ROOT_V2_SPEC.md, docs/WEAPON_EQUIPMENT_V2_SPEC.md, docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md, docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md. Read actual `monster_catalogue_v2.gd`, `monster_encounter_v2.gd`, `hunting_map_v2.gd`, `hunting_pve_run_v2.gd`, `map_battle_v2.gd`, `combat_stats_v2.gd`, `equipment_system.gd`.
**Parent topology:** docs/design/TMB_THANH_TRUC_LAM_20_CAMPS_TERRAIN_SPAWN_DIFFICULTY_RTS_WORLD_CONTRACT_2026-10-24.md on branch docs/ttl-20-camps-map-topology-five-difficulties-design-20261024. Retain its 20-camp bridges/paths and proposed map logic; update its former uniform early-realm illustrations here.

## 1. What player will see, and three separate scales
- One continuous Thanh Trúc Lâm open-world, ~20 camps/spawn clusters; about **10–20 live monster slots/camp**, total **200–400 when fully populated**, center illustration 300; 600 is explicit higher stress tier only. Monster population fluctuates as they die and await respawn.
- **Up to 30 deployed disciples in this map**, individually or as groups. Selecting a unit/units and ordering MOVE, ATTACK_MOVE, FARM_AREA, FOCUS, HOLD or RETREAT uses RTS-style controls; after arriving in a camp the disciple chooses targets/skills automatically and continues farming. Mini-map camera and camp selection do not own combat.
- One camp may have Trúc Thử and another Hắc Lang, and **two animals of the same species may have different author-assigned monster realm/floor**; neither takes the disciple's level from current group or attacker. Normal high-realm and Elite low-realm are logically different axes.
- Same map can contain **Kim/Mộc/Thủy/Hỏa/Thổ**, with U Minh/Nether distinct as already authored. When a monster dies, its own species/tier/element/realm/loot source can roll its **own** eligible materials, unique equipment, manuals/parts (if registered), not one end-of-map box.
- 1,000–3,000 total Sect disciples is a workforce scheduling objective, **not** 3,000 characters spawned in a 30-disciple map. Schedules and simulation correct offscreen, renderer culls visible detail only.

**Map selected grade L1–L5 ≠ camp risk ≠ monster realm/floor ≠ monster tier normal/elite/boss ≠ monster element ≠ equipment realm requirement/grade.** Do not map all six to one variable.

## 2. Actual code baseline — guard against fabricating implementation
| System | Confirmed live source (not runtime QA) | Missing for design |
|---|---|---|
| `HuntingMapV2.REGION_CONTENT.thanh_truc_lam` | baseline monster realm1/floor1; normal weighted selection: Trúc Thử65%, Thanh Lang30%, Hắc Lang5%; Elite Nham Giáp Thú, Boss Hắc Lang Vương; 5 regional encounter levels. | Current `spawn` passes **ONE region realm/floor for every monster in a finite 3–7 group**; no 20 physical camps, per-slot creature realm, respawn or per-monster world drop. |
| `MonsterCatalogueV2.create_actor(species_id,realm_index,floor_index,encounter_id)` | accepts independent monster realm index1..30/floor1..10 already. Pilot growth `1.65^(realm−1)×1.03^(floor−1)` then species/tier factors. Species stores element, behavior_id and loot_ready. | independent per-world-slot realm selection, world actor identity/AI and dedicated equipment loot tables unimplemented. This is reusable source math, not proof full gameplay. |
| `CombatStatsV2` / `MonsterEncounterV2` | per-hit legal elemental data, defenses/resistances and duplicate hit guards; canonical damage authority. | no separate second world combat formula permitted, no auto elemental skill from monster species. |
| `MapBattleV2` | arena36×20, MAX_DISCIPLES30, MAX_MONSTERS40, party max6, STEP_SECONDS0.25, finite90sec; targets scanned across actors. | not a 20-camp, 200–400-monster seamless RTS world, dynamic spawn or long-lived per-kill payout. |
| `HuntingPveRunV2`, `HuntingMapV2.claim_reward` | rewards on victorious finished encounter; resource factors per encounter; warranty Linh Tuy once after 4 qualifying victories. | not reward for every creature death; no multiplied 300× legacy per-win rewards. |
| `EquipmentSystem.forge_loot_for_victory` | old P2 material payout for Trúc Thử/Thanh Lang/Hắc Lang; P2 recipe equipment, only3 slots. | not canonical V2 10-slot/12-grade instanced item drop from arbitrary world monsters. Legacy route cannot double pay new route. |
| `WEAPON_EQUIPMENT_V2_SPEC` | **DESIGN LOCKED** 10 ordinary slots, separate3 Phù+2 Pháp Bảo, 12 gear grades, equipment realm1..30; all gear Sect-owned. | grade/drop rates/instance generator, named pool and actual Loot V2 authority not implemented. |
| `SPIRITUAL_ROOT_V2_SPEC` | **DESIGN LOCKED** five base disciple roots Kim/Mộc/Thủy/Hỏa/Thổ and purity1..100, elemental matchup when legitimate element skill hits. | monster element tags do not mean monster has the disciple root purity system. Novel enemy resist/skills need authoring. |

### Existing species identity is NOT rewritten
| species_id | Tier | Actual coded element | coded loot_ready |
|---|---|---|---|
| `truc_thu` | normal | **wood/Mộc** | true legacy |
| `thanh_lang` | normal | **wood/Mộc** | true legacy |
| `hac_lang` | normal | **nether/U Minh** | true legacy |
| `nham_giap_thu` | elite | **earth/Thổ** | false |
| `u_hon` | normal | **nether/U Minh** | false, not TTL normal pool |
| `huyet_lang_dau_dan` | elite | **fire/Hỏa** | false, present catalogue but not TTL base region |
| `hac_lang_vuong` | boss | **nether/U Minh** | false, boss phases deferred |

**Critical missing content:** Current TTL normal pool contains no Metal/Water/Fire regular species. Existing Hỏa Elite from another zone doesn't magically give all 5 base elements to TTL. **New proposed variants** such as Hỏa Văn Lang / Kim Giáp Trùng / Thủy Vụ Linh are content candidates ONLY, without approved registry ID, art, skills, statistics or drop table. Alternatively owner may authorize adding real existing catalogue species to TTL with authored eligibility. Never call new variants implemented; never recode Hắc Lang U Minh as Hỏa.

## 3. Varying monster strength INSIDE one map
### Proposed independent MonsterSpawnProfile / SpawnSlot
\`\`\`yaml
map_instance_id: ttl_world_01
camp_id: ttl_c08
spawn_slot_id: 04
species_id: thanh_lang       # existing catalogue example
monster_realm: 1             # independently authored 1..30, not disciple.realm
monster_floor: 7            # independently authored 1..10
tier: normal
element: wood               # from actual species definition; no arbitrary override
monster_ai_profile: pack_hunter
camp_leash_profile: ttl_c08_pack
loot_profile_id: ttl_wolf_fur
difficulty_source: region_selected_grade
source_seed_namespace: [map_instance_id,camp_id,spawn_slot_id,spawn_generation]
\`\`\`
**Design invariants:** specific slot rolls species/realm/floor deterministically and saves once on spawn, not rerolled on target change/viewport changes; tier from legitimate species or approved variant. For any monster active at same time, identity is `map_id:camp_id:spawn_slot:generation` and actual HP/pos/status/source; a monster crossing from C08 to C09 doesn't respawn or become C09 species/loot.
**Monster attack elements:** an element-tagged monster is **not automatically** doing element damage on every basic attack; current monster ordinary hit uses empty attack element. Actual enemy skills must declare their own element, Burn/Freeze/CC etc; species element alone never generates those effects.

### Proposed 20-camp monster bands and target loot identities
These are **CONTENT OPTIONS**, no canonical levels/loot chance. R1F3 = monster first realm, floor3. Entire map can include later-realm monsters if owner approves balance; no hard equalization to player level.
| Camp | Core mob ecology | Proposed floor band | Element mix | Main farm incentive |
|---|---|---|---|---|
| C01 | Trúc Thử | R1F1–3 | Mộc | Linh Mộc, basic herbs |
| C02 | Trúc Thử/Thanh Lang | R1F2–4 | Mộc | fur/wood |
| C03 | Trúc Thử + future water variant | R1F2–5 | Mộc/Thủy* | herb/water part* |
| C04 | Thanh Lang/Water variant* | R1F3–7 | Mộc/Thủy* | water component* |
| C05 | Thanh Lang/Hắc Lang | R1F4–8 | Mộc/U Minh | fur/fang/core |
| C06 | Trúc Thử/Thanh Lang | R1F1–5 | Mộc | steady wood |
| C07 | Thanh Lang/Hỏa variant* | R1F4–8 | Mộc/Hỏa* | Fire reagent* |
| C08 | Thủy Vụ Linh* | R1F5–10 | Thủy* | Water recipe parts* |
| C09 | Kim Giáp Trùng* | R1F6–10 | Kim* | Metal weapon material* |
| C10 | Hắc Lang/Hỏa variant* | R1F7–10 | U Minh/Hỏa* | fang/fire part* |
| C11 | Trúc Thử/Thanh Lang | R1F2–6 | Mộc | wood/fur |
| C12 | Wood normal, Nham Giáp Thú rare Elite | R1F6–10 | Mộc/Thổ | armor parts* |
| C13 | Water variant*/Wood | R1F6–10 | Thủy*/Mộc | Water herb* |
| C14 | Metal variant*/Hắc Lang | R1F8–10 | Kim*/U Minh | ore/core* |
| C15 | Wolves, one Boss route/event | R1F8–10 + independently scaled Boss | Mộc/U Minh | Boss loot source* |
| C16 | Trúc Thử/Thanh Lang | R1F2–7 | Mộc | reliable resource |
| C17 | Water/Fire variants* | R1F7–10 | Thủy*/Hỏa* | mixed essences* |
| C18 | Metal variant* | R1F7–10 | Kim* | blueprint/ore* |
| C19 | Wood + Nham Giáp Thú rare Elite | R1F7–10 | Mộc/Thổ | defensive material* |
| C20 | Hắc Lang/Fire variant* | R1F8–10 | U Minh/Hỏa* | high threat rare source* |

**Asterisk** = no runtime species or confirmed resource/template/rate; requires separate authoring/registry/owner review. Existing region normal 65/30/5 applies to existing finite encounters, **not automatically** this proposed map-specific mixed pool. 20 camps remain 10–20 living slots; Boss/Elite may replace one normal slot or be a separately counted event actor, choice OPEN.

### Canonical matchup vs inferred elemental flavor
Counter cycle from Spiritual Root V2: **Kim→Mộc→Thổ→Thủy→Hỏa→Kim**. A legally learned Metal-tagged spell can counter Wood mob under canonical eligible matchup. A character simply possessing Metal root but using an untagged basic Sword hit does not automatically receive Metal counter. The Five Element monster elements are tags/affinities for skills and drops; root purity1..100 belongs to disciples, not automatically monster stat growth. New enemy shields/DoTs/resist profiles require concrete authored skills; visual color does not grant status. Dị Linh/U Minh stays distinct.

## 4. One WORLD authority for 30+400, no sealed battle per camp
**Architecture alternatives:**
- **W1 raise MapBattle MAX_MONSTERS from40 to400**: REJECT. 36×20 bounds,90s finite timeout, per-battle terminal reward and full nearest-target scans, no 20 camp/respawn/nav.
- **W2 create20 separate tiny MapBattle arenas**: REJECT as world source of truth. Actor/proj crossing a boundary, healer standing in C14 helping C13, and one Boss attacked from multiple camps need one HP ledger. Local encapsulation allowed only if W3 owns unified targets/transactions.
- **W3 recommended:** `WorldCombatDomain` **PROPOSED**, a single map-owned actor registry/HP/target/cast and central event queue with spatial buckets. Reuse Combat V2 damage, stats/status/event and CARE; do not introduce a second Combat engine. One Sect time source; stable map namespaces. Existing MapBattle remains reference kernel and other finite battles; changes only after owner CODE approval and one integration writer.

**World schema**:
- `WorldInstance`: map_instance_id, region selected difficulty, current canonical tick, terrain nav version, roster/camp associations, actor registry and spawn slots, game RNG state, pending casts/impacts/status, world HP0 kill journal, receipt ACK cursor, unique Boss generation/HP. No camera/render sprites.
- `CampDef`: area boundary, home spawn slots10–20, species/realm weights, aggro/leash/assist profile, nav anchors, eligible rare event and loot source IDs.
- `MonsterActor`: life ID, current bucket/world pos, realm/floor, tier, element, real HP, status/cooldowns, active target, threat, RNG source seed, origin camp, dying/respawn state.
- `DiscipleAgent`: reference to canonical DiscipleState and exactly ONE HUNT job, command order, path/position, AI target and learned/active skill states (1 Basic+4 Active+6 Combat Passives mature).
- `Scheduler`: authoritative ordered `spawn_due/patrol_due/aggro_due/cast_release/projectile_impact/status_tick/hp0/receipt_ack` events. Stable tie ordering e.g. tick, priority, actor_id, cast_seq, hit_index, target_generation; replay deterministic.
- `WorldBoss`: exactly one active Hắc Lang Vương life/HP, 5 squads can rally; personal contribution DPS/tank/heal/support based on effective evidence, one Sect loot pool, no last-hit only; 60/40 Stones **not locked**.

**Path/aggro:** road graph (prior 3 bridges), spatial query nearby cells, ability to cross chunk/camp without changing actor HP/loot; cached paths per new order/real obstruction; pack-size threshold and chase leash separate from bãi population. A solo player entering 20-mob camp does NOT inherently attract all 20. Camera pan/minimap click modifies visibility/navigation only, never combat result.

**Simulation scaling:** active engagements process Combat V2 at real sim due times; idle patrol may use staggered policy decisions if demonstrably equivalent to fixed authored rule. Do not invent offscreen “loot/hour” in lieu of real kills. Visual Source A render only camera-visible creatures/VFX; proc and kill cannot be dropped with visual event budget. 30+400=430 actors, naive full pairs 184,900 theoretical candidate checks per sweep (not benchmark); spatial index lowers typical nearby queries, but packed worst-case needs profiling.

## 5. Loot-per-monster contract — differentiated monster materials and Sect-owned unique equipment
**LOOT IS NOT GUARANTEED EACH KILL:** one killed monster yields exactly **one deterministic loot decision/roll set** (may contain zero or several drops by authored rules), not one guaranteed unique sword.

A future `LootProfileV3` includes:
1. **Eligibility:** source species, tier, monster realm/floor, affinity element, map+camp ID, selected world grade and authored event classification. Player technique used to kill normally does not transmute creature's element loot.
2. **Pools:** real registered common materials, species monster parts/Yêu Đan, elemental crafting material IDs, blueprint/manuscript fragments, complete equipment templates, manual/skill inheritance items, eligible consumables, authorized Spirit Stones and personal Tu Vi/mastery source. **Only registered template IDs may produce an item**; missing future ID fails closed, not phantom loot.
3. **Gear instance generation:** **Equipment V2 ten ordinary slots, twelve approved grades (Phàm→Chí Tôn), equipment realm1..30, eligible 24 set families and 6 normal+2 rare stat lines+1 independent Chân Văn capacity at grade12**, not a new weapon tier system. High monster level need not always drop high gear; eligibility derived from authored table. No Chí Tôn guaranteed at a trivial camp, no rare affix automatically producing an attack proc.
4. **Outcome ownership:** all equipment+materials Sect owned in **single canonical Warehouse/unique item registry**, not “last hitter gets their own gear bag”. Personal progression and Stone shares only from authorized contribution/receipt sources; do not secretly lock 60/40.
5. **RNG/transaction:** roll using frozen source seed/`map_instance_id:camp_id:slot_id:generation` plus table version at HP0; persist RESULT BEFORE/with ledger transaction, never reroll on replay, backpressure or camera switch. Unique physical equipment instance ID allocated atomically; deposit/ACK exactly once. If Warehouse temporarily cannot accept, preserve pending durable result or reject & retry the **same decision**, not a different random item.
6. **Legacy source isolation:** `HuntingMapV2.preview_reward()` and `LINH_TUY_GUARANTEE_WINS=4` are per victorious **finite encounter**, not per wolf kill. `EquipmentSystem.forge_loot_for_victory()` is P2 fixed legacy materials. Do not pay finite, P2 and new world V3 tables three times for one event. One declared reward-route owner per reward life ID.

**Drop examples, all PROPOSAL until real IDs/rates are approved:**
| Enemy | Current element/availability | Target loot families (no probabilities) |
|---|---|---|
| Trúc Thử | current Mộc | Linh Mộc/herb/common craft component |
| Thanh Lang | current Mộc | Tinh Lang Bì and ordinary armor craft inputs |
| Hắc Lang | current U Minh | wolf part, Yêu Đan and U Minh-family components |
| Nham Giáp Thú | current Thổ Elite, loot_ready=false | durable earth armor materials, rare defense template |
| Huyết Lang Đầu Đàn | current Hỏa Elite elsewhere, loot_ready=false | Fire core/element ingredient if deliberately authorized here |
| Thủy Vụ Linh* | proposed Thủy | water essence/reagent and optional Water technique fragment |
| Kim Giáp Trùng* | proposed Kim | metal ore/weapon schematic or armor material |
| Hắc Lang Vương | current U Minh Boss, loot_ready=false | authored Boss unique gear/manual fragment/material pool, one world kill |

**Anti-inflation:** 20 camps respawn continuously, potentially thousands of valid kills per hour. Balance `kills/hour × probabilities × quantities` against profession, crafting, equipment set and Warehouse sinks, not per-victory reward numbers. Different strength, grade and drop pools create player choice; avoid “fastest 1 HP Trúc Thử drops the best weapon.” Weak mobs may have valuable common materials but higher grade eligibility should be authored deliberately. Older P3.7 description allows personal Tu Vi from real hunting; **only pay via a verified authorized per-kill source** and include reward decay gap policy after approval (no free “kill XP” from graphics).

### Transaction example: two disciples vs one monster
\`\`\`text
Map TTL-01 / origin C09 / slot04 / spawn_generation18
D07 launches Water hit, D10 Sword hit, another DoT in same tick
→ canonical ordered effect settlement → one HP >0 to HP 0 transition
→ record kill_id TTL-01:C09:04:18; freeze real contributions
→ source loot_profile and table version => ONE immutable RNG result
→ canonical Sect Warehouse unique gear/material receipt + legal personal rewards
→ mark ACK/durable; old generation cannot be killed twice
→ mark origin slot as RESPAWN_PENDING; after authorized ticks create generation19
→ visual death/particles/minimap refresh must NEVER issue new kill/loot.
\`\`\`
A mob walking from C09 to C08 still uses origin C09 slot and loot source unless specific event authoring changes its identity before HP0. Boss uses one global world life/HP and one receipt no matter how many teams attack.

## 6. Five grade modes within a map, while monster realms remain heterogeneous
**Existing HuntingMapV2.LEVELS (PILOT per finite encounter, not per-kill):**
| Level | Name | HP | ATK | DEF | Yield-per-win | Rare-per-win | Count-per-finite-fight | Elite optional | Boss optional | Guaranteed elites |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
|1|Ngoại Vi|0.75|0.82|0.88|1.00|0.00|3|0.06|0.01|0|
|2|Thâm Nhập|1.00|1.00|1.00|1.35|0.03|4|0.14|0.03|0|
|3|Hung Địa|1.40|1.18|1.12|1.80|0.08|5|0.30|0.08|1|
|4|Hiểm Địa|1.95|1.40|1.27|2.50|0.16|6|0.65|0.16|1|
|5|Tuyệt Địa|2.70|1.65|1.45|3.50|0.26|7|0.00|1.00|2|

At L5 optional Elite roll0 **does not mean zero elite**; min_elites=2 and Boss guaranteed **in its finite 7-mob encounter**. In a 20-camp world, this MUST NOT mean twenty Bosses or guaranteed two elites PER CAMP every respawn. Old reward rare/yield are **per victorious encounter**, not legitimate per-kill rolls.
**Recommended world semantics:** one selected grade per region ID (matches `v2_pve_selected_levels[region_id]`); level HP/ATK/DEF modifiers apply **once** to each mob's own species×tier×own realm/floor profile. Camps can simultaneously contain weaker or stronger individual monsters; one difficulty never flattens all to same realm. Tier/Elite/Boss spawn schedule, resource-yield/rare-per-kill and difficulty transition are separate authoring decisions, not automatic reuse.
**Alternative per-camp grade:** owner must explicitly override existing selected-per-region contract; no such override issued here. This design keeps region mode and content gradient orthogonal.

## 7. Testable vertical slices / acceptance fixtures, NO CODE AUTHORIZED
| Fixture | Input / scenario | Required output/guard |
|---|---|---|
| M01 | same C07, two `thanh_lang` R1F2 and R1F9 | distinct real monster HP/ATK/DEF from own realm; no player-level scaling |
| M02 | Wood Trúc Thử vs Nether Hắc Lang, plus new valid Fire/Water/Metal templates only if authored | preserve actual coded affinity; genuine element skill matchup; basic attack no free fire |
| M03 | selected world L1 while camp C20 stronger from species/realm | one stat-grade modifier, real level variance |
| M04 | 20 camps×10/15/20 spawn slots | 200/300/400 live target after readiness, unique slots/generations |
| M05 | 30 disciples distributed between20 camps (10 camps2, 10 camps1) | accepted per disciple with OneActiveJob, legitimate own paths, no ghosts |
| M06 | 2 disciples and lingering DoT kill a higher-realm Elite | one kill event and ONE loot roll, contribution attribution, no double hit reward |
| M07 | Boss near C15 and 5 teams from different camps | one HP and one Sect reward pool, no last-hit-only |
| M08 | Water/Metal/Fire item source missing registry | fail closed; no phantom warehouse/gear/skill |
| M09 | save after HP0 before roll, after roll before Warehouse, before ACK, before respawn | same result/unique equipment ID, no reroll/duplicate |
| M10 | camera pan/minimap click 50 times vs unchanged seed/orders | same HP/status/kill/loot/offscreen outcomes |
| M11 | camp C08 cross creek to C09, with projectile in flight | path via legal bridges, actor life retains origin/HP/loot identity |
| M12 | 200→300→400 live monsters (600 stress), 30 disciples casting/healing | measure SIM p95/p99/total actor memory, path backlog, no fake kill |
| M13 | L5 old finite battle vs new world | no per-camp guaranteed Boss or multiplication of finite win rare |
| M14 | far below/above player monster realm and different gear tiers | survival policy uses risk but no forced equality or direct gear=monster realm |
| M15 | 1,000–3,000 roster of Sect but 30 actors in one combat map | idle disciples scheduled by cohorts, no full render/brain for every roster member |

**Benchmark metrics to acquire only after explicit code:** map sim ms/tick and p95/p99, actor spatial candidates, nav paths/sec, pending cast/DoT/procs, RNG repeatability, world save/replay, Warehouse unique item/receipt counts, visible frame time and peak memory on Windows8GB and Android landscape1280×720. No numeric FPS/PASS claim from static design.

## 8. Dependency decisions / no Codex packet yet
- **D1 content:** define per-camp independent species×tier×own realm bands and *which original or newly authored* species fill Kim/Thủy/Hỏa; source code currently lacks normal examples for all three in TTL.
- **D2 loot economy:** source-registered monster materials, equipment template/realm/grade/category distributions and Boss/Elite rates; scale 200–400 camps against kills/hour and production demand; preserve single Sect-owned Warehouse. No arbitrary exact rarity % until approval.
- **D3 combat authority:** unify world actor/spawn/scheduler and spatial index with Combat V2 without reproducing MapBattle arena/40 cap/90s terminal; kill journal transaction and same-build save parity.
- **D4 RTS:** navigate20 farms, camp aggro/leash/pack policy, free camera/minimap only UI; Android alternative to right click. Art Source A stays separate.
- **D5 tests:** world 30+200, 30+300, 30+400, stress30+600; 5 teams Boss, heterogeneous elements, equipment exact-once, performance measured.
- **D6 later CODE:** owner permission, file allowlist, one writer and PR29 QA risk gate. THIS DOCUMENT DOES NOT GRANT CODE PERMISSION.

**Conclusion:** Current game has partial per-creature data and Combat V2 kernel, but NOT a 20-camp 400-monster continuous RTS map or V2 per-monster gear loot. Adopt **one authoritative world with 20 camps and heterogeneous quái**, strong identity/provenance, evolving Skill Engine and loot catalog; user review remains required for concrete rates, source species, skill definitions, resources and performance caps. No changes to PR29/UI/code/saves and no merge.
