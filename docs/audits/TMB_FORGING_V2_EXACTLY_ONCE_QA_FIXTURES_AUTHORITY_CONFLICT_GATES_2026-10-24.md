# TÔNG MÔN BÁ ĐẠO — LUYỆN KHÍ V2: TRANSACTION INVARIANTS, FAILURE MATRIX AND FUTURE QA GATES
## Strict design audit. These are FUTURE focused fixtures, NOT executable tests, CI or runtime PASS.

**Date:** 2026-10-24. **STATUS: DOCS ONLY, NO GAMEPLAY CODE, NO CODEX PACKET, NO PR29/UI/SOURCE A CHANGE, NO MERGE.**
**Core research files on same branch:** `docs/design/TMB_FORGING_V2_END_TO_END_TRANSACTION_BLUEPRINT_FACILITY_2026-10-24.md` and `docs/research/TMB_FORGING_V2_GRADE_1_12_COST_TIME_SALVAGE_INHERITANCE_BALANCE_2026-10-24.md`. Main at audit `29b5fba448b0178cb520a4ada44b375b4b934e31`, PR29 S1 OPEN/DRAFT `9522812e91b7ca5bc0cc108eb92e000e930fe850`. **SOURCE:** canonical Warehouse, save, `GameRng`, `ProfessionModifierSystem` and real P2 `EquipmentSystem` only; no V2 full crafting runtime. Future QA requires separate authorized code and official Godot4.7.2 evidence.

## 1. Required invariants, specific ownership
| ID | Invariant | Authoritative owner / why |
|---|---|---|
| F-IN01 | One accepted `client_request_id` produces at most ONE `order_id` | simulation Forge command authority; duplicate UI tap no second order |
| F-IN02 | Same `order_id` has at most ONE active reservation ledger entry per registered material; order hold is within ONE Sect Warehouse, not `forge_materials`/personal bag | canonical Warehouse + order journal |
| F-IN03 | `available(resource)=stored−reserve_min−Σactive_order_holds` while unlocked, never negative; locked resources unavailable | Warehouse rules, held liability; current `WarehouseSystem` does NOT implement order holds |
| F-IN04 | Material debit exactly once at COMMITTED, at most ONE `item_instance_id` and ONE work/profession completion credit | commit receipt/journal |
| F-IN05 | `UNIQUE item ID` cannot coexist as equipped on two disciples or in storage+shop copy simultaneously | Sect unique registry, equip pointers |
| F-IN06 | Repeat save/load or seek time advances NEVER changes previously frozen grade/affixes, output quantity or seed | per-order deterministic RNG and committed receipt |
| F-IN07 | Worker has at most ONE Active Job; Injury0/1/120 PAUSE/reassignment never grants progress while unavailable | Workforce/CARE authority |
| F-IN08 | Total work duration in canonical sim ticks, time-speed/offline have same result given same authoritative eligible tick history | scheduler/work status, not GUI |
| F-IN09 | Profession level boosts work speed (time), not product count; profession talent boosts XP, not generic grade probability | profession modifier canon |
| F-IN10 | Every slot is among ten V2 ordinary slots; `talisman` legacy is not `pendant`; output matches chosen template/slot/weapon form | Equipment V2 |
| F-IN11 | Item realm index1..30, grade index1..12, normal/rare/Chân Văn maxima legal and not duplicated, no new stat/action with missing consumer | Equipment V2 content gate |
| F-IN12 | Exactly four distinct set positions/lineage, thresholds 2/3/4 cumulative, same-generation, weakest realm governs tier, no free skill/Chân Văn | 24-set V2; **Hỗn Độn only Thần** |
| F-IN13 | No output on an item/blueprint/material unregistered, absent worker/facility or fail validation; invalid input never reserves or debits | fail-closed content contract |
| F-IN14 | Source rarity profile HIẾM is per actual monster-kill loot **separate** from Forge quality RNG; no accidental double allocation of old victory rewards | Combat V2/B3 + loot authoring |
| F-IN15 | Cancel queued order releases exactly its own hold; PAUSE preserves funds/progress; ACTIVE cancel policy OPEN and cannot be treated as free rollback | transaction |
| F-IN16 | Grade-upgrade fail, if authorized, preserves exact same item+grade+lines+set/realm; spent fee never refunded by retry | upgrade separate operation |
| F-IN17 | Salvage consumes one unique item and credits only registered returns, exactly once; craft↔salvage loop has no free resource or new blueprint | salvage economics |
| F-IN18 | Inheritance consumes one source unique item and changes one target under legal item/realm/generation/lineage constraints, no clone or equip ghost | transfer |
| F-IN19 | All items belong Tông Môn; autoequip/priority/locks are independent transaction, no item directly belonging to individual hunter | canonical Sect warehouse |
| F-IN20 | The source Spirit Stone, Tu Vi, EXP rewards not duplicated by Forge completion; normal V2 work does NOT grant extra Tu Vi beyond continuous natural source | economy/CARE |
| F-IN21 | No Forge/Salvage/Inheritance UI/animation can mutate underlying material or item identity without a real sim transaction | architecture A/B/C |
| F-IN22 | No forging implementation is considered PASS from design-only docs, static validation, offscreen state or synthetic throughput alone | release evidence |

## 2. Crash, reentry and same-build restart fixture matrix (NOT RUN)
**Preparation after separate implementation authorization:** fresh isolated temp save at exact future commit; register only real test materials/templates, fixed `world_seed`, `order_id`, canonical tick and full legal worker/facility; capture before/after Warehouse and unique item registry, exact material/recipe versions, old/offline snapshots. A test asserts actual inventory/event receipts/XP and **save/replay** stability, not just a return bool.
| Fixture | Disrupt at this exact transition | Expected after reload/retry |
|---|---|---|
| F-Q01 | Double-tap request before admission | one order, one material hold only |
| F-Q02 | Create two orders racing for last legal `thanh_thiet` | one accepted or both only if summed holds fit stock less protected reserve; no negative stock |
| F-Q03 | Disable auto-consume / owner lock after an existing RESERVED order; then new order | existing legitimately reserved order still holds its snapshot (policy to approve); new order blocked; no illegal new debit |
| F-Q04 | Crash right after reserve journal persisted, before ACK to UI | same reserved order and hold restored, no duplicate |
| F-Q05 | Crash when worker goes HUNT during Forge order | One Active Job arbitration, job paused/reassigned once; no extra work ticks |
| F-Q06 | Injury on worker during ACTIVE and recover at tick+120 | no forbidden work progress during Injury; resume correct remaining ticks with valid worker |
| F-Q07 | Save at `remaining_work_ticks=1`; advance offline one eligible tick, load twice | single due/resolve, no two items |
| F-Q08 | Save after RNG outcome frozen but before material debit | frozen same grade/affixes/item ID; one atomic final commit |
| F-Q09 | Save after material debit but before unique item insert (injected crash at journal substage) | journal rolls forward/repairs atomically; neither permanent "paid/no item" nor duplicate |
| F-Q10 | Save after unique item insert but before receipt ACK | one item ID only, one material debit, one XP credit |
| F-Q11 | Pause with original worker changed equipment/work buffs, then resume | job snapshot speed rule (or owner-approved explicit recalculation) applied once; no time exploit |
| F-Q12 | Quickload repeatedly at due tick hoping for grade5/6 | exact same stored RNG/outcome; no free rerolls |
| F-Q13 | Roll grade2 then corrupt affix pool with invalid action tag | fail-closed/PENDING_CONTENT without spawning a forbidden stat proc or silent reroll |
| F-Q14 | Two orders simultaneously resolve with separate deterministic IDs | each legal order one distinct unique item, deterministic order by due tick and order ID |
| F-Q15 | Cancel QUEUED_RESERVED repeatedly | hold released once, no credit of an input that was only held |
| F-Q16 | Press ACTIVE cancel/restart | unresolved until owner decides policy; must not issue a free retry/new seed/refund after output was rolled |
| F-Q17 | Basic `boots` equipped on disciple A, autoequip same ID on B | reject or atomic unassign A and equip B once; no double assignment |
| F-Q18 | Equip higher-grade item that would break valid 4-piece named set | honor owner lock/set scoring; no hidden dismemberment due to isolated item score |
| F-Q19 | 24-set 96-template validation: slot, identity and Hỗn Độn realm1 | reject any Hỗn Độn below realm21 and any invalid seventh set slot |
| F-Q20 | Salvage same item ID in two concurrent transactions | one item consumed/returns once; second request already settled or rejected |
| F-Q21 | Salvage then reload just before Warehouse credit | canonical journal gives one material return and item still deleted |
| F-Q22 | Inherit item S→T while S currently equipped/locked or assigned | reject unless valid explicit unassign state; never consume both items |
| F-Q23 | Crash after old source consumed in inheritance before target updated | journal completes transfer exactly once or rolls back cleanly; not both |
| F-Q24 | Retry failed grade upgrade with SAVE rollback at result | same grade unchanged, same committed cost once, no new chance without NEW paid order |
| F-Q25 | Run Forge orders at speed1× vs offline under same work availability | same tick-due resolved item/grade/receipt and material balance |
| F-Q26 | First archive named blueprint twice from actual monster source | one permanent sect unlock, no recipe proliferation/double future stock |
| F-Q27 | Realm/grade quality vectors 1..12 and missing materials for seven [NEW] monsters | every profile sums100%, no unregistered material or ghost output |
| F-Q28 | Mid-session World Boss 5 teams, one Hắc Lang Vương defeated | exactly one world loot reward; no extra Forge/Blueprint reward per assisting team |
| F-Q29 | Worker profession XP gain at production completion interrupted by save | one XP credit, no repeated Lv-up or inflated bonus |
| F-Q30 | Use item as target of inheritance while it is being salvaged or equipped by another order | same item lock prevents concurrent incompatible transitions |

## 3. Content + economy fixture requirements
**E-Q01 source truth:** old `EquipmentSystem.RECIPES` count5, three old slots; future proposed basic ten and specialist ten registered output templates may not collide with old `talisman` and no shadow legacy item authority.
**E-Q02 Forge basics:** 10 fixed non-set ordinary outputs with distinct legal slot IDs and 3 conditional `weapon_form` variations under ONE weapon slot. Components sum correctly `thanh_thiet×15 + linh_moc×21` per complete kit; every one of its inputs exists now; output definitions currently DO NOT.
**E-Q03 specialty:** 10 named monster-material recipes preserve two corrections (Fire cloak `ttl_xich_viem_xac×1 + ttl_hoa_lang_nanh×1 + linh_moc×2`, Water bracers `ttl_thuy_tinh_giap×1 + ttl_thuy_vu_tinh×2 + tinh_lang_bi×1`); other existing proposed recipes unchanged. No Forge while required [NEW] material registry or consumer missing.
**E-Q04 blueprints:** all 24 canon lineages, 96 named pieces exactly matching `EQUIPMENT_SETS_V2_SPEC.md`, set results only six eligible positions. Compare FIRST vs FOUR blueprint gating alternatives; neither magically produces a complete 4-piece set upon first unlock.
**E-Q05 Grade:** proposed vectors basic Lv1 `100% grade1`; specialty Lv30 `60/26/10/3/1% grades1..5`; advanced Lv75 `20/32/24/14/8/2% grades1..6`, all sum100%; grade7..12 require a separately authored source/profile, no invisible chance. Use seeded repeated trials for distribution bounds only after real code, never fake numerical godot PASS.
**E-Q06 profession time:** Profession Lv0=×1, Lv50=×1.5, Lv100=×2; baseline24-tick order→24/16/12 effective ACTIVE ticks in an otherwise multiplier-free snapshot; no extra item count. XP talent +5..25% only profession XP, once.
**E-Q07 materials:** accepted versus reserved-versus-spent ledger, same registered source ID and `WarehouseSystem.MAX_SAFE_STACK=9000000000000000` with reserve/lock. No arbitrarily "warehouse full"; only legal overflow and locks.
**E-Q08 basic economics:** 30/1000/3000 ×10 positions =300/10000/30000 items, material needs450/15000/45000 Thanh Thiết and630/21000/63000 Linh Mộc if every one newly gets basic kit. Forge lanes and input sectors must be actually profiled rather than assuming 4 concurrent workers.
**E-Q09 named set availability:** 12 [S0] low-rank candidate families, 6 [S1] advanced/camp event candidate and6 [S2] deferred as documented in previous matrix, but these readiness buckets are EDITORIAL not number of currently implemented sets. Hỗn Độn Thần only. The exact-source cells are proposals not loot validation.
**E-Q10 salvage anti-arbitrage:** with fixed input/output tables, ≥1 strictly consumed resource/time/cost per repeatable create→disassemble cycle, no per-order blueprint mint, no random rare output on pure salvage.
**E-Q11 historical recipe cross-check:** older P2 `huyen_thiet_quyen_sao` name does NOT mean material `huyen_thiet` is consumed (its actual inputs `thanh_thiet×3+tinh_lang_bi×1`). New V2 never silently changes that old recipe.
**E-Q12 no Hồi Xuân Đan source change:** old code `thanh_linh_thao×3` differs from newer owner pill contract `thanh_linh_thao×2 + linh_coc×1`, base6 ticks; unrelated known debt must remain out of Forge docs/code scope.
**E-Q13 20 camps:** 30 hunter RTS world 200–400 live monsters is separate from 1,000–3,000 sect members; no rendering 3,000 battle actors or spawn extra Boss per forged set.
**E-Q14 role:** Kiếm/Thể/Pháp and mixed path build based on learned skill and actual weapon_requirement, not static exclusive item class tags; every effect must use real canonical stat/event consumer, no source-less buff.

## 4. Evidence ladders and future implementation sequencing — NOT a Codex packet
1. **DOCS REVIEW:** verify canonical read provenance, choose reserve model, blueprint unlock cardinality, grade1 policy, advanced grade6 profile, upgrade/salvage/transfer scope; owner accepts design **explicitly** before any CODE.
2. **CODE scope required separately:** first isolated CREATE Forge vertical slice that uses actual registered `linh_moc/thanh_thiet`, ten V2 basic slot outputs and one real facility/worker/order/receipt. No simultaneous writer on `WarehouseSystem`, `SimulationState`, `DiscipleState`, `BuildingSystem` or PR29 shared code.
3. **Official Godot4.7.2 evidence:** focused job/Forging/Warehouse/Save tests, cross-cutting Economy-A and GP-02B1/GP-02C1 contracts, negative fixtures and actual 1280×720 GUI and Android hardware (pending); do not claim screenshot/performance gate from this document.
4. **Then** explicit authorization for Lv30 seven-species content+blueprints and direct HIẾM drops; Lv75 advanced Forge; grade upgrades; salvage/inheritance/auto allocation. Do not implement all 96 set recipes blindly at once with unregistered resources.
5. **Continual quality:** record SHA of code, real runner logs, save versions, actual item counts and authoritative receipts; only tests actually executed at exact source SHA can earn PASS, human UX approval separate.

**Final audit status:** 30 future fixtures listed, **0 executed**, **0 implementation authorizations**, **no QA claim**. No merge. The artifact is for owner rule choice and future small-scoped implementation planning, not instructions to start coding.
