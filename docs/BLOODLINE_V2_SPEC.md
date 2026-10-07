# HUYẾT MẠCH V2 — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-07
Status: **DESIGN LOCKED — NOT IMPLEMENTED**

Parents:
- `docs/GAME_SYSTEM_ARCHITECTURE.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`
- `docs/DISCIPLE_V2_DESIGN_LEDGER.md`
- `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`
- `docs/COMBAT_STATS_V2_SPEC.md`
- `docs/SPIRITUAL_ROOT_V2_SPEC.md`
- `docs/TRAITS_V2_SPEC.md`
- `docs/DESTINY_V2_SPEC.md`

Legacy compatibility source:
- `docs/P2_11_BLOODLINE_SPEC.md`
- `godot/src/simulation/bloodline/bloodline_system.gd`

This document supersedes P2.11 as the design authority for future Huyết Mạch gameplay.
P2.11 remains compatibility-only until a tested V2 migration replaces its runtime.

No gameplay implementation is authorized by this design lock.

---

# 1. Core identity

Huyết Mạch is inherited ancestral power carried by a person.

It is separate from:
- Lục Duy;
- Linh Căn / Dị Linh Căn;
- Trait;
- Mệnh Cách;
- Thể Chất;
- learned techniques/professions;
- temporary buffs.

Canonical fantasy:

**Huyết Mạch = lineage identity + purity + awakening + ancestral mechanics + inheritance/transformation potential.**

Huyết Mạch must not become:
- a second Disciple Quality;
- a universal rarity color;
- a private Combat Power field;
- a generic bundle where every lineage gives Attack + Defense + HP + cultivation at once.

Each lineage must have a readable build identity.

---

# 2. Whole-person generation

Huyết Mạch is generated as part of the same deterministic person.

Same:
`world seed + recruitment source + generation index`

must preserve the same hidden bloodline identity and birth purity.

Reveal/awakening never rerolls:
- lineage ID;
- birth purity;
- origin;
- hidden identity.

Dẫn Tiên quality, Disciple Quality, Lục Duy total, Spiritual Root, Trait and Mệnh Cách do not silently alter ordinary Bloodline odds.

A future explicitly bloodline-focused event/building/banner may bias Bloodline generation only if its content definition says so.

---

# 3. Ordinary congenital rate

Ordinary whole-person generation:

| Result | Rate |
|---|---:|
| No special Bloodline | **98.00%** |
| One congenital latent Bloodline | **1.60%** |
| One congenital already-revealed Bloodline | **0.40%** |

Total congenital special Bloodline:
**2.00% = about 1 / 50 generated people**.

Ordinary birth has at most one special congenital Bloodline.

Special named/story/event characters may explicitly break this birth rule.

This makes Bloodline:
- rarer than ordinary Traits;
- more common than congenital Mệnh Cách at 0.50%;
- much more common than congenital Dị Linh Căn at 0.20%.

Birth rate is intentionally not the final ceiling because Bloodlines can also be acquired post-birth.

---

# 4. Multiple Bloodlines after birth

A person may eventually own multiple compatible Bloodlines.

There is:
- no universal lifetime hard cap;
- no generic "three Bloodline slots";
- no rule that birth Bloodline is the only Bloodline forever.

Ordinary birth still starts with at most one special congenital Bloodline.

Long-term control comes from:
- exponentially increasing Blood-Grant cost;
- explicit pair conflicts;
- explicit fusion recipes;
- rare acquisition resources;
- strong build identity rather than every lineage buffing every axis.

This preserves the favorite-disciple fantasy without making "collect every lineage" a cheap mandatory optimization.

Same Bloodline ID cannot duplicate-stack on one person.

---

# 5. Purity

Every owned Bloodline has its own integer:

**Purity = 1..100**

There is no 0.00..0.95 V2 purity model.

For a congenital Bloodline, starting purity is generated deterministically:

`P = clamp(round(100 × U²), 1, 100)`

where `U` is that Bloodline's deterministic seeded random value in `0..1`.

This produces:
- many low/mid-purity births;
- a long rare high-purity tail;
- possible natural 100 without making it common.

Persist:
- immutable birth purity for congenital Bloodlines;
- current purity for gameplay.

Post-birth granted Bloodlines have no congenital birth purity; their origin record stores the acquisition event and starting purity instead.

---

# 6. State model

Per Bloodline:

- **Tiềm Ẩn** — identity exists, hidden, inactive.
- **Hiển Lộ** — identity and purity are known, still inactive.
- **Thức Tỉnh** — active; numeric contributions and mechanics apply.
- **Phong Ấn** — known but inactive due to an explicit conflict/content rule.
- **Đã Dung Hợp / Đã Thay Thế** — no longer active; history remains.

There is no universal multi-stage Bloodline realm ladder.

Two important milestones are derived from current purity:

- **Chân Huyết**: awakened and purity >= 50.
- **Phản Tổ**: awakened and purity == 100.

These are derived milestones, not separate mutable truth.

---

# 7. Effect architecture

Bloodline effects must consume the canonical character/stat framework.

Allowed effect forms:
- registered flat/percent-add/percentage-point modifiers;
- contextual recovery channels;
- filtered combat modifiers;
- explicit triggered mechanics;
- explicit rule changes.

Do not create:
- `combat_power_bonus` authority;
- Bloodline-private Attack/Defense copies;
- duplicate speed/crit/effect-hit systems.

Normal same-channel percentage bonuses follow the shared additive law:
`final = base × (1 + sum(percent_add))`.

Special multipliers and rule changes must declare timing/order.

---

# 8. Five initial Bloodlines

The five P2.11 identities are retained as the first V2 content set but redesigned to fit canonical channels.

The numeric coefficients below are starting V2 balance constants.
They are part of the design lock but may later be benchmark-tuned without changing the identity/mechanic contract.

Let `P` be current purity from 1..100.

## 8.1 Chân Long Huyết — all-round authority

Identity:
stable offense + defense + breakthrough power.

Awakened numeric contributions:
- Attack: `+0.18% × P`;
- Defense: `+0.18% × P`;
- Max HP: `+0.10% × P`;
- natural cultivation gain: `+0.10% × P`;
- breakthrough chance: `+0.03 percentage points × P`.

At P=100:
- +18% Attack;
- +18% Defense;
- +10% Max HP;
- +10% natural cultivation;
- +3 percentage points breakthrough chance.

### Chân Huyết >=50 — Long Uy

- while current HP >=50% Max HP: +10% outgoing damage;
- while current HP <50% Max HP: +10% Damage Reduction contribution.

The state switches deterministically from current HP ratio.
It is not a temporary proc.

### Phản Tổ 100 — Nghịch Lân

Once per encounter:
- the first time current HP crosses below 30% Max HP;
- gain for 10 seconds:
  - +25% Attack;
  - +25% Defense;
  - +20% Movement Speed.

A single damage event may trigger Nghịch Lân at most once.

---

## 8.2 Phượng Hoàng Huyết — life, healing, rebirth

Identity:
recovery, shields and survival.

Awakened numeric contributions:
- Max HP: `+0.10% × P`;
- Healing Done: `+0.20% × P`;
- Healing Received: `+0.20% × P`;
- HP/Stamina recovery: `+0.30% × P`;
- natural cultivation gain: `+0.06% × P`.

At P=100:
- +10% Max HP;
- +20% Healing Done;
- +20% Healing Received;
- +30% HP/Stamina recovery;
- +6% natural cultivation.

Phượng Hoàng does not receive generic Attack merely because it is rare.

### Chân Huyết >=50 — Phượng Viêm

When eligible healing would exceed Max HP:
- 50% of the overheal becomes a shield;
- shield cap from this mechanic = 10% Max HP;
- duration = 8 seconds.

Shield magnitude uses canonical Shield Effect where applicable.
Overheal conversion cannot recursively trigger itself.

### Phản Tổ 100 — Niết Bàn

Once per encounter:
- when an eligible lethal event would defeat the owner;
- intercept defeat through the future canonical lethal-interception pipeline;
- after the rebirth delay, restore 35% Max HP;
- remove ordinary control effects allowed by the control authority.

Niết Bàn must not implement a private death system.

If multiple lethal-interception effects exist, Combat V2 owns deterministic priority/consumption order.

---

## 8.3 Bạch Hổ Huyết — slaughter and critical pressure

Identity:
pure offensive pressure.

Awakened numeric contributions:
- Attack: `+0.25% × P`;
- Crit Chance: `+0.08 percentage points × P`;
- Crit Damage: `+0.15% × P`;
- Defense Penetration: `+0.08% × P`.

At P=100:
- +25% Attack;
- +8 percentage points Crit Chance;
- +15% Crit Damage;
- +8% Defense Penetration.

Bạch Hổ does not receive cultivation/recovery bonuses by default.

### Chân Huyết >=50 — Sát Khí

On a qualifying kill personally attributed to the owner:
- gain one Sát Khí stack for 10 seconds;
- each stack:
  - +6% Basic Attack Speed;
  - +6% Movement Speed;
- maximum 3 stacks.

Stack gain has a short source-level internal cooldown so one AoE event cannot generate arbitrary stacks from many simultaneous deaths.

### Phản Tổ 100 — Bạch Hổ Sát

On an eligible direct critical hit:
- place at most one Hổ Sát Ấn per caster-target-cast;
- at 3 marks:
  - consume all 3;
  - deal Bloodline proc damage equal to 80% Attack.

The proc:
- cannot crit by default;
- cannot place another Hổ Sát Ấn;
- cannot recursively trigger itself;
- follows ordinary damage ownership/attribution rules.

Bosses are valid targets unless content explicitly grants immunity.

---

## 8.4 Huyền Vũ Huyết — immovable defense

Identity:
HP, Defense, mitigation and control resistance.

Awakened numeric contributions:
- Defense: `+0.25% × P`;
- Max HP: `+0.20% × P`;
- Damage Reduction: `+0.05% × P`;
- Effect Resistance: `+0.08 percentage points × P`.

At P=100:
- +25% Defense;
- +20% Max HP;
- +5% Damage Reduction;
- +8 percentage points Effect Resistance.

Damage Reduction uses the canonical remaining-damage composition rule rather than naive additive stacking to immunity.

Huyền Vũ does not receive generic Attack by default.

### Chân Huyết >=50 — Huyền Giáp

If one eligible damage event removes at least 15% of Max HP:
- create a shield equal to 10% Max HP;
- duration = 6 seconds;
- internal cooldown = 10 seconds.

Multi-hit skills evaluate per resolved hit unless the final Combat V2 skill definition declares the sequence as one bundled damage event.

### Phản Tổ 100 — Bất Diệt Huyền Giáp

Once per encounter:
- first time current HP crosses below 30% Max HP:
  - gain shield = 30% Max HP;
  - remove one eligible current hard-control effect;
  - gain +20 percentage points Effect Resistance for 5 seconds.

Control removal uses the future canonical control taxonomy.

---

## 8.5 Thao Thiết Tàn Huyết — devour and sustain

Identity:
long-hunt sustain by consumption and killing.

Awakened numeric contributions:
- Attack: `+0.18% × P`;
- Max HP: `+0.15% × P`;
- Healing Received: `+0.15% × P`;
- Stamina recovery: `+0.25% × P`.

At P=100:
- +18% Attack;
- +15% Max HP;
- +15% Healing Received;
- +25% Stamina recovery.

Persistent tradeoff:
- when departing for an activity that consumes expedition Supply, consume +1 additional Supply.

The tradeoff is real economy state, not flavor text.

### Chân Huyết >=50 — Thôn Phệ

On a qualifying personal kill:
- restore 3% Max HP;
- restore 5% normalized Thể Lực;
- internal cooldown = 2 seconds.

Summon/DoT attribution follows canonical source ownership.
One kill cannot be credited to multiple owners for this mechanic.

### Phản Tổ 100 — Thực Thiên

Heal the owner for 5% of eligible direct damage personally dealt.

Excluded by default:
- DoT;
- reflected damage;
- fixed damage;
- Bloodline proc damage;
- secondary proc chains.

The healing is subject to a Max-HP-based per-second cap defined by Combat V2 implementation balance so large AoE target counts cannot instantly refill the owner.

This is an explicit triggered sustain mechanic, not a new universal Life Steal stat.

---

# 9. Reveal

Reveal means discovering a Bloodline that already existed.

Reveal never changes:
- lineage ID;
- purity;
- origin;
- compatibility;
- hidden seed identity.

Initial significant-history hooks:

- **Chân Long**: first qualifying victory against a substantially stronger enemy or major breakthrough.
- **Phượng Hoàng**: survive a qualifying near-death state or recover from a major injury.
- **Bạch Hổ**: qualifying major combat victory / real kill streak.
- **Huyền Vũ**: survive a qualifying high-damage encounter/event.
- **Thao Thiết**: meaningful consumption/absorption of high-tier beast/core material or major hunt event.

Exact thresholds are content data.

## 9.1 Significant-history retroactivity

Reveal must support retroactive history.

If a qualifying event happened before:
- appraisal;
- migration;
- feature activation;

the disciple must not be forced to repeat an impossible or artificial event.

Historical metrics/event records may satisfy reveal deterministically.

Do not use trivial counters such as "rest three times" as the final V2 identity test.

---

# 10. Awakening

A revealed Bloodline is inactive until awakened.

Starting generic awakening recipe:
- 8 Huyết Tinh;
- 1 Yêu Đan.

Awakening:
- is deterministic;
- cannot fail;
- does not reroll purity;
- consumes canonical Sect Warehouse resources;
- activates the Bloodline's purity-scaled contributions.

A specific lineage may later declare additional requirements, but ordinary V2 content must not invent a hidden fail chance.

---

# 11. Refinement

After awakening, refinement targets one specific Bloodline.

Each successful refinement:
- increases purity by exactly +1;
- cannot fail;
- cannot exceed 100.

No diminishing return in gained purity.

Cost rises with current purity:

| Current purity | Huyết Tinh per +1 |
|---:|---:|
| 1–24 | 1 |
| 25–49 | 2 |
| 50–74 | 4 |
| 75–89 | 8 |
| 90–94 | 16 |
| 95–98 | 32 |
| 99 -> 100 | 64 + 1 Tổ Huyết |

Tiềm Lực does not increase purity gain.
Tiềm Lực already owns Realm + Luyện Thể core growth quality and must not become a universal refinement stat.

---

# 12. Bloodline resources

Canonical V2 resource concepts:

## Huyết Tinh
Ordinary Bloodline awakening/refinement material.

## Tổ Huyết
Rare high-tier ancestral material used for:
- 99 -> 100;
- Blood-Grant;
- major fusion/transformation recipes.

## Huyết Nguyên [lineage]
Lineage-specific identity material.

Examples:
- Chân Long Huyết Nguyên;
- Phượng Hoàng Huyết Nguyên.

It is used to grant that specific Bloodline post-birth.

These are resource/content definitions, not separate currencies.

Implementation rule:
no exposed consumer may ship before at least one real acquisition loop exists for every required resource.

Intended sources:
- matching elite/boss hunting;
- secret realms;
- first-clear rewards;
- rare deterministic repeat sources;
- later auction/market/event content where explicit.

---

# 13. Ban Huyết — post-birth Bloodline grant

A person without a given Bloodline may acquire it later.

Required:
- correct lineage-specific Huyết Nguyên;
- Huyết Tinh;
- Tổ Huyết;
- no unresolved explicit conflict.

The new Bloodline:
- starts at purity 10;
- starts Hiển Lộ;
- is not yet awakened;
- records acquisition origin/history.

Starting generic cost curve by current number of owned active special Bloodlines:

| Existing -> after grant | Huyết Tinh | Tổ Huyết |
|---|---:|---:|
| 0 -> 1 | 128 | 1 |
| 1 -> 2 | 256 | 2 |
| 2 -> 3 | 512 | 4 |
| 3 -> 4 | 1,024 | 8 |

For further grants, the intended generic direction continues doubling unless the later content definition overrides with a stricter explicit recipe.

There is no lifetime hard cap.

This exponential cost is a progression/economy brake, not a hidden final stat ceiling.

---

# 14. Compatibility and conflict

Default relation between different Bloodlines:
**compatible**.

A pair is conflicting only when content explicitly declares it.

Each lineage definition may expose:
- `conflicts_with`;
- `compatible_with` where special clarification is useful;
- `fusion_recipes`.

Do not infer conflict merely from mythology such as "two sacred beasts should fight".

If two owned Bloodlines become incompatible through transformation:
- the operation must fail safely before resource consumption; or
- an explicit seal/replace/fusion recipe must resolve it.

No silent deletion.

---

# 15. Dung Huyết — fusion

Fusion exists only through an explicit recipe.

A generic random command:
"combine two Bloodlines and roll a new one"
does not exist.

A fusion recipe declares:
- source lineage IDs;
- required purity/awakening/state;
- resources;
- event/realm prerequisites;
- result lineage ID;
- result starting/current purity rule;
- whether sources are consumed, sealed or retained;
- migration/history record.

When source Bloodlines are consumed:
- mark them as `consumed_by_fusion` / historical;
- their old active effects stop;
- the result lineage becomes the new active source.

Fusion cannot duplicate-stack source effects unless the recipe explicitly says they are retained.

---

# 16. Hoán Huyết — replacement

Hoán Huyết is the deliberate removal/replacement route for:
- explicit conflicts;
- build reshaping;
- rare story transformations.

The original congenital identity remains in immutable history.

A replaced Bloodline:
- no longer contributes active effects;
- is not rerolled;
- cannot be erased from historical provenance.

There is no generic free Bloodline reroll.

---

# 17. Inheritance contract — formula deferred to Family V2

Bloodline is inheritable.

This V2 lock reserves the following architecture:
- each parental lineage is considered deterministically;
- higher parental purity should generally improve inheritance strength/chance;
- multiple compatible lineages may be inherited;
- conflicting lineages require explicit resolution;
- the child's result is fixed at birth and never rerolled;
- origin records which parent/ancestral source transmitted the lineage.

However, **the exact parent-child probability and purity formula is intentionally deferred** until Family / Dao Companion / reproduction design is locked.

Do not copy a formula from another game now.

Bloodline V2 must persist enough provenance for Family V2 to implement inheritance later without rewriting identity.

---

# 18. Future Huyết Mạch Khai Tổ hook

Reserved future direction:

An extraordinary long-lived disciple may eventually create a new lineage from their own:
- achievements;
- cultivation path;
- techniques;
- physique;
- major history.

Concept:
**Huyết Mạch Khai Tổ / Dị Biến lineage.**

Example fantasy:
a legendary sword cultivator may become the ancestor of a future sword-oriented Bloodline.

This is NOT part of V2 implementation scope.

Architecture only reserves:
- lineage definitions are data-driven;
- origin can be `founder_created`;
- lineage ID need not be restricted to the five initial Bloodlines;
- future descendants can reference the founder lineage.

Do not fabricate runtime founder-generation before its own design phase.

---

# 19. AI / combat / proc safety

Bloodline triggers follow common V2 ownership rules.

Required:
- source attribution is stable;
- one cast cannot create unlimited same-mechanic procs;
- secondary Bloodline proc damage does not recursively retrigger Bloodline proc chains by default;
- AoE/multi-hit behavior is explicitly defined per mechanic;
- boss immunity is never assumed unless content declares it;
- kill credit is deterministic;
- lethal interception uses one shared pipeline;
- shields use canonical shield state/effect channels;
- HP/Stamina recovery uses living-state authority.

Large-roster off-screen simulation may use equivalent deterministic aggregate resolution, but it must preserve the same gameplay outcomes required by the Bloodline contract.

---

# 20. Persistence target

Future V2 state should conceptually persist per person:

`bloodline_model_version = 2`

`bloodlines = [ ... ]`

Each owned Bloodline record needs at least:
- `bloodline_id`;
- `origin_type`;
- `origin_source`;
- `birth_purity` when congenital;
- `current_purity`;
- `revealed`;
- `awakened`;
- `sealed`;
- acquisition/reveal/awakening/fusion/replacement history references.

Derived data is not independent save truth:
- Chân Huyết;
- Phản Tổ;
- numeric modifier values;
- active stat totals.

Those are recomputed from canonical source state.

---

# 21. Migration from P2.11

Legacy P2.11 currently has:
- one `bloodline_id`;
- float `purity`;
- revealed/awakened flags;
- refinement count;
- source-biased 18% / 28% / 42% special rates;
- purity cap 0.95;
- Yêu Đan refinement with diminishing gain and old Potential influence;
- private `combat_power_bonus` and old direct consumers.

V2 migration must preserve existing people rather than reroll them.

Required migration direction:
- legacy `none` remains no Bloodline;
- legacy special lineage ID maps to the same V2 lineage;
- legacy purity converts deterministically to integer 1..100;
- revealed/awakened state is preserved where valid;
- origin marks `legacy_p2_11`;
- old `refinement_count` may remain history but is not V2 purity authority;
- no existing character loses a legacy special Bloodline merely because V2 ordinary birth rate is lower.

After V2 migration:
- old source-specific 18/28/42 generation is retired;
- old 0.95 cap is retired;
- old diminishing purity gain is retired;
- old Potential/Tiềm Lực refinement influence is retired;
- old `combat_power_bonus` is retired;
- old P2.11 runtime remains only as compatibility/migration code until tests prove it can be removed.

---

# 22. Required future implementation tests

A Bloodline V2 implementation phase must prove at minimum:

1. same seed/source/index -> exact same congenital Bloodline identity and purity;
2. ordinary congenital rate uses the locked 98/1.6/0.4 table;
3. Dẫn Tiên quality does not silently modify Bloodline odds;
4. hidden reveal never rerolls identity/purity;
5. significant-history retroactivity works;
6. unrevealed/unawakened Bloodline is inactive;
7. awakening consumes exact canonical resources;
8. refinement is deterministic +1 purity and cannot fail;
9. purity 50 derives Chân Huyết;
10. purity 100 derives Phản Tổ;
11. every initial lineage contributes only through canonical channels/mechanics;
12. no V2 `combat_power_bonus` authority exists;
13. Ban Huyết creates the selected lineage at purity 10 and preserves history;
14. grant cost scales by current owned Bloodline count;
15. no universal lifetime Bloodline cap is introduced;
16. conflict resolution is explicit and atomic;
17. fusion cannot duplicate source effects accidentally;
18. replacement preserves birth/history provenance;
19. kill/proc/AoE rules cannot recurse infinitely;
20. lethal interception integrates with shared combat authority;
21. exact save/load and deterministic continuation;
22. legacy P2.11 profiles migrate without reroll/loss;
23. locked earlier cumulative gates remain green.

---

# 23. Explicit non-goals

Bloodline V2 design lock does not implement:
- runtime code;
- UI;
- final acquisition drop tables;
- Family/Dao Companion reproduction;
- exact inheritance probability formula;
- founder-created Bloodline generation;
- final Combat V2 lethal-interception ordering;
- final Defense curve;
- Physique/Luyện Thể V2.

Those systems must consume this authority later rather than creating a parallel Bloodline model.
