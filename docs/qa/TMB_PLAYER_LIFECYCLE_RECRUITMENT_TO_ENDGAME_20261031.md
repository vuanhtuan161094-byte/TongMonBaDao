# TÔNG MÔN BÁ ĐẠO — Vòng đời người chơi / Disciple Journey (FACTS VS DESIGN)

As of 2026-10-31. Canonical code reference: `integration/one-game-v65-20261030` SHA `199f888c7fd690830728dfbf29b6b79276e3b283`. This is a code-read journey audit, **not** a Godot GUI acceptance. PR #57 and #58 contain candidate medicine and automation but are not yet accepted.

## 0. Legend
- **CODE BASELINE**: exact branch SHA contains data/mechanism; not necessarily accepted via GUI.
- **DRAFT**: candidate code in Draft PR #57/#58, no Godot QA pass.
- **PENDING**: idea or incomplete end-to-end producer→consumer flow.

## 1. Initial player state
`P37Factory.create_state` derives `P212Factory`→`P28Factory`→`P12Factory`→`P0Factory`. `P0Content.DISCIPLES` has **6 named initial disciples**. `P12Factory.INITIAL_CAPACITY=8`; `P28Factory.INITIAL_RECRUITMENT_TOKENS=3` and `RecruitmentSystem.DEFAULT_POOL_SIZE=3`. `P37Factory` supplements 40 Linh Mộc +40 Thanh Thiết (does not necessarily mean final Warehouse only has 40 each). At startup nominal 6/8 recruited slots; player can accept only two further candidates until capacity rises. Starter identities are NOT regenerated to the new V2 profile, so do not conflate them with newly recruited V2 disciples.

## 2. Dẫn Tiên, candidates, costs and choices
Code: `RecruitmentSystem`, `P3.2LandscapeSect`, `DiscipleGeneratorOpenPoints`, `DiscipleBirthRollV2`, `DiscipleBirthCatalogueV2`, `FoundationSystem`.

- **Natural arrivals**: Dẫn Tiên Lv1 base 5 candidates per **1440 canonical simulation ticks/day**, Lv100 base 35; helper elders add `floor(charisma/500)` per assisted actor. Ordinary arrivals have **no per-candidate token fee** inside `_begin_guidance_day`. There may be time/capacity costs (not direct currency debit).
- **Immediate Chiêu Mộ Lệnh**: click `GuidanceRecruitOrder` costs exactly **one** `disciple_recruitment_tokens` and immediately generates one candidate by `guidance_recruit_with_order`. Invalid generation returns token.
- **Accept/Reject**: `accept_candidate` requires valid candidate, V2 birth profile, and capacity. No explicit Ling Stone/token charge **at acceptance**. `reject_candidate` deletes candidate; no extra debit.
- **What can player choose in P3.2 now:** select Main Dẫn Tiên host and assistants; use/not use recruitment order; examine waiting candidates and **Accept / Reject**. P3.2 candidate card shows name, grade and six displayed foundation dimensions.
- **What cannot be manually chosen when rolling:** sex, name, exact grade, Tam Căn/Tứ Tính, Root element(s)/purity, traits, bloodline, physique, fate, starting martial path. They roll deterministically by seed. The separate P2.8 demonstration exposes ordinary/gacha/fate buttons, but P3.2 uses Dẫn Tiên + orders, NOT an unrestricted player-controlled Fate button.
- **Quality odds at base:** 65% common, 25% outstanding, 8% prodigy, 1.8% peerless, 0.2% heaven-defying. At main-guide 2500 Mị Lực while enhanced: 35/25/20/15/5%; daily enhanced heaven count has ceiling `ceil(main_charisma/625)`, after exhaustion revert toward base rules. Rates are CODE BASELINE.
- **Tam Căn (3)**: Tư Chất, Căn Cốt, Tâm Tính. **Tứ Tính (4)**: Tiềm Lực, Thông Tuệ, Cơ Duyên, Mị Lực. D7 born budgets are randomized but follow five quality tiers. Born point effects in `FoundationSystem`: Tu Vi +0.25%/Tư Chất point, Luyện Thể +0.20%/Căn Cốt point, learning +0.15%/Thông Tuệ point, growth +0.05%/Tiềm Lực point; Cơ Duyên influences luck rolls, Mị Lực recruitment/social; Tâm Tính is presently **consumer pending**.
- **Linh Căn**: 1–5 among Kim/Mộc/Thủy/Hỏa/Thổ (root-count probabilities 7/18/30/28/17%); each has independent purity 1–100. Dị Căn mutation event 20/10000=0.2%, five mapped mutations (Lôi/Phong/Băng/Dương/U Minh), potentially latent rather than actively usable.
- **Visible traits:** 1:60%, 2:32%, 3:8%; additional latent trait 8% independent conditional. Catalogue 101 traits, 24 fate identities, 14 physique identities, 5 bloodlines. Birth chance: bloodline 2%, physique 3%, destiny 0.5%; birth layers can be present but **active=false**, no claim of full gameplay effect. Some traits/fates excluded at birth.
- **Start after acceptance (V2 real recruit)**: always Phàm Nhân realm1 floor1 0 XP + Phàm Thân realm1 floor1 0 XP; good birth quality changes future potential/gain, NOT instant tier/realm.
- **Unresolved UX decisions**: choosing profession and combat path at birth versus afterwards, candidate filtering/re-roll fee, guaranteed recruit vs poor streak, visibility/rarity disclosure and whether assistants should be active workers. No new monetary mechanic without owner approval.

## 3. Disciples' professions and development
- **Player-operable after acceptance:** training policy `balanced/cultivation_focus/body_focus/manual`; assignment to the existing workforce and physical work sites (Mỏ, Lâm, Điền, Luyện Đan, etc); choose team for 6-person PvE; equipment/technique controls depend on active V2 consumer.
- **One active job per disciple**, no concurrent valid production/study/body/PvE; interrupt may abandon progress and no phantom resource.
- **Tu Vi and Luyện Thể** are each 30 major realms ×10 small floors. V2 specialized Tu Vi baseline 1000 XP/sim-minute, Chuyên Tu ×2; Body Hall +1500 Body XP per paid sim-minute, **1 sect Stone/minute/actor**. Entry gates and actual material sources are independent.
- **Professions are soft specializations**, not immutable identities or new summoned-class selection. Combat path (Sword/Body/Spell legacy) and newer Cung/Quyền/Độc skill architecture are different workstreams; do not present as already selectable at initial candidate generation.

## 4. Production consumption and cashflow
- **Mỏ** → Thanh Thiết. **Linh Lâm** → Linh Mộc. Economy-A default per worker 2 units each 10 simulation ticks at Lv1 (before speed boosts); canonical Warehouse deposits and optional 2 Stones wage/batch if affordability allows.
- **Linh Điền**: Thanh Linh Thảo 4 Stone seed /12 ticks→3; Linh Cốc 3 Stone /10 ticks→5; Tử Vân Thảo 14 Stone /24 ticks→3, field growing only Lv30, but separately available in `HuntingMapV2` Bạch Thạch Khê reward data (actual settlement not GUI proven).
- **Two legacy alchemy recipes:** 3 Thanh Linh Thảo→1 Hồi Xuân (+55 HP) / 2 Thanh Linh Thảo+1 Linh Cốc→1 Tụ Khí (+10,000 fixed Tu Vi). Each 6 ticks, real timed jobs and Warehouse. B3 daily saturation cap **1,000,000** per 1440 ticks; cost HXD10, TQD25; Injury120 unaffected.
- **PR#58 DRAFT only:** 30 realms×4 provisional grades×2 families =240 unique medicine items; only rank1/2 two-family recipes (4 total), and all quality effects/costs require approval and actual Godot QA. SX-01 auto stock planner still limited to legacy two pills.
- **Market Economy-A:** Sell 4 materials, at most 20 units/day total in default policy; highest unit price Thanh Thiết=8 Stones, hence 160 Stones/day MAX from this channel. This is not total income. Body Hall sustained single actor 1440 Stones/day; upgrade and wages further expenditure. Income loop may fail without appropriate source.

## 5. PvE, injuries, rewards and reset
- **Six disciples per party**, auto-combat continuous; normal→elite→boss progression as owner target.
- Need **legitimate** kill/encounter provenance→rewards→Warehouse and direct EXP→equipment/cultivation and back to production, one settlement per event and exact Save/Offline. HuntingMapV2 F3 has data-backed early material rewards, but open-world LOOT_PENDING and full per-kill game loop not yet released.
- **Injury 120 ticks** auto recovery, independently of HP medicine. No healing pill may erase Injury state.
- **Upgrades**: Lv1–100 means no endgame if mine requires unsourced `tam_mach_ban` at Lv10 and undefined milestone ingredient at Lv20, Forest+Alchemy upgrades disabled on baseline; Field 29 total Hearts through six milestone levels at base 5% fragment roll (rough expected 58k harvests before buffs). Current Mine per-job Lv1→100 x6, full 22 workers vs 2 => nominal x66, not owner x10,000 level-100 target.

## 6. Player Journey release acceptance
New Game→evaluate generated candidate→cost token/natural arrival→Accept→verify D7 birth identity and Phàm Nhân 1/F1 + Phàm Thân 1/F1→choose profession, training and PvE team→paid Field/Mine/Forest→Warehouse→recipe→graded medicine→B3 HP/Tu Vi→XP and gate→PvE source→legit loot→Reinvest→Save, Exit, Reload, Offline and 6/90/200/480 performance. Compare in-game controls, formulas and balances to each requirement. Any broken link is **BLOCKED / design pending**, not completed gameplay.

## 7. Age, life span, ghost state (owner locked design, NOT necessarily implemented)
The code-defined `CandidateState` stores `age`, `base_lifespan`, and `max_lifespan`. The canon `docs/DISCIPLE_LIFESPAN_CANON.md` states that major realm breakthrough can extend lifespan. At the limit, a disciple **becomes Ma/Hồn (ghost)**, is not deleted from roster; a legitimate lifespan-extending Thọ Đan may revive if `lifespan_max > age`. This is **a design lock**, not a claim that the whole aging/ghost/pill-revival pipeline has been coded, tested, and delivered in the P3.2 playable runtime. Injury120 is separate from lifespan and should not erase ghost state.

## 8. Open owner choices requiring explicit decision (do not guess)
- Should Chiêu Mộ Lệnh cost a Stone fee on top of one order? Current code **NO**. Should daily free visitors include non-human races at some tier? Current **HUMAN ONLY**.
- Is there recruit filtering/reroll? None in P3.2, candidates Accept/Reject. Could add targeted scout option but must balance odds and currency.
- Should sex/name be editable **after** recruitment for cosmetic use without rerolling immutable stats? Not implemented.
- How to show seven foundation points (P3.2 current recruitment card shows **six**, omits Tâm Tính) and latent trait information elegantly within 1280x720?
- Should sect capacity start at 8 with six P0 starter actors and three applicants, or adjust free starting slots? Owner review.
- Do not implement new nature/race/gender selection, guarantee, payment or rare odds without owner instruction.

**Sources**: `P37Factory`, `P28Factory`, `P12Factory`, `P0Content`, `RecruitmentSystem`, `DiscipleGeneratorOpenPoints`, `DiscipleBirthRollV2`, `FoundationSystem`, `P3.2LandscapeSect`, `BuildingSystem`, `SpiritCropRegistry`, `AlchemyRecipeRegistry`, `B3PillSatietyV1`, `EconomySystem`. State as-of baseline SHA 199f888; current Codex PRs separate and not merged.
