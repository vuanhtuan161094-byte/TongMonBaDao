# AS-CHAR-47 — Correct source-frame splitting & actual animation coverage (2026-11-14)

## Owner instructions (current authority)
- Male Kiếm Tu only, **weapon BAKED into authored image frames** (newest user decision supersedes old weapon-swapping requirement for this character); elegant silver-white ponytail, cobalt flowing ribbon, blue-white layered robes, bright blue eyes, small crimson sword-shaped forehead mark, asymmetric black-red sword.
- **All four directions** (front/right/back/left) and six actions (Idle/Walk/Attack/Cast/Hit/Death) desired: 24 clips, **no rig, no Skeleton2D/Bone2D**.
- Previous image generation sent a self-harm false positive for a non-graphic game defeat action; subsequent attempts to generate Cast/Hit often returned sword slash, which the owner rightly rejected. **Never call wrongly labeled motion a valid clip.**
- Previous sprite cutting was demonstrably incorrect; **each original GIF frame is a full independent original render, NOT a cell of a 3×3 collage**. Several source files are named `.png` but actual Pillow/byte magic is GIF, 9 or 8 frames. Don't cut the tiled preview as though it were the source.

## Exact technical fix completed
- Source 1254×1254 four-view static PNG independently cropped along **x=627, y=590** (not y=627); the seam was measured and verified free of visible foreground, preserving the top of back-view ponytail and four full bodies. Four static STAND images, not four moving Idle clips.
- Source four WALK GIFs (418×418, 9 genuine frames per direction): decoded all **36 original animation frames**, not the visual 3×3 preview. Correctly mapped front/right/back/left with front facing viewer, right to viewer's right, rear from behind and left to viewer's left; kept 9 distinct poses per direction.
- Separate attack-right **6 true source motion frames** from `chibi_mage_sword_slash_animation.png`: original source GIF has 8 frames on a black background; source frames **4 and 5 are clipped at the source's left/right VFX boundary** and were rejected rather than guessing the missing sword pixels. Selected source frame IDs `[0,1,2,3,6,7]`. A technical black-to-alpha matte was applied, still needs art QA. Includes real sword windup, overhead slash and recovery; not mislabeled Walk.
- Exported **46 individual RGBA PNG assets (4 static+36 Walk+6 Attack)** on **512×512 canvas**, shared foot anchor **(256,442)**, actor visible source around 320px, map display ~75px/zoom2 150/zoom3 225. Kept sword INSIDE frame (owner newest choice).
- Exported separate 3×3 Walk atlases by direction, 3×2 Attack-right atlas, 4-stand atlas, Godot `SpriteFrames` `animations.tres`, `actor.tscn`, independent Godot QA scene and a full standalone Godot test project.
- **126 exact-source frame/atlas/alpha/crop-geometry checks PASS**: every atlas cell binary-equal to its 512×512 exported PNG, no frame duplicate within a real 9/6 motion clip, no painted source cut at target canvas boundaries; ZIP CRC PASS. These are **STATIC/FILE checks only**, not animation beauty or actual Godot 4.7.2 engine QA.
- Actual offline QA: `qa/AS_CHAR47_FOUR_WALK_AND_ATTACK_RIGHT_QA_OFFLINE.mp4` (1280×720 four simultaneous Walk views then Attack-right), exported from extracted frames. **Not an engine screen recording.**

## Exact archived source bytes
The full ZIP exists in the owner's PERSONAL ChatGPT File Library, **NOT in GitHub**:
`/TMB-Character-Art/AS_CHAR47_KIEM_TU_CORRECT_FRAMES_4DIR_WALK_ATTACK_REVIEW.zip`
SHA256: `bee7eea386299f1a1faec0107a4c2f1ec9cc4ce924f7e337d03a42c17d0e5519`, 140 files, ZIP CRC PASS.
A standalone offline review MP4 is also in the same Library folder.
Future ChatGPT conversations MUST search Files/Library, retrieve the exact bytes, SHA verify and read `README_VI.md`, `CLIP_COVERAGE_MANIFEST.json`, `FRAME_PIVOTS.json`, `QA_RESULTS.json` and the actual original GIF sources before touching art. The ZIP ships `tools/build_as_char47_recut.py` to reproduce exports (Pillow/NumPy/SciPy), and Godot isolated preview. **Do not ask the owner to make the file again** if Library is available.

## Accurate clip coverage (DO NOT FAKE 24/24)
| Direction | Idle | Walk | Attack | Cast | Hit | Death |
|---|---|---|---|---|---|---|
| Front | static stand ONLY | 9-frame candidate | MISSING | MISSING | MISSING | MISSING |
| Right | static stand ONLY | 9-frame candidate | 6-frame candidate / alpha pending | MISSING | MISSING | MISSING |
| Back | static stand ONLY | 9-frame candidate | MISSING | MISSING | MISSING | MISSING |
| Left | static stand ONLY | 9-frame candidate | MISSING | MISSING | MISSING | MISSING |

**5 moving candidate clips of 24 slots, 4 independent static stands, 15 other source clips missing. 0/24 final production accepted.** Cast, Hit, and non-graphic defeat/Death attempts did not produce an acceptable sequence, and are intentionally NOT packaged as complete clips. No forced reused Attack/Walk, no inverted mirrored other directions, no skeletal rig.
**Godot 4.7.2 physical engine/GUI QA not run** here (engine binary not accessible in this session). Owner hand/weapon appearance/loop seam still visual-PENDING. No gameplay, SaveService, combat, VFX runtime, economy, production actors, branches or merges modified.

## Next real art tasks
1. Produce **Cast-right** through coherent stable foot stance / raised sword / free hand seal / release and recover; clear movement, no red sword slash. Inspect actual GIF first. Reject generator failures.
2. Produce **Hit-right** through impact recoil, step back, recovery, and **Death-right** through non-graphic loss of balance, kneel, settle. Author each frame from the same locked character; do NOT fake by renaming sword slash frames.
3. Produce true Attack/Cast/Hit/Death for front/back/left as independently authored perspectives and genuinely moving Idle in four views. Preserve fixed source height, sword baked and face identity.
4. Test all in official Godot 4.7.2 in isolated E: worktree and 1280×720 1×–3× zoom; correct seams, soles, hands, clipping/alpha/weapon arc. Do not expand to other disciples until this male Sword Cultivator passes owner visual approval.
