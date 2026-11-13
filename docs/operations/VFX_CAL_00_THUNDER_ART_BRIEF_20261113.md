# VFX-CAL-00 — Cửu Thiên Lôi Kiếp CLASSIC: art brief + execution gate

Scope: independent Combat Lab ONLY. Branch: PR #72. Reference: `docs/operations/vfx_reference/TMB_VFX_Lab_4Skills_ORIGINAL.html` (first owner-liked Canvas version, skill index 3) and `VFX19_ORIGINAL_THUNDER_RESTORATION_ANALYSIS_20261113.md`.

## Owner-locked art direction
- Hierarchy: **one central white-lavender lightning**, continuous violet feathered halo, no full-screen wire web.
- Original palette: #795fff air glow, #9ba9ff mid emission, #f1faff hot spine, pastel-pink/lavender contact.
- Original timing: 1.15s + i×0.31s, six 0.34s strikes (the 3 mock targets are revisited twice); no fourth victim, no gameplay claims. Short 48ms downward reveal with a fast, peaked emission; source HTML itself used an instant full-spine flash.
- Materials (R4): an original runtime-baked RGBA ImageTexture per full polyline, one Sprite2D with additive CanvasItemMaterial; continuous analytic distance-to-path Gaussian (outer violet + middle lavender + narrow white core). No Line2D joint geometry, Forward+ HDR, third-party art, gameplay event or external renderer dependency. At most two main strikes overlap and one quiet relay appears at 3.065–3.225s; contact/background use runtime Gaussian radial ImageTexture.
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

## Validation gates (required)
1. `godot --version` must be exactly official Godot 4.7.2, verified against SHA256-pinned engine ZIP.
2. Strict project import + scene parse + contract; quarantine any pre-existing unrelated compile shim as *ephemeral* and disclose it.
3. Real Godot Compatibility movie `--fixed-fps 60 --write-movie` 1280×720, extract the exact storyboard images; review the actual frames, not CI green alone.
4. Compare to source HTML at 1× same intent and spatial scale; source HTML has SIX distinct targets whereas the locked LAB contract has THREE, so a pixel-perfect same-target A/B is impossible without changing the mock target authorization.
5. Self-score silhouette/light/choreography/composition/contact/fade ≥4 before owner visual request; if artifacts cannot be accessed, mark FRAMES_NOT_REVIEWED.
6. `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, Windows/Android physical `PENDING_USER`. Do not start Xà Ảnh Quấn Mạch before the owner's style approval.

## Executed evidence — R4 self-QA (2026-11-13)

- **Exact code SHA tested:** `19b749353fe41493b745d3a3cc970fcf00138170`; [official workflow run #43465709619](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43465709619), artifact `vfx-cal00-classic-thunder-19b749353fe41493b745d3a3cc970fcf00138170`. Runner Godot `4.7.2.stable.official.ed1daf0bf`. Strict import/parse/isolated contract **PASS** (`VFX_CAL00_THUNDER_FOCUSED_RESULT=PASS failures=0`). Movie captured with xvfb official Godot `--write-movie --fixed-fps 60`, converted to MP4: `1280×720`, `60/1` encoded FPS, duration `4.650s`; ten PNG timestamps and source original HTML in artifact.
- **Source HTML comparison:** original `TMB_VFX_Lab_4Skills_ORIGINAL.html` skill #4 rendered deterministically in Chromium Canvas at `t=1.31s` and compared to genuine Godot `frame-1.31.png` at native 1280×720 each. Original has 6 targets; isolated R4 has 3 permitted mock contacts revisited twice; camera/actor layout and terrain are not pixel-identical.
- **Self-rework history:** R1 too little luminous mass; R2 (`9cca7ddb...`) CI PASS but gross triangular wide-Line2D shader joint artifacts => **REJECTED**. R3 (`016bacd8...`) continuous distance-to-whole-path sprites => seam artifacts gone; R4 (`19b74935...`) strengthened local purple-white impact, restrained 2px stage kick and ritual legibility. Actual R4 video and 10-frame sheet reviewed, no triangle wedges or 6-fork web.
- **Visual self-assessment (not owner approval):** silhouette 4/5; soft-light material 4/5; 6-beat rhythm 4/5; sparse composition 4/5; local impact 4/5; fade 4/5. Main remaining tradeoff: **Godot LAB is darker and smaller-scale in its ritual than original HTML** and has fewer mock targets; owner should choose style direction before any school production.
- **QA scope only:** no integrated cumulative gameplay QA from this isolated VFX calibration; Windows and Android hardware performance **PENDING USER**. Fixed-fps movie does not measure live FPS. Unrelated `v63-quyen-doc-matrix` workflow remains failing outside this VFX packet; never interpret this as an R4 VFX failure nor as a cumulative PASS.
- **Required human gate:** `OWNER_VISUAL_PENDING`; `PVE_INTEGRATION_HOLD`, `V6.3 OFF`. **Do not begin Xà Ảnh Quấn Mạch before owner explicitly approves this light style**, and never integrate live PvE without a separate authorization.

All graphics are original procedural code; no proprietary JX/Source A art copied.
