## VFX SPRITE-LAYER ART PIPELINE — owner order 2026-11-14 (MANDATORY)
All VFX school chats MUST read docs/operations/TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md plus docs/templates/VFX_SKILL_ART_FIRST_TEMPLATE.md. Fist chat also reads docs/operations/TMB_VFX_FIST_SCHOOL_PLAYBOOK_20261114.md. We learned the production method from the existing Loi Phu (talisman01): original master sprite -> pose-specific RGBA atlas -> independent light/impact layers -> real Godot movie -> visual corrections. **Copy the pipeline, not the talisman art**. Continue Fist work here; Talisman chat owns talisman01. Sprite material quality at native 1x and owner explicit approval are obligatory; code PASS alone is not art approval. No rig, Codex, new branches/merges, Combat V2 or SaveService changes.

---

## SPRITE-FIRST VFX OWNER DIRECTIVE — 2026-11-14

For ALL VFX/skill visual work, read [mandatory sprite-first VFX rules](docs/operations/TMB_VFX_SPRITE_FIRST_QUALITY_RULES_20261114.md) and the Art-First SOP V3. **Original multi-frame sprites/PNG flipbooks are expressly permitted and preferred when needed for beautiful motion.** Shader-only/code-only restrictions are rejected; a recolored static vector is not a completed skill. Separate school/chat paths, one original skill at a time, real Godot 1280×720 movie/art review before approval. No rig, Codex, new branch, merge or unauthorized PvE/Combat V2 edits.

---

## VFX ART-FIRST OWNER OVERRIDE — 2026-11-14 (MANDATORY FOR EVERY NEW CHAT)

**LATEST VFX FEEDBACK 14 NOV:** Xà Ảnh painted/4-pose layered serpent is the actual quality baseline. POI05 Tán Cổ R10 'tạm tạm' permits next skill but its electrical charge and rigid centipede are NOT approved as ideal art; backlog is light strands **gathering into a ring** + painted living creature (NO giant vector segmented re-skin). POI06 Vạn Cổ Phệ Giới light-ring experiment is at `docs/handoffs/VFX_CURRENT_ART_FIRST_NEXT_CHAT_20261114.md`. Test PASS is never owner art PASS. Do not copy Source VL copyrighted pixels.


For ANY Tông Môn Bá Đạo combat skill VFX, before generating art/code or handing off, automatically read [VFX ART-FIRST SOP V3](docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md), [VFX current handoff](docs/handoffs/VFX_CURRENT_ART_FIRST_NEXT_CHAT_20261114.md), [tmb-vfx-art-director skill](.agents/skills/tmb-vfx-art-director/SKILL.md), current PR #72 HEAD and actual skill catalogue. Owner REJECTED generic VFX-BATCH-01 R1–R4 as visually ugly. One ORIGINAL high-quality skill at a time; no static vector recolor mass production, no moving on until real Godot video inspected, corrected, and owner approves. Do NOT depend on chat memory or ask user to repeat SOP. Approved Human Poison labs locked; V6.3/PvE OFF; NO rig, Codex (unless explicitly authorized for VFX), new branch or merge. This supersedes older batch-artwork instructions in this file, but not other game-system authority.

---
# AGENTS.md — TÔNG MÔN BÁ ĐẠO

## CURRENT RELEASE-TRAIN OVERRIDE — 2026-11-04 (read first)

Owner direction: **ONE GAME → final `main`; only [PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) is the active gameplay integration candidate.** Live gate/work owner: [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56); concise factual source: [canonical release register](docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md); live status: [CURRENT_CHECKPOINT.md](CURRENT_CHECKPOINT.md) and [NEXT_CHAT_HANDOFF.md](NEXT_CHAT_HANDOFF.md).

**This paragraph supersedes dated instructions below on which PR/RC/launcher/QA lane to run, not their still-valid safety/architecture rules.** Do not resume work on old #52/#67/`one-game-v65` based on historical notes; PR #67 is #72's ancestor/base. Do not start a new gameplay branch or a duplicate roadmap. When instructions disagree, use the latest explicit user decision, Issue #56's release gates, live source SHA, then current architecture; do not interpret older QA/status as a current PASS.

- **R0 backup verified on 2026-11-04:** 196 working items + 94 saves, SHA256 manifest `EA753053E1DFBFD490E725C7FDD86B26FF565EA4BB10920805AA74571EDEF509`. Preserve these E: backups and user saves; no forced reset/clean/checkout. Do not merge `main` until R2–R4 release-critical QA PASS and main divergence reconciliation.
- **R1 canonical Godot headless PASS** at code SHA `b56b6fe8fa29ae663994a65098a56b60c3b42513`: 20/20 import+focused test exit 0, D7 Tam Căn(3)/Tứ Tính(4) UI fixed. Windows real GUI **NOT PLAYABLE PASS** (`ig11icd64.dll` OpenGL/Intel crash, PID problem), Android pending; `godot/project.godot` already uses `gl_compatibility`. **Continue R2→R3→R4→R5 automatically** under [Owner order](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72#issuecomment-6627064335), no stopping between gates. Do not report legacy `LOOT_PENDING`: P0 natural test has real reward/receipt on tested SHA, but actual same-save Windows GUI remains unproven.
- Old README/checkpoint/handoff contents were archived under `docs/archive/checkpoints/`. Do not follow the archived version's branch, phase, or commands.
- Character UI labels must respect Owner's **Tam Căn / Tứ Tính** correction. Check live canonical stat authority and UI before editing code; do not add a duplicate `Tâm Tính` gameplay stat from the label alone.
- The request to use **Codex to execute R0–R5 is explicitly authorized by Owner**; older text discouraging Codex is historical. Still enforce one writer per overlapping subsystem, exact-SHA QA, provenance and non-destructive workflow.
- PR backlog cleanup is **administrative**, not `main` merge: 61 → 18 open, 43 closed and branches/history retained (2026-11-04 snapshot); the 14 still-open gameplay PRs have a PORT/SUPERSEDED/DESIGN_HOLD matrix per R1; independent animation labs remain separate.

---

This file is the repository operating contract.

## VFX ART DIRECTOR OWNER LOCK — 2026-11-13 (skill; read for ALL combat FX work)

For ANY Tông Môn Bá Đạo VFX/skill visual/animation/shader task, especially Kiếm/kiếm khí/sét/rắn/Độc/Hỏa/Băng/Source JX/Source A, **read the repo-scoped skill [tmb-vfx-art-director](.agents/skills/tmb-vfx-art-director/SKILL.md) and its reference files before researching, coding or handing off to Codex**. This is the same skill also bundled into the private TMB Project Copilot ChatGPT plugin v0.2.0. Check live HEAD and the owner's newest visual comments; do not follow old VFX variants as if owner accepted them.

Owner visual standard: kiếm khí = *moving tapered luminous energy* (not a solid sword with steel body/hilt), phi kiếm thực thể is a different object class. Owner's liked sét and V9 light serpent are movement/lighting quality references. **A valid GDScript test or 60fps encoded Godot movie is NOT owner visual approval**. Do an art brief and verify actual 1280×720 Godot motion across >=8 phase frames; preserve `OWNER_VISUAL_PENDING` until owner explicitly accepts. Research-only requests do NOT authorize VFX code; no external JX/Source A commercial artwork shipped without verified rights. Live PvE still requires separate permission; combat targeting, damage/HP, SaveService and V6.3 authority remain outside art scope. Research authority: [VFX18 JX/Source A audit](docs/operations/VFX18_JX_SOURCEA_LIGHT_LANGUAGE_RESEARCH_20261113.md).


## 1. Authority order

Before changing code or gameplay design, read in this order:

1. current user instruction;
2. `docs/GAME_SYSTEM_ARCHITECTURE.md`;
3. `CURRENT_CHECKPOINT.md`;
4. `NEXT_CHAT_HANDOFF.md`;
5. the active phase spec;
6. subsystem master specs, especially `docs/DISCIPLE_MASTER_SCHEMA.md` for character changes;
7. current live code.

Do not ask the user to repeat information already available in these authorities.

If two documents conflict:
- newer explicit user decision wins;
- then `docs/GAME_SYSTEM_ARCHITECTURE.md`;
- then the more specific subsystem spec;
- implementation status comes only from `CURRENT_CHECKPOINT.md`.

Design specs must not be treated as progress logs.

---

## Owner Windows workspace directive — 2026-10-27

Canonical playable checkout MUST be E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao. Create new repo/worktrees/QA outputs on E under TongMonBaDaoWorkspace, never default C:\Users\Admin\Documents\Codex as a canonical game checkout. Windows Codex session metadata under C may be app-managed: do not delete while active. Before moving C/E paths inspect junction targets, git worktree list, active sessions, dirty/untracked, save and SHA provenance. Single owner launcher MO_GAME.cmd. See docs/operations/TMB_ONE_WORKSPACE_WINDOWS_20261027.md. This is NOT permission to silently merge main or mass delete PRs/branches/files.

## 2. Engine / branch / workflow

Repository:
`vuanhtuan161094-byte/TongMonBaDao`

Primary branch:
`main`

Engine:
Godot 4.7.2

Before edits:
- fetch live `main`;
- inspect current code;
- do not assume a previous chat's HEAD is still current.

Use GitHub connector for repository edits.
Do not use Codex or Work for repository coding unless the user explicitly changes that instruction.

---

## 3. Scoped CODE ownership rule — USER OVERRIDE 2026-10-15

**Supersedes the old repository-wide one-active-implementation-phase ban.** The owner prioritizes a playable Economy-A while preserving real evidence and locked gameplay.

1. **A CODE packet, not a historical phase, is the unit of implementation.** An OPEN QA debt or PAUSED unrelated phase does not automatically block a new explicitly authorized packet. A parallel DESIGN/QA investigation is allowed. There must be **one writer per overlapping file/subsystem**; concurrent CODE with shared `SimulationState`, `SectState`, `DiscipleState`, `BuildingSystem`, `WorkforceSystem`, `WarehouseSystem`, scheduler, save or scene integration needs one clearly named integration owner and no competing changes.
2. **Separate permission is still compulsory.** Before CODE, obtain the owner's specific authorization naming package, intended behavior, current `main` SHA, allowed paths, disallowed systems, rollback/legacy migration and focused/cumulative tests. A plan, an approved design, or this governance change alone never authorizes runtime, tests, workflows or balance edits.
3. **Preserve the exact statuses.** GP-02C1 is CODE DONE/official Linux focused+FULL PASS but overall QA OPEN because O6 standalone differential and physical Windows/Android debts are unresolved; DV2-03 remains PAUSED NOT CLOSED. Starting Economy-A cannot relabel either as CLOSED/PASS. Never call an old failure green or remove the test to make a dashboard green.
4. **Risk-based dependency check.** Keep a known-red test as a traced baseline debt if demonstrably independent. If Economy-A edits Mine/Forest/warehouse/job timing/currency/save, the affected O6/O5/GP-01/GP-02B1/GP-02C1/SAFE contracts must be reproduced or compared on real commits. A pre-existing failure in the path being changed **blocks integrated acceptance**, though it need not block development; repair requires a separate authorized allowlist or inclusion expressly authorized in the packet.
5. **Honest closure stays strict.** Close a packet only after explicit contract, complete implementation, official Godot 4.7.2 focused gate, cumulative regressions of affected and previously locked features (with any truly unrelated prior failures explicitly documented/owner-accepted, not called PASS), and `CURRENT_CHECKPOINT.md` / `NEXT_CHAT_HANDOFF.md` reflecting evidence, SHA, remaining debts and next permitted work.
6. **No duplicate authority.** One canonical Warehouse, one scheduler/time source, one disciple active job, canonical V2 state/save. Preserve P2 legacy without silently treating `wallet/treasury` as V2 `spirit_stones`. Avoid speculative UI, fake economy outputs or invented game balance.

**Current user decision:** Economy-A may be prepared and proposed for separate CODE authorization without waiting for GP-02C1 QA and DV2-03 administrative closure. The existing Injury 0/1/120-tick behavior remains production authority; 最强祖师-inspired graduated Injury/treatment is an independent DESIGN proposal, NOT a permission to change it. Economy-B/C, FE-02, DV2-04 and historical test repairs do not become authorized.

For any seeming conflict with historical notes, read the matching updated `docs/GAME_SYSTEM_ARCHITECTURE.md` section 4 and the top of `CURRENT_CHECKPOINT.md`.

---

## 4. Gate policy

Never call a phase PASS from static inspection alone.

During iteration:
- use FAST targeted gates;
- parse changed/adjacent scripts;
- run the active contract;
- use the smallest relevant smoke.

Run a FULL cumulative gate:
- when closing a phase;
- when a change crosses a locked subsystem;
- when regression evidence points into an older baseline.

Never weaken persistence, determinism, invariants or contract tests merely to make a gate pass.

GitHub Actions on official Godot 4.7.2 is valid runtime evidence.
Do not relabel CI evidence as Windows evidence.

For Windows:
- `tools/windows/sync/Sync-Main.cmd` is the stable sync entrypoint;
- for a gate use `tools/windows/sync/Sync-Main.cmd Verify-<gate>.cmd`;
- do not create phase-specific Sync launchers as the primary workflow.

---

## 5. Core architecture rule

Gameplay truth lives in simulation/runtime authority, not presentation.

Presentation may display state and issue real commands.
Presentation may not invent:
- resources;
- building levels;
- queues;
- production;
- upgrades;
- injury;
- ownership;
- cultivation;
- profession level;
- hunting rewards.

If backend authority does not exist yet, UI must not fake it.

Read:
`docs/GAME_SYSTEM_ARCHITECTURE.md`

---

## 6. Character authority

Read:
`docs/DISCIPLE_MASTER_SCHEMA.md`

Keep distinct:
- innate foundation;
- learned progression;
- Spiritual Root;
- Bloodline;
- Physique;
- traits/personality;
- equipment/loadout;
- living state;
- organization/social state.

Canonical six foundation dimensions:
- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

Do not replace them with a new parallel stat block.

---

## 7. Locked earlier baseline

Locked earlier runtime:
- P0–P2.12;
- P3.1;
- P3.2 map/camera/selection/real disciple tabs;
- P3.3 disciple operational flow;
- P3.4 building management;
- P3.5 living-sect cues;
- P3.6A runtime slice.

P3.6A final visual acceptance remains user-owned.
Do not reopen locked phases without real regression evidence.

---

## 8. P3.7 canonical direction

Parent:
`docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`

Children:
- `docs/P3_7_BUILDING_TREE_SPEC.md`
- `docs/P3_7_SPIRIT_FIELD_SPEC.md`
- `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`
- `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`
- `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`
- `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`
- `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`

Locked high-level rules:
- target scale 1,000–3,000 disciples;
- player manages policy/groups/teams/infrastructure rather than thousands of individuals;
- hunting is primary outward progression;
- rear-base professions support hunting and economy;
- no permanent disciple deletion from lifespan expiry;
- lifespan expiry -> Ma/Hồn state; only expulsion removes from roster;
- no reward Loot Warehouse;
- no persistent Team Loot Bag for rewards;
- ordinary item/material hunting rewards -> main Sect Warehouse immediately;
- one canonical P3.7 stackable-resource warehouse;
- no warehouse capacity gameplay ceiling;
- resource IDs stay distinct;
- realm/tier + explicit resource quantity are canonical; there is no Phẩm Lực system;
- building instances cap at Lv.100;
- normal levels scale numbers; milestones open mechanics;
- construction/upgrades take real simulation time;
- movement speed, attack speed, work speed, cast time and cooldown are separate concepts.

---

## 9. P3.7 backend currently locked through C1

Backend foundation:
- P3.7A1 Building Authority + Mine;
- P3.7A2R Spirit Field;
- P3.7B1 Resource Registry + canonical Sect Warehouse;
- P3.7C1 open-point six-foundation authority + Dẫn Tiên recruitment.

Exact evidence belongs in `CURRENT_CHECKPOINT.md`, not here.

Do not reintroduce:
- permanent P3.7 `forge_materials` authority;
- permanent P3.7 `technique_materials` authority;
- secondary reward warehouse;
- warehouse-capacity gating.

---

## 10. Current phase source

Do not duplicate current-phase status in AGENTS.

Read:
- `CURRENT_CHECKPOINT.md`;
- `NEXT_CHAT_HANDOFF.md`.

If the checkpoint says no CODE packet is authorized, do not start a queued packet without a new explicit user instruction; historical QA OPEN and PAUSED statuses do not themselves bar a new disjoint authorization.


---

## 11. One-tap user continuation / prewritten next prompts (USER WORKFLOW RULE 2026-10-11)

The user explicitly prefers **tap-to-continue, not typing/planning the next prompt**. Treat this as a **durable project working rule** for all project chats. **Owner reaffirmation 2026-10-14:** end every Tông Môn Bá Đạo project-task reply with a clearly labeled, complete, copy-ready **recommended next-work prompt in Vietnamese** (not merely an abstract suggestion), including when QA is deferred or a phase is blocked. This is a communication rule, **not permission to start code or another phase**.

After **every project-task reply**:

1. Present **2–3 concise, context-specific next choices**, with the recommended/most logical next step first. Do **not** overwhelm with 5–10 choices or ask the user to write their own prompt.
2. Wherever the chat UI supports it, use actual **clickable options/actions** that submit a **complete ready-made Vietnamese next-turn instruction**. The user should be able to tap one option and automatically issue the precise next request. Do not create a decorative button with no action. Include proper repo, branch, scope, commit/CI/test obligations, exclusion of adjacent phases and Windows `PENDING USER` in any coding-authorization prompt.
3. If the current channel cannot render active options, provide numbered **copy-ready prompts** with minimal required user effort; never imply a noninteractive markdown label actually sends a command.
4. Mark **what was verified, what remains blocked, and what needs user approval** before any suggested next step. An option to perform code changes is a **request for authorization**, not permission until the user taps/sends it. Do not choose or execute a coding option on the user's behalf.
5. **Keep continuity:** after an authorized packet, update `CURRENT_CHECKPOINT.md` + `NEXT_CHAT_HANDOFF.md` (or authoritative existing spec) with concise verified evidence, exact next permitted packet, unresolved decisions, and any Windows-only tasks as **PENDING USER**. Reuse existing MD files; do not spawn redundant handoff plans.
6. **Minimize cognitive load:** recommend one clear default, allow alternatives such as audit/review or defer, preserve existing locked rules, and never make the user manually reconstruct technical prompts from memory.

This rule governs **conversation workflow**, not game AI/UI. Do not change gameplay, balance or phase scope merely because the user chooses a chat option.


## 12. Mobile orientation authority — LANDSCAPE LOCK (USER CORRECTION 2026-10-11)

**Tông Môn Bá Đạo is a LANDSCAPE / màn hình ngang mobile game.** The current Godot landscape base is **1280×720**, as in `godot/project.godot`, `docs/P3_6A_PLAYABLE_VERTICAL_SLICE_SPEC.md` and `docs/P3_REFERENCE_UI_AUDIT.md`; the opening production UI and controls must remain landscape and finger-friendly. Reference `Ta Là Tông Sư` / `最强祖师` for landscape sect-map/workforce and production-panel interaction, not for permission to replace canonical gameplay.

**Never redirect this project to portrait / màn hình dọc or 390×844 as the primary runtime**, and never conflate it with the separate `Tu Tiên Nhàn Dỗi` portrait art/runtime project. If an older note suggests portrait, this latest explicit user correction controls. 1280×720 is the **current design baseline**; final device aspect ratios/responsive layout remain to verify on an actual user device. Keep all UX acceptance at landscape. Changing primary orientation requires explicit new user decision.


---

## CURRENT GP-PLAY01 OWNER SCOPE — 2026-11-10 (read with release override)

The owner commissioned **GP-PLAY01 whole-game audit and stepwise playable gameplay closure** on the existing Draft PR #72. Authoritative plan: [GP-PLAY01 master audit/gates](docs/operations/GP_PLAY01_WHOLE_GAME_AUDIT_AND_IMPLEMENTATION_PLAN_20261110.md). Dedicated coordinator skill: [`.agents/skills/tmb-gameplay-closure/SKILL.md`](.agents/skills/tmb-gameplay-closure/SKILL.md). The current `CURRENT_CHECKPOINT.md` remains authoritative for actual status.

**Exclusive split:** this GP agent owns the non-combat loop (New Game/onboarding, workforce, Mine/Forest/Field, Warehouse, alchemy/medicine sources, Economy-A/LT2/W2/T2, crafting equipment and Sect management UI, regression/release coordination). **A separate chat owns skills, combat, enemy/Boss AI, DoT, VFX and fighting animation.** GP agent may READ combat receipts for economy/UI but cannot write combat files or shared combat state; get SHA/interface handoff from that writer instead. Only one writer per overlapping `p3_2_landscape_sect.gd`/State/Warehouse/Save/RuntimeOwner file; coordinate first. No new branch, merge, SaveService or fake resources.

**Mandatory execution:** fetch PR HEAD before each change; source-backed GP0 O9 Warehouse herb/Alchemy + GP02/Economy regression first; then GP1–GP8 staged real user loop and physical QA. Mark `CODE`, `FOCUSED_PASS`, `CUMULATIVE_PASS`, `GUI_HARNESS_PASS`, `PHYSICAL_PASS`, `HOLD` distinctly. Update checkpoint/handoff with exact SHA/log and 2–3 ready-to-click Vietnamese next tasks; don't claim all gameplay works from a Godot headless test.

---

## 13. TMB Agent Skills

Use `.agents/skills/tmb-project-director/SKILL.md` for complex TMB work, then one specialist for the active subtask:
- `tmb-balance-lab`: canonical progression, pill/material/economy balance analysis.
- `tmb-autoplay-ai`: safe hunt/recovery policy and One Active Job transitions.
- `tmb-godot-evidence`: official runtime, persistence/replay, regression and platform evidence.
- `tmb-asset-gate`: provenance, manifests, animation/import evidence.
- `tmb-ui-playtest`: real landscape UI journeys, readability and input evidence.

These skills support the authority order above; they never expand CODE/asset/merge permissions or replace canonical runtime. Latest explicit owner decisions and authoritative source win over stale skill examples. Do not auto-load all six or spawn agents merely because six skills exist. Source registry and discovery evidence: `docs/AI_AGENT_SKILLS_TMB_2026-10-22.md` and `docs/AI_AGENT_SKILLS_AUTO_DISCOVERY_CARE_QA_2026-10-22.md`. Main/PR/QA status remains in CURRENT_CHECKPOINT and NEXT_CHAT_HANDOFF.
