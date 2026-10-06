# P3.7 — SHARED PROFESSION / WORK MODIFIER SPEC

Status: CANONICAL DESIGN AUTHORITY  
Updated: 2026-10-06

Parents:
- `docs/GAME_SYSTEM_ARCHITECTURE.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`

This file owns the small shared formula set used by all professions.

---

# 1. Core rule

**Lục duy describes the person. Profession level describes how good that person is at a profession.**

Do not force every foundation stat into every profession.

Normal percentage effects from:
- Đặc Chất;
- Huyết Mạch;
- Thể Chất;
- equipment;
- buffs;
- future content

must use generic modifier channels whenever they are only numeric modifiers.

Current generic channels:
- `work_speed`;
- `profession_xp`;
- `cultivation_gain`;
- `body_training_gain`;
- `rare_chance`;
- `social_effect`.

A new content name must not require a new gameplay branch merely to add or subtract a percentage.

Special code is reserved for effects that genuinely change a rule.

---

# 2. One common lục-duy curve

Foundation values remain normalized internally to `0.0 ... 1.0`.

Common factor:

**Foundation Factor = 0.75 + 0.50 × value**

Equivalent UI examples on a 0–100 display:
- 20 -> ×0.85;
- 40 -> ×0.95;
- 50 -> ×1.00;
- 70 -> ×1.10;
- 90 -> ×1.20;
- 100 -> ×1.25.

Exact future minimum generation value is balance data. The intended direction is that characters should not be made useless by a zero-value design.

Canonical roles:
- **Tư Chất** -> `cultivation_gain`;
- **Căn Cốt** -> `body_training_gain`;
- **Cơ Duyên** -> `rare_chance`;
- **Thông Tuệ** -> `profession_xp` and skill/mastery learning;
- **Mị Lực** -> `social_effect`;
- **Tiềm Lực** -> long-term permanent growth authority when implemented.

Căn Cốt does **not** generically reduce profession stamina cost or increase hauling.
Tư Chất does **not** generically increase production.
Mị Lực and Tiềm Lực do **not** generically increase routine production.

---

# 3. Profession level

P3.7 long-term profession level is derived from accumulated profession XP:

**Level = floor(sqrt(XP / 24))**

Profession throughput:

**Profession Speed Factor = 1 + 0.01 × Level**

Examples:
- Lv0 -> ×1.00;
- Lv10 -> ×1.10;
- Lv50 -> ×1.50;
- Lv100 -> ×2.00;
- Lv500 -> ×6.00;
- Lv1000 -> ×11.00.

Profession level improves throughput by reducing work/cycle time.

Do not multiply routine output by the same full profession factor again.

Locked P2 factories retain their legacy Lv0–6 behavior for compatibility.

---

# 4. Graded percentage data

Shared grade magnitude:

| Grade | Magnitude |
|---|---:|
| 1 | 5% |
| 2 | 10% |
| 3 | 15% |
| 4 | 20% |
| 5 | 25% |

Examples of content data:
- Cần Mẫn -> `work_speed_per_grade = +5%`;
- Cẩu Thả -> `work_speed_per_grade = -5%`.

Their names are not part of the work formula.

A future trait named differently can use `work_speed +12%`, for example, without modifying Linh Điền or Workforce logic.

---

# 5. Profession talent

Profession-specific talent primarily accelerates learning.

Examples:
- Khai Khoáng Thiên Phú;
- Linh Thực Thiên Phú;
- Luyện Khí Thiên Phú;
- Luyện Đan Thiên Phú.

Grade 1–5:
- +5%;
- +10%;
- +15%;
- +20%;
- +25%

to profession XP.

Profession XP formula:

**XP Gain = Base XP × Thông Tuệ Factor × Profession Talent Factor × generic profession_xp modifiers × Facility XP Factor**

Talent is not also a direct routine-yield multiplier.

---

# 6. Work speed

Canonical formula:

**Work Speed = Profession Speed × generic work_speed modifiers × optional content affinity × Facility Factor**

No generic Tư Chất/Căn Cốt/Cơ Duyên/Mị Lực/Tiềm Lực multiplier belongs in work speed.

---

# 7. Rare events

Canonical formula:

**Rare Chance = Base Chance × Cơ Duyên Factor × generic rare_chance modifiers**

Cơ Duyên affects lucky/rare outcomes, not routine production.

---

# 8. Passive Tu Vi while actually working

Raw target:

**Raw Work Tu Vi/hour = Current Stage Requirement × 0.0005 × (1 + 0.0005 × Profession Level)**

Only time in which the disciple is actually performing work may grant this.

Autonomous timers do not count:
- passive crop countdown;
- waiting;
- queued production without active disciple work.

The raw amount is passed through existing cultivation gain authority, so Tư Chất and other valid cultivation modifiers apply naturally and only once.

Current P3.7 scheduler normalization:
- one active work step = `1/60 hour`.

---

# 9. Optional content affinity

No profession gets a universal Spiritual Root bonus.

If a specific crop/recipe/resource declares compatible elements and the disciple has a matching Spiritual Root element:

**Work Speed ×1.05**

No mismatch penalty by default.

---

# 10. Profession-talent generation

Starting generation targets:

Chance to receive one profession-specific talent:
- ordinary recruitment: 30%;
- gacha/high-quality recruitment: 40%;
- fate/special recruitment: 50%.

Conditional grade distribution:

| Grade | Probability |
|---|---:|
| 1 | 50% |
| 2 | 30% |
| 3 | 13% |
| 4 | 6% |
| 5 | 1% |

---

# 11. Compatibility rule

Legacy P2 profession fields and behavior remain available only where required for locked P2 compatibility.

P3.7 uses:
- the long-term profession curve;
- common lục-duy factors;
- generic modifier channels.

Do not create another parallel profession formula.
