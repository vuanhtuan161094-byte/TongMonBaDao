# LUYỆN THỂ V2 + THỂ LỰC VIỄN CHINH — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-07
Status: **CORE DESIGN LOCKED — NOT IMPLEMENTED**

Parents:
- `docs/REALM_LADDER_V2_SPEC.md`
- `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`
- `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`
- `docs/COMBAT_STATS_V2_SPEC.md`

Legacy compatibility source:
- `docs/P2_12_PHYSIQUE_SPEC.md`
- `godot/src/simulation/physique/physique_system.gd`

This document locks the Luyện Thể core direction and the expedition-only Stamina role.
Thể Chất/Physique V2 is now separately locked in `docs/PHYSIQUE_V2_SPEC.md`.

No gameplay implementation is authorized by this design lock.

---

# 1. Separation of systems

Luyện Thể and Thể Chất are not the same subsystem.

**Luyện Thể**
- universal progression;
- every disciple may train it;
- owns body-training EXP/progression;
- contributes permanent Body Core;
- determines expedition endurance against map body pressure.

**Thể Chất**
- special body identity/mechanic;
- may be absent;
- will be designed separately after Luyện Thể.

Do not make a special Physique mandatory for Luyện Thể.

---

# 2. Realm ladder

Canonical realm order:
`docs/REALM_LADDER_V2_SPEC.md`

Luyện Thể has:
- 30 đại cảnh;
- 10 floors each;
- 300 total global floors;
- 3 macro bands: Nhân Giới / Tiên Giới / Thần Giới.

Tu Vi and Luyện Thể are independent.
Neither silently hard-locks the other.

---

# 3. Core growth ownership

Luyện Thể contributes reconstructible **Body Core**:
- Body Core Max HP;
- Body Core Defense;
- Body Core Attack.

Design identity:
**HP > Defense > Attack** as the general body-training emphasis.

Exact numeric tables remain future combat/economy balance data.

Derived final Realm + Body core values must consume current Tiềm Lực authority.

Locked Tiềm Lực law:
- 1 Tiềm Lực = +0.05% to the future Realm + Luyện Thể ATK/DEF/HP core component;
- the effect is retroactive;
- increasing Tiềm Lực later recomputes previously earned Realm/Body Core;
- do not bake one-time permanent stat increments that lose source provenance.

---

# 4. Luyện Thể EXP and Căn Cốt

Locked Căn Cốt law:
- 1 Căn Cốt = +0.20% natural/base Luyện Thể EXP.

For natural body-training gain:

`effective_body_xp = base_body_xp × (1 + 0.002 × CanCot + sum(other_body_xp_bonuses))`

Same-channel percentage bonuses are additive on base.

Fixed-value rewards remain fixed.

Example:
- item says +10,000 Luyện Thể EXP;
- result is exactly +10,000;
- Căn Cốt does not silently multiply that fixed reward.

Exact base XP curve across 300 floors remains balance work.

---


---

## 4.1 Luyện Thể source model — USER LOCK 2026-10-09

Luyện Thể deliberately does **not** mirror passive Tu Vi absorption.

Canonical source model:
- newly generated production V2 disciples start at **Phàm Thân tầng 1, 0 Luyện Thể EXP**;
- ordinary sect work, travel, hunting, standing idle and normal combat do not generically grant Luyện Thể EXP;
- natural/base Luyện Thể EXP exists only from an **explicit authored Luyện Thể source**;
- the concrete training activity model is **OPEN**: no `TRAIN_BODY` action, duration unit, EXP/time rate, facility interaction or body-training schedule is locked yet;
- Căn Cốt (+0.20%/point) and valid body-training modifiers apply to those natural/base body-training sources;
- pills, medicinal baths, monster materials/essence, events or other content may grant fixed +X Body EXP when explicitly authored;
- fixed +X Body EXP is not multiplied by Căn Cốt unless that content explicitly declares itself scalable.

This asymmetry is intentional: **Tu Vi is ambient spiritual absorption; Luyện Thể requires actual tempering.**

### Dedicated Rèn Thân Đường V1 — USER LOCK 2026-10-10

The approved implementation uses a **separate Rèn Thân Đường** building, not a shared slot in Tu Luyện Đài.
- Lv1 has exactly **2 training slots**. Normal building maximum is Lv100; slot scaling, upgrade recipes and higher grades remain unapproved. Do not fabricate upgrade effects.
- Only an authentic V2 disciple explicitly assigned a real available Rèn Thân Đường slot may use the `TRAIN_BODY` activity. A training policy `body_focus` may select this action only with verified access; if unavailable it may fall back to valid Chuyên Tu without granting fake Body EXP.
- Each verified active simulation minute costs exactly **1 Sect Spirit Stone**, debited atomically from the existing Sect treasury first. No free trial minute and no debt.
- Once the minute's cost has been committed, gain the **1,500 base Body EXP/minute** source, then apply the already-locked Căn Cốt +0.20%/point and legitimate named Body modifiers. Natural grants obey the existing one-disciple/one-Body-source-per-minute dedup.
- A failed prereq, full major gate, insufficient Spirit Stones, occupied/invalid slot, blocked action or duplicate minute causes **no charge and no Body EXP**. An EXP commit failure rolls back the minute charge.
- Rèn Thân at the sect never spends Expedition Stamina. It never adds a second passive Tu Vi grant: the ambient Tu Vi owner remains unchanged.
- This initial content uses one grade/rate only. Training intensity tiers, level-based training bonuses, material recipes, Thối Thể gate packages and visual UI are separate future approvals.

## 4.2 Natural Body EXP source contract — USER LOCK 2026-10-09

Luyện Thể has three distinct **natural** source contexts. They share one Căn Cốt formula, but they are not interchangeable gameplay activities.

### A. Production / Sản xuất

- only **active physically demanding production time** may grant natural Body EXP;
- a job/facility being assigned or passively counting down is not enough;
- the profession/work consumer must explicitly verify that the current work phase carries body load;
- this is a **low-rate secondary source**, not a replacement for dedicated Rèn Thân;
- exact eligible professions and rates remain content work.

### B. Dedicated body training / Rèn Thân

- this is the **primary controllable Luyện Thể source**;
- gain is normalized as **Luyện Thể EXP per simulation minute**;
- it requires a real future training-facility/content consumer to verify access/slot and selected training grade;
- the consumer must successfully commit that minute's cost **before** Body EXP is granted;
- training grade/intensity may raise both EXP/minute and economic cost;
- cost direction may use Linh Thạch and/or explicit materials, but the building name, grade count, unlock levels, resource IDs, quantities and formulas are deliberately deferred;
- Rèn Thân inside the sect does **not** spend Expedition Stamina.

### C. Expedition / Viễn chinh

- only verified active outside-map expedition time may grant natural Body EXP;
- it is a distinct source from in-sect production and dedicated Rèn Thân;
- killing a monster does not directly create generic Body EXP;
- expedition/body-pressure content may author the per-minute base rate later;
- Expedition Stamina remains the outside-map endurance cost and is not replaced by Body EXP.

### Shared accounting

All three natural sources use:

`effective_body_xp = source_base_body_xp_per_minute × (1 + 0.002 × CanCot + sum(other_body_xp_bonuses))`

Rules:
- one disciple may receive **at most one natural Body source per simulation minute**;
- production and dedicated Rèn Thân are in-sect sources; expedition is an outside-map source;
- buffs such as Dược Dục modify the chosen natural source instead of creating a second generic grant;
- fixed +X Body EXP remains a separate `fixed` path and is not multiplied by Căn Cốt;
- source-specific numeric rates are content/balance data and are **not locked yet**.

Canonical raw reference rates are now:
- physically demanding production: **250 Body EXP/minute**;
- active expedition: **750 Body EXP/minute**;
- dedicated Rèn Thân: **1,500 Body EXP/minute**.

Therefore the normal reference ratio is **1 : 3 : 6** (production : expedition : Rèn Thân), before Căn Cốt and valid Body modifiers. Specific authored content may scale from these references, but generic production must not become the optimal Body-EXP farm and ordinary low-risk expedition must not obsolete dedicated Rèn Thân.

**Implementation boundary:** `DiscipleBodyXpSourceV2` now owns typed source validation/accounting and one-source-per-minute dedup. No training building, resource cost table, profession eligibility list or expedition pressure table is implemented by this contract.

---

## 4.3 Canonical Body progression + major gates — USER LOCK 2026-10-09

- Body uses the same 300-floor XP requirement table as Tu Vi, owned by `DiscipleProgressionBalanceV2`.
- Minor floors auto-advance on sufficient EXP.
- Every one of the 29 Body major gates is **deterministic**.
- Gate rule: floor 10 EXP full + authored Thối Thể requirements verified -> **100% advance to next realm floor 1**.
- Body gates have **no RNG, no pity, no generic failure EXP loss and no generic failure HP/Stamina penalty**.
- Detailed material/resource packages remain future content. The core progression contract only receives a verified requirement result.
- Canonical runtime wrapper: `DiscipleRealmProgressV2.commit_canonical_body_gate()`.

---
# 5. Thể Lực V2 definition

Player-facing name:
**Thể Lực**

Canonical backend/authority meaning:
**Thể Lực Viễn Chinh / Expedition Stamina**.

It answers one question:

> How long can this disciple remain active on an outside-map expedition before the expedition must end?

It is NOT:
- a production-efficiency stat;
- an in-sect worker stamina bar;
- an Attack/Defense multiplier;
- a generic action point system.

---

# 6. Strict consumer boundary

Thể Lực V2 is consumed only by outside-map expedition gameplay.

Valid consumers may include:
- travel on external maps;
- exploration;
- external-map combat time;
- hunting;
- heavy gathering on external maps;
- harsh-map/environment endurance;
- explicit expedition events.

It must NOT be consumed by ordinary in-sect activity:
- Spirit Field;
- Mine/building work inside the sect simulation;
- warehouse/logistics inside sect;
- alchemy/crafting;
- office/management;
- cultivation/meditation;
- Luyện Thể training itself;
- ordinary walking inside the sect.

Production does not read current Thể Lực and does not receive a productivity multiplier from it.

This boundary exists deliberately to keep the large-roster economy manageable.

---

# 7. Daily budget

Base daily Expedition Stamina:

**100 points per disciple per sect day.**

The budget resets once per day.

Important anti-exploit rule:
- an active expedition does not receive a second full refill in the middle of that same expedition merely because the calendar reset is crossed;
- the daily refill applies to the next eligible expedition state/return cycle;
- implementation must not permit departure just before reset to double one expedition's budget.

Exact reset scheduling belongs to the future map runtime, but the no-mid-expedition-double-refill rule is canonical.

---

# 8. Maximum expedition duration

Default single-expedition hard cap:

**24 hours.**

This is a content cap for ordinary daily expedition loops, not a cap on disciple power.

No amount of ordinary Luyện Thể alone extends a default expedition beyond 24h.

Future explicit multi-day expedition content may override this with its own rules.

---

# 9. Map body requirement

Each external map/activity may define:

`recommended_body_global_floor`

using the 1..300 Luyện Thể coordinate.

This is a recommendation/pressure reference, NOT a hard entry requirement.

A disciple below the recommendation may still enter if other game rules allow it.

The consequence is shorter sustainable expedition time.

---

# 10. Normal-map endurance curve

For a normal map:

- exact match between disciple Luyện Thể global floor and map recommended body floor gives about **18 hours** of unbuffed expedition time;
- higher body training increases duration;
- lower body training decreases duration smoothly;
- Luyện Thể alone cannot reach the full 24h cap.

Let:

`gap = (disciple_body_global_floor - map_recommended_body_global_floor) / 10.0`

Then body-only target duration is:

`body_hours_raw = 18 × 1.20^gap`

Body-only duration is capped at:

**22 hours**

before external temporary expedition buffs.

Equivalent intuition:
- +10 Luyện Thể floors ≈ ×1.20 endurance time;
- -10 floors ≈ ÷1.20;
- every individual floor matters smoothly.

Starting examples on a normal map:

| Body difference vs recommendation | Approx. body-only duration |
|---:|---:|
| -50 floors / -5 realms | 7.2h |
| -30 floors / -3 realms | 10.4h |
| -20 floors / -2 realms | 12.5h |
| -10 floors / -1 realm | 15.0h |
| exact floor match | **18.0h** |
| +5 floors | 19.7h |
| +9 floors | 21.2h |
| +10 floors / +1 realm | 21.6h |
| sufficiently overleveled | **22.0h body-only cap** |

Therefore even a disciple in the same major Luyện Thể realm as the map cannot automatically assume 24h endurance.

This intentionally leaves room for food, pills, facilities and special character effects.

---

# 11. Temporary expedition support

External support may raise practical endurance toward the 24h cap.

Canonical future sources may include:
- **Ngự Thiện Phòng / expedition meals**;
- pills/elixirs;
- explicit Traits;
- Bloodlines;
- future Physiques;
- equipment/treasures;
- map-preparation buildings;
- team/support effects.

These effects must explicitly state their expedition-stamina behavior.

Allowed concepts include:
- +fixed daily Expedition Stamina;
- +% Expedition Stamina budget;
- explicit map-stamina consumption reduction;
- fixed stamina restoration during an expedition.

Do not let unrelated generic production buffs affect expedition stamina.

The normal default hard cap remains 24h after ordinary buffs unless content explicitly overrides it.

---

# 12. Why 18h / 22h / 24h

The curve deliberately creates three useful states:

### Match map recommendation
About **18h**.

The character is appropriate for the map but cannot fully exploit a 24h expedition window with no preparation.

### Overtrain Luyện Thể
Body-only rises toward **22h**.

Extra Luyện Thể remains useful even after reaching the map's recommended band.

### Prepare the expedition
Food/pills/facilities/special effects bridge the remaining gap to **24h**.

This gives support content real value without making support mandatory just to enter the map.

---

# 13. Example — Sáng Thế map

Example normal map:
- recommended Luyện Thể = Sáng Thế Thần Thể tầng 1;
- default expedition cap = 24h.

A disciple at exactly:
- Sáng Thế Thần Thể tầng 1
- receives about 18h body-only endurance.

A disciple at:
- Sáng Thế Thần Thể tầng 10
- is +9 floors;
- receives about 21.2h body-only endurance.

Even the latter still does not reach 24h from Luyện Thể alone.

A meal/pill/facility package can push the trip to 24h.

A disciple one full realm below the recommendation gets roughly 15h before support buffs.

A disciple several realms below may still enter, but the sustainable trip becomes much shorter.

---

# 14. Expedition depth interaction

Maps may place higher-value content deeper into an expedition window.

Illustrative content layout:
- early window: common areas;
- middle window: deeper gathering/events;
- late window: core area;
- final hours: boss/rare node/treasure opportunity.

This means the difference between 18h and 24h can be strategically meaningful without directly nerfing combat stats.

Exact map schedules are map-design data, not locked by this spec.

---

# 15. What happens at zero Stamina

When the expedition's available Stamina is exhausted:
- do not apply a hidden production penalty;
- do not globally reduce Attack/Defense;
- do not make the character die from stamina alone.

Default direction:
- finish/resolve the current atomic expedition action safely;
- then end/return from the expedition according to future map-runtime rules.

Combat already has HP and canonical combat stats.
Thể Lực V2 should remain an expedition-duration resource, not a second combat health bar.

---

# 16. Production non-interference

This is a hard design boundary.

Two disciples with identical profession/facility/assignment state but different Expedition Stamina:
- perform ordinary sect production at the same rate;
- are not forced to rest from production because Expedition Stamina is low;
- do not gain a hidden production bonus from high Luyện Thể merely through this stamina system.

Luyện Thể may affect other gameplay only through explicit future channels.
Do not smuggle map stamina into economy calculations.

---

# 17. Relationship to Physique V2

Canonical authority:
`docs/PHYSIQUE_V2_SPEC.md`

Physique may explicitly:
- modify Body Core;
- reduce named expedition cost components;
- specialize certain environments;
- alter canonical combat/effect channels.

Physique does not own the base expedition system.

Luyện Thể + map recommendation must function for a disciple with no special Physique.

P2.12 `temper_level 0..5` is not V2 authority.

---

# 18. Implementation invariants for a future phase

A future implementation must prove at minimum:

1. 30 Luyện Thể realms × 10 floors map to 1..300 deterministically;
2. Căn Cốt affects natural/base Luyện Thể XP at +0.20% per point;
3. fixed +X body XP remains fixed;
4. Tiềm Lực affects Realm+Body Core retroactively at +0.05% per point;
5. production never reads or drains Expedition Stamina;
6. base daily Expedition Stamina = 100;
7. same-floor normal-map match produces about 18h body-only duration;
8. +10 body floors produces about ×1.20 body endurance before cap;
9. body-only duration caps at 22h;
10. ordinary expedition duration caps at 24h after buffs;
11. a below-recommendation character is not hard-blocked solely by body floor;
12. daily reset cannot double-refill one active expedition;
13. food/pill/facility modifiers use explicit expedition channels;
14. reaching zero stamina ends the expedition flow without hidden combat-stat penalties;
15. save/load and deterministic continuation preserve progression and active expedition budget;
16. old P2.12 runtime remains compatibility-only until an explicit migration phase;
17. earlier locked cumulative gates remain green.

---

# 19. Still intentionally open

Not locked yet:
- exact body EXP curve for floors 1..300;
- exact Body Core ATK/DEF/HP table;
- exact major-body-realm breakthrough recipes;
- exact automatic/major breakthrough flow if later changed;
- exact Ngự Thiện Phòng meal list;
- exact pill values/use limits;
- special environment modifiers;
- injury interactions;
- Physique V2;
- map runtime implementation.

These require their own design/balance pass.

---

## Trạng thái triển khai Luyện Thể DV2-03 — 09/10/2026 (không thay thiết kế đã khóa)

- **Đã code + focused Godot PASS**: `DiscipleState.v2_realm_progress.body` (30 đại cảnh × 10 tầng; tên đúng ladder), `DiscipleRealmProgressV2.grant_xp(...,"body",...)`, tăng tầng nhỏ tự động theo EXP, `Căn Cốt +0,20%/điểm` cho EXP natural, cộng buff hợp lệ cùng channel và giữ thưởng `fixed` chính xác, dừng ở cửa đại cảnh.
- **Latest code safety state, runtime gate chưa xác minh**: generic Body progression + Căn Cốt scaling and the typed source authority (`production` / `body_training` / `expedition`) exist. The real Rèn Thân facility/cost consumer is still **NOT IMPLEMENTED**; provisional `TRAIN_BODY` therefore remains fail-closed and cannot fabricate EXP.
- **Chưa có quyền coi hoàn thành**: `commit_authorized_body_gate` chỉ là hàm commit sau khi consumer khác đã xác minh EXP/điều kiện; chưa có tỷ lệ thử đột phá, vật liệu, thất bại riêng cho Luyện Thể đã duyệt. Không được sao chép xác suất Tu Vi; không tự rút HP/Thể Lực Viễn Chinh từ hành động TRAIN_BODY.
- **Chưa thiết kế/triển khai đầy đủ**: hoạt động Luyện Thể cụ thể, nguồn natural Body EXP, đơn vị/thời lượng, công trình/vật liệu, 300 yêu cầu EXP, major-gate content, lịch persistent/offline, màn hình V2, và tiêu hao **Thể Lực Viễn Chinh** ngoài map. Các số test như 50 EXP/action và 100 EXP/tầng chỉ là fixture, không phải balance.
- **FOCUSED Godot 4.7.2 Linux PASS** [#37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181) tại `e96df183`. Full P3.7 PASS được xác minh [#37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334) tại mã cũ `5296f610`. Không phải Windows PASS hay lệnh V2 UI PASS.
- Tiến độ kỹ thuật và kiểm thử: [`DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md`](DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md). Các định nghĩa Thể Lực Viễn Chinh bên trên **vẫn là thiết kế**, không hiểu nhầm thành code.
