# TRAITS / ĐẶC CHẤT V2 — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-07
Status: **DESIGN LOCKED — NOT IMPLEMENTED**

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

No gameplay implementation is authorized by this design lock.

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

## 9.6 Consumer readiness

Every Trait definition must declare one of:

- `ready` — every required gameplay consumer already has canonical authority;
- `consumer_gated` — the Trait identity is valid, but one or more effects may not ship until the named owning subsystem exists;
- `future_only` — design pattern only, not initial shipping content.

UI/runtime must never display or apply an effect that has no real consumer.

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
| **Chậm Mà Chắc** | Song Diện, consumer-gated | -8% learning XP; payoff waits for a real mastery-milestone authority |
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
| **Nóng Vội Cầu Thành** | Song Diện, consumer-gated | +12% cultivation gain; downside waits for Breakthrough V2 |

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
| **Tiết Liệu** | Hữu Ích, consumer-gated | material-efficiency effect waits for Crafting V2 integer/rounding authority |
| **Phung Phí** | Song Diện, consumer-gated | +8% profession XP; material-consumption penalty waits for Crafting V2 |
| **Đa Nhiệm** | Hữu Ích / contextual, consumer-gated | +8% Work Speed only in professions explicitly tagged multi-step by future profession content |
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

# 24. Locked decisions

Traits V2 is locked with these rules:

1. Trait is separate from Personality / profession talent / Root / Mệnh Cách / Bloodline / Physique.
2. Origin/state = visible birth / latent birth / acquired / removed-or-overcome.
3. Effect nature = Hữu Ích / Bất Lợi / Song Diện.
4. No universal Trait Grade 1–5.
5. Ordinary visible birth count = 1/2/3 at **60% / 32% / 8%**.
6. Ordinary congenital latent rate = **8%**, max one latent Trait.
7. Ordinary visible nature weights = **50% Hữu Ích / 30% Song Diện / 20% Bất Lợi**.
8. Normal Trait generation is independent from Disciple Quality, Dẫn Tiên quality and Spiritual Root.
9. Commonality controls frequency, not universal power tier.
10. Explicit conflicts are canonical.
11. Hidden latent conflicts do not leak identity; reveal becomes suppressed rather than deleted/rerolled.
12. No lifetime Trait hard cap.
13. Same Trait cannot stack duplicate copies.
14. Ordinary numeric effects use canonical shared channels and filters.
15. Trait does not directly mutate permanent Lục Duy.
16. Latent reveal is deterministic and event-driven.
17. Post-birth Trait acquisition exists through life experience and targeted training.
18. Ordinary Traits are generally removable/overcome through explicit time + resource cost.
19. No generic removal fail chance once requirements/cost are met.
20. Birth/current/history are persisted separately.
21. Personality-only legacy Traits migrate toward Personality authority.
22. Profession-talent legacy entries remain profession talent rather than duplicate Trait.
23. Legacy generic Trait grades and `combat_power_flat` authority are retired for V2.
24. Trait definitions must declare `ready`, `consumer_gated`, or `future_only`.
25. Starter catalogue in this spec is the initial content target; exact numeric balance may be benchmark-tuned without reopening the architecture.
26. Social, Pill Satiety, Lifespan, disease/addiction/environment and other not-yet-owned domains remain intentionally deferred to their owning systems.

No gameplay runtime code was implemented by this design lock.

# 25. Next design subject

After Traits V2, the next design subject is **Mệnh Cách V2**.

Mệnh Cách must remain distinct from Trait:
- rarer;
- more identity-defining;
- allowed to change generation envelopes or gameplay rules;
- not merely "Trait but stronger";
- still constrained by the one-disciple-forever nurture philosophy.

---

# 26. Content expansion approved 2026-10-09 — DESIGN ONLY / ROOT-FIRST IMPLEMENTATION

**Decision:** user approved the previous review direction: keep the existing 53 Chapter-17 Trait concepts and add the 48 concepts below, for **101 target Trait identities**. This is a **design catalogue target, not 101 enabled runtime Traits**. No Godot implementation phase has been authorized by this approval.

**Unchanged locked rules:** ordinary 1/2/3 visible Traits = 60/32/8%; one latent = 8%; nature allocation Hữu Ích/Song Diện/Bất Lợi = 50/30/20%; quality-independent birth; conflicts; no universal Trait grade; no effectless active Trait. Birth identity may be stored for an approved gated mechanic, but its effect remains disabled until the real consumer exists.

**Rarity direction approved, exact per-ID weights NOT yet assigned:** weighted selection within each nature group, with provisional commonality weight tiers `phổ biến=10`, `ít gặp=4`, `hiếm=1`. These are encounter weights, never strength/rarity grades. Each specific Trait needs a later user-approved weight and eligibility before final generator activation.

**Numbers in the tables below are provisional effects for subsequent mechanic-level review**. A concept is not executable until the consuming system, constraints, conflicts, eligibility, nonrecursive triggers, UI disclosure and tests are approved. User's 2026-10-09 sequencing correction: build the ONE-person birth/action/event/result/progression authority first. Do not proceed from a large Trait catalogue directly to ad-hoc callbacks or private stat systems.

Nature codes: `H` = hữu ích, `S` = song diện, `B` = bất lợi. For concepts with no ready canonical consumer, tag them **CONSUMER-GATED / FUTURE-ONLY**, not `ready`.

## 26.1. Sinh hoạt / ăn uống

| Đặc Chất | Loại | Cơ chế dự kiến (chưa khóa hệ số) | Consumer/dependency |
|---|---|---|---|
| Tham Ăn | S | Tiêu thụ thêm 20% khẩu phần; +10% hiệu quả hồi phục từ bữa ăn | Food, meal/recovery |
| Kén Ăn | S | -10% hồi phục từ món thường; +15% từ món cao cấp | Food grades, meal/recovery |
| Cú Đêm | S | +12% tốc độ công việc ca đêm, -8% ca ngày | Time-of-day and work schedule |
| Ngủ Nướng | S | Vào ca đầu ngày muộn 30 phút; hồi phục lúc nghỉ +8% | Work schedule and rest |
| Mê Sạch Sẽ | S | Nơi sạch +10% Work Speed, nơi bẩn -10% | Building cleanliness |
| Bày Bừa | S | +8% Work Speed; tăng nguy cơ sự cố bảo trì có nguồn sự kiện thật | Maintenance events |
| Trộm Ăn Vặt | B | Tiêu hao thêm khẩu phần nhỏ qua sự kiện tiêu thụ có nhật ký | Food inventory/events |
| Mê Ngủ Trưa | S | Tự ưu tiên nghỉ giữa ca; giảm thời gian công việc nhưng hồi phục tốt hơn | Rest and work schedule |

## 26.2. Nghề / kinh tế

| Đặc Chất | Loại | Cơ chế dự kiến (chưa khóa hệ số) | Consumer/dependency |
|---|---|---|---|
| Mắt Nhìn Quặng | H | -400 Difficulty cho kiểm tra khoáng hiếm hợp lệ | Mine rare-check |
| Khứu Giác Linh Thảo | H | -400 Difficulty cho kiểm tra linh thảo hiếm hợp lệ | Spirit Field rare-check |
| Thích Thử Nghiệm | S | +12% profession XP khi thử công thức mới; giảm độ ổn định thử công thức | Crafting trial/quality |
| Đếm Từng Đồng | S | Giao dịch giá tốt hơn 3%, thời gian giao dịch +10% | Trade economy and timer |
| Vừa Làm Vừa Hát | S | +6% tốc độ bản thân; đồng nghiệp trong phạm vi hợp lệ có thể -3% | Co-worker proximity / work |
| Đổi Việc Như Thay Áo | S | +12% XP ca đầu nghề mới; -8% XP học chuyên sâu | Profession history/milestones |
| Hay Quên Dụng Cụ | B | Chậm khởi động một số ca do chuẩn bị dụng cụ; chỉ khi có sự kiện hợp lệ | Job setup event |
| Học Qua Thực Hành | H | Sau sản phẩm chất lượng cao +10% XP nghề cho lần sản xuất | Crafting quality event |

## 26.3. Tu luyện / học

| Đặc Chất | Loại | Cơ chế dự kiến (chưa khóa hệ số) | Consumer/dependency |
|---|---|---|---|
| Ngộ Đạo Lúc Quét Sân | H | Hoàn thành ca công việc phù hợp -> +5% Tu Vi tự nhiên ở lần tu luyện tiếp theo trong ngày | Work complete -> cultivation event |
| Bế Quan Quên Ngày | S | Bế quan liên tục nhận +8% Tu Vi tự nhiên; có xu hướng chậm rời lịch bế quan | Retreat schedule |
| Học Vẹt | S | +12% XP học công pháp mới, -8% Skill Effect trước Nhập Môn | Technique/skill mastery |
| Trí Nhớ Cá Vàng | B | Buổi học đầu sau khi đổi chủ đề -15% XP mastery; không xóa tiến độ đã đạt | Learning subject switch |
| Mê Sưu Tầm Công Pháp | S | +10% XP với công pháp chưa học; phạt đổi chủ đề thường xuyên | Technique library, session history |
| Nửa Đêm Tỉnh Ngộ | H | +10% learning/mastery XP cho buổi lĩnh ngộ đêm đầu tiên | Time-of-day learning |
| Sợ Đột Phá | B | Sau thất bại đột phá hợp lệ, 2 buổi tu sau -10% Tu Vi tự nhiên; không đổi tỷ lệ đột phá | Breakthrough outcome + temporary condition |
| Nghe Giảng Là Buồn Ngủ | S | -10% XP khi học qua truyền giảng; +5% Tu Vi tự nhiên khi tự tu | Teaching vs independent cultivation |

## 26.4. Chiến đấu / hành vi

| Đặc Chất | Loại | Cơ chế dự kiến (chưa khóa hệ số) | Consumer/dependency |
|---|---|---|---|
| Nhát Nhưng Chạy Nhanh | S | HP <50%: +20% Movement, -10% sát thương đánh thường | HP contextual combat |
| Thù Dai | H | Bị địch gây sát thương: +10% sát thương lên đúng địch đó 6s, không cộng dồn | Damage-source attribution |
| Đánh Hội Đồng | S | +10% sát thương lên địch đang bị đồng đội tấn công; đơn độc -8% | Team target attribution |
| Chuyên Đánh Lén | S | +15% đòn đầu lên địch chưa nhắm mình; bị tập trung tấn công -8% | Aggro/first strike |
| Hò Hét Xung Phong | S | Mở trận +3 điểm % Effect Resistance cho đồng đội gần trong 5s; đòn đầu của bản thân chậm 0.4s | Combat opening / allied proximity |
| Giả Chết Tài Tình | H | Một lần mỗi trận khi HP <15%: giảm ưu tiên bị nhắm trong khoảng ngắn; không hủy sát thương chí mạng đã giải quyết | Threat targeting, once/encounter |
| Tay Nhanh Hơn Não | S | +15% Basic Attack Speed; +10% cooldown của kỹ năng chủ động | Separate combat speed/cooldown |
| Vấp Nhưng Không Ngã | H | Lần đầu chịu slow hợp lệ mỗi trận: rút ngắn 20% thời hạn | Status source/duration |

## 26.5. Quan hệ / đời sống tông môn

| Đặc Chất | Loại | Cơ chế dự kiến (chưa khóa hệ số) | Consumer/dependency |
|---|---|---|---|
| Lắm Chuyện | S | Truyền thông tin đã biết nhanh hơn; tin xấu có thể gây mất thiện cảm từ tương tác thật | Social info/history |
| Hay Mách Lẻo | S | Báo cáo vi phạm có thật nhanh hơn; người bị báo có thể giảm thiện cảm | Violations/social relations |
| Biết Tuốt | S | Chủ động hướng dẫn; lời khuyên đúng tạo XP, sai làm mất thời gian | Advice/teaching validation |
| Hay Gây Sự | S | Ưu tiên đề nghị tỉ thí; thêm luyện tập nhưng tăng cơ hội mâu thuẫn | Duel/social event |
| Thích Khoe | S | Thành tựu thật có thể tạo cổ vũ hoặc ganh đua giữa nhân chứng | Witnessed achievements/social |
| Tốt Bụng Quá Đà | S | Ưu tiên giúp đồng môn bị thương, chậm công việc của mình | Rescue AI/work displacement |
| Mê Làm Sư Huynh | S | Khi dạy đệ tử ít kinh nghiệm: người học nhận thêm XP; người dạy mất thời gian cá nhân | Teaching/discipleship |
| Cãi Chày Cãi Cối | B | Kéo dài xử lý bất đồng bằng sự kiện tranh luận thật | Conflict resolution |

## 26.6. Viễn chinh / cơ duyên

| Đặc Chất | Loại | Cơ chế dự kiến (chưa khóa hệ số) | Consumer/dependency |
|---|---|---|---|
| Lạc Đường Có Duyên | S | +10% thời gian hoặc expedition stamina đi đường; -300 Difficulty cho lần khám phá kỳ ngộ hợp lệ đầu tiên | Expedition travel/event |
| Nhặt Gì Cũng Mang | S | Tăng cơ hội phần thưởng thường có nguồn hợp lệ; +10% tiêu hao thể lực vận chuyển ngoài map | Loot source + expedition stamina |
| Đụng Gì Cũng Mở | S | Tăng cơ hội tương tác vật thể chưa rõ; rủi ro sự kiện bất lợi qua bảng có thật | Exploration interaction/event |
| Thính Tai | H | Giảm Difficulty kiểm tra phát hiện phục kích/bẫy | Detection event |
| Xem Bản Đồ Ngược | B | Đường lần đầu có chi phí di chuyển cao; học thuộc đường giảm hoặc xóa phạt | Route familiarity |
| Đi Đâu Cũng Đánh Dấu | H | Trên đường đã khám phá giảm 10% expedition stamina cost | Explored-route tracking |
| Sợ Ma | B | Gặp địch có tag u linh/hồn ma: -8% sát thương gây ra | Monster tags |
| Lì Đòn Khi Lạc Rừng | H | Môi trường rừng khắc nghiệt: -8% thành phần tiêu hao expedition stamina do môi trường | Map environment stamina component |

## 26.7. Audit corrections and activation gates

- `Cuồng Công`: the old drawback `+20% Stamina cost for in-sect work` **contradicts** expedition-only Stamina authority. Do not execute it. Proposed alternative: a real separate work-rest/overwork cycle, requiring explicit approval and an actual schedule/condition owner.
- `Chậm Mà Chắc`, `Nóng Vội Cầu Thành`, `Tiết Liệu`, `Phung Phí`, `Đa Nhiệm`, and any other half-implemented trade-off must not become silently beneficial without its stated downside; require full legitimate consumer and balance approval before activation.
- `Trí Nhớ Sâu`: no imaginary mastery decay before mastery-decay authority exists. Existing `+8% mastery XP` can only become active once the legal XP consumer is present.
- Avoid duplicate authority with personality axes, profession talent, social stats, root/bloodline/physique/fate. Actual social actions need real participants/history, not phantom Mị Lực.
- Ordinary sect work never consumes Expedition Stamina. Only external expedition time/components can spend it.
- A successful eligibility+consumer gate must be checked per Trait before entering the enabled birth pool; rejected content must not be substituted with a fake combat-power bonus. Hidden profiles stay redacted until legal reveal.
- All work/combat/social/exploration Trait hooks should consume shared typed simulation events; do not poll 1,000–3,000 disciples per tick.
- No per-ID commonality weights, full conflict graph, social mechanics, crafting-quantity rules or other pending mechanics were approved by this design-catalogue decision. Those are dependencies, not invented defaults.

**Implementation sequence:** origin/world state -> ONE canonical Disciple V2 identity -> valid simulation actions/events -> canonical typed modifiers/outcomes -> only then detailed Trait readiness + individually reviewed rarity tables + runtime activation. Track 'DESIGN ONLY' separately from 'BACKEND TESTED'.
