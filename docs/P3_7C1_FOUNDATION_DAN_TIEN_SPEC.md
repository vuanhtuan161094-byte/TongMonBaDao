# P3.7C1 — LỤC DUY MỞ + DẪN TIÊN ĐÀI

Status: BACKEND LOCKED — official Godot 4.7.2 fast + full cumulative CI green  
Date: 2026-10-06

Parents:
- `docs/GAME_SYSTEM_ARCHITECTURE.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`
- `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`

This phase replaces the old normalized 0..1 P3.7 foundation model with the user-approved open-point lục-duy model and adds the first real Dẫn Tiên recruitment authority.

---

# 1. Six lục-duy common law

Canonical six dimensions remain:
- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

They use one common visible point scale:
- no permanent hard cap;
- values may grow to hundreds, thousands, tens of thousands or beyond;
- higher is always better;
- a disciple may eventually improve every growth dimension;
- innate/birth values remain historical truth and are never rewritten by later growth.

A disciple stores:
- current six values;
- an immutable birth snapshot;
- derived current quality.

Permanent growth changes the current value and may promote current disciple quality.

---

# 2. Birth total and distribution

Generation first rolls a **Total Birth Lục Duy**.

The total is then distributed across all six dimensions.

For ordinary generation, each dimension is constrained at birth to approximately:
- minimum = `floor(total / 12)` = about 0.5x the six-stat average;
- maximum = `floor(total / 2)` = about 3x the six-stat average.

Therefore a high-total disciple cannot normally be born with five completely worthless dimensions, while strongly skewed specialists remain possible.

Mệnh Cách / rare future identity rules may explicitly break this birth envelope.

The envelope exists only at birth.
After birth, each dimension grows independently without this restriction.

---

# 3. Current quality from total lục duy

Working thresholds:

| Current total | Quality |
|---:|---|
| < 360 | Phàm Thường |
| 360–599 | Xuất Chúng |
| 600–999 | Thiên Kiêu |
| 1,000–1,799 | Tuyệt Luân |
| >= 1,800 | Nghịch Thiên |

Quality is derived from the **current permanent six-stat total** and may improve through growth.

The exact total is always authoritative; quality is only a readable summary label.

Nghịch Thiên generation has a long tail and no hard upper total.

---

# 4. Starting lục-duy effects

These are starting balance constants, not immutable final balance.

## Tư Chất
Primary role: natural/base Tu Vi progression.

Starting conversion:
- +0.25% base cultivation gain per point;
- 2,500 -> x7.25 from Tư Chất alone;
- 10,000 -> x26 from Tư Chất alone.

Fixed-value Tu Vi consumables are not multiplied by Tư Chất:
a pill stating +10,000 Tu Vi grants exactly +10,000 Tu Vi.

Same-channel percentage bonuses are additive on the base value, not chained multipliers:
`final = base × (1 + sum(bonuses))`.
This applies to the P3.7 open-point cultivation/learning channels so long-lived high-stat disciples do not create accidental multiplier explosions.

## Căn Cốt
Primary role: Luyện Thể / body-training progression.

Starting conversion:
- +0.20% body-training XP per point;
- 2,500 -> x6.

Fixed-value body-training consumables are not multiplied by Căn Cốt.

## Cơ Duyên
Cơ Duyên is not a direct percentage.

Canonical check:
`Luck Score = RNG(0..9999) + Cơ Duyên - Cơ Duyên Difficulty`

Result tiers:

| Score | Tier |
|---:|---|
| < 6,000 | Bình thường |
| 6,000–8,499 | Tốt |
| 8,500–9,499 | Hiếm |
| 9,500–9,899 | Cực hiếm |
| >= 9,900 | Đại Cơ Duyên |

Only meaningful outcomes should make this check.
Do not roll it per combat hit/tick.

Existing older rare-chance consumers may use a bounded compatibility bridge until their own meaningful-outcome migration is implemented.

## Thông Tuệ
Primary role: learning/mastery.

Starting conversion:
- +0.15% learning XP per point;
- applies to profession XP and future technique/skill mastery learning;
- 2,500 -> x4.75.

A fixed-value book/item stating +X XP grants exactly X.

## Mị Lực
Primary role: social power and recruitment.

General social check:
`Social Score = RNG(0..9999) + Mị Lực - Social Resistance`

Dẫn Tiên recruitment has its own capped recruitment curve defined below.

## Tiềm Lực
Primary role: long-term growth quality.

Starting conversion:
- +0.05% per point to the future canonical Realm + Luyện Thể ATK/DEF/HP growth component;
- 2,500 -> x2.25;
- 10,000 -> x6.

It must be retroactive when the future canonical combat-stat/body-growth authority is implemented:
raising Tiềm Lực later recalculates the Realm/Body growth component already earned.

It does not multiply equipment, fixed consumable stats or every unrelated system.

---

# 5. Dẫn Tiên Đài

Dẫn Tiên Đài is a real building:
- Lv1–100;
- upgrading uses normal building timing/cost authority;
- current working slot curve: 1 guide at Lv1, +1 at Lv20/40/60/80/100, max 6;
- current base-arrival curve: `5 + 3 × floor(level / 10)` people/day;
- therefore Lv1 = 5/day and Lv100 = 35/day before guide bonuses.

Upgrading currently consumes the shared building resources Linh Mộc + Thanh Thiết + Linh Thạch and real simulation work/time. Major building milestones already use the common higher cost/work multiplier. A dedicated Dẫn Tiên Trận Bàn is reserved as a future milestone component, but C1 deliberately does not enforce an item with no acquisition authority yet.

Exact level/arrival/cost constants remain balance data.

---

# 6. Guide roles

One assigned guide is the **Trưởng lão Tiếp Dẫn Chính**.

Only the Main Guide's Mị Lực affects recruitment quality.

Other assigned guides are assistants:
- their Mị Lực increases the number of people arriving per day;
- they do not stack quality odds with the Main Guide.

Current assistant rule:
- assistant Mị Lực is not hard-capped by Dẫn Tiên Đài;
- every 500 assistant Mị Lực adds +1 arrival/day;
- extremely high Mị Lực therefore continues to increase throughput.

The Main Guide is deliberately not counted in assistant quantity; their Dẫn Tiên role is quality + daily enhanced-quality allowance.

Daily recruitment parameters are snapshotted for that simulation day so swapping guides cannot reset/duplicate the day's quality advantage.

---

# 7. Dẫn Tiên quality rates

Normal working distribution:

| Quality | Normal |
|---|---:|
| Phàm Thường | 65% |
| Xuất Chúng | 25% |
| Thiên Kiêu | 8% |
| Tuyệt Luân | 1.8% |
| Nghịch Thiên | 0.2% |

Main-guide Mị Lực shifts the distribution toward the mortal-platform quality ceiling.

At 2,500 Main-guide Mị Lực the quality table reaches its current ceiling:

| Quality | Maximum boosted rate |
|---|---:|
| Phàm Thường | 35% |
| Xuất Chúng | 25% |
| Thiên Kiêu | 20% |
| Tuyệt Luân | **15%** |
| Nghịch Thiên | **5%** |

No quality is reduced to 0%.

The **quality percentages** stop improving beyond this table because the user-locked ceiling is 5% Nghịch Thiên / 15% Tuyệt Luân. The disciple's Mị Lực itself is not capped. Mị Lực above 2,500 continues to increase the daily enhanced-Nghịch-Thiên allowance and remains fully available to other social systems.

---

# 8. Daily Mị Lực limit

Mị Lực does not provide its boosted quality table forever during one day.

Current working daily enhanced-Nghịch-Thiên allowance:
- formula: `ceil(Main Guide Mị Lực / 625)` for positive Mị Lực;
- 625 -> 1;
- 1,250 -> 2;
- 1,875 -> 3;
- 2,500 -> 4;
- 5,000 -> 8;
- 10,000 -> 16;
- there is no raw-Mị-Lực hard cap on this allowance.

When the boosted pool has produced that many Nghịch Thiên candidates during the day:
- the entire Dẫn Tiên quality table returns to the normal distribution for the rest of that day;
- natural normal-rate Nghịch Thiên can still appear afterward;
- the limit is therefore a limit on **Mị Lực-enhanced recruitment**, not a hard cap on Nghịch Thiên people.

The counter advances when the candidate appears, not when the player accepts them.

The counter resets next day.

---

# 9. Natural arrivals and Chiêu Mộ Lệnh

Natural Dẫn Tiên arrivals:
- are generated by the daily building/assistant count;
- use that day's snapshotted Main-guide quality rules.

Chiêu Mộ Lệnh:
- creates one immediate additional candidate;
- uses the same current-day Dẫn Tiên quality authority;
- consumes exactly one order;
- does not bypass the daily enhanced-Nghịch-Thiên limit.

This keeps one ordinary-recruitment probability authority.

---

# 10. Premium-jade reference rule

Reference review of 《最强祖师》 shows ordinary sect recruitment primarily uses:
- timed/free recruitment;
- 招募令 (Recruitment Orders);
- daily limited Recruitment Orders purchasable with 灵玉;
while limited/special disciple banners use a separate 寻仙令 currency.

P3.7C1 therefore does **not** make premium jade directly roll a disciple and does not let premium spend bypass the daily Mị Lực limit.

When this project later locks its premium currencies (for example Tiên Ngọc / bound Tiên Ngọc or equivalent):
- ordinary recruitment premium spending should buy Chiêu Mộ Lệnh through an explicit limited shop/rule;
- the resulting order still uses Dẫn Tiên authority;
- special named/limited banners, if ever implemented, must use a separate explicit currency/pool and are outside C1.

No new premium-currency wallet is invented in C1 because the repository does not yet have canonical authority for those currencies.

---

# 11. Compatibility

P0–P2.12 factories remain on the old normalized foundation model.

P3.7 states use open-point foundations.

Old P3.7 saves migrate deterministically:
- normalized values become open points;
- missing legacy dimensions are deterministically filled;
- the birth snapshot is created once;
- Dẫn Tiên Đài is added through building initialization;
- save/load must remain exact after migration.

No reroll of hidden identity is allowed.

---

# 12. Phase boundaries

C1 implements:
- open-point six-foundation persistence/generation;
- derived quality from total;
- initial lục-duy formula authority;
- bounded bridges where old subsystems still require them;
- Dẫn Tiên building;
- main/assistant guide assignment;
- daily arrivals;
- quality cap;
- daily enhanced-Nghịch-Thiên limit;
- Chiêu Mộ Lệnh through Dẫn Tiên;
- save/load/determinism/migration.

C1 does **not** implement:
- a new full Luyện Thể progression system;
- final ATK/DEF/HP stat migration for Tiềm Lực;
- all future Cơ Duyên event tables;
- Dao Companion/social-life systems;
- premium-currency wallet/shop;
- special named limited banners.

Those systems must consume this authority later rather than inventing another lục-duy model.


---

# 13. Closing evidence

Official Godot 4.7.2 GitHub Actions:
- workflow: `P3.7 Backend`;
- run: **#67**;
- run id: `37483719618`;
- job id: `112338256594`;
- tested commit: `a91cb9ba7a3dc775087f5b38e9a3452326f77681`;
- focused P3.7C1 gate: **PASS**;
- full cumulative P0 -> P2.12 -> P3.7A1 -> A2R -> B1 -> C1: **PASS**.

This is official Godot 4.7.2 CI evidence, not Windows evidence.
