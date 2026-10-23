# X1 — BỘ NỘI DUNG R01–R03: QUÁI, NGUYÊN LIỆU, 36 MẪU TRANG BỊ RIÊNG VÀ NGUỒN RƠI

**Ngày:** 2026-10-23 · **Trạng thái:** DESIGN PROPOSAL, **KHÔNG PHẢI DATA ĐÃ CODE, KHÔNG PHẢI PHẨM/RATE ĐÃ KHÓA**.  
**Authority:** `AGENTS.md`; `docs/REALM_LADDER_V2_SPEC.md`, `docs/WEAPON_EQUIPMENT_V2_SPEC.md`, `docs/EQUIPMENT_SETS_V2_SPEC.md`, `docs/design/TMB_CROSS_SYSTEM_REALM_CONTENT_INTEGRITY_CONTRACT_2026-10-23.md` on source branch. Source main `29b5fba4`; CARE PR24 `4d08984f`; stacked PR25 `710137c0` (draft, unmerged at audit).  
**Owner selected:** S2 balanced / F1 target-forge guaranteed usable item / Q1 quality primarily legal affix capacity; **each realm has independent appropriate item families and sources**. Gear grade (1–12) is separate from gear realm tier (1–30), character realm×floor and the technique/skill rarity. **No code, no merge, no PR24/25 touch.**

**Legend:** `SOURCE` = present inspected source, `LOCKED` = explicit owner mechanics, `PILOT` = real but not complete V2 content, `PROPOSED` = hypothetical item/drop/recipe/number. Prefix `x1_` guarantees this catalog cannot be mistaken for existing live item/resource IDs; these IDs **do not exist in ResourceRegistry/EquipmentSystem**. Table below describes what **would be authored**, not save data or drops currently working.

## 1. Cảnh giới/vùng săn: actual facts and stage-specific proposal

| Tier | Realm name | Sources already LIVE | Proposed distinct progression location and enemies | Completion boundary |
|---|---|---|---|---|
| R01 | **Phàm Nhân** | `HuntingMapV2` Thanh Trúc Lâm realm1/floor1, Bạch Thạch Khê realm1/floor3, Hắc Phong Cốc realm1/floor6; `B3PilotContent` Thanh Lang one hide per legitimate kill | Leverage exactly these regions; `Trúc Thử` normal, `Thanh Lang` normal, `Hắc Lang` normal; existing `Nham Giáp Thú` and `Hắc Lang Vương` are elite/boss **loot_ready=false** | Preserve previous pilot receipts and never call R01 content-complete until matching recipes/UI/source pass |
| R02 | **Luyện Khí** | No real realm2 region in `HuntingMapV2`; `thanh_thiet`, `tinh_lang_bi`, `yeu_dan` registered resources. Legacy P2 Thanh Thiết Kiếm recipe exists, **not** V2 R02 tier assignment | `x1_region_r02_thiet_lam`: `x1_thiet_tich_lang` normal, `x1_thiet_bi_yeu` normal, `x1_thiet_noi_ve` elite, `x1_thiet_lang_vuong` boss. Normal mobs farm ore/hide; elite/boss rare blueprint/chase | All **PROPOSED**, no actual encounter/renderer/spawn/schema |
| R03 | **Trúc Cơ** | No real realm3 region; `huyen_thiet`, `tu_van_thao`, `linh_tuy` already registered; current early-map *rare* Huyền Thiết is not sufficient evidence of a scalable R03 source | `x1_region_r03_huyen_thach`: `x1_thach_viên` normal, `x1_thach_giap_yeu` normal, `x1_truc_co_ho_ve` elite, `x1_huyen_thach_yeu_vuong` boss | Materials+recipe+skill/boss table below are **PROPOSED** |

- **LOCKED:** one authored hunt map concept may include ten specialty clusters; `HuntingMapV2.LEVELS=1..5` are *difficulty settings*, not 5 character ranks. Thirty primary maps is old **proposal**; X1 requires real distinct progression content even if zones reuse the same physical map.
- **LOCKED:** maps recommend strength but do **not** globally hard-lock under-level entrants; retreat/injury/weakness remains gameplay consequence. Track `monster_realm_index/floor` independently from cultivator/body ranks.
- **LOCKED:** R01–R03 are all **Nhân Giới**: no free Tiên/Thần skill generations, no Chí Tôn from inexpensive basic forge.

## 2. Materials (real resource catalog vs proposed missing source)

| Resource ID | Origin and actual status | R01 source | R02 proposed source | R03 proposed source | Proposed consumer |
|---|---|---|---|---|---|
| `linh_moc` | SOURCE real, `realm_grade=pham`, `realm_rank=0` | Linh Lâm or encounter loot (actual rules) | starter continuity material | starter continuity material | all three realm recipes as non-exclusive wood |
| `thanh_thiet` | SOURCE real, `realm_grade=luyen_khi`, `realm_rank=1` (resource metadata ≠ item tier) | real Mine and some **encounter-win** rewards | normal proposed `x1_thiet_tich_lang` and mine upgrade | not required as R03 main ore | R01 bridging pilots and R02 core forge |
| `tinh_lang_bi` | SOURCE real, `realm_grade=luyen_khi` | B3 CARE: **1 per paid Thanh Lang kill** | proposed normal hide sources | optional earlier material only | early armor/garments |
| `yeu_dan` | SOURCE real | `HacPhongCoc` existing *encounter-win* rewards | proposed 10–12% ordinary monster drop | proposed 16% ordinary monster drop | R02/R03 pills, technique teaching costs |
| `huyen_thiet` | SOURCE real, `realm_grade=truc_co`, `realm_rank=2` | rare *encounter-win* reward in existing R01 regions | optional small bridging stock | **PROPOSED** repeatable normal R03 loot/mine; not gated behind Boss | R03 core forge and manuals |
| `tu_van_thao` | SOURCE real, `realm_grade=truc_co` | Bạch Thạch Khê encounter and Spirit Field crop | future cultivation ingredient | Spirit Field crop + proposed R03 gather | R03 medicines |
| `linh_tuy` | SOURCE real | Thanh Trúc Lâm rare+guaranteed win progression (different receipt unit) | optional technique research | optional medicine/special essence | authored output only |
| `x1_r03_thach_thu_bi` | **PROPOSED NEW ID; not registered** | none | none | repeatable normal monster hide, 55% per eligible valid kill proposal | R03 armor/cape/boots and no Boss-only baseline |

**Critical:** using `thanh_thiet` during R01 is currently a REAL early-world behavior; it is an explicit early trans-tier availability, **not** proof that `ResourceRegistry.realm_rank=1` maps to Phàm Nhân item tier1. Versioned mappings required before runtime.

## 3. Normal/Elite/Boss drops — separate units and identities (ALL NEW RATES PROPOSED)

| Encounter | Owner of payout | Proposed reward roll on valid outcome | Why |
|---|---|---|---|
| R01 CARE Thanh Lang (SOURCE) | `B3HuntWorld` paid `kill_id`/generation | guaranteed exactly 1 `tinh_lang_bi`; **this currently exists** | baseline non-boss hide faucet and test |
| R01 legacy region encounter (SOURCE) | `HuntingMapV2.claim_reward()` at completed encounter/win ID | existing per-encounter specific resources; **not** an extra per-kill faucet on a CARE battle | preserve existing legacy results, no double counting |
| R02 normal (PROPOSED) | new **per-kill** settlement by world/monster/kill ID | `thanh_thiet` 70%; `tinh_lang_bi` 60%; `yeu_dan` 12%; independent eligible Bernoulli rolls, quantity1 on success | basic ore/hide repeatable; pills material scarce |
| R03 normal (PROPOSED) | new **per-kill** settlement | `huyen_thiet` 55%; `x1_r03_thach_thu_bi` 55%; `yeu_dan` 16%; quantity1 each | no Boss-only progress bottleneck |
| R02/R03 Elite (PROPOSED) | one source-specific **death ID** | bonus template-approved blueprint fragment 8%, fully authored higher-grade item 2%; normal base drops if eligible only once (no bonus duplicate base pool) | sidegrade/skill chase |
| R02/R03 Boss (PROPOSED) | one Boss HP and ONE Sect payout root | eligible blueprint fragment 25%; a *distinct registered* rare direct gear item 5%; rare-material pool if content defined | endgame chase; not essential baseline equipment |
| Manual fragments (PROPOSED) | eligible normal/elite only with `manual_definition_id` | 2% normal fragment, 12% elite; exact faction/discipline restrictions apply | non-Boss means to archive starter/secondary techniques |

All proposals are **per actual eligible kill**, not rewards per clock minute, not per action hit and not per party member; percent rolls are not probabilities of multiple item quantities. Death settlements for Boss use one sect-owned loot root, not one per team. Actual existing `B3PilotContent` has a single wolf-hide receipt; do NOT add the old encounter-win table over the same loop. Spell out deterministic seed/root and chosen content version in settlement history; new player direct Tu Vi per kill is a **separate planned** personal receipt, not automatically from loot.

**Warning:** `MonsterCatalogueV2.SPECIES` elite and boss have `loot_ready=false`; assigning them existing real drops before code would be false. `x1_` monsters do not exist.

## 4. The 36 item templates: 12 per realm (10 occupied slots + two alternative weapons)

Table is **100% PROPOSED** except the 10-slot taxonomy is owner-locked. Only ONE of three weapon-family variants occupies `weapon` in any complete ten-slot loadout. `ATK/HP/DEF` are **flat Combat V2 sources** before same-channel percent modifiers. The numbers are explicitly authored per item, **not `oldSwordATK×G(rank)`**; moving an R01 sword to an R03 wearer does not change its +3.

**Recipe notation:** `ore` (first material in rank table), `wood=linh_moc`, `hide` (third material; R03 hide is PROPOSED). Every output item belongs to the Sect's unique-item registry; no fake `ResourceRegistry` stack quantity for a sword.

| Tier | Proposed unique template ID | Visible item name | Slot/path | Authored Combat V2 flat stats | Proposed ingredient inputs | Status |
|---|---|---|---|---|---|---|
| R01 | `x1_r01_weapon_01` | Mộc Trúc Kiếm | `weapon` | ATK +3 | thanh_thiet:1 + linh_moc:2 | PROPOSED |
| R01 | `x1_r01_head_02` | Trúc Diệp Quan | `head` | HP +6 | linh_moc:2 | PROPOSED |
| R01 | `x1_r01_armor_03` | Lang Bì Giáp | `armor` | HP +20, DEF +2 | thanh_thiet:1 + tinh_lang_bi:2 | PROPOSED |
| R01 | `x1_r01_cloak_04` | Trúc Phong Bào | `cloak` | HP +8 | linh_moc:3 | PROPOSED |
| R01 | `x1_r01_bracers_05` | Trúc Vệ Uyển | `bracers` | ATK +1, DEF +1 | thanh_thiet:1 + linh_moc:1 | PROPOSED |
| R01 | `x1_r01_gloves_06` | Trúc Thủ Sáo | `gloves` | ATK +1 | linh_moc:2 | PROPOSED |
| R01 | `x1_r01_belt_07` | Mộc Linh Đái | `belt` | HP +9 | linh_moc:1 + tinh_lang_bi:2 | PROPOSED |
| R01 | `x1_r01_boots_08` | Trúc Hành Ngoa | `boots` | HP +5 | linh_moc:1 + tinh_lang_bi:2 | PROPOSED |
| R01 | `x1_r01_pendant_09` | Trúc Tâm Bội | `pendant` | HP +6 | thanh_thiet:1 + linh_moc:2 | PROPOSED |
| R01 | `x1_r01_ring_10` | Trúc Diệp Giới | `ring` | ATK +1 | thanh_thiet:1 + linh_moc:2 | PROPOSED |
| R01 | `x1_r01_weapon_11` | Trúc Cốt Quyền Sáo | `weapon` / body | ATK +3 | thanh_thiet:1 + linh_moc:2 | PROPOSED |
| R01 | `x1_r01_weapon_12` | Mộc Tức Pháp Trượng | `weapon` / spell | ATK +3 | thanh_thiet:1 + linh_moc:2 | PROPOSED |
| R02 | `x1_r02_weapon_01` | Thanh Thiết Kiếm · Luyện Khí | `weapon` | ATK +5 | thanh_thiet:3 + linh_moc:1 | PROPOSED |
| R02 | `x1_r02_head_02` | Thanh Thiết Quan | `head` | HP +10 | thanh_thiet:2 + tinh_lang_bi:1 | PROPOSED |
| R02 | `x1_r02_armor_03` | Thanh Thiết Hộ Giáp | `armor` | HP +35, DEF +4 | thanh_thiet:4 + tinh_lang_bi:2 | PROPOSED |
| R02 | `x1_r02_cloak_04` | Thanh Lang Phi Phong | `cloak` | HP +14 | linh_moc:1 + tinh_lang_bi:2 | PROPOSED |
| R02 | `x1_r02_bracers_05` | Thiết Vệ Uyển | `bracers` | ATK +2, DEF +1 | thanh_thiet:2 + tinh_lang_bi:1 | PROPOSED |
| R02 | `x1_r02_gloves_06` | Thiết Lang Thủ Sáo | `gloves` | ATK +1 | thanh_thiet:1 + tinh_lang_bi:1 | PROPOSED |
| R02 | `x1_r02_belt_07` | Thanh Thiết Đái | `belt` | HP +15 | thanh_thiet:1 + tinh_lang_bi:2 | PROPOSED |
| R02 | `x1_r02_boots_08` | Lang Nha Ngoa | `boots` | HP +8 | thanh_thiet:1 + tinh_lang_bi:2 | PROPOSED |
| R02 | `x1_r02_pendant_09` | Thanh Linh Bội | `pendant` | HP +12 | thanh_thiet:2 + linh_moc:1 | PROPOSED |
| R02 | `x1_r02_ring_10` | Thiết Ấn Giới | `ring` | ATK +2 | thanh_thiet:2 + linh_moc:1 | PROPOSED |
| R02 | `x1_r02_weapon_11` | Lang Cốt Quyền Sáo | `weapon` / body | ATK +5 | thanh_thiet:3 + linh_moc:1 | PROPOSED |
| R02 | `x1_r02_weapon_12` | Thanh Linh Pháp Trượng | `weapon` / spell | ATK +5 | thanh_thiet:3 + linh_moc:1 | PROPOSED |
| R03 | `x1_r03_weapon_01` | Huyền Thiết Kiếm · Trúc Cơ | `weapon` | ATK +8 | huyen_thiet:3 + linh_moc:1 | PROPOSED |
| R03 | `x1_r03_head_02` | Huyền Thạch Quan | `head` | HP +17 | huyen_thiet:2 + x1_r03_thach_thu_bi:1 | PROPOSED |
| R03 | `x1_r03_armor_03` | Huyền Thiết Trọng Giáp | `armor` | HP +60, DEF +6 | huyen_thiet:4 + x1_r03_thach_thu_bi:2 | PROPOSED |
| R03 | `x1_r03_cloak_04` | Huyền Vân Phi Phong | `cloak` | HP +24 | linh_moc:1 + x1_r03_thach_thu_bi:2 | PROPOSED |
| R03 | `x1_r03_bracers_05` | Huyền Cốt Uyển | `bracers` | ATK +3, DEF +2 | huyen_thiet:2 + x1_r03_thach_thu_bi:1 | PROPOSED |
| R03 | `x1_r03_gloves_06` | Huyền Linh Thủ Sáo | `gloves` | ATK +2 | huyen_thiet:1 + x1_r03_thach_thu_bi:1 | PROPOSED |
| R03 | `x1_r03_belt_07` | Huyền Trụ Đái | `belt` | HP +26 | huyen_thiet:1 + x1_r03_thach_thu_bi:2 | PROPOSED |
| R03 | `x1_r03_boots_08` | Huyền Thạch Ngoa | `boots` | HP +15 | huyen_thiet:1 + x1_r03_thach_thu_bi:2 | PROPOSED |
| R03 | `x1_r03_pendant_09` | Trúc Cơ Huyền Bội | `pendant` | HP +20 | huyen_thiet:2 + linh_moc:1 | PROPOSED |
| R03 | `x1_r03_ring_10` | Huyền Ấn Giới · Trúc Cơ | `ring` | ATK +3 | huyen_thiet:2 + linh_moc:1 | PROPOSED |
| R03 | `x1_r03_weapon_11` | Huyền Cốt Quyền Sáo | `weapon` / body | ATK +8 | huyen_thiet:3 + linh_moc:1 | PROPOSED |
| R03 | `x1_r03_weapon_12` | Huyền Thạch Pháp Trượng | `weapon` / spell | ATK +8 | huyen_thiet:3 + linh_moc:1 | PROPOSED |

**Item identity notes**:
- `x1_r02_weapon_01` has display name `Thanh Thiết Kiếm · Luyện Khí`. Legacy P2 `thanh_thiet_kiem` remains separate *unchanged* until migration; **no auto-upgrade and no automatic old `combat_power`→V2 Attack**.
- `x1_r03_ring_10` shares a partial *working Chinese-style name* with an existing set lineage `Huyền Ấn`; this is an **ordinary item without any set_lineage_id**, never counts toward a 24-lineage set unless explicitly tagged/approved.
- Weapon variants use the same raw ATK budget at first; their real differences later come from weapon requirements/style skill consumers, NOT a free skill kit from owning a staff/fist/kiếm.
- First V2 low-grade forge `F1` targets one template and its rank; grade 1–3 candidate E0 outcome (75% Phàm, 20% Tinh, 5% Thượng) is **a proposal, not owner locked**. Q1 keeps template base stat unchanged across these grades; higher grade creates only legal extra affix capacity and rolled actual consumers; all 12 grades and 24 set lineages exist in locked *design structure*, NOT in this starter drop table.
- Eleven? **NO:** exactly TEN equipped ordinary slots (1 weapon +9 others), with 2 alternate weapon templates per rank. These 36 templates are *design candidates*, not 36 shipped models or Source A assets. Avoid treating profession sets, three Phù, two Pháp Bảo or four medicine belt slots as extra ordinary gear.

### Complete 10-slot baseline per stage (one weapon chosen, NO affix/set buff/Potential)

| Rank | Added ATK | Added HP | Added DEF | Sum of ingredients for the *10 slots* |
|---|---:|---:|---:|---|
| R01 | +6 | +54 | +3 | thanh_thiet 5, linh_moc 16, tinh_lang_bi 6 |
| R02 | +10 | +94 | +5 | thanh_thiet 18, linh_moc 4, tinh_lang_bi 11 |
| R03 | +16 | +162 | +8 | huyen_thiet 18, linh_moc 4, x1_r03_thach_thu_bi 11 |

**Combat V2 dry arithmetic (NOT engine test, one-target equal-stat reference without crit/skills)**: `Core=(23,190,19)×G(r,1)`; at R01: +6 ATK/+54 HP/+3 DEF gives +26.09% raw ATK, +28.42% HP; against equal rank defender core DEF=19, basic hit damage increases approximately 34.2%. R02: +10 ATK/+94 HP/+5 DEF => +26.35% raw ATK, +29.98% HP, ~34.6% equal-stat basic-hit damage. R03: +16 ATK/+162 HP/+8 DEF => +25.55% raw ATK, +31.32% HP, ~33.5% basic-hit damage. This is a **candidate** coherent S2-compatible starter budget, not a cap; final role DPS/Tank/Healer+quality+set must be tested on real monsters and ability actions.

No additional gear flat bonus is multiplied by `PotentialFactor`; no hidden `combat_power` super-stat; equip legality checks actual track, rank, selected skill requirement. A lower-tier item retains its old flat stats. **No automatic 30-tier weapon scaling.**

## 5. End-to-end forge transaction (F1 direction owner-locked; timings and numbers PROPOSED)

**Common:** choose `item_template_id` and legal equipment tier → check source recipe+building/profession/One Active Job+Sect Warehouse reserved quantities → allocate persistent `forge_order_id`, freeze outcome RNG/recipe revision and input debit receipt → 1 timed order → deterministic legal Phàm/Tinh/Thượng grade draw at settlement → 1 unique Sect-owned item UID + completion receipt → equip authorized wearer → Combat V2 stat source rebuilt once → save/reload no duplicate/refresh race. No second Forge inventory, scheduler or clock; `WarehouseSystem.consume_requirements` memory atomicity is not a disk transaction.

**Proposed starter time** `10 simulation ticks` per basic item (still **OPEN**). Recommend facility Lv1 basic items that use common wood/ore/hide can forge; **do not silently enable advanced monster-material forging** locked at Luyện Khí Điện Lv30. If starter hide is disallowed until Lv30, offer simple wood/ore starter armor with separate recipe and preserve all legacy P2 `tinh_lang_giap` old-save semantics. The sample hide-based recipes above are **candidates conditioned on this policy decision**, not an automatic Lv1 unlock.

**Anti-bug matrix**: invalid resource ID, wrong tier, unavailable item template/loot/recipe, source probability outside 0..1, missing worker, double forge completion, app quit after Warehouse debit, save/reload between roll and UI, item UID concurrently worn by two actors, migrated P2 talisman, two simultaneous Mine+Forge jobs, set generation mismatch, item loss/sale/upgrade under lock, high-tier item on weak actor. All must FAIL CLOSED in future implementation; no changes in this docs packet.

## 6. Baseline stage content gate

- **R01** must produce one true registered starter item using real `linh_moc`, `thanh_thiet`, `tinh_lang_bi` and genuine playthrough; one of the catalog recipes must be reviewed for Lv1 material eligibility. R01 existing CARE kill loot still real.
- **R02** requires actual new realm2 monster sources or legitimate economic mine, distinct `x1_r02_...` item instances, a normal (non-Boss) repeatable resource supply and combat eligibility tests. Existing P2 sword name cannot masquerade as finished R02.
- **R03** requires real `huyen_thiet` farming AND registration/source of `x1_r03_thach_thu_bi` (or approved alternate), a proper R03 area and grade-limited legal craft, not a Boss-only blockade.
- **All ranks:** evidence of acquisition→recipe→Forge→unique item→equipped Combat V2 effect→save/offline→UI exact. No rate, monster, item or recipe in this doc has been implemented or actually tested in Godot.
