# TÔNG MÔN BÁ ĐẠO — ENDGAME 200–500 DISCIPLES LOD + PVE MULTICAMP FOUNDATION

**Owner follow-up 25/10/2026:** PR #38 successfully opened the actual P3.2 Godot 4.7.2 endgame fixture but visuals are too crowded. Owner now specifies **200–500 Sect disciple roster** as desired practical scale (NOT 1,000/3,000 mandatory); there is NO requirement to render 200–500 avatars simultaneously. Continue PvE urgently without pretending an unconnected 300-slot model is running combat.

**Base:** [PR #38](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/38) @ `7fd6848fa60791a43013b78fb2ae21fa6d388153`. Owner's Windows official-Godot evidence: 29/29 scoped, 56 S1, 4 additional checks PASS on gameplay SHA `14f0927c3161efc0b2afc1e8c411bd9d34dd4281`. **Those tests do not apply to THIS NEW branch!** All new Godot official tests/screenshots/perf remain NOT RUN until the desktop workspace executes them.

## 1. I reviewed the actual original PR38 screenshots

- `godot/outputs/endgame_qa_20261025/gameplay/00_endgame_full_map.png`: all 130 actual actors produce a large overlapping cluster at courtyard/roads, obscuring verified Source A buildings. This is a **visual** shortcoming; the real State has 130 disciples and 100 legitimate producer rows.
- `mine_021_selected.png`, `linh_forest_021_selected.png`, `spirit_field_035_selected.png`: 166x121 SVG vignette repeated per producer, with identical artistically basic silhouette, large labels and actor overlap. **The three SVGs were authored as original unapproved placeholders during PR33 by ChatGPT. They are NOT recovered Source A art.** Never promote or claim the map's final art was done.
- PR38's actual `asset_inventory_summary.json` reports **6,578 catalog rows / 6,567 unique fingerprints**, of which **263 are QA_PASS, 1,083 PARTIAL, 5,232 BLOCKED**; **262 current Godot asset folders have matching source hashes**, but crucially **ALL 6,578 rows have unmapped gameplay roles**. This explains why thousands of extracted files were NOT directly associated with a Mine, Forest, Field or actual disciple/monster body: import QA is not semantic classification. Only **32 Source A MAP25 PNGs** have verified presentation manifest; only three true approved map buildings are Main Hall 510052, Warehouse 510102, Forge 520081. Next local E: task is **classify/map the 263 QA_PASS first**, not batch-convert the 5,232 blocked rigs and not draw more generic SVG artwork.

## 2. Code committed in THIS branch — real view-domain optimization

Files:
- `godot/src/presentation/p3/sect_endgame_visual_budget_v1.gd`: pure camera LOD. **Default actor render caps**: 24 at zoom ≤0.96, 40 at zoom 0.96–1.24, 72 at zoom≥1.24. Select candidate IDs deterministically by focus, camera distance, ID and **one representative per screen-space tile** (84/68/52 px). Focus actor gets priority. This is NOT a cap on recruitment or active workers.
- `godot/src/presentation/p3_2_landscape_sect.gd`: only screen-eligible selected actor subset visible. Invisible actors skip walking effects/tween interpolation, position snaps to worksite on update, while state/work/Save continues independently. This changes no combat, production, injury, Warehouse or Save formula. Focused site uses canonical instance ID rather than just type to choose visual detail.
- `godot/src/presentation/p3/sect_isometric_world_v1.gd`: **all 100 producer rows and picking IDs stay**, but at low zoom use SMALL DISTINGUISHABLE per-type outlines instead of stamping identical large SVGs. At focus zoom draw at most **4 nearest/selected** candidate roofs, all other sites become compact icons. PV01 true Source A building art untouched. Corresponding pick radius shrinks in compact LOD.
- `godot/tests/presentation/sect_endgame_visual_budget_contract_test.gd`: unrun focused assertion for 500 visual candidates, stable caps, screen pile of 500→1 representative, 40 producers→4 large roofs, focus unchanged. Do not call this QA PASS without a Godot run.

**Caveats:** view budget does NOT pool/freeze creation of all 500 `ModularDiscipleActor` nodes; PR38 `_install_modular_live_actors` still constructs one per actual `DiscipleState`. This first pass cuts visible sprite animations/draw overlap, but **not full 500-node CPU/memory costs**. Need second gate: actor-node virtualization with at most ~64–96 reusable visible actor nodes and stable ID mapping; preserve profile/selection even when actor not instantiated, adapt `endgame_map_density_test.gd` and verify all existing UI assumptions before replacement. Memory/FPS under 500-disciple load NOT measured. Future mobile QA required.

## 3. Code committed in THIS branch — a REAL data foundation for PvE, not fake gameplay

- `godot/src/simulation/combat/pve_multi_camp_population_v1.gd`: deterministic serializable 20-camp slot registry in 256×192 world, 10–20 slots per camp (200/300/400), 30 design-road graph edges and 3 bridges with C08–C09 unbridged; stable per-slot IDs, spatial placement, life generation. `record_hp0` only accepts verified HP0 flag + matching current generation and does NOT award loot; `acknowledge_paid_receipt` remains separate and NEVER awards loot; `advance_respawns` refuses unpaid life and prevents generation rollback. Caller must supply approved per-camp respawn delay; zero game balance/loot constants invented.
- `godot/tests/simulation/pve_multi_camp_population_v1_test.gd`: unrun contract for 200/300/400 slots, deterministic JSON-serializable snapshot, stable roads, stale generation guard, no unacknowledged respawn/reward duplication.
- **Not integrated into B3 or MapBattleV2.** Real `B3HuntWorld` still has **one monster slot and one disciple**, `MapBattleV2` still caps a LOCAL encounter to **40 monsters and 30 disciples**. Spawn-slot registry is NOT live 300 enemies, not multi-camp auto-battle and not player-ready. No new Warehouse reward table was authored or paid.

## 4. NEXT REQUIRED WORK — true 20-camp PvE integration, not another design viewer

1. **PVE-A world authority:** define persistent `SectState` multi-camp world version and migration, single clock owner, 20-camp region map, slot generations & independent spawn deadlines. Index only *active nearest-camp battles* through bounded multi-arena MapBattleV2 or adapt actual authoritative world physics with focused fixtures. Do NOT blindly enlarge a single 36×20 / 40-monster battle to 256×192 and 400 monster actors.
2. **PVE-B deploy/jobs:** 30 eligible disciples, five parties×6, no worker also farming; roster/AI area order+navigation/collision on three bridges, fog/minimap camera and return/injury. Save/resume.
3. **PVE-C kill & loot:** MapBattleV2 real HP0 event -> `camp_id,slot_id,generation,life_id,verified actor` -> **canonical new receipt** in same SaveService barrier -> Warehouse.add ONCE -> ACK event -> respawn after cooldown. Old B3PilotContent `tinh_lang_bi×1` is specific to old single-slot zone; DO NOT silently copy as Thanh Trúc Lâm-wide loot or split a total encounter payout to fake per-monster economy. Missing species/source/rates -> explicit blocker.
4. **PVE-D scale:** test 20 camps×15 real actors, 30 disciples, 100/300/400 monsters, 200/500 Sect roster, 100 producer sites, long offline replay, exact-once reward, FPS p95 frame time/memory under 8GB Windows. Build visible-actor spatial culling; no 400 sprites permanently drawn.
5. **PVE-E art:** real Source A verified mob rigs, death/hit/attack clips, accurate pivots; never substitute NPC portrait rigs as official combat class bodies just because names look similar.

## 5. Required tests on desktop/Godot 4.7.2

Rebuild/import exact PR branch and run:
- `res://tests/presentation/sect_endgame_visual_budget_contract_test.gd`
- `res://tests/simulation/pve_multi_camp_population_v1_test.gd`
- `res://tests/presentation/endgame_map_density_test.gd`
- `res://tests/presentation/sect_map_d2_visual_contract_test.gd`
- `res://tests/presentation/p3_2_map_camera_test.gd`
- then original **29 focused PR38 regression**, **S1 56 checks**, endgame production/warehouse Save tests. Record log/exit/actual branch SHA; prior baseline not proof.
- Runtime snapshots from same endgame seed: at 0.75x,1.0x,1.35x,1.8x, downtown and three producer districts; selected sites and actor focus, pan zoom, touch/picking, real production while some workers hidden; compare against PR38 before. Check the redesigned compact picker (user can still select every ID), selected artifact detail and panel. Record FPS p05/avg, p95/p99 frame-time, GPU, physical/virtual RAM, Save/Load timing at 130,200,500 disciples. If full QA fails, fix within new branch, do NOT edit old tested PR38.

## 6. Owner decisions already clear

- 200–500 disciples = **canonical roster target**, not 500 live scene sprites. Keep up to 30 active hunters and assign others legitimate work/sect activities subject to One Active Job.
- Visually: near camera a few recognizable Source A animated disciples, distant workers represented by small on-site activity indicator or counts in actual selected panel; use sector/cluster summary in overview. **No artificial characters standing piled on the floor**. Placeholders in three producer types should be replaced with TRUE owner-approved Source A/Godot exports recovered locally from E; do not generate a new pile of primitive graphics and claim owner-approved art.
- Technical: no asset generator run here because this branch uses GitHub connector, which cannot inspect all local E directories or execute Godot official engine. No FPS/quality claim before Windows run.

**STATUS:** `ENDGAME_VISUAL_LOD_CODED_GODOT_PENDING`; `PVE_20_CAMP_SPAWN_SLOT_STATE_CODED_GODOT_PENDING`; `PVE_20_CAMP_COMBAT_AND_LOOT_NOT_IMPLEMENTED`; `SOURCE_A_WORKSITE_ART_MISSING`; `OWNER_VISUAL_PENDING`.
