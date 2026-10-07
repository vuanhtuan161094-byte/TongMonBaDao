# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-07

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
13. live character/trait/combat/work code before proposing the next disciple design.

Fetch live `main` before edits.
Do not ask the user to restate completed lục-duy or Dẫn Tiên decisions.

---

## Current implementation status

**No implementation phase is active.**

P3.7C1 — Open-point Lục Duy + Dẫn Tiên Đài is closed.

Official Godot 4.7.2 closing evidence:
- workflow: `P3.7 Backend`;
- run **#75**;
- run id `37491065054`;
- job id `112363619374`;
- tested SHA `948997f3d101fcd23361cd318ffa130ae97f7e77`;
- focused C1 gate: PASS;
- full cumulative P0 -> P2.12 -> P3.7A1 -> A2R -> B1 -> C1: PASS.

This is CI evidence, not Windows evidence.

---

## Completed six-foundation law

Canonical lục duy:
- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

Locked:
- no permanent hard cap;
- birth rolls Total Birth Lục Duy first;
- ordinary birth distribution ≈ 0.5x–3x six-stat average;
- rare Mệnh Cách/content may break that birth envelope;
- after birth values grow independently;
- immutable birth snapshot is preserved;
- current Disciple Quality derives from current permanent total and can promote;
- same-channel percentage bonuses add on base rather than chain-multiply;
- exact +X items stay exactly +X.

Current balance constants:
- 1 Tư Chất = +0.25% natural/base cultivation;
- 1 Căn Cốt = +0.20% body-training XP;
- 1 Thông Tuệ = +0.15% learning/mastery XP;
- 1 Tiềm Lực = +0.05% future Realm+Body ATK/DEF/HP growth;
- for UI readability think per 100 points as **25% / 20% / 15% / 5%**; do not cosmetically round the backend values.

Cơ Duyên:
`RNG(0..9999) + Cơ Duyên - difficulty`, tiers 6000/8500/9500/9900.

Mị Lực:
general Social Score + Dẫn Tiên-specific authority.

---

## Long-term disciple fantasy

This is not a disposable-character game.

The player may keep one disciple forever and eventually make them absurdly strong/full-everything through enough investment.

Therefore:
- birth changes starting advantage and resource/time cost, not universal final ceiling;
- every major growth axis should eventually have an explicit permanent improvement route;
- toolman/specialist strategies are allowed;
- huge stats should remain meaningfully useful;
- do not add generic diminishing returns merely to suppress power;
- content-specific limits are allowed when explicit, but must not become hidden global stat caps.

---

## Dẫn Tiên result to preserve

Dẫn Tiên Đài:
- Lv1–100;
- one Main Guide affects quality;
- assistants affect quantity only;
- quality odds saturate at current table: max Nghịch Thiên 5%, Tuyệt Luân 15%;
- raw Mị Lực itself is **not capped**;
- enhanced Nghịch Thiên allowance = `ceil(Main Mị Lực / 625)`;
- 2,500 -> 4/day; 5,000 -> 8/day; 10,000 -> 16/day;
- after allowance is consumed, quality rates return to normal until next day;
- normal-rate Nghịch Thiên may still appear;
- counter advances on appearance;
- daily snapshot blocks guide-swap reset;
- assistants: +1 arrival/day per 500 Mị Lực, no raw Mị Lực cap;
- base arrivals = `5 + 3 × floor(level/10)`: Lv1=5/day, Lv100=35/day;
- guide slots = 1 at Lv1, +1 at Lv20/40/60/80/100;
- Chiêu Mộ Lệnh uses the same pool and daily authority.

Premium-currency direction:
- no canonical Tiên Ngọc/Tiên Ngọc Khóa wallet yet;
- future ordinary premium spending should buy limited Chiêu Mộ Lệnh through an explicit shop/rule;
- it must not bypass Dẫn Tiên odds/allowance;
- future limited/named banners are separate explicit content.

---

## Future rules already agreed but not implemented

### Pill satiety
- one satiety system;
- character has base capacity;
- resets daily;
- each pill defines its own satiety cost;
- no automatic satiety by vague rarity category;
- fixed-value pill rewards remain fixed.

### Breakthrough V2
- failure loses 10% of the Tu Vi/EXP requirement;
- each failure adds +5 percentage points to the next attempt;
- breakthrough pills/items may raise success chance;
- max 3 breakthrough-boosting pills per attempt.

Do not claim these are already implemented.

---

## Reference lessons to keep from 《最强祖师》

Use as inspiration, not copying:
- six foundations should have genuinely different jobs;
- quality summarizes the person but does not define all value;
- high Wisdom/Charm/Fortune specialists can be strategically excellent;
- character development continues after recruitment;
- content-specific thresholds are better than global final caps;
- physiques/traits should change rules, tradeoffs or paths, not all be flat Attack;
- whole-person generation is more interesting than one rarity roll;
- five-element roots and mutation-root ideas are worth evaluating next;
- realtime combat must not blindly copy turn-based speed/balance.

Never copy its assets/text/icons/map.

---

## SPIRITUAL ROOT V2 — FULL DESIGN LOCKED

Canonical authority:
`docs/SPIRITUAL_ROOT_V2_SPEC.md`

Locked:
- base Kim/Mộc/Thủy/Hỏa/Thổ;
- root-count rates 7/18/30/28/17%;
- independent purity 1–100;
- deterministic refinement and missing-root creation;
- root buffs/passives + perfected-root Resonance;
- Ngũ Hành combat matchup;
- congenital Dị-Căn rate 0.20% total (0.19% latent, 0.01% awakened);
- Lôi/Phong/Băng/Dương/U Minh Thức Tỉnh → Thuế Biến → Viên Mãn;
- five matching Dị Bản Nguyên resources;
- Lôi Thiên Lôi timing;
- Phong Thế timing;
- Băng Hàn-Ấn/Băng-Phong/Hàn-Trệ timing;
- Dương Bạo source-owned DoT conversion;
- U Minh once-per-encounter Minh Mệnh;
- all five mutations may coexist;
- cả năm Dị Căn Viên Mãn -> Ngũ Dị Quy Nhất;
- proc-loop, AoE, multi-hit, boss, AI, persistence and migration rules.

No Spiritual Root V2 gameplay code is authorized yet.

Legacy boundary:
- `docs/P2_10_SPIRITUAL_ROOT_REFINEMENT_SPEC.md` is compatibility-only and superseded by `docs/SPIRITUAL_ROOT_V2_SPEC.md`;
- old root runtime files remain only for locked P2 regression and future old-save migration;
- do not extend the legacy global-purity/old-mutation model;
- physically remove dead legacy runtime only when a tested Spiritual Root V2 migration phase replaces it.

Implementation dependency:
do not implement mutation combat with temporary private stats. It requires the relevant Skill/Combat V2 primitives or must wait for that combat phase.

Combat Stats V2 is DESIGN LOCKED, NOT IMPLEMENTED.
Canonical authority:
`docs/COMBAT_STATS_V2_SPEC.md`

Disciple Characteristics & Stat Framework V2 is DESIGN LOCKED, NOT IMPLEMENTED.
Canonical authority:
`docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`

It locks:
- source/state/derived/outcome separation;
- living-state taxonomy;
- modifier modes and provenance;
- Healing Done / Healing Received / Shield Effect and other specialized effect channels;
- future-system ownership boundaries.

Traits V2 is DESIGN LOCKED, NOT IMPLEMENTED.
Canonical authority:
`docs/TRAITS_V2_SPEC.md`

Preserve:
- 60/32/8% visible birth count;
- 8% ordinary latent rate, max one;
- 50/30/20% Hữu Ích/Song Diện/Bất Lợi;
- no universal Trait grade;
- no lifetime Trait cap;
- deterministic reveal/acquisition/removal;
- consumer gating;
- Personality/profession talent separation.

Current design subject:
**Mệnh Cách V2**.

Draft:
`docs/DESTINY_V2_SPEC.md`

Status:
**DESIGN DRAFT — NOT IMPLEMENTED — NOT LOCKED**.

Review especially:
- canonical merge of old Thiên Mệnh wording into Mệnh Cách;
- 0.10% congenital rate;
- one active Chủ Mệnh;
- Tiềm/Hiển/Khai/Hóa/Chứng states;
- Mệnh Kiếp milestone progression;
- Mệnh Nguyên source/cost loop;
- post-birth chosen acquisition;
- starter Mệnh Cách catalogue.

Do not collapse Mệnh Cách into Trait.
