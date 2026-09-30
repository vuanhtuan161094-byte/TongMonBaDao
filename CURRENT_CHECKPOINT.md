# CURRENT CHECKPOINT

Date: 2026-10-01

## Project state

Runtime-confirmed on real Windows + Godot 4.7.2:

- P0 Foundation: LOCKED / PASS.
- P1.1 Goal + Personality: LOCKED / PASS.
- P1.2 Recruitment + Player Choice: LOCKED / PASS.
- P1.3 Relationships + Behavioral Impact: LOCKED / PASS.
- P1.4 Consequential Memory: PASS.
- P1.5 Organization + Teams + Leadership + Roles: PASS.
- P1.6 Sect Life + Needs + Resource Pressure: PASS.

Implemented but current cumulative runtime chain is blocked at P2.1:

- P2.1 Cultivation + Realms + Breakthrough: IMPLEMENTED / RUNTIME PERSISTENCE BLOCKER.
- P2.2 Spiritual Root Quality + Long-Term Growth: IMPLEMENTED / NOT REACHED AFTER CURRENT P2.1 BLOCKER.
- P2.3 Technique Economy + Library + Mastery: IMPLEMENTED / NOT REACHED AFTER CURRENT P2.1 BLOCKER.
- P2.4 Cultivation Paths / Character Dao Direction: IMPLEMENTED / NOT REACHED AFTER CURRENT P2.1 BLOCKER.
- P2.5 Combat Skills / Real-time Auto Combat: IMPLEMENTED / NOT REACHED AFTER CURRENT P2.1 BLOCKER.
- P2.6 Forge + Equipment Tycoon: IMPLEMENTED / AWAITING RUNTIME GATE.

Do not mark P2.1-P2.6 PASS until the real cumulative gate reaches and passes them.

## P1.5 persistence closure

P1.5 save/load was fixed and runtime-confirmed.

Root cause: JSON decimal round-trip shifted a nested float64 by one ULP in `last_decision.region_scores`.

- fix commit: `c895bdf114c8b11c2f84095c6da517b66f82f5fe`;
- SaveService wire format v2 recursively stores float64 as exact 8-byte hex wrappers;
- legacy v0/v1 saves remain readable;
- immediate exact save/load comparison: PASS;
- 800 continuation ticks after load: PASS;
- original P1.5 organization test: PASS.

Evidence: `docs/P1_5_PERSISTENCE_RUNTIME_REPORT.md`.

## Current runtime blocker — P2.1

Latest real cumulative run reached:

- P0 -> P1.6: PASS;
- P2.1: FAIL at `p2_1_cultivation_test.gd`, message `cultivation state was not preserved by save/load`;
- P2.2-P2.5 were not run because the chain stopped at P2.1.

A dedicated first-difference diagnostic now exists:

- `godot/tests/simulation/p2_1_persistence_diagnostic.gd`;
- `tools/godot/Verify-P2-1.ps1` runs it before the main P2.1 test.

Next real local run should expose the exact first P2.1 persisted-state difference instead of only the generic failure.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns gameplay/simulation authority.
- Deterministic seeded simulation is mandatory.
- Save/load, invariants and P0 money conservation are mandatory.
- Later phase mechanics remain opt-in so earlier factories keep prior behavior.
- Mechanics must change decisions/outcomes; decorative systems do not count as completion.
- No fixed character class. Kiếm/Thể/Pháp identity comes from actual path history and compatible systems.
- Player manages the sect and can intervene directly where useful, but disciples remain autonomous by default.

## Progression stack

- P2.1: cultivation -> breakthrough -> realm -> combat/HP consequences.
- P2.2: spiritual-root quality and elements affect long-term growth and compatibility.
- P2.3: sect-owned technique economy, manuals, learning/mastery/upgrades and one active cultivation technique.
- P2.4: Sword/Body/Spell path identity is derived from accumulated path XP; no fixed class.
- P2.5: independent combat skills + deterministic real-time auto combat with distance, movement, cast time, cooldown, projectiles and temporary combat effects.
- P2.6: hunting materials -> sect forge -> equipment shop/storage -> autonomous or manual equipment -> stronger combat and harder region choice.

## Active P2.6 — Forge + Equipment Tycoon

User-approved loop:

`Săn -> nguyên liệu -> Luyện Khí Đường -> rèn trang bị -> kho/cửa hàng -> đệ tử tự mua hoặc người chơi cấp -> mạnh hơn -> săn vùng khó hơn`.

### Player vs AI equipment authority

Default:

- disciples autonomously evaluate and buy meaningful upgrades;
- evaluation considers raw stats, path depth, active technique path, learned combat skills, root element, personality, price, spend bias and sect policy.

Player always retains direct control:

- manual equip an item to a disciple;
- lock an equipment slot so AI cannot replace it;
- unlock / return slot to auto;
- unequip back to sect storage.

Manual lock overrides autonomous equipment choice.

### Closed internal money

Disciple equipment purchase is an internal transfer:

`disciple wallet - price -> sect treasury + price`.

Total simulation money must remain unchanged by this transaction.

Manual allocation is not a purchase and does not transfer money.

The initial forge vertical slice consumes materials only; no undefined external money sink is introduced yet.

### Initial forge vertical slice

Materials:

- Linh Mộc;
- Thanh Thiết;
- Tinh Lang Bì;
- Yêu Đan.

Recipes:

- Thanh Thiết Kiếm — Kiếm / Kim;
- Huyền Thiết Quyền Sáo — Thể / Thổ;
- Linh Mộc Pháp Trượng — Pháp / Mộc;
- Tinh Lang Giáp — armor / Thể / Thổ;
- Hỏa Vân Ngọc — talisman / Pháp / Hỏa.

Quality tiers are deterministic from seed + forge index + recipe:

- Phàm phẩm;
- Tinh phẩm;
- Thượng phẩm.

P2.6 is classless: path/element affect suitability, not legality.

### P2.6 real consequences

Implemented connections:

- combat victory can produce forge materials;
- returning/selling deposits forge materials into the sect forge store before ordinary sale;
- forging consumes materials and creates a unique item instance;
- shop purchase transfers money internally without changing total money;
- equipment combat-power bonus affects P2.5 encounter power;
- equipment combat-power bonus also affects autonomous region selection, allowing gear progression to change where a disciple is willing to hunt;
- manual equip + lock/unlock state persists.

Equipment schema also includes defense, skill-effect, movement/basic-speed/range/ratio modifiers. These are reserved for continued P2.6 wiring and must not be described as runtime-complete until a real gate proves their CombatSystem integration.

### Verification assets

- spec: `docs/P2_6_SPEC.md`;
- system: `godot/src/simulation/equipment/equipment_system.gd`;
- factory: `godot/src/simulation/core/p2_6_factory.gd`;
- test: `godot/tests/simulation/p2_6_equipment_test.gd`;
- scene: `godot/scenes/p2/p2_6_equipment.tscn`;
- presentation: `godot/src/presentation/p2_6_equipment.gd`;
- verifier: `tools/godot/Verify-P2-6.ps1`;
- root verify launcher: `Verify-P2-6.cmd`;
- authoritative sync + cumulative gate: `Sync-P2-6.cmd`.

Only the latest root launchers are kept. Older phase PowerShell verifiers stay under `tools/godot` because cumulative verification depends on them.

## P2.6 gate contract

The gate must prove at minimum:

1. P2.5 remains equipment-disabled.
2. Combat victories produce and return forge materials.
3. Same seed/index/recipe produces deterministic forged quality/stats.
4. Forging consumes materials and creates unique equipment instances.
5. Different disciple builds score the same gear differently.
6. Autonomous buying chooses meaningful upgrades.
7. Internal equipment buying conserves total money.
8. Manual equip works.
9. Locked slots cannot be replaced by AI.
10. Unlocking returns control to AI.
11. Equipment power changes autonomous region choice.
12. Equipment power changes controlled combat outcome.
13. Full P2.6 state survives save/load exactly.
14. Post-load continuation remains deterministic.
15. All prior invariants remain green.
16. P2.6 interaction scene launches on Godot 4.7.2.

## Deferred after the vertical slice

Not yet part of P2.6 runtime completion:

- +N enhancement;
- reroll/random-affix economy;
- set bonuses;
- forge failure;
- blacksmith/crafter skill progression;
- durability/repair;
- auction house;
- pet equipment;
- autonomous artifact AI;
- multi-workstation crafting queues;
- undefined external money sources/sinks.

## Next authoritative command

When the Windows machine is available and the working tree is clean:

`Sync-P2-6.cmd`

Expected first useful evidence is still the P2.1 persistence diagnostic. Fix the first failing gate, rerun the same cumulative command, and continue until P2.6 is reached.
