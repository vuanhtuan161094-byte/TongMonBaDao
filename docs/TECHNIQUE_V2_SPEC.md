# CÔNG PHÁP V2 — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-08  
Status: **DESIGN LOCKED — NOT IMPLEMENTED**

Read with:
- `docs/CULTIVATION_PATH_V2_SPEC.md`
- `docs/COMBAT_SKILLS_V2_SPEC.md`
- `docs/SPIRITUAL_ROOT_V2_SPEC.md`
- `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`
- `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`

Legacy P2.3 remains compatibility-only for old runtime and tests.

---

# 1. Identity boundary

**Công Pháp** is cultivation/build foundation.

It may own:
- cultivation modifiers;
- passive combat modifiers;
- authored conditional/passive rules;
- compatibility/prerequisite relationships;
- Chủ Đạo guidance;
- Diễn Hóa successor relationships.

**Kỹ Năng** is a combat action or combat passive.

A Công Pháp does **not** automatically grant a full combat-skill kit.

Công Pháp and Kỹ Năng may be related through:
- independence;
- tag synergy;
- explicit prerequisite.

---

# 2. Three ownership layers

Keep separate:

1. **Sect transmission / ownership**
2. **Individual learned mastery**
3. **Current active operation**

A disciple may know many Công Pháp over a long life.

Inactive learned Công Pháp:
- retain knowledge;
- retain personal mastery;
- retain history;
- may satisfy explicit prerequisites;
- do **not** contribute their ordinary combat/stat passives while inactive.

---

# 3. Active loadout

V2 active Công Pháp loadout:

- **1 Chủ Tu**
- **2 Phụ Tu**

Chủ Tu:
- primary cultivation/build foundation;
- default guidance for Định Đạo;
- receives the strongest authored "main technique" relationships where content defines them.

Phụ Tu:
- support the build;
- may provide utilities/modifiers allowed by their definitions.

This supersedes legacy P2.3:
- max 3 learned techniques;
- exactly one active technique.

V2 may store a larger learned library.

---

# 4. Learning

To learn from the Sect:
- Tàng Kinh Các has the transmission;
- disciple satisfies authored requirements;
- disciple pays Contribution;
- disciple pays personal Spirit Stones when required;
- learning consumes time;
- result is deterministic.

No generic learning-failure RNG.

Requirements may include:
- realm;
- Luyện Thể;
- Root/element compatibility;
- Chủ Đạo/branch;
- prerequisite Công Pháp;
- prerequisite skill/mastery;
- explicit content/event.

Root mismatch does not generically forbid learning unless the Công Pháp explicitly requires it.

---

# 5. Tàng Kinh Các transmission

First complete manual archived:
- unlocks permanent Sect transmission for that definition.

Teaching a disciple:
- does not consume another full manual.

Duplicate complete manuals, fragments and commentaries may feed:
- completion;
- Nghiên Tu Tông Môn;
- authored unlocks;
- successor/evolution research.

The exact resource recipe belongs to content definitions.

---

# 6. Individual mastery

Personal mastery stages:

- Sơ Học
- Nhập Môn
- Tiểu Thành
- Đại Thành
- Viên Mãn

Progress is continuous beneath milestone labels.

Mastery may come from:
- actual cultivation while the Công Pháp is meaningfully used;
- valid combat/trigger usage;
- specialized study;
- Diễn Võ/Ngộ Đạo;
- future teaching/master-disciple hooks.

Anti-trivial-farm rules are required.

Thông Tuệ:
- increases valid learning/mastery XP speed;
- does not create a permanent final mastery ceiling.

Matching Spiritual Root:
- adds matching-element mastery bonus where the Công Pháp actually uses that element.

---

# 7. Mastery effects

Mastery effects are authored per Công Pháp.

Do not use a universal rule such as:
- every mastery milestone = +5% damage.

Possible authored changes:
- stronger passive magnitude;
- unlock conditional rule;
- expand allowed synergy;
- reduce an explicit drawback;
- enable successor prerequisite;
- alter cultivation behavior.

---

# 8. Grade / rarity

Candidate grade ladder:

- Phàm
- Huyền
- Địa
- Thiên
- Tiên
- Thần

Grade means:
- rarity;
- depth;
- complexity;
- transmission value.

Grade is **not** a universal scalar multiplier.

Do not hard-map:
- Phàm = Luyện Khí;
- Huyền = Trúc Cơ;
- etc.

Low-grade Công Pháp may remain useful through:
- utility;
- low requirements;
- low costs;
- niche rules;
- Diễn Hóa.

---

# 9. Nghiên Tu Tông Môn

Sect research is separate from personal mastery.

Possible inputs:
- duplicate manuals;
- fragments;
- commentaries;
- special research materials.

Possible outputs:
- authored Sect-side improvement;
- completion of missing sections;
- successor/evolution eligibility;
- new teaching utilities.

Do not create a universal "research level = +X all stats" ladder.

---

# 10. Diễn Hóa / successor

Diễn Hóa creates an authored **successor Công Pháp** with its own identity/name.

It is not:
- Công Pháp +17;
- a color/star feed system.

A predecessor may have:
- one successor;
- multiple authored branches.

When a successor replaces a predecessor as active source:
- predecessor effect does not stack with successor;
- mastery/history is preserved;
- some mastery may carry according to branch rules.

V1 uses authored successors only.
No procedural random naming/effect generation.

---

# 11. Personal discovery

A disciple may personally discover/evolve a new authored Công Pháp when eligibility is satisfied.

Initially:
- only that disciple owns the personal discovery.

To make it Sect-teachable:
- **Khắc Lục** the transmission into Tàng Kinh Các.

This preserves the fantasy that an individual can create a legacy.

---

# 12. Passive taxonomy

A Công Pháp may define:

- main passive;
- auxiliary passive;
- conditional modifier;
- trigger;
- tag modifier;
- party aura;
- unique rule.

Static self-only modifiers may remain always-on while that Công Pháp is active.

Triggered or party-wide effects must follow shared combat event/stacking rules.

---

# 13. Conflict and uniqueness

Content may define:
- conflict groups;
- unique effect families;
- strongest-only rules.

The same unique passive may not duplicate through:
- Chủ Tu + Phụ Tu;
- multiple generations of one family;
- duplicate sources that declare the same unique key.

Trigger attribution must prevent recursion.

---

# 14. Relationship to Chủ Đạo

Learning a Công Pháp does not permanently lock a class.

An eligible main Công Pháp may guide:
- Định Đạo;
- branch evolution;
- Diễn Đạo prerequisites.

Switching active Chủ Đạo does not erase:
- learned Công Pháp;
- mastery;
- history.

Only active compatible sources contribute their current ordinary effects.

---

# 15. Relationship to Kỹ Năng

Allowed relationships:

1. **Independent**
   - skill can be learned without this Công Pháp.

2. **Tag synergy**
   - this Công Pháp improves explicit skill tags/elements/roles.

3. **Prerequisite**
   - the skill requires this Công Pháp/mastery.

A Công Pháp never silently creates a combat skill unless explicit content says it grants a named transmission as a special exception.

Generic breakthrough modifiers are not owned by Công Pháp.
Rare authored effects may explicitly alter breakthrough under `CULTIVATION_BREAKTHROUGH_V2_SPEC.md`.

---

# 16. Persistence

Persist:
- learned Công Pháp IDs;
- personal mastery XP/milestones;
- active Chủ Tu/Phụ Tu selection;
- discovery/provenance/history;
- successor/branch knowledge;
- personal Khắc Lục state where relevant.

Do not persist derived final stats as Công-Pháp-owned save truth.

---

# 17. Scale contract

Target roster is 1,000–3,000 disciples.

Therefore:
- inactive learned techniques must not run combat triggers;
- active loadout is bounded 1+2;
- mastery progresses only on meaningful events;
- no per-frame scan of every learned Công Pháp.

---

# 18. Legacy migration direction

P2.3 legacy rules are not V2 authority for:
- max three learned Công Pháp;
- one-active-only final model;
- level 1–5 upgrade as final mastery;
- old generic breakthrough bonuses;
- old storage/material authorities already superseded by P3.7.

When migration is authorized:
- preserve learned identities and history where possible;
- map legacy active technique to initial Chủ Tu;
- convert old mastery/level deterministically;
- do not create duplicate transmissions.

---

# 19. Locked summary

1. Công Pháp and Kỹ Năng are separate.
2. 1 Chủ Tu + 2 Phụ Tu active.
3. Learned inactive techniques retain mastery/history but ordinary effects are inactive.
4. First archived manual unlocks Sect transmission.
5. Teaching is deterministic and does not consume a book per disciple.
6. Personal mastery uses five milestones.
7. Sect Nghiên Tu is separate.
8. Grade is rarity/depth, not a universal multiplier.
9. Diễn Hóa creates named authored successors.
10. Successor effects do not stack with predecessor.
11. Personal discovery is possible and can be Khắc Lục.
12. Conflict/unique-passive rules are explicit.
13. Switching Chủ Đạo preserves knowledge/mastery/history.
14. Technique-skill relation is independent/synergy/prerequisite.
