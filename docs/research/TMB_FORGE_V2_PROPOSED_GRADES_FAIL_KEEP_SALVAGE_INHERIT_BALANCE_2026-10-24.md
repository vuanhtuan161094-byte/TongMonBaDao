# TÔNG MÔN BÁ ĐẠO — LUYỆN KHÍ V2: RNG PHẨM 1–12, GIỮ ĐỒ KHI THẤT BẠI, PHÂN GIẢI/KẾ THỪA, QA EXACTLY-ONCE
## Numerical experiment, replay fixtures, economics + owner's decision gates
**Ngày:** 2026-10-24 · STATUS: **PROPOSED MODEL / DOCS ONLY / NOT LOCKED / NOT GODOT QA**.
**Inputs:** `docs/design/TMB_FORGE_V2_ONE_ORDER_AUTHORITATIVE_TRANSACTION_2026-10-24.md` and `docs/design/TMB_FORGE_V2_LV1_LV30_LV75_10_SLOTS_BLUEPRINT_24_SET_ROUTE_2026-10-24.md`, both same branch. Source: canonical `docs/{WEAPON_EQUIPMENT_V2_SPEC,EQUIPMENT_SETS_V2_SPEC,EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP,P3_7_PROFESSION_WORK_MODIFIER_SPEC,P3_7_TIME_SPEED_COOLDOWN_SPEC,P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC}.md` and real `WarehouseSystem`/`EquipmentSystem` in main `29b5fba448b0178cb520a4ada44b375b4b934e31`. Owner **HIẾM** loot remains **trial-only**, **not new in-game level and not locked**. No code/PR29/UI/Source A/Codex packet/merge.
**Source status separation:** [LOCKED] approved identity/caps/time/profession channels; [P] numbers and future code contract; [SOURCE] current P2 runtime; [PENDING] data/actor/source/QA not implemented. The Forge V2 implementation remains missing; do not call this a tested balance run.

## 1. Forge quality is NOT the per-monster HIẾM drop algorithm
- [LOCKED] grades: `1 Phàm, 2 Tinh, 3 Thượng, 4 Cực, 5 Linh, 6 Huyền, 7 Địa, 8 Thiên, 9 Vương, 10 Thánh, 11 Đế, 12 Chí Tôn`. Independently `equipment_realm_index` 1–30 with Nhân1–10/Tiên11–20/Thần21–30; player Tu Vi OR Body for allowed physical items, Tu Vi-only if spiritual, Body-only if explicitly body-specific.
- [P] A targeted *Forge recipe* has its own `allowed_grade_distribution` tied to facility/registered materials/blueprint/worker and equipment realm. A *monster kill* has per-species `HIẾM P(gear_event)` and separately conditional grade distribution from prior loot doc. **Do NOT multiply HIẾM loot event chance into Forge success; do NOT allow crafting bypass of authored grade9–12 exceptional sources.**
- [LOCKED] Affix ordinary/rare/Chân Văn capacities follow exact Equipment V2 table. At grade1 no ordinary/rare/chân văn. Grade2 one ordinary; grade3 two; grade4 three; grade5 three; grade6 four; grade7 four+one rare conditional stat; grade8 five+one rare; grade9 five+one rare; grade10 five+two rare; grade11 six+two rare; grade12 six+two rare+one **empty inscribable** individual Chân Văn capacity. No automatic new skill/proc or Chân Văn from grade, set or ordinary affix.
- [P] Treat rolls **only after** valid recipe/source/registered template, quality distribution defined and worker/facility min constraints met; cumulative integer weights fixed and versioned (e.g units basis point/bps where .1%=10bps), exactly sum10,000 and never floating rounding outside accepted version. Named luck or profession bonus may be added LATER to a versioned authored distribution; no silently free stacking.

### 1.1 Explicit twelve-grade FORGE distribution matrix (per completed valid order, numeric PILOT ONLY)
| Grade index/name | Basic Forge Lv1 neutral | Specialized Forge Lv30 proposed | Advanced Forge Lv75 proposed |
|---|---:|---:|---:|
|1 Phàm|**100%**|**65%**|0%|
|2 Tinh|0%|25%|**45%**|
|3 Thượng|0%|8%|27%|
|4 Cực|0%|1.8%|16%|
|5 Linh|0%|0.2%|8%|
|6 Huyền|0%|0%|3%|
|7 Địa|0%|0%|0.9%|
|8 Thiên|0%|0%|0.1%|
|9 Vương|0%|0%|0%|
|10 Thánh|0%|0%|0%|
|11 Đế|0%|0%|0%|
|12 Chí Tôn|0%|0%|0%|
| **Sum** |**100%**|**100%**|**100%**|
**Interpretation / no hidden locks:** Lv1 template deterministic grade1 guarantees everyday basic usability, not powerful affixes. Lv30 named specialist can be grade1–5; Lv75 advanced named set can be grade2–8 at the pilot source rank, **NOT “every Lv75 forge automatically grade8”**. This grade8 eligibility already presumes specific authorized advanced materials, blueprint and item tier; if not present, **BLOCKED** rather than roll from unregistered pool. Grade9–12 still available in full V2 but sources/forge rules are absent for TTL: **P=0 in these three prototypes ONLY**, not a blanket ban outside region/future; higher Forge Lv100 does not auto-add them.
**Check arithmetic:** Lv30 grade≥4 chance `1.8+0.2=2%` per completed eligible order; Lv75 grade≥5 chance `8+3+0.9+0.1=12%` and grade8 chance `0.1%` conditional on valid source. One hundred Lv75 attempts hypothetically generate **0.1 expected grade8** if the same advanced recipe is legally repeatable; without real blueprint and material supply this does NOT imply100 actual rolls. Values are [P] numbers, not game benchmark.
- [P] Begin with **grade1 guaranteed at Lv1**, do not add lucky starter Tinh grade just because earlier proposal mentioned a 95/5 possibility. If owner later desires alternate Lv1 distribution, it is a NEW version and needs balance review.
- [P] Facility and actual profession increase work throughput per canonical `1+0.01×level`; proposed advanced-grade distribution independent of raw profession level until specific quality modifier source is approved. No proficiency-based free rare item roll and no “reroll 10 times for best result”.
- [P] Grades2–8 conditional normal stat pools must validate A/B/C eligible consumers at item instance resolution; legal strongest roll doesn't allow forbidden triple general A, universal Mana, hit/evasion, reflect or proc recursion. 4-piece lineage from real distinct positions and generation, minimum item realm among four governs tier-scale threshold.

## 2. Failures and player-value policy: THREE separate cases
| Failure event | Recommended behavior | Warehouse/job/outcome |
|---|---|---|
| Validation cannot start: unknown recipe, missing blueprint/material ID, locked resource, missing Forge/worker/realm | **BLOCKED, no debit/no item; queued hold released on cancel** | record reason, no XP/grade roll |
| Real completed create-order, RNG lands low grade | **SUCCESS at rolled grade; always one valid item** for these prototype recipes | all charged materials legitimately consumed once; one unique instance; never destroys complete order with nothing |
| Transient save/serialization/Warehouse insertion failure after grade roll | **RETRY same frozen output** without re-debit/re-roll | state READY pending, durable content hash/id; no fake zero-output completion |
| Separate later `thăng phẩm` attempt fails | **retain original exact item instance and original grade/stats/affixes/locks**, no downgrade/destroy [P preferred] | resource fee consumed **once** only if real attempt started, one immutable attempt journal; no Ctrl+Z reload cheat |
| Separate later `cường hóa` attempt fails | NEED **owner approval** of cap/loss/fee; default safe prototype recommendation **keep existing level** [P], not old +15 cap | input debit/receipt once, original item unchanged except explicit ledger |
| Post-start user presses cancel | **no full refund AND output**, recommend pause/resume only | job retains charged materials; future abort/refund needs an independent one-time compensating receipt |

Avoid word **“guaranteed rare”**: guaranteeing one **valid basic item** from a legal Forge is not granting desired phẩm or set piece without its blueprint. Don't claim failure policies implemented. A low grade outfit may be useful for junior roster even when Boss squad has better; allocate to right role rather than auto-salvage immediately.

## 3. Salvage / inheritance: propose transactional design while preserving canonical ordering
Per Forge roadmap, refinement/inheritance/salvage are later packages after basic create-order. Here only define invariant-safe design and **trial** economics; do not call final recipes, success rates or CODE authorized.

### 3.1 PHÂN GIẢI: one source item destroyed, eligible material recovery, no dupe
- Validate Sect owns `item_instance_id`, in Warehouse or unequipped in authorized transaction; not reserved/locked/assigned in combat/forge, no 2/3/4-set critical item unless user explicitly confirms break. Item came from actual recipe/loot with record; material source reward must exist.
- [P] **Candidate trial recovery: 25% of EACH registered base material actually consumed by that item's original create-order (integer floor per material ID, maximum input paid)**; no recovery of spent registered blueprint license, named Boss manual, Chân Văn, skill, rare source essence or Spirit Stones unless separately authored. A dropped monster item without a genuine original-material input receipt uses an **independent registered salvage table or NO SALVAGE**; never fake its ore cost. A full10-slot basic kit inputs Ore15/Wood21 → this trial recovery yields at most **3 ore+4 wood if pooled before rounding**, but actual per-item floor will generally yield *less* than that. DO NOT pool rounding across individual items to create fractional arbitrage.
- Item is *tombstoned* exactly once and any output stacks deposited once in same canonical transaction; no resurrect-on-reload after salvaging and no repeated material credit. Cross-role inherited hand-me-down may be more valuable than immediate salvage.
- **Strong anti-arbitrage invariant:** total recovered input quantity per item cannot exceed quantities debited on that original order; 25% trial keeps sink net positive even with infinite remakes. If owner chooses different percentages by grade/item realm, require economic proof source/sink per 1/7/30sim-days. Avoid salvaging an item with no valid provenance into fictitious endgame seals.

### 3.2 KẾ THỪA: no source survives a full copy
- Validate **two distinct real Sect-owned item IDs** source and destination, both safely unequipped or atomic reassignment, same compatible equipment slot and realm/generation rules, no cross Nhân→Thần loophole, neither reserved/locked, no missing material.
- [P] Eligible source upgrade track may be *moved* (not cloned) to destination after a real recipe/cost; one atomic receipt, original source tombstoned and destination retains only **legal** stats/limits for its own actual phẩm. If destination already has unrelated investment, require choice+preview conflict resolution. No new generic realm-power multiplier, no Chân Văn transfer until independently approved Chân Văn rules/consumer.
- Original source no longer exists as assignable gear after success; previous Sect Warehouse stock and assigned pieces checked. On failure, neither piece or source investment disappears under preferred "keep" policy, except separately clearly authorised one-time attempt fee. Source and destination IDs cannot be same; duplicate request token/reload idempotent.
- Set tags don't transfer just by moving investment: destination must be AUTHORED set family/position, no arbitrary non-set ring made into Hộ Sơn head. Crossing different generation cannot create 4-piece set, and replacing one of four must account for threshold impact.

### 3.3 Refinement/grade/realm upgrade intentionally NOT finalized
- `Thăng phẩm` per-attempt formula, cost, max grade change, retention protection **OPEN**; suggested owner trial: spend upfront known materials for +1 grade chance in declared eligible source band, failed attempt keeps grade (not high-price result); no amount chosen here until material markets and Forge output are measured.
- `Thăng realm` 1..30, gaps Nhân→Tiên→Thần use registered higher-tier inputs and legal profession/facility capabilities, cannot transmute cheap TTL `linh_moc` into Thần gear via repeat pressing upgrade. Enhancement cap unknown; do not declare +15 or +30 locked.
- `Tinh luyện` raises a line value on valid pre-existing line; `Tẩy luyện` rerolls allowed identity with lock policy (stat pool A/B/C, no duplicates, at most2 A). No magic Chân Văn via either one.
- [P] For very large Sect, inherited generic armor and salvage old uncared-for extras should be a meaningful sink; **all gear remains Sect-owned**, storage unlimited in counts subject to safe integer and unique item identity. Auto-equipping still may not break a completed 4-piece set for a tiny individual-score gain.

## 4. End-to-end economy / throughput: one map30 deployed vs Sect1k–3k
Use OWNER's previous **HIẾM rare monster gear baseline** as external **sim trial only**: one continuous TTL map, 30 deployed, 20 camps×10–20 monsters; assumed normal kills360/h, Elite3/h, Boss0.25/h gave `E[rare gear]=0.297425 events/sim-hour` and ~214.15 gear events/30sim-days. That is **not** Forge output. For basic outfits, 10 pieces per disciple (300 for30, 10,000 for1k,30,000 for3k).

**Synthetic Forge trial conditions**: One `legitimately active` item order processed at a time by one lane, Lv0 forging speed1.0, no gaps, each Lv1 basic item exactly12 canonical ticks, 1440ticks=1simday. Multiple workers per building does NOT prove multiple active crafting lanes, so K=4 is hypothetical scenario only. No injury/travel/absence/missing materials/Forge building upgrade time, no duplicate protection overhead and no different weapon variant price modeled.
| Sect members each receiving one NEW basic 10-piece outfit | Required crafted item count | Source `thanh_thiet` | Source `linh_moc` | Min sim-days K=1 / 12ticks/item | Hypothetical K=4 lanes |
|---|---:|---:|---:|---:|---:|
| ONE TTL deployed team30 |300|450|630|**2.50d**|**0.625d**|
| Sect roster1000 |10,000|15,000|21,000|**83.33d**|**20.83d**|
| Sect roster3000 |30,000|45,000|63,000|**250.00d**|**62.50d**|
With profession level100, speed factor×2 could halve **duration** if no other modifier and if legit job, but must NOT also double items per completed order. Number of Forge facilities and parallel processing pipelines is **NOT code verified** and cannot be presumed. Insect boss/world spawn count is NOT craft count.

**Specialist ten-output recipe trial:** `10 ticks` first basic specialist, `24 ticks×8` other, `36 ticks` Ngũ Hành pendant → `238 base ticks` to forge one of each. At speed1, a one-lane uninterrupted sequence would take ~0.1653sim-days per hypothetical specialist 10-kit, thus30 fully specialist outfits ~**4.96 sim-days of pure work**,1k ~165.28days,3k ~495.83days — BEFORE new monster material rarity, resource scarcity, special worker, blueprint, actual allowed gear realm/grade, injury, set pieces or jobs. Hence Forge time alone is NOT a valid estimate for complete V2 named set acquisition.

### 4.1 Pricing and rare-grade inflation risk
- At Lv30 trial grade≥4 probability2% per finished eligible item; if 3,000 beginners each attempt specialist set one of ten slots, even 30,000 orders might statistically produce600 Cực-or-higher **IF** true source and economic material are sustainable; it isn't a grant. Grade5 chance0.2% conditional, no Lv30 grade6+ in that proposed vector. Uniformly producing recipes at zero material cost would bypass rare hunting; never set free input or automatic quantity bonus.
- Lv75 trial grade≥5=12% of **genuinely valid advanced work**. This is a separate controlled economic sink; if advanced blueprints/materials become too common, high-grade supply can dwarf the `HIẾM` monster drop source. **Cannot lock** these Forge grade curves before measuring real working resources, duration, Forge capacity, named blueprint scarcity and viable source consumer.
- `HIẾM` gear events per kill are unaffected by worker grade or Source A VFX. Physical drops into Warehouse and Forge outputs both produce one unique instance and separate source-specific receipts, and both compete for equipment assignments. Item grade12 not available by this three-prototype Forge map alone; it remains an authored high-rank source opportunity, NOT globally banned.

## 5. Focused QA design fixtures, evidence status PENDING — NO RUN
| Case | Setup | MUST ASSERT; otherwise reject ForgeV2 |
|---|---|---|
| F01 | 10 basic recipes / neutral slots | exactly10 distinct slot IDs, all ingredient IDs registered; no Phù/Pháp Bảo or old talisman conflation |
| F02 | choose `weapon=quyen_sao` then `gloves` basic | weapon requirement checked vs equipped skill; Quyền Sáo doesn't occupy gloves |
| F03 | two taps/duplicate request token while QUEUED | exactly one order ID and one per-order Warehouse hold; no double reserve |
| F04 | two orders competing for last available `thanh_thiet` with `reserve_min` set | at most one valid hold; quantity nonnegative, locked resources unavailable |
| F05 | worker already has active HUNT job, or injured120 | cannot start FORGING second active job; no input debit; no fake queued elapsed work |
| F06 | facility below required Lv30 or Lv75; content marked DEFERRED | fails closed with reason; no material debit, no grade roll, no phantom set piece |
| F07 | worker eligible, order starts | exactly one Warehouse material debit+receipt; after save/reload before/after debit still one charge |
| F08 | head template12 ticks and profession Lv0 vs Lv100 | duration uses canonical job speed and frozen start value; no doubled output / repeated profession EXP |
| F09 | queued cancel before start, then retry cancel | release hold once, no debit/XP/item; same token won't instantiate another order |
| F10 | RUNNING pressed cancel, worker injured or Forge disabled | no input refund+item duplication; pause/resume outcome with same deterministic order ID/seed |
| F11 | save after due tick, before deterministic resolution | exactly one frozen grade/affix/item-instance ID upon retry; no reroll based on UI or wall time |
| F12 | save after grade but before output item credit | READY persisted, unique same item id on reload; one credit only |
| F13 | save after item credit before ACK and after ACK | exactly one Sect-owned item, no second Warehouse increment, no extra wage or profession XP |
| F14 | RNG boundary using integer bps10000 | each proposed grade vector sums100%; grade can only be eligible result and never forbidden grade9–12 in opening source |
| F15 | grade12 test on legitimate future source | max6 ordinary+2 rare stat lines+one EMPTY Chân Văn slot, not a free combat proc |
| F16 | named Hộ Sơn item/source/realm | exact four positions & lineage/generation, mixed Nhân/Tiên cannot complete; no “any four” set |
| F17 | item salvaged twice/reload between delete and material credit | tombstone once and one bounded registered material output; no resource arbitrage/duplication |
| F18 | inheritance source/destination same id, locked or different incompatible slot | rejected with no mutation; valid case tombstones source, destination legal, preserves other item locks |
| F19 | fail grade upgrade / cancel and rerun | one paid attempt with same success/fail frozen; failure keeps original grade/affix, no unlimited lucky retry |
| F20 | HIẾM monster drops vs Forge completion same tick | separate correctly attributed receipts, no `HuntingMapV2` finite victory/legacy forge material double payout |
| F21 | simulated 30 deployed/300 monsters and 1,000–3,000 roster inventory | number of actors on ONE map≤30 disciples, equipment stored Sect; batched allocation respects set2/3/4 and locks |
| F22 | actual Godot4.7.2/Windows8GB/Android1280×720 profilers | no “PASS” until real evidence: p95 tick/frame, queue time, save/replay, 200/300/400 monsters, 30 active hunters; docs numerical results aren't performance proof |
**Fixture snapshots**: before QUEUE hold; after QUEUE hold; after START debit; RUNNING near due; after READY outcome freeze; after SETTLED before ACK; after ACK; after SALVAGE tombstone; after INHERIT transfer. Run repeated app restarts for every snapshot and compare exact canonical item instance IDs, stock, job time, EXP, set status and receipts. Include deterministic same-build save; fresh DEV world after future gameplay-breaking version changes is user choice but does not waive within-version receipt correctness.
**Benchmark needs**: official Godot focused and affected cumulative when future CODE authorized, runtime Windows Godot4.7.2, actual 8GB device limits and Android landscape UI/visual separate. No test executed as part of this docs commit.

## 6. OWNER REVIEW decision register (none implicitly granted)
- **O1** Transaction semantics: queue hold; debit once at start; pause/resume after start with no cancellation refund; pending output idempotent commit. Approve or request refund alternative.
- **O2** Starter guarantee: Lv1 basic ten-slot recipes require grade1 only, one valid item/order; approves ingredient/unit counts `15 Thanh Thiết+21 Linh Mộc` per full kit as *trial*, not locked gameplay.
- **O3** Craft rarity quality: accept Lv30 `65/25/8/1.8/.2` and Lv75 `45/27/16/8/3/.9/.1` grade vectors **as model only**, or request slower/more rewarding curve after real material throughput. Grade9–12 remain content source-gated.
- **O4** Blueprint license: one valid initial blueprint discovery archived per Sect, re-usable legally by that Sect, duplicates for owner-approved research; alternative per-craft consumable blueprint may make3k-scale impossible. 24×4 exact piece IDs and sources are only proposals until audited.
- **O5** Later salvage: try 25% original *registered* material recovery floor per item or leave rate undecided; dropped item salvage requires separate authenticated table. No automatic rare-core/Chân Văn recovery.
- **O6** Later inheritance+thăng phẩm: failed attempts keep existing item/grade/affix (attempt fee charged once); source consumed on actual successful compatible transfer. Upgrade caps/material quantities still OPEN.
- **O7** Multi-worker/concurrency & batching: choose processing lane rule distinct from worker slots; do not assume four lanes/crafting while active HUNT. Benchmark actual jobs and Forge facilities before claiming timeline.
**Review order recommended:** approve O1 transaction→O2 basic item legality→O4 blueprint licensing→only then O3 quality and O5/O6 future upgrade economics→O7 throughput. No resulting decision authorises implementation without explicit CODE scope.
