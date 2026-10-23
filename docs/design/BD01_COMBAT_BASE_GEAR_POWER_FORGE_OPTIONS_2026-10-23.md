# TÔNG MÔN BÁ ĐẠO — BD-01: NỀN COMBAT, SỨC MẠNH TRANG BỊ, MỘT CHU TRÌNH RÈN THẬT

**Date:** 2026-10-23. **Status:** RESEARCH/PROPOSED OPTIONS, awaiting owner choice; **DOCS ONLY, no CODE/CI/FULL/MERGE**.  
**Branch:** `docs/bd01-equipment-deep-design-20261023`, based on `docs/tmb-master-completion-roadmap-20261023`, main inspected `29b5fba448b0178cb520a4ada44b375b4b934e31`. CARE PR #24 and Playable PR #25 remain stacked draft; do not touch their code.  
**Purpose:** The assistant does all design work; the owner selects only genuinely unresolved gameplay policies. The assistant must not send research workload back to Codex. Numeric choices marked `PROPOSED` do not become owner-locked just by being stored here.

## 1. Is another base-stat decision needed? NO — read later authority

**Source conflict reconciliation:** `docs/WEAPON_EQUIPMENT_V2_SPEC.md` Oct08 says RealmBodyCore numeric Attack/DEF/HP still OPEN. **SUPERSEDED BY** Oct09 owner approval in `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md` (filename is historical; status numeric V1 **LOCKED**), now implemented in `godot/src/simulation/combat/combat_stats_v2.gd` on main; `docs/COMBAT_STATS_V2_SPEC.md` points to this. Do **not** ask owner to select different core baseline and do **not** scale gear through Potential.

```text
G(r,f) = 1.65^(r-1) * 1.03^(f-1)
RealmCore(r,f): [HP=100, ATK=20, DEF=12]*G
BodyCore (r,f): [HP=90,  ATK= 3, DEF= 7]*G
PotentialCoreFactor = 1 + .0005 * CurrentPotential
Core = (RealmCore + BodyCore) * PotentialCoreFactor
TotalPrimaryBeforePct = Core + SUM(legal flat gear/other sources)
TotalPrimary = TotalPrimaryBeforePct * (1 + SUM(legal same-channel pct))
DirectHitDefenseFactor = (2*current_ATK)/(2*current_ATK + max(0,current_target_DEF*(1-valid_penetration)))
```

Examples **SOURCE-derived/no gear/no other buffs/Potential 0**:
- both 1.1: HP=190, ATK=23, DEF=19.
- both 5.1: HP≈1408.28, ATK≈170.48, DEF≈140.83.
- both 10.10: HP≈22472.12, ATK≈2720.31, DEF≈2247.21.
- both 30.10: HP≈502716344.62, ATK≈60855136.45, DEF≈50271634.46.
- Potential 1000 multiplies **core** by 1.5, never item +flat by 1.5.
- CombatStatsV2 has real channels `max_hp,attack,defense,move_speed,attack_speed,cast_speed,cooldown_recovery,crit_chance,crit_damage,crit_resistance,defense_penetration,effect_hit,effect_resistance,damage_reduction,lifesteal,lifesteal_reduction` plus authorized elemental resistance and scoped modifiers. Not every design-level filtered affix has a live consumer; conditional affixes must be consumer-gated.
- No invented Dodge, physical/magic split, second combat-power damage formula, free set skills, or gem currency. One legitimate HP-commit deals damage and optional lifesteal once.

**Do NOT lock all 30 gear tier values yet**: after this foundation, only gear **budget against these locked cores**, legal affix contributions, and forge economics are open. Exact monster/skill balance must be measured after pilot.

## 2. Already owner locked: item identity and constraints

- **10 ordinary equipped slots**: `weapon,head,armor,cloak,bracers,gloves,belt,boots,pendant,ring`.
- **Separate**: three `Phù`, two `Pháp Bảo`, and four quick-consumable positions: 15 equip/active +4 consumable positions. Phù/Pháp Bảo implementation is deferred, not deleted.
- **12 grades**, independent from item realm tier 1..30 and wearer progression 30 realms×10 floors; Chí Tôn has 6 ordinary lines + 2 special conditional stat lines + **one individual EMPTY Chân Văn capacity** (not a free proc). Grade order: 1 Phàm, 2 Tinh, 3 Thượng, 4 Cực, 5 Linh, 6 Huyền, 7 Địa, 8 Thiên, 9 Vương, 10 Thánh, 11 Đế, 12 Chí Tôn.
- **24 four-piece set lineages**, only six eligible positions `head,armor,cloak,bracers,belt,boots`; 2/3/4 bonuses cumulative; 3+3 for two eligible families can be active simultaneously; mixed human/immortal/divine generations DO NOT count as a unified lineage.
- All equipment instances belong to **Sect**, never personal title. The equipped disciple is assignee; transfer must obey locks and compatibility. `owner_id` in existing P2 save means equipped-user compatibility, not legal property.
- Luyện Khí Điện building design milestone: Lv1 basic forge+repair; Lv10 auto-repair; Lv20 materials refinement; Lv30 monster-material forging; Lv50 reforge/side traits; Lv75 advanced sets/special outcomes; Lv100 rare lines/mastery. These are designed capabilities, **not all currently working buildings in Godot**.
- Nine ordered forge design packages in `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md` are an approved *order* only: forging → enhance → refine/reroll → raise grade → raise realm tier → inherit/salvage → individual Chân Văn → loot economy → autoequip.
- P2 `EquipmentSystem.VALID_SLOTS=[weapon,armor,talisman]`, 5 sample instant-craft recipes, grades Phàm/Tinh/Thượng, `equipment_items` UID registry and purchase/shop commands **are compatibility**, not V2's ten slots, full quality, profession work queue or Sect ownership policy. `DiscipleCombatLoadoutV2.build` currently consumes this old gear bridge, not a full 10-slot engine. Do not delete/migrate abruptly.

## 3. Owner decision **S**: How much primary strength may ten ordinary pieces contribute?

These are **candidate acceptance bands** for a **ten-slot coherent, equal-realm-tier, grade-neutral ordinary gear loadout**, compared with the same disciple's no-item Realm+Body core at Potential 0; measured **PER STAT** against an appropriate role build, not a promise that every piece simultaneously increases every stat. Affixes/sets/rare Chân Văn must be audited separately. This is design calibration, not hard universal ATK/DEF cap or algorithmic auto-nerf.

| Choice | Candidate FULL ten-slot base effect against appropriate baseline | Player feeling / risk |
|---|---|---|
| **S1 – cultivation-led** | roughly **+15% to +30%** relevant primary stats | realms dominate; gear upgrades less exciting, manageable balancing |
| **S2 – balanced (RECOMMENDED)** | roughly **+30% to +50%** in chosen primary stat roles | gear matters but realm remains main permanent power; must test ATK mitigation feedback |
| **S3 – gear-centric** | roughly **+60% to +90%** in chosen stat roles | loot very rewarding; risk bypassing realm/tier gaps and inflation at 10 slots |

**PROPOSED S2 FIRST PILOT NUMBERS** at item realm tier 1, no potential and no affixes:
- `Thanh Thiết Kiếm` tier1, Phàm, **Attack flat +3** (ATK23→26; +13.04% raw; versus DEF19 direct-hit basic ratio1, no crit/status/element: damage16.28→19.04, about **+17%** effective damage because mitigation depends on attacker ATK).
- `basic armor` tier1 Phàm, **MaxHP flat +20, Defense flat +2** (HP190→210, DEF19→21), before any damage reduction/conditional lines. This does **not** grant +10.5% HP permanently when wearer changes realm; it is an item flat tier1 source.
- At Potential 1000: baseline core ATK34.5, weapon still adds 3, not 4.5. If applying a legal same-channel +ATK%, the correct modifier is applied *after* core+flat.
- Starter numbers are **ASSISTANT PROPOSAL ONLY**, not a final item balance or the current P2 item stats. P2 pilot `combat_power=6` is NOT V2 attack+6.

**PROPOSED non-owner-locked growth to evaluate:** for a same-template rank `r∈1..30`, item flat base may scale by **G(r,1)** on the *item's own tier*, not by wearer stats. E.g. weapon `+3*G(r,1)`; always use finite floating-point internally; UI may format large numbers compactly but must offer precise value. Same tier is reference, not a universal equipment access gate: existing legality permits ordinary physical gear via eligible Tu Vi **OR** Luyện Thể, while authored spiritual/body-exclusive restrictions differ. Validate G(r,1) + high Potential + affix stacking across 30 ranks before locking scaling.

**S2 caution:** a complete 10-slot base budget target is NOT a design that awards a permanent +40% primary stat to each individual item. Distribute slot budgets by their unique identities. A single sword bonus +3 is a small illustration, not evidence S2 is balanced across all realms.

## 4. Owner decision **F**: What result is promised by a forge order?

All alternatives: one durable `forge_order_id`, one worker job, canonical materials, deterministic roll from saved order seed, one unique Sect item; **NO owner-policy unknown becomes code**.

| Choice | Upfront player control | Randomness + behavior | Pros / cons |
|---|---|---|---|
| **F1 – targeted with floor (RECOMMENDED)** | Choose slot+template+equipment realm tier+eligible blueprint. Cost pays guaranteed **one baseline usable item**. Grade/affixes may improve within **authored facility/profession/material ceilings** | player gets intended weapon/armor; rare materials improve chase rolls; needs transparent grade probabilities |
| **F2 – exact guaranteed quality** | Choose recipe for exact template, tier **and quality**, and pay its explicit higher materials | zero grade-RNG frustration; farming economy predictable but reduces excitement and needs more authored recipes |
| **F3 – blind crafting** | Pay a resource recipe with output pool, random item slot/template/quality | exciting short term; highly frustrating when building targeted six-piece set or 1,000 disciples; NOT recommended as main forge; might be separate event later |

**Recommended F1 design:** player's choice of template never randomly becomes another item; no failed forge that destroys all base materials for a useless result in the initial rank. Quality improvements depend on actual facility/recipe/special-material eligibility, never uniform Grade1..12 for every Lv1 order. At Lv1, guaranteed modest basic equipment with chance of *legally eligible* higher grade only when its table is authored; do not allow Chí Tôn merely because RNG integer rolled 12. Boss materials used for advanced/certain recipes, not all starter equipment.

**Candidate pilot resource inputs (SOURCE P2 sample recipe IDs/quantities, NOT V2 owner-lock):**
- `Thanh Thiết Kiếm`: `thanh_thiet=3` + `linh_moc=1`.
- `Tinh Lang Giáp`: `tinh_lang_bi=3` + `thanh_thiet=1`. Be careful: monster hide exists in resource registry, not a ready V2 item-armor template.
- Time/job start and guaranteed quality floor **OPEN**: no invented new `forge building type` in current Godot.
- First CODE pilot should use **one legal recipe**, then tests for a second recipe and one more slot; no mass 24 sets while core forge authority is untested.

## 5. Owner decision **Q**: How does the grade 1..12 affect strength?

Grade capacities remain exactly the locked table. The choice is **how base stat magnitude and affix rolling interact**, not how many grades exist.

| Choice | Impact | Risk |
|---|---|---|
| **Q1 – quality mainly opens affix potential (RECOMMENDED)** | item realm tier owns baseline base HP/ATK/DEF; grade grants available normal/special/Chân Văn capacities and legal rarity/roll quality, with **only modest bounded base-stat change if later approved** | clear balance: an extraordinary low-tier item cannot leap many realm tiers; still rewarding due focused affixes |
| **Q2 – quality also strongly multiplies base** | grade raises base significantly **plus** increases line capacities | strong "wow" but 12-grade ×30-tier×sets can explode; must have exhaustive realm/boss benchmarks |
| **Q3 – quality grants strictly capacity, exact same base per tier/template** | no baseline variance by grade, only affix/Chân Văn opportunity | easiest to balance and test, but grade may feel weak before affix-specific effects exist |

**Status:** normal/special line count per grade in canonical doc is the **capacity**; it does not imply guaranteed ideal rolls. Numeric grade multipliers, individual line percentages, actual 80+ affix registry, skill consumers and Grade12 probability are **OPEN**. Do **not** carry P2 `stat_multiplier=1/1.16/1.34` over as V2's first three quality multipliers without explicit independent approval.

## 6. Recommended one-order data contract (DESIGN PROPOSAL, not existing classes)

```text
Order:
  forge_order_id: globally unique within Sect, monotonic durable
  version, recipe_id, requested_slot, item_template_id, item_realm_index(1..30)
  worker_disciple_id, building_instance_id, profession_level_snapshot
  source_state: PENDING -> ACTIVE -> COMPLETE_COMMITTED (or AUTHORIZED_CANCEL)
  accepted_tick, planned_finish_tick, deterministic_order_seed
  consumed_material_requirements: exact canonical resource ids and counts
  material_debit_receipt_id
  proposed_roll_policy_id, immutable_creation_schema_revision
  completion_receipt_id?, product_item_id?  (both assigned exactly once)
Item:
  item_id unique, sect_owner=true, assigned_disciple_id optional
  template_id, realm_tier, grade_id(1..12), generation(man/tien/than)
  slot, set_lineage_id optional, base_stat_sources, normal_affixes[], special_affixes[]
  inscription_capacity, inscription_id optional
  location=storage/equipped/authorized-shop, locked/reservation, creation_receipt
```

**Data ownership:** `SimulationState/SectState` is authoritative for orders/item registry + original `WarehouseSystem` for STACKABLE materials, no second inventory store. Individual equipment can remain in the `equipment_items` unique-item registry once versioned and migrated; do not treat item UID as stackable `ResourceRegistry` qty. One canonical `SimulationRuntimeOwnerV2` and SaveService, one clock. No parallel gameplay engine owned by UI.

**State transition (reliable, anti-dup):**
1. `ACCEPT`: verify recipe/building/worker/work-policy/stock/reserve/rank; bind single worker One Active Job; save deterministic order seed/roll policy/version; consume exact stock through canonical Warehouse requirements together with durable order/debit record under existing state authority; reject the whole state mutation if save fails.
2. `IN_PROGRESS`: real canonical scheduler ticks, paused/status criteria clearly specified; no item before finish; worker not secretly assigned to mine/hunt; profession XP awarded on successful real completion exactly once.
3. `SETTLE`: load/order IDempotency: if receipt already COMMITTED, no-op. Else calculate reproducible grade+legal affix from **committed seed and eligible authored pools**, create exactly one unique Sect item, mark same order COMPLETE with item ID, persist via existing SaveService. If persistence fails, do not expose a durable paid item / duplicate on retry.
4. `ASSIGN`: inspect genuine equipment eligibility and locked slot; transfer between storage/assignee without cloning or private gear title. Refresh Combat V2 `sources` only after accepted change; preserve current HP ratio if Max HP changes.
5. `RECOVER`: after interrupted/resumed/corrupt-save attempt, replay deterministic state+barriers. Never regenerate a new grade or repeat material debit because UI was reopened.

**Crash fixtures:** crash before accepted order; after debit+durable job but before completion; after item+receipt durable but before GUI; duplicated callback; same order after offline; cancellation prior/after progress and no double refund; sell/assign/equip to 2 disciples; locked item; failing warehouse/material/crafter and full worker; legacy old `owner_id` and 3-slot save. Mark cancellation/refund policy OPEN until selected.

**Concurrency:** multiple queued orders may exist but any worker may have only ONE active job; serial settle at a canonical tick; sorted IDs for deterministic equal-time completion. Warehouse reservation cannot be satisfied twice from same item stack. No UI-side mutation of reward or artisan grade.

## 7. Minimal future code rollout (only after owner chooses)

- **CODE F0:** data schema + migration compatibility, stable item UID, legacy 3-slot proof, real `WarehouseSystem` debit + durable forge job, one low-tier guaranteed Phàm blueprint (no new rare rolls).
- **CODE F1:** second recipe/armor, scoped Combat V2 flat stat sources and accurate P3.2 UI labels, Save/Load + defeat/redeploy stats/no phantom HP.
- **CODE F2:** authored 12-grade-capacity/affix registry for ONLY sources that real consumers handle; genuine rarity distribution simulation, profession/building eligibility.
- **CODE F3:** 10-slot equipment and 24 sets in progressive groups, then enhancement/transfer/chân văn later; per-ticket focused/gating.

None has been authorized. Await P0 Windows gate/branch integration ownership and approve allowed source paths separately. Don't open a second CODE writer on PR #25 P3.2.

## 8. Owner choices requested FIRST (only 3; no need to decide all 80 affixes)

1. **S**: `S1` cultivation-led (15–30% base), **`S2` balanced (30–50%)**, or `S3` equipment-led (60–90%). Bands are provisional tuning targets, not automatic caps.
2. **F**: **`F1` target template + guaranteed usable baseline + tier-limited grade roll**, `F2` exact guaranteed grade cost, `F3` fully random main output.
3. **Q**: **`Q1` grade mainly affects available affixes + bounded base variance**, `Q2` strongly multiplies base plus capacities, `Q3` only affix capacity, same base.

**Assistant's provisional preferred stack: `S2 + F1 + Q1`**. Owner may choose mixed options. Once owner locks this, we can immediately do BD-01A detailed one-forge data & probability calibration, then BD-01B enhancement policy choices, while Codex remains on PLAYABLE QA. Owner will receive findings and choices **in chat**, with docs committed to GitHub by this assistant — not a request for Codex to design.

## 9. References, precedence and status

- `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md` Oct09 – numeric core locked and implemented, despite old name.
- `godot/src/simulation/combat/combat_stats_v2.gd`, `godot/src/simulation/combat/disciple_combat_loadout_v2.gd` – true Combat V2 stat pipeline.
- `docs/WEAPON_EQUIPMENT_V2_SPEC.md`, `docs/EQUIPMENT_SETS_V2_SPEC.md`, `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md` – gear structure locked / late open mechanics.
- `godot/src/simulation/equipment/equipment_system.gd` – real P2 compatibility 3 slots/3 qualities; `godot/src/simulation/resource/warehouse_system.gd` – canonical shared materials.
- `docs/P3_7_BUILDING_TREE_SPEC.md`, `godot/src/simulation/building/building_system.gd` – building design vs pilot implementation.
- [Master Roadmap](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/tmb-master-completion-roadmap-20261023/docs/roadmaps/TMB_MASTER_ROADMAP_PLAYABLE_TO_V1_2026-10-23.md), [Backend Gap Queue](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/tmb-master-completion-roadmap-20261023/docs/roadmaps/TMB_BACKEND_DESIGN_GAP_QUEUE_2026-10-23.md), [PR #24](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/24), [PR #25](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/25).

**No Game/B3/Source A code changed, no Engine tests claimed, no main/PR merge.**
