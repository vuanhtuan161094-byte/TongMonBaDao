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

## Actually executed — Windows Godot 4.7.2 import and focused test (2026-10-29)

Executed from the required isolated worktree at `E:\TongMonBaDaoWorkspace\01_Game\TMB_V63_COMBAT_20261029` on D1 baseline `6e4012d7a9e3a7efa56df349a176f9491d550742`. Used the official `4.7.2.stable.official.ed1daf0bf` console executable. The required project import completed with exit 0, registered 310 script classes, and reimported 103 resources. The focused D1 GDScript gate ran after import and completed with exit 0.

Commands:

```powershell
& "E:\Godot_v4.7.2-stable_win64_console.exe" --headless --editor --path "E:\TongMonBaDaoWorkspace\01_Game\TMB_V63_COMBAT_20261029\godot" --import --quit
& "E:\Godot_v4.7.2-stable_win64_console.exe" --headless --path "E:\TongMonBaDaoWorkspace\01_Game\TMB_V63_COMBAT_20261029\godot" --script "res://tests/simulation/v63_d1_content_registry_test.gd"
```

Result: `V63_D1_PASS: 105 families, 531 nodes, 18 rare variants, 9 bosses, gates OFF and negative cases`. No import/test errors or warnings were found in the captured logs. This is the focused D1 gate only; it is not a PvE regression, full gameplay, GUI, Android, or CI claim.

Logs are saved in the project QA folder `E:\TongMonBaDaoWorkspace\03_QA_Logs\v63_d1_validation` and copied to the user-facing outputs folder. SHA-256:

- `godot_4_7_2_import.log`: `793CC04691E6A2FF1E92B37BB38D1CB40F4DD49125EECFD63D96AAF94D23964A`
- `v63_d1_focused_test.log`: `921FC782AEF26F1FBB4A72FE2A586AD9C47FEC614875341542178CD167F78CD7`

## Open release gates

D1 is **CODE_READY_STATIC_PASS / FOCUSED_ENGINE_PASS / GAMEPLAY_UNWIRED**:
- Feature flags OFF; no live path imports the new registry.
- All skill-node effects are future authored candidates, not usable runtime skills.
- Boss definitions are read-only and explicitly disallow spawn/loot.
- No migration, economy, UI, Save or AI changes.
- D1's import and focused engine gate now pass on the exact baseline. D2 code remains gated by the repository's required owner-approved path allowlist for its CODE packet; no D2 gameplay changes are present.
- PR #52 remains Draft and no merge was performed.
