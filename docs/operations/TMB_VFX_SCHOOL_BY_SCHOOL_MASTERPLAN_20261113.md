## UPDATE — OWNER-ACCEPTED 4-POSE XÀ ẢNH, NEW VFX PRODUCTION SOP (2026-11-14)

**Current production standard:** [TMB_VFX_SOURCE_VL_PRODUCTION_STANDARD_20261114.md](TMB_VFX_SOURCE_VL_PRODUCTION_STANDARD_20261114.md). A verified 12-source/12-ledger audit confirms 12 schools / 36 specialized branches / 2,196 unique skill IDs / 420 families; 204 cast master families and 216 passive/innate event families. All 12 catalogues still disabled; **defined does not mean live/approved art**. The Godot POI-02 four-pose Xà Ảnh Quấn Mạch LAB is owner-accepted as visual baseline with **charge/tụ lực polishing still due**. The original flight and bind phases remain frozen. Its *one Human skill row only* is updated to LAB_APPROVED_CHARGE_POLISH_PENDING / OWNER_VISUAL_APPROVED / HOLD_V63_OFF; all descendants and other schools are not automatically approved. No rigging, no PvE integration, no Combat V2 or V6.3 feature-gate edits. Automated inventory checker: tools/qa/audit_vfx_school_catalogs.py.

# TÔNG MÔN BÁ ĐẠO — MASTERPLAN VFX CHUYÊN NGHIỆP THEO 12 MÔN PHÁI
Version: VFX-SCHOOL-PLAN-01 · Date: 2026-11-13 · Project: PR #72 Draft · Branch: `integration/pve-p0-playable-ui-20261103`.
**This commit changes planning files/ledgers only. No VFX renderer code, Combat V2, V63 gate, SaveService, PvE integration or gameplay changed.**
Source HEAD at last plan creation: `d2b3542b86872273cbc05f645396fff8995fe29a`. Recheck live HEAD at the next chat.

## A. Owner's binding constraints
1. Chủ dự án KHÔNG cần nhớ tên tool/skill. Assistant tự đọc `AGENTS.md`, `.agents/skills/tmb-vfx-art-director/SKILL.md` và vận dụng phù hợp. Tự thực hiện trực tiếp, KHÔNG mặc định giao Codex.
2. **Mỗi lần một kỹ năng có VFX thực**, xem bằng video Godot 4.7.2 thật 1280×720. Nếu xấu phải sửa cùng kỹ năng đó, không “làm xong” vì CI xanh. Chỉ chuyển kỹ năng khi chủ dự án duyệt visual hoặc chuyển hướng rõ ràng.
3. Theo **từng môn phái một**, không mass-produce hàng nghìn effect recolor. Mỗi môn phái 3 nhánh có style và chuyển động riêng, passive không tự phát nổ.
4. Tuyệt đối KHÔNG lấy VFX18.2 kiếm và VFX19 R2 sét bị chủ dự án chê làm chuẩn chất lượng. **VFX LAB gốc 4 kỹ năng** (HTML Canvas, Cửu Thiên Lôi Kiếp/độc/rắn/kiếm), cùng luồng sét và rắn V9 được thích, là reference. Bản HTML dùng `shadowBlur` mềm, lõi tím-trắng, ít nhánh, sáu pha chớp lệch nhịp; Godot phải tái dựng CHẤT LIỆU ÁNH SÁNG ấy trước, không bồi thêm đa giác/dây phát sáng.
5. Nguồn JX, Kiếm Thế, Source VL và Source A chỉ là **đối chiếu nghệ thuật, kỹ thuật và animation timing**; quyền sử dụng thương mại chưa được xác thực. Không copy PNG/sprite/mesh/shader độc quyền sang bản phát hành. Hình đẹp có thể dùng shader thuần, particle, hand-painted texture bản quyền của mình hoặc nhiều kỹ thuật kết hợp; không giáo điều “phải 100% code”.
6. PR #72 vẫn Draft, một nhánh, không merge; V6.3 feature gates OFF. Event journal/Combat V2 nắm quyền hit/target/HP/DoT/guard/heal/summon; VFX chỉ là view. Không đụng các file SaveService/economy/combat/AI do những nhóm khác đang viết.

## B. Verified source inventory — CATALOG != PLAYABLE or BEAUTIFUL
Đã đọc code JSON catalogue trên GitHub, không suy ra từ brief:
- **12 schools × 183 IDs = 2.196/2.196 actual unique IDs**, **420 unique family_id** (35 family per school), **36 nhánh**.
- Mỗi school có **17 family thi triển** = Basic + Mobility (2) + 3 × (4 active + 1 ultimate) (15), tổng **204 caster/master VFX families**.
- Mỗi school có **18 family thuộc passive/innate**, tổng **216**. Passive/innate liên tục KHÔNG có cast VFX; proc cue/buff aura phải phản ứng từ event thật khi có.
- Cả 12 catalogue đang đánh dấu `enabled=false`; 2.196 ID **không đồng nghĩa** 2.196 kỹ năng đã chạy thành công ở PvE. 9 trường phái mới có S1–S9 code đã hình thành trên V6.3 nhưng release source/content/balance có cổng pending. `V63FeatureGates` không được tự bật.
- **794 vfx_key declared** distinct, KHÔNG phải 794 renderer thực. Riêng Chú Tu **183/183 keys có `text_pending`**.
- Đã tạo **12 CSV ledger từ canonical catalog**, mỗi file 183 ID, tổng 2.196 hàng dữ liệu tại `docs/operations/vfx_school_ledgers/01_poison_183.csv` tới `12_summon_183.csv`. Columns: ID exact, family, school/branch/slot/tier/name, declared VFX key, effect, shape, target_limit, visual class, LAB status, owner gate, live gate. Không đổi skill ID/values. Đếm theo family_id distinct cho 420 danh mục. Không tự mark `OWNER_VISUAL_APPROVED` hoặc `LIVE_READY`.
- 549 IDs Cung/Quyền/Độc ở 3 catalog Human/Immortal/Divine; 9 trường còn lại 183 ID mỗi trường theo catalog riêng. Đây chỉ là **file scope**, không phải status gameplay full-pass.

## C. Godot VFX expert technical toolkit — đúng GL Compatibility 4.7.2
**Render target:** 2D/2.5D, Godot 4.7.2 Compatibility (Windows/Android planned) 1280×720. Không bắt ép Forward+ HDR 2D bloom, vì Compatibility có bản glow giới hạn khác và chưa có phép đo trên điện thoại.

| Technique | role / when to choose | likely failure | acceptance exercise |
| --- | --- | --- | --- |
| `canvas_item` shader, `ShaderMaterial`, `blend_mix` / `blend_add` | energy hot-core, iris/soft falloff, laser/qi, heat/blood/water | alpha cứng, cộng sáng quá nhiều, washed out | grayscale + dark/bright map; native 1× clip |
| `Line2D` + width_curve / ribbons / `CanvasItem.draw_polyline` | electric backbone, trails and attack-direction cues | equal-spaced points, polygon-join bright blocks | compare smooth halo vs hard kink at 1× |
| Distance/SDF Gaussian glow, original radial-gradient texture | reproduce original HTML `shadowBlur` while keeping pointed shape | hard halo cutoffs or visual flatness | A/B compare analytic vs texture, no forced code-only |
| `GPUParticles2D` and `CPUParticles2D` | timed sparks/fire/embers/ice debris/poison motes | emitter silent, GPU compatibility, large overdraw | one-shot seeded bursts, bounded lifetime/count, test native Compatibility |
| `AnimationPlayer` / `Tween` / Curve | planned 5-phase choreography; animate material/fade/position | uniform speed, all layers begin together | 8–12 timed frames; honest arrival |
| `Sprite2D` flipbooks / hand-painted masks / normal maps | flame, true steel swords, crystals, soft painted energy | copied proprietary art / no source permissions | original/properly licensed art + filename/hash |
| `PointLight2D` / 2D normals and `LightOccluder2D` | local environmental light from lightning, flame, formation | dozens of dynamic lights at 30×40 | additive benefit measured vs simpler decal |
| bounded local `SubViewport` / 2D blur experiment | mimic HTML Canvas shadowBlur soft cloud | full-screen blur and render-target costs | local reduced-size blurred mask vs Gaussian shader |
| `RenderingServer` batches / shared `Material` / pooling | dense PvE 6v8→30 disciples/40 monsters | drawcalls, per-frame node allocations and shader compiling | trace p95 CPU/GPU, drawcalls and particle count |
| sprite rigs + actor anchors | hand/weapon tip/ground vs target plus front/back Y sort | light renders over faces/UI, wrong hit end | render on actual actor and terrain (not only grid) |

**Actual official Godot refs** (confirmed 2026-11-13):
- https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html
- https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html
- https://docs.godotengine.org/en/stable/classes/class_gpuparticles2d.html
- https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html
- https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html
- https://docs.godotengine.org/en/stable/tutorials/animation/introduction.html
- https://docs.godotengine.org/en/stable/classes/class_subviewport.html
- https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
- https://docs.godotengine.org/en/stable/tutorials/performance/gpu_optimization.html

**Specific engineering lessons:** Canvas `shadowBlur` is NOT the same as stacking four Godot `draw_line` calls. Build a **thin bright white-lavender spine + smooth alpha-falloff cyan/violet mask**; let it travel; keep 1-2 branches and shape hierarchy. On GL Compatibility use original shader/gradient masks with `blend_add` sparingly, not untested HDR Bloom. Godot `GPUParticles2D` can use trails, subemitters and `one_shot`; validate supported behavior and use CPU fallback only if measured beneficial. Looping shader `TIME` must not detach from real Combat V2 skill release/hit timing; Lab should use deterministic author-timeline seed.

## D. External professional sources and legal-use classification
| link | grounded utility | terms / use decision |
| --- | --- | --- |
| https://github.com/REEBO0/godot-stylized-2d-vfx-lite | 4 complete 2D sparks/slash/explosion demos, native scenes, shaders and particles | **MIT** verified; works with Compatibility per author; test exact 4.7.2 |
| https://github.com/PSCactux/godot-effects-lab | 14 effects including hit flash, smooth trauma camera shake, trails, GPU particles, outline/glow, 2D lights | **MIT** verified; demo 4.7; some code paths Forward+, check Compatibility |
| https://github.com/uzkbwza/BurstParticles2D | one-shot burst grouping / curves | **MIT** verified; author warns slower than native GPU in bulk; not default for 30×40 |
| https://github.com/gdquest-demos/godot-visual-effects | explosion, laser, ghost-trail VFX composition | source **MIT**, artwork **CC-BY-NC-SA 4.0** -> NEVER include noncommercial art in game |
| https://github.com/scenario-labs/skills | expert Godot 4.7.2 VFX, shader, renderer and performance checklists | **MIT** verified; use know-how/audit practice; no extra plugin necessary |
| https://store.godotengine.org/asset/vefects/trails-vfx/ | 10 4.7+ elemental ribbon presets | commercial use with EULA restrictions; Forward+ suggested; Compatibility and redistribution unverified -> REFERENCE ONLY |
| internal `docs/operations/VFX18_JX_SOURCEA_LIGHT_LANGUAGE_RESEARCH_20261113.md` | JX1 #158, Source VL sword sheets, Unity Source A candidate clips and JXQY2 INI | JX/Source VL/Source A commercial asset rights **unverified** -> reference, no copied sprite/shader/texture |

**Check license file at exact pinned source commit when implementing any external code.** The list is a research shortlist, NOT a claim all 4.7.2 demos are fully compatibility proven on Android. MIT requires attribution/notice on source reuse. Avoid artistically borrowing recognizable nonlicensed game sprites.

## E. School schedule / 36 branch visual languages
`12 schools × (17 cast masters + 18 passive/innate event families) = 420 families`.
**Suggested sequential queue** (owner may change): 
| order | môn | 3 nhánh | visual signature / avoid duplication |
| --- | --- | --- | --- |
| 01 | **Độc Tu** (`poison`) | Độc Châm · Cổ Độc · Dược Độc | kim độc / rắn sáng / sen dược; dùng V9 làm baseline |
| 02 | **Phù Tu** (`talisman`) | Lôi Phù · Hỏa Phù · Phong Ấn Phù | lôi tím gốc HTML / đốt phù / ấn phong tỏa |
| 03 | **Kiếm Tu** (`sword`) | Ngự Kiếm · Sát Kiếm · Hộ Kiếm | kiếm khí ánh sáng ≠ kiếm thực thể / trảm / hộ |
| 04 | **Cung Tu** (`bow`) | Liệp Ảnh · Linh Tiễn · Thiên Vũ | xuyên tiễn / linh tiễn / vũ tiễn đúng hit receipts |
| 05 | **Quyền Tu** (`fist`) | Bá Quyền · Kim Cang · Huyết Quyền | chấn lực ngắn / hộ quyền / bạo quyền |
| 06 | **Đao Tu** (`blade`) | Cuồng Đao · Trảm Phách Đao · Trấn Đao | vết chém nặng / trảm phá / thủ đao |
| 07 | **Song Đao** (`dual_blade`) | Ảnh Nhẫn · Liên Hoàn · Huyết Nguyệt | dư ảnh không nhân hit / combo hai nhịp / huyết nguyệt |
| 08 | **Thương Tu** (`spear`) | Phá Trận Thương · Long Thương · Hộ Quân Thương | xuyên trục / long khí / hộ trận |
| 09 | **Chưởng Tu** (`palm`) | Liệt Dương Chưởng · Hàn Ngọc Chưởng · Hồi Phong Chưởng | hỏa / băng / phong hồi; mỗi loại diễn hoạt khác |
| 10 | **Chú Tu** (`curse`) | Trấn Hồn Chú · Phệ Linh Chú · Hộ Mệnh Chú | ấn chú / mạch hút linh / mệnh hộ; 183 key text_pending |
| 11 | **Trận Tu** (`formation`) | Tụ Linh Trận · Phong Tỏa Trận · Sát Phạt Trận | trận buff / khóa khu vực / sát phạt đúng vùng |
| 12 | **Triệu Hồi** (`summon`) | Kiếm Linh · Linh Thú · Khôi Lỗi Hộ Pháp | đối tượng triệu hồi thật, không tạo actor giả |

**Per school work package:**
- Inventory exact 183 node rows and 35 families from its CSV. Compare currently recorded `vfx_key` with actual renderer; metadata `text_pending` is not real art.
- Group **17 cast families** (2 shared + 15 branch actives/ultimates); 18 passive/innate family policies = no visual cast unless actual event. Identify 3 branch defining ultimate silhouettes before starting but produce art one skill at a time.
- Each skill `human` art master first; approved `immortal/divine` successors inherit the master system with deliberate phase/shape/strength changes only if mechanic allows (never silently change target count, area, damage, status duration).
- **Do not begin next skill until art of current master is visibly approved**, unless user explicitly asks to skip/switch. A simple passive with no event needs only an auditable NO_VFX_REQUIRED disposition, not artificial animation.
- After all 17 cast masters and conditional cues, run per-school focused+cumulative QA; only then mark school `VFX_ART_COMPLETE` (subject to separately scoped live integration).

## F. One-skill pipeline — 9 evidence gates, no mass-creation
| gate | actual work | exit proof |
| --- | --- | --- |
| A0 | Identify exact `skill_id`, school/branch, slot, element, shape, target cap, real `cast/hit/status` event receipt and caster/target anchor | source catalogue excerpt + event rules; no made-up mechanics |
| A1 | Original/official JX/Source VL/Source A references + license; benchmark praised HTML V9 where appropriate | source-verified/inferred table |
| A2 | Art brief **BEFORE CODE**: 8–12 frame storyboard charge/release/travel/impact/sustain/fade; palette/silhouette plus top-to-bottom layer mapping and volume of detail | art brief, ref image, rejection checklist |
| A3 | Build **ONE** VFX in separate Godot Combat Lab; layer math/particles/shader/author texture exactly as needed; do not over-engineer | source file & provenance; zero gameplay ownership |
| A4 | Godot 4.7.2 GL Compatibility exact SHA focused QA + actual **1280×720 GUI MP4**, 8–12 frames, same-camera baseline vs candidate | artifact/run URL/commit; fixed 60fps movie NOT measured FPS |
| A5 | Personally inspect actual movie 1× and on real-game-like background; if glow hard, lines uniform, contrast bad, no cast/impact, actor hidden: self-rework | visual findings with timestamps, not generic praise |
| A6 | User reviews one short real video + one side-by-side sheet; correction or **OWNER_VISUAL_APPROVED** on exact skill/variant, explicit only | ledger marked by owner approval; rejected sample preserved |
| A7 | Descendant/tier VFX variant if needed (Tiên/Thần); preserve verified gameplay counts; no passive fake cast | focused event and animation QA |
| A8 | **OPTIONAL and separate owner authorization** to connect approved VFX to live Combat V2 journal, test 1v1, 6v8 and 30 disciples/40 monsters, real Android/Windows | real event mapping, anti-replay, perf p95, runtime/device tests; gate OFF until approved |

**Tech QA != art QA.** 1x silhouette, luminous material, choreography, composition, contact, fade, uniqueness and 30×40 legibility judged separately. Existing `.agents/skills/tmb-vfx-art-director/references/QA_AND_EVIDENCE.md` requires core self-scores ≥4/5 before asking user to review. If weak, fix instead of passing with CI. No green badge for visually ugly outputs.

## G. Performance (targets to measure, NEVER claimed measured)
- Godot target 60fps frame budget 16.67ms; low-end 30fps 33.3ms only if explicitly selected. Initial **candidate** incremental active VFX budget ≤2ms at 6v8 is an objective to validate, not a current measurement.
- Real 1× Godot on dark/bright ground and real disciple atlas; Android GPU samples required. CPU time, GPU time if available, drawcalls, blended-overdraw, particles alive, RAM, 95th percentile frame time, any frame hitches and shader compilation.
- Bounded event lifetimes, pooled nodes/shared materials, LOD (high/mid/low) changes particle count, ambient light, forks and remote trails **without removing required hit telegraphs**; skip distant non-impact ambient, avoid permanent overbright concentric circles.
- Playback screen captures and FPS from `--write-movie --fixed-fps 60` **do not measure real hardware framerate**. Windows/Android physical `PENDING_USER` until actually tested.
- Avoid shader full-screen blur, many PointLight2D and CPUParticles×hundreds unless profiling shows benefit.
- All actual hits/casts/status/DoT/heal/guard/summon are from Combat V2/V63 source receipts. No fake monster hit/tick, not even for decorative afterimage.

## H. FIRST NEW-CHAT MILESTONE — GOLDEN LIGHT CALIBRATION
**First do NOT flood the game with 204 demos.** Establish one faithful quality baseline:
1. Read `docs/operations/vfx_reference/TMB_VFX_Lab_4Skills_ORIGINAL.html` and `VFX19_ORIGINAL_THUNDER_RESTORATION_ANALYSIS_20261113.md`.
2. Build `VFX-CAL-00` as a small **isolated Godot 4.7.2 GL Compatibility demo** of the original **Cửu Thiên Lôi Kiếp** quality: white-lavender core + genuinely feathered purple blur, maximum 1–2 low-key branches, pulsed large strike/short relay, sparse responsive debris, not a 30-fork light-wire web. Two technical implementation candidates (Gaussian shader vs small original authored gradient mask) only if necessary; choose on pixels.
3. Compare original HTML first-favorite screenshots with real Godot screenshots at identical scale; open actual native 1280×720 movie. Correct self-detected hard/glow/grid artifacts BEFORE showing.
4. Preserve `OWNER_VISUAL_PENDING/PVE_INTEGRATION_HOLD`. Ask owner to accept/revise **style** without implying all lightning/other skills approved.
5. Once art quality calibration passes, first actual school **Độc Tu**, first canonical representative: `tmb.skill.poison.co_doc.active_02.human` **Xà Ảnh Quấn Mạch**, because a luminous serpent is already visually preferred and requires genuine poison status distinction. Produce one real effect, not all Độc branch effects in one turn.

## I. Source control and handoff
- Scope on PR #72 Draft single `integration/pve-p0-playable-ui-20261103`, no new branch, no merge, no SaveService/skill numeric/AI/item/economy/feature gate changes.
- Each new chat automatically uses project VFX art-director skill, reads this plan and school ledger; user needn't remember skill names. Check latest commit and other active writers first.
- Handoff prompt: `docs/handoffs/VFX_SCHOOL_BY_SCHOOL_NEXT_CHAT_20261113.md`.
- Human approval statuses and provenance update in the relevant school CSV (source skill IDs untouched) only on actual evidence.
- Deliver output: genuine video/animated capture, one 8-12 frame contact sheet, source SHA and scope QA, explicit remaining visual flaws, then await user artistic choice **after having executed**. Do NOT hand work to Codex.
