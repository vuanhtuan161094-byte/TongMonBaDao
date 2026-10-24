# TÔNG MÔN BÁ ĐẠO — THANH TRÚC LÂM: DANH MỤC QUÁI / NGŨ HÀNH / 20 BÃI
**Ngày:** 2026-10-24 · **A: DESIGN ONLY** · Không code/packet Codex, PR29/UI/Source A, không merge.
**Owner:** Một map Thanh Trúc Lâm rộng, 20 bãi ×10–20 quái, 30 đệ tử điều bằng chuột tới bãi rồi auto-farm; quái **khác cảnh giới và cấp**, Kim/Mộc/Thủy/Hỏa/Thổ, đồ/vật liệu theo từng loài, không phải mọi quái cùng mạnh bằng nhân vật. Đang làm chung cùng tài liệu **B kinh tế loot** trên nhánh này.
**Các ràng buộc:** Combat V2 authoritative, One Active Job, Injury0/1/120, canonical Warehouse/Save/CARE exactly-once, Source A visual, không ảnh hưởng PR29.
**Nguồn mã đã kiểm:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`, PR29 `9522812e91b7ca5bc0cc108eb92e000e930fe850` OPEN/DRAFT; `godot/src/simulation/combat/{monster_catalogue_v2,hunting_map_v2,monster_encounter_v2,combat_stats_v2,map_battle_v2}.gd`; `docs/{SPIRITUAL_ROOT_V2_SPEC,COMBAT_SKILLS_V2_SPEC,TECHNIQUE_V2_SPEC,CULTIVATION_PATH_V2_SPEC,WEAPON_EQUIPMENT_V2_SPEC,EQUIPMENT_SETS_V2_SPEC}.md`. Kế thừa địa hình/cầu tại docs/ttl-20-camps-map-topology-five-difficulties-design-20261024.
**Nhãn bắt buộc:** [SOURCE] đã thấy trong code; [LOCKED] canonical/owner; [NEW] loài/ID/asset/skill/item chưa có; [EXAMPLE] con số gợi ý cho thiết kế, chưa duyệt; [OPEN] lựa chọn owner.

## 1. Loài có thật và khoảng trống
| Existing species ID | Tên | Tier | Element | Behavior string | loot_ready |
|---|---|---|---|---|---|
| `truc_thu` | Trúc Thử | normal | Mộc (wood) | skittish | true (legacy) |
| `thanh_lang` | Thanh Lang | normal | Mộc (wood) | pack_hunter | true (legacy) |
| `hac_lang` | Hắc Lang | normal | **U Minh (nether)** | aggressive | true (legacy) |
| `nham_giap_thu` | Nham Giáp Thú | elite | Thổ (earth) | armored_brute | false |
| `u_hon` | U Hồn | normal | U Minh (nether) | debuff_caster | false |
| `huyet_lang_dau_dan` | Huyết Lang Đầu Đàn | elite | Hỏa (fire) | pack_leader | false |
| `hac_lang_vuong` | Hắc Lang Vương | boss | **U Minh (nether)** | boss_phase_authoring_pending | false |

[SOURCE] Thanh Trúc Lâm finite encounter currently rolls ordinary species with weights Trúc Thử65%, Thanh Lang30%, Hắc Lang5%, Elite Nham Giáp Thú and Boss Hắc Lang Vương. U Hồn/Huyết Lang Đầu Đàn are NOT presently normal TTL mobs. `loot_ready=true` is not evidence of V2 equipment drop: current old P2 loot is distinct from new per-kill system.
[SOURCE] `MonsterCatalogueV2.create_actor(species_id, realm_index, floor_index, encounter_id)` already supports independent monster realm1..30/floor1..10 and tier/species factors, with pilot growth `1.65^(realm−1)×1.03^(floor−1)`. CURRENT `HuntingMapV2.spawn` passes one same region realm/floor to every mob, so heterogeneous World Combat is NOT currently implemented. Monster element does not make basic attack automatically elemental or cause status.

## 2. Seven NEW ordinary monster families to make the five elements meaningful
| Proposed new stable ID | Tên đề xuất | Hệ | Combat style candidate | Chiến lợi phẩm có chủ đích |
|---|---|---|---|---|
| `ttl_thuy_vu_linh` (W) | Thủy Vụ Linh | Thủy | ranged, authored slow / cast; bounded CC | Linh Dịch Thủy, dược liệu Thủy |
| `ttl_thuy_tinh_giai` (WG) | Thủy Tinh Giải | Thủy | durable patrol, authored shield | thủy giáp, Ngọc/Pháp vật tư |
| `ttl_kim_giap_trung` (K) | Kim Giáp Trùng | Kim | armor & short charge | hợp kim, giáp trùng, vũ khí |
| `ttl_thiet_tiem_thu` (KT) | Thiết Tiêm Thú | Kim | piercing projectile if implemented | mũi nhọn, nguyên liệu xuyên giáp |
| `ttl_hoa_van_lang` (F) | Hỏa Văn Lang | Hỏa | pack flanker, legal burn skill | hỏa tinh, vật liệu pháp khí Hỏa |
| `ttl_xich_viem_trung` (FT) | Xích Viêm Trùng | Hỏa | short authored AoE with hit cap | xác viêm, nguyên liệu chế Phù |
| `ttl_thach_bi_thu` (E) | Thạch Bì Thú | Thổ | slow/guard, high defense | vỏ đá, nguyên liệu giáp Thổ |

**[NEW]** Cả bảy ID, tên, kỹ năng, nguyên liệu, hình ảnh và tỉ lệ ở đây đều CHƯA có trong mã/ResourceRegistry; tuyệt đối không coi là runtime hoặc đã có ảnh Source A. Các tên vật tư mới mới chỉ là tên nội dung cần đăng ký. Quái Thổ thường cũng không đồng nghĩa Tinh Anh Nham Giáp Thú hiện có. Giữ loài Hắc Lang và Boss là U Minh, không đổi qua Hỏa để “đủ ngũ hành”.

## 3. Phân bố đủ 20 bãi, đúng tổng 300 quái thường
**[EXAMPLE]** Số N sau là số spawn slot thường khi đầy; quái thực sống có thể thấp hơn do chờ respawn. Gộp T=Trúc Thử, L=Thanh Lang, H=Hắc Lang [SOURCE]; W/WG/K/KT/F/FT/E = loài [NEW] ở bảng trên. Các số trong thành phần luôn cộng đúng N.

| Camp | N | Tổ hợp loài và số lượng | Cảnh giới riêng của từng quái, ví dụ | Hệ & cách chiến đấu | Lợi ích chọn săn |
|---|---:|---|---|---|---|
| C01 | 10 | T8+L2 | R1F1–R1F3 | Mộc, quái yếu đơn lẻ | Linh Mộc, vật liệu sơ cấp |
| C02 | 11 | T7+L4 | R1F2–R1F4 | Mộc, 1 ít sói | da thú, thảo dược |
| C03 | 12 | T7+W5 | R1F2–R1F5 | Mộc/Thủy | thực vật & Thủy nguyên liệu* |
| C04 | 13 | L8+W5 | R1F3–R1F7 | Mộc/Thủy, bắn xa | da thú & Thủy vật liệu* |
| C05 | 14 | L9+H5 | R1F4–R1F8 | Mộc/U Minh, sói đàn | răng/da/đan |
| C06 | 15 | T9+L6 | R1F1–R1F5 | Mộc, bãi đông dễ | nguồn thông dụng ổn định |
| C07 | 16 | L9+F7 | R1F4–R1F8 | Mộc/Hỏa, bầy sói | Hỏa vật liệu* |
| C08 | 17 | W11+WG6 | R1F5–R1F10 | Thủy, slow/defensive* | Linh Dịch, vảy Thủy* |
| C09 | 18 | K11+KT7 | R1F6–R1F10 | Kim, chống chịu/xuyên* | vật liệu vũ khí Kim* |
| C10 | 19 | H10+F9 | R1F7–R2F1 | U Minh/Hỏa, áp sát | Đan/dấu Hỏa* |
| C11 | 20 | T12+L8 | R1F2–R1F6 | Mộc, đông quái | Linh Mộc/da thú |
| C12 | 19 | L9+E10 | R1F6–R1F10 | Mộc/Thổ, giáp dày* | vật tư phòng thủ* |
| C13 | 18 | W11+T7 | R1F6–R1F10 | Thủy/Mộc, cầu | nguyên liệu Y Đạo* |
| C14 | 17 | K9+H8 | R1F8–R2F2 | Kim/U Minh, khó | hợp kim và Đan* |
| C15 | 16 | H10+L6 | R1F8–R2F2 | U Minh/Mộc | sói cao cấp, tiếp cận Boss |
| C16 | 15 | T10+L5 | R1F2–R1F7 | Mộc, đường rút an toàn | vật tư cơ bản |
| C17 | 14 | W7+FT7 | R1F7–R2F2 | Thủy/Hỏa, hỗn hệ | Thủy/Hỏa tinh* |
| C18 | 13 | K8+KT5 | R1F7–R2F2 | Kim, giáp/xuyên* | thiết khoáng/bản vẽ* |
| C19 | 12 | E7+L5 | R1F7–R2F2 | Thổ/Mộc, phòng thủ | giáp đá, Elite Nham Giáp* |
| C20 | 11 | H6+F5 | R1F8–R2F3 | U Minh/Hỏa, khó nhất thường | nguyên liệu rủi ro cao* |
| **TỔNG** | **300** | **20 bãi, 3 normal hiện có +7 normal đề xuất** | **khác tầng/cảnh giới từng monster** | **Kim/Mộc/Thủy/Hỏa/Thổ + U Minh** | **các nguồn săn khác nhau** |

Dấu * là **nội dung hoặc loot table mới**, chưa phải vật phẩm/monster thật. R1F1...R2F3 là **monster realm/floor ví dụ**, không khóa sức mạnh Thanh Trúc Lâm và không hề scale theo đệ tử. [OPEN] Owner có thể điều chỉnh để đưa cả R2+ vào bãi nguy hiểm hơn; đang dùng dải minh họa. 200 mobs =20 bãi×10; 400 mobs=20 bãi×20; 600 = STRESS ngoài yêu cầu 10–20 mỗi bãi, không phải trần đã khóa. Elite/Boss không bị nhân theo 20 bãi; thay một normal slot hoặc dùng event slot riêng sau khi duyệt cách đếm.

## 4. Hành vi, aggro, địa hình và party
- Patrol trong camp, phát hiện theo radius, pack assist có trần, chase/leash đến giới hạn và quay về; 20 quái/bãi **không tự động 20v1**. Số 2–4 trợ chiến là gợi ý thử nghiệm, không lock.
- Camp thống nhất địa hình đề xuất nhánh cũ: 5 cột ×4 hàng, suối ngăn giữa, 3 cầu ở C03–C04, C13–C14, C18–C19, C08–C09 không qua thẳng suối. Kích thước nav 256×192 cell và tọa độ là ví dụ, không phải map tile đã code.
- Một con quái C08 đuổi người sang C09 vẫn có cùng ID, cảnh giới, HP, U Minh/ngũ hành, loot table và camp gốc. Không tạo bản sao khi đổi spatial chunk hay camera.
- 30 đệ tử có thể chia 10 bãi×2 +10 bãi×1, hoặc điều đội 6 đi săn Elite/Boss và giao lại bãi khi hết event. Mỗi người có đúng một HUNT job, FarmArea là suborder; manual RETREAT/Auto OFF, Injury và nguồn thuốc luôn có quyền cao hơn auto-farm.
- Các `behavior_id` hiện chỉ là metadata, `behavior_ready=false` tại MonsterCatalogueV2; không coi skill AI chưa được viết là đã sẵn sàng. Monster combat skill phải có cast/hit/status riêng; quái Hỏa không auto Burn nếu chưa có skill thật.

## 5. Ngũ hành và khả năng lựa chọn bãi
[LOCKED] Linh Căn V2: Kim→Mộc→Thổ→Thủy→Hỏa→Kim là **vòng tương khắc**. Một kỹ năng có element tag hợp lệ mới hưởng hệ số khắc theo Combat V2/SpiritualRootV2; một đệ tử có linh căn Kim nhưng chém thường **không tự nhận Kim skill damage**. Quái mang hệ nguyên tố không nhất thiết tạo “Linh Căn thuần khiết” như con người; mã `element` hiện chỉ là identity tag. Tương sinh chỉ trên skill/effect đã author. U Minh là nhóm riêng, không ép về 5 cơ bản.
- Kim: giáp cao/xuyên hợp pháp, đồ luyện khí.
- Mộc: số đông/sói/linh mộc, thuốc thảo.
- Thủy: khống chế tầm xa nếu kỹ năng có thật, hỗ trợ Y Đạo.
- Hỏa: burst/Burn thông qua skill thật, nguyên liệu Hỏa.
- Thổ: chịu đòn/chống khống chế khi định nghĩa, giáp.
- U Minh: nguồn riêng không chiếm thuộc tính Fire/Water trong bảng khắc.

## 6. Elite / Boss trong ONE world
- [SOURCE] Nham Giáp Thú = Thổ Elite, Hắc Lang Vương = U Minh Boss; Huyết Lang Đầu Đàn = Hỏa Elite từ vùng khác, chỉ thêm vào TTL khi owner phê duyệt.
- [PROPOSAL] Camp C12/C19 đủ tư cách sinh Nham Giáp Thú ở một event slot có unique life; Boss có 1 bản thể toàn bản đồ gần đường C15, có thể bị 5 đội đánh chung, một HP, một loot pool thuộc tông môn. Rare event phải có giới hạn cùng lúc và lịch tái sinh, **không** dùng % Boss cũ theo từng con hoặc từng camp.
- [SOURCE] `HuntingMapV2.LEVELS` có 5 difficulty grades tính Elite/Boss trên *một trận hữu hạn* 3–7 quái. Level5 đảm bảo một Boss+2 Elites trong trận 7 quái, **không** thể tái sử dụng “mỗi bãi cấp5 có Boss” trong thế giới liên tục.

## 7. Gameplay and authority boundaries
One map-owned `WorldCombatDomain` (PROPOSAL, chưa class) giữ actor registry, vị trí, HP, states/targets, index bucket và due queue. Combat V2 là nguồn tính sát thương duy nhất; không nâng `MapBattleV2.MAX_MONSTERS` 40→400 như lối tắt. Cùng SpawnSlot chỉ có một monster per generation, HP0→one journal→loot per actual creature→warehouse→respawn thế hệ mới sau thời gian hợp lệ. Character and monster may cross camp/chunk, loot origin remains fixed. Renderer culls only visuals; minimap is readonly state and click/selection command interface.
Current `MapBattleV2` limits one arena to 30 disciples/40 monsters, 36×20 coordinates and 90s finite duration. This must not become global map cap or be copied as 20 separate private arenas.

## 8. Owner review / future tests (NOT executed)
- A01: Validate 20 camp IDs, each row count=composition, total=300 and 3 SOURCE+7 NEW clearly distinct; reject unregistered new IDs until real content authoring.
- A02: Two same-species wolves with R1F2 vs R2F1 have different real stats, do not scale to hunter; global difficulty applies once per creature.
- A03: Full five basic elements only once content exists, Hắc Lang/U Minh unchanged, elemental basic attack not automatically tagged.
- A04: 30 disciples 20 camps, two on same Elite, one Boss five groups; valid shared HP/one kill.
- A05: Cross creek/bridge and camera/offscreen deterministic HP/pos/status; no clone or fake loot.
- A06: 200→300→400 live monsters+30 disciples measured on Windows8GB and Android1280×720 before any “PASS/60FPS” claim.
- A07: 5 difficulty levels use current per-region selection; per-camp realm ranges don't alter current finite-mode Elite/Boss rates.
**Follow-on B:** Monster-specific loot category/gear/manual drop economy and numerical *proposal* models in sibling Markdown. No code authority or merge conferred.
