# AS-CHAR-43 — Male Kiếm Tu right-Walk map integration (technical pilot, 2026-11-14)

## Owner decision / authorized scope
Owner approved the silver-haired high-res Kiếm Tu male's visible Walk and requested immediate in-game integration. Slight hand art defect still needs refinement. **Absolute NO rig** for all new work. Do not replace prior Source A male/female actors indiscriminately, do not alter gameplay, SaveService, combat, currencies, damage or V6.3 gate.

## Exact original
Uploaded user GIF `Kiếm sĩ tóc bạc bước đi pixel art(1).gif`, 508×337, **9 frames × 120ms**, SHA-256 `15b78700836f3d519fbe916ae819f20c9d07d3821b6c8917bb84df99f950b6ac`. The embedded grey checkerboard is fully opaque (alpha 255), so it was automatically segmented to 9 separate transparent RGBA PNGs and a 1536×1152 atlas (frame 512×384; original actor visible ≈328 px). Transparent contact was visually inspected on navy background. **That masking process can leave fine fringe / gaps and is not a native pixel-painted correction.**

Owner-selected red-black asymmetric sword was independently composited via a source weapon PNG and hand socket pilot positions. Cyan coloring is **technical swap demo only**, not an item/skin approval. The sword is truly separate from body atlas, but gripping/occlusion remain visual pending. No new hand-painted Attack/other-direction Walk is claimed.

## Implementation
Source (technical view adapter) committed in PR #72:
- `godot/src/presentation/p3/disciple_source_a_visual_pool.gd`: guarded optional actor scene `res://assets/disciples/kiem_tu_male_v1/actor.tscn`, **male with confirmed Sword branch ID only**. Existing Source A actor always used otherwise.
- `godot/src/presentation/p3/modular_disciple_actor.gd`: reads optional high-res body's actual visible pixel height when explicitly tagged `pilot_only`, respects individual stand directions, supports right Walk while returning static stand for other un-authored Walk directions. Legacy Source A untagged actor behavior preserved.
- Binary source pack and scene/textures: `AS_CHAR43_GAME_INTEGRATION_20261114.zip` stored as conversation attachment and personal Library (see Issue #77). The ZIP contains `game_patch/godot/assets/disciples/kiem_tu_male_v1/` and `game_patch/godot/labs/character_family/as_char43_kiem_tu_game_preview/` plus one-click `INSTALL_AND_PREVIEW_E.cmd`. **Binary asset pixels are NOT in GitHub** until the installer copies the files into the real E: checkout.

One-click installer checks the correct Windows E: path and existing branch, only writes new isolated files, refuses conflicts, does not touch dirty checkout files or save data. It opens a real Godot preview if official 4.7.2 executable exists. **This chat cannot execute software on owner's E drive.**

## Verification and gates
- 8/8 focused local Python asset integrity tests PASS; PNG alpha verified; 9 distinct source frames; 2 separate weapon atlases, body unchanged after weapon item swap; no new rig; pose/alpha contact on dark inspected.
- Offline side-by-side video PREVIEW produced, **not a Godot screenshot**; do not label engine/GUI PASS.
- Godot 4.7.2 exact-SHA import/playback, GPU zoom, source compatibility and physical Android still **PENDING**.
- The Sword branch V6.3 feature gate remains OFF; no existing unrelated male disciple will be re-identified as Kiếm Tu because of this art pack.
- Stand front/right/back/left: four genuine high-res static views; Walk **RIGHT ONLY**. Animation in other directions and attack/cast/hit/death still **PENDING**. The owner-liked Walk has minor hand rendering issue; keep **ART_HAND_PENDING**, do not claim final full-set completion.

## Art/release status
`ASSET_SOURCE_ALPHA_PREVIEW_PASS`, `MODULAR_SWAP_TECH_PASS`, `SOURCE_VIEW_ADAPTER_STAGED`, `GODOT_QA_PENDING`, `HAND_ART_PENDING`, `PRODUCTION_RELEASE_PENDING`. Do not bulk-expand or merge.
