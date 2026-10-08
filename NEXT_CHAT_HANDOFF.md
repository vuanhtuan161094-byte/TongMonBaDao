# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-08

## Read first

1. `AGENTS.md`
2. `docs/GAME_SYSTEM_ARCHITECTURE.md`
3. `CURRENT_CHECKPOINT.md`
4. `docs/DISCIPLE_MASTER_SCHEMA.md`
5. `docs/DISCIPLE_V2_DESIGN_LEDGER.md`
6. `docs/DISCIPLE_V2_ROADMAP.md`
7. `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`
8. `docs/SPIRITUAL_ROOT_V2_SPEC.md`
9. `docs/COMBAT_STATS_V2_SPEC.md`
10. `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`
11. `docs/TRAITS_V2_SPEC.md`
12. `docs/DESTINY_V2_SPEC.md`
13. `docs/BLOODLINE_V2_SPEC.md`
14. `docs/REALM_LADDER_V2_SPEC.md`
15. `docs/BODY_CULTIVATION_V2_SPEC.md`
16. `docs/PHYSIQUE_V2_SPEC.md`
17. `docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md`
18. `docs/TECHNIQUE_V2_SPEC.md`
19. `docs/CULTIVATION_PATH_V2_SPEC.md`
20. `docs/COMBAT_SKILLS_V2_SPEC.md`
21. `docs/WEAPON_EQUIPMENT_V2_SPEC.md` — current **10 ordinary slots + 12 grades + 6/2/1 lines + sect-owned**; DESIGN ONLY;
22. `docs/EQUIPMENT_SETS_V2_SPEC.md` — **24 families, 2/3/4 bonuses and 3+3 coexistence**; DESIGN ONLY;
23. `docs/WEAPON_EQUIPMENT_V2_REALM_MAP_SET_MATRIX.md` — map/realm source projection only (no older 5-slot/set rules);
22. current equipment/loadout/crafting code and relevant legacy specs before continuing Weapon + Equipment V2.

Fetch live `main` before edits.
Do not ask the user to restate decisions that exist in these authorities.

---

## Current implementation status

**No implementation phase is active.**

The last backend-closed implementation remains:
P3.7C1 — Open-point Lục Duy + Dẫn Tiên Đài.

Godot 4.7.2 CI closing evidence remains recorded in `CURRENT_CHECKPOINT.md`.

All V2 systems named below are design authorities only unless the checkpoint explicitly says otherwise.

---

## Disciple V2 design status

Design-closed:
- Spiritual Root / Ngũ Hành / Dị Linh Căn;
- Combat Stats;
- Disciple Characteristic Framework;
- Traits;
- Mệnh Cách;
- Bloodline;
- Realm Ladder;
- Luyện Thể core + Expedition Stamina;
- Physique base;
- Cultivation + Breakthrough;
- Công Pháp;
- Chủ Đạo / Đạo Lịch;
- Combat Skills;
- Kiếm Tu / Thể Tu / Pháp Tu combat language;
- three-wave Nhân → Tiên → Thần skill evolution.

Do not reopen those systems unless:
- a concrete contradiction is discovered; or
- the user explicitly changes a decision.

---

## Key new skill/path laws to preserve

### Công Pháp
- 1 Chủ Tu + 2 Phụ Tu active;
- inactive learned techniques keep mastery/history but ordinary effects are inactive;
- Tàng Kinh Các transmission is permanent after first archived full manual;
- personal mastery and Sect Nghiên Tu are separate;
- Diễn Hóa creates authored named successors.

### Chủ Đạo
- Chưa Định Đạo → Kiếm / Thể / Pháp;
- no class level;
- no generic class-stat growth;
- Đạo Lịch is lived history, not a free stat multiplier;
- active branches:
  - Kiếm: Ngự / Sát / Hộ;
  - Thể: Bá / Kim Cương / Huyết;
  - Pháp: Ngũ Hành / Y Đạo / Huyền Pháp;
- switching preserves learned content/mastery/history.

### Combat Skills
- mature loadout = 1 Thường + 4 Active + 6 Combat Passive;
- static self passives do not require combat slots;
- triggered/party passives do;
- Nhân Giới learns/opens the full foundational combat language;
- Tiên Giới evolves those families;
- Thần Giới evolves them again with bounded rule-changing effects;
- skill family successor replaces predecessor as active family source;
- skill basis = Tu Vi / Luyện Thể / Hybrid;
- AI = priority 1→4 + skill-specific validity;
- movement uses simple range profiles;
- no universal Mana/Rage/Kiếm Ý resource;
- Ngũ Hành and Tương Sinh are shared skill layers;
- effect tiers Nhân/Tiên/Thần protect control/cleanse/dispel/rule-changing interactions;
- party max 6;
- cluster max 30;
- 0 HP = Bị Hạ;
- monsters/bosses share the same combat primitives.

### Kiếm Cốt dependency
Combat Skills V2 has now defined:
- sword style tag direction;
- weapon requirement separation;
- cast/source/hit attribution.

Kiếm Cốt is **still blocked** until Weapon + Equipment V2 defines:
- canonical weapon types;
- sword equip semantics;
- weapon-requirement checks;
- whether any weapon mastery exists.

Do not enable Kiếm Cốt effectless.

---

## Current design subject

# Weapon + Equipment V2

This is DESIGN ONLY unless the user explicitly authorizes implementation.

**User-approved Equipment/Set V2 structure 2026-10-08:**
- **10 ordinary slots** Vũ Khí/Mũ/Giáp/Phi Phong/Hộ Uyển/Thủ Sáo/Đai/Giày/Ngọc Bội/Nhẫn. Separate 3 Phù + 2 Pháp Bảo + 4 consumables. Old five-ordinary = OBSOLETE.
- 12 quality grades, at Chí Tôn **6 ordinary stat lines + 2 rare special-stat lines + 1 individual Chân Văn slot**. Normal lines do not produce autonomous action; rare special lines are conditional existing-channel stats; Chân Văn alone owns rule/event mechanics. Each ordinary item max two broad general lines, slot-specific pools and valid profession lines.
- **18 combat + 6 profession sets**, each four positions from Mũ/Giáp/Phi Phong/Hộ Uyển/Đai/Giày. 2/3/4 **cumulative stats**, 3+3 **both** three-piece bonuses active, no Chân Văn Cộng Hưởng, no new ability auto-spawned by a set.
- Nhân/Tiên/Thần versions keep family role; gear power and specialization rise by tier; Hỗn Độn Thần-only. 100% gear belongs to the Sect; disciples only assigned use.
- **OPEN**: item numerical power, % caps, enhancement cap, cost, crafting/loot/materials, full Chân Văn registry, actual Godot V2 implementation. Earlier provisional +15 is not approved final.
- 1 map = 10 specialty clusters accepted; **one primary map per each of 30 realms is still a content proposal requiring separate approval**, NOT a final source gate.

Before proposing:
1. read current equipment state and legacy authority;
2. preserve the existing 10-slot direction unless a concrete contradiction appears;
3. consume Combat Stats V2 channels rather than invent parallel stats;
4. consume Combat Skills V2 `style_tag` / `weapon_requirement` contract;
5. retain weapon equip/style and skill requirement rules, while Kiếm Cốt measurable effect remains OPEN;
6. preserve canonical warehouse/hunting/crafting authorities;
7. do not create weapon mastery merely because another game has it.

The design should explicitly decide:
- weapon types for Kiếm / Thể / Pháp and weaponless cases;
- 10 equipment slots and equip legality;
- grade / realm / rarity / quality semantics;
- base stats and substats;
- enhancement / refinement / forging;
- elemental equipment;
- set bonuses, if any;
- durability, keep/remove/reshape;
- binding/locking/trade;
- loot/crafting/market sources;
- Nhân → Tiên → Thần equipment progression;
- interaction with skill requirements;
- interaction with Root/Bloodline/Physique/Trait/Mệnh;
- large-roster auto-equip/template policy;
- persistence and deterministic generation;
- migration from current equipment authority.

---

## Remaining design order after Weapon + Equipment

Preferred queue:
1. Pháp Bảo + Phù V2;
2. Profession V2 final consolidation;
3. Living State V2 — Injury / recovery / age / lifespan;
4. Mood / Loyalty / Needs;
5. Personality + autonomy + goals/memories;
6. Relationships / Social V2;
7. Sư đồ / Đạo lữ / organization roles;
8. Family/inheritance if enabled;
9. Whole Disciple Generation V2 final assembly;
10. whole-disciple contradiction/dead-stat audit;
11. implementation dependency plan.

Do not begin implementation just because design is closed.

## Legacy design-document cleanup — 2026-10-08

Superseded legacy design Markdown files for Cultivation/Root/Công Pháp/Path/Combat Skills/Generation/Traits/Bloodline/Physique have been intentionally deleted from the repository.

Legacy runtime code, factories, tests and gates remain until their explicit V2 implementation/migration phases because they still protect regression and old-save compatibility.

Do not recreate or consult deleted legacy design specs as authority.
