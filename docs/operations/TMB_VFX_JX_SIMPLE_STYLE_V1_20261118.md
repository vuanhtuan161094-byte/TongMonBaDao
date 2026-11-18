> **SUPERSEDED AS A PRODUCTION PROCEDURE — OWNER 18/11/2026:** The owner rejected FIST14 R4 created from the relaxed one-sprite approach and explicitly restored original [Art-First V4](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md). The frame budget table, "some VFX can use only 1 good sprite" shortcut, and suggestion that Codex may bypass distinct first-party animated art **ARE NOT APPLICABLE as authoring/acceptance authority**. This document is retained only as an aesthetic reference to JX/Kiếm Thế readability, bright restrained contact and uncluttered color. [Formal rollback / R4 OWNER_REJECTED](docs/operations/TMB_VFX_REINSTATE_ART_FIRST_V4_AND_FIST14_R4_REJECTION_20261118.md).

# TMB VFX — JX / Kiếm Thế giản lược · Visual Style V1

**Owner directive: 18/11/2026.** Tông Môn Bá Đạo now prioritizes **gọn, rõ, đẹp, đúng chất võ hiệp** over ornamental complexity. This is a design simplification overlay for **future production and authorized reworks**, not permission to replace previously approved/provisional assets or weaken the canonical V4 QA/contract, physical QA, artwork originality, or Combat V2 receipt rules. PR #72 stays Draft, PvE HOLD, V6.3 OFF. Do not copy/trace any proprietary JX/Kiếm Thế sprites.

## Core look: one distinctive shape, one directional motion, one meaningful contact
- **1 main silhouette**: fist impact, sword energy, talisman/wind seal, living jade gu, compact flame/lightning. Readable **without reading a label** at native 1280×720 **1×**.
- **1 motivated move**: thrust, slash, drop, short orbit or expand, with sensible caster and selected-target anchors. No full-screen decorative swirls or glowing glyph board. Less is more.
- **1 hit/readout**: bright short contact, a handful of secondary particles, and a separate semantic mark **only when canonical skill has a persistent status**. No invented damage, extra projectile, target count or false combat hit.
- **Material**: one clear color family per school/skill, original first-party illustrated body with **small** hot white-yellow core, soft colored edge, fast fade; no muddy smoke/cloud, giant bloom, tangled rune paragraphs or a second unrelated motif.
- **Performance/readability**: reserve screen space for combat actors and targets; prefer smaller local hits and controlled alpha over wide expensive particles.

## Default production budget (guidance, not rigid physics or an override of existing art)
| Skill use | Typical original hero poses | Runtime VFX layers | Visual treatment |
|---|---:|---:|---|
| **B: basic, ordinary active, light projectile** | **2–4** meaningful changed poses (or a small original flipbook) | **main + small local trail/contact** | a short crisp punch, dart or spark |
| **A: recognizable active, characteristic buff** | **4–6** changed poses; extra only if real morphology requires | **main + one restrained trail + contact/status if actual** | characteristic sword arc, coiling jade gu, seal |
| **S: ultimate/branch identity/Boss signature** | **6–12** if justified by genuine distinct art and motion | selective 2–4 complementary layers; never mandatory all at once | memorable large silhouette + authoritative impact |

**These are budget targets, not automatic PASS conditions.** Some VFX can use only 1 good sprite and a moving particle system; some require more genuine hand-painted frames. The prior 16-frame POI18 Hybrid brief is a **candidate for that one revision, not a blanket standard**. Do not re-render old frozen approved/provisional art just to fit the table. Motion pacing respects the catalogue cast clock; no invented timing or automatic gameplay hit.

## Godot engineering pattern: minimum technical complexity
- Keep the **original hero RGBA** as the central sprite; prefer a small `AnimatedSprite2D` / `AnimationPlayer` sequence. Node animation is **not character skeletal rigging**.
- Optional **one** local `GPUParticles2D` instance with a small first-party texture for flight wisps or impact flecks; a trail/soft flash using `CanvasItemMaterial` ADD or a light `CanvasItem` shader only if visibly beneficial. **One hot core**, not multiple giant glow rings.
- Target-relative contact only when the skill's contract permits it; a skill's sustained debuff goes through the shared **status/buff visual layer** rather than another complete skill-specific continuous VFX.
- Prefer already-proven `tools/qa/run_vfx_shared_packet.py`, `.github/workflows/vfx-shared-skill.yml`; do not create a per-skill Godot project or duplicate 100-line workflow.
- **If the owner explicitly authorizes Codex for a scoped task**, it can help with GDScript, particles, shaders, workflows and regression; the current school-chat 'NO CODEX' rule otherwise remains in force. Codex is **not the visual director**. Author main sprite source deliberately, review real 1× Godot G3.5 and retain owner visual approval separate from CI success.

## Fast feedback for production — no infinite revision loop
1. **Choose a compelling single hero silhouette** with isolated, genuine transparent master. Examine it directly at the size it appears in gameplay; if it reads as a vague ribbon/flat font/clipart, rework source **before** creating dozens of frames or configuring CI.
2. Make only the **minimal distinct key poses** sufficient for that motion; do not animate one photo 36 times and call it 36 independently illustrated poses.
3. Add the minimum Godot trail/glow/contact, then run **native G3.5** on a moving target at 1×. Check one dim scene and one brighter background if the silhouette is dependent on darkness. **Technical PASS is not art PASS.**
4. If the central image fails twice on the same artistic approach, **stop and propose a simpler different silhouette** instead of R7–R12 micro-polish, massive new shaders, or long G5 movies.
5. On deliverable checkpoint, show native proof + clear owner-selectable A/B/C/(D) alternatives. User can approve a **simpler usable version** as provisional while preserving visible quality debt; only owner can do so.
6. Do **not** automatically redesign existing owner-approved and provisional skill assets. Continue existing school work within owned paths and record what was simplified.

## Example minimal JX-style recipes (NOT game event specifications)
- **FIST14:** a clearly painted closed fist in warm ruby, single short directional dash, small white-hot impact; **no three claws**, multiple red scribble ropes or additional real projectiles.
- **POI18:** a small **recognizable jade living-seed** with distinct head/tip, one thin short living-silk tail, local wrap on moving selected enemy, then existing separately governed status mark; no two abstract electric ribbons.
- **PAF05:** **one** legible wind seal made of original textured golden wind/ink, compact clockwise reveal, clean wind push/contact; no giant typography board, neon ring or replicated floating HUD glyphs. Keep R5E unchanged.
- **Ordinary sword/lightning:** one clear arc or bolt, tiny directional streak, localized hit flash; reserve complex multi-bolt formations for iconic ultimates.

## Visual references / independent production
- [Godot official 2D sprite animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html)
- [Godot official 2D particles](https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html)
- [Godot CanvasItem shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html)
- [Godot AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html)

Use JX and Kiếm Thế Mobile as **visual language reference**: short readable motifs, crisp core, strong contact, restrained trails; do not extract or reuse proprietary assets. No rig, no GIF by default, no gameplay/PvE/SaveService modifications, no merge. Existing G0–G8 are not bypassed by this simplification.
