# TÔNG MÔN BÁ ĐẠO — PVE CONTINUOUS WORLD ROLLOUT & SOURCE A ASSET FREEZE

Date: 2026-11-03; engine: **official Godot 4.7.2**; target landscape 1280×720, Windows 8GB RAM and Android.  
Authority baseline: PR [#67](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/67), Draft, HEAD `f2ae694af791a27deec4e1de7ae7c122914be635`. Independent feature branch `feature/pve-opt01-preserve-assets-viewrow-20261103`. No PR/main integration authority exercised.

## A. LOCKED — never replace the existing game art with a text game

- **Retain all existing Source A environment, character rigs, spritesheets, chibi creatures, building textures and native Godot 2.5D isometric renderer.** No deleting, replacing, upscaling/downscaling originals, renaming atlas files or changing asset provenance/hash. No generated placeholder graphics as replacements.
- Map is **the primary surface**; panels/HUD must not cover it with walls of text. Keep visible characters, animated attack, floating HP/damage numbers, loot icons and appropriate Source A scenery. Small polish can come *after* the real gameplay loop works.
- Conserve memory by **render culling, bounded active NPC lists, pooled render nodes and LOD**, not by disabling art. Texture atlases must load on demand with stable cache; do not repeatedly import textures or recreate camera/topology when UI updates.
- **Preserve canonical gameplay**: `SimulationRuntimeOwnerV2`, `SimulationRuntimeClockV2`, `MapBattleV2`, `SaveService`, item/resource registry and exactly-once receipts. No alternate RNG/gameplay clock for offscreen simulation.
- Source A main world: 192×192 navigation cells, 16×16 chunks, 20 camp centers and 200 potential spawn slots (20×10). These are *potential* monster slots; the runtime currently activates just one camp's ~10 monsters. A map must not require clearing a camp to move.
- 1–6 disciples is a party composition option, **NOT** a global hunting/world size constraint. Intended test growth: 1–6 → 12 → 20 → 30 disciples spread across 20 camps. Sect-wide target 300–500 disciples across multiple independent maps, with some maps entirely empty.
- Resource and drop quantities/rates must be data-authored and auditable, **not made up by graphics code**. No fake XP, material grant, recruitment, or boss corpse loot.

## B. Current authoritative gaps

1. **PVE-OPT01:** P3.2 builds visual rows; `PveSectWorldViewV1.show_authority_snapshot` recursively copies every row, then `SectIsometricWorldV1.set_pve_snapshot` repeats the same deep copy. The outer intermediate has no other reader. Keep the renderer's defensive copy, remove the adapter's redundant copy. This is an allocation reduction, not yet a measured FPS improvement. No asset files touched.
2. **PVE-LOOT01 (P0):** `HuntingPveRunV2._record_open_world_kills` creates authoritative kill IDs, preserves respawn slots and resolves V6.3 codex-only drops; regular kills are acknowledged with **`LOOT_PENDING`** instead of ordinary source-specific probabilistic drops. Legacy B3 CARE pays a **fixed single Thanh Lang leather**; that is an opt-in pilot, not open-world loot.
3. **PVE-WORLD01 (P0):** `HuntingPveRunV2._next_ready_world_camp` and `_spawn_open_world_camp` move to the next full group **only after all currently active mobs die**. This is not a resident continuous-world population. Need independent slot lifecycles in nearby regions.
4. **PVE-TEAM01 (P0):** current P3.2 picker requires exactly six and a single `v2_pve_active_runs` multicamp; `MapBattleV2.MAX_DISCIPLES=30` is an *actor safety bound*, not proof of multiple teams or maps. Need map-scoped sessions with independent members/assignment and global reservation.
5. **PVE-UX01 (P0):** current "Về tông môn" calls `retreat_multicamp()` for the active camp, ending the hunt instead of merely hiding the PvE screen. Must split "Đóng bản đồ" (keep hunting) and "Rút đội" (real retreat).
6. **PVE-LOAD01 (P1):** multi-map/300-disciple capacity is NOT supported/benchmarked. Need one active battle simulation authority per map, background simulation without sprites and deterministic bounded work batches. A naive approximate kills-per-minute model is NOT authoritative or safe.
7. Elite/Boss types have `behavior_id` labels but `behavior_ready=false` and `loot_ready=false` for newly authored species. Need authored class-specific mechanics *after* the PvE loop, not fake cosmetic special abilities.

## C. Execute in this order — one proof-of-play packet at a time

| Packet | Exact production scope | Gate to mark PASS | No-go / rollback |
|---|---|---|---|
| **OPT01 — NOW** | `PveSectWorldViewV1` adapter only: remove redundant deep copy; Source A renderer still owns one immutable visual snapshot. New isolated `pve_opt01_source_a_viewrow_copy_contract_test.gd` | Official Godot 4.7.2 test: six disciple + ten monster actor rows, HP mutation isolated then picked up on next snapshot, remove actor and preserve camera/world object; parent O2 smoke; clean final diff no asset/source-map/SaveService files | On renderer aliasing, UI regression or test failure, revert one adapter change. No PR67 code edits |
| **LOOT01 — NEXT P0** | New canonical per-species/per-kill loot table + exactly-once settlement wired to existing `_record_open_world_kills`, no separate reward authority. Use existing registered item IDs (e.g. canonical `tinh_lang_bi`, `yeu_dan`, `thanh_linh_thao` when semantically valid). No arbitrary `P0Content` legacy item copy into Warehouse | Kill 1 genuine mob → deterministic seed-and-kill-ID probability roll → optional 0 or N registered items → same receipt survives 2-process save/load, event ack, immediate/late replay and warehouse-full backpressure; kill another generation rolls separately; no items when no reward. Document draft odds and gain owner validation before balance freeze | Any double-paid item, silently dropped kill, invalid registry item, random reroll on reload or fake material grants = FAIL |
| **WORLD01 — P0** | One Source A map, 20 camps with **independent live/dead/respawn slot state**. Bounded active nearby combat actors (respect `MAX_MONSTERS=40` for a local battle); far camps retain slot timers and no graphic nodes. No dependency on "kill all ten" to visit another camp | Natural 1–6 recruits visit camps C01→C10→C20 and back with real navigation, some monsters still alive at C01; same slots/respawns/loot after reload, no phantom mobs or 41st combat actor | Any full-map 200-AI/render update every 0.25 s, out-of-range combat, duplicate spawn or broken pathfinding = FAIL |
| **TEAM01 — P0** | Authoritative map-scoped hunting participant/party assignment (optional 1–6 per party, individual hunters allowed). Build 12→20→30 user-selectable actors across 20 camps without altering global sect roster cap. Selection and work/job reservations exact | 30 real V2 at separate camps, independent nearest targets, injured and busy denied, retreat individual/party, jobs released; exact return/reload | One global six-person barrier or wrong shared HP/kill/receipt = FAIL |
| **UX01 — P0** | TRI-03 **exclusive P3.2 writer**: separate "Đóng bản đồ" from "Rút đội", keep map visible and colorful, icons native Source A, HP/loot feedback. Do not touch P3.2 on an unrelated feature branch | Closing map keeps combat+loot; retreat stops only chosen team, Save/Reload state correct; 1280×720 native screenshots reviewed; no character atlas redesign | Writer conflict, missing physical button, UI blocked = FAIL |
| **MAP01 — P1** | Bring existing Bạch Thạch Khê/Hắc Phong Cốc content into independently saved world sessions, each with its map identity and spawn population, without duplicating the simulation clock | Multiple occupied maps progress in parallel, closing one does not change another; kill/loot/respawn/HP/clock remain identical across reload; no seeded QA grants | Any cross-map session overwrite, ID collision, double-paid item or asset fallback = FAIL |
| **SCALE01 — P1** | Simulation LOD: visible camera detailed, offscreen map bounded event/time batches with same combat/stat/loot authority. Render pooling/culling; limit active physical actors; do not load all map atlases simultaneously | Scripted 30/hunting-map and 300/sect across 10+ maps, repeated reload and offline catch-up, zero duplicate receipts. Capture *QA-only* memory/frame time evidence on Android/Windows before declaring smooth; no new player telemetry | Memory exhaustion, O(N maps × 200 actors) frame work or drop result drift = FAIL |
| **POLISH01 — P2** | Source A rig/atlas-native chibi animation, attack/cast VFX, concise UI, minimap, rarity icons/feedback. No placeholder downgrade. | Real desktop 1280×720 screenshot review and Android touch + FPS acceptance | Cannot sign off merely by headless CI |

**Ownership:** TRI-03 is the sole PR67/P3.2 integration owner. All independent PvE backend and renderer code must use feature branches with minimal cherry-pick and explicit owner code authority, never directly merge `main`. Do not cherry-pick the pending independent PVE-01B V6.3 gate into PR67 without owner authorization. Asset producers must not overlap with live visual writer.

## D. Optimization policy for 300–500 disciplines

- **Logical state**: Each disciple has one location and job assignment: `sect`, `map_id/camp_id` or travel. Map session/kill/respawn receipts remain canonical; do not multiply the same actor into independent worlds.
- **Visible map**: Draw only camera-visible relevant Source A rigs and high-detail VFX, with a modest margin to prevent popping. Other camps preserve time and HP but do not render character animation.
- **Other maps**: Persist world state, process time in **bounded, deterministic chunks** of combat clock; no full offscreen Godot scene trees. When the user visits a map, materialize a renderer from the authoritative state and never restart a monster's spawn generation.
- **Current `MapBattleV2.MAX_DISCIPLES=30`, `MAX_MONSTERS=40` are local safety bounds**. Hundreds of disciples are sharded by independently owned map/camp sessions, not inserted into one giant `MapBattleV2` instance.
- **Assets**: Only sprites on active map/near camera need GPU resources; use the original high-quality sprites, not lower-res substitutions. Keep idle/attack/death cues aligned with authority events.
- **Proof before tuning**: first verify 6→12→30 actors, then 3 maps, then scale to 300 global. Do not claim Android 30/60 FPS without physical-device measurements. No permanent runtime telemetry or performance-logging systems introduced.

## E. Ready-to-run immediate QA

```sh
# Godot 4.7.2, isolated QA checkout ONLY. No production save changes.
godot --headless --path godot --editor --quit
godot --headless --path godot -s res://tests/presentation/pve_opt01_source_a_viewrow_copy_contract_test.gd
```

Baseline official CI on unmodified PR67 and previous natural G0 path:
- Natural New Game→six V2→Source A 6v10→two-process Save/Reload: [run 41592972229](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41592972229) (**correct owner repository link appears in QA evidence**). That proves entering PvE, not monster-loot settlement.
- PVE-01B V6.3 real cast/28.56 HP damage on **independent** branch: [run 41583753724](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41583753724); not yet integrated.
- The **OPT01 test and official CI outcome must be attached separately**; existence of this roadmap cannot be used as a PASS oracle.

**Most important acceptance:** The end product must still *look like the real Source A Tông Môn Bá Đạo game*, not an interface with only numbers and colored boxes. Optimization is about invisible work, not downgraded art.
