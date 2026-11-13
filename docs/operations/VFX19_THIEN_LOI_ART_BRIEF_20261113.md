# VFX19 — Thiên Lôi | Art brief BEFORE code (2026-11-13)
PR #72 Draft / integration/pve-p0-playable-ui-20261103 / source base 95a243d5c59029107ef04bdb87957fd762e2f4a6.

**User art reset**: VFX18.2 is visually **REJECTED** by owner; do NOT claim artistic improvement or reuse luminous sword-qi composition. Owner explicitly wants a demonstrable **THIÊN LÔI** skill. He noted a previous sét/light serpent style looked much better. Self-implementation on GitHub, not delegated to Codex; answer to Codex question: Codex can engineer but cannot certify commercial aesthetic.

## Visual identity
This must read as **lightning/plasma**, not a sword, a flat zigzag ladder, a comic outline, or an energy ring. Inspiration: own preexisting `godot/labs/combat_lab/combat_lab_v9_energy_fx.gd` (serpent light and four-layer white core with cyan/violet glow) and classic JX lightning references *only for principles*. Do not copy JX image/code.

Palette: narrow white core (#f5fbff), electric cyan (#75eaff), azure (#377ed8), sparse blue-violet (#9463eb). Strong differences between main discharge, secondary/tertiary forks. Source root is sky or caster. Ground impact stays localized and dissipates in electrical tendrils rather than a big opaque circular splash.

## Eight canonical frame milestones, 3.20s loop
- 0.10s: tiny luminous electrode wake near caster's raised arm, a few short fractured white branches.
- 0.44s: upward electricity dances to a luminous cloud *without making a drawn circle/cloud icon*.
- 0.84s: cloud field charges, suspended short forks with blue-violet atmospheric softness; target still visible.
- 1.15s: sharp bolt leader descends unevenly from heaven toward front-most fixed mock target (V19 A); a leading, nonuniform progressive white-hot line.
- 1.47s: **one** thick, structured primary sky-to-ground strike, with taper and real offshoot forks, a fast high-contrast intensity peak.
- 1.80s: 2 subsequent arcs jump from that first permitted mock target to two other permitted positions (V19 mode A); no contact on 4th mock monster; weaker cyan branches.
- 2.15s: contact threads and stray sparks on ground only; no giant ring or white blob covering actor.
- 2.70s: fully dispersed; character and monsters clear, no lingering permanent beam.

An independently selectable V19 **B/chain** comparison variant starts from caster's hand and jumps between the same exactly three fixed dummy positions. A and B share art primitives but distinct charge direction and strike staging. They are *alternative visuals*, NOT two real simultaneously cast skills. No gameplay skill ID, target or HP exists in this Lab.

## Geometry and light budget
- Main bolt: ~22 variable-kink segments / 4 luminance passes, width taper 10->3px, sampled from independent signed jitter with a deterministic low-frequency time seed (smooth 2-beat flicker, no fixed static lightning staircase).
- Forks: at most 6 main + 10 tiny crackles, cap branching depth 2, no unbounded recursion. Avoid equal-angle starburst.
- Contact: 1 hotspot and up to 7 asymmetric electrical earth-sparks, max one event per explicitly approved mock target. Only visual.
- 1280×720 1×, four real existing rig monsters, three fixed authorized demo positions, fourth ignored.
- No external images or textures; original Godot CanvasItem procedural white/cyan/violet light, optional V9 light-material technique, GL Compatibility only.
- Multi-agent stress and physical Android QA stay PENDING USER; code-only QA PASS ≠ art accepted. No live PvE, HP, DoT, SaveService, skill IDs, AI, or target changes. Single branch PR #72, no merge.

## Hold and acceptance
Only after writing isolated code and exporting true Godot 4.7.2 1280x720 A/B movie may one visually grade. If it looks like a stiff polyline, REWORK even if CI PASS. Mandatory >=8 Godot phase timestamps and owner visual decision. `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`.
