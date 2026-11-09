# TMB Combat Art V4 — Nữ Độc Tu, one-source four-way QA (2026-11-09)

## Owner-approved immutable character

Approved four-view PNG in conversation at 2026-11-09 10:28: `image(20261109-102800).png` (1448×1086 RGBA). SHA256: `435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118`. **Do not replace with subsequent purple characters, AI concept boards or a changed face/robe.** Female identity/costume approved; neck alignment remains a separate anatomical QA item.

## Produced independently in the artifact runtime (NOT committed binary content)

The external deliverable `TMB_V4_Nu_Doc_Tu_4Huong_Proto_QA_20261109.zip` has SHA256 `e536b732570e219b4f72c56250e644c96cb7d49e223e8382df0593ce36fdbab8` and contains the approved source, registered front/left/right/back PNGs, generated idle/walk/cast/attack atlases, Python generator, deterministic hashes, QA report, visual contact sheet, MP4 generated preview and standalone Godot viewer project source. **These binaries are NOT yet in this GitHub repository**; the chat file was not automatically uploaded to GitHub. Never claim that Godot/CI has imported them from PR #72.

Layout: 160×192 RGBA per frame, logical foot pivot (80,179), four authentic image views; prototype output includes 4×(8 Idle + 12 Walk + 12 Cast + 12 Attack) = 176 registered frame cells. One shared pixel-quantized palette from the master, no independently AI-generated frame redraws. The non-rigid whole-sprite deformation is only a deterministic **technical motion proxy**, not a correct anatomical 2D rig. VFX, weapon and magic circles stay separate.

## Actual QA

| Gate | Result | Evidence |
|---|---|---|
| Source identity SHA256 and 1448×1086 | PASS locally | Reproducible generator aborts on mismatch |
| 4 orientations, frame dimensions, empty atlas margins, fixed foot row | PASS locally | `qa_report.json` |
| Numeric phase continuity | PASS locally | 16 direction×clip assertions; maximum adjacent-frame changed-pixel fraction under 13% |
| Idle motion | PARTIAL | Subtle motion; not artistically accepted |
| Walk foot lift/alternating legs | **FAIL_VISUAL** | Whole-sprite deformation cannot provide authentic leg action |
| Cast hand/key poses | **FAIL_VISUAL** | Spell anticipation/release insufficiently differentiated |
| Attack anticipation/key hit/return | **FAIL_VISUAL** | Too similar to idle, no authentic arm articulation |
| Neck–shoulder correction | PENDING | Approved master has slight misalignment; do not silently change identity |
| Official Godot 4.7.2 parse/import/GUI video | **NOT RUN** | No matching official Godot executable in current isolated runtime; GitHub Actions could not import absent asset binaries |
| Production combat Save/V6.3 integration | **NOT PERFORMED** | Intentionally preserved |

### Decision

**V4 female identity: APPROVED. Technical registered 4-view atlas pack: BUILT, static continuity QA PASS. Playable game animation: REJECTED / NOT COMPLETE.** Do not replace V3, add these files to production renderer, or say "176 frames means finished." To complete: create four-view independent anatomically drawn layers/rig (including correction of neck), genuine leg and hand key poses, continuous animation with exact pivot, then import into official Godot 4.7.2 at original SHA and capture a real combat GUI video with the V6.3 skill events. Only author after art QA proves meaningful silhouette changes and no seams.

No gameplay, balance, simulation, SaveService, existing V3 textures, GitHub workflows, or PR merge changed in this note.
