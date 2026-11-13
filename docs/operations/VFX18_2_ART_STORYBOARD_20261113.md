# VFX18.2 — light-first art refinement storyboard (2026-11-13)
Base revision: `4527fde29ce4a39dfbfb78b51b225e4b300e0f71`, PR #72 Draft; source of truth: `AGENTS.md`, `.agents/skills/tmb-vfx-art-director/SKILL.md`, `VFX18_1_EXACT_SHA_VISUAL_QA_20261113.md`. Requested by owner: "làm tiếp đẹp đi", no delegation. Scope strictly LAB, no live PvE.

## Evidence / exact defects from Godot R18.1 (run 43399027318)
Actual original 1280×720 frames inspected at 0.36, 1.55, 2.43s:
- **Charge** shows about 5 nearly straight bright incoming strands, resembles 5 chalk lines; need pulsing gradients, converging movement and smaller faded outer branches.
- **Contact** is only a tiny horizontal slash directly at the upper-left of one monster; flight is a substantial luminous shaft, so arrival lacks weight and a readable direction. Need a broad but *sharp* split/soft edge, not explosion disk, not a UI circle.
- **Orbit** currently 16 separate sharp white/cyan line strokes in a clean projected ellipse; user photo reference also has blue energy filling gaps and irregular temporal trail density. Add a very soft fluctuating **ground light atmosphere**, and 8 faint secondary motion wakes only; do not double hit actors.
- **Actor/terrain** are still toy-like Combat Lab placeholders; do not claim final in-game artistic success.

## Eight-phase target (time normalized, 3.2-second mock timeline)
0.06: diffuse thin charge motes approach hand.
0.16: two stronger curved and three weak streams lock onto tiny focused core.
0.24: compressed hot center, imminent launch; no giant rune circle.
0.33: a single **energy-shaped** sword qi detaches, feathered white core + blue trail.
0.50: moving tail uses actual flight-history Bézier with irregular brightness pulses; not opaque colored polygons.
0.70: qi contracts as it nears authorized pre-contact boundary (no sword entering monster center).
0.76: 160-190px *incisional* directional light split, fast growing tip and delayed thin counter-shear, only one mock contact. No fake damage/HP.
0.83: dispersed residual small glints and immediate fade.

Orbit same 3.2s mock:
- 16 individually staggered nonuniform primary light strokes, front/back actor depth from verified R18.1 test. 2 projected annuli rotate at unequal opposite velocities.
- ONE very soft, irregular atmospheric energy sheet under the actor, masked by angle (NOT opaque circle); 8 tiny delayed low-opacity wisps following the orbit path with real time skew.
- Native 1× 1280×720 light/actor/ground contrast and non-repeat pacing required.
- Budget: 16 primary material carrier sprites + 1 backdrop and 1 localized impact Sprite2D, max 8 minor wakes; no excessive burst particles or HDR global bloom.
- Keep exact old tests: UV tip/path alignment <=0.65px; mock contact only in single mode; orbit never creates hits; preserve inner sanctuary clearance >=119px. Add shader and bounded wake structural contract.
- Art success is not determined by test PASS. Preserve OWNER_VISUAL_PENDING, PvE HOLD, Windows/Android physical PENDING. Compare native Godot 18.1 vs 18.2 via films at 10 existing timestamps, focus 0.36/1.55/2.43. Explicitly record art deficits even on PASS.
