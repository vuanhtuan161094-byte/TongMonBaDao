# FIST14 R5 — Liệp Huyết Truy Đả

**Status as of 18 Nov 2026:** G0–G3 source review passed; G3.5 1× visual self-review passed after the charge layer repair; G3.6 dark/bright contrast and G3.7 unlabeled semantic self-reviews passed; G4 anchor/movement focused checks and G5 native motion review passed on source SHA `e42447ee0c06f935a46b6da45b3bdf20a0944de4`. G6 self-review is recorded below. Final G7 exact-SHA verification is pending the current test/report update. Owner visual approval is pending; LAB only, PvE and device testing remain on hold.

## G0 — canonical authority

Initial R5 design HEAD: `38e4482da515b61fa5a04a9c89e80c72455eed96`. PR #72 was re-fetched before the last focused-test change at `e42447ee0c06f935a46b6da45b3bdf20a0944de4`, on `integration/pve-p0-playable-ui-20261103`; it remains Draft/Open, no merge. Skill: `tmb.skill.fist.huyet_quyen.active_04.human`, **Liệp Huyết Truy Đả**. Canonical contract: `effect=mark`, `element=nether`, `shape=single_target`, `target_limit=1`, `range=2.8`, `radius=0`, `cast_time=0.45s`, `cooldown=8s`, `duration=6s`, `projectile_speed=0`. `hit_count` is not declared. Runtime Combat V2 receipt/mark timing remains `RUNTIME_MAPPING_PENDING`; the LAB's contact at 0.90s is a simulated visual cue, not a combat hit. No damage, hit count, projectile, homing, extra target, or additional status is created here.

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

## Native V4 gates and self-review

- **G3.5:** native Godot 4.7.2 1280×720 1× charge/peak/contact on [run #44320413830](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44320413830), source SHA `e42447ee0c06f935a46b6da45b3bdf20a0944de4`. Moving the charge sprite above the unchanged caster made the clenched hand readable at `t=0.20`; peak at `0.62` and contact at `0.94` are fist-shaped, target-relative, and leave the target face visible. Visual contact is at the moving target torso, not a gameplay collision receipt.
- **G3.6 / G3.7:** native dark/bright 1× run [#44322802727](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44322802727), same source SHA, 9.45s. A supporting red-pixel probe compared active ROIs against same-background idle frames (charge ROI 160×135; peak/contact ROI 230×135; threshold `R≥70, R−G≥28, R−B≥25, R>1.25G`). Dark scene counts: charge **3117 vs 239** idle, peak **4698 vs 4**, contact **3693 vs 4**. Bright stone-floor counts: charge **3144 vs 236**, peak **4803 vs 8**, contact **3802 vs 8**. The probe supports visibility only; manual 1× review found the blood-red fist distinguishable on both scenes. No HUD or skill label is present; the visible story reads as a clenched blood-qi strike to one moving target. The face stays visible. G3.6/G3.7 are internal self-passes, not owner approval.
- **G4 / contact and movement:** the focused Godot contract checks one selected target moving left during the strike, a stationary pre-movement anchor, its rightward return during mark sustain, and target-relative contact/mark anchors. Target index 1 has no anchor. These are LAB visual checks; no gameplay collision callback or runtime mark receipt exists.
- **G5:** full native motion review on [run #44323702384](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44323702384), same source SHA. The MP4 is 1280×720, 60 encoded fps, 9.45s, SHA-256 `49f5d17e4eb3cf4a08cc2b4c3fbe06ab2739eff6c46dcd72fd4e90de2b0cc5dd`. Sixteen frames extracted from that Godot video were reviewed at 0.20, 0.38, 0.50, 0.62, 0.80, 0.94, 1.04, 1.20, 2.00, 3.90, 6.89, 7.04, 7.25, 8.20, 8.62 and 8.94s. Contact tightens into recoil, the single mark follows the target through sustain, fades from 6.90–7.20s, and is absent at 7.25s. The first dark loop completes through fade; the next light-floor loop shows charge, peak and contact. Continuous encoded motion is native Godot; 60fps is not a hardware performance measurement.
- **G6 self-score (0–5):** silhouette **4**, original material/light **4**, choreography **4**, composition/occlusion **4**, contact **4**, fade/status readability **4**, fist-school identity **4**, 1× readability **4**. No category is inferred from CI. Crowd readability, 6v8 / 30×40 load, physical device performance and Combat V2 receipt alignment are not measured here.
- **G7 / G8:** final exact-SHA strict import/parse/focused/native run is pending this report/test commit. Owner visual approval remains pending; live PvE, V6.3, Windows/Android and physical performance remain hold/pending.

## Rights and limits

The R5 artwork is original ImageGen output made for this project. JX1, Source VL and screenshot research were used for motion/readability observations only; no reference pixels are included. The existing approved valley, actor and walk-monster assets are read-only scene references. R2/R3/R4 sources remain frozen. This record does not approve art, live combat integration, V6.3, or device performance.
