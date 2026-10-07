# TRAITS / ĐẶC CHẤT V2 — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-07
Status: **DESIGN DRAFT FOR USER REVIEW — NOT IMPLEMENTED — NOT LOCKED**

Parents:
- `docs/GAME_SYSTEM_ARCHITECTURE.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`
- `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`
- `docs/COMBAT_STATS_V2_SPEC.md`
- `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`

Related but separate future authorities:
- Personality V2;
- Mệnh Cách V2;
- Bloodline V2;
- Physique + Luyện Thể V2;
- profession talents.

This document designs **Trait / Đặc Chất only**.

No gameplay implementation is authorized by this draft.

---

# 1. What Trait means in this project

A **Trait / Đặc Chất** is a persistent personal characteristic that:

- changes one or more registered gameplay channels;
- changes an AI/context rule;
- or introduces a specific triggered mechanic.

Trait is **not**:

- Personality;
- Lục Duy;
- Linh Căn / Dị Linh Căn;
- Mệnh Cách;
- Huyết Mạch;
- Thể Chất;
- profession talent;
- realm/progression;
- injury;
- temporary buff/debuff.

Every active Trait must have a real gameplay consequence.

Pure flavor belongs in personality/history/background rather than occupying a gameplay Trait slot.

---

# 2. Reference lessons adapted

## 2.1 《最强祖师》

Useful reference lessons:

- disciple identity is richer when "traits" affect cultivation, production, learning and combat rather than only raw combat power;
- negative quirks can be strategically harmless or even useful in the right role;
- talents/quirks can be forgotten through an explicit facility/process;
- a low headline-quality disciple may still be valuable because of the rest of the character package.

Project adaptation:

- keep positive / negative / tradeoff Trait identities;
- allow deliberate removal/reshaping after recruitment;
- do **not** group Root / Physique / Destiny into Trait because this project already has separate authorities for them;
- do **not** make Trait directly rewrite permanent Lục Duy merely to imitate a reference game's colored entry.

## 2.2 RimWorld

Useful lessons:

- 1–3 traits is enough to make ordinary people visibly different;
- traits can be helpful, harmful or situational;
- explicit conflict rules prevent nonsensical combinations;
- some traits alter behavior or rules rather than only adding a stat.

Project adaptation:

- ordinary birth has a small visible Trait set;
- conflicts are definition data;
- no generic "all positive is good, all negative is trash" assumption.

## 2.3 Oxygen Not Included

Useful lesson:

- Traits and Interests/Skills are different.
- A trait may modify work capability, while an Interest changes learning affinity.

Project adaptation:

- profession talent remains separate from Trait;
- `forge_talent` / `miner_instinct` are profession-talent identity, not generic Trait V2;
- Cần Mẫn / Lười Nhác / Cẩu Thả may remain generic work-behavior Traits because they affect how the person works across professions.

## 2.4 Dwarf Fortress

Useful lesson:

- Personality can shape behavior and preferences independently from attributes/skills.

Project adaptation:

- "Gan Dạ / Nhát Chiến" style behavioral identity belongs primarily to Personality V2;
- do not duplicate the same behavioral axis as a Trait plus a personality bias.

## 2.5 Amazing Cultivation Simulator

Useful lesson:

- backgrounds/features can supply meaningful modifiers without replacing core attributes.

Project adaptation:

- Trait is a source layer feeding shared canonical channels;
- it must not invent a private second Attack/Defense/Cultivation formula.

---

# 3. Core Trait taxonomy

Trait has two independent classifications.

## 3.1 Origin/state

### A. Bẩm Sinh Hiển Lộ
Generated with the person and visible immediately.

### B. Bẩm Sinh Tiềm Ẩn
Generated with the person but:
- hidden from the player;
- inactive before reveal;
- never rerolled;
- reveals deterministically when its own condition is met or a future explicit appraisal mechanic reveals it.

### C. Hậu Thiên
Not part of the birth roll.
Added later through:
- lived experience;
- milestone;
- targeted training;
- special event;
- explicit transformation content.

Hậu Thiên is a legitimate new Trait, not a reroll of a hidden birth Trait.

### D. Đã Khắc Phục / Đã Loại Bỏ
Trait history remains recorded, but the Trait is no longer active.

A removed Trait may later be reacquired if its acquisition rule allows it.

---

## 3.2 Effect nature

### Hữu Ích
Primarily beneficial.

### Bất Lợi
Primarily harmful.

### Song Diện
Has a real upside and downside or changes role suitability.

Song Diện is important.
Do not turn every interesting quirk into either "+stat" or "-stat".

---

# 4. No generic Trait grade

Trait V2 does **not** use a universal Grade 1–5 system.

Reasons:
- the same named characteristic should mean the same thing;
- profession talent already owns graded learning affinity;
- random Trait grades make a character sheet harder to read;
- generic grades encourage every Trait to become a flat numeric ladder.

If a future Trait genuinely evolves, use explicit named transformation data.

Example direction:
- `Kinh Mạch Ổn Định`
may someday transform into
- `Kinh Mạch Thông Suốt`

only if that exact progression is designed.

Do not label generic Trait growth as I / II / III.

Legacy P2 Trait grades become migration-only data when V2 is implemented.

---

# 5. Birth generation

## 5.1 Visible Trait count

Ordinary whole-person generation:

| Visible birth Traits | Probability |
|---:|---:|
| 1 | 60% |
| 2 | 32% |
| 3 | 8% |

Every ordinary generated person therefore starts with at least one visible Trait.

Reason:
- one small Trait set creates identity even before later systems mature;
- 1–3 remains readable at 1,000–3,000 population scale.

This is a birth-count distribution, **not a lifetime Trait cap**.

## 5.2 Trait nature distribution

For each visible birth Trait slot, first select nature:

| Nature | Starting weight |
|---|---:|
| Hữu Ích | 50% |
| Song Diện | 30% |
| Bất Lợi | 20% |

Then select a weighted eligible Trait from that pool.

Exact per-Trait commonality is content data.

## 5.3 Latent Trait rate

Ordinary birth:
- 92%: no latent Trait;
- 8%: exactly one latent Trait.

Ordinary birth does not start with more than one latent Trait.

Special story/event generation may explicitly force additional latent identity.

This is not a lifetime cap.

## 5.4 Independence from Disciple Quality

Normal Trait distribution is independent from:
- Disciple Quality;
- Lục Duy total;
- Dẫn Tiên Main-Guide quality curve;
- Spiritual Root count/purity;
- congenital Dị-Căn rate.

Therefore:
- a Phàm Thường may have an excellent Trait combination;
- a Nghịch Thiên may have awkward or harmful Traits.

This preserves whole-person evaluation.

Special recruitment/event content may explicitly bias or force a Trait, but that rule must be visible content data.

---

# 6. Commonality, not power rarity

Each Trait definition has a `commonality_weight`.

This controls generation frequency.

Do **not** treat commonality as a universal power tier.

A rare Trait may be:
- unusual;
- highly specialized;
- rule-changing;
- or awkward.

A common Trait may be extremely useful for a specific job.

The main Trait UI should not encourage players to reduce every Trait to one rarity color.

---

# 7. Conflicts

Each Trait may define:
- explicit conflicting Trait IDs;
- an optional conflict group.

Examples:
- Kinh Mạch Ổn Định conflicts with Kinh Mạch Mong Manh;
- Cần Mẫn conflicts with Lười Nhác;
- Tỉ Mỉ may coexist with Cần Mẫn;
- Cẩu Thả conflicts with Tỉ Mỉ.

## 7.1 Birth generation

Birth generation never places two conflicting Traits in the same generated birth set.

## 7.2 Post-birth acquisition

If the player intentionally trains a known Trait that conflicts with an active known Trait:
- acquisition is blocked;
- UI explains the conflict;
- the player may first remove/khắc phục the conflicting Trait.

## 7.3 Hidden-latent conflict edge case

A hidden latent Trait must not leak its existence by blocking another acquisition.

Therefore:
- player may acquire a Trait that unknowingly conflicts with a hidden latent identity;
- if the latent Trait later reveals, the newly revealed Trait becomes **Hiển Lộ nhưng Bị Áp Chế**;
- suppressed Trait has no gameplay effect;
- UI states which known Trait conflicts with it;
- when conflict is removed, the suppressed Trait becomes active automatically.

No Trait is silently deleted or rerolled.

---

# 8. No lifetime hard cap

There is no permanent maximum number of Traits a disciple may eventually own.

Why:
- long-term favorite-disciple fantasy allows enormous investment;
- birth advantage should save time/resources, not impose final ceiling.

Practical control comes from:
- generation rates;
- activity prerequisites;
- time;
- training cost;
- conflicts;
- rare-event requirements;
- trait-specific acquisition rules.

The player may eventually build a disciple with many compatible positive Traits.

This is intentional.

---

# 9. Trait effect model

Normal numeric Trait effects must use the locked Characteristic/Combat registry.

Allowed effect shapes:

## 9.1 Numeric channel modifier

Example:
```
channel = "work_speed"
mode = "percent_add"
value = +0.10
```

## 9.2 Percentage-point modifier

Example:
```
channel = "crit_chance"
mode = "percentage_points"
value = +0.05
```

## 9.3 Filtered modifier

Example:
```
channel = "skill_effect"
mode = "percent_add"
value = +0.08
filters = { path = "sword" }
```

## 9.4 Context difficulty modifier

Example:
```
context = "work_rare_quality_check"
difficulty_delta = +800
```

This changes the subsystem's explicit Luck Score check.
It does not rewrite Cơ Duyên.

## 9.5 Trigger / rule change

Example:
```
when HP < 30%
  gain +10% Damage Reduction
```

Triggered Trait mechanics must:
- use stable source identity;
- avoid recursive self-proc unless explicitly allowed;
- live only in relevant runtime contexts.

---

# 10. Trait must not mutate permanent Lục Duy

Trait may improve the same downstream outcome as a Lục Duy stat.

Example:
- Tư Chất improves natural cultivation;
- Kinh Mạch Ổn Định may also add cultivation gain.

That overlap is valid.

But Trait must not silently do:
- `aptitude += 20`;
- `fortune += 15`;
- `potential += 30`

as its ordinary runtime effect.

Reasons:
- Disciple Quality derives from permanent Lục Duy;
- removing a Trait must not rewrite birth/current foundation history;
- Trait and Lục Duy need separate ownership.

If future content permanently raises Lục Duy, that is a real foundation-growth action, not a passive Trait bonus.

---

# 11. Latent reveal

Every latent Trait has its own `reveal_rule`.

Reveal is:
- event-driven;
- deterministic;
- no reroll;
- no generic random "maybe reveal today" timer.

Examples:

### Bản Năng Chiến Đấu
Possible reveal target:
- participate in 10 real combat encounters.

### Ngộ Tĩnh
Possible reveal target:
- complete 10 cultivation sessions;
- and successfully complete at least one breakthrough.

### Kiếm Cảm
Possible reveal target:
- accumulate real Sword-path experience.

A future appraisal/insight mechanic may reveal a latent Trait early, but it reveals the already-stored identity.

Before reveal:
- latent Trait has no numeric effect;
- normal roster UI does not show its ID or even need to reveal that a hidden Trait exists.

---

# 12. Post-birth Trait acquisition

Trait V2 supports two acquisition routes.

## 12.1 Life-earned acquisition

Repeated meaningful activity may eventually create a new Trait.

Examples:
- extensive work history -> Cần Mẫn;
- extensive combat history -> Bản Năng Chiến Đấu;
- sustained Sword practice -> Kiếm Cảm;
- repeated successful healing -> Dược Tâm;
- repeated recovery from serious injury -> Hồi Nguyên.

The threshold to **earn** a Trait post-birth should be much higher than the threshold to merely reveal a congenital latent Trait.

This preserves birth value without imposing a final ceiling.

## 12.2 Targeted Tu Tâm training

Future development target:
**Tu Tâm Đường** — a dedicated character-development facility/activity.

It may allow the player to:
- choose one eligible positive/neutral Trait to cultivate;
- remove/overcome a known removable Trait;
- resolve a conflict intentionally.

Training requires:
- relevant life-history prerequisite;
- real facility time;
- Sect Spirit Stones;
- optional explicit content item for especially difficult Traits.

Training is deterministic once requirements/cost are met.
No generic fail roll.

Exact building level/cost/time are later balance data.

Starting balance direction:
- common ordinary Trait: hours, not instant;
- specialized Trait: longer and needs relevant history;
- rare rule-changing Trait: substantial history + high cost/content prerequisite.

No Trait consumer may ship before its acquisition/removal loop has a real source/activity.

---

# 13. Removal / overcoming

Reference-inspired direction:
a disciple is not permanently ruined by one bad birth quirk.

Trait removal is an explicit action, not a free UI delete.

Default future route:
- Tu Tâm Đường / equivalent facility;
- real time;
- Spirit Stone cost;
- deterministic completion.

A Trait definition declares:
- `removable = true/false`;
- removal difficulty/cost class;
- any prerequisite.

Most ordinary Hữu Ích/Bất Lợi/Song Diện Traits are removable.

Exception candidates should be very rare and usually belong to:
- Mệnh Cách;
- Bloodline;
- Physique;
- Root;
rather than making a normal Trait secretly permanent.

Removed birth Trait remains in immutable birth/history records.

---

# 14. Event-created negative Traits

A life event may add a negative or mixed Trait.

Examples:
- repeated reckless overwork may create an unhealthy work habit;
- repeated qi-deviation content may create a cultivation drawback;
- major trauma may create a persistent mental/behavioral Trait if Personality/Injury authority says it is not merely an Injury.

Rule:
do not turn temporary Injury/Mood into a Trait automatically.

Trait acquisition requires:
- a genuine persistent behavioral/capability change;
- explicit event definition.

---

# 15. Personality boundary

Trait does not duplicate Personality V2.

Examples that should primarily be Personality:
- brave/cowardly;
- greedy/frugal;
- reckless/cautious;
- sociable/withdrawn;
- risk-seeking;
- survival-oriented.

A Trait may still modify AI when it has a specific rule.

Example:
`Huyết Chiến` may increase utility of offensive actions while below a HP threshold.

But do not create:
- Personality "reckless";
- Trait "reckless";
- another work preference "reckless"

as three independent authorities.

Legacy Gan Dạ/Nhát Chiến must migrate toward Personality rather than remain generic V2 Trait stat sticks.

---

# 16. Profession-talent boundary

Profession talent remains:
- profession-specific learning affinity;
- graded according to profession authority where already designed.

Examples:
- Luyện Khí Thiên Phú;
- Khai Khoáng Thiên Phú;
- Linh Thực Thiên Phú;
- Luyện Đan Thiên Phú.

These are not general Trait V2.

General work Traits may still affect many professions:
- Cần Mẫn;
- Lười Nhác;
- Cẩu Thả;
- Tỉ Mỉ.

Legacy `Nhãn Lực Luyện Khí` should migrate to profession-talent authority rather than remain duplicate Trait identity.

---

# 17. Starter Trait catalogue — expanded balance draft

The following is a **starting content target**, not yet locked balance.

Reference-derived design rule:
- Trait content should cover learning, cultivation, production, timing, critical, status, defense, support and recovery;
- do not reduce the catalogue to only "+Attack" and "-Attack";
- positive/negative/tradeoff identity should sometimes change **role suitability**, not merely total power.

## 17.1 Học tập / lĩnh ngộ

These Traits modify learning/mastery outcomes.
They do not rewrite permanent Thông Tuệ.

| Trait | Nature | Starting effect |
|---|---|---|
| **Ham Học** | Hữu Ích | +10% all valid learning/mastery XP |
| **Nhất Tâm** | Hữu Ích | +15% technique/skill mastery XP while learning one selected subject at a time; switching subject clears the temporary focus buildup |
| **Trí Nhớ Sâu** | Hữu Ích | +8% mastery XP; mastery decay, if a future system ever has it, is reduced by 50% |
| **Suy Diễn** | Song Diện | +15% technique mastery XP; -8% Work Speed while assigned to ordinary production |
| **Học Nhanh Làm Ẩu** | Song Diện | +15% profession XP; +500 Difficulty on explicit work quality/rare checks |
| **Chậm Mà Chắc** | Song Diện | -8% learning XP; +10% skill/technique effect once that subject reaches its future mastery threshold |
| **Tạp Niệm** | Bất Lợi | -10% technique/skill mastery XP |
| **Khó Tiếp Thu** | Bất Lợi | -12% all valid learning/mastery XP |

Notes:
- **Nhất Tâm** is a rule-shaped Trait, not a fixed-class lock. The focused subject can change.
- **Chậm Mà Chắc** only activates its payoff when the owning mastery system has a real threshold; until then it must not ship as fake text.
- no Trait above changes the stored Thông Tuệ value.

## 17.2 Tu luyện

| Trait | Nature | Starting effect |
|---|---|---|
| **Kinh Mạch Ổn Định** | Hữu Ích | +10% natural/base cultivation gain |
| **Kinh Mạch Mong Manh** | Bất Lợi | -10% natural/base cultivation gain |
| **Ngộ Tĩnh** | Hữu Ích, latent-eligible | +8% cultivation gain; +10% technique/skill mastery XP |
| **Tâm Tĩnh Như Thủy** | Hữu Ích | +8% cultivation gain while not carrying a serious Injury or explicit disturbed-mind state |
| **Nóng Vội Cầu Thành** | Song Diện | +12% cultivation gain; future breakthrough preparation/recovery penalties may apply only when Breakthrough V2 explicitly owns that consumer |

Kinh Mạch Ổn Định and Kinh Mạch Mong Manh conflict.

Do not activate a breakthrough downside before Breakthrough V2 owns the exact channel.

## 17.3 Lao động / sản xuất

| Trait | Nature | Starting effect |
|---|---|---|
| **Cần Mẫn** | Hữu Ích | +10% generic Work Speed |
| **Cuồng Công** | Song Diện | +15% Work Speed; +20% Stamina cost for explicit stamina-consuming work |
| **Lười Nhác** | Bất Lợi | -12% generic Work Speed |
| **Cẩu Thả** | Song Diện | +10% Work Speed; +800 Difficulty on explicit work rare/quality Luck checks |
| **Tỉ Mỉ** | Song Diện | -5% Work Speed; -600 Difficulty on explicit work rare/quality Luck checks |
| **Tiết Liệu** | Hữu Ích | -8% ordinary recipe material consumption where the recipe explicitly allows efficiency reduction; never reduces fixed quest/special costs |
| **Phung Phí** | Bất Lợi | +10% ordinary recipe material consumption; +8% profession XP |
| **Đa Nhiệm** | Hữu Ích / contextual | +8% Work Speed in explicitly multi-step workshop professions; no bonus to simple field/mine tasks |
| **Quen Tay** | Hữu Ích | +10% profession XP for the disciple's currently highest profession |
| **Đổi Nghề Khó** | Bất Lợi | -15% profession XP in professions below the disciple's highest profession level |

Conflicts:
- Cần Mẫn ↔ Lười Nhác;
- Cẩu Thả ↔ Tỉ Mỉ;
- Tiết Liệu ↔ Phung Phí.

Production lesson:
- XP acceleration and actual throughput/material efficiency are separate channels.
- a Trait that levels a profession faster does not automatically multiply routine output.

Cơ Duyên remains the actual Luck Score attribute.
Cẩu Thả/Tỉ Mỉ modify task difficulty, not Cơ Duyên itself.

## 17.4 Combat / control

| Trait | Nature | Starting effect |
|---|---|---|
| **Bản Năng Chiến Đấu** | Hữu Ích, latent-eligible | +5 percentage points Crit Chance; +10% combat-skill mastery XP |
| **Linh Giác Sắc Bén** | Hữu Ích | +10 percentage points Effect Hit |
| **Tâm Thần Kiên Cố** | Hữu Ích | +10 percentage points Effect Resistance |
| **Phá Giáp Cảm** | Hữu Ích | +5% Defense Penetration |
| **Hấp Tấp** | Song Diện | +10% Cast Speed; -10 percentage points Effect Hit |
| **Huyết Chiến** | Song Diện | +12% All Damage; -20% Healing Received |
| **Bất Khuất** | Hữu Ích / conditional | while current HP <30%: +10% Damage Reduction |
| **Tâm Thần Bất Ổn** | Bất Lợi | -10 percentage points Effect Resistance |
| **Trì Trọng** | Song Diện | -10% Movement Speed; +10 pp Effect Resistance; +5% Damage Reduction |
| **Thân Pháp Nhẹ Nhàng** | Hữu Ích | +10% Movement Speed |
| **Phản Ứng Nhanh** | Hữu Ích | +8% Attack Speed and +5% Cast Speed |
| **Lão Luyện** | Hữu Ích | +8 pp Crit Resistance |
| **Liều Mạng** | Song Diện | +10% All Damage; +8% incoming damage |
| **Thừa Thắng Truy Kích** | Hữu Ích / conditional | after personally defeating an enemy, +8% Movement Speed and +8% Attack Speed for 5s; cannot stack, only refresh |
| **Ổn Trận** | Hữu Ích / contextual | when current HP >=70%, +8 pp Effect Resistance |

## 17.5 Support / recovery

| Trait | Nature | Starting effect |
|---|---|---|
| **Dược Tâm** | Hữu Ích | +15% Healing Done |
| **Hộ Tâm** | Hữu Ích | +15% Shield Effect |
| **Hồi Nguyên** | Hữu Ích | +15% Healing Received; +10% Injury Recovery |
| **Khí Huyết Khó Hợp** | Bất Lợi | -15% Healing Received |
| **Dược Lý Thông Thạo** | Hữu Ích | +10% Healing Done; +10% medicine/healing profession XP when that profession authority exists |
| **Thương Binh Kinh Nghiệm** | Hữu Ích | +15% Injury Recovery; treatment AI values wounded allies more strongly |
| **Cứng Đầu** | Song Diện | +8% Damage Reduction while injured; -15% Healing Received |
| **Hộ Trì Bản Năng** | Hữu Ích / conditional | +12% Shield Effect when shielding another target; no bonus to self-shield |

Hồi Nguyên and Khí Huyết Khó Hợp conflict.

Support Traits must use the locked Healing Done / Healing Received / Shield Effect channels rather than one generic "support power".

## 17.6 Đạo lộ / chiến đấu chuyên tinh

These do not create a fixed class.

| Trait | Nature | Starting effect |
|---|---|---|
| **Kiếm Cảm** | Hữu Ích, latent-eligible | +12% Sword path/mastery XP; +8% Sword-tagged skill effect |
| **Thể Ngộ** | Hữu Ích, latent-eligible | +12% Body path/mastery XP; +8% Body-tagged skill effect |
| **Pháp Cảm** | Hữu Ích, latent-eligible | +12% Spell path/mastery XP; +8% Spell-tagged skill effect |

All three may eventually coexist.

Additional path-shaped Traits:

| Trait | Nature | Starting effect |
|---|---|---|
| **Kiếm Tâm Ổn Định** | Hữu Ích | +8% Sword skill effect while current HP >=50% |
| **Cận Chiến Lão Thành** | Hữu Ích | +8% Body skill effect; +5 pp Crit Resistance |
| **Pháp Ý Liên Miên** | Hữu Ích | +8% Spell skill effect; +8% Cast Speed |
| **Tạp Tu** | Song Diện | +8% learning XP to the disciple's two lowest path depths; -5% skill effect for the currently highest path |

A disciple is not permanently locked to one path.
The framework intentionally supports eventual multi-path development.

---


# 17.7 Reference-pattern library — not direct copies

The reference game/community data shows several recurring Trait patterns worth preserving as **design patterns**, not copied content:

1. **speed-for-defense tradeoff**;
2. **crit-for-accuracy/reliability tradeoff**;
3. **DoT damage with survivability/lifespan downside**;
4. **Effect Resistance with offensive downside**;
5. **healing/support specialization**;
6. **low-HP conditional power**;
7. **position/context-dependent benefit**;
8. **production time vs output tradeoff**;
9. **profession XP vs material/output tradeoff**;
10. **resource saving vs speed/output tradeoff**;
11. **specialization in one path/weapon/tag**;
12. **learning fast but working poorly**;
13. **slow learning but stronger completed mastery**;
14. **activity-earned identity**;
15. **removable quirk whose value depends on assigned role**.

Trait V2 should keep producing content from these pattern families before inventing new top-level stat systems.

# 18. Why no social Trait catalogue yet

Mị Lực and relationship/social authority are not fully migrated.

Therefore this V2 draft does not prematurely create:
- Social Score +X Traits;
- loyalty Traits;
- romance Traits;
- diplomacy Traits.

When Social/Relationship V2 is designed:
- it may add Trait definitions that consume the already-locked social channels;
- it must not create another Charisma stat.

This avoids shipping Trait text with no stable consumer.

---

# 19. Candidate / save target

Target model:

```
trait_model_version = 2

trait_profile = {
  "initialized": true,

  "birth_visible": ["diligent", ...],
  "birth_latent": ["battle_instinct"],

  "revealed_latent": [],
  "current_acquired": [],

  "removed_birth": [],
  "suppressed": {},

  "insight_progress": {},

  "history": [
    {
      "trait_id": "...",
      "event": "acquired|revealed|removed|reactivated",
      "source": "...",
      "tick": 123
    }
  ]
}
```

Static Trait definitions live in content/registry code/data, not duplicated in every save.

Derived:
- active Trait set;
- modifier contributions;
- conflict state.

Candidate -> accepted Disciple must copy the same Trait profile exactly.

No accept-time reroll.

---

# 20. Large-roster runtime

Trait V2 must scale to 1,000–3,000 disciples.

Do not:
- poll every Trait condition on every disciple every tick;
- recompute full modifier sheets continuously.

Use event-driven hooks.

Examples:
- `combat_completed` only checks combat-relevant reveal/acquisition rules for participants;
- `work_cycle_completed` checks work-relevant rules;
- `cultivation_session_completed` checks cultivation-relevant rules.

`insight_progress` is sparse:
- only non-zero entries are stored.

Trait numeric changes invalidate only relevant derived channels.

A worker gaining Cần Mẫn should not force a complete combat-stat rebuild.

---

# 21. UI target

## Character summary
Show at most the most important visible Traits.

## Đặc Chất tab
Group by:
- Bẩm Sinh;
- Hiển Lộ từ Tiềm Ẩn;
- Hậu Thiên;
- Bị Áp Chế;
- Đã Khắc Phục history.

Each Trait shows:
- name;
- Hữu Ích / Bất Lợi / Song Diện;
- exact current effects;
- source/origin;
- conflicts;
- acquisition/removal progress where applicable.

Hidden latent Trait:
- not shown by default;
- no "1 hidden Trait" leak unless a future appraisal mechanic explicitly reveals that information.

No generic Trait star/grade UI.

---

# 22. Legacy migration direction

Current legacy Trait system is not V2 authority.

Mapping target:

- `steady_meridians` -> **Kinh Mạch Ổn Định**;
- `fragile_meridians` -> **Kinh Mạch Mong Manh**;
- `diligent_worker` -> **Cần Mẫn**;
- `careless_worker` -> **Cẩu Thả**;
- `battle_instinct` -> **Bản Năng Chiến Đấu**;
- `meditative_insight` -> **Ngộ Tĩnh**;
- `craftsman_eye` -> profession-talent migration, not Trait V2;
- `fearless` / `timid` -> Personality migration, not Trait V2.

Legacy profession-trait storage:
- `forge_talent` / `miner_instinct` stay profession talent;
- `diligent` -> Cần Mẫn;
- `lazy` -> Lười Nhác.

Legacy generic Trait Grade 1–5:
- retired;
- does not create V2 universal grades;
- exact save conversion is deterministic implementation work.

Legacy `combat_power_flat` Trait effects are removed.
V2 Traits use canonical Combat Stats/channels.

---

# 23. Required implementation invariants

When implemented, tests must prove at minimum:

1. same seed/source/index produces the same birth-visible and birth-latent Traits;
2. normal Disciple Quality does not change Trait probabilities;
3. ordinary birth always has 1–3 visible Traits by the locked count table;
4. ordinary birth has at most one latent Trait;
5. birth generation never creates duplicate/conflicting visible/latent combinations;
6. latent identity exists before reveal;
7. latent Trait has no effect before reveal;
8. reveal never rerolls Trait identity;
9. hidden latent Trait does not leak by blocking a visible acquisition;
10. revealed conflicting latent Trait becomes suppressed rather than deleted;
11. removing the conflict reactivates the suppressed Trait deterministically;
12. no generic lifetime Trait cap exists;
13. same Trait cannot stack duplicate copies;
14. Trait numeric effects use registered channels;
15. Trait does not directly mutate permanent Lục Duy;
16. fixed-value items remain fixed unless explicitly scalable;
17. Personality-only legacy Traits do not survive as duplicate V2 behavior authorities;
18. profession talent does not duplicate into general Trait V2;
19. candidate acceptance preserves exact Trait identity;
20. save/load preserves Trait state/history exactly;
21. removed Trait history does not reapply its effect;
22. reacquiring an allowed removed Trait works deterministically;
23. event-driven reveal/acquisition gives deterministic continuation after save/load;
24. large-roster background simulation does not poll all Traits each tick;
25. unknown Trait modifier channel fails validation;
26. Trait trigger cannot recursively self-proc unless explicitly allowed.

---

# 24. Decisions proposed for user approval

This draft proposes to lock:

1. Trait is separate from Personality / profession talent / Root / Mệnh Cách / Bloodline / Physique;
2. origin states = visible birth / latent birth / acquired / removed;
3. effect nature = beneficial / detrimental / tradeoff;
4. no universal Trait Grade 1–5;
5. visible birth count = 1/2/3 at 60/32/8%;
6. congenital latent rate = 8%, max one at ordinary birth;
7. visible nature weight = 50% beneficial / 30% tradeoff / 20% detrimental;
8. normal Trait generation independent from Disciple Quality and Dẫn Tiên quality;
9. commonality controls frequency, not universal power tier;
10. explicit conflicts;
11. hidden-latent conflict becomes revealed-but-suppressed, never rerolled/deleted;
12. no lifetime Trait cap;
13. ordinary numeric effects use canonical shared channels;
14. Trait does not alter permanent Lục Duy directly;
15. latent reveal is deterministic and event-driven;
16. post-birth Trait acquisition exists through life experience and targeted training;
17. ordinary Traits are generally removable/overcome through explicit time/resource cost;
18. no generic removal fail chance;
19. birth/current/history are persisted separately;
20. legacy combat_power-flat/grade/duplicate personality/profession Trait authority is retired;
21. starter catalogue above is the initial balance target, subject to user tuning before lock.

After this design is approved, the next design subject is **Mệnh Cách V2**.
