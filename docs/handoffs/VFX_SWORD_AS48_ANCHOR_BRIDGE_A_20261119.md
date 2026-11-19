# TMB — SWORD AS48 × HUMAN VFX BRIDGE A · IMPLEMENTATION HANDOFF

**Decision:** Owner chose architecture A (separate character source and VFX; connect only by frame anchors and read-only events) and requested a single Kiếm Tu Human proof **before** expanding 12-school VFX. Asset bulk production is being handled independently; **do not edit character assets**.

**PR:** Draft #72, branch integration/pve-p0-playable-ui-20261103. **No merge, no rig, no Codex Cloud for VFX, no gameplay/SaveService/Combat V2/V6.3 edit, PvE HOLD.**

## 1. Real immutable sources used (existing GitHub files)

- Actor: **AS-CHAR-48 male Kiếm Tu**, 4 genuinely authored *Attack_Front* full-body RGBA cels at 400×440, with candidate atlas at \`godot/labs/character_family/aschar_v9_batch1/assets/atlases/AS48_attack_front_consistency_v2_atlas.png\`.
- Per-frame grip and rotation (actual reviewed data): \`godot/labs/character_family/aschar_v9_batch1/meta/AS48_ATTACK_FRONT_SOCKET_V9_3.json\`. The four hand grips: (266,336), (311,221), (290,315), (263,263). Release is authored frame 2 at 7 fps. No rig; authored full-body frames unchanged.
- Detached sword texture: \`godot/labs/character_family/aschar_v9_batch1/assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png\` with approved **source STATUS CANDIDATE only**, grip/tip/scale from V9.3 data. No baked sword pixels.
- Real moving monster art: \`godot/assets/actors/v5_sa_monster_1113031_1/animations.tres\` / walk.
- Canonical skill: \`tmb.skill.sword.ngu_kiem.active_01.human\` — **Phi Kiếm Truy Ảnh**, \`damage\`, \`single_target\`, target_limit 1, per \`docs/operations/vfx_school_ledgers/03_sword_183.csv\`. **Human VFX art NOT APPROVED**.

**Important:** In the checked remote branch, *only Front motion for this AS48 candidate* is confirmed as authored and published. Other directions exist as historical owner/E-drive candidate discussions but were not verified on the current PR. Do not fill gaps by mirroring, static poster, inferred sprite or fake frame. This lab is intentionally **FRONT_ONLY**. The 4-direction contract from Architecture A remains required for full acceptance later.

## 2. Implemented isolated files

- \`godot/labs/visual_bridge_v1/as48_sword_anchor_lab.gd\` & \`.tscn\`: genuine AS48 4-pose front attack at 7 fps, separate sword attached at V9.3 per-frame grip/rotation, real animated monster at map-like 1×, caster release from derived sword-tip pixel and target contact following monster. Isolated 1280×720 viewer with SPACE replay and M motion toggle.
- \`godot/labs/visual_bridge_v1/as48_sword_vfx_binding_lab.json\`: binding manifest with **skill_cast→sword tip**, **hit→target body center**. It contains NO actual Sword G3 RGBA source. Glow/hit is a **technical visualization probe** reusing existing \`combat_lab_v16_impact_glow.gdshader\` only; this is **not an Art-First V4 art master**.
- \`tools/qa/check_as48_sword_bridge_sources.py\`: strict SHA-256 verification of **actual existing source** for 4 front cels and separate sword, PNG RGBA dimensions, grip metadata, real monster resource and declared skill.
- \`.github/workflows/vfx-sword-as48-anchor-native.yml\`: exact-SHA official Godot 4.7.2 GL Compatibility import/parse and isolated movie; 1280×720 MP4 and 6 inspection PNGs from native Godot, source-only log and SHA. CI fixture and native playback must be reported separately from owner sign-off.

## 3. Event truth, G3 and G3.5 constraints

- Lab drives **two synthetic \`LAB_ONLY\` event envelopes** with canonical field shapes, NOT a real Combat V2 battle. The read-only bridge routes an encounter-scoped event ID once; duplicate contact ID is rejected. Neither this scene nor shader mutates HP, targets, status, reward, equipment, Save or release V6.3 gates.
- Source sword tip is calculated from **real weapon asset pixel tip – pivot, real asset scale and frame rotation**, not a manually placed glowing point; dynamic \`source_to_world\` transform uses actor foot pivot (200,429) at map-scale 0.17. Contact uses the **actual moving monster** but an explicitly **estimated LAB-only torso offset** until target frame anchors are authored.
- The lab's release/contact times are **demonstration timings**, not canonical \`cast_time\` or hit receipts. Single target only and no artificial damage.
- **Do NOT label G3/G3.5 VFX art PASS.** This lab's shader is an engineering placeholder, not a new original Human sword RGBA source or the finished \`Phi Kiếm Truy Ảnh\`. Actual Art-First V4 still requires original sword VFX hero master and true changing poses, 1× manual art preflight on moving monster and exact-Godot evidence *for that separate revision*. No G8 or PvE integration.
- Original approved Poison art POI06 R11/POI15 R1B and POI19 R3 benchmark are immutable. Character actor source and all existing VFX assets unchanged.

## 4. Run/QA status boundary

Python static checks can run from repo root:

~~~bash
python3 tools/qa/check_as48_sword_bridge_sources.py
python3 -m unittest discover -s tools/qa -p 'test_asset_vfx_bridge_v1.py' -v
~~~

Native Godot scene, if official 4.7.2 is installed:

~~~bash
godot --path godot --scene res://labs/visual_bridge_v1/as48_sword_anchor_lab.tscn
~~~

**Do not claim Godot or video PASS before an exact-SHA workflow succeeds and the real frames have been inspected.** GitHub Actions movie capture tests technical playback; it cannot approve art or physical FPS.

## 5. Next work, VFX first

1. Review this native clip for anchor alignment and movement; repair **lab binding only** if needed.
2. Build **first-party illustrated RGBA source art** for Human Sword / Phi Kiếm Truy Ảnh, distinct charged sword-energy silhouettes and impact with genuinely changing keyframes. **Art-First V4 G3** manual gate must pass before running full Godot native G3.5.
3. Replace TECH cue with first-party art in LAB and rerun native moving-target 1×; preserve separate asset/FX pipelines. Repeat binding for real other directions only when Asset team publishes matching verified anchors. Human first; then branches and Tiên/Thần later.
4. Coordination: Issue #77 owns actor/weapons; Issue #83 owns 12-school VFX and V4 SOP. No file edits in character-owned paths from this bridge milestone.

**Status owner art:** PENDING; **VFX G3:** SOURCE_PENDING; **4-direction:** PARTIAL_FRONT_ONLY; **PVE:** HOLD; **native CI:** report actual run status after commit.
