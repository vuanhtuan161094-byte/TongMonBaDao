# TÔNG MÔN BÁ ĐẠO — B3 V2 / END-TO-END GAMEPLAY GAP AUDIT

**Date:** 2026-10-22. **Type:** gameplay/backend audit + prioritized DESIGN recommendations; **NO CODE, NO MERGE, NO PH0/SOURCE A/CHARACTER STUDIO/V5 edits**. Main SHA audited: `461caca1171462e0da092f21108c5c1733157ad9`. Source A independently converts, Codex separately validates B3-PH0; PH0 official Godot PASS not yet in evidence. This doc is a *planning priority*, NOT authorization to silently alter locked rules.

**Legend:** I = code implemented/real APIs confirmed (does not imply live game acceptance); P = partial/pilot/legacy; D = design/spec only; U = unauthored/unimplemented. Specific documented rules outrank illustrative ideas.

## 1. Player journey audit (ordered as actually played)

| # | Moment / player question | What live main contains | Gaps that prevent meaningful gameplay | Priority |
|---|---|---|---|---|
| 01 | First launch — what do I do? | `LiveGameRuntimeV2`, P37Factory, persistent world economy, existing landscape UI; opening loops tested | 3 clear initial objectives, obvious unlock progression, next-action suggestions tied to actual resources; without artificial quests spam | P1 |
| 02 | Recruit disciples — why is this disciple good? | `RecruitmentSystem`, Dẫn Tiên day ticks, V2 birth envelope, foundation/roots/traits, canonical profiles | Full birth identity completeness, real strengths/weaknesses reflected in team/professions, preview needed; no fake quality-to-faction assignment | P1 |
| 03 | Assign — who works vs hunts? | `WorkforceSystem`, `OrganizationSystem` max 6/team, `One Active Job`, professions, GP02B1 occupancy, real producer jobs | Shift/backup assignment, team presets, fatigue/downtime policies, replacement without job theft; dynamic reserve for sick/dead | P1 |
| 04 | Cultivate — what gains Tu Vi? | `DiscipleTuViFlowV2.resolve_minute`: natural Tu Vi once per scheduler minute; specialized Chuyên Tu multiplier; canonical V2 realm/body 30×10, no automatic major-gate bypass | Meaningful earned consumables and priority: Tinh Nguyên vs direct kill XP; daily saturation; manual/auto medication; breakthrough planning | P0 |
| 05 | Train body — how? | `DiscipleBodyTrainingFacilityV2`: 2 available Lv1 slots, 1 Stone/minute, base 1500 Body XP/minute, action sources + recorded facility reservations | Clear sources for active expedition tempering and later grades/intensities; no generic XP for idle/combat by default | P1 |
| 06 | Produce medicine/equipment — what exactly can I make? | `BuildingSystem` mine/forest/field/timed alchemy; `AlchemyRecipeRegistry` **ONLY hoi_xuan_dan** recipe, 3 thanh_linh_thao→1 pill, 6 ticks, +55 HP when consumed; P2 `EquipmentSystem` craft/3 ordinary slots | Actual Tu Vi/Body/Breakthrough/Lifespan pills, production recipes and ingredient economics, V2 10-slot/12-quality forge upgrade loop not implemented | P0 for 2–3 first useful medicine recipes after content approval; P1 for equipment V2 |
| 07 | Eat pills — how many/day? | `NeedsSystem.use_healing_pill` consumes Hoi Xuan Dan from one canonical Warehouse at Sect while HP not full; **no shared daily satiety counter** or per-disciple pill-cap implementation found. | Single deterministic `pill_satiety_used` indexed by canonical simulation-day, per-pill cost, reject at cap, no double consume on restart, auto-use thresholds; distinguish day 1440 ticks vs real 24h | P0 |
| 08 | Form team/prepare supplies | `DiscipleCombatLoadoutV2.build` real gear/learned skills + canonical realm; `HuntingPveRunV2.begin` checks Injury/HP/jobs; P1.6 stock+depart stamina pilot | Physically authored outward **consumable belt**, replenishment and role-aware AI purchasing; selected monster/zone risk; actual return-to-sect travel, not instant | P0 before live B3 launch |
| 09 | Roam and fight in persistent area | Finite `MapBattleV2` 0.25sec, MAX_SECONDS=90 and V2 cast/RNG, B2.4 local continuous/spawn sandbox; PH0 patch awaiting Codex Godot QA | PH0: robust continuous domain HP0; PH1: real disciple/respawn owner; AI aggro/leash/threat, on-target selection, healer/tank real actions, 1 world HP for bosses; avoid 90sec wave reset | P0 |
| 10 | Defeat, retreat, revival — how long? | `HuntingPveRunV2._settle_terminal` real finite battle: downed at <=0 HP→set live HP **1**, Injury **1**, `injury_recover_at_tick=state.tick+120`, teleport back Sect (pilot no travel delay). `SimulationScheduler._step_disciple` clears Injury when at Sect at/after deadline. One sim minute=60 wall seconds currently. | World continuous party-down return/recovery/AI substitution; triage/Y Quán, consumables, recovery ETA and re-entry policy. **No permanent death or automatic lifespan deduction on ordinary combat defeat** | P0 |
| 11 | Loot per monster — what happens? | Legacy `HuntingMapV2.claim_reward` only on finite encounter WIN; registered canonical resource warehouse; B2.4 receipt copied into isolated sandbox only | HP0 immutable per-slot-generation receipt, frozen content revisions, registered per-kill materials, duplicate/crash/overflow proof, special/unique Sect-owned item owner, no 100% test linh_moc in production | P0 |
| 12 | Become stronger from hunting | Natural cultivation always runs while eligible; `CombatSkillSystem` learned skill sources; P3.7 growth spec proposes activity-scaled Tu Vi and role participation, B3 boss credit design | **Design conflict:** `CULTIVATION_BREAKTHROUGH_V2_SPEC` §2.2 locks monster HP0 NOT directly granting Tu Vi, instead monster-dropped **Tinh Nguyên then absorption**; B3 proposals contain per-action/per-kill personal Tu Vi. Owner must choose source/consumer to avoid double credit, with no disguised overwrite. Skill mastery only on effective action | P0 policy |
| 13 | Recover/stock up/return to hunt | NeedsSystem rest +5 HP and conditional stamina; heal medicine stock, Economy-A personal HP service; town economy and auto equipment exist | Medical hall with real duration/cost, no instant re-entry exploit after Downed, consumable priority under shortage, team reserve and supply logistics | P0 |
| 14 | Breakthrough to new realm | `DiscipleRealmProgressV2.attempt_canonical_cultivation_breakthrough`, authored chance/failure/gates, max3 breakthrough consumables design; Body major gate transactions exist | Actual named support pills/sources, scheduling policies and protection from losing earned materials; no uncontrolled auto breakthrough | P1 |
| 15 | Age, lifespan, rare death | `DiscipleState` stores `age/base_lifespan/max_lifespan`; canon specifies older disciple at death-age becomes persistent ghost/Ma-Hồn; only expulsion removes roster. | No verified scheduler aging yearly cadence, near-limit event, ghost state/actions, lifespan increase/restore source or revival receipt on main. **HP0 ≠ age death**. Strong gameplay but depends on defining age/calendar mapping | P2 |
| 16 | Long-term Sect progression and economy | Main Hall/building upgrades, wage/market/stones, profession, relationships, techniques and equipment P2 sample | V2 gear 10 ordinary slots, high-grade forge, quality and set crafting, rare maps/Boss rotation, research/sect buffs, a reason to upgrade beyond production rates; meaningful long-term sinks and scarcity forecasts | P1/P2 |
| 17 | Offline / save / crash recovery | `SaveService.CURRENT_VERSION=2` staged .tmp/.bak, `SimulationRuntimeClockV2` single minute clock and bounded backlog. V2 finite PvE has settlement receipts | Persistent world snapshots, monster/generation RNG, **per-kill receipt+Warehouse exactly once**, timebase 0.25 battle substeps vs 60-second scheduler tick, offline deterministic equivalence; do not invent average loot/hour | P0 |
| 18 | Control/readability | Map/UX presentation streams are separate and owner visual PENDING | Team readiness, return ETA, pill counts, drop logs and warnings sourced from backend truth, not UI-generated resources | P1 |

**Important status clarification:** having fields, formula classes or a design spec ≠ complete live mechanic. No runtime tests were run for this audit. B3 PH0 is in Codex validation, NOT claimed integrated.

## 2. Direct answers to owner's examples; no invented live rates

### 2.1 When HP reaches zero — current code's exact interpretation
- This is a **downed state in the finite V2 PvE settlement**, not death/removal/ghost. It **sets one survivor HP** and Injury 1, returns the disciple instantly to Sect in this pilot, and stamps injury recovery at `tick+120`.
- 1 scheduler tick = 1 minute simulation, current runtime maps 60 wall seconds to a tick: **120 ticks ~120 real minutes** if time progresses normally. This duration is canonical for current GP02C1 and MUST NOT silently change as a balance tweak. The code clears Injury on a Sect scheduler tick when `state.tick >= injury_recover_at_tick`; realtime countdown must cite same owner, no separate timer.
- `NeedsSystem.apply_rest` and `EconomySystem.heal` adjust HP; **they do not clear Injury early** by default. Distinguish HP recovery from Injury.
- No ordinary downed → age/lifespan decrement exists in reviewed settlement. Longevity loss applies only if a future **specific authored special source** declares it; everyday defeat must not arbitrarily take age.
- **Proposed but not locked** recovery enrichment: Y Quán / treatment cost/duration and explicit medical pill effects on injury; 120-tick base remains until owner explicitly approves new injury schedule. For playfeel try bounded doctor bypass with explicit resource expense only after a separate policy approval; no hidden hardcoded quicker duration.
- Current prototype instant return is real in code but separate travel recovery is OPEN.

### 2.2 Longevity/Ma-Hồn
- `docs/DISCIPLE_LIFESPAN_CANON.md` gives *not permanent roster deletion*, age may eventually reach limit, character becomes `ghost` with memory/progression/gear relationship intact, and Thọ Đan can revive if `lifespan_max > age`. Special attacks/forbidden techniques may consume lifespan only if explicitly authored.
- Not implemented end-to-end; no game-day→year duration is locked. The code has only three numeric lifespan/age fields and roundtrip. Do not call this an implemented resurrection timer.
- Later design should specify (a) age increment cadence, (b) warnings 3/1 years or proportionate, (c) sect physical tasks disabled during ghost state, (d) priority to inherit work/roles, (e) revive receipt and one paid Thọ Đan transaction. **Do not implement ghost death before aging cadence and eligibility invariants are designed.**

### 2.3 Pill families, recipes and daily counts

**Actual production medicine:** only `hoi_xuan_dan` listed in `AlchemyRecipeRegistry` (3 herbs, 6 ticks, +55 live HP when consumed by `NeedsSystem.use_healing_pill`). No actual crafted Tu Vi/Body/Breakthrough/Longevity pill recipes in that registry. `P2` may contain legacy medicine stock, not equivalent to a V2 pill table.

**Already locked design:** single shared satiety pool per canonical day, explicit satiety cost per pill; max **3** special consumables for one major breakthrough attempt; **exact daily capacity and cost are OPEN**. Existing Hoi Xuan Dan use has no per-day cap.

**Pilot recommendation ONLY, requires owner acceptance before code/balance:**
| Proposed content ID / displayed name | Effect / source | Satiety cost if pool=100/day | Maximum if only taking this pill | Guard |
|---|---|---:|---:|---|
| `tu_khi_dan` — Tụ Khí Đan | fixed authored Tu Vi injection, does not multiply natural baseline | 25 | 4/day | stage-relative diminishing utility, no overflow across major gate |
| `ngung_nguyen_dan` — Ngưng Nguyên Đan | stronger fixed Tu Vi; ingredients higher rarity | 40 | 2/day | 2×40=80, not 3 |
| `duong_the_dan` — Dưỡng Thể Đan | fixed Body EXP only from item source | 40 | 2/day | no generic monster-kill Body EXP |
| `pha_canh_dan` — Phá Cảnh Đan | named eligible major-breakthrough assistance, not guaranteed pass | 70 | 1/day | combined 3 item slot gate remains |
| `hoi_xuan_dan` — Hồi Xuân Đan | **existing** +55 HP in Sect | 10 | 10/day | under consideration whether basic restorative HP pill should share satiety; if excluded, define explicitly, never silently |
| `tho_nguyen_dan` — Thọ Nguyên Đan | later longevity / Ma-Hồn recovery | specific future | NOT LOCKED | need diminishing returns + life-year calendar first |
- For mixed use, `sum(satiety_cost_i) <= 100/day` per real DiscipleState and absolute simulation-day index `floor(tick/1440)`, not 24h device clock. Counts are **suggestions**, not data in runtime or prior canon.
- Guard: no consumption of registered Warehouse item unless eligible and stat effect can be applied; failed cap/invalid realm/ghost/overflow must not debit. Persist `last_satiety_day,used`, derive time from one existing tick authority and apply safe save migration, exactly once with receipt.
- Plan first **two recipes** instead of authoring 30: actual Tu Vi pill and one injury/retreat medicine; then Body pill and breakthrough pill after combat/recovery integration. Introduce a third true material source only when farm/drop content exists.

### 2.4 Critical conflict: Tu Vi from hunting

**Strict older locked spec** `docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md`: ordinary monster HP0 grants NO direct generic Tu Vi; monster may drop **Tinh Nguyên**, which grants Tu Vi when separately absorbed/assigned (fixed +X). B3 reward/participation docs propose personal actual-combat Tu Vi per kill. These mechanics cannot silently both apply. Proposed safest bridge:
1. Normal kill gives registered Tinh Nguyên to Sect-owned channel via same immutable kill receipt (if and only if new content is approved).
2. Disciple obtains Tu Vi **once** on a separate explicit absorption/assigned-consumption receipt, with participation policy governing which participants can receive/consume it.
3. Boss contribution allocates **Tinh Nguyên eligibility/participation** rather than second automatic EXP. If owner prefers direct Tu Vi per kill, explicitly authorize override of old Section 2.2; do not implement both.
4. Passive Tu Vi continues once/min regardless of work/hunting, not doubled.

## 3. Priority based on real play rather than feature volume

**P0 — Unblock meaningful first hunt (after PH0 focused PASS, only separately authorized code):**
1. **PH1A+PH1B** real disciple/world/spawn/admission with one world owner. Old scheduler reservations and work must never be stolen.
2. **PH2** one normal per-kill material + immutable death receipt + authoritative warehouse/save; requires a user-approved drop table or explicit source.
3. **PH3** one scheduler clock + bounded offline combat, no second tick creator; no fake long-term yields.
4. **RECOVERY-V1** actual player policy on downed→Sect→Injury timer→medicine→reentry; keep current 120-tick until explicit override.
5. **PILL-V1** one shared daily cap, 1–2 approved recipes with real source/consume flow and UI-backed policy.
6. **TUVI-SOURCE-DECISION** Tinh Nguyên separate absorption vs direct Boss contribution reward; resolve before wiring PH2 reward.

**P1 — Meaningful content after a first loop is demonstrated:**
7. AI choose farming site by missing resource/target realm, healer/tank utility and actual causal contribution; safe retreat, restocking and replacement.
8. Expanded medicine/Body EXP sources + breakthrough policies, specialty professions, meaningful time/cost and second-region difficulty.
9. V2 equipment 10-slot/12-grade/set forge chain and item progression, market/service economy and rare gear goals; do not confuse P2 three equipped slots with V2 finished.
10. Configurable short-term objectives (build alchemy hall, recruit hunter, unlock zone, defeat boss, craft first set); no forced story grinding.
11. Transparent in-game signals: HP/injury countdown, estimated supplies, warehouse shortage, drop receipts, Tu Vi source breakdown, possible warning for time to breakthrough.

**P2 — Longer-term personality and Sect identity:**
12. Aging and no-permanent-loss Ma/Hồn cycle with thọ đan and inheritance, only once calendar mapping accepted.
13. Sect research/factions, achievements, exploration/bí cảnh, raid Boss tiers, unique quest chains, social and trait effects backed by canonical state.
14. Large-roster 1,000–3,000 scheduling/scaling, seasonal/world events, data-driven economy balancing.

## 4. Acceptance fixtures the NEXT gameplay design packet must cover

- R01: HP0→HP1 and Injury1 for exactly 120 ticks on Sect; HP heal does NOT bypass Injury.
- R02: repeated save/load of injured character and recovery tick does not duplicate reward / prematurely clear injury.
- R03: downed squad cannot restart battle or harvest ghost loot while marked unavailable.
- R04: never decrement age/lifespan from ordinary HP0 or retreat.
- R05: ghost/Ma-Hồn cannot be accidentally triggered by HP0 while age < limit.
- P01: one daily satiety counter across all cultivation/breakthrough categories; mix+restart rejects over-cap.
- P02: single pill consume stages Warehouse debit, Tu Vi/Body/HP change and saturation record atomically, no effects on invalid realm/overflow.
- P03: no new recipes beyond ResourceRegistry materials (source content gate); automatic pill AI consumes from actual inventory only.
- P04: breakthrough three-item limit and shared satiety both enforced.
- L01: normal monster HP0 creates one kill receipt and one approved resource drop, not legacy encounter WIN claim.
- L02: Tinh Nguyên credited once on real absorption rather than both direct kill and pill.
- L03: offline/save/restart preserves pending kill/loot/absorption and one-world time.
- T01: explicit role team occupancy/One Active Job prevents mining+HUNT double activity.
- T02: no arbitrary double passive Tu Vi with hunting, rest or work.
- T03: runtime official Godot 4.7.2, existing Injury/warehouse/PvE/save regressions on the exact new file SHA; no acceptance from design alone.

## 5. Recommended next isolated DESIGN ticket — NO CODE authority

**B3-MED-01 — Injury / Y Quán / first Tu Vi pill / shared daily satiety, decision packet**, AFTER PH0 test report but preparation can happen read-only now. Read main `NeedsSystem`, `AlchemyRecipeRegistry`, `DiscipleRealmProgressV2`, `DiscipleTuViFlowV2`, `SaveService`, `HuntingPveRunV2`, the above relevant specs, and current B3 PH1–PH3. Freeze no numeric balance without owner choice. Produce exactly one narrow CODE allowlist proposal after PH2 lifecycle interfaces stabilize. Do not modify any runtime or Source A while PH0 is pending.

**No CODEx PH0 result has been ingested; no new gameplay files were edited.**
