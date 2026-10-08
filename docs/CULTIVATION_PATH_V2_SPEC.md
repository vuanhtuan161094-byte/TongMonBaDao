# CHỦ ĐẠO / CULTIVATION PATH V2 — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-08  
Status: **DESIGN LOCKED — NOT IMPLEMENTED**

Read with:
- `docs/TECHNIQUE_V2_SPEC.md`
- `docs/COMBAT_SKILLS_V2_SPEC.md`
- `docs/REALM_LADDER_V2_SPEC.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`

Legacy P2.4 path XP/stat bonuses remain compatibility-only until V2 migration.

---

# 1. Core identity

V2 uses a **soft active Chủ Đạo**, not a permanent fixed class.

Base states:

- Chưa Định Đạo
- Kiếm Tu
- Thể Tu
- Pháp Tu

Only one Chủ Đạo is active at a time.

A disciple may retain deep history in multiple paths.

---

# 2. No class level

There is no:
- Kiếm Tu Lv.73;
- Thể Tu Lv.41;
- generic class XP 1–100;
- generic class stat growth.

Raw power comes from:
- Realm;
- Luyện Thể;
- Combat Stats;
- Công Pháp;
- Kỹ Năng;
- equipment;
- Roots;
- Bloodline;
- Physique;
- Traits/Mệnh;
- explicit content.

---

# 3. Base branches

## Kiếm Tu
- Ngự Kiếm
- Sát Kiếm
- Hộ Kiếm

## Thể Tu
- Bá Thể
- Kim Cương
- Huyết Thể

## Pháp Tu
- Ngũ Hành
- Y Đạo
- Huyền Pháp

Branches open:
- compatibility;
- skill families;
- AI tendencies;
- authored identity rules.

They do not grant generic free ATK/DEF/HP per branch level.

---

# 4. Y Đạo minimum identity

Y Đạo is not merely "larger heal numbers".

Its content must support:
- heal;
- buff;
- cleanse;
- emergency save.

Later higher-tier content may also support:
- shield;
- revive;
- recovery manipulation.

---

# 5. Định Đạo

A disciple begins Chưa Định Đạo.

Base Định Đạo direction:

1. learn an eligible main Công Pháp tagged to one base path;
2. satisfy its Tu Vi/Luyện Thể requirements;
3. perform deterministic Sect-based Định Đạo with authored time/cost;
4. that Công Pháp becomes the default Chủ Tu unless the player deliberately changes it later.

A combat skill is not required to Định Đạo.

No random class roll.

---

# 6. Switching

The player/system may switch active Chủ Đạo/branch through explicit Sect/time/resource rules.

Switching:
- does not erase learned Công Pháp;
- does not erase learned Kỹ Năng;
- does not erase mastery;
- does not erase history;
- does not reset previous Đạo Lịch.

Only one active Chủ Đạo/branch contributes current path-specific compatibility at a time.

Switching is not a mid-combat action.

---

# 7. Đạo Lịch

Legacy P2.4 generic path XP is replaced conceptually by **Đạo Lịch**.

Đạo Lịch records meaningful lived history such as:
- time genuinely practicing the path;
- valid path-skill usage;
- combat participation;
- major breakthroughs while practicing the path;
- mastered compatible Công Pháp;
- mastered compatible Kỹ Năng;
- branch milestones;
- authored feats/events.

Đạo Lịch is used for:
- Diễn Đạo eligibility;
- titles;
- events;
- transmission;
- self-comprehension;
- legacy/history display.

Đạo Lịch is **not** a generic stat multiplier.

No:
- Sword history = +20% free damage;
- Body history = +12% free DR;
- Spell history = +12% free cultivation.

Those legacy P2.4 bonuses are not V2 authority.

---

# 8. Diễn Đạo / branch evolution

A base path may evolve into an eligible branch when requirements are met.

Canonical requirement categories:
- currently active base path;
- compatible guiding Công Pháp at least Đại Thành where required;
- required skill-family/mastery progression;
- appropriate Tu Vi/Luyện Thể;
- matching Đạo Lịch;
- authored Sect facility/resource/time conditions.

Result is deterministic once requirements are satisfied.

No RNG branch roll.

---

# 9. Multiple branch history

A disciple may eventually unlock multiple branches historically.

However:
- only one branch is active at a time.

Unlocking another branch does not delete the old one.

This supports the long-term favorite-disciple fantasy.

---

# 10. No universal path resources

Do not create universal:
- Kiếm Ý bar;
- Cương Kình bar;
- Pháp Ấn bar;
- Y Tức bar;
- Rage/Mana equivalents.

Specific authored builds may create a special resource only if it materially changes that build.

The resource then belongs to that content/family, not the whole path.

---

# 11. Relationship to 30-realm skill growth

All three base paths use the shared three-wave combat-skill law:

- Nhân Giới 1–10: learn/open the full foundational combat language of the class/branch;
- Tiên Giới 11–20: evolve those skill/passive families into Tiên generations;
- Thần Giới 21–30: evolve again into Thần generations with bounded rule-changing effects.

Path identity itself does not add another fourth skill-growth ladder.

See:
`docs/COMBAT_SKILLS_V2_SPEC.md`.

---

# 12. Relationship to Công Pháp

Công Pháp can:
- guide Định Đạo;
- satisfy branch prerequisites;
- improve explicit path/style/element tags.

Công Pháp does not equal the path itself.

Changing Chủ Tu does not automatically rewrite active Chủ Đạo unless the player/system performs the explicit path-switch process.

---

# 13. Relationship to weapon

Path/style and weapon requirement are separate concepts.

Example future direction:
- `style_tag = sword`
- `weapon_requirement = sword`

A sword-style technique may exist without requiring a physical sword if its content explicitly says so.

Weapon V2 owns actual equipment typing/requirements.

This separation is required to resolve Kiếm Cốt and weaponless sword-style content correctly.

---

# 14. Persistence

Persist:
- current active Chủ Đạo;
- current active branch;
- unlocked historical branches;
- Đạo Lịch/history;
- major path milestones;
- switch/Diễn-Đạo provenance where useful.

Do not save generic path-derived ATK/DEF/HP as independent truth.

---

# 15. Scale

For 1,000–3,000 disciples:
- Đạo Lịch updates only on meaningful events;
- no per-frame path-XP ticking;
- no scan across all historical paths during ordinary combat;
- active path/branch lookup is O(1).

---

# 16. Legacy migration

P2.4 remains legacy runtime authority until V2 implementation.

V2 migration direction:
- preserve old Sword/Body/Spell history as historical seed data where sensible;
- stop using old bounded path depth to grant generic combat/cultivation bonuses;
- derive an initial active path/Đạo Lịch mapping deterministically;
- never erase old mixed-history information.

---

# 17. Locked summary

1. Three base paths: Kiếm / Thể / Pháp.
2. Start Chưa Định Đạo.
3. No class level or generic class stat growth.
4. Branches: Ngự/Sát/Hộ; Bá/Kim Cương/Huyết; Ngũ Hành/Y Đạo/Huyền Pháp.
5. Only one active path/branch.
6. Switching preserves all knowledge/mastery/history.
7. Đạo Lịch is meaningful history, not a stat buff.
8. Định Đạo is deterministic and technique-guided.
9. Diễn Đạo requires real progression/history.
10. Multiple branches may be historically unlocked.
11. No universal path-specific combat resource.
