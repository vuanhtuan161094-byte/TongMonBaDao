# TÔNG MÔN BÁ ĐẠO — LUYỆN KHÍ V2: 12 PHẨM, NGHỀ, GIÁ THÀNH, THẤT BẠI, PHÂN GIẢI VÀ KẾ THỪA
## Cấu hình HIẾM để thử; không khóa tỷ lệ và không sửa gameplay
**Ngày:** 2026-10-24. **STATUS: RESEARCH+PROPOSED, NOT OWNER-LOCKED, NOT IMPLEMENTED, NO CODE/PR29/UI/SOURCE A/MERGE.**
**Companion transaction:** `docs/design/TMB_FORGING_V2_END_TO_END_TRANSACTION_BLUEPRINT_FACILITY_2026-10-24.md`. **Source catalog** from `docs/gear-v2-basic-rare-24sets-camp-sources-20261024` and HIẾM from `docs/ttl-v3-rare-loot-three-profiles-gear-scaling-20261024`. Canonical `docs/{WEAPON_EQUIPMENT_V2_SPEC,EQUIPMENT_SETS_V2_SPEC,EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP,P3_7_PROFESSION_WORK_MODIFIER_SPEC,P3_7_TIME_SPEED_COOLDOWN_SPEC,P3_7_BUILDING_TREE_SPEC}.md`, actual WarehouseSystem/EquipmentSystem/ProfessionModifierSystem. All numbers with [P] are test parameters, not code facts.

## 1. Two orthogonal axes, one legal item
- [CANON] `equipment_realm_index=1..30` (Nhân1–10, Tiên11–20, Thần21–30) is the required item cultivation tier. Item quality `grade=1..12` is independent. A grade12 realm1 can't bypass realm21 battle progression.
- [CANON] Grade metadata and maximum affix capacity:

| Phẩm index | Tên | Max normal lines | Max rare conditional-stat lines | Empty Chân Văn slots |
|---:|---|---:|---:|---:|
|1|Phàm|0|0|0|
|2|Tinh|1|0|0|
|3|Thượng|2|0|0|
|4|Cực|3|0|0|
|5|Linh|3|0|0|
|6|Huyền|4|0|0|
|7|Địa|4|1|0|
|8|Thiên|5|1|0|
|9|Vương|5|1|0|
|10|Thánh|5|2|0|
|11|Đế|6|2|0|
|12|Chí Tôn|6|2|1|

- [CANON] Ordinary-stat A pool at most **2 broad A lines per item**; B=valid skill/path/element conditions; C=work/cultivation content with real consumer. Cannot roll duplicate identical affix IDs, phantom Dodge/Mana/Threat/copy attack, free shield/heal proc or equipment-set Chân Văn. B/C lines must check actual target skills/job consumers and source. Chân Văn is separate inscribed mechanism not granted by grade12 itself.
- [CANON] Set 24×4 pieces only from `head,armor,cloak,bracers,belt,boots`; 2/3/4 cumulative, one generation; weakest realm of contributors controls tier benefit. Four-piece set is distinct from ten-slot outfit.

## 2. Proposed Forge quality RNG at Lv1 / Lv30 / Lv75
**Proposed policy**: a correctly accepted Forge V2 order *always* resolves into exactly one item of the selected template/slot (no 20% vanishing finished item). **Rarity lies in what grade/lines the legal material, blueprint, Forge milestone and skill allow**, while optional grade-upgrade attempts are distinct later actions. Auto-forge grade doesn't inherit HIẾM monster-drop probability; **HIẾM** controls direct monster loot, while Forge probabilities must be modeled as an alternative material/time sink.
**PILOT parent:** earlier Lv1 basic had proposal 80/18/2% for grades1–3. But newest 10-slot BASIC output idea promises neutral grade1 and 0 lines; to avoid a silent conflict, **this study recommends Lv1 specifically fixed grade1**, only for basic starter recipes, leaving 80/18/2 an unused alternative for a future higher-cost basic premium recipe. This is NEW PROPOSAL, not a retroactive owner lock.
**Lv30 specialty original parent suggested 60/26/10/3/1 for grade1..5; preserve exactly as existing experimental starting vector.**
**Lv75 advanced candidate new vector 20/32/24/14/8/2 for grade1..6** (100%) is explicitly a **new [P]** not present in canonical, only if adequate advanced blueprint+qualified worker+material source have been registered. This does not guarantee Chí Tôn or grade7+.

| V2 quality (all12) | Lv1 starter [P] | Lv30 specialty [P previous] | Lv75 authorized advanced [P new] |
|---|---:|---:|---:|
|1 Phàm|**100%**|60%|20%|
|2 Tinh|0%|26%|32%|
|3 Thượng|0%|10%|24%|
|4 Cực|0%|3%|14%|
|5 Linh|0%|1%|8%|
|6 Huyền|0%|0%|2%|
|7 Địa|0%|0%|0%|
|8 Thiên|0%|0%|0%|
|9 Vương|0%|0%|0%|
|10 Thánh|0%|0%|0%|
|11 Đế|0%|0%|0%|
|12 Chí Tôn|0%|0%|0%|
|**Sum**|**100%**|**100%**|**100%**|

**What zero means:** in THESE starter/specialty/advanced recipe profiles grade7–12 NOT eligible. The canonical 12 grades exist globally, and TTL HIẾM monster loot can yield grade7 from appropriate Nham Elite and grade8 from valid Boss source. Future named exception/Chí Tôn content or advanced grade promotion can be authored separately with source, realm, costs, probability and true gate; NOT inferred from Lv100 alone or a luck stat.
**Output randomness algorithm [P]:**
1. Validate real recipe+output template+realm/generation and authorable grade set BEFORE any roll; selected slot and family never random (player knows what they are forging).
2. On completion use per-order stable `seed, recipe_version, quality_profile_version`; select grade with sorted cumulative integer weights (per10,000 basis points preferred) and no float boundary ambiguity, one primary quality draw.
3. Generate actual base stats deterministically by equipment realm/template; then apply grade max normal/rare capacities and legal affix source pool. **Max** capacity does NOT always mandate every possible line filled; exact number per grade and line magnitude distribution still OPEN.
4. Reroll based on worker gear/equip/root after order completion forbidden: freeze worker/validated modifiers at job start; no new global work-speed quality bonus.
5. Any declared grade probability whose eligible template/line source is absent makes order fail validation, never lazily replace it with phantom gear. If non-instrumented RNG callback fails after due tick, freeze to PENDING_RESOLVE and retry same seed/receipt without time benefit.
**CANON grade cap:** Lv75 candidate grade6 can have 4 normal lines and 0 rare special-stat lines; even high paid Forge cannot grant a new skill by field name.

## 3. PROFESSION speed / talent and time [source vs pilot]
**CANON source `P3_7_PROFESSION_WORK_MODIFIER_SPEC`:**
- Profession level `floor(sqrt(profession_xp/24))`; speed factor `1+.01×level`.
- Generic `work_speed` traits/additives and facility actual multiplier on time only, don't also multiply completed item count. No new profession yield multiplier.
- Luyện Khí talent Grade1..5 grants **profession XP gain +5/10/15/20/25%**, not chance to Chí Tôn. True Cơ Duyên luck tiers may affect explicitly authored *one* rare quality check later, not raw percentage multiplying every grade outcome; omitted in test tables.
- Lục Duy work affinity and local Linh Căn can modify only compatible content where actual tags authorize them; no generic rare quality exploit or universal forge efficiency.
**Prototype durations** preserve parent values when available:
| Order type | Suggested base action ticks [P] | Prerequisite |
|---|---:|---|
| Ordinary neutral/basic ten-slot|12|Lv1 basic Forge, registered `linh_moc/thanh_thiet`, legal forge worker|
| Ten specialist named monster material outputs|24 (Ngũ Hành Ngọc36)|Lv30 Forge and registered seven new materials|
| Low-rank positional named set piece |24|Lv30, explicit named blueprint source and each authorized set piece |
| Advanced positional set piece |48 [NEW P]|Lv75, authored material tier/blueprint/consumer|
| Grade upgrade/refine/disassembly/inheritance |TBD|separate future contract; no instant automatic operation authorization|

**Per-order resolved work time:** `ceil(base_action_ticks / valid_worker_work_speed_snapshot)` in canonical sim ticks, with construction/logistics/movement explicitly separate if authored. Example: Lv50 profession factor1.50 with otherwise1.00, base24→16 active ticks; Lv100 factor2.00, base24→12 active ticks. A 12-tick Lv1 order with Lv50→8 active ticks. These are *arithmetic examples*, not currently implemented Forge/worker QA. One Active Job prevents same worker mining and forging simultaneously; Injury 120 and pause prevents hidden production. No different wall-clock vs tick formula or bonus output generated when fast-forwarding.

## 4. Resource bill and 30/1,000/3,000 workforce feasibility
**Parent proposed basic kit ten outputs** uses exactly `thanh_thiet×15 + linh_moc×21` for one disciple's 10 ordinary gear positions. The identifiers are registered; the ten V2 recipe IDs are NEW design and not executed in current EquipmentSystem. Demand **only if every person needs one new full10-slot kit**, before salvaging/hand-me-downs:

| Roster size | Unique items | Thanh Thiết required | Linh Mộc required | Sequential Forge days @1 lane/12 ticks and1440 ticks per sim day [P] | If 2 REAL lanes, ideal lower bound [P] |
|---:|---:|---:|---:|---:|---:|
|30|300|450|630|2.5 days|1.25 days|
|1,000|10,000|15,000|21,000|83.33 days|41.67 days|
|3,000|30,000|45,000|63,000|250 days|125 days|

**Not observed throughput.** `1440 ticks/day /12 ticks/item=120 items/day/lane` assumes uninterrupted work, work speed1, no travel/upgrade/job switches, available inputs, no failure and that one valid worker/craft lane exists. `P3_7_BUILDING_TREE_SPEC` has default craft-building worker slots Lv1=2, +1 per10 levels; **worker slots are NOT proof of 2 independent functioning Forge lanes**. This last column is purely conditional; if throughput is shared work queue/worker contribution, use true implementation before counting parallel capacity.
**Important economy:** prior owner proposed Mine10,000 and Forest8,000 resources/hour at some x100 production settings, but main existing Economy-A pilot has smaller level1 batch output; no verified live mine/forest rate justifies assuming all 45,000/63,000 inputs instantly available. Mine/Forest/Field production, worker One Active Job, construction, personal meds and P3.7 wages compete for labor/materials. Guard reserves must honor emergency/upgrade inputs before auto batch forge.
**Expansion strategy [P, not a new 3,000-actor on-map allowance]:** 30 deployed fighters prioritized first, then roster segmented by activity (hunting/professions/cultivation), equip only what legitimate consumers use, batch auto orders by missing slot and stock, and recycle/unassign lawful gear from inactive colleagues. Need an owner-authorized item allocation policy/quality threshold before auto manufacturing 30,000 low-grade pieces.

## 5. Failure, keep-grade, salvage and inheritance must be different operations
### 5.1 New Forge: zero null-output production risk [P proposed]
- A valid completed **CREATE** order always returns one real target template item **at some authored grade**. Low quality is a valid outcome, not a destroyed item. No separate black-box `P(success)` on top of grade draw. Low-grade output can be used, reassigned, or later salvaged. Initial/basic always grade1 with no lines; specialty/advanced have vectors above.
- If invalid materials/blueprint/worker/facility before acceptance: **reject without hold or debit** (not a game “failure”). If interrupted after acceptance: **PAUSED**, not an instant chance fail; repairs/reassign preserve progress per later authorization. If deterministic RNG cannot resolve, don't reroll and don't debit twice.
- This reduces softlock for beginners and lets rare *found gear* keep its relative value through affixes/set scarcity. Owner may later prefer irreversible Forge failure only for extraordinary content; not locked here.

### 5.2 Thăng phẩm (grade upgrade) / “Giữ phẩm”
- [PROPOSED preferred] upgrade target item is a **separate** unique-ID-preserving order, where input is an existing legal gear instance, author-defined upgrade materials/fee, attempted **one grade step** (`g→g+1`) with a **source/versioned chance still TBD**. If success, improve capacity only to legal grade; affix identity preservation and new empty slots must follow authored rules. If fail, **retain exact same gear instance, grade, existing lines, set identity and realm**, not delete item or downgrade quality. Pay committed fee ONCE if outcome failed, otherwise infinite free rerolls via cancel/reload.
- No numeric chance, hard +enhancement cap or upgrade cost is approved; **no shortcut grade1→12 from ordinary Linh Mộc**. The owner's earlier +15 enhancement example is NOT locked. Create vs upgrade probabilities must be tuned separately.
- A **reforge choice** (reroll a legal line identity/value) requires frozen alternate outcome and **one KEEP_OLD or ACCEPT_NEW decision** after spending the defined cost. If the player rejects an unfavorable roll they keep OLD only, never both variants; rejecting is NOT a refundable retry. Persist pending decision; save/reload cannot change the alternate.
- Special-stat lines do not turn into Chân Văn on upgrading. Max2 general A lines, rare stats are conditional filters to already-known actions; Chân Văn has separate authorized source/inscription step only when item is eligible grade12.

### 5.3 Phân giải (salvage) and sinks [P]
- Only a genuine Sect-owned **unique** item, currently not equipped/locked/reserved/under inherited transfer/assigned as future Forge target, can be salvaged. Persist selected `item_instance_id`, `salvage_recipe_version`, deterministic output and receipt. One atomic operation **removes that one item instance** and credits actual registered return materials **exactly once**.
- **No universal % of whatever original future rare materials**: salvage outputs must be from the explicitly-authored item's registered approved resource list, with `0 ≤ returned_quantity < consumed_equivalent` for at least one positive sunk resource along any easily repeatable craft↔salvage loop. No returned blueprint, no unregistered resources, no Chân Văn clone, no spiritual upgrade/extract by accident. A 25% common-input recovery is a possible sensitivity fixture only (not locked), with floor rounding and genuine nonzero costs if appropriate. Some cheap one-unit inputs would yield0.
- Looted gear without logged exact Forge recipe may use separately authorized salvage table by template/realm/grade; do not generate made-up material amounts from a guessed crafting history. Upgraded/inscribed rare items may require explicit disassembly eligibility confirmation rather than auto disposing by grade.
- **Economy invariant** for every repeatable path: `expected_value_of_salvage_returns - consumed_crafting_inputs - authorized_work/time/stone_cost < 0` under same resource units (or a strictly dissipative path), else Forge/salvage infinite material exploit. Resource value cannot be calculated just from a fictional universal Power.

### 5.4 Kế thừa (inherit/transfer) [P]
- Transfer from **one** existing Sect-owned `source_item_instance_id` to **one** existing `target_item_instance_id`, after validating equip legality, compatible slot/family/realm/generation, both unique IDs, locks, no concurrent use. Choose explicit *what may transfer* (e.g. a portion of legitimate enhanced-base investment or lawful lines) and cost/cap from future owner-approved compatibility matrix; **NOT** automatic grade12 or Chân Văn inheritance, nor arbitrarily converting Thần armor into Nhân ring.
- [Recommended] atomic commit consumes/destroys the SOURCE unique item, updates SAME TARGET identity/version once, consumes authorized transfer materials/Stone once, and records irreversible receipt. Gear of source cannot remain in another disciple's equipped slot; references must be fixed in same transaction.
- A failure due to **validation** leaves source/target and stock untouched. Future chance-based transfer success must be separately authored/settled deterministically; no hidden refund+retry. Item lineage/generation preservation, capped affix counts and set-size thresholds invariant post-operation. Never credit generic salvage plus full transfer investment from the same source unless explicitly rare subset/rate balanced and idempotent.

## 6. Typical full loop (future data, not runtime)
- 30 hunters farm 20 camps, true per-monster loot rolls at **HIẾM** rates; materials enter canonical Warehouse with true one-life receipts.
- Worker not hunting takes ONE Luyện Khí job in facility; player chooses ten-slot base recipe or unlocked set-specialist recipe, real inputs reserved.
- Canonical ticks produce exactly one frozen item with profession XP once, legal rarity/affixes; item stored Sect-owned; assign most useful candidate to eligible disciple or keep as spare. On later upgrade, keep old grade if failed (owner must approve costs); when replacing gear, unassign old item and salvage or transfer under explicit locks, never equip both.
- No Phantom Boss relic sink: proposed `ttl_nham_giap_hach` and `ttl_hac_lang_vuong_hon_tinh` still **DEFERRED** until a real named Forge/research consumer is authored. Grade9–12 and full Hỗn Độn Thần set cannot appear in low-realm Thanh Trúc Lâm source by assumption.
- The vast 1,000–3,000 Sect stock naturally fills from professions and a real Forge queue; rare hunts improve selected high-value item quality and sets, not "one random full gear item per disciple per kill."
**OWNER DECISIONS:** choose create guaranteed-item policy; approve Lv1 fixed grade1 vs legacy-proposed80/18/2; approve Lv30 unchanged prototype60/26/10/3/1 and Lv75 new vector as test only; define upgrade cost/failure grade preservation; salvage loss/return and inheritance compatibility before calling those mechanics LOCKED. See QA appendix for evidence gates.
