# AS-BUILD-V3 — Three real Godot sprite replacement slots

This commit wires the **actual OneGame** isometric renderer to the twelve original
user-approved PNG sprites for `linh_forest`, `spirit_field`, and
`alchemy_hall`. All twelve exact-image SHA-verified files are now committed to PR #72.

Place the twelve RGBA PNGs from `TMB_AS_BUILD_V3_GODOT_READY_CANDIDATES.zip`
under `godot/art/reimagined_source_a_v3/` exactly as named. The image bundle
contains four independently rendered variants for each building:
`A_idle`, `A_active`, `B_idle`, `B_active`.

**Current image gate:** if a PNG is absent or cannot be imported, the renderer
automatically uses the existing verified-fallback worksite. No fake resource
counts or job starts. The active variant is selected only from committed jobs
in the canonical `BuildingState.production_state`; an idle fallback is shown
when active PNG is absent. The view is currently **presentation-only**, with
odd instances A/even instances B to allow both independently authored
orientations to be inspected. There is currently no persisted building rotation
in the save model; do not claim the direction is user-controlled.

Target draw sizes: Forest/Field 166x136; Alchemy 182x147, anchored at
`p + Vector2(0,-size.y*0.28)-size*0.5`. These are first-pass bounds and need
virtual GUI inspection for road/door and actor overlap before visual approval.
Existing five Source A buildings are not changed, nor combat, economy,
SaveService, or resource settlement. PR #72 remains Draft.

**Acceptance gates:** 12 files imported, actual Godot 1280x720 captures for A/B
and idle/active, pixel alpha/hard-edge checks, native Windows/Android
performance and hitbox tests, no roof occlusion or changed door approach.
Code-only PASS is not acceptance of those visual gates.

## 12/12 canonical image admission (2026-11-12)
All twelve PNG files were committed unchanged from the generated Godot-ready ZIP, each validated against its Git blob SHA-1. Forest, Field and Alchemy primary buildings now show their authentic illustration at normal 1x camera zoom; extra distant buildings use compact LOD until selected or zoomed in, preventing 100 large decals from overloading the renderer. `as_build_v3_canonical_art_test.gd` fails if even one image is absent. Real 7-screen GUI screenshots run through `art05-screenshot-compare.yml` on sprite changes. Windows/Android physical and screenshot visual approval remain separate gates.
