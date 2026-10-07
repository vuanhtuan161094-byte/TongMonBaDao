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

# 8. Reference ideas reserved for Spiritual Root V2

Reference-inspired candidates to evaluate next:
- five base roots: Metal / Wood / Water / Fire / Earth;
- single vs multi-element composition;
- purity/quality;
- mutation roots such as Wind / Lightning / Ice / Yang / Nether;
- elemental compatibility with techniques;
- root refinement after recruitment.

None of the exact mutation list, rates, bonuses or interactions above is automatically locked for this project.
The next chat must design them deliberately.

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

# 10. Next-chat carryover

The next design subject is **Spiritual Root V2**.

The assistant must not ask the user to restate the completed lục-duy/Dẫn Tiên decisions.

Use:
- this ledger;
- `docs/DISCIPLE_V2_ROADMAP.md`;
- `docs/DISCIPLE_MASTER_SCHEMA.md`;
- `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`;
- live code.

Start with design and reference comparison.
Do not code Spiritual Root V2 until the user explicitly approves the design.
