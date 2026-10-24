# TÔNG MÔN BÁ ĐẠO — KIỂM TOÁN SOURCE IDs CHO LOOT V3 / THANH TRÚC LÂM
**Ngày:** 2026-10-24 · **STATUS: SOURCE AUDIT / DOCS ONLY** · No Godot tests, code, PR29/UI/Source A edit, Codex packet or merge.

## 0. Inputs / precedence
Owner asks to make A+B source-grounded viable loot source catalogue from branch `docs/ttl-20-camp-monster-catalog-loot-economy-v3-20261024`; the named A+B parent docs are:
- `docs/design/TMB_TTL_20_CAMPS_MONSTER_SPECIES_FIVE_ELEMENTS_CATALOG_V3_2026-10-24.md` — 20 camps, 3 existing normal + 7 **NEW** normal, 300 proposed slots and per-monster realm/element.
- `docs/design/TMB_TTL_MONSTER_KILL_LOOT_EQUIPMENT_ECONOMY_BALANCE_V3_2026-10-24.md` — tentative per-monster materials, equipment/manual categories and artificial rate sensitivity; numerical rates **NOT APPROVED**.
- World Combat background on `docs/worldcombat-v3-heterogeneous-monsters-element-loot-20261024`, current Source A render untouched.

Branch originated at verified `main=29b5fba448b0178cb520a4ada44b375b4b934e31`. PR29 OPEN/DRAFT HEAD `9522812e91b7ca5bc0cc108eb92e000e930fe850` when checked. Authorities: newest owner directives > `docs/GAME_SYSTEM_ARCHITECTURE.md` > canonical subsystem specs > live source. Source inspected in `godot/src/simulation/{resource/resource_registry.gd,resource/warehouse_system.gd,building/alchemy_recipe_registry.gd,equipment/equipment_system.gd,technique/technique_system.gd,combat/hunting_map_v2.gd,combat/monster_catalogue_v2.gd}`; also `docs/{WEAPON_EQUIPMENT_V2_SPEC,EQUIPMENT_SETS_V2_SPEC,TECHNIQUE_V2_SPEC,COMBAT_SKILLS_V2_SPEC,P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC,EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP,DV2_02_PVE_FIVE_LEVEL_RESOURCE_LOADOUT_CONTRACT}.md`.
Notation: **S** = exact ID DEFINITIONS exists in actual ResourceRegistry; **L** = actual legacy P2 system recipe/loot source; **D** = user-approved V2 *design* but not implemented; **N** = proposed candidate ID, does NOT exist; **R** = actual executable V3 per-kill drop route (NONE currently).

## 1. ResourceRegistry is verified: 28 registered IDs, not a huge fantasy item database
**28 S IDs observed in `ResourceRegistry.DEFINITIONS`:**

| Family/role | Actual IDs | Material meaning / guard |
|---|---|---|
| Intro resource/forge/monster | `linh_moc`, `thanh_thiet`, `huyen_thiet`, `tinh_lang_bi`, `yeu_dan`, `linh_tuy` | valid stackable resource IDs; do NOT imply world-per-kill eligibility or individual monster loot chance |
| Ordinary plants/pill/food | `thanh_linh_thao`, `hoi_xuan_dan`, `linh_coc`, `tu_van_thao` | registered; `hoi_xuan_dan` is output/medicine, not implied natural monster drop |
| Building components | `tam_mach_ban`, `linh_tuyen_chi_tam_manh`, `linh_tuyen_chi_tam` | building/milestone resources, NOT automatically monster loot |
| Body progression special gates | `huyet_linh_sam`, `huyet_thu_tinh_huyet`, `kim_cot_thao`, `linh_thu_cot_ngoc`, `tien_tuy_lien`, `tien_thu_chan_cot`, `bat_hoai_tuy_dich`, `dai_la_kim_cot`, `than_mach_tinh`, `than_thu_cot`, `hon_don_tuy_hoa`, `bat_diet_than_cot` | registered high-realm gating IDs; **do NOT drop these casually from a starter map**; exact source and unlock requirements remain under Body canon |
| World/realm seals | `an_nhan_gioi`, `an_tien_gioi`, `an_than_gioi` | progression gate material, excluded from generic weak-monster rolls |

**Audit consequence:** 28 registered resources ≠ 28 valid rewards from Thanh Trúc Lâm. There are currently **no registered** specific materials for the **seven proposed monster species**, no complete V2 gear template registry and no complete V2 manual-fragment source registry. Future V3 source → actual item ID links must be additive and validated. The seven named species also do **not** exist in `MonsterCatalogueV2.SPECIES`.

### 1.1 IDs verified but not monster-reward evidence
- `HuntingMapV2.REGION_CONTENT.thanh_truc_lam.resources` = `linh_moc:3,thanh_thiet:1,thanh_linh_thao:1` and rare `linh_tuy`. These are **PER FINISHED VICTORIOUS ENCOUNTER** through `preview_reward/claim_reward`, with a separate 4-victory Linh Tủy guarantee. **Not one drop per killed rat**.
- `EquipmentSystem.forge_loot_for_victory(result)` returns **legacy** on qualifying P2 `outcome=win`: Trúc Thử→`linh_moc:1`; Thanh Lang→`thanh_thiet:1,tinh_lang_bi:1`; Hắc Lang→`thanh_thiet:2,tinh_lang_bi:1,yeu_dan:1`. **Not** a V3 World Combat per-monster loot table or a V2 equipment drop; no source for guaranteed drops from the seven new species.
- `MonsterCatalogueV2` source currently has `truc_thu` Mộc, `thanh_lang` Mộc, `hac_lang` U Minh, `nham_giap_thu` Thổ Elite, `u_hon` U Minh, `huyet_lang_dau_dan` Hỏa Elite from other region, `hac_lang_vuong` U Minh Boss. Existing `loot_ready=false` on Elite/Boss; no complete World per-kill table. Hắc Lang **NOT Hỏa**.
- `WarehouseSystem` stackable item authority validates registered ID, positive count and `MAX_SAFE_STACK=9000000000000000`; reserve/lock controls consumption. Canonical `P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC`: warehouse **logically unlimited** for ordinary stackables, unique gear/manual per-instance. **Do NOT invent physical Warehouse capacity pressure**: only safe integer bounds, reserved materials, availability and unique-item provenance; backpressure on invalid IDs or transient save/commit, not full storage gameplay.

## 2. Actual existing recipe consumers, P2 bridge vs V2 future
**[L] Actual legacy EquipmentSystem.RECIPES:**
| Recipe ID | Result / legacy slot | Actual ingredient quantity (all S) | Status |
|---|---|---|---|
| `thanh_thiet_kiem` | Thanh Thiết Kiếm / `weapon` | `thanh_thiet×3 + linh_moc×1` | legacy L, not V2 realm/12-grade forge |
| `huyen_thiet_quyen_sao` | Huyền Thiết Quyền Sáo / `weapon` | `thanh_thiet×3 + tinh_lang_bi×1` | legacy L; **despite its name it consumes no `huyen_thiet`** |
| `linh_moc_phap_truong` | Linh Mộc Pháp Trượng / `weapon` | `linh_moc×3 + yeu_dan×1` | legacy L |
| `tinh_lang_giap` | Tinh Lang Giáp / `armor` | `tinh_lang_bi×3 + thanh_thiet×1` | legacy L |
| `hoa_van_ngoc` | Hỏa Vân Ngọc / `talisman` | `yeu_dan×2 + linh_moc×1` | legacy L; `talisman` is NOT V2 ordinary `pendant` and does not authorize dropping it in V2 slot |
**[L] Actual legacy `AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN`:** `thanh_linh_thao×3 → hoi_xuan_dan×1`, 6 ticks. **[OWNER OVERRIDE 2026-10-22]** current owner pill contract separately specifies `thanh_linh_thao×2 + linh_coc×1`, 6 ticks and Hồi Xuân Đan +55 HP / satiety 10. This is a real **source-vs-newer-owner conflict**, NOT license to silently reconcile code in docs-only packet. Future implementation must use owner direction and dedicated focused gate.
**[L] Actual legacy technique consumers `TechniqueSystem.TECHNIQUES`:** `duong_khi_quyet` consumes `linh_tuy×2` for old upgrade; `huyen_giap_cong` `linh_tuy×1+huyen_thiet×2`; `liet_chien_quyet` `huyen_thiet×1+yeu_dan×1`; `thanh_phong_kiem_quyet` `huyen_thiet×2+yeu_dan×1`; `xich_viem_chan_quyet` `linh_tuy×1+yeu_dan×2`; `han_nguyet_tam_phap` `linh_tuy×2+huyen_thiet×2+yeu_dan×2`. P2 fragment IDs use `p23:fragment:<id>` and historical source, **not ResourceRegistry stack IDs or finished V2 Tàng Kinh Các archive entries**.

**V2 [D]** one Main +2 Support, sect transmission archived at first complete manual, mastery five named stages, skills separate from techniques. Drop a complete manual only through explicit separate V2 manual template/transmission, no direct auto-learn or auto-equip. Fragment count and 8/12/18/30 quantities seen in P2 are historical compatibility—not automatically the V2 crafting recipe.

## 3. V2 equipment is a design authority, NOT a completed item registry
**[D] Exact ordinary slots:** `weapon` Vũ Khí; `head` Mũ; `armor` Giáp; `cloak` Phi Phong; `bracers` Hộ Uyển; `gloves` Thủ Sáo; `belt` Đai Lưng; `boots` Giày; `pendant` Ngọc Bội; `ring` Nhẫn. Three Phù + two Pháp Bảo are SEPARATE V2 special slots, not among 10 ordinary; consumables further separate.
**[D] Twelve V2 grades and capacities, from `WEAPON_EQUIPMENT_V2_SPEC.md`:**
| Grade | Name | ordinary lines | rare conditional-stat lines | Chân Văn capacity |
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
|12|Chí Tôn|6|2|1 (empty until separately inscribed)|
**[D]** equipment realm index1..30, separate from quality grade; default equip legality Tu Vi **OR** Luyện Thể when ordinary physical, Tu Vi-only for spiritual gear, Body-only for authored Body gear. `EQUIPMENT_SETS_V2_SPEC` defines **24 sets, exactly four positional pieces each**, using ONLY `head,armor,cloak,bracers,belt,boots`, thresholds 2/3/4, different Nhân/Tiên/Thần generations not mix. Sets do not auto-create active skills, Chân Văn or special proc; item-affix channels must have actual consumer.
**[L]** `EquipmentSystem.VALID_SLOTS` are currently only `weapon,armor,talisman` with old Phàm/Tinh/Thượng quality and legacy equipment_items; do NOT label 10-slot V2 runtime shipped.
**[D]** `EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md` permits future design ORDER and says exact V2 forge inputs, 12-grade chance, enhancement and salvage recipes **OPEN**, no authority to call projected formulas implemented.

## 4. Collision and decision register for companion matrix
1. **Item source name vs ID:** proposed Water/Metal/Fire/Earth special drops must be new stable registered resource IDs; don't relabel `thanh_thiet` as Fire metal or create empty `water_essence` placeholder in Warehouse.
2. **Source applicability:** `tinh_lang_bi` is a real ID/legacy wolf reward, but any **world per-kill** source using it is still a proposal, not proof. `linh_tuy` 4-victory guarantee MUST NOT become every-four-kills guarantee.
3. **Craft sink claim:** label legacy 5 recipes L, owner-approved V2 structure D and new recipe proposal N separately. New V2 crafting components/gear templates require actual registry, not only material names.
4. **Manual IDs:** P2 six technique IDs exist in legacy, but V2 manual transmission first copy and fragment matching is not a native V2 item inventory yet. Need separate versioned manual/item registry and content authorization. One booklet != 4 active skills.
5. **Grade eligibility vs element:** gear realm and grade chosen through distinct authored source gates. A Metal monster is a Metal material origin, not automatic best-grade Metal sword or Sword character class.
6. **Reward ownership:** physical drops Sect-owned; one canonical Warehouse; no 2nd bag and no last-hit duplicate, original reward routing separate. Boss global one HP and one Sect reward pool; no 60/40 locked.
7. **DEV reset rule:** owner chooses fresh DEV save on gameplay version change; same-build within-run save/reload, pending impact, death→receipt and monster generation exactly once still required.
8. **Implementation truth:** current World Combat 30+400, 20 real camp positions, 7 new species, V2 per-kill equipment and first-copy manuals do NOT yet exist. No test/QA, no changes to them in docs-only commit.
