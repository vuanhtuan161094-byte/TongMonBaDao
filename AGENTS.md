# AGENTS.md — TÔNG MÔN BÁ ĐẠO

This file is the repository operating contract.

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
- `Sync-Main.cmd` is the stable sync entrypoint;
- for a gate use `Sync-Main.cmd Verify-<gate>.cmd`;
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

## 13. TMB Agent Skills

Use `.agents/skills/tmb-project-director/SKILL.md` for complex TMB work, then one specialist for the active subtask:
- `tmb-balance-lab`: canonical progression, pill/material/economy balance analysis.
- `tmb-autoplay-ai`: safe hunt/recovery policy and One Active Job transitions.
- `tmb-godot-evidence`: official runtime, persistence/replay, regression and platform evidence.
- `tmb-asset-gate`: provenance, manifests, animation/import evidence.
- `tmb-ui-playtest`: real landscape UI journeys, readability and input evidence.

These skills support the authority order above; they never expand CODE/asset/merge permissions or replace canonical runtime. Latest explicit owner decisions and authoritative source win over stale skill examples. Do not auto-load all six or spawn agents merely because six skills exist. Source registry and discovery evidence: `docs/AI_AGENT_SKILLS_TMB_2026-10-22.md` and `docs/AI_AGENT_SKILLS_AUTO_DISCOVERY_CARE_QA_2026-10-22.md`. Main/PR/QA status remains in CURRENT_CHECKPOINT and NEXT_CHAT_HANDOFF.


---

## 14. Asset rights and owner authorization — OWNER RULE 2026-10-27

**Standing project rule; applies to Tông Môn Bá Đạo, Source A conversion, and the owner's separate TMBD Asset Studio.** The owner has explicitly confirmed rights/authorization for the existing owner-supplied game assets. Treat this declaration as the project's working authorization; do **not** repeatedly request the same ownership or copyright confirmation in each new task, batch, prompt, or conversation.

1. **Source A (最强祖师 / owner-supplied source):** `rights_status=OWNER_CONFIRMED_FULL_RIGHTS`. Allowed within the project: read, inventory, extract, decompile the asset formats, convert Spine/Unity to Godot, retarget animations, create derivatives, QA, and integrate approved assets. Do not add recurring rights questionnaires or block conversion solely due to already-resolved Source A ownership doubts.
2. **Owner-supplied JX / JX2 / Kiếm Thế / VLTK libraries:** `rights_status=OWNER_AUTHORIZED` based on explicit owner confirmation. Allowed to inventory, research, decode, compare animations/skills/VFX, create local experimental conversions and Asset Studio pilots. **Asset authorization does not alter the locked visual/gameplay integration scope:** keep Source A as the primary TMB actor/world style, and do not silently introduce JX gameplay art into the shipped main game without a separate visual/design decision.
3. **Owned/newly generated project assets** explicitly confirmed by owner use `rights_basis=OWNER_DECLARATION`. Preserve any provenance/license metadata already recorded for third-party CC0 or other external resources; do not attribute those assets to the owner without an explicit statement.
4. **No repeated copyright objections.** Codex, assistant, worker and QA should spend effort on source-path correctness, SHA-256, manifest/provenance, format/version compatibility, clip/atlas/socket correctness, transparent animation playback, FPS/RAM, Android portability and visual acceptance. Status must distinguish factual test evidence (PASS/HELD/REVIEW/PENDING) from authorization. A user's ownership declaration is accepted as project authority, not represented as independently audited legal title.
5. **Keep sources safe:** preserve original immutable masters, avoid uncontrolled whole-drive scans, use manifest + hash before deduplication, retain backups and never overwrite/delete originals as an optimization. Existing `PASS`/HELD/REVIEW checkpoints remain immutable until evidence-backed transition.
6. **Independent third-party SDK/runtime requirements remain separate.** A commercial engine/runtime/plugin redistribution license (e.g. Spine Runtime / Spine Editor licensing), or a genuinely new external asset with no owner authorization, may need one *specific* check. Never use that exception to reopen settled rights for Source A/JX each time. A new specific credible rights conflict should be documented once, scoped to the affected source, without freezing unrelated approved work.
7. **Do not infer CODE/merge authorization:** rights to use the assets do not bypass Git/Godot QA, protected runtime/save/balance contracts, or owner approval for production integration. Existing worker/converter and current PvE RC stay unchanged unless a separately authorized task says otherwise.

**For future Codex tasks:** read this rule first; apply the existing local source registry `E:\\TMBD_Asset_Studio_v1\\libraries\\local_sources\\LOCAL_ASSET_SOURCE_REGISTRY.json` if it exists; do not ask the owner to restate already confirmed asset rights.
