# TÔNG MÔN BÁ ĐẠO — PH1: READY-TO-CODE PREP WHILE PH0 RUNS

**22/10/2026 · DOCS ONLY · PH1 CODE NOT YET AUTHORIZED.** Main verified as `461caca1171462e0da092f21108c5c1733157ad9`. **PH0 Codex reported ACCEPTED/PASS 5/5 on official Godot 4.7.2**, local full-checkout commit `97a3d98094451e85e8d5f26e8986a60968512ee5` (three authorized files, clean worktree; no push/merge). That is the PH1 candidate BASE, not GitHub main or the earlier reconstructed local commit `09e97d2`. The user's Codex QA summary is the acceptance evidence received; original Windows E: log ZIP has not been independently fetched into this chat. Source A worker remains untouched.

## 0. PH0 acceptance handoff / PH1 preflight (NEW)

**PH0 user-reported QA:** 5/5 focused/regressions PASS, Godot `4.7.2.stable.official.ed1daf0bf`, exit0+PASS marker; root certificate store diagnostic without run failure; GP-02C1 negative fixture expected. Commit `97a3d98094451e85e8d5f26e8986a60968512ee5` in Windows isolated `TongMonBaDao_B3_PH0_acceptance`. Reports: `B3_PH0_ACCEPTANCE_RESULTS.md`, `B3_PH0_3_FILE_CODE_FINAL.diff`, `B3_PH0_ACCEPTANCE_EVIDENCE.zip`, `PH1_CODE_AUTHORIZATION_DRAFT_vi.md` on owner's E: path. **Those E: documents are not accessible to this cloud session directly; before PH1 code, Codex must read its own local actual final PH0 sources and PH1 draft.**

**Base rule:** from full repository checkout that contains the **accepted local PH0 commit**, create a **new isolated PH1 worktree** starting at `97a3d980...`. Do not start from raw remote main, which still lacks PH0; do not cherry-pick reconstructed `09e97d2`. If PH0 SHA was amended, inspect full ancestry, changed-file allowlist and rerun exact PH0 gates or STOP for updated owner approval.

**Specific audited PH0 pilot APIs (from uploaded PH0 patch, MUST re-confirm against accepted final local commit):**
- `MapBattleV2.setup(world_id,party,initial_monsters,true)` active continuous; `step(viewed_map)`; `add_continuous_monster(actor)`; `remove_downed_monster(actor_id)`.
- `pending_kill_events()` returns domain entries with `kill_id`, `spawn_slot_id`, `slot_generation`, `monster_instance_id`, `species_id`, `at_seconds`. `acknowledge_kill_event(kill_id)` **MUST NOT be used as production paid/settled ACK by PH1A**; PH2 will persist the matching immutable reward receipt+Warehouse atomically before ACK. A pilot in-memory consumed-event index is permissible solely for bounded test orchestration, never an assertion of durable payout.
- PH0 versioned snapshot writer emits continuous v3, legacy finite v1; reader additionally accepts B2.4 v2. PH1A must use real returned types and reject malformed kill identity. No dependence on UI `events` cap `MAX_EVENTS=2400`.
- Backpressure pilot `MAX_PENDING_KILLS=256`, `MAX_REMEMBERED_SPAWN_SLOTS=1024`, `MAX_MONSTERS=40`: PH1A bounded fixture stops before any cap, must not suppress/lose events and must not advertise endless production loop until PH2 ACK exists.

**Writer/scope:** only **one designated PH1A CODE writer** in a new worktree, with three **new** files exactly listed in §3. This is the narrow proof stage. Real production admission/reservation, persistence and offline remain PH1B–PH3 and require new authority/allowlist; do not fold them into this approval. If actual `PH1_CODE_AUTHORIZATION_DRAFT_vi.md` requests shared runtime/State writes, treat it as a **larger competing packet requiring separate review**, not implicit permission.

**Highest-priority negative fixture:** disciple with `active_pve_encounter_id` or production job remains unavailable; PH1A never sets that existing legacy reservation and never acts like persistent world owner. A cloned genuine loadout in an isolated headless test is allowed, but must not be advertised as a deployed live sect hunter.

## 1. Only deliverable that matters

**PH1A = real actors hunt/respawn in one isolated world simulation**: one **genuine V2 DiscipleState** sourced from canonical live-state factory/recruitment (never a handcrafted fake stats dictionary); one normal `MonsterCatalogueV2` species; a stable region/slot/generation and automatic respawn after real HP0; real `DiscipleCombatLoadoutV2.build`; PH0 continuous Combat V2 steps >90s including a period with 0 live monsters or downed hunters; replay deterministic. **No rewards, no fake offline or production claims, no UI required**. Test with and without world viewer.

**PH1A is an in-memory proof, NOT a production Sect deployment**. It does not reserve a live disciple in SaveService: attempting to set `DiscipleState.active_pve_encounter_id` without a matching `SectState.v2_pve_active_runs` violates the current `SimulationState.validate_invariants` contract. Do not hijack finite-PvE reservations or steal working disciples. The separately authorized **PH1B** admission/persistence packet must add a sanctioned B3 reservation owner and valid save schema before live routing.

**Scope explicitly deferred:** canonical Warehouse/loot (PH2), PENDING kill settlement, SaveService migrations, Scheduler/RuntimeClock integration and offline parity (PH2/PH3), Boss multi-team, AI aggro/leash, Source A/visual Map, Character Studio, V5.

## 2. Read real sources

- PH0 outcome: `B3_PH0_FIRST_CODE_AUTHORIZATION_PACKET_PERSISTENT_HUNT_2026-10-22.md` and actual PH0 Codex new commit/diff. **DO NOT assume the interim V3 death-event API, data fields or snapshot version will stay unchanged** until PH0 passes.
- `main/godot/src/simulation/combat/disciple_combat_loadout_v2.gd` `build(state,disciple,realm,floor,body_realm,body_floor,role,position,party_id)`: reads actual equipped gear, learned skills, derives stats and actor HP. Determine realm/floors only from `DiscipleRealmProgressV2.current` for a validated V2 profile.
- `main/godot/src/simulation/combat/hunting_pve_run_v2.gd` `begin` validates HP, injury, old active PvE, One Active Job, work-cycle, spirit plots, timed recipes, body training; mirror **read-only eligibility** in PH1A, do NOT call finite `HuntingPveRunV2.begin/claim` to create a B3 session.
- `main/godot/src/simulation/combat/monster_catalogue_v2.gd` `create_actor(species_id,realm,floor,encounter_id)` has real V2 monsters. Pilot `truc_thu` in `thanh_truc_lam` is a **design/test-only example**, not new content or loot-rate approval.
- B2.4 uploaded ZIP `source_snapshot/godot/src/simulation/combat/spawn_director_v1.gd` does deterministic slots with `generation`, `spawn_initial`, `advance`, `handle_death`, `snapshot/restore`. It imports `res://addons/spawn_loot_studio/schema_validator.gd` and an external bundle: **do not bring entire B2.4 editor plugin or `project.godot` into PH1A**. Port/reuse only standalone spawn semantics with an explicitly validated small fixture/schema. Its internal floating `now` is TEST TIME ONLY, not new production clock authority.
- `main/godot/tests/simulation/dv2_03_live_runtime_integration_test.gd` shows genuine recruitment: start `LiveGameRuntimeV2` on isolated `user://`, call `DiscipleGeneratorOpenPoints.new().generate_candidate`, `RecruitmentSystem.accept_candidate`, ensure `DiscipleRealmProgressV2.owns_v2_progression`, choose HOLD. Do not run as second live game owner.
- `main/godot/src/simulation/core/simulation_runtime_clock_v2.gd`: **60 wall seconds = one canonical scheduler minute**. PH1A uses injected test step/time; PH1B/PH3 will bridge a single owner clock and persist its accumulator.

## 3. Proposed EXACT FIRST PH1A file scope (request separate CODE approval)

Use a new isolated clean worktree after PH0 code integration into its own branch/tested base. Do **not** work on the Source A Windows converter checkout or the PH0 worktree while Codex is testing it.

**ADD ONLY** (preferred zero shared-writer contention):
1. `godot/src/simulation/combat/b3_spawn_director_v1.gd` — extract B2.4 slot/generation/RNG/respawn ideas, keep local-time parameter injected by wrapper; standalone without B2 editor plugin.
2. `godot/src/simulation/combat/b3_hunting_session_pilot_v1.gd` — in-memory orchestration: authentic V2 disciple read-only admission → PH0 MapBattleV2, normal monster source → spawn → domain HP0 → slot cooldown → respawn. This is **not canonical online/offline owner**; never debit/credit game currency or resources.
3. `godot/tests/simulation/b3_ph1_real_disciple_respawn_test.gd` — focused tests.

**MODIFY zero existing files**. If PH0 API, class_name conflicts, project registration or source schema requires an extra file: STOP, revise allowlist and obtain owner authorization before writing.

**Admission**: may read `SimulationState` and `DiscipleState` for test identity; never set `active_pve_encounter_id`, bypass jobs, change `current_action` or force real HP updates without a proper production reservation. In local isolated test, only freeze/copy authoritative loadout to combat domain. Stable IDs: world/region/slot/generation and source disciple_id; no collision with legacy encounter_id.

## 4. Acceptance (real Godot 4.7.2 required)

- PH1A-01: genuine recruited V2 disciple has canonical source profile; no forged gear, skills or realm; invalid/production-busy/injured/old-PvE actor refuses read-only admission.
- PH1A-02: `truc_thu` actual MonsterCatalogue stats and one validated slot; spawn ID `slot:generation` stable, no duplicate.
- PH1A-03: combat uses PH0 continuous mode, >90 seconds, no finite WIN/reset.
- PH1A-04: source HP0 event produces exactly one slot cooldown; no death detection through capped VFX events.
- PH1A-05: independent respawn increments generation and can be attacked; stale death from old generation cannot kill/recredit new monster.
- PH1A-06: 0 monsters/0 fighting disciples does not end world; no fake heal.
- PH1A-07: same seed/actions → identical snapshot, kill IDs and spawn timing, including viewed/unviewed.
- PH1A-08: a negative B2.4 corrupt catalog / invalid bounds / illegal species fails closed; no mutation of canonical Warehouse/SaveService/RNG on failure.
- PH1A-09: 10–20 bounded spawn/kill cycles without unbounded memory/events; measure number of alive actors and snapshots.
- PH1A-10: existing PH0 tests and legacy battle, five-level PvE and GP-02C1 focused regression remain green on **actual same-byte Godot4.7.2 baseline**.

Stop before PH1A CODE if PH0 official tests fail or PH0's domain death queue contract cannot be safely consumed. **No FULL/CI/merge/push**. Run focused tests only when safe relative to Source A workload, isolated user://. No gameplay production PASS can be inferred from this sandbox.

## 5. PH1B and PH2 blockers, ready for owner after PH1A

**PH1B (separate shared-file integration approval):** real One Active Job reservation in canonical world; authoritative persistent `SectState` or `SimulationState` B3 world record, mode discriminator from finite PvE, valid migration/save; add HP/injury return treatment. Must review SimulationScheduler/SaveService owner allowlist explicitly, not hidden in PH1A.

**PH2 (separate content+code approval):** production per-kill loot table must have actual registered resource and approved quantity/probability; B2.4's synthetic test-only 100% `linh_moc` cannot be silently used. One HP0 → one immutable receipt → canonical Sect Warehouse + Saved World transaction; no last hit ownership and no VFX-ring events.

## 6. Copy-ready CODE request, DO NOT SEND UNTIL PH0 PASS

TÔNG MÔN BÁ ĐẠO — TÔI CẤP PHÉP CODE B3-PH1A SAU KHI PH0 FOCUSED GODOT4.7.2 PASS. Đọc AGENTS.md, chính xác HEAD base của PH0 đã được kiểm chứng và file docs/handoffs/2026-10-22/B3_PH1_REAL_DISCIPLE_RESPAWN_READY_PACKET_2026-10-22.md trên nhánh docs/b3-v2-architecture-redesign-20261022. Làm một worktree cách ly riêng, CHỈ thêm ba file: b3_spawn_director_v1.gd, b3_hunting_session_pilot_v1.gd và b3_ph1_real_disciple_respawn_test.gd (đường dẫn đầy đủ trong packet). Kế thừa SpawnDirector B2.4 có chọn lọc, không nhập plugin/editor hoặc project.godot, không sửa PH0/State/Save/Scheduler/Warehouse/Source A/Map/Studio/V5. Chạy một đệ tử V2 thật từ factory/recruitment qua DiscipleCombatLoadoutV2, một monster thật trong world continuous, death domain → slot cooldown → generation mới; >90 giây, không loot hoặc save production. Chạy PH1A-01..10 + focused legacy trên Godot4.7.2, một writer, không FULL/CI/push/merge. Nếu thiếu PH0 API hoặc cần sửa file thứ tư, dừng xin phép. Bàn giao diff, commit, test log và yêu cầu PH1B. **Đây là CODE request tương lai, không phải CODE đã được cấp phép hôm nay.**
