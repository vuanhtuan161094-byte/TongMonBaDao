# P1.5 persistence fix — runtime evidence

Date: 2026-10-01
Engine: Godot 4.7.2.stable.official.ed1daf0bf
Code commit: c895bdf114c8b11c2f84095c6da517b66f82f5fe

## Reproduction and root cause

The original p1_5_organization_test.gd failed immediately after save/load.
A strict recursive comparison (including Dictionary keys, types and exact floats)
reported the first difference in sorted field order:

- Path: state.disciples[0].last_decision.region_scores.thanh_truc_lam
- Before: 120.48151387023925000 (float)
- After: 120.48151387023924000 (float)

JSON decimal round-trip shifted a float by one ULP despite full_precision=true.
The previous diagnostic hid this difference behind a 1e-9 tolerance.
StringName/String was not the cause of this reproduction.

last_decision is a presentation/debug snapshot written by DecisionSystem;
the scheduler uses the current evaluation result, not the saved snapshot.
It remains fully persisted and covered by the exact equality contract.

## Fix and compatibility

SaveService version 2 recursively encodes float64 values as eight bytes in a
reserved __float64 hex wrapper, then decodes them before state construction.
This avoids decimal parsing loss for both simulation fields and nested diagnostic
fields without rounding values, deleting fields or changing gameplay.
State to_dict representations are unchanged; save version is a wire-format concern.
Legacy v0/v1 saves still load with their original interpretation.
Older binaries reject v2 saves through the existing newer-version guard.

The diagnostic now checks StringName/String differences, Dictionary key types and
exact floats, and uses Godot-supported float formatting. Added regression coverage
checks nested positive/negative floats and legacy v0/v1 loading.
The original organization test was not modified.

## Results

- Headless editor import: PASS.
- p1_5_organization_test.gd, separately: PASS.
- p1_5_resume_diagnostic.gd, separately: PASS.
- Exact immediate snapshot plus 800 continuation ticks: PASS.
- Nested float64 / legacy v0-v1 regression: PASS.
- Sync-P2-5.cmd on the code commit above: stopped at first failure, exit 1.
- P0, P1.1, P1.2, P1.3, P1.4, P1.5, P1.6 gates: PASS.
- Applicable headless scene smokes through P1.6: PASS.
- P2.1: FAIL — P2.1 cultivation state was not preserved by save/load.
  Location: p2_1_cultivation_test.gd:56.
- P2.2, P2.3, P2.4, P2.5: NOT RUN because P2.1 stopped the chain.

Relationship/memory/team/companion/ID persisted data passed the strict P1.5
recursive comparison. No tolerance or field exclusion was added.
P2.1 root cause has not been established in this bounded fix; no P2.x gameplay
or tests were changed. Do not mark the entire P2.5 stack PASS.

Local full chain log:
C:\Users\Admin\Documents\ChatGPT\Tongmon\p1_5-sync-p2_5.log
