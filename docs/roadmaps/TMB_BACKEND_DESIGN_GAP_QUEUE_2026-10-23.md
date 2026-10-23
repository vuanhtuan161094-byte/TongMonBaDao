# TÔNG MÔN BÁ ĐẠO — BACKEND DESIGN GAP QUEUE (AFTER CARE PLAYABLE)

> **X0 CROSS-SYSTEM CONTENT INTEGRITY GATE — OWNER CORRECTION 2026-10-23:** Before any P2/P6/P8/P10 content or equipment V2 implementation, read [Cross-System Realm Content Contract](../design/TMB_CROSS_SYSTEM_REALM_CONTENT_INTEGRITY_CONTRACT_2026-10-23.md) and [15-Finding Design Audit](../audits/TMB_CROSS_SYSTEM_ROOT_CAUSE_CORRECTION_REGISTER_2026-10-23.md). A named early item MUST NOT be cloned over 30 realms using `G(r,1)`; each realm needs authored gear group/source/consumer; distinct pills, manuals and skill generations obey their own canonical laws. All owner-approved S2+F1+Q1 remain, no invented 30-map implementation or arbitrary probability lock. This cross-system gate is DESIGN governance, not a runtime PASS or CODE permission.

**Date:** 2026-10-23 · **Class:** DOCS-ONLY / READ-ONLY source audit / candidate design tickets, **NOT CODE AUTHORIZATION**, not a gameplay balance lock, not merge.  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao`. Audited `main=29b5fba448b0178cb520a4ada44b375b4b934e31` for P2 equipment/related gameplay; PR #24 `4d08984f0` CARE and PR #25 `710137c0e` P3.2 integration are **draft, stacked, unmerged**, and must be reviewed on current heads before later implementation.  
**Parent plan:** [TMB_MASTER_ROADMAP_PLAYABLE_TO_V1_2026-10-23.md](TMB_MASTER_ROADMAP_PLAYABLE_TO_V1_2026-10-23.md).  
**Reason:** Codex can finish Windows/UX/Source A while this thread prepares **content + economy + character-growth designs** without competing CODE writers.

## A. Executive ranking

**Do not run BD-01 detailed gear arithmetic in isolation.** Its first dependency is now X0: a real realm-specific gear group and source/consumer contract, with 30 authoring coverage rows and R01–R03 pilot mapping. Earlier `+3*G(r,1)` copied-item design is RETIRED, never a code packet.
: critical backend/design work not already implemented V2

| Rank | Ticket | System | Already locked by owner/source | Actual gap to close (do NOT assume design=runtime) | Dependency |
|---|---|---|---|---|---|
| **1** | **BD-01 GEAR-FORGE-TRANSACTION** | Trang bị/Luyện Khí | 10 ordinary slots, 3 Phù +2 Pháp Bảo separate, 4 consumable belt slots; 12 grades and capacities; 30 equipment realm tiers; all gear Sect-owned; 24 set lineages with 2/3/4 stacking | Detailed **one** forge order: blueprint+materials+profession/building/job timing+rollback/RNG+item grade/affix+unique-ID+Sect Warehouse. Item migration from P2 three-slot schema and old `owner_id`. Grade roll/chance/failure/cost **OPEN**, not present as full V2 system | current Source and backend boundaries, no new code |
| **2** | **BD-02 LOOT-MATERIAL-CATALOG** | Quái→Kho→craft | one legitimate monster HP0→one Sect material loot receipt; real immutable kill root; optionally rare Tinh Nguyên as **non-EXP** material | Source registry for monster/Elite/Boss→tier/rate/unique materials/blueprints/set pieces; earning/cost budget and non-Boss baseline; 30-tier authored IDs are not implemented. Pilot B3 world currently one wolf/one drop generation (no broad economy) | BD-01 item outcome taxonomy |
| **3** | **BD-03 GEAR-STAT-MATH** | Combat V2 build/balance | Realm/Body ATK/DEF/HP authority, equipment stat channels and no false universal stats; 12-grade capacities; equipment realm tier 1..30 | exact base gear values per representative tier/grade, affix pool percentages + filters, stat stacking and damage/HP changes, PvE time-to-kill and Boss tuning; no guaranteed max roll | BD-01 + Combat V2 source |
| **4** | **BD-04 UPGRADE-PROGRESSION** | Cường hóa/Tinh luyện/Thăng phẩm | **Order of nine equipment work packages** locked, not numeric mechanics; Chân Văn individual only, not free set proc; 24 sets ×4 positional template identities | after BD-01: enhancement caps (NOT LOCKED, including old +15), fail/salvage, reroll vs value tune, grade/tier promotions, inheritance, rare inscription, item UID and atomic debit+receipt | BD-01,03 |
| **5** | **BD-05 EQUIP-AUTO-ALLOC** | Đồ tập thể/tổ đội | all items Sect-owned, actor is assignee; locked items protected, no private purchase for ownership; valid 3+3 2/3 bonuses | algorithm assigning among 1k–3k disciples, role-aware set-aware holistic upgrades, reserve/lock/transfer and stable selection, monotonic outcome, deterministic batching | BD-01,03,04 |
| **6** | **BD-06 PILL-RECIPE-TIERS** | Linh Điền→Đan→HP/Tu Vi/Body | Hồi Xuân 10 satiety/+55 HP, Tụ Khí 25/+10,000 fixed Tu Vi pilot; 1,000,000/day/disciple across medicines; 30×10 each Tu Vi+Body | medicine families by realm, verified ingredient outputs and costs, how pills remain meaningful vs late-stage HP/XP without hidden arbitrary multipliers, Body/Breakthrough/Thọ Đan sources, no phantom recipes | equipment/monster drop economy BD-02 |
| **7** | **BD-07 BOSS-CREDIT-ECONOMY** | Boss nhiều đội | one Boss HP/one Sect loot; causal DPS/tank/heal/support and no last hit; eligible personal Tu Vi once; Sect Spirit Stone cut **60/40 NOT LOCKED** | numeric contribution thresholds, retreat/late join/downed, support witnesses, role fairness simulations with actual Combat V2 fixtures; stone pool share and Boss rare drops | BD-02,03 and team admission |
| **8** | **BD-08 LONG-RUN-SYSTEMS** | AI/job/offline/profession/thọ | One Active Job, one clock, 30×10+30×10, ghost kept in roster instead of permanent delete; production/economy design existing | official simulation-age cadence, ghost/Thọ Đan lifecycle, higher-grade professions/work consumers, AI bãi/recipe/gear stock goals, large-pop scale policies, 300-tier no-softlock economic feasibility | after loop BDs 01–07 |

**Status:** these are the **remaining design gaps**, not proofs that every listed capability is absent in older P2. Do not redesign canonical approved 10 slots/12 grades/24 sets. Import of advanced rules into Godot V2 remains CODE PENDING.

## B. Precise first-ticket findings: equipment V2 design versus current code

Source:
- `docs/WEAPON_EQUIPMENT_V2_SPEC.md`: 10 ordinary gear slots (weapon, helm, armor, cape, bracer, gloves, belt, boots, jade, ring), 12 quality grades with authored ordinary/rare affix capacities; separate 3 Phù +2 Pháp Bảo +4 consumable slots; all equipment Sect-owned; grade and equipment-realm-tier are orthogonal.
- `docs/EQUIPMENT_SETS_V2_SPEC.md`: 24 lineages ×4 defined slot templates =96 unique position templates; only six positions set-eligible; cumulative 2/3/4 effects; 3+3 may trigger both eligible families; generation Nhân/Tiên/Thần; no free proc or set Chân Văn.
- `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md`: nine-step design order; **first: one complete forge-to-Warehouse transaction**. No probabilities, +15 caps, material costs, quality chances, item base values locked.
- `docs/WEAPON_EQUIPMENT_V2_REALM_MAP_SET_MATRIX.md`: 30 maps ×10 clusters is **proposed**, not shipping content or globally locked map count. Only one hunting map with 10 clusters is prior agreed topology.
- `godot/src/simulation/equipment/equipment_system.gd` on inspected main is a real **P2 compatibility implementation**: `VALID_SLOTS=[weapon,armor,talisman]`, 5 authored pilot recipes, basic quality defs, craft, manual equip, auto upgrade, purchase/sale, `owner_id` assignment, unique `equipment_items`; `DiscipleCombatLoadoutV2.build` bridges that actual P2 gear to the Combat V2 actor. This is NOT a production 10-slot V2 implementation.
- `godot/src/simulation/building/alchemy_recipe_registry.gd` on main historically only Hồi Xuân recipe; CARE branch adds Tụ Khí pilot. Do not mark either pilot as a complete rank-1..30 medicine line.
- `godot/src/simulation/combat/b3_pilot_content.gd` on CARE branch has explicit Bạch Thạch Khê/Thanh Lang `1 Tinh Lang Bì per generation`; an actual test content slice, not all monster drops.

### BD-01 deliverable: a **single real future forge order**, not another system encyclopaedia

Design this specific end-to-end sample with real canonical resources or explicitly label any **PROPOSED NEW resource ID** (do not silently add a resource):  
`Luyện Khí Điện/order → craft target by authored recipe (template/slot/tier/set eligibility) → check crafter and building level → reserve Sect Warehouse materials → start One Active Job for crafter and durable order ID → persist selected outcome seed and future timing → at the completion tick settle once → roll legal quality+affix from approved pool → create unique Sect-owned item instance with generation/grade/tier/roll/locks/state → insert under original canonical equipment registry/Warehouse transaction → assign/equip later through policy → SaveService crash/retry cannot reroll or clone item`.

Required explicit answers:
1. What exactly is chosen **before crafting**: template/slot/lineage/tier, what is rolled at completion, and whether recipe failure produces a legal weaker result?
2. Which **real** P3.7 Warehouse resource IDs pay which units? How does a Boss material make chasing a gear variant desirable without blocking first basic crafting?
3. Which **real building/profession** consumer checks are available now and what new minimal authority must be added? Prove work speed applies to duration not duplicated yield.
4. Is `equipment_items` still unique-item registry, or is new schema needed? Distinguish Sect ownership from legacy `owner_id` = wearing assignee. Migration must preserve three legacy equipped items and exact Warehouse counts without granting free gear.
5. When the app crashes before reservation, after reservation but before completion, after roll but before durable save, and after save before UI refresh, what exact idempotency/receipt barriers protect all resources and item instances?
6. Exactly which Combat V2 stat channels and skills can consume each affix, set threshold and individual Chân Văn? `PROPOSED` until actual consumers exist. No mega-stat that bypasses realm core.
7. How does quality 1..12 affect capacities without guaranteeing max lines? Which rolls depend on actual profession/rare materials? All rates explicitly `OPEN`.
8. How is manual player override + future auto policy represented and how are locks/reservations retained on save?
9. What is the smallest CODE pilot? Recommend ordinary **one recipe, one weapon or armor**, basic quality/affix and true unique item storage before 10-slot mass extension.
10. What are the legacy P2 upgrade/purchase compatibility and save migration traps, with reversible rollback?

**Do not** write new implementation yet, expand to Phù/Pháp Bảo, specify fictional probabilities as canonical, or insert Source A assets into these backend documents.

## C. Parallel work rule

- **Currently CODE owned by Codex:** PR #24 CARE, PR #25 P3.2 integration, playable Windows/manual/code fix/UI as separately authorized. Don't edit `godot/src/presentation/p3_2_landscape_sect.gd`, `SimulationState`, `SectState`, `SaveService`, Combat V2 or EquipmentSystem during DOCS audit; do not merge or change PR targets.
- **This independent backend design thread:** inspect the source/format and author isolated `docs/design/BD_01_...` contract, quantity assumptions, decision matrix and future narrow CODE allowlist only. No new game runtime and no claimed official tests.
- **Go/no-go:** Owner approves BD-01's concrete transaction/inputs/outputs and all new **numeric** rules separately before Codex or a second coder implements it. Balance may be calibrated against gameplay logs first.

## D. Suggested one-session prompt for BD-01 (DOCS ONLY)

```text
TÔNG MÔN BÁ ĐẠO — BD-01 / TRANG BỊ V2: MỘT LỆNH RÈN THẬT, CHỈ THIẾT KẾ.

Đọc AGENTS.md, master roadmap, và docs/roadmaps/TMB_BACKEND_DESIGN_GAP_QUEUE_2026-10-23.md từ nhánh docs/tmb-master-completion-roadmap-20261023. Đối chiếu WEAPON_EQUIPMENT_V2_SPEC.md, EQUIPMENT_SETS_V2_SPEC.md, EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md với equipment_system.gd, Combat V2 loadout/stats, BuildingSystem/Workforce/Warehouse/Save.

Tôi muốn audit chính xác luật đã KHÓA vs code P2 hiện có vs phần CÒN THIẾU. Không thay đổi 10 ô thường+3 Phù+2 Pháp Bảo, 12 phẩm, 24 bộ, 2/3/4 hiệu ứng, đồ thuộc tông môn. Ưu tiên chỉ một giao dịch: công thức→đặt lệnh rèn→phân thợ→trừ kho→kết toán→roll phẩm/affix hợp lệ→item ID duy nhất→vào kho→trang bị→save/load và chống nhân đồ. Nêu các lựa chọn còn mở: giá, tỷ lệ, thất bại, affix, khả năng nghề, nâng cấp, cưỡng bức ra kết quả. Có ví dụ 1 vũ khí, 1 áo giáp và fixture bảo vệ P2/migration. Lập matrix dữ liệu hiện có vs cần bổ sung, contract schema dự kiến, danh sách quyết định cần owner duyệt và gói CODE pilot rất nhỏ sau này.

**DOCS ONLY** trên nhánh thiết kế riêng; commit file Markdown lên GitHub, không code, không merge, không FULL/CI, không sửa PR #24/#25, Source A, Character Studio hoặc map.
```
