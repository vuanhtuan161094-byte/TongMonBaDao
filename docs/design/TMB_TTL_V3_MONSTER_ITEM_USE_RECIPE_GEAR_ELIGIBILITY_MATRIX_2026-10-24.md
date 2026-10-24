# TÔNG MÔN BÁ ĐẠO — MA TRẬN LOOT KHẢ THI CHO THANH TRÚC LÂM V3
## Loài quái → item ID xác minh → người dùng → công thức/sink → trang bị 10 ô, 12 phẩm, eligibility cảnh giới
**Ngày:** 2026-10-24. **STATUS: RECOMMENDED CONTENT PROPOSAL / CHỜ OWNER DUYỆT; DOCS ONLY; NO CODE, CODEX PACKET, PR29, UI, SOURCE A, MERGE.**
**Đọc kèm:** `docs/audits/TMB_TTL_V3_VERIFIED_RESOURCE_EQUIPMENT_TECHNIQUE_RECIPE_SOURCE_AUDIT_2026-10-24.md` (kiểm toán 28 ID thật, công thức legacy, hệ V2), hai docs A/B thuộc nhánh `docs/ttl-20-camp-monster-catalog-loot-economy-v3-20261024`, và sơ đồ WorldCombat 20 bãi đã nghiên cứu.
**Authority:** quyết định owner mới nhất: 1 bản đồ Thanh Trúc Lâm, 20 bãi quái, mỗi bãi 10–20 con, 30 đệ tử điều bằng chuột và tự farm; quái khác cảnh giới, 5 hệ Kim/Mộc/Thủy/Hỏa/Thổ (U Minh giữ riêng), vật tư/trang bị/bí tịch theo loài như Võ Lâm. Combat V2, ONE Warehouse, One Active Job, Injury120, exactly-once và Trang Bị/Công Pháp V2 được giữ.
**Baseline:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`, PR29 `9522812e91b7ca5bc0cc108eb92e000e930fe850` OPEN/DRAFT tại kiểm toán. Tất cả tên số mới chỉ đề xuất.
**Legend:** **[S]** resource ID thật có trong `ResourceRegistry.DEFINITIONS`; **[L]** công thức/định nghĩa cũ chạy P2; **[D]** chuẩn thiết kế V2 đã chấp thuận nhưng chưa code; **[N]** ID/item/recipe/species/content mới CHƯA tồn tại; **[U]** cần owner quyết định hoặc chưa có dữ liệu. **[S] vật tư tồn tại KHÔNG có nghĩa quái đã có nguồn rơi V3.**

## 1. Chốt đề xuất 9 ID nguyên liệu mới (chưa phải khóa canonical)
Mỗi ID mới cần `ResourceRegistry` gồm tên/nhóm/realm_rank/tags/stackability/giá và `source_tags` trước khi bất kỳ loot table nào được bật. Tên ID có prefix `ttl_` để tránh va chạm vật liệu chung.

| Proposed item ID [N] | Tên / hành | Nguồn species ID | Nhóm tiêu thụ có đường phát triển |
|---|---|---|---|
| `ttl_thuy_vu_tinh` | Thủy Vụ Tinh / Thủy | `ttl_thuy_vu_linh` [N] | Thủy Vụ Quan, Ngũ Hành Ngọc, Đan/Y Đạo sau này |
| `ttl_thuy_tinh_giap` | Thủy Tinh Giáp / Thủy | `ttl_thuy_tinh_giai` [N] | Thủy Tinh Uyển, giáp chống chịu |
| `ttl_kim_giap_xac` | Kim Giáp Xác / Kim | `ttl_kim_giap_trung` [N] | Kim Giáp Y, Ngũ Hành Ngọc |
| `ttl_thiet_tiem` | Thiết Tiêm / Kim | `ttl_thiet_tiem_thu` [N] | Thiết Tiêm Thủ Sáo, vũ khí xuyên |
| `ttl_hoa_lang_nanh` | Hỏa Lang Nanh / Hỏa | `ttl_hoa_van_lang` [N] | Ngũ Hành Ngọc, U Minh Giới (chỉ vật liệu hỗn hợp) |
| `ttl_xich_viem_xac` | Xích Viêm Xác / Hỏa | `ttl_xich_viem_trung` [N] | Xích Viêm Phi Phong, nguyên liệu Phù sau khi Phù V2 có thật |
| `ttl_thach_bi_giap` | Thạch Bì Giáp / Thổ | `ttl_thach_bi_thu` [N] | Thạch Bì Đái, Ngũ Hành Ngọc |
| `ttl_nham_giap_hach` | Nham Giáp Hạch / Thổ | `nham_giap_thu` [S species Elite] | Elite armor upgrade **chưa có công thức định lượng**, tạm DEFERRED |
| `ttl_hac_lang_vuong_hon_tinh` | Hắc Lang Vương Hồn Tinh / U Minh | `hac_lang_vuong` [S species Boss] | Boss relic/sect research **chưa có công thức định lượng**, tạm DEFERRED |

**Không đưa `ttl_nham_giap_hach` và `ttl_hac_lang_vuong_hon_tinh` vào bảng loot bật thực tế trước khi có template/consumer thật.** Tên [N] không phải item đã được tạo. [S] nguồn tái sử dụng: `linh_moc`, `thanh_thiet`, `huyen_thiet`, `tinh_lang_bi`, `yeu_dan`, `linh_tuy`, `thanh_linh_thao`; ID hợp lệ, nhưng luật rơi theo từng con vẫn chưa có. Dược liệu đột phá Thần/Tiên và Ấn Giới được giữ nguyên nguồn chuyên biệt, không cho Trúc Thử rơi theo suy diễn.

## 2. Ma trận quái → vật phẩm → người dùng / sink
**[NEW] = chưa xuất hiện trong runtime, KHÔNG dùng giả ID như đã có.** 7 loài mới: `ttl_thuy_vu_linh`, `ttl_thuy_tinh_giai`, `ttl_kim_giap_trung`, `ttl_thiet_tiem_thu`, `ttl_hoa_van_lang`, `ttl_xich_viem_trung`, `ttl_thach_bi_thu`. Quái hiện hữu: `truc_thu` Mộc, `thanh_lang` Mộc, `hac_lang` U Minh, `nham_giap_thu` Thổ Elite, `hac_lang_vuong` U Minh Boss. `huyet_lang_dau_dan` Hỏa Elite có thật trong catalogue nhưng KHÔNG thuộc normal pool của Thanh Trúc Lâm hiện tại.

| Quái / hệ | Camp đề xuất | Vật liệu dự kiến, status item | Đệ tử/nhà/công dụng | Công thức hoặc consumer |
|---|---|---|---|---|
| Trúc Thử / Mộc [S species] | C01,C02,C03,C06,C11,C13,C16 | `linh_moc` [S]; `thanh_linh_thao` [S] nếu owner cấp phép | Kiếm/Mộc, xây dựng/Đan | Thanh Thiết Kiếm [L], Linh Mộc Pháp Trượng [L]; Trúc Mộc Kiếm [N] |
| Thanh Lang / Mộc [S species] | C01,C02,C04,C05,C06,C07,C11,C12,C15,C16,C19 | `tinh_lang_bi` [S], `thanh_thiet` [S] nếu author | Thể/Kiếm, da làm Giáp | Tinh Lang Giáp [L], Huyền Thiết Quyền Sáo [L]; Lang Hành Ngoa [N] |
| Hắc Lang / U Minh [S species] | C05,C10,C14,C15,C20 | `tinh_lang_bi` [S], `yeu_dan` [S] nếu author | Công Pháp, Linh Thạch/đan (separate payout) | Linh Mộc Pháp Trượng [L], Liệt Chiến Quyết material [L], U Minh Giới [N] |
| Thủy Vụ Linh / Thủy [NEW] | C03,C04,C08,C13,C17 | `ttl_thuy_vu_tinh` [N] | Pháp Thủy/Y Đạo/Luyện Đan | Thủy Vụ Quan [N], Ngũ Hành Ngọc [N] |
| Thủy Tinh Giải / Thủy [NEW] | C08 | `ttl_thuy_tinh_giap` [N] | Thể/Thủy phòng thủ | Thủy Tinh Uyển [N] |
| Kim Giáp Trùng / Kim [NEW] | C09,C14,C18 | `ttl_kim_giap_xac` [N]; `thanh_thiet` [S] nếu authored | Kiếm/Kim và Luyện Khí | Kim Giáp Y [N]; Ngũ Hành Ngọc [N] |
| Thiết Tiêm Thú / Kim [NEW] | C09,C18 | `ttl_thiet_tiem` [N]; `huyen_thiet` [S] nếu rare allowed | Kiếm/Thể, rèn vũ khí | Thiết Tiêm Thủ Sáo [N] |
| Hỏa Văn Lang / Hỏa [NEW] | C07,C10,C20 | `ttl_hoa_lang_nanh` [N]; `yeu_dan` [S] nếu authored | Pháp Hỏa/tu luyện | Ngũ Hành Ngọc [N], U Minh Giới [N] |
| Xích Viêm Trùng / Hỏa [NEW] | C17 | `ttl_xich_viem_xac` [N] | Pháp/Phù sư | Xích Viêm Phi Phong [N], Phù V2 deferred |
| Thạch Bì Thú / Thổ [NEW] | C12,C19 | `ttl_thach_bi_giap` [N] | Thể Kim Cương/giáp | Thạch Bì Đái [N], Ngũ Hành Ngọc [N] |
| Nham Giáp Thú / Thổ Elite [S species] | C12,C19 event | `ttl_nham_giap_hach` [N DEFERRED] | phòng thủ/đồ bộ Hộ Sơn | chưa có full recipe, FAIL-CLOSED |
| Hắc Lang Vương / U Minh Boss [S species] | một actor world gần C15 | `ttl_hac_lang_vuong_hon_tinh` [N DEFERRED] | nghiên cứu bí tịch, Boss gear | chưa có full recipe, FAIL-CLOSED |
| Huyết Lang Đầu Đàn / Hỏa Elite [S species outside region] | NONE until owner adds | `yeu_dan` [S] conditional / Fire elite material [U] | Pháp Hỏa/forge | chưa có TTL event source approved |

**Hệ ngũ hành KHÔNG tự phát kỹ năng:** tag monster wood/metal/water/fire/earth không có nghĩa basic attack luôn cùng nguyên tố, hoặc đánh vào là Burn/Choáng; kỹ năng quái phải có authored cast/hit/status chính thức. Hắc Lang/Boss là Nether, không thay thành Hỏa. Kim khắc Mộc; Mộc khắc Thổ; Thổ khắc Thủy; Thủy khắc Hỏa; Hỏa khắc Kim; chỉ hoạt động trên **skill-tagged damage tương ứng** theo canonical, không trên thường kỹ vô hệ.

## 3. Công Pháp và mảnh: dùng thật P2 làm referent, V2 item transmission cần author
Six technique definition IDs đã có trong `TechniqueSystem.TECHNIQUES` P2 [L], nhưng **chưa phải item sách V2 trong ResourceRegistry**:
| P2 technique [L] | V2 proposed book ID [N] | Proposed fragment item key [N] | Legal World source candidate [N] |
|---|---|---|---|
| `duong_khi_quyet` | `book_v2:duong_khi_quyet` | `piece_v2:duong_khi_quyet` | Trúc Thử/Thủy Vụ Linh nếu có authored story |
| `huyen_giap_cong` | `book_v2:huyen_giap_cong` | `piece_v2:huyen_giap_cong` | Nham Giáp Thú, Thạch Bì Thú |
| `liet_chien_quyet` | `book_v2:liet_chien_quyet` | `piece_v2:liet_chien_quyet` | Hỏa Văn Lang, Huyết Lang Đầu Đàn nếu event approved |
| `thanh_phong_kiem_quyet` | `book_v2:thanh_phong_kiem_quyet` | `piece_v2:thanh_phong_kiem_quyet` | Kim Giáp Trùng/Thiết Tiêm Thú |
| `xich_viem_chan_quyet` | `book_v2:xich_viem_chan_quyet` | `piece_v2:xich_viem_chan_quyet` | Hỏa Văn Lang; Boss U Minh KHÔNG tự cho Hỏa sách |
| `han_nguyet_tam_phap` | `book_v2:han_nguyet_tam_phap` | `piece_v2:han_nguyet_tam_phap` | Thủy Vụ Linh/Thủy Tinh Giải rare/gated |

[TỐI QUAN TRỌNG] `book_v2:*` và `piece_v2:*` **không có trong `ResourceRegistry`**, cũng chưa có V2 manual unique-item registry. P2 `p23:fragment:<technique_id>` không phải canonical V2 book; P2 thresholds8/12/18/30 không tự động thành công thức V2. First complete book archive → Sect transmission vĩnh viễn, disciple học đúng điều kiện, **không tự nhận một bộ 4 kỹ năng**. Những **combat skill books** là loại riêng, không suy từ ID công pháp. Cần owner duyệt recipe mảnh→quyển và chance per monster theo nguồn thật.

## 4. Five working legacy recipes [L], not new V2
| Recipe ID actually in EquipmentSystem.RECIPES | Inputs actually coded | Existing output slot |
|---|---|---|
| `thanh_thiet_kiem` | `thanh_thiet×3 + linh_moc×1` | weapon |
| `huyen_thiet_quyen_sao` | `thanh_thiet×3 + tinh_lang_bi×1` | weapon; no actual huyen_thiet input |
| `linh_moc_phap_truong` | `linh_moc×3 + yeu_dan×1` | weapon |
| `tinh_lang_giap` | `tinh_lang_bi×3 + thanh_thiet×1` | armor |
| `hoa_van_ngoc` | `yeu_dan×2 + linh_moc×1` | legacy talisman; NOT V2 pendant |

[RECIPE CONFLICT] Current `AlchemyRecipeRegistry.hoi_xuan_dan` reads Thanh Linh Thảo×3→Hồi Xuân Đan×1/6 ticks. Newer owner pill rule reads Thanh Linh Thảo×2 + Linh Cốc×1/6 ticks, HP+55, satiety10. Flag for later separate CODE QA, DO NOT alter runtime now.

## 5. TEN candidate V2 recipes & output templates — ALL [N], one per ordinary slot
**Numbers below are merely DRAFT input quantities, NOT approved balance.** Every recipe must have real materials in validated registry first; output template+stats/forge facility/profession/duration/quality roll still need V2 authoring. Each result is Sect-owned unique item, not a stack. Recipes do not grant skills from materials.

| Recipe ID / output template suffix [N] | Output / required V2 ordinary slot | DRAFT ingredients — S real, N future | Main target |
|---|---|---|---|
| `forge_v2:ttl_truc_moc_kiem` / `gear_v2:ttl_truc_moc_kiem` | Trúc Mộc Kiếm / `weapon` | `linh_moc×3 [S]+thanh_thiet×2 [S]` | Kiếm/Mộc starter |
| `forge_v2:ttl_thuy_vu_quan` / `gear_v2:ttl_thuy_vu_quan` | Thủy Vụ Quan / `head` | `ttl_thuy_vu_tinh×2 [N]+thanh_linh_thao×1 [S]` | Thủy/Pháp |
| `forge_v2:ttl_kim_giap_y` / `gear_v2:ttl_kim_giap_y` | Kim Giáp Y / `armor` | `ttl_kim_giap_xac×3 [N]+thanh_thiet×2 [S]` | Thể/Kim |
| `forge_v2:ttl_xich_viem_phong_y` / `gear_v2:ttl_xich_viem_phong_y` | Xích Viêm Phi Phong / `cloak` | `ttl_xich_viem_xac×2 [N]+linh_moc×2 [S]` | Hỏa/Pháp |
| `forge_v2:ttl_thuy_tinh_uyen` / `gear_v2:ttl_thuy_tinh_uyen` | Thủy Tinh Uyển / `bracers` | `ttl_thuy_tinh_giap×3 [N]+tinh_lang_bi×1 [S]` | Thủy/Thể |
| `forge_v2:ttl_thiet_tiem_thu_sao` / `gear_v2:ttl_thiet_tiem_thu_sao` | Thiết Tiêm Thủ Sáo / `gloves` | `ttl_thiet_tiem×3 [N]+thanh_thiet×1 [S]` | Kiếm/võ |
| `forge_v2:ttl_thach_bi_dai` / `gear_v2:ttl_thach_bi_dai` | Thạch Bì Đái / `belt` | `ttl_thach_bi_giap×3 [N]+linh_moc×1 [S]` | Thể/giáp |
| `forge_v2:ttl_lang_hanh_ngoa` / `gear_v2:ttl_lang_hanh_ngoa` | Lang Hành Ngoa / `boots` | `tinh_lang_bi×3 [S]+linh_moc×1 [S]` | săn quái nhanh |
| `forge_v2:ttl_ngu_hanh_ngoc` / `gear_v2:ttl_ngu_hanh_ngoc` | Ngũ Hành Ngọc / `pendant` | `ttl_thuy_vu_tinh×1 [N]+ttl_hoa_lang_nanh×1 [N]+ttl_kim_giap_xac×1 [N]+ttl_thach_bi_giap×1 [N]+linh_moc×1 [S]` | Pháp ngũ hành |
| `forge_v2:ttl_u_minh_gioi` / `gear_v2:ttl_u_minh_gioi` | U Minh Giới / `ring` | `yeu_dan×2 [S]+ttl_hoa_lang_nanh×1 [N]` | U Minh, hỗn chế tác |

**Interpretation:** U Minh Giới using a Fire-fang ingredient does not make U Minh creature Fire-aligned. Ngũ Hành Ngọc is a long-run material collection sink, not auto Tương Sinh skill without actual consumer. A `Quyền Sáo` is `weapon` slot, not `gloves`. Only six of the ten ordinary slots `head,armor,cloak,bracers,belt,boots` can be one of canonical 24 sets, each four distinct pieces, mốc 2/3/4. Old `hoa_van_ngoc` talisman is NOT V2 ordinary Ngọc Bội.

## 6. Item eligibility by monster realm vs 12 V2 phẩm — PROPOSAL, not global lock
[LOCKED DESIGN] Ten ordinary slots: `weapon,head,armor,cloak,bracers,gloves,belt,boots,pendant,ring`. Extra 3 Phù+2 Pháp Bảo deferred. 12 grade ladder / max lines:
| Grade | Name | normal | rare-special-stat | Chân Văn capacity |
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
|12|Chí Tôn|6|2|1 EMPTY inscribable slot only|

[LOCKED DESIGN] `equipment_realm_index` =1..30 independent from V2 grade1..12, monster cultivation realm/floor and disciple stage. Only applicable item/skill channels can be rolled. A Chí Tôn R1 item is possible in principle, but cannot erase many realms of numerical progression merely by name. 24 sets have source lineage/generation/eligible positions, no auto-skill or free Chân Văn.

**[N] Location-specific source suggestions for first Thanh Trúc Lâm rollout ONLY:**
| Monster source | Item realm candidate | Default eligible grade proposal | Why, not a universal ban |
|---|---|---|---|
| Normal monster R1 any floor | gear realm1 | phẩm1–4 Phàm..Cực | common early drops, limited but meaningful |
| Strong normal R2+ within risky camps | gear realm1–2 if template exists | phẩm1–5 Phàm..Linh | own monster R2 not guaranteed gear2 |
| Nham Giáp Thú Elite R1/R2 | gear realm1–2 | phẩm2–7 Tinh..Địa | defensive specialized eligible templates |
| Hắc Lang Vương Boss R1/R2 | gear realm1–2 | phẩm3–8 Thượng..Thiên | named Boss gear pool, not guaranteed |
| Named exceptional world event/source | authored allowed realm tier | phẩm9–12 only with explicit authorized extraordinary source for THIS map | **Not a global rule banning grade9..12 at low realms** |

These ranges must not silently override high-grade gear possibilities elsewhere; all numeric drop weights are [U] until approved. Entry risk and character equip rules follow real Tu Vi OR Body compatibility for ordinary physical items, Tu Vi for authored spell-force items, Luyện Thể for body-exclusive ones. Monster realm and buyer disciple realm do not dictate an automatic grade formula.

## 7. Deterministic loot transaction, no triple payout or fake warehouse limit
1. One monster truly HP>0→0, unique life key `map_instance:origin_camp:slot:generation`, one ordered kill credit, boss shared HP for all teams.
2. Choose authored species/tier/element/monster realm/map difficulty/loot table version, **no player matching level** and no art/camera input.
3. Deterministically roll actual legal material IDs, gear event, manual/fragment event as separately defined categories; each category may yield ZERO. Conditional selection from eligible templates, realm, grade, lines and source. No blanket random all-item pool.
4. Persist frozen RNG results and unique equipment/manual instance identities before or atomically with warehouse/sect transmission/personal credit. Exactly-one durable receipt; reloading during roll/deposit/ACK uses same outcome; no 30× reward on Boss.
5. ResourceRegistry validates actual item IDs and safe integer; Warehouse is logically unbounded for normal stacks, no arbitrary physical capacity cap. Unique items owned by Sect, equipped actor is assignee only. Tech manual first book archived once to permanent Sect transmission, duplicate can support research; not auto-grant active skill kit.
6. Only after lifecycle/receipt barrier, respawn next monster generation from its origin slot. Old `HuntingMapV2.preview_reward/claim_reward` is **per finite battle victory**, `EquipmentSystem.forge_loot_for_victory` is **legacy P2 per win**, `LINH_TUY_GUARANTEE_WINS=4` counts wins, NEVER four individual monster kills. New World kill route must be exclusive, not additive to them.

## 8. What exactly needs OWNER approval vs what is source locked
**Owner decision gate O1 — species/ecology:** Approve names, IDs and 20-camp distribution of 7 new monsters, creature own realm/floor content bands and 5 elements + U Minh. No Source A sprites verified; content-only.
**O2 — material registry:** Approve seven primary new commodity IDs from `2`; delay/approve two elite-boss IDs only when recipe/result consumption exists; whether normal monsters may drop current herb/ore IDs and on what camp/source.
**O3 — ten V2 recipes/templates:** Approve *direction* and sample ingredient counts or request tuning. Forge V2 profession/building/time/quality rules are not yet locked; approval of sample table is not runtime authorization.
**O4 — books/fragment sources:** Approve six candidate manual source affinities and separate V2 manual registry keys; fragment-to-book numbers, complete book source tier, chance and learning prerequisites still [U].
**O5 — equipment eligibility:** Approve **as map-local test profile** proposed gear realm/grade bands for normal/Elite/Boss; 9–12 exceptional routes remain explicit opt-in; no single universal level equation; exact grade probabilities deferred.
**O6 — numerical loot and pacing:** Need actual kill/h under30 disciples, map live 200/300/400, continuous Boss/Elite cadence and 1/7/30 canonical-day output; previous parent gear event .30%/.04/.35 and fragment .10%/.02/.20 were merely artificial sensitivity inputs, NOT fixed. Old per-win yield/rare must be redesigned per kill, not 300×.
**O7 — ownership and code gating:** Future separately authorized CODE slice only after Codex PR29 S1 QA/one-writer coordination; this docs commit authorizes none.

## 9. Future acceptance tests (not executed)
- Registry audit: all 28 S resource IDs exist, all 9 N absent until actually added; cannot fake items by unregistered names.
- 20 camp source records with monster element, tier, own realm/floor independent of hunter; preserve Nether and no auto elemental basic.
- Ten proposed recipes cover ten distinct V2 ordinary slots; each has legal ingredient ID, positive quantity, profession/facility and real output template when eventually authored.
- Grade1..12 capacity/realm1..30, Chân Văn slot empty at grade12, 24-set four-slot lineage restricted; invalid source/grade/affix fails closed.
- One kill multiple attackers = one receipt; two monster kills in same tick = two; Boss killed by five parties = one pool and correct contribution.
- Same-build save at HP0/pre-roll/post-roll/pre-Warehouse ACK/respawn = deterministic same items; no reroll by camera or closing game.
- Current P2 five recipes and per-win reward unchanged before separate authorization, no double payout by activating new world tables.
- Spawn and loot load 30 hunters/20 bãi/200→300→400 living mobs, physical Windows8GB/Android1280×720 gate evidence PENDING; no performance PASS from docs.
- Economic model 3/10/30 deployed disciples and 1/7/30 sim-days records real kill/hour, quantities/gear/manual completion/forge recipes, capacity not fake warehouse full.

**Conclusion:** This is a concrete *owner-reviewable proposal*: source item IDs and existing consumers are proven; new species, 9 commodities, ten ordinary gear recipes, six V2 book variants and map-local gear eligibility are defined but **not implemented or numerically locked**. No PR/code/UI/merge touched.
