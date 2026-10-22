# TÔNG MÔN BÁ ĐẠO — B3-PH0 / FIRST CODE AUTHORIZATION PACKET

**Date:** 22/10/2026. **STATUS: DESIGN PACKET FOR OWNER APPROVAL ONLY. NO CODE AUTHORIZED YET.** Only this Markdown is committed in docs branch; no game source, merge, CI or Source A worktree changes.

**Repo** vuanhtuan161094-byte/TongMonBaDao; live main HEAD at audit: **461caca1171462e0da092f21108c5c1733157ad9**; docs branch docs/b3-v2-architecture-redesign-20261022.

**Input actual ZIP:** TMB_B2_4_HUNT_LOOP_REVIEW(1).zip; SHA-256 **29b2e6fa11932c94abac054b48cbd9440c63473079472dabcee0be2605fea422**. B2.4 worktree was LOCAL DIRTY/UNTRACKED at the main SHA, no pushed or committed implementation branch. Read its source_snapshot, git_diff.patch, all_changed_files.txt, docs/B2_4_INTEGRATION_RISK.md and docs/B2_4_TEST_MATRIX.md. Do not cherry-pick a nonexistent commit or overwrite a worktree from ZIP. Main checked directly through GitHub. Follow AGENTS.md, GAME_SYSTEM_ARCHITECTURE.md, CURRENT_CHECKPOINT.md and NEXT_CHAT_HANDOFF.md.

## A. Product target — PH-V1 (NOT first packet's acceptance)

Goal: smallest TRUE persistent hunting loop. One real canonical V2 disciple, one genuine MonsterCatalogueV2 normal species, one slot with independent respawn, shared Combat V2 actual movement/HP/casts/skill and >90-second world timeline; one AUTHOR-APPROVED per-kill registered stackable material enters ONE canonical Sect Warehouse; world+actor+spawn+loot RNG+PENDING/COMMITTED receipt save atomically through SaveService; restart/retry no duplicate; zero currently fighting disciples or monsters does not end the world. One Active Job/Injury 0/1/120 stays. The world design remains data-driven, not capped as product to 1 map, 3 zones, 5 recipes, 30 actors, 40 monsters or 90 seconds.

**Reason not to code all at once:** B2.4 uses six synthetic actors and a cloned Warehouse, never production SaveService. Main SaveService CURRENT_VERSION=2, SimulationState SAVE_VERSION=1, SectState has finite PvE reservations/receipts, SimulationRuntimeClockV2 advances only **once per 60 wall seconds = one scheduler minute**. The 0.25-second world substeps need a single clock/substep ownership contract; production per-kill tables in B2 are EMPTY. Forcing all state/combat/warehouse/offline migrations into first patch would violate scoped subsystem ownership and risk duplicate rewards.

**First recommended CODE packet is PH0**, then separate PH1–PH3 packages reach the above genuine playable milestone. PH0 does NOT claim true production loot/save/real disciples.

## B. Source-verified implementation gap matrix

| Evidence | Exists | Blocking gap |
|---|---|---|
| main MapBattleV2 | 0.25s STEP_SECONDS, MAX_SECONDS=90, MAX_EVENTS=2400, legacy finite WIN/DEFEAT, Combat V2 damage/cast/RNG | cannot continue world beyond 90 or after parties all down |
| B2.4 local MapBattleV2 | opt-in continuous_mode, individual monster add/remove, death identity, disable time limit and WIN on 0 monsters when enabled | still DEFEAT if all disciples HP0; run() loop capped near 90s; _nearest_enemy has no perception/leash |
| B2.4 MapBattleSnapshotV2 | v2 writer / v1+v2 reader, accurate variant Base64, continuous >90s; legacy v1 supported | not a canonical world/SaveService snapshot; require real v1 reader parity |
| B2.4 SpawnDirectorV1 | stable slot/generation, respawn timer, deterministic local RNG, pilot active cap40 | own float now, no shared runtime clock; cannot silently reuse separate time owner |
| B2.4 SpawnLootRuntimePilotV1 | independent sandbox step, cloned Warehouse, event_cursor, ledger retry, pause | death discovered by scanning capped UI battle.events, no production SaveService |
| B2.4 KillReceiptLedgerV1 | resource-only pending/settled roll, deterministic id, rollback of cloned warehouse | no production source/unique/XP/wallet or synchronized persisted receipt |
| main HuntingPveRunV2 | HP/injury/One Active Job/admission guards, canonical realm/loadout | tied to legacy finite hunt terminal settlement; must not call legacy claim from world mode |
| main RuntimeOwner/RuntimeClock/Scheduler | one clock 60s -> one scheduler tick/minute, natural Tu Vi, Injury/production owner | missing owner-consistent 0.25s substeps, backlog and reentrancy validation |
| main SectState/SimulationState/SaveService | one canonical warehouse and v2 saved encounters, .tmp/.bak | no B3 world/save/receipt schema or strict migration |
| main ResourceRegistry/WarehouseSystem | resource IDs and atomic preflight stack guard | no authorized production per-kill rate; must not import synthetic 100% linh_moc |

**Content gate:** MonsterCatalogueV2 flags truc_thu, thanh_lang, hac_lang as loot_ready:true but that is NOT proof of an approved per-kill table. Legacy HuntingMapV2 rewards by WHOLE ENCOUNTER WIN and has its own guarantee counter. B2.4 catalog production per_kill is empty; synthetic_per_kill_test_only.json contains test-only 100% linh_moc. No live per-kill grant until separate authorized source and amount/chance are selected. Source A character rig names NEVER determine canonical species, loot, skill or player role.

## C. PH0 — FIRST proposed authorized code scope

**CODE packet ID:** B3-PH0-CONTINUOUS-KERNEL.  
**Proposed clean isolated branch after owner approval:** feature/b3-ph0-continuous-kernel-20261022. Single writer. Exact main SHA pinned above; if HEAD moves, STOP for refreshed scope approval. Do not open/modify dirty B2.4, V5.1, Character Studio, Map or Source A worktrees. No main push/merge, no CI/FULL unless separately approved.

### EXACT ALLOWLIST (only three files)

1. MODIFY godot/src/simulation/combat/map_battle_v2.gd. Carry reviewed B2.4 semantic patch for opt-in continuous mode, independent monster add/remove and stable generation identity; keep ALL LEGACY finite default calls unchanged. Harden continuous world to remain active when every disciple is downed, as well as when monsters are temporarily all dead, and remove 90-second run() restriction ONLY when continuous. Must avoid unbounded memory or event backlog. Provide source HP0 domain event for future receipt independent of capped presentation events. If new event hook cannot be safely implemented in this file without changing Combat V2 formula, mark blocked and request scoped follow-up.
2. MODIFY godot/src/simulation/combat/map_battle_snapshot_v2.gd. Versioned v2 writer and v1+v2 backward reader matching source changes; permit valid 0-alive world, time beyond90, accurate HP/RNG/pending casts/generation; reject corrupt/newer data and object pointer injection, preserve legacy v1 behavior.
3. ADD godot/tests/simulation/b3_ph0_continuous_kernel_test.gd. Deterministic isolated contract tests below.

**HARD DISALLOWLIST:** godot/project.godot; godot/addons; godot/data; godot/scenes; godot/src/presentation; SimulationState, SectState, DiscipleState; SimulationScheduler, SimulationRuntimeClockV2, SimulationRuntimeOwnerV2; SaveService; WarehouseSystem, ResourceRegistry, HuntingPveRunV2, HuntingMapV2; source original Source A / Studio / V5 / Map / game balance; CURRENT_CHECKPOINT.md and NEXT_CHAT_HANDOFF.md shared files. No fake loot, no synthetic actor claim, no schema migration within PH0.

### PH0 deterministic acceptance

- PH0-T01: Default finite setup still ends WIN, DEFEAT, 90s timeout identically to main on same tests/seeds (no damage/timing/target/skill changes).
- PH0-T02: continuous-mode world remains active after 90.25s, 180s and >3600s (advanced in bounded batches), never battle-wave resets.
- PH0-T03: when last monster dies, no WIN, can admit one future generation with nonduplicate actor ID.
- PH0-T04: when every disciple is down, no world DEFEAT; all downed actors remain unable to attack, cannot spawn fake rewards/HP.
- PH0-T05: add/remove monster validates actor ID, slot generation, cap, stale cast/hit and rejects duplicate IDs.
- PH0-T06: HP>0→0 yields exactly one immutable typed death domain signal for source generation; two lethal attempts same tick do not mint twice.
- PH0-T07: death source remains available after UI event buffer reaches/compacts MAX_EVENTS=2400; never read event_cursor to award.
- PH0-T08: v1 snapshot loads unchanged; v2 long-running world snapshot preserves HP/RNG/cast, idle/empty-roster legality; invalid versions/corrupt payload fail closed.
- PH0-T09: viewed/unviewed snapshots agree with seed/tick and input order; renderer cannot modify gameplay.
- PH0-T10: 0.25s stepping honors requested bounded max_steps, not mandatory cap by 90s; no unbounded queue.

**Regression run AFTER approval:** official Godot 4.7.2 focused b3_ph0 test, dv2_02_battle_snapshot_test.gd, dv2_02_group_map_battle_test.gd, dv2_02_five_level_pve_test.gd, gp_02c1_injury_settlement_test.gd, git diff --check in clean TEMP clone/isolated user://. Compare the exact source/test SHA with baseline; B2 GP-02C1 PASS is NOT COMPARABLE to V5.1 test SHA. Do not weaken test or claim GUI/Android PASS. These are acceptance test DESIGNS now; NO B3 PH0 test has run.

**Rollback:** Revert/discard only isolated PH0 worktree/commit (no canonical save migrated). Never reset Source A Windows worker, V5.1 dirty source, Character Studio dirty files or unrelated worktrees.

## D. Next separately authorized scopes needed for PH-V1 (not permission inside PH0)

| Packet | Milestone / proof | Protected files / gates |
|---|---|---|
| **PH1 — REAL WORLD OWNER** | one canonical DiscipleState/DiscipleCombatLoadoutV2 with true One Active Job admission; one MonsterCatalogueV2 normal monster + one B2 SpawnDirector slot with independent respawn; one single in-world step owner; >90s and empty party survival | real admission validation must not cancel Mine/Field/recipe/body job; SpawnDirector clock must derive from runtime timeline; future exact allowlist needed for WorldAdapter + owner state hooks |
| **PH2 — LIVE REWARD & SAVE** | domain lethal from PH0 into stable slot+generation receipt; one approved real registered per-kill stackable to canonical Warehouse; world state+receipts+RNG saved/reloaded coherently; crash/pending/retry exactly once | SectState/SimulationState/SaveService migration, Warehouse read-only consumer, approved per-kill content source; one shared-file writer, explicit save v1/v2 migration and old encounter isolation |
| **PH3 — CLOCK/OFFLINE + PLAYABLE GATE** | run Combat world substeps linked to same 60s scheduler minute without second time owner; bounded offline backlog, online/offline deterministic parity, one playable real-team hunt after reload | RuntimeOwner, RuntimeClock, Scheduler exact order/barrier and Source A-independent headless test; no fake avg offline kills |
| Later | TeamAI, MonsterAI aggro/leash, Boss multi-party HP, fair DPS/tank/healer credit, Tu Vi and unique gear, map/V5 integration and scaling | separate B3 design contracts, real authored content, owner visual signoff |

**No hidden promises:** PH0 solves a foundational correctness blocker; it does **not** yet produce a real user save or material reward. PH-V1 end-to-end accepted only after PH1–PH3.

### Migration requirements for PH2/PH3

- Old saves without B3 data retain old v2_pve_active_runs, v2_pve_settlement_receipts and v2_pve_reward_claims. A disciple reserved by old PvE must NOT simultaneously enter B3.
- New B3 snapshot is opt-in and must be versioned. Maintain SaveService v1/v2 readers, account for independent SimulationState.SAVE_VERSION=1 versus SaveService.CURRENT_VERSION=2; do not blindly bump both.
- Freeze kill_id=world/region/slot/generation, authored table_rev and reward RNG result; pending receipts retry without reroll. Production item goes to canonical SectState.warehouse_resources ONLY under actual approved table. Stack overflow fails closed. Stage warehouse delta, receipt state and world HP/slot deadline before SaveService barrier; no “paid but unrecorded”.
- 60 wall seconds = one scheduler minute; 240 ×0.25s possible world substeps per minute are a **candidate**, not a new clock owner. Preserve partial elapsed wall-time backlog and minute/substep order. World exists with all disciples down; no instant revive.
- No active job theft, Injury0/1/120, legacy WIN-claim unchanged. No renderer event buffers used to settle kills.
- Different versions of old finite and B2 snapshot readers must be tested together before V5 adoption. Do not replace project.godot; later union editor plugin arrays if approved.

## E. Approval to request next (copy-ready, NOT sent yet)

TÔNG MÔN BÁ ĐẠO — **TÔI CẤP PHÉP CODE B3-PH0 (KERNEL COMBAT LIÊN TỤC)**.

Trên repo vuanhtuan161094-byte/TongMonBaDao, main pinned HEAD 461caca1171462e0da092f21108c5c1733157ad9, đọc AGENTS.md, tài liệu docs/handoffs/2026-10-22/B3_PH0_FIRST_CODE_AUTHORIZATION_PACKET_PERSISTENT_HUNT_2026-10-22.md trên branch docs/b3-v2-architecture-redesign-20261022 và ZIP B2.4 SHA-256 29b2e6fa11932c94abac054b48cbd9440c63473079472dabcee0be2605fea422. Nếu main đã đổi SHA, dừng và báo owner trước CODE.

Tạo isolated worktree/branch feature/b3-ph0-continuous-kernel-20261022. Chỉ sửa godot/src/simulation/combat/map_battle_v2.gd, godot/src/simulation/combat/map_battle_snapshot_v2.gd và thêm godot/tests/simulation/b3_ph0_continuous_kernel_test.gd. Nhập có chọn lọc code opt-in continuous B2.4 từ source_snapshot, không copy whole ZIP hoặc file dirty. Chế độ legacy giữ nguyên; world continuous không kết thúc do 90s, hết quái hoặc toàn đội HP0; có spawn/remove theo instance generation, domain HP0 event không phụ thuộc UI ring, v1/v2 snapshot backward reader và replay RNG/cast. Không đổi Combat V2 damage, skill, rng, injury, payout/save.

Chạy official Godot4.7.2 focused PH0-T01..T10 và regressions battle snapshot, group map battle, five-level PvE, GP-02C1 trên TEMP user data/byte-identical test baseline. Không FULL/CI/merge/push, không sửa Source A, Map, V5, Studio, SaveService, State, Scheduler, Warehouse hay shared checkpoints. Nếu cần file ngoài allowlist, dừng với BLOCKED_NEEDS_OWNER_AUTHORIZATION. Giao code scoped, commit SHA/log/test matrix, rollback và đề xuất PH1. Owner visual và Android PENDING USER.

**WARNING:** This approval wording is a template awaiting the user's later explicit choice. The present user asked for design and packet preparation only; no gameplay work has been performed.
