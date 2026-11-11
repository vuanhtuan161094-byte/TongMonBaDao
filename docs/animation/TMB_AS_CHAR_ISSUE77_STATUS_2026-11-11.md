# Issue #77 — AS-CHAR-01 → AS-CHAR-05 implementation status

Date: 2026-11-11  
PR #72 branch: integration/pve-p0-playable-ui-20261103  
Latest PR HEAD before this packet: 2d05b619e82c0010c58254107448be35303b0917  
Status: PARTIAL IMPLEMENTATION — OWNER VISUAL ACCEPTANCE PENDING

## Completed in this packet

- Read Issue #77 and all five Nữ Độc Tu process/asset lessons.
- Added the unified art bible and a separate review scene under godot/labs/character_family/.
- Added an asset catalog/schema, source and SHA manifest, dependency-free validator, deterministic Source A actor package matrix, and focused Python tests.
- Added two independent static 2×2 turnarounds for review: male swordsman and female healer. Both are CANDIDATE_NOT_APPROVED, with provenance and edge findings recorded.
- The isolated preview can play the six existing stored Nữ atlas sequences and holds new candidates still. It does not change main scene, project.godot, P3.2 actor code, combat, gameplay, or SaveService.
- Source A inventory covers all seven in-project actor packages and does not assign unverified identities. The monster stays a monster; the Boss package stays a candidate.

## Source and visual status

| Asset | Status | Evidence / limit |
|---|---|---|
| Owner-locked Nữ Độc Tu master | BLOCKED_SOURCE_ART | Expected SHA-256 435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118; exact file not located in checked directories. |
| Six Nữ Độc Tu atlas sheets | VERIFIED_FILE only | Local sheet hashes match the existing manifest. Original video package is absent; direction is three-quarter-right, not a four-view master. |
| Male sword turnaround | CANDIDATE_NOT_APPROVED | Independent text-generated static turnaround. Minor colored contour speckles remain; no layers or clips. |
| Female healer turnaround | CANDIDATE_NOT_APPROVED | Independent static turnaround, separate identity. Two edge alpha pixels remain; no layers or clips. |
| Source A actor packages | PROJECT_ASSET_PRESENT | Seven asset.json packages recorded in source_a_asset_matrix.json. Unknown roles remain unknown; monster/Boss candidates are not disciples. |
| P3.2 shared actor | SCAFFOLD_PRESENT | Modular Skeleton2D and procedural idle/walk source exist. This is not proof that this family’s art or motion has passed. |

## Stage gates

- AS-CHAR-01: PARTIAL. Existing assets, hashes, roles, statuses and boundaries are cataloged; some source images and packages remain unavailable.
- AS-CHAR-02: PARTIAL / OWNER VISUAL PENDING. Two independent static candidates exist; the locked Poison Tu master is missing and the family lineup is not approved.
- AS-CHAR-03: BLOCKED. No editable layer source exists for the locked female or candidates. Candidate walk/cast/attack/hit/death are not authored. No motion GIF/video is claimed.
- AS-CHAR-04: NOT STARTED. Do not build the 12-appearance set or 30-actor lineup before AS-02 and AS-03 approval.
- AS-CHAR-05: NOT STARTED. No production integration. The only new scene is review-only.

## QA evidence

- Latest-head Python tests: 6/6 PASS, exit 0 on 2d05b619.
- Latest-head catalog validator: PASS, exit 0. It checks manifest paths, six existing Nữ atlas sheet hashes, candidate SHA/dimensions/RGBA, and candidate status restrictions.
- Godot official binary: 4.7.2.stable.official.ed1daf0bf.
- Godot headless import and explicit review-scene smoke passed on the preceding base d0ed880d; the preview logged the real Nữ Idle atlas sequence (60 stored frames at 10 fps) and AS_CHAR_FAMILY_PREVIEW_READY. Import emitted nonfatal Windows certificate-store/editor-profile warnings.
- A separate GUI run on d0ed880d opened a responsive window with Intel Iris Plus OpenGL 3.3.0 Compatibility; process memory sampled at 267 MiB. The CUA window inventory could not see the Godot window, so there is no genuine screenshot, GUI input proof, FPS measurement, or exact-latest-head Godot run.
- One initial CLI invocation omitted Godot's explicit --scene option and launched the project’s default P3 scene. It logged “P3 live runtime exit save failed: 12”; the expected per-project user data directory was absent and no successful save write was observed. This is recorded as a failed setup attempt, not a test pass. The subsequent explicit review-scene smoke did not produce this message.
- No GIF/video is provided because no new character motion was authored. The two turnaround sheets are static.

These results do not grant owner visual acceptance and do not prove Windows/Android device quality. Re-run the official Godot smoke on the exact latest commit after the current GUI process has been closed, then capture the real 1280×720 GUI before claiming the visual gate.


## Addendum — owner V4 archive found (2026-11-11)

The V4 package was found under D:\Downloads. Outer ZIP SHA-256: 5e7f4b96c3416568722e59fc3a0fc4f02de0b1d486d136989d5f83f2f2e315915. Inner alpha-review ZIP SHA-256: 708bdfcab74d2842355061a4553be22fc207c6703cab13063efcb7b7ac047979. The owner-approved master matches the locked SHA exactly. The earlier BLOCKED_SOURCE_ART status is superseded for the female master.

The ECO-07 virtual-GUI archive has seven 1280×720 UI screenshots and one metrics JSON; it contains no character master or animation. The UI has a coherent dark-green/cream/gold layout, but it is not a character style or animation sample.

This packet stores the female master, six four-direction atlases, four real GIF motion previews, per-file SHA-256 manifest, and visible GitHub preview README in godot/labs/character_family/assets/nu_doc_tu_v4_candidate/. Atlas/GIF status remains candidate only. Cast/Attack contain baked green light, Godot is not yet run, and raw source action images are missing from the supplied ZIP.

The all-school visual guide records all 12 schools and 36 branches but is art guidance only. Nine schools are planning-only in the current authority; the other three runtime catalogues do not prove school-specific sprite support. Source A converted packages remain classified by actual metadata only.

The focused GitHub workflow will run after commit. The official Windows Godot executable exists at E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe, but Windows process inventory returned Access denied, so no local Godot instance was started. Exact workflow result and any Windows GUI/physical acceptance remain pending.
