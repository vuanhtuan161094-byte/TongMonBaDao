# COMBAT STATS V2 — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-07
Status: **DESIGN LOCKED — NOT IMPLEMENTED**

Parents:
- `docs/GAME_SYSTEM_ARCHITECTURE.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`
- `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`
- `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`
- `docs/SPIRITUAL_ROOT_V2_SPEC.md`
- `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`

This spec locks the **Combat Stat registry, meanings, ownership and composition rules**.

It does not yet lock:
- final Realm/Luyện Thể ATK/DEF/HP growth tables;
- the exact Defense-to-mitigation curve;
- equipment affix distributions;
- monster stat curves;
- encounter balance.

Those belong to later implementation/balance work and must consume this registry.

No gameplay implementation is authorized by this design lock.

---

# 1. Reference conclusion

The project borrows useful structure but does not copy another game's stat sheet.

## Ta Làm Tông Sư Trong Tiên Môn / 最强祖师

Useful lessons:
- core combat value is visibly built from Attack / Defense / HP;
- equipment/build choices meaningfully use Crit, Crit Damage, Effect Hit and Effect Resistance;
- defensive builds may use anti-crit and damage-reduction style attributes;
- character power also depends on techniques, destiny/traits, roots, equipment and lineup rather than one number.

Not copied:
- one turn-order Speed stat;
- physical/magical damage-reduction split;
- separate anti-crit chance + crit-damage-reduction as two mandatory core stats.

Reason:
this project uses realtime combat, five-element/advanced-element identity and explicit attack/cast/cooldown timing.

## 鬼谷八荒 / Tale of Immortal

Useful lessons:
- Attack, Defense, movement, Crit and a Crit counter form a coherent small combat core;
- damage-type resistance belongs separately from Defense.

Not copied:
- universal combat mana/spiritual resource;
- physical-technique vs root-resistance split as the main damage taxonomy.

## 了不起的修仙模拟器 / Amazing Cultivation Simulator

Useful lesson:
- special combat resources such as artifact Qi/shield strength can create depth when the whole combat model is designed around them.

Project decision:
- do not add Mana/Qi/Shield Strength as universal disciple stats before a real skill/resource system requires them.

---

# 2. Final canonical Combat Stat registry

## 2.1 Core combat

1. **Max HP — Sinh Mệnh Tối Đa**
   - internal target: `max_hp`
   - derived;
   - controls the current HP ceiling.

2. **Attack — Công Kích**
   - internal target: `attack`
   - derived;
   - common offensive magnitude input for direct attacks and skill formulas.

3. **Defense — Phòng Ngự**
   - internal target: `defense`
   - derived;
   - common defensive input for normal damage mitigation.

These three are the primary long-term combat-growth outputs of Realm + Luyện Thể.

Tiềm Lực modifies the canonical Realm+Body core growth component before unrelated equipment/fixed additions.

---

## 2.2 Realtime timing

4. **Movement Speed — Tốc Độ Di Chuyển**
   - internal target: `move_speed`
   - controls physical movement;
   - also naturally matters to travel/hauling where world/work authority consumes movement.

5. **Basic Attack Speed — Tốc Đánh Thường**
   - internal target: `attack_speed`
   - controls ordinary attack frequency only.

6. **Cast Speed — Tốc Độ Thi Pháp**
   - internal target: `cast_speed`
   - controls skill cast-time only.

7. **Cooldown Recovery — Tốc Độ Hồi Chiêu**
   - internal target: `cooldown_recovery`
   - controls ordinary skill cooldown frequency.

There is **no generic Speed stat**.

A turn-order Speed stat from turn-based references must not be introduced into this realtime model.

---

## 2.3 Critical

8. **Crit Chance — Tỷ Lệ Bạo Kích**
   - internal target: `crit_chance`
   - chance for eligible direct damage to critically strike.

9. **Crit Damage — Sát Thương Bạo Kích**
   - internal target: `crit_damage`
   - extra damage multiplier when a critical hit occurs.

10. **Crit Resistance — Kháng Bạo Kích**
   - internal target: `crit_resistance`
   - reduces the attacker's effective Crit Chance against this target.

There is **no separate mandatory Crit-Damage-Reduction stat** in V2.

Reason:
Crit Resistance supplies a clear counter-build while Defense and general Damage Reduction already defend against the damage that still crits.

A later unique skill/trait may explicitly reduce critical damage as a special modifier without creating a second universal crit-defense stat.

---

## 2.4 Defense interaction

11. **Defense Penetration — Xuyên Phòng**
   - internal target: `defense_penetration`
   - percentage of the target's remaining Defense ignored by this attacker.

V2 starts with one percentage penetration channel.
There is no second Flat Penetration stat.

Target Defense-reduction debuffs are **status effects**, not this attacker stat.

Canonical order:
1. resolve target Defense buffs/debuffs;
2. obtain remaining target Defense;
3. apply attacker Defense Penetration to the remaining value;
4. pass effective Defense into the Defense mitigation formula.

Defense may not become negative through ordinary reduction/penetration.
Explicit vulnerability mechanics may add damage through their own channel instead.

---

## 2.5 Status application

12. **Effect Hit — Chính Xác Hiệu Ứng**
   - internal target: `effect_hit`

13. **Effect Resistance — Kháng Hiệu Ứng**
   - internal target: `effect_resistance`

These govern debuff/control application **only when the effect definition says a hit/resistance check is required**.

They are not ordinary attack Accuracy/Dodge.

Direct attacks do not randomly miss by default.

A skill may explicitly declare:
- guaranteed status;
- status immune target rule;
- special independent application formula.

---

## 2.6 General incoming damage

14. **Damage Reduction — Giảm Sát Thương**
   - internal target: `damage_reduction`
   - reduces eligible incoming damage after normal offensive/Defense/element resolution.

Damage Reduction is distinct from Defense.

Independent normal Damage-Reduction sources compose on remaining damage rather than naively adding until 100%.

This preserves the existing locked direction used by U Minh and future defensive systems.

---

## 2.7 Elemental resistance map

15. **Elemental Resistance — Kháng Nguyên Tố / Dị Hệ**
   - internal target: one keyed map/channel, not ten hardcoded character fields.

Canonical keys:

Base:
- `metal`
- `wood`
- `water`
- `fire`
- `earth`

Advanced:
- `lightning`
- `wind`
- `ice`
- `yang`
- `nether`

Display:
- Kháng Kim;
- Kháng Mộc;
- Kháng Thủy;
- Kháng Hỏa;
- Kháng Thổ;
- Kháng Lôi;
- Kháng Phong;
- Kháng Băng;
- Kháng Dương;
- Kháng U Minh.

Only non-zero/relevant resistances need normal UI display.

Five-element counter is a separate matchup multiplier owned by Spiritual Root V2.
Resistance is not the same system.

---

# 3. Starting semantic constants

These are starting balance constants and may later be benchmark-tuned without changing the registry.

## 3.1 Critical baseline

Ordinary character starting baseline:
- Crit Chance: **5%**
- Crit Damage: **+50%**, meaning a normal critical hit deals **1.50×** the eligible direct damage before later incoming defensive layers.
- Crit Resistance: **0 percentage points** unless a source grants it.

Lôi mutation contributions plug directly into these channels.

Example:
Lôi Viên Mãn contributes:
- Crit Chance +15 percentage points;
- Crit Damage +50%.

With no other source:
- 5% -> 20% Crit Chance;
- 1.50× -> 2.00× critical damage.

This is intentionally powerful but still leaves equipment/traits/content room to specialize further.

## 3.2 Effect baseline

Ordinary:
- Effect Hit = 0 percentage points;
- Effect Resistance = 0 percentage points.

The skill/status definition owns its base application chance.

## 3.3 Penetration / reduction / elemental resistance baseline

Ordinary:
- Defense Penetration = 0%;
- Damage Reduction = 0%;
- elemental resistances = 0% before Root/Traits/Bloodline/Physique/equipment/content.

---

# 4. Canonical realtime speed formulas

Use rate-style bonuses rather than subtracting percentages directly from time.

This avoids cooldown/cast/attack intervals collapsing toward zero when a disciple is heavily invested.

## 4.1 Basic attack

`effective_basic_interval = base_basic_interval / (1 + attack_speed_bonus)`

Example:
+100% Attack Speed:
- attacks occur at 2× the base frequency;
- interval is half.

## 4.2 Cast speed

`effective_cast_time = base_cast_time / (1 + cast_speed_bonus)`

Example:
+50% Cast Speed:
- a 1.5s cast becomes 1.0s.

## 4.3 Cooldown recovery

`ordinary_effective_cooldown = base_cooldown / (1 + cooldown_recovery)`

Example:
+100% Cooldown Recovery:
- a 10s ordinary cooldown becomes 5s.

This is not the same as "100% cooldown reduction = zero cooldown".

## 4.4 Phong Thế ordering

Locked Dị-Căn rule remains:

1. resolve the skill's ordinary cooldown through Cooldown Recovery and normal eligible modifiers;
2. Phong Thế applies its special one-cast reduction to that resolved cooldown.

Therefore Phong Thế remains a special mechanic, not just another line of Cooldown Recovery.

## 4.5 Movement

Default:
`effective_move_speed = base_move_speed × (1 + movement_speed_bonus)`

Temporary slow/haste and injury effects enter explicit runtime modifier layers.

Technical simulation may enforce a tiny positive minimum to prevent zero/negative movement, but this is not a character-growth ceiling.

---

# 5. Critical resolution

By default, eligible direct-damage hits may crit.

## 5.1 Effective chance

`effective_crit_chance = clamp(attacker_crit_chance - target_crit_resistance, 0%, 100%)`

Both Crit Chance and Crit Resistance are displayed as percentage points.

Example:
- attacker 40% Crit;
- target 15% Crit Resistance;
- effective chance = 25%.

## 5.2 Crit damage

`critical_raw_damage = eligible_raw_damage × crit_damage_multiplier`

Starting multiplier = 1.50×.

## 5.3 What cannot crit by default

Unless content explicitly opts in:
- DoT ticks;
- reflected damage;
- mutation-proc damage such as Thiên Lôi;
- fixed damage;
- healing;
- shielding.

This prevents accidental proc/crit recursion and keeps DoT/Dị-Căn identities controllable.

A future skill may explicitly declare `can_crit = true` for one of these categories.

---

# 6. Status hit / resistance resolution

Starting V2 formula for an ordinary status check:

`final_status_chance = clamp(base_status_chance + EffectHit - EffectResistance, 0%, 100%)`

Example:
- skill base Freeze chance 60%;
- caster Effect Hit +25 pp;
- target Effect Resistance +15 pp;
- final chance = 70%.

This is intentionally readable.

A guaranteed effect may declare:
`guaranteed = true`

and skip the ordinary hit/resistance roll unless the target has an explicit immunity/rule override.

Băng's locked Effect Hit bonuses use this authority.

---

# 7. Defense / penetration semantics

The exact Defense mitigation curve is **deferred**.

Reason:
ATK/DEF/HP growth tables from Realm + Luyện Thể are not yet finalized, so locking a numeric Defense curve before those scales exist would be premature.

What is locked now:

- Attack is the common offensive magnitude source;
- Defense is the common ordinary mitigation source;
- target Defense buffs/debuffs resolve before attacker penetration;
- Defense Penetration ignores a percentage of the remaining Defense;
- ordinary effective Defense cannot fall below zero;
- the final Defense curve must be monotonic and must never produce healing/negative damage;
- it must remain stable across very large Realm/Luyện Thể values;
- it may not force introduction of Physical Attack / Magical Attack / Physical Defense / Magical Defense parallel stat blocks.

Kim Root's existing percentage penetration contribution plugs here.

---

# 8. Damage Reduction composition

General Damage Reduction is not Defense.

Each independent source reduces the remaining eligible damage.

Conceptually:

`remaining_damage *= (1 - source_reduction)`

for each independent source in canonical source order.

Example:
- one source gives 20%;
- another gives 10%.

Total:
`damage × 0.80 × 0.90 = damage × 0.72`

Effective reduction = 28%, not 30%.

This prevents ordinary stacking from reaching or exceeding 100% merely by addition.

A true immunity is a separate explicit rule/effect.

U Minh's temporary Minh Hộ incoming-damage multiplier remains a special encounter mechanic and composes in the incoming-damage authority.

---

# 9. Elemental resistance composition

Elemental resistance uses the same "reduce remaining damage" principle for independent resistance sources.

Example:
- Fire Root-derived resistance source = 30%;
- equipment Fire resistance source = 20%.

Combined incoming Fire multiplier:
`0.70 × 0.80 = 0.56`

Displayed effective Fire Resistance may therefore show:
**44%**.

This has several advantages:
- no ordinary additive path to 100% immunity;
- a source that says +30% resistance really reduces the remaining matching damage by 30%;
- very large investment remains useful;
- true immunity remains a special mechanic.

Root-generated resistance and mutation-generated resistance are derived source contributions, not independently persisted totals.

---

# 10. Specialized combat-effect channels — canonical, but not headline stats

The following are canonical modifier channels but are not required as always-visible primary Combat Stats:

- **All Damage**;
- **Direct Damage**;
- **Basic Attack Damage**;
- **DoT Potency**;
- **Skill Effect**;
- **Healing Done / Hiệu Quả Trị Liệu**;
- **Healing Received / Hiệu Quả Nhận Trị Liệu**;
- **Shield Effect / Hiệu Quả Hộ Thuẫn**;
- **Control/Debuff Duration**;
- element-specific damage/effect;
- path-specific damage/effect;
- skill-specific magnitude.

They are real combat authority.
They are simply shown contextually rather than cluttering every disciple's primary stat panel.

Example:
Hỏa Root's "All Damage" goes into outgoing damage modifiers.

Dương's DoT Potency goes into the DoT modifier channel.

Băng's control-duration contribution goes into control/debuff-duration modifiers.

A healing skill owns its base heal amount.
The healer's Healing Done channel modifies that outgoing heal.
The target's Healing Received channel then modifies the amount actually received.

Starting semantic order:
`final_heal = base_heal × outgoing_heal_factor × receiving_heal_factor`

Within each side, ordinary percent-add modifiers add on that side's base factor.

Example:
- base heal = 5,000;
- healer Healing Done +60% -> 8,000;
- target Healing Received +25% and one anti-heal effect -50% -> receiving factor = 1 + 0.25 - 0.50 = 0.75;
- final received heal = 6,000.

A receiving factor cannot go below zero through ordinary arithmetic.
A true "cannot be healed" state is an explicit rule override, not -1000% hidden arithmetic.

Shielding is separate:
`final_created_shield = base_shield × shield_effect_factor`

Healing Done does not increase shields.
Shield Effect does not increase healing.

HP regeneration, Stamina recovery and Injury recovery are contextual recovery channels owned by their respective systems; they are not silently folded into Healing Done.

These specialized channels should appear in detailed breakdown/filter UI when relevant, not clutter the first combat panel with dozens of always-visible lines.

---

# 11. Action properties that are NOT character Combat Stats

These belong to skill/weapon/action definitions:

- skill range;
- basic attack range;
- projectile speed;
- projectile count;
- hit count;
- AoE radius;
- dash distance;
- summon count;
- skill cast time before character Cast-Speed modification;
- base skill cooldown before character Cooldown-Recovery modification;
- skill base status chance;
- skill damage ratio.

Do not store these as permanent disciple stats merely because equipment/content may modify them.

Use tagged modifiers when modification is required.

---

# 12. Things intentionally NOT in Combat Stats V2

## 12.1 No normal Accuracy / Dodge

Direct attacks hit when their realtime target/geometry/action resolution succeeds.

Reason:
- realtime movement already supplies spatial avoidance;
- random miss on top of positioning reduces readability;
- Effect Hit/Resistance already owns status application.

A skill may explicitly grant:
- evasion;
- untargetability;
- invulnerability;
- miss chance;

as a special status/mechanic.

If many future systems genuinely need generic Dodge, it can be promoted later through an explicit design change.

## 12.2 No second Crit-Damage-Reduction stat

Crit Resistance already counters crit frequency.
General Damage Reduction / Defense protects against damage that still lands.

## 12.3 No Physical/Magical Attack or Defense split

Damage identity is built from:
- action/skill;
- Kiếm/Thể/Pháp path;
- base element;
- advanced element;
- explicit tags.

Do not force every ability into a physical-vs-magical duplicate stat system.

## 12.4 No universal Mana/Qi combat bar

Current combat is governed by:
- action choice;
- cast time;
- cooldown;
- skill rules.

A future technique/resource system may add an explicit resource if it has a closed gameplay loop.

Do not create one speculatively.

## 12.5 No universal Block / Lifesteal / Reflect / Threat stat

These remain explicit mechanics/channels until enough content proves they deserve a general stat.

## 12.6 No Combat Power as authority

"Combat Rating / Lực Chiến" may exist only as a derived UI estimate.

It:
- is not rolled at birth;
- is not a damage formula input;
- does not replace actual stats;
- should not be the sole condition for content correctness.

---

# 13. Interaction with Spiritual Root V2

Locked root contributions map cleanly:

| Root/Dị source | Combat Stats V2 consumer |
|---|---|
| Kim | Defense Penetration |
| Mộc | Max HP % |
| Thủy | Attack Speed + Cast Speed |
| Hỏa | All Damage modifier |
| Thổ | Defense % |
| matching Root resistance | Elemental Resistance map |
| Lôi | Crit Chance + Crit Damage + Thiên Lôi mechanic |
| Phong | Movement Speed + Cast Speed + Phong Thế mechanic |
| Băng | Effect Hit + control duration + Hàn Ấn mechanic |
| Dương | All Damage + DoT Potency + Dương Bạo mechanic |
| U Minh | Effect Resistance + Damage Reduction + Minh Mệnh mechanic |

No Root/Dị layer needs to invent a private parallel combat stat.

---

# 14. Interaction with future Trait / Bloodline / Physique / equipment

All normal numeric bonuses must use this registry or a registered modifier channel.

Examples:

Trait:
- +10 pp Crit Resistance;
- +12% Attack;
- +8% forging work speed — not a combat stat.

Bloodline:
- +15% Max HP;
- +10% Effect Resistance;
- triggered heal below 30% HP.

Physique:
- +20% Defense;
- +15% recovery;
- explicit body-training mechanics.

Equipment:
- +500 Attack;
- +10% Defense;
- +5 pp Crit Chance;
- +12% Fire Resistance source;
- +8% Movement Speed.

A named content item does not receive custom consumer branches for an ordinary numeric modifier.

---

# 15. Interaction with combat AI

AI must reason from skills/state, not from Combat Rating alone.

Examples:
- high Crit does not make a support skill bad if healing is needed;
- target with high Effect Resistance lowers expected utility of debuff skills;
- Băng target at two Hàn Ấn increases utility of the next eligible Băng skill;
- Phong Thế active increases value of a high-cooldown follow-up;
- U Minh already consumed changes survival evaluation;
- low HP/injury may increase retreat or defensive-skill utility.

Stat registry supplies facts.
AI utility owns decisions.

---

# 16. Large-roster runtime

For 1,000–3,000 disciples:

- permanent sources remain saved;
- derived combat stats are cached/lazily calculated;
- invalidate only when a relevant source changes;
- combat-local temporary modifiers/timers exist only for participants;
- background workers do not recompute full combat sheets every tick.

Events that may invalidate combat-derived cache:
- Realm/Luyện Thể change;
- Tiềm Lực change;
- Root/Dị change;
- Trait/Bloodline/Physique change;
- equipment change;
- persistent injury change;
- long-lived permanent buff/debuff source change.

Encounter-only states need not invalidate non-combat global caches.

---

# 17. UI target

Primary Combat panel should show:

## Chính
- Sinh Mệnh;
- Công Kích;
- Phòng Ngự.

## Tốc độ
- Di Chuyển;
- Đánh Thường;
- Thi Pháp;
- Hồi Chiêu.

## Bạo kích
- Bạo Kích;
- Sát Thương Bạo Kích;
- Kháng Bạo Kích.

## Phá / hiệu ứng
- Xuyên Phòng;
- Chính Xác Hiệu Ứng;
- Kháng Hiệu Ứng;
- Giảm Sát Thương.

## Kháng hệ
Only non-zero/relevant element resistances by default, expandable to all.

Detailed secondary page/breakdown may show:
- All Damage;
- DoT Potency;
- Skill Effect;
- Healing Done / Hiệu Quả Trị Liệu;
- Healing Received / Hiệu Quả Nhận Trị Liệu;
- Shield Effect / Hiệu Quả Hộ Thuẫn;
- control-duration modifiers;
- skill/path/element effect bonuses;
- source-by-source contributions.

---

# 18. Required implementation invariants

When Combat Stats V2 is implemented, tests must prove at minimum:

1. same persistent sources derive the same stats after save/load;
2. Max HP ratio is preserved when permanent Max HP changes unless an effect explicitly heals/damages;
3. Tiềm Lực multiplies Realm+Body core ATK/DEF/HP growth but not fixed equipment;
4. Movement / Attack / Cast / Cooldown remain separate;
5. +100% Attack Speed doubles ordinary attack frequency rather than reducing interval to zero;
6. +100% Cooldown Recovery halves ordinary cooldown rather than making it zero;
7. Phong Thế applies after ordinary cooldown recovery;
8. Crit Resistance subtracts Crit Chance percentage points;
9. Crit Chance clamps naturally to 0–100%;
10. DoT/reflection/mutation-proc damage does not crit unless explicitly opted in;
11. Effect Hit/Resistance only resolves statuses that require a check;
12. guaranteed statuses bypass normal hit/resist unless explicit immunity says otherwise;
13. Defense debuff resolves before Defense Penetration;
14. ordinary effective Defense cannot become negative;
15. independent Damage Reduction sources reduce remaining damage, not sum to ordinary immunity;
16. independent elemental-resistance sources reduce remaining matching damage;
17. elemental matchup remains separate from elemental resistance;
18. no standard Accuracy/Dodge roll is injected into ordinary direct attacks;
19. Combat Rating never becomes damage/stat authority;
20. unknown stat/modifier channel fails validation rather than silently doing nothing;
21. Healing Done modifies outgoing heal magnitude and does not modify shields;
22. Healing Received modifies the amount the target receives and is the canonical ordinary anti-heal channel;
23. Shield Effect modifies created shield magnitude and does not modify healing;
24. HP regeneration / Stamina recovery / Injury recovery are not silently treated as Healing Done.

---

# 19. Locked conclusion

Combat Stats V2 canonical registry is:

**Core**
- Max HP
- Attack
- Defense

**Realtime timing**
- Movement Speed
- Basic Attack Speed
- Cast Speed
- Cooldown Recovery

**Critical**
- Crit Chance
- Crit Damage
- Crit Resistance

**Defense interaction**
- Defense Penetration

**Status**
- Effect Hit
- Effect Resistance

**Incoming defense**
- Damage Reduction

**Elemental**
- keyed Elemental Resistance map for five base + five advanced elements

**Canonical specialized combat-effect channels**
- Healing Done
- Healing Received
- Shield Effect
- All Damage / Direct Damage / Basic Attack Damage
- DoT Potency
- Skill Effect
- Control/Debuff Duration
- element/path/skill-filtered effect channels

Everything else is either:
- another registered source/modifier channel;
- an action/skill property;
- a runtime status;
- a special triggered mechanic;
- or deferred until it has a real consumer.

This registry is **DESIGN LOCKED**.
Implementation remains future work.
