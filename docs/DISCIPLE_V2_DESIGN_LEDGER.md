# DISCIPLE V2 DESIGN LEDGER — LOCKED DECISIONS + REFERENCE LESSONS

Status: CANONICAL DESIGN LEDGER  
Updated: 2026-10-07

Purpose:
- preserve user-approved disciple decisions across chats;
- separate **LOCKED**, **PROVISIONAL BALANCE**, and **NOT IMPLEMENTED**;
- record useful lessons taken from reference games, especially 《最强祖师》, without turning the project into a copy.

Implementation truth still belongs to `CURRENT_CHECKPOINT.md`.

---

# 1. Core development philosophy — LOCKED

## 1.1 One disciple can be nurtured forever

A disciple may eventually become “full everything” if the player invests enough.

Therefore:
- birth is a starting advantage, not a permanent final ceiling;
- every major power/growth attribute should have some explicit permanent-improvement path;
- weak birth means more cost/time, not permanent invalidity;
- rare birth remains valuable because it saves enormous time/resources.

Keep both:
- **birth/innate value** for history;
- **current permanent value** for gameplay.

## 1.2 Toolman strategies are allowed

The project does not need to prevent efficient specialist/toolman play merely because it is optimal.

Examples:
- high Tư Chất disciple used to cultivate quickly;
- high Thông Tuệ disciple used for professions/mastery;
- high Mị Lực disciple used at Dẫn Tiên;
- high Cơ Duyên disciple used for meaningful lucky content.

Balance through acquisition cost, rarity, content difficulty, time, daily limits, satiety and infrastructure — not by making high stats secretly stop mattering.

## 1.3 Large numbers are allowed to feel large

No generic diminishing-return curve exists only to suppress the user's investment.

Old/easy content may become trivial to an absurdly developed disciple.

Content-specific resistance/difficulty/caps are allowed where the content itself has a clear rule, but they must not silently become global stat caps.

---

# 2. Six foundations — LOCKED ARCHITECTURE

Canonical:
1. Tư Chất;
2. Căn Cốt;
3. Cơ Duyên;
4. Thông Tuệ;
5. Mị Lực;
6. Tiềm Lực.

Common rules:
- no permanent hard cap;
- generation rolls Total Birth Lục Duy first;
- ordinary birth stat range ≈ 0.5x–3x six-stat average;
- rare Mệnh Cách/content may break the birth envelope;
- after birth each stat grows independently;
- current quality derives from current permanent total;
- birth snapshot is immutable.

Quality working thresholds:
- <360 Phàm Thường;
- 360–599 Xuất Chúng;
- 600–999 Thiên Kiêu;
- 1000–1799 Tuyệt Luân;
- >=1800 Nghịch Thiên;
- Nghịch Thiên has a long tail and no upper total cap.

## 2.1 Starting balance constants — PROVISIONAL BALANCE

Use the exact backend constants for now:

| Foundation | Starting effect |
|---|---|
| Tư Chất | +0.25% natural/base Tu Vi gain per point |
| Căn Cốt | +0.20% Luyện Thể XP per point |
| Thông Tuệ | +0.15% learning/mastery XP per point |
| Tiềm Lực | +0.05% future Realm+Luyện Thể ATK/DEF/HP growth per point |

For UI readability, prefer explaining them per 100 points:
- 100 Tư Chất = +25%;
- 100 Căn Cốt = +20%;
- 100 Thông Tuệ = +15%;
- 100 Tiềm Lực = +5%.

Do **not** round the backend constants merely for cosmetic neatness. If later benchmark changes a value, change it deliberately as balance.

## 2.2 Same-channel composition — LOCKED

Percentage bonuses that act on the same base progression channel add together before application:

`final = base × (1 + bonus_A + bonus_B + ...)`

Do not chain them as independent multipliers by default.

Fixed-value rewards stay fixed:
- pill +10,000 Tu Vi = exactly +10,000;
- book +5,000 mastery = exactly +5,000;
- body item +X fixed XP = exactly X.

---

# 3. Individual foundation meanings — LOCKED DIRECTION

## Tư Chất

Meaning: efficiency of natural/base cultivation.

Does:
- increase natural/base Tu Vi gain.

Does not inherently:
- multiply fixed-value pills;
- increase profession XP;
- increase luck;
- increase social power;
- directly increase breakthrough chance.

## Căn Cốt

Meaning: efficiency of Luyện Thể progression.

Does:
- increase body-training XP.

Does not inherently:
- directly add HP/Defense/Attack;
- multiply fixed-value body XP items;
- increase breakthrough chance.

Actual physical stats come from Luyện Thể progression itself.

## Cơ Duyên

Meaning: strength of fortunate outcomes when a meaningful random event is resolved.

Canonical check:

`Luck Score = RNG(0..9999) + Cơ Duyên - Difficulty`

Working tiers:
- <6000 normal;
- 6000–8499 good;
- 8500–9499 rare;
- 9500–9899 very rare;
- >=9900 great fortune.

Only meaningful outcomes should call it, not every hit/tick.

Subsystems own their reward tables; Cơ Duyên owns the generic luck check.

## Thông Tuệ

Meaning: ability to learn and master.

Does:
- profession XP;
- future technique mastery;
- future skill mastery;
- future study/research content that is genuinely learning.

Does not directly:
- increase product yield/quality;
- add combat damage;
- add Tu Vi;
- add luck.

The chain should be:
`Thông Tuệ -> learns faster -> higher mastery/profession -> downstream benefit`.

## Mị Lực

Meaning: social power — attraction, goodwill and persuasion.

General check:
`Social Score = RNG(0..9999) + Mị Lực - Social Resistance`

Does not passively make everyone loyal or in love.
A social action/context must exist.

Special Dẫn Tiên rules are separate and already implemented.

## Tiềm Lực

Meaning: quality of long-term growth, not growth speed.

Target future rule:
- amplifies the canonical Realm + Luyện Thể ATK/DEF/HP growth component;
- retroactive when Tiềm Lực increases;
- does not multiply equipment/fixed consumable stats/every unrelated modifier.

This future final stat integration is **NOT IMPLEMENTED YET**.

---

# 4. Pill / consumable satiety — DESIGN LOCKED, NOT IMPLEMENTED

Use one pill satiety system unless later content proves another is needed.

Rules:
- character has a base satiety capacity;
- satiety resets daily;
- every pill has its own explicit satiety cost;
- do not infer satiety from vague categories such as normal/rare pill;
- fixed-value effect remains exactly the stated value;
- traits/physiques/content may later modify capacity or cost explicitly.

This system is intended to limit how much permanent/pill progression is consumed per day without placing permanent caps on disciple growth.

---

# 5. Breakthrough V2 — DESIGN LOCKED, NOT IMPLEMENTED

Future simplified rule:
- failed breakthrough loses **10% of the Tu Vi/EXP requirement**;
- each failure adds **+5 percentage points** to the next attempt's success chance;
- breakthrough-boosting pills/items may be used;
- maximum **3 breakthrough-boosting pills per attempt**.

Exact pill catalogue and final realm-specific base chances remain future balance work.

Do not add unnecessary stability/mental-state/preparation subsystems unless explicitly requested later.

---

# 6. Dẫn Tiên recruitment — BACKEND LOCKED

Normal quality rates:
- Phàm 65%;
- Xuất Chúng 25%;
- Thiên Kiêu 8%;
- Tuyệt Luân 1.8%;
- Nghịch Thiên 0.2%.

At/above the quality-curve saturation point:
- Phàm 35%;
- Xuất Chúng 25%;
- Thiên Kiêu 20%;
- Tuyệt Luân 15%;
- Nghịch Thiên 5%.

Important:
- **Mị Lực itself is not hard-capped**;
- recruitment quality percentages simply stop rising beyond the 5%/15% ceiling;
- extra Main-guide Mị Lực continues to raise the daily enhanced-Nghịch-Thiên allowance;
- current allowance = `ceil(Mị Lực / 625)`;
- after allowance is consumed, the whole table returns to normal for that day;
- normal-rate Nghịch Thiên may still occur;
- counter advances on appearance, not acceptance;
- daily snapshot blocks guide-swap reset exploits.

Dẫn Tiên building:
- Lv1–100;
- one Main Guide controls quality;
- assistants control quantity;
- assistant Mị Lực has no raw hard cap;
- every 500 assistant Mị Lực = +1 arrival/day;
- base arrivals = `5 + 3 × floor(level/10)`;
- Lv1 = 5/day;
- Lv100 = 35/day;
- guide slots: 1 at Lv1, then +1 at Lv20/40/60/80/100, max 6.

Chiêu Mộ Lệnh uses the same Dẫn Tiên quality/daily-limit authority.

Premium currency:
- no canonical Tiên Ngọc/Tiên Ngọc Khóa wallet yet;
- when added, ordinary premium recruitment should buy limited Chiêu Mộ Lệnh through an explicit shop/rule;
- premium spending must not directly bypass Dẫn Tiên quality/daily limits;
- future limited/named banners may use a separate explicit currency/pool.

---

# 7. Reference lessons from 《最强祖师》 to preserve

These are **design lessons/inspiration**, not instructions to copy exact balance, text, art, map or content.

## 7.1 Six-stat value should be multi-dimensional

Useful reference observations:
- Tư Chất mainly represents cultivation efficiency;
- Căn Cốt is associated with body-training development;
- Thông Tuệ is very valuable for profession learning;
- Cơ Duyên matters in rare/lucky content;
- Mị Lực matters for recruitment/social content;
- Tiềm Lực affects long-term stat growth.

Project adaptation:
- preserve distinct domains;
- do not force six identical formulas;
- make a huge value in every foundation desirable for some real reason.

## 7.2 Quality should summarize, not define the whole person

Reference characters can be worth keeping despite lower headline rarity because of:
- traits;
- profession value;
- root;
- physique/bloodline-like special properties;
- unusual combinations.

Project rule:
- Disciple Quality derives from lục duy total;
- it must never replace Root/Bloodline/Physique/Trait/Mệnh Cách evaluation.

## 7.3 High-stat specialists / “toolmen” can be good game design

A very high Wisdom/Charm/Fortune specialist may be strategically valuable without being the best frontline fighter.

Do not artificially homogenize all six foundations into combat DPS.

## 7.4 Character growth should not stop at recruitment

Reference consumables/systems can improve foundations or special character properties after recruitment.

Project pushes this further:
- no permanent lục-duy hard cap;
- long-term nurture is a primary fantasy;
- improvement method limits are allowed, global final caps are not.

## 7.5 Content-specific thresholds are better than global caps

Reference pills/content sometimes have their own usage thresholds.

Project lesson:
- a pill may say “only usable below X”;
- a mortal recruitment building may have a probability ceiling;
- this does **not** mean the underlying stat has a universal hard cap.

## 7.6 Physiques / traits should create identity

Prefer:
- rule changes;
- tradeoffs;
- path specialization;
- unique interactions;
- growth mechanics;

over making every rare physique/trait merely “+Attack”.

## 7.7 Whole-person generation is more interesting than one rarity roll

Recruitment should create one deterministic person with:
- lục duy;
- root;
- traits;
- bloodline;
- physique;
- personality;
- age/progression;
- hidden identity.

Do not roll a rarity first and then treat every other layer as decoration.

---

# 9. Other future character lessons already identified

## Combat

A richer realtime combat model may eventually need:
- ATK / DEF / HP;
- speed separated into movement/attack/cast/cooldown;
- crit / crit damage;
- anti-crit / crit reduction;
- hit/resistance;
- damage reduction;
- healing/shield/dodge/penetration as justified by actual skills.

Do not copy turn-based Speed semantics directly.

## Traits

Production traits should be allowed to have:
- strengths;
- weaknesses;
- tradeoffs;
- event-driven acquisition/removal.

## Class identity

No fixed class.
A disciple becomes a sword/body/magic/etc specialist through:
- learned techniques;
- equipment;
- progression history;
- path XP;
- player/AI behavior.

---

# 8. Spiritual Root V2 — FULL DESIGN LOCKED, NOT IMPLEMENTED

Canonical detailed authority:
`docs/SPIRITUAL_ROOT_V2_SPEC.md`

Locked base-root core:
- Kim/Mộc/Thủy/Hỏa/Thổ;
- ordinary root-count rates 7% / 18% / 30% / 28% / 17%;
- each root has independent purity 1–100 and immutable birth snapshot;
- base-root buffs affect matching cultivation/mastery/skill effect/resistance;
- Kim penetration, Mộc Max HP, Thủy attack+cast speed, Hỏa all damage, Thổ Defense;
- perfected-root Resonance R=1.10/1.25/1.45/1.70/2.00 at 1/2/3/4/5 roots at 100;
- deterministic Linh-Tủy refinement;
- expensive deterministic missing-root creation;
- full five 100 is intentionally extremely strong.

Locked Dị-Linh-Căn core:
- V1 branches: Kim→Lôi, Mộc→Phong, Thủy→Băng, Hỏa→Dương, Thổ→U Minh;
- schema allows future additional branches;
- congenital rate = 0.20% total: 0.19% latent + 0.01% already awakened;
- ordinary birth has at most one congenital mutation;
- birth mutation is independent from Disciple Quality/Dẫn Tiên quality;
- latent identity exists before reveal and never rerolls;
- reveal at base purity 70; if congenital latent root is already >=70 at birth, it is Hiển Lộ immediately;
- congenital Thức Tỉnh requires base >=80, Thuế Biến >=90, Viên Mãn =100;
- a non-latent disciple can acquire a mutation after raising that base root to 100;
- display states are Tiềm Ẩn / Hiển Lộ, then power realms Thức Tỉnh → Thuế Biến → Viên Mãn; no second purity meter;
- matching mutation cultivation/mastery/skill-effect/resistance scale by cảnh giới Dị Căn;
- all owned mutations may be active simultaneously;
- base-root Resonance does not multiply mutation passive/mechanic values;
- cả năm Dị Căn Viên Mãn unlock Ngũ Dị Quy Nhất.

Locked mutation gameplay:
- Lôi: Lôi direct skill hit may call Thiên Lôi on a 6/5/4s internal cooldown; one proc per cast;
- Phong: skill creates 5s Phong Thế; next different skill gets 15/25/35% one-cast cooldown reduction; creation ICD 8/7/6s;
- Băng: one Hàn Ấn per caster-target-cast; 3 stacks trigger Băng Phong/Hàn Trệ; 15s mark life + 6s global refractory;
- Dương: converts 25/40/60% of the caster's remaining DoT into immediate damage; per-target ICD 8/6/4s;
- U Minh: once per encounter prevents lethal defeat, restores 15/25/35% Max HP and gives temporary incoming-damage protection;
- mutation secondary effects do not recursively trigger mutation mechanics by default.

Locked resource rule:
- five matching Bản Nguyên resources: Lôi/Phong/Băng/Dương/U Minh;
- primary source = matching elite/boss/secret-realm content;
- no mutation consumer may ship without a real acquisition source.

Important implementation dependency:
- design is closed but code is not authorized;
- mutation combat requires canonical skill tags/cast identity, Crit, Effect Hit/Resistance, source-owned DoT, control refractory, lethal interception and final combat-stat channels;
- do not invent temporary root-only substitutes.


# 10. Characteristic / Combat Stat framework — DESIGN LOCKED, NOT IMPLEMENTED

Canonical authorities:
- `docs/COMBAT_STATS_V2_SPEC.md`;
- `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`.

Locked structural rules:
- persistent sources, runtime state, derived channels and contextual outcomes are separate layers;
- Lục Duy remains the only general permanent foundation-stat block;
- Personality is behavioral/AI authority and is not Trait;
- Combat Stats use one canonical registry instead of duplicate subsystem-specific stats;
- living state uses current HP / normalized Thể Lực / named Thương Thế / Tâm Trạng / Trung Thành / Age-Lifespan;
- Healing Done, Healing Received and Shield Effect are canonical specialized combat channels;
- DoT/Skill/Control/element/path modifiers use registered channels + filters;
- derived values are reconstructible from source data and are not independent save truth;
- source provenance/breakdown is required;
- large-roster simulation computes only relevant channels.

No gameplay runtime implementation was added by this design lock.

# 11. Bloodline V2 — DESIGN LOCKED, NOT IMPLEMENTED

Canonical authority:
`docs/BLOODLINE_V2_SPEC.md`

Locked core:
- ordinary congenital total = **2.00%**:
  - 98.00% none;
  - 1.60% latent;
  - 0.40% revealed;
- ordinary birth max one special congenital Bloodline;
- lineage identity and birth purity are deterministic whole-person identity;
- purity is integer **1–100**;
- no universal Bloodline rarity color;
- no V2 private `combat_power_bonus`;
- effects use canonical character/combat/recovery channels;
- states: Tiềm Ẩn / Hiển Lộ / Thức Tỉnh / Phong Ấn / historical fused-replaced;
- awakened purity >=50 -> **Chân Huyết**;
- awakened purity 100 -> **Phản Tổ**;
- deterministic +1 refinement; resource cost rises, gained purity does not diminish;
- Huyết Tinh + Tổ Huyết + lineage-specific Huyết Nguyên resource model;
- post-birth Ban Huyết / Hoán Huyết / explicit Dung Huyết;
- no universal lifetime Bloodline cap, but later grants become exponentially expensive and conflicts/fusions are explicit;
- five first identities remain Chân Long / Phượng Hoàng / Bạch Hổ / Huyền Vũ / Thao Thiết Tàn Huyết, now redesigned around distinct build identities;
- significant-history reveal is retroactive;
- inheritance architecture is reserved but exact parent-child formula waits for Family V2;
- future Huyết Mạch Khai Tổ is an architecture hook only;
- P2.11 is compatibility-only until a tested migration replaces it.

No Huyết Mạch V2 runtime code has been added.

# 12. Next-chat carryover

Spiritual Root V2, Combat Stats V2 and the Disciple Characteristics/Stat Framework V2 are design-closed.

Traits V2 is now DESIGN LOCKED, NOT IMPLEMENTED.
Canonical authority:
`docs/TRAITS_V2_SPEC.md`

Mệnh Cách V2 is now DESIGN LOCKED, NOT IMPLEMENTED.
Canonical authority:
`docs/DESTINY_V2_SPEC.md`

Locked highlights:
- congenital total **0.50% = 0.45% latent + 0.05% revealed**;
- multiple compatible Mệnh Cách may coexist;
- no Chủ-Mệnh slot and no lifetime hard cap;
- no universal Khai/Hóa/Chứng ladder;
- Mệnh must be high-impact and build-defining;
- Mệnh Nguyên + explicit per-Mệnh acquisition recipes;
- significant-history retroactivity;
- explicit anti-farm laws;
- Mệnh Cục combinations;
- favorite disciple may eventually collect many compatible Mệnh.

Huyết Mạch V2 is now DESIGN LOCKED, NOT IMPLEMENTED.
Canonical authority:
`docs/BLOODLINE_V2_SPEC.md`

Realm Ladder V2 + Luyện Thể V2 core are now DESIGN LOCKED, NOT IMPLEMENTED.
Canonical authorities:
- `docs/REALM_LADDER_V2_SPEC.md`;
- `docs/BODY_CULTIVATION_V2_SPEC.md`.

Locked highlights:
- 30×10 Tu Vi and 30×10 Luyện Thể;
- Nhân/Tiên/Thần macro bands, 10 realms each;
- independent 1..300 global floors;
- Căn Cốt +0.20% natural/base body XP per point;
- Tiềm Lực +0.05% retroactive Realm+Body Core growth per point;
- Thể Lực is external-map expedition endurance only;
- production never consumes/reads it;
- base daily stamina = 100;
- exact normal-map body-floor match ≈18h body-only;
- +10 body floors ≈×1.20 endurance;
- body-only cap =22h;
- food/pills/facilities/special effects bridge toward ordinary 24h expedition cap;
- map recommendation is soft; undertrained disciples may still enter but stay less time;
- active expedition cannot exploit daily reset for a second full refill.

Physique / Thể Chất V2 base design is now DESIGN LOCKED, NOT IMPLEMENTED.
Canonical authority:
`docs/PHYSIQUE_V2_SPEC.md`

Locked highlights:
- no grade/purity/temper V2 authority;
- 97.00% none / 2.70% revealed / 0.30% latent congenital baseline;
- one active Core Physique;
- 15 weighted base identities;
- no lore-only enabled content;
- 14 base effect sets locked on canonical channels;
- Kiếm Cốt identity locked, effect explicitly blocked until Weapon/Skill V2 defines sword attribution;
- deterministic Cải/Tái Tạo/Tiến Hóa/Dung Thể;
- predecessor/fusion effects do not stack after replacement;
- persistent Physique history/provenance;
- explicit dependency registry and P2.12 migration direction.

Next default design subject:
**Cultivation + Breakthrough V2**.

Use:
- this ledger;
- `docs/DISCIPLE_V2_ROADMAP.md`;
- `docs/DISCIPLE_MASTER_SCHEMA.md`;
- `docs/SPIRITUAL_ROOT_V2_SPEC.md`;
- `docs/COMBAT_STATS_V2_SPEC.md`;
- `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`;
- `docs/TRAITS_V2_SPEC.md`;
- `docs/DESTINY_V2_SPEC.md`;
- `docs/BLOODLINE_V2_SPEC.md`;
- `docs/REALM_LADDER_V2_SPEC.md`;
- `docs/BODY_CULTIVATION_V2_SPEC.md`;
- `docs/PHYSIQUE_V2_SPEC.md`;
- live cultivation/map/combat code.

Do not implement any of these V2 design-locked systems without a new explicit implementation instruction.
