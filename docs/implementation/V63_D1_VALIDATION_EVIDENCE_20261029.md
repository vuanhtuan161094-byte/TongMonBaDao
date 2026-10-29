# V6.3 D1 — Focused validation evidence (2026-10-29)

## Commit and repository scope

Input PR #52 integration HEAD: `5005d7508dff4b6a3da3f319de09dac33669882a`.
New branch: `feature/v63-d1-content-registry-20261029`.
First D1 source commit: `15e9cd3bf443e7eaa2c11ea6d08ae7c856cd9bbf`.
Compared base to source commit with GitHub compare: **ahead=1, behind=0, changed=13, all 13 files added**; 0 legacy gameplay/asset/save files modified.
Documentation pack was copied, byte-for-byte by connector content retrieval, from separate docs branch (prior design commit `a3bca6735048fb832924dfcfe4fb55846321cc4e`).

## Actually executed — static verification on GitHub-fetched content

Read `godot/data/combat/v63_content_registry.json` back from new branch (Git blob SHA `b8a4af884632f938084d15818f84158e3a94ff06`) and parsed the stored JSON.

Result: `STATIC_REGISTRY_PASS`.
- exactly 105 distinct skill family IDs (six school-wide, 99 specialized across nine branches);
- exactly 531 distinct successor nodes, every parent previously declared in same family;
- exactly 18 rare Divine nodes, two per branch ultimate;
- exactly nine boss IDs and nine ultimate ability definitions;
- each Boss has exactly four ability records, phase thresholds 0.70/0.35, cooldown>0, telegraph>=0;
- spawn_ready/loot_ready/ability ready all false; catalogue enabled false;
- per-branch family counts exactly eleven and shared six;
- structural negative samples: duplicate family ID detected, forward/cyclic parent rejected, accidental boss spawn_ready enabled detected.

The checks above were run as a **JavaScript structural audit** on the actual committed JSON; this is not a Godot runtime PASS and does not validate the GDScript compile or engine behavior.

## NOT executed — engine focused test

Attempted executable probe in current container: neither `godot` nor `godot4` is installed (`BLOCKED_GODOT_ENGINE`). Internet GitHub hostname resolution unavailable in container, so engine installation was not attempted. The GDScript test `godot/tests/simulation/v63_d1_content_registry_test.gd` is committed but **PENDING_ENGINE**. There were **zero Godot focused tests executed** in this session. No CI claim.

Run on user's Windows machine with official Godot 4.7.2 and local checkout of this branch:

```powershell
& "E:\\path\\to\\Godot_v4.7.2-stable_win64_console.exe" --headless --path "E:\\TongMonBaDaoWorkspace\\TongMonBaDao\\godot" --script "res://tests/simulation/v63_d1_content_registry_test.gd"
```

Replace both paths with the actual executable/repository location. A successful test should exit 0 and print `V63_D1_PASS`. Do not assert PASS until that exit code and log exist.

Recommended additionally run current PvE focused suites (MapBattleV2/monster/pve tests) and import from the exact branch SHA; verify legacy combat snapshots byte-for-byte where applicable.

## Open release gates

D1 is **CODE_READY_STATIC_PASS / ENGINE_PENDING / GAMEPLAY_UNWIRED**:
- Feature flags OFF; no live path imports the new registry.
- All skill-node effects are future authored candidates, not usable runtime skills.
- Boss definitions are read-only and explicitly disallow spawn/loot.
- No migration, economy, UI, Save or AI changes.
- D2 should not be authorized until Godot import/focused tests confirm syntax/invariants and owner reviews A/B authority disputes.
- PR #52 remains Draft and no merge was performed.
