# MỆNH CÁCH V2 — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-07
Status: **REDESIGN DRAFT FOR USER REVIEW — NOT IMPLEMENTED — NOT LOCKED**

Parents:
- `docs/GAME_SYSTEM_ARCHITECTURE.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`
- `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`
- `docs/COMBAT_STATS_V2_SPEC.md`
- `docs/TRAITS_V2_SPEC.md`

This revision explicitly supersedes the earlier "one active Chủ Mệnh + universal Khai/Hóa/Chứng ladder" draft.

No gameplay implementation is authorized by this draft.

---

# 1. Core fantasy

A Mệnh Cách must make the player say:

> "Con này có Mệnh này, nuôi theo kiểu này sẽ rất khác."

It must not feel like:
- Trait +5%;
- one more rarity color;
- a long paragraph whose gameplay result is unclear.

Canonical direction:

**Mệnh Cách = a rare, high-impact law attached to one person's fate.**

Each Mệnh Cách must have:
1. a one-sentence **Luật Mệnh** readable by a normal player;
2. a strong immediate gameplay consequence;
3. at least one rule-changing / conditional / progression interaction that Traits normally do not own.

---

# 2. Old Thiên Mệnh terminology

The old future label **Thiên Mệnh** and the new Mệnh Cách concept are merged into one system.

Canonical system name:
**Mệnh Cách**.

Do not build:
- Mệnh Cách;
- plus another generic Thiên Mệnh layer.

Individual content names may still contain "Thiên Mệnh", "Thiên Quyến", etc.

---

# 3. Multiple Mệnh Cách are allowed

A disciple may own **multiple Mệnh Cách simultaneously**.

There is:
- no one-active-Chủ-Mệnh slot;
- no lifetime hard cap.

Every revealed, non-sealed compatible Mệnh Cách is active.

Same Mệnh Cách ID cannot duplicate-stack.

Practical control comes from:
- extreme rarity;
- major content requirements;
- Mệnh Nguyên cost;
- explicit conflict rules;
- unique boss/event conditions;
- long-term acquisition time.

This intentionally supports the favorite-disciple fantasy:
with enough years/resources/content, one disciple may become a terrifying collection of compatible fates.

---

# 4. Bản Mệnh is history, not a slot

If a Mệnh Cách is congenital, mark it as:
**Bản Mệnh / Bẩm Sinh**.

This means:
- the disciple was born with it;
- it may influence birth finalization if the definition explicitly says so;
- its birth identity is immutable history.

It does **not** mean only that Mệnh Cách can be active.

Post-birth Mệnh Cách are marked:
**Hậu Thiên**.

Both may be active together.

---

# 5. Simple state model

Remove the universal:
Tiềm -> Hiển -> Khai -> Hóa -> Chứng progression.

Canonical state per Mệnh Cách:

- **Tiềm Ẩn** — congenital identity exists, hidden, inactive.
- **Hiển Lộ** — known and active.
- **Phong Ấn** — known but temporarily inactive due to explicit conflict/content.
- **Đã Mất** — only for rare content that explicitly removes a fate; history remains.

Most Mệnh Cách is already fully meaningful once Hiển Lộ.

A specific Mệnh Cách may have its own:
- evolution;
- transformation;
- accumulation counter;
- upgraded form.

But this is content-specific, never a universal five-stage ladder.

---

# 6. Birth rarity

Starting ordinary congenital target remains intentionally rare:

- 99.90%: no congenital Mệnh Cách;
- 0.09%: one latent congenital Mệnh Cách;
- 0.01%: one already-revealed congenital Mệnh Cách.

Total:
**0.10% ≈ 1 / 1,000 generated people**.

Ordinary birth has at most one congenital Mệnh Cách.

Special named/story/event people may explicitly break that rule.

This low birth rate is acceptable because Mệnh Cách is also a long-term **acquirable collection system**, not birth-only gacha.

---

# 7. Independence from headline quality

Normal congenital Mệnh Cách roll is independent from:
- Disciple Quality;
- Dẫn Tiên quality table;
- Trait;
- Root/Dị Root;
- future Bloodline;
- future Physique.

A Phàm Thường may carry a terrifying Mệnh Cách.

A Nghịch Thiên may have none.

Dẫn Tiên Main Guide does not silently boost Mệnh Cách rate.

---

# 8. Birth override is allowed, but explicit

Some Bản Mệnh may change birth finalization.

Definition may declare:
`birth_override`.

Examples:
- minimum one Lục-Duy dimension;
- unusual starting age/realm;
- starting mastery/history;
- special birth resource.

Rules:
- deterministic;
- happens before immutable birth snapshot is finalized;
- visible in the Mệnh Cách description once revealed;
- never rerolls another hidden subsystem;
- most Mệnh Cách should not need this.

Mệnh Cách may break ordinary Lục-Duy birth envelope because the master schema already reserves this rare exception.

---

# 9. Mệnh Nguyên

Canonical rare fate resource:
**Mệnh Nguyên**.

Used for:
- post-birth acquisition;
- content-specific Mệnh evolution;
- future fate transformation/sealing/removal.

It uses the canonical Sect Warehouse.

Starting source direction:
- destiny-grade Secret Realm first clear: 1 guaranteed;
- tagged major world-boss first clear: 1 guaranteed;
- highest-tier meaningful Cơ-Duyên event may award 1;
- tagged repeat world/boss content: low chance for 1;
- long-form world/sect fate events: explicit reward.

No Mệnh consumer may ship before real acquisition content exists.

Mệnh Nguyên is not premium-only.

---

# 10. Post-birth acquisition

A disciple may acquire additional Mệnh Cách.

There is no universal "buy any fate for 8 Mệnh Nguyên" button.

Each Mệnh Cách defines a **Cải Mệnh recipe**:

- explicit prerequisite/history;
- explicit Mệnh Nguyên cost;
- optional unique item/event/boss requirement.

Once requirements are met:
- player chooses to perform the acquisition;
- deterministic success;
- no reroll;
- no generic fail chance.

Congenital ownership skips the acquisition recipe for that fate.

This makes each fate feel earned rather than purchased from one generic menu.

---

# 11. Mệnh Cách conflict

Most Mệnh Cách may coexist.

Only genuinely contradictory fate laws conflict.

A definition may declare:
- explicit incompatible IDs;
- a conflict group.

If player attempts to acquire a conflicting fate:
- acquisition is blocked;
- UI explains why.

A hidden congenital fate must not leak through this check.
If a newly acquired fate conflicts with a hidden congenital fate:
- acquisition proceeds;
- when latent fate reveals, the latent one becomes **Phong Ấn**;
- no reroll/deletion;
- future Cải Mệnh content may resolve the conflict.

---

# 12. Mệnh Cục — combination destiny

Multiple Mệnh Cách may unlock a **Mệnh Cục**.

A Mệnh Cục:
- is derived;
- cannot be directly rolled or bought;
- does not count as another owned Mệnh Cách;
- activates automatically when all required Mệnh Cách are active.

This is one of the main reasons multiple fate ownership matters.

Example:

**Sát Phá Lang**
requires:
- Thất Sát;
- Phá Quân;
- Tham Lang.

Derived effect is much stronger than any one component and creates a distinct build.

Mệnh Cục is analogous to a set bonus, but lore/gameplay belongs to fate.

---

# 13. Readability contract

Every Mệnh Cách UI entry has:

1. **Name**
2. **One-line Luật Mệnh**
3. **Effects** — maximum normal target 2–4 short bullets
4. **How to acquire** if known
5. **Conflicts / Mệnh Cục links** if any

Do not require the player to read lore paragraphs to know what it does.

Example UI:

**Đại Khí Vãn Thành**  
*Tu chậm lúc đầu, càng vượt đại cảnh giới càng tăng trưởng khủng.*

- Tu Vi tự nhiên -15%.
- Mỗi đại cảnh giới đã vượt: +8% tăng trưởng Công/Thủ/HP từ Cảnh Giới + Luyện Thể.
- Tính cả các đại cảnh giới đã vượt trước khi hậu thiên nhận Mệnh này.

That is sufficient to understand the build.

---

# 14. Power standard

A normal Trait may give:
- +10% Work Speed;
- +5 pp Crit;
- +15% Healing.

A Mệnh Cách is allowed to give:
- +25–40% in a restricted build context;
- extra casts;
- cooldown resets;
- lethal interception;
- permanent boss-derived growth;
- Luck tier promotion;
- altered breakthrough failure law;
- major resource duplication;
- retention through death/rebirth.

If a proposed Mệnh Cách could be converted into one ordinary Trait line without losing identity, it is probably too weak.

---

# 15. Starter high-impact Mệnh Cách catalogue

Numbers below are starting balance targets, not implementation authorization.

## 15.1 Đại Khí Vãn Thành — phát triển dài hạn

**Luật Mệnh:** Tu chậm lúc đầu; mỗi đại cảnh giới đã vượt khiến tăng trưởng thân–cảnh giới về sau mạnh hơn vĩnh viễn.

Effects:
- natural cultivation gain **-15%**;
- every completed **major realm breakthrough** grants one permanent Hậu-Phát mark;
- each mark gives **+8% Realm+Luyện-Thể core ATK/DEF/HP growth**;
- when acquired post-birth, existing completed major-realm history immediately creates the matching marks.

No arbitrary mark cap.
Natural limit comes from actual major realms/content.

This is intentionally extremely good on a disciple kept for years.

Consumer-gated:
final Realm/Luyện Thể growth authority.

Acquisition target:
- complete at least 3 major realm breakthroughs;
- 8 Mệnh Nguyên.

---

## 15.2 Hồng Trần Luyện Tâm — breakthrough/failure build

**Luật Mệnh:** Đột phá thất bại không còn là mất trắng; mỗi lần thất bại làm lần sau dễ hơn rất nhiều.

Once Breakthrough V2 is active:
- breakthrough failure loses **0%** Tu Vi instead of the normal locked 10%;
- failure bonus to next attempt becomes **+15 percentage points** instead of +5;
- after 3 consecutive failures on the same breakthrough, the next attempt is guaranteed if all mandatory non-chance requirements are satisfied.

The counter resets after success.

This is immediately understandable and highly practical.

Acquisition target:
- personally fail 3 real breakthrough attempts over life;
- then complete a special Tâm-Kiếp event;
- 6 Mệnh Nguyên.

Consumer-gated to Breakthrough V2.

---

## 15.3 Phá Quân — vượt cấp chiến

**Luật Mệnh:** Càng đánh kẻ mạnh hơn mình, càng hung.

Against encounters at least one explicit danger/realm tier above the disciple:
- **+25% All Damage**;
- **+15% Defense Penetration**;
- first elite/boss defeat by this disciple each encounter reduces all currently-running skill cooldowns by **50% of remaining time**.

No Combat Rating comparison.
Use explicit content danger/realm tier.

Acquisition target:
- defeat 3 distinct qualifying higher-tier elites/bosses;
- 8 Mệnh Nguyên.

---

## 15.4 Thất Sát — liên sát build

**Luật Mệnh:** Mỗi mạng hạ trong trận làm sát khí càng mạnh.

Each personal enemy defeat grants one Sát Ý stack until encounter end:
- +5% All Damage;
- +3% Attack Speed;
- +3% Cast Speed.

Stacks are limited only by actual valid enemies in the encounter.
Summoned disposable units do not count unless content explicitly marks them as valid.

On defeating an elite/boss:
- immediately gain 3 stacks.

No carryover between encounters.

Acquisition target:
- achieve a designated real kill-streak feat;
- 6 Mệnh Nguyên.

---

## 15.5 Tham Lang — tham chiến / hấp thu tài nguyên

**Luật Mệnh:** Đánh kẻ mạnh để cướp lợi ích về cho bản thân.

On first personal defeat of each unique elite/boss ID:
- gain one permanent **Tham Lang Ấn**;
- each Ấn gives **+1% Max HP and +1% All Damage**.

Unique-ID first defeat only.
Repeating the same boss never grants another mark.

This creates permanent growth from exploration without per-tick farming.

Acquisition target:
- personally first-kill 5 distinct elites/bosses;
- 10 Mệnh Nguyên.

---

## 15.6 Sát Phá Lang — Mệnh Cục

Requires active:
- Thất Sát;
- Phá Quân;
- Tham Lang.

**Luật Mệnh Cục:** Gặp cường địch càng đánh càng bùng nổ.

Derived effects in qualifying higher-tier encounters:
- Sát Ý stack values are doubled;
- personal elite/boss defeat **fully resets the shortest currently-running skill cooldown**;
- first time HP falls below 30% each encounter: gain **20% Damage Reduction for 5s**.

Cannot be acquired directly.

This is the target standard for a memorable fate-combination payoff.

---

## 15.7 Thiên Sát Cô Tinh — solo / last-stand

**Luật Mệnh:** Không có đồng đội bên cạnh thì sức chiến đấu tăng vọt.

When entering combat with no allied combatant, or when this disciple becomes the last standing allied combatant:
- +35% All Damage;
- +20 pp Crit Chance;
- +20% Damage Reduction;
- +20% Movement Speed.

When an ally becomes active again, bonus ends immediately.

Later Social V2 may add a social cost only if that system needs it.
Do not ship a fake social penalty now.

Acquisition target:
- solo-clear one designated high-risk encounter;
- 10 Mệnh Nguyên.

---

## 15.8 Gặp Dữ Hóa Lành — survival/event fate

**Luật Mệnh:** Tai họa lớn lần đầu thường bị hạ xuống một bậc.

Combat:
- first lethal hit each encounter leaves the disciple at **1 HP** instead;
- cleanse one ordinary control effect;
- 3s incoming damage ×0.70;
- once per encounter.

World/event:
- once per simulation day, one explicitly tagged **major-negative event outcome** is downgraded by one severity tier;
- cannot turn a negative event into a jackpot;
- only content with severity tiers may use it.

If another lethal-intercept effect exists, canonical lethal-intercept priority must resolve one at a time.

Acquisition target:
- survive a designated calamity/near-death event;
- 12 Mệnh Nguyên.

---

## 15.9 Thiên Quyến Hồng Phúc — fortune build

**Luật Mệnh:** Những lần “suýt đủ may” được Thiên Đạo đẩy lên kết quả tốt hơn.

For the first **2 meaningful Luck Score checks per simulation day**:
- if result is below the next tier by at most **1,000 points**, promote it exactly one tier.

Additionally:
- first naturally reached highest-tier Luck outcome each 30 simulation days grants **one extra roll on that event's explicit bonus-reward table**, if that event has one.

No effect on:
- combat hit rolls;
- per-tick farming;
- fixed rewards;
- events without canonical Luck Score.

Does not change stored Cơ Duyên.

Acquisition target:
- experience 3 distinct highest-tier Cơ-Duyên outcomes;
- 12 Mệnh Nguyên.

---

## 15.10 Thôn Thiên — boss-growth fate

**Luật Mệnh:** Giết cường địch để nuốt một phần “thế” của chúng thành tăng trưởng vĩnh viễn.

First personal defeat of each unique destiny-tagged boss:
- gain one Thôn-Thiên mark.

Each mark:
- +2% Realm+Luyện-Thể core ATK/DEF/HP growth;
- +1% Effect Resistance.

Unique boss only.
No repeat farm.

This Mệnh Cách may naturally become enormous as the game adds major bosses.
That is intentional long-term content scaling.

Acquisition target:
- first-clear a designated Thôn-Thiên event/boss;
- 15 Mệnh Nguyên.

---

## 15.11 Vạn Pháp Quy Nhất — multi-path combat

**Luật Mệnh:** Liên tục đổi Kiếm/Thể/Pháp để lấy sức mạnh từ việc thông nhiều đạo.

Passive:
- +25% learning/mastery XP to the disciple's currently lowest Kiếm/Thể/Pháp path.

Combat:
when a combat skill's path differs from the previous combat skill cast by this disciple:
- +20% Skill Effect for this cast;
- ordinary resulting cooldown ×0.80.

Alternating back and forth can repeatedly trigger.
Same-path consecutive casts do not.

This creates an actual multi-path rotation instead of a generic learning buff.

Acquisition target:
- all three paths have real learned content;
- each path has at least one mastered skill/technique milestone;
- 10 Mệnh Nguyên.

---

## 15.12 Kiếm Tiên Chuyển Thế — past-life sword fate

**Luật Mệnh:** Kiếm đạo như ký ức kiếp trước; học nhanh, dùng kiếm vượt chuẩn.

Effects:
- Sword path/mastery XP +40%;
- Sword-tagged Skill Effect +25%;
- first eligible Sword direct-damage skill cast each encounter is guaranteed to Crit;
- may ignore one future ordinary **learning prerequisite** tied only to Sword-path depth, but may not ignore realm/resource/item prerequisites.

This is deliberately much stronger than the Trait `Kiếm Cảm`.

Birth package if congenital and revealed:
- starts with a small deterministic Sword-path history/milestone, not a random skill reroll.

Acquisition target:
- extremely high Sword history/mastery;
- one specific Sword inheritance event;
- 15 Mệnh Nguyên.

---

## 15.13 Dược Vương Tại Thế — healer destiny

**Luật Mệnh:** Cứu người càng nguy cấp, trị liệu càng vượt chuẩn.

Effects:
- Healing Done +30%;
- Healing Received +20%;
- when healing an ally below 30% HP:
  - that heal gains another +30% effect;
  - remove one ordinary removable debuff/control after the heal;
- first time each encounter this disciple prevents an ally from falling to 0 HP through healing/shielding:
  - immediately refresh 50% of the remaining cooldown of the disciple's longest-cooldown eligible support skill.

No fake medicine-crafting bonus until that profession exists.

Acquisition target:
- meet real healing-history thresholds;
- complete a medical inheritance/event;
- 10 Mệnh Nguyên.

---

## 15.14 Tài Tinh Nhập Mệnh — production/economy fate

**Luật Mệnh:** Làm ra đồ quý thì thường được “thêm một phần”.

For explicit work/crafting tasks with a canonical rare/quality Luck check:
- effective Luck Score for that check +1,500 without changing stored Cơ Duyên.

Once per simulation day:
- first work result that naturally reaches the task's highest rare/quality tier produces **+100% stackable output quantity** for the eligible product.

Does not duplicate:
- unique equipment;
- quest items;
- first-clear rewards;
- non-stackable special artifacts.

Acquisition target:
- produce several distinct highest-tier work outcomes;
- 8 Mệnh Nguyên.

Consumer-gated where final crafting-quality authority is missing.

---

## 15.15 Bách Kiếp Bất Diệt — adversity growth

**Luật Mệnh:** Mỗi đại kiếp thật sự sống sót làm bản thân khó chết hơn vĩnh viễn.

For each **unique major-calamity event ID** personally survived:
- gain one Bách-Kiếp mark.

Each mark:
- +2% Max HP;
- +1% Damage Reduction.

Only events explicitly tagged `major_calamity` count.
Repeat of the same event ID gives nothing.

No arbitrary numeric hard cap.
The natural limit is unique calamity content.

Acquisition target:
- survive the first major calamity;
- 10 Mệnh Nguyên.

---

## 15.16 Thiên Đố Anh Tài — huge power for lifespan

**Luật Mệnh:** Tu và học cực nhanh, đổi bằng thọ mệnh.

Target effects:
- cultivation gain +35%;
- all valid learning/mastery XP +35%;
- profession XP +20%;
- current maximum lifespan ×0.60.

This is **consumer_gated** until final Age/Lifespan/Ma-Hồn rules are closed.

Do not ship only the positive portion.

The large numbers are intentional because the cost must also be real.

---

## 15.17 Túc Tuệ Chuyển Thế — rebirth preservation

**Luật Mệnh:** Chết/luân hồi không làm mất phần lớn kiến thức tích lũy.

Future target:
- after valid Ma/Hồn/rebirth transformation, preserve 100% technique mastery, profession XP and path XP that ordinary rebirth would otherwise partially lose;
- additionally retain a defined subset of relationship/memory history.

This is **future_only** until Ma/Hồn/revival has canonical loss rules.

---

## 15.18 Đoạt Mệnh — collect other destinies

**Luật Mệnh:** Hạ kẻ mang Mệnh Cách để rút Mệnh Mảnh, dùng chính số mảnh đó học Mệnh của chúng.

Future rule:
when personally defeating a valid hostile character/boss that owns a Mệnh Cách:
- if that fate is eligible for extraction, gain one Mệnh Mảnh for that specific fate;
- collect 3 matching fragments -> unlock that fate's Cải-Mệnh recipe at **50% normal Mệnh Nguyên cost**.

Does not:
- steal/delete victim's fate;
- instantly copy on one kill;
- work on summoned/farmed duplicate NPCs.

Consumer-gated to future hostile-NPC fate content.

This is a direct long-term multiple-Mệnh collection engine.

---

# 16. Mệnh Cục examples beyond Sát Phá Lang

## Phúc Họa Tương Y
Requires:
- Thiên Quyến Hồng Phúc;
- Gặp Dữ Hóa Lành.

Effect:
- when the daily negative-event downgrade triggers, the next meaningful Luck Score check that day gets +2,000 effective score.
- cannot chain itself.

## Vạn Kiếp Hậu Phát
Requires:
- Đại Khí Vãn Thành;
- Bách Kiếp Bất Diệt.

Effect:
- each Bách-Kiếp mark also gives +2% cultivation gain.
- each Hậu-Phát mark also gives +1% Healing Received.

This turns two long-life destinies into one extreme veteran build.

## Y Kiếm Song Tuyệt
Future example requiring:
- Kiếm Tiên Chuyển Thế;
- Dược Vương Tại Thế.

Effect target:
- after casting an eligible support skill on an ally, next Sword skill within 5s gets +25% Skill Effect;
- after landing an eligible Sword Crit, next heal/shield within 5s gets +25% effect.

This demonstrates that Mệnh Cục may create hybrid builds rather than only vertical power.

---

# 17. Why this is not Trait V2

Trait example:
**Kiếm Cảm**
- +12% Sword mastery XP;
- +8% Sword skill effect.

Mệnh example:
**Kiếm Tiên Chuyển Thế**
- +40% Sword mastery;
- +25% Sword skill effect;
- first Sword skill guaranteed Crit each encounter;
- may bypass one Sword-only learning-depth prerequisite.

Mệnh is allowed to be dramatically more defining.

---

# 18. Why this is not Physique / Root / Bloodline

Do not use Mệnh Cách to fake:
- elemental purity;
- body constitution;
- blood species;
- special organs/body form.

Mệnh Cách describes:
- fate;
- history law;
- event law;
- exceptional progression law;
- rule-changing combat/economy/luck behavior.

"Thần Thể" belongs to Physique.
"Lôi Linh Căn" belongs to Root.
"Chân Long Huyết" belongs to Bloodline.

"Kiếm Tiên Chuyển Thế" can be Mệnh Cách because it is a past-life destiny, not the body's structure.

---

# 19. Acquisition philosophy

Every Mệnh Cách should answer:

**Sinh ra có thì lời ở đâu?**
- earlier access;
- skips difficult prerequisite;
- may apply a birth package.

**Sinh ra không có thì lấy thế nào?**
- explicit major feat/event;
- explicit Mệnh Nguyên cost;
- deterministic acquisition.

**Nuôi favorite lâu dài có lấy được không?**
- yes, unless it is explicitly a story-exclusive identity;
- story-exclusive exceptions must be rare and visible.

This preserves rare birth excitement without disposable-character design.

---

# 20. Persistence target

```
destiny_model_version = 2

destiny_profile = {
  "initialized": true,

  "birth_destinies": [
    {
      "destiny_id": "...",
      "birth_state": "latent|revealed"
    }
  ],

  "owned": {
    "destiny_id": {
      "origin": "birth|acquired|story|extracted",
      "state": "latent|revealed|sealed|lost",
      "counters": {},
      "unique_marks": []
    }
  },

  "history": [
    {
      "event": "born|revealed|acquired|sealed|unsealed|lost",
      "destiny_id": "...",
      "source": "...",
      "tick": 0
    }
  ]
}
```

Mệnh Cục is derived and not separately saved as owned identity.

Static effect tables remain content registry data.

---

# 21. Large-roster runtime

Do not poll all Mệnh Cách every tick.

Event-driven hooks:
- major breakthrough;
- encounter start/end;
- personal defeat/kill;
- elite/boss first defeat;
- lethal interception;
- meaningful Luck Score event;
- work/crafting rare result;
- healing attribution;
- major calamity;
- rebirth.

Unique-ID marks use sparse sets.

Background farmers do not run combat-fate logic.

---

# 22. AI

AI may read revealed Mệnh Cách hints.

Examples:
- Phá Quân values higher-tier targets;
- Vạn Pháp Quy Nhất alternates path skills;
- Dược Vương prioritizes endangered allies;
- Thiên Sát Cô Tinh may prefer solo assignment.

Hidden Mệnh Cách has zero AI influence before reveal.

Player orders override ordinary preferences.

---

# 23. Reveal

Congenital latent identity:
- exists before candidate display;
- no gameplay effect before reveal;
- no AI effect;
- no UI hint that a hidden fate exists.

Each fate has its own reveal rule or future appraisal route.

Reveal only reveals the stored fate.
Never reroll.

---

# 24. Implementation invariants

When eventually implemented:

1. same seed/source/index = same congenital fate identity;
2. normal quality/Dẫn Tiên do not alter fate roll;
3. ordinary birth max one congenital fate;
4. latent fate has zero effect before reveal;
5. reveal never rerolls;
6. multiple compatible revealed Mệnh Cách are simultaneously active;
7. there is no one-active-Chủ-Mệnh slot;
8. no lifetime fate hard cap exists;
9. same fate ID cannot duplicate-stack;
10. hidden conflicts do not leak latent identity;
11. Mệnh Cục derives only from currently active required fates;
12. removing/sealing one required fate disables its Mệnh Cục immediately;
13. post-birth acquisition is deterministic after explicit requirements/cost;
14. no generic fate XP exists;
15. no universal Khai/Hóa/Chứng ladder exists;
16. permanent unique-boss/calamity marks cannot be repeat-farmed;
17. fixed-value rewards/items remain fixed unless the Mệnh specifically owns that rule;
18. rule effects use canonical combat/work/luck authorities;
19. future-only/consumer-gated effects cannot activate early;
20. save/load preserves all owned fates, marks and history exactly;
21. large-roster runtime does not per-tick poll every fate;
22. proc/trigger effects cannot recursively self-trigger unless explicitly allowed.

---

# 25. Revised design decisions proposed for user review

1. multiple Mệnh Cách may coexist and all compatible revealed fates are active;
2. no active Chủ-Mệnh slot;
3. no lifetime hard cap;
4. Bản Mệnh is birth-history label, not exclusive active slot;
5. keep congenital rarity target 0.10% for now;
6. ordinary birth max one congenital fate;
7. remove generic Khai/Hóa/Chứng progression;
8. each fate is already strongly useful on reveal;
9. specific fates may have their own counters/evolution only when meaningful;
10. Mệnh Cục provides derived bonuses for fate combinations;
11. each fate must have a one-line understandable law + 2–4 concrete effects;
12. Mệnh effects are intentionally much stronger than Traits;
13. Mệnh Nguyên remains universal rare acquisition resource;
14. every post-birth fate has an explicit feat/event + resource recipe rather than one generic shop;
15. same fate final effect is not weaker merely because it was acquired later;
16. long-term favorite disciple may eventually collect many compatible fates;
17. starter catalogue above is the new power/readability standard.

No gameplay implementation is authorized until the redesigned system is reviewed and locked.
