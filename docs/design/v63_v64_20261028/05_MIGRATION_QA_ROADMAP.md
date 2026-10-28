# V6.3/V6.4 — Safe migration, focused QA and staged implementation

Status: DOCS-only proposed execution order; **zero tests run for this document**; GitHub Actions quota and local resource constraints must not be mistaken for a PASS. Godot target 4.7.2 official, Android landscape 1280×720, PC ~8 GB RAM.

## 1. Runtime inventory and migration risks (checked against main)

- CombatSkillSystem.SKILLS still contains nine legacy examples under sword/body/spell, with learned_combat_skills keys, min_stage and generic effect_multiplier; must remain readable.
- CultivationPathSystem.VALID_PATHS = sword/body/spell only; path XP and identity derived from legacy active_technique_id. New paths cannot be injected as fake sword/body/spell without violating history.
- TechniqueSystem MAX_LEARNED_TECHNIQUES=3, max level5, one active_technique_id; new 1 main+2 aux model requires migration and old API compatibility.
- DiscipleCombatLoadoutV2 currently bridges legacy P2 learned damage-only skills; deferred others are **not** full V6.3 actions. No silent claim nine branches are executable.
- MonsterCatalogueV2 has small fixed species and boss tier factor2.50, not authored nine-boss data. Legacy hac_lang_vuong must remain.
- MapBattleV2 0.25s tick, MAX_SECONDS=90 for noncontinuous; world continuous mode different. Long Boss Bí Cảnh must use explicit mode and not break current timeout_retreat historical tests.
- Sect item ownership, exactly-once kill receipts, One Active Job and Injury120-tick rule are protected invariants.

## 2. Migration steps: NO mutation until opt-in

**M0 snapshot**: before/after bytes and semantic manifests for golden fixtures old save variants, normal and offline return/reload, 60 disciples and endgame facilities.

**M1 new optional state**: on load absence, initialize empty sect archive + new techniques/skills state. Keep existing legacy fields as migration source. Store save schema_version and migration completed flag. No new skills granted from new IDs to old characters.

**M2 technique**: if legacy active_technique_id exists and learned, place it as first normalized main-technique candidate while retaining original field for compatibility (dual read only during bounded migration). Other learned_techniques migrate to known list, not deleted and not all automatically active. Do not convert old generic P2 technique stat or breakthrough bonuses into V2 authority.

**M3 skills and path**: each legacy learned_combat_skills entry maps to identical historical ID or explicitly mapped successor; do not invent identical-name mapping without canonical crosswalk. Preserve old sword/body/spell XP, choices/mastery, equipped slot6, and last equipped active loadout. New Cung/Quyền/Độc content starts unowned until archive/learning. In the new branch, only five electives execute; innate is derived, legacy sixth passive remains dormant/recoverable.

**M4 archive and item**: archival keys/fragment balances in sect ownership only; idempotent one-time conversion; old P23 fragments must not become new Divine shards automatically. Never create duplicate warehouse.

**M5 reward and job**: new study jobs and skill unlocks have deterministic receipt keys. Save barrier before acknowledging kill rewards; costs and skill unlock commit exactly once on completion. On cancellation preserve completed personal knowledge/history, no grant to unfinished queued jobs.

**M6 rollback**: feature gate OFF ignores new effects but reads/writes new state without destroying it; old saves still load. Avoid irreversible schema writes until regression and backup tests pass.

## 3. Focused test matrix (author exact tests later; all PENDING)

| Gate | Tests that must pass |
|---|---|
| G0 docs/schema | 105 family IDs unique; 99+6 verified; 9 bosses and 18 rare ultimate lineage names; no overlap with old IDs; every family has all required authored generations before enabling |
| G1 legacy | Legacy nine P2 skills and sword/body/spell stable; old scenes, saves and combat exact fixtures unchanged with gates OFF; old P23 learned3/active1 still load |
| G2 path/loadout | one active path, historical path XP preserved; five electives + innate visual but 6th legacy data preserved; reject >4 actives or duplicate successor; main+2aux, conflict family strongest-only |
| G3 teaching | first complete book archives transmission once; teach 100 disciples without consuming 100 books; duplicates research only; missing prerequisite blocked with reason; deterministic successful study |
| G4 jobs/economy | one active job; cancel loses unfinished progress without erasing completed knowledge; personal contribution and stones charged once; reload/offline exact-once; warehouse fragment counts never negative |
| G5 evolution | Human Lv4/Lv7 choice persistence, 11/15/19 & 21/25/29 gates; dual learned A/B history, one active; old descendant deactivates; rare Divine replaces slot |
| G6 combat effects | root 0/40/80/100 applies only declared element fractions once; five root permanent effects remain; simultaneous elemental reactions bounded; cast speed vs attack speed vs cooldown independent |
| G7 poison | 1→30 real stacks, 19.5 effective on same Boss; attribution symmetric between six owners; consume only owned stacks, lose future ticks; refresh, cleanse, damage/kill, offline save, lag 0.25s |
| G8 blood | Immortal75%/Divine65% ceiling; cannot ordinary self-heal, no blood-sacrifice proc; allied healing threshold from original HP and 60/50%; rare55% no healing; frenzy strongest-only, cap8232%; Blood Life unaffected |
| G9 boss | nine boss IDs, phase 70/35 once per spawn; healing does not re-enter phase; max 4 summons, no duplicate loot, telegraph geometry valid, area safe; breakbar only interruptible cast; alternative protection/dodge works |
| G10 survivability | six poison, six bow, double healer, double Kim Cang, mixed and blood builds; each realm endpoints and endgame level 21/25/30; PvE Injury GP-02C 120 ticks unaffected |
| G11 persistence | Save/load during cast, phase, kill before ACK, after ACK, during job, offline settle and return/reload; equal receipts no duplicate; no dropped world events |
| G12 performance | Android 1280×720 gameplay screenshot from actual engine; 30 disciples + up to 40 monsters; actor view culling and bounded VFX; profile P50/P95 frame time, memory, no full minimap rebuild per world tick |

### Deterministic reference scenarios

- Eight seeds per 9 bosses x 6 team archetypes as smoke only, then ≥32 seeds near balance decisions. Report all failures, victory %, duration both complete and wins, damage, heal, absorbed, damage by owner/element/stack, casts, interruptions, phase times, downed count.
- Human 10-10, Immortal 20-10, Divine 21-10 /25-10 /30-10; Body track both aligned and lagging. Root purity [0,40,80,100] only as fixture; game natural roots 1–100.
- 6 Độc vs Thần Đế; 2 healer +2 Kim Cang; 6 Cung vs moving Boss; Huyết Ma with/without Dược; Huyết Sinh; element combinations Thủy-Lôi-Băng; extreme rare Divine; all gear/technique bonuses declared separately.
- HP Boss snapshots 653k–40.16bn are temporary. Record ATTACK/DEF/HP curves from CombatStatsV2 input; calculate encounter TTK from actual effective DPS, not ATK × arbitrary fixed multiplier.

## 4. Delivery phases (new branches / no merge without explicit owner direction)

| Phase | Scope | Acceptance gate |
|---|---|---|
| D0 specification | docs-only pack + IDs, conflict decisions, schema and QA matrix | docs review; no live-file diff |
| D1 content read model | validated registries, feature flags, no gameplay execution | all IDs/generation checks and gate-OFF tests PASS |
| D2 Sect Archive | one transmission first-book archive; fragments/warehouse, research, receipt | 100+ disciples teachable; no duplicate grant |
| D3 learning/techniques | 1 main+2 aux, personal mastery, time/jobs and UI | deterministic learn, migration/one-active-job SAVE PASS |
| D4 Human pilot | choose one branch (suggest Liệp Ảnh) complete Human skill tree with real combat, one Boss Human | 6-person real gameplay; P2 unaffected |
| D5 remaining Human | 8 branches, 3 Human bosses, AoE, heal/guard/poison | race/element/AI regression, field screenshots |
| D6 Immortal | 9 branches A/B and 3 Immortal Bosses, lineage/challenge | both roads testable, endless proc guard |
| D7 Divine + rare | 9 Divine lineages, rare ultimate/passive and 3 Divine Bosses | full endgame QA, frame and memory within budget |
| D8 economy/polish | codex balance, 20 sites expansion, VFX LOD, masteries, UI teaching cohorts | measured balance and loot progress; visual owner review |

Prefer small focused PR per phase, no merging just to advance progress. Godot 4.7.2 local low-RAM: import a subset, run headless focused suites sequentially with log capture, avoid all-at-once assets/Chrome. GitHub Actions quota exhaustion is infrastructure BLOCKED, not test failure or PASS. Work Cloud without Godot executable cannot validate gameplay.

## 5. Codex work order and forbidden shortcuts

1. Read this entire docs pack and existing V2 sources before coding. Explicitly resolve owner-required decisions in 01.
2. Begin at D1; read-only tests & schema first. Every new runtime module opt-in, old saves and production unaffected.
3. No fake PASS, no fabricated benchmark, no stat balance locked from static 40.16bn fixture.
4. Do not delete retired class content, source assets, previous PR state or save migration evidence.
5. Do not introduce new per-frame full-roster work, second loot warehouse, unexplained resource bar, extra passive slot, full multi-owner stack collapse, or generic always-hit boss CC.
6. For every phase report exact base SHA, HEAD SHA, files, tests actually executed and logs; clearly label PENDING when Godot unavailable.
7. Never merge without owner instruction.
