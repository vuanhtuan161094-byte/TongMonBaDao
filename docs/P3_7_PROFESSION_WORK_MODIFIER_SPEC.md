# P3.7 — SHARED PROFESSION / WORK MODIFIER SPEC

Status: CANONICAL DESIGN AUTHORITY  
Updated: 2026-10-06

Parents:
- `docs/GAME_SYSTEM_ARCHITECTURE.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`

This file owns the shared formulas used by all professions:
- Mining;
- Herbalism / Linh Thực;
- Alchemy;
- Forging;
- Logistics;
- later professions.

A profession-specific building may define its own outputs/events, but must not invent another foundation/trait formula.

---

# 1. Foundation values

All six foundation values are normalized to `0.0 ... 1.0`.

## Tư Chất — Aptitude

Primary role:
- cultivation absorption/progression.

No generic profession production bonus.

## Căn Cốt — Constitution

Primary work role:
- stamina/endurance.

Global work stamina formula:

**Stamina Cost = Base Stamina Cost × (1 − 0.25 × Căn Cốt)**

Range:
- Căn Cốt 0.00 -> 100% base stamina cost;
- Căn Cốt 0.50 -> 87.5%;
- Căn Cốt 1.00 -> 75%.

Căn Cốt does not directly increase material yield.

## Cơ Duyên — Fortune

Primary work role:
- profession-specific lucky/rare events.

Global rare-event formula:

**Actual Rare Chance = Base Rare Chance × (1 + 2 × Cơ Duyên)**

Range:
- Cơ Duyên 0.00 -> ×1.0 base chance;
- Cơ Duyên 0.50 -> ×2.0 base chance;
- Cơ Duyên 1.00 -> ×3.0 base chance.

Profession-specific content defines the base event chance.
Cap only where that event explicitly requires one.

Cơ Duyên does not provide a routine output multiplier.

## Thông Tuệ — Comprehension

Primary work role:
- profession learning speed.

Global profession-XP comprehension factor:

**Comprehension XP Factor = 0.75 + 0.50 × Thông Tuệ**

Range:
- 0.00 -> ×0.75;
- 0.50 -> ×1.00;
- 1.00 -> ×1.25.

## Mị Lực — Charisma

No generic production bonus.

Social/teaching/commerce professions may define an explicit use later.

## Tiềm Lực — Potential

No immediate work-speed or output multiplier.

Potential remains long-term character-growth identity unless a future shared progression system explicitly uses it.

---

# 2. Profession level

Canonical long-term profession range:
**Lv1–1000+**

Baseline efficiency rule remains:

**Profession Speed Factor = 1 + 0.01 × Profession Level**

Examples:
- Lv1 -> ×1.01;
- Lv10 -> ×1.10;
- Lv50 -> ×1.50;
- Lv100 -> ×2.00;
- Lv500 -> ×6.00;
- Lv1000 -> ×11.00.

Profession level improves throughput by reducing work/cycle time.
Do not also multiply the same output by the full profession factor; that would double-count mastery.

Profession milestones may add mechanics separately.

The current legacy Lv0–6 runtime must eventually migrate to this shared curve.
Individual buildings must not create private profession levels.

---

# 3. Graded trait magnitude

For shared graded work traits/talents:

| Grade | Modifier |
|---|---:|
| Nhất phẩm | 5% |
| Nhị phẩm | 10% |
| Tam phẩm | 15% |
| Tứ phẩm | 20% |
| Ngũ phẩm | 25% |

Helper:

**Grade Bonus = 0.05 × grade**, grade = 1..5.

This table is reused instead of hard-coding different arbitrary percentages everywhere.

---

# 4. Cần Mẫn

Cần Mẫn is a general work trait.

Effect:

**Work Speed × (1 + Grade Bonus)**

Examples:
- Nhất phẩm: +5%;
- Tam phẩm: +15%;
- Ngũ phẩm: +25%.

Cần Mẫn affects all ordinary professions unless a profession explicitly says the trait is irrelevant.

It does not also multiply output.

---

# 5. Cẩu Thả

Cẩu Thả is the general negative work trait.

Effect:

**Work Speed × (1 − Grade Bonus)**

Examples:
- Nhất phẩm: −5%;
- Tam phẩm: −15%;
- Ngũ phẩm: −25%.

Interpretation:
mistakes/rework consume more effective time.

Do not additionally subtract the same percentage from output unless a profession has a separate explicit failure mechanic.

---

# 6. Profession-specific talent

Examples:
- Khai Khoáng Thiên Phú;
- Linh Thực Thiên Phú;
- Luyện Khí Thiên Phú;
- Luyện Đan Thiên Phú.

Talent grade uses the shared 5/10/15/20/25 table.

Primary effect:

**Profession XP × (1 + Grade Bonus)**

Talent accelerates mastery.
Profession level then converts that mastery into real long-term throughput.

This avoids multiplying speed, yield and XP simultaneously from one trait.

---

# 7. Profession-talent occurrence

Starting generation targets:

Chance to receive one profession-specific talent:
- ordinary recruitment: 30%;
- gacha/high-quality recruitment: 40%;
- fate/special recruitment: 50%.

If a profession talent is rolled, choose one eligible profession talent from the current profession pool.

Talent-grade distribution, conditional on having a profession talent:

| Grade | Probability |
|---|---:|
| Nhất phẩm | 50% |
| Nhị phẩm | 30% |
| Tam phẩm | 13% |
| Tứ phẩm | 6% |
| Ngũ phẩm | 1% |

Total = 100%.

The profession pool expands as professions are implemented.

---

# 8. Total work-speed formula

For a normal profession cycle:

**Work Speed = Profession Speed Factor × General Trait Factor × Optional Content Affinity × Building/Facility Factor**

Where:
- Profession Speed Factor = `1 + 0.01 × profession level`;
- General Trait Factor = Cần Mẫn or Cẩu Thả modifier, otherwise 1.0;
- Optional Content Affinity defaults to 1.0;
- Building/Facility Factor comes from the relevant building/system.

Do not multiply Tư Chất, Cơ Duyên, Mị Lực and Tiềm Lực into generic work speed.

---

# 9. Profession XP formula

For one completed profession action/cycle:

**Profession XP = Base XP × Comprehension XP Factor × Profession Talent Factor**

Where:
- Comprehension XP Factor = `0.75 + 0.50 × Thông Tuệ`;
- Profession Talent Factor = `1 + grade bonus`, or 1.0 without talent.

Cần Mẫn/Cẩu Thả affect how quickly actions finish, not XP per completed action.

Therefore Cần Mẫn still gains XP faster over real time because it completes more actions.

---

# 10. Universal passive Tu Vi while working

Every living disciple passively absorbs cultivation while doing ordinary work.

Let:
- `R` = Tu Vi required to complete the disciple's current cultivation stage;
- `L` = level of the profession currently being performed.

Raw work absorption target:

**Raw Work Tu Vi / hour = R × 0.0005 × (1 + 0.0005 × L)**

Meaning:
- profession Lv0 -> 0.05% of current-stage requirement/hour before normal cultivation modifiers;
- Lv100 -> 0.0525%;
- Lv500 -> 0.0625%;
- Lv1000 -> 0.075%.

Then pass this raw gain through the existing cultivation-gain authority.

Therefore existing cultivation identity continues to matter naturally:
- Tư Chất;
- Spiritual Root;
- technique/path;
- relevant cultivation traits;
- Bloodline;
- Physique.

Do not create a second farming/mining-specific cultivation formula.

This keeps ordinary work much slower than focused cultivation and hunting.

---

# 11. Optional elemental/content affinity

No profession receives a universal Spiritual Root bonus.

A specific crop/recipe/resource may define compatible elements.

If the content explicitly has an affinity and the disciple has a matching Spiritual Root element:

**Content Work Speed ×1.05**

No mismatch penalty by default.

This +5% is intentionally small.

---

# 12. Bloodline / Physique

Current Bloodline and special Physique do not automatically buff professions.

A future Bloodline/Physique may define an explicit profession effect, but there is no universal hidden multiplier.

Căn Cốt's shared stamina rule still applies because it is a foundation stat.

---

# 13. Profession-specific lucky events

All professions may use the shared Fortune formula:

**Actual Chance = Base Chance × (1 + 2 × Cơ Duyên)**

Examples:
- Linh Điền: bội thu x2/x3/x4;
- Mỏ: rare vein / bonus material;
- Luyện Đan: extra pill / rare inspiration;
- Luyện Khí: exceptional by-product;
- Exploration: rare discovery.

The profession owns the event table.
The foundation formula remains shared.

---

# 14. Runtime migration rule

Current runtime has legacy:
- profession Lv0–6;
- ungraded profession talents;
- duplicate work-temperament traits in WorkforceSystem and TraitSystem.

Migration must move toward this canonical model without breaking existing saves.

Do not keep two permanent versions of Cần Mẫn/Cẩu Thả or profession talent.

---

# 15. Completion boundary

This shared profession system is not considered fully migrated until:
- graded profession talents exist;
- Cần Mẫn/Cẩu Thả use graded magnitude;
- profession level uses the long-term curve;
- passive work Tu Vi is shared across professions;
- legacy duplicate traits are migrated;
- all implemented professions use these shared formulas.

A profession-specific phase may temporarily bridge the legacy runtime, but must not create another competing formula.
