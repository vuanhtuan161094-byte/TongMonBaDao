# DISCIPLE V2 DESIGN LEDGER — LOCKED DECISIONS + REFERENCE LESSONS

Status: CANONICAL DESIGN LEDGER  
Updated: 2026-10-08

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

# 12. Cultivation + Breakthrough V2 — DESIGN LOCKED, NOT IMPLEMENTED

Canonical authority:
`docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md`

Locked:
- minor floors auto-advance;
- only major-realm transitions use breakthrough chance;
- default failure loses 10% gate requirement;
- same-gate failure gives +5 percentage points next attempt;
- same-gate and lifetime failure histories are separate;
- max 3 breakthrough consumables;
- no generic HP/Stamina/cooldown consequence;
- no generic Tư Chất/Căn Cốt/Cơ Duyên/Root/Physique chance bonus;
- auto breakthrough is supported;
- fixed +X cultivation remains fixed;
- Hậu Tích/Tích Tu, Hồng Trần Luyện Tâm and Đại Khí Vãn Thành are explicitly covered.

# 13. Công Pháp V2 — DESIGN LOCKED, NOT IMPLEMENTED

Canonical authority:
`docs/TECHNIQUE_V2_SPEC.md`

Locked:
- Công Pháp is cultivation/build/passive foundation; Kỹ Năng is combat action/passive;
- active loadout = 1 Chủ Tu + 2 Phụ Tu;
- learned inactive Công Pháp retain knowledge/mastery/history but ordinary effects are inactive;
- first full manual archived to Tàng Kinh Các unlocks Sect transmission;
- teaching is deterministic and does not consume one manual per disciple;
- personal mastery = Sơ Học → Nhập Môn → Tiểu Thành → Đại Thành → Viên Mãn;
- Sect Nghiên Tu is separate from personal mastery;
- grade is rarity/depth, not universal multiplier;
- Diễn Hóa creates authored named successors/branches;
- personal discovery may be Khắc Lục for Sect transmission;
- technique-skill relation = independent / tag synergy / prerequisite.

Legacy P2.3 max-three-learned / one-active / level-1–5 model is compatibility-only for V2.

# 14. Chủ Đạo / Đạo Lịch V2 — DESIGN LOCKED, NOT IMPLEMENTED

Canonical authority:
`docs/CULTIVATION_PATH_V2_SPEC.md`

Locked:
- Chưa Định Đạo → Kiếm / Thể / Pháp;
- no class level;
- no generic class-stat growth;
- branches:
  - Kiếm: Ngự / Sát / Hộ;
  - Thể: Bá / Kim Cương / Huyết;
  - Pháp: Ngũ Hành / Y Đạo / Huyền Pháp;
- only one active path/branch;
- switching preserves learned techniques/skills/mastery/history;
- Đạo Lịch records meaningful lived history and is not a free stat multiplier;
- Định Đạo and Diễn Đạo are deterministic when requirements are met;
- no universal Kiếm Ý/Cương Kình/Pháp Ấn/Y Tức resource.

Legacy P2.4 generic path-XP stat bonuses are not V2 authority.

# 15. Combat Skills V2 — DESIGN LOCKED, NOT IMPLEMENTED

Canonical authority:
`docs/COMBAT_SKILLS_V2_SPEC.md`

Locked structural rules:
- mature loadout = 1 Thường + 4 Active + 6 Combat Passive;
- static self-only passives do not need combat slots; triggered/party passives do;
- skills use Tu Vi / Luyện Thể / Hybrid progression basis;
- mastery = Sơ Học / Nhập Môn / Tiểu Thành / Đại Thành / Viên Mãn;
- mastery credit uses real contribution and anti-trivial-farm rules;
- skill family evolution uses named successors, not +level feeding;
- Nhân Giới learns/opens the full foundational combat language;
- Tiên Giới evolves those same families;
- Thần Giới evolves them again with bounded rule-changing effects;
- AI default = priority Active 1→4 + per-skill validity;
- movement AI uses simple cận/trung/viễn/hậu-tuyến profiles;
- ordinary movement handles approach; mobility skills are optional tactical content;
- cooldown / internal cooldown / cast / attack interval / projectile travel are separate;
- architecture supports minimum cooldown/cast/attack interval;
- buff/debuff/shield stacking is explicit;
- effect tiers Nhân/Tiên/Thần apply where needed to hard control/cleanse/dispel/sealing/lethal/rule effects;
- no universal Mana/Rage/Kiếm Ý combat resource;
- Ngũ Hành skill identity and opt-in Tương Sinh combo are shared across classes;
- party max = 6; hunting cluster max = 30;
- target debuff caps are shared encounter state;
- 0 HP = Bị Hạ; ordinary heal cannot revive;
- monsters/bosses use the same combat primitives;
- offscreen/viewed combat must resolve from the same simulation authority.

Class branches are design-closed:
- Kiếm Tu: Ngự Kiếm / Sát Kiếm / Hộ Kiếm;
- Thể Tu: Bá Thể / Kim Cương / Huyết Thể;
- Pháp Tu: Ngũ Hành / Y Đạo / Huyền Pháp.

Important class identities:
- Kiếm = technique, sword families, single/AoE, precision, phá thế, counter;
- Thể = body weapon, Luyện Thể, heavy/stagger, threat/protection, Huyết Chiến;
- Pháp = Tu Vi, ranged, Ngũ Hành, AoE, status, heal/buff/debuff/control.

# 16. Three-wave skill law — LOCKED

This is a long-form 30-realm rule:

## Nhân Giới 1–10
The class/branch exposes its full foundational combat language.

By end Nhân:
- Active/passive foundation is complete;
- single/AoE/support/control/elemental/branch mechanics already exist where appropriate;
- mature 1 Thường + 4 Active + 6 Combat Passive capacity is reachable.

This does NOT mean every disciple owns every skill.
Transmission, requirements and mastery still matter.

## Tiên Giới 11–20
Nhân skill/passive families **Tiên hóa**:
- stronger magnitude;
- larger range/target count;
- stronger status;
- additional authored effects.

## Thần Giới 21–30
Tiên families **Thần hóa**:
- power rises again;
- bounded Pháp Tắc/rule-changing effects become possible;
- Hỗn Độn/Sáng Thế identities may appear.

The player is not asked to learn a completely unrelated new class catalogue at each macro world.

# 17. Kiếm Cốt dependency status

Combat Skills V2 now closes the skill-side half:
- sword style tag direction exists;
- weapon requirement is separate from style;
- cast/source/hit attribution exists;
- AoE/multi-hit attribution exists;
- weaponless sword-style content is representable.

Kiếm Cốt remains effect-blocked because Weapon + Equipment V2 still needs to decide:
- canonical weapon types;
- sword equip semantics;
- weapon requirement checks;
- weapon-tag equipment modifiers;
- whether weapon-specific mastery exists at all.

Do not enable Kiếm Cốt effectless.

# 18. Weapon + Equipment V2 matrix — PARTIAL DESIGN LOCK (2026-10-08)

Canonical detail: `docs/WEAPON_EQUIPMENT_V2_REALM_MAP_SET_MATRIX.md`.

Locked map law recalled from prior user decision: **one map has 10 clusters**, max 30 concurrently hunting disciples per cluster, max 6 per party; not 10 separate maps per realm. New extension: 30 primary progression maps keyed to 30 realm indices, 10 clusters each (300 baseline authored clusters). Gear uses matching realm index 1..30 and independent 12 quality names, no parallel Phẩm Lực.

10 equipped slots: 5 ordinary (weapon, armor, head, footwear, pendant), 3 Phù and 2 Pháp Bảo; consumable belt is separate. Set bonuses on eligible non-weapon gear: 2-piece + 3-piece, with permitted 2+2 or 3+1 loadout, strongest-only party aura. **All equipment is owned by Sect only**; disciples are users/assignees. No personal gear ownership, compensation or private gear purchase. Actual 300 cluster content, numerical affix/set balance, crafting recipes and gameplay implementation remain open.

# 19. Next design subject

Next default design subject:
**Weapon + Equipment V2 (continue detailed content/affixes/sets and balance)**

Then preferred queue:
1. Pháp Bảo + Phù V2;
2. Profession V2 final consolidation;
3. Living State V2;
4. Mood / Loyalty / Needs;
5. Personality + autonomy + goals/memories;
6. Relationships / Social V2;
7. Sư đồ / Đạo lữ / organization roles;
8. Family/inheritance if enabled;
9. Whole Disciple Generation V2 final assembly;
10. whole-disciple contradiction/dead-stat audit;
11. implementation dependency plan.

Do not implement any V2 design-locked subsystem without a new explicit implementation instruction.


# Weapon + Equipment V2 — USER-APPROVED STRUCTURE (2026-10-08)

Current authority: `docs/WEAPON_EQUIPMENT_V2_SPEC.md` (10 ordinary slots; 12 grades; 6 ordinary stat affixes, 2 rare conditional/stat affixes, 1 inscribable individual Chân Văn maximum; max 2 general lines; allowed cross-system effects; all Sect-owned) and `docs/EQUIPMENT_SETS_V2_SPEC.md` (18 combat+6 work sets, four authored pieces each, six eligible positions, cumulative 2/3/4 stat-channel bonuses, both 3-piece bonuses active at 3+3, Nhân/Tiên/Thần family specialization). Old 5-slot, 2/3-only, Chân Văn Cộng Hưởng, automatic set skills and enhancement +15 as a locked cap are SUPERSEDED. Numerical gear power, percentages, costs, recipes, loot rates, final enhancement cap and genuine runtime implementation are OPEN.

# 20. Tu Vi / Luyện Thể source model — USER LOCK 2026-10-09

This supersedes any earlier implication that ordinary work itself grants a separate generic Tu Vi reward.

**Starting state**
- every newly generated production V2 disciple starts at **Phàm Nhân tầng 1 / 0 Tu Vi EXP**;
- every newly generated production V2 disciple starts at **Phàm Thân tầng 1 / 0 Luyện Thể EXP**;
- Tư Chất/Căn Cốt affect growth rate after recruitment, not starting realm/floor;
- legacy/dev-save compatibility mappings are migration-only and must not leak into new production recruitment.

**Tu Vi**
- every eligible disciple continuously absorbs natural Tu Vi over elapsed simulation time while living/acting normally;
- work, travel, hunting and normal combat do not add a second generic Tu Vi EXP award;
- `CULTIVATE` = **Chuyên Tu**, an explicit acceleration/multiplier of the same natural source;
- Tư Chất +0.25%/point applies to natural Tu Vi;
- monster kills do not directly grant Tu Vi; monsters may drop **Tinh Nguyên**;
- absorbing Tinh Nguyên, Tu Vi pills and ordinary authored +X rewards are fixed injections and are not multiplied by Tư Chất unless explicitly marked scalable.

**Luyện Thể**
- no passive body EXP from merely living/working/travelling/fighting;
- body EXP requires an **explicit authored Luyện Thể source**, but the concrete action/activity has NOT been locked yet;
- Căn Cốt +0.20%/point applies to natural/base body-training EXP;
- fixed body pills/material rewards remain fixed unless explicitly scalable.

**Time semantics**
- **15 seconds is NOT a gameplay balance unit.**
- Display/balance uses **Tu Vi per simulation minute**.
- Current P3.7 time semantics already define 1440 simulation ticks/day, so one scheduler step is one simulation minute.
- Wall-clock cadence may batch these minutes later, but equal simulated minutes must yield identical deterministic Tu Vi progression online/offline.
- **No Luyện Thể time unit or TRAIN_BODY activity is locked yet.** Body EXP sources, activity model, rate unit and schedule are the next design work.
- Production numeric Tu Vi/minute and Chuyên Tu multiplier remain OPEN until balance approval.

Implementation note: current DV2-03 action-based training/work bridge does **not yet fully implement this new source model**. In particular, passive Tu Vi and removal of the separate generic work-Tu-Vi award remain required code migration work.

