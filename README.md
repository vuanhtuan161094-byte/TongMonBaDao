# Tông Môn Bá Đạo — Tông Môn Tycoon

Godot 4.7.2 / GDScript simulation project for an autonomous cultivation-sect management game.

## Core direction

The player builds and manages a sect instead of directly puppeting every disciple.

Disciples act autonomously from personality, goals, relationships, memories, organization, sect resources, cultivation realm, spiritual roots, techniques, accumulated Kiếm/Thể/Pháp path history, learned combat skills and equipment.

Godot/GDScript is the gameplay authority. The simulation is deterministic and seeded; save/load and invariants are part of every phase contract.

## Implemented stack

- P0 — autonomous hunt/combat/loot/economy/recovery foundation.
- P1.1 — goals + personality.
- P1.2 — recruitment + player choice.
- P1.3 — relationships.
- P1.4 — consequential memory.
- P1.5 — teams, leadership and roles.
- P1.6 — sect needs and resource pressure.
- P2.1 — cultivation, realms and breakthroughs.
- P2.2 — spiritual-root quality/elements.
- P2.3 — technique economy, library and mastery.
- P2.4 — classless Kiếm/Thể/Pháp identity from accumulated path XP.
- P2.5 — deterministic real-time autonomous combat skills.
- P2.6 — Luyện Khí / forge / equipment tycoon loop.

## P2.6 loop

`hunt -> forge materials -> Luyện Khí Đường -> equipment -> sect storage/shop -> autonomous purchase or player allocation -> stronger disciple -> harder hunt`

P2.6 supports:

- deterministic forging and quality;
- sect equipment storage/shop;
- build-aware autonomous equipment purchasing;
- closed internal money transfer from disciple wallet to sect treasury;
- manual equip by the player;
- slot lock to override AI;
- return-to-auto;
- path/root/skill compatibility that changes real equipment effectiveness;
- equipment effects on region choice and P2.5 combat;
- exact SaveService v2 persistence.

See `docs/P2_6_SPEC.md` for the current contract.

## Runtime status

Real Windows/Godot 4.7.2 evidence currently confirms P0 through P1.6 PASS.

The first unresolved cumulative runtime gate is P2.1 save/load persistence. A dedicated first-difference diagnostic is already chained into `Verify-P2-1.ps1`.

P2.2 through P2.6 are implemented but must not be called PASS until the cumulative runtime gate reaches and verifies them.

See `CURRENT_CHECKPOINT.md` for the authoritative status.

## Windows — authoritative verification

After updating local `main`:

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-6.cmd
```

`Sync-P2-6.cmd` fast-forwards a clean local `main` and runs the cumulative P0 -> P2.6 verification chain.

Direct verification without sync:

```bat
Verify-P2-6.cmd
```

Older phase PowerShell verifiers remain under `tools/godot` because the cumulative chain depends on them. Only the latest root `.cmd` launchers are kept.

## Development rules

Read in order before changing simulation code:

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. `NEXT_CHAT_HANDOFF.md`
4. the active phase spec under `docs/`

Do not mark a phase PASS from source inspection alone. Runtime evidence must come from the real Godot gate.
