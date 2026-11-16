# HF02 R5 — Source-painted luminous rebuild: exact Godot visual review (2026-11-16)

**Canonical skill:** Liên Diệm Phần Giới, `tmb.skill.talisman.hoa_phu.active_02.human`. Human Hỏa Phù circle damage; max 3 targets, circle radius 2.1, cast .62, projectile speed zero. All parameters read-only and unmodified in VFX work.

**Branch:** `integration/pve-p0-playable-ui-20261103`, PR #72 Draft. This is isolated, view-only `talisman07`; no gameplay/live PvE work.

## Evidence
- **Exact art/source SHA:** `24b956a3dc2c8f06c4a0bc0c2926c6d831d13012`
- **GitHub Actions run:** https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43792325968
- **Artifact ID:** `14192079073`, `vfx-tal07-24b956a3dc2c8f06c4a0bc0c2926c6d831d13012`
- Godot **4.7.2 stable Compatibility**, strict import, script parse, focused contract **PASS failures=0**.
- Native 1280×720 MP4 **198 frames / fixed output 60 fps**, GIF, 14 timestamped PNGs and contact sheet produced and uploaded. 60 fps movie output is **not** physical Android/Windows performance proof.
- At least 12 native moments inspected: .30, .43, .58, .70, .86, 1.10, 1.28, 1.38, **1.49, 1.62**, 1.84, 2.22 (with .12 / 2.75 for boundaries).
- Three previously chosen deterministic moving WALK-monster stand-ins; one bounded cosmetic contact per target; no extra target/hit/damage/HP/status/DoT or projectile.

## Actual art-source provenance and honest limitations
- The owner-provided original TMB concept of **Lôi/Hỏa/Phong Ấn Phù** served as the visual benchmark. One real original fire-explosion fragment was isolated, compressed to **320×91** RGB WebP, stored UTF-8/base64 at `godot/labs/combat_lab/talisman07/art_sources/hf02_r5_owner_fire_blast.webp.b64`. Its full concept poster was **NOT** used as a Godot gameplay screenshot. This is a **lossy sub-region**, not a full-resolution painted master; this limits eventual fidelity.
- Recipe `tools/vfx/hf02_r5_source_painted.py` un-mattes bright flame RGB/alpha, repairs a tiny dark image occlusion in the source hot core, bakes **12 flame, 8 contact and 12 tri-talisman RGBA poses** with actual per-cell pixel variations. The talisman family art uses the previous first-party gold-red 火 source from HF01; no Source VL/JX commercial source pixels.
- R4 ground scorch atlas remains as a deliberately dim view-only support layer, generated independently by the existing stage.
- New compositing preserves saturated warm material and local contact. **Not hand-drawn 12 unique master paintings**: this is moving/deformed original painted source, so do not misrepresent pose hashes as hand-painted motion or owner-quality art approval.

## Native 1× correction findings
1. R4 Godot at 1.49s (run 43712804172): 7 smooth, gold, candle-like procedural plumes; low material detail. R5: a wide connected painterly red/orange explosion, hot yellow focus and uneven fire tongues. Compare **actual videos at the same 1.49s** rather than poster boards.
2. R5 initial native proof at source `aac6a72f` technically PASS but exposed a broad dark **rectangular poster matte** at x~800..1100 behind the enemies (1.49s). Next SHA `a2b33cc2` removed the dark plate by alpha threshold and edge feathering; rerendered, Godot PASS.
3. `a2b33cc2` native review found small dark rectangular hit mats under the moving monsters at 1.49–1.62s. Exact source `24b956a3` rebuilt the contact sprite with a local soft, radial *alpha window* and bright cutoff. The new native 1.49s shows no visible contact square plates. This is **alpha isolation**, not a radial HUD circle or an added AoE/hit.

## Art gate
**GODOT_FOCUSED_PASS / NATIVE_MOVIE_PASS / OWNER_VISUAL_PENDING / ART_FIDELITY_PARTIAL / PVE_INTEGRATION_HOLD / V63_OFF.** R5 is substantially different from R4, but still lacks the high-resolution master-detail and fully developed emissive lighting in the reference illustration. Do not mark ART_APPROVED; do not reuse R5 as a default template for other schools. Keep previous R4 files for before/after audit. Further quality lift should replace the compact 320×91 reference fragment with a larger isolated hand-authored source and more materially distinct key poses, after explicit owner visual feedback.

**No Codex, rig, branch, merge, Combat V2, SaveService, economy, AI or PvE changes** in this work.
