# TÔNG MÔN BÁ ĐẠO — R01–R03 CONTENT TRUTH: pilot source vs future realm tiers

**2026-10-23, DOCS ONLY.** **NOT CODED / NOT OWNER BALANCE-LOCKED.** This is the smallest non-fictional content ledger to prevent "one item copied into 30 ranks", fake medicine, imaginary technique drops and mislabeled PvE areas. Gameplay/source: inspected `main=29b5fba448b0178cb520a4ada44b375b4b934e31`, CARE PR24 `4d08984f044bfa29a98070c8d68ee5a155256d3a`. Design authority `TMB_CROSS_SYSTEM_REALM_CONTENT_INTEGRITY_CONTRACT_2026-10-23.md`.

## 1. Evidence: existing early areas are three **locations inside Realm 1**, not 3 rank-specific maps

`godot/src/simulation/combat/hunting_map_v2.gd` has:
- `thanh_truc_lam`: `realm:1,floor:1`, normal species Trúc Thử / Thanh Lang / Hắc Lang; authored encounter resources Linh Mộc, Thanh Thiết, Thanh Linh Thảo; rare Linh Tủy. Elite `nham_giap_thu`, Boss `hac_lang_vuong`, but their `loot_ready=false` in current `MonsterCatalogueV2`: **no per-species unique Boss drops yet**.
- `bach_thach_khe`: **`realm:1,floor:3`**, not r02, normal Trúc Thử/Thanh Lang/Hắc Lang; encounter resources Thanh Thiết/Tinh Lang Bì/Tử Vân Thảo; rare Huyền Thiết; elite Huyết Lang Đầu Đàn/Boss Hắc Lang Vương authoring not fully loot-ready.
- `hac_phong_coc`: **`realm:1,floor:6`**, NOT r03; encounter resources Tinh Lang Bì/Yêu Đan; rare Huyền Thiết.
- `HuntingMapV2.LEVELS=1..5` are **PvE difficulty settings** within a map; previous design's **10 cluster specialties per map** and each cultivation realm's **10 floors** are TWO OTHER independent concepts. Do not silently convert 3 existing regions to `hunt_r01/hunt_r02/hunt_r03`.
- `B3PilotContent` explicitly uses one `bach_thach_khe` wolf, 1 `tinh_lang_bi` per legitimate `slot_generation` *kill*, whereas legacy `HuntingMapV2.preview_reward()/claim_reward` uses an *encounter win* pool. These two **reward units** are different; a future unified loot registry must retain both exact-once roots and not pay both in the same battle.

`ResourceRegistry` currently:
- `linh_moc`: `realm_grade=pham,realm_rank=0`.
- `thanh_thiet`: `realm_grade=luyen_khi,realm_rank=1`.
- `huyen_thiet`: `realm_grade=truc_co,realm_rank=2`.
- `tinh_lang_bi`, `yeu_dan` and `thanh_linh_thao` are early named real resources.
**Semantic warning:** these `realm_rank` integers are existing resource-grade index metadata, NOT proven to equal V2 `equipment_realm_index` for Tu Vi names (R01 Phàm Nhân, R02 Luyện Khí, R03 Trúc Cơ). Never assign gear tier by copying a resource's numeric field or guessing from its label. Resolve with a versioned content mapping.

## 2. Stage coverage truth table

| Stage | OWNER realm name | Target gear/drop family | Real current map evidence | Real resource evidence | Real equipment instance/content chain | Pills, technique/skill evidence | Status |
|---|---|---|---|---|---|---|---|
| R01 | Phàm Nhân | authored Phàm-specific gear group; each actual item has template/ID and legal source | three pilot regions already use realm1 at floors1,3,6 | `linh_moc`, `thanh_thiet` etc existing but no finalized r01-to-resource tier rules | P2 3-slot recipes only, no confirmed V2 rank1 unique gear family/drop | Hồi Xuân pilot real; Tụ Khí CARE pilot; P2 techniques exist but V2 transmissions not full | **PILOT, NOT CLOSED** |
| R02 | Luyện Khí | new individually authored R02 gear family, distinct from R01 | **no HuntingMapV2 realm2 region**; `bach_thach_khe` still realm1 | Thanh Thiết labeled Luyện Khí but `realm_rank=1`: verify mapping and costs | P2 `thanh_thiet_kiem` lacks V2 `equipment_realm_index`; can't automatically label it rank2 | real chapter-2 medicine, manuals and actual sources **NOT AUTHORED** | **NOT CLOSED** |
| R03 | Trúc Cơ | new authored R03 gear family distinct from R02 | **no HuntingMapV2 realm3 region**; `hac_phong_coc` still realm1 | Huyền Thiết has Trúc Cơ label, `realm_rank=2`, may be rare low-level reward already | no distinct R03 V2 item/recipe/forge-to-warehouse source verified | R03 technique/skill/medicine chain **NOT AUTHORED** | **NOT CLOSED** |

Existing `EquipmentSystem` recipes (SOURCE P2 legacy): `thanh_thiet_kiem` needs 3 Thanh Thiết +1 Linh Mộc, `tinh_lang_giap` needs 3 Tinh Lang Bì +1 Thanh Thiết; plus three other P2 recipes. They are real P2 content but NOT evidence of a 12-grade/30-tier V2 forge. F1 targeted forge is owner-selected direction, still not a working timer/receipt.

`TechniqueSystem` P2 uses `MAX_LEARNED_TECHNIQUES=3`, `MAX_TECHNIQUE_LEVEL=5`, existing gacha/fragments/stones logic. The V2 art direction **does not** require fresh manuals every single realm; a learned low-grade technique may carry over, and new authored techniques/Diễn Hóa successors enter where their actual prerequisites/sources support them. NEVER turn P2 grade ID into 30-level technique tier by name.

`AlchemyRecipeRegistry` on main currently has `hoi_xuan_dan` 3 Thanh Linh Thảo, 6 ticks. In CARE, separate `tu_khi_dan` uses 2 Thanh Linh Thảo+1 Linh Cốc, +10,000 fixed Tu Vi, satiety25; Hồi Xuân +55HP, satiety10. There is no implemented R02/R03 medicine ladder by multiplying +10,000 by rank1.65. Any new pills need dedicated recipe, ingredient source, consumer and price.

## 3. Safe first content slice proposal (NOT approved item tables)

**PILOT QA path:** stay on ACTUAL R01 `bach_thach_khe` with Thanh Lang→Tinh Lang Bì, existing warehouse/save receipt. Design one explicitly named R01 compatible V2 **starter** gear/medicine consumer where materials are proven from real source; do NOT fabricate other ranks just to show feature breadth. If a new gear is named, the template_id/grade/slot/bonus and source will be marked `PROPOSED` until approved.

**Promotion to R02:** only after `REGION_CONTENT` authors a genuine realm2 species map/content source, a registered material source, one author-approved R02 gear template, one recipe/direct drop, an actual equip result, and save/UI. Higher-tier maps remain a **proposal** until actually authored. It should be possible to progress with a repeatable normal drop/forge path; Elite/Boss may supply attractive chase variants rather than blocking all ordinary R02 equipment.

**Promotion to R03:** analogous, authored true realm3 content and a legal chain with `huyen_thiet` or other explicitly approved registered resource; don't infer the region from Hắc Phong Cốc's *name*.

## 4. Three meaningful owner decisions after audit

- **D1 — main gear acquisition**: A (recommended) ordinary monsters mainly supply core materials; legitimate targeted forge makes base gear, Elite/Boss offer bonus rare direct gear/blueprints. B normal monsters directly drop most basic gear plus forge alternative. C equipment only through forging and rare Boss blueprints. This is *not* the S2/F1/Q1 choice; all three remain compatible with F1.
- **D2 — authoring density**: A (recommended) authored equipment **group per rank** with 10-slot families and rotating featured weapons/sets, but release incrementally R01–R03 first. B hundreds of full named gear templates from the beginning (expensive/fragile). C only one generic template with rank label change (REJECT: violates owner direction).
- **D3 — material gating/gear migration**: A (recommended) use explicit versioned mapping from early `ResourceRegistry.realm_grade/rank` to R01–R03 content ranks while **keeping old IDs and P2 saved items intact**, with a compatibility-only legacy P2 item path. B rewrite all old IDs/rolls immediately (high migration risk). Do not choose silently.

**Stop condition:** until D1/D2/D3 and cost/drop fixtures are genuinely reviewed, do not lock 10-tick forging or 0.2% Grade12 probability and do not run equipment CODE. Windows UI Codex writer remains separate. No actor/Source A/C4/MAP25 changes allowed by this design.
