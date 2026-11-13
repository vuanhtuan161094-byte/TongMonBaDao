# VFX18.1 — ART BRIEF before implementation (Godot 4.7.2 LAB ONLY)
Date: 2026-11-13. Live parent SHA `5ceb94c54d8f071e5936c5fded68e00fe21b2903`.

This packet is authorized by the owner's explicit "tự làm tiếp", and follows `.agents/skills/tmb-vfx-art-director/SKILL.md`. Do not change VFX15, VFX17 or production PvE. Do not use Codex.

## What is being depicted
**Kiếm khí** = energy only, never a metal-blade sprite or runic polygon. In SINGLE demo exactly ONE cosmetic projectile and ONE mock contact on the fixed approved target; the other three combat-lab rig positions are unmodified. In ORBIT demo sixteen independent decorative light streaks, **zero damage/hit/target events**. Neither mode becomes a live skill.

## Visual art direction: 8-frame storyboard (normalized 0–1, 3.2s loop)
1. `t=0.06`: thin, broken V9-style energy veins crawl toward hand. Keep character readable.
2. `t=0.16`: strands converge into a brilliant but <=7px hot spot; faint cyan breath.
3. `t=0.25`: narrow compressed streak, pre-release anticipation; no UI ring.
4. `t=0.32`: first flight shows one tapered white-hot energy body, blue feathered halo, bending path-following wake, not steel.
5. `t=0.49`: flight accelerates with slight changes in taper and two weak living filaments.
6. `t=0.69`: streak contracts as it approaches the safe pre-contact tip; no sword overlaps monster chest.
7. `t=0.76`: discrete incisional cyan-white diagonal peak, five short directional splinters, NOT a circular flash; one approved demo contact only.
8. `t=0.83`: clean dissolve; no phantom glowing polygon left over.

Orbit: start partially compressed around clear centered actor, unwind into two projected ellipses by t~0.15; outer and inner rings rotate in opposite directions, each has speed, taper, length and luminance variation. **Back** shards pass behind a real foreground actor layer; **front** shards pass in front, with limited intensity; soft broken ground energy ring but no fake AoE. Use existing original shader and bounded 16 carriers.

## Design gates
- Preserve exact shader hot-tip pixel/world anchor; use existing R2 <0.65px contract.
- Replace flat identical 3-line charge with five curved energy filaments of phase-varying amplitudes; no opaque filled polygons.
- Amplify contact by short incisional flash + ~5 sparse sparks after REAL sample event; do not alter target selector, HP, DoT, combat state.
- For orbit use y-projected front/back depth and actual separate actor Draw layer. Enforce bounded 16 streaks and alpha; use realistic falloff and nonuniform intensity.
- Keep compatibility with GL Compatibility: no HDR bloom dependency, no copied JX/Source A VFX texture, no unbounded spawn and no gameplay stat writes.
- Godot focused strict import, parse, contract and exact SHA; actual **native 1280×720 Godot MP4**, inspect 8+ timestamps; compare with R2 exact-capture footage and owner reference at native 1x. Art acceptance stays PENDING even if focused PASS.

## Allowed code paths
`godot/labs/combat_lab/research03/**`, `godot/tests/labs/combat_lab/research03_contract_test.gd`, isolated CI workflow only if necessary, corresponding docs and handoff. No production scenes/events/save nor cross-skill files.
