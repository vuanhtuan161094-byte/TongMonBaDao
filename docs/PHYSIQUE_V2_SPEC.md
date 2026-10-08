# PHYSIQUE V2 — THỂ CHẤT

Date: 2026-10-07
Status: **BASE DESIGN LOCKED — NOT IMPLEMENTED**

Parents:
- `docs/DISCIPLE_MASTER_SCHEMA.md`
- `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`
- `docs/COMBAT_STATS_V2_SPEC.md`
- `docs/SPIRITUAL_ROOT_V2_SPEC.md`
- `docs/BLOODLINE_V2_SPEC.md`
- `docs/REALM_LADDER_V2_SPEC.md`
- `docs/BODY_CULTIVATION_V2_SPEC.md`

Legacy runtime compatibility source:
- `godot/src/simulation/physique/physique_system.gd`

The old P2.12 design document has been removed.
This file is the sole design authority for future Thể Chất gameplay.
Legacy runtime remains only for regression/save migration until an explicit V2 implementation phase replaces it.

No gameplay implementation is authorized by this design lock.

---

# 1. Definition

**Luyện Thể** and **Thể Chất** are separate systems.

Luyện Thể answers:
> How far has the body been trained?

Thể Chất answers:
> What special structure/rule does this body have?

A disciple can reach any Luyện Thể realm with no special Thể Chất.

Thể Chất is not:
- a second body-level ladder;
- a rarity color;
- a purity meter;
- a replacement for Căn Cốt or Tiềm Lực;
- a second Luyện Thể XP bar.

---

# 2. Removed P2.12 authorities

Future Physique V2 has **no**:
- Phàm/Linh/Huyền/Thánh/Thần physique-grade roll;
- 0.85x/1.00x/1.20x/1.45x/1.80x grade scaler;
- `temper_level 0..5`;
- one-Yêu-Đan-per-temper progression;
- rule that every ordinary body has a pre-rolled `latent_transformation`;
- universal requirement that every physique must add Attack or Defense;
- generic `combat_power_bonus` authority;
- harsh root-mismatch penalty merely for owning the wrong root.

Luyện Thể V2 owns body progression.
Combat Stats V2 owns combat channels.

---

# 3. One active Core Physique

A disciple has at most **one active Core Physique**.

Valid current states:
- no special Physique;
- one base Physique;
- one evolved Physique;
- one fused Physique.

This differs from Bloodline V2, where several compatible lineages may coexist.

Old Physiques are not stacked underneath a new one.

Example:
`Hàn Âm Thể + Hỏa Linh Thể -> Thái Cực Âm Dương Thể`

If an authored Dung Thể recipe creates the result:
- Hàn Âm is no longer active;
- Hỏa Linh is not separately active;
- only Thái Cực Âm Dương Thể supplies current effects;
- the transformation history is preserved.

This prevents infinite passive stacking while still allowing one favorite disciple to be transformed repeatedly over a long save.

---

# 4. Congenital distribution

Ordinary congenital baseline:

| Result | Rate |
|---|---:|
| No special Physique | **97.00%** |
| Special Physique, revealed | **2.70%** |
| Special Physique, latent | **0.30%** |

Total congenital special Physique:
**3.00% ≈ 1 in 33 generated people.**

Rules:
- ordinary birth has at most one congenital special Physique;
- Physique is independent from Disciple Quality, six foundations, Root, Bloodline, Trait and Mệnh Cách;
- ordinary Dẫn Tiên quality manipulation does not silently improve Physique odds;
- special content may explicitly use a different Physique distribution;
- same seed/source/index must preserve the same congenital identity/reveal state;
- latent identity is fixed at birth and reveal never rerolls it;
- latent Physique has no gameplay effect until revealed.

---

# 5. Base-Physique type weights

When the ordinary 3% special roll succeeds, the starting base type uses these weights:

| Base Physique | Weight within special pool |
|---|---:|
| Kiếm Cốt | 12% |
| Kim Cương Bá Thể | 12% |
| Hàn Âm Thể | 10% |
| Hỏa Linh Thể | 10% |
| Sinh Cơ Linh Thể | 8% |
| Trường Sinh Thể | 8% |
| Tu La Chiến Thể | 8% |
| Huyết Sát Chi Thể | 7% |
| Ngũ Hành Đạo Thể | 6% |
| Vạn Độc Linh Thể | 5% |
| Huyền Nguyệt Linh Thể | 4% |
| Đấu Chiến Chi Thể | 3% |
| Không Linh Hư Thể | 3% |
| Vạn Pháp Đạo Thể | 2% |
| Vô Cấu Đạo Thể | 2% |

Total = 100%.

The same type-weight table applies to revealed vs latent congenital special rolls unless a future explicit source says otherwise.

---

# 6. No lore-only Physique rule

A Physique may not be enabled in gameplay merely because it has a name and flavor text.

Before an entry can be available through birth, reveal, Cải Thể, Tiến Hóa or Dung Thể, it must have:
1. at least one measurable gameplay effect;
2. all referenced channels/tags defined by canonical authority;
3. explicit composition semantics;
4. any proc/trigger attributed to an existing event pipeline;
5. no invented private universal stat or fake subsystem used only by that Physique.

A Physique is allowed to have only numeric effects if those effects create a real niche.
A custom proc is not mandatory.

Do not create one new `Ý/Ấn/Tức/Nhiệt/Khí` meter for every Physique.

---

# 7. Modifier semantics

Use canonical modifier modes:
- Percent-Add for ordinary % channels;
- Percentage-Points for Crit Chance / Effect Hit / Effect Resistance and similar probability-point channels;
- Special-Multiplier only where a rule explicitly says so.

Same-channel ordinary percentage bonuses add on base.

Physique effects carry source provenance.
Derived totals are not independent save truth.

Filtered channels may target:
- element;
- direct damage;
- basic attacks;
- DoT;
- control/debuff;
- expedition cost component;
- Body Core component;
- other tags that are already canonical.

---

# 8. Fifteen base Physiques

## 8.1 Kiếm Cốt — IDENTITY LOCKED, EFFECT STILL BLOCKED

Fantasy:
- a body/bone structure naturally suited to sword use.

**No numeric or combat effect is locked yet.**

Combat Skills V2 now closes the skill-side representation:
- `style_tag = sword` is a canonical skill-content direction;
- `weapon_requirement` is separate from style;
- cast/source/cast-id/hit-index attribution is part of the shared skill contract;
- AoE and multi-hit belong to one attributed cast;
- weaponless sword-style content is allowed when its definition explicitly has no sword weapon requirement.

Do NOT assume:
- a generic Sword Mastery stat exists;
- Đạo Lịch itself gives free combat stats;
- every sword-style skill requires a physical sword;
- +Attack/+Crit/+Penetration is automatically the correct Kiếm Cốt effect.

### Remaining blocking dependency — DEP-PHY-01-WEAPON

Weapon + Equipment V2 must still decide:
1. canonical `weapon_type` values;
2. what equipping a sword means;
3. how skill `weapon_requirement = sword` checks the loadout;
4. whether equipment can modify sword-style skills through explicit tags;
5. whether weapon-specific mastery exists at all.

**Activation gate:**
Kiếm Cốt must not be enabled as a revealed/usable gameplay Physique until:
- Weapon V2 closes the remaining dependency; and
- Kiếm Cốt receives at least one real measurable authored effect.

Its 12% roster weight is reserved design data, not permission to ship it effectless.

---

## 8.2 Kim Cương Bá Thể

Role:
- raw body durability and long expedition endurance.

Locked effects:
- **Body Core Max HP +15%**;
- **Body Core Defense +20%**;
- **Expedition Stamina consumption -10%** for ordinary map-consumption components.

Locked rule — **Kim Cương Hộ Thể**:
- for an eligible incoming direct hit;
- after ordinary Defense/element resolution identifies the hit magnitude but before final independent Damage-Reduction composition;
- if that hit would remove **<=8% Max HP**;
- apply a **×0.90 special incoming-damage multiplier** to that hit.

This is anti-chip durability.
It is not a shield and does not create a new resource.

---

## 8.3 Hàn Âm Thể

Role:
- Water/Ice effect specialization and cold-environment endurance.

Locked effects:
- **+12% Water/Ice Skill Effect**;
- **+10% Water/Ice Elemental Resistance**;
- **+15% Control/Debuff Duration** for eligible Water/Ice-sourced effects;
- **-20% cold-environment Expedition Stamina surcharge**, when a map explicitly defines that component.

Rules:
- no generic mismatch penalty if the disciple lacks Water/Ice Root;
- no automatic Freeze/Băng Phong is created by this Physique;
- Băng Dị Linh Căn keeps ownership of its Hàn Ấn/Băng Phong mechanic.

---

## 8.4 Hỏa Linh Thể

Role:
- Fire/Yang effect pressure and hot-environment endurance.

Locked effects:
- **+12% Fire/Yang Skill Effect**;
- **+10% Fire/Yang Elemental Resistance**;
- **+15% DoT Potency** for eligible Fire/Yang-owned DoTs;
- **-20% hot-environment Expedition Stamina surcharge**, when a map explicitly defines that component.

Rules:
- no generic mismatch penalty if the disciple lacks Fire/Yang Root;
- this Physique does not automatically create Burn;
- Dương Dị Linh Căn keeps ownership of Dương Bạo.

---

## 8.5 Sinh Cơ Linh Thể

Role:
- receiving healing and recovering from damage/injury.

Locked effects:
- **Max HP +10%**;
- **Healing Received +20%**.

Locked threshold rule:
- while current HP is **<=40% Max HP**;
- gain an additional **+15% Healing Received**.

Future Injury channel:
- **Injury recovery speed +25%** once canonical Injury treatment/recovery runtime exists.

The injury component is design-locked but consumer-gated.
The HP/healing effects remain real without it.

No revive.
No overheal shield.

---

## 8.6 Trường Sinh Thể

Role:
- long-life survivability rather than burst combat.

Locked current-combat effects:
- **Max HP +15%**;
- **Damage Reduction +3%**.

Locked long-life effects:
- **current Max Lifespan +50%**;
- **Injury recovery time -30%**.

Lifespan/Injury effects are consumer-gated until those runtime authorities exist.
They do not alter birth Lục Duy.

No revive and no immunity to lifespan rules.

---

## 8.7 Tu La Chiến Thể

Role:
- becomes more dangerous as its own HP falls.

No private rage/stack resource.

Locked rule based directly on current HP:

| Current HP | Direct Damage | Basic Attack Speed |
|---|---:|---:|
| >75% | +0% | +0% |
| >50% to 75% | +4% | +3% |
| >25% to 50% | +8% | +6% |
| <=25% | **+12%** | **+10%** |

The highest currently satisfied row applies.
Rows do not stack.

This uses existing current-HP, Direct Damage and Basic Attack Speed channels only.

---

## 8.8 Huyết Sát Chi Thể

Role:
- finishing weakened targets and sustaining through personal kills.

Locked conditional effects:
- against a target at **<=50% Max HP**: **Crit Chance +6 percentage points**;
- against a target at **<=30% Max HP**: additionally **Crit Damage +20%**.

Locked kill rule:
- an eligible **personal kill** restores **3% Max HP**;
- source-owned internal cooldown = **2 seconds**;
- summoned/secondary ownership must follow the shared kill-attribution pipeline.

This is target-low-HP specialization.
It is distinct from Tu La, which reads the owner's missing HP.

---

## 8.9 Ngũ Hành Đạo Thể

Role:
- broad five-base-element compatibility and matchup control.

Locked effects:
- **+8% Skill Effect** for Kim/Mộc/Thủy/Hỏa/Thổ skills;
- **+8% Elemental Resistance** to Kim/Mộc/Thủy/Hỏa/Thổ.

Locked five-element-counter rule:
- when this disciple has the favorable five-element matchup, multiply only the **counter bonus portion above 1.0** by **×1.15**;
- when this disciple suffers an unfavorable five-element matchup, multiply only the **extra counter penalty portion above 1.0** by **×0.75**.

Do not multiply total final damage by 1.15/0.75.
Only the canonical five-element matchup contribution is adjusted.

This Physique does not require owning all five Roots.

---

## 8.10 Vạn Độc Linh Thể

Role:
- DoT offense and DoT endurance.

Locked effects:
- **DoT Potency +20%**;
- **Effect Hit +6 percentage points** for eligible DoT/debuff applications;
- **incoming DoT damage -20%** through a filtered incoming-damage modifier.

No Poison-specific subtype is invented by this spec.
If a future status taxonomy adds Poison/Corrosion, later content may specialize further without changing this base authority.

No DoT contagion/transfer mechanic is created here.

---

## 8.11 Huyền Nguyệt Linh Thể

Role:
- status/control specialist.

Locked effects:
- **Effect Hit +10 percentage points**;
- **Effect Resistance +10 percentage points**;
- **Control/Debuff Duration +15%** for effects owned by this disciple.

No new `Nguyệt Ấn` resource.
No private control formula.

Control success must use the canonical future Effect Hit/Resistance resolution.

---

## 8.12 Đấu Chiến Chi Thể

Role:
- basic-attack specialist.

Locked effects:
- **Basic Attack Damage +15%**;
- **Basic Attack Speed +10%**;
- **Defense Penetration +8%** for basic attacks only;
- **Crit Resistance +8 percentage points**.

No `Martial/Body skill` tag is assumed.
No path/mastery system is required for this base version.

---

## 8.13 Không Linh Hư Thể

Role:
- mobility, casting mobility and efficient travel.

Locked effects:
- **Movement Speed +12%**;
- **Cast Speed +8%**;
- **Travel-component Expedition Stamina consumption -20%**.

Travel-component reduction:
- applies only when the map runtime identifies the cost as travel/movement;
- does not reduce combat, hunting, gathering or harsh-environment stamina by default.

No Dodge stat is created.

---

## 8.14 Vạn Pháp Đạo Thể

Role:
- broad skill throughput without specializing in one element.

Locked effects:
- **Skill Effect +10%** for eligible skills;
- **Cast Speed +8%**;
- **Cooldown Recovery +8%**.

It does not enhance basic attacks unless a skill explicitly owns that effect.
It does not create a skill-echo mechanic before Skills V2 defines such an event.

Vạn Pháp is a combat-skill generalist.
It is not the transformation/adaptation Physique; that role belongs to Vô Cấu.

---

## 8.15 Vô Cấu Đạo Thể

Role:
- adaptation and long-term body reconstruction.

Locked combat effects:
- **all elemental resistances +5%** for the ten canonical element keys;
- **Effect Resistance +5 percentage points**.

Locked transformation effect:
- **-20% common-material quantity** for authored Cải Thể / Tiến Hóa / Dung Thể recipes;
- round final common-material quantities upward;
- unique/key materials are never reduced;
- a recipe may explicitly opt out if its identity depends on an exact sacrifice.

Locked map effect:
- **environmental-mismatch Expedition Stamina surcharge -15%** when the map runtime explicitly defines such a surcharge;
- does not reduce base travel/combat/hunting cost.

Vô Cấu is deliberately flexible, not best-in-slot for every combat specialization.

---

# 9. Dependency / design-debt registry

## DEP-PHY-01 — Weapon + skill-tag authority
Status: **MISSING DESIGN — BLOCKS KIẾM CỐT EFFECT**

Must define:
- weapon types;
- sword identity/tag;
- skill-to-weapon attribution;
- whether weapon mastery exists;
- cast/hit/crit ownership semantics.

Owner:
future Techniques / Skills / Weapon V2.

## DEP-PHY-02 — Skill/combat tag runtime
Status: **DESIGN DIRECTION EXISTS — RUNTIME MISSING**

Needed by:
- Hàn Âm;
- Hỏa Linh;
- Ngũ Hành;
- Vạn Pháp;
- filtered effect channels generally.

Existing design precedent:
Spiritual Root V2 already requires element-tagged skill ownership.
Do not create a Physique-private implementation.

## DEP-PHY-03 — Status/DoT resolution runtime
Status: **CHANNEL AUTHORITY EXISTS — RUNTIME MISSING**

Needed by:
- Hàn Âm;
- Hỏa Linh;
- Vạn Độc;
- Huyền Nguyệt.

Must consume canonical:
- Effect Hit;
- Effect Resistance;
- DoT Potency;
- Control/Debuff Duration.

## DEP-PHY-04 — Injury + Lifespan runtime
Status: **SCHEMA/DIRECTION EXISTS — FULL RUNTIME MISSING**

Needed for full effect set of:
- Sinh Cơ;
- Trường Sinh.

Do not block their already-defined HP/healing/DR effects.

## DEP-PHY-05 — Expedition cost-component tags
Status: **BODY V2 AUTHORITY EXISTS — MAP RUNTIME MISSING**

Needed for:
- Hàn Âm cold surcharge;
- Hỏa Linh hot surcharge;
- Không Linh travel component;
- Vô Cấu environmental mismatch.

Must remain expedition-only.
Never route these modifiers into sect production.

## DEP-PHY-06 — Physique recipe/resource authority
Status: **ARCHITECTURE LOCKED — EXACT RECIPES OPEN**

Needed by:
- Cải Thể;
- Tiến Hóa;
- Dung Thể;
- Vô Cấu transformation-cost reduction.

Exact item IDs/quantities must not be invented until content/resource sources exist.

---

# 10. Cải Thể

Post-birth creation is deterministic.

A disciple with no special Physique may eventually acquire an unlocked base Physique through an authored recipe.

Rules:
- player selects the intended result;
- no random target;
- no generic failure roll;
- insufficient conditions/resources -> action does not start and consumes nothing;
- exact recipe defines Luyện Thể requirement, materials and any thematic prerequisite;
- blocked content such as Kiếm Cốt cannot be selected until its dependency is closed.

The old P2.12 rule that every ordinary body secretly owns one `latent_transformation` target is removed.

---

# 11. Tái Tạo Thể

A disciple is not permanently bricked by one old body choice.

An authored, expensive deterministic action may replace the current Core Physique with another eligible base/evolved body.

Rules:
- old effects stop;
- new effects become active;
- no silent resource refund;
- history is preserved;
- unique advanced bodies may define stricter replacement rules.

Exact costs are future content.

---

# 12. Tiến Hóa

Tiến Hóa upgrades/rebuilds the current Core Physique into an authored successor.

Rules:
- not `Physique Lv2/Lv3`;
- successor has its own identity/effects;
- predecessor stops being an active effect source;
- no passive stacking of base + evolved + final body;
- branch choices are allowed;
- not every base Physique is required to have the same number of branches;
- evolution requires explicit body threshold + resources + content condition;
- success is deterministic once requirements are met.

Nhân/Tiên/Thần macro stages are natural content bands for evolution requirements, but there is no universal automatic evolution simply for entering a new world tier.

---

# 13. Dung Thể

Dung Thể creates one new Core Physique from an authored combination.

Rules:
- only explicit recipes exist;
- no generic A+B random blender;
- result replaces current active Physique;
- ingredients/history do not remain as separately active passive sources;
- Dung Thể must create a coherent result rather than merely summing every effect of A+B;
- one recipe may require current Physique A plus a B-specific Thể Nguyên/material rather than requiring two simultaneously active Physiques;
- prior body history may be used as an explicit prerequisite/discount if a recipe says so.

This architecture is locked.
The exact V1 fusion roster is future content design.

---

# 14. Physique history

Persist immutable/append-only transformation provenance sufficient to answer:
- congenital or acquired;
- original congenital identity if any;
- reveal event/time;
- Cải Thể events;
- Tái Tạo events;
- Tiến Hóa events;
- Dung Thể events;
- predecessor/result IDs.

History:
- does not grant passive stats merely for existing;
- may satisfy authored future recipe prerequisites;
- must not be deleted when the active body changes.

---

# 15. Reveal of latent Physique

Latent identity exists at birth.

Reveal must be:
- deterministic;
- based on meaningful lived history/content;
- retroactive for significant history where technically possible;
- never a reroll.

Exact per-Physique reveal triggers remain content data and must be defined before that latent type is enabled.

A revealed Physique must immediately have a real gameplay consequence.
Do not reveal lore-only entries.

---

# 16. Relationship to Luyện Thể

Physique does not replace Luyện Thể.

Luyện Thể:
- 30 realms × 10 floors;
- Body Core growth;
- expedition endurance baseline.

Physique may:
- modify Body Core;
- modify combat channels;
- modify explicit expedition components;
- define requirements for Cải/Tiến/Dung recipes.

There is no universal formula such as:
`physique_effect × body_floor / 300`.

An evolved Physique may explicitly use a Luyện Thể threshold, but the base 15 effects above remain their defined effects unless a successor replaces them.

---

# 17. Relationship to Roots/Bloodlines

Root:
- elemental affinity/progression and root-specific mechanics.

Bloodline:
- lineage/purity/awakening and potentially several compatible active lineages.

Physique:
- one current body structure.

All may contribute to the same canonical channel.
Normal same-channel percent-add contributions add on base.

Physique must not steal a named mechanic owned by another subsystem.

Examples:
- Hàn Âm does not create Băng Dị Căn's Hàn Ấn;
- Hỏa Linh does not create Dương Bạo;
- Sinh Cơ does not copy Phượng Hoàng Niết Bàn;
- Kim Cương does not copy Huyền Vũ's large-hit shield rule.

---

# 18. Recruitment and quality

Physique does not change Disciple Quality.

Disciple Quality remains derived only from current permanent six-foundation total.

A low-quality recruit may have a rare/high-value Physique.
A high-quality recruit may have none.

Dẫn Tiên quality odds and Physique odds are separate authorities.

---

# 19. Inheritance

Inheritance architecture is reserved for Family/Dao Companion V2.

Persist enough provenance to distinguish:
- congenital Physique;
- revealed congenital Physique;
- acquired/rebuilt Physique;
- evolved/fused body history.

Do not lock parent-child probability formulas here.

---

# 20. Legacy P2.12 migration direction

P2.12 remains live compatibility until a tested V2 migration phase.

Future migration must:
1. preserve an existing special `physique_id` when it maps to a V2 identity;
2. remove V2 authority from `physique_grade`, `temper_level` and ordinary `latent_transformation`;
3. not silently discard player investment represented by old grade/temper;
4. convert old grade/temper into deterministic compensation such as Luyện Thể progress and/or explicit resources using a migration table locked in that implementation phase;
5. preserve an old ordinary-body `latent_transformation` as a legacy one-time transformation entitlement/discount rather than silently deleting the player's prior seeded route;
6. preserve same character ID and save determinism;
7. never extend legacy P2.12 mechanics for new content.

Exact compensation quantities remain future implementation/balance work.

---

# 21. Implementation invariants

A future Physique V2 implementation must prove at minimum:

1. no physique grade/purity/temper V2 authority exists;
2. ordinary congenital distribution = 97.00/2.70/0.30;
3. special-type weights sum to 100%;
4. same seed/source/index preserves congenital Physique identity/reveal state;
5. latent reveal does not reroll;
6. at most one Core Physique is active;
7. blocked/effectless content cannot be enabled;
8. Kiếm Cốt remains disabled until DEP-PHY-01 is closed;
9. each enabled base Physique has measurable effects matching this spec;
10. no private `combat_power_bonus` authority;
11. no production consumer reads expedition-only Physique modifiers;
12. same-channel stacking uses canonical modifier semantics;
13. Cải Thể is deterministic and player-selected;
14. Tiến Hóa replaces rather than stacks predecessor effects;
15. Dung Thể creates one result and does not keep A+B active;
16. history persists without granting passive stats by itself;
17. old P2.12 saves migrate deterministically with no silent loss of investment;
18. candidate accept/reject and save/load preserve canonical V2 profile state;
19. earlier cumulative gates remain green.

---

# 22. Current lock boundary

**Locked now:**
- core architecture;
- one-active-Core rule;
- no grade/purity/temper;
- 3% congenital model;
- 15 base identities and weights;
- effects for the 14 currently designable bases;
- Kiếm Cốt identity + explicit blocker;
- Cải/Tái Tạo/Tiến Hóa/Dung Thể architecture;
- history/provenance;
- dependency registry;
- migration direction.

**Still open:**
- Kiếm Cốt actual effects after DEP-PHY-01;
- exact Cải/Tiến/Dung resource recipes;
- exact per-Physique latent reveal triggers;
- exact advanced evolution branches;
- exact Dung Thể V1 result roster;
- visual names/icons/VFX;
- runtime implementation.

No implementation phase is active.
