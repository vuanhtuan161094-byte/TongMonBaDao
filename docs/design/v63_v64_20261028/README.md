# TMB V6.3/V6.4 — Combat, Boss, Bí Kíp, Công Pháp implementation handoff

Date: 2026-10-28. Branch base: main at c0c1382f119599497b52d8ee8abd9e830a883f1e. Status: **DESIGN HANDOFF ONLY / NO GAMEPLAY IMPLEMENTATION / BALANCE PENDING**.

## Read order

1. 01_AUTHORITY_AND_CONFLICTS.md — precedence, design decisions, legacy crosswalk, unresolved gates.
2. 02_CONTENT_REGISTRY.md — 105 skill-family slots, nine bosses, branch/realm ID rules.
3. 03_RUNTIME_DATA_CONTRACT.md — authored schema, systems, events, deterministic authority and save.
4. 04_LEARNING_ECONOMY_UI.md — manuals, techniques, learning, One Active Job, UI, loot.
5. 05_MIGRATION_QA_ROADMAP.md — non-destructive migration, focused tests, phased implementation.

## What is locked vs provisional

DESIGN-LOCKED for the new content proposal: nine Cung/Quyền/Độc branches; Human 1–10, Immortal 11–20, Divine 21–30; two mutually exclusive Immortal/Divine branches per specialization; 1 common basic + 1 common mobility per school; 4 branch actives, 1 ultimate, 5 elective passives, 1 branch innate; rare Divine successor **replaces** an existing ultimate/passive; six-disciple PvE teams; no universal mana; boss telegraph and counterplay; poison ownership by caster; Blood Demon HP-seal identity; one archived complete manual unlocks permanent sect transmission; 1 main + 2 auxiliary active techniques; no random learning failure; no merge.

PROVISIONAL/NEEDS EVIDENCE: all attack/HP/DEF/boss curves at real endgame; 6/12/20% ATK per poison stack-second (Human/Immortal/Divine), effective 19.5 of 30 stacks on bosses; Blood Demon 75/65% current in-combat HP ceiling; exact cooldowns, all rarity/drop fragments, learning costs/time, bosses' HP snapshots, PvP, and offline rewards. **Do not claim balance PASS** based on the prior unlogged V6.1 simulation summaries.

## Precedence and reconciliation

Canonical historical docs remain intact: docs/COMBAT_SKILLS_V2_SPEC.md; TECHNIQUE_V2_SPEC.md; CULTIVATION_PATH_V2_SPEC.md; REALM_LADDER_V2_SPEC.md; COMBAT_STATS_V2_SPEC.md; SPIRITUAL_ROOT_V2_SPEC.md; P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md. The present pack is the candidate V6.3/V6.4 *extension contract* for nine new branches and nine boss prototypes. It does **not** silently supersede old V2 class IDs, active-slot save format, or the live source implementation. Any conflict requires an explicit migration/authority decision before code, identified in 01 and 05.

No files outside this folder should be changed by this docs-only change. Do not edit gameplay, PRs #50/#51/#52, assets, economy/save balance, or CI. Do not merge this branch pending owner review.

## Reference baseline

Live main at handoff has CombatSkillSystem with path sword/body/spell and nine pilot skills; CultivationPathSystem.VALID_PATHS = those three paths; TechniqueSystem legacy 3 learned/one active; MonsterCatalogueV2 pilot factor boss 2.50 and boss_phase_authoring_pending; DiscipleCombatLoadoutV2 bridges legacy skill inventory. MapBattleV2 non-continuous battles time out after 90s, continuous world mode behaves differently; boss encounter durations 150–240s need a separate explicit encounter policy.

All named skill concepts and boss designs in this pack derive from the design discussion V5.9, V6.0, V6.2, V6.3 and V6.4. They are **not implemented merely by writing the registry**.
