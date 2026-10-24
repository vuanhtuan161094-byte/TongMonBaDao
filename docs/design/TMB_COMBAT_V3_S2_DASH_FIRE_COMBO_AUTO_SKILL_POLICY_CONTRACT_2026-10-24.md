# TÔNG MÔN BÁ ĐẠO — COMBAT V3-S2
## Truy Phong Bộ · Liệt Diễm · phối hợp Hỏa Cầu · AI chọn kỹ năng — Design Contract V0.1

**Ngày:** 2026-10-24 · **Trạng thái: PROPOSED / DESIGN ONLY** · **KHÔNG CODE / KHÔNG CHẠM PR**.  
**Chủ sở hữu gameplay:** Combat V2 (`MapBattleV2`) và CARE; UI ở chat/workstream khác.  
**Nguồn kiểm tra:** `main` `29b5fba448b0178cb520a4ada44b375b4b934e31`; PR #27 `deeae081bcfbe1413d4cf60a29db7e58150888b5`; PR #29 Combat V3-S1 `9522812e91b7ca5bc0cc108eb92e000e930fe850` (DRAFT, **QA PENDING**), không coi những thay đổi S1 đã PASS.

### 0. Quyết định chủ đạo
Hoàn thiện **hệ chiến đấu thời gian thực của đệ tử thực** theo chiều dọc: skill phải có điều kiện học → được đưa vào loadout → AI quyết định hợp lệ → vào tầm → thi triển → sát thương/hiệu ứng đúng → kết toán theo CombatStatsV2 → lưu/tải an toàn → thưởng loot đúng một lần. Không làm lại renderer, không tạo Combat V3 engine riêng, không cân bằng HP×100/Boss trong S2, không thêm universal mana, không tạo skill/monster/loot giả.

## 1. SOURCE AUDIT — sự thật có sẵn

- `CombatSkillSystem.SKILLS`: **Truy Phong Bộ** `effect=dash`, Kiếm/wood, `min_stage=4`, `range=7.0`, `cast_time=.25s`, `cooldown=5.0s`, `damage_ratio=.75`, `dash_to=1.35`; **Liệt Diễm** `effect=fire_combo`, Pháp/fire, `min_stage=9`, `range=6.0`, `cast_time=1.00s`, `cooldown=7.0s`, `damage_ratio=1.45`, `projectile_speed=8.5`, `burning_bonus=1.35`. **Hỏa Cầu** `effect=burn`, `ratio=1.15`, `range=7.5`, `cast=.65s`, `CD=3.8s`, `projectile_speed=8.0`, `burn_ratio=.16`, `burn_duration=3.2s`.
- `CombatSystem.gd` (P2 legacy real-time 1v1) ALREADY has `_select_skill`, `_skill_utility`, `_finish_cast`, `_apply_skill_effect`: dash closes scalar distance to `dash_to`, fire_combo boosts by 1.35 **only when burn is active at damage application**, and evaluates guard/burn/weaken/dash usefulness with a utility score. **This is a useful REFERENCE, NOT the authoritative multi-actor PvE implementation**.
- `MapBattleV2.gd`: source multi-actor real-time owner, `STEP_SECONDS=.25`, nearest-live-enemy target, linear movement toward base attack range, ordinary attack/cast/CD, generic healer/guard/mage AoE/Elite & Boss telegraph, `MAX_TARGETS_AOE=3`. Current `_try_learned_skill` in S1 attempts only `damage/burn/weaken/guard` and iterates sorted `skill_loadout` rather than utility-ranked context. It includes status `burn/weaken` fields and learned self-guard in actor snapshot; **official S1 QA pending**.
- `DiscipleCombatLoadoutV2.build`: real P2 learned skill + actual equipment + technique affinity; `truy_phong_bo` and `liet_diem` remain in `deferred_skill_ids`. No explicit 4-active-slot preference UI or full rotation policy in current bridge.
- `MapBattleSnapshotV2`: single authoritative snapshotted actor/casts/RNG/continuous kill generation; CARE owns actual durable loot, Injury0/1/120, save and exactly-once. Legacy `CombatSystem` and `MapBattleV2` MUST NOT both settle the same hunt.
- `B3HuntWorld` in main screen currently a **single disciple + one recurring Thanh Lang**; group fights are proven in MapBattle fixtures but not live multi-team CARE Boss. No new Boss mapping in S2.

## 2. Truy Phong Bộ — DESIGN PROPOSAL (keep authored 0.75/7.0/.25/5/1.35)

### 2.1 Intended player-visible action
A Sword-path disciple out of melee range, possessing genuinely learned Truy Phong Bộ and a reachable enemy, makes a 0.25s sword-step/dash toward that enemy, stopping about 1.35 arena coordinate units away; then commits **one** `0.75 × ATK` direct-damage packet subject to canonical DEF, crit, resist and other real buffs. Does **not** auto-hit several targets, does not become AoE, does not teleport through collision.

### 2.2 Target and geometry
- Legal at cast START: alive caster, learned and stage≥4, not Injury/downed, skill ready, target alive, in **7.0** straight-line cast range, path/landing valid in current arena, not already in convenient melee range. Default AI use primarily for gap closing (e.g. current target distance > own basic range plus a small position tolerance), never blindly dash inside melee.
- Landing goal: `target_position - normalized(target_position - caster_position) * 1.35`, clipped to ARENA and to the last reachable safe point along authorized collision/path constraints; no damage if target cannot be reached/within contact hit distance at **release**. Existing `MapBattleV2` arena has direct coordinate geometry; obstacle-aware map movement must NOT be falsely claimed live. If geometry cannot validate safe path in the initial test arena, fail closed instead of allowing wall bypass in future maps.
- Decision about moving target (proposed): target actor ID locked during cast, position sampled at release for final landing, with capped displacement/path safety; no instant retarget. If target dies, despawns or changes generation before settlement, cancel hit and clear queued cast; cooldown stays spent once casting has started. No phantom loot/second movement action.
- Dash occupancy: one cast/action at a time; after release, no bonus basic hit unless the existing scheduler contract deliberately allows same-tick release+basic. Save mid-dash preserves source, target, pending move/release, CD, original skill ID and RNG.
- Source IDs and serialized state mandatory for diagnostic attribution. Presentation gets only honest `dash_start/dash_resolve/dash_blocked` events from Combat V2; Source A animations are a separate UI/asset integration phase.

### 2.3 Simple test illustration (not a runtime result)
Sword move speed source `3.10 arena units/sec`. Closing from distance `6.0→1.35` by running takes about `4.65/3.10≈1.50s` before collision/time-grid; legal dash takes authored cast `.25s` (+ scheduling). It is valuable even with a **75%** direct hit because it saves approach time. This does NOT constitute a universal damage increase or a guarantee of exact 0.25s movement rendering.

## 3. Liệt Diễm × Hỏa Cầu — DESIGN PROPOSAL

### 3.1 Damage and combo semantics (source preserving)
- **Liệt Diễm remains SINGLE TARGET** by default; direct base packet = `1.45 × effective ATK × skill source factors` before DEF/crit/elements. Its projectile uses original `8.5` arena units/s, target must exist with same generation at impact.
- When, and only when, target has a **genuine unexpired BURN status at hit settlement time**, multiply this skill packet's **damage_ratio** by `burning_bonus=1.35`; `1.45×1.35 = 1.9575 × ATK` before DEF/crit. Don't recalculate an extra 1.35 final-damage buff after `resolve_direct_hit`, and don't multiply the generic per-element affinity twice.
- Proposal **DO NOT CONSUME BURN on Liệt Diễm impact**. This preserves legacy `CombatSystem` behavior and avoids conflict with other delayed burn ticks/party members. Burn continues until authored expiry; repeated combo casts still obey cooldown7.0 and status validity. If user later wants a consumption/explosion mechanic, separately version it as an upgrade, not a silent change to existing skill.
- **No AoE/explosion automatically added**. Future mastery may author an explicit circle/chained `max_targets` and falloff, but it is outside S2. The global AoE cap3 belongs to current generic AoE, not automatically to Liệt Diễm.
- No burn? Liệt Diễm still deals `1.45 × ATK` if legitimately cast/hit. It must NOT fake burning to achieve 1.9575, and AI may choose a more useful alternative. No status application from Liệt Diễm unless later authored.

### 3.2 Timing: check burn at IMPACT, not selection/cast
- At selection, AI predicts `cast_time/(1+cast_speed) + range_distance/projectile_speed`, plus one `.25s` combat-step safety margin. If existing burn is not expected to survive until release, combo bonus is not forecast; choose Hỏa Cầu to establish burn or use Liệt Diễm for reasonable raw damage/finisher.
- **Worked example:** distance6.0, no cast-speed bonus, Liệt Diễm requires `1.0+6/8.5≈1.71s` plus 0.25s safety margin to predict bonus. Burn must remain longer than about **1.96s** for reliable automatic combo. Exact action grid and movement must be checked in Godot; these are source-derived paper units.
- Ownership/attribution: status target ID + source actor/skill ID + target generation; bonus verification at canonical impact event; two disciples can cooperate (one applies burn, another uses Liệt Diễm) as long as burn status really belongs to that enemy, not a client-only badge.
- Tick DoT is not a second projectile or separate loot engine. Existing S1 burn pilot is `0.16 × ATK` per eligible 1-second tick for up to3.2s; exact tick count, protection, caster defeat behavior and update semantics must follow S1 official accepted contract after QA. This doc does not authorize editing S1.

### 3.3 Exploits to prevent
- Burn expired at cast start vs expired at hit; targets die before projectile landing; respawn with same reusable slot but new generation; projectile arrives after save/load; two burns of different strength; status applied by another caster later dying; cooldown used at cast start vs resolved hit.
- One single source-owned resolution per cast ID. No duplicate `skill_hit`, no second DoT tick after saved-load, no extra loot receipt from delayed hit. Preserve seeded replay and old snapshot compatibility.
- The current S1 pilot removes burn when its caster dies, and repeated guards may be preempted by generic role guard; S1 QA needs findings before S2 decides whether to version that behavior. No unapproved silent fixes.

## 4. Automatic skill AI — S2 practical plan, NOT heavyweight RL

**Goal:** smart-enough transparent utility + a small finite-state action controller, with exact deterministic tie-breaking; no per-frame machine learning and no second hunt authority.

### 4.1 Priority pipeline per actor action opportunity
1. **HARD GATES** — alive/valid, legal learn-stage, active equipment/path where applicable, ready cooldown, cast not pending, target eligible and alive, allowed aim range, safe cast endpoint, no conflicting One Active Job, true encounter; ignore `deferred_skill_ids` until officially implemented. Apply existing HP/retreat/injury gates at the owning layer, not inside UI.
2. **SURVIVAL** — if imminent enemy AoE/low HP and there is a genuine allowed escape/guard/heal action, evaluate it *ahead* of ordinary DPS. Existing generic healer threshold <65% ally, generic frontline guard <75% own HP are SOURCE pilot gates; an S2 skill may not change them without owner approval. Avoid consuming cooldown on an already active stronger guard.
3. **STATUS & COMBO** — prioritize Hỏa Cầu when useful target not burning and projected fight duration supports DoT; choose Liệt Diễm with confirmed/predicted alive burning at impact; weaken when dangerous target has no stronger valid debuff; do not refresh the same-status family merely for cosmetic animation.
4. **REPOSITION** — Truy Phong Bộ when target outside melee, dash creates a valid meaningful gap-closure and beats walking/opportunity cost; never dash against blocked path or a target about to die.
5. **DAMAGE / BASIC** — select legal high-value damage skill against basic attack opportunity; when none useful, move to range and basic-attack normally. Don't cast any available skill solely because its cooldown completed.

### 4.2 Scoring / cost model (design only; no arbitrary stat nerf)
For eligible actions, an optional stable score may combine:
`expected_direct_damage + expected_DoT_useful_damage + team_damage_prevented_by_guard_or_weaken + seconds_of_repositioning_saved * available_basic_DPS - displaced_basic_damage - cast-risk_cost - overkill_waste`. Normalize scores to one canonical damage-equivalent unit and use the current derived stats/target DEF rather than `combat_power`. Use 2-stage categories if analytic score too expensive or uncertain; **do not implement a magic factor 48** copied from legacy AI.
- AI only scores at **an eligible combat action opportunity** when not casting. Don't continuously re-evaluate all 9 skills per target every rendered frame. Cache target until dead, out of allowed range, unreachable or sufficiently invalid; deterministic tie break `skill_id`, then stable `target_id`.
- Role templates **Sword gap-close/burst**, **Body threaten/guard/weaken**, **Spell burn/combo/control**, **Healer save critical ally**. A real disciple's learned skill list/path and loadout determines available actions; don't grant unknown skills based on role. Legacy P2 survival_bias/risk_bias can inform policy only if proven appropriate for V2 source.
- The `MapBattleV2` source currently sorts learned IDs, often creating unintended priority. S2 changes only legal skill choice, not canonical damage/loot. Preserve AI intent/skill cooldown in actor snapshot.
- No overly intelligent dodging or Boss phase AI in S2; those need explicit enemy telegraphs, navigation and target threat content in later packets. Policy owner may control AUTO enable/disable / retreat, but no extra parallel scheduler.

### 4.3 Three worked cases
- **Sword** 6.0u from Thanh Lang, Truy Phong Bộ learned/ready: dash toward1.35u and hit if legal, then basic or Thanh Phong once action ready. At 1.5u from target, don't dash; use actual melee action.
- **Spell** target burn remaining2.4s, distance6.0u, Liệt Diễm cast1s+travel.71s+.25s margin≈1.96s: prefer combo. If burn remaining0.5s, don't predict combo; prefer renew Hỏa Cầu if available; Liệt Diễm may still be used as plain single-target damage.
- **Frontline** own HP55%, strong Kim Cương learned-guard already active, generic role guard available: don't waste another weaker guard while stronger is valid; cast/attack only when truly legal. If healer sees same-party ally at HP60% within6u, it may heal per source generic healer policy.

## 5. S2 slice sequencing — avoid endless whole-project audits

| Slice | Implementation candidate only AFTER owner CODE authorization and S1 QA | Visible result | Minimal evidence |
|---|---|---|---|
| S2A | Dash: legal cast/path/landing, one hit, move event, rollback, snapshot | Sword disciple closes gap and lands one hit | 1 legal target, target gone/blocked, save mid-dash, no ghost loot |
| S2B | Fire combo: source burn tag + direct damage bonus at impact; status survives correctly; no extra AoE | Spell disciple lands Hỏa Cầu→Liệt Diễm sequence | burn survives/expires before impact, third-party burn, projectile save/load, seeded repeat |
| S2C | Skill decision policy: legal filter, support precedence, combo timing, meaningful dash, fallback attack | 3 playstyles use different action sequences | >=6 small official Godot focused fixtures, 1 main-screen CARE smoke, true source loadout & no fixture-forced hidden skills |

**S2 exit gate:** all 9 pre-existing P2 skill definitions have live consumers in canonical V2 where genuinely learned/unlocked (subject to S1 QA), but this **does not** mean the game has all professions, complete technique/slot configuration, Boss live event, universal AoE or full stat balance. UI may visualize only actual authoritative cast/move/hit/status events.

**S2 safety tests:** parse+focused for changed effects + save/resume midcast and after status update + no double damage or receipt + no fake skill learned + semantic S1 regression (guard/burn/weaken) + no UI/source/map changes. Avoid rerunning all 1,240 diagnostic battles for every design tweak. After S2 end-to-end, run a medium 20–40 seed representative matrix and record actual skill usage, TTK, downed, path/target switches. Widen Monte Carlo for S3/S4 content rather than chasing final balance at S2.

## 6. Future CODE scope — only a planning estimate, NOT authorization

**Likely new writer file allowlist (review later):** `godot/src/simulation/combat/map_battle_v2.gd`, `disciple_combat_loadout_v2.gd`, maybe `combat_skill_system.gd` only for typed contract; `map_battle_snapshot_v2.gd` if new serialized fields; new `godot/tests/simulation/combat_v3_s2_*.gd` and `docs/handoffs/`. `CombatSystem.gd` legacy is **REFERENCE ONLY**. Do not touch PR #29/Codex worktree, any `godot/src/presentation/`, Source A, PR27 D7, SaveService, Economy, CARE reward, or map renderer.
- Need exact base SHA **after** Codex S1 QA fix branch is known and user grants a fresh code packet. If S1 QA fails, fix S1 first and update this docs contract; do not stack knowingly broken code.
- `main` remains unrelated to stacked draft PR #24→#25→#26→#27→#29. Do not blindly rebase/merge these into main.

## 7. User-friendly decisions (not yet locked)

1. **A — Recommended lean S2:** Truy Phong Bộ as safe single-target gap-close; Liệt Diễm 1.35× when target still burning at impact, **doesn't consume burn**; lightweight deterministic 5-stage AI (safety→survival→combo→reposition→damage). Unlock according to source, no new player-configured 4-slot system yet.
2. **B — Deep S2:** same combat semantics but also build an independent manual active skill priority/loadout UI and advanced role target policy. This adds UI/Save overlap with another writer and should be planned as separate follow-on, not bundled into current S2 while UI PR writer active.
3. **C — Alternative combo rules:** consume burn to create stronger single-use burst / optional AoE. Would diverge from current authored P2/legacy and requires explicit owner numbers, V2 effect contract and damage/loot tests before code. Avoid silently conflating this with `burning_bonus=1.35`.

### Acceptance philosophy
One small **technical safety** test suite per slice, one useful **playable behavior** demonstrator at completion, and a broader **balance check** only once content loop exists. No infinite repetitive review, no hypothetical final Boss HP before map/skills/gear exist.
