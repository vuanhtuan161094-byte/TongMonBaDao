# POI09 — Bách Độc Tán Châm Human — painted source, isolated Godot Combat Lab

Date: 2026-11-15. PR #72 Draft, branch `integration/pve-p0-playable-ui-20261103`. Next skill after owner provisionally accepts POI08 R4 with polish debt. Preserve POI07 R7 owner-accepted and POI08 R4 artwork unchanged.

## G0: exact Human skill contract (metadata, no V6.3 enabling)
`tmb.skill.poison.doc_cham.active_03.human`, name Bách Độc Tán Châm, poison/doc_cham/active Human, element `nether`, effect `poison`, shape `circle`, radius `2.8`, target_limit `3`, range `7`, cast_time `0.6`, cooldown `11`, projectile_speed `8`, poison_stacks `1`, duration `6`, damage_ratio `0.95`. The catalogue is authoritative. Concept art is never evidence for numerical contract: the first-party poster carries decorative numbers that may disagree with catalogue and **MUST NOT** be imported as game statistics.

## G1–G3: exclusive POI09 painted-source sprite identity and provenance
A first-party originally generated illuminated game showcase poster from project chat `a_detailed_cinematic_game_vfx_showcase_poster_wi.png` (SHA256 `db1572059d49bfc4152288b3140b9e5a27915570874ce213d6830be5f3b7c72c`) is *source material only*, **not** a gameplay screenshot or an approved VFX. Only original painted light pixels were cropped and alpha-matted; no actors, text, damage numbers, HUD boxes or licensed third-party/VL/JX/Source A assets are reused. The runtime never loads the poster, only four transparent atlas textures.

Independent first-party RGBA painted masters:
- `assets/master/fanlotus_charge_master.webp` from source crop (509,632,685,737) — purple poisonous lotus opening at caster palm.
- `assets/master/poison_needle_master.webp` from source crop (765,191,1055,308), with cropped single head and a trailing jade/purple light; no double-projectile baked into one cell.
- `assets/master/burst_contact_master.webp` from source crop (991,638,1177,737) — local petal/star burst per contact.
- `assets/master/sixsecond_toxin_master.webp` from source crop (1220,632,1408,736) — organic toxin bloom at each victim's chest.
The extracted masters have transparent feathered edges; alpha inspected over dark and light backgrounds. No character rigging.

**Master identity is new and specific to POI09**; no POI07 R7, POI08 R4 or R11 atlases shared. `tools/vfx/generate_poi09_painted.py` animates the isolated painted source pixels with per-frame nonrigid warping, scaling and alpha poses. It does not synthesize replacement neon vector outlines.

Four original 4-column RGBA8 flipbook atlases, total **46 distinct frames**:
- `poison_fan_charge_r1_12.png`: 12 frames 224×160, atlas 896×480.
- `poison_fan_needle_r1_12.png`: 12 frames 256×96, atlas 1024×288.
- `poison_fan_contact_r1_10.png`: 10 frames 192×160, atlas 768×480.
- `poison_fan_mark_r1_12.png`: 12 frames 192×160, atlas 768×480.
Raw four-atlas resident RGBA8 estimate `5,849,088 bytes` = **5.58 MiB**. CI must verify per-frame alpha, distinct SHA256, <=8MiB budget. This is NOT measured physical Android FPS/VRAM and no guarantee of no lag for 3+ simultaneous casts.

## G4: visual storyboard, moving enemy placeholders
Dedicated scene `res://labs/combat_lab/poison09/r1_painted/bach_doc_tan_cham_r1.tscn` is isolated, 1280×720:
- 0.00–0.60 s: one poison lotus opens/concentrates at caster palm.
- 0.60–1.69 s: one cast disperses into **three distinct original needle sprites** on separate straight, slightly staggered trajectories to no more than three target locations.
- ~1.53/1.61/1.69 s: exactly one localized chest-contact visual per moving target, no extra hit.
- 1.53/1.61/1.69 through +6.00 s: individual small poison blossom MARK follows each moving stand-in chest every rendered frame.
- After six seconds, each individual mark fades over ~0.32 s; all effects gone by t=8.02s, next view-only loop t=8.62s.

Moving targets are deterministic *visual placeholders using the already-approved Stage A actor texture*, not a fake PvE battle or a new targeting algorithm. Each needle is anchored to its target's predicted **contact-frame position**, avoiding a miss even though mock targets continue to move. The local mark follows target positions, rather than remaining static in world space. True combat range/radius/target selection and poison tick authority remain in the canonical Combat V2 system, untouched here. `effect=poison` and one 6s stack are catalogue descriptions only; no HP, status or gameplay writes.

## G5–G7: native QA & owner gate
`.github/workflows/vfx-poi-09-r1-painted-native.yml` pins official SHA256-verified Godot 4.7.2 Compatibility, restores the unchanged Stage A accepted sprite for the isolated lab, bakes and tests atlases, runs strict Godot import/parser/focused contract, records a genuine 1280×720 / 519 frame / fixed 60fps movie, 14 1× phase stills, MP4, GIF and media SHA256. A guarded same-branch non-force commit stores atlas binaries and re-runs exact final asset SHA. Human actor rig, Codex, new branch, merge, V6.3, Combat V2, SaveService, live PvE and other school art are all forbidden.

Expected status until evidenced: `POI09_TECH_PENDING`, `POI09_OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, `V63_OFF`, `PHYSICAL_DEVICE_QA_PENDING`. A green CI is **not** art approval. Record actual evidence only after successful run and visual review.

## Native QA evidence and R1 fan-lane correction (2026-11-15)
- Initial source `e03069c84daaf92ed3e09812ac5da74cc0e61bba`, [Actions run #43711019914](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43711019914) **SUCCESS**; first real 14-frame contact sheet revealed three needles overlapping at t=1.02–1.28, visually reading as one projectile despite three independently coded positions. Technical PASS did **not** override this visual failure.
- Changed ONLY isolated POI09 Lab scene and focused test: target stand-ins now occupy three visibly separated vertical lanes (screen base y≈460/549/637); cast outputs use 0.105s start stagger and 0.12s contact stagger. Tests assert >35px separation of neighboring painted needle tips at t=1.35 while each predicted tip hits its own **moving** target at the exact impact time. No change to circle radius 2.8, cap 3, poison 6s/1 stack or gameplay authority.
- Corrected R1 source/test SHA `eb59329af562bbcae9f7ae5a900a3079a9eb417f` with original 4 binary atlases already tracked on shared PR branch: exact-SHA [Actions run #43711514843](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43711514843) **SUCCESS**, native [artifact #14161165303](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43711514843/artifacts/14161165303).
- Official SHA256-pinned Godot 4.7.2 GL Compatibility, strict import/parse, `VFX_POI09_R1_RESULT=PASS failures=0`. Authentic Godot 1280×720 fixed-60-FPS H264 movie, **519 frames / 8.65s**, GIF and **14 source-frame 1× PNG checkpoints**. Media checksums independently verified **16/16 matching**, MP4 SHA256 `5fd419525b0385a0d96cc1f4a9df0fce9c226378a5353aa8746ce3a65abdc11f`. Movie fixed frame clock is *not* physical device FPS.
- Native visual comparison at 0.38/0.77/1.02/1.28/1.54/1.69/1.86/2.16/4.20/7.35/7.86/8.35 confirms distinct screen trajectories and sequential contact on three *moving visual stand-ins*; local floral toxin marks follow their motion and fade; no actor face hidden; no additional/missing target. Appearance uses first-party painted source pixels.
- Alpha/uniqueness: **46/46 distinct frames**, four alpha atlases with border zero; exact raw RGBA8 budget **5,849,088 bytes = 5.58 MiB**. Atlas texture burden per VFX library instance only; multiple simultaneous casts, GPU driver timing, Android thermal/performance, actual PvE target resolution still **UNTESTED**.
- Separate gates: `GODOT_FOCUSED_PASS`, `NATIVE_MEDIA_VERIFIED`, **`OWNER_VISUAL_PENDING`**, `V63_OFF`, `PVE_INTEGRATION_HOLD`, `PHYSICAL_ANDROID_WINDOWS_QA_PENDING`; not release-ready. POI07 R7 remains approved; POI08 R4 remains *provisionally acceptable for proceeding with a polish backlog*, **not** final art approved.

## Owner visual approval — 2026-11-15
Owner reviewed native POI09 R1 movie and explicitly replied **“Ok duyệt”**. Therefore **POI09 Human R1 artwork OWNER_VISUAL_APPROVED**, not merely technical Godot PASS. Applies to this skill/tier/art only: it does **not** authorize game integration, reuse for tiers, Android/Windows physical performance, PvE/V6.3, merging PR #72, or any Combat V2 / SaveService change. The canonical poison ledger row records `OWNER_VISUAL_APPROVED_R1 / OWNER_VISUAL_APPROVED / HOLD_V63_OFF`. Preserve all approved assets and scene untouched.
