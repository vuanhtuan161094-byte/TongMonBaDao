# TÔNG MÔN BÁ ĐẠO — CỬA KIỂM SOÁT SOFTLOCK, SAVE/MIGRATION, DỰ PHÒNG Lv75 TRƯỚC R21
## Hợp đồng nghiệm thu thiết kế / 34 tình huống lỗi; chưa chạy Godot

**24/10/2026 · DOCS ONLY · NO CODE / PR29 / UI / SOURCE A / MERGE.** Theo lựa chọn B của owner, ALL Forge-created equipment realm21+ MUST require authoritative Luyện Khí Điện Lv75. Không khóa số/cost/drop rate hoặc cho phép code. Accompanying files: docs/design/TMB_FORGE_LV30_TO_LV75_STRICT_R21_GATE_REAL_SOURCE_CONTRACT_2026-10-24.md and docs/research/TMB_FORGE_LV30_75_COST_PROOF_ECONOMY_TIME_PROFESSION_2026-10-24.md. Source main 29b5fba448b0178cb520a4ada44b375b4b934e31, branch docs/gear-r10-r11-r20-r21-first-design-acceptance-20261024. [OWNER] scope, [SOURCE] verified, [P] design, [BLOCKED] runtime unavailable, [QA-NOT-RUN] test contract.

## 1. Strict dependency DAG and correct acquisition order
R20 Tiên active equipped party and low-tier legitimate gatherers
→ genuine early-game Mine, Forest and Hắc Phong Cốc resources, actual Warehouse receipts (Linh Mộc, Thanh Thiết, Yêu Đan), real Sect Stone funding (possibly genuine NPC sale receipts)
→ valid Forge building Lv30 registered, with a true level-up method and authored stage costs
→ 19 upgrades Lv31–49 → Lv50 valid Yêu Đan milestone → 24 upgrades Lv51–74 → Lv75 Yêu Đan milestone, each cost/work paid and persisted ONCE
→ VERIFIED active Forge facility level75 (not a fake state or worker profession)
→ R20-geared team goes to true R21 outer frontier (still requires map/species/source authoring) for proposed eqv2_r21_ore/fiber/beast BEFORE R21 gear
→ paid Sect-wide first-blueprint research, Lv75 Forge-selected item job, Warehouse debit+unique item/receipt, legal wearer
→ set staging before changing Tiên 2/3/4 to Thần 2/3/4; optional donor-consumed inheritance and distinct Chân Văn source later.
**Do not invert:** Blueprint does not unlock Lv75, R21 loot does not auto-build Lv75, R21 gear does not appear when disciple crosses realm, C4/UI VFX cannot issue receipts.
**Formal cycle test:** Build a directed graph with prereq nodes building_level(75), source(wood/ore/yeudan/stones), can_access(early_regions), skill_for_building, R21_source, blueprint, item, equip. Reject any edge requiring R21_item or R21_Boss/Thần-specific R21-gear material for forge_level<=75. If all sources nominally lower but unaffordable due zero Stone, isolate funding softlock. If all qualified workers are injured or busy, require a real recovery/recruit path, not auto-minted professional XP.

## 2. What is verified versus absent on MAIN
- [SOURCE] BuildingSystem has no Forge type among its recognized definitions; R21/Forge Lv75 upgrade has no running code. Its upgrade_cost/progress math applies to actual registered building definitions only. BuildingState has persistent level, status=active/upgrading, upgrade_target_level, upgrade_required_work and progress; this is schema *infrastructure* not an operational forge instance.
- [SOURCE] ResourceRegistry and Mine/Forest identify genuine wood/ore; HuntingMapV2 declares Hắc Phong Cốc yeu_dan per TRUE victorious encounter; Economy-A NPC market sell is capped and receipt-backed; none proves instant enough stocks at R20. Forge milestone speciality Lo Tam/Hoa Chung from doc is thematic without registered ID; a trial Yêu Đan alternative is open owner approval.
- [SOURCE] SaveService.CURRENT_VERSION=2, SimulationState.SAVE_VERSION=1; SectState has legacy P2 equipment_items/forge_materials/equipment_forge_index and P3.7 Warehouse resources and sect.spirit_stones. WarehouseSystem.ensure_migrated already carries legacy materials to ONE canonical Warehouse snapshot idempotently; future V2 operation reservations, Forge facility identity, per-stage upgrade receipts and unique gear archive remain absent.
- [SOURCE] BuildingSystem.start_upgrade for known types consumes Warehouse resource quantities and Sect Stones, records level-up work; the code does not by itself guarantee a cross-system crash-safe journal including Forge item creation or staged in-progress jobs. P2 equipment slots (weapon/armor/talisman) must not silently map to new V2 pendant/10 slots.
- [SOURCE] One Active Job, Injury0/1 recovery120, canonical Sect sim tick, 24×4 set/generation, item grade1–12/realm1–30 and Combat V2 math remain protected. Player's approval of a design DOES NOT imply tested production or PR merge.

## 3. Failure matrix: distinguish temporary bottleneck from permanent softlock
| Condition | Nature | Correct response without bypassing Lv75 |
|---|---|---|
| No Forge type/level/upgrade path exists in runtime | HARD BLOCKER | require separately owner-authorized facility content/code, no fake grant |
| Builder Lv49→50 requires unregistered special catalyst | HARD BLOCKER | either approve real registered Yêu Đan trial, or author named specialty with REAL <=R20 repeatable source and test |
| Builder Lv74→75 requires R21 ore/boss | DEPENDENCY CYCLE | reject recipe; use valid <R21 source policy, never waive Lv75 |
| No Sect Spirit Stones and no tradable resources | ECONOMIC DEADLOCK | restore lawful Mine/Forest production/earn via authentic NPC receipt, or future independently approved Stone source; no free cash |
| Market quota20/day and costs high | SLOW PROGRESSION, not strictly deadlock | choose pacing after source simulation; never claim 3.7 days end-to-end |
| Missing Hắc Phong Cốc accessible path or combat win | SOURCE BLOCK | repair genuine ≤R20 access/encounter/reward, not map preview payout |
| Warehouse reserve_min/locked prevents materials | INTENTIONAL PLAYER BLOCK | expose exact need/have/locked; allow explicit owner policy change, never bypass protected stock |
| Worker Injury or one worker doing hunt and forge | TEMPORARY | recovery120 tick/One Active Job and lawful reassignment; preserve reservations |
| Source R21 outer frontier unreachable with R20 gear AFTER Lv75 | POST-GATE SOFTLOCK | author real access from R20 gear and ordinary M/F/N before R21 item; Lv75 alone insufficient |
| All 3,000 members must own Lv75 instead of a facility | FALSE DEPENDENCY | one building capital cost per instance; per-member only real gear materials and lawful professional labor |
| Boss-exclusive output is the only path to basic R21 ore | LOOT SOFTLOCK | provide ordinary repeatable source/alternative, keep Boss chase optional |
| Old set migrated to new Thần generation on level-up | DUPLICATION/LEGALITY BUG | no conversion; stage new targets and preserve old gear |

## 4. Additive schema and versioned migration plan [P; NOT IMPLEMENTED]
**Migration preflight:** check existing SaveService version2 and SimulationState internal version1; these are different constants. Validate previous save shape, original Sect Stone and physical resources, BuildingState IDs/levels, legacy equipment_items and active work states. Backup last-known-good original before changing supported fields. Reject corrupted/unknown newer schema without partially consuming.
**Proposed new persisted objects:** 
- facility_def_id and facility_instance_id in registered content mapping for true forge; an existing real instance with Lv30 or higher needs authenticated upgrade history; do not fabricate a Lv75 upgrade because some past save stores forge_support_points.
- sect.forge_construction_order_journal keyed stable construction-order ID, with prestate level, target level, resource+Stone debit receipt, work units, milestones, upgrade status and revision. For every level, status order REQUESTED→VALIDATED→DEBIT_COMMITTED→RUNNING→COMPLETED; duplicate request reuses exact receipt and never subtracts twice.
- new Forge recipe/order journal separate from construction journal; unique equipment registry + template version; one Sect-wide learned blueprint archive; item assignment by canonical 10 slots with ID version/owner. Donor and target inheritance must lock unique instances and preserve generation.
- integrate exact material reservation with canonical Warehouse rules/stock; do not maintain forge_materials as a second live resource bag. Preserve zero/empty defaults on old saves. Do not auto insert Yêu Đan, new ore, set patterns, R21 item, Chân Văn or Spirit Stones on migration.
**Load/save invariant:** after source receipts, milestone debits and construction events, same-build save/reload is stable; crash after resource+Stone debit but before grade/level/receipt must roll back or complete same durable operation, not charge again. Cross-version older executable must refuse unsupported future save and retain backup, not discard unknown proposed materials. Existing SaveService .tmp/.bak staging is groundwork, not a ForgeV2 transaction implementation or proof of migration PASS.
**Upgrading while active work:** choose policy before code: (recommended) Drain queued Forge item work before start, stop accepting NEW gear orders while facility status UPGRADING, then resume after level complete; actual canonical time and XP from only real jobs. Alternative freeze existing work with pinned state, but no double completion/partial refunds. A paused construction cannot create Thần output while level remains74; on completion at tick t, eligibility begins only after durable state and correct receipt at t.

## 5. Recovery/fallback menu, all remain real gameplay
**F0 (recommended):** Keep Lv75 mandatory, use current registered Linh Mộc, Thanh Thiết, Yêu Đan and valid Sect Stones under owner-approved milestone/cost curve. Gather before building upgrades; player can reserve stocks and schedule real old-zone teams. If real source path still blocked, keep strict Lv75 and correct SOURCE, not item gating.
**F1: author themed Lô Tâm/Hỏa Chủng with a fully explicit ≤R20 source.** Material ID presently nonexistent; propose future manufacture using a real Forge-independent artisan/alchemy consumer from genuine old-world ingredients or true repeatable old-world encounter reward. Must pass bootstrap test: does NOT itself need Forge Lv50/75 or R21 gear; cannot describe this as already supported. No unregistered ID may be written to Warehouse now.
**F2: change Forge-specific financial coefficient/work duration** to meet a chosen target pacing while still consuming real resources and milestone component, preserving one receipt and building Lv75. Owner needs to choose budget; copying Mine pricing is only baseline math. No gratis upgrade to Lv75 and no P2 treasury/wallet loan made up.
**F3: permit parallel lawful production/multiple independently registered Forge instances** to mitigate workforce downtime once authored, but each instance individually obeys Lv75 before any R21 output; no worker splitting One Active Job and no shared money double spend.
**F4: allow older equipment hand-me-downs and focused 30-hunter squad progression** while capital accrues; old Tiên high-grade gear remains useable when legal. No pretend full Sect 3,000 actors deployed and no first-R21 boss required.
**Do NOT:** silently revert to Lv30 R21 basic, use Body-Gate seals as forge catalysts, create R21 set/gear on realm breakthrough, hand out Lv75 UI shortcut, clone source loot from preview/camera or auto-fill owned recipe archives.

## 6. Thirty-four [QA-NOT-RUN] deliberate fault injections
| Test | Fault | Expected behavior |
|---|---|---|
| G01 | Forge facility absent in BuildingSystem | cannot start Lv31/R21 Forge; report missing authoritative facility |
| G02 | Forge level74 but worker profession Lv1000 | R21 Forge strictly rejects |
| G03 | Forge level75 but worker unqualified/missing recipe | R21 rejects before debit |
| G04 | Forge level75 with no R21 material IDs registered | rejects before debit |
| G05 | Forge level74, UI label accidentally says75 | backend still rejects R21 |
| G06 | Lv49→50 specialty not registered | block construction; no ghost milestone |
| G07 | Lv74→75 specialty only R21 Boss source | block because dependency cycle |
| G08 | Lv74→75 source Yêu Đan from true Lv1 Hắc Phong victory | authentic receipt, then milestone consumes exactly20 |
| G09 | Replay same victorious encounter preview 100 times | no extra Yêu Đan, reward from true settlement only |
| G10 | Market sale same request_id retried | one inventory debit and one Sect Stone receipt |
| G11 | Market daily quota exhausted | no extra NPC sale/payout that day |
| G12 | Warehouse user reserve_min protected ore | upgrade refuses without violating reserve |
| G13 | Warehouse resource locked after accepted construction debit | no debit twice on resume |
| G14 | Not enough Sect Stones at Lv70 | reject start with clear need/have, level unchanged |
| G15 | 2 simultaneous upgrade requests for one Forge instance | one win, second idempotent or rejects |
| G16 | A job/hunt/forge uses same worker concurrently | One Active Job respected |
| G17 | Worker injured Injury1 during item Forge while building upgrade requested | pause/drain consistent and recovery120 |
| G18 | Building upgrade time advances offscreen | one canonical tick stream, no duplicated work |
| G19 | Save during Lv49→50 construction | same remaining work/milestone material receipt |
| G20 | Crash after construction Stone debit before building status update | recover old snapshot or durable same debit+level transition |
| G21 | Crash after Lv75 completion before Save ACK | reopen exact Lv75 once, no free duplicate bonus |
| G22 | Lost/corrupt primary .tmp and valid backup | restore valid previous snapshot, no partial Forge grant |
| G23 | P2 old save has forge_materials still populated | migrate canonical Warehouse only once, preserve money/items |
| G24 | Old P2 talisman and new V2 pendant | do not auto-convert or clone |
| G25 | Unknown R21 material in old client | reject new-version Save safely, do not erase item and keep cost spent |
| G26 | R20 item remains equipped after disciple reaches R21 | no auto-promote old Tiên gear into Thần |
| G27 | R20 four-piece set plus one R21 piece | correct generation threshold, do not fake 4-piece bonus |
| G28 | R21 set4 switched simultaneously | one new legal equipped group, no extra bonus from dormant old set |
| G29 | R20 donor inheritance into new R21 item at Lv74 | cannot forge target until Lv75; no donor clone |
| G30 | R21 drop from true monster before Lv75 | separate loot system eligibility, do NOT classify as a forge; owner separately decides equip |
| G31 | R21 boss reward via 30 hunters | one shared HP/loot receipt, not each participant×1 |
| G32 | 1,000/3,000 rosters request initial Lv75 | one facility capital bill, no3,000 artificial copies |
| G33 | Copy Mine numeric formula but Forge definition absent | design model only; never say executable PASS |
| G34 | No Godot, physical Android, owner UX evidence | all remain NOT TESTED, no FULL/CI/visual acceptance claim |

## 7. Honest gate status and sign-off decisions
| Gate | Source or design evidence | Current status |
|---|---|---|
| S01 strict Lv75 for ALL forged R21 | explicit newest owner direction | **DIRECTION APPROVED**, code absent |
| S02 source <=R20 for 45 bills | 4 real material/currency IDs and Mine/Forest/Hắc Phong/economy sources | **SOURCE DEFINED, ACQUISITION NOT MEASURED** |
| S03 price/time and milestone component | 45-level synthetic ledger, total 7,169/10,746/35,777/30 | **PILOT NUMERIC ONLY** |
| S04 Forge building/upgrade authority | no Forge definition in main BuildingSystem | **BLOCKED RUNTIME** |
| S05 Source Spirit Stone pacing | NPC default20 units/day, 8 Stones/ore, 224-day lower-bound financing only if source0 Stone | **HIGH BALANCE RISK / NOT APPROVED** |
| S06 worker/One Job/upgrade queue | profession exists, Forge per-building order and builder policy not authored | **BLOCKED** |
| S07 Save/migration/rollback | schema plan, genuine SaveService version2 and .tmp/.bak recovery | **NEW FORGE MIGRATION NOT CODED** |
| S08 R20→R21 source + equip | earlier 3-source frontier design and separate R21 normal actor/ore/blueprint | **NOT CODED** |
| S09 official QA | 34 fault fixtures listed, none executed | **PENDING** |
**Owner must still choose:** (A) accept the real registered Yêu Đan catalyst at milestone50/75 and recalibrate Forge-specific Stone bill while retaining strict Lv75; (B) demand distinct themed Lô Tâm/Hỏa Chủng with a verified authentic <=R20 source, no shortcut; (C) focus first on versioned Save/facility schema and testable source gates in docs. No option authorizes code, CI, PR29 modification or merge.
