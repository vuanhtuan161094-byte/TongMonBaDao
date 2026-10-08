# WEAPON + EQUIPMENT V2 — MA TRẬN CẢNH GIỚI, MAP VÀ ĐỒ BỘ

Date: 2026-10-08
Status: **PARTIAL DESIGN LOCK — REALM/MAP/SET FRAMEWORK; NOT IMPLEMENTED**
Owner: Weapon + Equipment V2. This file is the specific authority for the locked matrix and set structure.
Parent authorities: `docs/REALM_LADDER_V2_SPEC.md`, `docs/BODY_CULTIVATION_V2_SPEC.md`, `docs/COMBAT_STATS_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`, `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`, `docs/P3_7_BUILDING_TREE_SPEC.md`.

This **does not** close the entire Weapon + Equipment V2 design, add runtime content or authorize gameplay coding. The actual Godot P0 map/content and P2.6 equipment remain compatibility baselines until an explicit implementation/migration phase.

## 1. Prior map decision vs new extension — do not conflate

**Previously user-locked map topology (2026-10-08 discussion):**
- One hunting **map has 10 clusters/areas**.
- Each cluster supports **at most 30 simultaneously hunting disciples** (party maximum = 6).
- No room-by-room maps/load transitions.
- Each cluster has its own specialty: enemies, material(s), resources, objectives, events.
- A map's overall roster is not hard-gated by the 30-person cluster limit. Disciples outside active cluster encounters may queue, transit, return or be assigned elsewhere; do not interpret 30 as a per-map cap.
- Party effects affect the exact party; shared target debuff caps use encounter/global target authority.

**New V2 map-to-realm matrix design:**
- **30 primary progression maps**, one for each of the 30 Tu Vi realm bands; **each has 10 clusters**, yielding **300 baseline authored clusters**. This is NOT "ten separate maps per realm".
- Other event maps, Bí Cảnh, side regions and future expansions may be added without changing this primary grid.
- Primary map `hunt_rNN` corresponds to realm index NN; cluster `c01..c10` has a recommended Tu Vi floor from that realm's ten floors, not an access lock or fixed-only monster tier.
- Example: `hunt_r05/c07` recommends Kim Đan tầng 7 (global floor 47). Its monsters may occupy a declared range, and unusual Elite/Boss events can exceed it.
- Map recommendations and expedition viability remain **soft**. Character Tu Vi/Luyện Thể are independent; a lower body-floor disciple may still enter and stay for less time. Expedition Stamina is 100/day baseline and respects the 18h matching-floor / 22h body-only / 24h ordinary final envelope from Body V2.
- A cluster is a gameplay activity/encounter area, **not an extra character realm/floor**.
- Design-level baseline: no hard minimum realm to walk into a primary map. Unlocked travel/navigation, special events or named instances may have explicit story/route conditions; do not convert general recommended floor into a hard entry gate.

## 2. Canonical 30-row matrix

Columns:
- Gear tier = canonical `equipment_realm_index` 1..30, aligned to the named **Tu Vi realm band** at the same index.
- Each primary map `hunt_rNN` contains `c01..c10`.
- Illustrative materials are **family/content names**, NOT existing `ResourceRegistry` IDs and NOT approval to create a stack of anonymous `material_power`. Exact material IDs/quantities/recipes require content authoring.
- Every row can generate normal item bases and a full set variant via recipes/Elite/Boss reward definitions. Different ranks change base stats and materials; the 12 quality grades remain separate.
- Boss at cluster 10 is a default specialty/boss opportunity, not the only boss spawn in a map.

| Gear tier | Realm band | Tu Vi realm | Primary map ID (10 clusters) | Thematic crafting-material family (examples, not registered IDs) | Region/monster/Boss theme (authoring seed) |
|---:|---|---|---|---|---|
| 01 | Nhân | Phàm Nhân | `hunt_r01` | Mộc trúc, Phàm Thiết | Rừng nhập môn, linh thú nhỏ |
| 02 | Nhân | Luyện Khí | `hunt_r02` | Thanh Thiết, Linh Mộc | Linh thú và mạch khoáng sơ cấp |
| 03 | Nhân | Trúc Cơ | `hunt_r03` | Huyền Thiết, yêu cốt sơ cấp | Thạch khê, cổ lâm và yêu động |
| 04 | Nhân | Tử Phủ | `hunt_r04` | Tử Tinh Khoáng, linh cốt | Linh phủ tàn tích, dị thú |
| 05 | Nhân | Kim Đan | `hunt_r05` | Đan Văn Khoáng, yêu đan | Đan hỏa địa mạch và Kim Đan yêu vương |
| 06 | Nhân | Nguyên Anh | `hunt_r06` | Anh Linh Khoáng, yêu nguyên | Nguyên anh yêu thú và cổ động |
| 07 | Nhân | Hóa Thần | `hunt_r07` | Thần Thức Khoáng, linh hồn tinh hoa | Hồn vực và yêu tướng |
| 08 | Nhân | Luyện Hư | `hunt_r08` | Hư Linh Khoáng, hư tinh | Hư không khe nứt và dị thú |
| 09 | Nhân | Hợp Thể | `hunt_r09` | Hợp Nguyên Khoáng, hợp linh cốt | Hợp linh cổ địa và đại yêu |
| 10 | Nhân | Đại Thừa | `hunt_r10` | Đại Thừa Khoáng, kiếp nguyên | Đại thừa cấm địa, tiền kiếp cảnh |
| 11 | Tiên | Nhân Tiên | `hunt_r11` | Tiên Thiết, tiên thú liệu | Tiên vực sơ khai |
| 12 | Tiên | Địa Tiên | `hunt_r12` | Địa Tiên Khoáng, địa mạch tiên tinh | Tiên mạch, địa thú |
| 13 | Tiên | Thiên Tiên | `hunt_r13` | Thiên Tiên Khoáng, thiên linh cốt | Thiên đình tàn khu |
| 14 | Tiên | Chân Tiên | `hunt_r14` | Chân Tiên Khoáng, chân tiên thú nguyên | Tiên sơn bí vực |
| 15 | Tiên | Huyền Tiên | `hunt_r15` | Huyền Tiên Khoáng, huyền tiên cốt | Huyền giới bí địa |
| 16 | Tiên | Kim Tiên | `hunt_r16` | Kim Tiên Khoáng, kim tiên nguyên | Kim tiên chiến trường |
| 17 | Tiên | Thái Ất Kim Tiên | `hunt_r17` | Thái Ất Khoáng, thái ất tinh | Thái Ất động thiên |
| 18 | Tiên | Đại La Kim Tiên | `hunt_r18` | Đại La Khoáng, đại la tiên cốt | Đại La cấm vực |
| 19 | Tiên | Tiên Vương | `hunt_r19` | Tiên Vương Khoáng, vương thú nguyên | Vương vực và tiên quân di tích |
| 20 | Tiên | Tiên Đế | `hunt_r20` | Tiên Đế Khoáng, đế nguyên | Đế giới, tiên kiếp di địa |
| 21 | Thần | Thần Nhân | `hunt_r21` | Sơ Thần Khoáng, thần thú liệu | Thần địa sơ nguyên |
| 22 | Thần | Chân Thần | `hunt_r22` | Chân Thần Khoáng, chân thần nguyên | Thần vực cổ xưa |
| 23 | Thần | Thiên Thần | `hunt_r23` | Thiên Thần Khoáng, thiên thần cốt | Thiên thần vực |
| 24 | Thần | Thần Quân | `hunt_r24` | Thần Quân Khoáng, quân thần tinh | Thần quân cổ chiến trường |
| 25 | Thần | Thần Vương | `hunt_r25` | Thần Vương Khoáng, vương thần nguyên | Thần vương di giới |
| 26 | Thần | Thần Hoàng | `hunt_r26` | Thần Hoàng Khoáng, hoàng thần cốt | Thần hoàng hỏa địa |
| 27 | Thần | Thần Đế | `hunt_r27` | Thần Đế Khoáng, đế thần nguyên | Thần đế cấm vực |
| 28 | Thần | Thần Tôn | `hunt_r28` | Thần Tôn Khoáng, tôn thần tinh | Thần tôn đạo trường |
| 29 | Thần | Hỗn Độn Thần | `hunt_r29` | Hỗn Độn Khoáng, hỗn độn nguyên | Hỗn độn biên vực |
| 30 | Thần | Sáng Thế Chủ | `hunt_r30` | Sáng Thế Khoáng, sáng thế tinh | Sáng thế nguyên cảnh |

**Important**:
1. Realm index 1..30 and its names follow `REALM_LADDER_V2_SPEC.md` exactly; the text above is NOT a second realm ladder.
2. Thematic material and map-description columns are **content direction only**; specific names, drop rates, unique IDs, recipes, monster roster, authored layouts and visual acceptance are NOT locked or implemented yet.
3. Current `P0Content.REGIONS` includes Thanh Trúc Lâm / Bạch Thạch Khê / Hắc Phong Cốc, but their current numeric danger/recommended-power values are NOT proof of canonical R01/R02/R03 V2 assignment. Old map IDs and saves must be migrated without assuming a new rank from display name.
4. Early `ResourceRegistry` covers only a small low-level subset. Never claim all 30 rows have live materials/map assets in code.
5. Cross-realm ascension events are not a 31st gear tier or an extra compulsory 11th cluster.

## 3. Ten cluster roles (each map has unique content)

| Cluster | Baseline floor recommendation | Specialty template; vary by map | Gear/reward function |
|---|---:|---|---|
| c01 | 1 | Entry/wildlife, safe approach | Common equipment bases / early materials |
| c02 | 2 | Mineral/ore feature | Gear metal/mineral family |
| c03 | 3 | Forest/organic feature | Wood/leather/organic crafting family |
| c04 | 4 | Beast den | Beast bone/hide/core family |
| c05 | 5 | Local elemental hazard/foe | Element-specific equipment inputs |
| c06 | 6 | Rare plant/essence/old cache | Refinement/repair inputs; optional formula fragment |
| c07 | 7 | Elite patrol | Improved quality rolls / selected set pieces |
| c08 | 8 | Ancient ruin/secret chamber | Set blueprints, affix-related rare items |
| c09 | 9 | Dangerous lair/boss trace | High-tier materials and boss preparation |
| c10 | 10 | Realm-peak Boss/danger hotspot | Targeted set piece/boss component, rare recipe/inscription source |

Roles are an **authoring baseline**, not rigid identical biome layout for 30 maps. A desert, swamp, ocean or void map may change material types, geometry and boss positions as long as 10 genuinely distinct specialties, recommended floors and drops are authored. The 30-active-disciples constraint is per cluster; 6 per party; no forced equal split of 30/6, and no cluster-wide party buffs.

## 4. Gear tier, quality, enhancement, equip legality

- `equipment_realm_index = 1..30`: determines **base stat scale and appropriate source tier**, aligned with realm index; never make 300 different item base tiers just because each realm contains 10 cultivation floors.
- `quality_grade = 1..12`: Phàm / Tinh / Thượng / Cực / Linh / Huyền / Địa / Thiên / Vương / Thánh / Đế / Chí Tôn; controls eligible number/range/rarity of affixes and special inscriptions. It does not directly become a character's `DiscipleQuality`.
- `enhancement = 0..15`: applies to the item's base stat component; never multiplies RealmBodyCore or all unrelated flat source stats.
- `affixes` / `special_effects` / `true_inscription` are separate explicit channels; the previously discussed provisional cap for Chí Tôn is up to 6 ordinary sub-lines + 2 special effects + 1 Chân Văn, pending final affix-budget balance. Avoid per-hit recursive proc loops.
- No `Phẩm Lực` or global item quality-point pool.
- Standard physical equipment and weapon types check **Tu Vi OR Luyện Thể realm index >= item tier**; explicitly spiritual-force-driven items check Tu Vi, explicitly body-technique-driven items check Luyện Thể. Realm floors do not silently impose a second condition.
- This is a use/equip requirement, **not a profession-work requirement**: a low-realm but highly capable Luyện Khí Sư may forge elevated items if recipe, facility, materials and profession capability permit.
- `style_tag` != `weapon_requirement`. Gear equipped as sword satisfies an authored `weapon_requirement=sword`; a `style_tag=sword` skill with `weapon_requirement=none` is playable weaponless. No default independent weapon-mastery stat.
- Different weapon types remain free to equip across Chủ Đạo where requirements permit; skill requirements determine cast eligibility, not global class lock.

## 5. Set equipment / Đồ Bộ V2 — structure locked

**Active ordinary equip slots**: weapon, armor/giáp, head/mũ, footwear/giày, pendant/ngọc bội (5). The separate later loadout preserves 3 Phù slots + 2 Pháp Bảo slots (10 equipped slots total); 4 consumable belt slots are NOT part of ten. Phù and Pháp Bảo V2 mechanics are their own future authority.

**Set pieces**:
- By default sets occupy **Giáp + Mũ + Giày + Ngọc Bội**, **not the Weapon slot**. This preserves weapon-style freedom and allows a set to support different Kiếm/Thể/Pháp roles.
- Every set has an explicit `set_lineage_id` (e.g. Hộ Sơn) and `set_generation` (Nhân/Tiên/Thần). Matching is by owned/equipped item instances with legal slots, not appearance or random shared stats.
- Default milestones: **2-piece simple stat/role identity**; **3-piece meaningful authored combat mechanic**. No default 4-piece universal bonus. The fourth slot lets the player do **2+2 with two independent sets**, or **3+1 (three-piece set plus free slot)**.
- Each single item counts for exactly one set; no double-counting. Every member of a two/three-piece set must be **legally equipped and effect-enabled**. Across different generations, pieces do NOT secretly combine into a higher-generation set.
- All 30 equipment tiers may host set pieces where a recipe/loot pool exists, including early progression; higher tiers have new sets and/or authored successors to old set lineages. There must always be a non-Boss path to basic set progression, plus targeted Elite/Boss/secret-region chase loot.
- Set effects from an older generation do **not** automatically upgrade to Tiên/Thần effects. An authored successor/upgrade path with explicit materials and conditions is required.
- Matching set pieces at different item realm tiers within the same generation may activate the family, but any tier-scaled magnitude is bounded by **the minimum contributing gear tier**. This prevents one high-tier piece + cheap low-tier items from faking top-tier set effects.
- Set effect source is item/loadout-derived only; removing/switching, broken/disabled state, and invalid equip instantly invalidate the bonus. A set is NOT a second passive-skill slot or Pháp Bảo.
- Party/team auras of the same set family obey **strongest-only**, or an explicitly authored shared encounter cap; 6 disciples must not stack 6 copies into a runaway buff. Reflection/lifesteal/proc effects follow Combat Skills V2 recursion/safety rules.
- Sources: targeted area/Elite/Boss drop, recipes/blueprint unlock, Luyện Khí Điện forging, authored conversion, and Phường Thị only when that item pool is legitimately available. Loot resolves into canonical sect stock.

**Initial candidate set lineages (identity/role proposals; exact unlock thresholds, numeric stats, effects and source pools are NOT yet design-locked):**
1. Hộ Sơn — HP/Defense -> eligible hit protection.
2. Truy Phong — Movement -> positioning/cast-use support (NOT turn order).
3. Sát Tinh — Crit Chance -> bounded Crit Damage/execute window.
4. Thanh Linh — Healing/Shield -> conditional team rescue.
5. Huyết Chiến — Attack -> low-HP condition, no self-cost farming.
6. Phá Cương — Defense Penetration -> punish defense-down targets.
7. Ngũ Hành — elemental Skill Effect -> named five-element payoff.
8. Hàn Vân — Effect Hit/Resistance -> cold/control specialization.
9. Cửu Lôi — Lightning Skill Effect -> bounded secondary hit/ICD.
10. Tịnh Thần — Effect Resistance -> anti-control/cleanse window.
11. Thiên Trận — Shield Effect -> strongest-only formation support.
12. Hỗn Độn — specialized high-gen protection/rule counter, explicit effect tier.

No set/weapon stat introduces turn-order Speed, ordinary Accuracy/Dodge, global Mana, free Kiếm Ý resource, physical/magical Attack split or independent `combat_power` authority.

## 6. Map -> loot -> craft -> upgrade matrix

For each `hunt_rNN/cXX`, content authoring must specify:
- `recommended_global_floor = (NN - 1)*10 + XX` as display/soft recommendation;
- monster rank distribution, elite rate, Boss opportunity, injury risk, travel time, stamina components, supply consumption;
- explicit `ResourceRegistry` IDs of ore/wood/beast/essence/element materials; no generic aggregated mineral power;
- item drop pool with `equipment_realm_index` and quality distribution, set pools and blueprint/inscription pools;
- first-clear/rare loot and deterministic repeat source for materials that are necessary to maintain progression (no impossible recipe/dead end);
- player-readable specialties; targetable farm/auto policy.

**Minimal source completeness per realm tier**: common gear base; forge ore; organic/beast component; enhancement/repair material; optional set piece/blueprint source; Elite/Boss rare upgrade component. A rare inscription may be obtainable only via named high-end sources, but basic tier advancement must have a repeatable path.

**Upgrade paths**:
1. Forge a new gear instance from explicit tier recipe; item quality/affixes generated deterministically once from world seed + unique forge/drop index + content ID.
2. Enhance +0..15 with explicit tier-appropriate inputs; deterministic success; no destruction.
3. Refine eligible affix magnitude; upgrade rule/cap owned by affix definition.
4. Reroll selected affix with old/new keep choice; cannot bypass costs, locks or valid affix pools.
5. Raise quality only through explicit tier-specific recipe; protect history and invested upgrades.
6. Raise item realm tier through `r -> r+1` with **new-rank resources**, valid facility/profession/recipe and real production time; no arbitrary transmutation from infinite low-rank goods.
7. Inherit selected paid investment from old to a legitimately better new item through an explicit compatibility, capacity and source-consumption contract; do not duplicate valuable upgrade state.

**Balancing guardrails**:
- RealmBodyCore from cultivation/body is independent from equipment base; Tiềm Lực only affects RealmBodyCore.
- 12 quality grades never permit low-rank equipment to erase arbitrary gaps across the 30 item realm indices.
- Elemental effects route to canonical elemental keys and defense/resistance/counter pipeline.
- Ordinary same-channel percentage bonus composes through Combat Stats V2; percent damage reduction and elemental resistance use independent remaining-damage sources.
- +15 enhancement is a starting **design direction**, not a proven final coefficient. Exact numeric base curves, gear contribution ceilings, 12-quality distribution, set effects, set/drop rates, cost curves and late-game material IDs remain to be benchmarked and designed.
- No second reward loot warehouse, personal item ownership or per-disciple giant backpack.

## 7. Ownership override — explicit newer user decision

**ALL equipment/gear is sect-owned.** Disciples are assignees/users, not owners.
- Loot, crafting and external acquisitions produce individual items in the canonical Sect Warehouse/unique item registry.
- Set/equipment pieces may be assigned, reassigned, auto-equipped, reserved, locked, sold or dismantled by user policy and explicit commands.
- No personal gear ownership, gifting semantics, Contribution compensation, forced confiscation economics, disciple spending personal currency to acquire ownership.
- Personal Spirit Stones/Contribution still exist for other uses and do not determine item title.
- Unique item `owner_id` in the P2.6 compatibility runtime means **equipped user mapping**, not future V2 property title. Preserve old save IDs/affixes/locations via explicit deterministic migration, without changing locked P2 gates prematurely.
- Newer decision supersedes conflicting personal-equipment-ownership and mandatory internal gear-buying text from the old P3.7 loadout/economy specs.

## 8. Implementation and balance debt (not locked by this matrix)

- 30x10 actual authored maps, 300 distinct areas, enemy/Elite/Boss content, rates and navigation/visual assets.
- All exact `ResourceRegistry` IDs and no-gap 30-realm gear/material recipe catalogue, forge station/profession prerequisites.
- Final 12-grade per-realm affix budget/stat bounds/rare line percentages; exact high-end set identity catalogue (the 12 above are candidates).
- Full upgrade/refinement/reroll/inheritance prices, durations and deterministic RNG rules, transfer compatibility and UI.
- Exact body-vs-realm equip-requirement exceptions and broken-item behavior.
- Equipment-set numeric balance against Realm+Body progression and 1 Thường + 4 Active + 6 Combat Passive.
- Automated equipment scoring, reserving and protecting sets at 1,000–3,000 disciple scale.
- Migration of legacy P2.6 three slots, item definitions, combat_power, item user mapping, old talisman -> Phù #1; full Godot 4.7.2 tests.
- Follow-up authority for Phù + Pháp Bảo V2 remains separate.

This matrix is a **design checkpoint**, not runtime completion. Continue Weapon + Equipment V2 detailed design; do not code without explicit permission.
