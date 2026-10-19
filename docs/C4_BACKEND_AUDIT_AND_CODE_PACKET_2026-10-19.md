# C4 BACKEND AUDIT — COMBAT V4 / JX1 (2026-10-19)

Status: **SOURCE AUDIT COMPLETE / BACKEND CODE NOT AUTHORIZED OR MODIFIED / GODOT RUNTIME PENDING**. Read-only from `c4-jx1-rank-and-fx-source-20261019` HEAD `f757c5f162f85ebccda936b06ba8a06b07eac003`; `main` checked at `461caca1171462e0da092f21108c5c1733157ad9`. Audit branch `audit/c4-backend-gap-contract-20261019` forks this exact commit. Do not conflate static source inspection with a running Android/Windows test or visual owner approval.

## Verified backend inventory

| Feature | Verified code | Operational boundary |
| --- | --- | --- |
| Deterministic step/RNG | `MapBattleV2.step` 0.25 s, `GameRng`, sorted actor/action order; `MapBattleSnapshotV2` variant-base64 V1 snapshot | Existing deterministic baselines locked. A new RNG miss roll MUST version/migrate old seeded/replay contract |
| Damage/crit/guard/heal/status | `CombatStatsV2`, `MapBattleV2._deal_direct`, `JxPilotRuntimeV1.release/tick` | Real HP receipts, DoT, HoT, guard, lifesteal exist. There is currently **NO** ordinary Accuracy/Evasion hit resolution or authoritative MISS/DODGE |
| Team/monster scale | `MapBattleV2`: max 30 disciples, six per team, max 40 monsters; AoE selection cap 3 | Actual full 30v40 Android performance/labels and e2e not established; pilot is 6v5 |
| Monster progress/tiers | `MonsterCatalogueV2.create_actor` produces true `realm_index/floor_index` (30x10), species normal/elite/boss; `HuntingMapV2.REGION_CONTENT` 3 regions x 5 local difficulty levels | `MapBattleV2.setup` discards original monster level/name metadata; C4 pilot display patch uses explicit **view-only** metadata, production hunt controller still needs read-only presentation adapter |
| Build movement speed | `CombatStatsV2.derive` outputs multiplier; **real** `DiscipleCombatLoadoutV2.build` already computes `max(0.1, style_move_speed * stats.move_speed)` and supplies row `move_speed` to `MapBattleV2.setup` | Direct pilot/custom actors without override use flat role defaults 2.35/2.05; do NOT characterize the real hunting gear-speed bridge as absent. Validate valid-data equivalence for all entrypoints before any migration |
| Boss warning/AI | `MapBattleV2._begin_telegraphed_aoe` 2.8/2.2 radius, windup 1.0/0.75s, `_release_casts` authoritative position and cap | `step` currently pursues nearest enemy; no telegraph response/learned evade. Do not invent auto-dodge/immunity or alter timing in HUD |
| Skills | `JxPilotSkillsV1` five explicit, equipped pilot skill IDs; `JxPilotRuntimeV1` handles casts/commit/impact, poison, HoT, defense; normal `_try_learned_damage_skill` consumes learned skills with effect=damage only | Pilot JX kits are fixture, **NOT automatically learned** by actual disciples; normal non-damage/debuff/dash skill consumers not implemented |
| PvE gameplay/loot/save | `HuntingPveRunV2.begin/advance/finish/claim`, `HuntingMapV2` spawning/reward; reservation, Injury 0/1 recovery 120 ticks, terminal receipt/duplicate claim prevention, resume/restore/reconcile | Comment states **not installed in legacy scheduler**; `HuntingLevelSelectorV2` code says **not mounted on SectMap by default**. Real route player selecting region → roster → live scene → persistent rewards needs integrated acceptance before calling it a playable loop |
| JX1 presentation | `CombatV4EffectAtlas`, `MapBattleWorldLayerV2`, `combat_v4_jx_pilot.gd` | Eight owner-supplied asset binaries committed; only #158 impact/#63 positive impact/#93 precast mapped. Runtime import/cropped frames/phone UI not verified |

## Prioritized unfinished backend work (implementation packets, not an authorization to mutate gameplay)

**P0 — C4-BE01: real hunting integration**. Designate one owner for the hunting controller, SectMap interaction and One Active Job integration. Validate `HuntingPveRunV2` begin / advance / save / resume / terminal / claim through an actual selected region and real disciple (not 6v5 fixture), including injury recovery, Warehouse, offline exactly-once, multiple resumes and cancelled/invalid attempts. Do NOT put parallel ticking in the Godot GUI. Potential files: `godot/src/simulation/combat/hunting_pve_run_v2.gd`, `godot/src/presentation/p3/hunting_level_selector_v2.gd`, the actual approved sect-map/region controller and relevant focused tests. **Requires a specific CODE packet** because it crosses scheduler, state and save contracts. Does not modify CombatStats formula.

**P0 — C4-BE02: safe source-identity/roster bridge**. All real-hunt actors must display true `DiscipleState.display_name`, canonical Tu Vi + Luyện Thể and `MonsterCatalogueV2` tier/level after beginning/resuming a saved encounter. Supply original spawn and canonical disciple input to a read-only presentation adapter, never infer realm from HP/ATK. Prefer a presentation-only adapter, **do not serialize renderer labels as gameplay state**. Regression against resume and pilot fixtures; zero changes to RNG, event journal, HP. May be implemented with separately scoped presentation permission.

**P1 — C4-GP02-STAT: Accuracy/Evasion migration**. The current explicit design `docs/C4_ACCURACY_EVASION_MOVEMENT_SKILL_REACTION_DESIGN_2026-10-19.md` overrides the former absence of stats for **future** gameplay. Version the deterministic/serialized encounter contract, register actually-owned gear/skill sources, add per-eligible-hit RNG stage, make real miss event receipts, distinguish critical vs hit roll, preserve DoT/HoT/area-cap. Make newly seeded replay + old snapshot differential gates. Touches CombatStatsV2/MapBattleV2/MonsterEncounterV2/MapBattleSnapshotV2 and consumer tests. **Requires explicit gameplay CODE authorization and numeric lock**; never silently retrofit GP01.

**P1 — C4-GP03-MOVE: measured speed and telegraph reaction**. Existing gear movement multiplier on real `DiscipleCombatLoadoutV2` must remain effective; pilot/custom actor defaults need a documented contract, finite guards, speed caps if authorized. Add simple actual AoE exit policy that respects available warning time, distance, speed, cast lock and arena; no teleports. Run deterministic tick/snapshot, 30v40 and fps30/60 comparisons. No guaranteed dodge.

**P2 — C4-GP04-EVADE-SKILL**. One genuinely learned/equipped, cooldown/resource-constrained evade movement or guard consumer after accuracy and movement migration. Require valid target geometry and true authoritative events; do not auto-assign all characters new evade skills. Pilot JX1 IDs must not be silently promoted into production progression.

**P2 — C4-MONSTER-AI**. Monster `behavior_id` and `behavior_ready=false` exist in `MonsterCatalogueV2`, but full species-specific AI and boss phases/loot are not yet authored. Introduce species behavior in a dedicated balance packet after e2e hunting and movement acceptance; no unsourced Boss AI theatrics.

**P2 — load/performance/content**. Full 30 disciple/40 monster case; server-side event bounded by `MAX_EVENTS=2400`, 90s max; ensure overflow produces an explicit safe outcome rather than pretending every receipt still exists. Compare real Windows/Android memory, HUD packing and display of large damage; physical Android performance PENDING. UI/VFX pending on all new branches.

## Required gate before any backend code

1. Current user permission must name an exact **single code packet**, allowed paths, prohibited systems, expected current `main` SHA, rollback boundary, and focused/adjacent tests as required by `AGENTS.md`. Generic review instruction is not approval to change shared simulation/RNG/save.
2. Read `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md` and the active master spec. One writer on shared state.
3. Create isolated branch from a proven base, write failing focused tests first and preserve deterministic old behavior; do NOT run FULL/CI or merge during exploratory coding without owner permission.
4. Report three distinct evidence levels: source inspected, static test checks authored, **official Godot 4.7.2 tests executed**. No claim of PASS or UX signoff on this audit-only branch.

## Audit conclusion

The immediate highest-value missing deliverable is a **real playable hunting loop and canonical actor identity linkage**, not replacement of existing deterministic combat arithmetic. Existing real-hunt speed modifiers and exactly-once settlement are implemented and must be preserved. Accuracy/Evasion, actual warning escape and learned evade skill are independent future gameplay packets. This audit creates **no additional combat mechanics**, imports no further art and does not change `main`, PR20, Economy, SaveService, CombatStatsV2, MapBattleV2 or RNG.
