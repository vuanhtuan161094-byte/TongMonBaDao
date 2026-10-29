# TÔNG MÔN BÁ ĐẠO — V6.5 FULL COMBAT EXECUTION CONTRACT
Date: 2026-10-29. **OWNER AUTHORISATION: complete the Cung–Quyền–Độc skill, codex, combat, Boss and UI/VFX experience end-to-end; do not stop after a proposal/design phase.** This instruction supersedes older "D4 design only, separate CODE approval" handoff wording **for the scoped packets below**, but does NOT waive safety, test, branch or owner visual acceptance.

## 0. Status and source-of-truth

Repository `vuanhtuan161094-byte/TongMonBaDao`.
- Stable main SHA `c0c1382f119599497b52d8ee8abd9e830a883f1e`, unchanged.
- Active single full-combat feature branch: `feature/v63-v64-full-combat-20261029`, audited pre-contract head `bbac288acd14b0612414a458c43a4fa8a178e86f`.
- PR #52 `integration/pve-unified-rc-20261027` advanced to `f7c33d9c3baba3267a17021718b44f87acd62ef6` on 2026-10-29. The full-combat feature and PR #52 are **diverged**; the latter is one commit ahead of the older integration base. Resolve before overlapping PvE/Save changes; do not merge blindly, force-push, reset or rewrite someone else's worktree. Record a file-by-file conflict matrix and evidence at the code handoff.
- D1 gated registry: 105 skill family IDs, 531 generation nodes, 18 rare Divine ultimate variants, 9 Boss candidate records; actual runtime skills are NOT yet enabled.
- D2 gated sect archive / canonical warehouse codex / idempotent receipts: tested Windows Godot 4.7.2, 10/10 per documented evidence.
- D3 gated 12 candidate foundational/branch techniques, tick study, personal mastery, 1 main+2 aux, save migration: 10/10 tests, 62 D3 checks at committed snapshot `677184c3f05eb84e31aed66e48ee42c383acc222`; feature head includes later documentation updates. No real live combat effect. Tests are HEADLESS only, not GUI proof.
- Sources of truth (read in this order): current owner instruction > `AGENTS.md` > `docs/GAME_SYSTEM_ARCHITECTURE.md` > current checkpoint > V6.3/V6.4 six docs `docs/design/v63_v64_20261028/` > D1/D2/D3 evidence > actual source. Conflict: preserve legacy and state; report explicit design deviations.

**Target:** a single play-capable 1280×720 Godot 4.7.2 game where archived codices → learned skill → equipped loadout → auto-combat → 9 distinct Bosses → persisted rewards all work, with Source A visuals and original gated VFX; not a second game scene or mock application.

## 1. Standard operating procedure: one continuing task, one writer per subsystem

1. Fetch live refs; compare `main`, PR #52, full-combat feature; inspect `git status --porcelain`, `git worktree list --porcelain`, existing sessions and Godot processes. Preserve dirty E: worktree; use one **isolated scratch worktree under E:\TongMonBaDaoWorkspace** for actual writes/import/tests. No canonical C: checkout. Do not remove untracked user files or kill Godot sessions owned by others.
2. Use **the existing full-combat feature branch**, no gratuitous extra branches or PR per phase. Establish a single writer for `SimulationState`, `SaveService`, `HuntingPveRunV2`, `MapBattleV2`; do not run parallel Codex code writers over those files.
3. One code packet per vertical slice, with (a) precise allowed files (b) protected files and interfaces (c) behavior (d) rollback/feature gate (e) focused tests + affected cumulative tests (f) actual Godot 4.7.2 exit codes and source parity (g) visual proof when UI/VFX changes. Scope modifications to packet allowlist; if an unforeseen file is needed, justify it in checkpoint before change.
4. For each slice: read authoritative code → implement smallest **playable** end-to-end behavior → Godot headless import → new focused suite → affected legacy suites → actual game GUI + visual capture when applicable → exact SHA, source parity, log hashes, screenshot path → commit and push after evidence. Do not fake GUI PASS with test screenshot mocks.
5. Continue automatically to the next authorized packet while tests pass. Do **not** pause for a new design packet or present 3 options after every packet. Only stop for conflicting owner constraints, missing rights/asset provenance, unresolved save/data risk, a failing gate that cannot be responsibly resolved, or visual acceptance that only the owner can provide.
6. Keep `CURRENT_CHECKPOINT.md` and `NEXT_CHAT_HANDOFF.md` updated with truthful committed-vs-tested SHAs, exact PASS/FAILED/BLOCKED/PENDING, changed files, output paths, and *the next code task*. Do not mark full game READY until all gates below and owner visual review pass.
7. Do not merge to main, merge/close PR #52, alter the old feature's history, auto-close source PRs, or clean branches/worktrees without explicit owner instruction.

## 2. Technical non-negotiables

Godot 4.7.2; Android target 1280×720 landscape. PvE six per team, up to 30 active disciples/cluster, continuous event-driven auto-combat. Reuse canonical CombatStatsV2 defense, normal skill/loadout and P3.2/Sect Source A map presentation. One Active Job, one Sect Warehouse, one scheduler, Injury 0/1 heal 120 ticks, exactly-once kill/loot/study, legacy P2/P2.3 saves and acquired skills must survive. No new generic mana or 7th passive, no JX gameplay art. Five elective passives + derived branch innate, separate 4 actives, ultimate, basic and mobility channels; main+2aux technique. A/B descendant is exclusive at runtime but both can remain personally known. Immortal/Divine is a **mechanic** successor, not recolored Human ratio. Boss HP scales to zone level/floor not current party. Candidate V6.3 poison/Blood coefficients and boss peak HP require event-sim and Godot measurements before balance lock.

Asset policy: Source A licensed/owner-confirmed primary actors/terrain/monsters, hashed manifest provenance. JX/JXQY only mechanical/VFX timing reference, no new extracted JX gameplay sprites or effects in production; prefer the independently made melee pilot and original skill VFX. Source A Unity skill-clip prefab/pivot/skill mapping are NOT production-verified merely from file names. Map remains the main surface; no rebuilding production renderer/UI or full-scene redraw every world tick.

## 3. Authorization packets (D4 → D8) — execute in order

Each packet names allowed file **families**; at execution, generate a concrete path diff allowlist before writing. All existing unrelated files are forbidden.

| Packet | Required behavior | Allowed file families | Hard acceptance |
|---|---|---|---|
| **D4-A shared Human combat kernel** | New content family resolve, personally learned/equipped gates, cooldown/cast/hit/range/target ownership, events into *existing* Combat V2 authority; one Liệp Ảnh Human skill tree + one Human boss *actually performs actions* | `godot/src/simulation/combat/v63_*`, `godot/data/combat/v63_*`, `godot/tests/simulation/v63_*`, narrowly justified adapter changes in `map_battle_v2.gd`/`hunting_pve_run_v2.gd`; only real UI presenter tests | Six actors auto-cast skill; gameplay snapshot changes from real damage, not VFX; legacy gate OFF exact regression |
| **D4-B full Human nine branches** | 9 branches × Human basic/actives/ultimate/mobility/passives/innate (family sharing allowed), independent behaviors, poison/guard/heal/marks/AoE/AI; 3 Human bosses; skill acquisition from archived manual | Same combat/runtime/content/test families plus approved relevant HUD/presentation adapters | 9/9 branches can learn/use/equip; 3/3 Human bosses execute telegraphed skills; owner attributions, bounded procs, graphics |
| **D5 Immortal** | 9 branches, two distinct A/B evolution paths, 3 Immortal bosses, status reactions, predictable breakthrough study | Combat/data/new UI/test, technique/archive/catalog changes only for proved new successor rules | 9/9 A/B executable; 3/3 Immortal boss stage/counter; no clone-Human recolor |
| **D6 Divine + rare** | 9 branches Divine I/II/III, 18 rare ultimate variants as replacements, elective rare passives according to authored definitions, 3 Divine bosses, Pháp Tắc, Huyết Ma/Huyết Sinh and 6 Độc semantics | Same targeted families and tests; owner-authorized only original VFX/verified derivative assets | 18/18 rare ultimate successor uses correct loadout; 3/3 Divine bosses stage and special attacks; endgame resource/cast/proc safety |
| **D7 UI/VFX integration** | Actual P3.2 landscape PvE HUD, 6 party cards, branch skill panel, cooldown/HP/status, Boss health/phase/telegraph/break, Source A actor animation, original VFX event stages, concise numbers, tap/zoom/camera; Tàng Kinh Các learning usable from map panel | `godot/src/presentation/**` affected scenes, `godot/tests/presentation/**`, verified manifests and newly permitted derivative files; never source raw APK | **Real GUI** screenshots 1280×720 for 9 branch skill cues + all 9 Bosses, melee timing, map input, Save/Return, owner visual review; no mockups |
| **D8 integrated play/balance/release candidate** | Endgame 300 cultivation/body steps, 20 camp and multiple teams, repeatable battle sims and balance, offline/save/reload, cost economy, low-RAM performance, Android deliverable if environment permits | Targeted bugfix-only, QA fixtures/scripts, balancing catalog after simulation logs and owner-authorized numerical changes | Full affected regressions + actual GUI + profiler; Android tested on device or accurately PENDING; no merged release without owner |

**IMPORTANT:** Old docs call D4 pilot, D5 other Human, D6 Immortal, D7 Divine, D8 polish. This updated scoped work contract uses D4-A/D4-B, D5 Immortal, D6 Divine, D7 UI/VFX, D8 final QA to avoid needless intermediate stop. The coverage is equivalent; checkpoint must translate naming to the older roadmap.

## 4. Artifact inventory and gap-control

Maintain a machine-readable master coverage ledger under `docs/implementation/` or `godot/outputs/`:
- 105 family IDs (99 specialized + 6 school shared), node owner and successor status; track each Human, Immortal A/B and Divine A/B **behavior**, and all 18 rare ultimates. "ID exists" != "effect implemented".
- nine bosses each with spawn, own AI, basic and 3 skills, ultimate, phase 70/35, minions/counterplay, UI/VFX, loot + receipt, save/resume and collision checks.
- codex: 96 archivable family manuals, 9 innates, 12 D3 technique candidate definitions. Personal learn/equip skill pipeline (not only technique) is still incomplete; do NOT call D3 equivalent to the full 105 skill learning.
- mapping for every runtime skill `skill_id -> animation/event -> VFX stage -> tooltip/icon -> actual result`, with provenance `PRESENT_VERIFIED | CANDIDATE_NEEDS_QA | MISSING`.
- status codes `NOT_STARTED, IMPLEMENTED_UNTESTED, HEADLESS_PASS, GUI_PASS, OWNER_ACCEPTED, BLOCKED`; each proof includes exact code SHA, command, exit code, evidence path.

## 5. Scope extension discipline

This document is the owner's explicit full-product mandate; **no need to request owner to select design-only D4**, but do not treat it as carte blanche to change unrelated economy, production, Source A originals, main, PR #52 or balance locked formulas. Work in serial technical packets and produce a diff allowlist per packet. Owner-only final approvals remain for visuals and mainline merge.

Stop and report contradictions or irreversible decisions instead of silently guessing. Failures must be fixed on exact evidence before proceeding; blocked Android GUI does not prohibit implementing independently testable game mechanics, but prevents `FULL_ACCEPTED`.

## 6. Handoff / start command to Windows Codex

> TÔNG MÔN BÁ ĐẠO V6.5 — EXECUTE, NOT DESIGN-ONLY. Read `AGENTS.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, and `docs/operations/TMB_V65_FULL_COMBAT_EXECUTION_CONTRACT_20261029.md` on `feature/v63-v64-full-combat-20261029`. Follow the owner-authorized D4-A → D4-B → D5 → D6 → D7 → D8 packets continuously. At each checkpoint execute official Windows Godot 4.7.2 headless import + focused/cumulative regressions, real GUI tests for visible work, SHA+log evidence, push to same feature branch, update handoff, and proceed. Inspect PR #52 drift `f7c33d9c3baba3267a17021718b44f87acd62ef6` before touching overlapping PvE/Save files. Preserve dirty E: checkout by using isolated E: scratch worktree, no merge/PR/cleanup. Keep candidate balance and feature gates OFF for legacy saves until explicit preview activation. Finish with real 9-branch/9-Boss gameplay, original VFX and usable UI, endgame proof, not registry-only. If blocked, explicitly enumerate blocker and next exact action; no fictitious PASS.
