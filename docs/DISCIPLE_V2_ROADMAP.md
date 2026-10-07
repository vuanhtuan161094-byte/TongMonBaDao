# DISCIPLE V2 ROADMAP — TÔNG MÔN BÁ ĐẠO

Status: DESIGN ROADMAP — NOT AN IMPLEMENTATION STATUS LOG  
Updated: 2026-10-07

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
| Spiritual Root | elements/count/purity/base buffs/resonance/mutation | **BASE V2 LOCKED; MUTATION NEXT** |
| Profession talent | innate learning talent per profession | Existing partial |
| Traits | visible/negative/latent/acquired traits | Existing partial; needs V2 review |
| Mệnh Cách / special destiny identity | rare rule-changing identity such as Yêu Nghiệt / Luân Hồi-type concepts | Design needed |
| Bloodline | presence/type/purity/reveal/awakening | Existing partial; needs V2 review |
| Physique | body grade + special physique + body progression | Existing partial; needs V2 review |
| Thiên Mệnh / very rare fate layer | latent rare branch-changing identity | Future design |

## B. Personal progression

| Layer | Purpose | Status |
|---|---|---|
| Cultivation / Realm | Tu Vi, realm, breakthrough | Existing legacy; V2 rules partly locked, migration needed later |
| Body Training / Luyện Thể | body XP/progression and permanent physical growth | Needs full V2 authority |
| Technique learning | learn techniques, mastery, active paths | Existing partial |
| Combat skills | learned skills / mastery | Existing partial |
| Path history | Kiếm / Thể / Pháp identity from actual progression | Existing partial |
| Profession XP | herbalism/mining/forging/alchemy/logistics/etc | Existing partial |
| Equipment | 10-slot equipment/loadout authority | Existing |
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
- Stage I/II/III mutation growth and five matching Bản Nguyên resources;
- mutation combat timing/proc/AoE/multi-hit/basic-attack/boss/team/AI rules;
- all five mutations may coexist;
- full five Stage III -> Ngũ Dị Quy Nhất;
- persistence/migration/test invariants.

Implementation is **not authorized**.

Important dependency:
mutation combat requires parts of Skills/Combat Stats V2 (advanced element tags, cast/source identity, Crit, Effect Hit/Resistance, source-owned DoT, control refractory, lethal interception and final stat channels).
When implementation is eventually scheduled, do not fabricate temporary root-only stats. Bring required primitives into the active phase or defer mutation combat activation until the proper combat phase.

## Then: Mệnh Cách + Traits V2

Need separate clearly:
- personality;
- visible trait;
- negative trait;
- latent trait;
- acquired trait;
- rare Mệnh Cách / reincarnation / monster-genius identity.

Rule-changing effects are preferred over every rare trait merely adding Attack.

## Then: Bloodline V2

Need decide:
- birth rate;
- type;
- purity;
- hidden/revealed;
- awakening;
- inheritance/refinement;
- bloodline-granting items;
- replacement/fusion rules.

## Then: Physique + Luyện Thể V2

Need decide together because they strongly interact:
- Phàm/Linh/Huyền/Thánh/Thần body grade;
- special physique identity;
- body-training XP;
- permanent ATK/DEF/HP growth;
- Căn Cốt speed;
- Tiềm Lực retroactive growth multiplier;
- physique transformation resources.

## Then: Cultivation + Breakthrough V2

Migrate legacy cultivation to the user-approved simple rules while preserving deterministic runtime.

## Then: Techniques / skills / mastery V2

Thong Tuệ must be the common learning/mastery input.
No fixed class.

## Then: final Combat Stats V2

Replace old shallow `combat_power` authority with real Attack/Defense/HP + secondary stats and derived Combat Rating.

## Then: Profession / life / social expansion

Finish:
- profession content breadth;
- relationships;
- Dao Companion;
- sư đồ;
- loyalty/mood/injury;
- long-life/Ma-Hồn/revival interaction;
- large-roster policy tools.

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

The next design conversation should start with **Spiritual Root V2**.

Before proposing rules:
1. read `docs/DISCIPLE_MASTER_SCHEMA.md`;
2. read `docs/DISCIPLE_V2_DESIGN_LEDGER.md`;
3. read this roadmap;
4. read `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`;
5. inspect live existing Spiritual Root / root-refinement code;
6. compare useful ideas from 《最强祖师》 without copying its assets/text/map or blindly importing its balance.

Do not implement Spiritual Root V2 until the user explicitly locks the design and authorizes code.
