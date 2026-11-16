# FIST10 R4 — Bất Động Kim Chung | owner-approved *visual reference*, NOT Godot art approval

Recorded: 2026-11-16. PR #72 Draft / branch `integration/pve-p0-playable-ui-20261103`.

## Owner decision and truth

Owner explicitly liked the short transparent-qi bell reference animation in ChatGPT, then asked whether it was **actually running in Godot** and forbade cutting GIF frames into the runtime (the frames contain whole scenes/actors and would produce seams). **Answer: NO.** The approved image is an *externally generated GIF style demonstration*, not captured Godot, not an alpha VFX atlas, and must never be installed as runtime sprite material.

Immutable approved reference: ChatGPT Library `/TMB-VFX-Art/FIST10_R4_APPROVED_STYLE_REFERENCE_ONLY_20261116.gif`, `libfile_1859688550fc8191a0ff514c5b629238`, SHA256 `34204b5d4191e36f55444df9f9c88b27388a15093bf704a474abaade06285dcf`; GIF 89a, 552×309, 9 frames, ~180 ms/frame. **REFERENCE ONLY — no pixel cropping or screen extraction**, nor copying actors/UI/map/text into VFX. This is owner-approved **visual direction**, not approved implementation.

## Visual target — not the old physical gold bell

- A hollow, **translucent golden-white spiritual bell** with organic fluid calligraphic qi strokes, glowing curved outer dome, small lotus crown, suspended soft gold runes and broken ribbon-like motion. Not an opaque gold metal item, UI circle, solid triangular SVG outline or decorative item icon.
- Golden curled streamers charge from the **foot seal** around a separately rendered character, surge upward and briefly complete the glowing bell crown at cast peak, then shrink to a restrained and readable **4-second actor-following buff** without occluding the actor/monster.
- A short, defensive local **white-hot collision flare** on the incoming side and a brief resonant ripple; no outgoing strike, invented damage, monster debuff or second recipient. Fade via fragmented painterly arcs, not shrinking a static full-screen poster.
- The actor, monster, world map, labels, HUD and camera are separate runtime layers. The approved GIF may be used ONLY as visual QA reference; cannot be a sprite source, neither by frame crop nor background removal.
- Use original independent alpha VFX masters with intact provenance (no commercial JX/VL pixels): transparent crest, broad bell outlines, foot seal, painterly gold runes, impact accent, and dissipating fragments. Each active layer must have source-preserved, authored multi-pose animation (frame-by-frame, **NO RIG**), timing and actual actor anchors. Never present a concept or fake composite as a Godot result.

## Canonical contract (catalogue, unchanged)

`tmb.skill.fist.kim_cang.ultimate.human`, Earth guard / single_target / cap 1; cast 1.15 seconds, guard 4 seconds, cooldown 34 seconds, range 5.5, power .35, no projectile or damage. Reuse Combat V2 receipts only after separately authorized mapping; LAB-only synthetic block demonstrations are not real receipts.

## Production System V4 gates to clear before claiming R4 integrated

1. Preserve the original independently created transparent source and record provenance/source hashes. **Explicitly test that NO GIF screenshot pixels were used as atlas inputs.** Do not move the previously generated reference GIF into `godot/`.
2. Create true 4-direction-compatible effect attachments by recipient/projectile direction where applicable; skill remains a single-user target guard that follows character/monster WALK. A single atlas pose scaled/rotated 28 times or glyph-only code geometry fails source-art review.
3. Three true native Godot 4.7.2 (Compatibility) 1280×720 screenshots at **t=.42 (charge), 1.23 (peak), 2.16 (moving protected contact)** with two actors moving independently. Review source vs native scale/shape against this GIF; early STOP if geometric, disconnected, or flashing the whole recipient.
4. Real full native MP4/GIF and 12+ event samples, coherent alpha, occlusion and right-flank defensive contact, exact SHA GitHub Actions, independent technical/art/owner gates. Avoid CPU/GPU claims from encoded movie FPS.
5. Until owner reviews actual new Godot footage: `STYLE_REFERENCE_OWNER_APPROVED`, `R4_GODOT_NOT_RENDERED`, `OWNER_RUNTIME_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, `PHYSICAL_QA_PENDING`; preserve R3 technical evidence and FIST09 owner-approved art without modification.

Do not merge or switch branch, do not use Codex, do not rig, do not change Combat V2/SaveService/economy/live PvE/V6.3.