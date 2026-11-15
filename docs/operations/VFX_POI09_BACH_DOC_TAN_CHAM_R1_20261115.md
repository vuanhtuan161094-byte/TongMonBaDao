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
