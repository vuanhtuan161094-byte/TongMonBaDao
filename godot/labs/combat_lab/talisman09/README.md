# HF04 — Chu Tước Hồi Hoàn (Human) | native independent VFX

**Canonical source:** `godot/data/combat/v63_talisman_combat_catalog.json` → `tmb.skill.talisman.hoa_phu.active_04.human`, **FIRE** / `damage` / `circle` radius **2.35**, `target_limit` **3**, `hit_count` **1**, cast **0.50s**, cooldown **13.6s**, range **8.5**, `projectile_speed` **0**, duration 0. No damage/status/DoT/homing or extra hit added.

## VFX identity and source rights

The separate HF04 cast-master features a first-party painterly **vermillion bird** / Chu Tước, returning fiery feather arcs around **one previously selected AoE circle**, one simultaneous local fire contact on three independently moving monster sprites, and a clean ember fade. No true gameplay projectile; bird path is a *cosmetic orbit*, not an invented Combat V2 actor/hit.

Source generator: `tools/vfx/hf04_r1_que_tuoc.py`, uses only original project-owned paper, Hỏa Long and flame master `.b64` files in `talisman06/art_sources` and `talisman07/art_sources`. Recombines **real painted pigment textures** into a novel multi-feather silhouette; it is **not** 16 separately hand-painted complete bird masters, so this requires native 1× source-fidelity review. Source A/JX/Source VL commercial pixels not copied. Promotional concept imagery, including any AI-generated poster with words `Godot PASS`, is **not gameplay evidence**.

Atlas flipbooks (baked on GitHub runner before Godot import):
- `tal09_r1_charge.webp` 12×320×320.
- `tal09_r1_phoenix.webp` 16×512×320 (source-painted independently animated bird feather/wing/body/tail).
- `tal09_r1_orbit.webp` 12×640×340 (painterly elliptical energy trail with gold-red scrolls, NO code UI circle).
- `tal09_r1_contact.webp` 10×256×256 (local fire on each moving target, one cap3 circle pulse).

## Three clocks / separate approval gates

1. **Catalogue real authority**: .50s cast, cooldown13.6, no projectile, one circle AoE hit (up to 3), actual runtime event timing **UNKNOWN**. No claims of Combat V2 receipts; game integration OFF.
2. **Isolated LAB visual**: charge .02–.68, summoned bird .58–2.04, elliptical return .78–2.24, one contact pulse at 1.60–1.92, fade by 2.55. Three monster current-pos anchors are maintained throughout. Bird orbit does not imply hit events.
3. **Demo/QA clock**: 3.12s fixed-length movie/replay is NOT cast or cooldown.

**Production System V4:** G0 canonical contract, G1 rights, G2 distinctive storyboard, G3 original sprite source and changing key poses, G3.5 **real Godot 4.7.2 1280×720 screenshots** charge .30, peak 1.29, contact 1.71 (requires 116 frames), G4 moving-anchor test, G5 full real movie 187 frames+12 stills, G6 human art review >=4/5 on core components, G7 owner explicit approval. **G8 PvE/Android/Windows performance remains separate.**

Do not edit owner-approved HF02 R6 (10/10, SHA `b5a29f15`) or HF03 R2 (approved 16 Nov 2026, SHA `ac3b02b1`). No rig, Codex, branch, merge, Combat V2, SaveService, AI, economy, PvE or V6.3 changes. Technical CI PASS does not mark art PASS.
