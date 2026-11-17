# FIST12 — Đoạn Mạch Liên Quyền | Energy-first Godot VFX / R1

**PR #72 (Draft)** · branch `integration/pve-p0-playable-ui-20261103` · Godot 4.7.2 Compatibility · 1280×720 native video · V4 production gates.

## G0: Canonical, unchanged

ID: `tmb.skill.fist.huyet_quyen.active_02.human`. **Nether / MARK** on exactly **one** target; declared cast **0.45 s**, 6-second mark duration, 8-second cooldown, range 2.8, power 1.15, radius 0, projectile speed **0**. Catalogue omits `hit_count` — the packet deliberately specifies `null`, and does not fabricate a hit count. No actual damage, healing, poison, debuff or gameplay mark is implemented; LAB is strictly view-only. V6.3 OFF.

## G1–G3.5: Original golden-energy workflow adapted to Huyết Quyền

User asked for *ánh sáng năng lượng* instead of obvious flying punch-sprite; first-party FIST11 R2 used only as contrast. Art direction follows living ruby/rose/violet qi and broken meridian lines, not rigid flat crimson hand, a uniform vector ring, or a recolored stock weapon. Core is ivory-hot light with ruby-pink body and soft violet-red halo. One local contact opens a **six-second broken-meridian sign** carried by the moving target.

**Original asset provenance:** `/tools/vfx/generate_fist12_doan_mach_lien_quyen.py` authors energy path silhouettes, fractures, original 36 animated alpha poses. To reduce digital-vector appearance, the generator uses **luminance micrograin only** from first-party original `godot/labs/combat_lab/fist03/assets/impact_master.webp`, with no borrowing of the image-shaped border, hand, stone or copied commercial source. This is code-authored first-party light art, **not** a newly commissioned/ImageGen-painted master; quality remains subject to 1× manual review. No rig or GIF creation/extraction.

R1 original four atlas pages: charge `8×256px`, energy stream `12×320px`, contact `8×320px`, mark `8×192px`; raw RGBA budget **11,468,800 B** (about 10.94 MiB), excluding any engine import overhead. A separate alpha `f12_original_energy_master.png` is baked and hashed for provenance. The light wave is **visual-only**, as the canonical skill has projectile speed zero. The branch-like streamers depict *one mark application*, not additional Combat V2 hits.

## Separate 3 clocks

* **Canonical combat:** cast 0.45s, mark duration 6 seconds, cooldown 8 seconds (actual Combat V2 event time unresolved).
* **LAB visual:** charge `0–0.45s`, travelling energy `0.45–0.92s` (purely cosmetic), one local mark application at `0.92s`, animated mark `0.92–6.92s`, translucent fade by `7.22s` (7.60s loop). No real runtime receipts are claimed.
* **Native Godot QA:** at exact SHA emit `v4-charge.png` (0.22s), `v4-peak.png` (0.74s), `v4-contact.png` (0.99s) on an independently WALK-moving actor, then 19+ sampled 1280×720 frames including t4.0 and t6.8, plus full native MP4. This does NOT establish physical-device performance.

## Human-owner gates

Required at 1x: convincing energy light (not rigid UI lines), smooth braid flow, correct contact anchor on WALK mover, clear 6-second but unobtrusive mark, no hard crop edges or photoposter alpha, no missing frames or imaginary multiple hits. **Never** state art approved from GitHub Actions technical success. `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, `PHYSICAL_QA_PENDING`; do not change Combat V2, SaveService, PvE, economy or V6.3.

## R1 native G3.5 review → R2 repair (2026-11-17)
- R1 exact-SHA `205e6d0f49ace65de9e9ec4f453d6d3b997f8951`, Actions #43995071867 technical **SUCCESS**; actual 1280×720 video and 20 screenshots showed an energy WEDGE/arrow with rigid crescent at t0.74 and a large pink contact obscuring the target's face t0.99. **R1 ART_SELF_FAIL**, not owner-accepted.
- R2 changes the actual **sprite source**: five independent intertwined meridian-current curves dynamically crossing and oscillating, broken light knots and source-derived granular detail; remove the fake UI crescent and pointed arrow silhouette. Contact and six-second vein mark moved to target upper chest (-84px from foot) and local burst slightly reduced. Mark contract remains 6 seconds, no real damage or status mutations.
- Repeat true 1x native G3.5 and full 7.6s movie, inspect target head/alpha/marked-mover behavior. No GIF pipeline, no rig, V6.3 OFF.

## R3 — R2 owner rejected; distinct triple pressure-echo remake (17 Nov 2026)
- OWNER REJECTS R2: "không đẹp. k có cảm giác skill đó." R2 exact-SHA technical PASS is not art approval.
- R3 replaces the generic moving pink plasma rope with **three visual-only martial force echoes**, four different hand-authored transparent RGBA source poses per beat, entering from three different angles at ONE moving enemy. Three visual echoes are NOT hit_count=3 nor additional Combat V2 hit receipts. Canonical mark is still one application on one actor.
- Instead of a UI ring, the local application draws THREE interrupted glowing meridian channels and a six-second broken-vein tracer attached to the recipient's chest.
- Code-authored first-party raster light paths with owned FIST03 painting luminance grain; it is NOT a newly independent ImageGen master and may still require source-art improvements. No GIF, rig, actor/background pixels or commercial JX art in VFX atlas.
- Actual exact-SHA Godot 4.7.2 1280×720 MP4 at charge 0.22, second echo/peak 0.74 and one mark application 0.99; review 6s mark in motion, owner approval manual. Keep PvE integration, V6.3 and physical QA on hold.

## R4 in-engine martial choreography correction, 17 Nov 2026
- R3 SHA 2b5ca416ffa9cff1f5381400cb5f73d9a96adb5a exact-SHA Godot Actions #43998534486 TECH SUCCESS, but manual review shows floating claw-like ribbons and a mostly stationary caster: ART_SELF_FAIL; owner rejection of R2 remains unaddressed.
- R4 adds a short, actual LAB-only actor dash to contact range followed by three timed wrist-origin light punches and retreat. Uses preexisting separate approved actor sprite for a faint motion afterimage, not copied into the VFX atlas. Contact contraction to 0.77 centers the broken meridians on the recipient's chest.
- Three echoes remain one illustrative MARK event with no invented 3 hits. Code source derives original alpha assets; no GIF or rig. Recheck exact-SHA Godot movie and manually inspect before reporting art.

## R5 deliberate strike silhouette re-authoring (17 Nov 2026)
- Exact R4 Godot Actions #43999142484 TECH PASS on SHA b6c073aa3ce3474ec6783555cf871e4287958f53; manual art review: caster dashes but pink claw ribbons remain poor articulation of repeated fists. **ART_SELF_FAIL**.
- R5 re-authors 12 consecutive strike-pulse RGBA poses (3 visual beats × 4 frames each) as localized **three asymmetrical inward pressure blooms with a compact hot ivory impact**, burst petals and original first-party painterly pigment rather than a long uniform ribbon. R4 LAB martial dash + hand-source synchronized flashes are retained. Mark-apply moved 28px down to target chest; 6s mark remains independent.
- No new gameplay hit_count or outgoing damage; canonical projectile_speed 0 mark, no rig, no GIF, no actor pixels in VFX source, V6.3/PvE/CombatV2 unchanged. Technical exact-SHA and owner visual gates separate.
