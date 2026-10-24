# TÔNG MÔN BÁ ĐẠO — R11/R21: HỒ SƠ NGUỒN THẬT, SỐ LIỆU SENSITIVITY VÀ PHIẾU NGHIỆM THU VERTICAL SLICE
## Companion cho Vertical Slice Roadmap ngày 25/10/2026

**Trạng thái: DOCS-ONLY DESIGN EVIDENCE.** Không run Godot, không gameplay code/PR29/UI/Source A/merge, không CODEX packet. Main được đối chiếu tại `29b5fba448b0178cb520a4ada44b375b4b934e31`; PR29 trước/sau kiểm toán là OPEN/DRAFT (HEAD tại lúc đọc `9522812e91b7ca5bc0cc108eb92e000e930fe850`). Các con số dưới là [TRIAL], không được chủ dự án khóa. Tài liệu gốc: `docs/gear-r10-r11-r20-r21-first-design-acceptance-20261024`; catalog `docs/forge-r11-r30-source-blueprint-economy-anti-softlock-20261024`. Companion roadmap `docs/design/TMB_ASCENSION_R11_R21_SOURCE_TO_EQUIP_VERTICAL_SLICE_ROADMAP_2026-10-25.md`.

## 1. “Nguồn thật” = một chuỗi bằng chứng, không phải tên vật liệu
| Mắt xích | Yêu cầu minimum trước khi người dùng coi là có thật | Hiện trạng main | Mức |
|---|---|---|---|
| Vật tư R11 ore/fiber/beast | ID registered, nguyên vật liệu có nguồn, recipe consumer, source_version | mới có nhãn `eqv2_r11_*` trong DOCS | **BLOCKED** |
| Mỏ và Lâm R11 | node stable ID, vị trí có lối đi, người làm đúng nghề, production theo canonical tick, harvest generation/receipt | building Mine/Forest cơ bản có; node R11 biên chưa có | **BLOCKED** |
| Vân Giác Lộc | có species ID, element/own realm, stats Combat V2, actor life/gen, true kill receipt, kho nhập tài nguyên | `MonsterCatalogueV2` có 7 loài thấp, không có Vân Giác Lộc | **BLOCKED** |
| Vật tư R21 ore/fiber/beast | độc lập với Body Gate, không phải “chuyển hệ” tài nguyên | chưa có các `eqv2_r21_*` trong Registry | **BLOCKED** |
| Sơ Thần Thạch Nhân | ordinary mob R20-geared có cơ hội sinh tồn hợp lý trên tuyến biên | chưa có high-world mob/biome combat | **BLOCKED** |
| Luyện Khí Điện Lv30 | Facility kind thật, upgrade bill accessible ≤R10, one-job/tick/worker, output recipe | chỉ có roadmap định hướng; current BuildingSystem không có Forge V2 active | **BLOCKED** |
| Archive Sect và receipt | nghiên cứu đầu tiên có cost thật, một học đủ Sect, Save persist, không mở lại bằng click | SectState chưa có blueprint knowledge V2 | **BLOCKED** |
| Forge item V2 và Kho | 10 slot API, real template, appropriate realm/grade; unique item id, reserved materials/Stone, atomic settlement | P2 legacy 3 slot/quality; Warehouse có user reserve_min, không có per-order ledger | **BLOCKED** |
| Save/migration | backup giữ nguyên, schema versioned, không convert old talisman thành V2 pendant, no double bridge | SaveService V2 có backup staging, V2 gear schema chưa có | **BLOCKED** |
**Verdict source evidence:** Cơ sở hạ tầng P2/P3.7 có những primitive hợp lệ, nhưng chưa có hoàn chỉnh chuỗi source-to-item R11/R21. Không được chỉ đăng ký ID rồi gọi “nguồn đã hoạt động”; phải có event/world data thật, save và actual worker/actor.

## 2. Hai lời giải transition — so sánh kiểm chứng nguồn
| Transition | Starting equipment | Proposed frontier to access BEFORE new item | Registered source? | Blueprint/facility | End goal |
|---|---|---|---|---|---|
| **R10 Đại Thừa → R11 Nhân Tiên** | R10 Nhân gear + lawful work/hunt | `frontier_r11` [NOT a scene], ore Tiên Thiết `eqv2_r11_ore` + Vân Mộc `eqv2_r11_fiber` + Vân Giác Lộc `eqv2_r11_beast` | NO (all candidate) | `eqv2_bp_r11_basic_catalog` Sect research once, Lv30 BASIC | một món weapon R11 Tiên có source + receipt & đúng người mặc |
| **R20 Tiên Đế → R21 Thần Nhân** | R20 Tiên gear + lawful work/hunt | `frontier_r21` [NOT a scene], Sơ Thần Khoáng `eqv2_r21_ore` + Sơ Thần Linh Bì `eqv2_r21_fiber` + Sơ Thần Thạch Nhân `eqv2_r21_beast` | NO (all candidate) | `eqv2_bp_r21_basic_catalog` learned once, **Lv30 basic exception**, Lv75 premium ONLY | một weapon R21 Thần có nguồn + receipt, set Tiên không trộn Thần |
**Enforcement:** New rank item cannot be crafted by consuming existing `an_tien_gioi`, `an_than_gioi` or `than_mach_tinh` without dual-system explicit owner approval; these are Body Gate tagged in ResourceRegistry. No vendor source for eqv2 materials exists in `EconomySystem.V2_MARKET_CATALOG`. Thanh Trúc Lâm currently one design world20 camps/30 deployed, not a ready R11 or R21 map. Future world source need not be one new map per realm; can be well-defined realm profiles on an authored map if actual nav/respawn/loot exist.

## 3. Trial material vector + the absolute lower bounds it implies
**Inputs remain [TRIAL] from prior docs, not gameplay balance:** 10 basic V2 item slots consume **15ore_R +21fiber_R +4beast_R per kit**; one-time Sect archive research consumes 1ore_R+1beast_R. R11 kit expense `20×11=220` Sect Stones, 12 base ticks/item; R21 kit `20×21=420` Sect Stones,32 base ticks/item (formula `t(R)=12+2×(R−11)`). Valid craft presupposes registered tier resources and a legal worker/facility; clock throughput is NOT material-source availability or wall-clock ETA.
| Eligible number needing 10 FRESH items | Ore incl archive once | Fiber | Beast incl archive once | R11 Stones | R21 Stones | One serial lane R11 / R21 sim days, **excluding gather/research** |
|---:|---:|---:|---:|---:|---:|---|
| 1 |16|21|5|220|420|0.0833 /0.2222|
| 30 |451|630|121|6,600|12,600|2.5 /6.667|
| 100 |1,501|2,100|401|22,000|42,000|8.333 /22.222|
| 300 |4,501|6,300|1,201|66,000|126,000|25 /66.667|
| 1,000 |15,001|21,000|4,001|220,000|420,000|83.333 /222.222|
| 3,000 |45,001|63,000|12,001|660,000|1,260,000|250 /666.667|
**Caveat:** one research unlock only once per Sect even if upgrading 3,000; one worker/lane, 1440sim ticks/day and uninterrupted work assumption, no injury/pathing/facility upgrade costs. A 30-person hunting team is not 3,000 actors on one map. Many noncombat disciples may keep earlier-tier items; priority/care policy reduces first-wave demand. Worker level affects time as `1+0.01×profession_level`, never output count.

## 4. Design stress tests for sourcing and softlock
**Common beast material is DISTINCT from rare gear.** Trial Bernoulli q=1,.5,.25 for **one registered common material per genuine kill** only. Expected eligible kills to gain 121 materials (30 kits+research) =121/242/484. Historical 10,000-run xorshift32 `seed=20261024` negative-binomial samples in parent acceptance doc show at q=.25 a P99 of576 genuine kills for121 units; THESE ARE NOT ACTUAL monster kills/time. A probabilistic material with no bounded compensation can stall starting research; candidate protections need owner approval:
- **Option COMMON-Q1:** each genuine eligible normal mob life yields **one common beast material** (only if a legal future source receipt exists), rare gear HIẾM remains a separate independent conditional event. A recommended *prototype* for a non-gacha entry path; unlike Boss, this is an ordinary commodity, not a guaranteed rare relic.
- **Option COMMON-PITY:** probabilistic q with per-sect typed receipt-backed counter, mandatory guaranteed source unit after N eligible deaths. Counter identity must be persisted and exactly-once; N cannot be invented until owner approval. No grant on animation, UI, frame, Save resume or one Boss shared by 30 participants.
- **If neither source exists:** report **BLOCKED**, not “grind a little longer” as proof. Ore/fiber also must have repeatable node cycles and bounded work times not subject to impossible harvest protection.
**Finite team failure:** when the only hunter is injured, Injury1+120 real canonical recovery ticks must preserve job/source receipts; if no surviving worker can access frontier, allow normal legitimate recovery/reassign/recruit path, but do not mint materials or promise an unstated free respawn. Combat source balance requires real R10/R20 Build vs frontier mob HP/ATK/DEF fixtures under locked Combat V2.

## 5. Pre-release hazards: migration and simultaneous ongoing work
**Persist as additive data (PROPOSED, no version bump executed):** `sect.eqv2_archive_learned_recipe_ids`, `sect.eqv2_source_receipts`, `sect.eqv2_resource_order_reservations`, `sect.eqv2_forge_order_journal`, `sect.eqv2_gear_unique_items`, `disciple.eqv2_assigned_unique_item_ids`, and reference to one Forge building real work lane only when such a runtime kind exists. Use existing canonical `sect.warehouse_resources` and `sect.spirit_stones`; leave legacy `equipment_items/forge_materials/equipment_forge_index` and prior migration bridge untouched pending separate approved adapter. No second storage authority or wallet. Current `SaveService.CURRENT_VERSION=2` is fact; **no future save version has been chosen or deployed**.
**Save rollback scenarios:** (1) old save with no V2 fields → empty new fields and no automatic new recipe, preserved legacy item; (2) progress at source node or creature death cutpoint → same receipt once; (3) learned archive then crash → learned once, payment once; (4) Forge RESERVED→RUNNING→RESULT_FROZEN cutpoints → same RNG/item ID and legal one worker; (5) material/Stone debit but before unique insert → atomic rollback/replay, not permanent asset loss; (6) after item created before ACK → same one output, no duplicates; (7) equip/old set swap cutpoint → one assignee, no mixed-generation bonuses; (8) future save opened by OLD client → reject via compatible version/error/backup, never discard unknown R21 item silently.
**PR29 constraint:** Parallel draft PR29 owns a different code stream; no code branch overlap or merge, even if schemas in docs suggest future edits. At coding time require new baseline SHA, one assigned integration owner for SectState/Save/Warehouse/Building and actual Code packet/rollback. Source A future monster visuals are not validated; no fake placeholder visual as acceptance.

## 6. Miniature QA fixture matrix — design gates, NOT executed tests
| ID | Gate | Setup → expected behavior |
|---|---|---|
| Q01 | S1 | R10 party can move onto one source R11 node without wearing itemR11; if not, SOURCE FAIL |
| Q02 | S1 | R20 party can reach R21 frontier without R21 gear or Lv75; if not, SOURCE FAIL |
| Q03 | S2 | Node harvest reclick/save yields one material per node generation and real job |
| Q04 | S2 | One monster normal life/death among many squad attackers gives one Sect source receipt, not per attacker |
| Q05 | S2 | Beast material absent or only from Elite/Boss → baseline progression FAIL |
| Q06 | S3 | First rank archive research reserves/consumes real1ore+1beast and persists one unlock |
| Q07 | S3 | Reload/retry archive job cannot consume twice or generate second blueprint |
| Q08 | S4 | Forge requested before worker/facility Lv30 really exists → reject pre-debit |
| Q09 | S4 | Forge two orders with last ore unit, Warehouse reserve_min respected → only one accepted |
| Q10 | S4 | Two source registered IDs from wrong realm consumed for selected R21 recipe → reject |
| Q11 | S4 | Save at RESULT_FROZEN and reload 100 times → same grade/affixes/item unique ID |
| Q12 | S4 | Power cut after resource/Stone debit → unique item and receipt eventually consistent (atomic or replay) |
| Q13 | S5 | P2 talisman cannot be recast silently as V2 pendant; legacy count unchanged |
| Q14 | S5 | R10 wearer not equipment-realm eligible for R11 → reject equip but item stays in Sect |
| Q15 | S7 | R21 basic legal at Lv30 ONLY with actual Thần IDs/bp; Lv75 not mandatory |
| Q16 | S7 | Body-Gate `than_mach_tinh`/`an_than_gioi` incorrectly used as Forge mats → reject |
| Q17 | S8 | Mixing R20 Tiên+R21 Thần in 4-piece set → no false 4-set bonus |
| Q18 | S8 | Donor transferred/destroyed twice via inheritance retry → one debit and target version once |
| Q19 | Any | Active hunter selected simultaneously as Forge worker → One Active Job prevents two tasks |
| Q20 | Any | Injury1, save,120-tick recovery, source/Forge resume → no duplicate item/XP |
| Q21 | Any | A future save read by older client → safe reject/backup; no silent material loss |
| Q22 | Any | q=.25 simulated kills falsely called Godot farm rate → reject PASS; actual kill data missing |
| Q23 | Any | Invalid ResourceRegistry IDs in a recipe/source → no Warehouse insertion/craft |
| Q24 | Any | One boss HP/loot pool hit by 30 actors → no repeated reward even if spawned once |
| Q25 | Any | 3,000 Sect roster presumed on one hunt map → invalid; distinguish global roster from30 deployment |

## 7. Honest gate review and owner action
| Item | Docs authority established | Runtime state | Owner action |
|---|---|---|---|
| Frontier source old gear | M/F/N principle R10→R11, R20→R21 | **BLOCKED** map nodes/monster | Approve content and actual old-gear access fixture |
| Normal common material reliability | q sensitivity and one material once per true life | **PROPOSED** | choose guaranteed common drop or bounded counter |
| Blueprint archive | learned-once Sect research after registered 1ore+1beast trial | **BLOCKED** archive/job | approve exact research cost/time and retention |
| Forge Lv30 basic | R11 & R21 valid ONLY with actual source+bps | **BLOCKED** Forge V2 building system | approve concept, not code or auto unlock |
| Equip and generation | ten slots, correct realm/sets and item ownership | **BLOCKED** 10-slot runtime | staged old/new generation replacement |
| Migration / crash resilience | additive schema and source/order receipts | **BLOCKED** implementation/tests | authorize later only with separate packet and no PR29 overlap |
| 1k–3k economy | formula outputs; rates UNKNOWN | **TRIAL ONLY** | prioritize30 hunter and selected next wave |

**Final claim restricted to:** a reviewed source-first progression design can be decomposed into small independently provable vertical slices; no R11/R21 real source/Forge item is yet produced by the game, no QA passed. Next authorization decision remains entirely with OWNER.
