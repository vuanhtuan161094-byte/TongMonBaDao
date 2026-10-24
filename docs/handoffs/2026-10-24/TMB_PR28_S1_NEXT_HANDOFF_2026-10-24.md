# Next handoff — PR28 + Combat V3-S1 Packet B

Continue the same stacked integration. Do not restart from main or merge PR #28/#29/#30.

## Verified checkpoint

- Integration branch: `integration/pr28-combat-v3-s1-playable-qa-20261024`.
- PR28 base: `e9190f490ebea82d2badf7f3fc44b34dd24bd425`.
- Final tested code SHA/tree: `4b02a0c61a2771d9d4638129d96b68ad292270dc` / `352700b65d3cd0ef7039df22a1153d81b2fd7b82`.
- Focused matrix: 28/28 PASS; S1 edge contract 56 checks PASS; O9 PASS.
- Exact-SHA P3.2 capture: 19 frames at 1280×720, including actual live burn, Weaken, learned guard active/expiry, paid loot, same-world respawn, return and SaveService reload.
- Portable Windows project ZIP smoke-launch: exit 0 on official Godot 4.7.2. It is a project+launcher package; export templates are absent so no standalone EXE.
- No FULL/CI or merge. PR #28/#29/#30 remain unchanged.

## Next permitted checks

1. Review the stacked draft PR and evidence, keeping it draft.
2. Perform human Windows mouse acceptance and record sustained FPS/RAM/responsiveness.
3. Run Android landscape/touch acceptance and request Owner Visual review.

No gameplay, combat-authority, economy, asset, balance, FULL/CI, merge, or source PR edits are part of this handoff.
