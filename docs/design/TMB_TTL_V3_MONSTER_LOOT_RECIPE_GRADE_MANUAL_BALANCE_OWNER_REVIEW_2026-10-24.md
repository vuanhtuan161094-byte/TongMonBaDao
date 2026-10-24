# TÔNG MÔN BÁ ĐẠO — THANH TRÚC LÂM V3: BẢN ĐỀ XUẤT CÂN BẰNG LOOT / CÔNG THỨC / NGŨ HÀNH / CÔNG PHÁP
## Đợt owner review — 7 loài mới, 9 nguyên liệu, 10 template thường, 6 nguồn công pháp, 20 bãi/300 quái minh họa
**Ngày:** 2026-10-24. **Trạng thái:** **PROPOSED NUMBERS FOR OWNER APPROVAL ONLY**. Không gameplay code, không Codex packet, không merge, không PR29/UI/Source A, không xoá SAVE.
**Owner approval dated 2026-10-24:** đồng ý **về nguyên tắc danh mục** 7 loài mới, 9 vật liệu (hai Elite/Boss vẫn chờ consumer), 10 template V2 và 6 hướng nguồn Công Pháp; **KHÔNG phê duyệt số, tỷ lệ, công thức cuối hoặc CODE**.
**Source baseline:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`, PR29 S1 OPEN/DRAFT `9522812e91b7ca5bc0cc108eb92e000e930fe850` tại lần kiểm tra. Bản đầu vào docs/ttl-v3-verified-loot-sources-crafting-matrix-20261024, hai tài liệu `docs/audits/TMB_TTL_V3_VERIFIED_RESOURCE_EQUIPMENT_TECHNIQUE_RECIPE_SOURCE_AUDIT_2026-10-24.md` và `docs/design/TMB_TTL_V3_MONSTER_ITEM_USE_RECIPE_GEAR_ELIGIBILITY_MATRIX_2026-10-24.md`.
**Read and checked:** AGENTS.md, docs/GAME_SYSTEM_ARCHITECTURE.md, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md, docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md, P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md, P3_7_BUILDING_TREE_SPEC.md, EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md, WEAPON_EQUIPMENT_V2_SPEC.md, EQUIPMENT_SETS_V2_SPEC.md, TECHNIQUE_V2_SPEC.md, COMBAT_SKILLS_V2_SPEC.md and live ResourceRegistry, WarehouseSystem, AlchemyRecipeRegistry, EquipmentSystem, TechniqueSystem, MonsterCatalogueV2 and HuntingMapV2. Implementation status only from code/checkpoint, not from aspiration.
**Labels:** [LOCKED] authoritative owner/canonical design; [CODE VERIFIED] current P2/P3 actual source; [APPROVED DIRECTION] user authorized concept only; [PROPOSED] all new numerical values and rates; [DEFERRED] source consumer not complete; [MEASURE FIRST] requires actual simulated kills/supply before final lock.

## 1. Accepted content without reopening design
- ONE open `thanh_truc_lam` map with **20 spawn/farm camps**, 10–20 monsters/camp (200–400 living when fully populated), 30 disciples selectable RTS-style, automatic combat after arriving and minimap. Camp ecology independently authors monster species/element, monster realm1..30/floor1..10, normal/Elite/Boss, gear/material source. Monster rank DOES NOT match player rank by default.
- [CODE VERIFIED] Existing ordinary monsters `truc_thu` Wood/Mộc, `thanh_lang` Wood/Mộc, `hac_lang` **Nether/U Minh**, Elite `nham_giap_thu` Earth/Thổ, Boss `hac_lang_vuong` **Nether/U Minh**, Fire Elite `huyet_lang_dau_dan` exists but not current TTL spawn pool. Seven new proposed ordinary monster IDs below NOT coded.
- [APPROVED DIRECTION] all seven new species:
  `ttl_thuy_vu_linh` (Thủy), `ttl_thuy_tinh_giai` (Thủy), `ttl_kim_giap_trung` (Kim), `ttl_thiet_tiem_thu` (Kim), `ttl_hoa_van_lang` (Hỏa), `ttl_xich_viem_trung` (Hỏa), `ttl_thach_bi_thu` (Thổ).
- [APPROVED DIRECTION] nine candidate material IDs; seven normal usable only after registration:
  `ttl_thuy_vu_tinh`, `ttl_thuy_tinh_giap`, `ttl_kim_giap_xac`, `ttl_thiet_tiem`, `ttl_hoa_lang_nanh`, `ttl_xich_viem_xac`, `ttl_thach_bi_giap`; **two [DEFERRED]** `ttl_nham_giap_hach` and `ttl_hac_lang_vuong_hon_tinh` cannot drop until their specific consumer/result is actually authored and approved.
- [CODE VERIFIED] ResourceRegistry has **28 resource IDs**, valid starter material sources `linh_moc`, `thanh_thiet`, `huyen_thiet`, `tinh_lang_bi`, `yeu_dan`, `linh_tuy`, `thanh_linh_thao`. Existing source `HuntingMapV2` rewards **a completed encounter** and old `EquipmentSystem.forge_loot_for_victory` rewards a legacy winner; both are NOT V3 per-kill systems. Native V2 10-slot/12-grade gear library and V2 itemized book+fragment registry NOT coded.
- [LOCKED] 10 ordinary slots and 12 grade qualities, item realm1..30, max6 ordinary lines +2 rare **stat-only** lines +1 Chân Văn capacity at grade12, 24 set families in exactly four permitted positions, 1 Main+2 Support techniques, first complete book permanently archives Sect transmission, combat skills separate from techniques. One Warehouse, deterministic kill receipt and save consistency, same-build. DEV reset old save after breaking gameplay changes per user; **does not waive same-build exactly-once**.

## 2. Proposed per-species material / gear event table — per ACTUAL KILL, NOT per time
**[PROPOSED]** Entry P_material = chance of a stack from PRIMARY material source (conditional quantity indicated). P_gear = chance to enter an **eligible V2 equipment roll** (not a guaranteed high-quality grade; fails closed unless full V2 item template exists). Fragment p uses `3` independently. Loot categories may both succeed on one real kill; no loot is guaranteed just by killing.

| Monster species ID | Element | Registered/candidate primary material ID | Proposed P(material) | Quantity if dropped | Proposed P(gear event) | Eligible V2 slots/roles (must have actual templates) |
|---|---|---|---:|---|---:|---|
| `truc_thu` | Mộc | `linh_moc` [registered] | **38%** | 2 | **0.15%** | weapon/basic gloves/boots if authored |
| `thanh_lang` | Mộc | `tinh_lang_bi` [registered] | **38%** | 1 or 2 equiprobable (mean1.5) | **0.25%** | armor, cloak, boots |
| `hac_lang` | U Minh | `yeu_dan` [registered] | **20%** | 1 | **0.40%** | ring, weapon (Nether authored) |
| `ttl_thuy_vu_linh` [NEW] | Thủy | `ttl_thuy_vu_tinh` [NEW] | **35%** | 1 | **0.25%** | head, pendant |
| `ttl_thuy_tinh_giai` [NEW] | Thủy | `ttl_thuy_tinh_giap` [NEW] | **30%** | 1 | **0.35%** | bracers, armor |
| `ttl_kim_giap_trung` [NEW] | Kim | `ttl_kim_giap_xac` [NEW] | **40%** | 1 | **0.30%** | armor, weapon |
| `ttl_thiet_tiem_thu` [NEW] | Kim | `ttl_thiet_tiem` [NEW] | **35%** | 1 | **0.35%** | gloves, weapon |
| `ttl_hoa_van_lang` [NEW] | Hỏa | `ttl_hoa_lang_nanh` [NEW] | **35%** | 1 | **0.30%** | ring, weapon |
| `ttl_xich_viem_trung` [NEW] | Hỏa | `ttl_xich_viem_xac` [NEW] | **28%** | 1 | **0.40%** | cloak, pendant |
| `ttl_thach_bi_thu` [NEW] | Thổ | `ttl_thach_bi_giap` [NEW] | **36%** | 1 | **0.35%** | belt, boots |
| `nham_giap_thu` [existing Elite] | Thổ | `ttl_nham_giap_hach` [NEW, DEFERRED] | **50% SHADOW TEST ONLY** | 1 if future sink | **4%** | armor/bracers/head/authorized Hộ Sơn set pieces |
| `hac_lang_vuong` [existing Boss] | U Minh | `ttl_hac_lang_vuong_hon_tinh` [NEW, DEFERRED] | **100% SHADOW TEST ONLY** | 1 per actual qualifying Boss | **35%** | legal Boss rare ring/armor/set template; no universal best gear |

**No source assignment to the existing `huyet_lang_dau_dan` in TTL** unless a NEW world event explicitly adds it. Its Fire identity in MonsterCatalogue remains unchanged.
**Optional secondary resources [PROPOSED but OFF in base forecast]:** `thanh_thiet` from `thanh_lang` (4%) or `ttl_kim_giap_trung` (7%), `huyen_thiet` from **R2+** `ttl_thiet_tiem_thu` only at 1%; `yeu_dan` from Hỏa Văn Lang 4%. `linh_tuy` **OFF for ordinary WORLD kills** because current guarantee is after 4 victorious finite fights, not after 4 dead quái. `thanh_linh_thao` from a Trúc Thử kill OFF until owner explicitly chooses hunting drop versus Linh Điền growth; this avoids collapsing professions and field outputs into easy monster farming.
**No made-up auto-Burn/Slow/status:** monster elemental identity ≠ every normal attack has that element; Combat V2 skills must actually carry authored element and effect.

## 3. Proposed fragment/completed-book source table — SIX known technique families, NOT automatic skills
[CODE VERIFIED] Six P2 technique definition IDs exist; V2 `book_v2:<id>` and `piece_v2:<id>` are **proposed versioned content IDs** (NOT ResourceRegistry IDs or current V2 runtime). V2 first complete book archived forever, duplicates used in Nghiên Tu only if authored; 1 book does not magically unlock 1 basic +4 active +6 passives. Do not copy old P2 `p23:fragment:*` count thresholds 8/12/18/30 as if V2 locked.

**[PROPOSED]** each kill performs AT MOST one family-fragment source roll (after eligibility), with family weights summing to its species total:
| Technique ID | Element/path | Primary eligible sources | Per-eligible-monster proposed **family fragment chance** | Draft required fragments for ONE FIRST copy | Complete-book exception |
|---|---|---|---|---:|---|
| `duong_khi_quyet` | Mộc/Pháp | Trúc Thử | Trúc Thử **2.0%** | **12** | Normal complete book 0%; direct book from future quest/mentor separately |
| `huyen_giap_cong` | Thổ/Thể | Thạch Bì Thú; **Nham Giáp Thú Elite** | Thạch Bì **1.2%**; Elite **8%** | **18** | Elite direct book **0.25%** illustrative only |
| `liet_chien_quyet` | Hỏa/Thể | Hỏa Văn Lang | Hỏa Lang **1.8%** | **18** | Normal complete book 0% |
| `thanh_phong_kiem_quyet` | Kim/Kiếm | Kim Giáp Trùng, Thiết Tiêm Thú | each **1.0%** | **28** | Normal complete book 0% |
| `xich_viem_chan_quyet` | Hỏa/Pháp | Hỏa Văn Lang, Xích Viêm Trùng | each **1.5%** | **28** | Normal complete book 0% |
| `han_nguyet_tam_phap` | Thủy/Pháp | Thủy Vụ Linh, Thủy Tinh Giải | Thủy Vụ **0.8%**; Thủy Tinh **1.0%** | **40** | Normal complete book 0%; other higher region/Bí Cảnh possible |

Hỏa Văn Lang has one fragment event roll P=3.3%, then chooses `liet_chien_quyet` weighted18/33 or `xich_viem_chan_quyet` weighted15/33; no two books from same one fragment-event roll. When one kill's material and gear and fragment categories independently succeed, multiple different category drops may coexist legitimately.
[DEFERRED] Boss Hắc Lang Vương is **U Minh**, so it must **NOT** automatically drop a complete Hỏa/Thủy book just because “Boss should drop books.” Future specifically named U Minh Boss transmission needs a new actual technique ID, game effect, manual consumer and owner decision. Current six complete books from Boss **OFF**. Other quest/transmission/sect research sources for each must be designed to avoid depending solely on hundreds of trivial monster kills.
**Time-to-first-copy** is source-directed and stochastic; `12 / expected valid fragments per hour` is a rough EXPECTATION UNDER FIXED TARGETING AND NO COMPLETE BOOK exception, not a guarantee of an individual player timeline. See computed source-mix worksheet companion document.

## 4. Proposed conditional gear-quality TABLE by source tier, independent of item's realm
Grade indexes and statutory maximum lines are exactly in `WEAPON_EQUIPMENT_V2_SPEC` and MUST NOT be touched. **These are proposed probability vectors for Thanh Trúc Lâm only**, conditional on a gear-event success and an eligible V2 template; source-based item realm is independent of monster own level and equipment grade:
| Source | Equipment realm index [PROPOSED] | Eligible V2 grade indices | P(grade | gear event), in ascending grade order | Sum |
|---|---|---|---|---:|
| Normal monster R1 | equipment realm1 | 1,2,3,4 | **70%,22%,7%,1%** |100%|
| Strong normal monster R2+ | equipment realm1–2, governed by actual eligible template | 1,2,3,4,5 | **45%,28%,17%,8%,2%** |100%|
| `nham_giap_thu` Elite R1/R2 | equipment realm1–2 | 2,3,4,5,6,7 | **30%,27%,19%,13%,8%,3%** |100%|
| `hac_lang_vuong` Boss R1/R2 | equipment realm1–2 | 3,4,5,6,7,8 | **18%,23%,22%,17%,12%,8%** |100%|
| Exceptional named world content | explicitly authored `equipment_realm_index` | 9,10,11,12 only as individually authored, source-gated exceptions | **UNDEFINED → NOT ELIGIBLE** until approved | — |

Even when grade=12 is available in some future content, that confers **6 normal+2 rare stat lines maximum and ONE initially EMPTY Chân Văn slot**, not an inscribed mechanic. `EQUIPMENT_SETS_V2_SPEC`: 24 set families, four positional pieces from ONLY `head,armor,cloak,bracers,belt,boots`; sets are stat-based and do not grant free combat skills/Chân Văn. One item instance may have a set lineage only with a registered, eligible positional template and matching Nhân/Tiên/Thần generation.
**No double gear ownership:** equipment from actual monster drop OR actual forge queue belongs to Sect; auto-assignment references same instance id. A cast/death animation itself doesn't create gear or shift item rarity.

## 5. Proposed full TEN-RECIPE V2 forging table, with two scarcity corrections
Earlier owner approval includes TEMPLATE/DIRECTION ONLY, **not** previous draft ingredient amounts. This is a deliberate **two-row numeric tuning proposal**: cloak FT×2→FT×1+Hỏa Lang Nanh×1; bracers rare Water Shell×3→×1+common Water Essence×2. Original and revised are both noncanonical proposals. All ten outputs are unique V2 gear; other eight drafts unchanged in content direction.

| Recipe ID (all NEW) | Slot / output | Recommended prototype recipe inputs | Material cost interpretation | Candidate Forge milestone / time (NOT LOCKED) |
|---|---|---|---|---|
| `forge_v2:ttl_truc_moc_kiem` | `weapon` / Trúc Mộc Kiếm | `linh_moc×3 + thanh_thiet×2` | 100% real registered material IDs | Lv1 base forge, **10 ticks** pilot |
| `forge_v2:ttl_thuy_vu_quan` | `head` / Thủy Vụ Quan | `ttl_thuy_vu_tinh×2 + thanh_linh_thao×1` | [NEW] Water+real herb | Lv30 monster-material forge, **24 ticks** |
| `forge_v2:ttl_kim_giap_y` | `armor` / Kim Giáp Y | `ttl_kim_giap_xac×3 + thanh_thiet×2` | new Metal+real metal | Lv30, **24 ticks** |
| `forge_v2:ttl_xich_viem_phong_y` | `cloak` / Xích Viêm Phi Phong | **`ttl_xich_viem_xac×1 + ttl_hoa_lang_nanh×1 + linh_moc×2`** | **changed** to reduce 7-slot scarce-monster bottleneck; Fire stays real Fire source | Lv30, **24 ticks** |
| `forge_v2:ttl_thuy_tinh_uyen` | `bracers` / Thủy Tinh Uyển | **`ttl_thuy_tinh_giap×1 + ttl_thuy_vu_tinh×2 + tinh_lang_bi×1`** | **changed** to reduce 6-slot Water Shell bottleneck | Lv30, **24 ticks** |
| `forge_v2:ttl_thiet_tiem_thu_sao` | `gloves` / Thiết Tiêm Thủ Sáo | `ttl_thiet_tiem×3 + thanh_thiet×1` | new Metal/real metal | Lv30, **24 ticks** |
| `forge_v2:ttl_thach_bi_dai` | `belt` / Thạch Bì Đái | `ttl_thach_bi_giap×3 + linh_moc×1` | Earth/real wood | Lv30, **24 ticks** |
| `forge_v2:ttl_lang_hanh_ngoa` | `boots` / Lang Hành Ngoa | `tinh_lang_bi×3 + linh_moc×1` | **all IDs exist**, but monster-leather forging is Lv30 milestone candidate | Lv30, **24 ticks** |
| `forge_v2:ttl_ngu_hanh_ngoc` | `pendant` / Ngũ Hành Ngọc | `ttl_thuy_vu_tinh×1 + ttl_hoa_lang_nanh×1 + ttl_kim_giap_xac×1 + ttl_thach_bi_giap×1 + linh_moc×1` | five-element multi-camp sourcing; item cannot automatically grant a skill | Lv30, **36 ticks** for multi-material (time pilot) |
| `forge_v2:ttl_u_minh_gioi` | `ring` / U Minh Giới | `yeu_dan×2 + ttl_hoa_lang_nanh×1` | Nether build using Fire fang as **craft ingredient**, not renaming U Minh into Hỏa | Lv30, **24 ticks** |

**Critical canon gating:** all **TEN SLOTS equip from early game** as per equipment spec, but **not all ten specialized monster-material RECIPES are forgeable at Lv1**; `EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP` says Lv1 basic forging, Lv30 monster-material forging, Lv75 advanced set/special. To meet early equipment availability later, ordinary low-grade **basic drops or simpler base recipes** for all ten slots must exist before Lv30; these ten specialist named recipes cannot be the only source of gear. Do not misstate Lv30 gate as already coded. Lv30, ticks and other recipe details are proposal, not a new locked rule.
**Forge outcome proposal:** choose target recipe/slot upfront; one authorized forge operation consumes ingredients once, after actual time creates at least **one valid base item** if inputs/jobs were accepted. An illustrative Lv1 **grade1/2/3 distribution 80%/18%/2%** and Lv30 specialized **grade1/2/3/4/5 60%/26%/10%/3%/1%** may be balance-tested; **not locked** and do NOT override actual V2 forge procedure, profession, time or affix consumer. No recipe above assumes grade6–12 by virtue of using monster items. Failure/other-grade economics require a full forge-cycle owner approval first. No instant result, hidden auto quality roll or free Chân Văn.
**Identity:** `forge_v2:<template>` / `gear_v2:<template>` are proposed ID namespaces only. Source A art icons and all actual V2 item template stats remain PENDING. Ingredient reserve/lock, times, receipt and unique item ID must use canonical future forging, not legacy `EquipmentSystem.RECIPES`.

### 5.1 Unit-consumption bill of materials, ONE example of all ten outputs
Totals from the **revised** ten prototype recipes:
- `linh_moc×8`, `thanh_thiet×5`, `thanh_linh_thao×1`, `tinh_lang_bi×4`, `yeu_dan×2` (existing IDs, actual per-kill sourcing still unapproved).
- `ttl_thuy_vu_tinh×5`, `ttl_thuy_tinh_giap×1`, `ttl_kim_giap_xac×4`, `ttl_thiet_tiem×3`, `ttl_hoa_lang_nanh×3`, `ttl_xich_viem_xac×1`, `ttl_thach_bi_giap×4` (all new).
- No `ttl_nham_giap_hach` / `ttl_hac_lang_vuong_hon_tinh` in these ten because their consumers are DEFERRED. They are NOT active drops.
For 30 disciples each needing one of each ordinary slot, multiply every component by30, then ADD actual forge time, build gating, profession, shared item eligibility, procurement travel, reserve/lock. This is a lower-bound bill of materials, **not** a prediction of full team gearing time.

### 5.2 Source and item realm prerequisites
[LOCKED] Equipment realm requirement1..30 is distinct from monster realm and gear grade. Ordinary physical gear normally uses Tu Vi OR Luyện Thể eligible tier; spiritual-intent item uses Tu Vi, body-specific one Luyện Thể, as authored. Character root/Dao and elemental affinity affect actual skill/affix usefulness, not full loot eligibility by the killing player's build. The player can order a weak disciple to a strong-monster camp; risk AI may decline suicide, without secretly downscaling monsters.
[PROPOSED TTL LOOT POOL ONLY] R1 normal → item realm1 and grades1–4. Higher own-rank R2+ normal → item realm1–2 grades1–5. Nham Giáp Thú Elite → item realm1–2 grades2–7. Hắc Lang Vương Boss → item realm1–2 grades3–8. Grades9–12 and higher item realms demand **explicit exceptional content** beyond this opening regional profile, not a global ban in other maps.
**Selected map difficulty L1–5 remains per region**, distinct from individual monster strength: HP/ATK/DEF multipliers in `HuntingMapV2.LEVELS` are source pilot **per encounter mode**, possible *once-only* world-mode stat adaptation. Old `yield/rare/boss/elite` chance fields are rolled per completed 3–7-creature finite encounter, **not per monster / respawn / camp**; never multiply them by20 bãi.

## 6. Sources-vs-sinks and what is NOT fully solved by this research
- `linh_moc/thanh_thiet` are also mass-produced by Forest/Mine; ordinary rat/wolf drops should be a supplementary hunting faucet, not eclipse the owner-approved x100 production baseline. Actual latest produced/h per level and work state must be measured at selected main/PR before treating them as per-character source savings. ResourceRegistry `market_value` is metadata, not a live fungible market for high-grade loot.
- Main wolf `tinh_lang_bi` and enemy `yeu_dan` already have actual P2 consumers; new V2 source remains proposed; avoid double-paying both old forge-per-win and new per-kill reward.
- `ttl_thuy_tinh_giap` and `ttl_xich_viem_xac` are scarce because only **6** Thủy Tinh Giải and **7** Xích Viêm Trùng normal spawn slots in the 300-slot example. Source redesign above reduces excessive monopoly from those two slots.
- Two Elite/Boss relic materials have **no complete named benefit**; providing them to the player with “value TBD” risks junk inventory. Need authored unique source/consumer/research target, then re-enable their percentage. Their source chances 50%/100% are **shadow scenario**, not future committed item.
- Fragment→book counts 12/18/28/40 are not the old P2 counts8/12/18/30 and NOT previously locked by V2; owner must approve whether a P2 first book can be mapped 1:1 to future V2 transmission or instead becomes successor/name-content variant.
- **Hồi Xuân Đan CODE CONFLICT:** `AlchemyRecipeRegistry` uses `thanh_linh_thao×3` for Hồi Xuân Đan, but owner later locked `thanh_linh_thao×2+linh_coc×1` /6 ticks, HP+55, satiety10 and shared 1,000,000 daily pill points. Must be resolved in a separate authorized code owner packet, **NOT silently fixed here**. Do not balance hunt-herb outputs against obsolete pill recipe.
- Phù3/Pháp Bảo2 are deferred, and legacy `hoa_van_ngoc` `talisman` is NOT V2 `pendant`; don't make ordinary slot table contain it. Equipment set positions fixed six as above.
- Content decision from Owner DEV reset means old versions' saved disciples can be discarded when a later authorized gameplay build evolves, but per-monster drop RNG and Warehouse save within one version still MUST replay exactly once.
- 30 active hunter slots per single map and 200–400 monsters is a **design target**; no profiler/Godot script/Android benchmark has been run and no Source A rig matches verified to 7 NEW species.

## 7. Strict transactional eligibility contract (later code only with separate authorization)
`KillLifeID=(map_instance,camp_origin,spawn_slot,generation)` + author/versioned `loot_profile_id` + own monster realm/floor, tier, species+affinity, map grade → source validation + deterministic independent material/gear/fragment rolls (frozen results) → valid registry/unique item/first-book archival → exactly one Sect Warehouse/material receipt and authorized individual progress → ACK/retry same outcome → respawn with NEW generation. One Boss HP/one Sect loot pool across parties; DPS/tank/healer/support contribution evidence, no last hit monopoly; user has **NOT locked 60/40 Spirit Stone split**. Do not grant unapproved Tu Vi per-kill or skill EXP on trivial repeated AoE. No art/VFX/minimap death UI owns RNG.
A missing/new unregistered ID **fails closed** with an explicit authoring diagnostic; do not silently swap it into `yeu_dan` or spawn a phantom commodity. Warehouse stacks logically unbounded subject to safe integer/locks/reserve, not artificial “warehouse full”.
No extra "all monsters dead" terminal battle win is required for continuous world farming. Never call this design a working Godot combat/forge implementation.

## 8. Specific owner decisions needed after reviewing this packet
**O1:** Accept relative per-monster PRIMARY material chances from `2` (28–40% ordinary) and direct gear event probabilities (0.15–0.40% normal /4% Elite /35% Boss) as preliminary **simulation inputs only**. Approving ratios does not authorize CODE.
**O2:** Accept **two proposed ingredient substitutions** (cloak and bracers), and source-weighted supply test before final quantities; consider basic-grade gear accessibility prior to Lv30 forge.
**O3:** Accept `3` per-family fragmentation source and required counts12/18/28/40, with all six technique definitions available by research from eligible camps and only Huyền Giáp elite full-book exception candidate; specify independent actual combat-skill manual sources later.
**O4:** Accept `4` equipment conditional quality vectors and item-realm source bands as *Thanh Trúc Lâm only*; maintain all V2 10 slots/12 grades and exceptional higher-grade world sources separately.
**O5:** Decide whether two Elite/Boss relics remain DEFERRED (recommended) until a known named research/forge consumer exists, or request consumer authoring next; no anonymous guaranteed relics.
**O6:** Review real kills/h, event cadence and forge throughput after an authorized benchmark before locking even the proposed percentages. Documentation approval not CODE or PR29 writer permission.

**Companion B:** see `docs/research/TMB_TTL_V3_LOOT_SUPPLY_CRAFTING_FRAGMENT_SENSITIVITY_2026-10-24.md` for computed 20-camp source shares, source bottlenecks, simulation sensitivity/horizons and measurable gates.
