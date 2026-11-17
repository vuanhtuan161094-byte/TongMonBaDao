# PAF04 – Hộ Mệnh Lưu Văn: R7 OWNER REJECTED / R8 G3 ART STOP (17/11/2026)

## Owner's latest directive and prior gate

Owner: "đọc lại quy trình làm vfx. lại lại đi. sai qusa rồi". Earlier owner decision: R6 **phase order/timing approved** but **aesthetics rejected**; R7 shown as a native Godot candidate was also rejected. Do **NOT** call R7 owner-approved. R6 original technical proof remains historical only and neither R6 nor R7 is the accepted PAF04 master.

Mandatory source documents freshly re-read before work: `AGENTS.md`, `docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md` (especially V4 G3.5 STOP and V4.3.1), `.agents/skills/tmb-vfx-art-director/SKILL.md`, `docs/operations/TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md`, `docs/operations/TMB_VFX_SPRITE_FIRST_QUALITY_RULES_20261114.md`, `docs/operations/TMB_VFX_PAINTED_SOURCE_TO_GODOT_ASSET_GATE_20261114.md`. Latest PR #72 HEAD at start of this art audit: `adbf7b2e995ab2d53a001295146a224228296ae2`; subsequent unrelated HEAD changes must always be rechecked.

## G0 canonical skill contract – UNCHANGED

- `tmb.skill.talisman.phong_an_phu.active_04.human`, element Wind, `guard/mitigation`, single target, `runtime_self_guard`, target=SELF, hit_count1, range8.5, cast0.5s, cooldown13.6s, duration4.0s, guard power0.16, projectile_speed0, damage_ratio0.
- R6 owner-accepted **visual order only**: charge → formation → protection-lock → optical fade. Do not conflate the 4s defensive status with a 4s cast/reveal. Actual live Combat V2 guard receipt is UNKNOWN/`RUNTIME_MAPPING_PENDING`. No real status writer, PvE/Combat V2/SaveService or V6.3 changes.
- Must never present an ImageGen infographic/poster as a screenshot of real Godot output or a texture imported into the game.

## Diagnosed violation – why R7 failed art-first

1. Instead of mastering first-party illustrated high-res material, R7 repeatedly recreated thin Pillow lines and called them painterly. At native gameplay 1x these were still isolated neon strokes rather than coherent living glass.
2. A static/near-static round glow and consistent arc disposition created a generic bubble shield. The moving light alone didn't give the principal material a living silhouette.
3. The protective field/actor relative placement hovered high over caster, with little change in material apparent scale.
4. R7 technical green CI gave no evidence of artistic approval; source texture authenticity and dark/light 1x comparison were insufficient.
5. Prior ImageGen outputs included full **infographics with titles/actors/QA text**. Such posters are not production VFX sprites. This violation is now explicitly logged.

## R8 G2 / G3 work actually done (NOT native Godot)

- One original first-party ImageGen concept was used as **research/donor art only**. A genuinely transparent 640x432 PNG glass-arc source was extracted with region + hue + alpha feathering; additional isolated gold talisman ornament, independent back and front alpha layers and 6 individual WEBP atlas sources were produced offline. Source uses original 1672x941 generated artwork; original source is preserved inside the ZIP, never presented as a Godot image.
- Atlas inventories: 12 charge (320²),16 BACK (352×448),16 FRONT (352×448),14 lock (320²),8 shimmer (256²),8 badge (128²) = 74 authored source poses. Generated pose difference and source hashes in manifest are **integrity/motion diagnostics only**, not artistic PASS.
- R8 source raw concept SHA256: `6a16cd017613abe64d39b1a59401a41d152ef66579ae92c782a317cda7d587a4`. Independent 640×432 transparent master SHA256: `24a1b442ad4fe334f7c1bbee2b9d02c1f04bf647403a4f33a69d51fbd355e93d`.
- Durable source packet: ChatGPT Library path `/TMB-Character-Art/PAF04_R8_G3_SOURCE_CANDIDATE_20261117.zip` (original source, cleaned alpha, 74 atlas poses, reproducible local scripts, native-size offline frame comparisons, SHA manifest and short offline movie).
- An **OFFLINE 1280×720 compositing preview** was made to measure visual scale/anchor. It reuses a captured existing R7 Godot backdrop; it is *NOT* a native R8 Godot render, and 60fps export is not physical FPS. No R8 assets were integrated into the PR or a live game.

## G3 art STOP: fail honestly, no repeat of the same mistake

Self-inspection on both dark and light matte and a 1x character composite still identifies a **bubble/arch silhouette** rather than the distinctive energy and flowing gold rune release requested. The new source has stronger material than R7 but the visual is not yet sufficient. **G3 ART_REWORK_REQUIRED**. Do NOT auto-advance to G3.5 native proof as if the silhouette were accepted; rework hero morphology first. Never increase zoom, generic glow or add more lines to hide this defect.

Gate results at this record:
- G0/Contract: VERIFIED from previously tested catalogue; G1 provenance FIRST_PARTY documented; G2 original artist-direction review FAILS.
- G3: prototype RGBA/atlas delivered, **ART_REWORK_REQUIRED**; G3.5 true Godot R8: NOT_EXECUTED; G4 moving self native: NOT_EXECUTED; G5 R8 native MP4: NOT_EXECUTED; G6 art: REWORK_REQUIRED; G7 exact-SHA R8 CI: NOT_EXECUTED; G8 owner: R7 REJECTED, R8 NOT_SUBMITTED/OWNER_VISUAL_PENDING; PvE HOLD; Windows/Android device QA PENDING.
- Existing Godot PAF04 R7 code, Combat V2 and all prior accepted assets remain unchanged. No Codex, no rig, no new branch, no merge, no GIF.

**Next valid action:** isolate a different distinctly flowing non-circular artistically authored main hero master and verify at game-size 1x and high-contrast terrain before generating another PAF04 native proof. Do not call this packet an accepted VFX.
