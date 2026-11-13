# VFX-CAL-00 — Cửu Thiên Lôi Kiếp CLASSIC: art brief + execution gate

Scope: independent Combat Lab ONLY. Branch: PR #72. Reference: `docs/operations/vfx_reference/TMB_VFX_Lab_4Skills_ORIGINAL.html` (first owner-liked Canvas version, skill index 3) and `VFX19_ORIGINAL_THUNDER_RESTORATION_ANALYSIS_20261113.md`.

## Owner-locked art direction
- Hierarchy: **one central white-lavender lightning**, continuous violet feathered halo, no full-screen wire web.
- Original palette: #795fff air glow, #9ba9ff mid emission, #f1faff hot spine, pastel-pink/lavender contact.
- Original timing: 1.15s + i×0.31s, six 0.34s strikes (the 3 mock targets are revisited twice); no fourth victim, no gameplay claims. Short 48ms downward reveal with a fast, peaked emission; source HTML itself used an instant full-spine flash.
- Materials: Godot CanvasItemShader Gaussian in cross-section of textured Line2D; no Forward+/HDR bloom requirement, no commercial artwork. 3 passes × up to two simultaneous primaries, one quiet residual relay at 3.065–3.225s. The radial contact mask is freshly generated at runtime using an analytic Gaussian.
- Ground and actors: muted dark soil, existing Combat Lab actor rendering, faint ritual ground light. Keep the scene readable at native 1280×720.
- Forbidden: heavy fractal forks, sky-crown clusters, opaque polygons, equal-strength sister bolts, attack event simulation, Combat V2/HP/target/SaveService/economy/V6.3 changes. No live PvE.

## 10-frame art storyboard / review checkpoints
| Timestamp | Stage | Should be visible |
|---|---|---|
| 0.20 | quiet | dark arena and caster |
| 0.60 | charge | restrained pale-violet ritual atmospheric pool |
| 1.13 | charge | quiet readiness immediately before first bolt |
| 1.22 | release | first tall white-lavender descending spine, feathered edge |
| 1.31 | contact | violent localized burst, sparse six sparks |
| 1.52 | release | second offset strike, very brief 2-bolt overlap |
| 1.85 | repeat | third spatial contact, no growing branch-web |
| 2.16 | repeat | fourth beat on already-known mock contact |
| 2.78 | final | sixth forceful strike |
| 3.12 | residual | one faint relay, shrinking violet light |

## Validation gates (not pre-claimed)
1. `godot --version` must be exactly official Godot 4.7.2, verified against SHA256-pinned engine ZIP.
2. Strict project import + scene parse + contract; quarantine any pre-existing unrelated compile shim as *ephemeral* and disclose it.
3. Real Godot Compatibility movie `--fixed-fps 60 --write-movie` 1280×720, extract the exact storyboard images; review the actual frames, not CI green alone.
4. Compare to source HTML at 1× same intent and spatial scale; source HTML has SIX distinct targets whereas the locked LAB contract has THREE, so a pixel-perfect same-target A/B is impossible without changing the mock target authorization.
5. Self-score silhouette/light/choreography/composition/contact/fade ≥4 before owner visual request; if artifacts cannot be accessed, mark FRAMES_NOT_REVIEWED.
6. `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, Windows/Android physical `PENDING_USER`. Do not start Xà Ảnh Quấn Mạch before the owner's style approval.

Status at authorship: **CODE_CANDIDATE**, visual/engine QA **UNVERIFIED** until the linked exact-SHA runner evidence actually exists. Source graphics are original code, no third-party asset reuse.
