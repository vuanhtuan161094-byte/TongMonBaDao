# DISCIPLE CHARACTERISTICS & STAT FRAMEWORK V2 — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-07
Status: **DESIGN DRAFT FOR USER REVIEW — NOT IMPLEMENTED — NOT LOCKED**

Parents:
- `docs/GAME_SYSTEM_ARCHITECTURE.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`
- `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`
- `docs/SPIRITUAL_ROOT_V2_SPEC.md`
- `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`
- `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`
- `docs/COMBAT_STATS_V2_SPEC.md` — locked Combat Stat registry/semantics

Purpose:
- define what a disciple actually consists of;
- separate permanent facts, progression, living state, personality and derived stats;
- define canonical stat/modifier channels before Traits/Bloodline/Physique create more modifiers;
- prevent parallel or duplicate stat authorities;
- keep the model scalable for roughly 1,000–3,000 disciples.

This draft does **not** authorize gameplay implementation.

---

# 1. Design principle

A disciple is not one giant stat sheet.

Use four layers:

1. **Persistent sources** — identity, lục duy, progression, Linh Căn, Trait, Bloodline, Physique, equipment ownership, etc.
2. **Runtime state** — current HP, stamina, injuries, mood, loyalty, temporary buffs/debuffs, current activity.
3. **Derived channels** — Attack, Defense, Max HP, movement speed, crit, work speed result, learning result, etc.
4. **Contextual outcomes** — one combat hit, one work cycle, one social action, one cultivation tick, one lucky event.

Do not persist a derived total as a second authority when it can be recalculated from canonical sources.

A cached derived value is allowed for performance only if:
- its source-version/invalidation is deterministic;
- it is not save truth;
- it can always be rebuilt exactly.

---

# 2. External reference lessons used

This project adapts principles, not exact balance/content.

## RimWorld
Useful lesson:
- health/capacity and final stats are different layers;
- injury can reduce a capability such as movement without rewriting the pawn's permanent identity;
- many final task stats are derived from skills + capacities + contextual factors.

Project adaptation:
- injury/fatigue/state modifies canonical channels;
- it does not permanently rewrite Lục Duy or progression.

## Oxygen Not Included
Useful lesson:
- Attributes, Skills, Interests, Traits, Morale/Stress and errands are separate concepts;
- interests can accelerate learning without being the same thing as skill level;
- a Trait may alter stats or rules without replacing the skill system.

Project adaptation:
- profession talent = learning affinity;
- profession level = actual learned proficiency;
- Trait = modifier/rule change;
- mood/state remains separate.

## Dwarf Fortress
Useful lesson:
- physical/mental attributes, skills, personality facets, preferences and needs are distinct;
- personality influences behavior and what matters to the character rather than existing only as combat buffs.

Project adaptation:
- personality belongs in AI utility/decision logic;
- Trait and personality are not synonyms.

## Amazing Cultivation Simulator
Useful lesson:
- base attributes, skills, cultivation state and many derived properties can coexist;
- cultivation-specific temporary state may influence cultivation/breakthrough;
- excessive derived properties can become difficult to reason about.

Project adaptation:
- preserve cultivation depth;
- avoid exposing hundreds of unrelated property fields;
- use a small canonical channel registry plus tagged/filterable modifiers.

## 《最强祖师》
Useful lesson:
- six dimensions summarize broad development;
- root/trait/physique/destiny/profession can make a lower headline-quality disciple strategically valuable.

Project adaptation:
- Disciple Quality remains only a lục-duy summary;
- no single rarity/quality field owns the whole character.

---

# 3. Canonical character layers

## 3.1 Identity facts — not stats

Persistent identity:
- ID/profile seed;
- recruitment source;
- display name;
- race;
- sex;
- origin/background history;
- age/date history;
- immutable birth snapshots;
- event/history records.

These are not modifiers merely because they are shown on the character sheet.

A race/origin may provide explicit content modifiers later, but the identity itself remains separate.

---

## 3.2 Lục Duy — permanent foundation attributes

Already canonical and locked:

- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

These are open-point permanent growth dimensions.

They do not become combat Attack/Defense directly except where a locked rule explicitly consumes them.

Existing meanings remain:
- Tư Chất -> natural/base cultivation gain;
- Căn Cốt -> body-training XP;
- Cơ Duyên -> meaningful Luck Score check;
- Thông Tuệ -> learning/mastery XP;
- Mị Lực -> social/recruitment power;
- Tiềm Lực -> future Realm + Luyện Thể core ATK/DEF/HP growth quality.

Disciple Quality remains derived only from current permanent Lục Duy total.

---

## 3.3 Personality / behavioral tendencies — decision inputs, not power stats

Personality and behavior are distinct from Trait.

Current runtime has:
- risk tendency;
- spending tendency;
- survival tendency;
- personality archetype.

Framework rule:
- personality primarily changes AI utility, preferences, priorities and reactions;
- personality does not automatically add Attack/Work Speed merely because its name sounds positive;
- if a personality genuinely modifies a numeric channel, that must be an explicit effect and visible in breakdown.

The exact final Personality V2 axis set is a later design subject.
Do not invent more permanent axes in this framework without a real consumer.

---

## 3.4 Special identity/growth layers — sources, not duplicate stats

These layers own their own identity/progression:
- Linh Căn;
- Dị Linh Căn;
- Trait / Đặc Chất;
- Mệnh Cách;
- Huyết Mạch;
- Thể Chất;
- future Pháp Bảo/inheritance;
- equipment/loadout.

They may contribute:
- flat values;
- percentage modifiers;
- percentage points;
- tagged/contextual modifiers;
- triggered rule changes.

They may not silently create a parallel Attack/Defense/Work-Speed formula.

---

## 3.5 Learned progression

Persistent learned/progression state:

### Tu luyện
- cultivation realm/stage;
- current Tu Vi/progress;
- breakthrough history/failure support state.

### Luyện Thể
- body-training progression;
- body-training XP/progress;
- later body realm/stage authority.

### Công pháp / kỹ năng
- learned techniques;
- technique mastery;
- learned combat skills;
- skill mastery;
- active technique/loadout.

### Đạo lộ
- Kiếm / Thể / Pháp accumulated path XP/history;
- identity is derived from actual progression, not a fixed class.

### Nghề nghiệp
- profession XP;
- derived profession level;
- profession-specific talent/affinity;
- work preferences.

Progression belongs to its subsystem.
Do not copy profession level into a permanent "work power" stat.

---

# 4. Living/runtime state

Runtime state changes frequently and must not rewrite permanent identity.

## 4.1 HP
- `current_hp`: runtime;
- `max_hp`: derived combat stat;
- current HP is bounded by current derived Max HP.

## 4.2 Thể Lực
Use one normalized **0–100 Stamina/Thể Lực meter** by default.

Why normalized:
- it is a current-condition meter, not a permanent growth axis;
- long-term progression should improve cost/recovery/efficiency where content says so rather than requiring an unbounded stamina number.

Activities may consume stamina:
- travel;
- hunting;
- physical work;
- special training;
- other explicit content.

No every-action stamina drain unless that activity actually needs it.

## 4.3 Thương Thế
Injury is a list of named conditions with:
- severity;
- duration/recovery requirements;
- explicit modifier channels;
- optional body-part/context tags where useful later.

Do not use one permanent "injury stat".

Example:
a leg injury may reduce Movement Speed;
an arm/meridian injury may affect Attack/Cast/Work where content explicitly defines it.

An injury never lowers birth/current Lục Duy by silently rewriting them.

## 4.4 Tâm Trạng
One high-level mood state is sufficient for the base game.

Target representation:
- normalized 0–100;
- affected by events, relationships, environment, success/failure, relevant personality/traits;
- primarily influences AI preference/behavior and selected productivity/social outcomes.

Do not create dozens of hunger/thirst/recreation bars merely because other colony simulators do.

Specific survival/resources may exist at Sect/activity level without becoming one bar per disciple.

## 4.5 Trung Thành
One 0–100 relationship-to-sect state.

It is distinct from:
- Mị Lực;
- pairwise friendship/trust/respect;
- mood;
- personality.

Loyalty changes from events/policies/relationships/rewards/punishment.
It is not automatically `Mị Lực = loyalty`.

## 4.6 Age / lifespan
Persist:
- age/history;
- base lifespan;
- current max lifespan.

Long-term project rule remains:
lifespan expiry does not permanently delete the disciple; later Ma/Hồn/revival authority handles continuation.

---

# 5. Combat Stats V2 — DESIGN LOCKED

Canonical authority:
`docs/COMBAT_STATS_V2_SPEC.md`

Locked combat registry:
- Max HP / Attack / Defense;
- Movement Speed / Basic Attack Speed / Cast Speed / Cooldown Recovery;
- Crit Chance / Crit Damage / Crit Resistance;
- Defense Penetration;
- Effect Hit / Effect Resistance;
- Damage Reduction;
- keyed elemental-resistance map for Kim/Mộc/Thủy/Hỏa/Thổ + Lôi/Phong/Băng/Dương/U Minh.

Important exclusions:
- no one-size-fits-all Speed stat;
- no normal Accuracy/Dodge;
- no mandatory Crit-Damage-Reduction stat;
- no Physical/Magical Attack/Defense split;
- no universal Mana/Qi bar;
- no Combat Power authority.

Exact final Realm/Luyện Thể ATK/DEF/HP growth curves and Defense mitigation curve remain later implementation/balance work.

---

# 6. Advanced effect-modifier channels

Not every useful modifier should become a headline character stat.

The modifier authority must support effects such as:
- All Damage;
- direct-damage bonus;
- DoT potency;
- skill-effect magnitude;
- control/debuff duration;
- healing effect;
- shield effect;
- incoming damage;
- elemental damage/resistance;
- path-specific effect;
- skill-specific effect.

Use **filters/tags** rather than inventing one field per content item.

Example conceptual effect:

```
channel = "skill_effect"
mode = "percent_add"
value = 0.20
filters = {
  advanced_element = "lightning"
}
```

Another:

```
channel = "work_speed"
mode = "percent_add"
value = 0.10
filters = {
  profession = "forging"
}
```

A named Trait/Linh Căn/Huyết Mạch should be data that contributes to a channel or a genuine triggered mechanic.
Its name must not become a branch in every consumer.

---

# 7. Modifier modes

Every numeric effect should declare a mode.

## 7.1 Flat
Adds a real unit:
`+100 Max HP`.

## 7.2 Percent-add
Normal same-channel percentage bonus.

Default:
`final = base × (1 + sum(percent_add))`.

This is the same common-law direction already used by P3.7 progression channels.

## 7.3 Percentage points
Used for chance-like values when content explicitly says so.

Example:
`Crit Chance +5 percentage points`.

## 7.4 Special multiplier
Reserved for mechanics whose meaning is genuinely multiplicative/order-sensitive.

Examples:
- an explicit temporary incoming-damage multiplier;
- Phong Thế's one-cast cooldown rule;
- elemental counter multiplier.

Special multipliers must declare ordering.

## 7.5 Override / rule change
Rare.

Examples:
- one lethal hit is intercepted by U Minh;
- a skill becomes Lôi-tagged;
- a target is immune to one explicit status.

Do not model these as gigantic percentage bonuses.

---

# 8. Derived-stat pipeline

Default conceptual pipeline:

1. identify canonical base/source components;
2. apply valid flat additions;
3. collect normal same-channel percent-add modifiers;
4. apply explicit contextual/tag filters;
5. apply ordered special multipliers;
6. apply runtime condition effects;
7. apply semantic floor/ceiling only where the subsystem requires one;
8. expose final value + complete source breakdown.

For ATK/DEF/HP specifically:

```
RealmBodyCore
-> apply Tiềm Lực to RealmBodyCore
-> add equipment/fixed/permanent flat components
-> apply normal ATK/DEF/HP percentage channel modifiers
-> apply temporary/contextual modifiers
-> final derived stat
```

This prevents Tiềm Lực from retroactively multiplying a sword that simply says +100 Attack.

---

# 9. Contextual activity outputs

The framework does not create one "overall efficiency" number.

Each activity consumes only relevant inputs.

## 9.1 Natural cultivation

Input:
- base cultivation amount/time;
- Tư Chất;
- compatible Linh Căn cultivation modifiers;
- valid Trait/Bloodline/Physique/technique/facility modifiers;
- temporary cultivation state where later content explicitly uses it.

Output:
- Tu Vi/cultivation progress;
- path/technique progression where the owning systems define it.

Normal percentage contributions in the same cultivation-gain channel add on base.

Fixed-value pill:
`+10,000 Tu Vi`
still grants exactly 10,000 unless the item explicitly says it is scalable.

## 9.2 Luyện Thể

Input:
- base body-training XP;
- Căn Cốt;
- body-training modifiers;
- facility/content;
- Physique where applicable.

Output:
- body XP/progression;
- Realm+Body core combat growth.

Tiềm Lực changes the resulting long-term core ATK/DEF/HP growth quality, not the body-training XP speed itself.

## 9.3 Profession work

One work cycle conceptually consumes:
- assignment/facility;
- travel time when applicable -> Movement Speed;
- base work duration -> Profession Level + Work Speed modifiers;
- profession learning -> Thông Tuệ + profession talent + learning modifiers;
- task-specific resource/recipe inputs;
- stamina where that profession explicitly consumes it.

Output:
- resource/item/service result;
- profession XP;
- optional work Tu Vi while actively working;
- optional one meaningful Cơ Duyên check for rare outcomes;
- history/metrics/event hooks.

Do not use Cơ Duyên as a per-second production multiplier.

## 9.4 Technique / skill study

Input:
- base learning/mastery XP;
- Thông Tuệ;
- matching Linh Căn mastery;
- learning/technique-specific modifiers;
- teacher/facility/content later.

Output:
- technique/skill mastery XP;
- learned/unlocked state where requirements are met.

## 9.5 Combat

At encounter/action evaluation:
- obtain current derived combat stats;
- apply equipment/style;
- choose skill/basic action through AI;
- skill owns its effect definition;
- Linh Căn/Dị Căn/Huyết Mạch/Trait/etc. feed shared channels or explicit triggers;
- Crit uses Crit Chance/Crit Damage;
- status checks use Effect Hit/Resistance where applicable;
- elemental counter/resistance resolves in elemental authority;
- current HP/statuses/injury/runtime state update.

Output may include:
- HP change;
- status;
- encounter result;
- path XP;
- skill/mastery XP;
- injury;
- loot/reward;
- relationships/mood/history events.

Combat must never write permanent Lục Duy merely because damage was dealt.

## 9.6 Recovery

Input:
- current HP;
- stamina;
- injuries;
- recovery location/facility;
- explicit recovery modifiers from Physique/Bloodline/Trait/items.

Output:
- HP recovery;
- stamina recovery;
- injury recovery;
- mood/event consequences.

Recovery is stateful downtime, not a fake cooldown.

## 9.7 Social interaction

Input:
- action/context;
- Mị Lực;
- relationship state;
- target Social Resistance/context;
- Trait/personality/context modifiers.

Canonical base check:
`Social Score = RNG(0..9999) + Mị Lực - Social Resistance`
where that subsystem uses the common social check.

Output:
- affinity/trust/respect;
- loyalty where appropriate;
- recruitment/persuasion result;
- relationship event/history.

Mị Lực does not passively force affection.

## 9.8 Cơ Duyên event

A subsystem first decides that a meaningful uncertain outcome exists.

Then:
`Luck Score = RNG(0..9999) + Cơ Duyên - Difficulty`.

Output table belongs to that subsystem.

Do not roll Luck Score:
- every combat hit;
- every simulation tick;
- every crop tick.

---

# 10. One hypothetical disciple through a day

This is a consistency test, not final balance.

Assume a disciple has:
- Tư Chất 200;
- Căn Cốt 180;
- Cơ Duyên 400;
- Thông Tuệ 300;
- Mị Lực 120;
- Tiềm Lực 400;
- Hỏa Linh Căn purity 80;
- forging profession talent Grade 3;
- no relevant Trait yet.

## Morning — forging work

Travel:
- uses derived Movement Speed.

Forging action:
- base recipe duration;
- reduced by profession level and valid Work Speed effects.

Learning:
- Thông Tuệ 300 gives +45% learning XP;
- Grade 3 profession talent gives +15% profession XP;
- under open-point additive learning composition, a base 10 XP work event becomes 16 XP before other valid learning bonuses.

Rare result:
- forging does not continuously multiply output by Cơ Duyên;
- when one meaningful rare-quality/event check is called, Cơ Duyên enters the Luck Score once.

## Afternoon — cultivation

Tư Chất 200:
- +50% natural/base cultivation.

Hỏa purity 80 at normal Resonance:
- +24% matching-root cultivation.

If base natural cultivation for the interval is 100:
- same-channel normal bonuses produce 174 before other valid sources.

A pill saying +10,000 Tu Vi:
- still grants exactly 10,000.

## Later — Realm/Body growth

Tiềm Lực 400:
- future Realm+Body growth component gets +20%.

If an earned Realm+Body Attack component is 100:
- its core becomes 120 before unrelated fixed equipment is added.

A sword with +100 fixed Attack:
- contributes +100;
- it is not turned into +120 by Tiềm Lực.

## Hunt

Combat derives:
- Max HP/Attack/Defense;
- movement/basic attack/cast/cooldown values;
- crit/status/penetration/resistance values;
- elemental/root effects;
- equipment;
- runtime injury/buffs.

If the disciple suffers a leg injury:
- the injury may reduce Movement Speed;
- it does not permanently lower Căn Cốt or Tư Chất.

After returning:
- rest/treatment recovers HP, stamina and injury state;
- later relationship/mood systems may react to victory/defeat/injury.

This closes the loop without one subsystem rewriting another subsystem's truth.

---

# 11. What remains deliberately outside the canonical framework

Do not create these merely because other RPGs have them:

- generic Mana/MP/Combat Qi bar;
- normal Accuracy/Dodge;
- separate Crit-Damage-Reduction stat;
- Block stat;
- generic Carry Capacity;
- generic Perception radius;
- hunger/thirst/toilet/recreation meters;
- separate physical/magical Attack;
- separate physical/magical Defense.

Combat Stats V2 **does** canonically include Crit Resistance / Kháng Bạo Kích.
See `docs/COMBAT_STATS_V2_SPEC.md`.

Excluded systems may be added later only through an explicit design change with a concrete consumer and interaction model.

Guard, Shield, Dash, etc. remain skill/status mechanics unless later design proves they need a permanent stat channel.

---

# 12. UI information architecture target

Do not show every internal modifier on the first screen.

## Summary
- name / quality;
- realm;
- HP state;
- six Lục Duy;
- key Linh Căn;
- current role/work/action.

## Tu Tiên
- realm/Tu Vi;
- Luyện Thể;
- Linh Căn/Dị Căn;
- Bloodline;
- Physique;
- Mệnh Cách;
- techniques/paths.

## Combat
- Max HP / Attack / Defense;
- timing stats;
- crit/penetration/status stats;
- elemental resistances;
- equipment;
- skills.

## Nghề
- profession levels/XP;
- profession talents;
- work preferences;
- current assignment;
- contextual work-speed breakdown.

## Tâm Tính
- personality;
- visible Traits;
- mood;
- loyalty;
- personal goals/history highlights.

## Quan Hệ
- pairwise relationship data;
- companions/master-disciple/family/etc. when implemented.

Every derived visible number should offer a breakdown:
`base -> permanent sources -> equipment -> temporary state -> final`.

---

# 13. Large-roster performance rule

For 1,000–3,000 disciples:

Do not recompute the entire derived stat sheet every simulation tick.

Use event-driven invalidation or lazy calculation.

Recompute when a relevant source changes, for example:
- realm/body progression;
- equipment;
- root/trait/bloodline/physique change;
- temporary buff/status;
- injury;
- encounter start/action where fresh state is required.

Background work should consume only the channels needed by that work.

A farmer does not need a full Crit/Defense/Elemental-Resistance recomputation every work tick.

---

# 14. Required modifier provenance

Every derived channel must be debuggable.

The runtime target should be able to answer conceptually:

```
Attack = 1,842
  Realm+Body core     1,000
  Tiềm Lực +20%        +200
  Equipment flat       +500
  Trait percent +10%   +120
  Injury modifier       ×0.93
  Final                1,842
```

Numbers above are illustrative only.

This breakdown is required for:
- player trust;
- balance;
- tests;
- debugging;
- avoiding double application.

---

# 15. Ownership rules for future systems

## Trait
May:
- contribute to registered channels;
- add filters;
- alter AI/personality utility;
- add genuine trigger/rule-change mechanics.

May not:
- invent a duplicate hidden combat/work formula.

## Bloodline
May:
- contribute permanent growth/modifiers;
- unlock mechanics/content;
- provide triggered effects.

## Physique
May:
- alter body training, recovery, core physical channels and explicit mechanics.

## Mệnh Cách
May:
- break ordinary generation envelopes;
- create rare rule changes;
- alter event/content access.

Because it is rare, it may be exceptional, but it still must declare what authority it modifies.

## Equipment
Provides:
- explicit flat/percent/tagged modifiers;
- skill/style changes where defined.

It does not rewrite birth identity.

## Skills/Techniques
Own:
- action definition;
- hit/effect structure;
- ratios;
- cast time;
- cooldown;
- target rules;
- status definitions;
- special skill mechanics.

Character systems modify those through declared channels/tags rather than stealing ownership.

---

# 16. Test invariants required when implemented

1. same persistent sources derive the same final channels after save/load;
2. removing one equipment item removes exactly its contribution;
3. temporary injury never rewrites Lục Duy birth/current permanent values;
4. fixed-value consumables remain fixed unless explicitly scalable;
5. Tư Chất cannot multiply profession XP;
6. Thông Tuệ cannot directly add routine work output;
7. Cơ Duyên is not rolled per tick/hit;
8. Mị Lực does not directly set loyalty/affinity;
9. Tiềm Lực applies only to Realm+Body core growth component;
10. movement/attack/cast/cooldown/work speeds remain separate;
11. unknown modifier channels fail validation rather than silently doing nothing;
12. a named Trait does not require consumer-specific branches for normal numeric bonuses;
13. triggered rule changes cannot recursively proc themselves without explicit permission;
14. derived totals are reconstructible from source data;
15. large-roster background work does not require a full combat-stat recomputation;
16. UI/debug breakdown sum/order matches runtime result.

---

# 17. Proposed closure decisions for user review

This draft proposes to lock:

1. no giant single character-stat block;
2. persistent source -> runtime state -> derived channel -> contextual outcome architecture;
3. six Lục Duy remain the only general innate foundation stat block;
4. personality is decision authority, not a synonym for Trait;
5. Max HP / Attack / Defense are core derived combat stats;
6. movement / basic attack / cast / cooldown are separate;
7. Combat Stats V2 is already separately DESIGN LOCKED in `docs/COMBAT_STATS_V2_SPEC.md`;
12. effect modifiers use channels + filters/tags;
13. Stamina is a normalized runtime meter, not an unbounded growth stat;
14. injury is condition data, not one permanent stat;
15. Mood and Loyalty are separate runtime/social states;
16. contextual work/social/luck outputs are not persisted as fake universal stats;
17. no universal Mana, normal Accuracy/Dodge, separate Crit-Damage-Reduction, Block or physical/magical duplicate stat families without an explicit future design change;
18. derived stats are calculated/cached, not saved as a second authority;
19. every visible derived number must be explainable by source breakdown;
20. Trait V2 must be designed against this registry rather than inventing new stat families ad hoc.

Once the user accepts or modifies these decisions, this spec can become **DESIGN LOCKED** and Trait V2 can proceed on top of it.
