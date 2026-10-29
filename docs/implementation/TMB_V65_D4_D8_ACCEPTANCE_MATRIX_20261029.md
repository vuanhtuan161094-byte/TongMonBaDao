# V6.5 Full Combat — cumulative acceptance matrix and observable evidence

Authoritative execution: [V6.5 contract](../operations/TMB_V65_FULL_COMBAT_EXECUTION_CONTRACT_20261029.md). Latest audited source branch at packet start: `bbac288acd14b0612414a458c43a4fa8a178e86f`; PR #52 integration HEAD drift: `f7c33d9c3baba3267a17021718b44f87acd62ef6`.

## Exit gates per code packet

**G0 Worktree, SHA, scope:** current refs, clean isolated scratch checkout; protect four previously reported dirty EOF-only files in owner E: worktree. Confirm no untracked assets or save modifications. Concrete allowlist, rollback, source parity.

**G1 D4-Human functional:** 9 branches and family sharing, 4 actives/1 ultimate/5 passives/innate, skill learned/equipped and cast legal; attack speed vs cast speed/cooldown; real HP damage/heal/shield/status. Test 6-person auto fight, moving monster, target loss, LoS, AoE cap, 30-disciple concurrent cluster, path safety. 3 Human bosses cast 3+ active skills plus ultimate, summon limits, phase idempotence, telegraphs.

**G2 status invariants:** (i) poison owner 1–5 stacks; six owners 30 real -> 19.5 effective boss; consumed stacks forfeit future ticks; no crit/lifesteal/proc recursion; root compatible fraction once; deterministic simultaneous owners; (ii) Immortal Huyết Ma 75%, Divine 65%, rare55% combat max original HP; allowed ally heals only below40/35% original threshold 60/50%, no ordinary self heal, Huyết Sinh unaffected; AI sacrifice must not kill owner; Divine ultimate cap 8232% candidate. (iii) lethal shield per-target cooldown, no permanent invulnerability.

**G3 generations:** Human Lv1–10, choice nodes Lv4/7; Immortal I–III gates 11/15/19, A/B transitions with owned predecessor and chosen lineage; Divine I–III gates21/25/29; 18 rare ultimate variants replace active ultimate. Personal learned history survives switching and saved loadout chooses one successor per family. Each evolves mechanical behavior; don't just retint.

**G4 codex + jobs + saves:** first manual archives sect-wide, duplicate/research receipts, 96 manuals, no 9 innates sold; actual skill learning/equip adds to D3 technique learning (12 technique candidates ≠ all skill learning). Existing 1 main+2aux works under gate. One Active Job, contribution/personal stone costs exactly once, refunds on cancel once, SAVE/RETURN mid-study and completion, LEGACY P2.3 migration, offline time consistent. Existing canonical Warehouse/Job/Scheduler preserved.

**G5 nine Bosses:** per boss basic, >=3 actives, 1 ultimate, three phase states, distinct mechanic; requires telegraph geometry and at least two valid responses; capped minions 4, no unlimited heal, spawn/kill/save exact once, no cross-generation repeated rewards. Boss HP by fixed zone realm/floor, not party attack; phase changes one-time despite healing.

**G6 visuals/source mapping:** each family stage precast/cast/projectile or area/impact/afterglow bounded, validated client event and hit; no visual-induced simulation damage; use approved Source A rigs/map, original melee pilot+original FX or approved verified derivatives; JX is reference for animation timing not imported wholesale. Capture at 1280×720 9 branch demos, 9 Bosses, party panel, Tàng Kinh Các, production map intact, input real/GUI, camera wheel +/− and touch; no mock screenshots.

**G7 performance:** test 6 and 30 disciples, multiple teams, summoned minions & AoE, boss ult phases. Capture P50/P95/P99 frame gaps and worst spike, FPS, RAM/PSS and rendering node count with logger OFF vs ON, no unnecessary map/minimap rebuild. Record baseline and endgame, not just idle FPS.

**G8 release boundary:** Godot 4.7.2 official Windows headless import, targeted + cumulative regression matrix from D3 (listed below), QA with exact source parity, SaveService/injury/production/warehouse/actor pre-existing suites, launcher one click, GUI actual, Android on device if available, owner visual review; **no merge**.

## D3 established regression baseline (all claimed PASS at D3 snapshot)

`v63_d3_learning_job_test.gd` (62 checks); `v63_d3_learning_ui_test.gd`; `p2_3_technique_test.gd`; `v63_d2_sect_archive_test.gd`; `v63_d2_codex_drop_receipts_test.gd`; `p3_7b1_warehouse_test.gd`; `save_service_async_roundtrip_test.gd`; `safe_01_save_recovery_test.gd`; `pve_save_return_reload_exactly_once_test.gd`; `pve_multicamp_combat_hp0_bridge_test.gd`.

When modifying MapBattleV2, SaveService, presentation or jobs, additionally run relevant V2 combat, P3_2 camera/map, P3_7 warehouse, Injury GP-02C1, exact source actor/VFX and loader tests. Never omit tests merely because pre-existing tests are slow; if unable to run, report PENDING/FAIL with logs.

## Two-tier status

- `CODE_READY` source changes present; `STATIC_PASS` only means syntax/content checks performed (not engine).
- `ENGINE_PASS` only when official Godot exit0 + expected assertions + exact tested HEAD or a documented source-parity manifest.
- `GUI_PASS` only from actual Godot window/scripted physical event evidence, not headless _draw() assertions; `ANDROID_PASS` only on real Android device.
- `OWNER_ACCEPTED` only owner explicitly approves visuals, balance and release. Never replace the latter with numerical self-evaluation.

## Screenshot evidence minimum

production map unchanged; sect -> PvE entry and 6-person picker; 9 branch signature casts (including melee, AoE, poison, heals); nine Boss encounters with named cast bars and distinct telegraphs; Huyết Ma HP seal; 6-poison ownership/debuff UI; Tàng Kinh Các book/archive/study/job/equip UI; Save/Return after skill and boss phase; 30 disciples stress screen. Actual screenshots/videos must show source HEAD and runtime identity separately in report.

## Final traceability template (update each phase)

| Phase | Code SHA | Implemented families | Functional Bosses | Godot import/tests with logs | Real GUI | Android | Regressions and blockers |
|---|---|---|---|---|---|---|---|
| D1 | recorded | 105 IDs only | 9 IDs only | recorded | PENDING | PENDING | gated |
| D2 | d45ab195 | none live | none | 10/10 reported | PENDING | PENDING | gated |
| D3 | 677184c | 12 technique learning candidates, effects OFF | none | 10/10 reported, 62 checks | PENDING | PENDING | gated |
| D4-A | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| D4-B | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| D5 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| D6 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| D7 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| D8 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
