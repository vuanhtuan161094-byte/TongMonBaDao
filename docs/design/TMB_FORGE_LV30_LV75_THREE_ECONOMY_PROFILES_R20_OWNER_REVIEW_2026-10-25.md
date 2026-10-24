# TÔNG MÔN BÁ ĐẠO — CÂN BẰNG LUYỆN KHÍ ĐIỆN Lv30→75: BA HỒ SƠ TIẾN ĐỘ
## Nhanh / Cân bằng / Dài hạn · Kiểm toán nguồn R20 và điều kiện Lv75 bắt buộc trước mọi lệnh R21 Forge

**Ngày 2026-10-25; DOCS-ONLY; DESIGN TRIAL; NOT RATE LOCKED; NO CODE / PR29 / PR31 / MAP-D0 / UI / SOURCE A / MERGE.**
**Owner instruction:** tiếp tục Phương án A (cân bằng chi phí Lv30→75) trong khi Codex chạy MAP-D0 riêng. MAP-D0 nghiên cứu MAP TÔNG MÔN từ PR31 baseline; tài liệu này chỉ thuộc **kinh tế Luyện Khí và đường R20→R21**, tuyệt đối không kế thừa PR31 hoặc sửa nhánh/cấu trúc map. Nhánh mới docs từ main SHA `29b5fba448b0178cb520a4ada44b375b4b934e31`. PR31 lúc đọc là OPEN/DRAFT head `9eb4fd55733bb49bbb069240b8e332d37d22aced`; trạng thái PR có thể thay đổi do Codex, không được làm giả chứng cứ head stable khi họ đang chạy.
**Authority:** `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/P3_7_BUILDING_TREE_SPEC.md`, `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`, `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`, `docs/WEAPON_EQUIPMENT_V2_SPEC.md`, `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md`, actual `godot/src/simulation/building/building_system.gd`, `resource/resource_registry.gd`, `resource/warehouse_system.gd`, `economy/economy_system.gd`, `state/sect_state.gd`, `combat/hunting_map_v2.gd`, `save/save_service.gd`. Read prior branch `docs/forge-lv30-75-r20-predivine-source-cost-softlock-20261024`: STRICT contract, detailed original cost calculation and 34 test scenarios. Companion study with arithmetic and Monte Carlo: `docs/research/TMB_FORGE_LV30_75_1000_3000_ECONOMY_STRESS_SCENARIOS_QA_2026-10-25.md`.
**Source coding:** [LOCK] owner canonical; [SOURCE] verifiable in main; [PILOT] newly proposed parameters; [SIM] mathematical model only; [BLOCKER] needs actual gameplay implementation/QA. **Forge facility type not present in current BuildingSystem.DEFINITIONS, so ZERO Lv30→75 Forge upgrades are implemented or QA-PASS.**

## 1. Invariants independent of any budget profile
1. **[OWNER] ALL gear CREATED THROUGH FORGE with equipment realm R21 or above strictly requires a real ACTIVE Luyện Khí Điện at Lv75+**, including blank basic R21 weapon/armor, set, auto-craft, rank promotion or craft/rebuild pathways. No Lv30 R21 basic exception, no cost shortcut by UI, no profession level75 substitution. A genuine monster equipment drop is NOT a forging command; wearable legality for a dropped R21 item remains separate owner decision. The current request does not silently forbid loot itself.
2. Construction Lv30→75 is **ONE capital investment per legitimate building instance**, not a per-disciple fee; next Thần crafting afterwards pays NEW R21 ore/fiber/beast, learned blueprint/worker/ticks and Stone separately. Older Tiên set generation never silently changes to Thần.
3. All 45 levels 31..75 paid in sequence with authentic registered source IDs, Sect Stones, canonical Warehouse debit and durable order receipt. Lv50 and Lv75 require a genuine milestone component. [PILOT] use existing `yeu_dan` first; source is `HuntingMapV2` Lv1 Hắc Phong Cốc 2 per genuinely victorious encounter, not per individual monster. “Lô Tâm/Hỏa Chủng” old names are SPECIALTY THEMES, not active registered IDs.
4. No body-gate seals/resources, no fictional R21 mining/monster materials, no Boss-only mandatory upgrade inputs, no new economy faucet invented without independent approval. Warehouse reserve_min/locked and ONE source of truth, One Active Job, Injury0/1 120 ticks and exactly-once Save continue.
5. Existing numeric construction method is [SOURCE] for some registered building types but NOT Forge. Formula shape [SOURCE] `F(L)=1+0.15×(L−1)+0.01×(L−1)^2`; milestone cost multiplier2 at Lv50/Lv75; build-work ×1.75 at milestones. Each proposal chooses Forge-specific base coefficients and Yêu Đan counts; other milestones Lv10/20/30 outside this transition.
6. Work tick construction and worker Luyện Khí profession are **different clocks/jobs**. `profession_level=floor(sqrt(XP/24))` and `speed=1+.01×Level` affect authorized profession jobs, NOT automatically BuildingSystem construction tick; no double efficiency.

## 2. Config definitions (not pre-existing or owner-approved)
For every target level integer L from31 to75 inclusive, previous=L−1, multiplier M=2 if L∈{50,75}, otherwise1:
- `wood(L)=ceil(base_wood×F(L)×M)`;
- `ore(L)=ceil(base_ore×F(L)×M)`;
- `stones(L)=ceil(base_stone×F(L)×M)`;
- `construction_work(L)=(work_base+work_per_target×L)×(1.75 if L50/75 else1)`; per-target completion takes ceiling whole sim ticks under [PILOT] 1 work/tick.
- `yeu_dan(L)=N50` at L50, `N75` at L75, else0; a separate real milestone sink, not a magical Lô Tâm.

| Profile [ALL PILOT] | Base Wood | Base Ore | Base Sect Stones | Work Base | Work per target | Lv50 Yêu Đan | Lv75 Yêu Đan |
|---|---:|---:|---:|---:|---:|---:|---:|
| **Nhanh** |2|3|2|6|1|5|10|
| **Cân bằng** |3|4|4|8|1.5|10|20|
| **Dài hạn** |4|6|12|8|2|15|30|
| **24/10 old reference** |4|6|20|8|2|10|20|

### 2.1 Final Lv30→75 cumulative bill — 45 steps
| Profile | Linh Mộc | Thanh Thiết spent on building | Sect Stones | Yêu Đan | Exact sum work units | Per-stage rounded construction ticks | Nominal build sim-days |
|---|---:|---:|---:|---:|---:|---:|---:|
| **Nhanh** |3,595|5,384|3,595|15|2,757.75|2,758|1.9153|
| **Cân bằng** |5,384|7,169|7,169|30|4,090.125|4,102|2.8486|
| **Dài hạn** |7,169|10,746|21,473|45|5,329.5|5,330|3.7014|
| **24/10 old pilot** |7,169|10,746|35,777|30|5,329.5|5,330|3.7014|
**Note:** work units may include fractional amounts, but EACH stage completes only after its own integral tick ceiling. For Cân bằng, ceil(SUM work) is NOT correct; sum(ceil(stage_work))=4,102 ticks, NOT 4,091. Excludes funding, mining, forest work, hunting, any building repair/recruit time, input research, item Forge after Lv75, real offline speed policy and UI/physical QA.

### 2.2 Registered source audit: only these actual families are in the candidate bill
| Resource | Source known in main | Verified acquisition limit/denominator | Risk |
|---|---|---|---|
| `linh_moc` | `ResourceRegistry` / Linh Lâm `BuildingSystem` producer | requires genuine worker/sim tick/warehouse; no blanket source rate guaranteed for this new Forge | reserve/minimum, same wood needed for other buildings |
| `thanh_thiet` | Registry / Mỏ worker producer | true production deposit; NPC sale priced at8 Stones per actual unit | construction competes with ore sales funding |
| `yeu_dan` | Registry / `HuntingMapV2.hac_phong_coc.resources` |2 units per base Lv1 completed, victorious **ENCOUNTER**; not2 per kill, worker, tick, boss or camera | actual route/win/reward exactly-once must be QA-verified |
| Sect `spirit_stones` | `SectState` canonical currency / `EconomySystem.sell_to_npc_v1` | default NPC global sale quota20 units/day, max5/request, ore=8Stones, wood=2Stones; receipt-based | finance bottleneck, not “idle unlimited cash” |
**Source ID exists != source can be gathered with current user's roster != sufficient daily production.** Both Lv50/Lv75 Yêu Đan milestones are real ID but **an owner-open replacement for thematic furnace-specialty component**, not an assertion that Yêu Đan is a named Lô Tâm.

## 3. Pure funding lower bound if no existing money (DO NOT report as played time)
Assume zero Sect Stones, no wages/repairs/other spending, unlimited EXTRA legitimately earned ore sold at default NPC max20 units/day, at8 Stones/ore, unlimited genuine encounters for Yêu Đan, enough other resources to construct. Required extra ore sold =ceil(Stone bill /8); min market-calendar days =ceil(extra_ore/20).

| Profile | Extra ore SOLD (not construction input) | Total ore production minimum (spent + sold) | Market sale day LOWER BOUND | Minimal Lv1 Hắc Phong victories for Yêu Đan |
|---|---:|---:|---:|---:|
| **Nhanh** |450|5,834|23 days|8 real encounters|
| **Cân bằng** |897|8,066|45 days|15 real encounters|
| **Dài hạn** |2,685|13,431|135 days|23 real encounters|
| **Old reference** |4,473|15,219|224 days|15 real encounters|
If a player begins with R20 treasury and adequate stock, capital timeline is lower, and construction2–4days matters. If NPC/warehouse policy or true production prevents20 surplus ore/day, timeline is longer. It is false to call the 45-day lower bound a chosen “45-day upgrade duration”; it is a source-constrained financing scenario.

## 4. Target tradeoffs and recommended pilot
**Recommend the CÂN BẰNG profile for an owner's first **design-only** trial**, not as an approved/default gameplay balance. Reason: still 45 individual upgrade purchases and two milestones, roughly half old material/Stone burden, minimum45 rather than224 NPC-only days from zero Stone (under extreme ore-surplus assumption), Lv75 retains strategic meaning and early Tiên-to-Thần progression is not halted by a 35,777 Stone-only faucet. The DÀI HẠN profile best suits a very long-running Sect with multiple authentic revenue channels but is high risk under CURRENT market cap. NHANH may fit testing/onboarding and a fast prototype but can trivialize Lv75 prestige if high-level players already hold enough stock.
**Do NOT merge profile choice into content authority:** every curve needs owner approval, proper R20 source and treasury measurements, legal milestone component definition and actual Forge BuildingSystem type; even after Lv75, R21 ore/fiber/beast, blueprint and unique-item transaction remain separately DEFERRED.
**Proposed release gate after any eventual implementation:** prove allowed `can_forge(R21)` false at building Lv74 and true ONLY with Lv75 ACTIVE plus authentic R21 recipe/source/worker/warehouse preconditions. “Lv75 reached” by itself never spawns R21 gear.

## 5. Scope/branch noninterference
MAP-D0 belongs to Codex, according to owner's supplied task, and is NOT this study; its PR31 baseline, map screenshots, navigation, renderer, camera, Source A manifests are **not read/edited/replicated** here. No PR/asset/source was changed or merged. This research references ONLY economics/Forge design inherited from predecessor docs. It is okay for two research branches to exist while Codex runs because there is **no overlapping writer in gameplay files**. Any future CODE for `BuildingSystem/SaveService/WarehouseSystem` will need owner-specified writer/integration boundary before a separate packet.
## 6. Owner questions still open
1. [OWNER] Lv75 strict threshold stays; choose a PILOT cost profile: Nhanh, Cân bằng, Dài hạn or custom Wood/Ore/Stone ratio.
2. Should milestone Yêu Đan amounts be acceptable as a generic catalyst, or must thematic Lô Tâm/Hỏa Chủng have distinct ID and a genuine ≤R20 production/drop consumer? If latter, refuse until exact source proven.
3. Should progression expect large initial R20 treasury / additional genuine Stone faucets, or must zero-Stone NPC-only be feasible within a target 30/60/90 sim-days?
4. Construction uses one-tick base authority or qualified builders? Default research keeps existing registered-building timing precedent; no profession/level double counting.
5. Any approval is only of DESIGN PRINCIPLE until a later explicit CODE scope is requested, independent of ongoing MAP-D0 Codex.
