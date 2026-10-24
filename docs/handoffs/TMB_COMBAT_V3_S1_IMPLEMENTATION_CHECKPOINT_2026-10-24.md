# TMB — COMBAT V3-S1 Implementation checkpoint / QA pending

Date: 2026-10-24 (Asia/Bangkok)
Base: PR #27 draft `deeae081bcfbe1413d4cf60a29db7e58150888b5`
Working branch: `feature/combat-v3-s1-runtime-effects-20261024` (stacked on PR #27, not main)
Authority: Combat V2/MapBattleV2, CARE save/reward/injury; original Source A and UI isolated.

## Implemented in code (NOT YET OFFICIALLY TESTED)
- `godot/src/simulation/combat/map_battle_v2.gd`: real learned skill cast support for damage, burn, weaken, self-guard; burn periodic damage using existing CombatStatsV2 hit pipeline; weaken reduces affected actor's outgoing damage; guard retains authored stronger mitigation (select strongest of role generic vs learned); no unlimited effects stack; actor-owned state and event receipts.
- Learnable `hoa_cau`, `han_suong_an`, `chan_son_quyen`, `kim_cuong_ho_the`, `bat_dong_than` now eligible in combat together with existing `thanh_phong_tram` and `ngu_kiem_thuat`.
- `cast_speed` and `cooldown_recovery` feed learned cast/recast deadlines; attack speed carries fractional attack deadlines across 0.25s steps, preserving at most one ordinary action each simulation step.
- `godot/src/simulation/combat/disciple_combat_loadout_v2.gd`: admit those learned effect classes while `truy_phong_bo` dash and `liet_diem` fire_combo stay deferred.
- `godot/src/simulation/combat/map_battle_snapshot_v2.gd`: validate authored status payload, timer and guard before restore. Existing snapshot envelope/version remains unchanged; states serialize through the existing actors. Older actor records lacking effects default to none.
- `godot/tests/simulation/combat_v3_s1_effects_test.gd`: new focused test fixture for basic speed, cast/cooldown, burn, weaken, guard, save/replay.
- One snapshot/clock, no extra world, second AI authority, pills, rewards or UI renderer change.

## Scope/behavior warnings
- This is **S1 technical slice**, NOT all 9 complete learned effects: Truy Phong Bộ/dash and Liệt Diễm/fire_combo remain deferred. No new Boss implementation, AI tactics, healing learned spells or equipment tuning.
- **Important semantic choice for pilot only:** burn ticks every 1 combat second, one burn status per target; weaken is one strongest status per target; guard triggers at HP below75%, uses strongest (smallest) mitigation factor rather than multiplicative double-guard. These are tunable choices, not final owner balance locks.
- Burn currently ends early if its caster leaves/dies. Projectile visual/obstacle collision not introduced. Cast distance checked at start, not at release. No new global mana.
- Speed change necessarily affects old seeded fight action traces; backward snapshot decode may succeed yet post-upgrade continuation differs from older game logic. Need a deliberate compatibility QA gate and potential ability to version old encounter simulation rules if persisted active fights cross the upgrade.

## Verification / gate status
- **CODE COMMITTED:** yes, isolated branch.
- **Static read/diff:** review required via GitHub branch compare; no second writer.
- **Official Godot 4.7.2 (focused): PENDING**, not executed in this environment: no engine binary installed, internet fetch blocked. A Godot test file has been authored, not passed.
- **Focused regression (old snapshots, CARE, P2.5, battle group, Injury, loot, save): PENDING**.
- **Windows/Android GUI, Owner visual, FULL/CI:** NOT RUN. Do NOT label ready to merge.
- The previously reported PR27 `20/20 PASS` and `139 D7 checks PASS` belong to old SHA `80ed0270` and DO NOT certify this S1 branch.

## Required exact next Codex gate
1. Read `AGENTS.md`, current code SHA and this file; checkout S1 branch separately, no change to PR27 or UI worktree.
2. Run official Godot 4.7.2 focused `godot --headless --path godot --script res://tests/simulation/combat_v3_s1_effects_test.gd` after an import pass as needed, isolated userdata; capture stdout/stderr/exit/PASS markers.
3. Run adjacent `dv2_02_group_map_battle_test.gd`, `dv2_02_battle_snapshot_test.gd`, `p2_5_combat_skill_test.gd`, `b3_ph0_continuous_kernel_test.gd`, `b3_care_pills_autohunt_test.gd` and CARE focused using project's documented runner, with fresh user data and exact SHA.
4. Specifically test old v1/v2/v3 battle snapshots restored midcast, existing PR27 D7 profiles, one burnt monster genuine canonical loot exactly once, poison/status replay, attack-speed0/+50/+100, 1 skill with guard under HP75%, no infinite guard or repeated tick.
5. If any parse/behavior test fails, patch **only** S1 combat files/tests on isolated branch, document impact to persisted encounters. Maintain no merge and no false pass.
6. Deliver exact SHA, per-test exit results, Godot log and official S1 QA report; coordinate with UI chat before editing shared presentation.

## Next owner choice
A: focused Godot QA + repair (recommended before S2)
B: complete S2 dash/fire_combo and target/AI policies after S1 QA
C: first normal→elite loot slice after S1/S2 usable
