# AS-BUILD-V3 — Three real Godot sprite replacement slots

This commit wires the **actual OneGame** isometric renderer to the twelve existing
user-approved sprite candidates for `linh_forest`, `spirit_field`, and
`alchemy_hall`. It does **not** claim that images have been uploaded to GitHub.

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
