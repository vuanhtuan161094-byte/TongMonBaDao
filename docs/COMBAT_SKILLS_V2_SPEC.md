# KỸ NĂNG CHIẾN ĐẤU V2 — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-08  
Status: **DESIGN LOCKED — NOT IMPLEMENTED**

Read with:
- `docs/COMBAT_STATS_V2_SPEC.md`
- `docs/SPIRITUAL_ROOT_V2_SPEC.md`
- `docs/TECHNIQUE_V2_SPEC.md`
- `docs/CULTIVATION_PATH_V2_SPEC.md`
- `docs/REALM_LADDER_V2_SPEC.md`
- `docs/BODY_CULTIVATION_V2_SPEC.md`
- `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`

Legacy P2.5 remains compatibility-only until explicit migration.

This document is the canonical V2 authority for combat-skill ownership, loadout, mastery, AI use, elemental interaction and the Kiếm/Thể/Pháp combat language.

---

# 1. Skill boundary

A Kỹ Năng is:
- a combat action;
- a combat passive;
- or a combat-trigger rule.

It is separate from Công Pháp.

A skill may relate to Công Pháp by:
- independence;
- tag synergy;
- explicit prerequisite.

A Công Pháp does not automatically grant a full move set.

---

# 2. Loadout

Final mature combat loadout:

- **1 Thường Kỹ**
- **4 Chủ Động**
- **6 Bị Động Chiến Đấu**

These slots open gradually through Nhân Giới.

A newly Định-Đạo disciple does not start with the mature full loadout.

The exact realm/floor of each slot unlock is balance/content data.

## 2.1 Passive ownership

A self-only passive that:
- only modifies static personal channels;
- creates no trigger/event;
- creates no party effect;

does **not** require a combat-passive slot.

A passive that:
- triggers on events;
- creates proc/counter;
- affects party/team;
- creates active runtime state;

**does** require a combat-passive slot.

---

# 3. Three-wave skill lifecycle — Nhân / Tiên / Thần

This is a core V2 law.

## Wave 1 — Nhân Giới, realms 1–10

By the end of Nhân Giới, the class/branch catalogue exposes the full **foundational combat language**:
- single target;
- AoE;
- buff/debuff;
- control;
- support where appropriate;
- elemental mechanics;
- branch mechanics;
- active/passive identities.

This does **not** mean every disciple automatically owns every skill.
Learning still requires transmission/self-comprehension and requirements.

## Wave 2 — Tiên Giới, realms 11–20

Existing Nhân-generation families evolve into **Tiên generations**.

Evolution may add:
- higher damage/heal/shield;
- more targets/range/area;
- stronger status;
- new synergy;
- more powerful authored mechanics.

Tiên Giới does not restart the class catalogue from zero.

## Wave 3 — Thần Giới, realms 21–30

Tiên generations evolve into **Thần generations**.

Thần skills may add bounded rule-changing mechanics:
- Pháp Tắc-like effects;
- partial suppression/penetration of rules;
- encounter-limited lethal protection;
- higher-order elemental interaction;
- Hỗn Độn/Sáng Thế identities.

Rule-changing effects must be bounded and explicit.
"Ignore everything / permanent immunity / infinite reset" is not acceptable default design.

---

# 4. Skill family / evolution

Skills belong to authored families.

Evolution creates a named successor, not:
- +17 levels;
- star/color feeding.

A successor may:
- replace predecessor as active family source;
- inherit some mastery;
- open one or more authored branches.

If the Sect owns multiple successor branches:
- one disciple may eventually learn multiple variants;
- only one mutually-exclusive successor of the same family may be equipped at a time;
- switching does not erase mastery/history;
- switching loadout occurs outside combat.

Predecessor and successor do not stack when successor explicitly replaces it.

Thường Kỹ families may also evolve through Nhân → Tiên → Thần.

---

# 5. Learning

A skill is learnable only when all required conditions are satisfied.

Typical conditions:
1. Sect owns the skill transmission/manual, or the disciple self-comprehended it;
2. correct Chủ Đạo/branch if the skill requires one;
3. sufficient Tu Vi, Luyện Thể, or both;
4. prerequisite Công Pháp/skill/mastery where authored;
5. learning cost/time.

No character level exists.

## 5.1 Skill basis

Each skill declares one progression basis:

- **Tu Vi skill**
- **Luyện Thể skill**
- **Hybrid skill**

Hybrid does not have to be exactly 50/50.

Exact scaling coefficients are content/balance data.

---

# 6. Mastery

Personal mastery:

- Sơ Học
- Nhập Môn
- Tiểu Thành
- Đại Thành
- Viên Mãn

Progress is continuous beneath the labels.

Mastery milestones may have progression gates.

Examples:
- Tu Vi skill milestones read Tu Vi;
- Luyện Thể skill milestones read Luyện Thể;
- Hybrid milestones may require both.

A disciple may accumulate XP toward a milestone but cannot cross it until the authored progression gate is satisfied.

Thông Tuệ:
- increases valid mastery XP speed;
- does not set a final mastery ceiling.

Matching Spiritual Root:
- increases mastery XP for matching elemental skill content.

---

# 7. Valid mastery contribution

Avoid trivial spam.

Damage:
- valid hit/damage against a sufficiently meaningful target.

Heal:
- effective healing, not useless overheal.

Shield:
- actual damage absorbed.

Buff:
- real contribution/time/value, capped where needed.

Debuff:
- successful application to a valid target.

Control:
- actual valuable control.

Mobility:
- reposition that genuinely solved distance/danger.

Combat passive:
- valid trigger.

Static self passive:
- study/research plus relevant real actions where authored.

Diễn Võ may grant mastery but must not become an infinite no-risk spam exploit.

---

# 8. Skill grade

Candidate grade ladder:

- Phàm
- Huyền
- Địa
- Thiên
- Tiên
- Thần

Grade is rarity/depth, not a rigid realm mapping.

Do not hardcode:
- Phàm = Luyện Khí;
- Huyền = Trúc Cơ;
- etc.

A low-grade utility skill may remain useful for a long time.

The three-wave Nhân/Tiên/Thần generation is separate from the ordinary grade label, although higher generations naturally tend toward higher grades.

---

# 9. Acquisition / farm loop

Core loop:

Map/cluster hunt  
→ skill manuals/fragments/materials  
→ Tàng Kinh Các transmission  
→ learn  
→ Diễn Võ/real combat mastery  
→ comprehend/evolve  
→ harder content.

Sources may include:
- normal/elite/boss drops;
- cluster-specialty drops;
- Bí Cảnh;
- other Sect transmission/copying;
- trade/auction;
- missions/events;
- enemy Sect content;
- self-comprehension + Khắc Lục.

Common skills may drop as full manuals.
Rare skills may use fragments.

First archived complete Kỹ Phổ/Bí Kíp:
- unlocks Sect transmission;
- is not consumed once per disciple.

Duplicates may feed Sect research.

---

# 10. Self-comprehension

A disciple may self-comprehend an authored eligible skill when requirements are met.

Possible inputs:
- Chủ Đạo/branch;
- Realm/Luyện Thể;
- Công Pháp;
- relevant mastery/history;
- Đạo Lịch;
- Thông Tuệ;
- Ngộ Đạo facility/content.

This is deterministic eligibility + time/content, not a meaningless 0.01% lottery.

Initially:
- only that disciple knows the personal skill.

Khắc Lục Kỹ Phổ:
- makes the transmission available to the Sect.

V1 does not procedurally generate random skill names/effects.

---

# 11. Combat targeting geometry

Every active attack/support skill must declare a clear target/geometry model such as:

- single target;
- frontal arc;
- line;
- circle around caster;
- ground/target area;
- chain targets;
- projectile;
- multi-projectile;
- persistent zone.

AoE must declare:
- max targets;
- selection order;
- friendly-fire rule.

Default:
- no friendly fire.

A low-tier AoE must not accidentally hit unlimited actors.

---

# 12. Position AI

Each loadout has a simple combat-distance profile:

- cận chiến;
- trung cự ly;
- viễn trình;
- hậu tuyến.

Movement AI attempts to maintain that profile.

Examples:
- Bá Thể → cận chiến;
- Ngự Kiếm → trung/viễn;
- Y Đạo → hậu tuyến.

Do not build MOBA-grade kiting AI by default.

Ordinary movement handles approaching targets.
Mobility skills are optional tactical tools, not mandatory "walk buttons".

---

# 13. Skill-use AI

Default autonomous skill use is deterministic and simple.

Loadout priority:
1. Active slot 1
2. Active slot 2
3. Active slot 3
4. Active slot 4

AI scans top-down.

A skill is valid only if:
- cooldown ready;
- caster is not committed to another active action;
- target is valid;
- range/geometry is valid;
- the skill-specific condition is satisfied.

If no active skill is valid:
- use Thường Kỹ when possible.

Examples:
- Heal valid only if an ally has enough missing HP;
- Cleanse valid only if a removable debuff exists;
- Execute valid only below its HP threshold;
- Truy Phong valid only when distance actually requires it;
- Burn-payoff skill may require target Burn.

Do not use a large global utility-scoring AI as the default.

---

# 14. Cooldown and action timing

Separate:
- skill cooldown;
- internal cooldown;
- Basic Attack interval;
- cast time;
- projectile travel time.

Cooldown Recovery uses Combat Stats V2.

Conceptual:
`actual_cooldown = base_cooldown / (1 + cooldown_recovery)`

Architecture must allow:
- minimum cooldown;
- minimum cast time;
- minimum attack interval.

Exact floors are benchmark data.

No universal MMO-style Global Cooldown is required.

One actor cannot commit multiple active actions simultaneously unless a skill explicitly creates a secondary autonomous effect.

---

# 15. Initial readiness

Skills may declare:
- start ready;
- initial delay;
- setup requirement.

Ordinary skills may start ready.

Major ultimates may require:
- initial delay;
- prior actions;
- target state;
- HP threshold;
- other authored setup.

This prevents every encounter from becoming "six ultimate skills at second zero" without creating a universal Mana bar.

---

# 16. Cast interruption

A cast may declare:
- interruptible;
- uninterruptible.

If target dies before commit:
- cancel/reselect according to the skill AI rule;
- no committed cooldown unless the skill already committed.

After commit:
- cooldown/consumption follows the skill definition.

If an already-launched projectile loses its target:
- it does not automatically retarget unless that projectile/skill explicitly supports retarget/chain behavior.

---

# 17. Source attribution

Combat events must retain enough identity to prevent recursion/abuse:

- caster/source;
- skill ID;
- cast ID;
- element;
- style tag;
- hit index;
- target;
- effect/proc source where relevant.

One multi-hit cast may be limited to:
- one proc per target per cast;
- one stack placement per cast;
- other explicit bounded rules.

DoT/reflect/mutation/bloodline proc ownership follows the same shared attribution pipeline.

---

# 18. Crit default

Default behavior:

- eligible direct damage may crit;
- DoT does not crit;
- reflected damage does not crit;
- mutation proc does not crit;
- Bloodline proc does not crit;
- fixed damage does not crit;
- heal/shield do not crit;

unless the skill/effect explicitly opts in.

---

# 19. Buff/debuff/shield stacking

Every persistent effect declares one stacking policy:

- Unique
- Strongest Only
- Refresh
- Stack N
- Independent

Example:
- party damage buff → Strongest Only;
- Phá Giáp → Stack N with shared max;
- Shield → explicit family/cap/refresh/replace behavior.

No undefined stacking.

---

# 20. Control / Cleanse / Dispel

Canonical concepts:

- Slow;
- Root;
- Stagger;
- interrupt;
- displacement;
- silence/lock only when content supports it;
- Cleanse ally debuff;
- Dispel enemy buff.

Bosses may use:
- resistance;
- refractory;
- soft-control replacement.

Do not permit permanent stun-lock.

Băng mutation already establishes:
- normal enemies may Freeze;
- bosses receive Hàn Trệ instead of unrestricted hard Freeze.

---

# 21. Effect tier — Nhân / Tiên / Thần

Certain non-damage effects have a tier:

- Nhân
- Tiên
- Thần

This applies where needed to:
- hard control;
- cleanse;
- dispel;
- sealing;
- lethal interception;
- rule-changing effects.

A low-tier control does not fully lock an arbitrarily higher-tier target merely because Effect Hit is huge.

A low-tier Cleanse does not automatically remove a higher-tier protected debuff.

Damage is not hard-disabled by this tier system.

Exact cross-tier degradation/eligibility tables are future balance/content data.

---

# 22. No universal combat resource

There is no universal:
- Mana;
- Kiếm Ý bar;
- Cương Kình bar;
- Rage;
- generic combo point.

Most skills use:
- cooldown;
- cast/action timing;
- authored conditions.

A specific build may define a special resource only when it materially creates that build's gameplay.

---

# 23. Ngũ Hành combat skill framework

Ngũ Hành is a cross-class combat property, not a class.

Base element identities:

- **Kim** — phá / xuyên / hard-target pressure
- **Mộc** — sinh / sustain / heal / growth
- **Thủy** — lưu chuyển / tempo / slow / cooldown manipulation
- **Hỏa** — Burn / burst / AoE pressure
- **Thổ** — trấn / defense / shield / suppression

No element exclusively owns a mechanic.

Skills may be neutral/non-elemental.

By default one skill has one primary combat element.
Special advanced/multi-element content must declare components explicitly.

---

# 24. Elemental counter

Use Spiritual Root V2 authority:

- Kim khắc Mộc
- Mộc khắc Thổ
- Thổ khắc Thủy
- Thủy khắc Hỏa
- Hỏa khắc Kim

Starting matchup:
- favorable counter: ×1.25 elemental effect/damage;
- unfavorable counter: ×0.85;
- neutral: ×1.00.

Monsters/content expose:
- primary element or neutral;
- elemental resistances.

---

# 25. Tương Sinh combo

Generation cycle:

- Mộc → Hỏa
- Hỏa → Thổ
- Thổ → Kim
- Kim → Thủy
- Thủy → Mộc

Tương Sinh is **opt-in per skill**, not a global automatic damage bonus.

A caster may remember:
- last valid element used.

An eligible skill can read that state and apply its authored bonus.

Personal Tương Sinh does not automatically use another party member's last element.

Party cooperation happens through target/ally states such as:
- Burn;
- Phá Giáp;
- Trấn Áp;
- Sinh Cơ;
- Slow;
- other authored marks.

---

# 26. Dị Linh Căn consumers

Skill data supports:
- base_element;
- advanced_element;
- path/style;
- effect tags;
- mutation requirements;
- root-scalable numeric fields.

Locked advanced consumers:
- Lôi direct damage may trigger Thiên Lôi;
- Phong creates Phong Thế for one later skill-rotation benefit;
- Băng creates Hàn Ấn/Băng Phong/Hàn Trệ;
- Dương may convert owned remaining DoT into burst;
- U Minh supports survival/debuff identities and Minh Mệnh.

Mutation proc chains do not recursively retrigger themselves by default.

---

# 27. Party and encounter scope

Party maximum:
- **6 disciples**.

A hunting cluster maximum:
- **30 disciples**.

Party buffs:
- affect only the exact party unless explicitly encounter-wide.

If multiple parties fight one encounter:
- target debuffs belong to the target/encounter state;
- shared caps apply globally to that target.

Example:
- Phá Giáp max 3 means max 3 on the boss total, not 3 per party.

---

# 28. Participation

Support must earn valid combat participation.

Valid contribution may include:
- damage;
- tanking;
- effective healing;
- shield absorption;
- buff contribution;
- debuff;
- control;
- cleanse;
- emergency save;
- meaningful time participated.

Do not make progression/reward DPS-only.

---

# 29. Downed state

At 0 HP:
- actor becomes **Bị Hạ** for that encounter.

Bị Hạ:
- cannot act;
- is not a target for ordinary healing;
- stops creating new contribution;
- remains out until encounter end unless explicitly revived.

This is not permanent death.

Only a skill explicitly marked as revive can return a downed actor during the encounter.

---

# 30. Monster/boss skill engine

Monsters and bosses use the same combat primitives:
- cooldown;
- cast;
- projectile;
- AoE;
- direct damage;
- heal;
- shield;
- buff/debuff;
- control;
- effect tier;
- source attribution.

They do not use:
- player learning;
- Tàng Kinh Các;
- personal skill mastery.

Bosses may additionally use:
- phases;
- special behavior policies;
- authored immunities/refractory rules.

Do not build a separate incompatible MonsterAbility engine.

---

# 31. Runtime / scale

Target population:
- 1,000–3,000 disciples.

Map:
- event-driven;
- only active encounters create combat runtime actors.

Offscreen map:
- simulation data/event queue.

Viewed map:
- presentation renders the same authority.

Outcome must not change merely because the map is being viewed.

Avoid:
- actor × skill × frame polling;
- ticking cooldowns for every idle disciple.

Use scheduled/event-driven expiry, cooldown and DoT events where practical.

Persistent DoT/Shield/HoT magnitude is snapshot by default at application time unless a definition explicitly declares dynamic recomputation.

---

# 32. Kiếm Tu — foundational identity

Kiếm Tu combat identity:
- sword technique;
- balanced single/AoE;
- precision;
- phá thế;
- counter;
- Ngự/Sát/Hộ branches.

Movement is handled normally by AI.
Mobility skills such as Truy Phong Bộ are optional tactical content, not mandatory rotation buttons.

## 32.1 Major family targets

- Kiếm Kích / basic sword family
- Nhất Kiếm / single-target family
- Hoành Tảo / Quần Kiếm AoE family
- Ngự Kiếm family
- Phá Quân / Phá Giáp family
- Hộ Kiếm family
- Phản Kiếm family
- optional mobility family
- Kim/Mộc/Thủy/Hỏa/Thổ sword families
- Kiếm Trận / Kiếm Vực / late rule-changing descendants

Representative Nhân skills include:
- Thanh Phong Trảm — fast single target;
- Hoành Tảo Kiếm — frontal multi-target;
- Ngự Kiếm Dẫn — ranged Tu Vi-oriented sword action;
- Kim Phong Thứ — single-target penetration;
- Thanh Mộc Kiếm — damage + personal sustain;
- Lưu Thủy Kiếm — tempo/rotation;
- Liệt Hỏa Kiếm — Burn pressure;
- Trấn Sơn Kiếm — suppression/guard identity;
- Phá Giáp Kiếm — shared target Defense debuff;
- Hộ Kiếm Thức — protection;
- Truy Phong Bộ — optional chase/reposition.

## 32.2 Branches

### Ngự Kiếm
- Tu Vi leaning;
- ranged;
- multiple flying swords;
- multi-target;
- formations/zones.

### Sát Kiếm
- single target;
- burst;
- execute;
- crit;
- debuff exploitation;
- boss pressure.

### Hộ Kiếm
- parry;
- counter;
- shield/protection;
- party defense;
- defensive sword formations.

## 32.3 Three-wave examples

Single-target family:
- Nhân: Thanh Phong Trảm / later Nhất-Kiếm successor
- Tiên: stronger named successor such as Thanh Tiêu Nhất Kiếm
- Thần: rule-changing successor such as Nhất Kiếm Khai Thiên

AoE family:
- Nhân: Hoành Tảo Kiếm
- Tiên: evolved sword-wave/multi-sword form
- Thần: battlefield-scale sword-zone descendant

Exact names are content-authoring data unless already locked by a later catalogue spec.

---

# 33. Thể Tu — foundational identity

Thể Tu identity:
- body as weapon;
- Luyện Thể emphasis;
- heavy hit;
- stagger;
- Phá Cương;
- counter;
- threat/protection;
- Huyết-Chiến risk-reward.

Thể Tu is not synonymous with Tank.

## 33.1 Major family targets

- Quyền Cước / basic body family
- Trọng Quyền / single heavy
- Quần Cước / Chấn Địa AoE
- Phá Cương
- Thiết Sơn charge/stagger
- Hộ Thể / Kim Cương
- Phản Chấn
- Hộ Chủ
- Huyết Chiến
- Ngũ Hành Thể
- Pháp Thân
- Chiến Vực/Uy Áp
- Thần Lực/rule-changing body descendants

Representative Nhân skills:
- Chấn Sơn Quyền — single heavy + stagger;
- Hoành Tảo Cước — frontal AoE;
- Hộ Thể — temporary defense;
- Thiết Sơn Kháo — optional charge/stagger;
- Kim Cương Chỉ — focused penetration;
- Thanh Mộc Kình — sustain;
- Lưu Thủy Kình — flow/rotation;
- Liệt Huyết Quyền — Hỏa pressure/Nhiệt Huyết;
- Trấn Sơn Chưởng — suppression/defense;
- Phá Cương Chưởng — heavy armor break;
- Địa Chấn Cước — local AoE control;
- Bất Động Thân — defense/control resistance with movement tradeoff;
- Huyết Chiến — power from real combat HP loss.

## 33.2 Threat/Uy Hiếp

Defensive Thể builds require a simple enemy-targeting pressure system.

Threat may read:
- distance;
- recent damage;
- recent healing/support;
- explicit threat skills;
- taunt/chấn nhiếp effects.

Bosses may resist or soften hard taunt.

Without Threat, Kim Cương cannot function as a real protection role.

## 33.3 Branches

### Bá Thể
- offense;
- heavy strikes;
- armor break;
- stagger;
- AoE;
- boss pressure.

### Kim Cương
- damage reduction;
- guard;
- threat;
- counter;
- control resistance;
- party protection.

### Huyết Thể
- low-HP/risk-reward;
- sustain;
- execute;
- survival thresholds.

Base Huyết Thể does not self-damage merely to exploit low-HP bonuses.
Late authored HP-cost skills may exist but self-cost must not count as enemy damage for trigger abuse.

## 33.4 Tiên/Thần identity

Tiên Thể content may evolve into:
- Pháp Thân state;
- larger geometry;
- stronger threat/control resistance;
- battle-field persistent pressure.

Pháp Thân is a state on the actor, not a second summon actor by default.

Thần descendants may add bounded:
- rule penetration;
- lethal protection;
- capped direct-damage sustain;
- Hỗn Độn/Sáng Thế body identities.

---

# 34. Pháp Tu — foundational identity

Pháp Tu identity:
- Tu Vi emphasis;
- ranged;
- Ngũ Hành;
- AoE;
- status;
- heal/buff/debuff/control;
- Cast Speed / Effect Hit / Cooldown interaction.

Pháp Tu has the broadest toolkit but only four active slots, so loadout choice is the balancing pressure.

## 34.1 Representative Nhân skills

- Linh Khí Đạn — neutral ranged Thường Kỹ;
- Linh Bạo Thuật — basic AoE;
- Kim Mang Chỉ — single-target penetration;
- Hồi Xuân Thuật — heal + Sinh Cơ;
- Hàn Sương Ấn — Water slow/control foundation;
- Hỏa Cầu — direct + Burn;
- Liệt Diễm — Hỏa AoE/payoff;
- Thổ Linh Thuẫn — Shield;
- Định Thân Ấn — Root/control;
- Suy Linh Chú — debuff;
- Linh Quang Gia Trì — party buff;
- Thanh Tâm Chú — Cleanse;
- Tán Linh Chú — Dispel;
- Hộ Mệnh Thuật — emergency support.

## 34.2 Branches

### Ngũ Hành
- elemental specialization or multi-element rotation;
- matchup;
- Tương Sinh;
- AoE/burst/status.

### Y Đạo
Must support:
- heal;
- buff;
- cleanse;
- emergency save.

Higher generations may add:
- stronger party sustain;
- lethal prevention;
- very rare bounded revive.

### Huyền Pháp
- control;
- debuff;
- dispel;
- sealing;
- Pháp Trận;
- Effect Hit/Resistance manipulation;
- late local rule-changing zones.

## 34.3 Three-wave examples

Fire family:
- Nhân: Hỏa Cầu / Liệt Diễm;
- Tiên: evolved high-tier Fire descendants;
- Thần: Fire-law descendants with bounded resistance/recovery suppression.

Emergency Y family:
- Nhân: Hộ Mệnh Thuật;
- Tiên: stronger lethal-prevention successor;
- Thần: extremely rare bounded revive successor may exist.

Control family:
- Nhân: Định Thân Ấn;
- Tiên: stronger control/debuff successor;
- Thần: short bounded sealing/rule manipulation.

---

# 35. Catch-up transmission

Late-game recruitment must not force the player to re-farm ancient low-tier manuals already mastered by the Sect.

If the Sect owns:
- predecessor transmission;
- successor transmission;

and the disciple satisfies requirements, a complete transmission path may teach the chain without needing a new physical copy of the old manual.

This does **not** grant free personal mastery.

The disciple still learns/trains the current generation under the relevant costs/time/mastery rules.

---

# 36. UI readability

Player-facing skill card should prioritize:

- Name
- Element
- Chủ Đạo/branch
- Basis: Tu Vi / Luyện Thể / Hybrid
- Requirement
- Cooldown
- Target/number of targets
- Plain-language effect
- Simple combo/synergy
- Mastery next milestone
- Evolution family

Do not expose implementation-first jargon such as:
- cast_id;
- stack_family;
- source_key;

as the primary player explanation.

---

# 37. Weapon/style boundary

Skills may declare:
- `style_tag = sword/body/spell/...`
- `weapon_requirement = sword/.../none`

These are separate.

Weapon V2 will own:
- canonical weapon types;
- equip legality;
- equipment-derived requirements.

This closes the skill-side half of the Kiếm-Cốt dependency but does not yet define Kiếm Cốt's final numeric effect.

---

# 38. Legacy migration

P2.5 remains compatibility runtime until V2 implementation.

V2 supersedes legacy assumptions that:
- every learned skill is automatically eligible for autonomous use;
- there is no final slot limit;
- only the initial 3×3 starter skill library defines long-term content.

Migration must preserve old learned-skill identity/history where possible.

---

# 39. Locked summary

1. 1 Thường + 4 Active + 6 Combat Passive final loadout.
2. Static self passives need no combat slot; triggered/party passives do.
3. Skills grow in three waves: Nhân foundation, Tiên evolution, Thần evolution.
4. Skill families use named successors, not +level feeding.
5. Learn requires transmission/self-comprehension + path + progression prerequisites.
6. No character level.
7. Mastery uses five milestones and valid-use anti-farm rules.
8. Skill basis = Tu Vi / Luyện Thể / Hybrid.
9. AI = priority slots 1→4 + per-skill validity.
10. Position AI uses simple range profile.
11. Movement is normal AI; mobility skills are optional tactical content.
12. Cooldown/cast/projectile/ICD are separate.
13. Buff/debuff/shield stacking is explicit.
14. Effect tiers protect Nhân/Tiên/Thần control/cleanse/rule interactions.
15. No universal Mana/Rage/Kiếm Ý resource.
16. Ngũ Hành and Tương Sinh are shared cross-class combat layers.
17. Party max 6; encounter debuff caps are target-shared.
18. 0 HP = Bị Hạ; ordinary heal cannot revive.
19. Monsters/bosses use the same combat primitives.
20. Kiếm/Thể/Pháp each have complete Nhân foundation then evolve through Tiên and Thần.
21. Runtime must be event-driven and scale to 1,000–3,000 disciples.
