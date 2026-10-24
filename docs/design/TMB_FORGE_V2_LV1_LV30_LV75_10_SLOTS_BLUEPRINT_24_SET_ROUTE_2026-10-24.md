# TÔNG MÔN BÁ ĐẠO — LUYỆN KHÍ V2: LV1 / LV30 / LV75 — 10 Ô, 24 ĐỒ BỘ, BẢN VẼ
## Gói content/blueprint/công thức và milestone; giữ đúng 96 item names của 24 sets canonical
**Ngày:** 2026-10-24 · **SOURCE-GROUNDED PROPOSAL ONLY, NO CODE/PR29/UI/SOURCE A/MERGE/CODEX PACKET.**
**Pair:** `docs/design/TMB_FORGE_V2_ONE_ORDER_AUTHORITATIVE_TRANSACTION_2026-10-24.md`. Exact 96-piece per-source matrix stays at `docs/design/TMB_EQUIPMENT_V2_24_SETS_96_PIECES_TTL_SOURCE_MATRIX_2026-10-24.md` on docs branch `docs/gear-v2-basic-rare-24sets-camp-sources-20261024`. This packet adds NO new set names, does not claim any of 96 templates/blueprints registered.
**Owner:** profile `HIẾM` is chosen for **TRIAL** from `docs/ttl-v3-rare-loot-three-profiles-gear-scaling-20261024`, NOT a new 6th region difficulty or canonical drop rate; 20 Thanh Trúc Lâm camps each10–20 monsters, max30 deployed; total Sect1k–3k workers, not on same map. Existing 7 NEW monster species/9 candidate materials, 2 special Elite/Boss materials without real consumer remain DEFERRED. Previous ten specialist recipe input totals preserved exactly.
**Input source:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`, `docs/{WEAPON_EQUIPMENT_V2_SPEC,EQUIPMENT_SETS_V2_SPEC,EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP,P3_7_BUILDING_TREE_SPEC,P3_7_PROFESSION_WORK_MODIFIER_SPEC,P3_7_TIME_SPEED_COOLDOWN_SPEC,P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC}.md`, `godot/src/simulation/equipment/equipment_system.gd` and actual `ResourceRegistry` / `WarehouseSystem`.
Labels: [LOCKED DESIGN] V2 structures and building milestone direction; [SOURCE] actually registered P2 resources/recipes; [P] authoring content, counts, gate or numbers; [DEFERRED] missing IDs, profession/blueprint event, real consumer or higher realm. NO runtime ForgeV2 implemented.

## 1. Correct level ladder (don't turn all milestones into numeric buffs)
| Luyện Khí Điện | Canonical direction [LOCKED DESIGN] | Proposed deliverable THIS research |
|---|---|---|
| **Lv1** | Basic forge and repair foundation | forge 10 neutral non-set item slots with real `thanh_thiet` and `linh_moc`; predictable item realm1/grade1, no blueprint |
| Lv10 | auto-repair capability | only actual upkeep repair if equipment durability later exists; NO invented deterioration stat or stamina |
| Lv20 | material refinement | recipe prerequisites/smaller batch if approved; NO hidden monster material generation |
| **Lv30** | legal monster-material forge | ten approved-direction specialty recipes; 12 S0/S1 set family candidates contain mostly named F30 piece routes; named blueprints and registered materials required |
| Lv50 | deeper refashion/trait work | no free “max phẩm” or smart reroll without existing actual affix consumer |
| **Lv75** | advanced named set/special likelihood | 6 advanced S1 family routes, only if current source and skill consumer exist; Lv75 NOT a blanket ban on all earlier named sets |
| Lv100 | rare-line/mastery limit | only within actual Forge quality/rare-line caps and authorized recipe, no 100% Chí Tôn |
Milestone direction is from canonical Forge roadmap. This doc's actual opening level gates and recipe numbers are [P], not runtime.

## 2. Lv1 — TEN BASIC templates with registered inputs (all [P] templates)
**Guaranteed deterministic floor candidate**: one genuinely produced item of chosen slot per legal completed forge order, item realm1, Nhân grade1 (Phàm), zero sub-lines/rare lines/Chân Văn and **no set_lineage_id**. User may choose real weapon form `kiem`, `quyen_sao` or `phap_truong`, all occupy `weapon` and require authored skill weapon compatibility. Zero material grant from UI. Profession/time/slots still authorize each order.
| # | Actual ordinary slot | Candidate `gear_v2:basic_*` output, working name | Legit `ResourceRegistry` inputs | DRAFT work duration |
|---:|---|---|---|---:|
|1|`weapon`|Thanh Thiết Kiếm / Quyền Sáo / Linh Mộc Pháp Trượng (weapon variants)|`thanh_thiet×3+linh_moc×2`|12 ticks|
|2|`head`|Thanh Thiết Khôi|`thanh_thiet×1+linh_moc×2`|12 ticks|
|3|`armor`|Thanh Thiết Giáp|`thanh_thiet×3+linh_moc×2`|12 ticks|
|4|`cloak`|Thanh Mộc Phi Phong|`thanh_thiet×1+linh_moc×3`|12 ticks|
|5|`bracers`|Thanh Thiết Uyển|`thanh_thiet×2+linh_moc×1`|12 ticks|
|6|`gloves`|Linh Mộc Thủ Sáo|`thanh_thiet×1+linh_moc×2`|12 ticks|
|7|`belt`|Mộc Tâm Đái|`thanh_thiet×1+linh_moc×3`|12 ticks|
|8|`boots`|Lâm Hành Ngoa|`thanh_thiet×1+linh_moc×3`|12 ticks|
|9|`pendant`|Tụ Linh Mộc Ngọc|`thanh_thiet×1+linh_moc×2`|12 ticks|
|10|`ring`|Thanh Thiết Giới|`thanh_thiet×1+linh_moc×1`|12 ticks|
**Checksum:** 10 outputs = `thanh_thiet×15 + linh_moc×21`. For30 fully equipped =450 ore+630 wood/300 forge orders;1k=15,000 ore+21,000 wood/10,000 orders;3k=45,000 ore+63,000 wood/30,000 orders. These are **if every person needs a complete new kit**, an upper acquisition scope (reuse reduces fresh counts); not a building/worker throughput PASS. Weapon variant's exact names+stats are not an implemented template. Propose first play target weapon+armor+boots (real jobs) before all ten slots if limited stocks, but do not require a made-up free kit or extra random loot.

## 3. Lv30 — TEN SPECIALIST recipes, unchanged from previous proposal
All output `gear_v2:*` IDs are proposed, NOT current registry. Named recipe picks one slot/element/main build and prototype input quantities; boss loot and profession aren't automatic input additions. Material IDs starting `ttl_` are **NEW** (must register source, icon, consumer). `linh_moc`, `thanh_thiet`, `thanh_linh_thao`, `tinh_lang_bi`, `yeu_dan` already registered resources, but all *monster-per-kill sourcing* remains only proposed.
| # | Output `gear_v2` template family / slot | Exact existing DRAFT ingredient amounts (preserved) | Build focus |
|---:|---|---|---|
|1|`ttl_truc_moc_kiem` / `weapon`|`linh_moc×3 + thanh_thiet×2`|Kiếm / simple wood|
|2|`ttl_thuy_vu_quan` / `head`|`ttl_thuy_vu_tinh×2 + thanh_linh_thao×1`|Pháp Thủy|
|3|`ttl_kim_giap_y` / `armor`|`ttl_kim_giap_xac×3 + thanh_thiet×2`|Thể/Kim|
|4|`ttl_xich_viem_phong_y` / `cloak`|`ttl_xich_viem_xac×1 + ttl_hoa_lang_nanh×1 + linh_moc×2`|Pháp Hỏa; corrected sparse source|
|5|`ttl_thuy_tinh_uyen` / `bracers`|`ttl_thuy_tinh_giap×1 + ttl_thuy_vu_tinh×2 + tinh_lang_bi×1`|Pháp/Thủy; corrected sparse source|
|6|`ttl_thiet_tiem_thu_sao` / `gloves`|`ttl_thiet_tiem×3 + thanh_thiet×1`|Kiếm/võ|
|7|`ttl_thach_bi_dai` / `belt`|`ttl_thach_bi_giap×3 + linh_moc×1`|Thể/Thổ|
|8|`ttl_lang_hanh_ngoa` / `boots`|`tinh_lang_bi×3 + linh_moc×1`|Hunting mobility|
|9|`ttl_ngu_hanh_ngoc` / `pendant`|`ttl_thuy_vu_tinh×1 + ttl_hoa_lang_nanh×1 + ttl_kim_giap_xac×1 + ttl_thach_bi_giap×1 + linh_moc×1`|Ngũ Hành|
|10|`ttl_u_minh_gioi` / `ring`|`yeu_dan×2 + ttl_hoa_lang_nanh×1`|U Minh component/heterogeneous materials|
**[P] Prototype durations only:** recipe1 `10 ticks`; recipes2–8 &10 `24 ticks`; recipe9 `36 ticks`; actual profession factor must reduce proper canonical work duration and not double normal output. Previous parent shows the same categories; no recipe new identity or material balancing override. Recalculate ingredient example 10-specialist kit per person: `linh_moc×8,thanh_thiet×5,thanh_linh_thao×1,tinh_lang_bi×4,yeu_dan×2` + `ttl_thuy_vu_tinh×5,ttl_thuy_tinh_giap×1,ttl_kim_giap_xac×4,ttl_thiet_tiem×3,ttl_hoa_lang_nanh×3,ttl_xich_viem_xac×1,ttl_thach_bi_giap×4`; two Elite/Boss special cores have NO consumer and drop OFF.
**Named 24-set BLUEPRINT recipe is separate from ten plain special recipes**, not a stealth 11th free source or bonus named set tag on ordinary specialist output.

## 4. Blueprint lifecycle and trusted acquisition
- [P] `blueprint_v2:set:<lineage_id>:<slot>` points to EXACT one of96 canonical pieces and `equipment_realm, generation`; **new item namespace**, no current `ResourceRegistry` row and no `EquipmentSystem.RECIPES` consumer. A blueprint's known source is a **specific** camp/spawn species, Elite/Boss, quest/research or legal Forge study. The **96 candidate camp-gates are in existing 96-piece source matrix**; they were **not validated as working source tables**.
- [P] One first discovery can permanently archive a **Sect blueprint license** (similar idea to Sect techniques but NOT inheriting the actual Technique V2 mechanic by accident). Later per-piece Forge uses this license and registered inputs; this is the **preferred nonconsuming blueprint proposal** for 1–3k roster. Alternative consumable `one physical blueprint for every item` would add a huge stochastic bottleneck and requires owner explicit approval; DO NOT claim the first-copy blueprint archive already exists.
- [P] Discovery pipeline: legit monster death/reward or explicit research source → distinct `blueprint_receipt_id` → validate registered blueprint and source → mark Sect recipe-license once → duplicate page feeds separately approved research/convert sink; never creates an equipment instance immediately. If source doesn't exist, flag `BLOCKED_SOURCE` not a 0.0001% chance.
- [P] Forge gate: actual recipe `forge_v2:set:<lineage_id>:<slot>`, blueprint license, facility Lv30 for low-rank named set or Lv75 only where authored advanced, worker profession, real registered material inputs, item tier/generation/grade pool and receipt/unique instance.
- [P] Time and cost example for **ONE low-rank named piece** only: real `thanh_thiet×1 + linh_moc×1` + **two units of its specifically registered monster material**; no universal all-elements token; `base_duration=36 ticks` pilot, not 96 approved recipes. If monster resource new/unregistered, this recipe cannot be used. Elite/Boss item/blueprint components must have valid unique event source; Boss pool one per whole world, no per-party duplicates.
- **Do not double the HIẾM gear event:** if a creature can drop a named SET piece directly, it is selected INSIDE one legitimate gear event (normal species `0.0375–0.1%`, Nham Elite `1%`, Hắc Lang Boss `8.75%` per actual life) with additional conditional template weights later; blueprint pages are an entirely separate reward category requiring their own **explicit approved probability** and a reasoned source/sink; OFF before authorization, not free extra stuff.
- [LOCKED] Exactly6 valid set slots `head,armor,cloak,bracers,belt,boots`, four per family. Weapon/gloves/pendant/ring never count as those4. Set thresholds2/3/4 only modify existing legal stat channels. Mixed equipment quality allowed; realm-tier within same generation allowed with weakest-tier scaling, mixed Nhân/Tiên/Thần doesn't combine. `Hỗn Độn` reserved for Thần realm21–30, not a TTL Lv30 forge. A `Lv75 Forge` is building level, NOT realm tier75 or Thần eligibility.
- [OWNER OPEN] Who grants access to a blueprint: one-time Sect archive, per-craft consumption, locked profession technique prerequisite, recipe discovery event, or hard item source drops; blueprint isn't automatically generated by holding a piece.

## 5. Exact 24 set families: compress 96 canonical piece routes without changing them
The companion 96-piece source matrix lists all 4 **actual canonical** names/slots and individual camp/source route. Below summaries are in **canonical set order** and EACH text cell covers the ordered four pieces in that matrix. ``S0` / `S1` / `S2` are editorial readiness tags, **not equip grades and not the game's five hunting difficulty levels**. `F30/F75` are candidate forge milestones, `Elite/Boss` candidate drop source, `DEFERRED` no verified source.

| Canonical lineage (4 positions) | Readiness | Individual routes in canonical piece order: 1 → 2 → 3 → 4 |
|---|---|---|
| Sát Tinh | S1 | C09 / F75 ; C18 / F75 ; C14 / F75 ; C18 / F75 |
| Phá Cương | S0 | C09 / F30 ; C12 / F30 ; C19 / ELITE ; C18 / F30 |
| Huyết Chiến | S1 | C07 / F75 ; C10 / F75 ; C10 / F75 ; C20 / F75 |
| Truy Phong | S0 | C02 / F30 ; C05 / F30 ; C11 / F30 ; C16 / F30 |
| Thiên Kích | S0 | C09 / F30 ; C18 / F30 ; C14 / F30 ; C05 / F30 |
| Trấn Yêu | S1 | C12 / F75 ; C19 / ELITE ; C15 / BOSS ; C19 / F75 |
| Hộ Sơn | S0 | C12 / F30 ; C19 / F30 ; C12 / ELITE ; C19 / F30 |
| Tịnh Thần | S1 | C08 / F75 ; C13 / F75 ; C15 / F75 ; C03 / F75 |
| Thiên Trận | S1 | C08 / F75 ; C13 / F75 ; C08 / F75 ; C13 / F75 |
| Phản Kiếm | S0 | C09 / F30 ; C18 / F30 ; C14 / F30 ; C18 / F30 |
| Huyết Liệp | S0 | C02 / F30 ; C05 / F30 ; C05 / F30 ; C20 / F30 |
| Thanh Linh | S0 | C01 / F30 ; C03 / F30 ; C06 / F30 ; C08 / F30 |
| Ngũ Hành | S0 | C09 / F30 ; C07 / F30 ; C08 / F30 ; C19 / F30 |
| Hàn Vân | S1 | C08 / F75 ; C13 / F75 ; C08 / F75 ; C17 / F75 |
| Cửu Lôi | S2 | DEFERRED ; DEFERRED ; DEFERRED ; DEFERRED |
| Thực Cốt | S2 | DEFERRED ; DEFERRED ; DEFERRED ; DEFERRED |
| Huyền Ấn | S2 | DEFERRED ; DEFERRED ; DEFERRED ; DEFERRED |
| Hỗn Độn | S2 | DEFERRED ; DEFERRED ; DEFERRED ; DEFERRED |
| Thiên Công | S0 | C09 / F30 ; C14 / F30 ; C18 / F30 ; C09 / F30 |
| Đan Tâm | S0 | C01 / F30 ; C03 / F30 ; C06 / F30 ; C07 / F30 |
| Mộc Linh | S0 | C01 / F30 ; C06 / F30 ; C11 / F30 ; C16 / F30 |
| Địa Mạch | S0 | C09 / F30 ; C18 / F30 ; C14 / F30 ; C18 / F30 |
| Phù Văn | S2 | DEFERRED ; DEFERRED ; DEFERRED ; DEFERRED |
| Thiên Cơ | S2 | DEFERRED ; DEFERRED ; DEFERRED ; DEFERRED |

**Availability reality:** with early authored monster materials, there are 12 [S0] candidates, six [S1] advanced/conditional and six [S2] absent-source families. This is an **editorial trial**, not guaranteed 48 immediately obtainable set pieces. In particular **some S0 rows (Phá Cương, Hộ Sơn) still require an Elite piece**; four-of-four isn't craftable solely at Lv30 in these proposals unless owner approves an alternate blueprint source. If higher-rank ranks/skill consumer absent, status must remain BLOCKED.
**S2** contains `Cửu Lôi` (lightning valid skill/source pending), `Thực Cốt` (real DoT source/consumer pending), `Huyền Ấn` (real seal/debuff source pending), `Hỗn Độn` (Thần only), `Phù Văn` (Phù real work consumer pending), `Thiên Cơ` (formation work consumer pending). No forced TTL drop just to fill the matrix. [S1] Lv75 bonuses also fail closed if linked combat skill doesn't exist.

## 6. Sample profession + facility authoring, without role lock
- [LOCKED] Profession throughput factor `1+0.01×profession_level`, real `work_speed` only accelerates effective work; the same factor does not multiply pieces/order or add passive loot rarity. [P] duration snapshot `ceil(base_ticks / actual_authorized_work_speed)` with job owner and due tick. Lv0 basic 12 ticks; Lv100 profession with speed×2 would be six ticks IF facility and modifiers legal; exact floor/speed compose consumer source still needs validation.
- [LOCKED] Kiếm/Thể/Pháp is a build pathway, not fixed armor class. Sword skill's real `weapon_requirement=sword` is enforced; `style_tag` by itself is not a restriction. Hộ Kiếm may prefer Hộ Sơn/Phản Kiếm; Thể Bá Thể may prefer Huyết Chiến/Huyết Liệp; Y Đạo Thanh Linh/Thiên Trận when real heal/shield skill exists. Hybrid can wear allowed armor with valid stats, different class profession gear consumes C-work channel only on real jobs.
- [P] Multi-worker Luyện Khí Điện may have authorized workforce slots, but **worker slot count does not prove N independent oven/production lanes**. Until code supports a real processing-queue model, model one work order per permitted lane, chosen worker's One Active Job. Do not infer instantaneous 12×output by adding building Lv100 workers. Parallel lane count and auto-priority/auto-equip policy require owner approval.
- [LOCKED] No arbitrary crafting resource cap in warehouse; stack materials registered and integer safe with `reserve_min`/locks; unique items each have stable Sect identity. One user-made queue cannot starve cultivation/medicines by bypassing reserve_min. When the forge output isn't received, retry same receipt rather than add duplicates or lose item.
- [PROPOSED] At scale provide demand queue: first fill missing `weapon/armor/boots` to deployed 30, then ten-slot basic, then chosen high-value set items for Boss team, then professions. Do not assume 3,000 equipped actors in one Thanh Trúc Lâm or manually click30,000 crafts.

## 7. Blocking information before any implementation
1. New `gear_v2:*`, `forge_v2:*`, `blueprint_v2:*` registries/consumer and every 24×4 V2 set template identity do not exist in current code; do not create temporary “item ID” by item display names.
2. Seven new TTL monster species and materials NEW, two Elite/Boss cores DEFERRED, manual/blueprint source tables not established, Source A sprites not proven. Source provenance required for every input.
3. Exact allowed work lane count/worker assignment, facility operational state, user item grade/pool, skill/affix consumers, blueprint acquisition and output/salvage cannot be called PASS from document tables.
4. Pending resolution: owner chooses persistent Sect blueprint-license vs consumed blueprint; source-specific per-piece chances and eligibility by realm generation; actual multi-map high-tier content for Tiên/Thần.
5. Official future Godot 4.7.2 focused + Windows/Android real measurement still required after CODE authorization. This document alone grants none.

**Companion QA/numbers:** `docs/research/TMB_FORGE_V2_PROPOSED_GRADES_FAIL_KEEP_SALVAGE_INHERIT_BALANCE_2026-10-24.md`.
