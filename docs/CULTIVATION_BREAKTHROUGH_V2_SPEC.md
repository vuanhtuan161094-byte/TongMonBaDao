# CULTIVATION + BREAKTHROUGH V2 — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-08  
Status: **DESIGN LOCKED — NOT IMPLEMENTED**

Read with:
- `docs/REALM_LADDER_V2_SPEC.md`
- `docs/BODY_CULTIVATION_V2_SPEC.md`
- `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`
- `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`

This document is the canonical V2 authority for Tu Vi gain, minor-floor advancement and major-realm breakthrough.

Legacy P2.1/P2.2 breakthrough rules remain compatibility-only until an explicit V2 migration phase.

---

# 1. Core progression model

Tu Vi uses the canonical ladder:
- 30 đại cảnh;
- 10 tầng per đại cảnh;
- 300 floors total.

Minor floors and major-realm transitions are deliberately different systems.

## 1.1 Minor floors

Within one major realm:
- enough Tu Vi progress advances automatically;
- no RNG;
- no breakthrough action;
- no HP loss;
- no Expedition Stamina cost;
- no generic cooldown.

Excess Tu Vi may cascade through multiple minor floors.

Excess Tu Vi may **not** cross a major-realm gate automatically.

Example:
- Đại cảnh A tầng 9 receives enough Tu Vi to fill tầng 9 and tầng 10;
- the disciple may reach tầng 10 with overflow retained according to the overflow rules below;
- the disciple does not enter đại cảnh B until a successful major breakthrough occurs.

## 1.2 Major breakthrough

Only:
`current realm tầng 10 -> next realm tầng 1`

uses breakthrough resolution.

Major breakthrough is a meaningful life milestone and may emit:
- history;
- Trait/Mệnh Cách reveal hooks;
- relationship/story hooks;
- content unlock hooks;
- realm-transition presentation.

---

# 2. Natural cultivation gain

Canonical Tư Chất law:

`1 Tư Chất = +0.25% natural/base Tu Vi gain`

For the same cultivation-gain channel:

`final_gain = base × (1 + sum(valid percentage bonuses))`

Valid same-channel bonuses may include:
- Tư Chất;
- matching Spiritual Root;
- active Công Pháp;
- explicit Trait/Mệnh/Bloodline/Physique/content modifiers.

Do not chain-multiply ordinary same-channel bonuses.

## 2.1 Fixed rewards remain fixed

If content says:
- `+10,000 Tu Vi`

the result is exactly:
- `+10,000 Tu Vi`

unless that content explicitly declares itself scalable.

Tư Chất, Root or ordinary cultivation-rate bonuses do not silently multiply fixed +X rewards.

---

# 3. Major-breakthrough chance

Conceptual authority:

`final_chance = Base Realm Chance + Same-Gate Failure Bonus + Explicit Sources + Consumables`

Then clamp to the content-defined valid probability range.

The exact base chance per major realm is balance data and is not locked by this architecture.

## 3.1 No silent generic chance sources

The following do **not** generically alter breakthrough chance:

- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- current HP;
- Expedition Stamina;
- Spiritual Root;
- Physique;
- generic equipment quality.

A specific authored effect may alter breakthrough chance only when it explicitly says so.

This retires legacy root-quality breakthrough bonuses as V2 authority.

---

# 4. Breakthrough failure

Default major-breakthrough failure:

- lose progress equal to **10% of the current gate requirement**;
- stay at the same major-realm gate;
- increment same-gate consecutive-failure history;
- increment lifetime breakthrough-failure history;
- gain **+5 percentage points** chance for the next attempt at the same gate.

The disciple must re-cultivate the lost progress before retrying.

Failure does not generically:
- damage HP;
- consume Expedition Stamina;
- create a cooldown;
- injure the disciple.

Explicit special content may add separate consequences only if authored.

## 4.1 Two counters

Persist separately:
- same-gate consecutive failures;
- lifetime breakthrough failures.

They serve different story/Mệnh/Trait consumers.

## 4.2 Success

On success:
- advance to next major realm tầng 1;
- reset same-gate consecutive failure bonus;
- preserve lifetime history;
- record breakthrough event/history;
- release valid overflow/Tích Tu according to the rules below;
- trigger content hooks.

---

# 5. Breakthrough consumables

A breakthrough attempt may use at most:

**3 consumables**

Consumables may explicitly provide:
- chance;
- failure protection;
- progress protection;
- requirement assistance;
- other authored effects.

There is no hidden fourth slot or generic stacking beyond the declared item rules.

Pill use also remains subject to the shared daily pill-satiety system when that system is implemented.

---

# 6. Auto breakthrough

Each disciple may support an:
- auto-breakthrough enabled/disabled policy.

Auto-breakthrough may attempt only when:
- the gate is fully ready;
- non-chance requirements are satisfied;
- allowed consumable policy is satisfied.

Auto mode does not bypass costs, conditions, failure or history.

---

# 7. Overflow and Tích Tu

Normal minor-floor overflow may cascade within the same major realm.

At a major gate, ordinary overflow cannot silently skip the breakthrough.

## 7.1 Hậu Tích Bạc Phát

The explicit Hậu Tích Bạc Phát mechanic may bank eligible overflow as **Tích Tu**.

Eligible sources:
- natural cultivation;
- cultivation activities;
- other sources explicitly marked overflow-bankable.

Fixed +X consumables/rewards do **not** automatically become Tích Tu.

Default Tích Tu cap:
- **100% of the first post-breakthrough Tu Vi requirement**.

After successful breakthrough, banked Tích Tu is released according to the mechanic's authored rule.

## 7.2 Mệnh Cục — Hậu Tích Thành Khí

When the explicit Mệnh Cục is active:
- Tích Tu cap becomes **150%** of the first post-breakthrough requirement;
- released Tích Tu receives **+20%** effectiveness.

This is a Mệnh-specific rule, not a generic breakthrough law.

---

# 8. Explicit special breakthrough identities

## 8.1 Hồng Trần Luyện Tâm

When active for an eligible major breakthrough:
- failure loses **0%** gate progress;
- next same-gate attempt gains **+15 percentage points** chance;
- after **3 consecutive failures at the same gate**, the next attempt is guaranteed if all non-chance requirements are satisfied.

This special rule overrides the default failure-loss and +5pp pity only for the eligible effect scope.

## 8.2 Đại Khí Vãn Thành

Locked identity:
- **-15% natural cultivation gain**;
- every completed major breakthrough grants one permanent Hậu-Phát mark;
- each mark gives **+8% Realm + Luyện-Thể Core ATK/DEF/HP growth**;
- the effect is retroactive/reconstructible.

It does not create a second independent ATK/DEF/HP authority.

---

# 9. Pill satiety dependency

Cultivation/breakthrough consumables must use one shared pill-satiety system.

The design direction already locked:
- one daily satiety pool;
- each pill declares explicit satiety cost;
- no separate hidden satiety bar for breakthrough pills versus cultivation pills.

Exact capacity and pill values are future content balance unless already declared by a specific item authority.

---

# 10. Persistence

Persist:
- current realm/floor;
- current Tu Vi progress;
- auto-breakthrough policy;
- same-gate consecutive failures;
- lifetime failure history;
- relevant breakthrough history;
- Tích Tu when an eligible mechanic exists;
- special persistent breakthrough identity state.

Do not persist derived final chance as save truth.
Recompute it from current sources.

---

# 11. Determinism

Breakthrough RNG must use an explicit deterministic stream.

Save/load continuation must preserve:
- attempt order;
- failure counters;
- resource consumption;
- result sequence.

No UI or presentation action may consume breakthrough RNG.

---

# 12. Legacy migration direction

When V2 implementation is authorized:
- keep P0–P2 regression compatibility behind old factories/flags until migration is explicitly closed;
- remove legacy HP/stamina/cooldown breakthrough consequences from V2;
- remove generic Spiritual-Root breakthrough modifiers from V2;
- preserve stable disciple identity and progression history;
- migrate old stage/progress data deterministically into the 30×10 ladder.

No runtime change is authorized by this document alone.

---

# 13. Locked summary

1. Tu Vi = 30×10.
2. Minor floors auto-advance with no RNG.
3. Only major transitions use breakthrough chance.
4. Overflow cannot cross a major gate without success.
5. Default failure loses 10% gate requirement.
6. Same-gate failure gives +5pp next attempt.
7. Re-cultivate lost progress before retry.
8. Success resets same-gate pity and records history.
9. No generic HP damage, Expedition Stamina cost or cooldown.
10. No generic Tư Chất/Căn Cốt/Cơ Duyên/Root/Physique chance modifier.
11. Max 3 breakthrough consumables.
12. Auto-breakthrough is supported.
13. Same-gate and lifetime failure counters are separate.
14. Tích Tu/Hậu Tích only bank eligible sources.
15. Fixed +X rewards remain fixed.
16. Special Mệnh/identity rules may explicitly override the default law.
