# PAF05 R4 — Godot Native Technical PASS, Visual Art STOP (17 Nov 2026)

Owner rejected PAF05 R3 for image compositing and whole-image sinusoidal warp. R4 is a real Godot 4.7.2 view-only LAB with independent moving tapered ribbon segments, an internally advecting energy shader, real CPUParticles2D and per-target follow. R2 scene remains intact. R4 technical implementation is NOT a finished visual art approval.

## Canonical mechanics (not changed)
ID tmb.skill.talisman.phong_an_phu.ultimate.human; Wind / mark / circle radius2.1 / cap3, cast0.9s, cooldown23s, status7s, projectile speed0. LAB contact 1.33s is simulated, not a Combat V2 real receipt. No gameplay damage/status/SaveService/AI/PvE/V6.3 writes, no rig.

## Reproducible Godot source
- Scene: godot/labs/combat_lab/talisman15/r4/thai_huyen_phong_gioi_r4.tscn
- Script and shader in same directory.
- Focused QA: godot/tests/labs/combat_lab/vfx_paf05_r4_contract_test.gd
- GitHub workflow: .github/workflows/vfx-v4-paf05-r4-native.yml

## Exact SHA QA
1. R4 first commit 63496c5b4dca252b9573015088cf8fdecbc4bebf: Godot FAILED. A concave moving ribbon self-intersected; strict 1280x720 native movie rejected polygons with "triangulation failed". Simple parse/logic tests had passed, illustrating why native rendering gate is compulsory.
2. Repair SHA 788939db10ad97498c21d0c501d16d3a68e5880b: GitHub Actions run https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44057439802 native TECH PASS after convex segment mesh fix.
3. Polish SHA 76013057ac2c8b97f807541989a88eae1f2bd9f5: GitHub Actions run https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44058404396 TECH PASS; Godot 4.7.2 Compatibility / Linux llvmpipe, 1280x720 @ encoded 60fps for 180 frames (3.0s), source/focused/import/native video/logs and 5 phase frames. Frame times .42, 1.16, 1.49, 2.25, 2.65 seconds. Native CPU render 2.38 ms/frame, GPU render 7.28 ms/frame in runner; these are NOT physical Windows/Android or crowded-combat FPS.

## Native 1x art review — FAIL (do not conflate with green CI)
Movement is now actual runtime dynamics rather than moving/warping a single poster; the 64px green particle blobs were reduced to small motes. HOWEVER, four principal wind silhouettes still look like simplistic turquoise geometric curved leaves rather than living painted wind energy. The ornate golden central seal and painterly translucency from the owner-liked R3 source are not faithfully represented. The charge is too weak, field lacks striking hero motif, and contact/icon remain generic. Polish reduced excessive blurred blobs but also made the energy visually thinner. R4 original code uses no R3 high-resolution transparent painted master; source should not be misrepresented as an accepted independent painted VFX atlas.

Internal 1x jade-pixel ROI (x600-1070,y310-620) t .42=0, t1.16=6640, t1.49=7904, t2.25=3987, t2.65=241; brightness evidence only, not visual beauty.

Statuses: G0 contract VERIFIED; G3 original painterly source master UNRESOLVED; G3.5 actual Godot TECH PASS, ART SELF FAIL; G3.7 semantic silhouette FAIL; G5 native 3s MP4 TECH PASS; G7 exact-SHA TECH PASS; OWNER VISUAL PENDING / ART REWORK REQUIRED; G8 PvE HOLD; physical devices PENDING. No owner art approval is claimed.

Next revision must first create isolated full-size transparent feather/golden-seal masters and true changing key poses (not thresholded poster crop), then layer directional interior light transport / localized impact and real particles. Repeat real native 1x charge/peak/moving-contact STOP gate before full production. Do not merely enlarge a polygon or increase halo.
