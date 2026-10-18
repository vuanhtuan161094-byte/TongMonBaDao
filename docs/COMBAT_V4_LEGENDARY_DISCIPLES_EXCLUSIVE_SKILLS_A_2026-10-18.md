# TÔNG MÔN BÁ ĐẠO — COMBAT V4 / ĐỆ TỬ TRUYỀN KỲ & TUYỆT KỸ ĐỘC QUYỀN
**Ngày:** 2026-10-18  
**Trạng thái:** DESIGN SPEC / CHƯA CẤP PHÉP CODE, CHƯA KHÓA BALANCE / NO ASSET IMPORT  
**Quyết định của owner:** **A — tuyệt kỹ cá nhân độc quyền tuyệt đối**. Không truyền thừa, không sao chép, không cho nhân vật khác học/sử dụng tuyệt kỹ thuộc về một đệ tử truyền kỳ. Giai đoạn hiện tại **chỉ hoàn thiện thiết kế**.

## 0. Authority, mối liên hệ và bằng chứng

- Repo https://github.com/vuanhtuan161094-byte/TongMonBaDao ; **main** xác minh khi thiết kế: `461caca1171462e0da092f21108c5c1733157ad9`.
- Đã đối chiếu: `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `docs/DISCIPLE_MASTER_SCHEMA.md` (Master Schema), `docs/DESTINY_V2_SPEC.md`, `docs/TRAITS_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/CULTIVATION_PATH_V2_SPEC.md`, `godot/src/simulation/state/disciple_state.gd`, `godot/src/simulation/combat/combat_skill_system.gd`.
- Thiết kế hệ phái chọn tự do **Model C**: https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/combat-v4-hybrid-school-design-c-20261018/docs/COMBAT_V4_HYBRID_JX1_SCHOOL_DESIGN_C_2026-10-18.md.
- Kiểm toán JavaScript source/VFX: https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/combat-v4-source-vl-research-20261018/docs/COMBAT_V4_SOURCE_VL_RESEARCH_AND_IMPLEMENTATION_PROPOSAL_2026-10-18.md.
- `最强祖师 / Ta Làm Tông Sư`: chỉ tham khảo *trải nghiệm đệ tử đặc biệt có nhận dạng riêng*, không bê luật theo lượt hay sao chép công thức/copyright. Tên/nhân vật trong bảng ở đây **được đề xuất riêng cho Tông Môn Bá Đạo**, chưa phải model/animation nguyên gốc và không phải NPC chính thức của game tham khảo.
- Không thay 30 Tu Vi ×10 tầng, 30 Luyện Thể ×10 tầng, Combat V2 0,25s fixed step, 6 đệ tử/đội, 30/cụm, canonical stats, one active job, warehouse, save/offline, economy, G1/PR20, C4-01. Godot 4.7.2 Windows/Android test PENDING.

## 1. Phân loại và nguyên tắc ownership

**Đệ tử thường:** sinh theo whole-person schema; học kỹ năng thông thường qua Tàng Kinh Các, tự lĩnh ngộ và chiến đấu. Không bị cấm trở thành mạnh hơn đệ tử truyền kỳ. Kỹ năng tự lĩnh ngộ của đệ tử thường có thể có cơ chế riêng trong V2 và không đồng nghĩa tuyệt kỹ định danh của roster truyền kỳ.

**Đệ tử mang Mệnh Cách:** Mệnh Cách V2 là một luật định mệnh hiếm, có thể sinh hoặc nhận hậu thiên; không phải nhãn `legendary` hay bảo đảm có tuyệt kỹ. Mệnh Cách cổ luật: ordinary birth 99,50% không có, 0,45% latent, 0,05% revealed (tổng 0,50%); một ordinary birth tối đa một congenital fate, compatible postbirth fates có thể đồng tồn tại, không Chủ Mệnh slot. **Không đụng phân bố này.** Effect của Fate vẫn chỉ một phần đã có code: lựa chọn/lưu identity sau flag, game-effect/reveal/collection chưa xong.

**Đệ tử truyền kỳ:** một **nhân vật định danh có story/provenance cụ thể**, là một `DiscipleState` đúng schema với tất cả thuộc tính, nghề, công pháp, kỹ năng, quyền lợi/giới hạn bình thường; có **một tuyệt kỹ ký danh được đánh dấu exclusive** và profile VFX riêng cho tuyệt kỹ, **không có class level, hệ gacha riêng hoặc chỉ số cộng tự động vì tên tướng**. Có thể thêm Bẩm Sinh Fate nếu *nội dung riêng* có giải thích và đáp ứng exception trong `DESTINY_V2_SPEC.md`, nhưng tuyệt kỹ và Fate **không được coi là hai nguồn cùng một proc**. Không phải mọi legendary tự động có Mệnh Cách.

### 1.1 Quyết định A — nghĩa chính xác của ĐỘC QUYỀN

**Khóa:** một tuyệt kỹ độc quyền sở hữu bởi **duy nhất một identity người**, không phải cả họ phái, thư viện tông môn, bất kỳ người nào sở hữu cùng bản template, hoặc truyền thừa sau khi chết.

- Không học qua bí kíp, Khắc Lục Kỹ Phổ, Tàng Kinh Các, sư đồ/truyền công, đấu giá, thương nhân, gacha vật phẩm, đột phá, chuyển phái, copy loadout, phẩm chất, luân hồi hoặc loot.
- Không tạo bản sao cùng `exclusive_skill_id` khi nhân vật bị xóa/tuyển lại, clone world, triệu hồi bóng/ảo ảnh, summon, phản chiếu kỹ năng, fake PvP replay hoặc đổi save. Nếu tương lai một chiêu phản chiếu kỹ năng của đối phương, mặc định **cấm** phản chiếu exclusive; ngoại lệ phải được owner duyệt.
- `unique_legendary_identity_id` là khóa **duy nhất trong một world/campaign**, do registry authored/story-source cấp phát khi whole person được sinh hợp lệ; **không** suy ra từ tên hiển thị hay phẩm chất. Một world không có hai người cùng identity huyền thoại. Do not reroll identical person when old save loads.
- `exclusive_skill_id` về thiết kế được đăng ký ở skill catalogue với `owner_legendary_identity_id` và tại thời điểm runtime loadout cần kiểm tra *identity + unique live persistent disciple ID*. Không chỉ tin boolean `learned_combat_skills[skill_id] = true`; tampered legacy data hoặc accidental grants fail closed. Cùng tên không đủ để đủ điều kiện.
- Tướng có thể tạm thời rời đội, chuyển phái hoặc phong ấn kỹ năng: quyền sở hữu và mastery vẫn ghi lịch sử, nhưng **không** tạo transferable Kỹ Phổ. Nếu một người hợp lệ được hồi sinh/quay lại **với cùng world-person identity/id** theo luật đã được phê duyệt, quyền sở hữu vẫn là của đúng người đó; không cho người thay thế tự nhận skill. Hồi sinh vẫn phải tuân theo luật revive trong Combat V2, không tự mở gameplay mới.
- Một tài khoản chơi mới/world mới được phép tái tạo cùng *story template* trong một campaign độc lập; giới hạn một-per-world, không phải global account exclusivity.
- Hiệu ứng thứ cấp như đạn bay/bẫy/DoT của tuyệt kỹ có thể tồn tại sau cast khi mô phỏng cho phép, nhưng attribution luôn giữ owner ID, `skill_id`, `cast_id`; không biến summon/thể hiện bóng thành người sở hữu skill. Mọi thông tin hiệu ứng đều thuộc một canonical skill transaction.
- Không sao chép mechanic/kỹ năng cùng ID thông qua alternate visuals. Kỹ năng phổ thông có thể có hình học cùng loại (ví dụ cùng là kiếm khí, độc AoE), nhưng không phải một biến thể ngầm của tuyệt kỹ truyền kỳ; skill family, trigger và quyền sở hữu khác nhau.

### 1.2 Độc quyền không có nghĩa luôn bật miễn phí

- Khi tuyển tướng: tuyệt kỹ đã **thuộc** người đó; hồ sơ hiển thị tên kỹ năng/đặc điểm và các điều kiện dùng. Chủ sở hữu có thể bắt đầu với dạng **Nhân Giới nhập môn** của riêng mình khi content quy định đủ điều kiện, không tự được phép dùng phiên bản Tiên/Thần từ giây đầu.
- Skill dùng **slot combat hợp lệ**: nếu active sẽ chiếm một trong tối đa 4 slot chủ động đã mở; nếu triggered passive tiêu tốn combat passive slot theo luật V2; nếu self-only static modifier không trigger thì dùng luật passive không cần slot. **Không thêm slot thứ 5 bí mật**, không cast ngoài cooldown, không rải damage miễn phí.
- Nếu quá thấp cảnh giới, chưa mở slot, thiếu vũ khí đúng, đang bị sealed/không tương thích Chủ Đạo/nhánh (nếu skill có yêu cầu), hiển thị `Sở hữu, chưa thể thi triển` cùng lý do. Người chơi vẫn được quyền chọn môn phái khác (Model C); chuyển phái không làm mất quyền sở hữu, nhưng không tự bỏ qua yêu cầu trang bị.
- Người chơi có thể đổi thứ tự slot, nhưng không thể gắn exclusive đó lên bất kỳ đệ tử khác trong UI, AI, save hoặc debug gameplay. Không auto-equip giẫm lên slot đã khóa của người chơi.
- Khi đạt điều kiện: cooldown, cast, interrupt, geometry, target, proc, credit và scaling tuân thủ `COMBAT_SKILLS_V2_SPEC.md`; không có cơ chế gacha quyết định skill có kích hoạt hay không.

## 2. Cấu trúc build Model C cùng tướng truyền kỳ

```text
Whole-person birth identity (Lục Duy / Linh Căn / root snapshots / Huyết Mạch / Thể Chất / Trait / optional Mệnh Cách)
    ├─ birth martial recommendation (derived from known, stable birth data)
    ├─ owner chooses school tradition (JX1-inspired; free-choice Model C)
    ├─ ONE active Chủ Đạo / branch (Kiếm/Thể/Pháp, history retained)
    ├─ learned and equipped normal school skills (shared Sect/manual rules)
    └─ 1 personal EXCLUSIVE signature skill owned only by this persistent person
                ↓
        canonical legal loadout (1 Thường + up to 4 active + 6 combat passives as unlocked)
                ↓
        MapBattleV2 fixed-step AI and real typed events
                ↓
        independent Godot presentation registry (cast/flight/hit/status VFX when legally sourced)
```

**Tuyệt kỹ không mặc định tương đương Mệnh Cách.** Một legendary có cả Mệnh Cách lẫn skill phải có nguồn/hiệu lực khác nhau, không cộng đôi cùng buff/proc. Root-element của **từng skill** theo luật V2; nhãn Kim/Mộc/Thủy/Hỏa/Thổ của JX1 school chỉ là nội dung tham khảo, không tự thêm khắc chế Ngũ Hành lần hai.

**No permanent level cap:** cùng cảnh giới và đầu tư, người thường vẫn có thể thành cường giả bằng mastery, công pháp, equipment, multi-fate hậu thiên và đặc chất. Exclusive tạo **khác biệt cơ chế**, không bảo đảm damage cao hơn đối thủ ở mọi tình huống.

## 3. Roster V1 design examples: 6 người / 6 mechanical identities

**Đây là nội dung PROPOSED, chưa có kỹ năng đầy đủ / skill stats / quyền art / tướng thực trong main.** Không sao chép tên/võ học nguyên bản JX1, dùng hệ phái làm ngôn ngữ chiến đấu. Mỗi kỹ năng là một **single unique skill family**, tương lai có successor Nhân→Tiên→Thần đúng luật V2, chỉ cùng chủ sở hữu nâng cấp.

| Story identity (proposed) | Signature ID (reserved proposal only) | Slot / Role | Luật kỹ năng phân biệt | Giới hạn an toàn và AI |
|---|---|---|---|---|
| **Lăng Vô Trần** · kiếm khách | `sig_lang_vo_tran_van_kiem` | Active, Kiếm Tu/Ngự Kiếm hợp | **Vạn Kiếm Quy Tông**: phóng kiếm khí nhiều nhịp vào các mục tiêu hợp lệ, một dấu ấn hiển thị trong trận có thể được đòn thực sau khai thác | tổng damage budget/target cap, không vượt AoE cap=3 khi áp dụng, mỗi target một trigger/commit, không đè mục tiêu chết |
| **Mộc Thanh La** · độc thuật | `sig_moc_thanh_la_van_doc` | Active, Pháp Tu/Ngũ Hành hợp | **Vạn Độc Phệ Tâm**: đặt độc hợp lệ, tích lũy khi mục tiêu chịu hiệu ứng nguồn này, bùng nổ khi đủ điều kiện | DoT không crit mặc định, stacking/refresh/cast attribution rõ, không nổ chuỗi vô hạn |
| **Bạch Linh Dao** · hỗ trợ | `sig_bach_linh_dao_thanh_lien` | Active, Pháp Tu/Y Đạo hợp | **Thanh Liên Hộ Mệnh**: hồi máu hữu hiệu một đồng đội nguy hiểm và cấp bảo hộ có thời hạn | không tự hồi sinh người đã downed, cấm overheal fake mastery, shield có stacking policy |
| **Hàn Thiết Sơn** · thủ vệ | `sig_han_thiet_son_bat_dong` | Active, Thể Tu/Kim Cương hợp | **Bất Động Sơn Hà**: đứng vững, hút uy hiếp qua hệ Threat thật và giảm sát thương có điều kiện | không bất tử, không dùng thuật `aggro` giả khi threat chưa code, buff duration/cap rõ |
| **Xích Vân Ly** · hỏa công | `sig_xich_van_ly_thien_hoa` | Active, Pháp Tu/Ngũ Hành hợp | **Thiên Hỏa Phần Không**: dự báo vùng hỏa công, phát nổ vào tối đa 3 mục tiêu và đặt Burn hợp lệ | thời gian báo hiệu, cast-interrupt, status cooldown và boss warning không bị che |
| **Tạ Huyền Ảnh** · cơ động | `sig_ta_huyen_anh_vo_anh` | Active, Kiếm Tu/Sát Kiếm hoặc branch tương thích được tác giả mở | **Vô Ảnh Bộ**: lướt đến vị trí có ích, ra đòn sau khi lướt thành công | không teleport xuyên vùng cấm, dash/hit once-only, không auto retarget sau mất target |

**Lưu ý:** các tên này chỉ là GỢI Ý, không phải locked content. `Bạch Linh Dao` chuyển tên kỹ năng thí dụ cũ từ `Thanh Liên Hồi Sinh` sang `Thanh Liên Hộ Mệnh` nhằm không ngầm mở revive bất hợp lệ. Cần thiết kế Threat cho Thể/Kim Cương và status engine cho độc/hỏa trước khi kích hoạt; chưa có hai engine ấy thì hiển thị kỹ năng UNIMPLEMENTED thay vì giả hiệu ứng.

**Fate/trait/quality:** mỗi tướng có hồ sơ hiện tại như người khác; nếu cho một Mệnh Cách định danh, phải author riêng, collision/conflict với Trait/Fate/Physique và exemption khỏi normal birth pool ghi rõ. Tướng đặc biệt **không tự sinh Fate hiếm 100%**.

## 4. Acquisition, roster uniqueness, death and economy

- **Suggested acquisition only:** named quest or sect-linked chain; special high-level encounter / Bí Cảnh / relationship event; optional campaign milestone. NOT forced to paid/gacha-only; do not change existing Dẫn Tiên ordinary gacha distribution, Mệnh Cách birth rates or market economy.
- **One unique story identity per world:** enrollment of story instance is exactly-once, with a campaign-level consumed/ownership record. Duplicate reward receipts/retry/offline recomputation cannot create second character or award the skill twice. Recruited legendary still obeys One Active Job and economic policy; no bonus salary/warehouse payout without separate authorization.
- **No hidden generator substitution:** ordinary random recruits cannot accidentally roll reserved `legendary_identity_id`, including after save migration. Story-character generation follows the full current character schema and preserves distinct birth/history snapshots (explicit story overrides must be authorized where they depart).
- **Loss:** if disciple dies/leaves, signature is unavailable. History/collection index may remember it, but never grants a shareable manual, skill shard or passive effect to the Sect. Returning exactly the same personal identity through an explicit legitimate story rule may reactivate it; creating a second person with same template is forbidden in same campaign. **No new death/revive/dismissal mechanics authorized by this document.**
- **Narrative progression:** Normal → early special introduction → small roster unlocks via real growth; no numeric drop rates or rarity color lock; six-concept roster is not six new gacha tiers.

## 5. Skill mastery / evolution / direct usability

- Exactly one **exclusive family** per legendary disciple in v1. Its authored succession may be **Nhân → Tiên → Thần**, named generations; original slot replaced as appropriate rather than stacking +unbounded extra activations. Same owner restriction extends to all successors.
- Keep canonical mastery five stages **Sơ Học → Nhập Môn → Tiểu Thành → Đại Thành → Viên Mãn** with real participation, valid hit/heal/control etc and existing Tu Vi/Luyện Thể gates. Introductory version might be known from recruitment; tiers and upgrade gates are **content/balance yet to author**, never assert full power automatically.
- Owner may equip other normally learned school skills in remaining unlocked slots, respecting actual path, profession/weapon restrictions and Sect manuals.
- If switched Chủ Đạo/branch incompatibly, exclusive skill stays in history but becomes unavailable as appropriate until legal; UI must state precisely why. The special person's story identity remains. No forced faction class and no erasing knowledge.
- A passive-exclusivity idea must also obey triggered-passive slot law and must not fire free in parallel with every active skill; all six current example signatures are **active** to simplify first pilot.

## 6. Combat rules and anti-exploit boundaries

**Authoritative:** MapBattleV2 chooses actors/targets/positions and applies cooldown, HP/guard/Burn/DoT, threat, interrupts, cast commit, damage and event journal; render never calculates damage. 0.25s fixed tick. **No turn-based combat**, no universal mana bar. One active cast/action per actor. 6/party, 30/cluster, 3 AoE-target baseline. Signature must not create nested unbounded proc storms.

**AI:** as the signature occupies ordinary active slot, existing deterministic priority 1→4 checks actually unlocked equipped slot, target validity, range, cooldown, not casting, skill-specific conditions, and exposure to late encounter/warm-up if necessary. No blanket auto-cast 6 major ultimates at tick 0; no expensive multi-agent general AI. When conditions fail, fall back to ordinary eligible skills/basic; no hit animation for canceled cast.

**Damage/proc identity:** event includes persistent owner-disciple-id, legendary-id, skill-id, cast-id, target-id, hit-index and optional status source. Direct eligible damage may crit, DoT/reflect/control procs follow V2 default no-crit policy. One cast cannot pay multiple mastery/proc rewards by duplicate journal replay; proc limits explicit. If a follower/summon assists, its damage attribution ultimately traces back to true owner, without giving it an equippable signature.

**Effects/buff:** every ongoing buff/shield/DoT declares Strongest-Only/Refresh/Stack-N/Independent/Unique, shared effect collision rules, expiration, visibility; no ad-hoc +infinite. Don't invent unlimited dispel immunity or guaranteed kill on Boss.

**Combat regression:** normal 9 authored skill definitions remain as-is; only two damage learned skills actually dispatched on audited main; seven deferred are not magically implemented by these six concepts. All missing primitives (dash/poison/true learned guard/heal/threat/Burn/shields) are dependencies, not an invitation to patch main in this docs-only scope.

## 7. VFX/actor art plan and user-facing 1280×720 UX

- Every named exclusive family has canonical Godot `skill_id` and optional **presentation-only** `art_profile_id`; VFX pipeline uses real event `precast/cast → projectile/area/move → impact → status/expire`, pooled with screen-space culling, no fake hit/poison/heal. Explicit VFX source rights needed; JX1 raw SPR/PAK and partial converted Drive folder are not a general copyright grant.
- Unique VFX should be identifiable from silhouette/trajectory/color composition, not 6 nearly identical color-swapped circles. Avoid covering HP, actors or Boss red telegraph. Source A character art or original authored/cleared 2D can be used only when separately authorized and hashes/scope verified.
- Actor UI cards: portrait/name, `Đệ Tử Truyền Kỳ` info, **Tuyệt kỹ duy nhất** visible, state `Sẵn sàng / Chưa đủ điều kiện / Đang hồi / Phong ấn`, exact trigger condition, remaining CD, skill element, active school/branch, impact description, optional Mệnh Cách shown SEPARATELY. No duplicate class meters.
- Team editor: unique skill appears in its **one owner's** slot selection; every other disciple's candidate list excludes it. Party preview shows the signature icon for recognizability, not fake use before conditions are met.
- Android: 1280×720 landscape, readable icons/HP/touch, 30 FPS **pilot target only**, visual FPS/VRAM acceptance PENDING and effect-count budget benchmarked on physical device.

## 8. Proposed persistent/content model (FUTURE, not implemented)

**Content definitions (pure authoring):**
- `legendary_character_defs[legendary_id]`: origin/story, spawn contract, display, exclusive family id, legal starting form, starting conditions, allowed canonical path/gear tags as authored, art reference status.
- `exclusive_skill_defs[skill_id]`: owner_legendary_id, activation type, basis Tu Vi/Luyện Thể/Hybrid, stage/grade/evolution, scaling, slot, geometry, targeting, cooldown/cast, cancel/interrupt, AI trigger, status stacking/proc, VFX profile.
- Exactly-one-owner inverse index: every `exclusive_skill_id` maps to only one `legendary_id`; exactly one base personal family per V1 legendary. If content validation finds any duplicates, fail closed with error, not choose one silently.

**Persistence (future migration design, NOT CURRENT FIELDS):**
- `DiscipleState`: store immutable `legendary_identity_id` only when story enrolment is authorized and true; `exclusive_skill_id` should be derived/validated from versioned immutable content registry (or additionally persisted only with explicit consistency checks), not granted from free-text. Its actual learned form/mastery can live in canonical skill storage as long as owner binding cannot be bypassed.
- `Sect/world`: durable unique identity ledger and exactly-once named recruitment receipt to avoid repeated event claims. No duplicate per-character new inventory, battle resource or timer. Avoid proliferating global booleans or reusing resource receipt IDs.
- Legacy save: missing legendary marker means ordinary recruit; **never infer** one by display name. Migration cannot silently reroll seeds, roots, Fate, traits or skill mastery; treat unexpected orphan/owner mismatch as invalid/reported, not convert it into a new free skill.
- **Template vs identity:** same named character content template in a DIFFERENT campaign is fine; copying a live instance in one campaign is not. Reused avatar image or person name does not confer ownership.
- **Future instance events:** active battle position/skill cooldown persist only via current combat/encounter authority. Duplicate collision/timeout receipts cannot duplicate rewards/proc.

## 9. Acceptance checklist for separate scoped CODE packets (ONLY with future owner permission)

- [ ] One special story recruit creates the full standard disciple envelope and exactly one bound exclusive family; a retry, save-load, offline settle, duplicated event receipt and same seed generate no duplicate in same campaign.
- [ ] Ordinary recruit cannot receive same legendary ID or skill even with seeded hidden rolls; all 0.50% regular birth Fate odds remain unchanged.
- [ ] Another disciple cannot study, unlock, equip, proc or UI-select the exclusive via manual, Tàng Kinh Các, same school, copying loadout, self-comprehension, summon, remap or corruption.
- [ ] Only one owner may use skill and it occupies actual available slot; no extra hidden activation, skill not yet legal remains owned but disabled. Legitimate owner switching school keeps ownership/history.
- [ ] Legitimate owner returning is NOT a second person; a second template copy in same campaign remains rejected. No changes to death/injury/revival policy.
- [ ] Skill families respect staged realm/mastery and true AI 1→4; fixed seed battles repeat exactly with identical event journals and outcomes; no altered CombatStats V2 baseline for ordinary disciples.
- [ ] Hit/effect/proc/status source attributes, stacking/expiration, interrupts, AoE cap3, collision once-only, cast cancel, and boss telegraph never create duplicated damage or extra drops.
- [ ] Renderer and VFX are observers only; missing/uncleared asset hides effect or uses visibly neutral fallback without changing damage; Android performance gate awaits actual device evidence.
- [ ] One Active Job, economy, save exactly-once, PR20/G1, canonical Warehouse untouched outside approved future allowlists.
- [ ] Run focused Godot 4.7.2 tests only if runner exists; Windows GUI and Android acceptance **PENDING** until real logs/screenshots. No fake PASS.

## 10. Small future packets; not authorized here

1. **LEG-00 — Definitions/read-only roster validator**: six example identities, skills, UI copy, normalized rights statuses and validation that no repeated ID/duplicate skill owner exists. **No changes to existing DiscipleState, SaveService, CombatStats or battle.**
2. **LEG-01 — Unique story recruitment and owner-bound skill registration**: needs explicit allowlist including canonical recruitment/state/rollback/save, duplicate receipt tests and Mệnh Cách no-reroll. Only after owner authorizes crossing those shared subsystems.
3. **LEG-02 — One signature skill playable inside MapBattleV2 + sprite/VFX pilot**: start **one** representative (recommend Lăng Vô Trần or Mộc Thanh La *after real Burn/poison status authority*), authentic events and exact visual asset rights/hash; focused battle + visual acceptance, then expand six roles. Explicit dependencies: existing C4-01 not on main; deferred seven learned skills.

**No CODE approval** from this document. No changes to canonical master schema until separate design integration permission. No import JX1/VLTK sprites/VFX from Drive without reuse authorization. No CI/FULL/merge or touching PR20, Economy, One Active Job, Injury, Save, Warehouse, Scheduler.
