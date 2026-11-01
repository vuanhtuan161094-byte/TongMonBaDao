# TRI-01 — ARCHITECTURE FROZEN / CODEX HANDOFF
## Đại Điện V2 × Đệ Tử Xá V2 × Dẫn Tiên Đài V2 — 2026-11-01

> **OWNER CHOICE A — Explicitly authorized: prepare docs-only GitHub handoff and full copy-ready Codex prompt.**
> This commit does not run Codex, alter game code, run engine tests, merge branches, rebalance values or accept gameplay.
> **FROZEN means design/scope fixed for integration, NOT engine QA PASS.**

**Codex execution instructions:** [CODEX_TRI_FACILITY_INTEGRATION_PROMPT.md](./CODEX_TRI_FACILITY_INTEGRATION_PROMPT.md). Copy the full prompt file into Codex. Other supporting authority: repository root [AGENTS.md](../../../AGENTS.md), [CURRENT_CHECKPOINT.md](../../../CURRENT_CHECKPOINT.md), [NEXT_CHAT_HANDOFF.md](../../../NEXT_CHAT_HANDOFF.md).

## A. Verified GitHub branch/commit ledger at handoff

| Item | Ref / exact SHA | Finding |
|---|---|---|
| Default main | c0c1382f119599497b52d8ee8abd9e830a883f1e | Untouched by this packet |
| ONE GAME RC (integration target) | rc/one-game-playable-20261101 @ 970af33b23076c80d677cf5898a721a27504708f | Use as new integration base; latest verified at authoring |
| Historical source RC | integration/one-game-v65-20261030 @ 199f888c7fd690830728dfbf29b6b79276e3b283 | Ancestor, NOT current target |
| Dẫn Tiên C2, PR #60 | feature/dan-tien-c2-ui-p0-20261101 @ 074ca829d2d35a559c445edba17c5e1f9d1dc937 | Draft. An ANCESTOR of latest RC, not a standalone merge requirement |
| Đại Điện + Đệ Tử Xá, PR #64 | feature/dai-dien-v2-live-p0-20261101 @ bf3ed0310899c554eea4e6b2e1967dcada2d68dd | Draft, code written, official Godot engine not run at this HEAD |
| PR #64 original divergence / RC ancestor | eb5e139d61adb5e9881ccb85d4cd823ad7a84263 | Common feature source base before newest RC commit |
| Newest RC-specific commit | 970af33b23076c80d677cf5898a721a27504708f | Dẫn Tiên GUI, tests, live Windows QA evidence; not in #64 |
| This handoff | docs/three-buildings-codex-handoff-20261101 | Docs-only branch forked from RC 970af33 |

GitHub API compare results at authoring:

- 199f888... old integration → 970af33... RC: RC ahead **75 commits**.
- 074ca829... Dẫn Tiên PR60 → 970af33... RC: RC ahead **56 commits**, behind 0. **Do not re-merge PR60.**
- 970af33... RC ↔ bf3ed031... PR64: **diverged**; #64 has 125 own commits, RC one commit absent from #64. GitHub compare reported 24 changed source/docs/test paths for PR64 relative to merge-base.
- PR64 source was developed on a prior RC snapshot; simply copying its whole GDScript files can delete newly added RC GUI behavior.

**MANDATORY live-ref refresh:** before coding Codex must re-fetch main, RC, both PRs; if any head changes, redo compare and record new exact SHAs.

## B. Frozen integration rules — source of truth

### B1. Đại Điện V2

- One canonical Hall BuildingState main_hall_001 (Lv1–100); native panel with six tabs, 7 offices, officer suitability, office mastery 1–10, real role effects only where a simulation consumer exists.
- 27 rank labels Nhân1–9 / Tiên1–9 / Thần1–9; gates: Hall level, roster, V2 cultivation realm, actual production, earned prestige, paid materials. Boss NOT mandatory.
- Intent ceilings: ~90 end Nhân, 200 end Tiên, 400–500 end Thần (current implementation max 480), subject to completed House beds. F2P goals Nhân ~3 mo, enter Thần ~12 mo, full ~24 mo are NOT demonstrated by balanced simulation. **Do not change formulas, costs, caps or pacing during this integration.** Log deficiencies as DD-10 design/owner decision after QA.

### B2. Đệ Tử Xá V2

- Starter residence_001 persists and stays active; Annex residence_002 onward are genuine BuildingStates with paid construction receipts and tick-based completion. Incomplete House has NO beds/buffs/rooms. Real Room assignments and capacity derive from SimulationState; replay cannot double-debit.
- House #2+ selected with native ResidencePlotSelector among 12 explicit plots, House 3×3 footprint, one open exterior interaction tile, no overlap, owned site persisted as versioned site_x/site_y inside real BuildingState.production_state. Legacy Houses without site version use their existing deterministic slot.
- **Owner veto on roads:** characters only move to building DOOR; no interior walk, no mandatory road networks or AStar route connecting gate and plot. PvE AStar untouched.
- Current plot selection is preset plots, NOT arbitrary map drag-to-build or land ownership unlock. Do not expand scope silently.

### B3. Dẫn Tiên Đài V2

- Source of truth: latest RC 970af33, NOT stale PR60 branch. D7 complete candidate identity in New Game; 6 founding disciples, capacity 8, 3 starting candidates and 3 tokens in existing QA fixture. Preserve Source A verified preview, search/grade filtering, accept/reject confirmation, guidance assignment permissions, queued candidates, cross-process save consistency, never double-debit paid token.
- Preserve exact RC UI **CandidateDecisionActions**, _detail_actions, _detail_action_hint, buttons NHẬN ĐỆ TỬ / TỪ CHỐI, responsive layout and live QA tests. DO NOT overwrite dan_tien_screen_v2.gd from PR #64.
- Candidate queue cap 30, odds and Chiêu Mộ Lệnh values remain current provisional behavior. Do not introduce pity, new currencies, altered odds or adjust balance without explicit decision.
- Dẫn Tiên Lv1 is a STARTER facility. RC confirms **there is no player build/place/purchase flow** for Dẫn Tiên. Do not fake this feature or claim it is complete.

### B4. Shared rules / scope exclusions

One canonical state, single scheduler/clock, exactly-once SaveService receipts, canonical Warehouse, one active job per disciple; existing injury 0/1 + 120 ticks. Preserve legacy saves, never silently reroll applicant identity. Isolated workspace and saves only. No main/RC direct writes or PR merges. No PvE, SX01/SX02, medicine/equipment, old Forge balance, no AI-created art, no monitoring/telemetry/FPS logging pipeline. Performance observations are NOT a gate for this doc packet; only minimum practical runtime smoke needed for QA.

## C. Concrete merge conflict and survival matrix

| Area | Latest RC must survive | PR64 additive integration | Verification |
|---|---|---|---|
| dan_tien_screen_v2.gd | CandidateDecisionActions, actual accept/reject and 1280×720 GUI corrections | No wholesale replacement needed | Screen buttons + mouse/keyboard input + screenshot |
| p3_2_landscape_sect.gd | Dẫn Tiên modal flow, candidate changes, upgrade, current map interaction | Hall native panel + Residence selection, door-only actors | Real map picking per building + rest/production |
| recruitment_system.gd | C2 candidate cap, order/debit, eligibility and Guide consumers | Hall officer sharing and no busy reassignment | Daily snapshots, guide assignment exactly once |
| building_system.gd | RC Dẫn Tiên upgrade and SX production unchanged | Hall/House construction, statuses, upgrade receipts | Lv1→2/9→10/19→20 and Hall/House timers |
| live_game_runtime_v2.gd | New Game C2 initialization, single state | Hall/Residence opt-in initializer | New Game/save/migration |
| sect_state.gd / simulation_state.gd / save_service.gd | RC C2 save wire, existing recovery behavior | Hall/Room/site receipts and saved upgrades | Legacy/backup/byte-stable roundtrip |
| sect_isometric_world_v1.gd | current Source A map camera/picking and PvE geometry | Real Residence site anchor and exterior door target | 1280×720 screenshots and door collision tests |

**Verified blob conflict:** RC dan_tien_screen_v2.gd blob **da96d25ffd1db486fa2f9b430af465fd46e7d0dc**, versus PR64/PR60 blob **d86824e13efe314f69e94df708e0c9398c6df888**. RC's newer file has the new CandidateDecisionActions area; choose RC and port only missing scoped integration changes. PR64 and PR60 also both touch recruitment_system.gd and p3_2_landscape_sect.gd, but because PR60 is ancestor of RC those earlier changes are already in RC; **do not apply a second C2 diff**.

## D. Existing QA evidence and actual debt

**Dẫn Tiên RC has Windows official Godot 4.7.2 evidence** at [docs/qa/dan_tien_rc_20261101/README.md](../../qa/dan_tien_rc_20261101/README.md), with [matrix.csv](../../qa/dan_tien_rc_20261101/matrix.csv), screenshots, logs. QA code snapshot was from isolated local source (README records commit/tree), so Codex must rerun exact integration SHA, not treat source SHA as already accepted.

- Real UI assertion run: **64** assertions, exit 0; native P3.2 map click, actual Dẫn Tiên modal, preview and upgrade.
- New-process Save/Reload: **29** assertions, exit 0; IDs, candidates, orders, guide and day snapshot retained.
- Focused regression: **11 PASS, 1 FAIL**. Fail: P3.4C Forge craft did not consume recipe material **thanh_thiet**. Explicitly record baseline-red; no unauthorized Forge fix. Verify if integrated diff changes the cause.
- Confirm rejection: automated second mouse click failed, keyboard focus+Enter fallback used. Physical owner-click acceptance remains **PENDING USER**; cannot label it full touch/mouse QA.
- Windows importer emitted root certificate/cache diagnostics but source Godot import exited 0; distinguish diagnostics from actual failure.

**Đại Điện/Đệ Tử Xá PR64:** DD-01 through DD-09.2 committed, code-only check; **no official Godot 4.7.2 import, parse, GUI or tests have run at bf3ed031**. Supporting document [DD handoff on PR64](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/bf3ed0310899c554eea4e6b2e1967dcada2d68dd/docs/qa/DAI_DIEN_V2_LIVE_P0_CODE_HANDOFF_20261101.md).

Six new DD tests exist **ONLY in PR64**, not in initial RC; port with code BEFORE running:
- godot/tests/dai_dien_v1_smoke.gd
- godot/tests/dai_dien_dd06_integrity_test.gd
- godot/tests/dai_dien_dd07_save_recovery_test.gd
- godot/tests/dai_dien_housing_full_loop_test.gd
- godot/tests/dai_dien_dd092_door_plot_test.gd
- godot/tests/presentation/sect_door_only_navigation_test.gd

Other test paths from latest RC are listed in the companion Codex prompt; verified to exist at RC SHA 970af33. Do not run test paths before import and code port.

## E. Execution plan / phase gates (Codex, not the author)

1. **Phase 0 — verify refs & baseline:** read source governance, current SHA, compare diffs, log baseline RED; create a fresh integration Draft branch from RC HEAD and isolate QA working directory/APPDATA.
2. **Phase 1 — code migration & unit contracts:** import PR64 backend in atomic groups (state/save, Hall/effects, House/plots, UI/map), preserve RC Dẫn Tiên C2 UI, not rewrite RC via file copying; parse each modified class.
3. **Phase 2 — engine:** official Godot 4.7.2 editor import; focused candidate, Hall, House, door, ledger, SaveService tests. Exactly-once replay, legacy fallback and negative corrupted-save cases required. All test results quote the same SHA.
4. **Phase 3 — real GUI:** 1280×720 native screenshot + click flow Dẫn Tiên (including CandidateDecisionActions), Hall management, House purchased plot and actual exterior-door interaction. Preserve Source A. No mock screenshots.
5. **Phase 4 — integration regressions:** production, recruitment, workforce, care, injury120, Save/Load, P3.4A/C; classify pre-existing Forge failure. No PvE source edits; run read-only tests only when needed.
6. **Phase 5 — handoff report:** Draft PR toward RC, source+test+evidence SHA, full PASS/FAIL/BLOCKED/NOT RUN matrix, bug causal notes, rollback, real screenshots, unapproved balance issues. No automatic merge.

## F. Explicit acceptance / rejection conditions

- PASS requires compiler/import exit 0, applicable tests exit 0, actual C2 UI buttons retained, real House door and placement tested, Hall/House receipts durable through restart, no duplicate spend; screenshots from real Godot window.
- BLOCKED if no official engine, unresolved same-scope runtime failure, save corruption, double debit, lost CandidateDecisionActions, or missing required screenshots. An unrelated Forge baseline-red must be documented and triaged; never quietly mark green.
- No owner approval means no new 27-rank values, altered candidate caps/odds, road system, PvE features or Forge-system repair.
- Existing and new docs must distinguish AUTHORING TESTS from EXECUTING TESTS. No unverified "READY", "FULL", "PLAYER ACCEPTED".
- Android/physical owner mouse or device testing is **PENDING USER** even if automated desktop clicks pass.

## G. Handoff result status

- Architecture locked: **YES (scope/behaviors)**.
- Source GitHub HEAD comparisons: **DONE** at listed SHA.
- Full Codex prompt: **PUBLISHED** in docs-only branch; not executed.
- Official Godot QA for PR64 and integrated target: **NOT RUN**.
- RC prior Windows Dẫn Tiên QA: **partial PASS with documented P3.4C baseline FAIL**.
- Code merged into RC/main: **NO**.
- Next allowed execution: owner sends companion Codex prompt directly, on a NEW integration branch, followed by explicit QA review. A reply option/prompt is not itself a CI run.
