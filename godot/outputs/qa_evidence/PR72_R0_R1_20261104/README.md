# PR #72 R0/R1 focused QA (2026-11-04)

- Runtime source used: PR #72 live parent `74412c60209c7abe7c52122c1df469c533f58a8a`; the clean source archive was based on `e888c010d6cfb09a97ce48af19d1a2f42a401240`. The owner-confirmed comparison showed the difference was documentation-only before this patch. The resulting code commit SHA is added in the PR/Issue report after the tree is committed.
- Godot binary: official Windows `E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe`, version `4.7.2.stable.official.ed1daf0bf`.
- Tests ran sequentially in an isolated app-data profile under `E:\TongMonBaDaoWorkspace\03_QA_Logs\PR72_R0_R1_20261104\profile`; no player/default save was used.
- The final post-patch editor import exited 0 and reported no script parse/load errors. Godot emits an environment warning `Failed to read the root certificate store`; it is nonfatal and unrelated to project scripts.
- Focused tests and exit codes are in `QA_MATRIX.csv`; combined unmodified stdout/stderr is in `godot_focused_tests.log`.
- Stale QA `.bak` state was preserved outside the checkout before test-only cleanup. Main E checkout plus player saves remain untouched.
- R1 code changes are presentation/test-fixture scoped: D7 UI displays 3 Tam Căn + 4 Tứ Tính in canonical order; Tâm Tính remains quality/profile data with no added gameplay effect. Current production loops (Mine, Spirit Field, Linh Lâm, Warehouse, Alchemy, consumers, multi-producer rehearsal, housing Save/Reload) passed.
- No old ProductionPlanRegistry rates, expansion caps, or FoundationGrowthV2 economy were imported. Their current numeric/source-consumer contract lacks an explicit approved SX-03 rule; disposition remains DESIGN_HOLD.
- This is headless Godot evidence, not GUI, Windows mouse, Android, or full one-save playable acceptance. Those remain pending later release gates.