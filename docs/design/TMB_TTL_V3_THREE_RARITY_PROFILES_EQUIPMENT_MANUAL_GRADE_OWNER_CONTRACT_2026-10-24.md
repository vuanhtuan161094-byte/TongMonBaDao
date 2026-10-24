# TÔNG MÔN BÁ ĐẠO — LOOT HIẾM V3: THƯỜNG / HIẾM / RẤT HIẾM
## 7 quái mới, phẩm 1–12, mảnh/first-book và luật đủ trang bị cho 30–3.000 đệ tử

**Ngày:** 2026-10-24. **Trạng thái:** OWNER-REVIEW DESIGN PROPOSAL, ALL RATES UNAPPROVED. KHÔNG code, packet Codex, PR29/UI/Source A, merge, sửa save.
**Owner intent (newest):** Muốn trang bị và bí tịch hiếm hơn nghiên cứu trước; đưa 3 cấu hình Thường/Hiếm/Rất Hiếm, loài/12 phẩm/mảnh/first-book, dự báo trang bị cho 30 và 1.000–3.000 người. GIỮ nguyên công thức/nguồn và canonical. Các profile là 3 phương án NGHIÊN CỨU thay thế nhau; **KHÔNG phải ba mức mới trong 5 mức khó bản đồ**.
**Baseline:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`, PR29 open/draft `9522812e91b7ca5bc0cc108eb92e000e930fe850` at audit. Parent docs on branch `docs/ttl-v3-loot-recipe-eligibility-balance-20261024`: `docs/design/TMB_TTL_V3_MONSTER_LOOT_RECIPE_GRADE_MANUAL_BALANCE_OWNER_REVIEW_2026-10-24.md` and `docs/research/TMB_TTL_V3_LOOT_SUPPLY_CRAFTING_FRAGMENT_SENSITIVITY_2026-10-24.md`. Verified AGENTS, architecture, checkpoint, WEAPON_EQUIPMENT_V2_SPEC, EQUIPMENT_SETS_V2_SPEC, TECHNIQUE_V2_SPEC, COMBAT_SKILLS_V2_SPEC, P3_7 resource/storage, forge roadmap and current HuntingMapV2 on main.
**Classification:** SOURCE/CODE VERIFIED = current runtime/ID; LOCKED DESIGN = approved canonical; PROPOSED = **every new rate/vector**; SYNTHETIC = forecast assumption; DEFERRED = unregistered content. Neither docs nor arithmetic establishes Godot PASS.

## 1. Guardrails before rarity
- One continuous Thanh Trúc Lâm with 20 camps of 10–20 normal slots each (200–400 full population, example 300) and max30 hunting disciples in THIS map; monster own realm/floor, tier and Kim/Mộc/Thủy/Hỏa/Thổ/U Minh affinities vary without scaling to player level. This world simulation and seven new normal species are **NOT code**; their names/IDs were approved in principle only.
- **Preserve 7 candidate new species** `ttl_thuy_vu_linh`, `ttl_thuy_tinh_giai`, `ttl_kim_giap_trung`, `ttl_thiet_tiem_thu`, `ttl_hoa_van_lang`, `ttl_xich_viem_trung`, `ttl_thach_bi_thu` and existing `truc_thu,thanh_lang,hac_lang,nham_giap_thu,hac_lang_vuong`. Hắc Lang/Hắc Lang Vương = U Minh (nether), not Hỏa. Existing Fire Elite `huyet_lang_dau_dan` belongs to another region until explicit content change.
- **Preserve nine materials**, seven ordinary registered-only-in-future and `ttl_nham_giap_hach/ttl_hac_lang_vuong_hon_tinh` still **DEFERRED** until named consumers. Keep **all primary material roll percentages/quantities from previous proposal UNCHANGED**; owner asked **GEAR and MANUAL rarity**, not new material starvation. All seven NEW material IDs are absent from actual ResourceRegistry at audit; current resource registry28 IDs does not imply per-kill drops.
- **Preserve all TEN specialist V2 proposed recipes and all input amounts from most recent draft**, including modified Fire cloak (1 Xích Viêm Xác +1 Hỏa Lang Nanh+2 Linh Mộc) and Water bracers (1 Thủy Tinh Giáp+2 Thủy Vụ Tinh+1 Tinh Lang Bì). Do not write new recipes, delete basic Forge paths, assume Forge Lv30 existed or convert P2 talisman into V2 pendant.
- **Preserve V2 10 ordinary slots, 12 grade classes, equipment realm1..30**, line/Chân Văn caps and **24 sets of exactly four eligible pieces** at position head/armor/cloak/bracers/belt/boots. An individual's complete set is NOT any four arbitrary pieces, and a full 10-slot equipment outfit is NOT the same thing as a 4-piece named set. All physical gear belongs to one Sect Warehouse with individual unique item IDs.
- **Preserve V2 Công Pháp transmission**: first complete manual archived permanently in Tàng Kinh Các, teach many disciples legally without spending subsequent full books. Công Pháp ≠ combat Kỹ Năng; six P2 technique IDs are present but V2 book/fragment item registries NOT. Same-build kill loot exactly once, no direct per-kill Tu Vi or Stone source invented; Injury0/1/120 and One Active Job remain.

## 2. Three economic trial profiles, strictly rarer than previous proposed figures
| Lottery | Previous proposed source (reference, NOT code) | THƯỜNG | HIẾM | RẤT HIẾM |
|---|---:|---:|---:|---:|
| Per-species equipment-event multiplier | ×1 | **×0.50** | **×0.25** | **×0.10** |
| Per-species fragment-event multiplier | ×1 | **×0.50** | **×0.25** | **×0.10** |
| Earth Elite Nham Giáp Thú equipment event |4%|**2%**|**1%**|**0.4%**|
| Nether Boss Hắc Lang Vương equipment event |35%|**17.5%**|**8.75%**|**3.5%**|
| Earth Elite complete `huyen_giap_cong` booklet |0.25%|**0.125%**|**0.0625%**|**0.025%**|
| All ordinary mob full books |0%|0%|0%|0%|
| Six technique books directly from U Minh Boss | NO AUTHORED SOURCE | **OFF** | **OFF** | **OFF** |
**No automatic material/quantity or map difficulty multiplier.** A LootProfile with source probabilities must explicitly declare species, monster realm/floor, tier, element, map, event and valid item template. Previous `HuntingMapV2.LEVELS.yield/rare` are for finite victorious encounter, NOT per death; do not pay old winning rewards or legacy P2 forge loot alongside V3.

### 2.1 Per-species equipment EVENT % per unique life death
| Species ID | Element | Previous | THƯỜNG | HIẾM | RẤT HIẾM |
|---|---|---:|---:|---:|---:|
| `truc_thu` | Mộc |0.15%|**0.075%**|**0.0375%**|**0.015%**|
| `thanh_lang` | Mộc |0.25%|**0.125%**|**0.0625%**|**0.025%**|
| `hac_lang` | U Minh |0.40%|**0.20%**|**0.10%**|**0.04%**|
| `ttl_thuy_vu_linh` [NEW] | Thủy |0.25%|**0.125%**|**0.0625%**|**0.025%**|
| `ttl_thuy_tinh_giai` [NEW] | Thủy |0.35%|**0.175%**|**0.0875%**|**0.035%**|
| `ttl_kim_giap_trung` [NEW] | Kim |0.30%|**0.15%**|**0.075%**|**0.03%**|
| `ttl_thiet_tiem_thu` [NEW] | Kim |0.35%|**0.175%**|**0.0875%**|**0.035%**|
| `ttl_hoa_van_lang` [NEW] | Hỏa |0.30%|**0.15%**|**0.075%**|**0.03%**|
| `ttl_xich_viem_trung` [NEW] | Hỏa |0.40%|**0.20%**|**0.10%**|**0.04%**|
| `ttl_thach_bi_thu` [NEW] | Thổ |0.35%|**0.175%**|**0.0875%**|**0.035%**|
| `nham_giap_thu` Elite | Thổ |4%|**2%**|**1%**|**0.4%**|
| `hac_lang_vuong` Boss | U Minh |35%|**17.5%**|**8.75%**|**3.5%**|

An EVENT permits ONE legal template/grade roll, not one useful item or one named SET. Actual item drop requires exact eligible template and unique Sect Warehouse instance, and one monster death may yield other independent materials/fragment categories (0 or more) under a deterministic frozen decision. No completion-chance reroll on quit/load/camera pan.

## 3. Grade 1–12 conditional vectors: source-band × profile
**CANONICAL GRADE ORDER:** 1 Phàm, 2 Tinh, 3 Thượng, 4 Cực, 5 Linh, 6 Huyền, 7 Địa, 8 Thiên, 9 Vương, 10 Thánh, 11 Đế, 12 Chí Tôn. Table lists chance *given a legitimate successful equipment event*, ordered by stated grade list. Any omitted grade has **ZERO** probability in this specific Thanh Trúc Lâm source, **not** a universal prohibition across other maps.
| Source category | Equipment realm eligibility [PROPOSED] | Grades with positive weight | THƯỜNG % vector | HIẾM % vector | RẤT HIẾM % vector |
|---|---|---|---|---|---|
| R1 normal | item realm1 |1,2,3,4; 5–12=0|**82/15/2.7/.3**|**88/10/1.9/.1**|**93/6/.95/.05**|
| Strong normal R2+ | item realm1–2 if authored |1,2,3,4,5; 6–12=0|**62/24/10/3.5/.5**|**72/20/6.5/1.4/.1**|**82/14/3.5/.45/.05**|
| Nham Giáp Thú Elite | item realm1–2 |2,3,4,5,6,7; 1 & 8–12=0|**44/30/16/7/2.5/.5**|**54/28/13/4/.9/.1**|**65/24/9/1.7/.28/.02**|
| Hắc Lang Vương Boss | item realm1–2 |3,4,5,6,7,8; 1,2 & 9–12=0|**33/28/20/11/6/2**|**43/30/17/7/2.5/.5**|**55/30/11/3/.9/.1**|
| Exception grade9–12 | **source/template/item realm not authored** |9 Vương,10 Thánh,11 Đế,12 Chí Tôn|**UNDEFINED/OFF**|**UNDEFINED/OFF**|**UNDEFINED/OFF**|
All defined vectors SUM100%. Grades9–12 exist in locked V2, but cannot be made available in this early map through imaginary 0.00001% rows without authoring a concrete exceptional source. Absolute example: in profile HIẾM a successful Hắc Lang Vương kill yields a **grade8 gear event chance =8.75%×.5%=0.04375%/Boss kill** before template/slot legality, not 8.75% grade8.
**Two different rarity dimensions:** `P(equipment_event|monster death)` × `P(grade|event,eligible_source)`; after that actual template/slot/set/affix/role compatibility further filter. No extra special lines grant combat skills; grade12 at most6 ordinary stat lines +2 rare stat lines +1 initially-empty Chân Văn capacity. A 4-piece set is only genuine registered one of24 lineages/generation, four exact positional templates, never any weapon/gloves/pendant/ring as set components.

## 4. Fragment and first-book by each of SIX existing P2 technique identities
**[SOURCE]** old technique IDs: `duong_khi_quyet`, `huyen_giap_cong`, `liet_chien_quyet`, `thanh_phong_kiem_quyet`, `xich_viem_chan_quyet`, `han_nguyet_tam_phap`. **[NEW]** proposed `piece_v2:<id>`, `book_v2:<id>` do NOT exist in current ResourceRegistry or live V2 Sect book registry; future manual item system separate. First complete book once archived unlocks permanent Sect transmission for many eligible disciples, who still pay contribution/learning time. Not all six learned by every disciple and not a free four-active-skills kit.
**Fragment requirements unchanged from previous PROPOSED design**: 12 Dưỡng, 18 Huyền Giáp, 18 Liệt Chiến, 28 Thanh Phong, 28 Xích Viêm, 40 Hàn Nguyệt. NOT old P2 counts or implemented synthesis.
| Fragment family | Exact eligible species | Previous P | THƯỜNG | HIẾM | RẤT HIẾM |
|---|---|---:|---:|---:|---:|
| `duong_khi_quyet` | `truc_thu` |2%|**1%**|**0.5%**|**0.2%**|
| `huyen_giap_cong` | `ttl_thach_bi_thu` |1.2%|**0.6%**|**0.3%**|**0.12%**|
| `huyen_giap_cong` | `nham_giap_thu` Elite |8%|**4%**|**2%**|**0.8%**|
| `liet_chien_quyet` | `ttl_hoa_van_lang` |1.8%|**0.9%**|**0.45%**|**0.18%**|
| `thanh_phong_kiem_quyet` | `ttl_kim_giap_trung` and `ttl_thiet_tiem_thu` |1% each|**0.5%**|**0.25%**|**0.1%**|
| `xich_viem_chan_quyet` | `ttl_hoa_van_lang` and `ttl_xich_viem_trung` |1.5% each|**0.75%**|**0.375%**|**0.15%**|
| `han_nguyet_tam_phap` | `ttl_thuy_vu_linh` |0.8%|**0.4%**|**0.2%**|**0.08%**|
| `han_nguyet_tam_phap` | `ttl_thuy_tinh_giai` |1%|**0.5%**|**0.25%**|**0.1%**|

One killed Hỏa Văn Lang runs ONE mutual-exclusive fragment family event total1.65% / .825% / .33%, then selects Liệt Chiến vs Xích Viêm based on their family weights. This prevents two different fragments from one fragment-category event. Materials/gear may still independently drop if legitimate.
**FIRST FULL BOOK directly from a monster:** only `book_v2:huyen_giap_cong` from Nham Giáp Thú Elite, previous .25% → **.125% / .0625% / .025%** by profile. Other five complete books direct from normal =0%; all six direct from Hắc Lang Vương U Minh =**OFF** until real U Minh technique/story/manual source is authored. Otherwise complete books come from fragment assembly or separately authored quest/Transmission/Revelation; source competition, not free full-book loot for every killer.
**Recommended deterministic priority at Elite:** roll full Huyền Giáp booklet first; if that succeeds, omit same-family fragment category on that kill; otherwise roll fragment. The one life remains one frozen reward decision. Subsequent complete books after first archive have only owner-authorized Nghiên Tu/successor research/convert sink; repeated copies must not teach individually more expensively.

## 5. Sources, formulas and deficits kept truthful
- Primary normal materials and ten V2 prototype specialist forge recipes are exactly as in previous balance docs, including 2 scarcity-corrected recipes; this packet does not tune material output, forge time/profession, ingredient counts, item-stat bonuses, real production rate or Save.
- Gameplay path **early legal basic equipment in ten slots** vs **Lv30 specialist monster forge** must exist; otherwise rare loot profile would softlock early gear. No free spawned 10-piece equipment assumed here; design source required separately.
- Enemy realm/floor does NOT copy attacked disciple cultivation. Selected five existing map grades still apply to whole map, not three rarity profiles; Elite/Boss WORLD event frequency needs own denominator, can't convert finite encounter odds per camp/tick/death.
- Realm gate/body gate, item set lineage, Source A sprites, item templates and new resource IDs all require distinct source evidence. Rarity must not grant phantom Chí Tôn or direct Tu Vi per-kill to make rare maps attractive.
- Forge fallback and overall gear demands require source/sink balance to avoid a roster of 1,000–3,000 without basic gear. 3,000 Sect disciples are NOT spawned in ONE 30-disciple map.
- **Current source discrepancy:** owner newer Hồi Xuân Đan uses2 Thanh Linh Thảo +1 Linh Cốc /6 ticks, HP+55, satiety10; current AlchemyRecipeRegistry old3 Thanh Linh Thảo. Flag to future authorized code, not changed here.
- Warehouse stack capacity logically unlimited by canonical storage spec (safe integer, reserve/lock); owner saves fresh DEV versions, while same-build kill/death/loot/ack/respawn exactly once remains necessary.
- **Overall recommendation for owner REVIEW:** test **HIẾM** as midpoint. It is rarer than previous per kill, and RẤT HIẾM may suit high-value extraordinary drops only when basic gear uses lawful forging. Do not declare any selected profile as gameplay LOCKED until real observed per-camp kills/h and equipment/forge sinks are known.

## 6. Owner decisions to request (NOT ALREADY APPROVED)
O1: choose THƯỜNG / HIẾM (recommend) / RẤT HIẾM as numeric **balance test baseline**; not new gameplay difficulty.
O2: approve or adjust 12-grade conditional distributions *for Thanh Trúc Lâm only*, exceptional9–12 remain disabled until named source.
O3: approve fragment multiplicative rarity / first-book Nham Giáp Thú direct chance; five other complete books via fragments/quest sources, not Boss Nether fire/water freebies.
O4: decide how to GUARANTEE basic gear sourcing prior to Lv30 Forge without diluting rare hunting chase; 24-set parts must be appropriately farmable or forgeable from named sources, not random any-of-24 uniform pool.
O5: measure actual 30-hunter kill-rate/respawn, Elite/Boss schedule, inventory role-fit and 1000–3000 Sect demand; no runtime or Codex work authorized.

**Companion forecast:** `docs/research/TMB_TTL_V3_RARITY_30_DAY_30_1000_3000_ROSTER_FORECAST_2026-10-24.md`. Status **DOCUMENTED PROPOSAL**, not PASS/implemented.
