# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-09

## Read first — mandatory order for character work

1. `AGENTS.md`
2. `docs/GAME_SYSTEM_ARCHITECTURE.md`
3. `CURRENT_CHECKPOINT.md`
4. `docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md` — **NEW PRIMARY ACTIVE DESIGN/IMPLEMENTATION ROADMAP, no code yet**
5. `docs/DISCIPLE_MASTER_SCHEMA.md`
6. `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`
7. `docs/DISCIPLE_V2_DESIGN_LEDGER.md`
8. `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`
9. `docs/COMBAT_STATS_V2_SPEC.md`
10. `docs/REALM_LADDER_V2_SPEC.md`
11. `docs/BODY_CULTIVATION_V2_SPEC.md`
12. `docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md`
13. `docs/SPIRITUAL_ROOT_V2_SPEC.md`
14. `docs/TRAITS_V2_SPEC.md`
15. `docs/DESTINY_V2_SPEC.md`
16. `docs/BLOODLINE_V2_SPEC.md`
17. `docs/PHYSIQUE_V2_SPEC.md`
18. `docs/TECHNIQUE_V2_SPEC.md`
19. `docs/CULTIVATION_PATH_V2_SPEC.md`
20. `docs/COMBAT_SKILLS_V2_SPEC.md`
21. **Live actual code/tests**: P3.7C1, recruitment/candidate/disciple_state, character modifiers, legacy combat, P3.2 tabs.
22. For compatibility **only**: `docs/WEAPON_EQUIPMENT_V2_SPEC.md` and `docs/EQUIPMENT_SETS_V2_SPEC.md`. Gear-forging roadmap is **deferred**.

Fetch live `main` before all work. Do not ask user to repeat approved design already in repo. Newer user priority: **real V2 characters first; ordinary item forging, Pháp Bảo and Phù later**. 

## Current implementation status

**DV2-01 IMPLEMENTATION IS ACTIVE (2026-10-09). DV2-01A opt-in birth envelope is implemented but DV2-01 is NOT closed.**

The last backend-closed implementation remains:
P3.7C1 — Open-point Lục Duy + Dẫn Tiên Đài.

Godot 4.7.2 CI closing evidence remains recorded in `CURRENT_CHECKPOINT.md`.

All V2 systems named below are design authorities only unless the checkpoint explicitly says otherwise.

---

## Disciple V2 design status

Design-closed:
- Spiritual Root / Ngũ Hành / Dị Linh Căn;
- Combat Stats;
- Disciple Characteristic Framework;
- Traits;
- Mệnh Cách;
- Bloodline;
- Realm Ladder;
- Luyện Thể core + Expedition Stamina;
- Physique base;
- Cultivation + Breakthrough;
- Công Pháp;
- Chủ Đạo / Đạo Lịch;
- Combat Skills;
- Kiếm Tu / Thể Tu / Pháp Tu combat language;
- three-wave Nhân → Tiên → Thần skill evolution.

Do not reopen those systems unless:
- a concrete contradiction is discovered; or
- the user explicitly changes a decision.

---

## Key new skill/path laws to preserve

### Công Pháp
- 1 Chủ Tu + 2 Phụ Tu active;
- inactive learned techniques keep mastery/history but ordinary effects are inactive;
- Tàng Kinh Các transmission is permanent after first archived full manual;
- personal mastery and Sect Nghiên Tu are separate;
- Diễn Hóa creates authored named successors.

### Chủ Đạo
- Chưa Định Đạo → Kiếm / Thể / Pháp;
- no class level;
- no generic class-stat growth;
- Đạo Lịch is lived history, not a free stat multiplier;
- active branches:
  - Kiếm: Ngự / Sát / Hộ;
  - Thể: Bá / Kim Cương / Huyết;
  - Pháp: Ngũ Hành / Y Đạo / Huyền Pháp;
- switching preserves learned content/mastery/history.

### Combat Skills
- mature loadout = 1 Thường + 4 Active + 6 Combat Passive;
- static self passives do not require combat slots;
- triggered/party passives do;
- Nhân Giới learns/opens the full foundational combat language;
- Tiên Giới evolves those families;
- Thần Giới evolves them again with bounded rule-changing effects;
- skill family successor replaces predecessor as active family source;
- skill basis = Tu Vi / Luyện Thể / Hybrid;
- AI = priority 1→4 + skill-specific validity;
- movement uses simple range profiles;
- no universal Mana/Rage/Kiếm Ý resource;
- Ngũ Hành and Tương Sinh are shared skill layers;
- effect tiers Nhân/Tiên/Thần protect control/cleanse/dispel/rule-changing interactions;
- party max 6;
- cluster max 30;
- 0 HP = Bị Hạ;
- monsters/bosses share the same combat primitives.

### Kiếm Cốt dependency
Combat Skills V2 has now defined:
- sword style tag direction;
- weapon requirement separation;
- cast/source/hit attribution.

Kiếm Cốt is **still blocked** until Weapon + Equipment V2 defines:
- canonical weapon types;
- sword equip semantics;
- weapon-requirement checks;
- whether any weapon mastery exists.

Do not enable Kiếm Cốt effectless.

---

## CURRENT NEXT-CHAT PRIORITY — COMPLETE A REAL DISCIPLE V2

The user **changed priority on 2026-10-09**: finish **disciple generation, complete meaningful attributes, real consumer/effects and one playable character** before further equipment forging/upgrading, Pháp Bảo or Phù design.

**Primary work authority:** `docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md`.

Required approach:
1. Audit live main and canonical V2 specs; produce `DV2-00` field → persisted source → derived channel → actual consumer → UI → test status matrix. Distinguish active C1 (validated) from P2 legacy and V2 design-only.
2. Prepare the **smallest first implementation slice**, `DV2-01`: deterministic ONE whole-person candidate/recruit, versioned identity persistence and no hidden rerolls. Then shared derived Combat Stats V2/RealmBodyCore and true progression/element/trait/fate/bloodline/physique/skill effects in tracked dependency order.
3. One recruited disciple must **really cultivate, train body, work and fight**, with stat values used by actual simulation and shown via existing P3.2 real disciple tabs. Any disabled/unimplemented mechanic must be labeled BLOCKED and cannot be shown as active. A real `combat_power` estimate is not the Combat Stats V2 authority.
4. Preserve P3.7C1 open-point lục-duy/recruitment and current Godot 4.7.2 locked baseline, old saves and deterministic generation. No new parallel stats, reroll-on-load or trait/physique grades resurrected as V2.
5. Focused Godot 4.7.2 gate for each slice; cumulative regression on cross-cutting changes and release; 1,000–3,000 disciple cache/perf acceptance; UI visual acceptance remains user-owned.

**Historical handoff at that time:** the user had not yet authorized gameplay code. **Superseded by explicit 2026-10-09 implementation instruction:** DV2-01 is now active; focused DV2-01A Godot 4.7.2 run #37876520342 PASS at commit 22f7d80e; later actual RecruitmentSystem accept-path test and cumulative P3.7 still need their own latest run. Do not claim whole DV2-01 PASS. to start `DV2-01` after audit if not already provided in the new chat; do not create a new numbered P3.x implementation phase without authorization.

**Locked subsystem context still valid:** `docs/DISCIPLE_V2_ROADMAP.md`/Ledger/Master. Realm/Luyện Thể = 30×10 each, Combat Skills = 1 basic + 4 active + 6 combat passive, Core Physique one active/no grades; Kiếm Cốt effect BLOCKED pending legitimate sword-tag/effect. Root/Bloodline/Destiny/Trait are not all implemented just because docs exist.

**Deferred without loss:** `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md` remains approved order but **NOT NEXT**. Equipment 10 slots, 12 phẩm, 24 sets remain locked *design*, no forging implementation. Pháp Bảo/Phù later. Mood/Loyalty/social/family expansion only after core character or smallest genuine dependency.

## Legacy design-document cleanup — 2026-10-08

Superseded legacy design Markdown files for Cultivation/Root/Công Pháp/Path/Combat Skills/Generation/Traits/Bloodline/Physique have been intentionally deleted from the repository.

Legacy runtime code, factories, tests and gates remain until their explicit V2 implementation/migration phases because they still protect regression and old-save compatibility.

Do not recreate or consult deleted legacy design specs as authority.

## 2026-10-09 — STAT-FIRST USER DECISION / NEW DOC AUTHORITIES

User approved correcting all three V2 conflicts: no in-sect Expedition Stamina consumption, no Trait V2 Grade 1–5 (profession talent grades remain), no Combat Power as V2 combat authority. **Design approved, legacy runtime not migrated or tested.**

User approved four-stage work order: base/derived stat audit → combat and production result contracts → effects-to-consumer map → implement canonical birth/character in phases after unresolved inputs are explicitly approved.

Read additionally, **before editing future V2 gameplay**:
- `docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md` — core Lục Duy/Realm/Body, Combat Stats 14+resistance, production channels and open numeric gates;
- `docs/DISCIPLE_V2_EFFECT_SOURCE_MATRIX.md` — 53 original + 48 proposed Traits (101), 24 Fates, 10 Roots, 5 Bloodlines, 15 Physiques;
- `docs/DISCIPLE_V2_ROOT_ARCHITECTURE.md` — whole person/action/owner contract.

Canonical docs corrected: `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md` (Stamina), `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md` (profession talent grade boundary), `docs/TRAITS_V2_SPEC.md` (Cuồng Công gated). Preserve existing backend P3.7C1 gate and old source until migration; `CURRENT_CHECKPOINT.md` is unchanged as no new code gate has run.

**Remaining user design gates:** exact Trait/Mệnh birth weighted eligible IDs + congenital special birth packages; Realm+Body numeric combat growth/Defense mitigation; production material/quantity/quality/rounding by content family; general HP ratio for non-Root sources; DV2-01 version/compatibility decisions. User is willing to reset disposable dev/test characters but has not authorized deleting actual user files automatically.


## DV2-01A REAL CODE/GATE SNAPSHOT — 2026-10-09

- **Active** DV2-01; the first partial integration adds default-off `SectState.disciple_v2_birth_enabled` and canonical `DiscipleBirthProfileV2` domain seeds/version/uninitialized layers. `CandidateState` → `RecruitmentSystem.accept_candidate` → `DiscipleState` save/load deep copies.
- **Godot 4.7.2 focused CI PASS:** [run #37876520342](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37876520342), code commit `22f7d80e`. Original nested JSON int→float failure fixed through normalized seed restore. More complete real-recruit path test at code commit `cbe5438d` awaits latest focused run.
- **P3.7 backend cumulative:** check latest run rather than assume PASS; previous official P3.7C1 closed baseline remains intact by design.
- Numeric proposal **NOT USER LOCKED**: `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`. Work result contract: `docs/DV2_PRODUCTION_RESULT_CONTRACT_V1.md`.
- Never claim 101 active Traits or a complete V2 person yet. Exact per-ID Trait/Destiny weights and relevant birth overrides are still a design gate. Kiếm Cốt birth remains blocked.

**DV2-01A verification update:** official Godot 4.7.2 focused test including real `RecruitmentSystem.accept_candidate` **PASS** [Actions #37876666598](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37876666598) (commit `cbe5438d`). Official **P3.7 full cumulative PASS** [Actions #37876520289](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37876520289) (last changed gameplay runtime commit `22f7d80e`). `CURRENT_CHECKPOINT.md` owns status. **DV2-01 still open**: only versioned identity envelope/seed domains are live under a default-off feature flag. No per-ID Trait/Fate V2 birth rolls, no V2 combat/production consumers. Numeric proposed curves: `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`; production contract: `docs/DV2_PRODUCTION_RESULT_CONTRACT_V1.md`; **full 101-Trait/24-Fate weighted birth pool V1 proposal**: `docs/DV2_BIRTH_WEIGHTS_TRAIT_FATE_V1_PROPOSAL.md` (NOT USER LOCKED, do not activate until reviewed).

## FINAL HANDOFF 2026-10-09 — DV2-01B FULL BIRTH CODE

Current latest code adds `DiscipleBirthCatalogueV2` (101 Trait IDs/weights, 24 Fate IDs/weights, conflict sets), `DiscipleBirthRollV2` (five-root purity, rare mutation, visible/latent Traits, rare fate, Bloodline, Physique and profession talent), integrated into both `RecruitmentSystem.generate_candidate` and Dẫn Tiên `_generate_open_candidate_with_quality`. V2 flag is **OFF** for P3.7 baseline, P2 profile rolls are bypassed only for V2-opt-in new candidates, six foundations and C1 odds not altered. All unreadied effect consumers remain inactive. Latent IDs are stored, never rerolled.

- **Godot 4.7.2 focused/pass:** [Actions #37878256401](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878256401) — candidate→disciple, real ordinary recruitment and **real Dẫn Tiên**, save/load, 100K deterministic births, rates, collisions and no Kiếm Cốt/unsafe fate. Validated 100K samples: Roots 1..5 = [6879,18066,30016,28080,16959]; Bloodline 1969; Physique 2994; Fate 491; Mutation 210, 8 awakened; latent Traits 7986.
- **Cumulative P3.7 real Godot 4.7.2**: [Actions #37878271820](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878271820); consult live result and `CURRENT_CHECKPOINT.md` before closing DV2-01.
- **Numeric Combat V1 user-approved, code DV2-02 not yet begun**: `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`.
- **Trait/Fate weighted birth user-approved, generated by DV2-01B**: `docs/DV2_BIRTH_WEIGHTS_TRAIT_FATE_V1_PROPOSAL.md`.
- **Birth exclusions**: Sword Bone/Kiếm Cốt (weapon consumer missing); Sword Immortal reincarnation fate/Kiếm Tiên Chuyển Thế (birth override not authored); `Thương Binh Kinh Nghiệm` acquired only. Other gated identities can be stored inactive, not applied as buffs.
- **NEXT** after DV2-01 closes: DV2-02 canonical derived modifier engine + real stat-based Combat/Work channels according to the phase roadmap; one phase at a time, official gates mandatory. Legacy working-time stamina and trait grade runtime are migration debts for their applicable phases, not already fixed by births. No tests should be marked PASS without actual job conclusion.

## 2026-10-09 — DV2-02A COMBAT STATS IN PROGRESS (LATEST)

**DV2-01 is CLOSED** with focused [Godot run #37878652697](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878652697) and full C1/P3.7 cumulative [#37878652738](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878652738), both official Linux Godot 4.7.2 at code commit `e697c947a`.

**DV2-02 ACTIVE; DV2-02A focused stat kernel PASS** [Godot 4.7.2 #37880761726](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37880761726), relevant code commit `691e1216`. Code `godot/src/simulation/combat/combat_stats_v2.gd`, test `godot/tests/simulation/dv2_02_combat_stats_test.gd`, CI `.github/workflows/dv2-02-combat-stats.yml`, contract `docs/DV2_02_COMBAT_STAT_EXECUTION_CONTRACT.md`.

What exists: all 14 stats + 10 resistances, 300-floor Realm+Body approved numeric core, Tiềm Lực core-only, typed source validators/unique attribution, deterministic source breakdown, independent DR/resist stacking, stat-rate intervals, status/crit chance and Defense formula, HP ratio. **What does NOT exist yet:** actual monster/boss V2 stat profiles, character's persistent two independent 30×10 tracks (DV2-03 implementation later), skill family action adapters, combat-system migration from `combat_power`, all conditional Trait/Fate/etc effects, real cache/UI. Do not declare DV2-02 finished or pretend PvE uses new stats. Keep one active phase only. Next task stays **DV2-02 actual end-to-end consumer integration with explicit legitimate inputs**; do not jump into production or another character birth pass.
