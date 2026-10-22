# TÔNG MÔN BÁ ĐẠO — NEXT ONE-SHOT: RECOVERY, PILLS & AUTO HUNT

**2026-10-22 · CODE PACKET PREP / NOT CODE AUTHORIZATION.** Do not alter gameplay, Source A, PH0, Map/V5 or main while preparing this handoff. This is one subsequent Codex task with internal checkpoints, not separate owner-gated PH1A/PH1B jobs.

## 1. Accepted baseline, verified artifacts

- **Most recent working source:** LOCAL branch `feature/b3-fasttrack-first-hunt-20261022`, commit **`1d686dc8e202f4831fa51373c15e6666f44702f9`**, descends from accepted PH0 `97a3d98094451e85e8d5f26e8986a60968512ee5`, whose main ancestor is `461caca1171462e0da092f21108c5c1733157ad9`. **This B3 code is not on remote main.** Worktree on owner's PC `E:\codex\2026-10-22\t-ng-m-n-b-o\work\TongMonBaDao_B3_fasttrack`.
- **Physical deliverable uploaded to current chat:** `B3_FASTTRACK_HANDOFF.zip`, includes nested **full** `B3_PLAYABLE_PROJECT.zip`, Git bundle, diff, README, two saves, GUI screenshot, original logs and `FOCUSED_RESULTS.json`. SHA256SUMS manifest verified **104/104** embedded entries in this chat. The nested project ZIP allows source recovery even if the local Git worktree/bundle parent is missing.
- **Reported finished QA** 13/13 official Godot 4.7.2 focused tests PASS, B3 56 checks; 7320 simulation seconds/5 kills/5 genuine `tinh_lang_bi`, GUI 8528 simulation seconds/3 kills/3 mats, save/load, synthetic crash tests, single time owner, Injury120. Those simulation seconds are not real waiting/GUI seconds. Actual Windows physical interaction, Android, 1k-3k scaling remain PENDING USER.
- **Verifiable B3 APIs** in included project: `B3HuntWorld.begin/admission/advance_frame/settle_kills/commit/return_to_sect`, `LiveGameRuntimeV2.start/poll/save`; domain HP0 receipt committed to `WarehouseSystem`; `b3_playable_hunt.gd` currently has manual Ra săn / Trở về / Dưỡng sức / Lưu/Tải. Normal Thanh Lang respawns **8s sim**; B3 prototype default single world/slot/disciple.
- **Canonical existing medicine**: `hoi_xuan_dan`, recipe 3 `thanh_linh_thao`, 6 scheduler ticks, heals **55 HP** at sect via `NeedsSystem.use_healing_pill`. Current Injury pilot after HP0: HP=1, Injury=1, clears after 120 simulation minutes at sect. Simple healing HP does **not** bypass Injury. No automatic lifespan decrease on combat down.
- **Existing canonical natural Tu Vi** `DiscipleTuViFlowV2`: 1000 base Tu Vi/minute for eligible V2, once per tick even while hunting, fixed consumable rewards must use `DiscipleRealmProgressV2.grant_xp` as an explicit source. No direct extra XP for monster HP0 under older locked Tu Vi V2 spec.

## 2. NEXT PLAYABLE VERTICAL SLICE: AUTO RECOVERY + REAL PILLS + RETURN TO SAME HUNT WORLD

**One acceptance loop:** real disciple hunts → gets downed → returns to sect with HP1 & Injury1 → real recovery time ticks → consumed approved healing pill or existing REST action increases HP only → canonical Injury clears at tick+120 → autonomous policy **checks equipment/health/occupancy and redeploys same disciple into same surviving world** → monster killed again, real loot goes to same Sect Warehouse → save/restart preserves policy, pill/day counters, HP/Injury and receipts. Auto mode can be turned OFF. No invisible speedup of Injury; no automatic revival in combat; no fake medicine added to inventory.

### 2A. Auto-care/auto-hunt (primary value, existing content)
- New B3 AUTOPLAY policy scoped to opt-in saved world, with flags `auto_hunt`, `auto_heal`, minimal deployment HP ratio `>=0.75` (PILOT candidate), and next eligible review tick (using canonical scheduler time, not a second real-time timer).
- Eligible re-entry requires **Injury 0**, at sect, canonical HP threshold reached, no One Active Job, no finite PvE/reserved job/training, authentic V2 profile, and fully committed last B3 kill save barrier. Same `B3HuntWorld.admission` authority must validate, no second weaker gate. Missing medicine leaves REST fallback; if resources unavailable and HP too low, **do not loop at high frequency or override safety**.
- When HP0, the current terminal state returns HP1/Injury1; policy cannot instantly heal Injury. Existing Godot time semantics: 120 sim ticks = 120 real minutes at 1×. Acceleration in fixture/test must use same injected clock and no alternate reward multiplier. Manual return remains final override and should pause auto re-entry until explicitly resumed.
- Injury and HP must be visible in GUI with a source-truth countdown, medication count and AUTO state. One clear click toggle, no huge UI redesign; extend existing standalone B3 scene only.

### 2B. Pills / shared satiety and early Tu Vi consumable (owner balance APPROVAL REQUIRED)
**Already locked design:** daily `Đan Bão Hòa` is one shared pool per disciple and one day from `floor(state.tick/1440)`; each pill declares its satiety cost. Exact capacity/cost and pills are **not** locked; must not pretend they already exist.
- Proposed **explicit TEST BALANCE** to approve in a single code authorization:
  - `daily_satiety_capacity=100` per DiscipleState, shared across all B3/cultivation/breakthrough pill uses; bounded spent counter persisted and reset only upon canonical day change (not OS midnight or save/reload).
  - Hồi Xuân Đan existing +55 HP costs **10** satiety per pill while category policy enabled; routine `use_healing_pill` must use one atomic debit/effect/satiety transaction (legacy opt-in compatibility preserved). If medicine not available, no phantom heal.
  - New **Tụ Khí Đan** (`tu_khi_dan`) trial: 2 Thanh Linh Thảo + 1 Linh Cốc → 1 pill after **6 ticks** at existing Alchemy Hall, one fixed **+10,000 Tu Vi** for one V2 disciple, satiety **25**; no passive multiplier, no automatic cross-major breakthrough, no duplicate double counting.
  - If one consume would cross cap 100, fail before any Warehouse debit or XP/HP mutation. At 100 cap, only Tụ Khí max 4/day, Hồi Xuân only max 10/day, combinations share pool. Existing max3 breakthrough-item condition remains a separate per-attempt constraint.
- This table is **new pilot proposal**; owner must explicitly authorize these 100/10/25 + formula/XP amounts before Codex activates it. If not authorized, implement auto-care/auto-return using existing Hồi Xuân Đan/REST only; satiety/pill code stays deferred without claiming full pack complete.
- No `Tinh Nguyên` new item or Boss/direct-kill XP in this packet, no Thọ Đan/Ma-Hồn or unrelated Luyện Thể recipes, no pharmacy made-up asset. A full buildable `Y Quán` building stays separate; medical service at Sect is what this pilot actually implements, label it accordingly.

### 2C. Prescription/economy guard
- Use only canonical Warehouse `WarehouseSystem.add/consume`, `ResourceRegistry`, `BuildingSystem` alchemy job state and `AlchemyRecipeRegistry`. No alternative inventory/clock. Real crafting requires material debit and One Active Job.
- Allow selecting `hoi_xuan_dan` or `tu_khi_dan` from same Alchemy Hall timed-job mechanics; finished batch arrives via canonical Warehouse once. No crafting of free pills on every rest.
- Auto consumption must obey policy and minimum health requirements. Pill EXP on major gate cannot overflow secretly; no pill use if not eligible. Do not create new automatic pill use for every character by default without explicitly saved toggle.
- Save/restart mid crafting, mid injury, before/after pill consume and mid combat must be replay-proof. Idempotent per-command receipts or equivalent canonical one-transaction save semantics; ordinary repeated player click cannot consume a paid pill twice for the same request.

## 3. CODE allowlist to approve as ONE PACKET

**Base:** accepted local B3 `1d686dc8...`, new isolated local worktree `feature/b3-care-pills-autohunt-20261022`. **One writer**, internal commits A/B/C at Codex's discretion; full end-to-end QA once and focused checks after relevant milestones. Codex has authority only once the user sends an explicit approval of this entire packet.

**May modify existing**:
1. `godot/src/simulation/combat/b3_hunt_world.gd` (real re-entry and owner-validated policy).
2. `godot/src/presentation/b3_playable_hunt.gd` (real toggle and source UI, no renderer authority).
3. `godot/src/simulation/needs/needs_system.gd` (heal guard and canonical medicine consume; must preserve legacy path).
4. `godot/src/simulation/building/alchemy_recipe_registry.gd` (new named recipe in same registry).
5. `godot/src/simulation/building/building_system.gd` (recipe selection/timed job, only if necessary and regression protected).
6. `godot/src/simulation/resource/resource_registry.gd` (registered new pill).
7. `godot/src/simulation/state/disciple_state.gd` (satiety/auto state persisted, if chosen).
8. `godot/src/simulation/state/sect_state.gd` and `godot/src/simulation/state/simulation_state.gd` (B3 policy save + validation).
9. `godot/src/simulation/core/simulation_runtime_owner_v2.gd` (clock-owned B3 policy tick orchestration/save barrier), and `godot/src/simulation/core/live_game_runtime_v2.gd` only if entrypoint absolutely needs narrow exposure.
10. `godot/src/simulation/save/save_service.gd` **only if needed** for strict migration/receipt shape; keep old save compatibility.

**May add**:
- `godot/src/simulation/combat/b3_medical_autoplay_v1.gd` (single owner policy + idempotent actions).
- `godot/src/simulation/cultivation/b3_pill_satiety_v1.gd` (single shared limit/consumer).
- `godot/tests/simulation/b3_care_pills_autohunt_test.gd` and `godot/tests/simulation/b3_pill_satiety_test.gd` (new focused tests).
- If a new B3-only debug configuration file is essential, STOP and ask scope update; don't touch project.godot.

**READ/reuse only:** `map_battle_v2.gd` and snapshot PH0, `hunting_pve_run_v2.gd`, `disciple_combat_loadout_v2.gd`, `disciple_tuvi_flow_v2.gd`, `disciple_realm_progress_v2.gd`, `warehouse_system.gd`, `simulation_runtime_clock_v2.gd`, `simulation_scheduler.gd`, old 13 focused tests. If modifying any read-only file is truly required, report BLOCKED for exact permission, do not silently expand scope.

**Never touch:** Source A worker/tool/data, Character Studio, Map G1/MAP25, V5, project.godot, main, old finite PvE reward, unique/Boss loot, old Injury 120 default or lifespan authority. No CI/FULL/push/merge.

## 4. Minimum acceptance: same underlying backend, real gameplay

- New real V2 disciple uses pill only when eligible, stock >0, Injury guard honored, mixed shared satiety never exceeds cap; day rollover and save/reload deterministic.
- Exact normal healed amount +55; Tu Vi pill +10k fixed with explicit source and no generic per-kill Tu Vi. 2 recipes craft from real Warehouse, save mid-job and correctly finish exactly once.
- Downed member becomes HP1, Injury1; 119 tick no entry, tick120 eligible when HP threshold and same-world reentry; auto disabled means no automatic reentry; manual return pauses auto.
- No medicine means REST or HOLD rather than retry spam; at most one successful medicine debit / command; per-character policies serialized and prevented from falsely running while at work.
- After auto-reentry, at least 2 new real kills produce +2 `tinh_lang_bi` once each (separate receipts), world_id and spawn slot persist through restart.
- 0 extra seconds source, no double Tu Vi minute, no time rewinding/retroactive deployment, no corrupt/downgraded save accepting inconsistent satiety/receipts.
- Official Godot4.7.2 focused + previous 13 regression suite; existing Economy-A, GP-02B1/02C1, P3.7 Warehouse and save tests unchanged. One clean portable ZIP including **full Godot project**, CODE bundle, diff, README_vi, logs, SHA256SUMS, GUI screenshot; physical/Android PENDING USER.
- No success label unless exact code SHA and logs correlate. Do not claim that running faster-than-realtime demo is equivalent to real minutes waiting.

## 5. One single copy-ready future authorization (NOT YET SENT)

TÔNG MÔN BÁ ĐẠO — TÔI CẤP PHÉP CODE B3 CARE-FASTTRACK trên nền commit B3 PASS `1d686dc8e202f4831fa51373c15e6666f44702f9`. Đọc `AGENTS.md` và packet `docs/handoffs/2026-10-22/B3_NEXT_ONE_SHOT_RECOVERY_PILLS_AUTOHUNT_2026-10-22.md` trên `docs/b3-v2-architecture-redesign-20261022`. Tôi cũng phê duyệt các giá trị PILOT: bão hòa 100 điểm/ngày, Hồi Xuân Đan 10 điểm/viên, Tụ Khí Đan 25 điểm/viên +10.000 Tu Vi, công thức 2 Thanh Linh Thảo + 1 Linh Cốc, 6 tick. Triển khai liền một vòng chơi: săn → bị hạ → Injury120 → tự dùng thuốc/nghỉ → đủ điều kiện tự tái nhập cùng world → săn và loot tiếp; thêm crafting và tiêu thụ Tụ Khí Đan với giới hạn chung/ngày. Một writer, một nhánh/worktree riêng, chỉ allowlist của packet, checkpoints nội bộ, tự sửa lỗi + focused tests trên Godot official4.7.2, không FULL/CI/push/merge, không chạm Source A/Map/V5/PH0. Bàn giao một ZIP chứa full project + patch/bundle/log/save/ảnh và checklist QA. Nếu cần sửa ngoài allowlist, dừng báo blocker, không tự mở rộng.

**Gate:** Request above is PREPARED, not implied approval by the current user's “continue” message. Do not implement code until the user explicitly sends it or equivalent.
