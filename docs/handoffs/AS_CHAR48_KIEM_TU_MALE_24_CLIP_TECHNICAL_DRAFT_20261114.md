# AS-CHAR-48 — Kiếm Tu nam 4 hướng × 6 trạng thái: 24 clip technical draft (14/11/2026)

## Owner art authority
Owner now explicitly wants **red-black sword BAKED IN every frame**, NOT modular sword for this male Kiếm Tu. Maintain visually selected silver-white ponytail, blue ribbons, blue eyes, embroidered blue-white robes, tiny crimson sword-shaped forehead mark; retain high-res Source-A-inspired render. **ABSOLUTE NO RIG**, no bones, no code-drawn replacement body; do not merge or modify SaveService/gameplay/combat/economy.

## What is ACTUALLY produced in ChatGPT (not GitHub binaries)
A self-contained 24-slot *technical visual draft*:
- 4 directions (front, right, back, left) × 6 actions (idle, walk, attack, cast, hit, death).
- **24 real `SpriteFrames` animations**, 24 atlas PNG, 24 animated GIF review, **126 individual transparent 512×512 PNG frames**, pivot foot **(256,442)**, Godot 4.7.2 standalone project and offline 1280×720 24-way review MP4.
- 36 walk source cels (four real nine-frame loops) copied from the **verified source-extraction AS-CHAR-47**.
- Front/back/left action/idle cels extracted from **three actual 16-frame generated mixed-action GIFs**, one GIF per genuine viewpoint (not a static 4×4 contact board). Right actions extracted from an independent **8-frame right-facing mixed-action GIF**. No overlay from unrelated PNGs, no rotation of one flat sprite for opposite directions, no fake animation names.
- **276 automatic technical checks** (binary atlas-to-frame equality, presence of all real GIFs and bbox no target-frame crop) PASS. SHA256 archive integrity, ZIP CRC PASS. This is **NOT GODOT engine QA**.

### Honest pose inventory
| Direction | Idle | Walk | Attack | Cast | Hit | Death |
|---|---|---|---|---|---|---|
| Front | 4 frames / 2 unique | 9 / 9 | 4 / 4 | 5 / 4 | 5 / 4 | 6 / 6 |
| Right | 4 / 2 | 9 / 9 | 4 / 3 | **3 / 2** | **3 / 2** | 4 / 4 |
| Back | 4 / 2 | 9 / 9 | 4 / 4 | 5 / 4 | 5 / 4 | 6 / 6 |
| Left | 4 / 2 | 9 / 9 | 4 / 4 | 5 / 4 | 5 / 4 | 6 / 6 |

**WARNING:** The fact each of 24 actions has a playable file does **not** mean 24 visually polished animation clips. Clip poses still jump (some source transitions need hand-authored inbetweens), idle is sparse, and right Cast/Hit have just 2 unique poses. Real Godot 4.7.2 GPU/GUI test and owner full visual acceptance are **PENDING**. 0/24 production release accepted. Do not wire production actors into this pack until fixed. Death should hold final frame in game (non-looping), and cannot auto-return to standing without the gameplay controller deciding.

## Actual source retrieval for the NEXT CHAT
The full binary package was saved to the **owner's ChatGPT personal File Library** (not GitHub):
`/TMB-Character-Art/AS_CHAR48_KIEM_TU_MALE_24_CLIP_TECHNICAL_DRAFT_20261114.zip`
SHA-256: `0c33c99bffa9911799cf13b23d74c55a36c94764ab6b0ddd721370ef86a5f11f`
189 entries, ZIP CRC PASS, about 36.5MB.
Offline MP4 separately saved:
`/TMB-Character-Art/AS_CHAR48_ALL24_RUNNING_OFFLINE_NOT_GODOT.mp4`
In future chats first use Files search scoped to Library, read actual ZIP bytes via materialize if needed, verify SHA. Do not invent sandbox paths or claim binary source committed to GitHub. Archive includes actual generated sources, GIF, frames, atlases, Godot project, and `CLIP_COVERAGE_MANIFEST.json` + `README_VI.md`.

## Gates remaining before owner can say “DONE”
1. Inspect 24 GIF clips in high-res and at real map zoom 1–3; **prioritize right Cast, Hit, remaining sparse Idle**. Hand-author meaningful inbetween poses on the existing image identity to remove jerky pose changes, without skeletal rigs or moving whole still images in place of frame-by-frame body articulation.
2. Fix any visual alpha halo, sword-tip/cast VFX clip inherited from source GIF; retain exact original sources. Frame-crop QA PASS is only against target 512 canvas, not proof source art itself was uncut.
3. Official **Godot 4.7.2** project import, SpriteFrames 24-clip enumeration, 1280×720 GUI capture and actual animation review at 1×,2×,3×. Test all states, no frame discontinuity, sword geometry or foot sliding issues, Android 1280×720 performance. Do not use offline FFmpeg videos as Godot captures.
4. Owner art signoff first; only then allowlist visual integration into PR #72. No branch creation or merge.

Status: **TECHNICAL_24_OF_24_EXPORTED / MOTION_VISUAL_QA_OPEN / GODOT_NOT_RUN / PRODUCTION_NOT_APPROVED**.