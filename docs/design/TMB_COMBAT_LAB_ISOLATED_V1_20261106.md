# TMB COMBAT LAB V1 — Isolated Skill / Damage / VFX / AI
**Date:** 2026-11-06
**Project:** Tông Môn Bá Đạo · Godot 4.7.2 official · landscape 1280×720
**Target:** PR #72, branch `integration/pve-p0-playable-ui-20261103`.
**Disposition:** APPROVED DIRECTION / IMPLEMENTATION NOT YET ACCEPTED. This document is an implementation contract, not test evidence.

## 0. Owner decision
Build and test disciples' skill progression, combat damage, combat AI, visual effects, animation and readable combat HUD **independently from the unfinished production/economy/alchemy/building systems**. Deliver an operable standalone **TMB Combat Lab** inside the same Godot repository, then attach it to the canonical PvE through a narrow adapter. Do not create a parallel game, second combat damage calculator, new gameplay RC/branch, save migration, or unrelated work.

## 1. Current source-of-truth check (PR #72 @ bf6cba1, 2026-11-06)
- `godot/src/simulation/combat/map_battle_v2.gd`: real 0.25s-step battle, HP, positions, AI, events, direct damage and kill receipts. `_deal_direct()` calls `CombatStatsV2.resolve_direct_hit()` and `settle_damage_and_lifesteal()`. This is **the** damage authority; preserve it.
- `godot/src/simulation/combat/v63_human_skill_combat_system.gd`, `v63_immortal_skill_combat_system.gd`, `v63_divine_skill_combat_system.gd`: skill cast/release/status mechanics already exist; extend/fix them rather than fork.
- `godot/src/simulation/combat/v63_feature_gates.gd`: runtime defaults OFF. `godot/src/simulation/combat/v63_content_registry.gd`: read-only catalog. Skill access/manual sources are not live-authored. Sandbox overrides must **never** enable flags for release/player saves.
- `godot/src/presentation/p3/v63_original_combat_vfx_v1.gd`: currently draws a small geometric event cue; not a complete per-skill VFX pipeline.
- `godot/src/presentation/p3/v63_combat_hud_v1.gd`: displays a basic lab-like panel, not final battle UX.
- 2026-11-05 evidence: all 183 Cung IDs covered in an isolated simulation; Quyền/Độc NOT exhaustive; full normal gameplay progression cannot yet acquire manuals.
- C2 animation master import: STATIC ONLY / NOT INTEGRATED / NOT VISUAL ACCEPTED, documented in `docs/animation/TMB_C2_NATIVE_PR72_IMPORT_GATE_20261105.md`. Do not silently import failing pilots.

## 2. Isolation boundaries
Create an **unreferenced** standalone scene at `res://labs/combat_lab/combat_lab.tscn` and its scripts/assets under `res://labs/combat_lab/`. Add tests under `godot/tests/labs/combat_lab/`. Run scene explicitly in Godot; do not set it as the release main scene, autoload, or attach it to production PvE until the integration gate is approved.

The Lab may instantiate `MapBattleV2`, `CombatStatsV2` and V6.3 classes. The Lab MUST NOT write to `SimulationState`/canonical `SectState`, live warehouse, `SaveService`, `user://` player profile, loot ledger, construction, economy, pharmacy, real recruit roster, or shared runtime feature switches. Any test fixtures must exist only inside this Lab/test profile and be visibly labeled `LAB_ONLY`.

Sole damage settlement authority: existing `MapBattleV2._deal_direct` -> `CombatStatsV2`. VFX, combat text and animation only **read** authoritative events; they never call damage, heal, loot, XP, injury or rewards setters. A single event must never inflict damage twice.

## 3. Ports to make future integration narrow
1. **CombatRosterPort** — accepts deterministic descriptors `{actor_id, side, school, path, realm, stage, current_hp, stats, position, loadout, statuses}`. The Lab uses fixture rosters; later the live port maps owned `DiscipleState` and monsters to existing authorized setup methods. Distinguish core paths Kiếm/Thể/Pháp from skill families Cung/Quyền/Độc.
2. **SkillAccessPort** — read-only `learned / unlocked / equipped` statuses. In the Lab only, allow explicit `LAB_ONLY` unlock fixture. In the live game, only canonical school/manual entitlement authorizes learning; empty drop profiles remain blocked until a real approved source exists. Never seed manuals into player saves.
3. **CombatEventBridge** — normalize `MapBattleV2.events` to read-only presentation records: `{event_id, encounter_id, tick_or_time, event_type, actor_id, target_id, skill_id, amount, is_crit, element, status, position}` with optional fields omitted rather than forged. Supported source events include `skill_cast`, `v63_skill_hit`, `hit`, `status_applied`, `status_tick`, `telegraph`, `downed` and available heal/evade/boss events. Use reliable cursor/idempotency over repeated polls; explicitly test `MAX_EVENTS` truncation/ring-buffer behavior. If raw events lack stable IDs, **do not invent an authority sequence**: implement a local read cursor with documented limitations, and propose a minimal authority event-id patch separately for approval.
4. **CombatPresentationPort** — reads normalized events plus positions and animation metadata, produces sprite actions, projectiles, hit flashes, hit stop, camera shake, particles, indicators, floating text and audio. Completely presentation-only and replaceable without changing numeric outcomes.
5. **PvEAttachPort (later only)** — replaces Lab fixtures with the existing real combat instance; no new battle scheduler, duplicate combat clocks, new reward claims or save schema. Verify cold Save/Reload and repeated event consumption.

## 4. Standalone scene: minimum usable controls
1280×720 dark-fantasy Xianxia chibi visual test arena. Expose a 1–6 disciple party, opponents (single normal, elite, Boss), choice of Cung/Quyền/Độc and Human/Immortal/Divine skills, loadouts (1 basic + 4 active + 1 ultimate + 1 mobility + 5 passive, according to existing contract), start/pause/step/reset, AUTO/HOLD, per-actor HP and state, cast/cooldown/energy, damage meter, compact event log with source id, criticals, DoT/Heal/Block/Guard/Miss/Death and telegraph. No production material requirements.

Provide deterministic scenario presets (fixed seed) for:
- solo Cung / Quyền / Độc against ordinary enemy;
- six-disciple team versus ordinary/elite and a Boss phase encounter;
- cast interruption/range miss, movement skill, crit, shield/guard, lifesteal and reflection when backed by actual engine events;
- DoT stack/refresh/ICD/GCD, expiry, crowd/status, HP0 and reset;
- snapshot replay with identical event/output sequences, no double settlement.
Do not display unsupported effects as if implemented. For missing real semantics, record `MISSING` and add a focused code/test task rather than invent a result.

## 5. Visual quality contract
All art used in production must be original/authorized and verified; no scraped copyrighted game assets. Clear Idle/Walk/Attack/Cast/Hit/Death silhouettes; separated weapon attachment, actor foot anchor stable, no gaps at joints, correct facing and positioning; do not fabricate animation frames by reusing a single static pose. Lab may use **explicit labeled placeholders** until accepted original master sprites exist, but cannot claim final-art PASS.
- Dedicated cast origin and hit position for projectile/beam/AoE and status VFX, matching canonical actor positions.
- Colored damage numbers read from `hit.damage`, `hit.critical`, `hit.lifesteal`; DoT numbers from `status_tick`; never duplicate when `v63_skill_hit` describes the same committed damage.
- Distinct semantic visuals per **mechanic / school / generation** (damage, poison, guard, heal, cleanse, mark, dash, counter, boss telegraph); common reusable particle primitives allowed, not 549 handcrafted effects.
- 1x/2x/4x/6x visual scale review without downsampling master art, mobile readability, batching/pooling and lifetime cleanup. FPS/VRAM claims require measured evidence.
- Presentation must not create damage, XP, loot or alter simulation state.

## 6. Implementation order, small observable gates
**CL-00 Contract and harness:** exact-source audit, Lab directory/scene, deterministic fixture factory, isolated profile and test entry. Deliver interactive scene, baseline screenshot and import/parse test. No production source touched.
**CL-01 Skill/Damage semantics:** connect existing authority, 6-character sample battles, single-source damage, logged raw/normalized events; run comprehensive per-ID semantic oracles for Cung, Quyền and Độc, including Human/Immortal/Divine, real ranges/cooldowns/status/boss. Report actual totals from catalog rather than guessing.
**CL-02 UX/VFX:** make presentation bus consume committed events, build damage numbers, school/generation cue styles, reusable effects, readable HUD. Test no duplicate damage text, no reward authority.
**CL-03 Animation/asset gate:** connect approved original sprite/rig/atlas where available, independently authored approved placeholders otherwise; verify Idle/Walk/Attack/Cast/Hit/Death, separate weapon, 1–6x, no green matte or seam. Do not import C2 pilots while blocked.
**CL-04 Integration-ready handoff:** freeze explicit `CombatRosterPort`/`SkillAccessPort`/`CombatEventBridge` contracts, demo video/screenshot, test matrix, integration diff proposal, rollback, final Godot smoke. **Do not actually connect into release PvE yet.**

## 7. Mandatory acceptance cases and test evidence
A. Starting Combat Lab directly works in official Godot 4.7.2 in GUI at 1280×720; open/restart deterministic; scene not reachable from normal New Game or release main scene.
B. `MapBattleV2` remains numeric authority, 1 attack -> at most 1 settlement, event-only renderer cannot change final HP, XP, loot, inventory, money or save.
C. For each declared skill ID across all families and generations, report `PASS / FAIL / NOT_TESTED` with actual damage/effect, target/range, cast/cooldown, statuses (including ICD and DoT ticks), boss/elite/pvp if supported, AI, and snapshot restore. Do not confuse catalog-valid with combat-tested.
D. Six disciples can cast in the same battle without overlapping actor anchors, lost events, double damage or animation timing errors.
E. Idempotent consumption: render same event stream twice -> no duplicated float numbers/VFX; rewind/reset and `MAX_EVENTS` handling covered.
F. Visuals: readable UI & anchored effects at 1x/2x/4x/6x; PNG evidence and owner-review notes; visual and mouse acceptance separated from headless PASS.
G. Feature gates default OFF and unchanged outside Lab; player saves and canonical SaveService untouched; Git checks on current PR SHA and existing PvE/production regressions PASS. No claim of release readiness from Lab tests.

## 8. Codex working rules
- Use ONLY the existing PR #72 branch. No new branch or merge `main`.
- Before modifying a file, read current HEAD/diff; do not overwrite other contributors' uncommitted changes or edit overlapping production/SX/SaveService files. Keep Lab-only commits narrow and separable. If a shared source fix is genuinely needed, report a proposed patch for approval first.
- No fake PASS, no fixture in normal release, no artificial economic input, no unauthorized skill/manual drops. Report source SHA, commit SHA, official Godot build, tests actually run, FAIL/PENDING and blockers.
- Deliver one playable Lab scene, not another game executable or new RC; do not wait for SX/đan dược/economy.
