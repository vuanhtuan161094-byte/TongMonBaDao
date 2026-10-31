# Độc Tu Combat — GitHub Handoff Packet

**Repository:** `vuanhtuan161094-byte/TongMonBaDao`  
**Handoff branch base:** `400baa11403720fb816075d65f3cb74e8f4ad505` (latest integration HEAD supplied and verified against branch ref)  
**Patch base:** `095ff2f90df8260dd123c06964d20c4f9b571d32`  
**Engine:** Godot 4.7.2 stable (`ed1daf0bf`)  
**Scope:** branch packet only; no ONE GAME ref, PR #52, main, runtime saves, or shared combat/save services are changed.

## Exact production files in the patch

1. `godot/src/simulation/combat/v63_human_skill_combat_system.gd` — heal target eligibility and deterministic sorting; poison tick/source/HP event attribution and pending kill journal attribution; owned mark consumption for Cổ Độc B punish.
2. `godot/data/combat/v63_divine_combat_catalog.json` — marks all Divine `single_spread_poison` and `removed_debuff_counter` records `DESIGN_PENDING` (13 records per rule; 26 total). No unapproved spread/counter behavior is implemented.

Test file: `godot/tests/simulation/v65_poison_combat_contract_test.gd`.

## Coverage

| Generation | Records | ID/effect handler routing | Effect counts |
|---|---:|---:|---|
| Nhân | 35 | 35/35 | poison 8, damage 4, cleanse 2, heal 2, passive 15, innate 3, mobility 1 |
| Tiên | 68 | 68/68 | poison 9, damage 8, consume_poison 8, cleanse 2, heal 2, mark 2, passive 30, innate 6, mobility 1 |
| Thần | 80 | 80/80 | poison 11, damage 8, consume_poison 11, cleanse 2, heal 3, mark 2, passive 36, innate 6, mobility 1 |
| **Total** | **183** | **183/183 source-routed** | |

Routing verifies each skill ID resolves and its effect is known to the combat effect registry; behavior is exercised by representative skills and existing suites, not by casting every one of 183 records.

## PASS evidence

`POISON_COMBAT_GODOT_47_PASS_20261031.log` records six Godot runs, all exit 0 with PASS markers:

- New poison contract: normal-monster needle cast/HP damage, 30 owned Boss stacks, 19.5 effective stacks (`0.65`), 0.25s stepping with 1s tick cadence, resistance, no crit/lifesteal, owner-only consume, snapshot timers/provenance, kill attribution, kill reload exactly-once, generation-safe respawn, heal target gating, Phệ Cổ mark consume, all 26 DESIGN_PENDING catalog rows.
- Existing D4B archive/effects and Human branch/Boss suites.
- Existing D5 Immortal lineage and D6 rare-successor and Divine-lineage suites.

Godot reports a Windows root certificate store diagnostic during headless runs; each process returned exit 0 and printed its PASS marker.

## DESIGN_PENDING / integration status

- `single_spread_poison`: no authored trigger, range/target selection, or stack policy found. Status remains DESIGN_PENDING.
- `removed_debuff_counter`: no authored counter cap and counter-to-defense conversion found. Status remains DESIGN_PENDING.
- No GUI combat/VFX evidence is in this packet. A prior Godot Project Manager capture failed twice in the computer-use helper; actual in-game acceptance is still pending.
- The four commits from 095ff2 to 400baa touch HS-09 presentation/tests and checkpoint docs; none overlap the two production paths or poison focused test path. This is a path-level comparison only. No patch was blindly applied to 400baa; Integrator should verify ownership and run apply-check in the isolated QA checkout.

**Handoff branch content:** artifact packet only: patch, report, test, PASS log. The production edits remain inside the patch for Codex 1 to review and selectively apply.

