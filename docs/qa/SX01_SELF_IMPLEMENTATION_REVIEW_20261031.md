# SX-01 — SELF-AUTHORED IMPLEMENTATION, REVIEW GATE

Status: **CODE_COMMITTED / GODOT_IMPORT_PENDING / RUNTIME_TESTS_PENDING / GUI_PENDING**.

Base: `integration/one-game-v65-20261030` at `199f888c7fd690830728dfbf29b6b79276e3b283`.
Implementation branch: `feature/sx01-pill-policy-20261031`.
No production `main` edits or legacy save writes.

## Changes actually made

- `SX01PillPolicy`: versioned sect policy, 6 HXD/12 TQD stock targets, pending-job-aware demand planner, 60% idle-safe HXD trigger, 2/day prioritized TQD budget, 5-canonical-tick stable review, opt-in target/mode/priority configuration. Auto effects route ONLY to `B3PillSatietyV1.consume`.
- `SectState`: policy persisted with legacy empty default and typed key normalization; existing inventory and original B3 receipts retained.
- `LiveGameRuntimeV2`: install defaults on **created** games only, not saved games.
- `SimulationScheduler`: run one policy review after all actors on every fifth minute.
- `BuildingSystem`: choose HXD/TQD before a genuinely paid job, freeze existing jobs, prevent overproduction in demand mode, plan Field AUTO_DEMAND crops by available herb/grain and crops already in progress. FIXED/PRIORITY crop modes untouched.
- `p3_2_landscape_sect.gd`: two recipe buttons, fixed/demand choice, auto production toggle, +/- stock targets, HXD and TQD durable manual actions, heal threshold, TQD quota, soft medical reserve, preferred Tu Vi disciple buttons and compact status text.
- New `sx01_pill_policy_test.gd`: checks live V2 setup, policy input validation, canonical B3 HXD/TQD exact effects, quota, hard reserves and SaveService roundtrip; **not yet executed**.

## Important compatibility decisions

- Initial recipe mode on freshly-created games is deliberately `fixed` (retains the existing HXD production behavior tested in O8) and can be switched to `demand` by Tông Chủ. This is a conservative deviation from the draft SX-01 spec suggesting immediate demand default.
- Legacy saves without SX-01 policy remain unmodified until explicit UI opt-in.
- Original `B3PillSatietyV1`, `B3MedicalAutoplayV1`, `DiscipleProgressionBalanceV2`, `EquipmentSystem`, `WarehouseSystem`, `SaveService` have NOT been modified.

## Known blocker / limitations

1. The pre-existing `B3MedicalAutoplayV1.busy` regards **CULTIVATE** as busy. Therefore SX-01 auto Tu Khí can run on an explicitly **prioritized HOLD/IDLE** actor, but it currently **cannot consume while Chuyên Tu is active**. We intentionally did not weaken B3 busy guard. Requires separate owner-approved safe-window remediation/test to satisfy the full proposed Chuyên Tu flow.
2. Source economy is still pilot (2 goods/10 ticks; 20 market units/day) and SX-01 does NOT rebalance prices, wages, Mỏ/Lâm cap or ingredient supply.
3. No independent Godot 4.7.2 binary exists in this environment; tests, import, 1280x720 GUI and Android have **NOT** been run here. Do not classify as PASS or merge.
4. Fixed-recipe mode intentionally doesn't stop based on stock targets; switch to `THEO NHU CẦU` to enforce target cap and Field demand planning.
5. Strict B3 occupation guard still rejects some assigned idle workers with nonempty worksite, so the auto-use eligibility may be narrow; this is a known limitation, not a silent bypass.

## Required QA before merging

On a Windows QA checkout on E: with Godot **4.7.2 official**, one process at a time under limited RAM, run import, `sx01_pill_policy_test.gd`, `p3_o4_spirit_field_loop_test.gd`, `p3_o8_alchemy_loop_test.gd`, `b3_pill_satiety_test.gd`, `b3_care_pills_autohunt_test.gd`, `economy_a_playable_test.gd`, `save_service_async_roundtrip_test.gd`, DV2/GP-02 focused tests. Capture exact SHA, command/exit and markers.

Prove real UI: NewGame→Field paid crops→Alchemy both modes→HXD/TQD manual and policy receipts→Warehouse locked/reserved→save/return/reload, offline parity, and B3 CARE no-double-spend. Screenshots must be from actual Godot, not generated.

This handoff intentionally records **partial implementation**, not a completed SX-01 accepted release.
