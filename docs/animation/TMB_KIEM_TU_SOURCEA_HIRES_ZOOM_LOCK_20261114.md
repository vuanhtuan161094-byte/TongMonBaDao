# TMB — Kiếm Tu / Source-A-resolution high-res lock V1 (2026-11-14)

**AUTHORITY:** latest owner direction on PR #72. The owner approved the *high-detail silver-haired Kiếm Tu appearance* and asked ChatGPT to implement without Codex creating primitive characters. The precise art-source SHA and footage are stored below. **No rig, Skeleton2D, Bone2D or skeletal animation** for new character assets.

## Locked production METHOD (not visual-animation approval)

1. Preserve owner-selected male Kiếm Tu identity: long silver-white high ponytail, deep-blue flowing ribbons, blue eyes, white/navy-indigo/silver multi-layer embroidered robe, blue crown and belt gems, adult 3–3.5-head chibi silhouette; **small centered crimson sword-shaped forehead sect mark** on face-visible views. Other 12-school palettes and unique motifs remain as approved.
2. Source A is **not** sharper due to a magic shader or an empty 768px canvas. Real asset manifest: `v5_sa_male_body_1110201` uses 768×768 working canvas, **263×258 actual cropped frame**, 30 fps with 48 stand, 24 walk, 29 attack frames. Some other Source A packages only have 110×135 cropped frames. Its proven technique: retain detailed source frames and display them at reduced game scale. Preserve provenance and do not copy Source A proprietary player art into new character packs.
3. **New Kiếm Tu authored/export resolution**: target >=320 px actual *body visible height* per frame (not canvas size), preferably retain original ~660px owner reference. Use a common **256×400 transparent export canvas**, same **foot pivot (128,356)** for four true authored views. Larger attack/weapon FX may use additional canvas margin with explicit pivot. **Map character display 75 px; zoom 1×/2×/3× -> 75/150/225 px**, never exceed the 320px body source at intended zoom 3×. No mandatory 128×128 master and no early destructive downsample.
4. **Authoring modular**: base+face/hair+outfit optionally separated *at source*, but offline-composite body/outfit per pose/direction for map runtime. The red-black asymmetric jagged owner sword must be **its own transparent weapon item**, with front/back occlusion layers and per-frame, per-direction **hand grip socket**; body atlas must not change when weapon is swapped. Keep VFX separate. Existing sword-baked concept Walk frames **cannot** be promoted as modular animation.
5. **Animation quality**: every actual Walk frame is newly authored with unambiguous left-contact -> passing -> right-contact -> passing, opposing arms, clothing/hair follow-through and planted feet. 16–24 real frames over about 0.8 s is a *quality target*, NOT an automatic minimum/PASS. Every Attack stroke must have wind-up, strike impact, and recovery plus matching sword arc; authored four directions independently, not rotating one sprite. No global bobbing/mirroring or code geometric character generation passed off as real art.
6. Godot 4.7.2 Compatibility: use baked SpriteFrames for body and independently swappable Sword Sprite2D/AnimatedSprite2D; compare **Nearest vs Linear** on actual high-res source with zoom and camera. No rig. No changes to SaveService, combat/economy, VFX source, production game visuals until engine+owner gates clear. PR #72 remains Draft, no branch or merge.

## Actual current-turn AS-CHAR-42 packet (source & evidence)

Binary artifact stored in the **original ChatGPT conversation, not in this repository**: `AS_CHAR42_KIEM_TU_HIRES_ZOOM_V1_20261114.zip`.
- ZIP **SHA-256 `2816047cc0fc374d1b677622bff7090f365bdd6e761ee62501a72394814a64bc`**, 61 entries, CRC PASS. **Do not claim the ZIP or PNGs are committed to GitHub**; download the original ZIP and unpack into an isolated E: QA workspace to use its original binary references.
- Owner four-direction **UNARMED** source exact SHA `ee0f8d46f34565dd6a1eb87f126135e7b4bed2a7cf573b085b64c8bf88878105` (2048×682); owner red-black sword original SHA `53389305f18549a5714c3fb5fc8a2fef54322cc4101dc890cb7a46ed4e8426c9` (736×981).
- V1 exported **4 independent 320px-visible body PNGs**, 256×400 canvas and identical foot anchor; **4 independent red-black sword overlays**, 4 cyan recolor *technical demonstration* overlays; SHA-256 manifest and grip test coordinates, raw unmodified owner references, image quality checks.
- Static images: `output/previews/ZOOM_1x_2x_3x_NEAREST_NOT_GODOT.png`, `HIRES_FOUR_DIRECTIONS_WEAPON_SWAP.png`; 4-view weapon-swap GIF **STATIC DIRECTION, not Walk**.
- Motion zoom preview `MOTION_WALK_R2_SOURCE_HIGHRES_ZOOM_1x_2x_3x_CONCEPT.gif` is adapted from AS-CHAR-41's 9 actual 421×415 PNG frames with ~375px actor size, and is **SWORD-BAKED CONCEPT** (not swappable). It only demonstrates high-res zoom retention; the new clean modular Walk has **not** been authored.
- `output/godot_lab/`: standalone Godot 4.7.2 project, `D` cycle 4 views, `E` swap weapon (none/red-black/cyan demo), `1/2/3` change zoom, `F` toggle texture filter. Body and sword are independent Sprite2D (NO rig).
- **Python validator 8/8 PASS**, ZIP CRC PASS. **ENGINE: NOT RUN in the generating environment** (Godot executable missing); **ART: visual approach candidate**, modular Walk/Attack **NOT APPROVED**, production **BLOCKED**. Preview zoom is Python simulation **not a Godot screenshot**.

## Quality and release gate

G0: owner-approved identity and exact original SHA preserved (verified).
G1: 320px body PNG, 4 direction screenshots, independent weapon overlays, zoom previews and Python tests (technical PASS).
G2: official Godot 4.7.2 screenshots zoom 1/2/3 in isolated E: checkout, no clipping, correct grip + four views, performance test for 30 actors (PENDING).
G3: 8–24 individually authored **unarmed** Walk frames at true >=320px body source height, consistent identity, garment/hair/pivots; same walk with at least two swappable sword item skins and original separate layer; real GIF/video and owner visual approval (PENDING).
G4: four directions, Attack/Cast/Hit/Death, Godot/Android visual acceptance, only then production import (PENDING).

**Nothing in this document authorizes skeletal rigging or mass-creation of 48 unverified clips.**