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