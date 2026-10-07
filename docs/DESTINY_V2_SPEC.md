# MỆNH CÁCH V2 — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-07
Status: **DESIGN DRAFT FOR USER REVIEW — NOT IMPLEMENTED — NOT LOCKED**

Parents:
- `docs/GAME_SYSTEM_ARCHITECTURE.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`
- `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`
- `docs/COMBAT_STATS_V2_SPEC.md`
- `docs/TRAITS_V2_SPEC.md`

This document designs the rare **Mệnh Cách / Destiny** layer only.

No gameplay implementation is authorized by this draft.

---

# 1. Canonical naming — merge old Thiên Mệnh into Mệnh Cách

The old master schema contains a future layer named **Thiên Mệnh**.

V2 direction:
- there is **one** rare fate/destiny layer;
- canonical system name is **Mệnh Cách**;
- old generic `Thiên Mệnh` wording becomes legacy/future-migration terminology rather than a second parallel system.

Content may still use names containing "Thiên Mệnh" where lore requires it, but there must not be:
- Mệnh Cách system;
- plus a separate Thiên Mệnh system;
- both doing the same job.

This avoids duplicate rarity/fate authorities.

---

# 2. What makes Mệnh Cách different from Trait

Trait:
- many may coexist;
- common and uncommon;
- often numeric/channel-based;
- may be learned/removed through ordinary long-term development.

Mệnh Cách:
- extremely rare identity architecture;
- defines a **fate rule + milestone path**;
- may alter generation envelopes, encounter/event rules, breakthrough/life-history behavior or special combat rules;
- grows through **unique major milestones**, not ordinary XP;
- cannot be reduced to "Trait but +30% instead of +10%".

A Mệnh Cách may still contribute ordinary modifiers where needed, but its identity must contain at least one:
- rule change;
- special event rule;
- milestone interaction;
- unique state transition;
- unique content eligibility.

---

# 3. One active Chủ Mệnh

Starting V2 rule:

A disciple has:
- zero or one **active Chủ Mệnh**.

Mệnh Cách types are therefore mutually exclusive as current active destiny.

Reason:
- destiny should remain a coherent identity rather than becoming a giant pile of rare Traits;
- this makes a Mệnh Cách narratively readable.

This is **not** a birth ceiling:
- a person born with none may acquire one later;
- a person may eventually perform an explicit **Cải Mệnh** to change their Chủ Mệnh;
- previous Mệnh Cách identity/progress/history is never rerolled or silently deleted.

Long-term endgame may later design:
- re-attunement to a previously mastered Mệnh Cách;
- Hợp Mệnh / multiple-fate interaction.

Those are future endgame mechanics and are not required by the initial V2 runtime.

---

# 4. Mệnh Cách state model

Canonical states:

1. **Không Có**
2. **Tiềm Mệnh** — identity exists, hidden, inactive.
3. **Hiển Mệnh** — identity revealed; Core Mệnh effect becomes active.
4. **Khai Mệnh** — first major Mệnh Kiếp completed.
5. **Hóa Mệnh** — second major Mệnh Kiếp completed.
6. **Chứng Mệnh** — third major Mệnh Kiếp completed; full current fate expression.

These are power/progression states, not rarity colors.

There is no generic:
- Common/Rare/Epic;
- Grade 1–5;
- orange/red destiny tier.

Each Mệnh Cách has its own commonality weight and content identity.

---

# 5. Congenital rarity

Mệnh Cách is intended to be the rarest normal whole-person birth layer.

Starting ordinary congenital rate:

- **99.90%** — no congenital Mệnh Cách;
- **0.09%** — one latent Mệnh Cách at **Tiềm Mệnh**;
- **0.01%** — one congenital Mệnh Cách already at **Hiển Mệnh**.

Total congenital Mệnh Cách:
**0.10% ≈ 1 in 1,000 generated people**.

This is rarer than the locked 0.20% congenital Dị-Linh-Căn rate.

No ordinary birth starts above Hiển Mệnh.

Special story/named/event characters may explicitly override this.

---

# 6. Independence from normal quality

Normal Mệnh Cách roll is independent from:
- Disciple Quality;
- Dẫn Tiên Main-Guide quality table;
- Trait generation;
- Spiritual Root count/purity;
- congenital Dị-Căn roll;
- Bloodline/Physique future rolls.

Therefore a Phàm Thường may secretly carry a major Mệnh Cách.

Dẫn Tiên quality must not silently multiply Mệnh Cách odds.

Special recruitment/event content may explicitly guarantee or bias Mệnh Cách, but that is content data.

---

# 7. Whole-person generation order

Mệnh Cách identity must be deterministically seeded as part of whole-person generation.

For a congenital Mệnh Cách:

1. derive `destiny_seed`;
2. decide none / latent / revealed;
3. choose one eligible Mệnh Cách ID by content commonality;
4. apply explicit **birth package** if that Mệnh Cách owns one;
5. finalize immutable birth snapshots;
6. persist hidden identity before candidate presentation.

Important:
some Mệnh Cách may explicitly break the ordinary Lục-Duy birth envelope.

This is allowed only through a declared `birth_override`.

Example:
a special Mệnh Cách may guarantee a high minimum on one dimension or create an unusual distribution.

It is not a reroll:
- base generation + explicit override are one deterministic profile-finalization process;
- final birth values are what enter the immutable birth snapshot.

Most Mệnh Cách should not require a birth override.

---

# 8. No generic Mệnh Cách XP

Mệnh Cách does not level from:
- killing 1,000 normal monsters;
- working 1,000 cycles;
- passive time;
- ordinary cultivation XP.

Progress comes from **Mệnh Kiếp**.

A Mệnh Kiếp is:
- a one-time major condition;
- content-specific;
- meaningful to that Mệnh Cách;
- deterministic once completed.

Each Mệnh Cách defines:
- reveal condition;
- Khai Mệnh condition;
- Hóa Mệnh condition;
- Chứng Mệnh condition.

Repeated trivial actions must not farm Mệnh Cách progression.

---

# 9. Mệnh Nguyên — universal major fate resource

Starting resource design:

**Mệnh Nguyên**

Purpose:
- awaken/advance major fate progression;
- acquire a Mệnh Cách post-birth;
- perform future Cải Mệnh.

It is a stackable Sect resource and must use the canonical Sect Warehouse when implemented.

Mệnh Nguyên is deliberately rare.

Starting acquisition targets:

- designated destiny-grade Secret Realm / world-content first clear: **1 guaranteed**;
- major world boss first clear where content explicitly tags destiny reward: **1 guaranteed**;
- highest canonical Cơ-Duyên tier event may explicitly award **1**;
- repeat rare/world boss tagged for destiny: starting target **3%** for 1;
- special long-form sect/world events may grant 1.

No Mệnh Cách consumer may ship before at least one real Mệnh Nguyên acquisition path ships.

Do not create a premium-only Mệnh Cách resource.

---

# 10. Advancement costs

Congenital latent:
- reveal: condition only, no cost;
- **Hiển Mệnh -> Khai Mệnh**: first Mệnh Kiếp + **1 Mệnh Nguyên**;
- **Khai Mệnh -> Hóa Mệnh**: second Mệnh Kiếp + **2 Mệnh Nguyên**;
- **Hóa Mệnh -> Chứng Mệnh**: third Mệnh Kiếp + **4 Mệnh Nguyên**.

No failure chance.

A congenital already-Hiển Mệnh character skips only the reveal step.

This means congenital Mệnh Cách saves:
- acquisition cost;
- discovery uncertainty/time;
- access to its fate path earlier.

It does not impose a higher final ceiling than a successfully acquired version of the same Mệnh Cách.

---

# 11. Acquiring a Mệnh Cách when born without one

A person with no congenital Mệnh Cách may eventually gain one.

Future explicit action:
**Nghịch Thiên Cải Mệnh**.

Starting requirements:
- disciple has no active Mệnh Cách;
- fulfils that Mệnh Cách's entry prerequisite;
- Sect owns **8 Mệnh Nguyên**;
- later implementation provides the required fate ritual/content facility.

Result:
- player chooses one currently eligible Mệnh Cách;
- it is created directly at **Hiển Mệnh**;
- no random reroll;
- birth history remains "born without Mệnh Cách";
- acquisition is appended to character history.

Then it advances through the same 1 / 2 / 4 Mệnh-Nguyên Mệnh-Kiếp progression.

This preserves:
- rare birth value;
- favorite-disciple final access.

---

# 12. Cải Mệnh for a person who already has one

V2 must support explicit future destiny change.

Rules:
- never random overwrite;
- player chooses from eligible new Mệnh Cách;
- old Mệnh Cách progress is preserved in history/retired record;
- current active effects of the old Mệnh Cách stop;
- exact Cải-Mệnh cost must be greater than first acquisition and is future balance data.

Starting direction:
- one active Chủ Mệnh;
- no simultaneous stacking of full multiple Mệnh Cách in initial V2.

A future endgame Hợp-Mệnh system may revisit coexistence only through explicit design.

---

# 13. Reveal

A congenital Tiềm Mệnh has:
- true `destiny_id` stored from birth;
- no gameplay effect;
- no normal UI leakage.

Each type defines an event-driven reveal rule.

Reveal:
- never rerolls;
- costs no resource for congenital fate;
- changes Tiềm Mệnh -> Hiển Mệnh;
- activates Core Mệnh effect.

A future appraisal / Thiên Cơ facility may reveal the already-existing identity early.

It must not generate a new Mệnh Cách on appraisal.

---

# 14. Mệnh Cách definition schema

Conceptual static definition:

```
{
  id,
  name,
  category,
  commonality_weight,

  birth_override?,

  reveal_rule,

  core_effects,
  khai_menh_condition,
  khai_menh_effects,
  hoa_menh_condition,
  hoa_menh_effects,
  chung_menh_condition,
  chung_menh_effects,

  consumers_required,
  ai_hints,
  content_tags
}
```

Character save stores:
- identity/state/progress/history;
- not copied static effect tables.

---

# 15. Starter Mệnh Cách categories

Categories are content organization, not quality tiers:

- **Đạo Mệnh** — cultivation/mastery/path law;
- **Chiến Mệnh** — hunting/combat/adversity law;
- **Phúc Mệnh** — fortune/event/world opportunity law;
- **Hộ Mệnh** — protection/team/support law;
- **Kiếp Mệnh** — suffering/failure/transformation law;
- **Luân Hồi Mệnh** — death/rebirth/history-continuation law.

A Mệnh Cách may belong to more than one category.

---

# 16. Starter Mệnh Cách catalogue — design targets

These are initial design targets for architecture review.
Exact numbers are balance data.

## 16.1 Vạn Pháp Quy Nhất — Đạo Mệnh

Identity:
learn many paths and turn breadth into synergy.

Core — Hiển Mệnh:
- learning/mastery of the disciple's currently lowest Kiếm/Thể/Pháp path gets +20%.

Khai Mệnh condition:
- two paths each reach the future "established" depth threshold.

Khai effect:
- skills of the lower of those two paths gain +10% Skill Effect.

Hóa condition:
- all three paths reach established threshold.

Hóa effect:
- all three path-tagged skills gain +10% Skill Effect;
- switching active technique between paths does not impose any future ordinary adaptation penalty if such a penalty system exists.

Chứng condition:
- all three paths reach the future high mastery threshold.

Chứng effect:
- each combat cast receives an additional +5% Skill Effect for each **other** established path, max +10%.

No fixed class.
This fate rewards genuinely developing all paths.

Consumer readiness:
- core can use Path XP;
- exact established/high thresholds are consumer-gated to Path/Mastery V2.

---

## 16.2 Thiên Quyến Hồng Phúc — Phúc Mệnh

Identity:
near-miss fortune can become true opportunity.

Core:
once per simulation day, on a **meaningful canonical Luck Score check**, if the final score is within 200 points below the next luck tier, promote it one tier.

Rules:
- no effect on routine fixed rewards;
- no per-hit/per-tick luck rolls;
- only one promotion/day;
- cannot promote beyond the highest tier.

Khai Mệnh:
- resolve one highest-tier major fortune event.

Khai effect:
- daily near-miss window becomes 300.

Hóa Mệnh:
- resolve three distinct major-fortune event IDs.

Hóa effect:
- first promoted major event each day may use the promoted tier's reward table normally; no duplicate reward roll.

Chứng Mệnh:
- complete one destiny-grade fortune storyline.

Chứng effect:
- once per 30 simulation days, a failed meaningful Luck check may be rerolled once using the same deterministic event seed branch.
- no reroll chaining.

This changes event law rather than simply adding Cơ Duyên.

---

## 16.3 Phá Quân — Chiến Mệnh

Identity:
stronger when confronting content above the disciple's current standing.

Core:
against an encounter whose canonical danger/realm tier is at least one tier above the disciple:
- +10% All Damage.

Khai condition:
- survive and win one such encounter.

Khai effect:
- also +5% Damage Reduction in those encounters.

Hóa condition:
- defeat three distinct higher-tier boss IDs.

Hóa effect:
- +10% Movement Speed in qualifying encounters;
- combat AI raises willingness to commit offensive skills.

Chứng condition:
- first-clear a designated destiny-grade boss while personally participating.

Chứng effect:
- once per qualifying encounter, dropping below 30% HP grants 5s:
  - +15% All Damage;
  - +10% Damage Reduction.
- once per encounter, no refresh.

Cannot use Combat Rating as the qualification authority.
Use explicit encounter danger/realm tier.

---

## 16.4 Bách Chiết Bất Khuất — Kiếp Mệnh

Identity:
major setbacks become one-time fate milestones.

Core:
serious Injury Recovery +15%.

Khai condition:
- fully recover from one serious named injury acquired in real combat.

Khai effect:
- next serious-injury recovery time -20%.

Hóa condition:
- recover from three distinct serious injury types or sources.

Hóa effect:
- while carrying a serious injury:
  - +10% Effect Resistance;
  - +5% Damage Reduction.

Chứng condition:
- survive a designated major calamity / near-defeat storyline.

Chứng effect:
- once per 30 simulation days, when a combat defeat would create a new ordinary acquired negative Trait, block that Trait acquisition.
- does not prevent Injury;
- does not erase congenital latent Trait;
- does not block Mệnh-Cách-specific consequences.

The final effect is consumer-gated until acquired-negative-Trait hooks exist.

---

## 16.5 Hộ Đạo — Hộ Mệnh

Identity:
fate expresses through saving allies rather than personal DPS.

Core:
when healing or shielding another target:
- +15% Healing Done / Shield Effect for that action.

Khai condition:
- complete a real encounter in which the disciple heals/shields allies for a future minimum meaningful amount.

Khai effect:
- when an ally first drops below 30% HP each encounter, the disciple's next eligible heal/shield on that ally within 5s gains +20% effect.

Hóa condition:
- successfully prevent three distinct ally defeats through healing/shielding according to combat event attribution.

Hóa effect:
- after protecting a low-HP ally, both gain +10% Damage Reduction for 3s.

Chứng condition:
- complete a designated high-risk team encounter with no ally defeated while this disciple actively supports.

Chứng effect:
- once per encounter, if an ally would take lethal damage and the disciple is alive and able to act, that hit is reduced so the ally remains at 1 HP;
- then the disciple is locked out of this effect for the encounter.
- this is a fate rule, not U Minh ownership;
- cannot chain with itself.

Exact "able to act" semantics are consumer-gated to final combat action/status authority.

---

## 16.6 Đại Khí Vãn Thành — Đạo/Kiếp Mệnh

Identity:
slow early growth, exceptional payoff from overcoming major realm walls.

Core:
- natural cultivation gain -10%;
- each **major realm breakthrough completed by this character** permanently records one `late_bloom_mark`.

Khai condition:
- complete the first major realm breakthrough after Hiển Mệnh.

Khai effect:
- each late-bloom mark gives +5% technique/skill mastery XP, max 3 marks.

Hóa condition:
- reach 3 marks.

Hóa effect:
- cultivation penalty is removed;
- the 3 marks also grant +5% Realm+Body core ATK/DEF/HP growth each for future gains.

Chứng condition:
- complete a designated high-realm breakthrough after 3 marks.

Chứng effect:
- all previously earned Realm+Body core growth since Hiển Mệnh is retroactively recalculated as if the 3-mark growth bonus had applied.
- equipment/fixed additions are not multiplied.

This is strongly consumer-gated to Breakthrough + final Realm/Body growth authority.

---

## 16.7 Thiên Đố Anh Tài — Đạo/Kiếp Mệnh

Identity:
extraordinary learning/growth at a real life-cost.

Core target:
- +20% cultivation gain;
- +20% learning/mastery XP;
- lifespan cost.

This Mệnh Cách is **future_only / consumer-gated** until Age/Lifespan/Ma-Hồn authority is closed.

Do not ship only the positive half.

Its final design must account for the project's rule that lifespan expiry does not permanently delete the disciple.

---

## 16.8 Túc Tuệ Chuyển Thế — Luân Hồi Mệnh

Identity:
past-life knowledge survives death/rebirth transformations.

Core target:
- special memory/mastery preservation across Ma/Hồn/revival or reincarnation.

This Mệnh Cách is **future_only** until the Ma/Hồn/revival system exists.

It may not fake reincarnation by granting arbitrary mastery at ordinary recruitment.

---

# 17. Why profession-specific fate is limited

Reference games may bind destiny strongly to fixed profession/class.

This project does not use fixed classes.

Therefore:
- Mệnh Cách may interact with path/profession tags;
- but ordinary Mệnh Cách should not say "only Sword class may have this" unless lore/content explicitly requires it.

Role emerges from:
- techniques;
- equipment;
- path history;
- profession history;
- player/AI choices.

---

# 18. Why no generic Mệnh Cách color/tier

A generic power rarity encourages:
- "red fate always better";
- reroll obsession;
- one-number evaluation.

Instead:
- each Mệnh Cách has commonality;
- every Mệnh Cách has a full Chứng-Mệnh path;
- balance aims for different rules/roles rather than one strict universal ranking.

Special named/story Mệnh Cách may be stronger or stranger, but this is explicit content.

---

# 19. Persistence target

```
destiny_model_version = 2

destiny_profile = {
  "initialized": true,

  "birth_destiny_id": "none|...",
  "birth_state": "none|latent|revealed",

  "active_destiny_id": "none|...",
  "state": "none|latent|revealed|opened|transformed|proven",

  "milestones": {
    "reveal": false,
    "khai": false,
    "hoa": false,
    "chung": false
  },

  "retired_destinies": {
    "...": {
      "last_state": "...",
      "milestones": {...}
    }
  },

  "history": [
    {
      "event": "born|revealed|acquired|khai|hoa|chung|changed",
      "destiny_id": "...",
      "source": "...",
      "tick": 0
    }
  ]
}
```

Static definition/effects are registry content, not copied into every save.

Hidden congenital identity is stored before reveal.

No empty-field reroll.

---

# 20. Candidate presentation

Normal recruitment UI:
- does not show latent Mệnh Cách;
- does not show "has one hidden destiny";
- does not leak via eligibility blocking.

Already-Hiển Mệnh birth:
- shows Mệnh Cách clearly;
- does not change Disciple Quality label.

Special appraisal content may reveal a stored latent fate.

---

# 21. Large-roster runtime

For 1,000–3,000 disciples:

Do not tick Mệnh Cách logic continuously.

Use event hooks:
- major breakthrough resolved;
- boss/encounter resolved;
- serious injury recovered;
- meaningful luck event resolved;
- ally lethal intercept point;
- path mastery milestone;
- world/secret-realm first clear.

Only disciples involved in a relevant event evaluate their fate rules.

No persistent per-disciple destiny timer unless a specific fate truly needs one.

---

# 22. AI interaction

Mệnh Cách may provide AI hints, never a parallel AI brain.

Examples:
- Phá Quân values higher-tier combat more;
- Hộ Đạo values endangered allies;
- Vạn Pháp Quy Nhất values developing underused paths.

Player orders may override ordinary AI preference.

AI must not reveal hidden Mệnh Cách by changing behavior before reveal.

---

# 23. Interaction with other character layers

## Lục Duy
Mệnh Cách may explicitly alter birth finalization or downstream channels.
It does not normally rewrite current Lục Duy every tick.

## Trait
Trait and Mệnh Cách may overlap channels.
Trait remains the more common many-per-person characteristic layer.

## Spiritual Root
Mệnh Cách does not replace elements/purity/mutations.

## Bloodline / Physique
Mệnh Cách may react to them in a specific storyline, but does not own their progression.

## Combat Stats
Numeric effects use canonical channels.

## Cơ Duyên
Phúc Mệnh may modify **Luck-check rules**, not silently become "+500 Cơ Duyên".

---

# 24. Migration direction from old schema

Old `Thiên Mệnh` future terminology maps to **Mệnh Cách V2**.

There is no live full old Destiny runtime to preserve as gameplay authority.

When implementation begins:
- add explicit V2 initialized marker;
- existing saves without Destiny data deterministically initialize through migration rules;
- migration must not reroll already-persisted hidden identity if any older field exists.

---

# 25. Required implementation invariants

When implemented, test at minimum:

1. same seed/source/index produces same congenital destiny result;
2. congenital rate matches 0.10% target over large deterministic samples;
3. normal Dẫn Tiên quality does not modify destiny rate;
4. no ordinary birth has more than one Mệnh Cách;
5. latent identity exists before reveal;
6. hidden fate has no gameplay/AI effect before reveal;
7. reveal never rerolls;
8. appraisal reveals stored identity rather than generates one;
9. no generic Mệnh Cách XP exists;
10. Mệnh Kiếp cannot be farmed repeatedly after completion;
11. advancement consumes exact 1/2/4 Mệnh Nguyên;
12. post-birth acquisition consumes exact acquisition cost and is player-selected, not random;
13. acquired fate has same final ceiling as congenital version;
14. birth history is never rewritten by acquisition/Cải Mệnh;
15. only one active Chủ Mệnh in initial V2;
16. retired fate state/history persists;
17. Mệnh Cách does not alter Disciple Quality directly;
18. fixed-value consumables remain fixed unless explicit;
19. numeric effects use canonical channels;
20. Cơ Duyên rule modification does not rewrite Cơ Duyên;
21. hidden fate does not leak through UI/AI/conflict eligibility;
22. consumer-gated effects cannot become active without owning subsystem;
23. save/load and deterministic continuation preserve fate exactly;
24. large-roster simulation has no all-disciple per-tick destiny polling;
25. rule-triggered fate effects cannot recursively self-trigger unless explicitly allowed.

---

# 26. Proposed decisions for user review

This draft proposes:

1. merge old generic Thiên Mệnh terminology into one canonical **Mệnh Cách V2** system;
2. one active Chủ Mệnh at a time in initial V2;
3. congenital rate **0.10%** = 0.09% latent + 0.01% already revealed;
4. normal rate independent from Disciple Quality/Dẫn Tiên/Root/Trait;
5. no generic quality color or Grade 1–5;
6. states = none / Tiềm Mệnh / Hiển Mệnh / Khai Mệnh / Hóa Mệnh / Chứng Mệnh;
7. no generic Mệnh Cách XP;
8. progress by three unique Mệnh Kiếp milestones;
9. universal rare resource **Mệnh Nguyên**;
10. congenital progression costs 1 / 2 / 4 Mệnh Nguyên after reveal;
11. non-congenital disciple may acquire an eligible chosen Mệnh Cách at Hiển Mệnh for **8 Mệnh Nguyên**;
12. acquisition and advancement are deterministic, no fail RNG;
13. same final fate ceiling whether congenital or acquired;
14. future Cải Mệnh is explicit/player-chosen and preserves old fate history;
15. starter catalogue begins with Vạn Pháp Quy Nhất, Thiên Quyến Hồng Phúc, Phá Quân, Bách Chiết Bất Khuất, Hộ Đạo, Đại Khí Vãn Thành, plus consumer-gated Thiên Đố Anh Tài and Túc Tuệ Chuyển Thế;
16. all Mệnh Cách must contain at least one real rule/event/milestone change and cannot be only a larger stat Trait.

No gameplay implementation is authorized until this design is reviewed and locked.
