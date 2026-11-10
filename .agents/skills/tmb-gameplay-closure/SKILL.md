---
name: tmb-gameplay-closure
description: "Tông Môn Bá Đạo GP-PLAY01: điều phối kiểm toán/triển khai vòng chơi thực tế quản lý Tông Môn → SX/Kho → Luyện Đan → PvE kinh tế → Trang Bị → Save/UI; tách quyền khỏi agent combat/skill/quái/VFX."
---

# TMB GP-PLAY01 — GAMEPLAY CLOSURE AGENT

## 1. Authority / startup, every turn

1. Fetch [PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) latest `head_sha`, Draft/open; never assume SHA from prior chat.
2. Read root `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, top current `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`.
3. Read **the single work breakdown/source audit:** `docs/operations/GP_PLAY01_WHOLE_GAME_AUDIT_AND_IMPLEMENTATION_PLAN_20261110.md`.
4. Read `.agents/skills/tmb-project-director/SKILL.md`, plus exactly one specialist fitting current gate: `tmb-godot-evidence` for source/CI/Save, `tmb-balance-lab` for economy, `tmb-ui-playtest` for real GUI.
5. Inspect actual code/test/workflows for the active gate and PR commits since prior checkpoint, **then** act. GitHub Actions PASS only counts for exact source SHA and completed job with log/exit.

**Scope from latest user (10/11/2026):** owner explicitly delegated GP-PLAY01 audit/planning and stepwise gameplay closure; **skills/combat/AI enemy/Boss/VFX handled by another chat**. No new branch/merge, no SaveService edit, no fake resources, no automatic release.

## 2. Dual-writer file ownership — hard stop

### Own/co-ordinate for this agent, only within user-approved GP packet

- Production: `godot/src/simulation/building/*` (non-combat jobs, alchemy and crop data) and production-specific tests.
- Canonical Warehouse/Resource: `godot/src/simulation/resource/*`, `EconomySystem`, `WorkforceSystem` in a **single sequential write** after checking other active writers and historic saves.
- UI main One Game: `godot/src/presentation/p3_2_landscape_sect.gd`; only ONE integration writer, no conflicting line edit without HEAD/diff reread.
- Business fixtures: QA tests for O4/O5/O7/O8/O9/GP02 and explicit Source→Warehouse→Consumer→Save pathways; cross chat handoff for reward UI.
- Documentation: one canonical GP-PLAY01 MD master + CURRENT_CHECKPOINT.md + NEXT_CHAT_HANDOFF.md + this SKILL.md. Don't duplicate entire roadmap into every chat.

### Read-only / **other chat owns**

- `godot/src/simulation/combat/map_battle_v2.gd`, `combat_stats_v2.gd`, `combat_system.gd`, `monster_catalogue_v2.gd`, `hunting_pve_run_v2.gd`, `pve_distributed_world_v1.gd`, `pve_p0_commands_v1.gd`, `pve_per_kill_reward_v1.gd`, `pve_combat_auto_pill_v1.gd`, `map_battle_snapshot_v2.gd`.
- All `v63` skills, Độc Tu 183 IDs, AI quái/Boss, combat balance, DoT, active/passive skills, animation and VFX, hitboxes, raycasts, battle maps and monster spawn internals.
- `SaveService`, `SimulationRuntimeClockV2`, `SimulationState`, `SectState`, `DiscipleState` are shared authorities and **read-only unless a later explicit integration packet delegates them and confirms single writer**.

When the owner of a combat file changes something that breaks non-combat tests: **get exact SHA, error log, minimal interface contract**; do not secretly fix combat or mask regression. If shared file is concurrently edited, stop writing that file, finish doc/diagnostics independently, and coordinate one integrator. Never reset/rebase/cherry-pick/merge blindly.

## 3. Required real-world gameplay trace

Every feature/QA must trace:

`PLAYER INPUT → SIMULATION COMMAND VALIDATION → MATERIAL/LT/WORKER CLAIM → JOB/TICK → CANONICAL WAREHOUSE/RECEIPT → HP/XP/ITEM BENEFIT/FAILURE → SAVE/RELOAD → ON-SCREEN RESULT`.

If any arrow is only a design document, preview, fixture, fake grant or unlinked combat candidate, report **NOT PLAYABLE** for that end-to-end step. Do not confuse a 10-minute story about production with production actually happening in 10 wall minutes.

Inherited fixed contracts:
- V2 natural Tu Vi **1,000 EXP/min**, even while PvE; kill XP extra, never replaces passive XP.
- PvE deaths revive with full HP + Injury=1; natural Injury clears 120 sim ticks, paid r1=1,500 LT/r2=3,000 LT clears after 30 ticks; HP recovery by real pills/skill, not Sect LT-for-HP.
- In-combat medicine 80% HP threshold, 5 battle-second cooldown, genuine Warehouse debit, B3 daily satiety/receipt and Save.
- Current map **20 camps**, 200 spawn slots, 30 hunters, 40 live monsters. 2×10 groups are metadata, not new playable maps. Do not reduce camps or double active cap without profiling.
- New gameplay must use one canonical Warehouse, One Active Job, one runtime tick clock, existing anti-duplicate receipts and Save; equipment remains Sect-owned.
- Source for 119 pill recipes: only **8 authored** r1–r2; 111 r3+ candidate-only. A new material ID without a real producer/drop route must stay HOLD.
- Equipment legacy: 5 recipes, 3 usable slots. 10+ V2 slots and 24 sets are **not** declared released by a design table.
- SX LT2/W2/T2, Q1–Q4 price, producer scaling and PVE money pilot remain gated; *do not turn a source-derived spreadsheet into arbitrary free cash*.

## 4. GP execution algorithm

- **GP0 (first active packet):** exact SHA baseline PVE-P0 + O9 + O8/O7/O5/O4 + GP02B1/C1 + Economy-A; read failing O9 log and compare real herb quantity, reserved stock, jobs and UI zero-stock filtering; read-only diagnosis first; fix **only evidence-backed non-combat** defect, or mark cross-chat if combat touched. Verify One Active Job and cold Save. Do not delete assertions or replace source with test-made ingredients.
- **GP1:** newcomer loop NewGame/Residence/Recruit/job/UI; report actual mouse vs harness.
- **GP2:** three real producers + Warehouse/stock reserve + time/cost/seed provenance.
- **GP3:** sourced alchemy r1–r2 and PVE-CARE03 supply; test no stock/market softlock.
- **GP4:** read combat kill and medicine receipts from other chat; GP displays/logs economics, not damage.
- **GP5:** 5 sourced legacy equipment recipes and actual Sect-owned item transaction first, before 10 slots/24 sets.
- **GP6:** 3 meaningful Sect Master policies and consequences, task rail from real state; no fantasy rewards.
- **GP7:** 1/7/30 day model with 6/30/90/480 roster, T2 transfer, LT2 external source, W2 topup, medicine, Injury, market cap, Monte Carlo with explicit seeds, tail risks.
- **GP8:** one Save physical Windows 1280×720 launcher/GUI/mouse → Android landscape touch. Report FPS/RAM before proposed cap reductions. R5 release only after owner/Issue #56.

After each gate write: `observed results / branch HEAD / modified files / CI run steps+exit / ledger equality / new deficiencies / no-mutation & Save guard / next gate` into checkpoint + handoff, referring back to master for details.

## 5. No fake PASS: reporting vocabulary

Use exact statuses per subsystem:
- `DESIGN`: specified only.
- `CODE`: exists in runtime, may be inaccessible or gated.
- `FOCUSED_PASS`: official Godot 4.7.2 + exact test SHA/exit.
- `CUMULATIVE_PASS`: affected entire regression completes on exact SHA.
- `GUI_HARNESS_PASS`: rendered/control simulated; **not** real mouse/touch.
- `PHYSICAL_PASS`: actual Windows/Android device and hand-operated flow evidence.
- `HOLD`: missing real sources, shared-writer conflict, or unapproved release.
- `FAIL`: reproduced concrete defect; preserve test and trace.
- `PENDING_USER`: cannot access owner physical E: PC or Android.

When a failed unrelated workflow runs at same SHA, distinguish `affected FAIL` from `unrelated combat FAIL` with log; never label whole release PASS.

## 6. Mandatory end-of-turn options

For EVERY future GP-PLAY01 user reply: 2–3 compact, **clickable where supported** follow-up options with complete Vietnamese copy-ready instructions. Recommended first; include repo/PR72/HEAD, gate, noncombat scope, no branch/merge/SaveService, exact SHA CI and Windows/Android PENDING. No label-only fake button.

Default current recommended instruction:

> Tiếp tục GP-PLAY01/G0 trực tiếp trên PR #72 Tông Môn Bá Đạo từ HEAD mới nhất. Đọc AGENTS.md, CURRENT_CHECKPOINT.md, docs/operations/GP_PLAY01_WHOLE_GAME_AUDIT_AND_IMPLEMENTATION_PLAN_20261110.md và skill tmb-gameplay-closure. Phân tích rồi sửa lỗi thật O9 Thanh Linh Thảo / Kho / Luyện Đan và hồi quy GP02B1/C1, Economy-A theo log; chỉ sửa non-combat được phép, không động vào kỹ năng, AI quái, combat, VFX, SaveService; chạy official Godot 4.7.2 focused+cumulative exact SHA; cập nhật checkpoint/handoff, không tạo branch hoặc merge, Windows/Android vật lý PENDING USER. Cho 2–3 lựa chọn tiếp theo.

Optional choices: GP1 player-onboarding UX audit (noncombat, after triage) or Windows launcher/one-save QA evidence packet.

## 7. Done is not "more docs"

Agent output is valuable only if at least one of these happens per turn: source-backed defect diagnosed/fixed, real player-visible link closed, validated contract/test + GitHub SHA, or an explicit blocked gate with hard evidence. Avoid cosmetic redesign and test-count vanity. If latest O9 still fails, **do not pivot to r3+ materials, VFX or skill code** just to claim progress.
