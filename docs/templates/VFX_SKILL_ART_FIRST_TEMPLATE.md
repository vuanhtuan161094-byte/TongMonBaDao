# VFX SKILL — ART-FIRST PACKET TEMPLATE

## Contract and scope
- Source SHA / PR / branch:
- Skill ID, name, school, branch, tier, slot:
- Effect / element / shape / cap / range / cast / cooldown:
- Event receipts and status/hit authority; keep view-only until authorized:
- School-owned source paths and concurrent-writer protection:

## Hero master and narrative
- Hero image silhouette, material, first-party provenance and rights:
- Is source an ImageGen illustration, original hand painting, generated raster, or other?
- What independent frame-by-frame edits are performed? Avoid just rotating/recoloring one frame.
- Separate layers: back aura / charge / hero / impact / grit / fade:
- Cast, travel, impact and fade timecode storyboard (8-12):

## Atlas manifest
| Texture | Rows x cols | px per frame | Frames | Pivot | Alpha | Blend/layer |
| Hero | | | | | | |
| Charge | | | | | | |
| Impact | | | | | | |
Original master + generator + output PNG/WebP and color/alpha QA.
Generated concept posters cannot substitute for production assets or Godot evidence.

## Godot visual contract
- Dedicated scene/script and source texture paths:
- Exact 1280x720 native movie, GIF and >=8 checkpoint frames:
- Actor/target silhouette visibility and correct hit semantics:
- No skeletal rig, Codex, new branch, merge or unauthorized live gameplay edits.

## QA outcome
- Exact SHA, GitHub Actions run and artifact ID:
- Strict import, parse, contract outcomes:
- 1x visual scores (/5): silhouette, material, motion, composition, contact, fade, uniqueness:
- Visual issues by timecode and corrective action:
- Owner visual gate: PENDING / EXPLICITLY APPROVED:
- PvE gate: HOLD until separately instructed:


## Mandatory V4 three-clock timeline (complete BEFORE drawing)

| Event / phase | Canonical catalogue value or exact real Combat V2 receipt | LAB-only simulation? | VFX local start/end seconds | Origin/target anchor and moving-follow rule | Status/confidence |
| --- | --- | --- | --- | --- | --- |
| Cast start / charge | | | | | |
| Cast end / release | | | | | |
| Travel / zone formation (if any) | | | | | |
| Impact / mark / guard receipt | | | | | |
| Status sustain / expiration (if any) | | | | | |
| Residual light / visual cleanup | | | | | |
| QA pre-roll / demo replay (not gameplay) | | | | | |

State cast_time, cooldown, projectile_speed, effect, duration and hit_count separately; distinguish actual receipts from LAB movie times. UNKNOWN receipt => RUNTIME_MAPPING_PENDING and view-only. Record visual overlap with next action and reason for each afterglow length. Persistent guard/mark is not a longer cast.

## Motion-derived pose budget and source fidelity

- Original transparent hero master path, origin/licence, dimensions, **visible-alpha bounds at 1×**:
- Per-layer pose list with key silhouettes and what really grows, bends, twists, condenses, splits, hits and fades:
- Frame count, authored key poses, in-between/holds, atlas FPS and displayed time **per layer** (no arbitrary fixed 8–12 requirement):
- Palette and light hierarchy: opaque MIX body, hot focused ADD highlight, restrained soft bloom, negative space:
- First-party master/atlas durability: committed source or long-lived object-storage URI, SHA and reproducible bake tool; artifact expiry:
- Reference and equivalent 1× game-space crop comparison; provenance/rights:
- Do not use frame-byte hashes alone to assert animation quality; no rig.

## G3.5 mandatory 3-frame actual Godot preflight STOP

| Frame (1× / 1280×720) | Timestamp | Evidence location | Source-to-Godot match | Pass/Fail and repair |
| --- | --- | --- | --- | --- |
| Charge / formation | | | | |
| Energy peak / main silhouette | | | | |
| Contact **on moving target** | | | | |

- Compare original hero silhouette, hot core, saturation, alpha, hand/ground contact and actor occlusion on true gameplay scale and bright/dark terrain.
- If any frame is dull, candle-like, flat HUD geometry, disconnected from palm or hides target: **STOP G3.5**, repair hero art; do NOT progress to expensive full movie. Automated capture is technical evidence, not automated art approval.
- Preflight review: PASS / FAIL / NOT_EXECUTED; reviewer/time; open defects and exact owner feedback:

## G4–G7 post-preflight evidence

- Motion cases: stationary target; moving left/right; multiple asynchronous moving targets; fixed zone vs homing policy; screenshots/video:
- Actual Godot 4.7.2 Compatibility MP4 1280×720, GIF/ZIP, continuous playback reviewed and >=12 useful frame timestamps (or justified fewer for short clip):
- Separate visual self-review (/5 each): silhouette, material, local-light/color purity, motion continuity, event timing, moving-contact, actor visibility/layering, fade, school identity. Each critical item >=4/5 before owner review:
- Technical QA: strict import/parse/focused, frame integrity, source commit exact SHA, workflow/run/artifact paths; never infer device fps from fixed movie:
- Distinct statuses: ART_SELF_QA_PASS/REWORK; GODOT_TECH_PASS/NOT_RUN/FAIL; OWNER_VISUAL_APPROVED/PENDING/REJECTED; PVE_INTEGRATION_HOLD; PHYSICAL_QA_PENDING:
- Owner approved revision SHA and immutable protected art; if user pivots, keep prior unresolved revision as REWORK/PENDING, not approved:
- Production measurements (when actually observed): G3.5 attempts, full renders, rework count, owner-approved masters per session; no invented work time:


## V4.1 efficient QA frame budget (mandatory from 2026-11-16)

| Quantity | Number / reason / evidence |
| --- | --- |
| **Authored atlas key poses** (not encoded frames) | |
| Atlas dimensions and uncompressed RGBA8 + loading/pooling assumptions | |
| True native Godot G3.5 preflight clip + charge / peak / moving contact timestamps | |
| G3.5 1× art STOP result (including cropped-square/alpha defect) | |
| **Attack-only** full-motion clip start/fade; native 1280×720 fps, frames and >=12 useful inspection points when warranted | |
| Long-lived status visual probe at start/mid/expiry (2–4 exact native stills or focused deterministic test); mock versus actual receipt | |
| Reason for optional full combined film (e.g. owner 11s / full regression) or SKIPPED | |
| Actual Actions run / output bytes / device FPS separately (NO invented throughput) | |

Do not export an 8–11s status-loop movie at **every** art iteration if the actual attack is only ~3s; do not shortcut genuine motion inspection or required long-duration phase behavior. Fixed 60 FPS movie frames are not sprite textures or measured physical GPU FPS. Every new skill must still be owner-reviewed and remain PvE HOLD until a separate authorization.
