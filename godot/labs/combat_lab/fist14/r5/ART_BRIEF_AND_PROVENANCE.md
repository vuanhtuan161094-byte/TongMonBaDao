# FIST14 R5 — Liệp Huyết Truy Đả

**Status:** G0/G1/G2 complete; six independent original RGBA sources made; G3 packet, alpha and atlas checks passed. Native G3.5 technical captures passed on [run #44314540322](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44314540322) and [run #44315336346](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44315336346). The first 1× art review was **ART_SELF_REWORK**: initial cast fist floated away from the caster hand, and the peak/contact artwork overwhelmed the target. Scale/alignment rework preserved the face but moved contact too low onto the legs; the next G3.5 pass moves peak/contact/mark to the upper torso. G3.5 visual acceptance is still pending; no G5/full render has run. Owner visual approval pending. LAB only, PvE hold.

## G0 — canonical authority

Latest PR #72 HEAD checked before R5 writes: `38e4482da515b61fa5a04a9c89e80c72455eed96` (`integration/pve-p0-playable-ui-20261103`). Skill: `tmb.skill.fist.huyet_quyen.active_04.human`, **Liệp Huyết Truy Đả**. Canonical contract: `effect=mark`, `element=nether`, `shape=single_target`, `target_limit=1`, `range=2.8`, `radius=0`, `cast_time=0.45s`, `cooldown=8s`, `duration=6s`, `projectile_speed=0`. `hit_count` is not declared. Runtime Combat V2 receipt/mark timing remains `RUNTIME_MAPPING_PENDING`; the LAB's contact at 0.90s is a simulated visual cue, not a combat hit. No damage, hit count, projectile, homing, extra target, or additional status is created here.

## G1 — observed references and limits

- JX1 Võ Đang #158 source sheets were viewed directly from their manifest crops: 10 precast poses at 50ms, 17 cast poses at 50ms, 8 impact poses at 40ms. The visible rhythm compresses small light masses, extends a narrow vertical sword form, then reduces the impact to a compact bright shape. This is sword material and is used only as a compression/peak/decay rhythm reference.
- Source VL sword 150 was viewed directly: 36 cast frames and 21 hit frames at 30ms. Its vertical luminous blade grows inside a dark smoky mass; thin filaments spread and later contract around the hit core. This is a sword sequence, not fist evidence. Commercial sprite pixels are reference-only and were not copied into R5.
- Existing JX / Kiếm Thế battlefield comparisons in `VFX14_JX_KIEMTHE_NKVS_VISUAL_COMPARISON_20261112.md` are screenshots, not frame-timed recordings. They show 2.5D combat readability, directional accents and the need to preserve actor silhouettes in crowded scenes; no fist cadence or internal implementation is inferred from them.
- FIST13 R7 review supports keeping any six-second mark compact and below the head/face. Its art is not reused. No first-party JX/Kiếm Thế fist clip was present in the inspected source manifests, so FIST14-specific reference motion remains unknown.

## G2 — visual identity and storyboard

Identity: a **physical fist of living blood-qi**, with four clear knuckle planes and a locking thumb; a short integrated wrist tapers into three unequal brush-cut pressure streamers. Dark oxblood/garnet body planes and translucent crimson seams carry the mass; a few pale red-white cuts define knuckles/contact. Asymmetrical gaps and a tight impact fracture keep the force directional. It must read as a fist at approximately 1× combat scale, not as a round aura or a long free-flying ball. There is no actor rig or fabricated punch animation.

| Beat | Local LAB time | Original pose | Anchor and intent |
|---|---:|---|---|
| Gather | 0.10–0.45s (canonical cast window) | `charge_coil` | Compact knuckle mass at caster-hand cue; trails bend inward. Cosmetic cue only. |
| Release | 0.45–0.62s | `release_lunge` | Short, taut pressure silhouette appears at the selected target anchor; it does not travel across the arena. |
| Peak | 0.62–0.90s | `peak_strike` | Broadest readable fist form follows the moving target's chest anchor. |
| Contact | 0.90–1.04s | `contact_impact` | Knuckle plane compresses; small asymmetric fracture stays on the torso. This is simulated visual contact only. |
| Recoil | 1.04–1.27s | `recoil` | Fist rolls back and separates into four tapered living strokes; alpha then clears. |
| Mark | 0.90–6.90s | `meridian_mark` | Small three-cut scar follows the one selected target near the upper chest/shoulder; fades over 0.30s. LAB timing reflects the declared duration but is not a runtime receipt. |

The combat clock remains catalogue-gated. The local motion clock is a view-only LAB sequence. The showcase clock repeats once on a light stone floor after the dark-valley run to check contrast. No trail is interpolated from caster to target, because `projectile_speed=0`.

## G3 — source and provenance

Six full-resolution PNG RGBA sources are retained in `source/`: five separately generated attack/contact key poses and one separate compact target-mark design. Each image has real alpha; the original art files are kept byte-for-byte. The initial first-party ImageGen concept was restyled as a 2D painted source; each attack pose was then generated as a new pose from the material reference, with distinct hand/streamer shape. The mark was generated independently. No R2/R3/R4 sprite, JX sprite pixel, rig, GIF, shader, vector fist, or code-drawn attack shape was used.

`tools/vfx/generate_fist14_r5_atlases.py` only packs the six unchanged sources into transparent, 2048×1024 cells. It never draws, recolors, rotates, duplicates, or warps a pose. The atlas manifest stores each original's SHA-256, source size/alpha bounds, cell offset and focal point. Review the raw masters as well as the packed layers: atlas byte uniqueness proves integrity only; native Godot motion and art fidelity are still human gates.

## Rights and limits

The R5 artwork is original ImageGen output made for this project. JX1, Source VL and screenshot research were used for motion/readability observations only; no reference pixels are included. The existing approved valley, actor and walk-monster assets are read-only scene references. R2/R3/R4 sources remain frozen. This record does not approve art, live combat integration, V6.3, or device performance.
