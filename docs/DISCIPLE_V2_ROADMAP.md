# DISCIPLE V2 ROADMAP — TÔNG MÔN BÁ ĐẠO

Status: DESIGN ROADMAP — NOT AN IMPLEMENTATION STATUS LOG  
Updated: 2026-10-08

Read with:
- `docs/DISCIPLE_MASTER_SCHEMA.md`
- `docs/DISCIPLE_V2_DESIGN_LEDGER.md`
- `CURRENT_CHECKPOINT.md`
- the active phase spec, if any.

This file answers: **the disciple system still contains what, in what order should we discuss it, and which parts are already locked vs still need design.**

Current implementation status still belongs only to `CURRENT_CHECKPOINT.md`.

---

# 1. Player fantasy that all disciple work must preserve

A disciple is not a disposable rarity card.

The player must be able to:
- recruit a weak person;
- keep investing for a very long time;
- improve every meaningful growth axis through explicit resources/content;
- eventually build one absurdly strong “full everything” disciple if enough time/resources are spent.

Birth determines:
- starting point;
- specialization;
- rarity of the initial person;
- how much time/resource is saved.

Birth does **not** permanently own the final ceiling.

No subsystem may silently introduce a permanent hard cap that contradicts this fantasy unless a later explicit user decision changes it.

---

# 2. Complete disciple system map

## A. Identity / innate layers

| Layer | Purpose | Current design status |
|---|---|---|
| Identity | ID, name, sex, race, origin, source, profile seed | Existing authority |
| Six foundations | Tư Chất, Căn Cốt, Cơ Duyên, Thông Tuệ, Mị Lực, Tiềm Lực | **P3.7C1 locked** |
| Disciple quality | Derived from current total six foundations | **P3.7C1 locked** |
| Personality | Core personality + risk/spend/survival tendencies | Existing but still shallow |
| Spiritual Root | elements/count/purity/base buffs/resonance/mutation | **FULL V2 DESIGN LOCKED — NOT IMPLEMENTED** |
| Profession talent | innate learning talent per profession | Existing partial |
| Traits | visible/negative/latent/acquired traits | Existing partial; needs V2 review |
| Mệnh Cách / special destiny identity | rare rule-changing identity such as Yêu Nghiệt / Luân Hồi-type concepts | **FULL V2 DESIGN LOCKED — NOT IMPLEMENTED** |
| Bloodline | lineage/purity/reveal/awakening/refinement/grant/fusion | **FULL V2 DESIGN LOCKED — NOT IMPLEMENTED** |
| Physique | body grade + special physique + body progression | Existing partial; needs V2 review |
| Thiên Mệnh / very rare fate layer | merged into canonical Mệnh Cách V2 | **MERGED — do not build separately** |

## B. Personal progression

| Layer | Purpose | Status |
|---|---|---|
| Cultivation / Realm | Tu Vi, realm, breakthrough | **FULL V2 DESIGN LOCKED — NOT IMPLEMENTED** |
| Body Training / Luyện Thể | body XP/progression and permanent physical growth | Needs full V2 authority |
| Technique learning | learn techniques, mastery, active loadout | **FULL V2 DESIGN LOCKED — NOT IMPLEMENTED** |
| Combat skills | learned skills / mastery / loadout / AI | **FULL V2 DESIGN LOCKED — NOT IMPLEMENTED** |
| Path history | active Chủ Đạo / branch / Đạo Lịch | **FULL V2 DESIGN LOCKED — NOT IMPLEMENTED** |
| Profession XP | herbalism/mining/forging/alchemy/logistics/etc | Existing partial |
| Equipment | 10 ordinary slots + 3 Phù + 2 Pháp Bảo; 2/3/4 set V2 | **STRUCTURE DESIGN LOCKED — NOT IMPLEMENTED** |
| Pháp Bảo / inheritance | long-term rare equipment/mastery layer | Future |
| Permanent consumables | pills, treasures, roots/bloodline/physique/foundation improvement | Needs unified content rules |

## C. Derived combat authority

Future final combat character should derive, not roll, values such as:
- HP;
- Attack;
- Defense;
- movement speed;
- attack speed;
- cast time;
- cooldown;
- crit / crit damage;
- anti-crit / crit reduction;
- effect hit / resistance;
- physical/magical or equivalent damage modifiers;
- healing/shield/dodge/penetration where actual combat design requires them;
- Combat Rating as a **displayed derived estimate**, never an identity roll.

Tiềm Lực must plug into the canonical Realm + Luyện Thể ATK/DEF/HP growth component retroactively when this authority is built.

## D. Living-person systems

Still part of a disciple:
- HP;
- stamina;
- injury;
- mood;
- loyalty;
- needs;
- memories;
- personal goals;
- work preferences;
- current action/location;
- life events.

These should create autonomous stories, not replace the player's strategic control.

## E. Social / organization systems

Still part of disciple architecture:
- relationships;
- friend/enemy;
- Dao Companion;
- master-disciple / sư đồ;
- family/kinship if later added;
- sect rank;
- elder positions;
- work group;
- combat team;
- Dẫn Tiên guide role;
- direct Sect Master orders.

Mị Lực is the canonical social-power input; individual systems may add resistance/context but must not invent a second charisma stat.

---

# 3. Proposed discussion / implementation order

This is the preferred order to reduce rework. It is a **queue**, not permission to auto-start code.

## Spiritual Root V2 — DESIGN CLOSED

Canonical authority:
`docs/SPIRITUAL_ROOT_V2_SPEC.md`

Full design now locked:
- five base roots;
- 1–5 root birth distribution;
- independent purity 1–100;
- base cultivation/mastery/combat buffs;
- base-element permanent passives;
- 1/2/3/4/5 perfected-root Resonance;
- elemental counter core;
- deterministic Linh-Tủy refinement;
- expensive post-birth missing-root creation;
- 0.20% congenital mutation model;
- Lôi/Phong/Băng/Dương/U Minh V1;
- Thức Tỉnh → Thuế Biến → Viên Mãn mutation growth and five matching Bản Nguyên resources;
- mutation combat timing/proc/AoE/multi-hit/basic-attack/boss/team/AI rules;
- all five mutations may coexist;
- cả năm Dị Căn Viên Mãn -> Ngũ Dị Quy Nhất;
- persistence/migration/test invariants.

Implementation is **not authorized**.

Important dependency:
mutation combat requires parts of Skills/Combat Stats V2 (advanced element tags, cast/source identity, Crit, Effect Hit/Resistance, source-owned DoT, control refractory, lethal interception and final stat channels).
When implementation is eventually scheduled, do not fabricate temporary root-only stats. Bring required primitives into the active phase or defer mutation combat activation until the proper combat phase.

## Combat Stats V2 — DESIGN CLOSED

Canonical authority:
`docs/COMBAT_STATS_V2_SPEC.md`

Locked:
- core HP/Attack/Defense;
- four separate realtime timing stats;
- Crit/Crit Damage/Crit Resistance;
- Defense Penetration;
- Effect Hit/Resistance;
- Damage Reduction;
- keyed elemental resistance;
- no generic Speed, Accuracy/Dodge, physical/magical split, universal mana or Combat Power authority.

Implementation remains future work.

## Disciple Characteristics & Stat Framework V2 — DESIGN CLOSED

Canonical authority:
`docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`

Locked:
- persistent source -> runtime state -> derived channel -> contextual outcome architecture;
- six Lục Duy remain the only general permanent foundation stat block;
- Personality is behavioral/AI authority, separate from Trait;
- learned progression remains subsystem-owned;
- living state uses HP / Thể Lực / Thương Thế / Tâm Trạng / Trung Thành / Age-Lifespan;
- Combat Stats V2 plugs into this framework;
- canonical specialized channels include Healing Done / Healing Received / Shield Effect / DoT / Skill Effect / Control Duration / tagged modifiers;
- modifier modes and source-breakdown/provenance are mandatory;
- derived stats may be cached but are not save truth;
- large-roster simulation computes only needed channels.

Implementation remains future work.

## Traits V2 — DESIGN CLOSED

Canonical authority:
`docs/TRAITS_V2_SPEC.md`

Locked:
- birth-visible / latent / acquired / removed-overcome states;
- Hữu Ích / Bất Lợi / Song Diện;
- no universal Grade 1–5;
- ordinary birth-visible count 1/2/3 = 60/32/8%;
- ordinary latent rate = 8%, max one;
- visible nature weights = 50/30/20%;
- independence from Disciple Quality/Dẫn Tiên/Root;
- explicit conflicts + hidden-latent suppression;
- no lifetime Trait cap;
- deterministic reveal/acquisition/removal;
- no generic removal fail chance;
- Personality/profession talent kept separate;
- consumer-readiness gating;
- legacy trait-grade/combat-power authority retired.

Implementation remains future work.

## Mệnh Cách V2 — DESIGN CLOSED

Canonical authority:
`docs/DESTINY_V2_SPEC.md`

Status:
**DESIGN LOCKED — NOT IMPLEMENTED**

Redesigned proposal:
- merge old generic Thiên Mệnh terminology into one Mệnh Cách authority;
- multiple compatible Mệnh Cách may coexist and all are active;
- no Chủ-Mệnh slot and no lifetime hard cap;
- congenital rate = **0.50% total (0.45% latent + 0.05% revealed)**, max one ordinary birth fate;
- no generic color/grade;
- no universal Khai/Hóa/Chứng ladder;
- each fate is strongly useful immediately after reveal;
- fate-specific counters/evolution only where meaningful;
- rare canonical Mệnh Nguyên resource;
- each post-birth fate has an explicit feat/event + resource recipe;
- Mệnh Cục gives derived bonuses for specific fate combinations;
- effects are intentionally much stronger and clearer than Traits;
- long-term favorite disciple may eventually collect many compatible fates.

## Bloodline V2 — DESIGN CLOSED

Canonical authority:
`docs/BLOODLINE_V2_SPEC.md`

Locked:
- 2.00% ordinary congenital rate: 1.60% latent + 0.40% revealed;
- ordinary birth max one congenital special lineage;
- integer purity 1–100;
- Chân Huyết at awakened purity >=50;
- Phản Tổ at awakened purity 100;
- five redesigned initial lineages with distinct build identities;
- deterministic +1 refinement with increasing material cost;
- Huyết Tinh / Tổ Huyết / lineage-specific Huyết Nguyên;
- no universal lifetime Bloodline cap;
- Ban Huyết / Hoán Huyết / explicit Dung Huyết;
- explicit compatibility/conflict data;
- significant-history retroactive reveal;
- inheritance architecture reserved while exact family formula is deferred;
- future founder-created Bloodline hook;
- P2.11 becomes compatibility/migration only.

Implementation remains future work.

## Realm Ladder V2 + Luyện Thể V2 core — DESIGN CLOSED

Canonical authorities:
- `docs/REALM_LADDER_V2_SPEC.md`;
- `docs/BODY_CULTIVATION_V2_SPEC.md`.

Locked:
- Tu Vi 30×10 and Luyện Thể 30×10;
- 3 macro bands of 10 realms: Nhân / Tiên / Thần;
- separate 1..300 global-floor coordinates;
- Luyện Thể Body Core direction = HP > Defense > Attack;
- Căn Cốt owns natural/base body-XP speed;
- Tiềm Lực applies retroactively to Realm+Body Core;
- Thể Lực is external-map expedition endurance only;
- no ordinary production stamina;
- daily base 100;
- normal map exact floor match ~18h;
- +10 floors ≈×1.20 duration;
- body-only cap 22h;
- ordinary final expedition cap 24h after preparation buffs;
- recommended body floor is a soft endurance target, not a hard map-entry gate.

Implementation remains future work.
Exact XP/stat/resource curves remain balance work.

## Physique / Thể Chất V2 — BASE DESIGN CLOSED

Canonical authority:
`docs/PHYSIQUE_V2_SPEC.md`

Locked:
- no V2 physique grade/purity/temper;
- ordinary congenital = 97.00% none / 2.70% revealed / 0.30% latent;
- one active Core Physique;
- 15 weighted base identities;
- 14 base effect sets use existing canonical channels;
- Kiếm Cốt identity is locked but effect is blocked by explicit Weapon/Skill dependency and cannot be enabled effectless;
- deterministic Cải Thể / Tái Tạo / Tiến Hóa / Dung Thể architecture;
- no generic fusion blender and no predecessor-effect stacking;
- Physique history/provenance persists;
- P2.12 is compatibility/migration only.

Open future content:
- Kiếm Cốt effect after Weapon/Skill V2;
- exact transformation recipes/resources;
- exact advanced evolution branches;
- Dung Thể V1 result roster;
- per-type latent reveal triggers;
- runtime implementation.

## Cultivation + Breakthrough V2 — DESIGN CLOSED

Canonical authority:
`docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md`

Locked:
- 30×10 Tu Vi ladder consumption;
- minor floors auto-advance without RNG;
- only major-realm transitions use breakthrough chance;
- default failure loses 10% gate requirement;
- same-gate failure gives +5 percentage points next attempt;
- max 3 breakthrough consumables;
- auto-breakthrough support;
- no generic HP/Stamina/cooldown consequence;
- no generic Tư Chất/Căn Cốt/Cơ Duyên/Root/Physique breakthrough chance;
- Tích Tu / Hậu Tích, Hồng Trần Luyện Tâm and Đại Khí Vãn Thành contracts.

Implementation remains future work.

## Công Pháp V2 — DESIGN CLOSED

Canonical authority:
`docs/TECHNIQUE_V2_SPEC.md`

Locked:
- Công Pháp and Kỹ Năng are separate;
- 1 Chủ Tu + 2 Phụ Tu active;
- learned inactive techniques keep mastery/history but ordinary effects are inactive;
- first archived full manual unlocks Sect transmission;
- personal mastery Sơ Học → Nhập Môn → Tiểu Thành → Đại Thành → Viên Mãn;
- Sect Nghiên Tu separate from personal mastery;
- authored Diễn Hóa successors/branches;
- personal discovery + Khắc Lục;
- technique-skill relation = independent / synergy / prerequisite.

Implementation remains future work.

## Chủ Đạo / Cultivation Path V2 — DESIGN CLOSED

Canonical authority:
`docs/CULTIVATION_PATH_V2_SPEC.md`

Locked:
- Chưa Định Đạo → Kiếm / Thể / Pháp;
- branches Ngự/Sát/Hộ, Bá/Kim Cương/Huyết, Ngũ Hành/Y Đạo/Huyền Pháp;
- no class level;
- no generic class-stat growth;
- Đạo Lịch is lived history, not a generic stat multiplier;
- deterministic Định Đạo / Diễn Đạo;
- path/branch switching preserves knowledge/mastery/history;
- only one active path/branch.

Implementation remains future work.

## Kỹ Năng Chiến Đấu V2 — DESIGN CLOSED

Canonical authority:
`docs/COMBAT_SKILLS_V2_SPEC.md`

Locked:
- mature loadout = 1 Thường + 4 Active + 6 Combat Passive;
- slots open gradually through Nhân Giới;
- three skill waves: Nhân foundation → Tiên evolution → Thần evolution;
- skill families use named successors, not +level feeding;
- mastery has five milestones and valid-use anti-farm;
- Tu Vi / Luyện Thể / Hybrid skill basis;
- simple priority AI 1→4 plus per-skill validity;
- simple combat-distance profiles;
- cooldown/cast/projectile/ICD separation;
- explicit buff/debuff/shield stacking;
- Nhân/Tiên/Thần effect tier for hard control/cleanse/dispel/rule effects;
- Ngũ Hành + Tương Sinh skill framework;
- party max 6, cluster max 30;
- 0 HP = Bị Hạ;
- monsters/bosses share the same combat primitives;
- Kiếm/Thể/Pháp base languages and branches are closed.

Implementation remains future work.

## Weapon + Equipment V2 — STRUCTURE DESIGN LOCKED, NOT IMPLEMENTED

Canonical `docs/WEAPON_EQUIPMENT_V2_SPEC.md` and `docs/EQUIPMENT_SETS_V2_SPEC.md` replace older 5 ordinary/2–3-only set directions. User-approved 2026-10-08: 10 ordinary slots, 12 grades, max 6 ordinary + 2 rare stat + 1 individual Chân Văn, distinct slot pools, 24 families of four pieces in six eligible positions, cumulative 2/3/4 set bonuses and both 3-piece bonuses for 3+3. Sets use stat identity, do **not** auto-generate any Chân Văn Cộng Hưởng. Work equipment permitted only with real consumer. Ownership fully Sect.

Still OPEN: full numbers/RealmBodyCore, individual Chân Văn catalog, forging/reroll/inheritance, enhancement cap, recipes, loot pools and Godot runtime/tests. 30-main-map projected content count needs separate confirmation.

## After Weapon + Equipment V2

Preferred design order:
1. Pháp Bảo + Phù V2;
2. Profession V2 final consolidation;
3. Living State V2 — Injury / recovery / age / lifespan consequences;
4. Mood / Loyalty / Needs;
5. Personality + autonomy + goals/memories;
6. Relationships / social V2;
7. Sư đồ / Đạo lữ / organization roles;
8. Family/inheritance if enabled;
9. Whole Disciple Generation V2 final assembly;
10. whole-disciple contradiction/dead-stat audit;
11. implementation dependency plan.

Combat Stats implementation remains deferred until the design sweep is complete.

---

# 4. Recruitment / generation relation to this roadmap

Dẫn Tiên ordinary recruitment is already one whole-person generator authority.

When a new innate layer becomes canonical:
- it must be generated as part of the same person;
- same seed/source/index must remain the same person;
- hidden values must exist before reveal;
- reveal must not reroll;
- a low quality label may still hide a valuable Root/Bloodline/Physique/Trait combination.

Do not turn each innate layer into a separate character gacha.

Separate future **item/inheritance gacha** may grant transformation resources, but it changes an existing person explicitly rather than silently rerolling them.

---

# 5. What is not allowed to regress

Do not reintroduce:
- hard permanent final caps on the six foundations;
- “bad birth can never catch up” as a global rule;
- one rarity color deciding the entire person's value;
- fixed class;
- combat power as an independent birth roll;
- hidden rerolls during reveal;
- Mị Lực or Cơ Duyên as generic +% to everything;
- multiplicative chains that accidentally explode the same progression channel;
- item text saying +X but secretly applying a foundation multiplier unless the item explicitly says so.

---

# 6. Next-chat instruction

The following Disciple V2 authorities are design-closed:
- Spiritual Root / Dị Linh Căn;
- Combat Stats;
- Characteristic Framework;
- Traits;
- Mệnh Cách;
- Bloodline;
- Realm Ladder + Luyện Thể core;
- Physique base;
- Cultivation + Breakthrough;
- Công Pháp;
- Chủ Đạo / Đạo Lịch;
- Combat Skills including Kiếm / Thể / Pháp and Nhân → Tiên → Thần evolution.

Weapon + Equipment V2 **design structure was approved and stored**. Continue unfinished forging/balance/Chân Văn details or move to Phù+Pháp Bảo only when user asks.

Before proposing Weapon/Equipment rules:
1. fetch live `main`;
2. read `AGENTS.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`;
3. read this roadmap and the four newly closed authorities;
4. read current equipment/loadout code/specs;
5. preserve the existing 10-slot equipment direction unless a concrete contradiction is found;
6. close the remaining Weapon side of the Kiếm Cốt dependency;
7. do not implement unless the user explicitly starts an implementation phase.

Do not reopen a locked V2 subsystem without a concrete contradiction or explicit user change.
