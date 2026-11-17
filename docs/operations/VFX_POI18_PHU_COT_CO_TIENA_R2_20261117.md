# POI18 R2 — Linh Cổ Liên Tâm: beautiful jade spirit-silk VFX
2026-11-17 · PR #72 Draft. Current owner feedback: **R1B TOO UGLY AND FRIGHTENING**. R1B native Godot G5 technical SUCCESS does not override explicit OWNER_ART_REJECTED. R1B has NOT been integrated into PvE; its prior assets remain unchanged in r1/ for history, not approval.

## G0 Canonical
Skill ID `tmb.skill.poison.co_doc.active_01.immortal.a`, lineage A (Tiên), element WOOD, effect MARK, shape SINGLE_TARGET, cap=1, range=7.8, cast=0.43s, cooldown=9.6s, projectile speed=8.96 WORLD units/s, mark duration=6.5s. hit_count missing. No VFX authority to invent hit, poison, damage, AoE, or actual target receipts. Combat V2 receipt time RUNTIME_MAPPING_PENDING, V6.3 OFF.

## G1 revised art direction after rejection
Owner's quality target: classic bright, pure jade and warm gold **beautiful spiritual light**, no horror. Discard dark scarab/bug anatomy, claws, fangs, segmented shell, insect eyes, rigid heart/UI glyph and murky smears. R2 visuals are original translucent non-anatomical soft silk wings and petal-like spirit seed, not commercial Võ Lâm pixels. Reference is approved original light/energy production practice, not copied art. The character frame and monster frame are unchanged, not rigged.

## G2 three clocks / storyboard
Combat authority: .43s cast, 6.5s mark, 9.6s cooldown, projectile speed8.96 WORLD units/s; receipt unknown.
LAB-only animation: 0–.43 three light petals converge into warm-white spirit seed; .43–.55 unfurl; .55–1.35 luminous silk flies continuously to a WALKING chosen enemy; t1.35 **simulated visual contact only**; 1.35–2.06 soft three-petal localized gold/jade bloom; t1.35–7.85 one target maintains two soft jade leaves connected with warm gold filament (6.5s); by8.10 all glow fades. Second moving enemy never marked. LAB loop8.5s not gameplay.
QA: first run short 1.8s Godot native G3.5 capture t.21 charge, .98 peak, 1.48 moving-contact, plus >=12 independent video checkpoints. Full 8.5s status movie only after manually judging those true native frames. Physical frame rate unmeasured.

## G3 original master / atlas / rights
Source generator: `tools/vfx/generate_poi18_phu_cot_co_tien_a_r2.py`. 48 independently posed first-party RGBA cells; gather 8x256², gu 16x320×256, local bloom 12x320², linked leaf mark 12x256², 4 independent master PNGs under `godot/labs/combat_lab/poison18_phu_cot_co_tien_a/r2/assets/master/`.
Painted translucent MIX jade/teal, soft feathered edges, controlled small warm-gold hotspot, white-ivory micro-core, separated low-alpha aura. No ghost copies or dark insect anatomy. No poster extraction, no commercial frame/pixel licensing claim. Art does not mutate actor sprite.

## G3.5–G8 independent gates
V4 packet `docs/operations/vfx_packets/POI18_R2_V4_PREFLIGHT.json`. Focused Godot test on real walking enemy + untouched decoy; exact 1280×720 screenshot capture is mandatory. First native review at **1×** must verify soft art, graceful silhouette, purity, wing motion, contact position, no UI-like target seal. If ugly or unreadable, G3.5 STOP and rework same skill. Technical PASS is not artwork approval.
Initial status R2 G3.5=NOT_EXECUTED; G5=NOT_EXECUTED; ART=MANUAL_REVIEW_PENDING; OWNER=VISUAL_PENDING; PvE=HOLD; physical Windows/Android=PENDING. Preserve rejected R1B only as audit history.
