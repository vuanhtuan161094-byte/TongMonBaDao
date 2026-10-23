# TÔNG MÔN BÁ ĐẠO — HỢP ĐỒNG LIÊN KẾT NỘI DUNG 30 CẢNH GIỚI: QUÁI → LOOT → CHẾ TẠO → TRANG BỊ/ĐAN/CÔNG PHÁP/KỸ NĂNG → PHÁT TRIỂN

**2026-10-23 | SOURCE-RECONCILED / DOCS ONLY / IMPLEMENTATION NOT AUTHORIZED.**  
**Owner latest:** mỗi cảnh giới phải có **nhóm/dòng trang bị và nguồn rơi tương ứng**; không lấy một Thanh Thiết Kiếm cấp thấp nhân `1.65^(r-1)` rồi coi như 30 loại vật phẩm. Owner-approved gear strategy **S2 + F1 + Q1** still stands. This document proposes an **integrity contract** tying systems together. The *intent* is owner-approved, but new detailed contents/IDs, rates, recipes and numeric balances remain **PROPOSED OR UNAUTHORED**, never implicitly locked.
**Do not edit Code, PR #24/#25, FE/Source A, run FULL/CI or merge.** This document corrects previous assistant-authored BD-01 examples only; it does not repeal canonical mechanics.

## I. ROOT CAUSE / authority and status

1. **Split source of truth:** separate subsystems lock equipment/medicine/techniques/skills/realms while no single executable content relationship joins monster source to ResourceRegistry ID to recipe item and legal consumer. Individual subsystem design passes are **not** evidence that a complete loop is authored.
2. **Three conflated dimensions:** `cultivation_realm_index 1..30 + floor 1..10` versus `equipment_realm_index 1..30` versus `equipment_grade 1..12`. Technique/skill rarity and generations are DIFFERENT from these; fixed medicine effects and eligibility are independent; Body uses separate realm+floor. Do not "unify" by number or by a name match.
3. **Legacy/live mismatch:** live P2 `EquipmentSystem.VALID_SLOTS=[weapon,armor,talisman]`, three qualities + instant craft; V2 doc has 10 normal + 3 Fu +2 treasures, 12 grades, 24 set lineages. P2 `TechniqueSystem` caps 3 learned/5 legacy levels; V2 allows many learned, 1 main+2 auxiliary active and V2 five named mastery stages. `AlchemyRecipeRegistry` on main has only a Hồi Xuân pilot; CARE adds Tụ Khí pilot. Three old early hunt regions and B3 single-wolf/single-hide are **pilots**, not a complete R01..R30 content registry.
4. **Wrong generative shortcut:** assistant BD-01A proposed `ThanhThietSwordATK(r)=3*1.65^(r-1)` for all 30 item tiers. This is **RETIRED as a content generation rule**. The Combat V2 character-core formula `G(r,f)` remains LOCKED and CODED; it may serve as reference for **budget validation** of distinct authored item templates, not as a function giving one named sword 30 rank variants.
5. **Testing gap:** CARE/O6 focused and GUI validations prove actual simulation (loot/injury/save/receipt) for pilot, NOT future tier coverage, content source/use, item compatibility, art, economic feasibility, learning, Body gates, Boss source, cross-realm balance.
6. **Documentation drift:** earlier `P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md` recommends hunt Tu Vi percentage of next stage; later explicit owner decision on 2026-10-23 **fixed direct personal Tu Vi on each valid credited kill** takes precedence; XP implementation remains separate, no phantom receipts. `WEAPON_EQUIPMENT_V2_SPEC.md` Oct08 says Combat Core base stats open, superseded Oct09 locked Combat curves. Preserve all source decisions by precedence rather than silently reading oldest paragraph literally.
7. **UI duplicate shell:** PR #25 P3.2 inherits P3.1 drawn legacy shell and adds CARE panels; visual mixing is a distinct presentation gate, not proof content gameplay design changed.

## II. Entity model: six separate axes, no implicit convert

- **Character cultivation**: `cultivation_realm_index` 1..30; `cultivation_floor` 1..10; state/XP and major gate. **Body**: `body_realm_index` 1..30 and independent `body_floor` 1..10.
- **Map & difficulty**: `region_id`, `cluster_id`, `recommended_cultivation_realm/floor`, danger/Elite/Boss; recommendations **soft**, not a generic lock (except authored specific events). Existing pilot PvE *five difficulty grades per map* is another axis, NOT the 10 clusters or 30 realms.
- **Monster**: `monster_species_id`, `monster_realm_index/floor`, `monster_grade=normal/elite/boss`, `encounter/kill_id`; source-specific loot tables, not fixed global realm-distribution shortcut.
- **Equipment**: `equipment_template_id` (real distinct item lineage/template and optional visual identity), `equipment_realm_index 1..30` (strength/equip requirement band), `grade_id 1..12` (affix capacity/rarity), `item_unique_instance_id`, authored slot/weapon/armor family, possible `set_lineage`. Every high-realm progression needs genuinely authored **different item group/content identity and loot/recipe sources**, not reused "Thanh Thiết Kiếm" multiplied. 12 grades apply to each eligible authored template/tier only if allowed; not all 12 must be obtainable from any source.
- **Materials/pills/manuals**: each `ResourceRegistry.resource_id` is distinct and has `realm_rank/tier/usage_tags`, actual authored source(s), quantity/rarity, consumer(s); `pill_id` has explicit effect and satiety; `technique_id`/ `skill_id` has distinct grade/rarity, generation and prerequisites. Those **do not inherit equipment grades**.
- **Content closure:** any reward advertised in UI/game must resolve to an actual source and at least one real consumer or be explicitly tagged **future content, non-obtainable**. Conversely, every mandatory progression material/blueprint/book/medicine must have repeatable obtainable source or owner-authorized alternate path. If a core upgrade requires an unimplemented unique Boss, that loop is **BLOCKED**, never silently satisfied.

## III. Cross-system joins required, all strict

| System | Producer/source definitions | Canonical reward identity | Real consumer(s) | Forbidden inference |
|---|---|---|---|---|
| PvE maps/normal/elite/boss | region/cluster/species/grade, seeded `loot_table_id`, `kill_id`, authorized chance | stackable resource IDs + unique item instance / technique manual IDs, Spirit Stones/tuvi receipts | Warehouse, Forge/Alchemy, Technique transmission, Body gate, equipment allocation | don't infer every boss drops random Grade12 or current Thanh Lang produces endgame loot |
| Gathering/buildings | mine/field/forest/elite gathering jobs | explicit `ResourceRegistry` resource IDs and counts on real settlement | construction, recipes, upgrades, logistics/market | never give abstract "material power"; never combine IDs just because they share element or tier |
| Forge | authored recipe, blueprint, materials, building/profession/ticks | unique Sect-owned equipment ID with template+tier+grade+affixes+source | legally equipped V2 Combat sources; upgrade/refine, locks/salvage | never create rank-N Thanh Thiết sword by name-copy+stat multiplier |
| Alchemy | ranked named recipe, herbs/grain/monster materials, true profession & building | pill ID, fixed/realtime validated effects, satiety costs | canonical player/CARE/healing/cultivation/Body/breakthrough/Thọ | don't multiply fixed +10,000 Tu Vi by rank/potential without authored rule |
| Techniques (Công Pháp) | complete manual/fragments from authored map/Boss/transmission/research | sect transmission + learned ID/mastery/state; consumable materials in Warehouse | 1 main+2 auxiliary active, authored cultivation/passive & path conditions | don't treat technique rarity as a strict realm index or teaching as repeatedly consuming a full tome |
| Combat skills | authored manual/prereq, teacher/comprehension/real battle | learned skill ID / mastery / family generation Nhân-Tiên-Thần | allowed 1 basic+4 active+6 combat passives at mature stage, Combat V2 | don't grant full kit from a Công Pháp or overwrite prior generations |
| Realm & Body gates | authoritative tier/floor EXP + explicit gate mats | paid XP once, true upgrade transaction, permanent derived stat rebuild | unlock new recommended maps, next-tier authored recipes, new content | don't infer Tu Vi rank = Body rank or auto-generate reward at any kill |
| Sect/individual economy | real transactions/receipts + wage/sales/loot | Sect Warehouse/sect stones/personal stones with distinct ownership | costs for training/craft/medicine/transmission, protected reserve | no P2 wallet/treasury alias automatically mapped to V2 stones |
| Equipment visuals & UI | registry-approved Source A IDs + raw state snapshots | readable correct item identity, realm index, grade and real sources | player input only | no art/placeholder or derived scaled UI label treated as item authority |

### Kill/loot/XP settle invariant
Valid monster `kill_id` settles one Sect loot pool (unique item registry or stackable Warehouse) and eligible personal direct-kill Tu Vi once each (after separate XP code authorization). Do not reintroduce last-hit-only loot, "Tinh Nguyên automatically grants all XP", or a per-team duplicated Boss loot pool.

### Lower-rank fallback exception
Not all rewards are forbidden outside their home rank: older-tier materials/pills/unique utility/low-rarity techniques can remain obtainable/usable if an **explicit authored source/reuse rule** says so. However, the **main progression rewards** of higher-rank encounters must be new, real rank-appropriate item families, not sole repeated rank1 gear. Lower-rank pills need not be hard-blocked; they can be simply inefficient at upper ranks.

## IV. 30-row production content coverage matrix — **NO FAKE GAME ASSETS**

These 30 names and rank numbers are SOURCE from `REALM_LADDER_V2_SPEC.md`. Column statuses here track **fully authored/cross-linked V2 release content**, not lack of *all* pilot code. Proposed 30 map IDs from map/equipment matrix remain **UNLOCKED PROJECTION**, never say 30 maps already exist.

| # | Cultivation realm | World | Corresponding equipment tier/group | PvE enemy/drop content | Equipment template+loot+forge recipe | Medicine herb→pill chain | Technique/skill/gate source |
|---:|---|---|---|---|---|---|---|
| 01 | Phàm Nhân | Nhân | `equipment_realm_index=1`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 02 | Luyện Khí | Nhân | `equipment_realm_index=2`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 03 | Trúc Cơ | Nhân | `equipment_realm_index=3`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 04 | Tử Phủ | Nhân | `equipment_realm_index=4`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 05 | Kim Đan | Nhân | `equipment_realm_index=5`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 06 | Nguyên Anh | Nhân | `equipment_realm_index=6`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 07 | Hóa Thần | Nhân | `equipment_realm_index=7`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 08 | Luyện Hư | Nhân | `equipment_realm_index=8`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 09 | Hợp Thể | Nhân | `equipment_realm_index=9`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 10 | Đại Thừa | Nhân | `equipment_realm_index=10`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 11 | Nhân Tiên | Tiên | `equipment_realm_index=11`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 12 | Địa Tiên | Tiên | `equipment_realm_index=12`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 13 | Thiên Tiên | Tiên | `equipment_realm_index=13`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 14 | Chân Tiên | Tiên | `equipment_realm_index=14`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 15 | Huyền Tiên | Tiên | `equipment_realm_index=15`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 16 | Kim Tiên | Tiên | `equipment_realm_index=16`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 17 | Thái Ất Kim Tiên | Tiên | `equipment_realm_index=17`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 18 | Đại La Kim Tiên | Tiên | `equipment_realm_index=18`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 19 | Tiên Vương | Tiên | `equipment_realm_index=19`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 20 | Tiên Đế | Tiên | `equipment_realm_index=20`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 21 | Thần Nhân | Thần | `equipment_realm_index=21`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 22 | Chân Thần | Thần | `equipment_realm_index=22`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 23 | Thiên Thần | Thần | `equipment_realm_index=23`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 24 | Thần Quân | Thần | `equipment_realm_index=24`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 25 | Thần Vương | Thần | `equipment_realm_index=25`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 26 | Thần Hoàng | Thần | `equipment_realm_index=26`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 27 | Thần Đế | Thần | `equipment_realm_index=27`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 28 | Thần Tôn | Thần | `equipment_realm_index=28`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 29 | Hỗn Độn Thần | Thần | `equipment_realm_index=29`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |
| 30 | Sáng Thế Chủ | Thần | `equipment_realm_index=30`; group identity to AUTHOR | `NOT_AUTHORED_AS_V2_RELEASE_CONTENT` | `NOT_AUTHORED` | `NOT_AUTHORED` | `NOT_AUTHORED` |

**Real pilot exceptions:** Three `HuntingMapV2.REGION_CONTENT` regions all have `realm:1` and floor variants, B3 CARE has `bach_thach_khe` one wolf species and `tinh_lang_bi` one paid generation. ResourceRegistry has early named resources plus selected authored Body gate materials. This does NOT establish 30 progression environments or 300 complete content clusters. The old projected material labels like "Địa Tiên Khoáng" are theme sketches, not registered Resource IDs. Stage R01–R03 content rows above can become INTEGRATED only after source→consumer evidence, even if P0 has a monster with a similar name.

## V. Corrected equipment family and balance contract (S2/F1/Q1 remain LOCKED directions)

1. The **equipment realm tier** `r` defines a power band and eligible templates; a **named item** has an authored `item_template_id` with a *defined realm tier* or explicit upgrade/evolution to a distinct successor. `Thanh Thiết Kiếm` R02 pilot (if mapped/approved) is NEVER reused unchanged at R20 by computing `ATK*G(20)`. Old P2 `thanh_thiet_kiem` carries no valid R02 assignment until an explicit migration mapping; current `ResourceRegistry["thanh_thiet"]` carries a `realm_rank=1` with label `luyen_khi`, so **raw string labels/IDs are insufficient to infer exact equipment_rank**. Resolve these source inconsistencies in authored content before code.
2. **S2 balanced**: full role-specific *available gear* targets a moderate **measured PvE contribution** vs same-rank no-gear actor (earlier `+30–50%` is a tuning proposal, not hard cap/uniform Attack bonus). Actual item base values are authored **per template and tier**, measured using locked Combat V2 stats and correct monster formulas. Equipping older sword at newer rank retains its old `+ATK`, doesn't gain wearer growth. No direct formula `B_sword(r)=B_start*1.65^(r-1)` assumed for every item; canonical `G` only scales realm/Body **Core**. Gear flat sources added after Potential Core.
3. **F1 targeted**: choose real authored template/tier/slot; guarantee usable baseline item after legal completed forge order; grade/affixes roll from *eligible authored pool*, not all 12 everywhere. Boss rare material may influence high-realm chase, but base gear progression cannot be blocked by inaccessible Boss-only drops.
4. **Q1 quality**: 12 grade affix-capacity table remains unchanged; grade/rarity impacts accessible normal/special/individual Chân Văn (Grade12 empty inscription capacity), not automatic massive base multiplier. Do not port P2 fixed quality multipliers 1.16/1.34 automatically. Any small base variance must be explicitly approved separately.
5. **Set identities**: 24 lineages ×4 authored slot pieces, eligible Mũ/Giáp/Phi Phong/Hộ Uyển/Đai/Giày only; 2/3/4 thresholds cumulative, lawful 3+3, generation Nhân/Tiên/Thần; true unique item UID per piece and source.
6. **No "one individual item total per realm":** owner's "mỗi cảnh giới rớt một loại item" means **rank-specific equipment group/content identity**. Each realm may need multiple templates for 10 slots, weapon families, materials and sets. The exact **number** of authored templates per realm is STILL OPEN, never assume literally one sword or one single drop. Each monster also needs real source table; not all monsters in same realm guarantee one type.

## VI. Explicit subsystem-specific constraints — prevent blanket stage-copy formulas

### Đan / Alchemy
- `Tụ Khí Đan` owner-approved **starter CARE pilot**: 2 Thanh Linh Thảo +1 Linh Cốc, 6 sim ticks, satiety **25** and **+10,000 fixed Tu Vi**. `Hồi Xuân Đan`: **10** satiety, **+55 HP**; shared daily cap **1,000,000 per disciple** and Injury 120 as currently locked. Existing main `AlchemyRecipeRegistry` contains Hồi Xuân from **3 herbs**, so never silently claim its recipe equals Tụ Khí. Both are pilots, not "same medicine formula ×1.65 each realm".
- At higher realms: design named distinct herbs/crop/monster resource IDs, real facility+profession+recipe unlock, legal `effect_kind` (flat Tu Vi, base cultivation modifier, HP heal, Body XP, breakthrough, lifespan etc.), exact `effect_amount` with unit and gate, `satiety_cost`, recipe duration/qty and source. Old pills may remain legally usable but economically weak.
- Every pill has `recipe_id / output_item_id / material_ids / effect_source_id / satiety_cost / eligibility_conditions / use_receipt`; cannot emit effect before canonical Warehouse debit. No blanket "one 12-grade pill per realm" required.

### Công Pháp
- V2 **1 Chủ Tu + 2 Phụ Tu active, learned collection unbounded by old P2 3**, history/mastery preserved; sect manual archived once unlocks stable transmission; learning spends authored time/Contribution/personal Spirit Stones and has deterministic requirements; personal mastery stages `Sơ Học/Nhập Môn/Tiểu Thành/Đại Thành/Viên Mãn`.
- Công Pháp rarity `Phàm/Huyền/Địa/Thiên/Tiên/Thần` is **not** one-to-one with cultivation realm: a lower-grade technique may stay valuable via synergy; success evolution `Diễn Hóa` creates authored successor ID, not multiplies a shared old technique by realm factor. Map drops full manuals/fragments by authored `loot_table_id` plus explicit academy/secret realm sources, no mandatory one technique per realm. Distinguish P2 level1–5 from V2 mastery labels for migration.

### Kỹ năng
- Mature loadout `1 Thường Kỹ+4 Chủ Động+6 Bị Động Chiến Đấu` unlocks over Nhân; passive slot-free only for statics with no trigger/team impact.
- Skill families evolve in **waves Nhân1..10→Tiên11..20→Thần21..30** with explicit authored `successor_skill_id`, not 30 new class kits nor auto upgrade on realm breakthrough. Learning conditions, cooldown, effect values and visual Source A mapping independent.
- If a gear affix says "+sword skill damage," it requires actual learned combat-skill action ID/tag and applicable event; don't present special proc if no runtime consumer.

### Luyện Thể/Body
- Body 30×10 independent. Natural body training only through authorized source per sim minute, correct Căn Cốt factor; fixed Body rewards only when explicitly authored. RealmBodyCore stat math remains unchanged. Body major breakthroughs require materials/receipts/source per gate, not simply "kill any same-rank monster."
- Cross-body-tier and weapon equip legality: ordinary physical gear can use Tu Vi OR Body tier where authorized; spiritual-only/Body-exclusive content may require specific track. Map recommendations are soft not hard Body entry gates.

### Economy/market/Boss/automation
- One Sect Warehouse for stacks, one unique gear item registry, one set of receipts, one scheduler/clock/save, one active disciple job; equipment remains Sect-owned even when assigned.
- Loot sources and material sinks must be balanced per 24h/7d/30d sim time; source tables must record whether materials support normal recipe progression vs optional rare Boss chase. Do not lock dramatic rare 0.2% Chí Tôn without a rate-of-eligible-crafts and rare material budget per hour and demand across 1k–3k disciples.
- Multi-team Boss: one HP+one sect pool+role evidence+per-actor XP. Spirit Stone sect/personal split **OPEN** (60/40 NOT LOCKED). Do not infer personal gold from P2 wallet.
- Recipe and profession bonuses only when a real consumer exists (quality/rare-yield etc.), not on passive UI hover or when equipped piece shared across multiple production workers.
- UI truth: show real rank/tier/template/grade/id, effects at real consumer value, raw Lục Duy, actual inventories and reward; radar/chart normalization is presentation-only.

## VII. Machine-validatable content registry contract (future code packet, NOT CURRENT IMPLEMENTATION)

One read-only **`ContentRelationshipRegistryV1`** for declarative authored definitions; references resolve to *existing canonical* runtime systems, no new Warehouse/reward authority. Suggested minimal schemas:

```yaml
realm_band:
  cultivation_realm_index: 2
  cultivation_name: "Luyện Khí"  # SOURCE
  content_status: "DESIGN_ONLY"
  item_group_id: "gear.family.r02" # PROPOSED, not existing!
  recommended_map_ids: []         # Unauthored; don't fill from 30-map sketch
  material_resource_ids: []
  monster_species_ids: []
  equipment_template_ids: []
  alchemy_recipe_ids: []
  technique_manual_ids: []
  combat_skill_family_ids: []
  body_gate_resource_ids: []

equipment_template:
  item_template_id: "PROPOSED/example_r02_weapon" # demonstration only
  equipment_realm_index: 2
  slot: "weapon"
  set_lineage_id: null
  legal_source_ids: ["PROPOSED/map_or_forge_id"]
  grade_eligibility: [1,2,3] # not an automatically verified probability
  core_flat_sources: [{"channel":"attack","mode":"flat","value":"PROPOSED"}]
  exact_recipe_id: "PROPOSED"
  equip_track_requirement: "cultivation_or_body_if_physical"

pve_drop_entry:
  loot_table_id: "PROPOSED/r02/normal"
  monster_species_id: "PROPOSED"
  monster_grade: "normal"
  source_region_id: "PROPOSED"
  content_id: "EXISTS_IN_CONTENT_REGISTRY_OR_BLOCK"
  content_kind: "stackable_resource|unique_equipment|manual|blueprint"
  chance: "PROPOSED"
  quantity: "PROPOSED"
  exact_once_scope: "kill_id_or_encounter_id" # according to actual owner

alchemy_recipe:
  recipe_id: "PROPOSED"
  output_item_id: "registered_pill_id"
  inputs: {"registered_resource_id": "explicit_quantity"}
  output_count: 1
  effect_kind: "flat_cultivation_xp|hp_heal|body_xp|breakthrough|lifespan"
  fixed_effect_amount: "PROPOSED"
  satiety_points: "PROPOSED"
  building_or_profession_requirement: "PROPOSED"
  canonical_use_receipt_id: "PROPOSED"

technique_definition:
  technique_id: "PROPOSED"
  rarity: "pham|huyen|dia|thien|tien|than"
  prerequisites: ["authored"]
  archive_material_source: "explicit_normal_elite_boss_academy_or_event"
  learned_mastery_id: "unique_per_disciple"
  active_slot: "main|auxiliary"
  successor_technique_id: null

skill_definition:
  skill_family_id: "authored"
  generation: "nhan|tien|than"
  acquire_source_id: "authored"
  prerequisites: []
  actual_combat_event_consumer: "implemented_or_block"
```

The data schema above is a *proposed validation interface*, not actual YAML to load today. All `PROPOSED` IDs are deliberately not registered: UI may not award, equip, consume or display them as real content.

**Registry consistency checks**, to implement only when explicitly authorized:
- `foreign_key` identity: every drop, recipe, stat affix, technique manual, Boss unique, set piece references actual defined ID and compatible source.
- `realm_coverage`: one rank-specific *equipment content group* per R01–R30 is ultimately required by owner target; **allow design-only gaps**, block release before required content complete.
- `source_consumer`: each critical material/recipe gate has repeatable obtaining path, enough qty for representative progress, no Boss-only normal gear bottleneck.
- `eligibility`: a player reaching a rank may eventually earn/equip/learn legal content; map soft gates remain soft.
- `probability_budget`: chance [0..1], probabilities sum only within their correct pool, no 12th grade from basic E0, no re-roll on reload, sample cohort assumptions declared.
- `stat_math`: only authorized CombatStatsV2 `source_id/channel/mode`, no PvE-invalid effect/no phantom proc. HP ratio maintained.
- `migration`: existing P2 equipment, techniques, pills, map saves continue to load with original IDs and outcomes; no silent gear at r20 due to item name.
- `save`: one kill/loot receipt, one order/item receipt, no duplicate XP on reload or offline, no mixed money/second warehouse.
- `presentation`: snapshot count/name/rank/grade exactly matches real content; missing content is visibly **unavailable/not authored**, never fake stats/images.

## VIII. Five immediate reparation packets (sequence is essential)

| Packet | Task | Output/closure | Code? |
|---|---|---|---|
| **X0 (this)** | Correct all contradictory assistant BD01 tier-copy claims and central content source/consumer definitions | publish correction banner in BD01/BD01A, this joint contract and audit with exact pointers | **DOCS ONLY completed once committed** |
| **X1** | Produce **R01–R03 content fixture** with EXACT existing source IDs + separately PROPOSED missing recipes/gear + technique and medicine loops | at least one real and one proposed source→reward→consumer path per system; owner approves small pilot quantities | design then code separately |
| **X2** | Draft R01–R30 **authoring coverage** table with actual equipment families/monster/drop/medicine/technique/skill content; migrate legend/id structure, no phantom assets | owner reviews content tiers; validate progressively by rank group, not blindly fabricate 30×10 assets | design-only until code |
| **X3** | Implement one **cross-system content registry validator**, staged behind current runtime and legacy migration; false references, orphaned rewards, missed gates reported cleanly | deterministic focused validation on official Godot pinned SHA, no unapproved gameplay edits | **needs owner separate CODE allowlist** |
| **X4** | Ship one whole playable vertical progression: hunt rank-appropriate drops→produce real item or pill→equip/consume→stats/XP improve→next rank→save/offline; extend only after UX QA | Android + Windows manual, true player numbers/provenance and economy budgets | **needs owner separate CODE allowlist** |

## IX. Gate before calling a realm group "complete"

For each supported rank:
1. named enemy species with real level and real loot table (common/elite/boss if authored);
2. one repeatable path to essential resources/gear and one actual consumer for each;
3. authored upgrade/equipment/pill/technique requirements and legitimate output;
4. nonzero, reasoned item improvement versus comparable rank / sourced balance fixtures;
5. Body and Tu Vi independent, source-specific grants/gates; no exploit or forced cross-body equality;
6. read-only UI with accurate numbers + appropriate Source A provenance state;
7. canonical save/load/offline, one job and one Warehouse, no duplicate rewards;
8. tests and physical Windows/Android visual approvals separate.
If any piece is missing, status is **PILOT/INCOMPLETE**, not realm-complete or shipped.

## X. Exact current Git truth / user visible scope

No new runtime changed in this X0 pass. Official Godot tests from earlier PR #24/#25 (28/28 and 13/13 focused at corresponding SHAs) remain true *for their scopes*, not proof of the full design. The actual P2 code/mapped resources and 3-region pilot were inspected on `main=29b5fba448b0178cb520a4ada44b375b4b934e31`, CARE on `4d08984f044bfa29a98070c8d68ee5a155256d3a`. The 30-row coverage status is an AUDIT of authored V2 release content, not a deletion plan for P2 saves.
