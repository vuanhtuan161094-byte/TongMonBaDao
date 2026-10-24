# TÔNG MÔN BÁ ĐẠO — I1: MỘT ĐỆ TỬ THẬT, LINH CĂN V2 VÀ MIGRATION
## So sánh 最强祖师 / hồ sơ Lâm Thanh / save cũ và hợp đồng chuyển đổi

**Ngày:** 2026-10-24. **DESIGN ONLY**: không sửa code, PR #27/#29, UI hoặc spec V2 đã khóa, không merge.
**Nguồn code:** main 29b5fba448b0178cb520a4ada44b375b4b934e31; PR #27 deeae081bcfbe1413d4cf60a29db7e58150888b5 (D7), PR #29 9522812e91b7ca5bc0cc108eb92e000e930fe850 (S1 QA pending).
**Nguồn chính sách:** docs/SPIRITUAL_ROOT_V2_SPEC.md, docs/COMBAT_SKILLS_V2_SPEC.md, docs/TECHNIQUE_V2_SPEC.md, docs/REALM_LADDER_V2_SPEC.md, docs/COMBAT_STATS_V2_SPEC.md, docs/GAME_SYSTEM_ARCHITECTURE.md, và quyết định D7 của owner.

## A. Game tham khảo: 最强祖师 — những gì thực sự tìm được

Nguồn hướng dẫn người chơi, không phải game client đang chạy:
- TapTap 2024-03-02: https://www.taptap.cn/moment/512977560364123565. Thời điểm đó, cường hóa linh căn có tổng giới hạn180 cấp, thiên linh căn tập trung180 vào một hành, ngũ linh căn chia36 mỗi hành; chi phí tinh thạch/ngọc; Linh Căn Bí Tàng bổ sung HP/ATK/DEF, tương tác công pháp và kháng; điện ngũ hành thử thách với ràng buộc hành.
- TapTap 2024-03-17: https://www.taptap.cn/moment/518641440847299228. Mỗi đệ tử có 1–5 linh căn; càng ít hành, bonus kỹ năng hành tương ứng càng mạnh; nhiều hành đa dụng hơn, căn tính không đổi trong phiên bản được mô tả.
- TapTap guide new-player 2025/26: https://www.taptap.cn/moment/601377068508252716. Đề xuất ngũ linh căn Kiếm/Thiền tham gia thử thách; thiên Hỏa linh căn có build sát thương chuyên hệ cao hơn; lựa chọn nghề/công pháp quan trọng.
- Screenshots: https://and-static.ghzs.com/image/poster/2024/02/26/65dc2b7cf9b490b47f02e542.jpeg và https://syimg.3dmgame.com/uploadimg/xiaz/2026/0420/1776667117197.jpg. Hiển thị tab 灵根 và từng hành/linh căn biến dị với mức cường hóa. Không coi giới hạn180/36 trong guide 2024 là trạng thái phiên bản2026 (ảnh mới cho thấy hệ tiến hóa đã thay đổi).

**Chỉ học:** thông tin 1 hành/đa hành dễ hiểu, rõ công pháp phù hợp, hiện hình từng hành và đầu tư cường hóa, chọn thử thách elemental. **TMB khác đã khóa:** sinh1–5 hành; mỗi hành có purity1..100 riêng; cộng hưởng N hành đúng100; có thể bổ sung hành thiếu; đủ 5x100 cuối game, không có cap tổng180; D7 độc lập với root-count; skill/công pháp có authored conditions, không mặc định tất cả kỹ năng trái hành bị cấm. Không sao chép tiền, bí tàng hay gameplay nguồn tham khảo.

## B. Hồ sơ mẫu cụ thể — Lâm Thanh
**Minh họa hợp lệ, không phải nhân vật RNG do Godot tạo hay bằng chứng runtime.** Chuỗi số được chọn để tính hiệu quả; UI chỉ trình bày, không sở hữu dữ liệu.

### B1. Lúc tuyển
- id: example_lam_thanh_001; tên: Lâm Thanh; tộc human; nguồn minh họa mountain_village.
- Tam Căn: Tư Chất126 + Căn Cốt105 + Tâm Tính96 = **327**.
- Tứ Tính: Tiềm Lực150 + Thông Tuệ120 + Cơ Duyên95 + Mị Lực65 = **430**.
- Chất lượng D7 theo score **(327+430)*6/7 = 648.857...**, thuộc vùng chất lượng Thiên Kiêu/Prodigy của thang đang đọc; **không phải roll ngẫu nhiên được xác nhận**.
- Tư Chất126: +31.5% Tu Vi EXP tự nhiên trong consumer hợp lệ; Căn Cốt105: +21.0% Body EXP tự nhiên; Tiềm Lực150: **+7.5% chỉ RealmCore** HP/ATK/DEF D7; Thông Tuệ120: nguồn thiết kế **+18% mastery XP**, chưa có skill-mastery consumer live; Tâm Tính chưa có combat consumer. Cơ Duyên và Mị Lực không tự cộng damage.
- Tu Vi 1.1; Luyện Thể 1.1; Chưa Định Đạo; công pháp/kỹ năng chưa tự học; không tạo skill chỉ vì có Hỏa.
- Root-model V2 birth: **Hỏa78, Thủy46, Mộc34**, vắng Kim/Thổ. Root count3 (thuộc hàng count3 rate30% trong generator V2 thiết kế), N100=0, R=1.00. Mutation none in this example, not a latent random identity.
- Required persisted root facts: schema_version2; birth_values={fire:78,water:46,wood:34}, current_values same; stable birth RNG namespace/source/index; mutations={} authenticated, no derived R and no inferred bonuses persisted.

### B2. Bonus nguồn linh căn ngay lúc tuyển (R=1)
| Root | Bonus cho kỹ năng đúng hệ | Mastery bonus đúng hệ | Bonus thường trực độc lập |
|---|---:|---:|---|
| Hỏa78 | +23.4% Fire magnitude | +11.7% Fire learning | +7.8% ALL outgoing damage |
| Thủy46 | +13.8% Water magnitude | +6.9% Water learning | +3.68% basic attack speed và +3.68% cast speed |
| Mộc34 | +10.2% Wood magnitude | +5.1% Wood learning | +4.08% MaxHP |
| Kim/Thổ missing | không có matching bonus | không có | không có penetration / DEF từ root |

Root matching elemental resistance source ở purityP là P*0.15%*R, theo kênh kháng và phép kết hợp canonical; không cộng bằng phép cộng thô với tất cả các nguồn kháng khác.

**Current Core V2 pre-×100 (chỉ minh họa):** Realm HP100 ATK20 DEF12, Body HP90 ATK3 DEF7. D7 Tiềm Lực150 = 1.075 trên RealmCore, trước root/equipment:
- HP=100*1.075+90=197.5
- ATK=20*1.075+3=24.5
- DEF=12*1.075+7=19.9
- Mộc34 nguồn +4.08% MaxHP => **205.558** theoretical, before any additional sources.
Do not present 205.558 as actual PR29/SourceA display; Fire all damage channel not yet working in live root V2.

### B3. Đường đời khi học kỹ năng (TARGET, chưa code)
1. Đội săn hạ quái hợp lệ → thật sự nhận bí tịch/mảnh/vật liệu về Warehouse bằng receipt canonical.
2. Đưa truyền thừa kỹ năng Hỏa vào Tàng Kinh Các; không tự tặng Hỏa Cầu chỉ vì có Fire root; cần điều kiện học TuVi/Body V2, công pháp/path nếu authored, chi phí/time.
3. Đệ tử học Hỏa Cầu (mẫu P2 ratio115%, 7.5 tầm, cast0.65s, CD3.8s, status Burn). Hiện PR29 code S1 có tiêu thụ Burn nhưng QA chưa được nghiệm thu; chỉ xem là mẫu contract.
4. Đòn Hỏa trúng quái primary Metal và không có riêng elemental resist: future V2 counter +25%; Fire78 root effect +23.4%, Fire always damage +7.8%. Các kênh độc lập tạo tỷ lệ giả định **1.234*1.078*1.25=1.662815** so với canonical hit không root/counter nhưng cùng ATK/DEF. Đây là toán thiết kế, KHÔNG phải Godot.
5. Luyện kỹ năng với đóng góp thật (damage không trivial, DoT hợp lệ); Thông Tuệ120 +18% và Fire78 matching mastery +11.7% dùng cùng channel additive => hệ số tiến bộ **1.297** ở tương lai. Không có skill XP hợp lệ trong runtime PR29; không giả lập.
6. Khi được phép, tiến 5 bậc Sơ Học/Nhập Môn/Tiểu Thành/Đại Thành/Viên Mãn bằng XP sự kiện thật và authored TuVi/Body gates; không đồng nhất với P2 learned BOOL hoặc kỹ thuật Lv1..5.

### B4. Tinh luyện Hỏa78→100 (đúng giá/tier đã khóa)
| Hành trình | Số bước | Chi phí Linh Tủy mỗi bước | Thành tiền |
|---|---:|---:|---:|
| 78→80 |2|4|8|
| 80→90 |10|8|80|
| 90→95 |5|16|80|
| 95→99 |4|32|128|
| 99→100 |1|64|64|
| **Tổng** |22| | **360 Linh Tủy + 1 Ngũ Hành Bản Nguyên** |

Phải có nguồn loot/recipe thật trước khi nút nâng cấp hoạt động; giao dịch debit-once, no fail, no reroll, no negative stock.
Sau Fire100: N100=1, R=1.10; updated current values {fire:100,water:46,wood:34}, **birth remains 78/46/34**.
- Fire magnitude +33%, Fire mastery +16.5%, Hỏa ALL outgoing damage +11%.
- Water46 basic & cast speed bonus từ3.68% thành **4.048%** (nhờ cộng hưởng).
- Wood34 MaxHP bonus từ4.08% thành **4.488%**; thay Max HP phải giữ current HP ratio, không miễn phí hồi đầy.
- Fire mastery + D7 Comprehension future = **1+0.165+0.18=1.345** lần XP hợp lệ, tăng từ1.297.
- Fire into Metal example = 1.33*1.11*1.25=**1.845375**, so với1.662815 trước nâng (~+10.98% tỷ lệ theo phép minh họa nếu giữ mọi thứ khác bằng nhau).
- Resonance boosts **ALL owned base roots**, không tăng công pháp/thiết bị/RealmCore/mutation theo lần nhân R thứ hai.

### B5. Tạo linh căn thứ tư khi đủ điều kiện
Lâm Thanh hiện có 3 hành, chọn tạo **Kim10** qua chuyển hóa **512 Linh Tủy + 4 Ngũ Hành Bản Nguyên**, thay current root map thành {fire:100,water:46,wood:34,metal:10}; birth vẫn giữ ba hành thật.
- Kim10 matching skill +3.3% nhờ R1.1; Kim permanent penetration +1.1 percentage points.
- Root count4 không làm R nhảy lên1.25 vì mới **1 hành đạt100**. Chỉ N100 quyết định R.
- Mẫu này chưa có Dị Linh Căn tự động, không tự cấp kỹ năng Kim; thiếu Thổ vẫn có thể bổ sung về sau, đạt5x100 thì R2.00.

## C. I1: schema nguồn sự thật

Persist **D7 birth/current**, **root V2 birth/current**, mutation identity/revealed/origin/rank (chỉ khi authentic), TuVi/Body V2, learned tech+skill IDs/mastery+provenance, archive transmission and authorized Warehouse receipt. Do NOT persist derived R, sum quality as mutable truth, post-root ATK or final skill output.

Suggested owner data boundaries (not code field names to mutate automatically):
- RootBirthIdentity: actor_id, root_model_version, root_birth_values, immutable provenance {seed_domain, world_seed, recruitment_source, generation_index}, if native.
- RootCurrent: root_current_values, valid base element IDs, meaningful refinements and formation receipt ids.
- RootMutation: per owning base_element, mutation_id, rank, reveal boolean, origin, version. A hidden mutation ID saved legitimately at birth must NEVER reroll when reveal.
- LegacyRootProfile (read-only): original elements/global_purity/quality + raw source version/hash + migration_decision.
- DerivedRootEffects: compute from current purity/number of100 roots at character change/combat entry, feed canonical CombatStats channels ONCE.
- Sect-owned Warehouse debit and archive transmission separate from person state.
- Combat-local status, cast time, proc/DoT, target generation and cooldown in MapBattle snapshot ONLY; never persist in the permanent spiritual root object.
- UI roots tab reads from auth state; no source UI reimplementation/SourceA rewrite.

## D. Legacy migration: P2 chung một purity → V2 mỗi hành purity riêng

Actual legacy PR27 fields: spiritual_root_elements:Array, spiritual_root_purity:float, spiritual_root_quality:StringName. Old roots generated by spiritual_root_quality and often one global purity. This is **NOT sufficient evidence** of per-element individual birth purity, root perfect count, hidden mutation.
Sample old disciple old_disciple_021: elements Fire/Water/Wood, global_purity=0.72, quality=earth. Facts known: owns three elements and one **shared old-era** potency72%; unknown: separate Fire/Water/Wood birth purity; mutation identity absent unless elsewhere explicitly persisted.

### Option A — SAFE COMPATIBILITY FIRST (proposed, recommended; NOT already locked)
Keep v1 old-root record with raw bytes and provenance intact, legacy visual label e.g. Linh Căn hệ cũ · thuần khiết chung72%; do not present Fire72/Water72/Wood72 as three genuine birth purities. New recruits use real V2 native root generation. No free R. Keep old effective root combat semantics behind version-aware adapter until explicit one-time controlled conversion/ceremony with preview, accepted mapping and paid source. No reroll, no accidental second D7 migration, no lost skill/technique/warehouse/injury.

Pros: maximally truthful legacy identities; protects against accidental all-100 old root resonance. Cons: two readers/models for a transition period, explicit future decision needed.

### Option B — deterministic uniform PROJECTION (proposed, NOT already locked)
Map old global purity0.72 to computed {Fire72, Water72, Wood72}, mark each value *inferred projected_legacy_shared*, NOT authentic birth; keep old raw values and source_hash. If global purity1.0 and three roots, naive conversion creates three root100 and R1.45 plus passives = power spike; must preview power and choose compensation policy without secretly changing already locked resonance rule. Do not generate hidden mutation, unseen roots or unearned mastery. Conversion must be idempotent for same source hash.

Pros: single V2 data model after conversion. Cons: invented per-element values and unintentionally large balance jumps; owner signoff required.

### Option C — manual per-person provenance
Only if actual historic authoritative logs prove independent purities; otherwise manual crafting 1000–3000 identities is neither reliable nor economical. NOT recommended default.

### Critical separate concerns
- A historical D7 PR27 model3 record must never be recomputed or rerolled by root migration.
- P2 combat-skill learned bool and P2 technique level/xp survive unchanged until their OWN V2 migration packet; root migration cannot invent a named skill or mastery.
- Old save without a root field or profile seed must be tagged legacy/incomplete and given documented fallback or error, not rewritten silently.
- Active fight snapshot with pending Burn or cast and reward/injury must replay or version-transition safely; source roots cannot reset timers, duplicate monster loot, reload full HP or fabricate active proc.
- Any convert preview shows original root source, proposed values, stat differences and reverse-safe immutable source record; no unannounced bulk conversion.

## E. I1 packages, dependencies and focused fixtures (future authorization only)

1. I1-00 **Read-only legacy inventory:** enumerate existing save versions and root quality/global purity/element variants; identify which objects have actual birth provenance and mutation records. Lock an evidence manifest with hashes.
2. I1-01 **Strict versioned root reader** and validators: ID/element list, P1..100, distinct roots, mutation base family, immutable birth/current, provenance. No mutable duplicate R.
3. I1-02 **Native Root V2 recruit**: independent seeded birth RNG domain, distribution 1 root7%, 2 root18%, 3 root30%, 4 root28%, 5 root17%, U^E purity individually; D7 generation remains intact. Old residents remain unchanged (option A).
4. I1-03 **Coexistence/controlled migration**: historical root1 untouched or owner-authorized conversion2; no silent hidden mutation; no R from a fake partial record; no UI claims for missing provenance.
5. I1-04 **Actual refinement transaction** only after real Linh Tủy/Ngũ Hành Bản Nguyên faucets via CARE, Warehouse payment and idempotent save; preserves HP ratio, root event/receipt identity. If no supply, feature remains locked (not fake clickable).
6. I1-05 **Later Combat bridge**: canonical root passives, Fire all-damage channel, R, matching-root skill effect, five-element counter source. Requires S1 official QA and a separate authorized Combat writer. Do not merge into an untested PR29.

**Proposed small fixture acceptance:**
- F01: candidate→disciple preserves example native birth Fire78/Water46/Wood34, D7 Tam327+Tu430, repeat save/recruit does not reroll.
- F02: base R0, Fire100 R1.10, two roots100 R1.25, full five100 R2, no compound R.
- F03: exact cost Fire78→100 360 Linh Tủy+1 Ngũ Hành Bản Nguyên, atomic debit once and current HP ratio preserved.
- F04: legacy shared global0.72 NOT magically stored as authentic three independent birth purities under A; old read/power still valid.
- F05: old legacy global1.0 and 3 roots does not generate accidental R1.45 under A; B must show preview, not implicit.
- F06: no root data + old/unprofiled D7 source handled deterministically without fabricated history.
- F07: existing learned skills/techniques + Injury120 + CARE loot source remain byte-integrity-sound; no new loot on reread.
- F08: repeat migration/load is idempotent; corrupt half-V2 payload fails safely before any Warehouse debit.
- F09: even at roster3000, only active combats process mutation/skill statuses, not idle per-frame ticks.

**NO CODE AUTHORIZATION.** Future code writer requires owner approval, exact new branch SHA, path allowlist, official Godot focused QA. UI chat owns only look; PR29 QA Codex owns its current combat files. This casebook changes NO canonical RootV2 design constants.
