# TÔNG MÔN BÁ ĐẠO — LUYỆN KHÍ V2 / ORDER 01: MỘT LỆNH RÈN ĐẾN KHO TÔNG MÔN
## Thiết kế giao dịch end-to-end, nghề, thời gian, reserve/debit, RNG một lần, phẩm thấp, Save/retry, item identity
**Ngày:** 2026-10-24 · **STATUS: OWNER REVIEW / DESIGN ONLY, NOT LOCKED NUMBERS NOR IMPLEMENTED**.
**Scope:** chỉ docs GitHub, nhánh `docs/forge-v2-transaction-rare-quality-qa-20261024` từ main `29b5fba448b0178cb520a4ada44b375b4b934e31`. Không code/test/packet Codex/PR29/UI/Source A/merge. PR29 OPEN DRAFT `9522812e91b7ca5bc0cc108eb92e000e930fe850` khi kiểm tra; giữ one-writer rule.
**Authority reading order:** current owner (HIẾM baseline **thử nghiệm** only) → `AGENTS.md` → `docs/GAME_SYSTEM_ARCHITECTURE.md` → `CURRENT_CHECKPOINT.md` → `NEXT_CHAT_HANDOFF.md` → `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md` → `docs/WEAPON_EQUIPMENT_V2_SPEC.md` → `docs/EQUIPMENT_SETS_V2_SPEC.md` → `docs/P3_7_{BUILDING_TREE,PROFESSION_WORK_MODIFIER,TIME_SPEED_COOLDOWN,RESOURCE_STORAGE_GROWTH_DATA_MODEL}_SPEC.md` and actual `godot/src/simulation/{equipment/equipment_system.gd,resource/warehouse_system.gd,resource/resource_registry.gd,building/building_system.gd}`. Previous docs `docs/gear-v2-basic-rare-24sets-camp-sources-20261024` and `docs/ttl-v3-rare-loot-three-profiles-gear-scaling-20261024`.
**Labels:** [LOCKED] explicit owner/canonical design; [SOURCE] real main code; [P] proposed architecture/parameter, not yet user-approved; [OPEN] needs decision or missing actual consumer; [QA PENDING] no run.

## 1. What the player should see vs who owns it
Player: chooses a legal `gear_template_id` / target slot / weapon form / equipment realm / target set piece if unlocked; selects one Luyện Khí Điện and an available crafter; preview shows **registered** inputs, current stock, stock reserved for other orders, simulated due tick, possible grade pool with honest source limitations; submits once; actual start consumes inputs; after real ticks, one Sect-owned unique item is available for assignment. Failed eligibility cannot consume inputs. Low-grade RNG result is still a real item in an honest order, not a fake “failed cast” popup.
Gameplay authority: one canonical simulation clock and job authority; warehouse is one `WarehouseSystem` plus future **in-warehouse per-order holds and pending transaction journal**, NOT a new inventory or second economy; equipment unique instance registry owned by SectState/persistent canonical object; UI is presentation-only. **The currently shipped P2** `EquipmentSystem` has ONLY weapon/armor/talisman and 5 old recipes; `WarehouseSystem` has registered ID checks, `reserve_min`/`locked`, atomic `consume_requirements` for a one-time actual call, `MAX_SAFE_STACK=9000000000000000`. It does **not** implement V2 per-order holds, 10-slot catalog, grade1..12 Forge or the proposed receipts. Do NOT label runnable.

## 2. Immutable content contract (potential future data schema)
~~~yaml
forge_recipe_v2:                 # PROPOSED SCHEMA, NO SUCH FILE IN MAIN
  recipe_id: forge_v2:basic_head
  definition_version: 1
  tier: basic                    # basic / specialty_monster / named_set / advanced
  required_forge_milestone: 1    # example: 1, 30 or 75 ONLY IF AUTHOR-APPROVED
  required_profession_id: forging
  output_template_id: gear_v2:basic_head
  output_slot_id: head
  allowed_equipment_realms: [1] # explicit content gate
  allowed_generations: [nhan]
  allowed_grade_pool_id: trial_forge_lv1_v1
  materials: {thanh_thiet: 1, linh_moc: 2}
  blueprint_id: null            # basic needs no invented blueprint
  base_duration_ticks: 12       # purely proposed balance input
  output_count: 1               # one unique gear per finished order
  safe_result_policy: one_valid_low_grade_item
  candidate_line_pools: [A,B,C] # only actual consumer-gated legal lines
~~~
- [LOCKED] Ten ordinary slots: `weapon, head, armor, cloak, bracers, gloves, belt, boots, pendant, ring`; +3 Phù +2 Pháp Bảo **separate and deferred**; weapon `quyen_sao` occupies `weapon` not `gloves`. All ordinary item realms `1..30`; 12 phẩm independent; no universal Mana/Accuracy/Evasion or fabricated stat.
- [LOCKED] Affix capacity by phẩm1..12 from canonical; maximum6 ordinary lines +2 rare **stat-only** conditional lines +1 initially empty Chân Văn slot at Chí Tôn. At most2 broad A-lines; unique affix ID per item; B/C must have real target skill/work consumer. Sets 24×4 with only6 permitted positions and 2/3/4 threshold, same generation; Hỗn Độn Thần-only.
- [P] Recipe is **targeted**: item family / slot / allowed equipment realm / legal ingredient list are known BEFORE starting. RNG only chooses output grade and legal line identities/values within approved template pool. **No random slot roulette on forging**, otherwise crafting to equip thousands is not controllable.
- [P] Recipe revision frozen per order; no player editing a queued/running recipe to reuse old material cost and obtain a new output. Existing `ResourceRegistry` item ID and recipe/blueprint referential integrity checked at queue and at start.

## 3. Proposed persisted order and journal
~~~yaml
forge_order:
  order_id: sect_uuid_or_monotonic_immutable_seq
  owner_sect_id: canonical_sect_id
  facility_instance_id: authoritative_building_id
  worker_disciple_id: canonical_disciple_id
  recipe_id: forge_v2:basic_head
  recipe_version: 1
  content_hash: recipe_and_pool_definition_digest
  output_template_id: gear_v2:basic_head
  slot_id: head
  equipment_realm: 1
  set_lineage_id: null
  generation: nhan
  intent: [selected_source, selected_weapon_form_or_none, auto_assignment_rule]
  inputs: {thanh_thiet: 1, linh_moc: 2}
  blueprint_hold_id: null
  materials_hold_id: order_id
  status: QUEUED|RUNNING|READY|SETTLED|CANCELLED|BLOCKED
  enqueue_tick: canonical_tick
  start_tick: canonical_tick_or_null
  due_tick: canonical_tick_or_null
  work_duration_snapshot_ticks: integer_or_null
  outcome_seed_key: canonical_save_seed_plus_order_id_and_recipe_version
  output_instance_id: null_until_frozen
  frozen_outcome: null_until_authoritative_resolve
  input_debit_receipt_id: null_until_started
  output_credit_receipt_id: null_until_settled
  completion_ack: false
~~~
This is **conceptual authoritative state** in existing sect simulation/save, not a second scheduler or proposed implementation class. No random ids from wall time, UI refresh or client request. For a one-person assignment, mark job as `FORGING` only when a legal work job is actually acquired; a queued order MUST NOT silently create two simultaneous active jobs. A different worker may be assigned before start by an owner-approved command with revalidation; once RUNNING snapshot identity preserved unless explicit pause/resume rules are separately authorized.

## 4. State machine / one canonical transition per event
| From → To | Trigger / guard | Economic mutation | Replay behavior |
|---|---|---|---|
| [none] → QUEUED | validated idempotency token; known recipe, worker, facility, positive registered inputs, valid blueprint/realm | create order ID and **per-order Warehouse hold** for needed inputs (not yet physical consume) while respecting `reserve_min`/`locked`/existing holds | repeat request token returns SAME order; never reserves twice |
| QUEUED → BLOCKED | worker missing, facility upgrading, One Active Job busy at start, source missing, reserve cannot be maintained | no debit, diagnostic; optional hold release under explicit policy | replay remains blocked; no item |
| QUEUED → CANCELLED | user/system cancellation **before RUNNING** | release its hold exactly once, keep stocks physically unchanged | second cancel no-op |
| QUEUED/BLOCKED → RUNNING | eligible worker takes ONE FORGING job; free actual processing lane; facility/recipe still legal; all holds revalidated | in ONE journal transaction: **debit actual Warehouse inputs exactly once**, release hold, snapshot time and grade pool/worker stat modifiers and start tick | replay sees input-debit receipt, no second charge |
| RUNNING → READY | `canonical_tick >= due_tick`, still valid job authority and chosen deterministic resolution policy | freeze random result (grade, lines, unique output ID) **once** in persistent record; no Warehouse credit yet | replay uses frozen outcome, not reroll |
| READY → SETTLED | one authoritative pending-delivery journal applied | insert precisely one unique Sect-owned gear instance, mark final receipt; profession EXP/wage only if existing authorized completion source and once | replay checks same instance/receipt, no duplicate |
| SETTLED → ACK | UI/auto-manager observes committed receipt | no new economic mutation, optional assignment distinct receipt | UI redraw/reload does not produce second copy |
| RUNNING → [paused] | injury/work state loss or facility unavailable according to future approved pause policy | **no refund or rollback of charged input**, no duplicate outcome; due tick handling deterministic | save/resume continues with same order and seed |
**PREFERRED policy proposal (requires owner approval):** hold at queue; debit at actual start; no gameplay RNG or item created before ready; after RUNNING there is NO refund/forfeit by cancel, instead **pause/resume or complete**. This is intentionally anti-abuse and user-friendly; if owner demands abort-after-start, design a separate deterministic one-time salvage/refund receipt with explicit caps rather than return all inputs plus keep an output. Failed pre-start checks ALWAYS release hold without losing materials.
**Important source caveat:** `WarehouseSystem` today supports resource policy `reserve_min` and per-ID `locked` but NOT dynamic per-order holds. The hold/journal additions are future authoring requirements; do not use a Dictionary outside Warehouse as a competing stock authority. Available=physical quantity−policy reserve_min−sum(valid per-order holds), honoring locked=0. When hold is claimed for its own start, double subtraction must be avoided; subtract EXACTLY the held quantity from real stock atomically, release only that hold. Registered IDs must pass one safe-int check. Avoid negative stocks / capacity fiction: Warehouse stacks are logically unbounded but integer-safe, individual gear stored by unique instance identity.

## 5. Forge jobs, real time and profession, no imaginary second timer
- [LOCKED] One Active Job: cannot farm monsters, mine and forge simultaneously. Facility has worker slots by building authority; WORKER SLOT COUNT != proven independent furnace processing lanes. **Number of concurrent actual work orders/queue throughput is OPEN**; UI may show a queue but not invent parallel lanes. Sect State scheduler is source.
- [LOCKED] Work speed distinct from walking, basic attack speed and skill cast speed; profession Level factor `1+0.01×Level` (0→1.0, 100→2.0, 1000→11.0), not both a speed multiplier AND identical output-per-cycle multiplier. Profession talent/Thông Tuệ influences EXP as authored; don't let “thiên phú luyện khí” silently add unrelated rare probability.
- [P] Duration snapshot at START using actual work-speed channel: `duration_ticks=max(1, ceil(base_duration_ticks / canonical_effective_work_speed))`; optional separate travel/logistics component if existing real source. Example basic `base=12 ticks` at Lv0 gives12; at level100 (speed×2) 6, PROVIDED no other modifiers. Lv30 specialist example24; Lv75 example48. These are *experiments*, not implementation or guaranteed exact real time. Start/due ticks persisted. On pause, choose documented `remaining_work_ticks` vs unchanged due tick AFTER owner decision; freeze simulation progress while paused, never give free progress by merely unassigning.
- [P] Work output is exactly one genuine item per completed order (unless new explicitly authored multi-output recipe, none here); capacity/headcount affects number of legitimate work orders, not multiplied output from the same worker speed. EXP and wages credited on committed receipt, never during UI preview. Daily pill/CARE remains separate.

## 6. RNG snapshot and grade roll — input facts vs proposals
- [P] At start, freeze recipe_version, legal conditional grade vector/affix pool, equipment realm/generation, actual worker+facility eligible bonuses, and persistent seed. At READY draw deterministically using stable `canonical_world_seed, order_id, recipe_version, outcome_category` namespace separated for grade, normal lines, rare stat lines, base stat values and special capacity. Persist outcome BEFORE credit; no reroll after reload, worker reassignment or failed Warehouse delivery.
- [LOCKED] Grade caps EXACTLY as `WEAPON_EQUIPMENT_V2_SPEC`; grade=12 only opens a **single EMPTY potential Chân Văn slot**, never automatically inscribes special action. Set pieces modify existing stat channels only; no extra skill, summon/reflect/heal action from rare affix.
- [P] Level1 basic: exact output grade1 **100% as first vertical-slice** preferred; alternatively later a bounded grade1–2 pilot for starter recipes is an explicit owner choice, not automatically launched. Lv30 selected recipe: category-dependent grade1–5, Lv75 advanced grade2–8 when registered source allows, no 9–12 by gambling in this starter map. Distributions, worker bonuses and failures are proposals in companion `docs/research/TMB_FORGE_V2_PROPOSED_GRADES_FAIL_KEEP_SALVAGE_INHERIT_BALANCE_2026-10-24.md`.
- There are THREE different failure concepts: **invalid request** = no hold/job/debit; **blocked start or delivery** = retry same order/seed, no extra debit; **quality under target** = still one valid lower-grade item after paid real work, not loss of all ingredients or sudden high-grade substitution. Grade1 item is valid; a “critical forge failure destroys item” is NOT approved and recommended OFF in early game.
- An explicit “requested minimum grade” must NEVER mean retry behind scenes until success. Display `chance of grade>=k` as a preview; the forge attempt uses one trial and can result below that target. No hidden pity or choose-best-of-N bonus until owner approves consumer/economic impact.

## 7. Worked real-looking examples — all DESIGN ONLY
### E1: Beginner Head item (Lv1 Forge, registered inputs)
Template `gear_v2:basic_head` Thanh Thiết Khôi, slot `head`, item realm1, Nhân, grade1, `thanh_thiet×1 + linh_moc×2`. This ingredient IDs are currently registered. Worker `forging profession` available, Lv1 hall and one genuine lane assumed. Queue makes an isolated hold; start debits1 ore/2 wood once, duration12 ticks at Lv0 example; due roll guaranteed grade1 (owner proposal). Settle outputs ONE `item_id` Sect owned, assign afterward; crash at any boundary repeats zero or one transition, never gives free helmet or removes resources twice. No four-set tags, no Chân Văn, no extra combat skill.
### E2: Specialist Thủy Tinh Uyển (Lv30 proposal, monster item source PENDING)
`forge_v2:ttl_thuy_tinh_uyen` `bracers`, `ttl_thuy_tinh_giap×1 [NEW] + ttl_thuy_vu_tinh×2 [NEW] + tinh_lang_bi×1 [registered]`, item realm1 allowed; owner previously accepted direction but did not lock this recipe. If new item ID not actually registered → **BLOCKED/no inventory mutation**. After registration & proper source, a Lv30 legal Forge produces exactly one bracer in allowable conditional grades1–5; any additional profession grade luck needs explicit consumer. Does NOT produce an ice shield independently.
### E3: Hộ Sơn Quan named set piece (Lv30 F30 proposal)
The canonical set piece exists as **name+slot**: `Hộ Sơn Quan/head`, Hộ Sơn family [S0] in 24×4 matrix. Proposed source material C12 Thạch Bì Thú [NEW] and piece blueprint; no actual blueprint ID/recipe yet, so **not craftable today**. When owner authors `blueprint_v2:set:ho_son:head` and concrete `forge_v2:set:ho_son:head`, the blueprint+registered ingredients are held/debited once; output must carry valid `set_lineage_id=ho_son`, slot=head, generation=nhan and a legal grade. Set2/3/4 bonus only from multiple real equipped distinct positions; single helmet never creates shield or guard active skill.
### E4: Elite/Boss item not forged at will
A rare Hắc Lang Vương [Nether] event is one world actor, one loot pool. Its `HIẾM 8.75% gear-event` is drop-authoring probability from a unique death, NOT one `forge_v2` recipe probability. Forging cannot claim Boss material unless actual Boss drop/registered consumer exists; `ttl_hac_lang_vuong_hon_tinh` still DEFERRED. Direct elite/Boss item and manually forged item share Sect unique gear registry, but separate receipt/source types.

## 8. Design boundary for later Forge ROADMAP packages
**Order 1 (this doc):** forge-create stable state machine, recipe choice, worker, time, grade, Warehouse, unique output. It intentionally does NOT “complete all nine upgrade phases” in one shot.
- Order2 Cường hóa [OPEN]: equipment upgrade level cap/ingredients/failure not locked; no silently choose +15 or +30.
- Order3 Tinh luyện / tẩy [OPEN]: roll single existing affix strength vs reroll affix identity, different snapshot transactions; cannot add incompatible stat/new action.
- Order4 Thăng phẩm [OPEN]: changing item grade after fabrication requires separate receipt, source material, risk policy and ensuring no lower-grade secret loss. **Recommended** non-destructive owner option: failing leaves the ORIGINAL item/grade/affix unchanged while consuming a clearly quoted one-time attempt fee; other return-of-fee option evaluated in companion, no repeated RNG via save. Not approved yet.
- Order5 Thăng realm [OPEN]: must not use 100 rat skins to elevate Nhân gear to Thần. Crossing 10→11/20→21 needs real higher-generation resources/blueprints/tech, never preserve mixed-generation set4 bonus.
- Order6 Salvage/inheritance [OPEN]: destructive move-or-convert with one source tombstone and one destination instance or material receipt, never transfer100% investment while also keeping original.
- Order7 Chân Văn [OPEN]: separate rare, registered item inscription event, no free Chí Tôn skill.
- Order8 Loot/content and Order9 auto-allocation still dependent on true equipped-role/multi-disciple source gates and batching, not authorised as runtime by this design.
Companion documents cover numerical experiments, blueprint provenance, and future QA only.
