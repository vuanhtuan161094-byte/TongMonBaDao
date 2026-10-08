# WEAPON + EQUIPMENT V2 — MA TRẬN CẢNH GIỚI, MAP VÀ ĐỒ BỘ

Date: 2026-10-08
Status: **MAP CONTENT PROJECTION; EQUIPMENT/SETS MOVED TO NEW CANONICAL DOCS; NOT IMPLEMENTED**
Owner: Realm-to-map planning. Gear and set authority moved to `docs/WEAPON_EQUIPMENT_V2_SPEC.md` and `docs/EQUIPMENT_SETS_V2_SPEC.md`.
Parent authorities: `docs/REALM_LADDER_V2_SPEC.md`, `docs/BODY_CULTIVATION_V2_SPEC.md`, `docs/COMBAT_STATS_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`, `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`, `docs/P3_7_BUILDING_TREE_SPEC.md`.

This document is map-to-equipment planning only. It does not authorize gameplay coding or claim authored map/content availability. The newer gear/set design structure has separate canonical documents. The actual Godot P0 map/content and P2.6 equipment remain compatibility baselines until an explicit implementation/migration phase.

## 1. Prior map decision vs new extension — do not conflate

**Previously user-locked map topology (2026-10-08 discussion):**
- One hunting **map has 10 clusters/areas**.
- Each cluster supports **at most 30 simultaneously hunting disciples** (party maximum = 6).
- No room-by-room maps/load transitions.
- Each cluster has its own specialty: enemies, material(s), resources, objectives, events.
- A map's overall roster is not hard-gated by the 30-person cluster limit. Disciples outside active cluster encounters may queue, transit, return or be assigned elsewhere; do not interpret 30 as a per-map cap.
- Party effects affect the exact party; shared target debuff caps use encounter/global target authority.

**Proposed map-to-realm content projection (not independently user-locked):**
- **Proposed 30 primary progression maps**, one for each of the 30 Tu Vi realm bands; **each has 10 clusters**, yielding **300 proposed, NOT authored/implemented clusters**. This is NOT "ten separate maps per realm".
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
- Each row is intended to permit gear and suitable selected set pieces through authored recipes/Elite/Boss rewards where such content is later defined. Not every one of 24 sets must drop on every map. Different ranks change base stats and materials; the 12 quality grades remain separate.
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

## 4. NEW EQUIPMENT + SET AUTHORITIES — SUPERSEDES OLD RULES

**Current approved gear structure**: `docs/WEAPON_EQUIPMENT_V2_SPEC.md`.
**Current approved 24-family set matrix**: `docs/EQUIPMENT_SETS_V2_SPEC.md`.

Old content under this path claiming five ordinary equipment slots, 2/3-only sets, four set positions including Ngọc Bội, Chân Văn Cộng Hưởng, a fixed +15 enhancement maximum, twelve-only set roster or free automatic set procs is **RETIRED**. Do not recover it as alternate authority.

- Ordinary gear = **10 slots**. 3 Phù + 2 Pháp Bảo + 4 consumable slots remain separate.
- Quality 1..12; at Chí Tôn max 6 ordinary sub-lines + 2 rare specialized **stat** modifiers + one individual, non-free Chân Văn capacity.
- Sets use **Mũ/Giáp/Phi Phong/Hộ Uyển/Đai/Giày**, four specified pieces per family, cumulative thresholds 2/3/4, 3+3 both active; no automatic new battle ability or set-level Chân Văn.
- Realm gear tier 1..30, independent from twelve quality grades and 300 cultivation floors. Exact Attack/Defense/HP item numbers and % ceilings are not approved.
- Enhancement cap, forging/transmission prices, item quality-roll probabilities, rare effect implementation and materials are design OPEN.

## 5. MAP → LOOT → CRAFT — PLANNING REQUIREMENTS

For any future authored `hunt_rNN/cXX`, define explicitly: recommended realm floor, actual enemies/Elite/Boss, travel/stamina/costs, real ResourceRegistry material IDs, legal item-tier+quality pools, which of the 24 set lineages may drop, blueprints/inscriptions, repeatable core-material paths and optional rare chase content. No phantom per-map material ID or non-existent equipment content.

Generic cluster roles c01–c10 above describe a proposal for source distribution, not implemented 300 zones. Any non-mandatory Boss source should have non-Boss access to baseline material progression; named rare variants may use Boss/chase.

## 6. OWNERSHIP AND EQUIPMENT COMPATIBILITY

**100% Sect-owned items**: Sect Warehouse + unique-item registry; disciple is only the equipment assignee. No private gear title, private buying, gear donation, compulsory requisition or Contribution compensation. Old P2.6 `owner_id` means a migration-equipped user, not property title. Gear may be reassigned by Sect policy with locks/reserves. No secondary loot warehouse.

Old Godot P2.6 weapon/armor/talisman, old quality list and old saves remain compatibility data. **No runtime or UI migration is authorized or claimed by this documentation commit.**

## 7. REMAINING DESIGN/IMPLEMENTATION DEBT

- RealmBodyCore Attack/Defense/HP and final per-tier gear contributions;
- real crafting and source content for 30 item tiers, 12 quality grades, 24 set families;
- fully authored individual Chân Văn effects, proc event rules and test coverage;
- forging/refining/enhancement cap/costs and transfer rules;
- real mining/forging/alchemy/talisman/profession-quality consumer checks;
- deterministic auto-equip preserving set thresholds for 1,000–3,000 disciples;
- legacy equipment+save migration and genuine official Godot 4.7.2 tests.

**Only "one map has ten specialty clusters" is treated as prior user-accepted map topology.** The projection **30 primary maps × 10 clusters = 300** is still proposed content planning, NOT a separate explicitly approved count of playable maps.

