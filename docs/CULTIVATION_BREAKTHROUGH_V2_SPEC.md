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


---

## 2.2 Natural Tu Vi source model — USER LOCK 2026-10-09, HUNT XP OWNER AMENDMENT 2026-10-23

Natural Tu Vi is **continuous passive absorption for every living V2 disciple**, not an EXP reward that exists only while the current action is `CULTIVATE`.

Canonical source model:
- every eligible disciple continuously accumulates natural Tu Vi over elapsed simulation time, regardless of ordinary activity such as sect work, travel, hunting or normal combat;
- ordinary work/combat does **not** create a second generic Tu Vi reward on top of this passive absorption;
- `CULTIVATE` means **Chuyên Tu**: the disciple gives up other ordinary activity to apply an explicit multiplier/acceleration to the same natural-Tu-Vi source;
- Tư Chất (+0.25%/point) and other valid natural-cultivation modifiers apply to this natural source;
- external **fixed** Tu Vi is allowed from authored pill consumption **or a legitimate monster-death hunting reward** that passes Combat V2 role/participation gates and commits exactly once; neither source creates another natural-grant tick;
- fixed injections are not multiplied by Tư Chất or ordinary natural-cultivation-rate bonuses;
- **OWNER OVERRIDE 2026-10-23 (supersedes the former ban on direct kill EXP):** a real monster HP > 0 → HP = 0 terminal death in the authorized persistent B3 world directly awards **100% of its authored fixed hunting Tu Vi** to EACH genuinely eligible contributor through one canonical kill/reward transaction, without a mandatory Tinh Nguyên absorption step, return to Sect, or XP claim click. The kill also resolves Sect-owned loot exactly once. **Tinh Nguyên**, if authored later, is an OPTIONAL rare material for alchemy/forge/breakthrough, NOT a required hunting-XP token or a second claim to EXP already awarded by that kill.

**Historical authority note:** the superseded 2026-10-09 rule was "killing a monster does not directly grant Tu Vi; monsters may instead drop Tinh Nguyên to absorb." The owner explicitly reversed **only this hunting reward-source decision** on 2026-10-23 after comparing Direct / Essence / Hybrid. Keep all other clauses in §2.2 and their original dates. This is a **DESIGN LOCK** only; it does NOT attest the new B3 XP ledger is implemented or authorize a CODE packet.

**Non-negotiable boundary for direct hunt XP (DESIGN LOCK):**
- Each real monster generation has **one** terminal death and one sect-loot settlement; each eligible disciple may receive **one** personal `fixed_hunt_tuvi` credit identified by the pair (kill identity, disciple identity). No last-hit ownership, duplicate wave-WIN payout, team-wide EXP to spectators or skin/VFX-triggered reward.
- Meaningful DPS, tanking, effective healing, or useful support may independently establish participation; the **exact numeric eligibility thresholds, grade/rank multipliers and EXP amounts are not locked** by this source-change decision. This must not incentivize 6 DPS or free-riding.
- The existing `DiscipleRealmProgressV2.grant_xp` **fixed** channel and canonical floor-cost table govern awards. No Tư Chất multiplier, no second generic hunting-passive Tu Vi source, no free Body EXP, no unapproved XP bank, no automatic pass through floor-10 major gate. Respect `unapplied_overflow`.
- One authoritative Combat V2 event/receipt and one canonical SaveService transaction cover valid loot + personal effects, including after retry/reload/offline replay. Real offline kills need canonical bounded simulation/replay evidence; a guessed kills/hour cannot mint XP.
- Natural Tu Vi still accrues exactly once per valid simulation minute under its own rules, independent of whether a monster dies. The **1,000,000/day** B3 pill-satiety pool applies to pills, **not** hunting EXP.
- Tinh Nguyên's future optional recipe/drop/quality is **CONTENT DESIGN ONLY**; no Tinh Nguyên-to-XP consumer by default. Any later XP granting Tinh Nguyên requires new owner authorization and anti-double-credit proof.

**Display/balance unit is now locked to Tu Vi per simulation minute.** Current P3.7 time semantics already use one scheduler tick as one simulation minute (1440 ticks/day). A runtime may batch/commit simulation minutes at any wall-clock cadence, but equal simulated minutes must produce equal Tu Vi. Canonical production baseline is now **1,000 Tu Vi per simulation minute** before Tư Chất and other valid natural bonuses.

All newly generated production V2 disciples start at **Phàm Nhân tầng 1, 0 Tu Vi EXP**. Legacy/dev-save migration may use an explicit compatibility mapping only; it is not a recruitment-generation rule.

## 2.3 Canonical progression balance — USER LOCK 2026-10-09

Canonical authority:
- code: `DiscipleProgressionBalanceV2`;
- both Tu Vi and Luyện Thể use the same 300-floor EXP requirement curve;
- realm totals r1..r30 are frozen integers:
  `10000000, 12700000, 16200000, 20500000, 26000000, 33000000, 42000000, 53300000, 67700000, 86000000, 109200000, 138700000, 176000000, 223700000, 284000000, 360700000, 458000000, 581700000, 738700000, 938200000, 1191500000, 1513200000, 1921700000, 2440500000, 3099500000, 3936300000, 4999200000, 6349000000, 8063200000, 10240200000`;
- floor weights inside each realm are `0.70 / 0.75 / 0.80 / 0.85 / 0.90 / 1.00 / 1.10 / 1.20 / 1.30 / 1.40`, summing to 10.0;
- floors 1..9 round to nearest 10 EXP; floor 10 receives the exact residual so each realm total stays exact;
- raw natural Tu Vi baseline = **1,000 Tu Vi / simulation minute**;
- Chuyên Tu multiplier = **×2.0** on the same natural source.

Examples:
- Phàm Nhân total = **10,000,000 EXP**;
- its 10 floors = `700,000 / 750,000 / 800,000 / 850,000 / 900,000 / 1,000,000 / 1,100,000 / 1,200,000 / 1,300,000 / 1,400,000`;
- realm 10 total = **86,000,000**;
- realm 20 total = **938,200,000**;
- realm 30 total = **10,240,200,000**.

Cumulative raw EXP:
- through realm 10 = **367,400,000**;
- through realm 20 = **4,376,300,000**;
- through realm 30 = **48,130,600,000**.

These are balance authorities, not test fixtures.

---

# 3. Major-breakthrough chance

Canonical authority:
- code: `DiscipleBreakthroughBalanceV2`;
- source realm r uses one authored base chance for r -> r+1;
- same-gate pity remains **+5 percentage points per prior failure**;
- failure remains **−10% of floor-10 EXP requirement**, then recultivate;
- no generic HP/Stamina/cooldown penalty;
- no generic Tư Chất/Căn Cốt/Linh Căn/current-HP modifier.

Base chance table:

| Gate | Base |
|---|---:|
| 1→2 | 100% |
| 2→3 | 95% |
| 3→4 | 90% |
| 4→5 | 85% |
| 5→6 | 80% |
| 6→7 | 75% |
| 7→8 | 70% |
| 8→9 | 65% |
| 9→10 | 60% |
| 10→11 | 50% |
| 11→12 | 90% |
| 12→13 | 85% |
| 13→14 | 80% |
| 14→15 | 75% |
| 15→16 | 70% |
| 16→17 | 65% |
| 17→18 | 60% |
| 18→19 | 55% |
| 19→20 | 50% |
| 20→21 | 35% |
| 21→22 | 80% |
| 22→23 | 75% |
| 23→24 | 70% |
| 24→25 | 65% |
| 25→26 | 60% |
| 26→27 | 55% |
| 27→28 | 50% |
| 28→29 | 45% |
| 29→30 | 35% |

Consumable/pill/special-identity modifiers are separate future consumers; they do not rewrite this base table.

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
17. **OWNER 2026-10-23:** real B3 monster death directly grants fixed hunt Tu Vi once per genuinely eligible disciple; Tinh Nguyên is only an optional rare material, not required absorption or a duplicate XP channel. Numeric hunt rates/role thresholds remain DESIGN-OPEN; gameplay implementation requires a separate CODE packet.

---

## Trạng thái code/gate DV2-03 — 09/10/2026 (không thay luật thiết kế ở trên)

- **Tu Vi V2 đã code ở** `DiscipleRealmProgressV2` + `DiscipleTuViFlowV2`: 30 đại cảnh ×10 tầng; new production recruit bắt đầu Phàm Nhân tầng 1/0 EXP; mỗi `SimulationScheduler.step()` (1 phút mô phỏng) nhận đúng một natural Tu Vi source nếu authored content hợp lệ; `CULTIVATE` chỉ tăng tốc cùng nguồn bằng Chuyên Tu multiplier. Tư Chất +0,25%/điểm và source cùng channel cộng trên base; EXP `fixed` không nhân buff.
- **Hàm thử đột phá Tu Vi đã code và PASS test có tham số**: `attempt_cultivation_breakthrough(disciple,rng,gate_required_xp,base_chance,requirements_verified,event_id)`. Tầng 10 đủ EXP, non-chance gate verified, event_id duy nhất; thất bại mất 10% EXP yêu cầu, +5 **điểm phần trăm** xác suất mỗi thất bại cùng cửa, giữ lifetime history; thành công lên đại cảnh sau tầng 1, không gây HP/Thể Lực/hồi chiêu chung. Tại đại cảnh 30 không vượt giới hạn.
- `auto_breakthrough` **mới là cờ lưu policy**, CHƯA có consumer tự thử trong scheduler, không tự ăn đan hay chi trả nguyên liệu. `Tích Tu`/overflow theo cơ chế đặc biệt không tự cộng vào quỹ chung.
- **Production balance now locked in code:** Tu Vi 1,000/phút, Chuyên Tu ×2, shared 300-floor EXP curve and 29 base major-gate chances. **Still not complete gameplay:** consumable/material consumers, automatic breakthrough scheduling, UI and innate-system modifiers remain unconnected. Tuyệt đối **không lấy XP/chance từ `CultivationSystem` P2** để làm dữ liệu V2.
- Lưu/tải `DiscipleState.v2_realm_progress.cultivation` và lịch sử đã code, test JSON roundtrip. Bằng chứng focused Linux Godot 4.7.2: [DV2-03 #37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181) PASS tại `e96df183`. Full P3.7 PASS gần nhất [#37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334) ở **SHA cũ hơn** `5296f610`; không có full PASS sau lệnh `request_training`.
- Nhật ký chi tiết và giới hạn thật: [`DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md`](DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md). Phần này vẫn thuộc **DV2-03 ACTIVE**, không tự nhận CLOSED.
