# Tán Linh Chỉ Nguyền — R1 source gate

Status at branch HEAD `cde55abb138d150d39e0eadce7a487c68e841fb7`:

- `G0_CONTRACT_CONFIRMED`
- `G3_SOURCE_FAIL` — no production sprite was accepted or added.
- `G3.5_NATIVE_NOT_ATTEMPTED`
- `OWNER_VISUAL_PENDING`
- `PVE_HOLD_V63_OFF`

## Canonical mechanic checked

Skill: `tmb.skill.curse.phe_linh_chu.active_01.human` — **Tán Linh Chỉ Nguyền**.

`godot/data/combat/v63_curse_combat_catalog.json` defines a nether-element, single-target `mark` with cap 1, direct damage ratio `1.05`, range `7.5`, cast time `0.5s`, cooldown `10.5s`, projectile speed `0`, and mark duration `4.5s`. `mark_policy` is `owner_scoped_expiring`. The description explicitly rules out stealing HP, spirit, or items. The presentation brief says the mark's strokes turn inward but do not pull the actor or resources.

The current presentation JSON specifies `caster.hand`, `target.center`, and `event.center` anchors. Its phases are `skill_cast` at the caster hand, `skill_release` at the caster hand, no travel event or projectile, `v63_curse_hit` at the target center, and `v63_curse_mark_applied` at the target center after the real mark state changes. There is no mark-expiry event; the source brief leaves fade unbound. The runtime implements the mark in `godot/src/simulation/combat/v63_human_skill_combat_system.gd`, with `v63_curse_mark_applied` emitted only after the owner-scoped state changes.

The existing `V63OriginalCombatVfxV1` event cue list and school-specific rendering branches do not handle Curse. No Curse LAB, actor binding, or mark renderer was added here. A native preview needs the existing candidate actor and the exact receipt-bound target anchor; it must not synthesize a hit or a mark.

## G3 source attempts

The only candidate art attempts are local ImageGen outputs under `/workspace/generated_images`; none were copied into the project or treated as reusable source. `tools/vfx/prepare_g3_source_review.py` generated a source-only dark/light scale sheet at `/tmp/curse_r1_review.png` (not Godot output). Manual 1× review rejected the candidates:

| Candidate | SHA-256 | Review result |
| --- | --- | --- |
| `exec-6c52c40c-a211-4bf2-a3b3-987bbe438591.png` | `53422a569f7242a12c9c4b97978f2f348b1bc97f42fccd0f075b35b755887f90` | The intended charge reduced to a faint pin and curls at 64px; not a readable curse pose. |
| `exec-d0e5f811-6498-4a00-8b5b-4a7d21ff93ff.png` | `5683e3fd9b6cf76cce48be1c867fb958cdf5c6711e17ce3fb0ea9247dfb30262` | Contact reads as a symmetric flower/starburst at 40px. |
| `exec-cc3eff63-6ac7-459b-bba8-ec51303ebc13.png` | `cac3c8139fa69b448acd0e0d8f5584194b54ce92eaf98704350985d1405cbae3` | The three-prong mark loses contrast and identity on the light surface at 40px. |
| `exec-dde07f21-486b-4110-bea3-a634c723d58a.png` | `70e7d1c2c90f7946a53b39e655c49fd1d54a4bc51da3e5feb0e60031ec8c56c7` | Reads as a horizontal beam/projectile, contradicting `projectile_speed=0` and the absent travel phase. |
| `exec-2144b2fa-36d5-4ade-a72d-7d8d7f3b6a9a.png` | `3e212238de426b2f598fcec252f7fa5e66331d7f8c2d277fbce3ed9d67fd8c77` | Reads as a broad slash rather than a compact target-owned mark. |

These trials do not pass G3 and are not game-ready assets. No scene, renderer, web catalog, test, or gameplay code was changed for this candidate. Resume with an original, asymmetrical, non-closing ink mark that remains distinct on light and dark backgrounds at 1×; only then bind it to the confirmed target receipt and status lifetime.
