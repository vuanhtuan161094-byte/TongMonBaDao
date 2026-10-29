# V6.3/V6.4 D1 — read-only content registry (unwired)

Integration base: PR #52, integration/pve-unified-rc-20261027 at 5005d7508dff4b6a3da3f319de09dac33669882a.
Copied source specifications from docs/v63-v64-combat-codex-contract-20261028, commit a3bca6735048fb832924dfcfe4fb55846321cc4e.

Files:
- data/combat/v63_content_registry.json: 3 schools; 9 branches; 105 family IDs; 531 progression records, including 18 rare Divine variants; 9 proposed boss prototypes.
- src/simulation/combat/v63_feature_gates.gd: all D1 flags OFF by default.
- src/simulation/combat/v63_content_registry.gd: read-only JSON loader and strict ID/lineage/boss validation.
- src/simulation/combat/v63_successor_graph.gd: read-only successor and equipped-family checks.
- src/simulation/combat/v63_boss_read_model.gd: read-only boss selection; spawn/rewards always false.
- tests/simulation/v63_d1_content_registry_test.gd: Godot focused tests and negative cases.

No reference to new classes is added to existing runtime. No combat gameplay, asset, save or migration changes. All numerical values candidate. This is *not* full V5.9 skill effect authoring, Boss combat AI, boss spawn, loot or Tàng Kinh Các learning.

Focused engine command (Godot official 4.7.2):
```sh
godot --headless --path godot --script res://tests/simulation/v63_d1_content_registry_test.gd
```
Gates are not hooked to P3/PvE and should remain disabled until dedicated follow-on phases with migration/engine evidence. Do NOT merge this branch by default.
