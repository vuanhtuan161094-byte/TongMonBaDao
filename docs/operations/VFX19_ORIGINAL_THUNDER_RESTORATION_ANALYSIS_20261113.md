# VFX19 — Why owner-approved first electric effect looked better (original source recovered)

Source of truth: user's original first demo **`TMB_VFX_Lab_4Skills.html`** (original 95-line self-contained HTML; stored verbatim at `docs/operations/vfx_reference/TMB_VFX_Lab_4Skills_ORIGINAL.html` for traceability). Skill index 3 = **Cửu Thiên Lôi Kiếp**, beside Vạn Độc Phi Châm, U Minh Độc Xà, Vạn Kiếm Quy Tông. This early prototype was **HTML Canvas**, 1280×720; NOT a prior official Godot render. Owner preferred its clean electricity compared with VFX19 R2.

## Grounded code comparison

| Source feature | Original HTML `vfxThunder(t,dt)` | Current `godot/labs/combat_lab/research04/thien_loi_vfx.gd` VFX19 R2 |
|--|--|--|
| Topology | One narrow 14-step sine-jitter lightning polyline per strike, then one lightweight chain pass | Hierarchical fractal 17-point bolt, up to 6 secondary branches, 2 auxiliary 'sister' bolts, sky-crown burst, many other fibers |
| Light material | `line(pts,'#795fff',thick*4,alpha*.35,28)` (purple softness), `'#9ba9ff'` thick*2, alpha*.8 blur20, `'#f1faff'` thick*.64 blur13 | Multiple separate thick translucent cyan/blue/violet polyline layers; no Canvas `shadowBlur` available in Godot Compatibility, and additive joints previously created squares |
| Rhythm | `mark=1.15+i*.31` for six strikes, ~0.34s each; immediate electrical impact / event kick and residual chain | Main 0.320–0.548 normalized of 3.2s plus two later relays; charged leader and many forks share attention; mock hit timings differ |
| Choreography | Soft ritual at center, six spatially distinct contact positions, `kick(12)`, `flash=.25`, `blast(...35,200)`; browser Canvas composite=`lighter` | Isolated Lab 3 mock targets, no camera shake/flash, smaller impacts; fixed subtle impact point |
| Separation | Simple motif, big negative space, glow blurred into halo | Many simultaneous pale lines and nested forks compete; greater stroke count does not equal greater aesthetic |

**Diagnosis**: owner complains specifically about *visual clutter*. Original wins by consistent purple/lavender/white palette, very limited lightning topology, native Canvas soft blur, strong intermittent strike/impact and screen-level camera response. VFX19's fractal branches and layers increased busyness but never reproduced that soft CSS/Canvas glow and crisp event staging. The HTML's rings do exist; it is incorrect to assert the first effect was literally 100% no circles/no geometry. Different engine and rendering also matter.

## Correct restoration direction
1. **Freeze original source exactly**; do not replace the approved motif with more random forks.
2. New isolated Godot alternate: **CLASSIC** with one 14-kink lightning spine + THREE soft Gaussian light layers + narrow white core, lavender palette; no sister channels, no sky-crown, no 6-side-fork web. Restrict active LAB victims to three per locked mock contract; recreate spacing as much as possible.
3. Distinct brightness spikes, delayed secondary little relay, 1–2 tiny spatial sparks and short local contact; clearly consider tasteful background illumination when comparing.
4. Render genuine Godot 4.7.2 1280×720 same-camera 1x comparison (original HTML is a stylistic reference, not a Godot video). Owner approval PENDING, PvE HOLD, no HP/target/SaveService changes.
5. Do NOT use Codex or claim QA success from code. The owner should watch real video to decide which direction is worth continuing.

Authoritative user rejection: VFX18.2 sword art and cluttered VFX19 R2 are **not** owner-approved. This source is a historic reference preserved to avoid visual-direction forgetting.
