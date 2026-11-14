# VIS-01–VIS-06 — Visual Excellence & Ngũ Sắc Tiên Quang (Owner authority annex)
Date: 2026-11-14. Scope: PR #72, presentation ONLY. Status: IMPLEMENTATION CANDIDATE — runtime visual and owner approval PENDING.

## Authority
This Owner decision overrides the older `no rainbow rarity` sentence of `docs/P3_ART_BIBLE.md` **only** for the Nghịch Thiên quality. Five IDs and gameplay authority remain immutable. The rest of P3 style (ink, jade, restrained bronze, 1280×720 readability, one game) remains canonical. Never replace original artwork with procedural placeholder geometry. No rig. Combat VFX stays in its separate owner approval lane.

## Existing implementation reuse
- Main playable scene: `godot/scenes/p3/p3_2_landscape_sect.tscn` -> `art05_onegame_cinematic_ui.gd` -> P3.2.
- Existing ART-05 filigree, ART-02 item artwork, B1 guidance screen, Source A portraits, six-dimension radar, native real save/cultivation/work are retained.
- New: `sect_quality_visual_v1.gd` centralized colors, 5 IDs, motion toggle, one edge overlay and one text shader, additive to real portrait nodes. Roster deliberately has static border rather than per-actor animated shader.
- Scene integration: live disciple summary, P3 profile V2+legacy shared UI, roster and actual Dẫn Tiên candidate/recruited screen.
- Reduced motion is **session-level**, available on deep profile and Dẫn Tiên; no persistence to SaveService. Mobile physical gate pending.

## Research matrix — 34 effects
Legend GPU/CPU estimates: T = low, V = moderate, C = expensive. All are **pre-profiling hypotheses**, not Android benchmark measurements. License G = own implementation based on Godot official documentation, no external texture/code copied. “Tốt” indicates likely suitability, NOT tested Android PASS.

| # / Technique | Aesthetic merit | Use in TMB | Godot 4 Compatibility implementation | Cost* | Android* | Priority | Rights |
|---|---|---|---|---|---|---|---|
| 01 Animated gradient | Ngũ sắc chuyển mềm | Tên Nghịch Thiên | CanvasItem glyph shader | T | Tốt | P0 | G |
| 02 Prismatic shimmer | Sáng ngọc theo góc nhìn | Khung Nghịch Thiên | CanvasItem edge shader | T | Tốt | P0 | G |
| 03 Iridescent ink | Mực đổi sắc tránh neon | Đại danh phẩm cao | HSV/vec3 interpolation | T | Tốt | P1 | G |
| 04 Crystal-edge illumination | Viền pha lê trong | Chân dung/trang bị | RGBA atlas + edge mask | T | Tốt | P0 | G |
| 05 Golden glint | Một đường ánh kim ngắn | Tuyệt Luân/pháp bảo | UV sweep shader | T | Tốt | P1 | G |
| 06 Soft rim light | Tách bóng tối rõ hình | Chân dung | Backlight layer masked | V | Có điều kiện | P0 | G |
| 07 Breathing spirit aura | Khí tức hô hấp chậm | Chân dung chọn | Alpha Tween/Shader | T | Tốt | P1 | G |
| 08 Sparse orbit dust | Tinh trần thưa có chiều sâu | Khung cực phẩm | GPUParticles2D thấp | V | Tốt | P1 | G |
| 09 Aurora ribbon | Dải cực quang dịu | Tuyển Nghịch Thiên | Mesh ribbon 2D + shader | V | Có điều kiện | P2 | G |
| 10 Runic circulation | Chuyển động phù văn | Công pháp Thần | Original glyph atlas + path | V | Tốt | P2 | G |
| 11 Animated sigil | Khai ấn dễ nhận | Thức tỉnh huyết mạch | AnimationPlayer / sprites | V | Tốt | P1 | G |
| 12 Energy trail | Vệt di chuyển liên tục | Kiếm/lôi đã duyệt | Line2D + gradient | V | Tốt | P2 | G |
| 13 Ink dissolve | Mực tan vào khí | Thắng trận / bỏ panel | Dissolve alpha mask | V | Có điều kiện | P2 | G |
| 14 Energy dissolve | Hạt tan mềm | Reveal cuối nhịp | Alpha erode atlas | T | Tốt | P1 | G |
| 15 Layer parallax | Nền có chiều sâu | Bản đồ công trình | Multi-layer CanvasItem | V | Tốt | P2 | G |
| 16 Lotus bloom | Hoa sen linh khí nở | Đan dược / trị liệu | Sprite frames authored | V | Tốt | P2 | G |
| 17 Shockwave ring | Nhấn lực đột phá | Đột phá cảnh giới | Ring shader short-lived | T | Tốt | P1 | G |
| 18 Impact flash | Đỉnh tương phản tức thời | Đánh trúng thực | Sub-100ms ColorRect FX | T | Tốt | P2 | G |
| 19 Heat refraction | Sóng nhiệt hỏa quang | Lò luyện khí | Screen-reading shader | C | Cân nhắc | P3 | G |
| 20 Poison volume layers | Sương độc mềm phân tầng | Độc Tu VFX đã duyệt | Few authored smoke sprites | V | Có điều kiện | P2 | G |
| 21 Lightning arc | Trắng tím có nhịp | Lôi Kiếp | Original ribbon/path shader | V | Tốt | P2 | G |
| 22 Constellation reveal | Sao kết thành chòm | Huyết mạch hiếm | Dot atlas + staged path | V | Tốt | P2 | G |
| 23 Reward reveal sequence | Cao trào có mở thưởng | Nghịch Thiên | AnimationPlayer five-stage | V | Tốt | P1 | G |
| 24 Realm ascent column | Cột sáng tăng cảnh giới | Đột phá thật | Stacked sprites + particles | V | Có điều kiện | P1 | G |
| 25 Bloodline pulse | Huyết mạch bừng sáng | Thức tỉnh thật | Mask + limited ripple | V | Tốt | P2 | G |
| 26 Divine scripture seal | Chữ bí pháp nổi sống | Công pháp Thần phẩm | UV glint original atlas | T | Tốt | P2 | G |
| 27 Artifact spirit motes | Pháp bảo có linh tính | Item nhỏ / tooltip | 2–4 independent motes | T | Tốt | P2 | G |
| 28 Architecture atmospheric glow | Công trình có khí quyển | Linh Điền / Đan Phòng | Low-opacity art overlay | V | Tốt | P2 | G |
| 29 Jade caustic shine | Đốm sáng trên ngọc | Khung Xuất Chúng | Normal-map-lite 2D shader | T | Tốt | P1 | G |
| 30 Material roughness illusion | Kim loại có vân thật | Khung Tuyệt Luân | Authored albedo + thin glint | T | Tốt | P1 | G |
| 31 Edge frosted refraction | Tinh băng không mù icon | Trang bị hiếm | Baked crystal atlas, no screen | V | Tốt | P2 | G |
| 32 Rare pickup beacon | Vệt sáng có hướng | Kho / phần thưởng | Tween local only | T | Tốt | P1 | G |
| 33 Temporal anticipation | Dấu hiệu trước cao trào | Sự kiện hiếm | AnimationPlayer easing | T | Tốt | P1 | G |
| 34 Camera micro-shake | Một nhịp rung có lực | Breakthrough, hit thật | Camera2D offset <=2px | T | Có điều kiện | P3 | G |

## Selection and limits
1. VIS-01: 5 literal quality IDs, centralized palette, low-motion prismatic shader only for heaven_defying labels; legibility always wins.
2. VIS-02: thin light rim as a sibling of original portrait imagery, halo restricted to the edge; optional motion; no screen-copy, blur filter, or HDR dependence.
3. VIS-03: do not deform or recolor actual portrait textures; radar/stat text and click targets remain above decor. V2+legacy use identical host form.
4. VIS-04/05/06 remain DESIGN QUEUE until scoped integration and actual visual review; **the 34-row matrix is not a claim of implementation**.
5. Crowd budget: no animated frame on every roster row or every map actor. Selected frame may animate; 500 disciples must not mean 500 active shaders.
6. Quality color mapping applies **only to disciple quality**, never reuse disciple `disciple_quality` for equipment, pill, bloodline, physique, or skill grade.
7. Quality shader never modulates source portrait: all pixels inside frame center transparent; real Source A / approved assets stay original.

## Genuine runtime/QA acceptance
- Check `vis01_02_quality_visual_test.gd` on exact SHA, Godot 4.7.2 Compatibility; official CI result must be read before saying PASS.
- Open real scene at 1280×720, recruit a true Nghịch Thiên, save/source verification; capture BEFORE/AFTER same camera and GUI MP4 (>=8 animation phase frames).
- Inspect name glyph outlines, ColorRect alpha transparency, UI clipping, click targets, roster switching, old/legacy profile, low VFX toggle, small-screen Android frame time.
- Physical GUI/Android and OWNER_VISUAL_APPROVED: PENDING until evidence; static code review and successful CI are insufficient.

## VIS-02 finishing pass
- `vis02_soft_aura.gdshader` is a restrained additive backlight **behind** real portrait textures, never a tint on character pixels.
- `sect_prismatic_motes_v1.gd` draws only 7 original sparse edge motes on Nghịch Thiên, at most 8 redraws/sec, and is disabled in reduced motion.
- UI toggle cycles full/reduced/off without modifying `SaveService`; changing view modes never replays recruitment.
- Dẫn Tiên Đài has one **0.60-second** non-looping first-reveal per recruited character ID; reduced/off bypasses the animation.
- Full VIS-05 event cinematics, platform screenshots of rare recruitment, and physical Android FPS remain PENDING.

## Open-source project comparison (analysis, NOT copied code/assets)
| Reference | Relevant techniques | Use rights | Decision |
|---|---|---|---|
| [GDQuest Godot Shaders](https://github.com/gdquest-demos/godot-shaders) | 2D glow, dissolve, outline, cloud, water, shockwave | Check the individual repository license and assets before any redistribution; sample code can have different rights from art | Study architecture only; no code/assets imported |
| [Godot 4 sprite outline CC0 sample](https://godotlearning.com/shaders/sprite-outline) | 2D alpha outline | Page declares CC0 | Technical comparison, no copied sprites |
| [Free Game Feel shaders](https://kodanvil.itch.io/godot-game-feel-shaders-free) | Hit flash, outline, dissolve | Publisher advertises MIT for free subset | Future VIS-05 comparison only; no imported code |
| [Godot 4 free shader set](https://stumasondev.itch.io/godot-4-2d-shaders) | Light sweep, dissolve, wave, shockwave | Publisher advertises CC0 | Study possible VIS-04/05 effects only; no imported files |

## Public technical references / rights
- Godot 4 CanvasItem shader (TIME, COLOR, UV), reference: https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html
- 2D particles (GPU/CPU differences): https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html
- Renderer feature comparison: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- StyleBoxFlat nontexture edge styles: https://docs.godotengine.org/en/stable/classes/class_styleboxflat.html
- Screen-reading shaders (expensive copy, consciously avoided): https://docs.godotengine.org/en/stable/tutorials/shaders/screen-reading_shaders.html
- Documentation content CC BY 3.0, credit Juan Linietsky, Ariel Manzur and Godot Engine community: https://docs.godotengine.org/en/stable/about/faq.html ; Godot engine MIT: https://godotengine.org/license/
- All newly committed shader/script code original for TMB. No third-party commercial JX/Source A artwork has been copied by this VIS packet.

## Real-Godot visual evidence gate added
- `godot/tests/presentation/vis02_real_recruit_visual_capture.gd` uses the real P3.2 scene, authentic D7 gacha generation until a **naturally rolled** Nghịch Thiên (no forced quality), and the real B1 two-click accept action in an isolated user:// QA save. It exports 9 1280x720 PNGs and a movie via the Godot 4.7.2 native movie writer.
- `.github/workflows/vis02-real-recruit-video.yml` runs under Xvfb GL Compatibility, transcodes native MJPEG AVI into MP4, uploads screenshots/movie and a provenance report. **Not physical Android/Owner acceptance.**
- Never claim PASS until this workflow actually runs SUCCESS; the test must inspect arrival, full/reduced/off, comparative nonrare profile and Source A textures.

## VIS-02 R2 → VIS-06 implementation packet (2026-11-14)
- **VIS-02 R2:** original vector crystal-cut frame at `godot/art/uiux/quality/vis02_heaven_crystal_frame.svg`, rendered as nine-slice transparent overlay only on Nghịch Thiên selected portrait and recruitment cards. Shader edge, soft aura and sparse motes remain separate from approved character texture. Reduced mode keeps a muted still frame; off hides the optional frame.
- **VIS-03:** the existing real V6.3 party HUD colors names from `DiscipleState.disciple_quality`; selected deep profile, legacy, candidate and roster continue reading the same canonical ID. No 500 concurrent animated frames.
- **VIS-04:** equipment has its **own existing quality authority** (`pham/tinh/thuong`) and dedicated `sect_equipment_material_v1.gd`; the actual equipped-item label and option selector use only `EquipmentSystem.equipped_item` and saved `state.sect.equipment_items`. No fabricated rainbow item or new quality/skill/economy IDs.
- **VIS-05:** genuine, once-per-real-ID Nghịch Thiên recruitment runs a five-beat, 1.10-second UI reveal; reduced/off skip it. Existing recruit decision, acceptance, persistence and navigation remain unchanged.
- **VIS-06:** warehouse, alchemy, site-operation cards share one responsive dark jade/bronze material with actual building accent; neutral stock is *not* assigned a fake equipment grade. Existing ART-05 world atmosphere is retained.
- **QA budget:** the short official 4.7.2 VIS contract runs on push. The costly movie workflow is manual-only, with no change to source, history or screenshots. Existing independent red CI and physical Android remain separate. Technical approval is not aesthetic approval.
- **Status:** CODE CANDIDATE; VIS02–06 artistic owner approval and Android/GUI evidence remain PENDING until inspected at exact SHA.
