# TMB Poison V4 — Exact-target VFX and combat distance pilot (2026-11-10)

**Scope/authority:** Owner requested target-locked poison impact, recognizable effect shapes and meaningful short/mid/long combat distances. Single PR #72 branch `integration/pve-p0-playable-ui-20261103`. No merge/branch, no Runway, no SaveService changes, V3 retained as default; V4 only on `TMB_POISON_V4_PREVIEW=1` inside isolated Combat Lab.

## Confirmed source defects

1. V4 particle endpoint was built from a **fixed position taken at cast time**, and projectile cues lacked `target_actor_id`. A moving enemy could leave the endpoint before canonical V6.3 release/hit.
2. V4 placed every effect at a universal `-17 * zoom` pixel offset above the target's feet, ignoring normal monster / boss / player rig size. At 6× this produces -102px regardless of the actual sprite height and can miss the quái's body.
3. VFX silhouettes were indistinct: the old needle was almost a narrow line, the gu-serpent only an undulating line, the jade lotus only thin spokes.
4. Lab's six disciples assigned `role` from roster INDEX rather than school. Previous Lab `basic_range`: Bow 5.5 and Fist/Poison 1.65; all Human school basic skill definitions had `range=7`. Most active skills used similar 7.2 ranges, masking actual class identity.

## Committed source changes

- `godot/labs/combat_lab/combat_lab_arena.gd`: attach `target_actor_id` to actual projectile cue; move projectile/impact to current canonical target actor position; keep AoE circle centered on canonical chosen center; derive body-space offsets from actual rendered actor rig. No new hit/event/damage owner.
- `godot/labs/combat_lab/combat_lab_poison_v4_layers.gd`: discrete three-layer VFX geometry: dark-edged poisoned metal needles and tips, bright tapered serpent and visible head, six jade lotus petals. Projectile path is now the *caster's body/hand to target's body*; time is still `skill_cast.release_at` and actual `skill_release/v63_skill_hit`.
- `godot/labs/combat_lab/combat_lab_roster_adapter.gd`: Fist = frontline basic range 1.8, Poison = mage 6.0, Bow = ranged 9.0 in the 1280×720 Lab. This is a **real MapBattleV2 actor attribute**, not a painted circle.
- `godot/src/simulation/combat/map_battle_v2.gd`: role-based **fallback** ordinary attack ranges, including joining a continuous world: frontline 1.8; mage 6.0; healer 6.0; ranged 9.0. **Explicit `basic_range` in caller data is preserved**; no second role source or Save migration.
- `godot/data/combat/v63_human_combat_catalog.json`: 39 Human skill `range` values retuned, no skill IDs/effects/coefficients or AoE radius changes. Tier 2/3 remains gated and unchanged.

## Human range policy in world grid units

| Gameplay role | Basic | Human active / ultimate |
| --- | ---: | --- |
| Fist (melee) | 1.8 | 2.8 direct; 4.0 shockwave circle; 5.0 ultimate; self guard unchanged |
| Poison (mid-range) | 6.0 | 7.5 direct; 7.0 circle; 8.5 ultimate; heal/cleanse 6.0 unchanged |
| Bow (long-range) | 9.0 | 10.0 direct; 9.0 circle; 11.5 ultimate; ally heal 7.0 |
| Mobility | separate | Existing 11.0, not an attack |
| AoE radius | unchanged | Canonical 3.0 radius for relevant area skills |

This is a **pilot** subject to official regression and visual QA, not a declaration that 183 Poison skills or Immortal/Divine are balanced. Fist must approach, but has limited reach shockwaves by authored shape; ranged remains at distance.

## Required QA / evidence

- `poison_v4_aim_range_contract_test.gd`: target moves after cast, visual projectile/impact follows canonical actor; AoE stays at real center, cast remains at caster, correct scaled body offsets and school role distances.
- `v63_human_range_role_test.gd`: actual `MapBattleV2` and V6.3 `_try_human_cast` at just INSIDE and OUTSIDE each skill's authored range (three schools), source ID/cooldown/cast only; HP unchanged before release.
- `dv2_02_group_map_battle_test.gd`, `v65_poison_combat_contract_test.gd`, `combat_lab_focused_test.gd`, `combat_lab_v2_visual_test.gd` and V4 render contract: regression guards.
- Workflow: `.github/workflows/poison-v4-godot-evidence.yml`, official 4.7.2 SHA-pinned import + strict script diagnostics + real 1280×720 videos. Video must show an actual quái target, no fabricated health changes. User review at 1×/2× plus detail zoom 4×/6× still required.
- **Until new SHA tests run:** all new range/aim values are CODE-CHANGED / QA-PENDING. Earlier run 42747713182 PASS applies to *previous* version, not these edits. Windows/Android device remains PENDING.

## Rollback

Remove/disable `TMB_POISON_V4_PREVIEW` to keep legacy V3 VFX (not a rollback for real skill range edits). Restore the 39 `range` values and role defaults only via reviewed commit revert if pilot regression fails; never reset dirty Windows E: worktrees or Save.
