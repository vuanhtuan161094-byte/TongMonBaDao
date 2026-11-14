# VIS-07 original environment asset register
Owner instruction 2026-11-14: replace displayed Source A main hall and gradually retire Source A map environment. All SVGs in this folder are **new TMB-original deterministic code-drawn art**, not extracted or traced Source A, not repainted Source A pixels and not an ImageGen-painted production sprite. Authoring source: this commit's SVG paths/gradients. Artistic acceptance: **PENDING owner**.

## Live replacement map
- `hall_isometric.svg`: main-map landmark and real hall operation illustration (Source A main_hall/510052.png is no longer used as a hall display).
- `mine_isometric.svg`: mine main-map worksite + real mine operation panel; supersedes old MAP-D2 candidate drawing.
- `stone_{lane,court,rune,edge}.svg`: runtime replacements for historical Source A route and stone textures without changing terrain cells or navigation.
- `tree_{pine,blossom,bamboo}.svg` and `rock_garden.svg`: replace historical Source A ENV01 vegetation render textures, preserving existing placement/depth layout.

The SHA-pinned original Source A bytes and their verification registry remain untouched for historical verification/rollback. Assets **not yet replaced**: residence, guidance, warehouse, forge map sprites; existing approved/independent forest/field/alchemy building variants; Source A character sprites (different pipeline). No gameplay/save/loot/building authority, collision/footprints, actor stats or routes changed. Existing Source A manifest QA validates original historical bytes, not current rendered source; `vis07_original_environment_test.gd` verifies new display provenance.

Mobile performance hypothesis: small fixed vector textures imported as Texture2D, no per-frame shader or particles. Android frame-time evidence pending. If the owner wants painterly isometric architecture rather than authored vector v1, this code-art iteration is a replaceable prototype, not a claim of hand-painted asset quality.
