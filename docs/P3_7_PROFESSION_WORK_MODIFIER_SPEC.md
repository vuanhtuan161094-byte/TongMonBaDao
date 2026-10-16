# P3.7 — SHARED PROFESSION / WORK MODIFIER SPEC

## Owner clarification — 2026-10-15 (profession, not cultivation realm)

**Áp dụng cho mọi nghề:** cấp làm việc là **cấp nghề của chính hoạt động đó**: Mỏ → Khai Khoáng, Linh Điền → Linh Thực, Linh Lâm → Lâm Nghiệp, Luyện Đan → Luyện Đan, Luyện Khí → Luyện Khí. Không lấy cảnh giới Tu Vi thay cấp nghề sản xuất. Lục Duy chỉ được đi qua kênh có thẩm quyền của nghề/recipe, không nhân `Tổng Lục Duy` cho mọi sản phẩm.

**P1 code scope chỉ có Mỏ:** một công trình Mỏ = một người tại mọi level. Existing `ProfessionModifierSystem` remains canonical speed/EXP for every profession. Cấp nghề Khai Khoáng tiếp tục thay đổi **thời gian mẻ** qua `1 + 0.01 × Level`; Thông Tuệ giữ kênh EXP nghề đã có. **KHÔNG có bonus Căn Cốt → quặng:** Căn Cốt là nguồn tác động Luyện Thể; chủ dự án đã bác bỏ công thức tùy tiện `+1 quặng/1.000 Căn Cốt` ngày 15/10. Số quặng/mẻ P1 **tạm dùng output hiện có từ định nghĩa/cấp Mỏ**, snapshot khi bắt đầu timer, commit Kho và lương đúng một lần. Ảnh hưởng Lục Duy lên **kết quả** sản xuất riêng từng nghề cần luật outcome cụ thể được duyệt; không tự dùng cả sáu trục, không tạo bonus quặng hiếm giả. Các nghề khác vẫn giữ speed/XP và luật kết quả đã khóa, P1 không đổi công thức.


Status: CANONICAL DESIGN AUTHORITY  
Updated: 2026-10-16

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

# 2. P3.7C1 open-point lục-duy authority

The old P3.7 normalized common curve `0.75 + 0.50 × value` is retired for P3.7 runtime.

Canonical open-point roles now come from:
`docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`

Starting balance:
- Tư Chất -> cultivation gain: +0.25% per point;
- Căn Cốt -> body-training gain: +0.20% per point;
- Thông Tuệ -> profession/learning XP: +0.15% per point;
- Cơ Duyên -> Luck Score check, not an uncapped percentage;
- Mị Lực -> Social Score / Dẫn Tiên authority, not an uncapped percentage;
- Tiềm Lực -> future Realm + Body growth: +0.05% per point.

P0–P2 factories keep the old normalized model behind their existing feature boundary for regression compatibility.

During migration of old P3.7 rare/social consumers:
- bounded compatibility bridges are allowed;
- new systems must use the canonical Cơ Duyên/Mị Lực checks;
- do not make 2,500 Cơ Duyên or Mị Lực become a raw +2,500% chance.

Fixed-value books/pills/items grant their stated amount and are not multiplied by a foundation unless the content explicitly says so.

---

# 3. Profession level

P3.7 long-term profession level is derived from accumulated profession XP:

**Level = floor(sqrt(XP / 24))**

Profession throughput:

**Profession Speed Factor = 1 + 0.01 × Level**

Examples:
- Lv0 -> ×1.00;
- Lv1 -> ×1.01;
- Lv10 -> ×1.10;
- Lv50 -> ×1.50;
- Lv100 -> ×2.00.

**Lv100 is a balance benchmark, not a profession cap.** Profession progression remains
independent from the two 30-realm character tracks; a future cap requires a separate owner decision.

Profession level improves throughput by reducing work/cycle time.

Do not multiply routine output by the same full profession factor again.

Timer authority must preserve small speed modifiers across integer simulation ticks.
A +1% worker cannot lose the entire benefit merely because each individual deadline
uses `ceil(base/speed)`. Production timers therefore retain fixed-point overshoot
remainder and commit that remainder only when the corresponding output actually settles.
Cancellation does not bank free work.

Locked P2 factories retain their legacy Lv0–6 behavior for compatibility.

## 3.1 Realm separation

Production profession level is independent from both canonical progression tracks:

- Tu Vi: 30 đại cảnh × 10 tầng, `Phàm Nhân` through `Sáng Thế Chủ`;
- Luyện Thể: 30 đại cảnh × 10 tầng, `Phàm Thân` through `Sáng Thế Thần Thể`.

A resource/recipe may declare an explicit canonical **realm tier** when progression content
needs thematic/tier alignment. That tier is descriptive progression metadata, **not** a worker
eligibility or work-speed substitute. Production access remains owned by explicit building level,
profession level and Sect progression rules. New Economy V2 content uses 1-based realm-tier
indexes from `DiscipleRealmProgressV2`; legacy labels such as `pham/luyen_khi/truc_co/kim_dan`
are compatibility metadata only.

---

# 4. Grade boundary — profession talent versus Trait V2

**User-locked V2 resolution (2026-10-09):** The Grade 1–5 magnitude table below is **valid for Profession Talent / legacy P3.7 compatibility**, **not** a universal `Trait V2 Grade` rule.

| Profession talent grade | Profession XP magnitude |
|---|---:|
| 1 | +5% |
| 2 | +10% |
| 3 | +15% |
| 4 | +20% |
| 5 | +25% |

In the older P3.7 work/trait compatibility model, entries like `Cần Mẫn` and `Cẩu Thả` may have been assigned a per-grade `work_speed` modifier. **That grading is not Trait V2 authority** and must be retired/converted when V2 consumers replace the legacy code. In V2, each ordinary Trait declares its own fixed/conditional numeric effect, typed channel and effect readiness, with **no Trait Grade 1–5**.

This is a clear separation:
- **Profession talent:** identity and Grade 1–5, primarily modifies profession XP.
- **Trait V2:** ungraded positive/negative/mixed identity with its own real work/learning/behavioral effect.
- Both may contribute to a work result where their definitions permit it, but one cannot silently convert into the other.

The work formula remains generic: a new approved Trait's `work_speed +12%`, for example, plugs into an existing channel without modifying the Linh Điền or Workforce source code.

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

Profession XP formula remains conceptually:

**XP Gain = Base XP × valid learning/work modifiers**

For P3.7 open-point characters, Thông Tuệ contributes its canonical +0.15% learning XP per point. Existing modifier composition may be migrated incrementally, but no second Thông Tuệ curve may be introduced.

Talent is not also a direct routine-yield multiplier.

---

# 6. Work speed

Canonical formula:

**Work Speed = Profession Speed × generic work_speed modifiers × optional content affinity × Facility Factor**

No generic Tư Chất/Căn Cốt/Cơ Duyên/Mị Lực/Tiềm Lực multiplier belongs in work speed.

---

# 7. Rare events

Canonical new-content rule:

**Luck Score = RNG(0..9999) + Cơ Duyên - Difficulty**

Then map the score to the canonical luck tier.

Existing locked content may temporarily use the bounded compatibility bridge until migrated to one meaningful check per outcome. Cơ Duyên affects lucky/rare outcomes, not routine production.

---

# 8. V2 Tu Vi during work — SUPERSEDED 2026-10-09

The old P3.7 formula `Raw Work Tu Vi/hour = Current Stage Requirement × ...` remains legacy/P2 compatibility only.

For an authentic V2 disciple:
- ordinary work does **not** create a separate Tu Vi reward;
- the disciple receives the same continuous natural Tu Vi source that every eligible V2 disciple receives each simulation minute;
- Tư Chất and valid cultivation modifiers are applied once by the V2 cultivation authority;
- work speed/profession level must not silently multiply that passive Tu Vi source;
- `_grant_p3_7_work_cultivation()` returns 0 for authentic V2 to prevent double credit.

This rule applies equally to mining, forging, herbalism and other ordinary jobs unless a future authored effect explicitly grants a separate fixed/reward source.

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
